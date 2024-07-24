# Chapitre 5 - Exercice 21

## Enoncé

Traduire le code suivant en assembleur x86 32 bits où x, y et z sont
trois variables entières :

```C
if ((((x % 2) == 0) && (y < 257)) || (z == 9)) {
    x = x + y - z;
}
```

## Résolution

Pour cet exercice, j'ai choisi de créer une fonction qui attend trois paramètres (x, y, z) et retourne `x + y - z` si les conditions sont réunies et `x` dans le cas contraire. Le code en C ci-dessous implémente ce fonctionnement :

```C
#include <stdio.h>

int compare_c(int x, int y, int z) {
    if ((((x % 2) == 0) && (y < 257)) || (z == 9)) {
        return x + y - z;
    }
    return x;
}

int main() {
    int x = 10, y = 200, z = 10;

    printf("f(%d, %d, %d) = %d\n", x, y, z, compare_c(x, y, z));

    return 0;
}
```

Je vais maintenant créer ma version en assembleur de cette fonction que je pourrais appeler dans la fonction `main`.

### Assembleur version 1

Pour cette fonction, j'ai simplement converti le code C en assembleur. J'ai décomposé la condition en un ensemble de petites conditions avec les sauts en fonction des résultats obtenus.

```
Si x est Impair
Alors Saut à IMPAIR
FinSi
Si y inférieur à 257
Alors Saut à CALCUL

IMPAIR
Si z différent 9
Alors Saut FIN

CALCUL
x = x + y - z

END
Retourne x
```

Je n'ai pas changé l'ordre des conditions. Si x est impair, il n'y a pas besoin de tester la valeur de y, je saute donc directement au deuxième teste pouvant entrainer le calcul du nouveau x (étant donné la présence du OU si la première condition n'est pas validée, il faut tester la seconde).
Si x est pair, alors la fonction teste la valeur du y, si cette dernière est inférieure à 257 alors le programme se rend directement aux instructions de calcul du nouveau x et la deuxième condition n'a pas besoin d'être testée.

Si x est impair ou y est supérieur ou égal à 257, alors je teste la valeur de z. Si z est différent de 9 alors je me rends la fin de la fonction sans calculer le nouveau x. Dans le cas contraire, l'instruction suivante rejoindra CALCUL et la nouvelle valeur de x sera calculée.

Ce qui donne en assembleur :

```Assembly
section .text
global compare_asm_v1           ; Nom de la fonction accessible depuis les autres fichiers sources

compare_asm_v1:
    ; Prologue de la fonction
    push    ebp
    mov     ebp, esp

    ; Corps de la fonction
    ; le premier argument (x de type entier) se trouve à l'adresse [ebp+8]
    ; le  second argument (y de type entier) se trouve à l'adresse [ebp+12]
    ; le dernier argument (z de type entier) se trouve à l'adresse [ebp+16]

    mov     eax, [ebp+8]    ; copie de la valeur de x dans le registre eax
    test    eax, 1          ; si le bit de poids faible n'est pas 1, alors il s'agit d'un nombre pair
    ; Rappel sur l'instruction test : elle permet de comparer deux valeurs en réalisant un and entre les deux opérandes qui ne seront pas modifiées et dont le résultat sera propagé au niveau du registre flags

    ; Souhaitant sauter à la condition suivante lorsque x est impair, j'utilise l'instruction jnz (jump on not zero), j'aurais pu utiliser jne (jump on not equal)
    jnz      .impair

    ; Je compare maintenant le second argument avec 257
    cmp [ebp+12], dword 257
    ; Lorsque y est inférieur à 257 je souhaite sauter à l'instruction du calcul, j'utilise donc l'instruction jl (jump on less)
    jl .calcul

; Ici se trouve la deuxième condition de l'exercice (z == 9)
.impair:
    ; Je compare la valeur du troisième argument avec 9
    cmp [ebp+16], dword 9
    ; Si les deux valeurs ne sont pas égales, je saute à la fin de la fonction et le calcul ne sera pas effectué.
    jne .end

; Le registre eax contient toujours la valeur de x, je lui ajoute donc la valeur de y puis je lui soustrais la valeur de z
.calcul:
    add eax, [ebp+12]
    sub eax, [ebp+16]

; La valeur retournée par la fonction se trouve dans le registre eax, donc la valeur est déjà prête
.end:
    ; Épilogue de la fonction
    mov     esp, ebp
    pop     ebp
    ret
```

