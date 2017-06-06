#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
int main ()
{
  pid_t child_pid;
  printf ("the main program process ID is %d\n", (int) getpid ());
  child_pid = fork ();
  if (child_pid != 0) { // se pai
    printf ("this is the parent process, with id %d\n", (int) getpid ()); // pid do processo
    printf ("the child’s process ID is %d\n", (int) child_pid); // pid do filho
  }
  else // se filho
  printf ("this is the child process, with id %d\n", (int) getpid ()); // pid do processo filho
  return 0;
}
