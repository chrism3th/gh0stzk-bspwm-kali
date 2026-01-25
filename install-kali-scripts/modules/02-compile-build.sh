#!/bin/bash
#
# 02-compile-build.sh - Compilar herramientas desde fuente
# Incluye: Rust/Cargo, eww, xwinwrap, y herramientas adicionales
#

source "$(dirname "$(dirname "$0")")/common.sh"

create_temp_dir

# ============================================
# INSTALACIÓN DE RUST Y CARGO
# ============================================
section_banner "Instalación de Rust/Cargo"

if command_exists rustc && command_exists cargo; then
    rust_version=$(rustc --version)
    msg_ok "Rust ya está instalado: $rust_version"

    msg_info "Actualizando Rust a la última versión..."
    if rustup update >> "$ERROR_LOG" 2>&1; then
        msg_ok "Rust actualizado correctamente"
    else
        msg_warning "No se pudo actualizar Rust (puede no ser crítico)"
    fi
else
    msg_info "Instalando Rust mediante rustup..."

    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >> "$ERROR_LOG" 2>&1; then
        msg_ok "Rustup instalado correctamente"

        source "$HOME/.cargo/env"

        if command_exists rustc && command_exists cargo; then
            rust_version=$(rustc --version)
            cargo_version=$(cargo --version)
            msg_ok "Rust instalado: $rust_version"
            msg_ok "Cargo instalado: $cargo_version"
        else
            msg_error "Rust se instaló pero no se encuentra en el PATH"
            msg_info "Intenta cerrar y abrir una nueva terminal"
            exit 1
        fi
    else
        msg_error "Fallo al instalar Rust"
        log_error "Fallo en instalación de rustup"
        exit 1
    fi
fi

# Asegurar que cargo/bin está en el PATH
if [ -d "$HOME/.cargo/bin" ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
    msg_ok "Ruta de cargo añadida al PATH"
fi

# Instalar eza (reemplazo moderno de ls)
if command_exists eza; then
    msg_ok "eza ya está instalado"
else
    msg_info "Instalando eza..."
    if cargo install eza >> "$ERROR_LOG" 2>&1; then
        msg_ok "eza instalado correctamente"
    else
        msg_warning "Fallo al instalar eza (no crítico)"
        log_error "Fallo al instalar eza desde cargo"
    fi
fi

# Instalar yazi (file manager para terminal)
if command_exists yazi; then
    msg_ok "yazi ya está instalado"
else
    msg_info "Instalando yazi (puede tomar varios minutos)..."
    if cargo install --locked yazi-fm yazi-cli >> "$ERROR_LOG" 2>&1; then
        msg_ok "yazi instalado correctamente"
    else
        msg_warning "Fallo al instalar yazi (no crítico)"
        log_error "Fallo al instalar yazi desde cargo"
    fi
fi

msg_ok "Instalación de Rust y herramientas completada"
echo

# ============================================
# COMPILACIÓN DE EWW
# ============================================
section_banner "Compilación de Eww"

if command_exists eww; then
    eww_version=$(eww --version 2>/dev/null || echo "versión desconocida")
    msg_ok "eww ya está instalado: $eww_version"

    if ! ask_confirm "¿Deseas recompilar eww de todas formas?"; then
        msg_info "Saltando compilación de eww"
    else
        COMPILE_EWW=true
    fi
else
    COMPILE_EWW=true
fi

if [ "${COMPILE_EWW:-false}" = true ]; then
    if ! command_exists cargo; then
        msg_error "Cargo no está instalado"
        exit 1
    fi

    msg_info "Clonando repositorio de eww..."
    EWW_DIR="$TEMP_DIR/eww"

    if git clone --depth=1 https://github.com/elkowar/eww.git "$EWW_DIR" >> "$ERROR_LOG" 2>&1; then
        msg_ok "Repositorio clonado correctamente"

        cd "$EWW_DIR" || exit 1

        msg_info "Compilando eww (esto puede tomar 10-15 minutos)..."
        msg_warning "Por favor, ten paciencia..."

        if cargo build --release --no-default-features --features x11 >> "$ERROR_LOG" 2>&1; then
            msg_ok "Compilación exitosa"

            if [ -f "target/release/eww" ]; then
                chmod +x target/release/eww

                if sudo cp target/release/eww /usr/local/bin/ 2>> "$ERROR_LOG"; then
                    msg_ok "eww instalado en /usr/local/bin/eww"

                    if command_exists eww; then
                        eww_version=$(eww --version 2>/dev/null || echo "versión desconocida")
                        msg_ok "eww instalado y verificado: $eww_version"
                    fi
                else
                    msg_error "Fallo al copiar binario de eww"
                    log_error "Fallo al copiar eww a /usr/local/bin"
                fi
            else
                msg_error "El binario de eww no fue creado"
                log_error "Binario de eww no encontrado después de compilación"
            fi
        else
            msg_error "Fallo durante la compilación de eww"
            msg_info "Revisa el log: $ERROR_LOG"
            log_error "Compilación de eww falló"
        fi

        cd - > /dev/null
    else
        msg_error "Fallo al clonar repositorio de eww"
        log_error "Git clone eww falló"
    fi
fi

echo

# ============================================
# COMPILACIÓN DE XWINWRAP
# ============================================
section_banner "Compilación de xwinwrap"

if command_exists xwinwrap; then
    msg_ok "xwinwrap ya está instalado"

    if ! ask_confirm "¿Deseas recompilar xwinwrap de todas formas?"; then
        msg_info "Saltando compilación de xwinwrap"
    else
        COMPILE_XWIN=true
    fi
else
    COMPILE_XWIN=true
fi

if [ "${COMPILE_XWIN:-false}" = true ]; then
    msg_info "Clonando repositorio de xwinwrap..."
    XWINWRAP_DIR="$TEMP_DIR/xwinwrap"

    if git clone --depth=1 https://github.com/ujjwal96/xwinwrap.git "$XWINWRAP_DIR" >> "$ERROR_LOG" 2>&1; then
        msg_ok "Repositorio clonado correctamente"

        cd "$XWINWRAP_DIR" || exit 1

        msg_info "Compilando xwinwrap..."

        if make >> "$ERROR_LOG" 2>&1; then
            msg_ok "Compilación exitosa"

            if [ -f "xwinwrap" ]; then
                if sudo make install >> "$ERROR_LOG" 2>&1; then
                    msg_ok "xwinwrap instalado correctamente"

                    if command_exists xwinwrap; then
                        msg_ok "xwinwrap instalado y verificado"
                    fi
                else
                    msg_error "Fallo al instalar xwinwrap"
                    log_error "make install de xwinwrap falló"
                fi
            else
                msg_error "El binario de xwinwrap no fue creado"
                log_error "Binario de xwinwrap no encontrado"
            fi

            make clean >> "$ERROR_LOG" 2>&1
        else
            msg_error "Fallo durante la compilación de xwinwrap"
            msg_info "Revisa el log: $ERROR_LOG"
            log_error "Compilación de xwinwrap falló"
        fi

        cd - > /dev/null
    else
        msg_error "Fallo al clonar repositorio de xwinwrap"
        log_error "Git clone xwinwrap falló"
    fi
fi

echo

# ============================================
# COMPILACIÓN DE I3LOCK-COLOR
# ============================================
section_banner "Compilación de i3lock-color"

if command_exists i3lock-color; then
    msg_ok "i3lock-color ya está instalado"

    if ! ask_confirm "¿Deseas recompilar i3lock-color de todas formas?"; then
        msg_info "Saltando compilación de i3lock-color"
    else
        COMPILE_I3LOCK=true
    fi
else
    COMPILE_I3LOCK=true
fi

if [ "${COMPILE_I3LOCK:-false}" = true ]; then
    msg_info "Instalando dependencias para i3lock-color..."

    # Lista de dependencias necesarias
    i3lock_deps=(
        "autoconf" "gcc" "make" "pkg-config"
        "libpam0g-dev" "libcairo2-dev" "libfontconfig1-dev"
        "libxcb-composite0-dev" "libev-dev" "libx11-xcb-dev"
        "libxcb-xkb-dev" "libxcb-xinerama0-dev" "libxcb-randr0-dev"
        "libxcb-image0-dev" "libxcb-util-dev" "libxcb-xrm-dev"
        "libxkbcommon-dev" "libxkbcommon-x11-dev" "libjpeg-dev"
    )

    deps_to_install=()
    for dep in "${i3lock_deps[@]}"; do
        if ! dpkg -l | grep -q "^ii  $dep"; then
            deps_to_install+=("$dep")
        fi
    done

    if [ ${#deps_to_install[@]} -gt 0 ]; then
        msg_info "Instalando ${#deps_to_install[@]} dependencias..."
        if sudo apt install -y "${deps_to_install[@]}" >> "$ERROR_LOG" 2>&1; then
            msg_ok "Dependencias instaladas correctamente"
        else
            msg_error "Error al instalar dependencias de i3lock-color"
            msg_warning "Algunas dependencias pueden faltar, continuando de todas formas..."
            log_error "Fallo al instalar dependencias de i3lock-color"
        fi
    else
        msg_ok "Todas las dependencias ya están instaladas"
    fi

    msg_info "Clonando repositorio de i3lock-color..."
    I3LOCK_DIR="$TEMP_DIR/i3lock-color"

    if git clone --depth=1 https://github.com/Raymo111/i3lock-color.git "$I3LOCK_DIR" >> "$ERROR_LOG" 2>&1; then
        msg_ok "Repositorio clonado correctamente"

        cd "$I3LOCK_DIR" || exit 1

        msg_info "Compilando i3lock-color (puede tomar unos minutos)..."

        # Usar el script de instalación provisto
        if [ -f "install-i3lock-color.sh" ]; then
            chmod +x install-i3lock-color.sh
            if ./install-i3lock-color.sh >> "$ERROR_LOG" 2>&1; then
                msg_ok "i3lock-color instalado correctamente mediante script oficial"
            else
                msg_warning "Script oficial falló, intentando método manual..."
                log_error "install-i3lock-color.sh falló, probando método manual"

                # Método manual
                if ./build.sh >> "$ERROR_LOG" 2>&1; then
                    msg_ok "Compilación exitosa"

                    if [ -f "x86_64-pc-linux-gnu/release/i3lock" ]; then
                        if sudo cp x86_64-pc-linux-gnu/release/i3lock /usr/local/bin/i3lock-color 2>> "$ERROR_LOG"; then
                            sudo chmod +x /usr/local/bin/i3lock-color
                            msg_ok "i3lock-color instalado en /usr/local/bin/i3lock-color"
                        else
                            msg_error "Fallo al copiar binario de i3lock-color"
                            log_error "Fallo al copiar i3lock-color a /usr/local/bin"
                        fi
                    else
                        msg_error "El binario de i3lock-color no fue creado"
                        log_error "Binario de i3lock-color no encontrado después de compilación"
                    fi
                else
                    msg_error "Fallo durante la compilación de i3lock-color"
                    msg_info "Revisa el log: $ERROR_LOG"
                    log_error "Compilación de i3lock-color falló"
                fi
            fi
        else
            msg_warning "Script de instalación no encontrado, usando método manual..."

            # Método manual clásico
            if ./build.sh >> "$ERROR_LOG" 2>&1; then
                msg_ok "Compilación exitosa"

                if [ -f "x86_64-pc-linux-gnu/release/i3lock" ]; then
                    if sudo cp x86_64-pc-linux-gnu/release/i3lock /usr/local/bin/i3lock-color 2>> "$ERROR_LOG"; then
                        sudo chmod +x /usr/local/bin/i3lock-color
                        msg_ok "i3lock-color instalado en /usr/local/bin/i3lock-color"
                    else
                        msg_error "Fallo al copiar binario de i3lock-color"
                        log_error "Fallo al copiar i3lock-color a /usr/local/bin"
                    fi
                else
                    msg_error "El binario de i3lock-color no fue creado"
                    log_error "Binario de i3lock-color no encontrado después de compilación"
                fi
            else
                msg_error "Fallo durante la compilación de i3lock-color"
                msg_info "Revisa el log: $ERROR_LOG"
                log_error "Compilación de i3lock-color falló"
            fi
        fi

        # Verificar instalación
        if command_exists i3lock-color; then
            msg_ok "i3lock-color instalado y verificado"
        else
            msg_warning "i3lock-color compilado pero no encontrado en PATH"
            msg_info "Puede que necesites reiniciar o actualizar tu PATH"
        fi

        cd - > /dev/null
    else
        msg_error "Fallo al clonar repositorio de i3lock-color"
        log_error "Git clone i3lock-color falló"
    fi
fi

echo

# ============================================
# HERRAMIENTAS ADICIONALES
# ============================================
section_banner "Herramientas Adicionales"

# TDROP
msg_info "Instalando tdrop..."
if command_exists tdrop; then
    msg_ok "tdrop ya está instalado"
else
    TDROP_DIR="$TEMP_DIR/tdrop"
    if git clone --depth=1 https://github.com/noctuid/tdrop.git "$TDROP_DIR" >> "$ERROR_LOG" 2>&1; then
        cd "$TDROP_DIR" || exit 1
        if sudo make install >> "$ERROR_LOG" 2>&1; then
            msg_ok "tdrop instalado correctamente"
        else
            msg_warning "Error al instalar tdrop"
            log_error "Fallo make install de tdrop"
        fi
        cd - > /dev/null
    else
        msg_warning "Error al clonar tdrop"
        log_error "Fallo git clone de tdrop"
    fi
fi

# XQP
msg_info "Instalando xqp..."
if command_exists xqp; then
    msg_ok "xqp ya está instalado"
else
    XQP_DIR="$TEMP_DIR/xqp"
    if git clone --depth=1 https://github.com/baskerville/xqp.git "$XQP_DIR" >> "$ERROR_LOG" 2>&1; then
        cd "$XQP_DIR" || exit 1
        if make >> "$ERROR_LOG" 2>&1 && sudo make install >> "$ERROR_LOG" 2>&1; then
            msg_ok "xqp instalado correctamente"
        else
            msg_warning "Error al instalar xqp"
            log_error "Fallo compilación/instalación de xqp"
        fi
        cd - > /dev/null
    else
        msg_warning "Error al clonar xqp"
        log_error "Fallo git clone de xqp"
    fi
fi

# GREENCLIP
msg_info "Instalando greenclip..."
if command_exists greenclip; then
    msg_ok "greenclip ya está instalado"
else
    GREENCLIP_URL="https://github.com/erebe/greenclip/releases/download/v4.2/greenclip"
    GREENCLIP_DEST="/usr/local/bin/greenclip"
    if wget -q "$GREENCLIP_URL" -O "$TEMP_DIR/greenclip" 2>> "$ERROR_LOG"; then
        if sudo cp "$TEMP_DIR/greenclip" "$GREENCLIP_DEST" 2>> "$ERROR_LOG"; then
            sudo chmod +x "$GREENCLIP_DEST"
            msg_ok "greenclip instalado en $GREENCLIP_DEST"
        else
            msg_warning "Error al copiar greenclip"
            log_error "Fallo al copiar greenclip"
        fi
    else
        msg_warning "Error al descargar greenclip"
        log_error "Fallo descarga de greenclip"
    fi
fi

# ZSH PLUGINS
msg_info "Instalando plugins de Zsh..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]; then
    msg_info "Instalando zsh-history-substring-search..."
    if git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search \
        "$ZSH_CUSTOM/plugins/zsh-history-substring-search" >> "$ERROR_LOG" 2>&1; then
        msg_ok "zsh-history-substring-search instalado"
    else
        msg_warning "Error al instalar zsh-history-substring-search"
    fi
else
    msg_ok "zsh-history-substring-search ya está instalado"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
    msg_info "Instalando fzf-tab..."
    if git clone --depth=1 https://github.com/Aloxaf/fzf-tab \
        "$ZSH_CUSTOM/plugins/fzf-tab" >> "$ERROR_LOG" 2>&1; then
        msg_ok "fzf-tab instalado"
    else
        msg_warning "Error al instalar fzf-tab"
    fi
else
    msg_ok "fzf-tab ya está instalado"
fi

# Verificar jgmenu
if ! command_exists jgmenu; then
    msg_warning "jgmenu no está instalado, instalando desde APT..."
    sudo apt install -y jgmenu >> "$ERROR_LOG" 2>&1
fi

msg_ok "Instalación de herramientas adicionales completada"
log_info "Herramientas compiladas e instaladas"
echo
