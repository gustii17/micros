#include <iostream>
#include <fstream>
#include <bitset>

int main() {
    std::ifstream arquivo("exampl.bin", std::ios::binary);
    if (!arquivo) {
        std::cerr << "Erro ao abrir o arquivo!" << std::endl;
        return 1;
    }

    unsigned char byte;
    size_t contador = 0;

    while (arquivo.read(reinterpret_cast<char*>(&byte), 1)) {
        std::bitset<8> bits(byte);  // converte o byte para binário
        std::cout << bits << ' ';   // imprime, ex: 00000001
        contador++;
    }

    std::cout << "\n\nTotal de bytes lidos: " << contador << std::endl;
    return 0;
}
