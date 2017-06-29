#include <stdio.h>
#include <stdlib.h>


// Autor: João Gabriel Corrêa Krüger
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

void firstFit(struct header ** anterior, struct header ** atual, int tam){
  while(atual!=NULL)
  {
      printf("atual->tam %d\n", (*atual)->tam);
      if((* atual)->tam < tam+sizeof(struct header))
      {
        // printf("procurando lugar");
        *anterior = *atual;
        *atual = (*atual )-> prox;
      }
      else
        return;
  }
  atual = NULL; anterior = NULL;
}

void worstFit(struct header ** ant, struct header ** at, int tam){
  struct header ** anteriorMaior = ant;
  struct header ** maior = at;

  struct header * atual = *at;
  struct header * anterior = *ant;
  int maiorTam = -1;
  while(atual!=NULL)
  {
    printf("atual->tam %d\n", atual->tam);
    if(atual->tam < tam+sizeof(struct header))
    {
      anterior = atual;
      atual = atual->prox;
    }
    else // cabe
    {
      if(atual->tam > maiorTam) // maior buraco achado
      {
        maiorTam = atual->tam;
        *maior = atual;
        *anteriorMaior = anterior;
      }
      anterior = atual;
      atual = atual->prox;
    }
  }
  if(maiorTam != -1) // achou
  {
    *ant = *anteriorMaior;
    *at = *maior;
  }
  else
  {
    *at=NULL;
    *ant=NULL;
  }
}

void bestFit(struct header ** ant, struct header ** at, int tam){
  struct header ** anteriorMelhor = ant;
  struct header ** melhor = at;

  struct header * atual = *at;
  struct header * anterior = *ant;

  int found = 0;

  while(atual!=NULL)
  {
    printf("atual->tam %d\n", atual->tam);
    if(atual->tam < tam+sizeof(struct header))
    {
      anterior = atual;
      atual = atual->prox;
    }
    else // cabe
    {
      if(!found || (((*melhor)->tam-tam)>(atual->tam-tam))) // maior buraco achado
      {
        *melhor = atual;
        *anteriorMelhor = anterior;
        found = 1;
      }
      anterior = atual;
      atual = atual->prox;
    }
  }
  if(found) // achou
  {
    *ant = *anteriorMelhor;
    *at = *melhor;
  }
  else
  {
    *at=NULL;
    *ant=NULL;
  }
}


void * meu_aloca(int tam){
//         aloco de acordo com o algoritmo (first, best, worst, next)
struct header * anterior = listaLivres;
struct header * atual = listaLivres;

  //worstFit(&anterior, &atual, tam);
  //firstFit(&anterior, &atual, tam);
  bestFit(&anterior, &atual, tam);
  if(atual!=NULL){
        printf("bloco de %d\nalocado %d\n", atual->tam, tam);
        if(atual->tam==(sizeof(struct header)+tam)){
          //if(atual->tam==tam) || tam + sizeof(struct header) < atual->tam){
          //printf("perfect fit");
          anterior->prox=atual->prox;
          atual->prox=NULL;
          //atual->tam=tam;
        }
        else
        {
          //printf("atual tam %d\n", atual->tam);
          //printf("ajustando");
          struct header * aux = atual->prox;
          struct header * novoBloco = atual+tam+sizeof(struct header);
          anterior->prox=novoBloco;
          novoBloco->prox=aux;
          //atual->prox=NULL;
          //printf("atual prox tam %d", atual->prox->tam);
          //printf("atual tam%d\n", atual->tam);
          novoBloco->tam=atual->tam-sizeof(struct header)-tam;
          atual->tam=tam;
          //printf("atual prox tam %d", atual->prox->tam);
          //printf("atual prox tam%d\n", atual->prox->tam);
          //printf("atual tam %d \n", atual->tam);
        }
        if(atual==listaLivres)
          listaLivres=atual->prox;

        // printf("alocado %d tamanho %d\n", atual, atual->tam );
        atual->prox=NULL;
        return (int)atual+sizeof(struct header); // retorna o endereço base onde está a memória alocada
  }
  printf("Impossivel alocar espaço\n");
}

int merge(struct header * anterior, struct header * posterior)
{
  //printf("%d %d %d\n", anterior, posterior, posterior-anterior-anterior->tam-sizeof(struct header));
  if((posterior-anterior-anterior->tam-sizeof(struct header))==0)
  {
    anterior->prox=posterior->prox;
    anterior->tam=sizeof(struct header)+anterior->tam+posterior->tam;
    //printf("%d novo bloco\n", sizeof(struct header)+anterior->tam+posterior->tam);
    return 1;
  }
  return 0;
}

void meu_libera(void * ponteiro)
{
  struct header * endHeader = ponteiro-sizeof(struct header);
  struct header * anterior = listaLivres;
  struct header * atual = listaLivres;

  if((int)endHeader<(int)listaLivres){
    endHeader->prox=listaLivres;
    listaLivres=endHeader;
    printf("liberado %d\n", endHeader->tam);
    merge(endHeader, endHeader->prox);
    return;
    //listaLivres->prox=atual;
  }

  while(atual < endHeader)
  {
    anterior=atual;
    //printf("pao %d\n",atual->tam);
    atual=atual->prox;
  }

  endHeader->prox=anterior->prox;
  anterior->prox = (struct header*) endHeader;
  //((struct header*) endHeader)->prox = atual;
  printf("liberado %d\n", endHeader->tam);
  if(merge ( (struct header *)anterior,(struct header *) endHeader))
      merge ((struct header *) anterior, (struct header *)atual);
  else
    merge ((struct header *) endHeader, (struct header *)atual);
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

int a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13;
int main()
{
  int teste;
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
  printf("\n\n\n\n\n\n");
  meu_libera(a3);
  printf("\n\n\n\n\n\n");
  mostra_livres();
  printf("\n\n\n\n\n\n");
  mostra_mem();
  printf("\n\n\n\n\n\n");
  meu_libera(a10);

  // a11 =  meu_aloca(20);
  // mostra_mem();
  // a12 =  meu_aloca(12);
  // mostra_mem();
  // a13 =  meu_aloca(40);
  // mostra_mem();
  printf("\n\n\n\n\n\n");printf("\n\n\n\n\n\n");
  //printf("aloca 100\n");
  teste = meu_aloca(100);
  mostra_livres();
  printf("\n\n\n\n\n\n");
  mostra_mem();
  printf("\n\n\n\n\n\n");
  //printf("libera 100\n");
  meu_libera(teste);
  mostra_livres();
  printf("\n\n\n\n\n\n");
  mostra_mem();
  printf("\n\n\n\n\n\n");
  //printf("aloca 12\n");
  teste = meu_aloca(12);
  mostra_livres();
  printf("\n\n\n\n\n\n");
  mostra_mem();
  printf("\n\n\n\n\n\n");
  meu_libera(teste);
  mostra_livres();
  printf("\n\n\n\n\n\n");
  mostra_mem();
  printf("\n\n\n\n\n\n");
  meu_libera(a1);
  mostra_livres();
  printf("\n\n\n\n\n\n");
  mostra_mem();
  printf("\n\n\n\n\n\n");

}
