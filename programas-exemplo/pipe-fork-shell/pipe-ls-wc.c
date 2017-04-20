#include <stdio.h>
int main(void){
  int pid, pfd[2];
  char l[ 20 ];
  pipe( pfd );
  pid = fork();
  printf( "%d:%d\n", pfd[ 0 ], pfd[ 1 ] );
  switch( pid ){
    case -1:
      exit(1);
      break;
    case 0:
      close( pfd[ 0 ] );
      write( pfd[ 1 ], "ALO MUNDO", 10 );
      break;
    default: 
      close( pfd[ 1 ] );
      read( pfd[ 0 ], l, 6 );
      printf( "%s", l );
      break;
  }
  return 0;
}
