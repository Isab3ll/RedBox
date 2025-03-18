<script>
  import { env } from "$env/dynamic/public";

  const backend_url = env.PUBLIC_BACKEND_URL === "" ? "localhost" : env.PUBLIC_BACKEND_URL;

  let cleanupStatus = "";
  let isCleaning = false;

  async function destroyEnvironment() {
    cleanupStatus = "Cleaning up...";
    isCleaning = true;

    const response = await fetch(`http://${backend_url}:8000/destroy`, {
      method: "POST",
    });

    setTimeout(async () => {
      await fetchStatus();
    }, 10000);
  }

  async function fetchStatus() {
    const response = await fetch(`http://${backend_url}:8000/status`, {
      method: "POST",
    });
    const data = await response.json();

    if (data.status === "success") {
      if (!data.output.trim()) {
        cleanupStatus = "Cleanup successful! No containers running";
      } else {
        cleanupStatus =
          "Containers still running, please perform cleanup again";
      }
    } else {
      cleanupStatus = `Error fetching status: ${data.output}`;
    }

    isCleaning = false;
  }
</script>

<h2>Cleanup Environment</h2>
<p>Click the button below to remove all infrastructure.</p>

<button
  class="action-button"
  on:click={destroyEnvironment}
  disabled={isCleaning}
>
  Destroy Environment
</button>

<p>{cleanupStatus}</p>
