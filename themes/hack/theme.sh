#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Theme definition: HACK

THEME_NAME="HACK"
THEME_DESC="Matrix Hacker style (phosphor green and deep black)"
THEME_ALLOW_CUSTOM="yes"

theme_render_banner() {
    printf '\e[1;32m'
    cat << 'EOF'
  _  _   _   ___ _  __
 | || | /_\ / __| |/ /
 | __ |/ _ \ (__| ' < 
 |_||_/_/ \_\___|_|\_\
EOF
    printf '\e[0;32m [+] TerminuX // HACK \e[1;30m|\e[0;32m ACCESS GRANTED // MATRIX\e[0m\n\n'
}

theme_render_prompt() {
    local u="$1" h="$2" ip="$3" p="$4" g="$5"
    local r='\[\e[0m\]'
    local box='\[\e[0;32m\]'
    local usr='\[\e[1;32m\]'
    local i_col='\[\e[1;37m\]'
    local p_col='\[\e[0;32m\]'
    local g_col='\[\e[1;33m\]'
    local sym='\[\e[1;32m\]'

    local ip_seg=""
    [ -n "$ip" ] && ip_seg="──[${i_col}${ip}${box}]"

    local git_seg=""
    [ -n "$g" ] && git_seg=" ${g_col}git:(${g})${box}"

    PS1="${box}┌──[${usr}${u}@${h}${box}]${ip_seg}──[${p_col}${p}${git_seg}${box}]${r}\n${box}└──${sym}>${r} "
}

