/* cs152-miniL phase3 */


%{
void yyerror(const char *msg);
extern int yylex();

#include "lib.h"
#include <stdio.h>
#include <stdlib.h>

 extern int currLine;
 extern int currPos;

extern "C" FILE *yyin;

%}

%union {
  int int_val;
  char* str;
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
%token CONTINUE SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE
%token NUMBER
%token <str>IDENT

%token<int_val> DIGIT
%type<str> EQ
%type<str> NEQ
%type<str> LT
%type<str> GT
%type<str> LTE
%type<str> GTE
%type<str>Comp

%% 

  /* write your rules here */
 Program: Function Program {printf("Program -> Function Program\n");}
         | {printf("Program -> epsilon\n");};

  Function: FUNCTION IDENT SEMICOLON BEGIN_PARAMS Function2 END_PARAMS BEGIN_LOCALS Function2 END_LOCALS BEGIN_BODY Statement SEMICOLON Function3 END_BODY 
  {printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements SEMICOLON functions END_BODY \n");};
  
  Function2 : Declaration SEMICOLON Function2 {printf("Function2 -> Declaratio SEMICOLON Function2\n");} 
            | {printf("function2 -> epsilon\n");} ;
  Function3 : Statement SEMICOLON Function3 {printf("Function2 -> Statement SEMICOLON Function3\n");} 
            | {printf("function3 -> epsilon\n");};

  Declaration: IDENT Declaration2 COLON Declaration3 {printf("Declaration -> IDENT Declaration2 COLON Declaration3\n");};
  Declaration2: COMMA IDENT Declaration2 {printf("Declaration2 -> IDENT Declaration2\n");}
               | {printf("declarations -> epsilon\n");};
  Declaration3: ENUM L_PAREN IDENT Declaration2 R_PAREN  {printf("Declaration3 -> ENUM L_PAREN IDENT Declaration2 R_PAREN \n");}
               | INTEGER  {printf("Declaration-> INTEGER\n");}
               | ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER  {printf("Declaration3 -> ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");};

  Statement: Var ASSIGN Exp  {printf("Statement -> Var ASSIGN Exp\n");}
            | IF BoolExp THEN Statement SEMICOLON Statement2 Statement3  {printf("Statement -> IF BoolExp THEN Statement SEMICOLON Statement2 Statement3\n");} 
            | WHILE BoolExp BEGINLOOP Statement SEMICOLON Statement2 ENDLOOP  {printf("Statement ->WHILE BoolExp BEGINLOOP Statement SEMICOLON Statement2 ENDLOOP\n");}
            | DO BEGINLOOP Statement SEMICOLON Statement2 ENDLOOP WHILE BoolExp  {printf("Statement -> DO BEGINLOOP Statement SEMICOLON Statement2 ENDLOOP WHILE BoolExp\n");}
            | READ Var Statement4 {printf("Statement -> READ Var Statement4\n");}
            | WRITE Var Statement4  {printf("Statement -> WRITE Var Statement4\n");}
            | CONTINUE {printf("Statement -> CONTINUE\n");}
            | RETURN Exp  {printf("Statement-> RETURN Exp\n");};
  Statement2: Statement SEMICOLON Statement2  {printf("Statement2 -> Statement SEMICOLON Statement2\n");}
            |  {printf("Statement2 -> epsilon\n");};
  Statement3: ENDIF  {printf("Statement3 -> ENDIF\n");}
            | ELSE Statement SEMICOLON Statement2 ENDIF {printf("Statement3 -> ELSE Statement SEMICOLON Statement2 ENDIF\n");};
  Statement4: COMMA Var Statement4 {printf("Statement4 -> COMMA Var Statement4\n");}
            | {printf("Statement4 -> epsilon\n");};

  BoolExp:  RelandExp BoolExp2 {printf("BoolExp -> RelandExp BoolExp2\n");};
  BoolExp2: OR RelandExp BoolExp2 {printf("BoolExp -> OR RelandExp BoolExp2\n");}
         | {printf("Statement3 -> ENDIF\n");};

  RelandExp: RelExp RelandExp2 {printf("RelandExp -> RelExp RelandExp2\n");};
  RelandExp2: AND RelExp RelandExp2 {printf("RelandExp2 -> AND RelExp RelandExp2\n");}
            | {printf("RelandExp2 -> epsilon\n");} ;

  RelExp: NOT RelExp2 {printf("RelExp -> NOT RelExp2\n");} 
         | RelExp2 {printf("RelExp -> RelExp2\n");};
  RelExp2: Exp Comp Exp {printf("RelExp2 -> Exp Comp Exp\n");}
         | TRUE {printf("RelExp2 ->TRUE\n");}
         | FALSE {printf("RelExp2 -> FALSE\n");}
         | L_PAREN BoolExp R_PAREN {printf("RelExp2 -> L_PAREN BoolExp R_PAREN\n");};

  Comp: EQ {$$ = $1;} 
      | NEQ {$$ = "!=";}
      | LT {$$ = $1;}
      | GT {$$ = $1;}
      | LTE {$$ = $1;}
      | GTE{$$ = $1;};

  Exp: MultExp Exp2 {printf("exp -> add multexp exp2\n");};
  Exp2: ADD MultExp Exp2 {printf("exp2 -> add multexp exp2\n");}
      | SUB MultExp Exp2 {printf("exp2 -> sub multexp exp2\n");}
      | {printf("Exp -> epsilon\n");};

  MultExp: Term MultExp2 {printf("MultExp -> Term MultExp2\n");};
  MultExp2: MULT Term MultExp2 {printf("MultExp2 -> MULT Term MultExp2\n");}
         | DIV Term MultExp2 {printf("MultExp2 -> DIV Term MultExp2\n");}
         | MOD Term MultExp2 {printf("MultExp2 -> MOD Term MultExp2\n");}
         | {printf("MultExp2 -> epsilon\n");};

  Term:  SUB Term2 {printf("Term -> SUB Term2\n");}
         | Term2 {printf("Term-> Term2\n");}
         | IDENT L_PAREN Term3 R_PAREN {printf("Term -> DIV Term MultExp2\n");};
  Term2: Var {printf("Term2 -> Var\n");}
         | NUMBER {printf("Term2 -> NUMBER\n");}
         | L_PAREN Exp R_PAREN {printf("Term2 -> L_PAREN Exp R_PAREN\n");};
  Term3: Exp Term4 {printf("Term3 -> Exp Term4\n");}
         | {printf("Term3 -> epsilon\n");};
  Term4:  COMMA Exp Term4 {printf("Term4 -> COMMA Exp Term4\n");}
         | {printf("Term4 -> epsilon\n");};

  Var: IDENT Var2 ;
  Var2: L_SQUARE_BRACKET Exp R_SQUARE_BRACKET  {printf("Var2 -> L_SQUARE_BRACKET Exp R_SQUARE_BRACKET \n");};
      |  {printf("Var -> epsilon \n");};

%% 

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
    /* implement your error handling */
    printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}