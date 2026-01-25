// supabase/functions/sync-cqc-maternity/index.ts
// Syncs maternity locations from CQC API to Supabase
// Supports:
//   - Batched full sync (mode: "batch" with page/perPage)
//   - Incremental daily sync (mode: "incremental")

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

// ============================================
// TYPES
// ============================================

interface CQCLocationListResponse {
  total: number;
  page: number;
  perPage: number;
  totalPages: number;
  locations: Array<{
    locationId: string;
    locationName: string;
    postalCode: string;
  }>;
}

interface CQCChangesResponse {
  total: number;
  page: number;
  perPage: number;
  totalPages: number;
  changes: string[]; // Array of location IDs that changed
}

interface CQCLocationDetail {
  locationId: string;
  providerId: string;
  name: string;
  type: string;
  postalAddressLine1: string;
  postalAddressLine2: string;
  postalAddressTownCity: string;
  postalAddressCounty: string;
  postalCode: string;
  region: string;
  localAuthority: string;
  onspdLatitude: number;
  onspdLongitude: number;
  mainPhoneNumber: string;
  website: string;
  odsCode: string;
  registrationStatus: string;
  lastInspection?: { date: string };
  lastReport?: { publicationDate: string };
  reports?: Array<{ linkId: string; reportUri: string }>;
  currentRatings?: {
    overall?: {
      rating: string;
      reportDate: string;
      keyQuestionRatings?: Array<{ name: string; rating: string }>;
    };
    serviceRatings?: Array<{
      name: string;
      rating: string;
      reportDate: string;
    }>;
  };
  regulatedActivities?: Array<{ name: string; code: string }>;
  inspectionAreas?: Array<{
    inspectionAreaId: string;
    inspectionAreaName: string;
    status: string;
  }>;
}

interface BatchSyncResult {
  success: boolean;
  mode: "batch" | "incremental";
  page?: number;
  perPage?: number;
  totalPages?: number;
  totalLocations?: number;
  processedInBatch: number;
  upsertedInBatch: number;
  errors: string[];
  nextPage?: number | null;
  isComplete: boolean;
  // Incremental-specific fields
  changedIdsFromCQC?: number;
  matchedMaternityUnits?: number;
  syncWindow?: { start: string; end: string };
}

// ============================================
// CONFIGURATION
// ============================================

const CQC_BASE_URL = "https://api.service.cqc.org.uk/public/v1";
const MATERNITY_ACTIVITY = "Maternity and midwifery services";
const DELAY_BETWEEN_REQUESTS_MS = 100; // Be nice to the CQC API

// ============================================
// HELPER FUNCTIONS
// ============================================

