<script>
  import { env } from "$env/dynamic/public";
  
  const grafana_ip = env.PUBLIC_GRAFANA_IP === "" ? "localhost" : env.PUBLIC_GRAFANA_IP;
  const grafana_port = env.PUBLIC_GRAFANA_PORT === "" ? "3000" : env.PUBLIC_GRAFANA_PORT;
  const metrics_dashboard_url = `http://${grafana_ip}:${grafana_port}/public-dashboards/541eb4e64f5c4ed1aca1c2cd84b4a65e`;
</script>
  
<h2>Grafana Metrics Dashboard</h2>
<div class="iframe-container">
  <iframe src={metrics_dashboard_url} title="Grafana Metrics Dashboard"></iframe>
</div>