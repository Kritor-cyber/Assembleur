# Chapitre 5 - Exercice 24

Soit le code suivant :

```C
const int N = 1005;
int tab[N];

for (int i = 0; i < N; i++) {
    tab[i] = i;
}
```

1. Réaliser un dépliage par 8 du code C
2. Traduire le code C en assembleur 32 bits

_Attention, la difficulté lors de la traduction en assembleur provient de l'instruction `tab[i] = i;` pour laquelle il faut augmenter `i` à chaque itération du dépliage._

## C

J'ai écrit le code ci-dessous pour vérifier que le contenu du tableau est bon.

```C
#include <stdio.h>

int main() {
    
    const int N = 1005;
    int tab[N];

    // Boucle à déplier
    for (int i = 0; i < N; i++) {
        tab[i] = i;
    }

    for (int i = 0; i < N; i++) {
        if (tab[i] != i) {
            printf("ERREUR, tab[i] != i => %d != %d\n", tab[i], i);
        }
    }

    return 0;
}
```

Je vais commencer par déplier la boucle par 4.

```C
#include <stdio.h>

int main() {
    
    const int N = 1005;
    int tab[N];

    // Pour i allant de 0 à N - (N % 4) <=> N & ~4
    /*
    * Par exemple si N = 7, alors N & ~4 = 4, ainsi la boucle fera pour i entre 0 et 3
    * Sans cette modification la boucle fera deux itérations, la première pour 0 à 3 et la suivante de 4 à 7
    * Or la limite supérieure est à 7 exclus
    */
    int i;
    for (i = 0; i < (N & ~4); i += 4) {
        tab[i] = i;
        tab[i+1] = i+1;
        tab[i+2] = i+2;
        tab[i+3] = i+3;
    }

    // Ici je traite les derniers indices du tableau précédemment ignorés
    while (i < N) {
        tab[i] = i;
        i++;
    }

    for (i = 0; i < N; i++) {
        if (tab[i] != i) {
            printf("ERREUR, tab[i] != i => %d != %d\n", tab[i], i);
        }
    }

    return 0;
}
```

## Assembleur

En assembleur, j'obtiens :

```Assembly
global main
extern printf       ; utilisation de la fonction printf de la bibliothèque standard C

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

    mov     edx, N          ; edx va contenir le maximum multiple de 4 à atteindre
    and     edx, ~4         ; suppression du reste de la division de N par 4


.whileinit:
    ; Pour la case de tableau d'indice ebx, je définis la valeur à ebx
    mov     [tab + ebx * 4], dword ebx
    add     ebx, 1                      ; Puis j'incrémente ebx pour le calcul suivant
    mov     [tab + ebx * 4], dword ebx
    add     ebx, 1
    mov     [tab + ebx * 4], dword ebx
    add     ebx, 1
    mov     [tab + ebx * 4], dword ebx
    add     ebx, 1
    ; Gestion de la boucle
    cmp     ebx, edx
    jl     .whileinit

; Ici je traite les derniers éléments du tableau 1 par 1
.whileendinit:
    mov     [tab + ebx * 4], dword ebx
    add     ebx, 1
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
```

Pour améliorer la lisibilité du code et plus facilement changer la taille du dépliage, je peux utiliser les macros instructions de nasm.

Ce qui donne :

```Assembly
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

    mov     edx, N          ; edx va contenir le maximum multiple de 4 à atteindre
    and     edx, ~4         ; suppression du reste de la division de N par 4


.whileinit:
    ; Pour la case de tableau d'indice ebx, je définis la valeur à ebx
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
```

Je peux facilement passer à un dépliage de 16 :

```Assembly
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

```