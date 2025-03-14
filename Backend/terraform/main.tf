resource "docker_container" "nginx" {
  count = var.nginx_count

  image = "nginx:latest"
  name  = "nginx-${count.index + 1}"
  
  ports {
    internal = 80
    external = 8080 + count.index
  }
}

resource "docker_container" "tomcat" {
  count = var.tomcat_count

  image = "tomcat:latest"
  name  = "tomcat-${count.index + 1}"
  
  ports {
    internal = 8080
    external = 8081 + count.index
  }
}

resource "docker_container" "mysql" {
  count = var.mysql_count

  image = "mysql:latest"
  name  = "mysql-${count.index + 1}"
  
  ports {
    internal = 3306
    external = 3307 + count.index
  }

  env = [
    "MYSQL_ROOT_PASSWORD=rootpassword"
  ]
}

resource "docker_container" "postgres" {
  count = var.postgres_count

  image = "postgres:latest"
  name  = "postgres-${count.index + 1}"
  
  ports {
    internal = 5432
    external = 5433 + count.index
  }

  env = [
    "POSTGRES_PASSWORD=postgrespassword"
  ]
}
