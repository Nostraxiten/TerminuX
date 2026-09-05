#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — IP Resolution and Validation Module

validate_ipv4() {
    local ip="$1"
    [ -z "$ip" ] && return 1

    # Split into 4 octets by dot
    local IFS='.'
    read -ra octets <<< "$ip"
    [ "${#octets[@]}" -ne 4 ] && return 1

    for oct in "${octets[@]}"; do
        # Must contain only digits
        [[ "$oct" =~ ^[0-9]+$ ]] || return 1

        # Do not allow leading zeros for numbers > 0 (e.g., 01, 002)
        if [[ "${#oct}" -gt 1 && "$oct" =~ ^0 ]]; then
            return 1
        fi

        # Range 0 to 255
        if (( oct < 0 || oct > 255 )); then
            return 1
        fi
    done

    return 0
}

get_real_ip() {
    local ip=""

    if command -v ip >/dev/null 2>&1; then
        # Search for wlan0 interface first
        ip=$(ip -4 addr show 2>/dev/null | awk '
            /^[0-9]+: / { cur=$2; sub(/:$/,"",cur) }
            cur=="wlan0" && /inet /{ split($2,a,"/"); print a[1]; exit }
        ')
        # If wlan0 is not found, search non-loopback and non-cellular interface
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
    local conf_dir="${1:-$HOME/.terminux}"
    [ ! -d "$conf_dir" ] && [ -d "$HOME/.noxmod" ] && conf_dir="$HOME/.noxmod"
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

