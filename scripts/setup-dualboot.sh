#!/usr/bin/env bash
# ==============================================================================
# ArcadiaOS: Configurador de Dual-Boot com Windows (UEFI GRUB)
# Detecta o Windows Boot Manager e configura o menu de inicialização para TV
# ==============================================================================

set -eo pipefail

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCESSO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[AVISO]${NC} $1"; }
log_error() { echo -e "${RED}[ERRO]${NC} $1"; }

echo -e "${CYAN}--------------------------------------------------------------${NC}"
echo -e "${CYAN}       Configuração de Dual-Boot: ArcadiaOS & Windows         ${NC}"
echo -e "${CYAN}--------------------------------------------------------------${NC}"

# 1. Verificar privilégios
if [ "$EUID" -ne 0 ]; then
    log_info "Solicitando privilégios de administrador (sudo)..."
    exec sudo bash "$0" "$@"
fi

# 2. Verificar se o sistema foi iniciado em modo UEFI
if [ ! -d "/sys/firmware/efi" ]; then
    log_warn "O sistema não parece estar rodando em modo UEFI nativo."
    log_warn "O Dual-Boot automático funciona melhor com partições EFI GPT."
fi

# 3. Fazer backup do arquivo de configuração do GRUB
GRUB_DEFAULT_FILE="/etc/default/grub"
if [ -f "$GRUB_DEFAULT_FILE" ]; then
    if [ ! -f "${GRUB_DEFAULT_FILE}.arcadia.bak" ]; then
        cp "$GRUB_DEFAULT_FILE" "${GRUB_DEFAULT_FILE}.arcadia.bak"
        log_info "Backup criado em ${GRUB_DEFAULT_FILE}.arcadia.bak"
    fi
fi

# 4. Ajustar opções visuais do GRUB para exibição em TV
log_info "Otimizando opções do menu de boot para TV (1080p, visível por 5s)..."

# Função auxiliar para atualizar ou adicionar propriedades no /etc/default/grub
set_grub_prop() {
    local key="$1"
    local value="$2"
    if grep -q "^${key}=" "$GRUB_DEFAULT_FILE" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$GRUB_DEFAULT_FILE"
    else
        echo "${key}=${value}" >> "$GRUB_DEFAULT_FILE"
    fi
}

# Garante que o menu seja visível
set_grub_prop "GRUB_TIMEOUT" "5"
set_grub_prop "GRUB_TIMEOUT_STYLE" "menu"
set_grub_prop "GRUB_GFXMODE" "1920x1080,1280x720,auto"
set_grub_prop "GRUB_DEFAULT" "saved"
set_grub_prop "GRUB_SAVEDEFAULT" "true"
set_grub_prop "GRUB_DISABLE_OS_PROBER" "false"

# 5. Procurar partição EFI do Windows no sistema
log_info "Procurando partição do Windows Boot Manager (bootmgfw.efi)..."
WIN_FOUND=false
WIN_UUID=""

# Instalar os-prober caso não esteja presente
if command -v rpm-ostree &>/dev/null; then
    # Sistema imutável (Bazzite / Silverblue)
    true
elif command -v dnf &>/dev/null; then
    dnf install -y os-prober || true
elif command -v apt &>/dev/null; then
    apt update && apt install -y os-prober || true
fi

# Busca direta nos discos por partições EFI com bootmgfw.efi
for part in $(lsblk -lno PATH,FSTYPE | awk '$2 == "vfat" {print $1}'); do
    TMP_MOUNT="/mnt/arcadia_efi_temp"
    mkdir -p "$TMP_MOUNT"
    if mount -o ro "$part" "$TMP_MOUNT" 2>/dev/null; then
        if [ -f "$TMP_MOUNT/EFI/Microsoft/Boot/bootmgfw.efi" ]; then
            WIN_UUID=$(lsblk -no UUID "$part" 2>/dev/null | head -n1)
            WIN_FOUND=true
            log_success "Windows Boot Manager localizado na partição $part (UUID: $WIN_UUID)"
            umount "$TMP_MOUNT" || true
            break
        fi
        umount "$TMP_MOUNT" || true
    fi
done
rm -rf "/mnt/arcadia_efi_temp" 2>/dev/null || true

# 6. Se encontrado via UUID mas o os-prober falhar, garantir entrada no 40_custom
if [ "$WIN_FOUND" = true ] && [ -n "$WIN_UUID" ]; then
    CUSTOM_GRUB="/etc/grub.d/40_custom"
    if [ -f "$CUSTOM_GRUB" ]; then
        if ! grep -q "Windows Boot Manager (Arcadia Dual-Boot)" "$CUSTOM_GRUB"; then
            log_info "Adicionando entrada dedicada do Windows ao GRUB..."
            cat <<EOF >> "$CUSTOM_GRUB"

# Entrada adicionada pelo instalador ArcadiaOS
menuentry "Windows Boot Manager" --class windows --class os {
    insmod part_gpt
    insmod fat
    search --no-floppy --fs-uuid --set=root $WIN_UUID
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
}
EOF
        fi
    fi
fi

# 7. Regenerar o arquivo de configuração do GRUB
log_info "Atualizando configuração do GRUB no sistema..."
if [ -f "/boot/grub2/grub.cfg" ]; then
    grub2-mkconfig -o /boot/grub2/grub.cfg || true
elif [ -f "/boot/efi/EFI/fedora/grub.cfg" ]; then
    grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg || true
elif command -v update-grub &>/dev/null; then
    update-grub || true
else
    grub-mkconfig -o /boot/grub/grub.cfg || true
fi

if [ "$WIN_FOUND" = true ]; then
    log_success "Dual-Boot configurado com sucesso!"
    echo "Ao ligar o PC, você poderá escolher entre 'ArcadiaOS' e 'Windows Boot Manager'."
else
    log_warn "O Windows não foi encontrado nas partições atuais ou o disco está desconectado."
    log_warn "O menu do GRUB foi ajustado para exibir a lista de sistemas e aguardar 5 segundos."
fi
