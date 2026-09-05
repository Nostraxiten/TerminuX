#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Módulo de Interfaz y Formato de Terminal

CLR_RESET='\e[0m'
CLR_BOLD='\e[1m'
CLR_DIM='\e[2m'
CLR_CYAN='\e[1;36m'
CLR_GREEN='\e[1;32m'
CLR_YELLOW='\e[1;33m'
CLR_RED='\e[1;31m'
CLR_BLUE='\e[1;34m'
CLR_PURPLE='\e[1;35m'
CLR_WHITE='\e[1;37m'
CLR_GRAY='\e[0;90m'

c_info()  { printf "${CLR_CYAN}[*]${CLR_RESET} %s\n" "$1"; }
c_ok()    { printf "${CLR_GREEN}[OK]${CLR_RESET} %s\n" "$1"; }
c_warn()  { printf "${CLR_YELLOW}[!]${CLR_RESET} %s\n" "$1"; }
c_err()   { printf "${CLR_RED}[ERROR]${CLR_RESET} %s\n" "$1"; }
c_title() { printf "${CLR_BOLD}${CLR_CYAN}=== %s ===${CLR_RESET}\n" "$1"; }

print_main_banner() {
    clear
    printf "${CLR_CYAN}"
    cat << 'EOF'
  _______                 _             _   _ 
 |__   __|               (_)           | \ | |
    | | ___ _ __ _ __ ___ _ _ __  _   _|  \| |_  __
    | |/ _ \ '__| '_ ` _ \ | '_ \| | | | . ` \ \/ /
    | |  __/ |  | | | | | | | | | | |_| | |\  |>  < 
    |_|\___|_|  |_| |_| |_|_|_| |_|\__,_|_| \_/_/\_\
EOF
    printf "${CLR_YELLOW}       ⚡ Ultra Terminal Customizer for Termux ⚡\n"
    printf "${CLR_GRAY}           Desarrollado para Nox (@nostraxiten)\n\n${CLR_RESET}"
}

draw_box_header() {
    local title="$1"
    local len=${#title}
    local border=""
    for ((i=0; i<len+4; i++)); do border="${border}─"; done
    printf "${CLR_CYAN}╭${border}╮\n"
    printf "│  ${CLR_BOLD}${CLR_WHITE}%s${CLR_RESET}${CLR_CYAN}  │\n" "$title"
    printf "╰${border}╯${CLR_RESET}\n"
}
