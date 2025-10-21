#include <iostream>
#include <fstream>
using namespace std;

struct dado
{
    /* data */  
};


int main(){
    fstream arq;
    string line = "000";
    unsigned char byt = 0x40;

    arq.open ("exampl.bin", ios::out | ios::trunc | ios::binary);


    if(!arq.is_open()){
        cout << "arquivo nao aberto";
        return 404;
    }
    //arq.write((char*) (&byt), 1);
    arq.write((char*) line.c_str(), 8);
    
    arq.close();
    
}