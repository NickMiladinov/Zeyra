/**
 * Standalone script to import PLACE NHS data directly to Supabase
 * 
 * This script can be run locally with Deno to import PLACE data directly,
 * without needing to deploy the edge function first.
 * 
 * Usage:
 *   deno run --allow-read --allow-net --allow-env scripts/import-place-data.ts <path-to-csv>
 * 
 * Environment variables required:
 *   SUPABASE_URL - Your Supabase project URL
 *   SUPABASE_SERVICE_ROLE_KEY - Your Supabase service role key (for direct DB access)
 * 
 * Example:
 *   deno run --allow-read --allow-net --allow-env scripts/import-place-data.ts "C:\Users\nikol\Downloads\PLACE-2024-Site-Scores(PLACE-2024-Site-Scores).csv"
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

// ============================================
// TYPES
// ============================================

interface PlaceRating {
  siteCode: string;
  siteName: string;
  cleanliness: number | null;
  food: number | null;
  privacyDignityWellbeing: number | null;
  conditionAppearance: number | null;
}

// ============================================
// CSV PARSING
// ============================================

/**
 * Parses a percentage string like "98.08%" or "N/A" to a number or null
 */
function parsePercentage(value: string): number | null {
  const trimmed = value.trim();
  
  if (!trimmed || trimmed === "N/A" || trimmed === "-" || trimmed === "") {
    return null;
  }
  
  const numStr = trimmed.replace("%", "").trim();
  const num = parseFloat(numStr);
  
  return isNaN(num) ? null : num;
}

/**
 * Parses a CSV line handling quoted fields with commas
 */
function parseCSVLine(line: string): string[] {
  const result: string[] = [];
  let current = "";
  let inQuotes = false;
  
  for (let i = 0; i < line.length; i++) {
    const char = line[i];
    
    if (char === '"') {
      inQuotes = !inQuotes;
    } else if (char === "," && !inQuotes) {
      result.push(current.trim());
      current = "";
    } else {
      current += char;
    }
  }
  
  result.push(current.trim());
  return result;
}

/**
 * Parses the PLACE CSV content
 * 
 * CSV columns:
 * 0: Organisation Code
 * 1: Organisation Name
 * 2: Commissioning Region
 * 3: Site Code          <-- matches cqc_location_id
 * 4: Site Name
 * 5: Organisation Type
 * 6: NHS or Independent
 * 7: PLACE Site Type
 * 8: Cleanliness        <-- extract
 * 9: Combined Food      <-- extract
 * 10: Organisation Food
 * 11: Ward Food
 * 12: Privacy, Dignity and Wellbeing  <-- extract
 * 13: Condition Appearance and Maintenance  <-- extract
 */
function parseCSV(csvContent: string): PlaceRating[] {
  const ratings: PlaceRating[] = [];
  const lines = csvContent.split(/\r?\n/);
  
  for (let i = 1; i < lines.length; i++) {
    const line = lines[i].trim();
    if (!line) continue;
    
    const fields = parseCSVLine(line);
    
    if (fields.length < 14) {
      console.warn(`Line ${i + 1}: Insufficient columns (${fields.length}), skipping`);
      continue;
    }
    
    const siteCode = fields[3].trim();
    if (!siteCode) continue;
    
    ratings.push({
      siteCode,
      siteName: fields[4].trim(),
      cleanliness: parsePercentage(fields[8]),
      food: parsePercentage(fields[9]),
      privacyDignityWellbeing: parsePercentage(fields[12]),
      conditionAppearance: parsePercentage(fields[13]),
    });
  }
  
  return ratings;
}

// ============================================
// MAIN
// ============================================

