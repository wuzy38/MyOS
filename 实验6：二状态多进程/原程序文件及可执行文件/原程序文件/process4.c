//第四个子程序
//在屏幕左下区域显示信息
//C程序
//位于0x4000
#include "io.h"
#include "time.h"
__asm__(".code16gcc");
char inf[] = "THANK YOU";
void drawRtDn()
{
	int i, j;
	for(i = 0; i < 9; i++)
	{		
		char cr = inf[i];
		if(cr == ' ') continue;
		j = 13;
		Setchar(13,54+i,cr);
		while(j++ < 18)
		{
			timedelay(5);
			Setchar(j-1,54+i,' ');			
			Setchar(j,54+i,cr);
			Setcolor(j,54+i,11);
		}		
	}
}