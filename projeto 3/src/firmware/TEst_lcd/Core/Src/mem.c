
#include "stm32f1xx_hal.h"
#include "mem.h"
#include "GPIO.h"


/* Definicoes da EEPROM I2C */
#define I2C_PORT GPIOB
#define I2C_SCL_PIN 6  // PB6
#define I2C_SDA_PIN 7  // PB7
#define EEPROM_ADDRESS 0xA0  // Endereco I2C da EEPROM (A0+A1+A2=0)
#define EEPROM_SIZE 32768    // 32KB (256Kb)
static uint8_t I2C_Ack_Received = 0;

/* ==================== FUNCOES I2C (Bit-banging) ==================== */
void I2C_Init(void) {
    /* Configura SCL e SDA como open-drain output */
    /* PB6 (SCL) */
    GPIOB->CRL &= ~(0xF << (4 * 6));
    GPIOB->CRL |= (0x6 << (4 * 6)); /* Output open-drain 2MHz */

    /* PB7 (SDA) */
    GPIOB->CRL &= ~(0xF << (4 * 7));
    GPIOB->CRL |= (0x6 << (4 * 7)); /* Output open-drain 2MHz */

    /* Inicializa linhas em alto (idle) */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
    Delay_us(20);
   //HAL_Delay(1)-;
}

void I2C_Start(void) {
    /* SDA high, SCL high */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    //HAL_Delay(1)-;
    Delay_us(20);

    /* SDA low */
    GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
    //HAL_Delay(1)-;
    Delay_us(20);

    /* SCL low */
    GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    //HAL_Delay(1)-;
    Delay_us(20);
}

void I2C_Stop(void) {
    /* SDA low, SCL low */
    GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
    GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    Delay_us(20);
    //HAL_Delay(1)-;

    /* SCL high */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    //HAL_Delay(1)-;
    Delay_us(20);

    /* SDA high */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
    //HAL_Delay(1)-;
    Delay_us(20);
}

void I2C_WriteByte(uint8_t data) {
    uint8_t i;

    for(i = 0; i < 8; i++) {
        if(data & 0x80) {
            GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
        } else {
            GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
        }

        //HAL_Delay(1)-;
        Delay_us(20);

        /* Clock high */
        GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
        //HAL_Delay(1)-;
        Delay_us(20);

        /* Clock low */
        GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
        //HAL_Delay(1)-;
        Delay_us(20);

        data <<= 1;
    }

    /* Libera SDA para ACK */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
    //HAL_Delay(1)-;
    Delay_us(20);

    /* Clock para ACK */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    //HAL_Delay(1)-;
    Delay_us(20);

    /* Verifica ACK */
    if(GPIO_ReadPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN)) == 0) {
        I2C_Ack_Received = 1;
    } else {
        I2C_Ack_Received = 0;
    }

    /* Clock low */
    GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    //HAL_Delay(1)-;
    Delay_us(20);
}

uint8_t I2C_ReadByte(uint8_t ack) {
    uint8_t i, data = 0;

    /* Libera SDA */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));

    for(i = 0; i < 8; i++) {
        data <<= 1;

        /* Clock high */
        GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
        //HAL_Delay(1)-;
        Delay_us(20);

        /* Le bit */
        if(GPIO_ReadPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN))) {
            data |= 1;
        }

        /* Clock low */
        GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
        //HAL_Delay(1)-;
        Delay_us(20);
    }

    /* Envia ACK/NACK */
    if(ack) {
        GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN)); // ACK
    } else {
        GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN)); // NACK
    }

    //HAL_Delay(1)-;
    Delay_us(20);

    /* Clock para ACK */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    //////////HAL_Delay(1)-;----
    Delay_us(20);

    /* Clock low */
    GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    //HAL_Delay(1)-;
    Delay_us(20);

    /* Libera SDA */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));

    return data;
}

/* ==================== FUNCOES EEPROM ==================== */
void EEPROM_Write(uint16_t address, uint8_t *data, uint8_t len) {
    uint8_t i;

    I2C_Start();
    I2C_WriteByte(EEPROM_ADDRESS); // Endereco + modo escrita
    I2C_WriteByte(address >> 8);   // Endereco alto
    I2C_WriteByte(address & 0xFF); // Endereco baixo

    for(i = 0; i < len; i++) {
        I2C_WriteByte(data[i]);
    }

    I2C_Stop();
}
void EEPROM_Write_word(uint16_t address, char *data, uint8_t len) {
	for(int i = 0;i < len; i++){
		uint8_t c = (uint8_t) data[i];
		EEPROM_Write(address+i, &c, 1);
	}

}
void EEPROM_READ_word(uint16_t address, char *data, uint8_t len) {
	for(int i = 0;i < len; i++){
		uint8_t c;

		EEPROM_Read(address+i, &c, 1);
		data[i] = (char) c;
	}

}
void EEPROM_Read(uint16_t address, uint8_t *data, uint8_t len) {
    uint8_t i;

    /* Primeiro envia endereco */
    I2C_Start();
    I2C_WriteByte(EEPROM_ADDRESS); // Endereco + modo escrita
    I2C_WriteByte(address >> 8);   // Endereco alto
    I2C_WriteByte(address & 0xFF); // Endereco baixo

    /* Restart para leitura */
    I2C_Start();
    I2C_WriteByte(EEPROM_ADDRESS | 0x01); // Endereco + modo leitura

    /* Le dados */
    for(i = 0; i < len; i++) {
        if(i == (len - 1)) {
            data[i] = I2C_ReadByte(0); // Ultimo byte: NACK
        } else {
            data[i] = I2C_ReadByte(1); // ACK para continuar
        }
    }

    I2C_Stop();
}

