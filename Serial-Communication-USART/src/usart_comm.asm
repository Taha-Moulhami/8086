STACKSEG SEGMENT PARA STACK
    DW 20 DUP(?)
STACKSEG ENDS

DATASEG SEGMENT PARA
LAST3   DB 3 DUP(0)
COUNT   DB 0
DATASEG ENDS

CODESEG SEGMENT PARA
ASSUME CS:CODESEG, DS:DATASEG, SS:STACKSEG

MAIN:
        MOV AX, DATASEG
        MOV DS, AX

        
        MOV DX, 015AH
        MOV AL, 01001101B
        OUT DX, AL

        MOV AL, 40H
        OUT DX, AL

        MOV AL, 01001101B
        OUT DX, AL

        MOV AL, 00010101B
        OUT DX, AL

        CALL CLEAR_BUF


READ_LOOP:
        CALL WAIT_RX
        CALL READ_CHAR

        CMP AL, '0'
        JE  OUTPUT_BUF

        CMP AL, 'A'
        JB  READ_LOOP
        CMP AL, 'Z'
        JA  READ_LOOP

        CALL STORE_CHAR
        JMP READ_LOOP


OUTPUT_BUF:
        MOV CL, COUNT
        CMP CL, 0
        JE  RESET_ONLY

        XOR CH, CH
        XOR SI, SI

SEND_LOOP:
        MOV BL, LAST3[SI]
        ADD BL, 3

WAIT_TX:
        MOV DX, 015AH
        IN  AL, DX
        AND AL, 01H
        JZ  WAIT_TX

        MOV DX, 0158H
        MOV AL, BL
        OUT DX, AL

        INC SI
        CMP SI, CX
        JL  SEND_LOOP

RESET_ONLY:
        CALL CLEAR_BUF
        JMP READ_LOOP


WAIT_RX PROC NEAR
        MOV DX, 015AH
RX_WAIT:
        IN  AL, DX
        AND AL, 02H
        JZ  RX_WAIT
        RET
WAIT_RX ENDP

READ_CHAR PROC NEAR
        MOV DX, 0158H
        IN  AL, DX
        SHR AL, 1
        RET
READ_CHAR ENDP

STORE_CHAR PROC NEAR
        PUSH BX
        PUSH SI

        MOV BL, COUNT
        CMP BL, 3
        JL  Ad_DIRECT

        
        MOV SI, 1
        MOV AL, LAST3[SI]
        MOV LAST3[0], AL

        MOV SI, 2
        MOV AL, LAST3[SI]
        MOV LAST3[1], AL

        MOV LAST3[2], AL        
        JMP STORE_DONE

Ad_DIRECT:
        MOV SI, BX
        MOV LAST3[SI], AL
        INC COUNT

STORE_DONE:
        POP SI
        POP BX
        RET
STORE_CHAR ENDP

CLEAR_BUF PROC NEAR
        MOV COUNT, 0
        MOV BYTE PTR LAST3[0], 0
        MOV BYTE PTR LAST3[1], 0
        MOV BYTE PTR LAST3[2], 0
        RET
CLEAR_BUF ENDP

CODESEG ENDS
END MAIN
