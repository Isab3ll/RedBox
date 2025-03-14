<script>
  async function destroyEnvironment() {
    const response = await fetch(`http://localhost:8000/destroy`, {
      method: "POST",
    });
  }
</script>

<h2>Cleanup Environment</h2>
<p>Click the button below to remove all infrastructure.</p>

<button on:click={destroyEnvironment}>Destroy Environment</button>
