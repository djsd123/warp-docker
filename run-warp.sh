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

# Get the IP address for Docker to connect to X11
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
if [ -z "$IP" ]; then
    # Try with en1 if en0 doesn't have an IP
    IP=$(ifconfig en1 | grep inet | awk '$1=="inet" {print $2}')
fi

if [ -z "$IP" ]; then
    echo -e "${RED}Could not determine IP address${NC}"
    exit 1
fi

echo -e "${GREEN}Using IP address: $IP${NC}"

# Allow connections from localhost to X11
xhost +$IP

# Build the Docker image if it doesn't exist
if ! docker images | grep -q "warp-terminal"; then
    echo -e "${YELLOW}Building Warp Terminal Docker image...${NC}"
    docker build -t warp-terminal .
fi

# Run the container
echo -e "${GREEN}Starting Warp Terminal container...${NC}"
docker run -it --rm \
    --name warp-terminal \
    -e DISPLAY=$IP:0 \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v "$HOME":/host-home:ro \
    --network host \
    warp-terminal

# Clean up
xhost -$IP

echo -e "${GREEN}Warp Terminal session ended${NC}"
