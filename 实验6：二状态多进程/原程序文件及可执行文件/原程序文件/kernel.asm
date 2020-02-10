;内核汇编模块
;放置中断服务程序
;
[bits 16]

extern _Kernel
extern _func1
extern _getnextproc
; kernel
global _InstallProc		;加载子程序
global _setrunningproc	;设置运行程序
global _RunProc			;运行子程序
;中断和系统调用
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
	
start:
	;int 34
	;int 35
	;int 36
	;int 37
	;自己的栈
	mov ax,cs
	mov word[cs:kernel_ss], ax
	mov word[cs:kernel_sp], temp_stack
	mov ax,cs
	mov ss,ax
	mov sp,stack
	mov word[cs:cs_save], 0
	mov word[cs:cs_save+2], 0
	mov word[cs:cs_save+4], 0
	mov word[cs:cs_save+6], 0
	mov word[cs:cs_save+8], 0
	mov word[cs:ip_save], 0x8100
	mov word[cs:ip_save+2], 0x1000
	mov word[cs:ip_save+4], 0x2000
	mov word[cs:ip_save+6], 0x3000
	mov word[cs:ip_save+8], 0x4000
	mov byte[cs:a_running_proc], 0
	xor eax,eax
	mov ax,_Kernel
	call eax
	jmp $
	
;funcname : _InstallProc
;功能：		安装子程序到指定位置
;入口参数： 栈
;出口参数： 无
;说明：     void InstallProc(int heads, int cylinder, int sector, int nums, int offset);	
;读软盘或硬盘上的若干物理扇区到内存的ES:BX处
;注意：     只由C调用，返回32位地址
_InstallProc:
	push bp
	mov bp,sp
	mov dh,byte[bp+6]                 ;磁头号 ; 起始编号为0/1  ax mod 2?
	mov ch,byte[bp+10]                ;柱面号 ; 起始编号为0 /1 /2   ax / 2?	
	mov cl,byte[bp+14]                ;起始扇区号 ; 起始编号为1
	mov dl,0                          ;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov ax,cs                         ;段地址 ; 存放数据的内存基地址  mov ax,0
	mov es,ax                         ;设置段地址（不能直接mov es,段地址）0？
	mov bx,word[bp+22]	              ;偏移地址; 存放数据的内存偏移地址
	mov ah,2                          ;功能号
	mov al,byte[bp+18]                ;扇区数	
	int 13H ;                调用读磁盘BIOS的13h功能
	pop bp
	retf

;funcname : _RunProc
;功能：		运行子程序
;入口参数： 栈
;出口参数： 无
;说明：     void RunProc(int offset);
;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
;注意：     只由C调用，返回32位地址
_RunProc:
	push bp
	mov bp,sp
	mov bx,[bp+6]
	pop bp
	mov ax, cs
	mov ss, ax
	mov sp, word[cs:temp_stack]
	mov byte[cs:a_running_proc], 5
	jmp bx
	retf

;setrunningproc(int num)
_setrunningproc:	
	push bp
	mov bp,sp
	mov bx,[bp+6]
	pop bp
	mov byte[cs:a_running_proc], bl
	retf


;时钟中断响应程序	
;在右下角循环输出字符	
;
Down  equ   1
Right equ   2
Up    equ   3
Left  equ   4
delay equ   1

int_8:
	cli
	cmp byte[cs:a_running_proc], 5
	jz nosave
	call save
nosave:
	pushf
	pushad
	cmp byte[cs:a_running_proc], 5
	jz dic
	xor eax, eax
	mov ax, _getnextproc
	call eax
	mov byte[cs:a_running_proc], al
	;计时	导致了popad使用错误，另外导致了没有restart
	;dec byte[cs:count]
	;jnz end1
	;mov byte[cs:count], delay
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
	;判断是否处于内核进程
	cmp byte[cs:a_running_proc], 5
	jz intest
inproc:
	popad
	popf
	call restart
	jmp end2
intest:
	popad
	popf
	jmp end2
end1:
	popad
	popf
end2:	
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
	iret
	
;系统调用中断，int_21h，五个功能
;AH 放置功能调用号
;功能一：更新系统时间 disptime       ah = 0
;功能二：改变背景颜色 changebcolor   ah = 1
;功能三：改变字体颜色 changefcolor   ah = 2
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

;int 34 : 关机         Shutdown
int_34:
	pushf
	pushad
	cli
	xor eax,eax
	mov ax,_Shutdown
	call eax	
	popad
	popf
	iret
;int 35 : 重启		  Restart
int_35:
	pushf
	pushad
	cli
	xor eax,eax
	mov ax,_Restart
	call eax	
	popad
	popf
	iret

;保存当前运行态进程的上下文
save:
	pop word[cs:ret_save]			;先保存函数返回地址
	cmp byte[cs:a_running_proc], 0	;判断现在运行中的进程是哪个
	jz proc_kernel
	cmp byte[cs:a_running_proc], 1
	jz proc1
	cmp byte[cs:a_running_proc], 2
	jz proc2
	cmp byte[cs:a_running_proc], 3
	jz proc3
	cmp byte[cs:a_running_proc], 4
	jz proc4
	push word[cs:ret_save]			;若不是并行进程则不进行save,test
	ret
