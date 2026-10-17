#!/bin/bash
#
# quick-check.sh - Verificación rápida antes de la instalación
#

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${BOLD}Verificación Rápida - gh0stzk Dotfiles para Kali${NC}      ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo

# Función para verificar comando
check_cmd() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# Función para verificar paquete instalado
check_pkg() {
    if dpkg -l | grep -q "^ii  $1"; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# Función para verificar disponibilidad en repos
check_available() {
    if apt-cache show "$1" &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# 1. VERIFICAR SISTEMA
echo -e "${CYAN}${BOLD}[1] Sistema${NC}"
echo -e "═══════════════════════════════════════════════════════════"

printf "%-40s " "Sistema operativo:"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "kali" ]]; then
        echo -e "${GREEN}Kali Linux${NC}"
    elif [[ "$ID_LIKE" == *"debian"* ]]; then
        echo -e "${YELLOW}Debian-based ($ID)${NC}"
    else
        echo -e "${RED}No es Kali/Debian ($ID)${NC}"
    fi
    echo "                                         $PRETTY_NAME"
else
    echo -e "${RED}Desconocido${NC}"
fi

printf "%-40s " "Usuario actual:"
if [ "$(id -u)" = 0 ]; then
    echo -e "${RED}root (NO ejecutar como root!)${NC}"
else
    echo -e "${GREEN}$USER${NC}"
fi

printf "%-40s " "Conexión a Internet:"
if ping -c 1 8.8.8.8 &>/dev/null; then
    echo -e "${GREEN}Conectado${NC}"
else
    echo -e "${RED}Sin conexión${NC}"
fi

printf "%-40s " "Espacio disponible:"
available_space=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$available_space" -ge 5 ]; then
    echo -e "${GREEN}${available_space}GB${NC}"
else
    echo -e "${YELLOW}${available_space}GB (recomendado: 5GB+)${NC}"
fi

echo

# 2. DEPENDENCIAS CRÍTICAS
echo -e "${CYAN}${BOLD}[2] Dependencias Críticas${NC}"
echo -e "═══════════════════════════════════════════════════════════"

critical_deps=("git" "curl" "wget" "sudo" "build-essential")
all_critical_ok=true

for dep in "${critical_deps[@]}"; do
    printf "%-40s " "$dep:"
    if ! check_cmd "$dep" && ! check_pkg "$dep"; then
        all_critical_ok=false
    fi
done

if [ "$all_critical_ok" = true ]; then
    echo -e "\n${GREEN}✓ Todas las dependencias críticas están presentes${NC}"
else
    echo -e "\n${RED}✗ Faltan dependencias críticas${NC}"
    echo -e "${YELLOW}Ejecutar: sudo apt install git curl wget build-essential${NC}"
fi

echo

# 3. PAQUETES PROBLEMÁTICOS
echo -e "${CYAN}${BOLD}[3] Verificación de Paquetes Problemáticos${NC}"
echo -e "═══════════════════════════════════════════════════════════"

echo -e "${BOLD}Leyenda:${NC} Instalado | Disponible en repos | No disponible"
echo

problematic=(
    "gvfs-backends:MTP Support (reemplaza gvfs-mtp)"
    "copyq:Clipboard Manager"
    "i3lock-color:Screen locker (apt)"
    "webp:WebP Support"
    "libmtp-runtime:MTP Support"
    "libgdk-pixbuf2.0-dev:GTK Dev (corregido)"
    "x11proto-dev:X11 Proto (consolidado)"
    "xserver-xorg-dev:Xorg Dev (corregido)"
)

for item in "${problematic[@]}"; do
    IFS=':' read -r pkg desc <<< "$item"
    printf "%-35s " "$pkg"
    printf "%-25s " "$desc"

    if check_pkg "$pkg"; then
        echo -e "  ${GREEN}Instalado${NC}"
    elif check_available "$pkg"; then
        echo -e "  ${YELLOW}Disponible${NC}"
    else
        echo -e "  ${RED}No disponible${NC}"
    fi
done

echo

# 4. HERRAMIENTAS QUE REQUIEREN COMPILACIÓN
echo -e "${CYAN}${BOLD}[4] Herramientas que Requieren Compilación${NC}"
echo -e "═══════════════════════════════════════════════════════════"

compile_tools=(
    "eww:ElKowar's Wacky Widgets"
    "xwinwrap:Fondos de pantalla animados"
    "xcolor:Color picker"
    "yazi:File manager para terminal"
)

for item in "${compile_tools[@]}"; do
    IFS=':' read -r tool desc <<< "$item"
    printf "%-20s " "$tool"
    printf "%-35s " "$desc"
    check_cmd "$tool"
done

echo

# 5. RESUMEN Y RECOMENDACIONES
echo -e "${CYAN}${BOLD}[5] Resumen${NC}"
echo -e "═══════════════════════════════════════════════════════════"

if [ "$all_critical_ok" = true ] && [ "$available_space" -ge 5 ]; then
    echo -e "${GREEN}✓ El sistema está listo para la instalación${NC}"
    echo
    echo -e "${BOLD}Próximos pasos:${NC}"
    echo "  1. Desde la raíz del repo ejecutar: ${CYAN}./KaliInstaller${NC}"
else
    echo -e "${YELLOW}⚠ Se recomienda resolver los problemas antes de continuar${NC}"
    echo
    echo -e "${BOLD}Acciones recomendadas:${NC}"

    if [ "$all_critical_ok" = false ]; then
        echo "  • Instalar dependencias críticas:"
        echo "    ${CYAN}sudo apt update${NC}"
        echo "    ${CYAN}sudo apt install git curl wget build-essential${NC}"
    fi

    if [ "$available_space" -lt 5 ]; then
        echo "  • Liberar espacio en disco (actual: ${available_space}GB, recomendado: 5GB+)"
    fi
fi

echo
echo -e "${BLUE}Más información:${NC}"
echo "  • Documentación de correcciones: ${CYAN}PACKAGE-CORRECTIONS.md${NC}"
echo "  • Verificación detallada: ${CYAN}./verify-packages.sh${NC}"
echo "  • Logs de instalación: ${CYAN}~/.local/share/gh0stzk/error.log${NC}"
echo
