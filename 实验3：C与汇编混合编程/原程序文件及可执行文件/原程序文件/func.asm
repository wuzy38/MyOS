;汇编函数模块
;实现部分共用函数
;
;注意输入几个功能键的响应
[bits 16]
global _Putchar
global _Getchar

global _Clear

global _RunProc
;global _Setchar
;global _Getkey


;funcname : _Putchar
;功能：		输出一个字符
;入口参数： 栈\ax
;出口参数： 无
;说明：     在光标位置输出字符    void Putchar(char cr);
;Esc键会直接返回操作系统内核
[section .text]
_Putchar:
	push bp
	mov bp,sp
	mov ax,[bp+6]	
	pop bp
	mov bh,0		;页号
	cmp al,1bh		;判断Esc键，返回操作系统内核
	jz Esc_key
	cmp al,0dh      ;判断换行
	jz Enter_key
	cmp al,08h	;
	jz backspace	
	mov ah,0eh
	int 10h		
	ret
Esc_key:
	jmp 0x8100
Enter_key:
	mov bh,0
	mov ah,3
	int 10h
	inc dh
	mov dl,00h
	mov ah,2
	int 10h
	ret
backspace:
	mov bh,0
	mov ah,0eh
	int 10h
	mov cx,1
	mov al,' '
	mov ah,0ah
	int 10h
	ret
	
;funcname : _Getchar
;功能：		输入一个字符
;入口参数： 无
;出口参数： al
;说明：     char Getchar();	
_Getchar:	
	xor eax,eax
	mov ah,0
	int 16h	
	ret
	
;funcname : Clear
;功能：		清屏
;入口参数： 栈
;出口参数： 无
;说明：     void Clear();	
_Clear:	
	mov cx,0
	mov dh,24
	mov dl,79
	mov ax,0600h
	mov bh,07h
	int 10h	
	mov bh,0
	mov dx,0
	mov ah,2
	int 10h
	ret
	
;funcname : _RunProc
;功能：		指定位置输出
;入口参数： 栈
;出口参数： 无
;说明：     void RunProc(int id);	
;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
_RunProc:
	push bp
	mov bp,sp
	mov ax,[bp+6]
	pop bp
	mov bl,2
	div bl
	mov dh,ah                ;磁头号 ; 起始编号为0/1  ax mod 2?
	mov ch,al                ;柱面号 ; 起始编号为0 /1 /2   ax / 2?	
	mov ax,cs                ;段地址 ; 存放数据的内存基地址	    mov ax,0
	mov es,ax                ;设置段地址（不能直接mov es,段地址）0？
	mov bx,0A100h	         ;偏移地址; 存放数据的内存偏移地址
	mov ah,2                 ;功能号
	mov al,16                ;扇区数
	mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H	
	mov cl,1                 ;起始扇区号 ; 起始编号为1
	int 13H ;                调用读磁盘BIOS的13h功能
	jmp 0A100h
	ret
	
	
;funcname : _Getkey
;功能：		获取一个按键输入
;入口参数： 无
;出口参数： (e)ax
;说明：     int Getkey();
;_Getkey:	
;	xor eax,eax
;	mov ah,0
;	int 16h	
;	ret

	
;funcname : _Setchar
;功能：		指定位置输出
;入口参数： 栈
;出口参数： 无
;说明：     void Setchar(int x, int y, char cr);
;_Setchar:
;	mov ax,0B800h
;	mov gs,ax
;	push bp
;	mov bp,sp
;	mov ax,[bp+6]
;	mov bx,80
;	mul bx
;	add ax,[bp+10]
;	mov bx,2
;	mul bx
;	mov si,ax
;	mov al,[bp+14]
;	pop bp
;	mov byte[gs:si],al
;	mov byte[gs:si+1],07h
;	ret