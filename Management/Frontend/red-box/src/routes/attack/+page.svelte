<script>
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

	let status = "";

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
		status = "Deploying...";

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
				}),
			},
		);
		const result = await response.json();

		status = result.status === "success" ? "Deployment successful!" : "Deployment failed. Rebuild infrastructure and try again.";
	}

	async function destroyAgent() {
		status = "Destroying...";

		const response = await fetch(
			`http://${backend_attack_ip}:${backend_attack_port}/destroy`,
			{
				method: "POST",
			},
		);
		const result = await response.json();

		status = result.status === "success" ? "Agent destroyed!" : "Destroy failed, please try again.";
	}
</script>

<h2>Deploy Attack Agent</h2>

<div class="config-box">
	<label for="agent-type">Agent Type</label>
	<select id="agent-type" bind:value={agent_type}>
		<option value="sandcat">Sandcat</option>
		<option value="ragdoll">Ragdoll</option>
		<option value="manx">Manx</option>
	</select>

	<label for="agent-param">Agent Parameter ({agentDescriptions[agent_type].param})</label>
	<input id="agent-param"	type="text"	placeholder={agentDescriptions[agent_type].placeholder}	bind:value={agent_param}/>

	<button class="action-button" on:click={deployAgent}>Deploy Agent</button>
	<button class="action-button" on:click={destroyAgent}>Destroy Agent</button>

	<p>{status}</p>
</div>

<h2>Caldera Framework</h2>
<a href={caldera_url} target="_blank" class="action-button">Open Caldera</a>
<br />
