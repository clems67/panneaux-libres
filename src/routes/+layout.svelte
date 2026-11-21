<script lang="ts">
	import './layout.css';
	import Install from '#lib/components/Install.svelte';
	import { invalidate } from '$app/navigation';
	import { onMount } from 'svelte';
	import MenuIcon from '@lucide/svelte/icons/menu';
	import { Menu, Portal } from '@skeletonlabs/skeleton-svelte';

	let { data, children } = $props();
	let { supabase, claims } = $derived(data);
	onMount(() => {
		const { data } = supabase.auth.onAuthStateChange((event, _session) => {
			if (_session?.expires_at !== claims?.exp) {
				invalidate('supabase:auth');
			}
		});
		return () => data.subscription.unsubscribe();
	});
</script>

<svelte:head>
	<link rel="icon" href="/icons/favicon-48.png" type="image/png" sizes="48x48" />
	<link rel="apple-touch-icon" href="/icons/apple-touch-icon.png" sizes="180x180" />
	<link rel="manifest" href="/manifest.webmanifest" />
	<meta name="theme-color" content="#4c0297" />
	<meta name="application-name" content="Panneaux Libres" />
	<meta name="apple-mobile-web-app-title" content="Panneaux" />
</svelte:head>

<div class="flex h-dvh flex-col">
	<header
		class="relative z-[1000] flex h-[10dvh] max-h-24 min-h-14 shrink-0 items-center justify-between gap-3 bg-[#4c0297] px-3 text-white shadow-md"
	>
		<div class="flex items-center">
			<img
				src="/icons/icon-192.png"
				alt=""
				width="36"
				height="36"
				class="h-9 w-9 shrink-0 rounded-lg"
			/>
			<Menu>
				<Menu.Trigger class="btn">
					<MenuIcon />
				</Menu.Trigger>

				<Menu.Positioner>
					<Menu.Content>
						<Menu.Item value="new">
							<Menu.ItemText>New File</Menu.ItemText>
						</Menu.Item>
						<Menu.Item value="open">
							<Menu.ItemText>Open File</Menu.ItemText>
						</Menu.Item>
					</Menu.Content>
				</Menu.Positioner>
			</Menu>

			<h2 class="truncate text-base font-semibold sm:text-sm">Panneaux Libres</h2>
		</div>

		<Install />
	</header>

	<main class="min-h-0 flex-1 overflow-y-auto">
		{@render children()}
	</main>
</div>
