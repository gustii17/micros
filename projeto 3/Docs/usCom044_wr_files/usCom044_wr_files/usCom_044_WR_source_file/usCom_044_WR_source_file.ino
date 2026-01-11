/* =============================================================================================================
    
   
   WR Kits Channel & Usina Info número 044


   Leitura de Teclado de Membrana Matricial com Arduino

   
   
       
    
   Autor: Eng. Wagner Rambo  Data: Julho de 2017
   
   www.wrkits.com.br | facebook.com/wrkits | youtube.com/user/canalwrkits
   
   
============================================================================================================= */

 
// =============================================================================================================
// --- Mapeamento de Hardware ---
#define  col_1   2                    //coluna 1 do teclado
#define  col_2   3                    //coluna 2 do teclado
#define  col_3   4                    //coluna 3 do teclado
#define  col_4   5                    //coluna 4 do teclado
#define  row_A   6                    //linha A  do teclado
#define  row_B   7                    //linha B  do teclado
#define  row_C   8                    //linha C  do teclado
#define  row_D   9                    //linha D  do teclado


// =============================================================================================================
// --- Protótipo das Funções ---
void readKeyboard();                  //Função para leitura do teclado
void store(char value);               //Função para armazenar o número digitado no teclado matricial
void numero();                        //Função para imprimir o número digitado na tela do LCD


// =============================================================================================================
// --- Variáveis Globais ---
char control = 0x01;                  //variável de controle de teclado
char counter = 0x00;                  //variável auxiliar de contagem
int  number  = 0x00;                  //variável para armazenar o número pressionado no teclado


// =============================================================================================================
// --- Interrupção ---
ISR(TIMER2_OVF_vect)
{
    TCNT2=100;          // Reinicializa o registrador do Timer2
    counter++;          // incrementa counter
    
    if(counter == 0x05) // counter igual a D'5'?
    {                   // sim...
    
       counter = 0x00;  //reinicia counter
       
       readKeyboard();  //lê teclado     

            
    
    } //end if counter
}


// =============================================================================================================
// --- Configurações Iniciais ---
void setup()
{
     Serial.begin(9600);
  
     for(char i=2;i< 6;i++) pinMode(i, OUTPUT);             //Saídas para varredura das colunas
     for(char j=6;j<10;j++) pinMode(j,  INPUT);             //Entradas para as linhas
     
     
     digitalWrite(col_1, HIGH);                             //Inicializa coluna 1 em HIGH
     digitalWrite(col_2, HIGH);                             //Inicializa coluna 2 em HIGH
     digitalWrite(col_3, HIGH);                             //Inicializa colune 3 em HIGH

     
     TCCR2A = 0x00;   //Timer operando em modo normal
     TCCR2B = 0x07;   //Prescaler 1:1024
     TCNT2  = 100;    //10 ms overflow again
     TIMSK2 = 0x01;   //Habilita interrupção do Timer2
 
} //end setup


// =============================================================================================================
// --- Loop Infinito ---
void loop()
{
  
 
   
    
} //end loop



   // Estouro = Timer2_cont x prescaler x ciclo de máquina
   
   // Ciclo de máquina = 1/Fosc = 1/16E6 = 62,5ns = 62,5E-9s
   
   // Estouro = (256 - 100) x 1024 x 62,5E-9 = 9,98ms 

   // Varredura = Estouro x Counter = 9,98ms x 5 = 49,9ms


// =============================================================================================================
// --- Desenvolvimento das Funções ---
void readKeyboard()                       //Função para leitura do teclado
{

   if(digitalRead(col_1) && control == 0x01)       //Coluna 1 em nível high? Control igual 1?
   {                                               //Sim...
         control = 0x02;                           //control igual a 2
         digitalWrite(col_1,  LOW);                //apenas coluna 1 em nível baixo
         digitalWrite(col_2, HIGH);
         digitalWrite(col_3, HIGH);
         digitalWrite(col_4, HIGH);
      
      // -- Testa qual tecla foi pressionada e armazena o valor --
         if     (!digitalRead(row_A))  store(1);
         else if(!digitalRead(row_B))  store(4);
         else if(!digitalRead(row_C))  store(7);
         else if(!digitalRead(row_D))  store(11);
      
   } //end if col_1
   
   else if(digitalRead(col_2) && control == 0x02)   //Coluna 2 em nível high? Control igual 2?
   {                                                //Sim...
         control = 0x03;                            //control igual a 3
         digitalWrite(col_1, HIGH);
         digitalWrite(col_2,  LOW);                 //apenas coluna 2 em nível baixo
         digitalWrite(col_3, HIGH);
         digitalWrite(col_4, HIGH);
         
      // -- Testa qual tecla foi pressionada e armazena o valor --
         if     (!digitalRead(row_A))  store(2);
         else if(!digitalRead(row_B))  store(5);
         else if(!digitalRead(row_C))  store(8);
         else if(!digitalRead(row_D))  store(0);

   } //end if col_2
   
   else if(digitalRead(col_3) && control == 0x03)   //Coluna 3 em nível high? Control igual 3?
   {                                                //Sim...
         control = 0x04;                            //control igual a 4     
         digitalWrite(col_1, HIGH);                 //
         digitalWrite(col_2, HIGH);
         digitalWrite(col_3,  LOW);                 //apenas coluna 3 em nível baixo
         digitalWrite(col_4, HIGH);
         
      // -- Testa qual tecla foi pressionada e armazena o valor --
         if     (!digitalRead(row_A))  store(3);
         else if(!digitalRead(row_B))  store(6);
         else if(!digitalRead(row_C))  store(9);
         else if(!digitalRead(row_D))  store(12);

   } //end if col_3

   else if(digitalRead(col_4) && control == 0x04)   //Coluna 3 em nível high? Control igual 4?
   {                                                //Sim...
         control = 0x01;                            //control igual a 1     
         digitalWrite(col_1, HIGH);                 //
         digitalWrite(col_2, HIGH);
         digitalWrite(col_3, HIGH);                 
         digitalWrite(col_4,  LOW);                 //apenas coluna 4 em nível baixo
         
      // -- Testa qual tecla foi pressionada e armazena o valor --
         if     (!digitalRead(row_A))  store(13);
         else if(!digitalRead(row_B))  store(14);
         else if(!digitalRead(row_C))  store(15);
         else if(!digitalRead(row_D))  store(16);

   } //end if col_4
  
  
} //end readKeyboard



void store(char value1)                   //Função para armazenar o valor digitado no teclado
{
   char i;                                //variável de iterações
        
   TIMSK2 = 0x00;                         //Desabilita interrupção do Timer2
   
   
  
   delay(350);
  
        
   number = value1;                       //atualiza number

   numero();

   TIMSK2 = 0x01;   //Habilita interrupção do Timer2
   
} //end store


void numero()                                           //Função para imprimir o número digitado
{
  
    
    
   if     (number == 11) Serial.println("*");
   else if(number == 12) Serial.println("#");
   else if(number == 13) Serial.println("A");
   else if(number == 14) Serial.println("B");
   else if(number == 15) Serial.println("C");
   else if(number == 16) Serial.println("D");
   else Serial.println(number);                                     //Mostra número  
   
 
} //end numero


 













