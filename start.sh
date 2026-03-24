#!/bin/bash

# This script correctly starts the two backend services and then the proxy itself.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Starting CLIProxyAPI on port 8317..."
cd "$DIR/CLIProxyAPI-main"
if [ ! -f "config.yaml" ]; then
    cp config.example.yaml config.yaml 2>/dev/null || true
fi

# Run built binary if it exists (e.g. built by Docker), otherwise go run
if [ -x "./CLIProxyAPI" ]; then
    ./CLIProxyAPI &
else
    go run ./cmd/server/ &
fi

echo "Starting grok2api-main on port 8000..."
cd "$DIR/grok2api-main"
sh scripts/init_storage.sh 2>/dev/null || true

# Grok2API utilizes granian, run via uv if available
if command -v uv &> /dev/null; then
    uv run granian --interface asgi --host 0.0.0.0 --port 8000 --workers 1 main:app &
else
    # Fallback to plain python3 and pip
    python3 -m pip install -r requirements.txt granian --break-system-packages 2>/dev/null || true
    python3 -m granian --interface asgi --host 0.0.0.0 --port 8000 --workers 1 main:app &
fi

echo "Backend services starting in background..."
echo "Now starting the Node.js root proxy on port 8080..."

cd "$DIR"
exec node proxy.js