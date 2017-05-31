#include <stdio.h>
#include <stdlib.h>

int tamMemoria = 10240;

struct header{
  int tam;
  struct header * prox;
};

struct header * listaLivres;
void * endBaseMemoria;

void inicializa_mem()
{
  listaLivres = endBaseMemoria = malloc(tamMemoria);       // endereço base da memória
  ((struct header *)listaLivres)->tam = tamMemoria-sizeof(struct header); // trata lista como um endereço de struct e
                                                                          // atribui a ela o tamanho de espaço vazio
  ((struct header *)listaLivres)->prox=NULL;                                // nao existe próximo bloco
   printf("%d %d\n", listaLivres->tam, (int)listaLivres->prox);             // debug
}


void * meu_aloca(int tam){
//         aloco de acordo com o algoritmo (first, best, worst, next)
struct header * anterior = listaLivres;
struct header * atual = listaLivres;


  while(atual!=NULL)
  {
      if(atual->tam < tam+sizeof(struct header))
      {
        anterior = atual;
        atual = atual -> prox;
      }
      else
      {
        if(atual->tam==(sizeof(struct header)+tam)){
        //if(atual->tam==tam) || tam + sizeof(struct header) < atual->tam){
          anterior->prox=atual->prox;
          //atual->tam=tam;
        }
        else
        {
          atual->prox=atual+tam+sizeof(struct header);
          atual->prox->tam=atual->tam-tam-sizeof(struct header);
          atual->tam=tam;
        }
        if(atual==listaLivres)
          listaLivres=atual->prox;

        // printf("alocado %d tamanho %d\n", atual, atual->tam );
        atual->prox=NULL;
        return (int)atual+sizeof(struct header); // retorna o endereço base onde está a memória alocada
      }
  }
  printf("Impossivel alocar espaço\n");
}

void merge(void * anterior, void * posterior)
{
  if((((int)anterior+(int)((struct header *)anterior)->tam+sizeof(struct header))==(int)posterior))
    ((struct header *)anterior)->tam=((struct header *)anterior)->tam+((struct header *)posterior)->tam+sizeof(struct header);
}

void meu_libera(void * ponteiro)
{
  struct header * endHeader = ponteiro-sizeof(struct header);
  struct header * anterior = listaLivres;
  struct header * atual = listaLivres;

  while((void *)atual < endHeader)
  {
    anterior=atual;
    atual=atual->prox;
  }
  if(endHeader<listaLivres){
    endHeader->prox=listaLivres;
    listaLivres=(struct header *) endHeader;
    //listaLivres->prox=atual;
  }
  else{
    endHeader->prox=anterior->prox;
    anterior->prox = (struct header*) endHeader;
    //((struct header*) endHeader)->prox = atual;
  }
  // printf("liberado\n");
  // merge ( anterior, endHeader);
  // merge ( endHeader, atual);
}

void mostra_mem(){
  int tam = 0;
  struct header * atual = endBaseMemoria;
  while(tam<tamMemoria)
  {
    printf("bloco de %d bytes + %d bytes de header = %d bytes\n", atual->tam,
      sizeof(struct header), atual->tam + sizeof(struct header));
      tam+=atual->tam+sizeof(struct header);
    atual=atual->tam+sizeof(struct header)+atual;
  }
}

void mostra_livres()
{
  struct header * atual =(struct header *) listaLivres;
  while(atual != NULL)
  {
    printf("Tamanho do bloco livre: %d\n", atual->tam);
    atual=atual->prox;
  }
}

int main()
{
  int a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13;
  inicializa_mem();
  //mostra_mem();
  a1  =  meu_aloca(10);
  a2  =  meu_aloca(5);
  a3  =  meu_aloca(20);
  // a4  =  meu_aloca(30);
  // a5  =  meu_aloca(15);
  // a6  =  meu_aloca(40);
  // a7  =  meu_aloca(60);
  // a8  =  meu_aloca(80);
  // a9  =  meu_aloca(100);
  mostra_mem();
  printf("\n\n\n\n\n\n");
  mostra_livres();
  meu_libera( a2 );
  printf("\n\n\n\n\n\n");
  mostra_livres();
  printf("\n\n\n\n\n\n");
  mostra_mem();
  // meu_libera( a4 );
  // mostra_mem();
  // meu_libera( a5 );
  // meu_libera( a7 );
  // meu_libera( a9 );
  // mostra_mem();
  a10 =  meu_aloca(3);
  printf("\n\n\n\n\n\n");
  mostra_livres();
  printf("\n\n\n\n\n\n");
  mostra_mem();
  // a11 =  meu_aloca(20);
  // mostra_mem();
  // a12 =  meu_aloca(12);
  // mostra_mem();
  // a13 =  meu_aloca(40);
  // mostra_mem();
}
