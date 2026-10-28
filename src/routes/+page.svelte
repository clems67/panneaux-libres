<script lang="ts">
	import { onMount } from 'svelte';
	import 'leaflet/dist/leaflet.css';
	import type { Map } from 'leaflet';

	const CENTER: [number, number] = [48.576, 7.75];
	const ZOOM = 13;

	let mapElement: HTMLDivElement;

	onMount(() => {
		let map: Map;
		let destroyed = false;

		void import('leaflet').then(async ({ default: L }) => {
			if (destroyed) return;

			map = L.map(mapElement).setView(CENTER, ZOOM);

			L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
				maxZoom: 19,
				attribution:
					'&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
			}).addTo(map);

			const response = await fetch('/api/panneaux', {
				method: 'GET',
				headers: {
					'Content-Type': 'application/json'
				}
			});

			if (!response.ok) {
				throw new Error(`HTTP error: ${response.status}`);
			}

			const { panneaux } = await response.json();

			const redIcon = L.icon({
				iconUrl:
					'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-red.png',
				shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
				iconSize: [25, 41],
				iconAnchor: [12, 41],
				popupAnchor: [1, -34],
				shadowSize: [41, 41]
			});

			const greenIcon = L.icon({
				iconUrl:
					'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-green.png',
				iconRetinaUrl:
					'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
				shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png',
				iconSize: [25, 41],
				iconAnchor: [12, 41],
				popupAnchor: [1, -34],
				shadowSize: [41, 41]
			});

			if (map != undefined) {
				panneaux.forEach((element) => {
					L.marker([element.latitude, element.longitude], {
						icon: element.status ? greenIcon : redIcon
					})
						.bindPopup(
							`<a href="https://www.google.com/maps?q=${element.latitude},${element.longitude}" target="_blank" rel="noopener noreferrer">Google Maps</a>
							<br>
							<br>
							<a href="/confirmer_panneau?id=${encodeURIComponent(element.id)}&status=${element.status}">Changer le statut</a>
							`
						)
						.addTo(map);
				});
			}
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
