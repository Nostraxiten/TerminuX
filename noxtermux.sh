#!/data/data/com.termux/files/usr/bin/bash
#
# NoxMod para Termux — INSTALADOR
# Aplica tema de colores, nano con resaltado de sintaxis, prompt visual
# (usuario + IP privada + git) con clear automático al abrir sesión,
# y fila de teclas extra para código.
#
# Uso:
#   bash noxtermux.sh
#
# Para volver todo a como estaba: bash default.sh
#
# Autor: hecho para Nox (@nostraxiten)

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NOXMOD_HOME="$HOME/.noxmod"
NANO_SYNTAX_DIR="$HOME/.nano-syntax"
BACKUP_ROOT="$HOME/.noxmod-backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$STAMP"

c_info()  { printf '\e[1;36m[*]\e[0m %s\n' "$1"; }
c_ok()    { printf '\e[1;32m[OK]\e[0m %s\n' "$1"; }
c_warn()  { printf '\e[1;33m[!]\e[0m %s\n' "$1"; }
c_err()   { printf '\e[1;31m[ERROR]\e[0m %s\n' "$1"; }

check_termux() {
    if [ -z "${PREFIX:-}" ] || [[ "$PREFIX" != *com.termux* ]]; then
        c_err "This does not appear to be Termux (com.termux \$PREFIX was not detected)."
        c_err "The script will not continue to avoid modifying another system's configuration."
        exit 1
    fi
}

backup_file() {
    local src="$1"
    if [ -e "$src" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$src" "$BACKUP_DIR/$(basename "$src").bak" 2>/dev/null
    fi
}

install_colors() {
    c_info "Installing color theme (Nightwire)..."
    mkdir -p "$HOME/.termux"
    backup_file "$HOME/.termux/colors.properties"
    backup_file "$HOME/.termux/termux.properties"
    cp "$SCRIPT_DIR/colors.properties" "$HOME/.termux/colors.properties"
    cp "$SCRIPT_DIR/termux.properties" "$HOME/.termux/termux.properties"
    c_ok "colors.properties and termux.properties installed in ~/.termux/"
}

install_nano() {
    c_info "Preparing nano with syntax highlighting..."
    if ! command -v nano >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then
        c_info "Installing dependencies (nano, git)..."
        pkg install -y nano git >/dev/null 2>&1 || {
            c_warn "Could not install nano/git automatically. Install them with 'pkg install nano git' and run the script again."
            return 1
        }
    fi

    if [ ! -d "$NANO_SYNTAX_DIR" ]; then
        c_info "Downloading syntax definitions (scopatz/nanorc)..."
        git clone --depth=1 https://github.com/scopatz/nanorc.git "$NANO_SYNTAX_DIR" >/dev/null 2>&1 || {
            c_warn "Could not clone the syntax repository (no connection?). Nano will only use the visual options."
        }
    else
        c_info "Syntax definitions are already present; they will not be downloaded again."
    fi

    backup_file "$HOME/.nanorc"
    {
        cat "$SCRIPT_DIR/nano-options.nanorc"
        echo
        if [ -d "$NANO_SYNTAX_DIR" ]; then
            find "$NANO_SYNTAX_DIR" -maxdepth 1 -iname "*.nanorc" -exec echo "include {}" \;
        fi
    } > "$HOME/.nanorc"
    c_ok "~/.nanorc generated."
}

configure_prompt_user() {
    local username="nox"
    local requested_username

    while true; do
        printf 'Prompt username [nox]: '
        IFS= read -r requested_username || requested_username=""
        username="${requested_username:-nox}"
        if [[ "$username" =~ ^[[:alnum:]_.-]{1,10}$ ]]; then
            break
        fi
        c_warn "Use 1 to 10 characters: letters, numbers, '.', '_' or '-'."
    done

    printf '%s\n' "$username" > "$NOXMOD_HOME/user-name"
    c_ok "Prompt username set to: $username"
}

configure_prompt_host() {
    local hostname="termux"
    local requested_hostname

    while true; do
        printf 'Prompt host [termux]: '
        IFS= read -r requested_hostname || requested_hostname=""
        hostname="${requested_hostname:-termux}"
        if [ "${#hostname}" -ge 1 ] && [ "${#hostname}" -le 10 ]; then
            break
        fi
        c_warn "Use between 1 and 10 characters."
    done

    printf '%s\n' "$hostname" > "$NOXMOD_HOME/host-name"
    c_ok "Prompt host set to: $hostname"
}

configure_prompt_ip() {
    local show_ip="yes"
    local requested_show_ip

    while true; do
        printf 'Show private IP in prompt? [Y/n]: '
        IFS= read -r requested_show_ip || requested_show_ip=""
        case "${requested_show_ip:-y}" in
            y|Y|yes|YES|Yes)
                show_ip="yes"
                break
                ;;
            n|N|no|NO|No)
                show_ip="no"
                break
                ;;
            *)
                c_warn "Answer yes or no."
                ;;
        esac
    done

    printf '%s\n' "$show_ip" > "$NOXMOD_HOME/show-ip"
    c_ok "Private IP display: $show_ip"
}

install_prompt() {
    c_info "Installing visual prompt (user + private IP + git + automatic clear)..."
    mkdir -p "$NOXMOD_HOME"
    configure_prompt_user
    configure_prompt_host
    configure_prompt_ip
    cp "$SCRIPT_DIR/prompt.sh" "$NOXMOD_HOME/prompt.sh"
    chmod +x "$NOXMOD_HOME/prompt.sh"

    backup_file "$HOME/.bashrc"
    touch "$HOME/.bashrc"
    if ! grep -q "NOXMOD_BLOCK_START" "$HOME/.bashrc" 2>/dev/null; then
        {
            echo ""
            echo "# >>> NOXMOD_BLOCK_START (managed by noxtermux.sh, do not edit manually)"
            echo "[ -f \"$NOXMOD_HOME/prompt.sh\" ] && source \"$NOXMOD_HOME/prompt.sh\""
            echo "# <<< NOXMOD_BLOCK_END"
        } >> "$HOME/.bashrc"
        c_ok "Source line added to ~/.bashrc"
    else
        c_info "~/.bashrc already contained the NoxMod block; no duplicate was added."
    fi
}

reload_settings() {
    if command -v termux-reload-settings >/dev/null 2>&1; then
        termux-reload-settings
        c_ok "Colors and font reloaded."
    else
        c_warn "'termux-reload-settings' was not found; close and reopen Termux to see the colors."
    fi
}

main() {
    check_termux
    mkdir -p "$BACKUP_ROOT"
    install_colors
    install_nano
    install_prompt
    reload_settings
    echo
    c_ok "Installation complete."
    c_info "Backup of your previous configuration: $BACKUP_DIR"
    c_info "Run:  source ~/.bashrc   (or restart Termux) to see the new prompt with automatic clear."
    c_info "To revert everything:  bash default.sh"
}

main
