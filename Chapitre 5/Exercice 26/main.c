#include <stdio.h>

extern int zero_un_moins_un_asm(int x);

int zero_un_moins_un_c(int x) {
    if (x < 0) {
        return -1;
    } else if (x > 1) {
        return 1;
    } else {
        return 0;
    }
}

int main() {
    int i, tmp = 0;

    for (unsigned int j = 0; j < 1000000; j++) {
        for (i = -1024; i < 1024; i++) {
            tmp += zero_un_moins_un_c(i);
        }
    }

    return tmp;
}
