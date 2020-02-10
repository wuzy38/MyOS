;第一个子程序
;进行初始化栈以及变量存放
;
[bits 16]
extern _drawRtUp
initial:
    mov ax, cs
    mov ss, ax
    mov sp, stack
    mov si,word[cs:stack]
    mov ax, [cs:stack+bx]
    sti
func:
    xor eax, eax
    mov ax, _drawRtUp
    call eax
    jmp func
end:
    jmp $

datadef:
;用户栈
sg        db    "thisproc222"
memory   times 200 dw   0
stack     dw            0
sgs        db    "thisproc222"