//第二个子程序
//在屏幕右上区域显示信息
//C程序
//位于0x2000
#include "io.h"
#include "time.h"
__asm__(".code16gcc");
char inf[] = "welcome!";
char memory_error[] = "memory error";
char producer_str[] = "producer: the num is  ";
char comsumer_str[] = "comsumer: the num is  ";
int size = 21;
// s1代表第一个信号量，用于互斥
// s2代表第二个信号量，用于避免缓冲区空时的消费
// s3代表第三个信号量，用于避免缓冲区溢出
// num表示生产的数据的数量
int s1 = 1;
int s2 = 2;
int s3 = 3;
int num = 0;
void append();
void take();
void delay(int t);
void drawLfUp()
{
	int i, j;
	for (i = 5; i < 8; i++)
		for(j = 14; j < 30; j++)
			Setcolor(i, j, 7);
	int pid;
	pid = fork();
	if (pid == -1) //内存失败
	{
		Putstr(memory_error);
		exit();
	}
	if (pid > 0) //父进程 生成者
	{
		while(1)
		{
			delay(150);	// 生产速度
			P(s3);
			P(s1);
			append();
			V(s1);
			V(s2);
		}
	}
	else //子进程
	{
		while(1)
		{	
			P(s2);
			P(s1);
			take();
			V(s1);
			V(s3);
			delay(50);	// 	消费速度
		}
	}
}
void append()
{
	num += 1;
	producer_str[size] = num + '0';
	Putstr(producer_str);
}
void take()
{
	num -= 1;
	comsumer_str[size] = num + '0';
	Putstr(comsumer_str);
}
void delay(int t)
{
	while(t-->0)
	{
		int j = 1000000;
		while(j-->0);
	}
}



