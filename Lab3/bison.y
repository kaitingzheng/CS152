%{
#include<stdio.h>
#include <stdlib.h>
#include<string>
#include<vector>
#include<string.h>

#include<fstream>
#include<sstream>

using namespace std;

extern int yylex(void);
void yyerror(const char *msg);
extern int currLine;
extern "C" FILE *yyin;

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

std::vector <Function> symbol_table;
vector<string> tempTable;

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
  char *op_val;
}

%define parse.error verbose
%start prog_start
%token BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token FUNCTION 
%token INTEGER 
%token WRITE
%token SUB ADD MULT DIV MOD
%token SEMICOLON COLON COMMA ASSIGN
%token <op_val> NUMBER 
%token <op_val> IDENT
%type <op_val> symbol 

%%

prog_start: functions
{
  printf("prog_start -> functions\n");
}

functions: 
/* epsilon */
{ 
  printf("functions -> epsilon\n");
  out_code << "endfunc" << endl;
}
| function functions
{
  printf("functions -> function functions\n");
};

function: FUNCTION IDENT 
{
  // midrule:
  // add the function to the symbol table.
  std::string func_name = $2;
  add_function_to_symbol_table(func_name);
  out_code<< "func " << func_name << endl;
}
	SEMICOLON
	BEGIN_PARAMS declarations END_PARAMS
	BEGIN_LOCALS declarations END_LOCALS
	BEGIN_BODY statements END_BODY
{
  printf("function -> FUNCTION IDENT ; BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY\n");
};

declarations: 
/* epsilon */
{
  printf("declarations -> epsilon\n");
}
| declaration SEMICOLON declarations
{
  printf("declarations -> declaration ; declarations\n");
};

declaration: 
	IDENT COLON INTEGER
{
  printf("declaration -> IDENT : integer\n");

  // add the variable to the symbol table.
  std::string value = $1;
  Type t = Integer;
  add_variable_to_symbol_table(value, t);
  out_code << ". " << value << endl;
};

statements: 
statement SEMICOLON
{
  printf("statements -> statement ;\n");
}
| statement SEMICOLON statements
{
  printf("statements -> statement ; statements\n");
};

statement: 
IDENT ASSIGN symbol ADD symbol
{
  printf("statement -> IDENT := symbol + symbol\n");
  string temp = make_temp();
  out_code << ". " << temp << endl;
  out_code<< "+ " << temp << ", " << $3 << ", " << $5 << endl;
  out_code << "= " << $1 << ", " << temp << endl;

}
| IDENT ASSIGN symbol SUB symbol
{
  printf("statement -> IDENT := symbol - symbol\n");
  string temp = make_temp();
  out_code << ". " << temp << endl;
  out_code<< "- " << temp << ", " << $3 << ", " << $5 << endl;
  out_code << "= " << $1 << ", " << temp << endl;
}
| IDENT ASSIGN symbol MULT symbol
{
  printf("statement -> IDENT := symbol * symbol\n");
  string temp = make_temp();
  out_code << ". " << temp << endl;
  out_code<< "* " << temp << ", " << $3 << ", " << $5 << endl;
  out_code << "= " << $1 << ", " << temp << endl;
}
| IDENT ASSIGN symbol DIV symbol
{
  printf("statement -> IDENT := symbol / symbol\n");
  string temp = make_temp();
  out_code << ". " << temp << endl;
  out_code<< "/ " << temp << ", " << $3 << ", " << $5 << endl;
  out_code << "= " << $1 << ", " << temp << endl;
}
| IDENT ASSIGN symbol MOD symbol
{
  printf("statement -> IDENT := symbol %% symbol\n");
  string temp = make_temp();
  out_code << ". " << temp << endl;
  out_code<< "% " << temp << ", " << $3 << ", " << $5 << endl;
  out_code << "= " << $1 << ", " << temp << endl;
}

| IDENT ASSIGN symbol
{
  printf("statement -> IDENT := symbol\n");
  out_code << "= " << $1<< ", " << $3 << endl;

}

| WRITE IDENT
{
  printf("statement -> WRITE IDENT\n");
  out_code << ".> " << $2<< endl;
}
;

symbol: 
IDENT 
{
  printf("symbol -> IDENT %s\n", $1); 
  $$ = $1; 
}
| NUMBER 
{
  printf("symbol -> NUMBER %s\n", $1);
  $$ = $1; 

}

%%

int main(int argc, char **argv)
{
  if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse();
   print_symbol_table();

  ofstream myFile;
   myFile.open("machine_code.mil");
   myFile << out_code.str();
   myFile.close();
   return 0;
}

void yyerror(const char *msg)
{
   printf("** Line %d: %s\n", currLine, msg);
   exit(1);
}
