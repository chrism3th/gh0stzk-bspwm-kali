#!/bin/bash
#
# 01-setup-packages.sh - Verificación del sistema e instalación de paquetes APT
#

source "$(dirname "$(dirname "$0")")/common.sh"

# ============================================
# VERIFICACIÓN DEL SISTEMA
# ============================================
section_banner "Verificación del Sistema"

# Verificar que NO se ejecuta como root
if [ "$(id -u)" = 0 ]; then
    msg_error "Este script NO debe ejecutarse como root"
    msg_info "Por favor, ejecuta sin sudo"
    exit 1
fi
msg_ok "Usuario correcto (no root)"

# Verificar distribución
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" != "kali" && "$ID_LIKE" != *"debian"* ]]; then
        msg_warning "Esta distribución no es Kali Linux: $PRETTY_NAME"
        msg_warning "El script está diseñado para Kali/Debian"
        if ! ask_confirm "¿Continuar de todas formas?"; then
            exit 1
        fi
    else
        msg_ok "Sistema operativo: $PRETTY_NAME"
    fi
fi

# Verificar conexión a Internet
if ! check_internet; then
    msg_error "Se requiere conexión a Internet para continuar"
    exit 1
fi

# Verificar espacio en disco
available_space=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$available_space" -lt 5 ]; then
    msg_warning "Espacio disponible bajo: ${available_space}GB"
    msg_info "Se recomienda al menos 5GB de espacio libre"
    if ! ask_confirm "¿Continuar de todas formas?"; then
        exit 1
    fi
else
    msg_ok "Espacio disponible: ${available_space}GB"
fi

# Verificar dependencias críticas
critical_deps=("git" "wget" "curl" "sudo")
missing_deps=()

for dep in "${critical_deps[@]}"; do
    if ! command_exists "$dep"; then
        missing_deps+=("$dep")
    fi
done

