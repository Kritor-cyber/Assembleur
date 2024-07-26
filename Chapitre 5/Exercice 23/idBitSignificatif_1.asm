section .text
global idBitSignificatif_1_asm   ; rendre la fonction accessible depuis l'extérieur

; int idBitSignificatif(int nb)
idBitSignificatif_1_asm:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    ; Corps de la fonction
    mov  eax, [ebp+8]    ; Chargement du paramètre dans eax
    mov  ecx, 32         ; ecx est mon compteur

.while:
    test eax, 0b10000000000000000000000000000000    ; Si le bit de poids le plus fort vaut 1
    jnz  .end   ; alors ecx contient l'indice du bit significatif donc fin de la fonction

    sub  ecx, 1 ; décrémentation de ecx
    shl  eax, 1 ; décalage sur la gauche de 1 bit de eax

    cmp  ecx, 0 ; Tant que ecx est supérieur à 0
    jg   .while ; retour au début de la boucle

.end:
    mov eax, ecx    ; ecx contient l'incidice et eax contient la valeur retournée

    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction
