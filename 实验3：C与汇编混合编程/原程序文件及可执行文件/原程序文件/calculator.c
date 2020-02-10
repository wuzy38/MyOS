//第二个子程序: calculator
//C主体
//计算含有 '(', ')', '+', '-', '*', '/'符号的表达式
//输入Esc返回内核
//

#include "func.h"
__asm__(".code16gcc");

int Getint(char* str, int size);
void tranf(int num, char* str);
int Priority(char cr);
int calcul(int a, int b, char cr);
int calculator(char* str, int size);
void my_proc2()
{
	int size, result;
	char str[100];
	while(1)
	{
		size = Getstr(str);
		if(size > 0 && str[size-1] != '=')
		{ 
			str[size] = '=';
			size++;
			str[size] = 0;
		}
		result = calculator(str, size);
		tranf(result, str);
		Putstr(str);		
	}
}

void tranf(int num, char* str)
{
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
int Getint(char* str, int size)
{
	int i;
	int ans = 0;
	for(i = 0; i < size; i++)
		ans = 10 * ans + str[i] - '0';
	return ans;
}

int Priority(char cr)
{
	if(cr == '(') return 4;
	if(cr == '*' || cr == '/') return 3;
	if(cr == '+' || cr == '-') return 2;
 	if(cr == ')') return 1;
 	if(cr == '=') return 0;
}
int calcul(int a, int b, char cr)
{
	if(cr == '+') return a+b;
	if(cr == '-') return a-b;
	if(cr == '*') return a*b;
	if(cr == '/') return a/b;
}
int calculator(char* str, int size)
{
	char symb[100];
	char var[10];
	int num[100];
	int ans, symb_size, num_size;
	symb_size = 0;
	num_size = 0 ;
	int i,j;
	for(i = 0; i < size; i++)
	{
		//  if num
		if(str[i] >= '0' && str[i] <= '9')
		{
			j = 0; // j = varlen
			while(str[i+j] >= '0' && str[i+j] <= '9')
			{
				var[j] = str[i+j];
				j++;
			}
			i = i + j - 1;
			num[num_size] = Getint(var,j);
			num_size++;
			continue;
		}
		// symbol
		else
		{
			if(symb_size == 0 || str[i] == '(' || Priority(str[i]) > Priority(symb[symb_size-1])) //入栈
			{
				symb[symb_size] = str[i];
				symb_size++;
			}
			else if(symb[symb_size-1] == '(' && str[i] != ')')
			{
				symb[symb_size] = str[i];
				symb_size++;
			}
			else //出栈 
			{
				int judge = 1;
				while(symb_size > 0 && Priority(str[i]) <= Priority(symb[symb_size-1]))
				{
					// 栈顶元素为左括号，扫描符号为右括号
					if(symb[symb_size-1] == '(' && str[i] == ')')
					{
						symb_size--;
						judge = 0;
						break;
					}
					else if(symb[symb_size-1] == '(' && str[i] != ')')
						break;
					else
					{
						//数字栈出两位，符号栈出一位，计算结果入数字栈
						num_size--;
						num[num_size-1] = calcul(num[num_size-1], num[num_size], symb[symb_size-1]);
						symb_size--;
					}						
				}
				if(judge == 1)
				{
					symb[symb_size] = str[i];
					symb_size++;
				}
			}
		}
	}
	ans = num[0];
	if(num_size == 2 && symb_size == 1) ans = calcul(num[0], num[1], symb[0]);
	return ans;
}

