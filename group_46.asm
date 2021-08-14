INCLUDE Irvine32.inc

screen PROTO
time PROTO
stage PROTO
firstCard PROTO
cursor PROTO
move PROTO

main EQU start@0

.data
;顯示文字
startWord BYTE "Press enter to start !", 0
TimeWord BYTE "Time pass: ", 0
rewardWord BYTE "       Your reward now: ", 0
stageWord BYTE "Current stage: ", 0
cardWord BYTE "Your cards: ", 0
tabWord BYTE "    ", 0
upWord BYTE "Press up to play card", 0
downWord BYTE "Press down to discard", 0
LRWord BYTE "Press left & right to choose cards", 0
endWord BYTE "Congratulations ! Your final reward is : ", 0
leftFrame BYTE ">", 0
rightFrame BYTE "<", 0

;關卡隨機文字與手牌隨機文字
arrayEnemy BYTE 8 DUP(0)
arrayCard BYTE 4 DUP(0)

;各項資訊
timeNumber DWORD 0
rewardNumber DWORD 0
stageNumber DWORD 1
chooseNumber BYTE 0
leftNumber Dword 0
isClearBL BYTE 0
isFirstBL BYTE 0

.code
main PROC

    ;給予初始時間值
    call GetMseconds
    mov timeNumber, eax

    ;先叫螢幕一次
    INVOKE screen

    WaitStart:
        call readchar
        cmp  eax, 1C0Dh
        je timing
        jmp WaitStart

    timing:
        ;再次給予初始時間值
        call GetMseconds
        mov timeNumber, eax

    WaitControl:

        call readchar
        INVOKE move
        INVOKE screen

        ;如果時間到就結束
        cmp timeNumber, 0
        je  ending
    jmp WaitControl

    ;結束動作
    ending:
        mov  dh, 20
        mov  dl, 17
        call Gotoxy
        mov edx, OFFSET endWord
        call WriteString
        mov eax, rewardNumber
        call WriteDec
        call Crlf
        call Crlf
        call Crlf
        call readchar
        cmp  eax, 1C0Dh
        je getOut
        jmp ending
    getOut:
        call WaitMsg

main ENDP

;螢幕顯示
screen PROC

    push eax
    push edx

    ;清空螢幕
    call clrscr

    ;顯示各個文字
    mov edx, OFFSET startWord
    call WriteString
    call Crlf
    call Crlf

    mov edx, OFFSET TimeWord
    call WriteString
    INVOKE time

    mov edx, OFFSET rewardWord
    call WriteString
    mov eax, rewardNumber
    call WriteDec
    call Crlf
    call Crlf

    mov edx, OFFSET stageWord
    call WriteString
    mov eax, stageNumber
    call WriteDec
    call Crlf
    call Crlf
    mov edx, OFFSET tabWord
    call WriteString

    INVOKE stage

    call Crlf
    call Crlf
    mov edx, OFFSET cardWord
    call WriteString
    call Crlf
    call Crlf
    call Crlf
    mov edx, OFFSET tabWord
    call WriteString

    INVOKE firstCard
    INVOKE cursor

    call Crlf
    call Crlf
    call Crlf
    mov edx, OFFSET upWord
    call WriteString
    call Crlf
    mov edx, OFFSET downWord
    call WriteString
    call Crlf
    mov edx, OFFSET LRWord
    call WriteString
    call Crlf
    call Crlf

    pop eax
    pop edx

    ret

screen ENDP

;時間計算
time PROC

    push eax
    push bx
    push dx

    ;計算經過幾秒
    call GetMseconds
    sub eax, timeNumber
    mov dx, 0 ;避免餘數出錯
    mov bx, 1000
    div bx ;得到整數位秒數
    call WriteDec

    cmp eax, 60 ;到指定時間就結束
    jae ending

    pop eax
    pop bx
    pop dx
    ret

    ending:
        mov timeNumber, 0

    pop eax
    pop bx
    pop dx
    ret

time ENDP

;關卡資訊
stage PROC

    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov  eax, 12+(black*16)
    call SetTextColor

    mov esi, OFFSET arrayEnemy

    ;如果還沒通關就不要產生新的
    mov ecx, 8
    sub ecx, leftNumber
    cmp isClearBL, 1
    je pass

    ;產生亂數決定敵人
    call Randomize
    mov ecx, 9
    enemy:
        mov eax, 4
        call RandomRange
        ;根據亂數決定敵人種類
        cmp ecx, 1
        je ending
        cmp eax, 0
        je first
        cmp eax, 1
        je second
        cmp eax, 2
        je third
        cmp eax, 3
        je fourth

    first:
        mov bl, 'A'
        mov [esi], bl
        inc esi
        loop enemy
    second:
        mov bl, 'B'
        mov [esi], bl
        inc esi
        loop enemy
    third:
        mov bl, 'C'
        mov [esi], bl
        inc esi
        loop enemy
    fourth:
        mov bl, 'D'
        mov [esi], bl
        inc esi
        loop enemy

    ;輸出產生的敵人串
    ending:
        mov ecx, 8
        mov esi, OFFSET arrayEnemy
        outPut:
            mov al, [esi]
            call WriteChar
            mov edx, OFFSET tabWord
            call WriteString
            inc esi
        loop outPut

        mov isClearBL, 1

        mov  eax, 15+(black*16)
        call SetTextColor

        pop eax
        pop ebx
        pop ecx
        pop edx
        pop esi
        ret

    pass:
        mov al, [esi]
        call WriteChar
        mov edx, OFFSET tabWord
        call WriteString
        inc esi
    loop pass

    mov  eax, 15+(black*16)
    call SetTextColor

    pop eax
    pop ebx
    pop ecx
    pop edx
    pop esi
    ret

