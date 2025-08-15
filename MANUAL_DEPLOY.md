# 🚀 Manual Deployment Instructions

## Vercel CLI is Installed and Ready!

Your Vercel CLI is installed at: `$HOME/.npm-global/bin/vercel`

## Step-by-Step Deployment:

### 1. Login to Vercel
```bash
$HOME/.npm-global/bin/vercel login
```
- Choose "Continue with GitHub" (recommended)
- Follow the browser login process

### 2. Deploy Your App
```bash
$HOME/.npm-global/bin/vercel
```
- When prompted for "Set up and deploy?": Choose **Y**
- When prompted for "Which scope?": Choose your account
- When prompted for "Link to existing project?": Choose **N**
- When prompted for project name: Enter **roku-realdebrid** (or press Enter for default)
- When prompted for directory: Press **Enter** (use current directory)
- When prompted to override settings: Choose **N**

### 3. Add Your Real-Debrid API Key
```bash
$HOME/.npm-global/bin/vercel env add REALDEBRID_API_KEY
```
- When prompted for value: Paste your Real-Debrid API key
- Choose all environments: **Production**, **Preview**, **Development**

### 4. Deploy to Production
```bash
$HOME/.npm-global/bin/vercel --prod
```

## 📱 After Deployment

You'll get a URL like: `https://roku-realdebrid-xxxx.vercel.app`

### Update Your Roku App
Edit `source/config.brs`:
```brightscript
function GetAPIBaseURL()
    return "https://your-vercel-url.vercel.app/api"
end function
```

### Test Your Deployment
1. Visit your Vercel URL in browser
2. Try searching for movies
3. Test the "Stream Now" functionality

## 🔧 Useful Commands

| Command | Purpose |
|---------|---------|
| `$HOME/.npm-global/bin/vercel` | Deploy preview |
| `$HOME/.npm-global/bin/vercel --prod` | Deploy production |
| `$HOME/.npm-global/bin/vercel env ls` | List environment variables |
| `$HOME/.npm-global/bin/vercel logs` | View deployment logs |
| `$HOME/.npm-global/bin/vercel domains` | Manage domains |

## 💡 Pro Tips

1. **Bookmark your Vercel dashboard**: After login, go to vercel.com/dashboard
2. **Set up custom domain** (optional): Use vercel.com domain settings
3. **Monitor usage**: Check analytics in Vercel dashboard
4. **Auto-redeploy**: Every git push will trigger new deployment

## 🆓 What You Get FREE

- **Unlimited deployments**
- **100GB bandwidth/month** (enough for 4 million searches!)
- **Global CDN**
- **Automatic SSL**
- **Custom domains**
- **Analytics**

## 🎬 Your App Features

Once deployed, your Roku app will have:
- ✅ **Always-on availability**
- ✅ **Global fast access**
- ✅ **Real-Debrid integration**
- ✅ **Multi-indexer search** (TPB, YTS, EZTV, RARBG, etc.)
- ✅ **Direct streaming** (video bypasses Vercel)
- ✅ **Zero maintenance**

---

**Ready to deploy? Just run:**
```bash
$HOME/.npm-global/bin/vercel login
$HOME/.npm-global/bin/vercel
```

Your Roku Real-Debrid app will be live in minutes! 🎉