#!/usr/bin/env bash
# ==============================================================================
# ArcadiaOS: TV Session Launcher
# Launches the Arcadia TV environment cleanly from Game Mode or Desktop
# ==============================================================================

set -e

# 1. Garantir que o serviço do contêiner está ativo
if ! systemctl is-active --quiet waydroid-container; then
    sudo systemctl start waydroid-container || true
    sleep 1
fi

# 2. Iniciar a sessão se não estiver rodando
if ! waydroid status 2>/dev/null | grep -q "RUNNING"; then
    waydroid session start &
    # Aguarda o subsistema Android responder
    for i in {1..30}; do
        if waydroid status 2>/dev/null | grep -q "RUNNING"; then
            break
        fi
        sleep 0.5
    done
fi

# 3. Lançar a interface completa de TV em tela cheia
# Se o Projectivy Launcher estiver instalado, foca nele, senão exibe a UI padrão
if waydroid app list 2>/dev/null | grep -q "com.spocky.projengmenu"; then
    waydroid app launch com.spocky.projengmenu
else
    waydroid show-full-ui
fi
