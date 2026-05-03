STACK SEGMENT PARA 'STACK'
        DW 30 DUP(?)    
STACK ENDS

PORTA   EQU 80h   ; Port A 
PORTB   EQU 82h   ; Port B 
PORTC   EQU 84h   ; Port C 
CTL8255 EQU 86h   ; Control register for 8255

; 7-segment display bit patterns for digits 0-7
ZERO    EQU 0C0h
ONE     EQU 0F9h
TWO     EQU 0A4h
THREE   EQU 0B0h
FOUR    EQU 099h
FIVE    EQU 092h
SIX     EQU 082h
SEVEN   EQU 0F8h

CODE SEGMENT PARA 'CODE'
        ASSUME CS:CODE, SS:STACK  

START:
    ; Set the control word for 8255A
    ; Mode setup: Port A and C (upper) are outputs, Port B is input
    MOV AL, 082h      
    OUT CTL8255, AL

LOOP_START:
    IN  AL, PORTB         
    NOT AL                

    ; Check each button by comparing the input byte
    CMP AL, 00000001b     
    JE  BUTTON_0
    CMP AL, 00000010b     
    JE  BUTTON_1
    CMP AL, 00000100b     
    JE  BUTTON_2
    CMP AL, 00001000b     
    JE  BUTTON_3
    CMP AL, 00010000b    
    JE  BUTTON_4
    CMP AL, 00100000b     
    JE  BUTTON_5
    CMP AL, 01000000b     
    JE  BUTTON_6
    CMP AL, 10000000b     
    JE  BUTTON_7
    JMP LOOP_START        

BUTTON_0:
    MOV AL, ZERO
    JMP DISPLAY
BUTTON_1:
    MOV AL, ONE
    JMP DISPLAY
BUTTON_2:
    MOV AL, TWO
    JMP DISPLAY
BUTTON_3:
    MOV AL, THREE
    JMP DISPLAY
BUTTON_4:
    MOV AL, FOUR
    JMP DISPLAY
BUTTON_5:
    MOV AL, FIVE
    JMP DISPLAY
BUTTON_6:
    MOV AL, SIX
    JMP DISPLAY
BUTTON_7:
    MOV AL, SEVEN
    JMP DISPLAY

DISPLAY:
    OUT PORTA, AL         
    JMP LOOP_START        

CODE ENDS
END START
