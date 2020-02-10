//C函数模块：
//放置部分公用函数
//

#include "time.h"

__asm__(".code16gcc");

// t属于[0,100],t的值越大，时间间隔越大
void timedelay(int t)
{
	while(t-->0)
	{
		int j = 1000000;
		while(j-->0);
	}
}