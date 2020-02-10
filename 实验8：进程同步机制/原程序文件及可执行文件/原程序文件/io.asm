[bits 16]
; I/O 
global _Clear			;清屏至黑底白字
global _Putchar			;光标位置输入,光标跟随移动	
global _Getchar			;光标位置输出,光标跟随移动
global _Setchar			;设置指定位置字符
global _Readchar		;读取指定位置字符
global _Setcolor		;设置指定位置颜色
global _Readcolor		;读取指定位置字符

;funcname : _Putchar
;功能：		输出一个字符
;入口参数： 栈\ax
;出口参数： 无
;说明：     在光标位置输出字符    void Putchar(char cr);
;Esc键会直接返回操作系统内核
;注意：     只由C调用，返回32位地址
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
	retf
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
	retf
backspace:
	mov bh,0
	mov ah,0eh
	int 10h
	mov cx,1
	mov al,' '
	mov ah,0ah
	int 10h
	retf
	
;funcname : _Getchar
;功能：		输入一个字符
;入口参数： 无
;出口参数： al
;说明：     char Getchar();	
;注意：     只由C调用，返回32位地址
_Getchar:	
	xor eax,eax
	mov ah, 1
	int 16h	
	jz _Getchar
	xor eax, eax
	mov ah, 0
	int 16h
	retf
	
;funcname : _Setchar
;功能：		指定位置输出
;入口参数： 栈
;出口参数： 无
;说明：     void Setchar(int x, int y, char cr);
;注意：     只由C调用，返回32位地址
_Setchar:
	mov ax,0B800h
	mov gs,ax
	push bp
	mov bp,sp
	mov ax,[bp+6]
	mov bx,80
	mul bx
	add ax,[bp+10]
	mov bx,2
	mul bx
	mov si,ax
	mov al,[bp+14]	
	mov byte[gs:si],al
	pop bp
	retf	
	
;funcname : _Setcolor
;功能：		设置背景与前景颜色
;入口参数： 栈
;出口参数： 无
;说明：     void Setcolor(int x, int y, int color);
;注意：     只由C调用，返回32位地址
_Setcolor:
	mov ax,0B800h
	mov gs,ax
	push bp
	mov bp,sp
	mov ax,[bp+6]
	mov bx,80
	mul bx
	add ax,[bp+10]
	mov bx,2
	mul bx
	mov si,ax
	mov ax,[bp+14]	
	mov byte[gs:si+1],al
	pop bp
	retf	
	
;funcname : _Readcolor
;功能：		读取背景与前景颜色
;入口参数： 栈
;出口参数： 无
;说明：     int Readcolor(int x, int y);
;注意：     只由C调用，返回32位地址
_Readcolor:
	mov ax,0B800h
	mov gs,ax
	push bp
	mov bp,sp
	mov ax,[bp+6]
	mov bx,80
	mul bx
	add ax,[bp+10]
	mov bx,2
	mul bx
	mov si,ax
	xor eax,eax
	mov al,byte[gs:si+1]
	pop bp
	retf		
	
;funcname : _Readchar
;功能：		读取当前位置字符
;入口参数： 栈
;出口参数： 无
;说明：     char Readchar(int x, int y);
;注意：     只由C调用，返回32位地址
_Readchar:
	mov ax,0B800h
	mov gs,ax
	push bp
	mov bp,sp
	mov ax,[bp+6]
	mov bx,80
	mul bx
	add ax,[bp+10]
	mov bx,2
	mul bx
	mov si,ax
	xor eax,eax
	mov al,byte[gs:si]
	pop bp
	retf

	
;funcname : Clear
;功能：		清屏，黑底白字属性
;入口参数： 栈
;出口参数： 无
;说明：     void Clear(); 
;注意：     只由C调用，返回32位地址	
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
	retf
		