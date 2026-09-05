#!/data/data/com.termux/files/usr/bin/bash
# ~/.terminux/prompt.sh
# TerminuX — Dynamic Modular Prompt Engine
# Sourced from ~/.bashrc. Managed by TerminuX.

# Apply only in interactive shells
case "$-" in
    *i*) ;;
    *) return 2>/dev/null || exit 0 ;;
esac

TERMINUX_HOME="$HOME/.terminux"
[ ! -d "$TERMINUX_HOME" ] && [ -d "$HOME/.noxmod" ] && TERMINUX_HOME="$HOME/.noxmod"

# Load IP functions
if [ -f "$TERMINUX_HOME/ip.sh" ]; then
    source "$TERMINUX_HOME/ip.sh"
fi

# Function to load/reload active theme definition
terminux_load_theme() {
    local target_theme="yello"
    if [ -f "$TERMINUX_HOME/active-theme" ]; then
        target_theme="$(tr -d '\r\n ' < "$TERMINUX_HOME/active-theme" 2>/dev/null)"
    fi
    [ -n "$target_theme" ] || target_theme="yello"

    if [ "${TERMINUX_LOADED_THEME:-}" != "$target_theme" ] || ! type theme_render_prompt >/dev/null 2>&1; then
        local t_file="$TERMINUX_HOME/themes/$target_theme/theme.sh"
        if [ -f "$t_file" ]; then
            THEME_ALLOW_CUSTOM="yes"
            source "$t_file"
            TERMINUX_LOADED_THEME="$target_theme"
        else
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
                printf '\e[1;36m[+] TerminuX — Shell Initialized\e[0m\n\n'
            }
            TERMINUX_LOADED_THEME="fallback"
        fi
    fi
}

# Initial theme load
terminux_load_theme

# Load user and host data (if theme permits)
terminux_get_user() {
    local u=""
    if [ "${THEME_ALLOW_CUSTOM:-yes}" = "yes" ] && [ -f "$TERMINUX_HOME/user-name" ]; then
        u="$(tr -d '\r\n' < "$TERMINUX_HOME/user-name" 2>/dev/null)"
    fi
    [ -n "$u" ] || u="${USER:-user}"
    printf '%s' "$u"
}

terminux_get_host() {
    local h=""
    if [ "${THEME_ALLOW_CUSTOM:-yes}" = "yes" ] && [ -f "$TERMINUX_HOME/host-name" ]; then
        h="$(tr -d '\r\n' < "$TERMINUX_HOME/host-name" 2>/dev/null)"
    fi
    [ -n "$h" ] || h="termux"
    printf '%s' "$h"
}

terminux_get_git_branch() {
    git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
}

terminux_update_prompt() {
    terminux_load_theme

    local u h ip git_b p
    u="$(terminux_get_user)"
    h="$(terminux_get_host)"
    
    if [ "${THEME_ALLOW_CUSTOM:-yes}" = "yes" ]; then
        if type get_active_ip >/dev/null 2>&1; then
            ip="$(get_active_ip "$TERMINUX_HOME")"
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

# Session banner (displayed once per terminal session)
if [ -z "${TERMINUX_BANNER_SHOWN:-}" ]; then
    export TERMINUX_BANNER_SHOWN=1
    clear
    if type theme_render_banner >/dev/null 2>&1; then
        theme_render_banner
    fi
fi


