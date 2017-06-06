#include <stdio.h>
#include <unistd.h>
//
// comando:
// $ls –la | wc
//
int main(void){
  int pfd[2];
  pipe( pfd );
  switch( fork() ){
    case -1: exit(1);
    break;
    case 0:
    close( 0 );
    //dup( pfd[ 0 ] );
    close( pfd[ 1 ] );
    close( pfd[ 0 ] );
    execl( "/usr/bin/wc", "wc", 0 );
    break;
  }
  switch( fork() ) {
    case -1: exit(1);
    break;
    case 0:
    // close( 1 );
    // dup( pfd[ 1 ] );
    close( pfd[ 0 ] );
    close( pfd[ 1 ] );
    execl( "/bin/ls", "ls", "-la", 0);
    break;
  }
  return 0;
}
