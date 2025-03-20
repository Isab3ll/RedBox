<script>
  import { onMount } from "svelte";
  import { env } from "$env/dynamic/public";

  const backend_ip = env.PUBLIC_BACKEND_IP === "" ? "localhost" : env.PUBLIC_BACKEND_IP;
  const backend_port = env.PUBLIC_BACKEND_PORT === "" ? "8000" : env.PUBLIC_BACKEND_PORT;

  let nginx_count = 0;
  let tomcat_count = 0;
  let mysql_count = 0;
  let postgres_count = 0;

  let statusOutput = "";
  let containers = [];
  let isLoading = true;

  const resetCounts = () => {
    nginx_count = 0;
    tomcat_count = 0;
    mysql_count = 0;
    postgres_count = 0;
  };

  async function sendRequest(action) {
    const response = await fetch(`http://${backend_ip}:${backend_port}/${action}`, {
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
    isLoading = true;
    statusOutput = "Loading...";

    const response = await fetch(`http://${backend_ip}:${backend_port}/status`, {
      method: "POST",
    });
    const data = await response.json();

    if (data.status === "success") {
      if (data.output.trim()) {
        containers = data.output
          .split("\n")
          .map((container) => {
            const regex = /([a-zA-Z0-9_]+)\[([0-9]+)\]/;
            const match = container.match(regex);
            if (match) {
              return { name: match[1], index: match[2] };
            }
            return null;
          })
          .filter((item) => item !== null);
        statusOutput = "";
      } else {
        statusOutput = "No containers are running";
        containers = [];
      }
    } else {
      statusOutput = `Error fetching status: ${data.output}`;
      containers = [];
    }

    isLoading = false;
  }

  onMount(() => {
    fetchStatus();
    const interval = setInterval(fetchStatus, 10000);
    return () => clearInterval(interval);
  });
</script>

<h2>Configure Infrastructure</h2>

<div class="counter-container">
  <div class="counter-box">
    <p>Nginx containers</p>
    <div class="counter">
      <button
        class="minus"
        on:click={() => (nginx_count = Math.max(0, nginx_count - 1))}>-</button
      >
      <span>{nginx_count}</span>
      <button class="plus" on:click={() => nginx_count++}>+</button>
    </div>
  </div>

  <div class="counter-box">
    <p>Tomcat containers</p>
    <div class="counter">
      <button
        class="minus"
        on:click={() => (tomcat_count = Math.max(0, tomcat_count - 1))}
        >-</button
      >
      <span>{tomcat_count}</span>
      <button class="plus" on:click={() => tomcat_count++}>+</button>
    </div>
  </div>

  <div class="counter-box">
    <p>MySQL containers</p>
    <div class="counter">
      <button
        class="minus"
        on:click={() => (mysql_count = Math.max(0, mysql_count - 1))}>-</button
      >
      <span>{mysql_count}</span>
      <button class="plus" on:click={() => mysql_count++}>+</button>
    </div>
  </div>

  <div class="counter-box">
    <p>Postgres containers</p>
    <div class="counter">
      <button
        class="minus"
        on:click={() => (postgres_count = Math.max(0, postgres_count - 1))}
        >-</button
      >
      <span>{postgres_count}</span>
      <button class="plus" on:click={() => postgres_count++}>+</button>
    </div>
  </div>
</div>

<button class="action-button" on:click={() => sendRequest("apply")}
  >Start Environment</button
>

<h2>Infrastructure Status</h2>

{#if isLoading && containers.length === 0}
  <p>{statusOutput}</p>
{:else if containers.length === 0}
  <p>{statusOutput}</p>
{:else}
  <div class="container-status">
    <table>
      <thead>
        <tr>
          <th>Container</th>
          <th>Instance ID</th>
        </tr>
      </thead>
      <tbody>
        {#each containers as { name, index }}
          <tr>
            <td>{name}</td>
            <td>{index}</td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
{/if}

<button class="action-button" on:click={fetchStatus}>Refresh Status</button>
