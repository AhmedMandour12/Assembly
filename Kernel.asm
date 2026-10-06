.model small

; Shared Constants
INCLUDE DEFINE.INC


.data

    ;==================
    ; Get Data From Other Modules
    ;==================
    EXTRN welcomeMsg:byte
    EXTRN prompt:byte
    EXTRN commandBuffer:byte
    
.code

;=======================
; Get Procedures From Other Modules
;========================
Extrn ShowCommands:NEAR; Under Constraction in Command.asm File
Extrn ExecuteCommand:NEAR
;Extrn Login:Near Under Constraction in AUTH.asm

;=============================
;Make Proceduers Public For Other Modules
;=============================
PUBLIC KernelStart
Public PrintString
Public ShowPrompt
Public ClearScrean
Public ReadCommand

;===================
;Procedures
;=================
KernelStart PROC NEAR
    MOV AX,@data
    MOV DS,AX
    
    Call ClearScrean
    MOV DX,OFFSET welcomeMsg
    Call PrintString
    
    ;Call Login Under Constraction in AUTH.asm
    ;Call ShowCommands; Under Constraction in Command.asm File
CommandLoop:
    Call ShowPrompt
    Call ReadCommand
    Call ExecuteCommand  ; Under Constraction in Command.asm File
    CMP AL,1 ; if command == exit then mov AL,1
    JE KernalExit
    
    JMP CommandLoop ; infinite loop just for now until Command.asm is finished

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
    
    ;clear interrupt 10 ,ah =06
    MOV AH,06h ; scrol up
    MOV AL, 00H; clear
    
    MOV BH,07h; Color Light Gray Background Black
    
    Mov CX,0000h;start from first row and first column
    Mov DX,184FH;DH:ROW  DL: Column, DOS is 25x80  this means i have 25 row and 80 columns , index starting from 0
   
    INT 10H;Clrear From(0,0) To (24,97)
    
    
    ;Move Curser UP INT 10 AH 02
    MOV AH,02H
    MOV BH,00H ; Page0
    MOV DX,0000H
    INT 10H
    
    RET
ClearScrean ENDP

end