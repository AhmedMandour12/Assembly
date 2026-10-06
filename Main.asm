; ==========================================
; Main.asm
; Program entry point + shared data
; ==========================================

.model small
.stack 100h

; Shared constants
INCLUDE DEFINE.INC

; ---------- EXPORTS ----------
PUBLIC username, password, commandBuffer
PUBLIC loginAttempts, loginSuccess
PUBLIC welcomeMsg, prompt, commandsString

; ---------- DATA ----------
.data

    ;---------- Shared variables ----------
    username        DB USERNAME_SIZE DUP('$')
    password        DB PASSWORD_SIZE DUP('$')
    commandBuffer   DB COMMAND_SIZE  DUP('$')
    loginAttempts   DB 0
    loginSuccess    DB 0

    ;---------- Messages ----------
    welcomeMsg      DB 13, 10
                    DB '==============================', 13, 10
                    DB ' OS SIMULATION v1.0', 13, 10
                    DB '==============================', 13, 10
                    DB 'Welcome to OS Simulation!', 13, 10
                    DB '$'

    prompt          DB 13, 10, 'OSS> $'

    commandsString  DB 13, 10
                    DB '==============================', 13, 10
                    DB 'HELP', 13, 10
                    DB 'CALC', 13, 10
                    DB 'TIME', 13, 10
                    DB 'LOG', 13, 10
                    DB 'STATUS', 13, 10
                    DB 'CLEAR', 13, 10
                    DB 'SNAKE',13,10
                    DB 'EXIT', 13, 10
                    DB '==============================',13,10
                    DB '$'

; ---------- CODE ----------
.code

    EXTRN KernelStart:NEAR          ; defined in Kernel.asm

MAIN PROC FAR
    MOV     AX, @data
    MOV     DS, AX

    CALL    KernelStart

    MOV     AX, 4C00h               ; exit to DOS
    INT     21h
MAIN ENDP

END MAIN
