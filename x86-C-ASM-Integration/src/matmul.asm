.386
.model flat, c
.code

PUBLIC matmul_asm

matmul_asm PROC NEAR
    push ebp
    mov  ebp, esp
    sub  esp, 16

    mov  DWORD PTR [EBP-4], 0

i_loop:
    mov  eax, [EBP-4]
    cmp  eax, [EBP+20]
    jge  end_i_loop

    mov  DWORD PTR [EBP-8], 0

j_loop:
    mov  eax, [EBP-8]
    cmp  eax, [EBP+28]
    jge  end_j_loop

    mov  DWORD PTR [EBP-16], 0
    mov  DWORD PTR [EBP-12], 0

k_loop:
    mov  eax, [EBP-12]
    cmp  eax, [EBP+24]
    jge  end_k_loop

    mov  eax, [EBP-4]
    imul DWORD PTR [EBP+24]
    add  eax, [EBP-12]
    shl  eax, 2
    mov  ebx, [EBP+8]
    mov  ecx, [ebx + eax]

    mov  eax, [EBP-12]
    imul DWORD PTR [EBP+28]
    add  eax, [EBP-8]
    shl  eax, 2
    mov  ebx, [EBP+12]
    mov  edx, [ebx + eax]

    mov  eax, ecx
    imul edx
    mov  ecx, eax

    add  [EBP-16], ecx

    inc  DWORD PTR [EBP-12]
    jmp  k_loop

end_k_loop:
    mov  eax, [EBP-4]
    imul DWORD PTR [EBP+28]
    add  eax, [EBP-8]
    shl  eax, 2
    mov  ebx, [EBP+16]
    mov  ecx, [EBP-16]
    mov  [ebx + eax], ecx

    inc  DWORD PTR [EBP-8]
    jmp  j_loop

end_j_loop:
    inc  DWORD PTR [EBP-4]
    jmp  i_loop

end_i_loop:
    mov  esp, ebp
    pop  ebp
    ret
matmul_asm ENDP

END
