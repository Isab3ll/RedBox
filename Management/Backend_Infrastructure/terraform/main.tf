resource "docker_network" "infrastructure" {
  provider = docker.backend-infrastructure
  name = "infrastructure"
  driver = "bridge"
}

resource "docker_container" "nginx" {
  provider = docker.backend-infrastructure
  count = var.nginx_count

  image = "nginx:latest"
  name  = "nginx-${count.index + 1}"

  labels {
    label = "module"
    value = "infrastructure"
  }

  ports {
    internal = 80
    external = 8000 + count.index
  }

  networks_advanced {
    name = docker_network.infrastructure.name
    aliases = ["nginx-${count.index + 1}"]
  }
  depends_on = [ docker_network.infrastructure ]
}

resource "docker_container" "tomcat" {
  provider = docker.backend-infrastructure
  count = var.tomcat_count

  image = "tomcat:latest"
  name  = "tomcat-${count.index + 1}"

  labels {
    label = "module"
    value = "infrastructure"
  }

  ports {
    internal = 8080
    external = 8081 + count.index
  }

  networks_advanced {
    name = docker_network.infrastructure.name
    aliases = ["tomcat-${count.index + 1}"]
  }
  depends_on = [ docker_network.infrastructure ]
}

resource "docker_container" "mysql" {
  provider = docker.backend-infrastructure
  count = var.mysql_count

  image = "mysql:latest"
  name  = "mysql-${count.index + 1}"
  
  labels {
    label = "module"
    value = "infrastructure"
  }
  
  ports {
    internal = 3306
    external = 3307 + count.index
  }

  networks_advanced {
    name = docker_network.infrastructure.name
    aliases = ["mysql-${count.index + 1}"]
  }
  depends_on = [ docker_network.infrastructure ]
  
  env = [
    "MYSQL_ROOT_PASSWORD=mysql",
    "MYSQL_DATABASE=mysql",
    "MYSQL_USER=mysql",
    "MYSQL_PASSWORD=mysql"
  ]
}

resource "docker_container" "postgres" {
  provider = docker.backend-infrastructure
  count = var.postgres_count

  image = "postgres:latest"
  name  = "postgres-${count.index + 1}"
  
  labels {
    label = "module"
    value = "infrastructure"
  }
  
  ports {
    internal = 5432
    external = 5433 + count.index
  }

  networks_advanced {
    name = docker_network.infrastructure.name
    aliases = ["postgres-${count.index + 1}"]
  }
  depends_on = [ docker_network.infrastructure ]

  env = [
    "POSTGRES_PASSWORD=postgres"
  ]

  command = [ "postgres", "-c", "log_statement=all" ]
}

resource "docker_container" "redis" {
  provider = docker.backend-infrastructure
  count = var.redis_count

  image = "redis:latest"
  name  = "redis-${count.index + 1}"
  
  labels {
    label = "module"
    value = "infrastructure"
  }
  
  ports {
    internal = 6379
    external = 6380 + count.index
  }

  networks_advanced {
    name = docker_network.infrastructure.name
    aliases = ["redis-${count.index + 1}"]
  }
  depends_on = [ docker_network.infrastructure ]  
}

resource "docker_container" "wordpress" {
  provider = docker.backend-infrastructure
  count = var.wordpress_count

  image = "wordpress:latest"
  name  = "wordpress-${count.index + 1}"
  
  labels {
    label = "module"
    value = "infrastructure"
  }
  
  ports {
    internal = 80
    external = 8100 + count.index
  }

  networks_advanced {
    name = docker_network.infrastructure.name
    aliases = ["wordpress-${count.index + 1}"]
  }
  depends_on = [ docker_network.infrastructure ]

  env = [
    "WORDPRESS_DB_HOST=mysql-${count.index + 1}",
    "WORDPRESS_DB_USER=mysql",
    "WORDPRESS_DB_PASSWORD=mysql",
    "WORDPRESS_DB_NAME=mysql"
  ]
}

resource "docker_container" "rabbitmq" {
  provider = docker.backend-infrastructure
  count = var.rabbitmq_count

  image = "rabbitmq:management"
  name  = "rabbitmq-${count.index + 1}"
  
  labels {
    label = "module"
    value = "infrastructure"
  }
  
  ports {
    internal = 5672
    external = 5673 + count.index
  }

  networks_advanced {
    name = docker_network.infrastructure.name
    aliases = ["rabbitmq-${count.index + 1}"]
  }
  depends_on = [ docker_network.infrastructure ]
}

resource "docker_container" "httpd" {
  provider = docker.backend-infrastructure
  count = var.httpd_count

  image = "httpd:latest"
  name  = "httpd-${count.index + 1}"
  
  labels {
    label = "module"
    value = "infrastructure"
  }
  
  ports {
    internal = 80
    external = 8200 + count.index
  }

  networks_advanced {
    name = docker_network.infrastructure.name
    aliases = ["httpd-${count.index + 1}"]
  }
  depends_on = [ docker_network.infrastructure ]
}