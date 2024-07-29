#include <stdio.h>
#include <math.h>

// Déclaration de la fonction assembleur
extern float calcul_asm(float x);
extern float calcul_asm_opti(float x);

float calcul_c(float x) {
    return (((x-5) * (x+6)) / (cos(x-5)*cos(x-5))) * sin(x+6);
}

int main() {

    float x = 1.2;

    printf("f_c(%.1f) = %f\n", x, calcul_c(x));
    printf("f_asm(%.1f) = %f\n", x, calcul_asm(x));
    printf("f_asm(%.1f) = %f\n", x, calcul_asm_opti(x));

    return 0;
}
