
obj/user/stresssched:     file format elf32-i386


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
  80002c:	e8 b4 00 00 00       	call   8000e5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 25 0d 00 00       	call   800d62 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 47 0f 00 00       	call   800f90 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0f                	je     80005c <umain+0x29>
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
			break;
	if (i == 20) {
		sys_yield();
  800055:	e8 27 0d 00 00       	call   800d81 <sys_yield>
		return;
  80005a:	eb 6b                	jmp    8000c7 <umain+0x94>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80005c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800062:	89 f2                	mov    %esi,%edx
  800064:	c1 e2 07             	shl    $0x7,%edx
  800067:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80006d:	eb 02                	jmp    800071 <umain+0x3e>
		asm volatile("pause");
  80006f:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800071:	8b 42 54             	mov    0x54(%edx),%eax
  800074:	85 c0                	test   %eax,%eax
  800076:	75 f7                	jne    80006f <umain+0x3c>
  800078:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80007d:	e8 ff 0c 00 00       	call   800d81 <sys_yield>
  800082:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  800087:	a1 04 20 80 00       	mov    0x802004,%eax
  80008c:	83 c0 01             	add    $0x1,%eax
  80008f:	a3 04 20 80 00       	mov    %eax,0x802004
		for (j = 0; j < 10000; j++)
  800094:	83 ea 01             	sub    $0x1,%edx
  800097:	75 ee                	jne    800087 <umain+0x54>
	for (i = 0; i < 10; i++) {
  800099:	83 eb 01             	sub    $0x1,%ebx
  80009c:	75 df                	jne    80007d <umain+0x4a>
	}

	if (counter != 10*10000)
  80009e:	a1 04 20 80 00       	mov    0x802004,%eax
  8000a3:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000a8:	75 24                	jne    8000ce <umain+0x9b>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000aa:	a1 08 20 80 00       	mov    0x802008,%eax
  8000af:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b2:	8b 40 48             	mov    0x48(%eax),%eax
  8000b5:	83 ec 04             	sub    $0x4,%esp
  8000b8:	52                   	push   %edx
  8000b9:	50                   	push   %eax
  8000ba:	68 5b 12 80 00       	push   $0x80125b
  8000bf:	e8 54 01 00 00       	call   800218 <cprintf>
  8000c4:	83 c4 10             	add    $0x10,%esp

}
  8000c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000ce:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d3:	50                   	push   %eax
  8000d4:	68 20 12 80 00       	push   $0x801220
  8000d9:	6a 21                	push   $0x21
  8000db:	68 48 12 80 00       	push   $0x801248
  8000e0:	e8 58 00 00 00       	call   80013d <_panic>

008000e5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000ed:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f0:	e8 6d 0c 00 00       	call   800d62 <sys_getenvid>
  8000f5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fa:	c1 e0 07             	shl    $0x7,%eax
  8000fd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800102:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800107:	85 db                	test   %ebx,%ebx
  800109:	7e 07                	jle    800112 <libmain+0x2d>
		binaryname = argv[0];
  80010b:	8b 06                	mov    (%esi),%eax
  80010d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800112:	83 ec 08             	sub    $0x8,%esp
  800115:	56                   	push   %esi
  800116:	53                   	push   %ebx
  800117:	e8 17 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011c:	e8 0a 00 00 00       	call   80012b <exit>
}
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800131:	6a 00                	push   $0x0
  800133:	e8 e9 0b 00 00       	call   800d21 <sys_env_destroy>
}
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	c9                   	leave  
  80013c:	c3                   	ret    

0080013d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800142:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800145:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014b:	e8 12 0c 00 00       	call   800d62 <sys_getenvid>
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	ff 75 0c             	pushl  0xc(%ebp)
  800156:	ff 75 08             	pushl  0x8(%ebp)
  800159:	56                   	push   %esi
  80015a:	50                   	push   %eax
  80015b:	68 84 12 80 00       	push   $0x801284
  800160:	e8 b3 00 00 00       	call   800218 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800165:	83 c4 18             	add    $0x18,%esp
  800168:	53                   	push   %ebx
  800169:	ff 75 10             	pushl  0x10(%ebp)
  80016c:	e8 56 00 00 00       	call   8001c7 <vcprintf>
	cprintf("\n");
  800171:	c7 04 24 77 12 80 00 	movl   $0x801277,(%esp)
  800178:	e8 9b 00 00 00       	call   800218 <cprintf>
  80017d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800180:	cc                   	int3   
  800181:	eb fd                	jmp    800180 <_panic+0x43>

00800183 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	53                   	push   %ebx
  800187:	83 ec 04             	sub    $0x4,%esp
  80018a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80018d:	8b 13                	mov    (%ebx),%edx
  80018f:	8d 42 01             	lea    0x1(%edx),%eax
  800192:	89 03                	mov    %eax,(%ebx)
  800194:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800197:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a0:	74 09                	je     8001ab <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a9:	c9                   	leave  
  8001aa:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	68 ff 00 00 00       	push   $0xff
  8001b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b6:	50                   	push   %eax
  8001b7:	e8 28 0b 00 00       	call   800ce4 <sys_cputs>
		b->idx = 0;
  8001bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c2:	83 c4 10             	add    $0x10,%esp
  8001c5:	eb db                	jmp    8001a2 <putch+0x1f>

008001c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001d7:	00 00 00 
	b.cnt = 0;
  8001da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e4:	ff 75 0c             	pushl  0xc(%ebp)
  8001e7:	ff 75 08             	pushl  0x8(%ebp)
  8001ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f0:	50                   	push   %eax
  8001f1:	68 83 01 80 00       	push   $0x800183
  8001f6:	e8 fb 00 00 00       	call   8002f6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fb:	83 c4 08             	add    $0x8,%esp
  8001fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800204:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020a:	50                   	push   %eax
  80020b:	e8 d4 0a 00 00       	call   800ce4 <sys_cputs>

	return b.cnt;
}
  800210:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800221:	50                   	push   %eax
  800222:	ff 75 08             	pushl  0x8(%ebp)
  800225:	e8 9d ff ff ff       	call   8001c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80022a:	c9                   	leave  
  80022b:	c3                   	ret    

0080022c <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	57                   	push   %edi
  800230:	56                   	push   %esi
  800231:	53                   	push   %ebx
  800232:	83 ec 1c             	sub    $0x1c,%esp
  800235:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800238:	89 d3                	mov    %edx,%ebx
  80023a:	8b 75 08             	mov    0x8(%ebp),%esi
  80023d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800240:	8b 45 10             	mov    0x10(%ebp),%eax
  800243:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800246:	89 c2                	mov    %eax,%edx
  800248:	b9 00 00 00 00       	mov    $0x0,%ecx
  80024d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800250:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800253:	39 c6                	cmp    %eax,%esi
  800255:	89 f8                	mov    %edi,%eax
  800257:	19 c8                	sbb    %ecx,%eax
  800259:	73 32                	jae    80028d <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  80025b:	83 ec 08             	sub    $0x8,%esp
  80025e:	53                   	push   %ebx
  80025f:	83 ec 04             	sub    $0x4,%esp
  800262:	ff 75 e4             	pushl  -0x1c(%ebp)
  800265:	ff 75 e0             	pushl  -0x20(%ebp)
  800268:	57                   	push   %edi
  800269:	56                   	push   %esi
  80026a:	e8 61 0e 00 00       	call   8010d0 <__umoddi3>
  80026f:	83 c4 14             	add    $0x14,%esp
  800272:	0f be 80 a7 12 80 00 	movsbl 0x8012a7(%eax),%eax
  800279:	50                   	push   %eax
  80027a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027d:	ff d0                	call   *%eax
	return remain - 1;
  80027f:	8b 45 14             	mov    0x14(%ebp),%eax
  800282:	83 e8 01             	sub    $0x1,%eax
}
  800285:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800288:	5b                   	pop    %ebx
  800289:	5e                   	pop    %esi
  80028a:	5f                   	pop    %edi
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  80028d:	83 ec 0c             	sub    $0xc,%esp
  800290:	ff 75 18             	pushl  0x18(%ebp)
  800293:	ff 75 14             	pushl  0x14(%ebp)
  800296:	ff 75 d8             	pushl  -0x28(%ebp)
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	51                   	push   %ecx
  80029d:	52                   	push   %edx
  80029e:	57                   	push   %edi
  80029f:	56                   	push   %esi
  8002a0:	e8 1b 0d 00 00       	call   800fc0 <__udivdi3>
  8002a5:	83 c4 18             	add    $0x18,%esp
  8002a8:	52                   	push   %edx
  8002a9:	50                   	push   %eax
  8002aa:	89 da                	mov    %ebx,%edx
  8002ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002af:	e8 78 ff ff ff       	call   80022c <printnum_helper>
  8002b4:	89 45 14             	mov    %eax,0x14(%ebp)
  8002b7:	83 c4 20             	add    $0x20,%esp
  8002ba:	eb 9f                	jmp    80025b <printnum_helper+0x2f>

