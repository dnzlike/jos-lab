
obj/user/faultalloc:     file format elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 60 12 80 00       	push   $0x801260
  800045:	e8 b3 01 00 00       	call   8001fd <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 27 0d 00 00       	call   800d85 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 ac 12 80 00       	push   $0x8012ac
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 cd 08 00 00       	call   800940 <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 80 12 80 00       	push   $0x801280
  800085:	6a 0e                	push   $0xe
  800087:	68 6a 12 80 00       	push   $0x80126a
  80008c:	e8 91 00 00 00       	call   800122 <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 d4 0e 00 00       	call   800f75 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 7c 12 80 00       	push   $0x80127c
  8000ae:	e8 4a 01 00 00       	call   8001fd <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 7c 12 80 00       	push   $0x80127c
  8000c0:	e8 38 01 00 00       	call   8001fd <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 6d 0c 00 00       	call   800d47 <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	c1 e0 07             	shl    $0x7,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800116:	6a 00                	push   $0x0
  800118:	e8 e9 0b 00 00       	call   800d06 <sys_env_destroy>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800127:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800130:	e8 12 0c 00 00       	call   800d47 <sys_getenvid>
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	ff 75 0c             	pushl  0xc(%ebp)
  80013b:	ff 75 08             	pushl  0x8(%ebp)
  80013e:	56                   	push   %esi
  80013f:	50                   	push   %eax
  800140:	68 d8 12 80 00       	push   $0x8012d8
  800145:	e8 b3 00 00 00       	call   8001fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014a:	83 c4 18             	add    $0x18,%esp
  80014d:	53                   	push   %ebx
  80014e:	ff 75 10             	pushl  0x10(%ebp)
  800151:	e8 56 00 00 00       	call   8001ac <vcprintf>
	cprintf("\n");
  800156:	c7 04 24 7e 12 80 00 	movl   $0x80127e,(%esp)
  80015d:	e8 9b 00 00 00       	call   8001fd <cprintf>
  800162:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800165:	cc                   	int3   
  800166:	eb fd                	jmp    800165 <_panic+0x43>

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 13                	mov    (%ebx),%edx
  800174:	8d 42 01             	lea    0x1(%edx),%eax
  800177:	89 03                	mov    %eax,(%ebx)
  800179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800180:	3d ff 00 00 00       	cmp    $0xff,%eax
  800185:	74 09                	je     800190 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800187:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800190:	83 ec 08             	sub    $0x8,%esp
  800193:	68 ff 00 00 00       	push   $0xff
  800198:	8d 43 08             	lea    0x8(%ebx),%eax
  80019b:	50                   	push   %eax
  80019c:	e8 28 0b 00 00       	call   800cc9 <sys_cputs>
		b->idx = 0;
  8001a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	eb db                	jmp    800187 <putch+0x1f>

008001ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bc:	00 00 00 
	b.cnt = 0;
  8001bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c9:	ff 75 0c             	pushl  0xc(%ebp)
  8001cc:	ff 75 08             	pushl  0x8(%ebp)
  8001cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d5:	50                   	push   %eax
  8001d6:	68 68 01 80 00       	push   $0x800168
  8001db:	e8 fb 00 00 00       	call   8002db <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e0:	83 c4 08             	add    $0x8,%esp
  8001e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	e8 d4 0a 00 00       	call   800cc9 <sys_cputs>

	return b.cnt;
}
  8001f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800203:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800206:	50                   	push   %eax
  800207:	ff 75 08             	pushl  0x8(%ebp)
  80020a:	e8 9d ff ff ff       	call   8001ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	57                   	push   %edi
  800215:	56                   	push   %esi
  800216:	53                   	push   %ebx
  800217:	83 ec 1c             	sub    $0x1c,%esp
  80021a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80021d:	89 d3                	mov    %edx,%ebx
  80021f:	8b 75 08             	mov    0x8(%ebp),%esi
  800222:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800225:	8b 45 10             	mov    0x10(%ebp),%eax
  800228:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  80022b:	89 c2                	mov    %eax,%edx
  80022d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800232:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800235:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800238:	39 c6                	cmp    %eax,%esi
  80023a:	89 f8                	mov    %edi,%eax
  80023c:	19 c8                	sbb    %ecx,%eax
  80023e:	73 32                	jae    800272 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800240:	83 ec 08             	sub    $0x8,%esp
  800243:	53                   	push   %ebx
  800244:	83 ec 04             	sub    $0x4,%esp
  800247:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024a:	ff 75 e0             	pushl  -0x20(%ebp)
  80024d:	57                   	push   %edi
  80024e:	56                   	push   %esi
  80024f:	e8 cc 0e 00 00       	call   801120 <__umoddi3>
  800254:	83 c4 14             	add    $0x14,%esp
  800257:	0f be 80 fb 12 80 00 	movsbl 0x8012fb(%eax),%eax
  80025e:	50                   	push   %eax
  80025f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800262:	ff d0                	call   *%eax
	return remain - 1;
  800264:	8b 45 14             	mov    0x14(%ebp),%eax
  800267:	83 e8 01             	sub    $0x1,%eax
}
  80026a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026d:	5b                   	pop    %ebx
  80026e:	5e                   	pop    %esi
  80026f:	5f                   	pop    %edi
  800270:	5d                   	pop    %ebp
  800271:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  800272:	83 ec 0c             	sub    $0xc,%esp
  800275:	ff 75 18             	pushl  0x18(%ebp)
  800278:	ff 75 14             	pushl  0x14(%ebp)
  80027b:	ff 75 d8             	pushl  -0x28(%ebp)
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	51                   	push   %ecx
  800282:	52                   	push   %edx
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	e8 86 0d 00 00       	call   801010 <__udivdi3>
  80028a:	83 c4 18             	add    $0x18,%esp
  80028d:	52                   	push   %edx
  80028e:	50                   	push   %eax
  80028f:	89 da                	mov    %ebx,%edx
  800291:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800294:	e8 78 ff ff ff       	call   800211 <printnum_helper>
  800299:	89 45 14             	mov    %eax,0x14(%ebp)
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 9f                	jmp    800240 <printnum_helper+0x2f>

008002a1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002a7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ab:	8b 10                	mov    (%eax),%edx
  8002ad:	3b 50 04             	cmp    0x4(%eax),%edx
  8002b0:	73 0a                	jae    8002bc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002b2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ba:	88 02                	mov    %al,(%edx)
}
  8002bc:	5d                   	pop    %ebp
  8002bd:	c3                   	ret    

