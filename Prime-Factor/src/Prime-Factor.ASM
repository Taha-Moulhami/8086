STK SEGMENT PARA STACK 'STACK'
    DW 64 DUP(?)
STK ENDS

DSG SEGMENT PARA 'DATA'
    CR EQU 13
    LF EQU 10

    entry      DB 'Enter a number: ',0
    display_msg DB CR, LF, 'Numbers entered: ',0
    msg_n        DB CR, LF, 'N = ',0
    msg_prime    DB '  IS_PRIME_FLAG = ',0
    msg_factors  DB '  FACTORS: ',0
    msg_none     DB '(none)',0
    msg_maxf     DB '  MAX_FACTOR = ',0
    nl           DB CR, LF, 0

    data structure
    NUMBER_LIST  DW 18 DUP(0)     ; 9 numbers (2 words per number)
    NUMBER_COUNT DW 9             ; Total count of numbers

    FACTORS     DW 64 DUP(0)      ; Storage for factors
    FACT_COUNT  DW 0              ; Number of factors found
    IS_PRIME_FLAG DB 0            ; Flag for primality (0/1)
    MAX_FACTOR  DW 0              ; Max prime factor or N itself if prime
DSG ENDS

CSG SEGMENT PARA 'CODE'
ASSUME CS:CSG, DS:DSG, SS:STK

; ========================= READ_ARRAY MACRO   =========================
READ_ARRAY MACRO array, count
    LOCAL READ_LOOP
    PUSH CX
    PUSH DI
    MOV CX, count
    LEA DI, array
READ_LOOP:
    MOV AX, OFFSET entry
    CALL PUT_STR
    CALL GETN32                ; Read 32-bit number -> DX:AX (high:low)
    MOV [DI], AX               ; Store low word
    MOV [DI+2], DX             ; Store high word
    ADD DI, 4                  ; Move to next 32-bit slot
    DEC CX
    JNZ READ_LOOP
    POP DI
    POP CX
ENDM

; ========================= PRINT_ARRAY MACRO   =========================
PRINT_ARRAY MACRO base, count
    LOCAL PRINT_LOOP, PRINT_DONE
    PUSH SI
    PUSH CX
    PUSH AX
    LEA SI, base               ; Load array address
    MOV CX, count              ; Load element count
    CMP CX, 0
    JE PRINT_DONE              ; Skip if empty
PRINT_LOOP:
    MOV AX, [SI]               ; Load factor
    CALL PUTN                  ; Print factor
    MOV AL, ' '                ; Print separator
    CALL PUTC
    ADD SI, 2                  ; Next word
    DEC CX
    JNZ PRINT_LOOP
PRINT_DONE:
    POP AX
    POP CX
    POP SI
ENDM

main PROC FAR
    PUSH DS
    XOR AX, AX
    PUSH AX
    MOV AX, DSG
    MOV DS, AX

    ; ---- READ 9 NUMBERS USING MACRO  ----
    READ_ARRAY NUMBER_LIST, NUMBER_COUNT

    ; ---- ECHO INPUT ----
    MOV AX, OFFSET display_msg
    CALL PUT_STR
    MOV CX, 9
    LEA SI, NUMBER_LIST
M_PRINT_LOOP:
    MOV AX, [SI]              ; Load low word
    MOV DX, [SI+2]            ; Load high word
    CALL PUTN32               ; Print 32-bit number
    MOV AL, ' '               ; Space separator
    CALL PUTC
    ADD SI, 4                 ; Next 32-bit number
    DEC CX
    JNZ M_PRINT_LOOP

    ; ---- PROCESS EACH NUMBER ----
    MOV CX, 9
    LEA SI, NUMBER_LIST
M_EACH:
    ; Display current number
    MOV AX, OFFSET msg_n
    CALL PUT_STR
    MOV AX, [SI]              ; N low
    MOV DX, [SI+2]            ; N high
    CALL PUTN32

    ; ---- IS_PRIME: REGISTER PARAMETER PASSING ----
    MOV AX, [SI]              ; Low word in AX
    MOV DX, [SI+2]            ; High word in DX
    CALL IS_PRIME             ; Result in AL (Register parameter passing)
    MOV IS_PRIME_FLAG, AL

    ; Display prime flag
    MOV AX, OFFSET msg_prime
    CALL PUT_STR
    MOV AL, IS_PRIME_FLAG
    CBW
    CALL PUTN

    ; Branch based on primality
    MOV AX, [SI]
    MOV DX, [SI+2]
    CMP IS_PRIME_FLAG, 1
    JE  M_PRIME_CASE

    ; ---- FACTORIZE: SEGMENT PARAMETER PASSING ----
    ; Uses global variables in DSG segment (NUMBER_LIST, FACTORS, FACT_COUNT)
    CALL FACTORIZE

    ; Display factors
    MOV AX, OFFSET msg_factors
    CALL PUT_STR
    MOV AX, FACT_COUNT
    OR  AX, AX
    JNZ M_HAVE_FACT
    MOV AX, OFFSET msg_none
    CALL PUT_STR
    JMP M_DO_MAX

