//
// Programa com o uso de thread
// Compilar com gcc ex_thread.c -l pthread -o ex_thread
//
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

pthread_mutex_t count_mutex = PTHREAD_MUTEX_INITIALIZER;
int                       x = 0;

void *mythread( void * );

int main( void )
{
   pthread_t tids[ 11 ];
   int        i;

   for( i = 0; i < 10; ++i )
      pthread_create( &tids[ i ], NULL, mythread, NULL );

   for( i = 0; i < 10; ++i ) {
      pthread_join( tids[ i ], NULL );
      printf( "A thread ID: %ld retornou!\n", tids[ i ] );
   }
   return 1;
}

void *mythread( void *data )
{
//
// Aumente o valor de 200 para 2000 para verificar a a��o do escalonador!
//
   while( x < 2000 ) {
      pthread_mutex_lock( &count_mutex );
      ++x;
      pthread_mutex_unlock( &count_mutex );
      printf( "Na thread ID %ld: X vale: %d.\n", pthread_self(), x );
   }
   pthread_exit( NULL );
}
