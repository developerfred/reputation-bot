# GitHub Reputation Bot

> Forked from [archestra-ai/reputation-bot](https://github.com/archestra-ai/reputation-bot) - Template repository for easy deployment to any GitHub repository.

## For OpenCLAW Agents

This is a **plug-and-play template** for adding a reputation bot to any GitHub repository. Configure via environment variables and deploy.

## Configuration (Environment Variables)

| Variable | Description | Default |
|----------|-------------|---------|
| `REPO_NAME` | Repository in `owner/name` format | `archestra-ai/archestra` |
| `GITHUB_TOKEN` | GitHub Personal Access Token with `repo` scope | **Required** |
| `GITHUB_WEBHOOK_SECRET` | Secret for webhook signature verification | **Required** |
| `CORE_TEAM_MEMBERS` | Comma-separated list of core team members | (empty) |
| `REPUTATION_THRESHOLD` | Minimum score to keep PR open | `-80` |
| `BOT_NAME` | Bot display name | `Reputation Bot` |
| `BOT_FOOTER` | Markdown footer with bot repo link | (auto-generated) |
| `PORT` | HTTP port | `8080` |

## Points System

| Action | Points |
|--------|--------|
| Merged PRs | +20 |
| Open PRs | +3 |
| Closed PRs (without merge) | -10 |
| Created Issues | +5 |
| Core Team positive reactions | +15 |
| Core Team negative reactions | -50 |

## Quick Deploy (Google Cloud Run)

```bash
# Build
docker build --platform linux/amd64 -t gcr.io/PROJECT_ID/reputation-bot .

# Deploy
gcloud run deploy reputation-bot \
  --image gcr.io/PROJECT_ID/reputation-bot \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars="^@^GITHUB_TOKEN=TOKEN@GITHUB_WEBHOOK_SECRET=SECRET@CORE_TEAM_MEMBERS=user1,user2@REPO_NAME=owner/repo@REPUTATION_THRESHOLD=-80"
```

## Webhook Events

The bot responds to:
- `pull_request` (opened, reopened)
- `issues` (opened, reopened)
- `issue_comment` (created)

## To Create Your Own Fork

1. Clone this repository
2. Update `REPO_NAME` to your repository
3. Configure environment variables
4. Deploy with your GitHub token
5. Configure GitHub webhook pointing to your endpoint
