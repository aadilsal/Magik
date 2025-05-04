%{
    #include <llvm/IR/Value.h>
    #include <llvm/IR/Type.h>
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
%token tok_whirl
%token tok_from
%token tok_to
%token tok_cast
%token tok_when
%token tok_otherwise
%token tok_and
%token tok_or
%token tok_not
%token <op> tok_relop
%token <identifier> tok_reveal_var
%token <string_literal> tok_reveal_str
%token <identifier> tok_identifier
%token <double_literal> tok_double_literal
%token <string_literal> tok_string_literal

%type <value> expr condition stmt block stmt_list
%type <value> whirl_loop if_stmt

%left '+' '-'
%left '*' '/'
%left tok_relop
%left tok_and tok_or

%start program

%%

program: stmt_list { debugBison(1); addReturnInstr(); }
       ;

stmt_list: /* empty */ { $$ = nullptr; };
         | stmt_list stmt { debugBison(2); }
         ;

stmt: expr ';' { debugBison(3); }
    | reveal_stmt ';' { debugBison(4); }
    | if_stmt { debugBison(5); }
    | whirl_loop { debugBison(6); }
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
    tok_cast tok_when '(' condition ')' 
   {
        Function* func = builder.GetInsertBlock()->getParent();
		Value* condVal = $4;
		
		thenBB = BasicBlock::Create(context, "then", func);
        elseBB = BasicBlock::Create(context, "else", func);
		mergeBB = BasicBlock::Create(context, "ifcont", func);

		builder.CreateCondBr(condVal, thenBB, elseBB);

		builder.SetInsertPoint(thenBB);
	}
	'{' stmt_list '}' tok_otherwise
	{
		builder.CreateBr(mergeBB);
		builder.SetInsertPoint(elseBB);
	} 
	'{' stmt_list '}'
    {
	    builder.CreateBr(mergeBB);
        builder.SetInsertPoint(mergeBB);
    }
  ;


whirl_loop:
    tok_whirl tok_identifier tok_from tok_double_literal tok_to tok_double_literal 
    {
        debugBison(13);

        Function* function = builder.GetInsertBlock()->getParent();

        // Create and insert blocks directly into the function
        loopCondBB = BasicBlock::Create(context, "loop.cond", function);
        loopBodyBB = BasicBlock::Create(context, "loop.body", function);
        loopIncBB  = BasicBlock::Create(context, "loop.inc", function);
        loopEndBB  = BasicBlock::Create(context, "loop.end", function);

        // 1. Initialize loop variable
        setDouble($2, createDoubleConstant($4));
        //Value* varPtr = getFromSymbolTable($2);

        // Jump to condition check
        builder.CreateBr(loopCondBB);

        // 2. Condition check
        builder.SetInsertPoint(loopCondBB);
        Value* cPtr = getFromSymbolTable($2);
        Value* cVal = builder.CreateLoad(Type::getDoubleTy(context), cPtr, $2);
        Value* limit = createDoubleConstant($6);
        Value* cond = builder.CreateFCmpULT(cVal, limit, "cmptmp");
        builder.CreateCondBr(cond, loopBodyBB, loopEndBB);

        // 3. Loop body
        builder.SetInsertPoint(loopBodyBB);
        
    } stmt 
    {

        builder.CreateBr(loopIncBB);

        // 4. Increment
        builder.SetInsertPoint(loopIncBB);
        Value* one = createDoubleConstant(1.0);
        Value* ptr = getFromSymbolTable($2);
        Value* val = builder.CreateLoad(Type::getDoubleTy(context), ptr, $2);
        Value* inc = builder.CreateFAdd(val, one, "incr");
        builder.CreateStore(inc, ptr);
        builder.CreateBr(loopCondBB);

        // 5. End of loop
        builder.SetInsertPoint(loopEndBB);
    }
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
         | tok_not condition {debugBison(26); $$=createLogicalNot($2);}
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