008002be <printfmt>:
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002c4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002c7:	50                   	push   %eax
  8002c8:	ff 75 10             	pushl  0x10(%ebp)
  8002cb:	ff 75 0c             	pushl  0xc(%ebp)
  8002ce:	ff 75 08             	pushl  0x8(%ebp)
  8002d1:	e8 05 00 00 00       	call   8002db <vprintfmt>
}
  8002d6:	83 c4 10             	add    $0x10,%esp
  8002d9:	c9                   	leave  
  8002da:	c3                   	ret    

008002db <vprintfmt>:
{
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	57                   	push   %edi
  8002df:	56                   	push   %esi
  8002e0:	53                   	push   %ebx
  8002e1:	83 ec 3c             	sub    $0x3c,%esp
  8002e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002ea:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ed:	e9 3f 05 00 00       	jmp    800831 <vprintfmt+0x556>
		padc = ' ';
  8002f2:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  8002f6:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  8002fd:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800304:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  80030b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  800312:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800319:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8d 47 01             	lea    0x1(%edi),%eax
  800321:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800324:	0f b6 17             	movzbl (%edi),%edx
  800327:	8d 42 dd             	lea    -0x23(%edx),%eax
  80032a:	3c 55                	cmp    $0x55,%al
  80032c:	0f 87 98 05 00 00    	ja     8008ca <vprintfmt+0x5ef>
  800332:	0f b6 c0             	movzbl %al,%eax
  800335:	ff 24 85 40 14 80 00 	jmp    *0x801440(,%eax,4)
  80033c:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  80033f:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  800343:	eb d9                	jmp    80031e <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800345:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800348:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  80034f:	eb cd                	jmp    80031e <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800351:	0f b6 d2             	movzbl %dl,%edx
  800354:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800357:	b8 00 00 00 00       	mov    $0x0,%eax
  80035c:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  80035f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800362:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800366:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800369:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80036c:	83 fb 09             	cmp    $0x9,%ebx
  80036f:	77 5c                	ja     8003cd <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  800371:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800374:	eb e9                	jmp    80035f <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  800376:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  800379:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  80037d:	eb 9f                	jmp    80031e <vprintfmt+0x43>
			precision = va_arg(ap, int);
  80037f:	8b 45 14             	mov    0x14(%ebp),%eax
  800382:	8b 00                	mov    (%eax),%eax
  800384:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800387:	8b 45 14             	mov    0x14(%ebp),%eax
  80038a:	8d 40 04             	lea    0x4(%eax),%eax
  80038d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  800393:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800397:	79 85                	jns    80031e <vprintfmt+0x43>
				width = precision, precision = -1;
  800399:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003a6:	e9 73 ff ff ff       	jmp    80031e <vprintfmt+0x43>
  8003ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003ae:	85 c0                	test   %eax,%eax
  8003b0:	0f 48 c1             	cmovs  %ecx,%eax
  8003b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8003b9:	e9 60 ff ff ff       	jmp    80031e <vprintfmt+0x43>
  8003be:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8003c1:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8003c8:	e9 51 ff ff ff       	jmp    80031e <vprintfmt+0x43>
  8003cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003d3:	eb be                	jmp    800393 <vprintfmt+0xb8>
			lflag++;
  8003d5:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  8003dc:	e9 3d ff ff ff       	jmp    80031e <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8d 78 04             	lea    0x4(%eax),%edi
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	56                   	push   %esi
  8003eb:	ff 30                	pushl  (%eax)
  8003ed:	ff d3                	call   *%ebx
			break;
  8003ef:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003f2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003f5:	e9 34 04 00 00       	jmp    80082e <vprintfmt+0x553>
			err = va_arg(ap, int);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 78 04             	lea    0x4(%eax),%edi
  800400:	8b 00                	mov    (%eax),%eax
  800402:	99                   	cltd   
  800403:	31 d0                	xor    %edx,%eax
  800405:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800407:	83 f8 08             	cmp    $0x8,%eax
  80040a:	7f 23                	jg     80042f <vprintfmt+0x154>
  80040c:	8b 14 85 a0 15 80 00 	mov    0x8015a0(,%eax,4),%edx
  800413:	85 d2                	test   %edx,%edx
  800415:	74 18                	je     80042f <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800417:	52                   	push   %edx
  800418:	68 1c 13 80 00       	push   $0x80131c
  80041d:	56                   	push   %esi
  80041e:	53                   	push   %ebx
  80041f:	e8 9a fe ff ff       	call   8002be <printfmt>
  800424:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800427:	89 7d 14             	mov    %edi,0x14(%ebp)
  80042a:	e9 ff 03 00 00       	jmp    80082e <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  80042f:	50                   	push   %eax
  800430:	68 13 13 80 00       	push   $0x801313
  800435:	56                   	push   %esi
  800436:	53                   	push   %ebx
  800437:	e8 82 fe ff ff       	call   8002be <printfmt>
  80043c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800442:	e9 e7 03 00 00       	jmp    80082e <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  800447:	8b 45 14             	mov    0x14(%ebp),%eax
  80044a:	83 c0 04             	add    $0x4,%eax
  80044d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800455:	85 c9                	test   %ecx,%ecx
  800457:	b8 0c 13 80 00       	mov    $0x80130c,%eax
  80045c:	0f 45 c1             	cmovne %ecx,%eax
  80045f:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800462:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800466:	7e 06                	jle    80046e <vprintfmt+0x193>
  800468:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  80046c:	75 0d                	jne    80047b <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800471:	89 c7                	mov    %eax,%edi
  800473:	03 45 d8             	add    -0x28(%ebp),%eax
  800476:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800479:	eb 53                	jmp    8004ce <vprintfmt+0x1f3>
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	ff 75 e0             	pushl  -0x20(%ebp)
  800481:	50                   	push   %eax
  800482:	e8 eb 04 00 00       	call   800972 <strnlen>
  800487:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80048a:	29 c1                	sub    %eax,%ecx
  80048c:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800494:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  800498:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	eb 0f                	jmp    8004ac <vprintfmt+0x1d1>
					putch(padc, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	56                   	push   %esi
  8004a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a4:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	83 ef 01             	sub    $0x1,%edi
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	7f ed                	jg     80049d <vprintfmt+0x1c2>
  8004b0:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8004b3:	85 c9                	test   %ecx,%ecx
  8004b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ba:	0f 49 c1             	cmovns %ecx,%eax
  8004bd:	29 c1                	sub    %eax,%ecx
  8004bf:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8004c2:	eb aa                	jmp    80046e <vprintfmt+0x193>
					putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	56                   	push   %esi
  8004c8:	52                   	push   %edx
  8004c9:	ff d3                	call   *%ebx
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8004d1:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d3:	83 c7 01             	add    $0x1,%edi
  8004d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004da:	0f be d0             	movsbl %al,%edx
  8004dd:	85 d2                	test   %edx,%edx
  8004df:	74 2e                	je     80050f <vprintfmt+0x234>
  8004e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e5:	78 06                	js     8004ed <vprintfmt+0x212>
  8004e7:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004eb:	78 1e                	js     80050b <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ed:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004f1:	74 d1                	je     8004c4 <vprintfmt+0x1e9>
  8004f3:	0f be c0             	movsbl %al,%eax
  8004f6:	83 e8 20             	sub    $0x20,%eax
  8004f9:	83 f8 5e             	cmp    $0x5e,%eax
  8004fc:	76 c6                	jbe    8004c4 <vprintfmt+0x1e9>
					putch('?', putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	56                   	push   %esi
  800502:	6a 3f                	push   $0x3f
  800504:	ff d3                	call   *%ebx
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	eb c3                	jmp    8004ce <vprintfmt+0x1f3>
  80050b:	89 cf                	mov    %ecx,%edi
  80050d:	eb 02                	jmp    800511 <vprintfmt+0x236>
  80050f:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  800511:	85 ff                	test   %edi,%edi
  800513:	7e 10                	jle    800525 <vprintfmt+0x24a>
				putch(' ', putdat);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	56                   	push   %esi
  800519:	6a 20                	push   $0x20
  80051b:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80051d:	83 ef 01             	sub    $0x1,%edi
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	eb ec                	jmp    800511 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800525:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800528:	89 45 14             	mov    %eax,0x14(%ebp)
  80052b:	e9 fe 02 00 00       	jmp    80082e <vprintfmt+0x553>
	if (lflag >= 2)
  800530:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800534:	7f 21                	jg     800557 <vprintfmt+0x27c>
	else if (lflag)
  800536:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80053a:	74 79                	je     8005b5 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  80053c:	8b 45 14             	mov    0x14(%ebp),%eax
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800544:	89 c1                	mov    %eax,%ecx
  800546:	c1 f9 1f             	sar    $0x1f,%ecx
  800549:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 40 04             	lea    0x4(%eax),%eax
  800552:	89 45 14             	mov    %eax,0x14(%ebp)
  800555:	eb 17                	jmp    80056e <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8b 50 04             	mov    0x4(%eax),%edx
  80055d:	8b 00                	mov    (%eax),%eax
  80055f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800562:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8d 40 08             	lea    0x8(%eax),%eax
  80056b:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  80056e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800571:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800574:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800577:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  80057a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80057e:	78 50                	js     8005d0 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  800580:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800583:	c1 fa 1f             	sar    $0x1f,%edx
  800586:	89 d0                	mov    %edx,%eax
  800588:	2b 45 e0             	sub    -0x20(%ebp),%eax
  80058b:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  80058e:	85 d2                	test   %edx,%edx
  800590:	0f 89 14 02 00 00    	jns    8007aa <vprintfmt+0x4cf>
  800596:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80059a:	0f 84 0a 02 00 00    	je     8007aa <vprintfmt+0x4cf>
				putch('+', putdat);
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	56                   	push   %esi
  8005a4:	6a 2b                	push   $0x2b
  8005a6:	ff d3                	call   *%ebx
  8005a8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ab:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b0:	e9 5c 01 00 00       	jmp    800711 <vprintfmt+0x436>
		return va_arg(*ap, int);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005bd:	89 c1                	mov    %eax,%ecx
  8005bf:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c8:	8d 40 04             	lea    0x4(%eax),%eax
  8005cb:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ce:	eb 9e                	jmp    80056e <vprintfmt+0x293>
				putch('-', putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	56                   	push   %esi
  8005d4:	6a 2d                	push   $0x2d
  8005d6:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005de:	f7 d8                	neg    %eax
  8005e0:	83 d2 00             	adc    $0x0,%edx
  8005e3:	f7 da                	neg    %edx
  8005e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005e8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005eb:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f3:	e9 19 01 00 00       	jmp    800711 <vprintfmt+0x436>
	if (lflag >= 2)
  8005f8:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8005fc:	7f 29                	jg     800627 <vprintfmt+0x34c>
	else if (lflag)
  8005fe:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800602:	74 44                	je     800648 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8b 00                	mov    (%eax),%eax
  800609:	ba 00 00 00 00       	mov    $0x0,%edx
  80060e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800611:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 40 04             	lea    0x4(%eax),%eax
  80061a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800622:	e9 ea 00 00 00       	jmp    800711 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 50 04             	mov    0x4(%eax),%edx
  80062d:	8b 00                	mov    (%eax),%eax
  80062f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800632:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8d 40 08             	lea    0x8(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800643:	e9 c9 00 00 00       	jmp    800711 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 00                	mov    (%eax),%eax
  80064d:	ba 00 00 00 00       	mov    $0x0,%edx
  800652:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800655:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8d 40 04             	lea    0x4(%eax),%eax
  80065e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800661:	b8 0a 00 00 00       	mov    $0xa,%eax
  800666:	e9 a6 00 00 00       	jmp    800711 <vprintfmt+0x436>
			putch('0', putdat);
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	56                   	push   %esi
  80066f:	6a 30                	push   $0x30
  800671:	ff d3                	call   *%ebx
	if (lflag >= 2)
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80067a:	7f 26                	jg     8006a2 <vprintfmt+0x3c7>
	else if (lflag)
  80067c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800680:	74 3e                	je     8006c0 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 00                	mov    (%eax),%eax
  800687:	ba 00 00 00 00       	mov    $0x0,%edx
  80068c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80068f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 40 04             	lea    0x4(%eax),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80069b:	b8 08 00 00 00       	mov    $0x8,%eax
  8006a0:	eb 6f                	jmp    800711 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8b 50 04             	mov    0x4(%eax),%edx
  8006a8:	8b 00                	mov    (%eax),%eax
  8006aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006ad:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 40 08             	lea    0x8(%eax),%eax
  8006b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006b9:	b8 08 00 00 00       	mov    $0x8,%eax
  8006be:	eb 51                	jmp    800711 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	8b 00                	mov    (%eax),%eax
  8006c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006cd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8d 40 04             	lea    0x4(%eax),%eax
  8006d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006d9:	b8 08 00 00 00       	mov    $0x8,%eax
  8006de:	eb 31                	jmp    800711 <vprintfmt+0x436>
			putch('0', putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	56                   	push   %esi
  8006e4:	6a 30                	push   $0x30
  8006e6:	ff d3                	call   *%ebx
			putch('x', putdat);
  8006e8:	83 c4 08             	add    $0x8,%esp
  8006eb:	56                   	push   %esi
  8006ec:	6a 78                	push   $0x78
  8006ee:	ff d3                	call   *%ebx
			num = (unsigned long long)
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8b 00                	mov    (%eax),%eax
  8006f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8006fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006fd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800700:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8d 40 04             	lea    0x4(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070c:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800711:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800715:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800718:	89 c1                	mov    %eax,%ecx
  80071a:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  80071d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800720:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800725:	89 c2                	mov    %eax,%edx
  800727:	39 c1                	cmp    %eax,%ecx
  800729:	0f 87 85 00 00 00    	ja     8007b4 <vprintfmt+0x4d9>
		tmp /= base;
  80072f:	89 d0                	mov    %edx,%eax
  800731:	ba 00 00 00 00       	mov    $0x0,%edx
  800736:	f7 f1                	div    %ecx
		len++;
  800738:	83 c7 01             	add    $0x1,%edi
  80073b:	eb e8                	jmp    800725 <vprintfmt+0x44a>
	if (lflag >= 2)
  80073d:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800741:	7f 26                	jg     800769 <vprintfmt+0x48e>
	else if (lflag)
  800743:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800747:	74 3e                	je     800787 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8b 00                	mov    (%eax),%eax
  80074e:	ba 00 00 00 00       	mov    $0x0,%edx
  800753:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800756:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8d 40 04             	lea    0x4(%eax),%eax
  80075f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800762:	b8 10 00 00 00       	mov    $0x10,%eax
  800767:	eb a8                	jmp    800711 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800769:	8b 45 14             	mov    0x14(%ebp),%eax
  80076c:	8b 50 04             	mov    0x4(%eax),%edx
  80076f:	8b 00                	mov    (%eax),%eax
  800771:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800774:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8d 40 08             	lea    0x8(%eax),%eax
  80077d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800780:	b8 10 00 00 00       	mov    $0x10,%eax
  800785:	eb 8a                	jmp    800711 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	8b 00                	mov    (%eax),%eax
  80078c:	ba 00 00 00 00       	mov    $0x0,%edx
  800791:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800794:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 40 04             	lea    0x4(%eax),%eax
  80079d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a0:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a5:	e9 67 ff ff ff       	jmp    800711 <vprintfmt+0x436>
			base = 10;
  8007aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007af:	e9 5d ff ff ff       	jmp    800711 <vprintfmt+0x436>
  8007b4:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8007b7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007ba:	29 f8                	sub    %edi,%eax
  8007bc:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8007be:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8007c2:	74 15                	je     8007d9 <vprintfmt+0x4fe>
		while (width > 0) {
  8007c4:	85 ff                	test   %edi,%edi
  8007c6:	7e 48                	jle    800810 <vprintfmt+0x535>
			putch(padc, putdat);
  8007c8:	83 ec 08             	sub    $0x8,%esp
  8007cb:	56                   	push   %esi
  8007cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8007cf:	ff d3                	call   *%ebx
			width--;
  8007d1:	83 ef 01             	sub    $0x1,%edi
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	eb eb                	jmp    8007c4 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  8007d9:	83 ec 0c             	sub    $0xc,%esp
  8007dc:	6a 2d                	push   $0x2d
  8007de:	ff 75 cc             	pushl  -0x34(%ebp)
  8007e1:	ff 75 c8             	pushl  -0x38(%ebp)
  8007e4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007e7:	ff 75 d0             	pushl  -0x30(%ebp)
  8007ea:	89 f2                	mov    %esi,%edx
  8007ec:	89 d8                	mov    %ebx,%eax
  8007ee:	e8 1e fa ff ff       	call   800211 <printnum_helper>
		width -= len;
  8007f3:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007f6:	2b 7d cc             	sub    -0x34(%ebp),%edi
  8007f9:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  8007fc:	85 ff                	test   %edi,%edi
  8007fe:	7e 2e                	jle    80082e <vprintfmt+0x553>
			putch(padc, putdat);
  800800:	83 ec 08             	sub    $0x8,%esp
  800803:	56                   	push   %esi
  800804:	6a 20                	push   $0x20
  800806:	ff d3                	call   *%ebx
			width--;
  800808:	83 ef 01             	sub    $0x1,%edi
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	eb ec                	jmp    8007fc <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800810:	83 ec 0c             	sub    $0xc,%esp
  800813:	ff 75 e0             	pushl  -0x20(%ebp)
  800816:	ff 75 cc             	pushl  -0x34(%ebp)
  800819:	ff 75 c8             	pushl  -0x38(%ebp)
  80081c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80081f:	ff 75 d0             	pushl  -0x30(%ebp)
  800822:	89 f2                	mov    %esi,%edx
  800824:	89 d8                	mov    %ebx,%eax
  800826:	e8 e6 f9 ff ff       	call   800211 <printnum_helper>
  80082b:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  80082e:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800831:	83 c7 01             	add    $0x1,%edi
  800834:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800838:	83 f8 25             	cmp    $0x25,%eax
  80083b:	0f 84 b1 fa ff ff    	je     8002f2 <vprintfmt+0x17>
			if (ch == '\0')
  800841:	85 c0                	test   %eax,%eax
  800843:	0f 84 a1 00 00 00    	je     8008ea <vprintfmt+0x60f>
			putch(ch, putdat);
  800849:	83 ec 08             	sub    $0x8,%esp
  80084c:	56                   	push   %esi
  80084d:	50                   	push   %eax
  80084e:	ff d3                	call   *%ebx
  800850:	83 c4 10             	add    $0x10,%esp
  800853:	eb dc                	jmp    800831 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800855:	8b 45 14             	mov    0x14(%ebp),%eax
  800858:	83 c0 04             	add    $0x4,%eax
  80085b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800863:	85 ff                	test   %edi,%edi
  800865:	74 15                	je     80087c <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800867:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  80086d:	7f 29                	jg     800898 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  80086f:	0f b6 06             	movzbl (%esi),%eax
  800872:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800874:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800877:	89 45 14             	mov    %eax,0x14(%ebp)
  80087a:	eb b2                	jmp    80082e <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  80087c:	68 b4 13 80 00       	push   $0x8013b4
  800881:	68 1c 13 80 00       	push   $0x80131c
  800886:	56                   	push   %esi
  800887:	53                   	push   %ebx
  800888:	e8 31 fa ff ff       	call   8002be <printfmt>
  80088d:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800890:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800893:	89 45 14             	mov    %eax,0x14(%ebp)
  800896:	eb 96                	jmp    80082e <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800898:	68 ec 13 80 00       	push   $0x8013ec
  80089d:	68 1c 13 80 00       	push   $0x80131c
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
  8008a4:	e8 15 fa ff ff       	call   8002be <printfmt>
				*res = -1;
  8008a9:	c6 07 ff             	movb   $0xff,(%edi)
  8008ac:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8008af:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8008b5:	e9 74 ff ff ff       	jmp    80082e <vprintfmt+0x553>
			putch(ch, putdat);
  8008ba:	83 ec 08             	sub    $0x8,%esp
  8008bd:	56                   	push   %esi
  8008be:	6a 25                	push   $0x25
  8008c0:	ff d3                	call   *%ebx
			break;
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	e9 64 ff ff ff       	jmp    80082e <vprintfmt+0x553>
			putch('%', putdat);
  8008ca:	83 ec 08             	sub    $0x8,%esp
  8008cd:	56                   	push   %esi
  8008ce:	6a 25                	push   $0x25
  8008d0:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008d2:	83 c4 10             	add    $0x10,%esp
  8008d5:	89 f8                	mov    %edi,%eax
  8008d7:	eb 03                	jmp    8008dc <vprintfmt+0x601>
  8008d9:	83 e8 01             	sub    $0x1,%eax
  8008dc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008e0:	75 f7                	jne    8008d9 <vprintfmt+0x5fe>
  8008e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008e5:	e9 44 ff ff ff       	jmp    80082e <vprintfmt+0x553>
}
  8008ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ed:	5b                   	pop    %ebx
  8008ee:	5e                   	pop    %esi
  8008ef:	5f                   	pop    %edi
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	83 ec 18             	sub    $0x18,%esp
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800901:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800905:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800908:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80090f:	85 c0                	test   %eax,%eax
  800911:	74 26                	je     800939 <vsnprintf+0x47>
  800913:	85 d2                	test   %edx,%edx
  800915:	7e 22                	jle    800939 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800917:	ff 75 14             	pushl  0x14(%ebp)
  80091a:	ff 75 10             	pushl  0x10(%ebp)
  80091d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800920:	50                   	push   %eax
  800921:	68 a1 02 80 00       	push   $0x8002a1
  800926:	e8 b0 f9 ff ff       	call   8002db <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80092b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80092e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800931:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800934:	83 c4 10             	add    $0x10,%esp
}
  800937:	c9                   	leave  
  800938:	c3                   	ret    
		return -E_INVAL;
  800939:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80093e:	eb f7                	jmp    800937 <vsnprintf+0x45>

00800940 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800946:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800949:	50                   	push   %eax
  80094a:	ff 75 10             	pushl  0x10(%ebp)
  80094d:	ff 75 0c             	pushl  0xc(%ebp)
  800950:	ff 75 08             	pushl  0x8(%ebp)
  800953:	e8 9a ff ff ff       	call   8008f2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800958:	c9                   	leave  
  800959:	c3                   	ret    

0080095a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800960:	b8 00 00 00 00       	mov    $0x0,%eax
  800965:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800969:	74 05                	je     800970 <strlen+0x16>
		n++;
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	eb f5                	jmp    800965 <strlen+0xb>
	return n;
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800978:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80097b:	ba 00 00 00 00       	mov    $0x0,%edx
  800980:	39 c2                	cmp    %eax,%edx
  800982:	74 0d                	je     800991 <strnlen+0x1f>
  800984:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800988:	74 05                	je     80098f <strnlen+0x1d>
		n++;
  80098a:	83 c2 01             	add    $0x1,%edx
  80098d:	eb f1                	jmp    800980 <strnlen+0xe>
  80098f:	89 d0                	mov    %edx,%eax
	return n;
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	53                   	push   %ebx
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80099d:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a2:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009a6:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009a9:	83 c2 01             	add    $0x1,%edx
  8009ac:	84 c9                	test   %cl,%cl
  8009ae:	75 f2                	jne    8009a2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	53                   	push   %ebx
  8009b7:	83 ec 10             	sub    $0x10,%esp
  8009ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009bd:	53                   	push   %ebx
  8009be:	e8 97 ff ff ff       	call   80095a <strlen>
  8009c3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009c6:	ff 75 0c             	pushl  0xc(%ebp)
  8009c9:	01 d8                	add    %ebx,%eax
  8009cb:	50                   	push   %eax
  8009cc:	e8 c2 ff ff ff       	call   800993 <strcpy>
	return dst;
}
  8009d1:	89 d8                	mov    %ebx,%eax
  8009d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d6:	c9                   	leave  
  8009d7:	c3                   	ret    

008009d8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	56                   	push   %esi
  8009dc:	53                   	push   %ebx
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e3:	89 c6                	mov    %eax,%esi
  8009e5:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e8:	89 c2                	mov    %eax,%edx
  8009ea:	39 f2                	cmp    %esi,%edx
  8009ec:	74 11                	je     8009ff <strncpy+0x27>
		*dst++ = *src;
  8009ee:	83 c2 01             	add    $0x1,%edx
  8009f1:	0f b6 19             	movzbl (%ecx),%ebx
  8009f4:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009f7:	80 fb 01             	cmp    $0x1,%bl
  8009fa:	83 d9 ff             	sbb    $0xffffffff,%ecx
  8009fd:	eb eb                	jmp    8009ea <strncpy+0x12>
	}
	return ret;
}
  8009ff:	5b                   	pop    %ebx
  800a00:	5e                   	pop    %esi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    

00800a03 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a03:	55                   	push   %ebp
  800a04:	89 e5                	mov    %esp,%ebp
  800a06:	56                   	push   %esi
  800a07:	53                   	push   %ebx
  800a08:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0e:	8b 55 10             	mov    0x10(%ebp),%edx
  800a11:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a13:	85 d2                	test   %edx,%edx
  800a15:	74 21                	je     800a38 <strlcpy+0x35>
  800a17:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a1b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800a1d:	39 c2                	cmp    %eax,%edx
  800a1f:	74 14                	je     800a35 <strlcpy+0x32>
  800a21:	0f b6 19             	movzbl (%ecx),%ebx
  800a24:	84 db                	test   %bl,%bl
  800a26:	74 0b                	je     800a33 <strlcpy+0x30>
			*dst++ = *src++;
  800a28:	83 c1 01             	add    $0x1,%ecx
  800a2b:	83 c2 01             	add    $0x1,%edx
  800a2e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a31:	eb ea                	jmp    800a1d <strlcpy+0x1a>
  800a33:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a35:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a38:	29 f0                	sub    %esi,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a44:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a47:	0f b6 01             	movzbl (%ecx),%eax
  800a4a:	84 c0                	test   %al,%al
  800a4c:	74 0c                	je     800a5a <strcmp+0x1c>
  800a4e:	3a 02                	cmp    (%edx),%al
  800a50:	75 08                	jne    800a5a <strcmp+0x1c>
		p++, q++;
  800a52:	83 c1 01             	add    $0x1,%ecx
  800a55:	83 c2 01             	add    $0x1,%edx
  800a58:	eb ed                	jmp    800a47 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5a:	0f b6 c0             	movzbl %al,%eax
  800a5d:	0f b6 12             	movzbl (%edx),%edx
  800a60:	29 d0                	sub    %edx,%eax
}
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	53                   	push   %ebx
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6e:	89 c3                	mov    %eax,%ebx
  800a70:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a73:	eb 06                	jmp    800a7b <strncmp+0x17>
		n--, p++, q++;
  800a75:	83 c0 01             	add    $0x1,%eax
  800a78:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a7b:	39 d8                	cmp    %ebx,%eax
  800a7d:	74 16                	je     800a95 <strncmp+0x31>
  800a7f:	0f b6 08             	movzbl (%eax),%ecx
  800a82:	84 c9                	test   %cl,%cl
  800a84:	74 04                	je     800a8a <strncmp+0x26>
  800a86:	3a 0a                	cmp    (%edx),%cl
  800a88:	74 eb                	je     800a75 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8a:	0f b6 00             	movzbl (%eax),%eax
  800a8d:	0f b6 12             	movzbl (%edx),%edx
  800a90:	29 d0                	sub    %edx,%eax
}
  800a92:	5b                   	pop    %ebx
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    
		return 0;
  800a95:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9a:	eb f6                	jmp    800a92 <strncmp+0x2e>

00800a9c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa6:	0f b6 10             	movzbl (%eax),%edx
  800aa9:	84 d2                	test   %dl,%dl
  800aab:	74 09                	je     800ab6 <strchr+0x1a>
		if (*s == c)
  800aad:	38 ca                	cmp    %cl,%dl
  800aaf:	74 0a                	je     800abb <strchr+0x1f>
	for (; *s; s++)
  800ab1:	83 c0 01             	add    $0x1,%eax
  800ab4:	eb f0                	jmp    800aa6 <strchr+0xa>
			return (char *) s;
	return 0;
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800abd:	55                   	push   %ebp
  800abe:	89 e5                	mov    %esp,%ebp
  800ac0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aca:	38 ca                	cmp    %cl,%dl
  800acc:	74 09                	je     800ad7 <strfind+0x1a>
  800ace:	84 d2                	test   %dl,%dl
  800ad0:	74 05                	je     800ad7 <strfind+0x1a>
	for (; *s; s++)
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	eb f0                	jmp    800ac7 <strfind+0xa>
			break;
	return (char *) s;
}
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ae2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ae5:	85 c9                	test   %ecx,%ecx
  800ae7:	74 31                	je     800b1a <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae9:	89 f8                	mov    %edi,%eax
  800aeb:	09 c8                	or     %ecx,%eax
  800aed:	a8 03                	test   $0x3,%al
  800aef:	75 23                	jne    800b14 <memset+0x3b>
		c &= 0xFF;
  800af1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af5:	89 d3                	mov    %edx,%ebx
  800af7:	c1 e3 08             	shl    $0x8,%ebx
  800afa:	89 d0                	mov    %edx,%eax
  800afc:	c1 e0 18             	shl    $0x18,%eax
  800aff:	89 d6                	mov    %edx,%esi
  800b01:	c1 e6 10             	shl    $0x10,%esi
  800b04:	09 f0                	or     %esi,%eax
  800b06:	09 c2                	or     %eax,%edx
  800b08:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b0a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b0d:	89 d0                	mov    %edx,%eax
  800b0f:	fc                   	cld    
  800b10:	f3 ab                	rep stos %eax,%es:(%edi)
  800b12:	eb 06                	jmp    800b1a <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b17:	fc                   	cld    
  800b18:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b1a:	89 f8                	mov    %edi,%eax
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	57                   	push   %edi
  800b25:	56                   	push   %esi
  800b26:	8b 45 08             	mov    0x8(%ebp),%eax
  800b29:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b2f:	39 c6                	cmp    %eax,%esi
  800b31:	73 32                	jae    800b65 <memmove+0x44>
  800b33:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b36:	39 c2                	cmp    %eax,%edx
  800b38:	76 2b                	jbe    800b65 <memmove+0x44>
		s += n;
		d += n;
  800b3a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3d:	89 fe                	mov    %edi,%esi
  800b3f:	09 ce                	or     %ecx,%esi
  800b41:	09 d6                	or     %edx,%esi
  800b43:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b49:	75 0e                	jne    800b59 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b4b:	83 ef 04             	sub    $0x4,%edi
  800b4e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b51:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b54:	fd                   	std    
  800b55:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b57:	eb 09                	jmp    800b62 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b59:	83 ef 01             	sub    $0x1,%edi
  800b5c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b5f:	fd                   	std    
  800b60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b62:	fc                   	cld    
  800b63:	eb 1a                	jmp    800b7f <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b65:	89 c2                	mov    %eax,%edx
  800b67:	09 ca                	or     %ecx,%edx
  800b69:	09 f2                	or     %esi,%edx
  800b6b:	f6 c2 03             	test   $0x3,%dl
  800b6e:	75 0a                	jne    800b7a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b70:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b73:	89 c7                	mov    %eax,%edi
  800b75:	fc                   	cld    
  800b76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b78:	eb 05                	jmp    800b7f <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b7a:	89 c7                	mov    %eax,%edi
  800b7c:	fc                   	cld    
  800b7d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    

