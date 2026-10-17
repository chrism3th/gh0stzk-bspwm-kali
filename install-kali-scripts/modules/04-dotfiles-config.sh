#!/bin/bash
#
# 04-dotfiles-config.sh - Clonar, respaldar, instalar dotfiles y configurar servicios
#

source "$(dirname "$(dirname "$0")")/common.sh"

# ============================================
# CLONAR DOTFILES
# ============================================
section_banner "Clonación de Dotfiles"

# IMPORTANTE: Este repositorio es una adaptación para Kali Linux
# de los dotfiles originales de gh0stzk (https://github.com/gh0stzk/dotfiles)
REPO_URL="https://github.com/chrism3th/gh0stzk-bspwm-kali.git"
INSTALL_DIR="$HOME/.local/share/gh0stzk"

msg_info "Repositorio: $REPO_URL"
msg_info "Destino: $INSTALL_DIR"
echo

# Verificar si ya existe el directorio
if [ -d "$INSTALL_DIR" ]; then
    msg_warning "El directorio de dotfiles ya existe"

    echo "Opciones:"
    echo "  1) Eliminar y clonar de nuevo (recomendado)"
    echo "  2) Respaldar y clonar de nuevo"
    echo "  3) Mantener existente y saltar clonación"
    echo "  4) Cancelar instalación"
    echo

    while true; do
        printf "${BLD}${CYE}Selecciona una opción [1-4]:${CNC} "
        read -r option

        case "$option" in
            1)
                msg_info "Eliminando directorio existente..."
                rm -rf "$INSTALL_DIR"
                msg_ok "Directorio eliminado"
                break
                ;;
            2)
                timestamp=$(date +"%Y%m%d-%H%M%S")
                backup_path="${INSTALL_DIR}_backup_${timestamp}"
                msg_info "Respaldando a: $backup_path"
                mv "$INSTALL_DIR" "$backup_path"
                msg_ok "Respaldo creado"
                break
                ;;
            3)
                msg_info "Manteniendo dotfiles existentes"
                msg_ok "Clonación saltada"
                SKIP_CLONE=true
                break
                ;;
            4)
                msg_warning "Instalación cancelada por el usuario"
                exit 1
                ;;
            *)
                msg_error "Opción inválida. Escribe 1, 2, 3 o 4"
                ;;
        esac
    done
fi

if [ "${SKIP_CLONE:-false}" != true ]; then
    mkdir -p "$(dirname "$INSTALL_DIR")"

    msg_info "Clonando dotfiles (esto puede tomar un momento)..."

    if git clone --depth=1 "$REPO_URL" "$INSTALL_DIR" >> "$ERROR_LOG" 2>&1; then
        msg_ok "Dotfiles clonados correctamente"
    else
        msg_error "Fallo al clonar dotfiles"
        log_error "Git clone de dotfiles falló"
        exit 1
    fi

    # Verificar estructura del repositorio
    msg_info "Verificando estructura del repositorio..."

    expected_dirs=("config" "home" "misc")
    all_present=true

    for dir in "${expected_dirs[@]}"; do
        if [ ! -d "$INSTALL_DIR/$dir" ]; then
            msg_error "Directorio faltante: $dir"
            all_present=false
        fi
    done

    if [ "$all_present" = true ]; then
        msg_ok "Estructura del repositorio verificada"
    else
        msg_error "El repositorio no tiene la estructura esperada"
        log_error "Estructura de dotfiles incorrecta"
        exit 1
    fi

    # Mostrar información del repositorio
    if [ -d "$INSTALL_DIR/.git" ]; then
        cd "$INSTALL_DIR" || exit 1
        commit_hash=$(git rev-parse --short HEAD 2>/dev/null)
        commit_date=$(git log -1 --format=%cd --date=short 2>/dev/null)

        if [ -n "$commit_hash" ]; then
            msg_ok "Commit: $commit_hash ($commit_date)"
        fi

        cd - > /dev/null
    fi

    msg_ok "Dotfiles descargados y verificados"
fi

log_info "Dotfiles preparados"
echo

# ============================================
# RESPALDO DE CONFIGURACIONES
# ============================================
section_banner "Respaldo de Configuraciones"

# Variable global para decidir sobre nvim
export TRY_NVIM="n"

# Preguntar sobre la configuración de Neovim
echo "${BLD}${CYE}Acerca de Neovim:${CNC}"
echo "Los dotfiles incluyen una configuración ligera y funcional de Neovim."
echo "Si ya tienes una configuración personalizada de Neovim, puedes mantenerla."
echo

