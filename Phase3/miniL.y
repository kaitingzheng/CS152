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

stringstream milCode;
ostringstream out_code;

char *identToken;
int numberToken;
int  count_names = 0;
int numTemp = 0;


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

std::vector <Function> symbol_table;
vector<string> tempTable;
Dec declarationX;

string make_temp(){
  string temp = "_temp" + to_string(numTemp);
  tempTable.push_back(temp);
  numTemp++;
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



%}

%union {
  int count = 0;
  char* str;
  char* op_val;
}

%error-verbose
%start Program
%nterm Function Function2 Function3
%nterm Declaration Declaration2 Declaration3
%nterm Statement Statement2 Statement3 Statement4
%nterm Var Var2
%nterm Term Term2 Term3 Term4
%nterm Exp Exp2
%nterm MultExp MultExp2
%nterm BoolExp BoolExp2
%nterm RelandExp RelandExp2
%nterm RelExp RelExp2
%nterm Comp

%type<str> Var

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS
%token BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE WHILE DO
%token BEGINLOOP ENDLOOP READ WRITE AND OR NOT TRUE FALSE RETURN
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token CONTINUE MULT DIV MOD 
%token <str>EQ <str>NEQ <str>LT <str>GT <str>LTE <str>GTE
%token SUB ADD
%token <str> NUMBER 
%token <str> IDENT


%type<str>Comp

%% 


Program: Function Program 
         | { printf("functions -> epsilon\n"); out_code << "endfunc" << endl;}

Function: FUNCTION IDENT 
              {std::string func_name = $2; 
              add_function_to_symbol_table(func_name);
              out_code << "func " << func_name << endl;} 
              SEMICOLON BEGIN_PARAMS Function2 END_PARAMS BEGIN_LOCALS Function2 END_LOCALS BEGIN_BODY Statement SEMICOLON Function3 END_BODY
 
  
  Function2 : Declaration SEMICOLON Function2 
            | 
  Function3 : Statement SEMICOLON Function3 
            | 

  Declaration: IDENT {declarationX.id_list.push_back($1);} Declaration2 COLON Declaration3 
  {
         if (declarationX.type == Array) {
                for (int i = 0; i < declarationX.id_list.size(); i++) {
                       out_code << ".[] " <<declarationX.id_list.at(i) << ", " << declarationX.count << "\n";
                }
         }
         else {
                
                for (int j = 0; j < declarationX.id_list.size(); j++) {
                       out_code << ". " <<declarationX.id_list.at(j) << "\n";
                }
         }
         
         declarationX.id_list.clear();
         
         
  }

  Declaration2: COMMA IDENT {;declarationX.id_list.push_back($2);} Declaration2
               | 

  Declaration3: ENUM L_PAREN IDENT Declaration2 R_PAREN
               | INTEGER {declarationX.type = Integer;}
               | ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {declarationX.type = Array; declarationX.count = $3;}

  Statement: Var ASSIGN Exp
            | IF BoolExp THEN Statement SEMICOLON Statement2 Statement3
            | WHILE BoolExp BEGINLOOP Statement SEMICOLON Statement2 ENDLOOP  
            | DO BEGINLOOP Statement SEMICOLON Statement2 ENDLOOP WHILE BoolExp  
            | READ Var Statement4 
            | WRITE Var Statement4  
            | CONTINUE 
            | RETURN Exp  
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
  RelExp2: Exp Comp Exp 
         | TRUE 
         | FALSE 
         | L_PAREN BoolExp R_PAREN 

  Comp: EQ {$$ = $1;} 
      | NEQ {$$ = $1;}
      | LT {$$ = $1;}
      | GT {$$ = $1;}
      | LTE {$$ = $1;}
      | GTE {$$ = $1;};

  Exp: MultExp Exp2 
  Exp2: ADD MultExp Exp2 
      | SUB MultExp Exp2 
      | 
  MultExp: Term MultExp2 
  MultExp2: MULT Term MultExp2 
         | DIV Term MultExp2 
         | MOD Term MultExp2 
         | 

  Term:  SUB Term2 
         | Term2 
         | IDENT L_PAREN Term3 R_PAREN 
  Term2: Var 
         | NUMBER 
         | L_PAREN Exp R_PAREN 
  Term3: Exp Term4 
         | 
  Term4:  COMMA Exp Term4 
         | 

  Var: IDENT Var2 
  Var2: L_SQUARE_BRACKET Exp R_SQUARE_BRACKET  
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