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

; Si la pile n'est pas utilisée, le prologue et l'épilogue peuvent être supprimés (seul l'instruction ret reste)

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
