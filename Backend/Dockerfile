ARG TERRAFORM_VERSION="1.11.2"

FROM python:3.13-bookworm

WORKDIR /usr/src/app

ARG TERRAFORM_VERSION

RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN cd terraform && \
    terraform init

CMD ["uvicorn", "backend:app", "--host", "0.0.0.0", "--port", "8000" ]

# Builowanie obrazu
# docker build -t isab3ll/management:backend .

# Pushowanie obrazu
# docker push isab3ll/management:backend

# Uruchamianie kontenera
# docker run -p 8000:8000 --env FRONTEND_URL=192.168.0.28 --rm -d -v /root/.ssh:/root/.ssh:ro isab3ll/management:backend