Pour valider le bon fonctionnement de ma fonction en assembleur, j'ai mis à jour mon code C pour inclure ma nouvelle fonction et comparer mes deux versions de la même fonction. Les résultats doivent toujours être identiques.

```C
#include <stdio.h>

#define N 256

// Déclaration de la fonction assembleur
extern int compare_asm_v1(int a, int b, int c);

int compare_c_v1(int x, int y, int z) {
    if ((((x % 2) == 0) && (y < 257)) || (z == 9)) {
        return x + y - z;
    }

    return x;
}

int main() {

    unsigned int x, y, z;
    
    for (x = 0; x < N; x++) {
        for (y = 0; y < N; y++) {
            for (z = 0; z < N; z++) {
                if (compare_asm_v1(x, y, z) != compare_c_v1(x, y, z)) {
                    printf("ERREUR avec %d, %d, %d\n", x, y, z);
                    return -1;
                }
            }
        }
    }

    printf("Aucune erreur, exercice validé !\n");

    return 0;
}
```

Pour compiler le code assembleur, le C et lancer le programme, j'utilise les commandes

```bash
nasm -f elf32 compare_v1.asm
gcc -m32 main.c compare_v1.o -o exo_21
./exo_21
```

### Fonction C version 2

Je souhaite essayer de trouver une fonction identique à la première mais n'utilisant aucun saut. J'ai donc commencé par en faire une version en C :

```C
int compare_c_v2(int x, int y, int z) {

    int y1 = y & ((z != 9) - 1);
    int z1 = z & ((z != 9) - 1);

    int y2 = y & ((x % 2 != 0) -1);
    int z2 = z & ((x % 2 != 0) -1);

    y2 = y2 & ((y >= 257) - 1);
    z2 = z2 & ((y >= 257) - 1);

    return x + (y1 | y2) - (z1 | z2);
}
```

Pour créer cette fonction, j'ai trouvé des opérations dont le résultat est toujours `0` ou `1`. `0` dans le cas où la condition correspondante est vérifiée et `1` sinon. A ce résultat je soustrais `1`, donc `0` devient `0xFFFFFFFF` et `1` devient `0` ce qui permet, avec l'opérateur `and` de conserver ou supprimer les valeurs. 

Il y a deux conditions principales, `((x % 2) == 0) && (y < 257))` et `z == 9`, il suffit que l'une des deux conditions soit vérifiée pour que le calcul ait lieu. Je crée donc deux copies des variables `y` et `z`.

`y1` et `z1` sont associées à la condition `z == 9`. Si elle est vérifiée, `y1 = y` et `z1 = z` sinon `y1 = z1 = 0`. Pour ce faire, je compare `z` avec `9`. S'ils sont différents, alors j'ai la valeur `1` à laquelle je soustrais `1` ce qui donne `0` et j'applique l'opérateur `and` entre `y` et cette valeur que j'enregistre dans `y1` (de même avec `z` dans `z1`). 

Pour `y2` et `z2`, je fais de même avec la parité de `x`. Puis dans un second temps, je réitère le processus avec la condition `y < 257` mais j'applique l'opérateur `and` directement sur `y2` et `z2`, ainsi le `ET` conditionnel est conservé.

Enfin, je fusionne `y1` et `y2` (de même pour z) avec l'opérateur `or`, ainsi si l'une des conditions est validée, le calcul s'opère, et si toutes les conditinos sont validées, le calcul restera le même.

Je l'ai ensuite convertie en assembleur.

## Fonction assembleur version 2

