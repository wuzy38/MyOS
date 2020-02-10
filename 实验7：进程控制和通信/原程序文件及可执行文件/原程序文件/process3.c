//第三个子程序
//在屏幕左下区域显示信息
//C程序
//位于0x3000
#include "io.h"
#include "time.h"
__asm__(".code16gcc");
char inf[] = "Xx XxXxxx";
void drawLfDn()
{
	int i, j;
	for(i = 0; i < 9; i++)
	{		
		char cr = inf[i];
		if(cr == ' ') continue;
		j = 13;
		Setchar(13,14+i,cr);
		while(j++ < 18)
		{
			timedelay(5);
			Setchar(j-1,14+i,' ');			
			Setchar(j,14+i,cr);
			Setcolor(j,14+i,14);
		}		
	}
}