008002bc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c6:	8b 10                	mov    (%eax),%edx
  8002c8:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cb:	73 0a                	jae    8002d7 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002cd:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	88 02                	mov    %al,(%edx)
}
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    

008002d9 <printfmt>:
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002df:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e2:	50                   	push   %eax
  8002e3:	ff 75 10             	pushl  0x10(%ebp)
  8002e6:	ff 75 0c             	pushl  0xc(%ebp)
  8002e9:	ff 75 08             	pushl  0x8(%ebp)
  8002ec:	e8 05 00 00 00       	call   8002f6 <vprintfmt>
}
  8002f1:	83 c4 10             	add    $0x10,%esp
  8002f4:	c9                   	leave  
  8002f5:	c3                   	ret    

008002f6 <vprintfmt>:
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
  8002f9:	57                   	push   %edi
  8002fa:	56                   	push   %esi
  8002fb:	53                   	push   %ebx
  8002fc:	83 ec 3c             	sub    $0x3c,%esp
  8002ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800302:	8b 75 0c             	mov    0xc(%ebp),%esi
  800305:	8b 7d 10             	mov    0x10(%ebp),%edi
  800308:	e9 3f 05 00 00       	jmp    80084c <vprintfmt+0x556>
		padc = ' ';
  80030d:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800311:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800318:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  80031f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800326:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  80032d:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800334:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800339:	8d 47 01             	lea    0x1(%edi),%eax
  80033c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80033f:	0f b6 17             	movzbl (%edi),%edx
  800342:	8d 42 dd             	lea    -0x23(%edx),%eax
  800345:	3c 55                	cmp    $0x55,%al
  800347:	0f 87 98 05 00 00    	ja     8008e5 <vprintfmt+0x5ef>
  80034d:	0f b6 c0             	movzbl %al,%eax
  800350:	ff 24 85 e0 13 80 00 	jmp    *0x8013e0(,%eax,4)
  800357:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  80035a:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80035e:	eb d9                	jmp    800339 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800360:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800363:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  80036a:	eb cd                	jmp    800339 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	0f b6 d2             	movzbl %dl,%edx
  80036f:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800372:	b8 00 00 00 00       	mov    $0x0,%eax
  800377:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  80037a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800381:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800384:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800387:	83 fb 09             	cmp    $0x9,%ebx
  80038a:	77 5c                	ja     8003e8 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  80038c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80038f:	eb e9                	jmp    80037a <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  800394:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  800398:	eb 9f                	jmp    800339 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  80039a:	8b 45 14             	mov    0x14(%ebp),%eax
  80039d:	8b 00                	mov    (%eax),%eax
  80039f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8d 40 04             	lea    0x4(%eax),%eax
  8003a8:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8003ae:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003b2:	79 85                	jns    800339 <vprintfmt+0x43>
				width = precision, precision = -1;
  8003b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ba:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003c1:	e9 73 ff ff ff       	jmp    800339 <vprintfmt+0x43>
  8003c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c9:	85 c0                	test   %eax,%eax
  8003cb:	0f 48 c1             	cmovs  %ecx,%eax
  8003ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8003d4:	e9 60 ff ff ff       	jmp    800339 <vprintfmt+0x43>
  8003d9:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8003dc:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8003e3:	e9 51 ff ff ff       	jmp    800339 <vprintfmt+0x43>
  8003e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003ee:	eb be                	jmp    8003ae <vprintfmt+0xb8>
			lflag++;
  8003f0:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  8003f7:	e9 3d ff ff ff       	jmp    800339 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  8003fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ff:	8d 78 04             	lea    0x4(%eax),%edi
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	56                   	push   %esi
  800406:	ff 30                	pushl  (%eax)
  800408:	ff d3                	call   *%ebx
			break;
  80040a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80040d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800410:	e9 34 04 00 00       	jmp    800849 <vprintfmt+0x553>
			err = va_arg(ap, int);
  800415:	8b 45 14             	mov    0x14(%ebp),%eax
  800418:	8d 78 04             	lea    0x4(%eax),%edi
  80041b:	8b 00                	mov    (%eax),%eax
  80041d:	99                   	cltd   
  80041e:	31 d0                	xor    %edx,%eax
  800420:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800422:	83 f8 08             	cmp    $0x8,%eax
  800425:	7f 23                	jg     80044a <vprintfmt+0x154>
  800427:	8b 14 85 40 15 80 00 	mov    0x801540(,%eax,4),%edx
  80042e:	85 d2                	test   %edx,%edx
  800430:	74 18                	je     80044a <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800432:	52                   	push   %edx
  800433:	68 c8 12 80 00       	push   $0x8012c8
  800438:	56                   	push   %esi
  800439:	53                   	push   %ebx
  80043a:	e8 9a fe ff ff       	call   8002d9 <printfmt>
  80043f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800442:	89 7d 14             	mov    %edi,0x14(%ebp)
  800445:	e9 ff 03 00 00       	jmp    800849 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  80044a:	50                   	push   %eax
  80044b:	68 bf 12 80 00       	push   $0x8012bf
  800450:	56                   	push   %esi
  800451:	53                   	push   %ebx
  800452:	e8 82 fe ff ff       	call   8002d9 <printfmt>
  800457:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80045d:	e9 e7 03 00 00       	jmp    800849 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	83 c0 04             	add    $0x4,%eax
  800468:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800470:	85 c9                	test   %ecx,%ecx
  800472:	b8 b8 12 80 00       	mov    $0x8012b8,%eax
  800477:	0f 45 c1             	cmovne %ecx,%eax
  80047a:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80047d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800481:	7e 06                	jle    800489 <vprintfmt+0x193>
  800483:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800487:	75 0d                	jne    800496 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800489:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80048c:	89 c7                	mov    %eax,%edi
  80048e:	03 45 d8             	add    -0x28(%ebp),%eax
  800491:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800494:	eb 53                	jmp    8004e9 <vprintfmt+0x1f3>
  800496:	83 ec 08             	sub    $0x8,%esp
  800499:	ff 75 e0             	pushl  -0x20(%ebp)
  80049c:	50                   	push   %eax
  80049d:	e8 eb 04 00 00       	call   80098d <strnlen>
  8004a2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8004a5:	29 c1                	sub    %eax,%ecx
  8004a7:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004af:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8004b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b6:	eb 0f                	jmp    8004c7 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004b8:	83 ec 08             	sub    $0x8,%esp
  8004bb:	56                   	push   %esi
  8004bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8004bf:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c1:	83 ef 01             	sub    $0x1,%edi
  8004c4:	83 c4 10             	add    $0x10,%esp
  8004c7:	85 ff                	test   %edi,%edi
  8004c9:	7f ed                	jg     8004b8 <vprintfmt+0x1c2>
  8004cb:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8004ce:	85 c9                	test   %ecx,%ecx
  8004d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d5:	0f 49 c1             	cmovns %ecx,%eax
  8004d8:	29 c1                	sub    %eax,%ecx
  8004da:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8004dd:	eb aa                	jmp    800489 <vprintfmt+0x193>
					putch(ch, putdat);
  8004df:	83 ec 08             	sub    $0x8,%esp
  8004e2:	56                   	push   %esi
  8004e3:	52                   	push   %edx
  8004e4:	ff d3                	call   *%ebx
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8004ec:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ee:	83 c7 01             	add    $0x1,%edi
  8004f1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f5:	0f be d0             	movsbl %al,%edx
  8004f8:	85 d2                	test   %edx,%edx
  8004fa:	74 2e                	je     80052a <vprintfmt+0x234>
  8004fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800500:	78 06                	js     800508 <vprintfmt+0x212>
  800502:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800506:	78 1e                	js     800526 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800508:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80050c:	74 d1                	je     8004df <vprintfmt+0x1e9>
  80050e:	0f be c0             	movsbl %al,%eax
  800511:	83 e8 20             	sub    $0x20,%eax
  800514:	83 f8 5e             	cmp    $0x5e,%eax
  800517:	76 c6                	jbe    8004df <vprintfmt+0x1e9>
					putch('?', putdat);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	56                   	push   %esi
  80051d:	6a 3f                	push   $0x3f
  80051f:	ff d3                	call   *%ebx
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	eb c3                	jmp    8004e9 <vprintfmt+0x1f3>
  800526:	89 cf                	mov    %ecx,%edi
  800528:	eb 02                	jmp    80052c <vprintfmt+0x236>
  80052a:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  80052c:	85 ff                	test   %edi,%edi
  80052e:	7e 10                	jle    800540 <vprintfmt+0x24a>
				putch(' ', putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	56                   	push   %esi
  800534:	6a 20                	push   $0x20
  800536:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800538:	83 ef 01             	sub    $0x1,%edi
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	eb ec                	jmp    80052c <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800540:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800543:	89 45 14             	mov    %eax,0x14(%ebp)
  800546:	e9 fe 02 00 00       	jmp    800849 <vprintfmt+0x553>
	if (lflag >= 2)
  80054b:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80054f:	7f 21                	jg     800572 <vprintfmt+0x27c>
	else if (lflag)
  800551:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800555:	74 79                	je     8005d0 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8b 00                	mov    (%eax),%eax
  80055c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80055f:	89 c1                	mov    %eax,%ecx
  800561:	c1 f9 1f             	sar    $0x1f,%ecx
  800564:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 40 04             	lea    0x4(%eax),%eax
  80056d:	89 45 14             	mov    %eax,0x14(%ebp)
  800570:	eb 17                	jmp    800589 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8b 50 04             	mov    0x4(%eax),%edx
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 40 08             	lea    0x8(%eax),%eax
  800586:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  800589:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800592:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  800595:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800599:	78 50                	js     8005eb <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  80059b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80059e:	c1 fa 1f             	sar    $0x1f,%edx
  8005a1:	89 d0                	mov    %edx,%eax
  8005a3:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8005a6:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	0f 89 14 02 00 00    	jns    8007c5 <vprintfmt+0x4cf>
  8005b1:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005b5:	0f 84 0a 02 00 00    	je     8007c5 <vprintfmt+0x4cf>
				putch('+', putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	56                   	push   %esi
  8005bf:	6a 2b                	push   $0x2b
  8005c1:	ff d3                	call   *%ebx
  8005c3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cb:	e9 5c 01 00 00       	jmp    80072c <vprintfmt+0x436>
		return va_arg(*ap, int);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d8:	89 c1                	mov    %eax,%ecx
  8005da:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 40 04             	lea    0x4(%eax),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e9:	eb 9e                	jmp    800589 <vprintfmt+0x293>
				putch('-', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	56                   	push   %esi
  8005ef:	6a 2d                	push   $0x2d
  8005f1:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f9:	f7 d8                	neg    %eax
  8005fb:	83 d2 00             	adc    $0x0,%edx
  8005fe:	f7 da                	neg    %edx
  800600:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800603:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800606:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800609:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060e:	e9 19 01 00 00       	jmp    80072c <vprintfmt+0x436>
	if (lflag >= 2)
  800613:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800617:	7f 29                	jg     800642 <vprintfmt+0x34c>
	else if (lflag)
  800619:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80061d:	74 44                	je     800663 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8b 00                	mov    (%eax),%eax
  800624:	ba 00 00 00 00       	mov    $0x0,%edx
  800629:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80062c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8d 40 04             	lea    0x4(%eax),%eax
  800635:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800638:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063d:	e9 ea 00 00 00       	jmp    80072c <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 50 04             	mov    0x4(%eax),%edx
  800648:	8b 00                	mov    (%eax),%eax
  80064a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80064d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 40 08             	lea    0x8(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	e9 c9 00 00 00       	jmp    80072c <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	8b 00                	mov    (%eax),%eax
  800668:	ba 00 00 00 00       	mov    $0x0,%edx
  80066d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800670:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8d 40 04             	lea    0x4(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80067c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800681:	e9 a6 00 00 00       	jmp    80072c <vprintfmt+0x436>
			putch('0', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	56                   	push   %esi
  80068a:	6a 30                	push   $0x30
  80068c:	ff d3                	call   *%ebx
	if (lflag >= 2)
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800695:	7f 26                	jg     8006bd <vprintfmt+0x3c7>
	else if (lflag)
  800697:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80069b:	74 3e                	je     8006db <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8b 00                	mov    (%eax),%eax
  8006a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006aa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b0:	8d 40 04             	lea    0x4(%eax),%eax
  8006b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006b6:	b8 08 00 00 00       	mov    $0x8,%eax
  8006bb:	eb 6f                	jmp    80072c <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 50 04             	mov    0x4(%eax),%edx
  8006c3:	8b 00                	mov    (%eax),%eax
  8006c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006c8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 40 08             	lea    0x8(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006d4:	b8 08 00 00 00       	mov    $0x8,%eax
  8006d9:	eb 51                	jmp    80072c <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8b 00                	mov    (%eax),%eax
  8006e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8d 40 04             	lea    0x4(%eax),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006f4:	b8 08 00 00 00       	mov    $0x8,%eax
  8006f9:	eb 31                	jmp    80072c <vprintfmt+0x436>
			putch('0', putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	56                   	push   %esi
  8006ff:	6a 30                	push   $0x30
  800701:	ff d3                	call   *%ebx
			putch('x', putdat);
  800703:	83 c4 08             	add    $0x8,%esp
  800706:	56                   	push   %esi
  800707:	6a 78                	push   $0x78
  800709:	ff d3                	call   *%ebx
			num = (unsigned long long)
  80070b:	8b 45 14             	mov    0x14(%ebp),%eax
  80070e:	8b 00                	mov    (%eax),%eax
  800710:	ba 00 00 00 00       	mov    $0x0,%edx
  800715:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800718:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  80071b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80071e:	8b 45 14             	mov    0x14(%ebp),%eax
  800721:	8d 40 04             	lea    0x4(%eax),%eax
  800724:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800727:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80072c:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800730:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800733:	89 c1                	mov    %eax,%ecx
  800735:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800738:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80073b:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800740:	89 c2                	mov    %eax,%edx
  800742:	39 c1                	cmp    %eax,%ecx
  800744:	0f 87 85 00 00 00    	ja     8007cf <vprintfmt+0x4d9>
		tmp /= base;
  80074a:	89 d0                	mov    %edx,%eax
  80074c:	ba 00 00 00 00       	mov    $0x0,%edx
  800751:	f7 f1                	div    %ecx
		len++;
  800753:	83 c7 01             	add    $0x1,%edi
  800756:	eb e8                	jmp    800740 <vprintfmt+0x44a>
	if (lflag >= 2)
  800758:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80075c:	7f 26                	jg     800784 <vprintfmt+0x48e>
	else if (lflag)
  80075e:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800762:	74 3e                	je     8007a2 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8b 00                	mov    (%eax),%eax
  800769:	ba 00 00 00 00       	mov    $0x0,%edx
  80076e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800771:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800774:	8b 45 14             	mov    0x14(%ebp),%eax
  800777:	8d 40 04             	lea    0x4(%eax),%eax
  80077a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80077d:	b8 10 00 00 00       	mov    $0x10,%eax
  800782:	eb a8                	jmp    80072c <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8b 50 04             	mov    0x4(%eax),%edx
  80078a:	8b 00                	mov    (%eax),%eax
  80078c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80078f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8d 40 08             	lea    0x8(%eax),%eax
  800798:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80079b:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a0:	eb 8a                	jmp    80072c <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8007a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a5:	8b 00                	mov    (%eax),%eax
  8007a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007af:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8d 40 04             	lea    0x4(%eax),%eax
  8007b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007bb:	b8 10 00 00 00       	mov    $0x10,%eax
  8007c0:	e9 67 ff ff ff       	jmp    80072c <vprintfmt+0x436>
			base = 10;
  8007c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ca:	e9 5d ff ff ff       	jmp    80072c <vprintfmt+0x436>
  8007cf:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8007d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007d5:	29 f8                	sub    %edi,%eax
  8007d7:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8007d9:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8007dd:	74 15                	je     8007f4 <vprintfmt+0x4fe>
		while (width > 0) {
  8007df:	85 ff                	test   %edi,%edi
  8007e1:	7e 48                	jle    80082b <vprintfmt+0x535>
			putch(padc, putdat);
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	56                   	push   %esi
  8007e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ea:	ff d3                	call   *%ebx
			width--;
  8007ec:	83 ef 01             	sub    $0x1,%edi
  8007ef:	83 c4 10             	add    $0x10,%esp
  8007f2:	eb eb                	jmp    8007df <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  8007f4:	83 ec 0c             	sub    $0xc,%esp
  8007f7:	6a 2d                	push   $0x2d
  8007f9:	ff 75 cc             	pushl  -0x34(%ebp)
  8007fc:	ff 75 c8             	pushl  -0x38(%ebp)
  8007ff:	ff 75 d4             	pushl  -0x2c(%ebp)
  800802:	ff 75 d0             	pushl  -0x30(%ebp)
  800805:	89 f2                	mov    %esi,%edx
  800807:	89 d8                	mov    %ebx,%eax
  800809:	e8 1e fa ff ff       	call   80022c <printnum_helper>
		width -= len;
  80080e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800811:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800814:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800817:	85 ff                	test   %edi,%edi
  800819:	7e 2e                	jle    800849 <vprintfmt+0x553>
			putch(padc, putdat);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	56                   	push   %esi
  80081f:	6a 20                	push   $0x20
  800821:	ff d3                	call   *%ebx
			width--;
  800823:	83 ef 01             	sub    $0x1,%edi
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	eb ec                	jmp    800817 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  80082b:	83 ec 0c             	sub    $0xc,%esp
  80082e:	ff 75 e0             	pushl  -0x20(%ebp)
  800831:	ff 75 cc             	pushl  -0x34(%ebp)
  800834:	ff 75 c8             	pushl  -0x38(%ebp)
  800837:	ff 75 d4             	pushl  -0x2c(%ebp)
  80083a:	ff 75 d0             	pushl  -0x30(%ebp)
  80083d:	89 f2                	mov    %esi,%edx
  80083f:	89 d8                	mov    %ebx,%eax
  800841:	e8 e6 f9 ff ff       	call   80022c <printnum_helper>
  800846:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800849:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80084c:	83 c7 01             	add    $0x1,%edi
  80084f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800853:	83 f8 25             	cmp    $0x25,%eax
  800856:	0f 84 b1 fa ff ff    	je     80030d <vprintfmt+0x17>
			if (ch == '\0')
  80085c:	85 c0                	test   %eax,%eax
  80085e:	0f 84 a1 00 00 00    	je     800905 <vprintfmt+0x60f>
			putch(ch, putdat);
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	56                   	push   %esi
  800868:	50                   	push   %eax
  800869:	ff d3                	call   *%ebx
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	eb dc                	jmp    80084c <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	83 c0 04             	add    $0x4,%eax
  800876:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800879:	8b 45 14             	mov    0x14(%ebp),%eax
  80087c:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  80087e:	85 ff                	test   %edi,%edi
  800880:	74 15                	je     800897 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800882:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800888:	7f 29                	jg     8008b3 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  80088a:	0f b6 06             	movzbl (%esi),%eax
  80088d:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  80088f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800892:	89 45 14             	mov    %eax,0x14(%ebp)
  800895:	eb b2                	jmp    800849 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800897:	68 60 13 80 00       	push   $0x801360
  80089c:	68 c8 12 80 00       	push   $0x8012c8
  8008a1:	56                   	push   %esi
  8008a2:	53                   	push   %ebx
  8008a3:	e8 31 fa ff ff       	call   8002d9 <printfmt>
  8008a8:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8008ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008ae:	89 45 14             	mov    %eax,0x14(%ebp)
  8008b1:	eb 96                	jmp    800849 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  8008b3:	68 98 13 80 00       	push   $0x801398
  8008b8:	68 c8 12 80 00       	push   $0x8012c8
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
  8008bf:	e8 15 fa ff ff       	call   8002d9 <printfmt>
				*res = -1;
  8008c4:	c6 07 ff             	movb   $0xff,(%edi)
  8008c7:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8008ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008cd:	89 45 14             	mov    %eax,0x14(%ebp)
  8008d0:	e9 74 ff ff ff       	jmp    800849 <vprintfmt+0x553>
			putch(ch, putdat);
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	56                   	push   %esi
  8008d9:	6a 25                	push   $0x25
  8008db:	ff d3                	call   *%ebx
			break;
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	e9 64 ff ff ff       	jmp    800849 <vprintfmt+0x553>
			putch('%', putdat);
  8008e5:	83 ec 08             	sub    $0x8,%esp
  8008e8:	56                   	push   %esi
  8008e9:	6a 25                	push   $0x25
  8008eb:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ed:	83 c4 10             	add    $0x10,%esp
  8008f0:	89 f8                	mov    %edi,%eax
  8008f2:	eb 03                	jmp    8008f7 <vprintfmt+0x601>
  8008f4:	83 e8 01             	sub    $0x1,%eax
  8008f7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008fb:	75 f7                	jne    8008f4 <vprintfmt+0x5fe>
  8008fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800900:	e9 44 ff ff ff       	jmp    800849 <vprintfmt+0x553>
}
  800905:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800908:	5b                   	pop    %ebx
  800909:	5e                   	pop    %esi
  80090a:	5f                   	pop    %edi
  80090b:	5d                   	pop    %ebp
  80090c:	c3                   	ret    

0080090d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	83 ec 18             	sub    $0x18,%esp
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800919:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80091c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800920:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800923:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80092a:	85 c0                	test   %eax,%eax
  80092c:	74 26                	je     800954 <vsnprintf+0x47>
  80092e:	85 d2                	test   %edx,%edx
  800930:	7e 22                	jle    800954 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800932:	ff 75 14             	pushl  0x14(%ebp)
  800935:	ff 75 10             	pushl  0x10(%ebp)
  800938:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80093b:	50                   	push   %eax
  80093c:	68 bc 02 80 00       	push   $0x8002bc
  800941:	e8 b0 f9 ff ff       	call   8002f6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800946:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800949:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094f:	83 c4 10             	add    $0x10,%esp
}
  800952:	c9                   	leave  
  800953:	c3                   	ret    
		return -E_INVAL;
  800954:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800959:	eb f7                	jmp    800952 <vsnprintf+0x45>

0080095b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800961:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800964:	50                   	push   %eax
  800965:	ff 75 10             	pushl  0x10(%ebp)
  800968:	ff 75 0c             	pushl  0xc(%ebp)
  80096b:	ff 75 08             	pushl  0x8(%ebp)
  80096e:	e8 9a ff ff ff       	call   80090d <vsnprintf>
	va_end(ap);

	return rc;
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80097b:	b8 00 00 00 00       	mov    $0x0,%eax
  800980:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800984:	74 05                	je     80098b <strlen+0x16>
		n++;
  800986:	83 c0 01             	add    $0x1,%eax
  800989:	eb f5                	jmp    800980 <strlen+0xb>
	return n;
}
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800993:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800996:	ba 00 00 00 00       	mov    $0x0,%edx
  80099b:	39 c2                	cmp    %eax,%edx
  80099d:	74 0d                	je     8009ac <strnlen+0x1f>
  80099f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009a3:	74 05                	je     8009aa <strnlen+0x1d>
		n++;
  8009a5:	83 c2 01             	add    $0x1,%edx
  8009a8:	eb f1                	jmp    80099b <strnlen+0xe>
  8009aa:	89 d0                	mov    %edx,%eax
	return n;
}
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	53                   	push   %ebx
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bd:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009c1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009c4:	83 c2 01             	add    $0x1,%edx
  8009c7:	84 c9                	test   %cl,%cl
  8009c9:	75 f2                	jne    8009bd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009cb:	5b                   	pop    %ebx
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	53                   	push   %ebx
  8009d2:	83 ec 10             	sub    $0x10,%esp
  8009d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d8:	53                   	push   %ebx
  8009d9:	e8 97 ff ff ff       	call   800975 <strlen>
  8009de:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009e1:	ff 75 0c             	pushl  0xc(%ebp)
  8009e4:	01 d8                	add    %ebx,%eax
  8009e6:	50                   	push   %eax
  8009e7:	e8 c2 ff ff ff       	call   8009ae <strcpy>
	return dst;
}
  8009ec:	89 d8                	mov    %ebx,%eax
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	56                   	push   %esi
  8009f7:	53                   	push   %ebx
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fe:	89 c6                	mov    %eax,%esi
  800a00:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a03:	89 c2                	mov    %eax,%edx
  800a05:	39 f2                	cmp    %esi,%edx
  800a07:	74 11                	je     800a1a <strncpy+0x27>
		*dst++ = *src;
  800a09:	83 c2 01             	add    $0x1,%edx
  800a0c:	0f b6 19             	movzbl (%ecx),%ebx
  800a0f:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a12:	80 fb 01             	cmp    $0x1,%bl
  800a15:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800a18:	eb eb                	jmp    800a05 <strncpy+0x12>
	}
	return ret;
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 75 08             	mov    0x8(%ebp),%esi
  800a26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a29:	8b 55 10             	mov    0x10(%ebp),%edx
  800a2c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a2e:	85 d2                	test   %edx,%edx
  800a30:	74 21                	je     800a53 <strlcpy+0x35>
  800a32:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a36:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800a38:	39 c2                	cmp    %eax,%edx
  800a3a:	74 14                	je     800a50 <strlcpy+0x32>
  800a3c:	0f b6 19             	movzbl (%ecx),%ebx
  800a3f:	84 db                	test   %bl,%bl
  800a41:	74 0b                	je     800a4e <strlcpy+0x30>
			*dst++ = *src++;
  800a43:	83 c1 01             	add    $0x1,%ecx
  800a46:	83 c2 01             	add    $0x1,%edx
  800a49:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a4c:	eb ea                	jmp    800a38 <strlcpy+0x1a>
  800a4e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a50:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a53:	29 f0                	sub    %esi,%eax
}
  800a55:	5b                   	pop    %ebx
  800a56:	5e                   	pop    %esi
  800a57:	5d                   	pop    %ebp
  800a58:	c3                   	ret    

00800a59 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a62:	0f b6 01             	movzbl (%ecx),%eax
  800a65:	84 c0                	test   %al,%al
  800a67:	74 0c                	je     800a75 <strcmp+0x1c>
  800a69:	3a 02                	cmp    (%edx),%al
  800a6b:	75 08                	jne    800a75 <strcmp+0x1c>
		p++, q++;
  800a6d:	83 c1 01             	add    $0x1,%ecx
  800a70:	83 c2 01             	add    $0x1,%edx
  800a73:	eb ed                	jmp    800a62 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a75:	0f b6 c0             	movzbl %al,%eax
  800a78:	0f b6 12             	movzbl (%edx),%edx
  800a7b:	29 d0                	sub    %edx,%eax
}
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	53                   	push   %ebx
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a89:	89 c3                	mov    %eax,%ebx
  800a8b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a8e:	eb 06                	jmp    800a96 <strncmp+0x17>
		n--, p++, q++;
  800a90:	83 c0 01             	add    $0x1,%eax
  800a93:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a96:	39 d8                	cmp    %ebx,%eax
  800a98:	74 16                	je     800ab0 <strncmp+0x31>
  800a9a:	0f b6 08             	movzbl (%eax),%ecx
  800a9d:	84 c9                	test   %cl,%cl
  800a9f:	74 04                	je     800aa5 <strncmp+0x26>
  800aa1:	3a 0a                	cmp    (%edx),%cl
  800aa3:	74 eb                	je     800a90 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa5:	0f b6 00             	movzbl (%eax),%eax
  800aa8:	0f b6 12             	movzbl (%edx),%edx
  800aab:	29 d0                	sub    %edx,%eax
}
  800aad:	5b                   	pop    %ebx
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    
		return 0;
  800ab0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab5:	eb f6                	jmp    800aad <strncmp+0x2e>

