

STK SEGMENT PARA STACK 'STACK'
    DW 256 DUP(?)
STK ENDS

DSG SEGMENT PARA 'DATA'
NUMBER_LIST     DW  10 dup(0)
NUMBER_COUNT    DW ?
IS_SORTED_FLAG  DW ?
KEY             DW ?
RESULT_INDEX    DW ?




CR      EQU 13
LF      EQU 10

; Messages
msgEnterCount   DB 'Enter count (max 10): ',0
msgEnterArr     DB CR,LF,'Enter numbers : ',0
msgShowArr      DB CR,LF,'Array: ',0
msgSorted       DB CR,LF,'Array is sorted.',0
msgNotSorted    DB CR,LF,'Array is NOT sorted.',0
msgKeyPrompt    DB CR,LF,'Enter key (or q to quit): ',0
msgResult       DB ' -> Index: ',0
msgNotFound     DB ' -> Not Found (-1)',0
msgNL           DB CR,LF,0



DSG ENDS

CSG SEGMENT PARA 'CODE'
ASSUME CS:CSG, DS:DSG, SS:STK

PRINT_STR PROC
    PUSH AX
    PUSH DX
    PUSH DI
next_char:
    MOV AL, [DI]
    CMP AL, 0
    JE str_done
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    INC DI
    JMP next_char
str_done:
    POP DI
    POP DX
    POP AX
    RET
PRINT_STR ENDP

READ_NUM PROC
    PUSH BX
    PUSH CX
    PUSH DX

    XOR BX, BX
skip_ws:
    MOV AH, 01h
    INT 21h
    CMP AL, ' '
    JE skip_ws
    CMP AL, CR
    JE skip_ws
    CMP AL, LF
    JE skip_ws

    CMP AL, '0'
    JB rn_done
    CMP AL, '9'
    JA rn_done

    SUB AL, '0'
    XOR AH, AH
    MOV BX, AX

rn_loop:
    MOV AH, 01h
    INT 21h
    CMP AL, '0'
    JB rn_done
    CMP AL, '9'
    JA rn_done

    SUB AL, '0'
    XOR AH, AH
    MOV CX, AX

    MOV AX, BX
    SHL BX, 1
    MOV DX, BX
    SHL BX, 1
    SHL BX, 1
    ADD BX, DX
    ADD BX, CX
    JMP rn_loop

rn_done:
    MOV AX, BX
    POP DX
    POP CX
    POP BX
    RET
READ_NUM ENDP

; ------------------------------------------------------------
; PRINT NUMBER
; ------------------------------------------------------------
PRINT_NUM PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP AX, 0
    JGE pn_start
    PUSH AX
    MOV DL, '-'
    MOV AH, 02h
    INT 21h
    POP AX
    NEG AX

pn_start:
    MOV CX, 0
    MOV BX, 10
pn_div:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE pn_div

pn_print:
    POP DX
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    LOOP pn_print

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUM ENDP

IS_SORTED PROC
    PUSH BP
    MOV BP, SP
    PUSH SI
    PUSH CX
    PUSH BX
    PUSH AX

    MOV SI, [BP+4]       ; Array Base
    MOV CX, [BP+6]       ; Count

    DEC CX
    CMP CX, 0
    JLE is_sorted_true

check_loop:
    MOV AX, [SI]
    MOV BX, [SI+2]
    CMP AX, BX
    JG is_sorted_false
    ADD SI, 2
    LOOP check_loop

is_sorted_true:
    MOV AX, 1
    MOV [BP+8], AX
    JMP is_done

is_sorted_false:
    MOV AX, 0
    MOV [BP+8], AX       ; WRITE RESULT TO STACK

is_done:
    POP AX
    POP BX
    POP CX
    POP SI
    POP BP
    RET 4
IS_SORTED ENDP


BINARY_SEARCH PROC
    PUSH BP
    MOV BP, SP
    PUSH SI
    PUSH BX
    PUSH DX
    PUSH CX
    PUSH DI
    PUSH AX

    ; Load Params
    MOV SI, [BP+10]     ; Array
    MOV DX, [BP+8]      ; Low
    MOV CX, [BP+6]      ; High
    MOV BX, [BP+4]      ; Key

    ; Base Case: Low > High?
    CMP DX, CX
    JG bs_not_found

    ; Mid = (Low + High) / 2
    MOV AX, DX
    ADD AX, CX
    SHR AX, 1
    MOV DI, AX          ; DI = Mid Index

    ; Val = A[Mid]
    SHL AX, 1
    ADD SI, AX
    MOV AX, [SI]

    CMP AX, BX
    JE bs_found
    JG bs_go_left

bs_go_right:
    ; Recurse Right: Low = Mid + 1
    MOV AX, DI
    INC AX

    ; PUSH STACK FRAME FOR CHILD
    mov dx,0
    PUSH dx               ; 5. Space for Result
    PUSH [BP+10]        ; 4. Array
    PUSH AX             ; 3. New Low
    PUSH [BP+6]         ; 2. High
    PUSH BX             ; 1. Key

    CALL BINARY_SEARCH

    POP AX              ; GET RESULT FROM STACK (Child result)
    MOV [BP+12], AX     ; Put it in OUR return slot
    JMP bs_return

