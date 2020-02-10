//放置字符串处理函数
//

#include "string.h"

__asm__(".code16gcc");

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
void strcat(char* str1, char* str2)
{
	int i, j;
	for(i = 0; str1[i]; i++);
	for(j = 0; str2[j]; j++)
		str1[i+j] = str2[j];
	str1[i+j] = 0;
}
int strlen(char* str)
{
	int i = 0;
	while(str[i]) i++;
	return i;
}