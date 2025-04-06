variable "nginx_external_config" {
  description = "Nginx external configuration file"
  type        = string
}

variable "nginx_internal_external_config" {
  description = "Nginx internal/external configuration file"
  type        = string
}

variable "nginx_count" {
  description = "Nginx instances"
  type        = number
  default     = 0
}

variable "nginx_external_count" {
  description = "Nginx external instances"
  type        = number
  default     = 0
}

variable "nginx_internal_external_count" {
  description = "Nginx instances that are both internal and external"
  type        = number
  default     = 0
}

variable "tomcat_count" {
  description = "Tomcat instances"
  type        = number
  default     = 0
}

variable "mysql_count" {
  description = "MySQL instances"
  type        = number
  default     = 0
}

variable "postgres_count" {
  description = "Postgres instances"
  type        = number
  default     = 0
}

variable "redis_count" {
  description = "Redis instances"
  type        = number
  default     = 0
}

variable "wordpress_internal_external_count" {
  description = "Wordpress instances that are both internal and external"
  type        = number
  default     = 0
}

variable "rabbitmq_count" {
  description = "RabbitMQ instances"
  type        = number
  default     = 0
}

variable "httpd_count" {
  description = "Apache HTTPD instances"
  type        = number
  default     = 0
}
