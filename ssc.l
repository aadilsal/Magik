%{
    #include <llvm/IR/Value.h>
    #include "ssc.tab.h"
    #include <stdlib.h>
    #include <stdio.h>
    #include <string>
    extern void yyerror(const char *msg);
    
<<<<<<< HEAD
    //#define DEBUGSSC
=======
>>>>>>> master
    #ifdef DEBUGSSC
        #define debugFlex(a) (printf("\n%d: Token=<ID, lexeme>=<%d, %s>\n",yylineno, a, yytext))
    #else
        #define debugFlex(a)
    #endif
%}

%option yylineno 
%option noyywrap

%%

"printd"                {debugFlex(tok_printd); return tok_printd;}
"prints"                {debugFlex(tok_prints); return tok_prints;}
"if"                    {debugFlex(tok_if); return tok_if;}
"else"                  {debugFlex(tok_else); return tok_else;}
<<<<<<< HEAD
"for"                   {debugFlex(tok_for); return tok_for;}
"return"                {debugFlex(tok_return); return tok_return;}
"int"                   {debugFlex(tok_int); return tok_int;}
"double"                {debugFlex(tok_double); return tok_double;}
"void"                  {debugFlex(tok_void); return tok_void;}
[a-zA-Z][a-zA-Z0-9_]*   {debugFlex(tok_identifier); yylval.identifier=strdup(yytext); return tok_identifier;}
[0-9]+(\.[0-9]+)?       {debugFlex(tok_double_literal); yylval.double_literal=atof(yytext); return tok_double_literal;}
\"[^"]*\"               {debugFlex(tok_string_literal); yylval.string_literal=strdup(yytext); return tok_string_literal;}
\/\/.*                  {;}
[ \n\r\t]               {;}
"<="                    {debugFlex(tok_le); return tok_le;}
">="                    {debugFlex(tok_ge); return tok_ge;}
"=="                    {debugFlex(tok_eq); return tok_eq;}
"!="                    {debugFlex(tok_ne); return tok_ne;}
"+"|"-"|"*"|"/"         {debugFlex(yytext[0]); return yytext[0];}
"="|";"|"("|")"|"{"|"}"|"," {debugFlex(yytext[0]); return yytext[0];}
"<"                     {debugFlex('<'); return '<';}
">"                     {debugFlex('>'); return '>';}
"function"              {debugFlex(tok_function); return tok_function;}
.                       {debugFlex(-1); yyerror("illegal lexeme"); exit(EXIT_FAILURE);}

%%
=======
[a-zA-Z][a-zA-Z0-9_]*           {debugFlex(tok_identifier); yylval.identifier=strdup(yytext); return tok_identifier;}
[0-9]+(\.[0-9]+)?          {debugFlex(tok_double_literal); yylval.double_literal=atof(yytext); return tok_double_literal;}
\"[^"]*\"               {debugFlex(tok_string_literal); yylval.string_literal=strdup(yytext); return tok_string_literal;}
\/\/.*                  {;}
[ \n\r\t]               {;}
"+"|"-"|"*"|"\/"|"="|";"|"("|")"|"{"|"}" {debugFlex(yytext[0]); return yytext[0];} 
"=="    { debugFlex(tok_relop); yylval.op=strdup(yytext); return tok_relop; }
"!="    { debugFlex(tok_relop); yylval.op=strdup(yytext); return tok_relop; }
"<"     { debugFlex(tok_relop); yylval.op=strdup(yytext); return tok_relop; }
">"     { debugFlex(tok_relop); yylval.op=strdup(yytext); return tok_relop; }
"<="    { debugFlex(tok_relop); yylval.op=strdup(yytext); return tok_relop; }
">="    { debugFlex(tok_relop); yylval.op=strdup(yytext); return tok_relop; }
"&&"    { debugFlex(tok_and); return tok_and; }
"||"    { debugFlex(tok_or); return tok_or; }
.                   {
                        char errmsg[100];
                        snprintf(errmsg, sizeof(errmsg), "Syntax error at line %d: unexpected character '%s'", yylineno, yytext);
                        yyerror(errmsg);
                        exit(EXIT_FAILURE);
                    }

%%
>>>>>>> master
