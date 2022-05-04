%{   
   /*
   Kaiting Zheng, Sec 21
   Gabriel Ruelas, Sec 23

   Enter C code below for CS152
   */
   
   int currLine = 1, currPos = 1;
%}

DIGIT    [0-9]
alpha    [a-zA-Z]
underscore [_]

%%



"function"     {currPos+= yyleng; return FUNCTION}
"beginparams"  {currPos+= yyleng; return BEGIN_PARAMS}
"endparams"    {currPos+= yyleng; return END_PARAMS}
"beginlocals"  {currPos+= yyleng; return BEGIN_LOCALS}
"endlocals"    {currPos+= yyleng; return END_LOCALS}
"beginbody"    {currPos+= yyleng; return BEGIN_BODY}
"endbody"      {currPos+= yyleng; return END_BODY}
"integer"      {currPos+= yyleng; return INTEGER}
"array"        {currPos+= yyleng; return ARRAY}
"enum"         {currPos+= yyleng; return ENUM}
"of"           {currPos+= yyleng; return OF}
"if"           {currPos+= yyleng; return IF}
"then"         {currPos+= yyleng; return THEN}
"endif"        {currPos+= yyleng; return ENDIF}
"else"         {currPos+= yyleng; return ELSE}
"for"          {currPos+= yyleng; return FOR}
"while"        {currPos+= yyleng; return WHILE}
"do"           {currPos+= yyleng; return DO}
"beginloop"    {currPos+= yyleng; return BEGINLOOP}
"endloop"      {currPos+= yyleng; return ENDLOOP}
"continue"     {currPos+= yyleng; return CONTINUE}
"read"         {currPos+= yyleng; return READ}
"write"        {currPos+= yyleng; return WRITE}
"and"          {currPos+= yyleng; return AND}
"or"           {currPos+= yyleng; return OR}
"not"          {currPos+= yyleng; return NOT}
"true"         {currPos+= yyleng; return TRUE}
"false"        {currPos+= yyleng; return FALSE}
"return"       {currPos+= yyleng; return RETURN}

";"            {currPos += yyleng; return SEMICOLON}
":"            {currPos += yyleng; return COLON}
","            {currPos += yyleng; return COMMA}
"("            {currPos += yyleng; return L_PAREN}
")"            {currPos += yyleng; return R_PAREN}
"["            {currPos += yyleng; return L_SQUARE_BRACKET}
"]"            {currPos += yyleng; return R_SQUARE_BRACKET}
":="           {currPos += yyleng; return ASSIGN}

(({alpha}+{DIGIT}*)+)|(({alpha}+{DIGIT}*)+({underscore}({alpha}|{DIGIT})+)*)   {currPos += yyleng; return IDENT}


("##"(.)*)   {currPos += yyleng;}


   /* specific lexer rules in regex */

({DIGIT}+(\.{DIGIT}*)?([eE][+-]?[0-9]+)?)|(\.{DIGIT}+) {yylval.dval = atof(yytext); return NUMBER}

"-"            {currPos+=yyleng; return SUB}
"+"            {currPos+=yyleng; return ADD}
"*"            {currPos+=yyleng; return MULT}
"/"            {currPos+=yyleng; return DIV}
"%"            {currPos+=yyleng; return MOD}

"=="           {currPos+=yyleng; return EQ}
"<>"           {currPos+=yyleng; return NEQ}
"<"            {currPos+=yyleng; return LT}
">"            {currPos+=yyleng; return GT}
"<="           {currPos+=yyleng; return LTE}
">="           {currPos+=yyleng; return GTE}

[ \t]+         {/* ignore spaces */ currPos += yyleng;}

"\n"           {currLine++; currPos = 1;}


.              {("Error at line %d, column %d: unrecongonized symbol \"%s\"\n",currLine, currPos, yytext); exit(0);}

(({DIGIT}+{alpha}*{underscore}?)+)   {("Error at line %d, column %d: identifier \"%s\" must start with a letter \n",currLine, currPos, yytext); exit(0);}

({alpha}+{DIGIT}*{underscore}+)   {("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore \n",currLine, currPos, yytext); exit(0);}

%%
