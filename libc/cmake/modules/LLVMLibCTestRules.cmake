# This is a helper function and not a build rule. It is to be used by the
# various test rules to generate the full list of object files
# recursively produced by "add_entrypoint_object" and "add_object_library"
# targets.
# Usage:
#   get_object_files_for_test(<result var> <target0> [<target1> ...])
#
#   targetN is either an "add_entrypoint_target" target or an
#   "add_object_library" target.
function(get_object_files_for_test result)
  set(object_files "")
  foreach(dep IN LISTS ARGN)
    get_target_property(dep_type ${dep} "TARGET_TYPE")
    if(NOT dep_type)
      # Target for which TARGET_TYPE property is not set do not
      # provide any object files.
      continue()
    endif()

    if(${dep_type} STREQUAL ${OBJECT_LIBRARY_TARGET_TYPE})
      get_target_property(dep_object_files ${dep} "OBJECT_FILES")
      if(dep_object_files)
        list(APPEND object_files ${dep_object_files})
      endif()
    elseif(${dep_type} STREQUAL ${ENTRYPOINT_OBJ_TARGET_TYPE})
      get_target_property(object_file_raw ${dep} "OBJECT_FILE_RAW")
      if(object_file_raw)
        list(APPEND object_files ${object_file_raw})
      endif()
    endif()

    get_target_property(indirect_deps ${dep} "DEPS")
    get_object_files_for_test(indirect_objfiles ${indirect_deps})
    list(APPEND object_files ${indirect_objfiles})
  endforeach(dep)
  list(REMOVE_DUPLICATES object_files)
  set(${result} ${object_files} PARENT_SCOPE)
endfunction(get_object_files_for_test)