while true; do
    printf "${BLD}${CYE}¿Deseas usar la configuración de Neovim de gh0stzk?${CNC} [y/N]: "
    read -r response

    case "$response" in
        [Yy]|[Ss])
            TRY_NVIM="y"
            msg_ok "Se instalará la configuración de Neovim"
            break
            ;;
        [Nn]|"")
            TRY_NVIM="n"
            msg_info "Se mantendrá tu configuración actual de Neovim"
            break
            ;;
        *)
            msg_error "Por favor, escribe 'y' o 'n'"
            ;;
    esac
done

echo

# Crear directorio de respaldo
BACKUP_DIR="$HOME/.RiceBackup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

msg_info "Directorio de respaldo: $BACKUP_DIR"
echo

# Directorios de ~/.config/ a respaldar
config_dirs=(
    "bspwm" "alacritty" "cava" "clipcat" "ghostty" "picom" "rofi" "eww" "sxhkd" "dunst"
    "jgmenu" "kitty" "polybar" "geany" "gtk-3.0" "ncmpcpp" "yazi" "zsh" "mpd" "mpv"
    "st" "zathura"
)

# Archivos/directorios en $HOME a respaldar
home_items=(".icons" ".zshrc" ".gtkrc-2.0")

backed_up_count=0
not_found_count=0

# Respaldar directorios de configuración
msg_info "Respaldando directorios de ~/.config/..."
for dir in "${config_dirs[@]}"; do
    source_path="$HOME/.config/$dir"

    if [ -d "$source_path" ]; then
        msg_info "Respaldando: $dir"

        if mv "$source_path" "$BACKUP_DIR/" 2>> "$ERROR_LOG"; then
            backed_up_count=$((backed_up_count + 1))
        else
            msg_warning "Error al respaldar $dir"
            log_error "Fallo al respaldar $source_path"
        fi
    else
        not_found_count=$((not_found_count + 1))
    fi
done

# Respaldar archivos/directorios del HOME
msg_info "Respaldando archivos de $HOME..."
for item in "${home_items[@]}"; do
    source_path="$HOME/$item"

    if [ -e "$source_path" ]; then
        msg_info "Respaldando: $item"

        if mv "$source_path" "$BACKUP_DIR/" 2>> "$ERROR_LOG"; then
            backed_up_count=$((backed_up_count + 1))
        else
            msg_warning "Error al respaldar $item"
            log_error "Fallo al respaldar $source_path"
        fi
    else
        not_found_count=$((not_found_count + 1))
    fi
done

# Respaldar configuración de Neovim si el usuario quiere probar la nueva
if [ "$TRY_NVIM" = "y" ]; then
    nvim_path="$HOME/.config/nvim"

    if [ -d "$nvim_path" ]; then
        msg_info "Respaldando: nvim"

        if mv "$nvim_path" "$BACKUP_DIR/" 2>> "$ERROR_LOG"; then
            backed_up_count=$((backed_up_count + 1))
        else
            msg_warning "Error al respaldar nvim"
            log_error "Fallo al respaldar $nvim_path"
        fi
    fi
fi

# Respaldar configuración de Firefox si existe
msg_info "Buscando perfil de Firefox..."
firefox_profile=$(find "$HOME/.mozilla/firefox" "$HOME/.config/mozilla/firefox" -maxdepth 1 -type d \
    \( -name "*.default-release" -o -name "*.default-esr" \) 2>/dev/null | head -n1)

if [ -n "$firefox_profile" ] && [ -d "$firefox_profile" ]; then
    msg_ok "Perfil de Firefox encontrado"

    firefox_items=("chrome" "user.js")
    for item in "${firefox_items[@]}"; do
        item_path="$firefox_profile/$item"

        if [ -e "$item_path" ]; then
            msg_info "Respaldando Firefox: $item"

            if cp -r "$item_path" "$BACKUP_DIR/firefox_$item" 2>> "$ERROR_LOG"; then
                backed_up_count=$((backed_up_count + 1))
            else
                msg_warning "Error al respaldar Firefox $item"
                log_error "Fallo al respaldar $item_path"
            fi
        fi
    done
else
    msg_info "No se encontró perfil de Firefox (no crítico)"
fi

echo
msg_ok "Respaldo completado"
msg_info "Elementos respaldados: $backed_up_count"
msg_info "Elementos no encontrados: $not_found_count"
msg_ok "Ubicación del respaldo: $BACKUP_DIR"

