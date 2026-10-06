
.model small

; Shared constants
INCLUDE DEFINE.INC

; ---------- EXPORTS ----------
PUBLIC ShowCommands
PUBLIC ExecuteCommand

; ---------- DATA FROM OTHER MODULES ----------
.data
    EXTRN commandBuffer:BYTE
    EXTRN commandsString:BYTE 

    cmdHelp    DB 'HELP$'    

; ---------- CODE ----------
.code

ShowCommands PROC NEAR

  
    MOV     DX, OFFSET commandsString
    MOV     AH, 09h
    INT     21h
    RET
ShowCommands ENDP

CompareString PROC NEAR
CmpLoop:
    MOV AL, [SI]
    MOV BL, [DI]
    CMP AL, BL
    JNE NotEqual
    CMP AL, '$'
    JE  Equal
    INC SI
    INC DI
    JMP CmpLoop
Equal:
    MOV AL, 1
    RET
NotEqual:
    MOV AL, 0
    RET
CompareString ENDP

ExecuteCommand PROC NEAR
    MOV SI, OFFSET commandBuffer
    MOV DI, OFFSET cmdHelp
    CALL CompareString
    CMP AL, 1
    JNE NotHelp

    CALL ShowCommands
    
NotHelp:
    MOV AL, 0
    RET
ExecuteCommand ENDP 

END
