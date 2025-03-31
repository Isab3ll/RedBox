variable "agent_type" {
  description = "Type of agent (ragdoll/sandcat/manx)"
  type        = string
}

variable "agent_param" {
  description = "Agent-specific parameter"
  type        = string
}

variable "server_ip" {
  description = "Server IP address"
  type        = string
}

variable "server_port" {
  description = "Server port number"
  type        = number
}