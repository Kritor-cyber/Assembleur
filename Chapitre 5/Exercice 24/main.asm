global main
extern printf       ; utilisation de la fonction printf de la bibliothèque standard C

%macro BODY 0
    mov     [tab + ebx * 4], dword ebx
    add     ebx, 1
%endmacro

section .data
    ; Déclaration d'une chaine de caractères
    ; dont l'avant dernier caractère est un \n (10)
    ; dont le dernier caractère est \0
    msg:    db "tab[%4d] = %d", 10, 0

    ; Réservation d'un tableau de N entiers initialisés à 0
    N       EQU 1005        ; constante
    tab:    times N dd 0

section .text

main:
    ; Entrée dans la fonction (donc du programme)
    push    ebp
    mov     ebp, esp

    xor     ebx, ebx        ; Initialisation de ebx à 0 qui servira de compteur pour les boucles

    mov     edx, N          ; edx va contenir le maximum multiple de 16 à atteindre
    and     edx, ~16         ; suppression du reste de la division de N par 16


.whileinit:
    ; Pour la case de tableau d'indice ebx, je définis la valeur à ebx
    BODY
    BODY
    BODY
    BODY
    BODY
    BODY
    BODY
    BODY
    BODY
    BODY
    BODY
    BODY
    BODY
    BODY
    BODY
    BODY
    ; Gestion de la boucle
    cmp     ebx, edx
    jl     .whileinit

; Ici je traite les derniers éléments du tableau 1 par 1
.whileendinit:
    BODY
    cmp     ebx, N
    jl     .whileendinit

; Je parcours et affiche l'ensemble du tableau pour vérifier le bon fonctionnement du code précédent
    xor     ebx, ebx
.whileprint:
    ; Affichage du texte
    push    dword [tab + ebx * 4]
    push    ebx
    push    dword msg               ; Chargement du premier paramètre (pointeur vers le texte)
    call    printf                  ; Appel de la fonction printf
    add     esp, 12                 ; Libération des paramètres
    add     ebx, 1
    cmp     ebx, N
    jne      .whileprint


    ; Le code de sortie se trouve dans le registre eax
    xor     eax, eax
    ; Sortie de la fonction (donc du programme)
    mov     esp, ebp
    pop     ebp
    ret
