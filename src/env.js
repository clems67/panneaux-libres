import { defineEnvVars } from "@sveltejs/kit/env";

export const variables = defineEnvVars({
    PUBLIC_SUPABASE_URL:{},
    PUBLIC_SUPABASE_PUBLISHABLE_KEY:{}
})