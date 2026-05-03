STAK    SEGMENT PARA STACK 'STACK'
        DW 20 DUP(?)
STAK    ENDS

DATA    SEGMENT PARA 'DATA'
DIGITS  DB 1 DUP(?)
DATA    ENDS

CODE    SEGMENT PARA 'CODE'
        ASSUME CS:CODE, DS:DATA, SS:STAK
START:
        MOV AX, DATA
        MOV DS, AX

      
ENDLESS:
       
        DB 09Ah         
        DW 0000h        
        DW 2000h        
       
        DB 09Ah         
        DW 0002h        
        DW 2800h        
    
        JMP ENDLESS     

CODE    ENDS
        END START