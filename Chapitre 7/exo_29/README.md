# Chapitre 7 - Exercice 29

## Enoncé

Montrer comment, en utilisant les registres généraux et les instructions associées, on peut réaliser les opérations de la FPU comme `fabs` qui calcule la valeur absolue ou `fchs` qui change le signe d'une valeur flottante sur 32 bits. On chargera la valeur flottante dans `eax` par exemple avant de réaliser l'opération.

## Solution

Les nombres flottants sont divisés en trois partis, le signe, la mantisse et l'exposant.

Pour rappel, dans la norme IEEE 754, la répartition des bits est la suivante :

**Précision** | **Encodage** | **Signe** | **Exposant** | **Mantisse** | **Valeur d'un nombre** | **Précision** | **Chiffres significatifs**
 --- | --- | --- | --- | --- | --- | --- | --- 
**Simple précision** | 32 bits | 1 bit | 8 bits | 23 bits | $(-1)^S * M * 2^{(E-127)}$ | 24 bits | environ 7
**Double précision** | 64 bits | 1 bit | 11 bits | 52 bits | $(-1)^S * M * 2^{(E-1023)}$ | 53 bits | environ 16

Dans les deux cas, pour avoir la valeur absolue d'un nombre, il suffit de mettre le bit de poids le plus fort à `0`. Pour en changer le signe il faut inverser la valeur du bit de poids le plus fort.

J'ai implémenté ces deux fonctions en assembleur :

```Assembly
section .text
global my_abs   ; rendre la fonction accessible depuis l'extérieur
global my_chs

; extern float my_abs(float nb)
my_abs:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    and     dword [ebp + 8], 0x7FFFFFFF     ; Je conserve la valeur de tous les bits sauf du premier qui vaut toujours 0
    fld     dword [ebp + 8]                 ; Je charge la valeur dans le registre st0 pour le retour

    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction

; extern float my_chs(float nb)
my_chs:
    ; Prologue de la fonction
    push    ebp
    mov     ebp, esp

    xor     dword [ebp + 8], 0x80000000     ; Inversion de la valeur du bit de poids le plus fort
    fld     dword [ebp + 8]                 ; Je charge la valeur dans le registre st0 pour le retour

    ; Epilogue de la fonction
    mov     esp, ebp
    pop     ebp
    ret
```

Que j'ai validé avec le code C :

```C
#include <stdio.h>
#include <math.h>

// Déclaration de la fonction assembleur
extern float my_abs(float nb);
extern float my_chs(float nb);

int main() {

    for (float a = -1000; a <= 1000; a += 0.1) {
        if (my_abs(a) != fabs(a)) {
            printf("Erreur ABS\n");
            return -1;
        }
        if (my_chs(a) != -a) {
            printf("Erreur CHS\n");
            return -1;
        }
    }

    printf("Fonctions validées !\n");

    return 0;
}
```