
#include "../include/8259.h"
#include "../include/types.h"
void init_8259(void)
{
	io_out8(PIC0_IMR, 0xff);/*禁止主8259的所有中断*/
	io_out8(PIC1_IMR, 0xff);/*禁止从8259的所有中断*/

	io_out8(PIC0_ICW1, 0x11);/*边沿触发模式*/
	io_out8(PIC0_ICW2, 0x20);/*PIC 0~7 由int 0x20~0x27负责*/
	io_out8(PIC0_ICW3, 1 << 2);/*从8259跟PIC 2 相连*/
	io_out8(PIC0_ICW4, 0x01);/*无缓冲模式*/
	
	io_out8(PIC1_ICW1, 0x11);/*边沿触发*/
	io_out8(PIC1_ICW2, 0x28);/*PIC 8~15 由int 0x28~0x2f负责*/
	io_out8(PIC1_ICW3, 2);/*从8259跟PIC 2 相连*/
	io_out8(PIC1_ICW4, 0x01);/*无缓冲模式*/

	io_out8(PIC0_IMR, 0xfb);/*从8259之外全部禁止*/
	io_out8(PIC1_IMR, 0xff);/*禁止所有中断*/
	
	io_sti();/*开启可屏蔽中断*/
}

/*开放8259特定中断的函数
 *入口：IRQ号
 *出口：(-1):错误 0:正确
 */
int32 open_8259(u32 IRQ)
{
	if (IRQ > 15)
	{
		return (-1);
	}else if (IRQ <= 7)/*主8259*/
	{
		io_out8(PIC0_IMR, (io_in8(PIC0_IMR) & (~(1 << IRQ))));
	}else{/*从8259*/
		io_out8(PIC0_IMR, (io_in8(PIC0_IMR) & (~(1 << IRQ - 8))));
	}	
	return 0;
}
