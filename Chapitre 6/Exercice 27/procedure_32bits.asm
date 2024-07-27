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
