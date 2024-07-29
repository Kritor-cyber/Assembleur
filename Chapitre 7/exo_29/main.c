#include <stdio.h>
#include <math.h>

// Déclaration de la fonction assembleur
extern float my_abs(float nb);
extern float my_chs(float nb);

int main() {

    for (float a = -1000; a <= 1000; a += 0.1) {
        if (my_abs(a) != fabs(a)) {
            printf("Erreur ABS\n");
            return -1;
        }
        if (my_chs(a) != -a) {
            printf("Erreur CHS\n");
            return -1;
        }
    }

    printf("Fonctions validées !\n");

    return 0;
}
