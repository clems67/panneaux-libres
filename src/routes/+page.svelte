<script lang="ts">
	import { onMount } from 'svelte';
	import 'leaflet/dist/leaflet.css';
	import type { Map } from 'leaflet';

	const CENTER: [number, number] = [48.576, 7.75];
	const ZOOM = 13;

	let mapElement: HTMLDivElement;

	onMount(() => {
		let map: Map | undefined;
		let destroyed = false;

		void import('leaflet').then(({ default: L }) => {
			if (destroyed) return;

			map = L.map(mapElement).setView(CENTER, ZOOM);

			L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
				maxZoom: 19,
				attribution:
					'&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
			}).addTo(map);
		});

		return () => {
			destroyed = true;
			map?.remove();
		};
	});
</script>

<div id="map" bind:this={mapElement}></div>

<style>
	#map {
		height: 100%;
		width: 100%;
	}
</style>
