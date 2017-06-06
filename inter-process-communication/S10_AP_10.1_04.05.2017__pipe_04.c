#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
//#define DEBUG 1

//
//  comando:
//       $       cat /etc/passwd | grep home | wc
//
//   PROBLEMA:  como criar redirecionamento de/para arquivos:    cat /etc/passwd >  meu_arquivo_1
//                                                               grep home < meu_arquivo_1 > meu_arquivo_2
//                                                               wc < meu_arquivo_2
//
//
int main(void){
  int pfd_0[2],
      pfd_1[2],
      status;

  pipe( pfd_0 ); // cria pipe 1
  pipe( pfd_1 ); // cria pipe 2

#ifdef DEBUG
  printf( "PAI: pfd_0[%d:%d]\t-\tpfd_1[%d:%d]\n\n", pfd_0[0],pfd_0[1],pfd_1[0],pfd_1[1] );
#endif
//   switch( fork() ){
//     case -1: exit(1); // se falhou no fork
//              break;
//     case 0: // se filho wc
// #ifdef DEBUG
//     printf( "FILHO 1: pfd_0[%d:%d]\t-\tpfd_1[%d:%d]\n\n", pfd_0[0],pfd_0[1],pfd_1[0],pfd_1[1] );
// #endif
//              close( 0 );            // fecha descritor stdin (0)
//              dup2( pfd_0[ 0 ], 0 ); // redireciona do stdout pro descritor de entrada do pipe 1
//              close( pfd_0[ 0 ] );   // fecha o pipe 1 fim
//              close( pfd_0[ 1 ] );   // fecha o pipe 1 começo
//              close( pfd_1[ 0 ] );   // fecha o pipe 2 fim
//              close( pfd_1[ 1 ] );   // fecha o pipe 2 começo
//              execl( "/usr/bin/wc", "wc", 0 );  // como colocar parametro para contar linhas apenas?
//              // usa stdin(agora pipe 1 [0])
//              break;
//   }

  switch( fork() ){
    case -1: exit(1);
             break;
    case 0: // se filho grep
#ifdef DEBUG
   printf( "FILHO 2: pfd_0[%d:%d]\t-\tpfd_1[%d:%d]\n\n", pfd_0[0],pfd_0[1],pfd_1[0],pfd_1[1] );
#endif
             close( 0 );        // fecha descritor stdin
             dup2( pfd_1[ 0 ], 0 ); // redireciona stdin pro descritor de saida do pipe 2
             close( 1 ); // fecha descritor stdout
             dup2( pfd_0[ 1 ], 1 ); // redireciona stdin pra saida do pipe 1
             close( pfd_0[ 0 ] ); // fecha pipe 1 entrada
             close( pfd_0[ 1 ] ); // fecha pipe 1 saida
             close( pfd_1[ 0 ] ); // fecha pipe 2 entrada
             close( pfd_1[ 1 ] ); // fecha pipe 2 saida
             execl( "/bin/grep", "grep", "home", 0 ); // manda sair pelo pipe
             break;
  }


  switch( fork() ) {
    case -1: exit(1);
             break;
    case 0:
#ifdef DEBUG
   printf( "FILHO 3: pfd_0[%d:%d]\t-\tpfd_1[%d:%d]\n\n", pfd_0[0],pfd_0[1],pfd_1[0],pfd_1[1] );
#endif
             close( 1 ); // fecha stdout
             dup2( pfd_1[ 1 ], 1 ); // redireciona do stdout pro pipe 1 entrada
             close( pfd_0[ 0 ] ); // fecha pipe 0 entrada
             close( pfd_0[ 1 ] ); // fecha pipe 0 saida
             close( pfd_1[ 0 ] ); // fecha pipe 1 entrada
             close( pfd_1[ 1 ] ); // fecha pipe 1 saida
             execl( "/bin/cat", "cat", "/etc/passwd", 0); // roda cat
             break;
  }


  wait(&status);
  return 0;
}
