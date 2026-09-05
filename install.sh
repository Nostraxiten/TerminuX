#!/data/data/com.termux/files/usr/bin/bash
# TerminuX — Entrypoint de instalación (ejecuta noxtermux.sh)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/noxtermux.sh" "$@"
