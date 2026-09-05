#!/data/data/com.termux/files/usr/bin/bash
# ~/.noxmod/prompt.sh
# TerminuX — Motor dinámico de prompt modular y soporte multi-tema
# Cargado desde ~/.bashrc. Administrado por TerminuX.

# Solo aplicar en shells interactivas
case "$-" in
    *i*) ;;
    *) return 2>/dev/null || exit 0 ;;
esac

NOXMOD_HOME="$HOME/.noxmod"

# Cargar funciones de IP
if [ -f "$NOXMOD_HOME/ip.sh" ]; then
    source "$NOXMOD_HOME/ip.sh"
fi

# Detectar tema activo
TERMINUX_THEME="yello"
if [ -f "$NOXMOD_HOME/active-theme" ]; then
    IFS= read -r TERMINUX_THEME < "$NOXMOD_HOME/active-theme"
fi
[ -n "$TERMINUX_THEME" ] || TERMINUX_THEME="yello"

# Cargar definición del tema activo
THEME_FILE="$NOXMOD_HOME/themes/$TERMINUX_THEME/theme.sh"
if [ -f "$THEME_FILE" ]; then
    source "$THEME_FILE"
else
    # Fallback si falta el archivo de tema
    THEME_ALLOW_CUSTOM="yes"
    theme_render_prompt() {
        local u="$1" h="$2" ip="$3" p="$4" g="$5"
        local ip_s=""
        [ -n "$ip" ] && ip_s="─[\[\e[1;33m\]${ip}\[\e[1;36m\]]"
        local g_s=""
        [ -n "$g" ] && g_s=" (\[\e[0;35m\]${g}\[\e[1;36m\])"
        PS1="\[\e[1;36m\]┌─[\[\e[1;32m\]${u}@${h}\[\e[1;36m\]]${ip_s}─[\[\e[1;34m\]${p}${g_s}\[\e[1;36m\]]\[\e[0m\]\n\[\e[1;36m\]└──\[\e[1;37m\]>\[\e[0m\] "
    }
    theme_render_banner() {
        printf '\e[1;36m[★] TerminuX — Shell Inicializada\e[0m\n\n'
    }
fi

# Cargar datos de usuario y host (si el tema lo permite)
terminux_get_user() {
    local u="${USER:-user}"
    if [ "${THEME_ALLOW_CUSTOM:-yes}" = "yes" ] && [ -f "$NOXMOD_HOME/user-name" ]; then
        IFS= read -r u < "$NOXMOD_HOME/user-name"
    fi
    [ -n "$u" ] || u="${USER:-user}"
    printf '%s' "$u"
}

terminux_get_host() {
    local h="termux"
    if [ "${THEME_ALLOW_CUSTOM:-yes}" = "yes" ] && [ -f "$NOXMOD_HOME/host-name" ]; then
        IFS= read -r h < "$NOXMOD_HOME/host-name"
    fi
    [ -n "$h" ] || h="termux"
    printf '%s' "$h"
}

terminux_get_git_branch() {
    git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
}

terminux_update_prompt() {
    local u h ip git_b p
    u="$(terminux_get_user)"
    h="$(terminux_get_host)"
    
    if [ "${THEME_ALLOW_CUSTOM:-yes}" = "yes" ]; then
        if type get_active_ip >/dev/null 2>&1; then
            ip="$(get_active_ip "$NOXMOD_HOME")"
        else
            ip=""
        fi
    else
        ip=""
    fi

    git_b="$(terminux_get_git_branch)"
    p="\w"

    theme_render_prompt "$u" "$h" "$ip" "$p" "$git_b"
}

PROMPT_COMMAND=terminux_update_prompt

# Banner al iniciar sesión (una sola vez por terminal)
if [ -z "${NOXMOD_BANNER_SHOWN:-}" ]; then
    export NOXMOD_BANNER_SHOWN=1
    clear
    if type theme_render_banner >/dev/null 2>&1; then
        theme_render_banner
    fi
fi
