
.model small
; Shared Constants
INCLUDE DEFINE.INC


.stack 100h
.data
    
    ;===================
    ; Shared Variable
    ;====================
    username db USERNAME_SIZE DUP('$')
    password db PASSWORD_SIZE DUP('$')
    commandBuffer db COMMAND_SIZE DUP('$')
    loginAttempts db 0
    loginSuccess db 0
    ; ========================================== 
    ; Messages 
    ; ==========================================
     welcomeMsg DB 13,10
     DB '======================================================',13,10
     DB '                 OS SIMULATION v1.1',13,10
     DB '======================================================',13,10
     DB '             Welcome to OS Simulation!',13,10 
     DB '$' 
     prompt DB 13,10,'OSS> $'
     commandsString DB 13,10
     DB '==============================',13,10
     DB 'HELP',13,10
     DB 'CALC',13,10
     DB 'TIME',13,10
     DB 'LOGOUT',13,10
     DB 'STATUS',13,10
     DB 'CLEAR',13,10
     DB 'EXIT',13,10
     DB '==============================',13,10
     DB '$' 
     
     
.CODE
     EXTRN KernelStart:NEAR
     PUBLIC username
     PUBLIC password
     PUBLIC commandBuffer
     PUBLIC loginAttempts
     PUBLIC loginSuccess 
     PUBLIC welcomeMsg
     PUBLIC prompt
     PUBLIC commandsString
     
     MAIN PROC FAR
         MOV AX, @data 
         MOV DS, AX 
         CALL KernelStart
         MOV AX, 4C00h
         INT 21h
     MAIN ENDP 
     END MAIN
