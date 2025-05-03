%{
    #include <llvm/IR/Value.h>
    #include "mgk.tab.h"
    #include <stdlib.h>
    #include <stdio.h>
    #include <string>
    extern void yyerror(const char *msg);
    
    #ifdef DEBUGSSC
        #define debugFlex(a) (printf("\n%d: Token=<ID, lexeme>=<%d, %s>\n",yylineno, a, yytext))
    #else
        #define debugFlex(a)
    #endif
%}

%option yylineno 
%option noyywrap

%%

"summon"                { debugFlex(tok_summon); return tok_summon; }
"cast"                  { debugFlex(tok_cast); return tok_cast;}
"when"                  {debugFlex(tok_when); return tok_when;}
"otherwise"             {debugFlex(tok_otherwise); return tok_otherwise;}
"whirl"                 { debugFlex(tok_whirl); return tok_whirl; }
"from"                  { debugFlex(tok_from); return tok_from; }
"\.\.\."                { debugFlex(tok_to); return tok_to; }
"reveal*"([^*]+)"*"     { debugFlex(tok_reveal_var); yylval.identifier=strndup(yytext+7,strlen(yytext)-8); return tok_reveal_var;}
"reveal**"([^*]+)"**"     { 
    debugFlex(tok_reveal_str); 
    yylval.string_literal = strndup(yytext+8, strlen(yytext)-10);
    return tok_reveal_str; 
}
":"                     {debugFlex(tok_colon); return tok_colon;}
[a-zA-Z][a-zA-Z0-9_]*   { debugFlex(tok_identifier); yylval.identifier=strdup(yytext); return tok_identifier; }
[0-9]+(\.[0-9]+)?      { debugFlex(tok_double_literal); yylval.double_literal=atof(yytext); return tok_double_literal; }
\"[^"]*\"              { debugFlex(tok_string_literal); yylval.string_literal=strdup(yytext); return tok_string_literal; }
"=="|"!="|"<"|">"|"<="|">=" { debugFlex(tok_relop); yylval.op=strdup(yytext); return tok_relop; }
"&&"                   { debugFlex(tok_and); return tok_and; }
"||"                   { debugFlex(tok_or); return tok_or; }
"+"|"-"|"*"|"/"|";"|"("|")"|"{"|"}" { debugFlex(yytext[0]); return yytext[0]; }
[ \t\n]                { /* ignore whitespace */ }
"@"[^\n]*              { /* Ignore @ comments */ }
.                      { char errmsg[100]; snprintf(errmsg, sizeof(errmsg), "Syntax error at line %d: unexpected character '%s'", yylineno, yytext); yyerror(errmsg); }

%%