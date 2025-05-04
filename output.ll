; ModuleID = 'top'
source_filename = "top"

@0 = private unnamed_addr constant [14 x i8] c"Y is beyond 5\00", align 1
@1 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@2 = private unnamed_addr constant [15 x i8] c"Y is notmore 5\00", align 1
@3 = private unnamed_addr constant [4 x i8] c"%s\0A\00", align 1
@4 = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@5 = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1

define i32 @main() {
entry:
  %y = alloca double, align 8
  store double 0.000000e+00, ptr %y, align 8
  store double 1.000000e+01, ptr %y, align 8
  %load_identifier = load double, ptr %y, align 8
  %fcmp_gt = fcmp ogt double %load_identifier, 5.000000e+00
  %logical_not = xor i1 %fcmp_gt, true
  br i1 %logical_not, label %then, label %else

then:                                             ; preds = %entry
  %printfCall = call i32 (ptr, ...) @printf(ptr @1, ptr @0)
  br label %ifcont

else:                                             ; preds = %entry
  %printfCall1 = call i32 (ptr, ...) @printf(ptr @3, ptr @2)
  br label %ifcont

ifcont:                                           ; preds = %else, %then
  %i = alloca double, align 8
  store double 0.000000e+00, ptr %i, align 8
  store double 0.000000e+00, ptr %i, align 8
  store double 0.000000e+00, ptr %i, align 8
  br label %loop.cond

loop.cond:                                        ; preds = %loop.inc, %ifcont
  %i2 = load double, ptr %i, align 8
  %cmptmp = fcmp ult double %i2, 5.000000e+00
  br i1 %cmptmp, label %loop.body, label %loop.end

loop.body:                                        ; preds = %loop.cond
  %load_reveal = load double, ptr %i, align 8
  %printfCall3 = call i32 (ptr, ...) @printf(ptr @4, double %load_reveal)
  br label %loop.inc

loop.inc:                                         ; preds = %loop.body
  %i4 = load double, ptr %i, align 8
  %incr = fadd double %i4, 1.000000e+00
  store double %incr, ptr %i, align 8
  br label %loop.cond

loop.end:                                         ; preds = %loop.cond
  %x = alloca double, align 8
  store double 0.000000e+00, ptr %x, align 8
  store double 1.000000e+01, ptr %x, align 8
  store double 2.000000e+01, ptr %x, align 8
  %load_reveal5 = load double, ptr %x, align 8
  %printfCall6 = call i32 (ptr, ...) @printf(ptr @5, double %load_reveal5)
  ret i32 0
}

declare i32 @printf(ptr, ...)
