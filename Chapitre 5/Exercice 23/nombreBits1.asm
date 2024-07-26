section .text
global nombreBits1_asm   ; rendre la fonction accessible depuis l'extérieur

; int nombreBits1(int nb)
nombreBits1_asm:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    ; Corps de la fonction
    mov     eax, [ebp+8]    ; Chargement du paramètre dans eax

    mov     ecx, 0          ; ecx correspond à la variable nb1

.while:
    test     eax, eax       ; Si eax est égal à 0
    jz      .end_while      ; alors on a trouvé le nombre de bits

    mov     edx, eax        ; Copie de eax dans edx
    and     edx, 1          ; Si edx est impair
    add     ecx, edx        ; j'augmente ecx de 1 (sinon de 0)

    shr     eax, 1          ; Décalage à droite de tous les bits d'un 1 bit

    jmp     .while          ; Retour au début de la boucle

.end_while:
    mov eax, ecx            ; ecx contient la valeur à retourner

.end:
    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction
