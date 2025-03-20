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
