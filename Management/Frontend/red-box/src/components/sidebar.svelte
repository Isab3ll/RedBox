<script>
  import { page } from "$app/stores";
  let currentPath = "";

  $: {
    page.subscribe((p) => {
      currentPath = p.url.pathname;
    });
  }
</script>

<div class="sidebar">
  <img src="/logo.png" alt="Logo" />
  <a
    href="/infrastructure"
    class={currentPath === "/infrastructure" ? "active" : ""}>Infrastructure</a
  >
  <a href="/attack" class={currentPath === "/attack" ? "active" : ""}>Attack</a>
  <a href="/data" class={currentPath === "/data" ? "active" : ""}>Data</a>
  <a href="/cleanup" class={currentPath === "/cleanup" ? "active" : ""}
    >Cleanup</a
  >
</div>
