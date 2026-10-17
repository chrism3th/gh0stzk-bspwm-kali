#!/bin/bash
#
# verify-packages.sh - Verifica la disponibilidad de paquetes en Kali Linux
#

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  Verificador de Paquetes para Kali Linux                  ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo

# Lista de paquetes a verificar
packages=(
    "gvfs-mtp"
    "copyq"
    "mpd"
    "mpc"
    "ncmpcpp"
    "mpv"
    "feh"
    "maim"
    "geany"
    "npm"
    "papirus-icon-theme"
    "gtk2-engines-murrine"
    "fonts-inconsolata"
    "fonts-ubuntu"
    "jq"
    "webp-pixbuf-loader"
    "i3lock-color"
    "libgtk-3-dev"
    "libpango1.0-dev"
    "libgdk-pixbuf-xlib-2.0-dev"
    "libdbusmenu-gtk3-dev"
    "libcairo2-dev"
    "libglib2.0-dev"
    "libxrender-dev"
    "x11proto-xext-dev"
    "xorg-dev"
)

echo -e "${YELLOW}Actualizando índice de paquetes...${NC}"
sudo apt update > /dev/null 2>&1
echo

available=()
not_available=()
alternative_names=()

echo -e "${BLUE}Verificando ${#packages[@]} paquetes...${NC}"
echo

for pkg in "${packages[@]}"; do
    printf "Verificando %-35s ... " "$pkg"

    # Verificar si el paquete existe en los repositorios
    if apt-cache show "$pkg" &>/dev/null; then
        echo -e "${GREEN}✓ DISPONIBLE${NC}"
        available+=("$pkg")
    else
        echo -e "${RED}✗ NO DISPONIBLE${NC}"
        not_available+=("$pkg")

        # Buscar alternativas
        case "$pkg" in
            "libgdk-pixbuf-xlib-2.0-dev")
                alt="libgdk-pixbuf2.0-dev"
                if apt-cache show "$alt" &>/dev/null; then
                    echo -e "    ${YELLOW}→ Alternativa sugerida: $alt${NC}"
                    alternative_names+=("$pkg → $alt")
                fi
                ;;
            "x11proto-xext-dev")
                alt="x11proto-dev"
                if apt-cache show "$alt" &>/dev/null; then
                    echo -e "    ${YELLOW}→ Alternativa sugerida: $alt${NC}"
                    alternative_names+=("$pkg → $alt")
                fi
                ;;
            "i3lock-color")
                echo -e "    ${YELLOW}→ Está en kali-rolling; ejecuta sudo apt update${NC}"
                alternative_names+=("$pkg → sudo apt update && sudo apt install i3lock-color")
                ;;
            "xorg-dev")
                alt="xserver-xorg-dev"
                if apt-cache show "$alt" &>/dev/null; then
                    echo -e "    ${YELLOW}→ Alternativa sugerida: $alt${NC}"
                    alternative_names+=("$pkg → $alt")
                fi
                ;;
            "webp-pixbuf-loader")
                alt="webp"
                if apt-cache show "$alt" &>/dev/null; then
                    echo -e "    ${YELLOW}→ Alternativa sugerida: $alt${NC}"
                    alternative_names+=("$pkg → $alt")
                fi
                ;;
        esac
    fi
done

echo
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  RESUMEN                                                   ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${GREEN}Paquetes disponibles:${NC} ${#available[@]}"
echo -e "${RED}Paquetes no disponibles:${NC} ${#not_available[@]}"
echo

if [ ${#not_available[@]} -gt 0 ]; then
    echo -e "${RED}Lista de paquetes NO disponibles:${NC}"
    for pkg in "${not_available[@]}"; do
        echo "  • $pkg"
    done
    echo
fi

if [ ${#alternative_names[@]} -gt 0 ]; then
    echo -e "${YELLOW}Alternativas sugeridas:${NC}"
    for alt in "${alternative_names[@]}"; do
        echo "  • $alt"
    done
    echo
fi

# Generar archivo de correcciones
if [ ${#not_available[@]} -gt 0 ]; then
    cat > package-fixes.txt <<EOF
# Correcciones de paquetes para Kali Linux
# Generado: $(date)

PAQUETES NO DISPONIBLES:
$(printf '%s\n' "${not_available[@]}")

ALTERNATIVAS SUGERIDAS:
$(printf '%s\n' "${alternative_names[@]}")

INSTRUCCIONES:
1. Reemplazar los paquetes en 01-setup-packages.sh con las alternativas
2. Paquetes que requieren compilación manual:
   - xcolor: cargo install --locked xcolor

EOF
    echo -e "${BLUE}Reporte guardado en: package-fixes.txt${NC}"
fi
