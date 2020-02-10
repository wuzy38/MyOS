; 程序源代码（pro1c.asm）
; 本程序在文本方式显示器上在中间显示个人姓名学号
; 又分别从显示器左边和右边射出一个'A'符号,以45度向右下和左下运动，撞到边框后反射,如此类推.
	Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
	Up_Rt equ 2                  ; equ 等价语句 
	Up_Lt equ 3                  ;
	Dn_Lt equ 4                  ;
	delay equ 50000				; 计时器延迟计数,用于控制画框的速度
	ddelay equ 580				; 计时器延迟计数,用于控制画框的速度
	org 8500h
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ax,0B800h				; 文本窗口显存起始地址
	mov gs,ax					; GS = B800h	
loop1:	
	dec word[count]				; 递减计数变量
	jnz loop1					; >0：跳转;word[count] = 0
	mov word[count],delay
	dec word[dcount]			; 递减计数变量
      jnz loop1
	mov word[count],delay
	mov word[dcount],ddelay		
	
	;循环选择两个对象，将对象的值赋给一个公共对象
	mov cl,0
choose:	
	mov al,1
	cmp al,cl
	jz stoneb1
stonea1:
	mov ax,word[xx]
	mov word[x],ax
	mov ax,word[yy]
	mov word[y],ax
	mov al,byte[rdul_]
	mov byte[rdul],al
	jmp dic
stoneb1:
	mov ax,word[xx+2]
	mov word[x],ax
	mov ax,word[yy+2]
	mov word[y],ax
	mov al,byte[rdul_+1]
	mov byte[rdul],al
	
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
	mov ax,40
	sub ax,bx				;ax = 80 - [y]
      jz  dr2dl
	jmp show
dr2ur:	;改变方向
      mov word[x],23
      mov byte[rdul],Up_Rt	
      jmp show
dr2dl:
      mov word[y],38
      mov byte[rdul],Dn_Lt	
      jmp show
;走右上方向
UpRt:
	dec word[x]
	inc word[y]
	mov bx,word[y]
	mov ax,40
	sub ax,bx
      jz  ur2ul
	mov bx,word[x]
	mov ax,12
	sub ax,bx
      jz  ur2dr
	jmp show
ur2ul:
      mov word[y],38
      mov byte[rdul],Up_Lt	
      jmp show
ur2dr:
      mov word[x],14
      mov byte[rdul],Dn_Rt	
      jmp show
;走左上方向
UpLt:
	dec word[x]
	dec word[y]
	mov bx,word[x]
	mov ax,12
	sub ax,bx
      jz  ul2dl
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
      jz  ul2ur
	jmp show

ul2dl:
      mov word[x],14
      mov byte[rdul],Dn_Lt	
      jmp show
ul2ur:
      mov word[y],1
      mov byte[rdul],Up_Rt	
      jmp show
;走左下方向
DnLt:
	inc word[x]
	dec word[y]
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
      jz  dl2dr
	mov bx,word[x]
	mov ax,25
	sub ax,bx
      jz  dl2ul
	jmp show

dl2dr:
      mov word[y],1
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
	mov byte[gs:si],'A'  		;  显示字符的ASCII码值
	mov byte[gs:si+1],15
	
;区别两个对象，将公共对象的值返回各自的对象
	mov al,1
	cmp al,cl
	jz stoneb2
stonea2:	
	mov ax,word[x]
	mov word[xx],ax
	mov ax,word[y]
	mov word[yy],ax
	mov al,byte[rdul]
	mov byte[rdul_],al
    inc cl
	jmp choose
stoneb2:	
	mov ax,word[x]
	mov word[xx+2],ax
	mov ax,word[y]
	mov word[yy+2],ax
	mov al,byte[rdul]
	mov byte[rdul_+1],al	
	
	mov ah,01h
	int 16h	
	jnz quit
	jmp loop1
	
quit:	
	mov ah,00h
	int 16h
	jmp 7c00h
	
datadef:	
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt         ; 向右下运动
    x   dw 5
    y   dw 0
	xx  dw 18, 18
	yy  dw 0, 39
	rdul_ db Dn_Rt, Dn_Lt

;times 510-($-$$) db 0
;dw 0xaa55