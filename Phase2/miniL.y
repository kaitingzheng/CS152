    /* cs152-miniL phase2 */
%{
#include <stdio.h>
 #include <stdlib.h>
 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 FILE * yyin;
%}

%union{
  /* put your types here */
  char* str;
  double dval;
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


%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS
%token BEGIN_BODY END_BODY INTEGER ARRAY ENUM OF IF THEN ENDIF ELSE WHILE DO
%token BEGINLOOP ENDLOOP READ WRITE AND OR NOT TRUE FALSE RETURN
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN
%token IDENT SUB ADD MULT DIV MOD EQ NEQ LT GT LTE GTE
%token NUMBER

/* %start program !!NOTE!!CONTINE and FOR tokens not used!*/

%% 
  /* write your rules here */
  Program: Function Program {printf("Program -> Function Program\n");}
         | {printf("Program -> epsilon\n");};

  Function: FUNCTION IDENT SEMICOLON BEGIN_PARAMS Function2 END_PARAMS BEGIN_LOCALS Function2 END_LOCALS BEGIN_BODY Statement SEMICOLON Function3 END_BODY 
  {printf("function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements SEMICOLON functions END_BODY \n");};
  
  Function2 : Declaration SEMICOLON Function2 
            | {printf("function2 -> epsilon\n");} ;
  Function3 : Statement SEMICOLON Function3 
            | {printf("function3 -> epsilon\n");};

  Declaration: IDENT Declaration2 COLON Declaration3 {printf("Declaration -> IDENT Declaration2 COLON Declaration3\n");};
  Declaration2: IDENT Declaration2 {printf("Declaration2 -> IDENT Declaration2\n");}
               | {printf("declarations -> epsilon\n");};
  Declaration3: ENUM L_PAREN IDENT Declaration2 R_PAREN | INTEGER | ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER ;

  Statement: Var ASSIGN Exp 
            | IF BoolExp THEN Statement SEMICOLON Statement2 Statement3 
            | WHILE BoolExp BEGINLOOP Statement SEMICOLON Statement2 ENDLOOP
            | DO BEGINLOOP Statement SEMICOLON Statement2 ENDLOOP WHILE BoolExp
            | READ Var Statement4
            | WRITE Var Statement4
            | RETURN Exp ;
  Statement2: Statement SEMICOLON Statement2 | ;
  Statement3: ENDIF | ELSE Statement SEMICOLON Statement2 ENDIF;
  Statement4: COMMA Var Statement4 | ;

  BoolExp:  RelandExp BoolExp2;
  BoolExp2: OR RelandExp BoolExp2 | ;

  RelandExp: RelExp RelandExp2;
  RelandExp2: AND RelExp RelandExp2 | ;

  RelExp: NOT RelExp2 | RelExp2;
  RelExp2: Exp Comp Exp | TRUE | FALSE | L_PAREN BoolExp R_PAREN;

  Comp: EQ {printf("comp -> EQ \n");} 
      | NEQ {printf("comp -> NEQ \n");}
      | LT {printf("comp -> LT \n");}
      | GT {printf("comp -> GT \n");}
      | LTE {printf("comp -> LTE \n");}
      | GTE{printf("comp -> GTE \n");};

  Exp: MultExp Exp2;
  Exp2: ADD MultExp Exp2 {printf("exp -> add multexp exp2\n");}
      | SUB MultExp Exp2 {printf("exp -> sub multexp exp2\n");}
      | {printf("Exp -> epsilon\n");};

  MultExp: Term MultExp2;
  MultExp2: MULT Term MultExp2 | DIV Term MultExp2 | MOD Term MultExp2 | ;

  Term:  SUB Term2 | Term2 | IDENT L_PAREN Term3 R_PAREN;
  Term2: Var | NUMBER | L_PAREN Exp R_PAREN;
  Term3: Exp Term4 | ;
  Term4:  COMMA Exp Term4 | ;

  Var: IDENT Var2 {printf("Var -> IDENT \n");};
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