log_info "Respaldo completado: $backed_up_count elementos en $BACKUP_DIR"
echo

# ============================================
# INSTALAR DOTFILES
# ============================================
section_banner "Instalación de Dotfiles"

# Verificar que los dotfiles fueron clonados
if [ ! -d "$INSTALL_DIR" ]; then
    msg_error "Directorio de dotfiles no encontrado: $INSTALL_DIR"
    exit 1
fi

msg_info "Configuración de Neovim: $TRY_NVIM"
echo

# Crear directorios necesarios
msg_info "Creando directorios necesarios..."
mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share"
msg_ok "Directorios creados"

# Copiar configuraciones a ~/.config
msg_info "Copiando configuraciones a ~/.config/..."

config_dirs=("alacritty" "bspwm" "cava" "clipcat" "dunst" "geany" "ghostty" "gtk-3.0" "jgmenu" "kitty"
             "mpd" "mpv" "ncmpcpp" "systemd" "yazi" "zsh" "st" "zathura")

copied_count=0
failed_count=0

for dir in "${config_dirs[@]}"; do
    source_path="$INSTALL_DIR/config/$dir"
    dest_path="$HOME/.config/$dir"

    if [ -d "$source_path" ]; then
        msg_info "  → $dir"

        if cp -R "$source_path" "$HOME/.config/" 2>> "$ERROR_LOG"; then
            copied_count=$((copied_count + 1))
        else
            msg_warning "Error al copiar $dir"
            log_error "Fallo al copiar $source_path"
            failed_count=$((failed_count + 1))
        fi
    else
        msg_warning "$dir no encontrado en dotfiles"
        log_error "Directorio no encontrado: $source_path"
    fi
done

# Copiar Neovim si el usuario lo eligió
if [ "$TRY_NVIM" = "y" ]; then
    nvim_source="$INSTALL_DIR/config/nvim"

    if [ -d "$nvim_source" ]; then
        msg_info "  → nvim (configuración personalizada)"

        if cp -R "$nvim_source" "$HOME/.config/" 2>> "$ERROR_LOG"; then
            copied_count=$((copied_count + 1))
        else
            msg_warning "Error al copiar nvim"
            log_error "Fallo al copiar nvim"
            failed_count=$((failed_count + 1))
        fi
    fi
else
    msg_info "  ⊗ nvim (saltado por elección del usuario)"
fi

msg_ok "Configuraciones copiadas a ~/.config/: $copied_count"

# Copiar archivos a ~/.local/share
msg_info "Copiando archivos a ~/.local/share/..."

misc_dirs=("applications" "asciiart" "fonts")

for dir in "${misc_dirs[@]}"; do
    source_path="$INSTALL_DIR/misc/$dir"

    if [ -d "$source_path" ]; then
        msg_info "  → $dir"

        if cp -R "$source_path" "$HOME/.local/share/" 2>> "$ERROR_LOG"; then
            copied_count=$((copied_count + 1))
        else
            msg_warning "Error al copiar $dir"
            log_error "Fallo al copiar $source_path"
            failed_count=$((failed_count + 1))
        fi
    else
        msg_warning "$dir no encontrado en misc/"
    fi
done

# Copiar bin a ~/.local/
bin_source="$INSTALL_DIR/misc/bin"
if [ -d "$bin_source" ]; then
    msg_info "  → bin"

    if cp -R "$bin_source" "$HOME/.local/" 2>> "$ERROR_LOG"; then
        chmod +x "$HOME/.local/bin/"* 2>/dev/null
        copied_count=$((copied_count + 1))
        msg_ok "Scripts en ~/.local/bin/ ahora son ejecutables"
    else
        msg_warning "Error al copiar bin"
        log_error "Fallo al copiar bin"
        failed_count=$((failed_count + 1))
    fi
fi

msg_ok "Archivos copiados a ~/.local/share/: $copied_count"

# Copiar archivos a $HOME
msg_info "Copiando archivos a $HOME..."

home_files=(".icons" ".zshrc" ".gtkrc-2.0")

for file in "${home_files[@]}"; do
    source_path="$INSTALL_DIR/home/$file"

    if [ -e "$source_path" ]; then
        msg_info "  → $file"

        if cp -R "$source_path" "$HOME/" 2>> "$ERROR_LOG"; then
            copied_count=$((copied_count + 1))
        else
            msg_warning "Error al copiar $file"
            log_error "Fallo al copiar $source_path"
            failed_count=$((failed_count + 1))
        fi
    else
        msg_warning "$file no encontrado en home/"
    fi
