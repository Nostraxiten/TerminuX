#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Interfaz Visual Interactiva (TUI)

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

NOXMOD_HOME="$HOME/.noxmod"

source "$SCRIPT_DIR/ui.sh"
source "$SCRIPT_DIR/ip.sh"
source "$SCRIPT_DIR/installer.sh"
source "$SCRIPT_DIR/restore.sh"

get_current_status() {
    local cur_theme="yello"
    [ -f "$NOXMOD_HOME/active-theme" ] && cur_theme="$(cat "$NOXMOD_HOME/active-theme" 2>/dev/null)"
    [ -n "$cur_theme" ] || cur_theme="yello"

    local cur_user="nox"
    [ -f "$NOXMOD_HOME/user-name" ] && cur_user="$(cat "$NOXMOD_HOME/user-name" 2>/dev/null)"
    [ -n "$cur_user" ] || cur_user="${USER:-user}"

    local cur_host="termux"
    [ -f "$NOXMOD_HOME/host-name" ] && cur_host="$(cat "$NOXMOD_HOME/host-name" 2>/dev/null)"
    [ -n "$cur_host" ] || cur_host="termux"

    local ip_mode="real"
    [ -f "$NOXMOD_HOME/ip-mode" ] && ip_mode="$(cat "$NOXMOD_HOME/ip-mode" 2>/dev/null)"
    [ -n "$ip_mode" ] || ip_mode="real"

    local cur_ip=""
    case "$ip_mode" in
        custom|fake)
            local f_ip="10.0.0.1"
            [ -f "$NOXMOD_HOME/custom-ip" ] && f_ip="$(cat "$NOXMOD_HOME/custom-ip" 2>/dev/null)"
            cur_ip="Falsa ($f_ip)"
            ;;
        off|none)
            cur_ip="Oculta"
            ;;
        real|*)
            cur_ip="Real WiFi ($(get_real_ip))"
            ;;
    esac

    printf '%s|%s|%s|%s' "$cur_theme" "$cur_user" "$cur_host" "$cur_ip"
}

render_status_card() {
    local status
    status="$(get_current_status)"
    local s_theme s_user s_host s_ip
    IFS='|' read -r s_theme s_user s_host s_ip <<< "$status"

    printf "${CLR_CYAN}  ╭────────────────────────────────────────────────────────╮\n"
    printf "  │ ${CLR_BOLD}${CLR_WHITE}ESTADO ACTUAL DE TERMINUX${CLR_RESET}${CLR_CYAN}                               │\n"
    printf "  ├────────────────────────────────────────────────────────┤\n"
    printf "  │  ${CLR_YELLOW}● Tema Activo:${CLR_RESET}   %-39s${CLR_CYAN}│\n" "$s_theme"
    if [ "$s_theme" = "root" ]; then
        printf "  │  ${CLR_RED}● Modo Root:${CLR_RESET}     %-39s${CLR_CYAN}│\n" "root@kali (Kali Linux oficial)"
    else
        printf "  │  ${CLR_GREEN}● Identidad:${CLR_RESET}     %-39s${CLR_CYAN}│\n" "${s_user}@${s_host}"
        printf "  │  ${CLR_PURPLE}● Modo IP:${CLR_RESET}       %-39s${CLR_CYAN}│\n" "$s_ip"
    fi
    printf "  ╰────────────────────────────────────────────────────────╯${CLR_RESET}\n\n"
}

menu_change_theme() {
    clear
    print_main_banner
    draw_box_header "SELECCIÓN DE TEMAS"
    echo
    printf "  ${CLR_CYAN}[1]${CLR_RESET} ${CLR_BOLD}Yello${CLR_RESET}  — Paleta suave Nightwire (cian/verde/amarillo) [Default]\n"
    printf "  ${CLR_GREEN}[2]${CLR_RESET} ${CLR_BOLD}HACK${CLR_RESET}   — Estilo Matrix Hacker (verde neón y negro profundo)\n"
    printf "  ${CLR_RED}[3]${CLR_RESET} ${CLR_BOLD}RED${CLR_RESET}    — Rojo y negro cyber con logo terminal '>_' parpadeante\n"
    printf "  ${CLR_BLUE}[4]${CLR_RESET} ${CLR_BOLD}Space${CLR_RESET}  — Azul galáctico con estrellas ASCII en la escritura\n"
    printf "  ${CLR_PURPLE}[5]${CLR_RESET} ${CLR_BOLD}ROOT${CLR_RESET}   — Réplica exacta de Kali Linux en root (bloqueado)\n"
    printf "  ${CLR_GRAY}[0]${CLR_RESET} Cancelar y volver al menú\n"
    echo
    printf "${CLR_BOLD}Elige una opción [1-5]: ${CLR_RESET}"
    local opt
    read -r opt || opt=""

    local target=""
    case "$opt" in
        1) target="yello" ;;
        2) target="hack" ;;
        3) target="red" ;;
        4) target="space" ;;
        5) target="root" ;;
        0|"") return 0 ;;
        *) c_warn "Opción inválida."; sleep 1; return 1 ;;
    esac

    switch_theme "$target"
    sleep 1.2
}

