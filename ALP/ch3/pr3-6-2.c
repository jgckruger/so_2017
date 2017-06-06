int main ()
{
  int child_status;
  /* The argument list to pass to the "ls" command.  */
  char* arg_list[] = {
    "ls",     /* argv[0], the name of the program.  */
    "-l",
    "/",
    NULL      /* The argument list must end with a NULL.  */
  };
  /* Spawn a child process running the "ls" command.  Ignore the
  returned child process ID.  */
  spawn ("ls", arg_list);
  /* Wait for the child process to complete.  */
  wait (&child_status);
  if (WIFEXITED (child_status))
  printf ("the child process exited normally, with exit code %d\n",
    WEXITSTATUS (child_status));
    else
    printf ("the child process exited abnormally\n");
    return 0;
  }
