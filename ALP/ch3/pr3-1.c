#include <stdio.h>
#include <unistd.h>
int main ()
{
  printf ("The process ID is %d\n", (pid_t) getpid ()); // PID DO PROCESSO
  printf ("The parent process ID is %d\n", (pid_t) getppid ()); // PID DO PAI
  return 0;
}
