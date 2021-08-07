# 实验3：C与汇编混合编程

## 一. 实验目的
- 把原来在引导扇区中实现的监控程序(内核)分离成一个独立的执行体，方便后续扩展功能。
- 学习**汇编与 C 混合编程技术**。

## 二. 实验要求
- **监控程序(内核)以独立的可执行程序实现**。引导程序 加载 监控程序(内核)；监控程序(内核) 加载 用户程序；
- 使用"汇编与 C 混合编程技术"，扩展监控程序命令处理能力。

## 三. 相关原理 (汇编与 C 混合编程)
### 【文件头注意点】
使用 16 位代码：
- 汇编模块开头加 ```[bits 16]``` 
- C 程序模块开头加```__asm__(".code16gcc")```
### 【符号与变量引用规则】
- 汇编文件引用 C 文件中的变量和函数名，需要在前面加下划线。C 文件中的变量和函数在编译后，前面都加了下划线，所以汇编文件中引用 C 文件中的变量和函数名时，要加下划线；
- C 文件引用汇编文件中变量和函数名。汇编文件中变量名和函数名前面要事先加下刬线，C 文件中才能在引用时去掉下划线。

### 【 函数调用参数传递与栈操作】
#### 汇编模块中调用C模块中的函数：
- (汇编模块中)需要先用extern声明C模块的函数。 
- 根据C函数原型，用栈传递参数，调用C函数时按后面参数先进栈的顺序压栈。
- C函数的返回值从eax寄存器中获取。
- 调用C函数后，要将栈中参数弹出。
- 进栈出栈以4字节为单位。

#### C模块中调用汇编模块中的过程和变量引用：
- 汇编模块中要先用global声明这些符号。
- 汇编模块中的过程从栈中取得参数，不必出栈，直接引用栈中的值，顺序与C进栈对应。
- 返回值需要放置在eax寄存器才能被C模块使用。
- 不确定 (C 模块中需要声明汇编模块中相应的过程和变量引用。)

### 【 Call 指令与 ret 指令具体操作】：
(忘记来源是哪了)
- call指令的具体操作 (压栈保存ip，ip跳转)
```x86asm
sp      sp-2
[sp]    ip
ip      ip+disp
```
- ret指令的具体操作 (取ip，退栈)
```x86asm
ip      [sp]
sp      sp+2
```

### 【扇区在磁盘中的位置】：
一个磁道有18个扇区。由于BIOS无法跨磁道读扇区，对扇区的位置以磁头，柱面做了区分。对第q个扇区。它在磁盘中的位置计算方法为：
```
磁头 = (q/18) % 2
柱面号 = (q/18) / 2
扇区起始号 = q % 18 + 1
```

### 【使用BIOS的10h输出中断】：
<div align=center>
<img src="figure/10H_a.png"/>
<img src="figure/10H_b.png"/>
</div>

## 四. 实验方案

### 汇编与 C 混合编译
#### 工具链
- GCC 编译器
- NASM 汇编器
- LD 链接器

#### 混合编译过程
使用 gcc 编译 C 程序生成 .o 文件，使用 nasm 汇编 x86 程序生成 .o 文件，使用 ld 将 .o 文件进行链接生成 .tmp 文件，使用 objcopy 命令将 .tmp 文件复制成 .bin 文件。

#### 混合编译命令
- GCC 编译命令(file.c 编译成 cfile.o)
    ```bash
    gcc -march=i386 -m32 -mpreferred-stack-boundary=2 -ffreestanding -c file.c -o cfile.o
    ```
- NASM 汇编命令(file.asm 编译成 afile.o)
    ```bash
    nasm -f elf32 file.asm -o afile.o
    ```
- LD 链接命令(链接 afile.o 与 cfile.o 为临时文件 kernel.tmp，程序("text"表示代码段)将被加载到内存 0x8100)
    ```bash
    ld -m i386pe -N afile.o cfile.o -Ttext 0x8100 -o kernel.tmp
    ```
	也可以使用脚本文件表示各个段的内存位置，如下。
	```bash
	ld -m i386pe -N kernel.o cfunc.o afunc.o -T linkerscript.txt -o kernel.tmp
	```
	其中linkerscript.txt的内容如下，表示代码段的内存位置是0x8100，数据段的内存位置为0x9100。
	```bash
	SECTIONS
	{
		. = 0x8100;
		.text : { *(.text) }
		. = 0x9100;
		.data : { *(.data) }
		.rdata : { *(.rdara) }
		.bss : { *(.bss) }
	}
	```

- objcopy 命令(将.tmp 文件复制成.bin 文件)
    ```bash
    objcopy -O binary kernel.tmp kernel.bin
    ```



### 程序流程
BIOS自举装载程序加载引导扇区到内存，跳转到引导程序运行，引导程序加载监控程序(内核)到内存，跳转到监控程序(内核)运行。  
内核程序相当于一个控制台。在内核程序中，可以输入命令，了解程序的使用方法、了解当前的用户程序、也可以加载子程序到内存并运行。  

**利用 C 初步建立函数库**。在汇编模块中实现输入输出，读取内存，读取扇区等基本函数。在C中以这几个函数为基础构建出更多常用的函数。这些函数构成函数库供其他程序调用。(问题：全都集成到一个函数库的话，会使这个文件变大，导致调用它的用户程序变得很大。所以应该按功能划分成多个函数库。)

### 文档清单
```bash
:.
│  C与汇编混合编程 的 编译链接方法.txt
│  readme.md
│  实验报告3.pdf
│
├─figure
│      10H_a.png
│      10H_b.png
│
├─原程序文件及可执行文件
│  ├─原程序文件
│  │      boot.asm				# 引导程序
│  │      calculator.c			# 子程序
│  │      func.asm				# 函数模块
│  │      func.c				# 函数模块
│  │      func.h				# 函数模块
│  │      information.asm		# 子程序
│  │      kernel.c				# 内核
│  │      tabletennis.asm		# 子程序1的汇编模块
│  │      tabletennis.c			# 子程序1的C模块
│  │      text_editor.c			# 子程序
│  │
│  ├─可执行文件
│  │      boot.bin
│  │      calculator.bin
│  │      information.bin
│  │      kernel.bin
│  │      tabletennis.bin
│  │      text_editor.bin
│  │
│  └─脚本文件
│          kernel.cmd			# 内核编译命令脚本
│          linkerscript.txt		# 内核段地址
│          userprog.cmd			# 4个子程序的编译命令脚本
│
└─虚拟机软盘映像文件
        disk.img				# 软盘
```

### 关键模块
#### 用户程序tabletennis的部分(反应了汇编与C的混合编程)
C模块中调用了汇编模块中的 ``` _Setchar ``` 过程；汇编模块中调用了C模块中的 ``` Gamestart() ``` 函数。```Setchar(int x, int y, char cr)``` 是有参数的，可以看到汇编过程中使用形参的方法。    
(没完全理解好奇汇编调用汇编的过程是怎样的)
- C 模块
```c
//第一个子程序C函数部分：tabletennis
__asm__(".code16gcc");
void Setchar(int x, int y, char cr);
int Getkey();               //可以不用声明
int left[2] = {2,5};
int right[2] = {2,5};
void Gamestart()
{
	int i;
	for(i = left[0]; i <= left[1]; i++)
	{
		Setchar(i, 0, '8');
	}
	for(i = right[0]; i <= right[1]; i++)
	{
		Setchar(i, 79, '8');
	}	
}

......
```
- 汇编模块
```x86asm
; 第一个用户子程序 ：tabletennis
[bits 16]
extern _Move
extern _Gamestart
global _Setchar
global _Getkey
......
start:
	xor eax,eax
	mov ax,_Gamestart
	call eax					; 因为调用C程序返回时，栈会弹回32位，所以压栈也要压32位
......
;funcname : _Setchar
;功能：		屏幕指定位置(x行y列)输出字符
;入口参数： 栈
;出口参数： 无
;说明：     void Setchar(int x, int y, char cr);
_Setchar:
	mov ax,0B800h
	mov gs,ax
	push bp                     ; 保护bp中的值. (栈底指针？保存上一调用的栈底？)
	mov bp,sp
	mov ax,[bp+6]               ; x (猜测：bp寄存器16位2B，C调用函数压了4B地址，所以偏移了6B.)
	mov bx,80
	mul bx
	add ax,[bp+10]              ; y
	mov bx,2
	mul bx
	mov si,ax
	mov al,[bp+14]              ; cr
	pop bp                      ; 
	mov byte[gs:si],al
	mov byte[gs:si+1],07h
	ret
```



-----

## 其他
### 【磁盘和内存安排方案】：
- 主引导程序放于磁盘第 1 个扇区，即引导扇区。将被自动加载到主存 07c00H ~ 07dffH。
- 内核程序存放于磁盘第 2 到第 17 个扇区，共 16 个扇区。由引导程序加载 08100H 开始的内存空间，即主存 08100H ~ 0a0ffH。
- 4 个用户子程序分别存放于磁盘 19~36,37~54,55~72,73~90 号扇区；每个子程序都占 16 个扇区。在执行时都由内核加载到 0a100H 开始的内存空间，即主存 0a100H ~ 0c0ffH。

### 遇到的问题及解决情况
#### 【从汇编模块调用 C 模块的函数时，不能用 call 函数名】
call function会将IP压入2位的栈，而C函数返回时，会弹出4位至eip中。因此会改变
了栈顶里的值。破坏了数据结构。而从C调用汇编时，由于栈是以地址降低的方向增大的并且x86的存储方式是是高高低低，即低位放低地址。所以虽然C压了eip的四位地址入栈， 但弹时把eip的低2位返回到ip中，使得ip的值没有改变，并且没有破坏栈里的数据，所以没问题。解决方法是在汇编中调用C函数时，使用如下代码。
```x86asm
xor eax,eax
mov ax,_funcname
call eax
```
#### 【链接时，文件放置的顺序不同会导致最后生成的执行文件不同】
哪个文件在前面，链接出来的程序，从哪个文件开始执行。(具体见实验报告)

#### 【链接时直接指定内存地址导致生成的文件过大】
即 ```-Ttext``` ，通过自己安排代码段和数据段的位置，控制占用空间大小，即linkerscript.txt文件中指定各个段位置。(具体见实验报告)