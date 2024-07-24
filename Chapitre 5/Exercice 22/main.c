#include <stdio.h>

int main() {
    const int SIZE = 1000;
    int tab[SIZE];

    for (int i = 0; i < SIZE; ++i) {
        tab[i] = (i + 1) % 7;
    }

    for (int i = 0; i < SIZE; i++) {
        printf("%d\n", tab[i]);
    }

    return 0;
}