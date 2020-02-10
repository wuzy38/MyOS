nasm -f elf32 process3.asm -o process3a.o
nasm -f elf32 io.asm -o ioa.o
nasm -f elf32 time.asm -o timea.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c process3.c -o process3c.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c io.c -o ioc.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c time.c -o timec.o
ld -m i386pe -N process3a.o process3c.o ioa.o ioc.o timea.o timec.o -T process3.txt -o temp.tmp
objcopy -O binary temp.tmp process3.bin
dd if=process3.bin of=pro6.img bs=512 seek=44 count=4