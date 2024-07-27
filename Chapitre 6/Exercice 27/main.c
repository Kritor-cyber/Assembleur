#include <stdio.h>
#include <math.h>

// Déclaration de la fonction assembleur
//extern float procedure_asm(int *tab, int n);
extern float procedure_asm(int *tab, int n);

float procedure_c(int *tab, int n) {
    float sum = 0;
    for (int i = 0; i < n; i++) {
        tab[i] = tab[i] / 2;
        sum += tab[i] * 1.25;
    }

    return sqrtf(sum);
}

#define N 10

int main() {

    int tab[N];

    for (int i = 0; i < N; i++) {
        tab[i] = i * 2 + 1;
    }

    float res1, res2;

    res1 = procedure_c(tab, N);
    printf("Résultat : %f\n", res1);
    for (int i = 0; i < N; i++) {
        printf("tab[%d] = %d\n", i, tab[i]);
    }

    for (int i = 0; i < N; i++) {
        tab[i] = i * 2 + 1;
    }
    res2 = procedure_asm(tab, N);
    printf("Résultat : %f\n", res2);
    for (int i = 0; i < N; i++) {
        printf("tab[%d] = %d\n", i, tab[i]);
    }

    if (res1 != res2) {
        printf("Code assembleur INCORRECT !\n");
    } else {
        printf("Code assembleur correct !!!\n");
    }

    return 0;
}
