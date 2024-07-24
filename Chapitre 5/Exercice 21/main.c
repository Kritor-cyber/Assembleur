#include <stdio.h>

#define N 256

// Déclaration de la fonction assembleur
extern int compare_asm_v1(int a, int b, int c);
extern int compare_asm_v2(int a, int b, int c);

int compare_c_v1(int x, int y, int z) {
    if ((((x % 2) == 0) && (y < 257)) || (z == 9)) {
        return x + y - z;
    }

    return x;
}

int compare_c_v2(int x, int y, int z) {

    int y1 = y & ((z != 9) - 1);
    int z1 = z & ((z != 9) - 1);

    int y2 = y & ((x % 2 != 0) -1);
    int z2 = z & ((x % 2 != 0) -1);

    y2 = y2 & ((y >= 257) - 1);
    z2 = z2 & ((y >= 257) - 1);

    return x + (y1 | y2) - (z1 | z2);
}

int main() {

    unsigned int x, y, z;
    
    for (x = 0; x < N; x++) {
        for (y = 0; y < N; y++) {
            for (z = 0; z < N; z++) {
                if (compare_asm_v1(x, y, z) != compare_c_v1(x, y, z)) {
                    printf("ERREUR avec %d, %d, %d\n", x, y, z);
                    return -1;
                }

                if (compare_c_v1(x, y, z) != compare_c_v2(x, y, z)) {
                    printf("ERREUR avec %d, %d, %d\n", x, y, z);
                    return -2;
                }


                if (compare_asm_v1(x, y, z) != compare_asm_v2(x, y, z)) {
                    printf("ERREUR avec %d, %d, %d\n", x, y, z);
                    return -3;
                }
            }
        }
    }

    printf("Aucune erreur, exercice validé !\n");

    return 0;
}