00800ab7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	8b 45 08             	mov    0x8(%ebp),%eax
  800abd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac1:	0f b6 10             	movzbl (%eax),%edx
  800ac4:	84 d2                	test   %dl,%dl
  800ac6:	74 09                	je     800ad1 <strchr+0x1a>
		if (*s == c)
  800ac8:	38 ca                	cmp    %cl,%dl
  800aca:	74 0a                	je     800ad6 <strchr+0x1f>
	for (; *s; s++)
  800acc:	83 c0 01             	add    $0x1,%eax
  800acf:	eb f0                	jmp    800ac1 <strchr+0xa>
			return (char *) s;
	return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ae5:	38 ca                	cmp    %cl,%dl
  800ae7:	74 09                	je     800af2 <strfind+0x1a>
  800ae9:	84 d2                	test   %dl,%dl
  800aeb:	74 05                	je     800af2 <strfind+0x1a>
	for (; *s; s++)
  800aed:	83 c0 01             	add    $0x1,%eax
  800af0:	eb f0                	jmp    800ae2 <strfind+0xa>
			break;
	return (char *) s;
}
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
  800afa:	8b 7d 08             	mov    0x8(%ebp),%edi
  800afd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b00:	85 c9                	test   %ecx,%ecx
  800b02:	74 31                	je     800b35 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b04:	89 f8                	mov    %edi,%eax
  800b06:	09 c8                	or     %ecx,%eax
  800b08:	a8 03                	test   $0x3,%al
  800b0a:	75 23                	jne    800b2f <memset+0x3b>
		c &= 0xFF;
  800b0c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b10:	89 d3                	mov    %edx,%ebx
  800b12:	c1 e3 08             	shl    $0x8,%ebx
  800b15:	89 d0                	mov    %edx,%eax
  800b17:	c1 e0 18             	shl    $0x18,%eax
  800b1a:	89 d6                	mov    %edx,%esi
  800b1c:	c1 e6 10             	shl    $0x10,%esi
  800b1f:	09 f0                	or     %esi,%eax
  800b21:	09 c2                	or     %eax,%edx
  800b23:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b25:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b28:	89 d0                	mov    %edx,%eax
  800b2a:	fc                   	cld    
  800b2b:	f3 ab                	rep stos %eax,%es:(%edi)
  800b2d:	eb 06                	jmp    800b35 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b32:	fc                   	cld    
  800b33:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b35:	89 f8                	mov    %edi,%eax
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	8b 45 08             	mov    0x8(%ebp),%eax
  800b44:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b47:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b4a:	39 c6                	cmp    %eax,%esi
  800b4c:	73 32                	jae    800b80 <memmove+0x44>
  800b4e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b51:	39 c2                	cmp    %eax,%edx
  800b53:	76 2b                	jbe    800b80 <memmove+0x44>
		s += n;
		d += n;
  800b55:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b58:	89 fe                	mov    %edi,%esi
  800b5a:	09 ce                	or     %ecx,%esi
  800b5c:	09 d6                	or     %edx,%esi
  800b5e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b64:	75 0e                	jne    800b74 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b66:	83 ef 04             	sub    $0x4,%edi
  800b69:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b6c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b6f:	fd                   	std    
  800b70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b72:	eb 09                	jmp    800b7d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b74:	83 ef 01             	sub    $0x1,%edi
  800b77:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b7a:	fd                   	std    
  800b7b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b7d:	fc                   	cld    
  800b7e:	eb 1a                	jmp    800b9a <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b80:	89 c2                	mov    %eax,%edx
  800b82:	09 ca                	or     %ecx,%edx
  800b84:	09 f2                	or     %esi,%edx
  800b86:	f6 c2 03             	test   $0x3,%dl
  800b89:	75 0a                	jne    800b95 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b8b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b8e:	89 c7                	mov    %eax,%edi
  800b90:	fc                   	cld    
  800b91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b93:	eb 05                	jmp    800b9a <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b95:	89 c7                	mov    %eax,%edi
  800b97:	fc                   	cld    
  800b98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ba4:	ff 75 10             	pushl  0x10(%ebp)
  800ba7:	ff 75 0c             	pushl  0xc(%ebp)
  800baa:	ff 75 08             	pushl  0x8(%ebp)
  800bad:	e8 8a ff ff ff       	call   800b3c <memmove>
}
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    

