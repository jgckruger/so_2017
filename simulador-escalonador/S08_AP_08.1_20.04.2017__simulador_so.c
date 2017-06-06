//
//  Exemplo de simula��o simples de escalonamento
//
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/time.h>

#define NUM_PROCESSOS   20
#define TAM_MEMORIA   1999
#define NUM_TICKS       2

//#define DEBUG

int processo_id = -1, pid = 0;

enum estado_Tarefa {
    RODANDO,  PRONTA, BLOQUEADA, DORMINDO,
    SUSPENSA, MORTA
};

struct {
   int id,             // PID do processo....
	 ci,                 // contador de instrucoes
	 bd,                 // base de dados - memoria
	 r0, r1, r2, r3, r4; // registradores
} _cpu;

int memoria[ TAM_MEMORIA ];

struct lista_Processos {
    int prim,           // cabeca da lista
        ultm;           // cauda
} prontos;

struct {
    int id,                     // PID do processo....
	  ci,                          // contador de instrucoes
	  bd,                          // base de dados - memoria
	  r0, r1, r2, r3, r4;          // registradores
    enum estado_Tarefa estado;
    void (*processo)();         // ponteiro para o processo
    int proximo;                // link para proximo processo.
} tabela_Processos[ NUM_PROCESSOS ];


void kernel_panic( char *mensagem )
{
    printf( "KERNEL PANIC: %s...\n", mensagem );
    exit( 0 );
}


void salva_contexto()
{
  tabela_Processos[ pid ].ci = _cpu.ci;
  tabela_Processos[ pid ].bd = _cpu.bd;
  tabela_Processos[ pid ].r0 = _cpu.r0;
  tabela_Processos[ pid ].r1 = _cpu.r1;
  tabela_Processos[ pid ].r2 = _cpu.r2;
  tabela_Processos[ pid ].r3 = _cpu.r3;
  tabela_Processos[ pid ].r4 = _cpu.r4;
}

void restaura_contexto()
{
  _cpu.ci = tabela_Processos[ pid ].ci;
  _cpu.bd = tabela_Processos[ pid ].bd;
  _cpu.r0 = tabela_Processos[ pid ].r0;
  _cpu.r1 = tabela_Processos[ pid ].r1;
  _cpu.r2 = tabela_Processos[ pid ].r2;
  _cpu.r3 = tabela_Processos[ pid ].r3;
  _cpu.r4 = tabela_Processos[ pid ].r4;
}

#ifdef DEBUG

  void mostra_tabela_Processos( void )
  {
       int _ii;
       printf("\tPID- PROX CI-- BD-- R0-- R1-- R2-- R3-- R4--\n" );
       printf("\t==== ==== ==== ==== ==== ==== ==== ==== ====\n" );
       for( _ii = 0; _ii <= processo_id; ++_ii ) {
           printf("\t%4d %4d %4d %4d %4d %4d%4d %4d %4d\n", tabela_Processos[ _ii ].id,
                                                          tabela_Processos[ _ii ].proximo,
                                                          tabela_Processos[ _ii ].ci,
                                                          tabela_Processos[ _ii ].bd,
                                                          tabela_Processos[ _ii ].r0,
                                                          tabela_Processos[ _ii ].r1,
                                                          tabela_Processos[ _ii ].r2,
                                                          tabela_Processos[ _ii ].r3,
                                                          tabela_Processos[ _ii ].r4
                                                          );
       }
    }

#endif

int escolhe_processo()
{
  int meu_pid;

  #ifdef DEBUG

    printf("DEBUG: escolhe_processo processo_id:%3d proximo: %3d\n", pid, tabela_Processos[ pid ].proximo );
    mostra_tabela_Processos();

  #endif

  meu_pid = tabela_Processos[ pid ].proximo;
  if( meu_pid < 0 )
      meu_pid = processo_id;  // estah mandando para o ultimo...
  return meu_pid;
}

