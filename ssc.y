%{
    #include <stdio.h>
    #include <stdlib.h>
<<<<<<< HEAD
    #include "IR.h"
    
    
    extern llvm::Function* mainFunction; 
    extern void printfLLVM(const char* format, llvm::Value* value);
    extern void printfLLVM(const char* format, const char* str);
    
    
=======
    #include <string.h>
    #include "IR.h"
    
>>>>>>> master
    extern int yyparse();
    extern int yylex();
    extern FILE *yyin;
    
<<<<<<< HEAD
    //#define DEBUGBISON
=======
>>>>>>> master
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
<<<<<<< HEAD
    llvm::Value* value; 
    int type;
    std::vector<llvm::Value*>* param_list;
=======
    char *op;
    llvm::Value* value; 
>>>>>>> master
}

%token tok_printd
%token tok_prints
%token tok_if
%token tok_else
<<<<<<< HEAD
%token tok_for
%token tok_return
%token tok_int
%token tok_double
%token tok_void
%token IFX

%token tok_le    // <=
%token tok_ge    // >=
%token tok_eq    // ==
%token tok_ne    // !=
%token tok_function

%token <identifier> tok_identifier
%token <double_literal> tok_double_literal
%token <string_literal> tok_string_literal

%type <value> term expression statement expression_statement return_statement
%type <type> type_specifier
%type <param_list> parameter_list argument_list
%type <value> parameter function compound_statement selection_statement iteration_statement
%precedence IFX

%start program

%%

program:    /* empty */
            | program function
            | program declaration
            | program statement
            ;
function:   type_specifier tok_identifier '(' parameter_list ')' compound_statement
            { debugBison(20); $$ = createFunction($1, $2, $4, $6); free($2); }
            | tok_identifier '(' parameter_list ')' compound_statement
            ;

parameter_list: /* empty */               { debugBison(21); $$ = new std::vector<llvm::Value*>(); }
            | parameter                   { debugBison(22); $$ = new std::vector<llvm::Value*>(); $$->push_back($1); }
            | parameter_list ',' parameter { debugBison(23); $1->push_back($3); $$ = $1; }
            ;

parameter:   type_specifier tok_identifier { debugBison(24); $$ = createParameter($1, $2); free($2); }
            ;

declaration: type_specifier tok_identifier ';' 
            { debugBison(25); declareVariable($1, $2); free($2); }
            | type_specifier tok_identifier '=' expression ';'
            { debugBison(26); declareAndAssignVariable($1, $2, $4); free($2); }
            ;

type_specifier: tok_int      { debugBison(27); $$ = TYPE_INT; }
              | tok_double   { debugBison(28); $$ = TYPE_DOUBLE; }
              | tok_void     { debugBison(29); $$ = TYPE_VOID; }
              ;
statement:   compound_statement
            | expression_statement
            | selection_statement
            | iteration_statement
            | return_statement
            | tok_prints '(' tok_string_literal ')' ';' { printString($3); free($3); }
            | tok_printd '(' expression ')' ';' { printDouble($3); }
            ;

compound_statement: '{' statement_list '}' { debugBison(30); $$ = nullptr; }
                  ;

statement_list: /* empty */
              | statement_list statement
              ;

expression_statement: expression ';' { debugBison(31); $$ = $1; }
                    | ';'            { debugBison(32); $$ = nullptr; }
                    ;

selection_statement: tok_if '(' expression ')' statement %prec IFX
                   { debugBison(33); createIfStatement($3, $5, nullptr); $$ = $3; }
                   | tok_if '(' expression ')' statement tok_else statement
                   { debugBison(34); createIfStatement($3, $5, $7); $$ = $3; }
                   ;

iteration_statement: tok_for '(' expression_statement expression_statement expression ')' statement
                   { debugBison(35); createForLoop($3, $4, $5, $7); $$ = $5; }
                   ;

return_statement: tok_return ';' { debugBison(36); createReturnStatement(nullptr); $$ = nullptr; }
                | tok_return expression ';' { debugBison(37); createReturnStatement($2); $$ = $2; }
                ;

expression: term                          { debugBison(10); $$ = $1; }
          | expression '+' expression     { debugBison(11); $$ = performBinaryOperation($1, $3, '+'); }
          | expression '-' expression     { debugBison(12); $$ = performBinaryOperation($1, $3, '-'); }
          | expression '/' expression     { debugBison(13); $$ = performBinaryOperation($1, $3, '/'); }
          | expression '*' expression     { debugBison(14); $$ = performBinaryOperation($1, $3, '*'); }
          | expression '<' expression     { debugBison(38); $$ = createComparison($1, $3, '<'); }
          | expression '>' expression     { debugBison(39); $$ = createComparison($1, $3, '>'); }
          | expression tok_le expression  { debugBison(40); $$ = createComparison($1, $3, tok_le); }
          | expression tok_ge expression  { debugBison(41); $$ = createComparison($1, $3, tok_ge); }
          | expression tok_eq expression  { debugBison(42); $$ = createComparison($1, $3, tok_eq); }
          | expression tok_ne expression  { debugBison(43); $$ = createComparison($1, $3, tok_ne); }
          | '(' expression ')'            { debugBison(15); $$ = $2; }
          ;

term: tok_identifier                     { debugBison(7); Value* ptr = getFromSymbolTable($1); $$ = builder.CreateLoad(builder.getDoubleTy(), ptr, "load_identifier"); free($1); }
    | tok_double_literal                 { debugBison(8); $$ = createDoubleConstant($1); }
    | tok_identifier '(' argument_list ')' { debugBison(44); $$ = createFunctionCall($1, $3); free($1); }
    ;

argument_list: /* empty */                { debugBison(45); $$ = new std::vector<llvm::Value*>(); }
            | expression                  { debugBison(46); $$ = new std::vector<llvm::Value*>(); $$->push_back($1); }
            | argument_list ',' expression { debugBison(47); $1->push_back($3); $$ = $1; }
            ;

%%
=======
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
>>>>>>> master
