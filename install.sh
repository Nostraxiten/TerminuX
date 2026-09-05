#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Installation Entrypoint
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/noxtermux.sh" "$@"

