#include <stdio.h>

// Déclaration de la fonction assembleur
extern void itoa_asm(float* t, int n);

void itoa_c(float *t, int n) {
    for (int i = 0; i < n; i++) {
        t[i] = (float) i;
    }
}

#define N 10

int main() {

    float tab_c[N];
    float tab_asm[N];

    itoa_c(tab_c, N);
    itoa_asm(tab_asm, N);

    for (int i = 0; i < N; i++) {
        if (tab_c[i] != tab_asm[i]) {
            printf("ERREUR, tab_c[%d] = %f et tab_asm[%d] = %f\n", i, tab_c[i], i, tab_asm[i]);
            return -1;
        }
    }

    printf("Fonction validée\n");

    return 0;
}
