
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop

    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
int kern_init(void) __attribute__((noreturn));

int kern_init(void)
{
	extern char edata[], end[];
	memset(edata, 0, end - edata);
ffffffffc0200032:	00013517          	auipc	a0,0x13
ffffffffc0200036:	76e50513          	addi	a0,a0,1902 # ffffffffc02137a0 <ide>
ffffffffc020003a:	0001f617          	auipc	a2,0x1f
ffffffffc020003e:	8f660613          	addi	a2,a2,-1802 # ffffffffc021e930 <end>
{
ffffffffc0200042:	1141                	addi	sp,sp,-16
	memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
{
ffffffffc0200048:	e406                	sd	ra,8(sp)
	memset(edata, 0, end - edata);
ffffffffc020004a:	1ca040ef          	jal	ra,ffffffffc0204214 <memset>

	cons_init(); // init the console
ffffffffc020004e:	208000ef          	jal	ra,ffffffffc0200256 <cons_init>

	const char *message = " os is loading ...";
	cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	5f658593          	addi	a1,a1,1526 # ffffffffc0204648 <etext+0x6>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	60650513          	addi	a0,a0,1542 # ffffffffc0204660 <etext+0x1e>
ffffffffc0200062:	05e000ef          	jal	ra,ffffffffc02000c0 <cprintf>

	pmm_init(); // init physical memory management
ffffffffc0200066:	1e5000ef          	jal	ra,ffffffffc0200a4a <pmm_init>
	idt_init(); // init interrupt descriptor table
ffffffffc020006a:	22e000ef          	jal	ra,ffffffffc0200298 <idt_init>

	vmm_init(); // init virtual memory management
ffffffffc020006e:	213010ef          	jal	ra,ffffffffc0201a80 <vmm_init>
	proc_init(); // init process table
ffffffffc0200072:	64f030ef          	jal	ra,ffffffffc0203ec0 <proc_init>

	ide_init(); // init ide devices
ffffffffc0200076:	170000ef          	jal	ra,ffffffffc02001e6 <ide_init>
	swap_init(); // init swap
ffffffffc020007a:	73d010ef          	jal	ra,ffffffffc0201fb6 <swap_init>

	intr_enable(); // enable irq interrupt
ffffffffc020007e:	20e000ef          	jal	ra,ffffffffc020028c <intr_enable>

	cpu_idle(); // run idle process
ffffffffc0200082:	76f030ef          	jal	ra,ffffffffc0203ff0 <cpu_idle>

ffffffffc0200086 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt)
{
ffffffffc0200086:	1141                	addi	sp,sp,-16
ffffffffc0200088:	e022                	sd	s0,0(sp)
ffffffffc020008a:	e406                	sd	ra,8(sp)
ffffffffc020008c:	842e                	mv	s0,a1
	cons_putc(c);
ffffffffc020008e:	1ca000ef          	jal	ra,ffffffffc0200258 <cons_putc>
	(*cnt)++;
ffffffffc0200092:	401c                	lw	a5,0(s0)
}
ffffffffc0200094:	60a2                	ld	ra,8(sp)
	(*cnt)++;
ffffffffc0200096:	2785                	addiw	a5,a5,1
ffffffffc0200098:	c01c                	sw	a5,0(s0)
}
ffffffffc020009a:	6402                	ld	s0,0(sp)
ffffffffc020009c:	0141                	addi	sp,sp,16
ffffffffc020009e:	8082                	ret

ffffffffc02000a0 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc02000a0:	1101                	addi	sp,sp,-32
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	86ae                	mv	a3,a1
	int cnt = 0;
	vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fe050513          	addi	a0,a0,-32 # ffffffffc0200086 <cputch>
ffffffffc02000ae:	006c                	addi	a1,sp,12
{
ffffffffc02000b0:	ec06                	sd	ra,24(sp)
	int cnt = 0;
ffffffffc02000b2:	c602                	sw	zero,12(sp)
	vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000b4:	1f6040ef          	jal	ra,ffffffffc02042aa <vprintfmt>
	return cnt;
}
ffffffffc02000b8:	60e2                	ld	ra,24(sp)
ffffffffc02000ba:	4532                	lw	a0,12(sp)
ffffffffc02000bc:	6105                	addi	sp,sp,32
ffffffffc02000be:	8082                	ret

ffffffffc02000c0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc02000c0:	711d                	addi	sp,sp,-96
	va_list ap;
	int cnt;
	va_start(ap, fmt);
ffffffffc02000c2:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
{
ffffffffc02000c6:	8e2a                	mv	t3,a0
ffffffffc02000c8:	f42e                	sd	a1,40(sp)
ffffffffc02000ca:	f832                	sd	a2,48(sp)
ffffffffc02000cc:	fc36                	sd	a3,56(sp)
	vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb850513          	addi	a0,a0,-72 # ffffffffc0200086 <cputch>
ffffffffc02000d6:	004c                	addi	a1,sp,4
ffffffffc02000d8:	869a                	mv	a3,t1
ffffffffc02000da:	8672                	mv	a2,t3
{
ffffffffc02000dc:	ec06                	sd	ra,24(sp)
ffffffffc02000de:	e0ba                	sd	a4,64(sp)
ffffffffc02000e0:	e4be                	sd	a5,72(sp)
ffffffffc02000e2:	e8c2                	sd	a6,80(sp)
ffffffffc02000e4:	ecc6                	sd	a7,88(sp)
	va_start(ap, fmt);
ffffffffc02000e6:	e41a                	sd	t1,8(sp)
	int cnt = 0;
ffffffffc02000e8:	c202                	sw	zero,4(sp)
	vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02000ea:	1c0040ef          	jal	ra,ffffffffc02042aa <vprintfmt>
	cnt = vcprintf(fmt, ap);
	va_end(ap);
	return cnt;
}
ffffffffc02000ee:	60e2                	ld	ra,24(sp)
ffffffffc02000f0:	4512                	lw	a0,4(sp)
ffffffffc02000f2:	6125                	addi	sp,sp,96
ffffffffc02000f4:	8082                	ret

ffffffffc02000f6 <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
	cons_putc(c);
ffffffffc02000f6:	a28d                	j	ffffffffc0200258 <cons_putc>

ffffffffc02000f8 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int cputs(const char *str)
{
ffffffffc02000f8:	1101                	addi	sp,sp,-32
ffffffffc02000fa:	e822                	sd	s0,16(sp)
ffffffffc02000fc:	ec06                	sd	ra,24(sp)
ffffffffc02000fe:	e426                	sd	s1,8(sp)
ffffffffc0200100:	842a                	mv	s0,a0
	int cnt = 0;
	char c;
	while ((c = *str++) != '\0') {
ffffffffc0200102:	00054503          	lbu	a0,0(a0)
ffffffffc0200106:	c51d                	beqz	a0,ffffffffc0200134 <cputs+0x3c>
ffffffffc0200108:	0405                	addi	s0,s0,1
ffffffffc020010a:	4485                	li	s1,1
ffffffffc020010c:	9c81                	subw	s1,s1,s0
	cons_putc(c);
ffffffffc020010e:	14a000ef          	jal	ra,ffffffffc0200258 <cons_putc>
	while ((c = *str++) != '\0') {
ffffffffc0200112:	00044503          	lbu	a0,0(s0)
ffffffffc0200116:	008487bb          	addw	a5,s1,s0
ffffffffc020011a:	0405                	addi	s0,s0,1
ffffffffc020011c:	f96d                	bnez	a0,ffffffffc020010e <cputs+0x16>
ffffffffc020011e:	0017841b          	addiw	s0,a5,1
	cons_putc(c);
ffffffffc0200122:	4529                	li	a0,10
ffffffffc0200124:	134000ef          	jal	ra,ffffffffc0200258 <cons_putc>
		cputch(c, &cnt);
	}
	cputch('\n', &cnt);
	return cnt;
}
ffffffffc0200128:	60e2                	ld	ra,24(sp)
ffffffffc020012a:	8522                	mv	a0,s0
ffffffffc020012c:	6442                	ld	s0,16(sp)
ffffffffc020012e:	64a2                	ld	s1,8(sp)
ffffffffc0200130:	6105                	addi	sp,sp,32
ffffffffc0200132:	8082                	ret
	while ((c = *str++) != '\0') {
ffffffffc0200134:	4405                	li	s0,1
ffffffffc0200136:	b7f5                	j	ffffffffc0200122 <cputs+0x2a>

ffffffffc0200138 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void __panic(const char *file, int line, const char *fmt, ...)
{
	if (is_panic) {
ffffffffc0200138:	0001e317          	auipc	t1,0x1e
ffffffffc020013c:	66830313          	addi	t1,t1,1640 # ffffffffc021e7a0 <is_panic>
ffffffffc0200140:	00032e03          	lw	t3,0(t1)
{
ffffffffc0200144:	715d                	addi	sp,sp,-80
ffffffffc0200146:	ec06                	sd	ra,24(sp)
ffffffffc0200148:	e822                	sd	s0,16(sp)
ffffffffc020014a:	f436                	sd	a3,40(sp)
ffffffffc020014c:	f83a                	sd	a4,48(sp)
ffffffffc020014e:	fc3e                	sd	a5,56(sp)
ffffffffc0200150:	e0c2                	sd	a6,64(sp)
ffffffffc0200152:	e4c6                	sd	a7,72(sp)
	if (is_panic) {
ffffffffc0200154:	020e1a63          	bnez	t3,ffffffffc0200188 <__panic+0x50>
		goto panic_dead;
	}
	is_panic = 1;
ffffffffc0200158:	4785                	li	a5,1
ffffffffc020015a:	00f32023          	sw	a5,0(t1)

	// print the 'message'
	va_list ap;
	va_start(ap, fmt);
ffffffffc020015e:	8432                	mv	s0,a2
ffffffffc0200160:	103c                	addi	a5,sp,40
	cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200162:	862e                	mv	a2,a1
ffffffffc0200164:	85aa                	mv	a1,a0
ffffffffc0200166:	00004517          	auipc	a0,0x4
ffffffffc020016a:	50250513          	addi	a0,a0,1282 # ffffffffc0204668 <etext+0x26>
	va_start(ap, fmt);
ffffffffc020016e:	e43e                	sd	a5,8(sp)
	cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200170:	f51ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	vcprintf(fmt, ap);
ffffffffc0200174:	65a2                	ld	a1,8(sp)
ffffffffc0200176:	8522                	mv	a0,s0
ffffffffc0200178:	f29ff0ef          	jal	ra,ffffffffc02000a0 <vcprintf>
	cprintf("\n");
ffffffffc020017c:	00005517          	auipc	a0,0x5
ffffffffc0200180:	72c50513          	addi	a0,a0,1836 # ffffffffc02058a8 <default_pmm_manager+0xd8>
ffffffffc0200184:	f3dff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200188:	4501                	li	a0,0
ffffffffc020018a:	4581                	li	a1,0
ffffffffc020018c:	4601                	li	a2,0
ffffffffc020018e:	48a1                	li	a7,8
ffffffffc0200190:	00000073          	ecall
	va_end(ap);

panic_dead:
	// No debug monitor here
	sbi_shutdown();
	intr_disable();
ffffffffc0200194:	0fe000ef          	jal	ra,ffffffffc0200292 <intr_disable>
	while (1) {
		kmonitor(NULL);
ffffffffc0200198:	4501                	li	a0,0
ffffffffc020019a:	04a000ef          	jal	ra,ffffffffc02001e4 <kmonitor>
	while (1) {
ffffffffc020019e:	bfed                	j	ffffffffc0200198 <__panic+0x60>

ffffffffc02001a0 <__warn>:
	}
}

/* __warn - like panic, but don't */
void __warn(const char *file, int line, const char *fmt, ...)
{
ffffffffc02001a0:	715d                	addi	sp,sp,-80
ffffffffc02001a2:	832e                	mv	t1,a1
ffffffffc02001a4:	e822                	sd	s0,16(sp)
	va_list ap;
	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02001a6:	85aa                	mv	a1,a0
{
ffffffffc02001a8:	8432                	mv	s0,a2
ffffffffc02001aa:	fc3e                	sd	a5,56(sp)
	cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02001ac:	861a                	mv	a2,t1
	va_start(ap, fmt);
ffffffffc02001ae:	103c                	addi	a5,sp,40
	cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02001b0:	00004517          	auipc	a0,0x4
ffffffffc02001b4:	4d850513          	addi	a0,a0,1240 # ffffffffc0204688 <etext+0x46>
{
ffffffffc02001b8:	ec06                	sd	ra,24(sp)
ffffffffc02001ba:	f436                	sd	a3,40(sp)
ffffffffc02001bc:	f83a                	sd	a4,48(sp)
ffffffffc02001be:	e0c2                	sd	a6,64(sp)
ffffffffc02001c0:	e4c6                	sd	a7,72(sp)
	va_start(ap, fmt);
ffffffffc02001c2:	e43e                	sd	a5,8(sp)
	cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02001c4:	efdff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	vcprintf(fmt, ap);
ffffffffc02001c8:	65a2                	ld	a1,8(sp)
ffffffffc02001ca:	8522                	mv	a0,s0
ffffffffc02001cc:	ed5ff0ef          	jal	ra,ffffffffc02000a0 <vcprintf>
	cprintf("\n");
ffffffffc02001d0:	00005517          	auipc	a0,0x5
ffffffffc02001d4:	6d850513          	addi	a0,a0,1752 # ffffffffc02058a8 <default_pmm_manager+0xd8>
ffffffffc02001d8:	ee9ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	va_end(ap);
}
ffffffffc02001dc:	60e2                	ld	ra,24(sp)
ffffffffc02001de:	6442                	ld	s0,16(sp)
ffffffffc02001e0:	6161                	addi	sp,sp,80
ffffffffc02001e2:	8082                	ret

ffffffffc02001e4 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void kmonitor(struct trapframe *tf)
{
	while (1)
ffffffffc02001e4:	a001                	j	ffffffffc02001e4 <kmonitor>

ffffffffc02001e6 <ide_init>:
#include <string.h>
#include <trap.h>

void ide_init(void)
{
}
ffffffffc02001e6:	8082                	ret

ffffffffc02001e8 <ide_device_valid>:
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno)
{
	return ideno < MAX_IDE;
}
ffffffffc02001e8:	00253513          	sltiu	a0,a0,2
ffffffffc02001ec:	8082                	ret

ffffffffc02001ee <ide_device_size>:

size_t ide_device_size(unsigned short ideno)
{
	return MAX_DISK_NSECS;
}
ffffffffc02001ee:	03800513          	li	a0,56
ffffffffc02001f2:	8082                	ret

ffffffffc02001f4 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs)
{
	int iobase = secno * SECTSIZE;
	memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02001f4:	00013797          	auipc	a5,0x13
ffffffffc02001f8:	5ac78793          	addi	a5,a5,1452 # ffffffffc02137a0 <ide>
	int iobase = secno * SECTSIZE;
ffffffffc02001fc:	0095959b          	slliw	a1,a1,0x9
{
ffffffffc0200200:	1141                	addi	sp,sp,-16
ffffffffc0200202:	8532                	mv	a0,a2
	memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200204:	95be                	add	a1,a1,a5
ffffffffc0200206:	00969613          	slli	a2,a3,0x9
{
ffffffffc020020a:	e406                	sd	ra,8(sp)
	memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020020c:	01a040ef          	jal	ra,ffffffffc0204226 <memcpy>
	return 0;
}
ffffffffc0200210:	60a2                	ld	ra,8(sp)
ffffffffc0200212:	4501                	li	a0,0
ffffffffc0200214:	0141                	addi	sp,sp,16
ffffffffc0200216:	8082                	ret

ffffffffc0200218 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
		   size_t nsecs)
{
	int iobase = secno * SECTSIZE;
ffffffffc0200218:	0095979b          	slliw	a5,a1,0x9
	memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc020021c:	00013517          	auipc	a0,0x13
ffffffffc0200220:	58450513          	addi	a0,a0,1412 # ffffffffc02137a0 <ide>
{
ffffffffc0200224:	1141                	addi	sp,sp,-16
ffffffffc0200226:	85b2                	mv	a1,a2
	memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200228:	953e                	add	a0,a0,a5
ffffffffc020022a:	00969613          	slli	a2,a3,0x9
{
ffffffffc020022e:	e406                	sd	ra,8(sp)
	memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200230:	7f7030ef          	jal	ra,ffffffffc0204226 <memcpy>
	return 0;
}
ffffffffc0200234:	60a2                	ld	ra,8(sp)
ffffffffc0200236:	4501                	li	a0,0
ffffffffc0200238:	0141                	addi	sp,sp,16
ffffffffc020023a:	8082                	ret

ffffffffc020023c <clock_set_next_event>:

static inline uint64_t get_cycles(void)
{
#if __riscv_xlen == 64
	uint64_t n;
	__asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020023c:	c0102573          	rdtime	a0
	cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void)
{
	sbi_set_timer(get_cycles() + timebase);
ffffffffc0200240:	0001e797          	auipc	a5,0x1e
ffffffffc0200244:	5687b783          	ld	a5,1384(a5) # ffffffffc021e7a8 <timebase>
ffffffffc0200248:	953e                	add	a0,a0,a5
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020024a:	4581                	li	a1,0
ffffffffc020024c:	4601                	li	a2,0
ffffffffc020024e:	4881                	li	a7,0
ffffffffc0200250:	00000073          	ecall
}
ffffffffc0200254:	8082                	ret

ffffffffc0200256 <cons_init>:
}

/* cons_init - initializes the console devices */
void cons_init(void)
{
}
ffffffffc0200256:	8082                	ret

ffffffffc0200258 <cons_putc>:
#include <riscv.h>
#include <sched.h>

static inline bool __intr_save(void)
{
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200258:	100027f3          	csrr	a5,sstatus
ffffffffc020025c:	8b89                	andi	a5,a5,2
ffffffffc020025e:	0ff57513          	andi	a0,a0,255
ffffffffc0200262:	e799                	bnez	a5,ffffffffc0200270 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200264:	4581                	li	a1,0
ffffffffc0200266:	4601                	li	a2,0
ffffffffc0200268:	4885                	li	a7,1
ffffffffc020026a:	00000073          	ecall
	return 0;
}

static inline void __intr_restore(bool flag)
{
	if (flag) {
ffffffffc020026e:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c)
{
ffffffffc0200270:	1101                	addi	sp,sp,-32
ffffffffc0200272:	ec06                	sd	ra,24(sp)
ffffffffc0200274:	e42a                	sd	a0,8(sp)
		intr_disable();
ffffffffc0200276:	01c000ef          	jal	ra,ffffffffc0200292 <intr_disable>
ffffffffc020027a:	6522                	ld	a0,8(sp)
ffffffffc020027c:	4581                	li	a1,0
ffffffffc020027e:	4601                	li	a2,0
ffffffffc0200280:	4885                	li	a7,1
ffffffffc0200282:	00000073          	ecall
	local_intr_save(intr_flag);
	{
		sbi_console_putchar((unsigned char)c);
	}
	local_intr_restore(intr_flag);
}
ffffffffc0200286:	60e2                	ld	ra,24(sp)
ffffffffc0200288:	6105                	addi	sp,sp,32
		intr_enable();
ffffffffc020028a:	a009                	j	ffffffffc020028c <intr_enable>

ffffffffc020028c <intr_enable>:
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void)
{
	set_csr(sstatus, SSTATUS_SIE);
ffffffffc020028c:	100167f3          	csrrsi	a5,sstatus,2
}
ffffffffc0200290:	8082                	ret

ffffffffc0200292 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void)
{
	clear_csr(sstatus, SSTATUS_SIE);
ffffffffc0200292:	100177f3          	csrrci	a5,sstatus,2
}
ffffffffc0200296:	8082                	ret

ffffffffc0200298 <idt_init>:
void idt_init(void)
{
	extern void __alltraps(void);
	/* Set sscratch register to 0, indicating to exception vector that we are
   * presently executing in the kernel */
	write_csr(sscratch, 0);
ffffffffc0200298:	14005073          	csrwi	sscratch,0
	/* Set the exception vector address */
	write_csr(stvec, &__alltraps);
ffffffffc020029c:	00000797          	auipc	a5,0x0
ffffffffc02002a0:	5b478793          	addi	a5,a5,1460 # ffffffffc0200850 <__alltraps>
ffffffffc02002a4:	10579073          	csrw	stvec,a5
	/* Allow kernel to access user memory */
	set_csr(sstatus, SSTATUS_SUM);
ffffffffc02002a8:	000407b7          	lui	a5,0x40
ffffffffc02002ac:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc02002b0:	8082                	ret

ffffffffc02002b2 <print_regs>:
	cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
	cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02002b2:	610c                	ld	a1,0(a0)
{
ffffffffc02002b4:	1141                	addi	sp,sp,-16
ffffffffc02002b6:	e022                	sd	s0,0(sp)
ffffffffc02002b8:	842a                	mv	s0,a0
	cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02002ba:	00004517          	auipc	a0,0x4
ffffffffc02002be:	3ee50513          	addi	a0,a0,1006 # ffffffffc02046a8 <etext+0x66>
{
ffffffffc02002c2:	e406                	sd	ra,8(sp)
	cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02002c4:	dfdff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02002c8:	640c                	ld	a1,8(s0)
ffffffffc02002ca:	00004517          	auipc	a0,0x4
ffffffffc02002ce:	3f650513          	addi	a0,a0,1014 # ffffffffc02046c0 <etext+0x7e>
ffffffffc02002d2:	defff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02002d6:	680c                	ld	a1,16(s0)
ffffffffc02002d8:	00004517          	auipc	a0,0x4
ffffffffc02002dc:	40050513          	addi	a0,a0,1024 # ffffffffc02046d8 <etext+0x96>
ffffffffc02002e0:	de1ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02002e4:	6c0c                	ld	a1,24(s0)
ffffffffc02002e6:	00004517          	auipc	a0,0x4
ffffffffc02002ea:	40a50513          	addi	a0,a0,1034 # ffffffffc02046f0 <etext+0xae>
ffffffffc02002ee:	dd3ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02002f2:	700c                	ld	a1,32(s0)
ffffffffc02002f4:	00004517          	auipc	a0,0x4
ffffffffc02002f8:	41450513          	addi	a0,a0,1044 # ffffffffc0204708 <etext+0xc6>
ffffffffc02002fc:	dc5ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200300:	740c                	ld	a1,40(s0)
ffffffffc0200302:	00004517          	auipc	a0,0x4
ffffffffc0200306:	41e50513          	addi	a0,a0,1054 # ffffffffc0204720 <etext+0xde>
ffffffffc020030a:	db7ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc020030e:	780c                	ld	a1,48(s0)
ffffffffc0200310:	00004517          	auipc	a0,0x4
ffffffffc0200314:	42850513          	addi	a0,a0,1064 # ffffffffc0204738 <etext+0xf6>
ffffffffc0200318:	da9ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc020031c:	7c0c                	ld	a1,56(s0)
ffffffffc020031e:	00004517          	auipc	a0,0x4
ffffffffc0200322:	43250513          	addi	a0,a0,1074 # ffffffffc0204750 <etext+0x10e>
ffffffffc0200326:	d9bff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc020032a:	602c                	ld	a1,64(s0)
ffffffffc020032c:	00004517          	auipc	a0,0x4
ffffffffc0200330:	43c50513          	addi	a0,a0,1084 # ffffffffc0204768 <etext+0x126>
ffffffffc0200334:	d8dff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200338:	642c                	ld	a1,72(s0)
ffffffffc020033a:	00004517          	auipc	a0,0x4
ffffffffc020033e:	44650513          	addi	a0,a0,1094 # ffffffffc0204780 <etext+0x13e>
ffffffffc0200342:	d7fff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200346:	682c                	ld	a1,80(s0)
ffffffffc0200348:	00004517          	auipc	a0,0x4
ffffffffc020034c:	45050513          	addi	a0,a0,1104 # ffffffffc0204798 <etext+0x156>
ffffffffc0200350:	d71ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200354:	6c2c                	ld	a1,88(s0)
ffffffffc0200356:	00004517          	auipc	a0,0x4
ffffffffc020035a:	45a50513          	addi	a0,a0,1114 # ffffffffc02047b0 <etext+0x16e>
ffffffffc020035e:	d63ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200362:	702c                	ld	a1,96(s0)
ffffffffc0200364:	00004517          	auipc	a0,0x4
ffffffffc0200368:	46450513          	addi	a0,a0,1124 # ffffffffc02047c8 <etext+0x186>
ffffffffc020036c:	d55ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200370:	742c                	ld	a1,104(s0)
ffffffffc0200372:	00004517          	auipc	a0,0x4
ffffffffc0200376:	46e50513          	addi	a0,a0,1134 # ffffffffc02047e0 <etext+0x19e>
ffffffffc020037a:	d47ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020037e:	782c                	ld	a1,112(s0)
ffffffffc0200380:	00004517          	auipc	a0,0x4
ffffffffc0200384:	47850513          	addi	a0,a0,1144 # ffffffffc02047f8 <etext+0x1b6>
ffffffffc0200388:	d39ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020038c:	7c2c                	ld	a1,120(s0)
ffffffffc020038e:	00004517          	auipc	a0,0x4
ffffffffc0200392:	48250513          	addi	a0,a0,1154 # ffffffffc0204810 <etext+0x1ce>
ffffffffc0200396:	d2bff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020039a:	604c                	ld	a1,128(s0)
ffffffffc020039c:	00004517          	auipc	a0,0x4
ffffffffc02003a0:	48c50513          	addi	a0,a0,1164 # ffffffffc0204828 <etext+0x1e6>
ffffffffc02003a4:	d1dff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc02003a8:	644c                	ld	a1,136(s0)
ffffffffc02003aa:	00004517          	auipc	a0,0x4
ffffffffc02003ae:	49650513          	addi	a0,a0,1174 # ffffffffc0204840 <etext+0x1fe>
ffffffffc02003b2:	d0fff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc02003b6:	684c                	ld	a1,144(s0)
ffffffffc02003b8:	00004517          	auipc	a0,0x4
ffffffffc02003bc:	4a050513          	addi	a0,a0,1184 # ffffffffc0204858 <etext+0x216>
ffffffffc02003c0:	d01ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02003c4:	6c4c                	ld	a1,152(s0)
ffffffffc02003c6:	00004517          	auipc	a0,0x4
ffffffffc02003ca:	4aa50513          	addi	a0,a0,1194 # ffffffffc0204870 <etext+0x22e>
ffffffffc02003ce:	cf3ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02003d2:	704c                	ld	a1,160(s0)
ffffffffc02003d4:	00004517          	auipc	a0,0x4
ffffffffc02003d8:	4b450513          	addi	a0,a0,1204 # ffffffffc0204888 <etext+0x246>
ffffffffc02003dc:	ce5ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02003e0:	744c                	ld	a1,168(s0)
ffffffffc02003e2:	00004517          	auipc	a0,0x4
ffffffffc02003e6:	4be50513          	addi	a0,a0,1214 # ffffffffc02048a0 <etext+0x25e>
ffffffffc02003ea:	cd7ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02003ee:	784c                	ld	a1,176(s0)
ffffffffc02003f0:	00004517          	auipc	a0,0x4
ffffffffc02003f4:	4c850513          	addi	a0,a0,1224 # ffffffffc02048b8 <etext+0x276>
ffffffffc02003f8:	cc9ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02003fc:	7c4c                	ld	a1,184(s0)
ffffffffc02003fe:	00004517          	auipc	a0,0x4
ffffffffc0200402:	4d250513          	addi	a0,a0,1234 # ffffffffc02048d0 <etext+0x28e>
ffffffffc0200406:	cbbff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc020040a:	606c                	ld	a1,192(s0)
ffffffffc020040c:	00004517          	auipc	a0,0x4
ffffffffc0200410:	4dc50513          	addi	a0,a0,1244 # ffffffffc02048e8 <etext+0x2a6>
ffffffffc0200414:	cadff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200418:	646c                	ld	a1,200(s0)
ffffffffc020041a:	00004517          	auipc	a0,0x4
ffffffffc020041e:	4e650513          	addi	a0,a0,1254 # ffffffffc0204900 <etext+0x2be>
ffffffffc0200422:	c9fff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200426:	686c                	ld	a1,208(s0)
ffffffffc0200428:	00004517          	auipc	a0,0x4
ffffffffc020042c:	4f050513          	addi	a0,a0,1264 # ffffffffc0204918 <etext+0x2d6>
ffffffffc0200430:	c91ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200434:	6c6c                	ld	a1,216(s0)
ffffffffc0200436:	00004517          	auipc	a0,0x4
ffffffffc020043a:	4fa50513          	addi	a0,a0,1274 # ffffffffc0204930 <etext+0x2ee>
ffffffffc020043e:	c83ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200442:	706c                	ld	a1,224(s0)
ffffffffc0200444:	00004517          	auipc	a0,0x4
ffffffffc0200448:	50450513          	addi	a0,a0,1284 # ffffffffc0204948 <etext+0x306>
ffffffffc020044c:	c75ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200450:	746c                	ld	a1,232(s0)
ffffffffc0200452:	00004517          	auipc	a0,0x4
ffffffffc0200456:	50e50513          	addi	a0,a0,1294 # ffffffffc0204960 <etext+0x31e>
ffffffffc020045a:	c67ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020045e:	786c                	ld	a1,240(s0)
ffffffffc0200460:	00004517          	auipc	a0,0x4
ffffffffc0200464:	51850513          	addi	a0,a0,1304 # ffffffffc0204978 <etext+0x336>
ffffffffc0200468:	c59ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020046c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020046e:	6402                	ld	s0,0(sp)
ffffffffc0200470:	60a2                	ld	ra,8(sp)
	cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200472:	00004517          	auipc	a0,0x4
ffffffffc0200476:	51e50513          	addi	a0,a0,1310 # ffffffffc0204990 <etext+0x34e>
}
ffffffffc020047a:	0141                	addi	sp,sp,16
	cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020047c:	b191                	j	ffffffffc02000c0 <cprintf>

ffffffffc020047e <print_trapframe>:
{
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
	cprintf("trapframe at %p\n", tf);
ffffffffc0200482:	85aa                	mv	a1,a0
{
ffffffffc0200484:	842a                	mv	s0,a0
	cprintf("trapframe at %p\n", tf);
ffffffffc0200486:	00004517          	auipc	a0,0x4
ffffffffc020048a:	52250513          	addi	a0,a0,1314 # ffffffffc02049a8 <etext+0x366>
{
ffffffffc020048e:	e406                	sd	ra,8(sp)
	cprintf("trapframe at %p\n", tf);
ffffffffc0200490:	c31ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	print_regs(&tf->gpr);
ffffffffc0200494:	8522                	mv	a0,s0
ffffffffc0200496:	e1dff0ef          	jal	ra,ffffffffc02002b2 <print_regs>
	cprintf("  status   0x%08x\n", tf->status);
ffffffffc020049a:	10043583          	ld	a1,256(s0)
ffffffffc020049e:	00004517          	auipc	a0,0x4
ffffffffc02004a2:	52250513          	addi	a0,a0,1314 # ffffffffc02049c0 <etext+0x37e>
ffffffffc02004a6:	c1bff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc02004aa:	10843583          	ld	a1,264(s0)
ffffffffc02004ae:	00004517          	auipc	a0,0x4
ffffffffc02004b2:	52a50513          	addi	a0,a0,1322 # ffffffffc02049d8 <etext+0x396>
ffffffffc02004b6:	c0bff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc02004ba:	11043583          	ld	a1,272(s0)
ffffffffc02004be:	00004517          	auipc	a0,0x4
ffffffffc02004c2:	53250513          	addi	a0,a0,1330 # ffffffffc02049f0 <etext+0x3ae>
ffffffffc02004c6:	bfbff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02004ca:	11843583          	ld	a1,280(s0)
}
ffffffffc02004ce:	6402                	ld	s0,0(sp)
ffffffffc02004d0:	60a2                	ld	ra,8(sp)
	cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02004d2:	00004517          	auipc	a0,0x4
ffffffffc02004d6:	52e50513          	addi	a0,a0,1326 # ffffffffc0204a00 <etext+0x3be>
}
ffffffffc02004da:	0141                	addi	sp,sp,16
	cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02004dc:	b6d5                	j	ffffffffc02000c0 <cprintf>

ffffffffc02004de <pgfault_handler>:
		trap_in_kernel(tf) ? 'K' : 'U',
		tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf)
{
ffffffffc02004de:	1101                	addi	sp,sp,-32
ffffffffc02004e0:	e426                	sd	s1,8(sp)
	extern struct mm_struct *check_mm_struct;
	if (check_mm_struct != NULL) { // used for test check_swap
ffffffffc02004e2:	0001e497          	auipc	s1,0x1e
ffffffffc02004e6:	35648493          	addi	s1,s1,854 # ffffffffc021e838 <check_mm_struct>
ffffffffc02004ea:	609c                	ld	a5,0(s1)
{
ffffffffc02004ec:	e822                	sd	s0,16(sp)
ffffffffc02004ee:	ec06                	sd	ra,24(sp)
ffffffffc02004f0:	842a                	mv	s0,a0
	if (check_mm_struct != NULL) { // used for test check_swap
ffffffffc02004f2:	cbad                	beqz	a5,ffffffffc0200564 <pgfault_handler+0x86>
	return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
	cprintf("page falut at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02004f8:	11053583          	ld	a1,272(a0)
ffffffffc02004fc:	04b00613          	li	a2,75
	return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200500:	1007f793          	andi	a5,a5,256
	cprintf("page falut at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200504:	c7b1                	beqz	a5,ffffffffc0200550 <pgfault_handler+0x72>
ffffffffc0200506:	11843703          	ld	a4,280(s0)
ffffffffc020050a:	47bd                	li	a5,15
ffffffffc020050c:	05700693          	li	a3,87
ffffffffc0200510:	00f70463          	beq	a4,a5,ffffffffc0200518 <pgfault_handler+0x3a>
ffffffffc0200514:	05200693          	li	a3,82
ffffffffc0200518:	00004517          	auipc	a0,0x4
ffffffffc020051c:	50050513          	addi	a0,a0,1280 # ffffffffc0204a18 <etext+0x3d6>
ffffffffc0200520:	ba1ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
		print_pgfault(tf);
	}
	struct mm_struct *mm;
	if (check_mm_struct != NULL) {
ffffffffc0200524:	6088                	ld	a0,0(s1)
ffffffffc0200526:	cd1d                	beqz	a0,ffffffffc0200564 <pgfault_handler+0x86>
		assert(current == idleproc);
ffffffffc0200528:	0001e717          	auipc	a4,0x1e
ffffffffc020052c:	2b873703          	ld	a4,696(a4) # ffffffffc021e7e0 <current>
ffffffffc0200530:	0001e797          	auipc	a5,0x1e
ffffffffc0200534:	2b87b783          	ld	a5,696(a5) # ffffffffc021e7e8 <idleproc>
ffffffffc0200538:	04f71663          	bne	a4,a5,ffffffffc0200584 <pgfault_handler+0xa6>
			print_pgfault(tf);
			panic("unhandled page fault.\n");
		}
		mm = current->mm;
	}
	return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020053c:	11043603          	ld	a2,272(s0)
ffffffffc0200540:	11843583          	ld	a1,280(s0)
}
ffffffffc0200544:	6442                	ld	s0,16(sp)
ffffffffc0200546:	60e2                	ld	ra,24(sp)
ffffffffc0200548:	64a2                	ld	s1,8(sp)
ffffffffc020054a:	6105                	addi	sp,sp,32
	return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020054c:	5360106f          	j	ffffffffc0201a82 <do_pgfault>
	cprintf("page falut at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200550:	11843703          	ld	a4,280(s0)
ffffffffc0200554:	47bd                	li	a5,15
ffffffffc0200556:	05500613          	li	a2,85
ffffffffc020055a:	05700693          	li	a3,87
ffffffffc020055e:	faf71be3          	bne	a4,a5,ffffffffc0200514 <pgfault_handler+0x36>
ffffffffc0200562:	bf5d                	j	ffffffffc0200518 <pgfault_handler+0x3a>
		if (current == NULL) {
ffffffffc0200564:	0001e797          	auipc	a5,0x1e
ffffffffc0200568:	27c7b783          	ld	a5,636(a5) # ffffffffc021e7e0 <current>
ffffffffc020056c:	cf85                	beqz	a5,ffffffffc02005a4 <pgfault_handler+0xc6>
	return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020056e:	11043603          	ld	a2,272(s0)
ffffffffc0200572:	11843583          	ld	a1,280(s0)
}
ffffffffc0200576:	6442                	ld	s0,16(sp)
ffffffffc0200578:	60e2                	ld	ra,24(sp)
ffffffffc020057a:	64a2                	ld	s1,8(sp)
		mm = current->mm;
ffffffffc020057c:	7788                	ld	a0,40(a5)
}
ffffffffc020057e:	6105                	addi	sp,sp,32
	return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200580:	5020106f          	j	ffffffffc0201a82 <do_pgfault>
		assert(current == idleproc);
ffffffffc0200584:	00004697          	auipc	a3,0x4
ffffffffc0200588:	4b468693          	addi	a3,a3,1204 # ffffffffc0204a38 <etext+0x3f6>
ffffffffc020058c:	00004617          	auipc	a2,0x4
ffffffffc0200590:	4c460613          	addi	a2,a2,1220 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0200594:	07000593          	li	a1,112
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	4d050513          	addi	a0,a0,1232 # ffffffffc0204a68 <etext+0x426>
ffffffffc02005a0:	b99ff0ef          	jal	ra,ffffffffc0200138 <__panic>
			print_trapframe(tf);
ffffffffc02005a4:	8522                	mv	a0,s0
ffffffffc02005a6:	ed9ff0ef          	jal	ra,ffffffffc020047e <print_trapframe>
	return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005aa:	10043783          	ld	a5,256(s0)
	cprintf("page falut at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02005ae:	11043583          	ld	a1,272(s0)
ffffffffc02005b2:	04b00613          	li	a2,75
	return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02005b6:	1007f793          	andi	a5,a5,256
	cprintf("page falut at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02005ba:	e399                	bnez	a5,ffffffffc02005c0 <pgfault_handler+0xe2>
ffffffffc02005bc:	05500613          	li	a2,85
ffffffffc02005c0:	11843703          	ld	a4,280(s0)
ffffffffc02005c4:	47bd                	li	a5,15
ffffffffc02005c6:	02f70663          	beq	a4,a5,ffffffffc02005f2 <pgfault_handler+0x114>
ffffffffc02005ca:	05200693          	li	a3,82
ffffffffc02005ce:	00004517          	auipc	a0,0x4
ffffffffc02005d2:	44a50513          	addi	a0,a0,1098 # ffffffffc0204a18 <etext+0x3d6>
ffffffffc02005d6:	aebff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
			panic("unhandled page fault.\n");
ffffffffc02005da:	00004617          	auipc	a2,0x4
ffffffffc02005de:	4a660613          	addi	a2,a2,1190 # ffffffffc0204a80 <etext+0x43e>
ffffffffc02005e2:	07600593          	li	a1,118
ffffffffc02005e6:	00004517          	auipc	a0,0x4
ffffffffc02005ea:	48250513          	addi	a0,a0,1154 # ffffffffc0204a68 <etext+0x426>
ffffffffc02005ee:	b4bff0ef          	jal	ra,ffffffffc0200138 <__panic>
	cprintf("page falut at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02005f2:	05700693          	li	a3,87
ffffffffc02005f6:	bfe1                	j	ffffffffc02005ce <pgfault_handler+0xf0>

ffffffffc02005f8 <interrupt_handler>:
static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
	intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02005f8:	11853783          	ld	a5,280(a0)
ffffffffc02005fc:	472d                	li	a4,11
ffffffffc02005fe:	0786                	slli	a5,a5,0x1
ffffffffc0200600:	8385                	srli	a5,a5,0x1
ffffffffc0200602:	06f76e63          	bltu	a4,a5,ffffffffc020067e <interrupt_handler+0x86>
ffffffffc0200606:	00004717          	auipc	a4,0x4
ffffffffc020060a:	53270713          	addi	a4,a4,1330 # ffffffffc0204b38 <etext+0x4f6>
ffffffffc020060e:	078a                	slli	a5,a5,0x2
ffffffffc0200610:	97ba                	add	a5,a5,a4
ffffffffc0200612:	439c                	lw	a5,0(a5)
ffffffffc0200614:	97ba                	add	a5,a5,a4
ffffffffc0200616:	8782                	jr	a5
		break;
	case IRQ_H_SOFT:
		cprintf("Hypervisor software interrupt\n");
		break;
	case IRQ_M_SOFT:
		cprintf("Machine software interrupt\n");
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	4e050513          	addi	a0,a0,1248 # ffffffffc0204af8 <etext+0x4b6>
ffffffffc0200620:	b445                	j	ffffffffc02000c0 <cprintf>
		cprintf("Hypervisor software interrupt\n");
ffffffffc0200622:	00004517          	auipc	a0,0x4
ffffffffc0200626:	4b650513          	addi	a0,a0,1206 # ffffffffc0204ad8 <etext+0x496>
ffffffffc020062a:	bc59                	j	ffffffffc02000c0 <cprintf>
		cprintf("User software interrupt\n");
ffffffffc020062c:	00004517          	auipc	a0,0x4
ffffffffc0200630:	46c50513          	addi	a0,a0,1132 # ffffffffc0204a98 <etext+0x456>
ffffffffc0200634:	b471                	j	ffffffffc02000c0 <cprintf>
		cprintf("Supervisor software interrupt\n");
ffffffffc0200636:	00004517          	auipc	a0,0x4
ffffffffc020063a:	48250513          	addi	a0,a0,1154 # ffffffffc0204ab8 <etext+0x476>
ffffffffc020063e:	b449                	j	ffffffffc02000c0 <cprintf>
{
ffffffffc0200640:	1141                	addi	sp,sp,-16
ffffffffc0200642:	e406                	sd	ra,8(sp)
		// "All bits besides SSIP and USIP in the sip register are
		// read-only." -- privileged spec1.9.1, 4.1.4, p59
		// In fact, Call sbi_set_timer will clear STIP, or you can clear it
		// directly.
		// clear_csr(sip, SIP_STIP);
		clock_set_next_event();
ffffffffc0200644:	bf9ff0ef          	jal	ra,ffffffffc020023c <clock_set_next_event>
		if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200648:	0001e697          	auipc	a3,0x1e
ffffffffc020064c:	1b868693          	addi	a3,a3,440 # ffffffffc021e800 <ticks>
ffffffffc0200650:	629c                	ld	a5,0(a3)
ffffffffc0200652:	06400713          	li	a4,100
ffffffffc0200656:	0785                	addi	a5,a5,1
ffffffffc0200658:	02e7f733          	remu	a4,a5,a4
ffffffffc020065c:	e29c                	sd	a5,0(a3)
ffffffffc020065e:	eb01                	bnez	a4,ffffffffc020066e <interrupt_handler+0x76>
ffffffffc0200660:	0001e797          	auipc	a5,0x1e
ffffffffc0200664:	1807b783          	ld	a5,384(a5) # ffffffffc021e7e0 <current>
ffffffffc0200668:	c399                	beqz	a5,ffffffffc020066e <interrupt_handler+0x76>
			// print_ticks();
			current->need_resched = 1;
ffffffffc020066a:	4705                	li	a4,1
ffffffffc020066c:	cf98                	sw	a4,24(a5)
		break;
	default:
		print_trapframe(tf);
		break;
	}
}
ffffffffc020066e:	60a2                	ld	ra,8(sp)
ffffffffc0200670:	0141                	addi	sp,sp,16
ffffffffc0200672:	8082                	ret
		cprintf("Supervisor external interrupt\n");
ffffffffc0200674:	00004517          	auipc	a0,0x4
ffffffffc0200678:	4a450513          	addi	a0,a0,1188 # ffffffffc0204b18 <etext+0x4d6>
ffffffffc020067c:	b491                	j	ffffffffc02000c0 <cprintf>
		print_trapframe(tf);
ffffffffc020067e:	b501                	j	ffffffffc020047e <print_trapframe>

ffffffffc0200680 <exception_handler>:

void exception_handler(struct trapframe *tf)
{
	int ret;
	switch (tf->cause) {
ffffffffc0200680:	11853783          	ld	a5,280(a0)
{
ffffffffc0200684:	1101                	addi	sp,sp,-32
ffffffffc0200686:	e822                	sd	s0,16(sp)
ffffffffc0200688:	ec06                	sd	ra,24(sp)
ffffffffc020068a:	e426                	sd	s1,8(sp)
ffffffffc020068c:	473d                	li	a4,15
ffffffffc020068e:	842a                	mv	s0,a0
ffffffffc0200690:	16f76063          	bltu	a4,a5,ffffffffc02007f0 <exception_handler+0x170>
ffffffffc0200694:	00004717          	auipc	a4,0x4
ffffffffc0200698:	66c70713          	addi	a4,a4,1644 # ffffffffc0204d00 <etext+0x6be>
ffffffffc020069c:	078a                	slli	a5,a5,0x2
ffffffffc020069e:	97ba                	add	a5,a5,a4
ffffffffc02006a0:	439c                	lw	a5,0(a5)
ffffffffc02006a2:	97ba                	add	a5,a5,a4
ffffffffc02006a4:	8782                	jr	a5
		// cprintf("Environment call from U-mode\n");
		tf->epc += 4;
		syscall();
		break;
	case CAUSE_SUPERVISOR_ECALL:
		cprintf("Environment call from S-mode\n");
ffffffffc02006a6:	00004517          	auipc	a0,0x4
ffffffffc02006aa:	5b250513          	addi	a0,a0,1458 # ffffffffc0204c58 <etext+0x616>
ffffffffc02006ae:	a13ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
		tf->epc += 4;
ffffffffc02006b2:	10843783          	ld	a5,264(s0)
ffffffffc02006b6:	0791                	addi	a5,a5,4
ffffffffc02006b8:	10f43423          	sd	a5,264(s0)
		break;
	default:
		print_trapframe(tf);
		break;
	}
}
ffffffffc02006bc:	6442                	ld	s0,16(sp)
ffffffffc02006be:	60e2                	ld	ra,24(sp)
ffffffffc02006c0:	64a2                	ld	s1,8(sp)
ffffffffc02006c2:	6105                	addi	sp,sp,32
		syscall();
ffffffffc02006c4:	2b10306f          	j	ffffffffc0204174 <syscall>
		cprintf("Environment call from H-mode\n");
ffffffffc02006c8:	00004517          	auipc	a0,0x4
ffffffffc02006cc:	5b050513          	addi	a0,a0,1456 # ffffffffc0204c78 <etext+0x636>
}
ffffffffc02006d0:	6442                	ld	s0,16(sp)
ffffffffc02006d2:	60e2                	ld	ra,24(sp)
ffffffffc02006d4:	64a2                	ld	s1,8(sp)
ffffffffc02006d6:	6105                	addi	sp,sp,32
		cprintf("Instruction access fault\n");
ffffffffc02006d8:	b2e5                	j	ffffffffc02000c0 <cprintf>
		cprintf("Environment call from M-mode\n");
ffffffffc02006da:	00004517          	auipc	a0,0x4
ffffffffc02006de:	5be50513          	addi	a0,a0,1470 # ffffffffc0204c98 <etext+0x656>
ffffffffc02006e2:	b7fd                	j	ffffffffc02006d0 <exception_handler+0x50>
		cprintf("Instruction page fault\n");
ffffffffc02006e4:	00004517          	auipc	a0,0x4
ffffffffc02006e8:	5d450513          	addi	a0,a0,1492 # ffffffffc0204cb8 <etext+0x676>
ffffffffc02006ec:	b7d5                	j	ffffffffc02006d0 <exception_handler+0x50>
		cprintf("Load page fault\n");
ffffffffc02006ee:	00004517          	auipc	a0,0x4
ffffffffc02006f2:	5e250513          	addi	a0,a0,1506 # ffffffffc0204cd0 <etext+0x68e>
ffffffffc02006f6:	9cbff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
		if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02006fa:	8522                	mv	a0,s0
ffffffffc02006fc:	de3ff0ef          	jal	ra,ffffffffc02004de <pgfault_handler>
ffffffffc0200700:	84aa                	mv	s1,a0
ffffffffc0200702:	10051963          	bnez	a0,ffffffffc0200814 <exception_handler+0x194>
}
ffffffffc0200706:	60e2                	ld	ra,24(sp)
ffffffffc0200708:	6442                	ld	s0,16(sp)
ffffffffc020070a:	64a2                	ld	s1,8(sp)
ffffffffc020070c:	6105                	addi	sp,sp,32
ffffffffc020070e:	8082                	ret
		cprintf("Store/AMO page fault\n");
ffffffffc0200710:	00004517          	auipc	a0,0x4
ffffffffc0200714:	5d850513          	addi	a0,a0,1496 # ffffffffc0204ce8 <etext+0x6a6>
ffffffffc0200718:	9a9ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
		if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020071c:	8522                	mv	a0,s0
ffffffffc020071e:	dc1ff0ef          	jal	ra,ffffffffc02004de <pgfault_handler>
ffffffffc0200722:	84aa                	mv	s1,a0
ffffffffc0200724:	d16d                	beqz	a0,ffffffffc0200706 <exception_handler+0x86>
			print_trapframe(tf);
ffffffffc0200726:	8522                	mv	a0,s0
ffffffffc0200728:	d57ff0ef          	jal	ra,ffffffffc020047e <print_trapframe>
			panic("handle pgfault failed. %e\n", ret);
ffffffffc020072c:	86a6                	mv	a3,s1
ffffffffc020072e:	00004617          	auipc	a2,0x4
ffffffffc0200732:	4da60613          	addi	a2,a2,1242 # ffffffffc0204c08 <etext+0x5c6>
ffffffffc0200736:	0fd00593          	li	a1,253
ffffffffc020073a:	00004517          	auipc	a0,0x4
ffffffffc020073e:	32e50513          	addi	a0,a0,814 # ffffffffc0204a68 <etext+0x426>
ffffffffc0200742:	9f7ff0ef          	jal	ra,ffffffffc0200138 <__panic>
		cprintf("Instruction address misaligned\n");
ffffffffc0200746:	00004517          	auipc	a0,0x4
ffffffffc020074a:	42250513          	addi	a0,a0,1058 # ffffffffc0204b68 <etext+0x526>
ffffffffc020074e:	b749                	j	ffffffffc02006d0 <exception_handler+0x50>
		cprintf("Instruction access fault\n");
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	43850513          	addi	a0,a0,1080 # ffffffffc0204b88 <etext+0x546>
ffffffffc0200758:	bfa5                	j	ffffffffc02006d0 <exception_handler+0x50>
		cprintf("Illegal instruction\n");
ffffffffc020075a:	00004517          	auipc	a0,0x4
ffffffffc020075e:	44e50513          	addi	a0,a0,1102 # ffffffffc0204ba8 <etext+0x566>
ffffffffc0200762:	b7bd                	j	ffffffffc02006d0 <exception_handler+0x50>
		cprintf("Breakpoint\n");
ffffffffc0200764:	00004517          	auipc	a0,0x4
ffffffffc0200768:	45c50513          	addi	a0,a0,1116 # ffffffffc0204bc0 <etext+0x57e>
ffffffffc020076c:	955ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
		if (tf->gpr.a7 == 10) {
ffffffffc0200770:	6458                	ld	a4,136(s0)
ffffffffc0200772:	47a9                	li	a5,10
ffffffffc0200774:	f8f719e3          	bne	a4,a5,ffffffffc0200706 <exception_handler+0x86>
ffffffffc0200778:	b791                	j	ffffffffc02006bc <exception_handler+0x3c>
		cprintf("Load address misaligned\n");
ffffffffc020077a:	00004517          	auipc	a0,0x4
ffffffffc020077e:	45650513          	addi	a0,a0,1110 # ffffffffc0204bd0 <etext+0x58e>
ffffffffc0200782:	b7b9                	j	ffffffffc02006d0 <exception_handler+0x50>
		cprintf("Load access fault\n");
ffffffffc0200784:	00004517          	auipc	a0,0x4
ffffffffc0200788:	46c50513          	addi	a0,a0,1132 # ffffffffc0204bf0 <etext+0x5ae>
ffffffffc020078c:	935ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
		if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200790:	8522                	mv	a0,s0
ffffffffc0200792:	d4dff0ef          	jal	ra,ffffffffc02004de <pgfault_handler>
ffffffffc0200796:	84aa                	mv	s1,a0
ffffffffc0200798:	d53d                	beqz	a0,ffffffffc0200706 <exception_handler+0x86>
			print_trapframe(tf);
ffffffffc020079a:	8522                	mv	a0,s0
ffffffffc020079c:	ce3ff0ef          	jal	ra,ffffffffc020047e <print_trapframe>
			panic("handle pgfault failed. %e\n", ret);
ffffffffc02007a0:	86a6                	mv	a3,s1
ffffffffc02007a2:	00004617          	auipc	a2,0x4
ffffffffc02007a6:	46660613          	addi	a2,a2,1126 # ffffffffc0204c08 <etext+0x5c6>
ffffffffc02007aa:	0d200593          	li	a1,210
ffffffffc02007ae:	00004517          	auipc	a0,0x4
ffffffffc02007b2:	2ba50513          	addi	a0,a0,698 # ffffffffc0204a68 <etext+0x426>
ffffffffc02007b6:	983ff0ef          	jal	ra,ffffffffc0200138 <__panic>
		cprintf("Store/AMO access fault\n");
ffffffffc02007ba:	00004517          	auipc	a0,0x4
ffffffffc02007be:	48650513          	addi	a0,a0,1158 # ffffffffc0204c40 <etext+0x5fe>
ffffffffc02007c2:	8ffff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
		if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02007c6:	8522                	mv	a0,s0
ffffffffc02007c8:	d17ff0ef          	jal	ra,ffffffffc02004de <pgfault_handler>
ffffffffc02007cc:	84aa                	mv	s1,a0
ffffffffc02007ce:	dd05                	beqz	a0,ffffffffc0200706 <exception_handler+0x86>
			print_trapframe(tf);
ffffffffc02007d0:	8522                	mv	a0,s0
ffffffffc02007d2:	cadff0ef          	jal	ra,ffffffffc020047e <print_trapframe>
			panic("handle pgfault failed. %e\n", ret);
ffffffffc02007d6:	86a6                	mv	a3,s1
ffffffffc02007d8:	00004617          	auipc	a2,0x4
ffffffffc02007dc:	43060613          	addi	a2,a2,1072 # ffffffffc0204c08 <etext+0x5c6>
ffffffffc02007e0:	0dc00593          	li	a1,220
ffffffffc02007e4:	00004517          	auipc	a0,0x4
ffffffffc02007e8:	28450513          	addi	a0,a0,644 # ffffffffc0204a68 <etext+0x426>
ffffffffc02007ec:	94dff0ef          	jal	ra,ffffffffc0200138 <__panic>
		print_trapframe(tf);
ffffffffc02007f0:	8522                	mv	a0,s0
}
ffffffffc02007f2:	6442                	ld	s0,16(sp)
ffffffffc02007f4:	60e2                	ld	ra,24(sp)
ffffffffc02007f6:	64a2                	ld	s1,8(sp)
ffffffffc02007f8:	6105                	addi	sp,sp,32
		print_trapframe(tf);
ffffffffc02007fa:	b151                	j	ffffffffc020047e <print_trapframe>
		panic("AMO address misaligned\n");
ffffffffc02007fc:	00004617          	auipc	a2,0x4
ffffffffc0200800:	42c60613          	addi	a2,a2,1068 # ffffffffc0204c28 <etext+0x5e6>
ffffffffc0200804:	0d600593          	li	a1,214
ffffffffc0200808:	00004517          	auipc	a0,0x4
ffffffffc020080c:	26050513          	addi	a0,a0,608 # ffffffffc0204a68 <etext+0x426>
ffffffffc0200810:	929ff0ef          	jal	ra,ffffffffc0200138 <__panic>
			print_trapframe(tf);
ffffffffc0200814:	8522                	mv	a0,s0
ffffffffc0200816:	c69ff0ef          	jal	ra,ffffffffc020047e <print_trapframe>
			panic("handle pgfault failed. %e\n", ret);
ffffffffc020081a:	86a6                	mv	a3,s1
ffffffffc020081c:	00004617          	auipc	a2,0x4
ffffffffc0200820:	3ec60613          	addi	a2,a2,1004 # ffffffffc0204c08 <etext+0x5c6>
ffffffffc0200824:	0f600593          	li	a1,246
ffffffffc0200828:	00004517          	auipc	a0,0x4
ffffffffc020082c:	24050513          	addi	a0,a0,576 # ffffffffc0204a68 <etext+0x426>
ffffffffc0200830:	909ff0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0200834 <trap>:
 * exception.
 * */
void trap(struct trapframe *tf)
{
	// dispatch based on what type of trap occurred
	if (current == NULL) {
ffffffffc0200834:	0001e797          	auipc	a5,0x1e
ffffffffc0200838:	fac7b783          	ld	a5,-84(a5) # ffffffffc021e7e0 <current>
ffffffffc020083c:	11853703          	ld	a4,280(a0)
ffffffffc0200840:	c789                	beqz	a5,ffffffffc020084a <trap+0x16>
		trap_dispatch(tf);
	} else {
		// struct trapframe *otf = current->tf;
		current->tf = tf;
ffffffffc0200842:	f3c8                	sd	a0,160(a5)
	if ((intptr_t)tf->cause < 0) {
ffffffffc0200844:	00074563          	bltz	a4,ffffffffc020084e <trap+0x1a>
		exception_handler(tf);
ffffffffc0200848:	bd25                	j	ffffffffc0200680 <exception_handler>
	if ((intptr_t)tf->cause < 0) {
ffffffffc020084a:	fe075fe3          	bgez	a4,ffffffffc0200848 <trap+0x14>
		interrupt_handler(tf);
ffffffffc020084e:	b36d                	j	ffffffffc02005f8 <interrupt_handler>

ffffffffc0200850 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200850:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200854:	00011463          	bnez	sp,ffffffffc020085c <__alltraps+0xc>
ffffffffc0200858:	14002173          	csrr	sp,sscratch
ffffffffc020085c:	712d                	addi	sp,sp,-288
ffffffffc020085e:	e406                	sd	ra,8(sp)
ffffffffc0200860:	ec0e                	sd	gp,24(sp)
ffffffffc0200862:	f012                	sd	tp,32(sp)
ffffffffc0200864:	f416                	sd	t0,40(sp)
ffffffffc0200866:	f81a                	sd	t1,48(sp)
ffffffffc0200868:	fc1e                	sd	t2,56(sp)
ffffffffc020086a:	e0a2                	sd	s0,64(sp)
ffffffffc020086c:	e4a6                	sd	s1,72(sp)
ffffffffc020086e:	e8aa                	sd	a0,80(sp)
ffffffffc0200870:	ecae                	sd	a1,88(sp)
ffffffffc0200872:	f0b2                	sd	a2,96(sp)
ffffffffc0200874:	f4b6                	sd	a3,104(sp)
ffffffffc0200876:	f8ba                	sd	a4,112(sp)
ffffffffc0200878:	fcbe                	sd	a5,120(sp)
ffffffffc020087a:	e142                	sd	a6,128(sp)
ffffffffc020087c:	e546                	sd	a7,136(sp)
ffffffffc020087e:	e94a                	sd	s2,144(sp)
ffffffffc0200880:	ed4e                	sd	s3,152(sp)
ffffffffc0200882:	f152                	sd	s4,160(sp)
ffffffffc0200884:	f556                	sd	s5,168(sp)
ffffffffc0200886:	f95a                	sd	s6,176(sp)
ffffffffc0200888:	fd5e                	sd	s7,184(sp)
ffffffffc020088a:	e1e2                	sd	s8,192(sp)
ffffffffc020088c:	e5e6                	sd	s9,200(sp)
ffffffffc020088e:	e9ea                	sd	s10,208(sp)
ffffffffc0200890:	edee                	sd	s11,216(sp)
ffffffffc0200892:	f1f2                	sd	t3,224(sp)
ffffffffc0200894:	f5f6                	sd	t4,232(sp)
ffffffffc0200896:	f9fa                	sd	t5,240(sp)
ffffffffc0200898:	fdfe                	sd	t6,248(sp)
ffffffffc020089a:	14001473          	csrrw	s0,sscratch,zero
ffffffffc020089e:	100024f3          	csrr	s1,sstatus
ffffffffc02008a2:	14102973          	csrr	s2,sepc
ffffffffc02008a6:	143029f3          	csrr	s3,stval
ffffffffc02008aa:	14202a73          	csrr	s4,scause
ffffffffc02008ae:	e822                	sd	s0,16(sp)
ffffffffc02008b0:	e226                	sd	s1,256(sp)
ffffffffc02008b2:	e64a                	sd	s2,264(sp)
ffffffffc02008b4:	ea4e                	sd	s3,272(sp)
ffffffffc02008b6:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02008b8:	850a                	mv	a0,sp
    jal trap
ffffffffc02008ba:	f7bff0ef          	jal	ra,ffffffffc0200834 <trap>

ffffffffc02008be <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02008be:	6492                	ld	s1,256(sp)
ffffffffc02008c0:	6932                	ld	s2,264(sp)
ffffffffc02008c2:	1004f413          	andi	s0,s1,256
ffffffffc02008c6:	e401                	bnez	s0,ffffffffc02008ce <__trapret+0x10>
ffffffffc02008c8:	1200                	addi	s0,sp,288
ffffffffc02008ca:	14041073          	csrw	sscratch,s0
ffffffffc02008ce:	10049073          	csrw	sstatus,s1
ffffffffc02008d2:	14191073          	csrw	sepc,s2
ffffffffc02008d6:	60a2                	ld	ra,8(sp)
ffffffffc02008d8:	61e2                	ld	gp,24(sp)
ffffffffc02008da:	7202                	ld	tp,32(sp)
ffffffffc02008dc:	72a2                	ld	t0,40(sp)
ffffffffc02008de:	7342                	ld	t1,48(sp)
ffffffffc02008e0:	73e2                	ld	t2,56(sp)
ffffffffc02008e2:	6406                	ld	s0,64(sp)
ffffffffc02008e4:	64a6                	ld	s1,72(sp)
ffffffffc02008e6:	6546                	ld	a0,80(sp)
ffffffffc02008e8:	65e6                	ld	a1,88(sp)
ffffffffc02008ea:	7606                	ld	a2,96(sp)
ffffffffc02008ec:	76a6                	ld	a3,104(sp)
ffffffffc02008ee:	7746                	ld	a4,112(sp)
ffffffffc02008f0:	77e6                	ld	a5,120(sp)
ffffffffc02008f2:	680a                	ld	a6,128(sp)
ffffffffc02008f4:	68aa                	ld	a7,136(sp)
ffffffffc02008f6:	694a                	ld	s2,144(sp)
ffffffffc02008f8:	69ea                	ld	s3,152(sp)
ffffffffc02008fa:	7a0a                	ld	s4,160(sp)
ffffffffc02008fc:	7aaa                	ld	s5,168(sp)
ffffffffc02008fe:	7b4a                	ld	s6,176(sp)
ffffffffc0200900:	7bea                	ld	s7,184(sp)
ffffffffc0200902:	6c0e                	ld	s8,192(sp)
ffffffffc0200904:	6cae                	ld	s9,200(sp)
ffffffffc0200906:	6d4e                	ld	s10,208(sp)
ffffffffc0200908:	6dee                	ld	s11,216(sp)
ffffffffc020090a:	7e0e                	ld	t3,224(sp)
ffffffffc020090c:	7eae                	ld	t4,232(sp)
ffffffffc020090e:	7f4e                	ld	t5,240(sp)
ffffffffc0200910:	7fee                	ld	t6,248(sp)
ffffffffc0200912:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200914:	10200073          	sret

ffffffffc0200918 <forkrets>:

    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200918:	812a                	mv	sp,a0
    j __trapret
ffffffffc020091a:	b755                	j	ffffffffc02008be <__trapret>
	...

ffffffffc020091e <pa2page.part.0>:
static inline uintptr_t page2pa(struct Page *page)
{
	return page2ppn(page) << PGSHIFT;
}

static inline struct Page *pa2page(uintptr_t pa)
ffffffffc020091e:	1141                	addi	sp,sp,-16
{
	if (PPN(pa) >= npage) {
		panic("pa2page called with invalid pa");
ffffffffc0200920:	00004617          	auipc	a2,0x4
ffffffffc0200924:	42060613          	addi	a2,a2,1056 # ffffffffc0204d40 <etext+0x6fe>
ffffffffc0200928:	06b00593          	li	a1,107
ffffffffc020092c:	00004517          	auipc	a0,0x4
ffffffffc0200930:	43450513          	addi	a0,a0,1076 # ffffffffc0204d60 <etext+0x71e>
static inline struct Page *pa2page(uintptr_t pa)
ffffffffc0200934:	e406                	sd	ra,8(sp)
		panic("pa2page called with invalid pa");
ffffffffc0200936:	803ff0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc020093a <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n)
{
ffffffffc020093a:	7139                	addi	sp,sp,-64
ffffffffc020093c:	f426                	sd	s1,40(sp)
ffffffffc020093e:	f04a                	sd	s2,32(sp)
ffffffffc0200940:	ec4e                	sd	s3,24(sp)
ffffffffc0200942:	e852                	sd	s4,16(sp)
ffffffffc0200944:	e456                	sd	s5,8(sp)
ffffffffc0200946:	e05a                	sd	s6,0(sp)
ffffffffc0200948:	fc06                	sd	ra,56(sp)
ffffffffc020094a:	f822                	sd	s0,48(sp)
ffffffffc020094c:	84aa                	mv	s1,a0
ffffffffc020094e:	0001e917          	auipc	s2,0x1e
ffffffffc0200952:	eba90913          	addi	s2,s2,-326 # ffffffffc021e808 <pmm_manager>
		{
			page = pmm_manager->alloc_pages(n);
		}
		local_intr_restore(intr_flag);

		if (page != NULL || n > 1 || swap_init_ok == 0)
ffffffffc0200956:	4a05                	li	s4,1
ffffffffc0200958:	0001ea97          	auipc	s5,0x1e
ffffffffc020095c:	e80a8a93          	addi	s5,s5,-384 # ffffffffc021e7d8 <swap_init_ok>
			break;

		extern struct mm_struct *check_mm_struct;
		// cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
		swap_out(check_mm_struct, n, 0);
ffffffffc0200960:	0005099b          	sext.w	s3,a0
ffffffffc0200964:	0001eb17          	auipc	s6,0x1e
ffffffffc0200968:	ed4b0b13          	addi	s6,s6,-300 # ffffffffc021e838 <check_mm_struct>
ffffffffc020096c:	a01d                	j	ffffffffc0200992 <alloc_pages+0x58>
			page = pmm_manager->alloc_pages(n);
ffffffffc020096e:	00093783          	ld	a5,0(s2)
ffffffffc0200972:	6f9c                	ld	a5,24(a5)
ffffffffc0200974:	9782                	jalr	a5
ffffffffc0200976:	842a                	mv	s0,a0
		swap_out(check_mm_struct, n, 0);
ffffffffc0200978:	4601                	li	a2,0
ffffffffc020097a:	85ce                	mv	a1,s3
		if (page != NULL || n > 1 || swap_init_ok == 0)
ffffffffc020097c:	ec0d                	bnez	s0,ffffffffc02009b6 <alloc_pages+0x7c>
ffffffffc020097e:	029a6c63          	bltu	s4,s1,ffffffffc02009b6 <alloc_pages+0x7c>
ffffffffc0200982:	000aa783          	lw	a5,0(s5)
ffffffffc0200986:	2781                	sext.w	a5,a5
ffffffffc0200988:	c79d                	beqz	a5,ffffffffc02009b6 <alloc_pages+0x7c>
		swap_out(check_mm_struct, n, 0);
ffffffffc020098a:	000b3503          	ld	a0,0(s6)
ffffffffc020098e:	6ca010ef          	jal	ra,ffffffffc0202058 <swap_out>
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200992:	100027f3          	csrr	a5,sstatus
ffffffffc0200996:	8b89                	andi	a5,a5,2
			page = pmm_manager->alloc_pages(n);
ffffffffc0200998:	8526                	mv	a0,s1
ffffffffc020099a:	dbf1                	beqz	a5,ffffffffc020096e <alloc_pages+0x34>
		intr_disable();
ffffffffc020099c:	8f7ff0ef          	jal	ra,ffffffffc0200292 <intr_disable>
ffffffffc02009a0:	00093783          	ld	a5,0(s2)
ffffffffc02009a4:	8526                	mv	a0,s1
ffffffffc02009a6:	6f9c                	ld	a5,24(a5)
ffffffffc02009a8:	9782                	jalr	a5
ffffffffc02009aa:	842a                	mv	s0,a0
		intr_enable();
ffffffffc02009ac:	8e1ff0ef          	jal	ra,ffffffffc020028c <intr_enable>
		swap_out(check_mm_struct, n, 0);
ffffffffc02009b0:	4601                	li	a2,0
ffffffffc02009b2:	85ce                	mv	a1,s3
		if (page != NULL || n > 1 || swap_init_ok == 0)
ffffffffc02009b4:	d469                	beqz	s0,ffffffffc020097e <alloc_pages+0x44>
	}
	// cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
	return page;
}
ffffffffc02009b6:	70e2                	ld	ra,56(sp)
ffffffffc02009b8:	8522                	mv	a0,s0
ffffffffc02009ba:	7442                	ld	s0,48(sp)
ffffffffc02009bc:	74a2                	ld	s1,40(sp)
ffffffffc02009be:	7902                	ld	s2,32(sp)
ffffffffc02009c0:	69e2                	ld	s3,24(sp)
ffffffffc02009c2:	6a42                	ld	s4,16(sp)
ffffffffc02009c4:	6aa2                	ld	s5,8(sp)
ffffffffc02009c6:	6b02                	ld	s6,0(sp)
ffffffffc02009c8:	6121                	addi	sp,sp,64
ffffffffc02009ca:	8082                	ret

ffffffffc02009cc <free_pages>:
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02009cc:	100027f3          	csrr	a5,sstatus
ffffffffc02009d0:	8b89                	andi	a5,a5,2
ffffffffc02009d2:	eb81                	bnez	a5,ffffffffc02009e2 <free_pages+0x16>
void free_pages(struct Page *base, size_t n)
{
	bool intr_flag;
	local_intr_save(intr_flag);
	{
		pmm_manager->free_pages(base, n);
ffffffffc02009d4:	0001e797          	auipc	a5,0x1e
ffffffffc02009d8:	e347b783          	ld	a5,-460(a5) # ffffffffc021e808 <pmm_manager>
ffffffffc02009dc:	0207b303          	ld	t1,32(a5)
ffffffffc02009e0:	8302                	jr	t1
{
ffffffffc02009e2:	1101                	addi	sp,sp,-32
ffffffffc02009e4:	ec06                	sd	ra,24(sp)
ffffffffc02009e6:	e822                	sd	s0,16(sp)
ffffffffc02009e8:	e426                	sd	s1,8(sp)
ffffffffc02009ea:	842a                	mv	s0,a0
ffffffffc02009ec:	84ae                	mv	s1,a1
		intr_disable();
ffffffffc02009ee:	8a5ff0ef          	jal	ra,ffffffffc0200292 <intr_disable>
		pmm_manager->free_pages(base, n);
ffffffffc02009f2:	0001e797          	auipc	a5,0x1e
ffffffffc02009f6:	e167b783          	ld	a5,-490(a5) # ffffffffc021e808 <pmm_manager>
ffffffffc02009fa:	739c                	ld	a5,32(a5)
ffffffffc02009fc:	85a6                	mv	a1,s1
ffffffffc02009fe:	8522                	mv	a0,s0
ffffffffc0200a00:	9782                	jalr	a5
	}
	local_intr_restore(intr_flag);
}
ffffffffc0200a02:	6442                	ld	s0,16(sp)
ffffffffc0200a04:	60e2                	ld	ra,24(sp)
ffffffffc0200a06:	64a2                	ld	s1,8(sp)
ffffffffc0200a08:	6105                	addi	sp,sp,32
		intr_enable();
ffffffffc0200a0a:	883ff06f          	j	ffffffffc020028c <intr_enable>

ffffffffc0200a0e <nr_free_pages>:
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200a0e:	100027f3          	csrr	a5,sstatus
ffffffffc0200a12:	8b89                	andi	a5,a5,2
ffffffffc0200a14:	eb81                	bnez	a5,ffffffffc0200a24 <nr_free_pages+0x16>
{
	size_t ret;
	bool intr_flag;
	local_intr_save(intr_flag);
	{
		ret = pmm_manager->nr_free_pages();
ffffffffc0200a16:	0001e797          	auipc	a5,0x1e
ffffffffc0200a1a:	df27b783          	ld	a5,-526(a5) # ffffffffc021e808 <pmm_manager>
ffffffffc0200a1e:	0287b303          	ld	t1,40(a5)
ffffffffc0200a22:	8302                	jr	t1
{
ffffffffc0200a24:	1141                	addi	sp,sp,-16
ffffffffc0200a26:	e406                	sd	ra,8(sp)
ffffffffc0200a28:	e022                	sd	s0,0(sp)
		intr_disable();
ffffffffc0200a2a:	869ff0ef          	jal	ra,ffffffffc0200292 <intr_disable>
		ret = pmm_manager->nr_free_pages();
ffffffffc0200a2e:	0001e797          	auipc	a5,0x1e
ffffffffc0200a32:	dda7b783          	ld	a5,-550(a5) # ffffffffc021e808 <pmm_manager>
ffffffffc0200a36:	779c                	ld	a5,40(a5)
ffffffffc0200a38:	9782                	jalr	a5
ffffffffc0200a3a:	842a                	mv	s0,a0
		intr_enable();
ffffffffc0200a3c:	851ff0ef          	jal	ra,ffffffffc020028c <intr_enable>
	}
	local_intr_restore(intr_flag);
	return ret;
}
ffffffffc0200a40:	60a2                	ld	ra,8(sp)
ffffffffc0200a42:	8522                	mv	a0,s0
ffffffffc0200a44:	6402                	ld	s0,0(sp)
ffffffffc0200a46:	0141                	addi	sp,sp,16
ffffffffc0200a48:	8082                	ret

ffffffffc0200a4a <pmm_init>:
	pmm_manager = &default_pmm_manager;
ffffffffc0200a4a:	00005797          	auipc	a5,0x5
ffffffffc0200a4e:	d8678793          	addi	a5,a5,-634 # ffffffffc02057d0 <default_pmm_manager>
	cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200a52:	638c                	ld	a1,0(a5)

// pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup
// paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void pmm_init(void)
{
ffffffffc0200a54:	1101                	addi	sp,sp,-32
ffffffffc0200a56:	e426                	sd	s1,8(sp)
	cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200a58:	00004517          	auipc	a0,0x4
ffffffffc0200a5c:	31850513          	addi	a0,a0,792 # ffffffffc0204d70 <etext+0x72e>
	pmm_manager = &default_pmm_manager;
ffffffffc0200a60:	0001e497          	auipc	s1,0x1e
ffffffffc0200a64:	da848493          	addi	s1,s1,-600 # ffffffffc021e808 <pmm_manager>
{
ffffffffc0200a68:	ec06                	sd	ra,24(sp)
ffffffffc0200a6a:	e822                	sd	s0,16(sp)
	pmm_manager = &default_pmm_manager;
ffffffffc0200a6c:	e09c                	sd	a5,0(s1)
	cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200a6e:	e52ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	pmm_manager->init();
ffffffffc0200a72:	609c                	ld	a5,0(s1)
	va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0200a74:	0001e417          	auipc	s0,0x1e
ffffffffc0200a78:	da440413          	addi	s0,s0,-604 # ffffffffc021e818 <va_pa_offset>
	pmm_manager->init();
ffffffffc0200a7c:	679c                	ld	a5,8(a5)
ffffffffc0200a7e:	9782                	jalr	a5
	va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0200a80:	57f5                	li	a5,-3
ffffffffc0200a82:	07fa                	slli	a5,a5,0x1e
	cprintf("physcial memory map:\n");
ffffffffc0200a84:	00004517          	auipc	a0,0x4
ffffffffc0200a88:	30450513          	addi	a0,a0,772 # ffffffffc0204d88 <etext+0x746>
	va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0200a8c:	e01c                	sd	a5,0(s0)
	cprintf("physcial memory map:\n");
ffffffffc0200a8e:	e32ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0200a92:	44300693          	li	a3,1091
ffffffffc0200a96:	06d6                	slli	a3,a3,0x15
ffffffffc0200a98:	40100613          	li	a2,1025
ffffffffc0200a9c:	0656                	slli	a2,a2,0x15
ffffffffc0200a9e:	088005b7          	lui	a1,0x8800
ffffffffc0200aa2:	16fd                	addi	a3,a3,-1
ffffffffc0200aa4:	00004517          	auipc	a0,0x4
ffffffffc0200aa8:	2fc50513          	addi	a0,a0,764 # ffffffffc0204da0 <etext+0x75e>
ffffffffc0200aac:	e14ff0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ab0:	777d                	lui	a4,0xfffff
ffffffffc0200ab2:	0001f797          	auipc	a5,0x1f
ffffffffc0200ab6:	e7d78793          	addi	a5,a5,-387 # ffffffffc021f92f <end+0xfff>
ffffffffc0200aba:	8ff9                	and	a5,a5,a4
	npage = maxpa / PGSIZE;
ffffffffc0200abc:	00088737          	lui	a4,0x88
ffffffffc0200ac0:	60070713          	addi	a4,a4,1536 # 88600 <_binary_obj___user_hello_out_size+0x7eec0>
ffffffffc0200ac4:	0001e597          	auipc	a1,0x1e
ffffffffc0200ac8:	cf458593          	addi	a1,a1,-780 # ffffffffc021e7b8 <npage>
	pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200acc:	0001e617          	auipc	a2,0x1e
ffffffffc0200ad0:	d5460613          	addi	a2,a2,-684 # ffffffffc021e820 <pages>
	npage = maxpa / PGSIZE;
ffffffffc0200ad4:	e198                	sd	a4,0(a1)
	pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ad6:	e21c                	sd	a5,0(a2)
	for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200ad8:	4701                	li	a4,0
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr)
{
	__op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200ada:	4505                	li	a0,1
ffffffffc0200adc:	fff80837          	lui	a6,0xfff80
ffffffffc0200ae0:	a011                	j	ffffffffc0200ae4 <pmm_init+0x9a>
ffffffffc0200ae2:	621c                	ld	a5,0(a2)
		SetPageReserved(pages + i);
ffffffffc0200ae4:	00671693          	slli	a3,a4,0x6
ffffffffc0200ae8:	97b6                	add	a5,a5,a3
ffffffffc0200aea:	07a1                	addi	a5,a5,8
ffffffffc0200aec:	40a7b02f          	amoor.d	zero,a0,(a5)
	for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200af0:	0005b883          	ld	a7,0(a1)
ffffffffc0200af4:	0705                	addi	a4,a4,1
ffffffffc0200af6:	010886b3          	add	a3,a7,a6
ffffffffc0200afa:	fed764e3          	bltu	a4,a3,ffffffffc0200ae2 <pmm_init+0x98>
		PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200afe:	6208                	ld	a0,0(a2)
ffffffffc0200b00:	069a                	slli	a3,a3,0x6
ffffffffc0200b02:	c02007b7          	lui	a5,0xc0200
ffffffffc0200b06:	96aa                	add	a3,a3,a0
ffffffffc0200b08:	06f6e263          	bltu	a3,a5,ffffffffc0200b6c <pmm_init+0x122>
ffffffffc0200b0c:	601c                	ld	a5,0(s0)
	if (freemem < mem_end) {
ffffffffc0200b0e:	44300593          	li	a1,1091
ffffffffc0200b12:	05d6                	slli	a1,a1,0x15
		PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200b14:	8e9d                	sub	a3,a3,a5
	if (freemem < mem_end) {
ffffffffc0200b16:	02b6f363          	bgeu	a3,a1,ffffffffc0200b3c <pmm_init+0xf2>
	mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200b1a:	6785                	lui	a5,0x1
ffffffffc0200b1c:	17fd                	addi	a5,a5,-1
ffffffffc0200b1e:	96be                	add	a3,a3,a5
	if (PPN(pa) >= npage) {
ffffffffc0200b20:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200b24:	0717fc63          	bgeu	a5,a7,ffffffffc0200b9c <pmm_init+0x152>
	pmm_manager->init_memmap(base, n);
ffffffffc0200b28:	6098                	ld	a4,0(s1)
		init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200b2a:	767d                	lui	a2,0xfffff
ffffffffc0200b2c:	8ef1                	and	a3,a3,a2
	}
	return &pages[PPN(pa) - nbase];
ffffffffc0200b2e:	97c2                	add	a5,a5,a6
	pmm_manager->init_memmap(base, n);
ffffffffc0200b30:	6b18                	ld	a4,16(a4)
		init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200b32:	8d95                	sub	a1,a1,a3
ffffffffc0200b34:	079a                	slli	a5,a5,0x6
	pmm_manager->init_memmap(base, n);
ffffffffc0200b36:	81b1                	srli	a1,a1,0xc
ffffffffc0200b38:	953e                	add	a0,a0,a5
ffffffffc0200b3a:	9702                	jalr	a4
	// use pmm->check to verify the correctness of the alloc/free function in a
	// pmm
	// check_alloc_page();
	// create boot_pgdir, an initial page directory(Page Directory Table, PDT)
	extern char boot_page_table_sv39[];
	boot_pgdir = (pte_t *)boot_page_table_sv39;
ffffffffc0200b3c:	00008697          	auipc	a3,0x8
ffffffffc0200b40:	4c468693          	addi	a3,a3,1220 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0200b44:	0001e797          	auipc	a5,0x1e
ffffffffc0200b48:	c6d7b623          	sd	a3,-916(a5) # ffffffffc021e7b0 <boot_pgdir>
	boot_satp = PADDR(boot_pgdir);
ffffffffc0200b4c:	c02007b7          	lui	a5,0xc0200
ffffffffc0200b50:	02f6ea63          	bltu	a3,a5,ffffffffc0200b84 <pmm_init+0x13a>
ffffffffc0200b54:	601c                	ld	a5,0(s0)
	// now the basic virtual memory map(see memalyout.h) is established.
	// check the correctness of the basic virtual memory map.
	// check_boot_pgdir();

	kmalloc_init();
}
ffffffffc0200b56:	6442                	ld	s0,16(sp)
ffffffffc0200b58:	60e2                	ld	ra,24(sp)
ffffffffc0200b5a:	64a2                	ld	s1,8(sp)
	boot_satp = PADDR(boot_pgdir);
ffffffffc0200b5c:	8e9d                	sub	a3,a3,a5
ffffffffc0200b5e:	0001e797          	auipc	a5,0x1e
ffffffffc0200b62:	cad7b923          	sd	a3,-846(a5) # ffffffffc021e810 <boot_satp>
}
ffffffffc0200b66:	6105                	addi	sp,sp,32
	kmalloc_init();
ffffffffc0200b68:	2a60106f          	j	ffffffffc0201e0e <kmalloc_init>
		PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200b6c:	00004617          	auipc	a2,0x4
ffffffffc0200b70:	25c60613          	addi	a2,a2,604 # ffffffffc0204dc8 <etext+0x786>
ffffffffc0200b74:	08700593          	li	a1,135
ffffffffc0200b78:	00004517          	auipc	a0,0x4
ffffffffc0200b7c:	27850513          	addi	a0,a0,632 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc0200b80:	db8ff0ef          	jal	ra,ffffffffc0200138 <__panic>
	boot_satp = PADDR(boot_pgdir);
ffffffffc0200b84:	00004617          	auipc	a2,0x4
ffffffffc0200b88:	24460613          	addi	a2,a2,580 # ffffffffc0204dc8 <etext+0x786>
ffffffffc0200b8c:	0cb00593          	li	a1,203
ffffffffc0200b90:	00004517          	auipc	a0,0x4
ffffffffc0200b94:	26050513          	addi	a0,a0,608 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc0200b98:	da0ff0ef          	jal	ra,ffffffffc0200138 <__panic>
ffffffffc0200b9c:	d83ff0ef          	jal	ra,ffffffffc020091e <pa2page.part.0>

ffffffffc0200ba0 <get_pte>:
   *   PTE_W           0x002                   // page table/directory entry
   * flags bit : Writeable
   *   PTE_U           0x004                   // page table/directory entry
   * flags bit : User can access
   */
	pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200ba0:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0200ba4:	1ff7f793          	andi	a5,a5,511
{
ffffffffc0200ba8:	7139                	addi	sp,sp,-64
	pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200baa:	078e                	slli	a5,a5,0x3
{
ffffffffc0200bac:	f426                	sd	s1,40(sp)
	pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0200bae:	00f504b3          	add	s1,a0,a5
	if (!(*pdep1 & PTE_V)) {
ffffffffc0200bb2:	6094                	ld	a3,0(s1)
{
ffffffffc0200bb4:	f04a                	sd	s2,32(sp)
ffffffffc0200bb6:	ec4e                	sd	s3,24(sp)
ffffffffc0200bb8:	e852                	sd	s4,16(sp)
ffffffffc0200bba:	fc06                	sd	ra,56(sp)
ffffffffc0200bbc:	f822                	sd	s0,48(sp)
ffffffffc0200bbe:	e456                	sd	s5,8(sp)
ffffffffc0200bc0:	e05a                	sd	s6,0(sp)
	if (!(*pdep1 & PTE_V)) {
ffffffffc0200bc2:	0016f793          	andi	a5,a3,1
{
ffffffffc0200bc6:	892e                	mv	s2,a1
ffffffffc0200bc8:	89b2                	mv	s3,a2
ffffffffc0200bca:	0001ea17          	auipc	s4,0x1e
ffffffffc0200bce:	beea0a13          	addi	s4,s4,-1042 # ffffffffc021e7b8 <npage>
	if (!(*pdep1 & PTE_V)) {
ffffffffc0200bd2:	e7b5                	bnez	a5,ffffffffc0200c3e <get_pte+0x9e>
		struct Page *page;
		if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200bd4:	12060b63          	beqz	a2,ffffffffc0200d0a <get_pte+0x16a>
ffffffffc0200bd8:	4505                	li	a0,1
ffffffffc0200bda:	d61ff0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc0200bde:	842a                	mv	s0,a0
ffffffffc0200be0:	12050563          	beqz	a0,ffffffffc0200d0a <get_pte+0x16a>
	return page - pages + nbase;
ffffffffc0200be4:	0001eb17          	auipc	s6,0x1e
ffffffffc0200be8:	c3cb0b13          	addi	s6,s6,-964 # ffffffffc021e820 <pages>
ffffffffc0200bec:	000b3503          	ld	a0,0(s6)
ffffffffc0200bf0:	00080ab7          	lui	s5,0x80
			return NULL;
		}
		set_page_ref(page, 1);
		uintptr_t pa = page2pa(page);
		memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200bf4:	0001ea17          	auipc	s4,0x1e
ffffffffc0200bf8:	bc4a0a13          	addi	s4,s4,-1084 # ffffffffc021e7b8 <npage>
ffffffffc0200bfc:	40a40533          	sub	a0,s0,a0
ffffffffc0200c00:	8519                	srai	a0,a0,0x6
ffffffffc0200c02:	9556                	add	a0,a0,s5
ffffffffc0200c04:	000a3703          	ld	a4,0(s4)
ffffffffc0200c08:	00c51793          	slli	a5,a0,0xc
	return page->ref;
}

static inline void set_page_ref(struct Page *page, int val)
{
	page->ref = val;
ffffffffc0200c0c:	4685                	li	a3,1
ffffffffc0200c0e:	c014                	sw	a3,0(s0)
ffffffffc0200c10:	83b1                	srli	a5,a5,0xc
	return page2ppn(page) << PGSHIFT;
ffffffffc0200c12:	0532                	slli	a0,a0,0xc
ffffffffc0200c14:	14e7f263          	bgeu	a5,a4,ffffffffc0200d58 <get_pte+0x1b8>
ffffffffc0200c18:	0001e797          	auipc	a5,0x1e
ffffffffc0200c1c:	c007b783          	ld	a5,-1024(a5) # ffffffffc021e818 <va_pa_offset>
ffffffffc0200c20:	6605                	lui	a2,0x1
ffffffffc0200c22:	4581                	li	a1,0
ffffffffc0200c24:	953e                	add	a0,a0,a5
ffffffffc0200c26:	5ee030ef          	jal	ra,ffffffffc0204214 <memset>
	return page - pages + nbase;
ffffffffc0200c2a:	000b3683          	ld	a3,0(s6)
ffffffffc0200c2e:	40d406b3          	sub	a3,s0,a3
ffffffffc0200c32:	8699                	srai	a3,a3,0x6
ffffffffc0200c34:	96d6                	add	a3,a3,s5
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
	return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200c36:	06aa                	slli	a3,a3,0xa
ffffffffc0200c38:	0116e693          	ori	a3,a3,17
		*pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200c3c:	e094                	sd	a3,0(s1)
	}
	pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200c3e:	77fd                	lui	a5,0xfffff
ffffffffc0200c40:	068a                	slli	a3,a3,0x2
ffffffffc0200c42:	000a3703          	ld	a4,0(s4)
ffffffffc0200c46:	8efd                	and	a3,a3,a5
ffffffffc0200c48:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200c4c:	0ce7f163          	bgeu	a5,a4,ffffffffc0200d0e <get_pte+0x16e>
ffffffffc0200c50:	0001ea97          	auipc	s5,0x1e
ffffffffc0200c54:	bc8a8a93          	addi	s5,s5,-1080 # ffffffffc021e818 <va_pa_offset>
ffffffffc0200c58:	000ab403          	ld	s0,0(s5)
ffffffffc0200c5c:	01595793          	srli	a5,s2,0x15
ffffffffc0200c60:	1ff7f793          	andi	a5,a5,511
ffffffffc0200c64:	96a2                	add	a3,a3,s0
ffffffffc0200c66:	00379413          	slli	s0,a5,0x3
ffffffffc0200c6a:	9436                	add	s0,s0,a3
	if (!(*pdep0 & PTE_V)) {
ffffffffc0200c6c:	6014                	ld	a3,0(s0)
ffffffffc0200c6e:	0016f793          	andi	a5,a3,1
ffffffffc0200c72:	e3ad                	bnez	a5,ffffffffc0200cd4 <get_pte+0x134>
		struct Page *page;
		if (!create || (page = alloc_page()) == NULL) {
ffffffffc0200c74:	08098b63          	beqz	s3,ffffffffc0200d0a <get_pte+0x16a>
ffffffffc0200c78:	4505                	li	a0,1
ffffffffc0200c7a:	cc1ff0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc0200c7e:	84aa                	mv	s1,a0
ffffffffc0200c80:	c549                	beqz	a0,ffffffffc0200d0a <get_pte+0x16a>
	return page - pages + nbase;
ffffffffc0200c82:	0001eb17          	auipc	s6,0x1e
ffffffffc0200c86:	b9eb0b13          	addi	s6,s6,-1122 # ffffffffc021e820 <pages>
ffffffffc0200c8a:	000b3503          	ld	a0,0(s6)
ffffffffc0200c8e:	000809b7          	lui	s3,0x80
			return NULL;
		}
		set_page_ref(page, 1);
		uintptr_t pa = page2pa(page);
		memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200c92:	000a3703          	ld	a4,0(s4)
ffffffffc0200c96:	40a48533          	sub	a0,s1,a0
ffffffffc0200c9a:	8519                	srai	a0,a0,0x6
ffffffffc0200c9c:	954e                	add	a0,a0,s3
ffffffffc0200c9e:	00c51793          	slli	a5,a0,0xc
	page->ref = val;
ffffffffc0200ca2:	4685                	li	a3,1
ffffffffc0200ca4:	c094                	sw	a3,0(s1)
ffffffffc0200ca6:	83b1                	srli	a5,a5,0xc
	return page2ppn(page) << PGSHIFT;
ffffffffc0200ca8:	0532                	slli	a0,a0,0xc
ffffffffc0200caa:	08e7fa63          	bgeu	a5,a4,ffffffffc0200d3e <get_pte+0x19e>
ffffffffc0200cae:	000ab783          	ld	a5,0(s5)
ffffffffc0200cb2:	6605                	lui	a2,0x1
ffffffffc0200cb4:	4581                	li	a1,0
ffffffffc0200cb6:	953e                	add	a0,a0,a5
ffffffffc0200cb8:	55c030ef          	jal	ra,ffffffffc0204214 <memset>
	return page - pages + nbase;
ffffffffc0200cbc:	000b3683          	ld	a3,0(s6)
ffffffffc0200cc0:	40d486b3          	sub	a3,s1,a3
ffffffffc0200cc4:	8699                	srai	a3,a3,0x6
ffffffffc0200cc6:	96ce                	add	a3,a3,s3
	return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200cc8:	06aa                	slli	a3,a3,0xa
ffffffffc0200cca:	0116e693          	ori	a3,a3,17
		*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0200cce:	e014                	sd	a3,0(s0)
ffffffffc0200cd0:	000a3703          	ld	a4,0(s4)
	}
	return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200cd4:	068a                	slli	a3,a3,0x2
ffffffffc0200cd6:	757d                	lui	a0,0xfffff
ffffffffc0200cd8:	8ee9                	and	a3,a3,a0
ffffffffc0200cda:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200cde:	04e7f463          	bgeu	a5,a4,ffffffffc0200d26 <get_pte+0x186>
ffffffffc0200ce2:	000ab503          	ld	a0,0(s5)
ffffffffc0200ce6:	00c95913          	srli	s2,s2,0xc
ffffffffc0200cea:	1ff97913          	andi	s2,s2,511
ffffffffc0200cee:	96aa                	add	a3,a3,a0
ffffffffc0200cf0:	00391513          	slli	a0,s2,0x3
ffffffffc0200cf4:	9536                	add	a0,a0,a3
}
ffffffffc0200cf6:	70e2                	ld	ra,56(sp)
ffffffffc0200cf8:	7442                	ld	s0,48(sp)
ffffffffc0200cfa:	74a2                	ld	s1,40(sp)
ffffffffc0200cfc:	7902                	ld	s2,32(sp)
ffffffffc0200cfe:	69e2                	ld	s3,24(sp)
ffffffffc0200d00:	6a42                	ld	s4,16(sp)
ffffffffc0200d02:	6aa2                	ld	s5,8(sp)
ffffffffc0200d04:	6b02                	ld	s6,0(sp)
ffffffffc0200d06:	6121                	addi	sp,sp,64
ffffffffc0200d08:	8082                	ret
			return NULL;
ffffffffc0200d0a:	4501                	li	a0,0
ffffffffc0200d0c:	b7ed                	j	ffffffffc0200cf6 <get_pte+0x156>
	pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0200d0e:	00004617          	auipc	a2,0x4
ffffffffc0200d12:	0f260613          	addi	a2,a2,242 # ffffffffc0204e00 <etext+0x7be>
ffffffffc0200d16:	10700593          	li	a1,263
ffffffffc0200d1a:	00004517          	auipc	a0,0x4
ffffffffc0200d1e:	0d650513          	addi	a0,a0,214 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc0200d22:	c16ff0ef          	jal	ra,ffffffffc0200138 <__panic>
	return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0200d26:	00004617          	auipc	a2,0x4
ffffffffc0200d2a:	0da60613          	addi	a2,a2,218 # ffffffffc0204e00 <etext+0x7be>
ffffffffc0200d2e:	11200593          	li	a1,274
ffffffffc0200d32:	00004517          	auipc	a0,0x4
ffffffffc0200d36:	0be50513          	addi	a0,a0,190 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc0200d3a:	bfeff0ef          	jal	ra,ffffffffc0200138 <__panic>
		memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200d3e:	86aa                	mv	a3,a0
ffffffffc0200d40:	00004617          	auipc	a2,0x4
ffffffffc0200d44:	0c060613          	addi	a2,a2,192 # ffffffffc0204e00 <etext+0x7be>
ffffffffc0200d48:	10f00593          	li	a1,271
ffffffffc0200d4c:	00004517          	auipc	a0,0x4
ffffffffc0200d50:	0a450513          	addi	a0,a0,164 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc0200d54:	be4ff0ef          	jal	ra,ffffffffc0200138 <__panic>
		memset(KADDR(pa), 0, PGSIZE);
ffffffffc0200d58:	86aa                	mv	a3,a0
ffffffffc0200d5a:	00004617          	auipc	a2,0x4
ffffffffc0200d5e:	0a660613          	addi	a2,a2,166 # ffffffffc0204e00 <etext+0x7be>
ffffffffc0200d62:	10400593          	li	a1,260
ffffffffc0200d66:	00004517          	auipc	a0,0x4
ffffffffc0200d6a:	08a50513          	addi	a0,a0,138 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc0200d6e:	bcaff0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0200d72 <unmap_range>:
		tlb_invalidate(pgdir, la); //(6) flush tlb
	}
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0200d72:	711d                	addi	sp,sp,-96
	assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200d74:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0200d78:	ec86                	sd	ra,88(sp)
ffffffffc0200d7a:	e8a2                	sd	s0,80(sp)
ffffffffc0200d7c:	e4a6                	sd	s1,72(sp)
ffffffffc0200d7e:	e0ca                	sd	s2,64(sp)
ffffffffc0200d80:	fc4e                	sd	s3,56(sp)
ffffffffc0200d82:	f852                	sd	s4,48(sp)
ffffffffc0200d84:	f456                	sd	s5,40(sp)
ffffffffc0200d86:	f05a                	sd	s6,32(sp)
ffffffffc0200d88:	ec5e                	sd	s7,24(sp)
ffffffffc0200d8a:	e862                	sd	s8,16(sp)
ffffffffc0200d8c:	e466                	sd	s9,8(sp)
	assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200d8e:	17d2                	slli	a5,a5,0x34
ffffffffc0200d90:	ebf1                	bnez	a5,ffffffffc0200e64 <unmap_range+0xf2>
	assert(USER_ACCESS(start, end));
ffffffffc0200d92:	002007b7          	lui	a5,0x200
ffffffffc0200d96:	842e                	mv	s0,a1
ffffffffc0200d98:	0af5e663          	bltu	a1,a5,ffffffffc0200e44 <unmap_range+0xd2>
ffffffffc0200d9c:	8932                	mv	s2,a2
ffffffffc0200d9e:	0ac5f363          	bgeu	a1,a2,ffffffffc0200e44 <unmap_range+0xd2>
ffffffffc0200da2:	4785                	li	a5,1
ffffffffc0200da4:	07fe                	slli	a5,a5,0x1f
ffffffffc0200da6:	08c7ef63          	bltu	a5,a2,ffffffffc0200e44 <unmap_range+0xd2>
ffffffffc0200daa:	89aa                	mv	s3,a0
			continue;
		}
		if (*ptep != 0) {
			page_remove_pte(pgdir, start, ptep);
		}
		start += PGSIZE;
ffffffffc0200dac:	6a05                	lui	s4,0x1
	if (PPN(pa) >= npage) {
ffffffffc0200dae:	0001ec97          	auipc	s9,0x1e
ffffffffc0200db2:	a0ac8c93          	addi	s9,s9,-1526 # ffffffffc021e7b8 <npage>
	return &pages[PPN(pa) - nbase];
ffffffffc0200db6:	0001ec17          	auipc	s8,0x1e
ffffffffc0200dba:	a6ac0c13          	addi	s8,s8,-1430 # ffffffffc021e820 <pages>
ffffffffc0200dbe:	fff80bb7          	lui	s7,0xfff80
			start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0200dc2:	00200b37          	lui	s6,0x200
ffffffffc0200dc6:	ffe00ab7          	lui	s5,0xffe00
		pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0200dca:	4601                	li	a2,0
ffffffffc0200dcc:	85a2                	mv	a1,s0
ffffffffc0200dce:	854e                	mv	a0,s3
ffffffffc0200dd0:	dd1ff0ef          	jal	ra,ffffffffc0200ba0 <get_pte>
ffffffffc0200dd4:	84aa                	mv	s1,a0
		if (ptep == NULL) {
ffffffffc0200dd6:	cd21                	beqz	a0,ffffffffc0200e2e <unmap_range+0xbc>
		if (*ptep != 0) {
ffffffffc0200dd8:	611c                	ld	a5,0(a0)
ffffffffc0200dda:	e38d                	bnez	a5,ffffffffc0200dfc <unmap_range+0x8a>
		start += PGSIZE;
ffffffffc0200ddc:	9452                	add	s0,s0,s4
	} while (start != 0 && start < end);
ffffffffc0200dde:	ff2466e3          	bltu	s0,s2,ffffffffc0200dca <unmap_range+0x58>
}
ffffffffc0200de2:	60e6                	ld	ra,88(sp)
ffffffffc0200de4:	6446                	ld	s0,80(sp)
ffffffffc0200de6:	64a6                	ld	s1,72(sp)
ffffffffc0200de8:	6906                	ld	s2,64(sp)
ffffffffc0200dea:	79e2                	ld	s3,56(sp)
ffffffffc0200dec:	7a42                	ld	s4,48(sp)
ffffffffc0200dee:	7aa2                	ld	s5,40(sp)
ffffffffc0200df0:	7b02                	ld	s6,32(sp)
ffffffffc0200df2:	6be2                	ld	s7,24(sp)
ffffffffc0200df4:	6c42                	ld	s8,16(sp)
ffffffffc0200df6:	6ca2                	ld	s9,8(sp)
ffffffffc0200df8:	6125                	addi	sp,sp,96
ffffffffc0200dfa:	8082                	ret
	if (*ptep & PTE_V) { //(1) check if this page table entry is
ffffffffc0200dfc:	0017f713          	andi	a4,a5,1
ffffffffc0200e00:	df71                	beqz	a4,ffffffffc0200ddc <unmap_range+0x6a>
	if (PPN(pa) >= npage) {
ffffffffc0200e02:	000cb703          	ld	a4,0(s9)
	return pa2page(PTE_ADDR(pte));
ffffffffc0200e06:	078a                	slli	a5,a5,0x2
ffffffffc0200e08:	83b1                	srli	a5,a5,0xc
	if (PPN(pa) >= npage) {
ffffffffc0200e0a:	06e7fd63          	bgeu	a5,a4,ffffffffc0200e84 <unmap_range+0x112>
	return &pages[PPN(pa) - nbase];
ffffffffc0200e0e:	000c3503          	ld	a0,0(s8)
ffffffffc0200e12:	97de                	add	a5,a5,s7
ffffffffc0200e14:	079a                	slli	a5,a5,0x6
ffffffffc0200e16:	953e                	add	a0,a0,a5
	page->ref -= 1;
ffffffffc0200e18:	411c                	lw	a5,0(a0)
ffffffffc0200e1a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0200e1e:	c118                	sw	a4,0(a0)
		if (page_ref(page) ==
ffffffffc0200e20:	cf11                	beqz	a4,ffffffffc0200e3c <unmap_range+0xca>
		*ptep = 0; //(5) clear second page table entry
ffffffffc0200e22:	0004b023          	sd	zero,0(s1)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
	asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200e26:	12040073          	sfence.vma	s0
		start += PGSIZE;
ffffffffc0200e2a:	9452                	add	s0,s0,s4
	} while (start != 0 && start < end);
ffffffffc0200e2c:	bf4d                	j	ffffffffc0200dde <unmap_range+0x6c>
			start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0200e2e:	945a                	add	s0,s0,s6
ffffffffc0200e30:	01547433          	and	s0,s0,s5
	} while (start != 0 && start < end);
ffffffffc0200e34:	d45d                	beqz	s0,ffffffffc0200de2 <unmap_range+0x70>
ffffffffc0200e36:	f9246ae3          	bltu	s0,s2,ffffffffc0200dca <unmap_range+0x58>
ffffffffc0200e3a:	b765                	j	ffffffffc0200de2 <unmap_range+0x70>
			free_page(page);
ffffffffc0200e3c:	4585                	li	a1,1
ffffffffc0200e3e:	b8fff0ef          	jal	ra,ffffffffc02009cc <free_pages>
ffffffffc0200e42:	b7c5                	j	ffffffffc0200e22 <unmap_range+0xb0>
	assert(USER_ACCESS(start, end));
ffffffffc0200e44:	00004697          	auipc	a3,0x4
ffffffffc0200e48:	01468693          	addi	a3,a3,20 # ffffffffc0204e58 <etext+0x816>
ffffffffc0200e4c:	00004617          	auipc	a2,0x4
ffffffffc0200e50:	c0460613          	addi	a2,a2,-1020 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0200e54:	14d00593          	li	a1,333
ffffffffc0200e58:	00004517          	auipc	a0,0x4
ffffffffc0200e5c:	f9850513          	addi	a0,a0,-104 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc0200e60:	ad8ff0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200e64:	00004697          	auipc	a3,0x4
ffffffffc0200e68:	fc468693          	addi	a3,a3,-60 # ffffffffc0204e28 <etext+0x7e6>
ffffffffc0200e6c:	00004617          	auipc	a2,0x4
ffffffffc0200e70:	be460613          	addi	a2,a2,-1052 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0200e74:	14c00593          	li	a1,332
ffffffffc0200e78:	00004517          	auipc	a0,0x4
ffffffffc0200e7c:	f7850513          	addi	a0,a0,-136 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc0200e80:	ab8ff0ef          	jal	ra,ffffffffc0200138 <__panic>
ffffffffc0200e84:	a9bff0ef          	jal	ra,ffffffffc020091e <pa2page.part.0>

ffffffffc0200e88 <exit_range>:
{
ffffffffc0200e88:	715d                	addi	sp,sp,-80
	assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200e8a:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0200e8e:	e486                	sd	ra,72(sp)
ffffffffc0200e90:	e0a2                	sd	s0,64(sp)
ffffffffc0200e92:	fc26                	sd	s1,56(sp)
ffffffffc0200e94:	f84a                	sd	s2,48(sp)
ffffffffc0200e96:	f44e                	sd	s3,40(sp)
ffffffffc0200e98:	f052                	sd	s4,32(sp)
ffffffffc0200e9a:	ec56                	sd	s5,24(sp)
ffffffffc0200e9c:	e85a                	sd	s6,16(sp)
ffffffffc0200e9e:	e45e                	sd	s7,8(sp)
	assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200ea0:	17d2                	slli	a5,a5,0x34
ffffffffc0200ea2:	e3f1                	bnez	a5,ffffffffc0200f66 <exit_range+0xde>
	assert(USER_ACCESS(start, end));
ffffffffc0200ea4:	002007b7          	lui	a5,0x200
ffffffffc0200ea8:	08f5ef63          	bltu	a1,a5,ffffffffc0200f46 <exit_range+0xbe>
ffffffffc0200eac:	89b2                	mv	s3,a2
ffffffffc0200eae:	08c5fc63          	bgeu	a1,a2,ffffffffc0200f46 <exit_range+0xbe>
ffffffffc0200eb2:	4785                	li	a5,1
	start = ROUNDDOWN(start, PTSIZE);
ffffffffc0200eb4:	ffe004b7          	lui	s1,0xffe00
	assert(USER_ACCESS(start, end));
ffffffffc0200eb8:	07fe                	slli	a5,a5,0x1f
	start = ROUNDDOWN(start, PTSIZE);
ffffffffc0200eba:	8ced                	and	s1,s1,a1
	assert(USER_ACCESS(start, end));
ffffffffc0200ebc:	08c7e563          	bltu	a5,a2,ffffffffc0200f46 <exit_range+0xbe>
ffffffffc0200ec0:	8a2a                	mv	s4,a0
	if (PPN(pa) >= npage) {
ffffffffc0200ec2:	0001eb17          	auipc	s6,0x1e
ffffffffc0200ec6:	8f6b0b13          	addi	s6,s6,-1802 # ffffffffc021e7b8 <npage>
	return &pages[PPN(pa) - nbase];
ffffffffc0200eca:	0001eb97          	auipc	s7,0x1e
ffffffffc0200ece:	956b8b93          	addi	s7,s7,-1706 # ffffffffc021e820 <pages>
ffffffffc0200ed2:	fff80937          	lui	s2,0xfff80
		start += PTSIZE;
ffffffffc0200ed6:	00200ab7          	lui	s5,0x200
ffffffffc0200eda:	a019                	j	ffffffffc0200ee0 <exit_range+0x58>
	} while (start != 0 && start < end);
ffffffffc0200edc:	0334fe63          	bgeu	s1,s3,ffffffffc0200f18 <exit_range+0x90>
		int pde_idx = PDX1(start);
ffffffffc0200ee0:	01e4d413          	srli	s0,s1,0x1e
		if (pgdir[pde_idx] & PTE_V) {
ffffffffc0200ee4:	1ff47413          	andi	s0,s0,511
ffffffffc0200ee8:	040e                	slli	s0,s0,0x3
ffffffffc0200eea:	9452                	add	s0,s0,s4
ffffffffc0200eec:	601c                	ld	a5,0(s0)
ffffffffc0200eee:	0017f713          	andi	a4,a5,1
ffffffffc0200ef2:	c30d                	beqz	a4,ffffffffc0200f14 <exit_range+0x8c>
	if (PPN(pa) >= npage) {
ffffffffc0200ef4:	000b3703          	ld	a4,0(s6)
	return pa2page(PDE_ADDR(pde));
ffffffffc0200ef8:	078a                	slli	a5,a5,0x2
ffffffffc0200efa:	83b1                	srli	a5,a5,0xc
	if (PPN(pa) >= npage) {
ffffffffc0200efc:	02e7f963          	bgeu	a5,a4,ffffffffc0200f2e <exit_range+0xa6>
	return &pages[PPN(pa) - nbase];
ffffffffc0200f00:	000bb503          	ld	a0,0(s7)
ffffffffc0200f04:	97ca                	add	a5,a5,s2
ffffffffc0200f06:	079a                	slli	a5,a5,0x6
			free_page(pde2page(pgdir[pde_idx]));
ffffffffc0200f08:	4585                	li	a1,1
ffffffffc0200f0a:	953e                	add	a0,a0,a5
ffffffffc0200f0c:	ac1ff0ef          	jal	ra,ffffffffc02009cc <free_pages>
			pgdir[pde_idx] = 0;
ffffffffc0200f10:	00043023          	sd	zero,0(s0)
		start += PTSIZE;
ffffffffc0200f14:	94d6                	add	s1,s1,s5
	} while (start != 0 && start < end);
ffffffffc0200f16:	f0f9                	bnez	s1,ffffffffc0200edc <exit_range+0x54>
}
ffffffffc0200f18:	60a6                	ld	ra,72(sp)
ffffffffc0200f1a:	6406                	ld	s0,64(sp)
ffffffffc0200f1c:	74e2                	ld	s1,56(sp)
ffffffffc0200f1e:	7942                	ld	s2,48(sp)
ffffffffc0200f20:	79a2                	ld	s3,40(sp)
ffffffffc0200f22:	7a02                	ld	s4,32(sp)
ffffffffc0200f24:	6ae2                	ld	s5,24(sp)
ffffffffc0200f26:	6b42                	ld	s6,16(sp)
ffffffffc0200f28:	6ba2                	ld	s7,8(sp)
ffffffffc0200f2a:	6161                	addi	sp,sp,80
ffffffffc0200f2c:	8082                	ret
		panic("pa2page called with invalid pa");
ffffffffc0200f2e:	00004617          	auipc	a2,0x4
ffffffffc0200f32:	e1260613          	addi	a2,a2,-494 # ffffffffc0204d40 <etext+0x6fe>
ffffffffc0200f36:	06b00593          	li	a1,107
ffffffffc0200f3a:	00004517          	auipc	a0,0x4
ffffffffc0200f3e:	e2650513          	addi	a0,a0,-474 # ffffffffc0204d60 <etext+0x71e>
ffffffffc0200f42:	9f6ff0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(USER_ACCESS(start, end));
ffffffffc0200f46:	00004697          	auipc	a3,0x4
ffffffffc0200f4a:	f1268693          	addi	a3,a3,-238 # ffffffffc0204e58 <etext+0x816>
ffffffffc0200f4e:	00004617          	auipc	a2,0x4
ffffffffc0200f52:	b0260613          	addi	a2,a2,-1278 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0200f56:	15f00593          	li	a1,351
ffffffffc0200f5a:	00004517          	auipc	a0,0x4
ffffffffc0200f5e:	e9650513          	addi	a0,a0,-362 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc0200f62:	9d6ff0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0200f66:	00004697          	auipc	a3,0x4
ffffffffc0200f6a:	ec268693          	addi	a3,a3,-318 # ffffffffc0204e28 <etext+0x7e6>
ffffffffc0200f6e:	00004617          	auipc	a2,0x4
ffffffffc0200f72:	ae260613          	addi	a2,a2,-1310 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0200f76:	15e00593          	li	a1,350
ffffffffc0200f7a:	00004517          	auipc	a0,0x4
ffffffffc0200f7e:	e7650513          	addi	a0,a0,-394 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc0200f82:	9b6ff0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0200f86 <page_insert>:
{
ffffffffc0200f86:	7179                	addi	sp,sp,-48
ffffffffc0200f88:	e44e                	sd	s3,8(sp)
ffffffffc0200f8a:	89b2                	mv	s3,a2
ffffffffc0200f8c:	f022                	sd	s0,32(sp)
	pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f8e:	4605                	li	a2,1
{
ffffffffc0200f90:	842e                	mv	s0,a1
	pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f92:	85ce                	mv	a1,s3
{
ffffffffc0200f94:	ec26                	sd	s1,24(sp)
ffffffffc0200f96:	f406                	sd	ra,40(sp)
ffffffffc0200f98:	e84a                	sd	s2,16(sp)
ffffffffc0200f9a:	e052                	sd	s4,0(sp)
ffffffffc0200f9c:	84b6                	mv	s1,a3
	pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0200f9e:	c03ff0ef          	jal	ra,ffffffffc0200ba0 <get_pte>
	if (ptep == NULL) {
ffffffffc0200fa2:	cd41                	beqz	a0,ffffffffc020103a <page_insert+0xb4>
	page->ref += 1;
ffffffffc0200fa4:	4014                	lw	a3,0(s0)
	if (*ptep & PTE_V) {
ffffffffc0200fa6:	611c                	ld	a5,0(a0)
ffffffffc0200fa8:	892a                	mv	s2,a0
ffffffffc0200faa:	0016871b          	addiw	a4,a3,1
ffffffffc0200fae:	c018                	sw	a4,0(s0)
ffffffffc0200fb0:	0017f713          	andi	a4,a5,1
ffffffffc0200fb4:	eb1d                	bnez	a4,ffffffffc0200fea <page_insert+0x64>
ffffffffc0200fb6:	0001e717          	auipc	a4,0x1e
ffffffffc0200fba:	86a73703          	ld	a4,-1942(a4) # ffffffffc021e820 <pages>
	return page - pages + nbase;
ffffffffc0200fbe:	8c19                	sub	s0,s0,a4
ffffffffc0200fc0:	000807b7          	lui	a5,0x80
ffffffffc0200fc4:	8419                	srai	s0,s0,0x6
ffffffffc0200fc6:	943e                	add	s0,s0,a5
	return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0200fc8:	042a                	slli	s0,s0,0xa
ffffffffc0200fca:	8c45                	or	s0,s0,s1
ffffffffc0200fcc:	00146413          	ori	s0,s0,1
	*ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0200fd0:	00893023          	sd	s0,0(s2) # fffffffffff80000 <end+0x3fd616d0>
	asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0200fd4:	12098073          	sfence.vma	s3
	return 0;
ffffffffc0200fd8:	4501                	li	a0,0
}
ffffffffc0200fda:	70a2                	ld	ra,40(sp)
ffffffffc0200fdc:	7402                	ld	s0,32(sp)
ffffffffc0200fde:	64e2                	ld	s1,24(sp)
ffffffffc0200fe0:	6942                	ld	s2,16(sp)
ffffffffc0200fe2:	69a2                	ld	s3,8(sp)
ffffffffc0200fe4:	6a02                	ld	s4,0(sp)
ffffffffc0200fe6:	6145                	addi	sp,sp,48
ffffffffc0200fe8:	8082                	ret
	return pa2page(PTE_ADDR(pte));
ffffffffc0200fea:	078a                	slli	a5,a5,0x2
ffffffffc0200fec:	83b1                	srli	a5,a5,0xc
	if (PPN(pa) >= npage) {
ffffffffc0200fee:	0001d717          	auipc	a4,0x1d
ffffffffc0200ff2:	7ca73703          	ld	a4,1994(a4) # ffffffffc021e7b8 <npage>
ffffffffc0200ff6:	04e7f463          	bgeu	a5,a4,ffffffffc020103e <page_insert+0xb8>
	return &pages[PPN(pa) - nbase];
ffffffffc0200ffa:	0001ea17          	auipc	s4,0x1e
ffffffffc0200ffe:	826a0a13          	addi	s4,s4,-2010 # ffffffffc021e820 <pages>
ffffffffc0201002:	000a3703          	ld	a4,0(s4)
ffffffffc0201006:	fff80537          	lui	a0,0xfff80
ffffffffc020100a:	97aa                	add	a5,a5,a0
ffffffffc020100c:	079a                	slli	a5,a5,0x6
ffffffffc020100e:	97ba                	add	a5,a5,a4
		if (p == page) {
ffffffffc0201010:	00f40a63          	beq	s0,a5,ffffffffc0201024 <page_insert+0x9e>
	page->ref -= 1;
ffffffffc0201014:	4394                	lw	a3,0(a5)
ffffffffc0201016:	fff6861b          	addiw	a2,a3,-1
ffffffffc020101a:	c390                	sw	a2,0(a5)
		if (page_ref(page) ==
ffffffffc020101c:	c611                	beqz	a2,ffffffffc0201028 <page_insert+0xa2>
	asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020101e:	12098073          	sfence.vma	s3
}
ffffffffc0201022:	bf71                	j	ffffffffc0200fbe <page_insert+0x38>
ffffffffc0201024:	c014                	sw	a3,0(s0)
	return page->ref;
ffffffffc0201026:	bf61                	j	ffffffffc0200fbe <page_insert+0x38>
			free_page(page);
ffffffffc0201028:	4585                	li	a1,1
ffffffffc020102a:	853e                	mv	a0,a5
ffffffffc020102c:	9a1ff0ef          	jal	ra,ffffffffc02009cc <free_pages>
ffffffffc0201030:	000a3703          	ld	a4,0(s4)
	asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201034:	12098073          	sfence.vma	s3
ffffffffc0201038:	b759                	j	ffffffffc0200fbe <page_insert+0x38>
		return -E_NO_MEM;
ffffffffc020103a:	5571                	li	a0,-4
ffffffffc020103c:	bf79                	j	ffffffffc0200fda <page_insert+0x54>
ffffffffc020103e:	8e1ff0ef          	jal	ra,ffffffffc020091e <pa2page.part.0>

ffffffffc0201042 <copy_range>:
{
ffffffffc0201042:	7159                	addi	sp,sp,-112
	assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201044:	00d667b3          	or	a5,a2,a3
{
ffffffffc0201048:	f486                	sd	ra,104(sp)
ffffffffc020104a:	f0a2                	sd	s0,96(sp)
ffffffffc020104c:	eca6                	sd	s1,88(sp)
ffffffffc020104e:	e8ca                	sd	s2,80(sp)
ffffffffc0201050:	e4ce                	sd	s3,72(sp)
ffffffffc0201052:	e0d2                	sd	s4,64(sp)
ffffffffc0201054:	fc56                	sd	s5,56(sp)
ffffffffc0201056:	f85a                	sd	s6,48(sp)
ffffffffc0201058:	f45e                	sd	s7,40(sp)
ffffffffc020105a:	f062                	sd	s8,32(sp)
ffffffffc020105c:	ec66                	sd	s9,24(sp)
ffffffffc020105e:	e86a                	sd	s10,16(sp)
ffffffffc0201060:	e46e                	sd	s11,8(sp)
	assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201062:	17d2                	slli	a5,a5,0x34
ffffffffc0201064:	1e079763          	bnez	a5,ffffffffc0201252 <copy_range+0x210>
	assert(USER_ACCESS(start, end));
ffffffffc0201068:	002007b7          	lui	a5,0x200
ffffffffc020106c:	8432                	mv	s0,a2
ffffffffc020106e:	16f66a63          	bltu	a2,a5,ffffffffc02011e2 <copy_range+0x1a0>
ffffffffc0201072:	8936                	mv	s2,a3
ffffffffc0201074:	16d67763          	bgeu	a2,a3,ffffffffc02011e2 <copy_range+0x1a0>
ffffffffc0201078:	4785                	li	a5,1
ffffffffc020107a:	07fe                	slli	a5,a5,0x1f
ffffffffc020107c:	16d7e363          	bltu	a5,a3,ffffffffc02011e2 <copy_range+0x1a0>
	return KADDR(page2pa(page));
ffffffffc0201080:	5b7d                	li	s6,-1
ffffffffc0201082:	8aaa                	mv	s5,a0
ffffffffc0201084:	89ae                	mv	s3,a1
		start += PGSIZE;
ffffffffc0201086:	6a05                	lui	s4,0x1
	if (PPN(pa) >= npage) {
ffffffffc0201088:	0001dc97          	auipc	s9,0x1d
ffffffffc020108c:	730c8c93          	addi	s9,s9,1840 # ffffffffc021e7b8 <npage>
	return &pages[PPN(pa) - nbase];
ffffffffc0201090:	0001dc17          	auipc	s8,0x1d
ffffffffc0201094:	790c0c13          	addi	s8,s8,1936 # ffffffffc021e820 <pages>
	return page - pages + nbase;
ffffffffc0201098:	00080bb7          	lui	s7,0x80
	return KADDR(page2pa(page));
ffffffffc020109c:	00cb5b13          	srli	s6,s6,0xc
		pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02010a0:	4601                	li	a2,0
ffffffffc02010a2:	85a2                	mv	a1,s0
ffffffffc02010a4:	854e                	mv	a0,s3
ffffffffc02010a6:	afbff0ef          	jal	ra,ffffffffc0200ba0 <get_pte>
ffffffffc02010aa:	84aa                	mv	s1,a0
		if (ptep == NULL) {
ffffffffc02010ac:	c175                	beqz	a0,ffffffffc0201190 <copy_range+0x14e>
		if (*ptep & PTE_V) {
ffffffffc02010ae:	611c                	ld	a5,0(a0)
ffffffffc02010b0:	8b85                	andi	a5,a5,1
ffffffffc02010b2:	e785                	bnez	a5,ffffffffc02010da <copy_range+0x98>
		start += PGSIZE;
ffffffffc02010b4:	9452                	add	s0,s0,s4
	} while (start != 0 && start < end);
ffffffffc02010b6:	ff2465e3          	bltu	s0,s2,ffffffffc02010a0 <copy_range+0x5e>
	return 0;
ffffffffc02010ba:	4501                	li	a0,0
}
ffffffffc02010bc:	70a6                	ld	ra,104(sp)
ffffffffc02010be:	7406                	ld	s0,96(sp)
ffffffffc02010c0:	64e6                	ld	s1,88(sp)
ffffffffc02010c2:	6946                	ld	s2,80(sp)
ffffffffc02010c4:	69a6                	ld	s3,72(sp)
ffffffffc02010c6:	6a06                	ld	s4,64(sp)
ffffffffc02010c8:	7ae2                	ld	s5,56(sp)
ffffffffc02010ca:	7b42                	ld	s6,48(sp)
ffffffffc02010cc:	7ba2                	ld	s7,40(sp)
ffffffffc02010ce:	7c02                	ld	s8,32(sp)
ffffffffc02010d0:	6ce2                	ld	s9,24(sp)
ffffffffc02010d2:	6d42                	ld	s10,16(sp)
ffffffffc02010d4:	6da2                	ld	s11,8(sp)
ffffffffc02010d6:	6165                	addi	sp,sp,112
ffffffffc02010d8:	8082                	ret
			if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc02010da:	4605                	li	a2,1
ffffffffc02010dc:	85a2                	mv	a1,s0
ffffffffc02010de:	8556                	mv	a0,s5
ffffffffc02010e0:	ac1ff0ef          	jal	ra,ffffffffc0200ba0 <get_pte>
ffffffffc02010e4:	c161                	beqz	a0,ffffffffc02011a4 <copy_range+0x162>
			uint32_t perm = (*ptep & PTE_USER);
ffffffffc02010e6:	609c                	ld	a5,0(s1)
	if (!(pte & PTE_V)) {
ffffffffc02010e8:	0017f713          	andi	a4,a5,1
ffffffffc02010ec:	01f7f493          	andi	s1,a5,31
ffffffffc02010f0:	14070563          	beqz	a4,ffffffffc020123a <copy_range+0x1f8>
	if (PPN(pa) >= npage) {
ffffffffc02010f4:	000cb683          	ld	a3,0(s9)
	return pa2page(PTE_ADDR(pte));
ffffffffc02010f8:	078a                	slli	a5,a5,0x2
ffffffffc02010fa:	00c7d713          	srli	a4,a5,0xc
	if (PPN(pa) >= npage) {
ffffffffc02010fe:	12d77263          	bgeu	a4,a3,ffffffffc0201222 <copy_range+0x1e0>
	return &pages[PPN(pa) - nbase];
ffffffffc0201102:	000c3783          	ld	a5,0(s8)
ffffffffc0201106:	fff806b7          	lui	a3,0xfff80
ffffffffc020110a:	9736                	add	a4,a4,a3
ffffffffc020110c:	071a                	slli	a4,a4,0x6
			struct Page *npage = alloc_page();
ffffffffc020110e:	4505                	li	a0,1
ffffffffc0201110:	00e78db3          	add	s11,a5,a4
ffffffffc0201114:	827ff0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc0201118:	8d2a                	mv	s10,a0
			assert(page != NULL);
ffffffffc020111a:	0a0d8463          	beqz	s11,ffffffffc02011c2 <copy_range+0x180>
			assert(npage != NULL);
ffffffffc020111e:	c175                	beqz	a0,ffffffffc0201202 <copy_range+0x1c0>
	return page - pages + nbase;
ffffffffc0201120:	000c3703          	ld	a4,0(s8)
	return KADDR(page2pa(page));
ffffffffc0201124:	000cb603          	ld	a2,0(s9)
	return page - pages + nbase;
ffffffffc0201128:	40ed86b3          	sub	a3,s11,a4
ffffffffc020112c:	8699                	srai	a3,a3,0x6
ffffffffc020112e:	96de                	add	a3,a3,s7
	return KADDR(page2pa(page));
ffffffffc0201130:	0166f7b3          	and	a5,a3,s6
	return page2ppn(page) << PGSHIFT;
ffffffffc0201134:	06b2                	slli	a3,a3,0xc
	return KADDR(page2pa(page));
ffffffffc0201136:	06c7fa63          	bgeu	a5,a2,ffffffffc02011aa <copy_range+0x168>
	return page - pages + nbase;
ffffffffc020113a:	40e507b3          	sub	a5,a0,a4
	return KADDR(page2pa(page));
ffffffffc020113e:	0001d717          	auipc	a4,0x1d
ffffffffc0201142:	6da70713          	addi	a4,a4,1754 # ffffffffc021e818 <va_pa_offset>
ffffffffc0201146:	6308                	ld	a0,0(a4)
	return page - pages + nbase;
ffffffffc0201148:	8799                	srai	a5,a5,0x6
ffffffffc020114a:	97de                	add	a5,a5,s7
	return KADDR(page2pa(page));
ffffffffc020114c:	0167f733          	and	a4,a5,s6
ffffffffc0201150:	00a685b3          	add	a1,a3,a0
	return page2ppn(page) << PGSHIFT;
ffffffffc0201154:	07b2                	slli	a5,a5,0xc
	return KADDR(page2pa(page));
ffffffffc0201156:	04c77963          	bgeu	a4,a2,ffffffffc02011a8 <copy_range+0x166>
			memcpy(kva_dst, kva_src, PGSIZE);
ffffffffc020115a:	6605                	lui	a2,0x1
ffffffffc020115c:	953e                	add	a0,a0,a5
ffffffffc020115e:	0c8030ef          	jal	ra,ffffffffc0204226 <memcpy>
			ret = page_insert(to, npage, start, perm);
ffffffffc0201162:	86a6                	mv	a3,s1
ffffffffc0201164:	8622                	mv	a2,s0
ffffffffc0201166:	85ea                	mv	a1,s10
ffffffffc0201168:	8556                	mv	a0,s5
ffffffffc020116a:	e1dff0ef          	jal	ra,ffffffffc0200f86 <page_insert>
			assert(ret == 0);
ffffffffc020116e:	d139                	beqz	a0,ffffffffc02010b4 <copy_range+0x72>
ffffffffc0201170:	00004697          	auipc	a3,0x4
ffffffffc0201174:	d4868693          	addi	a3,a3,-696 # ffffffffc0204eb8 <etext+0x876>
ffffffffc0201178:	00004617          	auipc	a2,0x4
ffffffffc020117c:	8d860613          	addi	a2,a2,-1832 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201180:	1a700593          	li	a1,423
ffffffffc0201184:	00004517          	auipc	a0,0x4
ffffffffc0201188:	c6c50513          	addi	a0,a0,-916 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc020118c:	fadfe0ef          	jal	ra,ffffffffc0200138 <__panic>
			start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0201190:	00200637          	lui	a2,0x200
ffffffffc0201194:	9432                	add	s0,s0,a2
ffffffffc0201196:	ffe00637          	lui	a2,0xffe00
ffffffffc020119a:	8c71                	and	s0,s0,a2
	} while (start != 0 && start < end);
ffffffffc020119c:	dc19                	beqz	s0,ffffffffc02010ba <copy_range+0x78>
ffffffffc020119e:	f12461e3          	bltu	s0,s2,ffffffffc02010a0 <copy_range+0x5e>
ffffffffc02011a2:	bf21                	j	ffffffffc02010ba <copy_range+0x78>
				return -E_NO_MEM;
ffffffffc02011a4:	5571                	li	a0,-4
ffffffffc02011a6:	bf19                	j	ffffffffc02010bc <copy_range+0x7a>
ffffffffc02011a8:	86be                	mv	a3,a5
ffffffffc02011aa:	00004617          	auipc	a2,0x4
ffffffffc02011ae:	c5660613          	addi	a2,a2,-938 # ffffffffc0204e00 <etext+0x7be>
ffffffffc02011b2:	07200593          	li	a1,114
ffffffffc02011b6:	00004517          	auipc	a0,0x4
ffffffffc02011ba:	baa50513          	addi	a0,a0,-1110 # ffffffffc0204d60 <etext+0x71e>
ffffffffc02011be:	f7bfe0ef          	jal	ra,ffffffffc0200138 <__panic>
			assert(page != NULL);
ffffffffc02011c2:	00004697          	auipc	a3,0x4
ffffffffc02011c6:	cd668693          	addi	a3,a3,-810 # ffffffffc0204e98 <etext+0x856>
ffffffffc02011ca:	00004617          	auipc	a2,0x4
ffffffffc02011ce:	88660613          	addi	a2,a2,-1914 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02011d2:	18c00593          	li	a1,396
ffffffffc02011d6:	00004517          	auipc	a0,0x4
ffffffffc02011da:	c1a50513          	addi	a0,a0,-998 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc02011de:	f5bfe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(USER_ACCESS(start, end));
ffffffffc02011e2:	00004697          	auipc	a3,0x4
ffffffffc02011e6:	c7668693          	addi	a3,a3,-906 # ffffffffc0204e58 <etext+0x816>
ffffffffc02011ea:	00004617          	auipc	a2,0x4
ffffffffc02011ee:	86660613          	addi	a2,a2,-1946 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02011f2:	17800593          	li	a1,376
ffffffffc02011f6:	00004517          	auipc	a0,0x4
ffffffffc02011fa:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc02011fe:	f3bfe0ef          	jal	ra,ffffffffc0200138 <__panic>
			assert(npage != NULL);
ffffffffc0201202:	00004697          	auipc	a3,0x4
ffffffffc0201206:	ca668693          	addi	a3,a3,-858 # ffffffffc0204ea8 <etext+0x866>
ffffffffc020120a:	00004617          	auipc	a2,0x4
ffffffffc020120e:	84660613          	addi	a2,a2,-1978 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201212:	18d00593          	li	a1,397
ffffffffc0201216:	00004517          	auipc	a0,0x4
ffffffffc020121a:	bda50513          	addi	a0,a0,-1062 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc020121e:	f1bfe0ef          	jal	ra,ffffffffc0200138 <__panic>
		panic("pa2page called with invalid pa");
ffffffffc0201222:	00004617          	auipc	a2,0x4
ffffffffc0201226:	b1e60613          	addi	a2,a2,-1250 # ffffffffc0204d40 <etext+0x6fe>
ffffffffc020122a:	06b00593          	li	a1,107
ffffffffc020122e:	00004517          	auipc	a0,0x4
ffffffffc0201232:	b3250513          	addi	a0,a0,-1230 # ffffffffc0204d60 <etext+0x71e>
ffffffffc0201236:	f03fe0ef          	jal	ra,ffffffffc0200138 <__panic>
		panic("pte2page called with invalid pte");
ffffffffc020123a:	00004617          	auipc	a2,0x4
ffffffffc020123e:	c3660613          	addi	a2,a2,-970 # ffffffffc0204e70 <etext+0x82e>
ffffffffc0201242:	07d00593          	li	a1,125
ffffffffc0201246:	00004517          	auipc	a0,0x4
ffffffffc020124a:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0204d60 <etext+0x71e>
ffffffffc020124e:	eebfe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0201252:	00004697          	auipc	a3,0x4
ffffffffc0201256:	bd668693          	addi	a3,a3,-1066 # ffffffffc0204e28 <etext+0x7e6>
ffffffffc020125a:	00003617          	auipc	a2,0x3
ffffffffc020125e:	7f660613          	addi	a2,a2,2038 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201262:	17700593          	li	a1,375
ffffffffc0201266:	00004517          	auipc	a0,0x4
ffffffffc020126a:	b8a50513          	addi	a0,a0,-1142 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc020126e:	ecbfe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0201272 <tlb_invalidate>:
	asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0201272:	12058073          	sfence.vma	a1
}
ffffffffc0201276:	8082                	ret

ffffffffc0201278 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm)
{
ffffffffc0201278:	7179                	addi	sp,sp,-48
ffffffffc020127a:	e84a                	sd	s2,16(sp)
ffffffffc020127c:	892a                	mv	s2,a0
	struct Page *page = alloc_page();
ffffffffc020127e:	4505                	li	a0,1
{
ffffffffc0201280:	f022                	sd	s0,32(sp)
ffffffffc0201282:	ec26                	sd	s1,24(sp)
ffffffffc0201284:	e44e                	sd	s3,8(sp)
ffffffffc0201286:	f406                	sd	ra,40(sp)
ffffffffc0201288:	84ae                	mv	s1,a1
ffffffffc020128a:	89b2                	mv	s3,a2
	struct Page *page = alloc_page();
ffffffffc020128c:	eaeff0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc0201290:	842a                	mv	s0,a0
	if (page != NULL) {
ffffffffc0201292:	cd05                	beqz	a0,ffffffffc02012ca <pgdir_alloc_page+0x52>
		if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0201294:	85aa                	mv	a1,a0
ffffffffc0201296:	86ce                	mv	a3,s3
ffffffffc0201298:	8626                	mv	a2,s1
ffffffffc020129a:	854a                	mv	a0,s2
ffffffffc020129c:	cebff0ef          	jal	ra,ffffffffc0200f86 <page_insert>
ffffffffc02012a0:	ed0d                	bnez	a0,ffffffffc02012da <pgdir_alloc_page+0x62>
			free_page(page);
			return NULL;
		}
		if (swap_init_ok) {
ffffffffc02012a2:	0001d797          	auipc	a5,0x1d
ffffffffc02012a6:	5367a783          	lw	a5,1334(a5) # ffffffffc021e7d8 <swap_init_ok>
ffffffffc02012aa:	c385                	beqz	a5,ffffffffc02012ca <pgdir_alloc_page+0x52>
			if (check_mm_struct != NULL) {
ffffffffc02012ac:	0001d517          	auipc	a0,0x1d
ffffffffc02012b0:	58c53503          	ld	a0,1420(a0) # ffffffffc021e838 <check_mm_struct>
ffffffffc02012b4:	c919                	beqz	a0,ffffffffc02012ca <pgdir_alloc_page+0x52>
				swap_map_swappable(check_mm_struct, la, page,
ffffffffc02012b6:	4681                	li	a3,0
ffffffffc02012b8:	8622                	mv	a2,s0
ffffffffc02012ba:	85a6                	mv	a1,s1
ffffffffc02012bc:	58f000ef          	jal	ra,ffffffffc020204a <swap_map_swappable>
						   0);
				page->pra_vaddr = la;
				assert(page_ref(page) == 1);
ffffffffc02012c0:	4018                	lw	a4,0(s0)
				page->pra_vaddr = la;
ffffffffc02012c2:	fc04                	sd	s1,56(s0)
				assert(page_ref(page) == 1);
ffffffffc02012c4:	4785                	li	a5,1
ffffffffc02012c6:	02f71063          	bne	a4,a5,ffffffffc02012e6 <pgdir_alloc_page+0x6e>
			}
		}
	}

	return page;
}
ffffffffc02012ca:	70a2                	ld	ra,40(sp)
ffffffffc02012cc:	8522                	mv	a0,s0
ffffffffc02012ce:	7402                	ld	s0,32(sp)
ffffffffc02012d0:	64e2                	ld	s1,24(sp)
ffffffffc02012d2:	6942                	ld	s2,16(sp)
ffffffffc02012d4:	69a2                	ld	s3,8(sp)
ffffffffc02012d6:	6145                	addi	sp,sp,48
ffffffffc02012d8:	8082                	ret
			free_page(page);
ffffffffc02012da:	8522                	mv	a0,s0
ffffffffc02012dc:	4585                	li	a1,1
ffffffffc02012de:	eeeff0ef          	jal	ra,ffffffffc02009cc <free_pages>
			return NULL;
ffffffffc02012e2:	4401                	li	s0,0
ffffffffc02012e4:	b7dd                	j	ffffffffc02012ca <pgdir_alloc_page+0x52>
				assert(page_ref(page) == 1);
ffffffffc02012e6:	00004697          	auipc	a3,0x4
ffffffffc02012ea:	be268693          	addi	a3,a3,-1054 # ffffffffc0204ec8 <etext+0x886>
ffffffffc02012ee:	00003617          	auipc	a2,0x3
ffffffffc02012f2:	76260613          	addi	a2,a2,1890 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02012f6:	1eb00593          	li	a1,491
ffffffffc02012fa:	00004517          	auipc	a0,0x4
ffffffffc02012fe:	af650513          	addi	a0,a0,-1290 # ffffffffc0204df0 <etext+0x7ae>
ffffffffc0201302:	e37fe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0201306 <_fifo_init_mm>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void list_init(list_entry_t *elm)
{
	elm->prev = elm->next = elm;
ffffffffc0201306:	0001d797          	auipc	a5,0x1d
ffffffffc020130a:	52278793          	addi	a5,a5,1314 # ffffffffc021e828 <pra_list_head>
 * access FIFO PRA
 */
static int _fifo_init_mm(struct mm_struct *mm)
{
	list_init(&pra_list_head);
	mm->sm_priv = &pra_list_head;
ffffffffc020130e:	f51c                	sd	a5,40(a0)
ffffffffc0201310:	e79c                	sd	a5,8(a5)
ffffffffc0201312:	e39c                	sd	a5,0(a5)
	// cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
	return 0;
}
ffffffffc0201314:	4501                	li	a0,0
ffffffffc0201316:	8082                	ret

ffffffffc0201318 <_fifo_init>:
}

static int _fifo_init(void)
{
	return 0;
}
ffffffffc0201318:	4501                	li	a0,0
ffffffffc020131a:	8082                	ret

ffffffffc020131c <_fifo_set_unswappable>:

static int _fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
	return 0;
}
ffffffffc020131c:	4501                	li	a0,0
ffffffffc020131e:	8082                	ret

ffffffffc0201320 <_fifo_tick_event>:

static int _fifo_tick_event(struct mm_struct *mm)
{
	return 0;
}
ffffffffc0201320:	4501                	li	a0,0
ffffffffc0201322:	8082                	ret

ffffffffc0201324 <_fifo_check_swap>:
{
ffffffffc0201324:	711d                	addi	sp,sp,-96
ffffffffc0201326:	fc4e                	sd	s3,56(sp)
ffffffffc0201328:	f852                	sd	s4,48(sp)
	cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020132a:	00004517          	auipc	a0,0x4
ffffffffc020132e:	bb650513          	addi	a0,a0,-1098 # ffffffffc0204ee0 <etext+0x89e>
	*(unsigned char *)0x3000 = 0x0c;
ffffffffc0201332:	698d                	lui	s3,0x3
ffffffffc0201334:	4a31                	li	s4,12
{
ffffffffc0201336:	e0ca                	sd	s2,64(sp)
ffffffffc0201338:	ec86                	sd	ra,88(sp)
ffffffffc020133a:	e8a2                	sd	s0,80(sp)
ffffffffc020133c:	e4a6                	sd	s1,72(sp)
ffffffffc020133e:	f456                	sd	s5,40(sp)
ffffffffc0201340:	f05a                	sd	s6,32(sp)
ffffffffc0201342:	ec5e                	sd	s7,24(sp)
ffffffffc0201344:	e862                	sd	s8,16(sp)
ffffffffc0201346:	e466                	sd	s9,8(sp)
ffffffffc0201348:	e06a                	sd	s10,0(sp)
	cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc020134a:	d77fe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	*(unsigned char *)0x3000 = 0x0c;
ffffffffc020134e:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_hello_out_size-0x6740>
	assert(pgfault_num == 4);
ffffffffc0201352:	0001d917          	auipc	s2,0x1d
ffffffffc0201356:	46e92903          	lw	s2,1134(s2) # ffffffffc021e7c0 <pgfault_num>
ffffffffc020135a:	4791                	li	a5,4
ffffffffc020135c:	14f91e63          	bne	s2,a5,ffffffffc02014b8 <_fifo_check_swap+0x194>
	cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0201360:	00004517          	auipc	a0,0x4
ffffffffc0201364:	bd850513          	addi	a0,a0,-1064 # ffffffffc0204f38 <etext+0x8f6>
	*(unsigned char *)0x1000 = 0x0a;
ffffffffc0201368:	6a85                	lui	s5,0x1
ffffffffc020136a:	4b29                	li	s6,10
	cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020136c:	d55fe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
ffffffffc0201370:	0001d417          	auipc	s0,0x1d
ffffffffc0201374:	45040413          	addi	s0,s0,1104 # ffffffffc021e7c0 <pgfault_num>
	*(unsigned char *)0x1000 = 0x0a;
ffffffffc0201378:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_hello_out_size-0x8740>
	assert(pgfault_num == 4);
ffffffffc020137c:	4004                	lw	s1,0(s0)
ffffffffc020137e:	2481                	sext.w	s1,s1
ffffffffc0201380:	2b249c63          	bne	s1,s2,ffffffffc0201638 <_fifo_check_swap+0x314>
	cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201384:	00004517          	auipc	a0,0x4
ffffffffc0201388:	bdc50513          	addi	a0,a0,-1060 # ffffffffc0204f60 <etext+0x91e>
	*(unsigned char *)0x4000 = 0x0d;
ffffffffc020138c:	6b91                	lui	s7,0x4
ffffffffc020138e:	4c35                	li	s8,13
	cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201390:	d31fe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	*(unsigned char *)0x4000 = 0x0d;
ffffffffc0201394:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_hello_out_size-0x5740>
	assert(pgfault_num == 4);
ffffffffc0201398:	00042903          	lw	s2,0(s0)
ffffffffc020139c:	2901                	sext.w	s2,s2
ffffffffc020139e:	26991d63          	bne	s2,s1,ffffffffc0201618 <_fifo_check_swap+0x2f4>
	cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02013a2:	00004517          	auipc	a0,0x4
ffffffffc02013a6:	be650513          	addi	a0,a0,-1050 # ffffffffc0204f88 <etext+0x946>
	*(unsigned char *)0x2000 = 0x0b;
ffffffffc02013aa:	6c89                	lui	s9,0x2
ffffffffc02013ac:	4d2d                	li	s10,11
	cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02013ae:	d13fe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	*(unsigned char *)0x2000 = 0x0b;
ffffffffc02013b2:	01ac8023          	sb	s10,0(s9) # 2000 <_binary_obj___user_hello_out_size-0x7740>
	assert(pgfault_num == 4);
ffffffffc02013b6:	401c                	lw	a5,0(s0)
ffffffffc02013b8:	2781                	sext.w	a5,a5
ffffffffc02013ba:	23279f63          	bne	a5,s2,ffffffffc02015f8 <_fifo_check_swap+0x2d4>
	cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc02013be:	00004517          	auipc	a0,0x4
ffffffffc02013c2:	bf250513          	addi	a0,a0,-1038 # ffffffffc0204fb0 <etext+0x96e>
ffffffffc02013c6:	cfbfe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	*(unsigned char *)0x5000 = 0x0e;
ffffffffc02013ca:	6795                	lui	a5,0x5
ffffffffc02013cc:	4739                	li	a4,14
ffffffffc02013ce:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_hello_out_size-0x4740>
	assert(pgfault_num == 5);
ffffffffc02013d2:	4004                	lw	s1,0(s0)
ffffffffc02013d4:	4795                	li	a5,5
ffffffffc02013d6:	2481                	sext.w	s1,s1
ffffffffc02013d8:	20f49063          	bne	s1,a5,ffffffffc02015d8 <_fifo_check_swap+0x2b4>
	cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc02013dc:	00004517          	auipc	a0,0x4
ffffffffc02013e0:	bac50513          	addi	a0,a0,-1108 # ffffffffc0204f88 <etext+0x946>
ffffffffc02013e4:	cddfe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	*(unsigned char *)0x2000 = 0x0b;
ffffffffc02013e8:	01ac8023          	sb	s10,0(s9)
	assert(pgfault_num == 5);
ffffffffc02013ec:	401c                	lw	a5,0(s0)
ffffffffc02013ee:	2781                	sext.w	a5,a5
ffffffffc02013f0:	1c979463          	bne	a5,s1,ffffffffc02015b8 <_fifo_check_swap+0x294>
	cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc02013f4:	00004517          	auipc	a0,0x4
ffffffffc02013f8:	b4450513          	addi	a0,a0,-1212 # ffffffffc0204f38 <etext+0x8f6>
ffffffffc02013fc:	cc5fe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	*(unsigned char *)0x1000 = 0x0a;
ffffffffc0201400:	016a8023          	sb	s6,0(s5)
	assert(pgfault_num == 6);
ffffffffc0201404:	401c                	lw	a5,0(s0)
ffffffffc0201406:	4719                	li	a4,6
ffffffffc0201408:	2781                	sext.w	a5,a5
ffffffffc020140a:	18e79763          	bne	a5,a4,ffffffffc0201598 <_fifo_check_swap+0x274>
	cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc020140e:	00004517          	auipc	a0,0x4
ffffffffc0201412:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0204f88 <etext+0x946>
ffffffffc0201416:	cabfe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	*(unsigned char *)0x2000 = 0x0b;
ffffffffc020141a:	01ac8023          	sb	s10,0(s9)
	assert(pgfault_num == 7);
ffffffffc020141e:	401c                	lw	a5,0(s0)
ffffffffc0201420:	471d                	li	a4,7
ffffffffc0201422:	2781                	sext.w	a5,a5
ffffffffc0201424:	14e79a63          	bne	a5,a4,ffffffffc0201578 <_fifo_check_swap+0x254>
	cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0201428:	00004517          	auipc	a0,0x4
ffffffffc020142c:	ab850513          	addi	a0,a0,-1352 # ffffffffc0204ee0 <etext+0x89e>
ffffffffc0201430:	c91fe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	*(unsigned char *)0x3000 = 0x0c;
ffffffffc0201434:	01498023          	sb	s4,0(s3)
	assert(pgfault_num == 8);
ffffffffc0201438:	401c                	lw	a5,0(s0)
ffffffffc020143a:	4721                	li	a4,8
ffffffffc020143c:	2781                	sext.w	a5,a5
ffffffffc020143e:	10e79d63          	bne	a5,a4,ffffffffc0201558 <_fifo_check_swap+0x234>
	cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0201442:	00004517          	auipc	a0,0x4
ffffffffc0201446:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0204f60 <etext+0x91e>
ffffffffc020144a:	c77fe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	*(unsigned char *)0x4000 = 0x0d;
ffffffffc020144e:	018b8023          	sb	s8,0(s7)
	assert(pgfault_num == 9);
ffffffffc0201452:	401c                	lw	a5,0(s0)
ffffffffc0201454:	4725                	li	a4,9
ffffffffc0201456:	2781                	sext.w	a5,a5
ffffffffc0201458:	0ee79063          	bne	a5,a4,ffffffffc0201538 <_fifo_check_swap+0x214>
	cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc020145c:	00004517          	auipc	a0,0x4
ffffffffc0201460:	b5450513          	addi	a0,a0,-1196 # ffffffffc0204fb0 <etext+0x96e>
ffffffffc0201464:	c5dfe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	*(unsigned char *)0x5000 = 0x0e;
ffffffffc0201468:	6795                	lui	a5,0x5
ffffffffc020146a:	4739                	li	a4,14
ffffffffc020146c:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_hello_out_size-0x4740>
	assert(pgfault_num == 10);
ffffffffc0201470:	4004                	lw	s1,0(s0)
ffffffffc0201472:	47a9                	li	a5,10
ffffffffc0201474:	2481                	sext.w	s1,s1
ffffffffc0201476:	0af49163          	bne	s1,a5,ffffffffc0201518 <_fifo_check_swap+0x1f4>
	cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc020147a:	00004517          	auipc	a0,0x4
ffffffffc020147e:	abe50513          	addi	a0,a0,-1346 # ffffffffc0204f38 <etext+0x8f6>
ffffffffc0201482:	c3ffe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0201486:	6785                	lui	a5,0x1
ffffffffc0201488:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_hello_out_size-0x8740>
ffffffffc020148c:	06979663          	bne	a5,s1,ffffffffc02014f8 <_fifo_check_swap+0x1d4>
	assert(pgfault_num == 11);
ffffffffc0201490:	401c                	lw	a5,0(s0)
ffffffffc0201492:	472d                	li	a4,11
ffffffffc0201494:	2781                	sext.w	a5,a5
ffffffffc0201496:	04e79163          	bne	a5,a4,ffffffffc02014d8 <_fifo_check_swap+0x1b4>
}
ffffffffc020149a:	60e6                	ld	ra,88(sp)
ffffffffc020149c:	6446                	ld	s0,80(sp)
ffffffffc020149e:	64a6                	ld	s1,72(sp)
ffffffffc02014a0:	6906                	ld	s2,64(sp)
ffffffffc02014a2:	79e2                	ld	s3,56(sp)
ffffffffc02014a4:	7a42                	ld	s4,48(sp)
ffffffffc02014a6:	7aa2                	ld	s5,40(sp)
ffffffffc02014a8:	7b02                	ld	s6,32(sp)
ffffffffc02014aa:	6be2                	ld	s7,24(sp)
ffffffffc02014ac:	6c42                	ld	s8,16(sp)
ffffffffc02014ae:	6ca2                	ld	s9,8(sp)
ffffffffc02014b0:	6d02                	ld	s10,0(sp)
ffffffffc02014b2:	4501                	li	a0,0
ffffffffc02014b4:	6125                	addi	sp,sp,96
ffffffffc02014b6:	8082                	ret
	assert(pgfault_num == 4);
ffffffffc02014b8:	00004697          	auipc	a3,0x4
ffffffffc02014bc:	a5068693          	addi	a3,a3,-1456 # ffffffffc0204f08 <etext+0x8c6>
ffffffffc02014c0:	00003617          	auipc	a2,0x3
ffffffffc02014c4:	59060613          	addi	a2,a2,1424 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02014c8:	05800593          	li	a1,88
ffffffffc02014cc:	00004517          	auipc	a0,0x4
ffffffffc02014d0:	a5450513          	addi	a0,a0,-1452 # ffffffffc0204f20 <etext+0x8de>
ffffffffc02014d4:	c65fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgfault_num == 11);
ffffffffc02014d8:	00004697          	auipc	a3,0x4
ffffffffc02014dc:	bb868693          	addi	a3,a3,-1096 # ffffffffc0205090 <etext+0xa4e>
ffffffffc02014e0:	00003617          	auipc	a2,0x3
ffffffffc02014e4:	57060613          	addi	a2,a2,1392 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02014e8:	07a00593          	li	a1,122
ffffffffc02014ec:	00004517          	auipc	a0,0x4
ffffffffc02014f0:	a3450513          	addi	a0,a0,-1484 # ffffffffc0204f20 <etext+0x8de>
ffffffffc02014f4:	c45fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02014f8:	00004697          	auipc	a3,0x4
ffffffffc02014fc:	b7068693          	addi	a3,a3,-1168 # ffffffffc0205068 <etext+0xa26>
ffffffffc0201500:	00003617          	auipc	a2,0x3
ffffffffc0201504:	55060613          	addi	a2,a2,1360 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201508:	07800593          	li	a1,120
ffffffffc020150c:	00004517          	auipc	a0,0x4
ffffffffc0201510:	a1450513          	addi	a0,a0,-1516 # ffffffffc0204f20 <etext+0x8de>
ffffffffc0201514:	c25fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgfault_num == 10);
ffffffffc0201518:	00004697          	auipc	a3,0x4
ffffffffc020151c:	b3868693          	addi	a3,a3,-1224 # ffffffffc0205050 <etext+0xa0e>
ffffffffc0201520:	00003617          	auipc	a2,0x3
ffffffffc0201524:	53060613          	addi	a2,a2,1328 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201528:	07600593          	li	a1,118
ffffffffc020152c:	00004517          	auipc	a0,0x4
ffffffffc0201530:	9f450513          	addi	a0,a0,-1548 # ffffffffc0204f20 <etext+0x8de>
ffffffffc0201534:	c05fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgfault_num == 9);
ffffffffc0201538:	00004697          	auipc	a3,0x4
ffffffffc020153c:	b0068693          	addi	a3,a3,-1280 # ffffffffc0205038 <etext+0x9f6>
ffffffffc0201540:	00003617          	auipc	a2,0x3
ffffffffc0201544:	51060613          	addi	a2,a2,1296 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201548:	07300593          	li	a1,115
ffffffffc020154c:	00004517          	auipc	a0,0x4
ffffffffc0201550:	9d450513          	addi	a0,a0,-1580 # ffffffffc0204f20 <etext+0x8de>
ffffffffc0201554:	be5fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgfault_num == 8);
ffffffffc0201558:	00004697          	auipc	a3,0x4
ffffffffc020155c:	ac868693          	addi	a3,a3,-1336 # ffffffffc0205020 <etext+0x9de>
ffffffffc0201560:	00003617          	auipc	a2,0x3
ffffffffc0201564:	4f060613          	addi	a2,a2,1264 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201568:	07000593          	li	a1,112
ffffffffc020156c:	00004517          	auipc	a0,0x4
ffffffffc0201570:	9b450513          	addi	a0,a0,-1612 # ffffffffc0204f20 <etext+0x8de>
ffffffffc0201574:	bc5fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgfault_num == 7);
ffffffffc0201578:	00004697          	auipc	a3,0x4
ffffffffc020157c:	a9068693          	addi	a3,a3,-1392 # ffffffffc0205008 <etext+0x9c6>
ffffffffc0201580:	00003617          	auipc	a2,0x3
ffffffffc0201584:	4d060613          	addi	a2,a2,1232 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201588:	06d00593          	li	a1,109
ffffffffc020158c:	00004517          	auipc	a0,0x4
ffffffffc0201590:	99450513          	addi	a0,a0,-1644 # ffffffffc0204f20 <etext+0x8de>
ffffffffc0201594:	ba5fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgfault_num == 6);
ffffffffc0201598:	00004697          	auipc	a3,0x4
ffffffffc020159c:	a5868693          	addi	a3,a3,-1448 # ffffffffc0204ff0 <etext+0x9ae>
ffffffffc02015a0:	00003617          	auipc	a2,0x3
ffffffffc02015a4:	4b060613          	addi	a2,a2,1200 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02015a8:	06a00593          	li	a1,106
ffffffffc02015ac:	00004517          	auipc	a0,0x4
ffffffffc02015b0:	97450513          	addi	a0,a0,-1676 # ffffffffc0204f20 <etext+0x8de>
ffffffffc02015b4:	b85fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgfault_num == 5);
ffffffffc02015b8:	00004697          	auipc	a3,0x4
ffffffffc02015bc:	a2068693          	addi	a3,a3,-1504 # ffffffffc0204fd8 <etext+0x996>
ffffffffc02015c0:	00003617          	auipc	a2,0x3
ffffffffc02015c4:	49060613          	addi	a2,a2,1168 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02015c8:	06700593          	li	a1,103
ffffffffc02015cc:	00004517          	auipc	a0,0x4
ffffffffc02015d0:	95450513          	addi	a0,a0,-1708 # ffffffffc0204f20 <etext+0x8de>
ffffffffc02015d4:	b65fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgfault_num == 5);
ffffffffc02015d8:	00004697          	auipc	a3,0x4
ffffffffc02015dc:	a0068693          	addi	a3,a3,-1536 # ffffffffc0204fd8 <etext+0x996>
ffffffffc02015e0:	00003617          	auipc	a2,0x3
ffffffffc02015e4:	47060613          	addi	a2,a2,1136 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02015e8:	06400593          	li	a1,100
ffffffffc02015ec:	00004517          	auipc	a0,0x4
ffffffffc02015f0:	93450513          	addi	a0,a0,-1740 # ffffffffc0204f20 <etext+0x8de>
ffffffffc02015f4:	b45fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgfault_num == 4);
ffffffffc02015f8:	00004697          	auipc	a3,0x4
ffffffffc02015fc:	91068693          	addi	a3,a3,-1776 # ffffffffc0204f08 <etext+0x8c6>
ffffffffc0201600:	00003617          	auipc	a2,0x3
ffffffffc0201604:	45060613          	addi	a2,a2,1104 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201608:	06100593          	li	a1,97
ffffffffc020160c:	00004517          	auipc	a0,0x4
ffffffffc0201610:	91450513          	addi	a0,a0,-1772 # ffffffffc0204f20 <etext+0x8de>
ffffffffc0201614:	b25fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgfault_num == 4);
ffffffffc0201618:	00004697          	auipc	a3,0x4
ffffffffc020161c:	8f068693          	addi	a3,a3,-1808 # ffffffffc0204f08 <etext+0x8c6>
ffffffffc0201620:	00003617          	auipc	a2,0x3
ffffffffc0201624:	43060613          	addi	a2,a2,1072 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201628:	05e00593          	li	a1,94
ffffffffc020162c:	00004517          	auipc	a0,0x4
ffffffffc0201630:	8f450513          	addi	a0,a0,-1804 # ffffffffc0204f20 <etext+0x8de>
ffffffffc0201634:	b05fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgfault_num == 4);
ffffffffc0201638:	00004697          	auipc	a3,0x4
ffffffffc020163c:	8d068693          	addi	a3,a3,-1840 # ffffffffc0204f08 <etext+0x8c6>
ffffffffc0201640:	00003617          	auipc	a2,0x3
ffffffffc0201644:	41060613          	addi	a2,a2,1040 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201648:	05b00593          	li	a1,91
ffffffffc020164c:	00004517          	auipc	a0,0x4
ffffffffc0201650:	8d450513          	addi	a0,a0,-1836 # ffffffffc0204f20 <etext+0x8de>
ffffffffc0201654:	ae5fe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0201658 <_fifo_swap_out_victim>:
	list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc0201658:	751c                	ld	a5,40(a0)
{
ffffffffc020165a:	1141                	addi	sp,sp,-16
ffffffffc020165c:	e406                	sd	ra,8(sp)
	assert(head != NULL);
ffffffffc020165e:	cf91                	beqz	a5,ffffffffc020167a <_fifo_swap_out_victim+0x22>
	assert(in_tick == 0);
ffffffffc0201660:	ee0d                	bnez	a2,ffffffffc020169a <_fifo_swap_out_victim+0x42>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *list_next(list_entry_t *listelm)
{
	return listelm->next;
ffffffffc0201662:	679c                	ld	a5,8(a5)
}
ffffffffc0201664:	60a2                	ld	ra,8(sp)
ffffffffc0201666:	4501                	li	a0,0
	__list_del(listelm->prev, listelm->next);
ffffffffc0201668:	6394                	ld	a3,0(a5)
ffffffffc020166a:	6798                	ld	a4,8(a5)
	*ptr_page = le2page(entry, pra_page_link);
ffffffffc020166c:	fd878793          	addi	a5,a5,-40
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void __list_del(list_entry_t *prev, list_entry_t *next)
{
	prev->next = next;
ffffffffc0201670:	e698                	sd	a4,8(a3)
	next->prev = prev;
ffffffffc0201672:	e314                	sd	a3,0(a4)
ffffffffc0201674:	e19c                	sd	a5,0(a1)
}
ffffffffc0201676:	0141                	addi	sp,sp,16
ffffffffc0201678:	8082                	ret
	assert(head != NULL);
ffffffffc020167a:	00004697          	auipc	a3,0x4
ffffffffc020167e:	a2e68693          	addi	a3,a3,-1490 # ffffffffc02050a8 <etext+0xa66>
ffffffffc0201682:	00003617          	auipc	a2,0x3
ffffffffc0201686:	3ce60613          	addi	a2,a2,974 # ffffffffc0204a50 <etext+0x40e>
ffffffffc020168a:	04800593          	li	a1,72
ffffffffc020168e:	00004517          	auipc	a0,0x4
ffffffffc0201692:	89250513          	addi	a0,a0,-1902 # ffffffffc0204f20 <etext+0x8de>
ffffffffc0201696:	aa3fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(in_tick == 0);
ffffffffc020169a:	00004697          	auipc	a3,0x4
ffffffffc020169e:	a1e68693          	addi	a3,a3,-1506 # ffffffffc02050b8 <etext+0xa76>
ffffffffc02016a2:	00003617          	auipc	a2,0x3
ffffffffc02016a6:	3ae60613          	addi	a2,a2,942 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02016aa:	04900593          	li	a1,73
ffffffffc02016ae:	00004517          	auipc	a0,0x4
ffffffffc02016b2:	87250513          	addi	a0,a0,-1934 # ffffffffc0204f20 <etext+0x8de>
ffffffffc02016b6:	a83fe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc02016ba <_fifo_map_swappable>:
	list_entry_t *head = (list_entry_t *)mm->sm_priv;
ffffffffc02016ba:	751c                	ld	a5,40(a0)
	assert(entry != NULL && head != NULL);
ffffffffc02016bc:	cb91                	beqz	a5,ffffffffc02016d0 <_fifo_map_swappable+0x16>
	__list_add(elm, listelm->prev, listelm);
ffffffffc02016be:	6394                	ld	a3,0(a5)
ffffffffc02016c0:	02860713          	addi	a4,a2,40
	prev->next = next->prev = elm;
ffffffffc02016c4:	e398                	sd	a4,0(a5)
ffffffffc02016c6:	e698                	sd	a4,8(a3)
}
ffffffffc02016c8:	4501                	li	a0,0
	elm->next = next;
ffffffffc02016ca:	fa1c                	sd	a5,48(a2)
	elm->prev = prev;
ffffffffc02016cc:	f614                	sd	a3,40(a2)
ffffffffc02016ce:	8082                	ret
{
ffffffffc02016d0:	1141                	addi	sp,sp,-16
	assert(entry != NULL && head != NULL);
ffffffffc02016d2:	00004697          	auipc	a3,0x4
ffffffffc02016d6:	9f668693          	addi	a3,a3,-1546 # ffffffffc02050c8 <etext+0xa86>
ffffffffc02016da:	00003617          	auipc	a2,0x3
ffffffffc02016de:	37660613          	addi	a2,a2,886 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02016e2:	03700593          	li	a1,55
ffffffffc02016e6:	00004517          	auipc	a0,0x4
ffffffffc02016ea:	83a50513          	addi	a0,a0,-1990 # ffffffffc0204f20 <etext+0x8de>
{
ffffffffc02016ee:	e406                	sd	ra,8(sp)
	assert(entry != NULL && head != NULL);
ffffffffc02016f0:	a49fe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc02016f4 <check_vma_overlap.isra.0.part.0>:
	}
	return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void check_vma_overlap(struct vma_struct *prev,
ffffffffc02016f4:	1141                	addi	sp,sp,-16
				     struct vma_struct *next)
{
	assert(prev->vm_start < prev->vm_end);
	assert(prev->vm_end <= next->vm_start);
	assert(next->vm_start < next->vm_end);
ffffffffc02016f6:	00004697          	auipc	a3,0x4
ffffffffc02016fa:	a0a68693          	addi	a3,a3,-1526 # ffffffffc0205100 <etext+0xabe>
ffffffffc02016fe:	00003617          	auipc	a2,0x3
ffffffffc0201702:	35260613          	addi	a2,a2,850 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201706:	07400593          	li	a1,116
ffffffffc020170a:	00004517          	auipc	a0,0x4
ffffffffc020170e:	a1650513          	addi	a0,a0,-1514 # ffffffffc0205120 <etext+0xade>
static inline void check_vma_overlap(struct vma_struct *prev,
ffffffffc0201712:	e406                	sd	ra,8(sp)
	assert(next->vm_start < next->vm_end);
ffffffffc0201714:	a25fe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0201718 <mm_create>:
{
ffffffffc0201718:	1141                	addi	sp,sp,-16
	struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020171a:	03800513          	li	a0,56
{
ffffffffc020171e:	e022                	sd	s0,0(sp)
ffffffffc0201720:	e406                	sd	ra,8(sp)
	struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0201722:	6ee000ef          	jal	ra,ffffffffc0201e10 <kmalloc>
ffffffffc0201726:	842a                	mv	s0,a0
	if (mm != NULL) {
ffffffffc0201728:	c505                	beqz	a0,ffffffffc0201750 <mm_create+0x38>
	elm->prev = elm->next = elm;
ffffffffc020172a:	e408                	sd	a0,8(s0)
ffffffffc020172c:	e008                	sd	a0,0(s0)
		mm->mmap_cache = NULL;
ffffffffc020172e:	00053823          	sd	zero,16(a0)
		mm->pgdir = NULL;
ffffffffc0201732:	00053c23          	sd	zero,24(a0)
		mm->map_count = 0;
ffffffffc0201736:	02052023          	sw	zero,32(a0)
		if (swap_init_ok) {
ffffffffc020173a:	0001d797          	auipc	a5,0x1d
ffffffffc020173e:	09e7a783          	lw	a5,158(a5) # ffffffffc021e7d8 <swap_init_ok>
ffffffffc0201742:	ef81                	bnez	a5,ffffffffc020175a <mm_create+0x42>
			mm->sm_priv = NULL;
ffffffffc0201744:	02053423          	sd	zero,40(a0)
	return mm->mm_count;
}

static inline void set_mm_count(struct mm_struct *mm, int val)
{
	mm->mm_count = val;
ffffffffc0201748:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void lock_init(lock_t *lock)
{
	*lock = 0;
ffffffffc020174c:	02042a23          	sw	zero,52(s0)
}
ffffffffc0201750:	60a2                	ld	ra,8(sp)
ffffffffc0201752:	8522                	mv	a0,s0
ffffffffc0201754:	6402                	ld	s0,0(sp)
ffffffffc0201756:	0141                	addi	sp,sp,16
ffffffffc0201758:	8082                	ret
			swap_init_mm(mm);
ffffffffc020175a:	0e3000ef          	jal	ra,ffffffffc020203c <swap_init_mm>
ffffffffc020175e:	b7ed                	j	ffffffffc0201748 <mm_create+0x30>

ffffffffc0201760 <find_vma>:
{
ffffffffc0201760:	86aa                	mv	a3,a0
	if (mm != NULL) {
ffffffffc0201762:	c505                	beqz	a0,ffffffffc020178a <find_vma+0x2a>
		vma = mm->mmap_cache;
ffffffffc0201764:	6908                	ld	a0,16(a0)
		if (!(vma != NULL && vma->vm_start <= addr &&
ffffffffc0201766:	c501                	beqz	a0,ffffffffc020176e <find_vma+0xe>
ffffffffc0201768:	651c                	ld	a5,8(a0)
ffffffffc020176a:	02f5f263          	bgeu	a1,a5,ffffffffc020178e <find_vma+0x2e>
	return listelm->next;
ffffffffc020176e:	669c                	ld	a5,8(a3)
			while ((le = list_next(le)) != list) {
ffffffffc0201770:	00f68d63          	beq	a3,a5,ffffffffc020178a <find_vma+0x2a>
				if (vma->vm_start <= addr &&
ffffffffc0201774:	fe87b703          	ld	a4,-24(a5)
ffffffffc0201778:	00e5e663          	bltu	a1,a4,ffffffffc0201784 <find_vma+0x24>
ffffffffc020177c:	ff07b703          	ld	a4,-16(a5)
ffffffffc0201780:	00e5ec63          	bltu	a1,a4,ffffffffc0201798 <find_vma+0x38>
ffffffffc0201784:	679c                	ld	a5,8(a5)
			while ((le = list_next(le)) != list) {
ffffffffc0201786:	fef697e3          	bne	a3,a5,ffffffffc0201774 <find_vma+0x14>
	struct vma_struct *vma = NULL;
ffffffffc020178a:	4501                	li	a0,0
}
ffffffffc020178c:	8082                	ret
		if (!(vma != NULL && vma->vm_start <= addr &&
ffffffffc020178e:	691c                	ld	a5,16(a0)
ffffffffc0201790:	fcf5ffe3          	bgeu	a1,a5,ffffffffc020176e <find_vma+0xe>
			mm->mmap_cache = vma;
ffffffffc0201794:	ea88                	sd	a0,16(a3)
ffffffffc0201796:	8082                	ret
				vma = le2vma(le, list_link);
ffffffffc0201798:	fe078513          	addi	a0,a5,-32
			mm->mmap_cache = vma;
ffffffffc020179c:	ea88                	sd	a0,16(a3)
ffffffffc020179e:	8082                	ret

ffffffffc02017a0 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
	assert(vma->vm_start < vma->vm_end);
ffffffffc02017a0:	6590                	ld	a2,8(a1)
ffffffffc02017a2:	0105b803          	ld	a6,16(a1)
{
ffffffffc02017a6:	1141                	addi	sp,sp,-16
ffffffffc02017a8:	e406                	sd	ra,8(sp)
ffffffffc02017aa:	87aa                	mv	a5,a0
	assert(vma->vm_start < vma->vm_end);
ffffffffc02017ac:	01066763          	bltu	a2,a6,ffffffffc02017ba <insert_vma_struct+0x1a>
ffffffffc02017b0:	a085                	j	ffffffffc0201810 <insert_vma_struct+0x70>
	list_entry_t *le_prev = list, *le_next;

	list_entry_t *le = list;
	while ((le = list_next(le)) != list) {
		struct vma_struct *mmap_prev = le2vma(le, list_link);
		if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02017b2:	fe87b703          	ld	a4,-24(a5)
ffffffffc02017b6:	04e66863          	bltu	a2,a4,ffffffffc0201806 <insert_vma_struct+0x66>
ffffffffc02017ba:	86be                	mv	a3,a5
ffffffffc02017bc:	679c                	ld	a5,8(a5)
	while ((le = list_next(le)) != list) {
ffffffffc02017be:	fef51ae3          	bne	a0,a5,ffffffffc02017b2 <insert_vma_struct+0x12>
	}

	le_next = list_next(le_prev);

	/* check overlap */
	if (le_prev != list) {
ffffffffc02017c2:	02a68463          	beq	a3,a0,ffffffffc02017ea <insert_vma_struct+0x4a>
		check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02017c6:	ff06b703          	ld	a4,-16(a3)
	assert(prev->vm_start < prev->vm_end);
ffffffffc02017ca:	fe86b883          	ld	a7,-24(a3)
ffffffffc02017ce:	08e8f163          	bgeu	a7,a4,ffffffffc0201850 <insert_vma_struct+0xb0>
	assert(prev->vm_end <= next->vm_start);
ffffffffc02017d2:	04e66f63          	bltu	a2,a4,ffffffffc0201830 <insert_vma_struct+0x90>
	}
	if (le_next != list) {
ffffffffc02017d6:	00f50a63          	beq	a0,a5,ffffffffc02017ea <insert_vma_struct+0x4a>
ffffffffc02017da:	fe87b703          	ld	a4,-24(a5)
	assert(prev->vm_end <= next->vm_start);
ffffffffc02017de:	05076963          	bltu	a4,a6,ffffffffc0201830 <insert_vma_struct+0x90>
	assert(next->vm_start < next->vm_end);
ffffffffc02017e2:	ff07b603          	ld	a2,-16(a5)
ffffffffc02017e6:	02c77363          	bgeu	a4,a2,ffffffffc020180c <insert_vma_struct+0x6c>
	}

	vma->vm_mm = mm;
	list_add_after(le_prev, &(vma->list_link));

	mm->map_count++;
ffffffffc02017ea:	5118                	lw	a4,32(a0)
	vma->vm_mm = mm;
ffffffffc02017ec:	e188                	sd	a0,0(a1)
	list_add_after(le_prev, &(vma->list_link));
ffffffffc02017ee:	02058613          	addi	a2,a1,32
	prev->next = next->prev = elm;
ffffffffc02017f2:	e390                	sd	a2,0(a5)
ffffffffc02017f4:	e690                	sd	a2,8(a3)
}
ffffffffc02017f6:	60a2                	ld	ra,8(sp)
	elm->next = next;
ffffffffc02017f8:	f59c                	sd	a5,40(a1)
	elm->prev = prev;
ffffffffc02017fa:	f194                	sd	a3,32(a1)
	mm->map_count++;
ffffffffc02017fc:	0017079b          	addiw	a5,a4,1
ffffffffc0201800:	d11c                	sw	a5,32(a0)
}
ffffffffc0201802:	0141                	addi	sp,sp,16
ffffffffc0201804:	8082                	ret
	if (le_prev != list) {
ffffffffc0201806:	fca690e3          	bne	a3,a0,ffffffffc02017c6 <insert_vma_struct+0x26>
ffffffffc020180a:	bfd1                	j	ffffffffc02017de <insert_vma_struct+0x3e>
ffffffffc020180c:	ee9ff0ef          	jal	ra,ffffffffc02016f4 <check_vma_overlap.isra.0.part.0>
	assert(vma->vm_start < vma->vm_end);
ffffffffc0201810:	00004697          	auipc	a3,0x4
ffffffffc0201814:	92068693          	addi	a3,a3,-1760 # ffffffffc0205130 <etext+0xaee>
ffffffffc0201818:	00003617          	auipc	a2,0x3
ffffffffc020181c:	23860613          	addi	a2,a2,568 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201820:	07a00593          	li	a1,122
ffffffffc0201824:	00004517          	auipc	a0,0x4
ffffffffc0201828:	8fc50513          	addi	a0,a0,-1796 # ffffffffc0205120 <etext+0xade>
ffffffffc020182c:	90dfe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(prev->vm_end <= next->vm_start);
ffffffffc0201830:	00004697          	auipc	a3,0x4
ffffffffc0201834:	94068693          	addi	a3,a3,-1728 # ffffffffc0205170 <etext+0xb2e>
ffffffffc0201838:	00003617          	auipc	a2,0x3
ffffffffc020183c:	21860613          	addi	a2,a2,536 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201840:	07300593          	li	a1,115
ffffffffc0201844:	00004517          	auipc	a0,0x4
ffffffffc0201848:	8dc50513          	addi	a0,a0,-1828 # ffffffffc0205120 <etext+0xade>
ffffffffc020184c:	8edfe0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(prev->vm_start < prev->vm_end);
ffffffffc0201850:	00004697          	auipc	a3,0x4
ffffffffc0201854:	90068693          	addi	a3,a3,-1792 # ffffffffc0205150 <etext+0xb0e>
ffffffffc0201858:	00003617          	auipc	a2,0x3
ffffffffc020185c:	1f860613          	addi	a2,a2,504 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201860:	07200593          	li	a1,114
ffffffffc0201864:	00004517          	auipc	a0,0x4
ffffffffc0201868:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0205120 <etext+0xade>
ffffffffc020186c:	8cdfe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0201870 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
	assert(mm_count(mm) == 0);
ffffffffc0201870:	591c                	lw	a5,48(a0)
{
ffffffffc0201872:	1141                	addi	sp,sp,-16
ffffffffc0201874:	e406                	sd	ra,8(sp)
ffffffffc0201876:	e022                	sd	s0,0(sp)
	assert(mm_count(mm) == 0);
ffffffffc0201878:	e785                	bnez	a5,ffffffffc02018a0 <mm_destroy+0x30>
ffffffffc020187a:	842a                	mv	s0,a0
	return listelm->next;
ffffffffc020187c:	6508                	ld	a0,8(a0)

	list_entry_t *list = &(mm->mmap_list), *le;
	while ((le = list_next(list)) != list) {
ffffffffc020187e:	00a40c63          	beq	s0,a0,ffffffffc0201896 <mm_destroy+0x26>
	__list_del(listelm->prev, listelm->next);
ffffffffc0201882:	6118                	ld	a4,0(a0)
ffffffffc0201884:	651c                	ld	a5,8(a0)
		list_del(le);
		kfree(le2vma(le, list_link)); // kfree vma
ffffffffc0201886:	1501                	addi	a0,a0,-32
	prev->next = next;
ffffffffc0201888:	e71c                	sd	a5,8(a4)
	next->prev = prev;
ffffffffc020188a:	e398                	sd	a4,0(a5)
ffffffffc020188c:	634000ef          	jal	ra,ffffffffc0201ec0 <kfree>
	return listelm->next;
ffffffffc0201890:	6408                	ld	a0,8(s0)
	while ((le = list_next(list)) != list) {
ffffffffc0201892:	fea418e3          	bne	s0,a0,ffffffffc0201882 <mm_destroy+0x12>
	}
	kfree(mm); // kfree mm
ffffffffc0201896:	8522                	mv	a0,s0
	mm = NULL;
}
ffffffffc0201898:	6402                	ld	s0,0(sp)
ffffffffc020189a:	60a2                	ld	ra,8(sp)
ffffffffc020189c:	0141                	addi	sp,sp,16
	kfree(mm); // kfree mm
ffffffffc020189e:	a50d                	j	ffffffffc0201ec0 <kfree>
	assert(mm_count(mm) == 0);
ffffffffc02018a0:	00004697          	auipc	a3,0x4
ffffffffc02018a4:	8f068693          	addi	a3,a3,-1808 # ffffffffc0205190 <etext+0xb4e>
ffffffffc02018a8:	00003617          	auipc	a2,0x3
ffffffffc02018ac:	1a860613          	addi	a2,a2,424 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02018b0:	09a00593          	li	a1,154
ffffffffc02018b4:	00004517          	auipc	a0,0x4
ffffffffc02018b8:	86c50513          	addi	a0,a0,-1940 # ffffffffc0205120 <etext+0xade>
ffffffffc02018bc:	87dfe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc02018c0 <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
	   struct vma_struct **vma_store)
{
ffffffffc02018c0:	7139                	addi	sp,sp,-64
ffffffffc02018c2:	f822                	sd	s0,48(sp)
	uintptr_t start = ROUNDDOWN(addr, PGSIZE),
		  end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02018c4:	6405                	lui	s0,0x1
ffffffffc02018c6:	147d                	addi	s0,s0,-1
	uintptr_t start = ROUNDDOWN(addr, PGSIZE),
ffffffffc02018c8:	77fd                	lui	a5,0xfffff
		  end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02018ca:	9622                	add	a2,a2,s0
ffffffffc02018cc:	962e                	add	a2,a2,a1
{
ffffffffc02018ce:	f426                	sd	s1,40(sp)
ffffffffc02018d0:	fc06                	sd	ra,56(sp)
	uintptr_t start = ROUNDDOWN(addr, PGSIZE),
ffffffffc02018d2:	00f5f4b3          	and	s1,a1,a5
{
ffffffffc02018d6:	f04a                	sd	s2,32(sp)
ffffffffc02018d8:	ec4e                	sd	s3,24(sp)
ffffffffc02018da:	e852                	sd	s4,16(sp)
ffffffffc02018dc:	e456                	sd	s5,8(sp)
	if (!USER_ACCESS(start, end)) {
ffffffffc02018de:	002005b7          	lui	a1,0x200
ffffffffc02018e2:	00f67433          	and	s0,a2,a5
ffffffffc02018e6:	06b4e363          	bltu	s1,a1,ffffffffc020194c <mm_map+0x8c>
ffffffffc02018ea:	0684f163          	bgeu	s1,s0,ffffffffc020194c <mm_map+0x8c>
ffffffffc02018ee:	4785                	li	a5,1
ffffffffc02018f0:	07fe                	slli	a5,a5,0x1f
ffffffffc02018f2:	0487ed63          	bltu	a5,s0,ffffffffc020194c <mm_map+0x8c>
ffffffffc02018f6:	89aa                	mv	s3,a0
		return -E_INVAL;
	}

	assert(mm != NULL);
ffffffffc02018f8:	cd21                	beqz	a0,ffffffffc0201950 <mm_map+0x90>

	int ret = -E_INVAL;

	struct vma_struct *vma;
	if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02018fa:	85a6                	mv	a1,s1
ffffffffc02018fc:	8ab6                	mv	s5,a3
ffffffffc02018fe:	8a3a                	mv	s4,a4
ffffffffc0201900:	e61ff0ef          	jal	ra,ffffffffc0201760 <find_vma>
ffffffffc0201904:	c501                	beqz	a0,ffffffffc020190c <mm_map+0x4c>
ffffffffc0201906:	651c                	ld	a5,8(a0)
ffffffffc0201908:	0487e263          	bltu	a5,s0,ffffffffc020194c <mm_map+0x8c>
	struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020190c:	03000513          	li	a0,48
ffffffffc0201910:	500000ef          	jal	ra,ffffffffc0201e10 <kmalloc>
ffffffffc0201914:	892a                	mv	s2,a0
		goto out;
	}
	ret = -E_NO_MEM;
ffffffffc0201916:	5571                	li	a0,-4
	if (vma != NULL) {
ffffffffc0201918:	02090163          	beqz	s2,ffffffffc020193a <mm_map+0x7a>

	if ((vma = vma_create(start, end, vm_flags)) == NULL) {
		goto out;
	}
	insert_vma_struct(mm, vma);
ffffffffc020191c:	854e                	mv	a0,s3
		vma->vm_start = vm_start;
ffffffffc020191e:	00993423          	sd	s1,8(s2)
		vma->vm_end = vm_end;
ffffffffc0201922:	00893823          	sd	s0,16(s2)
		vma->vm_flags = vm_flags;
ffffffffc0201926:	01592c23          	sw	s5,24(s2)
	insert_vma_struct(mm, vma);
ffffffffc020192a:	85ca                	mv	a1,s2
ffffffffc020192c:	e75ff0ef          	jal	ra,ffffffffc02017a0 <insert_vma_struct>
	if (vma_store != NULL) {
		*vma_store = vma;
	}
	ret = 0;
ffffffffc0201930:	4501                	li	a0,0
	if (vma_store != NULL) {
ffffffffc0201932:	000a0463          	beqz	s4,ffffffffc020193a <mm_map+0x7a>
		*vma_store = vma;
ffffffffc0201936:	012a3023          	sd	s2,0(s4) # 1000 <_binary_obj___user_hello_out_size-0x8740>

out:
	return ret;
}
ffffffffc020193a:	70e2                	ld	ra,56(sp)
ffffffffc020193c:	7442                	ld	s0,48(sp)
ffffffffc020193e:	74a2                	ld	s1,40(sp)
ffffffffc0201940:	7902                	ld	s2,32(sp)
ffffffffc0201942:	69e2                	ld	s3,24(sp)
ffffffffc0201944:	6a42                	ld	s4,16(sp)
ffffffffc0201946:	6aa2                	ld	s5,8(sp)
ffffffffc0201948:	6121                	addi	sp,sp,64
ffffffffc020194a:	8082                	ret
		return -E_INVAL;
ffffffffc020194c:	5575                	li	a0,-3
ffffffffc020194e:	b7f5                	j	ffffffffc020193a <mm_map+0x7a>
	assert(mm != NULL);
ffffffffc0201950:	00004697          	auipc	a3,0x4
ffffffffc0201954:	85868693          	addi	a3,a3,-1960 # ffffffffc02051a8 <etext+0xb66>
ffffffffc0201958:	00003617          	auipc	a2,0x3
ffffffffc020195c:	0f860613          	addi	a2,a2,248 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201960:	0ae00593          	li	a1,174
ffffffffc0201964:	00003517          	auipc	a0,0x3
ffffffffc0201968:	7bc50513          	addi	a0,a0,1980 # ffffffffc0205120 <etext+0xade>
ffffffffc020196c:	fccfe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0201970 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0201970:	7139                	addi	sp,sp,-64
ffffffffc0201972:	fc06                	sd	ra,56(sp)
ffffffffc0201974:	f822                	sd	s0,48(sp)
ffffffffc0201976:	f426                	sd	s1,40(sp)
ffffffffc0201978:	f04a                	sd	s2,32(sp)
ffffffffc020197a:	ec4e                	sd	s3,24(sp)
ffffffffc020197c:	e852                	sd	s4,16(sp)
ffffffffc020197e:	e456                	sd	s5,8(sp)
	assert(to != NULL && from != NULL);
ffffffffc0201980:	c52d                	beqz	a0,ffffffffc02019ea <dup_mmap+0x7a>
ffffffffc0201982:	892a                	mv	s2,a0
ffffffffc0201984:	84ae                	mv	s1,a1
	list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0201986:	842e                	mv	s0,a1
	assert(to != NULL && from != NULL);
ffffffffc0201988:	e595                	bnez	a1,ffffffffc02019b4 <dup_mmap+0x44>
ffffffffc020198a:	a085                	j	ffffffffc02019ea <dup_mmap+0x7a>
		nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
		if (nvma == NULL) {
			return -E_NO_MEM;
		}

		insert_vma_struct(to, nvma);
ffffffffc020198c:	854a                	mv	a0,s2
		vma->vm_start = vm_start;
ffffffffc020198e:	0155b423          	sd	s5,8(a1) # 200008 <_binary_obj___user_hello_out_size+0x1f68c8>
		vma->vm_end = vm_end;
ffffffffc0201992:	0145b823          	sd	s4,16(a1)
		vma->vm_flags = vm_flags;
ffffffffc0201996:	0135ac23          	sw	s3,24(a1)
		insert_vma_struct(to, nvma);
ffffffffc020199a:	e07ff0ef          	jal	ra,ffffffffc02017a0 <insert_vma_struct>

		bool share = 0;
		if (copy_range(to->pgdir, from->pgdir, vma->vm_start,
ffffffffc020199e:	ff043683          	ld	a3,-16(s0) # ff0 <_binary_obj___user_hello_out_size-0x8750>
ffffffffc02019a2:	fe843603          	ld	a2,-24(s0)
ffffffffc02019a6:	6c8c                	ld	a1,24(s1)
ffffffffc02019a8:	01893503          	ld	a0,24(s2)
ffffffffc02019ac:	4701                	li	a4,0
ffffffffc02019ae:	e94ff0ef          	jal	ra,ffffffffc0201042 <copy_range>
ffffffffc02019b2:	e105                	bnez	a0,ffffffffc02019d2 <dup_mmap+0x62>
	return listelm->prev;
ffffffffc02019b4:	6000                	ld	s0,0(s0)
	while ((le = list_prev(le)) != list) {
ffffffffc02019b6:	02848863          	beq	s1,s0,ffffffffc02019e6 <dup_mmap+0x76>
	struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02019ba:	03000513          	li	a0,48
		nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02019be:	fe843a83          	ld	s5,-24(s0)
ffffffffc02019c2:	ff043a03          	ld	s4,-16(s0)
ffffffffc02019c6:	ff842983          	lw	s3,-8(s0)
	struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02019ca:	446000ef          	jal	ra,ffffffffc0201e10 <kmalloc>
ffffffffc02019ce:	85aa                	mv	a1,a0
	if (vma != NULL) {
ffffffffc02019d0:	fd55                	bnez	a0,ffffffffc020198c <dup_mmap+0x1c>
			return -E_NO_MEM;
ffffffffc02019d2:	5571                	li	a0,-4
			       vma->vm_end, share) != 0) {
			return -E_NO_MEM;
		}
	}
	return 0;
}
ffffffffc02019d4:	70e2                	ld	ra,56(sp)
ffffffffc02019d6:	7442                	ld	s0,48(sp)
ffffffffc02019d8:	74a2                	ld	s1,40(sp)
ffffffffc02019da:	7902                	ld	s2,32(sp)
ffffffffc02019dc:	69e2                	ld	s3,24(sp)
ffffffffc02019de:	6a42                	ld	s4,16(sp)
ffffffffc02019e0:	6aa2                	ld	s5,8(sp)
ffffffffc02019e2:	6121                	addi	sp,sp,64
ffffffffc02019e4:	8082                	ret
	return 0;
ffffffffc02019e6:	4501                	li	a0,0
ffffffffc02019e8:	b7f5                	j	ffffffffc02019d4 <dup_mmap+0x64>
	assert(to != NULL && from != NULL);
ffffffffc02019ea:	00003697          	auipc	a3,0x3
ffffffffc02019ee:	7ce68693          	addi	a3,a3,1998 # ffffffffc02051b8 <etext+0xb76>
ffffffffc02019f2:	00003617          	auipc	a2,0x3
ffffffffc02019f6:	05e60613          	addi	a2,a2,94 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02019fa:	0c700593          	li	a1,199
ffffffffc02019fe:	00003517          	auipc	a0,0x3
ffffffffc0201a02:	72250513          	addi	a0,a0,1826 # ffffffffc0205120 <etext+0xade>
ffffffffc0201a06:	f32fe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0201a0a <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc0201a0a:	1101                	addi	sp,sp,-32
ffffffffc0201a0c:	ec06                	sd	ra,24(sp)
ffffffffc0201a0e:	e822                	sd	s0,16(sp)
ffffffffc0201a10:	e426                	sd	s1,8(sp)
ffffffffc0201a12:	e04a                	sd	s2,0(sp)
	assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0201a14:	c531                	beqz	a0,ffffffffc0201a60 <exit_mmap+0x56>
ffffffffc0201a16:	591c                	lw	a5,48(a0)
ffffffffc0201a18:	84aa                	mv	s1,a0
ffffffffc0201a1a:	e3b9                	bnez	a5,ffffffffc0201a60 <exit_mmap+0x56>
	return listelm->next;
ffffffffc0201a1c:	6500                	ld	s0,8(a0)
	pde_t *pgdir = mm->pgdir;
ffffffffc0201a1e:	01853903          	ld	s2,24(a0)
	list_entry_t *list = &(mm->mmap_list), *le = list;
	while ((le = list_next(le)) != list) {
ffffffffc0201a22:	02850663          	beq	a0,s0,ffffffffc0201a4e <exit_mmap+0x44>
		struct vma_struct *vma = le2vma(le, list_link);
		unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0201a26:	ff043603          	ld	a2,-16(s0)
ffffffffc0201a2a:	fe843583          	ld	a1,-24(s0)
ffffffffc0201a2e:	854a                	mv	a0,s2
ffffffffc0201a30:	b42ff0ef          	jal	ra,ffffffffc0200d72 <unmap_range>
ffffffffc0201a34:	6400                	ld	s0,8(s0)
	while ((le = list_next(le)) != list) {
ffffffffc0201a36:	fe8498e3          	bne	s1,s0,ffffffffc0201a26 <exit_mmap+0x1c>
ffffffffc0201a3a:	6400                	ld	s0,8(s0)
	}
	while ((le = list_next(le)) != list) {
ffffffffc0201a3c:	00848c63          	beq	s1,s0,ffffffffc0201a54 <exit_mmap+0x4a>
		struct vma_struct *vma = le2vma(le, list_link);
		exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0201a40:	ff043603          	ld	a2,-16(s0)
ffffffffc0201a44:	fe843583          	ld	a1,-24(s0)
ffffffffc0201a48:	854a                	mv	a0,s2
ffffffffc0201a4a:	c3eff0ef          	jal	ra,ffffffffc0200e88 <exit_range>
ffffffffc0201a4e:	6400                	ld	s0,8(s0)
	while ((le = list_next(le)) != list) {
ffffffffc0201a50:	fe8498e3          	bne	s1,s0,ffffffffc0201a40 <exit_mmap+0x36>
	}
}
ffffffffc0201a54:	60e2                	ld	ra,24(sp)
ffffffffc0201a56:	6442                	ld	s0,16(sp)
ffffffffc0201a58:	64a2                	ld	s1,8(sp)
ffffffffc0201a5a:	6902                	ld	s2,0(sp)
ffffffffc0201a5c:	6105                	addi	sp,sp,32
ffffffffc0201a5e:	8082                	ret
	assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0201a60:	00003697          	auipc	a3,0x3
ffffffffc0201a64:	77868693          	addi	a3,a3,1912 # ffffffffc02051d8 <etext+0xb96>
ffffffffc0201a68:	00003617          	auipc	a2,0x3
ffffffffc0201a6c:	fe860613          	addi	a2,a2,-24 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201a70:	0de00593          	li	a1,222
ffffffffc0201a74:	00003517          	auipc	a0,0x3
ffffffffc0201a78:	6ac50513          	addi	a0,a0,1708 # ffffffffc0205120 <etext+0xade>
ffffffffc0201a7c:	ebcfe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0201a80 <vmm_init>:
// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
	// check_vmm();
}
ffffffffc0201a80:	8082                	ret

ffffffffc0201a82 <do_pgfault>:
 * caused the exception was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing
 * at user mode (1) or supervisor mode (0) at the time of the exception.
 */
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)
{
ffffffffc0201a82:	7139                	addi	sp,sp,-64
	int ret = -E_INVAL;
	// try to find a vma which include addr
	struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201a84:	85b2                	mv	a1,a2
{
ffffffffc0201a86:	f822                	sd	s0,48(sp)
ffffffffc0201a88:	f426                	sd	s1,40(sp)
ffffffffc0201a8a:	fc06                	sd	ra,56(sp)
ffffffffc0201a8c:	f04a                	sd	s2,32(sp)
ffffffffc0201a8e:	ec4e                	sd	s3,24(sp)
ffffffffc0201a90:	8432                	mv	s0,a2
ffffffffc0201a92:	84aa                	mv	s1,a0
	struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0201a94:	ccdff0ef          	jal	ra,ffffffffc0201760 <find_vma>

	pgfault_num++;
ffffffffc0201a98:	0001d797          	auipc	a5,0x1d
ffffffffc0201a9c:	d287a783          	lw	a5,-728(a5) # ffffffffc021e7c0 <pgfault_num>
ffffffffc0201aa0:	2785                	addiw	a5,a5,1
ffffffffc0201aa2:	0001d717          	auipc	a4,0x1d
ffffffffc0201aa6:	d0f72f23          	sw	a5,-738(a4) # ffffffffc021e7c0 <pgfault_num>
	// If the addr is in the range of a mm's vma?
	if (vma == NULL || vma->vm_start > addr) {
ffffffffc0201aaa:	c545                	beqz	a0,ffffffffc0201b52 <do_pgfault+0xd0>
ffffffffc0201aac:	651c                	ld	a5,8(a0)
ffffffffc0201aae:	0af46263          	bltu	s0,a5,ffffffffc0201b52 <do_pgfault+0xd0>
   *    (read  an non_existed addr && addr is readable)
   * THEN
   *    continue process
   */
	uint32_t perm = PTE_U;
	if (vma->vm_flags & VM_WRITE) {
ffffffffc0201ab2:	4d1c                	lw	a5,24(a0)
	uint32_t perm = PTE_U;
ffffffffc0201ab4:	49c1                	li	s3,16
	if (vma->vm_flags & VM_WRITE) {
ffffffffc0201ab6:	8b89                	andi	a5,a5,2
ffffffffc0201ab8:	efb1                	bnez	a5,ffffffffc0201b14 <do_pgfault+0x92>
		perm |= READ_WRITE;
	}
	addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201aba:	75fd                	lui	a1,0xfffff
   * the PDT of these vma
   *
   */
	// try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
	// (notice the 3th parameter '1')
	if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201abc:	6c88                	ld	a0,24(s1)
	addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0201abe:	8c6d                	and	s0,s0,a1
	if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0201ac0:	4605                	li	a2,1
ffffffffc0201ac2:	85a2                	mv	a1,s0
ffffffffc0201ac4:	8dcff0ef          	jal	ra,ffffffffc0200ba0 <get_pte>
ffffffffc0201ac8:	c555                	beqz	a0,ffffffffc0201b74 <do_pgfault+0xf2>
		cprintf("get_pte in do_pgfault failed\n");
		goto failed;
	}

	if (*ptep ==
ffffffffc0201aca:	610c                	ld	a1,0(a0)
ffffffffc0201acc:	c5a5                	beqz	a1,ffffffffc0201b34 <do_pgfault+0xb2>
			goto failed;
		}
	} else { // if this pte is a swap entry, then load data from disk to a page
		// with phy addr and call page_insert to map the phy addr with
		// logical addr
		if (swap_init_ok) {
ffffffffc0201ace:	0001d797          	auipc	a5,0x1d
ffffffffc0201ad2:	d0a7a783          	lw	a5,-758(a5) # ffffffffc021e7d8 <swap_init_ok>
ffffffffc0201ad6:	c7d9                	beqz	a5,ffffffffc0201b64 <do_pgfault+0xe2>
			struct Page *page = NULL;
			if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0201ad8:	0030                	addi	a2,sp,8
ffffffffc0201ada:	85a2                	mv	a1,s0
ffffffffc0201adc:	8526                	mv	a0,s1
			struct Page *page = NULL;
ffffffffc0201ade:	e402                	sd	zero,8(sp)
			if ((ret = swap_in(mm, addr, &page)) != 0) {
ffffffffc0201ae0:	68c000ef          	jal	ra,ffffffffc020216c <swap_in>
ffffffffc0201ae4:	892a                	mv	s2,a0
ffffffffc0201ae6:	e90d                	bnez	a0,ffffffffc0201b18 <do_pgfault+0x96>
				cprintf("swap_in in do_pgfault failed\n");
				goto failed;
			}
			page_insert(mm->pgdir, page, addr, perm);
ffffffffc0201ae8:	65a2                	ld	a1,8(sp)
ffffffffc0201aea:	6c88                	ld	a0,24(s1)
ffffffffc0201aec:	86ce                	mv	a3,s3
ffffffffc0201aee:	8622                	mv	a2,s0
ffffffffc0201af0:	c96ff0ef          	jal	ra,ffffffffc0200f86 <page_insert>
			swap_map_swappable(mm, addr, page, 1);
ffffffffc0201af4:	6622                	ld	a2,8(sp)
ffffffffc0201af6:	4685                	li	a3,1
ffffffffc0201af8:	85a2                	mv	a1,s0
ffffffffc0201afa:	8526                	mv	a0,s1
ffffffffc0201afc:	54e000ef          	jal	ra,ffffffffc020204a <swap_map_swappable>
			page->pra_vaddr = addr;
ffffffffc0201b00:	67a2                	ld	a5,8(sp)
ffffffffc0201b02:	ff80                	sd	s0,56(a5)
		}
	}
	ret = 0;
failed:
	return ret;
}
ffffffffc0201b04:	70e2                	ld	ra,56(sp)
ffffffffc0201b06:	7442                	ld	s0,48(sp)
ffffffffc0201b08:	74a2                	ld	s1,40(sp)
ffffffffc0201b0a:	69e2                	ld	s3,24(sp)
ffffffffc0201b0c:	854a                	mv	a0,s2
ffffffffc0201b0e:	7902                	ld	s2,32(sp)
ffffffffc0201b10:	6121                	addi	sp,sp,64
ffffffffc0201b12:	8082                	ret
		perm |= READ_WRITE;
ffffffffc0201b14:	49dd                	li	s3,23
ffffffffc0201b16:	b755                	j	ffffffffc0201aba <do_pgfault+0x38>
				cprintf("swap_in in do_pgfault failed\n");
ffffffffc0201b18:	00003517          	auipc	a0,0x3
ffffffffc0201b1c:	75850513          	addi	a0,a0,1880 # ffffffffc0205270 <etext+0xc2e>
ffffffffc0201b20:	da0fe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
}
ffffffffc0201b24:	70e2                	ld	ra,56(sp)
ffffffffc0201b26:	7442                	ld	s0,48(sp)
ffffffffc0201b28:	74a2                	ld	s1,40(sp)
ffffffffc0201b2a:	69e2                	ld	s3,24(sp)
ffffffffc0201b2c:	854a                	mv	a0,s2
ffffffffc0201b2e:	7902                	ld	s2,32(sp)
ffffffffc0201b30:	6121                	addi	sp,sp,64
ffffffffc0201b32:	8082                	ret
		if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201b34:	6c88                	ld	a0,24(s1)
ffffffffc0201b36:	864e                	mv	a2,s3
ffffffffc0201b38:	85a2                	mv	a1,s0
ffffffffc0201b3a:	f3eff0ef          	jal	ra,ffffffffc0201278 <pgdir_alloc_page>
	ret = 0;
ffffffffc0201b3e:	4901                	li	s2,0
		if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0201b40:	f171                	bnez	a0,ffffffffc0201b04 <do_pgfault+0x82>
			cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0201b42:	00003517          	auipc	a0,0x3
ffffffffc0201b46:	70650513          	addi	a0,a0,1798 # ffffffffc0205248 <etext+0xc06>
ffffffffc0201b4a:	d76fe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	ret = -E_NO_MEM;
ffffffffc0201b4e:	5971                	li	s2,-4
			goto failed;
ffffffffc0201b50:	bf55                	j	ffffffffc0201b04 <do_pgfault+0x82>
		cprintf("not valid addr %x, and  can not find it in vma\n",
ffffffffc0201b52:	85a2                	mv	a1,s0
ffffffffc0201b54:	00003517          	auipc	a0,0x3
ffffffffc0201b58:	6a450513          	addi	a0,a0,1700 # ffffffffc02051f8 <etext+0xbb6>
ffffffffc0201b5c:	d64fe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	int ret = -E_INVAL;
ffffffffc0201b60:	5975                	li	s2,-3
		goto failed;
ffffffffc0201b62:	b74d                	j	ffffffffc0201b04 <do_pgfault+0x82>
			cprintf("no swap_init_ok but ptep is %x, failed\n",
ffffffffc0201b64:	00003517          	auipc	a0,0x3
ffffffffc0201b68:	72c50513          	addi	a0,a0,1836 # ffffffffc0205290 <etext+0xc4e>
ffffffffc0201b6c:	d54fe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	ret = -E_NO_MEM;
ffffffffc0201b70:	5971                	li	s2,-4
			goto failed;
ffffffffc0201b72:	bf49                	j	ffffffffc0201b04 <do_pgfault+0x82>
		cprintf("get_pte in do_pgfault failed\n");
ffffffffc0201b74:	00003517          	auipc	a0,0x3
ffffffffc0201b78:	6b450513          	addi	a0,a0,1716 # ffffffffc0205228 <etext+0xbe6>
ffffffffc0201b7c:	d44fe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	ret = -E_NO_MEM;
ffffffffc0201b80:	5971                	li	s2,-4
		goto failed;
ffffffffc0201b82:	b749                	j	ffffffffc0201b04 <do_pgfault+0x82>

ffffffffc0201b84 <user_mem_check>:

bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len,
		    bool write)
{
ffffffffc0201b84:	7179                	addi	sp,sp,-48
ffffffffc0201b86:	f022                	sd	s0,32(sp)
ffffffffc0201b88:	f406                	sd	ra,40(sp)
ffffffffc0201b8a:	ec26                	sd	s1,24(sp)
ffffffffc0201b8c:	e84a                	sd	s2,16(sp)
ffffffffc0201b8e:	e44e                	sd	s3,8(sp)
ffffffffc0201b90:	e052                	sd	s4,0(sp)
ffffffffc0201b92:	842e                	mv	s0,a1
	if (mm != NULL) {
ffffffffc0201b94:	c135                	beqz	a0,ffffffffc0201bf8 <user_mem_check+0x74>
		if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0201b96:	002007b7          	lui	a5,0x200
ffffffffc0201b9a:	04f5e663          	bltu	a1,a5,ffffffffc0201be6 <user_mem_check+0x62>
ffffffffc0201b9e:	00c584b3          	add	s1,a1,a2
ffffffffc0201ba2:	0495f263          	bgeu	a1,s1,ffffffffc0201be6 <user_mem_check+0x62>
ffffffffc0201ba6:	4785                	li	a5,1
ffffffffc0201ba8:	07fe                	slli	a5,a5,0x1f
ffffffffc0201baa:	0297ee63          	bltu	a5,s1,ffffffffc0201be6 <user_mem_check+0x62>
ffffffffc0201bae:	892a                	mv	s2,a0
ffffffffc0201bb0:	89b6                	mv	s3,a3
			if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
				return 0;
			}
			if (write && (vma->vm_flags & VM_STACK)) {
				if (start <
				    vma->vm_start +
ffffffffc0201bb2:	6a05                	lui	s4,0x1
ffffffffc0201bb4:	a821                	j	ffffffffc0201bcc <user_mem_check+0x48>
			if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201bb6:	0027f693          	andi	a3,a5,2
				    vma->vm_start +
ffffffffc0201bba:	9752                	add	a4,a4,s4
			if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201bbc:	8ba1                	andi	a5,a5,8
			if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201bbe:	c685                	beqz	a3,ffffffffc0201be6 <user_mem_check+0x62>
			if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0201bc0:	c399                	beqz	a5,ffffffffc0201bc6 <user_mem_check+0x42>
				if (start <
ffffffffc0201bc2:	02e46263          	bltu	s0,a4,ffffffffc0201be6 <user_mem_check+0x62>
					    PGSIZE) { // check stack start & size
					return 0;
				}
			}
			start = vma->vm_end;
ffffffffc0201bc6:	6900                	ld	s0,16(a0)
		while (start < end) {
ffffffffc0201bc8:	04947363          	bgeu	s0,s1,ffffffffc0201c0e <user_mem_check+0x8a>
			if ((vma = find_vma(mm, start)) == NULL ||
ffffffffc0201bcc:	85a2                	mv	a1,s0
ffffffffc0201bce:	854a                	mv	a0,s2
ffffffffc0201bd0:	b91ff0ef          	jal	ra,ffffffffc0201760 <find_vma>
ffffffffc0201bd4:	c909                	beqz	a0,ffffffffc0201be6 <user_mem_check+0x62>
			    start < vma->vm_start) {
ffffffffc0201bd6:	6518                	ld	a4,8(a0)
			if ((vma = find_vma(mm, start)) == NULL ||
ffffffffc0201bd8:	00e46763          	bltu	s0,a4,ffffffffc0201be6 <user_mem_check+0x62>
			if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0201bdc:	4d1c                	lw	a5,24(a0)
ffffffffc0201bde:	fc099ce3          	bnez	s3,ffffffffc0201bb6 <user_mem_check+0x32>
ffffffffc0201be2:	8b85                	andi	a5,a5,1
ffffffffc0201be4:	f3ed                	bnez	a5,ffffffffc0201bc6 <user_mem_check+0x42>
		}
		return 1;
	}
	return KERN_ACCESS(addr, addr + len);
ffffffffc0201be6:	4501                	li	a0,0
}
ffffffffc0201be8:	70a2                	ld	ra,40(sp)
ffffffffc0201bea:	7402                	ld	s0,32(sp)
ffffffffc0201bec:	64e2                	ld	s1,24(sp)
ffffffffc0201bee:	6942                	ld	s2,16(sp)
ffffffffc0201bf0:	69a2                	ld	s3,8(sp)
ffffffffc0201bf2:	6a02                	ld	s4,0(sp)
ffffffffc0201bf4:	6145                	addi	sp,sp,48
ffffffffc0201bf6:	8082                	ret
	return KERN_ACCESS(addr, addr + len);
ffffffffc0201bf8:	c02007b7          	lui	a5,0xc0200
ffffffffc0201bfc:	fef5e5e3          	bltu	a1,a5,ffffffffc0201be6 <user_mem_check+0x62>
ffffffffc0201c00:	962e                	add	a2,a2,a1
ffffffffc0201c02:	fec5f2e3          	bgeu	a1,a2,ffffffffc0201be6 <user_mem_check+0x62>
ffffffffc0201c06:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c0a:	fcc7eee3          	bltu	a5,a2,ffffffffc0201be6 <user_mem_check+0x62>
		return 1;
ffffffffc0201c0e:	4505                	li	a0,1
ffffffffc0201c10:	bfe1                	j	ffffffffc0201be8 <user_mem_check+0x64>

ffffffffc0201c12 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201c12:	c145                	beqz	a0,ffffffffc0201cb2 <slob_free+0xa0>
{
ffffffffc0201c14:	1141                	addi	sp,sp,-16
ffffffffc0201c16:	e022                	sd	s0,0(sp)
ffffffffc0201c18:	e406                	sd	ra,8(sp)
ffffffffc0201c1a:	842a                	mv	s0,a0
		return;

	if (size)
ffffffffc0201c1c:	edb1                	bnez	a1,ffffffffc0201c78 <slob_free+0x66>
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c1e:	100027f3          	csrr	a5,sstatus
ffffffffc0201c22:	8b89                	andi	a5,a5,2
	return 0;
ffffffffc0201c24:	4501                	li	a0,0
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c26:	e3ad                	bnez	a5,ffffffffc0201c88 <slob_free+0x76>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201c28:	00012617          	auipc	a2,0x12
ffffffffc0201c2c:	b6860613          	addi	a2,a2,-1176 # ffffffffc0213790 <slobfree>
ffffffffc0201c30:	621c                	ld	a5,0(a2)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201c32:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201c34:	0087fa63          	bgeu	a5,s0,ffffffffc0201c48 <slob_free+0x36>
ffffffffc0201c38:	00e46c63          	bltu	s0,a4,ffffffffc0201c50 <slob_free+0x3e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201c3c:	00e7fa63          	bgeu	a5,a4,ffffffffc0201c50 <slob_free+0x3e>
	return 0;
ffffffffc0201c40:	87ba                	mv	a5,a4
ffffffffc0201c42:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201c44:	fe87eae3          	bltu	a5,s0,ffffffffc0201c38 <slob_free+0x26>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201c48:	fee7ece3          	bltu	a5,a4,ffffffffc0201c40 <slob_free+0x2e>
ffffffffc0201c4c:	fee47ae3          	bgeu	s0,a4,ffffffffc0201c40 <slob_free+0x2e>
			break;

	if (b + b->units == cur->next) {
ffffffffc0201c50:	400c                	lw	a1,0(s0)
ffffffffc0201c52:	00459693          	slli	a3,a1,0x4
ffffffffc0201c56:	96a2                	add	a3,a3,s0
ffffffffc0201c58:	04d70763          	beq	a4,a3,ffffffffc0201ca6 <slob_free+0x94>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;
ffffffffc0201c5c:	e418                	sd	a4,8(s0)

	if (cur + cur->units == b) {
ffffffffc0201c5e:	4394                	lw	a3,0(a5)
ffffffffc0201c60:	00469713          	slli	a4,a3,0x4
ffffffffc0201c64:	973e                	add	a4,a4,a5
ffffffffc0201c66:	02e40a63          	beq	s0,a4,ffffffffc0201c9a <slob_free+0x88>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc0201c6a:	e780                	sd	s0,8(a5)

	slobfree = cur;
ffffffffc0201c6c:	e21c                	sd	a5,0(a2)
	if (flag) {
ffffffffc0201c6e:	e10d                	bnez	a0,ffffffffc0201c90 <slob_free+0x7e>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201c70:	60a2                	ld	ra,8(sp)
ffffffffc0201c72:	6402                	ld	s0,0(sp)
ffffffffc0201c74:	0141                	addi	sp,sp,16
ffffffffc0201c76:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc0201c78:	05bd                	addi	a1,a1,15
ffffffffc0201c7a:	8191                	srli	a1,a1,0x4
ffffffffc0201c7c:	c10c                	sw	a1,0(a0)
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c7e:	100027f3          	csrr	a5,sstatus
ffffffffc0201c82:	8b89                	andi	a5,a5,2
	return 0;
ffffffffc0201c84:	4501                	li	a0,0
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c86:	d3cd                	beqz	a5,ffffffffc0201c28 <slob_free+0x16>
		intr_disable();
ffffffffc0201c88:	e0afe0ef          	jal	ra,ffffffffc0200292 <intr_disable>
		return 1;
ffffffffc0201c8c:	4505                	li	a0,1
ffffffffc0201c8e:	bf69                	j	ffffffffc0201c28 <slob_free+0x16>
}
ffffffffc0201c90:	6402                	ld	s0,0(sp)
ffffffffc0201c92:	60a2                	ld	ra,8(sp)
ffffffffc0201c94:	0141                	addi	sp,sp,16
		intr_enable();
ffffffffc0201c96:	df6fe06f          	j	ffffffffc020028c <intr_enable>
		cur->units += b->units;
ffffffffc0201c9a:	4018                	lw	a4,0(s0)
		cur->next = b->next;
ffffffffc0201c9c:	640c                	ld	a1,8(s0)
		cur->units += b->units;
ffffffffc0201c9e:	9eb9                	addw	a3,a3,a4
ffffffffc0201ca0:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201ca2:	e78c                	sd	a1,8(a5)
ffffffffc0201ca4:	b7e1                	j	ffffffffc0201c6c <slob_free+0x5a>
		b->units += cur->next->units;
ffffffffc0201ca6:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201ca8:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201caa:	9db5                	addw	a1,a1,a3
ffffffffc0201cac:	c00c                	sw	a1,0(s0)
		b->next = cur->next->next;
ffffffffc0201cae:	e418                	sd	a4,8(s0)
ffffffffc0201cb0:	b77d                	j	ffffffffc0201c5e <slob_free+0x4c>
ffffffffc0201cb2:	8082                	ret

ffffffffc0201cb4 <__slob_get_free_pages.isra.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201cb4:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201cb6:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201cb8:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201cbc:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201cbe:	c7dfe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
	if (!page)
ffffffffc0201cc2:	c91d                	beqz	a0,ffffffffc0201cf8 <__slob_get_free_pages.isra.0+0x44>
	return page - pages + nbase;
ffffffffc0201cc4:	0001d697          	auipc	a3,0x1d
ffffffffc0201cc8:	b5c6b683          	ld	a3,-1188(a3) # ffffffffc021e820 <pages>
ffffffffc0201ccc:	8d15                	sub	a0,a0,a3
ffffffffc0201cce:	8519                	srai	a0,a0,0x6
ffffffffc0201cd0:	00004697          	auipc	a3,0x4
ffffffffc0201cd4:	4986b683          	ld	a3,1176(a3) # ffffffffc0206168 <nbase>
ffffffffc0201cd8:	9536                	add	a0,a0,a3
	return KADDR(page2pa(page));
ffffffffc0201cda:	00c51793          	slli	a5,a0,0xc
ffffffffc0201cde:	83b1                	srli	a5,a5,0xc
ffffffffc0201ce0:	0001d717          	auipc	a4,0x1d
ffffffffc0201ce4:	ad873703          	ld	a4,-1320(a4) # ffffffffc021e7b8 <npage>
	return page2ppn(page) << PGSHIFT;
ffffffffc0201ce8:	0532                	slli	a0,a0,0xc
	return KADDR(page2pa(page));
ffffffffc0201cea:	00e7fa63          	bgeu	a5,a4,ffffffffc0201cfe <__slob_get_free_pages.isra.0+0x4a>
ffffffffc0201cee:	0001d697          	auipc	a3,0x1d
ffffffffc0201cf2:	b2a6b683          	ld	a3,-1238(a3) # ffffffffc021e818 <va_pa_offset>
ffffffffc0201cf6:	9536                	add	a0,a0,a3
}
ffffffffc0201cf8:	60a2                	ld	ra,8(sp)
ffffffffc0201cfa:	0141                	addi	sp,sp,16
ffffffffc0201cfc:	8082                	ret
ffffffffc0201cfe:	86aa                	mv	a3,a0
ffffffffc0201d00:	00003617          	auipc	a2,0x3
ffffffffc0201d04:	10060613          	addi	a2,a2,256 # ffffffffc0204e00 <etext+0x7be>
ffffffffc0201d08:	07200593          	li	a1,114
ffffffffc0201d0c:	00003517          	auipc	a0,0x3
ffffffffc0201d10:	05450513          	addi	a0,a0,84 # ffffffffc0204d60 <etext+0x71e>
ffffffffc0201d14:	c24fe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0201d18 <slob_alloc.isra.0.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201d18:	1101                	addi	sp,sp,-32
ffffffffc0201d1a:	ec06                	sd	ra,24(sp)
ffffffffc0201d1c:	e822                	sd	s0,16(sp)
ffffffffc0201d1e:	e426                	sd	s1,8(sp)
ffffffffc0201d20:	e04a                	sd	s2,0(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201d22:	01050713          	addi	a4,a0,16
ffffffffc0201d26:	6785                	lui	a5,0x1
ffffffffc0201d28:	0cf77363          	bgeu	a4,a5,ffffffffc0201dee <slob_alloc.isra.0.constprop.0+0xd6>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201d2c:	00f50493          	addi	s1,a0,15
ffffffffc0201d30:	8091                	srli	s1,s1,0x4
ffffffffc0201d32:	2481                	sext.w	s1,s1
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d34:	10002673          	csrr	a2,sstatus
ffffffffc0201d38:	8a09                	andi	a2,a2,2
ffffffffc0201d3a:	e25d                	bnez	a2,ffffffffc0201de0 <slob_alloc.isra.0.constprop.0+0xc8>
	prev = slobfree;
ffffffffc0201d3c:	00012917          	auipc	s2,0x12
ffffffffc0201d40:	a5490913          	addi	s2,s2,-1452 # ffffffffc0213790 <slobfree>
ffffffffc0201d44:	00093683          	ld	a3,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next) {
ffffffffc0201d48:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201d4a:	4398                	lw	a4,0(a5)
ffffffffc0201d4c:	08975e63          	bge	a4,s1,ffffffffc0201de8 <slob_alloc.isra.0.constprop.0+0xd0>
		if (cur == slobfree) {
ffffffffc0201d50:	00d78b63          	beq	a5,a3,ffffffffc0201d66 <slob_alloc.isra.0.constprop.0+0x4e>
	for (cur = prev->next;; prev = cur, cur = cur->next) {
ffffffffc0201d54:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201d56:	4018                	lw	a4,0(s0)
ffffffffc0201d58:	02975a63          	bge	a4,s1,ffffffffc0201d8c <slob_alloc.isra.0.constprop.0+0x74>
ffffffffc0201d5c:	00093683          	ld	a3,0(s2)
ffffffffc0201d60:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc0201d62:	fed799e3          	bne	a5,a3,ffffffffc0201d54 <slob_alloc.isra.0.constprop.0+0x3c>
	if (flag) {
ffffffffc0201d66:	ee31                	bnez	a2,ffffffffc0201dc2 <slob_alloc.isra.0.constprop.0+0xaa>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201d68:	4501                	li	a0,0
ffffffffc0201d6a:	f4bff0ef          	jal	ra,ffffffffc0201cb4 <__slob_get_free_pages.isra.0>
ffffffffc0201d6e:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201d70:	cd05                	beqz	a0,ffffffffc0201da8 <slob_alloc.isra.0.constprop.0+0x90>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201d72:	6585                	lui	a1,0x1
ffffffffc0201d74:	e9fff0ef          	jal	ra,ffffffffc0201c12 <slob_free>
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d78:	10002673          	csrr	a2,sstatus
ffffffffc0201d7c:	8a09                	andi	a2,a2,2
ffffffffc0201d7e:	ee05                	bnez	a2,ffffffffc0201db6 <slob_alloc.isra.0.constprop.0+0x9e>
			cur = slobfree;
ffffffffc0201d80:	00093783          	ld	a5,0(s2)
	for (cur = prev->next;; prev = cur, cur = cur->next) {
ffffffffc0201d84:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201d86:	4018                	lw	a4,0(s0)
ffffffffc0201d88:	fc974ae3          	blt	a4,s1,ffffffffc0201d5c <slob_alloc.isra.0.constprop.0+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201d8c:	04e48763          	beq	s1,a4,ffffffffc0201dda <slob_alloc.isra.0.constprop.0+0xc2>
				prev->next = cur + units;
ffffffffc0201d90:	00449693          	slli	a3,s1,0x4
ffffffffc0201d94:	96a2                	add	a3,a3,s0
ffffffffc0201d96:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201d98:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201d9a:	9f05                	subw	a4,a4,s1
ffffffffc0201d9c:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201d9e:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201da0:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201da2:	00f93023          	sd	a5,0(s2)
	if (flag) {
ffffffffc0201da6:	e20d                	bnez	a2,ffffffffc0201dc8 <slob_alloc.isra.0.constprop.0+0xb0>
}
ffffffffc0201da8:	60e2                	ld	ra,24(sp)
ffffffffc0201daa:	8522                	mv	a0,s0
ffffffffc0201dac:	6442                	ld	s0,16(sp)
ffffffffc0201dae:	64a2                	ld	s1,8(sp)
ffffffffc0201db0:	6902                	ld	s2,0(sp)
ffffffffc0201db2:	6105                	addi	sp,sp,32
ffffffffc0201db4:	8082                	ret
		intr_disable();
ffffffffc0201db6:	cdcfe0ef          	jal	ra,ffffffffc0200292 <intr_disable>
			cur = slobfree;
ffffffffc0201dba:	00093783          	ld	a5,0(s2)
		return 1;
ffffffffc0201dbe:	4605                	li	a2,1
ffffffffc0201dc0:	b7d1                	j	ffffffffc0201d84 <slob_alloc.isra.0.constprop.0+0x6c>
		intr_enable();
ffffffffc0201dc2:	ccafe0ef          	jal	ra,ffffffffc020028c <intr_enable>
ffffffffc0201dc6:	b74d                	j	ffffffffc0201d68 <slob_alloc.isra.0.constprop.0+0x50>
ffffffffc0201dc8:	cc4fe0ef          	jal	ra,ffffffffc020028c <intr_enable>
}
ffffffffc0201dcc:	60e2                	ld	ra,24(sp)
ffffffffc0201dce:	8522                	mv	a0,s0
ffffffffc0201dd0:	6442                	ld	s0,16(sp)
ffffffffc0201dd2:	64a2                	ld	s1,8(sp)
ffffffffc0201dd4:	6902                	ld	s2,0(sp)
ffffffffc0201dd6:	6105                	addi	sp,sp,32
ffffffffc0201dd8:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201dda:	6418                	ld	a4,8(s0)
ffffffffc0201ddc:	e798                	sd	a4,8(a5)
ffffffffc0201dde:	b7d1                	j	ffffffffc0201da2 <slob_alloc.isra.0.constprop.0+0x8a>
		intr_disable();
ffffffffc0201de0:	cb2fe0ef          	jal	ra,ffffffffc0200292 <intr_disable>
		return 1;
ffffffffc0201de4:	4605                	li	a2,1
ffffffffc0201de6:	bf99                	j	ffffffffc0201d3c <slob_alloc.isra.0.constprop.0+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201de8:	843e                	mv	s0,a5
ffffffffc0201dea:	87b6                	mv	a5,a3
ffffffffc0201dec:	b745                	j	ffffffffc0201d8c <slob_alloc.isra.0.constprop.0+0x74>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201dee:	00003697          	auipc	a3,0x3
ffffffffc0201df2:	4ca68693          	addi	a3,a3,1226 # ffffffffc02052b8 <etext+0xc76>
ffffffffc0201df6:	00003617          	auipc	a2,0x3
ffffffffc0201dfa:	c5a60613          	addi	a2,a2,-934 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0201dfe:	06100593          	li	a1,97
ffffffffc0201e02:	00003517          	auipc	a0,0x3
ffffffffc0201e06:	4d650513          	addi	a0,a0,1238 # ffffffffc02052d8 <etext+0xc96>
ffffffffc0201e0a:	b2efe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0201e0e <kmalloc_init>:

inline void kmalloc_init(void)
{
	slob_init();
	// cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201e0e:	8082                	ret

ffffffffc0201e10 <kmalloc>:
	slob_free(bb, sizeof(bigblock_t));
	return 0;
}

void *kmalloc(size_t size)
{
ffffffffc0201e10:	1101                	addi	sp,sp,-32
ffffffffc0201e12:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201e14:	6905                	lui	s2,0x1
{
ffffffffc0201e16:	e822                	sd	s0,16(sp)
ffffffffc0201e18:	ec06                	sd	ra,24(sp)
ffffffffc0201e1a:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201e1c:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_hello_out_size-0x8751>
{
ffffffffc0201e20:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201e22:	04a7f963          	bgeu	a5,a0,ffffffffc0201e74 <kmalloc+0x64>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201e26:	4561                	li	a0,24
ffffffffc0201e28:	ef1ff0ef          	jal	ra,ffffffffc0201d18 <slob_alloc.isra.0.constprop.0>
ffffffffc0201e2c:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201e2e:	c929                	beqz	a0,ffffffffc0201e80 <kmalloc+0x70>
	bb->order = find_order(size);
ffffffffc0201e30:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201e34:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201e36:	00f95763          	bge	s2,a5,ffffffffc0201e44 <kmalloc+0x34>
ffffffffc0201e3a:	6705                	lui	a4,0x1
ffffffffc0201e3c:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201e3e:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201e40:	fef74ee3          	blt	a4,a5,ffffffffc0201e3c <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201e44:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201e46:	e6fff0ef          	jal	ra,ffffffffc0201cb4 <__slob_get_free_pages.isra.0>
ffffffffc0201e4a:	e488                	sd	a0,8(s1)
ffffffffc0201e4c:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201e4e:	c525                	beqz	a0,ffffffffc0201eb6 <kmalloc+0xa6>
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e50:	100027f3          	csrr	a5,sstatus
ffffffffc0201e54:	8b89                	andi	a5,a5,2
ffffffffc0201e56:	ef8d                	bnez	a5,ffffffffc0201e90 <kmalloc+0x80>
		bb->next = bigblocks;
ffffffffc0201e58:	0001d797          	auipc	a5,0x1d
ffffffffc0201e5c:	97078793          	addi	a5,a5,-1680 # ffffffffc021e7c8 <bigblocks>
ffffffffc0201e60:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201e62:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201e64:	e898                	sd	a4,16(s1)
	return __kmalloc(size, 0);
}
ffffffffc0201e66:	60e2                	ld	ra,24(sp)
ffffffffc0201e68:	8522                	mv	a0,s0
ffffffffc0201e6a:	6442                	ld	s0,16(sp)
ffffffffc0201e6c:	64a2                	ld	s1,8(sp)
ffffffffc0201e6e:	6902                	ld	s2,0(sp)
ffffffffc0201e70:	6105                	addi	sp,sp,32
ffffffffc0201e72:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201e74:	0541                	addi	a0,a0,16
ffffffffc0201e76:	ea3ff0ef          	jal	ra,ffffffffc0201d18 <slob_alloc.isra.0.constprop.0>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201e7a:	01050413          	addi	s0,a0,16
ffffffffc0201e7e:	f565                	bnez	a0,ffffffffc0201e66 <kmalloc+0x56>
ffffffffc0201e80:	4401                	li	s0,0
}
ffffffffc0201e82:	60e2                	ld	ra,24(sp)
ffffffffc0201e84:	8522                	mv	a0,s0
ffffffffc0201e86:	6442                	ld	s0,16(sp)
ffffffffc0201e88:	64a2                	ld	s1,8(sp)
ffffffffc0201e8a:	6902                	ld	s2,0(sp)
ffffffffc0201e8c:	6105                	addi	sp,sp,32
ffffffffc0201e8e:	8082                	ret
		intr_disable();
ffffffffc0201e90:	c02fe0ef          	jal	ra,ffffffffc0200292 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201e94:	0001d797          	auipc	a5,0x1d
ffffffffc0201e98:	93478793          	addi	a5,a5,-1740 # ffffffffc021e7c8 <bigblocks>
ffffffffc0201e9c:	6398                	ld	a4,0(a5)
		bigblocks = bb;
ffffffffc0201e9e:	e384                	sd	s1,0(a5)
		bb->next = bigblocks;
ffffffffc0201ea0:	e898                	sd	a4,16(s1)
		intr_enable();
ffffffffc0201ea2:	beafe0ef          	jal	ra,ffffffffc020028c <intr_enable>
ffffffffc0201ea6:	6480                	ld	s0,8(s1)
}
ffffffffc0201ea8:	60e2                	ld	ra,24(sp)
ffffffffc0201eaa:	64a2                	ld	s1,8(sp)
ffffffffc0201eac:	8522                	mv	a0,s0
ffffffffc0201eae:	6442                	ld	s0,16(sp)
ffffffffc0201eb0:	6902                	ld	s2,0(sp)
ffffffffc0201eb2:	6105                	addi	sp,sp,32
ffffffffc0201eb4:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201eb6:	45e1                	li	a1,24
ffffffffc0201eb8:	8526                	mv	a0,s1
ffffffffc0201eba:	d59ff0ef          	jal	ra,ffffffffc0201c12 <slob_free>
	return __kmalloc(size, 0);
ffffffffc0201ebe:	b765                	j	ffffffffc0201e66 <kmalloc+0x56>

ffffffffc0201ec0 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201ec0:	c169                	beqz	a0,ffffffffc0201f82 <kfree+0xc2>
{
ffffffffc0201ec2:	1101                	addi	sp,sp,-32
ffffffffc0201ec4:	e822                	sd	s0,16(sp)
ffffffffc0201ec6:	ec06                	sd	ra,24(sp)
ffffffffc0201ec8:	e426                	sd	s1,8(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1))) {
ffffffffc0201eca:	03451793          	slli	a5,a0,0x34
ffffffffc0201ece:	842a                	mv	s0,a0
ffffffffc0201ed0:	e7c9                	bnez	a5,ffffffffc0201f5a <kfree+0x9a>
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ed2:	100027f3          	csrr	a5,sstatus
ffffffffc0201ed6:	8b89                	andi	a5,a5,2
ffffffffc0201ed8:	ebc9                	bnez	a5,ffffffffc0201f6a <kfree+0xaa>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201eda:	0001d797          	auipc	a5,0x1d
ffffffffc0201ede:	8ee7b783          	ld	a5,-1810(a5) # ffffffffc021e7c8 <bigblocks>
	return 0;
ffffffffc0201ee2:	4601                	li	a2,0
ffffffffc0201ee4:	cbbd                	beqz	a5,ffffffffc0201f5a <kfree+0x9a>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201ee6:	0001d697          	auipc	a3,0x1d
ffffffffc0201eea:	8e268693          	addi	a3,a3,-1822 # ffffffffc021e7c8 <bigblocks>
ffffffffc0201eee:	a021                	j	ffffffffc0201ef6 <kfree+0x36>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201ef0:	01048693          	addi	a3,s1,16 # ffffffffffe00010 <end+0x3fbe16e0>
ffffffffc0201ef4:	c3a5                	beqz	a5,ffffffffc0201f54 <kfree+0x94>
			if (bb->pages == block) {
ffffffffc0201ef6:	6798                	ld	a4,8(a5)
ffffffffc0201ef8:	84be                	mv	s1,a5
ffffffffc0201efa:	6b9c                	ld	a5,16(a5)
ffffffffc0201efc:	fe871ae3          	bne	a4,s0,ffffffffc0201ef0 <kfree+0x30>
				*last = bb->next;
ffffffffc0201f00:	e29c                	sd	a5,0(a3)
	if (flag) {
ffffffffc0201f02:	ee2d                	bnez	a2,ffffffffc0201f7c <kfree+0xbc>
	return pa2page(PADDR(kva));
ffffffffc0201f04:	c02007b7          	lui	a5,0xc0200
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block,
ffffffffc0201f08:	4098                	lw	a4,0(s1)
ffffffffc0201f0a:	08f46963          	bltu	s0,a5,ffffffffc0201f9c <kfree+0xdc>
ffffffffc0201f0e:	0001d697          	auipc	a3,0x1d
ffffffffc0201f12:	90a6b683          	ld	a3,-1782(a3) # ffffffffc021e818 <va_pa_offset>
ffffffffc0201f16:	8c15                	sub	s0,s0,a3
	if (PPN(pa) >= npage) {
ffffffffc0201f18:	8031                	srli	s0,s0,0xc
ffffffffc0201f1a:	0001d797          	auipc	a5,0x1d
ffffffffc0201f1e:	89e7b783          	ld	a5,-1890(a5) # ffffffffc021e7b8 <npage>
ffffffffc0201f22:	06f47163          	bgeu	s0,a5,ffffffffc0201f84 <kfree+0xc4>
	return &pages[PPN(pa) - nbase];
ffffffffc0201f26:	00004517          	auipc	a0,0x4
ffffffffc0201f2a:	24253503          	ld	a0,578(a0) # ffffffffc0206168 <nbase>
ffffffffc0201f2e:	8c09                	sub	s0,s0,a0
ffffffffc0201f30:	041a                	slli	s0,s0,0x6
	free_pages(kva2page((void *)kva), 1 << order);
ffffffffc0201f32:	0001d517          	auipc	a0,0x1d
ffffffffc0201f36:	8ee53503          	ld	a0,-1810(a0) # ffffffffc021e820 <pages>
ffffffffc0201f3a:	4585                	li	a1,1
ffffffffc0201f3c:	9522                	add	a0,a0,s0
ffffffffc0201f3e:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201f42:	a8bfe0ef          	jal	ra,ffffffffc02009cc <free_pages>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201f46:	6442                	ld	s0,16(sp)
ffffffffc0201f48:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201f4a:	8526                	mv	a0,s1
}
ffffffffc0201f4c:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201f4e:	45e1                	li	a1,24
}
ffffffffc0201f50:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201f52:	b1c1                	j	ffffffffc0201c12 <slob_free>
ffffffffc0201f54:	c219                	beqz	a2,ffffffffc0201f5a <kfree+0x9a>
		intr_enable();
ffffffffc0201f56:	b36fe0ef          	jal	ra,ffffffffc020028c <intr_enable>
ffffffffc0201f5a:	ff040513          	addi	a0,s0,-16
}
ffffffffc0201f5e:	6442                	ld	s0,16(sp)
ffffffffc0201f60:	60e2                	ld	ra,24(sp)
ffffffffc0201f62:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201f64:	4581                	li	a1,0
}
ffffffffc0201f66:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201f68:	b16d                	j	ffffffffc0201c12 <slob_free>
		intr_disable();
ffffffffc0201f6a:	b28fe0ef          	jal	ra,ffffffffc0200292 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201f6e:	0001d797          	auipc	a5,0x1d
ffffffffc0201f72:	85a7b783          	ld	a5,-1958(a5) # ffffffffc021e7c8 <bigblocks>
		return 1;
ffffffffc0201f76:	4605                	li	a2,1
ffffffffc0201f78:	f7bd                	bnez	a5,ffffffffc0201ee6 <kfree+0x26>
ffffffffc0201f7a:	bff1                	j	ffffffffc0201f56 <kfree+0x96>
		intr_enable();
ffffffffc0201f7c:	b10fe0ef          	jal	ra,ffffffffc020028c <intr_enable>
ffffffffc0201f80:	b751                	j	ffffffffc0201f04 <kfree+0x44>
ffffffffc0201f82:	8082                	ret
		panic("pa2page called with invalid pa");
ffffffffc0201f84:	00003617          	auipc	a2,0x3
ffffffffc0201f88:	dbc60613          	addi	a2,a2,-580 # ffffffffc0204d40 <etext+0x6fe>
ffffffffc0201f8c:	06b00593          	li	a1,107
ffffffffc0201f90:	00003517          	auipc	a0,0x3
ffffffffc0201f94:	dd050513          	addi	a0,a0,-560 # ffffffffc0204d60 <etext+0x71e>
ffffffffc0201f98:	9a0fe0ef          	jal	ra,ffffffffc0200138 <__panic>
	return pa2page(PADDR(kva));
ffffffffc0201f9c:	86a2                	mv	a3,s0
ffffffffc0201f9e:	00003617          	auipc	a2,0x3
ffffffffc0201fa2:	e2a60613          	addi	a2,a2,-470 # ffffffffc0204dc8 <etext+0x786>
ffffffffc0201fa6:	07700593          	li	a1,119
ffffffffc0201faa:	00003517          	auipc	a0,0x3
ffffffffc0201fae:	db650513          	addi	a0,a0,-586 # ffffffffc0204d60 <etext+0x71e>
ffffffffc0201fb2:	986fe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0201fb6 <swap_init>:
unsigned int swap_in_seq_no[MAX_SEQ_NO], swap_out_seq_no[MAX_SEQ_NO];

static void check_swap(void);

int swap_init(void)
{
ffffffffc0201fb6:	1101                	addi	sp,sp,-32
ffffffffc0201fb8:	ec06                	sd	ra,24(sp)
ffffffffc0201fba:	e822                	sd	s0,16(sp)
ffffffffc0201fbc:	e426                	sd	s1,8(sp)
	swapfs_init();
ffffffffc0201fbe:	4cd000ef          	jal	ra,ffffffffc0202c8a <swapfs_init>

	// Since the IDE is faked, it can only store 7 pages at most to pass the test
	if (!(7 <= max_swap_offset &&
ffffffffc0201fc2:	0001d697          	auipc	a3,0x1d
ffffffffc0201fc6:	9066b683          	ld	a3,-1786(a3) # ffffffffc021e8c8 <max_swap_offset>
ffffffffc0201fca:	010007b7          	lui	a5,0x1000
ffffffffc0201fce:	ff968713          	addi	a4,a3,-7
ffffffffc0201fd2:	17e1                	addi	a5,a5,-8
ffffffffc0201fd4:	04e7e863          	bltu	a5,a4,ffffffffc0202024 <swap_init+0x6e>
	      max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
		panic("bad max_swap_offset %08x.\n", max_swap_offset);
	}

	sm = &swap_manager_fifo;
ffffffffc0201fd8:	00011797          	auipc	a5,0x11
ffffffffc0201fdc:	76878793          	addi	a5,a5,1896 # ffffffffc0213740 <swap_manager_fifo>
	int r = sm->init();
ffffffffc0201fe0:	6798                	ld	a4,8(a5)
	sm = &swap_manager_fifo;
ffffffffc0201fe2:	0001c497          	auipc	s1,0x1c
ffffffffc0201fe6:	7ee48493          	addi	s1,s1,2030 # ffffffffc021e7d0 <sm>
ffffffffc0201fea:	e09c                	sd	a5,0(s1)
	int r = sm->init();
ffffffffc0201fec:	9702                	jalr	a4
ffffffffc0201fee:	842a                	mv	s0,a0

	if (r == 0) {
ffffffffc0201ff0:	c519                	beqz	a0,ffffffffc0201ffe <swap_init+0x48>
		cprintf("SWAP: manager = %s\n", sm->name);
		// check_swap();
	}

	return r;
}
ffffffffc0201ff2:	60e2                	ld	ra,24(sp)
ffffffffc0201ff4:	8522                	mv	a0,s0
ffffffffc0201ff6:	6442                	ld	s0,16(sp)
ffffffffc0201ff8:	64a2                	ld	s1,8(sp)
ffffffffc0201ffa:	6105                	addi	sp,sp,32
ffffffffc0201ffc:	8082                	ret
		cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0201ffe:	609c                	ld	a5,0(s1)
ffffffffc0202000:	00003517          	auipc	a0,0x3
ffffffffc0202004:	32050513          	addi	a0,a0,800 # ffffffffc0205320 <etext+0xcde>
ffffffffc0202008:	638c                	ld	a1,0(a5)
		swap_init_ok = 1;
ffffffffc020200a:	4785                	li	a5,1
ffffffffc020200c:	0001c717          	auipc	a4,0x1c
ffffffffc0202010:	7cf72623          	sw	a5,1996(a4) # ffffffffc021e7d8 <swap_init_ok>
		cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202014:	8acfe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
}
ffffffffc0202018:	60e2                	ld	ra,24(sp)
ffffffffc020201a:	8522                	mv	a0,s0
ffffffffc020201c:	6442                	ld	s0,16(sp)
ffffffffc020201e:	64a2                	ld	s1,8(sp)
ffffffffc0202020:	6105                	addi	sp,sp,32
ffffffffc0202022:	8082                	ret
		panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202024:	00003617          	auipc	a2,0x3
ffffffffc0202028:	2cc60613          	addi	a2,a2,716 # ffffffffc02052f0 <etext+0xcae>
ffffffffc020202c:	02700593          	li	a1,39
ffffffffc0202030:	00003517          	auipc	a0,0x3
ffffffffc0202034:	2e050513          	addi	a0,a0,736 # ffffffffc0205310 <etext+0xcce>
ffffffffc0202038:	900fe0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc020203c <swap_init_mm>:

int swap_init_mm(struct mm_struct *mm)
{
	return sm->init_mm(mm);
ffffffffc020203c:	0001c797          	auipc	a5,0x1c
ffffffffc0202040:	7947b783          	ld	a5,1940(a5) # ffffffffc021e7d0 <sm>
ffffffffc0202044:	0107b303          	ld	t1,16(a5)
ffffffffc0202048:	8302                	jr	t1

ffffffffc020204a <swap_map_swappable>:
}

int swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page,
		       int swap_in)
{
	return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc020204a:	0001c797          	auipc	a5,0x1c
ffffffffc020204e:	7867b783          	ld	a5,1926(a5) # ffffffffc021e7d0 <sm>
ffffffffc0202052:	0207b303          	ld	t1,32(a5)
ffffffffc0202056:	8302                	jr	t1

ffffffffc0202058 <swap_out>:
}

volatile unsigned int swap_out_num = 0;

int swap_out(struct mm_struct *mm, int n, int in_tick)
{
ffffffffc0202058:	711d                	addi	sp,sp,-96
ffffffffc020205a:	ec86                	sd	ra,88(sp)
ffffffffc020205c:	e8a2                	sd	s0,80(sp)
ffffffffc020205e:	e4a6                	sd	s1,72(sp)
ffffffffc0202060:	e0ca                	sd	s2,64(sp)
ffffffffc0202062:	fc4e                	sd	s3,56(sp)
ffffffffc0202064:	f852                	sd	s4,48(sp)
ffffffffc0202066:	f456                	sd	s5,40(sp)
ffffffffc0202068:	f05a                	sd	s6,32(sp)
ffffffffc020206a:	ec5e                	sd	s7,24(sp)
ffffffffc020206c:	e862                	sd	s8,16(sp)
	int i;
	for (i = 0; i != n; ++i) {
ffffffffc020206e:	cde9                	beqz	a1,ffffffffc0202148 <swap_out+0xf0>
ffffffffc0202070:	8a2e                	mv	s4,a1
ffffffffc0202072:	892a                	mv	s2,a0
ffffffffc0202074:	8ab2                	mv	s5,a2
ffffffffc0202076:	4401                	li	s0,0
ffffffffc0202078:	0001c997          	auipc	s3,0x1c
ffffffffc020207c:	75898993          	addi	s3,s3,1880 # ffffffffc021e7d0 <sm>
		    0) {
			cprintf("SWAP: failed to save\n");
			sm->map_swappable(mm, v, page, 0);
			continue;
		} else {
			cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n",
ffffffffc0202080:	00003b17          	auipc	s6,0x3
ffffffffc0202084:	318b0b13          	addi	s6,s6,792 # ffffffffc0205398 <etext+0xd56>
			cprintf("SWAP: failed to save\n");
ffffffffc0202088:	00003b97          	auipc	s7,0x3
ffffffffc020208c:	2f8b8b93          	addi	s7,s7,760 # ffffffffc0205380 <etext+0xd3e>
ffffffffc0202090:	a825                	j	ffffffffc02020c8 <swap_out+0x70>
				i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0202092:	67a2                	ld	a5,8(sp)
			cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n",
ffffffffc0202094:	8626                	mv	a2,s1
ffffffffc0202096:	85a2                	mv	a1,s0
				i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc0202098:	7f94                	ld	a3,56(a5)
			cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n",
ffffffffc020209a:	855a                	mv	a0,s6
	for (i = 0; i != n; ++i) {
ffffffffc020209c:	2405                	addiw	s0,s0,1
				i, v, page->pra_vaddr / PGSIZE + 1);
ffffffffc020209e:	82b1                	srli	a3,a3,0xc
			cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n",
ffffffffc02020a0:	0685                	addi	a3,a3,1
ffffffffc02020a2:	81efe0ef          	jal	ra,ffffffffc02000c0 <cprintf>
			*ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
ffffffffc02020a6:	6522                	ld	a0,8(sp)
			free_page(page);
ffffffffc02020a8:	4585                	li	a1,1
			*ptep = (page->pra_vaddr / PGSIZE + 1) << 8;
ffffffffc02020aa:	7d1c                	ld	a5,56(a0)
ffffffffc02020ac:	83b1                	srli	a5,a5,0xc
ffffffffc02020ae:	0785                	addi	a5,a5,1
ffffffffc02020b0:	07a2                	slli	a5,a5,0x8
ffffffffc02020b2:	00fc3023          	sd	a5,0(s8)
			free_page(page);
ffffffffc02020b6:	917fe0ef          	jal	ra,ffffffffc02009cc <free_pages>
		}

		tlb_invalidate(mm->pgdir, v);
ffffffffc02020ba:	01893503          	ld	a0,24(s2)
ffffffffc02020be:	85a6                	mv	a1,s1
ffffffffc02020c0:	9b2ff0ef          	jal	ra,ffffffffc0201272 <tlb_invalidate>
	for (i = 0; i != n; ++i) {
ffffffffc02020c4:	048a0d63          	beq	s4,s0,ffffffffc020211e <swap_out+0xc6>
		int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc02020c8:	0009b783          	ld	a5,0(s3)
ffffffffc02020cc:	8656                	mv	a2,s5
ffffffffc02020ce:	002c                	addi	a1,sp,8
ffffffffc02020d0:	7b9c                	ld	a5,48(a5)
ffffffffc02020d2:	854a                	mv	a0,s2
ffffffffc02020d4:	9782                	jalr	a5
		if (r != 0) {
ffffffffc02020d6:	e12d                	bnez	a0,ffffffffc0202138 <swap_out+0xe0>
		v = page->pra_vaddr;
ffffffffc02020d8:	67a2                	ld	a5,8(sp)
		pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02020da:	01893503          	ld	a0,24(s2)
ffffffffc02020de:	4601                	li	a2,0
		v = page->pra_vaddr;
ffffffffc02020e0:	7f84                	ld	s1,56(a5)
		pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02020e2:	85a6                	mv	a1,s1
ffffffffc02020e4:	abdfe0ef          	jal	ra,ffffffffc0200ba0 <get_pte>
		assert((*ptep & PTE_V) != 0);
ffffffffc02020e8:	611c                	ld	a5,0(a0)
		pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc02020ea:	8c2a                	mv	s8,a0
		assert((*ptep & PTE_V) != 0);
ffffffffc02020ec:	8b85                	andi	a5,a5,1
ffffffffc02020ee:	cfb9                	beqz	a5,ffffffffc020214c <swap_out+0xf4>
		if (swapfs_write((page->pra_vaddr / PGSIZE + 1) << 8, page) !=
ffffffffc02020f0:	65a2                	ld	a1,8(sp)
ffffffffc02020f2:	7d9c                	ld	a5,56(a1)
ffffffffc02020f4:	83b1                	srli	a5,a5,0xc
ffffffffc02020f6:	0785                	addi	a5,a5,1
ffffffffc02020f8:	00879513          	slli	a0,a5,0x8
ffffffffc02020fc:	455000ef          	jal	ra,ffffffffc0202d50 <swapfs_write>
ffffffffc0202100:	d949                	beqz	a0,ffffffffc0202092 <swap_out+0x3a>
			cprintf("SWAP: failed to save\n");
ffffffffc0202102:	855e                	mv	a0,s7
ffffffffc0202104:	fbdfd0ef          	jal	ra,ffffffffc02000c0 <cprintf>
			sm->map_swappable(mm, v, page, 0);
ffffffffc0202108:	0009b783          	ld	a5,0(s3)
ffffffffc020210c:	6622                	ld	a2,8(sp)
ffffffffc020210e:	4681                	li	a3,0
ffffffffc0202110:	739c                	ld	a5,32(a5)
ffffffffc0202112:	85a6                	mv	a1,s1
ffffffffc0202114:	854a                	mv	a0,s2
	for (i = 0; i != n; ++i) {
ffffffffc0202116:	2405                	addiw	s0,s0,1
			sm->map_swappable(mm, v, page, 0);
ffffffffc0202118:	9782                	jalr	a5
	for (i = 0; i != n; ++i) {
ffffffffc020211a:	fa8a17e3          	bne	s4,s0,ffffffffc02020c8 <swap_out+0x70>
	}
	return i;
}
ffffffffc020211e:	60e6                	ld	ra,88(sp)
ffffffffc0202120:	8522                	mv	a0,s0
ffffffffc0202122:	6446                	ld	s0,80(sp)
ffffffffc0202124:	64a6                	ld	s1,72(sp)
ffffffffc0202126:	6906                	ld	s2,64(sp)
ffffffffc0202128:	79e2                	ld	s3,56(sp)
ffffffffc020212a:	7a42                	ld	s4,48(sp)
ffffffffc020212c:	7aa2                	ld	s5,40(sp)
ffffffffc020212e:	7b02                	ld	s6,32(sp)
ffffffffc0202130:	6be2                	ld	s7,24(sp)
ffffffffc0202132:	6c42                	ld	s8,16(sp)
ffffffffc0202134:	6125                	addi	sp,sp,96
ffffffffc0202136:	8082                	ret
			cprintf("i %d, swap_out: call swap_out_victim failed\n",
ffffffffc0202138:	85a2                	mv	a1,s0
ffffffffc020213a:	00003517          	auipc	a0,0x3
ffffffffc020213e:	1fe50513          	addi	a0,a0,510 # ffffffffc0205338 <etext+0xcf6>
ffffffffc0202142:	f7ffd0ef          	jal	ra,ffffffffc02000c0 <cprintf>
			break;
ffffffffc0202146:	bfe1                	j	ffffffffc020211e <swap_out+0xc6>
	for (i = 0; i != n; ++i) {
ffffffffc0202148:	4401                	li	s0,0
ffffffffc020214a:	bfd1                	j	ffffffffc020211e <swap_out+0xc6>
		assert((*ptep & PTE_V) != 0);
ffffffffc020214c:	00003697          	auipc	a3,0x3
ffffffffc0202150:	21c68693          	addi	a3,a3,540 # ffffffffc0205368 <etext+0xd26>
ffffffffc0202154:	00003617          	auipc	a2,0x3
ffffffffc0202158:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0204a50 <etext+0x40e>
ffffffffc020215c:	06100593          	li	a1,97
ffffffffc0202160:	00003517          	auipc	a0,0x3
ffffffffc0202164:	1b050513          	addi	a0,a0,432 # ffffffffc0205310 <etext+0xcce>
ffffffffc0202168:	fd1fd0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc020216c <swap_in>:

int swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
ffffffffc020216c:	7179                	addi	sp,sp,-48
ffffffffc020216e:	e84a                	sd	s2,16(sp)
ffffffffc0202170:	892a                	mv	s2,a0
	struct Page *result = alloc_page();
ffffffffc0202172:	4505                	li	a0,1
{
ffffffffc0202174:	ec26                	sd	s1,24(sp)
ffffffffc0202176:	e44e                	sd	s3,8(sp)
ffffffffc0202178:	f406                	sd	ra,40(sp)
ffffffffc020217a:	f022                	sd	s0,32(sp)
ffffffffc020217c:	84ae                	mv	s1,a1
ffffffffc020217e:	89b2                	mv	s3,a2
	struct Page *result = alloc_page();
ffffffffc0202180:	fbafe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
	assert(result != NULL);
ffffffffc0202184:	c129                	beqz	a0,ffffffffc02021c6 <swap_in+0x5a>

	pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202186:	842a                	mv	s0,a0
ffffffffc0202188:	01893503          	ld	a0,24(s2)
ffffffffc020218c:	4601                	li	a2,0
ffffffffc020218e:	85a6                	mv	a1,s1
ffffffffc0202190:	a11fe0ef          	jal	ra,ffffffffc0200ba0 <get_pte>
ffffffffc0202194:	892a                	mv	s2,a0
	// cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No
	// %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));

	int r;
	if ((r = swapfs_read((*ptep), result)) != 0) {
ffffffffc0202196:	6108                	ld	a0,0(a0)
ffffffffc0202198:	85a2                	mv	a1,s0
ffffffffc020219a:	329000ef          	jal	ra,ffffffffc0202cc2 <swapfs_read>
		assert(r != 0);
	}
	cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n",
ffffffffc020219e:	00093583          	ld	a1,0(s2)
ffffffffc02021a2:	8626                	mv	a2,s1
ffffffffc02021a4:	00003517          	auipc	a0,0x3
ffffffffc02021a8:	24450513          	addi	a0,a0,580 # ffffffffc02053e8 <etext+0xda6>
ffffffffc02021ac:	81a1                	srli	a1,a1,0x8
ffffffffc02021ae:	f13fd0ef          	jal	ra,ffffffffc02000c0 <cprintf>
		(*ptep) >> 8, addr);
	*ptr_result = result;
	return 0;
}
ffffffffc02021b2:	70a2                	ld	ra,40(sp)
	*ptr_result = result;
ffffffffc02021b4:	0089b023          	sd	s0,0(s3)
}
ffffffffc02021b8:	7402                	ld	s0,32(sp)
ffffffffc02021ba:	64e2                	ld	s1,24(sp)
ffffffffc02021bc:	6942                	ld	s2,16(sp)
ffffffffc02021be:	69a2                	ld	s3,8(sp)
ffffffffc02021c0:	4501                	li	a0,0
ffffffffc02021c2:	6145                	addi	sp,sp,48
ffffffffc02021c4:	8082                	ret
	assert(result != NULL);
ffffffffc02021c6:	00003697          	auipc	a3,0x3
ffffffffc02021ca:	21268693          	addi	a3,a3,530 # ffffffffc02053d8 <etext+0xd96>
ffffffffc02021ce:	00003617          	auipc	a2,0x3
ffffffffc02021d2:	88260613          	addi	a2,a2,-1918 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02021d6:	07700593          	li	a1,119
ffffffffc02021da:	00003517          	auipc	a0,0x3
ffffffffc02021de:	13650513          	addi	a0,a0,310 # ffffffffc0205310 <etext+0xcce>
ffffffffc02021e2:	f57fd0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc02021e6 <default_init>:
	elm->prev = elm->next = elm;
ffffffffc02021e6:	0001c797          	auipc	a5,0x1c
ffffffffc02021ea:	72278793          	addi	a5,a5,1826 # ffffffffc021e908 <free_area>
ffffffffc02021ee:	e79c                	sd	a5,8(a5)
ffffffffc02021f0:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void default_init(void)
{
	list_init(&free_list);
	nr_free = 0;
ffffffffc02021f2:	0007a823          	sw	zero,16(a5)
}
ffffffffc02021f6:	8082                	ret

ffffffffc02021f8 <default_nr_free_pages>:
}

static size_t default_nr_free_pages(void)
{
	return nr_free;
}
ffffffffc02021f8:	0001c517          	auipc	a0,0x1c
ffffffffc02021fc:	72056503          	lwu	a0,1824(a0) # ffffffffc021e918 <free_area+0x10>
ffffffffc0202200:	8082                	ret

ffffffffc0202202 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your
// EXERCISE 1) NOTICE: You SHOULD NOT CHANGE basic_check, default_check
// functions!
static void default_check(void)
{
ffffffffc0202202:	715d                	addi	sp,sp,-80
ffffffffc0202204:	e0a2                	sd	s0,64(sp)
	return listelm->next;
ffffffffc0202206:	0001c417          	auipc	s0,0x1c
ffffffffc020220a:	70240413          	addi	s0,s0,1794 # ffffffffc021e908 <free_area>
ffffffffc020220e:	641c                	ld	a5,8(s0)
ffffffffc0202210:	e486                	sd	ra,72(sp)
ffffffffc0202212:	fc26                	sd	s1,56(sp)
ffffffffc0202214:	f84a                	sd	s2,48(sp)
ffffffffc0202216:	f44e                	sd	s3,40(sp)
ffffffffc0202218:	f052                	sd	s4,32(sp)
ffffffffc020221a:	ec56                	sd	s5,24(sp)
ffffffffc020221c:	e85a                	sd	s6,16(sp)
ffffffffc020221e:	e45e                	sd	s7,8(sp)
ffffffffc0202220:	e062                	sd	s8,0(sp)
	int count = 0, total = 0;
	list_entry_t *le = &free_list;
	while ((le = list_next(le)) != &free_list) {
ffffffffc0202222:	2a878d63          	beq	a5,s0,ffffffffc02024dc <default_check+0x2da>
	int count = 0, total = 0;
ffffffffc0202226:	4481                	li	s1,0
ffffffffc0202228:	4901                	li	s2,0
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr)
{
	return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020222a:	ff07b703          	ld	a4,-16(a5)
		struct Page *p = le2page(le, page_link);
		assert(PageProperty(p));
ffffffffc020222e:	8b09                	andi	a4,a4,2
ffffffffc0202230:	2a070a63          	beqz	a4,ffffffffc02024e4 <default_check+0x2e2>
		count++, total += p->property;
ffffffffc0202234:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202238:	679c                	ld	a5,8(a5)
ffffffffc020223a:	2905                	addiw	s2,s2,1
ffffffffc020223c:	9cb9                	addw	s1,s1,a4
	while ((le = list_next(le)) != &free_list) {
ffffffffc020223e:	fe8796e3          	bne	a5,s0,ffffffffc020222a <default_check+0x28>
ffffffffc0202242:	89a6                	mv	s3,s1
	}
	assert(total == nr_free_pages());
ffffffffc0202244:	fcafe0ef          	jal	ra,ffffffffc0200a0e <nr_free_pages>
ffffffffc0202248:	6f351e63          	bne	a0,s3,ffffffffc0202944 <default_check+0x742>
	assert((p0 = alloc_page()) != NULL);
ffffffffc020224c:	4505                	li	a0,1
ffffffffc020224e:	eecfe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc0202252:	8aaa                	mv	s5,a0
ffffffffc0202254:	42050863          	beqz	a0,ffffffffc0202684 <default_check+0x482>
	assert((p1 = alloc_page()) != NULL);
ffffffffc0202258:	4505                	li	a0,1
ffffffffc020225a:	ee0fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc020225e:	89aa                	mv	s3,a0
ffffffffc0202260:	70050263          	beqz	a0,ffffffffc0202964 <default_check+0x762>
	assert((p2 = alloc_page()) != NULL);
ffffffffc0202264:	4505                	li	a0,1
ffffffffc0202266:	ed4fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc020226a:	8a2a                	mv	s4,a0
ffffffffc020226c:	48050c63          	beqz	a0,ffffffffc0202704 <default_check+0x502>
	assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202270:	293a8a63          	beq	s5,s3,ffffffffc0202504 <default_check+0x302>
ffffffffc0202274:	28aa8863          	beq	s5,a0,ffffffffc0202504 <default_check+0x302>
ffffffffc0202278:	28a98663          	beq	s3,a0,ffffffffc0202504 <default_check+0x302>
	assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020227c:	000aa783          	lw	a5,0(s5)
ffffffffc0202280:	2a079263          	bnez	a5,ffffffffc0202524 <default_check+0x322>
ffffffffc0202284:	0009a783          	lw	a5,0(s3)
ffffffffc0202288:	28079e63          	bnez	a5,ffffffffc0202524 <default_check+0x322>
ffffffffc020228c:	411c                	lw	a5,0(a0)
ffffffffc020228e:	28079b63          	bnez	a5,ffffffffc0202524 <default_check+0x322>
	return page - pages + nbase;
ffffffffc0202292:	0001c797          	auipc	a5,0x1c
ffffffffc0202296:	58e7b783          	ld	a5,1422(a5) # ffffffffc021e820 <pages>
ffffffffc020229a:	40fa8733          	sub	a4,s5,a5
ffffffffc020229e:	00004617          	auipc	a2,0x4
ffffffffc02022a2:	eca63603          	ld	a2,-310(a2) # ffffffffc0206168 <nbase>
ffffffffc02022a6:	8719                	srai	a4,a4,0x6
ffffffffc02022a8:	9732                	add	a4,a4,a2
	assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02022aa:	0001c697          	auipc	a3,0x1c
ffffffffc02022ae:	50e6b683          	ld	a3,1294(a3) # ffffffffc021e7b8 <npage>
ffffffffc02022b2:	06b2                	slli	a3,a3,0xc
	return page2ppn(page) << PGSHIFT;
ffffffffc02022b4:	0732                	slli	a4,a4,0xc
ffffffffc02022b6:	28d77763          	bgeu	a4,a3,ffffffffc0202544 <default_check+0x342>
	return page - pages + nbase;
ffffffffc02022ba:	40f98733          	sub	a4,s3,a5
ffffffffc02022be:	8719                	srai	a4,a4,0x6
ffffffffc02022c0:	9732                	add	a4,a4,a2
	return page2ppn(page) << PGSHIFT;
ffffffffc02022c2:	0732                	slli	a4,a4,0xc
	assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02022c4:	4cd77063          	bgeu	a4,a3,ffffffffc0202784 <default_check+0x582>
	return page - pages + nbase;
ffffffffc02022c8:	40f507b3          	sub	a5,a0,a5
ffffffffc02022cc:	8799                	srai	a5,a5,0x6
ffffffffc02022ce:	97b2                	add	a5,a5,a2
	return page2ppn(page) << PGSHIFT;
ffffffffc02022d0:	07b2                	slli	a5,a5,0xc
	assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02022d2:	30d7f963          	bgeu	a5,a3,ffffffffc02025e4 <default_check+0x3e2>
	assert(alloc_page() == NULL);
ffffffffc02022d6:	4505                	li	a0,1
	list_entry_t free_list_store = free_list;
ffffffffc02022d8:	00043c03          	ld	s8,0(s0)
ffffffffc02022dc:	00843b83          	ld	s7,8(s0)
	unsigned int nr_free_store = nr_free;
ffffffffc02022e0:	01042b03          	lw	s6,16(s0)
	elm->prev = elm->next = elm;
ffffffffc02022e4:	e400                	sd	s0,8(s0)
ffffffffc02022e6:	e000                	sd	s0,0(s0)
	nr_free = 0;
ffffffffc02022e8:	0001c797          	auipc	a5,0x1c
ffffffffc02022ec:	6207a823          	sw	zero,1584(a5) # ffffffffc021e918 <free_area+0x10>
	assert(alloc_page() == NULL);
ffffffffc02022f0:	e4afe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc02022f4:	2c051863          	bnez	a0,ffffffffc02025c4 <default_check+0x3c2>
	free_page(p0);
ffffffffc02022f8:	4585                	li	a1,1
ffffffffc02022fa:	8556                	mv	a0,s5
ffffffffc02022fc:	ed0fe0ef          	jal	ra,ffffffffc02009cc <free_pages>
	free_page(p1);
ffffffffc0202300:	4585                	li	a1,1
ffffffffc0202302:	854e                	mv	a0,s3
ffffffffc0202304:	ec8fe0ef          	jal	ra,ffffffffc02009cc <free_pages>
	free_page(p2);
ffffffffc0202308:	4585                	li	a1,1
ffffffffc020230a:	8552                	mv	a0,s4
ffffffffc020230c:	ec0fe0ef          	jal	ra,ffffffffc02009cc <free_pages>
	assert(nr_free == 3);
ffffffffc0202310:	4818                	lw	a4,16(s0)
ffffffffc0202312:	478d                	li	a5,3
ffffffffc0202314:	28f71863          	bne	a4,a5,ffffffffc02025a4 <default_check+0x3a2>
	assert((p0 = alloc_page()) != NULL);
ffffffffc0202318:	4505                	li	a0,1
ffffffffc020231a:	e20fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc020231e:	89aa                	mv	s3,a0
ffffffffc0202320:	26050263          	beqz	a0,ffffffffc0202584 <default_check+0x382>
	assert((p1 = alloc_page()) != NULL);
ffffffffc0202324:	4505                	li	a0,1
ffffffffc0202326:	e14fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc020232a:	8aaa                	mv	s5,a0
ffffffffc020232c:	3a050c63          	beqz	a0,ffffffffc02026e4 <default_check+0x4e2>
	assert((p2 = alloc_page()) != NULL);
ffffffffc0202330:	4505                	li	a0,1
ffffffffc0202332:	e08fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc0202336:	8a2a                	mv	s4,a0
ffffffffc0202338:	38050663          	beqz	a0,ffffffffc02026c4 <default_check+0x4c2>
	assert(alloc_page() == NULL);
ffffffffc020233c:	4505                	li	a0,1
ffffffffc020233e:	dfcfe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc0202342:	36051163          	bnez	a0,ffffffffc02026a4 <default_check+0x4a2>
	free_page(p0);
ffffffffc0202346:	4585                	li	a1,1
ffffffffc0202348:	854e                	mv	a0,s3
ffffffffc020234a:	e82fe0ef          	jal	ra,ffffffffc02009cc <free_pages>
	assert(!list_empty(&free_list));
ffffffffc020234e:	641c                	ld	a5,8(s0)
ffffffffc0202350:	20878a63          	beq	a5,s0,ffffffffc0202564 <default_check+0x362>
	assert((p = alloc_page()) == p0);
ffffffffc0202354:	4505                	li	a0,1
ffffffffc0202356:	de4fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc020235a:	30a99563          	bne	s3,a0,ffffffffc0202664 <default_check+0x462>
	assert(alloc_page() == NULL);
ffffffffc020235e:	4505                	li	a0,1
ffffffffc0202360:	ddafe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc0202364:	2e051063          	bnez	a0,ffffffffc0202644 <default_check+0x442>
	assert(nr_free == 0);
ffffffffc0202368:	481c                	lw	a5,16(s0)
ffffffffc020236a:	2a079d63          	bnez	a5,ffffffffc0202624 <default_check+0x422>
	free_page(p);
ffffffffc020236e:	854e                	mv	a0,s3
ffffffffc0202370:	4585                	li	a1,1
	free_list = free_list_store;
ffffffffc0202372:	01843023          	sd	s8,0(s0)
ffffffffc0202376:	01743423          	sd	s7,8(s0)
	nr_free = nr_free_store;
ffffffffc020237a:	01642823          	sw	s6,16(s0)
	free_page(p);
ffffffffc020237e:	e4efe0ef          	jal	ra,ffffffffc02009cc <free_pages>
	free_page(p1);
ffffffffc0202382:	4585                	li	a1,1
ffffffffc0202384:	8556                	mv	a0,s5
ffffffffc0202386:	e46fe0ef          	jal	ra,ffffffffc02009cc <free_pages>
	free_page(p2);
ffffffffc020238a:	4585                	li	a1,1
ffffffffc020238c:	8552                	mv	a0,s4
ffffffffc020238e:	e3efe0ef          	jal	ra,ffffffffc02009cc <free_pages>

	basic_check();

	struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0202392:	4515                	li	a0,5
ffffffffc0202394:	da6fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc0202398:	89aa                	mv	s3,a0
	assert(p0 != NULL);
ffffffffc020239a:	26050563          	beqz	a0,ffffffffc0202604 <default_check+0x402>
ffffffffc020239e:	651c                	ld	a5,8(a0)
ffffffffc02023a0:	8385                	srli	a5,a5,0x1
	assert(!PageProperty(p0));
ffffffffc02023a2:	8b85                	andi	a5,a5,1
ffffffffc02023a4:	54079063          	bnez	a5,ffffffffc02028e4 <default_check+0x6e2>

	list_entry_t free_list_store = free_list;
	list_init(&free_list);
	assert(list_empty(&free_list));
	assert(alloc_page() == NULL);
ffffffffc02023a8:	4505                	li	a0,1
	list_entry_t free_list_store = free_list;
ffffffffc02023aa:	00043b03          	ld	s6,0(s0)
ffffffffc02023ae:	00843a83          	ld	s5,8(s0)
ffffffffc02023b2:	e000                	sd	s0,0(s0)
ffffffffc02023b4:	e400                	sd	s0,8(s0)
	assert(alloc_page() == NULL);
ffffffffc02023b6:	d84fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc02023ba:	50051563          	bnez	a0,ffffffffc02028c4 <default_check+0x6c2>

	unsigned int nr_free_store = nr_free;
	nr_free = 0;

	free_pages(p0 + 2, 3);
ffffffffc02023be:	08098a13          	addi	s4,s3,128
ffffffffc02023c2:	8552                	mv	a0,s4
ffffffffc02023c4:	458d                	li	a1,3
	unsigned int nr_free_store = nr_free;
ffffffffc02023c6:	01042b83          	lw	s7,16(s0)
	nr_free = 0;
ffffffffc02023ca:	0001c797          	auipc	a5,0x1c
ffffffffc02023ce:	5407a723          	sw	zero,1358(a5) # ffffffffc021e918 <free_area+0x10>
	free_pages(p0 + 2, 3);
ffffffffc02023d2:	dfafe0ef          	jal	ra,ffffffffc02009cc <free_pages>
	assert(alloc_pages(4) == NULL);
ffffffffc02023d6:	4511                	li	a0,4
ffffffffc02023d8:	d62fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc02023dc:	4c051463          	bnez	a0,ffffffffc02028a4 <default_check+0x6a2>
ffffffffc02023e0:	0889b783          	ld	a5,136(s3)
ffffffffc02023e4:	8385                	srli	a5,a5,0x1
	assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02023e6:	8b85                	andi	a5,a5,1
ffffffffc02023e8:	48078e63          	beqz	a5,ffffffffc0202884 <default_check+0x682>
ffffffffc02023ec:	0909a703          	lw	a4,144(s3)
ffffffffc02023f0:	478d                	li	a5,3
ffffffffc02023f2:	48f71963          	bne	a4,a5,ffffffffc0202884 <default_check+0x682>
	assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02023f6:	450d                	li	a0,3
ffffffffc02023f8:	d42fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc02023fc:	8c2a                	mv	s8,a0
ffffffffc02023fe:	46050363          	beqz	a0,ffffffffc0202864 <default_check+0x662>
	assert(alloc_page() == NULL);
ffffffffc0202402:	4505                	li	a0,1
ffffffffc0202404:	d36fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc0202408:	42051e63          	bnez	a0,ffffffffc0202844 <default_check+0x642>
	assert(p0 + 2 == p1);
ffffffffc020240c:	418a1c63          	bne	s4,s8,ffffffffc0202824 <default_check+0x622>

	p2 = p0 + 1;
	free_page(p0);
ffffffffc0202410:	4585                	li	a1,1
ffffffffc0202412:	854e                	mv	a0,s3
ffffffffc0202414:	db8fe0ef          	jal	ra,ffffffffc02009cc <free_pages>
	free_pages(p1, 3);
ffffffffc0202418:	458d                	li	a1,3
ffffffffc020241a:	8552                	mv	a0,s4
ffffffffc020241c:	db0fe0ef          	jal	ra,ffffffffc02009cc <free_pages>
ffffffffc0202420:	0089b783          	ld	a5,8(s3)
	p2 = p0 + 1;
ffffffffc0202424:	04098c13          	addi	s8,s3,64
ffffffffc0202428:	8385                	srli	a5,a5,0x1
	assert(PageProperty(p0) && p0->property == 1);
ffffffffc020242a:	8b85                	andi	a5,a5,1
ffffffffc020242c:	3c078c63          	beqz	a5,ffffffffc0202804 <default_check+0x602>
ffffffffc0202430:	0109a703          	lw	a4,16(s3)
ffffffffc0202434:	4785                	li	a5,1
ffffffffc0202436:	3cf71763          	bne	a4,a5,ffffffffc0202804 <default_check+0x602>
ffffffffc020243a:	008a3783          	ld	a5,8(s4) # 1008 <_binary_obj___user_hello_out_size-0x8738>
ffffffffc020243e:	8385                	srli	a5,a5,0x1
	assert(PageProperty(p1) && p1->property == 3);
ffffffffc0202440:	8b85                	andi	a5,a5,1
ffffffffc0202442:	3a078163          	beqz	a5,ffffffffc02027e4 <default_check+0x5e2>
ffffffffc0202446:	010a2703          	lw	a4,16(s4)
ffffffffc020244a:	478d                	li	a5,3
ffffffffc020244c:	38f71c63          	bne	a4,a5,ffffffffc02027e4 <default_check+0x5e2>

	assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0202450:	4505                	li	a0,1
ffffffffc0202452:	ce8fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc0202456:	36a99763          	bne	s3,a0,ffffffffc02027c4 <default_check+0x5c2>
	free_page(p0);
ffffffffc020245a:	4585                	li	a1,1
ffffffffc020245c:	d70fe0ef          	jal	ra,ffffffffc02009cc <free_pages>
	assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0202460:	4509                	li	a0,2
ffffffffc0202462:	cd8fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc0202466:	32aa1f63          	bne	s4,a0,ffffffffc02027a4 <default_check+0x5a2>

	free_pages(p0, 2);
ffffffffc020246a:	4589                	li	a1,2
ffffffffc020246c:	d60fe0ef          	jal	ra,ffffffffc02009cc <free_pages>
	free_page(p2);
ffffffffc0202470:	4585                	li	a1,1
ffffffffc0202472:	8562                	mv	a0,s8
ffffffffc0202474:	d58fe0ef          	jal	ra,ffffffffc02009cc <free_pages>

	assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202478:	4515                	li	a0,5
ffffffffc020247a:	cc0fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc020247e:	89aa                	mv	s3,a0
ffffffffc0202480:	48050263          	beqz	a0,ffffffffc0202904 <default_check+0x702>
	assert(alloc_page() == NULL);
ffffffffc0202484:	4505                	li	a0,1
ffffffffc0202486:	cb4fe0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc020248a:	2c051d63          	bnez	a0,ffffffffc0202764 <default_check+0x562>

	assert(nr_free == 0);
ffffffffc020248e:	481c                	lw	a5,16(s0)
ffffffffc0202490:	2a079a63          	bnez	a5,ffffffffc0202744 <default_check+0x542>
	nr_free = nr_free_store;

	free_list = free_list_store;
	free_pages(p0, 5);
ffffffffc0202494:	4595                	li	a1,5
ffffffffc0202496:	854e                	mv	a0,s3
	nr_free = nr_free_store;
ffffffffc0202498:	01742823          	sw	s7,16(s0)
	free_list = free_list_store;
ffffffffc020249c:	01643023          	sd	s6,0(s0)
ffffffffc02024a0:	01543423          	sd	s5,8(s0)
	free_pages(p0, 5);
ffffffffc02024a4:	d28fe0ef          	jal	ra,ffffffffc02009cc <free_pages>
	return listelm->next;
ffffffffc02024a8:	641c                	ld	a5,8(s0)

	le = &free_list;
	while ((le = list_next(le)) != &free_list) {
ffffffffc02024aa:	00878963          	beq	a5,s0,ffffffffc02024bc <default_check+0x2ba>
		struct Page *p = le2page(le, page_link);
		count--, total -= p->property;
ffffffffc02024ae:	ff87a703          	lw	a4,-8(a5)
ffffffffc02024b2:	679c                	ld	a5,8(a5)
ffffffffc02024b4:	397d                	addiw	s2,s2,-1
ffffffffc02024b6:	9c99                	subw	s1,s1,a4
	while ((le = list_next(le)) != &free_list) {
ffffffffc02024b8:	fe879be3          	bne	a5,s0,ffffffffc02024ae <default_check+0x2ac>
	}
	assert(count == 0);
ffffffffc02024bc:	26091463          	bnez	s2,ffffffffc0202724 <default_check+0x522>
	assert(total == 0);
ffffffffc02024c0:	46049263          	bnez	s1,ffffffffc0202924 <default_check+0x722>
}
ffffffffc02024c4:	60a6                	ld	ra,72(sp)
ffffffffc02024c6:	6406                	ld	s0,64(sp)
ffffffffc02024c8:	74e2                	ld	s1,56(sp)
ffffffffc02024ca:	7942                	ld	s2,48(sp)
ffffffffc02024cc:	79a2                	ld	s3,40(sp)
ffffffffc02024ce:	7a02                	ld	s4,32(sp)
ffffffffc02024d0:	6ae2                	ld	s5,24(sp)
ffffffffc02024d2:	6b42                	ld	s6,16(sp)
ffffffffc02024d4:	6ba2                	ld	s7,8(sp)
ffffffffc02024d6:	6c02                	ld	s8,0(sp)
ffffffffc02024d8:	6161                	addi	sp,sp,80
ffffffffc02024da:	8082                	ret
	while ((le = list_next(le)) != &free_list) {
ffffffffc02024dc:	4981                	li	s3,0
	int count = 0, total = 0;
ffffffffc02024de:	4481                	li	s1,0
ffffffffc02024e0:	4901                	li	s2,0
ffffffffc02024e2:	b38d                	j	ffffffffc0202244 <default_check+0x42>
		assert(PageProperty(p));
ffffffffc02024e4:	00003697          	auipc	a3,0x3
ffffffffc02024e8:	f4468693          	addi	a3,a3,-188 # ffffffffc0205428 <etext+0xde6>
ffffffffc02024ec:	00002617          	auipc	a2,0x2
ffffffffc02024f0:	56460613          	addi	a2,a2,1380 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02024f4:	0f900593          	li	a1,249
ffffffffc02024f8:	00003517          	auipc	a0,0x3
ffffffffc02024fc:	f4050513          	addi	a0,a0,-192 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202500:	c39fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0202504:	00003697          	auipc	a3,0x3
ffffffffc0202508:	fcc68693          	addi	a3,a3,-52 # ffffffffc02054d0 <etext+0xe8e>
ffffffffc020250c:	00002617          	auipc	a2,0x2
ffffffffc0202510:	54460613          	addi	a2,a2,1348 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202514:	0c500593          	li	a1,197
ffffffffc0202518:	00003517          	auipc	a0,0x3
ffffffffc020251c:	f2050513          	addi	a0,a0,-224 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202520:	c19fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0202524:	00003697          	auipc	a3,0x3
ffffffffc0202528:	fd468693          	addi	a3,a3,-44 # ffffffffc02054f8 <etext+0xeb6>
ffffffffc020252c:	00002617          	auipc	a2,0x2
ffffffffc0202530:	52460613          	addi	a2,a2,1316 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202534:	0c600593          	li	a1,198
ffffffffc0202538:	00003517          	auipc	a0,0x3
ffffffffc020253c:	f0050513          	addi	a0,a0,-256 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202540:	bf9fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0202544:	00003697          	auipc	a3,0x3
ffffffffc0202548:	ff468693          	addi	a3,a3,-12 # ffffffffc0205538 <etext+0xef6>
ffffffffc020254c:	00002617          	auipc	a2,0x2
ffffffffc0202550:	50460613          	addi	a2,a2,1284 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202554:	0c800593          	li	a1,200
ffffffffc0202558:	00003517          	auipc	a0,0x3
ffffffffc020255c:	ee050513          	addi	a0,a0,-288 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202560:	bd9fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(!list_empty(&free_list));
ffffffffc0202564:	00003697          	auipc	a3,0x3
ffffffffc0202568:	05c68693          	addi	a3,a3,92 # ffffffffc02055c0 <etext+0xf7e>
ffffffffc020256c:	00002617          	auipc	a2,0x2
ffffffffc0202570:	4e460613          	addi	a2,a2,1252 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202574:	0e100593          	li	a1,225
ffffffffc0202578:	00003517          	auipc	a0,0x3
ffffffffc020257c:	ec050513          	addi	a0,a0,-320 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202580:	bb9fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert((p0 = alloc_page()) != NULL);
ffffffffc0202584:	00003697          	auipc	a3,0x3
ffffffffc0202588:	eec68693          	addi	a3,a3,-276 # ffffffffc0205470 <etext+0xe2e>
ffffffffc020258c:	00002617          	auipc	a2,0x2
ffffffffc0202590:	4c460613          	addi	a2,a2,1220 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202594:	0da00593          	li	a1,218
ffffffffc0202598:	00003517          	auipc	a0,0x3
ffffffffc020259c:	ea050513          	addi	a0,a0,-352 # ffffffffc0205438 <etext+0xdf6>
ffffffffc02025a0:	b99fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(nr_free == 3);
ffffffffc02025a4:	00003697          	auipc	a3,0x3
ffffffffc02025a8:	00c68693          	addi	a3,a3,12 # ffffffffc02055b0 <etext+0xf6e>
ffffffffc02025ac:	00002617          	auipc	a2,0x2
ffffffffc02025b0:	4a460613          	addi	a2,a2,1188 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02025b4:	0d800593          	li	a1,216
ffffffffc02025b8:	00003517          	auipc	a0,0x3
ffffffffc02025bc:	e8050513          	addi	a0,a0,-384 # ffffffffc0205438 <etext+0xdf6>
ffffffffc02025c0:	b79fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(alloc_page() == NULL);
ffffffffc02025c4:	00003697          	auipc	a3,0x3
ffffffffc02025c8:	fd468693          	addi	a3,a3,-44 # ffffffffc0205598 <etext+0xf56>
ffffffffc02025cc:	00002617          	auipc	a2,0x2
ffffffffc02025d0:	48460613          	addi	a2,a2,1156 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02025d4:	0d300593          	li	a1,211
ffffffffc02025d8:	00003517          	auipc	a0,0x3
ffffffffc02025dc:	e6050513          	addi	a0,a0,-416 # ffffffffc0205438 <etext+0xdf6>
ffffffffc02025e0:	b59fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02025e4:	00003697          	auipc	a3,0x3
ffffffffc02025e8:	f9468693          	addi	a3,a3,-108 # ffffffffc0205578 <etext+0xf36>
ffffffffc02025ec:	00002617          	auipc	a2,0x2
ffffffffc02025f0:	46460613          	addi	a2,a2,1124 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02025f4:	0ca00593          	li	a1,202
ffffffffc02025f8:	00003517          	auipc	a0,0x3
ffffffffc02025fc:	e4050513          	addi	a0,a0,-448 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202600:	b39fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(p0 != NULL);
ffffffffc0202604:	00003697          	auipc	a3,0x3
ffffffffc0202608:	00468693          	addi	a3,a3,4 # ffffffffc0205608 <etext+0xfc6>
ffffffffc020260c:	00002617          	auipc	a2,0x2
ffffffffc0202610:	44460613          	addi	a2,a2,1092 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202614:	10100593          	li	a1,257
ffffffffc0202618:	00003517          	auipc	a0,0x3
ffffffffc020261c:	e2050513          	addi	a0,a0,-480 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202620:	b19fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(nr_free == 0);
ffffffffc0202624:	00003697          	auipc	a3,0x3
ffffffffc0202628:	fd468693          	addi	a3,a3,-44 # ffffffffc02055f8 <etext+0xfb6>
ffffffffc020262c:	00002617          	auipc	a2,0x2
ffffffffc0202630:	42460613          	addi	a2,a2,1060 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202634:	0e700593          	li	a1,231
ffffffffc0202638:	00003517          	auipc	a0,0x3
ffffffffc020263c:	e0050513          	addi	a0,a0,-512 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202640:	af9fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(alloc_page() == NULL);
ffffffffc0202644:	00003697          	auipc	a3,0x3
ffffffffc0202648:	f5468693          	addi	a3,a3,-172 # ffffffffc0205598 <etext+0xf56>
ffffffffc020264c:	00002617          	auipc	a2,0x2
ffffffffc0202650:	40460613          	addi	a2,a2,1028 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202654:	0e500593          	li	a1,229
ffffffffc0202658:	00003517          	auipc	a0,0x3
ffffffffc020265c:	de050513          	addi	a0,a0,-544 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202660:	ad9fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert((p = alloc_page()) == p0);
ffffffffc0202664:	00003697          	auipc	a3,0x3
ffffffffc0202668:	f7468693          	addi	a3,a3,-140 # ffffffffc02055d8 <etext+0xf96>
ffffffffc020266c:	00002617          	auipc	a2,0x2
ffffffffc0202670:	3e460613          	addi	a2,a2,996 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202674:	0e400593          	li	a1,228
ffffffffc0202678:	00003517          	auipc	a0,0x3
ffffffffc020267c:	dc050513          	addi	a0,a0,-576 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202680:	ab9fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert((p0 = alloc_page()) != NULL);
ffffffffc0202684:	00003697          	auipc	a3,0x3
ffffffffc0202688:	dec68693          	addi	a3,a3,-532 # ffffffffc0205470 <etext+0xe2e>
ffffffffc020268c:	00002617          	auipc	a2,0x2
ffffffffc0202690:	3c460613          	addi	a2,a2,964 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202694:	0c100593          	li	a1,193
ffffffffc0202698:	00003517          	auipc	a0,0x3
ffffffffc020269c:	da050513          	addi	a0,a0,-608 # ffffffffc0205438 <etext+0xdf6>
ffffffffc02026a0:	a99fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(alloc_page() == NULL);
ffffffffc02026a4:	00003697          	auipc	a3,0x3
ffffffffc02026a8:	ef468693          	addi	a3,a3,-268 # ffffffffc0205598 <etext+0xf56>
ffffffffc02026ac:	00002617          	auipc	a2,0x2
ffffffffc02026b0:	3a460613          	addi	a2,a2,932 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02026b4:	0de00593          	li	a1,222
ffffffffc02026b8:	00003517          	auipc	a0,0x3
ffffffffc02026bc:	d8050513          	addi	a0,a0,-640 # ffffffffc0205438 <etext+0xdf6>
ffffffffc02026c0:	a79fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert((p2 = alloc_page()) != NULL);
ffffffffc02026c4:	00003697          	auipc	a3,0x3
ffffffffc02026c8:	dec68693          	addi	a3,a3,-532 # ffffffffc02054b0 <etext+0xe6e>
ffffffffc02026cc:	00002617          	auipc	a2,0x2
ffffffffc02026d0:	38460613          	addi	a2,a2,900 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02026d4:	0dc00593          	li	a1,220
ffffffffc02026d8:	00003517          	auipc	a0,0x3
ffffffffc02026dc:	d6050513          	addi	a0,a0,-672 # ffffffffc0205438 <etext+0xdf6>
ffffffffc02026e0:	a59fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert((p1 = alloc_page()) != NULL);
ffffffffc02026e4:	00003697          	auipc	a3,0x3
ffffffffc02026e8:	dac68693          	addi	a3,a3,-596 # ffffffffc0205490 <etext+0xe4e>
ffffffffc02026ec:	00002617          	auipc	a2,0x2
ffffffffc02026f0:	36460613          	addi	a2,a2,868 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02026f4:	0db00593          	li	a1,219
ffffffffc02026f8:	00003517          	auipc	a0,0x3
ffffffffc02026fc:	d4050513          	addi	a0,a0,-704 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202700:	a39fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert((p2 = alloc_page()) != NULL);
ffffffffc0202704:	00003697          	auipc	a3,0x3
ffffffffc0202708:	dac68693          	addi	a3,a3,-596 # ffffffffc02054b0 <etext+0xe6e>
ffffffffc020270c:	00002617          	auipc	a2,0x2
ffffffffc0202710:	34460613          	addi	a2,a2,836 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202714:	0c300593          	li	a1,195
ffffffffc0202718:	00003517          	auipc	a0,0x3
ffffffffc020271c:	d2050513          	addi	a0,a0,-736 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202720:	a19fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(count == 0);
ffffffffc0202724:	00003697          	auipc	a3,0x3
ffffffffc0202728:	03468693          	addi	a3,a3,52 # ffffffffc0205758 <etext+0x1116>
ffffffffc020272c:	00002617          	auipc	a2,0x2
ffffffffc0202730:	32460613          	addi	a2,a2,804 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202734:	12e00593          	li	a1,302
ffffffffc0202738:	00003517          	auipc	a0,0x3
ffffffffc020273c:	d0050513          	addi	a0,a0,-768 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202740:	9f9fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(nr_free == 0);
ffffffffc0202744:	00003697          	auipc	a3,0x3
ffffffffc0202748:	eb468693          	addi	a3,a3,-332 # ffffffffc02055f8 <etext+0xfb6>
ffffffffc020274c:	00002617          	auipc	a2,0x2
ffffffffc0202750:	30460613          	addi	a2,a2,772 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202754:	12300593          	li	a1,291
ffffffffc0202758:	00003517          	auipc	a0,0x3
ffffffffc020275c:	ce050513          	addi	a0,a0,-800 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202760:	9d9fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(alloc_page() == NULL);
ffffffffc0202764:	00003697          	auipc	a3,0x3
ffffffffc0202768:	e3468693          	addi	a3,a3,-460 # ffffffffc0205598 <etext+0xf56>
ffffffffc020276c:	00002617          	auipc	a2,0x2
ffffffffc0202770:	2e460613          	addi	a2,a2,740 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202774:	12100593          	li	a1,289
ffffffffc0202778:	00003517          	auipc	a0,0x3
ffffffffc020277c:	cc050513          	addi	a0,a0,-832 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202780:	9b9fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0202784:	00003697          	auipc	a3,0x3
ffffffffc0202788:	dd468693          	addi	a3,a3,-556 # ffffffffc0205558 <etext+0xf16>
ffffffffc020278c:	00002617          	auipc	a2,0x2
ffffffffc0202790:	2c460613          	addi	a2,a2,708 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202794:	0c900593          	li	a1,201
ffffffffc0202798:	00003517          	auipc	a0,0x3
ffffffffc020279c:	ca050513          	addi	a0,a0,-864 # ffffffffc0205438 <etext+0xdf6>
ffffffffc02027a0:	999fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02027a4:	00003697          	auipc	a3,0x3
ffffffffc02027a8:	f7468693          	addi	a3,a3,-140 # ffffffffc0205718 <etext+0x10d6>
ffffffffc02027ac:	00002617          	auipc	a2,0x2
ffffffffc02027b0:	2a460613          	addi	a2,a2,676 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02027b4:	11b00593          	li	a1,283
ffffffffc02027b8:	00003517          	auipc	a0,0x3
ffffffffc02027bc:	c8050513          	addi	a0,a0,-896 # ffffffffc0205438 <etext+0xdf6>
ffffffffc02027c0:	979fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02027c4:	00003697          	auipc	a3,0x3
ffffffffc02027c8:	f3468693          	addi	a3,a3,-204 # ffffffffc02056f8 <etext+0x10b6>
ffffffffc02027cc:	00002617          	auipc	a2,0x2
ffffffffc02027d0:	28460613          	addi	a2,a2,644 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02027d4:	11900593          	li	a1,281
ffffffffc02027d8:	00003517          	auipc	a0,0x3
ffffffffc02027dc:	c6050513          	addi	a0,a0,-928 # ffffffffc0205438 <etext+0xdf6>
ffffffffc02027e0:	959fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(PageProperty(p1) && p1->property == 3);
ffffffffc02027e4:	00003697          	auipc	a3,0x3
ffffffffc02027e8:	eec68693          	addi	a3,a3,-276 # ffffffffc02056d0 <etext+0x108e>
ffffffffc02027ec:	00002617          	auipc	a2,0x2
ffffffffc02027f0:	26460613          	addi	a2,a2,612 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02027f4:	11700593          	li	a1,279
ffffffffc02027f8:	00003517          	auipc	a0,0x3
ffffffffc02027fc:	c4050513          	addi	a0,a0,-960 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202800:	939fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(PageProperty(p0) && p0->property == 1);
ffffffffc0202804:	00003697          	auipc	a3,0x3
ffffffffc0202808:	ea468693          	addi	a3,a3,-348 # ffffffffc02056a8 <etext+0x1066>
ffffffffc020280c:	00002617          	auipc	a2,0x2
ffffffffc0202810:	24460613          	addi	a2,a2,580 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202814:	11600593          	li	a1,278
ffffffffc0202818:	00003517          	auipc	a0,0x3
ffffffffc020281c:	c2050513          	addi	a0,a0,-992 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202820:	919fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(p0 + 2 == p1);
ffffffffc0202824:	00003697          	auipc	a3,0x3
ffffffffc0202828:	e7468693          	addi	a3,a3,-396 # ffffffffc0205698 <etext+0x1056>
ffffffffc020282c:	00002617          	auipc	a2,0x2
ffffffffc0202830:	22460613          	addi	a2,a2,548 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202834:	11100593          	li	a1,273
ffffffffc0202838:	00003517          	auipc	a0,0x3
ffffffffc020283c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202840:	8f9fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(alloc_page() == NULL);
ffffffffc0202844:	00003697          	auipc	a3,0x3
ffffffffc0202848:	d5468693          	addi	a3,a3,-684 # ffffffffc0205598 <etext+0xf56>
ffffffffc020284c:	00002617          	auipc	a2,0x2
ffffffffc0202850:	20460613          	addi	a2,a2,516 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202854:	11000593          	li	a1,272
ffffffffc0202858:	00003517          	auipc	a0,0x3
ffffffffc020285c:	be050513          	addi	a0,a0,-1056 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202860:	8d9fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0202864:	00003697          	auipc	a3,0x3
ffffffffc0202868:	e1468693          	addi	a3,a3,-492 # ffffffffc0205678 <etext+0x1036>
ffffffffc020286c:	00002617          	auipc	a2,0x2
ffffffffc0202870:	1e460613          	addi	a2,a2,484 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202874:	10f00593          	li	a1,271
ffffffffc0202878:	00003517          	auipc	a0,0x3
ffffffffc020287c:	bc050513          	addi	a0,a0,-1088 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202880:	8b9fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0202884:	00003697          	auipc	a3,0x3
ffffffffc0202888:	dc468693          	addi	a3,a3,-572 # ffffffffc0205648 <etext+0x1006>
ffffffffc020288c:	00002617          	auipc	a2,0x2
ffffffffc0202890:	1c460613          	addi	a2,a2,452 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202894:	10e00593          	li	a1,270
ffffffffc0202898:	00003517          	auipc	a0,0x3
ffffffffc020289c:	ba050513          	addi	a0,a0,-1120 # ffffffffc0205438 <etext+0xdf6>
ffffffffc02028a0:	899fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(alloc_pages(4) == NULL);
ffffffffc02028a4:	00003697          	auipc	a3,0x3
ffffffffc02028a8:	d8c68693          	addi	a3,a3,-628 # ffffffffc0205630 <etext+0xfee>
ffffffffc02028ac:	00002617          	auipc	a2,0x2
ffffffffc02028b0:	1a460613          	addi	a2,a2,420 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02028b4:	10d00593          	li	a1,269
ffffffffc02028b8:	00003517          	auipc	a0,0x3
ffffffffc02028bc:	b8050513          	addi	a0,a0,-1152 # ffffffffc0205438 <etext+0xdf6>
ffffffffc02028c0:	879fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(alloc_page() == NULL);
ffffffffc02028c4:	00003697          	auipc	a3,0x3
ffffffffc02028c8:	cd468693          	addi	a3,a3,-812 # ffffffffc0205598 <etext+0xf56>
ffffffffc02028cc:	00002617          	auipc	a2,0x2
ffffffffc02028d0:	18460613          	addi	a2,a2,388 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02028d4:	10700593          	li	a1,263
ffffffffc02028d8:	00003517          	auipc	a0,0x3
ffffffffc02028dc:	b6050513          	addi	a0,a0,-1184 # ffffffffc0205438 <etext+0xdf6>
ffffffffc02028e0:	859fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(!PageProperty(p0));
ffffffffc02028e4:	00003697          	auipc	a3,0x3
ffffffffc02028e8:	d3468693          	addi	a3,a3,-716 # ffffffffc0205618 <etext+0xfd6>
ffffffffc02028ec:	00002617          	auipc	a2,0x2
ffffffffc02028f0:	16460613          	addi	a2,a2,356 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02028f4:	10200593          	li	a1,258
ffffffffc02028f8:	00003517          	auipc	a0,0x3
ffffffffc02028fc:	b4050513          	addi	a0,a0,-1216 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202900:	839fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0202904:	00003697          	auipc	a3,0x3
ffffffffc0202908:	e3468693          	addi	a3,a3,-460 # ffffffffc0205738 <etext+0x10f6>
ffffffffc020290c:	00002617          	auipc	a2,0x2
ffffffffc0202910:	14460613          	addi	a2,a2,324 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202914:	12000593          	li	a1,288
ffffffffc0202918:	00003517          	auipc	a0,0x3
ffffffffc020291c:	b2050513          	addi	a0,a0,-1248 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202920:	819fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(total == 0);
ffffffffc0202924:	00003697          	auipc	a3,0x3
ffffffffc0202928:	e4468693          	addi	a3,a3,-444 # ffffffffc0205768 <etext+0x1126>
ffffffffc020292c:	00002617          	auipc	a2,0x2
ffffffffc0202930:	12460613          	addi	a2,a2,292 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202934:	12f00593          	li	a1,303
ffffffffc0202938:	00003517          	auipc	a0,0x3
ffffffffc020293c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202940:	ff8fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(total == nr_free_pages());
ffffffffc0202944:	00003697          	auipc	a3,0x3
ffffffffc0202948:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0205450 <etext+0xe0e>
ffffffffc020294c:	00002617          	auipc	a2,0x2
ffffffffc0202950:	10460613          	addi	a2,a2,260 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202954:	0fc00593          	li	a1,252
ffffffffc0202958:	00003517          	auipc	a0,0x3
ffffffffc020295c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202960:	fd8fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert((p1 = alloc_page()) != NULL);
ffffffffc0202964:	00003697          	auipc	a3,0x3
ffffffffc0202968:	b2c68693          	addi	a3,a3,-1236 # ffffffffc0205490 <etext+0xe4e>
ffffffffc020296c:	00002617          	auipc	a2,0x2
ffffffffc0202970:	0e460613          	addi	a2,a2,228 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202974:	0c200593          	li	a1,194
ffffffffc0202978:	00003517          	auipc	a0,0x3
ffffffffc020297c:	ac050513          	addi	a0,a0,-1344 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202980:	fb8fd0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0202984 <default_free_pages>:
{
ffffffffc0202984:	1141                	addi	sp,sp,-16
ffffffffc0202986:	e406                	sd	ra,8(sp)
	assert(n > 0);
ffffffffc0202988:	12058f63          	beqz	a1,ffffffffc0202ac6 <default_free_pages+0x142>
	for (; p != base + n; p++) {
ffffffffc020298c:	00659693          	slli	a3,a1,0x6
ffffffffc0202990:	96aa                	add	a3,a3,a0
ffffffffc0202992:	87aa                	mv	a5,a0
ffffffffc0202994:	02d50263          	beq	a0,a3,ffffffffc02029b8 <default_free_pages+0x34>
ffffffffc0202998:	6798                	ld	a4,8(a5)
		assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020299a:	8b05                	andi	a4,a4,1
ffffffffc020299c:	10071563          	bnez	a4,ffffffffc0202aa6 <default_free_pages+0x122>
ffffffffc02029a0:	6798                	ld	a4,8(a5)
ffffffffc02029a2:	8b09                	andi	a4,a4,2
ffffffffc02029a4:	10071163          	bnez	a4,ffffffffc0202aa6 <default_free_pages+0x122>
		p->flags = 0;
ffffffffc02029a8:	0007b423          	sd	zero,8(a5)
	page->ref = val;
ffffffffc02029ac:	0007a023          	sw	zero,0(a5)
	for (; p != base + n; p++) {
ffffffffc02029b0:	04078793          	addi	a5,a5,64
ffffffffc02029b4:	fed792e3          	bne	a5,a3,ffffffffc0202998 <default_free_pages+0x14>
	base->property = n;
ffffffffc02029b8:	2581                	sext.w	a1,a1
ffffffffc02029ba:	c90c                	sw	a1,16(a0)
	SetPageProperty(base);
ffffffffc02029bc:	00850893          	addi	a7,a0,8
	__op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02029c0:	4789                	li	a5,2
ffffffffc02029c2:	40f8b02f          	amoor.d	zero,a5,(a7)
	nr_free += n;
ffffffffc02029c6:	0001c697          	auipc	a3,0x1c
ffffffffc02029ca:	f4268693          	addi	a3,a3,-190 # ffffffffc021e908 <free_area>
ffffffffc02029ce:	4a98                	lw	a4,16(a3)
	return list->next == list;
ffffffffc02029d0:	669c                	ld	a5,8(a3)
ffffffffc02029d2:	01850613          	addi	a2,a0,24
ffffffffc02029d6:	9db9                	addw	a1,a1,a4
ffffffffc02029d8:	ca8c                	sw	a1,16(a3)
	if (list_empty(&free_list)) {
ffffffffc02029da:	08d78f63          	beq	a5,a3,ffffffffc0202a78 <default_free_pages+0xf4>
			struct Page *page = le2page(le, page_link);
ffffffffc02029de:	fe878713          	addi	a4,a5,-24
ffffffffc02029e2:	0006b803          	ld	a6,0(a3)
	if (list_empty(&free_list)) {
ffffffffc02029e6:	4581                	li	a1,0
			if (base < page) {
ffffffffc02029e8:	00e56a63          	bltu	a0,a4,ffffffffc02029fc <default_free_pages+0x78>
	return listelm->next;
ffffffffc02029ec:	6798                	ld	a4,8(a5)
			} else if (list_next(le) == &free_list) {
ffffffffc02029ee:	04d70a63          	beq	a4,a3,ffffffffc0202a42 <default_free_pages+0xbe>
	for (; p != base + n; p++) {
ffffffffc02029f2:	87ba                	mv	a5,a4
			struct Page *page = le2page(le, page_link);
ffffffffc02029f4:	fe878713          	addi	a4,a5,-24
			if (base < page) {
ffffffffc02029f8:	fee57ae3          	bgeu	a0,a4,ffffffffc02029ec <default_free_pages+0x68>
ffffffffc02029fc:	c199                	beqz	a1,ffffffffc0202a02 <default_free_pages+0x7e>
ffffffffc02029fe:	0106b023          	sd	a6,0(a3)
	__list_add(elm, listelm->prev, listelm);
ffffffffc0202a02:	6398                	ld	a4,0(a5)
	prev->next = next->prev = elm;
ffffffffc0202a04:	e390                	sd	a2,0(a5)
ffffffffc0202a06:	e710                	sd	a2,8(a4)
	elm->next = next;
ffffffffc0202a08:	f11c                	sd	a5,32(a0)
	elm->prev = prev;
ffffffffc0202a0a:	ed18                	sd	a4,24(a0)
	if (le != &free_list) {
ffffffffc0202a0c:	00d70c63          	beq	a4,a3,ffffffffc0202a24 <default_free_pages+0xa0>
		if (p + p->property == base) {
ffffffffc0202a10:	ff872583          	lw	a1,-8(a4)
		p = le2page(le, page_link);
ffffffffc0202a14:	fe870613          	addi	a2,a4,-24
		if (p + p->property == base) {
ffffffffc0202a18:	02059793          	slli	a5,a1,0x20
ffffffffc0202a1c:	83e9                	srli	a5,a5,0x1a
ffffffffc0202a1e:	97b2                	add	a5,a5,a2
ffffffffc0202a20:	02f50b63          	beq	a0,a5,ffffffffc0202a56 <default_free_pages+0xd2>
ffffffffc0202a24:	7118                	ld	a4,32(a0)
	if (le != &free_list) {
ffffffffc0202a26:	00d70b63          	beq	a4,a3,ffffffffc0202a3c <default_free_pages+0xb8>
		if (base + base->property == p) {
ffffffffc0202a2a:	4910                	lw	a2,16(a0)
		p = le2page(le, page_link);
ffffffffc0202a2c:	fe870693          	addi	a3,a4,-24
		if (base + base->property == p) {
ffffffffc0202a30:	02061793          	slli	a5,a2,0x20
ffffffffc0202a34:	83e9                	srli	a5,a5,0x1a
ffffffffc0202a36:	97aa                	add	a5,a5,a0
ffffffffc0202a38:	04f68763          	beq	a3,a5,ffffffffc0202a86 <default_free_pages+0x102>
}
ffffffffc0202a3c:	60a2                	ld	ra,8(sp)
ffffffffc0202a3e:	0141                	addi	sp,sp,16
ffffffffc0202a40:	8082                	ret
	prev->next = next->prev = elm;
ffffffffc0202a42:	e790                	sd	a2,8(a5)
	elm->next = next;
ffffffffc0202a44:	f114                	sd	a3,32(a0)
	return listelm->next;
ffffffffc0202a46:	6798                	ld	a4,8(a5)
	elm->prev = prev;
ffffffffc0202a48:	ed1c                	sd	a5,24(a0)
		while ((le = list_next(le)) != &free_list) {
ffffffffc0202a4a:	02d70463          	beq	a4,a3,ffffffffc0202a72 <default_free_pages+0xee>
	prev->next = next->prev = elm;
ffffffffc0202a4e:	8832                	mv	a6,a2
ffffffffc0202a50:	4585                	li	a1,1
	for (; p != base + n; p++) {
ffffffffc0202a52:	87ba                	mv	a5,a4
ffffffffc0202a54:	b745                	j	ffffffffc02029f4 <default_free_pages+0x70>
			p->property += base->property;
ffffffffc0202a56:	491c                	lw	a5,16(a0)
ffffffffc0202a58:	9dbd                	addw	a1,a1,a5
ffffffffc0202a5a:	feb72c23          	sw	a1,-8(a4)
	__op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202a5e:	57f5                	li	a5,-3
ffffffffc0202a60:	60f8b02f          	amoand.d	zero,a5,(a7)
	__list_del(listelm->prev, listelm->next);
ffffffffc0202a64:	6d0c                	ld	a1,24(a0)
ffffffffc0202a66:	711c                	ld	a5,32(a0)
			base = p;
ffffffffc0202a68:	8532                	mv	a0,a2
	prev->next = next;
ffffffffc0202a6a:	e59c                	sd	a5,8(a1)
	next->prev = prev;
ffffffffc0202a6c:	6718                	ld	a4,8(a4)
ffffffffc0202a6e:	e38c                	sd	a1,0(a5)
ffffffffc0202a70:	bf5d                	j	ffffffffc0202a26 <default_free_pages+0xa2>
ffffffffc0202a72:	e290                	sd	a2,0(a3)
		while ((le = list_next(le)) != &free_list) {
ffffffffc0202a74:	873e                	mv	a4,a5
ffffffffc0202a76:	bf69                	j	ffffffffc0202a10 <default_free_pages+0x8c>
}
ffffffffc0202a78:	60a2                	ld	ra,8(sp)
	prev->next = next->prev = elm;
ffffffffc0202a7a:	e390                	sd	a2,0(a5)
ffffffffc0202a7c:	e790                	sd	a2,8(a5)
	elm->next = next;
ffffffffc0202a7e:	f11c                	sd	a5,32(a0)
	elm->prev = prev;
ffffffffc0202a80:	ed1c                	sd	a5,24(a0)
ffffffffc0202a82:	0141                	addi	sp,sp,16
ffffffffc0202a84:	8082                	ret
			base->property += p->property;
ffffffffc0202a86:	ff872783          	lw	a5,-8(a4)
ffffffffc0202a8a:	ff070693          	addi	a3,a4,-16
ffffffffc0202a8e:	9e3d                	addw	a2,a2,a5
ffffffffc0202a90:	c910                	sw	a2,16(a0)
ffffffffc0202a92:	57f5                	li	a5,-3
ffffffffc0202a94:	60f6b02f          	amoand.d	zero,a5,(a3)
	__list_del(listelm->prev, listelm->next);
ffffffffc0202a98:	6314                	ld	a3,0(a4)
ffffffffc0202a9a:	671c                	ld	a5,8(a4)
}
ffffffffc0202a9c:	60a2                	ld	ra,8(sp)
	prev->next = next;
ffffffffc0202a9e:	e69c                	sd	a5,8(a3)
	next->prev = prev;
ffffffffc0202aa0:	e394                	sd	a3,0(a5)
ffffffffc0202aa2:	0141                	addi	sp,sp,16
ffffffffc0202aa4:	8082                	ret
		assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0202aa6:	00003697          	auipc	a3,0x3
ffffffffc0202aaa:	cda68693          	addi	a3,a3,-806 # ffffffffc0205780 <etext+0x113e>
ffffffffc0202aae:	00002617          	auipc	a2,0x2
ffffffffc0202ab2:	fa260613          	addi	a2,a2,-94 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202ab6:	08b00593          	li	a1,139
ffffffffc0202aba:	00003517          	auipc	a0,0x3
ffffffffc0202abe:	97e50513          	addi	a0,a0,-1666 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202ac2:	e76fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(n > 0);
ffffffffc0202ac6:	00003697          	auipc	a3,0x3
ffffffffc0202aca:	cb268693          	addi	a3,a3,-846 # ffffffffc0205778 <etext+0x1136>
ffffffffc0202ace:	00002617          	auipc	a2,0x2
ffffffffc0202ad2:	f8260613          	addi	a2,a2,-126 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202ad6:	08800593          	li	a1,136
ffffffffc0202ada:	00003517          	auipc	a0,0x3
ffffffffc0202ade:	95e50513          	addi	a0,a0,-1698 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202ae2:	e56fd0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0202ae6 <default_alloc_pages>:
	assert(n > 0);
ffffffffc0202ae6:	c941                	beqz	a0,ffffffffc0202b76 <default_alloc_pages+0x90>
	if (n > nr_free) {
ffffffffc0202ae8:	0001c597          	auipc	a1,0x1c
ffffffffc0202aec:	e2058593          	addi	a1,a1,-480 # ffffffffc021e908 <free_area>
ffffffffc0202af0:	0105a803          	lw	a6,16(a1)
ffffffffc0202af4:	872a                	mv	a4,a0
ffffffffc0202af6:	02081793          	slli	a5,a6,0x20
ffffffffc0202afa:	9381                	srli	a5,a5,0x20
ffffffffc0202afc:	00a7ee63          	bltu	a5,a0,ffffffffc0202b18 <default_alloc_pages+0x32>
	list_entry_t *le = &free_list;
ffffffffc0202b00:	87ae                	mv	a5,a1
ffffffffc0202b02:	a801                	j	ffffffffc0202b12 <default_alloc_pages+0x2c>
		if (p->property >= n) {
ffffffffc0202b04:	ff87a683          	lw	a3,-8(a5)
ffffffffc0202b08:	02069613          	slli	a2,a3,0x20
ffffffffc0202b0c:	9201                	srli	a2,a2,0x20
ffffffffc0202b0e:	00e67763          	bgeu	a2,a4,ffffffffc0202b1c <default_alloc_pages+0x36>
	return listelm->next;
ffffffffc0202b12:	679c                	ld	a5,8(a5)
	while ((le = list_next(le)) != &free_list) {
ffffffffc0202b14:	feb798e3          	bne	a5,a1,ffffffffc0202b04 <default_alloc_pages+0x1e>
		return NULL;
ffffffffc0202b18:	4501                	li	a0,0
}
ffffffffc0202b1a:	8082                	ret
	return listelm->prev;
ffffffffc0202b1c:	0007b883          	ld	a7,0(a5)
	__list_del(listelm->prev, listelm->next);
ffffffffc0202b20:	0087b303          	ld	t1,8(a5)
		struct Page *p = le2page(le, page_link);
ffffffffc0202b24:	fe878513          	addi	a0,a5,-24
	prev->next = next;
ffffffffc0202b28:	00070e1b          	sext.w	t3,a4
ffffffffc0202b2c:	0068b423          	sd	t1,8(a7)
	next->prev = prev;
ffffffffc0202b30:	01133023          	sd	a7,0(t1)
		if (page->property > n) {
ffffffffc0202b34:	02c77863          	bgeu	a4,a2,ffffffffc0202b64 <default_alloc_pages+0x7e>
			struct Page *p = page + n;
ffffffffc0202b38:	071a                	slli	a4,a4,0x6
ffffffffc0202b3a:	972a                	add	a4,a4,a0
			p->property = page->property - n;
ffffffffc0202b3c:	41c686bb          	subw	a3,a3,t3
ffffffffc0202b40:	cb14                	sw	a3,16(a4)
	__op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202b42:	00870613          	addi	a2,a4,8
ffffffffc0202b46:	4689                	li	a3,2
ffffffffc0202b48:	40d6302f          	amoor.d	zero,a3,(a2)
	__list_add(elm, listelm, listelm->next);
ffffffffc0202b4c:	0088b683          	ld	a3,8(a7)
			list_add(prev, &(p->page_link));
ffffffffc0202b50:	01870613          	addi	a2,a4,24
	prev->next = next->prev = elm;
ffffffffc0202b54:	0105a803          	lw	a6,16(a1)
ffffffffc0202b58:	e290                	sd	a2,0(a3)
ffffffffc0202b5a:	00c8b423          	sd	a2,8(a7)
	elm->next = next;
ffffffffc0202b5e:	f314                	sd	a3,32(a4)
	elm->prev = prev;
ffffffffc0202b60:	01173c23          	sd	a7,24(a4)
		nr_free -= n;
ffffffffc0202b64:	41c8083b          	subw	a6,a6,t3
ffffffffc0202b68:	0105a823          	sw	a6,16(a1)
	__op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0202b6c:	5775                	li	a4,-3
ffffffffc0202b6e:	17c1                	addi	a5,a5,-16
ffffffffc0202b70:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0202b74:	8082                	ret
{
ffffffffc0202b76:	1141                	addi	sp,sp,-16
	assert(n > 0);
ffffffffc0202b78:	00003697          	auipc	a3,0x3
ffffffffc0202b7c:	c0068693          	addi	a3,a3,-1024 # ffffffffc0205778 <etext+0x1136>
ffffffffc0202b80:	00002617          	auipc	a2,0x2
ffffffffc0202b84:	ed060613          	addi	a2,a2,-304 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202b88:	06a00593          	li	a1,106
ffffffffc0202b8c:	00003517          	auipc	a0,0x3
ffffffffc0202b90:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0205438 <etext+0xdf6>
{
ffffffffc0202b94:	e406                	sd	ra,8(sp)
	assert(n > 0);
ffffffffc0202b96:	da2fd0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0202b9a <default_init_memmap>:
{
ffffffffc0202b9a:	1141                	addi	sp,sp,-16
ffffffffc0202b9c:	e406                	sd	ra,8(sp)
	assert(n > 0);
ffffffffc0202b9e:	c5f1                	beqz	a1,ffffffffc0202c6a <default_init_memmap+0xd0>
	for (; p != base + n; p++) {
ffffffffc0202ba0:	00659693          	slli	a3,a1,0x6
ffffffffc0202ba4:	96aa                	add	a3,a3,a0
ffffffffc0202ba6:	87aa                	mv	a5,a0
ffffffffc0202ba8:	00d50f63          	beq	a0,a3,ffffffffc0202bc6 <default_init_memmap+0x2c>
	return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202bac:	6798                	ld	a4,8(a5)
		assert(PageReserved(p));
ffffffffc0202bae:	8b05                	andi	a4,a4,1
ffffffffc0202bb0:	cf49                	beqz	a4,ffffffffc0202c4a <default_init_memmap+0xb0>
		p->flags = p->property = 0;
ffffffffc0202bb2:	0007a823          	sw	zero,16(a5)
ffffffffc0202bb6:	0007b423          	sd	zero,8(a5)
ffffffffc0202bba:	0007a023          	sw	zero,0(a5)
	for (; p != base + n; p++) {
ffffffffc0202bbe:	04078793          	addi	a5,a5,64
ffffffffc0202bc2:	fed795e3          	bne	a5,a3,ffffffffc0202bac <default_init_memmap+0x12>
	base->property = n;
ffffffffc0202bc6:	2581                	sext.w	a1,a1
ffffffffc0202bc8:	c90c                	sw	a1,16(a0)
	__op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0202bca:	4789                	li	a5,2
ffffffffc0202bcc:	00850713          	addi	a4,a0,8
ffffffffc0202bd0:	40f7302f          	amoor.d	zero,a5,(a4)
	nr_free += n;
ffffffffc0202bd4:	0001c697          	auipc	a3,0x1c
ffffffffc0202bd8:	d3468693          	addi	a3,a3,-716 # ffffffffc021e908 <free_area>
ffffffffc0202bdc:	4a98                	lw	a4,16(a3)
	return list->next == list;
ffffffffc0202bde:	669c                	ld	a5,8(a3)
ffffffffc0202be0:	01850613          	addi	a2,a0,24
ffffffffc0202be4:	9db9                	addw	a1,a1,a4
ffffffffc0202be6:	ca8c                	sw	a1,16(a3)
	if (list_empty(&free_list)) {
ffffffffc0202be8:	04d78a63          	beq	a5,a3,ffffffffc0202c3c <default_init_memmap+0xa2>
			struct Page *page = le2page(le, page_link);
ffffffffc0202bec:	fe878713          	addi	a4,a5,-24
ffffffffc0202bf0:	0006b803          	ld	a6,0(a3)
	if (list_empty(&free_list)) {
ffffffffc0202bf4:	4581                	li	a1,0
			if (base < page) {
ffffffffc0202bf6:	00e56a63          	bltu	a0,a4,ffffffffc0202c0a <default_init_memmap+0x70>
	return listelm->next;
ffffffffc0202bfa:	6798                	ld	a4,8(a5)
			} else if (list_next(le) == &free_list) {
ffffffffc0202bfc:	02d70263          	beq	a4,a3,ffffffffc0202c20 <default_init_memmap+0x86>
	for (; p != base + n; p++) {
ffffffffc0202c00:	87ba                	mv	a5,a4
			struct Page *page = le2page(le, page_link);
ffffffffc0202c02:	fe878713          	addi	a4,a5,-24
			if (base < page) {
ffffffffc0202c06:	fee57ae3          	bgeu	a0,a4,ffffffffc0202bfa <default_init_memmap+0x60>
ffffffffc0202c0a:	c199                	beqz	a1,ffffffffc0202c10 <default_init_memmap+0x76>
ffffffffc0202c0c:	0106b023          	sd	a6,0(a3)
	__list_add(elm, listelm->prev, listelm);
ffffffffc0202c10:	6398                	ld	a4,0(a5)
}
ffffffffc0202c12:	60a2                	ld	ra,8(sp)
	prev->next = next->prev = elm;
ffffffffc0202c14:	e390                	sd	a2,0(a5)
ffffffffc0202c16:	e710                	sd	a2,8(a4)
	elm->next = next;
ffffffffc0202c18:	f11c                	sd	a5,32(a0)
	elm->prev = prev;
ffffffffc0202c1a:	ed18                	sd	a4,24(a0)
ffffffffc0202c1c:	0141                	addi	sp,sp,16
ffffffffc0202c1e:	8082                	ret
	prev->next = next->prev = elm;
ffffffffc0202c20:	e790                	sd	a2,8(a5)
	elm->next = next;
ffffffffc0202c22:	f114                	sd	a3,32(a0)
	return listelm->next;
ffffffffc0202c24:	6798                	ld	a4,8(a5)
	elm->prev = prev;
ffffffffc0202c26:	ed1c                	sd	a5,24(a0)
		while ((le = list_next(le)) != &free_list) {
ffffffffc0202c28:	00d70663          	beq	a4,a3,ffffffffc0202c34 <default_init_memmap+0x9a>
	prev->next = next->prev = elm;
ffffffffc0202c2c:	8832                	mv	a6,a2
ffffffffc0202c2e:	4585                	li	a1,1
	for (; p != base + n; p++) {
ffffffffc0202c30:	87ba                	mv	a5,a4
ffffffffc0202c32:	bfc1                	j	ffffffffc0202c02 <default_init_memmap+0x68>
}
ffffffffc0202c34:	60a2                	ld	ra,8(sp)
ffffffffc0202c36:	e290                	sd	a2,0(a3)
ffffffffc0202c38:	0141                	addi	sp,sp,16
ffffffffc0202c3a:	8082                	ret
ffffffffc0202c3c:	60a2                	ld	ra,8(sp)
ffffffffc0202c3e:	e390                	sd	a2,0(a5)
ffffffffc0202c40:	e790                	sd	a2,8(a5)
	elm->next = next;
ffffffffc0202c42:	f11c                	sd	a5,32(a0)
	elm->prev = prev;
ffffffffc0202c44:	ed1c                	sd	a5,24(a0)
ffffffffc0202c46:	0141                	addi	sp,sp,16
ffffffffc0202c48:	8082                	ret
		assert(PageReserved(p));
ffffffffc0202c4a:	00003697          	auipc	a3,0x3
ffffffffc0202c4e:	b5e68693          	addi	a3,a3,-1186 # ffffffffc02057a8 <etext+0x1166>
ffffffffc0202c52:	00002617          	auipc	a2,0x2
ffffffffc0202c56:	dfe60613          	addi	a2,a2,-514 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202c5a:	05100593          	li	a1,81
ffffffffc0202c5e:	00002517          	auipc	a0,0x2
ffffffffc0202c62:	7da50513          	addi	a0,a0,2010 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202c66:	cd2fd0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(n > 0);
ffffffffc0202c6a:	00003697          	auipc	a3,0x3
ffffffffc0202c6e:	b0e68693          	addi	a3,a3,-1266 # ffffffffc0205778 <etext+0x1136>
ffffffffc0202c72:	00002617          	auipc	a2,0x2
ffffffffc0202c76:	dde60613          	addi	a2,a2,-546 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0202c7a:	04e00593          	li	a1,78
ffffffffc0202c7e:	00002517          	auipc	a0,0x2
ffffffffc0202c82:	7ba50513          	addi	a0,a0,1978 # ffffffffc0205438 <etext+0xdf6>
ffffffffc0202c86:	cb2fd0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0202c8a <swapfs_init>:
#include <pmm.h>
#include <swap.h>
#include <swapfs.h>

void swapfs_init(void)
{
ffffffffc0202c8a:	1141                	addi	sp,sp,-16
	static_assert((PGSIZE % SECTSIZE) == 0);
	if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0202c8c:	4505                	li	a0,1
{
ffffffffc0202c8e:	e406                	sd	ra,8(sp)
	if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0202c90:	d58fd0ef          	jal	ra,ffffffffc02001e8 <ide_device_valid>
ffffffffc0202c94:	cd01                	beqz	a0,ffffffffc0202cac <swapfs_init+0x22>
		panic("swap fs isn't available.\n");
	}
	max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0202c96:	4505                	li	a0,1
ffffffffc0202c98:	d56fd0ef          	jal	ra,ffffffffc02001ee <ide_device_size>
}
ffffffffc0202c9c:	60a2                	ld	ra,8(sp)
	max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0202c9e:	810d                	srli	a0,a0,0x3
ffffffffc0202ca0:	0001c797          	auipc	a5,0x1c
ffffffffc0202ca4:	c2a7b423          	sd	a0,-984(a5) # ffffffffc021e8c8 <max_swap_offset>
}
ffffffffc0202ca8:	0141                	addi	sp,sp,16
ffffffffc0202caa:	8082                	ret
		panic("swap fs isn't available.\n");
ffffffffc0202cac:	00003617          	auipc	a2,0x3
ffffffffc0202cb0:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0205808 <default_pmm_manager+0x38>
ffffffffc0202cb4:	45b5                	li	a1,13
ffffffffc0202cb6:	00003517          	auipc	a0,0x3
ffffffffc0202cba:	b7250513          	addi	a0,a0,-1166 # ffffffffc0205828 <default_pmm_manager+0x58>
ffffffffc0202cbe:	c7afd0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0202cc2 <swapfs_read>:

int swapfs_read(swap_entry_t entry, struct Page *page)
{
ffffffffc0202cc2:	1141                	addi	sp,sp,-16
ffffffffc0202cc4:	e406                	sd	ra,8(sp)
	return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT,
ffffffffc0202cc6:	00855793          	srli	a5,a0,0x8
ffffffffc0202cca:	cbb1                	beqz	a5,ffffffffc0202d1e <swapfs_read+0x5c>
ffffffffc0202ccc:	0001c717          	auipc	a4,0x1c
ffffffffc0202cd0:	bfc73703          	ld	a4,-1028(a4) # ffffffffc021e8c8 <max_swap_offset>
ffffffffc0202cd4:	04e7f563          	bgeu	a5,a4,ffffffffc0202d1e <swapfs_read+0x5c>
	return page - pages + nbase;
ffffffffc0202cd8:	0001c617          	auipc	a2,0x1c
ffffffffc0202cdc:	b4863603          	ld	a2,-1208(a2) # ffffffffc021e820 <pages>
ffffffffc0202ce0:	8d91                	sub	a1,a1,a2
ffffffffc0202ce2:	4065d613          	srai	a2,a1,0x6
ffffffffc0202ce6:	00003717          	auipc	a4,0x3
ffffffffc0202cea:	48273703          	ld	a4,1154(a4) # ffffffffc0206168 <nbase>
ffffffffc0202cee:	963a                	add	a2,a2,a4
	return KADDR(page2pa(page));
ffffffffc0202cf0:	00c61713          	slli	a4,a2,0xc
ffffffffc0202cf4:	8331                	srli	a4,a4,0xc
ffffffffc0202cf6:	0001c697          	auipc	a3,0x1c
ffffffffc0202cfa:	ac26b683          	ld	a3,-1342(a3) # ffffffffc021e7b8 <npage>
ffffffffc0202cfe:	0037959b          	slliw	a1,a5,0x3
	return page2ppn(page) << PGSHIFT;
ffffffffc0202d02:	0632                	slli	a2,a2,0xc
	return KADDR(page2pa(page));
ffffffffc0202d04:	02d77963          	bgeu	a4,a3,ffffffffc0202d36 <swapfs_read+0x74>
			     page2kva(page), PAGE_NSECT);
}
ffffffffc0202d08:	60a2                	ld	ra,8(sp)
	return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT,
ffffffffc0202d0a:	0001c797          	auipc	a5,0x1c
ffffffffc0202d0e:	b0e7b783          	ld	a5,-1266(a5) # ffffffffc021e818 <va_pa_offset>
ffffffffc0202d12:	46a1                	li	a3,8
ffffffffc0202d14:	963e                	add	a2,a2,a5
ffffffffc0202d16:	4505                	li	a0,1
}
ffffffffc0202d18:	0141                	addi	sp,sp,16
	return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT,
ffffffffc0202d1a:	cdafd06f          	j	ffffffffc02001f4 <ide_read_secs>
ffffffffc0202d1e:	86aa                	mv	a3,a0
ffffffffc0202d20:	00003617          	auipc	a2,0x3
ffffffffc0202d24:	b2060613          	addi	a2,a2,-1248 # ffffffffc0205840 <default_pmm_manager+0x70>
ffffffffc0202d28:	45d1                	li	a1,20
ffffffffc0202d2a:	00003517          	auipc	a0,0x3
ffffffffc0202d2e:	afe50513          	addi	a0,a0,-1282 # ffffffffc0205828 <default_pmm_manager+0x58>
ffffffffc0202d32:	c06fd0ef          	jal	ra,ffffffffc0200138 <__panic>
ffffffffc0202d36:	86b2                	mv	a3,a2
ffffffffc0202d38:	07200593          	li	a1,114
ffffffffc0202d3c:	00002617          	auipc	a2,0x2
ffffffffc0202d40:	0c460613          	addi	a2,a2,196 # ffffffffc0204e00 <etext+0x7be>
ffffffffc0202d44:	00002517          	auipc	a0,0x2
ffffffffc0202d48:	01c50513          	addi	a0,a0,28 # ffffffffc0204d60 <etext+0x71e>
ffffffffc0202d4c:	becfd0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0202d50 <swapfs_write>:

int swapfs_write(swap_entry_t entry, struct Page *page)
{
ffffffffc0202d50:	1141                	addi	sp,sp,-16
ffffffffc0202d52:	e406                	sd	ra,8(sp)
	return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT,
ffffffffc0202d54:	00855793          	srli	a5,a0,0x8
ffffffffc0202d58:	cbb1                	beqz	a5,ffffffffc0202dac <swapfs_write+0x5c>
ffffffffc0202d5a:	0001c717          	auipc	a4,0x1c
ffffffffc0202d5e:	b6e73703          	ld	a4,-1170(a4) # ffffffffc021e8c8 <max_swap_offset>
ffffffffc0202d62:	04e7f563          	bgeu	a5,a4,ffffffffc0202dac <swapfs_write+0x5c>
	return page - pages + nbase;
ffffffffc0202d66:	0001c617          	auipc	a2,0x1c
ffffffffc0202d6a:	aba63603          	ld	a2,-1350(a2) # ffffffffc021e820 <pages>
ffffffffc0202d6e:	8d91                	sub	a1,a1,a2
ffffffffc0202d70:	4065d613          	srai	a2,a1,0x6
ffffffffc0202d74:	00003717          	auipc	a4,0x3
ffffffffc0202d78:	3f473703          	ld	a4,1012(a4) # ffffffffc0206168 <nbase>
ffffffffc0202d7c:	963a                	add	a2,a2,a4
	return KADDR(page2pa(page));
ffffffffc0202d7e:	00c61713          	slli	a4,a2,0xc
ffffffffc0202d82:	8331                	srli	a4,a4,0xc
ffffffffc0202d84:	0001c697          	auipc	a3,0x1c
ffffffffc0202d88:	a346b683          	ld	a3,-1484(a3) # ffffffffc021e7b8 <npage>
ffffffffc0202d8c:	0037959b          	slliw	a1,a5,0x3
	return page2ppn(page) << PGSHIFT;
ffffffffc0202d90:	0632                	slli	a2,a2,0xc
	return KADDR(page2pa(page));
ffffffffc0202d92:	02d77963          	bgeu	a4,a3,ffffffffc0202dc4 <swapfs_write+0x74>
			      page2kva(page), PAGE_NSECT);
}
ffffffffc0202d96:	60a2                	ld	ra,8(sp)
	return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT,
ffffffffc0202d98:	0001c797          	auipc	a5,0x1c
ffffffffc0202d9c:	a807b783          	ld	a5,-1408(a5) # ffffffffc021e818 <va_pa_offset>
ffffffffc0202da0:	46a1                	li	a3,8
ffffffffc0202da2:	963e                	add	a2,a2,a5
ffffffffc0202da4:	4505                	li	a0,1
}
ffffffffc0202da6:	0141                	addi	sp,sp,16
	return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT,
ffffffffc0202da8:	c70fd06f          	j	ffffffffc0200218 <ide_write_secs>
ffffffffc0202dac:	86aa                	mv	a3,a0
ffffffffc0202dae:	00003617          	auipc	a2,0x3
ffffffffc0202db2:	a9260613          	addi	a2,a2,-1390 # ffffffffc0205840 <default_pmm_manager+0x70>
ffffffffc0202db6:	45e9                	li	a1,26
ffffffffc0202db8:	00003517          	auipc	a0,0x3
ffffffffc0202dbc:	a7050513          	addi	a0,a0,-1424 # ffffffffc0205828 <default_pmm_manager+0x58>
ffffffffc0202dc0:	b78fd0ef          	jal	ra,ffffffffc0200138 <__panic>
ffffffffc0202dc4:	86b2                	mv	a3,a2
ffffffffc0202dc6:	07200593          	li	a1,114
ffffffffc0202dca:	00002617          	auipc	a2,0x2
ffffffffc0202dce:	03660613          	addi	a2,a2,54 # ffffffffc0204e00 <etext+0x7be>
ffffffffc0202dd2:	00002517          	auipc	a0,0x2
ffffffffc0202dd6:	f8e50513          	addi	a0,a0,-114 # ffffffffc0204d60 <etext+0x71e>
ffffffffc0202dda:	b5efd0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0202dde <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0202dde:	8526                	mv	a0,s1
	jalr s0
ffffffffc0202de0:	9402                	jalr	s0

	jal do_exit
ffffffffc0202de2:	75c000ef          	jal	ra,ffffffffc020353e <do_exit>

ffffffffc0202de6 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0202de6:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0202dea:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0202dee:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0202df0:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0202df2:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0202df6:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0202dfa:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0202dfe:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0202e02:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0202e06:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0202e0a:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0202e0e:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0202e12:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0202e16:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0202e1a:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0202e1e:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0202e22:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0202e24:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0202e26:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0202e2a:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0202e2e:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0202e32:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0202e36:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0202e3a:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0202e3e:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0202e42:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0202e46:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0202e4a:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0202e4e:	8082                	ret

ffffffffc0202e50 <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *alloc_proc(void)
{
ffffffffc0202e50:	1141                	addi	sp,sp,-16
	struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0202e52:	10800513          	li	a0,264
{
ffffffffc0202e56:	e022                	sd	s0,0(sp)
ffffffffc0202e58:	e406                	sd	ra,8(sp)
	struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0202e5a:	fb7fe0ef          	jal	ra,ffffffffc0201e10 <kmalloc>
ffffffffc0202e5e:	842a                	mv	s0,a0
	if (proc != NULL) {
ffffffffc0202e60:	cd21                	beqz	a0,ffffffffc0202eb8 <alloc_proc+0x68>
		proc->state = PROC_UNINIT;
ffffffffc0202e62:	57fd                	li	a5,-1
ffffffffc0202e64:	1782                	slli	a5,a5,0x20
ffffffffc0202e66:	e11c                	sd	a5,0(a0)
		proc->runs = 0;
		proc->kstack = 0;
		proc->need_resched = 0;
		proc->parent = NULL;
		proc->mm = NULL;
		memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0202e68:	07000613          	li	a2,112
ffffffffc0202e6c:	4581                	li	a1,0
		proc->runs = 0;
ffffffffc0202e6e:	00052423          	sw	zero,8(a0)
		proc->kstack = 0;
ffffffffc0202e72:	00053823          	sd	zero,16(a0)
		proc->need_resched = 0;
ffffffffc0202e76:	00052c23          	sw	zero,24(a0)
		proc->parent = NULL;
ffffffffc0202e7a:	02053023          	sd	zero,32(a0)
		proc->mm = NULL;
ffffffffc0202e7e:	02053423          	sd	zero,40(a0)
		memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0202e82:	03050513          	addi	a0,a0,48
ffffffffc0202e86:	38e010ef          	jal	ra,ffffffffc0204214 <memset>
		proc->tf = NULL;
		proc->satp = boot_satp;
ffffffffc0202e8a:	0001c797          	auipc	a5,0x1c
ffffffffc0202e8e:	9867b783          	ld	a5,-1658(a5) # ffffffffc021e810 <boot_satp>
		proc->tf = NULL;
ffffffffc0202e92:	0a043023          	sd	zero,160(s0)
		proc->satp = boot_satp;
ffffffffc0202e96:	f45c                	sd	a5,168(s0)
		proc->flags = 0;
ffffffffc0202e98:	0a042823          	sw	zero,176(s0)
		memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0202e9c:	463d                	li	a2,15
ffffffffc0202e9e:	4581                	li	a1,0
ffffffffc0202ea0:	0b440513          	addi	a0,s0,180
ffffffffc0202ea4:	370010ef          	jal	ra,ffffffffc0204214 <memset>
		proc->wait_state = 0;
ffffffffc0202ea8:	0e042623          	sw	zero,236(s0)
		proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc0202eac:	0e043c23          	sd	zero,248(s0)
ffffffffc0202eb0:	10043023          	sd	zero,256(s0)
ffffffffc0202eb4:	0e043823          	sd	zero,240(s0)
	}
	return proc;
}
ffffffffc0202eb8:	60a2                	ld	ra,8(sp)
ffffffffc0202eba:	8522                	mv	a0,s0
ffffffffc0202ebc:	6402                	ld	s0,0(sp)
ffffffffc0202ebe:	0141                	addi	sp,sp,16
ffffffffc0202ec0:	8082                	ret

ffffffffc0202ec2 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void forkret(void)
{
	forkrets(current->tf);
ffffffffc0202ec2:	0001c797          	auipc	a5,0x1c
ffffffffc0202ec6:	91e7b783          	ld	a5,-1762(a5) # ffffffffc021e7e0 <current>
ffffffffc0202eca:	73c8                	ld	a0,160(a5)
ffffffffc0202ecc:	a4dfd06f          	j	ffffffffc0200918 <forkrets>

ffffffffc0202ed0 <user_main>:
	})

// user_main - kernel thread used to exec a user program
static int user_main(void *arg)
{
	KERNEL_EXECVE(hello); // exec
ffffffffc0202ed0:	0001c797          	auipc	a5,0x1c
ffffffffc0202ed4:	9107b783          	ld	a5,-1776(a5) # ffffffffc021e7e0 <current>
ffffffffc0202ed8:	43cc                	lw	a1,4(a5)
{
ffffffffc0202eda:	7139                	addi	sp,sp,-64
	KERNEL_EXECVE(hello); // exec
ffffffffc0202edc:	00003617          	auipc	a2,0x3
ffffffffc0202ee0:	98460613          	addi	a2,a2,-1660 # ffffffffc0205860 <default_pmm_manager+0x90>
ffffffffc0202ee4:	00003517          	auipc	a0,0x3
ffffffffc0202ee8:	98450513          	addi	a0,a0,-1660 # ffffffffc0205868 <default_pmm_manager+0x98>
{
ffffffffc0202eec:	fc06                	sd	ra,56(sp)
	KERNEL_EXECVE(hello); // exec
ffffffffc0202eee:	9d2fd0ef          	jal	ra,ffffffffc02000c0 <cprintf>
ffffffffc0202ef2:	3fe07797          	auipc	a5,0x3fe07
ffffffffc0202ef6:	84e78793          	addi	a5,a5,-1970 # 9740 <_binary_obj___user_hello_out_size>
ffffffffc0202efa:	e43e                	sd	a5,8(sp)
ffffffffc0202efc:	00003517          	auipc	a0,0x3
ffffffffc0202f00:	96450513          	addi	a0,a0,-1692 # ffffffffc0205860 <default_pmm_manager+0x90>
ffffffffc0202f04:	00007797          	auipc	a5,0x7
ffffffffc0202f08:	0fc78793          	addi	a5,a5,252 # ffffffffc020a000 <_binary_obj___user_hello_out_start>
ffffffffc0202f0c:	f03e                	sd	a5,32(sp)
ffffffffc0202f0e:	f42a                	sd	a0,40(sp)
	int64_t ret = 0, len = strlen(name);
ffffffffc0202f10:	e802                	sd	zero,16(sp)
ffffffffc0202f12:	2cc010ef          	jal	ra,ffffffffc02041de <strlen>
ffffffffc0202f16:	ec2a                	sd	a0,24(sp)
	asm volatile("li a0, %1\n"
ffffffffc0202f18:	4511                	li	a0,4
ffffffffc0202f1a:	55a2                	lw	a1,40(sp)
ffffffffc0202f1c:	4662                	lw	a2,24(sp)
ffffffffc0202f1e:	5682                	lw	a3,32(sp)
ffffffffc0202f20:	4722                	lw	a4,8(sp)
ffffffffc0202f22:	48a9                	li	a7,10
ffffffffc0202f24:	9002                	ebreak
ffffffffc0202f26:	c82a                	sw	a0,16(sp)
	panic("user_main execve failed.\n");
ffffffffc0202f28:	00003617          	auipc	a2,0x3
ffffffffc0202f2c:	96860613          	addi	a2,a2,-1688 # ffffffffc0205890 <default_pmm_manager+0xc0>
ffffffffc0202f30:	32b00593          	li	a1,811
ffffffffc0202f34:	00003517          	auipc	a0,0x3
ffffffffc0202f38:	97c50513          	addi	a0,a0,-1668 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0202f3c:	9fcfd0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0202f40 <put_pgdir>:
	return pa2page(PADDR(kva));
ffffffffc0202f40:	6d14                	ld	a3,24(a0)
{
ffffffffc0202f42:	1141                	addi	sp,sp,-16
ffffffffc0202f44:	e406                	sd	ra,8(sp)
ffffffffc0202f46:	c02007b7          	lui	a5,0xc0200
ffffffffc0202f4a:	02f6ee63          	bltu	a3,a5,ffffffffc0202f86 <put_pgdir+0x46>
ffffffffc0202f4e:	0001c517          	auipc	a0,0x1c
ffffffffc0202f52:	8ca53503          	ld	a0,-1846(a0) # ffffffffc021e818 <va_pa_offset>
ffffffffc0202f56:	8e89                	sub	a3,a3,a0
	if (PPN(pa) >= npage) {
ffffffffc0202f58:	82b1                	srli	a3,a3,0xc
ffffffffc0202f5a:	0001c797          	auipc	a5,0x1c
ffffffffc0202f5e:	85e7b783          	ld	a5,-1954(a5) # ffffffffc021e7b8 <npage>
ffffffffc0202f62:	02f6fe63          	bgeu	a3,a5,ffffffffc0202f9e <put_pgdir+0x5e>
	return &pages[PPN(pa) - nbase];
ffffffffc0202f66:	00003517          	auipc	a0,0x3
ffffffffc0202f6a:	20253503          	ld	a0,514(a0) # ffffffffc0206168 <nbase>
}
ffffffffc0202f6e:	60a2                	ld	ra,8(sp)
ffffffffc0202f70:	8e89                	sub	a3,a3,a0
ffffffffc0202f72:	069a                	slli	a3,a3,0x6
	free_page(kva2page(mm->pgdir));
ffffffffc0202f74:	0001c517          	auipc	a0,0x1c
ffffffffc0202f78:	8ac53503          	ld	a0,-1876(a0) # ffffffffc021e820 <pages>
ffffffffc0202f7c:	4585                	li	a1,1
ffffffffc0202f7e:	9536                	add	a0,a0,a3
}
ffffffffc0202f80:	0141                	addi	sp,sp,16
	free_page(kva2page(mm->pgdir));
ffffffffc0202f82:	a4bfd06f          	j	ffffffffc02009cc <free_pages>
	return pa2page(PADDR(kva));
ffffffffc0202f86:	00002617          	auipc	a2,0x2
ffffffffc0202f8a:	e4260613          	addi	a2,a2,-446 # ffffffffc0204dc8 <etext+0x786>
ffffffffc0202f8e:	07700593          	li	a1,119
ffffffffc0202f92:	00002517          	auipc	a0,0x2
ffffffffc0202f96:	dce50513          	addi	a0,a0,-562 # ffffffffc0204d60 <etext+0x71e>
ffffffffc0202f9a:	99efd0ef          	jal	ra,ffffffffc0200138 <__panic>
		panic("pa2page called with invalid pa");
ffffffffc0202f9e:	00002617          	auipc	a2,0x2
ffffffffc0202fa2:	da260613          	addi	a2,a2,-606 # ffffffffc0204d40 <etext+0x6fe>
ffffffffc0202fa6:	06b00593          	li	a1,107
ffffffffc0202faa:	00002517          	auipc	a0,0x2
ffffffffc0202fae:	db650513          	addi	a0,a0,-586 # ffffffffc0204d60 <etext+0x71e>
ffffffffc0202fb2:	986fd0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0202fb6 <setup_pgdir>:
{
ffffffffc0202fb6:	1101                	addi	sp,sp,-32
ffffffffc0202fb8:	e426                	sd	s1,8(sp)
ffffffffc0202fba:	84aa                	mv	s1,a0
	if ((page = alloc_page()) == NULL) {
ffffffffc0202fbc:	4505                	li	a0,1
{
ffffffffc0202fbe:	ec06                	sd	ra,24(sp)
ffffffffc0202fc0:	e822                	sd	s0,16(sp)
	if ((page = alloc_page()) == NULL) {
ffffffffc0202fc2:	979fd0ef          	jal	ra,ffffffffc020093a <alloc_pages>
ffffffffc0202fc6:	c939                	beqz	a0,ffffffffc020301c <setup_pgdir+0x66>
	return page - pages + nbase;
ffffffffc0202fc8:	0001c697          	auipc	a3,0x1c
ffffffffc0202fcc:	8586b683          	ld	a3,-1960(a3) # ffffffffc021e820 <pages>
ffffffffc0202fd0:	40d506b3          	sub	a3,a0,a3
ffffffffc0202fd4:	8699                	srai	a3,a3,0x6
ffffffffc0202fd6:	00003417          	auipc	s0,0x3
ffffffffc0202fda:	19243403          	ld	s0,402(s0) # ffffffffc0206168 <nbase>
ffffffffc0202fde:	96a2                	add	a3,a3,s0
	return KADDR(page2pa(page));
ffffffffc0202fe0:	00c69793          	slli	a5,a3,0xc
ffffffffc0202fe4:	83b1                	srli	a5,a5,0xc
ffffffffc0202fe6:	0001b717          	auipc	a4,0x1b
ffffffffc0202fea:	7d273703          	ld	a4,2002(a4) # ffffffffc021e7b8 <npage>
	return page2ppn(page) << PGSHIFT;
ffffffffc0202fee:	06b2                	slli	a3,a3,0xc
	return KADDR(page2pa(page));
ffffffffc0202ff0:	02e7f863          	bgeu	a5,a4,ffffffffc0203020 <setup_pgdir+0x6a>
ffffffffc0202ff4:	0001c417          	auipc	s0,0x1c
ffffffffc0202ff8:	82443403          	ld	s0,-2012(s0) # ffffffffc021e818 <va_pa_offset>
ffffffffc0202ffc:	9436                	add	s0,s0,a3
	memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0202ffe:	6605                	lui	a2,0x1
ffffffffc0203000:	0001b597          	auipc	a1,0x1b
ffffffffc0203004:	7b05b583          	ld	a1,1968(a1) # ffffffffc021e7b0 <boot_pgdir>
ffffffffc0203008:	8522                	mv	a0,s0
ffffffffc020300a:	21c010ef          	jal	ra,ffffffffc0204226 <memcpy>
	return 0;
ffffffffc020300e:	4501                	li	a0,0
	mm->pgdir = pgdir;
ffffffffc0203010:	ec80                	sd	s0,24(s1)
}
ffffffffc0203012:	60e2                	ld	ra,24(sp)
ffffffffc0203014:	6442                	ld	s0,16(sp)
ffffffffc0203016:	64a2                	ld	s1,8(sp)
ffffffffc0203018:	6105                	addi	sp,sp,32
ffffffffc020301a:	8082                	ret
		return -E_NO_MEM;
ffffffffc020301c:	5571                	li	a0,-4
ffffffffc020301e:	bfd5                	j	ffffffffc0203012 <setup_pgdir+0x5c>
ffffffffc0203020:	00002617          	auipc	a2,0x2
ffffffffc0203024:	de060613          	addi	a2,a2,-544 # ffffffffc0204e00 <etext+0x7be>
ffffffffc0203028:	07200593          	li	a1,114
ffffffffc020302c:	00002517          	auipc	a0,0x2
ffffffffc0203030:	d3450513          	addi	a0,a0,-716 # ffffffffc0204d60 <etext+0x71e>
ffffffffc0203034:	904fd0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0203038 <set_proc_name>:
{
ffffffffc0203038:	1101                	addi	sp,sp,-32
ffffffffc020303a:	e822                	sd	s0,16(sp)
	memset(proc->name, 0, sizeof(proc->name));
ffffffffc020303c:	0b450413          	addi	s0,a0,180
{
ffffffffc0203040:	e426                	sd	s1,8(sp)
	memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203042:	4641                	li	a2,16
{
ffffffffc0203044:	84ae                	mv	s1,a1
	memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203046:	8522                	mv	a0,s0
ffffffffc0203048:	4581                	li	a1,0
{
ffffffffc020304a:	ec06                	sd	ra,24(sp)
	memset(proc->name, 0, sizeof(proc->name));
ffffffffc020304c:	1c8010ef          	jal	ra,ffffffffc0204214 <memset>
	return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0203050:	8522                	mv	a0,s0
}
ffffffffc0203052:	6442                	ld	s0,16(sp)
ffffffffc0203054:	60e2                	ld	ra,24(sp)
	return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0203056:	85a6                	mv	a1,s1
}
ffffffffc0203058:	64a2                	ld	s1,8(sp)
	return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020305a:	463d                	li	a2,15
}
ffffffffc020305c:	6105                	addi	sp,sp,32
	return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020305e:	1c80106f          	j	ffffffffc0204226 <memcpy>

ffffffffc0203062 <proc_run>:
{
ffffffffc0203062:	7179                	addi	sp,sp,-48
ffffffffc0203064:	ec4a                	sd	s2,24(sp)
	if (proc != current) {
ffffffffc0203066:	0001b917          	auipc	s2,0x1b
ffffffffc020306a:	77a90913          	addi	s2,s2,1914 # ffffffffc021e7e0 <current>
{
ffffffffc020306e:	f026                	sd	s1,32(sp)
	if (proc != current) {
ffffffffc0203070:	00093483          	ld	s1,0(s2)
{
ffffffffc0203074:	f406                	sd	ra,40(sp)
ffffffffc0203076:	e84e                	sd	s3,16(sp)
	if (proc != current) {
ffffffffc0203078:	02a48a63          	beq	s1,a0,ffffffffc02030ac <proc_run+0x4a>
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020307c:	100027f3          	csrr	a5,sstatus
ffffffffc0203080:	8b89                	andi	a5,a5,2
	return 0;
ffffffffc0203082:	4981                	li	s3,0
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203084:	e3a9                	bnez	a5,ffffffffc02030c6 <proc_run+0x64>

#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void lsatp(unsigned long satp)
{
	write_csr(satp, 0x8000000000000000 | (satp >> RISCV_PGSHIFT));
ffffffffc0203086:	755c                	ld	a5,168(a0)
ffffffffc0203088:	577d                	li	a4,-1
ffffffffc020308a:	177e                	slli	a4,a4,0x3f
ffffffffc020308c:	83b1                	srli	a5,a5,0xc
			current = proc;
ffffffffc020308e:	00a93023          	sd	a0,0(s2)
ffffffffc0203092:	8fd9                	or	a5,a5,a4
ffffffffc0203094:	18079073          	csrw	satp,a5
        barrier();
ffffffffc0203098:	0ff0000f          	fence
			switch_to(&(prev->context), &(next->context));
ffffffffc020309c:	03050593          	addi	a1,a0,48
ffffffffc02030a0:	03048513          	addi	a0,s1,48
ffffffffc02030a4:	d43ff0ef          	jal	ra,ffffffffc0202de6 <switch_to>
	if (flag) {
ffffffffc02030a8:	00099863          	bnez	s3,ffffffffc02030b8 <proc_run+0x56>
}
ffffffffc02030ac:	70a2                	ld	ra,40(sp)
ffffffffc02030ae:	7482                	ld	s1,32(sp)
ffffffffc02030b0:	6962                	ld	s2,24(sp)
ffffffffc02030b2:	69c2                	ld	s3,16(sp)
ffffffffc02030b4:	6145                	addi	sp,sp,48
ffffffffc02030b6:	8082                	ret
ffffffffc02030b8:	70a2                	ld	ra,40(sp)
ffffffffc02030ba:	7482                	ld	s1,32(sp)
ffffffffc02030bc:	6962                	ld	s2,24(sp)
ffffffffc02030be:	69c2                	ld	s3,16(sp)
ffffffffc02030c0:	6145                	addi	sp,sp,48
		intr_enable();
ffffffffc02030c2:	9cafd06f          	j	ffffffffc020028c <intr_enable>
ffffffffc02030c6:	e42a                	sd	a0,8(sp)
		intr_disable();
ffffffffc02030c8:	9cafd0ef          	jal	ra,ffffffffc0200292 <intr_disable>
		return 1;
ffffffffc02030cc:	6522                	ld	a0,8(sp)
ffffffffc02030ce:	4985                	li	s3,1
ffffffffc02030d0:	bf5d                	j	ffffffffc0203086 <proc_run+0x24>

ffffffffc02030d2 <find_proc>:
	if (0 < pid && pid < MAX_PID) {
ffffffffc02030d2:	6789                	lui	a5,0x2
ffffffffc02030d4:	fff5071b          	addiw	a4,a0,-1
ffffffffc02030d8:	17f9                	addi	a5,a5,-2
ffffffffc02030da:	04e7e063          	bltu	a5,a4,ffffffffc020311a <find_proc+0x48>
{
ffffffffc02030de:	1141                	addi	sp,sp,-16
ffffffffc02030e0:	e022                	sd	s0,0(sp)
		list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02030e2:	45a9                	li	a1,10
ffffffffc02030e4:	842a                	mv	s0,a0
ffffffffc02030e6:	2501                	sext.w	a0,a0
{
ffffffffc02030e8:	e406                	sd	ra,8(sp)
		list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02030ea:	542010ef          	jal	ra,ffffffffc020462c <hash32>
ffffffffc02030ee:	02051693          	slli	a3,a0,0x20
ffffffffc02030f2:	00017797          	auipc	a5,0x17
ffffffffc02030f6:	6ae78793          	addi	a5,a5,1710 # ffffffffc021a7a0 <hash_list>
ffffffffc02030fa:	82f1                	srli	a3,a3,0x1c
ffffffffc02030fc:	96be                	add	a3,a3,a5
ffffffffc02030fe:	87b6                	mv	a5,a3
		while ((le = list_next(le)) != list) {
ffffffffc0203100:	a029                	j	ffffffffc020310a <find_proc+0x38>
			if (proc->pid == pid) {
ffffffffc0203102:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0203106:	00870c63          	beq	a4,s0,ffffffffc020311e <find_proc+0x4c>
	return listelm->next;
ffffffffc020310a:	679c                	ld	a5,8(a5)
		while ((le = list_next(le)) != list) {
ffffffffc020310c:	fef69be3          	bne	a3,a5,ffffffffc0203102 <find_proc+0x30>
}
ffffffffc0203110:	60a2                	ld	ra,8(sp)
ffffffffc0203112:	6402                	ld	s0,0(sp)
	return NULL;
ffffffffc0203114:	4501                	li	a0,0
}
ffffffffc0203116:	0141                	addi	sp,sp,16
ffffffffc0203118:	8082                	ret
	return NULL;
ffffffffc020311a:	4501                	li	a0,0
}
ffffffffc020311c:	8082                	ret
ffffffffc020311e:	60a2                	ld	ra,8(sp)
ffffffffc0203120:	6402                	ld	s0,0(sp)
			struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0203122:	f2878513          	addi	a0,a5,-216
}
ffffffffc0203126:	0141                	addi	sp,sp,16
ffffffffc0203128:	8082                	ret

ffffffffc020312a <do_fork>:
{
ffffffffc020312a:	7159                	addi	sp,sp,-112
ffffffffc020312c:	e0d2                	sd	s4,64(sp)
	if (nr_process >= MAX_PROCESS) {
ffffffffc020312e:	0001ba17          	auipc	s4,0x1b
ffffffffc0203132:	6caa0a13          	addi	s4,s4,1738 # ffffffffc021e7f8 <nr_process>
ffffffffc0203136:	000a2703          	lw	a4,0(s4)
{
ffffffffc020313a:	f486                	sd	ra,104(sp)
ffffffffc020313c:	f0a2                	sd	s0,96(sp)
ffffffffc020313e:	eca6                	sd	s1,88(sp)
ffffffffc0203140:	e8ca                	sd	s2,80(sp)
ffffffffc0203142:	e4ce                	sd	s3,72(sp)
ffffffffc0203144:	fc56                	sd	s5,56(sp)
ffffffffc0203146:	f85a                	sd	s6,48(sp)
ffffffffc0203148:	f45e                	sd	s7,40(sp)
ffffffffc020314a:	f062                	sd	s8,32(sp)
ffffffffc020314c:	ec66                	sd	s9,24(sp)
ffffffffc020314e:	e86a                	sd	s10,16(sp)
ffffffffc0203150:	e46e                	sd	s11,8(sp)
	if (nr_process >= MAX_PROCESS) {
ffffffffc0203152:	6785                	lui	a5,0x1
ffffffffc0203154:	2ef75c63          	bge	a4,a5,ffffffffc020344c <do_fork+0x322>
ffffffffc0203158:	89aa                	mv	s3,a0
ffffffffc020315a:	892e                	mv	s2,a1
ffffffffc020315c:	84b2                	mv	s1,a2
	if ((proc = alloc_proc()) == NULL) {
ffffffffc020315e:	cf3ff0ef          	jal	ra,ffffffffc0202e50 <alloc_proc>
ffffffffc0203162:	842a                	mv	s0,a0
ffffffffc0203164:	2c050163          	beqz	a0,ffffffffc0203426 <do_fork+0x2fc>
	proc->parent = current;
ffffffffc0203168:	0001bc17          	auipc	s8,0x1b
ffffffffc020316c:	678c0c13          	addi	s8,s8,1656 # ffffffffc021e7e0 <current>
ffffffffc0203170:	000c3783          	ld	a5,0(s8)
	assert(current->wait_state == 0);
ffffffffc0203174:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_hello_out_size-0x8654>
	proc->parent = current;
ffffffffc0203178:	f11c                	sd	a5,32(a0)
	assert(current->wait_state == 0);
ffffffffc020317a:	2e071963          	bnez	a4,ffffffffc020346c <do_fork+0x342>
	struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc020317e:	4509                	li	a0,2
ffffffffc0203180:	fbafd0ef          	jal	ra,ffffffffc020093a <alloc_pages>
	if (page != NULL) {
ffffffffc0203184:	28050e63          	beqz	a0,ffffffffc0203420 <do_fork+0x2f6>
	return page - pages + nbase;
ffffffffc0203188:	0001ba97          	auipc	s5,0x1b
ffffffffc020318c:	698a8a93          	addi	s5,s5,1688 # ffffffffc021e820 <pages>
ffffffffc0203190:	000ab683          	ld	a3,0(s5)
ffffffffc0203194:	00003b17          	auipc	s6,0x3
ffffffffc0203198:	fd4b0b13          	addi	s6,s6,-44 # ffffffffc0206168 <nbase>
ffffffffc020319c:	000b3783          	ld	a5,0(s6)
ffffffffc02031a0:	40d506b3          	sub	a3,a0,a3
ffffffffc02031a4:	8699                	srai	a3,a3,0x6
	return KADDR(page2pa(page));
ffffffffc02031a6:	0001bb97          	auipc	s7,0x1b
ffffffffc02031aa:	612b8b93          	addi	s7,s7,1554 # ffffffffc021e7b8 <npage>
	return page - pages + nbase;
ffffffffc02031ae:	96be                	add	a3,a3,a5
	return KADDR(page2pa(page));
ffffffffc02031b0:	000bb703          	ld	a4,0(s7)
ffffffffc02031b4:	00c69793          	slli	a5,a3,0xc
ffffffffc02031b8:	83b1                	srli	a5,a5,0xc
	return page2ppn(page) << PGSHIFT;
ffffffffc02031ba:	06b2                	slli	a3,a3,0xc
	return KADDR(page2pa(page));
ffffffffc02031bc:	28e7fc63          	bgeu	a5,a4,ffffffffc0203454 <do_fork+0x32a>
	struct mm_struct *mm, *oldmm = current->mm;
ffffffffc02031c0:	000c3703          	ld	a4,0(s8)
ffffffffc02031c4:	0001bc97          	auipc	s9,0x1b
ffffffffc02031c8:	654c8c93          	addi	s9,s9,1620 # ffffffffc021e818 <va_pa_offset>
ffffffffc02031cc:	000cb783          	ld	a5,0(s9)
ffffffffc02031d0:	02873c03          	ld	s8,40(a4)
ffffffffc02031d4:	96be                	add	a3,a3,a5
		proc->kstack = (uintptr_t)page2kva(page);
ffffffffc02031d6:	e814                	sd	a3,16(s0)
	if (oldmm == NULL) {
ffffffffc02031d8:	020c0863          	beqz	s8,ffffffffc0203208 <do_fork+0xde>
	if (clone_flags & CLONE_VM) {
ffffffffc02031dc:	1009f993          	andi	s3,s3,256
ffffffffc02031e0:	1a098e63          	beqz	s3,ffffffffc020339c <do_fork+0x272>
}

static inline int mm_count_inc(struct mm_struct *mm)
{
	mm->mm_count += 1;
ffffffffc02031e4:	030c2703          	lw	a4,48(s8)
	proc->satp = PADDR(mm->pgdir);
ffffffffc02031e8:	018c3783          	ld	a5,24(s8)
ffffffffc02031ec:	c02006b7          	lui	a3,0xc0200
ffffffffc02031f0:	2705                	addiw	a4,a4,1
ffffffffc02031f2:	02ec2823          	sw	a4,48(s8)
	proc->mm = mm;
ffffffffc02031f6:	03843423          	sd	s8,40(s0)
	proc->satp = PADDR(mm->pgdir);
ffffffffc02031fa:	28d7e963          	bltu	a5,a3,ffffffffc020348c <do_fork+0x362>
ffffffffc02031fe:	000cb703          	ld	a4,0(s9)
ffffffffc0203202:	6814                	ld	a3,16(s0)
ffffffffc0203204:	8f99                	sub	a5,a5,a4
ffffffffc0203206:	f45c                	sd	a5,168(s0)
	proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203208:	6789                	lui	a5,0x2
ffffffffc020320a:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_hello_out_size-0x7860>
ffffffffc020320e:	97b6                	add	a5,a5,a3
ffffffffc0203210:	f05c                	sd	a5,160(s0)
	*(proc->tf) = *tf;
ffffffffc0203212:	873e                	mv	a4,a5
ffffffffc0203214:	12048893          	addi	a7,s1,288
ffffffffc0203218:	0004b803          	ld	a6,0(s1)
ffffffffc020321c:	6488                	ld	a0,8(s1)
ffffffffc020321e:	688c                	ld	a1,16(s1)
ffffffffc0203220:	6c90                	ld	a2,24(s1)
ffffffffc0203222:	01073023          	sd	a6,0(a4)
ffffffffc0203226:	e708                	sd	a0,8(a4)
ffffffffc0203228:	eb0c                	sd	a1,16(a4)
ffffffffc020322a:	ef10                	sd	a2,24(a4)
ffffffffc020322c:	02048493          	addi	s1,s1,32
ffffffffc0203230:	02070713          	addi	a4,a4,32
ffffffffc0203234:	ff1492e3          	bne	s1,a7,ffffffffc0203218 <do_fork+0xee>
	proc->tf->gpr.a0 = 0;
ffffffffc0203238:	0407b823          	sd	zero,80(a5)
	proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf - 4 : esp;
ffffffffc020323c:	12090a63          	beqz	s2,ffffffffc0203370 <do_fork+0x246>
ffffffffc0203240:	0127b823          	sd	s2,16(a5)
	proc->context.ra = (uintptr_t)forkret;
ffffffffc0203244:	00000717          	auipc	a4,0x0
ffffffffc0203248:	c7e70713          	addi	a4,a4,-898 # ffffffffc0202ec2 <forkret>
ffffffffc020324c:	f818                	sd	a4,48(s0)
	proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020324e:	fc1c                	sd	a5,56(s0)
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203250:	100027f3          	csrr	a5,sstatus
ffffffffc0203254:	8b89                	andi	a5,a5,2
	return 0;
ffffffffc0203256:	4901                	li	s2,0
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203258:	12079e63          	bnez	a5,ffffffffc0203394 <do_fork+0x26a>
	if (++last_pid >= MAX_PID) {
ffffffffc020325c:	00010597          	auipc	a1,0x10
ffffffffc0203260:	53c58593          	addi	a1,a1,1340 # ffffffffc0213798 <last_pid.1671>
ffffffffc0203264:	419c                	lw	a5,0(a1)
ffffffffc0203266:	6709                	lui	a4,0x2
ffffffffc0203268:	0017851b          	addiw	a0,a5,1
ffffffffc020326c:	c188                	sw	a0,0(a1)
ffffffffc020326e:	08e55b63          	bge	a0,a4,ffffffffc0203304 <do_fork+0x1da>
	if (last_pid >= next_safe) {
ffffffffc0203272:	00010897          	auipc	a7,0x10
ffffffffc0203276:	52a88893          	addi	a7,a7,1322 # ffffffffc021379c <next_safe.1670>
ffffffffc020327a:	0008a783          	lw	a5,0(a7)
ffffffffc020327e:	0001b497          	auipc	s1,0x1b
ffffffffc0203282:	6a248493          	addi	s1,s1,1698 # ffffffffc021e920 <proc_list>
ffffffffc0203286:	08f55663          	bge	a0,a5,ffffffffc0203312 <do_fork+0x1e8>
		proc->pid = get_pid();
ffffffffc020328a:	c048                	sw	a0,4(s0)
	list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020328c:	45a9                	li	a1,10
ffffffffc020328e:	2501                	sext.w	a0,a0
ffffffffc0203290:	39c010ef          	jal	ra,ffffffffc020462c <hash32>
ffffffffc0203294:	1502                	slli	a0,a0,0x20
ffffffffc0203296:	00017797          	auipc	a5,0x17
ffffffffc020329a:	50a78793          	addi	a5,a5,1290 # ffffffffc021a7a0 <hash_list>
ffffffffc020329e:	8171                	srli	a0,a0,0x1c
ffffffffc02032a0:	953e                	add	a0,a0,a5
	__list_add(elm, listelm, listelm->next);
ffffffffc02032a2:	650c                	ld	a1,8(a0)
	if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02032a4:	7014                	ld	a3,32(s0)
	list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc02032a6:	0d840793          	addi	a5,s0,216
	prev->next = next->prev = elm;
ffffffffc02032aa:	e19c                	sd	a5,0(a1)
	__list_add(elm, listelm, listelm->next);
ffffffffc02032ac:	6490                	ld	a2,8(s1)
	prev->next = next->prev = elm;
ffffffffc02032ae:	e51c                	sd	a5,8(a0)
	if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02032b0:	7af8                	ld	a4,240(a3)
	list_add(&proc_list, &(proc->list_link));
ffffffffc02032b2:	0c840793          	addi	a5,s0,200
	elm->next = next;
ffffffffc02032b6:	f06c                	sd	a1,224(s0)
	elm->prev = prev;
ffffffffc02032b8:	ec68                	sd	a0,216(s0)
	prev->next = next->prev = elm;
ffffffffc02032ba:	e21c                	sd	a5,0(a2)
ffffffffc02032bc:	e49c                	sd	a5,8(s1)
	elm->next = next;
ffffffffc02032be:	e870                	sd	a2,208(s0)
	elm->prev = prev;
ffffffffc02032c0:	e464                	sd	s1,200(s0)
	proc->yptr = NULL;
ffffffffc02032c2:	0e043c23          	sd	zero,248(s0)
	if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc02032c6:	10e43023          	sd	a4,256(s0)
ffffffffc02032ca:	c311                	beqz	a4,ffffffffc02032ce <do_fork+0x1a4>
		proc->optr->yptr = proc;
ffffffffc02032cc:	ff60                	sd	s0,248(a4)
	nr_process++;
ffffffffc02032ce:	000a2783          	lw	a5,0(s4)
	proc->parent->cptr = proc;
ffffffffc02032d2:	fae0                	sd	s0,240(a3)
	nr_process++;
ffffffffc02032d4:	2785                	addiw	a5,a5,1
ffffffffc02032d6:	00fa2023          	sw	a5,0(s4)
	if (flag) {
ffffffffc02032da:	14091863          	bnez	s2,ffffffffc020342a <do_fork+0x300>
	wakeup_proc(proc);
ffffffffc02032de:	8522                	mv	a0,s0
ffffffffc02032e0:	52d000ef          	jal	ra,ffffffffc020400c <wakeup_proc>
	ret = proc->pid;
ffffffffc02032e4:	4048                	lw	a0,4(s0)
}
ffffffffc02032e6:	70a6                	ld	ra,104(sp)
ffffffffc02032e8:	7406                	ld	s0,96(sp)
ffffffffc02032ea:	64e6                	ld	s1,88(sp)
ffffffffc02032ec:	6946                	ld	s2,80(sp)
ffffffffc02032ee:	69a6                	ld	s3,72(sp)
ffffffffc02032f0:	6a06                	ld	s4,64(sp)
ffffffffc02032f2:	7ae2                	ld	s5,56(sp)
ffffffffc02032f4:	7b42                	ld	s6,48(sp)
ffffffffc02032f6:	7ba2                	ld	s7,40(sp)
ffffffffc02032f8:	7c02                	ld	s8,32(sp)
ffffffffc02032fa:	6ce2                	ld	s9,24(sp)
ffffffffc02032fc:	6d42                	ld	s10,16(sp)
ffffffffc02032fe:	6da2                	ld	s11,8(sp)
ffffffffc0203300:	6165                	addi	sp,sp,112
ffffffffc0203302:	8082                	ret
		last_pid = 1;
ffffffffc0203304:	4785                	li	a5,1
ffffffffc0203306:	c19c                	sw	a5,0(a1)
		goto inside;
ffffffffc0203308:	4505                	li	a0,1
ffffffffc020330a:	00010897          	auipc	a7,0x10
ffffffffc020330e:	49288893          	addi	a7,a7,1170 # ffffffffc021379c <next_safe.1670>
	return listelm->next;
ffffffffc0203312:	0001b497          	auipc	s1,0x1b
ffffffffc0203316:	60e48493          	addi	s1,s1,1550 # ffffffffc021e920 <proc_list>
ffffffffc020331a:	0084b303          	ld	t1,8(s1)
		next_safe = MAX_PID;
ffffffffc020331e:	6789                	lui	a5,0x2
ffffffffc0203320:	00f8a023          	sw	a5,0(a7)
ffffffffc0203324:	4801                	li	a6,0
ffffffffc0203326:	87aa                	mv	a5,a0
		while ((le = list_next(le)) != list) {
ffffffffc0203328:	6e89                	lui	t4,0x2
ffffffffc020332a:	10930c63          	beq	t1,s1,ffffffffc0203442 <do_fork+0x318>
ffffffffc020332e:	8e42                	mv	t3,a6
ffffffffc0203330:	869a                	mv	a3,t1
ffffffffc0203332:	6609                	lui	a2,0x2
ffffffffc0203334:	a811                	j	ffffffffc0203348 <do_fork+0x21e>
			} else if (proc->pid > last_pid &&
ffffffffc0203336:	00e7d663          	bge	a5,a4,ffffffffc0203342 <do_fork+0x218>
ffffffffc020333a:	00c75463          	bge	a4,a2,ffffffffc0203342 <do_fork+0x218>
ffffffffc020333e:	863a                	mv	a2,a4
ffffffffc0203340:	4e05                	li	t3,1
ffffffffc0203342:	6694                	ld	a3,8(a3)
		while ((le = list_next(le)) != list) {
ffffffffc0203344:	00968d63          	beq	a3,s1,ffffffffc020335e <do_fork+0x234>
			if (proc->pid == last_pid) {
ffffffffc0203348:	f3c6a703          	lw	a4,-196(a3) # ffffffffc01fff3c <_binary_obj___user_hello_out_size+0xffffffffc01f67fc>
ffffffffc020334c:	fee795e3          	bne	a5,a4,ffffffffc0203336 <do_fork+0x20c>
				if (++last_pid >= next_safe) {
ffffffffc0203350:	2785                	addiw	a5,a5,1
ffffffffc0203352:	0cc7df63          	bge	a5,a2,ffffffffc0203430 <do_fork+0x306>
ffffffffc0203356:	6694                	ld	a3,8(a3)
ffffffffc0203358:	4805                	li	a6,1
		while ((le = list_next(le)) != list) {
ffffffffc020335a:	fe9697e3          	bne	a3,s1,ffffffffc0203348 <do_fork+0x21e>
ffffffffc020335e:	00080463          	beqz	a6,ffffffffc0203366 <do_fork+0x23c>
ffffffffc0203362:	c19c                	sw	a5,0(a1)
ffffffffc0203364:	853e                	mv	a0,a5
ffffffffc0203366:	f20e02e3          	beqz	t3,ffffffffc020328a <do_fork+0x160>
ffffffffc020336a:	00c8a023          	sw	a2,0(a7)
ffffffffc020336e:	bf31                	j	ffffffffc020328a <do_fork+0x160>
	proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf - 4 : esp;
ffffffffc0203370:	6909                	lui	s2,0x2
ffffffffc0203372:	edc90913          	addi	s2,s2,-292 # 1edc <_binary_obj___user_hello_out_size-0x7864>
ffffffffc0203376:	9936                	add	s2,s2,a3
ffffffffc0203378:	0127b823          	sd	s2,16(a5) # 2010 <_binary_obj___user_hello_out_size-0x7730>
	proc->context.ra = (uintptr_t)forkret;
ffffffffc020337c:	00000717          	auipc	a4,0x0
ffffffffc0203380:	b4670713          	addi	a4,a4,-1210 # ffffffffc0202ec2 <forkret>
ffffffffc0203384:	f818                	sd	a4,48(s0)
	proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0203386:	fc1c                	sd	a5,56(s0)
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203388:	100027f3          	csrr	a5,sstatus
ffffffffc020338c:	8b89                	andi	a5,a5,2
	return 0;
ffffffffc020338e:	4901                	li	s2,0
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203390:	ec0786e3          	beqz	a5,ffffffffc020325c <do_fork+0x132>
		intr_disable();
ffffffffc0203394:	efffc0ef          	jal	ra,ffffffffc0200292 <intr_disable>
		return 1;
ffffffffc0203398:	4905                	li	s2,1
ffffffffc020339a:	b5c9                	j	ffffffffc020325c <do_fork+0x132>
	if ((mm = mm_create()) == NULL) {
ffffffffc020339c:	b7cfe0ef          	jal	ra,ffffffffc0201718 <mm_create>
ffffffffc02033a0:	89aa                	mv	s3,a0
ffffffffc02033a2:	c539                	beqz	a0,ffffffffc02033f0 <do_fork+0x2c6>
	if (setup_pgdir(mm) != 0) {
ffffffffc02033a4:	c13ff0ef          	jal	ra,ffffffffc0202fb6 <setup_pgdir>
ffffffffc02033a8:	e949                	bnez	a0,ffffffffc020343a <do_fork+0x310>
}

static inline void lock_mm(struct mm_struct *mm)
{
	if (mm != NULL) {
		lock(&(mm->mm_lock));
ffffffffc02033aa:	034c0d93          	addi	s11,s8,52
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr)
{
	return __test_and_op_bit(or, __NOP, nr,
ffffffffc02033ae:	4785                	li	a5,1
ffffffffc02033b0:	40fdb7af          	amoor.d	a5,a5,(s11)
	return !test_and_set_bit(0, lock);
}

static inline void lock(lock_t *lock)
{
	while (!try_lock(lock)) {
ffffffffc02033b4:	8b85                	andi	a5,a5,1
ffffffffc02033b6:	4d05                	li	s10,1
ffffffffc02033b8:	c799                	beqz	a5,ffffffffc02033c6 <do_fork+0x29c>
		schedule();
ffffffffc02033ba:	4d3000ef          	jal	ra,ffffffffc020408c <schedule>
ffffffffc02033be:	41adb7af          	amoor.d	a5,s10,(s11)
	while (!try_lock(lock)) {
ffffffffc02033c2:	8b85                	andi	a5,a5,1
ffffffffc02033c4:	fbfd                	bnez	a5,ffffffffc02033ba <do_fork+0x290>
		ret = dup_mmap(mm, oldmm);
ffffffffc02033c6:	85e2                	mv	a1,s8
ffffffffc02033c8:	854e                	mv	a0,s3
ffffffffc02033ca:	da6fe0ef          	jal	ra,ffffffffc0201970 <dup_mmap>
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr)
{
	return __test_and_op_bit(and, __NOT, nr,
ffffffffc02033ce:	57f9                	li	a5,-2
ffffffffc02033d0:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc02033d4:	8b85                	andi	a5,a5,1
	}
}

static inline void unlock(lock_t *lock)
{
	if (!test_and_clear_bit(0, lock)) {
ffffffffc02033d6:	cbe1                	beqz	a5,ffffffffc02034a6 <do_fork+0x37c>
good_mm:
ffffffffc02033d8:	8c4e                	mv	s8,s3
	if (ret != 0) {
ffffffffc02033da:	e00505e3          	beqz	a0,ffffffffc02031e4 <do_fork+0xba>
	exit_mmap(mm);
ffffffffc02033de:	854e                	mv	a0,s3
ffffffffc02033e0:	e2afe0ef          	jal	ra,ffffffffc0201a0a <exit_mmap>
	put_pgdir(mm);
ffffffffc02033e4:	854e                	mv	a0,s3
ffffffffc02033e6:	b5bff0ef          	jal	ra,ffffffffc0202f40 <put_pgdir>
	mm_destroy(mm);
ffffffffc02033ea:	854e                	mv	a0,s3
ffffffffc02033ec:	c84fe0ef          	jal	ra,ffffffffc0201870 <mm_destroy>
	free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02033f0:	6814                	ld	a3,16(s0)
	return pa2page(PADDR(kva));
ffffffffc02033f2:	c02007b7          	lui	a5,0xc0200
ffffffffc02033f6:	0ef6e063          	bltu	a3,a5,ffffffffc02034d6 <do_fork+0x3ac>
ffffffffc02033fa:	000cb783          	ld	a5,0(s9)
	if (PPN(pa) >= npage) {
ffffffffc02033fe:	000bb703          	ld	a4,0(s7)
	return pa2page(PADDR(kva));
ffffffffc0203402:	40f687b3          	sub	a5,a3,a5
	if (PPN(pa) >= npage) {
ffffffffc0203406:	83b1                	srli	a5,a5,0xc
ffffffffc0203408:	0ae7fb63          	bgeu	a5,a4,ffffffffc02034be <do_fork+0x394>
	return &pages[PPN(pa) - nbase];
ffffffffc020340c:	000b3703          	ld	a4,0(s6)
ffffffffc0203410:	000ab503          	ld	a0,0(s5)
ffffffffc0203414:	4589                	li	a1,2
ffffffffc0203416:	8f99                	sub	a5,a5,a4
ffffffffc0203418:	079a                	slli	a5,a5,0x6
ffffffffc020341a:	953e                	add	a0,a0,a5
ffffffffc020341c:	db0fd0ef          	jal	ra,ffffffffc02009cc <free_pages>
	kfree(proc);
ffffffffc0203420:	8522                	mv	a0,s0
ffffffffc0203422:	a9ffe0ef          	jal	ra,ffffffffc0201ec0 <kfree>
	ret = -E_NO_MEM;
ffffffffc0203426:	5571                	li	a0,-4
	return ret;
ffffffffc0203428:	bd7d                	j	ffffffffc02032e6 <do_fork+0x1bc>
		intr_enable();
ffffffffc020342a:	e63fc0ef          	jal	ra,ffffffffc020028c <intr_enable>
ffffffffc020342e:	bd45                	j	ffffffffc02032de <do_fork+0x1b4>
					if (last_pid >= MAX_PID) {
ffffffffc0203430:	01d7c363          	blt	a5,t4,ffffffffc0203436 <do_fork+0x30c>
						last_pid = 1;
ffffffffc0203434:	4785                	li	a5,1
					goto repeat;
ffffffffc0203436:	4805                	li	a6,1
ffffffffc0203438:	bdcd                	j	ffffffffc020332a <do_fork+0x200>
	mm_destroy(mm);
ffffffffc020343a:	854e                	mv	a0,s3
ffffffffc020343c:	c34fe0ef          	jal	ra,ffffffffc0201870 <mm_destroy>
ffffffffc0203440:	bf45                	j	ffffffffc02033f0 <do_fork+0x2c6>
ffffffffc0203442:	00080763          	beqz	a6,ffffffffc0203450 <do_fork+0x326>
ffffffffc0203446:	c19c                	sw	a5,0(a1)
ffffffffc0203448:	853e                	mv	a0,a5
ffffffffc020344a:	b581                	j	ffffffffc020328a <do_fork+0x160>
	int ret = -E_NO_FREE_PROC;
ffffffffc020344c:	556d                	li	a0,-5
ffffffffc020344e:	bd61                	j	ffffffffc02032e6 <do_fork+0x1bc>
ffffffffc0203450:	4188                	lw	a0,0(a1)
ffffffffc0203452:	bd25                	j	ffffffffc020328a <do_fork+0x160>
	return KADDR(page2pa(page));
ffffffffc0203454:	00002617          	auipc	a2,0x2
ffffffffc0203458:	9ac60613          	addi	a2,a2,-1620 # ffffffffc0204e00 <etext+0x7be>
ffffffffc020345c:	07200593          	li	a1,114
ffffffffc0203460:	00002517          	auipc	a0,0x2
ffffffffc0203464:	90050513          	addi	a0,a0,-1792 # ffffffffc0204d60 <etext+0x71e>
ffffffffc0203468:	cd1fc0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(current->wait_state == 0);
ffffffffc020346c:	00002697          	auipc	a3,0x2
ffffffffc0203470:	45c68693          	addi	a3,a3,1116 # ffffffffc02058c8 <default_pmm_manager+0xf8>
ffffffffc0203474:	00001617          	auipc	a2,0x1
ffffffffc0203478:	5dc60613          	addi	a2,a2,1500 # ffffffffc0204a50 <etext+0x40e>
ffffffffc020347c:	18600593          	li	a1,390
ffffffffc0203480:	00002517          	auipc	a0,0x2
ffffffffc0203484:	43050513          	addi	a0,a0,1072 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0203488:	cb1fc0ef          	jal	ra,ffffffffc0200138 <__panic>
	proc->satp = PADDR(mm->pgdir);
ffffffffc020348c:	86be                	mv	a3,a5
ffffffffc020348e:	00002617          	auipc	a2,0x2
ffffffffc0203492:	93a60613          	addi	a2,a2,-1734 # ffffffffc0204dc8 <etext+0x786>
ffffffffc0203496:	14700593          	li	a1,327
ffffffffc020349a:	00002517          	auipc	a0,0x2
ffffffffc020349e:	41650513          	addi	a0,a0,1046 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc02034a2:	c97fc0ef          	jal	ra,ffffffffc0200138 <__panic>
		panic("Unlock failed.\n");
ffffffffc02034a6:	00002617          	auipc	a2,0x2
ffffffffc02034aa:	44260613          	addi	a2,a2,1090 # ffffffffc02058e8 <default_pmm_manager+0x118>
ffffffffc02034ae:	03600593          	li	a1,54
ffffffffc02034b2:	00002517          	auipc	a0,0x2
ffffffffc02034b6:	44650513          	addi	a0,a0,1094 # ffffffffc02058f8 <default_pmm_manager+0x128>
ffffffffc02034ba:	c7ffc0ef          	jal	ra,ffffffffc0200138 <__panic>
		panic("pa2page called with invalid pa");
ffffffffc02034be:	00002617          	auipc	a2,0x2
ffffffffc02034c2:	88260613          	addi	a2,a2,-1918 # ffffffffc0204d40 <etext+0x6fe>
ffffffffc02034c6:	06b00593          	li	a1,107
ffffffffc02034ca:	00002517          	auipc	a0,0x2
ffffffffc02034ce:	89650513          	addi	a0,a0,-1898 # ffffffffc0204d60 <etext+0x71e>
ffffffffc02034d2:	c67fc0ef          	jal	ra,ffffffffc0200138 <__panic>
	return pa2page(PADDR(kva));
ffffffffc02034d6:	00002617          	auipc	a2,0x2
ffffffffc02034da:	8f260613          	addi	a2,a2,-1806 # ffffffffc0204dc8 <etext+0x786>
ffffffffc02034de:	07700593          	li	a1,119
ffffffffc02034e2:	00002517          	auipc	a0,0x2
ffffffffc02034e6:	87e50513          	addi	a0,a0,-1922 # ffffffffc0204d60 <etext+0x71e>
ffffffffc02034ea:	c4ffc0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc02034ee <kernel_thread>:
{
ffffffffc02034ee:	7129                	addi	sp,sp,-320
ffffffffc02034f0:	fa22                	sd	s0,304(sp)
ffffffffc02034f2:	f626                	sd	s1,296(sp)
ffffffffc02034f4:	f24a                	sd	s2,288(sp)
ffffffffc02034f6:	84ae                	mv	s1,a1
ffffffffc02034f8:	892a                	mv	s2,a0
ffffffffc02034fa:	8432                	mv	s0,a2
	memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02034fc:	4581                	li	a1,0
ffffffffc02034fe:	12000613          	li	a2,288
ffffffffc0203502:	850a                	mv	a0,sp
{
ffffffffc0203504:	fe06                	sd	ra,312(sp)
	memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0203506:	50f000ef          	jal	ra,ffffffffc0204214 <memset>
	tf.gpr.s0 = (uintptr_t)fn;
ffffffffc020350a:	e0ca                	sd	s2,64(sp)
	tf.gpr.s1 = (uintptr_t)arg;
ffffffffc020350c:	e4a6                	sd	s1,72(sp)
	tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) &
ffffffffc020350e:	100027f3          	csrr	a5,sstatus
ffffffffc0203512:	edd7f793          	andi	a5,a5,-291
ffffffffc0203516:	1207e793          	ori	a5,a5,288
ffffffffc020351a:	e23e                	sd	a5,256(sp)
	return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020351c:	860a                	mv	a2,sp
ffffffffc020351e:	10046513          	ori	a0,s0,256
	tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0203522:	00000797          	auipc	a5,0x0
ffffffffc0203526:	8bc78793          	addi	a5,a5,-1860 # ffffffffc0202dde <kernel_thread_entry>
	return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020352a:	4581                	li	a1,0
	tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020352c:	e63e                	sd	a5,264(sp)
	return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020352e:	bfdff0ef          	jal	ra,ffffffffc020312a <do_fork>
}
ffffffffc0203532:	70f2                	ld	ra,312(sp)
ffffffffc0203534:	7452                	ld	s0,304(sp)
ffffffffc0203536:	74b2                	ld	s1,296(sp)
ffffffffc0203538:	7912                	ld	s2,288(sp)
ffffffffc020353a:	6131                	addi	sp,sp,320
ffffffffc020353c:	8082                	ret

ffffffffc020353e <do_exit>:
{
ffffffffc020353e:	7179                	addi	sp,sp,-48
ffffffffc0203540:	f022                	sd	s0,32(sp)
	if (current == idleproc) {
ffffffffc0203542:	0001b417          	auipc	s0,0x1b
ffffffffc0203546:	29e40413          	addi	s0,s0,670 # ffffffffc021e7e0 <current>
ffffffffc020354a:	601c                	ld	a5,0(s0)
{
ffffffffc020354c:	f406                	sd	ra,40(sp)
ffffffffc020354e:	ec26                	sd	s1,24(sp)
ffffffffc0203550:	e84a                	sd	s2,16(sp)
ffffffffc0203552:	e44e                	sd	s3,8(sp)
ffffffffc0203554:	e052                	sd	s4,0(sp)
	if (current == idleproc) {
ffffffffc0203556:	0001b717          	auipc	a4,0x1b
ffffffffc020355a:	29273703          	ld	a4,658(a4) # ffffffffc021e7e8 <idleproc>
ffffffffc020355e:	0ce78e63          	beq	a5,a4,ffffffffc020363a <do_exit+0xfc>
	if (current == initproc) {
ffffffffc0203562:	0001b497          	auipc	s1,0x1b
ffffffffc0203566:	28e48493          	addi	s1,s1,654 # ffffffffc021e7f0 <initproc>
ffffffffc020356a:	6098                	ld	a4,0(s1)
ffffffffc020356c:	0ee78d63          	beq	a5,a4,ffffffffc0203666 <do_exit+0x128>
	struct mm_struct *mm = current->mm;
ffffffffc0203570:	0287b983          	ld	s3,40(a5)
ffffffffc0203574:	892a                	mv	s2,a0
	if (mm != NULL) {
ffffffffc0203576:	02098863          	beqz	s3,ffffffffc02035a6 <do_exit+0x68>
	write_csr(satp, 0x8000000000000000 | (satp >> RISCV_PGSHIFT));
ffffffffc020357a:	0001b797          	auipc	a5,0x1b
ffffffffc020357e:	2967b783          	ld	a5,662(a5) # ffffffffc021e810 <boot_satp>
ffffffffc0203582:	577d                	li	a4,-1
ffffffffc0203584:	177e                	slli	a4,a4,0x3f
ffffffffc0203586:	83b1                	srli	a5,a5,0xc
ffffffffc0203588:	8fd9                	or	a5,a5,a4
ffffffffc020358a:	18079073          	csrw	satp,a5
        barrier();
ffffffffc020358e:	0ff0000f          	fence
	mm->mm_count -= 1;
ffffffffc0203592:	0309a783          	lw	a5,48(s3)
ffffffffc0203596:	fff7871b          	addiw	a4,a5,-1
ffffffffc020359a:	02e9a823          	sw	a4,48(s3)
		if (mm_count_dec(mm) == 0) {
ffffffffc020359e:	cb55                	beqz	a4,ffffffffc0203652 <do_exit+0x114>
		current->mm = NULL;
ffffffffc02035a0:	601c                	ld	a5,0(s0)
ffffffffc02035a2:	0207b423          	sd	zero,40(a5)
	current->state = PROC_ZOMBIE;
ffffffffc02035a6:	601c                	ld	a5,0(s0)
ffffffffc02035a8:	470d                	li	a4,3
ffffffffc02035aa:	c398                	sw	a4,0(a5)
	current->exit_code = error_code;
ffffffffc02035ac:	0f27a423          	sw	s2,232(a5)
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02035b0:	100027f3          	csrr	a5,sstatus
ffffffffc02035b4:	8b89                	andi	a5,a5,2
	return 0;
ffffffffc02035b6:	4a01                	li	s4,0
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02035b8:	e3f9                	bnez	a5,ffffffffc020367e <do_exit+0x140>
		proc = current->parent;
ffffffffc02035ba:	6018                	ld	a4,0(s0)
		if (proc->wait_state == WT_CHILD) {
ffffffffc02035bc:	800007b7          	lui	a5,0x80000
ffffffffc02035c0:	0785                	addi	a5,a5,1
		proc = current->parent;
ffffffffc02035c2:	7308                	ld	a0,32(a4)
		if (proc->wait_state == WT_CHILD) {
ffffffffc02035c4:	0ec52703          	lw	a4,236(a0)
ffffffffc02035c8:	0af70f63          	beq	a4,a5,ffffffffc0203686 <do_exit+0x148>
		while (current->cptr != NULL) {
ffffffffc02035cc:	6018                	ld	a4,0(s0)
ffffffffc02035ce:	7b7c                	ld	a5,240(a4)
ffffffffc02035d0:	c3a1                	beqz	a5,ffffffffc0203610 <do_exit+0xd2>
				if (initproc->wait_state == WT_CHILD) {
ffffffffc02035d2:	800009b7          	lui	s3,0x80000
			if (proc->state == PROC_ZOMBIE) {
ffffffffc02035d6:	490d                	li	s2,3
				if (initproc->wait_state == WT_CHILD) {
ffffffffc02035d8:	0985                	addi	s3,s3,1
ffffffffc02035da:	a021                	j	ffffffffc02035e2 <do_exit+0xa4>
		while (current->cptr != NULL) {
ffffffffc02035dc:	6018                	ld	a4,0(s0)
ffffffffc02035de:	7b7c                	ld	a5,240(a4)
ffffffffc02035e0:	cb85                	beqz	a5,ffffffffc0203610 <do_exit+0xd2>
			current->cptr = proc->optr;
ffffffffc02035e2:	1007b683          	ld	a3,256(a5) # ffffffff80000100 <_binary_obj___user_hello_out_size+0xffffffff7fff69c0>
			if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02035e6:	6088                	ld	a0,0(s1)
			current->cptr = proc->optr;
ffffffffc02035e8:	fb74                	sd	a3,240(a4)
			if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02035ea:	7978                	ld	a4,240(a0)
			proc->yptr = NULL;
ffffffffc02035ec:	0e07bc23          	sd	zero,248(a5)
			if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc02035f0:	10e7b023          	sd	a4,256(a5)
ffffffffc02035f4:	c311                	beqz	a4,ffffffffc02035f8 <do_exit+0xba>
				initproc->cptr->yptr = proc;
ffffffffc02035f6:	ff7c                	sd	a5,248(a4)
			if (proc->state == PROC_ZOMBIE) {
ffffffffc02035f8:	4398                	lw	a4,0(a5)
			proc->parent = initproc;
ffffffffc02035fa:	f388                	sd	a0,32(a5)
			initproc->cptr = proc;
ffffffffc02035fc:	f97c                	sd	a5,240(a0)
			if (proc->state == PROC_ZOMBIE) {
ffffffffc02035fe:	fd271fe3          	bne	a4,s2,ffffffffc02035dc <do_exit+0x9e>
				if (initproc->wait_state == WT_CHILD) {
ffffffffc0203602:	0ec52783          	lw	a5,236(a0)
ffffffffc0203606:	fd379be3          	bne	a5,s3,ffffffffc02035dc <do_exit+0x9e>
					wakeup_proc(initproc);
ffffffffc020360a:	203000ef          	jal	ra,ffffffffc020400c <wakeup_proc>
ffffffffc020360e:	b7f9                	j	ffffffffc02035dc <do_exit+0x9e>
	if (flag) {
ffffffffc0203610:	020a1263          	bnez	s4,ffffffffc0203634 <do_exit+0xf6>
	schedule();
ffffffffc0203614:	279000ef          	jal	ra,ffffffffc020408c <schedule>
	panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0203618:	601c                	ld	a5,0(s0)
ffffffffc020361a:	00002617          	auipc	a2,0x2
ffffffffc020361e:	31660613          	addi	a2,a2,790 # ffffffffc0205930 <default_pmm_manager+0x160>
ffffffffc0203622:	1db00593          	li	a1,475
ffffffffc0203626:	43d4                	lw	a3,4(a5)
ffffffffc0203628:	00002517          	auipc	a0,0x2
ffffffffc020362c:	28850513          	addi	a0,a0,648 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0203630:	b09fc0ef          	jal	ra,ffffffffc0200138 <__panic>
		intr_enable();
ffffffffc0203634:	c59fc0ef          	jal	ra,ffffffffc020028c <intr_enable>
ffffffffc0203638:	bff1                	j	ffffffffc0203614 <do_exit+0xd6>
		panic("idleproc exit.\n");
ffffffffc020363a:	00002617          	auipc	a2,0x2
ffffffffc020363e:	2d660613          	addi	a2,a2,726 # ffffffffc0205910 <default_pmm_manager+0x140>
ffffffffc0203642:	1af00593          	li	a1,431
ffffffffc0203646:	00002517          	auipc	a0,0x2
ffffffffc020364a:	26a50513          	addi	a0,a0,618 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc020364e:	aebfc0ef          	jal	ra,ffffffffc0200138 <__panic>
			exit_mmap(mm);
ffffffffc0203652:	854e                	mv	a0,s3
ffffffffc0203654:	bb6fe0ef          	jal	ra,ffffffffc0201a0a <exit_mmap>
			put_pgdir(mm);
ffffffffc0203658:	854e                	mv	a0,s3
ffffffffc020365a:	8e7ff0ef          	jal	ra,ffffffffc0202f40 <put_pgdir>
			mm_destroy(mm);
ffffffffc020365e:	854e                	mv	a0,s3
ffffffffc0203660:	a10fe0ef          	jal	ra,ffffffffc0201870 <mm_destroy>
ffffffffc0203664:	bf35                	j	ffffffffc02035a0 <do_exit+0x62>
		panic("initproc exit.\n");
ffffffffc0203666:	00002617          	auipc	a2,0x2
ffffffffc020366a:	2ba60613          	addi	a2,a2,698 # ffffffffc0205920 <default_pmm_manager+0x150>
ffffffffc020366e:	1b200593          	li	a1,434
ffffffffc0203672:	00002517          	auipc	a0,0x2
ffffffffc0203676:	23e50513          	addi	a0,a0,574 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc020367a:	abffc0ef          	jal	ra,ffffffffc0200138 <__panic>
		intr_disable();
ffffffffc020367e:	c15fc0ef          	jal	ra,ffffffffc0200292 <intr_disable>
		return 1;
ffffffffc0203682:	4a05                	li	s4,1
ffffffffc0203684:	bf1d                	j	ffffffffc02035ba <do_exit+0x7c>
			wakeup_proc(proc);
ffffffffc0203686:	187000ef          	jal	ra,ffffffffc020400c <wakeup_proc>
ffffffffc020368a:	b789                	j	ffffffffc02035cc <do_exit+0x8e>

ffffffffc020368c <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc020368c:	7139                	addi	sp,sp,-64
ffffffffc020368e:	e852                	sd	s4,16(sp)
		current->wait_state = WT_CHILD;
ffffffffc0203690:	80000a37          	lui	s4,0x80000
int do_wait(int pid, int *code_store)
ffffffffc0203694:	f426                	sd	s1,40(sp)
ffffffffc0203696:	f04a                	sd	s2,32(sp)
ffffffffc0203698:	ec4e                	sd	s3,24(sp)
ffffffffc020369a:	e456                	sd	s5,8(sp)
ffffffffc020369c:	e05a                	sd	s6,0(sp)
ffffffffc020369e:	fc06                	sd	ra,56(sp)
ffffffffc02036a0:	f822                	sd	s0,48(sp)
ffffffffc02036a2:	892a                	mv	s2,a0
ffffffffc02036a4:	8aae                	mv	s5,a1
		proc = current->cptr;
ffffffffc02036a6:	0001b997          	auipc	s3,0x1b
ffffffffc02036aa:	13a98993          	addi	s3,s3,314 # ffffffffc021e7e0 <current>
			if (proc->state == PROC_ZOMBIE) {
ffffffffc02036ae:	448d                	li	s1,3
		current->state = PROC_SLEEPING;
ffffffffc02036b0:	4b05                	li	s6,1
		current->wait_state = WT_CHILD;
ffffffffc02036b2:	2a05                	addiw	s4,s4,1
	if (pid != 0) {
ffffffffc02036b4:	02090f63          	beqz	s2,ffffffffc02036f2 <do_wait.part.0+0x66>
		proc = find_proc(pid);
ffffffffc02036b8:	854a                	mv	a0,s2
ffffffffc02036ba:	a19ff0ef          	jal	ra,ffffffffc02030d2 <find_proc>
ffffffffc02036be:	842a                	mv	s0,a0
		if (proc != NULL && proc->parent == current) {
ffffffffc02036c0:	10050763          	beqz	a0,ffffffffc02037ce <do_wait.part.0+0x142>
ffffffffc02036c4:	0009b703          	ld	a4,0(s3)
ffffffffc02036c8:	711c                	ld	a5,32(a0)
ffffffffc02036ca:	10e79263          	bne	a5,a4,ffffffffc02037ce <do_wait.part.0+0x142>
			if (proc->state == PROC_ZOMBIE) {
ffffffffc02036ce:	411c                	lw	a5,0(a0)
ffffffffc02036d0:	02978c63          	beq	a5,s1,ffffffffc0203708 <do_wait.part.0+0x7c>
		current->state = PROC_SLEEPING;
ffffffffc02036d4:	01672023          	sw	s6,0(a4)
		current->wait_state = WT_CHILD;
ffffffffc02036d8:	0f472623          	sw	s4,236(a4)
		schedule();
ffffffffc02036dc:	1b1000ef          	jal	ra,ffffffffc020408c <schedule>
		if (current->flags & PF_EXITING) {
ffffffffc02036e0:	0009b783          	ld	a5,0(s3)
ffffffffc02036e4:	0b07a783          	lw	a5,176(a5)
ffffffffc02036e8:	8b85                	andi	a5,a5,1
ffffffffc02036ea:	d7e9                	beqz	a5,ffffffffc02036b4 <do_wait.part.0+0x28>
			do_exit(-E_KILLED);
ffffffffc02036ec:	555d                	li	a0,-9
ffffffffc02036ee:	e51ff0ef          	jal	ra,ffffffffc020353e <do_exit>
		proc = current->cptr;
ffffffffc02036f2:	0009b703          	ld	a4,0(s3)
ffffffffc02036f6:	7b60                	ld	s0,240(a4)
		for (; proc != NULL; proc = proc->optr) {
ffffffffc02036f8:	e409                	bnez	s0,ffffffffc0203702 <do_wait.part.0+0x76>
ffffffffc02036fa:	a8d1                	j	ffffffffc02037ce <do_wait.part.0+0x142>
ffffffffc02036fc:	10043403          	ld	s0,256(s0)
ffffffffc0203700:	d871                	beqz	s0,ffffffffc02036d4 <do_wait.part.0+0x48>
			if (proc->state == PROC_ZOMBIE) {
ffffffffc0203702:	401c                	lw	a5,0(s0)
ffffffffc0203704:	fe979ce3          	bne	a5,s1,ffffffffc02036fc <do_wait.part.0+0x70>
	if (proc == idleproc || proc == initproc) {
ffffffffc0203708:	0001b797          	auipc	a5,0x1b
ffffffffc020370c:	0e07b783          	ld	a5,224(a5) # ffffffffc021e7e8 <idleproc>
ffffffffc0203710:	0c878563          	beq	a5,s0,ffffffffc02037da <do_wait.part.0+0x14e>
ffffffffc0203714:	0001b797          	auipc	a5,0x1b
ffffffffc0203718:	0dc7b783          	ld	a5,220(a5) # ffffffffc021e7f0 <initproc>
ffffffffc020371c:	0af40f63          	beq	s0,a5,ffffffffc02037da <do_wait.part.0+0x14e>
	if (code_store != NULL) {
ffffffffc0203720:	000a8663          	beqz	s5,ffffffffc020372c <do_wait.part.0+0xa0>
		*code_store = proc->exit_code;
ffffffffc0203724:	0e842783          	lw	a5,232(s0)
ffffffffc0203728:	00faa023          	sw	a5,0(s5)
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020372c:	100027f3          	csrr	a5,sstatus
ffffffffc0203730:	8b89                	andi	a5,a5,2
	return 0;
ffffffffc0203732:	4581                	li	a1,0
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0203734:	efd9                	bnez	a5,ffffffffc02037d2 <do_wait.part.0+0x146>
	__list_del(listelm->prev, listelm->next);
ffffffffc0203736:	6c70                	ld	a2,216(s0)
ffffffffc0203738:	7074                	ld	a3,224(s0)
	if (proc->optr != NULL) {
ffffffffc020373a:	10043703          	ld	a4,256(s0)
ffffffffc020373e:	7c7c                	ld	a5,248(s0)
	prev->next = next;
ffffffffc0203740:	e614                	sd	a3,8(a2)
	next->prev = prev;
ffffffffc0203742:	e290                	sd	a2,0(a3)
	__list_del(listelm->prev, listelm->next);
ffffffffc0203744:	6470                	ld	a2,200(s0)
ffffffffc0203746:	6874                	ld	a3,208(s0)
	prev->next = next;
ffffffffc0203748:	e614                	sd	a3,8(a2)
	next->prev = prev;
ffffffffc020374a:	e290                	sd	a2,0(a3)
ffffffffc020374c:	c319                	beqz	a4,ffffffffc0203752 <do_wait.part.0+0xc6>
		proc->optr->yptr = proc->yptr;
ffffffffc020374e:	ff7c                	sd	a5,248(a4)
ffffffffc0203750:	7c7c                	ld	a5,248(s0)
	if (proc->yptr != NULL) {
ffffffffc0203752:	cbbd                	beqz	a5,ffffffffc02037c8 <do_wait.part.0+0x13c>
		proc->yptr->optr = proc->optr;
ffffffffc0203754:	10e7b023          	sd	a4,256(a5)
	nr_process--;
ffffffffc0203758:	0001b717          	auipc	a4,0x1b
ffffffffc020375c:	0a070713          	addi	a4,a4,160 # ffffffffc021e7f8 <nr_process>
ffffffffc0203760:	431c                	lw	a5,0(a4)
ffffffffc0203762:	37fd                	addiw	a5,a5,-1
ffffffffc0203764:	c31c                	sw	a5,0(a4)
	if (flag) {
ffffffffc0203766:	edb1                	bnez	a1,ffffffffc02037c2 <do_wait.part.0+0x136>
	free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0203768:	6814                	ld	a3,16(s0)
ffffffffc020376a:	c02007b7          	lui	a5,0xc0200
ffffffffc020376e:	08f6ee63          	bltu	a3,a5,ffffffffc020380a <do_wait.part.0+0x17e>
ffffffffc0203772:	0001b797          	auipc	a5,0x1b
ffffffffc0203776:	0a67b783          	ld	a5,166(a5) # ffffffffc021e818 <va_pa_offset>
ffffffffc020377a:	8e9d                	sub	a3,a3,a5
	if (PPN(pa) >= npage) {
ffffffffc020377c:	82b1                	srli	a3,a3,0xc
ffffffffc020377e:	0001b797          	auipc	a5,0x1b
ffffffffc0203782:	03a7b783          	ld	a5,58(a5) # ffffffffc021e7b8 <npage>
ffffffffc0203786:	06f6f663          	bgeu	a3,a5,ffffffffc02037f2 <do_wait.part.0+0x166>
	return &pages[PPN(pa) - nbase];
ffffffffc020378a:	00003517          	auipc	a0,0x3
ffffffffc020378e:	9de53503          	ld	a0,-1570(a0) # ffffffffc0206168 <nbase>
ffffffffc0203792:	8e89                	sub	a3,a3,a0
ffffffffc0203794:	069a                	slli	a3,a3,0x6
ffffffffc0203796:	0001b517          	auipc	a0,0x1b
ffffffffc020379a:	08a53503          	ld	a0,138(a0) # ffffffffc021e820 <pages>
ffffffffc020379e:	9536                	add	a0,a0,a3
ffffffffc02037a0:	4589                	li	a1,2
ffffffffc02037a2:	a2afd0ef          	jal	ra,ffffffffc02009cc <free_pages>
	kfree(proc);
ffffffffc02037a6:	8522                	mv	a0,s0
ffffffffc02037a8:	f18fe0ef          	jal	ra,ffffffffc0201ec0 <kfree>
	return 0;
ffffffffc02037ac:	4501                	li	a0,0
}
ffffffffc02037ae:	70e2                	ld	ra,56(sp)
ffffffffc02037b0:	7442                	ld	s0,48(sp)
ffffffffc02037b2:	74a2                	ld	s1,40(sp)
ffffffffc02037b4:	7902                	ld	s2,32(sp)
ffffffffc02037b6:	69e2                	ld	s3,24(sp)
ffffffffc02037b8:	6a42                	ld	s4,16(sp)
ffffffffc02037ba:	6aa2                	ld	s5,8(sp)
ffffffffc02037bc:	6b02                	ld	s6,0(sp)
ffffffffc02037be:	6121                	addi	sp,sp,64
ffffffffc02037c0:	8082                	ret
		intr_enable();
ffffffffc02037c2:	acbfc0ef          	jal	ra,ffffffffc020028c <intr_enable>
ffffffffc02037c6:	b74d                	j	ffffffffc0203768 <do_wait.part.0+0xdc>
		proc->parent->cptr = proc->optr;
ffffffffc02037c8:	701c                	ld	a5,32(s0)
ffffffffc02037ca:	fbf8                	sd	a4,240(a5)
ffffffffc02037cc:	b771                	j	ffffffffc0203758 <do_wait.part.0+0xcc>
	return -E_BAD_PROC;
ffffffffc02037ce:	5579                	li	a0,-2
ffffffffc02037d0:	bff9                	j	ffffffffc02037ae <do_wait.part.0+0x122>
		intr_disable();
ffffffffc02037d2:	ac1fc0ef          	jal	ra,ffffffffc0200292 <intr_disable>
		return 1;
ffffffffc02037d6:	4585                	li	a1,1
ffffffffc02037d8:	bfb9                	j	ffffffffc0203736 <do_wait.part.0+0xaa>
		panic("wait idleproc or initproc.\n");
ffffffffc02037da:	00002617          	auipc	a2,0x2
ffffffffc02037de:	17660613          	addi	a2,a2,374 # ffffffffc0205950 <default_pmm_manager+0x180>
ffffffffc02037e2:	2e200593          	li	a1,738
ffffffffc02037e6:	00002517          	auipc	a0,0x2
ffffffffc02037ea:	0ca50513          	addi	a0,a0,202 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc02037ee:	94bfc0ef          	jal	ra,ffffffffc0200138 <__panic>
		panic("pa2page called with invalid pa");
ffffffffc02037f2:	00001617          	auipc	a2,0x1
ffffffffc02037f6:	54e60613          	addi	a2,a2,1358 # ffffffffc0204d40 <etext+0x6fe>
ffffffffc02037fa:	06b00593          	li	a1,107
ffffffffc02037fe:	00001517          	auipc	a0,0x1
ffffffffc0203802:	56250513          	addi	a0,a0,1378 # ffffffffc0204d60 <etext+0x71e>
ffffffffc0203806:	933fc0ef          	jal	ra,ffffffffc0200138 <__panic>
	return pa2page(PADDR(kva));
ffffffffc020380a:	00001617          	auipc	a2,0x1
ffffffffc020380e:	5be60613          	addi	a2,a2,1470 # ffffffffc0204dc8 <etext+0x786>
ffffffffc0203812:	07700593          	li	a1,119
ffffffffc0203816:	00001517          	auipc	a0,0x1
ffffffffc020381a:	54a50513          	addi	a0,a0,1354 # ffffffffc0204d60 <etext+0x71e>
ffffffffc020381e:	91bfc0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0203822 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int init_main(void *arg)
{
ffffffffc0203822:	1141                	addi	sp,sp,-16
ffffffffc0203824:	e406                	sd	ra,8(sp)
	size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203826:	9e8fd0ef          	jal	ra,ffffffffc0200a0e <nr_free_pages>
	// size_t kernel_allocated_store = kallocated();

	int pid = kernel_thread(user_main, NULL, 0); // 2 user_main
ffffffffc020382a:	4601                	li	a2,0
ffffffffc020382c:	4581                	li	a1,0
ffffffffc020382e:	fffff517          	auipc	a0,0xfffff
ffffffffc0203832:	6a250513          	addi	a0,a0,1698 # ffffffffc0202ed0 <user_main>
ffffffffc0203836:	cb9ff0ef          	jal	ra,ffffffffc02034ee <kernel_thread>
	if (pid <= 0) {
ffffffffc020383a:	00a04563          	bgtz	a0,ffffffffc0203844 <init_main+0x22>
ffffffffc020383e:	a071                	j	ffffffffc02038ca <init_main+0xa8>
		panic("create user_main failed.\n");
	}

	while (do_wait(0, NULL) == 0) {
		schedule();
ffffffffc0203840:	04d000ef          	jal	ra,ffffffffc020408c <schedule>
	if (code_store != NULL) {
ffffffffc0203844:	4581                	li	a1,0
ffffffffc0203846:	4501                	li	a0,0
ffffffffc0203848:	e45ff0ef          	jal	ra,ffffffffc020368c <do_wait.part.0>
	while (do_wait(0, NULL) == 0) {
ffffffffc020384c:	d975                	beqz	a0,ffffffffc0203840 <init_main+0x1e>
	}

	cprintf("all user-mode processes have quit.\n");
ffffffffc020384e:	00002517          	auipc	a0,0x2
ffffffffc0203852:	14250513          	addi	a0,a0,322 # ffffffffc0205990 <default_pmm_manager+0x1c0>
ffffffffc0203856:	86bfc0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	assert(initproc->cptr == NULL && initproc->yptr == NULL &&
ffffffffc020385a:	0001b797          	auipc	a5,0x1b
ffffffffc020385e:	f967b783          	ld	a5,-106(a5) # ffffffffc021e7f0 <initproc>
ffffffffc0203862:	7bf8                	ld	a4,240(a5)
ffffffffc0203864:	e339                	bnez	a4,ffffffffc02038aa <init_main+0x88>
ffffffffc0203866:	7ff8                	ld	a4,248(a5)
ffffffffc0203868:	e329                	bnez	a4,ffffffffc02038aa <init_main+0x88>
ffffffffc020386a:	1007b703          	ld	a4,256(a5)
ffffffffc020386e:	ef15                	bnez	a4,ffffffffc02038aa <init_main+0x88>
	       initproc->optr == NULL);
	assert(nr_process == 2);
ffffffffc0203870:	0001b697          	auipc	a3,0x1b
ffffffffc0203874:	f886a683          	lw	a3,-120(a3) # ffffffffc021e7f8 <nr_process>
ffffffffc0203878:	4709                	li	a4,2
ffffffffc020387a:	0ae69463          	bne	a3,a4,ffffffffc0203922 <init_main+0x100>
	return listelm->next;
ffffffffc020387e:	0001b697          	auipc	a3,0x1b
ffffffffc0203882:	0a268693          	addi	a3,a3,162 # ffffffffc021e920 <proc_list>
	assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0203886:	6698                	ld	a4,8(a3)
ffffffffc0203888:	0c878793          	addi	a5,a5,200
ffffffffc020388c:	06f71b63          	bne	a4,a5,ffffffffc0203902 <init_main+0xe0>
	assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0203890:	629c                	ld	a5,0(a3)
ffffffffc0203892:	04f71863          	bne	a4,a5,ffffffffc02038e2 <init_main+0xc0>

	cprintf("init check memory pass.\n");
ffffffffc0203896:	00002517          	auipc	a0,0x2
ffffffffc020389a:	1e250513          	addi	a0,a0,482 # ffffffffc0205a78 <default_pmm_manager+0x2a8>
ffffffffc020389e:	823fc0ef          	jal	ra,ffffffffc02000c0 <cprintf>
	return 0;
}
ffffffffc02038a2:	60a2                	ld	ra,8(sp)
ffffffffc02038a4:	4501                	li	a0,0
ffffffffc02038a6:	0141                	addi	sp,sp,16
ffffffffc02038a8:	8082                	ret
	assert(initproc->cptr == NULL && initproc->yptr == NULL &&
ffffffffc02038aa:	00002697          	auipc	a3,0x2
ffffffffc02038ae:	10e68693          	addi	a3,a3,270 # ffffffffc02059b8 <default_pmm_manager+0x1e8>
ffffffffc02038b2:	00001617          	auipc	a2,0x1
ffffffffc02038b6:	19e60613          	addi	a2,a2,414 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02038ba:	33e00593          	li	a1,830
ffffffffc02038be:	00002517          	auipc	a0,0x2
ffffffffc02038c2:	ff250513          	addi	a0,a0,-14 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc02038c6:	873fc0ef          	jal	ra,ffffffffc0200138 <__panic>
		panic("create user_main failed.\n");
ffffffffc02038ca:	00002617          	auipc	a2,0x2
ffffffffc02038ce:	0a660613          	addi	a2,a2,166 # ffffffffc0205970 <default_pmm_manager+0x1a0>
ffffffffc02038d2:	33600593          	li	a1,822
ffffffffc02038d6:	00002517          	auipc	a0,0x2
ffffffffc02038da:	fda50513          	addi	a0,a0,-38 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc02038de:	85bfc0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02038e2:	00002697          	auipc	a3,0x2
ffffffffc02038e6:	16668693          	addi	a3,a3,358 # ffffffffc0205a48 <default_pmm_manager+0x278>
ffffffffc02038ea:	00001617          	auipc	a2,0x1
ffffffffc02038ee:	16660613          	addi	a2,a2,358 # ffffffffc0204a50 <etext+0x40e>
ffffffffc02038f2:	34200593          	li	a1,834
ffffffffc02038f6:	00002517          	auipc	a0,0x2
ffffffffc02038fa:	fba50513          	addi	a0,a0,-70 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc02038fe:	83bfc0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0203902:	00002697          	auipc	a3,0x2
ffffffffc0203906:	11668693          	addi	a3,a3,278 # ffffffffc0205a18 <default_pmm_manager+0x248>
ffffffffc020390a:	00001617          	auipc	a2,0x1
ffffffffc020390e:	14660613          	addi	a2,a2,326 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0203912:	34100593          	li	a1,833
ffffffffc0203916:	00002517          	auipc	a0,0x2
ffffffffc020391a:	f9a50513          	addi	a0,a0,-102 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc020391e:	81bfc0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(nr_process == 2);
ffffffffc0203922:	00002697          	auipc	a3,0x2
ffffffffc0203926:	0e668693          	addi	a3,a3,230 # ffffffffc0205a08 <default_pmm_manager+0x238>
ffffffffc020392a:	00001617          	auipc	a2,0x1
ffffffffc020392e:	12660613          	addi	a2,a2,294 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0203932:	34000593          	li	a1,832
ffffffffc0203936:	00002517          	auipc	a0,0x2
ffffffffc020393a:	f7a50513          	addi	a0,a0,-134 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc020393e:	ffafc0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0203942 <do_execve>:
{
ffffffffc0203942:	7135                	addi	sp,sp,-160
ffffffffc0203944:	fcce                	sd	s3,120(sp)
	struct mm_struct *mm = current->mm;
ffffffffc0203946:	0001b997          	auipc	s3,0x1b
ffffffffc020394a:	e9a98993          	addi	s3,s3,-358 # ffffffffc021e7e0 <current>
ffffffffc020394e:	0009b783          	ld	a5,0(s3)
{
ffffffffc0203952:	f8d2                	sd	s4,112(sp)
ffffffffc0203954:	e922                	sd	s0,144(sp)
	struct mm_struct *mm = current->mm;
ffffffffc0203956:	0287ba03          	ld	s4,40(a5)
{
ffffffffc020395a:	e526                	sd	s1,136(sp)
ffffffffc020395c:	e14a                	sd	s2,128(sp)
ffffffffc020395e:	84aa                	mv	s1,a0
ffffffffc0203960:	842e                	mv	s0,a1
ffffffffc0203962:	8932                	mv	s2,a2
	if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc0203964:	4681                	li	a3,0
ffffffffc0203966:	862e                	mv	a2,a1
ffffffffc0203968:	85aa                	mv	a1,a0
ffffffffc020396a:	8552                	mv	a0,s4
{
ffffffffc020396c:	ed06                	sd	ra,152(sp)
ffffffffc020396e:	f4d6                	sd	s5,104(sp)
ffffffffc0203970:	f0da                	sd	s6,96(sp)
ffffffffc0203972:	ecde                	sd	s7,88(sp)
ffffffffc0203974:	e8e2                	sd	s8,80(sp)
ffffffffc0203976:	e4e6                	sd	s9,72(sp)
ffffffffc0203978:	e0ea                	sd	s10,64(sp)
ffffffffc020397a:	fc6e                	sd	s11,56(sp)
	if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc020397c:	a08fe0ef          	jal	ra,ffffffffc0201b84 <user_mem_check>
ffffffffc0203980:	3e050763          	beqz	a0,ffffffffc0203d6e <do_execve+0x42c>
	memset(local_name, 0, sizeof(local_name));
ffffffffc0203984:	4641                	li	a2,16
ffffffffc0203986:	4581                	li	a1,0
ffffffffc0203988:	1008                	addi	a0,sp,32
ffffffffc020398a:	08b000ef          	jal	ra,ffffffffc0204214 <memset>
	memcpy(local_name, name, len);
ffffffffc020398e:	47bd                	li	a5,15
ffffffffc0203990:	8622                	mv	a2,s0
ffffffffc0203992:	0687ef63          	bltu	a5,s0,ffffffffc0203a10 <do_execve+0xce>
ffffffffc0203996:	85a6                	mv	a1,s1
ffffffffc0203998:	1008                	addi	a0,sp,32
ffffffffc020399a:	08d000ef          	jal	ra,ffffffffc0204226 <memcpy>
	if (mm != NULL) {
ffffffffc020399e:	080a0063          	beqz	s4,ffffffffc0203a1e <do_execve+0xdc>
		cputs("mm != NULL");
ffffffffc02039a2:	00002517          	auipc	a0,0x2
ffffffffc02039a6:	80650513          	addi	a0,a0,-2042 # ffffffffc02051a8 <etext+0xb66>
ffffffffc02039aa:	f4efc0ef          	jal	ra,ffffffffc02000f8 <cputs>
	write_csr(satp, 0x8000000000000000 | (satp >> RISCV_PGSHIFT));
ffffffffc02039ae:	0001b797          	auipc	a5,0x1b
ffffffffc02039b2:	e627b783          	ld	a5,-414(a5) # ffffffffc021e810 <boot_satp>
ffffffffc02039b6:	577d                	li	a4,-1
ffffffffc02039b8:	177e                	slli	a4,a4,0x3f
ffffffffc02039ba:	83b1                	srli	a5,a5,0xc
ffffffffc02039bc:	8fd9                	or	a5,a5,a4
ffffffffc02039be:	18079073          	csrw	satp,a5
        barrier();
ffffffffc02039c2:	0ff0000f          	fence
ffffffffc02039c6:	030a2783          	lw	a5,48(s4) # ffffffff80000030 <_binary_obj___user_hello_out_size+0xffffffff7fff68f0>
ffffffffc02039ca:	fff7871b          	addiw	a4,a5,-1
ffffffffc02039ce:	02ea2823          	sw	a4,48(s4)
		if (mm_count_dec(mm) == 0) {
ffffffffc02039d2:	28070563          	beqz	a4,ffffffffc0203c5c <do_execve+0x31a>
		current->mm = NULL;
ffffffffc02039d6:	0009b783          	ld	a5,0(s3)
ffffffffc02039da:	0207b423          	sd	zero,40(a5)
	if ((mm = mm_create()) == NULL) {
ffffffffc02039de:	d3bfd0ef          	jal	ra,ffffffffc0201718 <mm_create>
ffffffffc02039e2:	842a                	mv	s0,a0
ffffffffc02039e4:	c135                	beqz	a0,ffffffffc0203a48 <do_execve+0x106>
	if (setup_pgdir(mm) != 0) {
ffffffffc02039e6:	dd0ff0ef          	jal	ra,ffffffffc0202fb6 <setup_pgdir>
ffffffffc02039ea:	e931                	bnez	a0,ffffffffc0203a3e <do_execve+0xfc>
	if (elf->e_magic != ELF_MAGIC) {
ffffffffc02039ec:	00092703          	lw	a4,0(s2)
ffffffffc02039f0:	464c47b7          	lui	a5,0x464c4
ffffffffc02039f4:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_hello_out_size+0x464bae3f>
ffffffffc02039f8:	04f70a63          	beq	a4,a5,ffffffffc0203a4c <do_execve+0x10a>
	put_pgdir(mm);
ffffffffc02039fc:	8522                	mv	a0,s0
ffffffffc02039fe:	d42ff0ef          	jal	ra,ffffffffc0202f40 <put_pgdir>
	mm_destroy(mm);
ffffffffc0203a02:	8522                	mv	a0,s0
ffffffffc0203a04:	e6dfd0ef          	jal	ra,ffffffffc0201870 <mm_destroy>
		ret = -E_INVAL_ELF;
ffffffffc0203a08:	5a61                	li	s4,-8
	do_exit(ret);
ffffffffc0203a0a:	8552                	mv	a0,s4
ffffffffc0203a0c:	b33ff0ef          	jal	ra,ffffffffc020353e <do_exit>
	memcpy(local_name, name, len);
ffffffffc0203a10:	463d                	li	a2,15
ffffffffc0203a12:	85a6                	mv	a1,s1
ffffffffc0203a14:	1008                	addi	a0,sp,32
ffffffffc0203a16:	011000ef          	jal	ra,ffffffffc0204226 <memcpy>
	if (mm != NULL) {
ffffffffc0203a1a:	f80a14e3          	bnez	s4,ffffffffc02039a2 <do_execve+0x60>
	if (current->mm != NULL) {
ffffffffc0203a1e:	0009b783          	ld	a5,0(s3)
ffffffffc0203a22:	779c                	ld	a5,40(a5)
ffffffffc0203a24:	dfcd                	beqz	a5,ffffffffc02039de <do_execve+0x9c>
		panic("load_icode: current->mm must be empty.\n");
ffffffffc0203a26:	00002617          	auipc	a2,0x2
ffffffffc0203a2a:	07260613          	addi	a2,a2,114 # ffffffffc0205a98 <default_pmm_manager+0x2c8>
ffffffffc0203a2e:	1e600593          	li	a1,486
ffffffffc0203a32:	00002517          	auipc	a0,0x2
ffffffffc0203a36:	e7e50513          	addi	a0,a0,-386 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0203a3a:	efefc0ef          	jal	ra,ffffffffc0200138 <__panic>
	mm_destroy(mm);
ffffffffc0203a3e:	8522                	mv	a0,s0
ffffffffc0203a40:	e31fd0ef          	jal	ra,ffffffffc0201870 <mm_destroy>
	int ret = -E_NO_MEM;
ffffffffc0203a44:	5a71                	li	s4,-4
ffffffffc0203a46:	b7d1                	j	ffffffffc0203a0a <do_execve+0xc8>
ffffffffc0203a48:	5a71                	li	s4,-4
ffffffffc0203a4a:	b7c1                	j	ffffffffc0203a0a <do_execve+0xc8>
	struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0203a4c:	03895703          	lhu	a4,56(s2)
	struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0203a50:	02093483          	ld	s1,32(s2)
	struct Page *page = NULL;
ffffffffc0203a54:	4b01                	li	s6,0
	struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0203a56:	00371793          	slli	a5,a4,0x3
ffffffffc0203a5a:	8f99                	sub	a5,a5,a4
	struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0203a5c:	94ca                	add	s1,s1,s2
	struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0203a5e:	078e                	slli	a5,a5,0x3
ffffffffc0203a60:	97a6                	add	a5,a5,s1
ffffffffc0203a62:	ec3e                	sd	a5,24(sp)
	for (; ph < ph_end; ph++) {
ffffffffc0203a64:	02f4fa63          	bgeu	s1,a5,ffffffffc0203a98 <do_execve+0x156>
	return KADDR(page2pa(page));
ffffffffc0203a68:	57fd                	li	a5,-1
ffffffffc0203a6a:	83b1                	srli	a5,a5,0xc
	return page - pages + nbase;
ffffffffc0203a6c:	0001bd17          	auipc	s10,0x1b
ffffffffc0203a70:	db4d0d13          	addi	s10,s10,-588 # ffffffffc021e820 <pages>
ffffffffc0203a74:	00002c97          	auipc	s9,0x2
ffffffffc0203a78:	6f4c8c93          	addi	s9,s9,1780 # ffffffffc0206168 <nbase>
	return KADDR(page2pa(page));
ffffffffc0203a7c:	e43e                	sd	a5,8(sp)
ffffffffc0203a7e:	0001bc17          	auipc	s8,0x1b
ffffffffc0203a82:	d3ac0c13          	addi	s8,s8,-710 # ffffffffc021e7b8 <npage>
		if (ph->p_type != ELF_PT_LOAD) {
ffffffffc0203a86:	4098                	lw	a4,0(s1)
ffffffffc0203a88:	4785                	li	a5,1
ffffffffc0203a8a:	0ef70863          	beq	a4,a5,ffffffffc0203b7a <do_execve+0x238>
	for (; ph < ph_end; ph++) {
ffffffffc0203a8e:	67e2                	ld	a5,24(sp)
ffffffffc0203a90:	03848493          	addi	s1,s1,56
ffffffffc0203a94:	fef4e9e3          	bltu	s1,a5,ffffffffc0203a86 <do_execve+0x144>
	if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags,
ffffffffc0203a98:	4701                	li	a4,0
ffffffffc0203a9a:	46ad                	li	a3,11
ffffffffc0203a9c:	00100637          	lui	a2,0x100
ffffffffc0203aa0:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0203aa4:	8522                	mv	a0,s0
ffffffffc0203aa6:	e1bfd0ef          	jal	ra,ffffffffc02018c0 <mm_map>
ffffffffc0203aaa:	8a2a                	mv	s4,a0
ffffffffc0203aac:	18051e63          	bnez	a0,ffffffffc0203c48 <do_execve+0x306>
	assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) !=
ffffffffc0203ab0:	6c08                	ld	a0,24(s0)
ffffffffc0203ab2:	467d                	li	a2,31
ffffffffc0203ab4:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0203ab8:	fc0fd0ef          	jal	ra,ffffffffc0201278 <pgdir_alloc_page>
ffffffffc0203abc:	34050763          	beqz	a0,ffffffffc0203e0a <do_execve+0x4c8>
	assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) !=
ffffffffc0203ac0:	6c08                	ld	a0,24(s0)
ffffffffc0203ac2:	467d                	li	a2,31
ffffffffc0203ac4:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0203ac8:	fb0fd0ef          	jal	ra,ffffffffc0201278 <pgdir_alloc_page>
ffffffffc0203acc:	30050f63          	beqz	a0,ffffffffc0203dea <do_execve+0x4a8>
	assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) !=
ffffffffc0203ad0:	6c08                	ld	a0,24(s0)
ffffffffc0203ad2:	467d                	li	a2,31
ffffffffc0203ad4:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0203ad8:	fa0fd0ef          	jal	ra,ffffffffc0201278 <pgdir_alloc_page>
ffffffffc0203adc:	2e050763          	beqz	a0,ffffffffc0203dca <do_execve+0x488>
	assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) !=
ffffffffc0203ae0:	6c08                	ld	a0,24(s0)
ffffffffc0203ae2:	467d                	li	a2,31
ffffffffc0203ae4:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0203ae8:	f90fd0ef          	jal	ra,ffffffffc0201278 <pgdir_alloc_page>
ffffffffc0203aec:	2a050f63          	beqz	a0,ffffffffc0203daa <do_execve+0x468>
	mm->mm_count += 1;
ffffffffc0203af0:	581c                	lw	a5,48(s0)
	current->mm = mm;
ffffffffc0203af2:	0009b703          	ld	a4,0(s3)
	current->satp = PADDR(mm->pgdir);
ffffffffc0203af6:	6c14                	ld	a3,24(s0)
ffffffffc0203af8:	2785                	addiw	a5,a5,1
ffffffffc0203afa:	d81c                	sw	a5,48(s0)
	current->mm = mm;
ffffffffc0203afc:	f700                	sd	s0,40(a4)
	current->satp = PADDR(mm->pgdir);
ffffffffc0203afe:	c02007b7          	lui	a5,0xc0200
ffffffffc0203b02:	28f6e863          	bltu	a3,a5,ffffffffc0203d92 <do_execve+0x450>
ffffffffc0203b06:	0001b797          	auipc	a5,0x1b
ffffffffc0203b0a:	d127b783          	ld	a5,-750(a5) # ffffffffc021e818 <va_pa_offset>
ffffffffc0203b0e:	8e9d                	sub	a3,a3,a5
ffffffffc0203b10:	f754                	sd	a3,168(a4)
	write_csr(satp, 0x8000000000000000 | (satp >> RISCV_PGSHIFT));
ffffffffc0203b12:	577d                	li	a4,-1
ffffffffc0203b14:	00c6d793          	srli	a5,a3,0xc
ffffffffc0203b18:	177e                	slli	a4,a4,0x3f
ffffffffc0203b1a:	8fd9                	or	a5,a5,a4
ffffffffc0203b1c:	18079073          	csrw	satp,a5
        barrier();
ffffffffc0203b20:	0ff0000f          	fence
	struct trapframe *tf = current->tf;
ffffffffc0203b24:	0009b783          	ld	a5,0(s3)
	memset(tf, 0, sizeof(struct trapframe));
ffffffffc0203b28:	4581                	li	a1,0
ffffffffc0203b2a:	12000613          	li	a2,288
	struct trapframe *tf = current->tf;
ffffffffc0203b2e:	73c0                	ld	s0,160(a5)
	memset(tf, 0, sizeof(struct trapframe));
ffffffffc0203b30:	8522                	mv	a0,s0
	uintptr_t sstatus = tf->status;
ffffffffc0203b32:	10043483          	ld	s1,256(s0)
	memset(tf, 0, sizeof(struct trapframe));
ffffffffc0203b36:	6de000ef          	jal	ra,ffffffffc0204214 <memset>
	tf->epc = elf->e_entry;
ffffffffc0203b3a:	01893703          	ld	a4,24(s2)
	tf->gpr.sp = USTACKTOP;
ffffffffc0203b3e:	4785                	li	a5,1
	set_proc_name(current, local_name);
ffffffffc0203b40:	0009b503          	ld	a0,0(s3)
	tf->status = sstatus &
ffffffffc0203b44:	edf4f493          	andi	s1,s1,-289
	tf->gpr.sp = USTACKTOP;
ffffffffc0203b48:	07fe                	slli	a5,a5,0x1f
ffffffffc0203b4a:	e81c                	sd	a5,16(s0)
	tf->epc = elf->e_entry;
ffffffffc0203b4c:	10e43423          	sd	a4,264(s0)
	tf->status = sstatus &
ffffffffc0203b50:	10943023          	sd	s1,256(s0)
	set_proc_name(current, local_name);
ffffffffc0203b54:	100c                	addi	a1,sp,32
ffffffffc0203b56:	ce2ff0ef          	jal	ra,ffffffffc0203038 <set_proc_name>
}
ffffffffc0203b5a:	60ea                	ld	ra,152(sp)
ffffffffc0203b5c:	644a                	ld	s0,144(sp)
ffffffffc0203b5e:	64aa                	ld	s1,136(sp)
ffffffffc0203b60:	690a                	ld	s2,128(sp)
ffffffffc0203b62:	79e6                	ld	s3,120(sp)
ffffffffc0203b64:	7aa6                	ld	s5,104(sp)
ffffffffc0203b66:	7b06                	ld	s6,96(sp)
ffffffffc0203b68:	6be6                	ld	s7,88(sp)
ffffffffc0203b6a:	6c46                	ld	s8,80(sp)
ffffffffc0203b6c:	6ca6                	ld	s9,72(sp)
ffffffffc0203b6e:	6d06                	ld	s10,64(sp)
ffffffffc0203b70:	7de2                	ld	s11,56(sp)
ffffffffc0203b72:	8552                	mv	a0,s4
ffffffffc0203b74:	7a46                	ld	s4,112(sp)
ffffffffc0203b76:	610d                	addi	sp,sp,160
ffffffffc0203b78:	8082                	ret
		if (ph->p_filesz > ph->p_memsz) {
ffffffffc0203b7a:	7490                	ld	a2,40(s1)
ffffffffc0203b7c:	709c                	ld	a5,32(s1)
ffffffffc0203b7e:	1ef66c63          	bltu	a2,a5,ffffffffc0203d76 <do_execve+0x434>
		if (ph->p_flags & ELF_PF_X)
ffffffffc0203b82:	40dc                	lw	a5,4(s1)
ffffffffc0203b84:	0017f693          	andi	a3,a5,1
ffffffffc0203b88:	c291                	beqz	a3,ffffffffc0203b8c <do_execve+0x24a>
			vm_flags |= VM_EXEC;
ffffffffc0203b8a:	4691                	li	a3,4
		if (ph->p_flags & ELF_PF_W)
ffffffffc0203b8c:	0027f713          	andi	a4,a5,2
		if (ph->p_flags & ELF_PF_R)
ffffffffc0203b90:	8b91                	andi	a5,a5,4
		if (ph->p_flags & ELF_PF_W)
ffffffffc0203b92:	0c071f63          	bnez	a4,ffffffffc0203c70 <do_execve+0x32e>
		vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0203b96:	4745                	li	a4,17
ffffffffc0203b98:	e03a                	sd	a4,0(sp)
		if (ph->p_flags & ELF_PF_R)
ffffffffc0203b9a:	c789                	beqz	a5,ffffffffc0203ba4 <do_execve+0x262>
			perm |= PTE_R;
ffffffffc0203b9c:	47cd                	li	a5,19
			vm_flags |= VM_READ;
ffffffffc0203b9e:	0016e693          	ori	a3,a3,1
			perm |= PTE_R;
ffffffffc0203ba2:	e03e                	sd	a5,0(sp)
		if (vm_flags & VM_WRITE)
ffffffffc0203ba4:	0026f793          	andi	a5,a3,2
ffffffffc0203ba8:	e7f9                	bnez	a5,ffffffffc0203c76 <do_execve+0x334>
		if (vm_flags & VM_EXEC)
ffffffffc0203baa:	0046f793          	andi	a5,a3,4
ffffffffc0203bae:	c789                	beqz	a5,ffffffffc0203bb8 <do_execve+0x276>
			perm |= PTE_X;
ffffffffc0203bb0:	6782                	ld	a5,0(sp)
ffffffffc0203bb2:	0087e793          	ori	a5,a5,8
ffffffffc0203bb6:	e03e                	sd	a5,0(sp)
		if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) !=
ffffffffc0203bb8:	688c                	ld	a1,16(s1)
ffffffffc0203bba:	4701                	li	a4,0
ffffffffc0203bbc:	8522                	mv	a0,s0
ffffffffc0203bbe:	d03fd0ef          	jal	ra,ffffffffc02018c0 <mm_map>
ffffffffc0203bc2:	8a2a                	mv	s4,a0
ffffffffc0203bc4:	e151                	bnez	a0,ffffffffc0203c48 <do_execve+0x306>
		uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0203bc6:	0104bb83          	ld	s7,16(s1)
		end = ph->p_va + ph->p_filesz;
ffffffffc0203bca:	0204ba03          	ld	s4,32(s1)
		unsigned char *from = binary + ph->p_offset;
ffffffffc0203bce:	0084ba83          	ld	s5,8(s1)
		uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0203bd2:	77fd                	lui	a5,0xfffff
		end = ph->p_va + ph->p_filesz;
ffffffffc0203bd4:	9a5e                	add	s4,s4,s7
		unsigned char *from = binary + ph->p_offset;
ffffffffc0203bd6:	9aca                	add	s5,s5,s2
		uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0203bd8:	00fbfdb3          	and	s11,s7,a5
		while (start < end) {
ffffffffc0203bdc:	054bee63          	bltu	s7,s4,ffffffffc0203c38 <do_execve+0x2f6>
ffffffffc0203be0:	aa49                	j	ffffffffc0203d72 <do_execve+0x430>
			off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0203be2:	6785                	lui	a5,0x1
ffffffffc0203be4:	41bb8533          	sub	a0,s7,s11
ffffffffc0203be8:	9dbe                	add	s11,s11,a5
ffffffffc0203bea:	417d8633          	sub	a2,s11,s7
			if (end < la) {
ffffffffc0203bee:	01ba7463          	bgeu	s4,s11,ffffffffc0203bf6 <do_execve+0x2b4>
				size -= la - end;
ffffffffc0203bf2:	417a0633          	sub	a2,s4,s7
	return page - pages + nbase;
ffffffffc0203bf6:	000d3683          	ld	a3,0(s10)
ffffffffc0203bfa:	000cb883          	ld	a7,0(s9)
	return KADDR(page2pa(page));
ffffffffc0203bfe:	67a2                	ld	a5,8(sp)
	return page - pages + nbase;
ffffffffc0203c00:	40db06b3          	sub	a3,s6,a3
ffffffffc0203c04:	8699                	srai	a3,a3,0x6
	return KADDR(page2pa(page));
ffffffffc0203c06:	000c3583          	ld	a1,0(s8)
	return page - pages + nbase;
ffffffffc0203c0a:	96c6                	add	a3,a3,a7
	return KADDR(page2pa(page));
ffffffffc0203c0c:	00f6f8b3          	and	a7,a3,a5
	return page2ppn(page) << PGSHIFT;
ffffffffc0203c10:	06b2                	slli	a3,a3,0xc
	return KADDR(page2pa(page));
ffffffffc0203c12:	16b8f463          	bgeu	a7,a1,ffffffffc0203d7a <do_execve+0x438>
ffffffffc0203c16:	0001b797          	auipc	a5,0x1b
ffffffffc0203c1a:	c0278793          	addi	a5,a5,-1022 # ffffffffc021e818 <va_pa_offset>
ffffffffc0203c1e:	0007b883          	ld	a7,0(a5)
			memcpy(page2kva(page) + off, from, size);
ffffffffc0203c22:	85d6                	mv	a1,s5
			start += size, from += size;
ffffffffc0203c24:	9bb2                	add	s7,s7,a2
ffffffffc0203c26:	96c6                	add	a3,a3,a7
			memcpy(page2kva(page) + off, from, size);
ffffffffc0203c28:	9536                	add	a0,a0,a3
			start += size, from += size;
ffffffffc0203c2a:	e832                	sd	a2,16(sp)
			memcpy(page2kva(page) + off, from, size);
ffffffffc0203c2c:	5fa000ef          	jal	ra,ffffffffc0204226 <memcpy>
			start += size, from += size;
ffffffffc0203c30:	6642                	ld	a2,16(sp)
ffffffffc0203c32:	9ab2                	add	s5,s5,a2
		while (start < end) {
ffffffffc0203c34:	054bf463          	bgeu	s7,s4,ffffffffc0203c7c <do_execve+0x33a>
			if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) ==
ffffffffc0203c38:	6c08                	ld	a0,24(s0)
ffffffffc0203c3a:	6602                	ld	a2,0(sp)
ffffffffc0203c3c:	85ee                	mv	a1,s11
ffffffffc0203c3e:	e3afd0ef          	jal	ra,ffffffffc0201278 <pgdir_alloc_page>
ffffffffc0203c42:	8b2a                	mv	s6,a0
ffffffffc0203c44:	fd59                	bnez	a0,ffffffffc0203be2 <do_execve+0x2a0>
		ret = -E_NO_MEM;
ffffffffc0203c46:	5a71                	li	s4,-4
	exit_mmap(mm);
ffffffffc0203c48:	8522                	mv	a0,s0
ffffffffc0203c4a:	dc1fd0ef          	jal	ra,ffffffffc0201a0a <exit_mmap>
	put_pgdir(mm);
ffffffffc0203c4e:	8522                	mv	a0,s0
ffffffffc0203c50:	af0ff0ef          	jal	ra,ffffffffc0202f40 <put_pgdir>
	mm_destroy(mm);
ffffffffc0203c54:	8522                	mv	a0,s0
ffffffffc0203c56:	c1bfd0ef          	jal	ra,ffffffffc0201870 <mm_destroy>
	return ret;
ffffffffc0203c5a:	bb45                	j	ffffffffc0203a0a <do_execve+0xc8>
			exit_mmap(mm);
ffffffffc0203c5c:	8552                	mv	a0,s4
ffffffffc0203c5e:	dadfd0ef          	jal	ra,ffffffffc0201a0a <exit_mmap>
			put_pgdir(mm);
ffffffffc0203c62:	8552                	mv	a0,s4
ffffffffc0203c64:	adcff0ef          	jal	ra,ffffffffc0202f40 <put_pgdir>
			mm_destroy(mm);
ffffffffc0203c68:	8552                	mv	a0,s4
ffffffffc0203c6a:	c07fd0ef          	jal	ra,ffffffffc0201870 <mm_destroy>
ffffffffc0203c6e:	b3a5                	j	ffffffffc02039d6 <do_execve+0x94>
			vm_flags |= VM_WRITE;
ffffffffc0203c70:	0026e693          	ori	a3,a3,2
		if (ph->p_flags & ELF_PF_R)
ffffffffc0203c74:	f785                	bnez	a5,ffffffffc0203b9c <do_execve+0x25a>
			perm |= (PTE_W | PTE_R);
ffffffffc0203c76:	47dd                	li	a5,23
ffffffffc0203c78:	e03e                	sd	a5,0(sp)
ffffffffc0203c7a:	bf05                	j	ffffffffc0203baa <do_execve+0x268>
ffffffffc0203c7c:	0104ba03          	ld	s4,16(s1)
		end = ph->p_va + ph->p_memsz;
ffffffffc0203c80:	7494                	ld	a3,40(s1)
ffffffffc0203c82:	9a36                	add	s4,s4,a3
		if (start < la) {
ffffffffc0203c84:	07bbff63          	bgeu	s7,s11,ffffffffc0203d02 <do_execve+0x3c0>
			if (start == end) {
ffffffffc0203c88:	e17a03e3          	beq	s4,s7,ffffffffc0203a8e <do_execve+0x14c>
			off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0203c8c:	6505                	lui	a0,0x1
ffffffffc0203c8e:	955e                	add	a0,a0,s7
ffffffffc0203c90:	41b50533          	sub	a0,a0,s11
				size -= la - end;
ffffffffc0203c94:	417a0ab3          	sub	s5,s4,s7
			if (end < la) {
ffffffffc0203c98:	0dba7863          	bgeu	s4,s11,ffffffffc0203d68 <do_execve+0x426>
	return page - pages + nbase;
ffffffffc0203c9c:	000d3683          	ld	a3,0(s10)
ffffffffc0203ca0:	000cb583          	ld	a1,0(s9)
	return KADDR(page2pa(page));
ffffffffc0203ca4:	67a2                	ld	a5,8(sp)
	return page - pages + nbase;
ffffffffc0203ca6:	40db06b3          	sub	a3,s6,a3
ffffffffc0203caa:	8699                	srai	a3,a3,0x6
	return KADDR(page2pa(page));
ffffffffc0203cac:	000c3603          	ld	a2,0(s8)
	return page - pages + nbase;
ffffffffc0203cb0:	96ae                	add	a3,a3,a1
	return KADDR(page2pa(page));
ffffffffc0203cb2:	00f6f5b3          	and	a1,a3,a5
	return page2ppn(page) << PGSHIFT;
ffffffffc0203cb6:	06b2                	slli	a3,a3,0xc
	return KADDR(page2pa(page));
ffffffffc0203cb8:	0cc5f163          	bgeu	a1,a2,ffffffffc0203d7a <do_execve+0x438>
ffffffffc0203cbc:	0001b617          	auipc	a2,0x1b
ffffffffc0203cc0:	b5c63603          	ld	a2,-1188(a2) # ffffffffc021e818 <va_pa_offset>
ffffffffc0203cc4:	96b2                	add	a3,a3,a2
			memset(page2kva(page) + off, 0, size);
ffffffffc0203cc6:	4581                	li	a1,0
ffffffffc0203cc8:	8656                	mv	a2,s5
ffffffffc0203cca:	9536                	add	a0,a0,a3
ffffffffc0203ccc:	548000ef          	jal	ra,ffffffffc0204214 <memset>
			start += size;
ffffffffc0203cd0:	017a8733          	add	a4,s5,s7
			assert((end < la && start == end) ||
ffffffffc0203cd4:	03ba7463          	bgeu	s4,s11,ffffffffc0203cfc <do_execve+0x3ba>
ffffffffc0203cd8:	daea0be3          	beq	s4,a4,ffffffffc0203a8e <do_execve+0x14c>
ffffffffc0203cdc:	00002697          	auipc	a3,0x2
ffffffffc0203ce0:	de468693          	addi	a3,a3,-540 # ffffffffc0205ac0 <default_pmm_manager+0x2f0>
ffffffffc0203ce4:	00001617          	auipc	a2,0x1
ffffffffc0203ce8:	d6c60613          	addi	a2,a2,-660 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0203cec:	24600593          	li	a1,582
ffffffffc0203cf0:	00002517          	auipc	a0,0x2
ffffffffc0203cf4:	bc050513          	addi	a0,a0,-1088 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0203cf8:	c40fc0ef          	jal	ra,ffffffffc0200138 <__panic>
ffffffffc0203cfc:	ffb710e3          	bne	a4,s11,ffffffffc0203cdc <do_execve+0x39a>
ffffffffc0203d00:	8bee                	mv	s7,s11
ffffffffc0203d02:	0001ba97          	auipc	s5,0x1b
ffffffffc0203d06:	b16a8a93          	addi	s5,s5,-1258 # ffffffffc021e818 <va_pa_offset>
		while (start < end) {
ffffffffc0203d0a:	054be763          	bltu	s7,s4,ffffffffc0203d58 <do_execve+0x416>
ffffffffc0203d0e:	b341                	j	ffffffffc0203a8e <do_execve+0x14c>
			off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0203d10:	6785                	lui	a5,0x1
ffffffffc0203d12:	41bb8533          	sub	a0,s7,s11
ffffffffc0203d16:	9dbe                	add	s11,s11,a5
ffffffffc0203d18:	417d8633          	sub	a2,s11,s7
			if (end < la) {
ffffffffc0203d1c:	01ba7463          	bgeu	s4,s11,ffffffffc0203d24 <do_execve+0x3e2>
				size -= la - end;
ffffffffc0203d20:	417a0633          	sub	a2,s4,s7
	return page - pages + nbase;
ffffffffc0203d24:	000d3683          	ld	a3,0(s10)
ffffffffc0203d28:	000cb883          	ld	a7,0(s9)
	return KADDR(page2pa(page));
ffffffffc0203d2c:	67a2                	ld	a5,8(sp)
	return page - pages + nbase;
ffffffffc0203d2e:	40db06b3          	sub	a3,s6,a3
ffffffffc0203d32:	8699                	srai	a3,a3,0x6
	return KADDR(page2pa(page));
ffffffffc0203d34:	000c3583          	ld	a1,0(s8)
	return page - pages + nbase;
ffffffffc0203d38:	96c6                	add	a3,a3,a7
	return KADDR(page2pa(page));
ffffffffc0203d3a:	00f6f8b3          	and	a7,a3,a5
	return page2ppn(page) << PGSHIFT;
ffffffffc0203d3e:	06b2                	slli	a3,a3,0xc
	return KADDR(page2pa(page));
ffffffffc0203d40:	02b8fd63          	bgeu	a7,a1,ffffffffc0203d7a <do_execve+0x438>
ffffffffc0203d44:	000ab883          	ld	a7,0(s5)
			start += size;
ffffffffc0203d48:	9bb2                	add	s7,s7,a2
			memset(page2kva(page) + off, 0, size);
ffffffffc0203d4a:	4581                	li	a1,0
ffffffffc0203d4c:	96c6                	add	a3,a3,a7
ffffffffc0203d4e:	9536                	add	a0,a0,a3
ffffffffc0203d50:	4c4000ef          	jal	ra,ffffffffc0204214 <memset>
		while (start < end) {
ffffffffc0203d54:	d34bfde3          	bgeu	s7,s4,ffffffffc0203a8e <do_execve+0x14c>
			if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) ==
ffffffffc0203d58:	6c08                	ld	a0,24(s0)
ffffffffc0203d5a:	6602                	ld	a2,0(sp)
ffffffffc0203d5c:	85ee                	mv	a1,s11
ffffffffc0203d5e:	d1afd0ef          	jal	ra,ffffffffc0201278 <pgdir_alloc_page>
ffffffffc0203d62:	8b2a                	mv	s6,a0
ffffffffc0203d64:	f555                	bnez	a0,ffffffffc0203d10 <do_execve+0x3ce>
ffffffffc0203d66:	b5c5                	j	ffffffffc0203c46 <do_execve+0x304>
			off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0203d68:	417d8ab3          	sub	s5,s11,s7
ffffffffc0203d6c:	bf05                	j	ffffffffc0203c9c <do_execve+0x35a>
		return -E_INVAL;
ffffffffc0203d6e:	5a75                	li	s4,-3
ffffffffc0203d70:	b3ed                	j	ffffffffc0203b5a <do_execve+0x218>
		while (start < end) {
ffffffffc0203d72:	8a5e                	mv	s4,s7
ffffffffc0203d74:	b731                	j	ffffffffc0203c80 <do_execve+0x33e>
			ret = -E_INVAL_ELF;
ffffffffc0203d76:	5a61                	li	s4,-8
ffffffffc0203d78:	bdc1                	j	ffffffffc0203c48 <do_execve+0x306>
ffffffffc0203d7a:	00001617          	auipc	a2,0x1
ffffffffc0203d7e:	08660613          	addi	a2,a2,134 # ffffffffc0204e00 <etext+0x7be>
ffffffffc0203d82:	07200593          	li	a1,114
ffffffffc0203d86:	00001517          	auipc	a0,0x1
ffffffffc0203d8a:	fda50513          	addi	a0,a0,-38 # ffffffffc0204d60 <etext+0x71e>
ffffffffc0203d8e:	baafc0ef          	jal	ra,ffffffffc0200138 <__panic>
	current->satp = PADDR(mm->pgdir);
ffffffffc0203d92:	00001617          	auipc	a2,0x1
ffffffffc0203d96:	03660613          	addi	a2,a2,54 # ffffffffc0204dc8 <etext+0x786>
ffffffffc0203d9a:	26900593          	li	a1,617
ffffffffc0203d9e:	00002517          	auipc	a0,0x2
ffffffffc0203da2:	b1250513          	addi	a0,a0,-1262 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0203da6:	b92fc0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) !=
ffffffffc0203daa:	00002697          	auipc	a3,0x2
ffffffffc0203dae:	e2e68693          	addi	a3,a3,-466 # ffffffffc0205bd8 <default_pmm_manager+0x408>
ffffffffc0203db2:	00001617          	auipc	a2,0x1
ffffffffc0203db6:	c9e60613          	addi	a2,a2,-866 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0203dba:	26200593          	li	a1,610
ffffffffc0203dbe:	00002517          	auipc	a0,0x2
ffffffffc0203dc2:	af250513          	addi	a0,a0,-1294 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0203dc6:	b72fc0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) !=
ffffffffc0203dca:	00002697          	auipc	a3,0x2
ffffffffc0203dce:	dc668693          	addi	a3,a3,-570 # ffffffffc0205b90 <default_pmm_manager+0x3c0>
ffffffffc0203dd2:	00001617          	auipc	a2,0x1
ffffffffc0203dd6:	c7e60613          	addi	a2,a2,-898 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0203dda:	26000593          	li	a1,608
ffffffffc0203dde:	00002517          	auipc	a0,0x2
ffffffffc0203de2:	ad250513          	addi	a0,a0,-1326 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0203de6:	b52fc0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) !=
ffffffffc0203dea:	00002697          	auipc	a3,0x2
ffffffffc0203dee:	d5e68693          	addi	a3,a3,-674 # ffffffffc0205b48 <default_pmm_manager+0x378>
ffffffffc0203df2:	00001617          	auipc	a2,0x1
ffffffffc0203df6:	c5e60613          	addi	a2,a2,-930 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0203dfa:	25e00593          	li	a1,606
ffffffffc0203dfe:	00002517          	auipc	a0,0x2
ffffffffc0203e02:	ab250513          	addi	a0,a0,-1358 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0203e06:	b32fc0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) !=
ffffffffc0203e0a:	00002697          	auipc	a3,0x2
ffffffffc0203e0e:	cf668693          	addi	a3,a3,-778 # ffffffffc0205b00 <default_pmm_manager+0x330>
ffffffffc0203e12:	00001617          	auipc	a2,0x1
ffffffffc0203e16:	c3e60613          	addi	a2,a2,-962 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0203e1a:	25c00593          	li	a1,604
ffffffffc0203e1e:	00002517          	auipc	a0,0x2
ffffffffc0203e22:	a9250513          	addi	a0,a0,-1390 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0203e26:	b12fc0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0203e2a <do_yield>:
	current->need_resched = 1;
ffffffffc0203e2a:	0001b797          	auipc	a5,0x1b
ffffffffc0203e2e:	9b67b783          	ld	a5,-1610(a5) # ffffffffc021e7e0 <current>
ffffffffc0203e32:	4705                	li	a4,1
ffffffffc0203e34:	cf98                	sw	a4,24(a5)
}
ffffffffc0203e36:	4501                	li	a0,0
ffffffffc0203e38:	8082                	ret

ffffffffc0203e3a <do_wait>:
{
ffffffffc0203e3a:	1101                	addi	sp,sp,-32
ffffffffc0203e3c:	e822                	sd	s0,16(sp)
ffffffffc0203e3e:	e426                	sd	s1,8(sp)
ffffffffc0203e40:	ec06                	sd	ra,24(sp)
ffffffffc0203e42:	842e                	mv	s0,a1
ffffffffc0203e44:	84aa                	mv	s1,a0
	if (code_store != NULL) {
ffffffffc0203e46:	c999                	beqz	a1,ffffffffc0203e5c <do_wait+0x22>
	struct mm_struct *mm = current->mm;
ffffffffc0203e48:	0001b797          	auipc	a5,0x1b
ffffffffc0203e4c:	9987b783          	ld	a5,-1640(a5) # ffffffffc021e7e0 <current>
		if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int),
ffffffffc0203e50:	7788                	ld	a0,40(a5)
ffffffffc0203e52:	4685                	li	a3,1
ffffffffc0203e54:	4611                	li	a2,4
ffffffffc0203e56:	d2ffd0ef          	jal	ra,ffffffffc0201b84 <user_mem_check>
ffffffffc0203e5a:	c909                	beqz	a0,ffffffffc0203e6c <do_wait+0x32>
ffffffffc0203e5c:	85a2                	mv	a1,s0
}
ffffffffc0203e5e:	6442                	ld	s0,16(sp)
ffffffffc0203e60:	60e2                	ld	ra,24(sp)
ffffffffc0203e62:	8526                	mv	a0,s1
ffffffffc0203e64:	64a2                	ld	s1,8(sp)
ffffffffc0203e66:	6105                	addi	sp,sp,32
ffffffffc0203e68:	825ff06f          	j	ffffffffc020368c <do_wait.part.0>
ffffffffc0203e6c:	60e2                	ld	ra,24(sp)
ffffffffc0203e6e:	6442                	ld	s0,16(sp)
ffffffffc0203e70:	64a2                	ld	s1,8(sp)
ffffffffc0203e72:	5575                	li	a0,-3
ffffffffc0203e74:	6105                	addi	sp,sp,32
ffffffffc0203e76:	8082                	ret

ffffffffc0203e78 <do_kill>:
{
ffffffffc0203e78:	1141                	addi	sp,sp,-16
ffffffffc0203e7a:	e406                	sd	ra,8(sp)
ffffffffc0203e7c:	e022                	sd	s0,0(sp)
	if ((proc = find_proc(pid)) != NULL) {
ffffffffc0203e7e:	a54ff0ef          	jal	ra,ffffffffc02030d2 <find_proc>
ffffffffc0203e82:	cd0d                	beqz	a0,ffffffffc0203ebc <do_kill+0x44>
		if (!(proc->flags & PF_EXITING)) {
ffffffffc0203e84:	0b052703          	lw	a4,176(a0)
ffffffffc0203e88:	00177693          	andi	a3,a4,1
ffffffffc0203e8c:	e695                	bnez	a3,ffffffffc0203eb8 <do_kill+0x40>
			if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0203e8e:	0ec52683          	lw	a3,236(a0)
			proc->flags |= PF_EXITING;
ffffffffc0203e92:	00176713          	ori	a4,a4,1
ffffffffc0203e96:	0ae52823          	sw	a4,176(a0)
			return 0;
ffffffffc0203e9a:	4401                	li	s0,0
			if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0203e9c:	0006c763          	bltz	a3,ffffffffc0203eaa <do_kill+0x32>
}
ffffffffc0203ea0:	60a2                	ld	ra,8(sp)
ffffffffc0203ea2:	8522                	mv	a0,s0
ffffffffc0203ea4:	6402                	ld	s0,0(sp)
ffffffffc0203ea6:	0141                	addi	sp,sp,16
ffffffffc0203ea8:	8082                	ret
				wakeup_proc(proc);
ffffffffc0203eaa:	162000ef          	jal	ra,ffffffffc020400c <wakeup_proc>
}
ffffffffc0203eae:	60a2                	ld	ra,8(sp)
ffffffffc0203eb0:	8522                	mv	a0,s0
ffffffffc0203eb2:	6402                	ld	s0,0(sp)
ffffffffc0203eb4:	0141                	addi	sp,sp,16
ffffffffc0203eb6:	8082                	ret
		return -E_KILLED;
ffffffffc0203eb8:	545d                	li	s0,-9
ffffffffc0203eba:	b7dd                	j	ffffffffc0203ea0 <do_kill+0x28>
	return -E_INVAL;
ffffffffc0203ebc:	5475                	li	s0,-3
ffffffffc0203ebe:	b7cd                	j	ffffffffc0203ea0 <do_kill+0x28>

ffffffffc0203ec0 <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0203ec0:	1101                	addi	sp,sp,-32
	elm->prev = elm->next = elm;
ffffffffc0203ec2:	0001b797          	auipc	a5,0x1b
ffffffffc0203ec6:	a5e78793          	addi	a5,a5,-1442 # ffffffffc021e920 <proc_list>
ffffffffc0203eca:	ec06                	sd	ra,24(sp)
ffffffffc0203ecc:	e822                	sd	s0,16(sp)
ffffffffc0203ece:	e426                	sd	s1,8(sp)
ffffffffc0203ed0:	e79c                	sd	a5,8(a5)
ffffffffc0203ed2:	e39c                	sd	a5,0(a5)
	int i;

	list_init(&proc_list);
	for (i = 0; i < HASH_LIST_SIZE; i++) {
ffffffffc0203ed4:	0001b717          	auipc	a4,0x1b
ffffffffc0203ed8:	8cc70713          	addi	a4,a4,-1844 # ffffffffc021e7a0 <is_panic>
ffffffffc0203edc:	00017797          	auipc	a5,0x17
ffffffffc0203ee0:	8c478793          	addi	a5,a5,-1852 # ffffffffc021a7a0 <hash_list>
ffffffffc0203ee4:	e79c                	sd	a5,8(a5)
ffffffffc0203ee6:	e39c                	sd	a5,0(a5)
ffffffffc0203ee8:	07c1                	addi	a5,a5,16
ffffffffc0203eea:	fef71de3          	bne	a4,a5,ffffffffc0203ee4 <proc_init+0x24>
		list_init(hash_list + i);
	}

	if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0203eee:	f63fe0ef          	jal	ra,ffffffffc0202e50 <alloc_proc>
ffffffffc0203ef2:	0001b417          	auipc	s0,0x1b
ffffffffc0203ef6:	8f640413          	addi	s0,s0,-1802 # ffffffffc021e7e8 <idleproc>
ffffffffc0203efa:	e008                	sd	a0,0(s0)
ffffffffc0203efc:	c151                	beqz	a0,ffffffffc0203f80 <proc_init+0xc0>
		panic("cannot alloc idleproc.\n");
	}

	idleproc->pid = 0;
	idleproc->state = PROC_RUNNABLE;
ffffffffc0203efe:	4709                	li	a4,2
ffffffffc0203f00:	e118                	sd	a4,0(a0)
	idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0203f02:	00003717          	auipc	a4,0x3
ffffffffc0203f06:	0fe70713          	addi	a4,a4,254 # ffffffffc0207000 <bootstack>
ffffffffc0203f0a:	e918                	sd	a4,16(a0)
	idleproc->need_resched = 1;
ffffffffc0203f0c:	4705                	li	a4,1
	set_proc_name(idleproc, "idle");
ffffffffc0203f0e:	00002597          	auipc	a1,0x2
ffffffffc0203f12:	d2a58593          	addi	a1,a1,-726 # ffffffffc0205c38 <default_pmm_manager+0x468>
	idleproc->need_resched = 1;
ffffffffc0203f16:	cd18                	sw	a4,24(a0)
	set_proc_name(idleproc, "idle");
ffffffffc0203f18:	920ff0ef          	jal	ra,ffffffffc0203038 <set_proc_name>
	nr_process++;
ffffffffc0203f1c:	0001b717          	auipc	a4,0x1b
ffffffffc0203f20:	8dc70713          	addi	a4,a4,-1828 # ffffffffc021e7f8 <nr_process>
ffffffffc0203f24:	431c                	lw	a5,0(a4)

	current = idleproc;
ffffffffc0203f26:	6014                	ld	a3,0(s0)

	int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0203f28:	4601                	li	a2,0
	nr_process++;
ffffffffc0203f2a:	2785                	addiw	a5,a5,1
	int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0203f2c:	4581                	li	a1,0
ffffffffc0203f2e:	00000517          	auipc	a0,0x0
ffffffffc0203f32:	8f450513          	addi	a0,a0,-1804 # ffffffffc0203822 <init_main>
	nr_process++;
ffffffffc0203f36:	c31c                	sw	a5,0(a4)
	current = idleproc;
ffffffffc0203f38:	0001b797          	auipc	a5,0x1b
ffffffffc0203f3c:	8ad7b423          	sd	a3,-1880(a5) # ffffffffc021e7e0 <current>
	int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0203f40:	daeff0ef          	jal	ra,ffffffffc02034ee <kernel_thread>
	if (pid <= 0) {
ffffffffc0203f44:	08a05a63          	blez	a0,ffffffffc0203fd8 <proc_init+0x118>
		panic("create init_main failed.\n");
	}

	initproc = find_proc(pid);
ffffffffc0203f48:	98aff0ef          	jal	ra,ffffffffc02030d2 <find_proc>
ffffffffc0203f4c:	0001b497          	auipc	s1,0x1b
ffffffffc0203f50:	8a448493          	addi	s1,s1,-1884 # ffffffffc021e7f0 <initproc>
	set_proc_name(initproc, "init");
ffffffffc0203f54:	00002597          	auipc	a1,0x2
ffffffffc0203f58:	d0c58593          	addi	a1,a1,-756 # ffffffffc0205c60 <default_pmm_manager+0x490>
	initproc = find_proc(pid);
ffffffffc0203f5c:	e088                	sd	a0,0(s1)
	set_proc_name(initproc, "init");
ffffffffc0203f5e:	8daff0ef          	jal	ra,ffffffffc0203038 <set_proc_name>

	assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0203f62:	601c                	ld	a5,0(s0)
ffffffffc0203f64:	cbb1                	beqz	a5,ffffffffc0203fb8 <proc_init+0xf8>
ffffffffc0203f66:	43dc                	lw	a5,4(a5)
ffffffffc0203f68:	eba1                	bnez	a5,ffffffffc0203fb8 <proc_init+0xf8>
	assert(initproc != NULL && initproc->pid == 1);
ffffffffc0203f6a:	609c                	ld	a5,0(s1)
ffffffffc0203f6c:	c795                	beqz	a5,ffffffffc0203f98 <proc_init+0xd8>
ffffffffc0203f6e:	43d8                	lw	a4,4(a5)
ffffffffc0203f70:	4785                	li	a5,1
ffffffffc0203f72:	02f71363          	bne	a4,a5,ffffffffc0203f98 <proc_init+0xd8>
}
ffffffffc0203f76:	60e2                	ld	ra,24(sp)
ffffffffc0203f78:	6442                	ld	s0,16(sp)
ffffffffc0203f7a:	64a2                	ld	s1,8(sp)
ffffffffc0203f7c:	6105                	addi	sp,sp,32
ffffffffc0203f7e:	8082                	ret
		panic("cannot alloc idleproc.\n");
ffffffffc0203f80:	00002617          	auipc	a2,0x2
ffffffffc0203f84:	ca060613          	addi	a2,a2,-864 # ffffffffc0205c20 <default_pmm_manager+0x450>
ffffffffc0203f88:	35400593          	li	a1,852
ffffffffc0203f8c:	00002517          	auipc	a0,0x2
ffffffffc0203f90:	92450513          	addi	a0,a0,-1756 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0203f94:	9a4fc0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(initproc != NULL && initproc->pid == 1);
ffffffffc0203f98:	00002697          	auipc	a3,0x2
ffffffffc0203f9c:	cf868693          	addi	a3,a3,-776 # ffffffffc0205c90 <default_pmm_manager+0x4c0>
ffffffffc0203fa0:	00001617          	auipc	a2,0x1
ffffffffc0203fa4:	ab060613          	addi	a2,a2,-1360 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0203fa8:	36900593          	li	a1,873
ffffffffc0203fac:	00002517          	auipc	a0,0x2
ffffffffc0203fb0:	90450513          	addi	a0,a0,-1788 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0203fb4:	984fc0ef          	jal	ra,ffffffffc0200138 <__panic>
	assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0203fb8:	00002697          	auipc	a3,0x2
ffffffffc0203fbc:	cb068693          	addi	a3,a3,-848 # ffffffffc0205c68 <default_pmm_manager+0x498>
ffffffffc0203fc0:	00001617          	auipc	a2,0x1
ffffffffc0203fc4:	a9060613          	addi	a2,a2,-1392 # ffffffffc0204a50 <etext+0x40e>
ffffffffc0203fc8:	36800593          	li	a1,872
ffffffffc0203fcc:	00002517          	auipc	a0,0x2
ffffffffc0203fd0:	8e450513          	addi	a0,a0,-1820 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0203fd4:	964fc0ef          	jal	ra,ffffffffc0200138 <__panic>
		panic("create init_main failed.\n");
ffffffffc0203fd8:	00002617          	auipc	a2,0x2
ffffffffc0203fdc:	c6860613          	addi	a2,a2,-920 # ffffffffc0205c40 <default_pmm_manager+0x470>
ffffffffc0203fe0:	36200593          	li	a1,866
ffffffffc0203fe4:	00002517          	auipc	a0,0x2
ffffffffc0203fe8:	8cc50513          	addi	a0,a0,-1844 # ffffffffc02058b0 <default_pmm_manager+0xe0>
ffffffffc0203fec:	94cfc0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc0203ff0 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do
// below works
void cpu_idle(void)
{
ffffffffc0203ff0:	1141                	addi	sp,sp,-16
ffffffffc0203ff2:	e022                	sd	s0,0(sp)
ffffffffc0203ff4:	e406                	sd	ra,8(sp)
ffffffffc0203ff6:	0001a417          	auipc	s0,0x1a
ffffffffc0203ffa:	7ea40413          	addi	s0,s0,2026 # ffffffffc021e7e0 <current>
	while (1) {
		if (current->need_resched) {
ffffffffc0203ffe:	6018                	ld	a4,0(s0)
ffffffffc0204000:	4f1c                	lw	a5,24(a4)
ffffffffc0204002:	2781                	sext.w	a5,a5
ffffffffc0204004:	dff5                	beqz	a5,ffffffffc0204000 <cpu_idle+0x10>
			schedule();
ffffffffc0204006:	086000ef          	jal	ra,ffffffffc020408c <schedule>
ffffffffc020400a:	bfd5                	j	ffffffffc0203ffe <cpu_idle+0xe>

ffffffffc020400c <wakeup_proc>:
#include <sched.h>
#include <sync.h>

void wakeup_proc(struct proc_struct *proc)
{
	assert(proc->state != PROC_ZOMBIE);
ffffffffc020400c:	4118                	lw	a4,0(a0)
{
ffffffffc020400e:	1101                	addi	sp,sp,-32
ffffffffc0204010:	ec06                	sd	ra,24(sp)
ffffffffc0204012:	e822                	sd	s0,16(sp)
ffffffffc0204014:	e426                	sd	s1,8(sp)
	assert(proc->state != PROC_ZOMBIE);
ffffffffc0204016:	478d                	li	a5,3
ffffffffc0204018:	04f70b63          	beq	a4,a5,ffffffffc020406e <wakeup_proc+0x62>
ffffffffc020401c:	842a                	mv	s0,a0
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020401e:	100027f3          	csrr	a5,sstatus
ffffffffc0204022:	8b89                	andi	a5,a5,2
	return 0;
ffffffffc0204024:	4481                	li	s1,0
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204026:	ef9d                	bnez	a5,ffffffffc0204064 <wakeup_proc+0x58>
	bool intr_flag;
	local_intr_save(intr_flag);
	{
		if (proc->state != PROC_RUNNABLE) {
ffffffffc0204028:	4789                	li	a5,2
ffffffffc020402a:	02f70163          	beq	a4,a5,ffffffffc020404c <wakeup_proc+0x40>
			proc->state = PROC_RUNNABLE;
ffffffffc020402e:	c01c                	sw	a5,0(s0)
			proc->wait_state = 0;
ffffffffc0204030:	0e042623          	sw	zero,236(s0)
	if (flag) {
ffffffffc0204034:	e491                	bnez	s1,ffffffffc0204040 <wakeup_proc+0x34>
		} else {
			warn("wakeup runnable process.\n");
		}
	}
	local_intr_restore(intr_flag);
}
ffffffffc0204036:	60e2                	ld	ra,24(sp)
ffffffffc0204038:	6442                	ld	s0,16(sp)
ffffffffc020403a:	64a2                	ld	s1,8(sp)
ffffffffc020403c:	6105                	addi	sp,sp,32
ffffffffc020403e:	8082                	ret
ffffffffc0204040:	6442                	ld	s0,16(sp)
ffffffffc0204042:	60e2                	ld	ra,24(sp)
ffffffffc0204044:	64a2                	ld	s1,8(sp)
ffffffffc0204046:	6105                	addi	sp,sp,32
		intr_enable();
ffffffffc0204048:	a44fc06f          	j	ffffffffc020028c <intr_enable>
			warn("wakeup runnable process.\n");
ffffffffc020404c:	00002617          	auipc	a2,0x2
ffffffffc0204050:	ca460613          	addi	a2,a2,-860 # ffffffffc0205cf0 <default_pmm_manager+0x520>
ffffffffc0204054:	45c5                	li	a1,17
ffffffffc0204056:	00002517          	auipc	a0,0x2
ffffffffc020405a:	c8250513          	addi	a0,a0,-894 # ffffffffc0205cd8 <default_pmm_manager+0x508>
ffffffffc020405e:	942fc0ef          	jal	ra,ffffffffc02001a0 <__warn>
ffffffffc0204062:	bfc9                	j	ffffffffc0204034 <wakeup_proc+0x28>
		intr_disable();
ffffffffc0204064:	a2efc0ef          	jal	ra,ffffffffc0200292 <intr_disable>
		return 1;
ffffffffc0204068:	4018                	lw	a4,0(s0)
ffffffffc020406a:	4485                	li	s1,1
ffffffffc020406c:	bf75                	j	ffffffffc0204028 <wakeup_proc+0x1c>
	assert(proc->state != PROC_ZOMBIE);
ffffffffc020406e:	00002697          	auipc	a3,0x2
ffffffffc0204072:	c4a68693          	addi	a3,a3,-950 # ffffffffc0205cb8 <default_pmm_manager+0x4e8>
ffffffffc0204076:	00001617          	auipc	a2,0x1
ffffffffc020407a:	9da60613          	addi	a2,a2,-1574 # ffffffffc0204a50 <etext+0x40e>
ffffffffc020407e:	45a5                	li	a1,9
ffffffffc0204080:	00002517          	auipc	a0,0x2
ffffffffc0204084:	c5850513          	addi	a0,a0,-936 # ffffffffc0205cd8 <default_pmm_manager+0x508>
ffffffffc0204088:	8b0fc0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc020408c <schedule>:

void schedule(void)
{
ffffffffc020408c:	1141                	addi	sp,sp,-16
ffffffffc020408e:	e406                	sd	ra,8(sp)
ffffffffc0204090:	e022                	sd	s0,0(sp)
	if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204092:	100027f3          	csrr	a5,sstatus
ffffffffc0204096:	8b89                	andi	a5,a5,2
ffffffffc0204098:	4401                	li	s0,0
ffffffffc020409a:	efbd                	bnez	a5,ffffffffc0204118 <schedule+0x8c>
	bool intr_flag;
	list_entry_t *le, *last;
	struct proc_struct *next = NULL;
	local_intr_save(intr_flag);
	{
		current->need_resched = 0;
ffffffffc020409c:	0001a897          	auipc	a7,0x1a
ffffffffc02040a0:	7448b883          	ld	a7,1860(a7) # ffffffffc021e7e0 <current>
ffffffffc02040a4:	0008ac23          	sw	zero,24(a7)
		last = (current == idleproc) ? &proc_list :
ffffffffc02040a8:	0001a517          	auipc	a0,0x1a
ffffffffc02040ac:	74053503          	ld	a0,1856(a0) # ffffffffc021e7e8 <idleproc>
ffffffffc02040b0:	04a88e63          	beq	a7,a0,ffffffffc020410c <schedule+0x80>
ffffffffc02040b4:	0c888693          	addi	a3,a7,200
ffffffffc02040b8:	0001b617          	auipc	a2,0x1b
ffffffffc02040bc:	86860613          	addi	a2,a2,-1944 # ffffffffc021e920 <proc_list>
					       &(current->list_link);
		le = last;
ffffffffc02040c0:	87b6                	mv	a5,a3
	struct proc_struct *next = NULL;
ffffffffc02040c2:	4581                	li	a1,0
		do {
			if ((le = list_next(le)) != &proc_list) {
				next = le2proc(le, list_link);
				if (next->state == PROC_RUNNABLE) {
ffffffffc02040c4:	4809                	li	a6,2
	return listelm->next;
ffffffffc02040c6:	679c                	ld	a5,8(a5)
			if ((le = list_next(le)) != &proc_list) {
ffffffffc02040c8:	00c78863          	beq	a5,a2,ffffffffc02040d8 <schedule+0x4c>
				if (next->state == PROC_RUNNABLE) {
ffffffffc02040cc:	f387a703          	lw	a4,-200(a5)
				next = le2proc(le, list_link);
ffffffffc02040d0:	f3878593          	addi	a1,a5,-200
				if (next->state == PROC_RUNNABLE) {
ffffffffc02040d4:	03070163          	beq	a4,a6,ffffffffc02040f6 <schedule+0x6a>
					break;
				}
			}
		} while (le != last);
ffffffffc02040d8:	fef697e3          	bne	a3,a5,ffffffffc02040c6 <schedule+0x3a>
		if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02040dc:	ed89                	bnez	a1,ffffffffc02040f6 <schedule+0x6a>
			next = idleproc;
		}
		next->runs++;
ffffffffc02040de:	451c                	lw	a5,8(a0)
ffffffffc02040e0:	2785                	addiw	a5,a5,1
ffffffffc02040e2:	c51c                	sw	a5,8(a0)
		if (next != current) {
ffffffffc02040e4:	00a88463          	beq	a7,a0,ffffffffc02040ec <schedule+0x60>
			proc_run(next);
ffffffffc02040e8:	f7bfe0ef          	jal	ra,ffffffffc0203062 <proc_run>
	if (flag) {
ffffffffc02040ec:	e819                	bnez	s0,ffffffffc0204102 <schedule+0x76>
		}
	}
	local_intr_restore(intr_flag);
}
ffffffffc02040ee:	60a2                	ld	ra,8(sp)
ffffffffc02040f0:	6402                	ld	s0,0(sp)
ffffffffc02040f2:	0141                	addi	sp,sp,16
ffffffffc02040f4:	8082                	ret
		if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc02040f6:	4198                	lw	a4,0(a1)
ffffffffc02040f8:	4789                	li	a5,2
ffffffffc02040fa:	fef712e3          	bne	a4,a5,ffffffffc02040de <schedule+0x52>
ffffffffc02040fe:	852e                	mv	a0,a1
ffffffffc0204100:	bff9                	j	ffffffffc02040de <schedule+0x52>
}
ffffffffc0204102:	6402                	ld	s0,0(sp)
ffffffffc0204104:	60a2                	ld	ra,8(sp)
ffffffffc0204106:	0141                	addi	sp,sp,16
		intr_enable();
ffffffffc0204108:	984fc06f          	j	ffffffffc020028c <intr_enable>
		last = (current == idleproc) ? &proc_list :
ffffffffc020410c:	0001b617          	auipc	a2,0x1b
ffffffffc0204110:	81460613          	addi	a2,a2,-2028 # ffffffffc021e920 <proc_list>
ffffffffc0204114:	86b2                	mv	a3,a2
ffffffffc0204116:	b76d                	j	ffffffffc02040c0 <schedule+0x34>
		intr_disable();
ffffffffc0204118:	97afc0ef          	jal	ra,ffffffffc0200292 <intr_disable>
		return 1;
ffffffffc020411c:	4405                	li	s0,1
ffffffffc020411e:	bfbd                	j	ffffffffc020409c <schedule+0x10>

ffffffffc0204120 <sys_getpid>:
	return do_kill(pid);
}

static int sys_getpid(uint64_t arg[])
{
	return current->pid;
ffffffffc0204120:	0001a797          	auipc	a5,0x1a
ffffffffc0204124:	6c07b783          	ld	a5,1728(a5) # ffffffffc021e7e0 <current>
}
ffffffffc0204128:	43c8                	lw	a0,4(a5)
ffffffffc020412a:	8082                	ret

ffffffffc020412c <sys_putc>:

static int sys_putc(uint64_t arg[])
{
	int c = (int)arg[0];
	cputchar(c);
ffffffffc020412c:	4108                	lw	a0,0(a0)
{
ffffffffc020412e:	1141                	addi	sp,sp,-16
ffffffffc0204130:	e406                	sd	ra,8(sp)
	cputchar(c);
ffffffffc0204132:	fc5fb0ef          	jal	ra,ffffffffc02000f6 <cputchar>
	return 0;
}
ffffffffc0204136:	60a2                	ld	ra,8(sp)
ffffffffc0204138:	4501                	li	a0,0
ffffffffc020413a:	0141                	addi	sp,sp,16
ffffffffc020413c:	8082                	ret

ffffffffc020413e <sys_kill>:
	return do_kill(pid);
ffffffffc020413e:	4108                	lw	a0,0(a0)
ffffffffc0204140:	d39ff06f          	j	ffffffffc0203e78 <do_kill>

ffffffffc0204144 <sys_yield>:
	return do_yield();
ffffffffc0204144:	ce7ff06f          	j	ffffffffc0203e2a <do_yield>

ffffffffc0204148 <sys_exec>:
	return do_execve(name, len, binary, size);
ffffffffc0204148:	6d14                	ld	a3,24(a0)
ffffffffc020414a:	6910                	ld	a2,16(a0)
ffffffffc020414c:	650c                	ld	a1,8(a0)
ffffffffc020414e:	6108                	ld	a0,0(a0)
ffffffffc0204150:	ff2ff06f          	j	ffffffffc0203942 <do_execve>

ffffffffc0204154 <sys_wait>:
	return do_wait(pid, store);
ffffffffc0204154:	650c                	ld	a1,8(a0)
ffffffffc0204156:	4108                	lw	a0,0(a0)
ffffffffc0204158:	ce3ff06f          	j	ffffffffc0203e3a <do_wait>

ffffffffc020415c <sys_fork>:
	struct trapframe *tf = current->tf;
ffffffffc020415c:	0001a797          	auipc	a5,0x1a
ffffffffc0204160:	6847b783          	ld	a5,1668(a5) # ffffffffc021e7e0 <current>
ffffffffc0204164:	73d0                	ld	a2,160(a5)
	return do_fork(0, stack, tf);
ffffffffc0204166:	4501                	li	a0,0
ffffffffc0204168:	6a0c                	ld	a1,16(a2)
ffffffffc020416a:	fc1fe06f          	j	ffffffffc020312a <do_fork>

ffffffffc020416e <sys_exit>:
	return do_exit(error_code);
ffffffffc020416e:	4108                	lw	a0,0(a0)
ffffffffc0204170:	bceff06f          	j	ffffffffc020353e <do_exit>

ffffffffc0204174 <syscall>:
};

#define NUM_SYSCALLS ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void syscall(void)
{
ffffffffc0204174:	7139                	addi	sp,sp,-64
	struct trapframe *tf = current->tf;
ffffffffc0204176:	0001a797          	auipc	a5,0x1a
ffffffffc020417a:	66a7b783          	ld	a5,1642(a5) # ffffffffc021e7e0 <current>
{
ffffffffc020417e:	f822                	sd	s0,48(sp)
	struct trapframe *tf = current->tf;
ffffffffc0204180:	73c0                	ld	s0,160(a5)
{
ffffffffc0204182:	fc06                	sd	ra,56(sp)
	uint64_t arg[5];
	int num = tf->gpr.a0;
	if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0204184:	4779                	li	a4,30
	int num = tf->gpr.a0;
ffffffffc0204186:	4834                	lw	a3,80(s0)
	if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0204188:	02d76c63          	bltu	a4,a3,ffffffffc02041c0 <syscall+0x4c>
		if (syscalls[num] != NULL) {
ffffffffc020418c:	00369613          	slli	a2,a3,0x3
ffffffffc0204190:	00002717          	auipc	a4,0x2
ffffffffc0204194:	bc870713          	addi	a4,a4,-1080 # ffffffffc0205d58 <syscalls>
ffffffffc0204198:	9732                	add	a4,a4,a2
ffffffffc020419a:	6318                	ld	a4,0(a4)
ffffffffc020419c:	c315                	beqz	a4,ffffffffc02041c0 <syscall+0x4c>
			arg[0] = tf->gpr.a1;
ffffffffc020419e:	6c28                	ld	a0,88(s0)
			arg[1] = tf->gpr.a2;
ffffffffc02041a0:	702c                	ld	a1,96(s0)
			arg[2] = tf->gpr.a3;
ffffffffc02041a2:	7430                	ld	a2,104(s0)
			arg[3] = tf->gpr.a4;
ffffffffc02041a4:	7834                	ld	a3,112(s0)
			arg[4] = tf->gpr.a5;
ffffffffc02041a6:	7c3c                	ld	a5,120(s0)
			arg[0] = tf->gpr.a1;
ffffffffc02041a8:	e42a                	sd	a0,8(sp)
			arg[1] = tf->gpr.a2;
ffffffffc02041aa:	e82e                	sd	a1,16(sp)
			arg[2] = tf->gpr.a3;
ffffffffc02041ac:	ec32                	sd	a2,24(sp)
			arg[3] = tf->gpr.a4;
ffffffffc02041ae:	f036                	sd	a3,32(sp)
			arg[4] = tf->gpr.a5;
ffffffffc02041b0:	f43e                	sd	a5,40(sp)
			tf->gpr.a0 = syscalls[num](arg); // sys_exec(arg)
ffffffffc02041b2:	0028                	addi	a0,sp,8
ffffffffc02041b4:	9702                	jalr	a4
			return;
		}
	}
	panic("undefined syscall %d, pid = %d, name = %s.\n", num, current->pid,
	      current->name);
}
ffffffffc02041b6:	70e2                	ld	ra,56(sp)
			tf->gpr.a0 = syscalls[num](arg); // sys_exec(arg)
ffffffffc02041b8:	e828                	sd	a0,80(s0)
}
ffffffffc02041ba:	7442                	ld	s0,48(sp)
ffffffffc02041bc:	6121                	addi	sp,sp,64
ffffffffc02041be:	8082                	ret
	panic("undefined syscall %d, pid = %d, name = %s.\n", num, current->pid,
ffffffffc02041c0:	43d8                	lw	a4,4(a5)
ffffffffc02041c2:	00002617          	auipc	a2,0x2
ffffffffc02041c6:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0205d10 <default_pmm_manager+0x540>
ffffffffc02041ca:	0b478793          	addi	a5,a5,180
ffffffffc02041ce:	05500593          	li	a1,85
ffffffffc02041d2:	00002517          	auipc	a0,0x2
ffffffffc02041d6:	b6e50513          	addi	a0,a0,-1170 # ffffffffc0205d40 <default_pmm_manager+0x570>
ffffffffc02041da:	f5ffb0ef          	jal	ra,ffffffffc0200138 <__panic>

ffffffffc02041de <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t strlen(const char *s)
{
	size_t cnt = 0;
	while (*s++ != '\0') {
ffffffffc02041de:	00054783          	lbu	a5,0(a0)
{
ffffffffc02041e2:	872a                	mv	a4,a0
	size_t cnt = 0;
ffffffffc02041e4:	4501                	li	a0,0
	while (*s++ != '\0') {
ffffffffc02041e6:	cb81                	beqz	a5,ffffffffc02041f6 <strlen+0x18>
		cnt++;
ffffffffc02041e8:	0505                	addi	a0,a0,1
	while (*s++ != '\0') {
ffffffffc02041ea:	00a707b3          	add	a5,a4,a0
ffffffffc02041ee:	0007c783          	lbu	a5,0(a5)
ffffffffc02041f2:	fbfd                	bnez	a5,ffffffffc02041e8 <strlen+0xa>
ffffffffc02041f4:	8082                	ret
	}
	return cnt;
}
ffffffffc02041f6:	8082                	ret

ffffffffc02041f8 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t strnlen(const char *s, size_t len)
{
ffffffffc02041f8:	872a                	mv	a4,a0
	size_t cnt = 0;
ffffffffc02041fa:	4501                	li	a0,0
	while (cnt < len && *s++ != '\0') {
ffffffffc02041fc:	e589                	bnez	a1,ffffffffc0204206 <strnlen+0xe>
ffffffffc02041fe:	a811                	j	ffffffffc0204212 <strnlen+0x1a>
		cnt++;
ffffffffc0204200:	0505                	addi	a0,a0,1
	while (cnt < len && *s++ != '\0') {
ffffffffc0204202:	00a58763          	beq	a1,a0,ffffffffc0204210 <strnlen+0x18>
ffffffffc0204206:	00a707b3          	add	a5,a4,a0
ffffffffc020420a:	0007c783          	lbu	a5,0(a5)
ffffffffc020420e:	fbed                	bnez	a5,ffffffffc0204200 <strnlen+0x8>
	}
	return cnt;
}
ffffffffc0204210:	8082                	ret
ffffffffc0204212:	8082                	ret

ffffffffc0204214 <memset>:
{
#ifdef __HAVE_ARCH_MEMSET
	return __memset(s, c, n);
#else
	char *p = s;
	while (n-- > 0) {
ffffffffc0204214:	ca01                	beqz	a2,ffffffffc0204224 <memset+0x10>
ffffffffc0204216:	962a                	add	a2,a2,a0
	char *p = s;
ffffffffc0204218:	87aa                	mv	a5,a0
		*p++ = c;
ffffffffc020421a:	0785                	addi	a5,a5,1
ffffffffc020421c:	feb78fa3          	sb	a1,-1(a5)
	while (n-- > 0) {
ffffffffc0204220:	fec79de3          	bne	a5,a2,ffffffffc020421a <memset+0x6>
	}
	return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204224:	8082                	ret

ffffffffc0204226 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
	return __memcpy(dst, src, n);
#else
	const char *s = src;
	char *d = dst;
	while (n-- > 0) {
ffffffffc0204226:	ca19                	beqz	a2,ffffffffc020423c <memcpy+0x16>
ffffffffc0204228:	962e                	add	a2,a2,a1
	char *d = dst;
ffffffffc020422a:	87aa                	mv	a5,a0
		*d++ = *s++;
ffffffffc020422c:	0005c703          	lbu	a4,0(a1)
ffffffffc0204230:	0585                	addi	a1,a1,1
ffffffffc0204232:	0785                	addi	a5,a5,1
ffffffffc0204234:	fee78fa3          	sb	a4,-1(a5)
	while (n-- > 0) {
ffffffffc0204238:	fec59ae3          	bne	a1,a2,ffffffffc020422c <memcpy+0x6>
	}
	return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020423c:	8082                	ret

ffffffffc020423e <printnum>:
 * */
static void printnum(void (*putch)(int, void *), void *putdat,
		     unsigned long long num, unsigned base, int width, int padc)
{
	unsigned long long result = num;
	unsigned mod = do_div(result, base);
ffffffffc020423e:	02069813          	slli	a6,a3,0x20
{
ffffffffc0204242:	7179                	addi	sp,sp,-48
	unsigned mod = do_div(result, base);
ffffffffc0204244:	02085813          	srli	a6,a6,0x20
{
ffffffffc0204248:	e052                	sd	s4,0(sp)
	unsigned mod = do_div(result, base);
ffffffffc020424a:	03067a33          	remu	s4,a2,a6
{
ffffffffc020424e:	f022                	sd	s0,32(sp)
ffffffffc0204250:	ec26                	sd	s1,24(sp)
ffffffffc0204252:	e84a                	sd	s2,16(sp)
ffffffffc0204254:	f406                	sd	ra,40(sp)
ffffffffc0204256:	e44e                	sd	s3,8(sp)
ffffffffc0204258:	84aa                	mv	s1,a0
ffffffffc020425a:	892e                	mv	s2,a1
ffffffffc020425c:	fff7041b          	addiw	s0,a4,-1
	unsigned mod = do_div(result, base);
ffffffffc0204260:	2a01                	sext.w	s4,s4

	// first recursively print all preceding (more significant) digits
	if (num >= base) {
ffffffffc0204262:	03067e63          	bgeu	a2,a6,ffffffffc020429e <printnum+0x60>
ffffffffc0204266:	89be                	mv	s3,a5
		printnum(putch, putdat, result, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
ffffffffc0204268:	00805763          	blez	s0,ffffffffc0204276 <printnum+0x38>
ffffffffc020426c:	347d                	addiw	s0,s0,-1
			putch(padc, putdat);
ffffffffc020426e:	85ca                	mv	a1,s2
ffffffffc0204270:	854e                	mv	a0,s3
ffffffffc0204272:	9482                	jalr	s1
		while (--width > 0)
ffffffffc0204274:	fc65                	bnez	s0,ffffffffc020426c <printnum+0x2e>
	}
	// then print this (the least significant) digit
	putch("0123456789abcdef"[mod], putdat);
ffffffffc0204276:	1a02                	slli	s4,s4,0x20
ffffffffc0204278:	020a5a13          	srli	s4,s4,0x20
ffffffffc020427c:	00002797          	auipc	a5,0x2
ffffffffc0204280:	bd478793          	addi	a5,a5,-1068 # ffffffffc0205e50 <syscalls+0xf8>
	// Crashes if num >= base. No idea what going on here
	// Here is a quick fix
	// update: Stack grows downward and destory the SBI
	// sbi_console_putchar("0123456789abcdef"[mod]);
	// (*(int *)putdat)++;
}
ffffffffc0204284:	7402                	ld	s0,32(sp)
	putch("0123456789abcdef"[mod], putdat);
ffffffffc0204286:	9a3e                	add	s4,s4,a5
ffffffffc0204288:	000a4503          	lbu	a0,0(s4)
}
ffffffffc020428c:	70a2                	ld	ra,40(sp)
ffffffffc020428e:	69a2                	ld	s3,8(sp)
ffffffffc0204290:	6a02                	ld	s4,0(sp)
	putch("0123456789abcdef"[mod], putdat);
ffffffffc0204292:	85ca                	mv	a1,s2
ffffffffc0204294:	8326                	mv	t1,s1
}
ffffffffc0204296:	6942                	ld	s2,16(sp)
ffffffffc0204298:	64e2                	ld	s1,24(sp)
ffffffffc020429a:	6145                	addi	sp,sp,48
	putch("0123456789abcdef"[mod], putdat);
ffffffffc020429c:	8302                	jr	t1
		printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020429e:	03065633          	divu	a2,a2,a6
ffffffffc02042a2:	8722                	mv	a4,s0
ffffffffc02042a4:	f9bff0ef          	jal	ra,ffffffffc020423e <printnum>
ffffffffc02042a8:	b7f9                	j	ffffffffc0204276 <printnum+0x38>

ffffffffc02042aa <vprintfmt>:
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void vprintfmt(void (*putch)(int, void *), void *putdat, const char *fmt,
	       va_list ap)
{
ffffffffc02042aa:	7119                	addi	sp,sp,-128
ffffffffc02042ac:	f4a6                	sd	s1,104(sp)
ffffffffc02042ae:	f0ca                	sd	s2,96(sp)
ffffffffc02042b0:	ecce                	sd	s3,88(sp)
ffffffffc02042b2:	e8d2                	sd	s4,80(sp)
ffffffffc02042b4:	e4d6                	sd	s5,72(sp)
ffffffffc02042b6:	e0da                	sd	s6,64(sp)
ffffffffc02042b8:	fc5e                	sd	s7,56(sp)
ffffffffc02042ba:	f06a                	sd	s10,32(sp)
ffffffffc02042bc:	fc86                	sd	ra,120(sp)
ffffffffc02042be:	f8a2                	sd	s0,112(sp)
ffffffffc02042c0:	f862                	sd	s8,48(sp)
ffffffffc02042c2:	f466                	sd	s9,40(sp)
ffffffffc02042c4:	ec6e                	sd	s11,24(sp)
ffffffffc02042c6:	892a                	mv	s2,a0
ffffffffc02042c8:	84ae                	mv	s1,a1
ffffffffc02042ca:	8d32                	mv	s10,a2
ffffffffc02042cc:	8a36                	mv	s4,a3
	register int ch, err;
	unsigned long long num;
	int base, width, precision, lflag, altflag;

	while (1) {
		while ((ch = *(unsigned char *)fmt++) != '%') {
ffffffffc02042ce:	02500993          	li	s3,37
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		char padc = ' ';
		width = precision = -1;
ffffffffc02042d2:	5b7d                	li	s6,-1
ffffffffc02042d4:	00002a97          	auipc	s5,0x2
ffffffffc02042d8:	bb0a8a93          	addi	s5,s5,-1104 # ffffffffc0205e84 <syscalls+0x12c>
		case 'e':
			err = va_arg(ap, int);
			if (err < 0) {
				err = -err;
			}
			if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02042dc:	00002b97          	auipc	s7,0x2
ffffffffc02042e0:	dc4b8b93          	addi	s7,s7,-572 # ffffffffc02060a0 <error_string>
		while ((ch = *(unsigned char *)fmt++) != '%') {
ffffffffc02042e4:	000d4503          	lbu	a0,0(s10)
ffffffffc02042e8:	001d0413          	addi	s0,s10,1
ffffffffc02042ec:	01350a63          	beq	a0,s3,ffffffffc0204300 <vprintfmt+0x56>
			if (ch == '\0') {
ffffffffc02042f0:	c121                	beqz	a0,ffffffffc0204330 <vprintfmt+0x86>
			putch(ch, putdat);
ffffffffc02042f2:	85a6                	mv	a1,s1
		while ((ch = *(unsigned char *)fmt++) != '%') {
ffffffffc02042f4:	0405                	addi	s0,s0,1
			putch(ch, putdat);
ffffffffc02042f6:	9902                	jalr	s2
		while ((ch = *(unsigned char *)fmt++) != '%') {
ffffffffc02042f8:	fff44503          	lbu	a0,-1(s0)
ffffffffc02042fc:	ff351ae3          	bne	a0,s3,ffffffffc02042f0 <vprintfmt+0x46>
ffffffffc0204300:	00044603          	lbu	a2,0(s0)
		char padc = ' ';
ffffffffc0204304:	02000793          	li	a5,32
		lflag = altflag = 0;
ffffffffc0204308:	4c81                	li	s9,0
ffffffffc020430a:	4881                	li	a7,0
		width = precision = -1;
ffffffffc020430c:	5c7d                	li	s8,-1
ffffffffc020430e:	5dfd                	li	s11,-1
ffffffffc0204310:	05500513          	li	a0,85
				if (ch < '0' || ch > '9') {
ffffffffc0204314:	4825                	li	a6,9
		switch (ch = *(unsigned char *)fmt++) {
ffffffffc0204316:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020431a:	0ff5f593          	andi	a1,a1,255
ffffffffc020431e:	00140d13          	addi	s10,s0,1
ffffffffc0204322:	04b56263          	bltu	a0,a1,ffffffffc0204366 <vprintfmt+0xbc>
ffffffffc0204326:	058a                	slli	a1,a1,0x2
ffffffffc0204328:	95d6                	add	a1,a1,s5
ffffffffc020432a:	4194                	lw	a3,0(a1)
ffffffffc020432c:	96d6                	add	a3,a3,s5
ffffffffc020432e:	8682                	jr	a3
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
ffffffffc0204330:	70e6                	ld	ra,120(sp)
ffffffffc0204332:	7446                	ld	s0,112(sp)
ffffffffc0204334:	74a6                	ld	s1,104(sp)
ffffffffc0204336:	7906                	ld	s2,96(sp)
ffffffffc0204338:	69e6                	ld	s3,88(sp)
ffffffffc020433a:	6a46                	ld	s4,80(sp)
ffffffffc020433c:	6aa6                	ld	s5,72(sp)
ffffffffc020433e:	6b06                	ld	s6,64(sp)
ffffffffc0204340:	7be2                	ld	s7,56(sp)
ffffffffc0204342:	7c42                	ld	s8,48(sp)
ffffffffc0204344:	7ca2                	ld	s9,40(sp)
ffffffffc0204346:	7d02                	ld	s10,32(sp)
ffffffffc0204348:	6de2                	ld	s11,24(sp)
ffffffffc020434a:	6109                	addi	sp,sp,128
ffffffffc020434c:	8082                	ret
			padc = '0';
ffffffffc020434e:	87b2                	mv	a5,a2
			goto reswitch;
ffffffffc0204350:	00144603          	lbu	a2,1(s0)
		switch (ch = *(unsigned char *)fmt++) {
ffffffffc0204354:	846a                	mv	s0,s10
ffffffffc0204356:	00140d13          	addi	s10,s0,1
ffffffffc020435a:	fdd6059b          	addiw	a1,a2,-35
ffffffffc020435e:	0ff5f593          	andi	a1,a1,255
ffffffffc0204362:	fcb572e3          	bgeu	a0,a1,ffffffffc0204326 <vprintfmt+0x7c>
			putch('%', putdat);
ffffffffc0204366:	85a6                	mv	a1,s1
ffffffffc0204368:	02500513          	li	a0,37
ffffffffc020436c:	9902                	jalr	s2
			for (fmt--; fmt[-1] != '%'; fmt--)
ffffffffc020436e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204372:	8d22                	mv	s10,s0
ffffffffc0204374:	f73788e3          	beq	a5,s3,ffffffffc02042e4 <vprintfmt+0x3a>
ffffffffc0204378:	ffed4783          	lbu	a5,-2(s10)
ffffffffc020437c:	1d7d                	addi	s10,s10,-1
ffffffffc020437e:	ff379de3          	bne	a5,s3,ffffffffc0204378 <vprintfmt+0xce>
ffffffffc0204382:	b78d                	j	ffffffffc02042e4 <vprintfmt+0x3a>
				precision = precision * 10 + ch - '0';
ffffffffc0204384:	fd060c1b          	addiw	s8,a2,-48
				ch = *fmt;
ffffffffc0204388:	00144603          	lbu	a2,1(s0)
		switch (ch = *(unsigned char *)fmt++) {
ffffffffc020438c:	846a                	mv	s0,s10
				if (ch < '0' || ch > '9') {
ffffffffc020438e:	fd06069b          	addiw	a3,a2,-48
				ch = *fmt;
ffffffffc0204392:	0006059b          	sext.w	a1,a2
				if (ch < '0' || ch > '9') {
ffffffffc0204396:	02d86463          	bltu	a6,a3,ffffffffc02043be <vprintfmt+0x114>
				ch = *fmt;
ffffffffc020439a:	00144603          	lbu	a2,1(s0)
				precision = precision * 10 + ch - '0';
ffffffffc020439e:	002c169b          	slliw	a3,s8,0x2
ffffffffc02043a2:	0186873b          	addw	a4,a3,s8
ffffffffc02043a6:	0017171b          	slliw	a4,a4,0x1
ffffffffc02043aa:	9f2d                	addw	a4,a4,a1
				if (ch < '0' || ch > '9') {
ffffffffc02043ac:	fd06069b          	addiw	a3,a2,-48
			for (precision = 0;; ++fmt) {
ffffffffc02043b0:	0405                	addi	s0,s0,1
				precision = precision * 10 + ch - '0';
ffffffffc02043b2:	fd070c1b          	addiw	s8,a4,-48
				ch = *fmt;
ffffffffc02043b6:	0006059b          	sext.w	a1,a2
				if (ch < '0' || ch > '9') {
ffffffffc02043ba:	fed870e3          	bgeu	a6,a3,ffffffffc020439a <vprintfmt+0xf0>
			if (width < 0)
ffffffffc02043be:	f40ddce3          	bgez	s11,ffffffffc0204316 <vprintfmt+0x6c>
				width = precision, precision = -1;
ffffffffc02043c2:	8de2                	mv	s11,s8
ffffffffc02043c4:	5c7d                	li	s8,-1
ffffffffc02043c6:	bf81                	j	ffffffffc0204316 <vprintfmt+0x6c>
			if (width < 0)
ffffffffc02043c8:	fffdc693          	not	a3,s11
ffffffffc02043cc:	96fd                	srai	a3,a3,0x3f
ffffffffc02043ce:	00ddfdb3          	and	s11,s11,a3
ffffffffc02043d2:	00144603          	lbu	a2,1(s0)
ffffffffc02043d6:	2d81                	sext.w	s11,s11
		switch (ch = *(unsigned char *)fmt++) {
ffffffffc02043d8:	846a                	mv	s0,s10
			goto reswitch;
ffffffffc02043da:	bf35                	j	ffffffffc0204316 <vprintfmt+0x6c>
			precision = va_arg(ap, int);
ffffffffc02043dc:	000a2c03          	lw	s8,0(s4)
			goto process_precision;
ffffffffc02043e0:	00144603          	lbu	a2,1(s0)
			precision = va_arg(ap, int);
ffffffffc02043e4:	0a21                	addi	s4,s4,8
		switch (ch = *(unsigned char *)fmt++) {
ffffffffc02043e6:	846a                	mv	s0,s10
			goto process_precision;
ffffffffc02043e8:	bfd9                	j	ffffffffc02043be <vprintfmt+0x114>
	if (lflag >= 2) {
ffffffffc02043ea:	4705                	li	a4,1
ffffffffc02043ec:	008a0593          	addi	a1,s4,8
ffffffffc02043f0:	01174463          	blt	a4,a7,ffffffffc02043f8 <vprintfmt+0x14e>
	} else if (lflag) {
ffffffffc02043f4:	1a088e63          	beqz	a7,ffffffffc02045b0 <vprintfmt+0x306>
		return va_arg(*ap, unsigned long);
ffffffffc02043f8:	000a3603          	ld	a2,0(s4)
ffffffffc02043fc:	46c1                	li	a3,16
ffffffffc02043fe:	8a2e                	mv	s4,a1
			printnum(putch, putdat, num, base, width, padc);
ffffffffc0204400:	2781                	sext.w	a5,a5
ffffffffc0204402:	876e                	mv	a4,s11
ffffffffc0204404:	85a6                	mv	a1,s1
ffffffffc0204406:	854a                	mv	a0,s2
ffffffffc0204408:	e37ff0ef          	jal	ra,ffffffffc020423e <printnum>
			break;
ffffffffc020440c:	bde1                	j	ffffffffc02042e4 <vprintfmt+0x3a>
			putch(va_arg(ap, int), putdat);
ffffffffc020440e:	000a2503          	lw	a0,0(s4)
ffffffffc0204412:	85a6                	mv	a1,s1
ffffffffc0204414:	0a21                	addi	s4,s4,8
ffffffffc0204416:	9902                	jalr	s2
			break;
ffffffffc0204418:	b5f1                	j	ffffffffc02042e4 <vprintfmt+0x3a>
	if (lflag >= 2) {
ffffffffc020441a:	4705                	li	a4,1
ffffffffc020441c:	008a0593          	addi	a1,s4,8
ffffffffc0204420:	01174463          	blt	a4,a7,ffffffffc0204428 <vprintfmt+0x17e>
	} else if (lflag) {
ffffffffc0204424:	18088163          	beqz	a7,ffffffffc02045a6 <vprintfmt+0x2fc>
		return va_arg(*ap, unsigned long);
ffffffffc0204428:	000a3603          	ld	a2,0(s4)
ffffffffc020442c:	46a9                	li	a3,10
ffffffffc020442e:	8a2e                	mv	s4,a1
ffffffffc0204430:	bfc1                	j	ffffffffc0204400 <vprintfmt+0x156>
			goto reswitch;
ffffffffc0204432:	00144603          	lbu	a2,1(s0)
			altflag = 1;
ffffffffc0204436:	4c85                	li	s9,1
		switch (ch = *(unsigned char *)fmt++) {
ffffffffc0204438:	846a                	mv	s0,s10
			goto reswitch;
ffffffffc020443a:	bdf1                	j	ffffffffc0204316 <vprintfmt+0x6c>
			putch(ch, putdat);
ffffffffc020443c:	85a6                	mv	a1,s1
ffffffffc020443e:	02500513          	li	a0,37
ffffffffc0204442:	9902                	jalr	s2
			break;
ffffffffc0204444:	b545                	j	ffffffffc02042e4 <vprintfmt+0x3a>
			lflag++;
ffffffffc0204446:	00144603          	lbu	a2,1(s0)
ffffffffc020444a:	2885                	addiw	a7,a7,1
		switch (ch = *(unsigned char *)fmt++) {
ffffffffc020444c:	846a                	mv	s0,s10
			goto reswitch;
ffffffffc020444e:	b5e1                	j	ffffffffc0204316 <vprintfmt+0x6c>
	if (lflag >= 2) {
ffffffffc0204450:	4705                	li	a4,1
ffffffffc0204452:	008a0593          	addi	a1,s4,8
ffffffffc0204456:	01174463          	blt	a4,a7,ffffffffc020445e <vprintfmt+0x1b4>
	} else if (lflag) {
ffffffffc020445a:	14088163          	beqz	a7,ffffffffc020459c <vprintfmt+0x2f2>
		return va_arg(*ap, unsigned long);
ffffffffc020445e:	000a3603          	ld	a2,0(s4)
ffffffffc0204462:	46a1                	li	a3,8
ffffffffc0204464:	8a2e                	mv	s4,a1
ffffffffc0204466:	bf69                	j	ffffffffc0204400 <vprintfmt+0x156>
			putch('0', putdat);
ffffffffc0204468:	03000513          	li	a0,48
ffffffffc020446c:	85a6                	mv	a1,s1
ffffffffc020446e:	e03e                	sd	a5,0(sp)
ffffffffc0204470:	9902                	jalr	s2
			putch('x', putdat);
ffffffffc0204472:	85a6                	mv	a1,s1
ffffffffc0204474:	07800513          	li	a0,120
ffffffffc0204478:	9902                	jalr	s2
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020447a:	0a21                	addi	s4,s4,8
			goto number;
ffffffffc020447c:	6782                	ld	a5,0(sp)
ffffffffc020447e:	46c1                	li	a3,16
			num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204480:	ff8a3603          	ld	a2,-8(s4)
			goto number;
ffffffffc0204484:	bfb5                	j	ffffffffc0204400 <vprintfmt+0x156>
			if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204486:	000a3403          	ld	s0,0(s4)
ffffffffc020448a:	008a0713          	addi	a4,s4,8
ffffffffc020448e:	e03a                	sd	a4,0(sp)
ffffffffc0204490:	14040263          	beqz	s0,ffffffffc02045d4 <vprintfmt+0x32a>
			if (width > 0 && padc != '-') {
ffffffffc0204494:	0fb05763          	blez	s11,ffffffffc0204582 <vprintfmt+0x2d8>
ffffffffc0204498:	02d00693          	li	a3,45
ffffffffc020449c:	0cd79163          	bne	a5,a3,ffffffffc020455e <vprintfmt+0x2b4>
			for (; (ch = *p++) != '\0' &&
ffffffffc02044a0:	00044783          	lbu	a5,0(s0)
ffffffffc02044a4:	0007851b          	sext.w	a0,a5
ffffffffc02044a8:	cf85                	beqz	a5,ffffffffc02044e0 <vprintfmt+0x236>
ffffffffc02044aa:	00140a13          	addi	s4,s0,1
				if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02044ae:	05e00413          	li	s0,94
			for (; (ch = *p++) != '\0' &&
ffffffffc02044b2:	000c4563          	bltz	s8,ffffffffc02044bc <vprintfmt+0x212>
			       (precision < 0 || --precision >= 0);
ffffffffc02044b6:	3c7d                	addiw	s8,s8,-1
ffffffffc02044b8:	036c0263          	beq	s8,s6,ffffffffc02044dc <vprintfmt+0x232>
					putch('?', putdat);
ffffffffc02044bc:	85a6                	mv	a1,s1
				if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02044be:	0e0c8e63          	beqz	s9,ffffffffc02045ba <vprintfmt+0x310>
ffffffffc02044c2:	3781                	addiw	a5,a5,-32
ffffffffc02044c4:	0ef47b63          	bgeu	s0,a5,ffffffffc02045ba <vprintfmt+0x310>
					putch('?', putdat);
ffffffffc02044c8:	03f00513          	li	a0,63
ffffffffc02044cc:	9902                	jalr	s2
			for (; (ch = *p++) != '\0' &&
ffffffffc02044ce:	000a4783          	lbu	a5,0(s4)
			     width--) {
ffffffffc02044d2:	3dfd                	addiw	s11,s11,-1
			for (; (ch = *p++) != '\0' &&
ffffffffc02044d4:	0a05                	addi	s4,s4,1
ffffffffc02044d6:	0007851b          	sext.w	a0,a5
ffffffffc02044da:	ffe1                	bnez	a5,ffffffffc02044b2 <vprintfmt+0x208>
			for (; width > 0; width--) {
ffffffffc02044dc:	01b05963          	blez	s11,ffffffffc02044ee <vprintfmt+0x244>
ffffffffc02044e0:	3dfd                	addiw	s11,s11,-1
				putch(' ', putdat);
ffffffffc02044e2:	85a6                	mv	a1,s1
ffffffffc02044e4:	02000513          	li	a0,32
ffffffffc02044e8:	9902                	jalr	s2
			for (; width > 0; width--) {
ffffffffc02044ea:	fe0d9be3          	bnez	s11,ffffffffc02044e0 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02044ee:	6a02                	ld	s4,0(sp)
ffffffffc02044f0:	bbd5                	j	ffffffffc02042e4 <vprintfmt+0x3a>
	if (lflag >= 2) {
ffffffffc02044f2:	4705                	li	a4,1
ffffffffc02044f4:	008a0c93          	addi	s9,s4,8
ffffffffc02044f8:	01174463          	blt	a4,a7,ffffffffc0204500 <vprintfmt+0x256>
	} else if (lflag) {
ffffffffc02044fc:	08088d63          	beqz	a7,ffffffffc0204596 <vprintfmt+0x2ec>
		return va_arg(*ap, long);
ffffffffc0204500:	000a3403          	ld	s0,0(s4)
			if ((long long)num < 0) {
ffffffffc0204504:	0a044d63          	bltz	s0,ffffffffc02045be <vprintfmt+0x314>
			num = getint(&ap, lflag);
ffffffffc0204508:	8622                	mv	a2,s0
ffffffffc020450a:	8a66                	mv	s4,s9
ffffffffc020450c:	46a9                	li	a3,10
ffffffffc020450e:	bdcd                	j	ffffffffc0204400 <vprintfmt+0x156>
			err = va_arg(ap, int);
ffffffffc0204510:	000a2783          	lw	a5,0(s4)
			if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204514:	4761                	li	a4,24
			err = va_arg(ap, int);
ffffffffc0204516:	0a21                	addi	s4,s4,8
			if (err < 0) {
ffffffffc0204518:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020451c:	8fb5                	xor	a5,a5,a3
ffffffffc020451e:	40d786bb          	subw	a3,a5,a3
			if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204522:	02d74163          	blt	a4,a3,ffffffffc0204544 <vprintfmt+0x29a>
ffffffffc0204526:	00369793          	slli	a5,a3,0x3
ffffffffc020452a:	97de                	add	a5,a5,s7
ffffffffc020452c:	639c                	ld	a5,0(a5)
ffffffffc020452e:	cb99                	beqz	a5,ffffffffc0204544 <vprintfmt+0x29a>
				printfmt(putch, putdat, "%s", p);
ffffffffc0204530:	86be                	mv	a3,a5
ffffffffc0204532:	00002617          	auipc	a2,0x2
ffffffffc0204536:	94e60613          	addi	a2,a2,-1714 # ffffffffc0205e80 <syscalls+0x128>
ffffffffc020453a:	85a6                	mv	a1,s1
ffffffffc020453c:	854a                	mv	a0,s2
ffffffffc020453e:	0ce000ef          	jal	ra,ffffffffc020460c <printfmt>
ffffffffc0204542:	b34d                	j	ffffffffc02042e4 <vprintfmt+0x3a>
				printfmt(putch, putdat, "error %d", err);
ffffffffc0204544:	00002617          	auipc	a2,0x2
ffffffffc0204548:	92c60613          	addi	a2,a2,-1748 # ffffffffc0205e70 <syscalls+0x118>
ffffffffc020454c:	85a6                	mv	a1,s1
ffffffffc020454e:	854a                	mv	a0,s2
ffffffffc0204550:	0bc000ef          	jal	ra,ffffffffc020460c <printfmt>
ffffffffc0204554:	bb41                	j	ffffffffc02042e4 <vprintfmt+0x3a>
				p = "(null)";
ffffffffc0204556:	00002417          	auipc	s0,0x2
ffffffffc020455a:	91240413          	addi	s0,s0,-1774 # ffffffffc0205e68 <syscalls+0x110>
				for (width -= strnlen(p, precision); width > 0;
ffffffffc020455e:	85e2                	mv	a1,s8
ffffffffc0204560:	8522                	mv	a0,s0
ffffffffc0204562:	e43e                	sd	a5,8(sp)
ffffffffc0204564:	c95ff0ef          	jal	ra,ffffffffc02041f8 <strnlen>
ffffffffc0204568:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020456c:	01b05b63          	blez	s11,ffffffffc0204582 <vprintfmt+0x2d8>
ffffffffc0204570:	67a2                	ld	a5,8(sp)
ffffffffc0204572:	00078a1b          	sext.w	s4,a5
				     width--) {
ffffffffc0204576:	3dfd                	addiw	s11,s11,-1
					putch(padc, putdat);
ffffffffc0204578:	85a6                	mv	a1,s1
ffffffffc020457a:	8552                	mv	a0,s4
ffffffffc020457c:	9902                	jalr	s2
				for (width -= strnlen(p, precision); width > 0;
ffffffffc020457e:	fe0d9ce3          	bnez	s11,ffffffffc0204576 <vprintfmt+0x2cc>
			for (; (ch = *p++) != '\0' &&
ffffffffc0204582:	00044783          	lbu	a5,0(s0)
ffffffffc0204586:	00140a13          	addi	s4,s0,1
ffffffffc020458a:	0007851b          	sext.w	a0,a5
ffffffffc020458e:	d3a5                	beqz	a5,ffffffffc02044ee <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204590:	05e00413          	li	s0,94
ffffffffc0204594:	bf39                	j	ffffffffc02044b2 <vprintfmt+0x208>
		return va_arg(*ap, int);
ffffffffc0204596:	000a2403          	lw	s0,0(s4)
ffffffffc020459a:	b7ad                	j	ffffffffc0204504 <vprintfmt+0x25a>
		return va_arg(*ap, unsigned int);
ffffffffc020459c:	000a6603          	lwu	a2,0(s4)
ffffffffc02045a0:	46a1                	li	a3,8
ffffffffc02045a2:	8a2e                	mv	s4,a1
ffffffffc02045a4:	bdb1                	j	ffffffffc0204400 <vprintfmt+0x156>
ffffffffc02045a6:	000a6603          	lwu	a2,0(s4)
ffffffffc02045aa:	46a9                	li	a3,10
ffffffffc02045ac:	8a2e                	mv	s4,a1
ffffffffc02045ae:	bd89                	j	ffffffffc0204400 <vprintfmt+0x156>
ffffffffc02045b0:	000a6603          	lwu	a2,0(s4)
ffffffffc02045b4:	46c1                	li	a3,16
ffffffffc02045b6:	8a2e                	mv	s4,a1
ffffffffc02045b8:	b5a1                	j	ffffffffc0204400 <vprintfmt+0x156>
					putch(ch, putdat);
ffffffffc02045ba:	9902                	jalr	s2
ffffffffc02045bc:	bf09                	j	ffffffffc02044ce <vprintfmt+0x224>
				putch('-', putdat);
ffffffffc02045be:	85a6                	mv	a1,s1
ffffffffc02045c0:	02d00513          	li	a0,45
ffffffffc02045c4:	e03e                	sd	a5,0(sp)
ffffffffc02045c6:	9902                	jalr	s2
				num = -(long long)num;
ffffffffc02045c8:	6782                	ld	a5,0(sp)
ffffffffc02045ca:	8a66                	mv	s4,s9
ffffffffc02045cc:	40800633          	neg	a2,s0
ffffffffc02045d0:	46a9                	li	a3,10
ffffffffc02045d2:	b53d                	j	ffffffffc0204400 <vprintfmt+0x156>
			if (width > 0 && padc != '-') {
ffffffffc02045d4:	03b05163          	blez	s11,ffffffffc02045f6 <vprintfmt+0x34c>
ffffffffc02045d8:	02d00693          	li	a3,45
ffffffffc02045dc:	f6d79de3          	bne	a5,a3,ffffffffc0204556 <vprintfmt+0x2ac>
				p = "(null)";
ffffffffc02045e0:	00002417          	auipc	s0,0x2
ffffffffc02045e4:	88840413          	addi	s0,s0,-1912 # ffffffffc0205e68 <syscalls+0x110>
			for (; (ch = *p++) != '\0' &&
ffffffffc02045e8:	02800793          	li	a5,40
ffffffffc02045ec:	02800513          	li	a0,40
ffffffffc02045f0:	00140a13          	addi	s4,s0,1
ffffffffc02045f4:	bd6d                	j	ffffffffc02044ae <vprintfmt+0x204>
ffffffffc02045f6:	00002a17          	auipc	s4,0x2
ffffffffc02045fa:	873a0a13          	addi	s4,s4,-1933 # ffffffffc0205e69 <syscalls+0x111>
ffffffffc02045fe:	02800513          	li	a0,40
ffffffffc0204602:	02800793          	li	a5,40
				if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204606:	05e00413          	li	s0,94
ffffffffc020460a:	b565                	j	ffffffffc02044b2 <vprintfmt+0x208>

ffffffffc020460c <printfmt>:
{
ffffffffc020460c:	715d                	addi	sp,sp,-80
	va_start(ap, fmt);
ffffffffc020460e:	02810313          	addi	t1,sp,40
{
ffffffffc0204612:	f436                	sd	a3,40(sp)
	vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204614:	869a                	mv	a3,t1
{
ffffffffc0204616:	ec06                	sd	ra,24(sp)
ffffffffc0204618:	f83a                	sd	a4,48(sp)
ffffffffc020461a:	fc3e                	sd	a5,56(sp)
ffffffffc020461c:	e0c2                	sd	a6,64(sp)
ffffffffc020461e:	e4c6                	sd	a7,72(sp)
	va_start(ap, fmt);
ffffffffc0204620:	e41a                	sd	t1,8(sp)
	vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204622:	c89ff0ef          	jal	ra,ffffffffc02042aa <vprintfmt>
}
ffffffffc0204626:	60e2                	ld	ra,24(sp)
ffffffffc0204628:	6161                	addi	sp,sp,80
ffffffffc020462a:	8082                	ret

ffffffffc020462c <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t hash32(uint32_t val, unsigned int bits)
{
	uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020462c:	9e3707b7          	lui	a5,0x9e370
ffffffffc0204630:	2785                	addiw	a5,a5,1
ffffffffc0204632:	02a7853b          	mulw	a0,a5,a0
	return (hash >> (32 - bits));
ffffffffc0204636:	02000793          	li	a5,32
ffffffffc020463a:	9f8d                	subw	a5,a5,a1
}
ffffffffc020463c:	00f5553b          	srlw	a0,a0,a5
ffffffffc0204640:	8082                	ret
