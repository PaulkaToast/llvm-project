#include "src/string/memory_utils/memcpy_utils.h"

static void CopyGE128(char *__restrict dst, const char *__restrict src,
                      size_t count) {
    __builtin_memcpy(dst, src, count);
}