/***************************************************************
  DISCIPLINA: 203065 - Sistemas Operacionais 

  Shell para execução de comandos simples;
     - Esse código roda em Linux;
     - O que fazer para portar para o Xv6?
		- ver código do sh.c

***************************************************************/

#include <stdlib.h>
#include <string.h>

int main( void )
{
 char lc[ 81 ];
 char *argv[ 20 ];
 int pid, i, status;

 while( 1 ) {
 	printf( "Prompt > " );
	gets( lc );
	if( ! strcmp( lc, "" ) )
 		continue;
 	argv[ 0 ] = strtok( lc, " " );
 	if( ! strcmp( argv[ 0 ], "exit" ) )
 		exit( 0 );
	i = 1;
	while( i < 20 && (argv[ i ] = strtok( NULL, " " )) )
		 ++i;
	if( (pid = fork()) == -1 ) {
		 printf( "Erro no fork\n" );
		 exit( 1 );
	}
	if( pid == 0 )
	if( execvp( argv[ 0 ], argv ) ) {
		printf( "Erro no execv\n" );
		exit( 1 );
 	}
	 wait( &status );
 }
}
