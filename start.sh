#!/bin/bash

# Fix: start.sh was previously overwritten by proxy.js contents.
# This script correctly starts the two backend services.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Starting CLIProxyAPI on port 8317..."
cd "$DIR/CLIProxyAPI-main"
if [ ! -f "config.yaml" ]; then
    cp config.example.yaml config.yaml
fi

# Run built binary if it exists (e.g. built by Docker), otherwise go run
if [ -x "./CLIProxyAPI" ]; then
    ./CLIProxyAPI &
else
    go run ./cmd/server/ &
fi

echo "Starting grok2api-main on port 8000..."
cd "$DIR/grok2api-main"
# Grok2API utilizes granian, run via uv if available
if command -v uv &> /dev/null; then
    uv run granian --interface asgi --host 0.0.0.0 --port 8000 --workers 1 main:app &
else
    # Fallback to plain python3 and pip
    python3 -m pip install -r requirements.txt granian --break-system-packages || true
    python3 -m granian --interface asgi --host 0.0.0.0 --port 8000 --workers 1 main:app &
fi

echo "Backend services starting in background..."
wait