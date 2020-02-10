//函数头文件
//
//
#ifndef FUNC_H
#define FUNC_H

__asm__(".code16gcc");
void Clear();
void Putchar(char cr);
char Getchar();
int Getstr(char* str);
void Putstr(char* str);
int is_equal(char* str1, char* str2);
void RunProc(int id);


//void Setchar(int x, int y, char cr);
//int Getkey();

//void Setchar(int x, int y, char cr);


#endif