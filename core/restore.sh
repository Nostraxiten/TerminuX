#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Módulo de Restauración a Estado de Fábrica

set -u

NOXMOD_HOME="$HOME/.noxmod"
BACKUP_ROOT="$HOME/.noxmod-backups"

check_termux() {
    if [ -z "${PREFIX:-}" ] || [[ "$PREFIX" != *com.termux* ]]; then
        printf '\e[1;31m[ERROR]\e[0m This does not appear to be Termux (com.termux $PREFIX was not detected).\n'
        exit 1
    fi
}

reload_settings() {
    if command -v termux-reload-settings >/dev/null 2>&1; then
        termux-reload-settings
        printf '\e[1;32m[OK]\e[0m Colors reloaded.\n'
    else
        printf '\e[1;33m[!]\e[0m Termux-reload-settings not found; restart Termux to apply changes.\n'
    fi
}

restore_defaults() {
    check_termux

    local last_backup=""
    if [ -d "$BACKUP_ROOT" ] && [ -n "$(ls -A "$BACKUP_ROOT" 2>/dev/null)" ]; then
        last_backup="$(ls -1 "$BACKUP_ROOT" | sort | tail -n1)"
        printf '\e[1;36m[*]\e[0m Restoring backup: %s\n' "$last_backup"
    else
        printf '\e[1;33m[!]\e[0m No NoxMod backups found; Termux will be restored to clean default state.\n'
    fi

    # Eliminar bloque de bashrc
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/# >>> NOXMOD_BLOCK_START/,/# <<< NOXMOD_BLOCK_END/d' "$HOME/.bashrc"
        sed -i '/alias terminux=/d' "$HOME/.bashrc"
        printf '\e[1;32m[OK]\e[0m TerminuX removed from ~/.bashrc\n'
    fi

    # Eliminar binario de terminux
    if [ -n "${PREFIX:-}" ] && [ -f "$PREFIX/bin/terminux" ]; then
        rm -f "$PREFIX/bin/terminux"
        printf '\e[1;32m[OK]\e[0m Command $PREFIX/bin/terminux removed.\n'
    fi

    rm -rf "$NOXMOD_HOME"

    if [ -n "$last_backup" ]; then
        local bdir="$BACKUP_ROOT/$last_backup"
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
