#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Definición del tema: RED

THEME_NAME="RED"
THEME_DESC="Estilo rojo y negro con logo cibernético '>_' parpadeante"
THEME_ALLOW_CUSTOM="yes"

theme_render_banner() {
    printf '\e[1;31m'
    cat << 'EOF'
     __  _
    / / (_)
   / /_ 
   \___/
EOF
    printf '  \e[1;31m╭──────────────────────────────────╮\e[0m\n'
    printf '  \e[1;31m│   \e[5;1;31m>\e[5;1;37m_\e[0;1;31m  TERMINUX // RED PROTOCOL   │\e[0m\n'
    printf '  \e[1;31m╰──────────────────────────────────╯\e[0m\n\n'
}

theme_render_prompt() {
    local u="$1" h="$2" ip="$3" p="$4" g="$5"
    local r='\[\e[0m\]'
    local box='\[\e[0;31m\]'
    local usr='\[\e[1;31m\]'
    local i_col='\[\e[1;37m\]'
    local p_col='\[\e[1;31m\]'
    local g_col='\[\e[1;33m\]'
    local logo='\[\e[1;31m\][\[\e[5;1;37m\]>_\[\e[0;1;31m\]]'

    local ip_seg=""
    [ -n "$ip" ] && ip_seg="──[${i_col}${ip}${box}]"

    local git_seg=""
    [ -n "$g" ] && git_seg=" ${g_col}git:(${g})${box}"

    PS1="${box}┌──[${usr}${u}@${h}${box}]${ip_seg}──[${p_col}${p}${git_seg}${box}]${r}\n${box}└──${logo}─>${r} "
}
