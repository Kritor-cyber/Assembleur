# Chapitre 7 - Exercice 32

## Enoncé

Implantez la fonction `puissance` en architecture 32 bits en utilisant la FPU :

```C
float puissance(float x, int n) {
    float result = 1;
    for (int i=0; i<n; ++i) {
        result *= x;
    }
    return result;
}
```

Faire de même en 64 bits.

## 32 bits

```Assembly
section .text
global puissance_asm_32

puissance_asm_32:
        ; Prologue
        push    ebp
        mov     ebp, esp

        mov     eax, [ebp + 12]         ; eax = n

        fld     dword [ebp + 8]         ; st0 = x
        fld1                            ; st0 = 1 et st1 = x

        cmp     eax, 0                  ; Si n <= 0
        jle     .end                    ; Alors retourne 1.0

.boucle:
        test    eax, eax                ; Si eax = 0
        jz      .end                    ; Fin du calcul, retour de st0

        fmul    st1                     ; st0 *= st1 (x)

        sub     eax, 1                  ; eax--
        jmp     .boucle                 ; Nouvelle itération

.end:
        fstp                            ; Libération de st1
        ; Epilogue
        mov     esp, ebp
        pop     ebp
        ret
```

Que j'ai testé avec :

```C
#include <stdio.h>
#include <math.h>

extern float puissance_asm_32(float x, int n);

float puissance_c(float x, int n) {
    float result = 1;
    for (int i=0; i<n; ++i) {
        result *= x;
    }
    return result;
}

int main() {

    float x = 1.2, e = -5.;

    printf("%.1f ^ %.1f = %f\n", x, e, puissance_c(x, e));
    printf("%.1f ^ %.1f = %f\n", x, e, puissance_asm_32(x, e));

    e = 5.;

    printf("%.1f ^ %.1f = %f\n", x, e, puissance_c(x, e));
    printf("%.1f ^ %.1f = %f\n", x, e, puissance_asm_32(x, e));

    return 0;
}
```

## 64 bits

```Assembly
default rel

section .data
        un: dd 1.

        section .text
global puissance_asm_64

; En 64 bits, les paramètres sont passés via les registres pour les entiers (puis la pile s'il n'y a pas assez de registres)
; Les registres sont : rdi, rsi, rdx, rcx, r8, r9 (à utiliser dans cet ordre)
; Les paramètres flotants sont passés dans la partie basse des registres xmm0 à xmm7

; Le retour d'une valeur entière se fait dans le registre rax
; Le retour d'un flotant se fait dans la partie basse du registre xmm0

; Les registres qui ne doivent pas être modifiés par la sous-fonction : rbp, rbx, r12 à r15

; float procedure(int* tab, int n)

; Si la pile n'est pas utilisée, le prologue et l'épilogue peuvent être supprimés (seule l'instruction ret reste)

; Sous linux, la zone de [rsp-128] à [rsp] peut-être utilisée si les instructions push et call ne le sont pas
; (elles modifient cette zone). Cela n'est pas possible sous Windows

puissance_asm_64:

        ; xmm0 contient x
        ; rdi contient n

        movss   xmm1, [un]              ; xmm1 = 1

        cmp     edi, 0                  ; Si n <= 0
        ; Les int sont sur 4 octets alors que rdi propose 8 octets. Donc pour un int valant -5, edi = 0xfffffffb = -5
        ; mais rdi = 0xfffffffb = 4294967291
        jle     .end                    ; Alors retourne 1.0

.boucle:
        test    edi, edi                ; Si eax = 0
        jz      .end                    ; Fin du calcul, retour de st0

        mulss   xmm1, xmm0

        sub     edi, 1                  ; eax--
        jmp     .boucle                 ; Nouvelle itération

.end:
        movss   xmm0, xmm1
        ret
```

Sans modification majeure dans le code C de vérification :

```C
#include <stdio.h>
#include <math.h>

extern float puissance_asm_64(float x, int n);

float puissance_c(float x, int n) {
    float result = 1;
    for (int i=0; i<n; ++i) {
        result *= x;
    }
    return result;
}

int main() {

    float x = 1.2;
    int e = -5;

    printf("%.1f ^ %d = %f\n", x, e, puissance_c(x, e));
    printf("%.1f ^ %d = %f\n", x, e, puissance_asm_64(x, e));

    e = 5;

    printf("%.1f ^ %d = %f\n", x, e, puissance_c(x, e));
    printf("%.1f ^ %d = %f\n", x, e, puissance_asm_64(x, e));

    return 0;
}
```