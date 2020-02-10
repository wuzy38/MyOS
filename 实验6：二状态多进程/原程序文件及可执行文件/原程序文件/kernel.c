//内核
//用户通过输入命令访问指定程序
//三种命令
//四个程序
#include "io.h"
#include "time.h"
#include "string.h"
#include "stdlib.h"
__asm__(".code16gcc");
void Disptime();
void drawblock();
int getnextproc();
void setrunningproc(int num);
char apply[50] = "0";
char return_inf[60] = "Enter 'Esc' to clear screen";
int running_proc = 0;
int status[5] = {1, 0, 0, 0, 0};// 进程表   0代表内核进程s
char proc_inf[6][80] = {
	"filename       memory         segment        offset         status",
	"process1       4KB            0              0x1000",
	"process2       4KB            0              0x2000",
	"process3       4KB            0              0x3000",
	"process4       4KB            0              0x4000",
	"test           4KB            0              0x5000"
};
char process_table[5][20] = {
	"kernel",
	"process1",
	"process2",
	"process3",
	"process4"
};
char order[11][20] = {
	"help",
	"run process1",
	"run process2",
	"run process3",
	"run process4",
	"exit process1",
	"exit process2",
	"exit process3",
	"exit process4",
	"run test",
	"check"
};
char helpinf[5][60] = {
	"Input 'help' to get help",
	"Input 'run filename' to run the process",
	"Input 'quit filename' to quit the  process",
	"Input 'check' to see the information of process",
	"Enter 'Esc' to clear screen"
};

char errorinf[20] = "invalid command";
char proc_inf_status[100];
char running[20] = "         running";
char sleeping[20] = "         sleeping";
void Kernel()
{	
	Clear();
	running_proc = 0;
	Disptime();
	InstallProc(0, 1, 1, 4, 0x1000);
	InstallProc(0, 1, 5, 4, 0x2000);
	InstallProc(0, 1, 9, 4, 0x3000);
	InstallProc(0, 1, 13, 4, 0x4000);
	drawblock();
	//Setstr(12, 0, return_inf);
	int i;
	while(1)
	{
		Getstr(apply);
		if(is_equal(apply,order[0]))
		{
			for(i = 0; i < 5; i++)
				Putstr(helpinf[i]);
		}
		else if(is_equal(apply, order[1]))
		{
			//CleanScreen();
			status[1] = 1;
		}
		else if(is_equal(apply, order[2]))
		{
			//CleanScreen();
			status[2] = 1;
		}
		else if(is_equal(apply, order[3]))
		{
			//CleanScreen();
			status[3] = 1;
		}
		else if(is_equal(apply, order[4]))
		{
			//CleanScreen();
			status[4] = 1;
		}
		else if(is_equal(apply, order[5]))
		{
			//CleanScreen();
			status[1] = 0;
		}
		else if(is_equal(apply, order[6]))
		{
			//CleanScreen();
			status[2] = 0;
		}
		else if(is_equal(apply, order[7]))
		{
			//CleanScreen();
			status[3] = 0;
		}
		else if(is_equal(apply, order[8]))
		{
			//CleanScreen();
			status[4] = 0;
		}
		else if(is_equal(apply, order[9]))
		{
			InstallProc(0, 1, 17, 2, 0x5000);
			CleanScreen();
			running_proc = 5;
			//setrunningproc(5);
			RunProc(0x5000);
		}
		else if(is_equal(apply, order[10]))
		{
			Putstr(proc_inf[0]);
			for(i = 1; i < 6; i++)
			{
				strcpy(proc_inf_status, proc_inf[i]);
				if(i != 5 && status[i]) 
					strcat(proc_inf_status, running);
				else 
					strcat(proc_inf_status, sleeping);
				Putstr(proc_inf_status);
			}
		}
		else 
			Putstr(errorinf);
		Putchar(0x0d);
	}
}
int getnextproc()
{
	int i;
	if (running_proc < 5)
	{
		i = running_proc+1;
		while(i%5 != running_proc)
		{
			if(status[i%5] == 1)
			{
				running_proc = i%5;
				break;
			}
			i++;
		}
	}
	return running_proc;
}


void drawblock()
{
	int i;
	for(i = 0; i < 80; i++)
	{
		Setcolor(12, i, 0x17);
	}	
	for(i = 0; i < 25; i++)
	{
		Setcolor(i, 39, 0x17);
		Setcolor(i, 40, 0x17);
	}
}


char temp[10] = "00";
char times[11] = "20";
// 系统调用功能，0，1，2号功能
// 在右下角显示时间
void Disptime()
{
	times[0] = '2';
	times[1] = '0';
	times[2] = 0;
	//分秒要补零，
	int year, month, day, hour, minute, second, i;
	year = Getyear();
	Str(year, temp);
	strcat(times, temp);
	temp[0] = '/';
	temp[1] = 0;
	strcat(times, temp);
	month = Getmonth();
	Str(month, temp);
	strcat(times, temp);
	temp[0] = '/';
	temp[1] = 0;
	strcat(times, temp);
	day = Getday();
	Str(day, temp);
	strcat(times, temp);
	Setstr(22, 68, times);
	times[0] = 0;
	hour = Gethour();
	Str(hour, times);
	if(strlen(times) == 1)
	{
		times[2] = times[1];
		times[1] = times[0];
		times[0] = '0';
	}
	temp[0] = ':';
	temp[1] = 0;
	strcat(times, temp);
	minute = Getminute();
	Str(minute, temp);
	if(strlen(temp) == 1)
	{
		temp[2] = temp[1];
		temp[1] = temp[0];
		temp[0] = '0';
	}
	strcat(times, temp);
	temp[0] = ':';
	temp[1] = 0;
	strcat(times, temp);
	second = Getsecond();
	Str(second, temp);
	if(strlen(temp) == 1)
	{
		temp[2] = temp[1];
		temp[1] = temp[0];
		temp[0] = '0';
	}
	strcat(times, temp);
	Setstr(21, 68, times);	
}

void changebcolor()
{
	int i, j, color;
	for(i = 0; i < 25; i++)
		for(j = 0; j < 80; j++)
		{
			color = Readcolor(i, j);
			color += 0x10;			
			if(color > 0xff) color -= 0x100;
			int fcolor = color / 16;
			int bcolor = color % 16;
			if(bcolor == fcolor || fcolor == (bcolor+0x08) || bcolor == (fcolor+0x08))
			{
				color += 0x10;
				if(color > 0xff) color -= 0x100;
			}
			Setcolor(i, j, color);
		}	
}
void changefcolor()
{
	int i, j, color;
	for(i = 0; i < 25; i++)
		for(j = 0; j < 80; j++)
		{
			color = Readcolor(i, j);
			color += 0x01;
			if(color % 16 == 0) color -= 0x10;
			int fcolor = color / 16;
			int bcolor = color % 16;
			if(bcolor == fcolor || fcolor == (bcolor+0x08) || bcolor == (fcolor+0x08))
			{
				color += 0x01;
				if(color % 16 == 0) color -= 0x10;
			}
			Setcolor(i, j, color);
		}
}

// 34，35号中断
void Shutdown()
{
	Port_out_16(0x1004, 0x2001);
}
void Restart()
{
	Port_out_16(0x64,0xfe);
}