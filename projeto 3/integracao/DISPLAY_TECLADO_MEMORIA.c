#include "stm32f10x.h"
#include "core_cm3.h"

/* Definicoes do LCD (LM016L) - Modo 4 bits */
#define LCD_RS_PIN 0  // PA0
#define LCD_RW_PIN 1  // PA1  
#define LCD_EN_PIN 2  // PA2
#define LCD_D4_PIN 3  // PA3
#define LCD_D5_PIN 4  // PA4
#define LCD_D6_PIN 5  // PA5
#define LCD_D7_PIN 6  // PA6

/* Definicoes do Teclado Matricial */
#define ROW1_PIN 7    // PA7 - Linha 1
#define ROW2_PIN 8    // PA8 - Linha 2  
#define ROW3_PIN 9    // PA9 - Linha 3
#define ROW4_PIN 10   // PA10 - Linha 4
#define COL1_PIN 11   // PA11 - Coluna 1
#define COL2_PIN 12   // PA12 - Coluna 2
#define COL3_PIN 15   // PA15 - Coluna 3

/* Definicoes da EEPROM I2C */
#define I2C_PORT GPIOB
#define I2C_SCL_PIN 6  // PB6
#define I2C_SDA_PIN 7  // PB7
#define EEPROM_ADDRESS 0xA0  // Endereco I2C da EEPROM (A0+A1+A2=0)
#define EEPROM_SIZE 32768    // 32KB (256Kb)

/* Variaveis globais */
char last_key = ' ';         // Ultima tecla pressionada
uint32_t key_count = 0;      // Contador de teclas
uint8_t eeprom_buffer[16];   // Buffer para dados da EEPROM

/* Funcoes para manipular GPIO */
static void GPIO_SetPin(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin) {
    GPIOx->BSRR = GPIO_Pin;
}

static void GPIO_ResetPin(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin) {
    GPIOx->BRR = GPIO_Pin;
}

static uint8_t GPIO_ReadPin(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin) {
    return (GPIOx->IDR & GPIO_Pin) ? 1 : 0;
}

static uint16_t PIN_MASK(uint8_t pin) {
    return (1 << pin);
}

/* Prototipos de funcoes */
void LCD_Init(void);
void LCD_Cmd(uint8_t cmd);
void LCD_Data(uint8_t data);
void LCD_String(const char *str);
void LCD_Clear(void);
void LCD_SetCursor(uint8_t row, uint8_t col);
void Keypad_Init(void);
uint8_t Keypad_Scan(void);
void I2C_Init(void);
void I2C_Start(void);
void I2C_Stop(void);
void I2C_WriteByte(uint8_t data);
uint8_t I2C_ReadByte(uint8_t ack);
void EEPROM_Write(uint16_t address, uint8_t *data, uint8_t len);
void EEPROM_Read(uint16_t address, uint8_t *data, uint8_t len);
void Delay_ms(uint32_t ms);
void Delay_us(uint32_t us);
void LCD_ShowNumber(uint32_t num);
void LCD_ShowHex(uint8_t num);

/* Variaveis para I2C */
static uint8_t I2C_Ack_Received = 0;

