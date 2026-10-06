
.model small
INCLUDE DEFINE.INC

.data

    EXTRN welcomeMsg:byte
    EXTRN prompt:byte
    EXTRN commandBuffer:byte
    
.code

Extrn ShowCommands:NEAR 
Extrn ExecuteCommand:Near
;Extrn Login:Near Under Constraction in AUTH.asm

PUBLIC KernelStart
Public PrintString
Public ShowPrompt
Public ClearScrean
Public ReadCommand

;===================
;Procedures
;=================
KernelStart PROC NEAR
    Mov AX,@data
    Mov DS,AX
    Call ClearScrean
    MOV DX,OFFSET welcomeMsg
    Call PrintString
    ;Call Login Under Constraction in AUTH.asm
    Call ShowCommands 
CommandLoop:
    Call ShowPrompt
    Call ReadCommand
    Call ExecuteCommand  
    CMP AL,1 ; if command == exit then mov AL,1
    JE KernalExit
    
    JMP CommandLoop 

KernalExit :   
    RET
    
KernelStart ENDP

PrintString PROC NEAR
    MOV AH,09H
    INT 21H
    RET
PrintString ENDP

ShowPrompt PROC NEAR
    MOV DX, OFFSET prompt
    Call PrintString
    RET
ShowPrompt ENDP

ReadCommand PROC NEAR

    MOV SI,0
ReadLoop:
    CMP SI,COMMAND_SIZE-1
    JAE Finished
    
    MOV Ah,01h
    INT 21h
    
    CMP AL,13
    JE Finished
    
    MOV commandBuffer[SI],AL
    inc SI
    JMP ReadLoop
    
    
Finished:
    MOV commandBuffer[SI],'$'
    RET
    
ReadCommand ENDP

;After Clear Screen you should Show Any Message Like Welcome And Commands And Prompet >.<
ClearScrean Proc Near
   PUSH AX
    PUSH DX
    PUSH BX
    
    MOV AH, 00H
    MOV AL, 03H     ; Mode 03h: 80x25 text mode, 16 colors
    INT 10H

    
    ;Move Curser UP INT 10 AH 02
    MOV AH,02H
    MOV BH,00H ; Page0
    MOV DX,0000H
    INT 10H
    
    POP BX
    POP DX
    POP AX
    
    RET
ClearScrean ENDP

end