```Assembly
section .text
global compare_asm_v2   ; rendre la fonction accessible depuis l'extérieur

compare_asm_v2:
    ; Prologue de la fonction
    push    ebp
    mov     ebp, esp

    ; Corps de la fonction
    ; "Allocation" de mémoire pour mes variables locales (16 octets => 4 entiers) y1, y2, z1 et z2
    sub    esp,0x10

    ; [esp] <=> y1
    mov eax, [ebp+12]
    mov [esp+0x0], eax

    ; [esp+0x4] <=> z1
    mov eax, [ebp+16]
    mov [esp+0x4], eax

    ; [esp] <=> y2
    mov eax, [ebp+12]
    mov [esp+0x8], eax

    ; [esp+0x4] <=> z2
    mov eax, [ebp+16]
    mov [esp+0xc], eax


    ; if (z == 9) => eax = FFFFFFFF sinon eax = 0
    mov eax, [ebp+16]           ; Copie de z dans eax
    cmp eax, 9
    lahf                        ; Load Status Flags Into AH Register (ainsi le résultat de la comparaison est chargé dans le registre ah, qui est une partie de eax)
    not eax                     ; Inversion du résultat car je teste la différence
    ; Je conserve uniquement le bit de l'égalité entre eax et 9
    and eax, dword 0b0100000000000000
    shr eax, 14

    add eax, -1                 ; Enfin je soustrais 1 pour avoir 0xFFFFFFFF ou 0x0

    and [esp], eax              ; J'applique le résultat à y1
    and [esp+0x4], eax          ; et z1

    ; if (x % 2 == 0) => eax = FFFFFFFF sinon eax = 0
    mov eax, [ebp+8]
    and eax, 0b1                ; Pour tester la non parité d'un entier, il suffit que son bit de poids le plus faible soit égal à 1
    add eax, -1

    and [esp+0x8], eax          ; J'applique le résultat à y2
    and [esp+0xc], eax          ; et z2

    ; if (y < 257) => eax = FFFFFFFF sinon eax = 0
    mov eax, [ebp+0xc]
    cmp eax, 257                ; Le principe est ici le même que pour l'égalité
    lahf
    not eax                     ; mais ce n'est pas le même flag qu'il faut conserver
    and eax, dword 0b000100000000
    shr eax, 8
    add eax, -1

    and [esp+0x8], eax          ; J'applique le résultat à y2
    and [esp+0xc], eax          ; et z2

    ; x = x + (y1 | y2) - (z1 | z2)
    mov eax, [ebp+8]            ; Je charge x
    mov ecx, [esp]              ; et y1
    mov edx, [esp+4]            ; et z1

    or ecx, [esp+8]             ; = y1 | y2
    or edx, [esp+0xc]           ; = z1 | z2

    add eax, ecx                ; = x + (y1 | y2)
    sub eax, edx                ; = x + (y1 | y2) - (z1 | z2)

    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction
```

Je mets à jour mon code C pour tester toutes mes nouvelles fonctions :

```C
#include <stdio.h>

#define N 256

// Déclaration de la fonction assembleur
extern int compare_asm_v1(int a, int b, int c);
extern int compare_asm_v2(int a, int b, int c);

int compare_c_v1(int x, int y, int z) {
    if ((((x % 2) == 0) && (y < 257)) || (z == 9)) {
        return x + y - z;
    }

    return x;
}

int compare_c_v2(int x, int y, int z) {

    int y1 = y & ((z != 9) - 1);
    int z1 = z & ((z != 9) - 1);

    int y2 = y & ((x % 2 != 0) -1);
    int z2 = z & ((x % 2 != 0) -1);

    y2 = y2 & ((y >= 257) - 1);
    z2 = z2 & ((y >= 257) - 1);

    return x + (y1 | y2) - (z1 | z2);
}

int main() {

    unsigned int x, y, z;
    
    for (x = 0; x < N; x++) {
        for (y = 0; y < N; y++) {
            for (z = 0; z < N; z++) {
                if (compare_asm_v1(x, y, z) != compare_c_v1(x, y, z)) {
                    printf("ERREUR avec %d, %d, %d\n", x, y, z);
                    return -1;
                }

                if (compare_c_v1(x, y, z) != compare_c_v2(x, y, z)) {
                    printf("ERREUR avec %d, %d, %d\n", x, y, z);
                    return -2;
                }


                if (compare_asm_v1(x, y, z) != compare_asm_v2(x, y, z)) {
                    printf("ERREUR avec %d, %d, %d\n", x, y, z);
                    return -3;
                }
            }
        }
    }

    printf("Aucune erreur, exercice validé !\n");

    return 0;
}
```

