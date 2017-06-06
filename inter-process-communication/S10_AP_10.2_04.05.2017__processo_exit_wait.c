//
//  Analisar o código e descrever como um processo filho devolve um valor ao processo pai.
//
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#define eh_filho(P) P == 0

void sinc_fib10( void );

int main() {
  sinc_fib10();
  exit(0);
}

void sinc_fib10( void ) 
{
  pid_t pid;                                       
  int status;                                          
                                                         
  pid = fork();                                     
  if( eh_filho( pid ) ) {
    printf( "Processo filho (%d) do processo (%d) vai calcular o fibonacci de 10\n", getpid(), getppid() );
    exit( fibonacci( 10 ) ); 
  } else {
    wait( &status );
    if( WIFEXITED(status) ) {
       printf( "\nPAI(%d): fib(10) = %d\n", getpid(), WEXITSTATUS(status) );
    } else {
       printf("\nProcesso filho (%d) nao terminou normalmente!\n\n", pid);
    }
  }
  return;
}

int fibonacci( int n )        
{                             
    if( n == 0 ) return 1;       
    if( n == 1 ) return 1;       
    return fibonacci( n-1 ) + fibonacci( n-2 );
}                             


