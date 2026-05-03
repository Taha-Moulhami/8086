;  MEAN SQUARED ERROR (MSE) HESAPLAMA

STK SEGMENT PARA STACK 'STACK'
        DW 30 DUP(?) ; allocates 30 uninizialized words
STK ENDS

DSG SEGMENT PARA 'DATA' ;defining variables
        SUM     DD    0 ; defining double word SUM with value 0
        MSE     DW    0 ;defining word MSE with value 0
        VAR     DB    0fBH ;defining byte VAR with value 0
        D1      DW   10,  1, -3,  7,  0 ;defining an array of words D1 with initialized values
        D2      DW    5,  5,  8, -6,  9 ;defining an array of words D2 with initialized values
        N       DW    5 ;defining word N with value 5
DSG ENDS

CSG SEGMENT PARA 'CODE'
        ASSUME CS:CSG, DS:DSG, SS:STK   ; associates the registers with data segments

START PROC

        MOV   AX, DSG ; mov data segment to ax
        MOV   DS, AX ; copy ax to ds
        MOV   ax, stk ; copy stack base to ax
        MOV   SS, AX ; copying stack from ax to stack segment
        MOV SP, 60 ; making stack pointer points to stack top
        XOR   AX, AX ;reseting ax
        MOV   word ptr [SUM],   AX ; clearing lower 16 of sum
        MOV   word ptr [SUM+2], dX   ; clearing higher 16 of sum
        LEA   SI, D1 ; loading the adress of d1 into source index
        LEA   DI, D2 ; loading the adress  of d2 into destination index
        MOV   CX, [N] ; setting the nb of iterations of the loop to cx

    CALC_LOOP:
        MOV   AX, [SI] ;copying the value of the current element from arr to ax
        MOV   BX, [DI] ;copying the value of the current element from arr to bx

        SUB   AX, BX  ;substracting ax from bx and saving it ax

        IMUL  AX  ;squaring ax

        ADD   word ptr [SUM],   AX ;addingf the val of ax to the sum lower 16 bits
        ADC   word ptr [SUM+2], DX ;addingf the val of ax to the sum higher 16 bits

        ADD   SI, 2  ;adding 2 to move to the next word
        ADD   DI, 2 ;adding 2 to move to the next word
        LOOP  CALC_LOOP ; calling the loop and decrement loop counter

        MOV   DX, word ptr [SUM+2]    ;copying value of upper sum to dx
        MOV   AX, word ptr [SUM] ;copying value of lower sum to ax
        MOV   BX, [N] ; getting n value again and assignig it to bx
        DIV   BX ; ax=ax/bx
        MOV   MSE, AX ; mov val of ax to mse result

        ret
START ENDP
CSG ENDS

END START
