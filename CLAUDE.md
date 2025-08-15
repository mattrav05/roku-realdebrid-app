# Claude Code Project Memory

## Deployment Status
- ✅ **GitHub Repository**: https://github.com/mattrav05/roku-realdebrid-app
- ✅ **Vercel Deployment**: https://roku-realdebrid-korve7cqq-matthew-travis-projects.vercel.app
- ✅ **GitHub CLI**: Authenticated as mattrav05
- ✅ **Vercel CLI**: Authenticated and linked to project
- ✅ **Real-Debrid API**: Configured with API key

## Important Notes
- Git repository is connected and configured
- **For future deployments**: Only need to push to GitHub (git push)
- Vercel auto-deploys from GitHub repo
- No need to run vercel CLI commands again

## Project Structure
- **Backend**: Node.js Express server (server.js)
- **Frontend**: Web UI in /public folder
- **Roku Components**: BrightScript files in /components and /source
- **API**: Real-Debrid proxy with multi-indexer torrent search

## Commands for Future Updates
```bash
# Make changes, then:
git add .
git commit -m "Your changes"
git push  # This triggers auto-deployment to Vercel
```

## Environment
- Real-Debrid API Key: Configured in Vercel
- Node.js dependencies: All installed
- Vercel config: Set up in vercel.json