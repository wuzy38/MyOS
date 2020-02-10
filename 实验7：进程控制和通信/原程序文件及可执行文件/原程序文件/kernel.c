//内核
//用户通过输入命令访问指定程序
//三种命令
//四个程序
#include "io.h"
#include "time.h"
#include "string.h"
#include "stdlib.h"
__asm__(".code16gcc");
void wheel();
void Disptime();
int do_fork();
int do_wait();
int do_exit();
void drawblock();
int RunProc(int proc_ip);
int ExitProc(int proc_ip);
int getnextproc();
char apply[50] = "0";
char return_inf[60] = "Enter 'Esc' to clear screen";
int running_proc = 0;
// 0状态代表空闲, 1状态代表挂起, 2状态代表就绪
int status[7] = {2, 0, 0, 0, 0, 0, 0};// 进程表   0代表内核进程
int father[7] = {0, 0, 0, 0, 0, 0, 0};// 代表父进程
int proc_addr[7] = {0x8100, 0, 0, 0, 0, 0, 0}; //代表进程的起始地址
int getnextproc()
{
	int i;
	if (running_proc < 7)
	{
		i = running_proc+1;
		while(i%7 != running_proc)
		{
			if(status[i%7] == 2)
			{
				running_proc = i%7;
				break;
			}
			i++;
		}
	}
	return running_proc;
}
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
	"Input 'exit filename' to exit the  process",
	"Input 'check' to see the information of process",
	"Enter 'Esc' to clear screen"
};

char errorinf[20] = "invalid command";
char memory_error[20] = "memory error";
char proc_inf_status[100];
char running[20] = "         running";
char sleeping[20] = "         sleeping";
void Kernel()
{	
	int i;
	status[0] = 2;
	father[0] = 0;
	for (i = 1; i < 7; i++)
	{
		status[i] = 0;
		father[i] = 0;
	}
	running_proc = 0;
	Clear();
	Disptime();
	InstallProc(0, 1, 1, 4, 0x1000);
	InstallProc(0, 1, 5, 4, 0x2000);
	InstallProc(0, 1, 9, 4, 0x3000);
	InstallProc(0, 1, 13, 4, 0x4000);
	drawblock();
	//Setstr(12, 0, return_inf);
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
			if (RunProc(0x1000) == 0) Putstr(memory_error);
		}
		else if(is_equal(apply, order[2]))
		{
			//CleanScreen();
			if (RunProc(0x2000) == 0) Putstr(memory_error);
		}
		else if(is_equal(apply, order[3]))
		{
			//CleanScreen();
			if (RunProc(0x3000) == 0) Putstr(memory_error);
		}
		else if(is_equal(apply, order[4]))
		{
			//CleanScreen();
			if (RunProc(0x4000) == 0) Putstr(memory_error);
		}
		else if(is_equal(apply, order[5]))
		{
			//CleanScreen();
			ExitProc(0x1000);
		}
		else if(is_equal(apply, order[6]))
		{
			//CleanScreen();
			ExitProc(0x2000);
		}
		else if(is_equal(apply, order[7]))
		{
			//CleanScreen();
			ExitProc(0x3000);
		}
		else if(is_equal(apply, order[8]))
		{
			//CleanScreen();
			ExitProc(0x4000);
		}
		else if(is_equal(apply, order[9]))
		{
			InstallProc(0, 1, 17, 2, 0x5000);
			CleanScreen();
			running_proc = 5;
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



//在pcb中找到空闲的位置，然后修改状态，设置ip地址和栈地址
int RunProc(int proc_ip)
{
	int i = 1;
	int stack_ip;
	for (i = 1; i < 7; i++)
	{
		if (status[i] == 0)
		{
			father[i] = 0;
			stack_ip = i * (0x200) - (0x200);
			stack_ip += 0x5000;
			SetProc(i, proc_ip, stack_ip);
			proc_addr[i] = proc_ip;
			status[i] = 2;
			return 1;
		}
	}
	if (i == 7) return 0;
}

int ExitProc(int proc_ip)
{
	int i = 1;
	for (i = 1; i < 7; i++)
	{
		if (proc_addr[i] == proc_ip && status[i] > 0)
		{
			status[i] = 0;
			father[i] = 0;
			proc_addr[i] = 0;
			return 1;
		}
	}
	if (i == 7) return 0;
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

//无内存返回-1，父进程返回子进程id，子进程返回0
int do_fork()
{
	int i = 1;
	int stack_ip, proc_ip;
	if (father[running_proc] > 0) return 0;
	for (i = 1; i < 7; i++)
	{
		if (status[i] == 0)
		{
			father[i] = running_proc;
			proc_ip = proc_addr[running_proc];
			stack_ip = i * (0x200) - (0x200);
			stack_ip += 0x5000;
			SetProc(i, proc_ip, stack_ip);
			status[i] = 2;
			return i;
		}
	}
	return -1;
}

char exit[] = "exit";
char wait[] = "wait";
int do_exit()
{
	status[running_proc] = 0;
	if (status[father[running_proc]] == 1) 
		status[father[running_proc]] = 2;
	father[running_proc] = 0;
}

int do_wait()
{
	status[running_proc] = 1;
	Schedule();
	return 1;
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

int Down = 1;
int Right = 2;
int Up = 3;
int Left = 4;
int rdul = 1;
int x = 20;
int y = 67;
int color = 1;
char cr = 'a';
char space[5] = "    ";
void wheel()
{
	space[4] = 0;
	if (cr < 'a' || cr > 'z') cr = 'a';
	if (rdul == 1)
	{
		x++;
		if (x == 25)
		{
			x--;
			y++;
			rdul++;
		}
	}
	else if (rdul == 2)
	{
		y++;
		if (y == 80)
		{
			y--;
			x--;
			rdul++;
		}
	}
	else if (rdul == 3)
	{
		x--;
		if (x == 19)
		{
			x++;
			y--;
			rdul++;
		}
	}
	else if (rdul == 4)
	{
		y--;
		if (y == 66)
		{
			y++;
			x++;
			rdul = 1;
			if (cr < 'z') cr++;
			else cr = 'a';
		}
	}
	else 
	{
		x = 20;
		y = 67;
		rdul = 1;
	}
	if (color < 15) color++;
	else color = 1;
	Setchar(x, y, cr);
	Setcolor(x, y, color);
	Setstr(23, 71, space);
}