/* cs152-miniL phase3 */


%{
void yyerror(const char *msg);
extern int yylex();

#include "lib.h"
#include <stdio.h>
#include <stdlib.h>

#include<iostream>
#include<vector>
#include<stack>
#include<fstream>
#include<sstream>
#include<string>
#include<string.h>


using namespace std;

 extern int currLine;
 extern int currPos;

extern "C" FILE *yyin;

ostringstream out_code;

char *identToken;
int numberToken;
int  count_names = 0;
int numTemp = 0;
int numLabel = 0;


enum Type { Integer, Array };
struct Symbol {
  std::string name;
  Type type;
};
struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};

struct Dec {
       std::vector<string> id_list;
       Type type;
       string count;
};

struct TnO {
string operation;
string term;
};

struct e {
  string place;
  string code;
  vector<TnO> list;
  int count = 0;
};

struct me {
  string place;
  string code;
  vector<TnO> list;
};

struct S {
  string before;
  string after;
  string code;

};

std::vector <Function> symbol_table;
vector<string> tempTable;
vector<string> labelTable;
Dec declarationX;

e E;
me mE;



string make_temp(){
  string temp = "__temp__" + to_string(numTemp);
  tempTable.push_back(temp);
  numTemp++;
  return temp;
}

string make_label(){
  string temp = "__label__" + to_string(numLabel);
  labelTable.push_back(temp);
  numLabel++;
  return temp;
}


Function *get_function() {
  int last = symbol_table.size()-1;
  return &symbol_table[last];
}

bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

void add_function_to_symbol_table(std::string &value) {
  Function f; 
  f.name = value; 
  symbol_table.push_back(f);
}

void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

void mEfinished() {
  if (mE.place == "!!!") return;

  if (mE.list.size() == 0) {
    cout << "hi mE size check\n";
    string temp = make_temp();
    out_code << ". " << temp << "\n";
    out_code << "= " <<temp << ", " << mE.place << "\n";
    //E.place = mE.place;
  }
  else {
    
    for (int i = mE.list.size()-1; i >= 0; --i) {
      string temp = make_temp();
      out_code << ". " << temp << "\n";
      out_code << mE.list.at(i).operation << " ";
      out_code << temp << ", ";
      if (i ==  mE.list.size()-1) {
        out_code << mE.place << ", ";
        
      }
      else {
        out_code << tempTable.at(tempTable.size()-2) << ", ";
      }
      out_code << mE.list.at(i).term << "\n";
    }
  }
  mE.list.clear();
  mE.place = "!!!";
}

void Efinished() {
  if (E.place == "!!!") return;

  if (E.list.size() == 0) {
    //string temp = make_temp();
    //out_code << ". " << temp << "\n";
    //out_code << "= " <<temp << ", " << E.place << "\n";
  }
  else {
    
    for (int i = E.list.size()-1; i >= 0; --i) {
      string temp = make_temp();
      out_code << ". " << temp << "\n";
      out_code << E.list.at(i).operation << " ";
      out_code << temp << ", ";
      if (i ==  E.list.size()-1) {
        cout << "hi E if\n";
        cout << "size :" << tempTable.size() << "\n";
        cout << "E.count : " << E.count << "\n";
        out_code << tempTable.at((tempTable.size()-1) - E.count - 1) << ", ";
        
      }
      else {
        cout << "hi E else\n";
        out_code << tempTable.at((tempTable.size()-1) - 1) << ", ";
      }
      cout << "hi E after if else\n";
      out_code << tempTable.at((tempTable.size()-1) - E.count) << "\n";
      cout << "after last print\n";
    }
  }
  E.count = 0;
  E.list.clear();
  E.place = "!!!";
}


%}

%union {
  int count = 0;
  char* str;
  char* op_val;
}

%error-verbose
%start Program


%type<str> Var

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS
%token BEGIN_BODY END_BODY INTEGER ENUM OF IF THEN ENDIF ELSE WHILE DO
%token BEGINLOOP ENDLOOP READ WRITE TRUE FALSE RETURN
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET
%token CONTINUE
%token <str> NUMBER 
%token <str> IDENT



%right ASSIGN
%left OR
%left AND
%right NOT
%left <str>LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD
%left ARRAY
%left FUNCTION

%type<str> Comp Exp Exp2
%type<str> Term
%type<str> MultExp MultExp2
%type<str> Declaration 
%type<str> RelExp 
%type<str> RelExp2

%% 


Program: Function {out_code << "endfunc" << endl;} Program 
         | { printf("functions -> epsilon\n");}

Function: FUNCTION IDENT 
              {std::string func_name = $2; 
              add_function_to_symbol_table(func_name);
              out_code << "func " << func_name << endl;} 
              SEMICOLON BEGIN_PARAMS Function2 END_PARAMS BEGIN_LOCALS Function4 END_LOCALS BEGIN_BODY Statement SEMICOLON Function3 END_BODY
 
  
Function2 : Declaration SEMICOLON Function2 {out_code << "= " << $1<< ", $0" << endl;}
            |
Function3 : Statement SEMICOLON Function3 
            |
Function4 : Declaration SEMICOLON Function4
            |

