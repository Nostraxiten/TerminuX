<div align="center">

# TerminuX

**A Nightwire-inspired terminal customization for Termux on Android.**  
Enhanced `nano`, extra shell keys, and a clean Kali-style prompt with private IP and git context.

<hr>

![Platform](https://img.shields.io/badge/PLATFORM-TERMUX%20%7C%20ANDROID-00d9e8?style=flat-square)
![Shell](https://img.shields.io/badge/SHELL-BASH-7aa2f7?style=flat-square)
[![License](https://img.shields.io/badge/LICENSE-MIT-9ece6a?style=flat-square)](LICENSE)
![Status](https://img.shields.io/badge/STATUS-ACTIVE-f7768e?style=flat-square)

</div>

<div align="center">
<img width="436" height="166" alt="Captura de pantalla 2026-09-03 074223" src="https://github.com/user-attachments/assets/fb0d61a2-1bd9-46d8-9ebd-026084a8c3ee" />
</div>

## What It Installs

- **Color theme** (`~/.termux/colors.properties`): dark "Nightwire"-style palette
  (background `#1a1b26`, cyan/green/yellow accents), easy on the eyes.
- **Extra keys** (`~/.termux/termux.properties`): rows with `KEYBOARD`, navigation keys,
  and `> < | && ; ~` \` so you can show the touchscreen keyboard again while writing
  commands or code.
- **Enhanced nano** (`~/.nanorc`): line numbers, automatic indentation, interface colors,
  and syntax highlighting for dozens of languages through the
  [scopatz/nanorc](https://github.com/scopatz/nanorc) repository.
- **Prompt + automatic clear** (`~/.noxmod/prompt.sh`, loaded from `~/.bashrc`):

<div align="center">
<img width="407" height="67" alt="Captura de pantalla 2026-09-03 074231" src="https://github.com/user-attachments/assets/78b9b0d6-6232-4355-90e4-512560e1a20f" />
</div>

  The screen is cleared automatically when opening Termux. The IP is taken from
  `wlan0` (Wi-Fi); if no Wi-Fi is connected, it looks for another interface while
  excluding mobile data interfaces (`ccmni*`, `rmnet*`, `pdp*`) to avoid displaying
  the carrier's IP by mistake.

  During installation, you can choose the username shown in the prompt. The default
  is `nox`; it accepts 1 to 10 letters, numbers, `.`, `_`, or `-`.
  You can also choose the text shown after `@` (default: `termux`, 1 to 10 characters)
  and decide whether to show the private IP (default: yes).

## Installation

### Quick installation

Copy and paste this entire command into Termux:

```bash
cd "$HOME" && pkg update -y && pkg install -y git && git clone https://github.com/Nostraxiten/TerminuX.git && cd TerminuX && bash noxtermux.sh && source ~/.bashrc
```

### From an extracted project

With the project extracted, run one command (`chmod` is not required):

<img width="412" height="205" alt="image" src="https://github.com/user-attachments/assets/a25fc698-0c45-43b7-be1f-68f7643297d9" />

`noxtermux.sh` automatically backs up your existing `colors.properties`,
`termux.properties`, `.nanorc`, and `.bashrc` to `~/.noxmod-backups/<date>/`
before making any changes.

## Restore the Previous State

Again, run one command from anywhere inside Termux. It does not depend on the rest
of the project and works on its own:

```bash
bash default.sh
source ~/.bashrc
```

Restores the latest backup saved by `noxtermux.sh` and removes the block added to
`~/.bashrc`. If no backup exists, it restores Termux to its default state (no theme,
no prompt, and no extra keys).

<img width="1080" height="360" alt="image" src="https://github.com/user-attachments/assets/e5e037d2-0837-4e3e-ab29-f9ebe18aa946" />

## Project Structure

```
TerminuX/
├── noxtermux.sh           # installer (bash noxtermux.sh)
├── default.sh              # reset to default state (bash default.sh)
├── colors.properties      # terminal color palette
├── termux.properties      # extra keys row
├── nano-options.nanorc    # nano visual options
├── prompt.sh              # prompt (username, private IP, git) + banner + clear
└── README.md
```

## Notes

- An internet connection is required the first time to clone the nano syntax
  repository with `git`. If there is no network connection, nano keeps the visual
  options but has no language highlighting until you run `bash noxtermux.sh` again.
- Both scripts refuse to run if they do not detect Termux's `$PREFIX`, to avoid
  modifying another system's configuration by mistake.

## License

This project is licensed under the [MIT License](LICENSE).
