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

#include "types.h" // header com a definição dos tipos usados pela user.h

#include "user.h" // header com os cabeçalhos de syscalls e funções.
// possui as syscalls aqui usadas: fork, exit, wait, exec
// possui as funções aqui usadas: strcmp, printf, gets, strlen

#include "strtok.c" // arquivo com o código fonte da função strtok (não nativa do xv6)


int main( void )
{
  char lc[ 81 ]; // buffer de entrada do shell
  char *argv[ 20 ]; // vetor de strings para separar os argumentos e funções
  int pid, i; // process id e contador

  while( 1 ) { // loop até dar saída
    printf(1, "Prompt > " ); // escreve na saída padrão (stdout ou 1) que está pronto para receber instruções
    gets( lc , 81); // lê buffer de entrada
    if( ! strcmp( lc, "" ) ) // se a entrada não for nula continua a rodar
    continue;
    lc[strlen(lc)-1]=0; // retira o \n do fim da string de entrada visto que o gets a lê
    // tamanho da string -1 (começa no 0) deve ser nulo pra tirar o \n
    argv[ 0 ] = strtok( lc, " " ); // carrega o nome da instrução para a primeira posição do vetor argv
    if( ! strcmp( argv[ 0 ], "exit" ) ) // se a instrução for sair então
    exit(  ); // dê a syscall para parar a execução e sair do programa
    i = 1;
    while( i < 20 && (argv[ i ] = strtok( 0, " " )) ) // carrega para o vetor argv os parâmetros da função lida
    ++i;
    if( (pid = fork()) == -1 ) { // se a syscall de fork teve problema
      printf(2, "Erro no fork\n" ); // escreva na saída padrão de erro(stderr ou 2) que deu erro ao criar o filho
      exit(  ); // dê a syscall para parar a execução e sair do programa
    }
    /*
    A partir do fork existem duas linhas de execução: a do processo filho e a do pai
    o fork faz com que seja feita uma cópia binária(byte por byte) do programa que chamou o fork
    no processo pai a variável pid recebe a id do processo filho
    no processo filho a variável pid recebe 0
    */


    if( pid == 0 ) // se esse é o processo filho
      if( exec( argv[ 0 ], argv ) ) { // se a execução do filho teve algum problema e não retornou 0
        printf(2, "Erro no execv\n" ); // escreva na saída padrão de erro(stderr ou 2) que deu erro ao rodar o programa
        exit(  ); // dê a syscall para parar a execução e sair do programa
    }
    wait(); // espera o processo filho terminar sua execução para voltar ao começo do loop
  }
}