00800b83 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b89:	ff 75 10             	pushl  0x10(%ebp)
  800b8c:	ff 75 0c             	pushl  0xc(%ebp)
  800b8f:	ff 75 08             	pushl  0x8(%ebp)
  800b92:	e8 8a ff ff ff       	call   800b21 <memmove>
}
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba4:	89 c6                	mov    %eax,%esi
  800ba6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba9:	39 f0                	cmp    %esi,%eax
  800bab:	74 1c                	je     800bc9 <memcmp+0x30>
		if (*s1 != *s2)
  800bad:	0f b6 08             	movzbl (%eax),%ecx
  800bb0:	0f b6 1a             	movzbl (%edx),%ebx
  800bb3:	38 d9                	cmp    %bl,%cl
  800bb5:	75 08                	jne    800bbf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bb7:	83 c0 01             	add    $0x1,%eax
  800bba:	83 c2 01             	add    $0x1,%edx
  800bbd:	eb ea                	jmp    800ba9 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800bbf:	0f b6 c1             	movzbl %cl,%eax
  800bc2:	0f b6 db             	movzbl %bl,%ebx
  800bc5:	29 d8                	sub    %ebx,%eax
  800bc7:	eb 05                	jmp    800bce <memcmp+0x35>
	}

	return 0;
  800bc9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    