bs_go_left:
    ; Recurse Left: High = Mid - 1
    MOV AX, DI
    DEC AX

    ; PUSH STACK FRAME FOR CHILD
    mov dx,0
    PUSH dx            ; 5. Space for Result
    PUSH [BP+10]        ; 4. Array
    PUSH [BP+8]         ; 3. Low
    PUSH AX             ; 2. New High
    PUSH BX             ; 1. Key

    CALL BINARY_SEARCH

    POP AX              ; GET RESULT FROM STACK (Child result)
    MOV [BP+12], AX     ; Put it in OUR return slot
    JMP bs_return

bs_found:
    MOV [BP+12], DI     ; Write Mid Index to Stack
    JMP bs_return

bs_not_found:
    MOV AX, -1
    MOV [BP+12], AX     ; Write -1 to Stack

bs_return:
    POP AX
    POP DI
    POP CX
    POP DX
    POP BX
    POP SI
    POP BP
    RET 8               ; Clean Params (8 bytes), Result (2 bytes) remains
BINARY_SEARCH ENDP


; MAIN PROGRAM

START PROC FAR
    MOV AX, DSG
    MOV DS, AX

    ; ---Get Input  ---
    LEA DI, msgEnterCount
    CALL PRINT_STR
    CALL READ_NUM
    MOV NUMBER_COUNT, AX

    LEA DI, msgEnterArr
    CALL PRINT_STR
    MOV CX, NUMBER_COUNT
    MOV SI, OFFSET NUMBER_LIST
get_nums:
    CALL READ_NUM
    MOV [SI], AX
    ADD SI, 2
    LOOP get_nums

    ; Show Array
    LEA DI, msgShowArr
    CALL PRINT_STR
    MOV CX, NUMBER_COUNT
    MOV SI, OFFSET NUMBER_LIST
print_nums:
    MOV AX, [SI]
    CALL PRINT_NUM
    MOV DL, ' '
    MOV AH, 02h
    INT 21h
    ADD SI, 2
    LOOP print_nums

    ; ---  Check Sorted  ---
    mov dx,0
    PUSH dx                   ; Placeholder for Result
    PUSH NUMBER_COUNT       ; Param 2
    MOV AX, OFFSET NUMBER_LIST
    PUSH AX                 ; Param 1

    CALL IS_SORTED

    POP AX                  ; READ RESULT FROM STACK
    MOV IS_SORTED_FLAG, AX

    CMP AX, 1
    JE sorted_ok
    LEA DI, msgNotSorted
    CALL PRINT_STR
    JMP program_exit

sorted_ok:
    LEA DI, msgSorted
    CALL PRINT_STR

    ; ---  Loop Key ---
key_loop:
    LEA DI, msgKeyPrompt
    CALL PRINT_STR

skip_ws_key:
    MOV AH, 01h
    INT 21h
    CMP AL, ' '
    JE skip_ws_key
    CMP AL, CR
    JE skip_ws_key
    CMP AL, LF
    JE skip_ws_key

    CMP AL, 'q'
    JE program_exit

    ; Manual parse first char
    SUB AL, '0'
    XOR AH, AH
    MOV BX, AX

read_rest_key:
    MOV AH, 01h
    INT 21h
    CMP AL, '0'
    JB key_done
    CMP AL, '9'
    JA key_done
    SUB AL, '0'
    XOR AH, AH
    MOV CX, AX
    MOV AX, BX
    SHL BX, 1
    MOV DX, BX
    SHL BX, 1
    SHL BX, 1
    ADD BX, DX
    ADD BX, CX
    JMP read_rest_key

key_done:
    MOV KEY, BX

    ; ---  BINARY SEARCH (Stack Return) ---
    mov dx,0
    PUSH dx                   ; Placeholder for Result (BP+12)

    MOV AX, OFFSET NUMBER_LIST
    PUSH AX                 ; Array (BP+10)
    MOV AX, 0
    PUSH AX                 ; Low (BP+8)
    MOV AX, NUMBER_COUNT
    DEC AX
    PUSH AX                 ; High (BP+6)
    MOV AX, KEY
    PUSH AX                 ; Key (BP+4)

    CALL BINARY_SEARCH

    POP AX                  ; READ RESULT FROM STACK
    MOV RESULT_INDEX, AX

    ; ---  Print Result ---
    CMP AX, -1
    JE print_not_found

    LEA DI, msgResult
    CALL PRINT_STR
    MOV AX, RESULT_INDEX
    CALL PRINT_NUM
    JMP key_loop

print_not_found:
    LEA DI, msgNotFound
    CALL PRINT_STR
    JMP key_loop

program_exit:
    MOV AH, 4Ch
    INT 21h
    RETF

START ENDP
CSG ENDS
END START
