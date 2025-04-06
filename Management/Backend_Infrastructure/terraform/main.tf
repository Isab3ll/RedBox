resource "docker_network" "internal" {
  name = "internal"
  driver = "bridge"
}

resource "docker_network" "external" {
  name = "external"
  driver = "bridge"
}

resource "local_file" "nginx_external_config_file" {
  content = var.nginx_external_config
  filename = "${path.module}/nginx_external_config/nginx.conf"
}

resource "local_file" "nginx_internal_external_config_file" {
  content = var.nginx_internal_external_config
  filename = "${path.module}/nginx_internal_external_config/nginx.conf"
}

resource "null_resource" "create_nginx_external_config_dir" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /root/nginx_external_config"
    ]
    connection {
      host        = "192.168.0.29"
      user        = "root"
      private_key = file("~/.ssh/id_ed25519")
    }
  }
  triggers = {
    config_hash = sha256(var.nginx_external_config)
  }
}

resource "null_resource" "upload_nginx_external_config" {
  depends_on = [ null_resource.create_nginx_external_config_dir, local_file.nginx_external_config_file ]
  provisioner "file" {
    source      = local_file.nginx_external_config_file.filename
    destination = "/root/nginx_external_config/nginx.conf"
    connection {
      host        = "192.168.0.29"
      user        = "root"
      private_key = file("~/.ssh/id_ed25519")
    }
  }
  triggers = {
    config_hash = sha256(var.nginx_external_config)
  }
}

resource "null_resource" "create_nginx_internal_external_config_dir" {
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /root/nginx_internal_external_config"
    ]
    connection {
      host        = "192.168.0.29"
      user        = "root"
      private_key = file("~/.ssh/id_ed25519")
    }
  }
  triggers = {
    config_hash = sha256(var.nginx_internal_external_config)
  }
}

resource "null_resource" "upload_nginx_internal_external_config" {
  depends_on = [ null_resource.create_nginx_internal_external_config_dir, local_file.nginx_internal_external_config_file ]
  provisioner "file" {
    source      = local_file.nginx_internal_external_config_file.filename
    destination = "/root/nginx_internal_external_config/nginx.conf"
    connection {
      host        = "192.168.0.29"
      user        = "root"
      private_key = file("~/.ssh/id_ed25519")
    }
  }
  triggers = {
    config_hash = sha256(var.nginx_internal_external_config)
  }
}

resource "docker_container" "nginx" {
  count = var.nginx_count

  image = "nginx:latest"
  name  = "nginx-${count.index}"

  labels {
    label = "module"
    value = "infrastructure"
  }

  # ports {
  #   internal = 80
  #   external = 8000 + count.index
  # }

  networks_advanced {
    name = docker_network.internal.name
    aliases = ["nginx-${count.index}"]
  }

  depends_on = [ docker_network.internal ]
}

resource "docker_container" "nginx-external" {
  count = var.nginx_external_count

  image = "nginx:latest"
  name  = "nginx-external-${count.index}"

  labels {
    label = "module"
    value = "infrastructure"
  }

  ports {
    internal = 80
    external = 8100 + count.index
  }

  networks_advanced {
    name = docker_network.external.name
    aliases = ["nginx-external-${count.index}"]
  }

  depends_on = [ docker_network.external, null_resource.upload_nginx_external_config ]

  user = "root"

  volumes {
    host_path = "/root/nginx_external_config/nginx.conf"
    container_path = "/etc/nginx/nginx.conf"
    read_only = true
  }
}

resource "docker_container" "nginx-internal-external" {
  count = var.nginx_internal_external_count

  image = "nginx:latest"
  name  = "nginx-internal-external-${count.index}"

  labels {
    label = "module"
    value = "infrastructure"
  }

  ports {
    internal = 80
    external = 8200 + count.index
  }

  networks_advanced {
    name = docker_network.internal.name
    aliases = ["nginx-internal-external-${count.index}"]
  }
  networks_advanced {
    name = docker_network.external.name
    aliases = ["nginx-internal-external-${count.index}"]
  }

  depends_on = [ docker_network.internal, docker_network.external, null_resource.upload_nginx_internal_external_config ]

  volumes {
    host_path = "/root/nginx_internal_external_config/nginx.conf"
    container_path = "/etc/nginx/nginx.conf"
    read_only = true
  }
}