00800bd2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bdb:	89 c2                	mov    %eax,%edx
  800bdd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800be0:	39 d0                	cmp    %edx,%eax
  800be2:	73 09                	jae    800bed <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800be4:	38 08                	cmp    %cl,(%eax)
  800be6:	74 05                	je     800bed <memfind+0x1b>
	for (; s < ends; s++)
  800be8:	83 c0 01             	add    $0x1,%eax
  800beb:	eb f3                	jmp    800be0 <memfind+0xe>
			break;
	return (void *) s;
}
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfb:	eb 03                	jmp    800c00 <strtol+0x11>
		s++;
  800bfd:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c00:	0f b6 01             	movzbl (%ecx),%eax
  800c03:	3c 20                	cmp    $0x20,%al
  800c05:	74 f6                	je     800bfd <strtol+0xe>
  800c07:	3c 09                	cmp    $0x9,%al
  800c09:	74 f2                	je     800bfd <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c0b:	3c 2b                	cmp    $0x2b,%al
  800c0d:	74 2a                	je     800c39 <strtol+0x4a>
	int neg = 0;
  800c0f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c14:	3c 2d                	cmp    $0x2d,%al
  800c16:	74 2b                	je     800c43 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c18:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1e:	75 0f                	jne    800c2f <strtol+0x40>
  800c20:	80 39 30             	cmpb   $0x30,(%ecx)
  800c23:	74 28                	je     800c4d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c25:	85 db                	test   %ebx,%ebx
  800c27:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c2c:	0f 44 d8             	cmove  %eax,%ebx
  800c2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c34:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c37:	eb 50                	jmp    800c89 <strtol+0x9a>
		s++;
  800c39:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c3c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c41:	eb d5                	jmp    800c18 <strtol+0x29>
		s++, neg = 1;
  800c43:	83 c1 01             	add    $0x1,%ecx
  800c46:	bf 01 00 00 00       	mov    $0x1,%edi
  800c4b:	eb cb                	jmp    800c18 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c4d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c51:	74 0e                	je     800c61 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c53:	85 db                	test   %ebx,%ebx
  800c55:	75 d8                	jne    800c2f <strtol+0x40>
		s++, base = 8;
  800c57:	83 c1 01             	add    $0x1,%ecx
  800c5a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c5f:	eb ce                	jmp    800c2f <strtol+0x40>
		s += 2, base = 16;
  800c61:	83 c1 02             	add    $0x2,%ecx
  800c64:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c69:	eb c4                	jmp    800c2f <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c6b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c6e:	89 f3                	mov    %esi,%ebx
  800c70:	80 fb 19             	cmp    $0x19,%bl
  800c73:	77 29                	ja     800c9e <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c75:	0f be d2             	movsbl %dl,%edx
  800c78:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c7b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c7e:	7d 30                	jge    800cb0 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c80:	83 c1 01             	add    $0x1,%ecx
  800c83:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c87:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c89:	0f b6 11             	movzbl (%ecx),%edx
  800c8c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c8f:	89 f3                	mov    %esi,%ebx
  800c91:	80 fb 09             	cmp    $0x9,%bl
  800c94:	77 d5                	ja     800c6b <strtol+0x7c>
			dig = *s - '0';
  800c96:	0f be d2             	movsbl %dl,%edx
  800c99:	83 ea 30             	sub    $0x30,%edx
  800c9c:	eb dd                	jmp    800c7b <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800c9e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ca1:	89 f3                	mov    %esi,%ebx
  800ca3:	80 fb 19             	cmp    $0x19,%bl
  800ca6:	77 08                	ja     800cb0 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ca8:	0f be d2             	movsbl %dl,%edx
  800cab:	83 ea 37             	sub    $0x37,%edx
  800cae:	eb cb                	jmp    800c7b <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cb0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb4:	74 05                	je     800cbb <strtol+0xcc>
		*endptr = (char *) s;
  800cb6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cbb:	89 c2                	mov    %eax,%edx
  800cbd:	f7 da                	neg    %edx
  800cbf:	85 ff                	test   %edi,%edi
  800cc1:	0f 45 c2             	cmovne %edx,%eax
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ccf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	89 c3                	mov    %eax,%ebx
  800cdc:	89 c7                	mov    %eax,%edi
  800cde:	89 c6                	mov    %eax,%esi
  800ce0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ced:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf7:	89 d1                	mov    %edx,%ecx
  800cf9:	89 d3                	mov    %edx,%ebx
  800cfb:	89 d7                	mov    %edx,%edi
  800cfd:	89 d6                	mov    %edx,%esi
  800cff:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	b8 03 00 00 00       	mov    $0x3,%eax
  800d1c:	89 cb                	mov    %ecx,%ebx
  800d1e:	89 cf                	mov    %ecx,%edi
  800d20:	89 ce                	mov    %ecx,%esi
  800d22:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7f 08                	jg     800d30 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	50                   	push   %eax
  800d34:	6a 03                	push   $0x3
  800d36:	68 c4 15 80 00       	push   $0x8015c4
  800d3b:	6a 23                	push   $0x23
  800d3d:	68 e1 15 80 00       	push   $0x8015e1
  800d42:	e8 db f3 ff ff       	call   800122 <_panic>

