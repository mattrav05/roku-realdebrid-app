#!/bin/bash

echo "🚀 Deploying Roku Real-Debrid App to Vercel"
echo "==========================================="
echo ""

# Check if Vercel CLI is available
if ! command -v vercel &> /dev/null && ! command -v npx &> /dev/null; then
    echo "❌ Vercel CLI not found. Installing..."
    npm install --save-dev vercel
fi

# Use npx to run vercel
echo "📦 Starting deployment..."
npx vercel

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Next steps:"
echo "1. Add your Real-Debrid API key:"
echo "   npx vercel env add REALDEBRID_API_KEY"
echo ""
echo "2. Deploy to production:"
echo "   npx vercel --prod"
echo ""
echo "3. Update your Roku app with the new URL"