done

msg_ok "Archivos copiados a $HOME: ${#home_files[@]}"

# Configurar Firefox
msg_info "Configurando Firefox..."

firefox_profile=$(find "$HOME/.mozilla/firefox" "$HOME/.config/mozilla/firefox" -maxdepth 1 -type d \
    \( -name "*.default-release" -o -name "*.default-esr" \) 2>/dev/null | head -n1)

if [ -n "$firefox_profile" ] && [ -d "$firefox_profile" ]; then
    msg_ok "Perfil de Firefox encontrado"

    firefox_source="$INSTALL_DIR/misc/firefox"

    if [ -d "$firefox_source" ]; then
        if cp -R "$firefox_source/"* "$firefox_profile/" 2>> "$ERROR_LOG"; then
            msg_ok "Tema de Firefox instalado"

            user_js="$firefox_profile/user.js"
            if [ -f "$user_js" ]; then
                sed -i "s|/home/z0mbi3|$HOME|g" "$user_js" 2>> "$ERROR_LOG"
                msg_ok "Rutas de Firefox actualizadas"
            fi
        else
            msg_warning "Error al copiar configuración de Firefox"
        fi
    fi
else
    msg_info "Firefox no instalado o perfil no encontrado (no crítico)"
fi

# Copiar y personalizar startup-page (nombre y zona horaria)
if [ -d "$INSTALL_DIR/misc/startup-page" ]; then
    cp -R "$INSTALL_DIR/misc/startup-page" "$HOME/.local/share/" 2>> "$ERROR_LOG"
fi

startup_config="$HOME/.local/share/startup-page/config.js"
if [ -f "$startup_config" ]; then
    timezone=$(timedatectl show --property=Timezone --value 2>/dev/null)
    [ -z "$timezone" ] && timezone=$(readlink /etc/localtime 2>/dev/null | sed 's|.*/zoneinfo/||')

    sed -i \
        -e "0,/^[[:space:]]*name:/s|'.*'|'$USER'|" \
        -e "/^[[:space:]]*timeZone:/s|'.*'|'$timezone'|" \
        "$startup_config" 2>> "$ERROR_LOG"
    msg_ok "Startup page personalizada con tu usuario y zona horaria"
fi

# Actualizar caché de fuentes
msg_info "Actualizando caché de fuentes..."
if fc-cache -rv >> "$ERROR_LOG" 2>&1; then
    msg_ok "Caché de fuentes actualizado"
else
    msg_warning "Error al actualizar caché de fuentes (no crítico)"
fi

# Generar directorios XDG
msg_info "Generando directorios XDG del usuario..."
if [ ! -e "$HOME/.config/user-dirs.dirs" ]; then
    xdg-user-dirs-update
    msg_ok "Directorios XDG creados"
else
    msg_info "Directorios XDG ya existen"
fi

echo
msg_ok "Instalación de dotfiles completada"
msg_info "Archivos copiados exitosamente: $copied_count"

if [ $failed_count -gt 0 ]; then
    msg_warning "Archivos con errores: $failed_count"
    msg_info "Revisa el log: $ERROR_LOG"
fi

log_info "Dotfiles instalados: $copied_count exitosos, $failed_count fallos"
echo

# ============================================
# CONFIGURACIÓN DE SERVICIOS
# ============================================
section_banner "Configuración de Servicios"

# Configurar MPD
msg_info "Configurando MPD..."

if systemctl is-enabled --quiet mpd.service 2>/dev/null; then
    msg_info "Deshabilitando servicio global de MPD..."

    if sudo systemctl disable --now mpd.service >> "$ERROR_LOG" 2>&1; then
        msg_ok "Servicio global de MPD deshabilitado"
    else
        msg_warning "Error al deshabilitar servicio global de MPD"
        log_error "Fallo al deshabilitar MPD global"
    fi
else
    msg_info "Servicio global de MPD no está habilitado"
fi

msg_info "Habilitando servicio de usuario de MPD..."

if systemctl --user enable --now mpd.service >> "$ERROR_LOG" 2>&1; then
    msg_ok "Servicio de usuario de MPD habilitado"
else
    msg_warning "Error al habilitar servicio de usuario de MPD"
    log_error "Fallo al habilitar MPD usuario"
