#!/data/data/com.termux/files/usr/bin/bash
#
# TerminuX — INSTALADOR Y GESTOR INTERACTIVO
#
# Mod visual para Termux: 5 temas (Yello, HACK, RED, Space, ROOT),
# prompt estilo Kali/Nightwire con IP WiFi o falsa personalizada (0.0.0.0-255.255.255.255),
# nano con resaltado de sintaxis, teclas extra y menú TUI interactivo.
#
# Uso:
#   bash noxtermux.sh             (abre el menú interactivo con todas las opciones)
#   bash noxtermux.sh --install   (instalación directa con tema por defecto)
#   bash noxtermux.sh --theme T   (instala directamente con el tema T)
#
# Para desinstalar o volver a default: bash default.sh
#
# Autor: hecho para Nox (@nostraxiten)

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Si se pasa --install o un flag, ejecutar instalación directa
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

# Si se ejecuta sin parámetros, abrir el menú visual interactivo
if [ -f "$SCRIPT_DIR/core/menu.sh" ]; then
    exec bash "$SCRIPT_DIR/core/menu.sh" "$@"
else
    source "$SCRIPT_DIR/core/installer.sh"
    full_install "yello"
fi
