# Chapitre 6 - Exercice 27

## Enoncé

Réaliser le codage du sous-programme suivant en 32 bits, puis en 64 bits :

```C
float procedure(int *tab, int n) {
    float sum = 0;
    for (int i = 0; i < n; ++i) {
        tab[i] = tab[i] / 2;
        sum += tab[i] * 1.25;
    }
    return sqrt(sum);
}
```

## Préparation

J'ai commencé par implémenter la fonction en C en utilisant la bibliothèque `math.h` pour la fonction sqrt. Cette fonction me permet de valider que ma fonction assembleur est correcte.

```C
#include <stdio.h>
#include <math.h>

float procedure_c(int *tab, int n) {
    float sum = 0;
    for (int i = 0; i < n; i++) {
        tab[i] = tab[i] / 2;
        sum += tab[i] * 1.25;
    }

    return sqrtf(sum);
}

#define N 10

int main() {

    int tab[N];

    for (int i = 0; i < N; i++) {
        tab[i] = i * 2 + 1;
    }

    printf("Résultat : %f\n", procedure_c(tab, N));
    for (int i = 0; i < N; i++) {
        printf("tab[%d] = %d\n", i, tab[i]);
    }

    return 0;
}
```

_Il faut ajouter l'option `-lm` pour compiler en utilisant la bilbiothèque `math.h`._

## 32 bits

En 32 bits, j'ai écrit le code assembleur suivant :

```Assembly
section .data
    deux:           dd 2       ; constante qui vaut 2
    unvingtcinq:    dd 1.25    ; constante qui vaut 1.25

section .text
global procedure_asm   ; rendre la fonction accessible depuis l'extérieur


; float procedure(int* tab, int n)
procedure_asm:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    sub     esp, 4      ; Allocation de la mémoire pour une variable locale (int)
    push    ebx         ; Sauvegarde de ebx pour pouvoir l'utiliser

    mov     ebx, [ebp + 8]  ; ebx = tab[0]
    mov     ecx, [ebp + 12] ; ecx = n

    fldz                    ; st0 = 0 (<=> sum)

.boucle:
    mov     eax, [ebx + 4 * ecx - 4]    ; eax = tab[i-1] : i allant de n à 1 inclus
    xor     edx, edx                    ; mise à 0 de edx avant la division
    div     dword [deux]                ; division de eax par 2
    mov     [ebx + 4 * ecx - 4], eax    ; application de la modification dans le tableau

    mov     [ebp - 4], eax              ; stockage de tab[i-1]/2 à une adresse mémoire pour la convertir en float
    fild    dword [ebp - 4]             ; conversion en float

    fmul    dword [unvingtcinq]         ; multiplication du float contenant tab[i-1]/2 par 1.25

    faddp   st1                         ; ajout du dernier résultat au total (contenu dans st1) et libération de st0 => donc st1 devient st0

    sub     ecx, 1          ; eax--
    test    ecx, ecx        ; Si eax != 0
    jnz     .boucle         ; retour au début de la boucle

    fsqrt                   ; enfin calcul de la racine carrée de la somme totale
.end:
    pop     ebx             ; Récupération de ebx
    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction
```

Que j'ai validé avec le code C suivant :

```C
#include <stdio.h>
#include <math.h>

// Déclaration de la fonction assembleur
extern float procedure_asm(int *tab, int n);

float procedure_c(int *tab, int n) {
    float sum = 0;
    for (int i = 0; i < n; i++) {
        tab[i] = tab[i] / 2;
        sum += tab[i] * 1.25;
    }

    return sqrtf(sum);
}

#define N 10

int main() {

    int tab[N];

    for (int i = 0; i < N; i++) {
        tab[i] = i * 2 + 1;
    }

    float res1, res2;

    res1 = procedure_c(tab, N);
    printf("Résultat : %f\n", res1);
    /*for (int i = 0; i < N; i++) {
        printf("tab[%d] = %d\n", i, tab[i]);
    }*/

    for (int i = 0; i < N; i++) {
        tab[i] = i * 2 + 1;
    }
    res2 = procedure_asm(tab, N);
    printf("Résultat : %f\n", res2);
    /*for (int i = 0; i < N; i++) {
        printf("tab[%d] = %d\n", i, tab[i]);
    }*/

    if (res1 != res2) {
        printf("Code assembleur INCORRECT !\n");
    } else {
        printf("Code assembleur correct !!!\n");
    }

    return 0;
}
```

J'ai compilé le programme avec l'option `-O2` et ai récupéré le code assembleur de la fonction `procedure` :

