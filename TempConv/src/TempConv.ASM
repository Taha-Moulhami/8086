data segment
        CEL      DW   0, 11, -273, 72, 100, 27, -33 ; declaring celsius word array
        FEH      DW   7 DUP(?) ; declaring feh arr of 7 un inizialized word
        SUM     dw 0 ;declarinf sum word
        N   dw 7 ; declaring word for
        ort dw 0 ; declaring word for avg value
        Byk dw 0 ; declaring word for count of numbers bigger than avg
        ; 32, 51, -459 , 161, 212 , 80, -27
        ; 20, 33, fe35 ,a1 , D4 ,50, FFE5
data ends


code segment
    assume cs:code, ds:data
start:
        MOV AX, DATA ;get the segment address
        MOV DS, AX ;set DS to DATA segment

        LEA   SI, CEL ; loading the adress of cel array into source index
        LEA   DI, FEH; loading the adress  of feh array into destination index
        MOV   CX, [N]; setting loop counter to 7
    loop_cev:
        mov ax,[SI] ;calling the I'th element of cel to ax
        mov bx, 18 ;setting bx to 18
        imul bx ; multiplying bx with ax
        mov bx ,10 ; setting bx to 10
        idiv bx ;dividing by bx
        mov bx,32 ;setting bx to 32
        add ax,bx ; summing ax and bx which is the feh value
        add [sum], ax ;adding ax to lab
        mov [DI] , ax ; sending ax to the dest index
        add SI, 2 ; iterating to the next element of si
        add DI, 2 ; iterating to the next element of di
    LOOP  loop_cev
        mov ax, [sum] ; calling sum by value
        mov bx, [N] ;setting bx to 7
        mov dx,0 ;resetting dx
        div bx ; dividing ax by dx to get the avg
        mov [ort], ax ; copying avg to ax
        MOV   CX, [N]; setting loop counter
        LEA   SI, FEH ; ; loading the adress of cel array into source index
    loop_karis:
        mov ax,[SI] ;calling the i'th element of feh array
        cmp ax , [ort] ;comparing each val with the avg
        Jl smaller ;jump to smaller if cmp returns neg
        inc [byk] ; inc the byk counter
        smaller:
        add SI, 2 ;iterating ti the next element
    LOOP loop_karis
    mov ah, 4Ch     ; terminate program
    int 21h         ; call DOS interrupt to exit cleanly



    ret
code ends
end start
























