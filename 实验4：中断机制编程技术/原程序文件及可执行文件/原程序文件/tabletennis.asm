; 第一个子程序 ：tabletennis
; 汇编主体，部分C
; 显示器左右边各有一个球拍，通过‘w','s','up','down'键来控制球拍移动
; 输入Esc返回内核
[bits 16]
extern _Move
extern _Gamestart
global _Setchar
global _Getkey
[section .text]
	Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
	Up_Rt equ 2                  ; equ 等价语句 
	Up_Lt equ 3                  ;
	Dn_Lt equ 4                  ;
	delay equ 1000 				; 计时器延迟计数,用于控制画框的速度
	ddelay equ 50000			; 计时器延迟计数,用于控制画框的速度  
start:
	xor eax,eax
	mov ax,_Gamestart
	call eax
    mov ax,cs
	mov ds,ax					; DS = CS
	mov es,ax					; ES = CS
	mov ax,0B800h				; 文本窗口显存起始地址
	mov gs,ax					; GS = B800h
	mov si,0
	;制造时延
loop1:
	dec word[count]				; 递减计数变量
	jnz loop1					; >0：跳转;word[count] = 0	
	mov word[count],delay
	dec word[dcount]			; 递减计数变量
      jnz loop1
	mov word[count],delay
	mov word[dcount],ddelay		
	mov byte[gs:si],' '  		;清除前面痕迹
	mov byte[gs:si+1],13	
	mov ah,1
	int 16h
	jz dic
	cmp al,1bh
	jz 0x8100					;输入Esc返回内核
	xor eax,eax					;因为调用C程序返回时，栈会弹回32位，所以压栈也要压32位
	mov ax,_Move				;
	call eax
;确定方向	
dic:		
      mov al,1
      cmp al,byte[rdul]			;al - [rdul] 结果影响标志寄存器
	jz  DnRt
      mov al,2
      cmp al,byte[rdul]
	jz  UpRt
      mov al,3
      cmp al,byte[rdul]
	jz  UpLt
      mov al,4
      cmp al,byte[rdul]
	jz  DnLt
      jmp $	
	  
;根据方向行走，走右下方向
DnRt:
	inc word[x]
	inc word[y]
	
	mov bx,word[x]
	mov ax,25
	sub ax,bx				;ax = 25 - [x]
      jz  dr2ur				;[x] == 25 jmp
	mov bx,word[y]
	mov ax,79
	sub ax,bx				;ax = 79 - [y]
      jz  dr2dl
	jmp show
dr2ur:	;改变方向
      mov word[x],23
      mov byte[rdul],Up_Rt	
      jmp show
dr2dl:
	  call judge			;right wall
      mov word[y],77
      mov byte[rdul],Dn_Lt	
      jmp show
;走右上方向
UpRt:
	dec word[x]
	inc word[y]
	mov bx,word[y]
	mov ax,79
	sub ax,bx
      jz  ur2ul
	mov bx,word[x]
	mov ax,-1
	sub ax,bx
      jz  ur2dr
	jmp show
ur2ul:
	  call judge
      mov word[y],77
      mov byte[rdul],Up_Lt	
      jmp show
ur2dr:
      mov word[x],1
      mov byte[rdul],Dn_Rt	
      jmp show
;走左上方向
UpLt:
	dec word[x]
	dec word[y]
	mov bx,word[x]
	mov ax,-1
	sub ax,bx
      jz  ul2dl
	mov bx,word[y]
	mov ax,0
	sub ax,bx
      jz  ul2ur
	jmp show

ul2dl:
      mov word[x],1
      mov byte[rdul],Dn_Lt	
      jmp show
ul2ur:
	  call judge
      mov word[y],2
      mov byte[rdul],Up_Rt	
      jmp show
;走左下方向
DnLt:
	inc word[x]
	dec word[y]
	mov bx,word[y]
	mov ax,0
	sub ax,bx
      jz  dl2dr
	mov bx,word[x]
	mov ax,25
	sub ax,bx
      jz  dl2ul
	jmp show

dl2dr:
	  call judge
      mov word[y],2
      mov byte[rdul],Dn_Rt	
      jmp show
dl2ul:
      mov word[x],23
      mov byte[rdul],Up_Lt	
      jmp show
	  
;改变显示屏内存上的内容，使对应位置上存储上字符
show:	    
	mov ax,word[x]
	mov bx,80
	mul bx					;ax = 80*[x]
	add ax,word[y]			;ax = ax + [y]
	mov bx,2
	mul bx					;ax = 2 * (80 * x + y)
	mov si,ax
	;mov ah,0Fh				;  0000：黑底、1111：亮白字（默认值为07h）
	;mov al,byte[char]			;  AL = 显示字符值（默认值为20h=空格符）
	mov byte[gs:si],'o'  		;  显示字符的ASCII码值
	mov byte[gs:si+1],13
	jmp loop1
Gameover:
	mov ax,1300h
	mov bx,0007h
	mov cx,11
	mov dx,0920h
	mov bp,over
	int 10h
	mov ah,1
	int 16h
	jz Gameover
	cmp al,1bh
	jz 0x8100					;输入Esc返回内核
	jmp Gameover
end:
    jmp $                   ; 停止画框，无限循环 

datadef:	
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt         ; 向右下运动
    x   dw 5
    y   dw 1
	over  db  "Game Over !"
judge:
	mov ax,word[x]
	mov bx,80
	mul bx					;ax = 80*[x]
	add ax,word[y]			;ax = ax + [y]
	mov bx,2
	mul bx					;ax = 2 * (80 * x + y)
	mov si,ax
	mov ax,0B800h
	mov gs,ax
	cmp byte[gs:si],'8'
	jnz Gameover
	ret

;funcname : _Setchar
;功能：		指定位置输出
;入口参数： 栈
;出口参数： 无
;说明：     void Setchar(int x, int y, char cr);
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
	pop bp
	mov byte[gs:si],al
	mov byte[gs:si+1],07h
	ret

;funcname : Getkey
;功能：		获取一个按键输入
;入口参数： 无
;出口参数： (e)ax
;说明：     int Getkey();
_Getkey:	
	xor eax,eax
	mov ah,0
	int 16h	
	ret
	