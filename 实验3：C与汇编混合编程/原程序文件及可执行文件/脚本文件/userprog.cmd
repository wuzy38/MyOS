gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c tabletennis.c -o ctabletennis.o
nasm -f elf32 tabletennis.asm -o atabletennis.o
ld -m i386pe -N atabletennis.o ctabletennis.o -Ttext 0xA100 -o tabletennis.tmp
objcopy -O binary tabletennis.tmp tabletennis.bin

gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c calculator.c -o calculator.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c func.c -o cfunc.o
nasm -f elf32 func.asm -o afunc.o
ld -m i386pe -N calculator.o cfunc.o afunc.o -Ttext 0xA100 -o calculator.tmp
objcopy -O binary calculator.tmp calculator.bin

gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c text_editor.c -o text_editor.o
gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c func.c -o cfunc.o
nasm -f elf32 func.asm -o afunc.o
ld -m i386pe -N text_editor.o cfunc.o afunc.o -Ttext 0xA100 -o text_editor.tmp
objcopy -O binary text_editor.tmp text_editor.bin

nasm information.asm -o information.bin