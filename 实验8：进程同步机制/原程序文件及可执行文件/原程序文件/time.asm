;汇编函数模块
;实现关于时间函数
[bits 16]

;time
global _Getyear
global _Getmonth
global _Getday
global _Gethour
global _Getminute
global _Getsecond

;funcname : _Getyear
;功能：		读取当前位置字符
;入口参数： 无
;出口参数： eax
;说明：     int Getyear()
;注意：     只由C调用，返回32位地址
_Getyear:
	;发送需要的时间参数到指定端口70h，从71h获得其BCD码	
	push bx
	push cx
	mov al,9
	out 70h,al
	in al,71h
	mov ah,al
	mov cl,4
	shr al,cl
	and ah,00001111b
	;ah 代表 个位数, al 代表 十位数
	xor cx,cx
	mov cl,ah
	xor ah,ah	
	mov bl,10
	mul bl
	add cx,ax
	xor eax,eax
	mov ax,cx
	pop cx
	pop bx
	retf
	
;funcname : _Getmonth
;功能：		读取当前位置字符
;入口参数： 无
;出口参数： eax
;说明：     int Getmonth()
;注意：     只由C调用，返回32位地址
_Getmonth:
	;发送需要的时间参数到指定端口70h，从71h获得其BCD码	
	push bx
	push cx
	mov al,8
	out 70h,al
	in al,71h
	mov ah,al
	mov cl,4
	shr al,cl
	and ah,00001111b
	;ah 代表 个位数, al 代表 十位数
	xor cx,cx
	mov cl,ah
	xor ah,ah	
	mov bl,10
	mul bl
	add cx,ax
	xor eax,eax
	mov ax,cx
	pop cx
	pop bx
	retf

;funcname : _Getday
;功能：		读取当前位置字符
;入口参数： 无
;出口参数： eax
;说明：     int Getday()
;注意：     只由C调用，返回32位地址
_Getday:
	;发送需要的时间参数到指定端口70h，从71h获得其BCD码	
	push bx
	push cx
	mov al,7
	out 70h,al
	in al,71h
	mov ah,al
	mov cl,4
	shr al,cl
	and ah,00001111b
	;ah 代表 个位数, al 代表 十位数
	xor cx,cx
	mov cl,ah
	xor ah,ah	
	mov bl,10
	mul bl
	add cx,ax
	xor eax,eax
	mov ax,cx
	pop cx
	pop bx
	retf

;funcname : _Gethour
;功能：		读取当前位置字符
;入口参数： 无
;出口参数： eax
;说明：     int Gethour()
;注意：     只由C调用，返回32位地址
_Gethour:
	;发送需要的时间参数到指定端口70h，从71h获得其BCD码	
	push bx
	push cx
	mov al,4
	out 70h,al
	in al,71h
	mov ah,al
	mov cl,4
	shr al,cl
	and ah,00001111b
	;ah 代表 个位数, al 代表 十位数
	xor cx,cx
	mov cl,ah
	xor ah,ah	
	mov bl,10
	mul bl
	add cx,ax
	xor eax,eax
	mov ax,cx
	pop cx
	pop bx
	retf

;funcname : _Getminute
;功能：		读取当前位置字符
;入口参数： 无
;出口参数： eax
;说明：     int Getminute()
;注意：     只由C调用，返回32位地址
_Getminute:
	;发送需要的时间参数到指定端口70h，从71h获得其BCD码	
	push bx
	push cx
	mov al,2
	out 70h,al
	in al,71h
	mov ah,al
	mov cl,4
	shr al,cl
	and ah,00001111b
	;ah 代表 个位数, al 代表 十位数
	xor cx,cx
	mov cl,ah
	xor ah,ah	
	mov bl,10
	mul bl
	add cx,ax
	xor eax,eax
	mov ax,cx
	pop cx
	pop bx
	retf
	
;funcname : _Getsecond
;功能：		读取当前位置字符
;入口参数： 无
;出口参数： eax
;说明：     int Getsecond()
;注意：     只由C调用，返回32位地址
_Getsecond:
	;发送需要的时间参数到指定端口70h，从71h获得其BCD码	
	push bx
	push cx
	mov al,0
	out 70h,al
	in al,71h
	mov ah,al
	mov cl,4
	shr al,cl
	and ah,00001111b
	;ah 代表 个位数, al 代表 十位数
	xor cx,cx
	mov cl,ah
	xor ah,ah	
	mov bl,10
	mul bl
	add cx,ax
	xor eax,eax
	mov ax,cx
	pop cx
	pop bx
	retf
