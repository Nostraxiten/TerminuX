#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Theme definition: Yello

THEME_NAME="Yello"
THEME_DESC="Nightwire soft palette (cyan, green, and yellow)"
THEME_ALLOW_CUSTOM="yes"

theme_render_banner() {
    printf '\e[1;36m'
    cat << 'EOF'
  _____                   _             _   _ 
 |_   _|__ _ __ _ __ ___ (_)_ __  _   _| \ | |
   | |/ _ \ '__| '_ ` _ \| | '_ \| | | |  \| |
   | |  __/ |  | | | | | | | | | | |_| | |\  |
   |_|\___|_|  |_| |_| |_|_|_| |_|\__,_|_| \_|
EOF
    printf '\e[0;33m      [+] TerminuX \e[1;30m|\e[0;36m Nightwire Soft Theme\e[0m\n\n'
}

theme_render_prompt() {
    local u="$1" h="$2" ip="$3" p="$4" g="$5"
    local r='\[\e[0m\]'
    local box='\[\e[1;36m\]'
    local usr='\[\e[1;32m\]'
    local i_col='\[\e[1;33m\]'
    local p_col='\[\e[1;34m\]'
    local g_col='\[\e[0;35m\]'
    local arr='\[\e[1;37m\]'

    local ip_seg=""
    [ -n "$ip" ] && ip_seg="─[${i_col}${ip}${box}]"

    local git_seg=""
    [ -n "$g" ] && git_seg=" ${g_col}(${g})${box}"

    PS1="${box}┌─[${usr}${u}@${h}${box}]${ip_seg}─[${p_col}${p}${git_seg}${box}]${r}\n${box}└──${arr}>${r} "
}

