<script>
	import { env } from "$env/dynamic/public";

	const grafana_ip = env.PUBLIC_GRAFANA_IP === "" ? "localhost" : env.PUBLIC_GRAFANA_IP;
	const grafana_port = env.PUBLIC_GRAFANA_PORT === "" ? "3000" : env.PUBLIC_GRAFANA_PORT;
	const metrics_dashboard_url =
		`http://${grafana_ip}:${grafana_port}/d/pMEd7m0Mz/metrics?orgId=1&from=now-1h&to=now&timezone=browser&var-host=$__all&var-container=$__all`;
</script>

<h2>Grafana Metrics Dashboard</h2>
<div class="iframe-container">
	<iframe src={metrics_dashboard_url} title="Grafana Metrics Dashboard"></iframe>
</div>
