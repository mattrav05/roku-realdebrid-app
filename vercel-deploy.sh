#!/bin/bash

# Vercel deployment script
VERCEL_PATH="$HOME/.npm-global/bin/vercel"

echo "🚀 Deploying Roku Real-Debrid App to Vercel"
echo "============================================"
echo ""

# Check if vercel is available
if [ ! -f "$VERCEL_PATH" ]; then
    echo "❌ Vercel CLI not found. Installing..."
    npm install -g vercel
fi

echo "📦 Starting deployment with Vercel CLI..."
echo ""

# Deploy to Vercel
$VERCEL_PATH

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Next steps:"
echo "1. Add your Real-Debrid API key:"
echo "   $VERCEL_PATH env add REALDEBRID_API_KEY"
echo ""
echo "2. Deploy to production:"
echo "   $VERCEL_PATH --prod"
echo ""
echo "3. Your app will be available at the URL shown above"
echo "4. Update your Roku app with the new URL"