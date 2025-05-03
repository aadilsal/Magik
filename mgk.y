%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "IR.h"
    
    extern int yyparse();
    extern int yylex();
    extern FILE *yyin;
    
    #ifdef DEBUGBISON
        #define debugBison(a) (printf("\n%d \n",a))
    #else
        #define debugBison(a)
    #endif
%}

%union {
    char *identifier;
    double double_literal;
    char *string_literal;
    char *op;
    llvm::Value* value; 
}

%token tok_summon
%token tok_colon
%token tok_for
%token tok_cast
%token tok_when
%token tok_otherwise
%token tok_and
%token tok_or
%token <op> tok_relop
%token <identifier> tok_reveal_var
%token <string_literal> tok_reveal_str
%token <identifier> tok_identifier
%token <double_literal> tok_double_literal
%token <string_literal> tok_string_literal

%type <value> expr condition stmt block stmt_list
%type <value> for_loop if_stmt

%left '+' '-'
%left '*' '/'
%left tok_relop
%left tok_and tok_or

%start program

%%

program: stmt_list { debugBison(1); addReturnInstr(); }
       ;

stmt_list: /* empty */
         | stmt_list stmt { debugBison(2); }
         ;

stmt: expr ';' { debugBison(3); }
    | reveal_stmt ';' { debugBison(4); }
    | if_stmt { debugBison(5); }
    | for_loop { debugBison(6); }
    | block { debugBison(7); }
    | decl_stmt {debugBison(28);}
    ;

decl_stmt: tok_summon tok_identifier ';' {
    debugBison(26);
    declareVariable($2);
    free($2);
}
| tok_summon tok_identifier tok_colon expr ';' {
    debugBison(27);
    declareVariable($2);
    setDouble($2,$4);
    free($2);
}

reveal_stmt: 
    tok_reveal_var { debugBison(30); Value* ptr = getFromSymbolTable($1); Value* val = builder.CreateLoad(builder.getDoubleTy(), ptr, "load_reveal"); printDouble(val); free($1); }
    | tok_reveal_str { debugBison(31); printString($1); free($1); }
    ;

block: '{' stmt_list '}' { debugBison(10); }
     ;

if_stmt: 
    tok_cast tok_when '(' condition ')' stmt { debugBison(11); handleIf($4); }
    | tok_cast tok_when '(' condition ')' stmt tok_otherwise stmt { debugBison(12); handleIfElse($4); }
    ;

for_loop: tok_for '(' expr ';' condition ';' expr ')' stmt { debugBison(13); handleForLoop($3, $5, $7); }
        ;

expr: tok_identifier { debugBison(14); Value* ptr = getFromSymbolTable($1); $$ = builder.CreateLoad(builder.getDoubleTy(), ptr, "load_identifier"); free($1); }
    | tok_double_literal { debugBison(15); $$ = createDoubleConstant($1); }
    | expr '+' expr { debugBison(16); $$ = performBinaryOperation($1, $3, '+'); }
    | expr '-' expr { debugBison(17); $$ = performBinaryOperation($1, $3, '-'); }
    | expr '*' expr { debugBison(18); $$ = performBinaryOperation($1, $3, '*'); }
    | expr '/' expr { debugBison(19); $$ = performBinaryOperation($1, $3, '/'); }
    | tok_identifier tok_colon expr { debugBison(20); setDouble($1, $3); free($1); $$ = $3; }
    | '(' expr ')' { debugBison(21); $$ = $2; }
    ;

condition: expr tok_relop expr { debugBison(22); $$ = createComparison($1, $3, $2); }
         | condition tok_and condition { debugBison(23); $$ = builder.CreateAnd($1, $3, "logical_and"); }
         | condition tok_or condition { debugBison(24); $$ = builder.CreateOr($1, $3, "logical_or"); }
         | '(' condition ')' { debugBison(25); $$ = $2; }
         ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char** argv) {
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (fp == NULL) {
            fprintf(stderr, "Error: Could not open file %s\n", argv[1]);
            return EXIT_FAILURE;
        }
        yyin = fp;
    } else {
        yyin = stdin;
    }
    
    initLLVM();
    
    int parserResult = yyparse();
        
    if (parserResult == 0) {
        printLLVMIR();
    } else {
        fprintf(stderr, "Compilation failed due to syntax errors\n");
    }
    
    return parserResult;
}