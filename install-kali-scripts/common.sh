#!/bin/bash
#
# common.sh - Funciones y variables compartidas
# Para la instalación de dotfiles gh0stzk en Kali Linux
#

# ==============================
# COLORES
# ==============================
CRE=$(tput setaf 1)    # Red
CYE=$(tput setaf 3)    # Yellow
CGR=$(tput setaf 2)    # Green
CBL=$(tput setaf 4)    # Blue
CMA=$(tput setaf 5)    # Magenta
CCY=$(tput setaf 6)    # Cyan
BLD=$(tput bold)       # Bold
CNC=$(tput sgr0)       # Reset colors

# ==============================
# VARIABLES GLOBALES
# ==============================
INSTALL_DIR="$HOME/.local/share/gh0stzk"
BACKUP_DIR="$HOME/.RiceBackup/$(date +%Y%m%d-%H%M%S)"
ERROR_LOG="$HOME/RiceError-$(date +%Y%m%d-%H%M%S).log"
TEMP_DIR="/tmp/gh0stzk-install"

# ==============================
# FUNCIONES DE UTILIDAD
# ==============================

# Logo
logo() {
    local text="${1:-Installation}"
    printf "%b" "
               ${CCY}%%%
        %%%%%//%%%%%
      %%************%%%
  (%%//############*****%%
 %%%%**###&&&&&&&&&###**//
 %%(**##&&&#########&&&##**
 %%(**##*****#####*****##**%%%
 %%(**##     *****     ##**
   //##   @@**   @@   ##//
     ##     **###     ##
     #######     #####//
       ###**&&&&&**###
       &&&         &&&
       &&&////   &&
          &&//@@@**
            ..***${CNC}

   ${BLD}${CRE}[ ${CYE}${text} ${CRE}]${CNC}

"
}

# Mensaje de información
msg_info() {
    printf "${BLD}${CBL}[INFO]${CNC} %s\n" "$1"
}

# Mensaje de éxito
msg_ok() {
    printf "${BLD}${CGR}[OK]${CNC} %s\n" "$1"
}

# Mensaje de advertencia
msg_warning() {
    printf "${BLD}${CYE}[WARNING]${CNC} %s\n" "$1"
}

# Mensaje de error
msg_error() {
    printf "${BLD}${CRE}[ERROR]${CNC} %s\n" "$1"
}

# Registrar error en log
log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$ERROR_LOG"
}

# Registrar info en log
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" >> "$ERROR_LOG"
}

# Barra de progreso
progress_bar() {
    local total=$1
    local current=$2
    local width=50
    local progress=$((current * width / total))
    local remaining=$((width - progress))

    printf "\r["
    printf "%${progress}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    printf "] %3d%%" $((current * 100 / total))
}

# Verificar si un paquete está instalado
is_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii"
}

# Verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Crear directorio temporal
create_temp_dir() {
    mkdir -p "$TEMP_DIR"
    log_info "Directorio temporal creado: $TEMP_DIR"
}

# Limpiar directorio temporal
cleanup_temp_dir() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        log_info "Directorio temporal limpiado: $TEMP_DIR"
    fi
}

# Preguntar confirmación al usuario
ask_confirm() {
    local prompt="${1:-¿Continuar?}"
    local response

    while true; do
        printf "${BLD}${CYE}%s${CNC} [y/N]: " "$prompt"
        read -r response
        case "$response" in
            [Yy]|[Ss])
                return 0
                ;;
            [Nn]|"")
                return 1
                ;;
            *)
                msg_error "Por favor, escribe 'y' o 'n'"
                ;;
        esac
    done
}

# Verificar conexión a Internet
check_internet() {
    msg_info "Verificando conexión a Internet..."
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        msg_ok "Conexión a Internet disponible"
        return 0
    else
        msg_error "No hay conexión a Internet"
        return 1
    fi
}

# Pausa con mensaje
pause_with_msg() {
    local msg="${1:-Presiona Enter para continuar...}"
    printf "\n${BLD}${CCY}%s${CNC}" "$msg"
    read -r
}

# Banner de sección
section_banner() {
    local title="$1"
    local width=60
    local title_length=${#title}
    local padding=$(( (width - title_length - 2) / 2 ))

    echo
    printf "${BLD}${CBL}"
    printf '═%.0s' $(seq 1 $width)
    printf "\n"
    printf "%${padding}s" ""
    printf " %s " "$title"
    printf "\n"
    printf '═%.0s' $(seq 1 $width)
    printf "${CNC}\n\n"
}

# Exportar variables y funciones
export INSTALL_DIR BACKUP_DIR ERROR_LOG TEMP_DIR
export CRE CYE CGR CBL CMA CCY BLD CNC
export -f msg_info msg_ok msg_warning msg_error
export -f log_error log_info progress_bar
export -f is_installed command_exists
export -f ask_confirm check_internet pause_with_msg
export -f section_banner logo
