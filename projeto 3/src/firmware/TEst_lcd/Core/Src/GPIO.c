#include "GPIO.h"

void GPIO_SetPin(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin) {
    GPIOx->BSRR = GPIO_Pin;
}

void GPIO_ResetPin(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin) {
    GPIOx->BRR = GPIO_Pin;
}

uint8_t GPIO_ReadPin(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin) {
    return (GPIOx->IDR & GPIO_Pin) ? 1 : 0;
}

uint16_t PIN_MASK(uint8_t pin) {
    return (1 << pin);
}
void Delay_us(uint32_t us) {
    for(uint32_t i = 0; i < us; i++) {
        for(uint8_t j = 0; j < 10; j++) {
            __NOP();
        }
    }
}
