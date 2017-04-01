/***************************************************************
  DISCIPLINA: 203065 - Sistemas Operacionais

  Shell para execu��o de comandos simples;
     - Esse c�digo roda em Linux;
     - O que fazer para portar para o Xv6?
		- ver c�digo do sh.c

    1. Mudado os printf("string") para printf(1, "string") - Saída padrão
    2. Removidas as bibliotecas stdio e stdlib - Não existem no xv6
    3. Adicionada a biblioteca do printf no xv6 (user.h)
    4. Removido o parâmetro do exit - Não existe no xv6
    5. Adicionado o tamanho da string com o comando no gets - Obrigatório no xv6
    6. Removido o parametro do wait - Isso talvez não esteja certo, conferir com o dierone
    7. Adicionada a biblioteca types.h antes da user, ela contém a declaração dos tipos
      - Solução possível para o futuro: adicionar a definição na própria user.h
      - Resolveria a dependência? Criaria re-declarações? Deveria ser feita em outras libraries?
    8. Mudado de execvp para exec - Isso talvez não esteja certo, conferir com o dierone
    9. Mudar o NULL para 0 no strtok - NULL não é definido no xv6
      - Solução possível para o futuro: adicionar a constante NULL na types.h
    10. Arrumar o strtok - Perguntar ao dierone
      - Implementar strtok ou achar alternativa, aparentemente não existe no xv6
    11. Mudada a saida padrão dos erros para a 2 (stderr)
    12. Adicionado o arquivo da strtok na pasta e incluido o arquivo
    13. O gets lê o \n final
	- Solução: adicionar no strtok o '\n' como delimitador
	- Solução alternativa: adicionar o 0 na ultima posicao do vetor (depois da verificação pra nao dar underflow)


***************************************************************/

#include "types.h"

#include "user.h"

#include "strtok.c"


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
	lc[strlen(lc)-1]=0; // tamanho da string -1 (começa no 0) deve ser nulo pra tirar o \n
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
