#!/usr/bin/env bash
# ==============================================================================
# RICK AGENT TERMINAL (StrikerPi 24/7 Edge Hub - 192.168.178.86)
# ==============================================================================
set -u

BASE_DIR="/opt/rick-agent"
INBOX_DIR="${BASE_DIR}/inbox"
OUTBOX_DIR="${BASE_DIR}/outbox"
GIT_BARE="/srv/git/simrig.git"

mkdir -p "${INBOX_DIR}" "${OUTBOX_DIR}" "${BASE_DIR}/logs"

BLUE='\033[0;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m'

MODE="HOST-LOKAL"
if [[ -n "${SSH_CONNECTION:-}" ]]; then
    MODE="SSH-CLIENT ($(echo "${SSH_CONNECTION}" | awk '{print $1}'))"
fi

check_port() {
    local host="$1"
    local port="$2"
    if timeout 1 bash -c "cat < /dev/null > /dev/tcp/${host}/${port}" 2>/dev/null; then
        echo -e "${GREEN}ONLINE${NC}"
    else
        echo -e "${RED}OFFLINE${NC}"
    fi
}

show_status() {
    clear 2>/dev/null || true
    echo -e "${BLUE}=================================================================${NC}"
    echo -e " RICK AGENT KONSOLE  |  StrikerPi 24/7 Edge Hub (192.168.178.86)"
    echo -e " Modus: ${CYAN}${MODE}${NC}  |  Arch Linux ARM ($(uname -m))"
    echo -e "${BLUE}=================================================================${NC}"
    echo ""
    echo -e "  ${CYAN}Systemd Services:${NC}"
    echo -e "    caddy.service           : $(systemctl is-active caddy.service 2>/dev/null || echo unknown)"
    echo -e "    gitlabor-api.service    : $(systemctl is-active gitlabor-api.service 2>/dev/null || echo unknown)"
    echo -e "    telemetry-relay.service : $(systemctl is-active telemetry-relay.service 2>/dev/null || echo unknown)"
    echo -e "    mosquitto.service       : $(systemctl is-active mosquitto.service 2>/dev/null || echo unknown)"
    echo -e "    rick-agent.service      : $(systemctl is-active rick-agent.service 2>/dev/null || echo unknown)"
    echo ""
    echo -e "  ${CYAN}LAN & Port-Matrix:${NC}"
    echo -e "    StrikerPi Caddy (:80)   : $(check_port 127.0.0.1 80)"
    echo -e "    GitLabor API    (:8085) : $(check_port 127.0.0.1 8085)"
    echo -e "    StrikerPi Relay (:8080) : $(check_port 127.0.0.1 8080)"
    echo -e "    StrikerPi MQTT  (:1883) : $(check_port 127.0.0.1 1883)"
    echo -e "    SimRacer SSH    (:22)   : $(check_port 192.168.178.68 22)"
    echo -e "    SimRacer Stream (:8090) : $(check_port 192.168.178.68 8090)"
    echo -e "    Sandbox VNC     (:8006) : $(check_port 192.168.178.68 8006)"
    echo -e "    Sandbox SSH     (:2222) : $(check_port 192.168.178.68 2222)"
    echo -e "    Archibald SSH   (:22)   : $(check_port 192.168.178.98 22)"
    echo ""
    if [[ -d "${GIT_BARE}" ]]; then
        local last_commit
        last_commit=$(git --git-dir="${GIT_BARE}" log -1 --oneline 2>/dev/null || echo "(noch keine Commits)")
        echo -e "  ${CYAN}Bare-Git-Hub:${NC} ${GIT_BARE} -> ${GRAY}${last_commit}${NC}"
    fi
    echo -e "  ${CYAN}Git-Labor Web:${NC} http://192.168.178.86/  (Root: /srv/git-labor/web)"
    echo -e "${BLUE}-----------------------------------------------------------------${NC}"
}

