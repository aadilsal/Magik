%{
    #include <llvm/IR/Value.h>
    #include "ssc.tab.h"
    #include <stdlib.h>
    #include <stdio.h>
    #include <string>
    extern void yyerror(const char *msg);
    
    #ifdef DEBUGSSC
        #define debugFlex(a) (printf("\n%d: Token=<ID, lexeme>=<%d, %s>\n", yylineno, a, yytext))
    #else
        #define debugFlex(a)
    #endif
%}

%option yylineno 
%option noyywrap

%%

"reveal"                { debugFlex(tok_reveal); return tok_reveal; }  // Reveal keyword
"summon"                { debugFlex(tok_summon); return tok_summon; }  // Summon keyword
"cast"                  { debugFlex(tok_cast); return tok_cast; }  // Cast for if-else condition
"when"                  { debugFlex(tok_when); return tok_when; }  // For conditional expression

\*\*[^*]*\*\*   { 
    char* raw = strdup(yytext + 2);  // Skip **
    raw[strlen(raw) - 2] = '\0';      // Remove ending **
    debugFlex(tok_string_literal);
    yylval.string_literal = raw;
    return tok_string_literal;
}

\*([a-zA-Z_][a-zA-Z0-9_]*)\*   { 
    char* raw = strdup(yytext + 1);  // Skip *
    raw[strlen(raw) - 1] = '\0';      // Remove ending *
    debugFlex(tok_var_output);
    yylval.identifier = raw;
    return tok_var_output;
}

[a-zA-Z][a-zA-Z0-9_]*   { debugFlex(tok_identifier); yylval.identifier=strdup(yytext); return tok_identifier; }
[0-9]+(\.[0-9]+)?      { debugFlex(tok_double_literal); yylval.double_literal=atof(yytext); return tok_double_literal; }

"=="|"!="|"<"|">"|"<="|">=" { debugFlex(tok_relop); yylval.op=strdup(yytext); return tok_relop; }
"&&"                   { debugFlex(tok_and); return tok_and; }
"||"                   { debugFlex(tok_or); return tok_or; }

"\bwhirl\b"                { debugFlex(tok_whirl); return tok_whirl; }  // whirl for loop


"+"|"-"|"*"|"/"|"="|";"|"("|")"|"{"|"}" { debugFlex(yytext[0]); return yytext[0]; }

[ \t\n]                { /* ignore whitespace */ }
@.*                    { /* ignore comments starting with @ */ }

.                      { char errmsg[100]; snprintf(errmsg, sizeof(errmsg), "Syntax error at line %d: unexpected character '%s'", yylineno, yytext); yyerror(errmsg); }

%%

