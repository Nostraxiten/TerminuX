#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Core Installation and Theme Engine

set -u

CORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$CORE_DIR/.." && pwd)"

TERMINUX_HOME="$HOME/.terminux"
NANO_SYNTAX_DIR="$HOME/.nano-syntax"
BACKUP_ROOT="$HOME/.terminux-backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$BACKUP_ROOT/$STAMP"

source "$CORE_DIR/ui.sh"
source "$CORE_DIR/ip.sh"

check_termux() {
    if [ -z "${PREFIX:-}" ] || [[ "$PREFIX" != *com.termux* ]]; then
        c_err "This environment does not appear to be Termux (\$PREFIX is not set)."
        c_err "Aborting to avoid modifying another system's configuration."
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

init_backups() {
    mkdir -p "$BACKUP_ROOT"
    backup_file "$HOME/.termux/colors.properties"
    backup_file "$HOME/.termux/termux.properties"
    backup_file "$HOME/.nanorc"
    backup_file "$HOME/.bashrc"
}

copy_themes_and_core() {
    c_info "Configuring TerminuX modules..."
    mkdir -p "$TERMINUX_HOME/themes"
    mkdir -p "$TERMINUX_HOME/bin"
    mkdir -p "$TERMINUX_HOME/core"

    # Copy all themes and core scripts
    cp -r "$ROOT_DIR/themes/"* "$TERMINUX_HOME/themes/"
    cp "$ROOT_DIR/core/ip.sh" "$TERMINUX_HOME/ip.sh"
    cp "$ROOT_DIR/core/prompt_engine.sh" "$TERMINUX_HOME/prompt.sh"
    cp -r "$ROOT_DIR/core/"* "$TERMINUX_HOME/core/" 2>/dev/null || true
    chmod +x "$TERMINUX_HOME/prompt.sh"
}

apply_colors_theme() {
    local theme="${1:-yello}"
    local theme_colors="$TERMINUX_HOME/themes/$theme/colors.properties"

    if [ ! -f "$theme_colors" ]; then
        theme_colors="$ROOT_DIR/themes/$theme/colors.properties"
    fi

    if [ -f "$theme_colors" ]; then
        mkdir -p "$HOME/.termux"
        cp "$theme_colors" "$HOME/.termux/colors.properties"
        c_ok "Color theme '$theme' applied to ~/.termux/colors.properties"
    else
        c_warn "Theme colors not found for '$theme'."
    fi
}

apply_termux_keys() {
    local keys_file="$ROOT_DIR/config/termux.properties"
    mkdir -p "$HOME/.termux"
    if [ -f "$keys_file" ]; then
        cp "$keys_file" "$HOME/.termux/termux.properties"
        c_ok "Extra keys configured in ~/.termux/termux.properties"
    fi
}

apply_nano_config() {
    local theme="${1:-yello}"
    c_info "Setting up nano editor ($theme colors)..."

    # Verify packages
    if ! command -v nano >/dev/null 2>&1; then
        pkg install -y nano >/dev/null 2>&1 || c_warn "Could not install nano automatically."
    fi

    if [ ! -d "$NANO_SYNTAX_DIR" ]; then
        if command -v git >/dev/null 2>&1; then
            c_info "Downloading nano syntax highlighting..."
            git clone --depth=1 https://github.com/scopatz/nanorc.git "$NANO_SYNTAX_DIR" >/dev/null 2>&1 || {
                c_warn "Could not clone syntax repository. Using base settings."
            }
        fi
    fi

    local nano_theme="$TERMINUX_HOME/themes/$theme/nano.nanorc"
    [ -f "$nano_theme" ] || nano_theme="$ROOT_DIR/themes/$theme/nano.nanorc"

    local base_nano="$ROOT_DIR/config/nano-base.nanorc"

    {
        if [ -f "$base_nano" ]; then
            cat "$base_nano"
            echo
        fi
        if [ -f "$nano_theme" ]; then
            cat "$nano_theme"
            echo
        fi
        if [ -d "$NANO_SYNTAX_DIR" ]; then
            find "$NANO_SYNTAX_DIR" -maxdepth 1 -iname "*.nanorc" -exec echo "include {}" \;
        fi
    } > "$HOME/.nanorc"

    c_ok "Generated ~/.nanorc with '$theme' color scheme."
}

apply_bashrc_hook() {
    touch "$HOME/.bashrc"
    # Clean any legacy blocks first
    sed -i '/# >>> NOXMOD_BLOCK_START/,/# <<< NOXMOD_BLOCK_END/d' "$HOME/.bashrc"
    sed -i '/# >>> TERMINUX_BLOCK_START/,/# <<< TERMINUX_BLOCK_END/d' "$HOME/.bashrc"
    sed -i '/alias terminux=/d' "$HOME/.bashrc"

    {
        echo ""
        echo "# >>> TERMINUX_BLOCK_START (managed by terminux, do not edit manually)"
        echo "[ -f \"$TERMINUX_HOME/prompt.sh\" ] && source \"$TERMINUX_HOME/prompt.sh\""
        echo "alias terminux=\"bash $TERMINUX_HOME/core/menu.sh\""
        echo "# <<< TERMINUX_BLOCK_END"
    } >> "$HOME/.bashrc"
    c_ok "Hook and alias added to ~/.bashrc"
}

install_terminux_cli() {
    local cli_src="$ROOT_DIR/bin/terminux"
    if [ -f "$cli_src" ]; then
        cp "$cli_src" "$TERMINUX_HOME/bin/terminux"
        chmod +x "$TERMINUX_HOME/bin/terminux"

        if [ -n "${PREFIX:-}" ] && [ -d "$PREFIX/bin" ]; then
            cp "$cli_src" "$PREFIX/bin/terminux" 2>/dev/null && chmod +x "$PREFIX/bin/terminux" 2>/dev/null || true
            c_ok "CLI command 'terminux' installed to system path."
        fi
    fi
}

reload_settings() {
    if command -v termux-reload-settings >/dev/null 2>&1; then
        termux-reload-settings
        c_ok "Terminal configuration reloaded."
    else
        c_warn "Run 'termux-reload-settings' or restart Termux to apply visual changes."
    fi
}

switch_theme() {
    local new_theme="${1:-yello}"
    new_theme="$(echo "$new_theme" | tr '[:upper:]' '[:lower:]')"

    if [ ! -d "$ROOT_DIR/themes/$new_theme" ] && [ ! -d "$TERMINUX_HOME/themes/$new_theme" ]; then
        c_err "Theme '$new_theme' does not exist. Available: yello, hack, red, space, root."
        return 1
    fi

    mkdir -p "$TERMINUX_HOME"
    printf '%s\n' "$new_theme" > "$TERMINUX_HOME/active-theme"

    apply_colors_theme "$new_theme"
    apply_nano_config "$new_theme"
    reload_settings

    c_ok "Active theme switched to: $new_theme"
}

full_install() {
    local theme="${1:-yello}"
    check_termux
    init_backups
    copy_themes_and_core
    
    # Store active theme
    printf '%s\n' "$theme" > "$TERMINUX_HOME/active-theme"

    apply_colors_theme "$theme"
    apply_termux_keys
    apply_nano_config "$theme"
    apply_bashrc_hook
    install_terminux_cli
    reload_settings

    echo
    c_ok "TerminuX installed successfully with theme: $theme"
    c_info "Backup created at: $BACKUP_DIR"
    c_info "Manage settings anytime by running: terminux"
    c_info "Apply changes now: source ~/.bashrc (or restart Termux)."
}

