output "nginx_ports" {
  value = [for container in docker_container.nginx : container.ports[0].external]
}

output "tomcat_ports" {
  value = [for container in docker_container.tomcat : container.ports[0].external]
}

output "mysql_ports" {
  value = [for container in docker_container.mysql : container.ports[0].external]
}

output "postgres_ports" {
  value = [for container in docker_container.postgres : container.ports[0].external]
}

output "redis_ports" {
  value = [for container in docker_container.redis : container.ports[0].external]
}

output "wordpress_ports" {
  value = [for container in docker_container.wordpress : container.ports[0].external] 
}

output "rabbitmq_ports" {
  value = [for container in docker_container.rabbitmq : container.ports[0].external]  
}

output "httpd_ports" {
  value = [for container in docker_container.httpd : container.ports[0].external]  
}