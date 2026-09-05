<div align="center">

# TerminuX

**The ultimate terminal customization suite for Termux on Android.**  
5 themes, enhanced `nano`, coding keys, Kali-style prompts, fake/real IP manager, and an interactive TUI.

<hr>

![Platform](https://img.shields.io/badge/PLATFORM-TERMUX%20%7C%20ANDROID-00d9e8?style=flat-square)
![Shell](https://img.shields.io/badge/SHELL-BASH-7aa2f7?style=flat-square)
[![License](https://img.shields.io/badge/LICENSE-MIT-9ece6a?style=flat-square)](LICENSE)
![Status](https://img.shields.io/badge/STATUS-ACTIVE-f7768e?style=flat-square)
![Themes](https://img.shields.io/badge/THEMES-5%20AVAILABLE-22c55e?style=flat-square)

</div>

<div align="center">
<img width="436" height="166" alt="TerminuX Header" src="https://github.com/user-attachments/assets/fb0d61a2-1bd9-46d8-9ebd-026084a8c3ee" />
</div>

## ✨ Características Principales

- 🎨 **5 Temas Visuales Completos**:
  - **`Yello`** *(Por defecto)*: Paleta Nightwire suave (fondo oscuro `#1a1b26`, acentos cian, verde y amarillo).
  - **`HACK`**: Estilo Matrix Hacker (verde neón fosforescente sobre negro profundo con símbolos cyber).
  - **`RED`**: Estilo cibernético rojo y negro con logo minimalista terminal `>_` con parpadeo activo (`\e[5m`).
  - **`Space`**: Azul cósmico profundo con decoración espacial de estrellas ASCII sutiles (`✦`, `*`, `·`, `✧`, `˚`) en la línea de escritura.
  - **`ROOT`**: Réplica 100% auténtica y literal del entorno root de Kali Linux (`root@kali:~#`), estricta y sin alteraciones de IP para máxima fidelidad.
- 🌐 **Gestor de IP Avanzado (Real o Falsa)**:
  - Detección automática de WiFi (`wlan0`) excluyendo interfaces de datos móviles (`rmnet*`, `ccmni*`) para evitar fugas de IP del operador.
  - Soporte para **IP falsa personalizada** con validación estricta de 4 octetos en rango `0.0.0.0` a `255.255.255.255`.
  - Opción para ocultar la IP si prefieres un prompt compacto.
- ⚡ **Menú TUI Interactivo y CLI `terminux`**:
  - Interfaz visual con selector de temas al vuelo sin reinstalar.
  - Comando global `terminux` para cambiar temas y opciones desde cualquier directorio.
- 📝 **Nano Mejorado**: Números de línea, indentación inteligente y colores sincronizados con el tema activo, además de soporte para decenas de lenguajes.
- ⌨️ **Teclas Extra para Programación**: Fila superior con navegación (`ESC`, `TAB`, flechas) y símbolos frecuentes (`> < | && ; ~ \``).

---

## 🚀 Instalación Rápida

Copia y pega este comando en Termux:

```bash
cd "$HOME" && pkg update -y && pkg install -y git && git clone https://github.com/Nostraxiten/TerminuX.git && cd TerminuX && bash noxtermux.sh
```

Al finalizar, ejecuta `source ~/.bashrc` (o reinicia Termux) para disfrutar de tu nuevo entorno.

---

## 🛠️ Uso del Comando `terminux`

Una vez instalado, tienes a tu disposición el comando global `terminux`:

```bash
terminux                      # Abre el menú visual interactivo
terminux theme hack           # Cambia al tema HACK al instante
terminux theme red            # Cambia al tema RED con logo parpadeante
terminux theme space          # Cambia al tema Space con estrellas
terminux theme root           # Cambia a la réplica oficial de Kali Root
terminux theme yello          # Vuelve al tema Yello por defecto
terminux ip fake 10.10.10.1   # Asigna una IP falsa (validada 0-255)
terminux ip real              # Vuelve a detectar tu WiFi real
terminux ip off               # Oculta la IP del prompt
terminux user miusuario       # Cambia tu usuario del prompt
terminux restore              # Desinstala y vuelve al estado original
```

---

## 📂 Estructura del Proyecto

```
TerminuX/
├── noxtermux.sh           # Instalador y lanzador del menú interactivo
├── install.sh             # Entrypoint alternativo de instalación
├── default.sh             # Script de restauración a estado de fábrica
├── bin/
│   └── terminux           # Comando CLI global instalado en el sistema
├── themes/                # Los 5 temas visuales
│   ├── yello/             # Tema Nightwire suave
│   ├── hack/              # Tema Matrix Hacker (verde y negro)
│   ├── red/               # Tema RED (logo '>_' con parpadeo)
│   ├── space/             # Tema Space (estrellas cósmicas)
│   └── root/              # Tema ROOT (Kali Linux oficial)
├── core/                  # Módulos del motor
│   ├── menu.sh            # Interfaz visual TUI
│   ├── installer.sh       # Lógica de instalación y backups
│   ├── prompt_engine.sh   # Motor dinámico de prompt para bashrc
│   ├── ip.sh              # Resolución de WiFi y validador de IP (0-255)
│   ├── restore.sh         # Restaurador de configuraciones
│   └── ui.sh              # Paletas ANSI y formato de cajas
├── config/                # Configuraciones base
│   ├── termux.properties  # Teclas extra para Termux
│   └── nano-base.nanorc   # Configuración base de Nano
└── README.md
```

---

## 🔄 Restaurar el Estado Original

Si deseas eliminar la personalización y restaurar tu configuración anterior (o el estado de fábrica de Termux), ejecuta:

```bash
bash default.sh
source ~/.bashrc
```

`default.sh` es completamente independiente y restaura tu último respaldo guardado en `~/.noxmod-backups/`.

---

## 📄 Licencia

Este proyecto está bajo la Licencia [MIT](LICENSE).
