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

  let deploymentStatus = "";

  const agentDescriptions = {
    ragdoll: { param: "app.contact.html", placeholder: "eg. weather, network, system", key: "ragdoll_contact_html" },
    sandcat: { param: "agents.implant_name", placeholder: "eg. splunkd, sysmon, defender", key: "sandcat_implant_name" },
    manx: { param: "agents.implant_name", placeholder: "eg. splunkd, sysmon, defender", key: "manx_implant_name" }
  };

  async function deployAgent() {
    deploymentStatus = "Deploying...";

    const response = await fetch(`http://${backend_attack_ip}:${backend_attack_port}/apply`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        agent_type,
        agent_param,
        server_ip,
        server_port
      }),
    });

    const result = await response.json();
    deploymentStatus = result.status === "success" ? "Deployment successful!" : "Deployment failed!";
  }

  async function destroyAgent() {
    deploymentStatus = "Destroying...";

    const response = await fetch(`http://${backend_attack_ip}:${backend_attack_port}/destroy`, { method: "POST" });

    const result = await response.json();
    deploymentStatus = result.status === "success" ? "Agent destroyed!" : "Destroy failed!";
  }
</script>

<h2>Deploy Agent</h2>

<label for="agent-type">Agent Type:</label>
<select id="agent-type" bind:value={agent_type}>
  <option value="ragdoll">Ragdoll</option>
  <option value="sandcat">Sandcat</option>
  <option value="manx">Manx</option>
</select>

<label for="agent-input">Agent Parameter ({agentDescriptions[agent_type].param}):</label>
<input id="agent-input" type="text" bind:value={agent_param} placeholder={agentDescriptions[agent_type].placeholder} />

<button on:click={deployAgent}>Deploy Agent</button>
<button on:click={destroyAgent}>Destroy Agent</button>

<p>{deploymentStatus}</p>
<br/>

<h2>Caldera Framework</h2>
<br>
<a href={caldera_url} target="_blank" class="action-button">Open Caldera</a>
