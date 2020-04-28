#include <string.h>

int main() {
  const char *s2 = "hello";
  char s1[6];
  char *ret = strcpy(s1, s2);
  (void)ret;
  return 0;
}
