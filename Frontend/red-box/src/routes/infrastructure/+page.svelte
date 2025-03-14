<script>
    import { onMount } from "svelte";
  
    let nginx_count = 0;
    let tomcat_count = 0;
    let mysql_count = 0;
    let postgres_count = 0; 

    let statusOutput = "Loading...";
  
    const resetCounts = () => {
      nginx_count = 0;
      tomcat_count = 0;
      mysql_count = 0;
      postgres_count = 0;
    };
  
    async function sendRequest(action) {
      const response = await fetch(`http://localhost:8000/${action}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          nginx_count,
          tomcat_count,
          mysql_count,
          postgres_count,
        }),
      });
      resetCounts();
      fetchStatus();
    }
  
    async function fetchStatus() {
      const response = await fetch("http://localhost:8000/status", { method: "POST" });
      const data = await response.json();
      statusOutput = data.status === "success" ? data.output : "Error fetching status!";
    }
  
    onMount(() => {
      fetchStatus();
      const interval = setInterval(fetchStatus, 10000);
      return () => clearInterval(interval);
    });
  </script>
  
  <h2>Configure Infrastructure</h2>
  
  <label for="nginx_count">Nginx instances:</label>
  <input type="number" id="nginx_count" bind:value={nginx_count} min="0" />
  
  <label for="tomcat_count">Tomcat instances:</label>
  <input type="number" id="tomcat_count" bind:value={tomcat_count} min="0" />
  
  <label for="mysql_count">MySQL instances:</label>
  <input type="number" id="mysql_count" bind:value={mysql_count} min="0" />
  
  <label for="postgres_count">Postgres instances:</label>
  <input type="number" id="postgres_count" bind:value={postgres_count} min="0" />
  
  <button on:click={() => sendRequest("apply")}>Start Environment</button>
  
  <h2>Infrastructure Status</h2>
  <p>{statusOutput}</p>
  <button on:click={fetchStatus}>Refresh Status</button>
  