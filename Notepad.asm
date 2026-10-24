.model small

NOTE_SIZE EQU 2000

.data

    noteBuffer DB NOTE_SIZE DUP('$')

    noteLen    DW 0
    noteFile   DB 'NOTE.TXT',0
    Header   DB 13,10,'--- NOTEPAD  (ESC = save and exit, Backspace = delete) ---',13,10,'$'
    Footer   DB 13,10,'--- Saved to NOTE.TXT ---',13,10,'$'
    SaveErr  DB 13,10,'--- Error: could not save NOTE.TXT ---',13,10,'$'

.code
PUBLIC Notepad  
EXTRN PrintString:NEAR
EXTRN PrintChar:NEAR
EXTRN PrintNewLine:NEAR

Notepad PROC Near
    PUSH AX
    PUSH BX
    PUSH DX
    PUSH SI
    PUSH CX
    
    MOV DX,OFFSET Header
    Call PrintString
    
    Call LoadNote
    Mov DX,OFFSET noteBuffer
    Call PrintString
    Mov BX,noteLen
MainLoop:
    Mov AH,08h
    INT 21h
    
    CMP AL,27;esc
    JNE NotEsc
    JMP Save
NotEsc:
    CMP AL,0 ; extended key(arrow,f-key) arrive as 2 bytes
    JE Extended
    CMP AL,8
    JE Back
    CMP AL,13
    JE KeyEnter
    CMP AL,32 ;other controls
    JB MainLoop
    CMP AL,'$';ignore
    JE MainLoop
    
    CMP BX,NOTE_SIZE-3
    JAE FullBeep
    
    Mov[noteBuffer+BX],AL
    INC BX
    Mov DL,AL
    Call PrintChar
    JMP MainLoop
    
Extended:
    Mov AH,08h ; read and discard second byte 
    int 21h
    JMP MainLoop
KeyEnter:
    CMP BX,NOTE_SIZE-3
    JAE FullBeep
    Mov BYTE PTR [noteBuffer+BX],13
    INC BX
    Mov BYTE PTR [noteBuffer+BX],10
    INC BX
    Call PrintNewLine
    JMP MainLoop
    
FullBeep: 
    Mov DL,7
    Call PrintChar
    JMP MainLoop
    
Back:
    CMP BX,0
    JE MainLoop
    CMP BYTE PTR [noteBuffer+BX-1],10
    JE BackLine ; last char is ENTER
    
    DEC BX
    Mov BYTE PTR [noteBuffer+BX],'$'
    
    PUSH BX
    MOV AH,03H;get cursor
    MOV BH,0
    INT 10H
    OR DL,DL ;first col
    JZ BackWrap
    POP BX
    
    Mov DL,8
    Call PrintChar
    Mov DL,' '
    Call PrintChar
    Mov DL,8
    Call PrintChar
    JMP MainLoop
BackWrap:
     OR DH,DH ;top row
     JZ BackWrapEnd
     DEC DH
     Mov AH,0Fh;AH = width,BH=page
     INT 10H
     Mov DL,AH
     DEC DL  ; index start from 0 so we dec dl
     Mov AH,02H ; move cursor
     Int 10h
     Mov AX,0A20h;AH=0A write char at cursor char = 20 space 
     Mov cx,1;repet 1 time
     INT 10h
 BackWrapEnd:
     POP BX
     JMP MainLoop
     ;----handle line break
BackLine:
    DEC BX
    CMP BX,0
    JE BackCut
    CMP BYTE PTR [noteBuffer+BX-1],13
    JNE BackCut
    DEC BX
BackCut:
    Mov Byte PTR[noteBuffer+BX],'$'
    ;cx =length of prev line
    mov SI,BX
    Xor cx,cx
Count:
    CMP SI,0
    JE CountDone
    CMP BYTE PTR [noteBuffer+SI-1],10
    JE CountDone
    DEC SI
    INC CX
    JMP Count
    
CountDone:
    PUSH BX
    PUSH CX
    Mov AH,03
    Mov BH,0
    INT 10H
    POP CX
    
    OR DH,DH ; check if row=0
    JZ CurserDone
    
    DEC DH ; one row up
    Mov DL,CL ; Col = end of prev Line
    
    Mov AH,02H
    Mov BX,0
    Int 10h
CurserDone:
    POP BX
    JMP MainLoop
    
    
    
    
Save:
    Mov noteLen,BX
    Call SaveNote ;CF=1 if err
    Mov DX,OFFSET Footer
    JNC Done
    Mov DX,OFFSET SaveErr
    
Done:
    Call PrintString
    POP CX
    POP SI
    POP DX
    POP BX
    POP AX
    RET
Notepad ENDP


LoadNote PROC Near
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV noteLen,0
    
    Mov AX,3d00h
    Mov DX,OFFSET noteFile
    INT 21h
    JC LoadDone ; carry is set if cant open 
    ;AX = FileHandle
    
    Mov BX,AX ;FileHandle in BX
    Mov AH,3fh ; read after open
    Mov CX,NOTE_SIZE-3;Max Byte To Read
    Mov DX,OFFSET noteBuffer ;Destination
    INT 21h
    JC LoadClose
    Mov noteLen,AX
LoadClose:
    Mov AH,3eh
    INT 21h
LoadDone:
    Mov BX, noteLen
    Mov BYTE PTR [noteBuffer+BX],'$'

    POP DX
    POP CX
    POP BX
    POP AX
    RET
LoadNote ENDP
  
;CF =1 If error
SaveNote Proc Near
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  
  Mov AH,3ch
  Mov CX,0;normal file
  Mov DX,OFFSET noteFile
  INT 21H
  JC SaveDone
  
  Mov BX,AX; save File handle
  Mov AH, 40H
  Mov CX,noteLen
  LEA DX, noteBuffer
  INT 21H
  
  PUSHF ; Save carry flag 
  Mov AH,3Eh
  INT 21h
  POPF
  
SaveDone: 
  POP DX
  POP CX
  POP BX
  POP AX
  RET
SaveNote ENDP
END
