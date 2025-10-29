#include <iostream>
#include <fstream>
#include <map>
#include <vector>
#include <string>
#include <cstdio>
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
    while(line[j] != ' ' && j < (int)line.size() && line[j] != '\n'){
        palavra = palavra + line[j];
        j++;
    }
    return palavra;
}

informacao obeter_opcode(string minem){
    informacao inf;
    if(mapa.find(minem) == mapa.end()){
        cout << "ERROR - comand not found: " << minem << endl;
        return inf;
    }
    inf = mapa[minem];
    return inf;
}

string identar(string line){
    int j = 0;
    while (j < (int) line.size() && line[j] == ' ')
    {
        j++;
    }
    if(j >= 0) line.erase(0, j);
    
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
    if(palavra.size() != 4){
        return "";
    } 
    for(int i = 2; i < 4; i++){
        if(hexa.find(palavra[i]) == hexa.end()){
            return "";
        }
        bin = bin + hexa[palavra[i]];
    }
    return bin;
}

string trad_bin(string palavra){
    string bin;
    int i;
    if(palavra.size() != 10){
        return "";
    } 
    for(i = 2; i < 10; i++){
        if(!(palavra[i] == '1' || palavra[i] == '0')){
            return "";
        }
        bin = bin + palavra[i];
    }
    return bin;
}

string trad_dec(string palavra){
    string bin;
    int acum = 0;
    int i = 2;
    
    while(palavra[i] >= '0' && palavra[i] <= '9'){
        acum = acum * 10;
        acum = acum + palavra[i] - '0';
        i++; 
    }
    
    if(i == 2 || i < (int) palavra.size()){
        return "";
    }                     
    i = 0;
    if(acum >= 248) return "";
    while (acum > 0)
    {
        i++;
        if(acum % 2 == 1){
            acum = (acum - 1) / 2;
            bin = '1' + bin;
        }
        else{
            acum = acum / 2;
            bin = '0' + bin; 
        }
    }
    
    
    while(i < 8){
        bin = '0' + bin;
        i++; 
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
            return trad_bin(palavra);
        }
        else if(palavra[1] == 'd'){
           return trad_dec(palavra);
        }
    }
    return "";
}

void erro(fstream& arq, fstream& bin){
    bin.close();
    arq.close();
    cout << "apagando o arquivo" << endl;
    remove("exampl.bin");
    return;
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
        
        line = identar(line);
        if(line.empty()){
            cout << endl;
            continue;
        }
        
        int j = 0;
        string mnem = pegar_palavra(line, j);
        //cout << mnem << ' ';
        
        informacao inf = obeter_opcode(mnem);
        if(inf.opcode.empty()){
            erro(arq, bin);
            return 404;
        }
        inf.opcode = inf.opcode + '\n';
        bin.write((char*) inf.opcode.c_str(), 9);

        for(int i = 0; i < inf.quant_dadpos; i++ ){
            string palavra = pegar_palavra(line, j);
            if(palavra == ""){
                cout << "ERROR -- line: " << num_line << ":       missing arguments" << endl;
                erro(arq, bin);
                return 404;
            }
            
            string dado = obter_dado(palavra);

            if(dado.empty()){
                cout << "ERROR -- line: " << num_line << ":       argument invalid: " << palavra << endl;
                erro(arq, bin);
                return 404;
            }
            dado = dado + '\n';
            bin.write((char*) dado.c_str(), 9);
        }
        string palavra = pegar_palavra(line, j);
        if(!(palavra == "")){
                cout << "ERROR -- line: " << num_line << ":       most arguments: " << palavra << endl;
                erro(arq, bin);
                return 404;
            }
        //string dado = "\n";
        //bin.write((char*) dado.c_str(), 1);
        
    }
    bin.close();
    arq.close();
    



    
}