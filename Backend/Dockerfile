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

CMD ["uvicorn", "backend:app", "--host", "0.0.0.0", "--port", "8000" ]

# Builowanie obrazu
# docker build -t docker-python-test:latest .

# Uruchamianie kontenera
# docker run -p 8000:8000 --rm docker-python-test:latest