# ifndef GPIO_H
# define GPIO_H

#include "stm32f1xx_hal.h"
void GPIO_SetPin(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin);
uint8_t GPIO_ReadPin(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin);
uint16_t PIN_MASK(uint8_t pin);
void GPIO_ResetPin(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin);
void Delay_us(uint32_t us);

# endif
