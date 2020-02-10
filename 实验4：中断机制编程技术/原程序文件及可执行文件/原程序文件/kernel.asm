;内核汇编模块
;放置中断服务程序
;
[bits 16]

extern _Kernel

; kernel
global _RunProc			;运行子程序

;中断和系统调用
extern _drawLfUp
extern _drawRtUp
extern _drawLfDn
extern _drawRtDn
extern _Disptime
extern _Shutdown
extern _Restart
extern _changebcolor
extern _changefcolor

Setaddr:
;判断是否初始化了,已设置就跳转
	cmp byte[cs:is_init],1
	jz start
	inc byte[cs:is_init]
;时钟中断响应地址
	xor ax,ax
	mov es,ax
	mov word[es:20h],int_8
	mov word[es:22h],cs
;键盘中断响应地址
	mov ax,word[es:24h]
	mov word[cs:pre_int9_addr],ax	
	mov ax,word[es:26h]
	mov word[cs:pre_int9_addr+2],ax	
	mov word[es:24h],int_9
	mov word[es:26h],cs
;系统调用中断 int_21h,33号中断
	mov ax,word[es:84h]
	mov word[cs:pre_int21h_addr],ax	
	mov ax,word[es:86h]
	mov word[cs:pre_int21h_addr+2],ax	
	mov word[es:84h],int_21h
	mov word[es:86h],cs
;int 34号中断,22h
	mov word[es:88h],int_34		
	mov word[es:8ah],cs
;int 35号中断,23h
	mov word[es:8ch],int_35
	mov word[es:8eh],cs
;int 36号中断,24h
	mov word[es:90h],int_36
	mov word[es:92h],cs
;int 37号中断,25h
	mov word[es:94h],int_37
	mov word[es:96h],cs
	
start:
	;int 34
	;int 35
	;int 36
	;int 37
	xor eax,eax
	mov ax,_Kernel
	call eax
	jmp $
	
;funcname : _RunProc
;功能：		指定位置输出
;入口参数： 栈
;出口参数： 无
;说明：     void RunProc(int id);	
;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
;注意：     只由C调用，返回32位地址
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
	retf
		
;时钟中断响应程序	
;在右下角循环输出字符	
;
Down  equ   1
Right equ   2
Up    equ   3
Left  equ   4
delay equ   2

int_8:
	pushf
	pushad
	cli	
	;计时	
	dec byte[cs:count]
	jnz end_
	mov byte[cs:count], delay
	;移动字符,输出
dic:
	cmp byte[cs:rdul],1
	jz DN
	cmp byte[cs:rdul],2
	jz RT
	cmp byte[cs:rdul],3
	jz UP
	cmp byte[cs:rdul],4
	jz LF
DN:
	inc byte[cs:x]
	cmp byte[cs:x],25
	jnz show
	mov byte[cs:rdul],2
	dec byte[cs:x]
	inc byte[cs:y]
	jmp show
RT:
	inc byte[cs:y]
	cmp byte[cs:y],80
	jnz show
	mov byte[cs:rdul],3
	dec byte[cs:x]
	dec byte[cs:y]
	jmp show
UP:
	dec byte[cs:x]
	cmp byte[cs:x],19
	jnz show
	mov byte[cs:rdul],4
	inc byte[cs:x]
	dec byte[cs:y]
	jmp show
LF:
	dec byte[cs:y]
	cmp byte[cs:y],66
	jnz show
	mov byte[cs:rdul],1
	inc byte[cs:x]
	inc byte[cs:y]
	inc byte[cs:cr]
	cmp byte[cs:cr],123     ;123 = 'z'+1
	jnz show
	mov byte[cs:cr],'a'
	jmp show
