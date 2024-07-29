section .text
global puissance_asm_32

puissance_asm_32:
        ; Prologue
        push    ebp
        mov     ebp, esp

        mov     eax, [ebp + 12]         ; eax = n

        fld     dword [ebp + 8]         ; st0 = x
        fld1                            ; st0 = 1 et st1 = x

        cmp     eax, 0                  ; Si n <= 0
        jle     .end                    ; Alors retourne 1.0

.boucle:
        test    eax, eax                ; Si eax = 0
        jz      .end                    ; Fin du calcul, retour de st0

        fmul    st1                     ; st0 *= st1 (x)

        sub     eax, 1                  ; eax--
        jmp     .boucle                 ; Nouvelle itération

.end:
        fstp                            ; Libération de st1
        ; Epilogue
        mov     esp, ebp
        pop     ebp
        ret
