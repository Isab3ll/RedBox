from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import json
import os
import re
import subprocess

TERRAFORM_DIR = "terraform"
FRONTEND_IP = os.environ.get("FRONTEND_IP", "localhost")
FRONTEND_PORT = os.environ.get("FRONTEND_PORT", "5173")

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=[f"http://{FRONTEND_IP}:{FRONTEND_PORT}"],
    allow_credentials=True,
    allow_methods=["POST", "OPTIONS"],
    allow_headers=["Content-Type"],
)

nginx_default_config = """
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
"""

@app.post("/apply")
def apply_infrastructure(data: dict):
    try:
        variables = {
            "nginx_count": data.get("nginx_count", 0),
            "nginx_external_count": data.get("nginx_external_count", 0),
            "nginx_external_config": data.get("nginx_external_config", nginx_default_config),
            "nginx_internal_external_count": data.get("nginx_internal_external_count", 0),
            "nginx_internal_external_config": data.get("nginx_internal_external_config", nginx_default_config),
            "tomcat_count": data.get("tomcat_count", 0),
            "mysql_count": data.get("mysql_count", 0),
            "postgres_count": data.get("postgres_count", 0),
            "redis_count": data.get("redis_count", 0),
            "wordpress_internal_external_count": data.get("wordpress_internal_external_count", 0),
            "rabbitmq_count": data.get("rabbitmq_count", 0),
            "httpd_count": data.get("httpd_count", 0),
        }

        variables_file = os.path.join(TERRAFORM_DIR, "terraform.tfvars.json")
        with open(variables_file, "w") as f:
            json.dump(variables, f)

        result = subprocess.run(
            ["terraform", "apply", "-auto-approve", "-lock=false"],
            cwd=TERRAFORM_DIR,
            check=True,
            text=True,
            capture_output=True
        )
        return {"status": "success", "output": result.stdout}
    
    except subprocess.CalledProcessError as e:
        return {"status": "error", "output": e.stderr}

@app.post("/destroy")
def destroy_infrastructure():
    try:
        result = subprocess.run(
            ["terraform", "destroy", "-auto-approve", "-lock=false"],
            cwd=TERRAFORM_DIR,
            check=True,
            text=True,
            capture_output=True
        )
        return {"status": "success", "output": result.stdout}
    
    except subprocess.CalledProcessError as e:
        return {"status": "error", "output": e.stderr}

@app.post("/status")
def infrastructure_status():
    try:
        output_result = subprocess.run(
            ["terraform", "output", "-json"],
            cwd=TERRAFORM_DIR,
            check=True,
            text=True,
            capture_output=True
        )
        output_data = json.loads(output_result.stdout)

        containers = []
        container_groups = [
            "httpd_container_ips",
            "mysql_container_ips",
            "nginx_container_ips",
            "nginx_external_container_ips",
            "nginx_internal_external_container_ips",
            "postgres_container_ips",
            "rabbitmq_container_ips",
            "redis_container_ips",
            "tomcat_container_ips",
            "wordpress_internal_external_container_ips",
        ]

        for group in container_groups:
            if group in output_data:
                containers_list = output_data[group]["value"]
                for container in containers_list:
                    name = container.get("name")
                    ip_info = "N/A"
                    ip_0 = container.get("ip_0")
                    ip_1 = container.get("ip_1")

                    if ip_0 and ip_1:
                        ip_info = f"{ip_0} / {ip_1}"
                    elif ip_0:
                        ip_info = f"{ip_0}"

                    parts = name.split("-")
                    container_name = "-".join(parts[:-1])
                    container_id = parts[-1]

                    containers.append({
                        "name": container_name,
                        "id": container_id,
                        "ip": ip_info
                    })

        return {"status": "success", "containers": containers}

    except subprocess.CalledProcessError as e:
        return {"status": "error", "output": e.stderr}
