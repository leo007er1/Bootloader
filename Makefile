
# https://wiki.osdev.org/GNU-EFI

override buildDir := Build
override gnuEfi := gnu-efi

cFlags ?= -I Include/ -I $(gnuEfi)/inc/ -fpic -ffreestanding -fno-stack-protector -fno-stack-check -mno-red-zone -fshort-wchar \
-maccumulate-outgoing-args

# We use the already existent gnu-efi linker script
ldFlags ?= -shared -Bsymbolic -L$(gnuEfi)/x86_64/lib -L$(gnuEfi)/x86_64/gnuefi -T$(gnuEfi)/gnuefi/elf_x86_64_efi.lds \
$(gnuEfi)/x86_64/gnuefi/crt0-efi-x86_64.o $(buildDir)/Boot.o -o $(buildDir)/BOOTX64.so -lgnuefi -lefi

objcopyFlags ?= -j .text -j .sdata -j .data -j .rodata -j .dynamic -j .dynsym  -j .rel -j .rela -j .rel.* -j .rela.* -j .reloc \
--target efi-app-x86_64 --subsystem=10


all: main

.PHONY: main
main:
	gcc $(cFlags) -c Boot/Boot.c -o $(buildDir)/Boot.o
	ld $(ldFlags)
	objcopy $(objcopyFlags) $(buildDir)/BOOTX64.so $(buildDir)/BOOTX64.EFI

	sudo losetup -o 1048576 --sizelimit 8388608 -f BootImage.dd
	mkfs.vfat -F 32 -n "EFI System" /dev/loop1
	sudo mount /dev/loop1 $(buildDir)/Mount
	mkdir -p $(buildDir)/Mount/EFI/BOOT/
	cp $(buildDir)/BOOTX64.EFI $(buildDir)/Mount/EFI/BOOT
	sudo umount $(buildDir)/Mount
	sudo losetup -d /dev/loop1


.PHONY: run clean
run:
	qemu-system-x86_64 -L OVMF/ -pflash OVMF.fd


clean:
	rm -rf $(buildDir)/*
	mkdir -p $(buildDir)/Mount/