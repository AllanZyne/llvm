; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 4
; RUN: opt -S -passes=indvars < %s | FileCheck %s

target datalayout = "n64"

declare void @use(i64)

define void @or_disjoint() {
; CHECK-LABEL: define void @or_disjoint() {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 2, [[ENTRY:%.*]] ], [ [[IV_DEC:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[OR:%.*]] = or disjoint i64 [[IV]], 1
; CHECK-NEXT:    call void @use(i64 [[OR]])
; CHECK-NEXT:    [[IV_DEC]] = add nsw i64 [[IV]], -1
; CHECK-NEXT:    [[EXIT_COND:%.*]] = icmp eq i64 [[IV_DEC]], 0
; CHECK-NEXT:    br i1 [[EXIT_COND]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv = phi i64 [ 2, %entry ], [ %iv.dec, %loop ]
  %or = or disjoint i64 %iv, 1
  %add = add nsw i64 %iv, 1
  %sel = select i1 false, i64 %or, i64 %add
  call void @use(i64 %sel)

  %iv.dec = add nsw i64 %iv, -1
  %exit.cond = icmp eq i64 %iv.dec, 0
  br i1 %exit.cond, label %exit, label %loop

exit:
  ret void
}

define void @add_nowrap_flags(i64 %n) {
; CHECK-LABEL: define void @add_nowrap_flags(
; CHECK-SAME: i64 [[N:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_INC:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[ADD1:%.*]] = add nuw nsw i64 [[IV]], 123
; CHECK-NEXT:    call void @use(i64 [[ADD1]])
; CHECK-NEXT:    [[IV_INC]] = add i64 [[IV]], 1
; CHECK-NEXT:    [[EXIT_COND:%.*]] = icmp eq i64 [[IV_INC]], [[N]]
; CHECK-NEXT:    br i1 [[EXIT_COND]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop

loop:
  %iv = phi i64 [ 0, %entry ], [ %iv.inc, %loop ]
  %add1 = add nuw nsw i64 %iv, 123
  %add2 = add i64 %iv, 123
  %sel = select i1 false, i64 %add1, i64 %add2
  call void @use(i64 %sel)

  %iv.inc = add i64 %iv, 1
  %exit.cond = icmp eq i64 %iv.inc, %n
  br i1 %exit.cond, label %exit, label %loop

exit:
  ret void
}


define void @expander_or_disjoint(i64 %n) {
; CHECK-LABEL: define void @expander_or_disjoint(
; CHECK-SAME: i64 [[N:%.*]]) {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[OR:%.*]] = or i64 [[N]], 1
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[IV_INC:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[IV_INC]] = add i64 [[IV]], 1
; CHECK-NEXT:    [[ADD:%.*]] = add i64 [[IV]], [[OR]]
; CHECK-NEXT:    call void @use(i64 [[ADD]])
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i64 [[IV_INC]], [[OR]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %or = or disjoint i64 %n, 1
  br label %loop

loop:
  %iv = phi i64 [ 0, %entry ], [ %iv.inc, %loop ]
  %iv.inc = add i64 %iv, 1
  %add = add i64 %iv, %or
  call void @use(i64 %add)
  %cmp = icmp ult i64 %iv, %n
  br i1 %cmp, label %loop, label %exit

exit:
  ret void
}