M_HAVE_FACT:
    PRINT_ARRAY FACTORS, FACT_COUNT

M_DO_MAX:
    ; ---- MAX_FACTOR: SEGMENT + REGISTER PARAMETER PASSING ----
    ; Register AX = pointer to FACTORS array
    ; Stack parameters: FACT_COUNT (value), &MAX_FACTOR (pointer)
    MOV WORD PTR MAX_FACTOR, 0
    LEA AX, FACTORS            ; Register parameter: array pointer
    MOV BX, FACT_COUNT         ; Prepare stack parameter
    PUSH BX                    ; [BP+6] = FACT_COUNT (by value)
    MOV BX, OFFSET MAX_FACTOR
    PUSH BX                    ; [BP+4] = &MAX_FACTOR (by pointer)
    CALL MAX_FACTOR_PROC       ; Uses both register and segment parameters
    ; Stack cleaned by RET 4

    ; Display max factor
    MOV AX, OFFSET msg_maxf
    CALL PUT_STR
    MOV AX, MAX_FACTOR
    CALL PUTN
    JMP M_NEXT

M_PRIME_CASE:
    ; Prime number: no factors, MAX_FACTOR = N
    MOV WORD PTR FACT_COUNT, 0
    MOV AX, [SI]
    MOV MAX_FACTOR, AX

    MOV AX, OFFSET msg_factors
    CALL PUT_STR
    MOV AX, OFFSET msg_none
    CALL PUT_STR

    MOV AX, OFFSET msg_maxf
    CALL PUT_STR
    MOV AX, MAX_FACTOR
    CALL PUTN

M_NEXT:
    MOV AX, OFFSET nl
    CALL PUT_STR
    ADD SI, 4                  ; Next 32-bit number
    DEC CX
    JZ  M_DONE
    JMP M_EACH

M_DONE:
    MOV AH, 4Ch
    INT 21h
main ENDP

; ========================= I/O PROCEDURES =========================
GETC PROC NEAR
    MOV AH,1
    INT 21h
    RET
GETC ENDP

PUTC PROC NEAR
    PUSH AX
    PUSH DX
    MOV DL,AL
    MOV AH,2
    INT 21h
    POP DX
    POP AX
    RET
PUTC ENDP

; AX = string offset (null-terminated)
PUT_STR PROC NEAR
    PUSH BX
    MOV BX,AX
PS_LOOP:
    MOV AL,[BX]
    OR  AL,AL
    JZ  PS_DONE
    CALL PUTC
    INC BX
    JMP PS_LOOP
PS_DONE:
    POP BX
    RET
PUT_STR ENDP

; Print unsigned 16-bit in AX
PUTN PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV CX,0
    CMP AX,0
    JNE PN_CONV
    MOV AL,'0'
    CALL PUTC
    JMP PN_OUT
PN_CONV:
    MOV BX,10
PN_DIV:
    XOR DX,DX
    DIV BX
    PUSH DX
    INC CX
    TEST AX,AX
    JNZ PN_DIV
PN_PRINT:
    POP DX
    ADD DL,'0'
    MOV AH,2
    INT 21h
    DEC CX
    JNZ PN_PRINT
PN_OUT:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PUTN ENDP

; ========================= 32-BIT I/O PROCEDURES =========================
; GETN32: Read 32-bit number -> DX:AX (high:low)
GETN32 PROC NEAR
    PUSH BX
    PUSH CX
    PUSH SI
    XOR BX,BX                  ; Low word accumulator
    XOR CX,CX                  ; High word accumulator
    MOV SI,1                   ; Sign flag
G32_SKIP_WS:
    CALL GETC
    CMP AL,' '
    JE  G32_SKIP_WS
    CMP AL,LF
    JE  G32_SKIP_WS
    CMP AL,'-'
    JNE G32_CHK_PLUS
    MOV SI,-1                  ; Negative number
    JMP G32_READ_FIRST
G32_CHK_PLUS:
    CMP AL,'+'
    JNE G32_CHKDIG
G32_READ_FIRST:
    CALL GETC
G32_CHKDIG:
    CMP AL,CR
    JE  G32_FIN_EMPTY
    CMP AL,'0'
    JB  G32_READ_FIRST
    CMP AL,'9'
    JA  G32_READ_FIRST
G32_DIGIT:
    SUB AL,'0'
    MOV AH,0
    PUSH AX
    ; Multiply current value by 10: (CX:BX) * 10
    MOV AX,BX
    MOV DX,CX
    SHL AX,1
    RCL DX,1                   ; *2
    PUSH DX
    PUSH AX
    SHL AX,1
    RCL DX,1                   ; *4
    SHL AX,1
    RCL DX,1                   ; *8
    POP BX
    POP SI
    ADD AX,BX
    ADC DX,SI                  ; *8 + *2 = *10
    MOV BX,AX
    MOV CX,DX
    POP AX
    ADD BX,AX                  ; Add new digit
    ADC CX,0
G32_NEXT:
    CALL GETC
    CMP AL,CR
    JE  G32_FINISH
    CMP AL,'0'
    JB  G32_NEXT
    CMP AL,'9'
    JA  G32_NEXT
    JMP G32_DIGIT
G32_FIN_EMPTY:
    ; Keep value 0
G32_FINISH:
    CMP SI,-1
    JNE G32_OUT
    NOT BX
    NOT CX
    ADD BX,1
    ADC CX,0                   ; Two's complement for negative
G32_OUT:
    MOV AX,BX
    MOV DX,CX
    POP SI
    POP CX
    POP BX
    RET
GETN32 ENDP

; PUTN32: Print 32-bit number from DX:AX
PUTN32 PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    TEST DX,DX
    JNS  PN32_POS
    ; Negative number
    PUSH AX
    PUSH DX
    MOV AL,'-'
    CALL PUTC
    POP DX
    POP AX
    NOT AX
    NOT DX
    ADD AX,1
    ADC DX,0                   ; Two's complement
PN32_POS:
    MOV CX,DX
    OR  CX,AX
    JNZ PN32_CONV
    MOV AL,'0'
    CALL PUTC
    JMP PN32_DONE
PN32_CONV:
    MOV SI,AX                  ; Low word
    MOV DI,DX                  ; High word
    XOR CX,CX                  ; Digit counter
    MOV BX,10
PN32_DIV:
    XOR DX,DX
    MOV AX,DI
    DIV BX
    MOV DI,AX
    MOV AX,SI
    DIV BX
    MOV SI,AX
    PUSH DX                    ; Remainder (digit)
    INC CX
    MOV AX,DI
    OR  AX,SI
    JNZ PN32_DIV
PN32_PRINT:
    POP DX
    ADD DL,'0'
    MOV AH,2
    INT 21h
    DEC CX
    JNZ PN32_PRINT
PN32_DONE:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PUTN32 ENDP

; ========================= IS_PRIME PROCEDURE =========================
; Register parameter passing: DX:AX = 32-bit number, AL returns result (0/1)
IS_PRIME PROC NEAR
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    MOV DI,DX                  ; N high
    MOV SI,AX                  ; N low
    ; Check N < 2
    CMP DI,0
    JNE IP_GE2
    CMP SI,2
    JB  IP_NOT                 ; N < 2 → not prime
    JE  IP_YES                 ; N = 2 → prime
IP_GE2:
    ; Check even
    TEST SI,1
    JNZ IP_ODDS
    CMP DI,0
    JNE IP_NOT
    CMP SI,2
    JE  IP_YES                 ; N = 2 → prime
    JMP IP_NOT                 ; Even > 2 → not prime
IP_ODDS:
    MOV BX,3                   ; Start with divisor 3
IP_LOOP:
    ; Check if d² > N
    MOV AX,BX
    CALL SQR16                 ; DX:AX = d²
    CMP DX,DI
    JA  IP_YES                 ; d² > N → prime
    JB  IP_CHECK
    CMP AX,SI
    JA  IP_YES                 ; d² > N → prime
IP_CHECK:
    CALL REM32_16              ; DX = N % d
    TEST DX,DX
    JZ  IP_NOT                 ; Divisible → not prime
    ADD BX,2                   ; Next odd divisor
    JMP IP_LOOP
IP_YES:
    MOV AL,1
    JMP IP_OUT
IP_NOT:
    MOV AL,0
IP_OUT:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    RET
IS_PRIME ENDP

; ========================= FACTORIZE PROCEDURE =========================
; Segment parameter passing: Uses NUMBER_LIST, FACTORS, FACT_COUNT from DSG
FACTORIZE PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    MOV DI,DX                  ; N high
    MOV SI,AX                  ; N low
    MOV WORD PTR FACT_COUNT,0  ; Reset factor count
    ; Check N < 2
    CMP DI,0
    JNE F_CHECK2
    CMP SI,2
    JB  F_DONE                 ; N < 2 → no factors
