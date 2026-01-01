# Documentação do Esquemático da Calculadora com STM32

Este documento detalha o design do hardware e as conexões elétricas do nosso projeto de calculadora, que utiliza o microcontrolador STM32F103C8T (em uma placa Blue Pill) como unidade central de processamento. O esquemático foi projetado e simulado no ambiente Proteus.

## Visão Geral da Arquitetura

O projeto é dividido em três blocos funcionais principais:

1.  **Unidade de Processamento (U1):** A placa Blue Pill, responsável por executar o firmware que lê as entradas, processa os dados e controla as saídas.
2.  **Interface de Entrada (J1):** Um keypad matricial 4x4, que permite ao usuário inserir números e comandos.
3.  **Interface de Saída (J2):** Um display de 7 segmentos, utilizado para mostrar os dígitos inseridos e os resultados das operações.


---

## 1. Unidade de Processamento - Blue Pill (STM32F103C8T)

O coração do nosso projeto. Todos os outros componentes se conectam diretamente aos seus pinos de GPIO (General Purpose Input/Output).

*   **Alimentação:** A placa é alimentada via sua porta micro-USB ou através dos pinos `5V` e `GND`. Ela possui um regulador de tensão interno que fornece a tensão de operação de `3.3V` para o chip e para os nossos periféricos.

## 2. Interface de Entrada - Keypad Matricial 4x4

Utilizamos um keypad matricial para reduzir o número de pinos necessários para ler 16 teclas. Em vez de 16 pinos, usamos apenas 8 (4 para linhas e 4 para colunas).

O método de leitura é o **escaneamento por colunas (Column Scanning)**:
*   As colunas são configuradas como **saídas** no STM32.
*   As linhas são configuradas como **entradas** com resistores de **pull-up** internos ativados. Isso significa que, por padrão, as linhas sempre leem um nível lógico ALTO (HIGH).
*   O firmware ativa uma coluna de cada vez, colocando-a em nível lógico BAIXO (LOW). Em seguida, ele lê o estado de todas as linhas. Se uma tecla naquela coluna for pressionada, ela criará uma conexão entre a coluna (LOW) e a sua linha correspondente, fazendo com que o pino da linha também seja lido como BAIXO.

### Conexões do Keypad:

| Pino do Keypad | Descrição | Conectado ao Pino STM32 | Função no Firmware |
| :--- | :--- | :--- | :--- |
| **1** | Coluna 1 | `PB0` | Saída (Output) |
| **2** | Coluna 2 | `PB1` | Saída (Output) |
| **3** | Coluna 3 | `PB10` | Saída (Output) |
| **4** | Coluna 4 | `PB11` | Saída (Output) |
| **A** | Linha A (7, 8, 9, /) | `PB4` | Entrada com Pull-up |
| **B** | Linha B (4, 5, 6, *) | `PB5` | Entrada com Pull-up |
| **C** | Linha C (1, 2, 3, -) | `PB6` | Entrada com Pull-up |
| **D** | Linha D (ON, 0, =, +) | `PB7` | Entrada com Pull-up |

## 3. Interface de Saída - Display de 7 Segmentos

Para exibir os resultados, utilizamos um display de 7 segmentos do tipo **Catodo Comum**.

*   **Catodo Comum:** Significa que todos os pinos negativos (catodos) dos 8 LEDs internos (7 segmentos + o ponto decimal) são conectados juntos a um único pino `COM`. Este pino `COM` deve ser conectado ao `GND` (Terra).
*   **Controle dos Segmentos:** Para acender um segmento individual (a, b, c, etc.), precisamos enviar um sinal de nível lógico ALTO (HIGH / 3.3V) para o pino correspondente.

### Conexões do Display:

Para proteger os pinos do STM32 e os LEDs do display, um **resistor limitador de corrente** (valor típico de 220Ω a 330Ω) é colocado em série com cada pino de segmento.

| Pino do Display | Segmento | Conectado ao Pino STM32 | Função no Firmware |
| :--- | :--- | :--- | :--- |
| **a** | Segmento Superior | `PA0` | Saída (Output) |
| **b** | Segmento Superior Direito | `PA1` | Saída (Output) |
| **c** | Segmento Inferior Direito | `PA2` | Saída (Output) |
| **d** | Segmento Inferior | `PA3` | Saída (Output) |
| **e** | Segmento Inferior Esquerdo | `PA4` | Saída (Output) |
| **f** | Segmento Superior Esquerdo | `PA5` | Saída (Output) |
| **g** | Segmento Central | `PA6` | Saída (Output) |
| **COM** | Catodo Comum | `GND` | Terra do Circuito |

O firmware contém uma função (`display_digit`) que recebe um número (0-9) e ativa a combinação correta de pinos de saída (`PA0` a `PA6`) para formar o dígito visualmente no display.

---
