//IO函数头文件
//
#ifndef IO_H
#define IO_H

__asm__(".code16gcc");

//  I/O module
void Clear();   		//清屏并显示黑底白字格式
void CleanScreen();     //清屏并保持背景
void Putchar(char cr);
char Getchar();
int Getstr(char* str);
void Putstr(char* str);
void Setchar(int x, int y, char cr);
void Setcolor(int x, int y, int color);
int Readcolor(int x, int y);
char Readchar(int x, int y);
void Setstr(int x, int y, char* str);
void Setbackground(int color);

#endif