//IO函数模块：
//

#include "io.h"

__asm__(".code16gcc");
void CleanScreen()
{
	int i, j;
	for(i = 0; i < 25; i++)
		for(j = 0; j < 80; j++)
			Setchar(i, j, ' ');
}

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
void Setstr(int x, int y, char* str)
{
	int i = 0;
	while(str[i])
		Setchar(x,y+i,str[i++]);
}

void Setbackground(int color)
{
	int i, j;
	for(i = 0; i < 25; i++)
		for(j = 0; j < 80; j++)
			Setcolor(i, j, color);
}
