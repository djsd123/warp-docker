# Warp Terminal in Docker - Setup Instructions

This setup allows you to run Warp Terminal in a Docker container with X11 forwarding on macOS, bypassing direct installation on your work machine.

## Prerequisites

1. **Docker Desktop** - Must be installed and running
2. **Homebrew** - For installing XQuartz
3. **XQuartz** - For X11 forwarding support

## Step-by-Step Setup

### 1. Install XQuartz (if not already installed)

```bash
brew install --cask xquartz
```

**Important**: After installing XQuartz, you must either:
- Log out and log back in, OR
- Reboot your Mac

This is required for XQuartz to properly integrate with the system.

### 2. Configure XQuartz

1. Launch XQuartz: `open -a XQuartz`
2. Go to XQuartz → Preferences → Security
3. Check "Allow connections from network clients"
4. Restart XQuartz

### 3. Copy the Docker Files

Copy these files to your work machine:
- `Dockerfile`
- `run-warp.sh`
- `README.md` (this file)

### 4. Build and Run

Navigate to the directory containing the files and run:

```bash
chmod +x run-warp.sh
./run-warp.sh
```

The script will:
- Check if XQuartz is installed and running
- Build the Docker image (first time only)
- Configure X11 forwarding
- Launch Warp Terminal in the container

## How It Works

- **Container Isolation**: Warp Terminal runs inside an Ubuntu container
- **X11 Forwarding**: GUI is forwarded to your Mac via XQuartz
- **No Direct Installation**: The Warp binary never touches your macOS system
- **Network Access**: Container can access network for AI features

## Troubleshooting

### XQuartz Issues
- Make sure XQuartz is running before starting the container
- Check that "Allow connections from network clients" is enabled in XQuartz preferences
- Try restarting XQuartz if GUI doesn't appear

### Docker Issues
- Ensure Docker Desktop is running
- Check Docker has sufficient resources allocated
- Try rebuilding the image: `docker build -t warp-terminal --no-cache .`

### Display Issues
- If no GUI appears, check the IP address detection in the script
- Try manually setting DISPLAY: `export DISPLAY=YOUR_IP:0`

### Network Issues
- Some corporate firewalls may block the container's network access
- Warp's AI features require internet connectivity

## Alternative Approaches

If this doesn't work in your environment:

1. **VNC Access**: Modify the container to run a VNC server
2. **SSH with X11**: Set up a remote server with Warp installed
3. **Lima VM**: Use Lima instead of Docker for a full Linux VM

## Security Considerations

- The container runs as a non-root user
- Your home directory is mounted read-only
- X11 forwarding is temporary and cleaned up after use
- Consider the implications of network traffic to Warp's AI services

## Files Explained

- **Dockerfile**: Builds Ubuntu container with Warp Terminal and X11 support
- **run-warp.sh**: Convenience script to handle X11 setup and container execution
- **README.md**: This documentation

## Cleanup

To remove the Docker image when no longer needed:

```bash
docker rmi warp-terminal
```
