#!/usr/bin/env bash
# ==============================================================================
# ArcadiaOS: Boot Selector Launcher
# Opens the split-screen selection portal (Games vs SmartTV) on system startup
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PORTAL_DIR="$ROOT_DIR/portal"
PORT=8888
URL="http://127.0.0.1:$PORT"

# 1. Iniciar servidor do portal em segundo plano se não estiver rodando
if ! ss -tuln 2>/dev/null | grep -q ":$PORT "; then
    python3 "$PORTAL_DIR/server.py" &
    SERVER_PID=$!
    sleep 0.6
fi

# 2. Determinar o melhor navegador/compositor disponível
launch_browser() {
    # Firefox Kiosk (Nativo no Fedora / Bazzite)
    if command -v firefox &>/dev/null; then
        firefox --kiosk "$URL"
    # Chromium / Chrome Kiosk
    elif command -v chromium &>/dev/null; then
        chromium --kiosk --no-first-run --disable-infobars "$URL"
    elif command -v google-chrome &>/dev/null; then
        google-chrome --kiosk --no-first-run --disable-infobars "$URL"
    # Fallback genérico
    elif command -v xdg-open &>/dev/null; then
        xdg-open "$URL"
    else
        echo "[ArcadiaOS] Nenhum navegador encontrado para abrir o portal."
        exit 1
    fi
}

# 3. Executar em tela cheia (Gamescope se disponível, ou compositor direto)
if command -v gamescope &>/dev/null && [ -z "$GAMESCOPE_WAYLAND_DISPLAY" ]; then
    gamescope -f -w 1920 -h 1080 -- launch_browser
else
    launch_browser
fi
