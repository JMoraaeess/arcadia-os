#!/usr/bin/env bash
# ==============================================================================
# ArcadiaOS: Assistente de Pareamento do Controle Remoto Bluetooth
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=================================================================${NC}"
echo -e "${BLUE}   ArcadiaOS: Assistente de Pareamento de Controle Remoto        ${NC}"
echo -e "${BLUE}=================================================================${NC}"
echo ""
echo -e "${YELLOW}Passo 1:${NC} No controle remoto, coloque-o em modo de pareamento."
echo -e "        (No controle do Chromecast, segure ${GREEN}[VOLTAR]${NC} e ${GREEN}[HOME]${NC}"
echo -e "        juntos até a luz começar a piscar)."
echo ""
read -p "Pressione [ENTER] quando a luz do controle estiver piscando..."

echo -e "${BLUE}[INFO]${NC} Escaneando dispositivos Bluetooth por 15 segundos..."
bluetoothctl power on >/dev/null 2>&1 || true
bluetoothctl default-agent >/dev/null 2>&1 || true

bluetoothctl --timeout 15 scan on || true

echo ""
echo -e "${BLUE}[INFO]${NC} Dispositivos encontrados:"
bluetoothctl devices | grep -iE "Chromecast|Remote|G9N9N|Google|BLE" || {
    echo -e "${YELLOW}[AVISO]${NC} Dispositivos recentes disponíveis:"
    bluetoothctl devices
}

echo ""
read -p "Digite o endereço MAC do controle (ex: AA:BB:CC:DD:EE:FF): " REMOTE_MAC

if [ -n "$REMOTE_MAC" ]; then
    echo -e "${BLUE}[INFO]${NC} Pareando com $REMOTE_MAC..."
    bluetoothctl pair "$REMOTE_MAC" || true
    sleep 1
    bluetoothctl trust "$REMOTE_MAC" || true
    sleep 1
    bluetoothctl connect "$REMOTE_MAC" || true
    echo -e "${GREEN}[SUCESSO]${NC} Controle remoto configurado com sucesso no ArcadiaOS!"
else
    echo -e "${YELLOW}[AVISO]${NC} Nenhum endereço inserido. Você também pode parear pelas configurações do sistema."
fi
