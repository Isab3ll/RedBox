<script>
  import { env } from "$env/dynamic/public";

  const caldera_ip = env.PUBLIC_CALDERA_IP === "" ? "localhost" : env.PUBLIC_CALDERA_IP;
  const caldera_port = env.PUBLIC_CALDERA_PORT === "" ? "8888" : env.PUBLIC_CALDERA_PORT;
  const caldera_url = `http://${caldera_ip}:${caldera_port}`;
</script>

<h2>Caldera Framework</h2>
<br>
<a href={caldera_url} target="_blank" class="action-button">Open Caldera</a>