00800bb4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	56                   	push   %esi
  800bb8:	53                   	push   %ebx
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bbf:	89 c6                	mov    %eax,%esi
  800bc1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc4:	39 f0                	cmp    %esi,%eax
  800bc6:	74 1c                	je     800be4 <memcmp+0x30>
		if (*s1 != *s2)
  800bc8:	0f b6 08             	movzbl (%eax),%ecx
  800bcb:	0f b6 1a             	movzbl (%edx),%ebx
  800bce:	38 d9                	cmp    %bl,%cl
  800bd0:	75 08                	jne    800bda <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bd2:	83 c0 01             	add    $0x1,%eax
  800bd5:	83 c2 01             	add    $0x1,%edx
  800bd8:	eb ea                	jmp    800bc4 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800bda:	0f b6 c1             	movzbl %cl,%eax
  800bdd:	0f b6 db             	movzbl %bl,%ebx
  800be0:	29 d8                	sub    %ebx,%eax
  800be2:	eb 05                	jmp    800be9 <memcmp+0x35>
	}

	return 0;
  800be4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be9:	5b                   	pop    %ebx
  800bea:	5e                   	pop    %esi
  800beb:	5d                   	pop    %ebp
  800bec:	c3                   	ret    

00800bed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bf6:	89 c2                	mov    %eax,%edx
  800bf8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bfb:	39 d0                	cmp    %edx,%eax
  800bfd:	73 09                	jae    800c08 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bff:	38 08                	cmp    %cl,(%eax)
  800c01:	74 05                	je     800c08 <memfind+0x1b>
	for (; s < ends; s++)
  800c03:	83 c0 01             	add    $0x1,%eax
  800c06:	eb f3                	jmp    800bfb <memfind+0xe>
			break;
	return (void *) s;
}
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c16:	eb 03                	jmp    800c1b <strtol+0x11>
		s++;
  800c18:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c1b:	0f b6 01             	movzbl (%ecx),%eax
  800c1e:	3c 20                	cmp    $0x20,%al
  800c20:	74 f6                	je     800c18 <strtol+0xe>
  800c22:	3c 09                	cmp    $0x9,%al
  800c24:	74 f2                	je     800c18 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c26:	3c 2b                	cmp    $0x2b,%al
  800c28:	74 2a                	je     800c54 <strtol+0x4a>
	int neg = 0;
  800c2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c2f:	3c 2d                	cmp    $0x2d,%al
  800c31:	74 2b                	je     800c5e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c33:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c39:	75 0f                	jne    800c4a <strtol+0x40>
  800c3b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c3e:	74 28                	je     800c68 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c40:	85 db                	test   %ebx,%ebx
  800c42:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c47:	0f 44 d8             	cmove  %eax,%ebx
  800c4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c4f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c52:	eb 50                	jmp    800ca4 <strtol+0x9a>
		s++;
  800c54:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c57:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5c:	eb d5                	jmp    800c33 <strtol+0x29>
		s++, neg = 1;
  800c5e:	83 c1 01             	add    $0x1,%ecx
  800c61:	bf 01 00 00 00       	mov    $0x1,%edi
  800c66:	eb cb                	jmp    800c33 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c68:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c6c:	74 0e                	je     800c7c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c6e:	85 db                	test   %ebx,%ebx
  800c70:	75 d8                	jne    800c4a <strtol+0x40>
		s++, base = 8;
  800c72:	83 c1 01             	add    $0x1,%ecx
  800c75:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c7a:	eb ce                	jmp    800c4a <strtol+0x40>
		s += 2, base = 16;
  800c7c:	83 c1 02             	add    $0x2,%ecx
  800c7f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c84:	eb c4                	jmp    800c4a <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c86:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c89:	89 f3                	mov    %esi,%ebx
  800c8b:	80 fb 19             	cmp    $0x19,%bl
  800c8e:	77 29                	ja     800cb9 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c90:	0f be d2             	movsbl %dl,%edx
  800c93:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c99:	7d 30                	jge    800ccb <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c9b:	83 c1 01             	add    $0x1,%ecx
  800c9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ca2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ca4:	0f b6 11             	movzbl (%ecx),%edx
  800ca7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800caa:	89 f3                	mov    %esi,%ebx
  800cac:	80 fb 09             	cmp    $0x9,%bl
  800caf:	77 d5                	ja     800c86 <strtol+0x7c>
			dig = *s - '0';
  800cb1:	0f be d2             	movsbl %dl,%edx
  800cb4:	83 ea 30             	sub    $0x30,%edx
  800cb7:	eb dd                	jmp    800c96 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800cb9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cbc:	89 f3                	mov    %esi,%ebx
  800cbe:	80 fb 19             	cmp    $0x19,%bl
  800cc1:	77 08                	ja     800ccb <strtol+0xc1>
			dig = *s - 'A' + 10;
  800cc3:	0f be d2             	movsbl %dl,%edx
  800cc6:	83 ea 37             	sub    $0x37,%edx
  800cc9:	eb cb                	jmp    800c96 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ccb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ccf:	74 05                	je     800cd6 <strtol+0xcc>
		*endptr = (char *) s;
  800cd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd4:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cd6:	89 c2                	mov    %eax,%edx
  800cd8:	f7 da                	neg    %edx
  800cda:	85 ff                	test   %edi,%edi
  800cdc:	0f 45 c2             	cmovne %edx,%eax
}
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cea:	b8 00 00 00 00       	mov    $0x0,%eax
  800cef:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf5:	89 c3                	mov    %eax,%ebx
  800cf7:	89 c7                	mov    %eax,%edi
  800cf9:	89 c6                	mov    %eax,%esi
  800cfb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d08:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0d:	b8 01 00 00 00       	mov    $0x1,%eax
  800d12:	89 d1                	mov    %edx,%ecx
  800d14:	89 d3                	mov    %edx,%ebx
  800d16:	89 d7                	mov    %edx,%edi
  800d18:	89 d6                	mov    %edx,%esi
  800d1a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	57                   	push   %edi
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d32:	b8 03 00 00 00       	mov    $0x3,%eax
  800d37:	89 cb                	mov    %ecx,%ebx
  800d39:	89 cf                	mov    %ecx,%edi
  800d3b:	89 ce                	mov    %ecx,%esi
  800d3d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	7f 08                	jg     800d4b <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4b:	83 ec 0c             	sub    $0xc,%esp
  800d4e:	50                   	push   %eax
  800d4f:	6a 03                	push   $0x3
  800d51:	68 64 15 80 00       	push   $0x801564
  800d56:	6a 23                	push   $0x23
  800d58:	68 81 15 80 00       	push   $0x801581
  800d5d:	e8 db f3 ff ff       	call   80013d <_panic>

