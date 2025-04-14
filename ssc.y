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

%token tok_printd
%token tok_prints
%token tok_if
%token tok_else
%token <op> tok_relop
%token <identifier> tok_identifier
%token <double_literal> tok_double_literal
%token <string_literal> tok_string_literal
%token tok_and
%token tok_or


%type <value> term expression condition
%type <value> statement

%left '+' '-' 
%left '*' '/'
%left '(' ')'
%left tok_relop

%start root

%%

root: /* empty */                { debugBison(1); addReturnInstr(); }
    | statement root             { debugBison(2); }
    | error ';'                  { yyerrok; }  /* Error recovery */
    ;

statement:
    prints                       { debugBison(3); }
    | printd                     { debugBison(4); }
    | assignment                 { debugBison(5); }
    | if_else                    { debugBison(6); }
    ;

prints: tok_prints '(' tok_string_literal ')' ';'   { debugBison(7); printString($3); } 
    ;

printd: tok_printd '(' term ')' ';'        { debugBison(8); printDouble($3); }
    ;

term: tok_identifier               { debugBison(9); Value* ptr = getFromSymbolTable($1); $$ = builder.CreateLoad(builder.getDoubleTy(), ptr, "load_identifier"); free($1); }
    | tok_double_literal           { debugBison(10); $$ = createDoubleConstant($1); }
    ;

assignment: tok_identifier '=' expression ';'   { debugBison(11); setDouble($1, $3); free($1); }
    ;

expression: term                    { debugBison(12); $$ = $1; }
    | expression '+' expression     { debugBison(13); $$ = performBinaryOperation($1, $3, '+'); }
    | expression '-' expression     { debugBison(14); $$ = performBinaryOperation($1, $3, '-'); }
    | expression '/' expression     { debugBison(15); $$ = performBinaryOperation($1, $3, '/'); }
    | expression '*' expression     { debugBison(16); $$ = performBinaryOperation($1, $3, '*'); }
    | '(' expression ')'            { debugBison(17); $$ = $2; }
    ;

condition: 
    expression tok_relop expression 
    { debugBison(18); $$ = createComparison($1, $3, $2); }
    | condition tok_and condition 
    { debugBison(22); $$ = builder.CreateAnd($1, $3, "logical_and"); }
    | condition tok_or condition 
    { debugBison(23); $$ = builder.CreateOr($1, $3, "logical_or"); }
    | '(' condition ')' 
    { debugBison(24); $$ = $2; }
    ;
	
if_else: 
    tok_if '(' condition ')' '{' root '}' 
    { debugBison(19); handleIf($3); }
    | tok_if '(' condition ')' '{' root '}' tok_else '{' root '}' 
    { debugBison(20); handleIfElse($3); }
    | tok_if '(' condition ')' '{' root '}' tok_else if_else 
    { debugBison(21); handleIfElseIf($3); }
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