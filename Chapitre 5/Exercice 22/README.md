# Chapitre 5 - Exercice 22

## Enoncé

Traduire le code suivante en assembleur x86 32 bits :

```C
const int SIZE = 1000;
int tab[SIZE];

for (int i = 0; i < SIZE; ++i) {
    tab[i] = (i + 1) % 7;
}
```

## Etude du problème

Je commence par créer une première version du code en C qui après avoir rempli le tableau va l'afficher :

```C
#include <stdio.h>

int main() {
    const int SIZE = 1000;
    int tab[SIZE];

    for (int i = 0; i < SIZE; ++i) {
        tab[i] = (i + 1) % 7;
    }

    for (int i = 0; i < SIZE; i++) {
        printf("%d\n", tab[i]);
    }

    return 0;
}
```

Je dois créer un tableau de 1000 entiers. Sa création peut être statique car sa taille est constante. Chaque élément du tableau doit contenir son indice modulo 7. Dans ma version, j'ai ajouté une deuxième boucle qui affiche tous les éléments du tableau.

## Solution

Je commence par récupérer la version assembleur du classique Hello World! fournit dans le pdf :

```Assembly
global main
extern printf       ; utilisation de la fonction printf de la bibliothèque standard C

section .data
    ; Déclaration d'une chaine de caractères
    ; dont l'avant dernier caractère est un \n (10)
    ; dont le dernier caractère est \0
    msg:    db "Hello World!", 10, 0

section .text

main:
    ; Entrée dans la fonction (donc du programme)
    push    ebp
    mov     ebp, esp

    push    dword msg
    call    printf
    add     esp, 4

    ; Le code de sortie se trouve dans le registre eax
    xor     eax, eax

    ; Sortie de la fonction (donc du programme)
    mov     esp, ebp
    pop     ebp
    ret
```


Maintenant que je peux afficher dans la console, je vais créer une boucle qui va afficher le même message 10 fois.

Je remplace mon message par `"Mon incide : %d", 10, 0` pour afficher la valeur de l'incide courant.

Je vais utiliser le registre `ebx` comme compteur. Je l'initialise à 0 avec `xor ebx, ebx` puis je déclare le début de ma boucle avec l'étiquette/label `.boucle`.

Je mets ensuite le code qui s'exécute à l'intérieur de ma boucle puis j'incrémente mon compteur `add ebx, 1`, je le compare avec la limite supérieure `cmp ebx, 10` et je recommence tant que `ebx` est inférieur à 10.

Ce qui donne :

```Assembly
    ; Initialisation de ebx à 0
    xor ebx, ebx

.boucle:
    ; ... Ici le code à exécuter

    add     ebx, 1      ; Incrémentation du compteur
    cmp     ebx, 10     ; Tant que ebx < 10
    jl      .boucle     ; je reste dans la boucle
```

Ce qui donne le code :

```Assembly
global main
extern printf       ; utilisation de la fonction printf de la bibliothèque standard C

section .data
    ; Déclaration d'une chaine de caractères
    ; dont l'avant dernier caractère est un \n (10)
    ; dont le dernier caractère est \0
    msg:    db "Mon incide : %d", 10, 0

section .text

main:
    ; Entrée dans la fonction (donc du programme)
    push    ebp
    mov     ebp, esp

    ; Initialisation de ebx à 0
    xor ebx, ebx
.boucle:
    ; Affichage du texte
    push    ebx         ; Chargement du deuxième paramètre (ici l'indice)
    push    dword msg   ; Chargement du premier paramètre (pointeur vers le texte)
    call    printf      ; Appel de la fonction printf
    add     esp, 8      ; Libération des paramètres

    ; Gestion de la boucle
    add     ebx, 1
    cmp     ebx, 10
    jl      .boucle

    ; Le code de sortie se trouve dans le registre eax
    xor     eax, eax

    ; Sortie de la fonction (donc du programme)
    mov     esp, ebp
    pop     ebp
    ret
```

J'ai `ebx` qui sert de compteur pour ma boucle. Pour calculer le modulo d'un nombre qui n'est pas une puissance de 2, il faut utiliser `div` (pour les puissances de 2, le `and` est plus efficace). Le dividende se trouve dans `edx:eax` et le diviseur est l'opérande attendu par `div`. Le quotient est enregistré dans `eax` et le reste dans `edx`. Je peux donc calculer comme ci-dessous :

```Assembly
mov eax, ebx    ; Je souhaite diviser le compteur (ici ebx)
add eax, 1      ; auquel j'ai ajouté 1
mov ecx, 7      ; par 7
xor edx, edx    ; edx contient les octets de poids forts du dividende, ne l'utilisant pas, je l'initialise à 0
div ecx         ; Le reste de la division du compteur par 7 est contenu dans edx
```

J'ajoute ce nouveau contenu dans ma boucle, et créer une nouvelle boucle pour afficher le contenu du tableau. Enfin, j'augmente la taille du tableau ainsi que le nombre de tour dans la boucle et j'obtiens :

```Assembly
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
```

## Vérification

J'ai enregistré le contenu affiché dans la console de mes deux programmes (C et Assembleur) dans deux fichiers textes et la commande diff m'a confirmé que le contenu était identique, donc mon programme est bon.