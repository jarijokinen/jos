#ifndef _STRING_H
#define _STRING_H

void memmove(void *dst, const void *src, size_t n);
void memset(void *dst, int c, size_t n);
void itoa(int n, char *str);
void reverse(char *str);
size_t strlen(char *str);

#endif
