# Roku Real-Debrid App

A Roku application that integrates with Real-Debrid to stream your torrents and downloads directly to your Roku device.

## Features

- Search for torrents
- View and manage Real-Debrid downloads
- Stream video files directly to Roku
- Manage active torrents
- Web UI for testing and debugging

## Setup Instructions

### 1. Backend Server Setup

First, install Node.js dependencies:

```bash
npm install
```

### 2. Configure Real-Debrid API Key

Edit the `.env` file and add your Real-Debrid API key:

```
REALDEBRID_API_KEY=your_api_key_here
```

You can get your API key from: https://real-debrid.com/apitoken

### 3. Start the Backend Server

```bash
npm start
```

The server will start on `http://localhost:3000`

### 4. Access the Web UI

Open your browser and navigate to `http://localhost:3000` to test the functionality.

### 5. Configure Roku App

Edit `source/config.brs` and update the `serverUrl` with your computer's IP address:

```brightscript
serverUrl: "http://YOUR_COMPUTER_IP:3000"
```

To find your computer's IP:
- Windows: `ipconfig`
- Mac/Linux: `ifconfig` or `ip addr`

### 6. Deploy to Roku

Enable Developer Mode on your Roku:
1. Go to Settings > System > Advanced system settings
2. Select "Advanced system settings"
3. Select "Developer options"
4. Enable "Developer Mode" and set a password

Deploy the app:
```bash
# Package the app
zip -r roku-app.zip manifest source components images

# Or use the existing package
# The out/roku-deploy.zip file is already packaged

# Upload to Roku (replace ROKU_IP with your Roku's IP)
curl -u "rokudev:YOUR_DEV_PASSWORD" --digest \
     -F "mysubmit=Install" \
     -F "archive=@roku-app.zip" \
     http://ROKU_IP/plugin_install
```

## Project Structure

```
roku-realdebrid-app/
├── components/          # Roku SceneGraph components
├── source/             # BrightScript source files
│   ├── main.brs       # Main application entry
│   ├── RealDebridAPI.brs # API integration
│   └── config.brs     # Configuration
├── public/            # Web UI files
│   ├── index.html
│   ├── styles.css
│   └── app.js
├── server.js          # Node.js backend server
├── package.json       # Node dependencies
└── .env              # Environment variables
```

## API Endpoints

The backend server provides these endpoints:

- `GET /api/user` - Get user information
- `GET /api/downloads` - List downloads
- `GET /api/torrents` - List active torrents
- `POST /api/torrents/add` - Add a new torrent
- `POST /api/torrents/select/:id` - Select files from torrent
- `DELETE /api/torrents/:id` - Delete a torrent
- `POST /api/unrestrict` - Unrestrict a link for streaming
- `GET /api/search?query=` - Search for torrents

## Debugging

### Test Without Roku Device

1. Use the web UI at `http://localhost:3000` to test all functionality
2. The backend server handles all Real-Debrid API calls
3. Check server logs for API responses and errors

### Roku Simulator

For basic testing without a device:
```bash
# Install brs (BrightScript interpreter)
npm install -g brs

# Run the app in simulator
brs source/main.brs
```

Note: The simulator has limited graphics support and will run in text mode.

### Debug on Roku Device

1. Access Roku debug console: `telnet ROKU_IP 8085`
2. View print statements and errors in real-time
3. The app includes debug logging that can be toggled in `config.brs`

## Troubleshooting

### Connection Issues
- Ensure your Roku and computer are on the same network
- Check firewall settings to allow port 3000
- Verify the server URL in `config.brs` matches your computer's IP

### API Errors
- Verify your Real-Debrid API key in `.env`
- Check if your Real-Debrid account is premium
- Monitor server console for detailed error messages

### Video Playback
- Real-Debrid must unrestrict the link first
- Roku supports limited video formats (MP4, MKV, etc.)
- Large files may take time to start streaming

## Security Notes

- Never commit your API key to version control
- Keep the `.env` file private
- Consider using HTTPS in production
- Restrict server access to local network only

## License

This project is for personal use only. Respect copyright laws and Real-Debrid's terms of service.