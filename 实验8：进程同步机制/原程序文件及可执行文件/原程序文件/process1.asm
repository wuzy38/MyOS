;第一个子程序
;进行初始化栈以及变量存放
;
[bits 16]
extern _drawLfUp
global _fork
global _exit
global _wait
global _P
global _V

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

;将变量放在哪个, 参数为int, 压4为栈P(int semid) bl存放内容
_P:
    push bp
    mov bp, sp
    push bx
    mov bx, word[bp+6]
    mov ah, 6
    int 21h
    pop bx
    pop bp
    retf

_V:
    push bp
    mov bp, sp
    push bx
    mov bx, word[bp+6]
    mov ah, 7
    int 21h
    pop bx
    pop bp
    retf
