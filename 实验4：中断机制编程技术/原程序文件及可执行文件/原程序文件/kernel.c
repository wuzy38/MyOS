//内核
//用户通过输入命令访问指定程序
//三种命令
//四个程序
#include "io.h"
#include "time.h"
#include "string.h"
#include "stdlib.h"
__asm__(".code16gcc");
void drawLfUp();
void drawRtUp();
void drawLfDn();
void drawRtDn();
void Disptime();
void Shutdown();
void Restart();
char apply[50] = "0";
char proc[4][6][40] = {
	{"name: tabletennis", "memory:      8KB", "SectorNo:      19", "SectorNums:    16","condition: ", "game:\rtable tennis"},
	{"name: calculator ", "memory:      8KB", "SectorNo:      37", "SectorNums:    16","condition: ", "tool:\rcalculator"},
	{"name: text editor", "memory:      8KB", "SectorNo:      55", "SectorNums:    16","condition: ", "tool:\rtext editor"},
	{"name: test       ", "memory:      8KB", "SectorNo:      73", "SectorNums:    16","condition: ", "test:\rTest the interupt and syscall"}
};

char order[9][20] = {
	"help",
	"run tabletennis",
	"run calculator",
	"run text editor",
	"run test",
	"check tabletennis",
	"check calculator",
	"check text editor",
	"check test"
};
char helpinf[9][55] = {
	"Input 'help' for help",
	"Input 'run filename' to run a process",
	"Input 'check filename' to see a process's information",
	"Enter 'Esc' to come back to kernel at any time",
	"There are four process here : ",
	"1.tabletennis",
	"2.calculator",
	"3.text editor",
	"4.test"
};
char errorinf[20] = "invalid command";
void drawblock()
{	
	Setbackground(0x57);
	int i;
	for(i = 0; i < 80; i++)
	{
		timedelay(2);		
		Setcolor(12,i,0x17);
	}	
	for(i = 0; i < 25; i++)
	{
		timedelay(8);
		Setcolor(i,39, 0x17);
		Setcolor(i,40, 0x17);
	}
}

void Kernel()
{	
	Clear();
	Disptime();
	int i;
	while(1)
	{
		Getstr(apply);
		if(is_equal(apply,order[0]))
		{
			for(i = 0; i < 9; i++)
				Putstr(helpinf[i]);
		}
		else if(is_equal(apply, order[1]))
		{
			Clear();
			RunProc(1);
		}		
		else if(is_equal(apply, order[2]))
		{
			Clear();
			RunProc(2);
		}	
		else if(is_equal(apply, order[3]))
		{
			Clear();			
			RunProc(3);
		}	
		else if(is_equal(apply, order[4]))
		{
			CleanScreen();
			drawblock();
			Disptime();
			RunProc(4);
		}	
		else if(is_equal(apply, order[5]))
		{
			for(i = 0; i < 6; i++)
				Putstr(proc[0][i]);			
		}
		else if(is_equal(apply, order[6]))
		{
			for(i = 0; i < 6; i++)
				Putstr(proc[1][i]);			
		}
		else if(is_equal(apply, order[7]))
		{
			for(i = 0; i < 6; i++)
				Putstr(proc[2][i]);			
		}
		else if(is_equal(apply, order[8]))
		{
			for(i = 0; i < 6; i++)
				Putstr(proc[3][i]);			
		}
		else 
			Putstr(errorinf);
		Putchar(0x0d);		
	}
}

char temp[10] = "00";
char times[11] = "20";
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

void Shutdown()
{
	Port_out_16(0x1004, 0x2001);
}
void Restart()
{
	Port_out_16(0x64,0xfe);
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

// 34，35，36，37号中断
// 0~11, 13~24, 0~38, 41~79
char my_inf[4][20] = {
	"Xx XxXx",
	"00000000",
	"computer science",
	"THANk YOU"
	};	
void drawLfUp()
{
	// 输出信息	
	int i, j;	
	for(i = 0; i < 9; i++)
	{		
		char cr = my_inf[0][i];
		if(cr == ' ') continue;
		j = 0;
		Setchar(0,14+i,cr);
		while(j++ < 6)
		{
			timedelay(5);
			Setchar(j-1,14+i,' ');			
			Setchar(j, 14+i, cr);
		}		
	}
}
void drawRtUp()
{
	int i, j;
	for(i = 0; i < 8; i++)
	{		
		char cr = my_inf[1][i];
		if(cr == ' ') continue;
		j = 0;
		Setchar(0,54+i,cr);
		while(j++ < 6)
		{
			timedelay(5);
			Setchar(j-1,54+i,' ');			
			Setchar(j,54+i,cr);
		}		
	}
}
void drawLfDn()
{
	int i, j;
	for(i = 0; i < 16; i++)
	{		
		char cr = my_inf[2][i];
		if(cr == ' ') continue;
		j = 13;
		Setchar(13,14+i,cr);
		while(j++ < 18)
		{
			timedelay(5);
			Setchar(j-1,14+i,' ');			
			Setchar(j,14+i,cr);
		}		
	}
}
void drawRtDn()
{
	int i, j;
	for(i = 0; i < 9; i++)
	{		
		char cr = my_inf[3][i];
		if(cr == ' ') continue;
		j = 13;
		Setchar(13,54+i,cr);
		while(j++ < 18)
		{
			timedelay(5);
			Setchar(j-1,54+i,' ');			
			Setchar(j,54+i,cr);
		}		
	}
}