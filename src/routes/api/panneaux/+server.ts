import { hasAuthClaims } from '#lib/auth.ts';
import type { RequestHandler } from '@sveltejs/kit';

export const GET: RequestHandler = async ({ locals }) => {
	if (!(await hasAuthClaims(locals.supabase))) {
		// Clear any stale session left behind before rejecting the request.
		await locals.supabase.auth.signOut();

		return new Response(JSON.stringify({ error: 'Unauthorized' }), {
			status: 401,
			headers: {
				'Content-Type': 'application/json'
			}
		});
	}

	const { data, error } = await locals.supabase.from('panneaux').select('*');

	if (error) {
		console.error('Failed to fetch panneaux:', error);
		return Response.json({ error: error.message }, { status: 500 });
	}

	return Response.json({ panneaux: data ?? [] });
};
