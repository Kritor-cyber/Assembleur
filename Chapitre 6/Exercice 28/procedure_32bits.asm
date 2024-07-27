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
    ret                     ; retourner de la fonction
