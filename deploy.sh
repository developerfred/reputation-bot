#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --project GCP_PROJECT_ID    Google Cloud project ID (required)"
    echo "  -r, --region REGION             Region (default: us-central1)"
    echo "  -n, --name NAME                 Service name (default: reputation-bot)"
    echo "  -e, --env FILE                  Env file with variables (default: .env)"
    echo "  -h, --help                      Show this help"
    exit 1
}

# Defaults
REGION="us-central1"
SERVICE_NAME="reputation-bot"
ENV_FILE=".env"

# Parse args
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--project)
            PROJECT_ID="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -n|--name)
            SERVICE_NAME="$2"
            shift 2
            ;;
        -e|--env)
            ENV_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Check required params
if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}❌ GCP_PROJECT_ID is required${NC}"
    usage
fi

# Load env from file if exists
if [ -f "$ENV_FILE" ]; then
    echo "📂 Loading environment from $ENV_FILE..."
    set -a
    source "$ENV_FILE"
    set +a
fi

# Validate required env vars
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}❌ GITHUB_TOKEN is required in $ENV_FILE${NC}"
    exit 1
fi

if [ -z "$GITHUB_WEBHOOK_SECRET" ]; then
    echo -e "${RED}❌ GITHUB_WEBHOOK_SECRET is required in $ENV_FILE${NC}"
    exit 1
fi

REPO_NAME="${REPO_NAME:-archestra-ai/archestra}"
CORE_TEAM_MEMBERS="${CORE_TEAM_MEMBERS:-}"
REPUTATION_THRESHOLD="${REPUTATION_THRESHOLD:--80}"

echo -e "${GREEN}🚀 Deploying Reputation Bot to Google Cloud Run${NC}"
echo "  Project: $PROJECT_ID"
echo "  Region: $REGION"
echo "  Service: $SERVICE_NAME"
echo "  Repo: $REPO_NAME"

# Build image name
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME"

# Build
echo ""
echo -e "${YELLOW}📦 Building Docker image...${NC}"
docker build --platform linux/amd64 -t "$IMAGE_NAME" .

# Push
echo ""
echo -e "${YELLOW}⬆️  Pushing to Google Container Registry...${NC}"
docker push "$IMAGE_NAME"

# Deploy
echo ""
echo -e "${YELLOW}🚀 Deploying to Cloud Run...${NC}"

# Build env vars string (handle commas in CORE_TEAM_MEMBERS)
ENV_VARS="^@^GITHUB_TOKEN=$GITHUB_TOKEN@GITHUB_WEBHOOK_SECRET=$GITHUB_WEBHOOK_SECRET@REPO_NAME=$REPO_NAME@REPUTATION_THRESHOLD=$REPUTATION_THRESHOLD"

if [ -n "$CORE_TEAM_MEMBERS" ]; then
    ENV_VARS="$ENV_VARS@CORE_TEAM_MEMBERS=$CORE_TEAM_MEMBERS"
fi

gcloud run deploy "$SERVICE_NAME" \
    --image "$IMAGE_NAME" \
    --platform managed \
    --region "$REGION" \
    --allow-unauthenticated \
    --set-env-vars="$ENV_VARS" \
    --memory 512Mi \
    --max-instances 1

echo ""
echo -e "${GREEN}✅ Deploy complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Note your service URL from the output above"
echo "  2. Go to GitHub > Settings > Webhooks"
echo "  3. Add webhook pointing to: https://YOUR-URL/webhook"
