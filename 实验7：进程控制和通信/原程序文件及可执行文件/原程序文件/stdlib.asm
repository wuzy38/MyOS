[bits 16]
global _Port_out_16
global _Port_in_16
;funcname : _Port_out_16
;功能：		输入16位数据进16位端口
;入口参数： 栈
;出口参数： 无
;说明：     void Port_out_16(int port, int value) port和value 16位数据
;注意：     只由C调用，返回32位地址
_Port_out_16:
    push bp
    mov bp,sp
	push dx
	push ax
		mov dx, word[bp + 6]		; port	
        mov	ax, word[bp + 10]			
		out	dx, ax
		nop							; 一点延迟
		nop
	pop ax
	pop dx
	pop bp
	retf	
	
;funcname : _Port_in_16
;功能：		从端口读出16位数据
;入口参数： 栈 
;出口参数： eax
;说明：     int Port_in_16(int port)
;注意：     只由C调用，返回32位地址
_Port_in_16:
    push bp
    mov bp,sp
	push dx
        mov	dx, word[bp + 6]		; port
		xor	eax, eax
		in	ax, dx
		nop							; 一点延迟
		nop
	pop dx
	pop bp
	retf
	