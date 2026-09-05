#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Definición del tema: ROOT (Réplica oficial de Kali Linux Root)

THEME_NAME="ROOT"
THEME_DESC="Réplica exacta de Kali Linux en modo root (estricto y bloqueado por defecto)"
THEME_ALLOW_CUSTOM="no"

theme_render_banner() {
    printf '\e[1;34m'
    cat << 'EOF'
  _  __     _ _   _     _                  
 | |/ /__ _| (_) | |   (_)_ __  _   ___  __
 | ' // _` | | | | |   | | '_ \| | | \ \/ /
 | . \ (_| | | | | |___| | | | | |_| |>  < 
 |_|\_\__,_|_|_| |_____|_|_| |_|\__,_/_/\_\
EOF
    printf '\e[1;31m [☠] ROOT@KALI // PRIVILEGED ACCESS (KALI LINUX REPLICA)\e[0m\n\n'
}

theme_render_prompt() {
    # El modo ROOT replica literalmente el prompt de Kali Linux root:
    # No permite modificar usuario, host ni inyectar IP personalizada.
    local p="$4" g="$5"
    local r='\[\e[0m\]'
    local blue='\[\e[1;34m\]'
    local red='\[\e[1;31m\]'
    local white='\[\e[0m\]'

    local git_seg=""
    [ -n "$g" ] && git_seg="${blue}:(${red}${g}${blue})"

    PS1="${blue}┌──(${red}root${blue}㉿${red}kali${blue})-[${white}${p}${git_seg}${blue}]${r}\n${blue}└─${red}#${r} "
}