Declaration: IDENT {declarationX.id_list.push_back($1);} Declaration2 COLON Declaration3 
  {
         if (declarationX.type == Array) {
                for (int i = 0; i < declarationX.id_list.size(); i++) {
                       out_code << ".[] " <<declarationX.id_list.at(i) << ", " << declarationX.count << "\n";
                       $$ = $1;
                }
         }
         else {
                
                for (int j = 0; j < declarationX.id_list.size(); j++) {
                       out_code << ". " <<declarationX.id_list.at(j) << "\n";
                       $$ = $1;
                }
         }
         
         declarationX.id_list.clear();
         
         
  }

Declaration2: COMMA IDENT {;declarationX.id_list.push_back($2);} Declaration2
               | 

Declaration3: ENUM L_PAREN IDENT Declaration2 R_PAREN
               | INTEGER {declarationX.type = Integer;}
               | ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {declarationX.type = Array; declarationX.count = $3;}

Statement: Var ASSIGN Exp {Efinished();}
            | IF BoolExp THEN {
                          
                string label1 = make_label();
                string label2 = make_label();

                out_code << "?:= " << label1 << ", " << tempTable[numTemp-1] << endl;

                out_code << ":= " << label2 << endl;
                out_code << ": " << label1 << endl;



            }
            Statement SEMICOLON Statement2 Statement3
            | WHILE BoolExp BEGINLOOP Statement SEMICOLON Statement2 ENDLOOP  
            | DO BEGINLOOP Statement SEMICOLON Statement2 ENDLOOP WHILE BoolExp  
            | READ Var Statement4 {
              out_code << ".< " << $2 << endl;
            }
            | WRITE Var Statement4  {
              out_code << ".> " << $2 << endl;
            }
            | CONTINUE 
            
            | RETURN Exp{
              string temp = make_temp();

              out_code << ". " << temp << endl;
              out_code << "= " << temp << ", "<< $2 << endl;

              out_code<< "ret " << temp << endl; 
            }
Statement2: Statement SEMICOLON Statement2  
            |  
Statement3: ENDIF  
            | ELSE Statement SEMICOLON Statement2 ENDIF 
Statement4: COMMA Var Statement4 
            | 

BoolExp:  RelandExp BoolExp2 
BoolExp2: OR RelandExp BoolExp2 
         | 

RelandExp: RelExp RelandExp2 
RelandExp2: AND RelExp RelandExp2 
            | 

RelExp: NOT RelExp2 
         | RelExp2 
RelExp2: Exp Comp Exp {
            string temp1 = make_temp();
            string temp2 = make_temp();

            out_code << ". " << temp1 << endl;
            out_code << "= " << temp1 << ", "<< $1 << endl;

            out_code << ". " << temp2 << endl;
            out_code << "= " << temp2 << ", "<< $3 << endl;

            string temp3 = make_temp();

            out_code << ". " << temp3 << endl;

            //compare
            out_code << $2 << " " << temp3 << ", " << temp1 << ", " << temp2 << endl;

          }
         | TRUE 
         | FALSE 
         | L_PAREN BoolExp R_PAREN 

Comp: EQ {$$ =  "==";} 
      | NEQ {$$ = "!=";}
      | LT {$$ = "<";}
      | GT {$$ = ">";}
      | LTE {$$ = "<=";}
      | GTE {$$ = ">=";};

Exp: MultExp Exp2 {$$ = $1;}
Exp2: ADD MultExp {mEfinished();} Exp2 {
          TnO tempTnO;
          tempTnO.operation = "+"; 
          tempTnO.term = $2;
          E.list.push_back(tempTnO); 
          E.count++;

        }
      | SUB MultExp {mEfinished();} Exp2 {TnO tempTnO; tempTnO.operation = "-"; tempTnO.term = $2;E.list.push_back(tempTnO);  E.count++;}
      | 
      
MultExp: Term {mE.place = $1;} MultExp2 {}
MultExp2: MULT Term MultExp2 {
            TnO tempTnO; 
            tempTnO.operation = "*"; 
            tempTnO.term = $2;
            mE.list.push_back(tempTnO);  
            E.count++;
          }
         | DIV Term MultExp2 {TnO tempTnO; tempTnO.operation = "/"; tempTnO.term = $2;mE.list.push_back(tempTnO);  E.count++;}
         | MOD Term MultExp2 {TnO tempTnO; tempTnO.operation = "%"; tempTnO.term = $2;mE.list.push_back(tempTnO);  E.count++;}
         | /*epsilon*/

Term: SUB Var 
      | SUB NUMBER
      | SUB L_PAREN Exp R_PAREN
      | Var {$$ = $1;}
      | NUMBER {$$ = $1;}
      | L_PAREN Exp {Efinished();} R_PAREN 
      | IDENT L_PAREN Term2 R_PAREN 

Term2: Exp Term3 
         | /*epsilon*/
Term3:  COMMA Exp {Efinished();} Term3 
         | /*epsilon*/

Var: IDENT Var2 {$$ = $1;}
Var2: L_SQUARE_BRACKET Exp {Efinished();} R_SQUARE_BRACKET  
      |  

%% 

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   print_symbol_table();

   ofstream myFile;
   myFile.open("machine_code.mil");
   myFile << out_code.str();
   myFile.close();
   return 0;
}

void yyerror(const char *msg) {
    /* implement your error handling */
    printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}