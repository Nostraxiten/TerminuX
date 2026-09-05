#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Interactive Terminal User Interface (TUI)

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TERMINUX_HOME="$HOME/.terminux"
[ ! -d "$TERMINUX_HOME" ] && [ -d "$HOME/.noxmod" ] && TERMINUX_HOME="$HOME/.noxmod"

source "$SCRIPT_DIR/ui.sh"
source "$SCRIPT_DIR/ip.sh"
source "$SCRIPT_DIR/installer.sh"
source "$SCRIPT_DIR/restore.sh"

get_current_status() {
    local cur_theme="yello"
    [ -f "$TERMINUX_HOME/active-theme" ] && cur_theme="$(cat "$TERMINUX_HOME/active-theme" 2>/dev/null)"
    [ -n "$cur_theme" ] || cur_theme="yello"

    local cur_user="user"
    [ -f "$TERMINUX_HOME/user-name" ] && cur_user="$(cat "$TERMINUX_HOME/user-name" 2>/dev/null)"
    [ -n "$cur_user" ] || cur_user="${USER:-user}"

    local cur_host="termux"
    [ -f "$TERMINUX_HOME/host-name" ] && cur_host="$(cat "$TERMINUX_HOME/host-name" 2>/dev/null)"
    [ -n "$cur_host" ] || cur_host="termux"

    local ip_mode="real"
    [ -f "$TERMINUX_HOME/ip-mode" ] && ip_mode="$(cat "$TERMINUX_HOME/ip-mode" 2>/dev/null)"
    [ -n "$ip_mode" ] || ip_mode="real"

    local cur_ip=""
    case "$ip_mode" in
        custom|fake)
            local f_ip="10.0.0.1"
            [ -f "$TERMINUX_HOME/custom-ip" ] && f_ip="$(cat "$TERMINUX_HOME/custom-ip" 2>/dev/null)"
            cur_ip="Custom ($f_ip)"
            ;;
        off|none)
            cur_ip="Hidden"
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
    printf "  │ ${CLR_BOLD}${CLR_WHITE}CURRENT TERMINUX STATUS${CLR_RESET}${CLR_CYAN}                                │\n"
    printf "  ├────────────────────────────────────────────────────────┤\n"
    printf "  │  ${CLR_YELLOW}[*] Active Theme:${CLR_RESET}    %-37s${CLR_CYAN}│\n" "$s_theme"
    if [ "$s_theme" = "root" ]; then
        printf "  │  ${CLR_RED}[*] Root Mode:${CLR_RESET}       %-37s${CLR_CYAN}│\n" "root@kali (Kali Linux replica)"
    else
        printf "  │  ${CLR_GREEN}[*] Identity:${CLR_RESET}        %-37s${CLR_CYAN}│\n" "${s_user}@${s_host}"
        printf "  │  ${CLR_PURPLE}[*] IP Mode:${CLR_RESET}         %-37s${CLR_CYAN}│\n" "$s_ip"
    fi
    printf "  ╰────────────────────────────────────────────────────────╯${CLR_RESET}\n\n"
}

menu_change_theme() {
    clear
    print_main_banner
    draw_box_header "THEME SELECTION"
    echo
    printf "  ${CLR_CYAN}[1]${CLR_RESET} ${CLR_BOLD}Yello${CLR_RESET}  — Nightwire soft palette (cyan/green/yellow) [Default]\n"
    printf "  ${CLR_GREEN}[2]${CLR_RESET} ${CLR_BOLD}HACK${CLR_RESET}   — Matrix Hacker style (phosphor green & deep black)\n"
    printf "  ${CLR_RED}[3]${CLR_RESET} ${CLR_BOLD}RED${CLR_RESET}    — Cyber red & black with pulsing '>_' terminal logo\n"
    printf "  ${CLR_BLUE}[4]${CLR_RESET} ${CLR_BOLD}Space${CLR_RESET}  — Cosmic blue with subtle ASCII star accents\n"
    printf "  ${CLR_PURPLE}[5]${CLR_RESET} ${CLR_BOLD}ROOT${CLR_RESET}   — Official Kali Linux root replica (locked)\n"
    printf "  ${CLR_GRAY}[0]${CLR_RESET} Cancel and return to main menu\n"
    echo
    printf "${CLR_BOLD}Select an option [1-5]: ${CLR_RESET}"
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
        *) c_warn "Invalid option."; sleep 1; return 1 ;;
    esac

    switch_theme "$target"
    sleep 1.2
}

