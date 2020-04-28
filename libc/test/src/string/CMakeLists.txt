add_libc_testsuite(libc_string_unittests)

add_subdirectory(memory_utils)

add_libc_unittest(
  strcat_test
  SUITE
    libc_string_unittests
  SRCS
    strcat_test.cpp
  DEPENDS
    libc.src.string.strcat
)
add_libc_integration_test(
  strcat_integration_test
  SUITE
    libc_string_unittests
  SRCS
    strcat_integration_test.c
  HDRS
    libc.include.string
  LIB
    llvmlibc
)

add_libc_unittest(
  strcpy_test
  SUITE
    libc_string_unittests
  SRCS
    strcpy_test.cpp
  DEPENDS
    libc.src.string.strcpy
)
add_libc_integration_test(
  strcpy_integration_test
  SUITE
    libc_string_unittests
  SRCS
    strcpy_integration_test.c
  HDRS
    libc.include.string
  LIB
    llvmlibc
)

add_libc_unittest(
  strlen_test
  SUITE
    libc_string_unittests
  SRCS
    strlen_test.cpp
  DEPENDS
    libc.src.string.strlen
)
add_libc_integration_test(
  strlen_integration_test
  SUITE
    libc_string_unittests
  SRCS
    strlen_integration_test.c
  HDRS
    libc.include.string
  LIB
    llvmlibc
)


# Tests all implementations of memcpy that can run on the host.
get_property(memcpy_implementations GLOBAL PROPERTY memcpy_implementations)
foreach(memcpy_config_name IN LISTS memcpy_implementations)
  get_target_property(require_cpu_features libc.src.string.${memcpy_config_name} REQUIRE_CPU_FEATURES)
  host_supports(can_run "${require_cpu_features}")
  if(can_run)
    add_libc_unittest(
      ${memcpy_config_name}_test
      SUITE
        libc_string_unittests
      SRCS
        memcpy_test.cpp
      DEPENDS
        libc.src.string.${memcpy_config_name}
    )
  else()
    message(STATUS "Skipping test for '${memcpy_config_name}' insufficient host cpu features")
  endif()
endforeach()

add_libc_integration_test(
  memcpy_integration_test
  SUITE
    libc_string_unittests
  SRCS
    memcpy_integration_test.c
  HDRS
    libc.include.string
  LIB
    llvmlibc
)