00800d47 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	57                   	push   %edi
  800d4b:	56                   	push   %esi
  800d4c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d52:	b8 02 00 00 00       	mov    $0x2,%eax
  800d57:	89 d1                	mov    %edx,%ecx
  800d59:	89 d3                	mov    %edx,%ebx
  800d5b:	89 d7                	mov    %edx,%edi
  800d5d:	89 d6                	mov    %edx,%esi
  800d5f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_yield>:

void
sys_yield(void)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	57                   	push   %edi
  800d6a:	56                   	push   %esi
  800d6b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d71:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d76:	89 d1                	mov    %edx,%ecx
  800d78:	89 d3                	mov    %edx,%ebx
  800d7a:	89 d7                	mov    %edx,%edi
  800d7c:	89 d6                	mov    %edx,%esi
  800d7e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
  800d8b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d8e:	be 00 00 00 00       	mov    $0x0,%esi
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	b8 04 00 00 00       	mov    $0x4,%eax
  800d9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da1:	89 f7                	mov    %esi,%edi
  800da3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7f 08                	jg     800db1 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 04                	push   $0x4
  800db7:	68 c4 15 80 00       	push   $0x8015c4
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 e1 15 80 00       	push   $0x8015e1
  800dc3:	e8 5a f3 ff ff       	call   800122 <_panic>

