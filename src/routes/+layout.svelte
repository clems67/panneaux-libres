<script lang="ts">
	import './layout.css';
	import Install from '#lib/components/Install.svelte';
	import type { LayoutProps } from './$types';

	let { children }: LayoutProps = $props();
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
		class="relative z-[1000] flex h-[10dvh] max-h-24 min-h-14 shrink-0 items-center justify-between gap-3 bg-[#4c0297] px-4 text-white shadow-md"
	>
		<div class="flex min-w-0 items-center gap-3">
			<img
				src="/icons/icon-192.png"
				alt=""
				width="36"
				height="36"
				class="h-9 w-9 shrink-0 rounded-lg"
			/>
			<h1 class="truncate text-base font-semibold sm:text-lg">Panneaux Libres</h1>
		</div>

		<Install />
	</header>

	<main class="min-h-0 flex-1">
		{@render children()}
	</main>
</div>
