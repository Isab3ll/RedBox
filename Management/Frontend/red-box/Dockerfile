FROM denoland/deno:2.2.4
WORKDIR '/app'

COPY package.json .
RUN deno install

COPY . .

CMD ["deno", "task", "dev", "--host", "0.0.0.0"]

# Builowanie obrazu
# docker build -t isab3ll/management:frontend .

# Pushowanie obrazu
# docker push isab3ll/management:frontend

# Uruchamianie kontenera
# docker run -p 5173:5173 --env PUBLIC_BACKEND_IP=192.168.0.28 --env PUBLIC_BACKEND_PORT=8000 --env PUBLIC_ATTACK_IP=192.168.0.25 --env PUBLIC_ATTACK_PORT=8888 --rm -d isab3ll/management:frontend 
