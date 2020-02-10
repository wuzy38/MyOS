//函数头文件
//字符串处理函数

#ifndef STRING_H
#define STRING_H

__asm__(".code16gcc");

//字符串函数 string
int is_equal(char* str1, char* str2);
void strcat(char* str1, char* str2);
int strlen(char* str);

#endif