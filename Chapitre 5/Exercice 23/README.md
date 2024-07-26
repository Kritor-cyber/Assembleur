# Chapitre 5 - Exercice 23

Ecrire les fonctions qui réalisent les traitements suivants en C puis les traduire en assembleur :

1. Vérifier qu'un entier est une puissance de 2
2. Trouver le bit le plus significatif d'un entier non signé, c'est à dire la position du bit de poids fort
3. Compter le nombre de bits à 1 dans un entier non signé

## 1 - Puissance de 2

Voici un tableau avec les premières puissances de deux en base 10 et 2.

Décimal | Binaire
--- | ---
2   | 0000 0010
4   | 0000 0100
8   | 0000 1000
16  | 0001 0000
32  | 0010 0000
64  | 0100 0000
128 | 1000 0000

Je remarque que les puissances deux n'ont qu'un bit à 1 (excepté 1). En retirant 1 à chaque nombre j'obtiens le tableau ci-dessous.

Décimal | Binaire
--- | ---
1   | 0000 0001
3   | 0000 0011
7   | 0000 0111
15  | 0000 1111
31  | 0001 1111
63  | 0011 1111
127 | 0111 1111

Les puissances de 2, en binaire, ne présentent qu'un unique bit à 1, donc en retirant 1, j'obtiens un nombre dont le 1 est devenu 0. Si `x` est une puissance de 2, il n'y a aucun 1 commun entre `x` et `x-1`. Donc si en appliquant l'opérateur `and` entre `x` et `x-1` on obtient `0`, alors il s'agit d'une puissance de 2, sinon `x` n'est pas une puissance de 2.

Par exemple si `x = 1010`, alors `x-1 = 1001` et `x & x-1 = 1000`. Donc `1010` n'est pas une puissance de 2.

### C

L'implémentation de ce raisonnement en C donne la fonction ci-dessous.

```C
int puissance2deux(int nb) {
    if (nb == 0)
        nb = 3;

    return nb & (nb - 1);
}
```

Si `n` est une puissance de 2, alors `nb & (nb - 1)` vaut `0`. 

Cependant, `0 & x` donne `0` quel que soit `x` alors que `0` n'est pas une puissance de 2, donc il faut exclure ce cas avec une condition. 

### Assembleur

```Assembly
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
```

## 2 - Bit de poids fort

Je pourrais manuellement tester les 32 positions des bits avec des opérateurs `and` mais ce serait long et lourd à programmer et exécuter. 

Idée 1 : Je parcours le nombre bit par bit dans l'ordre décroissant des poids. Le premier bit qui vaut 1 se trouve être le bit le plus significatif.

Idée 2 : Je cherche dans quel intervalle de puissance de 2 se trouve mon nombre. L'indice du bit significatif de mon nombre correspondra à l'indice de la puissance de 2 qui lui est inférieure.

Pour résoudre cet exercice, je peux soit coder ma propre fonction soit utiliser l'instruction `clz` (pour Count Leading Zeros) qui retourne le nombre de zéros qui précèdent le bit le plus significatif.

### C - Idée 1

```C
int idBitSignificatif(int nb) {
    int i = 32; // Car un entier est constitué de 32 bits
    while (i > 0) {
        if (nb & 0b10000000000000000000000000000000) {
            return i;
        }
        i--;
        nb = nb << 1;
    }

    return 0;
}
```

### Assembleur - Idée 1

```Assembly
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
```

### C - Idée 2

```C
int idBitSignificatif_2(int nb) {
    int indice = 0;
    int puissance = 2;

    while (1) {
        if (nb < puissance) return indice;
        indice++;
        puissance = puissance << 1;     // Est équivalent à *= 2
    }
}
```

### Assembleur - Idée 2

```Assembly
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
```

## 3 - Nombre de bits à 1

Je parcours le nombre du bit de poids faible au plus fort, s'il est impair, j'incrémente le nombre de bits à 1 puis je décale le nombre à droite d'un bit.

### C

```C
int nombreBits1(unsigned int nb) {
    int nb1 = 0;

    while (nb > 0) {
        if (nb % 2) nb1++;
        nb = nb >> 1;
    }

    return nb1;
}
```

Que je peux simplifier en :

```C
int nombreBits1(unsigned int nb) {
    int nb1 = 0;

    while (nb > 0) {
        nb1 += nb % 2;
        nb = nb >> 1;
    }

    return nb1;
}
```

### Assembleur

```Assembly
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
```

## Vérification

Pour m'assurer que toutes mes fonctions soient correctes, j'utilise le code suivant :

```C
#include <stdio.h>

extern int puissance2deux_asm(int nb);
extern int idBitSignificatif_1_asm(int nb);
extern int idBitSignificatif_2_asm(int nb);
extern int nombreBits1_asm(unsigned int nb);

int puissance2deux_c(int nb) {
    if (nb == 0)
        nb = 3;

    return nb & (nb - 1);
}

int idBitSignificatif_1_c(int nb) {
    int i = 32;
    while (i >= 0) {
        if (nb & 0b10000000000000000000000000000000) {
            return i;
        }
        i--;
        nb = nb << 1;
    }

    return 0;
}

int idBitSignificatif_2_c(int nb) {
    int indice = 0;
    int puissance = 2;

    while (1) {
        if (nb < puissance) return indice;
        indice++;
        puissance = puissance << 1;
    }
}

int nombreBits1_c(unsigned int nb) {
    int nb1 = 0;

    while (nb > 0) {
        nb1 += nb % 2;
        nb = nb >> 1;
    }

    return nb1;
}

int main() {
    
    int indiceBitSignificatif = 0;

    for (int i = 0; i <= 1024; i++) {
        if (puissance2deux_c(i) != puissance2deux_asm(i)) {
            printf("Erreur puissance2deux à %d, %d != %d\n", i, puissance2deux_c(i), puissance2deux_asm(i));
            return -1;
        }
        if (puissance2deux_asm(i) == 0) {
            printf("%d\n", i);
        }

        if (idBitSignificatif_1_c(i) != idBitSignificatif_1_asm(i)) {
            printf("Erreur id bit significatif (1) à %d, %d != %d\n", i, idBitSignificatif_1_c(i), idBitSignificatif_1_asm(i));
            return -1;
        }

        if (idBitSignificatif_2_c(i) != idBitSignificatif_2_asm(i)) {
            printf("Erreur id bit significatif (2) à %d, %d != %d\n", i, idBitSignificatif_2_c(i), idBitSignificatif_2_asm(i));
            return -1;
        }

        if (nombreBits1_c(i) != nombreBits1_asm(i)) {
            printf("Erreur nombre bits à %d, %d != %d\n", i, nombreBits1_c(i), nombreBits1_asm(i));
            return -1;
        }
    }

    return 0;
}
```