00800dc8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	b8 05 00 00 00       	mov    $0x5,%eax
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de2:	8b 75 18             	mov    0x18(%ebp),%esi
  800de5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7f 08                	jg     800df3 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800deb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5f                   	pop    %edi
  800df1:	5d                   	pop    %ebp
  800df2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	50                   	push   %eax
  800df7:	6a 05                	push   $0x5
  800df9:	68 c4 15 80 00       	push   $0x8015c4
  800dfe:	6a 23                	push   $0x23
  800e00:	68 e1 15 80 00       	push   $0x8015e1
  800e05:	e8 18 f3 ff ff       	call   800122 <_panic>

00800e0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	57                   	push   %edi
  800e0e:	56                   	push   %esi
  800e0f:	53                   	push   %ebx
  800e10:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7f 08                	jg     800e35 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	83 ec 0c             	sub    $0xc,%esp
  800e38:	50                   	push   %eax
  800e39:	6a 06                	push   $0x6
  800e3b:	68 c4 15 80 00       	push   $0x8015c4
  800e40:	6a 23                	push   $0x23
  800e42:	68 e1 15 80 00       	push   $0x8015e1
  800e47:	e8 d6 f2 ff ff       	call   800122 <_panic>

00800e4c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	57                   	push   %edi
  800e50:	56                   	push   %esi
  800e51:	53                   	push   %ebx
  800e52:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e60:	b8 08 00 00 00       	mov    $0x8,%eax
  800e65:	89 df                	mov    %ebx,%edi
  800e67:	89 de                	mov    %ebx,%esi
  800e69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7f 08                	jg     800e77 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	50                   	push   %eax
  800e7b:	6a 08                	push   $0x8
  800e7d:	68 c4 15 80 00       	push   $0x8015c4
  800e82:	6a 23                	push   $0x23
  800e84:	68 e1 15 80 00       	push   $0x8015e1
  800e89:	e8 94 f2 ff ff       	call   800122 <_panic>

