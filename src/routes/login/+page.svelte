<script lang="ts">
	import { page } from '$app/state';
	import { goto } from '$app/navigation';
	import { getPostLoginRedirect } from '#lib/auth.ts';

	let { data } = $props();
	let { supabase } = $derived(data);

	let email = $state('');
	let password = $state('');
	let error = $state<string | null>(null);
	let loading = $state(false);

	const redirectTo = $derived.by(() =>
		getPostLoginRedirect(page.url.searchParams.get('redirect_to'))
	);

	async function handleSubmit(event: Event) {
		event.preventDefault();
		if (loading) return;

		loading = true;
		error = null;

		const { error: signInError } = await supabase.auth.signInWithPassword({
			email: email.trim(),
			password
		});

		loading = false;

		if (signInError) {
			error = signInError.message;
			return;
		}

		await goto(redirectTo);
	}
</script>

<svelte:head>
	<title>Connexion</title>
</svelte:head>

<div class="flex min-h-0 flex-1 items-center justify-center px-4 mt-8">
	<div class="w-full max-w-md rounded-2xl bg-white p-6 shadow-lg">
		<h1 class="mb-6 text-center text-2xl font-bold text-[#4c0297]">Connexion</h1>

		{#if error}
			<p class="mb-4 rounded-lg bg-red-50 px-3 py-2 text-sm text-red-600">{error}</p>
		{/if}

		<form class="flex flex-col gap-4" onsubmit={handleSubmit}>
			<div class="flex flex-col gap-2">
				<label class="text-sm font-semibold text-gray-700" for="email">Email</label>
				<input
					id="email"
					name="email"
					type="email"
					bind:value={email}
					required
					class="rounded-lg border border-gray-300 px-3 py-2 focus:border-[#4c0297] focus:outline-2 focus:outline-offset-2 focus:outline-[#4c0297]"
				/>
			</div>

			<div class="flex flex-col gap-2">
				<label class="text-sm font-semibold text-gray-700" for="password">Mot de passe</label>
				<input
					id="password"
					name="password"
					type="password"
					bind:value={password}
					required
					class="rounded-lg border border-gray-300 px-3 py-2 focus:border-[#4c0297] focus:outline-2 focus:outline-offset-2 focus:outline-[#4c0297]"
				/>
			</div>

			<button
				type="submit"
				class="w-full rounded-lg bg-[#4c0297] px-4 py-2 font-bold text-white transition hover:bg-[#6a03b3] disabled:cursor-not-allowed disabled:opacity-60"
				disabled={loading}
			>
				{loading ? 'Connexion…' : 'Se connecter'}
			</button>
		</form>

		<p class="mt-4 text-center text-sm text-gray-600">
			Pas encore de compte ?
			<a href="/signup" class="font-semibold text-[#4c0297] hover:underline">Créer un compte</a>
		</p>
	</div>
</div>
