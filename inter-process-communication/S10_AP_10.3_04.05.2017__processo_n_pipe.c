//
// Analisar o código e descrever como os processos interagem e trocam as mensagens!
//
#include <sys/types.h>
#include <signal.h>
#include <unistd.h>
#define READ 0  // stdin(0)
#define WRITE 1 // stdout(1)
                // stderr(2)

#define NP 5 
#define VAL 20

main() {
  pid_t proc[ NP ];
  int fd[ NP ][ 2 ], 
      np, val, i;

  for( np = 0; np < NP; np++ )
     pipe( fd[ np ] );
  
  for( np = 0; np < NP; np++) {
    if( (proc[ np ] = fork() ) == 0 ) {
      for( i = 0; i < NP; i++) {
         if( i != np )             close( fd[ i ][ WRITE ] );
 	 if( i != (np-1+NP) % NP ) close( fd[ i ][ READ  ] );
      }
      if( np == 0 ) {
        val = 1;
        printf( "Filho 1(%d):\t1\n", getpid() );
        write( fd[ np ][ WRITE ], &val, sizeof(int) );
      }
      while( read( fd[ (np-1+NP) % NP ][ READ ], &val, sizeof(int) ) ) {
        if( val == VAL ) break;
        val++;
	printf( "Filho %d(%d):\t%d\n", np+1, getpid(), val );
        write( fd[ np ][ WRITE ], &val, sizeof(int) );
      }
      close( fd[ np ][ WRITE ]);
      close( fd[ (np-1+NP) % NP ][ READ ]);
      exit(0);
    }
  }
  wait(&val);
}

