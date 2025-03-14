from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import subprocess
import json
import os

app = FastAPI()
TERRAFORM_DIR = "terraform"

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["POST", "OPTIONS"],
    allow_headers=["Content-Type"],
)

@app.post("/apply")
def apply_infrastructure(data: dict):
    try:
        variables = {
            "nginx_count": data.get("nginx_count", 1),
            "tomcat_count": data.get("tomcat_count", 1),
            "mysql_count": data.get("mysql_count", 1),
            "postgres_count": data.get("postgres_count", 1)
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
def destroy_infrastructure():
    try:
        result = subprocess.run(
            ["terraform", "state", "list"],
            cwd=TERRAFORM_DIR,
            check=True,
            text=True,
            capture_output=True
        )
        return {"status": "success", "output": result.stdout}
    
    except subprocess.CalledProcessError as e:
        return {"status": "error", "output": e.stderr}
