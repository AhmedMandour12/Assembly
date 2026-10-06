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
    cmdHelp     DB 'HELP$'
    cmdStatus   DB 'STATUS$'
    cmdExit     DB 'EXIT$'
    statusMsg   DB 13,10,'OS Simulation is running...$'
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
        DB 'LOG     - Show security log',13,10
        DB 'STATUS  - Show system status',13,10
        DB 'CLEAR   - Clear the screen',13,10
        DB 'EXIT    - Exit ',13,10
        DB 13,10
        DB '================================',13,10
        DB '$'
    
; ---------- CODE ---------- 
.code

    EXTRN PrintString:Near
    
    
    ShowCommands PROC NEAR
        MOV DX, OFFSET commandsString
        Call PrintString
        RET
    ShowCommands ENDP
    
    CompareString PROC NEAR
    
CmpLoop:
        MOV AL, [SI]
        MOV BL, [DI]
        
        CMP AL ,'$'
        JNE ContinueCmp
        CMP BL,'$'
        JE Equal
        
    ContinueCmp:
        AND AL, 0DFh
        AND BL, 0DFh
        
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
        Call CompareString
        CMP AL,1
        JE HelpCommand
    
    ;Status
        MOV SI, OFFSET commandBuffer
        MOV DI, OFFSET cmdStatus
        Call CompareString
        CMP AL, 1
        JE StatusCommand
        
    ;EXIT
        Mov SI , OFFSET commandBuffer
        Mov DI, OFFSET cmdExit
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
        JMP Finish
Finish:
        Mov AL,0
        RET
ExitCommand:
       ; Mov AL,1
        RET
        
        ExecuteCommand ENDP
      
    
END
