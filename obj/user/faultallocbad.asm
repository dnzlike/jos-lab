
obj/user/faultallocbad:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800045:	e8 9e 01 00 00       	call   8001e8 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 12 0d 00 00       	call   800d70 <sys_page_alloc>
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
  80006e:	e8 b8 08 00 00       	call   80092b <snprintf>
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
  800085:	6a 0f                	push   $0xf
  800087:	68 6a 12 80 00       	push   $0x80126a
  80008c:	e8 7c 00 00 00       	call   80010d <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 bf 0e 00 00       	call   800f60 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 04 0c 00 00       	call   800cb4 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 6d 0c 00 00       	call   800d32 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	c1 e0 07             	shl    $0x7,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 e9 0b 00 00       	call   800cf1 <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800112:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800115:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80011b:	e8 12 0c 00 00       	call   800d32 <sys_getenvid>
  800120:	83 ec 0c             	sub    $0xc,%esp
  800123:	ff 75 0c             	pushl  0xc(%ebp)
  800126:	ff 75 08             	pushl  0x8(%ebp)
  800129:	56                   	push   %esi
  80012a:	50                   	push   %eax
  80012b:	68 d8 12 80 00       	push   $0x8012d8
  800130:	e8 b3 00 00 00       	call   8001e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800135:	83 c4 18             	add    $0x18,%esp
  800138:	53                   	push   %ebx
  800139:	ff 75 10             	pushl  0x10(%ebp)
  80013c:	e8 56 00 00 00       	call   800197 <vcprintf>
	cprintf("\n");
  800141:	c7 04 24 68 12 80 00 	movl   $0x801268,(%esp)
  800148:	e8 9b 00 00 00       	call   8001e8 <cprintf>
  80014d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800150:	cc                   	int3   
  800151:	eb fd                	jmp    800150 <_panic+0x43>

00800153 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	53                   	push   %ebx
  800157:	83 ec 04             	sub    $0x4,%esp
  80015a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015d:	8b 13                	mov    (%ebx),%edx
  80015f:	8d 42 01             	lea    0x1(%edx),%eax
  800162:	89 03                	mov    %eax,(%ebx)
  800164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800167:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800170:	74 09                	je     80017b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800172:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80017b:	83 ec 08             	sub    $0x8,%esp
  80017e:	68 ff 00 00 00       	push   $0xff
  800183:	8d 43 08             	lea    0x8(%ebx),%eax
  800186:	50                   	push   %eax
  800187:	e8 28 0b 00 00       	call   800cb4 <sys_cputs>
		b->idx = 0;
  80018c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	eb db                	jmp    800172 <putch+0x1f>

00800197 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a7:	00 00 00 
	b.cnt = 0;
  8001aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b4:	ff 75 0c             	pushl  0xc(%ebp)
  8001b7:	ff 75 08             	pushl  0x8(%ebp)
  8001ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c0:	50                   	push   %eax
  8001c1:	68 53 01 80 00       	push   $0x800153
  8001c6:	e8 fb 00 00 00       	call   8002c6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cb:	83 c4 08             	add    $0x8,%esp
  8001ce:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001da:	50                   	push   %eax
  8001db:	e8 d4 0a 00 00       	call   800cb4 <sys_cputs>

	return b.cnt;
}
  8001e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f1:	50                   	push   %eax
  8001f2:	ff 75 08             	pushl  0x8(%ebp)
  8001f5:	e8 9d ff ff ff       	call   800197 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	57                   	push   %edi
  800200:	56                   	push   %esi
  800201:	53                   	push   %ebx
  800202:	83 ec 1c             	sub    $0x1c,%esp
  800205:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800208:	89 d3                	mov    %edx,%ebx
  80020a:	8b 75 08             	mov    0x8(%ebp),%esi
  80020d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800210:	8b 45 10             	mov    0x10(%ebp),%eax
  800213:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800216:	89 c2                	mov    %eax,%edx
  800218:	b9 00 00 00 00       	mov    $0x0,%ecx
  80021d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800220:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800223:	39 c6                	cmp    %eax,%esi
  800225:	89 f8                	mov    %edi,%eax
  800227:	19 c8                	sbb    %ecx,%eax
  800229:	73 32                	jae    80025d <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  80022b:	83 ec 08             	sub    $0x8,%esp
  80022e:	53                   	push   %ebx
  80022f:	83 ec 04             	sub    $0x4,%esp
  800232:	ff 75 e4             	pushl  -0x1c(%ebp)
  800235:	ff 75 e0             	pushl  -0x20(%ebp)
  800238:	57                   	push   %edi
  800239:	56                   	push   %esi
  80023a:	e8 d1 0e 00 00       	call   801110 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 fb 12 80 00 	movsbl 0x8012fb(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024d:	ff d0                	call   *%eax
	return remain - 1;
  80024f:	8b 45 14             	mov    0x14(%ebp),%eax
  800252:	83 e8 01             	sub    $0x1,%eax
}
  800255:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800258:	5b                   	pop    %ebx
  800259:	5e                   	pop    %esi
  80025a:	5f                   	pop    %edi
  80025b:	5d                   	pop    %ebp
  80025c:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  80025d:	83 ec 0c             	sub    $0xc,%esp
  800260:	ff 75 18             	pushl  0x18(%ebp)
  800263:	ff 75 14             	pushl  0x14(%ebp)
  800266:	ff 75 d8             	pushl  -0x28(%ebp)
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	51                   	push   %ecx
  80026d:	52                   	push   %edx
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	e8 8b 0d 00 00       	call   801000 <__udivdi3>
  800275:	83 c4 18             	add    $0x18,%esp
  800278:	52                   	push   %edx
  800279:	50                   	push   %eax
  80027a:	89 da                	mov    %ebx,%edx
  80027c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027f:	e8 78 ff ff ff       	call   8001fc <printnum_helper>
  800284:	89 45 14             	mov    %eax,0x14(%ebp)
  800287:	83 c4 20             	add    $0x20,%esp
  80028a:	eb 9f                	jmp    80022b <printnum_helper+0x2f>

0080028c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800292:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800296:	8b 10                	mov    (%eax),%edx
  800298:	3b 50 04             	cmp    0x4(%eax),%edx
  80029b:	73 0a                	jae    8002a7 <sprintputch+0x1b>
		*b->buf++ = ch;
  80029d:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a0:	89 08                	mov    %ecx,(%eax)
  8002a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a5:	88 02                	mov    %al,(%edx)
}
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <printfmt>:
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002af:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002b2:	50                   	push   %eax
  8002b3:	ff 75 10             	pushl  0x10(%ebp)
  8002b6:	ff 75 0c             	pushl  0xc(%ebp)
  8002b9:	ff 75 08             	pushl  0x8(%ebp)
  8002bc:	e8 05 00 00 00       	call   8002c6 <vprintfmt>
}
  8002c1:	83 c4 10             	add    $0x10,%esp
  8002c4:	c9                   	leave  
  8002c5:	c3                   	ret    

008002c6 <vprintfmt>:
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 3c             	sub    $0x3c,%esp
  8002cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002d2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002d5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002d8:	e9 3f 05 00 00       	jmp    80081c <vprintfmt+0x556>
		padc = ' ';
  8002dd:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  8002e1:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  8002e8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8002ef:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  8002f6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  8002fd:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800304:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800309:	8d 47 01             	lea    0x1(%edi),%eax
  80030c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80030f:	0f b6 17             	movzbl (%edi),%edx
  800312:	8d 42 dd             	lea    -0x23(%edx),%eax
  800315:	3c 55                	cmp    $0x55,%al
  800317:	0f 87 98 05 00 00    	ja     8008b5 <vprintfmt+0x5ef>
  80031d:	0f b6 c0             	movzbl %al,%eax
  800320:	ff 24 85 40 14 80 00 	jmp    *0x801440(,%eax,4)
  800327:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  80032a:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80032e:	eb d9                	jmp    800309 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800333:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  80033a:	eb cd                	jmp    800309 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80033c:	0f b6 d2             	movzbl %dl,%edx
  80033f:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800342:	b8 00 00 00 00       	mov    $0x0,%eax
  800347:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  80034a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80034d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800351:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800354:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800357:	83 fb 09             	cmp    $0x9,%ebx
  80035a:	77 5c                	ja     8003b8 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  80035c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80035f:	eb e9                	jmp    80034a <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  800364:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  800368:	eb 9f                	jmp    800309 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  80036a:	8b 45 14             	mov    0x14(%ebp),%eax
  80036d:	8b 00                	mov    (%eax),%eax
  80036f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800372:	8b 45 14             	mov    0x14(%ebp),%eax
  800375:	8d 40 04             	lea    0x4(%eax),%eax
  800378:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  80037e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800382:	79 85                	jns    800309 <vprintfmt+0x43>
				width = precision, precision = -1;
  800384:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800387:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800391:	e9 73 ff ff ff       	jmp    800309 <vprintfmt+0x43>
  800396:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800399:	85 c0                	test   %eax,%eax
  80039b:	0f 48 c1             	cmovs  %ecx,%eax
  80039e:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8003a4:	e9 60 ff ff ff       	jmp    800309 <vprintfmt+0x43>
  8003a9:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8003ac:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8003b3:	e9 51 ff ff ff       	jmp    800309 <vprintfmt+0x43>
  8003b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003be:	eb be                	jmp    80037e <vprintfmt+0xb8>
			lflag++;
  8003c0:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  8003c7:	e9 3d ff ff ff       	jmp    800309 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  8003cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cf:	8d 78 04             	lea    0x4(%eax),%edi
  8003d2:	83 ec 08             	sub    $0x8,%esp
  8003d5:	56                   	push   %esi
  8003d6:	ff 30                	pushl  (%eax)
  8003d8:	ff d3                	call   *%ebx
			break;
  8003da:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003dd:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003e0:	e9 34 04 00 00       	jmp    800819 <vprintfmt+0x553>
			err = va_arg(ap, int);
  8003e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e8:	8d 78 04             	lea    0x4(%eax),%edi
  8003eb:	8b 00                	mov    (%eax),%eax
  8003ed:	99                   	cltd   
  8003ee:	31 d0                	xor    %edx,%eax
  8003f0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f2:	83 f8 08             	cmp    $0x8,%eax
  8003f5:	7f 23                	jg     80041a <vprintfmt+0x154>
  8003f7:	8b 14 85 a0 15 80 00 	mov    0x8015a0(,%eax,4),%edx
  8003fe:	85 d2                	test   %edx,%edx
  800400:	74 18                	je     80041a <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800402:	52                   	push   %edx
  800403:	68 1c 13 80 00       	push   $0x80131c
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
  80040a:	e8 9a fe ff ff       	call   8002a9 <printfmt>
  80040f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800412:	89 7d 14             	mov    %edi,0x14(%ebp)
  800415:	e9 ff 03 00 00       	jmp    800819 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  80041a:	50                   	push   %eax
  80041b:	68 13 13 80 00       	push   $0x801313
  800420:	56                   	push   %esi
  800421:	53                   	push   %ebx
  800422:	e8 82 fe ff ff       	call   8002a9 <printfmt>
  800427:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80042a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80042d:	e9 e7 03 00 00       	jmp    800819 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	83 c0 04             	add    $0x4,%eax
  800438:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800440:	85 c9                	test   %ecx,%ecx
  800442:	b8 0c 13 80 00       	mov    $0x80130c,%eax
  800447:	0f 45 c1             	cmovne %ecx,%eax
  80044a:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80044d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800451:	7e 06                	jle    800459 <vprintfmt+0x193>
  800453:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800457:	75 0d                	jne    800466 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800459:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80045c:	89 c7                	mov    %eax,%edi
  80045e:	03 45 d8             	add    -0x28(%ebp),%eax
  800461:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800464:	eb 53                	jmp    8004b9 <vprintfmt+0x1f3>
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	ff 75 e0             	pushl  -0x20(%ebp)
  80046c:	50                   	push   %eax
  80046d:	e8 eb 04 00 00       	call   80095d <strnlen>
  800472:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800475:	29 c1                	sub    %eax,%ecx
  800477:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80047f:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  800483:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	eb 0f                	jmp    800497 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	56                   	push   %esi
  80048c:	ff 75 d8             	pushl  -0x28(%ebp)
  80048f:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800491:	83 ef 01             	sub    $0x1,%edi
  800494:	83 c4 10             	add    $0x10,%esp
  800497:	85 ff                	test   %edi,%edi
  800499:	7f ed                	jg     800488 <vprintfmt+0x1c2>
  80049b:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80049e:	85 c9                	test   %ecx,%ecx
  8004a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a5:	0f 49 c1             	cmovns %ecx,%eax
  8004a8:	29 c1                	sub    %eax,%ecx
  8004aa:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8004ad:	eb aa                	jmp    800459 <vprintfmt+0x193>
					putch(ch, putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	56                   	push   %esi
  8004b3:	52                   	push   %edx
  8004b4:	ff d3                	call   *%ebx
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8004bc:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004be:	83 c7 01             	add    $0x1,%edi
  8004c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c5:	0f be d0             	movsbl %al,%edx
  8004c8:	85 d2                	test   %edx,%edx
  8004ca:	74 2e                	je     8004fa <vprintfmt+0x234>
  8004cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d0:	78 06                	js     8004d8 <vprintfmt+0x212>
  8004d2:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004d6:	78 1e                	js     8004f6 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  8004d8:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004dc:	74 d1                	je     8004af <vprintfmt+0x1e9>
  8004de:	0f be c0             	movsbl %al,%eax
  8004e1:	83 e8 20             	sub    $0x20,%eax
  8004e4:	83 f8 5e             	cmp    $0x5e,%eax
  8004e7:	76 c6                	jbe    8004af <vprintfmt+0x1e9>
					putch('?', putdat);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	56                   	push   %esi
  8004ed:	6a 3f                	push   $0x3f
  8004ef:	ff d3                	call   *%ebx
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	eb c3                	jmp    8004b9 <vprintfmt+0x1f3>
  8004f6:	89 cf                	mov    %ecx,%edi
  8004f8:	eb 02                	jmp    8004fc <vprintfmt+0x236>
  8004fa:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  8004fc:	85 ff                	test   %edi,%edi
  8004fe:	7e 10                	jle    800510 <vprintfmt+0x24a>
				putch(' ', putdat);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	56                   	push   %esi
  800504:	6a 20                	push   $0x20
  800506:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800508:	83 ef 01             	sub    $0x1,%edi
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	eb ec                	jmp    8004fc <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800510:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800513:	89 45 14             	mov    %eax,0x14(%ebp)
  800516:	e9 fe 02 00 00       	jmp    800819 <vprintfmt+0x553>
	if (lflag >= 2)
  80051b:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80051f:	7f 21                	jg     800542 <vprintfmt+0x27c>
	else if (lflag)
  800521:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800525:	74 79                	je     8005a0 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8b 00                	mov    (%eax),%eax
  80052c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052f:	89 c1                	mov    %eax,%ecx
  800531:	c1 f9 1f             	sar    $0x1f,%ecx
  800534:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 40 04             	lea    0x4(%eax),%eax
  80053d:	89 45 14             	mov    %eax,0x14(%ebp)
  800540:	eb 17                	jmp    800559 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8b 50 04             	mov    0x4(%eax),%edx
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8d 40 08             	lea    0x8(%eax),%eax
  800556:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  800559:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80055f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800562:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  800565:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800569:	78 50                	js     8005bb <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  80056b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80056e:	c1 fa 1f             	sar    $0x1f,%edx
  800571:	89 d0                	mov    %edx,%eax
  800573:	2b 45 e0             	sub    -0x20(%ebp),%eax
  800576:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  800579:	85 d2                	test   %edx,%edx
  80057b:	0f 89 14 02 00 00    	jns    800795 <vprintfmt+0x4cf>
  800581:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800585:	0f 84 0a 02 00 00    	je     800795 <vprintfmt+0x4cf>
				putch('+', putdat);
  80058b:	83 ec 08             	sub    $0x8,%esp
  80058e:	56                   	push   %esi
  80058f:	6a 2b                	push   $0x2b
  800591:	ff d3                	call   *%ebx
  800593:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800596:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059b:	e9 5c 01 00 00       	jmp    8006fc <vprintfmt+0x436>
		return va_arg(*ap, int);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8b 00                	mov    (%eax),%eax
  8005a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a8:	89 c1                	mov    %eax,%ecx
  8005aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ad:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 40 04             	lea    0x4(%eax),%eax
  8005b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b9:	eb 9e                	jmp    800559 <vprintfmt+0x293>
				putch('-', putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	56                   	push   %esi
  8005bf:	6a 2d                	push   $0x2d
  8005c1:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005c9:	f7 d8                	neg    %eax
  8005cb:	83 d2 00             	adc    $0x0,%edx
  8005ce:	f7 da                	neg    %edx
  8005d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005d3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005d6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005de:	e9 19 01 00 00       	jmp    8006fc <vprintfmt+0x436>
	if (lflag >= 2)
  8005e3:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8005e7:	7f 29                	jg     800612 <vprintfmt+0x34c>
	else if (lflag)
  8005e9:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8005ed:	74 44                	je     800633 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005fc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 40 04             	lea    0x4(%eax),%eax
  800605:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800608:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060d:	e9 ea 00 00 00       	jmp    8006fc <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8b 50 04             	mov    0x4(%eax),%edx
  800618:	8b 00                	mov    (%eax),%eax
  80061a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80061d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 40 08             	lea    0x8(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800629:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062e:	e9 c9 00 00 00       	jmp    8006fc <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8b 00                	mov    (%eax),%eax
  800638:	ba 00 00 00 00       	mov    $0x0,%edx
  80063d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800640:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 40 04             	lea    0x4(%eax),%eax
  800649:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800651:	e9 a6 00 00 00       	jmp    8006fc <vprintfmt+0x436>
			putch('0', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	56                   	push   %esi
  80065a:	6a 30                	push   $0x30
  80065c:	ff d3                	call   *%ebx
	if (lflag >= 2)
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800665:	7f 26                	jg     80068d <vprintfmt+0x3c7>
	else if (lflag)
  800667:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80066b:	74 3e                	je     8006ab <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8b 00                	mov    (%eax),%eax
  800672:	ba 00 00 00 00       	mov    $0x0,%edx
  800677:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80067a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8d 40 04             	lea    0x4(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800686:	b8 08 00 00 00       	mov    $0x8,%eax
  80068b:	eb 6f                	jmp    8006fc <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8b 50 04             	mov    0x4(%eax),%edx
  800693:	8b 00                	mov    (%eax),%eax
  800695:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800698:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8d 40 08             	lea    0x8(%eax),%eax
  8006a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8006a9:	eb 51                	jmp    8006fc <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 00                	mov    (%eax),%eax
  8006b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006b8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 40 04             	lea    0x4(%eax),%eax
  8006c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8006c9:	eb 31                	jmp    8006fc <vprintfmt+0x436>
			putch('0', putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	56                   	push   %esi
  8006cf:	6a 30                	push   $0x30
  8006d1:	ff d3                	call   *%ebx
			putch('x', putdat);
  8006d3:	83 c4 08             	add    $0x8,%esp
  8006d6:	56                   	push   %esi
  8006d7:	6a 78                	push   $0x78
  8006d9:	ff d3                	call   *%ebx
			num = (unsigned long long)
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8b 00                	mov    (%eax),%eax
  8006e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  8006eb:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8d 40 04             	lea    0x4(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f7:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006fc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800700:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800703:	89 c1                	mov    %eax,%ecx
  800705:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800708:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80070b:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800710:	89 c2                	mov    %eax,%edx
  800712:	39 c1                	cmp    %eax,%ecx
  800714:	0f 87 85 00 00 00    	ja     80079f <vprintfmt+0x4d9>
		tmp /= base;
  80071a:	89 d0                	mov    %edx,%eax
  80071c:	ba 00 00 00 00       	mov    $0x0,%edx
  800721:	f7 f1                	div    %ecx
		len++;
  800723:	83 c7 01             	add    $0x1,%edi
  800726:	eb e8                	jmp    800710 <vprintfmt+0x44a>
	if (lflag >= 2)
  800728:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80072c:	7f 26                	jg     800754 <vprintfmt+0x48e>
	else if (lflag)
  80072e:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800732:	74 3e                	je     800772 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 00                	mov    (%eax),%eax
  800739:	ba 00 00 00 00       	mov    $0x0,%edx
  80073e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800741:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8d 40 04             	lea    0x4(%eax),%eax
  80074a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074d:	b8 10 00 00 00       	mov    $0x10,%eax
  800752:	eb a8                	jmp    8006fc <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8b 50 04             	mov    0x4(%eax),%edx
  80075a:	8b 00                	mov    (%eax),%eax
  80075c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80075f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8d 40 08             	lea    0x8(%eax),%eax
  800768:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076b:	b8 10 00 00 00       	mov    $0x10,%eax
  800770:	eb 8a                	jmp    8006fc <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8b 00                	mov    (%eax),%eax
  800777:	ba 00 00 00 00       	mov    $0x0,%edx
  80077c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80077f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800782:	8b 45 14             	mov    0x14(%ebp),%eax
  800785:	8d 40 04             	lea    0x4(%eax),%eax
  800788:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80078b:	b8 10 00 00 00       	mov    $0x10,%eax
  800790:	e9 67 ff ff ff       	jmp    8006fc <vprintfmt+0x436>
			base = 10;
  800795:	b8 0a 00 00 00       	mov    $0xa,%eax
  80079a:	e9 5d ff ff ff       	jmp    8006fc <vprintfmt+0x436>
  80079f:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8007a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007a5:	29 f8                	sub    %edi,%eax
  8007a7:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8007a9:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8007ad:	74 15                	je     8007c4 <vprintfmt+0x4fe>
		while (width > 0) {
  8007af:	85 ff                	test   %edi,%edi
  8007b1:	7e 48                	jle    8007fb <vprintfmt+0x535>
			putch(padc, putdat);
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	56                   	push   %esi
  8007b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ba:	ff d3                	call   *%ebx
			width--;
  8007bc:	83 ef 01             	sub    $0x1,%edi
  8007bf:	83 c4 10             	add    $0x10,%esp
  8007c2:	eb eb                	jmp    8007af <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  8007c4:	83 ec 0c             	sub    $0xc,%esp
  8007c7:	6a 2d                	push   $0x2d
  8007c9:	ff 75 cc             	pushl  -0x34(%ebp)
  8007cc:	ff 75 c8             	pushl  -0x38(%ebp)
  8007cf:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007d2:	ff 75 d0             	pushl  -0x30(%ebp)
  8007d5:	89 f2                	mov    %esi,%edx
  8007d7:	89 d8                	mov    %ebx,%eax
  8007d9:	e8 1e fa ff ff       	call   8001fc <printnum_helper>
		width -= len;
  8007de:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007e1:	2b 7d cc             	sub    -0x34(%ebp),%edi
  8007e4:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  8007e7:	85 ff                	test   %edi,%edi
  8007e9:	7e 2e                	jle    800819 <vprintfmt+0x553>
			putch(padc, putdat);
  8007eb:	83 ec 08             	sub    $0x8,%esp
  8007ee:	56                   	push   %esi
  8007ef:	6a 20                	push   $0x20
  8007f1:	ff d3                	call   *%ebx
			width--;
  8007f3:	83 ef 01             	sub    $0x1,%edi
  8007f6:	83 c4 10             	add    $0x10,%esp
  8007f9:	eb ec                	jmp    8007e7 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  8007fb:	83 ec 0c             	sub    $0xc,%esp
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	ff 75 cc             	pushl  -0x34(%ebp)
  800804:	ff 75 c8             	pushl  -0x38(%ebp)
  800807:	ff 75 d4             	pushl  -0x2c(%ebp)
  80080a:	ff 75 d0             	pushl  -0x30(%ebp)
  80080d:	89 f2                	mov    %esi,%edx
  80080f:	89 d8                	mov    %ebx,%eax
  800811:	e8 e6 f9 ff ff       	call   8001fc <printnum_helper>
  800816:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800819:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80081c:	83 c7 01             	add    $0x1,%edi
  80081f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800823:	83 f8 25             	cmp    $0x25,%eax
  800826:	0f 84 b1 fa ff ff    	je     8002dd <vprintfmt+0x17>
			if (ch == '\0')
  80082c:	85 c0                	test   %eax,%eax
  80082e:	0f 84 a1 00 00 00    	je     8008d5 <vprintfmt+0x60f>
			putch(ch, putdat);
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	56                   	push   %esi
  800838:	50                   	push   %eax
  800839:	ff d3                	call   *%ebx
  80083b:	83 c4 10             	add    $0x10,%esp
  80083e:	eb dc                	jmp    80081c <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800840:	8b 45 14             	mov    0x14(%ebp),%eax
  800843:	83 c0 04             	add    $0x4,%eax
  800846:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800849:	8b 45 14             	mov    0x14(%ebp),%eax
  80084c:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  80084e:	85 ff                	test   %edi,%edi
  800850:	74 15                	je     800867 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800852:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800858:	7f 29                	jg     800883 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  80085a:	0f b6 06             	movzbl (%esi),%eax
  80085d:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  80085f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800862:	89 45 14             	mov    %eax,0x14(%ebp)
  800865:	eb b2                	jmp    800819 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800867:	68 b4 13 80 00       	push   $0x8013b4
  80086c:	68 1c 13 80 00       	push   $0x80131c
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	e8 31 fa ff ff       	call   8002a9 <printfmt>
  800878:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  80087b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80087e:	89 45 14             	mov    %eax,0x14(%ebp)
  800881:	eb 96                	jmp    800819 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800883:	68 ec 13 80 00       	push   $0x8013ec
  800888:	68 1c 13 80 00       	push   $0x80131c
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
  80088f:	e8 15 fa ff ff       	call   8002a9 <printfmt>
				*res = -1;
  800894:	c6 07 ff             	movb   $0xff,(%edi)
  800897:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  80089a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80089d:	89 45 14             	mov    %eax,0x14(%ebp)
  8008a0:	e9 74 ff ff ff       	jmp    800819 <vprintfmt+0x553>
			putch(ch, putdat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	56                   	push   %esi
  8008a9:	6a 25                	push   $0x25
  8008ab:	ff d3                	call   *%ebx
			break;
  8008ad:	83 c4 10             	add    $0x10,%esp
  8008b0:	e9 64 ff ff ff       	jmp    800819 <vprintfmt+0x553>
			putch('%', putdat);
  8008b5:	83 ec 08             	sub    $0x8,%esp
  8008b8:	56                   	push   %esi
  8008b9:	6a 25                	push   $0x25
  8008bb:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008bd:	83 c4 10             	add    $0x10,%esp
  8008c0:	89 f8                	mov    %edi,%eax
  8008c2:	eb 03                	jmp    8008c7 <vprintfmt+0x601>
  8008c4:	83 e8 01             	sub    $0x1,%eax
  8008c7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008cb:	75 f7                	jne    8008c4 <vprintfmt+0x5fe>
  8008cd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008d0:	e9 44 ff ff ff       	jmp    800819 <vprintfmt+0x553>
}
  8008d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008d8:	5b                   	pop    %ebx
  8008d9:	5e                   	pop    %esi
  8008da:	5f                   	pop    %edi
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	83 ec 18             	sub    $0x18,%esp
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ec:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008fa:	85 c0                	test   %eax,%eax
  8008fc:	74 26                	je     800924 <vsnprintf+0x47>
  8008fe:	85 d2                	test   %edx,%edx
  800900:	7e 22                	jle    800924 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800902:	ff 75 14             	pushl  0x14(%ebp)
  800905:	ff 75 10             	pushl  0x10(%ebp)
  800908:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80090b:	50                   	push   %eax
  80090c:	68 8c 02 80 00       	push   $0x80028c
  800911:	e8 b0 f9 ff ff       	call   8002c6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800916:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800919:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80091c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80091f:	83 c4 10             	add    $0x10,%esp
}
  800922:	c9                   	leave  
  800923:	c3                   	ret    
		return -E_INVAL;
  800924:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800929:	eb f7                	jmp    800922 <vsnprintf+0x45>

0080092b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800931:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800934:	50                   	push   %eax
  800935:	ff 75 10             	pushl  0x10(%ebp)
  800938:	ff 75 0c             	pushl  0xc(%ebp)
  80093b:	ff 75 08             	pushl  0x8(%ebp)
  80093e:	e8 9a ff ff ff       	call   8008dd <vsnprintf>
	va_end(ap);

	return rc;
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80094b:	b8 00 00 00 00       	mov    $0x0,%eax
  800950:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800954:	74 05                	je     80095b <strlen+0x16>
		n++;
  800956:	83 c0 01             	add    $0x1,%eax
  800959:	eb f5                	jmp    800950 <strlen+0xb>
	return n;
}
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800963:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800966:	ba 00 00 00 00       	mov    $0x0,%edx
  80096b:	39 c2                	cmp    %eax,%edx
  80096d:	74 0d                	je     80097c <strnlen+0x1f>
  80096f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800973:	74 05                	je     80097a <strnlen+0x1d>
		n++;
  800975:	83 c2 01             	add    $0x1,%edx
  800978:	eb f1                	jmp    80096b <strnlen+0xe>
  80097a:	89 d0                	mov    %edx,%eax
	return n;
}
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	53                   	push   %ebx
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800988:	ba 00 00 00 00       	mov    $0x0,%edx
  80098d:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800991:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800994:	83 c2 01             	add    $0x1,%edx
  800997:	84 c9                	test   %cl,%cl
  800999:	75 f2                	jne    80098d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80099b:	5b                   	pop    %ebx
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	53                   	push   %ebx
  8009a2:	83 ec 10             	sub    $0x10,%esp
  8009a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a8:	53                   	push   %ebx
  8009a9:	e8 97 ff ff ff       	call   800945 <strlen>
  8009ae:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009b1:	ff 75 0c             	pushl  0xc(%ebp)
  8009b4:	01 d8                	add    %ebx,%eax
  8009b6:	50                   	push   %eax
  8009b7:	e8 c2 ff ff ff       	call   80097e <strcpy>
	return dst;
}
  8009bc:	89 d8                	mov    %ebx,%eax
  8009be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ce:	89 c6                	mov    %eax,%esi
  8009d0:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d3:	89 c2                	mov    %eax,%edx
  8009d5:	39 f2                	cmp    %esi,%edx
  8009d7:	74 11                	je     8009ea <strncpy+0x27>
		*dst++ = *src;
  8009d9:	83 c2 01             	add    $0x1,%edx
  8009dc:	0f b6 19             	movzbl (%ecx),%ebx
  8009df:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009e2:	80 fb 01             	cmp    $0x1,%bl
  8009e5:	83 d9 ff             	sbb    $0xffffffff,%ecx
  8009e8:	eb eb                	jmp    8009d5 <strncpy+0x12>
	}
	return ret;
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f9:	8b 55 10             	mov    0x10(%ebp),%edx
  8009fc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009fe:	85 d2                	test   %edx,%edx
  800a00:	74 21                	je     800a23 <strlcpy+0x35>
  800a02:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a06:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800a08:	39 c2                	cmp    %eax,%edx
  800a0a:	74 14                	je     800a20 <strlcpy+0x32>
  800a0c:	0f b6 19             	movzbl (%ecx),%ebx
  800a0f:	84 db                	test   %bl,%bl
  800a11:	74 0b                	je     800a1e <strlcpy+0x30>
			*dst++ = *src++;
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	83 c2 01             	add    $0x1,%edx
  800a19:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a1c:	eb ea                	jmp    800a08 <strlcpy+0x1a>
  800a1e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a20:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a23:	29 f0                	sub    %esi,%eax
}
  800a25:	5b                   	pop    %ebx
  800a26:	5e                   	pop    %esi
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a32:	0f b6 01             	movzbl (%ecx),%eax
  800a35:	84 c0                	test   %al,%al
  800a37:	74 0c                	je     800a45 <strcmp+0x1c>
  800a39:	3a 02                	cmp    (%edx),%al
  800a3b:	75 08                	jne    800a45 <strcmp+0x1c>
		p++, q++;
  800a3d:	83 c1 01             	add    $0x1,%ecx
  800a40:	83 c2 01             	add    $0x1,%edx
  800a43:	eb ed                	jmp    800a32 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a45:	0f b6 c0             	movzbl %al,%eax
  800a48:	0f b6 12             	movzbl (%edx),%edx
  800a4b:	29 d0                	sub    %edx,%eax
}
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	53                   	push   %ebx
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a59:	89 c3                	mov    %eax,%ebx
  800a5b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a5e:	eb 06                	jmp    800a66 <strncmp+0x17>
		n--, p++, q++;
  800a60:	83 c0 01             	add    $0x1,%eax
  800a63:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a66:	39 d8                	cmp    %ebx,%eax
  800a68:	74 16                	je     800a80 <strncmp+0x31>
  800a6a:	0f b6 08             	movzbl (%eax),%ecx
  800a6d:	84 c9                	test   %cl,%cl
  800a6f:	74 04                	je     800a75 <strncmp+0x26>
  800a71:	3a 0a                	cmp    (%edx),%cl
  800a73:	74 eb                	je     800a60 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a75:	0f b6 00             	movzbl (%eax),%eax
  800a78:	0f b6 12             	movzbl (%edx),%edx
  800a7b:	29 d0                	sub    %edx,%eax
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    
		return 0;
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
  800a85:	eb f6                	jmp    800a7d <strncmp+0x2e>

00800a87 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a91:	0f b6 10             	movzbl (%eax),%edx
  800a94:	84 d2                	test   %dl,%dl
  800a96:	74 09                	je     800aa1 <strchr+0x1a>
		if (*s == c)
  800a98:	38 ca                	cmp    %cl,%dl
  800a9a:	74 0a                	je     800aa6 <strchr+0x1f>
	for (; *s; s++)
  800a9c:	83 c0 01             	add    $0x1,%eax
  800a9f:	eb f0                	jmp    800a91 <strchr+0xa>
			return (char *) s;
	return 0;
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ab5:	38 ca                	cmp    %cl,%dl
  800ab7:	74 09                	je     800ac2 <strfind+0x1a>
  800ab9:	84 d2                	test   %dl,%dl
  800abb:	74 05                	je     800ac2 <strfind+0x1a>
	for (; *s; s++)
  800abd:	83 c0 01             	add    $0x1,%eax
  800ac0:	eb f0                	jmp    800ab2 <strfind+0xa>
			break;
	return (char *) s;
}
  800ac2:	5d                   	pop    %ebp
  800ac3:	c3                   	ret    

