#include <stdio.h>
#include <math.h>

// Déclaration de la fonction assembleur
extern double procedure_asm(double *tab, int n, double k);

double procedure_c(double *tab, int n, double k) {
    double sum = 0;

    for (int i = 0; i < n; ++i) {
        sum += tab[i] / k;
    }

    sum = sqrt(sum);

    return sum;
}

#define N 10

int main() {

    double tab[N];

    for (int i = 0; i < N; i++) {
        tab[i] = i * 2.2 + 1.5;
    }

    double res1 = procedure_c(tab, N, 1.2);
    printf("Résultat : %f\n", res1);
    for (int i = 0; i < N; i++) {
        printf("tab[%d] = %f\n", i, tab[i]);
    }

    double res2 = procedure_asm(tab, N, 1.2);
    printf("Résultat : %f\n", res2);
    for (int i = 0; i < N; i++) {
        printf("tab[%d] = %f\n", i, tab[i]);
    }

    if (res1 != res2) {
        printf("Code assembleur INCORRECT !\n");
    } else {
        printf("Code assembleur correct !!!\n");
    }

    return 0;
}
