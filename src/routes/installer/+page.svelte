<script lang="ts">
	import { Tabs } from '@skeletonlabs/skeleton-svelte';
</script>

<a href="/">
	<button class="m-5 rounded bg-blue-500 px-4 py-2 font-bold text-white hover:bg-gray-700">
		RETOUR
	</button>
</a>

<Tabs defaultValue="overview">
	<Tabs.List>
		<Tabs.Trigger value="android">Android</Tabs.Trigger>
		<Tabs.Trigger value="iphone">Iphone</Tabs.Trigger>
	</Tabs.List>
	<Tabs.Content value="android">
		<div class="flex flex-col items-start gap-2 p-4 pb-8">
			<b>Étape 1 :</b>
			<p>Coller l'url du site internet dans le navigateur Google Chrome</p>
			<b>Étape 2 :</b>
			<img
				class="block h-auto w-40 max-w-full rounded-lg"
				src="/images/install_step_android_2.jpeg"
				alt="Installation step 2"
			/>
			<b>Étape 3 :</b>
			<img
				class="block h-auto w-40 max-w-full rounded-lg"
				src="/images/install_step_android_3.jpeg"
				alt="Installation step 3"
			/>
			<b>Étape 4 :</b>
			<img
				class="block h-auto w-40 max-w-full rounded-lg"
				src="/images/install_step_android_4.jpeg"
				alt="Installation step 4"
			/>
		</div>
	</Tabs.Content>
	<Tabs.Content value="iphone">
		<div class="flex flex-col items-start gap-2 p-4 pb-8">
			<b>Étape 1 :</b>
			<p>Coller l'url du site internet dans le navigateur Google Chrome</p>
			<b>Étape 2 :</b>
			<img
				class="block h-auto w-40 max-w-full rounded-lg"
				src="/images/install_step_iphone_2.jpg"
				alt="Installation step 2"
			/>
			<b>Étape 3 :</b>
			<img
				class="block h-auto w-40 max-w-full rounded-lg"
				src="/images/install_step_iphone_3.jpg"
				alt="Installation step 3"
			/>
		</div>
	</Tabs.Content>
</Tabs>
