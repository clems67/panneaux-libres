<script lang="ts">
	import { onMount } from 'svelte';
	import 'leaflet/dist/leaflet.css';
	import type { Map } from 'leaflet';

	const CENTER: [number, number] = [48.576, 7.75];
	const ZOOM = 13;
	const STORAGE_KEY = 'panneaux-libres:map-view';

	type MapView = { center: [number, number]; zoom: number };

	function loadMapView(): MapView {
		try {
			const raw = localStorage.getItem(STORAGE_KEY);
			if (raw) {
				const parsed = JSON.parse(raw) as Partial<MapView> | null;
				const center = parsed?.center;
				const zoom = parsed?.zoom;

				if (
					Array.isArray(center) &&
					center.length === 2 &&
					center.every((value) => typeof value === 'number' && Number.isFinite(value)) &&
					typeof zoom === 'number' &&
					Number.isFinite(zoom)
				) {
					return { center: [center[0], center[1]], zoom };
				}
			}
		} catch {
			// Ignore invalid or inaccessible storage and fall back to the defaults.
		}

		return { center: CENTER, zoom: ZOOM };
	}

	let mapElement: HTMLDivElement;

	onMount(() => {
		let map: Map;
		let destroyed = false;

		void import('leaflet').then(async ({ default: L }) => {
			if (destroyed) return;

			const initialView = loadMapView();

			map = L.map(mapElement).setView(initialView.center, initialView.zoom);

			map.on('moveend', () => {
				const center = map.getCenter();
				const view: MapView = {
					center: [center.lat, center.lng],
					zoom: map.getZoom()
				};

				try {
					localStorage.setItem(STORAGE_KEY, JSON.stringify(view));
				} catch {
					// Ignore storage failures (private mode, quota, etc.).
				}
			});

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
				panneaux.forEach((element: { latitude: number; longitude: number; status: boolean; id: string | number | boolean; }) => {
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
