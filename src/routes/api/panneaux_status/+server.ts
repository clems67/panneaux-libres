import { hasAuthClaims } from '#lib/auth.ts';
import type { RequestHandler } from '@sveltejs/kit';

export const POST: RequestHandler = async ({ locals, request }) => {
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

	const { id, new_status } = await request.json();

	const { data, error } = await locals.supabase
		.from('panneaux')
		.update({ status: new_status })
		.eq('id', id)
		.select();

	if (error) {
		return new Response(JSON.stringify({ error: error.message }), {
			status: 500,
			headers: {
				'Content-Type': 'application/json'
			}
		});
	}

	return new Response(JSON.stringify(data), {
		status: 200,
		headers: {
			'Content-Type': 'application/json'
		}
	});
};
