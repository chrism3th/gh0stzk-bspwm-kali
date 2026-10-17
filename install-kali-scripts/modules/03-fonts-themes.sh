#!/bin/bash
#
# 03-fonts-themes.sh - Instalación de fuentes y paquetes personalizados gh0stzk
#

source "$(dirname "$(dirname "$0")")/common.sh"

create_temp_dir

# ============================================
# INSTALACIÓN DE FUENTES
# ============================================
section_banner "Instalación de Fuentes"

FONTS_DIR="$HOME/.local/share/fonts"
msg_info "Creando directorio de fuentes..."
mkdir -p "$FONTS_DIR"

FONTS_TEMP="$TEMP_DIR/fonts"
mkdir -p "$FONTS_TEMP"

# Array de fuentes a descargar
declare -A fonts=(
    ["JetBrainsMono"]="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    ["Terminus"]="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Terminus.zip"
    ["UbuntuMono"]="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.zip"
    ["Inconsolata"]="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Inconsolata.zip"
)

total=${#fonts[@]}
current=0

for font_name in "${!fonts[@]}"; do
    current=$((current + 1))
    url="${fonts[$font_name]}"

    msg_info "[$current/$total] Descargando $font_name..."

    cd "$FONTS_TEMP" || exit 1

    if wget -q --show-progress "$url" -O "${font_name}.zip" 2>> "$ERROR_LOG"; then
        msg_ok "Descarga completada: $font_name"

        msg_info "Extrayendo $font_name..."
        if unzip -q "${font_name}.zip" -d "$font_name" 2>> "$ERROR_LOG"; then
            find "$font_name" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$FONTS_DIR/" \;
            msg_ok "$font_name instalada"
        else
            msg_warning "Error al extraer $font_name"
            log_error "Fallo al extraer fuente: $font_name"
        fi

        rm -f "${font_name}.zip"
        rm -rf "$font_name"
    else
        msg_warning "Error al descargar $font_name"
        log_error "Fallo al descargar fuente: $font_name (URL: $url)"
    fi
done

cd - > /dev/null

# JetBrains Mono oficial (sin Nerd Font patches)
msg_info "Descargando JetBrains Mono oficial..."
if wget -q --show-progress "https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip" -O "$FONTS_TEMP/JBMono.zip" 2>> "$ERROR_LOG"; then
    msg_ok "Descarga completada: JetBrains Mono oficial"

    cd "$FONTS_TEMP" || exit 1
    if unzip -q "JBMono.zip" -d "JBMono" 2>> "$ERROR_LOG"; then
        find "JBMono" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp {} "$FONTS_DIR/" \;
        msg_ok "JetBrains Mono oficial instalada"
    else
        msg_warning "Error al extraer JetBrains Mono oficial"
    fi
    rm -f "JBMono.zip"
    rm -rf "JBMono"
    cd - > /dev/null
else
    msg_warning "Error al descargar JetBrains Mono oficial"
fi

# Actualizar caché de fuentes
msg_info "Actualizando caché de fuentes..."
if fc-cache -fv >> "$ERROR_LOG" 2>&1; then
    msg_ok "Caché de fuentes actualizado"
else
    msg_warning "Error al actualizar caché de fuentes (no crítico)"
fi

# Verificar fuentes instaladas
installed_fonts=$(fc-list | grep -i -E "(jetbrains|terminus|ubuntu|inconsolata)" | wc -l)
msg_ok "Fuentes instaladas correctamente ($installed_fonts variantes encontradas)"

log_info "Fuentes Nerd Fonts instaladas"
echo

# ============================================
# PAQUETES PERSONALIZADOS DE GH0STZK
# ============================================
section_banner "Paquetes Personalizados de gh0stzk"

# Verificar que zstd está instalado
if ! command_exists zstd; then
    msg_info "Instalando zstd..."
    sudo apt update >> "$ERROR_LOG" 2>&1
    sudo apt install -y zstd >> "$ERROR_LOG" 2>&1
fi

REPO_URL="https://github.com/gh0stzk/pkgs.git"
CLONE_DIR="$TEMP_DIR/gh0stzk_pkgs"
PKG_DIR="$CLONE_DIR/x86_64"

msg_info "Clonando repositorio de paquetes gh0stzk..."

if git clone --depth=1 "$REPO_URL" "$CLONE_DIR" >> "$ERROR_LOG" 2>&1; then
    msg_ok "Repositorio clonado correctamente"
else
    msg_error "Fallo al clonar repositorio de paquetes"
    log_error "Git clone de gh0stzk/pkgs falló"
    exit 1
fi

# Verificar que existe el directorio de paquetes
if [ ! -d "$PKG_DIR" ]; then
    msg_error "No se encontró el directorio x86_64 en el repositorio"
    log_error "Directorio $PKG_DIR no encontrado"
    exit 1
fi

msg_info "Instalando paquetes personalizados..."

installed_count=0
failed_count=0

# Listar todos los paquetes .pkg.tar.zst
for package in "$PKG_DIR"/*.pkg.tar.zst; do
    if [ ! -f "$package" ]; then
        continue
    fi

    pkg_basename=$(basename "$package")
    pkg_name=$(echo "$pkg_basename" | cut -d'-' -f1-3)

    # Solo se usan los paquetes de datos (temas, iconos, cursores).
    # st es un binario de Arch: se compila desde fuente en 02-compile-build.sh
    case "$pkg_basename" in
        st-gh0stzk-*) continue ;;
    esac

    msg_info "Procesando: $pkg_basename"

    # Crear directorio temporal para este paquete
    extract_dir="$TEMP_DIR/extract_${pkg_name}"
    mkdir -p "$extract_dir"

    # Descomprimir el paquete
    if tar --use-compress-program=zstd -xf "$package" -C "$extract_dir" >> "$ERROR_LOG" 2>&1; then
        # Hooks de pacman no sirven en Debian
        rm -rf "$extract_dir/usr/share/libalpm"

        # Verificar si tiene directorio usr/
        if [ -d "$extract_dir/usr" ]; then
            # Copiar archivos al sistema
            if sudo cp -r "$extract_dir/usr/"* /usr/ 2>> "$ERROR_LOG"; then
                msg_ok "$pkg_name instalado"
                installed_count=$((installed_count + 1))
            else
                msg_warning "Error al copiar archivos de $pkg_name"
                log_error "Fallo al copiar archivos de $pkg_name"
                failed_count=$((failed_count + 1))
            fi
        else
            msg_warning "$pkg_name no tiene estructura usr/ esperada"
            log_error "$pkg_name sin estructura usr/"
            failed_count=$((failed_count + 1))
        fi
    else
        msg_warning "Error al extraer $pkg_name"
        log_error "Fallo al extraer $pkg_name"
        failed_count=$((failed_count + 1))
    fi

    # Limpiar directorio temporal
    rm -rf "$extract_dir"
done

echo
msg_ok "Paquetes instalados: $installed_count"
if [ $failed_count -gt 0 ]; then
    msg_warning "Paquetes con errores: $failed_count"
fi

# Verificar instalación de paquetes clave
msg_info "Verificando instalación de paquetes clave..."

# Verificar temas GTK
if [ -d "/usr/share/themes" ]; then
    theme_count=$(find /usr/share/themes -maxdepth 1 -type d -name "*gh0stzk*" 2>/dev/null | wc -l)
    if [ "$theme_count" -gt 0 ]; then
        msg_ok "Temas GTK de gh0stzk instalados ($theme_count encontrados)"
    fi
fi

# Verificar iconos
if [ -d "/usr/share/icons" ]; then
    icon_count=$(find /usr/share/icons -maxdepth 1 -type d -name "*gh0stzk*" 2>/dev/null | wc -l)
    if [ "$icon_count" -gt 0 ]; then
        msg_ok "Iconos de gh0stzk instalados ($icon_count paquetes)"
    fi
fi

msg_ok "Instalación de paquetes gh0stzk completada"
log_info "Paquetes gh0stzk: $installed_count instalados, $failed_count fallos"
echo
