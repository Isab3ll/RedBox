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
        output_result = subprocess.run(
            ["terraform", "output", "-json"],
            cwd=TERRAFORM_DIR,
            check=True,
            text=True,
            capture_output=True
        )
        output_data = json.loads(output_result.stdout)

        agents = []
        agents_groups = [
            "ragdoll_agent_ips",
            "sandcat_agent_ips",
            "manx_agent_ips",
        ]

        for group in agents_groups:
            if group in output_data:
                agent_list = output_data[group]["value"]
                for agent in agent_list:
                    name = agent.get("name")
                    ip_info = "N/A"
                    ip_0 = agent.get("ip_0")
                    ip_1 = agent.get("ip_1")

                    if ip_0 and ip_1:
                        ip_info = f"{ip_0} / {ip_1}"
                    elif ip_0:
                        ip_info = ip_0

                    agents.append({
                        "name": name,
                        "ip": ip_info,
                    })

        return {"status": "success", "agents": agents}
    
    except subprocess.CalledProcessError as e:
        return {"status": "error", "output": e.stderr}
