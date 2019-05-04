
obj/user/evilhello2:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 25 01 00 00       	call   800156 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <evil>:
struct Segdesc *entry;
static void (*wrapper)(void) = NULL;

// Call this function with ring0 privilege
void evil()
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
	// Kernel memory access
	*(char*)0xf010000a = 0;
  800037:	c6 05 0a 00 10 f0 00 	movb   $0x0,0xf010000a
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80003e:	bb 49 00 00 00       	mov    $0x49,%ebx
  800043:	ba f8 03 00 00       	mov    $0x3f8,%edx
  800048:	89 d8                	mov    %ebx,%eax
  80004a:	ee                   	out    %al,(%dx)
  80004b:	b9 4e 00 00 00       	mov    $0x4e,%ecx
  800050:	89 c8                	mov    %ecx,%eax
  800052:	ee                   	out    %al,(%dx)
  800053:	b8 20 00 00 00       	mov    $0x20,%eax
  800058:	ee                   	out    %al,(%dx)
  800059:	b8 52 00 00 00       	mov    $0x52,%eax
  80005e:	ee                   	out    %al,(%dx)
  80005f:	89 d8                	mov    %ebx,%eax
  800061:	ee                   	out    %al,(%dx)
  800062:	89 c8                	mov    %ecx,%eax
  800064:	ee                   	out    %al,(%dx)
  800065:	b8 47 00 00 00       	mov    $0x47,%eax
  80006a:	ee                   	out    %al,(%dx)
  80006b:	b8 30 00 00 00       	mov    $0x30,%eax
  800070:	ee                   	out    %al,(%dx)
  800071:	b8 21 00 00 00       	mov    $0x21,%eax
  800076:	ee                   	out    %al,(%dx)
  800077:	ee                   	out    %al,(%dx)
  800078:	ee                   	out    %al,(%dx)
  800079:	b8 0a 00 00 00       	mov    $0xa,%eax
  80007e:	ee                   	out    %al,(%dx)
	outb(0x3f8, '0');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '\n');
}
  80007f:	5b                   	pop    %ebx
  800080:	5d                   	pop    %ebp
  800081:	c3                   	ret    

00800082 <call_fun_ptr>:

void call_fun_ptr()
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	83 ec 08             	sub    $0x8,%esp
    wrapper();  
  800088:	ff 15 20 20 80 00    	call   *0x802020
    *entry = old;  
  80008e:	8b 0d 40 20 80 00    	mov    0x802040,%ecx
  800094:	a1 64 30 80 00       	mov    0x803064,%eax
  800099:	8b 15 68 30 80 00    	mov    0x803068,%edx
  80009f:	89 01                	mov    %eax,(%ecx)
  8000a1:	89 51 04             	mov    %edx,0x4(%ecx)
    asm volatile("leave");
  8000a4:	c9                   	leave  
    asm volatile("lret");   
  8000a5:	cb                   	lret   
}
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <ring0_call>:
{
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
}

// Invoke a given function pointer with ring0 privilege, then return to ring3
void ring0_call(void (*fun_ptr)(void)) {
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 20             	sub    $0x20,%esp
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
  8000ae:	0f 01 45 f2          	sgdtl  -0xe(%ebp)

    // Lab3 : Your Code Here
    struct Pseudodesc r_gdt; 
    sgdt(&r_gdt);

    int t = sys_map_kernel_page((void* )r_gdt.pd_base, (void* )vaddr);
  8000b2:	68 60 20 80 00       	push   $0x802060
  8000b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8000ba:	e8 bb 0e 00 00       	call   800f7a <sys_map_kernel_page>
    if (t < 0) {
  8000bf:	83 c4 10             	add    $0x10,%esp
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	78 63                	js     800129 <ring0_call+0x81>
        cprintf("ring0_call: sys_map_kernel_page failed, %e\n", t);
    }

    wrapper = fun_ptr;
  8000c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c9:	a3 20 20 80 00       	mov    %eax,0x802020

    uint32_t base = (uint32_t)(PGNUM(vaddr) << PTXSHIFT);
    uint32_t index = GD_UD >> 3;
    uint32_t offset = PGOFF(r_gdt.pd_base);
  8000ce:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  8000d1:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
    uint32_t base = (uint32_t)(PGNUM(vaddr) << PTXSHIFT);
  8000d7:	b8 60 20 80 00       	mov    $0x802060,%eax
  8000dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax

    gdt = (struct Segdesc*)(base+offset); 
  8000e1:	09 c1                	or     %eax,%ecx
  8000e3:	89 0d 60 30 80 00    	mov    %ecx,0x803060
    entry = gdt + index; 
  8000e9:	8d 41 20             	lea    0x20(%ecx),%eax
  8000ec:	a3 40 20 80 00       	mov    %eax,0x802040
    old= *entry; 
  8000f1:	8b 41 20             	mov    0x20(%ecx),%eax
  8000f4:	8b 51 24             	mov    0x24(%ecx),%edx
  8000f7:	a3 64 30 80 00       	mov    %eax,0x803064
  8000fc:	89 15 68 30 80 00    	mov    %edx,0x803068

    SETCALLGATE(*((struct Gatedesc*)entry), GD_KT, call_fun_ptr, 3);
  800102:	b8 82 00 80 00       	mov    $0x800082,%eax
  800107:	66 89 41 20          	mov    %ax,0x20(%ecx)
  80010b:	66 c7 41 22 08 00    	movw   $0x8,0x22(%ecx)
  800111:	c6 41 24 00          	movb   $0x0,0x24(%ecx)
  800115:	c6 41 25 ec          	movb   $0xec,0x25(%ecx)
  800119:	c1 e8 10             	shr    $0x10,%eax
  80011c:	66 89 41 26          	mov    %ax,0x26(%ecx)
    asm volatile("lcall $0x20, $0");
  800120:	9a 00 00 00 00 20 00 	lcall  $0x20,$0x0
}
  800127:	c9                   	leave  
  800128:	c3                   	ret    
        cprintf("ring0_call: sys_map_kernel_page failed, %e\n", t);
  800129:	83 ec 08             	sub    $0x8,%esp
  80012c:	50                   	push   %eax
  80012d:	68 60 12 80 00       	push   $0x801260
  800132:	e8 0c 01 00 00       	call   800243 <cprintf>
  800137:	83 c4 10             	add    $0x10,%esp
  80013a:	eb 8a                	jmp    8000c6 <ring0_call+0x1e>

0080013c <umain>:

void
umain(int argc, char **argv)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 14             	sub    $0x14,%esp
        // call the evil function in ring0
	ring0_call(&evil);
  800142:	68 33 00 80 00       	push   $0x800033
  800147:	e8 5c ff ff ff       	call   8000a8 <ring0_call>

	// call the evil function in ring3
	evil();
  80014c:	e8 e2 fe ff ff       	call   800033 <evil>
}
  800151:	83 c4 10             	add    $0x10,%esp
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80015e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800161:	e8 27 0c 00 00       	call   800d8d <sys_getenvid>
  800166:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016b:	c1 e0 07             	shl    $0x7,%eax
  80016e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800173:	a3 6c 30 80 00       	mov    %eax,0x80306c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800178:	85 db                	test   %ebx,%ebx
  80017a:	7e 07                	jle    800183 <libmain+0x2d>
		binaryname = argv[0];
  80017c:	8b 06                	mov    (%esi),%eax
  80017e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800183:	83 ec 08             	sub    $0x8,%esp
  800186:	56                   	push   %esi
  800187:	53                   	push   %ebx
  800188:	e8 af ff ff ff       	call   80013c <umain>

	// exit gracefully
	exit();
  80018d:	e8 0a 00 00 00       	call   80019c <exit>
}
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5d                   	pop    %ebp
  80019b:	c3                   	ret    

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001a2:	6a 00                	push   $0x0
  8001a4:	e8 a3 0b 00 00       	call   800d4c <sys_env_destroy>
}
  8001a9:	83 c4 10             	add    $0x10,%esp
  8001ac:	c9                   	leave  
  8001ad:	c3                   	ret    

008001ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
  8001b1:	53                   	push   %ebx
  8001b2:	83 ec 04             	sub    $0x4,%esp
  8001b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b8:	8b 13                	mov    (%ebx),%edx
  8001ba:	8d 42 01             	lea    0x1(%edx),%eax
  8001bd:	89 03                	mov    %eax,(%ebx)
  8001bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cb:	74 09                	je     8001d6 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001cd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d4:	c9                   	leave  
  8001d5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001d6:	83 ec 08             	sub    $0x8,%esp
  8001d9:	68 ff 00 00 00       	push   $0xff
  8001de:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e1:	50                   	push   %eax
  8001e2:	e8 28 0b 00 00       	call   800d0f <sys_cputs>
		b->idx = 0;
  8001e7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001ed:	83 c4 10             	add    $0x10,%esp
  8001f0:	eb db                	jmp    8001cd <putch+0x1f>

008001f2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001fb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800202:	00 00 00 
	b.cnt = 0;
  800205:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80020c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80020f:	ff 75 0c             	pushl  0xc(%ebp)
  800212:	ff 75 08             	pushl  0x8(%ebp)
  800215:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	68 ae 01 80 00       	push   $0x8001ae
  800221:	e8 fb 00 00 00       	call   800321 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800226:	83 c4 08             	add    $0x8,%esp
  800229:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80022f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800235:	50                   	push   %eax
  800236:	e8 d4 0a 00 00       	call   800d0f <sys_cputs>

	return b.cnt;
}
  80023b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800241:	c9                   	leave  
  800242:	c3                   	ret    

00800243 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800243:	55                   	push   %ebp
  800244:	89 e5                	mov    %esp,%ebp
  800246:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800249:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80024c:	50                   	push   %eax
  80024d:	ff 75 08             	pushl  0x8(%ebp)
  800250:	e8 9d ff ff ff       	call   8001f2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 1c             	sub    $0x1c,%esp
  800260:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800263:	89 d3                	mov    %edx,%ebx
  800265:	8b 75 08             	mov    0x8(%ebp),%esi
  800268:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80026b:	8b 45 10             	mov    0x10(%ebp),%eax
  80026e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800271:	89 c2                	mov    %eax,%edx
  800273:	b9 00 00 00 00       	mov    $0x0,%ecx
  800278:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80027b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80027e:	39 c6                	cmp    %eax,%esi
  800280:	89 f8                	mov    %edi,%eax
  800282:	19 c8                	sbb    %ecx,%eax
  800284:	73 32                	jae    8002b8 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800286:	83 ec 08             	sub    $0x8,%esp
  800289:	53                   	push   %ebx
  80028a:	83 ec 04             	sub    $0x4,%esp
  80028d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800290:	ff 75 e0             	pushl  -0x20(%ebp)
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	e8 86 0e 00 00       	call   801120 <__umoddi3>
  80029a:	83 c4 14             	add    $0x14,%esp
  80029d:	0f be 80 96 12 80 00 	movsbl 0x801296(%eax),%eax
  8002a4:	50                   	push   %eax
  8002a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a8:	ff d0                	call   *%eax
	return remain - 1;
  8002aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ad:	83 e8 01             	sub    $0x1,%eax
}
  8002b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  8002b8:	83 ec 0c             	sub    $0xc,%esp
  8002bb:	ff 75 18             	pushl  0x18(%ebp)
  8002be:	ff 75 14             	pushl  0x14(%ebp)
  8002c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	51                   	push   %ecx
  8002c8:	52                   	push   %edx
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	e8 40 0d 00 00       	call   801010 <__udivdi3>
  8002d0:	83 c4 18             	add    $0x18,%esp
  8002d3:	52                   	push   %edx
  8002d4:	50                   	push   %eax
  8002d5:	89 da                	mov    %ebx,%edx
  8002d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002da:	e8 78 ff ff ff       	call   800257 <printnum_helper>
  8002df:	89 45 14             	mov    %eax,0x14(%ebp)
  8002e2:	83 c4 20             	add    $0x20,%esp
  8002e5:	eb 9f                	jmp    800286 <printnum_helper+0x2f>

008002e7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ed:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f1:	8b 10                	mov    (%eax),%edx
  8002f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f6:	73 0a                	jae    800302 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002f8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	88 02                	mov    %al,(%edx)
}
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <printfmt>:
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80030a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030d:	50                   	push   %eax
  80030e:	ff 75 10             	pushl  0x10(%ebp)
  800311:	ff 75 0c             	pushl  0xc(%ebp)
  800314:	ff 75 08             	pushl  0x8(%ebp)
  800317:	e8 05 00 00 00       	call   800321 <vprintfmt>
}
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	c9                   	leave  
  800320:	c3                   	ret    

00800321 <vprintfmt>:
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
  800327:	83 ec 3c             	sub    $0x3c,%esp
  80032a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80032d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800330:	8b 7d 10             	mov    0x10(%ebp),%edi
  800333:	e9 3f 05 00 00       	jmp    800877 <vprintfmt+0x556>
		padc = ' ';
  800338:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  80033c:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800343:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  80034a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800351:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  800358:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80035f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8d 47 01             	lea    0x1(%edi),%eax
  800367:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80036a:	0f b6 17             	movzbl (%edi),%edx
  80036d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800370:	3c 55                	cmp    $0x55,%al
  800372:	0f 87 98 05 00 00    	ja     800910 <vprintfmt+0x5ef>
  800378:	0f b6 c0             	movzbl %al,%eax
  80037b:	ff 24 85 e0 13 80 00 	jmp    *0x8013e0(,%eax,4)
  800382:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  800385:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  800389:	eb d9                	jmp    800364 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  80038e:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  800395:	eb cd                	jmp    800364 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800397:	0f b6 d2             	movzbl %dl,%edx
  80039a:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80039d:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a2:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  8003a5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003a8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003ac:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003af:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003b2:	83 fb 09             	cmp    $0x9,%ebx
  8003b5:	77 5c                	ja     800413 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  8003b7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003ba:	eb e9                	jmp    8003a5 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  8003bf:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  8003c3:	eb 9f                	jmp    800364 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  8003c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c8:	8b 00                	mov    (%eax),%eax
  8003ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 40 04             	lea    0x4(%eax),%eax
  8003d3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8003d9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003dd:	79 85                	jns    800364 <vprintfmt+0x43>
				width = precision, precision = -1;
  8003df:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ec:	e9 73 ff ff ff       	jmp    800364 <vprintfmt+0x43>
  8003f1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003f4:	85 c0                	test   %eax,%eax
  8003f6:	0f 48 c1             	cmovs  %ecx,%eax
  8003f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003fc:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8003ff:	e9 60 ff ff ff       	jmp    800364 <vprintfmt+0x43>
  800404:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  800407:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  80040e:	e9 51 ff ff ff       	jmp    800364 <vprintfmt+0x43>
  800413:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800416:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800419:	eb be                	jmp    8003d9 <vprintfmt+0xb8>
			lflag++;
  80041b:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80041f:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  800422:	e9 3d ff ff ff       	jmp    800364 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  800427:	8b 45 14             	mov    0x14(%ebp),%eax
  80042a:	8d 78 04             	lea    0x4(%eax),%edi
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	56                   	push   %esi
  800431:	ff 30                	pushl  (%eax)
  800433:	ff d3                	call   *%ebx
			break;
  800435:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800438:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80043b:	e9 34 04 00 00       	jmp    800874 <vprintfmt+0x553>
			err = va_arg(ap, int);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 78 04             	lea    0x4(%eax),%edi
  800446:	8b 00                	mov    (%eax),%eax
  800448:	99                   	cltd   
  800449:	31 d0                	xor    %edx,%eax
  80044b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044d:	83 f8 08             	cmp    $0x8,%eax
  800450:	7f 23                	jg     800475 <vprintfmt+0x154>
  800452:	8b 14 85 40 15 80 00 	mov    0x801540(,%eax,4),%edx
  800459:	85 d2                	test   %edx,%edx
  80045b:	74 18                	je     800475 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  80045d:	52                   	push   %edx
  80045e:	68 b7 12 80 00       	push   $0x8012b7
  800463:	56                   	push   %esi
  800464:	53                   	push   %ebx
  800465:	e8 9a fe ff ff       	call   800304 <printfmt>
  80046a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800470:	e9 ff 03 00 00       	jmp    800874 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  800475:	50                   	push   %eax
  800476:	68 ae 12 80 00       	push   $0x8012ae
  80047b:	56                   	push   %esi
  80047c:	53                   	push   %ebx
  80047d:	e8 82 fe ff ff       	call   800304 <printfmt>
  800482:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800485:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800488:	e9 e7 03 00 00       	jmp    800874 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	83 c0 04             	add    $0x4,%eax
  800493:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80049b:	85 c9                	test   %ecx,%ecx
  80049d:	b8 a7 12 80 00       	mov    $0x8012a7,%eax
  8004a2:	0f 45 c1             	cmovne %ecx,%eax
  8004a5:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  8004a8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ac:	7e 06                	jle    8004b4 <vprintfmt+0x193>
  8004ae:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8004b2:	75 0d                	jne    8004c1 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004b7:	89 c7                	mov    %eax,%edi
  8004b9:	03 45 d8             	add    -0x28(%ebp),%eax
  8004bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004bf:	eb 53                	jmp    800514 <vprintfmt+0x1f3>
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c7:	50                   	push   %eax
  8004c8:	e8 eb 04 00 00       	call   8009b8 <strnlen>
  8004cd:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8004d0:	29 c1                	sub    %eax,%ecx
  8004d2:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004da:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8004de:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	eb 0f                	jmp    8004f2 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	56                   	push   %esi
  8004e7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ea:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ec:	83 ef 01             	sub    $0x1,%edi
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	85 ff                	test   %edi,%edi
  8004f4:	7f ed                	jg     8004e3 <vprintfmt+0x1c2>
  8004f6:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8004f9:	85 c9                	test   %ecx,%ecx
  8004fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800500:	0f 49 c1             	cmovns %ecx,%eax
  800503:	29 c1                	sub    %eax,%ecx
  800505:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800508:	eb aa                	jmp    8004b4 <vprintfmt+0x193>
					putch(ch, putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	56                   	push   %esi
  80050e:	52                   	push   %edx
  80050f:	ff d3                	call   *%ebx
  800511:	83 c4 10             	add    $0x10,%esp
  800514:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800517:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800519:	83 c7 01             	add    $0x1,%edi
  80051c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800520:	0f be d0             	movsbl %al,%edx
  800523:	85 d2                	test   %edx,%edx
  800525:	74 2e                	je     800555 <vprintfmt+0x234>
  800527:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052b:	78 06                	js     800533 <vprintfmt+0x212>
  80052d:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800531:	78 1e                	js     800551 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800533:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800537:	74 d1                	je     80050a <vprintfmt+0x1e9>
  800539:	0f be c0             	movsbl %al,%eax
  80053c:	83 e8 20             	sub    $0x20,%eax
  80053f:	83 f8 5e             	cmp    $0x5e,%eax
  800542:	76 c6                	jbe    80050a <vprintfmt+0x1e9>
					putch('?', putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	56                   	push   %esi
  800548:	6a 3f                	push   $0x3f
  80054a:	ff d3                	call   *%ebx
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	eb c3                	jmp    800514 <vprintfmt+0x1f3>
  800551:	89 cf                	mov    %ecx,%edi
  800553:	eb 02                	jmp    800557 <vprintfmt+0x236>
  800555:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  800557:	85 ff                	test   %edi,%edi
  800559:	7e 10                	jle    80056b <vprintfmt+0x24a>
				putch(' ', putdat);
  80055b:	83 ec 08             	sub    $0x8,%esp
  80055e:	56                   	push   %esi
  80055f:	6a 20                	push   $0x20
  800561:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800563:	83 ef 01             	sub    $0x1,%edi
  800566:	83 c4 10             	add    $0x10,%esp
  800569:	eb ec                	jmp    800557 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  80056b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80056e:	89 45 14             	mov    %eax,0x14(%ebp)
  800571:	e9 fe 02 00 00       	jmp    800874 <vprintfmt+0x553>
	if (lflag >= 2)
  800576:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80057a:	7f 21                	jg     80059d <vprintfmt+0x27c>
	else if (lflag)
  80057c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800580:	74 79                	je     8005fb <vprintfmt+0x2da>
		return va_arg(*ap, long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8b 00                	mov    (%eax),%eax
  800587:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058a:	89 c1                	mov    %eax,%ecx
  80058c:	c1 f9 1f             	sar    $0x1f,%ecx
  80058f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 40 04             	lea    0x4(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
  80059b:	eb 17                	jmp    8005b4 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8b 50 04             	mov    0x4(%eax),%edx
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 40 08             	lea    0x8(%eax),%eax
  8005b1:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  8005b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005bd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  8005c0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005c4:	78 50                	js     800616 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  8005c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c9:	c1 fa 1f             	sar    $0x1f,%edx
  8005cc:	89 d0                	mov    %edx,%eax
  8005ce:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8005d1:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8005d4:	85 d2                	test   %edx,%edx
  8005d6:	0f 89 14 02 00 00    	jns    8007f0 <vprintfmt+0x4cf>
  8005dc:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005e0:	0f 84 0a 02 00 00    	je     8007f0 <vprintfmt+0x4cf>
				putch('+', putdat);
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	56                   	push   %esi
  8005ea:	6a 2b                	push   $0x2b
  8005ec:	ff d3                	call   *%ebx
  8005ee:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f6:	e9 5c 01 00 00       	jmp    800757 <vprintfmt+0x436>
		return va_arg(*ap, int);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800603:	89 c1                	mov    %eax,%ecx
  800605:	c1 f9 1f             	sar    $0x1f,%ecx
  800608:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 40 04             	lea    0x4(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
  800614:	eb 9e                	jmp    8005b4 <vprintfmt+0x293>
				putch('-', putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	56                   	push   %esi
  80061a:	6a 2d                	push   $0x2d
  80061c:	ff d3                	call   *%ebx
				num = -(long long) num;
  80061e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800621:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800624:	f7 d8                	neg    %eax
  800626:	83 d2 00             	adc    $0x0,%edx
  800629:	f7 da                	neg    %edx
  80062b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80062e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800631:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800634:	b8 0a 00 00 00       	mov    $0xa,%eax
  800639:	e9 19 01 00 00       	jmp    800757 <vprintfmt+0x436>
	if (lflag >= 2)
  80063e:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800642:	7f 29                	jg     80066d <vprintfmt+0x34c>
	else if (lflag)
  800644:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800648:	74 44                	je     80068e <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	ba 00 00 00 00       	mov    $0x0,%edx
  800654:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800657:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800663:	b8 0a 00 00 00       	mov    $0xa,%eax
  800668:	e9 ea 00 00 00       	jmp    800757 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 50 04             	mov    0x4(%eax),%edx
  800673:	8b 00                	mov    (%eax),%eax
  800675:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800678:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 40 08             	lea    0x8(%eax),%eax
  800681:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800684:	b8 0a 00 00 00       	mov    $0xa,%eax
  800689:	e9 c9 00 00 00       	jmp    800757 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8b 00                	mov    (%eax),%eax
  800693:	ba 00 00 00 00       	mov    $0x0,%edx
  800698:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80069b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 40 04             	lea    0x4(%eax),%eax
  8006a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ac:	e9 a6 00 00 00       	jmp    800757 <vprintfmt+0x436>
			putch('0', putdat);
  8006b1:	83 ec 08             	sub    $0x8,%esp
  8006b4:	56                   	push   %esi
  8006b5:	6a 30                	push   $0x30
  8006b7:	ff d3                	call   *%ebx
	if (lflag >= 2)
  8006b9:	83 c4 10             	add    $0x10,%esp
  8006bc:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8006c0:	7f 26                	jg     8006e8 <vprintfmt+0x3c7>
	else if (lflag)
  8006c2:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006c6:	74 3e                	je     800706 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 00                	mov    (%eax),%eax
  8006cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8006d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006d5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8006e6:	eb 6f                	jmp    800757 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 50 04             	mov    0x4(%eax),%edx
  8006ee:	8b 00                	mov    (%eax),%eax
  8006f0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006f3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8d 40 08             	lea    0x8(%eax),%eax
  8006fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006ff:	b8 08 00 00 00       	mov    $0x8,%eax
  800704:	eb 51                	jmp    800757 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 00                	mov    (%eax),%eax
  80070b:	ba 00 00 00 00       	mov    $0x0,%edx
  800710:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800713:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8d 40 04             	lea    0x4(%eax),%eax
  80071c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80071f:	b8 08 00 00 00       	mov    $0x8,%eax
  800724:	eb 31                	jmp    800757 <vprintfmt+0x436>
			putch('0', putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	56                   	push   %esi
  80072a:	6a 30                	push   $0x30
  80072c:	ff d3                	call   *%ebx
			putch('x', putdat);
  80072e:	83 c4 08             	add    $0x8,%esp
  800731:	56                   	push   %esi
  800732:	6a 78                	push   $0x78
  800734:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	8b 00                	mov    (%eax),%eax
  80073b:	ba 00 00 00 00       	mov    $0x0,%edx
  800740:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800743:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800746:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8d 40 04             	lea    0x4(%eax),%eax
  80074f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800752:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800757:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  80075b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80075e:	89 c1                	mov    %eax,%ecx
  800760:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800763:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800766:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  80076b:	89 c2                	mov    %eax,%edx
  80076d:	39 c1                	cmp    %eax,%ecx
  80076f:	0f 87 85 00 00 00    	ja     8007fa <vprintfmt+0x4d9>
		tmp /= base;
  800775:	89 d0                	mov    %edx,%eax
  800777:	ba 00 00 00 00       	mov    $0x0,%edx
  80077c:	f7 f1                	div    %ecx
		len++;
  80077e:	83 c7 01             	add    $0x1,%edi
  800781:	eb e8                	jmp    80076b <vprintfmt+0x44a>
	if (lflag >= 2)
  800783:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800787:	7f 26                	jg     8007af <vprintfmt+0x48e>
	else if (lflag)
  800789:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80078d:	74 3e                	je     8007cd <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8b 00                	mov    (%eax),%eax
  800794:	ba 00 00 00 00       	mov    $0x0,%edx
  800799:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80079c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8d 40 04             	lea    0x4(%eax),%eax
  8007a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a8:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ad:	eb a8                	jmp    800757 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8b 50 04             	mov    0x4(%eax),%edx
  8007b5:	8b 00                	mov    (%eax),%eax
  8007b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007ba:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8d 40 08             	lea    0x8(%eax),%eax
  8007c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8007cb:	eb 8a                	jmp    800757 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	8b 00                	mov    (%eax),%eax
  8007d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007da:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 40 04             	lea    0x4(%eax),%eax
  8007e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e6:	b8 10 00 00 00       	mov    $0x10,%eax
  8007eb:	e9 67 ff ff ff       	jmp    800757 <vprintfmt+0x436>
			base = 10;
  8007f0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f5:	e9 5d ff ff ff       	jmp    800757 <vprintfmt+0x436>
  8007fa:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8007fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800800:	29 f8                	sub    %edi,%eax
  800802:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  800804:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  800808:	74 15                	je     80081f <vprintfmt+0x4fe>
		while (width > 0) {
  80080a:	85 ff                	test   %edi,%edi
  80080c:	7e 48                	jle    800856 <vprintfmt+0x535>
			putch(padc, putdat);
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	56                   	push   %esi
  800812:	ff 75 e0             	pushl  -0x20(%ebp)
  800815:	ff d3                	call   *%ebx
			width--;
  800817:	83 ef 01             	sub    $0x1,%edi
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	eb eb                	jmp    80080a <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  80081f:	83 ec 0c             	sub    $0xc,%esp
  800822:	6a 2d                	push   $0x2d
  800824:	ff 75 cc             	pushl  -0x34(%ebp)
  800827:	ff 75 c8             	pushl  -0x38(%ebp)
  80082a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80082d:	ff 75 d0             	pushl  -0x30(%ebp)
  800830:	89 f2                	mov    %esi,%edx
  800832:	89 d8                	mov    %ebx,%eax
  800834:	e8 1e fa ff ff       	call   800257 <printnum_helper>
		width -= len;
  800839:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80083c:	2b 7d cc             	sub    -0x34(%ebp),%edi
  80083f:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800842:	85 ff                	test   %edi,%edi
  800844:	7e 2e                	jle    800874 <vprintfmt+0x553>
			putch(padc, putdat);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	56                   	push   %esi
  80084a:	6a 20                	push   $0x20
  80084c:	ff d3                	call   *%ebx
			width--;
  80084e:	83 ef 01             	sub    $0x1,%edi
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	eb ec                	jmp    800842 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800856:	83 ec 0c             	sub    $0xc,%esp
  800859:	ff 75 e0             	pushl  -0x20(%ebp)
  80085c:	ff 75 cc             	pushl  -0x34(%ebp)
  80085f:	ff 75 c8             	pushl  -0x38(%ebp)
  800862:	ff 75 d4             	pushl  -0x2c(%ebp)
  800865:	ff 75 d0             	pushl  -0x30(%ebp)
  800868:	89 f2                	mov    %esi,%edx
  80086a:	89 d8                	mov    %ebx,%eax
  80086c:	e8 e6 f9 ff ff       	call   800257 <printnum_helper>
  800871:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800874:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800877:	83 c7 01             	add    $0x1,%edi
  80087a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80087e:	83 f8 25             	cmp    $0x25,%eax
  800881:	0f 84 b1 fa ff ff    	je     800338 <vprintfmt+0x17>
			if (ch == '\0')
  800887:	85 c0                	test   %eax,%eax
  800889:	0f 84 a1 00 00 00    	je     800930 <vprintfmt+0x60f>
			putch(ch, putdat);
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	56                   	push   %esi
  800893:	50                   	push   %eax
  800894:	ff d3                	call   *%ebx
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	eb dc                	jmp    800877 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  80089b:	8b 45 14             	mov    0x14(%ebp),%eax
  80089e:	83 c0 04             	add    $0x4,%eax
  8008a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a7:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8008a9:	85 ff                	test   %edi,%edi
  8008ab:	74 15                	je     8008c2 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  8008ad:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  8008b3:	7f 29                	jg     8008de <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  8008b5:	0f b6 06             	movzbl (%esi),%eax
  8008b8:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  8008ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008bd:	89 45 14             	mov    %eax,0x14(%ebp)
  8008c0:	eb b2                	jmp    800874 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8008c2:	68 50 13 80 00       	push   $0x801350
  8008c7:	68 b7 12 80 00       	push   $0x8012b7
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
  8008ce:	e8 31 fa ff ff       	call   800304 <printfmt>
  8008d3:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8008d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8008dc:	eb 96                	jmp    800874 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  8008de:	68 88 13 80 00       	push   $0x801388
  8008e3:	68 b7 12 80 00       	push   $0x8012b7
  8008e8:	56                   	push   %esi
  8008e9:	53                   	push   %ebx
  8008ea:	e8 15 fa ff ff       	call   800304 <printfmt>
				*res = -1;
  8008ef:	c6 07 ff             	movb   $0xff,(%edi)
  8008f2:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8008f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8008fb:	e9 74 ff ff ff       	jmp    800874 <vprintfmt+0x553>
			putch(ch, putdat);
  800900:	83 ec 08             	sub    $0x8,%esp
  800903:	56                   	push   %esi
  800904:	6a 25                	push   $0x25
  800906:	ff d3                	call   *%ebx
			break;
  800908:	83 c4 10             	add    $0x10,%esp
  80090b:	e9 64 ff ff ff       	jmp    800874 <vprintfmt+0x553>
			putch('%', putdat);
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	56                   	push   %esi
  800914:	6a 25                	push   $0x25
  800916:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800918:	83 c4 10             	add    $0x10,%esp
  80091b:	89 f8                	mov    %edi,%eax
  80091d:	eb 03                	jmp    800922 <vprintfmt+0x601>
  80091f:	83 e8 01             	sub    $0x1,%eax
  800922:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800926:	75 f7                	jne    80091f <vprintfmt+0x5fe>
  800928:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80092b:	e9 44 ff ff ff       	jmp    800874 <vprintfmt+0x553>
}
  800930:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800933:	5b                   	pop    %ebx
  800934:	5e                   	pop    %esi
  800935:	5f                   	pop    %edi
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	83 ec 18             	sub    $0x18,%esp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800944:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800947:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80094b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80094e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800955:	85 c0                	test   %eax,%eax
  800957:	74 26                	je     80097f <vsnprintf+0x47>
  800959:	85 d2                	test   %edx,%edx
  80095b:	7e 22                	jle    80097f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80095d:	ff 75 14             	pushl  0x14(%ebp)
  800960:	ff 75 10             	pushl  0x10(%ebp)
  800963:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800966:	50                   	push   %eax
  800967:	68 e7 02 80 00       	push   $0x8002e7
  80096c:	e8 b0 f9 ff ff       	call   800321 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800971:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800974:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800977:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097a:	83 c4 10             	add    $0x10,%esp
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    
		return -E_INVAL;
  80097f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800984:	eb f7                	jmp    80097d <vsnprintf+0x45>

00800986 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80098c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80098f:	50                   	push   %eax
  800990:	ff 75 10             	pushl  0x10(%ebp)
  800993:	ff 75 0c             	pushl  0xc(%ebp)
  800996:	ff 75 08             	pushl  0x8(%ebp)
  800999:	e8 9a ff ff ff       	call   800938 <vsnprintf>
	va_end(ap);

	return rc;
}
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ab:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009af:	74 05                	je     8009b6 <strlen+0x16>
		n++;
  8009b1:	83 c0 01             	add    $0x1,%eax
  8009b4:	eb f5                	jmp    8009ab <strlen+0xb>
	return n;
}
  8009b6:	5d                   	pop    %ebp
  8009b7:	c3                   	ret    

008009b8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009be:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c6:	39 c2                	cmp    %eax,%edx
  8009c8:	74 0d                	je     8009d7 <strnlen+0x1f>
  8009ca:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009ce:	74 05                	je     8009d5 <strnlen+0x1d>
		n++;
  8009d0:	83 c2 01             	add    $0x1,%edx
  8009d3:	eb f1                	jmp    8009c6 <strnlen+0xe>
  8009d5:	89 d0                	mov    %edx,%eax
	return n;
}
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	53                   	push   %ebx
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e8:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009ec:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009ef:	83 c2 01             	add    $0x1,%edx
  8009f2:	84 c9                	test   %cl,%cl
  8009f4:	75 f2                	jne    8009e8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009f6:	5b                   	pop    %ebx
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	53                   	push   %ebx
  8009fd:	83 ec 10             	sub    $0x10,%esp
  800a00:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a03:	53                   	push   %ebx
  800a04:	e8 97 ff ff ff       	call   8009a0 <strlen>
  800a09:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a0c:	ff 75 0c             	pushl  0xc(%ebp)
  800a0f:	01 d8                	add    %ebx,%eax
  800a11:	50                   	push   %eax
  800a12:	e8 c2 ff ff ff       	call   8009d9 <strcpy>
	return dst;
}
  800a17:	89 d8                	mov    %ebx,%eax
  800a19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a1c:	c9                   	leave  
  800a1d:	c3                   	ret    

00800a1e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a29:	89 c6                	mov    %eax,%esi
  800a2b:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a2e:	89 c2                	mov    %eax,%edx
  800a30:	39 f2                	cmp    %esi,%edx
  800a32:	74 11                	je     800a45 <strncpy+0x27>
		*dst++ = *src;
  800a34:	83 c2 01             	add    $0x1,%edx
  800a37:	0f b6 19             	movzbl (%ecx),%ebx
  800a3a:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a3d:	80 fb 01             	cmp    $0x1,%bl
  800a40:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800a43:	eb eb                	jmp    800a30 <strncpy+0x12>
	}
	return ret;
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
  800a4e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a54:	8b 55 10             	mov    0x10(%ebp),%edx
  800a57:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a59:	85 d2                	test   %edx,%edx
  800a5b:	74 21                	je     800a7e <strlcpy+0x35>
  800a5d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a61:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800a63:	39 c2                	cmp    %eax,%edx
  800a65:	74 14                	je     800a7b <strlcpy+0x32>
  800a67:	0f b6 19             	movzbl (%ecx),%ebx
  800a6a:	84 db                	test   %bl,%bl
  800a6c:	74 0b                	je     800a79 <strlcpy+0x30>
			*dst++ = *src++;
  800a6e:	83 c1 01             	add    $0x1,%ecx
  800a71:	83 c2 01             	add    $0x1,%edx
  800a74:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a77:	eb ea                	jmp    800a63 <strlcpy+0x1a>
  800a79:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a7b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a7e:	29 f0                	sub    %esi,%eax
}
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a8a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a8d:	0f b6 01             	movzbl (%ecx),%eax
  800a90:	84 c0                	test   %al,%al
  800a92:	74 0c                	je     800aa0 <strcmp+0x1c>
  800a94:	3a 02                	cmp    (%edx),%al
  800a96:	75 08                	jne    800aa0 <strcmp+0x1c>
		p++, q++;
  800a98:	83 c1 01             	add    $0x1,%ecx
  800a9b:	83 c2 01             	add    $0x1,%edx
  800a9e:	eb ed                	jmp    800a8d <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa0:	0f b6 c0             	movzbl %al,%eax
  800aa3:	0f b6 12             	movzbl (%edx),%edx
  800aa6:	29 d0                	sub    %edx,%eax
}
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	53                   	push   %ebx
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab4:	89 c3                	mov    %eax,%ebx
  800ab6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ab9:	eb 06                	jmp    800ac1 <strncmp+0x17>
		n--, p++, q++;
  800abb:	83 c0 01             	add    $0x1,%eax
  800abe:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ac1:	39 d8                	cmp    %ebx,%eax
  800ac3:	74 16                	je     800adb <strncmp+0x31>
  800ac5:	0f b6 08             	movzbl (%eax),%ecx
  800ac8:	84 c9                	test   %cl,%cl
  800aca:	74 04                	je     800ad0 <strncmp+0x26>
  800acc:	3a 0a                	cmp    (%edx),%cl
  800ace:	74 eb                	je     800abb <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad0:	0f b6 00             	movzbl (%eax),%eax
  800ad3:	0f b6 12             	movzbl (%edx),%edx
  800ad6:	29 d0                	sub    %edx,%eax
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    
		return 0;
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae0:	eb f6                	jmp    800ad8 <strncmp+0x2e>

00800ae2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aec:	0f b6 10             	movzbl (%eax),%edx
  800aef:	84 d2                	test   %dl,%dl
  800af1:	74 09                	je     800afc <strchr+0x1a>
		if (*s == c)
  800af3:	38 ca                	cmp    %cl,%dl
  800af5:	74 0a                	je     800b01 <strchr+0x1f>
	for (; *s; s++)
  800af7:	83 c0 01             	add    $0x1,%eax
  800afa:	eb f0                	jmp    800aec <strchr+0xa>
			return (char *) s;
	return 0;
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b0d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b10:	38 ca                	cmp    %cl,%dl
  800b12:	74 09                	je     800b1d <strfind+0x1a>
  800b14:	84 d2                	test   %dl,%dl
  800b16:	74 05                	je     800b1d <strfind+0x1a>
	for (; *s; s++)
  800b18:	83 c0 01             	add    $0x1,%eax
  800b1b:	eb f0                	jmp    800b0d <strfind+0xa>
			break;
	return (char *) s;
}
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b28:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b2b:	85 c9                	test   %ecx,%ecx
  800b2d:	74 31                	je     800b60 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b2f:	89 f8                	mov    %edi,%eax
  800b31:	09 c8                	or     %ecx,%eax
  800b33:	a8 03                	test   $0x3,%al
  800b35:	75 23                	jne    800b5a <memset+0x3b>
		c &= 0xFF;
  800b37:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b3b:	89 d3                	mov    %edx,%ebx
  800b3d:	c1 e3 08             	shl    $0x8,%ebx
  800b40:	89 d0                	mov    %edx,%eax
  800b42:	c1 e0 18             	shl    $0x18,%eax
  800b45:	89 d6                	mov    %edx,%esi
  800b47:	c1 e6 10             	shl    $0x10,%esi
  800b4a:	09 f0                	or     %esi,%eax
  800b4c:	09 c2                	or     %eax,%edx
  800b4e:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b50:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b53:	89 d0                	mov    %edx,%eax
  800b55:	fc                   	cld    
  800b56:	f3 ab                	rep stos %eax,%es:(%edi)
  800b58:	eb 06                	jmp    800b60 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5d:	fc                   	cld    
  800b5e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b60:	89 f8                	mov    %edi,%eax
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b72:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b75:	39 c6                	cmp    %eax,%esi
  800b77:	73 32                	jae    800bab <memmove+0x44>
  800b79:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b7c:	39 c2                	cmp    %eax,%edx
  800b7e:	76 2b                	jbe    800bab <memmove+0x44>
		s += n;
		d += n;
  800b80:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b83:	89 fe                	mov    %edi,%esi
  800b85:	09 ce                	or     %ecx,%esi
  800b87:	09 d6                	or     %edx,%esi
  800b89:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b8f:	75 0e                	jne    800b9f <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b91:	83 ef 04             	sub    $0x4,%edi
  800b94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b97:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b9a:	fd                   	std    
  800b9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9d:	eb 09                	jmp    800ba8 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b9f:	83 ef 01             	sub    $0x1,%edi
  800ba2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ba5:	fd                   	std    
  800ba6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ba8:	fc                   	cld    
  800ba9:	eb 1a                	jmp    800bc5 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bab:	89 c2                	mov    %eax,%edx
  800bad:	09 ca                	or     %ecx,%edx
  800baf:	09 f2                	or     %esi,%edx
  800bb1:	f6 c2 03             	test   $0x3,%dl
  800bb4:	75 0a                	jne    800bc0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bb6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bb9:	89 c7                	mov    %eax,%edi
  800bbb:	fc                   	cld    
  800bbc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbe:	eb 05                	jmp    800bc5 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800bc0:	89 c7                	mov    %eax,%edi
  800bc2:	fc                   	cld    
  800bc3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bc5:	5e                   	pop    %esi
  800bc6:	5f                   	pop    %edi
  800bc7:	5d                   	pop    %ebp
  800bc8:	c3                   	ret    

00800bc9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc9:	55                   	push   %ebp
  800bca:	89 e5                	mov    %esp,%ebp
  800bcc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bcf:	ff 75 10             	pushl  0x10(%ebp)
  800bd2:	ff 75 0c             	pushl  0xc(%ebp)
  800bd5:	ff 75 08             	pushl  0x8(%ebp)
  800bd8:	e8 8a ff ff ff       	call   800b67 <memmove>
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	8b 45 08             	mov    0x8(%ebp),%eax
  800be7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bea:	89 c6                	mov    %eax,%esi
  800bec:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bef:	39 f0                	cmp    %esi,%eax
  800bf1:	74 1c                	je     800c0f <memcmp+0x30>
		if (*s1 != *s2)
  800bf3:	0f b6 08             	movzbl (%eax),%ecx
  800bf6:	0f b6 1a             	movzbl (%edx),%ebx
  800bf9:	38 d9                	cmp    %bl,%cl
  800bfb:	75 08                	jne    800c05 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bfd:	83 c0 01             	add    $0x1,%eax
  800c00:	83 c2 01             	add    $0x1,%edx
  800c03:	eb ea                	jmp    800bef <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c05:	0f b6 c1             	movzbl %cl,%eax
  800c08:	0f b6 db             	movzbl %bl,%ebx
  800c0b:	29 d8                	sub    %ebx,%eax
  800c0d:	eb 05                	jmp    800c14 <memcmp+0x35>
	}

	return 0;
  800c0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c21:	89 c2                	mov    %eax,%edx
  800c23:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c26:	39 d0                	cmp    %edx,%eax
  800c28:	73 09                	jae    800c33 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c2a:	38 08                	cmp    %cl,(%eax)
  800c2c:	74 05                	je     800c33 <memfind+0x1b>
	for (; s < ends; s++)
  800c2e:	83 c0 01             	add    $0x1,%eax
  800c31:	eb f3                	jmp    800c26 <memfind+0xe>
			break;
	return (void *) s;
}
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c41:	eb 03                	jmp    800c46 <strtol+0x11>
		s++;
  800c43:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c46:	0f b6 01             	movzbl (%ecx),%eax
  800c49:	3c 20                	cmp    $0x20,%al
  800c4b:	74 f6                	je     800c43 <strtol+0xe>
  800c4d:	3c 09                	cmp    $0x9,%al
  800c4f:	74 f2                	je     800c43 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c51:	3c 2b                	cmp    $0x2b,%al
  800c53:	74 2a                	je     800c7f <strtol+0x4a>
	int neg = 0;
  800c55:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c5a:	3c 2d                	cmp    $0x2d,%al
  800c5c:	74 2b                	je     800c89 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c5e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c64:	75 0f                	jne    800c75 <strtol+0x40>
  800c66:	80 39 30             	cmpb   $0x30,(%ecx)
  800c69:	74 28                	je     800c93 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c6b:	85 db                	test   %ebx,%ebx
  800c6d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c72:	0f 44 d8             	cmove  %eax,%ebx
  800c75:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c7d:	eb 50                	jmp    800ccf <strtol+0x9a>
		s++;
  800c7f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c82:	bf 00 00 00 00       	mov    $0x0,%edi
  800c87:	eb d5                	jmp    800c5e <strtol+0x29>
		s++, neg = 1;
  800c89:	83 c1 01             	add    $0x1,%ecx
  800c8c:	bf 01 00 00 00       	mov    $0x1,%edi
  800c91:	eb cb                	jmp    800c5e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c93:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c97:	74 0e                	je     800ca7 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c99:	85 db                	test   %ebx,%ebx
  800c9b:	75 d8                	jne    800c75 <strtol+0x40>
		s++, base = 8;
  800c9d:	83 c1 01             	add    $0x1,%ecx
  800ca0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ca5:	eb ce                	jmp    800c75 <strtol+0x40>
		s += 2, base = 16;
  800ca7:	83 c1 02             	add    $0x2,%ecx
  800caa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800caf:	eb c4                	jmp    800c75 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cb1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cb4:	89 f3                	mov    %esi,%ebx
  800cb6:	80 fb 19             	cmp    $0x19,%bl
  800cb9:	77 29                	ja     800ce4 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800cbb:	0f be d2             	movsbl %dl,%edx
  800cbe:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cc1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cc4:	7d 30                	jge    800cf6 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800cc6:	83 c1 01             	add    $0x1,%ecx
  800cc9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ccd:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ccf:	0f b6 11             	movzbl (%ecx),%edx
  800cd2:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cd5:	89 f3                	mov    %esi,%ebx
  800cd7:	80 fb 09             	cmp    $0x9,%bl
  800cda:	77 d5                	ja     800cb1 <strtol+0x7c>
			dig = *s - '0';
  800cdc:	0f be d2             	movsbl %dl,%edx
  800cdf:	83 ea 30             	sub    $0x30,%edx
  800ce2:	eb dd                	jmp    800cc1 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800ce4:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ce7:	89 f3                	mov    %esi,%ebx
  800ce9:	80 fb 19             	cmp    $0x19,%bl
  800cec:	77 08                	ja     800cf6 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800cee:	0f be d2             	movsbl %dl,%edx
  800cf1:	83 ea 37             	sub    $0x37,%edx
  800cf4:	eb cb                	jmp    800cc1 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cf6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cfa:	74 05                	je     800d01 <strtol+0xcc>
		*endptr = (char *) s;
  800cfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cff:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d01:	89 c2                	mov    %eax,%edx
  800d03:	f7 da                	neg    %edx
  800d05:	85 ff                	test   %edi,%edi
  800d07:	0f 45 c2             	cmovne %edx,%eax
}
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d15:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d20:	89 c3                	mov    %eax,%ebx
  800d22:	89 c7                	mov    %eax,%edi
  800d24:	89 c6                	mov    %eax,%esi
  800d26:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d28:	5b                   	pop    %ebx
  800d29:	5e                   	pop    %esi
  800d2a:	5f                   	pop    %edi
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    

00800d2d <sys_cgetc>:

int
sys_cgetc(void)
{
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d33:	ba 00 00 00 00       	mov    $0x0,%edx
  800d38:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3d:	89 d1                	mov    %edx,%ecx
  800d3f:	89 d3                	mov    %edx,%ebx
  800d41:	89 d7                	mov    %edx,%edi
  800d43:	89 d6                	mov    %edx,%esi
  800d45:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	b8 03 00 00 00       	mov    $0x3,%eax
  800d62:	89 cb                	mov    %ecx,%ebx
  800d64:	89 cf                	mov    %ecx,%edi
  800d66:	89 ce                	mov    %ecx,%esi
  800d68:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	7f 08                	jg     800d76 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	50                   	push   %eax
  800d7a:	6a 03                	push   $0x3
  800d7c:	68 64 15 80 00       	push   $0x801564
  800d81:	6a 23                	push   $0x23
  800d83:	68 81 15 80 00       	push   $0x801581
  800d88:	e8 2e 02 00 00       	call   800fbb <_panic>

00800d8d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d93:	ba 00 00 00 00       	mov    $0x0,%edx
  800d98:	b8 02 00 00 00       	mov    $0x2,%eax
  800d9d:	89 d1                	mov    %edx,%ecx
  800d9f:	89 d3                	mov    %edx,%ebx
  800da1:	89 d7                	mov    %edx,%edi
  800da3:	89 d6                	mov    %edx,%esi
  800da5:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_yield>:

void
sys_yield(void)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800db2:	ba 00 00 00 00       	mov    $0x0,%edx
  800db7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dbc:	89 d1                	mov    %edx,%ecx
  800dbe:	89 d3                	mov    %edx,%ebx
  800dc0:	89 d7                	mov    %edx,%edi
  800dc2:	89 d6                	mov    %edx,%esi
  800dc4:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd4:	be 00 00 00 00       	mov    $0x0,%esi
  800dd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddf:	b8 04 00 00 00       	mov    $0x4,%eax
  800de4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de7:	89 f7                	mov    %esi,%edi
  800de9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7f 08                	jg     800df7 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800def:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df2:	5b                   	pop    %ebx
  800df3:	5e                   	pop    %esi
  800df4:	5f                   	pop    %edi
  800df5:	5d                   	pop    %ebp
  800df6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df7:	83 ec 0c             	sub    $0xc,%esp
  800dfa:	50                   	push   %eax
  800dfb:	6a 04                	push   $0x4
  800dfd:	68 64 15 80 00       	push   $0x801564
  800e02:	6a 23                	push   $0x23
  800e04:	68 81 15 80 00       	push   $0x801581
  800e09:	e8 ad 01 00 00       	call   800fbb <_panic>

00800e0e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e17:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1d:	b8 05 00 00 00       	mov    $0x5,%eax
  800e22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e25:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e28:	8b 75 18             	mov    0x18(%ebp),%esi
  800e2b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e2d:	85 c0                	test   %eax,%eax
  800e2f:	7f 08                	jg     800e39 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	83 ec 0c             	sub    $0xc,%esp
  800e3c:	50                   	push   %eax
  800e3d:	6a 05                	push   $0x5
  800e3f:	68 64 15 80 00       	push   $0x801564
  800e44:	6a 23                	push   $0x23
  800e46:	68 81 15 80 00       	push   $0x801581
  800e4b:	e8 6b 01 00 00       	call   800fbb <_panic>

00800e50 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
  800e56:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e59:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e64:	b8 06 00 00 00       	mov    $0x6,%eax
  800e69:	89 df                	mov    %ebx,%edi
  800e6b:	89 de                	mov    %ebx,%esi
  800e6d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	7f 08                	jg     800e7b <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e76:	5b                   	pop    %ebx
  800e77:	5e                   	pop    %esi
  800e78:	5f                   	pop    %edi
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7b:	83 ec 0c             	sub    $0xc,%esp
  800e7e:	50                   	push   %eax
  800e7f:	6a 06                	push   $0x6
  800e81:	68 64 15 80 00       	push   $0x801564
  800e86:	6a 23                	push   $0x23
  800e88:	68 81 15 80 00       	push   $0x801581
  800e8d:	e8 29 01 00 00       	call   800fbb <_panic>

00800e92 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea6:	b8 08 00 00 00       	mov    $0x8,%eax
  800eab:	89 df                	mov    %ebx,%edi
  800ead:	89 de                	mov    %ebx,%esi
  800eaf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	7f 08                	jg     800ebd <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800eb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb8:	5b                   	pop    %ebx
  800eb9:	5e                   	pop    %esi
  800eba:	5f                   	pop    %edi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	83 ec 0c             	sub    $0xc,%esp
  800ec0:	50                   	push   %eax
  800ec1:	6a 08                	push   $0x8
  800ec3:	68 64 15 80 00       	push   $0x801564
  800ec8:	6a 23                	push   $0x23
  800eca:	68 81 15 80 00       	push   $0x801581
  800ecf:	e8 e7 00 00 00       	call   800fbb <_panic>

00800ed4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800edd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee8:	b8 09 00 00 00       	mov    $0x9,%eax
  800eed:	89 df                	mov    %ebx,%edi
  800eef:	89 de                	mov    %ebx,%esi
  800ef1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	7f 08                	jg     800eff <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ef7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800efa:	5b                   	pop    %ebx
  800efb:	5e                   	pop    %esi
  800efc:	5f                   	pop    %edi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	50                   	push   %eax
  800f03:	6a 09                	push   $0x9
  800f05:	68 64 15 80 00       	push   $0x801564
  800f0a:	6a 23                	push   $0x23
  800f0c:	68 81 15 80 00       	push   $0x801581
  800f11:	e8 a5 00 00 00       	call   800fbb <_panic>

00800f16 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f22:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f27:	be 00 00 00 00       	mov    $0x0,%esi
  800f2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f32:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	57                   	push   %edi
  800f3d:	56                   	push   %esi
  800f3e:	53                   	push   %ebx
  800f3f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f47:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f4f:	89 cb                	mov    %ecx,%ebx
  800f51:	89 cf                	mov    %ecx,%edi
  800f53:	89 ce                	mov    %ecx,%esi
  800f55:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f57:	85 c0                	test   %eax,%eax
  800f59:	7f 08                	jg     800f63 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f63:	83 ec 0c             	sub    $0xc,%esp
  800f66:	50                   	push   %eax
  800f67:	6a 0c                	push   $0xc
  800f69:	68 64 15 80 00       	push   $0x801564
  800f6e:	6a 23                	push   $0x23
  800f70:	68 81 15 80 00       	push   $0x801581
  800f75:	e8 41 00 00 00       	call   800fbb <_panic>

00800f7a <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	57                   	push   %edi
  800f7e:	56                   	push   %esi
  800f7f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f85:	8b 55 08             	mov    0x8(%ebp),%edx
  800f88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f90:	89 df                	mov    %ebx,%edi
  800f92:	89 de                	mov    %ebx,%esi
  800f94:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f96:	5b                   	pop    %ebx
  800f97:	5e                   	pop    %esi
  800f98:	5f                   	pop    %edi
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fa1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa6:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa9:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fae:	89 cb                	mov    %ecx,%ebx
  800fb0:	89 cf                	mov    %ecx,%edi
  800fb2:	89 ce                	mov    %ecx,%esi
  800fb4:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800fb6:	5b                   	pop    %ebx
  800fb7:	5e                   	pop    %esi
  800fb8:	5f                   	pop    %edi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fc0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fc3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800fc9:	e8 bf fd ff ff       	call   800d8d <sys_getenvid>
  800fce:	83 ec 0c             	sub    $0xc,%esp
  800fd1:	ff 75 0c             	pushl  0xc(%ebp)
  800fd4:	ff 75 08             	pushl  0x8(%ebp)
  800fd7:	56                   	push   %esi
  800fd8:	50                   	push   %eax
  800fd9:	68 90 15 80 00       	push   $0x801590
  800fde:	e8 60 f2 ff ff       	call   800243 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fe3:	83 c4 18             	add    $0x18,%esp
  800fe6:	53                   	push   %ebx
  800fe7:	ff 75 10             	pushl  0x10(%ebp)
  800fea:	e8 03 f2 ff ff       	call   8001f2 <vcprintf>
	cprintf("\n");
  800fef:	c7 04 24 b4 15 80 00 	movl   $0x8015b4,(%esp)
  800ff6:	e8 48 f2 ff ff       	call   800243 <cprintf>
  800ffb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ffe:	cc                   	int3   
  800fff:	eb fd                	jmp    800ffe <_panic+0x43>
  801001:	66 90                	xchg   %ax,%ax
  801003:	66 90                	xchg   %ax,%ax
  801005:	66 90                	xchg   %ax,%ax
  801007:	66 90                	xchg   %ax,%ax
  801009:	66 90                	xchg   %ax,%ax
  80100b:	66 90                	xchg   %ax,%ax
  80100d:	66 90                	xchg   %ax,%ax
  80100f:	90                   	nop

00801010 <__udivdi3>:
  801010:	55                   	push   %ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	83 ec 1c             	sub    $0x1c,%esp
  801017:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80101b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80101f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801023:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801027:	85 d2                	test   %edx,%edx
  801029:	75 4d                	jne    801078 <__udivdi3+0x68>
  80102b:	39 f3                	cmp    %esi,%ebx
  80102d:	76 19                	jbe    801048 <__udivdi3+0x38>
  80102f:	31 ff                	xor    %edi,%edi
  801031:	89 e8                	mov    %ebp,%eax
  801033:	89 f2                	mov    %esi,%edx
  801035:	f7 f3                	div    %ebx
  801037:	89 fa                	mov    %edi,%edx
  801039:	83 c4 1c             	add    $0x1c,%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    
  801041:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801048:	89 d9                	mov    %ebx,%ecx
  80104a:	85 db                	test   %ebx,%ebx
  80104c:	75 0b                	jne    801059 <__udivdi3+0x49>
  80104e:	b8 01 00 00 00       	mov    $0x1,%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	f7 f3                	div    %ebx
  801057:	89 c1                	mov    %eax,%ecx
  801059:	31 d2                	xor    %edx,%edx
  80105b:	89 f0                	mov    %esi,%eax
  80105d:	f7 f1                	div    %ecx
  80105f:	89 c6                	mov    %eax,%esi
  801061:	89 e8                	mov    %ebp,%eax
  801063:	89 f7                	mov    %esi,%edi
  801065:	f7 f1                	div    %ecx
  801067:	89 fa                	mov    %edi,%edx
  801069:	83 c4 1c             	add    $0x1c,%esp
  80106c:	5b                   	pop    %ebx
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    
  801071:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801078:	39 f2                	cmp    %esi,%edx
  80107a:	77 1c                	ja     801098 <__udivdi3+0x88>
  80107c:	0f bd fa             	bsr    %edx,%edi
  80107f:	83 f7 1f             	xor    $0x1f,%edi
  801082:	75 2c                	jne    8010b0 <__udivdi3+0xa0>
  801084:	39 f2                	cmp    %esi,%edx
  801086:	72 06                	jb     80108e <__udivdi3+0x7e>
  801088:	31 c0                	xor    %eax,%eax
  80108a:	39 eb                	cmp    %ebp,%ebx
  80108c:	77 a9                	ja     801037 <__udivdi3+0x27>
  80108e:	b8 01 00 00 00       	mov    $0x1,%eax
  801093:	eb a2                	jmp    801037 <__udivdi3+0x27>
  801095:	8d 76 00             	lea    0x0(%esi),%esi
  801098:	31 ff                	xor    %edi,%edi
  80109a:	31 c0                	xor    %eax,%eax
  80109c:	89 fa                	mov    %edi,%edx
  80109e:	83 c4 1c             	add    $0x1c,%esp
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5f                   	pop    %edi
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    
  8010a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010ad:	8d 76 00             	lea    0x0(%esi),%esi
  8010b0:	89 f9                	mov    %edi,%ecx
  8010b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8010b7:	29 f8                	sub    %edi,%eax
  8010b9:	d3 e2                	shl    %cl,%edx
  8010bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8010bf:	89 c1                	mov    %eax,%ecx
  8010c1:	89 da                	mov    %ebx,%edx
  8010c3:	d3 ea                	shr    %cl,%edx
  8010c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010c9:	09 d1                	or     %edx,%ecx
  8010cb:	89 f2                	mov    %esi,%edx
  8010cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010d1:	89 f9                	mov    %edi,%ecx
  8010d3:	d3 e3                	shl    %cl,%ebx
  8010d5:	89 c1                	mov    %eax,%ecx
  8010d7:	d3 ea                	shr    %cl,%edx
  8010d9:	89 f9                	mov    %edi,%ecx
  8010db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010df:	89 eb                	mov    %ebp,%ebx
  8010e1:	d3 e6                	shl    %cl,%esi
  8010e3:	89 c1                	mov    %eax,%ecx
  8010e5:	d3 eb                	shr    %cl,%ebx
  8010e7:	09 de                	or     %ebx,%esi
  8010e9:	89 f0                	mov    %esi,%eax
  8010eb:	f7 74 24 08          	divl   0x8(%esp)
  8010ef:	89 d6                	mov    %edx,%esi
  8010f1:	89 c3                	mov    %eax,%ebx
  8010f3:	f7 64 24 0c          	mull   0xc(%esp)
  8010f7:	39 d6                	cmp    %edx,%esi
  8010f9:	72 15                	jb     801110 <__udivdi3+0x100>
  8010fb:	89 f9                	mov    %edi,%ecx
  8010fd:	d3 e5                	shl    %cl,%ebp
  8010ff:	39 c5                	cmp    %eax,%ebp
  801101:	73 04                	jae    801107 <__udivdi3+0xf7>
  801103:	39 d6                	cmp    %edx,%esi
  801105:	74 09                	je     801110 <__udivdi3+0x100>
  801107:	89 d8                	mov    %ebx,%eax
  801109:	31 ff                	xor    %edi,%edi
  80110b:	e9 27 ff ff ff       	jmp    801037 <__udivdi3+0x27>
  801110:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801113:	31 ff                	xor    %edi,%edi
  801115:	e9 1d ff ff ff       	jmp    801037 <__udivdi3+0x27>
  80111a:	66 90                	xchg   %ax,%ax
  80111c:	66 90                	xchg   %ax,%ax
  80111e:	66 90                	xchg   %ax,%ax

00801120 <__umoddi3>:
  801120:	55                   	push   %ebp
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	53                   	push   %ebx
  801124:	83 ec 1c             	sub    $0x1c,%esp
  801127:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80112b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80112f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801137:	89 da                	mov    %ebx,%edx
  801139:	85 c0                	test   %eax,%eax
  80113b:	75 43                	jne    801180 <__umoddi3+0x60>
  80113d:	39 df                	cmp    %ebx,%edi
  80113f:	76 17                	jbe    801158 <__umoddi3+0x38>
  801141:	89 f0                	mov    %esi,%eax
  801143:	f7 f7                	div    %edi
  801145:	89 d0                	mov    %edx,%eax
  801147:	31 d2                	xor    %edx,%edx
  801149:	83 c4 1c             	add    $0x1c,%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    
  801151:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801158:	89 fd                	mov    %edi,%ebp
  80115a:	85 ff                	test   %edi,%edi
  80115c:	75 0b                	jne    801169 <__umoddi3+0x49>
  80115e:	b8 01 00 00 00       	mov    $0x1,%eax
  801163:	31 d2                	xor    %edx,%edx
  801165:	f7 f7                	div    %edi
  801167:	89 c5                	mov    %eax,%ebp
  801169:	89 d8                	mov    %ebx,%eax
  80116b:	31 d2                	xor    %edx,%edx
  80116d:	f7 f5                	div    %ebp
  80116f:	89 f0                	mov    %esi,%eax
  801171:	f7 f5                	div    %ebp
  801173:	89 d0                	mov    %edx,%eax
  801175:	eb d0                	jmp    801147 <__umoddi3+0x27>
  801177:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80117e:	66 90                	xchg   %ax,%ax
  801180:	89 f1                	mov    %esi,%ecx
  801182:	39 d8                	cmp    %ebx,%eax
  801184:	76 0a                	jbe    801190 <__umoddi3+0x70>
  801186:	89 f0                	mov    %esi,%eax
  801188:	83 c4 1c             	add    $0x1c,%esp
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    
  801190:	0f bd e8             	bsr    %eax,%ebp
  801193:	83 f5 1f             	xor    $0x1f,%ebp
  801196:	75 20                	jne    8011b8 <__umoddi3+0x98>
  801198:	39 d8                	cmp    %ebx,%eax
  80119a:	0f 82 b0 00 00 00    	jb     801250 <__umoddi3+0x130>
  8011a0:	39 f7                	cmp    %esi,%edi
  8011a2:	0f 86 a8 00 00 00    	jbe    801250 <__umoddi3+0x130>
  8011a8:	89 c8                	mov    %ecx,%eax
  8011aa:	83 c4 1c             	add    $0x1c,%esp
  8011ad:	5b                   	pop    %ebx
  8011ae:	5e                   	pop    %esi
  8011af:	5f                   	pop    %edi
  8011b0:	5d                   	pop    %ebp
  8011b1:	c3                   	ret    
  8011b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011b8:	89 e9                	mov    %ebp,%ecx
  8011ba:	ba 20 00 00 00       	mov    $0x20,%edx
  8011bf:	29 ea                	sub    %ebp,%edx
  8011c1:	d3 e0                	shl    %cl,%eax
  8011c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c7:	89 d1                	mov    %edx,%ecx
  8011c9:	89 f8                	mov    %edi,%eax
  8011cb:	d3 e8                	shr    %cl,%eax
  8011cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8011d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011d5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8011d9:	09 c1                	or     %eax,%ecx
  8011db:	89 d8                	mov    %ebx,%eax
  8011dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011e1:	89 e9                	mov    %ebp,%ecx
  8011e3:	d3 e7                	shl    %cl,%edi
  8011e5:	89 d1                	mov    %edx,%ecx
  8011e7:	d3 e8                	shr    %cl,%eax
  8011e9:	89 e9                	mov    %ebp,%ecx
  8011eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011ef:	d3 e3                	shl    %cl,%ebx
  8011f1:	89 c7                	mov    %eax,%edi
  8011f3:	89 d1                	mov    %edx,%ecx
  8011f5:	89 f0                	mov    %esi,%eax
  8011f7:	d3 e8                	shr    %cl,%eax
  8011f9:	89 e9                	mov    %ebp,%ecx
  8011fb:	89 fa                	mov    %edi,%edx
  8011fd:	d3 e6                	shl    %cl,%esi
  8011ff:	09 d8                	or     %ebx,%eax
  801201:	f7 74 24 08          	divl   0x8(%esp)
  801205:	89 d1                	mov    %edx,%ecx
  801207:	89 f3                	mov    %esi,%ebx
  801209:	f7 64 24 0c          	mull   0xc(%esp)
  80120d:	89 c6                	mov    %eax,%esi
  80120f:	89 d7                	mov    %edx,%edi
  801211:	39 d1                	cmp    %edx,%ecx
  801213:	72 06                	jb     80121b <__umoddi3+0xfb>
  801215:	75 10                	jne    801227 <__umoddi3+0x107>
  801217:	39 c3                	cmp    %eax,%ebx
  801219:	73 0c                	jae    801227 <__umoddi3+0x107>
  80121b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80121f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801223:	89 d7                	mov    %edx,%edi
  801225:	89 c6                	mov    %eax,%esi
  801227:	89 ca                	mov    %ecx,%edx
  801229:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80122e:	29 f3                	sub    %esi,%ebx
  801230:	19 fa                	sbb    %edi,%edx
  801232:	89 d0                	mov    %edx,%eax
  801234:	d3 e0                	shl    %cl,%eax
  801236:	89 e9                	mov    %ebp,%ecx
  801238:	d3 eb                	shr    %cl,%ebx
  80123a:	d3 ea                	shr    %cl,%edx
  80123c:	09 d8                	or     %ebx,%eax
  80123e:	83 c4 1c             	add    $0x1c,%esp
  801241:	5b                   	pop    %ebx
  801242:	5e                   	pop    %esi
  801243:	5f                   	pop    %edi
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    
  801246:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80124d:	8d 76 00             	lea    0x0(%esi),%esi
  801250:	89 da                	mov    %ebx,%edx
  801252:	29 fe                	sub    %edi,%esi
  801254:	19 c2                	sbb    %eax,%edx
  801256:	89 f1                	mov    %esi,%ecx
  801258:	89 c8                	mov    %ecx,%eax
  80125a:	e9 4b ff ff ff       	jmp    8011aa <__umoddi3+0x8a>
