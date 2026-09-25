# Personal assistant – n8n maintenance tools

Helper scripts for maintaining a self-hosted n8n assistant.
This repository is public: it holds tooling only, never workflow exports,
personal data or credentials.

## Scripts

| Script | What it does | Changes anything? |
| --- | --- | --- |
| `scripts/n8n-backup.sh [id ...]` | Saves each workflow to `backups/<id>/<UTC time>.json` (git-ignored). Run before every edit. | No |
| `scripts/n8n-audit.sh [n]` | Lists workflows, triggers, credential *names*, approval nodes and the last `n` execution results. | No |

Both need two environment variables, set in the Claude environment settings
(not pasted into chat):

- `N8N_BASE_URL` – the n8n editor URL
- `N8N_API_KEY` – created in n8n under **Settings → n8n API**

## Restoring a backup

In n8n, open the workflow, choose **… → Import from File**, and select the
backup JSON. Credentials are re-linked by reference; no secrets are stored in
the backup.
