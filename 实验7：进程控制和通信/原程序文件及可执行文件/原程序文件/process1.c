//第二个子程序
//在屏幕右上区域显示信息
//C程序
//位于0x2000
#include "io.h"
#include "time.h"
__asm__(".code16gcc");
char inf[] = "welcome!";
char memory_error[] = "memory error";
char father_str1[] = "father: the string is 'welcome!'";
char son_str[] = "son: counting the length of the string";
char father_str2[30] = "father: the length is ";
int letter_num = 0;
int size = 22;
int num = 0;
int strlen(char* str);
void drawLfUp()
{
	int i, j;
	for (i = 5; i < 8; i++)
		for(j = 14; j < 30; j++)
			Setcolor(i, j, 7);
	int pid;
	pid = fork();
	if (pid == -1) //内存失败
	{
		Putstr(memory_error);
		exit();
	}
	if (pid > 0) //父进程
	{
		Putstr(father_str1);
		wait();
		size = 22;
		num = letter_num;
		while(num > 0)
		{
			father_str2[size] = num % 10 + '0';
			num /= 10;
			size++;
		}
		father_str2[size] = 0;
		Putstr(father_str2);
		exit();
	}
	else //子进程
	{
		Putstr(son_str);
		letter_num = strlen(inf);
		exit();
	}
}

int strlen(char* str)
{
	int i = 0;
	while(str[i]) i++;
	return i;
}