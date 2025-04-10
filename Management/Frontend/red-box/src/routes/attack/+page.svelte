<script>
	import { onMount } from "svelte";
	import { env } from "$env/dynamic/public";

	const caldera_ip = env.PUBLIC_CALDERA_IP || "localhost";
	const caldera_port = env.PUBLIC_CALDERA_PORT || "8888";
	const caldera_url = `http://${caldera_ip}:${caldera_port}`;

	const backend_attack_ip = env.PUBLIC_BACKEND_ATTACK_IP || "localhost";
	const backend_attack_port = env.PUBLIC_BACKEND_ATTACK_PORT || "8100";

	let agent_type = "sandcat";
	let agent_param = "splunkd";
	let server_ip = caldera_ip;
	let server_port = caldera_port;
	let network_internal = false;
	let network_external = true;

	let deploymentStatus = "";
	let status = "";

	let agents = [];

	let isDeploying = false;
	let isCleaning = false;
	let isLoading = false;

	const agentDescriptions = {
		sandcat: {
			param: "agents.implant_name",
			placeholder: "e.g. splunkd, sysmon, defender",
			key: "sandcat_implant_name",
		},
		ragdoll: {
			param: "app.contact.html",
			placeholder: "e.g. weather, network, system",
			key: "ragdoll_contact_html",
		},
		manx: {
			param: "agents.implant_name",
			placeholder: "e.g. splunkd, sysmon, defender",
			key: "manx_implant_name",
		},
	};

	async function deployAgent() {
		deploymentStatus = "Deploying...";
		isDeploying = true;

		const response = await fetch(
			`http://${backend_attack_ip}:${backend_attack_port}/apply`,
			{
				method: "POST",
				headers: { "Content-Type": "application/json" },
				body: JSON.stringify({
					agent_type,
					agent_param,
					server_ip,
					server_port,
					network_internal,
					network_external,
				}),
			},
		);
		const result = await response.json();

		deploymentStatus = result.status === "success" ? "Deployment successful!" : "Deployment failed. Rebuild infrastructure and try again.";
		isDeploying = false;

		fetchAgentStatus();
	}

	async function destroyAgent() {
		deploymentStatus = "Destroying...";
		isCleaning = true;

		const response = await fetch(
			`http://${backend_attack_ip}:${backend_attack_port}/destroy`,
			{
				method: "POST",
			},
		);
		const result = await response.json();

		deploymentStatus = result.status === "success" ? "Agent destroyed!" : "Destroy failed, please try again.";
		isCleaning = false;

		fetchAgentStatus();
	}

	async function fetchAgentStatus() {
		status = "Loading ...";
		isLoading = true;

		const response = await fetch(
			`http://${backend_attack_ip}:${backend_attack_port}/status`,
			{
				method: "POST",
			},
		);
		const result = await response.json();

		if (result.status === "success") {
			if (result.agents?.length > 0) {
				agents = result.agents;
				status = "";
			} else {
				status = "No agents are running.";
				agents = [];
			}
		} else {
			status = `Error fetching status. Please try again.`;
			agents = [];
		}

		isLoading = false;
	}

	onMount(() => {
		fetchAgentStatus();
		const interval = setInterval(() => {
			if (!isCleaning && !isDeploying) {
				fetchAgentStatus();
			}
		}, 5000);
		return () => clearInterval(interval);
	});
</script>

<h2>Deploy Attack Agent</h2>

<div class="config-box">
	<label for="agent-type">Agent Type</label>
	<select id="agent-type" bind:value={agent_type}>
		<option value="sandcat">Sandcat</option>
		<option value="ragdoll">Ragdoll</option>
		<option value="manx">Manx</option>
	</select>

	{#if agent_type !== 'ragdoll'}
		<label for="agent-param">Agent Parameter ({agentDescriptions[agent_type].param})</label>
		<input 
			id="agent-param" 
			type="text" 
			placeholder={agentDescriptions[agent_type].placeholder} 
			bind:value={agent_param}
		/>
	{/if}

	<div class="checkbox-container">
		<label for="network-internal" class="checkbox-label">Network Internal</label>
		<input id="network-internal" type="checkbox" bind:checked={network_internal} />
	</div>
	<div class="checkbox-container">
		<label for="network-external" class="checkbox-label">Network External</label>
		<input id="network-external" type="checkbox" bind:checked={network_external} />
	</div>

	<button class="action-button" on:click={deployAgent}>Deploy Agent</button>
	<button class="action-button" on:click={destroyAgent}>Destroy Agent</button>

	<p>{deploymentStatus}</p>
</div>

<h2>Agent Status</h2>
{#if isLoading && agents.length === 0}
	<p>{status}</p>
{:else if agents.length === 0}
	<p>{status}</p>
{:else}
	<div class="container-status">
		<table>
			<thead>
				<tr>
					<th>Agent</th>
					<th>IP Address</th>
				</tr>
			</thead>
			<tbody>
				{#each agents as { name, ip }}
					<tr>
						<td>{name}</td>
						<td>{ip}</td>
					</tr>
				{/each}
			</tbody>
		</table>
	</div>
{/if}

<button class="action-button" on:click={fetchAgentStatus}>Refresh Status</button>

<h2>Caldera Framework</h2>
<a href={caldera_url} target="_blank" class="action-button">Open Caldera</a>
<br />
