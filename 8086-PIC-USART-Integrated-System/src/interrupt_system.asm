MYSTACK SEGMENT PARA STACK 'STACK'
    DW 256 DUP(0)
MYSTACK ENDS

MYDATA  SEGMENT PARA PUBLIC 'DATA'
    BUFFER      DB 5 DUP(0)
    COUNT_ADC   DB 0
    COUNT_TX    DB 0
MYDATA  ENDS

MYCODE  SEGMENT PARA PUBLIC 'CODE'
    ASSUME CS:MYCODE, DS:MYDATA, SS:MYSTACK

PIC_CMD     EQU 00H
PIC_DAT     EQU 02H

USART_DATA  EQU 10H
USART_CMD   EQU 12H

ADC_DATA    EQU 20H
ADC_CTRL    EQU 22H

EOI         EQU 20H

START_ADC_CONV PROC NEAR
    push ax
    push dx

    mov dx, ADC_CTRL
    mov al, 00h
    out dx, al
    nop
    out dx, al

    pop dx
    pop ax
    ret
START_ADC_CONV ENDP

ADC_ISR PROC FAR
    push ax
    push bx
    push cx
    push dx
    push si
    push ds

    mov ax, MYDATA
    mov ds, ax

    mov dx, ADC_DATA
    in  al, dx

    lea si, BUFFER
    mov bl, COUNT_ADC
    xor bh, bh
    mov [si+bx], al

    inc COUNT_ADC
    cmp COUNT_ADC, 5
    jne ADC_CONTINUE_SAMPLING

    mov COUNT_ADC, 0
    mov COUNT_TX, 0

    mov dx, PIC_DAT
    mov al, 0FDh
    out dx, al

    lea si, BUFFER
    mov al, [si]

    mov dx, USART_DATA
    out dx, al

    mov COUNT_TX, 1

    jmp ADC_ISR_EOI

ADC_CONTINUE_SAMPLING:
    call START_ADC_CONV

ADC_ISR_EOI:
    mov dx, PIC_CMD
    mov al, EOI
    out dx, al

    pop ds
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    iret
ADC_ISR ENDP

SERIAL_ISR PROC FAR
    push ax
    push bx
    push cx
    push dx
    push si
    push ds

    mov ax, MYDATA
    mov ds, ax

    cmp COUNT_TX, 5
    jae SERIAL_DONE

    lea si, BUFFER
    mov bl, COUNT_TX
    xor bh, bh
    mov al, [si+bx]

    mov dx, USART_DATA
    out dx, al

    inc COUNT_TX
    jmp SERIAL_EOI

SERIAL_DONE:
    mov COUNT_TX, 0

    mov dx, PIC_DAT
    mov al, 0FBh
    out dx, al

    call START_ADC_CONV

SERIAL_EOI:
    mov dx, PIC_CMD
    mov al, EOI
    out dx, al

    pop ds
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    iret
SERIAL_ISR ENDP

START:
    mov ax, MYDATA
    mov ds, ax

    cli

    xor ax, ax
    mov es, ax

    mov di, 51h*4
    mov word ptr es:[di], offset SERIAL_ISR
    mov word ptr es:[di+2], cs

    mov di, 52h*4
    mov word ptr es:[di], offset ADC_ISR
    mov word ptr es:[di+2], cs

    mov dx, PIC_CMD
    mov al, 13h
    out dx, al

    mov dx, PIC_DAT
    mov al, 50h
    out dx, al

    mov al, 03h
    out dx, al

    mov al, 0FBh
    out dx, al

    mov dx, USART_CMD
    mov al, 40h
    out dx, al

    mov al, 4Dh
    out dx, al

    mov al, 25h
    out dx, al

    call START_ADC_CONV

    sti

MAIN_LOOP:
    jmp MAIN_LOOP

MYCODE ENDS
END START
