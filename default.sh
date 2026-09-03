#!/data/data/com.termux/files/usr/bin/bash
#
# NoxMod para Termux — RESET A DEFAULT
# Quita colores, prompt, nanorc y teclas extra instalados por noxtermux.sh
# y restaura tu configuración anterior (o el estado de fábrica si no había).
# No depende de ningún otro archivo del proyecto: funciona solo.
#
# Uso:
#   bash default.sh
#
# Autor: hecho para Nox (@nostraxiten)

set -u

NOXMOD_HOME="$HOME/.noxmod"
BACKUP_ROOT="$HOME/.noxmod-backups"

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

reload_settings() {
    if command -v termux-reload-settings >/dev/null 2>&1; then
        termux-reload-settings
        c_ok "Colors reloaded."
    else
        c_warn "'termux-reload-settings' was not found; close and reopen Termux to see the change."
    fi
}

main() {
    check_termux

    local last_backup=""
    if [ -d "$BACKUP_ROOT" ] && [ -n "$(ls -A "$BACKUP_ROOT" 2>/dev/null)" ]; then
        last_backup="$(ls -1 "$BACKUP_ROOT" | sort | tail -n1)"
        c_info "Restoring backup: $last_backup"
    else
        c_warn "No NoxMod backups found; Termux will be restored to its default state (no theme, no prompt)."
    fi

    # Quitar el bloque que noxtermux.sh añadió a .bashrc
    if [ -f "$HOME/.bashrc" ]; then
        sed -i '/# >>> NOXMOD_BLOCK_START/,/# <<< NOXMOD_BLOCK_END/d' "$HOME/.bashrc"
        c_ok "NoxMod block removed from ~/.bashrc"
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
        c_ok "Previous configuration restored from $last_backup."
    else
        rm -f "$HOME/.termux/colors.properties" "$HOME/.termux/termux.properties" "$HOME/.nanorc"
        c_ok "Theme files, extra keys, and nanorc removed."
    fi

    reload_settings
    echo
    c_ok "Termux is back to its state before NoxMod."
    c_info "Run:  source ~/.bashrc   (or restart Termux) to apply the change."
}

main
