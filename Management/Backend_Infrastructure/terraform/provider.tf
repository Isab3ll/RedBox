provider "docker" {
  alias = "backend-infrastructure"
  host = "ssh://root@192.168.0.29:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}