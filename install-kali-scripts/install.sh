#!/bin/bash
#  ██████╗ ██╗  ██╗ ██████╗ ███████╗████████╗███████╗██╗  ██╗    ██████╗  ██████╗ ████████╗███████╗
# ██╔════╝ ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝╚══███╔╝██║ ██╔╝    ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝
# ██║  ███╗███████║██║   ██║███████╗   ██║     ███╔╝ █████╔╝     ██║  ██║██║   ██║   ██║   ███████╗
# ██║   ██║██╔══██║██║   ██║╚════██║   ██║    ███╔╝  ██╔═██╗     ██║  ██║██║   ██║   ██║   ╚════██║
# ╚██████╔╝██║  ██║╚██████╔╝███████║   ██║   ███████╗██║  ██╗    ██████╔╝╚██████╔╝   ██║   ███████║
#  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝    ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝
#
# INSTALADOR DE DOTFILES PARA KALI LINUX
# Adaptado de los dotfiles de gh0stzk para Arch Linux
#
# Autor: gh0stzk
# Repositorio: https://github.com/gh0stzk/dotfiles
# Adaptación para Kali: Script modular
#
# Copyright (C) 2021-2025 gh0stzk <z0mbi3.zk@protonmail.com>
# Licensed under GPL-3.0 license

set -eo pipefail

