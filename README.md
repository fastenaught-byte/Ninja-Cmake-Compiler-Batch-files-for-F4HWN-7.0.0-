# Windows Build Scripts

This guide covers the Windows batch files in the repository root. They build
two different things:

| Script | Builds | Runs |
|---|---|---|
| `compile-firmware.bat` | Firmware presets | Natively on Windows |
| `compile-app.bat` | Overlay applications (`.app` files) | In Docker |

Run commands from Command Prompt or PowerShell. Both scripts switch to the
repository directory automatically, so they can also be started from another
working directory.

## Firmware

### Requirements

Install these tools and make them available on `PATH`:

- CMake 3.24 or newer
- Ninja
- Python 3
- GNU Arm Embedded Toolchain for `arm-none-eabi`

The firmware script also searches the standard
`%ProgramFiles(x86)%\Arm GNU Toolchain arm-none-eabi` directory for ARM GCC.
No Docker installation or Linux shell is needed for firmware builds.

### Build commands

```bat
compile-firmware.bat
compile-firmware.bat Fusion
compile-firmware.bat Service
compile-firmware.bat Custom
compile-firmware.bat All
```

The default preset is `Fusion`. `All` builds `Fusion` and `Service`. Each
preset's artifacts are written to `build\<Preset>\`, including its `.elf`,
`.bin`, and `.hex` files.

Extra arguments are passed to CMake as cache options:

```bat
compile-firmware.bat Fusion -DDEV=ON
compile-firmware.bat Service -DENABLE_VOX=OFF
```

For example, the development build writes the normal Fusion output and also
updates `archive\f4hwn.fusion.development.bin`.

## Overlay applications

### Requirements

- Docker Desktop installed and running
- Docker CLI available in the terminal

`compile-app.bat` builds the repository's `uvk1-uvk5v3` Docker image if it is
not already available, then runs the application build scripts inside it.

### Build commands

```bat
compile-app.bat
compile-app.bat All
compile-app.bat breakout
compile-app.bat cwkeyer cwusb cwmem
```

With no app name, or with `All`, the script builds every discovered non-test
app. You can also give one or more app directory names under `App\apps\`.

The packed application files are collected in `build\Apps\`. Each app uses a
4 KiB RAM overlay; the build report shows code size and flags failed or
oversized apps.

## Troubleshooting

- **CMake, Ninja, Python, or ARM GCC not found:** install the missing tool and
  add it to `PATH`, then open a new terminal.
- **Docker is unavailable:** start Docker Desktop and wait for it to finish
  starting before running `compile-app.bat`.
- **Unknown preset or app:** check the spelling. Firmware presets are
  `Custom`, `Fusion`, `Service`, and `All`; app names match directories under
  `App\apps\`.
