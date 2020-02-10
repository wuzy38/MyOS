gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c kernel.c -o kernel.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c func.c -o cfunc.o
nasm -f elf32 func.asm -o afunc.o
ld -m i386pe -N kernel.o cfunc.o afunc.o -T linkerscript.txt -o kernel.tmp
objcopy -O binary kernel.tmp kernel.bin
