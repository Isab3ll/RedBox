from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import json
import os
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

@app.post("/apply")
def apply_agent(data: dict):
    try:
        variables = {
            "agent_type": data.get("agent_type", "sandcat"),
            "agent_param": data.get("agent_param", "splunkd"),
            "server_ip": data.get("server_ip", "localhost"),
            "server_port": data.get("server_port", 8888),
            "network_internal": data.get("network_internal", False),
            "network_external": data.get("network_external", True),
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
def destroy_agent():
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
def agent_status():
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
