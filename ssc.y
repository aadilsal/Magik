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

%token <identifier> tok_identifier
%token <double_literal> tok_double_literal
%token <string_literal> tok_string_literal

%type <value> term expression
%type <type> type_specifier

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

parameter_list: /* empty */               { debugBison(21); $$ = nullptr; }
            | parameter                   { debugBison(22); $$ = $1; }
            | parameter_list ',' parameter { debugBison(23); $$ = $3; }
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

compound_statement: '{' statement_list '}' { debugBison(30); }
                  ;

statement_list: /* empty */
              | statement_list statement
              ;

expression_statement: expression ';' { debugBison(31); }
                    | ';'            { debugBison(32); }
                    ;

selection_statement: tok_if '(' expression ')' statement %prec IFX
                   { debugBison(33); createIfStatement($3, $5, nullptr); }
                   | tok_if '(' expression ')' statement tok_else statement
                   { debugBison(34); createIfStatement($3, $5, $7); }
                   ;

iteration_statement: tok_for '(' expression_statement expression_statement expression ')' statement
                   { debugBison(35); createForLoop($3, $4, $5, $7); }
                   ;

return_statement: tok_return ';' { debugBison(36); createReturnStatement(nullptr); }
                | tok_return expression ';' { debugBison(37); createReturnStatement($2); }
                ;

expression: term                          { debugBison(10); $$ = $1; }
          | expression '+' expression     { debugBison(11); $$ = performBinaryOperation($1, $3, '+'); }
          | expression '-' expression     { debugBison(12); $$ = performBinaryOperation($1, $3, '-'); }
          | expression '/' expression     { debugBison(13); $$ = performBinaryOperation($1, $3, '/'); }
          | expression '*' expression     { debugBison(14); $$ = performBinaryOperation($1, $3, '*'); }
          | expression '<' expression     { debugBison(38); $$ = createComparison($1, $3, '<'); }
          | expression '>' expression     { debugBison(39); $$ = createComparison($1, $3, '>'); }
          | expression LE expression      { debugBison(40); $$ = createComparison($1, $3, LE); }
          | expression GE expression      { debugBison(41); $$ = createComparison($1, $3, GE); }
          | expression EQ expression      { debugBison(42); $$ = createComparison($1, $3, EQ); }
          | expression NE expression      { debugBison(43); $$ = createComparison($1, $3, NE); }
          | '(' expression ')'            { debugBison(15); $$ = $2; }
          ;

term: tok_identifier                     { debugBison(7); Value* ptr = getFromSymbolTable($1); $$ = builder.CreateLoad(builder.getDoubleTy(), ptr, "load_identifier"); free($1); }
    | tok_double_literal                 { debugBison(8); $$ = createDoubleConstant($1); }
    | tok_identifier '(' argument_list ')' { debugBison(44); $$ = createFunctionCall($1, $3); free($1); }
    ;

argument_list: /* empty */                { debugBison(45); $$ = nullptr; }
            | expression                  { debugBison(46); $$ = $1; }
            | argument_list ',' expression { debugBison(47); $$ = $3; }
            ;

%%
