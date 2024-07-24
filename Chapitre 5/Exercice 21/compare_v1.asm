section .text
global compare_asm_v1           ; Nom de la fonction accessible depuis les autres fichiers sources

compare_asm_v1:
    ; Prologue de la fonction
    push    ebp
    mov     ebp, esp

    ; Corps de la fonction
    ; le premier argument (x de type entier) se trouve à l'adresse [ebp+8]
    ; le  second argument (y de type entier) se trouve à l'adresse [ebp+12]
    ; le dernier argument (z de type entier) se trouve à l'adresse [ebp+16]

    mov     eax, [ebp+8]    ; copie de la valeur de x dans le registre eax
    test    eax, 1          ; si le bit de poids faible n'est pas 1, alors il s'agit d'un nombre pair
    ; Rappel sur l'instruction test : elle permet de comparer deux valeurs en réalisant un and entre les deux opérandes qui ne seront pas modifiées et dont le résultat sera propagé au niveau du registre flags

    ; Souhaitant sauter à la condition suivante lorsque x est impair, j'utilise l'instruction jnz (jump on not zero), j'aurais pu utiliser jne (jump on not equal)
    jnz      .impair

    ; Je compare maintenant le second argument avec 257
    cmp [ebp+12], dword 257
    ; Lorsque y est inférieur à 257 je souhaite sauter à l'instruction du calcul, j'utilise donc l'instruction jl (jump on less)
    jl .calcul

; Ici se trouve la deuxième condition de l'exercice (z == 9)
.impair:
    ; Je compare la valeur du troisième argument avec 9
    cmp [ebp+16], dword 9
    ; Si les deux valeurs ne sont pas égales, je saute à la fin de la fonction et le calcul ne sera pas effectué.
    jne .end

; Le registre eax contient toujours la valeur de x, je lui ajoute donc la valeur de y puis je lui soustrais la valeur de z
.calcul:
    add eax, [ebp+12]
    sub eax, [ebp+16]

; La valeur retournée par la fonction se trouve dans le registre eax, donc la valeur est déjà prête
.end:
    ; Épilogue de la fonction
    mov     esp, ebp
    pop     ebp
    ret