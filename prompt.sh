#!/data/data/com.termux/files/usr/bin/bash
# ~/.noxmod/prompt.sh
# NoxMod — prompt visual para Termux (estilo Kali) con IP privada y rama git.
# Cargado desde ~/.bashrc por noxtermux.sh. No editar a mano si vas a re-instalar.

# Solo aplicar en shells interactivas
case "$-" in
    *i*) ;;
    *) return 2>/dev/null || exit 0 ;;
esac

# --- Colores (secuencias envueltas en \[ \] para que bash no cuente mal el ancho del prompt) ---
NOXMOD_RESET='\[\e[0m\]'
NOXMOD_BOX='\[\e[1;36m\]'      # cian: líneas y corchetes
NOXMOD_USER='\[\e[1;32m\]'     # verde: usuario@termux
NOXMOD_IP='\[\e[1;33m\]'       # amarillo: IP privada
NOXMOD_PATH='\[\e[1;34m\]'     # azul: ruta actual
NOXMOD_GIT='\[\e[0;35m\]'      # magenta: rama git
NOXMOD_ARROW='\[\e[1;37m\]'    # blanco brillante: símbolo de entrada
NOXMOD_USER_NAME="${USER:-user}"
if [ -f "$HOME/.noxmod/user-name" ]; then
    IFS= read -r NOXMOD_USER_NAME < "$HOME/.noxmod/user-name"
fi
[ -n "$NOXMOD_USER_NAME" ] || NOXMOD_USER_NAME="${USER:-user}"
NOXMOD_HOST_NAME="termux"
if [ -f "$HOME/.noxmod/host-name" ]; then
    IFS= read -r NOXMOD_HOST_NAME < "$HOME/.noxmod/host-name"
fi
[ -n "$NOXMOD_HOST_NAME" ] || NOXMOD_HOST_NAME="termux"
NOXMOD_SHOW_IP="yes"
if [ -f "$HOME/.noxmod/show-ip" ]; then
    IFS= read -r NOXMOD_SHOW_IP < "$HOME/.noxmod/show-ip"
fi

# --- IP privada de la Wi-Fi (evita coger la de datos móviles: ccmni*, rmnet*, pdp*) ---
# IMPORTANTE: en Android, pedir la interfaz por nombre directamente (p.ej.
# "ip addr show wlan0" o "ifconfig wlan0") puede devolver vacío aunque el
# listado completo sí funcione. Por eso aquí SIEMPRE se pide el listado
# completo y se busca el bloque de wlan0 dentro del texto, nunca por nombre.
noxmod_get_ip() {
    local ip=""

    if command -v ip >/dev/null 2>&1; then
        # Bloque de wlan0 dentro del listado completo de "ip addr show"
        ip=$(ip -4 addr show 2>/dev/null | awk '
            /^[0-9]+: / { cur=$2; sub(/:$/,"",cur) }
            cur=="wlan0" && /inet /{ split($2,a,"/"); print a[1]; exit }
        ')
        # Si no hay wlan0, cualquier otra interfaz que no sea loopback ni datos móviles
        if [ -z "$ip" ]; then
            ip=$(ip -4 addr show 2>/dev/null | awk '
                /^[0-9]+: / { cur=$2; sub(/:$/,"",cur) }
                cur=="lo" { next }
                cur ~ /^(ccmni|rmnet|pdp|v4-rmnet|clat|ccinet)/ { next }
                /inet /{ split($2,a,"/"); print a[1]; exit }
            ')
        fi
    fi

    if [ -z "$ip" ] && command -v ifconfig >/dev/null 2>&1; then
        # Mismo criterio pero parseando el listado completo de "ifconfig"
        ip=$(ifconfig 2>/dev/null | awk '
            /^[A-Za-z0-9_.-]+:/ { cur=$1; sub(/:$/,"",cur) }
            cur=="wlan0" && /inet /{ print $2; exit }
        ')
        if [ -z "$ip" ]; then
            ip=$(ifconfig 2>/dev/null | awk '
                /^[A-Za-z0-9_.-]+:/ { cur=$1; sub(/:$/,"",cur) }
                cur=="lo" { next }
                cur ~ /^(ccmni|rmnet|pdp|v4-rmnet|clat|ccinet)/ { next }
                /inet /{ print $2; exit }
            ')
        fi
    fi

    [ -z "$ip" ] && ip="no-wifi"
    printf '%s' "$ip"
}

# --- Rama git actual, si estamos dentro de un repo ---
noxmod_get_git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    [ -n "$branch" ] && printf ' (%s)' "$branch"
}

# --- Construye el prompt en cada línea nueva ---
noxmod_set_prompt() {
    local ip branch ip_segment
    branch=$(noxmod_get_git_branch)
    ip_segment=""
    if [ "$NOXMOD_SHOW_IP" = "yes" ]; then
        ip=$(noxmod_get_ip)
        ip_segment="─[${NOXMOD_IP}${ip}${NOXMOD_BOX}]"
    fi
    PS1="${NOXMOD_BOX}┌─[${NOXMOD_USER}${NOXMOD_USER_NAME}@${NOXMOD_HOST_NAME}${NOXMOD_BOX}]${ip_segment}─[${NOXMOD_PATH}\w${NOXMOD_GIT}${branch}${NOXMOD_BOX}]${NOXMOD_RESET}\n${NOXMOD_BOX}└──${NOXMOD_ARROW}>${NOXMOD_RESET} "
}

PROMPT_COMMAND=noxmod_set_prompt

# --- Pantalla limpia al abrir sesión (una sola vez, sin banner) ---
if [ -z "$NOXMOD_BANNER_SHOWN" ]; then
    export NOXMOD_BANNER_SHOWN=1
    clear
fi