stage ENDP

;手牌
firstCard PROC

    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi, OFFSET arrayCard

    ;若不是初次則顯示已發好的
    mov ecx, 4
    cmp isFirstBL, 1
    je pass

    ;產生亂數決定牌
    call Randomize
    mov ecx, 5
    play:
        mov eax, 4
        call RandomRange
        ;根據亂數決定手牌種類
        cmp ecx, 1
        je ending
        cmp eax, 0
        je first
        cmp eax, 1
        je second
        cmp eax, 2
        je third
        cmp eax, 3
        je fourth

    first:
        mov bl, 'A'
        mov [esi], bl
        inc esi
        loop play
    second:
        mov bl, 'B'
        mov [esi], bl
        inc esi
        loop play
    third:
        mov bl, 'C'
        mov [esi], bl
        inc esi
        loop play
    fourth:
        mov bl, 'D'
        mov [esi], bl
        inc esi
        loop play

    ;輸出產生的手牌串
    ending:
        mov ecx, 4
        mov esi, OFFSET arrayEnemy
        outPut:
            mov al, [esi]
            call WriteChar
            mov edx, OFFSET tabWord
            call WriteString
            inc esi
        loop outPut
        mov isFirstBL, 1
        pop eax
        pop ebx
        pop ecx
        pop edx
        pop esi
        ret

    pass:
        mov al, [esi]
        call WriteChar
        mov edx, OFFSET tabWord
        call WriteString
        inc esi
    loop pass
    pop eax
    pop ebx
    pop ecx
    pop edx
    pop esi
    ret

firstCard ENDP

;選取位置
cursor PROC

    push edx
    push bx

    ;設定顏色
    mov  bl, chooseNumber
    mov  eax, 10+(black*16)
    call SetTextColor

    ;左框框
    mov  dh, 11
    mov  dl, 3
    add  dl, bl
    add  dl, bl
    add  dl, bl
    add  dl, bl
    add  dl, bl
    call Gotoxy
    mov  edx, OFFSET leftFrame
    call WriteString

    ;右框框
    mov  dh, 11
    mov  dl, 5
    add  dl, bl
    add  dl, bl
    add  dl, bl
    add  dl, bl
    add  dl, bl
    call Gotoxy
    mov  edx, OFFSET rightFrame
    call WriteString

    mov  eax, 15+(black*16)
    call SetTextColor

    pop edx
    pop bx
    ret

cursor ENDP


move PROC

    cmp  eax, 4800h
    je   Up
    cmp  eax, 5000h
    je   Down
    cmp  eax, 4B00h
    je   Left
    cmp  eax, 4D00h
    je   Right

    ;左右選擇
    Right:
        inc chooseNumber
        cmp chooseNumber, 3
        ja fix2
        ret
    Left:
        dec chooseNumber
        cmp chooseNumber, 3
        ja fix1
        ret
    fix1:
        mov chooseNumber, 0
        ret
    fix2:
        mov chooseNumber, 3
        ret

    Down:
        push eax
        push ebx
        push esi

        mov   esi, OFFSET arrayCard
        movzx ebx, chooseNumber
        add   esi, ebx
        ;換成新的手牌
        mov eax, 4
        call RandomRange
        cmp eax, 0
        je first
        cmp eax, 1
        je second
        cmp eax, 2
        je third
        cmp eax, 3
        je fourth

        first:
            mov bl, 'A'
            mov [esi], bl
            pop eax
            pop ebx
            pop esi
            ret
        second:
            mov bl, 'B'
            mov [esi], bl
            pop eax
            pop ebx
            pop esi
            ret
        third:
            mov bl, 'C'
            mov [esi], bl
            pop eax
            pop ebx
            pop esi
            ret
        fourth:
            mov bl, 'D'
            mov [esi], bl
            pop eax
            pop ebx
            pop esi
            ret

    Up:
        push esi
        push edi
        push eax
        push ebx
        push ecx
        push edx

        mov   esi, OFFSET arrayCard
        movzx edx, chooseNumber
        add   esi, edx
        mov   edi, OFFSET arrayEnemy
        mov   al, [edi]
        cmp   [esi], al
        jne   ending

        inc   rewardNumber
        ;手牌換新
        mov eax, 4
        call RandomRange
        cmp eax, 0
        je first1
        cmp eax, 1
        je second1
        cmp eax, 2
        je third1
        cmp eax, 3
        je fourth1

        first1:
            mov bl, 'A'
            mov [esi], bl
            jmp enemyTurn
        second1:
            mov bl, 'B'
            mov [esi], bl
            jmp enemyTurn
        third1:
            mov bl, 'C'
            mov [esi], bl
            jmp enemyTurn
        fourth1:
            mov bl, 'D'
            mov [esi], bl
            jmp enemyTurn

        ;敵人消滅
        enemyTurn:
            mov ecx, 7
            sub ecx, leftNumber
            mov	esi, OFFSET arrayEnemy
            inc	esi
            mov edi, OFFSET arrayEnemy
            cld
            rep	movsb
            mov	BYTE PTR [edi],0
            inc leftNumber
            cmp leftNumber, 8
            jne ending
            mov isClearBL, 0
            mov edx, stageNumber
            add rewardNumber, edx
            inc stageNumber
            mov leftNumber, 0

        ending:
            pop esi
            pop edi
            pop eax
            pop ebx
            pop ecx
            pop edx
            ret

move ENDP

END main
