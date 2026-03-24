FROM node:20-bullseye

WORKDIR /app

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    golang \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv for python package management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

COPY . /app

RUN npm install

RUN cd /app/CLIProxyAPI-main && \
    go mod tidy && \
    go build -o CLIProxyAPI ./cmd/server/

RUN chmod +x /app/start.sh

EXPOSE 8080

CMD ["/app/start.sh"]