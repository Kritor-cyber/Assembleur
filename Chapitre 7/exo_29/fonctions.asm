section .text
global my_abs   ; rendre la fonction accessible depuis l'extérieur
global my_chs

; extern float my_abs(float nb)
my_abs:
    ; Prologue de la fonction
    push    ebp         ; sauvegarde de l'ancien base pointer
    mov     ebp, esp    ; esp devient le nouveau base pointer

    and     dword [ebp + 8], 0x7FFFFFFF     ; Je conserve la valeur de tous les bits sauf du premier qui vaut toujours 0
    fld     dword [ebp + 8]                 ; Je charge la valeur dans le registre st0 pour le retour

    ; Épilogue de la fonction
    mov     esp, ebp        ; restaurer l'ancien esp
    pop     ebp             ; restaurer l'ancien base pointer
    ret                     ; retourner de la fonction

; extern float my_chs(float nb)
my_chs:
    ; Prologue de la fonction
    push    ebp
    mov     ebp, esp

    xor     dword [ebp + 8], 0x80000000     ; Inversion de la valeur du bit de poids le plus fort
    fld     dword [ebp + 8]                 ; Je charge la valeur dans le registre st0 pour le retour

    ; Epilogue de la fonction
    mov     esp, ebp
    pop     ebp
    ret
