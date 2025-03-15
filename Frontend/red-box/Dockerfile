FROM denoland/deno:2.2.4
WORKDIR '/app'

COPY package.json .
RUN deno install

COPY . .

CMD ["deno", "task", "dev", "--host", "0.0.0.0"]

# Builowanie obrazu
# docker build -t docker-svelte-test:latest .

# Uruchamianie kontenera
# docker run -p 5173:5173 --rm docker-svelte-test:latest

# Uruchamianie w wersji deweloperskiej z dynamicznym odświeżaniem
# docker run -it -p 5173:5173 -v /app/node_modules -v .:/app docker-svelte-test:latest