resource "docker_container" "tomcat" {
  count = var.tomcat_count

  image = "tomcat:latest"
  name  = "tomcat-${count.index}"

  labels {
    label = "module"
    value = "infrastructure"
  }

  # ports {
  #   internal = 8080
  #   external = 8081 + count.index
  # }

  networks_advanced {
    name = docker_network.internal.name
    aliases = ["tomcat-${count.index}"]
  }

  depends_on = [ docker_network.internal ]
}

resource "docker_container" "mysql" {
  count = var.mysql_count

  image = "mysql:latest"
  name  = "mysql-${count.index}"
  
  labels {
    label = "module"
    value = "infrastructure"
  }
  
  # ports {
  #   internal = 3306
  #   external = 3307 + count.index
  # }

  networks_advanced {
    name = docker_network.internal.name
    aliases = ["mysql-${count.index}"]
  }

  depends_on = [ docker_network.internal ]
  
  env = [
    "MYSQL_ROOT_PASSWORD=mysql",
    "MYSQL_DATABASE=mysql",
    "MYSQL_USER=mysql",
    "MYSQL_PASSWORD=mysql"
  ]
}

resource "docker_container" "postgres" {
  count = var.postgres_count

  image = "postgres:latest"
  name  = "postgres-${count.index}"
  
  labels {
    label = "module"
    value = "infrastructure"
  }
  
  # ports {
  #   internal = 5432
  #   external = 5433 + count.index
  # }

  networks_advanced {
    name = docker_network.internal.name
    aliases = ["postgres-${count.index}"]
  }

  depends_on = [ docker_network.internal ]

  env = [
    "POSTGRES_PASSWORD=postgres"
  ]

  command = [ "postgres", "-c", "log_statement=all" ]
}

resource "docker_container" "redis" {
  count = var.redis_count

  image = "redis:latest"
  name  = "redis-${count.index}"
  
  labels {
    label = "module"
    value = "infrastructure"
  }
  
  # ports {
  #   internal = 6379
  #   external = 6380 + count.index
  # }

  networks_advanced {
    name = docker_network.internal.name
    aliases = ["redis-${count.index}"]
  }

  depends_on = [ docker_network.internal ]
}

resource "docker_container" "wordpress-internal-external" {
  count = var.wordpress_internal_external_count

  image = "wordpress:latest"
  name  = "wordpress-internal-external-${count.index}"
  
  labels {
    label = "module"
    value = "infrastructure"
  }
  
  ports {
    internal = 80
    external = 8000 + count.index
  }

  networks_advanced {
    name = docker_network.internal.name
    aliases = ["wordpress-internal-external-${count.index}"]
  }
  networks_advanced {
    name = docker_network.external.name
    aliases = ["wordpress-internal-external-${count.index}"]
  }

  depends_on = [ docker_network.internal, docker_network.external, docker_container.mysql ]

  env = [
    "WORDPRESS_DB_HOST=mysql-${count.index}",
    "WORDPRESS_DB_USER=mysql",
    "WORDPRESS_DB_PASSWORD=mysql",
    "WORDPRESS_DB_NAME=mysql"
  ]
}

resource "docker_container" "rabbitmq" {
  count = var.rabbitmq_count

  image = "rabbitmq:management"
  name  = "rabbitmq-${count.index}"
  
  labels {
    label = "module"
    value = "infrastructure"
  }
  
  # ports {
  #   internal = 5672
  #   external = 5673 + count.index
  # }

  networks_advanced {
    name = docker_network.internal.name
    aliases = ["rabbitmq-${count.index}"]
  }

  depends_on = [ docker_network.internal ]
}

resource "docker_container" "httpd" {
  count = var.httpd_count

  image = "httpd:latest"
  name  = "httpd-${count.index}"
  
  labels {
    label = "module"
    value = "infrastructure"
  }
  
  # ports {
  #   internal = 80
  #   external = 8200 + count.index
  # }

  networks_advanced {
    name = docker_network.internal.name
    aliases = ["httpd-${count.index}"]
  }

  depends_on = [ docker_network.internal ]
}
