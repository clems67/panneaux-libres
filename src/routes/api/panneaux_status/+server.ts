import { supabase } from '#lib/supabaseClient.ts';
import type { RequestHandler } from '@sveltejs/kit';

export const POST: RequestHandler = async ({ request }) => {
	const { id, new_status } = await request.json();

	const { data, error } = await supabase
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
