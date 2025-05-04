#include <string>
#include <map>
#include <stdio.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Value.h>
#include <llvm/Support/raw_ostream.h>

using namespace llvm;

Value* getFromSymbolTable(const char *id);
void setDouble(const char *id, Value* value);
void printString(const char *str);
void printDouble(Value* value);
Value* performBinaryOperation(Value* lhs, Value* rhs, int op);
Value* createComparison(Value* lhs, Value* rhs, const char *op);
void handleIf(Value* cond);
void handleIfElse(Value* cond);
void handleIfElseIf(Value* cond, std::pair<Value*, Value*>* elseIfs, Value* elseBlock);
void handleForLoop(Value* init, Value* cond, Value* update);
void yyerror(const char *err);
static void initLLVM();
void printLLVMIR();
void addReturnInstr();
Value* createDoubleConstant(double val);
void declareVariable(const char *id);

static std::map<std::string, Value *> SymbolTable;

static LLVMContext context;
static Module *module = nullptr;
static IRBuilder<> builder(context);
static Function *mainFunction = nullptr;

BasicBlock* loopCondBB ;
BasicBlock* loopBodyBB ;
BasicBlock* loopIncBB ;
BasicBlock* loopEndBB;
BasicBlock *thenBB = nullptr;
BasicBlock *elseBB = nullptr;
BasicBlock *mergeBB = nullptr;

static void initLLVM() {
	module = new Module("top", context);
	FunctionType *mainTy = FunctionType::get(builder.getInt32Ty(), false);
	mainFunction = Function::Create(mainTy, Function::ExternalLinkage, "main", module);
	BasicBlock *entry = BasicBlock::Create(context, "entry", mainFunction);
	builder.SetInsertPoint(entry);
}


void declareVariable(const char *id){
    std::string name(id);
    if (SymbolTable.find(name) != SymbolTable.end()) {
        yyerror("Variable redeclared");
        exit(EXIT_FAILURE);
    }
    Value* ptr = builder.CreateAlloca(builder.getDoubleTy(), nullptr, name);
    SymbolTable[name] = ptr;
    builder.CreateStore(ConstantFP::get(context, APFloat(0.0)), ptr);
}
void addReturnInstr() {
	builder.CreateRet(ConstantInt::get(context, APInt(32, 0)));
}

Value* createDoubleConstant(double val) {
	return ConstantFP::get(context, APFloat(val));
}

Value* createComparison(Value* lhs, Value* rhs, const char *op) {
    if (strcmp(op, "==") == 0) {
        return builder.CreateFCmpOEQ(lhs, rhs, "fcmp_eq");
    } else if (strcmp(op, "!=") == 0) {
        return builder.CreateFCmpONE(lhs, rhs, "fcmp_ne");
    } else if (strcmp(op, "<") == 0) {
        return builder.CreateFCmpOLT(lhs, rhs, "fcmp_lt");
    } else if (strcmp(op, "<=") == 0) {
        return builder.CreateFCmpOLE(lhs, rhs, "fcmp_le");
    } else if (strcmp(op, ">") == 0) {
        return builder.CreateFCmpOGT(lhs, rhs, "fcmp_gt");
    } else if (strcmp(op, ">=") == 0) {
        return builder.CreateFCmpOGE(lhs, rhs, "fcmp_ge");
    } else {
        yyerror("Unknown comparison operator");
        exit(EXIT_FAILURE);
    }
}

void handleIf(Value* cond) {
    BasicBlock* thenBB = BasicBlock::Create(context, "if.then", mainFunction);
    BasicBlock* mergeBB = BasicBlock::Create(context, "if.merge", mainFunction);
    
    builder.CreateCondBr(cond, thenBB, mergeBB);
    
    builder.SetInsertPoint(thenBB);
   
    builder.CreateBr(mergeBB);
    
    builder.SetInsertPoint(mergeBB);
}


void handleIfElse(Value* cond) {
    BasicBlock* thenBB = BasicBlock::Create(context, "if.then", mainFunction);
    BasicBlock* elseBB = BasicBlock::Create(context, "if.else", mainFunction);
    BasicBlock* mergeBB = BasicBlock::Create(context, "if.merge", mainFunction);
    
    builder.CreateCondBr(cond, thenBB, elseBB);
    
    builder.SetInsertPoint(thenBB);
    // Then block code
    builder.CreateBr(mergeBB);
    
    builder.SetInsertPoint(elseBB);
    // Else block code
    builder.CreateBr(mergeBB);
    
    builder.SetInsertPoint(mergeBB);
}

// void handleIfElseIf(Value* cond, std::vector<std::pair<Value*, Value*>>* elseIfs, Value* elseBlock) {
//     BasicBlock* thenBB = BasicBlock::Create(context, "if.then", mainFunction);
//     BasicBlock* currentElseBB = BasicBlock::Create(context, "if.else", mainFunction);
//     BasicBlock* mergeBB = BasicBlock::Create(context, "if.merge", mainFunction);
    