00800ac4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	57                   	push   %edi
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	8b 7d 08             	mov    0x8(%ebp),%edi
  800acd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad0:	85 c9                	test   %ecx,%ecx
  800ad2:	74 31                	je     800b05 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad4:	89 f8                	mov    %edi,%eax
  800ad6:	09 c8                	or     %ecx,%eax
  800ad8:	a8 03                	test   $0x3,%al
  800ada:	75 23                	jne    800aff <memset+0x3b>
		c &= 0xFF;
  800adc:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae0:	89 d3                	mov    %edx,%ebx
  800ae2:	c1 e3 08             	shl    $0x8,%ebx
  800ae5:	89 d0                	mov    %edx,%eax
  800ae7:	c1 e0 18             	shl    $0x18,%eax
  800aea:	89 d6                	mov    %edx,%esi
  800aec:	c1 e6 10             	shl    $0x10,%esi
  800aef:	09 f0                	or     %esi,%eax
  800af1:	09 c2                	or     %eax,%edx
  800af3:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800af5:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800af8:	89 d0                	mov    %edx,%eax
  800afa:	fc                   	cld    
  800afb:	f3 ab                	rep stos %eax,%es:(%edi)
  800afd:	eb 06                	jmp    800b05 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b02:	fc                   	cld    
  800b03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b05:	89 f8                	mov    %edi,%eax
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5f                   	pop    %edi
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
  800b14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b1a:	39 c6                	cmp    %eax,%esi
  800b1c:	73 32                	jae    800b50 <memmove+0x44>
  800b1e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b21:	39 c2                	cmp    %eax,%edx
  800b23:	76 2b                	jbe    800b50 <memmove+0x44>
		s += n;
		d += n;
  800b25:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b28:	89 fe                	mov    %edi,%esi
  800b2a:	09 ce                	or     %ecx,%esi
  800b2c:	09 d6                	or     %edx,%esi
  800b2e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b34:	75 0e                	jne    800b44 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b36:	83 ef 04             	sub    $0x4,%edi
  800b39:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b3c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b3f:	fd                   	std    
  800b40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b42:	eb 09                	jmp    800b4d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b44:	83 ef 01             	sub    $0x1,%edi
  800b47:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b4a:	fd                   	std    
  800b4b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b4d:	fc                   	cld    
  800b4e:	eb 1a                	jmp    800b6a <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b50:	89 c2                	mov    %eax,%edx
  800b52:	09 ca                	or     %ecx,%edx
  800b54:	09 f2                	or     %esi,%edx
  800b56:	f6 c2 03             	test   $0x3,%dl
  800b59:	75 0a                	jne    800b65 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b5b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b5e:	89 c7                	mov    %eax,%edi
  800b60:	fc                   	cld    
  800b61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b63:	eb 05                	jmp    800b6a <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b65:	89 c7                	mov    %eax,%edi
  800b67:	fc                   	cld    
  800b68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b6a:	5e                   	pop    %esi
  800b6b:	5f                   	pop    %edi
  800b6c:	5d                   	pop    %ebp
  800b6d:	c3                   	ret    

