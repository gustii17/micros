#include <iostream>
#include <fstream>
#include <map>
#include <vector>
#include <string>
using namespace std;


struct informacao
{
    string opcode;
    int quant_dadpos;
};
map<string, informacao> mapa{
    {"MOV", informacao{"00000000", 2}},
    {"ADD", informacao{"00000001", 2}},
    {"ADI", informacao{"00000010", 2}},
    {"SUB", informacao{"00000011", 2}},
    {"MUL", informacao{"00000100", 2}},
    {"DIV", informacao{"00000101", 2}},
    {"RES", informacao{"00000110", 2}},
    {"CMP", informacao{"00000111", 2}},
    {"AND", informacao{"00001000", 2}},
    {"ORR", informacao{"00001001", 2}},
    {"NOT", informacao{"00001010", 1}},
    {"XOR", informacao{"00001011", 2}},
    {"NOP", informacao{"11111111", 0}}
};

map<char, string> hexa{
    {'0', "0000"},
    {'1', "0001"},
    {'2', "0010"},
    {'3', "0011"},
    {'4', "0100"},
    {'5', "0101"},
    {'6', "0110"},
    {'7', "0111"},
    {'8', "1000"},
    {'9', "1001"},
    {'A', "1010"},
    {'B', "1011"},
    {'C', "1100"},
    {'D', "1101"},
    {'E', "1110"},
    {'F', "1111"},
    
};

string pegar_palavra(string line, int& j){
    //to_do
    string palavra;
    while(line[j] == ' ' && (j < (int)line.size())){
        j++;
    }
    if(j > (int)line.size() || line[j] == '\n') return palavra;
    while(line[j] != ' ' && j < (int)line.size()){
        palavra = palavra + line[j];
        j++;
    }
    return palavra;
}

informacao obeter_opcode(string minem){
    informacao inf = mapa[minem];
    return inf;
}

string identar(string line){

    for(int i = 1; i < (int) line.size(); i++){
        if(line[i] == '/' && line[i-1] == '/'){
            line.erase(i-1);
            return line;
        }
    }
    //to_do
    return line;
}

string trad_hexa(string palavra){
    string bin;
    for(int i = 2; i < 4; i++){
        bin = bin + hexa[palavra[i]];
    }
    return bin;
}

string obter_dado(string palavra){
    if(palavra[0] == '0'){
        if(palavra[1] == 'x'){
            //if(palavra.size() != 4) return "";
            return trad_hexa(palavra); 
        }
        else if(palavra[1] == 'b'){
            //if(palavra.size() != 10) return "";
            //return trad_bin();
        }
        else if(palavra[1] == 'd'){
           // return trad_dec();
        }
    }
    return "";
}



int main(){
    fstream arq;
    fstream bin;
    string line;
    int num_line = 0;

    arq.open("assembly.txt");
    bin.open ("exampl.bin", ios::out | ios::trunc | ios::binary);


    if(!arq.is_open()){
        cout << "arquivo nao aberto";
        return 404;
    }
    while (!arq.eof())
    {
        num_line++;
        getline(arq, line);
        //arq >> line;
        
        line = identar(line);
        cout << num_line << ' ';
        if(line.empty()){
            cout << endl;
            continue;
        }
        
        int j = 0;
        string mnem = pegar_palavra(line, j);
        cout << mnem << ' ';
        
        informacao inf = obeter_opcode(mnem);
        inf.opcode = inf.opcode + '\n';
        bin.write((char*) inf.opcode.c_str(), 9);

        for(int i = 0; i < inf.quant_dadpos; i++ ){
            string palavra = pegar_palavra(line, j);
            cout << palavra << ' ';
            string dado = obter_dado(palavra);
            cout << dado << endl;
            dado = dado + '\n';
            bin.write((char*) dado.c_str(), 9);
        }
        //string dado = "\n";
        //bin.write((char*) dado.c_str(), 1);
        cout << endl;
        
    }
    arq.close();
    



    
}