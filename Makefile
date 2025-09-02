# Watcom Makefile for SvarDOS SYS command

!ifdef __MSDOS__
CC = wcl
CFLAGS += -q
!else
! ifdef __NT__
CC = wcl386
CFLAGS += -q
! else
CC = cc
! endif
!endif


!ifdef __UNIX__
DIRLEADER = ./
!endif

sys.exe: sys.obj
	wlink system dos option quiet option map file $<

sys.obj: sys.c fat12com.h fat16com.h fat32chs.h fat32lba.h
	wcc -q -0 -ms -DSVARDOS -DWITHFAT32 -os -fo=sys.obj sys.c

bin2c.exe: bin2c.c
!ifdef __UNIX__
	$(CC) $(CFLAGS) bin2c.c -o $@
!else
	$(CC) $(CFLAGS) $<
!endif
boot/fat12com.bin: boot/boot.asm
	nasm -DISFAT12 -Iboot $< -o $@ -l fat12com.lst

fat12com.h: boot/fat12com.bin bin2c.exe
	$(DIRLEADER)bin2c.exe $[@ $@ fat12com


boot/fat16com.bin: boot/boot.asm
	nasm -DISFAT16 -Iboot $< -o $@

fat16com.h: boot/fat16com.bin bin2c.exe
	$(DIRLEADER)bin2c.exe $[@ $@ fat16com

boot/fat32chs.bin: boot/boot32.asm
	nasm -DQUIET -Iboot $< -o $@

fat32chs.h: boot/fat32chs.bin bin2c.exe
	$(DIRLEADER)bin2c.exe $[@ $@ fat32chs

boot/fat32lba.bin: boot/boot32lb.asm
	nasm -DQUIET -Iboot $< -o $@

fat32lba.h: boot/fat32lba.bin bin2c.exe
	$(DIRLEADER)bin2c.exe $[@ $@ fat32lba


clean: .SYMBOLIC
	rm -f sys.exe
	rm -f sys.obj
	rm -f sys.map
	rm -f fat12com.h
	rm -f fat16com.h
	rm -f fat32chs.h
	rm -f fat32lba.h
	rm -f boot/fat12com.bin
	rm -f boot/fat16com.bin
	rm -f boot/fat32chs.bin
	rm -f boot/fat32lba.bin
	rm -f *.lst
	rm -f bin2c.exe
	rm -f bin2c.obj
	rm -f bin2c.o

