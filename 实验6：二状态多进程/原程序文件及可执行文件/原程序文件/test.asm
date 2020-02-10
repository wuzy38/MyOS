;第四个子程序
;汇编
;测试中断响应程序与系统调用程序
;输入“Esc”返回内核
org 0x5000		
start:
	mov ax,cs
	mov es,ax
	mov ds,ax
    mov ss, ax
    mov sp, stack
    sti
showinf:
	mov	ax, 1301h		 
	mov	bx, 0007h		 
	mov	cx, 49		  
    mov dx, 0000h		
	mov	bp, message00
	int	10h	
	mov	cx, 64		     
    mov dx, 0100h		 
	mov	bp, message0 	 
	int	10h	
	mov	cx, 68		     
    mov dx, 0200h		 
	mov	bp, message1 	 
	int	10h			     
	mov	cx, 69		     
    mov dx, 0300h		
	mov	bp, message2 	
	int	10h			    
	mov	cx, 57		     
    mov dx, 0400h		 
	mov	bp, message3 	 
	int	10h			    
	mov	cx, 57		     
    mov dx, 0500h		 
	mov	bp, message4 	 
	int	10h

loop1:
	xor eax, eax
	mov ah,1
	int 16h
	jz loop1
	xor eax, eax
	mov ah,0
	int 16h	
	cmp al,0x1b
	jz 0x8100
	cmp al,0x30
	jz int_21_0	
	cmp al,0x31			
	jz int_21_1
	cmp al,0x32				
	jz int_21_2
	cmp al,0x33
	jz int_22h
	cmp al,0x34
	jz int_23h
	jmp loop1
int_21_0:
	mov ah,0
	int 21h
	jmp loop1
int_21_1:
	mov ah,1
	int 21h	
	jmp loop1
int_21_2:
	mov ah,2
	int 21h
	jmp loop1	
int_22h:
	int 22h
	jmp loop1
int_23h:
	int 23h
	jmp loop1	
end:
	jmp $
message0     db      "enter '0' to call the first syscall,which will upgrade the clock"
message1     db      "enter '1' to call the second syscall,which will change the background"
message2     db      "enter '2' to call the third syscall,which will change the foreground"
message3 	 db      "enter '3' to call the 22h interuption,which will shutdown" 
message4	 db      "enter '4' to call the 23h interuption,which will restart " 	
message00	 db		 "enter 'Esc' to return to kernel"
memory   times 200 dw   0
stack     dw            0
;times 1022-($-$$) db 0
;db 0x55,0xaa