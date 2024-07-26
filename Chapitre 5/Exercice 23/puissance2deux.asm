section .text
global puissance2deux_asm   ; rendre la fonction accessible depuis l'extérieur

; int puissance2deux(int nb)
puissance2deux_asm:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    ; Corps de la fonction
    mov eax, [ebp+8]    ; Chargement du paramètre dans eax
    test eax, eax       ; Si eax = 0 alors ce n'est pas une puissance de 2
    jnz .continue       ; alors je change la valeur de eax poour 3 qui n'est pas une puissance de 2
    mov eax, 3         ; car le code ci-dessous considère 0 comme une puissance de 2

.continue:
    mov ecx, eax        ; Copie de eax dans ecx
    sub ecx, 1          ; ecx--
    and eax, ecx        ; eax = eax + ecx
    ; Si le paramètre est une puissance de 2 alors eax = 0
    ; Sinon eax != 0


    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction
