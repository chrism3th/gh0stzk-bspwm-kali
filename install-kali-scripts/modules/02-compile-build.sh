#!/bin/bash
#
# 02-compile-build.sh - Compilar herramientas desde fuente
# Incluye: Rust/Cargo, eww, xwinwrap, y herramientas adicionales
#

source "$(dirname "$(dirname "$0")")/common.sh"

create_temp_dir
touch "$ERROR_LOG" 2>/dev/null || true

# --------------------------------------------
# Logging helpers (do NOT hide command output)
# --------------------------------------------
# Run a command and:
# - show stdout/stderr in terminal
# - append stdout/stderr to $ERROR_LOG
# - preserve the original exit code
run_logged() {
    "$@" 2>&1 | tee -a "$ERROR_LOG"
    return ${PIPESTATUS[0]}
}

# Same as run_logged, but for complex shell pipelines.
run_logged_sh() {
    bash -c "$1" 2>&1 | tee -a "$ERROR_LOG"
    return ${PIPESTATUS[0]}
}

# ============================================
# INSTALACIÓN DE RUST Y CARGO
# ============================================
section_banner "Instalación de Rust/Cargo"

ensure_rust_and_cargo() {
    if command_exists rustc && command_exists cargo; then
        rust_version=$(rustc --version 2>/dev/null || echo "versión desconocida")
        msg_ok "Rust ya está instalado: $rust_version"

        if command_exists rustup; then
            msg_info "Actualizando Rust a la última versión..."
            if run_logged rustup update; then
                msg_ok "Rust actualizado correctamente"
            else
                msg_warning "No se pudo actualizar Rust (puede no ser crítico)"
            fi
        fi

        return 0
    fi

    msg_info "Instalando Rust..."

    # Prefer rustup, fall back to APT if rustup fails (network/TLS issues are common).
    if run_logged_sh 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'; then
        msg_ok "Rustup instalado correctamente"
        if [ -f "$HOME/.cargo/env" ]; then
            # shellcheck disable=SC1090
            source "$HOME/.cargo/env" 2>/dev/null || true
        fi
    else
        msg_warning "Fallo al instalar Rust con rustup, intentando instalar desde APT..."
        log_error "rustup falló; intentando APT (rustc cargo)"

        if run_logged sudo apt install -y rustc cargo; then
            msg_ok "Rust instalado desde APT"
        else
            msg_warning "No se pudo instalar Rust/Cargo desde APT"
            log_error "APT install rustc cargo falló"
            return 1
        fi
    fi

    # Asegurar que cargo/bin está en el PATH (si existe).
    if [ -d "$HOME/.cargo/bin" ]; then
        export PATH="$HOME/.cargo/bin:$PATH"
    fi

    if command_exists rustc && command_exists cargo; then
        rust_version=$(rustc --version 2>/dev/null || echo "versión desconocida")
        cargo_version=$(cargo --version 2>/dev/null || echo "versión desconocida")
        msg_ok "Rust disponible: $rust_version"
        msg_ok "Cargo disponible: $cargo_version"
        return 0
    fi

    msg_warning "Rust/Cargo no están disponibles; se omitirán herramientas basadas en cargo"
    log_error "rustc/cargo no disponibles tras instalación"
    return 1
}

HAS_CARGO=false
if ensure_rust_and_cargo; then
    HAS_CARGO=true
    msg_ok "Rust/Cargo listos (si aplica)"
fi

# Instalar yazi (file manager para terminal)
if [ "$HAS_CARGO" = true ] && command_exists cargo; then
    if command_exists yazi; then
        msg_ok "yazi ya está instalado"
    else
        msg_info "Instalando yazi (puede tomar varios minutos)..."
        if run_logged cargo install --locked yazi-fm yazi-cli; then
            msg_ok "yazi instalado correctamente"
        else
            msg_warning "Fallo al instalar yazi (no crítico)"
            log_error "Fallo al instalar yazi desde cargo"
        fi
    fi
else
    msg_warning "Cargo no disponible; omitiendo instalación de yazi"
fi

# Instalar xcolor (color picker usado por Colorpicker)
if [ "$HAS_CARGO" = true ] && command_exists cargo; then
    if command_exists xcolor; then
        msg_ok "xcolor ya está instalado"
    else
        msg_info "Instalando xcolor..."
        if run_logged cargo install --locked xcolor; then
            msg_ok "xcolor instalado correctamente"
        else
            msg_warning "Fallo al instalar xcolor (no crítico)"
            log_error "Fallo al instalar xcolor desde cargo"
        fi
    fi
else
    msg_warning "Cargo no disponible; omitiendo instalación de xcolor"
fi

msg_ok "Instalación de Rust y herramientas completada"
echo

# Enlazar binarios de cargo en /usr/local/bin: la sesión X (sxhkd, polybar)
# no siempre carga ~/.cargo/env; sin esto Colorpicker o Term --yazi pueden fallar.
for bin in yazi ya xcolor; do
    if [ -x "$HOME/.cargo/bin/$bin" ]; then
        run_logged sudo ln -sf "$HOME/.cargo/bin/$bin" "/usr/local/bin/$bin" \
            || log_error "No se pudo enlazar $bin en /usr/local/bin"
    fi
done

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
        msg_warning "Cargo no está instalado; se omite compilación de eww"
        log_error "eww: cargo no disponible, compilación omitida"
        COMPILE_EWW=false
    fi

    msg_info "Clonando repositorio de eww..."
    EWW_DIR="$TEMP_DIR/eww"

    if run_logged git clone --depth=1 https://github.com/elkowar/eww.git "$EWW_DIR"; then
        msg_ok "Repositorio clonado correctamente"

        cd "$EWW_DIR" || exit 1

        msg_info "Compilando eww (esto puede tomar 10-15 minutos)..."
        msg_warning "Por favor, ten paciencia..."

        if run_logged cargo build --release --no-default-features --features x11; then
            msg_ok "Compilación exitosa"

            if [ -f "target/release/eww" ]; then
                chmod +x target/release/eww

                if run_logged sudo cp target/release/eww /usr/local/bin/; then
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

    if run_logged git clone --depth=1 https://github.com/ujjwal96/xwinwrap.git "$XWINWRAP_DIR"; then
        msg_ok "Repositorio clonado correctamente"

        cd "$XWINWRAP_DIR" || exit 1

        msg_info "Compilando xwinwrap..."

        if run_logged make; then
            msg_ok "Compilación exitosa"

            if [ -f "xwinwrap" ]; then
                if run_logged sudo make install; then
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

            run_logged make clean || true
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
# COMPILACIÓN DE ST (fork de gh0stzk)
# ============================================
# El paquete st-gh0stzk del repo de gh0stzk es un binario de Arch;
# se compila desde la fuente para enlazar contra las librerías de Kali.
section_banner "Compilación de st"

# Un st con librerías faltantes (p. ej. el binario de Arch) cuenta como no instalado
if command_exists st && ! ldd "$(command -v st)" 2>/dev/null | grep -q "not found"; then
    msg_ok "st ya está instalado"

    if ! ask_confirm "¿Deseas recompilar st de todas formas?"; then
        msg_info "Saltando compilación de st"
    else
        COMPILE_ST=true
    fi
else
    COMPILE_ST=true
fi

if [ "${COMPILE_ST:-false}" = true ]; then
    msg_info "Clonando repositorio de st..."
    ST_DIR="$TEMP_DIR/st-terminal"

    if run_logged git clone --depth=1 https://github.com/gh0stzk/st-terminal.git "$ST_DIR"; then
        msg_ok "Repositorio clonado correctamente"

        cd "$ST_DIR" || exit 1

        msg_info "Compilando st..."

        if run_logged make; then
            msg_ok "Compilación exitosa"

            # make install también registra el terminfo (tic -sx st.info)
            if run_logged sudo make PREFIX=/usr/local install; then
                msg_ok "st instalado en /usr/local/bin/st"
            else
                msg_error "Fallo al instalar st"
                log_error "make install de st falló"
            fi

            run_logged make clean || true
        else
            msg_error "Fallo durante la compilación de st"
            msg_info "Revisa el log: $ERROR_LOG"
            log_error "Compilación de st falló"
        fi

        cd - > /dev/null
    else
        msg_error "Fallo al clonar repositorio de st"
        log_error "Git clone st-terminal falló"
    fi
fi

echo

# ============================================
# I3LOCK-COLOR
# ============================================
# Kali empaqueta i3lock-color (se instala con apt en 01-setup-packages.sh).
# Provee /usr/bin/i3lock, que es lo que llama ScreenLocker.
section_banner "Verificación de i3lock-color"

if dpkg -s i3lock-color >/dev/null 2>&1; then
    msg_ok "i3lock-color instalado desde apt"
elif run_logged sudo apt install -y i3lock-color; then
    msg_ok "i3lock-color instalado desde apt"
else
    msg_warning "No se pudo instalar i3lock-color (ScreenLocker no funcionará)"
    log_error "apt install i3lock-color falló"
fi

echo

# ============================================
# HERRAMIENTAS ADICIONALES
# ============================================
section_banner "Herramientas Adicionales"

# ZSH PLUGINS
msg_info "Instalando plugins de Zsh..."

# Store custom Zsh plugins in a distro-agnostic location (no Oh-My-Zsh required).
ZSH_PLUGIN_DIR="${ZSH_PLUGIN_DIR:-$HOME/.config/zsh/plugins}"
mkdir -p "$ZSH_PLUGIN_DIR"

install_zsh_plugin() {
    local plugin_name="$1"
    local repo_url="$2"
    local dest_dir="${ZSH_PLUGIN_DIR}/${plugin_name}"

    if [ -d "$dest_dir" ]; then
        msg_ok "${plugin_name} ya está instalado"
        return 0
    fi

    msg_info "Instalando ${plugin_name}..."
    if run_logged git clone --depth=1 "$repo_url" "$dest_dir"; then
        msg_ok "${plugin_name} instalado"
        return 0
    fi

    msg_warning "Error al instalar ${plugin_name}"
    log_error "Git clone ${plugin_name} falló"
    return 1
}

install_zsh_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search" || true
install_zsh_plugin "fzf-tab" "https://github.com/Aloxaf/fzf-tab" || true

# Verificar jgmenu
install_jgmenu_from_source() {
    # Prefer a user-local install to avoid requiring sudo for `make install`.
    local prefix="${HOME}/.local"
    local repo_url="https://github.com/johanmalm/jgmenu.git"
    local build_dir="$TEMP_DIR/jgmenu"

    msg_info "Instalando jgmenu desde fuente (fallback)..."

    # Build dependencies (Debian/Kali)
    local deps=(
        "git" "make" "gcc" "pkg-config"
        "libx11-dev" "libxrandr-dev" "libcairo2-dev" "libpango1.0-dev" "libglib2.0-dev"
    )

    local missing=()
    for dep in "${deps[@]}"; do
        if ! dpkg -l | grep -q "^ii  $dep"; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        msg_info "Instalando dependencias de jgmenu (${#missing[@]})..."
        if ! run_logged sudo apt install -y "${missing[@]}"; then
            msg_warning "No se pudieron instalar todas las dependencias de jgmenu"
            log_error "Fallo al instalar dependencias de jgmenu: ${missing[*]}"
        fi
    fi

    rm -rf "$build_dir" 2>/dev/null || true
    if ! run_logged git clone --depth=1 "$repo_url" "$build_dir"; then
        msg_error "Fallo al clonar el repositorio de jgmenu"
        log_error "Git clone jgmenu falló"
        return 1
    fi

    cd "$build_dir" || return 1

    msg_info "Configurando jgmenu..."
    if ! run_logged ./configure --prefix="$prefix" --with-lx --with-pmenu; then
        msg_warning "configure con --with-lx/--with-pmenu falló, intentando configuración mínima..."
        log_error "jgmenu configure con extras falló; reintentando sin extras"

        if ! run_logged ./configure --prefix="$prefix"; then
            msg_error "No se pudo configurar jgmenu"
            log_error "jgmenu configure falló"
            cd - > /dev/null || true
            return 1
        fi
    fi

    msg_info "Compilando jgmenu..."
    if ! run_logged make; then
        msg_error "Fallo durante la compilación de jgmenu"
        log_error "make jgmenu falló"
        cd - > /dev/null || true
        return 1
    fi

    msg_info "Instalando jgmenu en ${prefix}..."
    if ! run_logged make install; then
        msg_error "Fallo durante la instalación de jgmenu"
        log_error "make install jgmenu falló"
        cd - > /dev/null || true
        return 1
    fi

    cd - > /dev/null || true

    # Refresh shell command cache if available.
    hash -r 2>/dev/null || true

    if command_exists jgmenu; then
        msg_ok "jgmenu instalado correctamente"
        return 0
    fi

    msg_warning "jgmenu fue instalado pero no se encuentra en PATH"
    msg_info "Asegúrate de tener ${prefix}/bin en tu PATH"
    log_error "jgmenu instalado pero no encontrado en PATH (prefix=${prefix})"
    return 1
}

if ! command_exists jgmenu; then
    msg_warning "jgmenu no está instalado, intentando instalar..."

    if apt-cache show jgmenu &>/dev/null; then
        msg_info "Instalando jgmenu desde APT..."
        if run_logged sudo apt install -y jgmenu; then
            msg_ok "jgmenu instalado desde APT"
        else
            msg_warning "Fallo al instalar jgmenu desde APT, usando fallback desde fuente..."
            log_error "APT install jgmenu falló; usando fallback"
            install_jgmenu_from_source || true
        fi
    else
        msg_warning "jgmenu no está disponible en repositorios, usando fallback desde fuente..."
        log_error "jgmenu no disponible en repos; usando fallback"
        install_jgmenu_from_source || true
    fi
fi

msg_ok "Instalación de herramientas adicionales completada"
log_info "Herramientas compiladas e instaladas"
echo
