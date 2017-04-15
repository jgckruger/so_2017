# coding: utf-8

from threading import Condition, Thread                                     # Mutex(Condition) e Threads
from time import sleep                                                      # Sleep
from random import randint, random                                          # números aleatórios

fila = []                                                                   # Fila de mensagens
MAX_NUM = 5                                                                 # Tamanho máximo da fila de mensagens
mutex = Condition()                                                         # Criado o mutex

class Produtor(Thread):                                                     # Produtor é criado numa Thread
    def run(self):                                                          # Ao startar a thread
        global fila                                                         # Declara que vai usar a fila
        while True:                                                         # Loop infinito
            mutex.acquire()                                                 # Pede ao Mutex que execute sozinho a partir daqui (lock)
            if len(fila) == MAX_NUM:                                        # Se a fila está cheia
                print "Fila cheia, Produtor está aguardando"                # Printa que fila está cheia e irá esperar
                mutex.wait()                                                # Waiting até o consumidor consumir (Thread acorda numa call de notify)
                                                                            # wait libera a lock até ser notificado, após ser notificado tenta readquirir
                print "Espaço na fila, o Consumidor avisou o Produtor"      # Produtor voltou do wait(readquiriu a lock), segue a execução
            num = randint(0, 5)                                             # Gera um número aleatório (Simboliza uma mensagem)
            fila.append(num)                                                # Insere na fila de mensagens
            print "Produzido", num                                          # Printa que inseriu
            mutex.notify()                                                  # Acorda a thread esperando pela sua vez de usar a lock
            mutex.release()                                                 # Libera a lock
            sleep(random())                                                 # Espera quantidade aleatória de tempo entre 0 e 1, faz com que exista variação na velocidade de produção e consumo


class Consumidor(Thread):                                                   # Consumidor é criado numa Thread
    def run(self):                                                          # Ao startar a thread
        global fila                                                         # Declara que vai usar a fila
        while True:                                                         # Loop infinito
            mutex.acquire()                                                 # Pede ao Mutex que execute sozinho a partir daqui (lock)
            if not fila:                                                    # Se a fila está vazia
                print "Nada na fila, Consumidor está aguardando"            # Prita que fila está vazia e vai esperar
                mutex.wait()                                                # Waiting até o produtor produzir (Thread acorda numa call de notify)
                                                                            # Wait libera a lock até ser notificado, após ser notificado tenta readquirir
                print "Produtor adicionou algo na fila e notificou o Consumidor"    # Consumidor voltou do wait(readquiriu a lock), segue a execução
            num = fila.pop(0)                                               # Remove da fila de mensagens
            print "Consumido", num                                          # Printa que removeu
            mutex.notify()                                                  # Acorda a thread esperando pela sua vez de usar a lock
            mutex.release()                                                 # Libera a lock
            sleep(random())                                          # Espera quantidade aleatória de tempo entre 0 e 1, faz com que exista variação na velocidade de produção e consumo

Produtor().start()
Consumidor().start()