//     builder.CreateCondBr(cond, thenBB, currentElseBB);
    
//     // Handle 'then' block
//     builder.SetInsertPoint(thenBB);
//     // ... Generate code for 'then' ...
//     builder.CreateBr(mergeBB);
    
//     // Handle else-if clauses
//     builder.SetInsertPoint(currentElseBB);
//     while (elseIfs != nullptr) {
//         BasicBlock* elseIfBB = BasicBlock::Create(context, "if.elseif", mainFunction);
//         builder.CreateCondBr(elseIfs->first, elseIfBB, currentElseBB);
        
//         builder.SetInsertPoint(elseIfBB);
//         // ... Generate code for else-if ...
//         builder.CreateBr(mergeBB);
        
//         currentElseBB = elseIfBB;
//         elseIfs = elseIfs->second; // Assume linked list structure
//     }
    
//     // Handle 'otherwise' block
//     if (elseBlock != nullptr) {
//         BasicBlock* otherwiseBB = BasicBlock::Create(context, "if.otherwise", mainFunction);
//         builder.CreateBr(otherwiseBB);
//         builder.SetInsertPoint(otherwiseBB);
//         // ... Generate code for 'otherwise' ...
//         builder.CreateBr(mergeBB);
//     } else {
//         builder.CreateBr(mergeBB);
//     }
    
//     builder.SetInsertPoint(mergeBB);
// }
// void handleIfElseIf(Value* cond) {
//     BasicBlock* thenBB = BasicBlock::Create(context, "then", mainFunction);
//     BasicBlock* elseBB = BasicBlock::Create(context, "else", mainFunction);
//     BasicBlock* mergeBB = BasicBlock::Create(context, "ifmerge", mainFunction);
    
//     builder.CreateCondBr(cond, thenBB, elseBB);
    
//     builder.SetInsertPoint(thenBB);
//     // Then block code
//     builder.CreateBr(mergeBB);
    
//     builder.SetInsertPoint(elseBB);
    
// }
void printLLVMIR() {
	module->print(errs(), nullptr);
}

Value* getFromSymbolTable(const char *id) {
    std::string name(id);
    auto it = SymbolTable.find(name);
    if (it != SymbolTable.end()) {
        return it->second;
    } else {
        yyerror("Variable not declared. Use 'summon' to declare.");
        exit(EXIT_FAILURE);
    }
}

void setDouble(const char *id, Value* value) {
	Value *ptr = getFromSymbolTable(id);
	builder.CreateStore(value, ptr);
}

void printfLLVM(const char *format, Value *inputValue) {
	Function *printfFunc = module->getFunction("printf");
	if(!printfFunc) {
		FunctionType *printfTy = FunctionType::get(builder.getInt32Ty(), PointerType::get(builder.getInt8Ty(), 0), true);
		printfFunc = Function::Create(printfTy, Function::ExternalLinkage, "printf", module);
	}
	Value *formatVal = builder.CreateGlobalStringPtr(format);
	builder.CreateCall(printfFunc, {formatVal, inputValue}, "printfCall");
}

void printString(const char *str) {
	Value *strValue = builder.CreateGlobalStringPtr(str);
	printfLLVM("%s\n", strValue);
}

void printDouble(Value *value) {
	printfLLVM("%f\n", value); 
}

Value* performBinaryOperation(Value* lhs, Value* rhs, int op) {
	switch (op) {
		case '+': return builder.CreateFAdd(lhs, rhs, "fadd");
		case '-': return builder.CreateFSub(lhs, rhs, "fsub");
		case '*': return builder.CreateFMul(lhs, rhs, "fmul");
		case '/': return builder.CreateFDiv(lhs, rhs, "fdiv");
		default: yyerror("illegal binary operation"); exit(EXIT_FAILURE);
	}
}

void handleForLoop(Value* init, Value* cond, Value* update) {
    BasicBlock* condBB = BasicBlock::Create(context, "for.cond", mainFunction);
    BasicBlock* bodyBB = BasicBlock::Create(context, "for.body", mainFunction);
    BasicBlock* updateBB = BasicBlock::Create(context, "for.update", mainFunction);
    BasicBlock* endBB = BasicBlock::Create(context, "for.end", mainFunction);
    
    // Initialization (already done)
    builder.CreateBr(condBB);
    
    // Condition
    builder.SetInsertPoint(condBB);
    Value* condValue = builder.CreateFCmpONE(cond, 
        ConstantFP::get(context, APFloat(0.0)), "for.cond");
    builder.CreateCondBr(condValue, bodyBB, endBB);
    
    // Body
    builder.SetInsertPoint(bodyBB);
    // Body code will be generated here
    builder.CreateBr(updateBB);
    
    // Update
    builder.SetInsertPoint(updateBB);
    // Update code will be generated here
    builder.CreateBr(condBB);
    
    // End
    builder.SetInsertPoint(endBB);
}