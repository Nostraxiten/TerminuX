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

## Key Features

- **5 Complete Visual Themes**:
  - **`Yello`** *(Default)*: Soft Nightwire palette (dark background `#1a1b26`, cyan, green, and yellow accents).
  - **`HACK`**: Matrix Hacker theme (phosphor green over deep black).
  - **`RED`**: Cyber red and black with pulsing `>_` terminal logo (`\e[5m`).
  - **`Space`**: Deep cosmic blue with subtle ASCII star accents (`✦`, `*`, `·`, `✧`, `˚`).
  - **`ROOT`**: Authentic Kali Linux root replica (`root@kali:~#`), strict and locked for fidelity.
- **Advanced IP Manager (Real or Custom/Fake)**:
  - Automatic WiFi detection (`wlan0`) excluding cellular data interfaces (`rmnet*`, `ccmni*`) to prevent operator IP leaks.
  - Support for **custom fake IP** with strict 4-octet validation within range `0.0.0.0` to `255.255.255.255`.
  - Option to hide IP segment from prompt for a compact appearance.
- **Interactive TUI Menu and CLI `terminux`**:
  - Visual interface with on-the-fly theme switcher without reinstallation.
  - Global `terminux` CLI command to manage themes and preferences from any directory.
- **Enhanced Nano Editor**: Line numbers, smart indentation, syntax highlighting for dozens of languages, and colors synced to active theme.
- **Extra Programming Keys**: Top bar with essential keys (`ESC`, `TAB`, arrows) and frequent programming symbols (`> < | && ; ~ \``).

---

## Quick Installation

Run the following command in Termux (automatically fixes desynced/broken mirrors, cleans cache, and installs dependencies):

```bash
cd "$HOME" && rm -rf "$PREFIX/var/lib/apt/lists/"* && apt clean && sed -i 's|https://[^ ]*|https://grimler.se/termux/termux-main|g' "$PREFIX/etc/apt/sources.list" && pkg update -y && pkg install -y git && git clone https://github.com/Nostraxiten/TerminuX.git && cd TerminuX && bash noxtermux.sh
```

When finished, run `source ~/.bashrc` (or restart Termux) to apply all changes.

---

## CLI Usage (`terminux`)

Once installed, use the global `terminux` command:

```bash
terminux                      # Open interactive visual TUI menu
terminux theme hack           # Switch to HACK theme
terminux theme red            # Switch to RED theme with pulsing logo
terminux theme space          # Switch to Space theme
terminux theme root           # Switch to Kali Linux Root replica
terminux theme yello          # Switch to default Yello theme
terminux ip fake 10.10.10.1   # Set custom fake IP (0-255 validated)
terminux ip real              # Detect and display real WiFi IP
terminux ip off               # Hide IP segment from prompt
terminux user myuser          # Change prompt username
terminux host myhost          # Change prompt hostname
terminux restore              # Uninstall and restore previous configuration
```

---

## Project Structure

```
TerminuX/
├── noxtermux.sh           # Main installer and TUI menu launcher
├── install.sh             # Alternative installation entrypoint
├── default.sh             # Factory reset and uninstaller script
├── bin/
│   └── terminux           # Global system CLI tool
├── themes/                # Visual themes
│   ├── yello/             # Nightwire soft theme
│   ├── hack/              # Matrix Hacker theme
│   ├── red/               # Cyber RED theme
│   ├── space/             # Cosmic Space theme
│   └── root/              # Kali Linux ROOT replica
├── core/                  # Engine modules
│   ├── menu.sh            # Interactive TUI interface
│   ├── installer.sh       # Installation logic and backups
│   ├── prompt_engine.sh   # Dynamic prompt engine for bashrc
│   ├── ip.sh              # WiFi resolution and IP validator (0-255)
│   ├── restore.sh         # Configuration restoration module
│   └── ui.sh              # ANSI palette and box formatters
├── config/                # Base configuration files
│   ├── termux.properties  # Extra keys layout for Termux
│   └── nano-base.nanorc   # Base Nano settings
└── README.md
```

---

## Factory Reset & Restoration

To remove custom configurations and restore your previous setup (or clean Termux default state):

```bash
bash default.sh
source ~/.bashrc
```

`default.sh` is fully standalone and restores from backups stored in `~/.terminux-backups/`.

---

## License

This project is licensed under the [MIT License](LICENSE).

