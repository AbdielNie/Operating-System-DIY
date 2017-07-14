#ifndef TIMER_H_
#define TIMER_H_

#include "types.h"

#define PIT_CTRL	0x0043
#define PIT_CNT0	0x0040

extern int_timer;

void init_timer(void);
void int_timer_display(void);
void init_pit(void);

#endif