show_help() {
    echo -e "${CYAN}Verfuegbare Befehle:${NC}"
    echo "  status          - Zeigt Live-Status (Services, LAN-Matrix, Caddy, Git)"
    echo "  caddy           - Zeigt Caddy-Konfiguration, Validierung & Access-Log"
    echo "  caddy-reload    - Validiert Caddyfile und laedt caddy.service neu"
    echo "  build-ts        - Kompiliert alle TypeScript-Projekte unter /srv/git-labor/web"
    echo "  relay           - Zeigt detaillierten JSON-Status von :8080/api/status"
    echo "  restart-relay   - Startet telemetry-relay.service neu"
    echo "  mqtt <MODE>     - Publiziert simrig/mode (ENGINEERING | LIVE_RACE | PITBOX_SETUP)"
    echo "  git             - Zeigt letzte 10 Commits in /srv/git/simrig.git"
    echo "  logs            - Zeigt letzte 30 Zeilen von caddy, gitlabor-api & rick-agent"
    echo "  inbox <TEXT>    - Sendet Test-Task in /opt/rick-agent/inbox"
    echo "  help            - Diese Hilfe"
    echo "  exit            - Konsole beenden (systemd-Dienste laufen weiter)"
}

show_status
show_help

while true; do
    echo ""
    read -rp $'\033[1;34mRick@StrikerPi>\033[0m ' cmd arg || break
    case "${cmd}" in
        "" )
            ;;
        status|s)
            show_status
            ;;
        caddy)
            caddy validate --config /etc/caddy/Caddyfile
            echo "--- /etc/caddy/conf.d/git-labor.caddy ---"
            cat /etc/caddy/conf.d/git-labor.caddy 2>/dev/null || true
            echo "--- Letzte 5 Access-Log-Eintraege ---"
            tail -n 5 /var/log/caddy/gitlabor-access.log 2>/dev/null || echo "(noch keine Requests)"
            ;;
        caddy-reload)
            caddy validate --config /etc/caddy/Caddyfile && systemctl reload caddy.service && echo -e "${GREEN}Caddy neu geladen.${NC}"
            ;;
        build-ts)
            ts=$(date +%Y%m%d_%H%M%S)
            printf '{"task_id":"cli_build_%s","sender":"CLI","action":"build_ts_labs"}\n' "${ts}" > "${INBOX_DIR}/task_build_${ts}.json"
            echo -e "${GREEN}TypeScript-Build-Task an @rick gesendet.${NC}"
            ;;
        relay)
            curl -sf http://127.0.0.1:8080/api/status | python3 -m json.tool 2>/dev/null || echo -e "${RED}Relay nicht erreichbar.${NC}"
            ;;
        restart-relay)
            systemctl restart telemetry-relay.service && echo -e "${GREEN}telemetry-relay.service neu gestartet.${NC}"
            ;;
        mqtt)
            mode_val="${arg:-ENGINEERING}"
            mosquitto_pub -h 127.0.0.1 -t "simrig/mode" -m "${mode_val}" && echo -e "${GREEN}MQTT simrig/mode=${mode_val} gesendet.${NC}"
            ;;
        git)
            git --git-dir="${GIT_BARE}" log -n 10 --oneline 2>/dev/null || echo "(Keine Commits)"
            ;;
        logs)
            journalctl -u caddy.service -u gitlabor-api.service -u telemetry-relay.service -u rick-agent.service -n 30 --no-pager
            ;;
        inbox)
            if [[ -z "${arg:-}" ]]; then
                echo -e "${YELLOW}Usage: inbox <Nachricht>${NC}"
            else
                ts=$(date +%Y%m%d_%H%M%S)
                printf '{"task_id":"cli_%s","sender":"CLI","action":"note","prompt":"%s"}\n' "${ts}" "${arg}" > "${INBOX_DIR}/task_${ts}.json"
                echo -e "${GREEN}Task gespeichert: task_${ts}.json${NC}"
            fi
            ;;
        help|h|\?)
            show_help
            ;;
        exit|quit|q)
            echo -e "${GRAY}Beende Rick Konsole (Hintergrunddienste laufen weiter)...${NC}"
            break
            ;;
        *)
            echo -e "${YELLOW}Unbekannter Befehl '${cmd}'. Nutze 'help'.${NC}"
            ;;
    esac
done
