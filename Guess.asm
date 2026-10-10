.Model small
MAX_GUESSES EQU 7

.data
    Answer DB 0
    Tries  DB 0
    GuessBuffer DB 4,0,4 DUP(0);First byte is size second byte number of character 3,4,5,6 is the input  
    
    GameHdrMsg    DB 13,10,'===================== GUESS THE NUMBER =====================',13,10
                  DB '              I picked a number between 1 and 100.',13,10
                  DB '              You have $'
    GameHdr2Msg   DB ' tries. Type Q to quit.',13,10
                  DB '============================================================',13,10,'$'
    GamePrompt DB 'Your guess: $'
    GuessLowMsg   DB 'Too LOW.$'
    GuessHighMsg  DB 'Too HIGH.$'
    TriesLeftMsg     DB ' Tries left: $'
    InvalidInputMsg   DB 'Please enter a number from 1 to 100.',13,10,'$'

    GameWinMsg      DB 'Correct! You got it in $'
    TriesMsg      DB ' tries.',13,10,'$'
    LoseMsg     DB 13,10,'        Game over! The number was : $'
    QuitMsg   DB 13,10,'          Game cancelled.',13,10,'$'

.Code
    
PUBLIC Guess

    EXTRN PrintString:NEAR
    EXTRN PrintChar:NEAR
    EXTRN PrintNewLine:NEAR
    
    Guess PROC NEAR
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
        
        MOV AH,2Ch
        INT 21h
        
        Mov AL,DL
        ADD AL,DH
        XOR AH,AH ; Make sure AH =0
        Mov BL,100
        DIV BL
        Mov AL,AH
        INC AL
        MOV Answer,AL
        Mov Tries,0
        
        Mov DX,OFFSET GameHdrMsg
        Call PrintString
        Mov AL ,MAX_GUESSES
        Call PrintNum  
        Mov DX , OFFSET GameHdr2Msg
        Call PrintString
        
GameLoop:     
        
        Mov Al, Tries
        CMP AL,MAX_GUESSES
        JB Play
        JMP GameLose
Play:
        Mov DX, OFFSET GamePrompt
        Call PrintString
        
        Mov DX, OFFSET GuessBuffer
        MOV AH,0Ah
        INT 21h
        Call PrintNewLine
        
        Mov AL,GuessBuffer+2
        AND AL,0DFh
        CMP AL,'Q'
        JNE NotQuit
        JMP Quit
        
NotQuit:
        Call ParseGuess ; AX = number, CF = 1 if not a number
        JC InvalidInput
        
        CMP AX,1
        JB InvalidInput
        CMP AX,100
        JA InvalidInput
        
        INC Tries
        CMP AL,Answer
        JE GameWin
        JA GameTooHigh
        
        Mov DX, Offset GuessLowMsg
        JMP Show
GameTooHigh:
        Mov DX , OFFSET GuessHighMsg
Show:
        Call PrintString
        Mov DX,OFFSET TriesLeftMsg
        Call PrintString
        MOV AL , MAX_GUESSES
        SUB AL,Tries
        Call PrintNum
        Call PrintNewLine
        JMP GameLoop
        
InvalidInput:
        Mov DX,OFFSET InvalidInputMsg
        Call PrintString
        JMP Play
GameWin:
        Mov DX,OFFSET GameWinMsg
        Call PrintString
        Mov AL,Tries
        Call PrintNum
        Mov Dx,OFFSET TriesMsg
        Call PrintString
        JMP GameDone

GameLose:
        Mov Dx,OFFSET LoseMsg
        Call PrintString
        Mov AL,Answer
        Call PrintNum
        Call PrintNewLine
        JMP GameDone
        
Quit:
        Mov DX,OFFSET QuitMsg  
        Call PrintString
GameDone: 
        
        MOV AH,08h
        int 21h
        
        POP DX
        POP CX
        POP BX
        POP AX


        Ret       
    Guess ENDP
     
    
    ;Prints AL 0-255 As decimal
    PrintNum Proc Near
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
        XOR AH,AH
        XOR CX,CX
        Mov BL,10
        
Divide:
        Div BL
        PUSH AX
        INC CX
        XOR AH,AH
        CMP AL,0
        JNE Divide
Print:
        POP AX
        Mov Dl,AH ; Remainder Was In AH
        ADD DL,'0'
        Call PrintChar
        Loop Print
       
        POP DX
        POP CX
        POP BX
        POP AX
        
        RET
    PrintNum EndP
  
    
    ;==========================================
    ; ParseGuess: converts GuessBuffer text to a number
    ; Output: AX = value, CF = 1 if invalid (empty / non-digit)
    ;==========================================
    ParseGuess Proc Near
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        
        XOR CH,CH
        MOV CL,GuessBuffer+1; Count OF input Chars
        JCXZ ParseBad
        MOV SI,OFFSET GuessBuffer+2;Address OF The First Char
        XOR AX,AX
        Mov BL,10
ParseLoop:
        Mov DL,[SI]
        CMP DL,'0'
        JB ParseBad
        CMP DL,'9'
        JA ParseBad
        
        SUB DL,'0'
        Mul BL
        XOR DH,DH ; Make sure DH =0 For next Instruction Cuz We just Need DL
        ADD AX,DX
        INC SI
        LOOP ParseLoop
        
        CLC
        JMP ParseDone
        
ParseBad:
         STC
        
ParseDone:        
        POP SI
        POP DX
        POP CX
        POP BX
        RET
    ParseGuess ENDP
    
  
  
  
  
  
    
END






