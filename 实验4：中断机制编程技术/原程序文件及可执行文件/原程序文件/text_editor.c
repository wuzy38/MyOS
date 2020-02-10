//第三个子程序：text editor（文本编辑器）
//编辑文本
//输入Esc键返回内核

#include "func.h"
__asm__(".code16gcc");

void my_proc3()
{
	char str[100];
	while(1)	
		Getstr(str);	
}