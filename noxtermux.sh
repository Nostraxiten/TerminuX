#!/data/data/com.termux/files/usr/bin/bash
#
# TerminuX — Interactive Installer & Suite Manager
#
# Usage:
#   bash noxtermux.sh             (opens interactive menu)
#   bash noxtermux.sh --install   (direct install with default theme)
#   bash noxtermux.sh --theme T   (direct install with theme T)
#
# To uninstall or restore factory defaults: bash default.sh

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Direct installation flags
if [ "${1:-}" = "--install" ] || [ "${1:-}" = "-i" ]; then
    source "$SCRIPT_DIR/core/installer.sh"
    target_theme="${2:-yello}"
    full_install "$target_theme"
    exit 0
elif [ "${1:-}" = "--theme" ] || [ "${1:-}" = "-t" ]; then
    source "$SCRIPT_DIR/core/installer.sh"
    target_theme="${2:-yello}"
    switch_theme "$target_theme"
    exit 0
fi

# Launch interactive menu if no arguments passed
if [ -f "$SCRIPT_DIR/core/menu.sh" ]; then
    exec bash "$SCRIPT_DIR/core/menu.sh" "$@"
else
    source "$SCRIPT_DIR/core/installer.sh"
    full_install "yello"
fi

