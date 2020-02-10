;第一个子程序
;进行初始化栈以及变量存放
;
[bits 16]
extern _drawLfDn
initial:
    sti
func:
    xor eax, eax
    mov ax, _drawLfDn
    call eax
    jmp func
end:
    jmp $

datadef:
;用户栈
sg        db     "thisproc333"