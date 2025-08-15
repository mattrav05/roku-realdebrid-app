# Keep Your Render App Always Awake

## Option 1: UptimeRobot (Recommended)
1. Go to [uptimerobot.com](https://uptimerobot.com)
2. Sign up free
3. Add new monitor:
   - Type: HTTP(s)
   - URL: https://roku-realdebrid.onrender.com/api/health
   - Interval: 5 minutes
4. Save - your app will never sleep!

## Option 2: GitHub Actions (Alternative)
Create `.github/workflows/keep-alive.yml`:

```yaml
name: Keep Alive
on:
  schedule:
    - cron: '*/5 * * * *'  # Every 5 minutes
jobs:
  ping:
    runs-on: ubuntu-latest
    steps:
      - name: Ping server
        run: curl https://roku-realdebrid.onrender.com/api/health
```

## Option 3: Cron-job.org
1. Go to [cron-job.org](https://cron-job.org)
2. Create free account
3. Add job to GET your health endpoint every 5 min