section .text
global itoa_asm

; extern void itoa_asm(float* t, int n)
itoa_asm:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    sub     esp, 4      ; Besoin d'une variable locale de 32 bits pour les transfers avec le FPU

    ; [ebp + 8] contient l'adresse avec tab
    ; [ebp + 12] contient n

    mov     dword [esp], 0          ; Initialisation de ma variable locale à 0
    mov     ecx, [ebp + 12]         ; ecx = n
    mov     eax, [ebp + 8]          ; eax = tab
    lea     edx, [eax + ecx * 4]    ; edx = tab + n (c'est à dire la première adresse en dehors du tableau)

.boucle:
    fild    dword [esp]             ; Chargement de ma variable locale par le FPU et conversion de int vers float
    fstp    dword [eax]             ; Récupération du float et enregistrement dans l'adresse pointée par eax
    add     dword [esp], 1          ; Incrémentation de ma variable locale

    add     eax, 4                  ; Incrémentation de l'adresse du tableau à traiter
    cmp    eax, edx                 ; Vérification que l'on est toujours dans le tableau
    jne     .boucle                 ; Pour refaire un tour de boucle

    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction
