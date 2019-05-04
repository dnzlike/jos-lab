
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0
	# movl	%eax, %cr4

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 20 12 f0       	mov    $0xf0122000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5e 00 00 00       	call   f010009c <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 0e 25 f0 00 	cmpl   $0x0,0xf0250e80
f010004f:	74 0f                	je     f0100060 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100051:	83 ec 0c             	sub    $0xc,%esp
f0100054:	6a 00                	push   $0x0
f0100056:	e8 4b 0c 00 00       	call   f0100ca6 <monitor>
f010005b:	83 c4 10             	add    $0x10,%esp
f010005e:	eb f1                	jmp    f0100051 <_panic+0x11>
	panicstr = fmt;
f0100060:	89 35 80 0e 25 f0    	mov    %esi,0xf0250e80
	asm volatile("cli; cld");
f0100066:	fa                   	cli    
f0100067:	fc                   	cld    
	va_start(ap, fmt);
f0100068:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006b:	e8 8e 61 00 00       	call   f01061fe <cpunum>
f0100070:	ff 75 0c             	pushl  0xc(%ebp)
f0100073:	ff 75 08             	pushl  0x8(%ebp)
f0100076:	50                   	push   %eax
f0100077:	68 60 68 10 f0       	push   $0xf0106860
f010007c:	e8 54 3c 00 00       	call   f0103cd5 <cprintf>
	vcprintf(fmt, ap);
f0100081:	83 c4 08             	add    $0x8,%esp
f0100084:	53                   	push   %ebx
f0100085:	56                   	push   %esi
f0100086:	e8 24 3c 00 00       	call   f0103caf <vcprintf>
	cprintf("\n");
f010008b:	c7 04 24 68 7d 10 f0 	movl   $0xf0107d68,(%esp)
f0100092:	e8 3e 3c 00 00       	call   f0103cd5 <cprintf>
f0100097:	83 c4 10             	add    $0x10,%esp
f010009a:	eb b5                	jmp    f0100051 <_panic+0x11>

f010009c <i386_init>:
{
f010009c:	55                   	push   %ebp
f010009d:	89 e5                	mov    %esp,%ebp
f010009f:	57                   	push   %edi
f01000a0:	53                   	push   %ebx
f01000a1:	81 ec 14 01 00 00    	sub    $0x114,%esp
	char chnum1 = 0, chnum2 = 0, ntest[256] = {};
f01000a7:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
f01000ab:	c6 45 f6 00          	movb   $0x0,-0xa(%ebp)
f01000af:	c7 85 f6 fe ff ff 00 	movl   $0x0,-0x10a(%ebp)
f01000b6:	00 00 00 
f01000b9:	c7 45 f2 00 00 00 00 	movl   $0x0,-0xe(%ebp)
f01000c0:	8d bd f8 fe ff ff    	lea    -0x108(%ebp),%edi
f01000c6:	b9 3f 00 00 00       	mov    $0x3f,%ecx
f01000cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01000d0:	f3 ab                	rep stos %eax,%es:(%edi)
	memset(edata, 0, end - edata);
f01000d2:	b8 08 20 29 f0       	mov    $0xf0292008,%eax
f01000d7:	2d 00 00 25 f0       	sub    $0xf0250000,%eax
f01000dc:	50                   	push   %eax
f01000dd:	6a 00                	push   $0x0
f01000df:	68 00 00 25 f0       	push   $0xf0250000
f01000e4:	e8 14 5b 00 00       	call   f0105bfd <memset>
	cons_init();
f01000e9:	e8 03 06 00 00       	call   f01006f1 <cons_init>
	cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);
f01000ee:	8d 45 f6             	lea    -0xa(%ebp),%eax
f01000f1:	50                   	push   %eax
f01000f2:	8d 7d f7             	lea    -0x9(%ebp),%edi
f01000f5:	57                   	push   %edi
f01000f6:	68 ac 1a 00 00       	push   $0x1aac
f01000fb:	68 84 68 10 f0       	push   $0xf0106884
f0100100:	e8 d0 3b 00 00       	call   f0103cd5 <cprintf>
	cprintf("pading space in the right to number 22: %-8d.\n", 22);
f0100105:	83 c4 18             	add    $0x18,%esp
f0100108:	6a 16                	push   $0x16
f010010a:	68 a4 68 10 f0       	push   $0xf01068a4
f010010f:	e8 c1 3b 00 00       	call   f0103cd5 <cprintf>
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f0100114:	83 c4 0c             	add    $0xc,%esp
f0100117:	0f be 45 f6          	movsbl -0xa(%ebp),%eax
f010011b:	50                   	push   %eax
f010011c:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
f0100120:	50                   	push   %eax
f0100121:	68 1c 69 10 f0       	push   $0xf010691c
f0100126:	e8 aa 3b 00 00       	call   f0103cd5 <cprintf>
	cprintf("%n", NULL);
f010012b:	83 c4 08             	add    $0x8,%esp
f010012e:	6a 00                	push   $0x0
f0100130:	68 35 69 10 f0       	push   $0xf0106935
f0100135:	e8 9b 3b 00 00       	call   f0103cd5 <cprintf>
	memset(ntest, 0xd, sizeof(ntest) - 1);
f010013a:	83 c4 0c             	add    $0xc,%esp
f010013d:	68 ff 00 00 00       	push   $0xff
f0100142:	6a 0d                	push   $0xd
f0100144:	8d 9d f6 fe ff ff    	lea    -0x10a(%ebp),%ebx
f010014a:	53                   	push   %ebx
f010014b:	e8 ad 5a 00 00       	call   f0105bfd <memset>
	cprintf("%s%n", ntest, &chnum1); 
f0100150:	83 c4 0c             	add    $0xc,%esp
f0100153:	57                   	push   %edi
f0100154:	53                   	push   %ebx
f0100155:	68 33 69 10 f0       	push   $0xf0106933
f010015a:	e8 76 3b 00 00       	call   f0103cd5 <cprintf>
	cprintf("chnum1: %d\n", chnum1);
f010015f:	83 c4 08             	add    $0x8,%esp
f0100162:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
f0100166:	50                   	push   %eax
f0100167:	68 38 69 10 f0       	push   $0xf0106938
f010016c:	e8 64 3b 00 00       	call   f0103cd5 <cprintf>
	cprintf("show me the sign: %+d, %+d\n", 1024, -1024);
f0100171:	83 c4 0c             	add    $0xc,%esp
f0100174:	68 00 fc ff ff       	push   $0xfffffc00
f0100179:	68 00 04 00 00       	push   $0x400
f010017e:	68 44 69 10 f0       	push   $0xf0106944
f0100183:	e8 4d 3b 00 00       	call   f0103cd5 <cprintf>
	mem_init();
f0100188:	e8 e6 14 00 00       	call   f0101673 <mem_init>
	env_init();
f010018d:	e8 75 33 00 00       	call   f0103507 <env_init>
	trap_init();
f0100192:	e8 59 3c 00 00       	call   f0103df0 <trap_init>
	mp_init();
f0100197:	e8 6b 5d 00 00       	call   f0105f07 <mp_init>
	lapic_init();
f010019c:	e8 73 60 00 00       	call   f0106214 <lapic_init>
	pic_init();
f01001a1:	e8 46 3a 00 00       	call   f0103bec <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01001a6:	c7 04 24 c0 43 12 f0 	movl   $0xf01243c0,(%esp)
f01001ad:	e8 bc 62 00 00       	call   f010646e <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	83 3d 88 0e 25 f0 07 	cmpl   $0x7,0xf0250e88
f01001bc:	76 27                	jbe    f01001e5 <i386_init+0x149>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001be:	83 ec 04             	sub    $0x4,%esp
f01001c1:	b8 6a 5e 10 f0       	mov    $0xf0105e6a,%eax
f01001c6:	2d f0 5d 10 f0       	sub    $0xf0105df0,%eax
f01001cb:	50                   	push   %eax
f01001cc:	68 f0 5d 10 f0       	push   $0xf0105df0
f01001d1:	68 00 70 00 f0       	push   $0xf0007000
f01001d6:	e8 6a 5a 00 00       	call   f0105c45 <memmove>
f01001db:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f01001de:	bb 20 10 25 f0       	mov    $0xf0251020,%ebx
f01001e3:	eb 19                	jmp    f01001fe <i386_init+0x162>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001e5:	68 00 70 00 00       	push   $0x7000
f01001ea:	68 d4 68 10 f0       	push   $0xf01068d4
f01001ef:	6a 5e                	push   $0x5e
f01001f1:	68 60 69 10 f0       	push   $0xf0106960
f01001f6:	e8 45 fe ff ff       	call   f0100040 <_panic>
f01001fb:	83 c3 74             	add    $0x74,%ebx
f01001fe:	6b 05 c4 13 25 f0 74 	imul   $0x74,0xf02513c4,%eax
f0100205:	05 20 10 25 f0       	add    $0xf0251020,%eax
f010020a:	39 c3                	cmp    %eax,%ebx
f010020c:	73 4d                	jae    f010025b <i386_init+0x1bf>
		if (c == cpus + cpunum())  // We've started already.
f010020e:	e8 eb 5f 00 00       	call   f01061fe <cpunum>
f0100213:	6b c0 74             	imul   $0x74,%eax,%eax
f0100216:	05 20 10 25 f0       	add    $0xf0251020,%eax
f010021b:	39 c3                	cmp    %eax,%ebx
f010021d:	74 dc                	je     f01001fb <i386_init+0x15f>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010021f:	89 d8                	mov    %ebx,%eax
f0100221:	2d 20 10 25 f0       	sub    $0xf0251020,%eax
f0100226:	c1 f8 02             	sar    $0x2,%eax
f0100229:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010022f:	c1 e0 0f             	shl    $0xf,%eax
f0100232:	8d 80 00 a0 25 f0    	lea    -0xfda6000(%eax),%eax
f0100238:	a3 84 0e 25 f0       	mov    %eax,0xf0250e84
		lapic_startap(c->cpu_id, PADDR(code));
f010023d:	83 ec 08             	sub    $0x8,%esp
f0100240:	68 00 70 00 00       	push   $0x7000
f0100245:	0f b6 03             	movzbl (%ebx),%eax
f0100248:	50                   	push   %eax
f0100249:	e8 18 61 00 00       	call   f0106366 <lapic_startap>
f010024e:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f0100251:	8b 43 04             	mov    0x4(%ebx),%eax
f0100254:	83 f8 01             	cmp    $0x1,%eax
f0100257:	75 f8                	jne    f0100251 <i386_init+0x1b5>
f0100259:	eb a0                	jmp    f01001fb <i386_init+0x15f>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010025b:	83 ec 08             	sub    $0x8,%esp
f010025e:	6a 00                	push   $0x0
f0100260:	68 14 7a 1e f0       	push   $0xf01e7a14
f0100265:	e8 7c 34 00 00       	call   f01036e6 <env_create>
	sched_yield();
f010026a:	e8 93 45 00 00       	call   f0104802 <sched_yield>

f010026f <mp_main>:
{
f010026f:	55                   	push   %ebp
f0100270:	89 e5                	mov    %esp,%ebp
f0100272:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f0100275:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010027a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010027f:	76 52                	jbe    f01002d3 <mp_main+0x64>
	return (physaddr_t)kva - KERNBASE;
f0100281:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100286:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100289:	e8 70 5f 00 00       	call   f01061fe <cpunum>
f010028e:	83 ec 08             	sub    $0x8,%esp
f0100291:	50                   	push   %eax
f0100292:	68 6c 69 10 f0       	push   $0xf010696c
f0100297:	e8 39 3a 00 00       	call   f0103cd5 <cprintf>
	lapic_init();
f010029c:	e8 73 5f 00 00       	call   f0106214 <lapic_init>
	env_init_percpu();
f01002a1:	e8 35 32 00 00       	call   f01034db <env_init_percpu>
	trap_init_percpu();
f01002a6:	e8 3e 3a 00 00       	call   f0103ce9 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01002ab:	e8 4e 5f 00 00       	call   f01061fe <cpunum>
f01002b0:	6b d0 74             	imul   $0x74,%eax,%edx
f01002b3:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01002b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01002bb:	f0 87 82 20 10 25 f0 	lock xchg %eax,-0xfdaefe0(%edx)
f01002c2:	c7 04 24 c0 43 12 f0 	movl   $0xf01243c0,(%esp)
f01002c9:	e8 a0 61 00 00       	call   f010646e <spin_lock>
	sched_yield();
f01002ce:	e8 2f 45 00 00       	call   f0104802 <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01002d3:	50                   	push   %eax
f01002d4:	68 f8 68 10 f0       	push   $0xf01068f8
f01002d9:	6a 75                	push   $0x75
f01002db:	68 60 69 10 f0       	push   $0xf0106960
f01002e0:	e8 5b fd ff ff       	call   f0100040 <_panic>

f01002e5 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01002e5:	55                   	push   %ebp
f01002e6:	89 e5                	mov    %esp,%ebp
f01002e8:	53                   	push   %ebx
f01002e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01002ec:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01002ef:	ff 75 0c             	pushl  0xc(%ebp)
f01002f2:	ff 75 08             	pushl  0x8(%ebp)
f01002f5:	68 82 69 10 f0       	push   $0xf0106982
f01002fa:	e8 d6 39 00 00       	call   f0103cd5 <cprintf>
	vcprintf(fmt, ap);
f01002ff:	83 c4 08             	add    $0x8,%esp
f0100302:	53                   	push   %ebx
f0100303:	ff 75 10             	pushl  0x10(%ebp)
f0100306:	e8 a4 39 00 00       	call   f0103caf <vcprintf>
	cprintf("\n");
f010030b:	c7 04 24 68 7d 10 f0 	movl   $0xf0107d68,(%esp)
f0100312:	e8 be 39 00 00       	call   f0103cd5 <cprintf>
	va_end(ap);
}
f0100317:	83 c4 10             	add    $0x10,%esp
f010031a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010031d:	c9                   	leave  
f010031e:	c3                   	ret    

f010031f <serial_proc_data>:
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010031f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100324:	ec                   	in     (%dx),%al
static bool serial_exists;

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100325:	a8 01                	test   $0x1,%al
f0100327:	74 0a                	je     f0100333 <serial_proc_data+0x14>
f0100329:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010032e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010032f:	0f b6 c0             	movzbl %al,%eax
f0100332:	c3                   	ret    
		return -1;
f0100333:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100338:	c3                   	ret    

f0100339 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100339:	55                   	push   %ebp
f010033a:	89 e5                	mov    %esp,%ebp
f010033c:	53                   	push   %ebx
f010033d:	83 ec 04             	sub    $0x4,%esp
f0100340:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100342:	ff d3                	call   *%ebx
f0100344:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100347:	74 29                	je     f0100372 <cons_intr+0x39>
		if (c == 0)
f0100349:	85 c0                	test   %eax,%eax
f010034b:	74 f5                	je     f0100342 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f010034d:	8b 0d 24 02 25 f0    	mov    0xf0250224,%ecx
f0100353:	8d 51 01             	lea    0x1(%ecx),%edx
f0100356:	88 81 20 00 25 f0    	mov    %al,-0xfdaffe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010035c:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100362:	b8 00 00 00 00       	mov    $0x0,%eax
f0100367:	0f 44 d0             	cmove  %eax,%edx
f010036a:	89 15 24 02 25 f0    	mov    %edx,0xf0250224
f0100370:	eb d0                	jmp    f0100342 <cons_intr+0x9>
	}
}
f0100372:	83 c4 04             	add    $0x4,%esp
f0100375:	5b                   	pop    %ebx
f0100376:	5d                   	pop    %ebp
f0100377:	c3                   	ret    

f0100378 <kbd_proc_data>:
{
f0100378:	55                   	push   %ebp
f0100379:	89 e5                	mov    %esp,%ebp
f010037b:	53                   	push   %ebx
f010037c:	83 ec 04             	sub    $0x4,%esp
f010037f:	ba 64 00 00 00       	mov    $0x64,%edx
f0100384:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100385:	a8 01                	test   $0x1,%al
f0100387:	0f 84 f2 00 00 00    	je     f010047f <kbd_proc_data+0x107>
	if (stat & KBS_TERR)
f010038d:	a8 20                	test   $0x20,%al
f010038f:	0f 85 f1 00 00 00    	jne    f0100486 <kbd_proc_data+0x10e>
f0100395:	ba 60 00 00 00       	mov    $0x60,%edx
f010039a:	ec                   	in     (%dx),%al
f010039b:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010039d:	3c e0                	cmp    $0xe0,%al
f010039f:	74 61                	je     f0100402 <kbd_proc_data+0x8a>
	} else if (data & 0x80) {
f01003a1:	84 c0                	test   %al,%al
f01003a3:	78 70                	js     f0100415 <kbd_proc_data+0x9d>
	} else if (shift & E0ESC) {
f01003a5:	8b 0d 00 00 25 f0    	mov    0xf0250000,%ecx
f01003ab:	f6 c1 40             	test   $0x40,%cl
f01003ae:	74 0e                	je     f01003be <kbd_proc_data+0x46>
		data |= 0x80;
f01003b0:	83 c8 80             	or     $0xffffff80,%eax
f01003b3:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01003b5:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003b8:	89 0d 00 00 25 f0    	mov    %ecx,0xf0250000
	shift |= shiftcode[data];
f01003be:	0f b6 d2             	movzbl %dl,%edx
f01003c1:	0f b6 82 00 6b 10 f0 	movzbl -0xfef9500(%edx),%eax
f01003c8:	0b 05 00 00 25 f0    	or     0xf0250000,%eax
	shift ^= togglecode[data];
f01003ce:	0f b6 8a 00 6a 10 f0 	movzbl -0xfef9600(%edx),%ecx
f01003d5:	31 c8                	xor    %ecx,%eax
f01003d7:	a3 00 00 25 f0       	mov    %eax,0xf0250000
	c = charcode[shift & (CTL | SHIFT)][data];
f01003dc:	89 c1                	mov    %eax,%ecx
f01003de:	83 e1 03             	and    $0x3,%ecx
f01003e1:	8b 0c 8d e0 69 10 f0 	mov    -0xfef9620(,%ecx,4),%ecx
f01003e8:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003ec:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003ef:	a8 08                	test   $0x8,%al
f01003f1:	74 61                	je     f0100454 <kbd_proc_data+0xdc>
		if ('a' <= c && c <= 'z')
f01003f3:	89 da                	mov    %ebx,%edx
f01003f5:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003f8:	83 f9 19             	cmp    $0x19,%ecx
f01003fb:	77 4b                	ja     f0100448 <kbd_proc_data+0xd0>
			c += 'A' - 'a';
f01003fd:	83 eb 20             	sub    $0x20,%ebx
f0100400:	eb 0c                	jmp    f010040e <kbd_proc_data+0x96>
		shift |= E0ESC;
f0100402:	83 0d 00 00 25 f0 40 	orl    $0x40,0xf0250000
		return 0;
f0100409:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010040e:	89 d8                	mov    %ebx,%eax
f0100410:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100413:	c9                   	leave  
f0100414:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100415:	8b 0d 00 00 25 f0    	mov    0xf0250000,%ecx
f010041b:	89 cb                	mov    %ecx,%ebx
f010041d:	83 e3 40             	and    $0x40,%ebx
f0100420:	83 e0 7f             	and    $0x7f,%eax
f0100423:	85 db                	test   %ebx,%ebx
f0100425:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100428:	0f b6 d2             	movzbl %dl,%edx
f010042b:	0f b6 82 00 6b 10 f0 	movzbl -0xfef9500(%edx),%eax
f0100432:	83 c8 40             	or     $0x40,%eax
f0100435:	0f b6 c0             	movzbl %al,%eax
f0100438:	f7 d0                	not    %eax
f010043a:	21 c8                	and    %ecx,%eax
f010043c:	a3 00 00 25 f0       	mov    %eax,0xf0250000
		return 0;
f0100441:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100446:	eb c6                	jmp    f010040e <kbd_proc_data+0x96>
		else if ('A' <= c && c <= 'Z')
f0100448:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010044b:	8d 4b 20             	lea    0x20(%ebx),%ecx
f010044e:	83 fa 1a             	cmp    $0x1a,%edx
f0100451:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100454:	f7 d0                	not    %eax
f0100456:	a8 06                	test   $0x6,%al
f0100458:	75 b4                	jne    f010040e <kbd_proc_data+0x96>
f010045a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100460:	75 ac                	jne    f010040e <kbd_proc_data+0x96>
		cprintf("Rebooting!\n");
f0100462:	83 ec 0c             	sub    $0xc,%esp
f0100465:	68 9c 69 10 f0       	push   $0xf010699c
f010046a:	e8 66 38 00 00       	call   f0103cd5 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010046f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100474:	ba 92 00 00 00       	mov    $0x92,%edx
f0100479:	ee                   	out    %al,(%dx)
f010047a:	83 c4 10             	add    $0x10,%esp
f010047d:	eb 8f                	jmp    f010040e <kbd_proc_data+0x96>
		return -1;
f010047f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f0100484:	eb 88                	jmp    f010040e <kbd_proc_data+0x96>
		return -1;
f0100486:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010048b:	eb 81                	jmp    f010040e <kbd_proc_data+0x96>

f010048d <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010048d:	55                   	push   %ebp
f010048e:	89 e5                	mov    %esp,%ebp
f0100490:	57                   	push   %edi
f0100491:	56                   	push   %esi
f0100492:	53                   	push   %ebx
f0100493:	83 ec 1c             	sub    $0x1c,%esp
f0100496:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f0100498:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010049d:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01004a2:	bb 84 00 00 00       	mov    $0x84,%ebx
f01004a7:	89 fa                	mov    %edi,%edx
f01004a9:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01004aa:	a8 20                	test   $0x20,%al
f01004ac:	75 13                	jne    f01004c1 <cons_putc+0x34>
f01004ae:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01004b4:	7f 0b                	jg     f01004c1 <cons_putc+0x34>
f01004b6:	89 da                	mov    %ebx,%edx
f01004b8:	ec                   	in     (%dx),%al
f01004b9:	ec                   	in     (%dx),%al
f01004ba:	ec                   	in     (%dx),%al
f01004bb:	ec                   	in     (%dx),%al
	     i++)
f01004bc:	83 c6 01             	add    $0x1,%esi
f01004bf:	eb e6                	jmp    f01004a7 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f01004c1:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004c4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01004c9:	89 c8                	mov    %ecx,%eax
f01004cb:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01004cc:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004d1:	bf 79 03 00 00       	mov    $0x379,%edi
f01004d6:	bb 84 00 00 00       	mov    $0x84,%ebx
f01004db:	89 fa                	mov    %edi,%edx
f01004dd:	ec                   	in     (%dx),%al
f01004de:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01004e4:	7f 0f                	jg     f01004f5 <cons_putc+0x68>
f01004e6:	84 c0                	test   %al,%al
f01004e8:	78 0b                	js     f01004f5 <cons_putc+0x68>
f01004ea:	89 da                	mov    %ebx,%edx
f01004ec:	ec                   	in     (%dx),%al
f01004ed:	ec                   	in     (%dx),%al
f01004ee:	ec                   	in     (%dx),%al
f01004ef:	ec                   	in     (%dx),%al
f01004f0:	83 c6 01             	add    $0x1,%esi
f01004f3:	eb e6                	jmp    f01004db <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004f5:	ba 78 03 00 00       	mov    $0x378,%edx
f01004fa:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01004fe:	ee                   	out    %al,(%dx)
f01004ff:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100504:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100509:	ee                   	out    %al,(%dx)
f010050a:	b8 08 00 00 00       	mov    $0x8,%eax
f010050f:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100510:	89 ca                	mov    %ecx,%edx
f0100512:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100518:	89 c8                	mov    %ecx,%eax
f010051a:	80 cc 07             	or     $0x7,%ah
f010051d:	85 d2                	test   %edx,%edx
f010051f:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f0100522:	0f b6 c1             	movzbl %cl,%eax
f0100525:	83 f8 09             	cmp    $0x9,%eax
f0100528:	0f 84 b0 00 00 00    	je     f01005de <cons_putc+0x151>
f010052e:	7e 73                	jle    f01005a3 <cons_putc+0x116>
f0100530:	83 f8 0a             	cmp    $0xa,%eax
f0100533:	0f 84 98 00 00 00    	je     f01005d1 <cons_putc+0x144>
f0100539:	83 f8 0d             	cmp    $0xd,%eax
f010053c:	0f 85 d3 00 00 00    	jne    f0100615 <cons_putc+0x188>
		crt_pos -= (crt_pos % CRT_COLS);
f0100542:	0f b7 05 28 02 25 f0 	movzwl 0xf0250228,%eax
f0100549:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010054f:	c1 e8 16             	shr    $0x16,%eax
f0100552:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100555:	c1 e0 04             	shl    $0x4,%eax
f0100558:	66 a3 28 02 25 f0    	mov    %ax,0xf0250228
	if (crt_pos >= CRT_SIZE) {
f010055e:	66 81 3d 28 02 25 f0 	cmpw   $0x7cf,0xf0250228
f0100565:	cf 07 
f0100567:	0f 87 cb 00 00 00    	ja     f0100638 <cons_putc+0x1ab>
	outb(addr_6845, 14);
f010056d:	8b 0d 30 02 25 f0    	mov    0xf0250230,%ecx
f0100573:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100578:	89 ca                	mov    %ecx,%edx
f010057a:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010057b:	0f b7 1d 28 02 25 f0 	movzwl 0xf0250228,%ebx
f0100582:	8d 71 01             	lea    0x1(%ecx),%esi
f0100585:	89 d8                	mov    %ebx,%eax
f0100587:	66 c1 e8 08          	shr    $0x8,%ax
f010058b:	89 f2                	mov    %esi,%edx
f010058d:	ee                   	out    %al,(%dx)
f010058e:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100593:	89 ca                	mov    %ecx,%edx
f0100595:	ee                   	out    %al,(%dx)
f0100596:	89 d8                	mov    %ebx,%eax
f0100598:	89 f2                	mov    %esi,%edx
f010059a:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010059b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010059e:	5b                   	pop    %ebx
f010059f:	5e                   	pop    %esi
f01005a0:	5f                   	pop    %edi
f01005a1:	5d                   	pop    %ebp
f01005a2:	c3                   	ret    
f01005a3:	83 f8 08             	cmp    $0x8,%eax
f01005a6:	75 6d                	jne    f0100615 <cons_putc+0x188>
		if (crt_pos > 0) {
f01005a8:	0f b7 05 28 02 25 f0 	movzwl 0xf0250228,%eax
f01005af:	66 85 c0             	test   %ax,%ax
f01005b2:	74 b9                	je     f010056d <cons_putc+0xe0>
			crt_pos--;
f01005b4:	83 e8 01             	sub    $0x1,%eax
f01005b7:	66 a3 28 02 25 f0    	mov    %ax,0xf0250228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01005bd:	0f b7 c0             	movzwl %ax,%eax
f01005c0:	b1 00                	mov    $0x0,%cl
f01005c2:	83 c9 20             	or     $0x20,%ecx
f01005c5:	8b 15 2c 02 25 f0    	mov    0xf025022c,%edx
f01005cb:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f01005cf:	eb 8d                	jmp    f010055e <cons_putc+0xd1>
		crt_pos += CRT_COLS;
f01005d1:	66 83 05 28 02 25 f0 	addw   $0x50,0xf0250228
f01005d8:	50 
f01005d9:	e9 64 ff ff ff       	jmp    f0100542 <cons_putc+0xb5>
		cons_putc(' ');
f01005de:	b8 20 00 00 00       	mov    $0x20,%eax
f01005e3:	e8 a5 fe ff ff       	call   f010048d <cons_putc>
		cons_putc(' ');
f01005e8:	b8 20 00 00 00       	mov    $0x20,%eax
f01005ed:	e8 9b fe ff ff       	call   f010048d <cons_putc>
		cons_putc(' ');
f01005f2:	b8 20 00 00 00       	mov    $0x20,%eax
f01005f7:	e8 91 fe ff ff       	call   f010048d <cons_putc>
		cons_putc(' ');
f01005fc:	b8 20 00 00 00       	mov    $0x20,%eax
f0100601:	e8 87 fe ff ff       	call   f010048d <cons_putc>
		cons_putc(' ');
f0100606:	b8 20 00 00 00       	mov    $0x20,%eax
f010060b:	e8 7d fe ff ff       	call   f010048d <cons_putc>
f0100610:	e9 49 ff ff ff       	jmp    f010055e <cons_putc+0xd1>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100615:	0f b7 05 28 02 25 f0 	movzwl 0xf0250228,%eax
f010061c:	8d 50 01             	lea    0x1(%eax),%edx
f010061f:	66 89 15 28 02 25 f0 	mov    %dx,0xf0250228
f0100626:	0f b7 c0             	movzwl %ax,%eax
f0100629:	8b 15 2c 02 25 f0    	mov    0xf025022c,%edx
f010062f:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
f0100633:	e9 26 ff ff ff       	jmp    f010055e <cons_putc+0xd1>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100638:	a1 2c 02 25 f0       	mov    0xf025022c,%eax
f010063d:	83 ec 04             	sub    $0x4,%esp
f0100640:	68 00 0f 00 00       	push   $0xf00
f0100645:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010064b:	52                   	push   %edx
f010064c:	50                   	push   %eax
f010064d:	e8 f3 55 00 00       	call   f0105c45 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100652:	8b 15 2c 02 25 f0    	mov    0xf025022c,%edx
f0100658:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010065e:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100664:	83 c4 10             	add    $0x10,%esp
f0100667:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010066c:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010066f:	39 d0                	cmp    %edx,%eax
f0100671:	75 f4                	jne    f0100667 <cons_putc+0x1da>
		crt_pos -= CRT_COLS;
f0100673:	66 83 2d 28 02 25 f0 	subw   $0x50,0xf0250228
f010067a:	50 
f010067b:	e9 ed fe ff ff       	jmp    f010056d <cons_putc+0xe0>

f0100680 <serial_intr>:
	if (serial_exists)
f0100680:	80 3d 34 02 25 f0 00 	cmpb   $0x0,0xf0250234
f0100687:	75 01                	jne    f010068a <serial_intr+0xa>
f0100689:	c3                   	ret    
{
f010068a:	55                   	push   %ebp
f010068b:	89 e5                	mov    %esp,%ebp
f010068d:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100690:	b8 1f 03 10 f0       	mov    $0xf010031f,%eax
f0100695:	e8 9f fc ff ff       	call   f0100339 <cons_intr>
}
f010069a:	c9                   	leave  
f010069b:	c3                   	ret    

f010069c <kbd_intr>:
{
f010069c:	55                   	push   %ebp
f010069d:	89 e5                	mov    %esp,%ebp
f010069f:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01006a2:	b8 78 03 10 f0       	mov    $0xf0100378,%eax
f01006a7:	e8 8d fc ff ff       	call   f0100339 <cons_intr>
}
f01006ac:	c9                   	leave  
f01006ad:	c3                   	ret    

f01006ae <cons_getc>:
{
f01006ae:	55                   	push   %ebp
f01006af:	89 e5                	mov    %esp,%ebp
f01006b1:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01006b4:	e8 c7 ff ff ff       	call   f0100680 <serial_intr>
	kbd_intr();
f01006b9:	e8 de ff ff ff       	call   f010069c <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01006be:	8b 15 20 02 25 f0    	mov    0xf0250220,%edx
	return 0;
f01006c4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01006c9:	3b 15 24 02 25 f0    	cmp    0xf0250224,%edx
f01006cf:	74 1e                	je     f01006ef <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01006d1:	8d 4a 01             	lea    0x1(%edx),%ecx
f01006d4:	0f b6 82 20 00 25 f0 	movzbl -0xfdaffe0(%edx),%eax
			cons.rpos = 0;
f01006db:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01006e1:	ba 00 00 00 00       	mov    $0x0,%edx
f01006e6:	0f 44 ca             	cmove  %edx,%ecx
f01006e9:	89 0d 20 02 25 f0    	mov    %ecx,0xf0250220
}
f01006ef:	c9                   	leave  
f01006f0:	c3                   	ret    

f01006f1 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01006f1:	55                   	push   %ebp
f01006f2:	89 e5                	mov    %esp,%ebp
f01006f4:	57                   	push   %edi
f01006f5:	56                   	push   %esi
f01006f6:	53                   	push   %ebx
f01006f7:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f01006fa:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100701:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100708:	5a a5 
	if (*cp != 0xA55A) {
f010070a:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100711:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100715:	0f 84 d4 00 00 00    	je     f01007ef <cons_init+0xfe>
		addr_6845 = MONO_BASE;
f010071b:	c7 05 30 02 25 f0 b4 	movl   $0x3b4,0xf0250230
f0100722:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100725:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f010072a:	8b 3d 30 02 25 f0    	mov    0xf0250230,%edi
f0100730:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100735:	89 fa                	mov    %edi,%edx
f0100737:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100738:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010073b:	89 ca                	mov    %ecx,%edx
f010073d:	ec                   	in     (%dx),%al
f010073e:	0f b6 c0             	movzbl %al,%eax
f0100741:	c1 e0 08             	shl    $0x8,%eax
f0100744:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100746:	b8 0f 00 00 00       	mov    $0xf,%eax
f010074b:	89 fa                	mov    %edi,%edx
f010074d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010074e:	89 ca                	mov    %ecx,%edx
f0100750:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100751:	89 35 2c 02 25 f0    	mov    %esi,0xf025022c
	pos |= inb(addr_6845 + 1);
f0100757:	0f b6 c0             	movzbl %al,%eax
f010075a:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f010075c:	66 a3 28 02 25 f0    	mov    %ax,0xf0250228
	kbd_intr();
f0100762:	e8 35 ff ff ff       	call   f010069c <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f0100767:	83 ec 0c             	sub    $0xc,%esp
f010076a:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
f0100771:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100776:	50                   	push   %eax
f0100777:	e8 f2 33 00 00       	call   f0103b6e <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010077c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100781:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f0100786:	89 d8                	mov    %ebx,%eax
f0100788:	89 ca                	mov    %ecx,%edx
f010078a:	ee                   	out    %al,(%dx)
f010078b:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100790:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100795:	89 fa                	mov    %edi,%edx
f0100797:	ee                   	out    %al,(%dx)
f0100798:	b8 0c 00 00 00       	mov    $0xc,%eax
f010079d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01007a2:	ee                   	out    %al,(%dx)
f01007a3:	be f9 03 00 00       	mov    $0x3f9,%esi
f01007a8:	89 d8                	mov    %ebx,%eax
f01007aa:	89 f2                	mov    %esi,%edx
f01007ac:	ee                   	out    %al,(%dx)
f01007ad:	b8 03 00 00 00       	mov    $0x3,%eax
f01007b2:	89 fa                	mov    %edi,%edx
f01007b4:	ee                   	out    %al,(%dx)
f01007b5:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01007ba:	89 d8                	mov    %ebx,%eax
f01007bc:	ee                   	out    %al,(%dx)
f01007bd:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c2:	89 f2                	mov    %esi,%edx
f01007c4:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007c5:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01007ca:	ec                   	in     (%dx),%al
f01007cb:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01007cd:	83 c4 10             	add    $0x10,%esp
f01007d0:	3c ff                	cmp    $0xff,%al
f01007d2:	0f 95 05 34 02 25 f0 	setne  0xf0250234
f01007d9:	89 ca                	mov    %ecx,%edx
f01007db:	ec                   	in     (%dx),%al
f01007dc:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01007e1:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007e2:	80 fb ff             	cmp    $0xff,%bl
f01007e5:	74 23                	je     f010080a <cons_init+0x119>
		cprintf("Serial port does not exist!\n");
}
f01007e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007ea:	5b                   	pop    %ebx
f01007eb:	5e                   	pop    %esi
f01007ec:	5f                   	pop    %edi
f01007ed:	5d                   	pop    %ebp
f01007ee:	c3                   	ret    
		*cp = was;
f01007ef:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01007f6:	c7 05 30 02 25 f0 d4 	movl   $0x3d4,0xf0250230
f01007fd:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100800:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100805:	e9 20 ff ff ff       	jmp    f010072a <cons_init+0x39>
		cprintf("Serial port does not exist!\n");
f010080a:	83 ec 0c             	sub    $0xc,%esp
f010080d:	68 a8 69 10 f0       	push   $0xf01069a8
f0100812:	e8 be 34 00 00       	call   f0103cd5 <cprintf>
f0100817:	83 c4 10             	add    $0x10,%esp
}
f010081a:	eb cb                	jmp    f01007e7 <cons_init+0xf6>

f010081c <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010081c:	55                   	push   %ebp
f010081d:	89 e5                	mov    %esp,%ebp
f010081f:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100822:	8b 45 08             	mov    0x8(%ebp),%eax
f0100825:	e8 63 fc ff ff       	call   f010048d <cons_putc>
}
f010082a:	c9                   	leave  
f010082b:	c3                   	ret    

f010082c <getchar>:

int
getchar(void)
{
f010082c:	55                   	push   %ebp
f010082d:	89 e5                	mov    %esp,%ebp
f010082f:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100832:	e8 77 fe ff ff       	call   f01006ae <cons_getc>
f0100837:	85 c0                	test   %eax,%eax
f0100839:	74 f7                	je     f0100832 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010083b:	c9                   	leave  
f010083c:	c3                   	ret    

f010083d <iscons>:
int
iscons(int fdnum)
{
	// used by readline
	return 1;
}
f010083d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100842:	c3                   	ret    

f0100843 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100843:	55                   	push   %ebp
f0100844:	89 e5                	mov    %esp,%ebp
f0100846:	56                   	push   %esi
f0100847:	53                   	push   %ebx
f0100848:	bb 80 70 10 f0       	mov    $0xf0107080,%ebx
f010084d:	be c8 70 10 f0       	mov    $0xf01070c8,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100852:	83 ec 04             	sub    $0x4,%esp
f0100855:	ff 73 04             	pushl  0x4(%ebx)
f0100858:	ff 33                	pushl  (%ebx)
f010085a:	68 00 6c 10 f0       	push   $0xf0106c00
f010085f:	e8 71 34 00 00       	call   f0103cd5 <cprintf>
f0100864:	83 c3 0c             	add    $0xc,%ebx
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100867:	83 c4 10             	add    $0x10,%esp
f010086a:	39 f3                	cmp    %esi,%ebx
f010086c:	75 e4                	jne    f0100852 <mon_help+0xf>
	return 0;
}
f010086e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100873:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100876:	5b                   	pop    %ebx
f0100877:	5e                   	pop    %esi
f0100878:	5d                   	pop    %ebp
f0100879:	c3                   	ret    

f010087a <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010087a:	55                   	push   %ebp
f010087b:	89 e5                	mov    %esp,%ebp
f010087d:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100880:	68 09 6c 10 f0       	push   $0xf0106c09
f0100885:	e8 4b 34 00 00       	call   f0103cd5 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010088a:	83 c4 08             	add    $0x8,%esp
f010088d:	68 0c 00 10 00       	push   $0x10000c
f0100892:	68 70 6d 10 f0       	push   $0xf0106d70
f0100897:	e8 39 34 00 00       	call   f0103cd5 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010089c:	83 c4 0c             	add    $0xc,%esp
f010089f:	68 0c 00 10 00       	push   $0x10000c
f01008a4:	68 0c 00 10 f0       	push   $0xf010000c
f01008a9:	68 98 6d 10 f0       	push   $0xf0106d98
f01008ae:	e8 22 34 00 00       	call   f0103cd5 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01008b3:	83 c4 0c             	add    $0xc,%esp
f01008b6:	68 4f 68 10 00       	push   $0x10684f
f01008bb:	68 4f 68 10 f0       	push   $0xf010684f
f01008c0:	68 bc 6d 10 f0       	push   $0xf0106dbc
f01008c5:	e8 0b 34 00 00       	call   f0103cd5 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01008ca:	83 c4 0c             	add    $0xc,%esp
f01008cd:	68 00 00 25 00       	push   $0x250000
f01008d2:	68 00 00 25 f0       	push   $0xf0250000
f01008d7:	68 e0 6d 10 f0       	push   $0xf0106de0
f01008dc:	e8 f4 33 00 00       	call   f0103cd5 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01008e1:	83 c4 0c             	add    $0xc,%esp
f01008e4:	68 08 20 29 00       	push   $0x292008
f01008e9:	68 08 20 29 f0       	push   $0xf0292008
f01008ee:	68 04 6e 10 f0       	push   $0xf0106e04
f01008f3:	e8 dd 33 00 00       	call   f0103cd5 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01008f8:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01008fb:	b8 08 20 29 f0       	mov    $0xf0292008,%eax
f0100900:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100905:	c1 f8 0a             	sar    $0xa,%eax
f0100908:	50                   	push   %eax
f0100909:	68 28 6e 10 f0       	push   $0xf0106e28
f010090e:	e8 c2 33 00 00       	call   f0103cd5 <cprintf>
	return 0;
}
f0100913:	b8 00 00 00 00       	mov    $0x0,%eax
f0100918:	c9                   	leave  
f0100919:	c3                   	ret    

f010091a <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f010091a:	55                   	push   %ebp
f010091b:	89 e5                	mov    %esp,%ebp
f010091d:	83 ec 14             	sub    $0x14,%esp
    cprintf("Overflow success\n");
f0100920:	68 22 6c 10 f0       	push   $0xf0106c22
f0100925:	e8 ab 33 00 00       	call   f0103cd5 <cprintf>
}
f010092a:	83 c4 10             	add    $0x10,%esp
f010092d:	c9                   	leave  
f010092e:	c3                   	ret    

f010092f <mon_time>:
	return 0;
}

int
mon_time(int argc, char **argv, struct Trapframe *tf)
{
f010092f:	55                   	push   %ebp
f0100930:	89 e5                	mov    %esp,%ebp
f0100932:	57                   	push   %edi
f0100933:	56                   	push   %esi
f0100934:	53                   	push   %ebx
f0100935:	83 ec 1c             	sub    $0x1c,%esp
f0100938:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010093b:	bb 00 00 00 00       	mov    $0x0,%ebx
	if (argc != 2) {
f0100940:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
f0100944:	74 1d                	je     f0100963 <mon_time+0x34>
		cprintf("Usage: time [command]\n");
f0100946:	83 ec 0c             	sub    $0xc,%esp
f0100949:	68 34 6c 10 f0       	push   $0xf0106c34
f010094e:	e8 82 33 00 00       	call   f0103cd5 <cprintf>
		return 0;
f0100953:	83 c4 10             	add    $0x10,%esp
f0100956:	e9 8b 00 00 00       	jmp    f01009e6 <mon_time+0xb7>
	}
	else if (argc == 1 && strcmp(argv[0], "time")) {
		return commands[3].func(argc - 1, argv + 1, tf);
	}

	for (int i = 0; i < ARRAY_SIZE(commands); i++) {
f010095b:	83 c3 01             	add    $0x1,%ebx
f010095e:	83 fb 06             	cmp    $0x6,%ebx
f0100961:	74 70                	je     f01009d3 <mon_time+0xa4>
		if (!strcmp(argv[1], commands[i].name) && strcmp(argv[1], "time")) {
f0100963:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100966:	8b 34 85 80 70 10 f0 	mov    -0xfef8f80(,%eax,4),%esi
f010096d:	83 ec 08             	sub    $0x8,%esp
f0100970:	56                   	push   %esi
f0100971:	ff 77 04             	pushl  0x4(%edi)
f0100974:	e8 e9 51 00 00       	call   f0105b62 <strcmp>
f0100979:	83 c4 10             	add    $0x10,%esp
f010097c:	85 c0                	test   %eax,%eax
f010097e:	75 db                	jne    f010095b <mon_time+0x2c>
f0100980:	83 ec 08             	sub    $0x8,%esp
f0100983:	68 4b 6c 10 f0       	push   $0xf0106c4b
f0100988:	ff 77 04             	pushl  0x4(%edi)
f010098b:	e8 d2 51 00 00       	call   f0105b62 <strcmp>
f0100990:	83 c4 10             	add    $0x10,%esp
f0100993:	85 c0                	test   %eax,%eax
f0100995:	74 c4                	je     f010095b <mon_time+0x2c>
			uint32_t lo, hi;
			uint64_t start = 0, end = 0;
			__asm __volatile("rdtsc":"=a"(lo),"=d"(hi));
f0100997:	0f 31                	rdtsc  
			start = (uint64_t)hi << 32 | lo;
f0100999:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010099c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
			commands[i].func(argc - 1, argv + 1, tf);
f010099f:	83 ec 04             	sub    $0x4,%esp
f01009a2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009a5:	ff 75 10             	pushl  0x10(%ebp)
f01009a8:	83 c7 04             	add    $0x4,%edi
f01009ab:	57                   	push   %edi
f01009ac:	6a 01                	push   $0x1
f01009ae:	ff 14 85 88 70 10 f0 	call   *-0xfef8f78(,%eax,4)
			__asm __volatile("rdtsc":"=a"(lo),"=d"(hi));
f01009b5:	0f 31                	rdtsc  
			end = (uint64_t)hi << 32 | lo;
f01009b7:	89 c1                	mov    %eax,%ecx
f01009b9:	89 d3                	mov    %edx,%ebx
			cprintf("%s cycles: %d\n", commands[i].name, end - start);
f01009bb:	2b 4d e0             	sub    -0x20(%ebp),%ecx
f01009be:	1b 5d e4             	sbb    -0x1c(%ebp),%ebx
f01009c1:	53                   	push   %ebx
f01009c2:	51                   	push   %ecx
f01009c3:	56                   	push   %esi
f01009c4:	68 50 6c 10 f0       	push   $0xf0106c50
f01009c9:	e8 07 33 00 00       	call   f0103cd5 <cprintf>
			return 0;
f01009ce:	83 c4 20             	add    $0x20,%esp
f01009d1:	eb 13                	jmp    f01009e6 <mon_time+0xb7>
		}
	}

	cprintf("Unknown command:'%s'\n", argv[1]);
f01009d3:	83 ec 08             	sub    $0x8,%esp
f01009d6:	ff 77 04             	pushl  0x4(%edi)
f01009d9:	68 5f 6c 10 f0       	push   $0xf0106c5f
f01009de:	e8 f2 32 00 00       	call   f0103cd5 <cprintf>
	return 0;
f01009e3:	83 c4 10             	add    $0x10,%esp
}
f01009e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01009eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009ee:	5b                   	pop    %ebx
f01009ef:	5e                   	pop    %esi
f01009f0:	5f                   	pop    %edi
f01009f1:	5d                   	pop    %ebp
f01009f2:	c3                   	ret    

f01009f3 <mon_showmappings>:

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f01009f3:	55                   	push   %ebp
f01009f4:	89 e5                	mov    %esp,%ebp
f01009f6:	56                   	push   %esi
f01009f7:	53                   	push   %ebx
f01009f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern pde_t *kern_pgdir;
	uintptr_t start, end;
	if (argc != 3) {
f01009fb:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f01009ff:	75 4a                	jne    f0100a4b <mon_showmappings+0x58>
		cprintf("usage: %s start end\n", argv[0]);
		return -1;
	}
	start = ROUNDDOWN(strtol(argv[1], NULL, 16), PGSIZE);
f0100a01:	83 ec 04             	sub    $0x4,%esp
f0100a04:	6a 10                	push   $0x10
f0100a06:	6a 00                	push   $0x0
f0100a08:	ff 76 04             	pushl  0x4(%esi)
f0100a0b:	e8 03 53 00 00       	call   f0105d13 <strtol>
f0100a10:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a15:	89 c3                	mov    %eax,%ebx
	end = ROUNDDOWN(strtol(argv[2], NULL, 16), PGSIZE);
f0100a17:	83 c4 0c             	add    $0xc,%esp
f0100a1a:	6a 10                	push   $0x10
f0100a1c:	6a 00                	push   $0x0
f0100a1e:	ff 76 08             	pushl  0x8(%esi)
f0100a21:	e8 ed 52 00 00       	call   f0105d13 <strtol>
f0100a26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a2b:	89 c6                	mov    %eax,%esi
	if (start > end) {
f0100a2d:	83 c4 10             	add    $0x10,%esp
f0100a30:	39 c3                	cmp    %eax,%ebx
f0100a32:	76 4b                	jbe    f0100a7f <mon_showmappings+0x8c>
		cprintf("start cannot be larger than end\n");
f0100a34:	83 ec 0c             	sub    $0xc,%esp
f0100a37:	68 54 6e 10 f0       	push   $0xf0106e54
f0100a3c:	e8 94 32 00 00       	call   f0103cd5 <cprintf>
		return -1;
f0100a41:	83 c4 10             	add    $0x10,%esp
f0100a44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100a49:	eb 7f                	jmp    f0100aca <mon_showmappings+0xd7>
		cprintf("usage: %s start end\n", argv[0]);
f0100a4b:	83 ec 08             	sub    $0x8,%esp
f0100a4e:	ff 36                	pushl  (%esi)
f0100a50:	68 75 6c 10 f0       	push   $0xf0106c75
f0100a55:	e8 7b 32 00 00       	call   f0103cd5 <cprintf>
		return -1;
f0100a5a:	83 c4 10             	add    $0x10,%esp
f0100a5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100a62:	eb 66                	jmp    f0100aca <mon_showmappings+0xd7>
	}
	for (uintptr_t i = start; i <= end; i += PGSIZE) {
		pte_t* pte = pgdir_walk(kern_pgdir, (void*)i, 0);
		if (!pte) cprintf("  0x%08x(virt)  not mapped(phys)\n", i);
f0100a64:	83 ec 08             	sub    $0x8,%esp
f0100a67:	53                   	push   %ebx
f0100a68:	68 78 6e 10 f0       	push   $0xf0106e78
f0100a6d:	e8 63 32 00 00       	call   f0103cd5 <cprintf>
f0100a72:	83 c4 10             	add    $0x10,%esp
	for (uintptr_t i = start; i <= end; i += PGSIZE) {
f0100a75:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100a7b:	39 de                	cmp    %ebx,%esi
f0100a7d:	72 46                	jb     f0100ac5 <mon_showmappings+0xd2>
		pte_t* pte = pgdir_walk(kern_pgdir, (void*)i, 0);
f0100a7f:	83 ec 04             	sub    $0x4,%esp
f0100a82:	6a 00                	push   $0x0
f0100a84:	53                   	push   %ebx
f0100a85:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0100a8b:	e8 2a 09 00 00       	call   f01013ba <pgdir_walk>
		if (!pte) cprintf("  0x%08x(virt)  not mapped(phys)\n", i);
f0100a90:	83 c4 10             	add    $0x10,%esp
f0100a93:	85 c0                	test   %eax,%eax
f0100a95:	74 cd                	je     f0100a64 <mon_showmappings+0x71>
		else cprintf("  0x%08x(virt)  0x%08x(phys) PTE_P  %x  PTE_W  %x  PTE_U  %x\n",
			i, *pte & (~0xfff), *pte & PTE_P, *pte & PTE_W, *pte & PTE_U);
f0100a97:	8b 10                	mov    (%eax),%edx
		else cprintf("  0x%08x(virt)  0x%08x(phys) PTE_P  %x  PTE_W  %x  PTE_U  %x\n",
f0100a99:	83 ec 08             	sub    $0x8,%esp
f0100a9c:	89 d0                	mov    %edx,%eax
f0100a9e:	83 e0 04             	and    $0x4,%eax
f0100aa1:	50                   	push   %eax
f0100aa2:	89 d0                	mov    %edx,%eax
f0100aa4:	83 e0 02             	and    $0x2,%eax
f0100aa7:	50                   	push   %eax
f0100aa8:	89 d0                	mov    %edx,%eax
f0100aaa:	83 e0 01             	and    $0x1,%eax
f0100aad:	50                   	push   %eax
f0100aae:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ab4:	52                   	push   %edx
f0100ab5:	53                   	push   %ebx
f0100ab6:	68 9c 6e 10 f0       	push   $0xf0106e9c
f0100abb:	e8 15 32 00 00       	call   f0103cd5 <cprintf>
f0100ac0:	83 c4 20             	add    $0x20,%esp
f0100ac3:	eb b0                	jmp    f0100a75 <mon_showmappings+0x82>
	}
	return 0;
f0100ac5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100aca:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100acd:	5b                   	pop    %ebx
f0100ace:	5e                   	pop    %esi
f0100acf:	5d                   	pop    %ebp
f0100ad0:	c3                   	ret    

f0100ad1 <mon_setpermisions>:

int
mon_setpermisions(int argc, char **argv, struct Trapframe *tf)
{
f0100ad1:	55                   	push   %ebp
f0100ad2:	89 e5                	mov    %esp,%ebp
f0100ad4:	56                   	push   %esi
f0100ad5:	53                   	push   %ebx
f0100ad6:	8b 75 0c             	mov    0xc(%ebp),%esi
	extern pde_t *kern_pgdir;
	uintptr_t addr, perm;
	if (argc != 3) {
f0100ad9:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100add:	0f 85 87 00 00 00    	jne    f0100b6a <mon_setpermisions+0x99>
		cprintf("usage: %s addr perm\n", argv[0]);
		return -1;
	}
	addr = ROUNDDOWN(strtol(argv[1], NULL, 16), PGSIZE);
f0100ae3:	83 ec 04             	sub    $0x4,%esp
f0100ae6:	6a 10                	push   $0x10
f0100ae8:	6a 00                	push   $0x0
f0100aea:	ff 76 04             	pushl  0x4(%esi)
f0100aed:	e8 21 52 00 00       	call   f0105d13 <strtol>
f0100af2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100af7:	89 c3                	mov    %eax,%ebx
	perm = strtol(argv[2], NULL, 16);
f0100af9:	83 c4 0c             	add    $0xc,%esp
f0100afc:	6a 10                	push   $0x10
f0100afe:	6a 00                	push   $0x0
f0100b00:	ff 76 08             	pushl  0x8(%esi)
f0100b03:	e8 0b 52 00 00       	call   f0105d13 <strtol>
f0100b08:	89 c6                	mov    %eax,%esi
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
f0100b0a:	83 c4 0c             	add    $0xc,%esp
f0100b0d:	6a 00                	push   $0x0
f0100b0f:	53                   	push   %ebx
f0100b10:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0100b16:	e8 9f 08 00 00       	call   f01013ba <pgdir_walk>
	if (!pte) cprintf("  0x%08x(virt)  not mapped(phys)\n", addr);
f0100b1b:	83 c4 10             	add    $0x10,%esp
f0100b1e:	85 c0                	test   %eax,%eax
f0100b20:	74 61                	je     f0100b83 <mon_setpermisions+0xb2>
	else {
		*pte = (*pte & (~0xfff)) | (perm & 0xfff);
f0100b22:	8b 10                	mov    (%eax),%edx
f0100b24:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b2a:	81 e6 ff 0f 00 00    	and    $0xfff,%esi
f0100b30:	09 f2                	or     %esi,%edx
f0100b32:	89 10                	mov    %edx,(%eax)
		cprintf("  0x%08x(virt)  0x%08x(phys) PTE_P  %x  PTE_W  %x  PTE_U  %x\n",
f0100b34:	83 ec 08             	sub    $0x8,%esp
f0100b37:	89 d0                	mov    %edx,%eax
f0100b39:	83 e0 04             	and    $0x4,%eax
f0100b3c:	50                   	push   %eax
f0100b3d:	89 d0                	mov    %edx,%eax
f0100b3f:	83 e0 02             	and    $0x2,%eax
f0100b42:	50                   	push   %eax
f0100b43:	89 d0                	mov    %edx,%eax
f0100b45:	83 e0 01             	and    $0x1,%eax
f0100b48:	50                   	push   %eax
f0100b49:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b4f:	52                   	push   %edx
f0100b50:	53                   	push   %ebx
f0100b51:	68 9c 6e 10 f0       	push   $0xf0106e9c
f0100b56:	e8 7a 31 00 00       	call   f0103cd5 <cprintf>
f0100b5b:	83 c4 20             	add    $0x20,%esp
			addr, *pte & (~0xfff), *pte & PTE_P, *pte & PTE_W, *pte & PTE_U);
	}
	return 0;
f0100b5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100b63:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100b66:	5b                   	pop    %ebx
f0100b67:	5e                   	pop    %esi
f0100b68:	5d                   	pop    %ebp
f0100b69:	c3                   	ret    
		cprintf("usage: %s addr perm\n", argv[0]);
f0100b6a:	83 ec 08             	sub    $0x8,%esp
f0100b6d:	ff 36                	pushl  (%esi)
f0100b6f:	68 8a 6c 10 f0       	push   $0xf0106c8a
f0100b74:	e8 5c 31 00 00       	call   f0103cd5 <cprintf>
		return -1;
f0100b79:	83 c4 10             	add    $0x10,%esp
f0100b7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100b81:	eb e0                	jmp    f0100b63 <mon_setpermisions+0x92>
	if (!pte) cprintf("  0x%08x(virt)  not mapped(phys)\n", addr);
f0100b83:	83 ec 08             	sub    $0x8,%esp
f0100b86:	53                   	push   %ebx
f0100b87:	68 78 6e 10 f0       	push   $0xf0106e78
f0100b8c:	e8 44 31 00 00       	call   f0103cd5 <cprintf>
f0100b91:	83 c4 10             	add    $0x10,%esp
	return 0;
f0100b94:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b99:	eb c8                	jmp    f0100b63 <mon_setpermisions+0x92>

f0100b9b <start_overflow>:
{
f0100b9b:	55                   	push   %ebp
f0100b9c:	89 e5                	mov    %esp,%ebp
f0100b9e:	57                   	push   %edi
f0100b9f:	56                   	push   %esi
f0100ba0:	53                   	push   %ebx
f0100ba1:	83 ec 0c             	sub    $0xc,%esp
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
f0100ba4:	8d 5d 04             	lea    0x4(%ebp),%ebx
f0100ba7:	89 de                	mov    %ebx,%esi
f0100ba9:	8d 7b 04             	lea    0x4(%ebx),%edi
    	cprintf("%*s%n\n", pret_addr[i] & 0xff, "", pret_addr + 4 + i);
f0100bac:	8d 43 04             	lea    0x4(%ebx),%eax
f0100baf:	50                   	push   %eax
f0100bb0:	68 69 7d 10 f0       	push   $0xf0107d69
f0100bb5:	0f b6 03             	movzbl (%ebx),%eax
f0100bb8:	50                   	push   %eax
f0100bb9:	68 9f 6c 10 f0       	push   $0xf0106c9f
f0100bbe:	e8 12 31 00 00       	call   f0103cd5 <cprintf>
f0100bc3:	83 c3 01             	add    $0x1,%ebx
    for (int i = 0; i < 4; i++) {
f0100bc6:	83 c4 10             	add    $0x10,%esp
f0100bc9:	39 fb                	cmp    %edi,%ebx
f0100bcb:	75 df                	jne    f0100bac <start_overflow+0x11>
    for (int i = 0; i < 4; i++) {
f0100bcd:	bb 00 00 00 00       	mov    $0x0,%ebx
    	cprintf("%*s%n\n", (overflow_ra >> (8 * i)) & 0xff, "", pret_addr + i);
f0100bd2:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0100bd5:	50                   	push   %eax
f0100bd6:	68 69 7d 10 f0       	push   $0xf0107d69
f0100bdb:	8d 0c dd 00 00 00 00 	lea    0x0(,%ebx,8),%ecx
f0100be2:	b8 1a 09 10 f0       	mov    $0xf010091a,%eax
f0100be7:	d3 e8                	shr    %cl,%eax
f0100be9:	0f b6 c0             	movzbl %al,%eax
f0100bec:	50                   	push   %eax
f0100bed:	68 9f 6c 10 f0       	push   $0xf0106c9f
f0100bf2:	e8 de 30 00 00       	call   f0103cd5 <cprintf>
    for (int i = 0; i < 4; i++) {
f0100bf7:	83 c3 01             	add    $0x1,%ebx
f0100bfa:	83 c4 10             	add    $0x10,%esp
f0100bfd:	83 fb 04             	cmp    $0x4,%ebx
f0100c00:	75 d0                	jne    f0100bd2 <start_overflow+0x37>
}
f0100c02:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c05:	5b                   	pop    %ebx
f0100c06:	5e                   	pop    %esi
f0100c07:	5f                   	pop    %edi
f0100c08:	5d                   	pop    %ebp
f0100c09:	c3                   	ret    

f0100c0a <mon_backtrace>:
{
f0100c0a:	55                   	push   %ebp
f0100c0b:	89 e5                	mov    %esp,%ebp
f0100c0d:	56                   	push   %esi
f0100c0e:	53                   	push   %ebx
f0100c0f:	83 ec 20             	sub    $0x20,%esp
        start_overflow();
f0100c12:	e8 84 ff ff ff       	call   f0100b9b <start_overflow>
    cprintf("Stack backtrace:\n");
f0100c17:	83 ec 0c             	sub    $0xc,%esp
f0100c1a:	68 a6 6c 10 f0       	push   $0xf0106ca6
f0100c1f:	e8 b1 30 00 00       	call   f0103cd5 <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100c24:	89 eb                	mov    %ebp,%ebx
    while (ebp != NULL) {
f0100c26:	83 c4 10             	add    $0x10,%esp
		debuginfo_eip((uintptr_t)ebp[1], &info);
f0100c29:	8d 75 e0             	lea    -0x20(%ebp),%esi
    while (ebp != NULL) {
f0100c2c:	85 db                	test   %ebx,%ebx
f0100c2e:	74 50                	je     f0100c80 <mon_backtrace+0x76>
    	cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n",
f0100c30:	ff 73 18             	pushl  0x18(%ebx)
f0100c33:	ff 73 14             	pushl  0x14(%ebx)
f0100c36:	ff 73 10             	pushl  0x10(%ebx)
f0100c39:	ff 73 0c             	pushl  0xc(%ebx)
f0100c3c:	ff 73 08             	pushl  0x8(%ebx)
f0100c3f:	53                   	push   %ebx
f0100c40:	ff 73 04             	pushl  0x4(%ebx)
f0100c43:	68 dc 6e 10 f0       	push   $0xf0106edc
f0100c48:	e8 88 30 00 00       	call   f0103cd5 <cprintf>
		debuginfo_eip((uintptr_t)ebp[1], &info);
f0100c4d:	83 c4 18             	add    $0x18,%esp
f0100c50:	56                   	push   %esi
f0100c51:	ff 73 04             	pushl  0x4(%ebx)
f0100c54:	e8 0a 43 00 00       	call   f0104f63 <debuginfo_eip>
		cprintf("      %s:%u %.*s+%u\n",
f0100c59:	83 c4 08             	add    $0x8,%esp
f0100c5c:	8b 43 04             	mov    0x4(%ebx),%eax
f0100c5f:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100c62:	50                   	push   %eax
f0100c63:	ff 75 e8             	pushl  -0x18(%ebp)
f0100c66:	ff 75 ec             	pushl  -0x14(%ebp)
f0100c69:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100c6c:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c6f:	68 b8 6c 10 f0       	push   $0xf0106cb8
f0100c74:	e8 5c 30 00 00       	call   f0103cd5 <cprintf>
    	ebp = (uint32_t *)(ebp[0]);
f0100c79:	8b 1b                	mov    (%ebx),%ebx
f0100c7b:	83 c4 20             	add    $0x20,%esp
f0100c7e:	eb ac                	jmp    f0100c2c <mon_backtrace+0x22>
	cprintf("Backtrace success\n");
f0100c80:	83 ec 0c             	sub    $0xc,%esp
f0100c83:	68 cd 6c 10 f0       	push   $0xf0106ccd
f0100c88:	e8 48 30 00 00       	call   f0103cd5 <cprintf>
}
f0100c8d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c92:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100c95:	5b                   	pop    %ebx
f0100c96:	5e                   	pop    %esi
f0100c97:	5d                   	pop    %ebp
f0100c98:	c3                   	ret    

f0100c99 <overflow_me>:
{
f0100c99:	55                   	push   %ebp
f0100c9a:	89 e5                	mov    %esp,%ebp
f0100c9c:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f0100c9f:	e8 f7 fe ff ff       	call   f0100b9b <start_overflow>
}
f0100ca4:	c9                   	leave  
f0100ca5:	c3                   	ret    

f0100ca6 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100ca6:	55                   	push   %ebp
f0100ca7:	89 e5                	mov    %esp,%ebp
f0100ca9:	57                   	push   %edi
f0100caa:	56                   	push   %esi
f0100cab:	53                   	push   %ebx
f0100cac:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100caf:	68 14 6f 10 f0       	push   $0xf0106f14
f0100cb4:	e8 1c 30 00 00       	call   f0103cd5 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100cb9:	c7 04 24 38 6f 10 f0 	movl   $0xf0106f38,(%esp)
f0100cc0:	e8 10 30 00 00       	call   f0103cd5 <cprintf>
f0100cc5:	83 c4 10             	add    $0x10,%esp
f0100cc8:	e9 c6 00 00 00       	jmp    f0100d93 <monitor+0xed>
		while (*buf && strchr(WHITESPACE, *buf))
f0100ccd:	83 ec 08             	sub    $0x8,%esp
f0100cd0:	0f be c0             	movsbl %al,%eax
f0100cd3:	50                   	push   %eax
f0100cd4:	68 e4 6c 10 f0       	push   $0xf0106ce4
f0100cd9:	e8 e2 4e 00 00       	call   f0105bc0 <strchr>
f0100cde:	83 c4 10             	add    $0x10,%esp
f0100ce1:	85 c0                	test   %eax,%eax
f0100ce3:	74 63                	je     f0100d48 <monitor+0xa2>
			*buf++ = 0;
f0100ce5:	c6 03 00             	movb   $0x0,(%ebx)
f0100ce8:	89 f7                	mov    %esi,%edi
f0100cea:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100ced:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f0100cef:	0f b6 03             	movzbl (%ebx),%eax
f0100cf2:	84 c0                	test   %al,%al
f0100cf4:	75 d7                	jne    f0100ccd <monitor+0x27>
	argv[argc] = 0;
f0100cf6:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100cfd:	00 
	if (argc == 0)
f0100cfe:	85 f6                	test   %esi,%esi
f0100d00:	0f 84 8d 00 00 00    	je     f0100d93 <monitor+0xed>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100d06:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100d0b:	83 ec 08             	sub    $0x8,%esp
f0100d0e:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100d11:	ff 34 85 80 70 10 f0 	pushl  -0xfef8f80(,%eax,4)
f0100d18:	ff 75 a8             	pushl  -0x58(%ebp)
f0100d1b:	e8 42 4e 00 00       	call   f0105b62 <strcmp>
f0100d20:	83 c4 10             	add    $0x10,%esp
f0100d23:	85 c0                	test   %eax,%eax
f0100d25:	0f 84 8f 00 00 00    	je     f0100dba <monitor+0x114>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100d2b:	83 c3 01             	add    $0x1,%ebx
f0100d2e:	83 fb 06             	cmp    $0x6,%ebx
f0100d31:	75 d8                	jne    f0100d0b <monitor+0x65>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100d33:	83 ec 08             	sub    $0x8,%esp
f0100d36:	ff 75 a8             	pushl  -0x58(%ebp)
f0100d39:	68 06 6d 10 f0       	push   $0xf0106d06
f0100d3e:	e8 92 2f 00 00       	call   f0103cd5 <cprintf>
f0100d43:	83 c4 10             	add    $0x10,%esp
f0100d46:	eb 4b                	jmp    f0100d93 <monitor+0xed>
		if (*buf == 0)
f0100d48:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100d4b:	74 a9                	je     f0100cf6 <monitor+0x50>
		if (argc == MAXARGS-1) {
f0100d4d:	83 fe 0f             	cmp    $0xf,%esi
f0100d50:	74 2f                	je     f0100d81 <monitor+0xdb>
		argv[argc++] = buf;
f0100d52:	8d 7e 01             	lea    0x1(%esi),%edi
f0100d55:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f0100d59:	0f b6 03             	movzbl (%ebx),%eax
f0100d5c:	84 c0                	test   %al,%al
f0100d5e:	74 8d                	je     f0100ced <monitor+0x47>
f0100d60:	83 ec 08             	sub    $0x8,%esp
f0100d63:	0f be c0             	movsbl %al,%eax
f0100d66:	50                   	push   %eax
f0100d67:	68 e4 6c 10 f0       	push   $0xf0106ce4
f0100d6c:	e8 4f 4e 00 00       	call   f0105bc0 <strchr>
f0100d71:	83 c4 10             	add    $0x10,%esp
f0100d74:	85 c0                	test   %eax,%eax
f0100d76:	0f 85 71 ff ff ff    	jne    f0100ced <monitor+0x47>
			buf++;
f0100d7c:	83 c3 01             	add    $0x1,%ebx
f0100d7f:	eb d8                	jmp    f0100d59 <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100d81:	83 ec 08             	sub    $0x8,%esp
f0100d84:	6a 10                	push   $0x10
f0100d86:	68 e9 6c 10 f0       	push   $0xf0106ce9
f0100d8b:	e8 45 2f 00 00       	call   f0103cd5 <cprintf>
f0100d90:	83 c4 10             	add    $0x10,%esp
	// cprintf("test:[%5x]\n", 32);

	// cprintf("test:[%-5x]\n", 32);	
	
	while (1) {
		buf = readline("K> ");
f0100d93:	83 ec 0c             	sub    $0xc,%esp
f0100d96:	68 e0 6c 10 f0       	push   $0xf0106ce0
f0100d9b:	e8 fc 4b 00 00       	call   f010599c <readline>
f0100da0:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100da2:	83 c4 10             	add    $0x10,%esp
f0100da5:	85 c0                	test   %eax,%eax
f0100da7:	74 ea                	je     f0100d93 <monitor+0xed>
	argv[argc] = 0;
f0100da9:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100db0:	be 00 00 00 00       	mov    $0x0,%esi
f0100db5:	e9 35 ff ff ff       	jmp    f0100cef <monitor+0x49>
			return commands[i].func(argc, argv, tf);
f0100dba:	83 ec 04             	sub    $0x4,%esp
f0100dbd:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100dc0:	ff 75 08             	pushl  0x8(%ebp)
f0100dc3:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100dc6:	52                   	push   %edx
f0100dc7:	56                   	push   %esi
f0100dc8:	ff 14 85 88 70 10 f0 	call   *-0xfef8f78(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100dcf:	83 c4 10             	add    $0x10,%esp
f0100dd2:	85 c0                	test   %eax,%eax
f0100dd4:	79 bd                	jns    f0100d93 <monitor+0xed>
				break;
	}
}
f0100dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dd9:	5b                   	pop    %ebx
f0100dda:	5e                   	pop    %esi
f0100ddb:	5f                   	pop    %edi
f0100ddc:	5d                   	pop    %ebp
f0100ddd:	c3                   	ret    

f0100dde <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100dde:	55                   	push   %ebp
f0100ddf:	89 e5                	mov    %esp,%ebp
f0100de1:	56                   	push   %esi
f0100de2:	53                   	push   %ebx
f0100de3:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100de5:	83 ec 0c             	sub    $0xc,%esp
f0100de8:	50                   	push   %eax
f0100de9:	e8 52 2d 00 00       	call   f0103b40 <mc146818_read>
f0100dee:	89 c3                	mov    %eax,%ebx
f0100df0:	83 c6 01             	add    $0x1,%esi
f0100df3:	89 34 24             	mov    %esi,(%esp)
f0100df6:	e8 45 2d 00 00       	call   f0103b40 <mc146818_read>
f0100dfb:	c1 e0 08             	shl    $0x8,%eax
f0100dfe:	09 d8                	or     %ebx,%eax
}
f0100e00:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e03:	5b                   	pop    %ebx
f0100e04:	5e                   	pop    %esi
f0100e05:	5d                   	pop    %ebp
f0100e06:	c3                   	ret    

f0100e07 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100e07:	89 d1                	mov    %edx,%ecx
f0100e09:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100e0c:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100e0f:	a8 01                	test   $0x1,%al
f0100e11:	74 52                	je     f0100e65 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100e13:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100e18:	89 c1                	mov    %eax,%ecx
f0100e1a:	c1 e9 0c             	shr    $0xc,%ecx
f0100e1d:	3b 0d 88 0e 25 f0    	cmp    0xf0250e88,%ecx
f0100e23:	73 25                	jae    f0100e4a <check_va2pa+0x43>
	if (!(p[PTX(va)] & PTE_P))
f0100e25:	c1 ea 0c             	shr    $0xc,%edx
f0100e28:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100e2e:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100e35:	89 c2                	mov    %eax,%edx
f0100e37:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100e3a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100e3f:	85 d2                	test   %edx,%edx
f0100e41:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100e46:	0f 44 c2             	cmove  %edx,%eax
f0100e49:	c3                   	ret    
{
f0100e4a:	55                   	push   %ebp
f0100e4b:	89 e5                	mov    %esp,%ebp
f0100e4d:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e50:	50                   	push   %eax
f0100e51:	68 d4 68 10 f0       	push   $0xf01068d4
f0100e56:	68 b3 03 00 00       	push   $0x3b3
f0100e5b:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0100e60:	e8 db f1 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100e65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100e6a:	c3                   	ret    

f0100e6b <boot_alloc>:
	if (!nextfree) {
f0100e6b:	83 3d 38 02 25 f0 00 	cmpl   $0x0,0xf0250238
f0100e72:	74 45                	je     f0100eb9 <boot_alloc+0x4e>
	if (n > 0) {
f0100e74:	85 c0                	test   %eax,%eax
f0100e76:	74 78                	je     f0100ef0 <boot_alloc+0x85>
{
f0100e78:	55                   	push   %ebp
f0100e79:	89 e5                	mov    %esp,%ebp
f0100e7b:	53                   	push   %ebx
f0100e7c:	83 ec 04             	sub    $0x4,%esp
f0100e7f:	89 c2                	mov    %eax,%edx
		result = nextfree;
f0100e81:	a1 38 02 25 f0       	mov    0xf0250238,%eax
		nextfree = KADDR(PADDR(ROUNDUP(nextfree + n, PGSIZE)));
f0100e86:	8d 94 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edx
f0100e8d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if ((uint32_t)kva < KERNBASE)
f0100e93:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100e99:	76 31                	jbe    f0100ecc <boot_alloc+0x61>
	return (physaddr_t)kva - KERNBASE;
f0100e9b:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
	if (PGNUM(pa) >= npages)
f0100ea1:	89 cb                	mov    %ecx,%ebx
f0100ea3:	c1 eb 0c             	shr    $0xc,%ebx
f0100ea6:	39 1d 88 0e 25 f0    	cmp    %ebx,0xf0250e88
f0100eac:	76 30                	jbe    f0100ede <boot_alloc+0x73>
f0100eae:	89 15 38 02 25 f0    	mov    %edx,0xf0250238
}
f0100eb4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100eb7:	c9                   	leave  
f0100eb8:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100eb9:	ba 07 30 29 f0       	mov    $0xf0293007,%edx
f0100ebe:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ec4:	89 15 38 02 25 f0    	mov    %edx,0xf0250238
f0100eca:	eb a8                	jmp    f0100e74 <boot_alloc+0x9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ecc:	52                   	push   %edx
f0100ecd:	68 f8 68 10 f0       	push   $0xf01068f8
f0100ed2:	6a 76                	push   $0x76
f0100ed4:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0100ed9:	e8 62 f1 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ede:	51                   	push   %ecx
f0100edf:	68 d4 68 10 f0       	push   $0xf01068d4
f0100ee4:	6a 76                	push   $0x76
f0100ee6:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0100eeb:	e8 50 f1 ff ff       	call   f0100040 <_panic>
	else if (n == 0) result =  nextfree;
f0100ef0:	a1 38 02 25 f0       	mov    0xf0250238,%eax
}
f0100ef5:	c3                   	ret    

f0100ef6 <check_page_free_list>:
{
f0100ef6:	55                   	push   %ebp
f0100ef7:	89 e5                	mov    %esp,%ebp
f0100ef9:	57                   	push   %edi
f0100efa:	56                   	push   %esi
f0100efb:	53                   	push   %ebx
f0100efc:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100eff:	84 c0                	test   %al,%al
f0100f01:	0f 85 77 02 00 00    	jne    f010117e <check_page_free_list+0x288>
	if (!page_free_list)
f0100f07:	83 3d 40 02 25 f0 00 	cmpl   $0x0,0xf0250240
f0100f0e:	74 0a                	je     f0100f1a <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100f10:	be 00 04 00 00       	mov    $0x400,%esi
f0100f15:	e9 bf 02 00 00       	jmp    f01011d9 <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100f1a:	83 ec 04             	sub    $0x4,%esp
f0100f1d:	68 c8 70 10 f0       	push   $0xf01070c8
f0100f22:	68 df 02 00 00       	push   $0x2df
f0100f27:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0100f2c:	e8 0f f1 ff ff       	call   f0100040 <_panic>
f0100f31:	50                   	push   %eax
f0100f32:	68 d4 68 10 f0       	push   $0xf01068d4
f0100f37:	6a 58                	push   $0x58
f0100f39:	68 79 7a 10 f0       	push   $0xf0107a79
f0100f3e:	e8 fd f0 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100f43:	8b 1b                	mov    (%ebx),%ebx
f0100f45:	85 db                	test   %ebx,%ebx
f0100f47:	74 41                	je     f0100f8a <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f49:	89 d8                	mov    %ebx,%eax
f0100f4b:	2b 05 90 0e 25 f0    	sub    0xf0250e90,%eax
f0100f51:	c1 f8 03             	sar    $0x3,%eax
f0100f54:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100f57:	89 c2                	mov    %eax,%edx
f0100f59:	c1 ea 16             	shr    $0x16,%edx
f0100f5c:	39 f2                	cmp    %esi,%edx
f0100f5e:	73 e3                	jae    f0100f43 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100f60:	89 c2                	mov    %eax,%edx
f0100f62:	c1 ea 0c             	shr    $0xc,%edx
f0100f65:	3b 15 88 0e 25 f0    	cmp    0xf0250e88,%edx
f0100f6b:	73 c4                	jae    f0100f31 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100f6d:	83 ec 04             	sub    $0x4,%esp
f0100f70:	68 80 00 00 00       	push   $0x80
f0100f75:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100f7a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f7f:	50                   	push   %eax
f0100f80:	e8 78 4c 00 00       	call   f0105bfd <memset>
f0100f85:	83 c4 10             	add    $0x10,%esp
f0100f88:	eb b9                	jmp    f0100f43 <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100f8a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f8f:	e8 d7 fe ff ff       	call   f0100e6b <boot_alloc>
f0100f94:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f97:	8b 15 40 02 25 f0    	mov    0xf0250240,%edx
		assert(pp >= pages);
f0100f9d:	8b 0d 90 0e 25 f0    	mov    0xf0250e90,%ecx
		assert(pp < pages + npages);
f0100fa3:	a1 88 0e 25 f0       	mov    0xf0250e88,%eax
f0100fa8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100fab:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100fae:	bf 00 00 00 00       	mov    $0x0,%edi
f0100fb3:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fb6:	e9 f9 00 00 00       	jmp    f01010b4 <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100fbb:	68 87 7a 10 f0       	push   $0xf0107a87
f0100fc0:	68 93 7a 10 f0       	push   $0xf0107a93
f0100fc5:	68 f9 02 00 00       	push   $0x2f9
f0100fca:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0100fcf:	e8 6c f0 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100fd4:	68 a8 7a 10 f0       	push   $0xf0107aa8
f0100fd9:	68 93 7a 10 f0       	push   $0xf0107a93
f0100fde:	68 fa 02 00 00       	push   $0x2fa
f0100fe3:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0100fe8:	e8 53 f0 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100fed:	68 ec 70 10 f0       	push   $0xf01070ec
f0100ff2:	68 93 7a 10 f0       	push   $0xf0107a93
f0100ff7:	68 fb 02 00 00       	push   $0x2fb
f0100ffc:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101001:	e8 3a f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0101006:	68 bc 7a 10 f0       	push   $0xf0107abc
f010100b:	68 93 7a 10 f0       	push   $0xf0107a93
f0101010:	68 fe 02 00 00       	push   $0x2fe
f0101015:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010101a:	e8 21 f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010101f:	68 cd 7a 10 f0       	push   $0xf0107acd
f0101024:	68 93 7a 10 f0       	push   $0xf0107a93
f0101029:	68 ff 02 00 00       	push   $0x2ff
f010102e:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101033:	e8 08 f0 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101038:	68 20 71 10 f0       	push   $0xf0107120
f010103d:	68 93 7a 10 f0       	push   $0xf0107a93
f0101042:	68 00 03 00 00       	push   $0x300
f0101047:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010104c:	e8 ef ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101051:	68 e6 7a 10 f0       	push   $0xf0107ae6
f0101056:	68 93 7a 10 f0       	push   $0xf0107a93
f010105b:	68 01 03 00 00       	push   $0x301
f0101060:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101065:	e8 d6 ef ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f010106a:	89 c3                	mov    %eax,%ebx
f010106c:	c1 eb 0c             	shr    $0xc,%ebx
f010106f:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0101072:	76 0f                	jbe    f0101083 <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0101074:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101079:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010107c:	77 17                	ja     f0101095 <check_page_free_list+0x19f>
			++nfree_extmem;
f010107e:	83 c7 01             	add    $0x1,%edi
f0101081:	eb 2f                	jmp    f01010b2 <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101083:	50                   	push   %eax
f0101084:	68 d4 68 10 f0       	push   $0xf01068d4
f0101089:	6a 58                	push   $0x58
f010108b:	68 79 7a 10 f0       	push   $0xf0107a79
f0101090:	e8 ab ef ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101095:	68 44 71 10 f0       	push   $0xf0107144
f010109a:	68 93 7a 10 f0       	push   $0xf0107a93
f010109f:	68 02 03 00 00       	push   $0x302
f01010a4:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01010a9:	e8 92 ef ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f01010ae:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01010b2:	8b 12                	mov    (%edx),%edx
f01010b4:	85 d2                	test   %edx,%edx
f01010b6:	74 74                	je     f010112c <check_page_free_list+0x236>
		assert(pp >= pages);
f01010b8:	39 d1                	cmp    %edx,%ecx
f01010ba:	0f 87 fb fe ff ff    	ja     f0100fbb <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f01010c0:	39 d6                	cmp    %edx,%esi
f01010c2:	0f 86 0c ff ff ff    	jbe    f0100fd4 <check_page_free_list+0xde>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010c8:	89 d0                	mov    %edx,%eax
f01010ca:	29 c8                	sub    %ecx,%eax
f01010cc:	a8 07                	test   $0x7,%al
f01010ce:	0f 85 19 ff ff ff    	jne    f0100fed <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f01010d4:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f01010d7:	c1 e0 0c             	shl    $0xc,%eax
f01010da:	0f 84 26 ff ff ff    	je     f0101006 <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f01010e0:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010e5:	0f 84 34 ff ff ff    	je     f010101f <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f01010eb:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f01010f0:	0f 84 42 ff ff ff    	je     f0101038 <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f01010f6:	3d 00 00 10 00       	cmp    $0x100000,%eax
f01010fb:	0f 84 50 ff ff ff    	je     f0101051 <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101101:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101106:	0f 87 5e ff ff ff    	ja     f010106a <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f010110c:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0101111:	75 9b                	jne    f01010ae <check_page_free_list+0x1b8>
f0101113:	68 00 7b 10 f0       	push   $0xf0107b00
f0101118:	68 93 7a 10 f0       	push   $0xf0107a93
f010111d:	68 04 03 00 00       	push   $0x304
f0101122:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101127:	e8 14 ef ff ff       	call   f0100040 <_panic>
f010112c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f010112f:	85 db                	test   %ebx,%ebx
f0101131:	7e 19                	jle    f010114c <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0101133:	85 ff                	test   %edi,%edi
f0101135:	7e 2e                	jle    f0101165 <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0101137:	83 ec 0c             	sub    $0xc,%esp
f010113a:	68 8c 71 10 f0       	push   $0xf010718c
f010113f:	e8 91 2b 00 00       	call   f0103cd5 <cprintf>
}
f0101144:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101147:	5b                   	pop    %ebx
f0101148:	5e                   	pop    %esi
f0101149:	5f                   	pop    %edi
f010114a:	5d                   	pop    %ebp
f010114b:	c3                   	ret    
	assert(nfree_basemem > 0);
f010114c:	68 1d 7b 10 f0       	push   $0xf0107b1d
f0101151:	68 93 7a 10 f0       	push   $0xf0107a93
f0101156:	68 0c 03 00 00       	push   $0x30c
f010115b:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101160:	e8 db ee ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0101165:	68 2f 7b 10 f0       	push   $0xf0107b2f
f010116a:	68 93 7a 10 f0       	push   $0xf0107a93
f010116f:	68 0d 03 00 00       	push   $0x30d
f0101174:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101179:	e8 c2 ee ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f010117e:	a1 40 02 25 f0       	mov    0xf0250240,%eax
f0101183:	85 c0                	test   %eax,%eax
f0101185:	0f 84 8f fd ff ff    	je     f0100f1a <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010118b:	8d 55 d8             	lea    -0x28(%ebp),%edx
f010118e:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101191:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101194:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101197:	89 c2                	mov    %eax,%edx
f0101199:	2b 15 90 0e 25 f0    	sub    0xf0250e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010119f:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01011a5:	0f 95 c2             	setne  %dl
f01011a8:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01011ab:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01011af:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01011b1:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01011b5:	8b 00                	mov    (%eax),%eax
f01011b7:	85 c0                	test   %eax,%eax
f01011b9:	75 dc                	jne    f0101197 <check_page_free_list+0x2a1>
		*tp[1] = 0;
f01011bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011be:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01011c4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01011c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011ca:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01011cc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01011cf:	a3 40 02 25 f0       	mov    %eax,0xf0250240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01011d4:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01011d9:	8b 1d 40 02 25 f0    	mov    0xf0250240,%ebx
f01011df:	e9 61 fd ff ff       	jmp    f0100f45 <check_page_free_list+0x4f>

f01011e4 <page_init>:
{
f01011e4:	55                   	push   %ebp
f01011e5:	89 e5                	mov    %esp,%ebp
f01011e7:	56                   	push   %esi
f01011e8:	53                   	push   %ebx
	pages[0].pp_ref = 1;
f01011e9:	a1 90 0e 25 f0       	mov    0xf0250e90,%eax
f01011ee:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
	pages[0].pp_link = NULL;
f01011f4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f01011fa:	8b 35 40 02 25 f0    	mov    0xf0250240,%esi
	for (i = 1; i < (IOPHYSMEM / PGSIZE); i++) {
f0101200:	bb 01 00 00 00       	mov    $0x1,%ebx
		pages[i].pp_ref = 0;
f0101205:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f010120c:	89 c2                	mov    %eax,%edx
f010120e:	03 15 90 0e 25 f0    	add    0xf0250e90,%edx
f0101214:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f010121a:	89 32                	mov    %esi,(%edx)
		page_free_list = &pages[i];
f010121c:	8b 15 90 0e 25 f0    	mov    0xf0250e90,%edx
f0101222:	8d 34 02             	lea    (%edx,%eax,1),%esi
	for (i = 1; i < (IOPHYSMEM / PGSIZE); i++) {
f0101225:	83 c3 01             	add    $0x1,%ebx
f0101228:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f010122e:	77 14                	ja     f0101244 <page_init+0x60>
		if (i == (MPENTRY_PADDR / PGSIZE)) {
f0101230:	83 fb 07             	cmp    $0x7,%ebx
f0101233:	75 d0                	jne    f0101205 <page_init+0x21>
			pages[i].pp_ref = 1;
f0101235:	66 c7 42 3c 01 00    	movw   $0x1,0x3c(%edx)
			pages[i].pp_link = NULL;
f010123b:	c7 42 38 00 00 00 00 	movl   $0x0,0x38(%edx)
			continue;
f0101242:	eb e1                	jmp    f0101225 <page_init+0x41>
f0101244:	89 35 40 02 25 f0    	mov    %esi,0xf0250240
f010124a:	eb 17                	jmp    f0101263 <page_init+0x7f>
		pages[i].pp_ref = 1;
f010124c:	a1 90 0e 25 f0       	mov    0xf0250e90,%eax
f0101251:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0101254:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
		pages[i].pp_link = NULL;
f010125a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	for (; i < PGNUM(PADDR(boot_alloc(0))); i++) { //???
f0101260:	83 c3 01             	add    $0x1,%ebx
f0101263:	b8 00 00 00 00       	mov    $0x0,%eax
f0101268:	e8 fe fb ff ff       	call   f0100e6b <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f010126d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101272:	76 18                	jbe    f010128c <page_init+0xa8>
	return (physaddr_t)kva - KERNBASE;
f0101274:	05 00 00 00 10       	add    $0x10000000,%eax
f0101279:	c1 e8 0c             	shr    $0xc,%eax
f010127c:	39 d8                	cmp    %ebx,%eax
f010127e:	77 cc                	ja     f010124c <page_init+0x68>
f0101280:	b8 00 00 00 00       	mov    $0x0,%eax
f0101285:	b9 01 00 00 00       	mov    $0x1,%ecx
f010128a:	eb 39                	jmp    f01012c5 <page_init+0xe1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010128c:	50                   	push   %eax
f010128d:	68 f8 68 10 f0       	push   $0xf01068f8
f0101292:	68 65 01 00 00       	push   $0x165
f0101297:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010129c:	e8 9f ed ff ff       	call   f0100040 <_panic>
f01012a1:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
		pages[i].pp_ref = 0;
f01012a8:	89 c2                	mov    %eax,%edx
f01012aa:	03 15 90 0e 25 f0    	add    0xf0250e90,%edx
f01012b0:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
		pages[i].pp_link = page_free_list;
f01012b6:	89 32                	mov    %esi,(%edx)
	for (; i < npages; i++) {
f01012b8:	83 c3 01             	add    $0x1,%ebx
		page_free_list = &pages[i];
f01012bb:	03 05 90 0e 25 f0    	add    0xf0250e90,%eax
f01012c1:	89 c6                	mov    %eax,%esi
f01012c3:	89 c8                	mov    %ecx,%eax
	for (; i < npages; i++) {
f01012c5:	39 1d 88 0e 25 f0    	cmp    %ebx,0xf0250e88
f01012cb:	77 d4                	ja     f01012a1 <page_init+0xbd>
f01012cd:	84 c0                	test   %al,%al
f01012cf:	74 06                	je     f01012d7 <page_init+0xf3>
f01012d1:	89 35 40 02 25 f0    	mov    %esi,0xf0250240
}
f01012d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012da:	5b                   	pop    %ebx
f01012db:	5e                   	pop    %esi
f01012dc:	5d                   	pop    %ebp
f01012dd:	c3                   	ret    

f01012de <page_alloc>:
{
f01012de:	55                   	push   %ebp
f01012df:	89 e5                	mov    %esp,%ebp
f01012e1:	53                   	push   %ebx
f01012e2:	83 ec 04             	sub    $0x4,%esp
	if (!page_free_list) return NULL;
f01012e5:	8b 1d 40 02 25 f0    	mov    0xf0250240,%ebx
f01012eb:	85 db                	test   %ebx,%ebx
f01012ed:	74 19                	je     f0101308 <page_alloc+0x2a>
	page_free_list = page_free_list->pp_link;
f01012ef:	8b 03                	mov    (%ebx),%eax
f01012f1:	a3 40 02 25 f0       	mov    %eax,0xf0250240
	res->pp_ref = 0;
f01012f6:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	res->pp_link = NULL;
f01012fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) {
f0101302:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101306:	75 07                	jne    f010130f <page_alloc+0x31>
}
f0101308:	89 d8                	mov    %ebx,%eax
f010130a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010130d:	c9                   	leave  
f010130e:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f010130f:	89 d8                	mov    %ebx,%eax
f0101311:	2b 05 90 0e 25 f0    	sub    0xf0250e90,%eax
f0101317:	c1 f8 03             	sar    $0x3,%eax
f010131a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010131d:	89 c2                	mov    %eax,%edx
f010131f:	c1 ea 0c             	shr    $0xc,%edx
f0101322:	3b 15 88 0e 25 f0    	cmp    0xf0250e88,%edx
f0101328:	73 1a                	jae    f0101344 <page_alloc+0x66>
		memset(page2kva(res), 0, PGSIZE);
f010132a:	83 ec 04             	sub    $0x4,%esp
f010132d:	68 00 10 00 00       	push   $0x1000
f0101332:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0101334:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101339:	50                   	push   %eax
f010133a:	e8 be 48 00 00       	call   f0105bfd <memset>
f010133f:	83 c4 10             	add    $0x10,%esp
f0101342:	eb c4                	jmp    f0101308 <page_alloc+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101344:	50                   	push   %eax
f0101345:	68 d4 68 10 f0       	push   $0xf01068d4
f010134a:	6a 58                	push   $0x58
f010134c:	68 79 7a 10 f0       	push   $0xf0107a79
f0101351:	e8 ea ec ff ff       	call   f0100040 <_panic>

f0101356 <page_free>:
{
f0101356:	55                   	push   %ebp
f0101357:	89 e5                	mov    %esp,%ebp
f0101359:	83 ec 08             	sub    $0x8,%esp
f010135c:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL) {
f010135f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101364:	75 14                	jne    f010137a <page_free+0x24>
f0101366:	83 38 00             	cmpl   $0x0,(%eax)
f0101369:	75 0f                	jne    f010137a <page_free+0x24>
	pp->pp_link = page_free_list;
f010136b:	8b 15 40 02 25 f0    	mov    0xf0250240,%edx
f0101371:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101373:	a3 40 02 25 f0       	mov    %eax,0xf0250240
}
f0101378:	c9                   	leave  
f0101379:	c3                   	ret    
		panic("pp->pp_ref is nonzero or pp->pp_link is not NULL");
f010137a:	83 ec 04             	sub    $0x4,%esp
f010137d:	68 b0 71 10 f0       	push   $0xf01071b0
f0101382:	68 9a 01 00 00       	push   $0x19a
f0101387:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010138c:	e8 af ec ff ff       	call   f0100040 <_panic>

f0101391 <page_decref>:
{
f0101391:	55                   	push   %ebp
f0101392:	89 e5                	mov    %esp,%ebp
f0101394:	83 ec 08             	sub    $0x8,%esp
f0101397:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010139a:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010139e:	83 e8 01             	sub    $0x1,%eax
f01013a1:	66 89 42 04          	mov    %ax,0x4(%edx)
f01013a5:	66 85 c0             	test   %ax,%ax
f01013a8:	74 02                	je     f01013ac <page_decref+0x1b>
}
f01013aa:	c9                   	leave  
f01013ab:	c3                   	ret    
		page_free(pp);
f01013ac:	83 ec 0c             	sub    $0xc,%esp
f01013af:	52                   	push   %edx
f01013b0:	e8 a1 ff ff ff       	call   f0101356 <page_free>
f01013b5:	83 c4 10             	add    $0x10,%esp
}
f01013b8:	eb f0                	jmp    f01013aa <page_decref+0x19>

f01013ba <pgdir_walk>:
{
f01013ba:	55                   	push   %ebp
f01013bb:	89 e5                	mov    %esp,%ebp
f01013bd:	56                   	push   %esi
f01013be:	53                   	push   %ebx
f01013bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01013c2:	8b 45 10             	mov    0x10(%ebp),%eax
	unsigned int ptx = PTX(va);
f01013c5:	89 de                	mov    %ebx,%esi
f01013c7:	c1 ee 0c             	shr    $0xc,%esi
f01013ca:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	unsigned int pdx = PDX(va);
f01013d0:	c1 eb 16             	shr    $0x16,%ebx
	pde_t *pde = pgdir + pdx;
f01013d3:	c1 e3 02             	shl    $0x2,%ebx
f01013d6:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!(*pde & PTE_P) && create) {
f01013d9:	8b 13                	mov    (%ebx),%edx
f01013db:	83 e2 01             	and    $0x1,%edx
f01013de:	89 c1                	mov    %eax,%ecx
f01013e0:	09 d1                	or     %edx,%ecx
f01013e2:	85 c0                	test   %eax,%eax
f01013e4:	74 04                	je     f01013ea <pgdir_walk+0x30>
f01013e6:	85 d2                	test   %edx,%edx
f01013e8:	74 26                	je     f0101410 <pgdir_walk+0x56>
	else if(!(*pde & PTE_P) && !create) return NULL;
f01013ea:	85 c9                	test   %ecx,%ecx
f01013ec:	74 67                	je     f0101455 <pgdir_walk+0x9b>
	pte_t *res = KADDR(PTE_ADDR(*pde));
f01013ee:	8b 03                	mov    (%ebx),%eax
f01013f0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01013f5:	89 c2                	mov    %eax,%edx
f01013f7:	c1 ea 0c             	shr    $0xc,%edx
f01013fa:	3b 15 88 0e 25 f0    	cmp    0xf0250e88,%edx
f0101400:	73 37                	jae    f0101439 <pgdir_walk+0x7f>
	return &res[ptx];
f0101402:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
}	
f0101409:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010140c:	5b                   	pop    %ebx
f010140d:	5e                   	pop    %esi
f010140e:	5d                   	pop    %ebp
f010140f:	c3                   	ret    
		struct PageInfo *newpg = page_alloc(ALLOC_ZERO);
f0101410:	83 ec 0c             	sub    $0xc,%esp
f0101413:	6a 01                	push   $0x1
f0101415:	e8 c4 fe ff ff       	call   f01012de <page_alloc>
		if (newpg == NULL) return NULL;
f010141a:	83 c4 10             	add    $0x10,%esp
f010141d:	85 c0                	test   %eax,%eax
f010141f:	74 2d                	je     f010144e <pgdir_walk+0x94>
		newpg->pp_ref++;
f0101421:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101426:	2b 05 90 0e 25 f0    	sub    0xf0250e90,%eax
f010142c:	c1 f8 03             	sar    $0x3,%eax
f010142f:	c1 e0 0c             	shl    $0xc,%eax
		*pde = page2pa(newpg) | PTE_P | PTE_W | PTE_U;
f0101432:	83 c8 07             	or     $0x7,%eax
f0101435:	89 03                	mov    %eax,(%ebx)
	if (!(*pde & PTE_P) && create) {
f0101437:	eb b5                	jmp    f01013ee <pgdir_walk+0x34>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101439:	50                   	push   %eax
f010143a:	68 d4 68 10 f0       	push   $0xf01068d4
f010143f:	68 d2 01 00 00       	push   $0x1d2
f0101444:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101449:	e8 f2 eb ff ff       	call   f0100040 <_panic>
		if (newpg == NULL) return NULL;
f010144e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101453:	eb b4                	jmp    f0101409 <pgdir_walk+0x4f>
	else if(!(*pde & PTE_P) && !create) return NULL;
f0101455:	b8 00 00 00 00       	mov    $0x0,%eax
f010145a:	eb ad                	jmp    f0101409 <pgdir_walk+0x4f>

f010145c <boot_map_region>:
{
f010145c:	55                   	push   %ebp
f010145d:	89 e5                	mov    %esp,%ebp
f010145f:	57                   	push   %edi
f0101460:	56                   	push   %esi
f0101461:	53                   	push   %ebx
f0101462:	83 ec 1c             	sub    $0x1c,%esp
f0101465:	89 c7                	mov    %eax,%edi
f0101467:	89 d6                	mov    %edx,%esi
f0101469:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for (int i = 0; i < size; i+=PGSIZE) {
f010146c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101471:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0101474:	76 27                	jbe    f010149d <boot_map_region+0x41>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
f0101476:	83 ec 04             	sub    $0x4,%esp
f0101479:	6a 01                	push   $0x1
f010147b:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010147e:	50                   	push   %eax
f010147f:	57                   	push   %edi
f0101480:	e8 35 ff ff ff       	call   f01013ba <pgdir_walk>
		*pte = (pa + i) | perm | PTE_P;
f0101485:	89 da                	mov    %ebx,%edx
f0101487:	03 55 08             	add    0x8(%ebp),%edx
f010148a:	0b 55 0c             	or     0xc(%ebp),%edx
f010148d:	83 ca 01             	or     $0x1,%edx
f0101490:	89 10                	mov    %edx,(%eax)
	for (int i = 0; i < size; i+=PGSIZE) {
f0101492:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101498:	83 c4 10             	add    $0x10,%esp
f010149b:	eb d4                	jmp    f0101471 <boot_map_region+0x15>
}
f010149d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014a0:	5b                   	pop    %ebx
f01014a1:	5e                   	pop    %esi
f01014a2:	5f                   	pop    %edi
f01014a3:	5d                   	pop    %ebp
f01014a4:	c3                   	ret    

f01014a5 <page_lookup>:
{
f01014a5:	55                   	push   %ebp
f01014a6:	89 e5                	mov    %esp,%ebp
f01014a8:	53                   	push   %ebx
f01014a9:	83 ec 08             	sub    $0x8,%esp
f01014ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01014af:	6a 00                	push   $0x0
f01014b1:	ff 75 0c             	pushl  0xc(%ebp)
f01014b4:	ff 75 08             	pushl  0x8(%ebp)
f01014b7:	e8 fe fe ff ff       	call   f01013ba <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;
f01014bc:	83 c4 10             	add    $0x10,%esp
f01014bf:	85 c0                	test   %eax,%eax
f01014c1:	74 3a                	je     f01014fd <page_lookup+0x58>
f01014c3:	f6 00 01             	testb  $0x1,(%eax)
f01014c6:	74 3c                	je     f0101504 <page_lookup+0x5f>
	if (pte_store) *pte_store = pte;
f01014c8:	85 db                	test   %ebx,%ebx
f01014ca:	74 02                	je     f01014ce <page_lookup+0x29>
f01014cc:	89 03                	mov    %eax,(%ebx)
f01014ce:	8b 00                	mov    (%eax),%eax
f01014d0:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014d3:	39 05 88 0e 25 f0    	cmp    %eax,0xf0250e88
f01014d9:	76 0e                	jbe    f01014e9 <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01014db:	8b 15 90 0e 25 f0    	mov    0xf0250e90,%edx
f01014e1:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01014e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014e7:	c9                   	leave  
f01014e8:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01014e9:	83 ec 04             	sub    $0x4,%esp
f01014ec:	68 e4 71 10 f0       	push   $0xf01071e4
f01014f1:	6a 51                	push   $0x51
f01014f3:	68 79 7a 10 f0       	push   $0xf0107a79
f01014f8:	e8 43 eb ff ff       	call   f0100040 <_panic>
	if (!pte || !(*pte & PTE_P)) return NULL;
f01014fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0101502:	eb e0                	jmp    f01014e4 <page_lookup+0x3f>
f0101504:	b8 00 00 00 00       	mov    $0x0,%eax
f0101509:	eb d9                	jmp    f01014e4 <page_lookup+0x3f>

f010150b <tlb_invalidate>:
{
f010150b:	55                   	push   %ebp
f010150c:	89 e5                	mov    %esp,%ebp
f010150e:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101511:	e8 e8 4c 00 00       	call   f01061fe <cpunum>
f0101516:	6b c0 74             	imul   $0x74,%eax,%eax
f0101519:	83 b8 28 10 25 f0 00 	cmpl   $0x0,-0xfdaefd8(%eax)
f0101520:	74 16                	je     f0101538 <tlb_invalidate+0x2d>
f0101522:	e8 d7 4c 00 00       	call   f01061fe <cpunum>
f0101527:	6b c0 74             	imul   $0x74,%eax,%eax
f010152a:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0101530:	8b 55 08             	mov    0x8(%ebp),%edx
f0101533:	39 50 64             	cmp    %edx,0x64(%eax)
f0101536:	75 06                	jne    f010153e <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101538:	8b 45 0c             	mov    0xc(%ebp),%eax
f010153b:	0f 01 38             	invlpg (%eax)
}
f010153e:	c9                   	leave  
f010153f:	c3                   	ret    

f0101540 <page_remove>:
{
f0101540:	55                   	push   %ebp
f0101541:	89 e5                	mov    %esp,%ebp
f0101543:	56                   	push   %esi
f0101544:	53                   	push   %ebx
f0101545:	83 ec 14             	sub    $0x14,%esp
f0101548:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010154b:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte_store = NULL;
f010154e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f0101555:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101558:	50                   	push   %eax
f0101559:	56                   	push   %esi
f010155a:	53                   	push   %ebx
f010155b:	e8 45 ff ff ff       	call   f01014a5 <page_lookup>
	if (!pp) return;
f0101560:	83 c4 10             	add    $0x10,%esp
f0101563:	85 c0                	test   %eax,%eax
f0101565:	74 25                	je     f010158c <page_remove+0x4c>
	page_decref(pp);
f0101567:	83 ec 0c             	sub    $0xc,%esp
f010156a:	50                   	push   %eax
f010156b:	e8 21 fe ff ff       	call   f0101391 <page_decref>
	tlb_invalidate(pgdir, va);
f0101570:	83 c4 08             	add    $0x8,%esp
f0101573:	56                   	push   %esi
f0101574:	53                   	push   %ebx
f0101575:	e8 91 ff ff ff       	call   f010150b <tlb_invalidate>
	memset(pte_store, 0, 4);
f010157a:	83 c4 0c             	add    $0xc,%esp
f010157d:	6a 04                	push   $0x4
f010157f:	6a 00                	push   $0x0
f0101581:	ff 75 f4             	pushl  -0xc(%ebp)
f0101584:	e8 74 46 00 00       	call   f0105bfd <memset>
f0101589:	83 c4 10             	add    $0x10,%esp
}
f010158c:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010158f:	5b                   	pop    %ebx
f0101590:	5e                   	pop    %esi
f0101591:	5d                   	pop    %ebp
f0101592:	c3                   	ret    

f0101593 <page_insert>:
{
f0101593:	55                   	push   %ebp
f0101594:	89 e5                	mov    %esp,%ebp
f0101596:	57                   	push   %edi
f0101597:	56                   	push   %esi
f0101598:	53                   	push   %ebx
f0101599:	83 ec 10             	sub    $0x10,%esp
f010159c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010159f:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f01015a2:	6a 01                	push   $0x1
f01015a4:	57                   	push   %edi
f01015a5:	ff 75 08             	pushl  0x8(%ebp)
f01015a8:	e8 0d fe ff ff       	call   f01013ba <pgdir_walk>
	if (pte == NULL) return -E_NO_MEM;
f01015ad:	83 c4 10             	add    $0x10,%esp
f01015b0:	85 c0                	test   %eax,%eax
f01015b2:	74 3e                	je     f01015f2 <page_insert+0x5f>
f01015b4:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f01015b6:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) page_remove(pgdir, va);
f01015bb:	f6 00 01             	testb  $0x1,(%eax)
f01015be:	75 21                	jne    f01015e1 <page_insert+0x4e>
	return (pp - pages) << PGSHIFT;
f01015c0:	2b 1d 90 0e 25 f0    	sub    0xf0250e90,%ebx
f01015c6:	c1 fb 03             	sar    $0x3,%ebx
f01015c9:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = page2pa(pp) | perm | PTE_P;
f01015cc:	0b 5d 14             	or     0x14(%ebp),%ebx
f01015cf:	83 cb 01             	or     $0x1,%ebx
f01015d2:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01015d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015dc:	5b                   	pop    %ebx
f01015dd:	5e                   	pop    %esi
f01015de:	5f                   	pop    %edi
f01015df:	5d                   	pop    %ebp
f01015e0:	c3                   	ret    
	if (*pte & PTE_P) page_remove(pgdir, va);
f01015e1:	83 ec 08             	sub    $0x8,%esp
f01015e4:	57                   	push   %edi
f01015e5:	ff 75 08             	pushl  0x8(%ebp)
f01015e8:	e8 53 ff ff ff       	call   f0101540 <page_remove>
f01015ed:	83 c4 10             	add    $0x10,%esp
f01015f0:	eb ce                	jmp    f01015c0 <page_insert+0x2d>
	if (pte == NULL) return -E_NO_MEM;
f01015f2:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01015f7:	eb e0                	jmp    f01015d9 <page_insert+0x46>

f01015f9 <mmio_map_region>:
{
f01015f9:	55                   	push   %ebp
f01015fa:	89 e5                	mov    %esp,%ebp
f01015fc:	57                   	push   %edi
f01015fd:	56                   	push   %esi
f01015fe:	53                   	push   %ebx
f01015ff:	83 ec 0c             	sub    $0xc,%esp
f0101602:	8b 45 08             	mov    0x8(%ebp),%eax
	start = (uintptr_t)ROUNDDOWN(pa, PGSIZE);
f0101605:	89 c3                	mov    %eax,%ebx
f0101607:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	end = (uintptr_t)ROUNDUP(pa + size, PGSIZE);
f010160d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101610:	8d bc 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%edi
f0101617:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	size = end - start;
f010161d:	89 fe                	mov    %edi,%esi
f010161f:	29 de                	sub    %ebx,%esi
	if (base + size >= MMIOLIM) panic("mmio_map_region: overflow MMIOLIM");
f0101621:	8b 15 00 43 12 f0    	mov    0xf0124300,%edx
f0101627:	8d 04 32             	lea    (%edx,%esi,1),%eax
f010162a:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010162f:	77 2b                	ja     f010165c <mmio_map_region+0x63>
	boot_map_region(kern_pgdir, base, size, start, PTE_PCD | PTE_PWT | PTE_W);
f0101631:	83 ec 08             	sub    $0x8,%esp
f0101634:	6a 1a                	push   $0x1a
f0101636:	53                   	push   %ebx
f0101637:	89 f1                	mov    %esi,%ecx
f0101639:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
f010163e:	e8 19 fe ff ff       	call   f010145c <boot_map_region>
	base += size;
f0101643:	89 f0                	mov    %esi,%eax
f0101645:	03 05 00 43 12 f0    	add    0xf0124300,%eax
f010164b:	a3 00 43 12 f0       	mov    %eax,0xf0124300
	return (void *)(base - size);
f0101650:	29 fb                	sub    %edi,%ebx
f0101652:	01 d8                	add    %ebx,%eax
}
f0101654:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101657:	5b                   	pop    %ebx
f0101658:	5e                   	pop    %esi
f0101659:	5f                   	pop    %edi
f010165a:	5d                   	pop    %ebp
f010165b:	c3                   	ret    
	if (base + size >= MMIOLIM) panic("mmio_map_region: overflow MMIOLIM");
f010165c:	83 ec 04             	sub    $0x4,%esp
f010165f:	68 04 72 10 f0       	push   $0xf0107204
f0101664:	68 88 02 00 00       	push   $0x288
f0101669:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010166e:	e8 cd e9 ff ff       	call   f0100040 <_panic>

f0101673 <mem_init>:
{
f0101673:	55                   	push   %ebp
f0101674:	89 e5                	mov    %esp,%ebp
f0101676:	57                   	push   %edi
f0101677:	56                   	push   %esi
f0101678:	53                   	push   %ebx
f0101679:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f010167c:	b8 15 00 00 00       	mov    $0x15,%eax
f0101681:	e8 58 f7 ff ff       	call   f0100dde <nvram_read>
f0101686:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO); //65535
f0101688:	b8 17 00 00 00       	mov    $0x17,%eax
f010168d:	e8 4c f7 ff ff       	call   f0100dde <nvram_read>
f0101692:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64; //114688
f0101694:	b8 34 00 00 00       	mov    $0x34,%eax
f0101699:	e8 40 f7 ff ff       	call   f0100dde <nvram_read>
	if (ext16mem)
f010169e:	c1 e0 06             	shl    $0x6,%eax
f01016a1:	0f 84 21 01 00 00    	je     f01017c8 <mem_init+0x155>
		totalmem = 16 * 1024 + ext16mem;
f01016a7:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024); // 32768
f01016ac:	89 c2                	mov    %eax,%edx
f01016ae:	c1 ea 02             	shr    $0x2,%edx
f01016b1:	89 15 88 0e 25 f0    	mov    %edx,0xf0250e88
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01016b7:	89 c2                	mov    %eax,%edx
f01016b9:	29 da                	sub    %ebx,%edx
f01016bb:	52                   	push   %edx
f01016bc:	53                   	push   %ebx
f01016bd:	50                   	push   %eax
f01016be:	68 28 72 10 f0       	push   $0xf0107228
f01016c3:	e8 0d 26 00 00       	call   f0103cd5 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01016c8:	b8 00 10 00 00       	mov    $0x1000,%eax
f01016cd:	e8 99 f7 ff ff       	call   f0100e6b <boot_alloc>
f01016d2:	a3 8c 0e 25 f0       	mov    %eax,0xf0250e8c
	if ((uint32_t)kva < KERNBASE)
f01016d7:	83 c4 10             	add    $0x10,%esp
f01016da:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01016df:	0f 86 f3 00 00 00    	jbe    f01017d8 <mem_init+0x165>
	cprintf("kern_pgdir: %x\n", PADDR(kern_pgdir));
f01016e5:	83 ec 08             	sub    $0x8,%esp
	return (physaddr_t)kva - KERNBASE;
f01016e8:	05 00 00 00 10       	add    $0x10000000,%eax
f01016ed:	50                   	push   %eax
f01016ee:	68 40 7b 10 f0       	push   $0xf0107b40
f01016f3:	e8 dd 25 00 00       	call   f0103cd5 <cprintf>
	memset(kern_pgdir, 0, PGSIZE);
f01016f8:	83 c4 0c             	add    $0xc,%esp
f01016fb:	68 00 10 00 00       	push   $0x1000
f0101700:	6a 00                	push   $0x0
f0101702:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0101708:	e8 f0 44 00 00       	call   f0105bfd <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010170d:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101712:	83 c4 10             	add    $0x10,%esp
f0101715:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010171a:	0f 86 cd 00 00 00    	jbe    f01017ed <mem_init+0x17a>
	return (physaddr_t)kva - KERNBASE;
f0101720:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101726:	83 ca 05             	or     $0x5,%edx
f0101729:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f010172f:	a1 88 0e 25 f0       	mov    0xf0250e88,%eax
f0101734:	c1 e0 03             	shl    $0x3,%eax
f0101737:	e8 2f f7 ff ff       	call   f0100e6b <boot_alloc>
f010173c:	a3 90 0e 25 f0       	mov    %eax,0xf0250e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101741:	83 ec 04             	sub    $0x4,%esp
f0101744:	8b 0d 88 0e 25 f0    	mov    0xf0250e88,%ecx
f010174a:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101751:	52                   	push   %edx
f0101752:	6a 00                	push   $0x0
f0101754:	50                   	push   %eax
f0101755:	e8 a3 44 00 00       	call   f0105bfd <memset>
	cprintf("pages: %x\n", PADDR(pages));
f010175a:	a1 90 0e 25 f0       	mov    0xf0250e90,%eax
	if ((uint32_t)kva < KERNBASE)
f010175f:	83 c4 10             	add    $0x10,%esp
f0101762:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101767:	0f 86 95 00 00 00    	jbe    f0101802 <mem_init+0x18f>
f010176d:	83 ec 08             	sub    $0x8,%esp
	return (physaddr_t)kva - KERNBASE;
f0101770:	05 00 00 00 10       	add    $0x10000000,%eax
f0101775:	50                   	push   %eax
f0101776:	68 50 7b 10 f0       	push   $0xf0107b50
f010177b:	e8 55 25 00 00       	call   f0103cd5 <cprintf>
	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101780:	b8 00 00 02 00       	mov    $0x20000,%eax
f0101785:	e8 e1 f6 ff ff       	call   f0100e6b <boot_alloc>
f010178a:	a3 44 02 25 f0       	mov    %eax,0xf0250244
	memset(envs, 0, NENV * sizeof(struct Env));
f010178f:	83 c4 0c             	add    $0xc,%esp
f0101792:	68 00 00 02 00       	push   $0x20000
f0101797:	6a 00                	push   $0x0
f0101799:	50                   	push   %eax
f010179a:	e8 5e 44 00 00       	call   f0105bfd <memset>
	page_init();
f010179f:	e8 40 fa ff ff       	call   f01011e4 <page_init>
	check_page_free_list(1);
f01017a4:	b8 01 00 00 00       	mov    $0x1,%eax
f01017a9:	e8 48 f7 ff ff       	call   f0100ef6 <check_page_free_list>
	if (!pages)
f01017ae:	83 c4 10             	add    $0x10,%esp
f01017b1:	83 3d 90 0e 25 f0 00 	cmpl   $0x0,0xf0250e90
f01017b8:	74 5d                	je     f0101817 <mem_init+0x1a4>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01017ba:	a1 40 02 25 f0       	mov    0xf0250240,%eax
f01017bf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01017c6:	eb 6c                	jmp    f0101834 <mem_init+0x1c1>
		totalmem = 1 * 1024 + extmem;
f01017c8:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01017ce:	85 f6                	test   %esi,%esi
f01017d0:	0f 44 c3             	cmove  %ebx,%eax
f01017d3:	e9 d4 fe ff ff       	jmp    f01016ac <mem_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01017d8:	50                   	push   %eax
f01017d9:	68 f8 68 10 f0       	push   $0xf01068f8
f01017de:	68 99 00 00 00       	push   $0x99
f01017e3:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01017e8:	e8 53 e8 ff ff       	call   f0100040 <_panic>
f01017ed:	50                   	push   %eax
f01017ee:	68 f8 68 10 f0       	push   $0xf01068f8
f01017f3:	68 a5 00 00 00       	push   $0xa5
f01017f8:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01017fd:	e8 3e e8 ff ff       	call   f0100040 <_panic>
f0101802:	50                   	push   %eax
f0101803:	68 f8 68 10 f0       	push   $0xf01068f8
f0101808:	68 b0 00 00 00       	push   $0xb0
f010180d:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101812:	e8 29 e8 ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f0101817:	83 ec 04             	sub    $0x4,%esp
f010181a:	68 5b 7b 10 f0       	push   $0xf0107b5b
f010181f:	68 20 03 00 00       	push   $0x320
f0101824:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101829:	e8 12 e8 ff ff       	call   f0100040 <_panic>
		++nfree;
f010182e:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101832:	8b 00                	mov    (%eax),%eax
f0101834:	85 c0                	test   %eax,%eax
f0101836:	75 f6                	jne    f010182e <mem_init+0x1bb>
	assert((pp0 = page_alloc(0)));
f0101838:	83 ec 0c             	sub    $0xc,%esp
f010183b:	6a 00                	push   $0x0
f010183d:	e8 9c fa ff ff       	call   f01012de <page_alloc>
f0101842:	89 c3                	mov    %eax,%ebx
f0101844:	83 c4 10             	add    $0x10,%esp
f0101847:	85 c0                	test   %eax,%eax
f0101849:	0f 84 00 02 00 00    	je     f0101a4f <mem_init+0x3dc>
	assert((pp1 = page_alloc(0)));
f010184f:	83 ec 0c             	sub    $0xc,%esp
f0101852:	6a 00                	push   $0x0
f0101854:	e8 85 fa ff ff       	call   f01012de <page_alloc>
f0101859:	89 c6                	mov    %eax,%esi
f010185b:	83 c4 10             	add    $0x10,%esp
f010185e:	85 c0                	test   %eax,%eax
f0101860:	0f 84 02 02 00 00    	je     f0101a68 <mem_init+0x3f5>
	assert((pp2 = page_alloc(0)));
f0101866:	83 ec 0c             	sub    $0xc,%esp
f0101869:	6a 00                	push   $0x0
f010186b:	e8 6e fa ff ff       	call   f01012de <page_alloc>
f0101870:	89 c7                	mov    %eax,%edi
f0101872:	83 c4 10             	add    $0x10,%esp
f0101875:	85 c0                	test   %eax,%eax
f0101877:	0f 84 04 02 00 00    	je     f0101a81 <mem_init+0x40e>
	assert(pp1 && pp1 != pp0);
f010187d:	39 f3                	cmp    %esi,%ebx
f010187f:	0f 84 15 02 00 00    	je     f0101a9a <mem_init+0x427>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101885:	39 c3                	cmp    %eax,%ebx
f0101887:	0f 84 26 02 00 00    	je     f0101ab3 <mem_init+0x440>
f010188d:	39 c6                	cmp    %eax,%esi
f010188f:	0f 84 1e 02 00 00    	je     f0101ab3 <mem_init+0x440>
	return (pp - pages) << PGSHIFT;
f0101895:	8b 0d 90 0e 25 f0    	mov    0xf0250e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010189b:	8b 15 88 0e 25 f0    	mov    0xf0250e88,%edx
f01018a1:	c1 e2 0c             	shl    $0xc,%edx
f01018a4:	89 d8                	mov    %ebx,%eax
f01018a6:	29 c8                	sub    %ecx,%eax
f01018a8:	c1 f8 03             	sar    $0x3,%eax
f01018ab:	c1 e0 0c             	shl    $0xc,%eax
f01018ae:	39 d0                	cmp    %edx,%eax
f01018b0:	0f 83 16 02 00 00    	jae    f0101acc <mem_init+0x459>
f01018b6:	89 f0                	mov    %esi,%eax
f01018b8:	29 c8                	sub    %ecx,%eax
f01018ba:	c1 f8 03             	sar    $0x3,%eax
f01018bd:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01018c0:	39 c2                	cmp    %eax,%edx
f01018c2:	0f 86 1d 02 00 00    	jbe    f0101ae5 <mem_init+0x472>
f01018c8:	89 f8                	mov    %edi,%eax
f01018ca:	29 c8                	sub    %ecx,%eax
f01018cc:	c1 f8 03             	sar    $0x3,%eax
f01018cf:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01018d2:	39 c2                	cmp    %eax,%edx
f01018d4:	0f 86 24 02 00 00    	jbe    f0101afe <mem_init+0x48b>
	fl = page_free_list;
f01018da:	a1 40 02 25 f0       	mov    0xf0250240,%eax
f01018df:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018e2:	c7 05 40 02 25 f0 00 	movl   $0x0,0xf0250240
f01018e9:	00 00 00 
	assert(!page_alloc(0));
f01018ec:	83 ec 0c             	sub    $0xc,%esp
f01018ef:	6a 00                	push   $0x0
f01018f1:	e8 e8 f9 ff ff       	call   f01012de <page_alloc>
f01018f6:	83 c4 10             	add    $0x10,%esp
f01018f9:	85 c0                	test   %eax,%eax
f01018fb:	0f 85 16 02 00 00    	jne    f0101b17 <mem_init+0x4a4>
	page_free(pp0);
f0101901:	83 ec 0c             	sub    $0xc,%esp
f0101904:	53                   	push   %ebx
f0101905:	e8 4c fa ff ff       	call   f0101356 <page_free>
	page_free(pp1);
f010190a:	89 34 24             	mov    %esi,(%esp)
f010190d:	e8 44 fa ff ff       	call   f0101356 <page_free>
	page_free(pp2);
f0101912:	89 3c 24             	mov    %edi,(%esp)
f0101915:	e8 3c fa ff ff       	call   f0101356 <page_free>
	assert((pp0 = page_alloc(0)));
f010191a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101921:	e8 b8 f9 ff ff       	call   f01012de <page_alloc>
f0101926:	89 c3                	mov    %eax,%ebx
f0101928:	83 c4 10             	add    $0x10,%esp
f010192b:	85 c0                	test   %eax,%eax
f010192d:	0f 84 fd 01 00 00    	je     f0101b30 <mem_init+0x4bd>
	assert((pp1 = page_alloc(0)));
f0101933:	83 ec 0c             	sub    $0xc,%esp
f0101936:	6a 00                	push   $0x0
f0101938:	e8 a1 f9 ff ff       	call   f01012de <page_alloc>
f010193d:	89 c6                	mov    %eax,%esi
f010193f:	83 c4 10             	add    $0x10,%esp
f0101942:	85 c0                	test   %eax,%eax
f0101944:	0f 84 ff 01 00 00    	je     f0101b49 <mem_init+0x4d6>
	assert((pp2 = page_alloc(0)));
f010194a:	83 ec 0c             	sub    $0xc,%esp
f010194d:	6a 00                	push   $0x0
f010194f:	e8 8a f9 ff ff       	call   f01012de <page_alloc>
f0101954:	89 c7                	mov    %eax,%edi
f0101956:	83 c4 10             	add    $0x10,%esp
f0101959:	85 c0                	test   %eax,%eax
f010195b:	0f 84 01 02 00 00    	je     f0101b62 <mem_init+0x4ef>
	assert(pp1 && pp1 != pp0);
f0101961:	39 f3                	cmp    %esi,%ebx
f0101963:	0f 84 12 02 00 00    	je     f0101b7b <mem_init+0x508>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101969:	39 c6                	cmp    %eax,%esi
f010196b:	0f 84 23 02 00 00    	je     f0101b94 <mem_init+0x521>
f0101971:	39 c3                	cmp    %eax,%ebx
f0101973:	0f 84 1b 02 00 00    	je     f0101b94 <mem_init+0x521>
	assert(!page_alloc(0));
f0101979:	83 ec 0c             	sub    $0xc,%esp
f010197c:	6a 00                	push   $0x0
f010197e:	e8 5b f9 ff ff       	call   f01012de <page_alloc>
f0101983:	83 c4 10             	add    $0x10,%esp
f0101986:	85 c0                	test   %eax,%eax
f0101988:	0f 85 1f 02 00 00    	jne    f0101bad <mem_init+0x53a>
f010198e:	89 d8                	mov    %ebx,%eax
f0101990:	2b 05 90 0e 25 f0    	sub    0xf0250e90,%eax
f0101996:	c1 f8 03             	sar    $0x3,%eax
f0101999:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010199c:	89 c2                	mov    %eax,%edx
f010199e:	c1 ea 0c             	shr    $0xc,%edx
f01019a1:	3b 15 88 0e 25 f0    	cmp    0xf0250e88,%edx
f01019a7:	0f 83 19 02 00 00    	jae    f0101bc6 <mem_init+0x553>
	memset(page2kva(pp0), 1, PGSIZE);
f01019ad:	83 ec 04             	sub    $0x4,%esp
f01019b0:	68 00 10 00 00       	push   $0x1000
f01019b5:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01019b7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01019bc:	50                   	push   %eax
f01019bd:	e8 3b 42 00 00       	call   f0105bfd <memset>
	page_free(pp0);
f01019c2:	89 1c 24             	mov    %ebx,(%esp)
f01019c5:	e8 8c f9 ff ff       	call   f0101356 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01019ca:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01019d1:	e8 08 f9 ff ff       	call   f01012de <page_alloc>
f01019d6:	83 c4 10             	add    $0x10,%esp
f01019d9:	85 c0                	test   %eax,%eax
f01019db:	0f 84 f7 01 00 00    	je     f0101bd8 <mem_init+0x565>
	assert(pp && pp0 == pp);
f01019e1:	39 c3                	cmp    %eax,%ebx
f01019e3:	0f 85 08 02 00 00    	jne    f0101bf1 <mem_init+0x57e>
	return (pp - pages) << PGSHIFT;
f01019e9:	2b 05 90 0e 25 f0    	sub    0xf0250e90,%eax
f01019ef:	c1 f8 03             	sar    $0x3,%eax
f01019f2:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01019f5:	89 c2                	mov    %eax,%edx
f01019f7:	c1 ea 0c             	shr    $0xc,%edx
f01019fa:	3b 15 88 0e 25 f0    	cmp    0xf0250e88,%edx
f0101a00:	0f 83 04 02 00 00    	jae    f0101c0a <mem_init+0x597>
	return (void *)(pa + KERNBASE);
f0101a06:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0101a0c:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
		assert(c[i] == 0);
f0101a11:	80 3a 00             	cmpb   $0x0,(%edx)
f0101a14:	0f 85 02 02 00 00    	jne    f0101c1c <mem_init+0x5a9>
f0101a1a:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < PGSIZE; i++)
f0101a1d:	39 c2                	cmp    %eax,%edx
f0101a1f:	75 f0                	jne    f0101a11 <mem_init+0x39e>
	page_free_list = fl;
f0101a21:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101a24:	a3 40 02 25 f0       	mov    %eax,0xf0250240
	page_free(pp0);
f0101a29:	83 ec 0c             	sub    $0xc,%esp
f0101a2c:	53                   	push   %ebx
f0101a2d:	e8 24 f9 ff ff       	call   f0101356 <page_free>
	page_free(pp1);
f0101a32:	89 34 24             	mov    %esi,(%esp)
f0101a35:	e8 1c f9 ff ff       	call   f0101356 <page_free>
	page_free(pp2);
f0101a3a:	89 3c 24             	mov    %edi,(%esp)
f0101a3d:	e8 14 f9 ff ff       	call   f0101356 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101a42:	a1 40 02 25 f0       	mov    0xf0250240,%eax
f0101a47:	83 c4 10             	add    $0x10,%esp
f0101a4a:	e9 ec 01 00 00       	jmp    f0101c3b <mem_init+0x5c8>
	assert((pp0 = page_alloc(0)));
f0101a4f:	68 76 7b 10 f0       	push   $0xf0107b76
f0101a54:	68 93 7a 10 f0       	push   $0xf0107a93
f0101a59:	68 28 03 00 00       	push   $0x328
f0101a5e:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101a63:	e8 d8 e5 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101a68:	68 8c 7b 10 f0       	push   $0xf0107b8c
f0101a6d:	68 93 7a 10 f0       	push   $0xf0107a93
f0101a72:	68 29 03 00 00       	push   $0x329
f0101a77:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101a7c:	e8 bf e5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101a81:	68 a2 7b 10 f0       	push   $0xf0107ba2
f0101a86:	68 93 7a 10 f0       	push   $0xf0107a93
f0101a8b:	68 2a 03 00 00       	push   $0x32a
f0101a90:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101a95:	e8 a6 e5 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101a9a:	68 b8 7b 10 f0       	push   $0xf0107bb8
f0101a9f:	68 93 7a 10 f0       	push   $0xf0107a93
f0101aa4:	68 2d 03 00 00       	push   $0x32d
f0101aa9:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101aae:	e8 8d e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ab3:	68 64 72 10 f0       	push   $0xf0107264
f0101ab8:	68 93 7a 10 f0       	push   $0xf0107a93
f0101abd:	68 2e 03 00 00       	push   $0x32e
f0101ac2:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101ac7:	e8 74 e5 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101acc:	68 ca 7b 10 f0       	push   $0xf0107bca
f0101ad1:	68 93 7a 10 f0       	push   $0xf0107a93
f0101ad6:	68 2f 03 00 00       	push   $0x32f
f0101adb:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101ae0:	e8 5b e5 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101ae5:	68 e7 7b 10 f0       	push   $0xf0107be7
f0101aea:	68 93 7a 10 f0       	push   $0xf0107a93
f0101aef:	68 30 03 00 00       	push   $0x330
f0101af4:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101af9:	e8 42 e5 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101afe:	68 04 7c 10 f0       	push   $0xf0107c04
f0101b03:	68 93 7a 10 f0       	push   $0xf0107a93
f0101b08:	68 31 03 00 00       	push   $0x331
f0101b0d:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101b12:	e8 29 e5 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101b17:	68 21 7c 10 f0       	push   $0xf0107c21
f0101b1c:	68 93 7a 10 f0       	push   $0xf0107a93
f0101b21:	68 38 03 00 00       	push   $0x338
f0101b26:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101b2b:	e8 10 e5 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0101b30:	68 76 7b 10 f0       	push   $0xf0107b76
f0101b35:	68 93 7a 10 f0       	push   $0xf0107a93
f0101b3a:	68 3f 03 00 00       	push   $0x33f
f0101b3f:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101b44:	e8 f7 e4 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b49:	68 8c 7b 10 f0       	push   $0xf0107b8c
f0101b4e:	68 93 7a 10 f0       	push   $0xf0107a93
f0101b53:	68 40 03 00 00       	push   $0x340
f0101b58:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101b5d:	e8 de e4 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b62:	68 a2 7b 10 f0       	push   $0xf0107ba2
f0101b67:	68 93 7a 10 f0       	push   $0xf0107a93
f0101b6c:	68 41 03 00 00       	push   $0x341
f0101b71:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101b76:	e8 c5 e4 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f0101b7b:	68 b8 7b 10 f0       	push   $0xf0107bb8
f0101b80:	68 93 7a 10 f0       	push   $0xf0107a93
f0101b85:	68 43 03 00 00       	push   $0x343
f0101b8a:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101b8f:	e8 ac e4 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b94:	68 64 72 10 f0       	push   $0xf0107264
f0101b99:	68 93 7a 10 f0       	push   $0xf0107a93
f0101b9e:	68 44 03 00 00       	push   $0x344
f0101ba3:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101ba8:	e8 93 e4 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101bad:	68 21 7c 10 f0       	push   $0xf0107c21
f0101bb2:	68 93 7a 10 f0       	push   $0xf0107a93
f0101bb7:	68 45 03 00 00       	push   $0x345
f0101bbc:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101bc1:	e8 7a e4 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101bc6:	50                   	push   %eax
f0101bc7:	68 d4 68 10 f0       	push   $0xf01068d4
f0101bcc:	6a 58                	push   $0x58
f0101bce:	68 79 7a 10 f0       	push   $0xf0107a79
f0101bd3:	e8 68 e4 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101bd8:	68 30 7c 10 f0       	push   $0xf0107c30
f0101bdd:	68 93 7a 10 f0       	push   $0xf0107a93
f0101be2:	68 4a 03 00 00       	push   $0x34a
f0101be7:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101bec:	e8 4f e4 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101bf1:	68 4e 7c 10 f0       	push   $0xf0107c4e
f0101bf6:	68 93 7a 10 f0       	push   $0xf0107a93
f0101bfb:	68 4b 03 00 00       	push   $0x34b
f0101c00:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101c05:	e8 36 e4 ff ff       	call   f0100040 <_panic>
f0101c0a:	50                   	push   %eax
f0101c0b:	68 d4 68 10 f0       	push   $0xf01068d4
f0101c10:	6a 58                	push   $0x58
f0101c12:	68 79 7a 10 f0       	push   $0xf0107a79
f0101c17:	e8 24 e4 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f0101c1c:	68 5e 7c 10 f0       	push   $0xf0107c5e
f0101c21:	68 93 7a 10 f0       	push   $0xf0107a93
f0101c26:	68 4e 03 00 00       	push   $0x34e
f0101c2b:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0101c30:	e8 0b e4 ff ff       	call   f0100040 <_panic>
		--nfree;
f0101c35:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c39:	8b 00                	mov    (%eax),%eax
f0101c3b:	85 c0                	test   %eax,%eax
f0101c3d:	75 f6                	jne    f0101c35 <mem_init+0x5c2>
	assert(nfree == 0);
f0101c3f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0101c43:	0f 85 30 09 00 00    	jne    f0102579 <mem_init+0xf06>
	cprintf("check_page_alloc() succeeded!\n");
f0101c49:	83 ec 0c             	sub    $0xc,%esp
f0101c4c:	68 84 72 10 f0       	push   $0xf0107284
f0101c51:	e8 7f 20 00 00       	call   f0103cd5 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c5d:	e8 7c f6 ff ff       	call   f01012de <page_alloc>
f0101c62:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101c65:	83 c4 10             	add    $0x10,%esp
f0101c68:	85 c0                	test   %eax,%eax
f0101c6a:	0f 84 22 09 00 00    	je     f0102592 <mem_init+0xf1f>
	assert((pp1 = page_alloc(0)));
f0101c70:	83 ec 0c             	sub    $0xc,%esp
f0101c73:	6a 00                	push   $0x0
f0101c75:	e8 64 f6 ff ff       	call   f01012de <page_alloc>
f0101c7a:	89 c7                	mov    %eax,%edi
f0101c7c:	83 c4 10             	add    $0x10,%esp
f0101c7f:	85 c0                	test   %eax,%eax
f0101c81:	0f 84 24 09 00 00    	je     f01025ab <mem_init+0xf38>
	assert((pp2 = page_alloc(0)));
f0101c87:	83 ec 0c             	sub    $0xc,%esp
f0101c8a:	6a 00                	push   $0x0
f0101c8c:	e8 4d f6 ff ff       	call   f01012de <page_alloc>
f0101c91:	89 c3                	mov    %eax,%ebx
f0101c93:	83 c4 10             	add    $0x10,%esp
f0101c96:	85 c0                	test   %eax,%eax
f0101c98:	0f 84 26 09 00 00    	je     f01025c4 <mem_init+0xf51>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c9e:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0101ca1:	0f 84 36 09 00 00    	je     f01025dd <mem_init+0xf6a>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101ca7:	39 c7                	cmp    %eax,%edi
f0101ca9:	0f 84 47 09 00 00    	je     f01025f6 <mem_init+0xf83>
f0101caf:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101cb2:	0f 84 3e 09 00 00    	je     f01025f6 <mem_init+0xf83>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101cb8:	a1 40 02 25 f0       	mov    0xf0250240,%eax
f0101cbd:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101cc0:	c7 05 40 02 25 f0 00 	movl   $0x0,0xf0250240
f0101cc7:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101cca:	83 ec 0c             	sub    $0xc,%esp
f0101ccd:	6a 00                	push   $0x0
f0101ccf:	e8 0a f6 ff ff       	call   f01012de <page_alloc>
f0101cd4:	83 c4 10             	add    $0x10,%esp
f0101cd7:	85 c0                	test   %eax,%eax
f0101cd9:	0f 85 30 09 00 00    	jne    f010260f <mem_init+0xf9c>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101cdf:	83 ec 04             	sub    $0x4,%esp
f0101ce2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ce5:	50                   	push   %eax
f0101ce6:	6a 00                	push   $0x0
f0101ce8:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0101cee:	e8 b2 f7 ff ff       	call   f01014a5 <page_lookup>
f0101cf3:	83 c4 10             	add    $0x10,%esp
f0101cf6:	85 c0                	test   %eax,%eax
f0101cf8:	0f 85 2a 09 00 00    	jne    f0102628 <mem_init+0xfb5>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101cfe:	6a 02                	push   $0x2
f0101d00:	6a 00                	push   $0x0
f0101d02:	57                   	push   %edi
f0101d03:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0101d09:	e8 85 f8 ff ff       	call   f0101593 <page_insert>
f0101d0e:	83 c4 10             	add    $0x10,%esp
f0101d11:	85 c0                	test   %eax,%eax
f0101d13:	0f 89 28 09 00 00    	jns    f0102641 <mem_init+0xfce>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d19:	83 ec 0c             	sub    $0xc,%esp
f0101d1c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d1f:	e8 32 f6 ff ff       	call   f0101356 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d24:	6a 02                	push   $0x2
f0101d26:	6a 00                	push   $0x0
f0101d28:	57                   	push   %edi
f0101d29:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0101d2f:	e8 5f f8 ff ff       	call   f0101593 <page_insert>
f0101d34:	83 c4 20             	add    $0x20,%esp
f0101d37:	85 c0                	test   %eax,%eax
f0101d39:	0f 85 1b 09 00 00    	jne    f010265a <mem_init+0xfe7>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d3f:	8b 35 8c 0e 25 f0    	mov    0xf0250e8c,%esi
	return (pp - pages) << PGSHIFT;
f0101d45:	8b 0d 90 0e 25 f0    	mov    0xf0250e90,%ecx
f0101d4b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101d4e:	8b 16                	mov    (%esi),%edx
f0101d50:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d59:	29 c8                	sub    %ecx,%eax
f0101d5b:	c1 f8 03             	sar    $0x3,%eax
f0101d5e:	c1 e0 0c             	shl    $0xc,%eax
f0101d61:	39 c2                	cmp    %eax,%edx
f0101d63:	0f 85 0a 09 00 00    	jne    f0102673 <mem_init+0x1000>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d69:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d6e:	89 f0                	mov    %esi,%eax
f0101d70:	e8 92 f0 ff ff       	call   f0100e07 <check_va2pa>
f0101d75:	89 fa                	mov    %edi,%edx
f0101d77:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101d7a:	c1 fa 03             	sar    $0x3,%edx
f0101d7d:	c1 e2 0c             	shl    $0xc,%edx
f0101d80:	39 d0                	cmp    %edx,%eax
f0101d82:	0f 85 04 09 00 00    	jne    f010268c <mem_init+0x1019>
	assert(pp1->pp_ref == 1);
f0101d88:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d8d:	0f 85 12 09 00 00    	jne    f01026a5 <mem_init+0x1032>
	assert(pp0->pp_ref == 1);
f0101d93:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d96:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d9b:	0f 85 1d 09 00 00    	jne    f01026be <mem_init+0x104b>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101da1:	6a 02                	push   $0x2
f0101da3:	68 00 10 00 00       	push   $0x1000
f0101da8:	53                   	push   %ebx
f0101da9:	56                   	push   %esi
f0101daa:	e8 e4 f7 ff ff       	call   f0101593 <page_insert>
f0101daf:	83 c4 10             	add    $0x10,%esp
f0101db2:	85 c0                	test   %eax,%eax
f0101db4:	0f 85 1d 09 00 00    	jne    f01026d7 <mem_init+0x1064>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dba:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dbf:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
f0101dc4:	e8 3e f0 ff ff       	call   f0100e07 <check_va2pa>
f0101dc9:	89 da                	mov    %ebx,%edx
f0101dcb:	2b 15 90 0e 25 f0    	sub    0xf0250e90,%edx
f0101dd1:	c1 fa 03             	sar    $0x3,%edx
f0101dd4:	c1 e2 0c             	shl    $0xc,%edx
f0101dd7:	39 d0                	cmp    %edx,%eax
f0101dd9:	0f 85 11 09 00 00    	jne    f01026f0 <mem_init+0x107d>
	assert(pp2->pp_ref == 1);
f0101ddf:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101de4:	0f 85 1f 09 00 00    	jne    f0102709 <mem_init+0x1096>

	// should be no free memory
	assert(!page_alloc(0));
f0101dea:	83 ec 0c             	sub    $0xc,%esp
f0101ded:	6a 00                	push   $0x0
f0101def:	e8 ea f4 ff ff       	call   f01012de <page_alloc>
f0101df4:	83 c4 10             	add    $0x10,%esp
f0101df7:	85 c0                	test   %eax,%eax
f0101df9:	0f 85 23 09 00 00    	jne    f0102722 <mem_init+0x10af>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101dff:	6a 02                	push   $0x2
f0101e01:	68 00 10 00 00       	push   $0x1000
f0101e06:	53                   	push   %ebx
f0101e07:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0101e0d:	e8 81 f7 ff ff       	call   f0101593 <page_insert>
f0101e12:	83 c4 10             	add    $0x10,%esp
f0101e15:	85 c0                	test   %eax,%eax
f0101e17:	0f 85 1e 09 00 00    	jne    f010273b <mem_init+0x10c8>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e1d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e22:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
f0101e27:	e8 db ef ff ff       	call   f0100e07 <check_va2pa>
f0101e2c:	89 da                	mov    %ebx,%edx
f0101e2e:	2b 15 90 0e 25 f0    	sub    0xf0250e90,%edx
f0101e34:	c1 fa 03             	sar    $0x3,%edx
f0101e37:	c1 e2 0c             	shl    $0xc,%edx
f0101e3a:	39 d0                	cmp    %edx,%eax
f0101e3c:	0f 85 12 09 00 00    	jne    f0102754 <mem_init+0x10e1>
	assert(pp2->pp_ref == 1);
f0101e42:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e47:	0f 85 20 09 00 00    	jne    f010276d <mem_init+0x10fa>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e4d:	83 ec 0c             	sub    $0xc,%esp
f0101e50:	6a 00                	push   $0x0
f0101e52:	e8 87 f4 ff ff       	call   f01012de <page_alloc>
f0101e57:	83 c4 10             	add    $0x10,%esp
f0101e5a:	85 c0                	test   %eax,%eax
f0101e5c:	0f 85 24 09 00 00    	jne    f0102786 <mem_init+0x1113>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e62:	8b 15 8c 0e 25 f0    	mov    0xf0250e8c,%edx
f0101e68:	8b 02                	mov    (%edx),%eax
f0101e6a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101e6f:	89 c1                	mov    %eax,%ecx
f0101e71:	c1 e9 0c             	shr    $0xc,%ecx
f0101e74:	3b 0d 88 0e 25 f0    	cmp    0xf0250e88,%ecx
f0101e7a:	0f 83 1f 09 00 00    	jae    f010279f <mem_init+0x112c>
	return (void *)(pa + KERNBASE);
f0101e80:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e85:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101e88:	83 ec 04             	sub    $0x4,%esp
f0101e8b:	6a 00                	push   $0x0
f0101e8d:	68 00 10 00 00       	push   $0x1000
f0101e92:	52                   	push   %edx
f0101e93:	e8 22 f5 ff ff       	call   f01013ba <pgdir_walk>
f0101e98:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101e9b:	8d 51 04             	lea    0x4(%ecx),%edx
f0101e9e:	83 c4 10             	add    $0x10,%esp
f0101ea1:	39 d0                	cmp    %edx,%eax
f0101ea3:	0f 85 0b 09 00 00    	jne    f01027b4 <mem_init+0x1141>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ea9:	6a 06                	push   $0x6
f0101eab:	68 00 10 00 00       	push   $0x1000
f0101eb0:	53                   	push   %ebx
f0101eb1:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0101eb7:	e8 d7 f6 ff ff       	call   f0101593 <page_insert>
f0101ebc:	83 c4 10             	add    $0x10,%esp
f0101ebf:	85 c0                	test   %eax,%eax
f0101ec1:	0f 85 06 09 00 00    	jne    f01027cd <mem_init+0x115a>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ec7:	8b 35 8c 0e 25 f0    	mov    0xf0250e8c,%esi
f0101ecd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ed2:	89 f0                	mov    %esi,%eax
f0101ed4:	e8 2e ef ff ff       	call   f0100e07 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101ed9:	89 da                	mov    %ebx,%edx
f0101edb:	2b 15 90 0e 25 f0    	sub    0xf0250e90,%edx
f0101ee1:	c1 fa 03             	sar    $0x3,%edx
f0101ee4:	c1 e2 0c             	shl    $0xc,%edx
f0101ee7:	39 d0                	cmp    %edx,%eax
f0101ee9:	0f 85 f7 08 00 00    	jne    f01027e6 <mem_init+0x1173>
	assert(pp2->pp_ref == 1);
f0101eef:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ef4:	0f 85 05 09 00 00    	jne    f01027ff <mem_init+0x118c>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101efa:	83 ec 04             	sub    $0x4,%esp
f0101efd:	6a 00                	push   $0x0
f0101eff:	68 00 10 00 00       	push   $0x1000
f0101f04:	56                   	push   %esi
f0101f05:	e8 b0 f4 ff ff       	call   f01013ba <pgdir_walk>
f0101f0a:	83 c4 10             	add    $0x10,%esp
f0101f0d:	f6 00 04             	testb  $0x4,(%eax)
f0101f10:	0f 84 02 09 00 00    	je     f0102818 <mem_init+0x11a5>
	assert(kern_pgdir[0] & PTE_U);
f0101f16:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
f0101f1b:	f6 00 04             	testb  $0x4,(%eax)
f0101f1e:	0f 84 0d 09 00 00    	je     f0102831 <mem_init+0x11be>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f24:	6a 02                	push   $0x2
f0101f26:	68 00 10 00 00       	push   $0x1000
f0101f2b:	53                   	push   %ebx
f0101f2c:	50                   	push   %eax
f0101f2d:	e8 61 f6 ff ff       	call   f0101593 <page_insert>
f0101f32:	83 c4 10             	add    $0x10,%esp
f0101f35:	85 c0                	test   %eax,%eax
f0101f37:	0f 85 0d 09 00 00    	jne    f010284a <mem_init+0x11d7>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101f3d:	83 ec 04             	sub    $0x4,%esp
f0101f40:	6a 00                	push   $0x0
f0101f42:	68 00 10 00 00       	push   $0x1000
f0101f47:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0101f4d:	e8 68 f4 ff ff       	call   f01013ba <pgdir_walk>
f0101f52:	83 c4 10             	add    $0x10,%esp
f0101f55:	f6 00 02             	testb  $0x2,(%eax)
f0101f58:	0f 84 05 09 00 00    	je     f0102863 <mem_init+0x11f0>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f5e:	83 ec 04             	sub    $0x4,%esp
f0101f61:	6a 00                	push   $0x0
f0101f63:	68 00 10 00 00       	push   $0x1000
f0101f68:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0101f6e:	e8 47 f4 ff ff       	call   f01013ba <pgdir_walk>
f0101f73:	83 c4 10             	add    $0x10,%esp
f0101f76:	f6 00 04             	testb  $0x4,(%eax)
f0101f79:	0f 85 fd 08 00 00    	jne    f010287c <mem_init+0x1209>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f7f:	6a 02                	push   $0x2
f0101f81:	68 00 00 40 00       	push   $0x400000
f0101f86:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f89:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0101f8f:	e8 ff f5 ff ff       	call   f0101593 <page_insert>
f0101f94:	83 c4 10             	add    $0x10,%esp
f0101f97:	85 c0                	test   %eax,%eax
f0101f99:	0f 89 f6 08 00 00    	jns    f0102895 <mem_init+0x1222>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f9f:	6a 02                	push   $0x2
f0101fa1:	68 00 10 00 00       	push   $0x1000
f0101fa6:	57                   	push   %edi
f0101fa7:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0101fad:	e8 e1 f5 ff ff       	call   f0101593 <page_insert>
f0101fb2:	83 c4 10             	add    $0x10,%esp
f0101fb5:	85 c0                	test   %eax,%eax
f0101fb7:	0f 85 f1 08 00 00    	jne    f01028ae <mem_init+0x123b>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fbd:	83 ec 04             	sub    $0x4,%esp
f0101fc0:	6a 00                	push   $0x0
f0101fc2:	68 00 10 00 00       	push   $0x1000
f0101fc7:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0101fcd:	e8 e8 f3 ff ff       	call   f01013ba <pgdir_walk>
f0101fd2:	83 c4 10             	add    $0x10,%esp
f0101fd5:	f6 00 04             	testb  $0x4,(%eax)
f0101fd8:	0f 85 e9 08 00 00    	jne    f01028c7 <mem_init+0x1254>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101fde:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
f0101fe3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101fe6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101feb:	e8 17 ee ff ff       	call   f0100e07 <check_va2pa>
f0101ff0:	89 fe                	mov    %edi,%esi
f0101ff2:	2b 35 90 0e 25 f0    	sub    0xf0250e90,%esi
f0101ff8:	c1 fe 03             	sar    $0x3,%esi
f0101ffb:	c1 e6 0c             	shl    $0xc,%esi
f0101ffe:	39 f0                	cmp    %esi,%eax
f0102000:	0f 85 da 08 00 00    	jne    f01028e0 <mem_init+0x126d>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102006:	ba 00 10 00 00       	mov    $0x1000,%edx
f010200b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010200e:	e8 f4 ed ff ff       	call   f0100e07 <check_va2pa>
f0102013:	39 c6                	cmp    %eax,%esi
f0102015:	0f 85 de 08 00 00    	jne    f01028f9 <mem_init+0x1286>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010201b:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102020:	0f 85 ec 08 00 00    	jne    f0102912 <mem_init+0x129f>
	assert(pp2->pp_ref == 0);
f0102026:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010202b:	0f 85 fa 08 00 00    	jne    f010292b <mem_init+0x12b8>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102031:	83 ec 0c             	sub    $0xc,%esp
f0102034:	6a 00                	push   $0x0
f0102036:	e8 a3 f2 ff ff       	call   f01012de <page_alloc>
f010203b:	83 c4 10             	add    $0x10,%esp
f010203e:	39 c3                	cmp    %eax,%ebx
f0102040:	0f 85 fe 08 00 00    	jne    f0102944 <mem_init+0x12d1>
f0102046:	85 c0                	test   %eax,%eax
f0102048:	0f 84 f6 08 00 00    	je     f0102944 <mem_init+0x12d1>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010204e:	83 ec 08             	sub    $0x8,%esp
f0102051:	6a 00                	push   $0x0
f0102053:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0102059:	e8 e2 f4 ff ff       	call   f0101540 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010205e:	8b 35 8c 0e 25 f0    	mov    0xf0250e8c,%esi
f0102064:	ba 00 00 00 00       	mov    $0x0,%edx
f0102069:	89 f0                	mov    %esi,%eax
f010206b:	e8 97 ed ff ff       	call   f0100e07 <check_va2pa>
f0102070:	83 c4 10             	add    $0x10,%esp
f0102073:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102076:	0f 85 e1 08 00 00    	jne    f010295d <mem_init+0x12ea>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010207c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102081:	89 f0                	mov    %esi,%eax
f0102083:	e8 7f ed ff ff       	call   f0100e07 <check_va2pa>
f0102088:	89 fa                	mov    %edi,%edx
f010208a:	2b 15 90 0e 25 f0    	sub    0xf0250e90,%edx
f0102090:	c1 fa 03             	sar    $0x3,%edx
f0102093:	c1 e2 0c             	shl    $0xc,%edx
f0102096:	39 d0                	cmp    %edx,%eax
f0102098:	0f 85 d8 08 00 00    	jne    f0102976 <mem_init+0x1303>
	assert(pp1->pp_ref == 1);
f010209e:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01020a3:	0f 85 e6 08 00 00    	jne    f010298f <mem_init+0x131c>
	assert(pp2->pp_ref == 0);
f01020a9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020ae:	0f 85 f4 08 00 00    	jne    f01029a8 <mem_init+0x1335>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01020b4:	6a 00                	push   $0x0
f01020b6:	68 00 10 00 00       	push   $0x1000
f01020bb:	57                   	push   %edi
f01020bc:	56                   	push   %esi
f01020bd:	e8 d1 f4 ff ff       	call   f0101593 <page_insert>
f01020c2:	83 c4 10             	add    $0x10,%esp
f01020c5:	85 c0                	test   %eax,%eax
f01020c7:	0f 85 f4 08 00 00    	jne    f01029c1 <mem_init+0x134e>
	assert(pp1->pp_ref);
f01020cd:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01020d2:	0f 84 02 09 00 00    	je     f01029da <mem_init+0x1367>
	assert(pp1->pp_link == NULL);
f01020d8:	83 3f 00             	cmpl   $0x0,(%edi)
f01020db:	0f 85 12 09 00 00    	jne    f01029f3 <mem_init+0x1380>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01020e1:	83 ec 08             	sub    $0x8,%esp
f01020e4:	68 00 10 00 00       	push   $0x1000
f01020e9:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f01020ef:	e8 4c f4 ff ff       	call   f0101540 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020f4:	8b 35 8c 0e 25 f0    	mov    0xf0250e8c,%esi
f01020fa:	ba 00 00 00 00       	mov    $0x0,%edx
f01020ff:	89 f0                	mov    %esi,%eax
f0102101:	e8 01 ed ff ff       	call   f0100e07 <check_va2pa>
f0102106:	83 c4 10             	add    $0x10,%esp
f0102109:	83 f8 ff             	cmp    $0xffffffff,%eax
f010210c:	0f 85 fa 08 00 00    	jne    f0102a0c <mem_init+0x1399>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102112:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102117:	89 f0                	mov    %esi,%eax
f0102119:	e8 e9 ec ff ff       	call   f0100e07 <check_va2pa>
f010211e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102121:	0f 85 fe 08 00 00    	jne    f0102a25 <mem_init+0x13b2>
	assert(pp1->pp_ref == 0);
f0102127:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010212c:	0f 85 0c 09 00 00    	jne    f0102a3e <mem_init+0x13cb>
	assert(pp2->pp_ref == 0);
f0102132:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102137:	0f 85 1a 09 00 00    	jne    f0102a57 <mem_init+0x13e4>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010213d:	83 ec 0c             	sub    $0xc,%esp
f0102140:	6a 00                	push   $0x0
f0102142:	e8 97 f1 ff ff       	call   f01012de <page_alloc>
f0102147:	83 c4 10             	add    $0x10,%esp
f010214a:	85 c0                	test   %eax,%eax
f010214c:	0f 84 1e 09 00 00    	je     f0102a70 <mem_init+0x13fd>
f0102152:	39 c7                	cmp    %eax,%edi
f0102154:	0f 85 16 09 00 00    	jne    f0102a70 <mem_init+0x13fd>

	// should be no free memory
	assert(!page_alloc(0));
f010215a:	83 ec 0c             	sub    $0xc,%esp
f010215d:	6a 00                	push   $0x0
f010215f:	e8 7a f1 ff ff       	call   f01012de <page_alloc>
f0102164:	83 c4 10             	add    $0x10,%esp
f0102167:	85 c0                	test   %eax,%eax
f0102169:	0f 85 1a 09 00 00    	jne    f0102a89 <mem_init+0x1416>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010216f:	8b 0d 8c 0e 25 f0    	mov    0xf0250e8c,%ecx
f0102175:	8b 11                	mov    (%ecx),%edx
f0102177:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010217d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102180:	2b 05 90 0e 25 f0    	sub    0xf0250e90,%eax
f0102186:	c1 f8 03             	sar    $0x3,%eax
f0102189:	c1 e0 0c             	shl    $0xc,%eax
f010218c:	39 c2                	cmp    %eax,%edx
f010218e:	0f 85 0e 09 00 00    	jne    f0102aa2 <mem_init+0x142f>
	kern_pgdir[0] = 0;
f0102194:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010219a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010219d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01021a2:	0f 85 13 09 00 00    	jne    f0102abb <mem_init+0x1448>
	pp0->pp_ref = 0;
f01021a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021ab:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01021b1:	83 ec 0c             	sub    $0xc,%esp
f01021b4:	50                   	push   %eax
f01021b5:	e8 9c f1 ff ff       	call   f0101356 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01021ba:	83 c4 0c             	add    $0xc,%esp
f01021bd:	6a 01                	push   $0x1
f01021bf:	68 00 10 40 00       	push   $0x401000
f01021c4:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f01021ca:	e8 eb f1 ff ff       	call   f01013ba <pgdir_walk>
f01021cf:	89 c1                	mov    %eax,%ecx
f01021d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01021d4:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
f01021d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01021dc:	8b 40 04             	mov    0x4(%eax),%eax
f01021df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01021e4:	8b 35 88 0e 25 f0    	mov    0xf0250e88,%esi
f01021ea:	89 c2                	mov    %eax,%edx
f01021ec:	c1 ea 0c             	shr    $0xc,%edx
f01021ef:	83 c4 10             	add    $0x10,%esp
f01021f2:	39 f2                	cmp    %esi,%edx
f01021f4:	0f 83 da 08 00 00    	jae    f0102ad4 <mem_init+0x1461>
	assert(ptep == ptep1 + PTX(va));
f01021fa:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01021ff:	39 c1                	cmp    %eax,%ecx
f0102201:	0f 85 e2 08 00 00    	jne    f0102ae9 <mem_init+0x1476>
	kern_pgdir[PDX(va)] = 0;
f0102207:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010220a:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102211:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102214:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010221a:	2b 05 90 0e 25 f0    	sub    0xf0250e90,%eax
f0102220:	c1 f8 03             	sar    $0x3,%eax
f0102223:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102226:	89 c2                	mov    %eax,%edx
f0102228:	c1 ea 0c             	shr    $0xc,%edx
f010222b:	39 d6                	cmp    %edx,%esi
f010222d:	0f 86 cf 08 00 00    	jbe    f0102b02 <mem_init+0x148f>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102233:	83 ec 04             	sub    $0x4,%esp
f0102236:	68 00 10 00 00       	push   $0x1000
f010223b:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102240:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102245:	50                   	push   %eax
f0102246:	e8 b2 39 00 00       	call   f0105bfd <memset>
	page_free(pp0);
f010224b:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f010224e:	89 34 24             	mov    %esi,(%esp)
f0102251:	e8 00 f1 ff ff       	call   f0101356 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102256:	83 c4 0c             	add    $0xc,%esp
f0102259:	6a 01                	push   $0x1
f010225b:	6a 00                	push   $0x0
f010225d:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0102263:	e8 52 f1 ff ff       	call   f01013ba <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0102268:	89 f0                	mov    %esi,%eax
f010226a:	2b 05 90 0e 25 f0    	sub    0xf0250e90,%eax
f0102270:	c1 f8 03             	sar    $0x3,%eax
f0102273:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102276:	89 c2                	mov    %eax,%edx
f0102278:	c1 ea 0c             	shr    $0xc,%edx
f010227b:	83 c4 10             	add    $0x10,%esp
f010227e:	3b 15 88 0e 25 f0    	cmp    0xf0250e88,%edx
f0102284:	0f 83 8a 08 00 00    	jae    f0102b14 <mem_init+0x14a1>
	return (void *)(pa + KERNBASE);
f010228a:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
	ptep = (pte_t *) page2kva(pp0);
f0102290:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102293:	2d 00 f0 ff 0f       	sub    $0xffff000,%eax
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102298:	f6 02 01             	testb  $0x1,(%edx)
f010229b:	0f 85 85 08 00 00    	jne    f0102b26 <mem_init+0x14b3>
f01022a1:	83 c2 04             	add    $0x4,%edx
	for(i=0; i<NPTENTRIES; i++)
f01022a4:	39 c2                	cmp    %eax,%edx
f01022a6:	75 f0                	jne    f0102298 <mem_init+0xc25>
	kern_pgdir[0] = 0;
f01022a8:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
f01022ad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01022b3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022b6:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01022bc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01022bf:	89 0d 40 02 25 f0    	mov    %ecx,0xf0250240

	// free the pages we took
	page_free(pp0);
f01022c5:	83 ec 0c             	sub    $0xc,%esp
f01022c8:	50                   	push   %eax
f01022c9:	e8 88 f0 ff ff       	call   f0101356 <page_free>
	page_free(pp1);
f01022ce:	89 3c 24             	mov    %edi,(%esp)
f01022d1:	e8 80 f0 ff ff       	call   f0101356 <page_free>
	page_free(pp2);
f01022d6:	89 1c 24             	mov    %ebx,(%esp)
f01022d9:	e8 78 f0 ff ff       	call   f0101356 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01022de:	83 c4 08             	add    $0x8,%esp
f01022e1:	68 01 10 00 00       	push   $0x1001
f01022e6:	6a 00                	push   $0x0
f01022e8:	e8 0c f3 ff ff       	call   f01015f9 <mmio_map_region>
f01022ed:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01022ef:	83 c4 08             	add    $0x8,%esp
f01022f2:	68 00 10 00 00       	push   $0x1000
f01022f7:	6a 00                	push   $0x0
f01022f9:	e8 fb f2 ff ff       	call   f01015f9 <mmio_map_region>
f01022fe:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102300:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0102306:	83 c4 10             	add    $0x10,%esp
f0102309:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010230f:	0f 86 2a 08 00 00    	jbe    f0102b3f <mem_init+0x14cc>
f0102315:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010231a:	0f 87 1f 08 00 00    	ja     f0102b3f <mem_init+0x14cc>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102320:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0102326:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010232c:	0f 87 26 08 00 00    	ja     f0102b58 <mem_init+0x14e5>
f0102332:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102338:	0f 86 1a 08 00 00    	jbe    f0102b58 <mem_init+0x14e5>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010233e:	89 da                	mov    %ebx,%edx
f0102340:	09 f2                	or     %esi,%edx
f0102342:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102348:	0f 85 23 08 00 00    	jne    f0102b71 <mem_init+0x14fe>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f010234e:	39 c6                	cmp    %eax,%esi
f0102350:	0f 82 34 08 00 00    	jb     f0102b8a <mem_init+0x1517>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102356:	8b 3d 8c 0e 25 f0    	mov    0xf0250e8c,%edi
f010235c:	89 da                	mov    %ebx,%edx
f010235e:	89 f8                	mov    %edi,%eax
f0102360:	e8 a2 ea ff ff       	call   f0100e07 <check_va2pa>
f0102365:	85 c0                	test   %eax,%eax
f0102367:	0f 85 36 08 00 00    	jne    f0102ba3 <mem_init+0x1530>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010236d:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102373:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102376:	89 c2                	mov    %eax,%edx
f0102378:	89 f8                	mov    %edi,%eax
f010237a:	e8 88 ea ff ff       	call   f0100e07 <check_va2pa>
f010237f:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102384:	0f 85 32 08 00 00    	jne    f0102bbc <mem_init+0x1549>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010238a:	89 f2                	mov    %esi,%edx
f010238c:	89 f8                	mov    %edi,%eax
f010238e:	e8 74 ea ff ff       	call   f0100e07 <check_va2pa>
f0102393:	85 c0                	test   %eax,%eax
f0102395:	0f 85 3a 08 00 00    	jne    f0102bd5 <mem_init+0x1562>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010239b:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01023a1:	89 f8                	mov    %edi,%eax
f01023a3:	e8 5f ea ff ff       	call   f0100e07 <check_va2pa>
f01023a8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023ab:	0f 85 3d 08 00 00    	jne    f0102bee <mem_init+0x157b>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01023b1:	83 ec 04             	sub    $0x4,%esp
f01023b4:	6a 00                	push   $0x0
f01023b6:	53                   	push   %ebx
f01023b7:	57                   	push   %edi
f01023b8:	e8 fd ef ff ff       	call   f01013ba <pgdir_walk>
f01023bd:	83 c4 10             	add    $0x10,%esp
f01023c0:	f6 00 1a             	testb  $0x1a,(%eax)
f01023c3:	0f 84 3e 08 00 00    	je     f0102c07 <mem_init+0x1594>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01023c9:	83 ec 04             	sub    $0x4,%esp
f01023cc:	6a 00                	push   $0x0
f01023ce:	53                   	push   %ebx
f01023cf:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f01023d5:	e8 e0 ef ff ff       	call   f01013ba <pgdir_walk>
f01023da:	83 c4 10             	add    $0x10,%esp
f01023dd:	f6 00 04             	testb  $0x4,(%eax)
f01023e0:	0f 85 3a 08 00 00    	jne    f0102c20 <mem_init+0x15ad>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01023e6:	83 ec 04             	sub    $0x4,%esp
f01023e9:	6a 00                	push   $0x0
f01023eb:	53                   	push   %ebx
f01023ec:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f01023f2:	e8 c3 ef ff ff       	call   f01013ba <pgdir_walk>
f01023f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f01023fd:	83 c4 0c             	add    $0xc,%esp
f0102400:	6a 00                	push   $0x0
f0102402:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102405:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f010240b:	e8 aa ef ff ff       	call   f01013ba <pgdir_walk>
f0102410:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102416:	83 c4 0c             	add    $0xc,%esp
f0102419:	6a 00                	push   $0x0
f010241b:	56                   	push   %esi
f010241c:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0102422:	e8 93 ef ff ff       	call   f01013ba <pgdir_walk>
f0102427:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010242d:	c7 04 24 51 7d 10 f0 	movl   $0xf0107d51,(%esp)
f0102434:	e8 9c 18 00 00       	call   f0103cd5 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f0102439:	a1 90 0e 25 f0       	mov    0xf0250e90,%eax
	if ((uint32_t)kva < KERNBASE)
f010243e:	83 c4 10             	add    $0x10,%esp
f0102441:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102446:	0f 86 ed 07 00 00    	jbe    f0102c39 <mem_init+0x15c6>
f010244c:	83 ec 08             	sub    $0x8,%esp
f010244f:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102451:	05 00 00 00 10       	add    $0x10000000,%eax
f0102456:	50                   	push   %eax
f0102457:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010245c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102461:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
f0102466:	e8 f1 ef ff ff       	call   f010145c <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f010246b:	a1 44 02 25 f0       	mov    0xf0250244,%eax
	if ((uint32_t)kva < KERNBASE)
f0102470:	83 c4 10             	add    $0x10,%esp
f0102473:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102478:	0f 86 d0 07 00 00    	jbe    f0102c4e <mem_init+0x15db>
f010247e:	83 ec 08             	sub    $0x8,%esp
f0102481:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102483:	05 00 00 00 10       	add    $0x10000000,%eax
f0102488:	50                   	push   %eax
f0102489:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010248e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102493:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
f0102498:	e8 bf ef ff ff       	call   f010145c <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0x10000000, 0, PTE_W);
f010249d:	83 c4 08             	add    $0x8,%esp
f01024a0:	6a 02                	push   $0x2
f01024a2:	6a 00                	push   $0x0
f01024a4:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01024a9:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01024ae:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
f01024b3:	e8 a4 ef ff ff       	call   f010145c <boot_map_region>
f01024b8:	c7 45 d0 00 20 25 f0 	movl   $0xf0252000,-0x30(%ebp)
f01024bf:	83 c4 10             	add    $0x10,%esp
f01024c2:	bb 00 20 25 f0       	mov    $0xf0252000,%ebx
f01024c7:	be 00 80 ff ef       	mov    $0xefff8000,%esi
	if ((uint32_t)kva < KERNBASE)
f01024cc:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01024d2:	0f 86 8b 07 00 00    	jbe    f0102c63 <mem_init+0x15f0>
		boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE - i * (KSTKSIZE + KSTKGAP), 
f01024d8:	83 ec 08             	sub    $0x8,%esp
f01024db:	6a 02                	push   $0x2
f01024dd:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01024e3:	50                   	push   %eax
f01024e4:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01024e9:	89 f2                	mov    %esi,%edx
f01024eb:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
f01024f0:	e8 67 ef ff ff       	call   f010145c <boot_map_region>
f01024f5:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01024fb:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for (uintptr_t i = 0; i < NCPU; i++) {
f0102501:	83 c4 10             	add    $0x10,%esp
f0102504:	81 fb 00 20 29 f0    	cmp    $0xf0292000,%ebx
f010250a:	75 c0                	jne    f01024cc <mem_init+0xe59>
	pgdir = kern_pgdir;
f010250c:	8b 3d 8c 0e 25 f0    	mov    0xf0250e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102512:	a1 88 0e 25 f0       	mov    0xf0250e88,%eax
f0102517:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010251a:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102521:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102526:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102529:	8b 35 90 0e 25 f0    	mov    0xf0250e90,%esi
f010252f:	89 75 cc             	mov    %esi,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102532:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0102538:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f010253b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102540:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102543:	0f 86 5d 07 00 00    	jbe    f0102ca6 <mem_init+0x1633>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102549:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f010254f:	89 f8                	mov    %edi,%eax
f0102551:	e8 b1 e8 ff ff       	call   f0100e07 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102556:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f010255d:	0f 86 15 07 00 00    	jbe    f0102c78 <mem_init+0x1605>
f0102563:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102566:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f0102569:	39 d0                	cmp    %edx,%eax
f010256b:	0f 85 1c 07 00 00    	jne    f0102c8d <mem_init+0x161a>
	for (i = 0; i < n; i += PGSIZE)
f0102571:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102577:	eb c7                	jmp    f0102540 <mem_init+0xecd>
	assert(nfree == 0);
f0102579:	68 68 7c 10 f0       	push   $0xf0107c68
f010257e:	68 93 7a 10 f0       	push   $0xf0107a93
f0102583:	68 5b 03 00 00       	push   $0x35b
f0102588:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010258d:	e8 ae da ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102592:	68 76 7b 10 f0       	push   $0xf0107b76
f0102597:	68 93 7a 10 f0       	push   $0xf0107a93
f010259c:	68 d0 03 00 00       	push   $0x3d0
f01025a1:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01025a6:	e8 95 da ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01025ab:	68 8c 7b 10 f0       	push   $0xf0107b8c
f01025b0:	68 93 7a 10 f0       	push   $0xf0107a93
f01025b5:	68 d1 03 00 00       	push   $0x3d1
f01025ba:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01025bf:	e8 7c da ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01025c4:	68 a2 7b 10 f0       	push   $0xf0107ba2
f01025c9:	68 93 7a 10 f0       	push   $0xf0107a93
f01025ce:	68 d2 03 00 00       	push   $0x3d2
f01025d3:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01025d8:	e8 63 da ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01025dd:	68 b8 7b 10 f0       	push   $0xf0107bb8
f01025e2:	68 93 7a 10 f0       	push   $0xf0107a93
f01025e7:	68 d5 03 00 00       	push   $0x3d5
f01025ec:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01025f1:	e8 4a da ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01025f6:	68 64 72 10 f0       	push   $0xf0107264
f01025fb:	68 93 7a 10 f0       	push   $0xf0107a93
f0102600:	68 d6 03 00 00       	push   $0x3d6
f0102605:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010260a:	e8 31 da ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010260f:	68 21 7c 10 f0       	push   $0xf0107c21
f0102614:	68 93 7a 10 f0       	push   $0xf0107a93
f0102619:	68 dd 03 00 00       	push   $0x3dd
f010261e:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102623:	e8 18 da ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102628:	68 a4 72 10 f0       	push   $0xf01072a4
f010262d:	68 93 7a 10 f0       	push   $0xf0107a93
f0102632:	68 e0 03 00 00       	push   $0x3e0
f0102637:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010263c:	e8 ff d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102641:	68 dc 72 10 f0       	push   $0xf01072dc
f0102646:	68 93 7a 10 f0       	push   $0xf0107a93
f010264b:	68 e3 03 00 00       	push   $0x3e3
f0102650:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102655:	e8 e6 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010265a:	68 0c 73 10 f0       	push   $0xf010730c
f010265f:	68 93 7a 10 f0       	push   $0xf0107a93
f0102664:	68 e7 03 00 00       	push   $0x3e7
f0102669:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010266e:	e8 cd d9 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102673:	68 3c 73 10 f0       	push   $0xf010733c
f0102678:	68 93 7a 10 f0       	push   $0xf0107a93
f010267d:	68 e8 03 00 00       	push   $0x3e8
f0102682:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102687:	e8 b4 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010268c:	68 64 73 10 f0       	push   $0xf0107364
f0102691:	68 93 7a 10 f0       	push   $0xf0107a93
f0102696:	68 e9 03 00 00       	push   $0x3e9
f010269b:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01026a0:	e8 9b d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01026a5:	68 73 7c 10 f0       	push   $0xf0107c73
f01026aa:	68 93 7a 10 f0       	push   $0xf0107a93
f01026af:	68 ea 03 00 00       	push   $0x3ea
f01026b4:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01026b9:	e8 82 d9 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01026be:	68 84 7c 10 f0       	push   $0xf0107c84
f01026c3:	68 93 7a 10 f0       	push   $0xf0107a93
f01026c8:	68 eb 03 00 00       	push   $0x3eb
f01026cd:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01026d2:	e8 69 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01026d7:	68 94 73 10 f0       	push   $0xf0107394
f01026dc:	68 93 7a 10 f0       	push   $0xf0107a93
f01026e1:	68 ee 03 00 00       	push   $0x3ee
f01026e6:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01026eb:	e8 50 d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01026f0:	68 d0 73 10 f0       	push   $0xf01073d0
f01026f5:	68 93 7a 10 f0       	push   $0xf0107a93
f01026fa:	68 ef 03 00 00       	push   $0x3ef
f01026ff:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102704:	e8 37 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102709:	68 95 7c 10 f0       	push   $0xf0107c95
f010270e:	68 93 7a 10 f0       	push   $0xf0107a93
f0102713:	68 f0 03 00 00       	push   $0x3f0
f0102718:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010271d:	e8 1e d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102722:	68 21 7c 10 f0       	push   $0xf0107c21
f0102727:	68 93 7a 10 f0       	push   $0xf0107a93
f010272c:	68 f3 03 00 00       	push   $0x3f3
f0102731:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102736:	e8 05 d9 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010273b:	68 94 73 10 f0       	push   $0xf0107394
f0102740:	68 93 7a 10 f0       	push   $0xf0107a93
f0102745:	68 f6 03 00 00       	push   $0x3f6
f010274a:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010274f:	e8 ec d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102754:	68 d0 73 10 f0       	push   $0xf01073d0
f0102759:	68 93 7a 10 f0       	push   $0xf0107a93
f010275e:	68 f7 03 00 00       	push   $0x3f7
f0102763:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102768:	e8 d3 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010276d:	68 95 7c 10 f0       	push   $0xf0107c95
f0102772:	68 93 7a 10 f0       	push   $0xf0107a93
f0102777:	68 f8 03 00 00       	push   $0x3f8
f010277c:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102781:	e8 ba d8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102786:	68 21 7c 10 f0       	push   $0xf0107c21
f010278b:	68 93 7a 10 f0       	push   $0xf0107a93
f0102790:	68 fc 03 00 00       	push   $0x3fc
f0102795:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010279a:	e8 a1 d8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010279f:	50                   	push   %eax
f01027a0:	68 d4 68 10 f0       	push   $0xf01068d4
f01027a5:	68 ff 03 00 00       	push   $0x3ff
f01027aa:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01027af:	e8 8c d8 ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01027b4:	68 00 74 10 f0       	push   $0xf0107400
f01027b9:	68 93 7a 10 f0       	push   $0xf0107a93
f01027be:	68 00 04 00 00       	push   $0x400
f01027c3:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01027c8:	e8 73 d8 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01027cd:	68 40 74 10 f0       	push   $0xf0107440
f01027d2:	68 93 7a 10 f0       	push   $0xf0107a93
f01027d7:	68 03 04 00 00       	push   $0x403
f01027dc:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01027e1:	e8 5a d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01027e6:	68 d0 73 10 f0       	push   $0xf01073d0
f01027eb:	68 93 7a 10 f0       	push   $0xf0107a93
f01027f0:	68 04 04 00 00       	push   $0x404
f01027f5:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01027fa:	e8 41 d8 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01027ff:	68 95 7c 10 f0       	push   $0xf0107c95
f0102804:	68 93 7a 10 f0       	push   $0xf0107a93
f0102809:	68 05 04 00 00       	push   $0x405
f010280e:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102813:	e8 28 d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102818:	68 80 74 10 f0       	push   $0xf0107480
f010281d:	68 93 7a 10 f0       	push   $0xf0107a93
f0102822:	68 06 04 00 00       	push   $0x406
f0102827:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010282c:	e8 0f d8 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102831:	68 a6 7c 10 f0       	push   $0xf0107ca6
f0102836:	68 93 7a 10 f0       	push   $0xf0107a93
f010283b:	68 07 04 00 00       	push   $0x407
f0102840:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102845:	e8 f6 d7 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010284a:	68 94 73 10 f0       	push   $0xf0107394
f010284f:	68 93 7a 10 f0       	push   $0xf0107a93
f0102854:	68 0a 04 00 00       	push   $0x40a
f0102859:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010285e:	e8 dd d7 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102863:	68 b4 74 10 f0       	push   $0xf01074b4
f0102868:	68 93 7a 10 f0       	push   $0xf0107a93
f010286d:	68 0b 04 00 00       	push   $0x40b
f0102872:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102877:	e8 c4 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010287c:	68 e8 74 10 f0       	push   $0xf01074e8
f0102881:	68 93 7a 10 f0       	push   $0xf0107a93
f0102886:	68 0c 04 00 00       	push   $0x40c
f010288b:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102890:	e8 ab d7 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102895:	68 20 75 10 f0       	push   $0xf0107520
f010289a:	68 93 7a 10 f0       	push   $0xf0107a93
f010289f:	68 0f 04 00 00       	push   $0x40f
f01028a4:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01028a9:	e8 92 d7 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01028ae:	68 58 75 10 f0       	push   $0xf0107558
f01028b3:	68 93 7a 10 f0       	push   $0xf0107a93
f01028b8:	68 12 04 00 00       	push   $0x412
f01028bd:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01028c2:	e8 79 d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01028c7:	68 e8 74 10 f0       	push   $0xf01074e8
f01028cc:	68 93 7a 10 f0       	push   $0xf0107a93
f01028d1:	68 13 04 00 00       	push   $0x413
f01028d6:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01028db:	e8 60 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01028e0:	68 94 75 10 f0       	push   $0xf0107594
f01028e5:	68 93 7a 10 f0       	push   $0xf0107a93
f01028ea:	68 16 04 00 00       	push   $0x416
f01028ef:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01028f4:	e8 47 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01028f9:	68 c0 75 10 f0       	push   $0xf01075c0
f01028fe:	68 93 7a 10 f0       	push   $0xf0107a93
f0102903:	68 17 04 00 00       	push   $0x417
f0102908:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010290d:	e8 2e d7 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102912:	68 bc 7c 10 f0       	push   $0xf0107cbc
f0102917:	68 93 7a 10 f0       	push   $0xf0107a93
f010291c:	68 19 04 00 00       	push   $0x419
f0102921:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102926:	e8 15 d7 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010292b:	68 cd 7c 10 f0       	push   $0xf0107ccd
f0102930:	68 93 7a 10 f0       	push   $0xf0107a93
f0102935:	68 1a 04 00 00       	push   $0x41a
f010293a:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010293f:	e8 fc d6 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102944:	68 f0 75 10 f0       	push   $0xf01075f0
f0102949:	68 93 7a 10 f0       	push   $0xf0107a93
f010294e:	68 1d 04 00 00       	push   $0x41d
f0102953:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102958:	e8 e3 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010295d:	68 14 76 10 f0       	push   $0xf0107614
f0102962:	68 93 7a 10 f0       	push   $0xf0107a93
f0102967:	68 21 04 00 00       	push   $0x421
f010296c:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102971:	e8 ca d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102976:	68 c0 75 10 f0       	push   $0xf01075c0
f010297b:	68 93 7a 10 f0       	push   $0xf0107a93
f0102980:	68 22 04 00 00       	push   $0x422
f0102985:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010298a:	e8 b1 d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010298f:	68 73 7c 10 f0       	push   $0xf0107c73
f0102994:	68 93 7a 10 f0       	push   $0xf0107a93
f0102999:	68 23 04 00 00       	push   $0x423
f010299e:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01029a3:	e8 98 d6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01029a8:	68 cd 7c 10 f0       	push   $0xf0107ccd
f01029ad:	68 93 7a 10 f0       	push   $0xf0107a93
f01029b2:	68 24 04 00 00       	push   $0x424
f01029b7:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01029bc:	e8 7f d6 ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01029c1:	68 38 76 10 f0       	push   $0xf0107638
f01029c6:	68 93 7a 10 f0       	push   $0xf0107a93
f01029cb:	68 27 04 00 00       	push   $0x427
f01029d0:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01029d5:	e8 66 d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01029da:	68 de 7c 10 f0       	push   $0xf0107cde
f01029df:	68 93 7a 10 f0       	push   $0xf0107a93
f01029e4:	68 28 04 00 00       	push   $0x428
f01029e9:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01029ee:	e8 4d d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01029f3:	68 ea 7c 10 f0       	push   $0xf0107cea
f01029f8:	68 93 7a 10 f0       	push   $0xf0107a93
f01029fd:	68 29 04 00 00       	push   $0x429
f0102a02:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102a07:	e8 34 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102a0c:	68 14 76 10 f0       	push   $0xf0107614
f0102a11:	68 93 7a 10 f0       	push   $0xf0107a93
f0102a16:	68 2d 04 00 00       	push   $0x42d
f0102a1b:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102a20:	e8 1b d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102a25:	68 70 76 10 f0       	push   $0xf0107670
f0102a2a:	68 93 7a 10 f0       	push   $0xf0107a93
f0102a2f:	68 2e 04 00 00       	push   $0x42e
f0102a34:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102a39:	e8 02 d6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102a3e:	68 ff 7c 10 f0       	push   $0xf0107cff
f0102a43:	68 93 7a 10 f0       	push   $0xf0107a93
f0102a48:	68 2f 04 00 00       	push   $0x42f
f0102a4d:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102a52:	e8 e9 d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102a57:	68 cd 7c 10 f0       	push   $0xf0107ccd
f0102a5c:	68 93 7a 10 f0       	push   $0xf0107a93
f0102a61:	68 30 04 00 00       	push   $0x430
f0102a66:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102a6b:	e8 d0 d5 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102a70:	68 98 76 10 f0       	push   $0xf0107698
f0102a75:	68 93 7a 10 f0       	push   $0xf0107a93
f0102a7a:	68 33 04 00 00       	push   $0x433
f0102a7f:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102a84:	e8 b7 d5 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102a89:	68 21 7c 10 f0       	push   $0xf0107c21
f0102a8e:	68 93 7a 10 f0       	push   $0xf0107a93
f0102a93:	68 36 04 00 00       	push   $0x436
f0102a98:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102a9d:	e8 9e d5 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102aa2:	68 3c 73 10 f0       	push   $0xf010733c
f0102aa7:	68 93 7a 10 f0       	push   $0xf0107a93
f0102aac:	68 39 04 00 00       	push   $0x439
f0102ab1:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102ab6:	e8 85 d5 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102abb:	68 84 7c 10 f0       	push   $0xf0107c84
f0102ac0:	68 93 7a 10 f0       	push   $0xf0107a93
f0102ac5:	68 3b 04 00 00       	push   $0x43b
f0102aca:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102acf:	e8 6c d5 ff ff       	call   f0100040 <_panic>
f0102ad4:	50                   	push   %eax
f0102ad5:	68 d4 68 10 f0       	push   $0xf01068d4
f0102ada:	68 42 04 00 00       	push   $0x442
f0102adf:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102ae4:	e8 57 d5 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102ae9:	68 10 7d 10 f0       	push   $0xf0107d10
f0102aee:	68 93 7a 10 f0       	push   $0xf0107a93
f0102af3:	68 43 04 00 00       	push   $0x443
f0102af8:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102afd:	e8 3e d5 ff ff       	call   f0100040 <_panic>
f0102b02:	50                   	push   %eax
f0102b03:	68 d4 68 10 f0       	push   $0xf01068d4
f0102b08:	6a 58                	push   $0x58
f0102b0a:	68 79 7a 10 f0       	push   $0xf0107a79
f0102b0f:	e8 2c d5 ff ff       	call   f0100040 <_panic>
f0102b14:	50                   	push   %eax
f0102b15:	68 d4 68 10 f0       	push   $0xf01068d4
f0102b1a:	6a 58                	push   $0x58
f0102b1c:	68 79 7a 10 f0       	push   $0xf0107a79
f0102b21:	e8 1a d5 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102b26:	68 28 7d 10 f0       	push   $0xf0107d28
f0102b2b:	68 93 7a 10 f0       	push   $0xf0107a93
f0102b30:	68 4d 04 00 00       	push   $0x44d
f0102b35:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102b3a:	e8 01 d5 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102b3f:	68 bc 76 10 f0       	push   $0xf01076bc
f0102b44:	68 93 7a 10 f0       	push   $0xf0107a93
f0102b49:	68 5d 04 00 00       	push   $0x45d
f0102b4e:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102b53:	e8 e8 d4 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102b58:	68 e4 76 10 f0       	push   $0xf01076e4
f0102b5d:	68 93 7a 10 f0       	push   $0xf0107a93
f0102b62:	68 5e 04 00 00       	push   $0x45e
f0102b67:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102b6c:	e8 cf d4 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102b71:	68 0c 77 10 f0       	push   $0xf010770c
f0102b76:	68 93 7a 10 f0       	push   $0xf0107a93
f0102b7b:	68 60 04 00 00       	push   $0x460
f0102b80:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102b85:	e8 b6 d4 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f0102b8a:	68 3f 7d 10 f0       	push   $0xf0107d3f
f0102b8f:	68 93 7a 10 f0       	push   $0xf0107a93
f0102b94:	68 62 04 00 00       	push   $0x462
f0102b99:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102b9e:	e8 9d d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102ba3:	68 34 77 10 f0       	push   $0xf0107734
f0102ba8:	68 93 7a 10 f0       	push   $0xf0107a93
f0102bad:	68 64 04 00 00       	push   $0x464
f0102bb2:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102bb7:	e8 84 d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102bbc:	68 58 77 10 f0       	push   $0xf0107758
f0102bc1:	68 93 7a 10 f0       	push   $0xf0107a93
f0102bc6:	68 65 04 00 00       	push   $0x465
f0102bcb:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102bd0:	e8 6b d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102bd5:	68 88 77 10 f0       	push   $0xf0107788
f0102bda:	68 93 7a 10 f0       	push   $0xf0107a93
f0102bdf:	68 66 04 00 00       	push   $0x466
f0102be4:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102be9:	e8 52 d4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102bee:	68 ac 77 10 f0       	push   $0xf01077ac
f0102bf3:	68 93 7a 10 f0       	push   $0xf0107a93
f0102bf8:	68 67 04 00 00       	push   $0x467
f0102bfd:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102c02:	e8 39 d4 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102c07:	68 d8 77 10 f0       	push   $0xf01077d8
f0102c0c:	68 93 7a 10 f0       	push   $0xf0107a93
f0102c11:	68 69 04 00 00       	push   $0x469
f0102c16:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102c1b:	e8 20 d4 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102c20:	68 1c 78 10 f0       	push   $0xf010781c
f0102c25:	68 93 7a 10 f0       	push   $0xf0107a93
f0102c2a:	68 6a 04 00 00       	push   $0x46a
f0102c2f:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102c34:	e8 07 d4 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c39:	50                   	push   %eax
f0102c3a:	68 f8 68 10 f0       	push   $0xf01068f8
f0102c3f:	68 d0 00 00 00       	push   $0xd0
f0102c44:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102c49:	e8 f2 d3 ff ff       	call   f0100040 <_panic>
f0102c4e:	50                   	push   %eax
f0102c4f:	68 f8 68 10 f0       	push   $0xf01068f8
f0102c54:	68 d9 00 00 00       	push   $0xd9
f0102c59:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102c5e:	e8 dd d3 ff ff       	call   f0100040 <_panic>
f0102c63:	53                   	push   %ebx
f0102c64:	68 f8 68 10 f0       	push   $0xf01068f8
f0102c69:	68 29 01 00 00       	push   $0x129
f0102c6e:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102c73:	e8 c8 d3 ff ff       	call   f0100040 <_panic>
f0102c78:	56                   	push   %esi
f0102c79:	68 f8 68 10 f0       	push   $0xf01068f8
f0102c7e:	68 73 03 00 00       	push   $0x373
f0102c83:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102c88:	e8 b3 d3 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102c8d:	68 50 78 10 f0       	push   $0xf0107850
f0102c92:	68 93 7a 10 f0       	push   $0xf0107a93
f0102c97:	68 73 03 00 00       	push   $0x373
f0102c9c:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102ca1:	e8 9a d3 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ca6:	a1 44 02 25 f0       	mov    0xf0250244,%eax
f0102cab:	89 45 cc             	mov    %eax,-0x34(%ebp)
	if ((uint32_t)kva < KERNBASE)
f0102cae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102cb1:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102cb6:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f0102cbc:	89 da                	mov    %ebx,%edx
f0102cbe:	89 f8                	mov    %edi,%eax
f0102cc0:	e8 42 e1 ff ff       	call   f0100e07 <check_va2pa>
f0102cc5:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102ccc:	76 47                	jbe    f0102d15 <mem_init+0x16a2>
f0102cce:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102cd1:	39 d0                	cmp    %edx,%eax
f0102cd3:	75 57                	jne    f0102d2c <mem_init+0x16b9>
f0102cd5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102cdb:	81 fb 00 00 c2 ee    	cmp    $0xeec20000,%ebx
f0102ce1:	75 d9                	jne    f0102cbc <mem_init+0x1649>
	if (!(*pgdir & PTE_P) | !(*pgdir & PTE_PS))
f0102ce3:	8b 87 00 0f 00 00    	mov    0xf00(%edi),%eax
f0102ce9:	89 c2                	mov    %eax,%edx
f0102ceb:	81 e2 81 00 00 00    	and    $0x81,%edx
f0102cf1:	81 fa 81 00 00 00    	cmp    $0x81,%edx
f0102cf7:	0f 85 7e 01 00 00    	jne    f0102e7b <mem_init+0x1808>
	if (check_va2pa_large(pgdir, KERNBASE) == 0) {
f0102cfd:	a9 00 f0 ff ff       	test   $0xfffff000,%eax
f0102d02:	0f 85 73 01 00 00    	jne    f0102e7b <mem_init+0x1808>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0102d08:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0102d0b:	c1 e3 0c             	shl    $0xc,%ebx
f0102d0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d13:	eb 3f                	jmp    f0102d54 <mem_init+0x16e1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d15:	ff 75 cc             	pushl  -0x34(%ebp)
f0102d18:	68 f8 68 10 f0       	push   $0xf01068f8
f0102d1d:	68 78 03 00 00       	push   $0x378
f0102d22:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102d27:	e8 14 d3 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102d2c:	68 84 78 10 f0       	push   $0xf0107884
f0102d31:	68 93 7a 10 f0       	push   $0xf0107a93
f0102d36:	68 78 03 00 00       	push   $0x378
f0102d3b:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102d40:	e8 fb d2 ff ff       	call   f0100040 <_panic>
	return PTE_ADDR(*pgdir);
f0102d45:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);
f0102d4b:	39 d0                	cmp    %edx,%eax
f0102d4d:	75 25                	jne    f0102d74 <mem_init+0x1701>
		for (i = 0; i < npages * PGSIZE; i += PTSIZE)
f0102d4f:	05 00 00 40 00       	add    $0x400000,%eax
f0102d54:	39 d8                	cmp    %ebx,%eax
f0102d56:	73 35                	jae    f0102d8d <mem_init+0x171a>
	pgdir = &pgdir[PDX(va)];
f0102d58:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0102d5e:	c1 ea 16             	shr    $0x16,%edx
	if (!(*pgdir & PTE_P) | !(*pgdir & PTE_PS))
f0102d61:	8b 14 97             	mov    (%edi,%edx,4),%edx
f0102d64:	89 d1                	mov    %edx,%ecx
f0102d66:	81 e1 81 00 00 00    	and    $0x81,%ecx
f0102d6c:	81 f9 81 00 00 00    	cmp    $0x81,%ecx
f0102d72:	74 d1                	je     f0102d45 <mem_init+0x16d2>
			assert(check_va2pa_large(pgdir, KERNBASE + i) == i);
f0102d74:	68 b8 78 10 f0       	push   $0xf01078b8
f0102d79:	68 93 7a 10 f0       	push   $0xf0107a93
f0102d7e:	68 7d 03 00 00       	push   $0x37d
f0102d83:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102d88:	e8 b3 d2 ff ff       	call   f0100040 <_panic>
		cprintf("large page installed!\n");
f0102d8d:	83 ec 0c             	sub    $0xc,%esp
f0102d90:	68 6a 7d 10 f0       	push   $0xf0107d6a
f0102d95:	e8 3b 0f 00 00       	call   f0103cd5 <cprintf>
f0102d9a:	83 c4 10             	add    $0x10,%esp
        for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d9d:	b8 00 20 25 f0       	mov    $0xf0252000,%eax
f0102da2:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102da7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102daa:	89 c7                	mov    %eax,%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102dac:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102daf:	89 f3                	mov    %esi,%ebx
f0102db1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102db4:	05 00 80 00 20       	add    $0x20008000,%eax
f0102db9:	89 45 cc             	mov    %eax,-0x34(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102dbc:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f0102dc2:	89 45 c8             	mov    %eax,-0x38(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102dc5:	89 da                	mov    %ebx,%edx
f0102dc7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102dca:	e8 38 e0 ff ff       	call   f0100e07 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102dcf:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102dd5:	0f 86 ad 00 00 00    	jbe    f0102e88 <mem_init+0x1815>
f0102ddb:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102dde:	8d 14 19             	lea    (%ecx,%ebx,1),%edx
f0102de1:	39 d0                	cmp    %edx,%eax
f0102de3:	0f 85 b6 00 00 00    	jne    f0102e9f <mem_init+0x182c>
f0102de9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102def:	3b 5d c8             	cmp    -0x38(%ebp),%ebx
f0102df2:	75 d1                	jne    f0102dc5 <mem_init+0x1752>
f0102df4:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102dfa:	89 da                	mov    %ebx,%edx
f0102dfc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102dff:	e8 03 e0 ff ff       	call   f0100e07 <check_va2pa>
f0102e04:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102e07:	0f 85 ab 00 00 00    	jne    f0102eb8 <mem_init+0x1845>
f0102e0d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102e13:	39 f3                	cmp    %esi,%ebx
f0102e15:	75 e3                	jne    f0102dfa <mem_init+0x1787>
f0102e17:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f0102e1d:	81 45 d0 00 80 01 00 	addl   $0x18000,-0x30(%ebp)
f0102e24:	81 c7 00 80 00 00    	add    $0x8000,%edi
	for (n = 0; n < NCPU; n++) {
f0102e2a:	81 ff 00 20 29 f0    	cmp    $0xf0292000,%edi
f0102e30:	0f 85 76 ff ff ff    	jne    f0102dac <mem_init+0x1739>
f0102e36:	8b 7d d4             	mov    -0x2c(%ebp),%edi
	for (i = 0; i < NPDENTRIES; i++) {
f0102e39:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e3e:	e9 c4 00 00 00       	jmp    f0102f07 <mem_init+0x1894>
        for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e43:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e49:	39 f3                	cmp    %esi,%ebx
f0102e4b:	0f 83 4c ff ff ff    	jae    f0102d9d <mem_init+0x172a>
            assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102e51:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102e57:	89 f8                	mov    %edi,%eax
f0102e59:	e8 a9 df ff ff       	call   f0100e07 <check_va2pa>
f0102e5e:	39 c3                	cmp    %eax,%ebx
f0102e60:	74 e1                	je     f0102e43 <mem_init+0x17d0>
f0102e62:	68 e4 78 10 f0       	push   $0xf01078e4
f0102e67:	68 93 7a 10 f0       	push   $0xf0107a93
f0102e6c:	68 82 03 00 00       	push   $0x382
f0102e71:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102e76:	e8 c5 d1 ff ff       	call   f0100040 <_panic>
        for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102e7b:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102e7e:	c1 e6 0c             	shl    $0xc,%esi
f0102e81:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e86:	eb c1                	jmp    f0102e49 <mem_init+0x17d6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e88:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102e8b:	68 f8 68 10 f0       	push   $0xf01068f8
f0102e90:	68 8b 03 00 00       	push   $0x38b
f0102e95:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102e9a:	e8 a1 d1 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102e9f:	68 0c 79 10 f0       	push   $0xf010790c
f0102ea4:	68 93 7a 10 f0       	push   $0xf0107a93
f0102ea9:	68 8b 03 00 00       	push   $0x38b
f0102eae:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102eb3:	e8 88 d1 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102eb8:	68 54 79 10 f0       	push   $0xf0107954
f0102ebd:	68 93 7a 10 f0       	push   $0xf0107a93
f0102ec2:	68 8d 03 00 00       	push   $0x38d
f0102ec7:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102ecc:	e8 6f d1 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102ed1:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102ed5:	75 48                	jne    f0102f1f <mem_init+0x18ac>
f0102ed7:	68 81 7d 10 f0       	push   $0xf0107d81
f0102edc:	68 93 7a 10 f0       	push   $0xf0107a93
f0102ee1:	68 98 03 00 00       	push   $0x398
f0102ee6:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102eeb:	e8 50 d1 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102ef0:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102ef3:	f6 c2 01             	test   $0x1,%dl
f0102ef6:	74 2c                	je     f0102f24 <mem_init+0x18b1>
				assert(pgdir[i] & PTE_W);
f0102ef8:	f6 c2 02             	test   $0x2,%dl
f0102efb:	74 40                	je     f0102f3d <mem_init+0x18ca>
	for (i = 0; i < NPDENTRIES; i++) {
f0102efd:	83 c0 01             	add    $0x1,%eax
f0102f00:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102f05:	74 68                	je     f0102f6f <mem_init+0x18fc>
		switch (i) {
f0102f07:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102f0d:	83 fa 04             	cmp    $0x4,%edx
f0102f10:	76 bf                	jbe    f0102ed1 <mem_init+0x185e>
			if (i >= PDX(KERNBASE)) {
f0102f12:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102f17:	77 d7                	ja     f0102ef0 <mem_init+0x187d>
				assert(pgdir[i] == 0);
f0102f19:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102f1d:	75 37                	jne    f0102f56 <mem_init+0x18e3>
	for (i = 0; i < NPDENTRIES; i++) {
f0102f1f:	83 c0 01             	add    $0x1,%eax
f0102f22:	eb e3                	jmp    f0102f07 <mem_init+0x1894>
				assert(pgdir[i] & PTE_P);
f0102f24:	68 81 7d 10 f0       	push   $0xf0107d81
f0102f29:	68 93 7a 10 f0       	push   $0xf0107a93
f0102f2e:	68 9c 03 00 00       	push   $0x39c
f0102f33:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102f38:	e8 03 d1 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102f3d:	68 92 7d 10 f0       	push   $0xf0107d92
f0102f42:	68 93 7a 10 f0       	push   $0xf0107a93
f0102f47:	68 9d 03 00 00       	push   $0x39d
f0102f4c:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102f51:	e8 ea d0 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102f56:	68 a3 7d 10 f0       	push   $0xf0107da3
f0102f5b:	68 93 7a 10 f0       	push   $0xf0107a93
f0102f60:	68 9f 03 00 00       	push   $0x39f
f0102f65:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0102f6a:	e8 d1 d0 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102f6f:	83 ec 0c             	sub    $0xc,%esp
f0102f72:	68 78 79 10 f0       	push   $0xf0107978
f0102f77:	e8 59 0d 00 00       	call   f0103cd5 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102f7c:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102f81:	83 c4 10             	add    $0x10,%esp
f0102f84:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f89:	0f 86 fb 01 00 00    	jbe    f010318a <mem_init+0x1b17>
	return (physaddr_t)kva - KERNBASE;
f0102f8f:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102f94:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102f97:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f9c:	e8 55 df ff ff       	call   f0100ef6 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102fa1:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102fa4:	83 e0 f3             	and    $0xfffffff3,%eax
f0102fa7:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102fac:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102faf:	83 ec 0c             	sub    $0xc,%esp
f0102fb2:	6a 00                	push   $0x0
f0102fb4:	e8 25 e3 ff ff       	call   f01012de <page_alloc>
f0102fb9:	89 c6                	mov    %eax,%esi
f0102fbb:	83 c4 10             	add    $0x10,%esp
f0102fbe:	85 c0                	test   %eax,%eax
f0102fc0:	0f 84 d9 01 00 00    	je     f010319f <mem_init+0x1b2c>
	assert((pp1 = page_alloc(0)));
f0102fc6:	83 ec 0c             	sub    $0xc,%esp
f0102fc9:	6a 00                	push   $0x0
f0102fcb:	e8 0e e3 ff ff       	call   f01012de <page_alloc>
f0102fd0:	89 c7                	mov    %eax,%edi
f0102fd2:	83 c4 10             	add    $0x10,%esp
f0102fd5:	85 c0                	test   %eax,%eax
f0102fd7:	0f 84 db 01 00 00    	je     f01031b8 <mem_init+0x1b45>
	assert((pp2 = page_alloc(0)));
f0102fdd:	83 ec 0c             	sub    $0xc,%esp
f0102fe0:	6a 00                	push   $0x0
f0102fe2:	e8 f7 e2 ff ff       	call   f01012de <page_alloc>
f0102fe7:	89 c3                	mov    %eax,%ebx
f0102fe9:	83 c4 10             	add    $0x10,%esp
f0102fec:	85 c0                	test   %eax,%eax
f0102fee:	0f 84 dd 01 00 00    	je     f01031d1 <mem_init+0x1b5e>
	page_free(pp0);
f0102ff4:	83 ec 0c             	sub    $0xc,%esp
f0102ff7:	56                   	push   %esi
f0102ff8:	e8 59 e3 ff ff       	call   f0101356 <page_free>
	return (pp - pages) << PGSHIFT;
f0102ffd:	89 f8                	mov    %edi,%eax
f0102fff:	2b 05 90 0e 25 f0    	sub    0xf0250e90,%eax
f0103005:	c1 f8 03             	sar    $0x3,%eax
f0103008:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010300b:	89 c2                	mov    %eax,%edx
f010300d:	c1 ea 0c             	shr    $0xc,%edx
f0103010:	83 c4 10             	add    $0x10,%esp
f0103013:	3b 15 88 0e 25 f0    	cmp    0xf0250e88,%edx
f0103019:	0f 83 cb 01 00 00    	jae    f01031ea <mem_init+0x1b77>
	memset(page2kva(pp1), 1, PGSIZE);
f010301f:	83 ec 04             	sub    $0x4,%esp
f0103022:	68 00 10 00 00       	push   $0x1000
f0103027:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0103029:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010302e:	50                   	push   %eax
f010302f:	e8 c9 2b 00 00       	call   f0105bfd <memset>
	return (pp - pages) << PGSHIFT;
f0103034:	89 d8                	mov    %ebx,%eax
f0103036:	2b 05 90 0e 25 f0    	sub    0xf0250e90,%eax
f010303c:	c1 f8 03             	sar    $0x3,%eax
f010303f:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0103042:	89 c2                	mov    %eax,%edx
f0103044:	c1 ea 0c             	shr    $0xc,%edx
f0103047:	83 c4 10             	add    $0x10,%esp
f010304a:	3b 15 88 0e 25 f0    	cmp    0xf0250e88,%edx
f0103050:	0f 83 a6 01 00 00    	jae    f01031fc <mem_init+0x1b89>
	memset(page2kva(pp2), 2, PGSIZE);
f0103056:	83 ec 04             	sub    $0x4,%esp
f0103059:	68 00 10 00 00       	push   $0x1000
f010305e:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0103060:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103065:	50                   	push   %eax
f0103066:	e8 92 2b 00 00       	call   f0105bfd <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010306b:	6a 02                	push   $0x2
f010306d:	68 00 10 00 00       	push   $0x1000
f0103072:	57                   	push   %edi
f0103073:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f0103079:	e8 15 e5 ff ff       	call   f0101593 <page_insert>
	assert(pp1->pp_ref == 1);
f010307e:	83 c4 20             	add    $0x20,%esp
f0103081:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103086:	0f 85 82 01 00 00    	jne    f010320e <mem_init+0x1b9b>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010308c:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103093:	01 01 01 
f0103096:	0f 85 8b 01 00 00    	jne    f0103227 <mem_init+0x1bb4>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010309c:	6a 02                	push   $0x2
f010309e:	68 00 10 00 00       	push   $0x1000
f01030a3:	53                   	push   %ebx
f01030a4:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f01030aa:	e8 e4 e4 ff ff       	call   f0101593 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01030af:	83 c4 10             	add    $0x10,%esp
f01030b2:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01030b9:	02 02 02 
f01030bc:	0f 85 7e 01 00 00    	jne    f0103240 <mem_init+0x1bcd>
	assert(pp2->pp_ref == 1);
f01030c2:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01030c7:	0f 85 8c 01 00 00    	jne    f0103259 <mem_init+0x1be6>
	assert(pp1->pp_ref == 0);
f01030cd:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01030d2:	0f 85 9a 01 00 00    	jne    f0103272 <mem_init+0x1bff>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01030d8:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01030df:	03 03 03 
	return (pp - pages) << PGSHIFT;
f01030e2:	89 d8                	mov    %ebx,%eax
f01030e4:	2b 05 90 0e 25 f0    	sub    0xf0250e90,%eax
f01030ea:	c1 f8 03             	sar    $0x3,%eax
f01030ed:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01030f0:	89 c2                	mov    %eax,%edx
f01030f2:	c1 ea 0c             	shr    $0xc,%edx
f01030f5:	3b 15 88 0e 25 f0    	cmp    0xf0250e88,%edx
f01030fb:	0f 83 8a 01 00 00    	jae    f010328b <mem_init+0x1c18>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103101:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103108:	03 03 03 
f010310b:	0f 85 8c 01 00 00    	jne    f010329d <mem_init+0x1c2a>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103111:	83 ec 08             	sub    $0x8,%esp
f0103114:	68 00 10 00 00       	push   $0x1000
f0103119:	ff 35 8c 0e 25 f0    	pushl  0xf0250e8c
f010311f:	e8 1c e4 ff ff       	call   f0101540 <page_remove>
	assert(pp2->pp_ref == 0);
f0103124:	83 c4 10             	add    $0x10,%esp
f0103127:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010312c:	0f 85 84 01 00 00    	jne    f01032b6 <mem_init+0x1c43>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103132:	8b 0d 8c 0e 25 f0    	mov    0xf0250e8c,%ecx
f0103138:	8b 11                	mov    (%ecx),%edx
f010313a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0103140:	89 f0                	mov    %esi,%eax
f0103142:	2b 05 90 0e 25 f0    	sub    0xf0250e90,%eax
f0103148:	c1 f8 03             	sar    $0x3,%eax
f010314b:	c1 e0 0c             	shl    $0xc,%eax
f010314e:	39 c2                	cmp    %eax,%edx
f0103150:	0f 85 79 01 00 00    	jne    f01032cf <mem_init+0x1c5c>
	kern_pgdir[0] = 0;
f0103156:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010315c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103161:	0f 85 81 01 00 00    	jne    f01032e8 <mem_init+0x1c75>
	pp0->pp_ref = 0;
f0103167:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f010316d:	83 ec 0c             	sub    $0xc,%esp
f0103170:	56                   	push   %esi
f0103171:	e8 e0 e1 ff ff       	call   f0101356 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103176:	c7 04 24 0c 7a 10 f0 	movl   $0xf0107a0c,(%esp)
f010317d:	e8 53 0b 00 00       	call   f0103cd5 <cprintf>
}
f0103182:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103185:	5b                   	pop    %ebx
f0103186:	5e                   	pop    %esi
f0103187:	5f                   	pop    %edi
f0103188:	5d                   	pop    %ebp
f0103189:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010318a:	50                   	push   %eax
f010318b:	68 f8 68 10 f0       	push   $0xf01068f8
f0103190:	68 02 01 00 00       	push   $0x102
f0103195:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010319a:	e8 a1 ce ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010319f:	68 76 7b 10 f0       	push   $0xf0107b76
f01031a4:	68 93 7a 10 f0       	push   $0xf0107a93
f01031a9:	68 7f 04 00 00       	push   $0x47f
f01031ae:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01031b3:	e8 88 ce ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01031b8:	68 8c 7b 10 f0       	push   $0xf0107b8c
f01031bd:	68 93 7a 10 f0       	push   $0xf0107a93
f01031c2:	68 80 04 00 00       	push   $0x480
f01031c7:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01031cc:	e8 6f ce ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01031d1:	68 a2 7b 10 f0       	push   $0xf0107ba2
f01031d6:	68 93 7a 10 f0       	push   $0xf0107a93
f01031db:	68 81 04 00 00       	push   $0x481
f01031e0:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01031e5:	e8 56 ce ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01031ea:	50                   	push   %eax
f01031eb:	68 d4 68 10 f0       	push   $0xf01068d4
f01031f0:	6a 58                	push   $0x58
f01031f2:	68 79 7a 10 f0       	push   $0xf0107a79
f01031f7:	e8 44 ce ff ff       	call   f0100040 <_panic>
f01031fc:	50                   	push   %eax
f01031fd:	68 d4 68 10 f0       	push   $0xf01068d4
f0103202:	6a 58                	push   $0x58
f0103204:	68 79 7a 10 f0       	push   $0xf0107a79
f0103209:	e8 32 ce ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010320e:	68 73 7c 10 f0       	push   $0xf0107c73
f0103213:	68 93 7a 10 f0       	push   $0xf0107a93
f0103218:	68 86 04 00 00       	push   $0x486
f010321d:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0103222:	e8 19 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103227:	68 98 79 10 f0       	push   $0xf0107998
f010322c:	68 93 7a 10 f0       	push   $0xf0107a93
f0103231:	68 87 04 00 00       	push   $0x487
f0103236:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010323b:	e8 00 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103240:	68 bc 79 10 f0       	push   $0xf01079bc
f0103245:	68 93 7a 10 f0       	push   $0xf0107a93
f010324a:	68 89 04 00 00       	push   $0x489
f010324f:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0103254:	e8 e7 cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0103259:	68 95 7c 10 f0       	push   $0xf0107c95
f010325e:	68 93 7a 10 f0       	push   $0xf0107a93
f0103263:	68 8a 04 00 00       	push   $0x48a
f0103268:	68 6d 7a 10 f0       	push   $0xf0107a6d
f010326d:	e8 ce cd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103272:	68 ff 7c 10 f0       	push   $0xf0107cff
f0103277:	68 93 7a 10 f0       	push   $0xf0107a93
f010327c:	68 8b 04 00 00       	push   $0x48b
f0103281:	68 6d 7a 10 f0       	push   $0xf0107a6d
f0103286:	e8 b5 cd ff ff       	call   f0100040 <_panic>
f010328b:	50                   	push   %eax
f010328c:	68 d4 68 10 f0       	push   $0xf01068d4
f0103291:	6a 58                	push   $0x58
f0103293:	68 79 7a 10 f0       	push   $0xf0107a79
f0103298:	e8 a3 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010329d:	68 e0 79 10 f0       	push   $0xf01079e0
f01032a2:	68 93 7a 10 f0       	push   $0xf0107a93
f01032a7:	68 8d 04 00 00       	push   $0x48d
f01032ac:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01032b1:	e8 8a cd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01032b6:	68 cd 7c 10 f0       	push   $0xf0107ccd
f01032bb:	68 93 7a 10 f0       	push   $0xf0107a93
f01032c0:	68 8f 04 00 00       	push   $0x48f
f01032c5:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01032ca:	e8 71 cd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01032cf:	68 3c 73 10 f0       	push   $0xf010733c
f01032d4:	68 93 7a 10 f0       	push   $0xf0107a93
f01032d9:	68 92 04 00 00       	push   $0x492
f01032de:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01032e3:	e8 58 cd ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01032e8:	68 84 7c 10 f0       	push   $0xf0107c84
f01032ed:	68 93 7a 10 f0       	push   $0xf0107a93
f01032f2:	68 94 04 00 00       	push   $0x494
f01032f7:	68 6d 7a 10 f0       	push   $0xf0107a6d
f01032fc:	e8 3f cd ff ff       	call   f0100040 <_panic>

f0103301 <user_mem_check>:
{
f0103301:	55                   	push   %ebp
f0103302:	89 e5                	mov    %esp,%ebp
f0103304:	57                   	push   %edi
f0103305:	56                   	push   %esi
f0103306:	53                   	push   %ebx
f0103307:	83 ec 0c             	sub    $0xc,%esp
	start = (uintptr_t)ROUNDDOWN(va, PGSIZE);
f010330a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010330d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	end = (uintptr_t)ROUNDUP(va + len, PGSIZE);
f0103313:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103316:	03 75 10             	add    0x10(%ebp),%esi
f0103319:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
f010331f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		if (pte == NULL || i >= ULIM || !((perm | PTE_P) & *pte)) {
f0103325:	8b 7d 14             	mov    0x14(%ebp),%edi
f0103328:	83 cf 01             	or     $0x1,%edi
	for (uintptr_t i = start; i < end; i += PGSIZE) {
f010332b:	39 f3                	cmp    %esi,%ebx
f010332d:	73 51                	jae    f0103380 <user_mem_check+0x7f>
		pte_t* pte = pgdir_walk(curenv->env_pgdir, (void*)i, 0);
f010332f:	e8 ca 2e 00 00       	call   f01061fe <cpunum>
f0103334:	83 ec 04             	sub    $0x4,%esp
f0103337:	6a 00                	push   $0x0
f0103339:	53                   	push   %ebx
f010333a:	6b c0 74             	imul   $0x74,%eax,%eax
f010333d:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0103343:	ff 70 64             	pushl  0x64(%eax)
f0103346:	e8 6f e0 ff ff       	call   f01013ba <pgdir_walk>
		if (pte == NULL || i >= ULIM || !((perm | PTE_P) & *pte)) {
f010334b:	83 c4 10             	add    $0x10,%esp
f010334e:	85 c0                	test   %eax,%eax
f0103350:	74 14                	je     f0103366 <user_mem_check+0x65>
f0103352:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0103358:	77 0c                	ja     f0103366 <user_mem_check+0x65>
f010335a:	85 38                	test   %edi,(%eax)
f010335c:	74 08                	je     f0103366 <user_mem_check+0x65>
	for (uintptr_t i = start; i < end; i += PGSIZE) {
f010335e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103364:	eb c5                	jmp    f010332b <user_mem_check+0x2a>
			user_mem_check_addr = i < (uintptr_t)va ? (uintptr_t)va : i;
f0103366:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0103369:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f010336d:	89 1d 3c 02 25 f0    	mov    %ebx,0xf025023c
			return -E_FAULT;
f0103373:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0103378:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010337b:	5b                   	pop    %ebx
f010337c:	5e                   	pop    %esi
f010337d:	5f                   	pop    %edi
f010337e:	5d                   	pop    %ebp
f010337f:	c3                   	ret    
	return 0;
f0103380:	b8 00 00 00 00       	mov    $0x0,%eax
f0103385:	eb f1                	jmp    f0103378 <user_mem_check+0x77>

f0103387 <user_mem_assert>:
{
f0103387:	55                   	push   %ebp
f0103388:	89 e5                	mov    %esp,%ebp
f010338a:	53                   	push   %ebx
f010338b:	83 ec 04             	sub    $0x4,%esp
f010338e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103391:	8b 45 14             	mov    0x14(%ebp),%eax
f0103394:	83 c8 04             	or     $0x4,%eax
f0103397:	50                   	push   %eax
f0103398:	ff 75 10             	pushl  0x10(%ebp)
f010339b:	ff 75 0c             	pushl  0xc(%ebp)
f010339e:	53                   	push   %ebx
f010339f:	e8 5d ff ff ff       	call   f0103301 <user_mem_check>
f01033a4:	83 c4 10             	add    $0x10,%esp
f01033a7:	85 c0                	test   %eax,%eax
f01033a9:	78 05                	js     f01033b0 <user_mem_assert+0x29>
}
f01033ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033ae:	c9                   	leave  
f01033af:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f01033b0:	83 ec 04             	sub    $0x4,%esp
f01033b3:	ff 35 3c 02 25 f0    	pushl  0xf025023c
f01033b9:	ff 73 48             	pushl  0x48(%ebx)
f01033bc:	68 38 7a 10 f0       	push   $0xf0107a38
f01033c1:	e8 0f 09 00 00       	call   f0103cd5 <cprintf>
		env_destroy(env);	// may not return
f01033c6:	89 1c 24             	mov    %ebx,(%esp)
f01033c9:	e8 eb 05 00 00       	call   f01039b9 <env_destroy>
f01033ce:	83 c4 10             	add    $0x10,%esp
}
f01033d1:	eb d8                	jmp    f01033ab <user_mem_assert+0x24>

f01033d3 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01033d3:	55                   	push   %ebp
f01033d4:	89 e5                	mov    %esp,%ebp
f01033d6:	57                   	push   %edi
f01033d7:	56                   	push   %esi
f01033d8:	53                   	push   %ebx
f01033d9:	83 ec 0c             	sub    $0xc,%esp
f01033dc:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	// (But only if you need it for load_icode.)
	uintptr_t start, end;
	start = (uintptr_t)ROUNDDOWN(va, PGSIZE);
f01033de:	89 d3                	mov    %edx,%ebx
f01033e0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	end = (uintptr_t)ROUNDUP(va + len, PGSIZE);
f01033e6:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f01033ed:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	for (uintptr_t i = start; i < end; i += PGSIZE) {
f01033f3:	39 f3                	cmp    %esi,%ebx
f01033f5:	73 3f                	jae    f0103436 <region_alloc+0x63>
		struct PageInfo *p = page_alloc(0);
f01033f7:	83 ec 0c             	sub    $0xc,%esp
f01033fa:	6a 00                	push   $0x0
f01033fc:	e8 dd de ff ff       	call   f01012de <page_alloc>
		if (!p) panic("allocation attemps fails");
f0103401:	83 c4 10             	add    $0x10,%esp
f0103404:	85 c0                	test   %eax,%eax
f0103406:	74 17                	je     f010341f <region_alloc+0x4c>
		page_insert(e->env_pgdir, p, (void*)i, PTE_U | PTE_W);
f0103408:	6a 06                	push   $0x6
f010340a:	53                   	push   %ebx
f010340b:	50                   	push   %eax
f010340c:	ff 77 64             	pushl  0x64(%edi)
f010340f:	e8 7f e1 ff ff       	call   f0101593 <page_insert>
	for (uintptr_t i = start; i < end; i += PGSIZE) {
f0103414:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010341a:	83 c4 10             	add    $0x10,%esp
f010341d:	eb d4                	jmp    f01033f3 <region_alloc+0x20>
		if (!p) panic("allocation attemps fails");
f010341f:	83 ec 04             	sub    $0x4,%esp
f0103422:	68 b1 7d 10 f0       	push   $0xf0107db1
f0103427:	68 28 01 00 00       	push   $0x128
f010342c:	68 ca 7d 10 f0       	push   $0xf0107dca
f0103431:	e8 0a cc ff ff       	call   f0100040 <_panic>
	
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0103436:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103439:	5b                   	pop    %ebx
f010343a:	5e                   	pop    %esi
f010343b:	5f                   	pop    %edi
f010343c:	5d                   	pop    %ebp
f010343d:	c3                   	ret    

f010343e <envid2env>:
{
f010343e:	55                   	push   %ebp
f010343f:	89 e5                	mov    %esp,%ebp
f0103441:	56                   	push   %esi
f0103442:	53                   	push   %ebx
f0103443:	8b 45 08             	mov    0x8(%ebp),%eax
f0103446:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f0103449:	85 c0                	test   %eax,%eax
f010344b:	74 2e                	je     f010347b <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f010344d:	89 c3                	mov    %eax,%ebx
f010344f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103455:	c1 e3 07             	shl    $0x7,%ebx
f0103458:	03 1d 44 02 25 f0    	add    0xf0250244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010345e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103462:	74 31                	je     f0103495 <envid2env+0x57>
f0103464:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103467:	75 2c                	jne    f0103495 <envid2env+0x57>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103469:	84 d2                	test   %dl,%dl
f010346b:	75 38                	jne    f01034a5 <envid2env+0x67>
	*env_store = e;
f010346d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103470:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103472:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103477:	5b                   	pop    %ebx
f0103478:	5e                   	pop    %esi
f0103479:	5d                   	pop    %ebp
f010347a:	c3                   	ret    
		*env_store = curenv;
f010347b:	e8 7e 2d 00 00       	call   f01061fe <cpunum>
f0103480:	6b c0 74             	imul   $0x74,%eax,%eax
f0103483:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0103489:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010348c:	89 01                	mov    %eax,(%ecx)
		return 0;
f010348e:	b8 00 00 00 00       	mov    $0x0,%eax
f0103493:	eb e2                	jmp    f0103477 <envid2env+0x39>
		*env_store = 0;
f0103495:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103498:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010349e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01034a3:	eb d2                	jmp    f0103477 <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01034a5:	e8 54 2d 00 00       	call   f01061fe <cpunum>
f01034aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01034ad:	39 98 28 10 25 f0    	cmp    %ebx,-0xfdaefd8(%eax)
f01034b3:	74 b8                	je     f010346d <envid2env+0x2f>
f01034b5:	8b 73 4c             	mov    0x4c(%ebx),%esi
f01034b8:	e8 41 2d 00 00       	call   f01061fe <cpunum>
f01034bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01034c0:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f01034c6:	3b 70 48             	cmp    0x48(%eax),%esi
f01034c9:	74 a2                	je     f010346d <envid2env+0x2f>
		*env_store = 0;
f01034cb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01034d4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01034d9:	eb 9c                	jmp    f0103477 <envid2env+0x39>

f01034db <env_init_percpu>:
	asm volatile("lgdt (%0)" : : "r" (p));
f01034db:	b8 20 43 12 f0       	mov    $0xf0124320,%eax
f01034e0:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01034e3:	b8 23 00 00 00       	mov    $0x23,%eax
f01034e8:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01034ea:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01034ec:	b8 10 00 00 00       	mov    $0x10,%eax
f01034f1:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01034f3:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01034f5:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01034f7:	ea fe 34 10 f0 08 00 	ljmp   $0x8,$0xf01034fe
	asm volatile("lldt %0" : : "r" (sel));
f01034fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0103503:	0f 00 d0             	lldt   %ax
}
f0103506:	c3                   	ret    

f0103507 <env_init>:
{
f0103507:	55                   	push   %ebp
f0103508:	89 e5                	mov    %esp,%ebp
f010350a:	56                   	push   %esi
f010350b:	53                   	push   %ebx
		envs[i].env_id = 0;
f010350c:	8b 35 44 02 25 f0    	mov    0xf0250244,%esi
f0103512:	8b 15 48 02 25 f0    	mov    0xf0250248,%edx
f0103518:	8d 86 80 ff 01 00    	lea    0x1ff80(%esi),%eax
f010351e:	89 f3                	mov    %esi,%ebx
f0103520:	eb 02                	jmp    f0103524 <env_init+0x1d>
f0103522:	89 c8                	mov    %ecx,%eax
f0103524:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f010352b:	89 50 44             	mov    %edx,0x44(%eax)
		envs[i].env_type = ENV_FREE;
f010352e:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
f0103535:	8d 48 80             	lea    -0x80(%eax),%ecx
		env_free_list = &envs[i];
f0103538:	89 c2                	mov    %eax,%edx
	for (int i = NENV - 1; i >= 0; i--) {
f010353a:	39 d8                	cmp    %ebx,%eax
f010353c:	75 e4                	jne    f0103522 <env_init+0x1b>
f010353e:	89 35 48 02 25 f0    	mov    %esi,0xf0250248
	env_init_percpu();
f0103544:	e8 92 ff ff ff       	call   f01034db <env_init_percpu>
}
f0103549:	5b                   	pop    %ebx
f010354a:	5e                   	pop    %esi
f010354b:	5d                   	pop    %ebp
f010354c:	c3                   	ret    

f010354d <env_alloc>:
{
f010354d:	55                   	push   %ebp
f010354e:	89 e5                	mov    %esp,%ebp
f0103550:	53                   	push   %ebx
f0103551:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f0103554:	8b 1d 48 02 25 f0    	mov    0xf0250248,%ebx
f010355a:	85 db                	test   %ebx,%ebx
f010355c:	0f 84 76 01 00 00    	je     f01036d8 <env_alloc+0x18b>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103562:	83 ec 0c             	sub    $0xc,%esp
f0103565:	6a 01                	push   $0x1
f0103567:	e8 72 dd ff ff       	call   f01012de <page_alloc>
f010356c:	83 c4 10             	add    $0x10,%esp
f010356f:	85 c0                	test   %eax,%eax
f0103571:	0f 84 68 01 00 00    	je     f01036df <env_alloc+0x192>
	return (pp - pages) << PGSHIFT;
f0103577:	89 c2                	mov    %eax,%edx
f0103579:	2b 15 90 0e 25 f0    	sub    0xf0250e90,%edx
f010357f:	c1 fa 03             	sar    $0x3,%edx
f0103582:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103585:	89 d1                	mov    %edx,%ecx
f0103587:	c1 e9 0c             	shr    $0xc,%ecx
f010358a:	3b 0d 88 0e 25 f0    	cmp    0xf0250e88,%ecx
f0103590:	73 35                	jae    f01035c7 <env_alloc+0x7a>
	return (void *)(pa + KERNBASE);
f0103592:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103598:	89 53 64             	mov    %edx,0x64(%ebx)
	p->pp_ref++;
f010359b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	for (int i = PDX(UTOP); i < NPDENTRIES; i++) {
f01035a0:	b8 bb 03 00 00       	mov    $0x3bb,%eax
		e->env_pgdir[i] = kern_pgdir[i];
f01035a5:	8b 15 8c 0e 25 f0    	mov    0xf0250e8c,%edx
f01035ab:	8b 0c 82             	mov    (%edx,%eax,4),%ecx
f01035ae:	8b 53 64             	mov    0x64(%ebx),%edx
f01035b1:	89 0c 82             	mov    %ecx,(%edx,%eax,4)
	for (int i = PDX(UTOP); i < NPDENTRIES; i++) {
f01035b4:	83 c0 01             	add    $0x1,%eax
f01035b7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01035bc:	7f 1b                	jg     f01035d9 <env_alloc+0x8c>
		if (i == PDX(UVPT)) continue;
f01035be:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01035c3:	75 e0                	jne    f01035a5 <env_alloc+0x58>
f01035c5:	eb ed                	jmp    f01035b4 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01035c7:	52                   	push   %edx
f01035c8:	68 d4 68 10 f0       	push   $0xf01068d4
f01035cd:	6a 58                	push   $0x58
f01035cf:	68 79 7a 10 f0       	push   $0xf0107a79
f01035d4:	e8 67 ca ff ff       	call   f0100040 <_panic>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01035d9:	8b 43 64             	mov    0x64(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01035dc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035e1:	0f 86 dc 00 00 00    	jbe    f01036c3 <env_alloc+0x176>
	return (physaddr_t)kva - KERNBASE;
f01035e7:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01035ed:	83 ca 05             	or     $0x5,%edx
f01035f0:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01035f6:	8b 43 48             	mov    0x48(%ebx),%eax
f01035f9:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01035fe:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0103603:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103608:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f010360b:	89 da                	mov    %ebx,%edx
f010360d:	2b 15 44 02 25 f0    	sub    0xf0250244,%edx
f0103613:	c1 fa 07             	sar    $0x7,%edx
f0103616:	09 d0                	or     %edx,%eax
f0103618:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f010361b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010361e:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103621:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103628:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010362f:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103636:	83 ec 04             	sub    $0x4,%esp
f0103639:	6a 44                	push   $0x44
f010363b:	6a 00                	push   $0x0
f010363d:	53                   	push   %ebx
f010363e:	e8 ba 25 00 00       	call   f0105bfd <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103643:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103649:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010364f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103655:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010365c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_pgfault_upcall = 0;
f0103662:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)
	e->env_ipc_recving = 0;
f0103669:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
	env_free_list = e->env_link;
f010366d:	8b 43 44             	mov    0x44(%ebx),%eax
f0103670:	a3 48 02 25 f0       	mov    %eax,0xf0250248
	*newenv_store = e;
f0103675:	8b 45 08             	mov    0x8(%ebp),%eax
f0103678:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010367a:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010367d:	e8 7c 2b 00 00       	call   f01061fe <cpunum>
f0103682:	6b c0 74             	imul   $0x74,%eax,%eax
f0103685:	83 c4 10             	add    $0x10,%esp
f0103688:	ba 00 00 00 00       	mov    $0x0,%edx
f010368d:	83 b8 28 10 25 f0 00 	cmpl   $0x0,-0xfdaefd8(%eax)
f0103694:	74 11                	je     f01036a7 <env_alloc+0x15a>
f0103696:	e8 63 2b 00 00       	call   f01061fe <cpunum>
f010369b:	6b c0 74             	imul   $0x74,%eax,%eax
f010369e:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f01036a4:	8b 50 48             	mov    0x48(%eax),%edx
f01036a7:	83 ec 04             	sub    $0x4,%esp
f01036aa:	53                   	push   %ebx
f01036ab:	52                   	push   %edx
f01036ac:	68 d5 7d 10 f0       	push   $0xf0107dd5
f01036b1:	e8 1f 06 00 00       	call   f0103cd5 <cprintf>
	return 0;
f01036b6:	83 c4 10             	add    $0x10,%esp
f01036b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01036c1:	c9                   	leave  
f01036c2:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036c3:	50                   	push   %eax
f01036c4:	68 f8 68 10 f0       	push   $0xf01068f8
f01036c9:	68 c9 00 00 00       	push   $0xc9
f01036ce:	68 ca 7d 10 f0       	push   $0xf0107dca
f01036d3:	e8 68 c9 ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f01036d8:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01036dd:	eb df                	jmp    f01036be <env_alloc+0x171>
		return -E_NO_MEM;
f01036df:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01036e4:	eb d8                	jmp    f01036be <env_alloc+0x171>

f01036e6 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01036e6:	55                   	push   %ebp
f01036e7:	89 e5                	mov    %esp,%ebp
f01036e9:	57                   	push   %edi
f01036ea:	56                   	push   %esi
f01036eb:	53                   	push   %ebx
f01036ec:	83 ec 34             	sub    $0x34,%esp
f01036ef:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	struct Env *env;
	env_alloc(&env, 0);
f01036f2:	6a 00                	push   $0x0
f01036f4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01036f7:	50                   	push   %eax
f01036f8:	e8 50 fe ff ff       	call   f010354d <env_alloc>
	load_icode(env, binary);
f01036fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	ph = (struct Proghdr *) ((uint8_t *) elf + elf->e_phoff);
f0103700:	89 f3                	mov    %esi,%ebx
f0103702:	03 5e 1c             	add    0x1c(%esi),%ebx
	eph = ph + elf->e_phnum;
f0103705:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
f0103709:	c1 e0 05             	shl    $0x5,%eax
f010370c:	01 d8                	add    %ebx,%eax
f010370e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	lcr3(PADDR(e->env_pgdir));
f0103711:	8b 47 64             	mov    0x64(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103714:	83 c4 10             	add    $0x10,%esp
f0103717:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010371c:	76 0a                	jbe    f0103728 <env_create+0x42>
	return (physaddr_t)kva - KERNBASE;
f010371e:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103723:	0f 22 d8             	mov    %eax,%cr3
f0103726:	eb 18                	jmp    f0103740 <env_create+0x5a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103728:	50                   	push   %eax
f0103729:	68 f8 68 10 f0       	push   $0xf01068f8
f010372e:	68 6e 01 00 00       	push   $0x16e
f0103733:	68 ca 7d 10 f0       	push   $0xf0107dca
f0103738:	e8 03 c9 ff ff       	call   f0100040 <_panic>
	for (; ph < eph; ph++) {
f010373d:	83 c3 20             	add    $0x20,%ebx
f0103740:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103743:	76 3b                	jbe    f0103780 <env_create+0x9a>
		if (ph->p_type != ELF_PROG_LOAD) continue;
f0103745:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103748:	75 f3                	jne    f010373d <env_create+0x57>
		region_alloc(e, (void*)ph->p_va, ph->p_memsz);
f010374a:	8b 4b 14             	mov    0x14(%ebx),%ecx
f010374d:	8b 53 08             	mov    0x8(%ebx),%edx
f0103750:	89 f8                	mov    %edi,%eax
f0103752:	e8 7c fc ff ff       	call   f01033d3 <region_alloc>
		memset((void*)ph->p_va, 0, ph->p_memsz);
f0103757:	83 ec 04             	sub    $0x4,%esp
f010375a:	ff 73 14             	pushl  0x14(%ebx)
f010375d:	6a 00                	push   $0x0
f010375f:	ff 73 08             	pushl  0x8(%ebx)
f0103762:	e8 96 24 00 00       	call   f0105bfd <memset>
		memmove((void*)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103767:	83 c4 0c             	add    $0xc,%esp
f010376a:	ff 73 10             	pushl  0x10(%ebx)
f010376d:	89 f0                	mov    %esi,%eax
f010376f:	03 43 04             	add    0x4(%ebx),%eax
f0103772:	50                   	push   %eax
f0103773:	ff 73 08             	pushl  0x8(%ebx)
f0103776:	e8 ca 24 00 00       	call   f0105c45 <memmove>
f010377b:	83 c4 10             	add    $0x10,%esp
f010377e:	eb bd                	jmp    f010373d <env_create+0x57>
	lcr3(PADDR(kern_pgdir));
f0103780:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103785:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010378a:	76 37                	jbe    f01037c3 <env_create+0xdd>
	return (physaddr_t)kva - KERNBASE;
f010378c:	05 00 00 00 10       	add    $0x10000000,%eax
f0103791:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = elf->e_entry;
f0103794:	8b 46 18             	mov    0x18(%esi),%eax
f0103797:	89 47 30             	mov    %eax,0x30(%edi)
	e->env_break = UTEXT;
f010379a:	c7 47 60 00 00 80 00 	movl   $0x800000,0x60(%edi)
	region_alloc(e, (void*)USTACKTOP - PGSIZE, PGSIZE);
f01037a1:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01037a6:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01037ab:	89 f8                	mov    %edi,%eax
f01037ad:	e8 21 fc ff ff       	call   f01033d3 <region_alloc>
	env->env_type = type;
f01037b2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01037b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01037b8:	89 50 50             	mov    %edx,0x50(%eax)
}
f01037bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037be:	5b                   	pop    %ebx
f01037bf:	5e                   	pop    %esi
f01037c0:	5f                   	pop    %edi
f01037c1:	5d                   	pop    %ebp
f01037c2:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037c3:	50                   	push   %eax
f01037c4:	68 f8 68 10 f0       	push   $0xf01068f8
f01037c9:	68 78 01 00 00       	push   $0x178
f01037ce:	68 ca 7d 10 f0       	push   $0xf0107dca
f01037d3:	e8 68 c8 ff ff       	call   f0100040 <_panic>

f01037d8 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01037d8:	55                   	push   %ebp
f01037d9:	89 e5                	mov    %esp,%ebp
f01037db:	57                   	push   %edi
f01037dc:	56                   	push   %esi
f01037dd:	53                   	push   %ebx
f01037de:	83 ec 1c             	sub    $0x1c,%esp
f01037e1:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01037e4:	e8 15 2a 00 00       	call   f01061fe <cpunum>
f01037e9:	6b c0 74             	imul   $0x74,%eax,%eax
f01037ec:	39 b8 28 10 25 f0    	cmp    %edi,-0xfdaefd8(%eax)
f01037f2:	74 48                	je     f010383c <env_free+0x64>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01037f4:	8b 5f 48             	mov    0x48(%edi),%ebx
f01037f7:	e8 02 2a 00 00       	call   f01061fe <cpunum>
f01037fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01037ff:	ba 00 00 00 00       	mov    $0x0,%edx
f0103804:	83 b8 28 10 25 f0 00 	cmpl   $0x0,-0xfdaefd8(%eax)
f010380b:	74 11                	je     f010381e <env_free+0x46>
f010380d:	e8 ec 29 00 00       	call   f01061fe <cpunum>
f0103812:	6b c0 74             	imul   $0x74,%eax,%eax
f0103815:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f010381b:	8b 50 48             	mov    0x48(%eax),%edx
f010381e:	83 ec 04             	sub    $0x4,%esp
f0103821:	53                   	push   %ebx
f0103822:	52                   	push   %edx
f0103823:	68 ea 7d 10 f0       	push   $0xf0107dea
f0103828:	e8 a8 04 00 00       	call   f0103cd5 <cprintf>
f010382d:	83 c4 10             	add    $0x10,%esp
f0103830:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103837:	e9 a9 00 00 00       	jmp    f01038e5 <env_free+0x10d>
		lcr3(PADDR(kern_pgdir));
f010383c:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103841:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103846:	76 0a                	jbe    f0103852 <env_free+0x7a>
	return (physaddr_t)kva - KERNBASE;
f0103848:	05 00 00 00 10       	add    $0x10000000,%eax
f010384d:	0f 22 d8             	mov    %eax,%cr3
f0103850:	eb a2                	jmp    f01037f4 <env_free+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103852:	50                   	push   %eax
f0103853:	68 f8 68 10 f0       	push   $0xf01068f8
f0103858:	68 a2 01 00 00       	push   $0x1a2
f010385d:	68 ca 7d 10 f0       	push   $0xf0107dca
f0103862:	e8 d9 c7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103867:	56                   	push   %esi
f0103868:	68 d4 68 10 f0       	push   $0xf01068d4
f010386d:	68 b1 01 00 00       	push   $0x1b1
f0103872:	68 ca 7d 10 f0       	push   $0xf0107dca
f0103877:	e8 c4 c7 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010387c:	83 ec 08             	sub    $0x8,%esp
f010387f:	89 d8                	mov    %ebx,%eax
f0103881:	c1 e0 0c             	shl    $0xc,%eax
f0103884:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103887:	50                   	push   %eax
f0103888:	ff 77 64             	pushl  0x64(%edi)
f010388b:	e8 b0 dc ff ff       	call   f0101540 <page_remove>
f0103890:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103893:	83 c3 01             	add    $0x1,%ebx
f0103896:	83 c6 04             	add    $0x4,%esi
f0103899:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f010389f:	74 07                	je     f01038a8 <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f01038a1:	f6 06 01             	testb  $0x1,(%esi)
f01038a4:	74 ed                	je     f0103893 <env_free+0xbb>
f01038a6:	eb d4                	jmp    f010387c <env_free+0xa4>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01038a8:	8b 47 64             	mov    0x64(%edi),%eax
f01038ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01038ae:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01038b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01038b8:	3b 05 88 0e 25 f0    	cmp    0xf0250e88,%eax
f01038be:	73 69                	jae    f0103929 <env_free+0x151>
		page_decref(pa2page(pa));
f01038c0:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01038c3:	a1 90 0e 25 f0       	mov    0xf0250e90,%eax
f01038c8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01038cb:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01038ce:	50                   	push   %eax
f01038cf:	e8 bd da ff ff       	call   f0101391 <page_decref>
f01038d4:	83 c4 10             	add    $0x10,%esp
f01038d7:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01038db:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01038de:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01038e3:	74 58                	je     f010393d <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01038e5:	8b 47 64             	mov    0x64(%edi),%eax
f01038e8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01038eb:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01038ee:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01038f4:	74 e1                	je     f01038d7 <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01038f6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f01038fc:	89 f0                	mov    %esi,%eax
f01038fe:	c1 e8 0c             	shr    $0xc,%eax
f0103901:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103904:	39 05 88 0e 25 f0    	cmp    %eax,0xf0250e88
f010390a:	0f 86 57 ff ff ff    	jbe    f0103867 <env_free+0x8f>
	return (void *)(pa + KERNBASE);
f0103910:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103916:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103919:	c1 e0 14             	shl    $0x14,%eax
f010391c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010391f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103924:	e9 78 ff ff ff       	jmp    f01038a1 <env_free+0xc9>
		panic("pa2page called with invalid pa");
f0103929:	83 ec 04             	sub    $0x4,%esp
f010392c:	68 e4 71 10 f0       	push   $0xf01071e4
f0103931:	6a 51                	push   $0x51
f0103933:	68 79 7a 10 f0       	push   $0xf0107a79
f0103938:	e8 03 c7 ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010393d:	8b 47 64             	mov    0x64(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f0103940:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103945:	76 49                	jbe    f0103990 <env_free+0x1b8>
	e->env_pgdir = 0;
f0103947:	c7 47 64 00 00 00 00 	movl   $0x0,0x64(%edi)
	return (physaddr_t)kva - KERNBASE;
f010394e:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103953:	c1 e8 0c             	shr    $0xc,%eax
f0103956:	3b 05 88 0e 25 f0    	cmp    0xf0250e88,%eax
f010395c:	73 47                	jae    f01039a5 <env_free+0x1cd>
	page_decref(pa2page(pa));
f010395e:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103961:	8b 15 90 0e 25 f0    	mov    0xf0250e90,%edx
f0103967:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010396a:	50                   	push   %eax
f010396b:	e8 21 da ff ff       	call   f0101391 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103970:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103977:	a1 48 02 25 f0       	mov    0xf0250248,%eax
f010397c:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010397f:	89 3d 48 02 25 f0    	mov    %edi,0xf0250248
}
f0103985:	83 c4 10             	add    $0x10,%esp
f0103988:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010398b:	5b                   	pop    %ebx
f010398c:	5e                   	pop    %esi
f010398d:	5f                   	pop    %edi
f010398e:	5d                   	pop    %ebp
f010398f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103990:	50                   	push   %eax
f0103991:	68 f8 68 10 f0       	push   $0xf01068f8
f0103996:	68 bf 01 00 00       	push   $0x1bf
f010399b:	68 ca 7d 10 f0       	push   $0xf0107dca
f01039a0:	e8 9b c6 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f01039a5:	83 ec 04             	sub    $0x4,%esp
f01039a8:	68 e4 71 10 f0       	push   $0xf01071e4
f01039ad:	6a 51                	push   $0x51
f01039af:	68 79 7a 10 f0       	push   $0xf0107a79
f01039b4:	e8 87 c6 ff ff       	call   f0100040 <_panic>

f01039b9 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01039b9:	55                   	push   %ebp
f01039ba:	89 e5                	mov    %esp,%ebp
f01039bc:	53                   	push   %ebx
f01039bd:	83 ec 04             	sub    $0x4,%esp
f01039c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01039c3:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01039c7:	74 21                	je     f01039ea <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f01039c9:	83 ec 0c             	sub    $0xc,%esp
f01039cc:	53                   	push   %ebx
f01039cd:	e8 06 fe ff ff       	call   f01037d8 <env_free>

	if (curenv == e) {
f01039d2:	e8 27 28 00 00       	call   f01061fe <cpunum>
f01039d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01039da:	83 c4 10             	add    $0x10,%esp
f01039dd:	39 98 28 10 25 f0    	cmp    %ebx,-0xfdaefd8(%eax)
f01039e3:	74 1e                	je     f0103a03 <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f01039e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01039e8:	c9                   	leave  
f01039e9:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01039ea:	e8 0f 28 00 00       	call   f01061fe <cpunum>
f01039ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01039f2:	39 98 28 10 25 f0    	cmp    %ebx,-0xfdaefd8(%eax)
f01039f8:	74 cf                	je     f01039c9 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f01039fa:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103a01:	eb e2                	jmp    f01039e5 <env_destroy+0x2c>
		curenv = NULL;
f0103a03:	e8 f6 27 00 00       	call   f01061fe <cpunum>
f0103a08:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a0b:	c7 80 28 10 25 f0 00 	movl   $0x0,-0xfdaefd8(%eax)
f0103a12:	00 00 00 
		sched_yield();
f0103a15:	e8 e8 0d 00 00       	call   f0104802 <sched_yield>

f0103a1a <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103a1a:	55                   	push   %ebp
f0103a1b:	89 e5                	mov    %esp,%ebp
f0103a1d:	53                   	push   %ebx
f0103a1e:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103a21:	e8 d8 27 00 00       	call   f01061fe <cpunum>
f0103a26:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a29:	8b 98 28 10 25 f0    	mov    -0xfdaefd8(%eax),%ebx
f0103a2f:	e8 ca 27 00 00       	call   f01061fe <cpunum>
f0103a34:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103a37:	8b 65 08             	mov    0x8(%ebp),%esp
f0103a3a:	61                   	popa   
f0103a3b:	07                   	pop    %es
f0103a3c:	1f                   	pop    %ds
f0103a3d:	83 c4 08             	add    $0x8,%esp
f0103a40:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103a41:	83 ec 04             	sub    $0x4,%esp
f0103a44:	68 00 7e 10 f0       	push   $0xf0107e00
f0103a49:	68 f6 01 00 00       	push   $0x1f6
f0103a4e:	68 ca 7d 10 f0       	push   $0xf0107dca
f0103a53:	e8 e8 c5 ff ff       	call   f0100040 <_panic>

f0103a58 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103a58:	55                   	push   %ebp
f0103a59:	89 e5                	mov    %esp,%ebp
f0103a5b:	53                   	push   %ebx
f0103a5c:	83 ec 04             	sub    $0x4,%esp
f0103a5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != e) { 
f0103a62:	e8 97 27 00 00       	call   f01061fe <cpunum>
f0103a67:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a6a:	39 98 28 10 25 f0    	cmp    %ebx,-0xfdaefd8(%eax)
f0103a70:	74 7a                	je     f0103aec <env_run+0x94>
		if (curenv && curenv->env_status == ENV_RUNNING) curenv->env_status = ENV_RUNNABLE;
f0103a72:	e8 87 27 00 00       	call   f01061fe <cpunum>
f0103a77:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a7a:	83 b8 28 10 25 f0 00 	cmpl   $0x0,-0xfdaefd8(%eax)
f0103a81:	74 14                	je     f0103a97 <env_run+0x3f>
f0103a83:	e8 76 27 00 00       	call   f01061fe <cpunum>
f0103a88:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a8b:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0103a91:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103a95:	74 7a                	je     f0103b11 <env_run+0xb9>
		curenv = e;
f0103a97:	e8 62 27 00 00       	call   f01061fe <cpunum>
f0103a9c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a9f:	89 98 28 10 25 f0    	mov    %ebx,-0xfdaefd8(%eax)
		curenv->env_status = ENV_RUNNING;
f0103aa5:	e8 54 27 00 00       	call   f01061fe <cpunum>
f0103aaa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103aad:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0103ab3:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		curenv->env_runs++;
f0103aba:	e8 3f 27 00 00       	call   f01061fe <cpunum>
f0103abf:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ac2:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0103ac8:	83 40 58 01          	addl   $0x1,0x58(%eax)

		lcr3(PADDR(curenv->env_pgdir));
f0103acc:	e8 2d 27 00 00       	call   f01061fe <cpunum>
f0103ad1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ad4:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0103ada:	8b 40 64             	mov    0x64(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0103add:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ae2:	76 47                	jbe    f0103b2b <env_run+0xd3>
	return (physaddr_t)kva - KERNBASE;
f0103ae4:	05 00 00 00 10       	add    $0x10000000,%eax
f0103ae9:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103aec:	83 ec 0c             	sub    $0xc,%esp
f0103aef:	68 c0 43 12 f0       	push   $0xf01243c0
f0103af4:	e8 11 2a 00 00       	call   f010650a <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103af9:	f3 90                	pause  
	}

	unlock_kernel();
	env_pop_tf(&curenv->env_tf);
f0103afb:	e8 fe 26 00 00       	call   f01061fe <cpunum>
f0103b00:	83 c4 04             	add    $0x4,%esp
f0103b03:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b06:	ff b0 28 10 25 f0    	pushl  -0xfdaefd8(%eax)
f0103b0c:	e8 09 ff ff ff       	call   f0103a1a <env_pop_tf>
		if (curenv && curenv->env_status == ENV_RUNNING) curenv->env_status = ENV_RUNNABLE;
f0103b11:	e8 e8 26 00 00       	call   f01061fe <cpunum>
f0103b16:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b19:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0103b1f:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103b26:	e9 6c ff ff ff       	jmp    f0103a97 <env_run+0x3f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b2b:	50                   	push   %eax
f0103b2c:	68 f8 68 10 f0       	push   $0xf01068f8
f0103b31:	68 1a 02 00 00       	push   $0x21a
f0103b36:	68 ca 7d 10 f0       	push   $0xf0107dca
f0103b3b:	e8 00 c5 ff ff       	call   f0100040 <_panic>

f0103b40 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103b40:	55                   	push   %ebp
f0103b41:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103b43:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b46:	ba 70 00 00 00       	mov    $0x70,%edx
f0103b4b:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103b4c:	ba 71 00 00 00       	mov    $0x71,%edx
f0103b51:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103b52:	0f b6 c0             	movzbl %al,%eax
}
f0103b55:	5d                   	pop    %ebp
f0103b56:	c3                   	ret    

f0103b57 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103b57:	55                   	push   %ebp
f0103b58:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103b5a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b5d:	ba 70 00 00 00       	mov    $0x70,%edx
f0103b62:	ee                   	out    %al,(%dx)
f0103b63:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b66:	ba 71 00 00 00       	mov    $0x71,%edx
f0103b6b:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103b6c:	5d                   	pop    %ebp
f0103b6d:	c3                   	ret    

f0103b6e <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103b6e:	55                   	push   %ebp
f0103b6f:	89 e5                	mov    %esp,%ebp
f0103b71:	56                   	push   %esi
f0103b72:	53                   	push   %ebx
f0103b73:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103b76:	66 a3 a8 43 12 f0    	mov    %ax,0xf01243a8
	if (!didinit)
f0103b7c:	80 3d 4c 02 25 f0 00 	cmpb   $0x0,0xf025024c
f0103b83:	75 07                	jne    f0103b8c <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103b85:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103b88:	5b                   	pop    %ebx
f0103b89:	5e                   	pop    %esi
f0103b8a:	5d                   	pop    %ebp
f0103b8b:	c3                   	ret    
f0103b8c:	89 c6                	mov    %eax,%esi
f0103b8e:	ba 21 00 00 00       	mov    $0x21,%edx
f0103b93:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103b94:	66 c1 e8 08          	shr    $0x8,%ax
f0103b98:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103b9d:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103b9e:	83 ec 0c             	sub    $0xc,%esp
f0103ba1:	68 0c 7e 10 f0       	push   $0xf0107e0c
f0103ba6:	e8 2a 01 00 00       	call   f0103cd5 <cprintf>
f0103bab:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103bae:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103bb3:	0f b7 f6             	movzwl %si,%esi
f0103bb6:	f7 d6                	not    %esi
f0103bb8:	eb 19                	jmp    f0103bd3 <irq_setmask_8259A+0x65>
			cprintf(" %d", i);
f0103bba:	83 ec 08             	sub    $0x8,%esp
f0103bbd:	53                   	push   %ebx
f0103bbe:	68 f3 82 10 f0       	push   $0xf01082f3
f0103bc3:	e8 0d 01 00 00       	call   f0103cd5 <cprintf>
f0103bc8:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103bcb:	83 c3 01             	add    $0x1,%ebx
f0103bce:	83 fb 10             	cmp    $0x10,%ebx
f0103bd1:	74 07                	je     f0103bda <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f0103bd3:	0f a3 de             	bt     %ebx,%esi
f0103bd6:	73 f3                	jae    f0103bcb <irq_setmask_8259A+0x5d>
f0103bd8:	eb e0                	jmp    f0103bba <irq_setmask_8259A+0x4c>
	cprintf("\n");
f0103bda:	83 ec 0c             	sub    $0xc,%esp
f0103bdd:	68 68 7d 10 f0       	push   $0xf0107d68
f0103be2:	e8 ee 00 00 00       	call   f0103cd5 <cprintf>
f0103be7:	83 c4 10             	add    $0x10,%esp
f0103bea:	eb 99                	jmp    f0103b85 <irq_setmask_8259A+0x17>

f0103bec <pic_init>:
{
f0103bec:	55                   	push   %ebp
f0103bed:	89 e5                	mov    %esp,%ebp
f0103bef:	57                   	push   %edi
f0103bf0:	56                   	push   %esi
f0103bf1:	53                   	push   %ebx
f0103bf2:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103bf5:	c6 05 4c 02 25 f0 01 	movb   $0x1,0xf025024c
f0103bfc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c01:	bb 21 00 00 00       	mov    $0x21,%ebx
f0103c06:	89 da                	mov    %ebx,%edx
f0103c08:	ee                   	out    %al,(%dx)
f0103c09:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103c0e:	89 ca                	mov    %ecx,%edx
f0103c10:	ee                   	out    %al,(%dx)
f0103c11:	bf 11 00 00 00       	mov    $0x11,%edi
f0103c16:	be 20 00 00 00       	mov    $0x20,%esi
f0103c1b:	89 f8                	mov    %edi,%eax
f0103c1d:	89 f2                	mov    %esi,%edx
f0103c1f:	ee                   	out    %al,(%dx)
f0103c20:	b8 20 00 00 00       	mov    $0x20,%eax
f0103c25:	89 da                	mov    %ebx,%edx
f0103c27:	ee                   	out    %al,(%dx)
f0103c28:	b8 04 00 00 00       	mov    $0x4,%eax
f0103c2d:	ee                   	out    %al,(%dx)
f0103c2e:	b8 03 00 00 00       	mov    $0x3,%eax
f0103c33:	ee                   	out    %al,(%dx)
f0103c34:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103c39:	89 f8                	mov    %edi,%eax
f0103c3b:	89 da                	mov    %ebx,%edx
f0103c3d:	ee                   	out    %al,(%dx)
f0103c3e:	b8 28 00 00 00       	mov    $0x28,%eax
f0103c43:	89 ca                	mov    %ecx,%edx
f0103c45:	ee                   	out    %al,(%dx)
f0103c46:	b8 02 00 00 00       	mov    $0x2,%eax
f0103c4b:	ee                   	out    %al,(%dx)
f0103c4c:	b8 01 00 00 00       	mov    $0x1,%eax
f0103c51:	ee                   	out    %al,(%dx)
f0103c52:	bf 68 00 00 00       	mov    $0x68,%edi
f0103c57:	89 f8                	mov    %edi,%eax
f0103c59:	89 f2                	mov    %esi,%edx
f0103c5b:	ee                   	out    %al,(%dx)
f0103c5c:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103c61:	89 c8                	mov    %ecx,%eax
f0103c63:	ee                   	out    %al,(%dx)
f0103c64:	89 f8                	mov    %edi,%eax
f0103c66:	89 da                	mov    %ebx,%edx
f0103c68:	ee                   	out    %al,(%dx)
f0103c69:	89 c8                	mov    %ecx,%eax
f0103c6b:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103c6c:	0f b7 05 a8 43 12 f0 	movzwl 0xf01243a8,%eax
f0103c73:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103c77:	75 08                	jne    f0103c81 <pic_init+0x95>
}
f0103c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c7c:	5b                   	pop    %ebx
f0103c7d:	5e                   	pop    %esi
f0103c7e:	5f                   	pop    %edi
f0103c7f:	5d                   	pop    %ebp
f0103c80:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f0103c81:	83 ec 0c             	sub    $0xc,%esp
f0103c84:	0f b7 c0             	movzwl %ax,%eax
f0103c87:	50                   	push   %eax
f0103c88:	e8 e1 fe ff ff       	call   f0103b6e <irq_setmask_8259A>
f0103c8d:	83 c4 10             	add    $0x10,%esp
}
f0103c90:	eb e7                	jmp    f0103c79 <pic_init+0x8d>

f0103c92 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103c92:	55                   	push   %ebp
f0103c93:	89 e5                	mov    %esp,%ebp
f0103c95:	53                   	push   %ebx
f0103c96:	83 ec 10             	sub    $0x10,%esp
f0103c99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f0103c9c:	ff 75 08             	pushl  0x8(%ebp)
f0103c9f:	e8 78 cb ff ff       	call   f010081c <cputchar>
	(*cnt)++;
f0103ca4:	83 03 01             	addl   $0x1,(%ebx)
}
f0103ca7:	83 c4 10             	add    $0x10,%esp
f0103caa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103cad:	c9                   	leave  
f0103cae:	c3                   	ret    

f0103caf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103caf:	55                   	push   %ebp
f0103cb0:	89 e5                	mov    %esp,%ebp
f0103cb2:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103cb5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103cbc:	ff 75 0c             	pushl  0xc(%ebp)
f0103cbf:	ff 75 08             	pushl  0x8(%ebp)
f0103cc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103cc5:	50                   	push   %eax
f0103cc6:	68 92 3c 10 f0       	push   $0xf0103c92
f0103ccb:	e8 4d 16 00 00       	call   f010531d <vprintfmt>
	return cnt;
}
f0103cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103cd3:	c9                   	leave  
f0103cd4:	c3                   	ret    

f0103cd5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103cd5:	55                   	push   %ebp
f0103cd6:	89 e5                	mov    %esp,%ebp
f0103cd8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103cdb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103cde:	50                   	push   %eax
f0103cdf:	ff 75 08             	pushl  0x8(%ebp)
f0103ce2:	e8 c8 ff ff ff       	call   f0103caf <vcprintf>
	va_end(ap);

	return cnt;
}
f0103ce7:	c9                   	leave  
f0103ce8:	c3                   	ret    

f0103ce9 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103ce9:	55                   	push   %ebp
f0103cea:	89 e5                	mov    %esp,%ebp
f0103cec:	57                   	push   %edi
f0103ced:	56                   	push   %esi
f0103cee:	53                   	push   %ebx
f0103cef:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - thiscpu->cpu_id * (KSTKSIZE + KSTKGAP);
f0103cf2:	e8 07 25 00 00       	call   f01061fe <cpunum>
f0103cf7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cfa:	0f b6 98 20 10 25 f0 	movzbl -0xfdaefe0(%eax),%ebx
f0103d01:	c1 e3 10             	shl    $0x10,%ebx
f0103d04:	e8 f5 24 00 00       	call   f01061fe <cpunum>
f0103d09:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d0c:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103d11:	29 da                	sub    %ebx,%edx
f0103d13:	89 90 30 10 25 f0    	mov    %edx,-0xfdaefd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103d19:	e8 e0 24 00 00       	call   f01061fe <cpunum>
f0103d1e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d21:	66 c7 80 34 10 25 f0 	movw   $0x10,-0xfdaefcc(%eax)
f0103d28:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f0103d2a:	e8 cf 24 00 00       	call   f01061fe <cpunum>
f0103d2f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d32:	66 c7 80 92 10 25 f0 	movw   $0x68,-0xfdaef6e(%eax)
f0103d39:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103d3b:	e8 be 24 00 00       	call   f01061fe <cpunum>
f0103d40:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d43:	0f b6 98 20 10 25 f0 	movzbl -0xfdaefe0(%eax),%ebx
f0103d4a:	83 c3 05             	add    $0x5,%ebx
f0103d4d:	e8 ac 24 00 00       	call   f01061fe <cpunum>
f0103d52:	89 c7                	mov    %eax,%edi
f0103d54:	e8 a5 24 00 00       	call   f01061fe <cpunum>
f0103d59:	89 c6                	mov    %eax,%esi
f0103d5b:	e8 9e 24 00 00       	call   f01061fe <cpunum>
f0103d60:	66 c7 04 dd 40 43 12 	movw   $0x67,-0xfedbcc0(,%ebx,8)
f0103d67:	f0 67 00 
f0103d6a:	6b ff 74             	imul   $0x74,%edi,%edi
f0103d6d:	81 c7 2c 10 25 f0    	add    $0xf025102c,%edi
f0103d73:	66 89 3c dd 42 43 12 	mov    %di,-0xfedbcbe(,%ebx,8)
f0103d7a:	f0 
f0103d7b:	6b d6 74             	imul   $0x74,%esi,%edx
f0103d7e:	81 c2 2c 10 25 f0    	add    $0xf025102c,%edx
f0103d84:	c1 ea 10             	shr    $0x10,%edx
f0103d87:	88 14 dd 44 43 12 f0 	mov    %dl,-0xfedbcbc(,%ebx,8)
f0103d8e:	c6 04 dd 45 43 12 f0 	movb   $0x99,-0xfedbcbb(,%ebx,8)
f0103d95:	99 
f0103d96:	c6 04 dd 46 43 12 f0 	movb   $0x40,-0xfedbcba(,%ebx,8)
f0103d9d:	40 
f0103d9e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103da1:	05 2c 10 25 f0       	add    $0xf025102c,%eax
f0103da6:	c1 e8 18             	shr    $0x18,%eax
f0103da9:	88 04 dd 47 43 12 f0 	mov    %al,-0xfedbcb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + thiscpu->cpu_id].sd_s = 0;
f0103db0:	e8 49 24 00 00       	call   f01061fe <cpunum>
f0103db5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db8:	0f b6 80 20 10 25 f0 	movzbl -0xfdaefe0(%eax),%eax
f0103dbf:	80 24 c5 6d 43 12 f0 	andb   $0xef,-0xfedbc93(,%eax,8)
f0103dc6:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (thiscpu->cpu_id << 3));
f0103dc7:	e8 32 24 00 00       	call   f01061fe <cpunum>
f0103dcc:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dcf:	0f b6 80 20 10 25 f0 	movzbl -0xfdaefe0(%eax),%eax
f0103dd6:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
	asm volatile("ltr %0" : : "r" (sel));
f0103ddd:	0f 00 d8             	ltr    %ax
	asm volatile("lidt (%0)" : : "r" (p));
f0103de0:	b8 ac 43 12 f0       	mov    $0xf01243ac,%eax
f0103de5:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103de8:	83 c4 0c             	add    $0xc,%esp
f0103deb:	5b                   	pop    %ebx
f0103dec:	5e                   	pop    %esi
f0103ded:	5f                   	pop    %edi
f0103dee:	5d                   	pop    %ebp
f0103def:	c3                   	ret    

f0103df0 <trap_init>:
{
f0103df0:	55                   	push   %ebp
f0103df1:	89 e5                	mov    %esp,%ebp
f0103df3:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[0], 1, GD_KT, H_DIVIDE, 0);
f0103df6:	b8 c0 46 10 f0       	mov    $0xf01046c0,%eax
f0103dfb:	66 a3 60 02 25 f0    	mov    %ax,0xf0250260
f0103e01:	66 c7 05 62 02 25 f0 	movw   $0x8,0xf0250262
f0103e08:	08 00 
f0103e0a:	c6 05 64 02 25 f0 00 	movb   $0x0,0xf0250264
f0103e11:	c6 05 65 02 25 f0 8f 	movb   $0x8f,0xf0250265
f0103e18:	c1 e8 10             	shr    $0x10,%eax
f0103e1b:	66 a3 66 02 25 f0    	mov    %ax,0xf0250266
	SETGATE(idt[1], 1, GD_KT, H_DEBUG, 0);
f0103e21:	b8 c6 46 10 f0       	mov    $0xf01046c6,%eax
f0103e26:	66 a3 68 02 25 f0    	mov    %ax,0xf0250268
f0103e2c:	66 c7 05 6a 02 25 f0 	movw   $0x8,0xf025026a
f0103e33:	08 00 
f0103e35:	c6 05 6c 02 25 f0 00 	movb   $0x0,0xf025026c
f0103e3c:	c6 05 6d 02 25 f0 8f 	movb   $0x8f,0xf025026d
f0103e43:	c1 e8 10             	shr    $0x10,%eax
f0103e46:	66 a3 6e 02 25 f0    	mov    %ax,0xf025026e
	SETGATE(idt[2], 1, GD_KT, H_NMI, 0);
f0103e4c:	b8 cc 46 10 f0       	mov    $0xf01046cc,%eax
f0103e51:	66 a3 70 02 25 f0    	mov    %ax,0xf0250270
f0103e57:	66 c7 05 72 02 25 f0 	movw   $0x8,0xf0250272
f0103e5e:	08 00 
f0103e60:	c6 05 74 02 25 f0 00 	movb   $0x0,0xf0250274
f0103e67:	c6 05 75 02 25 f0 8f 	movb   $0x8f,0xf0250275
f0103e6e:	c1 e8 10             	shr    $0x10,%eax
f0103e71:	66 a3 76 02 25 f0    	mov    %ax,0xf0250276
	SETGATE(idt[3], 1, GD_KT, H_BRKPT, 3);
f0103e77:	b8 d2 46 10 f0       	mov    $0xf01046d2,%eax
f0103e7c:	66 a3 78 02 25 f0    	mov    %ax,0xf0250278
f0103e82:	66 c7 05 7a 02 25 f0 	movw   $0x8,0xf025027a
f0103e89:	08 00 
f0103e8b:	c6 05 7c 02 25 f0 00 	movb   $0x0,0xf025027c
f0103e92:	c6 05 7d 02 25 f0 ef 	movb   $0xef,0xf025027d
f0103e99:	c1 e8 10             	shr    $0x10,%eax
f0103e9c:	66 a3 7e 02 25 f0    	mov    %ax,0xf025027e
	SETGATE(idt[4], 1, GD_KT, H_OFLOW, 3);
f0103ea2:	b8 d8 46 10 f0       	mov    $0xf01046d8,%eax
f0103ea7:	66 a3 80 02 25 f0    	mov    %ax,0xf0250280
f0103ead:	66 c7 05 82 02 25 f0 	movw   $0x8,0xf0250282
f0103eb4:	08 00 
f0103eb6:	c6 05 84 02 25 f0 00 	movb   $0x0,0xf0250284
f0103ebd:	c6 05 85 02 25 f0 ef 	movb   $0xef,0xf0250285
f0103ec4:	c1 e8 10             	shr    $0x10,%eax
f0103ec7:	66 a3 86 02 25 f0    	mov    %ax,0xf0250286
	SETGATE(idt[5], 1, GD_KT, H_BOUND, 3);
f0103ecd:	b8 de 46 10 f0       	mov    $0xf01046de,%eax
f0103ed2:	66 a3 88 02 25 f0    	mov    %ax,0xf0250288
f0103ed8:	66 c7 05 8a 02 25 f0 	movw   $0x8,0xf025028a
f0103edf:	08 00 
f0103ee1:	c6 05 8c 02 25 f0 00 	movb   $0x0,0xf025028c
f0103ee8:	c6 05 8d 02 25 f0 ef 	movb   $0xef,0xf025028d
f0103eef:	c1 e8 10             	shr    $0x10,%eax
f0103ef2:	66 a3 8e 02 25 f0    	mov    %ax,0xf025028e
	SETGATE(idt[6], 1, GD_KT, H_ILLOP, 0);
f0103ef8:	b8 e4 46 10 f0       	mov    $0xf01046e4,%eax
f0103efd:	66 a3 90 02 25 f0    	mov    %ax,0xf0250290
f0103f03:	66 c7 05 92 02 25 f0 	movw   $0x8,0xf0250292
f0103f0a:	08 00 
f0103f0c:	c6 05 94 02 25 f0 00 	movb   $0x0,0xf0250294
f0103f13:	c6 05 95 02 25 f0 8f 	movb   $0x8f,0xf0250295
f0103f1a:	c1 e8 10             	shr    $0x10,%eax
f0103f1d:	66 a3 96 02 25 f0    	mov    %ax,0xf0250296
	SETGATE(idt[7], 1, GD_KT, H_DEVICE, 0);
f0103f23:	b8 ea 46 10 f0       	mov    $0xf01046ea,%eax
f0103f28:	66 a3 98 02 25 f0    	mov    %ax,0xf0250298
f0103f2e:	66 c7 05 9a 02 25 f0 	movw   $0x8,0xf025029a
f0103f35:	08 00 
f0103f37:	c6 05 9c 02 25 f0 00 	movb   $0x0,0xf025029c
f0103f3e:	c6 05 9d 02 25 f0 8f 	movb   $0x8f,0xf025029d
f0103f45:	c1 e8 10             	shr    $0x10,%eax
f0103f48:	66 a3 9e 02 25 f0    	mov    %ax,0xf025029e
	SETGATE(idt[8], 1, GD_KT, H_DBLFLT, 0);
f0103f4e:	b8 f0 46 10 f0       	mov    $0xf01046f0,%eax
f0103f53:	66 a3 a0 02 25 f0    	mov    %ax,0xf02502a0
f0103f59:	66 c7 05 a2 02 25 f0 	movw   $0x8,0xf02502a2
f0103f60:	08 00 
f0103f62:	c6 05 a4 02 25 f0 00 	movb   $0x0,0xf02502a4
f0103f69:	c6 05 a5 02 25 f0 8f 	movb   $0x8f,0xf02502a5
f0103f70:	c1 e8 10             	shr    $0x10,%eax
f0103f73:	66 a3 a6 02 25 f0    	mov    %ax,0xf02502a6
	SETGATE(idt[10], 1, GD_KT, H_TSS, 0);
f0103f79:	b8 f4 46 10 f0       	mov    $0xf01046f4,%eax
f0103f7e:	66 a3 b0 02 25 f0    	mov    %ax,0xf02502b0
f0103f84:	66 c7 05 b2 02 25 f0 	movw   $0x8,0xf02502b2
f0103f8b:	08 00 
f0103f8d:	c6 05 b4 02 25 f0 00 	movb   $0x0,0xf02502b4
f0103f94:	c6 05 b5 02 25 f0 8f 	movb   $0x8f,0xf02502b5
f0103f9b:	c1 e8 10             	shr    $0x10,%eax
f0103f9e:	66 a3 b6 02 25 f0    	mov    %ax,0xf02502b6
	SETGATE(idt[11], 1, GD_KT, H_SEGNP, 0);
f0103fa4:	b8 f8 46 10 f0       	mov    $0xf01046f8,%eax
f0103fa9:	66 a3 b8 02 25 f0    	mov    %ax,0xf02502b8
f0103faf:	66 c7 05 ba 02 25 f0 	movw   $0x8,0xf02502ba
f0103fb6:	08 00 
f0103fb8:	c6 05 bc 02 25 f0 00 	movb   $0x0,0xf02502bc
f0103fbf:	c6 05 bd 02 25 f0 8f 	movb   $0x8f,0xf02502bd
f0103fc6:	c1 e8 10             	shr    $0x10,%eax
f0103fc9:	66 a3 be 02 25 f0    	mov    %ax,0xf02502be
	SETGATE(idt[12], 1, GD_KT, H_STACK, 0);
f0103fcf:	b8 fc 46 10 f0       	mov    $0xf01046fc,%eax
f0103fd4:	66 a3 c0 02 25 f0    	mov    %ax,0xf02502c0
f0103fda:	66 c7 05 c2 02 25 f0 	movw   $0x8,0xf02502c2
f0103fe1:	08 00 
f0103fe3:	c6 05 c4 02 25 f0 00 	movb   $0x0,0xf02502c4
f0103fea:	c6 05 c5 02 25 f0 8f 	movb   $0x8f,0xf02502c5
f0103ff1:	c1 e8 10             	shr    $0x10,%eax
f0103ff4:	66 a3 c6 02 25 f0    	mov    %ax,0xf02502c6
	SETGATE(idt[13], 1, GD_KT, H_GPFLT, 0);
f0103ffa:	b8 00 47 10 f0       	mov    $0xf0104700,%eax
f0103fff:	66 a3 c8 02 25 f0    	mov    %ax,0xf02502c8
f0104005:	66 c7 05 ca 02 25 f0 	movw   $0x8,0xf02502ca
f010400c:	08 00 
f010400e:	c6 05 cc 02 25 f0 00 	movb   $0x0,0xf02502cc
f0104015:	c6 05 cd 02 25 f0 8f 	movb   $0x8f,0xf02502cd
f010401c:	c1 e8 10             	shr    $0x10,%eax
f010401f:	66 a3 ce 02 25 f0    	mov    %ax,0xf02502ce
	SETGATE(idt[14], 1, GD_KT, H_PGFLT, 0);
f0104025:	b8 04 47 10 f0       	mov    $0xf0104704,%eax
f010402a:	66 a3 d0 02 25 f0    	mov    %ax,0xf02502d0
f0104030:	66 c7 05 d2 02 25 f0 	movw   $0x8,0xf02502d2
f0104037:	08 00 
f0104039:	c6 05 d4 02 25 f0 00 	movb   $0x0,0xf02502d4
f0104040:	c6 05 d5 02 25 f0 8f 	movb   $0x8f,0xf02502d5
f0104047:	c1 e8 10             	shr    $0x10,%eax
f010404a:	66 a3 d6 02 25 f0    	mov    %ax,0xf02502d6
	SETGATE(idt[16], 1, GD_KT, H_FPERR, 0);
f0104050:	b8 08 47 10 f0       	mov    $0xf0104708,%eax
f0104055:	66 a3 e0 02 25 f0    	mov    %ax,0xf02502e0
f010405b:	66 c7 05 e2 02 25 f0 	movw   $0x8,0xf02502e2
f0104062:	08 00 
f0104064:	c6 05 e4 02 25 f0 00 	movb   $0x0,0xf02502e4
f010406b:	c6 05 e5 02 25 f0 8f 	movb   $0x8f,0xf02502e5
f0104072:	c1 e8 10             	shr    $0x10,%eax
f0104075:	66 a3 e6 02 25 f0    	mov    %ax,0xf02502e6
	SETGATE(idt[17], 1, GD_KT, H_ALIGN, 0);
f010407b:	b8 0e 47 10 f0       	mov    $0xf010470e,%eax
f0104080:	66 a3 e8 02 25 f0    	mov    %ax,0xf02502e8
f0104086:	66 c7 05 ea 02 25 f0 	movw   $0x8,0xf02502ea
f010408d:	08 00 
f010408f:	c6 05 ec 02 25 f0 00 	movb   $0x0,0xf02502ec
f0104096:	c6 05 ed 02 25 f0 8f 	movb   $0x8f,0xf02502ed
f010409d:	c1 e8 10             	shr    $0x10,%eax
f01040a0:	66 a3 ee 02 25 f0    	mov    %ax,0xf02502ee
	SETGATE(idt[18], 1, GD_KT, H_MCHK, 0);
f01040a6:	b8 14 47 10 f0       	mov    $0xf0104714,%eax
f01040ab:	66 a3 f0 02 25 f0    	mov    %ax,0xf02502f0
f01040b1:	66 c7 05 f2 02 25 f0 	movw   $0x8,0xf02502f2
f01040b8:	08 00 
f01040ba:	c6 05 f4 02 25 f0 00 	movb   $0x0,0xf02502f4
f01040c1:	c6 05 f5 02 25 f0 8f 	movb   $0x8f,0xf02502f5
f01040c8:	c1 e8 10             	shr    $0x10,%eax
f01040cb:	66 a3 f6 02 25 f0    	mov    %ax,0xf02502f6
	SETGATE(idt[19], 1, GD_KT, H_SIMDERR, 0);
f01040d1:	b8 1a 47 10 f0       	mov    $0xf010471a,%eax
f01040d6:	66 a3 f8 02 25 f0    	mov    %ax,0xf02502f8
f01040dc:	66 c7 05 fa 02 25 f0 	movw   $0x8,0xf02502fa
f01040e3:	08 00 
f01040e5:	c6 05 fc 02 25 f0 00 	movb   $0x0,0xf02502fc
f01040ec:	c6 05 fd 02 25 f0 8f 	movb   $0x8f,0xf02502fd
f01040f3:	c1 e8 10             	shr    $0x10,%eax
f01040f6:	66 a3 fe 02 25 f0    	mov    %ax,0xf02502fe
	SETGATE(idt[T_SYSCALL], 1, GD_KT, H_SYSCALL,3);
f01040fc:	b8 20 47 10 f0       	mov    $0xf0104720,%eax
f0104101:	66 a3 e0 03 25 f0    	mov    %ax,0xf02503e0
f0104107:	66 c7 05 e2 03 25 f0 	movw   $0x8,0xf02503e2
f010410e:	08 00 
f0104110:	c6 05 e4 03 25 f0 00 	movb   $0x0,0xf02503e4
f0104117:	c6 05 e5 03 25 f0 ef 	movb   $0xef,0xf02503e5
f010411e:	c1 e8 10             	shr    $0x10,%eax
f0104121:	66 a3 e6 03 25 f0    	mov    %ax,0xf02503e6
	trap_init_percpu();
f0104127:	e8 bd fb ff ff       	call   f0103ce9 <trap_init_percpu>
}
f010412c:	c9                   	leave  
f010412d:	c3                   	ret    

f010412e <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010412e:	55                   	push   %ebp
f010412f:	89 e5                	mov    %esp,%ebp
f0104131:	53                   	push   %ebx
f0104132:	83 ec 0c             	sub    $0xc,%esp
f0104135:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104138:	ff 33                	pushl  (%ebx)
f010413a:	68 20 7e 10 f0       	push   $0xf0107e20
f010413f:	e8 91 fb ff ff       	call   f0103cd5 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104144:	83 c4 08             	add    $0x8,%esp
f0104147:	ff 73 04             	pushl  0x4(%ebx)
f010414a:	68 2f 7e 10 f0       	push   $0xf0107e2f
f010414f:	e8 81 fb ff ff       	call   f0103cd5 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104154:	83 c4 08             	add    $0x8,%esp
f0104157:	ff 73 08             	pushl  0x8(%ebx)
f010415a:	68 3e 7e 10 f0       	push   $0xf0107e3e
f010415f:	e8 71 fb ff ff       	call   f0103cd5 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104164:	83 c4 08             	add    $0x8,%esp
f0104167:	ff 73 0c             	pushl  0xc(%ebx)
f010416a:	68 4d 7e 10 f0       	push   $0xf0107e4d
f010416f:	e8 61 fb ff ff       	call   f0103cd5 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104174:	83 c4 08             	add    $0x8,%esp
f0104177:	ff 73 10             	pushl  0x10(%ebx)
f010417a:	68 5c 7e 10 f0       	push   $0xf0107e5c
f010417f:	e8 51 fb ff ff       	call   f0103cd5 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104184:	83 c4 08             	add    $0x8,%esp
f0104187:	ff 73 14             	pushl  0x14(%ebx)
f010418a:	68 6b 7e 10 f0       	push   $0xf0107e6b
f010418f:	e8 41 fb ff ff       	call   f0103cd5 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104194:	83 c4 08             	add    $0x8,%esp
f0104197:	ff 73 18             	pushl  0x18(%ebx)
f010419a:	68 7a 7e 10 f0       	push   $0xf0107e7a
f010419f:	e8 31 fb ff ff       	call   f0103cd5 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01041a4:	83 c4 08             	add    $0x8,%esp
f01041a7:	ff 73 1c             	pushl  0x1c(%ebx)
f01041aa:	68 89 7e 10 f0       	push   $0xf0107e89
f01041af:	e8 21 fb ff ff       	call   f0103cd5 <cprintf>
}
f01041b4:	83 c4 10             	add    $0x10,%esp
f01041b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01041ba:	c9                   	leave  
f01041bb:	c3                   	ret    

f01041bc <print_trapframe>:
{
f01041bc:	55                   	push   %ebp
f01041bd:	89 e5                	mov    %esp,%ebp
f01041bf:	56                   	push   %esi
f01041c0:	53                   	push   %ebx
f01041c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01041c4:	e8 35 20 00 00       	call   f01061fe <cpunum>
f01041c9:	83 ec 04             	sub    $0x4,%esp
f01041cc:	50                   	push   %eax
f01041cd:	53                   	push   %ebx
f01041ce:	68 ed 7e 10 f0       	push   $0xf0107eed
f01041d3:	e8 fd fa ff ff       	call   f0103cd5 <cprintf>
	print_regs(&tf->tf_regs);
f01041d8:	89 1c 24             	mov    %ebx,(%esp)
f01041db:	e8 4e ff ff ff       	call   f010412e <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01041e0:	83 c4 08             	add    $0x8,%esp
f01041e3:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01041e7:	50                   	push   %eax
f01041e8:	68 0b 7f 10 f0       	push   $0xf0107f0b
f01041ed:	e8 e3 fa ff ff       	call   f0103cd5 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01041f2:	83 c4 08             	add    $0x8,%esp
f01041f5:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01041f9:	50                   	push   %eax
f01041fa:	68 1e 7f 10 f0       	push   $0xf0107f1e
f01041ff:	e8 d1 fa ff ff       	call   f0103cd5 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104204:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0104207:	83 c4 10             	add    $0x10,%esp
f010420a:	83 f8 13             	cmp    $0x13,%eax
f010420d:	0f 86 e1 00 00 00    	jbe    f01042f4 <print_trapframe+0x138>
		return "System call";
f0104213:	ba 98 7e 10 f0       	mov    $0xf0107e98,%edx
	if (trapno == T_SYSCALL)
f0104218:	83 f8 30             	cmp    $0x30,%eax
f010421b:	74 13                	je     f0104230 <print_trapframe+0x74>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010421d:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104220:	83 fa 0f             	cmp    $0xf,%edx
f0104223:	ba a4 7e 10 f0       	mov    $0xf0107ea4,%edx
f0104228:	b9 b3 7e 10 f0       	mov    $0xf0107eb3,%ecx
f010422d:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104230:	83 ec 04             	sub    $0x4,%esp
f0104233:	52                   	push   %edx
f0104234:	50                   	push   %eax
f0104235:	68 31 7f 10 f0       	push   $0xf0107f31
f010423a:	e8 96 fa ff ff       	call   f0103cd5 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010423f:	83 c4 10             	add    $0x10,%esp
f0104242:	39 1d 60 0a 25 f0    	cmp    %ebx,0xf0250a60
f0104248:	0f 84 b2 00 00 00    	je     f0104300 <print_trapframe+0x144>
	cprintf("  err  0x%08x", tf->tf_err);
f010424e:	83 ec 08             	sub    $0x8,%esp
f0104251:	ff 73 2c             	pushl  0x2c(%ebx)
f0104254:	68 52 7f 10 f0       	push   $0xf0107f52
f0104259:	e8 77 fa ff ff       	call   f0103cd5 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f010425e:	83 c4 10             	add    $0x10,%esp
f0104261:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104265:	0f 85 b8 00 00 00    	jne    f0104323 <print_trapframe+0x167>
			tf->tf_err & 1 ? "protection" : "not-present");
f010426b:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f010426e:	89 c2                	mov    %eax,%edx
f0104270:	83 e2 01             	and    $0x1,%edx
f0104273:	b9 c6 7e 10 f0       	mov    $0xf0107ec6,%ecx
f0104278:	ba d1 7e 10 f0       	mov    $0xf0107ed1,%edx
f010427d:	0f 44 ca             	cmove  %edx,%ecx
f0104280:	89 c2                	mov    %eax,%edx
f0104282:	83 e2 02             	and    $0x2,%edx
f0104285:	be dd 7e 10 f0       	mov    $0xf0107edd,%esi
f010428a:	ba e3 7e 10 f0       	mov    $0xf0107ee3,%edx
f010428f:	0f 45 d6             	cmovne %esi,%edx
f0104292:	83 e0 04             	and    $0x4,%eax
f0104295:	b8 e8 7e 10 f0       	mov    $0xf0107ee8,%eax
f010429a:	be 35 80 10 f0       	mov    $0xf0108035,%esi
f010429f:	0f 44 c6             	cmove  %esi,%eax
f01042a2:	51                   	push   %ecx
f01042a3:	52                   	push   %edx
f01042a4:	50                   	push   %eax
f01042a5:	68 60 7f 10 f0       	push   $0xf0107f60
f01042aa:	e8 26 fa ff ff       	call   f0103cd5 <cprintf>
f01042af:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01042b2:	83 ec 08             	sub    $0x8,%esp
f01042b5:	ff 73 30             	pushl  0x30(%ebx)
f01042b8:	68 6f 7f 10 f0       	push   $0xf0107f6f
f01042bd:	e8 13 fa ff ff       	call   f0103cd5 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01042c2:	83 c4 08             	add    $0x8,%esp
f01042c5:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01042c9:	50                   	push   %eax
f01042ca:	68 7e 7f 10 f0       	push   $0xf0107f7e
f01042cf:	e8 01 fa ff ff       	call   f0103cd5 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01042d4:	83 c4 08             	add    $0x8,%esp
f01042d7:	ff 73 38             	pushl  0x38(%ebx)
f01042da:	68 91 7f 10 f0       	push   $0xf0107f91
f01042df:	e8 f1 f9 ff ff       	call   f0103cd5 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01042e4:	83 c4 10             	add    $0x10,%esp
f01042e7:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01042eb:	75 4b                	jne    f0104338 <print_trapframe+0x17c>
}
f01042ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01042f0:	5b                   	pop    %ebx
f01042f1:	5e                   	pop    %esi
f01042f2:	5d                   	pop    %ebp
f01042f3:	c3                   	ret    
		return excnames[trapno];
f01042f4:	8b 14 85 c0 81 10 f0 	mov    -0xfef7e40(,%eax,4),%edx
f01042fb:	e9 30 ff ff ff       	jmp    f0104230 <print_trapframe+0x74>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104300:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104304:	0f 85 44 ff ff ff    	jne    f010424e <print_trapframe+0x92>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010430a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010430d:	83 ec 08             	sub    $0x8,%esp
f0104310:	50                   	push   %eax
f0104311:	68 43 7f 10 f0       	push   $0xf0107f43
f0104316:	e8 ba f9 ff ff       	call   f0103cd5 <cprintf>
f010431b:	83 c4 10             	add    $0x10,%esp
f010431e:	e9 2b ff ff ff       	jmp    f010424e <print_trapframe+0x92>
		cprintf("\n");
f0104323:	83 ec 0c             	sub    $0xc,%esp
f0104326:	68 68 7d 10 f0       	push   $0xf0107d68
f010432b:	e8 a5 f9 ff ff       	call   f0103cd5 <cprintf>
f0104330:	83 c4 10             	add    $0x10,%esp
f0104333:	e9 7a ff ff ff       	jmp    f01042b2 <print_trapframe+0xf6>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104338:	83 ec 08             	sub    $0x8,%esp
f010433b:	ff 73 3c             	pushl  0x3c(%ebx)
f010433e:	68 a0 7f 10 f0       	push   $0xf0107fa0
f0104343:	e8 8d f9 ff ff       	call   f0103cd5 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104348:	83 c4 08             	add    $0x8,%esp
f010434b:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010434f:	50                   	push   %eax
f0104350:	68 af 7f 10 f0       	push   $0xf0107faf
f0104355:	e8 7b f9 ff ff       	call   f0103cd5 <cprintf>
f010435a:	83 c4 10             	add    $0x10,%esp
}
f010435d:	eb 8e                	jmp    f01042ed <print_trapframe+0x131>

f010435f <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010435f:	55                   	push   %ebp
f0104360:	89 e5                	mov    %esp,%ebp
f0104362:	57                   	push   %edi
f0104363:	56                   	push   %esi
f0104364:	53                   	push   %ebx
f0104365:	83 ec 0c             	sub    $0xc,%esp
f0104368:	8b 75 08             	mov    0x8(%ebp),%esi
f010436b:	0f 20 d7             	mov    %cr2,%edi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0) 
f010436e:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0104372:	74 5d                	je     f01043d1 <page_fault_handler+0x72>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall != NULL) {
f0104374:	e8 85 1e 00 00       	call   f01061fe <cpunum>
f0104379:	6b c0 74             	imul   $0x74,%eax,%eax
f010437c:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104382:	83 78 68 00          	cmpl   $0x0,0x68(%eax)
f0104386:	75 60                	jne    f01043e8 <page_fault_handler+0x89>
		curenv->env_tf.tf_esp = (uintptr_t)utf;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104388:	8b 5e 30             	mov    0x30(%esi),%ebx
		curenv->env_id, fault_va, tf->tf_eip);
f010438b:	e8 6e 1e 00 00       	call   f01061fe <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104390:	53                   	push   %ebx
f0104391:	57                   	push   %edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104392:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104395:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f010439b:	ff 70 48             	pushl  0x48(%eax)
f010439e:	68 80 81 10 f0       	push   $0xf0108180
f01043a3:	e8 2d f9 ff ff       	call   f0103cd5 <cprintf>
	print_trapframe(tf);
f01043a8:	89 34 24             	mov    %esi,(%esp)
f01043ab:	e8 0c fe ff ff       	call   f01041bc <print_trapframe>
	env_destroy(curenv);
f01043b0:	e8 49 1e 00 00       	call   f01061fe <cpunum>
f01043b5:	83 c4 04             	add    $0x4,%esp
f01043b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01043bb:	ff b0 28 10 25 f0    	pushl  -0xfdaefd8(%eax)
f01043c1:	e8 f3 f5 ff ff       	call   f01039b9 <env_destroy>
}
f01043c6:	83 c4 10             	add    $0x10,%esp
f01043c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01043cc:	5b                   	pop    %ebx
f01043cd:	5e                   	pop    %esi
f01043ce:	5f                   	pop    %edi
f01043cf:	5d                   	pop    %ebp
f01043d0:	c3                   	ret    
		panic("kernel-mode page faults");
f01043d1:	83 ec 04             	sub    $0x4,%esp
f01043d4:	68 c2 7f 10 f0       	push   $0xf0107fc2
f01043d9:	68 58 01 00 00       	push   $0x158
f01043de:	68 da 7f 10 f0       	push   $0xf0107fda
f01043e3:	e8 58 bc ff ff       	call   f0100040 <_panic>
		if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp <= UXSTACKTOP - 1) {
f01043e8:	8b 46 3c             	mov    0x3c(%esi),%eax
f01043eb:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f01043f1:	bb cc ff bf ee       	mov    $0xeebfffcc,%ebx
		if (tf->tf_esp >= UXSTACKTOP - PGSIZE && tf->tf_esp <= UXSTACKTOP - 1) {
f01043f6:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f01043fc:	77 03                	ja     f0104401 <page_fault_handler+0xa2>
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f01043fe:	8d 58 c8             	lea    -0x38(%eax),%ebx
		user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_W);
f0104401:	e8 f8 1d 00 00       	call   f01061fe <cpunum>
f0104406:	6a 02                	push   $0x2
f0104408:	6a 34                	push   $0x34
f010440a:	53                   	push   %ebx
f010440b:	6b c0 74             	imul   $0x74,%eax,%eax
f010440e:	ff b0 28 10 25 f0    	pushl  -0xfdaefd8(%eax)
f0104414:	e8 6e ef ff ff       	call   f0103387 <user_mem_assert>
		utf->utf_eflags = tf->tf_eflags;
f0104419:	8b 46 38             	mov    0x38(%esi),%eax
f010441c:	89 43 2c             	mov    %eax,0x2c(%ebx)
		utf->utf_eip = tf->tf_eip;
f010441f:	8b 46 30             	mov    0x30(%esi),%eax
f0104422:	89 43 28             	mov    %eax,0x28(%ebx)
		utf->utf_err = tf->tf_err;
f0104425:	8b 46 2c             	mov    0x2c(%esi),%eax
f0104428:	89 43 04             	mov    %eax,0x4(%ebx)
		utf->utf_esp = tf->tf_esp;
f010442b:	8b 46 3c             	mov    0x3c(%esi),%eax
f010442e:	89 43 30             	mov    %eax,0x30(%ebx)
		utf->utf_fault_va = fault_va;
f0104431:	89 3b                	mov    %edi,(%ebx)
		utf->utf_regs = tf->tf_regs;
f0104433:	8d 7b 08             	lea    0x8(%ebx),%edi
f0104436:	b9 08 00 00 00       	mov    $0x8,%ecx
f010443b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f010443d:	e8 bc 1d 00 00       	call   f01061fe <cpunum>
f0104442:	6b c0 74             	imul   $0x74,%eax,%eax
f0104445:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f010444b:	8b 70 68             	mov    0x68(%eax),%esi
f010444e:	e8 ab 1d 00 00       	call   f01061fe <cpunum>
f0104453:	6b c0 74             	imul   $0x74,%eax,%eax
f0104456:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f010445c:	89 70 30             	mov    %esi,0x30(%eax)
		curenv->env_tf.tf_esp = (uintptr_t)utf;
f010445f:	e8 9a 1d 00 00       	call   f01061fe <cpunum>
f0104464:	6b c0 74             	imul   $0x74,%eax,%eax
f0104467:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f010446d:	89 58 3c             	mov    %ebx,0x3c(%eax)
		env_run(curenv);
f0104470:	e8 89 1d 00 00       	call   f01061fe <cpunum>
f0104475:	83 c4 04             	add    $0x4,%esp
f0104478:	6b c0 74             	imul   $0x74,%eax,%eax
f010447b:	ff b0 28 10 25 f0    	pushl  -0xfdaefd8(%eax)
f0104481:	e8 d2 f5 ff ff       	call   f0103a58 <env_run>

f0104486 <trap>:
{
f0104486:	55                   	push   %ebp
f0104487:	89 e5                	mov    %esp,%ebp
f0104489:	57                   	push   %edi
f010448a:	56                   	push   %esi
f010448b:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f010448e:	fc                   	cld    
	if (panicstr)
f010448f:	83 3d 80 0e 25 f0 00 	cmpl   $0x0,0xf0250e80
f0104496:	74 01                	je     f0104499 <trap+0x13>
		asm volatile("hlt");
f0104498:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104499:	e8 60 1d 00 00       	call   f01061fe <cpunum>
f010449e:	6b d0 74             	imul   $0x74,%eax,%edx
f01044a1:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01044a4:	b8 01 00 00 00       	mov    $0x1,%eax
f01044a9:	f0 87 82 20 10 25 f0 	lock xchg %eax,-0xfdaefe0(%edx)
f01044b0:	83 f8 02             	cmp    $0x2,%eax
f01044b3:	74 7e                	je     f0104533 <trap+0xad>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01044b5:	9c                   	pushf  
f01044b6:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01044b7:	f6 c4 02             	test   $0x2,%ah
f01044ba:	0f 85 88 00 00 00    	jne    f0104548 <trap+0xc2>
	if ((tf->tf_cs & 3) == 3) {
f01044c0:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01044c4:	83 e0 03             	and    $0x3,%eax
f01044c7:	66 83 f8 03          	cmp    $0x3,%ax
f01044cb:	0f 84 90 00 00 00    	je     f0104561 <trap+0xdb>
	last_tf = tf;
f01044d1:	89 35 60 0a 25 f0    	mov    %esi,0xf0250a60
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01044d7:	8b 46 28             	mov    0x28(%esi),%eax
f01044da:	83 f8 27             	cmp    $0x27,%eax
f01044dd:	0f 84 23 01 00 00    	je     f0104606 <trap+0x180>
f01044e3:	83 f8 0e             	cmp    $0xe,%eax
f01044e6:	0f 84 4f 01 00 00    	je     f010463b <trap+0x1b5>
f01044ec:	83 f8 30             	cmp    $0x30,%eax
f01044ef:	0f 84 7c 01 00 00    	je     f0104671 <trap+0x1eb>
f01044f5:	83 f8 03             	cmp    $0x3,%eax
f01044f8:	0f 84 22 01 00 00    	je     f0104620 <trap+0x19a>
			print_trapframe(tf);
f01044fe:	83 ec 0c             	sub    $0xc,%esp
f0104501:	56                   	push   %esi
f0104502:	e8 b5 fc ff ff       	call   f01041bc <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0104507:	83 c4 10             	add    $0x10,%esp
f010450a:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010450f:	0f 84 7d 01 00 00    	je     f0104692 <trap+0x20c>
				env_destroy(curenv);
f0104515:	e8 e4 1c 00 00       	call   f01061fe <cpunum>
f010451a:	83 ec 0c             	sub    $0xc,%esp
f010451d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104520:	ff b0 28 10 25 f0    	pushl  -0xfdaefd8(%eax)
f0104526:	e8 8e f4 ff ff       	call   f01039b9 <env_destroy>
f010452b:	83 c4 10             	add    $0x10,%esp
f010452e:	e9 14 01 00 00       	jmp    f0104647 <trap+0x1c1>
	spin_lock(&kernel_lock);
f0104533:	83 ec 0c             	sub    $0xc,%esp
f0104536:	68 c0 43 12 f0       	push   $0xf01243c0
f010453b:	e8 2e 1f 00 00       	call   f010646e <spin_lock>
f0104540:	83 c4 10             	add    $0x10,%esp
f0104543:	e9 6d ff ff ff       	jmp    f01044b5 <trap+0x2f>
	assert(!(read_eflags() & FL_IF));
f0104548:	68 e6 7f 10 f0       	push   $0xf0107fe6
f010454d:	68 93 7a 10 f0       	push   $0xf0107a93
f0104552:	68 22 01 00 00       	push   $0x122
f0104557:	68 da 7f 10 f0       	push   $0xf0107fda
f010455c:	e8 df ba ff ff       	call   f0100040 <_panic>
f0104561:	83 ec 0c             	sub    $0xc,%esp
f0104564:	68 c0 43 12 f0       	push   $0xf01243c0
f0104569:	e8 00 1f 00 00       	call   f010646e <spin_lock>
		assert(curenv);
f010456e:	e8 8b 1c 00 00       	call   f01061fe <cpunum>
f0104573:	6b c0 74             	imul   $0x74,%eax,%eax
f0104576:	83 c4 10             	add    $0x10,%esp
f0104579:	83 b8 28 10 25 f0 00 	cmpl   $0x0,-0xfdaefd8(%eax)
f0104580:	74 3e                	je     f01045c0 <trap+0x13a>
		if (curenv->env_status == ENV_DYING) {
f0104582:	e8 77 1c 00 00       	call   f01061fe <cpunum>
f0104587:	6b c0 74             	imul   $0x74,%eax,%eax
f010458a:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104590:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104594:	74 43                	je     f01045d9 <trap+0x153>
		curenv->env_tf = *tf;
f0104596:	e8 63 1c 00 00       	call   f01061fe <cpunum>
f010459b:	6b c0 74             	imul   $0x74,%eax,%eax
f010459e:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f01045a4:	b9 11 00 00 00       	mov    $0x11,%ecx
f01045a9:	89 c7                	mov    %eax,%edi
f01045ab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01045ad:	e8 4c 1c 00 00       	call   f01061fe <cpunum>
f01045b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01045b5:	8b b0 28 10 25 f0    	mov    -0xfdaefd8(%eax),%esi
f01045bb:	e9 11 ff ff ff       	jmp    f01044d1 <trap+0x4b>
		assert(curenv);
f01045c0:	68 ff 7f 10 f0       	push   $0xf0107fff
f01045c5:	68 93 7a 10 f0       	push   $0xf0107a93
f01045ca:	68 2a 01 00 00       	push   $0x12a
f01045cf:	68 da 7f 10 f0       	push   $0xf0107fda
f01045d4:	e8 67 ba ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f01045d9:	e8 20 1c 00 00       	call   f01061fe <cpunum>
f01045de:	83 ec 0c             	sub    $0xc,%esp
f01045e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01045e4:	ff b0 28 10 25 f0    	pushl  -0xfdaefd8(%eax)
f01045ea:	e8 e9 f1 ff ff       	call   f01037d8 <env_free>
			curenv = NULL;
f01045ef:	e8 0a 1c 00 00       	call   f01061fe <cpunum>
f01045f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01045f7:	c7 80 28 10 25 f0 00 	movl   $0x0,-0xfdaefd8(%eax)
f01045fe:	00 00 00 
			sched_yield();
f0104601:	e8 fc 01 00 00       	call   f0104802 <sched_yield>
		cprintf("Spurious interrupt on irq 7\n");
f0104606:	83 ec 0c             	sub    $0xc,%esp
f0104609:	68 06 80 10 f0       	push   $0xf0108006
f010460e:	e8 c2 f6 ff ff       	call   f0103cd5 <cprintf>
		print_trapframe(tf);
f0104613:	89 34 24             	mov    %esi,(%esp)
f0104616:	e8 a1 fb ff ff       	call   f01041bc <print_trapframe>
f010461b:	83 c4 10             	add    $0x10,%esp
f010461e:	eb 27                	jmp    f0104647 <trap+0x1c1>
			print_trapframe(tf);
f0104620:	83 ec 0c             	sub    $0xc,%esp
f0104623:	56                   	push   %esi
f0104624:	e8 93 fb ff ff       	call   f01041bc <print_trapframe>
f0104629:	83 c4 10             	add    $0x10,%esp
				monitor(NULL);
f010462c:	83 ec 0c             	sub    $0xc,%esp
f010462f:	6a 00                	push   $0x0
f0104631:	e8 70 c6 ff ff       	call   f0100ca6 <monitor>
f0104636:	83 c4 10             	add    $0x10,%esp
f0104639:	eb f1                	jmp    f010462c <trap+0x1a6>
			page_fault_handler(tf);
f010463b:	83 ec 0c             	sub    $0xc,%esp
f010463e:	56                   	push   %esi
f010463f:	e8 1b fd ff ff       	call   f010435f <page_fault_handler>
f0104644:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104647:	e8 b2 1b 00 00       	call   f01061fe <cpunum>
f010464c:	6b c0 74             	imul   $0x74,%eax,%eax
f010464f:	83 b8 28 10 25 f0 00 	cmpl   $0x0,-0xfdaefd8(%eax)
f0104656:	74 14                	je     f010466c <trap+0x1e6>
f0104658:	e8 a1 1b 00 00       	call   f01061fe <cpunum>
f010465d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104660:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104666:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010466a:	74 3d                	je     f01046a9 <trap+0x223>
		sched_yield();
f010466c:	e8 91 01 00 00       	call   f0104802 <sched_yield>
			r = syscall(tf->tf_regs.reg_eax,
f0104671:	83 ec 08             	sub    $0x8,%esp
f0104674:	ff 76 04             	pushl  0x4(%esi)
f0104677:	ff 36                	pushl  (%esi)
f0104679:	ff 76 10             	pushl  0x10(%esi)
f010467c:	ff 76 18             	pushl  0x18(%esi)
f010467f:	ff 76 14             	pushl  0x14(%esi)
f0104682:	ff 76 1c             	pushl  0x1c(%esi)
f0104685:	e8 13 02 00 00       	call   f010489d <syscall>
			tf->tf_regs.reg_eax = r;
f010468a:	89 46 1c             	mov    %eax,0x1c(%esi)
f010468d:	83 c4 20             	add    $0x20,%esp
f0104690:	eb b5                	jmp    f0104647 <trap+0x1c1>
				panic("unhandled trap in kernel");
f0104692:	83 ec 04             	sub    $0x4,%esp
f0104695:	68 23 80 10 f0       	push   $0xf0108023
f010469a:	68 06 01 00 00       	push   $0x106
f010469f:	68 da 7f 10 f0       	push   $0xf0107fda
f01046a4:	e8 97 b9 ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f01046a9:	e8 50 1b 00 00       	call   f01061fe <cpunum>
f01046ae:	83 ec 0c             	sub    $0xc,%esp
f01046b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b4:	ff b0 28 10 25 f0    	pushl  -0xfdaefd8(%eax)
f01046ba:	e8 99 f3 ff ff       	call   f0103a58 <env_run>
f01046bf:	90                   	nop

f01046c0 <H_DIVIDE>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(H_DIVIDE, T_DIVIDE)
f01046c0:	6a 00                	push   $0x0
f01046c2:	6a 00                	push   $0x0
f01046c4:	eb 60                	jmp    f0104726 <_alltraps>

f01046c6 <H_DEBUG>:
TRAPHANDLER_NOEC(H_DEBUG, T_DEBUG)
f01046c6:	6a 00                	push   $0x0
f01046c8:	6a 01                	push   $0x1
f01046ca:	eb 5a                	jmp    f0104726 <_alltraps>

f01046cc <H_NMI>:
TRAPHANDLER_NOEC(H_NMI, T_NMI)
f01046cc:	6a 00                	push   $0x0
f01046ce:	6a 02                	push   $0x2
f01046d0:	eb 54                	jmp    f0104726 <_alltraps>

f01046d2 <H_BRKPT>:
TRAPHANDLER_NOEC(H_BRKPT, T_BRKPT)
f01046d2:	6a 00                	push   $0x0
f01046d4:	6a 03                	push   $0x3
f01046d6:	eb 4e                	jmp    f0104726 <_alltraps>

f01046d8 <H_OFLOW>:
TRAPHANDLER_NOEC(H_OFLOW, T_OFLOW)
f01046d8:	6a 00                	push   $0x0
f01046da:	6a 04                	push   $0x4
f01046dc:	eb 48                	jmp    f0104726 <_alltraps>

f01046de <H_BOUND>:
TRAPHANDLER_NOEC(H_BOUND, T_BOUND)
f01046de:	6a 00                	push   $0x0
f01046e0:	6a 05                	push   $0x5
f01046e2:	eb 42                	jmp    f0104726 <_alltraps>

f01046e4 <H_ILLOP>:
TRAPHANDLER_NOEC(H_ILLOP, T_ILLOP)
f01046e4:	6a 00                	push   $0x0
f01046e6:	6a 06                	push   $0x6
f01046e8:	eb 3c                	jmp    f0104726 <_alltraps>

f01046ea <H_DEVICE>:
TRAPHANDLER_NOEC(H_DEVICE, T_DEVICE)
f01046ea:	6a 00                	push   $0x0
f01046ec:	6a 07                	push   $0x7
f01046ee:	eb 36                	jmp    f0104726 <_alltraps>

f01046f0 <H_DBLFLT>:
TRAPHANDLER(H_DBLFLT, T_DBLFLT)
f01046f0:	6a 08                	push   $0x8
f01046f2:	eb 32                	jmp    f0104726 <_alltraps>

f01046f4 <H_TSS>:
/* TRAPHANDLER_NOEC(H_COPROC, T_COPROC) */
TRAPHANDLER(H_TSS, T_TSS)
f01046f4:	6a 0a                	push   $0xa
f01046f6:	eb 2e                	jmp    f0104726 <_alltraps>

f01046f8 <H_SEGNP>:
TRAPHANDLER(H_SEGNP, T_SEGNP)
f01046f8:	6a 0b                	push   $0xb
f01046fa:	eb 2a                	jmp    f0104726 <_alltraps>

f01046fc <H_STACK>:
TRAPHANDLER(H_STACK, T_STACK)
f01046fc:	6a 0c                	push   $0xc
f01046fe:	eb 26                	jmp    f0104726 <_alltraps>

f0104700 <H_GPFLT>:
TRAPHANDLER(H_GPFLT, T_GPFLT)
f0104700:	6a 0d                	push   $0xd
f0104702:	eb 22                	jmp    f0104726 <_alltraps>

f0104704 <H_PGFLT>:
TRAPHANDLER(H_PGFLT, T_PGFLT)
f0104704:	6a 0e                	push   $0xe
f0104706:	eb 1e                	jmp    f0104726 <_alltraps>

f0104708 <H_FPERR>:
/* TRAPHANDLER_NOEC(H_RES, T_RES) */
TRAPHANDLER_NOEC(H_FPERR, T_FPERR)
f0104708:	6a 00                	push   $0x0
f010470a:	6a 10                	push   $0x10
f010470c:	eb 18                	jmp    f0104726 <_alltraps>

f010470e <H_ALIGN>:
TRAPHANDLER_NOEC(H_ALIGN, T_ALIGN)
f010470e:	6a 00                	push   $0x0
f0104710:	6a 11                	push   $0x11
f0104712:	eb 12                	jmp    f0104726 <_alltraps>

f0104714 <H_MCHK>:
TRAPHANDLER_NOEC(H_MCHK, T_MCHK)
f0104714:	6a 00                	push   $0x0
f0104716:	6a 12                	push   $0x12
f0104718:	eb 0c                	jmp    f0104726 <_alltraps>

f010471a <H_SIMDERR>:
TRAPHANDLER_NOEC(H_SIMDERR, T_SIMDERR)
f010471a:	6a 00                	push   $0x0
f010471c:	6a 13                	push   $0x13
f010471e:	eb 06                	jmp    f0104726 <_alltraps>

f0104720 <H_SYSCALL>:

TRAPHANDLER_NOEC(H_SYSCALL, T_SYSCALL)
f0104720:	6a 00                	push   $0x0
f0104722:	6a 30                	push   $0x30
f0104724:	eb 00                	jmp    f0104726 <_alltraps>

f0104726 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
.global _alltraps
_alltraps:
	pushl %ds
f0104726:	1e                   	push   %ds
	pushl %es
f0104727:	06                   	push   %es
	pushal
f0104728:	60                   	pusha  
	movl $GD_KD, %eax
f0104729:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f010472e:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0104730:	8e c0                	mov    %eax,%es
	pushl %esp
f0104732:	54                   	push   %esp
	call trap
f0104733:	e8 4e fd ff ff       	call   f0104486 <trap>

f0104738 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104738:	55                   	push   %ebp
f0104739:	89 e5                	mov    %esp,%ebp
f010473b:	83 ec 08             	sub    $0x8,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010473e:	8b 0d 44 02 25 f0    	mov    0xf0250244,%ecx
	for (i = 0; i < NENV; i++) {
f0104744:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104749:	89 c2                	mov    %eax,%edx
f010474b:	c1 e2 07             	shl    $0x7,%edx
		     envs[i].env_status == ENV_RUNNING ||
f010474e:	8b 54 11 54          	mov    0x54(%ecx,%edx,1),%edx
f0104752:	83 ea 01             	sub    $0x1,%edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104755:	83 fa 02             	cmp    $0x2,%edx
f0104758:	76 29                	jbe    f0104783 <sched_halt+0x4b>
	for (i = 0; i < NENV; i++) {
f010475a:	83 c0 01             	add    $0x1,%eax
f010475d:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104762:	75 e5                	jne    f0104749 <sched_halt+0x11>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f0104764:	83 ec 0c             	sub    $0xc,%esp
f0104767:	68 10 82 10 f0       	push   $0xf0108210
f010476c:	e8 64 f5 ff ff       	call   f0103cd5 <cprintf>
f0104771:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104774:	83 ec 0c             	sub    $0xc,%esp
f0104777:	6a 00                	push   $0x0
f0104779:	e8 28 c5 ff ff       	call   f0100ca6 <monitor>
f010477e:	83 c4 10             	add    $0x10,%esp
f0104781:	eb f1                	jmp    f0104774 <sched_halt+0x3c>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104783:	e8 76 1a 00 00       	call   f01061fe <cpunum>
f0104788:	6b c0 74             	imul   $0x74,%eax,%eax
f010478b:	c7 80 28 10 25 f0 00 	movl   $0x0,-0xfdaefd8(%eax)
f0104792:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104795:	a1 8c 0e 25 f0       	mov    0xf0250e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f010479a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010479f:	76 4f                	jbe    f01047f0 <sched_halt+0xb8>
	return (physaddr_t)kva - KERNBASE;
f01047a1:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01047a6:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01047a9:	e8 50 1a 00 00       	call   f01061fe <cpunum>
f01047ae:	6b d0 74             	imul   $0x74,%eax,%edx
f01047b1:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01047b4:	b8 02 00 00 00       	mov    $0x2,%eax
f01047b9:	f0 87 82 20 10 25 f0 	lock xchg %eax,-0xfdaefe0(%edx)
	spin_unlock(&kernel_lock);
f01047c0:	83 ec 0c             	sub    $0xc,%esp
f01047c3:	68 c0 43 12 f0       	push   $0xf01243c0
f01047c8:	e8 3d 1d 00 00       	call   f010650a <spin_unlock>
	asm volatile("pause");
f01047cd:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		//"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01047cf:	e8 2a 1a 00 00       	call   f01061fe <cpunum>
f01047d4:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f01047d7:	8b 80 30 10 25 f0    	mov    -0xfdaefd0(%eax),%eax
f01047dd:	bd 00 00 00 00       	mov    $0x0,%ebp
f01047e2:	89 c4                	mov    %eax,%esp
f01047e4:	6a 00                	push   $0x0
f01047e6:	6a 00                	push   $0x0
f01047e8:	f4                   	hlt    
f01047e9:	eb fd                	jmp    f01047e8 <sched_halt+0xb0>
}
f01047eb:	83 c4 10             	add    $0x10,%esp
f01047ee:	c9                   	leave  
f01047ef:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01047f0:	50                   	push   %eax
f01047f1:	68 f8 68 10 f0       	push   $0xf01068f8
f01047f6:	6a 50                	push   $0x50
f01047f8:	68 39 82 10 f0       	push   $0xf0108239
f01047fd:	e8 3e b8 ff ff       	call   f0100040 <_panic>

f0104802 <sched_yield>:
{
f0104802:	55                   	push   %ebp
f0104803:	89 e5                	mov    %esp,%ebp
f0104805:	57                   	push   %edi
f0104806:	56                   	push   %esi
f0104807:	53                   	push   %ebx
f0104808:	83 ec 0c             	sub    $0xc,%esp
	struct Env *idle = curenv;
f010480b:	e8 ee 19 00 00       	call   f01061fe <cpunum>
f0104810:	6b c0 74             	imul   $0x74,%eax,%eax
f0104813:	8b 98 28 10 25 f0    	mov    -0xfdaefd8(%eax),%ebx
	envid_t cur = curenv ? ENVX(curenv->env_id) : -1;
f0104819:	e8 e0 19 00 00       	call   f01061fe <cpunum>
f010481e:	6b d0 74             	imul   $0x74,%eax,%edx
f0104821:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104826:	83 ba 28 10 25 f0 00 	cmpl   $0x0,-0xfdaefd8(%edx)
f010482d:	74 16                	je     f0104845 <sched_yield+0x43>
f010482f:	e8 ca 19 00 00       	call   f01061fe <cpunum>
f0104834:	6b c0 74             	imul   $0x74,%eax,%eax
f0104837:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f010483d:	8b 40 48             	mov    0x48(%eax),%eax
f0104840:	25 ff 03 00 00       	and    $0x3ff,%eax
		if (envs[cur].env_status == ENV_RUNNABLE) {
f0104845:	8b 3d 44 02 25 f0    	mov    0xf0250244,%edi
f010484b:	b9 00 04 00 00       	mov    $0x400,%ecx
		cur = (cur + 1 == NENV) ? 0 : cur + 1;
f0104850:	be 00 00 00 00       	mov    $0x0,%esi
f0104855:	8d 50 01             	lea    0x1(%eax),%edx
f0104858:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010485d:	89 d0                	mov    %edx,%eax
f010485f:	0f 44 c6             	cmove  %esi,%eax
		if (envs[cur].env_status == ENV_RUNNABLE) {
f0104862:	89 c2                	mov    %eax,%edx
f0104864:	c1 e2 07             	shl    $0x7,%edx
f0104867:	01 fa                	add    %edi,%edx
f0104869:	83 7a 54 02          	cmpl   $0x2,0x54(%edx)
f010486d:	74 1c                	je     f010488b <sched_yield+0x89>
	for (int i = 0; i < NENV; i++) {
f010486f:	83 e9 01             	sub    $0x1,%ecx
f0104872:	75 e1                	jne    f0104855 <sched_yield+0x53>
	if (idle && idle->env_status == ENV_RUNNING) {
f0104874:	85 db                	test   %ebx,%ebx
f0104876:	74 06                	je     f010487e <sched_yield+0x7c>
f0104878:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f010487c:	74 16                	je     f0104894 <sched_yield+0x92>
	sched_halt();
f010487e:	e8 b5 fe ff ff       	call   f0104738 <sched_halt>
}
f0104883:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104886:	5b                   	pop    %ebx
f0104887:	5e                   	pop    %esi
f0104888:	5f                   	pop    %edi
f0104889:	5d                   	pop    %ebp
f010488a:	c3                   	ret    
			env_run(&envs[cur]);
f010488b:	83 ec 0c             	sub    $0xc,%esp
f010488e:	52                   	push   %edx
f010488f:	e8 c4 f1 ff ff       	call   f0103a58 <env_run>
		env_run(idle);
f0104894:	83 ec 0c             	sub    $0xc,%esp
f0104897:	53                   	push   %ebx
f0104898:	e8 bb f1 ff ff       	call   f0103a58 <env_run>

f010489d <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010489d:	55                   	push   %ebp
f010489e:	89 e5                	mov    %esp,%ebp
f01048a0:	57                   	push   %edi
f01048a1:	56                   	push   %esi
f01048a2:	53                   	push   %ebx
f01048a3:	83 ec 2c             	sub    $0x2c,%esp
f01048a6:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	// panic("syscall not implemented");

	switch (syscallno) {
f01048a9:	83 f8 0e             	cmp    $0xe,%eax
f01048ac:	0f 87 8f 05 00 00    	ja     f0104e41 <syscall+0x5a4>
f01048b2:	ff 24 85 90 82 10 f0 	jmp    *-0xfef7d70(,%eax,4)
	user_mem_assert(curenv, s, len, PTE_U);
f01048b9:	e8 40 19 00 00       	call   f01061fe <cpunum>
f01048be:	6a 04                	push   $0x4
f01048c0:	ff 75 10             	pushl  0x10(%ebp)
f01048c3:	ff 75 0c             	pushl  0xc(%ebp)
f01048c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01048c9:	ff b0 28 10 25 f0    	pushl  -0xfdaefd8(%eax)
f01048cf:	e8 b3 ea ff ff       	call   f0103387 <user_mem_assert>
	cprintf("%.*s", len, s);
f01048d4:	83 c4 0c             	add    $0xc,%esp
f01048d7:	ff 75 0c             	pushl  0xc(%ebp)
f01048da:	ff 75 10             	pushl  0x10(%ebp)
f01048dd:	68 46 82 10 f0       	push   $0xf0108246
f01048e2:	e8 ee f3 ff ff       	call   f0103cd5 <cprintf>
f01048e7:	83 c4 10             	add    $0x10,%esp
		case SYS_cputs:
			sys_cputs((const char *)a1, (size_t)a2);
			return 0;
f01048ea:	b8 00 00 00 00       	mov    $0x0,%eax
		// case NSYSCALLS:
		// 	return -E_INVAL;
		default:
			return -E_INVAL;
	}
}
f01048ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01048f2:	5b                   	pop    %ebx
f01048f3:	5e                   	pop    %esi
f01048f4:	5f                   	pop    %edi
f01048f5:	5d                   	pop    %ebp
f01048f6:	c3                   	ret    
	return cons_getc();
f01048f7:	e8 b2 bd ff ff       	call   f01006ae <cons_getc>
			return sys_cgetc();
f01048fc:	eb f1                	jmp    f01048ef <syscall+0x52>
	return curenv->env_id;
f01048fe:	e8 fb 18 00 00       	call   f01061fe <cpunum>
f0104903:	6b c0 74             	imul   $0x74,%eax,%eax
f0104906:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f010490c:	8b 40 48             	mov    0x48(%eax),%eax
			return sys_getenvid();
f010490f:	eb de                	jmp    f01048ef <syscall+0x52>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104911:	83 ec 04             	sub    $0x4,%esp
f0104914:	6a 01                	push   $0x1
f0104916:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104919:	50                   	push   %eax
f010491a:	ff 75 0c             	pushl  0xc(%ebp)
f010491d:	e8 1c eb ff ff       	call   f010343e <envid2env>
f0104922:	83 c4 10             	add    $0x10,%esp
f0104925:	85 c0                	test   %eax,%eax
f0104927:	78 c6                	js     f01048ef <syscall+0x52>
	if (e == curenv)
f0104929:	e8 d0 18 00 00       	call   f01061fe <cpunum>
f010492e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104931:	6b c0 74             	imul   $0x74,%eax,%eax
f0104934:	39 90 28 10 25 f0    	cmp    %edx,-0xfdaefd8(%eax)
f010493a:	74 3d                	je     f0104979 <syscall+0xdc>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010493c:	8b 5a 48             	mov    0x48(%edx),%ebx
f010493f:	e8 ba 18 00 00       	call   f01061fe <cpunum>
f0104944:	83 ec 04             	sub    $0x4,%esp
f0104947:	53                   	push   %ebx
f0104948:	6b c0 74             	imul   $0x74,%eax,%eax
f010494b:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104951:	ff 70 48             	pushl  0x48(%eax)
f0104954:	68 66 82 10 f0       	push   $0xf0108266
f0104959:	e8 77 f3 ff ff       	call   f0103cd5 <cprintf>
f010495e:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104961:	83 ec 0c             	sub    $0xc,%esp
f0104964:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104967:	e8 4d f0 ff ff       	call   f01039b9 <env_destroy>
f010496c:	83 c4 10             	add    $0x10,%esp
	return 0;
f010496f:	b8 00 00 00 00       	mov    $0x0,%eax
			return sys_env_destroy((envid_t)a1);
f0104974:	e9 76 ff ff ff       	jmp    f01048ef <syscall+0x52>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104979:	e8 80 18 00 00       	call   f01061fe <cpunum>
f010497e:	83 ec 08             	sub    $0x8,%esp
f0104981:	6b c0 74             	imul   $0x74,%eax,%eax
f0104984:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f010498a:	ff 70 48             	pushl  0x48(%eax)
f010498d:	68 4b 82 10 f0       	push   $0xf010824b
f0104992:	e8 3e f3 ff ff       	call   f0103cd5 <cprintf>
f0104997:	83 c4 10             	add    $0x10,%esp
f010499a:	eb c5                	jmp    f0104961 <syscall+0xc4>
	if ((uint32_t)kva < KERNBASE)
f010499c:	81 7d 0c ff ff ff ef 	cmpl   $0xefffffff,0xc(%ebp)
f01049a3:	76 48                	jbe    f01049ed <syscall+0x150>
	return (physaddr_t)kva - KERNBASE;
f01049a5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01049a8:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f01049ad:	c1 e8 0c             	shr    $0xc,%eax
f01049b0:	3b 05 88 0e 25 f0    	cmp    0xf0250e88,%eax
f01049b6:	73 4c                	jae    f0104a04 <syscall+0x167>
	return &pages[PGNUM(pa)];
f01049b8:	8b 15 90 0e 25 f0    	mov    0xf0250e90,%edx
f01049be:	8d 1c c2             	lea    (%edx,%eax,8),%ebx
    if (p == NULL)
f01049c1:	85 db                	test   %ebx,%ebx
f01049c3:	0f 84 82 04 00 00    	je     f0104e4b <syscall+0x5ae>
    r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f01049c9:	e8 30 18 00 00       	call   f01061fe <cpunum>
f01049ce:	6a 06                	push   $0x6
f01049d0:	ff 75 10             	pushl  0x10(%ebp)
f01049d3:	53                   	push   %ebx
f01049d4:	6b c0 74             	imul   $0x74,%eax,%eax
f01049d7:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f01049dd:	ff 70 64             	pushl  0x64(%eax)
f01049e0:	e8 ae cb ff ff       	call   f0101593 <page_insert>
f01049e5:	83 c4 10             	add    $0x10,%esp
f01049e8:	e9 02 ff ff ff       	jmp    f01048ef <syscall+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01049ed:	ff 75 0c             	pushl  0xc(%ebp)
f01049f0:	68 f8 68 10 f0       	push   $0xf01068f8
f01049f5:	68 55 01 00 00       	push   $0x155
f01049fa:	68 7e 82 10 f0       	push   $0xf010827e
f01049ff:	e8 3c b6 ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f0104a04:	83 ec 04             	sub    $0x4,%esp
f0104a07:	68 e4 71 10 f0       	push   $0xf01071e4
f0104a0c:	6a 51                	push   $0x51
f0104a0e:	68 79 7a 10 f0       	push   $0xf0107a79
f0104a13:	e8 28 b6 ff ff       	call   f0100040 <_panic>
	if (inc == 0) return (int)curenv->env_break;
f0104a18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104a1c:	74 5a                	je     f0104a78 <syscall+0x1db>
	if (curenv->env_break + inc > UTOP) return -1;
f0104a1e:	e8 db 17 00 00       	call   f01061fe <cpunum>
f0104a23:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a26:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104a2f:	03 48 60             	add    0x60(%eax),%ecx
f0104a32:	81 f9 00 00 c0 ee    	cmp    $0xeec00000,%ecx
f0104a38:	0f 87 17 04 00 00    	ja     f0104e55 <syscall+0x5b8>
	start = (uintptr_t)ROUNDDOWN(curenv->env_break, PGSIZE);
f0104a3e:	e8 bb 17 00 00       	call   f01061fe <cpunum>
f0104a43:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a46:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104a4c:	8b 58 60             	mov    0x60(%eax),%ebx
f0104a4f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	end = (uintptr_t)ROUNDUP(curenv->env_break + inc, PGSIZE);
f0104a55:	e8 a4 17 00 00       	call   f01061fe <cpunum>
f0104a5a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a5d:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104a63:	8b 40 60             	mov    0x60(%eax),%eax
f0104a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104a69:	8d bc 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edi
f0104a70:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0104a76:	eb 5a                	jmp    f0104ad2 <syscall+0x235>
	if (inc == 0) return (int)curenv->env_break;
f0104a78:	e8 81 17 00 00       	call   f01061fe <cpunum>
f0104a7d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a80:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104a86:	8b 40 60             	mov    0x60(%eax),%eax
f0104a89:	e9 61 fe ff ff       	jmp    f01048ef <syscall+0x52>
			if ((p = page_alloc(0)) == NULL)
f0104a8e:	83 ec 0c             	sub    $0xc,%esp
f0104a91:	6a 00                	push   $0x0
f0104a93:	e8 46 c8 ff ff       	call   f01012de <page_alloc>
f0104a98:	89 c6                	mov    %eax,%esi
f0104a9a:	83 c4 10             	add    $0x10,%esp
f0104a9d:	85 c0                	test   %eax,%eax
f0104a9f:	0f 84 ba 03 00 00    	je     f0104e5f <syscall+0x5c2>
			if (page_insert(curenv->env_pgdir, p, (void*)i, PTE_U | PTE_W) < 0)
f0104aa5:	e8 54 17 00 00       	call   f01061fe <cpunum>
f0104aaa:	6a 06                	push   $0x6
f0104aac:	ff 75 d4             	pushl  -0x2c(%ebp)
f0104aaf:	56                   	push   %esi
f0104ab0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ab3:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104ab9:	ff 70 64             	pushl  0x64(%eax)
f0104abc:	e8 d2 ca ff ff       	call   f0101593 <page_insert>
f0104ac1:	83 c4 10             	add    $0x10,%esp
f0104ac4:	85 c0                	test   %eax,%eax
f0104ac6:	0f 88 9d 03 00 00    	js     f0104e69 <syscall+0x5cc>
	for (uintptr_t i = start; i < end; i += PGSIZE) {
f0104acc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0104ad2:	39 df                	cmp    %ebx,%edi
f0104ad4:	76 5c                	jbe    f0104b32 <syscall+0x295>
		pte_t *pte = pgdir_walk(curenv->env_pgdir, (void*)i, 0);
f0104ad6:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104ad9:	e8 20 17 00 00       	call   f01061fe <cpunum>
f0104ade:	83 ec 04             	sub    $0x4,%esp
f0104ae1:	6a 00                	push   $0x0
f0104ae3:	53                   	push   %ebx
f0104ae4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae7:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104aed:	ff 70 64             	pushl  0x64(%eax)
f0104af0:	e8 c5 c8 ff ff       	call   f01013ba <pgdir_walk>
		struct PageInfo *p = page_alloc(0);
f0104af5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104afc:	e8 dd c7 ff ff       	call   f01012de <page_alloc>
		if ((pte = pgdir_walk(curenv->env_pgdir, (void*)i, 0)) == NULL || !(*pte & PTE_P)){
f0104b01:	e8 f8 16 00 00       	call   f01061fe <cpunum>
f0104b06:	83 c4 0c             	add    $0xc,%esp
f0104b09:	6a 00                	push   $0x0
f0104b0b:	53                   	push   %ebx
f0104b0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b0f:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104b15:	ff 70 64             	pushl  0x64(%eax)
f0104b18:	e8 9d c8 ff ff       	call   f01013ba <pgdir_walk>
f0104b1d:	83 c4 10             	add    $0x10,%esp
f0104b20:	85 c0                	test   %eax,%eax
f0104b22:	0f 84 66 ff ff ff    	je     f0104a8e <syscall+0x1f1>
f0104b28:	f6 00 01             	testb  $0x1,(%eax)
f0104b2b:	75 9f                	jne    f0104acc <syscall+0x22f>
f0104b2d:	e9 5c ff ff ff       	jmp    f0104a8e <syscall+0x1f1>
	curenv->env_break += inc;
f0104b32:	e8 c7 16 00 00       	call   f01061fe <cpunum>
f0104b37:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b3a:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104b40:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104b43:	01 50 60             	add    %edx,0x60(%eax)
	return (int)curenv->env_break;
f0104b46:	e8 b3 16 00 00       	call   f01061fe <cpunum>
f0104b4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b4e:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104b54:	8b 40 60             	mov    0x60(%eax),%eax
f0104b57:	e9 93 fd ff ff       	jmp    f01048ef <syscall+0x52>
	sched_yield();
f0104b5c:	e8 a1 fc ff ff       	call   f0104802 <sched_yield>
	if ((r = env_alloc(&env, curenv->env_id)) < 0) return r;
f0104b61:	e8 98 16 00 00       	call   f01061fe <cpunum>
f0104b66:	83 ec 08             	sub    $0x8,%esp
f0104b69:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b6c:	8b 80 28 10 25 f0    	mov    -0xfdaefd8(%eax),%eax
f0104b72:	ff 70 48             	pushl  0x48(%eax)
f0104b75:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b78:	50                   	push   %eax
f0104b79:	e8 cf e9 ff ff       	call   f010354d <env_alloc>
f0104b7e:	83 c4 10             	add    $0x10,%esp
f0104b81:	85 c0                	test   %eax,%eax
f0104b83:	0f 88 66 fd ff ff    	js     f01048ef <syscall+0x52>
	env->env_status = ENV_NOT_RUNNABLE;
f0104b89:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b8c:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	env->env_tf = curenv->env_tf;
f0104b93:	e8 66 16 00 00       	call   f01061fe <cpunum>
f0104b98:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b9b:	8b b0 28 10 25 f0    	mov    -0xfdaefd8(%eax),%esi
f0104ba1:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104ba6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ba9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	env->env_tf.tf_regs.reg_eax = 0;
f0104bab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bae:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return env->env_id;
f0104bb5:	8b 40 48             	mov    0x48(%eax),%eax
			return sys_exofork();
f0104bb8:	e9 32 fd ff ff       	jmp    f01048ef <syscall+0x52>
	if ((r = envid2env(envid, &env, 1)) < 0) return r;
f0104bbd:	83 ec 04             	sub    $0x4,%esp
f0104bc0:	6a 01                	push   $0x1
f0104bc2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104bc5:	50                   	push   %eax
f0104bc6:	ff 75 0c             	pushl  0xc(%ebp)
f0104bc9:	e8 70 e8 ff ff       	call   f010343e <envid2env>
f0104bce:	83 c4 10             	add    $0x10,%esp
f0104bd1:	85 c0                	test   %eax,%eax
f0104bd3:	0f 88 16 fd ff ff    	js     f01048ef <syscall+0x52>
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;
f0104bd9:	8b 45 10             	mov    0x10(%ebp),%eax
f0104bdc:	83 e8 02             	sub    $0x2,%eax
f0104bdf:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104be4:	75 13                	jne    f0104bf9 <syscall+0x35c>
	env->env_status = status;
f0104be6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104be9:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104bec:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;
f0104bef:	b8 00 00 00 00       	mov    $0x0,%eax
f0104bf4:	e9 f6 fc ff ff       	jmp    f01048ef <syscall+0x52>
	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) return -E_INVAL;
f0104bf9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			return sys_env_set_status((envid_t)a1, (int)a2);
f0104bfe:	e9 ec fc ff ff       	jmp    f01048ef <syscall+0x52>
	if ((r = envid2env(envid, &env, 1)) < 0) return r;
f0104c03:	83 ec 04             	sub    $0x4,%esp
f0104c06:	6a 01                	push   $0x1
f0104c08:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c0b:	50                   	push   %eax
f0104c0c:	ff 75 0c             	pushl  0xc(%ebp)
f0104c0f:	e8 2a e8 ff ff       	call   f010343e <envid2env>
f0104c14:	83 c4 10             	add    $0x10,%esp
f0104c17:	85 c0                	test   %eax,%eax
f0104c19:	0f 88 d0 fc ff ff    	js     f01048ef <syscall+0x52>
	env->env_pgfault_upcall = func;
f0104c1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c22:	8b 55 10             	mov    0x10(%ebp),%edx
f0104c25:	89 50 68             	mov    %edx,0x68(%eax)
	return 0;
f0104c28:	b8 00 00 00 00       	mov    $0x0,%eax
			return sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
f0104c2d:	e9 bd fc ff ff       	jmp    f01048ef <syscall+0x52>
	if ((r = envid2env(envid, &env, 1)) < 0) return r;
f0104c32:	83 ec 04             	sub    $0x4,%esp
f0104c35:	6a 01                	push   $0x1
f0104c37:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c3a:	50                   	push   %eax
f0104c3b:	ff 75 0c             	pushl  0xc(%ebp)
f0104c3e:	e8 fb e7 ff ff       	call   f010343e <envid2env>
f0104c43:	83 c4 10             	add    $0x10,%esp
f0104c46:	85 c0                	test   %eax,%eax
f0104c48:	0f 88 a1 fc ff ff    	js     f01048ef <syscall+0x52>
	if ((uintptr_t)va >= UTOP || PGOFF(va) != 0) return -E_INVAL;
f0104c4e:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104c55:	77 5b                	ja     f0104cb2 <syscall+0x415>
f0104c57:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104c5e:	75 5c                	jne    f0104cbc <syscall+0x41f>
	if ((perm & (PTE_U | PTE_P)) == 0) return -E_INVAL;
f0104c60:	f6 45 14 05          	testb  $0x5,0x14(%ebp)
f0104c64:	74 60                	je     f0104cc6 <syscall+0x429>
	struct PageInfo *p = page_alloc(ALLOC_ZERO);
f0104c66:	83 ec 0c             	sub    $0xc,%esp
f0104c69:	6a 01                	push   $0x1
f0104c6b:	e8 6e c6 ff ff       	call   f01012de <page_alloc>
f0104c70:	89 c3                	mov    %eax,%ebx
	if (!p) return -E_NO_MEM;
f0104c72:	83 c4 10             	add    $0x10,%esp
f0104c75:	85 c0                	test   %eax,%eax
f0104c77:	74 57                	je     f0104cd0 <syscall+0x433>
	if ((r = page_insert(env->env_pgdir, p, va, perm)) < 0) {
f0104c79:	ff 75 14             	pushl  0x14(%ebp)
f0104c7c:	ff 75 10             	pushl  0x10(%ebp)
f0104c7f:	50                   	push   %eax
f0104c80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c83:	ff 70 64             	pushl  0x64(%eax)
f0104c86:	e8 08 c9 ff ff       	call   f0101593 <page_insert>
f0104c8b:	83 c4 10             	add    $0x10,%esp
f0104c8e:	85 c0                	test   %eax,%eax
f0104c90:	78 0a                	js     f0104c9c <syscall+0x3ff>
	return 0;
f0104c92:	b8 00 00 00 00       	mov    $0x0,%eax
			return sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
f0104c97:	e9 53 fc ff ff       	jmp    f01048ef <syscall+0x52>
		page_free(p);
f0104c9c:	83 ec 0c             	sub    $0xc,%esp
f0104c9f:	53                   	push   %ebx
f0104ca0:	e8 b1 c6 ff ff       	call   f0101356 <page_free>
f0104ca5:	83 c4 10             	add    $0x10,%esp
		return -E_NO_MEM;
f0104ca8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104cad:	e9 3d fc ff ff       	jmp    f01048ef <syscall+0x52>
	if ((uintptr_t)va >= UTOP || PGOFF(va) != 0) return -E_INVAL;
f0104cb2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104cb7:	e9 33 fc ff ff       	jmp    f01048ef <syscall+0x52>
f0104cbc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104cc1:	e9 29 fc ff ff       	jmp    f01048ef <syscall+0x52>
	if ((perm & (PTE_U | PTE_P)) == 0) return -E_INVAL;
f0104cc6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ccb:	e9 1f fc ff ff       	jmp    f01048ef <syscall+0x52>
	if (!p) return -E_NO_MEM;
f0104cd0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0104cd5:	e9 15 fc ff ff       	jmp    f01048ef <syscall+0x52>
	if ((r = envid2env(srcenvid, &srcenv, 1)) < 0) return r;
f0104cda:	83 ec 04             	sub    $0x4,%esp
f0104cdd:	6a 01                	push   $0x1
f0104cdf:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ce2:	50                   	push   %eax
f0104ce3:	ff 75 0c             	pushl  0xc(%ebp)
f0104ce6:	e8 53 e7 ff ff       	call   f010343e <envid2env>
f0104ceb:	83 c4 10             	add    $0x10,%esp
f0104cee:	85 c0                	test   %eax,%eax
f0104cf0:	0f 88 f9 fb ff ff    	js     f01048ef <syscall+0x52>
	if ((r = envid2env(dstenvid, &dstenv, 1)) < 0) return r;
f0104cf6:	83 ec 04             	sub    $0x4,%esp
f0104cf9:	6a 01                	push   $0x1
f0104cfb:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104cfe:	50                   	push   %eax
f0104cff:	ff 75 14             	pushl  0x14(%ebp)
f0104d02:	e8 37 e7 ff ff       	call   f010343e <envid2env>
f0104d07:	83 c4 10             	add    $0x10,%esp
f0104d0a:	85 c0                	test   %eax,%eax
f0104d0c:	0f 88 dd fb ff ff    	js     f01048ef <syscall+0x52>
	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
f0104d12:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d19:	0f 87 90 00 00 00    	ja     f0104daf <syscall+0x512>
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
f0104d1f:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104d26:	0f 87 8d 00 00 00    	ja     f0104db9 <syscall+0x51c>
f0104d2c:	8b 45 10             	mov    0x10(%ebp),%eax
f0104d2f:	0b 45 18             	or     0x18(%ebp),%eax
f0104d32:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104d37:	0f 85 86 00 00 00    	jne    f0104dc3 <syscall+0x526>
	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0) return -E_INVAL;
f0104d3d:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104d40:	83 e0 05             	and    $0x5,%eax
f0104d43:	83 f8 05             	cmp    $0x5,%eax
f0104d46:	0f 85 81 00 00 00    	jne    f0104dcd <syscall+0x530>
	struct PageInfo *p = page_lookup(srcenv->env_pgdir, srcva, &srcpte);
f0104d4c:	83 ec 04             	sub    $0x4,%esp
f0104d4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d52:	50                   	push   %eax
f0104d53:	ff 75 10             	pushl  0x10(%ebp)
f0104d56:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d59:	ff 70 64             	pushl  0x64(%eax)
f0104d5c:	e8 44 c7 ff ff       	call   f01014a5 <page_lookup>
	assert(p);
f0104d61:	83 c4 10             	add    $0x10,%esp
f0104d64:	85 c0                	test   %eax,%eax
f0104d66:	74 2e                	je     f0104d96 <syscall+0x4f9>
	if ((perm & PTE_W) && (*srcpte & PTE_W) == 0) return -E_INVAL;
f0104d68:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104d6c:	74 08                	je     f0104d76 <syscall+0x4d9>
f0104d6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d71:	f6 02 02             	testb  $0x2,(%edx)
f0104d74:	74 61                	je     f0104dd7 <syscall+0x53a>
	if ((r = page_insert(dstenv->env_pgdir, p, dstva, perm)) < 0) return -E_NO_MEM;
f0104d76:	ff 75 1c             	pushl  0x1c(%ebp)
f0104d79:	ff 75 18             	pushl  0x18(%ebp)
f0104d7c:	50                   	push   %eax
f0104d7d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d80:	ff 70 64             	pushl  0x64(%eax)
f0104d83:	e8 0b c8 ff ff       	call   f0101593 <page_insert>
f0104d88:	83 c4 10             	add    $0x10,%esp
f0104d8b:	c1 f8 1f             	sar    $0x1f,%eax
f0104d8e:	83 e0 fc             	and    $0xfffffffc,%eax
f0104d91:	e9 59 fb ff ff       	jmp    f01048ef <syscall+0x52>
	assert(p);
f0104d96:	68 1f 6d 10 f0       	push   $0xf0106d1f
f0104d9b:	68 93 7a 10 f0       	push   $0xf0107a93
f0104da0:	68 ee 00 00 00       	push   $0xee
f0104da5:	68 7e 82 10 f0       	push   $0xf010827e
f0104daa:	e8 91 b2 ff ff       	call   f0100040 <_panic>
	if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) != 0) return -E_INVAL;
f0104daf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104db4:	e9 36 fb ff ff       	jmp    f01048ef <syscall+0x52>
	if ((uintptr_t)dstva >= UTOP || PGOFF(dstva) != 0) return -E_INVAL;
f0104db9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104dbe:	e9 2c fb ff ff       	jmp    f01048ef <syscall+0x52>
f0104dc3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104dc8:	e9 22 fb ff ff       	jmp    f01048ef <syscall+0x52>
	if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0) return -E_INVAL;
f0104dcd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104dd2:	e9 18 fb ff ff       	jmp    f01048ef <syscall+0x52>
	if ((perm & PTE_W) && (*srcpte & PTE_W) == 0) return -E_INVAL;
f0104dd7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104ddc:	e9 0e fb ff ff       	jmp    f01048ef <syscall+0x52>
	if ((r = envid2env(envid, &env, 1)) < 0) return r;
f0104de1:	83 ec 04             	sub    $0x4,%esp
f0104de4:	6a 01                	push   $0x1
f0104de6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104de9:	50                   	push   %eax
f0104dea:	ff 75 0c             	pushl  0xc(%ebp)
f0104ded:	e8 4c e6 ff ff       	call   f010343e <envid2env>
f0104df2:	83 c4 10             	add    $0x10,%esp
f0104df5:	85 c0                	test   %eax,%eax
f0104df7:	0f 88 f2 fa ff ff    	js     f01048ef <syscall+0x52>
	if ((uintptr_t)va >= UTOP || PGOFF(va) != 0) return -E_INVAL;
f0104dfd:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104e04:	77 27                	ja     f0104e2d <syscall+0x590>
f0104e06:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104e0d:	75 28                	jne    f0104e37 <syscall+0x59a>
	page_remove(env->env_pgdir, va);
f0104e0f:	83 ec 08             	sub    $0x8,%esp
f0104e12:	ff 75 10             	pushl  0x10(%ebp)
f0104e15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e18:	ff 70 64             	pushl  0x64(%eax)
f0104e1b:	e8 20 c7 ff ff       	call   f0101540 <page_remove>
f0104e20:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104e23:	b8 00 00 00 00       	mov    $0x0,%eax
f0104e28:	e9 c2 fa ff ff       	jmp    f01048ef <syscall+0x52>
	if ((uintptr_t)va >= UTOP || PGOFF(va) != 0) return -E_INVAL;
f0104e2d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104e32:	e9 b8 fa ff ff       	jmp    f01048ef <syscall+0x52>
f0104e37:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			return sys_page_unmap((envid_t)a1, (void *)a2);
f0104e3c:	e9 ae fa ff ff       	jmp    f01048ef <syscall+0x52>
			return -E_INVAL;
f0104e41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104e46:	e9 a4 fa ff ff       	jmp    f01048ef <syscall+0x52>
        return E_INVAL;
f0104e4b:	b8 03 00 00 00       	mov    $0x3,%eax
f0104e50:	e9 9a fa ff ff       	jmp    f01048ef <syscall+0x52>
	if (curenv->env_break + inc > UTOP) return -1;
f0104e55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e5a:	e9 90 fa ff ff       	jmp    f01048ef <syscall+0x52>
				return -1;
f0104e5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e64:	e9 86 fa ff ff       	jmp    f01048ef <syscall+0x52>
				return -1;
f0104e69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e6e:	e9 7c fa ff ff       	jmp    f01048ef <syscall+0x52>

f0104e73 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104e73:	55                   	push   %ebp
f0104e74:	89 e5                	mov    %esp,%ebp
f0104e76:	57                   	push   %edi
f0104e77:	56                   	push   %esi
f0104e78:	53                   	push   %ebx
f0104e79:	83 ec 14             	sub    $0x14,%esp
f0104e7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104e7f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104e82:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104e85:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104e88:	8b 1a                	mov    (%edx),%ebx
f0104e8a:	8b 01                	mov    (%ecx),%eax
f0104e8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104e8f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104e96:	eb 23                	jmp    f0104ebb <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104e98:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104e9b:	eb 1e                	jmp    f0104ebb <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104e9d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ea0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ea3:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104ea7:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104eaa:	73 41                	jae    f0104eed <stab_binsearch+0x7a>
			*region_left = m;
f0104eac:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104eaf:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104eb1:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0104eb4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104ebb:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104ebe:	7f 5a                	jg     f0104f1a <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0104ec0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104ec3:	01 d8                	add    %ebx,%eax
f0104ec5:	89 c7                	mov    %eax,%edi
f0104ec7:	c1 ef 1f             	shr    $0x1f,%edi
f0104eca:	01 c7                	add    %eax,%edi
f0104ecc:	d1 ff                	sar    %edi
f0104ece:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104ed1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ed4:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104ed8:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0104eda:	39 c3                	cmp    %eax,%ebx
f0104edc:	7f ba                	jg     f0104e98 <stab_binsearch+0x25>
f0104ede:	0f b6 0a             	movzbl (%edx),%ecx
f0104ee1:	83 ea 0c             	sub    $0xc,%edx
f0104ee4:	39 f1                	cmp    %esi,%ecx
f0104ee6:	74 b5                	je     f0104e9d <stab_binsearch+0x2a>
			m--;
f0104ee8:	83 e8 01             	sub    $0x1,%eax
f0104eeb:	eb ed                	jmp    f0104eda <stab_binsearch+0x67>
		} else if (stabs[m].n_value > addr) {
f0104eed:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104ef0:	76 14                	jbe    f0104f06 <stab_binsearch+0x93>
			*region_right = m - 1;
f0104ef2:	83 e8 01             	sub    $0x1,%eax
f0104ef5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ef8:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104efb:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0104efd:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104f04:	eb b5                	jmp    f0104ebb <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104f06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f09:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0104f0b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104f0f:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0104f11:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104f18:	eb a1                	jmp    f0104ebb <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0104f1a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104f1e:	75 15                	jne    f0104f35 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104f20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f23:	8b 00                	mov    (%eax),%eax
f0104f25:	83 e8 01             	sub    $0x1,%eax
f0104f28:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104f2b:	89 06                	mov    %eax,(%esi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104f2d:	83 c4 14             	add    $0x14,%esp
f0104f30:	5b                   	pop    %ebx
f0104f31:	5e                   	pop    %esi
f0104f32:	5f                   	pop    %edi
f0104f33:	5d                   	pop    %ebp
f0104f34:	c3                   	ret    
		for (l = *region_right;
f0104f35:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f38:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104f3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f3d:	8b 0f                	mov    (%edi),%ecx
f0104f3f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104f42:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0104f45:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0104f49:	eb 03                	jmp    f0104f4e <stab_binsearch+0xdb>
		     l--)
f0104f4b:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104f4e:	39 c1                	cmp    %eax,%ecx
f0104f50:	7d 0a                	jge    f0104f5c <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104f52:	0f b6 1a             	movzbl (%edx),%ebx
f0104f55:	83 ea 0c             	sub    $0xc,%edx
f0104f58:	39 f3                	cmp    %esi,%ebx
f0104f5a:	75 ef                	jne    f0104f4b <stab_binsearch+0xd8>
		*region_left = l;
f0104f5c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104f5f:	89 06                	mov    %eax,(%esi)
}
f0104f61:	eb ca                	jmp    f0104f2d <stab_binsearch+0xba>

f0104f63 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104f63:	55                   	push   %ebp
f0104f64:	89 e5                	mov    %esp,%ebp
f0104f66:	57                   	push   %edi
f0104f67:	56                   	push   %esi
f0104f68:	53                   	push   %ebx
f0104f69:	83 ec 4c             	sub    $0x4c,%esp
f0104f6c:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104f6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104f72:	c7 03 cc 82 10 f0    	movl   $0xf01082cc,(%ebx)
	info->eip_line = 0;
f0104f78:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104f7f:	c7 43 08 cc 82 10 f0 	movl   $0xf01082cc,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104f86:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104f8d:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104f90:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104f97:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104f9d:	0f 86 22 01 00 00    	jbe    f01050c5 <debuginfo_eip+0x162>
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104fa3:	c7 45 b8 7a 95 11 f0 	movl   $0xf011957a,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104faa:	c7 45 b4 a5 5c 11 f0 	movl   $0xf0115ca5,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104fb1:	be a4 5c 11 f0       	mov    $0xf0115ca4,%esi
		stabs = __STAB_BEGIN__;
f0104fb6:	c7 45 bc 34 88 10 f0 	movl   $0xf0108834,-0x44(%ebp)
		if (user_mem_check(curenv, stabs  , stab_end   -stabs  , PTE_U) < 0) return -1;
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0) return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104fbd:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0104fc0:	39 4d b4             	cmp    %ecx,-0x4c(%ebp)
f0104fc3:	0f 83 61 02 00 00    	jae    f010522a <debuginfo_eip+0x2c7>
f0104fc9:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0104fcd:	0f 85 5e 02 00 00    	jne    f0105231 <debuginfo_eip+0x2ce>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104fd3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104fda:	2b 75 bc             	sub    -0x44(%ebp),%esi
f0104fdd:	c1 fe 02             	sar    $0x2,%esi
f0104fe0:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0104fe6:	83 e8 01             	sub    $0x1,%eax
f0104fe9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104fec:	83 ec 08             	sub    $0x8,%esp
f0104fef:	57                   	push   %edi
f0104ff0:	6a 64                	push   $0x64
f0104ff2:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104ff5:	89 d1                	mov    %edx,%ecx
f0104ff7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104ffa:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0104ffd:	89 f0                	mov    %esi,%eax
f0104fff:	e8 6f fe ff ff       	call   f0104e73 <stab_binsearch>
	if (lfile == 0)
f0105004:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105007:	83 c4 10             	add    $0x10,%esp
f010500a:	85 c0                	test   %eax,%eax
f010500c:	0f 84 26 02 00 00    	je     f0105238 <debuginfo_eip+0x2d5>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105012:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105015:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105018:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010501b:	83 ec 08             	sub    $0x8,%esp
f010501e:	57                   	push   %edi
f010501f:	6a 24                	push   $0x24
f0105021:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0105024:	89 d1                	mov    %edx,%ecx
f0105026:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105029:	89 f0                	mov    %esi,%eax
f010502b:	e8 43 fe ff ff       	call   f0104e73 <stab_binsearch>

	if (lfun <= rfun) {
f0105030:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105033:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105036:	83 c4 10             	add    $0x10,%esp
f0105039:	39 d0                	cmp    %edx,%eax
f010503b:	0f 8f 31 01 00 00    	jg     f0105172 <debuginfo_eip+0x20f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105041:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105044:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0105047:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f010504a:	8b 36                	mov    (%esi),%esi
f010504c:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f010504f:	2b 4d b4             	sub    -0x4c(%ebp),%ecx
f0105052:	39 ce                	cmp    %ecx,%esi
f0105054:	73 06                	jae    f010505c <debuginfo_eip+0xf9>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105056:	03 75 b4             	add    -0x4c(%ebp),%esi
f0105059:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010505c:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010505f:	8b 4e 08             	mov    0x8(%esi),%ecx
f0105062:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105065:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0105067:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010506a:	89 55 d0             	mov    %edx,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010506d:	83 ec 08             	sub    $0x8,%esp
f0105070:	6a 3a                	push   $0x3a
f0105072:	ff 73 08             	pushl  0x8(%ebx)
f0105075:	e8 67 0b 00 00       	call   f0105be1 <strfind>
f010507a:	2b 43 08             	sub    0x8(%ebx),%eax
f010507d:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105080:	83 c4 08             	add    $0x8,%esp
f0105083:	57                   	push   %edi
f0105084:	6a 44                	push   $0x44
f0105086:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105089:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010508c:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010508f:	89 f0                	mov    %esi,%eax
f0105091:	e8 dd fd ff ff       	call   f0104e73 <stab_binsearch>
	if (lline <= rline) {
f0105096:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105099:	83 c4 10             	add    $0x10,%esp
f010509c:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f010509f:	0f 8f 9a 01 00 00    	jg     f010523f <debuginfo_eip+0x2dc>
		info->eip_line = stabs[lline].n_desc;
f01050a5:	89 d0                	mov    %edx,%eax
f01050a7:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01050aa:	c1 e2 02             	shl    $0x2,%edx
f01050ad:	0f b7 4c 16 06       	movzwl 0x6(%esi,%edx,1),%ecx
f01050b2:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01050b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050b8:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f01050bc:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01050c0:	e9 cb 00 00 00       	jmp    f0105190 <debuginfo_eip+0x22d>
		if (user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0) return -1;
f01050c5:	e8 34 11 00 00       	call   f01061fe <cpunum>
f01050ca:	6a 04                	push   $0x4
f01050cc:	6a 10                	push   $0x10
f01050ce:	68 00 00 20 00       	push   $0x200000
f01050d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01050d6:	ff b0 28 10 25 f0    	pushl  -0xfdaefd8(%eax)
f01050dc:	e8 20 e2 ff ff       	call   f0103301 <user_mem_check>
f01050e1:	83 c4 10             	add    $0x10,%esp
f01050e4:	85 c0                	test   %eax,%eax
f01050e6:	0f 88 30 01 00 00    	js     f010521c <debuginfo_eip+0x2b9>
		stabs = usd->stabs;
f01050ec:	8b 0d 00 00 20 00    	mov    0x200000,%ecx
f01050f2:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stab_end = usd->stab_end;
f01050f5:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f01050fb:	a1 08 00 20 00       	mov    0x200008,%eax
f0105100:	89 45 b4             	mov    %eax,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0105103:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0105109:	89 55 b8             	mov    %edx,-0x48(%ebp)
		if (user_mem_check(curenv, stabs  , stab_end   -stabs  , PTE_U) < 0) return -1;
f010510c:	e8 ed 10 00 00       	call   f01061fe <cpunum>
f0105111:	6a 04                	push   $0x4
f0105113:	89 f2                	mov    %esi,%edx
f0105115:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f0105118:	29 ca                	sub    %ecx,%edx
f010511a:	c1 fa 02             	sar    $0x2,%edx
f010511d:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0105123:	52                   	push   %edx
f0105124:	51                   	push   %ecx
f0105125:	6b c0 74             	imul   $0x74,%eax,%eax
f0105128:	ff b0 28 10 25 f0    	pushl  -0xfdaefd8(%eax)
f010512e:	e8 ce e1 ff ff       	call   f0103301 <user_mem_check>
f0105133:	83 c4 10             	add    $0x10,%esp
f0105136:	85 c0                	test   %eax,%eax
f0105138:	0f 88 e5 00 00 00    	js     f0105223 <debuginfo_eip+0x2c0>
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U) < 0) return -1;
f010513e:	e8 bb 10 00 00       	call   f01061fe <cpunum>
f0105143:	6a 04                	push   $0x4
f0105145:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0105148:	8b 4d b4             	mov    -0x4c(%ebp),%ecx
f010514b:	29 ca                	sub    %ecx,%edx
f010514d:	52                   	push   %edx
f010514e:	51                   	push   %ecx
f010514f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105152:	ff b0 28 10 25 f0    	pushl  -0xfdaefd8(%eax)
f0105158:	e8 a4 e1 ff ff       	call   f0103301 <user_mem_check>
f010515d:	83 c4 10             	add    $0x10,%esp
f0105160:	85 c0                	test   %eax,%eax
f0105162:	0f 89 55 fe ff ff    	jns    f0104fbd <debuginfo_eip+0x5a>
f0105168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010516d:	e9 d9 00 00 00       	jmp    f010524b <debuginfo_eip+0x2e8>
		info->eip_fn_addr = addr;
f0105172:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0105175:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105178:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010517b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010517e:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105181:	e9 e7 fe ff ff       	jmp    f010506d <debuginfo_eip+0x10a>
f0105186:	83 e8 01             	sub    $0x1,%eax
f0105189:	83 ea 0c             	sub    $0xc,%edx
f010518c:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0105190:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0105193:	39 c7                	cmp    %eax,%edi
f0105195:	7f 45                	jg     f01051dc <debuginfo_eip+0x279>
	       && stabs[lline].n_type != N_SOL
f0105197:	0f b6 0a             	movzbl (%edx),%ecx
f010519a:	80 f9 84             	cmp    $0x84,%cl
f010519d:	74 19                	je     f01051b8 <debuginfo_eip+0x255>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010519f:	80 f9 64             	cmp    $0x64,%cl
f01051a2:	75 e2                	jne    f0105186 <debuginfo_eip+0x223>
f01051a4:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f01051a8:	74 dc                	je     f0105186 <debuginfo_eip+0x223>
f01051aa:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01051ae:	74 11                	je     f01051c1 <debuginfo_eip+0x25e>
f01051b0:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01051b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01051b6:	eb 09                	jmp    f01051c1 <debuginfo_eip+0x25e>
f01051b8:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f01051bc:	74 03                	je     f01051c1 <debuginfo_eip+0x25e>
f01051be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01051c1:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01051c4:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01051c7:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01051ca:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01051cd:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f01051d0:	29 f8                	sub    %edi,%eax
f01051d2:	39 c2                	cmp    %eax,%edx
f01051d4:	73 06                	jae    f01051dc <debuginfo_eip+0x279>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01051d6:	89 f8                	mov    %edi,%eax
f01051d8:	01 d0                	add    %edx,%eax
f01051da:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01051dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01051df:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01051e2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f01051e7:	39 f2                	cmp    %esi,%edx
f01051e9:	7d 60                	jge    f010524b <debuginfo_eip+0x2e8>
		for (lline = lfun + 1;
f01051eb:	83 c2 01             	add    $0x1,%edx
f01051ee:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01051f1:	89 d0                	mov    %edx,%eax
f01051f3:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01051f6:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01051f9:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01051fd:	eb 04                	jmp    f0105203 <debuginfo_eip+0x2a0>
			info->eip_fn_narg++;
f01051ff:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0105203:	39 c6                	cmp    %eax,%esi
f0105205:	7e 3f                	jle    f0105246 <debuginfo_eip+0x2e3>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105207:	0f b6 0a             	movzbl (%edx),%ecx
f010520a:	83 c0 01             	add    $0x1,%eax
f010520d:	83 c2 0c             	add    $0xc,%edx
f0105210:	80 f9 a0             	cmp    $0xa0,%cl
f0105213:	74 ea                	je     f01051ff <debuginfo_eip+0x29c>
	return 0;
f0105215:	b8 00 00 00 00       	mov    $0x0,%eax
f010521a:	eb 2f                	jmp    f010524b <debuginfo_eip+0x2e8>
		if (user_mem_check(curenv, (void*)usd, sizeof(struct UserStabData), PTE_U) < 0) return -1;
f010521c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105221:	eb 28                	jmp    f010524b <debuginfo_eip+0x2e8>
		if (user_mem_check(curenv, stabs  , stab_end   -stabs  , PTE_U) < 0) return -1;
f0105223:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105228:	eb 21                	jmp    f010524b <debuginfo_eip+0x2e8>
		return -1;
f010522a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010522f:	eb 1a                	jmp    f010524b <debuginfo_eip+0x2e8>
f0105231:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105236:	eb 13                	jmp    f010524b <debuginfo_eip+0x2e8>
		return -1;
f0105238:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010523d:	eb 0c                	jmp    f010524b <debuginfo_eip+0x2e8>
	else return -1;
f010523f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105244:	eb 05                	jmp    f010524b <debuginfo_eip+0x2e8>
	return 0;
f0105246:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010524b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010524e:	5b                   	pop    %ebx
f010524f:	5e                   	pop    %esi
f0105250:	5f                   	pop    %edi
f0105251:	5d                   	pop    %ebp
f0105252:	c3                   	ret    

f0105253 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105253:	55                   	push   %ebp
f0105254:	89 e5                	mov    %esp,%ebp
f0105256:	57                   	push   %edi
f0105257:	56                   	push   %esi
f0105258:	53                   	push   %ebx
f0105259:	83 ec 1c             	sub    $0x1c,%esp
f010525c:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010525f:	89 d3                	mov    %edx,%ebx
f0105261:	8b 75 08             	mov    0x8(%ebp),%esi
f0105264:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0105267:	8b 45 10             	mov    0x10(%ebp),%eax
f010526a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
f010526d:	89 c2                	mov    %eax,%edx
f010526f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105274:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105277:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010527a:	39 c6                	cmp    %eax,%esi
f010527c:	89 f8                	mov    %edi,%eax
f010527e:	19 c8                	sbb    %ecx,%eax
f0105280:	73 32                	jae    f01052b4 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
f0105282:	83 ec 08             	sub    $0x8,%esp
f0105285:	53                   	push   %ebx
f0105286:	83 ec 04             	sub    $0x4,%esp
f0105289:	ff 75 e4             	pushl  -0x1c(%ebp)
f010528c:	ff 75 e0             	pushl  -0x20(%ebp)
f010528f:	57                   	push   %edi
f0105290:	56                   	push   %esi
f0105291:	e8 7a 14 00 00       	call   f0106710 <__umoddi3>
f0105296:	83 c4 14             	add    $0x14,%esp
f0105299:	0f be 80 d6 82 10 f0 	movsbl -0xfef7d2a(%eax),%eax
f01052a0:	50                   	push   %eax
f01052a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01052a4:	ff d0                	call   *%eax
	return remain - 1;
f01052a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01052a9:	83 e8 01             	sub    $0x1,%eax
}
f01052ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01052af:	5b                   	pop    %ebx
f01052b0:	5e                   	pop    %esi
f01052b1:	5f                   	pop    %edi
f01052b2:	5d                   	pop    %ebp
f01052b3:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
f01052b4:	83 ec 0c             	sub    $0xc,%esp
f01052b7:	ff 75 18             	pushl  0x18(%ebp)
f01052ba:	ff 75 14             	pushl  0x14(%ebp)
f01052bd:	ff 75 d8             	pushl  -0x28(%ebp)
f01052c0:	83 ec 08             	sub    $0x8,%esp
f01052c3:	51                   	push   %ecx
f01052c4:	52                   	push   %edx
f01052c5:	57                   	push   %edi
f01052c6:	56                   	push   %esi
f01052c7:	e8 34 13 00 00       	call   f0106600 <__udivdi3>
f01052cc:	83 c4 18             	add    $0x18,%esp
f01052cf:	52                   	push   %edx
f01052d0:	50                   	push   %eax
f01052d1:	89 da                	mov    %ebx,%edx
f01052d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01052d6:	e8 78 ff ff ff       	call   f0105253 <printnum_helper>
f01052db:	89 45 14             	mov    %eax,0x14(%ebp)
f01052de:	83 c4 20             	add    $0x20,%esp
f01052e1:	eb 9f                	jmp    f0105282 <printnum_helper+0x2f>

f01052e3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01052e3:	55                   	push   %ebp
f01052e4:	89 e5                	mov    %esp,%ebp
f01052e6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01052e9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01052ed:	8b 10                	mov    (%eax),%edx
f01052ef:	3b 50 04             	cmp    0x4(%eax),%edx
f01052f2:	73 0a                	jae    f01052fe <sprintputch+0x1b>
		*b->buf++ = ch;
f01052f4:	8d 4a 01             	lea    0x1(%edx),%ecx
f01052f7:	89 08                	mov    %ecx,(%eax)
f01052f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01052fc:	88 02                	mov    %al,(%edx)
}
f01052fe:	5d                   	pop    %ebp
f01052ff:	c3                   	ret    

f0105300 <printfmt>:
{
f0105300:	55                   	push   %ebp
f0105301:	89 e5                	mov    %esp,%ebp
f0105303:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0105306:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105309:	50                   	push   %eax
f010530a:	ff 75 10             	pushl  0x10(%ebp)
f010530d:	ff 75 0c             	pushl  0xc(%ebp)
f0105310:	ff 75 08             	pushl  0x8(%ebp)
f0105313:	e8 05 00 00 00       	call   f010531d <vprintfmt>
}
f0105318:	83 c4 10             	add    $0x10,%esp
f010531b:	c9                   	leave  
f010531c:	c3                   	ret    

f010531d <vprintfmt>:
{
f010531d:	55                   	push   %ebp
f010531e:	89 e5                	mov    %esp,%ebp
f0105320:	57                   	push   %edi
f0105321:	56                   	push   %esi
f0105322:	53                   	push   %ebx
f0105323:	83 ec 3c             	sub    $0x3c,%esp
f0105326:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105329:	8b 75 0c             	mov    0xc(%ebp),%esi
f010532c:	8b 7d 10             	mov    0x10(%ebp),%edi
f010532f:	e9 3f 05 00 00       	jmp    f0105873 <vprintfmt+0x556>
		padc = ' ';
f0105334:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
f0105338:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
f010533f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
f0105346:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
f010534d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
f0105354:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
f010535b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105360:	8d 47 01             	lea    0x1(%edi),%eax
f0105363:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105366:	0f b6 17             	movzbl (%edi),%edx
f0105369:	8d 42 dd             	lea    -0x23(%edx),%eax
f010536c:	3c 55                	cmp    $0x55,%al
f010536e:	0f 87 98 05 00 00    	ja     f010590c <vprintfmt+0x5ef>
f0105374:	0f b6 c0             	movzbl %al,%eax
f0105377:	ff 24 85 20 84 10 f0 	jmp    *-0xfef7be0(,%eax,4)
f010537e:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
f0105381:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
f0105385:	eb d9                	jmp    f0105360 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
f0105387:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
f010538a:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
f0105391:	eb cd                	jmp    f0105360 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
f0105393:	0f b6 d2             	movzbl %dl,%edx
f0105396:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0105399:	b8 00 00 00 00       	mov    $0x0,%eax
f010539e:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
f01053a1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01053a4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01053a8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f01053ab:	8d 5a d0             	lea    -0x30(%edx),%ebx
f01053ae:	83 fb 09             	cmp    $0x9,%ebx
f01053b1:	77 5c                	ja     f010540f <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
f01053b3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f01053b6:	eb e9                	jmp    f01053a1 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
f01053b8:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
f01053bb:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
f01053bf:	eb 9f                	jmp    f0105360 <vprintfmt+0x43>
			precision = va_arg(ap, int);
f01053c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01053c4:	8b 00                	mov    (%eax),%eax
f01053c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01053c9:	8b 45 14             	mov    0x14(%ebp),%eax
f01053cc:	8d 40 04             	lea    0x4(%eax),%eax
f01053cf:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01053d2:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
f01053d5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01053d9:	79 85                	jns    f0105360 <vprintfmt+0x43>
				width = precision, precision = -1;
f01053db:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01053de:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01053e1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f01053e8:	e9 73 ff ff ff       	jmp    f0105360 <vprintfmt+0x43>
f01053ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01053f0:	85 c0                	test   %eax,%eax
f01053f2:	0f 48 c1             	cmovs  %ecx,%eax
f01053f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01053f8:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01053fb:	e9 60 ff ff ff       	jmp    f0105360 <vprintfmt+0x43>
f0105400:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
f0105403:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
f010540a:	e9 51 ff ff ff       	jmp    f0105360 <vprintfmt+0x43>
f010540f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105412:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0105415:	eb be                	jmp    f01053d5 <vprintfmt+0xb8>
			lflag++;
f0105417:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010541b:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
f010541e:	e9 3d ff ff ff       	jmp    f0105360 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
f0105423:	8b 45 14             	mov    0x14(%ebp),%eax
f0105426:	8d 78 04             	lea    0x4(%eax),%edi
f0105429:	83 ec 08             	sub    $0x8,%esp
f010542c:	56                   	push   %esi
f010542d:	ff 30                	pushl  (%eax)
f010542f:	ff d3                	call   *%ebx
			break;
f0105431:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0105434:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0105437:	e9 34 04 00 00       	jmp    f0105870 <vprintfmt+0x553>
			err = va_arg(ap, int);
f010543c:	8b 45 14             	mov    0x14(%ebp),%eax
f010543f:	8d 78 04             	lea    0x4(%eax),%edi
f0105442:	8b 00                	mov    (%eax),%eax
f0105444:	99                   	cltd   
f0105445:	31 d0                	xor    %edx,%eax
f0105447:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105449:	83 f8 08             	cmp    $0x8,%eax
f010544c:	7f 23                	jg     f0105471 <vprintfmt+0x154>
f010544e:	8b 14 85 80 85 10 f0 	mov    -0xfef7a80(,%eax,4),%edx
f0105455:	85 d2                	test   %edx,%edx
f0105457:	74 18                	je     f0105471 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
f0105459:	52                   	push   %edx
f010545a:	68 a5 7a 10 f0       	push   $0xf0107aa5
f010545f:	56                   	push   %esi
f0105460:	53                   	push   %ebx
f0105461:	e8 9a fe ff ff       	call   f0105300 <printfmt>
f0105466:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105469:	89 7d 14             	mov    %edi,0x14(%ebp)
f010546c:	e9 ff 03 00 00       	jmp    f0105870 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
f0105471:	50                   	push   %eax
f0105472:	68 ee 82 10 f0       	push   $0xf01082ee
f0105477:	56                   	push   %esi
f0105478:	53                   	push   %ebx
f0105479:	e8 82 fe ff ff       	call   f0105300 <printfmt>
f010547e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105481:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105484:	e9 e7 03 00 00       	jmp    f0105870 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
f0105489:	8b 45 14             	mov    0x14(%ebp),%eax
f010548c:	83 c0 04             	add    $0x4,%eax
f010548f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0105492:	8b 45 14             	mov    0x14(%ebp),%eax
f0105495:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
f0105497:	85 c9                	test   %ecx,%ecx
f0105499:	b8 e7 82 10 f0       	mov    $0xf01082e7,%eax
f010549e:	0f 45 c1             	cmovne %ecx,%eax
f01054a1:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01054a4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01054a8:	7e 06                	jle    f01054b0 <vprintfmt+0x193>
f01054aa:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
f01054ae:	75 0d                	jne    f01054bd <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
f01054b0:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01054b3:	89 c7                	mov    %eax,%edi
f01054b5:	03 45 d8             	add    -0x28(%ebp),%eax
f01054b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01054bb:	eb 53                	jmp    f0105510 <vprintfmt+0x1f3>
f01054bd:	83 ec 08             	sub    $0x8,%esp
f01054c0:	ff 75 e0             	pushl  -0x20(%ebp)
f01054c3:	50                   	push   %eax
f01054c4:	e8 cd 05 00 00       	call   f0105a96 <strnlen>
f01054c9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01054cc:	29 c1                	sub    %eax,%ecx
f01054ce:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f01054d1:	83 c4 10             	add    $0x10,%esp
f01054d4:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
f01054d6:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
f01054da:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01054dd:	eb 0f                	jmp    f01054ee <vprintfmt+0x1d1>
					putch(padc, putdat);
f01054df:	83 ec 08             	sub    $0x8,%esp
f01054e2:	56                   	push   %esi
f01054e3:	ff 75 d8             	pushl  -0x28(%ebp)
f01054e6:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
f01054e8:	83 ef 01             	sub    $0x1,%edi
f01054eb:	83 c4 10             	add    $0x10,%esp
f01054ee:	85 ff                	test   %edi,%edi
f01054f0:	7f ed                	jg     f01054df <vprintfmt+0x1c2>
f01054f2:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f01054f5:	85 c9                	test   %ecx,%ecx
f01054f7:	b8 00 00 00 00       	mov    $0x0,%eax
f01054fc:	0f 49 c1             	cmovns %ecx,%eax
f01054ff:	29 c1                	sub    %eax,%ecx
f0105501:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0105504:	eb aa                	jmp    f01054b0 <vprintfmt+0x193>
					putch(ch, putdat);
f0105506:	83 ec 08             	sub    $0x8,%esp
f0105509:	56                   	push   %esi
f010550a:	52                   	push   %edx
f010550b:	ff d3                	call   *%ebx
f010550d:	83 c4 10             	add    $0x10,%esp
f0105510:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0105513:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105515:	83 c7 01             	add    $0x1,%edi
f0105518:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010551c:	0f be d0             	movsbl %al,%edx
f010551f:	85 d2                	test   %edx,%edx
f0105521:	74 2e                	je     f0105551 <vprintfmt+0x234>
f0105523:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105527:	78 06                	js     f010552f <vprintfmt+0x212>
f0105529:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f010552d:	78 1e                	js     f010554d <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
f010552f:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0105533:	74 d1                	je     f0105506 <vprintfmt+0x1e9>
f0105535:	0f be c0             	movsbl %al,%eax
f0105538:	83 e8 20             	sub    $0x20,%eax
f010553b:	83 f8 5e             	cmp    $0x5e,%eax
f010553e:	76 c6                	jbe    f0105506 <vprintfmt+0x1e9>
					putch('?', putdat);
f0105540:	83 ec 08             	sub    $0x8,%esp
f0105543:	56                   	push   %esi
f0105544:	6a 3f                	push   $0x3f
f0105546:	ff d3                	call   *%ebx
f0105548:	83 c4 10             	add    $0x10,%esp
f010554b:	eb c3                	jmp    f0105510 <vprintfmt+0x1f3>
f010554d:	89 cf                	mov    %ecx,%edi
f010554f:	eb 02                	jmp    f0105553 <vprintfmt+0x236>
f0105551:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
f0105553:	85 ff                	test   %edi,%edi
f0105555:	7e 10                	jle    f0105567 <vprintfmt+0x24a>
				putch(' ', putdat);
f0105557:	83 ec 08             	sub    $0x8,%esp
f010555a:	56                   	push   %esi
f010555b:	6a 20                	push   $0x20
f010555d:	ff d3                	call   *%ebx
			for (; width > 0; width--)
f010555f:	83 ef 01             	sub    $0x1,%edi
f0105562:	83 c4 10             	add    $0x10,%esp
f0105565:	eb ec                	jmp    f0105553 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
f0105567:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010556a:	89 45 14             	mov    %eax,0x14(%ebp)
f010556d:	e9 fe 02 00 00       	jmp    f0105870 <vprintfmt+0x553>
	if (lflag >= 2)
f0105572:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
f0105576:	7f 21                	jg     f0105599 <vprintfmt+0x27c>
	else if (lflag)
f0105578:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f010557c:	74 79                	je     f01055f7 <vprintfmt+0x2da>
		return va_arg(*ap, long);
f010557e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105581:	8b 00                	mov    (%eax),%eax
f0105583:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105586:	89 c1                	mov    %eax,%ecx
f0105588:	c1 f9 1f             	sar    $0x1f,%ecx
f010558b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010558e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105591:	8d 40 04             	lea    0x4(%eax),%eax
f0105594:	89 45 14             	mov    %eax,0x14(%ebp)
f0105597:	eb 17                	jmp    f01055b0 <vprintfmt+0x293>
		return va_arg(*ap, long long);
f0105599:	8b 45 14             	mov    0x14(%ebp),%eax
f010559c:	8b 50 04             	mov    0x4(%eax),%edx
f010559f:	8b 00                	mov    (%eax),%eax
f01055a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01055a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01055a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01055aa:	8d 40 08             	lea    0x8(%eax),%eax
f01055ad:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
f01055b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01055b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01055b9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
f01055bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01055c0:	78 50                	js     f0105612 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
f01055c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01055c5:	c1 fa 1f             	sar    $0x1f,%edx
f01055c8:	89 d0                	mov    %edx,%eax
f01055ca:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01055cd:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
f01055d0:	85 d2                	test   %edx,%edx
f01055d2:	0f 89 14 02 00 00    	jns    f01057ec <vprintfmt+0x4cf>
f01055d8:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f01055dc:	0f 84 0a 02 00 00    	je     f01057ec <vprintfmt+0x4cf>
				putch('+', putdat);
f01055e2:	83 ec 08             	sub    $0x8,%esp
f01055e5:	56                   	push   %esi
f01055e6:	6a 2b                	push   $0x2b
f01055e8:	ff d3                	call   *%ebx
f01055ea:	83 c4 10             	add    $0x10,%esp
			base = 10;
f01055ed:	b8 0a 00 00 00       	mov    $0xa,%eax
f01055f2:	e9 5c 01 00 00       	jmp    f0105753 <vprintfmt+0x436>
		return va_arg(*ap, int);
f01055f7:	8b 45 14             	mov    0x14(%ebp),%eax
f01055fa:	8b 00                	mov    (%eax),%eax
f01055fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01055ff:	89 c1                	mov    %eax,%ecx
f0105601:	c1 f9 1f             	sar    $0x1f,%ecx
f0105604:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0105607:	8b 45 14             	mov    0x14(%ebp),%eax
f010560a:	8d 40 04             	lea    0x4(%eax),%eax
f010560d:	89 45 14             	mov    %eax,0x14(%ebp)
f0105610:	eb 9e                	jmp    f01055b0 <vprintfmt+0x293>
				putch('-', putdat);
f0105612:	83 ec 08             	sub    $0x8,%esp
f0105615:	56                   	push   %esi
f0105616:	6a 2d                	push   $0x2d
f0105618:	ff d3                	call   *%ebx
				num = -(long long) num;
f010561a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010561d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105620:	f7 d8                	neg    %eax
f0105622:	83 d2 00             	adc    $0x0,%edx
f0105625:	f7 da                	neg    %edx
f0105627:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010562a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010562d:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0105630:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105635:	e9 19 01 00 00       	jmp    f0105753 <vprintfmt+0x436>
	if (lflag >= 2)
f010563a:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
f010563e:	7f 29                	jg     f0105669 <vprintfmt+0x34c>
	else if (lflag)
f0105640:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f0105644:	74 44                	je     f010568a <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
f0105646:	8b 45 14             	mov    0x14(%ebp),%eax
f0105649:	8b 00                	mov    (%eax),%eax
f010564b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105650:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105653:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105656:	8b 45 14             	mov    0x14(%ebp),%eax
f0105659:	8d 40 04             	lea    0x4(%eax),%eax
f010565c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010565f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105664:	e9 ea 00 00 00       	jmp    f0105753 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
f0105669:	8b 45 14             	mov    0x14(%ebp),%eax
f010566c:	8b 50 04             	mov    0x4(%eax),%edx
f010566f:	8b 00                	mov    (%eax),%eax
f0105671:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105674:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105677:	8b 45 14             	mov    0x14(%ebp),%eax
f010567a:	8d 40 08             	lea    0x8(%eax),%eax
f010567d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105680:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105685:	e9 c9 00 00 00       	jmp    f0105753 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
f010568a:	8b 45 14             	mov    0x14(%ebp),%eax
f010568d:	8b 00                	mov    (%eax),%eax
f010568f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105694:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105697:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010569a:	8b 45 14             	mov    0x14(%ebp),%eax
f010569d:	8d 40 04             	lea    0x4(%eax),%eax
f01056a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01056a3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01056a8:	e9 a6 00 00 00       	jmp    f0105753 <vprintfmt+0x436>
			putch('0', putdat);
f01056ad:	83 ec 08             	sub    $0x8,%esp
f01056b0:	56                   	push   %esi
f01056b1:	6a 30                	push   $0x30
f01056b3:	ff d3                	call   *%ebx
	if (lflag >= 2)
f01056b5:	83 c4 10             	add    $0x10,%esp
f01056b8:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
f01056bc:	7f 26                	jg     f01056e4 <vprintfmt+0x3c7>
	else if (lflag)
f01056be:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f01056c2:	74 3e                	je     f0105702 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
f01056c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01056c7:	8b 00                	mov    (%eax),%eax
f01056c9:	ba 00 00 00 00       	mov    $0x0,%edx
f01056ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01056d1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01056d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01056d7:	8d 40 04             	lea    0x4(%eax),%eax
f01056da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01056dd:	b8 08 00 00 00       	mov    $0x8,%eax
f01056e2:	eb 6f                	jmp    f0105753 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
f01056e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01056e7:	8b 50 04             	mov    0x4(%eax),%edx
f01056ea:	8b 00                	mov    (%eax),%eax
f01056ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01056ef:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01056f2:	8b 45 14             	mov    0x14(%ebp),%eax
f01056f5:	8d 40 08             	lea    0x8(%eax),%eax
f01056f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f01056fb:	b8 08 00 00 00       	mov    $0x8,%eax
f0105700:	eb 51                	jmp    f0105753 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
f0105702:	8b 45 14             	mov    0x14(%ebp),%eax
f0105705:	8b 00                	mov    (%eax),%eax
f0105707:	ba 00 00 00 00       	mov    $0x0,%edx
f010570c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010570f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105712:	8b 45 14             	mov    0x14(%ebp),%eax
f0105715:	8d 40 04             	lea    0x4(%eax),%eax
f0105718:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010571b:	b8 08 00 00 00       	mov    $0x8,%eax
f0105720:	eb 31                	jmp    f0105753 <vprintfmt+0x436>
			putch('0', putdat);
f0105722:	83 ec 08             	sub    $0x8,%esp
f0105725:	56                   	push   %esi
f0105726:	6a 30                	push   $0x30
f0105728:	ff d3                	call   *%ebx
			putch('x', putdat);
f010572a:	83 c4 08             	add    $0x8,%esp
f010572d:	56                   	push   %esi
f010572e:	6a 78                	push   $0x78
f0105730:	ff d3                	call   *%ebx
			num = (unsigned long long)
f0105732:	8b 45 14             	mov    0x14(%ebp),%eax
f0105735:	8b 00                	mov    (%eax),%eax
f0105737:	ba 00 00 00 00       	mov    $0x0,%edx
f010573c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010573f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
f0105742:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105745:	8b 45 14             	mov    0x14(%ebp),%eax
f0105748:	8d 40 04             	lea    0x4(%eax),%eax
f010574b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010574e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105753:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
f0105757:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010575a:	89 c1                	mov    %eax,%ecx
f010575c:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
f010575f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0105762:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
f0105767:	89 c2                	mov    %eax,%edx
f0105769:	39 c1                	cmp    %eax,%ecx
f010576b:	0f 87 85 00 00 00    	ja     f01057f6 <vprintfmt+0x4d9>
		tmp /= base;
f0105771:	89 d0                	mov    %edx,%eax
f0105773:	ba 00 00 00 00       	mov    $0x0,%edx
f0105778:	f7 f1                	div    %ecx
		len++;
f010577a:	83 c7 01             	add    $0x1,%edi
f010577d:	eb e8                	jmp    f0105767 <vprintfmt+0x44a>
	if (lflag >= 2)
f010577f:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
f0105783:	7f 26                	jg     f01057ab <vprintfmt+0x48e>
	else if (lflag)
f0105785:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
f0105789:	74 3e                	je     f01057c9 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
f010578b:	8b 45 14             	mov    0x14(%ebp),%eax
f010578e:	8b 00                	mov    (%eax),%eax
f0105790:	ba 00 00 00 00       	mov    $0x0,%edx
f0105795:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105798:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010579b:	8b 45 14             	mov    0x14(%ebp),%eax
f010579e:	8d 40 04             	lea    0x4(%eax),%eax
f01057a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01057a4:	b8 10 00 00 00       	mov    $0x10,%eax
f01057a9:	eb a8                	jmp    f0105753 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
f01057ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01057ae:	8b 50 04             	mov    0x4(%eax),%edx
f01057b1:	8b 00                	mov    (%eax),%eax
f01057b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01057b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01057b9:	8b 45 14             	mov    0x14(%ebp),%eax
f01057bc:	8d 40 08             	lea    0x8(%eax),%eax
f01057bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01057c2:	b8 10 00 00 00       	mov    $0x10,%eax
f01057c7:	eb 8a                	jmp    f0105753 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
f01057c9:	8b 45 14             	mov    0x14(%ebp),%eax
f01057cc:	8b 00                	mov    (%eax),%eax
f01057ce:	ba 00 00 00 00       	mov    $0x0,%edx
f01057d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01057d6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01057d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01057dc:	8d 40 04             	lea    0x4(%eax),%eax
f01057df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01057e2:	b8 10 00 00 00       	mov    $0x10,%eax
f01057e7:	e9 67 ff ff ff       	jmp    f0105753 <vprintfmt+0x436>
			base = 10;
f01057ec:	b8 0a 00 00 00       	mov    $0xa,%eax
f01057f1:	e9 5d ff ff ff       	jmp    f0105753 <vprintfmt+0x436>
f01057f6:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
f01057f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01057fc:	29 f8                	sub    %edi,%eax
f01057fe:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
f0105800:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
f0105804:	74 15                	je     f010581b <vprintfmt+0x4fe>
		while (width > 0) {
f0105806:	85 ff                	test   %edi,%edi
f0105808:	7e 48                	jle    f0105852 <vprintfmt+0x535>
			putch(padc, putdat);
f010580a:	83 ec 08             	sub    $0x8,%esp
f010580d:	56                   	push   %esi
f010580e:	ff 75 e0             	pushl  -0x20(%ebp)
f0105811:	ff d3                	call   *%ebx
			width--;
f0105813:	83 ef 01             	sub    $0x1,%edi
f0105816:	83 c4 10             	add    $0x10,%esp
f0105819:	eb eb                	jmp    f0105806 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
f010581b:	83 ec 0c             	sub    $0xc,%esp
f010581e:	6a 2d                	push   $0x2d
f0105820:	ff 75 cc             	pushl  -0x34(%ebp)
f0105823:	ff 75 c8             	pushl  -0x38(%ebp)
f0105826:	ff 75 d4             	pushl  -0x2c(%ebp)
f0105829:	ff 75 d0             	pushl  -0x30(%ebp)
f010582c:	89 f2                	mov    %esi,%edx
f010582e:	89 d8                	mov    %ebx,%eax
f0105830:	e8 1e fa ff ff       	call   f0105253 <printnum_helper>
		width -= len;
f0105835:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0105838:	2b 7d cc             	sub    -0x34(%ebp),%edi
f010583b:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
f010583e:	85 ff                	test   %edi,%edi
f0105840:	7e 2e                	jle    f0105870 <vprintfmt+0x553>
			putch(padc, putdat);
f0105842:	83 ec 08             	sub    $0x8,%esp
f0105845:	56                   	push   %esi
f0105846:	6a 20                	push   $0x20
f0105848:	ff d3                	call   *%ebx
			width--;
f010584a:	83 ef 01             	sub    $0x1,%edi
f010584d:	83 c4 10             	add    $0x10,%esp
f0105850:	eb ec                	jmp    f010583e <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
f0105852:	83 ec 0c             	sub    $0xc,%esp
f0105855:	ff 75 e0             	pushl  -0x20(%ebp)
f0105858:	ff 75 cc             	pushl  -0x34(%ebp)
f010585b:	ff 75 c8             	pushl  -0x38(%ebp)
f010585e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0105861:	ff 75 d0             	pushl  -0x30(%ebp)
f0105864:	89 f2                	mov    %esi,%edx
f0105866:	89 d8                	mov    %ebx,%eax
f0105868:	e8 e6 f9 ff ff       	call   f0105253 <printnum_helper>
f010586d:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
f0105870:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105873:	83 c7 01             	add    $0x1,%edi
f0105876:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010587a:	83 f8 25             	cmp    $0x25,%eax
f010587d:	0f 84 b1 fa ff ff    	je     f0105334 <vprintfmt+0x17>
			if (ch == '\0')
f0105883:	85 c0                	test   %eax,%eax
f0105885:	0f 84 a1 00 00 00    	je     f010592c <vprintfmt+0x60f>
			putch(ch, putdat);
f010588b:	83 ec 08             	sub    $0x8,%esp
f010588e:	56                   	push   %esi
f010588f:	50                   	push   %eax
f0105890:	ff d3                	call   *%ebx
f0105892:	83 c4 10             	add    $0x10,%esp
f0105895:	eb dc                	jmp    f0105873 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
f0105897:	8b 45 14             	mov    0x14(%ebp),%eax
f010589a:	83 c0 04             	add    $0x4,%eax
f010589d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01058a0:	8b 45 14             	mov    0x14(%ebp),%eax
f01058a3:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
f01058a5:	85 ff                	test   %edi,%edi
f01058a7:	74 15                	je     f01058be <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
f01058a9:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
f01058af:	7f 29                	jg     f01058da <vprintfmt+0x5bd>
				*res = *(char *)putdat;
f01058b1:	0f b6 06             	movzbl (%esi),%eax
f01058b4:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
f01058b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058b9:	89 45 14             	mov    %eax,0x14(%ebp)
f01058bc:	eb b2                	jmp    f0105870 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
f01058be:	68 8c 83 10 f0       	push   $0xf010838c
f01058c3:	68 a5 7a 10 f0       	push   $0xf0107aa5
f01058c8:	56                   	push   %esi
f01058c9:	53                   	push   %ebx
f01058ca:	e8 31 fa ff ff       	call   f0105300 <printfmt>
f01058cf:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
f01058d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058d5:	89 45 14             	mov    %eax,0x14(%ebp)
f01058d8:	eb 96                	jmp    f0105870 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
f01058da:	68 c4 83 10 f0       	push   $0xf01083c4
f01058df:	68 a5 7a 10 f0       	push   $0xf0107aa5
f01058e4:	56                   	push   %esi
f01058e5:	53                   	push   %ebx
f01058e6:	e8 15 fa ff ff       	call   f0105300 <printfmt>
				*res = -1;
f01058eb:	c6 07 ff             	movb   $0xff,(%edi)
f01058ee:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
f01058f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058f4:	89 45 14             	mov    %eax,0x14(%ebp)
f01058f7:	e9 74 ff ff ff       	jmp    f0105870 <vprintfmt+0x553>
			putch(ch, putdat);
f01058fc:	83 ec 08             	sub    $0x8,%esp
f01058ff:	56                   	push   %esi
f0105900:	6a 25                	push   $0x25
f0105902:	ff d3                	call   *%ebx
			break;
f0105904:	83 c4 10             	add    $0x10,%esp
f0105907:	e9 64 ff ff ff       	jmp    f0105870 <vprintfmt+0x553>
			putch('%', putdat);
f010590c:	83 ec 08             	sub    $0x8,%esp
f010590f:	56                   	push   %esi
f0105910:	6a 25                	push   $0x25
f0105912:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105914:	83 c4 10             	add    $0x10,%esp
f0105917:	89 f8                	mov    %edi,%eax
f0105919:	eb 03                	jmp    f010591e <vprintfmt+0x601>
f010591b:	83 e8 01             	sub    $0x1,%eax
f010591e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105922:	75 f7                	jne    f010591b <vprintfmt+0x5fe>
f0105924:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105927:	e9 44 ff ff ff       	jmp    f0105870 <vprintfmt+0x553>
}
f010592c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010592f:	5b                   	pop    %ebx
f0105930:	5e                   	pop    %esi
f0105931:	5f                   	pop    %edi
f0105932:	5d                   	pop    %ebp
f0105933:	c3                   	ret    

f0105934 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105934:	55                   	push   %ebp
f0105935:	89 e5                	mov    %esp,%ebp
f0105937:	83 ec 18             	sub    $0x18,%esp
f010593a:	8b 45 08             	mov    0x8(%ebp),%eax
f010593d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105940:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105943:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105947:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010594a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105951:	85 c0                	test   %eax,%eax
f0105953:	74 26                	je     f010597b <vsnprintf+0x47>
f0105955:	85 d2                	test   %edx,%edx
f0105957:	7e 22                	jle    f010597b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105959:	ff 75 14             	pushl  0x14(%ebp)
f010595c:	ff 75 10             	pushl  0x10(%ebp)
f010595f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105962:	50                   	push   %eax
f0105963:	68 e3 52 10 f0       	push   $0xf01052e3
f0105968:	e8 b0 f9 ff ff       	call   f010531d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010596d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105970:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105973:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105976:	83 c4 10             	add    $0x10,%esp
}
f0105979:	c9                   	leave  
f010597a:	c3                   	ret    
		return -E_INVAL;
f010597b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105980:	eb f7                	jmp    f0105979 <vsnprintf+0x45>

f0105982 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105982:	55                   	push   %ebp
f0105983:	89 e5                	mov    %esp,%ebp
f0105985:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105988:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010598b:	50                   	push   %eax
f010598c:	ff 75 10             	pushl  0x10(%ebp)
f010598f:	ff 75 0c             	pushl  0xc(%ebp)
f0105992:	ff 75 08             	pushl  0x8(%ebp)
f0105995:	e8 9a ff ff ff       	call   f0105934 <vsnprintf>
	va_end(ap);

	return rc;
}
f010599a:	c9                   	leave  
f010599b:	c3                   	ret    

f010599c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010599c:	55                   	push   %ebp
f010599d:	89 e5                	mov    %esp,%ebp
f010599f:	57                   	push   %edi
f01059a0:	56                   	push   %esi
f01059a1:	53                   	push   %ebx
f01059a2:	83 ec 0c             	sub    $0xc,%esp
f01059a5:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01059a8:	85 c0                	test   %eax,%eax
f01059aa:	74 11                	je     f01059bd <readline+0x21>
		cprintf("%s", prompt);
f01059ac:	83 ec 08             	sub    $0x8,%esp
f01059af:	50                   	push   %eax
f01059b0:	68 a5 7a 10 f0       	push   $0xf0107aa5
f01059b5:	e8 1b e3 ff ff       	call   f0103cd5 <cprintf>
f01059ba:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01059bd:	83 ec 0c             	sub    $0xc,%esp
f01059c0:	6a 00                	push   $0x0
f01059c2:	e8 76 ae ff ff       	call   f010083d <iscons>
f01059c7:	89 c7                	mov    %eax,%edi
f01059c9:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01059cc:	be 00 00 00 00       	mov    $0x0,%esi
f01059d1:	eb 4b                	jmp    f0105a1e <readline+0x82>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01059d3:	83 ec 08             	sub    $0x8,%esp
f01059d6:	50                   	push   %eax
f01059d7:	68 a4 85 10 f0       	push   $0xf01085a4
f01059dc:	e8 f4 e2 ff ff       	call   f0103cd5 <cprintf>
			return NULL;
f01059e1:	83 c4 10             	add    $0x10,%esp
f01059e4:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f01059e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01059ec:	5b                   	pop    %ebx
f01059ed:	5e                   	pop    %esi
f01059ee:	5f                   	pop    %edi
f01059ef:	5d                   	pop    %ebp
f01059f0:	c3                   	ret    
			if (echoing)
f01059f1:	85 ff                	test   %edi,%edi
f01059f3:	75 05                	jne    f01059fa <readline+0x5e>
			i--;
f01059f5:	83 ee 01             	sub    $0x1,%esi
f01059f8:	eb 24                	jmp    f0105a1e <readline+0x82>
				cputchar('\b');
f01059fa:	83 ec 0c             	sub    $0xc,%esp
f01059fd:	6a 08                	push   $0x8
f01059ff:	e8 18 ae ff ff       	call   f010081c <cputchar>
f0105a04:	83 c4 10             	add    $0x10,%esp
f0105a07:	eb ec                	jmp    f01059f5 <readline+0x59>
				cputchar(c);
f0105a09:	83 ec 0c             	sub    $0xc,%esp
f0105a0c:	53                   	push   %ebx
f0105a0d:	e8 0a ae ff ff       	call   f010081c <cputchar>
f0105a12:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105a15:	88 9e 80 0a 25 f0    	mov    %bl,-0xfdaf580(%esi)
f0105a1b:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105a1e:	e8 09 ae ff ff       	call   f010082c <getchar>
f0105a23:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105a25:	85 c0                	test   %eax,%eax
f0105a27:	78 aa                	js     f01059d3 <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105a29:	83 f8 08             	cmp    $0x8,%eax
f0105a2c:	0f 94 c2             	sete   %dl
f0105a2f:	83 f8 7f             	cmp    $0x7f,%eax
f0105a32:	0f 94 c0             	sete   %al
f0105a35:	08 c2                	or     %al,%dl
f0105a37:	74 04                	je     f0105a3d <readline+0xa1>
f0105a39:	85 f6                	test   %esi,%esi
f0105a3b:	7f b4                	jg     f01059f1 <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105a3d:	83 fb 1f             	cmp    $0x1f,%ebx
f0105a40:	7e 0e                	jle    f0105a50 <readline+0xb4>
f0105a42:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105a48:	7f 06                	jg     f0105a50 <readline+0xb4>
			if (echoing)
f0105a4a:	85 ff                	test   %edi,%edi
f0105a4c:	74 c7                	je     f0105a15 <readline+0x79>
f0105a4e:	eb b9                	jmp    f0105a09 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f0105a50:	83 fb 0a             	cmp    $0xa,%ebx
f0105a53:	74 05                	je     f0105a5a <readline+0xbe>
f0105a55:	83 fb 0d             	cmp    $0xd,%ebx
f0105a58:	75 c4                	jne    f0105a1e <readline+0x82>
			if (echoing)
f0105a5a:	85 ff                	test   %edi,%edi
f0105a5c:	75 11                	jne    f0105a6f <readline+0xd3>
			buf[i] = 0;
f0105a5e:	c6 86 80 0a 25 f0 00 	movb   $0x0,-0xfdaf580(%esi)
			return buf;
f0105a65:	b8 80 0a 25 f0       	mov    $0xf0250a80,%eax
f0105a6a:	e9 7a ff ff ff       	jmp    f01059e9 <readline+0x4d>
				cputchar('\n');
f0105a6f:	83 ec 0c             	sub    $0xc,%esp
f0105a72:	6a 0a                	push   $0xa
f0105a74:	e8 a3 ad ff ff       	call   f010081c <cputchar>
f0105a79:	83 c4 10             	add    $0x10,%esp
f0105a7c:	eb e0                	jmp    f0105a5e <readline+0xc2>

f0105a7e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105a7e:	55                   	push   %ebp
f0105a7f:	89 e5                	mov    %esp,%ebp
f0105a81:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105a84:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a89:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105a8d:	74 05                	je     f0105a94 <strlen+0x16>
		n++;
f0105a8f:	83 c0 01             	add    $0x1,%eax
f0105a92:	eb f5                	jmp    f0105a89 <strlen+0xb>
	return n;
}
f0105a94:	5d                   	pop    %ebp
f0105a95:	c3                   	ret    

f0105a96 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105a96:	55                   	push   %ebp
f0105a97:	89 e5                	mov    %esp,%ebp
f0105a99:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105a9f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105aa4:	39 c2                	cmp    %eax,%edx
f0105aa6:	74 0d                	je     f0105ab5 <strnlen+0x1f>
f0105aa8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105aac:	74 05                	je     f0105ab3 <strnlen+0x1d>
		n++;
f0105aae:	83 c2 01             	add    $0x1,%edx
f0105ab1:	eb f1                	jmp    f0105aa4 <strnlen+0xe>
f0105ab3:	89 d0                	mov    %edx,%eax
	return n;
}
f0105ab5:	5d                   	pop    %ebp
f0105ab6:	c3                   	ret    

f0105ab7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105ab7:	55                   	push   %ebp
f0105ab8:	89 e5                	mov    %esp,%ebp
f0105aba:	53                   	push   %ebx
f0105abb:	8b 45 08             	mov    0x8(%ebp),%eax
f0105abe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105ac1:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ac6:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0105aca:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105acd:	83 c2 01             	add    $0x1,%edx
f0105ad0:	84 c9                	test   %cl,%cl
f0105ad2:	75 f2                	jne    f0105ac6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105ad4:	5b                   	pop    %ebx
f0105ad5:	5d                   	pop    %ebp
f0105ad6:	c3                   	ret    

f0105ad7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105ad7:	55                   	push   %ebp
f0105ad8:	89 e5                	mov    %esp,%ebp
f0105ada:	53                   	push   %ebx
f0105adb:	83 ec 10             	sub    $0x10,%esp
f0105ade:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105ae1:	53                   	push   %ebx
f0105ae2:	e8 97 ff ff ff       	call   f0105a7e <strlen>
f0105ae7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105aea:	ff 75 0c             	pushl  0xc(%ebp)
f0105aed:	01 d8                	add    %ebx,%eax
f0105aef:	50                   	push   %eax
f0105af0:	e8 c2 ff ff ff       	call   f0105ab7 <strcpy>
	return dst;
}
f0105af5:	89 d8                	mov    %ebx,%eax
f0105af7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105afa:	c9                   	leave  
f0105afb:	c3                   	ret    

f0105afc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105afc:	55                   	push   %ebp
f0105afd:	89 e5                	mov    %esp,%ebp
f0105aff:	56                   	push   %esi
f0105b00:	53                   	push   %ebx
f0105b01:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105b07:	89 c6                	mov    %eax,%esi
f0105b09:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105b0c:	89 c2                	mov    %eax,%edx
f0105b0e:	39 f2                	cmp    %esi,%edx
f0105b10:	74 11                	je     f0105b23 <strncpy+0x27>
		*dst++ = *src;
f0105b12:	83 c2 01             	add    $0x1,%edx
f0105b15:	0f b6 19             	movzbl (%ecx),%ebx
f0105b18:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105b1b:	80 fb 01             	cmp    $0x1,%bl
f0105b1e:	83 d9 ff             	sbb    $0xffffffff,%ecx
f0105b21:	eb eb                	jmp    f0105b0e <strncpy+0x12>
	}
	return ret;
}
f0105b23:	5b                   	pop    %ebx
f0105b24:	5e                   	pop    %esi
f0105b25:	5d                   	pop    %ebp
f0105b26:	c3                   	ret    

f0105b27 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105b27:	55                   	push   %ebp
f0105b28:	89 e5                	mov    %esp,%ebp
f0105b2a:	56                   	push   %esi
f0105b2b:	53                   	push   %ebx
f0105b2c:	8b 75 08             	mov    0x8(%ebp),%esi
f0105b2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105b32:	8b 55 10             	mov    0x10(%ebp),%edx
f0105b35:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105b37:	85 d2                	test   %edx,%edx
f0105b39:	74 21                	je     f0105b5c <strlcpy+0x35>
f0105b3b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105b3f:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0105b41:	39 c2                	cmp    %eax,%edx
f0105b43:	74 14                	je     f0105b59 <strlcpy+0x32>
f0105b45:	0f b6 19             	movzbl (%ecx),%ebx
f0105b48:	84 db                	test   %bl,%bl
f0105b4a:	74 0b                	je     f0105b57 <strlcpy+0x30>
			*dst++ = *src++;
f0105b4c:	83 c1 01             	add    $0x1,%ecx
f0105b4f:	83 c2 01             	add    $0x1,%edx
f0105b52:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105b55:	eb ea                	jmp    f0105b41 <strlcpy+0x1a>
f0105b57:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0105b59:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105b5c:	29 f0                	sub    %esi,%eax
}
f0105b5e:	5b                   	pop    %ebx
f0105b5f:	5e                   	pop    %esi
f0105b60:	5d                   	pop    %ebp
f0105b61:	c3                   	ret    

f0105b62 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105b62:	55                   	push   %ebp
f0105b63:	89 e5                	mov    %esp,%ebp
f0105b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105b68:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105b6b:	0f b6 01             	movzbl (%ecx),%eax
f0105b6e:	84 c0                	test   %al,%al
f0105b70:	74 0c                	je     f0105b7e <strcmp+0x1c>
f0105b72:	3a 02                	cmp    (%edx),%al
f0105b74:	75 08                	jne    f0105b7e <strcmp+0x1c>
		p++, q++;
f0105b76:	83 c1 01             	add    $0x1,%ecx
f0105b79:	83 c2 01             	add    $0x1,%edx
f0105b7c:	eb ed                	jmp    f0105b6b <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105b7e:	0f b6 c0             	movzbl %al,%eax
f0105b81:	0f b6 12             	movzbl (%edx),%edx
f0105b84:	29 d0                	sub    %edx,%eax
}
f0105b86:	5d                   	pop    %ebp
f0105b87:	c3                   	ret    

f0105b88 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105b88:	55                   	push   %ebp
f0105b89:	89 e5                	mov    %esp,%ebp
f0105b8b:	53                   	push   %ebx
f0105b8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b8f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b92:	89 c3                	mov    %eax,%ebx
f0105b94:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105b97:	eb 06                	jmp    f0105b9f <strncmp+0x17>
		n--, p++, q++;
f0105b99:	83 c0 01             	add    $0x1,%eax
f0105b9c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105b9f:	39 d8                	cmp    %ebx,%eax
f0105ba1:	74 16                	je     f0105bb9 <strncmp+0x31>
f0105ba3:	0f b6 08             	movzbl (%eax),%ecx
f0105ba6:	84 c9                	test   %cl,%cl
f0105ba8:	74 04                	je     f0105bae <strncmp+0x26>
f0105baa:	3a 0a                	cmp    (%edx),%cl
f0105bac:	74 eb                	je     f0105b99 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105bae:	0f b6 00             	movzbl (%eax),%eax
f0105bb1:	0f b6 12             	movzbl (%edx),%edx
f0105bb4:	29 d0                	sub    %edx,%eax
}
f0105bb6:	5b                   	pop    %ebx
f0105bb7:	5d                   	pop    %ebp
f0105bb8:	c3                   	ret    
		return 0;
f0105bb9:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bbe:	eb f6                	jmp    f0105bb6 <strncmp+0x2e>

f0105bc0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105bc0:	55                   	push   %ebp
f0105bc1:	89 e5                	mov    %esp,%ebp
f0105bc3:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bc6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105bca:	0f b6 10             	movzbl (%eax),%edx
f0105bcd:	84 d2                	test   %dl,%dl
f0105bcf:	74 09                	je     f0105bda <strchr+0x1a>
		if (*s == c)
f0105bd1:	38 ca                	cmp    %cl,%dl
f0105bd3:	74 0a                	je     f0105bdf <strchr+0x1f>
	for (; *s; s++)
f0105bd5:	83 c0 01             	add    $0x1,%eax
f0105bd8:	eb f0                	jmp    f0105bca <strchr+0xa>
			return (char *) s;
	return 0;
f0105bda:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105bdf:	5d                   	pop    %ebp
f0105be0:	c3                   	ret    

f0105be1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105be1:	55                   	push   %ebp
f0105be2:	89 e5                	mov    %esp,%ebp
f0105be4:	8b 45 08             	mov    0x8(%ebp),%eax
f0105be7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105beb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105bee:	38 ca                	cmp    %cl,%dl
f0105bf0:	74 09                	je     f0105bfb <strfind+0x1a>
f0105bf2:	84 d2                	test   %dl,%dl
f0105bf4:	74 05                	je     f0105bfb <strfind+0x1a>
	for (; *s; s++)
f0105bf6:	83 c0 01             	add    $0x1,%eax
f0105bf9:	eb f0                	jmp    f0105beb <strfind+0xa>
			break;
	return (char *) s;
}
f0105bfb:	5d                   	pop    %ebp
f0105bfc:	c3                   	ret    

f0105bfd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105bfd:	55                   	push   %ebp
f0105bfe:	89 e5                	mov    %esp,%ebp
f0105c00:	57                   	push   %edi
f0105c01:	56                   	push   %esi
f0105c02:	53                   	push   %ebx
f0105c03:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105c06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105c09:	85 c9                	test   %ecx,%ecx
f0105c0b:	74 31                	je     f0105c3e <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105c0d:	89 f8                	mov    %edi,%eax
f0105c0f:	09 c8                	or     %ecx,%eax
f0105c11:	a8 03                	test   $0x3,%al
f0105c13:	75 23                	jne    f0105c38 <memset+0x3b>
		c &= 0xFF;
f0105c15:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105c19:	89 d3                	mov    %edx,%ebx
f0105c1b:	c1 e3 08             	shl    $0x8,%ebx
f0105c1e:	89 d0                	mov    %edx,%eax
f0105c20:	c1 e0 18             	shl    $0x18,%eax
f0105c23:	89 d6                	mov    %edx,%esi
f0105c25:	c1 e6 10             	shl    $0x10,%esi
f0105c28:	09 f0                	or     %esi,%eax
f0105c2a:	09 c2                	or     %eax,%edx
f0105c2c:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105c2e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105c31:	89 d0                	mov    %edx,%eax
f0105c33:	fc                   	cld    
f0105c34:	f3 ab                	rep stos %eax,%es:(%edi)
f0105c36:	eb 06                	jmp    f0105c3e <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105c38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105c3b:	fc                   	cld    
f0105c3c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105c3e:	89 f8                	mov    %edi,%eax
f0105c40:	5b                   	pop    %ebx
f0105c41:	5e                   	pop    %esi
f0105c42:	5f                   	pop    %edi
f0105c43:	5d                   	pop    %ebp
f0105c44:	c3                   	ret    

f0105c45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105c45:	55                   	push   %ebp
f0105c46:	89 e5                	mov    %esp,%ebp
f0105c48:	57                   	push   %edi
f0105c49:	56                   	push   %esi
f0105c4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c4d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105c50:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105c53:	39 c6                	cmp    %eax,%esi
f0105c55:	73 32                	jae    f0105c89 <memmove+0x44>
f0105c57:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105c5a:	39 c2                	cmp    %eax,%edx
f0105c5c:	76 2b                	jbe    f0105c89 <memmove+0x44>
		s += n;
		d += n;
f0105c5e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105c61:	89 fe                	mov    %edi,%esi
f0105c63:	09 ce                	or     %ecx,%esi
f0105c65:	09 d6                	or     %edx,%esi
f0105c67:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105c6d:	75 0e                	jne    f0105c7d <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105c6f:	83 ef 04             	sub    $0x4,%edi
f0105c72:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105c75:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105c78:	fd                   	std    
f0105c79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105c7b:	eb 09                	jmp    f0105c86 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105c7d:	83 ef 01             	sub    $0x1,%edi
f0105c80:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105c83:	fd                   	std    
f0105c84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105c86:	fc                   	cld    
f0105c87:	eb 1a                	jmp    f0105ca3 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105c89:	89 c2                	mov    %eax,%edx
f0105c8b:	09 ca                	or     %ecx,%edx
f0105c8d:	09 f2                	or     %esi,%edx
f0105c8f:	f6 c2 03             	test   $0x3,%dl
f0105c92:	75 0a                	jne    f0105c9e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105c94:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105c97:	89 c7                	mov    %eax,%edi
f0105c99:	fc                   	cld    
f0105c9a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105c9c:	eb 05                	jmp    f0105ca3 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
f0105c9e:	89 c7                	mov    %eax,%edi
f0105ca0:	fc                   	cld    
f0105ca1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105ca3:	5e                   	pop    %esi
f0105ca4:	5f                   	pop    %edi
f0105ca5:	5d                   	pop    %ebp
f0105ca6:	c3                   	ret    

f0105ca7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105ca7:	55                   	push   %ebp
f0105ca8:	89 e5                	mov    %esp,%ebp
f0105caa:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105cad:	ff 75 10             	pushl  0x10(%ebp)
f0105cb0:	ff 75 0c             	pushl  0xc(%ebp)
f0105cb3:	ff 75 08             	pushl  0x8(%ebp)
f0105cb6:	e8 8a ff ff ff       	call   f0105c45 <memmove>
}
f0105cbb:	c9                   	leave  
f0105cbc:	c3                   	ret    

f0105cbd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105cbd:	55                   	push   %ebp
f0105cbe:	89 e5                	mov    %esp,%ebp
f0105cc0:	56                   	push   %esi
f0105cc1:	53                   	push   %ebx
f0105cc2:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cc5:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105cc8:	89 c6                	mov    %eax,%esi
f0105cca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ccd:	39 f0                	cmp    %esi,%eax
f0105ccf:	74 1c                	je     f0105ced <memcmp+0x30>
		if (*s1 != *s2)
f0105cd1:	0f b6 08             	movzbl (%eax),%ecx
f0105cd4:	0f b6 1a             	movzbl (%edx),%ebx
f0105cd7:	38 d9                	cmp    %bl,%cl
f0105cd9:	75 08                	jne    f0105ce3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105cdb:	83 c0 01             	add    $0x1,%eax
f0105cde:	83 c2 01             	add    $0x1,%edx
f0105ce1:	eb ea                	jmp    f0105ccd <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0105ce3:	0f b6 c1             	movzbl %cl,%eax
f0105ce6:	0f b6 db             	movzbl %bl,%ebx
f0105ce9:	29 d8                	sub    %ebx,%eax
f0105ceb:	eb 05                	jmp    f0105cf2 <memcmp+0x35>
	}

	return 0;
f0105ced:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105cf2:	5b                   	pop    %ebx
f0105cf3:	5e                   	pop    %esi
f0105cf4:	5d                   	pop    %ebp
f0105cf5:	c3                   	ret    

f0105cf6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105cf6:	55                   	push   %ebp
f0105cf7:	89 e5                	mov    %esp,%ebp
f0105cf9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105cff:	89 c2                	mov    %eax,%edx
f0105d01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105d04:	39 d0                	cmp    %edx,%eax
f0105d06:	73 09                	jae    f0105d11 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105d08:	38 08                	cmp    %cl,(%eax)
f0105d0a:	74 05                	je     f0105d11 <memfind+0x1b>
	for (; s < ends; s++)
f0105d0c:	83 c0 01             	add    $0x1,%eax
f0105d0f:	eb f3                	jmp    f0105d04 <memfind+0xe>
			break;
	return (void *) s;
}
f0105d11:	5d                   	pop    %ebp
f0105d12:	c3                   	ret    

f0105d13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105d13:	55                   	push   %ebp
f0105d14:	89 e5                	mov    %esp,%ebp
f0105d16:	57                   	push   %edi
f0105d17:	56                   	push   %esi
f0105d18:	53                   	push   %ebx
f0105d19:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105d1f:	eb 03                	jmp    f0105d24 <strtol+0x11>
		s++;
f0105d21:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105d24:	0f b6 01             	movzbl (%ecx),%eax
f0105d27:	3c 20                	cmp    $0x20,%al
f0105d29:	74 f6                	je     f0105d21 <strtol+0xe>
f0105d2b:	3c 09                	cmp    $0x9,%al
f0105d2d:	74 f2                	je     f0105d21 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0105d2f:	3c 2b                	cmp    $0x2b,%al
f0105d31:	74 2a                	je     f0105d5d <strtol+0x4a>
	int neg = 0;
f0105d33:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105d38:	3c 2d                	cmp    $0x2d,%al
f0105d3a:	74 2b                	je     f0105d67 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105d3c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105d42:	75 0f                	jne    f0105d53 <strtol+0x40>
f0105d44:	80 39 30             	cmpb   $0x30,(%ecx)
f0105d47:	74 28                	je     f0105d71 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105d49:	85 db                	test   %ebx,%ebx
f0105d4b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105d50:	0f 44 d8             	cmove  %eax,%ebx
f0105d53:	b8 00 00 00 00       	mov    $0x0,%eax
f0105d58:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105d5b:	eb 50                	jmp    f0105dad <strtol+0x9a>
		s++;
f0105d5d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105d60:	bf 00 00 00 00       	mov    $0x0,%edi
f0105d65:	eb d5                	jmp    f0105d3c <strtol+0x29>
		s++, neg = 1;
f0105d67:	83 c1 01             	add    $0x1,%ecx
f0105d6a:	bf 01 00 00 00       	mov    $0x1,%edi
f0105d6f:	eb cb                	jmp    f0105d3c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105d71:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105d75:	74 0e                	je     f0105d85 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
f0105d77:	85 db                	test   %ebx,%ebx
f0105d79:	75 d8                	jne    f0105d53 <strtol+0x40>
		s++, base = 8;
f0105d7b:	83 c1 01             	add    $0x1,%ecx
f0105d7e:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105d83:	eb ce                	jmp    f0105d53 <strtol+0x40>
		s += 2, base = 16;
f0105d85:	83 c1 02             	add    $0x2,%ecx
f0105d88:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105d8d:	eb c4                	jmp    f0105d53 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0105d8f:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105d92:	89 f3                	mov    %esi,%ebx
f0105d94:	80 fb 19             	cmp    $0x19,%bl
f0105d97:	77 29                	ja     f0105dc2 <strtol+0xaf>
			dig = *s - 'a' + 10;
f0105d99:	0f be d2             	movsbl %dl,%edx
f0105d9c:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105d9f:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105da2:	7d 30                	jge    f0105dd4 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
f0105da4:	83 c1 01             	add    $0x1,%ecx
f0105da7:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105dab:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105dad:	0f b6 11             	movzbl (%ecx),%edx
f0105db0:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105db3:	89 f3                	mov    %esi,%ebx
f0105db5:	80 fb 09             	cmp    $0x9,%bl
f0105db8:	77 d5                	ja     f0105d8f <strtol+0x7c>
			dig = *s - '0';
f0105dba:	0f be d2             	movsbl %dl,%edx
f0105dbd:	83 ea 30             	sub    $0x30,%edx
f0105dc0:	eb dd                	jmp    f0105d9f <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
f0105dc2:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105dc5:	89 f3                	mov    %esi,%ebx
f0105dc7:	80 fb 19             	cmp    $0x19,%bl
f0105dca:	77 08                	ja     f0105dd4 <strtol+0xc1>
			dig = *s - 'A' + 10;
f0105dcc:	0f be d2             	movsbl %dl,%edx
f0105dcf:	83 ea 37             	sub    $0x37,%edx
f0105dd2:	eb cb                	jmp    f0105d9f <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105dd4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105dd8:	74 05                	je     f0105ddf <strtol+0xcc>
		*endptr = (char *) s;
f0105dda:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105ddd:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105ddf:	89 c2                	mov    %eax,%edx
f0105de1:	f7 da                	neg    %edx
f0105de3:	85 ff                	test   %edi,%edi
f0105de5:	0f 45 c2             	cmovne %edx,%eax
}
f0105de8:	5b                   	pop    %ebx
f0105de9:	5e                   	pop    %esi
f0105dea:	5f                   	pop    %edi
f0105deb:	5d                   	pop    %ebp
f0105dec:	c3                   	ret    
f0105ded:	66 90                	xchg   %ax,%ax
f0105def:	90                   	nop

f0105df0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105df0:	fa                   	cli    

	xorw    %ax, %ax
f0105df1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105df3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105df5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105df7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105df9:	0f 01 16             	lgdtl  (%esi)
f0105dfc:	74 70                	je     f0105e6e <mpsearch1+0x3>
	movl    %cr0, %eax
f0105dfe:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105e01:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105e05:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105e08:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105e0e:	08 00                	or     %al,(%eax)

f0105e10 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105e10:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105e14:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105e16:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105e18:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105e1a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105e1e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105e20:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105e22:	b8 00 20 12 00       	mov    $0x122000,%eax
	movl    %eax, %cr3
f0105e27:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105e2a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105e2d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105e32:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105e35:	8b 25 84 0e 25 f0    	mov    0xf0250e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105e3b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105e40:	b8 6f 02 10 f0       	mov    $0xf010026f,%eax
	call    *%eax
f0105e45:	ff d0                	call   *%eax

f0105e47 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105e47:	eb fe                	jmp    f0105e47 <spin>
f0105e49:	8d 76 00             	lea    0x0(%esi),%esi

f0105e4c <gdt>:
	...
f0105e54:	ff                   	(bad)  
f0105e55:	ff 00                	incl   (%eax)
f0105e57:	00 00                	add    %al,(%eax)
f0105e59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105e60:	00                   	.byte 0x0
f0105e61:	92                   	xchg   %eax,%edx
f0105e62:	cf                   	iret   
	...

f0105e64 <gdtdesc>:
f0105e64:	17                   	pop    %ss
f0105e65:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105e6a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105e6a:	90                   	nop

f0105e6b <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105e6b:	55                   	push   %ebp
f0105e6c:	89 e5                	mov    %esp,%ebp
f0105e6e:	57                   	push   %edi
f0105e6f:	56                   	push   %esi
f0105e70:	53                   	push   %ebx
f0105e71:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f0105e74:	8b 0d 88 0e 25 f0    	mov    0xf0250e88,%ecx
f0105e7a:	89 c3                	mov    %eax,%ebx
f0105e7c:	c1 eb 0c             	shr    $0xc,%ebx
f0105e7f:	39 cb                	cmp    %ecx,%ebx
f0105e81:	73 1a                	jae    f0105e9d <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0105e83:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105e89:	8d 3c 02             	lea    (%edx,%eax,1),%edi
	if (PGNUM(pa) >= npages)
f0105e8c:	89 f8                	mov    %edi,%eax
f0105e8e:	c1 e8 0c             	shr    $0xc,%eax
f0105e91:	39 c8                	cmp    %ecx,%eax
f0105e93:	73 1a                	jae    f0105eaf <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0105e95:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f0105e9b:	eb 27                	jmp    f0105ec4 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e9d:	50                   	push   %eax
f0105e9e:	68 d4 68 10 f0       	push   $0xf01068d4
f0105ea3:	6a 57                	push   $0x57
f0105ea5:	68 41 87 10 f0       	push   $0xf0108741
f0105eaa:	e8 91 a1 ff ff       	call   f0100040 <_panic>
f0105eaf:	57                   	push   %edi
f0105eb0:	68 d4 68 10 f0       	push   $0xf01068d4
f0105eb5:	6a 57                	push   $0x57
f0105eb7:	68 41 87 10 f0       	push   $0xf0108741
f0105ebc:	e8 7f a1 ff ff       	call   f0100040 <_panic>
f0105ec1:	83 c3 10             	add    $0x10,%ebx
f0105ec4:	39 fb                	cmp    %edi,%ebx
f0105ec6:	73 30                	jae    f0105ef8 <mpsearch1+0x8d>
f0105ec8:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105eca:	83 ec 04             	sub    $0x4,%esp
f0105ecd:	6a 04                	push   $0x4
f0105ecf:	68 51 87 10 f0       	push   $0xf0108751
f0105ed4:	53                   	push   %ebx
f0105ed5:	e8 e3 fd ff ff       	call   f0105cbd <memcmp>
f0105eda:	83 c4 10             	add    $0x10,%esp
f0105edd:	85 c0                	test   %eax,%eax
f0105edf:	75 e0                	jne    f0105ec1 <mpsearch1+0x56>
f0105ee1:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f0105ee3:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f0105ee6:	0f b6 0a             	movzbl (%edx),%ecx
f0105ee9:	01 c8                	add    %ecx,%eax
f0105eeb:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0105eee:	39 f2                	cmp    %esi,%edx
f0105ef0:	75 f4                	jne    f0105ee6 <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ef2:	84 c0                	test   %al,%al
f0105ef4:	75 cb                	jne    f0105ec1 <mpsearch1+0x56>
f0105ef6:	eb 05                	jmp    f0105efd <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105ef8:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105efd:	89 d8                	mov    %ebx,%eax
f0105eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105f02:	5b                   	pop    %ebx
f0105f03:	5e                   	pop    %esi
f0105f04:	5f                   	pop    %edi
f0105f05:	5d                   	pop    %ebp
f0105f06:	c3                   	ret    

f0105f07 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105f07:	55                   	push   %ebp
f0105f08:	89 e5                	mov    %esp,%ebp
f0105f0a:	57                   	push   %edi
f0105f0b:	56                   	push   %esi
f0105f0c:	53                   	push   %ebx
f0105f0d:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105f10:	c7 05 c0 13 25 f0 20 	movl   $0xf0251020,0xf02513c0
f0105f17:	10 25 f0 
	if (PGNUM(pa) >= npages)
f0105f1a:	83 3d 88 0e 25 f0 00 	cmpl   $0x0,0xf0250e88
f0105f21:	0f 84 a3 00 00 00    	je     f0105fca <mp_init+0xc3>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105f27:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105f2e:	85 c0                	test   %eax,%eax
f0105f30:	0f 84 aa 00 00 00    	je     f0105fe0 <mp_init+0xd9>
		p <<= 4;	// Translate from segment to PA
f0105f36:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105f39:	ba 00 04 00 00       	mov    $0x400,%edx
f0105f3e:	e8 28 ff ff ff       	call   f0105e6b <mpsearch1>
f0105f43:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105f46:	85 c0                	test   %eax,%eax
f0105f48:	75 1a                	jne    f0105f64 <mp_init+0x5d>
	return mpsearch1(0xF0000, 0x10000);
f0105f4a:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105f4f:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105f54:	e8 12 ff ff ff       	call   f0105e6b <mpsearch1>
f0105f59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0105f5c:	85 c0                	test   %eax,%eax
f0105f5e:	0f 84 31 02 00 00    	je     f0106195 <mp_init+0x28e>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105f64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105f67:	8b 58 04             	mov    0x4(%eax),%ebx
f0105f6a:	85 db                	test   %ebx,%ebx
f0105f6c:	0f 84 97 00 00 00    	je     f0106009 <mp_init+0x102>
f0105f72:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105f76:	0f 85 8d 00 00 00    	jne    f0106009 <mp_init+0x102>
f0105f7c:	89 d8                	mov    %ebx,%eax
f0105f7e:	c1 e8 0c             	shr    $0xc,%eax
f0105f81:	3b 05 88 0e 25 f0    	cmp    0xf0250e88,%eax
f0105f87:	0f 83 91 00 00 00    	jae    f010601e <mp_init+0x117>
	return (void *)(pa + KERNBASE);
f0105f8d:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0105f93:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105f95:	83 ec 04             	sub    $0x4,%esp
f0105f98:	6a 04                	push   $0x4
f0105f9a:	68 56 87 10 f0       	push   $0xf0108756
f0105f9f:	53                   	push   %ebx
f0105fa0:	e8 18 fd ff ff       	call   f0105cbd <memcmp>
f0105fa5:	83 c4 10             	add    $0x10,%esp
f0105fa8:	85 c0                	test   %eax,%eax
f0105faa:	0f 85 83 00 00 00    	jne    f0106033 <mp_init+0x12c>
f0105fb0:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105fb4:	01 df                	add    %ebx,%edi
	sum = 0;
f0105fb6:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0105fb8:	39 fb                	cmp    %edi,%ebx
f0105fba:	0f 84 88 00 00 00    	je     f0106048 <mp_init+0x141>
		sum += ((uint8_t *)addr)[i];
f0105fc0:	0f b6 0b             	movzbl (%ebx),%ecx
f0105fc3:	01 ca                	add    %ecx,%edx
f0105fc5:	83 c3 01             	add    $0x1,%ebx
f0105fc8:	eb ee                	jmp    f0105fb8 <mp_init+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fca:	68 00 04 00 00       	push   $0x400
f0105fcf:	68 d4 68 10 f0       	push   $0xf01068d4
f0105fd4:	6a 6f                	push   $0x6f
f0105fd6:	68 41 87 10 f0       	push   $0xf0108741
f0105fdb:	e8 60 a0 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105fe0:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105fe7:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105fea:	2d 00 04 00 00       	sub    $0x400,%eax
f0105fef:	ba 00 04 00 00       	mov    $0x400,%edx
f0105ff4:	e8 72 fe ff ff       	call   f0105e6b <mpsearch1>
f0105ff9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ffc:	85 c0                	test   %eax,%eax
f0105ffe:	0f 85 60 ff ff ff    	jne    f0105f64 <mp_init+0x5d>
f0106004:	e9 41 ff ff ff       	jmp    f0105f4a <mp_init+0x43>
		cprintf("SMP: Default configurations not implemented\n");
f0106009:	83 ec 0c             	sub    $0xc,%esp
f010600c:	68 b4 85 10 f0       	push   $0xf01085b4
f0106011:	e8 bf dc ff ff       	call   f0103cd5 <cprintf>
f0106016:	83 c4 10             	add    $0x10,%esp
f0106019:	e9 77 01 00 00       	jmp    f0106195 <mp_init+0x28e>
f010601e:	53                   	push   %ebx
f010601f:	68 d4 68 10 f0       	push   $0xf01068d4
f0106024:	68 90 00 00 00       	push   $0x90
f0106029:	68 41 87 10 f0       	push   $0xf0108741
f010602e:	e8 0d a0 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106033:	83 ec 0c             	sub    $0xc,%esp
f0106036:	68 e4 85 10 f0       	push   $0xf01085e4
f010603b:	e8 95 dc ff ff       	call   f0103cd5 <cprintf>
f0106040:	83 c4 10             	add    $0x10,%esp
f0106043:	e9 4d 01 00 00       	jmp    f0106195 <mp_init+0x28e>
	if (sum(conf, conf->length) != 0) {
f0106048:	84 d2                	test   %dl,%dl
f010604a:	75 16                	jne    f0106062 <mp_init+0x15b>
	if (conf->version != 1 && conf->version != 4) {
f010604c:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0106050:	80 fa 01             	cmp    $0x1,%dl
f0106053:	74 05                	je     f010605a <mp_init+0x153>
f0106055:	80 fa 04             	cmp    $0x4,%dl
f0106058:	75 1d                	jne    f0106077 <mp_init+0x170>
f010605a:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f010605e:	01 d9                	add    %ebx,%ecx
f0106060:	eb 36                	jmp    f0106098 <mp_init+0x191>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106062:	83 ec 0c             	sub    $0xc,%esp
f0106065:	68 18 86 10 f0       	push   $0xf0108618
f010606a:	e8 66 dc ff ff       	call   f0103cd5 <cprintf>
f010606f:	83 c4 10             	add    $0x10,%esp
f0106072:	e9 1e 01 00 00       	jmp    f0106195 <mp_init+0x28e>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106077:	83 ec 08             	sub    $0x8,%esp
f010607a:	0f b6 d2             	movzbl %dl,%edx
f010607d:	52                   	push   %edx
f010607e:	68 3c 86 10 f0       	push   $0xf010863c
f0106083:	e8 4d dc ff ff       	call   f0103cd5 <cprintf>
f0106088:	83 c4 10             	add    $0x10,%esp
f010608b:	e9 05 01 00 00       	jmp    f0106195 <mp_init+0x28e>
		sum += ((uint8_t *)addr)[i];
f0106090:	0f b6 13             	movzbl (%ebx),%edx
f0106093:	01 d0                	add    %edx,%eax
f0106095:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0106098:	39 d9                	cmp    %ebx,%ecx
f010609a:	75 f4                	jne    f0106090 <mp_init+0x189>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010609c:	02 46 2a             	add    0x2a(%esi),%al
f010609f:	75 1c                	jne    f01060bd <mp_init+0x1b6>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f01060a1:	c7 05 00 10 25 f0 01 	movl   $0x1,0xf0251000
f01060a8:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01060ab:	8b 46 24             	mov    0x24(%esi),%eax
f01060ae:	a3 00 20 29 f0       	mov    %eax,0xf0292000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01060b3:	8d 7e 2c             	lea    0x2c(%esi),%edi
f01060b6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01060bb:	eb 4d                	jmp    f010610a <mp_init+0x203>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01060bd:	83 ec 0c             	sub    $0xc,%esp
f01060c0:	68 5c 86 10 f0       	push   $0xf010865c
f01060c5:	e8 0b dc ff ff       	call   f0103cd5 <cprintf>
f01060ca:	83 c4 10             	add    $0x10,%esp
f01060cd:	e9 c3 00 00 00       	jmp    f0106195 <mp_init+0x28e>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01060d2:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f01060d6:	74 11                	je     f01060e9 <mp_init+0x1e2>
				bootcpu = &cpus[ncpu];
f01060d8:	6b 05 c4 13 25 f0 74 	imul   $0x74,0xf02513c4,%eax
f01060df:	05 20 10 25 f0       	add    $0xf0251020,%eax
f01060e4:	a3 c0 13 25 f0       	mov    %eax,0xf02513c0
			if (ncpu < NCPU) {
f01060e9:	a1 c4 13 25 f0       	mov    0xf02513c4,%eax
f01060ee:	83 f8 07             	cmp    $0x7,%eax
f01060f1:	7f 2f                	jg     f0106122 <mp_init+0x21b>
				cpus[ncpu].cpu_id = ncpu;
f01060f3:	6b d0 74             	imul   $0x74,%eax,%edx
f01060f6:	88 82 20 10 25 f0    	mov    %al,-0xfdaefe0(%edx)
				ncpu++;
f01060fc:	83 c0 01             	add    $0x1,%eax
f01060ff:	a3 c4 13 25 f0       	mov    %eax,0xf02513c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106104:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106107:	83 c3 01             	add    $0x1,%ebx
f010610a:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f010610e:	39 d8                	cmp    %ebx,%eax
f0106110:	76 4b                	jbe    f010615d <mp_init+0x256>
		switch (*p) {
f0106112:	0f b6 07             	movzbl (%edi),%eax
f0106115:	84 c0                	test   %al,%al
f0106117:	74 b9                	je     f01060d2 <mp_init+0x1cb>
f0106119:	3c 04                	cmp    $0x4,%al
f010611b:	77 1c                	ja     f0106139 <mp_init+0x232>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f010611d:	83 c7 08             	add    $0x8,%edi
			continue;
f0106120:	eb e5                	jmp    f0106107 <mp_init+0x200>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106122:	83 ec 08             	sub    $0x8,%esp
f0106125:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106129:	50                   	push   %eax
f010612a:	68 8c 86 10 f0       	push   $0xf010868c
f010612f:	e8 a1 db ff ff       	call   f0103cd5 <cprintf>
f0106134:	83 c4 10             	add    $0x10,%esp
f0106137:	eb cb                	jmp    f0106104 <mp_init+0x1fd>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106139:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f010613c:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f010613f:	50                   	push   %eax
f0106140:	68 b4 86 10 f0       	push   $0xf01086b4
f0106145:	e8 8b db ff ff       	call   f0103cd5 <cprintf>
			ismp = 0;
f010614a:	c7 05 00 10 25 f0 00 	movl   $0x0,0xf0251000
f0106151:	00 00 00 
			i = conf->entry;
f0106154:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0106158:	83 c4 10             	add    $0x10,%esp
f010615b:	eb aa                	jmp    f0106107 <mp_init+0x200>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010615d:	a1 c0 13 25 f0       	mov    0xf02513c0,%eax
f0106162:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106169:	83 3d 00 10 25 f0 00 	cmpl   $0x0,0xf0251000
f0106170:	74 2b                	je     f010619d <mp_init+0x296>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106172:	83 ec 04             	sub    $0x4,%esp
f0106175:	ff 35 c4 13 25 f0    	pushl  0xf02513c4
f010617b:	0f b6 00             	movzbl (%eax),%eax
f010617e:	50                   	push   %eax
f010617f:	68 5b 87 10 f0       	push   $0xf010875b
f0106184:	e8 4c db ff ff       	call   f0103cd5 <cprintf>

	if (mp->imcrp) {
f0106189:	83 c4 10             	add    $0x10,%esp
f010618c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010618f:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106193:	75 2e                	jne    f01061c3 <mp_init+0x2bc>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0106195:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106198:	5b                   	pop    %ebx
f0106199:	5e                   	pop    %esi
f010619a:	5f                   	pop    %edi
f010619b:	5d                   	pop    %ebp
f010619c:	c3                   	ret    
		ncpu = 1;
f010619d:	c7 05 c4 13 25 f0 01 	movl   $0x1,0xf02513c4
f01061a4:	00 00 00 
		lapicaddr = 0;
f01061a7:	c7 05 00 20 29 f0 00 	movl   $0x0,0xf0292000
f01061ae:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01061b1:	83 ec 0c             	sub    $0xc,%esp
f01061b4:	68 d4 86 10 f0       	push   $0xf01086d4
f01061b9:	e8 17 db ff ff       	call   f0103cd5 <cprintf>
		return;
f01061be:	83 c4 10             	add    $0x10,%esp
f01061c1:	eb d2                	jmp    f0106195 <mp_init+0x28e>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01061c3:	83 ec 0c             	sub    $0xc,%esp
f01061c6:	68 00 87 10 f0       	push   $0xf0108700
f01061cb:	e8 05 db ff ff       	call   f0103cd5 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01061d0:	b8 70 00 00 00       	mov    $0x70,%eax
f01061d5:	ba 22 00 00 00       	mov    $0x22,%edx
f01061da:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01061db:	ba 23 00 00 00       	mov    $0x23,%edx
f01061e0:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01061e1:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01061e4:	ee                   	out    %al,(%dx)
f01061e5:	83 c4 10             	add    $0x10,%esp
f01061e8:	eb ab                	jmp    f0106195 <mp_init+0x28e>

f01061ea <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f01061ea:	8b 0d 04 20 29 f0    	mov    0xf0292004,%ecx
f01061f0:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01061f3:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01061f5:	a1 04 20 29 f0       	mov    0xf0292004,%eax
f01061fa:	8b 40 20             	mov    0x20(%eax),%eax
}
f01061fd:	c3                   	ret    

f01061fe <cpunum>:
}

int
cpunum(void)
{
	if (lapic)
f01061fe:	8b 15 04 20 29 f0    	mov    0xf0292004,%edx
		return lapic[ID] >> 24;
	return 0;
f0106204:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0106209:	85 d2                	test   %edx,%edx
f010620b:	74 06                	je     f0106213 <cpunum+0x15>
		return lapic[ID] >> 24;
f010620d:	8b 42 20             	mov    0x20(%edx),%eax
f0106210:	c1 e8 18             	shr    $0x18,%eax
}
f0106213:	c3                   	ret    

f0106214 <lapic_init>:
	if (!lapicaddr)
f0106214:	a1 00 20 29 f0       	mov    0xf0292000,%eax
f0106219:	85 c0                	test   %eax,%eax
f010621b:	75 01                	jne    f010621e <lapic_init+0xa>
f010621d:	c3                   	ret    
{
f010621e:	55                   	push   %ebp
f010621f:	89 e5                	mov    %esp,%ebp
f0106221:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0106224:	68 00 10 00 00       	push   $0x1000
f0106229:	50                   	push   %eax
f010622a:	e8 ca b3 ff ff       	call   f01015f9 <mmio_map_region>
f010622f:	a3 04 20 29 f0       	mov    %eax,0xf0292004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106234:	ba 27 01 00 00       	mov    $0x127,%edx
f0106239:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010623e:	e8 a7 ff ff ff       	call   f01061ea <lapicw>
	lapicw(TDCR, X1);
f0106243:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106248:	b8 f8 00 00 00       	mov    $0xf8,%eax
f010624d:	e8 98 ff ff ff       	call   f01061ea <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106252:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106257:	b8 c8 00 00 00       	mov    $0xc8,%eax
f010625c:	e8 89 ff ff ff       	call   f01061ea <lapicw>
	lapicw(TICR, 10000000); 
f0106261:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106266:	b8 e0 00 00 00       	mov    $0xe0,%eax
f010626b:	e8 7a ff ff ff       	call   f01061ea <lapicw>
	if (thiscpu != bootcpu)
f0106270:	e8 89 ff ff ff       	call   f01061fe <cpunum>
f0106275:	6b c0 74             	imul   $0x74,%eax,%eax
f0106278:	05 20 10 25 f0       	add    $0xf0251020,%eax
f010627d:	83 c4 10             	add    $0x10,%esp
f0106280:	39 05 c0 13 25 f0    	cmp    %eax,0xf02513c0
f0106286:	74 0f                	je     f0106297 <lapic_init+0x83>
		lapicw(LINT0, MASKED);
f0106288:	ba 00 00 01 00       	mov    $0x10000,%edx
f010628d:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106292:	e8 53 ff ff ff       	call   f01061ea <lapicw>
	lapicw(LINT1, MASKED);
f0106297:	ba 00 00 01 00       	mov    $0x10000,%edx
f010629c:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01062a1:	e8 44 ff ff ff       	call   f01061ea <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01062a6:	a1 04 20 29 f0       	mov    0xf0292004,%eax
f01062ab:	8b 40 30             	mov    0x30(%eax),%eax
f01062ae:	c1 e8 10             	shr    $0x10,%eax
f01062b1:	a8 fc                	test   $0xfc,%al
f01062b3:	75 7c                	jne    f0106331 <lapic_init+0x11d>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01062b5:	ba 33 00 00 00       	mov    $0x33,%edx
f01062ba:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01062bf:	e8 26 ff ff ff       	call   f01061ea <lapicw>
	lapicw(ESR, 0);
f01062c4:	ba 00 00 00 00       	mov    $0x0,%edx
f01062c9:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01062ce:	e8 17 ff ff ff       	call   f01061ea <lapicw>
	lapicw(ESR, 0);
f01062d3:	ba 00 00 00 00       	mov    $0x0,%edx
f01062d8:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01062dd:	e8 08 ff ff ff       	call   f01061ea <lapicw>
	lapicw(EOI, 0);
f01062e2:	ba 00 00 00 00       	mov    $0x0,%edx
f01062e7:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01062ec:	e8 f9 fe ff ff       	call   f01061ea <lapicw>
	lapicw(ICRHI, 0);
f01062f1:	ba 00 00 00 00       	mov    $0x0,%edx
f01062f6:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01062fb:	e8 ea fe ff ff       	call   f01061ea <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106300:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106305:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010630a:	e8 db fe ff ff       	call   f01061ea <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010630f:	8b 15 04 20 29 f0    	mov    0xf0292004,%edx
f0106315:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010631b:	f6 c4 10             	test   $0x10,%ah
f010631e:	75 f5                	jne    f0106315 <lapic_init+0x101>
	lapicw(TPR, 0);
f0106320:	ba 00 00 00 00       	mov    $0x0,%edx
f0106325:	b8 20 00 00 00       	mov    $0x20,%eax
f010632a:	e8 bb fe ff ff       	call   f01061ea <lapicw>
}
f010632f:	c9                   	leave  
f0106330:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0106331:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106336:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010633b:	e8 aa fe ff ff       	call   f01061ea <lapicw>
f0106340:	e9 70 ff ff ff       	jmp    f01062b5 <lapic_init+0xa1>

f0106345 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0106345:	83 3d 04 20 29 f0 00 	cmpl   $0x0,0xf0292004
f010634c:	74 17                	je     f0106365 <lapic_eoi+0x20>
{
f010634e:	55                   	push   %ebp
f010634f:	89 e5                	mov    %esp,%ebp
f0106351:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f0106354:	ba 00 00 00 00       	mov    $0x0,%edx
f0106359:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010635e:	e8 87 fe ff ff       	call   f01061ea <lapicw>
}
f0106363:	c9                   	leave  
f0106364:	c3                   	ret    
f0106365:	c3                   	ret    

f0106366 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0106366:	55                   	push   %ebp
f0106367:	89 e5                	mov    %esp,%ebp
f0106369:	56                   	push   %esi
f010636a:	53                   	push   %ebx
f010636b:	8b 75 08             	mov    0x8(%ebp),%esi
f010636e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106371:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106376:	ba 70 00 00 00       	mov    $0x70,%edx
f010637b:	ee                   	out    %al,(%dx)
f010637c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106381:	ba 71 00 00 00       	mov    $0x71,%edx
f0106386:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0106387:	83 3d 88 0e 25 f0 00 	cmpl   $0x0,0xf0250e88
f010638e:	74 7e                	je     f010640e <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106390:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106397:	00 00 
	wrv[1] = addr >> 4;
f0106399:	89 d8                	mov    %ebx,%eax
f010639b:	c1 e8 04             	shr    $0x4,%eax
f010639e:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01063a4:	c1 e6 18             	shl    $0x18,%esi
f01063a7:	89 f2                	mov    %esi,%edx
f01063a9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01063ae:	e8 37 fe ff ff       	call   f01061ea <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01063b3:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01063b8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01063bd:	e8 28 fe ff ff       	call   f01061ea <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01063c2:	ba 00 85 00 00       	mov    $0x8500,%edx
f01063c7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01063cc:	e8 19 fe ff ff       	call   f01061ea <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01063d1:	c1 eb 0c             	shr    $0xc,%ebx
f01063d4:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f01063d7:	89 f2                	mov    %esi,%edx
f01063d9:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01063de:	e8 07 fe ff ff       	call   f01061ea <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01063e3:	89 da                	mov    %ebx,%edx
f01063e5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01063ea:	e8 fb fd ff ff       	call   f01061ea <lapicw>
		lapicw(ICRHI, apicid << 24);
f01063ef:	89 f2                	mov    %esi,%edx
f01063f1:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01063f6:	e8 ef fd ff ff       	call   f01061ea <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01063fb:	89 da                	mov    %ebx,%edx
f01063fd:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106402:	e8 e3 fd ff ff       	call   f01061ea <lapicw>
		microdelay(200);
	}
}
f0106407:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010640a:	5b                   	pop    %ebx
f010640b:	5e                   	pop    %esi
f010640c:	5d                   	pop    %ebp
f010640d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010640e:	68 67 04 00 00       	push   $0x467
f0106413:	68 d4 68 10 f0       	push   $0xf01068d4
f0106418:	68 98 00 00 00       	push   $0x98
f010641d:	68 78 87 10 f0       	push   $0xf0108778
f0106422:	e8 19 9c ff ff       	call   f0100040 <_panic>

f0106427 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106427:	55                   	push   %ebp
f0106428:	89 e5                	mov    %esp,%ebp
f010642a:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010642d:	8b 55 08             	mov    0x8(%ebp),%edx
f0106430:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106436:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010643b:	e8 aa fd ff ff       	call   f01061ea <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106440:	8b 15 04 20 29 f0    	mov    0xf0292004,%edx
f0106446:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010644c:	f6 c4 10             	test   $0x10,%ah
f010644f:	75 f5                	jne    f0106446 <lapic_ipi+0x1f>
		;
}
f0106451:	c9                   	leave  
f0106452:	c3                   	ret    

f0106453 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106453:	55                   	push   %ebp
f0106454:	89 e5                	mov    %esp,%ebp
f0106456:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0106459:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010645f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106462:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106465:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010646c:	5d                   	pop    %ebp
f010646d:	c3                   	ret    

f010646e <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010646e:	55                   	push   %ebp
f010646f:	89 e5                	mov    %esp,%ebp
f0106471:	56                   	push   %esi
f0106472:	53                   	push   %ebx
f0106473:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106476:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106479:	75 12                	jne    f010648d <spin_lock+0x1f>
	asm volatile("lock; xchgl %0, %1"
f010647b:	ba 01 00 00 00       	mov    $0x1,%edx
f0106480:	89 d0                	mov    %edx,%eax
f0106482:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106485:	85 c0                	test   %eax,%eax
f0106487:	74 36                	je     f01064bf <spin_lock+0x51>
		asm volatile ("pause");
f0106489:	f3 90                	pause  
f010648b:	eb f3                	jmp    f0106480 <spin_lock+0x12>
	return lock->locked && lock->cpu == thiscpu;
f010648d:	8b 73 08             	mov    0x8(%ebx),%esi
f0106490:	e8 69 fd ff ff       	call   f01061fe <cpunum>
f0106495:	6b c0 74             	imul   $0x74,%eax,%eax
f0106498:	05 20 10 25 f0       	add    $0xf0251020,%eax
	if (holding(lk))
f010649d:	39 c6                	cmp    %eax,%esi
f010649f:	75 da                	jne    f010647b <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01064a1:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01064a4:	e8 55 fd ff ff       	call   f01061fe <cpunum>
f01064a9:	83 ec 0c             	sub    $0xc,%esp
f01064ac:	53                   	push   %ebx
f01064ad:	50                   	push   %eax
f01064ae:	68 88 87 10 f0       	push   $0xf0108788
f01064b3:	6a 41                	push   $0x41
f01064b5:	68 ec 87 10 f0       	push   $0xf01087ec
f01064ba:	e8 81 9b ff ff       	call   f0100040 <_panic>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01064bf:	e8 3a fd ff ff       	call   f01061fe <cpunum>
f01064c4:	6b c0 74             	imul   $0x74,%eax,%eax
f01064c7:	05 20 10 25 f0       	add    $0xf0251020,%eax
f01064cc:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01064cf:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f01064d1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01064d6:	83 f8 09             	cmp    $0x9,%eax
f01064d9:	7f 16                	jg     f01064f1 <spin_lock+0x83>
f01064db:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01064e1:	76 0e                	jbe    f01064f1 <spin_lock+0x83>
		pcs[i] = ebp[1];          // saved %eip
f01064e3:	8b 4a 04             	mov    0x4(%edx),%ecx
f01064e6:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01064ea:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f01064ec:	83 c0 01             	add    $0x1,%eax
f01064ef:	eb e5                	jmp    f01064d6 <spin_lock+0x68>
	for (; i < 10; i++)
f01064f1:	83 f8 09             	cmp    $0x9,%eax
f01064f4:	7f 0d                	jg     f0106503 <spin_lock+0x95>
		pcs[i] = 0;
f01064f6:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f01064fd:	00 
	for (; i < 10; i++)
f01064fe:	83 c0 01             	add    $0x1,%eax
f0106501:	eb ee                	jmp    f01064f1 <spin_lock+0x83>
	get_caller_pcs(lk->pcs);
#endif
}
f0106503:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106506:	5b                   	pop    %ebx
f0106507:	5e                   	pop    %esi
f0106508:	5d                   	pop    %ebp
f0106509:	c3                   	ret    

f010650a <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010650a:	55                   	push   %ebp
f010650b:	89 e5                	mov    %esp,%ebp
f010650d:	57                   	push   %edi
f010650e:	56                   	push   %esi
f010650f:	53                   	push   %ebx
f0106510:	83 ec 4c             	sub    $0x4c,%esp
f0106513:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0106516:	83 3e 00             	cmpl   $0x0,(%esi)
f0106519:	75 35                	jne    f0106550 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010651b:	83 ec 04             	sub    $0x4,%esp
f010651e:	6a 28                	push   $0x28
f0106520:	8d 46 0c             	lea    0xc(%esi),%eax
f0106523:	50                   	push   %eax
f0106524:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106527:	53                   	push   %ebx
f0106528:	e8 18 f7 ff ff       	call   f0105c45 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f010652d:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106530:	0f b6 38             	movzbl (%eax),%edi
f0106533:	8b 76 04             	mov    0x4(%esi),%esi
f0106536:	e8 c3 fc ff ff       	call   f01061fe <cpunum>
f010653b:	57                   	push   %edi
f010653c:	56                   	push   %esi
f010653d:	50                   	push   %eax
f010653e:	68 b4 87 10 f0       	push   $0xf01087b4
f0106543:	e8 8d d7 ff ff       	call   f0103cd5 <cprintf>
f0106548:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010654b:	8d 7d a8             	lea    -0x58(%ebp),%edi
f010654e:	eb 4e                	jmp    f010659e <spin_unlock+0x94>
	return lock->locked && lock->cpu == thiscpu;
f0106550:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106553:	e8 a6 fc ff ff       	call   f01061fe <cpunum>
f0106558:	6b c0 74             	imul   $0x74,%eax,%eax
f010655b:	05 20 10 25 f0       	add    $0xf0251020,%eax
	if (!holding(lk)) {
f0106560:	39 c3                	cmp    %eax,%ebx
f0106562:	75 b7                	jne    f010651b <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0106564:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f010656b:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0106572:	b8 00 00 00 00       	mov    $0x0,%eax
f0106577:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f010657a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010657d:	5b                   	pop    %ebx
f010657e:	5e                   	pop    %esi
f010657f:	5f                   	pop    %edi
f0106580:	5d                   	pop    %ebp
f0106581:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f0106582:	83 ec 08             	sub    $0x8,%esp
f0106585:	ff 36                	pushl  (%esi)
f0106587:	68 13 88 10 f0       	push   $0xf0108813
f010658c:	e8 44 d7 ff ff       	call   f0103cd5 <cprintf>
f0106591:	83 c4 10             	add    $0x10,%esp
f0106594:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106597:	8d 45 e8             	lea    -0x18(%ebp),%eax
f010659a:	39 c3                	cmp    %eax,%ebx
f010659c:	74 40                	je     f01065de <spin_unlock+0xd4>
f010659e:	89 de                	mov    %ebx,%esi
f01065a0:	8b 03                	mov    (%ebx),%eax
f01065a2:	85 c0                	test   %eax,%eax
f01065a4:	74 38                	je     f01065de <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01065a6:	83 ec 08             	sub    $0x8,%esp
f01065a9:	57                   	push   %edi
f01065aa:	50                   	push   %eax
f01065ab:	e8 b3 e9 ff ff       	call   f0104f63 <debuginfo_eip>
f01065b0:	83 c4 10             	add    $0x10,%esp
f01065b3:	85 c0                	test   %eax,%eax
f01065b5:	78 cb                	js     f0106582 <spin_unlock+0x78>
					pcs[i] - info.eip_fn_addr);
f01065b7:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01065b9:	83 ec 04             	sub    $0x4,%esp
f01065bc:	89 c2                	mov    %eax,%edx
f01065be:	2b 55 b8             	sub    -0x48(%ebp),%edx
f01065c1:	52                   	push   %edx
f01065c2:	ff 75 b0             	pushl  -0x50(%ebp)
f01065c5:	ff 75 b4             	pushl  -0x4c(%ebp)
f01065c8:	ff 75 ac             	pushl  -0x54(%ebp)
f01065cb:	ff 75 a8             	pushl  -0x58(%ebp)
f01065ce:	50                   	push   %eax
f01065cf:	68 fc 87 10 f0       	push   $0xf01087fc
f01065d4:	e8 fc d6 ff ff       	call   f0103cd5 <cprintf>
f01065d9:	83 c4 20             	add    $0x20,%esp
f01065dc:	eb b6                	jmp    f0106594 <spin_unlock+0x8a>
		panic("spin_unlock");
f01065de:	83 ec 04             	sub    $0x4,%esp
f01065e1:	68 1b 88 10 f0       	push   $0xf010881b
f01065e6:	6a 67                	push   $0x67
f01065e8:	68 ec 87 10 f0       	push   $0xf01087ec
f01065ed:	e8 4e 9a ff ff       	call   f0100040 <_panic>
f01065f2:	66 90                	xchg   %ax,%ax
f01065f4:	66 90                	xchg   %ax,%ax
f01065f6:	66 90                	xchg   %ax,%ax
f01065f8:	66 90                	xchg   %ax,%ax
f01065fa:	66 90                	xchg   %ax,%ax
f01065fc:	66 90                	xchg   %ax,%ax
f01065fe:	66 90                	xchg   %ax,%ax

f0106600 <__udivdi3>:
f0106600:	55                   	push   %ebp
f0106601:	57                   	push   %edi
f0106602:	56                   	push   %esi
f0106603:	53                   	push   %ebx
f0106604:	83 ec 1c             	sub    $0x1c,%esp
f0106607:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010660b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010660f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106613:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0106617:	85 d2                	test   %edx,%edx
f0106619:	75 4d                	jne    f0106668 <__udivdi3+0x68>
f010661b:	39 f3                	cmp    %esi,%ebx
f010661d:	76 19                	jbe    f0106638 <__udivdi3+0x38>
f010661f:	31 ff                	xor    %edi,%edi
f0106621:	89 e8                	mov    %ebp,%eax
f0106623:	89 f2                	mov    %esi,%edx
f0106625:	f7 f3                	div    %ebx
f0106627:	89 fa                	mov    %edi,%edx
f0106629:	83 c4 1c             	add    $0x1c,%esp
f010662c:	5b                   	pop    %ebx
f010662d:	5e                   	pop    %esi
f010662e:	5f                   	pop    %edi
f010662f:	5d                   	pop    %ebp
f0106630:	c3                   	ret    
f0106631:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106638:	89 d9                	mov    %ebx,%ecx
f010663a:	85 db                	test   %ebx,%ebx
f010663c:	75 0b                	jne    f0106649 <__udivdi3+0x49>
f010663e:	b8 01 00 00 00       	mov    $0x1,%eax
f0106643:	31 d2                	xor    %edx,%edx
f0106645:	f7 f3                	div    %ebx
f0106647:	89 c1                	mov    %eax,%ecx
f0106649:	31 d2                	xor    %edx,%edx
f010664b:	89 f0                	mov    %esi,%eax
f010664d:	f7 f1                	div    %ecx
f010664f:	89 c6                	mov    %eax,%esi
f0106651:	89 e8                	mov    %ebp,%eax
f0106653:	89 f7                	mov    %esi,%edi
f0106655:	f7 f1                	div    %ecx
f0106657:	89 fa                	mov    %edi,%edx
f0106659:	83 c4 1c             	add    $0x1c,%esp
f010665c:	5b                   	pop    %ebx
f010665d:	5e                   	pop    %esi
f010665e:	5f                   	pop    %edi
f010665f:	5d                   	pop    %ebp
f0106660:	c3                   	ret    
f0106661:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106668:	39 f2                	cmp    %esi,%edx
f010666a:	77 1c                	ja     f0106688 <__udivdi3+0x88>
f010666c:	0f bd fa             	bsr    %edx,%edi
f010666f:	83 f7 1f             	xor    $0x1f,%edi
f0106672:	75 2c                	jne    f01066a0 <__udivdi3+0xa0>
f0106674:	39 f2                	cmp    %esi,%edx
f0106676:	72 06                	jb     f010667e <__udivdi3+0x7e>
f0106678:	31 c0                	xor    %eax,%eax
f010667a:	39 eb                	cmp    %ebp,%ebx
f010667c:	77 a9                	ja     f0106627 <__udivdi3+0x27>
f010667e:	b8 01 00 00 00       	mov    $0x1,%eax
f0106683:	eb a2                	jmp    f0106627 <__udivdi3+0x27>
f0106685:	8d 76 00             	lea    0x0(%esi),%esi
f0106688:	31 ff                	xor    %edi,%edi
f010668a:	31 c0                	xor    %eax,%eax
f010668c:	89 fa                	mov    %edi,%edx
f010668e:	83 c4 1c             	add    $0x1c,%esp
f0106691:	5b                   	pop    %ebx
f0106692:	5e                   	pop    %esi
f0106693:	5f                   	pop    %edi
f0106694:	5d                   	pop    %ebp
f0106695:	c3                   	ret    
f0106696:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010669d:	8d 76 00             	lea    0x0(%esi),%esi
f01066a0:	89 f9                	mov    %edi,%ecx
f01066a2:	b8 20 00 00 00       	mov    $0x20,%eax
f01066a7:	29 f8                	sub    %edi,%eax
f01066a9:	d3 e2                	shl    %cl,%edx
f01066ab:	89 54 24 08          	mov    %edx,0x8(%esp)
f01066af:	89 c1                	mov    %eax,%ecx
f01066b1:	89 da                	mov    %ebx,%edx
f01066b3:	d3 ea                	shr    %cl,%edx
f01066b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01066b9:	09 d1                	or     %edx,%ecx
f01066bb:	89 f2                	mov    %esi,%edx
f01066bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01066c1:	89 f9                	mov    %edi,%ecx
f01066c3:	d3 e3                	shl    %cl,%ebx
f01066c5:	89 c1                	mov    %eax,%ecx
f01066c7:	d3 ea                	shr    %cl,%edx
f01066c9:	89 f9                	mov    %edi,%ecx
f01066cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01066cf:	89 eb                	mov    %ebp,%ebx
f01066d1:	d3 e6                	shl    %cl,%esi
f01066d3:	89 c1                	mov    %eax,%ecx
f01066d5:	d3 eb                	shr    %cl,%ebx
f01066d7:	09 de                	or     %ebx,%esi
f01066d9:	89 f0                	mov    %esi,%eax
f01066db:	f7 74 24 08          	divl   0x8(%esp)
f01066df:	89 d6                	mov    %edx,%esi
f01066e1:	89 c3                	mov    %eax,%ebx
f01066e3:	f7 64 24 0c          	mull   0xc(%esp)
f01066e7:	39 d6                	cmp    %edx,%esi
f01066e9:	72 15                	jb     f0106700 <__udivdi3+0x100>
f01066eb:	89 f9                	mov    %edi,%ecx
f01066ed:	d3 e5                	shl    %cl,%ebp
f01066ef:	39 c5                	cmp    %eax,%ebp
f01066f1:	73 04                	jae    f01066f7 <__udivdi3+0xf7>
f01066f3:	39 d6                	cmp    %edx,%esi
f01066f5:	74 09                	je     f0106700 <__udivdi3+0x100>
f01066f7:	89 d8                	mov    %ebx,%eax
f01066f9:	31 ff                	xor    %edi,%edi
f01066fb:	e9 27 ff ff ff       	jmp    f0106627 <__udivdi3+0x27>
f0106700:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0106703:	31 ff                	xor    %edi,%edi
f0106705:	e9 1d ff ff ff       	jmp    f0106627 <__udivdi3+0x27>
f010670a:	66 90                	xchg   %ax,%ax
f010670c:	66 90                	xchg   %ax,%ax
f010670e:	66 90                	xchg   %ax,%ax

f0106710 <__umoddi3>:
f0106710:	55                   	push   %ebp
f0106711:	57                   	push   %edi
f0106712:	56                   	push   %esi
f0106713:	53                   	push   %ebx
f0106714:	83 ec 1c             	sub    $0x1c,%esp
f0106717:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f010671b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010671f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0106723:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106727:	89 da                	mov    %ebx,%edx
f0106729:	85 c0                	test   %eax,%eax
f010672b:	75 43                	jne    f0106770 <__umoddi3+0x60>
f010672d:	39 df                	cmp    %ebx,%edi
f010672f:	76 17                	jbe    f0106748 <__umoddi3+0x38>
f0106731:	89 f0                	mov    %esi,%eax
f0106733:	f7 f7                	div    %edi
f0106735:	89 d0                	mov    %edx,%eax
f0106737:	31 d2                	xor    %edx,%edx
f0106739:	83 c4 1c             	add    $0x1c,%esp
f010673c:	5b                   	pop    %ebx
f010673d:	5e                   	pop    %esi
f010673e:	5f                   	pop    %edi
f010673f:	5d                   	pop    %ebp
f0106740:	c3                   	ret    
f0106741:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106748:	89 fd                	mov    %edi,%ebp
f010674a:	85 ff                	test   %edi,%edi
f010674c:	75 0b                	jne    f0106759 <__umoddi3+0x49>
f010674e:	b8 01 00 00 00       	mov    $0x1,%eax
f0106753:	31 d2                	xor    %edx,%edx
f0106755:	f7 f7                	div    %edi
f0106757:	89 c5                	mov    %eax,%ebp
f0106759:	89 d8                	mov    %ebx,%eax
f010675b:	31 d2                	xor    %edx,%edx
f010675d:	f7 f5                	div    %ebp
f010675f:	89 f0                	mov    %esi,%eax
f0106761:	f7 f5                	div    %ebp
f0106763:	89 d0                	mov    %edx,%eax
f0106765:	eb d0                	jmp    f0106737 <__umoddi3+0x27>
f0106767:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010676e:	66 90                	xchg   %ax,%ax
f0106770:	89 f1                	mov    %esi,%ecx
f0106772:	39 d8                	cmp    %ebx,%eax
f0106774:	76 0a                	jbe    f0106780 <__umoddi3+0x70>
f0106776:	89 f0                	mov    %esi,%eax
f0106778:	83 c4 1c             	add    $0x1c,%esp
f010677b:	5b                   	pop    %ebx
f010677c:	5e                   	pop    %esi
f010677d:	5f                   	pop    %edi
f010677e:	5d                   	pop    %ebp
f010677f:	c3                   	ret    
f0106780:	0f bd e8             	bsr    %eax,%ebp
f0106783:	83 f5 1f             	xor    $0x1f,%ebp
f0106786:	75 20                	jne    f01067a8 <__umoddi3+0x98>
f0106788:	39 d8                	cmp    %ebx,%eax
f010678a:	0f 82 b0 00 00 00    	jb     f0106840 <__umoddi3+0x130>
f0106790:	39 f7                	cmp    %esi,%edi
f0106792:	0f 86 a8 00 00 00    	jbe    f0106840 <__umoddi3+0x130>
f0106798:	89 c8                	mov    %ecx,%eax
f010679a:	83 c4 1c             	add    $0x1c,%esp
f010679d:	5b                   	pop    %ebx
f010679e:	5e                   	pop    %esi
f010679f:	5f                   	pop    %edi
f01067a0:	5d                   	pop    %ebp
f01067a1:	c3                   	ret    
f01067a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01067a8:	89 e9                	mov    %ebp,%ecx
f01067aa:	ba 20 00 00 00       	mov    $0x20,%edx
f01067af:	29 ea                	sub    %ebp,%edx
f01067b1:	d3 e0                	shl    %cl,%eax
f01067b3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01067b7:	89 d1                	mov    %edx,%ecx
f01067b9:	89 f8                	mov    %edi,%eax
f01067bb:	d3 e8                	shr    %cl,%eax
f01067bd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01067c1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01067c5:	8b 54 24 04          	mov    0x4(%esp),%edx
f01067c9:	09 c1                	or     %eax,%ecx
f01067cb:	89 d8                	mov    %ebx,%eax
f01067cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01067d1:	89 e9                	mov    %ebp,%ecx
f01067d3:	d3 e7                	shl    %cl,%edi
f01067d5:	89 d1                	mov    %edx,%ecx
f01067d7:	d3 e8                	shr    %cl,%eax
f01067d9:	89 e9                	mov    %ebp,%ecx
f01067db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01067df:	d3 e3                	shl    %cl,%ebx
f01067e1:	89 c7                	mov    %eax,%edi
f01067e3:	89 d1                	mov    %edx,%ecx
f01067e5:	89 f0                	mov    %esi,%eax
f01067e7:	d3 e8                	shr    %cl,%eax
f01067e9:	89 e9                	mov    %ebp,%ecx
f01067eb:	89 fa                	mov    %edi,%edx
f01067ed:	d3 e6                	shl    %cl,%esi
f01067ef:	09 d8                	or     %ebx,%eax
f01067f1:	f7 74 24 08          	divl   0x8(%esp)
f01067f5:	89 d1                	mov    %edx,%ecx
f01067f7:	89 f3                	mov    %esi,%ebx
f01067f9:	f7 64 24 0c          	mull   0xc(%esp)
f01067fd:	89 c6                	mov    %eax,%esi
f01067ff:	89 d7                	mov    %edx,%edi
f0106801:	39 d1                	cmp    %edx,%ecx
f0106803:	72 06                	jb     f010680b <__umoddi3+0xfb>
f0106805:	75 10                	jne    f0106817 <__umoddi3+0x107>
f0106807:	39 c3                	cmp    %eax,%ebx
f0106809:	73 0c                	jae    f0106817 <__umoddi3+0x107>
f010680b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010680f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0106813:	89 d7                	mov    %edx,%edi
f0106815:	89 c6                	mov    %eax,%esi
f0106817:	89 ca                	mov    %ecx,%edx
f0106819:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010681e:	29 f3                	sub    %esi,%ebx
f0106820:	19 fa                	sbb    %edi,%edx
f0106822:	89 d0                	mov    %edx,%eax
f0106824:	d3 e0                	shl    %cl,%eax
f0106826:	89 e9                	mov    %ebp,%ecx
f0106828:	d3 eb                	shr    %cl,%ebx
f010682a:	d3 ea                	shr    %cl,%edx
f010682c:	09 d8                	or     %ebx,%eax
f010682e:	83 c4 1c             	add    $0x1c,%esp
f0106831:	5b                   	pop    %ebx
f0106832:	5e                   	pop    %esi
f0106833:	5f                   	pop    %edi
f0106834:	5d                   	pop    %ebp
f0106835:	c3                   	ret    
f0106836:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010683d:	8d 76 00             	lea    0x0(%esi),%esi
f0106840:	89 da                	mov    %ebx,%edx
f0106842:	29 fe                	sub    %edi,%esi
f0106844:	19 c2                	sbb    %eax,%edx
f0106846:	89 f1                	mov    %esi,%ecx
f0106848:	89 c8                	mov    %ecx,%eax
f010684a:	e9 4b ff ff ff       	jmp    f010679a <__umoddi3+0x8a>
