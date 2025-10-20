#include <iostream>
#include <fstream>
using namespace std;

int main(){
    fstream arq;
    string line;

    arq.open("example.bin");


    if(!arq.is_open()){
        cout << "arquivo nao aberto";
        return 404;
    }
    while (!arq.eof())
    {
        getline(arq, line);
        cout << line << endl;
        
    }
    arq.close();
    
}