nasm -f elf32 io.asm -o ioa.o
nasm -f elf32 time.asm -o timea.o
nasm -f elf32 stdlib.asm -o stdliba.o
nasm -f elf32 kernel.asm -o kernela.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c io.c -o ioc.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c time.c -o timec.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c stdlib.c -o stdlibc.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c string.c -o stringc.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c kernel.c -o kernelc.o
ld -m i386pe -N kernela.o kernelc.o ioa.o ioc.o timea.o timec.o stdliba.o stdlibc.o stringc.o -T kernel.txt -o temp.tmp
objcopy -O binary temp.tmp kernel.bin
dd if=kernel.bin of=pro8.img bs=512 seek=1 count=35