00800e8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea2:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea7:	89 df                	mov    %ebx,%edi
  800ea9:	89 de                	mov    %ebx,%esi
  800eab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7f 08                	jg     800eb9 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb9:	83 ec 0c             	sub    $0xc,%esp
  800ebc:	50                   	push   %eax
  800ebd:	6a 09                	push   $0x9
  800ebf:	68 c4 15 80 00       	push   $0x8015c4
  800ec4:	6a 23                	push   $0x23
  800ec6:	68 e1 15 80 00       	push   $0x8015e1
  800ecb:	e8 52 f2 ff ff       	call   800122 <_panic>

00800ed0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ed6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ee1:	be 00 00 00 00       	mov    $0x0,%esi
  800ee6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eec:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eee:	5b                   	pop    %ebx
  800eef:	5e                   	pop    %esi
  800ef0:	5f                   	pop    %edi
  800ef1:	5d                   	pop    %ebp
  800ef2:	c3                   	ret    

00800ef3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800efc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f01:	8b 55 08             	mov    0x8(%ebp),%edx
  800f04:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f09:	89 cb                	mov    %ecx,%ebx
  800f0b:	89 cf                	mov    %ecx,%edi
  800f0d:	89 ce                	mov    %ecx,%esi
  800f0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f11:	85 c0                	test   %eax,%eax
  800f13:	7f 08                	jg     800f1d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f18:	5b                   	pop    %ebx
  800f19:	5e                   	pop    %esi
  800f1a:	5f                   	pop    %edi
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1d:	83 ec 0c             	sub    $0xc,%esp
  800f20:	50                   	push   %eax
  800f21:	6a 0c                	push   $0xc
  800f23:	68 c4 15 80 00       	push   $0x8015c4
  800f28:	6a 23                	push   $0x23
  800f2a:	68 e1 15 80 00       	push   $0x8015e1
  800f2f:	e8 ee f1 ff ff       	call   800122 <_panic>

