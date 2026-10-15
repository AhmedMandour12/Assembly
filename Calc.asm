.model small

.data
   
    ; Calculator Messages
    CalcMenuMsg     DB 13,10
                    DB '================================',13,10
                    DB '       Welcome To Calculator',13,10
                    DB '================================',13,10,13,10
                    DB '1. Addition',13,10
                    DB '2. Subtraction',13,10
                    DB '3. Multiplication',13,10
                    DB '4. Division',13,10
                    DB '5. Exit',13,10,13,10
                    DB 'Choose an operation: $'

    FirstNumMsg     DB 13,10,'Enter first number: $'

    SecondNumMsg    DB 13,10,'Enter second number: $'

    ResultMsg       DB 13,10,'Result: $'

    InvalidChoice   DB 13,10,'Invalid choice!',13,10,'$'

    GoodbyeMsg      DB 13,10,'Goodbye!$'

           ; extra messages 
    InvalidNumMsg   DB 13,10,'Invalid number! Try again: $'
    DivZeroMsg      DB 13,10,'Cannot divide by zero!$'
    PressKeyMsg     DB 13,10,13,10,'Press any key to go back...$'

    
    ; Calculator Variables
    
    Choice          DB 0
    Num1            DW 0
    Num2            DW 0
    NumBuffer       DB 8 DUP('$')

.code

    PUBLIC Calculator

    EXTRN PrintString:NEAR
    EXTRN PrintChar:NEAR
    EXTRN ClearScrean:NEAR
    EXTRN ReloadScreen:NEAR
    EXTRN ReadInput:NEAR

    ;==========================================
    ; Calculator: main calculator screen
    ; Shows menu, does ONE operation, waits for a key,
    ; then calls ReloadScreen and returns to the OS loop
    ;==========================================
    Calculator PROC NEAR
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI

CalcMenu:
        Call ClearScrean
        Mov DX, OFFSET CalcMenuMsg
        Call PrintString

        Mov AH,01h              ; read one char with echo
        INT 21h
        Mov Choice,AL

        CMP AL,'5'
        JNE CalcNot5
        JMP CalcExit
CalcNot5:
        CMP AL,'1'
        JB CalcBadChoice
        CMP AL,'4'
        JA CalcBadChoice
        JMP CalcGetNumbers

CalcBadChoice:
        Mov DX, OFFSET InvalidChoice
        Call PrintString
        Mov AH,08h              ; let the user read the message
        INT 21h
        JMP CalcMenu

CalcGetNumbers:
        Mov DX, OFFSET FirstNumMsg
        Call PrintString
        Call ReadNumber         ; AX = number
        Mov Num1,AX

        Mov DX, OFFSET SecondNumMsg
        Call PrintString
        Call ReadNumber
        Mov Num2,AX

        Mov AL,Choice
        CMP AL,'1'
        JE DoAdd
        CMP AL,'2'
        JE DoSub
        CMP AL,'3'
        JE DoMul
        JMP DoDiv

DoAdd:
        Mov AX,Num1
        ADD AX,Num2
        CWD                     ; DX:AX = signed 32-bit result
        JMP ShowResult
DoSub:
        Mov AX,Num1
        SUB AX,Num2
        CWD
        JMP ShowResult
DoMul:
        Mov AX,Num1
        IMUL Num2               ; DX:AX = Num1 * Num2
        JMP ShowResult
DoDiv:
        CMP Num2,0
        JE DivByZero
        Mov AX,Num1
        CWD
        IDIV Num2               ; AX = quotient
        CWD
        JMP ShowResult

DivByZero:
        Mov DX, OFFSET DivZeroMsg
        Call PrintString
        JMP CalcWait

ShowResult:
        PUSH DX
        PUSH AX
        Mov DX, OFFSET ResultMsg
        Call PrintString
        POP AX
        POP DX
        Call PrintSigned32
        JMP CalcWait

CalcExit:
        Mov DX, OFFSET GoodbyeMsg
        Call PrintString

CalcWait:
        Mov DX, OFFSET PressKeyMsg
        Call PrintString
        Mov AH,08h
        INT 21h

        Call ReloadScreen       ; go back to the system screen

        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
    Calculator ENDP


    ;====
    ; ReadNumber: reads a number from the keyboard
    ; Output: AX = signed value (-9999 to 9999)
    ; Keeps asking until the input is valid
    ;====
    ReadNumber PROC NEAR
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI

RnRetry:
        Mov CX,5                ; max chars ( '-' + 4 digits )
        Mov BX,OFFSET NumBuffer
        Mov DH,0                ; show the typed chars (no stars)
        Call ReadInput

        Mov SI,OFFSET NumBuffer
        Call ParseNum           ; AX = number, CF = 1 if invalid
        JNC RnDone

        Mov DX, OFFSET InvalidNumMsg
        Call PrintString
        JMP RnRetry

RnDone:
        POP SI
        POP DX
        POP CX
        POP BX
        RET
    ReadNumber ENDP


    ;==========================================
    ; ParseNum: converts '$' terminated text at [SI] to a number
    ; Accepts optional '-' and 1 to 4 digits
    ; Output: AX = value, CF = 1 if invalid
    ;==========================================
    ParseNum PROC NEAR
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI

        XOR AX,AX
        XOR BX,BX               ; BX = 1 if negative
        XOR DI,DI               ; DI = digits count
        Mov CX,10

        CMP BYTE PTR [SI],'-'
        JNE PnLoop
        Mov BX,1
        INC SI

PnLoop:
        Mov DL,[SI]
        CMP DL,'$'
        JE PnEnd
        CMP DL,'0'
        JB PnBad
        CMP DL,'9'
        JA PnBad

        INC DI
        CMP DI,4
        JA PnBad

        SUB DL,'0'
        PUSH DX                 ; MUL destroys DX
        MUL CX                  ; AX = AX * 10
        POP DX
        XOR DH,DH
        ADD AX,DX
        INC SI
        JMP PnLoop

PnEnd:
        CMP DI,0                ; empty input (or just '-')
        JE PnBad
        CMP BX,1
        JNE PnOk
        NEG AX
PnOk:
        CLC
        JMP PnDone

PnBad:
        STC

PnDone:
        POP DI
        POP DX
        POP CX
        POP BX
        RET
    ParseNum ENDP


    ;==========================================
    ; PrintSigned32: prints DX:AX as a signed decimal number
    ;==========================================
    PrintSigned32 PROC NEAR
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI

        TEST DX,8000h
        JZ PsPositive

        PUSH AX                 ; negative: print '-' then negate DX:AX
        PUSH DX
        Mov DL,'-'
        Call PrintChar
        POP DX
        POP AX
        NOT AX
        NOT DX
        ADD AX,1
        ADC DX,0

PsPositive:
        XOR CX,CX               ; CX = digits count
        Mov BX,10

PsDivLoop:
        Mov SI,AX               ; SI = low word
        Mov AX,DX               ; AX = high word
        XOR DX,DX
        DIV BX                  ; AX = high / 10 , DX = high % 10
        XCHG AX,SI              ; SI = high quotient , AX = low word
        DIV BX                  ; AX = low quotient , DX = remainder
        PUSH DX                 ; save the digit
        INC CX
        Mov DX,SI               ; DX:AX = quotient
        CMP AX,0
        JNE PsDivLoop
        CMP DX,0
        JNE PsDivLoop

PsPrint:
        POP DX
        ADD DL,'0'
        Call PrintChar
        LOOP PsPrint

        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
    PrintSigned32 ENDP

END
