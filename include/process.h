
#ifndef PROCESS_H_
#define PROCESS_H_

#include "types.h"
#include "address.h"

#define THREAD_SIZE		8192

union thread_union kernel_thread;
union thread_union *thread_union_point;
u32 creat_thread_id;
u32 creat_process_id;

typedef u32 pid_t;

struct thread_info
{
	u32 count;
	u32 esp0;
	union thread_union *next_thread_union;
	u32 *cr3;
	u32 pid;
	u32 ppid;
	u32 default_count;
	u32 thread_id;
	u8 filename[32];
};

union thread_union
{
	struct thread_info thread_info;
	unsigned long stack[THREAD_SIZE / sizeof(long)];
};

struct header
{
	char flag[4];
	void *entry;
};

void init_process(void);
void Creat_process(u8 *filename);

u32 get_tid(void);
u32 get_ppid(void);
u32 get_pid(void);


#endif
