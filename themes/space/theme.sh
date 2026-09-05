#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Theme definition: Space

THEME_NAME="Space"
THEME_DESC="Deep cosmic blue with subtle ASCII star accents"
THEME_ALLOW_CUSTOM="yes"

theme_render_banner() {
    printf '\e[1;34m'
    cat << 'EOF'
       .  *  ✦  .  *  .  ✧  .  *
    _____                      
   / ____|                     
  | (___  _ __   __ _  ___ ___ 
   \___ \| '_ \ / _` |/ __/ _ \
   ____) | |_) | (_| | (_|  __/
  |_____/| .__/ \__,_|\___\___|
         | |                   
         |_|   ✦  S P A C E  ✦
EOF
    printf '\e[0;36m      [+] TerminuX \e[1;30m|\e[0;35m DEEP COSMOS // GALAXY\e[0m\n\n'
}

theme_render_prompt() {
    local u="$1" h="$2" ip="$3" p="$4" g="$5"
    local r='\[\e[0m\]'
    local box='\[\e[0;34m\]'
    local star1='\[\e[1;36m\]✦\[\e[0;34m\]'
    local star2='\[\e[1;35m\]·\[\e[0;34m\]'
    local usr='\[\e[1;36m\]'
    local i_col='\[\e[1;35m\]'
    local p_col='\[\e[1;34m\]'
    local g_col='\[\e[0;36m\]'
    local writing_deco='\[\e[1;36m\]✦ \[\e[1;35m\]˚ \[\e[0;36m\]· \[\e[1;37m\]>'

    local ip_seg=""
    [ -n "$ip" ] && ip_seg="─${star2}─[${i_col}${ip}${box}]"

    local git_seg=""
    [ -n "$g" ] && git_seg=" ${g_col}✦ (${g})${box}"

    PS1="${box}┌─${star1}─[${usr}${u}@${h}${box}]${ip_seg}─${star2}─[${p_col}${p}${git_seg}${box}]─${star1}${r}\n${box}└──${writing_deco}${r} "
}

