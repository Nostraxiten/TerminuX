#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Restoration Module to Clean Factory State

set -u

TERMINUX_HOME="$HOME/.terminux"
BACKUP_ROOT="$HOME/.terminux-backups"
LEGACY_HOME="$HOME/.noxmod"
LEGACY_BACKUP="$HOME/.noxmod-backups"

check_termux() {
    if [ -z "${PREFIX:-}" ] || [[ "$PREFIX" != *com.termux* ]]; then
        printf '\e[1;31m[ERROR]\e[0m This environment does not appear to be Termux (\$PREFIX is not set).\n'
        exit 1
    fi
}

reload_settings() {
    if command -v termux-reload-settings >/dev/null 2>&1; then
        termux-reload-settings
        printf '\e[1;32m[OK]\e[0m Colors reloaded.\n'
    else
        printf '\e[1;33m[!]\e[0m termux-reload-settings not found; restart Termux to apply changes.\n'
    fi
}

restore_defaults() {
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
        printf '\e[1;36m[*]\e[0m Restoring backup: %s\n' "$last_backup"
    else
        printf '\e[1;33m[!]\e[0m No previous backups found; Termux will be restored to clean default state.\n'
    fi

    # Remove bashrc hook and aliases
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/# >>> NOXMOD_BLOCK_START/,/# <<< NOXMOD_BLOCK_END/d' "$HOME/.bashrc"
        sed -i '/# >>> TERMINUX_BLOCK_START/,/# <<< TERMINUX_BLOCK_END/d' "$HOME/.bashrc"
        sed -i '/alias terminux=/d' "$HOME/.bashrc"
        printf '\e[1;32m[OK]\e[0m TerminuX configurations removed from ~/.bashrc\n'
    fi

    # Remove CLI binary
    if [ -n "${PREFIX:-}" ] && [ -f "$PREFIX/bin/terminux" ]; then
        rm -f "$PREFIX/bin/terminux"
        printf '\e[1;32m[OK]\e[0m Command $PREFIX/bin/terminux removed.\n'
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
        printf '\e[1;32m[OK]\e[0m Previous configuration restored from %s.\n' "$last_backup"
    else
        rm -f "$HOME/.termux/colors.properties" "$HOME/.termux/termux.properties" "$HOME/.nanorc"
        printf '\e[1;32m[OK]\e[0m Theme files, extra keys, and nanorc removed.\n'
    fi

    reload_settings
    echo
    printf '\e[1;32m[OK]\e[0m Termux has been restored successfully!\n'
    printf '\e[1;36m[*]\e[0m Run:  source ~/.bashrc  (or restart Termux).\n'
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    restore_defaults
fi

