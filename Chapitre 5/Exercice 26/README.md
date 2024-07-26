# Chapitre 5 - Exercice 26

Traduire la fonction suivante en assembleur x86 32 bits de la manière la plus efficace possible.

```C
int zero_un_moins_un(int x) {
    if (x < 0) {
        return -1;
    } else if (x > 1) {
        return 1;
    } else {
        return 0;
    }
}
```

## Solution

Dans la fonction ci-dessus, il y a deux conditions `x < 0`  et `x > 1`.

Pour différencier un nombre négatif d'un nombre positif ou nul, il suffit d'en regarder le bit de poids le plus fort. 

L'opérateur `test` permet de facilement différencier les non nuls des nuls.

Pour recréer la fonction C en évitant les sauts et réduisant le nombre d'instruction, je peux :

1. Par défaut, je considère que x est positif, donc `eax` vaut 1
2. Comparer (avec `test`) la valeur de x et `0b10000000000000000000000000000000` (32 bits car x est un entier) puis avec `cmovnz` changer la valeur de `eax` pour -1 si le résultat précédent n'est pas nul (donc que x est négatif).
3. Après avoir décalé les bits d'un rang vers la droite, utiliser l'opérateur `test` avec `cmovz` pour changer la valeur de `eax` pour 0 lorsque x est nul. _Lorsque x vaut 1, la fonction doit retourner 0 donc je supprime le bit de poids faible, ainsi 0 et 1 sont traités de la même façon._

Ce qui donne en assembleur :

```Assembly
section .text
global zero_un_moins_un_asm

; int zero_un_moins_un(int x)
zero_un_moins_un_asm:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    ; Corps de la fonction
    mov     ecx, [ebp+8]    ; x dans ecx
    mov     eax, 1          ; par défault x est considéré comme positif

    ; if (x < 0) return -1;
    mov     edx, -1
    test    ecx, 0b10000000000000000000000000000000
    cmovnz  eax, edx

    ; if (x == 0 || x == 1) return 0;
    xor     edx, edx
    shr     ecx, 1
    test    ecx, ecx        ; Si ecx & ecx = 0 (donc si ecx = 0)
    cmovz   eax, edx          ; alors eax = 0

    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction
```

_J'utilise le registre edx pour stocker la valeur que va hypothétiquement prendre eax lors du `cmovCC`._

Pour tester le bon fonctionnement de ma fonction, j'ai utilisé le code ci-dessous.

```C
#include <stdio.h>

extern int zero_un_moins_un_asm(int x);

int zero_un_moins_un_c(int x) {
    if (x < 0) {
        return -1;
    } else if (x > 1) {
        return 1;
    } else {
        return 0;
    }
}

int main() {
    int i;

    for (i = -1024; i <= 1024; i++) {
        if (zero_un_moins_un_c(i) != zero_un_moins_un_asm(i)) {
            printf("Erreur avec %d\n", i);
            return -1;
        }
    }

    return 0;
}
```

## Performances

J'ai utilisé le code ci-dessous pour comparer ma fonction assembleur et la fonction C.

```C
#include <stdio.h>

extern int zero_un_moins_un_asm(int x);

int zero_un_moins_un_c(int x) {
    if (x < 0) {
        return -1;
    } else if (x > 1) {
        return 1;
    } else {
        return 0;
    }
}

int main() {
    int i, tmp = 0;

    for (unsigned int j = 0; j < 1000; j++) {
        for (i = -1024; i <= 1024; i++) {
            tmp += zero_un_moins_un_asm(i);
        }
    }

    return tmp;
}
```

Si l'option `-O3` de gcc, ma fonction asm prend 0,004 seconde et la fonction C prend 0,006 secondes. Ma fonction est donc plus optimisée. Mais en activé l'option `-O3`, ma fonction assembleur reste à 0,004 secondes tant dis que la fonction C est réduite à 0,002 secondes.

En passant de `1000` itérations à `1000000`, la fonction C prend environ 0,730 secondes et ma fonction assembleur 2,600 secondes.

En décompilant le programme et que je récupère la fonction main, je remarque qu'elle n'appelle aucune fonction, ce qui explique, au moins partiellement, en quoi la "fonction" en C est plus optimisée. 

```Assembly
00001050 <main>:
    1050:	53                   	push   ebx
    1051:	31 d2                	xor    edx,edx
    1053:	bb 40 42 0f 00       	mov    ebx,0xf4240
    1058:	2e 8d b4 26 00 00 00 	lea    esi,cs:[esi+eiz*1+0x0]
    105f:	00 
    1060:	b8 00 fc ff ff       	mov    eax,0xfffffc00
    1065:	8d 76 00             	lea    esi,[esi+0x0]
    1068:	85 c0                	test   eax,eax
    106a:	78 24                	js     1090 <main+0x40>
    106c:	31 c9                	xor    ecx,ecx
    106e:	83 f8 01             	cmp    eax,0x1
    1071:	0f 9f c1             	setg   cl
    1074:	83 c0 01             	add    eax,0x1
    1077:	01 ca                	add    edx,ecx
    1079:	3d 01 04 00 00       	cmp    eax,0x401
    107e:	75 e8                	jne    1068 <main+0x18>
    1080:	83 eb 01             	sub    ebx,0x1
    1083:	75 db                	jne    1060 <main+0x10>
    1085:	89 d0                	mov    eax,edx
    1087:	5b                   	pop    ebx
    1088:	c3                   	ret
    1089:	8d b4 26 00 00 00 00 	lea    esi,[esi+eiz*1+0x0]
    1090:	83 ea 01             	sub    edx,0x1
    1093:	83 c0 01             	add    eax,0x1
    1096:	eb d0                	jmp    1068 <main+0x18>
    1098:	66 90                	xchg   ax,ax
    109a:	66 90                	xchg   ax,ax
    109c:	66 90                	xchg   ax,ax
    109e:	66 90                	xchg   ax,ax
```

