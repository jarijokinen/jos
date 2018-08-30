; mbr.asm - MBR part of the bootloader for JOS
; Copyright (C) 2018 Jari Jokinen

org 0x7c00
bits 16

jmp 0x0000:_start

_start:
  cli

  ; Reset segment registers to zero

  xor ax, ax
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  ; Initialize stack

  mov ss, ax
  mov sp, _start

  call set_video_mode

  ; Read the loader from the disk

  mov si, MSG_LOADING
  call print

  mov bx, 0x1000  ; Where to save the data?
  mov dh, 17       ; Number of sectors to read (1 * 512 = 512 bytes)
  push dx

  mov ah, 0x02    ; BIOS INT 0x13 ah=0x02: Read Disk Sectors
  mov al, dh      ; - number of sectors to read
  mov ch, 0x00    ; - cylinder number
  mov dh, 0x00    ; - head number
  mov cl, 0x02    ; - sector number
  int 0x13
  jc error

  pop dx

  cmp dh, al
  jne error

  ; Jump to the loader

  jmp 0x1000

set_video_mode:
  mov ah, 0x00    ; BIOS INT 0x10 ah=0x00: Set Video Mode
  mov al, 0x03    ; - video mode 0x03 (80x25 16 color text)
  int 0x10
  ret

print:
  .loop:
    mov al, [si]  ; Character to print
    inc si
    or al, al
    jz .done
    mov ah, 0x0e  ; BIOS INT 0x10 ah=0x0e: Teletype Output
    mov bh, 0x00  ; - page number
    mov bl, 0x07  ; - color
    int 0x10
    jmp .loop
  .done:
    ret

error:
  mov si, ERR
  call print
  jmp halt

halt:
  cli
  hlt
  jmp halt

MSG_LOADING db 'Loading system...', 13, 10, 0
ERR db 'ERROR', 0

times 510 - ($ - $$) db 0
dw 0xaa55