00800b6e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b74:	ff 75 10             	pushl  0x10(%ebp)
  800b77:	ff 75 0c             	pushl  0xc(%ebp)
  800b7a:	ff 75 08             	pushl  0x8(%ebp)
  800b7d:	e8 8a ff ff ff       	call   800b0c <memmove>
}
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8f:	89 c6                	mov    %eax,%esi
  800b91:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b94:	39 f0                	cmp    %esi,%eax
  800b96:	74 1c                	je     800bb4 <memcmp+0x30>
		if (*s1 != *s2)
  800b98:	0f b6 08             	movzbl (%eax),%ecx
  800b9b:	0f b6 1a             	movzbl (%edx),%ebx
  800b9e:	38 d9                	cmp    %bl,%cl
  800ba0:	75 08                	jne    800baa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	83 c2 01             	add    $0x1,%edx
  800ba8:	eb ea                	jmp    800b94 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800baa:	0f b6 c1             	movzbl %cl,%eax
  800bad:	0f b6 db             	movzbl %bl,%ebx
  800bb0:	29 d8                	sub    %ebx,%eax
  800bb2:	eb 05                	jmp    800bb9 <memcmp+0x35>
	}

	return 0;
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bc6:	89 c2                	mov    %eax,%edx
  800bc8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bcb:	39 d0                	cmp    %edx,%eax
  800bcd:	73 09                	jae    800bd8 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bcf:	38 08                	cmp    %cl,(%eax)
  800bd1:	74 05                	je     800bd8 <memfind+0x1b>
	for (; s < ends; s++)
  800bd3:	83 c0 01             	add    $0x1,%eax
  800bd6:	eb f3                	jmp    800bcb <memfind+0xe>
			break;
	return (void *) s;
}
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be6:	eb 03                	jmp    800beb <strtol+0x11>
		s++;
  800be8:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800beb:	0f b6 01             	movzbl (%ecx),%eax
  800bee:	3c 20                	cmp    $0x20,%al
  800bf0:	74 f6                	je     800be8 <strtol+0xe>
  800bf2:	3c 09                	cmp    $0x9,%al
  800bf4:	74 f2                	je     800be8 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bf6:	3c 2b                	cmp    $0x2b,%al
  800bf8:	74 2a                	je     800c24 <strtol+0x4a>
	int neg = 0;
  800bfa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bff:	3c 2d                	cmp    $0x2d,%al
  800c01:	74 2b                	je     800c2e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c03:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c09:	75 0f                	jne    800c1a <strtol+0x40>
  800c0b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c0e:	74 28                	je     800c38 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c10:	85 db                	test   %ebx,%ebx
  800c12:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c17:	0f 44 d8             	cmove  %eax,%ebx
  800c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c22:	eb 50                	jmp    800c74 <strtol+0x9a>
		s++;
  800c24:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c27:	bf 00 00 00 00       	mov    $0x0,%edi
  800c2c:	eb d5                	jmp    800c03 <strtol+0x29>
		s++, neg = 1;
  800c2e:	83 c1 01             	add    $0x1,%ecx
  800c31:	bf 01 00 00 00       	mov    $0x1,%edi
  800c36:	eb cb                	jmp    800c03 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c38:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c3c:	74 0e                	je     800c4c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c3e:	85 db                	test   %ebx,%ebx
  800c40:	75 d8                	jne    800c1a <strtol+0x40>
		s++, base = 8;
  800c42:	83 c1 01             	add    $0x1,%ecx
  800c45:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c4a:	eb ce                	jmp    800c1a <strtol+0x40>
		s += 2, base = 16;
  800c4c:	83 c1 02             	add    $0x2,%ecx
  800c4f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c54:	eb c4                	jmp    800c1a <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c56:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c59:	89 f3                	mov    %esi,%ebx
  800c5b:	80 fb 19             	cmp    $0x19,%bl
  800c5e:	77 29                	ja     800c89 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c60:	0f be d2             	movsbl %dl,%edx
  800c63:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c66:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c69:	7d 30                	jge    800c9b <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c6b:	83 c1 01             	add    $0x1,%ecx
  800c6e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c72:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c74:	0f b6 11             	movzbl (%ecx),%edx
  800c77:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c7a:	89 f3                	mov    %esi,%ebx
  800c7c:	80 fb 09             	cmp    $0x9,%bl
  800c7f:	77 d5                	ja     800c56 <strtol+0x7c>
			dig = *s - '0';
  800c81:	0f be d2             	movsbl %dl,%edx
  800c84:	83 ea 30             	sub    $0x30,%edx
  800c87:	eb dd                	jmp    800c66 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800c89:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c8c:	89 f3                	mov    %esi,%ebx
  800c8e:	80 fb 19             	cmp    $0x19,%bl
  800c91:	77 08                	ja     800c9b <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c93:	0f be d2             	movsbl %dl,%edx
  800c96:	83 ea 37             	sub    $0x37,%edx
  800c99:	eb cb                	jmp    800c66 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9f:	74 05                	je     800ca6 <strtol+0xcc>
		*endptr = (char *) s;
  800ca1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ca6:	89 c2                	mov    %eax,%edx
  800ca8:	f7 da                	neg    %edx
  800caa:	85 ff                	test   %edi,%edi
  800cac:	0f 45 c2             	cmovne %edx,%eax
}
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cba:	b8 00 00 00 00       	mov    $0x0,%eax
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc5:	89 c3                	mov    %eax,%ebx
  800cc7:	89 c7                	mov    %eax,%edi
  800cc9:	89 c6                	mov    %eax,%esi
  800ccb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	57                   	push   %edi
  800cd6:	56                   	push   %esi
  800cd7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ce2:	89 d1                	mov    %edx,%ecx
  800ce4:	89 d3                	mov    %edx,%ebx
  800ce6:	89 d7                	mov    %edx,%edi
  800ce8:	89 d6                	mov    %edx,%esi
  800cea:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cec:	5b                   	pop    %ebx
  800ced:	5e                   	pop    %esi
  800cee:	5f                   	pop    %edi
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cfa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cff:	8b 55 08             	mov    0x8(%ebp),%edx
  800d02:	b8 03 00 00 00       	mov    $0x3,%eax
  800d07:	89 cb                	mov    %ecx,%ebx
  800d09:	89 cf                	mov    %ecx,%edi
  800d0b:	89 ce                	mov    %ecx,%esi
  800d0d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0f:	85 c0                	test   %eax,%eax
  800d11:	7f 08                	jg     800d1b <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	50                   	push   %eax
  800d1f:	6a 03                	push   $0x3
  800d21:	68 c4 15 80 00       	push   $0x8015c4
  800d26:	6a 23                	push   $0x23
  800d28:	68 e1 15 80 00       	push   $0x8015e1
  800d2d:	e8 db f3 ff ff       	call   80010d <_panic>

