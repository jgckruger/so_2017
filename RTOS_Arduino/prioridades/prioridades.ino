#include <Arduino_FreeRTOS.h>

//// CABEÇALHO DAS TASKS
void Task3( void *pvParameters );
void Task2( void *pvParameters );
void Task1( void *pvParameters );
void Task0( void *pvParameters );

//// SETUP
void setup() {
  
  // Inicia conexão serial com 9600 de bitrate
  Serial.begin(9600);

  //// CRIAÇÃO DAS TASKS

  // task 3: printa "prioridade 3" com maior prioridade
  xTaskCreate(
    Task3                          // Ponteiro pra task criada
    ,  (const portCHAR *)"Task 3"  // Nome da task
    ,  128                         // Tamanho da pilha
    ,  NULL                        // Ponteiro dos parâmetros (*pvParameters)
    ,  3                           // Prioridade máxima  3 (configMAX_PRIORITIES - 1)
    ,  NULL                        // Parâmetro opcional, passa handler pra task criada
    );                      

  // task 2: printa "prioridade 2" com maior prioridade
  xTaskCreate(
    Task2                          // Ponteiro pra task criada
    ,  (const portCHAR *)"Task 2"  // Nome da task
    ,  128                         // Tamanho da pilha
    ,  NULL                        // Ponteiro dos parâmetros (*pvParameters)
    ,  2                           // Prioridade máxima  3 (configMAX_PRIORITIES - 1)
    ,  NULL                        // Parâmetro opcional, passa handler pra task criada
    );      

    // task 1: printa "prioridade 0" com maior prioridade
  xTaskCreate(
    Task1                          // Ponteiro pra task criada
    ,  (const portCHAR *)"Task 1"  // Nome da task
    ,  128                         // Tamanho da pilha
    ,  NULL                        // Ponteiro dos parâmetros (*pvParameters)
    ,  1                           // Prioridade máxima  3 (configMAX_PRIORITIES - 1)
    ,  NULL                        // Parâmetro opcional, passa handler pra task criada
    );      

    // task 0: printa "prioridade 0" com maior prioridade
  xTaskCreate(
    Task0                          // Ponteiro pra task criada
    ,  (const portCHAR *)"Task 0"  // Nome da task
    ,  128                         // Tamanho da pilha
    ,  NULL                        // Ponteiro dos parâmetros (*pvParameters)
    ,  0                           // Prioridade máxima  3 (configMAX_PRIORITIES - 1)
    ,  NULL                        // Parâmetro opcional, passa handler pra task criada
    );      

  // SCHEDULER ENTRA EM AÇÃO NO FINAL DO SETUP, GERENCIANDO QUAL ENTRA EM EXECUÇÃO
}

void loop()
{
  // Vazio, o RTOS cuida de gerenciar qual task executa
}

//// TASKS

// Task 3
void Task3(void *pvParameters)
{
  (void) pvParameters;
  
  for (;;)                         // Execução infinita
  {
    Serial.println("Prioridade 3\n");
  }
}

// Task 3
void Task2(void *pvParameters)
{
  (void) pvParameters;
  
  for (;;)                         // Execução infinita
  {
    Serial.println("Prioridade 2\n");
  }
}

// Task 1
void Task1(void *pvParameters)
{
  (void) pvParameters;
  
  for (;;)                         // Execução infinita
  {
    Serial.println("Prioridade 1\n");
  }
}

// Task 0
void Task0(void *pvParameters)
{
  (void) pvParameters;
  
  for (;;)                         // Execução infinita
  {
    Serial.println("Prioridade 0\n");
  }
}


/* OBSERVAÇÕES
 *  
 *  - A task 3 executa rapidamente, e como tem prioridade alta, volta a executar, causando starvation
 *  - Mudando a prioridade da task 3 para 2, a task 2 e a 3 disputam intermitentemente pelo console da porta serial
 *  - Uma maneira de não causar starvation mesmo possuindo tasks de alta prioridade é vTaskDelay( NUMERODETICKS);
 *  - Não descobri se ele não causa starvation por ocasionar uma troca de contexto porque demora demais ou porque a task dorme
 */