if [ ${#missing_deps[@]} -gt 0 ]; then
    msg_error "Dependencias críticas faltantes: ${missing_deps[*]}"
    msg_info "Instala con: sudo apt install ${missing_deps[*]}"
    exit 1
fi
msg_ok "Dependencias críticas presentes"

# Crear directorio de logs
touch "$ERROR_LOG"
log_info "=== Inicio de instalación ==="
log_info "Usuario: $USER"
log_info "Sistema: $(uname -a)"
msg_ok "Sistema de logs inicializado"

msg_ok "Todas las verificaciones pasaron correctamente"
echo

# ============================================
# INSTALACIÓN DE PAQUETES APT
# ============================================
section_banner "Instalación de Paquetes APT"

msg_info "Actualizando índice de paquetes..."
if sudo apt update >> "$ERROR_LOG" 2>&1; then
    msg_ok "Índice de paquetes actualizado"
else
    msg_error "Error al actualizar paquetes (ver $ERROR_LOG)"
fi

# Lista de paquetes APT (corregidos para Kali Linux)
apt_packages=(
    # Build tools
    "build-essential" "git" "curl" "wget" "pkg-config" "gcc" "libc6-dev"

    # WM y herramientas core
    "bspwm" "sxhkd" "polybar" "rofi" "dunst" "picom" "jgmenu" "i3lock-color"

    # Terminales
    "alacritty" "kitty"

    # File managers
    "thunar" "tumbler" "gvfs-backends"

    # Herramientas de sistema
    "brightnessctl" "playerctl" "pamixer" "pulseaudio-utils"
    "lxsession" "xsettingsd" "redshift"

    # Utilidades CLI modernas
    "bat" "eza" "fzf" "neovim" "tmux"

    # Clipboard manager (lanzado desde bspwmrc)
    "copyq"

    # Media players
    "mpd" "mpc" "ncmpcpp" "mpv" "ffmpeg" "cava"

    # Herramientas gráficas
    "feh" "maim" "imagemagick" "webp-pixbuf-loader" "viewnior"
    "zathura" "zathura-pdf-poppler"

    # Editores y desarrollo
    "geany" "npm"

    # Utilidades X11
    "x11-utils" "x11-xserver-utils" "xclip" "xdotool" "xdo" "xdg-user-dirs"

    # Iconos y temas
    "papirus-icon-theme" "gtk2-engines-murrine" "gtk2-engines-pixbuf"

    # Python
    "python3-gi"

    # Fuentes disponibles en repos
    "fonts-inconsolata" "fonts-ubuntu"

    # Herramientas adicionales
    "jq" "bc" "webp"

    # Shell
    "zsh" "zsh-autosuggestions" "zsh-syntax-highlighting"

    # Navegador
    "firefox-esr"

    # MTP
    "libmtp-runtime" "libmtp-common"

    # Dependencias para compilación posterior (corregidos)
    "libgtk-3-dev" "libpango1.0-dev" "libgdk-pixbuf2.0-dev"
    "libdbusmenu-gtk3-dev" "libcairo2-dev" "libglib2.0-dev"
    "libx11-dev" "libxrandr-dev" "libxrender-dev" "libxext-dev"
    "x11proto-dev" "xserver-xorg-dev" "zstd"
    "libxcb1-dev" "libxcb-randr0-dev" "libxcb-xinerama0-dev"
    "libxcb-icccm4-dev" "libxcb-ewmh-dev" "libxcb-util0-dev"
    "libxcb-shape0-dev" "libxcb-xfixes0-dev" "libxcursor-dev"
)

msg_info "Se instalarán ${#apt_packages[@]} paquetes"
echo

# Arrays para tracking
installed=()
already_installed=()
failed=()

total=${#apt_packages[@]}
current=0

for pkg in "${apt_packages[@]}"; do
    current=$((current + 1))
    progress_bar "$total" "$current"

    # Mostrar paquete actual
    echo
    printf "${BLD}${CYE}[%3d/%3d]${CNC} Verificando: ${BLD}%s${CNC}\n" "$current" "$total" "$pkg"

    if is_installed "$pkg"; then
        already_installed+=("$pkg")
        printf "          ${BLD}${CCY}→${CNC} Ya instalado\n"
        log_info "Paquete ya instalado: $pkg"
        continue
    fi

    # Verificar si el paquete existe en los repositorios
    if ! apt-cache show "$pkg" &>/dev/null; then
        failed+=("$pkg")
        printf "          ${BLD}${CRE}✗${CNC} No disponible en repositorios\n"
        log_error "Paquete no encontrado en repos: $pkg"
        {
            echo "=== Intento de instalación: $pkg ==="
            echo "ERROR: Paquete no encontrado en los repositorios de Kali Linux"
            echo "Comando: apt-cache show $pkg"
            apt-cache show "$pkg" 2>&1 || true
            echo
        } >> "$ERROR_LOG"
        continue
    fi

    printf "          ${BLD}${CBL}→${CNC} Instalando...\n"

    # Crear log temporal para esta instalación
    temp_log=$(mktemp)

    # Instalar con logs visibles
    if sudo apt install -y "$pkg" 2>&1 | tee "$temp_log" | grep -E "(Unpacking|Setting up|Processing|Preparing|Selecting|already|newest)" | sed 's/^/          /'; then
        installed+=("$pkg")
        printf "          ${BLD}${CGR}✓${CNC} Instalado correctamente\n"
        log_info "Paquete instalado exitosamente: $pkg"
        # Guardar log completo en caso de éxito
        {
            echo "=== Instalación exitosa: $pkg ==="
            cat "$temp_log"
            echo
        } >> "$ERROR_LOG"
    else
        failed+=("$pkg")
        printf "          ${BLD}${CRE}✗${CNC} Error en instalación\n"
        log_error "Fallo al instalar: $pkg"
        # Guardar log completo del error
        {
            echo "=== ERROR en instalación: $pkg ==="
            cat "$temp_log"
            echo
        } >> "$ERROR_LOG"
    fi

    rm -f "$temp_log"
done

echo
echo

# Reporte de resultados
if [ ${#installed[@]} -gt 0 ]; then
    msg_ok "Paquetes instalados: ${#installed[@]}"
fi

if [ ${#already_installed[@]} -gt 0 ]; then
    msg_info "Paquetes ya instalados: ${#already_installed[@]}"
fi

if [ ${#failed[@]} -gt 0 ]; then
    msg_error "Paquetes fallidos: ${#failed[@]}"
    printf "${BLD}${CRE}Lista de fallos:${CNC}\n"
    printf '%s\n' "${failed[@]}"

    {
        echo "# Paquetes que fallaron durante la instalación automática"
        echo "# Fecha: $(date)"
        echo "# Intenta instalar manualmente con: sudo apt install <paquete>"
        echo
        printf '%s\n' "${failed[@]}"
    } > "$HOME/failed_packages.txt"

    msg_warning "Lista guardada en: $HOME/failed_packages.txt"

    if ! ask_confirm "¿Continuar con la instalación a pesar de los fallos?"; then
        exit 1
    fi
fi

msg_ok "Instalación de paquetes APT completada"
log_info "APT packages: ${#installed[@]} instalados, ${#already_installed[@]} ya presentes, ${#failed[@]} fallidos"
echo
