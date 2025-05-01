%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "IR.h"
    
    extern int yyparse();
    extern int yylex();
    extern FILE *yyin;
    extern char* yytext;
    
    void yyerror(const char *s);
    
    #ifdef DEBUGBISON
        #define debugBison(a) (printf("\nRule %d\n",a))
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

%token tok_reveal tok_summon tok_cast tok_when tok_whirl tok_else
%token <identifier> tok_var_output  // Now has type identifier
%token tok_from tok_dotdot
%token <op> tok_relop
%token <identifier> tok_identifier
%token <double_literal> tok_double_literal
%token <string_literal> tok_string_literal 

%type <value> expr condition stmt block
%type <value> declaration for_loop if_stmt

%left '+' '-'
%left '*' '/'
%left tok_relop
%left tok_and tok_or

%start program

%%

program: stmt_list { debugBison(1); addReturnInstr(); }
       ;

stmt_list: 
    | stmt_list stmt { debugBison(2); }
    ;

stmt: declaration ';' { debugBison(3); }
    | expr ';' { debugBison(4); }
    | print_stmt ';' { debugBison(5); }
    | if_stmt { debugBison(6); }
    | for_loop { debugBison(7); }
    | block { debugBison(8); }
    ;

declaration: 
    tok_summon tok_identifier { debugBison(9); 
        setDouble($2, createDoubleConstant(0.0)); 
        free($2); }
    | tok_summon tok_identifier ':' expr { debugBison(10); 
        setDouble($2, $4); 
        free($2); }
    ;

print_stmt: 
    tok_reveal tok_var_output { debugBison(11); 
        printDouble(getFromSymbolTable($2)); 
        free($2); }
    | tok_reveal tok_string_literal { debugBison(12); 
        printString($2); 
        free($2); }
    ;

block: '{' stmt_list '}' { debugBison(13); }
     ;

if_stmt: 
    tok_cast tok_when '(' condition ')' block { debugBison(14); 
        handleIf($4); }
    | tok_cast tok_when '(' condition ')' block tok_else block { debugBison(15); 
        handleIfElse($4); }
    ;

for_loop: 
    tok_whirl tok_identifier tok_from expr tok_dotdot expr block { debugBison(16); 
        Value* loopVar = getFromSymbolTable($2);  // Get Value* from symbol table
        handleForLoop($4, $6, loopVar); 
        free($2); }
    ;

expr: 
    tok_identifier { debugBison(17); 
        $$ = builder.CreateLoad(builder.getDoubleTy(), getFromSymbolTable($1), "loadtmp"); }
    | tok_double_literal { debugBison(18); 
        $$ = createDoubleConstant($1); }
    | expr '+' expr { debugBison(19); 
        $$ = performBinaryOperation($1, $3, '+'); }
    | expr '-' expr { debugBison(20); 
        $$ = performBinaryOperation($1, $3, '-'); }
    | expr '*' expr { debugBison(21); 
        $$ = performBinaryOperation($1, $3, '*'); }
    | expr '/' expr { debugBison(22); 
        $$ = performBinaryOperation($1, $3, '/'); }
    | tok_identifier '=' expr { debugBison(23); 
        setDouble($1, $3); 
        $$ = $3; }
    | '(' expr ')' { debugBison(24); 
        $$ = $2; }
    ;

condition: 
    expr tok_relop expr { debugBison(25); 
        $$ = createComparison($1, $3, $2); }
    | condition tok_and condition { debugBison(26); 
        $$ = builder.CreateAnd($1, $3, "logical_and"); }
    | condition tok_or condition { debugBison(27); 
        $$ = builder.CreateOr($1, $3, "logical_or"); }
    | '(' condition ')' { debugBison(28); 
        $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main(int argc, char** argv) {
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (!fp) {
            fprintf(stderr, "Error opening %s\n", argv[1]);
            exit(1);
        }
        yyin = fp;
    }
    
    initLLVM();
    yyparse();
    printLLVMIR();
    
    return 0;
}