00800d62 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d68:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6d:	b8 02 00 00 00       	mov    $0x2,%eax
  800d72:	89 d1                	mov    %edx,%ecx
  800d74:	89 d3                	mov    %edx,%ebx
  800d76:	89 d7                	mov    %edx,%edi
  800d78:	89 d6                	mov    %edx,%esi
  800d7a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_yield>:

void
sys_yield(void)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d87:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d91:	89 d1                	mov    %edx,%ecx
  800d93:	89 d3                	mov    %edx,%ebx
  800d95:	89 d7                	mov    %edx,%edi
  800d97:	89 d6                	mov    %edx,%esi
  800d99:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da9:	be 00 00 00 00       	mov    $0x0,%esi
  800dae:	8b 55 08             	mov    0x8(%ebp),%edx
  800db1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db4:	b8 04 00 00 00       	mov    $0x4,%eax
  800db9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbc:	89 f7                	mov    %esi,%edi
  800dbe:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	7f 08                	jg     800dcc <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	50                   	push   %eax
  800dd0:	6a 04                	push   $0x4
  800dd2:	68 64 15 80 00       	push   $0x801564
  800dd7:	6a 23                	push   $0x23
  800dd9:	68 81 15 80 00       	push   $0x801581
  800dde:	e8 5a f3 ff ff       	call   80013d <_panic>

