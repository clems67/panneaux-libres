<script lang="ts">
	import { page } from '$app/state';

	const getParam = (key: string) => page.url.searchParams.get(key);

	let id = $derived(getParam('id'));
	let status = $derived(getParam('status') === 'true');

	let question = $state('Voulez-vous rendre le point vert ?');
	let color = $state('bg-green-500 hover:bg-green-700');
	if (status) {
		question = 'Voulez-vous rendre le point rouge ?';
		color = 'bg-red-500 hover:bg-red-700';
	}

	async function change_status() {
		const new_status = !status;
		console.log(new_status);

		const response = await fetch('/api/panneaux_status', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({ id: id, new_status: new_status })
		});

		if (!response.ok) {
			throw new Error('Update failed');
		} else {
			window.location.href = '/';
		}
	}
</script>

<div class="flex flex-col items-center">
	<div class="m-6">{question}</div>
	<div class="flex gap-4">
		<button onclick={change_status} class="rounded px-4 py-2 font-bold text-white {color}">
			OUI
		</button>
		<a href="/">
			<button class="rounded bg-gray-500 px-4 py-2 font-bold text-white hover:bg-gray-700">
				ANNULER
			</button>
		</a>
	</div>
</div>
