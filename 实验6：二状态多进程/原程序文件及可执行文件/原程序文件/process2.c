//第二个子程序
//在屏幕右上区域显示信息
//C程序
//位于0x2000
#include "io.h"
#include "time.h"
__asm__(".code16gcc");
char inf[] = "00000000";
void drawRtUp()
{
	int i, j;
	for(i = 0; i < 8; i++)
	{		
		char cr = inf[i];
		if(cr == ' ') continue;
		j = 0;
		Setchar(0,54+i,cr);
		while(j++ < 6)
		{
			timedelay(5);
			Setchar(j-1,54+i,' ');			
			Setchar(j,54+i,cr);
			Setcolor(j, 54+i, 13);
		}		
	}
}