00800de3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
  800de9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dec:	8b 55 08             	mov    0x8(%ebp),%edx
  800def:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df2:	b8 05 00 00 00       	mov    $0x5,%eax
  800df7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dfa:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfd:	8b 75 18             	mov    0x18(%ebp),%esi
  800e00:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e02:	85 c0                	test   %eax,%eax
  800e04:	7f 08                	jg     800e0e <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0e:	83 ec 0c             	sub    $0xc,%esp
  800e11:	50                   	push   %eax
  800e12:	6a 05                	push   $0x5
  800e14:	68 64 15 80 00       	push   $0x801564
  800e19:	6a 23                	push   $0x23
  800e1b:	68 81 15 80 00       	push   $0x801581
  800e20:	e8 18 f3 ff ff       	call   80013d <_panic>

00800e25 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e39:	b8 06 00 00 00       	mov    $0x6,%eax
  800e3e:	89 df                	mov    %ebx,%edi
  800e40:	89 de                	mov    %ebx,%esi
  800e42:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e44:	85 c0                	test   %eax,%eax
  800e46:	7f 08                	jg     800e50 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4b:	5b                   	pop    %ebx
  800e4c:	5e                   	pop    %esi
  800e4d:	5f                   	pop    %edi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e50:	83 ec 0c             	sub    $0xc,%esp
  800e53:	50                   	push   %eax
  800e54:	6a 06                	push   $0x6
  800e56:	68 64 15 80 00       	push   $0x801564
  800e5b:	6a 23                	push   $0x23
  800e5d:	68 81 15 80 00       	push   $0x801581
  800e62:	e8 d6 f2 ff ff       	call   80013d <_panic>

