section .text
global procedure_asm   ; rendre la fonction accessible depuis l'extérieur


; En 64 bits, les paramètres sont passés via les registres pour les entiers (puis la pile s'il n'y a pas assez de registres)
; Les registres sont : rdi, rsi, rdx, rcx, r8, r9 (à utiliser dans cet ordre)
; Les paramètres flotants sont passés dans la partie basse des registres xmm0 à xmm7

; Le retour d'une valeur entière se fait dans le registre rax
; Le retour d'un flotant se fait dans la partie basse du registre xmm0

; Les registres qui ne doivent pas être modifiés par la sous-fonction : rbp, rbx, r12 à r15

; float procedure(int* tab, int n)

; Si la pile n'est pas utilisée, le prologue et l'épilogue peuvent être supprimés (seul l'instruction ret reste)

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
