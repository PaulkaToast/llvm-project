add_libc_unittest(
  libc_linux_aarch64_syscall_unittest
  SUITE libc_linux_tests
  SRCS syscall_test.cpp
  DEPENDS
   libc.config.linux.linux_syscall_h
)