menu_configure_ip() {
    clear
    print_main_banner
    draw_box_header "CONFIGURACIÓN DE IP"
    echo

    local cur_status
    cur_status="$(get_current_status)"
    local s_theme
    IFS='|' read -r s_theme _ <<< "$cur_status"

    if [ "$s_theme" = "root" ]; then
        c_warn "El tema ROOT replica estrictamente Kali Linux y no muestra IP en el prompt."
        printf "\nPresiona ENTER para volver..."
        read -r
        return 0
    fi

    printf "  ${CLR_CYAN}[1]${CLR_RESET} IP Real (WiFi automática wlan0 sin filtrar datos móviles)\n"
    printf "  ${CLR_CYAN}[2]${CLR_RESET} IP Falsa / Personalizada (Escribe una IP personalizada)\n"
    printf "  ${CLR_CYAN}[3]${CLR_RESET} Ocultar IP del prompt\n"
    printf "  ${CLR_GRAY}[0]${CLR_RESET} Volver\n"
    echo
    printf "${CLR_BOLD}Elige una opción [1-3]: ${CLR_RESET}"
    local opt
    read -r opt || opt=""

    mkdir -p "$NOXMOD_HOME"
    case "$opt" in
        1)
            printf 'real\n' > "$NOXMOD_HOME/ip-mode"
            c_ok "Configurado a IP Real de WiFi."
            sleep 1
            ;;
        2)
            while true; do
                echo
                printf "${CLR_BOLD}Ingresa la IP deseada (entre 0.0.0.0 y 255.255.255.255): ${CLR_RESET}"
                local fake_ip
                read -r fake_ip || fake_ip=""
                [ -z "$fake_ip" ] && break

                if validate_ipv4 "$fake_ip"; then
                    printf 'custom\n' > "$NOXMOD_HOME/ip-mode"
                    printf '%s\n' "$fake_ip" > "$NOXMOD_HOME/custom-ip"
                    c_ok "IP falsa guardada correctamente: $fake_ip"
                    sleep 1.2
                    break
                else
                    c_err "'$fake_ip' no es válida. Debe tener 4 bloques entre 0 y 255 (ej: 10.0.0.1)."
                fi
            done
            ;;
        3)
            printf 'off\n' > "$NOXMOD_HOME/ip-mode"
            c_ok "Segmento de IP desactivado en el prompt."
            sleep 1
            ;;
        0|"") return 0 ;;
        *) c_warn "Opción inválida."; sleep 1 ;;
    esac
}

menu_configure_identity() {
    clear
    print_main_banner
    draw_box_header "CONFIGURACIÓN DE IDENTIDAD"
    echo

    local cur_status
    cur_status="$(get_current_status)"
    local s_theme
    IFS='|' read -r s_theme _ <<< "$cur_status"

    if [ "$s_theme" = "root" ]; then
        c_warn "El tema ROOT es la réplica exacta de Kali Linux y usa exclusivamente 'root@kali'."
        printf "\nPresiona ENTER para volver..."
        read -r
        return 0
    fi

    mkdir -p "$NOXMOD_HOME"
    local u_input h_input

    printf "Usuario actual: [${CLR_GREEN}%s${CLR_RESET}]\n" "$(terminux_get_user)"
    printf "Nuevo usuario (1-10 caracteres) [dejar vacío para mantener]: "
    read -r u_input || u_input=""
    if [ -n "$u_input" ]; then
        if [[ "$u_input" =~ ^[[:alnum:]_.-]{1,10}$ ]]; then
            printf '%s\n' "$u_input" > "$NOXMOD_HOME/user-name"
            c_ok "Usuario actualizado a: $u_input"
        else
            c_warn "Formato inválido. No se realizaron cambios."
        fi
    fi

    echo
    printf "Host actual: [${CLR_CYAN}%s${CLR_RESET}]\n" "$(terminux_get_host)"
    printf "Nuevo host (1-10 caracteres) [dejar vacío para mantener]: "
    read -r h_input || h_input=""
    if [ -n "$h_input" ]; then
        if [ "${#h_input}" -ge 1 ] && [ "${#h_input}" -le 10 ]; then
            printf '%s\n' "$h_input" > "$NOXMOD_HOME/host-name"
            c_ok "Host actualizado a: $h_input"
        else
            c_warn "Longitud inválida (1-10 caracteres). No se realizaron cambios."
        fi
    fi

    sleep 1.2
}

