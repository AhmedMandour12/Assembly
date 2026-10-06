; ==========================================
; Command.asm
; Command list module
; ==========================================

.model small

; Shared constants
INCLUDE DEFINE.INC

; ---------- EXPORTS ----------
PUBLIC ShowCommands

; ---------- DATA FROM OTHER MODULES ----------
.data
    EXTRN commandsString:BYTE      

; ---------- CODE ----------
.code


ShowCommands PROC NEAR
    MOV     DX, OFFSET commandsString
    MOV     AH, 09h
    INT     21h
    RET
ShowCommands ENDP

END
