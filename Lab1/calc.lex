   /* cs152-calculator */
   
%{   

 /* write your C code here for defination of variables and including headers */
 int currLine = 1, currPos = 1;
 int numInt = 0, numOp = 0, numParens = 0, numEquals = 0;
%}


   /* some common rules, for example DIGIT */
DIGIT    [0-9]
   
%%
   /* specific lexer rules in regex */


({DIGIT}+(\.{DIGIT}*)?([eE][+-]?[0-9]+)?)|(\.{DIGIT}+) {printf("NUMBER %s\n", yytext);}


"+"            {printf("PLUS \n"); currPos += yyleng; numOp++;}
"="            {printf("EQUAL\n"); currPos += yyleng; numEquals++;}
"-"            {printf("MINUS\n"); currPos += yyleng; numOp++;}
"*"            {printf("MULT\n"); currPos += yyleng; numOp++;}
"/"            {printf("DIV\n"); currPos += yyleng; numOp++;}
"("            {printf("L_PAREN\n"); currPos += yyleng; numParens++;}
")"            {printf("R_PAREN\n"); currPos += yyleng; numParens++;}

[ \t]+         {/* ignore spaces */ currPos += yyleng;}

"\n"           {currLine++; currPos = 1;}



%%
	/* C functions used in lexer */

int main(int argc, char ** argv)
{
   if(argc >= 2){
      yyin = fopen(argv[1],"r");
      if(yyin == NULL){
         yyin = stdin;
      }
   }
   else{
      yyin = stdin;
   }
   yylex();
   printf("# of Integers: %d\n", numInt);
   printf("# of Operators: %d\n", numOp);
   printf("# of Parentheses: %d\n", numParens);
   printf("# of Equal signs: %d\n", numEquals);
}

