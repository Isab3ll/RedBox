output "ragdoll_agent_ips" {
  description = "IP addresses of Ragdoll agents"
  value = var.agent_type == "ragdoll" ? [
    for c in docker_container.ragdoll : {
      name = c.name
      ip_0  = c.network_data[0].ip_address
      ip_1  = length(c.network_data) > 1 ? c.network_data[1].ip_address : null
    }
  ] : []
}

output "sandcat_agent_ips" {
  description = "IP addresses of Sandcat agents"
  value = var.agent_type == "sandcat" ? [
    for c in docker_container.sandcat : {
      name = c.name
      ip_0  = c.network_data[0].ip_address
      ip_1  = length(c.network_data) > 1 ? c.network_data[1].ip_address : null
    }
  ] : []
}

output "manx_agent_ips" {
  description = "IP addresses of Manx agents"
  value = var.agent_type == "manx" ? [
    for c in docker_container.manx : {
      name = c.name
      ip_0  = c.network_data[0].ip_address
      ip_1  = length(c.network_data) > 1 ? c.network_data[1].ip_address : null
    }
  ] : []
}
