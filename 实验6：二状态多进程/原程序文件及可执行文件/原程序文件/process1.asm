;第一个子程序
;进行初始化栈以及变量存放
;
[bits 16]
extern _drawLfUp
initial:
    mov ax, cs
    mov ss, ax
    mov sp, stack
    mov si,word[cs:stack]
    sti
func:
    xor eax, eax
    mov ax, _drawLfUp
    call eax
    jmp func
end:
    jmp $

datadef:
;用户栈
sg        db    "thisproc111"
memory   times 200 dw   0
stack     dw            0
sgs        db    "thisproc111"