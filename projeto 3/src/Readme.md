# README
Aqui vamos descrever como funciona as nossas funcionalidades para que os outros consigam ter uma noção

# Integrando programação com proteus
* [Instalando STM32CUBE IDE](https://www.youtube.com/watch?v=2OwUnupABec)

## Passo 1 -> instalar STM32cubeIDE
Primeiro, temos que instalar as nossas IDEs para fazermos nossos códigos. Normalmente ao se programar em stm, utilizamos 2 programas:
- STM32cubeIDE -> software principal para fazer o código (tipo o nosso vscode)
- STM32cubeIDEmx -> software auxiliar, nele, podemos configurar visualmente o nosso stm, para ter uma configuração inicial do código pronta (criador de código inicial)
Em versões anteriores, eles eram juntos, na mais atual, são separados. 

Para baixa-los, siga os passos:
1) acesse os sites:
* [stm32cubeIDE](https://www.st.com/en/development-tools/stm32cubeide.html)
* [stm32cubeIDEMX](https://www.st.com/en/development-tools/stm32cubemx.html)
2) crie sua conta
3) baixe o arquivo .zip, descompacte, inicialize e siga o procedimento de instalação

## Passoo 2 -> programando
Vamos fazer um Led piscar

### No MX
Primeiro começamos no MX, nele vamos criar uma base inicial
- Inicialize -> file -> new project
- Escolha o modelo de numero "STM32F103C8t6" (Blue pill)
- Em project menage, selecione um nome, um caminho pro projeto e em tolchan/IDE selecione stm32cubeIDEMX

Para o led
- em pinout configuração
- Na esquerda, Systen core -> Sys -> Debug, selecione Serial Wire
- Na stm, selecione PC_13 -> GPIO output


Slave o projeto em file
Gere o códio em cima na direita (Generate Code)

### Abra o stm32cube IDE normal
configurações:
- na barra de cima, em project clique em build Automatically
- clice em file->properties->C/C++build->setings-> MCU/MPU Post build output
- marque "convert to hex file" e apply

- na barra de cima, faça, File -> import -> General -> existing project in orkspace
- selecione seu projeto
- teste rapido -> veja se clicando nele com o botão direito, aas opções Build project e Cleam project estão habilitadas, se estiverem, tudo certo.
- va no seu projeto Core -> Src -> main.c

La, teremos nosso código, vc pode tentar entender as partes do código que foram geradas pelo MX, basicamente ele gerou as configurações de pinos, clocks, e do Hall (funções de pinos GPIO), mas o que vamos focar é na função main.

na função While da main, use o seguinte:
```Cpp
    HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, 1); //ativa o pino
	HAL_Delay(2000); // delay
	HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, 0); // desativa o pino
	HAL_Delay(2000); // delay
```
Para auto complete use Ctrl + espaço

Clique no martelo na barra de cima para compilar

## passo 3 -> simulação no proteus
No proteus, crie um projeto
Em Componentes, procure os seguintes:
1) LeD-Blue
2) RES
3) Stm32F103C8

Dica: você pode colocar um label, (icone a esquerda) em um fio para conecta-lo a outro.
1) concet um power VDDA de 3.3V e um ground VSSA
2) conect NRST a um resisto de 10k ao ground
3) conect os pinos VDDA, VBAT ao power
4) conect VSSa e BOOT ao VSSA
5) conect o pino PC13 ao led com um resistor.

### conctando o código
Em sua stm, clique 2 vezes, em program File, escolha dentro de seu projeto:
- Debug-> o seu programa.hex

salve e rode a simulação


# Programação geral
## Ideia geral
Para facilitar, nessa parte em que estamos mais testando os componentes, vamos fazer em C e depois que conseguirmos passamos para assembly. Acredito eu que fazendo em C, conseguiriamos programar em assembly, em termos de conexão, então, para efeito de hardware, poderemos começar com C. a ideia é a seguinte:
1) fazer em c puro, usando MX e Hall
2) ir tranformando esse codigo em um c voltado para registradores 
3) transformar algumas funções do C em assembly
4) transformar o c todo em assembly

Com o passo 1, ja podemos fazer a simulação, ja que é mais facil, o resto pode ser feito apos a PCB.

## Funcionamento da programação


# STM32
## Funcionamento da pinagem

# Tela 
## Funcionamento da pinagem
## Funcionamento da programação

# Teclado
## Funcionamento da pinagem
## Funcionamento da programação

# Memoria externa
## Funcionamento da pinagem
## Funcionamento da programação