menu_configure_nano() {
    clear
    print_main_banner
    draw_box_header "EDITOR NANO"
    echo
    printf "  ${CLR_CYAN}[1]${CLR_RESET} Sincronizar colores de Nano con el tema actual\n"
    printf "  ${CLR_CYAN}[2]${CLR_RESET} Abrir ~/.nanorc para editar colores a mano con Nano\n"
    printf "  ${CLR_GRAY}[0]${CLR_RESET} Volver\n"
    echo
    printf "${CLR_BOLD}Elige una opción [1-2]: ${CLR_RESET}"
    local opt
    read -r opt || opt=""

    case "$opt" in
        1)
            local cur_theme="yello"
            [ -f "$NOXMOD_HOME/active-theme" ] && cur_theme="$(cat "$NOXMOD_HOME/active-theme" 2>/dev/null)"
            apply_nano_config "$cur_theme"
            sleep 1.2
            ;;
        2)
            if command -v nano >/dev/null 2>&1 && [ -f "$HOME/.nanorc" ]; then
                nano "$HOME/.nanorc"
            else
                c_warn "Nano no está instalado o ~/.nanorc no existe todavía."
                sleep 1.5
            fi
            ;;
        0|"") return 0 ;;
        *) c_warn "Opción inválida."; sleep 1 ;;
    esac
}

menu_preview_themes() {
    clear
    print_main_banner
    draw_box_header "MUESTRA DE TEMAS DISPONIBLES"
    echo
    for t in yello hack red space root; do
        printf "${CLR_BOLD}=== TEMA: %s ===${CLR_RESET}\n" "$t"
        if [ -f "$ROOT_DIR/themes/$t/theme.sh" ]; then
            (
                source "$ROOT_DIR/themes/$t/theme.sh"
                theme_render_banner
                theme_render_prompt "nox" "termux" "192.168.1.5" "~/TerminuX" "main"
                printf "%s (ejemplo de comando)\n\n" "$PS1"
            )
        fi
    done
    printf "${CLR_CYAN}Presiona ENTER para volver al menú principal...${CLR_RESET}"
    read -r
}

main_menu() {
    while true; do
        clear
        print_main_banner
        render_status_card

        printf "  ${CLR_CYAN}[1]${CLR_RESET} ${CLR_BOLD}Instalar / Reaplicar TerminuX${CLR_RESET} (Instala todo el mod completo)\n"
        printf "  ${CLR_CYAN}[2]${CLR_RESET} ${CLR_BOLD}Cambiar Tema${CLR_RESET} (Yello, HACK, RED, Space, ROOT)\n"
        printf "  ${CLR_CYAN}[3]${CLR_RESET} ${CLR_BOLD}Configurar Identidad${CLR_RESET} (Usuario y Hostname)\n"
        printf "  ${CLR_CYAN}[4]${CLR_RESET} ${CLR_BOLD}Configurar IP${CLR_RESET} (Real WiFi / IP Falsa 0-255 / Ocultar)\n"
        printf "  ${CLR_CYAN}[5]${CLR_RESET} ${CLR_BOLD}Configurar Nano${CLR_RESET} (Sincronizar o editar colores)\n"
        printf "  ${CLR_CYAN}[6]${CLR_RESET} ${CLR_BOLD}Ver Vista Previa de Temas${CLR_RESET}\n"
        printf "  ${CLR_YELLOW}[7]${CLR_RESET} ${CLR_BOLD}Restaurar Estado de Fábrica / Desinstalar${CLR_RESET}\n"
        printf "  ${CLR_GRAY}[0]${CLR_RESET} Salir\n"
        echo
        printf "${CLR_BOLD}Selecciona una opción [0-7]: ${CLR_RESET}"
        local choice
        read -r choice || choice=""

        case "$choice" in
            1)
                local cur_theme="yello"
                [ -f "$NOXMOD_HOME/active-theme" ] && cur_theme="$(cat "$NOXMOD_HOME/active-theme" 2>/dev/null)"
                full_install "$cur_theme"
                printf "\nPresiona ENTER para continuar..."
                read -r
                ;;
            2) menu_change_theme ;;
            3) menu_configure_identity ;;
            4) menu_configure_ip ;;
            5) menu_configure_nano ;;
            6) menu_preview_themes ;;
            7)
                clear
                print_main_banner
                draw_box_header "RESTAURAR A ESTADO ORIGINAL"
                echo
                printf "${CLR_YELLOW}¿Estás seguro de que deseas desinstalar TerminuX y restaurar el estado original? [s/N]: ${CLR_RESET}"
                local conf
                read -r conf || conf=""
                case "$conf" in
                    s|S|y|Y)
                        restore_defaults
                        printf "\nPresiona ENTER para salir..."
                        read -r
                        exit 0
                        ;;
                    *) c_info "Operación cancelada."; sleep 1 ;;
                esac
                ;;
            0|q|Q)
                clear
                printf "${CLR_GREEN}¡Hasta pronto! Recuerda que puedes ejecutar '${CLR_WHITE}terminux${CLR_GREEN}' en cualquier momento.${CLR_RESET}\n\n"
                break
                ;;
            *)
                c_warn "Opción inválida."
                sleep 1
                ;;
        esac
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_menu
fi
