section .text
global idBitSignificatif_2_asm   ; rendre la fonction accessible depuis l'extérieur

; int idBitSignificatif(int nb)
idBitSignificatif_2_asm:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    ; Corps de la fonction
    mov     eax, [ebp+8]    ; Chargement du paramètre dans eax

    mov     ecx, 0          ; ecx correspond à la variable indice
    mov     edx, 2          ; edx correspond à la variable puissance

.while:
    cmp     eax, edx        ; Si eax (le paramètre) est inférieur à edx (puissance)
    jl      .end_while      ; alors on a trouvé l'indice

    add     ecx, 1          ; Incrémentation de l'indice
    shl     edx, 1          ; Décalage à gauche de tous les bits d'un 1

    jmp     .while          ; Retour au début de la boucle

.end_while:
    mov eax, ecx            ; ecx contient la valeur à retourner

.end:
    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction
