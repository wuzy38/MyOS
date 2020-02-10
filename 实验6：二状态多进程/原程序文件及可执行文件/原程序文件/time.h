#ifndef TIME_H
#define TIME_H

__asm__(".code16gcc");

//time
void timedelay(int t);
int Getyear();
int Getmonth();
int Getday();
int Gethour();
int Getminute();
int Getsecond();

#endif