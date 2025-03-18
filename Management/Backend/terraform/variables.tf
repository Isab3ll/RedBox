variable "nginx_count" {
  description = "Nginx instances"
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