menu_configure_ip() {
    clear
    print_main_banner
    draw_box_header "IP CONFIGURATION"
    echo

    local cur_status
    cur_status="$(get_current_status)"
    local s_theme
    IFS='|' read -r s_theme _ <<< "$cur_status"

    if [ "$s_theme" = "root" ]; then
        c_warn "The ROOT theme strictly replicates Kali Linux and does not display an IP."
        printf "\nPress ENTER to return..."
        read -r
        return 0
    fi

    printf "  ${CLR_CYAN}[1]${CLR_RESET} Real IP (Automatic WiFi wlan0 excluding cellular data)\n"
    printf "  ${CLR_CYAN}[2]${CLR_RESET} Custom / Fake IP (Enter any custom IP address)\n"
    printf "  ${CLR_CYAN}[3]${CLR_RESET} Hide IP segment from prompt\n"
    printf "  ${CLR_GRAY}[0]${CLR_RESET} Back\n"
    echo
    printf "${CLR_BOLD}Select an option [1-3]: ${CLR_RESET}"
    local opt
    read -r opt || opt=""

    mkdir -p "$TERMINUX_HOME"
    case "$opt" in
        1)
            printf 'real\n' > "$TERMINUX_HOME/ip-mode"
            c_ok "Configured to Real WiFi IP."
            sleep 1
            ;;
        2)
            while true; do
                echo
                printf "${CLR_BOLD}Enter custom IP address (0.0.0.0 - 255.255.255.255): ${CLR_RESET}"
                local fake_ip
                read -r fake_ip || fake_ip=""
                [ -z "$fake_ip" ] && break

                if validate_ipv4 "$fake_ip"; then
                    printf 'custom\n' > "$TERMINUX_HOME/ip-mode"
                    printf '%s\n' "$fake_ip" > "$TERMINUX_HOME/custom-ip"
                    c_ok "Custom IP saved: $fake_ip"
                    sleep 1.2
                    break
                else
                    c_err "'$fake_ip' is invalid. Must consist of 4 octets between 0 and 255 (e.g. 10.0.0.1)."
                fi
            done
            ;;
        3)
            printf 'off\n' > "$TERMINUX_HOME/ip-mode"
            c_ok "IP segment disabled in prompt."
            sleep 1
            ;;
        0|"") return 0 ;;
        *) c_warn "Invalid option."; sleep 1 ;;
    esac
}

menu_configure_identity() {
    clear
    print_main_banner
    draw_box_header "IDENTITY CONFIGURATION"
    echo

    local cur_status
    cur_status="$(get_current_status)"
    local s_theme
    IFS='|' read -r s_theme _ <<< "$cur_status"

    if [ "$s_theme" = "root" ]; then
        c_warn "The ROOT theme is a locked replica and strictly uses 'root@kali'."
        printf "\nPress ENTER to return..."
        read -r
        return 0
    fi

    mkdir -p "$TERMINUX_HOME"
    local u_input h_input

    printf "Current username: [${CLR_GREEN}%s${CLR_RESET}]\n" "$(terminux_get_user)"
    printf "New username (1-10 alphanumeric chars) [leave empty to keep]: "
    read -r u_input || u_input=""
    if [ -n "$u_input" ]; then
        if [[ "$u_input" =~ ^[[:alnum:]_.-]{1,10}$ ]]; then
            printf '%s\n' "$u_input" > "$TERMINUX_HOME/user-name"
            c_ok "Username updated to: $u_input"
        else
            c_warn "Invalid format. No changes made."
        fi
    fi

    echo
    printf "Current hostname: [${CLR_CYAN}%s${CLR_RESET}]\n" "$(terminux_get_host)"
    printf "New hostname (1-10 alphanumeric chars) [leave empty to keep]: "
    read -r h_input || h_input=""
    if [ -n "$h_input" ]; then
        if [ "${#h_input}" -ge 1 ] && [ "${#h_input}" -le 10 ]; then
            printf '%s\n' "$h_input" > "$TERMINUX_HOME/host-name"
            c_ok "Hostname updated to: $h_input"
        else
            c_warn "Invalid length (1-10 characters). No changes made."
        fi
    fi

    sleep 1.2
}