async function main() {
  // Get CSV file path from arguments
  if (Deno.args.length === 0) {
    console.error("Usage: deno run --allow-read --allow-net --allow-env scripts/import-place-data.ts <path-to-csv>");
    Deno.exit(1);
  }

  const csvPath = Deno.args[0];

  // Get environment variables
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !supabaseServiceKey) {
    console.error("Error: Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables");
    console.error("\nYou can set them by running:");
    console.error("  export SUPABASE_URL=https://your-project.supabase.co");
    console.error("  export SUPABASE_SERVICE_ROLE_KEY=your-service-role-key");
    Deno.exit(1);
  }

  // Read CSV file
  console.log(`\n📁 Reading CSV from: ${csvPath}`);
  const csvContent = await Deno.readTextFile(csvPath);
  
  console.log(`   Size: ${(csvContent.length / 1024).toFixed(1)} KB`);
  
  // Parse CSV
  console.log("\n📊 Parsing CSV...");
  const ratings = parseCSV(csvContent);
  console.log(`   Found ${ratings.length} PLACE entries`);

  // Connect to Supabase
  console.log("\n🔌 Connecting to Supabase...");
  const supabase = createClient(supabaseUrl, supabaseServiceKey);

  // Get all site codes to check which ones exist
  const siteCodes = ratings.map((r) => r.siteCode);
  
  console.log("\n🔍 Checking for matching maternity units...");
  const { data: existingUnits, error: queryError } = await supabase
    .from("maternity_units")
    .select("cqc_location_id, name")
    .in("cqc_location_id", siteCodes);

  if (queryError) {
    console.error(`Database query error: ${queryError.message}`);
    Deno.exit(1);
  }

  const existingCodes = new Map<string, string>();
  existingUnits?.forEach((u) => {
    existingCodes.set(u.cqc_location_id, u.name);
  });

  console.log(`   Found ${existingCodes.size} matching maternity units`);

  // Filter to matched ratings
  const matchedRatings = ratings.filter((r) => existingCodes.has(r.siteCode));
  const unmatchedCount = ratings.length - matchedRatings.length;

  if (matchedRatings.length === 0) {
    console.log("\n⚠️  No matching units found. Nothing to update.");
    Deno.exit(0);
  }

  // Update each matched unit
  console.log(`\n📝 Updating ${matchedRatings.length} maternity units...`);
  const syncTimestamp = new Date().toISOString();
  
  let updated = 0;
  let errors = 0;

  for (const rating of matchedRatings) {
    const { error: updateError } = await supabase
      .from("maternity_units")
      .update({
        place_cleanliness: rating.cleanliness,
        place_food: rating.food,
        place_privacy_dignity_wellbeing: rating.privacyDignityWellbeing,
        place_condition_appearance: rating.conditionAppearance,
        place_synced_at: syncTimestamp,
      })
      .eq("cqc_location_id", rating.siteCode);

    if (updateError) {
      console.error(`   ❌ Error updating ${rating.siteCode}: ${updateError.message}`);
      errors++;
    } else {
      updated++;
      // Show progress every 10 units
      if (updated % 10 === 0) {
        console.log(`   ✓ Updated ${updated}/${matchedRatings.length}...`);
      }
    }
  }

  // Summary
  console.log("\n" + "=".repeat(50));
  console.log("📋 PLACE Data Import Summary");
  console.log("=".repeat(50));
  console.log(`Total PLACE entries parsed:  ${ratings.length}`);
  console.log(`Matched maternity units:     ${matchedRatings.length}`);
  console.log(`Successfully updated:        ${updated}`);
  console.log(`Errors:                      ${errors}`);
  console.log(`Unmatched site codes:        ${unmatchedCount}`);
  console.log("=".repeat(50));

  if (updated > 0) {
    console.log("\n✅ Import completed successfully!");
    
    // Show a few examples
    console.log("\n📍 Sample updated units:");
    const samples = matchedRatings.slice(0, 5);
    for (const sample of samples) {
      const name = existingCodes.get(sample.siteCode);
      console.log(`   - ${name}`);
      console.log(`     Cleanliness: ${sample.cleanliness ?? "N/A"}%`);
      console.log(`     Food: ${sample.food ?? "N/A"}%`);
    }
  }

  Deno.exit(errors > 0 ? 1 : 0);
}

main();
