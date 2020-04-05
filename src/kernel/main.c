#include "vga.h"

void kdie(void)
{
  while(1) {
    asm("cli");
    asm("hlt");
  }
}

void kmain(void)
{
  vga_clear();
  vga_puts("Welcome to Jari's Operating System\n");
  kdie();
}

void klog(char *str)
{
  vga_puts(str);
  vga_puts("\n");
}

void kpanic(char *str)
{
  vga_puts("KERNEL PANIC: ");
  vga_puts(str);
  kdie();
}