Et je compile :

```bash
nasm -f elf32 compare_v1.asm
nasm -f elf32 compare_v2.asm
gcc -m32 main.c compare_v1.o compare_v2.o -o exo_21
./exo_21
```

## Performances

J'utilise le code ci-dessous pour comparer les performances de mes différentes fonctions :

```C
#include <stdio.h>

#define N 256

// Déclaration de la fonction assembleur
extern int compare_asm_v1(int a, int b, int c);
extern int compare_asm_v2(int a, int b, int c);

int compare_c_v1(int x, int y, int z) {
    if ((((x % 2) == 0) && (y < 257)) || (z == 9)) {
        return x + y - z;
    }

    return x;
}

int compare_c_v2(int x, int y, int z) {

    int y1 = y & ((z != 9) - 1);
    int z1 = z & ((z != 9) - 1);

    int y2 = y & ((x % 2 != 0) -1);
    int z2 = z & ((x % 2 != 0) -1);

    y2 = y2 & ((y >= 257) - 1);
    z2 = z2 & ((y >= 257) - 1);

    return x + (y1 | y2) - (z1 | z2);
}

int main() {

    unsigned int x, y, z, tmp = 0;
    
    for (x = 0; x < N; x++) {
        for (y = 0; y < N; y++) {
            for (z = 0; z < N; z++) {
                tmp += compare_c_v1(x, y, z);
                // tmp += compare_c_v2(x, y, z);
                // tmp += compare_asm_v1(x, y, z);
                // tmp += compare_asm_v2(x, y, z);
            }
        }
    }


    printf("Résultat : %u\n", tmp);

    return 0;
}
```

Puis je compile et exécutre avec la commande :

```bash
nasm -f elf32 compare_v1.asm && nasm -f elf32 compare_v2.asm && gcc -m32 main.c compare_v1.o compare_v2.o -o exo_21 && time ./exo_21
```

### Compare C version 1

```
Résultat : 2142978048

real    0m0,038s
user    0m0,037s
sys     0m0,001s
```

### Compare C version 2

```
Résultat : 2142978048

real    0m0,058s
user    0m0,057s
sys     0m0,001s
```

### Compare ASM version 1

```
Résultat : 2142978048

real    0m0,037s
user    0m0,036s
sys     0m0,001s
```

### Compare ASM version 2

```
Résultat : 2142978048

real    0m0,061s
user    0m0,060s
sys     0m0,001s
```

## Performances -O3

En ajoutant l'option `-O3` à gcc, j'obtiens les résultats :

### Compare C version 1

```
Résultat : 2142978048

real    0m0,008s
user    0m0,007s
sys     0m0,001s
```

### Compare C version 2

```
Résultat : 2142978048

real    0m0,014s
user    0m0,012s
sys     0m0,001s
```

### Compare ASM version 1

```
Résultat : 2142978048

real    0m0,028s
user    0m0,027s
sys     0m0,001s
```

### Compare ASM version 2

```
Résultat : 2142978048

real    0m0,053s
user    0m0,051s
sys     0m0,002s
```

Je remarque une amélioration des performances pour toutes les fonctions, mais ce sont les fonctions en C qui présentent le meilleur gain. En décompilant le programme avec objdump, je retrouve les instructions correspondant aux fonctions C :

Version 1 :

```Assembly
compare_c_v1():
    1250:       8b 54 24 08             mov    edx,DWORD PTR [esp+0x8]
    1254:       8b 44 24 04             mov    eax,DWORD PTR [esp+0x4]
    1258:       8b 4c 24 0c             mov    ecx,DWORD PTR [esp+0xc]
    125c:       81 fa 00 01 00 00       cmp    edx,0x100
    1262:       7f 04                   jg     1268 <compare_c_v1+0x18>
    1264:       a8 01                   test   al,0x1
    1266:       74 08                   je     1270 <compare_c_v1+0x20>
    1268:       83 f9 09                cmp    ecx,0x9
    126b:       74 03                   je     1270 <compare_c_v1+0x20>
    126d:       c3                      ret
    126e:       66 90                   xchg   ax,ax
    1270:       01 d0                   add    eax,edx
    1272:       29 c8                   sub    eax,ecx
    1274:       c3                      ret
    1275:       2e 8d b4 26 00 00 00    lea    esi,cs:[esi+eiz*1+0x0]
    127c:       00 
    127d:       8d 76 00                lea    esi,[esi+0x0]
```

