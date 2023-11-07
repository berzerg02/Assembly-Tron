Code Segment
assume CS:Code, DS:Data, SS:Stack

    org 100h
    jmp Start

menuText db 'Welcome to MY tron game', 0Dh, 0Ah
         db 'We consider Player 1 the player who plays with "w, a, s, d"', 0Dh, 0Ah
         db 'And obviously player 2 is the player who plays with "i, j, k, l"', 0Dh, 0Ah
         db '            ', 0dh, 0ah
         db 'Press 1 to Start Game', 0Dh, 0Ah
         db 'Esc. Exit', 0Dh, 0Ah
         db 'Enter your choice: $'

restartText db '            ', 0dh, 0ah
            db 'Press 1 to Restart the game', 0Dh, 0Ah
            db 'Esc. Exit', 0Dh, 0Ah
            db 'Enter your choice: $'
Start:
    mov ax, Code
    mov DS, AX

    mov ah, 00h
    mov al, 03h
    int 10h
    
    mov player1wins, 48
    mov player2wins, 48

    mov ah, 09h  
    mov dx, offset menuText
    int 21h       
    mov ah, 00h   
    int 16h       
    cmp al, '1'  
    je startGame
    cmp al, 27  
    je Start_to_end
    jmp Start

startGame:
    ; Init
    mov player_x, 60
    mov player_y, 100

    mov player2_x, 260
    mov player2_y, 100

    mov dl, "d"
    mov player_dir, dl
    mov dl, "j"
    mov player2_dir, dl

    mov ax, 13h
    int 10h

    mov ax, 0a000h
    mov es, ax

    ; Draw borders 
;TOP
    mov ah, 0
    mov al, 13h
    int 10h

    mov cx, 0
    mov dx, 0
    back:
    mov ah, 0Ch
    mov al, 2
    int 10h
    inc cx
    cmp cx, 320
    jnz back

;Left
    mov cx, 0
    mov dx, 0
    backl:
    mov ah, 0Ch
    mov al, 2
    int 10h
    inc dx
    cmp dx, 200
    jnz backl

; Right
    mov cx, 319
    mov dx, 0
    backr:
    mov ah, 0Ch
    mov al, 2
    int 10h
    inc dx
    cmp dx, 200
    jnz backr
    jmp bottom

start_to_end:
    jmp end_island

; Bottom
    bottom:
    mov cx, 0
    mov dx, 199
    backb:
    mov ah, 0Ch
    mov al, 2
    int 10h
    inc cx
    cmp cx, 320
    jnz backb


Draw:
    xor ah, ah
    mov ax, player_y 
    mov bx, 320
    mul bx
    add ax, player_x
    jnc Pixel
    inc ah
Pixel:
    mov di, ax
    mov al, 64
    mov es:[di], al

Draw2:
    xor ah, ah
    mov ax, player2_y 
    mov bx, 320
    mul bx
    add ax, player2_x
    jnc Pixel2
    inc ah

Pixel2:
    mov di, ax
    mov al, 128
    mov es:[di], al

thread:
    xor cx, cx
    mov cx, 40000
    delayLoopMain:
    dec cx
    jnz delayLoopMain

    mov dl, player_dir
    mov player_dir_helper, dl

    mov ah, 01h
    int 16h
    jz persisted

    mov ah, 00h
    int 16h
    jmp playercheck



playercheck:
    cmp al, 27
    jz End_help_island

    cmp al, 'a'
    je player1down

    cmp al, 'w'
    je player1down
    
    cmp al, 's'
    je player1down
    
    cmp al, 'd'
    je player1down

    cmp al, 'k'
    je player2down

    cmp al, 'i'
    je player2down
    
    cmp al, 'j'
    je player2down
    
    cmp al, 'l'
    je player2down

    jmp persisted

player1down:
    mov player_dir, al
    jmp persisted


player2down:
    mov player2_dir, al

persisted:
    cmp player_dir, "a"
    jz Left_island

    cmp player_dir, "d"
    jz Right

    cmp player_dir, "s"
    jz Down_help_island

    cmp player_dir, "w"
    jz Up_help_island

    cmp player2_dir, "i"
    jz Up_p2_island

    cmp player2_dir, "j"
    jz Left_p2_island

    cmp player2_dir, "k"
    jz Down_island_p2

    cmp player2_dir, "l"
    jz Right_p2_island

    jmp thread

startGame_island:
    jmp startGame
End_help_island:
    jmp End_island
Up_help_island:
    jmp Up_island
Down_help_island:
    jmp Down_island

Draw_island:
    jmp Draw
Left_island:
    jmp Left

Right:
    inc player_x
    cmp player_x, 319
    jz End_island  
    jmp CheckColor

CheckColor:
    xor ah, ah
    mov ax, player_y
    mov bx, 320
    mul bx
    add ax, player_x
    mov di, ax
    mov al, es:[di]
    cmp al, 128
    je Tie_helper
    cmp al, 64
    je Player2Win
    jmp NotOnColor

startGame_island2:
    jmp startGame_island

Up_p2_island:
    jmp Up_p2
Up_island:
    jmp Up
Left_p2_island:
    jmp Left_p2

Down_island_p2:
    jmp Down_p2
Right_p2_island:
    jmp Right_p2

