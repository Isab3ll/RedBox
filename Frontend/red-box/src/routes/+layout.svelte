<script>
  import "../styles/global.css";
  import Sidebar from "../components/sidebar.svelte";
</script>

<div class="container">
  <Sidebar />
  <div class="content">
    <slot />
  </div>
</div>