# Cargar funciones comunes
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# ============================================
# BANNER DE BIENVENIDA
# ============================================
welcome() {
    clear
    logo "Bienvenido $USER"

    cat << EOF

${BLD}${CGR}Este script instalará los dotfiles de gh0stzk en tu sistema Kali Linux${CNC}

${BLD}${CYE}¿Qué se instalará?${CNC}

  ${BLD}${CGR}[${CYE}1${CGR}]${CNC} ${BLD}Sistema y Paquetes APT${CNC}
      • Verificación del sistema
      • ~100 paquetes desde repositorios Debian/Kali
      • bspwm, polybar, rofi, dunst, picom, etc.

  ${BLD}${CGR}[${CYE}2${CGR}]${CNC} ${BLD}Compilación de Herramientas${CNC}
      • Rust/Cargo + yazi + xcolor
      • eww (ElKowar's Wacky Widgets)
      • xwinwrap (fondos animados)
      • Plugins de Zsh (fzf-tab, history-substring-search)

  ${BLD}${CGR}[${CYE}3${CGR}]${CNC} ${BLD}Fuentes y Temas${CNC}
      • Fuentes Nerd Fonts (JetBrains Mono, Terminus, etc.)
      • Paquetes personalizados de gh0stzk
      • Temas GTK, iconos, cursores

  ${BLD}${CGR}[${CYE}4${CGR}]${CNC} ${BLD}Dotfiles y Configuración${CNC}
      • Copia de los dotfiles de este repositorio (rama actual)
      • Respaldo de configuraciones existentes
      • Instalación de dotfiles
      • Configuración de servicios (MPD, shell, etc.)
      • Optimizaciones para máquinas virtuales

${BLD}${CRE}[!]${CNC} ${BLD}${CYE}Importante:${CNC}
  • Este script NO modifica configuraciones del sistema
  • Todas tus configuraciones actuales se respaldarán
  • El proceso puede tomar 15-30 minutos
  • Se requiere conexión a Internet estable

${BLD}${CGR}[i]${CNC} ${BLD}${CCY}Instalación modular:${CNC}
  Puedes ejecutar módulos individuales desde ${CBL}modules/${CNC}
  o usar este script para instalación completa

EOF

    if ! ask_confirm "¿Deseas continuar con la instalación?"; then
        msg_warning "Instalación cancelada por el usuario"
        exit 0
    fi
}

# ============================================
# EJECUTAR MÓDULO
# ============================================
run_module() {
    local module_num="$1"
    local module_name="$2"
    local module_script="$SCRIPT_DIR/modules/${module_num}-${module_name}.sh"

    if [ ! -f "$module_script" ]; then
        msg_error "Módulo no encontrado: $module_script"
        return 1
    fi

    if bash "$module_script"; then
        msg_ok "Módulo completado: $module_name"
        return 0
    else
        msg_error "Módulo falló: $module_name"
        log_error "Fallo en módulo: $module_name"
        return 1
    fi
}

# ============================================
# INSTALACIÓN COMPLETA
# ============================================
full_installation() {
    local start_time=$(date +%s)
    local failed_modules=()

    section_banner "INICIO DE INSTALACIÓN"

    # Array de módulos a ejecutar
    modules=(
        "01:setup-packages:Sistema y Paquetes APT"
        "02:compile-build:Compilación de Herramientas"
        "03:fonts-themes:Fuentes y Temas"
        "04:dotfiles-config:Dotfiles y Configuración"
    )

    total_modules=${#modules[@]}
    current_module=0

    for module_info in "${modules[@]}"; do
        current_module=$((current_module + 1))

        IFS=':' read -r num name desc <<< "$module_info"

        echo
        echo "${BLD}${CBL}╔════════════════════════════════════════════════════════════╗${CNC}"
        printf "${BLD}${CBL}║${CNC} ${BLD}${CYE}Módulo %d/%d:${CNC} %-44s ${BLD}${CBL}║${CNC}\n" "$current_module" "$total_modules" "$desc"
        echo "${BLD}${CBL}╚════════════════════════════════════════════════════════════╝${CNC}"
        echo

        if run_module "$num" "$name"; then
            log_info "Módulo $num ($name) completado exitosamente"
        else
            failed_modules+=("$desc")
            msg_error "Módulo $num ($name) falló"

            # Preguntar si continuar
            echo
            if ! ask_confirm "¿Deseas continuar con la instalación a pesar del error?"; then
                msg_warning "Instalación detenida por el usuario"
                break
            fi
        fi

        # Limpiar directorio temporal después de cada módulo
        cleanup_temp_dir
    done

    # Calcular tiempo transcurrido
    local end_time=$(date +%s)
    local elapsed=$((end_time - start_time))
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))

    # Mostrar resumen
    section_banner "RESUMEN DE INSTALACIÓN"

    echo "${BLD}${CGR}Instalación completada${CNC}"
    echo
    printf "${BLD}${CCY}Tiempo transcurrido:${CNC} %d minutos, %d segundos\n" "$minutes" "$seconds"
    echo

    if [ ${#failed_modules[@]} -eq 0 ]; then
        echo "${BLD}${CGR}✓ Todos los módulos se completaron exitosamente${CNC}"
    else
        echo "${BLD}${CRE}⚠ Algunos módulos presentaron errores:${CNC}"
        for failed in "${failed_modules[@]}"; do
            echo "  ${BLD}${CRE}✗${CNC} $failed"
        done
        echo
        echo "${BLD}${CYE}Revisa el log de errores:${CNC} $ERROR_LOG"
    fi

    echo
    echo "${BLD}${CCY}Archivos importantes:${CNC}"
    echo "  ${BLD}${CGR}•${CNC} Dotfiles: ${CBL}$HOME/.local/share/gh0stzk${CNC}"
    echo "  ${BLD}${CGR}•${CNC} Configuración: ${CBL}$HOME/.config/${CNC}"
    echo "  ${BLD}${CGR}•${CNC} Respaldo: ${CBL}$HOME/.RiceBackup/${CNC}"
    echo "  ${BLD}${CGR}•${CNC} Log de errores: ${CBL}$ERROR_LOG${CNC}"
    echo
}

# ============================================
# PROMPT FINAL
# ============================================
final_prompt() {
    section_banner "INSTALACIÓN FINALIZADA"

    cat << EOF

${BLD}${CGR}¡Instalación completada exitosamente!${CNC}

${BLD}${CYE}Próximos pasos:${CNC}

  ${BLD}${CGR}1.${CNC} ${BLD}Reinicia tu sistema${CNC} para aplicar todos los cambios
  ${BLD}${CGR}2.${CNC} Selecciona ${BLD}${CBL}bspwm${CNC} en el gestor de inicio de sesión
  ${BLD}${CGR}3.${CNC} Usa ${BLD}${CBL}Super + Return${CNC} para abrir una terminal
  ${BLD}${CGR}4.${CNC} Presiona ${BLD}${CBL}Super + Shift + R${CNC} para ver los atajos de teclado

${BLD}${CCY}Temas disponibles:${CNC}
  Usa ${BLD}${CBL}Super + Alt + [1-9]${CNC} para cambiar entre temas

${BLD}${CRE}[!]${CNC} ${BLD}${CRE}Es NECESARIO reiniciar para que los cambios surtan efecto${CNC}

EOF

    if ask_confirm "¿Deseas reiniciar ahora?"; then
        msg_info "Reiniciando sistema en 3 segundos..."
        sleep 3
        sudo reboot
    else
        msg_warning "Recuerda reiniciar tu sistema manualmente"
        msg_info "Usa: sudo reboot"
    fi
}

# ============================================
# MENÚ PRINCIPAL
# ============================================
main_menu() {
    clear
    logo "Menú Principal"

    cat << EOF

${BLD}${CYE}Selecciona una opción:${CNC}

  ${BLD}${CGR}1.${CNC} Instalación completa (recomendado)
  ${BLD}${CGR}2.${CNC} Mostrar módulos disponibles
  ${BLD}${CGR}3.${CNC} Ejecutar módulo específico
  ${BLD}${CGR}4.${CNC} Ver información del sistema
  ${BLD}${CGR}5.${CNC} Salir

EOF

    printf "${BLD}${CYE}Opción [1-5]:${CNC} "
    read -r option

    case "$option" in
        1)
            welcome
            full_installation
            final_prompt
            ;;
        2)
            show_modules
            pause_with_msg
            main_menu
            ;;
        3)
            select_module
            pause_with_msg
            main_menu
            ;;
        4)
            show_system_info
            pause_with_msg
            main_menu
            ;;
        5)
            msg_info "Saliendo..."
            exit 0
            ;;
        *)
            msg_error "Opción inválida"
            sleep 2
            main_menu
            ;;
    esac
}

