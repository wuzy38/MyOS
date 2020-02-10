;第一个子程序
;进行初始化栈以及变量存放
;
[bits 16]
extern _drawRtDn
initial:
    sti
func:
    xor eax, eax
    mov ax, _drawRtDn
    call eax
    jmp func
end:
    jmp $

datadef:
;用户栈
sg        db    "thisproc444"