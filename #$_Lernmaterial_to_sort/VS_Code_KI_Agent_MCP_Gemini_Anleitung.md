# Einrichtung eines KI-Agenten in VS Code mit MCP und Gemini

## 1\. Voraussetzungen & GitHub-Anbindung

* **Visual Studio Code**: Aktuelle Version installiert.  
* **GitHub & Copilot**:  
  * Es wird primär ein aktives GitHub-Konto mit GitHub Copilot-Abonnement/Zugriff benötigt.  
  * Installiere in VS Code die Erweiterungen **GitHub Copilot** und **GitHub Copilot Chat** und melde dich über VS Code mit deinem GitHub-Konto an.  
  * Eine lokale Git-Konfiguration oder Repository-Anbindung ist für den reinen Agenten-/MCP-Betrieb nicht zwingend erforderlich.  
* **Node.js**: Installiert (wird für viele MCP-Server und `npx` benötigt).

## 2\. MCP-Konfiguration erstellen

Erstelle die Konfigurationsdatei für den MCP-Server (z. B. unter `~/.config/mcp/config.json`).

Füge folgende Struktur ein und ersetze `DEIN_GEMINI_API_KEY` durch deinen API-Schlüssel:

{

  "mcpServers": {

    "gemini": {

      "command": "npx",

      "args": \[

        "-y",

        "@modelcontextprotocol/server-gemini"

      \],

      "env": {

        "GEMINI\_API\_KEY": "DEIN\_GEMINI\_API\_KEY"

      }

    }

  }

}

## 3\. Workspace in VS Code anbinden

1. Projektverzeichnis in Visual Studio Code öffnen.  
2. Sicherstellen, dass die MCP-Erweiterung aktiv ist, oder bei Bedarf `Developer: Reload Window` ausführen, um Konfigurationsänderungen zu laden.

## 4\. Sandbox-Umgebung (Dev Containers) einrichten

Für den isolierten Betrieb des Agenten:

1. Im Projekt-Stammverzeichnis einen Ordner namens `.devcontainer` erstellen.  
2. Darin die Konfigurationsdatei `devcontainer.json` anlegen:

{

  "name": "KI-Agent-Sandbox",

  "image": "mcr.microsoft.com/devcontainers/universal:2",

  "customizations": {

    "vscode": {

      "extensions": \[

        "GitHub.copilot",

        "GitHub.copilot-chat"

      \]

    }

  },

  "remoteUser": "vscode"

}

3. Unten links auf das Remote-Symbol klicken und **Reopen in Container** wählen. Der Agent arbeitet isoliert in der Sandbox mit MCP-Zugriff auf Gemini.

## 5\. Integration von Google Antigravity

* **Überblick**: Google Antigravity dient als agentenbasierte Plattform zur Orchestrierung und Ausführung autonomer KI-Agenten im Workspace.  
* **Installation in VS Code**:  
  1. Den VS Code Marketplace (`Ctrl+Shift+X` / `Cmd+Shift+X`) öffnen.  
  2. Nach der Erweiterung **Google Antigravity** suchen und installieren.  
* **Verbindung mit dem Google-Konto**:  
  1. Unten links auf das Accounts-Icon klicken oder in der Befehlspalette (`Ctrl+Shift+P`) den Befehl `Antigravity: Sign In with Google` ausführen.  
  2. Im Browser mit dem autorisierten Google-Konto anmelden und Zugriffsrechte bestätigen.  
* **Import und Konfiguration von MCP-Servern**:  
  * **Über Konfigurationsdatei**: MCP-Definitionen können im Projektordner unter `.antigravity/mcp.json` oder global hinterlegt werden:

{

  "mcpServers": {

    "gemini": {

      "command": "npx",

      "args": \[

        "-y",

        "@modelcontextprotocol/server-gemini"

      \],

      "env": {

        "GEMINI\_API\_KEY": "DEIN\_GEMINI\_API\_KEY"

      }

    }

  }

}

* **Über VS Code Settings / Extension UI**:  
  1. Die Antigravity-Seitenleiste in VS Code öffnen.  
  2. Den Menüpunkt **MCP Servers** aufrufen und **Import MCP Config** auswählen.  
  3. Den Pfad zur bestehenden Konfiguration (`~/.config/mcp/config.json`) angeben, um Server wie Gemini automatisch zu registrieren.