from threading import Lock, Thread

x = 0
mutex = Lock()

class ExThread(Thread):
    def run(self):
        global x

        while True:
            mutex.acquire()
            if x < 200:
                x+=1
                print self.name +  "   " + str(x)
            mutex.release()
            if x >= 200:
                break

vetor = []

for i in range(0,5):
    vetor.append(ExThread())

for i in range(0,5):
    vetor[i].start()
