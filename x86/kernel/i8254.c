/*
 *Copyright 2013-2014 by Explorer Developer.
 *made by Hu wenjie(CN)<1@GhostBirdOS.org>
 *Explorer 8259 head
 *Explorer 0.01/arch/x86/include/i8259.h
 *version:Alpha
 *7/26/2014 5:26 PM
 */

#include<stdlib.h>
#include<types.h>
#include "../include/trap.h"
#include "../include/i8254.h"

unsigned long long sys_clock;
static struct timer_task *current_task;

void init_PIT(void)
{
	/*set 0 to sys_clock*/
	sys_clock = 0;
	/*there is nothing task need PIT*/
	current_task = NULL;
	/*register PIT to PIC*/
	register_PIC(0, &int_PIT, "intel 8254");
	/*³õÊ¼»¯ÆµÂÊ*/
	io_out8(PIT_CTRL, 0x34);
	io_out8(PIT_CNT0, LATCH & 0xff);
	io_out8(PIT_CNT0, LATCH >> 8);
	return;
}

void int_PIT_display(void)
{
	sys_clock++;
	struct timer_task *task_point;
	task_point = current_task;
	while((task_point != NULL) && ((*task_point).time == sys_clock))
	{
		(*(*task_point).function)();
		if ((*task_point).state == 0)
		{
			settimer((*task_point).function, (*task_point).time_size, (*task_point).state);
		}
		current_task = (*task_point).next_task;
		kfree(task_point, sizeof(struct timer_task));
		task_point = (*task_point).next_task;
	}
/*EOI*/
EOI:
	io_out8(0x20, 0x20);
	io_out8(0xA0, 0x20);
}

int_long settimer(void (*function)(void), unsigned long long time, unsigned char state)
{
	/*argument check*/
	if (time == 0) return -1;
	
	struct timer_task *new_task, *task_point;
	task_point = current_task;
	new_task = (struct timer_task *) kmalloc(sizeof(struct timer_task));
	(*new_task).time_size = time;
	(*new_task).time = sys_clock + time;
	(*new_task).state = state;
	(*new_task).function = function;
	if (current_task == NULL)
	{
		current_task = new_task;
		return 0;
	}else{
		while(((*task_point).time < (*new_task).time) && (*task_point).next_task != NULL)
		{
			task_point = (*task_point).next_task;
		}
		(*task_point).next_task = new_task;
	}
}
