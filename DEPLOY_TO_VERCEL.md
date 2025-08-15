# 🚀 Deploy to Vercel - Quick Setup Guide

Your app is **ready to deploy**! Follow these simple steps:

## Option 1: Deploy with Vercel CLI (Recommended)

```bash
# From your project directory, run:
npx vercel

# Follow the prompts:
# 1. Set up and deploy? Y
# 2. Which scope? (select your account)
# 3. Link to existing project? N
# 4. Project name? roku-realdebrid
# 5. Directory? ./ (current)
# 6. Override settings? N

# Add your Real-Debrid API key:
npx vercel env add REALDEBRID_API_KEY
# Enter your API key when prompted
# Select all environments (Production, Preview, Development)

# Deploy to production:
npx vercel --prod
```

## Option 2: Deploy via GitHub (Easiest)

1. **Push to GitHub:**
```bash
# Create a new repository on GitHub.com, then:
git remote add origin https://github.com/YOUR_USERNAME/roku-realdebrid.git
git push -u origin main
```

2. **Connect to Vercel:**
- Go to [vercel.com](https://vercel.com)
- Click "New Project"
- Import your GitHub repository
- Add environment variable:
  - Name: `REALDEBRID_API_KEY`
  - Value: Your Real-Debrid API key
- Click "Deploy"

## Option 3: Deploy with Vercel Button

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/YOUR_USERNAME/roku-realdebrid&env=REALDEBRID_API_KEY&envDescription=Your%20Real-Debrid%20API%20key&project-name=roku-realdebrid)

## 📱 After Deployment

Your app will be available at:
```
https://roku-realdebrid.vercel.app
```

### Update Your Roku App

In your Roku BrightScript code (`source/config.brs`), update:
```brightscript
function GetAPIBaseURL()
    return "https://roku-realdebrid.vercel.app/api"
end function
```

### Test Your Deployment

1. **Web UI Test:**
   - Visit: `https://roku-realdebrid.vercel.app`
   - Search for movies
   - Test streaming

2. **API Test:**
   ```bash
   curl https://roku-realdebrid.vercel.app/api/health
   # Should return: {"status":"healthy","service":"roku-realdebrid"}
   ```

## 🔑 Getting Your Real-Debrid API Key

1. Go to [real-debrid.com/apitoken](https://real-debrid.com/apitoken)
2. Log in to your account
3. Copy your API token
4. Use this token for `REALDEBRID_API_KEY`

## ⚡ Features After Deployment

- ✅ **Always Available** - No need to run local server
- ✅ **Auto-scaling** - Handles traffic automatically  
- ✅ **Global CDN** - Fast response worldwide
- ✅ **SSL/HTTPS** - Secure by default
- ✅ **Zero maintenance** - Vercel handles everything

## 🆓 Cost

**Completely FREE** for your usage:
- Vercel Free Tier: 100GB bandwidth/month
- Your app uses: ~25KB per search
- That's **4 million searches** per month free!

## 🎬 How It Works

```
Roku → Vercel (Search) → Real-Debrid API
           ↓
      Stream URL
           ↓
Roku ← Real-Debrid CDN (Direct Stream)
```

Your Vercel server only handles searches. Video streams go directly from Real-Debrid to Roku!

## 📞 Support

If you have issues:
1. Check Vercel dashboard for logs
2. Verify REALDEBRID_API_KEY is set
3. Test with: `curl https://your-app.vercel.app/api/user`

---

**That's it!** Your Roku app will work exactly like Torrentio - cloud-hosted, always available, completely free! 🎉