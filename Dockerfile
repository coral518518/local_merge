FROM node:20-bullseye

WORKDIR /app

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    golang \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY . /app

RUN npm install

RUN cd /app/CLIProxyAPI-main && \
    go mod tidy && \
    go build -o CLIProxyAPI .

RUN chmod +x /app/start.sh

EXPOSE 8080

CMD ["/app/start.sh"]