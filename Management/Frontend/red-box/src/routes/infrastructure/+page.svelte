<script>
	import { onMount } from "svelte";
	import { env } from "$env/dynamic/public";

	const backend_infra_ip = env.PUBLIC_BACKEND_INFRA_IP === "" ? "localhost" : env.PUBLIC_BACKEND_INFRA_IP;
	const backend_infra_port = env.PUBLIC_BACKEND_INFRA_PORT === "" ? "8000" : env.PUBLIC_BACKEND_INFRA_PORT;

	const backend_attack_ip = env.PUBLIC_BACKEND_ATTACK_IP === "" ? "localhost" : env.PUBLIC_BACKEND_ATTACK_IP;
	const backend_attack_port = env.PUBLIC_BACKEND_ATTACK_PORT === "" ? "8100" : env.PUBLIC_BACKEND_ATTACK_PORT;

	const infrastructure_ip = env.PUBLIC_INFRASTRUCTURE_IP === "" ? "localhost" : env.PUBLIC_INFRASTRUCTURE_IP;

	let nginx_count = 0;
	let nginx_external_count = 0;
	let nginx_internal_external_count = 0;
	let tomcat_count = 0;
	let mysql_count = 0;
	let postgres_count = 0;
	let redis_count = 0;
	let wordpress_internal_external_count = 0;
	let rabbitmq_count = 0;
	let httpd_count = 0;

	let wordpress_internal_external_count_old = 0;

	let deploymentStatus = "";
	let cleanupStatus = "";
	let status = "";

	let containers = [];

	let isDeploying = false;
	let isCleaning = false;
	let isLoading = false;

	let nginx_default_config = 
