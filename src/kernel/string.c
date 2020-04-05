#include <stddef.h>
#include <stdint.h>
#include "string.h"

void memmove(void *dst, const void *src, size_t n)
{
  char *d = dst;
  const char *s = src;

  if (d < s) {
    for (size_t i = 0; i < n; i++) {
      d[i] = s[i];
    }
  }
  else {
    for (size_t i = 0; i < n; i++) {
      d[n - i - 1] = s[n - i - 1];
    }
  }
}

void memset(void *dst, int c, size_t n)
{
  char *d = dst;

  do {
    *d++ = c;
  } while (--n);
}

void itoa(int n, char *str)
{
  int i, sign;

  if ((sign = n) < 0) {
    n = -n;
  }

  i = 0;

  do {
    str[i++] = n % 10 + '0';
  } while ((n /= 10) > 0);

  if (sign < 0) {
    str[i++] = '-';
  }

  str[i] = '\0';
  reverse(str);
}

void reverse(char *str)
{
  char c;

  for (int i = 0, j = strlen(str) - 1; i < j; i++, j--) {
    c = str[i];
    str[i] = str[j];
    str[j] = c;
  }
}

size_t strlen(char *str)
{
  int len = 0;

  for (int i = 0; str[i] != 0; i++) {
    len++;
  }

  return len;
}
