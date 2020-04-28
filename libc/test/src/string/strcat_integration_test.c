#include <string.h>

int main() {
  const char *s2 = "llo";
  char s1[6];
  s1[0] = 'h';
  s1[1] = 'e';
  s1[2] = '\0';
  char *ret = strcat(s1, s2);
  (void)ret;
  return 0;
}
