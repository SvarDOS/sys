# Watcom Makefile for SvarDOS SYS command

CC = wcc
CFLAGS = -q -0 -ms -ox -DSVARDOS -DWITHFAT32 -DFORSYS 
NASM = nasm
NASMFLAGS = -DQUIET -Iboot

!ifdef __MSDOS__
HOST_CC = wcl
HOST_CFLAGS = -q
!else
! ifdef __NT__
HOST_CC = wcl386
HOST_CFLAGS = -q
! else
HOST_CC = cc
! endif
!endif


!ifdef __UNIX__
DIRLEADER = ./
!endif

.erase

sys.com: sys.obj prf.obj talloc.obj
	wlink name sys.com system dos option quiet option map file sys.obj,prf.obj,talloc.obj

.c.obj: .AUTODEPEND
	$(CC) $(CFLAGS) -i=boot -fo=$*.obj $*.c

sys.obj: sys.c boot/fat12com.h boot/fat16com.h boot/fat32chs.h boot/fat32lba.h


# utilities

bin2c.exe: bin2c.c
!ifdef __UNIX__
	$(HOST_CC) $(HOST_CFLAGS) bin2c.c -o $@
!else
	$(HOST_CC) $(HOST_CFLAGS) $<
!endif


# bootsectors

boot/fat12com.bin: boot/boot.asm
	$(NASM) $(NASMFLAGS) -DISFAT12 $< -o $@ -l $*.lst

boot/fat12com.h: boot/fat12com.bin bin2c.exe
	$(DIRLEADER)bin2c.exe $[@ $@ fat12com

boot/fat16com.bin: boot/boot.asm
	$(NASM) $(NASMFLAGS) -DISFAT16 $< -o $@ -l $*.lst

boot/fat16com.h: boot/fat16com.bin bin2c.exe
	$(DIRLEADER)bin2c.exe $[@ $@ fat16com

boot/fat32chs.bin: boot/boot32.asm
	$(NASM) $(NASMFLAGS) $< -o $@ -l $*.lst

boot/fat32chs.h: boot/fat32chs.bin bin2c.exe
	$(DIRLEADER)bin2c.exe $[@ $@ fat32chs

boot/fat32lba.bin: boot/boot32lb.asm
	$(NASM) $(NASMFLAGS) $< -o $@ -l $*.lst

boot/fat32lba.h: boot/fat32lba.bin bin2c.exe
	$(DIRLEADER)bin2c.exe $[@ $@ fat32lba


clean: .SYMBOLIC
	rm -f *.exe
	rm -f *.com
	rm -f *.obj
	rm -f *.o
	rm -f *.map
	rm -f boot/*.h
	rm -f boot/*.bin
	rm -f boot/*.lst

