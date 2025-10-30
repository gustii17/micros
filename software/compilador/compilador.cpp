#include <iostream>
#include <fstream>
#include <map>
#include <string>
#include <cstdio>
using namespace std;


//tipo de dado para pegar o opcode e a quantidaade de parametro
struct informacao
{
    string opcode;
    int quant_dadpos;
};
//mapa que relaciona o mnemmocnico com o opcode e a quantidaade de parametro
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


//mapa para teansformar hexa em binario
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
string identar(string line){
    int j = 0;
    //remover espaços do inicio
    while (j < (int) line.size() && line[j] == ' ')
    {
        j++;
    }
    if(j >= 0) line.erase(0, j);
    
    //remover comentarios
    for(int i = 1; i < (int) line.size(); i++){
        if(line[i] == '/' && line[i-1] == '/'){
            line.erase(i-1);
            return line;
        }
    }
    return line;
}

// obtem a proxima palavra da lnha line, depois da posição j
string pegar_palavra(string line, int& j){
    string palavra;
    //pula os espaços vazios
    while(line[j] == ' ' && (j < (int)line.size())){
        j++;
    }
    //obtem a palavra 
    if(j > (int)line.size() || line[j] == '\n') return palavra;
    while(line[j] != ' ' && j < (int)line.size() && line[j] != '\n'){
        palavra = palavra + line[j];
        j++;
    }
    //se tiver uma palavra, retorna a palavra, caso não, retorna vazio
    return palavra;
}

//tranforma o mnemonico em binario
informacao obeter_opcode(string minem){
    informacao inf;
    //se estiver no map, ele pega o binario e a quantidade de operandos correspondente, caso contrario, ele retorna vazio 
    if(mapa.find(minem) == mapa.end()){
        cout << "ERROR - comand not found: " << minem << endl;
        return inf;
    }
    inf = mapa[minem];
    return inf;
}


//traduz de hexa para binario
string trad_hexa(string palavra){
    string bin;
    //so irá aceitar hexa de 2 digitos, pois nosso limite é o binario de 8 digitos
    if(palavra.size() > 4){
        return "";
    } 
    //se o hexa só tiver 1 digito, acrescenta 0000 para formar o binsrio
    if(palavra.size() == 3){
        bin = "0000";
    }
    for(int i = 2; i < 4; i++){
        //pega do mapa de hexa, o binario correspondente ao digito
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
    //se o binario for maior que 10, ele estoura nosso limite, erro
    if(palavra.size() > 10){
        cout << palavra.size();
        return "";
    } 
    //se for menor ele adiciona 0 para completar a o binario
    if(palavra.size() < 10){
        int k = 10 - (int) palavra.size();
        for(int i = 0; i < k; i++){
            bin = bin + '0';
        } 
    }
    //separando o binario e verificando se está certo
    for(i = 2; i < (int) palavra.size(); i++){
        if(!(palavra[i] == '1' || palavra[i] == '0')){
            return "";
        }
        bin = bin + palavra[i];
    }
    return bin;
}

//traduz decimal em binario
string trad_dec(string palavra){
    string bin;
    int acum = 0;
    int i = 2;

    //tranforma de string para inteiro para as operaçõs
    while(palavra[i] >= '0' && palavra[i] <= '9'){
        acum = acum * 10;
        acum = acum + palavra[i] - '0';
        i++; 
    }
    
    //verifica se a formatação esta certa
    if(i == 2 || i < (int) palavra.size()){
        return "";
    }                     
    i = 0;
    //valor maximo permitido
    if(acum >= 248) return "";

    //transforma decimal em binario
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
    
    //completa com zero até termos 8 bits
    while(i < 8){
        bin = '0' + bin;
        i++; 
    }
    
    return bin;
}

//obtem o binario correspondente da palavra
string obter_dado(string palavra){
    //verifica a estrutura 0x para hexa, 0b para binario 0d para decimal
    if(palavra[0] == '0'){
        if(palavra[1] == 'x'){
            return trad_hexa(palavra); 
        }
        else if(palavra[1] == 'b'){
            return trad_bin(palavra);
        }
        else if(palavra[1] == 'd'){
           return trad_dec(palavra);
        }
    }
    //caso não esteja na estrutura, retorna o erro
    return "";
}

//ccaso a função erro seja chamada, ela fecha os arquivos e apaga o binario, simbolizando um erro
void erro(fstream& arq, fstream& bin){
    bin.close();
    arq.close();
    cout << "apagando o arquivo" << endl;
    remove("exampl.bin");
    return;
}


int main(){
    //arquivos usados
    fstream arq; // leitura
    fstream bin; // binario gerado
    string line; // linha de leitura atual
    int num_line = 0; // contador da linha

    arq.open("assembly.txt");
    bin.open ("dados.bin", ios::out | ios::trunc | ios::binary);

    //verifica se o arquivo de leitura esta aberto
    if(!arq.is_open()){
        cout << "arquivo nao aberto";
        return 404;
    }
    //laço de leitura
    while (!arq.eof())
    {
        num_line++;
        getline(arq, line); //pega a linha atual
        
        //retirar comentarios + retirar espaços do inicio
        line = identar(line);

        //se a linha apos a identação estiver vazia, passa para o proximo
        if(line.empty()){
            cout << endl;
            continue;
        }
        

        int j = 0; // marcará a posição na linha
        string mnem = pegar_palavra(line, j); // pega o mminemonico da linha
        
        //obtem o o binario a partir do minemonico da primeira palavra da linha
        informacao inf = obeter_opcode(mnem);
        // se retornar vazio, ocorreu um erro, e ele encerra o programa
        if(inf.opcode.empty()){
            erro(arq, bin);
            return 404;
        }

        //colocando uma quebra de linha no final do opcode e escrevendo no binario
        inf.opcode = inf.opcode + '\n';
        bin.write((char*) inf.opcode.c_str(), 9);

        // pega a quantidade de parametros correspondente do mnemonico 
        for(int i = 0; i < inf.quant_dadpos; i++ ){
            //pegando o proximo parametro
            string palavra = pegar_palavra(line, j);
            //se retornar vazio, não achou parametro, e ocorrreu um erro
            if(palavra == ""){
                cout << "ERROR -- line: " << num_line << ":       missing arguments" << endl;
                erro(arq, bin);
                return 400;
            }
            
            //obtem o binario do parametro
            string dado = obter_dado(palavra);
            //verificação de erro
            if(dado.empty()){
                cout << "ERROR -- line: " << num_line << ":       argument invalid: " << palavra << endl;
                erro(arq, bin);
                return 404;
            }
            //escrevendo o dado no arquivo
            dado = dado + '\n';
            bin.write((char*) dado.c_str(), 9);
        }
        //se houver mais parametros que o permitido, acusa de erro
        string palavra = pegar_palavra(line, j);
        if(!(palavra == "")){
                cout << "ERROR -- line: " << num_line << ":       most arguments: " << palavra << endl;
                erro(arq, bin);
                return 404;
            }
        
    }
    //fechando os arquivos
    bin.close();
    arq.close();
    



    
}