show:	
	mov ax, 0b800h
	mov gs, ax
	mov byte[gs:(23*80+72)*2],' '
	mov byte[gs:(23*80+72)*2+1],0fh
	mov byte[gs:(23*80+73)*2],' '
	mov byte[gs:(23*80+73)*2+1],0fh
	mov byte[gs:(23*80+74)*2],' '
	mov byte[gs:(23*80+74)*2+1],0fh
	mov byte[gs:(23*80+75)*2],' '
	mov byte[gs:(23*80+75)*2+1],0fh
	xor ax,ax
	mov al,byte[cs:x]
	mov bx,80
	mul bx
	mov bl,byte[cs:y]
	add ax,bx
	mov bx,2
	mul bx
	mov bx,ax
	mov al,byte[cs:cr]
	mov byte[gs:bx],al	
	inc byte[cs:color]
	cmp byte[cs:color],15
	jnz Clr
	mov byte[cs:color],1
Clr:
	mov al,byte[cs:color]
	mov byte[gs:bx+1],al
end_:
	popad
	popf
	push ax
	mov al,20h			; AL = EOI
	out 20h,al			; 发送EOI到主8529A
	out 0A0h,al			; 发送EOI到从8529A	
	pop ax
	iret

;键盘中断响应程序,int 9
;
int_9:
;调用旧的9号中断
	pushf
	cli
	call far[cs:pre_int9_addr]	
	pushf
	pushad
	push gs
	mov ax,0b800h
	mov gs,ax
	mov byte[gs:(23*80+72)*2],'O'
	mov byte[gs:(23*80+72)*2+1],0fh
	mov byte[gs:(23*80+73)*2],'U'
	mov byte[gs:(23*80+73)*2+1],0fh
	mov byte[gs:(23*80+74)*2],'C'
	mov byte[gs:(23*80+74)*2+1],0fh
	mov byte[gs:(23*80+75)*2],'H'
	mov byte[gs:(23*80+75)*2+1],0fh
	pop gs
	popad
	popf	
	iret
	
;系统调用中断，int_21h，五个功能
;AH 放置功能调用号
;功能一：更新系统时间 disptime       ah = 0
;功能二：改变背景颜色 changebcolor   ah = 1
;功能三：改变字体颜色 changefcolor   ah = 2
;功能四：关机         Shutdown       ah = 3
;功能五：重启		  Restart        ah = 4
int_21h:
	pushf
	pushad
	xor ecx,ecx
	cmp ah,0
	jz int_21h_0
	cmp ah,1
	jz int_21h_1
	cmp ah,2
	jz int_21h_2
	cmp ah,3
	jz int_21h_3
	cmp ah,4
	jz int_21h_4
int_21h_end:
	popad
	popf
	iret
int_21h_0:	
	mov ecx,_Disptime
	call ecx
	jmp int_21h_end
int_21h_1:
	mov ecx,_changebcolor
	call ecx
	jmp int_21h_end
int_21h_2:
	mov ecx,_changefcolor
	call ecx
	jmp int_21h_end
int_21h_3:
	mov ecx,_Shutdown
	call ecx
	jmp int_21h_end
int_21h_4:	
	mov ecx,_Restart
	call ecx
	jmp int_21h_end	

;int 34
int_34:
	pushf
	pushad
	cli
	xor eax,eax
	mov ax,_drawLfUp
	call eax	
	popad
	popf
	iret
;int 35
int_35:
	pushf
	pushad
	cli
	xor eax,eax
	mov ax,_drawRtUp
	call eax	
	popad
	popf
	iret
;int 36
int_36:
	pushf
	pushad
	cli 
	xor eax,eax
	mov ax,_drawLfDn
	call eax	
	popad
	popf
	iret
;int 37
int_37:
	pushf
	pushad
	cli
	xor eax,eax
	mov ax,_drawRtDn
	call eax	
	popad
	popf
	iret
;data section
datadef:
is_init        		   db        0
count 		   		   db  	     4	
color 		  		   db        1
cr 	  	  	  	   	   db   	 'a'
x  	  	 	   		   db  	     20
y  	  	 	   		   db	     67
rdul  		  		   db        1
pre_int9_addr 		   dw        0,0
pre_int21h_addr        dw        0,0