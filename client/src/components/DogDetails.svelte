<script lang="ts">
    import { onMount } from "svelte";
    
    interface Dog {
        id: number;
        name: string;
        breed: string;
        age: number;
        description: string;
        gender: string;
        status: 'AVAILABLE' | 'PENDING' | 'ADOPTED';
    };

    // Accept either a dog object or a dogId
    export let dog: Dog | undefined = undefined;
    export let dogId = 0;
    
    let loading = true;
    let error: string | null = null;
    let dogData: Dog | null = null;
    
    onMount(async () => {
        // If dog object is provided directly, use it
        if (dog) {
            dogData = dog;
            loading = false;
            return;
        }
        
        // Otherwise fetch data using dogId
        if (dogId) {
            try {
                const response = await fetch(`/api/dogs/${dogId}`);
                if (response.ok) {
                    dogData = await response.json();
                } else {
                    error = `Failed to fetch dog: ${response.status} ${response.statusText}`;
                }
            } catch (err) {
                error = `Error: ${err instanceof Error ? err.message : String(err)}`;
            } finally {
                loading = false;
            }
        } else {
            error = "No dog ID provided";
            loading = false;
        }
    });
</script>

{#if loading}
    <div class="animate-pulse bg-slate-800/60 backdrop-blur-sm rounded-xl overflow-hidden p-6">
        <div class="h-8 bg-slate-700 rounded w-1/2 mb-6"></div>
        <div class="h-4 bg-slate-700 rounded w-3/4 mb-3"></div>
        <div class="h-4 bg-slate-700 rounded w-1/2 mb-3"></div>
        <div class="h-4 bg-slate-700 rounded w-full mb-3"></div>
    </div>
{:else if error}
    <div class="bg-red-500/20 border border-red-500/50 text-red-400 rounded-xl p-6">
        {error}
    </div>
{:else if dogData}
    <div class="bg-slate-800/70 backdrop-blur-sm border border-slate-700 rounded-xl overflow-hidden">
        <div class="p-6">
            <div class="flex justify-between items-start">
                <h1 class="text-3xl font-bold text-slate-100 mb-2">{dogData.name}</h1>
                {#if dogData.status === 'AVAILABLE'}
                    <span class="bg-green-500/20 text-green-400 text-sm px-3 py-1 rounded-full">Available</span>
                {:else if dogData.status === 'PENDING'}
                    <span class="bg-amber-500/20 text-amber-400 text-sm px-3 py-1 rounded-full">Pending Adoption</span>
                {:else}
                    <span class="bg-red-500/20 text-red-400 text-sm px-3 py-1 rounded-full">Adopted</span>
                {/if}
            </div>
            
            <div class="grid grid-cols-2 gap-4 mb-6 mt-4">
                <div class="flex items-center">
                    <p class="text-slate-300">Breed: {dogData.breed}</p>
                </div>
                <div class="flex items-center">
                    <p class="text-slate-300">Age: {dogData.age} {dogData.age === 1 ? 'year' : 'years'}</p>
                </div>
                <div class="flex items-center">
                    <p class="text-slate-300">Gender: {dogData.gender}</p>
                </div>
            </div>
            
            <h2 class="text-lg font-semibold text-slate-200 mb-2">About {dogData.name}</h2>
            <p class="text-slate-400">{dogData.description}</p>
        </div>
    </div>
{:else}
    <div class="bg-slate-800/60 backdrop-blur-sm rounded-xl p-6">
        <p class="text-slate-400">No dog information available</p>
    </div>
{/if}