F_CHECK2:
    ; Extract factors of 2
F_EVEN:
    TEST SI,1
    JNZ F_ODD_START
    CALL SHR32_1               ; N /= 2
    MOV AX,2
    CALL PUSH_FACTOR           ; Store factor 2
    JMP F_EVEN
F_ODD_START:
    MOV BX,3                   ; Start with odd divisor 3
F_LOOP:
    ; Check if d² > remaining N
    MOV AX,BX
    CALL SQR16
    CMP DX,DI
    JA  F_FINISH_REST
    JB  F_TRYD
    CMP AX,SI
    JA  F_FINISH_REST
F_TRYD:
    CALL REM32_16              ; Check divisibility
    TEST DX,DX
    JNZ F_NEXTD
    CALL DIV32_16              ; N /= d
    MOV AX,BX
    CALL PUSH_FACTOR           ; Store factor
    JMP F_LOOP
F_NEXTD:
    ADD BX,2                   ; Next odd divisor
    JMP F_LOOP
F_FINISH_REST:
    ; Store remaining prime factor (if > 1)
    MOV AX,DI
    OR  AX,SI
    JZ  F_DONE                 ; N became 0
    CMP DI,0
    JNE F_PUSH_LOW
    MOV AX,SI
    CALL PUSH_FACTOR
    JMP F_DONE
F_PUSH_LOW:
    MOV AX,SI
    CALL PUSH_FACTOR
F_DONE:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
FACTORIZE ENDP

; ========================= MAX_FACTOR_PROC PROCEDURE =========================
; Mixed parameter passing:
; - Register AX = FACTORS array pointer
; - Stack: [BP+6] = FACT_COUNT, [BP+4] = &MAX_FACTOR
MAX_FACTOR_PROC PROC NEAR
    PUSH BP
    MOV  BP,SP
    PUSH SI
    PUSH BX
    PUSH CX
    MOV SI,AX                  ; Array pointer from register
    MOV BX,[BP+6]              ; Count from stack
    MOV CX,0
    CMP BX,0
    JNE MF_SCAN
    MOV AX,0                   ; Empty array → max = 0
    JMP MF_STORE
MF_SCAN:
    MOV AX,[SI]                ; First element as initial max
    MOV CX,1                   ; Counter
MF_NEXT:
    CMP CX,BX
    JAE MF_STORE               ; End of array
    ADD SI,2                   ; Next element
    MOV DX,[SI]
    CMP DX,AX
    JBE MF_CONT
    MOV AX,DX                  ; New maximum
MF_CONT:
    INC CX
    JMP MF_NEXT
MF_STORE:
    MOV BX,[BP+4]              ; MAX_FACTOR pointer from stack
    MOV [BX],AX                ; Store result
    POP CX
    POP BX
    POP SI
    POP BP
    RET 4                      ; Clean stack (2 words)
MAX_FACTOR_PROC ENDP

; ========================= 32-BIT UTILITY PROCEDURES =========================
SQR16 PROC NEAR
    MUL AX                     ; AX * AX -> DX:AX
    RET
SQR16 ENDP

SHR32_1 PROC NEAR
    SHR DI, 1                  ; Shift high word
    RCR SI, 1                  ; Shift low word with carry
    RET
SHR32_1 ENDP

DIV32_16 PROC NEAR
    PUSH AX
    XOR DX, DX
    MOV AX, DI
    DIV BX                     ; Divide high word
    MOV DI, AX                 ; Quotient high
    MOV AX, SI
    DIV BX                     ; Divide low word with remainder
    MOV SI, AX                 ; Quotient low
    POP AX
    RET
DIV32_16 ENDP

REM32_16 PROC NEAR
    PUSH AX
    PUSH DI
    PUSH SI
    XOR DX, DX
    MOV AX, DI
    DIV BX                     ; Divide high word
    MOV AX, SI
    DIV BX                     ; DX = remainder
    POP SI
    POP DI
    POP AX
    RET
REM32_16 ENDP

PUSH_FACTOR PROC NEAR
    PUSH BX
    PUSH SI
    MOV BX, FACT_COUNT
    LEA SI, FACTORS
    SHL BX, 1                  ; Word offset
    ADD SI, BX
    MOV [SI], AX               ; Store factor
    INC FACT_COUNT
    POP SI
    POP BX
    RET
PUSH_FACTOR ENDP

CSG ENDS
END main
