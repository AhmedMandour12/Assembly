OS Simulation v1.1

A small command-line operating system simulation written in x86 (8086) Assembly for Turbo Assembler (TASM). It runs in DOS text mode and has a login screen, a command prompt, and a few built-in programs (a number-guessing game and a calculator).

======================================================
                 OS SIMULATION v1.1
======================================================
             Welcome to OS Simulation!

OSS> _
Features
Login system with password masking (*) and a limit of 3 attempts before the system locks.
Command prompt (OSS>) with case-insensitive commands.
Built-in programs:
Guess The Number game
Calculator (supports negative numbers and large results)
Modular design: each part of the system lives in its own source file and shares code through PUBLIC / EXTRN.
Commands
Command	Description
HELP	Show the help menu
GUESS	Play the number guessing game
CALC	Open the calculator
TIME	Display the current system time (HH:MM:SS)
STATUS	Show login status and attempts used
CLEAR	Clear the screen
LOGOUT	Log out and return to the login screen
EXIT	Exit the system

Default login: Admin / 1234 (case-sensitive)

Calculator

Type CALC at the prompt. The calculator performs one operation, waits for a key press, then returns to the system screen.

================================
       Welcome To Calculator
================================

1. Addition
2. Subtraction
3. Multiplication
4. Division
5. Exit

Choose an operation: 1

Enter first number: 3

Enter second number: 4

Result: 7

Press any key to go back...
Input range: -9999 to 9999.
Results are calculated as 32-bit signed values, so multiplication never overflows (e.g. 9999 * 9999 = 99980001).
Division returns the integer quotient only.
Division by zero and invalid input are handled with an error message.
Guess The Number

Type GUESS. The system picks a number between 1 and 100 and you have 4 tries. After each guess you get a Too LOW / Too HIGH hint. Type Q to quit.

Project Structure
File	Purpose
Main.asm	Entry point. Holds the shared data (username, password, buffers, messages).
Kernel.asm	Main loop (login, prompt, read, execute) and basic I/O: print, clear screen.
Auth.asm	Login, logout, and the shared ReadInput routine.
Command.asm	Command parser/executor, CompareString, ReloadScreen, TIME.
Guess.asm	The guessing game.
Calc.asm	The calculator.
DEFINE.INC	Shared constants (MAX_ATTEMPTS, buffer sizes).
How it flows
Main  ->  KernelStart  ->  Login
                             |
                             v
                    +-->  ShowPrompt
                    |        |
                    |     ReadCommand
                    |        |
                    |    ExecuteCommand  ->  HELP / GUESS / CALC / TIME / ...
                    |        |
                    +--------+   (loops until EXIT)
Shared routines
Routine	File	Description
PrintString	Kernel.asm	Print a $-terminated string
PrintChar	Kernel.asm	Print the character in DL
PrintNewLine	Kernel.asm	Print CR + LF
ClearScrean	Kernel.asm	Clear the screen and reset the cursor
ReadInput	Auth.asm	Read a line. BX = buffer, CX = max length, DH=1 shows stars
CompareString	Command.asm	Compare two $-terminated strings. CL=1 for case-sensitive
ReloadScreen	Command.asm	Clear the screen, then show the welcome message and command list
Build and Run

Requires Turbo Assembler (TASM) and Turbo Link (TLINK), and a DOS environment (DOSBox or GUI Turbo Assembler).

1. Assemble every source file (DEFINE.INC is included automatically):

tasm Main.asm
tasm Kernel.asm
tasm Command.asm
tasm Auth.asm
tasm Guess.asm
tasm Calc.asm

2. Link them into one executable (Main must be first):

tlink Main+Kernel+Command+Auth+Guess+Calc

3. Run:

Main

After changing a single file, you only need to re-assemble that file and run tlink again.

Adding a New Command
In Command.asm add a string in .data, for example cmdMyCmd DB 'MYCMD$'.
Add EXTRN MyProc:Near in the .code section.
In ExecuteCommand, add a block that compares commandBuffer with the new string and jumps to a label (copy any existing block).
Add the label, for example MyCmdCommand: Call MyProc then JMP Finish.
Make your procedure PUBLIC in its own file and add it to the tlink line.
Add the command name to helpMsg and commandsString.
Author

Ahmed Mandour - @AhmedMandour12