# Rule to add a libc integration test.
# Usage
#    add_libc_integration_test(
#      <target name>
#      SUITE <name of the suite this test belongs to>
#      SRCS  <list of .c files for the test>
#      HDRS  <list of .h files for the test>
#      LIB   <public library to link against>
#    )
function(add_libc_integration_test target_name)
  if(NOT LLVM_INCLUDE_TESTS)
    return()
  endif()

  cmake_parse_arguments(
    "LIBC_INTTEST"
    "" # No optional arguments
    "SUITE;LIB" # Single value arguments
    "SRCS;HDRS" # Multi-value arguments
    ${ARGN}
  )
  if(NOT LIBC_INTTEST_SRCS)
    message(FATAL_ERROR "'add_libc_integration_test' target requires a SRCS "
                        "list of .c files.")
  endif()
  if(NOT LIBC_INTTEST_HDRS)
    message(FATAL_ERROR "'add_libc_integration_test' target requires a HDRS "
                        "list of public .h files.")
  endif()
  if(NOT LIBC_INTTEST_LIB)
    message(FATAL_ERROR "'add_libc_integration_test' target requires a LIB "
                        "public library to link against.")
  endif()

  get_fq_target_name(${target_name} fq_target_name)
  add_executable(
    ${fq_target_name}
    EXCLUDE_FROM_ALL
    ${LIBC_INTTEST_SRCS}
  )
  set_target_properties(${fq_target_name}
    PROPERTIES 
    INCLUDE_DIRECTORIES ""
  )
  target_include_directories(
    ${fq_target_name} SYSTEM BEFORE 
    PRIVATE
      "${LIBC_BUILD_DIR}/include"
  )
  target_compile_options(
    ${fq_target_name}
    PRIVATE "-nostdinc" "-Wall" "-Wconversion" "-Werror" 
    # There is currently a bug that prevents us from adding the compilers
    # include directory using target_include_directories so we must add it in
    # the compiler flags ourselves. This is because -ibuiltininc is only
    # available on clang 11.
    # See: https://gitlab.kitware.com/cmake/cmake/issues/19227
    # TODO: Get compiler include dir dynamically. 
    "-isystem" "/usr/lib/llvm-8/lib/clang/8.0.1/include"
  )
  target_link_options(
    ${fq_target_name}
    PRIVATE "-nostdlib"
  )

  add_dependencies(
    ${fq_target_name}
    ${LIBC_INTTEST_LIB}
    ${LIBC_INTTEST_HDRS}
    libc.loader.linux.crt1
  )
  # Grab the object file assosciated with the loader.
  get_object_files_for_test(loader_object_file libc.loader.linux.crt1)

  get_target_property(library_file ${LIBC_INTTEST_LIB} "LIBRARY_FILE")
  target_link_libraries(${fq_target_name} 
    PRIVATE 
    ${library_file} 
    ${loader_object_file}
  )

  set_target_properties(${fq_target_name}
  PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

  add_custom_command(
    TARGET ${fq_target_name}
    POST_BUILD
    COMMAND $<TARGET_FILE:${fq_target_name}>
  )

  # Differential test against system libc.
  add_executable(
    ${fq_target_name}-systemlibc
    EXCLUDE_FROM_ALL
    ${LIBC_INTTEST_SRCS}
  )
  add_custom_command(
    TARGET ${fq_target_name}-systemlibc
    POST_BUILD
    COMMAND $<TARGET_FILE:${fq_target_name}-systemlibc>
  )

  if(LIBC_INTTEST_SUITE)
    add_dependencies(
      ${LIBC_INTTEST_SUITE}
      ${fq_target_name}
      ${fq_target_name}-systemlibc
    )
  endif()
endfunction(add_libc_integration_test)

# Rule to add a libc unittest.
# Usage
#    add_libc_unittest(
#      <target name>
#      SUITE <name of the suite this test belongs to>
#      SRCS  <list of .cpp files for the test>
#      HDRS  <list of .h files for the test>
#      DEPENDS <list of dependencies>
#      COMPILE_OPTIONS <list of special compile options for this target>
#    )
function(add_libc_unittest target_name)
  if(NOT LLVM_INCLUDE_TESTS)
    return()
  endif()

  cmake_parse_arguments(
    "LIBC_UNITTEST"
    "" # No optional arguments
    "SUITE" # Single value arguments
    "SRCS;HDRS;DEPENDS;COMPILE_OPTIONS" # Multi-value arguments
    ${ARGN}
  )
  if(NOT LIBC_UNITTEST_SRCS)
    message(FATAL_ERROR "'add_libc_unittest' target requires a SRCS list of .cpp "
                        "files.")
  endif()
  if(NOT LIBC_UNITTEST_DEPENDS)
    message(FATAL_ERROR "'add_libc_unittest' target requires a DEPENDS list of "
                        "'add_entrypoint_object' targets.")
  endif()


  get_fq_target_name(${target_name} fq_target_name)
  add_executable(
    ${fq_target_name}
    EXCLUDE_FROM_ALL
    ${LIBC_UNITTEST_SRCS}
    ${LIBC_UNITTEST_HDRS}
  )
  target_include_directories(
    ${fq_target_name}
    PRIVATE
      ${LIBC_SOURCE_DIR}
      ${LIBC_BUILD_DIR}
      ${LIBC_BUILD_DIR}/include
  )
  if(LIBC_UNITTEST_COMPILE_OPTIONS)
    target_compile_options(
      ${target_name}
      PRIVATE ${LIBC_UNITTEST_COMPILE_OPTIONS}
    )
  endif()

  get_fq_deps_list(fq_deps_list ${LIBC_UNITTEST_DEPENDS})
  get_object_files_for_test(link_object_files ${fq_deps_list})
  target_link_libraries(${fq_target_name} PRIVATE ${link_object_files})

  set_target_properties(${fq_target_name}
    PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

  add_dependencies(
    ${fq_target_name}
    ${fq_deps_list}
  )

  target_link_libraries(${fq_target_name} PRIVATE LibcUnitTest libc_test_utils)

  add_custom_command(
    TARGET ${fq_target_name}
    POST_BUILD
    COMMAND $<TARGET_FILE:${fq_target_name}>
  )
  if(LIBC_UNITTEST_SUITE)
    add_dependencies(
      ${LIBC_UNITTEST_SUITE}
      ${fq_target_name}
    )
  endif()
endfunction(add_libc_unittest)

function(add_libc_testsuite suite_name)
  add_custom_target(${suite_name})
  add_dependencies(check-libc ${suite_name})
endfunction(add_libc_testsuite)

# Rule to add a fuzzer test.
# Usage
#    add_libc_fuzzer(
#      <target name>
#      SRCS  <list of .cpp files for the test>
#      HDRS  <list of .h files for the test>
#      DEPENDS <list of dependencies>
#    )
function(add_libc_fuzzer target_name)
  cmake_parse_arguments(
    "LIBC_FUZZER"
    "" # No optional arguments
    "" # Single value arguments
    "SRCS;HDRS;DEPENDS" # Multi-value arguments
    ${ARGN}
  )
  if(NOT LIBC_FUZZER_SRCS)
    message(FATAL_ERROR "'add_libc_fuzzer' target requires a SRCS list of .cpp "
                        "files.")
  endif()
  if(NOT LIBC_FUZZER_DEPENDS)
    message(FATAL_ERROR "'add_libc_fuzzer' target requires a DEPENDS list of "
                        "'add_entrypoint_object' targets.")
  endif()

  get_fq_target_name(${target_name} fq_target_name)
  add_executable(
    ${fq_target_name}
    EXCLUDE_FROM_ALL
    ${LIBC_FUZZER_SRCS}
    ${LIBC_FUZZER_HDRS}
  )
  target_include_directories(
    ${fq_target_name}
    PRIVATE
      ${LIBC_SOURCE_DIR}
      ${LIBC_BUILD_DIR}
      ${LIBC_BUILD_DIR}/include
  )

  get_fq_deps_list(fq_deps_list ${LIBC_FUZZER_DEPENDS})
  get_object_files_for_test(link_object_files ${fq_deps_list})
  target_link_libraries(${fq_target_name} PRIVATE ${link_object_files})

  set_target_properties(${fq_target_name}
      PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})

  add_dependencies(
    ${fq_target_name}
    ${fq_deps_list}
  )
  add_dependencies(libc-fuzzer ${fq_target_name})
endfunction(add_libc_fuzzer)
