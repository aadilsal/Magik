; ModuleID = 'top'
source_filename = "top"

@0 = private unnamed_addr constant [31 x i8] c"BASIC ARITHMETIC AND VARIABLES\00", align 1
@1 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@2 = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@3 = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@4 = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@5 = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@6 = private unnamed_addr constant [16 x i8] c"IF-ELSE TESTING\00", align 1
@7 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@8 = private unnamed_addr constant [14 x i8] c"Y is beyond 5\00", align 1
@9 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@10 = private unnamed_addr constant [15 x i8] c"Y is notmore 5\00", align 1
@11 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@12 = private unnamed_addr constant [21 x i8] c"Z is between 0 and 5\00", align 1
@13 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@14 = private unnamed_addr constant [13 x i8] c"Z is invalid\00", align 1
@15 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@16 = private unnamed_addr constant [21 x i8] c"FOR-LOOP AND SCOPING\00", align 1
@17 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@18 = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@19 = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@20 = private unnamed_addr constant [14 x i8] c"NESTED SCOPES\00", align 1
@21 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@22 = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@23 = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

define i32 @main() {
entry:
  %printfCall = call i32 (ptr, ...) @printf(ptr @1, ptr @0)
  %a = alloca double, align 8
  store double 0.000000e+00, ptr %a, align 8
  store double 1.000000e+01, ptr %a, align 8
  %b = alloca double, align 8
  store double 0.000000e+00, ptr %b, align 8
  store double 5.000000e+00, ptr %b, align 8
  %load_identifier = load double, ptr %a, align 8
  %load_identifier1 = load double, ptr %b, align 8
  %fadd = fadd double %load_identifier, %load_identifier1
  store double %fadd, ptr %a, align 8
  %load_reveal = load double, ptr %a, align 8
  %printfCall2 = call i32 (ptr, ...) @printf(ptr @2, double %load_reveal)
  %load_identifier3 = load double, ptr %a, align 8
  %load_identifier4 = load double, ptr %b, align 8
  %fsub = fsub double %load_identifier3, %load_identifier4
  store double %fsub, ptr %a, align 8
  %load_reveal5 = load double, ptr %a, align 8
  %printfCall6 = call i32 (ptr, ...) @printf(ptr @3, double %load_reveal5)
  %load_identifier7 = load double, ptr %a, align 8
  %load_identifier8 = load double, ptr %b, align 8
  %fmul = fmul double %load_identifier7, %load_identifier8
  store double %fmul, ptr %a, align 8
  %load_reveal9 = load double, ptr %a, align 8
  %printfCall10 = call i32 (ptr, ...) @printf(ptr @4, double %load_reveal9)
  %load_identifier11 = load double, ptr %b, align 8
  %load_identifier12 = load double, ptr %a, align 8
  %fdiv = fdiv double %load_identifier11, %load_identifier12
  store double %fdiv, ptr %a, align 8
  %load_reveal13 = load double, ptr %a, align 8
  %printfCall14 = call i32 (ptr, ...) @printf(ptr @5, double %load_reveal13)
  %printfCall15 = call i32 (ptr, ...) @printf(ptr @7, ptr @6)
  %y = alloca double, align 8
  store double 0.000000e+00, ptr %y, align 8
  store double 1.000000e+01, ptr %y, align 8
  %load_identifier16 = load double, ptr %y, align 8
  %fcmp_gt = fcmp ogt double %load_identifier16, 5.000000e+00
  br i1 %fcmp_gt, label %then, label %else

then:                                             ; preds = %entry
  %printfCall17 = call i32 (ptr, ...) @printf(ptr @9, ptr @8)
  br label %ifcont

else:                                             ; preds = %entry
  %printfCall18 = call i32 (ptr, ...) @printf(ptr @11, ptr @10)
  br label %ifcont

ifcont:                                           ; preds = %else, %then
  %z = alloca double, align 8
  store double 0.000000e+00, ptr %z, align 8
  store double 3.000000e+00, ptr %z, align 8
  %load_identifier19 = load double, ptr %z, align 8
  %fcmp_lt = fcmp olt double %load_identifier19, 5.000000e+00
  %load_identifier20 = load double, ptr %z, align 8
  %fcmp_ne = fcmp one double %load_identifier20, 0.000000e+00
  %logical_and = and i1 %fcmp_lt, %fcmp_ne
  br i1 %logical_and, label %then21, label %else22

then21:                                           ; preds = %ifcont
  %printfCall24 = call i32 (ptr, ...) @printf(ptr @13, ptr @12)
  br label %ifcont23

else22:                                           ; preds = %ifcont
  %printfCall25 = call i32 (ptr, ...) @printf(ptr @15, ptr @14)
  br label %ifcont23

ifcont23:                                         ; preds = %else22, %then21
  %printfCall26 = call i32 (ptr, ...) @printf(ptr @17, ptr @16)
  %i = alloca double, align 8
  store double 0.000000e+00, ptr %i, align 8
  store double 0.000000e+00, ptr %i, align 8
  store double 0.000000e+00, ptr %i, align 8
  br label %loop.cond

loop.cond:                                        ; preds = %loop.inc, %ifcont23
  %i27 = load double, ptr %i, align 8
  %cmptmp = fcmp ult double %i27, 3.000000e+00
  br i1 %cmptmp, label %loop.body, label %loop.end

loop.body:                                        ; preds = %loop.cond
  %i28 = alloca double, align 8
  store double 0.000000e+00, ptr %i28, align 8
  store double 2.000000e+00, ptr %i28, align 8
  %load_reveal29 = load double, ptr %i28, align 8
  %printfCall30 = call i32 (ptr, ...) @printf(ptr @18, double %load_reveal29)
  br label %loop.inc

loop.inc:                                         ; preds = %loop.body
  %i31 = load double, ptr %i, align 8
  %incr = fadd double %i31, 1.000000e+00
  store double %incr, ptr %i, align 8
  br label %loop.cond

loop.end:                                         ; preds = %loop.cond
  %load_reveal32 = load double, ptr %i, align 8
  %printfCall33 = call i32 (ptr, ...) @printf(ptr @19, double %load_reveal32)
  %printfCall34 = call i32 (ptr, ...) @printf(ptr @21, ptr @20)
  %outerVar = alloca double, align 8
  store double 0.000000e+00, ptr %outerVar, align 8
  store double 1.000000e+02, ptr %outerVar, align 8
  %outerVar35 = alloca double, align 8
  store double 0.000000e+00, ptr %outerVar35, align 8
  store double 2.000000e+02, ptr %outerVar35, align 8
  %load_reveal36 = load double, ptr %outerVar35, align 8
  %printfCall37 = call i32 (ptr, ...) @printf(ptr @22, double %load_reveal36)
  %load_reveal38 = load double, ptr %outerVar, align 8
  %printfCall39 = call i32 (ptr, ...) @printf(ptr @23, double %load_reveal38)
  ret i32 0
}

declare i32 @printf(ptr, ...)
