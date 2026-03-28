# GitHub Reputation Bot

Bot que calcula e exibe reputação de contribuidores em PRs e issues. PRs de usuários com reputação baixa são automaticamente fechados.

## Características

- **Reputação Configurável**: Sistema de pontos baseado em atividade GitHub
- **Auto-Fechamento de PRs**: Fecha automaticamente PRs com score abaixo do threshold
- **Links Diretos**: Todas as estatísticas linkam para buscas filtradas no GitHub
- **Smart Updates**: Só atualiza comments quando há novos participantes
- **100% Configurável**: Funciona com qualquer repositório via env vars

## Sistema de Pontos

| Ação | Pontos |
|------|--------|
| PR Merged | +20 |
| PR Aberto | +3 |
| PR Fechado (sem merge) | -10 |
| Issue Criado | +5 |
| Reactions positivas do Core | +15 |
| Reactions negativas do Core | -50 |

> **Nota**: Scores podem ser negativos!

## Configuração

### Environment Variables

```bash
# Obrigatórios
GITHUB_TOKEN=ghp_xxxxxxxxxxxxx          # Personal Access Token
GITHUB_WEBHOOK_SECRET=your-secret        # Para verificar webhooks

# Opcionais (com defaults)
REPO_NAME=owner/repo                     # Repositório monitorado
CORE_TEAM_MEMBERS=user1,user2            # Lista de membros core
REPUTATION_THRESHOLD=-80                 # Threshold para auto-fechar
BOT_NAME=Reputation Bot                  # Nome do bot
BOT_FOOTER="Gen by [Bot](link)"          # Footer dos comments
```

### GitHub Webhook

Configure no Settings > Webhooks do seu repositório:

- **Payload URL**: `https://your-bot-url/webhook`
- **Content type**: `application/json`
- **Secret**: Mesmo valor de `GITHUB_WEBHOOK_SECRET`
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

## Desenvolvimento Local

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

## Estrutura do Projeto

```
reputation-bot/
├── app.py              # Flask app + webhook handlers
├── github_client.py    # Cliente GitHub API
├── reputation.py       # Lógica de pontuação
├── Dockerfile          # Container
├── requirements.txt    # Dependências
├── install.sh          # Script de setup local
├── deploy.sh           # Script de deploy GCR
├── .env.example        # Template de variáveis
└── SKILL.md            # Para OpenCLAW agents
```

## Para OpenCLAW Agents

Este bot é designed para ser facilmente implementável como skill. Veja `SKILL.md` para instruções.
