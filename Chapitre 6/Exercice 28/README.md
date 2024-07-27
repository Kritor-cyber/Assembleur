# Chapitre 6 - Exercice 28

## Enoncé

Réaliser le codage du sous-programme suivant en 32 bits, puis en 64
bits :

```C
double procedure(double *tab, int n, double k) {
    double sum = 0;
    
    for (int i = 0; i < n; ++i) {
        sum += tab[i] / k;
    }
    
    return sqrt(sum);
}
```

## Préparation

J'ai commencé par implémenter la fonction en C en utilisant la bibliothèque `math.h` pour la fonction sqrt. Cette fonction me permet de valider que ma fonction assembleur est correcte.

```C
#include <stdio.h>
#include <math.h>

double procedure_c(double *tab, int n, double k) {
    double sum = 0;
    
    for (int i = 0; i < n; ++i) {
        sum += tab[i] / k;
    }
    
    return sqrt(sum);
}

#define N 10

int main() {

    double tab[N];

    for (int i = 0; i < N; i++) {
        tab[i] = i * 2.2 + 1.5;
    }

    printf("Résultat : %f\n", procedure_c(tab, N, 1.2));
    for (int i = 0; i < N; i++) {
        printf("tab[%d] = %f\n", i, tab[i]);
    }

    return 0;
}
```

_Il faut ajouter l'option `-lm` pour compiler en utilisant la bilbiothèque `math.h`._

## 32 bits

En 32 bits, j'ai écrit le code assembleur suivant :

```Assembly
section .text
global procedure_asm   ; rendre la fonction accessible depuis l'extérieur


; float double procedure(double *tab, int n, double k)
procedure_asm:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    mov     eax, [ebp + 8]          ; eax = PTR to tab[0]
    mov     ecx, [ebp + 12]         ; ecx = n
    lea     ecx, [eax + 8 * ecx]    ; ecx = PTR to tab[n]

    fldz                    ; st0 = 0

.boucle:
    fld     qword [eax]             ; st1 = tab[i]
    fdiv    qword [ebp + 16]        ; st1 = tab[i]/k avec [ebp + 16] = k
    faddp   st1                     ; st0 += st1

    ; Déplacement dans le tableau et gestion de la boucle
    add     eax, 8
    cmp     eax, ecx
    jl      .boucle

    fsqrt                           ; il suffit de laisser mon double dans le registre st0 pour que la fonction main en récupère le contenu

    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retour de la fonction
```

Que j'ai validé avec le code C suivant :

```C
#include <stdio.h>
#include <math.h>

// Déclaration de la fonction assembleur
extern double procedure_asm(double *tab, int n, double k);

double procedure_c(double *tab, int n, double k) {
    double sum = 0;

    for (int i = 0; i < n; ++i) {
        sum += tab[i] / k;
    }

    sum = sqrt(sum);

    return sum;
}

#define N 10

int main() {

    double tab[N];

    for (int i = 0; i < N; i++) {
        tab[i] = i * 2.2 + 1.5;
    }

    double res1 = procedure_c(tab, N, 1.2);
    printf("Résultat : %f\n", res1);
    for (int i = 0; i < N; i++) {
        printf("tab[%d] = %f\n", i, tab[i]);
    }

    double res2 = procedure_asm(tab, N, 1.2);
    printf("Résultat : %f\n", res2);
    for (int i = 0; i < N; i++) {
        printf("tab[%d] = %f\n", i, tab[i]);
    }

    if (res1 != res2) {
        printf("Code assembleur INCORRECT !\n");
    } else {
        printf("Code assembleur correct !!!\n");
    }

    return 0;
}
```

## 64 bits

```Assembly
extern printf

section .data
    unvingtcinq:    dd 1.25

section .text
global procedure_asm   ; rendre la fonction accessible depuis l'extérieur


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

procedure_asm:
    ; Prologue de la fonction
    ; push    rbp         ; sauvegarde de l'ancien base pointer
    ; mov     rbp, rsp    ; esp devient le nouveau base pointer

    sub     rsp, 8                  ; Zone de mémoire nécessaire pour le transfert entre xmm et st

    lea     rax, [rdi + rsi * 8]    ; rax contient la première adresse qui suit le tableau sans en faire partie
    movq    qword [rsp], xmm0       ; Chargement de k dans la zone de mémoire pour réaliser la division
    fldz                            ; st0 = 0 (<=> sum)

.boucle

    fld     qword [rdi]             ; st0 = tab[i]
    fdiv    qword [rsp]             ; st0 = st0 / k
    faddp   st1                     ; st1 += st0 (avec libération de st0)

    add     rdi, 8                  ; i++ (ici je travaille avec des double donc sur 8 octets)
    cmp     rdi, rax                ; Tant que je n'ai pas atteint la fin du tableau
    jl      .boucle                 ; Je continue

    fsqrt                           ; Calcul de la racine carré de la somme obtenue
    fstp    qword [rsp]             ; Récupération du résultat dans la zone mémoire
    movq    xmm0, qword [rsp]       ; Enregistrement du résultat dans le registre xmm0 pour que l'appelant le récupère


    add rsp, 8                      ; Libération de la mémoire

    ; Épilogue de la fonction
    ; mov rsp, rbp
    ; pop rbp
    ret
```

