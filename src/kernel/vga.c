#include "io.h"
#include <stdint.h>
#include <stddef.h>
#include "string.h"
#include "vga.h"

#define VGA_COLS 80
#define VGA_ROWS 25
#define VGA_PORT 0x3d4

static void vga_putc(char c);
static void vga_update_cursor(void);

struct vga_char {
  char c;
  uint8_t attr;
};

static size_t col = 0;
static size_t row = 0;

static struct vga_char *vga_mem = (struct vga_char *)0xb8000;

void vga_puts(char *str) {
  for (; *str; str++) {
    vga_putc(*str);
  }
  vga_update_cursor();
}

void vga_clear() {
  for (size_t i = 0; i < (VGA_COLS * VGA_ROWS); i++) {
    vga_mem[i].c = ' ';
    vga_mem[i].attr = 0x0f;
  }
  row = 0;
  col = 0;
  vga_update_cursor();
}

static void vga_putc(char c) {
  if (c == '\n') {
    row++;
    col = 0;
  }
  else {
    size_t i = row * VGA_COLS + col;

    vga_mem[i].c = c;
    vga_mem[i].attr = 0x07;

    col++;

    if (col == VGA_COLS) {
      row++;
      col = 0;
    }
  }

  if (row == VGA_ROWS) {
    row--;
    memmove(vga_mem, vga_mem + VGA_COLS, VGA_COLS * (VGA_ROWS - 1) * 2);
    memset((uint64_t *)(vga_mem + VGA_COLS * (VGA_ROWS - 1)), 0, VGA_COLS * 2);
  }
}

static void vga_update_cursor(void) {
  size_t pos = row * VGA_COLS + col;

  outb(VGA_PORT, 0x0e);
  outb(VGA_PORT + 1, (pos >> 8) & 0xff);

  outb(VGA_PORT, 0x0f);
  outb(VGA_PORT + 1, pos & 0xff);
}
