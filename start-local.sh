#!/bin/bash

echo "========================================"
echo "  Real-Debrid Roku Local Server"
echo "========================================"
echo ""
echo "This server runs on your local network only"
echo "No cloud deployment needed!"
echo ""
echo "Your Roku must be on the same WiFi network"
echo ""

# Get local IP address
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2 | head -1)
else
    # Linux
    LOCAL_IP=$(hostname -I | cut -d' ' -f1)
fi

echo "Server will be available at:"
echo "  http://$LOCAL_IP:3000"
echo ""
echo "Configure your Roku app with this URL"
echo ""
echo "Starting server..."
npm start