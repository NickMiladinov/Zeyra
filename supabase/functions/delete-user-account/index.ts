import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

type JsonRecord = Record<string, unknown>;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function jsonResponse(payload: JsonRecord, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse(
      {
        success: false,
        code: "method_not_allowed",
        message: "Only POST is supported.",
      },
      405,
    );
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return jsonResponse(
      {
        success: false,
        code: "missing_authorization",
        message: "Authorization header is required.",
      },
      401,
    );
  }
  const bearerPrefix = "Bearer ";
  const hasBearerPrefix = authHeader.startsWith(bearerPrefix);
  const accessToken = hasBearerPrefix
    ? authHeader.slice(bearerPrefix.length)
    : authHeader;

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey) {
    return jsonResponse(
      {
        success: false,
        code: "missing_env",
        message: "Supabase environment variables are missing.",
      },
      500,
    );
  }

  let body: JsonRecord = {};
  try {
    body = (await req.json()) as JsonRecord;
  } catch {
    // Request body is optional. Missing/invalid JSON should not block deletion.
  }

  if (body["confirmDeletion"] == false) {
    return jsonResponse(
      {
        success: false,
        code: "confirmation_required",
        message: "confirmDeletion must be true.",
      },
      400,
    );
  }

  try {
    const userClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user },
      error: getUserError,
    } = await userClient.auth.getUser(accessToken);

    if (getUserError || !user) {
      return jsonResponse(
        {
          success: false,
          code: "invalid_token",
          message: getUserError?.message ?? "Could not verify authenticated user.",
        },
        401,
      );
    }

    const adminClient = createClient(supabaseUrl, supabaseServiceRoleKey);
    const { error: deleteError } = await adminClient.auth.admin.deleteUser(
      user.id,
    );

    if (deleteError) {
      return jsonResponse(
        {
          success: false,
          code: "delete_failed",
          message: deleteError.message,
        },
        500,
      );
    }

    return jsonResponse(
      {
        success: true,
        code: "deleted",
        userId: user.id,
      },
      200,
    );
  } catch (error) {
    return jsonResponse(
      {
        success: false,
        code: "unexpected_error",
        message: String(error),
      },
      500,
    );
  }
});