Version 2 :

```Assembly
    1280:       55                      push   ebp
    1281:       57                      push   edi
    1282:       56                      push   esi
    1283:       53                      push   ebx
    1284:       83 ec 04                sub    esp,0x4
    1287:       8b 6c 24 18             mov    ebp,DWORD PTR [esp+0x18]
    128b:       8b 54 24 1c             mov    edx,DWORD PTR [esp+0x1c]
    128f:       8b 5c 24 20             mov    ebx,DWORD PTR [esp+0x20]
    1293:       89 e9                   mov    ecx,ebp
    1295:       89 d0                   mov    eax,edx
    1297:       83 e1 01                and    ecx,0x1
    129a:       83 e9 01                sub    ecx,0x1
    129d:       21 c8                   and    eax,ecx
    129f:       21 d9                   and    ecx,ebx
    12a1:       81 fa 00 01 00 00       cmp    edx,0x100
    12a7:       89 04 24                mov    DWORD PTR [esp],eax
    12aa:       0f 9e c0                setle  al
    12ad:       31 f6                   xor    esi,esi
    12af:       83 fb 09                cmp    ebx,0x9
    12b2:       0f 45 d6                cmovne edx,esi
    12b5:       89 c7                   mov    edi,eax
    12b7:       84 c0                   test   al,al
    12b9:       8b 04 24                mov    eax,DWORD PTR [esp]
    12bc:       0f 44 c6                cmove  eax,esi
    12bf:       09 d0                   or     eax,edx
    12c1:       89 fa                   mov    edx,edi
    12c3:       01 e8                   add    eax,ebp
    12c5:       83 fb 09                cmp    ebx,0x9
    12c8:       0f 94 c3                sete   bl
    12cb:       84 d2                   test   dl,dl
    12cd:       0f 44 ce                cmove  ecx,esi
    12d0:       0f b6 db                movzx  ebx,bl
    12d3:       83 c4 04                add    esp,0x4
    12d6:       8d 1c db                lea    ebx,[ebx+ebx*8]
    12d9:       09 cb                   or     ebx,ecx
    12db:       29 d8                   sub    eax,ebx
    12dd:       5b                      pop    ebx
    12de:       5e                      pop    esi
    12df:       5f                      pop    edi
    12e0:       5d                      pop    ebp
    12e1:       c3                      ret
```

Je remarque que la version 1 n'est pas une fonction, elle fait partie de la boucle principale, j'y trouve notamment la comparaison entre `z` et `9` :

```Assembly
main():
    1060:       e8 7d 02 00 00          call   12e2 <__x86.get_pc_thunk.ax>
    1065:       05 73 2f 00 00          add    eax,0x2f73
    106a:       8d 4c 24 04             lea    ecx,[esp+0x4]
    106e:       83 e4 f0                and    esp,0xfffffff0
    1071:       31 d2                   xor    edx,edx
    1073:       ff 71 fc                push   DWORD PTR [ecx-0x4]
    1076:       55                      push   ebp
    1077:       89 e5                   mov    ebp,esp
    1079:       57                      push   edi
    107a:       31 ff                   xor    edi,edi
    107c:       56                      push   esi
    107d:       53                      push   ebx
    107e:       51                      push   ecx
    107f:       83 ec 18                sub    esp,0x18
    1082:       89 45 e0                mov    DWORD PTR [ebp-0x20],eax
    1085:       8d 87 00 01 00 00       lea    eax,[edi+0x100]
    108b:       89 fb                   mov    ebx,edi
    108d:       89 fe                   mov    esi,edi
    108f:       89 45 e4                mov    DWORD PTR [ebp-0x1c],eax
    1092:       f7 d3                   not    ebx
    1094:       83 e3 01                and    ebx,0x1
    1097:       2e 8d b4 26 00 00 00    lea    esi,cs:[esi+eiz*1+0x0]
    109e:       00 
    109f:       90                      nop
    10a0:       31 c0                   xor    eax,eax                      ; eax = 0
    10a2:       8d b6 00 00 00 00       lea    esi,[esi+0x0]
    10a8:       83 f8 09                cmp    eax,0x9                      ; Comparaison avec 9
    10ab:       74 53                   je     1100 <main+0xa0>             ; si eax = 9 => saut à l'adresse 0x1100
    10ad:       84 db                   test   bl,bl                        ; si bl vaut 0 => saut à l'adresse 0x1100
    10af:       75 4f                   jne    1100 <main+0xa0>
    10b1:       83 c0 01                add    eax,0x1                      ; eax++
    10b4:       01 fa                   add    edx,edi                      ; edx += edi
    10b6:       3d 00 01 00 00          cmp    eax,0x100                    ; si eax != 0x100 (256)
    10bb:       75 eb                   jne    10a8 <main+0x48>             ; saut à l'adresse 0x10a8 (retour à la comparaison entre eax et 9)
    10bd:       83 c6 01                add    esi,0x1                      ; esi++
    10c0:       39 75 e4                cmp    DWORD PTR [ebp-0x1c],esi     ; si [epb-0x1c] != esi
    10c3:       75 db                   jne    10a0 <main+0x40>             ; saut à l'adresse 0x10a0 (retour à la mise à 0 de eax)
    10c5:       83 c7 01                add    edi,0x1                      ; edi++
    10c8:       81 ff 00 01 00 00       cmp    edi,0x100                    ; edi != 0x100 (256)
    10ce:       75 b5                   jne    1085 <main+0x25>             ; saut à l'adresse 0x1085
    10d0:       8b 5d e0                mov    ebx,DWORD PTR [ebp-0x20]     ; ebx = [ebp-0x20]
    10d3:       83 ec 04                sub    esp,0x4                      ; esp -= 4
    10d6:       52                      push   edx                          ; ajout de edx dans la pile des arguments de la prochaine fonction appelée
    10d7:       8d 83 30 e0 ff ff       lea    eax,[ebx-0x1fd0]             ; eax = ebx-0x1fd0 (adresse vers la chaine de caractères constante)
    10dd:       50                      push   eax                          ; ajout de eax dans la pile des arguments de la prochaine fonction appelée
    10de:       6a 02                   push   0x2                          ; ajout de 0x2 dans la pile des arguments de la prochaine fonction appelée (nombre d'arguments)
    10e0:       e8 5b ff ff ff          call   1040 <__printf_chk@plt>      ; appel de la fonction printf
    10e5:       83 c4 10                add    esp,0x10
    10e8:       8d 65 f0                lea    esp,[ebp-0x10]
    10eb:       31 c0                   xor    eax,eax                      ; eax = 0
    10ed:       59                      pop    ecx
    10ee:       5b                      pop    ebx
    10ef:       5e                      pop    esi
    10f0:       5f                      pop    edi
    10f1:       5d                      pop    ebp
    10f2:       8d 61 fc                lea    esp,[ecx-0x4]
    10f5:       c3                      ret
    10f6:       2e 8d b4 26 00 00 00    lea    esi,cs:[esi+eiz*1+0x0]
    10fd:       00 
    10fe:       66 90                   xchg   ax,ax
    1100:       89 f1                   mov    ecx,esi
    1102:       29 c1                   sub    ecx,eax
    1104:       83 c0 01                add    eax,0x1
    1107:       01 ca                   add    edx,ecx
    1109:       3d 00 01 00 00          cmp    eax,0x100
    110e:       75 98                   jne    10a8 <main+0x48>
    1110:       83 c6 01                add    esi,0x1
    1113:       39 75 e4                cmp    DWORD PTR [ebp-0x1c],esi
    1116:       75 88                   jne    10a0 <main+0x40>
    1118:       eb ab                   jmp    10c5 <main+0x65>
    111a:       66 90                   xchg   ax,ax
    111c:       66 90                   xchg   ax,ax
    111e:       66 90                   xchg   ax,ax
```