```Assembly
procedure_c:
    push   esi                          ; Sauvegarde de esi
    call   __x86.get_pc_thunk.si
    add    esi,0x2cb6                   ; esi = 0x2cb6
    
    push   ebx                          ; Sauvegarde de ebx
    sub    esp,0x14                     ; Allocation de 14 octets de variables locales
    
    mov    eax,DWORD PTR [esp+0x24]     ; eax = n (le deuxième paramètre)
    test   eax,eax                      ; Si eax <= 0
    jle    .saut1                       ; aucune exécution, fin de la fonction
    
    mov    edx,DWORD PTR [esp+0x20]     ; edx contient l'adresse vers esp+0x20 (soit tab[0])
    fldz                                ; Chargement dans st0 de 0.0
    fld    DWORD PTR [esi-0x1fc4]       ; Chargement dans st1 de ce qui se trouve à l'adresse 0x0cf2 (= 0x2cb6 - 0x1fc4) soit 1.25
    lea    ebx,[edx+eax*4]              ; ebx = tab[n] (l'adresse qui suit la dernière adresse valide du tableau)
    jmp    .saut2                       ; saut à saut 2
    
    lea    esi,[esi+eiz*1+0x0]
.saut3:
    fxch   st(1)                        ; st1 devient st0 et st0 devient st1

.saut2:
    ; int tmp = tab[i]/2
    mov    ecx,DWORD PTR [edx]          ; ecx = edx = tab[0]
    add    edx,0x4                      ; edx = tab[1]
    mov    eax,ecx                      ; eax = ecx = tab[0]
    shr    eax,0x1f                     ; le bit de poids le plus fort devient celui de poids le plus faible (les autres sont supprimés)
    add    eax,ecx                      ; eax += ecx (si ecx est pair alors eax = ecx sinon, eax = ecx + 1)
    sar    eax,1                        ; décalage des bits de eax de 1 sur la droite (avec conservation du signe)

    ; float ftmp = (float) tmp; tab[i] = tmp;
    mov    DWORD PTR [esp+0xc],eax      ; Stockage de tab[i]/2 dans une variable locale pour en faire un float
    fild   DWORD PTR [esp+0xc]          ; Stockage de tab[i]/2 dans st0
    mov    DWORD PTR [edx-0x4],eax      ; Stockage de tab[i]/2 dans tab[i]
    
    
    fmul   st,st(1)                     ; st0 *= st1
    faddp  st(2),st                     ; st2 += st0 avec libération de st0 => st1 devient st0 et st2 devient st1
    
    fxch   st(1)                        ; st1 devient st0 et st0 devient st1
    fstp   DWORD PTR [esp+0xc]          ; Enregistre st0 dans la variable locale esp+0xc tout en le retirant de la liste
    fld    DWORD PTR [esp+0xc]          ; Charge dans st0 la valeur contenue à l'adresse esp+0xc
    
    cmp    ebx,edx                      ; Si ebx != edx (condition d'arrêt de la boucle)
    jne    .saut3                       ; Retour au début de la boucle
    
    fstp   st(1)                        ; Copie de st0 dans st1 puis libère st0
    fldz                                ; st0 = 0 et le précédent st0 devient st1
    fucomip st,st(1)                    ; si st0 > st1 et libération de st0 => Si st1 est négatif ou nul
    ja     .saut4                       ; Alors saut à saut4
    fsqrt                               ; Sinon calcul de la racine carré et fin de la fonction

.saut5: ; Libération de la mémoire et récupération des registres
    add    esp,0x14
    pop    ebx
    pop    esi
    ret
    lea    esi,[esi+0x0]
    
.saut1:
    add    esp,0x14                     ; Libération des variables locales
    fldz                                ; Retourne 0 car le tableau est vide (ou présente une taille invalide)
    pop    ebx
    pop    esi
    ret
    
.saut4:
    sub    esp,0x10
    mov    ebx,esi
    fstp   DWORD PTR [esp]
    call   sqrtf@plt                    ; sum étant négatif, utilisation de la fonction sqrt de math.h plutôt que l'instruction fsqrt
    add    esp,0x10
    jmp    .saut5
```

Mon code ne prend pas en charge lorsque le paramètre `n` est strictement inférieur à `1`. Si la somme de tous les éléments du tableau est négative, alors une exception sera générée et elle ne sera pas traitée par ma fonction. Pour un total négatif, la fonction en C retourne `-nan` mais pas ma fonction.

## 64 bits

En 64 bits ma sous fonction est plus courte que ma version 32 bits (beaucoup de commentaires pour me servir de mémo pour les programmes suivants aussi en base64) :

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

    lea     r11, [rdi + 4 * rsi]    ; rdi contient l'adresse de  tab[0] et rsi contient n
    ; => r1 contient l'adresse de tab[n] qui n'existe pas

    fldz                            ; st0 = 0 (<=> sum)


.boucle:
    ; Ici je traite les données
    shr     dword [rdi], 1
    ; mov     [rdi], rax

    fild    dword [rdi]             ; conversion en float et ajout dans la pile
    fmul    dword [unvingtcinq]     ; multiplication du float contenant tab[i-1]/2 par 1.25
    faddp   st1                     ; ajout du dernier résultat au total (contenu dans st1) et libération de st0 => donc st1 devient st0

    add     rdi, 4      ; Incrémentation de l'adresse dans le tableau que l'on utilise
    cmp     rdi, r11    ; Si r11 < rdi (tant que l'on est dans le tableau)
    jne     .boucle     ; Retour au début de la boucle

    fsqrt               ; Calcul de la racine puis récupération de la somme pour la retourner "enregistrement dans xmm0"
    fstp        dword [unvingtcinq]
    movd        xmm0, [unvingtcinq]

    ; Épilogue de la fonction
    ; mov rsp, rbp
    ; pop rbp
    ret

    ; mov     rdi, msg
    ; mov     rsi, rax
    ; xor     rax, rax        ; Met rax à 0 pour indiquer qu'il n'y a pas d'arguments en virgule flottante
    ; When a function taking variable-arguments is called, %rax must be set to the total number of floating point parameters passed to the function in vector registers
    ; call printf WRT ..plt
```

