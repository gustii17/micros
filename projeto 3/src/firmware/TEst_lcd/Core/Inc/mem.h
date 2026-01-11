# ifndef MEM_H
# define MEM_H


void I2C_Init(void);
void I2C_Start(void);
void I2C_Stop(void);
void I2C_WriteByte(uint8_t data);
uint8_t I2C_ReadByte(uint8_t ack);
void EEPROM_Write(uint16_t address, uint8_t *data, uint8_t len);
void EEPROM_Read(uint16_t address, uint8_t *data, uint8_t len);
void EEPROM_Write_word(uint16_t address, char *data, uint8_t len);
void EEPROM_READ_word(uint16_t address, char *data, uint8_t len);
# endif
