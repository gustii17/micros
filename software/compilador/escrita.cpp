#include <iostream>
#include <fstream>
using namespace std;

struct dado
{
    /* data */  
};


int main(){
    fstream arq;
    string line = "00011111" + 'n';
    unsigned char byt = 0x40;
    unsigned char byte = 0b00000001;

    arq.open ("exampl.bin", ios::out | ios::trunc | ios::binary);


    if(!arq.is_open()){
        cout << "arquivo nao aberto";
        return 404;
    }
     
    //arq.write(reinterpret_cast<const char*>(&byte), 1);
    //arq.write((char*) (&byt), 1);
    arq.write((char*) line.c_str(), 9);
    arq << byt;

    
    arq.close();
    //não criar como string e sim como inteiro em base binaria
    
}