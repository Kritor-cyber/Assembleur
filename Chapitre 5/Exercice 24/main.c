#include <stdio.h>

int main() {
    
    const int N = 1005;
    int tab[N];

    // Pour i allant de 0 à N - (N % 4) <=> N & ~4
    /*
    * Par exemple si N = 7, alors N & ~4 = 4, ainsi la boucle fera pour i entre 0 et 3
    * Sans cette modification la boucle fera deux itérations, la première pour 0 à 3 et la suivante de 4 à 7
    * Or la limite supérieure est à 7 exclus
    */
    int i;
    for (i = 0; i < (N & ~4); i += 4) {
        tab[i] = i;
        tab[i+1] = i+1;
        tab[i+2] = i+2;
        tab[i+3] = i+3;
    }

    // Ici je traite les derniers indices du tableau précédemment ignorés
    // while (i < N) {
    //     tab[i] = i;
    //     i++;
    // }

    // for (i = 0; i < N; i++) {
    //     if (tab[i] != i) {
    //         printf("ERREUR, tab[i] != i => %d != %d\n", tab[i], i);
    //     }
    // }
for (i = 0; i < N; i++) {
    printf("tab[%4d] = %d\n", i, tab[i]);
}
printf("%d %d %d\n", N, ~4, N & ~4);
    return 0;
}