#ifndef FAT32_H_
#define FAT32_H_

#include "types.h"

typedef struct
{
	u32 start;
	u32 size;/*字节算*/
}file_info;

void init_FAT32(void);
unsigned int get_next_clu(unsigned int clu);
unsigned int clu_to_sector(unsigned int clu_num);
void load_data(u32 addr, u32 clu);
unsigned int get_metadata(unsigned char *name);
void file_open(u8 *name, u32 addr);
file_info get_file_info(u8 *name);

#endif