Après avoir ajouté des étiquettes/labels, j'ai retiré les adresses des lignes et ai ajouté des commentaires sur le fonctionnement du code.

```Assembly
main:
    ; Initialisation
    push   ebx
    xor    edx,edx
    
    ; compteur de la boucle for de 1 000 000 d'itérations
    mov    ebx,0xf4240              ; ebx = 0xf4240 (ou 1000000 en binaire)
    lea    esi,cs:[esi+eiz*1+0x0]   ; NOP : il s'agit d'une instruction ne faisant rien (eiz valant toujours 0), équivalente à l'instruction nop
    105f:	00                      ; fait partie de l'instruction précédente
    
.saut3:
    ; compteur de la boucle for de -1024 à 1024
    mov    eax,0xfffffc00           ; eax = 0xfffffc00 (ou -1024 en base 10)
    lea    esi,[esi+0x0]            ; nop
    
.saut2:
    ; if (eax < 0) { edx = -1; eax++; } // eax est l'indice de la sous-boucle et edx correspond à la variable tmp (somme des résultats de la "fonction")
    ; donc si la valeur à tester est négative, edx qui contient la somme des résultats, est décrémenté
    ; et on passe à l'itération suivante en incrémentant eax
    test   eax,eax                  ; <=> cmp eax, 0 donc SF = 1 si eax < 0
    js     .saut1                   ; Saut si SF = 1
    
    
    ; if (eax > 1) { cl = 1; } else { cl = 0; }
    ; ecx est initialisé à 0
    ; si eax est supérieur à 1
    ; cl prend la valeur 1
    ; sachant que cl correspond aux 8 bits de poids faible de ecx, donc ecx vaut 1 si eax > 1
    xor    ecx,ecx                  ; ecx = 0
    cmp    eax,0x1                  ; Si eax > 1
    setg   cl                       ; alors cl prend la valeur 1 sinon 0
    
    ; On passe à l'itération suivante
    add    eax,0x1                  ; eax ++
    add    edx,ecx                  ; edx += ecx
    
    ; Retour au début de la sous-boucle
    cmp    eax,0x401                ; Si eax != 0x401 (ou 1025 en base 10)
    jne    .saut2                   ; alors saute à saut2
    
    ; boucle for de 1 000 000 => décrémentation + saut (avec fin du programme lorsque ebx atteint 0)
    sub    ebx,0x1                  ; ebx-- avec ZF (et CF) définis selon le résultat donc ZF = 0 si ebx = 0 (après décrémentation)
    jne    .saut3                   ; Saut à saut3 lorsque ZF = 0
    mov    eax,edx                  ; eax = edx => retour de la somme de tous les résultats
    
    ;fin de la fonction
    pop    ebx
    ret
    lea    esi,[esi+eiz*1+0x0]
    
.saut1:
    sub    edx,0x1                  ; edx--
    add    eax,0x1                  ; eax++
    jmp    .saut2                   ; Saut à saut2
    
    xchg   ax,ax
    xchg   ax,ax
    xchg   ax,ax
    xchg   ax,ax
```

En C, cela donnerait :

```C
#include <stdio.h>

int main() {
    int a = 1000000, c;

    while (a > 0) {
        for (int b = -1024; b < 1025; b++) {
            if (b < 0) {
                c--;
                break;
            }

            if (b > 1) {
                c++;
            }
        }
    }

    return c;
}
```

Certaines des optimisations du compilateur ne peuvent pas être appliquées à ma fonction car je ne la fusionne pas avec les boucles, mais je peux obtenir le code ci-dessous.

```Assembly
section .text
global zero_un_moins_un_asm

; int zero_un_moins_un(int x)
zero_un_moins_un_asm:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    ; Corps de la fonction
    mov     edx, [ebp+8]    ; x dans ecx
    mov     eax, 1          ; par défault x est considéré comme positif

    ; if (x == 0 || x == 1) return 0;
    xor     ecx, ecx
    cmp     edx, 1
    setg    cl
    mov   eax, ecx        ; alors eax = 1 si x > 1 et 0 sinon

    ; if (x < 0) return -1;
    mov     ecx, -1
    test    edx, edx
    cmovs   eax, ecx

    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction
```

Cette nouvelle version prend environ 2,65 secondes à s'exécuter. Elle est donc très légèrement moins rapidement que ma fonction mais la principale perte de temps vis-à-vis de la fonction C compilée est l'appel de ma fonction.