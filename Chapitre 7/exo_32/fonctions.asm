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
