<script>
	import { onMount } from "svelte";
	import { env } from "$env/dynamic/public";

	const backend_infra_ip = env.PUBLIC_BACKEND_INFRA_IP === "" ? "localhost" : env.PUBLIC_BACKEND_INFRA_IP;
	const backend_infra_port = env.PUBLIC_BACKEND_INFRA_PORT === "" ? "8000" : env.PUBLIC_BACKEND_INFRA_PORT;

	const backend_attack_ip = env.PUBLIC_BACKEND_ATTACK_IP === "" ? "localhost" : env.PUBLIC_BACKEND_ATTACK_IP;
	const backend_attack_port = env.PUBLIC_BACKEND_ATTACK_PORT === "" ? "8100" : env.PUBLIC_BACKEND_ATTACK_PORT;

	let nginx_count = 0;
	let tomcat_count = 0;
	let mysql_count = 0;
	let postgres_count = 0;
	let redis_count = 0;
	let wordpress_count = 0;
	let rabbitmq_count = 0;
	let httpd_count = 0;

	let deploymentStatus = "";
	let cleanupStatus = "";
	let status = "";

	let containers = [];

	let isDeploying = false;
	let isCleaning = false;
	let isLoading = false;

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

	async function buildEnvironment() {
		deploymentStatus = "Deploying...";
		isDeploying = true;

		const response = await fetch(
			`http://${backend_infra_ip}:${backend_infra_port}/apply`,
			{
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
					httpd_count,
				}),
			},
		);
		const result = await response.json();

		deploymentStatus = result.status === "success" ? "Deployment successful!" : "Deployment failed. Perform cleanup and try again.";
		isDeploying = false;

		resetCounts();
		fetchStatus();
	}

	async function destroyEnvironment() {
		cleanupStatus = "Cleaning up...";
		isCleaning = true;

		const response_attack = await fetch(
			`http://${backend_attack_ip}:${backend_attack_port}/destroy`,
			{
				method: "POST",
			},
		);
		const result_attack = await response_attack.json();

		const response_infra = await fetch(
			`http://${backend_infra_ip}:${backend_infra_port}/destroy`,
			{
				method: "POST",
			},
		);
		const result_infra = await response_infra.json();

		cleanupStatus = result_attack.status === "success" && result_infra.status === "success"
			? "Cleanup successful!"
			: `Cleanup failed, please try again.`;
		isCleaning = false;

		fetchStatus();
	}

	async function fetchStatus() {
		isLoading = true;
		status = "Loading...";

		const response = await fetch(
			`http://${backend_infra_ip}:${backend_infra_port}/status`,
			{
				method: "POST",
			},
		);
		const result = await response.json();

		if (result.status === "success") {
			if (result.output.trim()) {
				containers = result.output
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
				status = "";
			} else {
				status = "No containers are running.";
				containers = [];
			}
		} else {
			status = `Error fetching status. Please try again.`;
			containers = [];
		}

		isLoading = false;
	}

	onMount(() => {
		fetchStatus();
		const interval = setInterval(() => {
			if (!isCleaning && !isDeploying) {
				fetchStatus();
			}
		}, 10000);
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

<br />
<button class="action-button" on:click={() => buildEnvironment()}>Start Environment</button>

<h2>Infrastructure Status</h2>

{#if isLoading && containers.length === 0}
	<p>{status}</p>
{:else if containers.length === 0}
	<p>{status}</p>
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

<h2>Cleanup Environment</h2>
<p>Click the button below to remove all infrastructure.</p>

<button class="action-button" on:click={destroyEnvironment} disabled={isCleaning}>Destroy Environment</button>
<p>{cleanupStatus}</p>
<br />
