#!/bin/bash

# Script to run Warp Terminal in Docker with X11 forwarding on macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Warp Terminal Docker Setup${NC}"

# Check if XQuartz is installed
if ! command -v xquartz >/dev/null 2>&1; then
    echo -e "${RED}XQuartz is not installed. Please install it first:${NC}"
    echo "brew install --cask xquartz"
    echo "Then log out and log back in, or reboot your Mac."
    exit 1
fi

# Check if XQuartz is running
if ! pgrep -f "XQuartz" > /dev/null; then
    echo -e "${YELLOW}Starting XQuartz...${NC}"
    open -a XQuartz
    sleep 3
fi

# Set up X11 forwarding using host.docker.internal (Docker's standard host reference)
echo -e "${GREEN}Using host.docker.internal for X11 forwarding${NC}"

# Allow connections from Docker's host reference
xhost +${hostname}

export HOSTNAME=`hostname`

# Build the Docker image if it doesn't exist
if ! docker images | grep -q "warp-docker"; then
    echo -e "${YELLOW}Building Warp Terminal Docker image...${NC}"
    docker build -t warp-terminal .
fi

# Run the container with AMD64 platform for compatibility
echo -e "${GREEN}Starting Warp Terminal container...${NC}"
docker run -it --rm \
    --platform linux/amd64 \
    --name warp-terminal \
    -e DISPLAY=host.docker.internal:0 \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v "$HOME":/host-home:ro \
    --network host \
    djsd123/warp-docker

# Clean up
xhost -host.docker.internal

echo -e "${GREEN}Warp Terminal session ended${NC}"
