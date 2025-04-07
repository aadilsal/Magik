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
#include "ssc.tab.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/DerivedTypes.h"

extern FILE *yyin;  // Flex's input file pointer
extern llvm::Function* mainFunction; 

using namespace llvm;

// Type definitions
#define TYPE_INT 0
#define TYPE_DOUBLE 1
#define TYPE_VOID 2


// Function declarations
void printfLLVM(const char* format, llvm::Value* value);
void printfLLVM(const char* format, const char* str);
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
Value* createFunction(int returnType, const char* name, std::vector<llvm::Value*>* params, Value* body);
Value* createParameter(int type, const char* name);
void declareVariable(int type, const char* name);
void declareAndAssignVariable(int type, const char* name, Value* value);
void createIfStatement(Value* condition, Value* thenBlock, Value* elseBlock);
void createForLoop(Value* init, Value* condition, Value* increment, Value* body);
void createReturnStatement(Value* value);
Value* createFunctionCall(const char* name, std::vector<llvm::Value*>* args);


// Global variables
static std::map<std::string, Value *> SymbolTable;
static std::map<std::string, Function *> FunctionTable;

static LLVMContext context;
static Module *module = nullptr;
static IRBuilder<> builder(context);
static Function *currentFunction = nullptr;
static BasicBlock *currentBlock = nullptr;


static void initLLVM() {
    module = new Module("top", context);
    FunctionType *mainTy = FunctionType::get(builder.getInt32Ty(), false);
    mainFunction = Function::Create(mainTy, Function::ExternalLinkage, "main", module);
    BasicBlock *entry = BasicBlock::Create(context, "entry", mainFunction);
    builder.SetInsertPoint(entry);
}

void printfLLVM(const char* format, llvm::Value* value) {
    std::vector<llvm::Type*> printfArgs;
    printfArgs.push_back(llvm::PointerType::get(llvm::Type::getInt8Ty(context), 0));
    printfArgs.push_back(llvm::Type::getDoubleTy(context));
    llvm::FunctionType* printfType = llvm::FunctionType::get(
        llvm::Type::getInt32Ty(context), printfArgs, true);
    
    llvm::Function* printfFunc = llvm::Function::Create(
        printfType, llvm::Function::ExternalLinkage, "printf", module);
    
    std::vector<llvm::Value*> args;
    args.push_back(builder.CreateGlobalStringPtr(format));
    args.push_back(value);
    builder.CreateCall(printfFunc, args);
}

void printfLLVM(const char* format, const char* str) {
    std::vector<llvm::Type*> printfArgs;
    printfArgs.push_back(llvm::PointerType::get(llvm::Type::getInt8Ty(context), 0));
    printfArgs.push_back(llvm::PointerType::get(llvm::Type::getInt8Ty(context), 0));
    llvm::FunctionType* printfType = llvm::FunctionType::get(
        llvm::Type::getInt32Ty(context), printfArgs, true);
    
    llvm::Function* printfFunc = llvm::Function::Create(
        printfType, llvm::Function::ExternalLinkage, "printf", module);
    
    std::vector<llvm::Value*> args;
    args.push_back(builder.CreateGlobalStringPtr(format));
    args.push_back(builder.CreateGlobalStringPtr(str));
    builder.CreateCall(printfFunc, args);
}

void addReturnInstr() {
    builder.CreateRet(ConstantInt::get(context, APInt(32, 0)));
}

void printString(const char *str) {
    Value *strValue = builder.CreateGlobalStringPtr(str);
    printfLLVM("%s\n", strValue);
}

