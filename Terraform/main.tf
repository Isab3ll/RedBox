terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "ssh://root@192.168.0.24:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

# docker pull nginx:latest
resource "docker_image" "my-nginx" {
  name = "nginx:latest"
}

# docker run --name nginx -p8080:80 -d nginx:latest
resource "docker_container" "nginx" {
  name = "nginx"
  image = docker_image.my-nginx.image_id

  ports {
    external = 8080
    internal = 80
  }
}
