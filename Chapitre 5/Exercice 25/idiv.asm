global main

section .text

main:
    ; Entrée dans la fonction (donc du programme)
    push    ebp
    mov     ebp, esp

    mov eax, -6
    xor edx, edx
    dec edx
    mov ebx, 3
    idiv ebx

    ; Sortie de la fonction (donc du programme)
    mov     esp, ebp
    pop     ebp
    ret
