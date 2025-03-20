<script>
    import { env } from "$env/dynamic/public";
  
    const kibana_ip = env.PUBLIC_KIBANA_IP === "" ? "localhost" : env.PUBLIC_KIBANA_IP;
    const kibana_port = env.PUBLIC_KIBANA_PORT === "" ? "8888" : env.PUBLIC_KIBANA_PORT;
    const kibana_url = `http://${kibana_ip}:${kibana_port}`;
  </script>
  
  <h2>Kibana Dashboard</h2>
  <br>
  <a href={kibana_url} target="_blank" class="action-button">Open Kibana</a>
  