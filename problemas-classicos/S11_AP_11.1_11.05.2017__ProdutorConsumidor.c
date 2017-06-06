#include<stdio.h>
#include<stdlib.h>
#include<sys/types.h>
#include<pthread.h>
#include "mysem.c"

#define MAX_BUF 10

int *buffer;
int head=0,tail=0,item_id=1;
int count=0;
int sem_ID; // 3 semaphores... { Mutex, Empty, Full}
int fflag=0,eflag=0;

void producer()
{
  printf("Producer started\n");
  while(1) 
  {
     int v=0;
     sem_change(sem_ID, 0, -1);
     if(count==MAX_BUF)
     {
        printf("Producer waiting\n");
        fflag=1;
	sem_change(sem_ID, 0, 1);
	sem_change(sem_ID, 2, -1);
	sem_change(sem_ID, 0, -1); //Waits until a free slot is available
     }
     count++;
     buffer[head]=item_id++;
     if(count==1 && eflag==1)
     {
        eflag=0;
        sem_change(sem_ID, 1, 1); //To signal consumer thread that buffer is not empty
     }
     printf("produced item:%d \n", buffer[head]);
     head=(head+1)%MAX_BUF;
     sem_change(sem_ID, 0, 1);
     sleep(rand()%3);
  }
}

void consumer()
{
  printf("consumer started\n");
  while(1)
  {
    int v=0;
    sem_change(sem_ID, 0, -1);
    if(count==0)
    {
      printf("Consumer Waiting\n");
      eflag=1;
      sem_change(sem_ID, 0, 1);
      sem_change(sem_ID, 1, -1);
      sem_change(sem_ID, 0, -1);
      //Waits until an item is produced
    }
    count--;
    printf("consumed item:%d \n", buffer[tail]);
    tail=(tail+1)%MAX_BUF;
    if(count==MAX_BUF-1 && fflag==1) 
    {
      fflag=0;
      sem_change(sem_ID, 2, 1); //To signal the producer thread that buffer is not full
    }
       
    sem_change(sem_ID, 0, 1);
    sleep(rand()%4);
  }
}


int main()
{
  buffer=(int*)calloc(MAX_BUF,sizeof(int));
  pthread_t pro,con;
  int values[]={1,0,0};
  sem_ID=sem_init_diff_val(3, values); //initialize with 1, 0, 0
  pthread_create(&pro, NULL, (void*)&producer, NULL);
  pthread_create(&con, NULL, (void*)&consumer, NULL);
  pthread_join(pro,NULL);
  return 0;
}
