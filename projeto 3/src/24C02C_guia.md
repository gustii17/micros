# Documentação do 24C02C com STM32

[Datasheet do 2402C](https://www.alldatasheet.com/datasheet-pdf/pdf/23686/STMICROELECTRONICS/ST24C02.html)

## Visão Geral da Arquitetura

![Esquemático](https://github.com/gustii17/micros/blob/main/projeto%203/src/24C02C_guia_image.jpg)

Observação: SCK é, na realidade, o pino SCL do Datasheet.

### Conexões:

|24C02C | STM32 | Função |
| :--- | :--- | :--- |
| SDA | PB7 | Barramento de Dados (DEVE TER RESISTOR DE PULL-UP!) |
| SCL | PB6 | Barramento de Dados (DEVE TER RESISTOR DE PULL-UP!) |
| A0 | GND | Seletor |
| A1 | GND | Seletor |
| A2 | GND | Seletor |
| VCC | 3.3 V | Fonte |
| VSS | GND | Terra |
| WP | GND | Write Protection ou Write Control, deve estar em 0V para habilitar escrita |



### Exemplo de Código I2C:
```C
#include "stm32f1xx_hal.h"

I2C_HandleTypeDef hi2c1;

void I2C1_Init(void) {
    hi2c1.Instance = I2C1;
    hi2c1.Init.ClockSpeed = 100000; // 100 kHz
    hi2c1.Init.DutyCycle = I2C_DUTYCYCLE_2;
    hi2c1.Init.OwnAddress1 = 0;
    hi2c1.Init.AddressingMode = I2C_ADDRESSINGMODE_7BIT;
    hi2c1.Init.DualAddressMode = I2C_DUALADDRESS_DISABLE;
    hi2c1.Init.OwnAddress2 = 0;
    hi2c1.Init.GeneralCallMode = I2C_GENERALCALL_DISABLE;
    hi2c1.Init.NoStretchMode = I2C_NOSTRETCH_DISABLE;
    HAL_I2C_Init(&hi2c1);
}

uint8_t EEPROM_ReadByte(uint16_t addr) {
    uint8_t data = 0xFF;
    HAL_I2C_Mem_Read(&hi2c1, 0xA0, addr, I2C_MEMADD_SIZE_8BIT, &data, 1, 100);
    return data;
}

void EEPROM_WriteByte(uint16_t addr, uint8_t data) {
    HAL_I2C_Mem_Write(&hi2c1, 0xA0, addr, I2C_MEMADD_SIZE_8BIT, &data, 1, 100);
    HAL_Delay(5); // Espera escrita terminar (t_wr = 5ms típico)
}

int main(void) {
    // Inicializações...
    I2C1_Init();
    
    // Exemplo: escrever e ler
    EEPROM_WriteByte(0x10, 0xAB);
    uint8_t valor = EEPROM_ReadByte(0x10); // Retorna 0xAB
    
    while(1);
}
```
