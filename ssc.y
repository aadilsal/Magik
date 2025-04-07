%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "IR.h"
    
    extern int yyparse();
    extern int yylex();
    extern FILE *yyin;
    
    //#define DEBUGBISON
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
    llvm::Value* value; 
    int type;
    std::vector<llvm::Value*>* param_list;
}

%token tok_printd
%token tok_prints
%token tok_if
%token tok_else
%token tok_for
%token tok_return
%token tok_int
%token tok_double
%token tok_void
%token IFX
%token tok_lt    // <
%token tok_gt    // >
%token tok_le    // <=
%token tok_ge    // >=
%token tok_eq    // ==
%token tok_ne    // !=

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
          | expression tok_lt expression  { debugBison(38); $$ = createComparison($1, $3, tok_lt); }
          | expression tok_gt expression  { debugBison(39); $$ = createComparison($1, $3, tok_gt); }
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
