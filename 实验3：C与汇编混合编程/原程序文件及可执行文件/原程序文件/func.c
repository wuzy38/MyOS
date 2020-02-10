//C函数模块：
//放置部分公用函数
//

#include "func.h"
__asm__(".code16gcc");
int Getstr(char* str)
{
	int size = 0;
	char cr = 0;			
	while(1)		
	{
		cr = Getchar();
		if(cr == 0)
			continue;
		Putchar(cr);
		if(cr == 0x0d)
		{
			str[size] = 0;
			break;
		}				
		if(cr == 0x08)
		{
			if(size > 0)				
				size--;
			continue;
		}		
		str[size] = cr;
		size++;						
	}
	return size;
}
void Putstr(char* str)
{
	int i = 0;
	while(str[i] != 0)
	{
		Putchar(str[i]);
		i++;
	}
	Putchar(0x0d);
}
int is_equal(char* str1, char* str2)
{
	int i = 0;
	while(1)
	{
		if(str1[i] == 0 && str2[i] == 0) return 1;			
		if(str1[i] != str2[i]) return 0;
		i++;
	}
}