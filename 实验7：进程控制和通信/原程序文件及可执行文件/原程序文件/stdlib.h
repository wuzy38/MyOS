//定义杂项函数
#ifndef STDLIB_H
#define STDLIB_H

__asm__(".code16gcc");

//数据类型转换
int Int(char* str);
void Str(int num, char* str);
//读写端口
int Port_in_16(int port);
void Port_out_16(int port, int value);

#endif