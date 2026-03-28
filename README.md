# GitHub Reputation Bot

> **Template Repository**: This is a fork of [archestra-ai/reputation-bot](https://github.com/archestra-ai/reputation-bot) - adapted to be a drop-in template for any GitHub repository.

Bot that calculates and displays contributor reputation on PRs and issues. PRs from users with low reputation are automatically closed.

## Features

- **Configurable Reputation**: Points system based on GitHub activity
- **Auto-Close PRs**: Automatically closes PRs with score below threshold
- **Direct Links**: All statistics link to filtered GitHub searches
- **Smart Updates**: Only updates comments when new participants join
- **100% Configurable**: Works with any repository via env vars

## Points System

| Action | Points |
|--------|--------|
| PR Merged | +20 |
| PR Open | +3 |
| PR Closed (without merge) | -10 |
| Issue Created | +5 |
| Core Team 👍 | +15 |
| Core Team 👎 | -50 |

> **Note**: Scores can be negative!

## Configuration

### Environment Variables

```bash
# Required
GITHUB_TOKEN=ghp_xxxxxxxxxxxxx          # Personal Access Token
GITHUB_WEBHOOK_SECRET=your-secret        # Webhook signature verification

# Optional (with defaults)
REPO_NAME=owner/repo                     # Repository to monitor
CORE_TEAM_MEMBERS=user1,user2            # Core team members list
REPUTATION_THRESHOLD=-80                 # Threshold for auto-close
BOT_NAME=Reputation Bot                  # Bot display name
BOT_FOOTER="Gen by [Bot](link)"          # Comment footer
```

### GitHub Webhook

Configure in Settings > Webhooks of your repository:

- **Payload URL**: `https://your-bot-url/webhook`
- **Content type**: `application/json`
- **Secret**: Same value as `GITHUB_WEBHOOK_SECRET`
- **Events**: `pull_requests`, `issues`, `issue_comments`

## Deploy (Google Cloud Run)

```bash
# Build
docker build --platform linux/amd64 -t gcr.io/PROJECT/reputation-bot .

# Push
docker push gcr.io/PROJECT/reputation-bot

# Deploy
gcloud run deploy reputation-bot \
  --image gcr.io/PROJECT/reputation-bot \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars="^@^GITHUB_TOKEN=TOKEN@GITHUB_WEBHOOK_SECRET=SECRET@CORE_TEAM_MEMBERS=user1@REPO_NAME=owner/repo"
```

## Local Development

```bash
# Setup
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run
export GITHUB_TOKEN=your-token
export GITHUB_WEBHOOK_SECRET=test-secret
export CORE_TEAM_MEMBERS=your-username
export REPO_NAME=owner/repo
python app.py

# Test
python test_webhook.py
```

## Project Structure

```
reputation-bot/
├── app.py              # Flask app + webhook handlers
├── github_client.py    # GitHub API client
├── reputation.py       # Scoring logic
├── Dockerfile          # Container
├── requirements.txt    # Dependencies
├── install.sh          # Local setup script
├── deploy.sh           # GCP deploy script
├── .env.example        # Environment template
└── SKILL.md            # For OpenCLAW agents
```

## For OpenCLAW Agents

This bot is designed to be easily implementable as a skill. See `SKILL.md` for instructions.
