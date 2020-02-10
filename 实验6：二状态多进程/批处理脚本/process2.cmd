nasm -f elf32 process2.asm -o process2a.o
nasm -f elf32 io.asm -o ioa.o
nasm -f elf32 time.asm -o timea.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c process2.c -o process2c.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c io.c -o ioc.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c time.c -o timec.o
ld -m i386pe -N process2a.o process2c.o ioa.o ioc.o timea.o timec.o -T process2.txt -o temp.tmp
objcopy -O binary temp.tmp process2.bin
dd if=process2.bin of=pro6.img bs=512 seek=40 count=4