void printDouble(Value *value) {
    printfLLVM("%f\n", value);
}
/*
void printfLLVM(const char *format, Value *inputValue) {
    Function *printfFunc = module->getFunction("printf");
    if(!printfFunc) {
        FunctionType *printfTy = FunctionType::get(builder.getInt32Ty(), 
            PointerType::get(builder.getInt8Ty(), 0), true);
        printfFunc = Function::Create(printfTy, Function::ExternalLinkage, "printf", module);
    }
    Value *formatVal = builder.CreateGlobalStringPtr(format);
    builder.CreateCall(printfFunc, {formatVal, inputValue}, "printfCall");
}
*/
Value* createFunction(int returnType, const char* name, std::vector<llvm::Value*>* params, Value* body) {
    // Determine return type
    Type *retType;
    switch(returnType) {
        case TYPE_INT: retType = builder.getInt32Ty(); break;
        case TYPE_DOUBLE: retType = builder.getDoubleTy(); break;
        case TYPE_VOID: retType = builder.getVoidTy(); break;
        default: retType = builder.getVoidTy();
    }
    
    // Create parameter types vector
    std::vector<Type*> paramTypes;
    if (params) {
        for (auto param : *params) {
            paramTypes.push_back(param->getType());
        }
    }
    
    // Create function type
    FunctionType *funcType = FunctionType::get(retType, paramTypes, false);
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

Value* createFunctionCall(const char* name, std::vector<llvm::Value*>* args) {
    Function *callee = FunctionTable[name];
    if (!callee) {
        yyerror("undefined function");
        exit(EXIT_FAILURE);
    }
    
    if (args) {
        return builder.CreateCall(callee, *args, "calltmp");
    } else {
        return builder.CreateCall(callee, {}, "calltmp");
    }
}



Value* createComparison(Value* lhs, Value* rhs, int op) {
    switch(op) {
        case '<': return builder.CreateFCmpULT(lhs, rhs, "cmplt");
        case '>': return builder.CreateFCmpUGT(lhs, rhs, "cmpgt");
        case tok_le: return builder.CreateFCmpULE(lhs, rhs, "cmple");
        case tok_ge: return builder.CreateFCmpUGE(lhs, rhs, "cmpge");
        case tok_eq: return builder.CreateFCmpUEQ(lhs, rhs, "cmpeq");
        case tok_ne: return builder.CreateFCmpUNE(lhs, rhs, "cmpne");
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

// Error handling
void yyerror(const char *err) {
    fprintf(stderr, "\n%s\n", err);
}

// Variable and symbol table operations
Value* getFromSymbolTable(const char *id) {
    std::string name(id);
    if(SymbolTable.find(name) != SymbolTable.end()) {
        return SymbolTable[name];
    } else {
        Value* defaultValue = builder.CreateAlloca(builder.getDoubleTy(), nullptr, name);
        SymbolTable[name] = defaultValue;
        return defaultValue;
    }
}

void setDouble(const char *id, Value* value) {
    Value *ptr = getFromSymbolTable(id);
    builder.CreateStore(value, ptr);
}

void declareVariable(int type, const char* name) {
    Type* varType = type == TYPE_INT ? builder.getInt32Ty() : builder.getDoubleTy();
    Value* var = builder.CreateAlloca(varType, nullptr, name);
    SymbolTable[name] = var;
}

void declareAndAssignVariable(int type, const char* name, Value* value) {
    declareVariable(type, name);
    setDouble(name, value);
}

// Parameter handling
Value* createParameter(int type, const char* name) {
    Type* paramType = type == TYPE_INT ? builder.getInt32Ty() : builder.getDoubleTy();
    return builder.CreateAlloca(paramType, nullptr, name);
}

// Binary operations
Value* performBinaryOperation(Value* lhs, Value* rhs, int op) {
    switch (op) {
        case '+': return builder.CreateFAdd(lhs, rhs, "fadd");
        case '-': return builder.CreateFSub(lhs, rhs, "fsub");
        case '*': return builder.CreateFMul(lhs, rhs, "fmul");
        case '/': return builder.CreateFDiv(lhs, rhs, "fdiv");
        default: yyerror("illegal binary operation"); exit(EXIT_FAILURE);
    }
}

// Constant creation
Value* createDoubleConstant(double val) {
    return ConstantFP::get(context, APFloat(val));
}

int main(int argc, char** argv) {
    extern FILE *yyin;  // Declaration of Flex's input file pointer
    
    // Initialize LLVM
    initLLVM();
    
    // Set input source
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            fprintf(stderr, "Could not open input file: %s\n", argv[1]);
            return EXIT_FAILURE;
        }
    } else {
        yyin = stdin;
    }
    
    // Run parser
    int parserResult = yyparse();
    
    // Print generated IR
    printLLVMIR();
    
    // Clean up
    if (yyin != stdin) {
        fclose(yyin);
    }
    
    return parserResult ? EXIT_FAILURE : EXIT_SUCCESS;
}
