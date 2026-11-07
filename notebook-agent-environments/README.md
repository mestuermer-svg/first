# Notebook Agent Environments

Eine dedizierte Python-Notebook-Agent-Umgebung für Antigravity.

## Struktur & Setup
- **Paketmanager:** `uv`
- **Python-Version:** 3.14
- **Kernkomponenten:** `ipykernel`, `ipywidgets`
- **Beispiel-Notebook:** `agent_demo.ipynb`

## Schnellstart
```powershell
cd notebook-agent-environments
uv run python -m ipykernel install --user --name notebook-agent-env --display-name "Python (Notebook Agent Env)"
```