int main(void) {
    /* Habilita clock para GPIOA e GPIOB */
    RCC->APB2ENR |= RCC_APB2ENR_IOPAEN | RCC_APB2ENR_IOPBEN;
    
    /* Configura SystemCoreClock para 8MHz (HSI) */
    SystemCoreClock = 8000000;
    
    /* Configura GPIOs - LCD */
    for(uint8_t i = 0; i <= 6; i++) {
        GPIOA->CRL &= ~(0xF << (4 * i));
        GPIOA->CRL |= (0x2 << (4 * i)); /* Output push-pull 2MHz */
    }
    
    /* Configura GPIOs - Linhas do teclado */
    for(uint8_t i = 7; i <= 10; i++) {
        if(i < 8) {
            GPIOA->CRL &= ~(0xF << (4 * (i)));
            GPIOA->CRL |= (0x6 << (4 * (i))); /* Output open-drain 2MHz */
        } else {
            GPIOA->CRH &= ~(0xF << (4 * (i - 8)));
            GPIOA->CRH |= (0x6 << (4 * (i - 8))); /* Output open-drain 2MHz */
        }
    }
    
    /* Configura GPIOs - Colunas do teclado */
    GPIOA->CRH &= ~(0xF << (4 * 3));  // PA11
    GPIOA->CRH |= (0x8 << (4 * 3));   /* Input pull-up/down */
    
    GPIOA->CRH &= ~(0xF << (4 * 4));  // PA12
    GPIOA->CRH |= (0x8 << (4 * 4));   /* Input pull-up/down */
    
    GPIOA->CRH &= ~(0xF << (4 * 7));  // PA15
    GPIOA->CRH |= (0x8 << (4 * 7));   /* Input pull-up/down */
    
    /* Ativa pull-up nas colunas */
    GPIOA->ODR |= PIN_MASK(COL1_PIN) | PIN_MASK(COL2_PIN) | PIN_MASK(COL3_PIN);
    
    /* Inicializa os perifericos */
    LCD_Init();
    Keypad_Init();
    I2C_Init();
    
    /* Testa a EEPROM */
    LCD_Clear();
    LCD_String("Testando EEPROM");
    Delay_ms(100);
    
    /* Escreve e le dados de teste */
    uint8_t test_data[] = "EEPROM OK!";
    uint8_t read_data[16];
    
    EEPROM_Write(0x0000, test_data, 10);
    Delay_ms(10); // Espera escrita completar
    EEPROM_Read(0x0000, read_data, 10);
    read_data[10] = '\0'; // Terminador de string
    
    /* Mostra resultado do teste */
    LCD_Clear();
    if(read_data[0] == 'E' && read_data[1] == 'E' && read_data[2] == 'P') {
        LCD_String("EEPROM: OK");
    } else {
        LCD_String("EEPROM: Falha");
    }
    Delay_ms(500);
    
    /* Mensagem inicial */
    LCD_Clear();
    LCD_String("Aguardando...");
    LCD_SetCursor(1, 0);
    LCD_String("Tecla: Salva");
    
    uint16_t eeprom_address = 0x0010; // Comeca a salvar a partir do endereco 16
    
    while (1) {
        uint8_t key = Keypad_Scan();
        
        if (key != 0) {
            last_key = key;
            key_count++;
            
            /* Atualiza o display */
            LCD_Clear();
            LCD_String("Tecla: ");
            LCD_Data(last_key);
            
            LCD_SetCursor(1, 0);
            LCD_String("Salva em: 0x");
            LCD_ShowHex(eeprom_address >> 8);
            LCD_ShowHex(eeprom_address & 0xFF);
            
            /* Salva tecla na EEPROM */
            eeprom_buffer[0] = last_key;
            eeprom_buffer[1] = key_count & 0xFF;          // Byte baixo do contador
            eeprom_buffer[2] = (key_count >> 8) & 0xFF;   // Byte alto do contador
            
            EEPROM_Write(eeprom_address, eeprom_buffer, 3);
            eeprom_address += 3; // Avanca 3 bytes
            
            /* Se chegou no final da memoria, volta ao inicio */
            if(eeprom_address >= EEPROM_SIZE - 3) {
                eeprom_address = 0x0010;
            }
            
            /* Le e mostra os ultimos 3 bytes salvos */
            Delay_ms(100); // Espera escrita completar
            EEPROM_Read(eeprom_address - 3, read_data, 3);
            
            LCD_Clear();
            LCD_String("Salvo: ");
            LCD_Data(read_data[0]); // Tecla
            LCD_String(" Cnt:");
            LCD_ShowNumber((read_data[2] << 8) | read_data[1]); // Contador
            
            LCD_SetCursor(1, 0);
            LCD_String("Addr: 0x");
            LCD_ShowHex((eeprom_address - 3) >> 8);
            LCD_ShowHex((eeprom_address - 3) & 0xFF);
            
            Delay_ms(500);
            
            /* Volta para tela principal */
            LCD_Clear();
            LCD_String("Aguardando...");
            LCD_SetCursor(1, 0);
            LCD_String("Tecla: Salva");
        }
        
        /* Pequeno delay entre varreduras */
        Delay_ms(10);
    }
}

/* ==================== FUNCOES DO LCD ==================== */
void LCD_Init(void) {
    Delay_ms(50);
    
    /* Inicializacao no modo 4 bits */
    LCD_Cmd(0x33);
    LCD_Cmd(0x32);
    LCD_Cmd(0x28); // Function set: 4-bit, 2-line, 5x8 dots
    LCD_Cmd(0x0C); // Display on, cursor off, blink off
    LCD_Cmd(0x06); // Entry mode: increment, no shift
    LCD_Cmd(0x01); // Clear display
    Delay_ms(5);
}

