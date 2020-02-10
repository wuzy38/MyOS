//内核
//用户通过输入命令访问指定程序
//三种命令
//四个程序
#include "func.h"
__asm__(".code16gcc");

char apply[50];
char proc[4][6][30] = {
	{"name: tabletennis", "memory:       8KB", "SectorNo:      19", "SectorNums:    16","condition: ", "game:\rtable tennis"},
	{"name: calculator ", "memory:       8KB", "SectorNo:      37", "SectorNums:    16","condition: ", "tool:\rcalculator"},
	{"name: text editor", "memory:       8KB", "SectorNo:      55", "SectorNums:    16","condition: ", "tool:\rtext editor"},
	{"name: information", "memory:       8KB", "SectorNo:      73", "SectorNums:    16","condition: ", "message:\ruser information"}
};
char order[9][20] = {
	"help",
	"run tabletennis",
	"run calculator",
	"run text editor",
	"run information",
	"check tabletennis",
	"check calculator",
	"check text editor",
	"check information"
};
char helpinf[9][60] = {
	"Input 'help' for help",
	"Input 'run filename' to run a process",
	"Input 'check filename' to see a process's information",
	"Enter 'Esc' to come back to kernel at any time",
	"There are four process here : ",
	"1.tabletennis",
	"2.calculator",
	"3.text editor",
	"4.information"
};
char errorinf[20] = "invalid command";

void Kernel()
{
	Clear();
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
			//Putstr(helpinf[0]);
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
			Clear();
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
			for(i = 0; i < 5; i++)
				Putstr(proc[3][i]);			
		}
		else 
			Putstr(errorinf);
		Putchar(0x0d);		
	}
}