00800d32 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d38:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3d:	b8 02 00 00 00       	mov    $0x2,%eax
  800d42:	89 d1                	mov    %edx,%ecx
  800d44:	89 d3                	mov    %edx,%ebx
  800d46:	89 d7                	mov    %edx,%edi
  800d48:	89 d6                	mov    %edx,%esi
  800d4a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <sys_yield>:

void
sys_yield(void)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d57:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d61:	89 d1                	mov    %edx,%ecx
  800d63:	89 d3                	mov    %edx,%ebx
  800d65:	89 d7                	mov    %edx,%edi
  800d67:	89 d6                	mov    %edx,%esi
  800d69:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	53                   	push   %ebx
  800d76:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d79:	be 00 00 00 00       	mov    $0x0,%esi
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d84:	b8 04 00 00 00       	mov    $0x4,%eax
  800d89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8c:	89 f7                	mov    %esi,%edi
  800d8e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d90:	85 c0                	test   %eax,%eax
  800d92:	7f 08                	jg     800d9c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	50                   	push   %eax
  800da0:	6a 04                	push   $0x4
  800da2:	68 c4 15 80 00       	push   $0x8015c4
  800da7:	6a 23                	push   $0x23
  800da9:	68 e1 15 80 00       	push   $0x8015e1
  800dae:	e8 5a f3 ff ff       	call   80010d <_panic>