void LCD_Cmd(uint8_t cmd) {
    GPIO_ResetPin(GPIOA, PIN_MASK(LCD_RS_PIN));
    GPIO_ResetPin(GPIOA, PIN_MASK(LCD_RW_PIN));
    
    /* Envia 4 bits mais significativos */
    if((cmd >> 4) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D4_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D4_PIN));
    
    if((cmd >> 5) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D5_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D5_PIN));
    
    if((cmd >> 6) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D6_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D6_PIN));
    
    if((cmd >> 7) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D7_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D7_PIN));
    
    /* Pulso no Enable */
    GPIO_SetPin(GPIOA, PIN_MASK(LCD_EN_PIN));
    Delay_us(1);
    GPIO_ResetPin(GPIOA, PIN_MASK(LCD_EN_PIN));
    Delay_us(100);
    
    /* Envia 4 bits menos significativos */
    if((cmd >> 0) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D4_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D4_PIN));
    
    if((cmd >> 1) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D5_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D5_PIN));
    
    if((cmd >> 2) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D6_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D6_PIN));
    
    if((cmd >> 3) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D7_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D7_PIN));
    
    /* Pulso no Enable */
    GPIO_SetPin(GPIOA, PIN_MASK(LCD_EN_PIN));
    Delay_us(1);
    GPIO_ResetPin(GPIOA, PIN_MASK(LCD_EN_PIN));
    
    if(cmd == 0x01 || cmd == 0x02) Delay_ms(5);
    else Delay_us(100);
}

void LCD_Data(uint8_t data) {
    GPIO_SetPin(GPIOA, PIN_MASK(LCD_RS_PIN));
    GPIO_ResetPin(GPIOA, PIN_MASK(LCD_RW_PIN));
    
    /* Envia 4 bits mais significativos */
    if((data >> 4) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D4_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D4_PIN));
    
    if((data >> 5) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D5_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D5_PIN));
    
    if((data >> 6) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D6_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D6_PIN));
    
    if((data >> 7) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D7_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D7_PIN));
    
    /* Pulso no Enable */
    GPIO_SetPin(GPIOA, PIN_MASK(LCD_EN_PIN));
    Delay_us(1);
    GPIO_ResetPin(GPIOA, PIN_MASK(LCD_EN_PIN));
    Delay_us(100);
    
    /* Envia 4 bits menos significativos */
    if((data >> 0) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D4_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D4_PIN));
    
    if((data >> 1) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D5_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D5_PIN));
    
    if((data >> 2) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D6_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D6_PIN));
    
    if((data >> 3) & 0x01) GPIO_SetPin(GPIOA, PIN_MASK(LCD_D7_PIN));
    else GPIO_ResetPin(GPIOA, PIN_MASK(LCD_D7_PIN));
    
    /* Pulso no Enable */
    GPIO_SetPin(GPIOA, PIN_MASK(LCD_EN_PIN));
    Delay_us(1);
    GPIO_ResetPin(GPIOA, PIN_MASK(LCD_EN_PIN));
    
    Delay_us(100);
}

void LCD_String(const char *str) {
    while(*str) {
        LCD_Data(*str++);
    }
}

void LCD_Clear(void) {
    LCD_Cmd(0x01);
    Delay_ms(5);
}

void LCD_SetCursor(uint8_t row, uint8_t col) {
    uint8_t address;
    if(row == 0) address = 0x80 + col;
    else if(row == 1) address = 0xC0 + col;
    LCD_Cmd(address);
}

void LCD_ShowNumber(uint32_t num) {
    if (num < 10) {
        LCD_Data('0');
        LCD_Data('0');
        LCD_Data('0' + num);
    } else if (num < 100) {
        LCD_Data('0');
        LCD_Data('0' + (num / 10));
        LCD_Data('0' + (num % 10));
    } else {
        LCD_Data('0' + (num / 100));
        LCD_Data('0' + ((num / 10) % 10));
        LCD_Data('0' + (num % 10));
    }
}

void LCD_ShowHex(uint8_t num) {
    uint8_t nibble_high = (num >> 4) & 0x0F;
    uint8_t nibble_low = num & 0x0F;
    
    if(nibble_high < 10) LCD_Data('0' + nibble_high);
    else LCD_Data('A' + (nibble_high - 10));
    
    if(nibble_low < 10) LCD_Data('0' + nibble_low);
    else LCD_Data('A' + (nibble_low - 10));
}

