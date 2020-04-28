#include <string.h>

int main() {
  const char *s2 = "hello";
  char s1[6];
  size_t n = 6;
  void *ret = memcpy((void *)s1, (const void *)s2, n);
  (void)ret;
  return 0;
}
