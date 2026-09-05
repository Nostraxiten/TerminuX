#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Módulo de Resolución y Validación de IP

validate_ipv4() {
    local ip="$1"
    [ -z "$ip" ] && return 1

    # Separar en 4 partes por el punto
    local IFS='.'
    read -ra octets <<< "$ip"
    [ "${#octets[@]}" -ne 4 ] && return 1

    for oct in "${octets[@]}"; do
        # Debe contener únicamente números
        [[ "$oct" =~ ^[0-9]+$ ]] || return 1

        # No permitir ceros a la izquierda en números mayores a 0 (ej: 01, 002)
        if [[ "${#oct}" -gt 1 && "$oct" =~ ^0 ]]; then
            return 1
        fi

        # Rango 0 a 255
        if (( oct < 0 || oct > 255 )); then
            return 1
        fi
    done

    return 0
}

get_real_ip() {
    local ip=""

    if command -v ip >/dev/null 2>&1; then
        # Buscar interfaz wlan0 primero
        ip=$(ip -4 addr show 2>/dev/null | awk '
            /^[0-9]+: / { cur=$2; sub(/:$/,"",cur) }
            cur=="wlan0" && /inet /{ split($2,a,"/"); print a[1]; exit }
        ')
        # Si no hay wlan0, buscar interfaz no-loopback y no-datos móviles
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

get_active_ip() {
    local conf_dir="${1:-$HOME/.noxmod}"
    local mode="real"
    local custom_ip="192.168.1.100"

    [ -f "$conf_dir/ip-mode" ] && mode="$(cat "$conf_dir/ip-mode" 2>/dev/null)"
    [ -f "$conf_dir/custom-ip" ] && custom_ip="$(cat "$conf_dir/custom-ip" 2>/dev/null)"

    case "$mode" in
        off|none|no)
            printf ''
            ;;
        custom|fake)
            if validate_ipv4 "$custom_ip"; then
                printf '%s' "$custom_ip"
            else
                get_real_ip
            fi
            ;;
        real|yes|*)
            get_real_ip
            ;;
    esac
}
