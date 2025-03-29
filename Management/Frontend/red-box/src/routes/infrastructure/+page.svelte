<script>
  import { onMount } from "svelte";
  import { env } from "$env/dynamic/public";

  const backend_ip = env.PUBLIC_BACKEND_IP === "" ? "localhost" : env.PUBLIC_BACKEND_IP;
  const backend_port = env.PUBLIC_BACKEND_PORT === "" ? "8000" : env.PUBLIC_BACKEND_PORT;

  let nginx_count = 0;
  let tomcat_count = 0;
  let mysql_count = 0;
  let postgres_count = 0;
  let redis_count = 0;
  let wordpress_count = 0;
  let rabbitmq_count = 0;
  let httpd_count = 0;

  let statusOutput = "";
  let containers = [];
  let isLoading = true;

  const resetCounts = () => {
    nginx_count = 0;
    tomcat_count = 0;
    mysql_count = 0;
    postgres_count = 0;
    redis_count = 0;
    wordpress_count = 0;
    rabbitmq_count = 0;
    httpd_count = 0;
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
        redis_count,
        wordpress_count,
        rabbitmq_count,
        httpd_count
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
    <img src="/nginx.svg" alt="Nginx Logo" class="container-logo" />
    <p>Nginx containers</p>
    <div class="counter">
      <button class="minus" on:click={() => (nginx_count = Math.max(0, nginx_count - 1))}>-</button>
      <span>{nginx_count}</span>
      <button class="plus" on:click={() => nginx_count++}>+</button>
    </div>
  </div>

  <div class="counter-box">
    <img src="/tomcat.svg" alt="Tomcat Logo" class="container-logo" />
    <p>Tomcat containers</p>
    <div class="counter">
      <button class="minus" on:click={() => (tomcat_count = Math.max(0, tomcat_count - 1))}>-</button>
      <span>{tomcat_count}</span>
      <button class="plus" on:click={() => tomcat_count++}>+</button>
    </div>
  </div>

  <div class="counter-box">
    <img src="/mysql.svg" alt="MySQL Logo" class="container-logo" />
    <p>MySQL containers</p>
    <div class="counter">
      <button class="minus" on:click={() => (mysql_count = Math.max(0, mysql_count - 1))}>-</button>
      <span>{mysql_count}</span>
      <button class="plus" on:click={() => mysql_count++}>+</button>
    </div>
  </div>

  <div class="counter-box">
    <img src="/postgres.svg" alt="Postgres Logo" class="container-logo" />
    <p>Postgres containers</p>
    <div class="counter">
      <button class="minus" on:click={() => (postgres_count = Math.max(0, postgres_count - 1))}>-</button>
      <span>{postgres_count}</span>
      <button class="plus" on:click={() => postgres_count++}>+</button>
    </div>
  </div>

  <div class="counter-box">
    <img src="/redis.svg" alt="Redis Logo" class="container-logo" />
    <p>Redis containers</p>
    <div class="counter">
      <button class="minus" on:click={() => (redis_count = Math.max(0, redis_count - 1))}>-</button>
      <span>{redis_count}</span>
      <button class="plus" on:click={() => redis_count++}>+</button>
    </div>
  </div>

  <div class="counter-box">
    <img src="/wordpress.svg" alt="WordPress Logo" class="container-logo" />
    <p>WordPress containers</p>
    <div class="counter">
      <button class="minus" on:click={() => (wordpress_count = Math.max(0, wordpress_count - 1))}>-</button>
      <span>{wordpress_count}</span>
      <button class="plus" on:click={() => wordpress_count++}>+</button>
    </div>
  </div>

  <div class="counter-box">
    <img src="/rabbitmq.svg" alt="RabbitMQ Logo" class="container-logo" />
    <p>RabbitMQ containers</p>
    <div class="counter">
      <button class="minus" on:click={() => (rabbitmq_count = Math.max(0, rabbitmq_count - 1))}>-</button>
      <span>{rabbitmq_count}</span>
      <button class="plus" on:click={() => rabbitmq_count++}>+</button>
    </div>
  </div>

  <div class="counter-box">
    <img src="/httpd.svg" alt="HTTPD Logo" class="container-logo" />
    <p>HTTPD containers</p>
    <div class="counter">
      <button class="minus" on:click={() => (httpd_count = Math.max(0, httpd_count - 1))}>-</button>
      <span>{httpd_count}</span>
      <button class="plus" on:click={() => httpd_count++}>+</button>
    </div>
  </div>
</div>

<button class="action-button" on:click={() => sendRequest("apply")}>Start Environment</button>

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
