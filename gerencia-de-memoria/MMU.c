#include <stdio.h>
#include <stdlib.h>

// Autor: Michel Hoekstra

struct hole{
    int tam;
    struct hole *next;
    struct hole *prev;
};
struct hole * hole_list;
int hole_size  = sizeof(struct hole);
void inicializa_memoria(int n);
void* meu_aloca(int n);
void  meu_desaloca(void* n);
void imprime();

int main(void)
{
    void *p,*q, *t;
    imprime();
    inicializa_memoria(100);
    p = meu_aloca(12);
    q = meu_aloca(12);

    imprime();

    meu_desaloca(q);
    t=meu_aloca(5);
    meu_desaloca(p);
    imprime();
    return 0;
}

void inicializa_memoria(int size)
{
    if(size < hole_size)
    {
        size = hole_size + size;
    }
    hole_list = malloc(size);
    hole_list -> tam = size - hole_size;
    hole_list->next = NULL;
    hole_list->prev = NULL;
}

void meu_desaloca(void* p)
{
    struct hole* current_hole,*prev_hole,*next_hole;
    void *aux;
    aux = p - hole_size;
    current_hole = aux;
    prev_hole = current_hole->prev;
    next_hole = current_hole->next;
    current_hole->tam = (-1)*current_hole->tam;
    if(next_hole != NULL)
     {
        if(next_hole -> tam > 0)
        {
        current_hole->tam = current_hole->tam +hole_size + next_hole->tam;
        current_hole->next = next_hole->next;
        if(current_hole->next != NULL)
        {
            current_hole->next->prev = current_hole;
        }
      }
    }
    if(prev_hole != NULL)
    {
        if(prev_hole->tam > 0){
        prev_hole->tam = prev_hole->tam + current_hole->tam + hole_size;
        prev_hole->next = current_hole->next;
        if(current_hole->next != NULL)
        {
            current_hole->next->prev = prev_hole;
        }
      }
    }
}
void* meu_aloca(int size)
{
    struct hole *current_hole,*prev_hole,*next_hole;
    void *aux;
    current_hole = hole_list;
    while(current_hole != NULL)
    {
        if(current_hole->tam == size)
        {
            aux = current_hole;
           current_hole->tam = (-1)*current_hole->tam;
           return (aux + hole_size);
        }
        if(current_hole->tam > (size + hole_size))
        {
            prev_hole = current_hole;
            next_hole = current_hole->next;
            printf("\n%d\n\n",current_hole);
            aux = (void*)prev_hole + prev_hole->tam -size -hole_size;
            printf("\n%d\n\n",aux);
            current_hole = aux;

            current_hole->tam = -size;
            current_hole->next = next_hole;
            current_hole->prev = prev_hole;
            prev_hole->next = current_hole;
            prev_hole->tam = prev_hole->tam - size - hole_size;
            if(next_hole != NULL)
            {
                next_hole->prev = current_hole;
            }
            printf("\n%d\n",current_hole+hole_size);
            return (aux + hole_size);
        }
        current_hole = current_hole->next;
    }
    return NULL;
}
void imprime()
{
    struct hole *current_hole;
    current_hole = hole_list;
    while(current_hole != NULL)
    {
        printf("\nEndere�o do buraco -> %d\nTamanho do buraco -> %d\nProximo buraco -> %d\nBuraco anterior -> %d\n\n",current_hole,current_hole->tam,current_hole->next,current_hole->prev);
        current_hole = current_hole->next;
    }
}
