<script>
  import { onMount } from "svelte";
  import { env } from "$env/dynamic/public";

  const backend_url =
    env.PUBLIC_BACKEND_URL === "" ? "localhost" : env.PUBLIC_BACKEND_URL;

  let attackTechniques = ["T1003", "T1059", "T1566"];
  let selectedTechnique = "";
  let targetContainers = [];
  let selectedTarget = "";
  let attackResult = "";
  let isLoading = false;

  async function fetchContainers() {
    isLoading = true;
    targetContainers = [];

    try {
      const response = await fetch(`http://${backend_url}:8000/status`, {
        method: "POST",
      });
      const data = await response.json();

      if (data.status === "success" && data.output.trim()) {
        targetContainers = data.output
          .split("\n")
          .map((container) => {
            const match = container.match(/([a-zA-Z0-9_]+)\[([0-9]+)\]/);
            return match ? `${match[1]}-${match[2]}` : null;
          })
          .filter(Boolean);
      }
    } catch (error) {
      console.error("Error fetching containers:", error);
    }

    isLoading = false;
  }

  async function startAttack() {
    if (!selectedTechnique || !selectedTarget) {
      attackResult = "Select a technique and target first!";
      return;
    }

    attackResult = "Attack in progress...";

    try {
      const response = await fetch(`http://${backend_url}:8000/attack`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          technique: selectedTechnique,
          target_container: selectedTarget,
        }),
      });

      const data = await response.json();
      attackResult =
        data.status === "success"
          ? "Attack executed successfully!"
          : `Error: ${data.output}`;
    } catch (error) {
      attackResult = "Failed to start attack.";
      console.error(error);
    }
  }

  onMount(fetchContainers);
</script>

<h2>Attack Simulation</h2>

<div class="attack-container">
  <div class="attack-box">
    <p>Technique:</p>
    <select bind:value={selectedTechnique}>
      <option value="" disabled>Select technique</option>
      {#each attackTechniques as tech}
        <option value={tech}>{tech}</option>
      {/each}
    </select>
  </div>

  <div class="attack-box">
    <p>Target:</p>
    <select bind:value={selectedTarget}>
      <option value="" disabled>Select target</option>
      {#each targetContainers as container}
        <option value={container}>{container}</option>
      {/each}
    </select>
  </div>
</div>

<div class="attack-button-container">
  <button class="action-button" on:click={fetchContainers} disabled={isLoading}>
    {isLoading ? "Refreshing..." : "Refresh Targets"}
  </button>
  <button class="action-button" on:click={startAttack}>Launch Attack</button>
</div>

{#if attackResult}
  <p class="attack-result">{attackResult}</p>
{/if}
