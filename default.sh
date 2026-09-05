#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Factory Reset & Uninstaller
# Restores previous configuration or clean Termux default state.
#
# Usage:
#   bash default.sh

set -u

TERMINUX_HOME="$HOME/.terminux"
BACKUP_ROOT="$HOME/.terminux-backups"
LEGACY_HOME="$HOME/.noxmod"
LEGACY_BACKUP="$HOME/.noxmod-backups"

c_info()  { printf '\e[1;36m[*]\e[0m %s\n' "$1"; }
c_ok()    { printf '\e[1;32m[OK]\e[0m %s\n' "$1"; }
c_warn()  { printf '\e[1;33m[!]\e[0m %s\n' "$1"; }
c_err()   { printf '\e[1;31m[ERROR]\e[0m %s\n' "$1"; }

check_termux() {
    if [ -z "${PREFIX:-}" ] || [[ "$PREFIX" != *com.termux* ]]; then
        c_err "This environment does not appear to be Termux (\$PREFIX is not set)."
        c_err "Aborting to avoid modifying another system's configuration."
        exit 1
    fi
}

reload_settings() {
    if command -v termux-reload-settings >/dev/null 2>&1; then
        termux-reload-settings
        c_ok "Terminal configuration reloaded."
    else
        c_warn "Run 'termux-reload-settings' or restart Termux to apply changes."
    fi
}

main() {
    check_termux

    local last_backup=""
    local active_backup_root=""

    if [ -d "$BACKUP_ROOT" ] && [ -n "$(ls -A "$BACKUP_ROOT" 2>/dev/null)" ]; then
        active_backup_root="$BACKUP_ROOT"
        last_backup="$(ls -1 "$BACKUP_ROOT" | sort | tail -n1)"
    elif [ -d "$LEGACY_BACKUP" ] && [ -n "$(ls -A "$LEGACY_BACKUP" 2>/dev/null)" ]; then
        active_backup_root="$LEGACY_BACKUP"
        last_backup="$(ls -1 "$LEGACY_BACKUP" | sort | tail -n1)"
    fi

    if [ -n "$last_backup" ]; then
        c_info "Restoring backup: $last_backup"
    else
        c_warn "No backups found; Termux will be restored to clean default state."
    fi

    # Remove bashrc hook and aliases
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/# >>> NOXMOD_BLOCK_START/,/# <<< NOXMOD_BLOCK_END/d' "$HOME/.bashrc"
        sed -i '/# >>> TERMINUX_BLOCK_START/,/# <<< TERMINUX_BLOCK_END/d' "$HOME/.bashrc"
        sed -i '/alias terminux=/d' "$HOME/.bashrc"
        c_ok "TerminuX configurations removed from ~/.bashrc"
    fi

    # Remove CLI binary
    if [ -n "${PREFIX:-}" ] && [ -f "$PREFIX/bin/terminux" ]; then
        rm -f "$PREFIX/bin/terminux"
        c_ok "Removed \$PREFIX/bin/terminux"
    fi

    rm -rf "$TERMINUX_HOME" "$LEGACY_HOME"

    if [ -n "$last_backup" ] && [ -n "$active_backup_root" ]; then
        local bdir="$active_backup_root/$last_backup"
        if [ -f "$bdir/colors.properties.bak" ]; then
            cp "$bdir/colors.properties.bak" "$HOME/.termux/colors.properties"
        else
            rm -f "$HOME/.termux/colors.properties"
        fi
        if [ -f "$bdir/termux.properties.bak" ]; then
            cp "$bdir/termux.properties.bak" "$HOME/.termux/termux.properties"
        else
            rm -f "$HOME/.termux/termux.properties"
        fi
        if [ -f "$bdir/.nanorc.bak" ]; then
            cp "$bdir/.nanorc.bak" "$HOME/.nanorc"
        else
            rm -f "$HOME/.nanorc"
        fi
        if [ -f "$bdir/.bashrc.bak" ]; then
            cp "$bdir/.bashrc.bak" "$HOME/.bashrc"
        fi
        c_ok "Previous configuration restored from $last_backup."
    else
        rm -f "$HOME/.termux/colors.properties" "$HOME/.termux/termux.properties" "$HOME/.nanorc"
        c_ok "Theme files, extra keys, and nanorc removed."
    fi

    reload_settings
    echo
    c_ok "Termux restored to original state."
    c_info "Reloading clean terminal environment..."
    exec bash
}

main


