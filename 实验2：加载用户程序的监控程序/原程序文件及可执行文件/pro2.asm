;程序源代码（myos1.asm）
		; BIOS将把引导扇区加载到0:7C00h处，并开始执行
		; 四个用户程序分别加载到如下四个地址
OffSetOfUserPrg1 equ 8100h
OffSetOfUserPrg2 equ 8300h
OffSetOfUserPrg3 equ 8500h
OffSetOfUserPrg4 equ 8700h
org  7c00h
Start:
	mov	ax, cs	       ; 置其他段寄存器值与CS相同
	mov	ds, ax	       ; 数据段
	mov	es, ax		 ; 置ES=DS
	mov	bp, Message		 ; BP=当前串的偏移地址
	mov	cx, MessageLength  ; CX = 串长（=9）
	mov	ax, 1301h		 ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	bx, 0007h		 ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 0000h		 ; 行号=0, 列号=0 
	int	10h			 ; BIOS的10h功能：显示一行字符
LoadnEx:
     ;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
      mov ax,cs                ;段地址 ; 存放数据的内存基地址
      mov es,ax                ;设置段地址（不能直接mov es,段地址）
      mov bx, OffSetOfUserPrg1  ;偏移地址; 存放数据的内存偏移地址
      mov ah,2                 ;功能号
      mov al,4                 ;扇区数
      mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
      mov dh,0                 ;磁头号 ; 起始编号为0
      mov ch,0                 ;柱面号 ; 起始编号为0
      mov cl,2                 ;起始扇区号 ; 起始编号为1
      int 13H ;                调用读磁盘BIOS的13h功能
      ; 用户程序a.com已加载到指定内存区域中
	  mov ah,0
	  int 16H
	  cmp al,49
	  jz OffSetOfUserPrg1
	  cmp al,50
	  jz OffSetOfUserPrg2
	  cmp al,51
	  jz OffSetOfUserPrg3
	  cmp al,52
	  jz OffSetOfUserPrg4
AfterRun:
      jmp $                      ;无限循环
Message:
      db 'Xx XxXx  0000000000  input 1/2/3/4 to select app and input q to exit app'

MessageLength  equ ($-Message)
      times 510-($-$$) db 0
      db 0x55,0xaa
