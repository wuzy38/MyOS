; ����Դ���루pro1.asm��
; ���������ı���ʽ��ʾ�������м���ʾ��������ѧ��
; �ֱַ����ʾ����ߺ��ұ����һ��'A'����,��45�������º������˶���ײ���߿����,�������.

	Dn_Rt equ 1                  ;D-Down,U-Up,R-right,L-Left
	Up_Rt equ 2                  ; equ �ȼ���� 
	Up_Lt equ 3                  ;
	Dn_Lt equ 4                  ;
	delay equ 50000				; ��ʱ���ӳټ���,���ڿ��ƻ�����ٶ�
	ddelay equ 580				; ��ʱ���ӳټ���,���ڿ��ƻ�����ٶ�
	org 07c00h					; ������ص�07c00h    
start:
    mov ax,cs
	mov ds,ax					; DS = CS
	mov es,ax					; ES = CS
	mov ax,0B800h				; �ı������Դ���ʼ��ַ
	mov gs,ax					; GS = B800h
showinf:	
	mov si,1980					; ƫ��
	mov cx,20					; string����
	mov bp,inf
infloop:
	mov bl,byte[es:bp]			;
	mov byte[gs:si],bl			;
	mov byte[gs:si+1],11		;
	inc bp
	add si,2
	loop infloop
	
	;����ʱ��
loop1:
	dec word[count]				; �ݼ���������
	jnz loop1					; >0����ת;word[count] = 0
	mov word[count],delay
	dec word[dcount]			; �ݼ���������
      jnz loop1
	mov word[count],delay
	mov word[dcount],ddelay		
	
	;ѭ��ѡ���������󣬽������ֵ����һ����������
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
	
;ȷ������	
dic:		
      mov al,1
      cmp al,byte[rdul]			;al - [rdul] ���Ӱ���־�Ĵ���
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
	  
;���ݷ������ߣ������·���
DnRt:
	inc word[x]
	inc word[y]
	mov bx,word[x]
	mov ax,25
	sub ax,bx				;ax = 25 - [x]
      jz  dr2ur				;[x] == 25 jmp
	mov bx,word[y]
	mov ax,80
	sub ax,bx				;ax = 80 - [y]
      jz  dr2dl
	jmp show
dr2ur:	;�ı䷽��
      mov word[x],23
      mov byte[rdul],Up_Rt	
      jmp show
dr2dl:
      mov word[y],78
      mov byte[rdul],Dn_Lt	
      jmp show
;�����Ϸ���
UpRt:
	dec word[x]
	inc word[y]
	mov bx,word[y]
	mov ax,80
	sub ax,bx
      jz  ur2ul
	mov bx,word[x]
	mov ax,-1
	sub ax,bx
      jz  ur2dr
	jmp show
ur2ul:
      mov word[y],78
      mov byte[rdul],Up_Lt	
      jmp show
ur2dr:
      mov word[x],1
      mov byte[rdul],Dn_Rt	
      jmp show
;�����Ϸ���
UpLt:
	dec word[x]
	dec word[y]
	mov bx,word[x]
	mov ax,-1
	sub ax,bx
      jz  ul2dl
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
      jz  ul2ur
	jmp show

ul2dl:
      mov word[x],1
      mov byte[rdul],Dn_Lt	
      jmp show
ul2ur:
      mov word[y],1
      mov byte[rdul],Up_Rt	
      jmp show
;�����·���
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
	  
;�ı���ʾ���ڴ��ϵ����ݣ�ʹ��Ӧλ���ϴ洢���ַ�
show:	    
	mov ax,word[x]
	mov bx,80
	mul bx					;ax = 80*[x]
	add ax,word[y]			;ax = ax + [y]
	mov bx,2
	mul bx					;ax = 2 * (80 * x + y)
	mov si,ax
	;mov ah,0Fh				;  0000���ڵס�1111�������֣�Ĭ��ֵΪ07h��
	;mov al,byte[char]			;  AL = ��ʾ�ַ�ֵ��Ĭ��ֵΪ20h=�ո����
	mov byte[gs:si],'A'  		;  ��ʾ�ַ���ASCII��ֵ
	mov byte[gs:si+1],13
	
;�����������󣬽����������ֵ���ظ��ԵĶ���
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
	
	jmp showinf
	
end:
    jmp $                   ; ֹͣ��������ѭ�� 
	
inf:  db "Xx XxXx     00000000"
datadef:	
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt         ; �������˶�
    x   dw 5
    y   dw 0
	xx  dw 5, 5
	yy  dw 0, 79
	rdul_ db Dn_Rt, Dn_Lt

