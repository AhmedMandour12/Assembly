.model small
; Shared constants 
INCLUDE DEFINE.INC
; ---------- EXPORTS ----------
 PUBLIC ShowCommands
 PUBLIC ExecuteCommand
 Public ReloadScreen
 Public CompareString
; ---------- DATA FROM OTHER MODULES ----------
.data
    EXTRN loginAttempts:byte
    EXTRN commandBuffer:BYTE 
    EXTRN commandsString:BYTE
    EXTRN welcomeMsg:BYTE
    cmdHelp     DB 'HELP$'
    cmdStatus   DB 'STATUS$'
    cmdExit     DB 'EXIT$'
    cmdClear    DB 'CLEAR$'
    cmdTime    DB 'TIME$'
    cmdLogOut  DB 'LOGOUT$'
    statusMsg   DB 13,10,'Loged In , Attempts Used : $'
    NotAvailableCommand DB 13,10,'Not Available Command.$'
    helpMsg DB 13,10
        DB '================================',13,10
        DB '           HELP MENU            ',13,10
        DB '================================',13,10
        DB 13,10
        DB 'Available Commands:',13,10
        DB '-------------------',13,10
        DB 'HELP    - Show this help menu',13,10
        DB 'CALC    - Open calculator',13,10
        DB 'TIME    - Display current time',13,10
        DB 'LOGOUT     - LogOut The System',13,10
        DB 'STATUS  - Show system status',13,10
        DB 'CLEAR   - Clear the screen',13,10
        DB 'EXIT    - Exit ',13,10
        DB 13,10
        DB '================================',13,10
        DB '$'
    timeMsg    DB 13,10,'Current Time: $'
    
; ---------- CODE ---------- 
.code

    EXTRN PrintString:Near
    EXTRN ClearScrean:NEAR
    EXTRN PrintChar:Near
    EXTRN LogOut:Near
    ShowCommands PROC NEAR
        MOV DX, OFFSET commandsString
        Call PrintString
        RET
    ShowCommands ENDP
    
    ;=================
    ; If you want Case Sensetive put 1 in cl
    CompareString PROC NEAR

CmpLoop:
        MOV AL, [SI]
        MOV BL, [DI]
        
        CMP AL ,'$'
        JNE ContinueCmp
        CMP BL,'$'
        JE Equal
        
    ContinueCmp:
        CMP CL,1
        JE CaseSensetive
        AND AL, 0DFh
        AND BL, 0DFh
    CaseSensetive:
        CMP AL, BL
        JNE NotEqual

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
    ;HELP
        MOV SI,OFFSET commandBuffer
        MOV DI,OFFSET cmdHelp
        MOV CL,0
        Call CompareString
        CMP AL,1
        JE HelpCommand
    
    ;Status
        MOV SI, OFFSET commandBuffer
        MOV DI, OFFSET cmdStatus
        MOV CL,0
        Call CompareString
        CMP AL, 1
        JE StatusCommand
    ;Clear
        MOV SI,OFFSET commandBuffer
        MOV DI,OFFSET cmdClear
        MOV CL,0
        Call CompareString
        CMP AL,1
        JE ClearCommand
    
    ; TIME
        MOV SI, OFFSET commandBuffer
        MOV DI, OFFSET cmdTime
        MOV CL,0
        CALL CompareString
        CMP AL, 1
        JE TimeCommand 
        
     ; LogOut
        MOV SI, OFFSET commandBuffer
        MOV DI, OFFSET cmdLogOut
        MOV CL,0
        CALL CompareString
        CMP AL, 1
        JE LogOutCommand    
           
        
    ;EXIT
        Mov SI , OFFSET commandBuffer
        Mov DI, OFFSET cmdExit
        MOV CL,0
        Call CompareString
        CMP AL,1
        JE ExitCommand
        
    ;NotAvailableCommand
        Mov DX , OFFSET NotAvailableCommand
        Call PrintString
        RET
        
HelpCommand:
        Mov DX,OFFSET helpMsg
        Call PrintString
        JMP Finish
        
StatusCommand:
        Mov DX ,OFFSET statusMsg
        Call PrintString
        Mov DL,loginAttempts
        ADD DL,'0'
        Call PrintChar
        JMP Finish
ClearCommand:
        Call ReloadScreen
        JMP Finish

TimeCommand:
        call ShowTime
        JMP Finish

LogOutCommand:
        Call LogOut
        JMP Finish
        
Finish:
        Mov AL,0
        RET
ExitCommand:
       ; Mov AL,1
        RET
        
        ExecuteCommand ENDP
        
        ReloadScreen Proc Near
            Call ClearScrean
            Mov DX, OFFSET welcomeMsg
            Call PrintString
            Call ShowCommands
            RET
        ReloadScreen ENDP
        
        ShowTime Proc Near
            Mov DX,OFFSET timeMsg    
            Call PrintString
            
            Mov AH,2cH
            INT 21h
            
            Mov AL, CH ;HOURS
            Call PrintTwoDigits
            Mov Dl,':'
            Call PrintChar
            
            Mov AL,CL ; Mints
            Call PrintTwoDigits
            Mov Dl,':'
            Call PrintChar
            
            Mov AL,DH ; Seconds
            Call PrintTwoDigits
            
            Ret
            
        ShowTime ENDP
        
        PrintTwoDigits Proc Near
            PUSH AX
            PUSH DX
            
            
            AAM
            ADD AH,'0'
            ADD AL,'0'
            
            PUSH AX ; store register
            
            MOV DL,AH
            Call PrintChar
            
            POP AX ; Restore Register
            Mov DL,AL
            Call PrintChar
            
            POP DX
            POP AX
            
            RET
            
            
        PrintTwoDigits ENDP
        
END