;保存si的值，以si作为偏移量选择进程	
proc_kernel:
	mov word[cs:si0_save], si
	mov si, 0
	jmp saveother
proc1:
	mov word[cs:si1_save], si
	mov si, 2
	jmp saveother
proc2:
	mov word[cs:si2_save], si
	mov si, 4
	jmp saveother
proc3:
	mov word[cs:si3_save], si
	mov si, 6
	jmp saveother
proc4:
	mov word[cs:si4_save], si
	mov si, 8
	jmp saveother
saveother:
	mov word[cs:ax_save+si],ax
	mov word[cs:bx_save+si],bx
	mov word[cs:cx_save+si],cx
	mov word[cs:dx_save+si],dx
	mov word[cs:di_save+si],di
	mov word[cs:bp_save+si],bp
	mov ax, gs
	mov word[cs:gs_save+si],ax
	mov ax, fs
	mov word[cs:fs_save+si],ax
	mov ax, es
	mov word[cs:es_save+si],ax
	mov ax, ds
	mov word[cs:ds_save+si],ax
	pop word[cs:ip_save+si]
	pop word[cs:cs_save+si]
	pop word[cs:flags_save+si]
	mov word[cs:sp_save+si], sp
	mov ax, ss
	mov word[cs:ss_save+si],ax
;切换成内核栈
	mov ax, cs
	mov ss, ax
	mov sp, temp_stack
	push word[cs:ret_save]
	ret
;切换进程
restart:
	pop word[cs:ret_save]
	mov bx, 2
	mov ax, word[cs:a_running_proc]
	mul bl
	mov si, ax
	;切换栈用户
	mov ax, word[cs:ss_save+si]
	mov ss, ax
	mov sp, word[cs:sp_save+si]
	mov ax, word[cs:gs_save+si]
	mov gs,ax
	mov ax, word[cs:fs_save+si]
	mov fs,ax
	mov ax, word[cs:es_save+si]
	mov es,ax
	mov ax, word[cs:ds_save+si]
	mov ds,ax
	mov ax, word[cs:ax_save+si]
	mov bx, word[cs:bx_save+si]
	mov cx, word[cs:cx_save+si]
	mov dx, word[cs:dx_save+si]
	mov di, word[cs:di_save+si]
	mov bp, word[cs:bp_save+si]
;恢复子程序的栈顶元素
	push word[cs:flags_save+si]
	push word[cs:cs_save+si]
	push word[cs:ip_save+si]
	push word[cs:ret_save]
	cmp byte[cs:a_running_proc], 0	;判断现在运行中的进程是哪个
	jz proc_kernel_
	cmp byte[cs:a_running_proc], 1
	jz proc1_
	cmp byte[cs:a_running_proc], 2
	jz proc2_
	cmp byte[cs:a_running_proc], 3
	jz proc3_
	cmp byte[cs:a_running_proc], 4
	jz proc4_
proc_kernel_:
	mov si, word[cs:si0_save]
	ret
proc1_:
	mov si, word[cs:si1_save]
	ret
proc2_:
	mov si, word[cs:si2_save]
	ret
proc3_:
	mov si, word[cs:si3_save]
	ret
proc4_:
	mov si, word[cs:si4_save]
	ret		

PCB:
	si0_save	dw		0
	si1_save	dw		0
	si2_save	dw		0
	si3_save	dw		0
	si4_save	dw		0
	di_save		dw		0, 0, 0, 0, 0
	bp_save		dw		0, 0, 0, 0, 0
	sp_save		dw		0, 0x1a00, 0x2a00, 0x3a00, 0x4a00
	bx_save		dw		0, 0, 0, 0, 0
	ax_save		dw		0, 0, 0, 0, 0
	cx_save		dw		0, 0, 0, 0, 0
	dx_save		dw		0, 0, 0, 0, 0
	ss_save		dw		0, 0, 0, 0, 0
	gs_save		dw		0, 0, 0, 0, 0
	fs_save		dw		0, 0, 0, 0, 0
	es_save		dw		0, 0, 0, 0, 0
	ds_save		dw		0, 0, 0, 0, 0
	ip_save		dw		0x8100, 0x1000, 0x2000, 0x3000, 0x4000
	cs_save		dw		0, 0, 0, 0, 0
	flags_save	dw		0, 0, 0, 0, 0


;data section
datadef:
memory   times   800   dw        0
stack                  dw        100
memory2  times   500   dw        0
temp_stack             dw        0
a_running_proc		   db		 0
ret_save			   dw		 0
kernel_ss			   dw		 0	
kernel_sp			   dw		 0
is_init        		   db        0
count 		   		   db  	     4	
color 		  		   db        1
cr 	  	  	  	   	   db   	 'a'
x  	  	 	   		   db  	     20
y  	  	 	   		   db	     67
rdul  		  		   db        1
pre_int9_addr 		   dw        0,0
pre_int21h_addr        dw        0,0