Mon programme de test (qui n'a pas changé) m'indique que le résultat obtenu n'est pas correct. En récupérant le contenu des deux variables avec gdb, j'obtiens `res1 = 9.7467943448089631` et `res2 = 9.7467943448089649`.

En récupérant le code généré par gcc, je remarque qu'il a calculé directement dans les registres xmm :

```Assembly
; double procedure_c(double *tab, int n, double k) {
    1169:	f3 0f 1e fa          	endbr64
    116d:	55                   	push   rbp
    116e:	48 89 e5             	mov    rbp,rsp
    1171:	48 83 ec 30          	sub    rsp,0x30
    1175:	48 89 7d e8          	mov    QWORD PTR [rbp-0x18],rdi
    1179:	89 75 e4             	mov    DWORD PTR [rbp-0x1c],esi
    117c:	f2 0f 11 45 d8       	movsd  QWORD PTR [rbp-0x28],xmm0
;   double sum = 0;
    1181:	66 0f ef c0          	pxor   xmm0,xmm0
    1185:	f2 0f 11 45 f8       	movsd  QWORD PTR [rbp-0x8],xmm0

;   for (int i = 0; i < n; ++i) {
    118a:	c7 45 f4 00 00 00 00 	mov    DWORD PTR [rbp-0xc],0x0
    1191:	eb 2f                	jmp    11c2 <procedure_c+0x59>
;       sum += tab[i] / k;
    1193:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    1196:	48 98                	cdqe
    1198:	48 8d 14 c5 00 00 00 	lea    rdx,[rax*8+0x0]
    119f:	00 
    11a0:	48 8b 45 e8          	mov    rax,QWORD PTR [rbp-0x18]
    11a4:	48 01 d0             	add    rax,rdx
    11a7:	f2 0f 10 00          	movsd  xmm0,QWORD PTR [rax]
    11ab:	f2 0f 5e 45 d8       	divsd  xmm0,QWORD PTR [rbp-0x28]
    11b0:	f2 0f 10 4d f8       	movsd  xmm1,QWORD PTR [rbp-0x8]
    11b5:	f2 0f 58 c1          	addsd  xmm0,xmm1
    11b9:	f2 0f 11 45 f8       	movsd  QWORD PTR [rbp-0x8],xmm0
;   for (int i = 0; i < n; ++i) {
    11be:	83 45 f4 01          	add    DWORD PTR [rbp-0xc],0x1
    11c2:	8b 45 f4             	mov    eax,DWORD PTR [rbp-0xc]
    11c5:	3b 45 e4             	cmp    eax,DWORD PTR [rbp-0x1c]
    11c8:	7c c9                	jl     1193 <procedure_c+0x2a>
;   }

;   sum = sqrt(sum);
    11ca:	48 8b 45 f8          	mov    rax,QWORD PTR [rbp-0x8]
    11ce:	66 48 0f 6e c0       	movq   xmm0,rax
    11d3:	e8 88 fe ff ff       	call   1060 <sqrt@plt>
    11d8:	66 48 0f 7e c0       	movq   rax,xmm0
    11dd:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax

;   return sum;
    11e1:	f2 0f 10 45 f8       	movsd  xmm0,QWORD PTR [rbp-0x8]
;}
    11e6:	c9                   	leave
    11e7:	c3                   	ret
```

Je vais donc mettre à jour ma fonction pour utiliser uniquement les registres xmm, cependant, je ne vais pas appeler la fonction sqrt de la bibliothèque `math.h` :

```Assembly
section .text
global procedure_asm   ; rendre la fonction accessible depuis l'extérieur


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

procedure_asm:
    ; Prologue de la fonction
    ; push    rbp         ; sauvegarde de l'ancien base pointer
    ; mov     rbp, rsp    ; esp devient le nouveau base pointer

    lea     rax, [rdi + rsi * 8]    ; rax contient la première adresse qui suit le tableau sans en faire partie

    xorps    xmm1, xmm1              ; sum = 0

.boucle:

    movq    xmm2, qword [rdi]       ; Chargement de tab[i] dans xmm2
    divsd   xmm2, xmm0              ; Division de xmm2 par xmm0 (k)
    addsd   xmm1, xmm2              ; Ajout de xmm2 à xmm1 (somme totale)

    add     rdi, 8                  ; i++ (ici je travaille avec des double donc sur 8 octets)
    cmp     rdi, rax                ; Tant que je n'ai pas atteint la fin du tableau
    jl      .boucle                 ; Je continue

    sqrtsd  xmm0, xmm1              ; Calcul de la racine carré de la somme obtenue

    ; Épilogue de la fonction
    ; mov rsp, rbp
    ; pop rbp
    ret
```

Avec ce code, j'obtiens exactement le même résultat qu'avec ma fonction C. 