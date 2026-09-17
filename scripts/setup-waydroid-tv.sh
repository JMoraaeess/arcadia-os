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

# Detecção e compatibilidade automática de GPU (NVIDIA, AMD, Intel e APUs)
if lspci 2>/dev/null | grep -iE 'vga|3d' | grep -iq nvidia; then
    log_info "   -> GPU NVIDIA detectada! Aplicando perfil de compatibilidade para drivers proprietários..."
    waydroid prop set ro.hardware.gralloc default || true
    waydroid prop set ro.hardware.egl swiftshader || true
elif lspci 2>/dev/null | grep -iE 'vga|3d' | grep -iqE 'amd|ati|radeon'; then
    log_info "   -> GPU AMD / APU Ryzen detectada! Utilizando aceleração direta Mesa DRI3/KMS de alta performance."
elif lspci 2>/dev/null | grep -iE 'vga|3d' | grep -iq intel; then
    log_info "   -> GPU Intel / Gráficos Integrados detectados! Utilizando aceleração direta Mesa Intel."
fi

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

log_info "7. Baixando APKs essenciais de Smart TV (Lojas e Players)..."
mkdir -p "$BUILD_DIR/apks"

# Launcher principal de TV (leve, sem anúncios e com canais dinâmicos)
log_info "   -> Baixando Projectivy Launcher..."
curl -sL -o "$BUILD_DIR/apks/Projectivy.apk" "https://github.com/spocky/marmite/releases/latest/download/Projectivy_Launcher.apk" || true

# Loja de Aplicativos para TV (Aurora Store - Acessa catálogo da Google Play Store com interface de TV)
log_info "   -> Baixando Aurora Store (Loja de Aplicativos Google Play TV)..."
curl -sL -o "$BUILD_DIR/apks/AuroraStore.apk" "https://f-droid.org/repo/com.aurora.store_76.apk" || true

# YouTube dedicado para Smart TV (SmartTube 4K sem anúncios e navegação por controle)
log_info "   -> Baixando SmartTube 4K..."
curl -sL -o "$BUILD_DIR/apks/SmartTube.apk" "https://github.com/yuliskov/SmartTube/releases/download/latest/smarttube_stable.apk" || true

log_info "8. Instalando APKs no Arcadia TV..."
waydroid app install "$BUILD_DIR/apks/Projectivy.apk" 2>/dev/null || true
waydroid app install "$BUILD_DIR/apks/AuroraStore.apk" 2>/dev/null || true
waydroid app install "$BUILD_DIR/apks/SmartTube.apk" 2>/dev/null || true

log_info "9. Verificando Certificação do Google Play Protect..."
log_info "Caso a Google Play Store oficial mostre 'Dispositivo não certificado':"
if [ -f "$BUILD_DIR/waydroid_script/main.py" ]; then
    echo "----------------------------------------------------------------------"
    echo "ID do Dispositivo para registro no Google Play Services:"
    sudo "$BUILD_DIR/waydroid_script/venv/bin/python3" "$BUILD_DIR/waydroid_script/main.py" certified || true
    echo "Acesse https://www.google.com/android/uncertified/ para registrar se necessário."
    echo "----------------------------------------------------------------------"
fi

log_success "Ambiente Arcadia TV configurado com sucesso! Loja de aplicativos e apps de TV prontos."

