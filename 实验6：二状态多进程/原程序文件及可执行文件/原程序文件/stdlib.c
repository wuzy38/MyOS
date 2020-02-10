//C函数模块：
//放置部分公用函数
//

#include "stdlib.h"

__asm__(".code16gcc");
// 类型转换
int Int(char* str)
{
	int i, ans = 0;
	for(i = 0; str[i]; i++)
		ans = 10 * ans + str[i] - '0';
	return ans;
}
void Str(int num, char* str)
{
	if(num == 0)
	{
		str[0] = '0';
		str[1] = 0;
		return;
	}
	int size = 0;
	int begin = 0;
	if(num < 0)
	{
		str[size] = '-';
		size++;
		num = -num;
		begin = 1;
	}
	while(num > 0)
	{
		str[size] = num % 10 + '0';
		num /= 10;
		size++;
	}
	str[size] = 0;
	int temp, i;
	for(i = begin; i < (size - begin)/2; i++)
	{
		temp = str[i];
		str[i] = str[size - i + begin - 1];
		str[size - i + begin - 1] = temp;
	}
}