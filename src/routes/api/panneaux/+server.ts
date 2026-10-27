import { supabase } from '#lib/supabaseClient.ts';
import type { RequestHandler } from '@sveltejs/kit';

export const GET: RequestHandler = async () => {
    const { data, error, status, statusText } = await supabase
        .from('panneaux')
        .select('*');

    console.log('Supabase status:', status, statusText);
    console.log('Supabase data:', data);
    console.log('Supabase error:', error);

	if (error) return Response.json({ error: error.message }, { status: 500 });

	return Response.json({ panneaux: data ?? [] });
};
