;第四个子程序
;汇编
;显示个人信息
;输入“Esc”返回内核
org 0xA100		; A100h
start:
	mov ax,cs
	mov es,ax
	mov ds,ax
showinf:
	mov	bp, message 	 ; BP=当前串的偏移地址
	mov	cx, 20		     ; CX = 串长（=20）
	mov	ax, 1301h		 ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	bx, 0007h		 ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dx, 0020h		 ; 行号=0, 列号=0 
	int	10h			     ; BIOS的10h功能：显示一行字符
loop1:
	mov ah,01h
	int 16h
	jz loop1
	mov ah,00h
	int 16h
	cmp al,0x1b
	jz 0x8100
end:
	jmp $
message db "Xx XxXx   0000000000"
times 510-($-$$) db 0
db 0x55,0xaa