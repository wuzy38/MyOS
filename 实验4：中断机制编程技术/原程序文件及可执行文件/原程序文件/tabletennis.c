//第一个子程序C函数部分：tabletennis
//
//
__asm__(".code16gcc");
void Setchar(int x, int y, char cr);
int Getkey();     //可以不用声明
int left[2] = {2,5};
int right[2] = {2,5};
void Gamestart()
{
	int i;
	for(i = left[0]; i <= left[1]; i++)
	{
		Setchar(i, 0, '8');
	}
	for(i = right[0]; i <= right[1]; i++)
	{
		Setchar(i, 79, '8');
	}	
}

void Move()
{
	int key = Getkey();
	if(key == 0x1177 && left[0] > 0)//'w'
	{
		left[0]--;
		Setchar(left[0], 0, '8');
		Setchar(left[1], 0, ' ');
		left[1]--;
	}
	if(key == 0x1f73 && left[1] < 24)//'s'
	{
		left[1]++;
		Setchar(left[1], 0, '8');
		Setchar(left[0], 0, ' ');
		left[0]++;
	}
	if(key == 0x4800 && right[0] > 0)
	{
		right[0]--;
		Setchar(right[0], 79, '8');
		Setchar(right[1], 79, ' ');
		right[1]--;
	}
	if(key == 0x5000 && right[1] < 24)
	{
		right[1]++;
		Setchar(right[1], 79, '8');
		Setchar(right[0], 79, ' ');
		right[0]++;
	}
}