00800db3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	57                   	push   %edi
  800db7:	56                   	push   %esi
  800db8:	53                   	push   %ebx
  800db9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dca:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dcd:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	7f 08                	jg     800dde <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	50                   	push   %eax
  800de2:	6a 05                	push   $0x5
  800de4:	68 c4 15 80 00       	push   $0x8015c4
  800de9:	6a 23                	push   $0x23
  800deb:	68 e1 15 80 00       	push   $0x8015e1
  800df0:	e8 18 f3 ff ff       	call   80010d <_panic>

00800df5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	57                   	push   %edi
  800df9:	56                   	push   %esi
  800dfa:	53                   	push   %ebx
  800dfb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e03:	8b 55 08             	mov    0x8(%ebp),%edx
  800e06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e09:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0e:	89 df                	mov    %ebx,%edi
  800e10:	89 de                	mov    %ebx,%esi
  800e12:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e14:	85 c0                	test   %eax,%eax
  800e16:	7f 08                	jg     800e20 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e20:	83 ec 0c             	sub    $0xc,%esp
  800e23:	50                   	push   %eax
  800e24:	6a 06                	push   $0x6
  800e26:	68 c4 15 80 00       	push   $0x8015c4
  800e2b:	6a 23                	push   $0x23
  800e2d:	68 e1 15 80 00       	push   $0x8015e1
  800e32:	e8 d6 f2 ff ff       	call   80010d <_panic>

00800e37 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	57                   	push   %edi
  800e3b:	56                   	push   %esi
  800e3c:	53                   	push   %ebx
  800e3d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e40:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e50:	89 df                	mov    %ebx,%edi
  800e52:	89 de                	mov    %ebx,%esi
  800e54:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e56:	85 c0                	test   %eax,%eax
  800e58:	7f 08                	jg     800e62 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e62:	83 ec 0c             	sub    $0xc,%esp
  800e65:	50                   	push   %eax
  800e66:	6a 08                	push   $0x8
  800e68:	68 c4 15 80 00       	push   $0x8015c4
  800e6d:	6a 23                	push   $0x23
  800e6f:	68 e1 15 80 00       	push   $0x8015e1
  800e74:	e8 94 f2 ff ff       	call   80010d <_panic>

00800e79 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	57                   	push   %edi
  800e7d:	56                   	push   %esi
  800e7e:	53                   	push   %ebx
  800e7f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e82:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e87:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e92:	89 df                	mov    %ebx,%edi
  800e94:	89 de                	mov    %ebx,%esi
  800e96:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	7f 08                	jg     800ea4 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5f                   	pop    %edi
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	50                   	push   %eax
  800ea8:	6a 09                	push   $0x9
  800eaa:	68 c4 15 80 00       	push   $0x8015c4
  800eaf:	6a 23                	push   $0x23
  800eb1:	68 e1 15 80 00       	push   $0x8015e1
  800eb6:	e8 52 f2 ff ff       	call   80010d <_panic>

