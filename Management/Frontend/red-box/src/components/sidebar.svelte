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
		class={currentPath === "/infrastructure" ? "active" : ""}
	>Infrastructure</a>
	<a href="/attack" class={currentPath === "/attack" ? "active" : ""}>Attack</a>
	<a href="/logs" class={currentPath === "/logs" ? "active" : ""}>Logs</a>
	<a href="/metrics" class={currentPath === "/metrics" ? "active" : ""}>Metrics</a>
</div>
