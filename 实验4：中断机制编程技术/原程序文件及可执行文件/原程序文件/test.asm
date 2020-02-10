;第四个子程序
;汇编
;测试中断响应程序与系统调用程序
;输入“Esc”返回内核
org 0xA100		;8100h
start:
	mov ax,cs
	mov es,ax
	mov ds,ax
showinf:
	mov	bp, message0 	 ; BP=当前串的偏移地址
	mov	cx, 49		     ; CX = 串长（=9）
	mov	ax, 1301h		 ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	bx, 0007h		 ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dx, 0000h		 ; 行号=0, 列号=0 
	int	10h			     ; BIOS的10h功能：显示一行字符
	int 34
	int 35
	int 36
	int 37
	
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
	mov	cx, 55		     
    mov dx, 0400h		 
	mov	bp, message3 	 
	int	10h			    
	mov	cx, 55		     
    mov dx, 0500h		 
	mov	bp, message4 	 
	int	10h					    
	
	
loop1:
;	mov ah,2
;	int 16h
;Shift:		
;	cmp al,0x02				;L_shift
;	jz int_21_1
;	cmp al,0x01				;R_shift
;	jz int_21_2
	mov ah,01h
	int 16h
	jz loop1
	mov ah,00h
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
	jz int_21_3
	cmp al,0x34
	jz int_21_4
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
int_21_3:
	mov ah,3
	int 21h
	jmp loop1
int_21_4:
	mov ah,4
	int 21h
	jmp loop1	
end:
	jmp $
message     db      "Now it is the interupt. Don't touch the keyboard."
message00    db      "Now you can call the syscall                     "
message0     db      "Input '0' to call the first syscall,which will upgrade the clock"
message1     db      "Input '1' to call the second syscall,which will change the background"
message2     db      "Input '2' to call the third syscall,which will change the foreground"
message3 	 db      "Input '3' to call the forth syscall,which will shutdown" 
message4	 db      "Input '4' to call the fifth syscall,which will restart " 	

times 1022-($-$$) db 0
db 0x55,0xaa