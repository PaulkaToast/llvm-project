#include "src/string/strcpy.h"
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

extern "C" int LLVMFuzzerTestOneInput(uint8_t *data, size_t size) {
  if (size == 0) {
    return 0;
  }
  // strcpy can only accept null-terminated strings.
  char *src = (char *)malloc(size + 1);
  memcpy(src, data, size);
  for (size_t i = 0; i < size; i++) {
    // replace early null-termination with valid character.
    if (src[i] == '\0') {
      src[i] = 'a';
    }
  }
  src[size] = '\0';

  char *dest = (char *)malloc(size + 1);
  __llvm_libc::strcpy(dest, src);

  if (strcmp(dest, src) != 0) {
    abort();
  }
  free(src);
  free(dest);
  return 0;
}
