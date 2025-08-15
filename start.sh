#!/bin/bash

echo "========================================"
echo "  Real-Debrid Roku App Server"
echo "========================================"
echo

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed"
    echo "Please install npm"
    exit 1
fi

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "Error: package.json not found"
    echo "Please run this script from the project directory"
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "Installing Node.js dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install dependencies"
        exit 1
    fi
    echo
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "Warning: .env file not found"
    echo "Please create a .env file with your Real-Debrid API key:"
    echo "REALDEBRID_API_KEY=your_api_key_here"
    echo
fi

# Get local IP address
if command -v hostname &> /dev/null; then
    LOCAL_IP=$(hostname -I | awk '{print $1}' 2>/dev/null)
    if [ -z "$LOCAL_IP" ]; then
        LOCAL_IP=$(ip route get 1 | awk '{print $7}' 2>/dev/null | head -n1)
    fi
    if [ -z "$LOCAL_IP" ]; then
        LOCAL_IP="localhost"
    fi
else
    LOCAL_IP="localhost"
fi

echo "Starting server..."
echo "Local IP: $LOCAL_IP"
echo "Server will be available at:"
echo "  - Local: http://localhost:3000"
echo "  - Network: http://$LOCAL_IP:3000"
echo
echo "Update your Roku app config with: http://$LOCAL_IP:3000"
echo "Press Ctrl+C to stop the server"
echo "========================================"
echo

# Start the server
npm start