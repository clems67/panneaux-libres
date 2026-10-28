import { supabase } from '#lib/supabaseClient.ts';
import type { RequestHandler } from '@sveltejs/kit';

export const GET: RequestHandler = async () => {
	const { data, error } = await supabase.from('panneaux').select('*');

	if (error) return Response.json({ error: error.message }, { status: 500 });

	return Response.json({ panneaux: data ?? [] });
};
