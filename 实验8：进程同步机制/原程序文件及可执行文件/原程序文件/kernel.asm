;内核汇编模块
;放置中断服务程序
;
[bits 16]

extern _Kernel
extern _func1
extern _getnextproc
; kernel
global _InstallProc		;加载子程序
global _SetProc	;设置运行程序
global _Schedule 
;中断和系统调用
extern _wheel
extern _Disptime
extern _do_fork
extern _do_exit
extern _do_wait
extern _do_p
extern _do_v
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
	mov word[cs:ip_save], 0x8100
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

;SetProc
;功能：		设置进程ip和栈ip
;入口参数： 栈
;出口参数： 无
;说明：  void SetProc(int proc_id, int proc_ip, int stack_ip)
_SetProc:	
	push bp						;要记录下sp的位置后再push其他东西
	mov bp,sp					;
	push bx
	mov ax,word[bp+6]
	mov bx, 2
	mul bl
	mov si, ax
	mov ax,word[bp+10]
	mov word[cs:ip_save+si], ax
	mov ax,word[bp+14]
	mov word[cs:sp_save+si], ax
	pop bx
	pop bp
	retf

;调用wait函数后进行进程切换,要先压标志寄存器，cs，ip
_Schedule:
	pushf
	push cs
	call changeproc
	retf
changeproc:
	call save
	push ax
	xor eax, eax
	mov ax, _getnextproc
	call eax
	mov byte[cs:a_running_proc], al
	pop ax
	call restart
	iret

;时钟中断响应程序	
int_8:
	cli
	call save
	pushf
	pushad
	xor eax, eax
	mov ax, _getnextproc
	call eax
	mov byte[cs:a_running_proc], al
	;摩天轮
run_wheel:
	xor eax,eax
	mov ax,_wheel
	call eax
	;判断是否处于内核进程
end1:
	popad
	popf
	call restart
	push ax
	mov al,20h			; AL = EOI
	out 20h,al			; 发送EOI到主8529A
	out 0A0h,al			; 发送EOI到从8529A	
	pop ax
	iret

;键盘中断响应程序,int 9
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
;功能四：创建进程获取pcb             ah = 3
;功能五：挂起进程					ah = 4
;功能六：退出进程					ah = 5
;功能七：P操作						ah = 6				bx存放调用的信号量
;功能八：V操作						ah = 7
int_21h:
	pushf
	cli
	push bx
	push cx
	push dx
	push si
	push di
	push bp
	push ds
	push es
	push gs
	xor ecx,ecx
	cmp ah,0
	jz int_21h_0
	cmp ah,1
	jz int_21h_1
	cmp ah,2
	jz int_21h_2
	cmp ah, 3
	jz int_21h_3
	cmp ah, 4
	jz int_21h_4
	cmp ah, 5
	jz int_21h_5
	cmp ah, 6
	jz int_21h_6
	cmp ah, 7
	jz int_21h_7
int_21h_end:
	pop gs
	pop es
	pop ds
	pop di
	pop si
	pop bp
	pop dx
	pop cx
	pop bx
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
	mov ecx,_do_fork
	call ecx
	jmp int_21h_end
int_21h_4:
	mov ecx,_do_exit
	call ecx
	jmp int_21h_end
int_21h_5:
	mov ecx,_do_wait
	call ecx
	jmp int_21h_end
int_21h_6:
	mov cx, bx
	push ecx
	xor ecx, ecx
	mov ecx, _do_p
	call ecx
	pop ecx
	jmp int_21h_end
int_21h_7:
	mov cx, bx
	push ecx
	xor ecx, ecx
	mov ecx, _do_v
	call ecx
	pop ecx
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
	cmp byte[cs:a_running_proc], 5
	jz proc5
	cmp byte[cs:a_running_proc], 6
	jz proc6
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
proc5:
	mov word[cs:si5_save], si
	mov si, 10
	jmp saveother
proc6:
	mov word[cs:si6_save], si
	mov si, 12
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
;切换成过渡栈
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
	cmp byte[cs:a_running_proc], 5
	jz proc5_
	cmp byte[cs:a_running_proc], 6
	jz proc6_
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
proc5_:
	mov si, word[cs:si5_save]
	ret
proc6_:
	mov si, word[cs:si6_save]
	ret

PCB:
	si0_save	dw		0
	si1_save	dw		0
	si2_save	dw		0
	si3_save	dw		0
	si4_save	dw		0
	si5_save	dw		0
	si6_save	dw		0
	di_save		dw		0, 0, 0, 0, 0, 0, 0
	bp_save		dw		0, 0, 0, 0, 0, 0, 0
	sp_save		dw		0, 0x5000, 0x5200, 0x5400, 0x5600, 0x5800, 0x5a00
	bx_save		dw		0, 0, 0, 0, 0, 0, 0
	ax_save		dw		0, 0, 0, 0, 0, 0, 0
	cx_save		dw		0, 0, 0, 0, 0, 0, 0
	dx_save		dw		0, 0, 0, 0, 0, 0, 0
	ss_save		dw		0, 0, 0, 0, 0, 0, 0
	gs_save		dw		0, 0, 0, 0, 0, 0, 0
	fs_save		dw		0, 0, 0, 0, 0, 0, 0
	es_save		dw		0, 0, 0, 0, 0, 0, 0
	ds_save		dw		0, 0, 0, 0, 0, 0, 0
	ip_save		dw		0x8100, 0x0000, 0x0000, 0x3000, 0x4000, 0, 0
	cs_save		dw		0, 0, 0, 0, 0, 0, 0
	flags_save	dw		0, 0, 0, 0, 0, 0, 0
	status      dw      1, 0, 0, 0, 0, 0, 0


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
pre_int9_addr 		   dw        0,0
pre_int21h_addr        dw        0,0