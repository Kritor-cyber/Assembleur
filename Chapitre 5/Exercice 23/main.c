#include <stdio.h>

extern int puissance2deux_asm(int nb);
extern int idBitSignificatif_1_asm(int nb);
extern int idBitSignificatif_2_asm(int nb);
extern int nombreBits1_asm(unsigned int nb);

int puissance2deux_c(int nb) {
    if (nb == 0)
        nb = 3;

    return nb & (nb - 1);
}

int idBitSignificatif_1_c(int nb) {
    int i = 32;
    while (i >= 0) {
        if (nb & 0b10000000000000000000000000000000) {
            return i;
        }
        i--;
        nb = nb << 1;
    }

    return 0;
}

int idBitSignificatif_2_c(int nb) {
    int indice = 0;
    int puissance = 2;

    while (1) {
        if (nb < puissance) return indice;
        indice++;
        puissance = puissance << 1;
    }
}

int nombreBits1_c(unsigned int nb) {
    int nb1 = 0;

    while (nb > 0) {
        nb1 += nb % 2;
        nb = nb >> 1;
    }

    return nb1;
}

int main() {
    
    int indiceBitSignificatif = 0;

    for (int i = 0; i <= 1024; i++) {
        if (puissance2deux_c(i) != puissance2deux_asm(i)) {
            printf("Erreur puissance2deux à %d, %d != %d\n", i, puissance2deux_c(i), puissance2deux_asm(i));
            return -1;
        }
        if (puissance2deux_asm(i) == 0) {
            printf("%d\n", i);
        }

        if (idBitSignificatif_1_c(i) != idBitSignificatif_1_asm(i)) {
            printf("Erreur id bit significatif (1) à %d, %d != %d\n", i, idBitSignificatif_1_c(i), idBitSignificatif_1_asm(i));
            return -1;
        }

        if (idBitSignificatif_2_c(i) != idBitSignificatif_2_asm(i)) {
            printf("Erreur id bit significatif (2) à %d, %d != %d\n", i, idBitSignificatif_2_c(i), idBitSignificatif_2_asm(i));
            return -1;
        }

        if (nombreBits1_c(i) != nombreBits1_asm(i)) {
            printf("Erreur nombre bits à %d, %d != %d\n", i, nombreBits1_c(i), nombreBits1_asm(i));
            return -1;
        }
    }

    return 0;
}