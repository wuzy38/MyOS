;第一个子程序
;进行初始化栈以及变量存放
;
[bits 16]
extern _drawLfUp
global _fork
global _exit
global _wait

initial:
    sti
func:
    xor eax, eax
    mov ax, _drawLfUp
    call eax
end:
    jmp $

datadef:
;用户栈
sg        db    "thisproc111"

_fork:
    mov ah, 3
    int 21h
    retf

_exit:
    mov ah, 4
    int 21h
    retf

_wait:
    mov ah, 5
    int 21h
    retf
