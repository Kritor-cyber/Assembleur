global main
extern printf       ; utilisation de la fonction printf de la bibliothèque standard C

section .data
    ; Déclaration d'une chaine de caractères
    ; dont l'avant dernier caractère est un \n (10)
    ; dont le dernier caractère est \0
    msg:    db "Mon incide : %d", 10, 0

section .bss
    ; Réservation d'un tableau de 40 octets (1000 entiers de 4 octets chacun)
    tab: resb 4000

section .text

main:
    ; Entrée dans la fonction (donc du programme)
    push    ebp
    mov     ebp, esp

    ; Initialisation de ebx à 0
    xor ebx, ebx
.boucle:
    ; tab[i] = (i + 1) % 7
    mov     eax, ebx
    add     eax, 1
    xor     edx, edx
    mov     ecx, 7
    div     ecx
    mov     [tab + ebx * 4], dword edx

    ; Gestion de la boucle
    add     ebx, 1
    cmp     ebx, 1000
    jl      .boucle

        ; Initialisation de ebx à 0
    xor ebx, ebx
.boucle2:
    ; Affichage du texte
    push    dword [tab + ebx * 4]   ; Chargement du deuxième paramètre (ici l'indice)
    push    dword msg               ; Chargement du premier paramètre (pointeur vers le texte)
    call    printf                  ; Appel de la fonction printf
    add     esp, 8                  ; Libération des paramètres

    ; Gestion de la boucle
    add     ebx, 1
    cmp     ebx, 1000
    jl      .boucle2

    ; Le code de sortie se trouve dans le registre eax
    xor     eax, eax

    ; Sortie de la fonction (donc du programme)
    mov     esp, ebp
    pop     ebp
    ret
