# GitHub Reputation Bot Skill

Template de bot GitHub para calcular e exibir reputação de contribuidores em PRs e issues.

## Para OpenCLAW Agents

Este é um **template plug-and-play** para adicionar um bot de reputação a qualquer repositório GitHub. Configure via variáveis de ambiente e deploy.

## Configuração (Environment Variables)

| Variável | Descrição | Default |
|----------|-----------|---------|
| `REPO_NAME` | Repositório no formato `owner/name` | `archestra-ai/archestra` |
| `GITHUB_TOKEN` | Personal Access Token GitHub com scope `repo` | **Obrigatório** |
| `GITHUB_WEBHOOK_SECRET` | Secret para verificar assinaturas do webhook | **Obrigatório** |
| `CORE_TEAM_MEMBERS` | Lista separada por vírgulas de membros core | (vazio) |
| `REPUTATION_THRESHOLD` | Score mínimo para manter PR aberto | `-80` |
| `BOT_NAME` | Nome do bot para exibição | `Reputation Bot` |
| `BOT_FOOTER` | Footer markdown com link do repo do bot | (auto-gerado) |
| `PORT` | Porta HTTP | `8080` |

## Pontuação

- **PRs Merged**: +20 pontos
- **PRs Abertos**: +3 pontos
- **PRs Fechados sem merge**: -10 pontos
- **Issues criados**: +5 pontos
- **Reações positivas do Core Team**: +15 pontos
- **Reações negativas do Core Team**: -50 pontos

## Deploy Rápido (Google Cloud Run)

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

O bot responde a:
- `pull_request` (opened, reopened)
- `issues` (opened, reopened)
- `issue_comment` (created)

## Para Criar Seu Próprio Fork

1. Clone este repositório
2. Atualize `REPO_NAME` para seu repositório
3. Configure as variáveis de ambiente
4. Deploy com seu token GitHub
5. Configure o webhook no GitHub apontando para seu endpoint
