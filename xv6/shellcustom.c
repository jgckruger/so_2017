#include "types.h"

#include "user.h"

#define NULL 0

char *
strtok(s, delim)
	register char *s;
	register const char *delim;
{
	register char *spanp;
	register int c, sc;
	char *tok;
	static char *last;


	if (s == NULL && (s = last) == NULL)
		return (NULL);

	/*
	 * Skip (span) leading delimiters (s += strspn(s, delim), sort of).
	 */
cont:
	c = *s++;
	for (spanp = (char *)delim; (sc = *spanp++) != 0;) {
		if (c == sc)
			goto cont;
	}

	if (c == 0) {		/* no non-delimiter characters */
		last = NULL;
		return (NULL);
	}
	tok = s - 1;

	/*
	 * Scan token (scan for delimiters: s += strcspn(s, delim), sort of).
	 * Note that delim must have one NUL; we stop if we see that, too.
	 */
	for (;;) {
		c = *s++;
		spanp = (char *)delim;
		do {
			if ((sc = *spanp++) == c) {
				if (c == 0)
					s = NULL;
				else
					s[-1] = 0;
				last = s;
				return (tok);
			}
		} while (sc != 0);
	}
	/* NOTREACHED */
}

int main( void )
{
 char lc[ 81 ];
 char *argv[ 20 ];
 int pid, i;

 while( 1 ) {
 	printf(1, "Prompt > " );
	gets( lc , 81);
	if( ! strcmp( lc, "" ) )
 		continue;
	lc[strlen(lc)-1]=0;
 	argv[ 0 ] = strtok( lc, " " );
 	if( ! strcmp( argv[ 0 ], "exit" ) )
 		exit(  );
	i = 1;
	while( i < 20 && (argv[ i ] = strtok( 0, " " )) )
		 ++i;
	if( (pid = fork()) == -1 ) {
		 printf(2, "Erro no fork\n" );
		 exit(  );
	}
	if( pid == 0 )
	if( exec( argv[ 0 ], argv ) ) {
		printf(2, "Erro no execv\n" );
		exit(  );
 	}
	 wait();
 }
}

