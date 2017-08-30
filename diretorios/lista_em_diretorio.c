/***********************************************************************************/
/*Mostra todos os arquivos, diretórios e sub-diretórios da pasta onde for executado*/
/* utilizando um algoritmo de busca em largura. MHH                                */
/***********************************************************************************/
#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static void pesquisa(char* diretorio,const char* arg)
{
  DIR *dirpont;
  struct dirent *dp;
  int encontrou = 0;
  if(dirpont == NULL)
    if ((dirpont = opendir(".")) ==  NULL) {
      perror(" Nao pode abrir \n");
      return;
    }

  do {
    errno = 0;
    if ((dp = readdir(dirpont)) != NULL) {
      //(void) printf("%s: %s ",diretorio, dp -> d_name);
      switch (dp->d_type ) {
        case 0:

          //printf(" - Desconhecido\n");
          break;

        case 8:

          //printf(" - Arquivo\n");
          if(strcmp(arg,dp->d_name) == 0)
          {
            encontrou = 1;
          }
          break;

        case 4:

            //printf(" - Diretorio \n");
            usleep(100);
            if((strcmp(dp->d_name,".") != 0) && (strcmp(dp->d_name,"..") != 0))
            {
              chdir(dp->d_name);
              pesquisa(dp->d_name,arg);
              chdir("..");
            }
            break;

      }
    }
  } while(dp != NULL);

  if(encontrou == 1)
  {
    printf(">>>>>> %s encontrado <<<<<<<\n", arg);
    encontrou = 0;
  }

  if (errno != 0) {
    perror("Erro lendo o diretorio\n\n");
  }
  (void) closedir(dirpont);
  return;
}

int main(int argc, char const *argv[]) {
  pesquisa(".", argv[1]);
  return 0;
}