00800e67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e75:	8b 55 08             	mov    0x8(%ebp),%edx
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e80:	89 df                	mov    %ebx,%edi
  800e82:	89 de                	mov    %ebx,%esi
  800e84:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e86:	85 c0                	test   %eax,%eax
  800e88:	7f 08                	jg     800e92 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e92:	83 ec 0c             	sub    $0xc,%esp
  800e95:	50                   	push   %eax
  800e96:	6a 08                	push   $0x8
  800e98:	68 64 15 80 00       	push   $0x801564
  800e9d:	6a 23                	push   $0x23
  800e9f:	68 81 15 80 00       	push   $0x801581
  800ea4:	e8 94 f2 ff ff       	call   80013d <_panic>

00800ea9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eb2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800eba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebd:	b8 09 00 00 00       	mov    $0x9,%eax
  800ec2:	89 df                	mov    %ebx,%edi
  800ec4:	89 de                	mov    %ebx,%esi
  800ec6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	7f 08                	jg     800ed4 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ecc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed4:	83 ec 0c             	sub    $0xc,%esp
  800ed7:	50                   	push   %eax
  800ed8:	6a 09                	push   $0x9
  800eda:	68 64 15 80 00       	push   $0x801564
  800edf:	6a 23                	push   $0x23
  800ee1:	68 81 15 80 00       	push   $0x801581
  800ee6:	e8 52 f2 ff ff       	call   80013d <_panic>

00800eeb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ef1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800efc:	be 00 00 00 00       	mov    $0x0,%esi
  800f01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f04:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f07:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f09:	5b                   	pop    %ebx
  800f0a:	5e                   	pop    %esi
  800f0b:	5f                   	pop    %edi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f24:	89 cb                	mov    %ecx,%ebx
  800f26:	89 cf                	mov    %ecx,%edi
  800f28:	89 ce                	mov    %ecx,%esi
  800f2a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	7f 08                	jg     800f38 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f38:	83 ec 0c             	sub    $0xc,%esp
  800f3b:	50                   	push   %eax
  800f3c:	6a 0c                	push   $0xc
  800f3e:	68 64 15 80 00       	push   $0x801564
  800f43:	6a 23                	push   $0x23
  800f45:	68 81 15 80 00       	push   $0x801581
  800f4a:	e8 ee f1 ff ff       	call   80013d <_panic>

00800f4f <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f60:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f65:	89 df                	mov    %ebx,%edi
  800f67:	89 de                	mov    %ebx,%esi
  800f69:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f6b:	5b                   	pop    %ebx
  800f6c:	5e                   	pop    %esi
  800f6d:	5f                   	pop    %edi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	56                   	push   %esi
  800f75:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f83:	89 cb                	mov    %ecx,%ebx
  800f85:	89 cf                	mov    %ecx,%edi
  800f87:	89 ce                	mov    %ecx,%esi
  800f89:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f8b:	5b                   	pop    %ebx
  800f8c:	5e                   	pop    %esi
  800f8d:	5f                   	pop    %edi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f96:	68 9b 15 80 00       	push   $0x80159b
  800f9b:	6a 53                	push   $0x53
  800f9d:	68 8f 15 80 00       	push   $0x80158f
  800fa2:	e8 96 f1 ff ff       	call   80013d <_panic>

00800fa7 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fad:	68 9a 15 80 00       	push   $0x80159a
  800fb2:	6a 5a                	push   $0x5a
  800fb4:	68 8f 15 80 00       	push   $0x80158f
  800fb9:	e8 7f f1 ff ff       	call   80013d <_panic>
  800fbe:	66 90                	xchg   %ax,%ax

00800fc0 <__udivdi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 1c             	sub    $0x1c,%esp
  800fc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800fcb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800fcf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fd3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800fd7:	85 d2                	test   %edx,%edx
  800fd9:	75 4d                	jne    801028 <__udivdi3+0x68>
  800fdb:	39 f3                	cmp    %esi,%ebx
  800fdd:	76 19                	jbe    800ff8 <__udivdi3+0x38>
  800fdf:	31 ff                	xor    %edi,%edi
  800fe1:	89 e8                	mov    %ebp,%eax
  800fe3:	89 f2                	mov    %esi,%edx
  800fe5:	f7 f3                	div    %ebx
  800fe7:	89 fa                	mov    %edi,%edx
  800fe9:	83 c4 1c             	add    $0x1c,%esp
  800fec:	5b                   	pop    %ebx
  800fed:	5e                   	pop    %esi
  800fee:	5f                   	pop    %edi
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    
  800ff1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ff8:	89 d9                	mov    %ebx,%ecx
  800ffa:	85 db                	test   %ebx,%ebx
  800ffc:	75 0b                	jne    801009 <__udivdi3+0x49>
  800ffe:	b8 01 00 00 00       	mov    $0x1,%eax
  801003:	31 d2                	xor    %edx,%edx
  801005:	f7 f3                	div    %ebx
  801007:	89 c1                	mov    %eax,%ecx
  801009:	31 d2                	xor    %edx,%edx
  80100b:	89 f0                	mov    %esi,%eax
  80100d:	f7 f1                	div    %ecx
  80100f:	89 c6                	mov    %eax,%esi
  801011:	89 e8                	mov    %ebp,%eax
  801013:	89 f7                	mov    %esi,%edi
  801015:	f7 f1                	div    %ecx
  801017:	89 fa                	mov    %edi,%edx
  801019:	83 c4 1c             	add    $0x1c,%esp
  80101c:	5b                   	pop    %ebx
  80101d:	5e                   	pop    %esi
  80101e:	5f                   	pop    %edi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    
  801021:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801028:	39 f2                	cmp    %esi,%edx
  80102a:	77 1c                	ja     801048 <__udivdi3+0x88>
  80102c:	0f bd fa             	bsr    %edx,%edi
  80102f:	83 f7 1f             	xor    $0x1f,%edi
  801032:	75 2c                	jne    801060 <__udivdi3+0xa0>
  801034:	39 f2                	cmp    %esi,%edx
  801036:	72 06                	jb     80103e <__udivdi3+0x7e>
  801038:	31 c0                	xor    %eax,%eax
  80103a:	39 eb                	cmp    %ebp,%ebx
  80103c:	77 a9                	ja     800fe7 <__udivdi3+0x27>
  80103e:	b8 01 00 00 00       	mov    $0x1,%eax
  801043:	eb a2                	jmp    800fe7 <__udivdi3+0x27>
  801045:	8d 76 00             	lea    0x0(%esi),%esi
  801048:	31 ff                	xor    %edi,%edi
  80104a:	31 c0                	xor    %eax,%eax
  80104c:	89 fa                	mov    %edi,%edx
  80104e:	83 c4 1c             	add    $0x1c,%esp
  801051:	5b                   	pop    %ebx
  801052:	5e                   	pop    %esi
  801053:	5f                   	pop    %edi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    
  801056:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80105d:	8d 76 00             	lea    0x0(%esi),%esi
  801060:	89 f9                	mov    %edi,%ecx
  801062:	b8 20 00 00 00       	mov    $0x20,%eax
  801067:	29 f8                	sub    %edi,%eax
  801069:	d3 e2                	shl    %cl,%edx
  80106b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80106f:	89 c1                	mov    %eax,%ecx
  801071:	89 da                	mov    %ebx,%edx
  801073:	d3 ea                	shr    %cl,%edx
  801075:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801079:	09 d1                	or     %edx,%ecx
  80107b:	89 f2                	mov    %esi,%edx
  80107d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801081:	89 f9                	mov    %edi,%ecx
  801083:	d3 e3                	shl    %cl,%ebx
  801085:	89 c1                	mov    %eax,%ecx
  801087:	d3 ea                	shr    %cl,%edx
  801089:	89 f9                	mov    %edi,%ecx
  80108b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80108f:	89 eb                	mov    %ebp,%ebx
  801091:	d3 e6                	shl    %cl,%esi
  801093:	89 c1                	mov    %eax,%ecx
  801095:	d3 eb                	shr    %cl,%ebx
  801097:	09 de                	or     %ebx,%esi
  801099:	89 f0                	mov    %esi,%eax
  80109b:	f7 74 24 08          	divl   0x8(%esp)
  80109f:	89 d6                	mov    %edx,%esi
  8010a1:	89 c3                	mov    %eax,%ebx
  8010a3:	f7 64 24 0c          	mull   0xc(%esp)
  8010a7:	39 d6                	cmp    %edx,%esi
  8010a9:	72 15                	jb     8010c0 <__udivdi3+0x100>
  8010ab:	89 f9                	mov    %edi,%ecx
  8010ad:	d3 e5                	shl    %cl,%ebp
  8010af:	39 c5                	cmp    %eax,%ebp
  8010b1:	73 04                	jae    8010b7 <__udivdi3+0xf7>
  8010b3:	39 d6                	cmp    %edx,%esi
  8010b5:	74 09                	je     8010c0 <__udivdi3+0x100>
  8010b7:	89 d8                	mov    %ebx,%eax
  8010b9:	31 ff                	xor    %edi,%edi
  8010bb:	e9 27 ff ff ff       	jmp    800fe7 <__udivdi3+0x27>
  8010c0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8010c3:	31 ff                	xor    %edi,%edi
  8010c5:	e9 1d ff ff ff       	jmp    800fe7 <__udivdi3+0x27>
  8010ca:	66 90                	xchg   %ax,%ax
  8010cc:	66 90                	xchg   %ax,%ax
  8010ce:	66 90                	xchg   %ax,%ax

