//===-- inline implementation of aarch64 syscalls -------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

%%begin()

#include "src/__support/common.h"

// cc stands for the condition register.
#define SYSCALL_CLOBBER_LIST "cc", "memory"

namespace __llvm_libc {

// There are no machine constrainsts for aarch64 family that specify specific
// registers thus we create register aliases for them.
__attribute__((always_inline)) inline long syscall(long __number) {
  register long retcode asm("x0");
  register long syscall_num asm("x8") = __number;
  
  LIBC_INLINE_ASM("svc 0"
                  : "=r"(retcode)
                  : "r"(syscall_num)
                  : SYSCALL_CLOBBER_LIST);
  return retcode;
}

__attribute__((always_inline)) inline long syscall(long __number, long __arg1) {
  register long retcode asm("x0");
  register long syscall_num asm("x8") = __number;

  register long arg1 asm("x0") = __arg1;
  
  LIBC_INLINE_ASM("svc 0"
                  : "=r"(retcode)
                  : "r"(syscall_num), "r"(arg1)
                  : SYSCALL_CLOBBER_LIST);
  return retcode;
}

__attribute__((always_inline)) inline long syscall(long __number, long __arg1,
                                                   long __arg2) {
  register long retcode asm("x0");
  register long syscall_num asm("x8") = __number;

  register long arg1 asm("x0") = __arg1;
  register long arg2 asm("x1") = __arg2;
  
  LIBC_INLINE_ASM("svc 0"
                  : "=r"(retcode)
                  : "r"(syscall_num), "r"(arg1), "r"(arg2)
                  : SYSCALL_CLOBBER_LIST);
  return retcode;
}

__attribute__((always_inline)) inline long syscall(long __number, long __arg1,
                                                   long __arg2, long __arg3) {
  register long retcode asm("x0");
  register long syscall_num asm("x8") = __number;

  register long arg1 asm("x0") = __arg1;
  register long arg2 asm("x1") = __arg2;
  register long arg3 asm("x2") = __arg3;
  
  LIBC_INLINE_ASM("svc 0"
                  : "=r"(retcode)
                  : "r"(syscall_num), "r"(arg1), "r"(arg2), "r"(arg3)
                  : SYSCALL_CLOBBER_LIST);
  return retcode;
}

__attribute__((always_inline)) inline long syscall(long __number, long __arg1,
                                                   long __arg2, long __arg3,
                                                   long __arg4) {
  register long retcode asm("x0");
  register long syscall_num asm("x8") = __number;

  register long arg1 asm("x0") = __arg1;
  register long arg2 asm("x1") = __arg2;
  register long arg3 asm("x2") = __arg3;
  register long arg4 asm("x3") = __arg4;
  
  LIBC_INLINE_ASM("svc 0"
                  : "=r"(retcode)
                  : "r"(syscall_num), "r"(arg1), "r"(arg2), "r"(arg3), 
                    "r"(arg4)
                  : SYSCALL_CLOBBER_LIST);
  return retcode;
}

__attribute__((always_inline)) inline long syscall(long __number, long __arg1,
                                                   long __arg2, long __arg3,
                                                   long __arg4, long __arg5) {
  register long retcode asm("x0");
  register long syscall_num asm("x8") = __number;

  register long arg1 asm("x0") = __arg1;
  register long arg2 asm("x1") = __arg2;
  register long arg3 asm("x2") = __arg3;
  register long arg4 asm("x3") = __arg4;
  register long arg5 asm("x4") = __arg5;
  
  LIBC_INLINE_ASM("svc 0"
                  : "=r"(retcode)
                  : "r"(syscall_num), "r"(arg1), "r"(arg2), "r"(arg3), 
                    "r"(arg4), "r"(arg5)
                  : SYSCALL_CLOBBER_LIST);
  return retcode;
}


__attribute__((always_inline)) inline long syscall(long __number, long __arg1,
                                                   long __arg2, long __arg3,
                                                   long __arg4, long __arg5,
                                                   long __arg6) {
  register long retcode asm("x0");
  register long syscall_num asm("x8") = __number;

  register long arg1 asm("x0") = __arg1;
  register long arg2 asm("x1") = __arg2;
  register long arg3 asm("x2") = __arg3;
  register long arg4 asm("x3") = __arg4;
  register long arg5 asm("x4") = __arg5;
  register long arg6 asm("x5") = __arg6;
  
  LIBC_INLINE_ASM("svc 0"
                  : "=r"(retcode)
                  : "r"(syscall_num), "r"(arg1), "r"(arg2), "r"(arg3), 
                   "r"(arg4), "r"(arg5), "r"(arg6)
                  : SYSCALL_CLOBBER_LIST);
  return retcode;
}

template <typename... Ts>
__attribute__((always_inline)) inline long syscall(long __number, Ts... ts) {
  static_assert(sizeof...(Ts) <= 6, "Too many arguments for syscall");
  return syscall(__number, (long)ts...);
}

#undef SYSCALL_CLOBBER_LIST

} // namespace __llvm_libc    
