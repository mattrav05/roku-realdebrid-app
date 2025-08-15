# 🚀 Deploy to Vercel via GitHub

Since your local GitHub CLI path isn't configured, here are the **super simple** steps:

## Step 1: Create GitHub Repository

**Option A: Using GitHub CLI (if available in Windows)**
Open PowerShell/Command Prompt and run:
```bash
gh repo create roku-realdebrid-app --public --source=. --remote=origin --push
```

**Option B: Manual GitHub Creation**
1. Go to [github.com/new](https://github.com/new)
2. Repository name: `roku-realdebrid-app`
3. Set to **Public**
4. Don't initialize with README (we have files already)
5. Click "Create repository"

Then run these commands:
```bash
git remote add origin https://github.com/YOUR_USERNAME/roku-realdebrid-app.git
git branch -M main
git push -u origin main
```

## Step 2: Deploy to Vercel via GitHub

1. **Go to [vercel.com](https://vercel.com)**
2. **Sign up/Login** (use GitHub account for easiest setup)
3. **Click "New Project"**
4. **Import from GitHub**: Select your `roku-realdebrid-app` repository
5. **Configure Project**:
   - Project Name: `roku-realdebrid-app`
   - Framework: Leave as "Other"
   - Root Directory: `./`
   - Build Command: Leave default
   - Output Directory: Leave default
6. **Add Environment Variable**:
   - Name: `REALDEBRID_API_KEY`
   - Value: (paste your Real-Debrid API key)
7. **Click "Deploy"**

## Step 3: Get Your URL

Vercel will give you a URL like:
```
https://roku-realdebrid-app.vercel.app
```

## Step 4: Auto-Deploy Setup

✅ **Already configured!** Every time you push to GitHub:
```bash
git add .
git commit -m "Update app"
git push
```

Vercel will automatically redeploy! 🎉

## Step 5: Update Roku App

Edit `source/config.brs`:
```brightscript
function GetAPIBaseURL()
    return "https://roku-realdebrid-app.vercel.app/api"
end function
```

---

**That's it!** Your app will be:
- ✅ **Always available** at your Vercel URL
- ✅ **Auto-updating** when you push to GitHub  
- ✅ **Completely free** for your usage
- ✅ **Global CDN** for fast access worldwide

**Just like Torrentio, but yours!** 🎬