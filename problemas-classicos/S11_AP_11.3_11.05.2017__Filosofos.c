#include<stdio.h>
#include<stdlib.h>
#include<pthread.h>

#define PHILOSOPHERS 5

pthread_mutex_t spoon[PHILOSOPHERS];
//Intializes the philosopher threads
void phil_init(int a, int* b, int* c)
{
	*b=(a>0) ? a-1 : PHILOSOPHERS;
	*c=a;
	printf("Philosopher %d started\n", a+1);
	return;
}

int check_If_Spoons_Are_Available(int a, int b, int c)
{
	int sum=0;
	if(a&1) {
		sum = pthread_mutex_trylock(&spoon[c])==0 ? 0 : 10;
		sum += pthread_mutex_trylock(&spoon[b])==0 ? 0 : 1;
	} else {
		sum = pthread_mutex_trylock(&spoon[b])==0 ? 0 : 1;
		sum += pthread_mutex_trylock(&spoon[c])==0 ? 0 : 10;
	}
return sum;
}

void Release_Spoons(int a, int b, int c)
{
	if(a&1) {
		pthread_mutex_unlock(&spoon[b]);
		pthread_mutex_unlock(&spoon[c]);
	} else {
		pthread_mutex_unlock(&spoon[c]);
		pthread_mutex_unlock(&spoon[b]);
	}
}

void wait_for_others_to_finish(int a, int b ,int c, int d)
{
	switch( a ) {
		case  1: printf("Philosopher %d waiting since right spoon is unavailable\n",b+1);
			  pthread_mutex_lock(&spoon[c]);
			  break;
		case 10: printf("Philosopher %d waiting since left spoon is unavailable\n", b+1); 
			  pthread_mutex_lock(&spoon[d]);
			  break;
		case 11: printf("Philosopher %d waiting since both spoons are unavailable\n", b+1);
		    	  if( a&1 ) {
				pthread_mutex_lock(&spoon[d]);
				pthread_mutex_lock(&spoon[c]);
			  } else {
				pthread_mutex_lock(&spoon[d]);
				pthread_mutex_lock(&spoon[c]);
			  }
			  break;
	}
return;
}

void Eat(int a)
{
	printf("philosopher %d eating\n", a+1);
	sleep(rand()%5);
	printf("philosopher %d finished eating\n", a+1);
}

void philo(void * arg)
{
	int back;
	int front;
	int tmp;
	int id=*((int*)arg);

	phil_init(id, &back, &front);
	while(1) {
		printf("philosopher %d thinking\n", id+1);
		sleep(rand()%6);
		if((tmp=check_If_Spoons_Are_Available(id, back, front))!=0)
			wait_for_others_to_finish(tmp, id, back, front);
		Eat(id);
		Release_Spoons(*((int*)arg), back, front);
	}
}

int main(int argc, char* argv[])
{
	pthread_t S[PHILOSOPHERS];
	int *g;

	for(int i=0; i<PHILOSOPHERS; i++)
		pthread_mutex_init(&spoon[i], NULL);
	g=(int*)malloc(PHILOSOPHERS*sizeof(int));
	for(int i=0; i<PHILOSOPHERS; i++) {
		g[i]=i;
		pthread_create(&S[i], NULL, (void*)&philo,(void*)&g[i]);
	}
	pthread_join(S[0], NULL);
	exit(0);
}
