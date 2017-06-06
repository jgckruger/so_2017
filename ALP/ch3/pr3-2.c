#include <stdlib.h>
int main ()
{
  int return_value;
  return_value = system ("ls -l /"); // roda o comando entre parenteses criando um novo shell
  return return_value;
}