008010d0 <__umoddi3>:
  8010d0:	55                   	push   %ebp
  8010d1:	57                   	push   %edi
  8010d2:	56                   	push   %esi
  8010d3:	53                   	push   %ebx
  8010d4:	83 ec 1c             	sub    $0x1c,%esp
  8010d7:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8010db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8010df:	8b 74 24 30          	mov    0x30(%esp),%esi
  8010e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8010e7:	89 da                	mov    %ebx,%edx
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	75 43                	jne    801130 <__umoddi3+0x60>
  8010ed:	39 df                	cmp    %ebx,%edi
  8010ef:	76 17                	jbe    801108 <__umoddi3+0x38>
  8010f1:	89 f0                	mov    %esi,%eax
  8010f3:	f7 f7                	div    %edi
  8010f5:	89 d0                	mov    %edx,%eax
  8010f7:	31 d2                	xor    %edx,%edx
  8010f9:	83 c4 1c             	add    $0x1c,%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    
  801101:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801108:	89 fd                	mov    %edi,%ebp
  80110a:	85 ff                	test   %edi,%edi
  80110c:	75 0b                	jne    801119 <__umoddi3+0x49>
  80110e:	b8 01 00 00 00       	mov    $0x1,%eax
  801113:	31 d2                	xor    %edx,%edx
  801115:	f7 f7                	div    %edi
  801117:	89 c5                	mov    %eax,%ebp
  801119:	89 d8                	mov    %ebx,%eax
  80111b:	31 d2                	xor    %edx,%edx
  80111d:	f7 f5                	div    %ebp
  80111f:	89 f0                	mov    %esi,%eax
  801121:	f7 f5                	div    %ebp
  801123:	89 d0                	mov    %edx,%eax
  801125:	eb d0                	jmp    8010f7 <__umoddi3+0x27>
  801127:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80112e:	66 90                	xchg   %ax,%ax
  801130:	89 f1                	mov    %esi,%ecx
  801132:	39 d8                	cmp    %ebx,%eax
  801134:	76 0a                	jbe    801140 <__umoddi3+0x70>
  801136:	89 f0                	mov    %esi,%eax
  801138:	83 c4 1c             	add    $0x1c,%esp
  80113b:	5b                   	pop    %ebx
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    
  801140:	0f bd e8             	bsr    %eax,%ebp
  801143:	83 f5 1f             	xor    $0x1f,%ebp
  801146:	75 20                	jne    801168 <__umoddi3+0x98>
  801148:	39 d8                	cmp    %ebx,%eax
  80114a:	0f 82 b0 00 00 00    	jb     801200 <__umoddi3+0x130>
  801150:	39 f7                	cmp    %esi,%edi
  801152:	0f 86 a8 00 00 00    	jbe    801200 <__umoddi3+0x130>
  801158:	89 c8                	mov    %ecx,%eax
  80115a:	83 c4 1c             	add    $0x1c,%esp
  80115d:	5b                   	pop    %ebx
  80115e:	5e                   	pop    %esi
  80115f:	5f                   	pop    %edi
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    
  801162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801168:	89 e9                	mov    %ebp,%ecx
  80116a:	ba 20 00 00 00       	mov    $0x20,%edx
  80116f:	29 ea                	sub    %ebp,%edx
  801171:	d3 e0                	shl    %cl,%eax
  801173:	89 44 24 08          	mov    %eax,0x8(%esp)
  801177:	89 d1                	mov    %edx,%ecx
  801179:	89 f8                	mov    %edi,%eax
  80117b:	d3 e8                	shr    %cl,%eax
  80117d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801181:	89 54 24 04          	mov    %edx,0x4(%esp)
  801185:	8b 54 24 04          	mov    0x4(%esp),%edx
  801189:	09 c1                	or     %eax,%ecx
  80118b:	89 d8                	mov    %ebx,%eax
  80118d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801191:	89 e9                	mov    %ebp,%ecx
  801193:	d3 e7                	shl    %cl,%edi
  801195:	89 d1                	mov    %edx,%ecx
  801197:	d3 e8                	shr    %cl,%eax
  801199:	89 e9                	mov    %ebp,%ecx
  80119b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80119f:	d3 e3                	shl    %cl,%ebx
  8011a1:	89 c7                	mov    %eax,%edi
  8011a3:	89 d1                	mov    %edx,%ecx
  8011a5:	89 f0                	mov    %esi,%eax
  8011a7:	d3 e8                	shr    %cl,%eax
  8011a9:	89 e9                	mov    %ebp,%ecx
  8011ab:	89 fa                	mov    %edi,%edx
  8011ad:	d3 e6                	shl    %cl,%esi
  8011af:	09 d8                	or     %ebx,%eax
  8011b1:	f7 74 24 08          	divl   0x8(%esp)
  8011b5:	89 d1                	mov    %edx,%ecx
  8011b7:	89 f3                	mov    %esi,%ebx
  8011b9:	f7 64 24 0c          	mull   0xc(%esp)
  8011bd:	89 c6                	mov    %eax,%esi
  8011bf:	89 d7                	mov    %edx,%edi
  8011c1:	39 d1                	cmp    %edx,%ecx
  8011c3:	72 06                	jb     8011cb <__umoddi3+0xfb>
  8011c5:	75 10                	jne    8011d7 <__umoddi3+0x107>
  8011c7:	39 c3                	cmp    %eax,%ebx
  8011c9:	73 0c                	jae    8011d7 <__umoddi3+0x107>
  8011cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8011cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8011d3:	89 d7                	mov    %edx,%edi
  8011d5:	89 c6                	mov    %eax,%esi
  8011d7:	89 ca                	mov    %ecx,%edx
  8011d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011de:	29 f3                	sub    %esi,%ebx
  8011e0:	19 fa                	sbb    %edi,%edx
  8011e2:	89 d0                	mov    %edx,%eax
  8011e4:	d3 e0                	shl    %cl,%eax
  8011e6:	89 e9                	mov    %ebp,%ecx
  8011e8:	d3 eb                	shr    %cl,%ebx
  8011ea:	d3 ea                	shr    %cl,%edx
  8011ec:	09 d8                	or     %ebx,%eax
  8011ee:	83 c4 1c             	add    $0x1c,%esp
  8011f1:	5b                   	pop    %ebx
  8011f2:	5e                   	pop    %esi
  8011f3:	5f                   	pop    %edi
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    
  8011f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011fd:	8d 76 00             	lea    0x0(%esi),%esi
  801200:	89 da                	mov    %ebx,%edx
  801202:	29 fe                	sub    %edi,%esi
  801204:	19 c2                	sbb    %eax,%edx
  801206:	89 f1                	mov    %esi,%ecx
  801208:	89 c8                	mov    %ecx,%eax
  80120a:	e9 4b ff ff ff       	jmp    80115a <__umoddi3+0x8a>
