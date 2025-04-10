output "nginx_container_ips" {
  value = var.nginx_count > 0 ? [
    for c in docker_container.nginx : {
      name = c.name
      ip_0   = c.network_data[0].ip_address
    }
  ] : []
  description = "IP addresses of Nginx containers (internal network)"
}

output "nginx_external_container_ips" {
  value = var.nginx_external_count > 0 ? [
    for c in docker_container.nginx-external : {
      name = c.name
      ip_0   = c.network_data[0].ip_address
    }
  ] : []
  description = "IP addresses of Nginx containers (external network)"
}

output "nginx_internal_external_container_ips" {
  value = var.nginx_internal_external_count > 0 ? [
    for c in docker_container.nginx-internal-external : {
      name   = c.name
      ip_0 = c.network_data[0].ip_address
      ip_1 = c.network_data[1].ip_address
    }
  ] : []
  description = "IP addresses of Nginx containers (connected to both internal and external networks)"
}

output "tomcat_container_ips" {
  value = var.tomcat_count > 0 ? [
    for c in docker_container.tomcat : {
      name = c.name
      ip_0   = c.network_data[0].ip_address
    }
  ] : []
  description = "IP addresses of Tomcat containers"
}

output "mysql_container_ips" {
  value = var.mysql_count > 0 ? [
    for c in docker_container.mysql : {
      name = c.name
      ip_0   = c.network_data[0].ip_address
    }
  ] : []
  description = "IP addresses of MySQL containers"
}

output "postgres_container_ips" {
  value = var.postgres_count > 0 ? [
    for c in docker_container.postgres : {
      name = c.name
      ip_0   = c.network_data[0].ip_address
    }
  ] : []
  description = "IP addresses of PostgreSQL containers"
}

output "redis_container_ips" {
  value = var.redis_count > 0 ? [
    for c in docker_container.redis : {
      name = c.name
      ip_0   = c.network_data[0].ip_address
    }
  ] : []
  description = "IP addresses of Redis containers"
}

output "wordpress_internal_external_container_ips" {
  value = var.wordpress_internal_external_count > 0 ? [
    for c in docker_container.wordpress-internal-external : {
      name   = c.name
      ip_0 = c.network_data[0].ip_address
      ip_1 = c.network_data[1].ip_address
    }
  ] : []
  description = "IP addresses of WordPress containers (connected to both internal and external networks)"
}

output "rabbitmq_container_ips" {
  value = var.rabbitmq_count > 0 ? [
    for c in docker_container.rabbitmq : {
      name = c.name
      ip_0   = c.network_data[0].ip_address
    }
  ] : []
  description = "IP addresses of RabbitMQ containers"
}

output "httpd_container_ips" {
  value = var.httpd_count > 0 ? [
    for c in docker_container.httpd : {
      name = c.name
      ip_0   = c.network_data[0].ip_address
    }
  ] : []
  description = "IP addresses of Apache HTTPD containers"
}