function delay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function fetchCQCApi<T>(endpoint: string, apiKey: string): Promise<T> {
  const response = await fetch(`${CQC_BASE_URL}${endpoint}`, {
    headers: {
      "Ocp-Apim-Subscription-Key": apiKey,
      Accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(`CQC API error: ${response.status} ${response.statusText}`);
  }

  return response.json();
}

function extractKeyQuestionRating(
  keyQuestions: Array<{ name: string; rating: string }> | undefined,
  questionName: string
): string | null {
  if (!keyQuestions) return null;
  const found = keyQuestions.find(
    (kq) => kq.name.toLowerCase() === questionName.toLowerCase()
  );
  return found?.rating || null;
}

function extractMaternityRating(
  serviceRatings:
    | Array<{ name: string; rating: string; reportDate: string }>
    | undefined
): { rating: string | null; date: string | null } {
  if (!serviceRatings) return { rating: null, date: null };

  const maternityRating = serviceRatings.find(
    (sr) =>
      sr.name.toLowerCase().includes("maternity") ||
      sr.name === "independentmaternity"
  );

  return {
    rating: maternityRating?.rating || null,
    date: maternityRating?.reportDate || null,
  };
}

function buildCQCReportUrl(locationId: string): string {
  return `https://www.cqc.org.uk/location/${locationId}`;
}

function determineUnitType(location: CQCLocationDetail): string {
  if (location.type?.toLowerCase().includes("independent")) {
    return "independent_hospital";
  }
  return "nhs_hospital";
}

function transformToDbRecord(
  location: CQCLocationDetail
): Record<string, unknown> {
  const overallRatings = location.currentRatings?.overall;
  const keyQuestions = overallRatings?.keyQuestionRatings;
  const maternityRating = extractMaternityRating(
    location.currentRatings?.serviceRatings
  );

  return {
    cqc_location_id: location.locationId,
    cqc_provider_id: location.providerId || null,
    ods_code: location.odsCode || null,
    name: location.name,
    provider_name: null,
    unit_type: determineUnitType(location),
    is_nhs: !location.type?.toLowerCase().includes("independent"),
    address_line_1: location.postalAddressLine1 || null,
    address_line_2: location.postalAddressLine2 || null,
    town_city: location.postalAddressTownCity || null,
    county: location.postalAddressCounty || null,
    postcode: location.postalCode || null,
    region: location.region || null,
    local_authority: location.localAuthority || null,
    latitude: location.onspdLatitude || null,
    longitude: location.onspdLongitude || null,
    phone: location.mainPhoneNumber || null,
    website: location.website || null,
    overall_rating: overallRatings?.rating || null,
    rating_safe: extractKeyQuestionRating(keyQuestions, "Safe"),
    rating_effective: extractKeyQuestionRating(keyQuestions, "Effective"),
    rating_caring: extractKeyQuestionRating(keyQuestions, "Caring"),
    rating_responsive: extractKeyQuestionRating(keyQuestions, "Responsive"),
    rating_well_led: extractKeyQuestionRating(keyQuestions, "Well-led"),
    maternity_rating: maternityRating.rating,
    maternity_rating_date: maternityRating.date,
    last_inspection_date: location.lastInspection?.date || null,
    cqc_report_url: buildCQCReportUrl(location.locationId),
    registration_status: location.registrationStatus || "Registered",
    is_active: location.registrationStatus === "Registered",
    cqc_synced_at: new Date().toISOString(),
  };
}

// ============================================
// BATCH SYNC LOGIC (for initial/full sync)
// ============================================

async function syncBatch(
  supabase: ReturnType<typeof createClient>,
  cqcApiKey: string,
  page: number,
  perPage: number
): Promise<BatchSyncResult> {
  const result: BatchSyncResult = {
    success: false,
    mode: "batch",
    page,
    perPage,
    totalPages: 0,
    totalLocations: 0,
    processedInBatch: 0,
    upsertedInBatch: 0,
    errors: [],
    nextPage: null,
    isComplete: false,
  };

  try {
    console.log(`Starting batch sync for page ${page} (perPage: ${perPage})...`);

    const encodedActivity = encodeURIComponent(MATERNITY_ACTIVITY);
    const listResponse = await fetchCQCApi<CQCLocationListResponse>(
      `/locations?regulatedActivity=${encodedActivity}&perPage=${perPage}&page=${page}`,
      cqcApiKey
    );

    result.totalPages = listResponse.totalPages;
    result.totalLocations = listResponse.total;

    const locationIds = listResponse.locations.map((l) => l.locationId);
    console.log(
      `Page ${page}/${listResponse.totalPages}: Found ${locationIds.length} locations to process`
    );

    const batchRecords: Record<string, unknown>[] = [];

    for (const locationId of locationIds) {
      try {
        const detail = await fetchCQCApi<CQCLocationDetail>(
          `/locations/${locationId}`,
          cqcApiKey
        );

        const record = transformToDbRecord(detail);
        batchRecords.push(record);
        result.processedInBatch++;

        await delay(DELAY_BETWEEN_REQUESTS_MS);
      } catch (error) {
        const errorMsg = `Error fetching location ${locationId}: ${error}`;
        console.error(errorMsg);
        result.errors.push(errorMsg);
      }
    }

    if (batchRecords.length > 0) {
      console.log(`Upserting ${batchRecords.length} records to database...`);

      const { data, error } = await supabase
        .from("maternity_units")
        .upsert(batchRecords, {
          onConflict: "cqc_location_id",
          ignoreDuplicates: false,
        })
        .select("id");

      if (error) {
        const errorMsg = `Database upsert error: ${error.message}`;
        console.error(errorMsg);
        result.errors.push(errorMsg);
      } else {
        result.upsertedInBatch = data?.length || 0;
        console.log(`Successfully upserted ${result.upsertedInBatch} records`);
      }
    }

    if (page < listResponse.totalPages) {
      result.nextPage = page + 1;
      result.isComplete = false;
    } else {
      result.nextPage = null;
      result.isComplete = true;
    }

    result.success = result.errors.length === 0;

    console.log(
      `Batch ${page} complete. Processed: ${result.processedInBatch}, Upserted: ${result.upsertedInBatch}, Errors: ${result.errors.length}`
    );
  } catch (error) {
    const errorMsg = `Fatal batch error: ${error}`;
    console.error(errorMsg);
    result.errors.push(errorMsg);
  }

  return result;
}

// ============================================
// INCREMENTAL SYNC LOGIC (for daily cron job)
// ============================================

async function syncIncremental(
  supabase: ReturnType<typeof createClient>,
  cqcApiKey: string
): Promise<BatchSyncResult> {
  const result: BatchSyncResult = {
    success: false,
    mode: "incremental",
    processedInBatch: 0,
    upsertedInBatch: 0,
    errors: [],
    isComplete: false,
    changedIdsFromCQC: 0,
    matchedMaternityUnits: 0,
  };

  try {
    console.log("Starting incremental sync...");

    // Step 1: Get last SUCCESSFUL sync timestamp from metadata table
    // We query for the most recent successful run to get the starting timestamp
    const { data: metaData, error: metaError } = await supabase
      .from("sync_metadata")
      .select("last_sync_at")
      .eq("last_sync_status", "success")
      .order("last_sync_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (metaError) {
      throw new Error(`Failed to get sync metadata: ${metaError.message}`);
    }

    // Default to 24 hours ago if no successful sync found
    const lastSyncAt = metaData?.last_sync_at
      ? new Date(metaData.last_sync_at)
      : new Date(Date.now() - 24 * 60 * 60 * 1000);

    const now = new Date();

    // Format timestamps for CQC API (ISO 8601)
    const startTimestamp = lastSyncAt.toISOString().split('.')[0] + 'Z';
    const endTimestamp = now.toISOString().split('.')[0] + 'Z';

    result.syncWindow = { start: startTimestamp, end: endTimestamp };

    console.log(`Sync window: ${startTimestamp} to ${endTimestamp}`);

    // Step 2: Get all changed location IDs from CQC (may need pagination)
    let allChangedIds: string[] = [];
    let page = 1;
    let totalPages = 1;

    do {
      const changesResponse = await fetchCQCApi<CQCChangesResponse>(
        `/changes/location?startTimestamp=${encodeURIComponent(startTimestamp)}&endTimestamp=${encodeURIComponent(endTimestamp)}&perPage=1000&page=${page}`,
        cqcApiKey
      );

      allChangedIds = allChangedIds.concat(changesResponse.changes);
      totalPages = changesResponse.totalPages;
      page++;

      console.log(
        `Fetched changes page ${page - 1}/${totalPages}, IDs so far: ${allChangedIds.length}`
      );

      await delay(DELAY_BETWEEN_REQUESTS_MS);
    } while (page <= totalPages);

    result.changedIdsFromCQC = allChangedIds.length;
    console.log(`Total changed location IDs from CQC: ${allChangedIds.length}`);

    if (allChangedIds.length === 0) {
      console.log("No changes found. Updating sync timestamp.");
      result.success = true;
      result.isComplete = true;

      // Update sync metadata even if no changes
      await updateSyncMetadataSuccess(supabase, now, "success", 0);

      return result;
    }

    // Step 3: Filter to only IDs that exist in our maternity_units table
    // We do this because /changes returns ALL location changes, not just maternity
    const { data: existingUnits, error: existingError } = await supabase
      .from("maternity_units")
      .select("cqc_location_id")
      .in("cqc_location_id", allChangedIds);

    if (existingError) {
      throw new Error(`Failed to check existing units: ${existingError.message}`);
    }

    const maternityChangedIds = existingUnits?.map((u) => u.cqc_location_id) || [];
    result.matchedMaternityUnits = maternityChangedIds.length;

    console.log(
      `Filtered to ${maternityChangedIds.length} maternity units that changed`
    );

    if (maternityChangedIds.length === 0) {
      console.log("No maternity unit changes. Updating sync timestamp.");
      result.success = true;
      result.isComplete = true;

      await updateSyncMetadataSuccess(supabase, now, "success", 0);

      return result;
    }

    // Step 4: Fetch details and update each changed maternity unit
    const batchRecords: Record<string, unknown>[] = [];

    for (const locationId of maternityChangedIds) {
      try {
        const detail = await fetchCQCApi<CQCLocationDetail>(
          `/locations/${locationId}`,
          cqcApiKey
        );

        const record = transformToDbRecord(detail);
        batchRecords.push(record);
        result.processedInBatch++;

        await delay(DELAY_BETWEEN_REQUESTS_MS);
      } catch (error) {
        const errorMsg = `Error fetching location ${locationId}: ${error}`;
        console.error(errorMsg);
        result.errors.push(errorMsg);
      }
    }

    // Step 5: Upsert updated records
    if (batchRecords.length > 0) {
      console.log(`Upserting ${batchRecords.length} updated records...`);

      const { data, error } = await supabase
        .from("maternity_units")
        .upsert(batchRecords, {
          onConflict: "cqc_location_id",
          ignoreDuplicates: false,
        })
        .select("id");

      if (error) {
        const errorMsg = `Database upsert error: ${error.message}`;
        console.error(errorMsg);
        result.errors.push(errorMsg);
      } else {
        result.upsertedInBatch = data?.length || 0;
        console.log(`Successfully upserted ${result.upsertedInBatch} records`);
      }
    }

    // Step 6: Update sync metadata
    if (result.errors.length === 0) {
      // Full success - update timestamp
      await updateSyncMetadataSuccess(supabase, now, "success", result.upsertedInBatch);
    } else {
      // Partial success - still update timestamp but note errors
      // (We processed some records, so we should advance the timestamp)
      await updateSyncMetadataSuccess(supabase, now, "completed_with_errors", result.upsertedInBatch);
    }

    result.success = result.errors.length === 0;
    result.isComplete = true;

    console.log(
      `Incremental sync complete. Updated: ${result.upsertedInBatch}, Errors: ${result.errors.length}`
    );
  } catch (error) {
    const errorMsg = `Fatal incremental sync error: ${error}`;
    console.error(errorMsg);
    result.errors.push(errorMsg);

    // Update sync metadata with error but DO NOT update last_sync_at
    // This ensures the next run will retry the same time window
    await updateSyncMetadataFailure(supabase, "failed", errorMsg);
  }

  return result;
}

// Helper to insert sync_metadata entry on SUCCESS (records the sync timestamp)
async function updateSyncMetadataSuccess(
  supabase: ReturnType<typeof createClient>,
  syncTime: Date,
  status: string,
  count: number
): Promise<void> {
  // Insert a new row for each sync run
  const { error: insertError } = await supabase
    .from("sync_metadata")
    .insert({
      last_sync_at: syncTime.toISOString(), // Record the sync timestamp on success
      last_sync_status: status,
      last_sync_count: count,
      last_error: null,
      updated_at: new Date().toISOString(),
    });

  if (insertError) {
    console.error(`Failed to insert sync metadata: ${insertError.message}`);
  }
}

// Helper to insert sync_metadata entry on FAILURE (does NOT set last_sync_at)
async function updateSyncMetadataFailure(
  supabase: ReturnType<typeof createClient>,
  status: string,
  errorMsg: string
): Promise<void> {
  // Insert a new row with null last_sync_at to indicate failure
  // This ensures the next run will use the last successful run's timestamp
  const { error: insertError } = await supabase
    .from("sync_metadata")
    .insert({
      last_sync_at: null, // No timestamp update on failure
      last_sync_status: status,
      last_sync_count: 0,
      last_error: errorMsg,
      updated_at: new Date().toISOString(),
    });

  if (insertError) {
    console.error(`Failed to insert sync metadata: ${insertError.message}`);
  }
}

// ============================================
// HTTP HANDLER
// ============================================

serve(async (req: Request) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
  };

  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing authorization" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const cqcApiKey = Deno.env.get("CQC_API_KEY");

    if (!supabaseUrl || !supabaseServiceKey || !cqcApiKey) {
      throw new Error("Missing required environment variables");
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Parse request body
    let mode: "batch" | "incremental" = "batch";
    let page = 1;
    let perPage = 50;

    try {
      const body = await req.json();
      mode = body.mode || "batch";
      page = body.page || 1;
      perPage = Math.min(body.perPage || 50, 100);
    } catch {
      // No body or invalid JSON, use defaults
    }

    let result: BatchSyncResult;

    if (mode === "incremental") {
      // Daily cron job mode - uses /changes endpoint
      result = await syncIncremental(supabase, cqcApiKey);
    } else {
      // Batch mode - for initial/full sync
      result = await syncBatch(supabase, cqcApiKey, page, perPage);
    }

    return new Response(JSON.stringify(result), {
      status: result.success ? 200 : 207,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Handler error:", error);
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