# ============================================
# MOSTRAR MÓDULOS
# ============================================
show_modules() {
    clear
    section_banner "Módulos Disponibles"

    cat << EOF
${BLD}${CYE}01.${CNC} setup-packages     - Sistema y Paquetes APT
     • Verificación del sistema
     • Instalación de ~100 paquetes desde APT

${BLD}${CYE}02.${CNC} compile-build      - Compilación de Herramientas
     • Rust/Cargo + yazi + xcolor
     • eww (widgets)
     • xwinwrap (fondos animados)
     • Herramientas adicionales

${BLD}${CYE}03.${CNC} fonts-themes       - Fuentes y Temas
     • Nerd Fonts (JetBrains, Terminus, etc.)
     • Paquetes personalizados gh0stzk
     • Temas GTK, iconos, cursores

${BLD}${CYE}04.${CNC} dotfiles-config    - Dotfiles y Configuración
     • Clonar dotfiles oficiales
     • Respaldo de configuraciones
     • Instalación de dotfiles
     • Configurar servicios

${BLD}${CCY}Puedes ejecutar módulos individuales con:${CNC}
${BLD}${CBL}bash modules/0X-nombre-modulo.sh${CNC}

EOF
}

# ============================================
# SELECCIONAR MÓDULO
# ============================================
select_module() {
    show_modules
    echo
    printf "${BLD}${CYE}Número de módulo [1-4]:${CNC} "
    read -r module_num

    # Validar entrada
    if [[ ! "$module_num" =~ ^[1-4]$ ]]; then
        msg_error "Número de módulo inválido"
        return 1
    fi

    # Formatear número con cero inicial
    module_num=$(printf "%02d" "$module_num")

    # Buscar archivo de módulo
    module_file=$(find "$SCRIPT_DIR/modules" -name "${module_num}-*.sh" | head -n1)

    if [ -z "$module_file" ]; then
        msg_error "Módulo no encontrado: $module_num"
        return 1
    fi

    module_name=$(basename "$module_file" .sh | cut -d'-' -f2-)

    echo
    msg_info "Ejecutando módulo: $module_name"
    echo

    bash "$module_file"
}

# ============================================
# MOSTRAR INFO DEL SISTEMA
# ============================================
show_system_info() {
    clear
    section_banner "Información del Sistema"

    echo "${BLD}${CYE}Sistema Operativo:${CNC}"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "  Distribución: $PRETTY_NAME"
        echo "  Versión: $VERSION"
    fi

    echo
    echo "${BLD}${CYE}Usuario:${CNC}"
    echo "  Nombre: $USER"
    echo "  Home: $HOME"
    echo "  Shell: $SHELL"

    echo
    echo "${BLD}${CYE}Hardware:${CNC}"
    echo "  Kernel: $(uname -r)"
    echo "  Arquitectura: $(uname -m)"

    echo
    echo "${BLD}${CYE}Espacio en disco:${CNC}"
    df -h "$HOME" | tail -n1 | awk '{print "  Usado: " $3 " / " $2 " (" $5 ")"}'

    echo
    echo "${BLD}${CYE}Herramientas instaladas:${CNC}"

    tools=("git" "curl" "wget" "cargo" "rustc" "eww" "bspwm" "polybar" "rofi")

    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            version=$($tool --version 2>/dev/null | head -n1 || echo "instalado")
            printf "  ${BLD}${CGR}✓${CNC} %-12s %s\n" "$tool" "$version"
        else
            printf "  ${BLD}${CRE}✗${CNC} %-12s no instalado\n" "$tool"
        fi
    done

    echo
}

# ============================================
# MAIN
# ============================================
main() {
    # Si se ejecuta sin argumentos, mostrar menú
    if [ $# -eq 0 ]; then
        main_menu
    else
        # Permitir ejecutar con argumentos
        case "$1" in
            --full|-f)
                welcome
                full_installation
                final_prompt
                ;;
            --help|-h)
                cat << EOF
Uso: $0 [OPCIÓN]

Instalador modular de dotfiles gh0stzk para Kali Linux

Opciones:
  --full, -f    Instalación completa sin menú interactivo
  --help, -h    Mostrar esta ayuda
  --info, -i    Mostrar información del sistema

Sin argumentos: Muestra menú interactivo

Módulos disponibles:
  01-setup-packages   - Sistema y paquetes APT
  02-compile-build    - Compilación de herramientas
  03-fonts-themes     - Fuentes y temas
  04-dotfiles-config  - Dotfiles y configuración

Para ejecutar módulos individuales:
  bash modules/0X-nombre-modulo.sh
EOF
                ;;
            --info|-i)
                show_system_info
                ;;
            *)
                msg_error "Opción desconocida: $1"
                msg_info "Usa --help para ver opciones disponibles"
                exit 1
                ;;
        esac
    fi
}

# Ejecutar función principal
main "$@"
