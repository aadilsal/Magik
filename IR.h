#include <string>
#include <map>
#include <vector>
#include <stdio.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Value.h>
#include <llvm/Support/raw_ostream.h>

using namespace llvm;

// Type definitions
#define TYPE_INT 0
#define TYPE_DOUBLE 1
#define TYPE_VOID 2

// Function declarations
Value* getFromSymbolTable(const char *id);
void setDouble(const char *id, Value* value);
void printString(const char *str);
void printDouble(Value* value);
Value* performBinaryOperation(Value* lhs, Value* rhs, int op);
Value* createComparison(Value* lhs, Value* rhs, int op);
void yyerror(const char *err);
static void initLLVM();
void printLLVMIR();
void addReturnInstr();
Value* createDoubleConstant(double val);
Value* createFunction(int returnType, const char* name, Value* params, Value* body);
Value* createParameter(int type, const char* name);
void declareVariable(int type, const char* name);
void declareAndAssignVariable(int type, const char* name, Value* value);
void createIfStatement(Value* condition, Value* thenBlock, Value* elseBlock);
void createForLoop(Value* init, Value* condition, Value* increment, Value* body);
void createReturnStatement(Value* value);
Value* createFunctionCall(const char* name, Value* args);

// Global variables
static std::map<std::string, Value *> SymbolTable;
static std::map<std::string, Function *> FunctionTable;

static LLVMContext context;
static Module *module = nullptr;
static IRBuilder<> builder(context);
static Function *currentFunction = nullptr;
static BasicBlock *currentBlock = nullptr;

/**
* Initialize LLVM context and module
*/
static void initLLVM() {
    module = new Module("top", context);
}

// [Previous implementations remain the same...]

/**
* Create a function with given return type, name, parameters and body
*/
Value* createFunction(int returnType, const char* name, Value* params, Value* body) {
    // Determine return type
    Type *retType;
    switch(returnType) {
        case TYPE_INT: retType = builder.getInt32Ty(); break;
        case TYPE_DOUBLE: retType = builder.getDoubleTy(); break;
        case TYPE_VOID: retType = builder.getVoidTy(); break;
        default: retType = builder.getVoidTy();
    }
    
    // Create function type and function
    FunctionType *funcType = FunctionType::get(retType, false);
    Function *func = Function::Create(funcType, Function::ExternalLinkage, name, module);
    
    // Add to function table
    FunctionTable[name] = func;
    
    // Create entry block
    BasicBlock *entry = BasicBlock::Create(context, "entry", func);
    builder.SetInsertPoint(entry);
    
    // Set current function and block
    currentFunction = func;
    currentBlock = entry;
    
    return func;
}

/**
* Create a comparison operation
*/
Value* createComparison(Value* lhs, Value* rhs, int op) {
    switch(op) {
        case '<': return builder.CreateFCmpULT(lhs, rhs, "cmplt");
        case '>': return builder.CreateFCmpUGT(lhs, rhs, "cmpgt");
        case LE: return builder.CreateFCmpULE(lhs, rhs, "cmple");
        case GE: return builder.CreateFCmpUGE(lhs, rhs, "cmpge");
        case EQ: return builder.CreateFCmpUEQ(lhs, rhs, "cmpeq");
        case NE: return builder.CreateFCmpUNE(lhs, rhs, "cmpne");
        default: yyerror("invalid comparison operator"); exit(EXIT_FAILURE);
    }
}

/**
* Create an if-else statement
*/
void createIfStatement(Value* condition, Value* thenBlock, Value* elseBlock) {
    // Create blocks for then and else parts
    BasicBlock *thenBB = BasicBlock::Create(context, "then", currentFunction);
    BasicBlock *elseBB = elseBlock ? BasicBlock::Create(context, "else", currentFunction) : nullptr;
    BasicBlock *mergeBB = BasicBlock::Create(context, "ifcont", currentFunction);
    
    // Create conditional branch
    builder.CreateCondBr(condition, thenBB, elseBB ? elseBB : mergeBB);
    
    // Emit then block
    builder.SetInsertPoint(thenBB);
    // Code for then block would be generated here
    builder.CreateBr(mergeBB);
    
    // Emit else block if exists
    if (elseBB) {
        builder.SetInsertPoint(elseBB);
        // Code for else block would be generated here
        builder.CreateBr(mergeBB);
    }
    
    // Continue with merge block
    builder.SetInsertPoint(mergeBB);
}

/**
* Create a for loop
*/
void createForLoop(Value* init, Value* condition, Value* increment, Value* body) {
    // Create basic blocks
    BasicBlock *preheaderBB = builder.GetInsertBlock();
    BasicBlock *loopBB = BasicBlock::Create(context, "loop", currentFunction);
    BasicBlock *bodyBB = BasicBlock::Create(context, "loopbody", currentFunction);
    BasicBlock *afterBB = BasicBlock::Create(context, "afterloop", currentFunction);
    
    // Emit initialization code
    if (init) {
        // Code for initialization would be generated here
    }
    
    // Branch to loop condition check
    builder.CreateBr(loopBB);
    
    // Emit loop condition check
    builder.SetInsertPoint(loopBB);
    if (condition) {
        // Create conditional branch
        builder.CreateCondBr(condition, bodyBB, afterBB);
    } else {
        // Infinite loop if no condition
        builder.CreateBr(bodyBB);
    }
    
    // Emit loop body
    builder.SetInsertPoint(bodyBB);
    // Code for loop body would be generated here
    if (increment) {
        // Code for increment would be generated here
    }
    builder.CreateBr(loopBB);
    
    // Continue with after loop block
    builder.SetInsertPoint(afterBB);
}

/**
* Create a return statement
*/
void createReturnStatement(Value* value) {
    if (value) {
        builder.CreateRet(value);
    } else {
        if (currentFunction->getReturnType()->isVoidTy()) {
            builder.CreateRetVoid();
        } else {
            yyerror("non-void function must return a value");
            exit(EXIT_FAILURE);
        }
    }
}

/**
* Create a function call
*/
Value* createFunctionCall(const char* name, Value* args) {
    Function *callee = FunctionTable[name];
    if (!callee) {
        yyerror("undefined function");
        exit(EXIT_FAILURE);
    }
    
    // Handle arguments here (simplified)
    return builder.CreateCall(callee, {}, "calltmp");
}
