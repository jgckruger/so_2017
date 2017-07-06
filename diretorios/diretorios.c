//
// DIRETORIOS.C
//
#include <dirent.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>


static int pesquisa(const char *arg, const char *path, const char *raiz)
{
    DIR *dirpont;
    struct dirent *dp;

    int achou = 0;

    if ((dirpont = opendir(path)) == NULL) {
        perror( "nao pode abrir '.': ");
        //printf( "nao pode abrir '%s'\n\n", dir);
        return 0;
    }
    do {
        errno = 0;
        if ((dp = readdir(dirpont)) != NULL) {
            // SE É O PRÓPRIO DIRETÓRIO OU É O DIRETÓRIO PAI PULA RESTO DO WHILE
            //printf("nome: %s\n", dp->d_name);
            //printf("1 comp\n");
            if ((strcmp(dp->d_name, ".") == 0  ||  strcmp(dp->d_name, "..") == 0))
                continue;
            //printf("2 comp\n");
            if((strcmp(dp->d_name, arg) == 0 )){ // SE ACHOU
              struct stat infoArquivo;
              char pathDir[1000];
              memset(pathDir, 0, sizeof(pathDir));
              strcat(pathDir,path);
              strcat(pathDir,"/");
              strcat(pathDir,dp->d_name);
              stat(pathDir, &infoArquivo);
              (void) printf("Achado:\n diretorio: %s/%s \n tipo:%d\n tamanho: %ld bytes\n numero de blocos: %ld blocos\n tamanho de bloco: %ld bytes\n tamanho em disco: %ld bytes\n", path, dp->d_name, dp->d_type, infoArquivo.st_size, infoArquivo.st_blocks, infoArquivo.st_blksize, infoArquivo.st_blocks* infoArquivo.st_blksize);
              //(void) printf("%s/%s \ntipo:%d\n", path, dp->d_name, dp->d_type);
              (void) closedir(dirpont);
              return 1;
            }
            //printf("3 comp\n");
            if(dp->d_type == DT_DIR){ // SE É DIRETÓRIO BUSCÁVEL
              char pathDir[1000];
              memset(pathDir, 0, sizeof(pathDir));
              strcat(pathDir,path);
              strcat(pathDir,"/");
              strcat(pathDir,dp->d_name);
              // printf("pathDir: %s\n", pathDir);
              achou = pesquisa(arg, pathDir, raiz);
              if(achou)
                return achou;
              continue;
            }
        }
    } while (dp != NULL);

    if(!achou)
    //(void) printf("Falha ao procurar: %s\n", arg);
    //printf("path:%s\nraiz:%s\n comp: %d\n", path, raiz, strcmp(path, raiz));
    if(strcmp(path, raiz) == 0){
      if (errno != 0)
          perror("Erro lendo o diretorio\n\n");
      else
          (void) printf("Falha ao procurar: %s\n", arg);
    }
    (void) closedir(dirpont);
    return 0;
}

int main(int argc, char *argv[])
{
    int i;

    if( argc < 2 ) {
       printf( "USO: %s nome_arquivo ...\n\n", argv[ 0 ] );
       return( -1 );
    }
    for (i = 1; i < argc; i++)
        pesquisa( argv[i] , ".", ".");
    return (0);
}
