section .data

    cinq: dd 5.0
    six:  dd 6.0

section .text
global calcul_asm
global calcul_asm_opti

; extern float calcul_asm(float x)
calcul_asm:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    fld     dword [ebp + 8]
    fld     dword [cinq]
    fsubp

    fld     dword [ebp + 8]
    fld     dword [six]
    faddp

    fmulp

    fld     dword [ebp + 8]
    fld     dword [cinq]
    fsubp
    fcos
    fmul    st0

    fdivp

    fld     dword [ebp + 8]
    fld     dword [six]
    faddp
    fsin

    fmulp


    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction

; extern float calcul_asm_opti(float x)
calcul_asm_opti:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    sub     esp, 16

    fld     dword [ebp + 8]
    fld     dword [cinq]
    fsubp
    fst     qword [esp]     ; Chargement de x - 5 dans la première variable locale (loc1)
    ; Utilisation de qword pour ne pas perdre d'informations

    fld     dword [ebp + 8]
    fld     dword [six]
    faddp
    fst     qword [esp + 8] ; Chargement de x + 6 dans la deuxième variable locale (loc2)

    fmulp

    fld     qword [esp]     ; Chargement de loc1 (x - 5)
    fcos
    fmul    st0

    fdivp

    fld     qword [esp + 8] ; Chargement de loc2 (x + 6)
    fsin

    fmulp


    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction
