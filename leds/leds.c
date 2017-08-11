//
// Programa LEDS.C
//

// Pesquisar sobre: 
//	- ioperm()
//	- setuid()
//	- outb()
//	- inb()
//	- controlador do teclado: 
//		- http://www.brokenthorn.com/Resources/OSDev19.html

#include <stdio.h>
#include <stdlib.h>
#include <sys/io.h>
#include <errno.h>
#include <string.h>

#define R 1	// scroll lock
#define L 2	// numlock
#define M 4	// caps lock

#define PORTA_BASE  0x60
#define QTD_PORTAS    5
#define ON	1
#define OFF	0

#define VEZES	3

void setLeds( unsigned char );
void erro( char * );

int main( int argc, char **argv )
{
	unsigned char led, i;

	fprintf( stdout, "Testando os leds do teclado!\n\nOLHE!!!\n\n" );

	setuid( 0 ); 	//  acertar prioridade -- TALVEZ PRECISE ROOT

	if( ioperm( PORTA_BASE, QTD_PORTAS, ON ) ) 
		erro( "Falha no ioperm de acesso!" );
	for( i = 0; i < VEZES; ++i) {
		setLeds( L );
		sleep( 1 );
		setLeds( M );
		sleep( 1 );
		setLeds( R );
		sleep( 1 );
	}
	if( ioperm( PORTA_BASE, QTD_PORTAS, OFF ) ) 
		erro( "Falha no ioperm de fechamento!" );
	fprintf( stdout, "... Gostou?\n\n" );
	exit( 0 );
}
	
void setLeds( unsigned char led )
{
	outb( 0xED, PORTA_BASE );
	while( (inb( PORTA_BASE + 4 ) & 2)  )
		;
	outb( led, PORTA_BASE );
	while( (inb( PORTA_BASE + 4 ) & 2)  )
		;
	usleep( 1500 );
}

void erro( char *msg )
{
	fprintf( stderr, "\nERRO: %s (%d)\n%s\n\n", msg, errno, strerror( errno ) );
	exit( 1 );
}
