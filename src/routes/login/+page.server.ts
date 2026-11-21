import { redirect } from '@sveltejs/kit';
import { hasAuthClaims } from '#lib/auth.ts';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
	if (await hasAuthClaims(locals.supabase)) {
		throw redirect(302, '/');
	}

	return {};
};