/* ==================== FUNCOES DO TECLADO ==================== */
void Keypad_Init(void) {
    GPIO_SetPin(GPIOA, PIN_MASK(ROW1_PIN));
    GPIO_SetPin(GPIOA, PIN_MASK(ROW2_PIN));
    GPIO_SetPin(GPIOA, PIN_MASK(ROW3_PIN));
    GPIO_SetPin(GPIOA, PIN_MASK(ROW4_PIN));
}

uint8_t Keypad_Scan(void) {
    uint8_t rows[] = {ROW1_PIN, ROW2_PIN, ROW3_PIN, ROW4_PIN};
    uint8_t cols[] = {COL1_PIN, COL2_PIN, COL3_PIN};
    
    char keymap[4][3] = {
        {'1', '2', '3'},
        {'4', '5', '6'},
        {'7', '8', '9'},
        {'*', '0', '#'}
    };
    
    for(uint8_t i = 0; i < 4; i++) {
        GPIO_SetPin(GPIOA, PIN_MASK(ROW1_PIN));
        GPIO_SetPin(GPIOA, PIN_MASK(ROW2_PIN));
        GPIO_SetPin(GPIOA, PIN_MASK(ROW3_PIN));
        GPIO_SetPin(GPIOA, PIN_MASK(ROW4_PIN));
        
        GPIO_ResetPin(GPIOA, PIN_MASK(rows[i]));
        
        Delay_us(10);
        
        for(uint8_t j = 0; j < 3; j++) {
            if(GPIO_ReadPin(GPIOA, PIN_MASK(cols[j])) == 0) {
                Delay_ms(20);
                if(GPIO_ReadPin(GPIOA, PIN_MASK(cols[j])) == 0) {
                    while(GPIO_ReadPin(GPIOA, PIN_MASK(cols[j])) == 0);
                    return keymap[i][j];
                }
            }
        }
    }
    
    return 0;
}

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
    
    Delay_ms(1);
}

void I2C_Start(void) {
    /* SDA high, SCL high */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    Delay_us(5);
    
    /* SDA low */
    GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
    Delay_us(5);
    
    /* SCL low */
    GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    Delay_us(5);
}

void I2C_Stop(void) {
    /* SDA low, SCL low */
    GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
    GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    Delay_us(5);
    
    /* SCL high */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    Delay_us(5);
    
    /* SDA high */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
    Delay_us(5);
}

void I2C_WriteByte(uint8_t data) {
    uint8_t i;
    
    for(i = 0; i < 8; i++) {
        if(data & 0x80) {
            GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
        } else {
            GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
        }
        
        Delay_us(2);
        
        /* Clock high */
        GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
        Delay_us(5);
        
        /* Clock low */
        GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
        Delay_us(2);
        
        data <<= 1;
    }
    
    /* Libera SDA para ACK */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
    Delay_us(2);
    
    /* Clock para ACK */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    Delay_us(5);
    
    /* Verifica ACK */
    if(GPIO_ReadPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN)) == 0) {
        I2C_Ack_Received = 1;
    } else {
        I2C_Ack_Received = 0;
    }
    
    /* Clock low */
    GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    Delay_us(2);
}

uint8_t I2C_ReadByte(uint8_t ack) {
    uint8_t i, data = 0;
    
    /* Libera SDA */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN));
    
    for(i = 0; i < 8; i++) {
        data <<= 1;
        
        /* Clock high */
        GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
        Delay_us(5);
        
        /* Le bit */
        if(GPIO_ReadPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN))) {
            data |= 1;
        }
        
        /* Clock low */
        GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
        Delay_us(2);
    }
    
    /* Envia ACK/NACK */
    if(ack) {
        GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN)); // ACK
    } else {
        GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SDA_PIN)); // NACK
    }
    
    Delay_us(2);
    
    /* Clock para ACK */
    GPIO_SetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    Delay_us(5);
    
    /* Clock low */
    GPIO_ResetPin(I2C_PORT, PIN_MASK(I2C_SCL_PIN));
    Delay_us(2);
    
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

/* ==================== FUNCOES DE DELAY ==================== */
void Delay_ms(uint32_t ms) {
    for(uint32_t i = 0; i < ms; i++) {
        for(uint32_t j = 0; j < 7200; j++) {
            __NOP();
        }
    }
}

void Delay_us(uint32_t us) {
    for(uint32_t i = 0; i < us; i++) {
        for(uint8_t j = 0; j < 10; j++) {
            __NOP();
        }
    }
}