00800ebb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	57                   	push   %edi
  800ebf:	56                   	push   %esi
  800ec0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ec1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ecc:	be 00 00 00 00       	mov    $0x0,%esi
  800ed1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ed4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ed7:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ed9:	5b                   	pop    %ebx
  800eda:	5e                   	pop    %esi
  800edb:	5f                   	pop    %edi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ee7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eec:	8b 55 08             	mov    0x8(%ebp),%edx
  800eef:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ef4:	89 cb                	mov    %ecx,%ebx
  800ef6:	89 cf                	mov    %ecx,%edi
  800ef8:	89 ce                	mov    %ecx,%esi
  800efa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800efc:	85 c0                	test   %eax,%eax
  800efe:	7f 08                	jg     800f08 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f03:	5b                   	pop    %ebx
  800f04:	5e                   	pop    %esi
  800f05:	5f                   	pop    %edi
  800f06:	5d                   	pop    %ebp
  800f07:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	50                   	push   %eax
  800f0c:	6a 0c                	push   $0xc
  800f0e:	68 c4 15 80 00       	push   $0x8015c4
  800f13:	6a 23                	push   $0x23
  800f15:	68 e1 15 80 00       	push   $0x8015e1
  800f1a:	e8 ee f1 ff ff       	call   80010d <_panic>

00800f1f <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	57                   	push   %edi
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f30:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f35:	89 df                	mov    %ebx,%edi
  800f37:	89 de                	mov    %ebx,%esi
  800f39:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5f                   	pop    %edi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f53:	89 cb                	mov    %ecx,%ebx
  800f55:	89 cf                	mov    %ecx,%edi
  800f57:	89 ce                	mov    %ecx,%esi
  800f59:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f5b:	5b                   	pop    %ebx
  800f5c:	5e                   	pop    %esi
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f66:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800f6d:	74 0a                	je     800f79 <set_pgfault_handler+0x19>
		if ((r = sys_env_set_pgfault_upcall((envid_t)0, _pgfault_upcall)) < 0)
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f72:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800f77:	c9                   	leave  
  800f78:	c3                   	ret    
		if ((r = sys_page_alloc((envid_t)0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W)) < 0) 
  800f79:	83 ec 04             	sub    $0x4,%esp
  800f7c:	6a 07                	push   $0x7
  800f7e:	68 00 f0 bf ee       	push   $0xeebff000
  800f83:	6a 00                	push   $0x0
  800f85:	e8 e6 fd ff ff       	call   800d70 <sys_page_alloc>
  800f8a:	83 c4 10             	add    $0x10,%esp
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	78 2a                	js     800fbb <set_pgfault_handler+0x5b>
		if ((r = sys_env_set_pgfault_upcall((envid_t)0, _pgfault_upcall)) < 0)
  800f91:	83 ec 08             	sub    $0x8,%esp
  800f94:	68 cf 0f 80 00       	push   $0x800fcf
  800f99:	6a 00                	push   $0x0
  800f9b:	e8 d9 fe ff ff       	call   800e79 <sys_env_set_pgfault_upcall>
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	79 c8                	jns    800f6f <set_pgfault_handler+0xf>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail");
  800fa7:	83 ec 04             	sub    $0x4,%esp
  800faa:	68 1c 16 80 00       	push   $0x80161c
  800faf:	6a 23                	push   $0x23
  800fb1:	68 54 16 80 00       	push   $0x801654
  800fb6:	e8 52 f1 ff ff       	call   80010d <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail");
  800fbb:	83 ec 04             	sub    $0x4,%esp
  800fbe:	68 f0 15 80 00       	push   $0x8015f0
  800fc3:	6a 21                	push   $0x21
  800fc5:	68 54 16 80 00       	push   $0x801654
  800fca:	e8 3e f1 ff ff       	call   80010d <_panic>

00800fcf <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800fcf:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800fd0:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800fd5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800fd7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %ebp
  800fda:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl 48(%esp), %ebx
  800fde:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800fe2:	83 eb 04             	sub    $0x4,%ebx
	movl %ebp, (%ebx)
  800fe5:	89 2b                	mov    %ebp,(%ebx)
	movl %ebx, 48(%esp)
  800fe7:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800feb:	83 c4 08             	add    $0x8,%esp
	popal
  800fee:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800fef:	83 c4 04             	add    $0x4,%esp
	popfl
  800ff2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800ff3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800ff4:	c3                   	ret    
  800ff5:	66 90                	xchg   %ax,%ax
  800ff7:	66 90                	xchg   %ax,%ax
  800ff9:	66 90                	xchg   %ax,%ax
  800ffb:	66 90                	xchg   %ax,%ax
  800ffd:	66 90                	xchg   %ax,%ax
  800fff:	90                   	nop

00801000 <__udivdi3>:
  801000:	55                   	push   %ebp
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
  801004:	83 ec 1c             	sub    $0x1c,%esp
  801007:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80100b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80100f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801013:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801017:	85 d2                	test   %edx,%edx
  801019:	75 4d                	jne    801068 <__udivdi3+0x68>
  80101b:	39 f3                	cmp    %esi,%ebx
  80101d:	76 19                	jbe    801038 <__udivdi3+0x38>
  80101f:	31 ff                	xor    %edi,%edi
  801021:	89 e8                	mov    %ebp,%eax
  801023:	89 f2                	mov    %esi,%edx
  801025:	f7 f3                	div    %ebx
  801027:	89 fa                	mov    %edi,%edx
  801029:	83 c4 1c             	add    $0x1c,%esp
  80102c:	5b                   	pop    %ebx
  80102d:	5e                   	pop    %esi
  80102e:	5f                   	pop    %edi
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    
  801031:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801038:	89 d9                	mov    %ebx,%ecx
  80103a:	85 db                	test   %ebx,%ebx
  80103c:	75 0b                	jne    801049 <__udivdi3+0x49>
  80103e:	b8 01 00 00 00       	mov    $0x1,%eax
  801043:	31 d2                	xor    %edx,%edx
  801045:	f7 f3                	div    %ebx
  801047:	89 c1                	mov    %eax,%ecx
  801049:	31 d2                	xor    %edx,%edx
  80104b:	89 f0                	mov    %esi,%eax
  80104d:	f7 f1                	div    %ecx
  80104f:	89 c6                	mov    %eax,%esi
  801051:	89 e8                	mov    %ebp,%eax
  801053:	89 f7                	mov    %esi,%edi
  801055:	f7 f1                	div    %ecx
  801057:	89 fa                	mov    %edi,%edx
  801059:	83 c4 1c             	add    $0x1c,%esp
  80105c:	5b                   	pop    %ebx
  80105d:	5e                   	pop    %esi
  80105e:	5f                   	pop    %edi
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    
  801061:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801068:	39 f2                	cmp    %esi,%edx
  80106a:	77 1c                	ja     801088 <__udivdi3+0x88>
  80106c:	0f bd fa             	bsr    %edx,%edi
  80106f:	83 f7 1f             	xor    $0x1f,%edi
  801072:	75 2c                	jne    8010a0 <__udivdi3+0xa0>
  801074:	39 f2                	cmp    %esi,%edx
  801076:	72 06                	jb     80107e <__udivdi3+0x7e>
  801078:	31 c0                	xor    %eax,%eax
  80107a:	39 eb                	cmp    %ebp,%ebx
  80107c:	77 a9                	ja     801027 <__udivdi3+0x27>
  80107e:	b8 01 00 00 00       	mov    $0x1,%eax
  801083:	eb a2                	jmp    801027 <__udivdi3+0x27>
  801085:	8d 76 00             	lea    0x0(%esi),%esi
  801088:	31 ff                	xor    %edi,%edi
  80108a:	31 c0                	xor    %eax,%eax
  80108c:	89 fa                	mov    %edi,%edx
  80108e:	83 c4 1c             	add    $0x1c,%esp
  801091:	5b                   	pop    %ebx
  801092:	5e                   	pop    %esi
  801093:	5f                   	pop    %edi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    
  801096:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80109d:	8d 76 00             	lea    0x0(%esi),%esi
  8010a0:	89 f9                	mov    %edi,%ecx
  8010a2:	b8 20 00 00 00       	mov    $0x20,%eax
  8010a7:	29 f8                	sub    %edi,%eax
  8010a9:	d3 e2                	shl    %cl,%edx
  8010ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8010af:	89 c1                	mov    %eax,%ecx
  8010b1:	89 da                	mov    %ebx,%edx
  8010b3:	d3 ea                	shr    %cl,%edx
  8010b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010b9:	09 d1                	or     %edx,%ecx
  8010bb:	89 f2                	mov    %esi,%edx
  8010bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010c1:	89 f9                	mov    %edi,%ecx
  8010c3:	d3 e3                	shl    %cl,%ebx
  8010c5:	89 c1                	mov    %eax,%ecx
  8010c7:	d3 ea                	shr    %cl,%edx
  8010c9:	89 f9                	mov    %edi,%ecx
  8010cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8010cf:	89 eb                	mov    %ebp,%ebx
  8010d1:	d3 e6                	shl    %cl,%esi
  8010d3:	89 c1                	mov    %eax,%ecx
  8010d5:	d3 eb                	shr    %cl,%ebx
  8010d7:	09 de                	or     %ebx,%esi
  8010d9:	89 f0                	mov    %esi,%eax
  8010db:	f7 74 24 08          	divl   0x8(%esp)
  8010df:	89 d6                	mov    %edx,%esi
  8010e1:	89 c3                	mov    %eax,%ebx
  8010e3:	f7 64 24 0c          	mull   0xc(%esp)
  8010e7:	39 d6                	cmp    %edx,%esi
  8010e9:	72 15                	jb     801100 <__udivdi3+0x100>
  8010eb:	89 f9                	mov    %edi,%ecx
  8010ed:	d3 e5                	shl    %cl,%ebp
  8010ef:	39 c5                	cmp    %eax,%ebp
  8010f1:	73 04                	jae    8010f7 <__udivdi3+0xf7>
  8010f3:	39 d6                	cmp    %edx,%esi
  8010f5:	74 09                	je     801100 <__udivdi3+0x100>
  8010f7:	89 d8                	mov    %ebx,%eax
  8010f9:	31 ff                	xor    %edi,%edi
  8010fb:	e9 27 ff ff ff       	jmp    801027 <__udivdi3+0x27>
  801100:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801103:	31 ff                	xor    %edi,%edi
  801105:	e9 1d ff ff ff       	jmp    801027 <__udivdi3+0x27>
  80110a:	66 90                	xchg   %ax,%ax
  80110c:	66 90                	xchg   %ax,%ax
  80110e:	66 90                	xchg   %ax,%ax