`user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
	worker_connections  1024;
}


http {
	include       /etc/nginx/mime.types;
	default_type  application/octet-stream;

	log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
					'$status $body_bytes_sent "$http_referer" '
					'"$http_user_agent" "$http_x_forwarded_for"';

	access_log  /var/log/nginx/access.log  main;

	sendfile        on;
	#tcp_nopush     on;

	keepalive_timeout  65;

	#gzip  on;

	include /etc/nginx/conf.d/*.conf;
}`

	let nginx_external_config = nginx_default_config;
	let nginx_internal_external_config = nginx_default_config;

	const resetCounts = () => {
		nginx_count = 0;
		nginx_external_count = 0;
		nginx_internal_external_count = 0;
		tomcat_count = 0;
		mysql_count = 0;
		postgres_count = 0;
		redis_count = 0;
		wordpress_internal_external_count = 0;
		rabbitmq_count = 0;
		httpd_count = 0;
	};

	const resetExternalNginxConfig = () => {
		nginx_external_config = nginx_default_config;
	};

	const resetInternalExternalNginxConfig = () => {
		nginx_internal_external_config = nginx_default_config;
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
					nginx_external_count,
					nginx_external_config,
					nginx_internal_external_count,
					nginx_internal_external_config,
					tomcat_count,
					mysql_count,
					postgres_count,
					redis_count,
					wordpress_internal_external_count,
					rabbitmq_count,
					httpd_count,
				}),
			},
		);
		const result = await response.json();

		deploymentStatus = result.status === "success" ? "Deployment successful!" : "Deployment failed. Perform cleanup, check config files and try again.";
		isDeploying = false;
		
		wordpress_internal_external_count_old = wordpress_internal_external_count;
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
			if (result.containers?.length > 0) {
				containers = result.containers;
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

	async function handleFile(event, setter) {
		const file = event.target.files?.[0];
		if (!file) return;

		const text = await file.text();
		setter(text);
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

<h3>Internal Containers</h3>

<div class="counter-container">
	<div class="counter-box">
		<img src="/nginx.svg" alt="Nginx Logo" class="container-logo" />
		<p>Nginx</p>
		<div class="counter">
			<button class="minus" on:click={() => (nginx_count = Math.max(0, nginx_count-1))}>-</button>
			<span>{nginx_count}</span>
			<button class="plus" on:click={() => nginx_count++}>+</button>
		</div>
	</div>

	<div class="counter-box">
		<img src="/httpd.svg" alt="HTTPD Logo" class="container-logo" />
		<p>HTTPD</p>
		<div class="counter">
			<button class="minus" on:click={() => (httpd_count = Math.max(0, httpd_count-1))}>-</button>
			<span>{httpd_count}</span>
			<button class="plus" on:click={() => httpd_count++}>+</button>
		</div>
	</div>
	
	<div class="counter-box">
		<img src="/tomcat.svg" alt="Tomcat Logo" class="container-logo" />
		<p>Tomcat</p>
		<div class="counter">
			<button class="minus" on:click={() => (tomcat_count = Math.max(0, tomcat_count-1))}>-</button>
			<span>{tomcat_count}</span>
			<button class="plus" on:click={() => tomcat_count++}>+</button>
		</div>
	</div>

	<div class="counter-box">
		<img src="/mysql.svg" alt="MySQL Logo" class="container-logo" />
		<p>MySQL</p>
		<div class="counter">
			<button class="minus" on:click={() => (mysql_count = Math.max(0, mysql_count-1))}>-</button>
			<span>{mysql_count}</span>
			<button class="plus" on:click={() => mysql_count++}>+</button>
		</div>
	</div>

	<div class="counter-box">
		<img src="/postgres.svg" alt="Postgres Logo" class="container-logo" />
		<p>Postgres</p>
		<div class="counter">
			<button class="minus" on:click={() => (postgres_count = Math.max(0, postgres_count-1))}>-</button>
			<span>{postgres_count}</span>
			<button class="plus" on:click={() => postgres_count++}>+</button>
		</div>
	</div>

	<div class="counter-box">
		<img src="/redis.svg" alt="Redis Logo" class="container-logo" />
		<p>Redis</p>
		<div class="counter">
			<button class="minus" on:click={() => (redis_count = Math.max(0, redis_count-1))}>-</button>
			<span>{redis_count}</span>
			<button class="plus" on:click={() => redis_count++}>+</button>
		</div>
	</div>

	<div class="counter-box">
		<img src="/rabbitmq.svg" alt="RabbitMQ Logo" class="container-logo" />
		<p>RabbitMQ</p>
		<div class="counter">
			<button class="minus" on:click={() => (rabbitmq_count = Math.max(0, rabbitmq_count-1))}>-</button>
			<span>{rabbitmq_count}</span>
			<button class="plus" on:click={() => rabbitmq_count++}>+</button>
		</div>
	</div>
</div>

<h3>External Containers</h3>

<div class="counter-container">
	<div class="counter-box wide-box">
		<img src="/nginx.svg" alt="Nginx Logo" class="container-logo" />
		<p>External Nginx</p>
		<div class="counter">
			<button class="minus" on:click={() => (nginx_external_count = Math.max(0, nginx_external_count-1))}>-</button>
			<span>{nginx_external_count}</span>
			<button class="plus" on:click={() => nginx_external_count++}>+</button>
		</div>
		<div class="file-upload">
			<div class="upload-wrapper">
				<input type="file" accept=".conf" id="external-config" on:change={(e) => handleFile(e, val => nginx_external_config = val)}/>
				<label for="external-config" class="upload-button">Choose Config File</label>
			</div>
			<textarea class="config-textarea" bind:value={nginx_external_config} rows="10" readonly></textarea>
			<button class="action-button" on:click={resetExternalNginxConfig}>Reset Config</button>
		</div>
	</div>

	<div class="counter-box wide-box">
		<img src="/nginx.svg" alt="Nginx Logo" class="container-logo" />
		<p>Internal/External Nginx</p>
		<div class="counter">
			<button class="minus" on:click={() => (nginx_internal_external_count = Math.max(0, nginx_internal_external_count-1))}>-</button>
			<span>{nginx_internal_external_count}</span>
			<button class="plus" on:click={() => nginx_internal_external_count++}>+</button>
		</div>
		<div class="file-upload">
			<div class="upload-wrapper">
				<input type="file" accept=".conf" id="internal-external-config" on:change={(e) => handleFile(e, val => nginx_internal_external_config = val)}/>
				<label for="internal-external-config" class="upload-button">Choose Config File</label>
			</div>
			<textarea class="config-textarea" bind:value={nginx_internal_external_config} rows="10" readonly></textarea>
			<button class="action-button" on:click={resetInternalExternalNginxConfig}>Reset Config</button>
		</div>
	</div>

	<div class="counter-box wide-box">
		<img src="/wordpress.svg" alt="WordPress Logo" class="container-logo" />
		<p>Internal/External WordPress</p>
		<div class="counter">
			<button class="minus" on:click={() => (wordpress_internal_external_count = Math.max(0, wordpress_internal_external_count-1))}>-</button>
			<span>{wordpress_internal_external_count}</span>
			<button class="plus" on:click={() => wordpress_internal_external_count++}>+</button>
		</div>
		<p>WordPress requires MySQL database.</p>
		<p>Please ensure you have one MySQL container for each WordPress container running.</p>
		{#each Array(wordpress_internal_external_count_old) as _, index}
			<p><a href="http://{infrastructure_ip}:{8000 + index}" target="_blank">http://{infrastructure_ip}:{8000 + index}</a></p>
	  	{/each}
	</div>
</div>

<br />
<button class="action-button" on:click={() => buildEnvironment()}>Start Environment</button>
<p>{deploymentStatus}</p>

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
					<th>IP Address</th>
				</tr>
			</thead>
			<tbody>
				{#each containers as { name, id, ip }}
					<tr>
						<td>{name}</td>
						<td>{id}</td>
						<td>{ip}</td>
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
