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

CMD ["uvicorn", "backend_infrastructure:app", "--host", "0.0.0.0", "--port", "8000" ]

# Builowanie obrazu
# docker build -t isab3ll/management:backend_infrastructure .

# Pushowanie obrazu
# docker push isab3ll/management:backend_infrastructure
