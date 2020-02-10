nasm -f elf32 process1.asm -o process1a.o
nasm -f elf32 io.asm -o ioa.o
nasm -f elf32 time.asm -o timea.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c process1.c -o process1c.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c io.c -o ioc.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c time.c -o timec.o
ld -m i386pe -N process1a.o process1c.o ioa.o ioc.o timea.o timec.o -T process1.txt -o temp.tmp
objcopy -O binary temp.tmp process1.bin
dd if=process1.bin of=pro8.img bs=512 seek=36 count=4