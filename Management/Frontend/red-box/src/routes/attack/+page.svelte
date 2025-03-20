<script>
  import { env } from "$env/dynamic/public";

  const attack_ip = env.PUBLIC_ATTACK_IP === "" ? "localhost" : env.PUBLIC_ATTACK_IP;
  const attack_port = env.PUBLIC_ATTACK_PORT === "" ? "8888" : env.PUBLIC_ATTACK_PORT;
  const caldera_url = `http://${attack_ip}:${attack_port}`;
</script>

<h2>Caldera Attack Framework</h2>
<br>
<a href={caldera_url} target="_blank" class="action-button">Open Caldera</a>