void escalonador ( int signum )
{
  static int contador = 0;
  static volatile int reentrada = 0;

  if( reentrada > 0 ) {
    kernel_panic( "\n\nChamando escalonador 2x!!!\n\n" );
  }

  reentrada = 1;

  #ifdef DEBUG

     printf ( "DEBUG: relogio contador: %d\n", contador );

  #endif

  salva_contexto();
  if( ++contador > NUM_TICKS ) {
    pid = escolhe_processo();
    contador = 0;
  }
  restaura_contexto();
  reentrada = 0;
  (tabela_Processos[ pid ].processo)();
}

void init_proc( void )
{
  struct sigaction sa;
  struct itimerval relogio;

  memset( memoria, 0, TAM_MEMORIA );
  memset( &sa, 0, sizeof( sa ) );

  sa.sa_handler = &escalonador;
  sigaction( SIGVTALRM, &sa, NULL );   // registra o manipulador do SIGVTALARM - escalonador

int memoria[ TAM_MEMORIA ];

struct lista_Processos {
    int prim,           // cabeca da lista
        ultm;           // cauda
} prontos;

struct {
    int id,                     // PID do processo....
	 ci,                     // contador de instrucoes
  relogio.it_value.tv_sec = 0;
  relogio.it_value.tv_usec = 200000;
  relogio.it_interval.tv_sec = 0;
  relogio.it_interval.tv_usec = 200000;
  setitimer( ITIMER_VIRTUAL, &relogio, NULL );  // registra o intervalo para cada SIGVTALARM
}

int cria_processo( void (*proc)() )
{
    #ifdef DEBUG

       printf( "DEBUG: cria_processo processo_id: %d\n", processo_id );
       mostra_tabela_Processos();

    #endif

    if( processo_id < NUM_PROCESSOS-1 ) {
      tabela_Processos[ ++processo_id ].id       = processo_id;
      tabela_Processos[   processo_id ].ci       = 0;
      tabela_Processos[   processo_id ].bd       = 0;
      tabela_Processos[   processo_id ].r0       = 0;
      tabela_Processos[   processo_id ].r1       = 0;
      tabela_Processos[   processo_id ].r2       = 0;
      tabela_Processos[   processo_id ].r3       = 0;
      tabela_Processos[   processo_id ].r4       = 0;
      tabela_Processos[   processo_id ].processo = proc;

      if( processo_id > 0 )
        tabela_Processos[ processo_id ].proximo  = processo_id-1;
      else
        tabela_Processos[ processo_id ].proximo  = -1;

    } else
      kernel_panic( "muitos processos" );
}

void processo_1( void )
{
    switch( _cpu.ci ) {
      case 0 : printf( "1: Este � o processo 1\n" );
               _cpu.ci++;
               break;
      case 1 : _cpu.ci = 0;
               break;
    }
}

void processo_2( void )
{
    switch( _cpu.ci ) {
       case 0 : printf( "2: Este � o processo 2\n" );
               _cpu.ci++;
                break;
       case 1 : printf( "2: Fazendo alguma outra coisa\n" );
               _cpu.ci++;
                break;
       case 2 : printf( "2: Ainda fazendo algo...\n" );
               _cpu.ci++;
                break;
       case 3 : _cpu.ci = 0;
                break;
    }
}

void processo_3( void )
{
    switch( _cpu.ci ) {
       case 0 : printf( "3: Este � o processo 3\n" );
               _cpu.ci++;
                break;
       case 1 : _cpu.ci = 0;
                break;
    }
}

void processo_4( void )
{
    switch( _cpu.ci ) {
       case 0 : printf( "4: Este � o processo 4\n" );
               _cpu.ci++;
                break;
       case 1 : _cpu.ci = 0;
                break;
    }
}

int main ()
{
  init_proc();
  cria_processo( (void *) processo_1);
  cria_processo( (void *) processo_2 );
  cria_processo( (void *) processo_3 );
  cria_processo( (void *) processo_4 );
  while( 1 )
     ;
}
