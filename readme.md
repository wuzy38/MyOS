# MyOS
从零开始设计一个操作系统，并运行在裸机上。

整个项目分为多个实验，每个实验都可以独立执行，每个实验在前一个实验的基础上添加了新的特性，形成一个更完善的OS。



-----

## 实验环境
### 工具
- 虚拟机：VMware  
- 编译链：nasm + gcc + ld  
- 映像文件制作工具：dd命令  
- 映像文件读写工具：winhex 或 dd命令

### 安装OS过程
#### 1. VMware创建裸机
```
① 新建虚拟机 (典型)
② 选择"稍后安装操作系统"
③ 选择"其他"操作系统以及"MD-DOS"版本  
④ 添加软盘驱动器 (使用软盘映像文件)  
```

#### 2. 生成映像文件
```
① dd命令制作映像文件。  
② 编译程序，生成二进制文件。  
③ winhex或dd命令将二进制文件写入映像文件。   
④ 将该映像文件设置为虚拟机的软盘映像文件。  
```

#### 关于dd命令  
- 制作映像文件：  
```dd if=/dev/zero of=disk.img bs=512 count=2880```  
生成一个由"2880个大小为512字节的块"组成的"空白"(0值字节)文件，即1.44MB大小 
- 将二进制文件写入映像文件：  
```dd if=kernel.bin of=disk.img bs=512 seek=1 count=16```  
将二进制文件的前16个块(块大小512B)写入到映像文件第1个块(从0开始)的起始地址

### 编译 
#### 编译环境
- 安装gcc，nasm，ld并添加到环境变量。
- 或将Tools文件夹添加到环境变量中，便可编译汇编程序，C程序，并且进行链接。
- 或将原程序文件放到Tools文件夹下进行编译链接。

#### 编译命令
- nasm直接汇编生成二进制文件：nasm boot.asm -o boot.bin  
- C与汇编混合编程(见实验3)：使用 gcc 编译 C 程序生成.o文件，使用 nasm 汇编 x86 程序生成.o文件，使用 ld 将.o文件进行链接生成.tmp文件，使用 objcopy 命令将.tmp文件复制成.bin文件。

-----

## 实验内容

### 实验1：接管裸机的控制权
设计引导程序，使用裸机加载并执行引导程序。

了解电脑启动过程。

### 实验2：加载用户程序的监控程序
以引导程序为监控程序，实现对用户程序的加载控制。主要利用了BIOS的中断功能(BIOS的13H中断读扇区到内存)
- 实现4个有输出的用户程序。
- 设计引导程序，用于将用户程序加载到指定内存位置，并跳转该程序。(实现OS运行用户程序的功能)

### ** 实验3：C与汇编混合编程
- 将引导程序与内核程序分离，为扩展内核提供发展空间。(引导程序只负责加载内核)
- 添加C的元素，使用汇编与C混合编程技术，提高程序的表达能力。

### * 实验4：中断机制编程技术
- 掌握实模式硬件中断系统原理和中断服务程序设计方法。实现对时钟、键盘/鼠标等硬件**中断**的简单服务**处理程序编程**和调试。
- 掌握操作系统的系统调用原理。**实现系统调用框架**，提供若干简单功能的系统调用。
- 掌握 C 语言库的设计方法，为自己的原型操作系统配套一个 C 程序开发环境

### 实验6：二状态多进程
- 实现多进程的二状态模型，维护进程控制块。
- 设计时间片轮转调度过程，实现多进程并发机制。

### 实验7：进程控制和通信
- 实现五状态进程模型
- 实现父子进程的通信(共享内存)

### 实验8：进程同步机制
- 设计信号量机制
- 模拟生产者消费者问题