Player2Win:
    mov ah, 00h     ;00h ha teljes képernyőt akarok törlöni
    mov al, 03h      ;03h ha teljes képernyőt akarok törölni
    int 10h

    mov ah, 09h
    mov dx, offset P2winmsg
    int 21h

    mov ah, 09h
    mov dx, offset Space
    int 21h

    call Player1WinsMsg
    mov dl, player1wins
    mov ah, 02h
    int 21h

    mov ah, 09h
    mov dx, offset Space
    int 21h

    call Player2WinsMsg
    mov dl, player2wins
    mov ah, 02h
    int 21h

    mov ah, 09h
    mov dx, offset restartText
    int 21h
    
    mov ah, 00h   
    int 16h       
    cmp al, '1'   
    je startGame_island2
    cmp al, 27    
    je End_island

    jmp Player2Win


End_island:
    jmp End_island2
Down_island:
    jmp Down
StartGame_island4:
    jmp StartGame_island3

Tie_helper:
    jmp Tie2

Player1Win:
    mov ah, 00h
    mov al, 03h
    int 10h

    mov ah, 09h
    mov dx, offset P1winmsg
    int 21h

    mov ah, 09h
    mov dx, offset Space
    int 21h

    call Player1WinsMsg
    mov dl, player1wins
    mov ah, 02h
    int 21h

    mov ah, 09h
    mov dx, offset Space
    int 21h

    call Player2WinsMsg
    mov dl, player2wins
    mov ah, 02h
    int 21h

    mov ah, 09h
    mov dx, offset restartText
    int 21h


    mov ah, 00h   
    int 16h       
    cmp al, '1'   
    je startGame_island4
    cmp al, 27    
    je End_island2

    jmp Player1Win

NotOnColor:
    cmp player2_dir, "i"
    jz Up_p2
    cmp player2_dir, "j"
    jz Left_p2
    cmp player2_dir, "l"
    jz Right_p2
    cmp player2_dir, "k"
    jz Down_p2
    jmp Draw 

Player1_win_helper:
    jmp Player1Win
    
Left:
    dec player_x
    jz End_island
    call CheckColor
    jmp Program_End


NotOnColor2:
    jmp Draw_island

Up:
    dec player_y
    jz End_island2
    jmp CheckColor

Down:
    inc player_y
    cmp player_y, 199
    jz End_island2
    jmp CheckColor

End_island2:
    jmp Program_End


CheckColor_p2:
    xor ah, ah
    mov ax, player2_y
    mov bx, 320
    mul bx
    add ax, player2_x
    mov di, ax
    mov al, es:[di]
    cmp al, 128
    je Player1_win_helper
    cmp al, 64
    je Tie1

    jmp NotOnColor2

Player1_win_helper2:
    jmp Player1_win_helper


Up_p2:
    dec player2_y
    jz End_island2
    jmp CheckColor_p2

Right_p2:
    inc player2_x
    cmp player2_x, 319
    jz End_island2
    jmp CheckColor_p2

Player2Win_island:
    jmp Player2Win

Left_p2:
    dec player2_x
    jz End_island2
    jmp CheckColor_p2

Down_p2:
    inc player2_y
    cmp player2_y, 199
    jz End_island2
    jmp CheckColor_p2

StartGame_island3:
    jmp startGame_island2

Tie1:
    xor ah, ah
    xor dh, dh
    mov ax, player_y
    add ax, player_x
    sub ax, 1
    mov dx, player2_y
    add dx, player2_x

    cmp ax, dx
    jz TieMsgFunc
    inc player1wins
    jmp Player1_win_helper2

Tie2:
    xor ah, ah
    xor dh, dh
    mov ax, player_y
    add ax, player_x
    sub ax, 1
    mov dx, player2_y
    add dx, player2_x

    cmp ax, dx
    jz TieMsgFunc
    inc player2wins
    jmp Player2Win_island


TieMsgFunc:

    mov ah, 00h
    mov al, 03h
    int 10h

    mov ah, 09h
    mov dx, offset TieMsg
    int 21h

    call Player1WinsMsg
    mov dl, player1wins
    mov ah, 02h
    int 21h

    mov ah, 09h
    mov dx, offset Space
    int 21h

    call Player2WinsMsg
    mov dl, player2wins
    mov ah, 02h
    int 21h

    mov ah, 09h
    mov dx, offset restartText
    int 21h
    mov ah, 00h   
    int 16h       
    cmp al, '1'
    je StartGame_island3
    cmp al, 27    
    je Program_End

    jmp TieMsgFunc

Player1WinsMsg:
    mov ah, 09h
    mov dx, offset Winmsg
    int 21h
    ret

Player2WinsMsg:
    mov ah, 09h
    mov dx, offset Winmsg2
    int 21h
    ret

Program_End:

    mov ax, 03h
    int 10h

    mov ax, 4c00h
    int 21h

P1winmsg db "Player 1 won this round$"
P2winmsg db "Player 2 won this round$"
TieMsg db "It was a tie" , 0Dh, 0Ah
       db "$"
Winmsg: db "Player 1 win(s): $"
Winmsg2: db "Player 2 win(s): $"
Space:  db "", 0dh, 0ah
        db "$"


Code Ends
Data Segment
    player_dir_helper db 0
    player2_dir_helper db 0
    player_dir db "d"
    player2_dir db "i"
    player_x dw 50
    player_y dw 50
    player2_x dw 250
    player2_y dw 150
    player1wins db 0
    player2wins db 0
    
Data Ends

Stack Segment

Stack Ends

End Start
