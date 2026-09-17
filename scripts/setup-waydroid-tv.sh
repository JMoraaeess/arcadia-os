#!/usr/bin/env bash
# ==============================================================================
# ArcadiaOS: Provisionamento do Contêiner Android TV
# Instala: Tradução ARM (libndk) + Magisk + Spoofing de Hardware + Apps de TV
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCESSO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[AVISO]${NC} $1"; }
log_error() { echo -e "${RED}[ERRO]${NC} $1"; }

BUILD_DIR="$HOME/.arcadia/build"
mkdir -p "$BUILD_DIR"

log_info "1. Configurando serviços do subsistema Android TV..."
sudo systemctl enable --now waydroid-container || true

log_info "2. Inicializando imagem do sistema..."
if [ ! -d "/var/lib/waydroid/images" ] || [ -z "$(ls -A /var/lib/waydroid/images 2>/dev/null)" ]; then
    sudo waydroid init -s GAPPS || sudo waydroid init
fi

log_info "3. Definindo propriedades de tela para TV (1080p, DPI 320)..."
waydroid prop set persist.waydroid.width 1920
waydroid prop set persist.waydroid.height 1080
waydroid prop set persist.waydroid.dpi 320
waydroid prop set persist.waydroid.ui tv

log_info "4. Clonando utilitário de injeção (GApps + libndk + Magisk)..."
cd "$BUILD_DIR"
if [ ! -d "waydroid_script" ]; then
    git clone https://github.com/casualsnek/waydroid_script.git
fi
cd waydroid_script
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

log_info "5. Injetando tradutor ARM (libndk) e Magisk Root..."
sudo "$BUILD_DIR/waydroid_script/venv/bin/python3" main.py -n -m || {
    log_warn "Aviso na injeção. Continuando..."
}
deactivate

log_info "6. Aplicando perfil de Hardware: NVIDIA SHIELD Android TV..."
while IFS='=' read -r key value || [ -n "$key" ]; do
    [[ "$key" =~ ^#.*$ ]] && continue
    [[ -z "$key" ]] && continue
    waydroid prop set "$key" "$value"
done < "$ROOT_DIR/config/shield-props.prop"

log_info "7. Baixando APKs recomendados (Projectivy Launcher & SmartTube)..."
mkdir -p "$BUILD_DIR/apks"
curl -sL -o "$BUILD_DIR/apks/Projectivy.apk" "https://github.com/spocky/marmite/releases/latest/download/Projectivy_Launcher.apk" || true
curl -sL -o "$BUILD_DIR/apks/SmartTube.apk" "https://github.com/yuliskov/SmartTube/releases/download/latest/smarttube_stable.apk" || true

log_info "8. Instalando APKs no Arcadia TV..."
waydroid app install "$BUILD_DIR/apks/Projectivy.apk" 2>/dev/null || true
waydroid app install "$BUILD_DIR/apks/SmartTube.apk" 2>/dev/null || true

log_success "Ambiente Arcadia TV configurado com sucesso!"
