CC=gcc
LD=ld
NASM=nasm
RM=rm
DD=dd
OBJCOPY=objcopy
QEMU=qemu-system-x86_64

CFLAGS=-g -c -m64 -masm=intel -ffreestanding
LFLAGS=-melf_x86_64 -n -Ttext=0x1000
QEMUFLAGS=-fda

OBJS=\
	loader.o \
	main.o \
	vga.o \
	io.o \
	string.o
ELFS=kernel.elf
BINS=mbr.bin kernel.bin

TARGET=jos.img

mbr.bin: src/boot/mbr.asm
	$(NASM) -f bin -o $@ $<

loader.o: src/boot/loader.asm
	$(NASM) -f elf64 -o $@ $<

main.o: src/kernel/main.c
	$(CC) $(CFLAGS) -o $@ $<

vga.o: src/kernel/vga.c
	$(CC) $(CFLAGS) -o $@ $<

io.o: src/kernel/io.c
	$(CC) $(CFLAGS) -o $@ $<

string.o: src/kernel/string.c
	$(CC) $(CFLAGS) -o $@ $<

kernel.elf: $(OBJS)
	$(LD) $(LFLAGS) -o $@ $^

kernel.bin: $(ELFS)
	$(OBJCOPY) -O binary $^ $@

$(TARGET): $(BINS)
	$(DD) if=/dev/zero of=$@ bs=512 count=2880
	$(DD) if=mbr.bin of=$@ bs=512 conv=notrunc
	$(DD) if=kernel.bin of=$@ bs=512 seek=1 conv=notrunc

run: $(TARGET)
	$(QEMU) $(QEMUFLAGS) $<

clean:
	$(RM) $(OBJS) $(ELFS) $(BINS) $(TARGET)
