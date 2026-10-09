.model small

INCLUDE DEFINE.INC

.data
    EXTRN username:Byte
    EXTRN password:BYTE
    EXTRN loginAttempts:byte
    EXTRN loginSuccess:byte
    Admin DB 'Admin$'
    AdminPassword DB '1234$'
    
    UsernameMsg DB 'Username : $'
    PasswordMsg DB 'Password : $'
    LockMsg     DB 'Too Many Wrong Attempts System Locked. $'
    WrongMsg    DB 'Wrong Username OR Password ',13,10,'$'

.code

PUBLIC Login
PUBLIC ReadInput
PUBLIC LogOut

    EXTRN CompareString:Near
    EXTRN PrintChar:NEAR
    EXTRN PrintString:NEAR
    EXTRN ReloadScreen:Near
    EXTRN PrintNewLine:Near
    
    
    Login Proc Near
        Call PrintNewLine
LoginLoop:
        Mov DX, OFFSET UsernameMsg
        Call PrintString
        
        Mov CX,USERNAME_SIZE-1
        Mov BX,OFFSET username
        Mov DH,0
        Call ReadInput
        
        
        Mov DX, OFFSET PasswordMsg
        Call PrintString
        
        Mov CX ,PASSWORD_SIZE-1
        Mov BX,OFFSET password
        Mov DH,1
        Call ReadInput
        
        
        
        Call Valedate
        

        
        
        CMP loginSuccess,1
        JE EnterSystem
        
        CMP loginAttempts,MAX_ATTEMPTS
        JAE LockSystem
        
        JMP LoginLoop
EnterSystem:
        Call ReloadScreen
        Ret
LockSystem:
        Mov DX, OFFSET LockMsg
        Call PrintString
        Mov AX,4c00h
        INT 21h
        RET
               
    Login ENDP
    
    Valedate Proc Near
    
        Mov CL,1
        MOV SI, OFFSET username
        MOV DI, OFFSET Admin
       
        CALL CompareString 
        

        CMP AL,1
        JNE LoginFailed

        Mov CL,1
        MOV SI, OFFSET password
        MOV DI, OFFSET AdminPassword
        CALL CompareString
        CMP AL,1
        JNE LoginFailed
        
        MOV loginSuccess, 1
        RET
        
LoginFailed:
            
        Mov loginSuccess,0
        Inc loginAttempts
        MOV DX, OFFSET WrongMsg
        CALL PrintString
        
        RET
    Valedate ENDP
    
    
    ;====================
    ; Put Max Input Length in CX
    ; Put Address Of The Variable in BX
    ; If you want stars on screen put 1 in DH
    ;============
    ReadInput Proc Near
        PUSH AX
        PUSH DX
        PUSH SI
        PUSH BX
        
        MOV SI,0
ReadLoop:
        
        CMP SI,CX
        JAE Finished
        
        MOV Ah,08h
        INT 21h
        
        
        CMP AL,13
        JE Finished
        
        CMP AL,8
        JE HandleBackSpace
        
        
        MOV [BX+SI],AL
        inc SI
        
        
        CMP DH,1
        JE PrintStars
        
        Mov DL,AL
        Call PrintChar
        JMP ReadLoop
        
PrintStars:  
    Mov DL,'*'
    Call PrintChar
    JMP ReadLoop
        
 HandleBackSpace:
        CMP SI,0
        JE IgnoreBackSpace
        
        DEC SI
        Mov BYTE PTR [BX+SI],'$'
       
        MOV DL,8
        Call PrintChar
        
        MOV DL,' '
        Call PrintChar
        
        MOV DL,8
        Call PrintChar
        
        
        JMP ReadLoop

 IgnoreBackSpace:
        JMP ReadLoop
        
 Finished:
        MOV BYTE PTR[BX+SI],'$'
        Call PrintNewLine
        POP BX
        POP SI
        POP DX
        POP AX
        
        RET
    ReadInput ENDP

    LogOut Proc Near
        Mov loginAttempts,0
        Mov loginSuccess,0
        Call KernelStart
        RET
    LogOut ENDP
END
