#!/usr/bin/env bash
# ==============================================================================
# ArcadiaOS: Instalador Mestre Oficial
# Transforma a instalação do Bazzite na central definitiva ArcadiaOS
# ==============================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}=================================================================${NC}"
echo -e "${CYAN}              🏛️ BEM-VINDO AO INSTALADOR ARCADIAOS 🎮📺          ${NC}"
echo -e "${CYAN}=================================================================${NC}"
echo "Configurando o ecossistema unificado de Jogos AAA e Smart TV no seu PC..."
echo ""

# 1. Copiar Launcher para o PATH do sistema
echo -e "${BLUE}[1/5]${NC} Instalando binário de inicialização em /usr/local/bin..."
sudo cp "$ROOT_DIR/bin/arcadia-launcher.sh" /usr/local/bin/arcadia-launcher.sh
sudo chmod +x /usr/local/bin/arcadia-launcher.sh

# 2. Configurar Regras Udev para Controles Bluetooth
echo -e "${BLUE}[2/5]${NC} Configurando regras udev de baixa latência para controle de TV..."
sudo cp "$ROOT_DIR/config/99-bt-remote.rules" /etc/udev/rules.d/99-bt-remote.rules
sudo udevadm control --reload-rules || true
sudo udevadm trigger || true

# 3. Registrar o Atalho no Menu de Jogos da Steam
echo -e "${BLUE}[3/5]${NC} Registrando o atalho 'Arcadia TV' no Game Mode..."
mkdir -p "$HOME/.local/share/applications"
cp "$ROOT_DIR/config/arcadia-tv.desktop" "$HOME/.local/share/applications/arcadia-tv.desktop"
chmod +x "$HOME/.local/share/applications/arcadia-tv.desktop"

# 4. Executar configuração do contêiner Android TV
echo -e "${BLUE}[4/5]${NC} Executando provisionamento do Android TV (Waydroid + Spoofing)..."
bash "$ROOT_DIR/scripts/setup-waydroid-tv.sh"

# 5. Instalar o Seletor de Boot Dividido (Jogos vs SmartTV)
echo -e "${BLUE}[5/6]${NC} Instalando o Seletor de Inicialização (Arcadia Boot Portal)..."
mkdir -p "$HOME/.arcadia/bin" "$HOME/.arcadia/portal" "$HOME/.config/autostart"
cp -r "$ROOT_DIR/portal/"* "$HOME/.arcadia/portal/"
cp "$ROOT_DIR/bin/"* "$HOME/.arcadia/bin/"
chmod +x "$HOME/.arcadia/bin/"*.sh
sudo cp "$ROOT_DIR/bin/arcadia-portal.sh" /usr/local/bin/arcadia-portal || true

# Configurar Autostart para o Seletor abrir ao ligar o PC
cp "$ROOT_DIR/config/arcadia-portal.desktop" "$HOME/.config/autostart/arcadia-portal.desktop"

# 6. Pareamento do Controle
echo ""
echo -e "${BLUE}[6/6]${NC} Deseja parear o controle Bluetooth agora? (s/n)"
read -r -p "Escolha: " PAIR_CHOICE
if [[ "$PAIR_CHOICE" =~ ^[Ss]$ ]]; then
    bash "$ROOT_DIR/scripts/setup-remote.sh"
fi

echo ""
echo -e "${GREEN}=================================================================${NC}"
echo -e "${GREEN}             🎉 ARCADIAOS INSTALADO COM SUCESSO!                ${NC}"
echo -e "${GREEN}=================================================================${NC}"
echo "O sistema está pronto:"
echo "1. Ao ligar o PC, a tela dividida abrirá para escolher JOGOS ou SMART TV."
echo "2. Você pode navegar com Gamepad (Xbox/PS) ou com o Controle Remoto."
echo "3. O atalho 'Arcadia TV' também estará na sua biblioteca da Steam."
echo "================================================================="
