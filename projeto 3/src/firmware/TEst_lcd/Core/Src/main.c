
#include "main.h"
#include "LCD.h"
#include "telas.h"

void SystemClock_Config(void);
static void MX_GPIO_Init(void);


/* Pinagem LCD
 * PA0 - D0
 * PA1 - D1
 * PA2 - D2
 * PA3 - D3
 * PA4 - D4
 * PA5 - D5
 * PA6 - D6
 * PA7 - D7
 * PB0 - E
 * PB11 - RS
 *
 *
 */

int main(void)
{

  HAL_Init();
  SystemClock_Config();
  MX_GPIO_Init();

  //LCD funções
  //iniciar
  LCD_init();
  HAL_Delay(1000);
  //enviar caractere, exemplo: W, minusculas virão maiusculas (tabela ACISS)
  write_letter('w');

  //enviar palavra, necessario um array de char terminado em '\0'
  	char msg[] = "ikkkac";
  	char msg2[] = "hello";
  	char msg3[] = "world!";

  	//enviando
  	write_word(msg);


  	//limpar o lcd
  	LCD_clear();

  	//setar o cursor, o primeiro é a coluna indo de 0 a 15, e o segundo, a linha, 0 ou 1.
  	set_adress(4, 0);

  	//testando
  	write_word(msg2);

  	//trocando linha
  	set_adress(4, 1);

  	//testando
  	 write_word(msg3);
  	 HAL_Delay(1000);


  	//tela 0 - carregando
  	 load();

  	 //Tela 1 - inicio
  	Tela_inicio();
  	HAL_Delay(2000);


  	//tela 2 - jogo
  	 //Tela 1

  	 int tamanho_palavra = 6;
  	 Tela_forca(tamanho_palavra);
  	 set_adress(11, 0);
  	 HAL_Delay(2000);


  	//TELA DE VITRORIA
  	tela_vitoria();
  	HAL_Delay(2000);
  	//TELA DE DERROTA
  	tela_derrota();
  	HAL_Delay(2000);




  while (1)
  {

  }
}


void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_NONE;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_HSI;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_0) != HAL_OK)
  {
    Error_Handler();
  }
}

/**
  * @brief GPIO Initialization Function
  * @param None
  * @retval None
  */
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  /* USER CODE BEGIN MX_GPIO_Init_1 */

  /* USER CODE END MX_GPIO_Init_1 */

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOA_CLK_ENABLE();

  /*Configure GPIO pin Output Level */
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_0|GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3|GPIO_PIN_4
                          |GPIO_PIN_5|GPIO_PIN_6|GPIO_PIN_7, GPIO_PIN_RESET);

  /*Configure GPIO pins : PA1 PA2 PA3 PA4
                           PA5 PA6 PA7 PA8
                           PA9 PA10 */
  GPIO_InitStruct.Pin = GPIO_PIN_0|GPIO_PIN_1|GPIO_PIN_2|GPIO_PIN_3|GPIO_PIN_4
                          |GPIO_PIN_5|GPIO_PIN_6|GPIO_PIN_7;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_0|GPIO_PIN_11, GPIO_PIN_RESET);

   /*Configure GPIO pins : PA1 PA2 PA3 PA4
                            PA5 PA6 PA7 PA8
                            PA9 PA10 */
   GPIO_InitStruct.Pin = GPIO_PIN_0|GPIO_PIN_11;
   GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
   GPIO_InitStruct.Pull = GPIO_NOPULL;
   GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
   HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

  /* USER CODE BEGIN MX_GPIO_Init_2 */

  /* USER CODE END MX_GPIO_Init_2 */
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
