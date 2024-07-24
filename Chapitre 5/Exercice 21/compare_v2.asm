section .text
global compare_asm_v2   ; rendre la fonction accessible depuis l'extérieur

compare_asm_v2:
    ; Prologue de la fonction
    push    ebp
    mov     ebp, esp

    ; Corps de la fonction
    ; "Allocation" de mémoire pour mes variables locales (16 octets => 4 entiers) y1, y2, z1 et z2
    sub    esp,0x10

    ; [esp] <=> y1
    mov eax, [ebp+12]
    mov [esp+0x0], eax

    ; [esp+0x4] <=> z1
    mov eax, [ebp+16]
    mov [esp+0x4], eax

    ; [esp] <=> y2
    mov eax, [ebp+12]
    mov [esp+0x8], eax

    ; [esp+0x4] <=> z2
    mov eax, [ebp+16]
    mov [esp+0xc], eax


    ; if (z == 9) => eax = FFFFFFFF sinon eax = 0
    mov eax, [ebp+16]           ; Copie de z dans eax
    cmp eax, 9
    lahf                        ; Load Status Flags Into AH Register (ainsi le résultat de la comparaison est chargé dans le registre ah, qui est une partie de eax)
    not eax                     ; Inversion du résultat car je teste la différence
    ; Je conserve uniquement le bit de l'égalité entre eax et 9
    and eax, dword 0b0100000000000000
    shr eax, 14

    add eax, -1                 ; Enfin je soustrais 1 pour avoir 0xFFFFFFFF ou 0x0

    and [esp], eax              ; J'applique le résultat à y1
    and [esp+0x4], eax          ; et z1

    ; if (x % 2 == 0) => eax = FFFFFFFF sinon eax = 0
    mov eax, [ebp+8]
    and eax, 0b1                ; Pour tester la non parité d'un entier, il suffit que son bit de poids le plus faible soit égal à 1
    add eax, -1

    and [esp+0x8], eax          ; J'applique le résultat à y2
    and [esp+0xc], eax          ; et z2

    ; if (y < 257) => eax = FFFFFFFF sinon eax = 0
    mov eax, [ebp+0xc]
    cmp eax, 257                ; Le principe est ici le même que pour l'égalité
    lahf
    not eax                     ; mais ce n'est pas le même flag qu'il faut conserver
    and eax, dword 0b000100000000
    shr eax, 8
    add eax, -1

    and [esp+0x8], eax          ; J'applique le résultat à y2
    and [esp+0xc], eax          ; et z2

    ; x = x + (y1 | y2) - (z1 | z2)
    mov eax, [ebp+8]            ; Je charge x
    mov ecx, [esp]              ; et y1
    mov edx, [esp+4]            ; et z1

    or ecx, [esp+8]             ; = y1 | y2
    or edx, [esp+0xc]           ; = z1 | z2

    add eax, ecx                ; = x + (y1 | y2)
    sub eax, edx                ; = x + (y1 | y2) - (z1 | z2)

    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction