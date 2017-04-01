
_shellsimples: formato do arquivo elf32-i386


Desmontagem da seção .text:

00000000 <strtok>:

char *
strtok(s, delim)
	register char *s;
	register const char *delim;
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	57                   	push   %edi
   4:	56                   	push   %esi
   5:	53                   	push   %ebx
   6:	83 ec 10             	sub    $0x10,%esp
   9:	8b 45 08             	mov    0x8(%ebp),%eax
   c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	register int c, sc;
	char *tok;
	static char *last;


	if (s == NULL && (s = last) == NULL)
   f:	85 c0                	test   %eax,%eax
  11:	75 10                	jne    23 <strtok+0x23>
  13:	a1 3c 0c 00 00       	mov    0xc3c,%eax
  18:	85 c0                	test   %eax,%eax
  1a:	75 07                	jne    23 <strtok+0x23>
		return (NULL);
  1c:	b8 00 00 00 00       	mov    $0x0,%eax
  21:	eb 7c                	jmp    9f <strtok+0x9f>

	/*
	 * Skip (span) leading delimiters (s += strspn(s, delim), sort of).
	 */
cont:
	c = *s++;
  23:	89 c2                	mov    %eax,%edx
  25:	8d 42 01             	lea    0x1(%edx),%eax
  28:	0f b6 12             	movzbl (%edx),%edx
  2b:	0f be f2             	movsbl %dl,%esi
	for (spanp = (char *)delim; (sc = *spanp++) != 0;) {
  2e:	89 cf                	mov    %ecx,%edi
  30:	eb 06                	jmp    38 <strtok+0x38>
		if (c == sc)
  32:	39 de                	cmp    %ebx,%esi
  34:	75 02                	jne    38 <strtok+0x38>
			goto cont;
  36:	eb eb                	jmp    23 <strtok+0x23>
	/*
	 * Skip (span) leading delimiters (s += strspn(s, delim), sort of).
	 */
cont:
	c = *s++;
	for (spanp = (char *)delim; (sc = *spanp++) != 0;) {
  38:	89 fa                	mov    %edi,%edx
  3a:	8d 7a 01             	lea    0x1(%edx),%edi
  3d:	0f b6 12             	movzbl (%edx),%edx
  40:	0f be da             	movsbl %dl,%ebx
  43:	85 db                	test   %ebx,%ebx
  45:	75 eb                	jne    32 <strtok+0x32>
		if (c == sc)
			goto cont;
	}

	if (c == 0) {		/* no non-delimiter characters */
  47:	85 f6                	test   %esi,%esi
  49:	75 11                	jne    5c <strtok+0x5c>
		last = NULL;
  4b:	c7 05 3c 0c 00 00 00 	movl   $0x0,0xc3c
  52:	00 00 00 
		return (NULL);
  55:	b8 00 00 00 00       	mov    $0x0,%eax
  5a:	eb 43                	jmp    9f <strtok+0x9f>
	}
	tok = s - 1;
  5c:	8d 50 ff             	lea    -0x1(%eax),%edx
  5f:	89 55 f0             	mov    %edx,-0x10(%ebp)
	/*
	 * Scan token (scan for delimiters: s += strcspn(s, delim), sort of).
	 * Note that delim must have one NUL; we stop if we see that, too.
	 */
	for (;;) {
		c = *s++;
  62:	89 c2                	mov    %eax,%edx
  64:	8d 42 01             	lea    0x1(%edx),%eax
  67:	0f b6 12             	movzbl (%edx),%edx
  6a:	0f be f2             	movsbl %dl,%esi
		spanp = (char *)delim;
  6d:	89 cf                	mov    %ecx,%edi
		do {
			if ((sc = *spanp++) == c) {
  6f:	89 fa                	mov    %edi,%edx
  71:	8d 7a 01             	lea    0x1(%edx),%edi
  74:	0f b6 12             	movzbl (%edx),%edx
  77:	0f be da             	movsbl %dl,%ebx
  7a:	39 f3                	cmp    %esi,%ebx
  7c:	75 1b                	jne    99 <strtok+0x99>
				if (c == 0)
  7e:	85 f6                	test   %esi,%esi
  80:	75 07                	jne    89 <strtok+0x89>
					s = NULL;
  82:	b8 00 00 00 00       	mov    $0x0,%eax
  87:	eb 06                	jmp    8f <strtok+0x8f>
				else
					s[-1] = 0;
  89:	8d 50 ff             	lea    -0x1(%eax),%edx
  8c:	c6 02 00             	movb   $0x0,(%edx)
				last = s;
  8f:	a3 3c 0c 00 00       	mov    %eax,0xc3c
				return (tok);
  94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  97:	eb 06                	jmp    9f <strtok+0x9f>
			}
		} while (sc != 0);
  99:	85 db                	test   %ebx,%ebx
  9b:	75 d2                	jne    6f <strtok+0x6f>
	}
  9d:	eb c3                	jmp    62 <strtok+0x62>
	/* NOTREACHED */
}
  9f:	83 c4 10             	add    $0x10,%esp
  a2:	5b                   	pop    %ebx
  a3:	5e                   	pop    %esi
  a4:	5f                   	pop    %edi
  a5:	5d                   	pop    %ebp
  a6:	c3                   	ret    

000000a7 <main>:

#include "strtok.c"


int main( void )
{
  a7:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  ab:	83 e4 f0             	and    $0xfffffff0,%esp
  ae:	ff 71 fc             	pushl  -0x4(%ecx)
  b1:	55                   	push   %ebp
  b2:	89 e5                	mov    %esp,%ebp
  b4:	51                   	push   %ecx
  b5:	81 ec b4 00 00 00    	sub    $0xb4,%esp
 char lc[ 81 ];
 char *argv[ 20 ];
 int pid, i;

 while( 1 ) {
 	printf(1, "Prompt > " );
  bb:	83 ec 08             	sub    $0x8,%esp
  be:	68 7d 09 00 00       	push   $0x97d
  c3:	6a 01                	push   $0x1
  c5:	e8 fd 04 00 00       	call   5c7 <printf>
  ca:	83 c4 10             	add    $0x10,%esp
	gets( lc , 81);
  cd:	83 ec 08             	sub    $0x8,%esp
  d0:	6a 51                	push   $0x51
  d2:	8d 45 9f             	lea    -0x61(%ebp),%eax
  d5:	50                   	push   %eax
  d6:	e8 27 02 00 00       	call   302 <gets>
  db:	83 c4 10             	add    $0x10,%esp
	if( ! strcmp( lc, "" ) )
  de:	83 ec 08             	sub    $0x8,%esp
  e1:	68 87 09 00 00       	push   $0x987
  e6:	8d 45 9f             	lea    -0x61(%ebp),%eax
  e9:	50                   	push   %eax
  ea:	e8 60 01 00 00       	call   24f <strcmp>
  ef:	83 c4 10             	add    $0x10,%esp
  f2:	85 c0                	test   %eax,%eax
  f4:	0f 84 f9 00 00 00    	je     1f3 <main+0x14c>
 		continue;
	lc[strlen(lc)-1]=0; // tamanho da string -1 (começa no 0) deve ser nulo pra tirar o \n
  fa:	83 ec 0c             	sub    $0xc,%esp
  fd:	8d 45 9f             	lea    -0x61(%ebp),%eax
 100:	50                   	push   %eax
 101:	e8 88 01 00 00       	call   28e <strlen>
 106:	83 c4 10             	add    $0x10,%esp
 109:	83 e8 01             	sub    $0x1,%eax
 10c:	c6 44 05 9f 00       	movb   $0x0,-0x61(%ebp,%eax,1)
 	argv[ 0 ] = strtok( lc, " " );
 111:	83 ec 08             	sub    $0x8,%esp
 114:	68 88 09 00 00       	push   $0x988
 119:	8d 45 9f             	lea    -0x61(%ebp),%eax
 11c:	50                   	push   %eax
 11d:	e8 de fe ff ff       	call   0 <strtok>
 122:	83 c4 10             	add    $0x10,%esp
 125:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
 	if( ! strcmp( argv[ 0 ], "exit" ) )
 12b:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
 131:	83 ec 08             	sub    $0x8,%esp
 134:	68 8a 09 00 00       	push   $0x98a
 139:	50                   	push   %eax
 13a:	e8 10 01 00 00       	call   24f <strcmp>
 13f:	83 c4 10             	add    $0x10,%esp
 142:	85 c0                	test   %eax,%eax
 144:	75 05                	jne    14b <main+0xa4>
 		exit(  );
 146:	e8 05 03 00 00       	call   450 <exit>
	i = 1;
 14b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
	while( i < 20 && (argv[ i ] = strtok( 0, " " )) )
 152:	eb 04                	jmp    158 <main+0xb1>
		 ++i;
 154:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
	lc[strlen(lc)-1]=0; // tamanho da string -1 (começa no 0) deve ser nulo pra tirar o \n
 	argv[ 0 ] = strtok( lc, " " );
 	if( ! strcmp( argv[ 0 ], "exit" ) )
 		exit(  );
	i = 1;
	while( i < 20 && (argv[ i ] = strtok( 0, " " )) )
 158:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
 15c:	7f 2c                	jg     18a <main+0xe3>
 15e:	83 ec 08             	sub    $0x8,%esp
 161:	68 88 09 00 00       	push   $0x988
 166:	6a 00                	push   $0x0
 168:	e8 93 fe ff ff       	call   0 <strtok>
 16d:	83 c4 10             	add    $0x10,%esp
 170:	89 c2                	mov    %eax,%edx
 172:	8b 45 f4             	mov    -0xc(%ebp),%eax
 175:	89 94 85 4c ff ff ff 	mov    %edx,-0xb4(%ebp,%eax,4)
 17c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 17f:	8b 84 85 4c ff ff ff 	mov    -0xb4(%ebp,%eax,4),%eax
 186:	85 c0                	test   %eax,%eax
 188:	75 ca                	jne    154 <main+0xad>
		 ++i;
	if( (pid = fork()) == -1 ) {
 18a:	e8 b9 02 00 00       	call   448 <fork>
 18f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 192:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
 196:	75 17                	jne    1af <main+0x108>
		 printf(2, "Erro no fork\n" );
 198:	83 ec 08             	sub    $0x8,%esp
 19b:	68 8f 09 00 00       	push   $0x98f
 1a0:	6a 02                	push   $0x2
 1a2:	e8 20 04 00 00       	call   5c7 <printf>
 1a7:	83 c4 10             	add    $0x10,%esp
		 exit(  );
 1aa:	e8 a1 02 00 00       	call   450 <exit>
	}
	if( pid == 0 )
 1af:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1b3:	75 34                	jne    1e9 <main+0x142>
	if( exec( argv[ 0 ], argv ) ) {
 1b5:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
 1bb:	83 ec 08             	sub    $0x8,%esp
 1be:	8d 95 4c ff ff ff    	lea    -0xb4(%ebp),%edx
 1c4:	52                   	push   %edx
 1c5:	50                   	push   %eax
 1c6:	e8 bd 02 00 00       	call   488 <exec>
 1cb:	83 c4 10             	add    $0x10,%esp
 1ce:	85 c0                	test   %eax,%eax
 1d0:	74 17                	je     1e9 <main+0x142>
		printf(2, "Erro no execv\n" );
 1d2:	83 ec 08             	sub    $0x8,%esp
 1d5:	68 9d 09 00 00       	push   $0x99d
 1da:	6a 02                	push   $0x2
 1dc:	e8 e6 03 00 00       	call   5c7 <printf>
 1e1:	83 c4 10             	add    $0x10,%esp
		exit(  );
 1e4:	e8 67 02 00 00       	call   450 <exit>
 	}
	 wait();
 1e9:	e8 6a 02 00 00       	call   458 <wait>
 1ee:	e9 c8 fe ff ff       	jmp    bb <main+0x14>

 while( 1 ) {
 	printf(1, "Prompt > " );
	gets( lc , 81);
	if( ! strcmp( lc, "" ) )
 		continue;
 1f3:	90                   	nop
	if( exec( argv[ 0 ], argv ) ) {
		printf(2, "Erro no execv\n" );
		exit(  );
 	}
	 wait();
 }
 1f4:	e9 c2 fe ff ff       	jmp    bb <main+0x14>

000001f9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 1f9:	55                   	push   %ebp
 1fa:	89 e5                	mov    %esp,%ebp
 1fc:	57                   	push   %edi
 1fd:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 1fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
 201:	8b 55 10             	mov    0x10(%ebp),%edx
 204:	8b 45 0c             	mov    0xc(%ebp),%eax
 207:	89 cb                	mov    %ecx,%ebx
 209:	89 df                	mov    %ebx,%edi
 20b:	89 d1                	mov    %edx,%ecx
 20d:	fc                   	cld    
 20e:	f3 aa                	rep stos %al,%es:(%edi)
 210:	89 ca                	mov    %ecx,%edx
 212:	89 fb                	mov    %edi,%ebx
 214:	89 5d 08             	mov    %ebx,0x8(%ebp)
 217:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 21a:	90                   	nop
 21b:	5b                   	pop    %ebx
 21c:	5f                   	pop    %edi
 21d:	5d                   	pop    %ebp
 21e:	c3                   	ret    

0000021f <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 21f:	55                   	push   %ebp
 220:	89 e5                	mov    %esp,%ebp
 222:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 225:	8b 45 08             	mov    0x8(%ebp),%eax
 228:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 22b:	90                   	nop
 22c:	8b 45 08             	mov    0x8(%ebp),%eax
 22f:	8d 50 01             	lea    0x1(%eax),%edx
 232:	89 55 08             	mov    %edx,0x8(%ebp)
 235:	8b 55 0c             	mov    0xc(%ebp),%edx
 238:	8d 4a 01             	lea    0x1(%edx),%ecx
 23b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 23e:	0f b6 12             	movzbl (%edx),%edx
 241:	88 10                	mov    %dl,(%eax)
 243:	0f b6 00             	movzbl (%eax),%eax
 246:	84 c0                	test   %al,%al
 248:	75 e2                	jne    22c <strcpy+0xd>
    ;
  return os;
 24a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 24d:	c9                   	leave  
 24e:	c3                   	ret    

0000024f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 24f:	55                   	push   %ebp
 250:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 252:	eb 08                	jmp    25c <strcmp+0xd>
    p++, q++;
 254:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 258:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 25c:	8b 45 08             	mov    0x8(%ebp),%eax
 25f:	0f b6 00             	movzbl (%eax),%eax
 262:	84 c0                	test   %al,%al
 264:	74 10                	je     276 <strcmp+0x27>
 266:	8b 45 08             	mov    0x8(%ebp),%eax
 269:	0f b6 10             	movzbl (%eax),%edx
 26c:	8b 45 0c             	mov    0xc(%ebp),%eax
 26f:	0f b6 00             	movzbl (%eax),%eax
 272:	38 c2                	cmp    %al,%dl
 274:	74 de                	je     254 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 276:	8b 45 08             	mov    0x8(%ebp),%eax
 279:	0f b6 00             	movzbl (%eax),%eax
 27c:	0f b6 d0             	movzbl %al,%edx
 27f:	8b 45 0c             	mov    0xc(%ebp),%eax
 282:	0f b6 00             	movzbl (%eax),%eax
 285:	0f b6 c0             	movzbl %al,%eax
 288:	29 c2                	sub    %eax,%edx
 28a:	89 d0                	mov    %edx,%eax
}
 28c:	5d                   	pop    %ebp
 28d:	c3                   	ret    

0000028e <strlen>:

uint
strlen(char *s)
{
 28e:	55                   	push   %ebp
 28f:	89 e5                	mov    %esp,%ebp
 291:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 294:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 29b:	eb 04                	jmp    2a1 <strlen+0x13>
 29d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 2a1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2a4:	8b 45 08             	mov    0x8(%ebp),%eax
 2a7:	01 d0                	add    %edx,%eax
 2a9:	0f b6 00             	movzbl (%eax),%eax
 2ac:	84 c0                	test   %al,%al
 2ae:	75 ed                	jne    29d <strlen+0xf>
    ;
  return n;
 2b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2b3:	c9                   	leave  
 2b4:	c3                   	ret    

000002b5 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2b5:	55                   	push   %ebp
 2b6:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 2b8:	8b 45 10             	mov    0x10(%ebp),%eax
 2bb:	50                   	push   %eax
 2bc:	ff 75 0c             	pushl  0xc(%ebp)
 2bf:	ff 75 08             	pushl  0x8(%ebp)
 2c2:	e8 32 ff ff ff       	call   1f9 <stosb>
 2c7:	83 c4 0c             	add    $0xc,%esp
  return dst;
 2ca:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2cd:	c9                   	leave  
 2ce:	c3                   	ret    

000002cf <strchr>:

char*
strchr(const char *s, char c)
{
 2cf:	55                   	push   %ebp
 2d0:	89 e5                	mov    %esp,%ebp
 2d2:	83 ec 04             	sub    $0x4,%esp
 2d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 2db:	eb 14                	jmp    2f1 <strchr+0x22>
    if(*s == c)
 2dd:	8b 45 08             	mov    0x8(%ebp),%eax
 2e0:	0f b6 00             	movzbl (%eax),%eax
 2e3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 2e6:	75 05                	jne    2ed <strchr+0x1e>
      return (char*)s;
 2e8:	8b 45 08             	mov    0x8(%ebp),%eax
 2eb:	eb 13                	jmp    300 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 2ed:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2f1:	8b 45 08             	mov    0x8(%ebp),%eax
 2f4:	0f b6 00             	movzbl (%eax),%eax
 2f7:	84 c0                	test   %al,%al
 2f9:	75 e2                	jne    2dd <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 2fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
 300:	c9                   	leave  
 301:	c3                   	ret    

00000302 <gets>:

char*
gets(char *buf, int max)
{
 302:	55                   	push   %ebp
 303:	89 e5                	mov    %esp,%ebp
 305:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 308:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 30f:	eb 42                	jmp    353 <gets+0x51>
    cc = read(0, &c, 1);
 311:	83 ec 04             	sub    $0x4,%esp
 314:	6a 01                	push   $0x1
 316:	8d 45 ef             	lea    -0x11(%ebp),%eax
 319:	50                   	push   %eax
 31a:	6a 00                	push   $0x0
 31c:	e8 47 01 00 00       	call   468 <read>
 321:	83 c4 10             	add    $0x10,%esp
 324:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 327:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 32b:	7e 33                	jle    360 <gets+0x5e>
      break;
    buf[i++] = c;
 32d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 330:	8d 50 01             	lea    0x1(%eax),%edx
 333:	89 55 f4             	mov    %edx,-0xc(%ebp)
 336:	89 c2                	mov    %eax,%edx
 338:	8b 45 08             	mov    0x8(%ebp),%eax
 33b:	01 c2                	add    %eax,%edx
 33d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 341:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 343:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 347:	3c 0a                	cmp    $0xa,%al
 349:	74 16                	je     361 <gets+0x5f>
 34b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 34f:	3c 0d                	cmp    $0xd,%al
 351:	74 0e                	je     361 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 353:	8b 45 f4             	mov    -0xc(%ebp),%eax
 356:	83 c0 01             	add    $0x1,%eax
 359:	3b 45 0c             	cmp    0xc(%ebp),%eax
 35c:	7c b3                	jl     311 <gets+0xf>
 35e:	eb 01                	jmp    361 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 360:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 361:	8b 55 f4             	mov    -0xc(%ebp),%edx
 364:	8b 45 08             	mov    0x8(%ebp),%eax
 367:	01 d0                	add    %edx,%eax
 369:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 36c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 36f:	c9                   	leave  
 370:	c3                   	ret    

00000371 <stat>:

int
stat(char *n, struct stat *st)
{
 371:	55                   	push   %ebp
 372:	89 e5                	mov    %esp,%ebp
 374:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 377:	83 ec 08             	sub    $0x8,%esp
 37a:	6a 00                	push   $0x0
 37c:	ff 75 08             	pushl  0x8(%ebp)
 37f:	e8 0c 01 00 00       	call   490 <open>
 384:	83 c4 10             	add    $0x10,%esp
 387:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 38a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 38e:	79 07                	jns    397 <stat+0x26>
    return -1;
 390:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 395:	eb 25                	jmp    3bc <stat+0x4b>
  r = fstat(fd, st);
 397:	83 ec 08             	sub    $0x8,%esp
 39a:	ff 75 0c             	pushl  0xc(%ebp)
 39d:	ff 75 f4             	pushl  -0xc(%ebp)
 3a0:	e8 03 01 00 00       	call   4a8 <fstat>
 3a5:	83 c4 10             	add    $0x10,%esp
 3a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 3ab:	83 ec 0c             	sub    $0xc,%esp
 3ae:	ff 75 f4             	pushl  -0xc(%ebp)
 3b1:	e8 c2 00 00 00       	call   478 <close>
 3b6:	83 c4 10             	add    $0x10,%esp
  return r;
 3b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 3bc:	c9                   	leave  
 3bd:	c3                   	ret    

000003be <atoi>:

int
atoi(const char *s)
{
 3be:	55                   	push   %ebp
 3bf:	89 e5                	mov    %esp,%ebp
 3c1:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 3c4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 3cb:	eb 25                	jmp    3f2 <atoi+0x34>
    n = n*10 + *s++ - '0';
 3cd:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3d0:	89 d0                	mov    %edx,%eax
 3d2:	c1 e0 02             	shl    $0x2,%eax
 3d5:	01 d0                	add    %edx,%eax
 3d7:	01 c0                	add    %eax,%eax
 3d9:	89 c1                	mov    %eax,%ecx
 3db:	8b 45 08             	mov    0x8(%ebp),%eax
 3de:	8d 50 01             	lea    0x1(%eax),%edx
 3e1:	89 55 08             	mov    %edx,0x8(%ebp)
 3e4:	0f b6 00             	movzbl (%eax),%eax
 3e7:	0f be c0             	movsbl %al,%eax
 3ea:	01 c8                	add    %ecx,%eax
 3ec:	83 e8 30             	sub    $0x30,%eax
 3ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f2:	8b 45 08             	mov    0x8(%ebp),%eax
 3f5:	0f b6 00             	movzbl (%eax),%eax
 3f8:	3c 2f                	cmp    $0x2f,%al
 3fa:	7e 0a                	jle    406 <atoi+0x48>
 3fc:	8b 45 08             	mov    0x8(%ebp),%eax
 3ff:	0f b6 00             	movzbl (%eax),%eax
 402:	3c 39                	cmp    $0x39,%al
 404:	7e c7                	jle    3cd <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 406:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 409:	c9                   	leave  
 40a:	c3                   	ret    

0000040b <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 40b:	55                   	push   %ebp
 40c:	89 e5                	mov    %esp,%ebp
 40e:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 411:	8b 45 08             	mov    0x8(%ebp),%eax
 414:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 417:	8b 45 0c             	mov    0xc(%ebp),%eax
 41a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 41d:	eb 17                	jmp    436 <memmove+0x2b>
    *dst++ = *src++;
 41f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 422:	8d 50 01             	lea    0x1(%eax),%edx
 425:	89 55 fc             	mov    %edx,-0x4(%ebp)
 428:	8b 55 f8             	mov    -0x8(%ebp),%edx
 42b:	8d 4a 01             	lea    0x1(%edx),%ecx
 42e:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 431:	0f b6 12             	movzbl (%edx),%edx
 434:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 436:	8b 45 10             	mov    0x10(%ebp),%eax
 439:	8d 50 ff             	lea    -0x1(%eax),%edx
 43c:	89 55 10             	mov    %edx,0x10(%ebp)
 43f:	85 c0                	test   %eax,%eax
 441:	7f dc                	jg     41f <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 443:	8b 45 08             	mov    0x8(%ebp),%eax
}
 446:	c9                   	leave  
 447:	c3                   	ret    

00000448 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 448:	b8 01 00 00 00       	mov    $0x1,%eax
 44d:	cd 40                	int    $0x40
 44f:	c3                   	ret    

00000450 <exit>:
SYSCALL(exit)
 450:	b8 02 00 00 00       	mov    $0x2,%eax
 455:	cd 40                	int    $0x40
 457:	c3                   	ret    

00000458 <wait>:
SYSCALL(wait)
 458:	b8 03 00 00 00       	mov    $0x3,%eax
 45d:	cd 40                	int    $0x40
 45f:	c3                   	ret    

00000460 <pipe>:
SYSCALL(pipe)
 460:	b8 04 00 00 00       	mov    $0x4,%eax
 465:	cd 40                	int    $0x40
 467:	c3                   	ret    

00000468 <read>:
SYSCALL(read)
 468:	b8 05 00 00 00       	mov    $0x5,%eax
 46d:	cd 40                	int    $0x40
 46f:	c3                   	ret    

00000470 <write>:
SYSCALL(write)
 470:	b8 10 00 00 00       	mov    $0x10,%eax
 475:	cd 40                	int    $0x40
 477:	c3                   	ret    

00000478 <close>:
SYSCALL(close)
 478:	b8 15 00 00 00       	mov    $0x15,%eax
 47d:	cd 40                	int    $0x40
 47f:	c3                   	ret    

00000480 <kill>:
SYSCALL(kill)
 480:	b8 06 00 00 00       	mov    $0x6,%eax
 485:	cd 40                	int    $0x40
 487:	c3                   	ret    

00000488 <exec>:
SYSCALL(exec)
 488:	b8 07 00 00 00       	mov    $0x7,%eax
 48d:	cd 40                	int    $0x40
 48f:	c3                   	ret    

00000490 <open>:
SYSCALL(open)
 490:	b8 0f 00 00 00       	mov    $0xf,%eax
 495:	cd 40                	int    $0x40
 497:	c3                   	ret    

00000498 <mknod>:
SYSCALL(mknod)
 498:	b8 11 00 00 00       	mov    $0x11,%eax
 49d:	cd 40                	int    $0x40
 49f:	c3                   	ret    

000004a0 <unlink>:
SYSCALL(unlink)
 4a0:	b8 12 00 00 00       	mov    $0x12,%eax
 4a5:	cd 40                	int    $0x40
 4a7:	c3                   	ret    

000004a8 <fstat>:
SYSCALL(fstat)
 4a8:	b8 08 00 00 00       	mov    $0x8,%eax
 4ad:	cd 40                	int    $0x40
 4af:	c3                   	ret    

000004b0 <link>:
SYSCALL(link)
 4b0:	b8 13 00 00 00       	mov    $0x13,%eax
 4b5:	cd 40                	int    $0x40
 4b7:	c3                   	ret    

000004b8 <mkdir>:
SYSCALL(mkdir)
 4b8:	b8 14 00 00 00       	mov    $0x14,%eax
 4bd:	cd 40                	int    $0x40
 4bf:	c3                   	ret    

000004c0 <chdir>:
SYSCALL(chdir)
 4c0:	b8 09 00 00 00       	mov    $0x9,%eax
 4c5:	cd 40                	int    $0x40
 4c7:	c3                   	ret    

000004c8 <dup>:
SYSCALL(dup)
 4c8:	b8 0a 00 00 00       	mov    $0xa,%eax
 4cd:	cd 40                	int    $0x40
 4cf:	c3                   	ret    

000004d0 <getpid>:
SYSCALL(getpid)
 4d0:	b8 0b 00 00 00       	mov    $0xb,%eax
 4d5:	cd 40                	int    $0x40
 4d7:	c3                   	ret    

000004d8 <sbrk>:
SYSCALL(sbrk)
 4d8:	b8 0c 00 00 00       	mov    $0xc,%eax
 4dd:	cd 40                	int    $0x40
 4df:	c3                   	ret    

000004e0 <sleep>:
SYSCALL(sleep)
 4e0:	b8 0d 00 00 00       	mov    $0xd,%eax
 4e5:	cd 40                	int    $0x40
 4e7:	c3                   	ret    

000004e8 <uptime>:
SYSCALL(uptime)
 4e8:	b8 0e 00 00 00       	mov    $0xe,%eax
 4ed:	cd 40                	int    $0x40
 4ef:	c3                   	ret    

000004f0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4f0:	55                   	push   %ebp
 4f1:	89 e5                	mov    %esp,%ebp
 4f3:	83 ec 18             	sub    $0x18,%esp
 4f6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f9:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4fc:	83 ec 04             	sub    $0x4,%esp
 4ff:	6a 01                	push   $0x1
 501:	8d 45 f4             	lea    -0xc(%ebp),%eax
 504:	50                   	push   %eax
 505:	ff 75 08             	pushl  0x8(%ebp)
 508:	e8 63 ff ff ff       	call   470 <write>
 50d:	83 c4 10             	add    $0x10,%esp
}
 510:	90                   	nop
 511:	c9                   	leave  
 512:	c3                   	ret    

00000513 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 513:	55                   	push   %ebp
 514:	89 e5                	mov    %esp,%ebp
 516:	53                   	push   %ebx
 517:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 51a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 521:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 525:	74 17                	je     53e <printint+0x2b>
 527:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 52b:	79 11                	jns    53e <printint+0x2b>
    neg = 1;
 52d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 534:	8b 45 0c             	mov    0xc(%ebp),%eax
 537:	f7 d8                	neg    %eax
 539:	89 45 ec             	mov    %eax,-0x14(%ebp)
 53c:	eb 06                	jmp    544 <printint+0x31>
  } else {
    x = xx;
 53e:	8b 45 0c             	mov    0xc(%ebp),%eax
 541:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 544:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 54b:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 54e:	8d 41 01             	lea    0x1(%ecx),%eax
 551:	89 45 f4             	mov    %eax,-0xc(%ebp)
 554:	8b 5d 10             	mov    0x10(%ebp),%ebx
 557:	8b 45 ec             	mov    -0x14(%ebp),%eax
 55a:	ba 00 00 00 00       	mov    $0x0,%edx
 55f:	f7 f3                	div    %ebx
 561:	89 d0                	mov    %edx,%eax
 563:	0f b6 80 28 0c 00 00 	movzbl 0xc28(%eax),%eax
 56a:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 56e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 571:	8b 45 ec             	mov    -0x14(%ebp),%eax
 574:	ba 00 00 00 00       	mov    $0x0,%edx
 579:	f7 f3                	div    %ebx
 57b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 57e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 582:	75 c7                	jne    54b <printint+0x38>
  if(neg)
 584:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 588:	74 2d                	je     5b7 <printint+0xa4>
    buf[i++] = '-';
 58a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 58d:	8d 50 01             	lea    0x1(%eax),%edx
 590:	89 55 f4             	mov    %edx,-0xc(%ebp)
 593:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 598:	eb 1d                	jmp    5b7 <printint+0xa4>
    putc(fd, buf[i]);
 59a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 59d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5a0:	01 d0                	add    %edx,%eax
 5a2:	0f b6 00             	movzbl (%eax),%eax
 5a5:	0f be c0             	movsbl %al,%eax
 5a8:	83 ec 08             	sub    $0x8,%esp
 5ab:	50                   	push   %eax
 5ac:	ff 75 08             	pushl  0x8(%ebp)
 5af:	e8 3c ff ff ff       	call   4f0 <putc>
 5b4:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 5b7:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 5bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5bf:	79 d9                	jns    59a <printint+0x87>
    putc(fd, buf[i]);
}
 5c1:	90                   	nop
 5c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5c5:	c9                   	leave  
 5c6:	c3                   	ret    

000005c7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 5c7:	55                   	push   %ebp
 5c8:	89 e5                	mov    %esp,%ebp
 5ca:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 5cd:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 5d4:	8d 45 0c             	lea    0xc(%ebp),%eax
 5d7:	83 c0 04             	add    $0x4,%eax
 5da:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 5dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 5e4:	e9 59 01 00 00       	jmp    742 <printf+0x17b>
    c = fmt[i] & 0xff;
 5e9:	8b 55 0c             	mov    0xc(%ebp),%edx
 5ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5ef:	01 d0                	add    %edx,%eax
 5f1:	0f b6 00             	movzbl (%eax),%eax
 5f4:	0f be c0             	movsbl %al,%eax
 5f7:	25 ff 00 00 00       	and    $0xff,%eax
 5fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5ff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 603:	75 2c                	jne    631 <printf+0x6a>
      if(c == '%'){
 605:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 609:	75 0c                	jne    617 <printf+0x50>
        state = '%';
 60b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 612:	e9 27 01 00 00       	jmp    73e <printf+0x177>
      } else {
        putc(fd, c);
 617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 61a:	0f be c0             	movsbl %al,%eax
 61d:	83 ec 08             	sub    $0x8,%esp
 620:	50                   	push   %eax
 621:	ff 75 08             	pushl  0x8(%ebp)
 624:	e8 c7 fe ff ff       	call   4f0 <putc>
 629:	83 c4 10             	add    $0x10,%esp
 62c:	e9 0d 01 00 00       	jmp    73e <printf+0x177>
      }
    } else if(state == '%'){
 631:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 635:	0f 85 03 01 00 00    	jne    73e <printf+0x177>
      if(c == 'd'){
 63b:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 63f:	75 1e                	jne    65f <printf+0x98>
        printint(fd, *ap, 10, 1);
 641:	8b 45 e8             	mov    -0x18(%ebp),%eax
 644:	8b 00                	mov    (%eax),%eax
 646:	6a 01                	push   $0x1
 648:	6a 0a                	push   $0xa
 64a:	50                   	push   %eax
 64b:	ff 75 08             	pushl  0x8(%ebp)
 64e:	e8 c0 fe ff ff       	call   513 <printint>
 653:	83 c4 10             	add    $0x10,%esp
        ap++;
 656:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 65a:	e9 d8 00 00 00       	jmp    737 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 65f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 663:	74 06                	je     66b <printf+0xa4>
 665:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 669:	75 1e                	jne    689 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 66b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 66e:	8b 00                	mov    (%eax),%eax
 670:	6a 00                	push   $0x0
 672:	6a 10                	push   $0x10
 674:	50                   	push   %eax
 675:	ff 75 08             	pushl  0x8(%ebp)
 678:	e8 96 fe ff ff       	call   513 <printint>
 67d:	83 c4 10             	add    $0x10,%esp
        ap++;
 680:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 684:	e9 ae 00 00 00       	jmp    737 <printf+0x170>
      } else if(c == 's'){
 689:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 68d:	75 43                	jne    6d2 <printf+0x10b>
        s = (char*)*ap;
 68f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 692:	8b 00                	mov    (%eax),%eax
 694:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 697:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 69b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 69f:	75 25                	jne    6c6 <printf+0xff>
          s = "(null)";
 6a1:	c7 45 f4 ac 09 00 00 	movl   $0x9ac,-0xc(%ebp)
        while(*s != 0){
 6a8:	eb 1c                	jmp    6c6 <printf+0xff>
          putc(fd, *s);
 6aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6ad:	0f b6 00             	movzbl (%eax),%eax
 6b0:	0f be c0             	movsbl %al,%eax
 6b3:	83 ec 08             	sub    $0x8,%esp
 6b6:	50                   	push   %eax
 6b7:	ff 75 08             	pushl  0x8(%ebp)
 6ba:	e8 31 fe ff ff       	call   4f0 <putc>
 6bf:	83 c4 10             	add    $0x10,%esp
          s++;
 6c2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 6c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6c9:	0f b6 00             	movzbl (%eax),%eax
 6cc:	84 c0                	test   %al,%al
 6ce:	75 da                	jne    6aa <printf+0xe3>
 6d0:	eb 65                	jmp    737 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6d2:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 6d6:	75 1d                	jne    6f5 <printf+0x12e>
        putc(fd, *ap);
 6d8:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6db:	8b 00                	mov    (%eax),%eax
 6dd:	0f be c0             	movsbl %al,%eax
 6e0:	83 ec 08             	sub    $0x8,%esp
 6e3:	50                   	push   %eax
 6e4:	ff 75 08             	pushl  0x8(%ebp)
 6e7:	e8 04 fe ff ff       	call   4f0 <putc>
 6ec:	83 c4 10             	add    $0x10,%esp
        ap++;
 6ef:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f3:	eb 42                	jmp    737 <printf+0x170>
      } else if(c == '%'){
 6f5:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6f9:	75 17                	jne    712 <printf+0x14b>
        putc(fd, c);
 6fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6fe:	0f be c0             	movsbl %al,%eax
 701:	83 ec 08             	sub    $0x8,%esp
 704:	50                   	push   %eax
 705:	ff 75 08             	pushl  0x8(%ebp)
 708:	e8 e3 fd ff ff       	call   4f0 <putc>
 70d:	83 c4 10             	add    $0x10,%esp
 710:	eb 25                	jmp    737 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 712:	83 ec 08             	sub    $0x8,%esp
 715:	6a 25                	push   $0x25
 717:	ff 75 08             	pushl  0x8(%ebp)
 71a:	e8 d1 fd ff ff       	call   4f0 <putc>
 71f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 722:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 725:	0f be c0             	movsbl %al,%eax
 728:	83 ec 08             	sub    $0x8,%esp
 72b:	50                   	push   %eax
 72c:	ff 75 08             	pushl  0x8(%ebp)
 72f:	e8 bc fd ff ff       	call   4f0 <putc>
 734:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 737:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 73e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 742:	8b 55 0c             	mov    0xc(%ebp),%edx
 745:	8b 45 f0             	mov    -0x10(%ebp),%eax
 748:	01 d0                	add    %edx,%eax
 74a:	0f b6 00             	movzbl (%eax),%eax
 74d:	84 c0                	test   %al,%al
 74f:	0f 85 94 fe ff ff    	jne    5e9 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 755:	90                   	nop
 756:	c9                   	leave  
 757:	c3                   	ret    

00000758 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 758:	55                   	push   %ebp
 759:	89 e5                	mov    %esp,%ebp
 75b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 75e:	8b 45 08             	mov    0x8(%ebp),%eax
 761:	83 e8 08             	sub    $0x8,%eax
 764:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 767:	a1 48 0c 00 00       	mov    0xc48,%eax
 76c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 76f:	eb 24                	jmp    795 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 771:	8b 45 fc             	mov    -0x4(%ebp),%eax
 774:	8b 00                	mov    (%eax),%eax
 776:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 779:	77 12                	ja     78d <free+0x35>
 77b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 781:	77 24                	ja     7a7 <free+0x4f>
 783:	8b 45 fc             	mov    -0x4(%ebp),%eax
 786:	8b 00                	mov    (%eax),%eax
 788:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 78b:	77 1a                	ja     7a7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 790:	8b 00                	mov    (%eax),%eax
 792:	89 45 fc             	mov    %eax,-0x4(%ebp)
 795:	8b 45 f8             	mov    -0x8(%ebp),%eax
 798:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 79b:	76 d4                	jbe    771 <free+0x19>
 79d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a0:	8b 00                	mov    (%eax),%eax
 7a2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7a5:	76 ca                	jbe    771 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 7a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7aa:	8b 40 04             	mov    0x4(%eax),%eax
 7ad:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7b4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7b7:	01 c2                	add    %eax,%edx
 7b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	39 c2                	cmp    %eax,%edx
 7c0:	75 24                	jne    7e6 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 7c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7c5:	8b 50 04             	mov    0x4(%eax),%edx
 7c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7cb:	8b 00                	mov    (%eax),%eax
 7cd:	8b 40 04             	mov    0x4(%eax),%eax
 7d0:	01 c2                	add    %eax,%edx
 7d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 7d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7db:	8b 00                	mov    (%eax),%eax
 7dd:	8b 10                	mov    (%eax),%edx
 7df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7e2:	89 10                	mov    %edx,(%eax)
 7e4:	eb 0a                	jmp    7f0 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e9:	8b 10                	mov    (%eax),%edx
 7eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ee:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f3:	8b 40 04             	mov    0x4(%eax),%eax
 7f6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 800:	01 d0                	add    %edx,%eax
 802:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 805:	75 20                	jne    827 <free+0xcf>
    p->s.size += bp->s.size;
 807:	8b 45 fc             	mov    -0x4(%ebp),%eax
 80a:	8b 50 04             	mov    0x4(%eax),%edx
 80d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 810:	8b 40 04             	mov    0x4(%eax),%eax
 813:	01 c2                	add    %eax,%edx
 815:	8b 45 fc             	mov    -0x4(%ebp),%eax
 818:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 81b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81e:	8b 10                	mov    (%eax),%edx
 820:	8b 45 fc             	mov    -0x4(%ebp),%eax
 823:	89 10                	mov    %edx,(%eax)
 825:	eb 08                	jmp    82f <free+0xd7>
  } else
    p->s.ptr = bp;
 827:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 82d:	89 10                	mov    %edx,(%eax)
  freep = p;
 82f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 832:	a3 48 0c 00 00       	mov    %eax,0xc48
}
 837:	90                   	nop
 838:	c9                   	leave  
 839:	c3                   	ret    

0000083a <morecore>:

static Header*
morecore(uint nu)
{
 83a:	55                   	push   %ebp
 83b:	89 e5                	mov    %esp,%ebp
 83d:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 840:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 847:	77 07                	ja     850 <morecore+0x16>
    nu = 4096;
 849:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 850:	8b 45 08             	mov    0x8(%ebp),%eax
 853:	c1 e0 03             	shl    $0x3,%eax
 856:	83 ec 0c             	sub    $0xc,%esp
 859:	50                   	push   %eax
 85a:	e8 79 fc ff ff       	call   4d8 <sbrk>
 85f:	83 c4 10             	add    $0x10,%esp
 862:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 865:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 869:	75 07                	jne    872 <morecore+0x38>
    return 0;
 86b:	b8 00 00 00 00       	mov    $0x0,%eax
 870:	eb 26                	jmp    898 <morecore+0x5e>
  hp = (Header*)p;
 872:	8b 45 f4             	mov    -0xc(%ebp),%eax
 875:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 878:	8b 45 f0             	mov    -0x10(%ebp),%eax
 87b:	8b 55 08             	mov    0x8(%ebp),%edx
 87e:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 881:	8b 45 f0             	mov    -0x10(%ebp),%eax
 884:	83 c0 08             	add    $0x8,%eax
 887:	83 ec 0c             	sub    $0xc,%esp
 88a:	50                   	push   %eax
 88b:	e8 c8 fe ff ff       	call   758 <free>
 890:	83 c4 10             	add    $0x10,%esp
  return freep;
 893:	a1 48 0c 00 00       	mov    0xc48,%eax
}
 898:	c9                   	leave  
 899:	c3                   	ret    

0000089a <malloc>:

void*
malloc(uint nbytes)
{
 89a:	55                   	push   %ebp
 89b:	89 e5                	mov    %esp,%ebp
 89d:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a0:	8b 45 08             	mov    0x8(%ebp),%eax
 8a3:	83 c0 07             	add    $0x7,%eax
 8a6:	c1 e8 03             	shr    $0x3,%eax
 8a9:	83 c0 01             	add    $0x1,%eax
 8ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 8af:	a1 48 0c 00 00       	mov    0xc48,%eax
 8b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8b7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 8bb:	75 23                	jne    8e0 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 8bd:	c7 45 f0 40 0c 00 00 	movl   $0xc40,-0x10(%ebp)
 8c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c7:	a3 48 0c 00 00       	mov    %eax,0xc48
 8cc:	a1 48 0c 00 00       	mov    0xc48,%eax
 8d1:	a3 40 0c 00 00       	mov    %eax,0xc40
    base.s.size = 0;
 8d6:	c7 05 44 0c 00 00 00 	movl   $0x0,0xc44
 8dd:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8e3:	8b 00                	mov    (%eax),%eax
 8e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8eb:	8b 40 04             	mov    0x4(%eax),%eax
 8ee:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8f1:	72 4d                	jb     940 <malloc+0xa6>
      if(p->s.size == nunits)
 8f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f6:	8b 40 04             	mov    0x4(%eax),%eax
 8f9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8fc:	75 0c                	jne    90a <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 901:	8b 10                	mov    (%eax),%edx
 903:	8b 45 f0             	mov    -0x10(%ebp),%eax
 906:	89 10                	mov    %edx,(%eax)
 908:	eb 26                	jmp    930 <malloc+0x96>
      else {
        p->s.size -= nunits;
 90a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 90d:	8b 40 04             	mov    0x4(%eax),%eax
 910:	2b 45 ec             	sub    -0x14(%ebp),%eax
 913:	89 c2                	mov    %eax,%edx
 915:	8b 45 f4             	mov    -0xc(%ebp),%eax
 918:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 91b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 91e:	8b 40 04             	mov    0x4(%eax),%eax
 921:	c1 e0 03             	shl    $0x3,%eax
 924:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 927:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92a:	8b 55 ec             	mov    -0x14(%ebp),%edx
 92d:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 930:	8b 45 f0             	mov    -0x10(%ebp),%eax
 933:	a3 48 0c 00 00       	mov    %eax,0xc48
      return (void*)(p + 1);
 938:	8b 45 f4             	mov    -0xc(%ebp),%eax
 93b:	83 c0 08             	add    $0x8,%eax
 93e:	eb 3b                	jmp    97b <malloc+0xe1>
    }
    if(p == freep)
 940:	a1 48 0c 00 00       	mov    0xc48,%eax
 945:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 948:	75 1e                	jne    968 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 94a:	83 ec 0c             	sub    $0xc,%esp
 94d:	ff 75 ec             	pushl  -0x14(%ebp)
 950:	e8 e5 fe ff ff       	call   83a <morecore>
 955:	83 c4 10             	add    $0x10,%esp
 958:	89 45 f4             	mov    %eax,-0xc(%ebp)
 95b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 95f:	75 07                	jne    968 <malloc+0xce>
        return 0;
 961:	b8 00 00 00 00       	mov    $0x0,%eax
 966:	eb 13                	jmp    97b <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 968:	8b 45 f4             	mov    -0xc(%ebp),%eax
 96b:	89 45 f0             	mov    %eax,-0x10(%ebp)
 96e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 971:	8b 00                	mov    (%eax),%eax
 973:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 976:	e9 6d ff ff ff       	jmp    8e8 <malloc+0x4e>
}
 97b:	c9                   	leave  
 97c:	c3                   	ret    
