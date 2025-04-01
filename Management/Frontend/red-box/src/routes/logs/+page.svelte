<script>
	import { env } from "$env/dynamic/public";

	const grafana_ip = env.PUBLIC_GRAFANA_IP === "" ? "localhost" : env.PUBLIC_GRAFANA_IP;
	const grafana_port = env.PUBLIC_GRAFANA_PORT === "" ? "3000" : env.PUBLIC_GRAFANA_PORT;
	const logs_dashboard_url =
		`http://${grafana_ip}:${grafana_port}/d/feh4mpln2k7b4f/logs?orgId=1&from=now-1h&to=now&timezone=browser`;
</script>

<h2>Grafana Logs Dashboard</h2>
<div class="iframe-container">
	<iframe src={logs_dashboard_url} title="Grafana Logs Dashboard"></iframe>
</div>
