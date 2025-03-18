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
# docker run -p 5173:5173 --rm -d isab3ll/management:frontend
# docker run -p 5173:5173 --env PUBLIC_BACKEND_URL=192.168.0.28 --rm -d isab3ll/management:frontend 

# Uruchamianie w wersji deweloperskiej z dynamicznym odświeżaniem
# docker run -it -p 5173:5173 -v /app/node_modules -v .:/app isab3ll/management:frontend