00801110 <__umoddi3>:
  801110:	55                   	push   %ebp
  801111:	57                   	push   %edi
  801112:	56                   	push   %esi
  801113:	53                   	push   %ebx
  801114:	83 ec 1c             	sub    $0x1c,%esp
  801117:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80111b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80111f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801127:	89 da                	mov    %ebx,%edx
  801129:	85 c0                	test   %eax,%eax
  80112b:	75 43                	jne    801170 <__umoddi3+0x60>
  80112d:	39 df                	cmp    %ebx,%edi
  80112f:	76 17                	jbe    801148 <__umoddi3+0x38>
  801131:	89 f0                	mov    %esi,%eax
  801133:	f7 f7                	div    %edi
  801135:	89 d0                	mov    %edx,%eax
  801137:	31 d2                	xor    %edx,%edx
  801139:	83 c4 1c             	add    $0x1c,%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5f                   	pop    %edi
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    
  801141:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801148:	89 fd                	mov    %edi,%ebp
  80114a:	85 ff                	test   %edi,%edi
  80114c:	75 0b                	jne    801159 <__umoddi3+0x49>
  80114e:	b8 01 00 00 00       	mov    $0x1,%eax
  801153:	31 d2                	xor    %edx,%edx
  801155:	f7 f7                	div    %edi
  801157:	89 c5                	mov    %eax,%ebp
  801159:	89 d8                	mov    %ebx,%eax
  80115b:	31 d2                	xor    %edx,%edx
  80115d:	f7 f5                	div    %ebp
  80115f:	89 f0                	mov    %esi,%eax
  801161:	f7 f5                	div    %ebp
  801163:	89 d0                	mov    %edx,%eax
  801165:	eb d0                	jmp    801137 <__umoddi3+0x27>
  801167:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80116e:	66 90                	xchg   %ax,%ax
  801170:	89 f1                	mov    %esi,%ecx
  801172:	39 d8                	cmp    %ebx,%eax
  801174:	76 0a                	jbe    801180 <__umoddi3+0x70>
  801176:	89 f0                	mov    %esi,%eax
  801178:	83 c4 1c             	add    $0x1c,%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5f                   	pop    %edi
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    
  801180:	0f bd e8             	bsr    %eax,%ebp
  801183:	83 f5 1f             	xor    $0x1f,%ebp
  801186:	75 20                	jne    8011a8 <__umoddi3+0x98>
  801188:	39 d8                	cmp    %ebx,%eax
  80118a:	0f 82 b0 00 00 00    	jb     801240 <__umoddi3+0x130>
  801190:	39 f7                	cmp    %esi,%edi
  801192:	0f 86 a8 00 00 00    	jbe    801240 <__umoddi3+0x130>
  801198:	89 c8                	mov    %ecx,%eax
  80119a:	83 c4 1c             	add    $0x1c,%esp
  80119d:	5b                   	pop    %ebx
  80119e:	5e                   	pop    %esi
  80119f:	5f                   	pop    %edi
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    
  8011a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011a8:	89 e9                	mov    %ebp,%ecx
  8011aa:	ba 20 00 00 00       	mov    $0x20,%edx
  8011af:	29 ea                	sub    %ebp,%edx
  8011b1:	d3 e0                	shl    %cl,%eax
  8011b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b7:	89 d1                	mov    %edx,%ecx
  8011b9:	89 f8                	mov    %edi,%eax
  8011bb:	d3 e8                	shr    %cl,%eax
  8011bd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8011c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011c5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8011c9:	09 c1                	or     %eax,%ecx
  8011cb:	89 d8                	mov    %ebx,%eax
  8011cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011d1:	89 e9                	mov    %ebp,%ecx
  8011d3:	d3 e7                	shl    %cl,%edi
  8011d5:	89 d1                	mov    %edx,%ecx
  8011d7:	d3 e8                	shr    %cl,%eax
  8011d9:	89 e9                	mov    %ebp,%ecx
  8011db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011df:	d3 e3                	shl    %cl,%ebx
  8011e1:	89 c7                	mov    %eax,%edi
  8011e3:	89 d1                	mov    %edx,%ecx
  8011e5:	89 f0                	mov    %esi,%eax
  8011e7:	d3 e8                	shr    %cl,%eax
  8011e9:	89 e9                	mov    %ebp,%ecx
  8011eb:	89 fa                	mov    %edi,%edx
  8011ed:	d3 e6                	shl    %cl,%esi
  8011ef:	09 d8                	or     %ebx,%eax
  8011f1:	f7 74 24 08          	divl   0x8(%esp)
  8011f5:	89 d1                	mov    %edx,%ecx
  8011f7:	89 f3                	mov    %esi,%ebx
  8011f9:	f7 64 24 0c          	mull   0xc(%esp)
  8011fd:	89 c6                	mov    %eax,%esi
  8011ff:	89 d7                	mov    %edx,%edi
  801201:	39 d1                	cmp    %edx,%ecx
  801203:	72 06                	jb     80120b <__umoddi3+0xfb>
  801205:	75 10                	jne    801217 <__umoddi3+0x107>
  801207:	39 c3                	cmp    %eax,%ebx
  801209:	73 0c                	jae    801217 <__umoddi3+0x107>
  80120b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80120f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801213:	89 d7                	mov    %edx,%edi
  801215:	89 c6                	mov    %eax,%esi
  801217:	89 ca                	mov    %ecx,%edx
  801219:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80121e:	29 f3                	sub    %esi,%ebx
  801220:	19 fa                	sbb    %edi,%edx
  801222:	89 d0                	mov    %edx,%eax
  801224:	d3 e0                	shl    %cl,%eax
  801226:	89 e9                	mov    %ebp,%ecx
  801228:	d3 eb                	shr    %cl,%ebx
  80122a:	d3 ea                	shr    %cl,%edx
  80122c:	09 d8                	or     %ebx,%eax
  80122e:	83 c4 1c             	add    $0x1c,%esp
  801231:	5b                   	pop    %ebx
  801232:	5e                   	pop    %esi
  801233:	5f                   	pop    %edi
  801234:	5d                   	pop    %ebp
  801235:	c3                   	ret    
  801236:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80123d:	8d 76 00             	lea    0x0(%esi),%esi
  801240:	89 da                	mov    %ebx,%edx
  801242:	29 fe                	sub    %edi,%esi
  801244:	19 c2                	sbb    %eax,%edx
  801246:	89 f1                	mov    %esi,%ecx
  801248:	89 c8                	mov    %ecx,%eax
  80124a:	e9 4b ff ff ff       	jmp    80119a <__umoddi3+0x8a>
