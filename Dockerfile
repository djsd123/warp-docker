# Use Ubuntu as base image
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages for X11 and GUI support
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    x11-apps \
    xauth \
    dbus-x11 \
    libgtk-3-0 \
    libx11-xcb1 \
    libxss1 \
    libgconf-2-4 \
    libxrandr2 \
    libasound2 \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libcairo-gobject2 \
    libgtk-3-0 \
    libgdk-pixbuf2.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libnss3 \
    libdrm2 \
    libxss1 \
    libgbm1 \
    && rm -rf /var/lib/apt/lists/*

# Download and install Warp Terminal
RUN wget https://releases.warp.dev/linux/v0.2024.10.29.08.02.stable_00/warp-terminal_0.2024.10.29.08.02.stable.00_amd64.deb -O /tmp/warp.deb && \
    dpkg -i /tmp/warp.deb || apt-get install -f -y && \
    rm /tmp/warp.deb

# Create a non-root user
RUN useradd -m -s /bin/bash warpuser && \
    usermod -aG sudo warpuser

# Set up environment for X11
ENV DISPLAY=:0
ENV XDG_RUNTIME_DIR=/tmp/runtime-warpuser
RUN mkdir -p /tmp/runtime-warpuser && chown warpuser:warpuser /tmp/runtime-warpuser

# Switch to non-root user
USER warpuser
WORKDIR /home/warpuser

# Create startup script
RUN echo '#!/bin/bash\n\
export DISPLAY=${DISPLAY:-:0}\n\
export XDG_RUNTIME_DIR=/tmp/runtime-warpuser\n\
# Wait for X11 to be available\n\
until xset q &>/dev/null; do\n\
  echo "Waiting for X11..."\n\
  sleep 1\n\
done\n\
exec warp-terminal "$@"' > /home/warpuser/start-warp.sh && \
    chmod +x /home/warpuser/start-warp.sh

# Default command
CMD ["/home/warpuser/start-warp.sh"]