00800f34 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	57                   	push   %edi
  800f38:	56                   	push   %esi
  800f39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f45:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f4a:	89 df                	mov    %ebx,%edi
  800f4c:	89 de                	mov    %ebx,%esi
  800f4e:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5f                   	pop    %edi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	57                   	push   %edi
  800f59:	56                   	push   %esi
  800f5a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f60:	8b 55 08             	mov    0x8(%ebp),%edx
  800f63:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f68:	89 cb                	mov    %ecx,%ebx
  800f6a:	89 cf                	mov    %ecx,%edi
  800f6c:	89 ce                	mov    %ecx,%esi
  800f6e:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5f                   	pop    %edi
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    

00800f75 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f7b:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800f82:	74 0a                	je     800f8e <set_pgfault_handler+0x19>
		if ((r = sys_env_set_pgfault_upcall((envid_t)0, _pgfault_upcall)) < 0)
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f84:	8b 45 08             	mov    0x8(%ebp),%eax
  800f87:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    
		if ((r = sys_page_alloc((envid_t)0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W)) < 0) 
  800f8e:	83 ec 04             	sub    $0x4,%esp
  800f91:	6a 07                	push   $0x7
  800f93:	68 00 f0 bf ee       	push   $0xeebff000
  800f98:	6a 00                	push   $0x0
  800f9a:	e8 e6 fd ff ff       	call   800d85 <sys_page_alloc>
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	78 2a                	js     800fd0 <set_pgfault_handler+0x5b>
		if ((r = sys_env_set_pgfault_upcall((envid_t)0, _pgfault_upcall)) < 0)
  800fa6:	83 ec 08             	sub    $0x8,%esp
  800fa9:	68 e4 0f 80 00       	push   $0x800fe4
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 d9 fe ff ff       	call   800e8e <sys_env_set_pgfault_upcall>
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	79 c8                	jns    800f84 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail");
  800fbc:	83 ec 04             	sub    $0x4,%esp
  800fbf:	68 1c 16 80 00       	push   $0x80161c
  800fc4:	6a 23                	push   $0x23
  800fc6:	68 54 16 80 00       	push   $0x801654
  800fcb:	e8 52 f1 ff ff       	call   800122 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail");
  800fd0:	83 ec 04             	sub    $0x4,%esp
  800fd3:	68 f0 15 80 00       	push   $0x8015f0
  800fd8:	6a 21                	push   $0x21
  800fda:	68 54 16 80 00       	push   $0x801654
  800fdf:	e8 3e f1 ff ff       	call   800122 <_panic>

00800fe4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800fe4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800fe5:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800fea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800fec:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %ebp
  800fef:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl 48(%esp), %ebx
  800ff3:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800ff7:	83 eb 04             	sub    $0x4,%ebx
	movl %ebp, (%ebx)
  800ffa:	89 2b                	mov    %ebp,(%ebx)
	movl %ebx, 48(%esp)
  800ffc:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801000:	83 c4 08             	add    $0x8,%esp
	popal
  801003:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801004:	83 c4 04             	add    $0x4,%esp
	popfl
  801007:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801008:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801009:	c3                   	ret    
  80100a:	66 90                	xchg   %ax,%ax
  80100c:	66 90                	xchg   %ax,%ax
  80100e:	66 90                	xchg   %ax,%ax

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
