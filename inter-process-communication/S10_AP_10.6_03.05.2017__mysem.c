#include<stdio.h>
#include<stdlib.h>
#include<sys/sem.h>
#include<sys/types.h>
#include<sys/ipc.h>
#include<pthread.h>
int ID;
union semun {
 int val;
 struct semid_ds *buf;
 unsigned short int *array;
 };
int state=1;
int sem_init(int no_of_sems, int common_intial_value)
{
 union semun tmp;
 key_t h=ftok(".", state++);
 int i,sem_id=semget(h, no_of_sems, IPC_CREAT|0666);

 if(sem_id==-1)
 {
  printf("Semaphore init error\n");
  exit(1);
 }
 tmp.val=common_intial_value;

 for(i=0; i<no_of_sems; i++)
  semctl(sem_id, i, SETVAL, tmp);
 return sem_id;
}



int sem_init_diff_val(int no_of_sems, int *array)
{
 key_t h=ftok(".", state++);
 int sem_id=semget(h, no_of_sems, IPC_CREAT|0666);
 if(sem_id==-1)
 {
  printf("Semaphore init error\n");
  exit(1);
 }
 union semun tmp;//.array=array;
 tmp.array=(unsigned short int*)array;
 semctl(sem_id, 0, SETALL, tmp);
 return sem_id;
}



void sem_change(int sem_id, int sem_no, int amount)
{
 struct sembuf tmp;
 tmp.sem_num=sem_no;
 tmp.sem_flg=0;
 tmp.sem_op=amount;
 if(semop(sem_id, &tmp, 1)==-1)
  {
   printf("Sem_op error\n");
   exit(1);
  }
}

int sem_try_change(int sem_id, int sem_no, int amount)
{
 struct sembuf tmp;
 tmp.sem_num=sem_no;
 tmp.sem_flg=IPC_NOWAIT;
 tmp.sem_op=amount;
 return semop(sem_id, &tmp, 1);
  
}
