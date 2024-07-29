#include <stdio.h>
#include <math.h>

extern float puissance_asm_64(float x, int n);

float puissance_c(float x, int n) {
    float result = 1;
    for (int i=0; i<n; ++i) {
        result *= x;
    }
    return result;
}

int main() {

    float x = 1.2;
    int e = -5;

    printf("%.1f ^ %d = %f\n", x, e, puissance_c(x, e));
    printf("%.1f ^ %d = %f\n", x, e, puissance_asm_64(x, e));

    e = 5;

    printf("%.1f ^ %d = %f\n", x, e, puissance_c(x, e));
    printf("%.1f ^ %d = %f\n", x, e, puissance_asm_64(x, e));

    return 0;
}
