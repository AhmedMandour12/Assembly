; ==========================================
; Kernel.asm
; Main loop + screen / keyboard helpers
; ==========================================

.model small

; Shared constants
INCLUDE DEFINE.INC

; ---------- EXPORTS ----------
PUBLIC KernelStart
PUBLIC PrintString
PUBLIC ShowPrompt
PUBLIC ClearScreen
PUBLIC ReadCommand

; ---------- DATA FROM OTHER MODULES ----------
.data
    EXTRN welcomeMsg:BYTE           ; Main.asm
    EXTRN prompt:BYTE               ; Main.asm
    EXTRN commandBuffer:BYTE        ; Main.asm
    EXTRN commandsString:BYTE       ; Main.asm

; ---------- CODE ----------
.code

    ; PROCEDURES FROM OTHER MODULES
    EXTRN ShowCommands:NEAR        
    ; EXTRN Login:NEAR              ; under construction (AUTH.asm)


KernelStart PROC NEAR
    CALL    ClearScreen

    MOV     DX, OFFSET welcomeMsg
    CALL    PrintString

    ; CALL  Login                   ; under construction (AUTH.asm)
     CALL    ShowCommands
CommandLoop:
    CALL    ShowPrompt
    CALL    ReadCommand
 

    ; CALL  ExecuteCommand          ; under construction
    ; CMP   AL, 1                   ; AL = 1 when command == EXIT
    ; JE    KernelExit

    JMP     CommandLoop             ; infinite loop until Command.asm is finished

KernelExit:
    RET
KernelStart ENDP


PrintString PROC NEAR
    MOV     AH, 09h
    INT     21h
    RET
PrintString ENDP


ShowPrompt PROC NEAR
    MOV     DX, OFFSET prompt
    CALL    PrintString
    RET
ShowPrompt ENDP


ReadCommand PROC NEAR
    MOV     SI, 0

ReadLoop:
    CMP     SI, COMMAND_SIZE - 1
    JAE     Finished

    MOV     AH, 01h                 ; read char with echo
    INT     21h

    CMP     AL, 13                  ; Enter?
    JE      Finished

    MOV     commandBuffer[SI], AL
    INC     SI
    JMP     ReadLoop

Finished:
    MOV     commandBuffer[SI], '$'
    RET
ReadCommand ENDP

;-------------------------------------------
; ClearScreen
; Clears the screen and homes the cursor.
; After calling it, print a message / prompt.
;-------------------------------------------
ClearScreen PROC NEAR
    PUSH    AX
    PUSH    BX
    PUSH    CX
    PUSH    DX

    ; Scroll window up (INT 10h, AH=06h) = clear
    MOV     AH, 06h                 ; scroll up
    MOV     AL, 00h                 ; 0 lines = clear whole window
    MOV     BH, 07h                 ; attribute: light gray on black
    MOV     CX, 0000h               ; top-left     (row 0,  col 0)
    MOV     DX, 184Fh               ; bottom-right (row 24, col 79)
    INT     10h

    ; Move cursor to top-left (INT 10h, AH=02h)
    MOV     AH, 02h
    MOV     BH, 00h                 ; page 0
    MOV     DX, 0000h               ; row 0, col 0
    INT     10h

    POP     DX
    POP     CX
    POP     BX
    POP     AX
    RET
ClearScreen ENDP

END