fi

if systemctl --user is-active --quiet mpd.service; then
    msg_ok "MPD está activo y funcionando"
else
    msg_warning "MPD no está activo (puede iniciarse después del reinicio)"
fi

# Configurar shell por defecto (Zsh)
msg_info "Configurando Zsh como shell por defecto..."

current_shell=$(getent passwd "$USER" | cut -d: -f7)
zsh_path=$(command -v zsh)

if [ -z "$zsh_path" ]; then
    msg_error "Zsh no está instalado"
    log_error "Zsh no encontrado en el sistema"
else
    msg_info "Zsh encontrado en: $zsh_path"

    if [ "$current_shell" != "$zsh_path" ]; then
        msg_info "Cambiando shell de $current_shell a $zsh_path..."

        if chsh -s "$zsh_path" >> "$ERROR_LOG" 2>&1; then
            msg_ok "Shell cambiado exitosamente a Zsh"
            msg_warning "Cierra sesión y vuelve a iniciar para aplicar el cambio"
        else
            msg_error "Error al cambiar shell"
            msg_info "Puedes cambiarlo manualmente con: chsh -s $zsh_path"
            log_error "Fallo al cambiar shell a zsh"
        fi
    else
        msg_ok "Zsh ya es tu shell por defecto"
    fi
fi

# Detectar máquina virtual y ajustar picom
msg_info "Detectando si se ejecuta en máquina virtual..."

is_vm=false

if command_exists systemd-detect-virt; then
    if systemd-detect-virt --quiet 2>/dev/null; then
        is_vm=true
        vm_type=$(systemd-detect-virt 2>/dev/null)
        msg_warning "Máquina virtual detectada: $vm_type"
    fi
fi

if [ "$is_vm" = false ]; then
    if dmesg 2>/dev/null | grep -qi "hypervisor\|virtualbox\|vmware\|qemu\|kvm"; then
        is_vm=true
        msg_warning "Máquina virtual detectada (vía dmesg)"
    fi
fi

if [ "$is_vm" = false ]; then
    msg_ok "Sistema ejecutándose en hardware físico"
else
    msg_info "Ajustando configuración de Picom para VM..."

    picom_config="$HOME/.config/bspwm/config/picom/picom.conf"

    if [ -f "$picom_config" ]; then
        if sed -i 's/backend = "glx"/backend = "xrender"/' "$picom_config" 2>> "$ERROR_LOG"; then
            msg_ok "Backend de Picom cambiado a xrender"
        else
            msg_warning "Error al cambiar backend de Picom"
            log_error "Fallo sed backend picom"
        fi

        if sed -i 's/vsync = true/vsync = false/' "$picom_config" 2>> "$ERROR_LOG"; then
            msg_ok "VSync de Picom deshabilitado"
        else
            msg_warning "Error al deshabilitar vsync de Picom"
            log_error "Fallo sed vsync picom"
        fi

        msg_ok "Picom optimizado para máquina virtual"
    else
        msg_warning "Archivo de configuración de Picom no encontrado"
        msg_info "Ubicación esperada: $picom_config"
        log_error "picom.conf no encontrado"
    fi
fi

# Verificar permisos de scripts
msg_info "Verificando permisos de scripts..."

if [ -d "$HOME/.local/bin" ]; then
    script_count=$(find "$HOME/.local/bin" -type f | wc -l)

    if [ "$script_count" -gt 0 ]; then
        chmod +x "$HOME/.local/bin/"* 2>/dev/null
        msg_ok "Permisos de ejecución establecidos para $script_count scripts"
    fi
fi

if [ -d "$HOME/.config/bspwm" ]; then
    chmod +x "$HOME/.config/bspwm/bspwmrc" 2>/dev/null
    chmod +x "$HOME/.config/bspwm/bin/"* 2>/dev/null
    msg_ok "Permisos establecidos para scripts de bspwm"
fi

# Verificar configuración de sxhkd
msg_info "Verificando configuración de sxhkd..."

sxhkdrc="$HOME/.config/bspwm/config/sxhkdrc"
if [ -f "$sxhkdrc" ]; then
    msg_ok "Archivo sxhkdrc encontrado"
else
    msg_warning "Archivo sxhkdrc no encontrado"
    log_error "sxhkdrc no encontrado en $sxhkdrc"
fi

echo
msg_ok "Configuración de servicios completada"
log_info "Servicios configurados exitosamente"
echo
