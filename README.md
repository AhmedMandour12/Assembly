# Assembly
# OS Simulation

A command-line operating system simulation written in 16-bit x86 assembly for DOS. It starts a text-mode shell, reads commands from the keyboard, and dispatches them to handler routines. The code is split into separately assembled modules that are linked into a single executable.

The project is a learning exercise in low-level programming: multi-module assembly, DOS and BIOS interrupts, and structuring a program around a simple kernel loop.

## Features

- Interactive shell with a prompt and a fixed-size input buffer
- Command dispatcher that compares the typed input against known commands
- Screen handling through BIOS interrupt `10h`, text I/O through DOS interrupt `21h`
- Shared data and procedures exported between modules with `PUBLIC` / `EXTRN`
- Shared constants kept in a single include file

## Project Structure

```
.
├── Main.asm       Entry point, shared variables and messages
├── Kernel.asm     Startup, main loop, prompt, input reading, screen clearing
├── Command.asm    Command list output, string comparison, command dispatch
└── DEFINE.INC     Shared constants
```

| Module | Responsibility |
| --- | --- |
| `Main.asm` | Defines the data segment (buffers, messages, command list), sets up `DS`, and transfers control to `KernelStart`. Exits to DOS when the kernel returns. |
| `Kernel.asm` | Clears the screen, prints the welcome message, and runs the main loop: show prompt, read a command, execute it. |
| `Command.asm` | Prints the command list, compares strings, and implements `ExecuteCommand`. |
| `DEFINE.INC` | Constants shared by every module. |

### Constants

| Name | Value | Purpose |
| --- | --- | --- |
| `COMMAND_SIZE` | 30 | Size of the command buffer, including the terminator |
| `USERNAME_SIZE` | 20 | Size of the username buffer |
| `PASSWORD_SIZE` | 20 | Size of the password buffer |
| `MAX_ATTEMPTS` | 3 | Allowed login attempts |

## How It Works

1. `Main.asm` initializes the data segment and calls `KernelStart`.
2. `KernelStart` clears the screen and prints the welcome message.
3. The kernel loop repeats:
   - `ShowPrompt` prints `OSS>`
   - `ReadCommand` reads characters until Enter or until the buffer is full, and terminates the string with `$`
   - `ExecuteCommand` compares the buffer against each known command and runs the matching handler
4. `ExecuteCommand` returns a status in `AL`. A value of `1` tells the kernel to leave the loop and return to DOS; `0` keeps the shell running.

All strings are `$`-terminated so they can be printed directly with `INT 21h`, function `09h`.

## Commands

| Command | Description | Status |
| --- | --- | --- |
| `HELP` | List available commands | Implemented |
| `CLEAR` | Clear the screen | Planned |
| `EXIT` | Leave the shell | Planned |
| `CALC` | Calculator | Planned |
| `TIME` | Show the system time | Planned |
| `LOG` | Show the activity log | Planned |
| `STATUS` | Show system status | Planned |

Unrecognized input is ignored and the shell returns to the prompt.

## Build and Run

### Requirements

- Turbo Assembler (`TASM`) and Turbo Linker (`TLINK`)
- DOSBox, or any DOS-compatible environment

### Build

```
tasm main.asm
tasm kernel.asm
tasm command.asm
tlink main.obj kernel.obj command.obj
```

`main.obj` must come first in the link command because it contains the program entry point.

### Run

```
main
```

### Example

```
==============================
 OS SIMULATION v1.0
==============================
Welcome to OS Simulation!
Type HELP to see available commands

OSS> HELP

==============================
HELP
CALC
TIME
LOG
STATUS
CLEAR
EXIT

OSS>
```

## Roadmap

- [x] Multi-module project layout and shared constants
- [x] Shell loop with prompt and input buffer
- [x] `HELP` command
- [ ] `CLEAR` and `EXIT` commands
- [ ] Case-insensitive command matching
- [ ] Login module (`AUTH.asm`) using `MAX_ATTEMPTS`
- [ ] `CALC`, `TIME`, `LOG`, `STATUS`
