; loader.asm - Kernel loader for JOS
; Copyright (C) 2018 Jari Jokinen

section .text
global _start
bits 16

_start:
  lgdt [gdt32]

  mov eax, cr0              ; Enable protected mode
  or al, 1
  mov cr0, eax

  jmp 0x0008:protected_mode

bits 32

protected_mode:
  mov ax, 0x0010            ; Reload segment registers
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  ; Initialize stack

  mov ss, ax
  mov sp, 0x7c0

  mov ebx, MSG_PROTECTED_MODE_ENABLED
  call print

  cld                       ; Build paging tables at 0x9000
  mov edi, 0x9000

  push edi                  ; Zero out 4 * 4096 bytes = 16 KiB free space
  mov ecx, 0x1000
  xor eax, eax
  cld
  rep stosd
  pop edi

  lea eax, [edi + 0x1000]   ; PML4 Table
  or eax, 11b
  mov [edi], eax

  lea eax, [edi + 0x2000]   ; Page-Directory-Pointer Table
  or eax, 11b
  mov [edi + 0x1000], eax

  lea eax, [edi + 0x3000]   ; Page Directory
  or eax, 11b
  mov [edi + 0x2000], eax

  push edi                  ; Page Table
  lea edi, [edi + 0x3000]
  mov eax, 11b
  .build_pt:                ; identity map the first 2 MiB of our memory
    mov [edi], eax          ; 0x00000000-0x00000FFF
    add eax, 0x1000
    add edi, 8
    cmp eax, 0x200000
    jb .build_pt
  pop edi

  mov eax, 0x9000           ; Store PML4 physical address in CR3
  mov cr3, eax

  mov eax, cr4              ; Enable PSE and PAE
  or eax, 1 << 4
  or eax, 1 << 5
  mov cr4, eax

  mov ecx, 0xc0000080       ; Enable long mode
  rdmsr
  or eax, 1 << 8
  wrmsr

  mov eax, cr0              ; Enable 4-level paging
  or eax, 1 << 31
  mov cr0, eax

  lgdt [gdt64]
  jmp 0x0008:long_mode

print:
  push eax
  push ebx
  push edx

  mov edx, 0xb8000

  .loop:
    mov al, [ebx]
    mov ah, 0x0f
    cmp al, 0
    je .done
    mov [edx], ax
    add ebx, 1
    add edx, 2
    jmp .loop

  .done:
    pop edx
    pop ebx
    pop eax
    ret

bits 64

extern kmain

long_mode:
  call kmain

section .data

; Global Descriptor Table for protected mode

gdt32_base:
  dd 0
  dd 0
  dw 0xffff
  dw 0x0000
  db 0x00
  db 10011010b
  db 11001111b
  db 0x00
  dw 0xffff
  dw 0x0000
  db 0x00
  db 10010010b
  db 11001111b
  db 0x00

gdt32:
  dw gdt32 - gdt32_base - 1
  dd gdt32_base

; Global Descriptor Table for long mode

gdt64_base:
  dq 0
  .code: equ $ - gdt64
    dq (1 << 44) | (1 << 47) | (1 << 41) | (1 << 43) | (1 << 53)
  .data: equ $ - gdt64
    dq (1 << 44) | (1 << 47) | (1 << 41)

gdt64:
  dw gdt64 - gdt64_base - 1
  dq gdt64_base

section .rodata

MSG_ENTERING_PROTECTED_MODE db "Entering protected mode...", 13, 10, 0
MSG_PROTECTED_MODE_ENABLED db "Protected mode enabled", 0
ERR db "ERROR", 0
