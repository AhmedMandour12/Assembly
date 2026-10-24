.model small
.stack 100h

; Data segment
.data
board     db '1','2','3','4','5','6','7','8','9'
player    db 'X'
moves     db 0

; all 8 winning lines (indices into board)
wins      db 0,1,2, 3,4,5, 6,7,8
          db 0,3,6, 1,4,7, 2,5,8
          db 0,4,8, 2,4,6

msgTitle  db '=== XO Game ===',13,10,13,10,'$'
msgplayer db 13,10,'Player $'
msgEnter  db ', choose cell (1-9): $'
msgInvalid db 13,10,'Invalid or taken cell! Press any key...$'
msgWin    db 13,10,'Player $'
msgWins   db ' wins!',13,10,'$'
msgDraw   db 13,10,'well played nobody won!',13,10,'$'
newline   db 13,10,'$'
sep       db ' | $'  ;Separator
line      db '---+---+---',13,10,'$'; separator between each row

.code
PUBLIC xoGame
EXTRN PrintString:Near

xoGame proc Near
    push ax                
    push bx                
    push cx                
    push dx                
    push si               

    call reset_game
    
game_loop:
    call draw
    ;print massage
    mov dx,offset msgplayer
    call PrintString
    mov dl, player
    call print
    mov dx,offset msgEnter
    call PrintString

    mov ah, 1              ; read a character
    int 21h
    cmp al, '1'
    jb  invalid
    cmp al, '9'
    ja  invalid

    sub al, '1'            ; convert to index 0..8
    xor ah, ah
    mov si, ax

    mov al, board[si]      ; is the cell already taken?
    cmp al, 'X'
    je  invalid
    cmp al, 'O'
    je  invalid

    mov al, player         ; place the mark
    mov board[si], al
    inc moves

    call check_win
    cmp al, 1
    je  win
    cmp moves, 9
    je  draw_game

    cmp player, 'X'        ; switch player
    je  set_o
    mov player, 'X'
    jmp game_loop
set_o:
    mov player, 'O'
    jmp game_loop

invalid:
    mov dx,offset msgInvalid
    call PrintString
    mov ah, 1              ; wait for a key
    int 21h
    jmp game_loop

win:
    call draw
    mov dx,offset msgWin
    call PrintString
    mov dl, player
    call print
    mov dx,offset msgWins
    call PrintString
    jmp exit

draw_game:
    call draw
    mov dx,offset msgDraw
    call PrintString

exit:
    mov ah,1
    int 21h
    
    pop si                
    pop dx                 
    pop cx                
    pop bx                
    pop ax
    ret
xoGame endp

reset_game proc near
    mov cx, 9
    mov si, 0
    mov al, '1'
resetloop:
    mov board[si], al
    inc al
    inc si
    loop resetloop

    mov player, 'X'
    mov moves, 0
    ret
reset_game endp
; print command shortcut for improvement
print proc
    mov ah, 2
    int 21h
    ret
print endp

;  draw the ?game board 
; clear screen

draw proc
    mov ax, 0003h ;Because the program calls Procedur?`draw`in almost every iteration.         
    int 10h ;requests BIOS to perform a service

    mov dx,offset msgTitle  ;dx title of the text
    call PrintString

    
    mov si, 0;Because we want to start from the first cell on the board
    mov cx, 3; Repeat the drawing of the rows 3 times.
row_loop:
    mov dl, ' '
    call print
    
    mov dl, board[si] ;go to the board matrix give the value of the cell that si consults and put it in dl
    call print
    
    mov dx,offset sep
    call PrintString
    
    mov dl, board[si+1] 
    call print
    mov dx,offset sep
    call PrintString
    
    mov dl, board[si+2]
    call print
    
    mov dx,offset newline
    call PrintString

    add si, 3 
    cmp cx, 1
    je  no_line
    
    mov dx,offset line
    call PrintString
no_line:
    loop row_loop
    ret
draw endp

 ;checks 8 possible winning combinations 3 rows 3 columns 2 diagonals.
check_win proc
    mov cx, 8
    mov bx, offset wins
cw_loop:
    mov al, [bx]
    mov ah, 0
    mov si, ax
    mov dl, board[si]

    mov al, [bx+1]
    mov ah, 0
    mov si, ax
    cmp dl, board[si]
    jne cw_next

    mov al, [bx+2]
    mov ah, 0
    mov si, ax
    cmp dl, board[si]
    jne cw_next

    mov al, 1
    ret
cw_next:
    add bx, 3
    loop cw_loop
    mov al, 0
    ret
check_win endp

end 