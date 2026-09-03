# NoxMod para Termux

Mod visual únicamente para **Termux** (Android). Cambia el tema de color, mejora `nano`
con resaltado de sintaxis y números de línea, y sustituye el prompt por uno estilo
Kali con tu usuario, tu IP privada (Wi-Fi) y la rama de git (si aplica), rematado
en `>`. Al abrir una sesión nueva, limpia la pantalla automáticamente (solo una
vez al entrar, no en cada comando).

## Qué instala

- **Tema de color** (`~/.termux/colors.properties`): paleta oscura tipo "Nightwire"
  (fondo `#1a1b26`, acentos cian/verde/amarillo), suave para la vista.
- **Teclas extra** (`~/.termux/termux.properties`): fila con `> < | && ; ~` \` para
  no depender del teclado táctil normal al escribir comandos o código.
- **nano mejorado** (`~/.nanorc`): números de línea, indentado automático, colores
  de interfaz, y resaltado de sintaxis para decenas de lenguajes vía el repo
  [scopatz/nanorc](https://github.com/scopatz/nanorc).
- **Prompt + clear automático** (`~/.noxmod/prompt.sh`, cargado desde `~/.bashrc`):

  ```
  ┌─[nox@termux]─[192.168.1.34]─[~/proyectos/kaisen (main)]
  └──> 
  ```

  La pantalla se limpia sola al abrir Termux. La IP es la de `wlan0` (Wi-Fi);
  si no hay Wi-Fi conectada, busca otra interfaz descartando las de datos
  móviles (`ccmni*`, `rmnet*`, `pdp*`) para no mostrar la IP de la operadora
  por error.

## Instalación

Con el proyecto descomprimido, un solo comando (no hace falta `chmod`):

```bash
cd noxmod-termux
bash noxtermux.sh
source ~/.bashrc
```

`noxtermux.sh` hace *backup* automático de tu `colors.properties`, `termux.properties`,
`.nanorc` y `.bashrc` previos en `~/.noxmod-backups/<fecha>/` antes de tocar nada.

## Volver todo a como estaba

También con un solo comando, desde cualquier sitio dentro de Termux (no depende
del resto del proyecto, funciona por sí solo):

```bash
bash default.sh
source ~/.bashrc
```

Restaura la última copia de seguridad guardada por `noxtermux.sh` y quita el
bloque que se añadió a `~/.bashrc`. Si nunca hubo backup, deja Termux en su
estado de fábrica (sin tema, sin prompt, sin teclas extra).

## Estructura del proyecto

```
noxmod-termux/
├── noxtermux.sh           # instalador (bash noxtermux.sh)
├── default.sh              # reset a estado por defecto (bash default.sh)
├── colors.properties      # paleta de color del terminal
├── termux.properties      # fila de teclas extra
├── nano-options.nanorc    # opciones visuales de nano
├── prompt.sh              # prompt (usuario, IP privada, git) + banner + clear
└── README.md
```

## Notas

- Necesita conexión a internet la primera vez, para clonar el repo de sintaxis de
  nano con `git`. Si no hay red, nano se queda con las opciones visuales pero sin
  resaltado de lenguajes hasta que vuelvas a correr `bash noxtermux.sh`.
- Ambos scripts se niegan a ejecutarse si no detectan `$PREFIX` de Termux, para no
  tocar la configuración de otro sistema por error.
