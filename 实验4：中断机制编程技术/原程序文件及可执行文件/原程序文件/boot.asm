;引导程序
;读内核扇区，并跳转到内核
;
OS_offset equ 8100h
org 7c00h
start:
	mov ax,cs
	mov es,ax
	mov ds,ax
showpro:
	mov	bp, message 	 ; BP=当前串的偏移地址
	mov	cx, 9		     ; CX = 串长（=9）
	mov	ax, 1301h		 ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	bx, 0007h		 ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dx, 0000h		 ; 行号=0, 列号=0 
	int	10h			     ; BIOS的10h功能：显示一行字符	
LoadnEx:
;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
	mov ax,cs                ;段地址 ; 存放数据的内存基地址
	mov es,ax                ;设置段地址（不能直接mov es,段地址）
	mov bx, OS_offset        ;偏移地址; 存放数据的内存偏移地址
	mov ah,2                 ;功能号
	mov al,17                 ;扇区数
	mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
	mov dh,0                 ;磁头号 ; 起始编号为0
	mov ch,0                 ;柱面号 ; 起始编号为0
	mov cl,2                 ;起始扇区号 ; 起始编号为1
	int 13H ;                调用读磁盘BIOS的13h功能
	jmp OS_offset
message db "this boot"
times 510-($-$$) db 0
db 0x55,0xaa