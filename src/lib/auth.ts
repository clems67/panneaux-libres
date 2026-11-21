import type { SupabaseClient } from '@supabase/supabase-js';

/**
 * Whether the current session carries valid (and non-expired) auth claims
 * for an existing user. Performs a server-side lookup via the Auth server so
 * that users deleted in the meantime are rejected as well.
 */
export const hasAuthClaims = async (supabase: SupabaseClient): Promise<boolean> => {
	const { data, error } = await supabase.auth.getUser();
	const user = error ? null : data?.user;
	return user != null;
};

export const getPostLoginRedirect = (redirectTo: string | null): string => {
	if (redirectTo && redirectTo.startsWith('/') && !redirectTo.startsWith('//')) {
		return redirectTo;
	}

	return '/';
};
