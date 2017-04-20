#include <stdio.h>
int main( void ) {
    int ID = -9999;
    printf("ANTES: %d\n", ID );
    ID = fork();
    printf("DEPOIS: %d\n", ID );
    return 0;
}
