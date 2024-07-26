section .text
global zero_un_moins_un_asm

; int zero_un_moins_un(int x)
zero_un_moins_un_asm:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    ; Corps de la fonction
    mov     ecx, [ebp+8]    ; x dans ecx
    mov     eax, 1          ; par défault x est considéré comme positif

    ; if (x < 0) return -1;
    mov     edx, -1
    test    ecx, 0b10000000000000000000000000000000
    cmovnz  eax, edx

    ; if (x == 0 || x == 1) return 0;
    xor     edx, edx
    shr     ecx, 1
    test    ecx, ecx        ; Si ecx & ecx = 0 (donc si ecx = 0)
    cmovz   eax, edx          ; alors eax = 0

    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction
