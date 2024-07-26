# Chapitre 5 - Exercice 25

Que se passe t-il si on réalise le traitement suivant ?

```Assembly
mov eax, -6     ; eax = FF_FF_FF_FA_h
xor edx, edx    ; mise à -1 de edx
dec edx
mov ebx, 3
div ebx
```

Lorsque l'on arrive à la cinquième instruction (`div ebx`) nous avons :

```
edx = FF FF FF FF
eax = FF FF FF FA
ebx = 00 00 00 03
```

L'instruction `div` réalise la division entre `edx:eax` et `ebx`, donc on a ici, `FF FF FF FF FF FF FF FA / 00 00 00 03`. En décimale, cela donne `18446744073709551610 / 3` qui vaut environ `5555555555555553` soit en hexadécimal `13 BC BF 93 6B 38 E1` ce qui est supérieur à `FF FF FF FF` (valeur maximal d'un entier). Le microprocesseur lèvera une exception.

Si c'est l'opérateur `idiv` qui est utilisé, alors `FF FF FF FF FF FF FF FA` vaudra `-6` et le résultat sera `FF FF FF F2` soit `-2`.

Avec l'opérateur `div` :

```Assembly
global main

section .text

main:
    ; Entrée dans la fonction (donc du programme)
    push    ebp
    mov     ebp, esp

    mov eax, -6
    xor edx, edx
    dec edx
    mov ebx, 3
    div ebx

    ; Sortie de la fonction (donc du programme)
    mov     esp, ebp
    pop     ebp
    ret
```

J'obtiens le retour `Exception en point flottant (core dumped)`.

Avec l'opérateur `idiv` :

```Assembly
global main

section .text

main:
    ; Entrée dans la fonction (donc du programme)
    push    ebp
    mov     ebp, esp

    mov eax, -6
    xor edx, edx
    dec edx
    mov ebx, 3
    idiv ebx

    ; Sortie de la fonction (donc du programme)
    mov     esp, ebp
    pop     ebp
    ret
```

Plus d'erreur dans la console et le code de retour est `254`, ou `-2` lorsque l'information est sur 8 bits.