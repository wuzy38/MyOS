nasm -f elf32 process4.asm -o process4a.o
nasm -f elf32 io.asm -o ioa.o
nasm -f elf32 time.asm -o timea.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c process4.c -o process4c.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c io.c -o ioc.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c time.c -o timec.o
ld -m i386pe -N process4a.o process4c.o ioa.o ioc.o timea.o timec.o -T process4.txt -o temp.tmp
objcopy -O binary temp.tmp process4.bin
dd if=process4.bin of=pro8.img bs=512 seek=48 count=4