menu_configure_nano() {
    clear
    print_main_banner
    draw_box_header "NANO EDITOR"
    echo
    printf "  ${CLR_CYAN}[1]${CLR_RESET} Synchronize Nano colors with current theme\n"
    printf "  ${CLR_CYAN}[2]${CLR_RESET} Open ~/.nanorc with Nano to edit manually\n"
    printf "  ${CLR_GRAY}[0]${CLR_RESET} Back\n"
    echo
    printf "${CLR_BOLD}Select an option [1-2]: ${CLR_RESET}"
    local opt
    read -r opt || opt=""

    case "$opt" in
        1)
            local cur_theme="yello"
            [ -f "$TERMINUX_HOME/active-theme" ] && cur_theme="$(cat "$TERMINUX_HOME/active-theme" 2>/dev/null)"
            apply_nano_config "$cur_theme"
            sleep 1.2
            ;;
        2)
            if command -v nano >/dev/null 2>&1 && [ -f "$HOME/.nanorc" ]; then
                nano "$HOME/.nanorc"
            else
                c_warn "Nano is not installed or ~/.nanorc does not exist yet."
                sleep 1.5
            fi
            ;;
        0|"") return 0 ;;
        *) c_warn "Invalid option."; sleep 1 ;;
    esac
}

menu_preview_themes() {
    clear
    print_main_banner
    draw_box_header "THEMES PREVIEW"
    echo
    for t in yello hack red space root; do
        printf "${CLR_BOLD}=== THEME: %s ===${CLR_RESET}\n" "$t"
        if [ -f "$ROOT_DIR/themes/$t/theme.sh" ]; then
            (
                source "$ROOT_DIR/themes/$t/theme.sh"
                theme_render_banner
                theme_render_prompt "user" "termux" "192.168.1.5" "~/TerminuX" "main"
                printf "%s (sample command)\n\n" "$PS1"
            )
        fi
    done
    printf "${CLR_CYAN}Press ENTER to return to main menu...${CLR_RESET}"
    read -r
}

main_menu() {
    while true; do
        clear
        print_main_banner
        render_status_card

        printf "  ${CLR_CYAN}[1]${CLR_RESET} ${CLR_BOLD}Install / Reapply TerminuX${CLR_RESET} (Full suite installation)\n"
        printf "  ${CLR_CYAN}[2]${CLR_RESET} ${CLR_BOLD}Switch Theme${CLR_RESET} (Yello, HACK, RED, Space, ROOT)\n"
        printf "  ${CLR_CYAN}[3]${CLR_RESET} ${CLR_BOLD}Configure Identity${CLR_RESET} (Username & Hostname)\n"
        printf "  ${CLR_CYAN}[4]${CLR_RESET} ${CLR_BOLD}Configure IP${CLR_RESET} (Real WiFi / Custom Fake IP / Hide)\n"
        printf "  ${CLR_CYAN}[5]${CLR_RESET} ${CLR_BOLD}Configure Nano${CLR_RESET} (Sync or edit colors)\n"
        printf "  ${CLR_CYAN}[6]${CLR_RESET} ${CLR_BOLD}Preview Themes${CLR_RESET}\n"
        printf "  ${CLR_YELLOW}[7]${CLR_RESET} ${CLR_BOLD}Restore Factory Defaults / Uninstall${CLR_RESET}\n"
        printf "  ${CLR_GRAY}[0]${CLR_RESET} Exit\n"
        echo
        printf "${CLR_BOLD}Select an option [0-7]: ${CLR_RESET}"
        local choice
        read -r choice || choice=""

        case "$choice" in
            1)
                local cur_theme="yello"
                [ -f "$TERMINUX_HOME/active-theme" ] && cur_theme="$(cat "$TERMINUX_HOME/active-theme" 2>/dev/null)"
                full_install "$cur_theme"
                printf "\nPress ENTER to continue..."
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
                draw_box_header "RESTORE FACTORY DEFAULTS"
                echo
                printf "${CLR_YELLOW}Are you sure you want to uninstall TerminuX and restore original settings? [y/N]: ${CLR_RESET}"
                local conf
                read -r conf || conf=""
                case "$conf" in
                    y|Y|s|S)
                        restore_defaults
                        printf "\nPress ENTER to exit..."
                        read -r
                        exit 0
                        ;;
                    *) c_info "Operation cancelled."; sleep 1 ;;
                esac
                ;;
            0|q|Q)
                clear
                printf "${CLR_GREEN}Goodbye! You can run '${CLR_WHITE}terminux${CLR_GREEN}' anytime.${CLR_RESET}\n\n"
                break
                ;;
            *)
                c_warn "Invalid option."
                sleep 1
                ;;
        esac
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_menu
fi

