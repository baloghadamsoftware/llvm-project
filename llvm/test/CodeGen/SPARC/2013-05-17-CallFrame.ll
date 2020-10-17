; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -march=sparc   < %s | FileCheck %s --check-prefix=V8
; RUN: llc -march=sparcv9 < %s | FileCheck %s --check-prefix=SPARC64

; (this should ideally be doing "add 4+7; and -8", instead of
;  "add 7; and -8; add 8"; see comments in LowerDYNAMIC_STACKALLOC)

define void @variable_alloca_with_adj_call_stack(i32 %num) {
; V8-LABEL: variable_alloca_with_adj_call_stack:
; V8:         .cfi_startproc
; V8-NEXT:  ! %bb.0: ! %entry
; V8-NEXT:    save %sp, -96, %sp
; V8-NEXT:    .cfi_def_cfa_register %fp
; V8-NEXT:    .cfi_window_save
; V8-NEXT:    .cfi_register %o7, %i7
; V8-NEXT:    add %i0, 7, %i0
; V8-NEXT:    and %i0, -8, %i0
; V8-NEXT:    sub %sp, %i0, %i0
; V8-NEXT:    add %i0, -8, %sp
; V8-NEXT:    add %i0, 88, %o0
; V8-NEXT:    add %sp, -16, %sp
; V8-NEXT:    st %o0, [%sp+104]
; V8-NEXT:    st %o0, [%sp+100]
; V8-NEXT:    st %o0, [%sp+96]
; V8-NEXT:    st %o0, [%sp+92]
; V8-NEXT:    mov %o0, %o1
; V8-NEXT:    mov %o0, %o2
; V8-NEXT:    mov %o0, %o3
; V8-NEXT:    mov %o0, %o4
; V8-NEXT:    call foo
; V8-NEXT:    mov %o0, %o5
; V8-NEXT:    add %sp, 16, %sp
; V8-NEXT:    ret
; V8-NEXT:    restore
;
; SPARC64-LABEL: variable_alloca_with_adj_call_stack:
; SPARC64:         .cfi_startproc
; SPARC64-NEXT:  ! %bb.0: ! %entry
; SPARC64-NEXT:    save %sp, -128, %sp
; SPARC64-NEXT:    .cfi_def_cfa_register %fp
; SPARC64-NEXT:    .cfi_window_save
; SPARC64-NEXT:    .cfi_register %o7, %i7
; SPARC64-NEXT:    srl %i0, 0, %i0
; SPARC64-NEXT:    add %i0, 15, %i0
; SPARC64-NEXT:    sethi 4194303, %i1
; SPARC64-NEXT:    or %i1, 1008, %i1
; SPARC64-NEXT:    sethi 0, %i2
; SPARC64-NEXT:    or %i2, 1, %i2
; SPARC64-NEXT:    sllx %i2, 32, %i2
; SPARC64-NEXT:    or %i2, %i1, %i1
; SPARC64-NEXT:    and %i0, %i1, %i0
; SPARC64-NEXT:    sub %sp, %i0, %i0
; SPARC64-NEXT:    add %i0, 2175, %o0
; SPARC64-NEXT:    mov %i0, %sp
; SPARC64-NEXT:    add %sp, -80, %sp
; SPARC64-NEXT:    stx %o0, [%sp+2247]
; SPARC64-NEXT:    stx %o0, [%sp+2239]
; SPARC64-NEXT:    stx %o0, [%sp+2231]
; SPARC64-NEXT:    stx %o0, [%sp+2223]
; SPARC64-NEXT:    mov %o0, %o1
; SPARC64-NEXT:    mov %o0, %o2
; SPARC64-NEXT:    mov %o0, %o3
; SPARC64-NEXT:    mov %o0, %o4
; SPARC64-NEXT:    call foo
; SPARC64-NEXT:    mov %o0, %o5
; SPARC64-NEXT:    add %sp, 80, %sp
; SPARC64-NEXT:    ret
; SPARC64-NEXT:    restore
entry:
  %0 = alloca i8, i32 %num, align 8
  call void @foo(i8* %0, i8* %0, i8* %0, i8* %0, i8* %0, i8* %0, i8* %0, i8* %0, i8* %0, i8* %0)
  ret void
}

declare void @foo(i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*, i8*);
