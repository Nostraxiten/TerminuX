<div align="center">

# NoxMod for Termux

**A Nightwire-inspired terminal customization for Termux on Android.**  
Enhanced `nano`, extra shell keys, and a clean Kali-style prompt with private IP and git context.

<hr>

![Platform](https://img.shields.io/badge/PLATFORM-TERMUX%20%7C%20ANDROID-00d9e8?style=flat-square)
![Shell](https://img.shields.io/badge/SHELL-BASH-7aa2f7?style=flat-square)
[![License](https://img.shields.io/badge/LICENSE-MIT-9ece6a?style=flat-square)](LICENSE)
![Status](https://img.shields.io/badge/STATUS-ACTIVE-f7768e?style=flat-square)

</div>

NoxMod changes the color theme, improves `nano` with syntax highlighting and line numbers,
and replaces the prompt with a Kali-style prompt showing your username, private IP (Wi-Fi),
and git branch when applicable, ending in `>`. When opening a new session, it clears the
screen automatically once, rather than after every command.

## What It Installs

- **Color theme** (`~/.termux/colors.properties`): dark "Nightwire"-style palette
  (background `#1a1b26`, cyan/green/yellow accents), easy on the eyes.
- **Extra keys** (`~/.termux/termux.properties`): a row with `> < | && ; ~` \` so you
  do not have to rely on the regular touchscreen keyboard when writing commands or code.
- **Enhanced nano** (`~/.nanorc`): line numbers, automatic indentation, interface colors,
  and syntax highlighting for dozens of languages through the
  [scopatz/nanorc](https://github.com/scopatz/nanorc) repository.
- **Prompt + automatic clear** (`~/.noxmod/prompt.sh`, loaded from `~/.bashrc`):

  ```
  ┌─[user@termux]─[192.168.1.34]─[~/proyect/]
  └──> 
  ```

  The screen is cleared automatically when opening Termux. The IP is taken from
  `wlan0` (Wi-Fi); if no Wi-Fi is connected, it looks for another interface while
  excluding mobile data interfaces (`ccmni*`, `rmnet*`, `pdp*`) to avoid displaying
  the carrier's IP by mistake.

## Installation

With the project extracted, run one command (`chmod` is not required):

```bash
cd noxmod-termux
bash noxtermux.sh
source ~/.bashrc
```

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

## Project Structure

```
noxmod-termux/
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
