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

%token tok_for
%token tok_if
%token tok_else
%token tok_printd
%token tok_prints
%token tok_and
%token tok_or
%token <op> tok_relop
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
    | print_stmt ';' { debugBison(4); }
    | if_stmt { debugBison(5); }
    | for_loop { debugBison(6); }
    | block { debugBison(7); }
    ;

print_stmt: tok_prints '(' tok_string_literal ')' { debugBison(8); printString($3); }
          | tok_printd '(' expr ')' { debugBison(9); printDouble($3); }
          ;

block: '{' stmt_list '}' { debugBison(10); }
     ;

if_stmt: tok_if '(' condition ')' stmt { debugBison(11); handleIf($3); }
       | tok_if '(' condition ')' stmt tok_else stmt { debugBison(12); handleIfElse($3); }
       ;

for_loop: tok_for '(' expr ';' condition ';' expr ')' stmt { debugBison(13); handleForLoop($3, $5, $7); }
        ;

expr: tok_identifier { debugBison(14); Value* ptr = getFromSymbolTable($1); $$ = builder.CreateLoad(builder.getDoubleTy(), ptr, "load_identifier"); free($1); }
    | tok_double_literal { debugBison(15); $$ = createDoubleConstant($1); }
    | expr '+' expr { debugBison(16); $$ = performBinaryOperation($1, $3, '+'); }
    | expr '-' expr { debugBison(17); $$ = performBinaryOperation($1, $3, '-'); }
    | expr '*' expr { debugBison(18); $$ = performBinaryOperation($1, $3, '*'); }
    | expr '/' expr { debugBison(19); $$ = performBinaryOperation($1, $3, '/'); }
    | tok_identifier '=' expr { debugBison(20); setDouble($1, $3); free($1); $$ = $3; }
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