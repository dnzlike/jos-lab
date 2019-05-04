
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 e0 11 80 00       	push   $0x8011e0
  80003e:	e8 cc 01 00 00       	call   80020f <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	75 63                	jne    8000b8 <umain+0x85>
	for (i = 0; i < ARRAYSIZE; i++)
  800055:	83 c0 01             	add    $0x1,%eax
  800058:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80005d:	75 ec                	jne    80004b <umain+0x18>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80005f:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800064:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006b:	83 c0 01             	add    $0x1,%eax
  80006e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800073:	75 ef                	jne    800064 <umain+0x31>
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007a:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  800081:	75 47                	jne    8000ca <umain+0x97>
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 ed                	jne    80007a <umain+0x47>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	68 28 12 80 00       	push   $0x801228
  800095:	e8 75 01 00 00       	call   80020f <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009a:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000a1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	68 87 12 80 00       	push   $0x801287
  8000ac:	6a 1a                	push   $0x1a
  8000ae:	68 78 12 80 00       	push   $0x801278
  8000b3:	e8 7c 00 00 00       	call   800134 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000b8:	50                   	push   %eax
  8000b9:	68 5b 12 80 00       	push   $0x80125b
  8000be:	6a 11                	push   $0x11
  8000c0:	68 78 12 80 00       	push   $0x801278
  8000c5:	e8 6a 00 00 00       	call   800134 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ca:	50                   	push   %eax
  8000cb:	68 00 12 80 00       	push   $0x801200
  8000d0:	6a 16                	push   $0x16
  8000d2:	68 78 12 80 00       	push   $0x801278
  8000d7:	e8 58 00 00 00       	call   800134 <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000e7:	e8 6d 0c 00 00       	call   800d59 <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	c1 e0 07             	shl    $0x7,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 20 c0 00       	mov    %eax,0xc02020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800128:	6a 00                	push   $0x0
  80012a:	e8 e9 0b 00 00       	call   800d18 <sys_env_destroy>
}
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800139:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800142:	e8 12 0c 00 00       	call   800d59 <sys_getenvid>
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	ff 75 0c             	pushl  0xc(%ebp)
  80014d:	ff 75 08             	pushl  0x8(%ebp)
  800150:	56                   	push   %esi
  800151:	50                   	push   %eax
  800152:	68 a8 12 80 00       	push   $0x8012a8
  800157:	e8 b3 00 00 00       	call   80020f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015c:	83 c4 18             	add    $0x18,%esp
  80015f:	53                   	push   %ebx
  800160:	ff 75 10             	pushl  0x10(%ebp)
  800163:	e8 56 00 00 00       	call   8001be <vcprintf>
	cprintf("\n");
  800168:	c7 04 24 76 12 80 00 	movl   $0x801276,(%esp)
  80016f:	e8 9b 00 00 00       	call   80020f <cprintf>
  800174:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800177:	cc                   	int3   
  800178:	eb fd                	jmp    800177 <_panic+0x43>

0080017a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	53                   	push   %ebx
  80017e:	83 ec 04             	sub    $0x4,%esp
  800181:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800184:	8b 13                	mov    (%ebx),%edx
  800186:	8d 42 01             	lea    0x1(%edx),%eax
  800189:	89 03                	mov    %eax,(%ebx)
  80018b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800192:	3d ff 00 00 00       	cmp    $0xff,%eax
  800197:	74 09                	je     8001a2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800199:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001a2:	83 ec 08             	sub    $0x8,%esp
  8001a5:	68 ff 00 00 00       	push   $0xff
  8001aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ad:	50                   	push   %eax
  8001ae:	e8 28 0b 00 00       	call   800cdb <sys_cputs>
		b->idx = 0;
  8001b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b9:	83 c4 10             	add    $0x10,%esp
  8001bc:	eb db                	jmp    800199 <putch+0x1f>

008001be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ce:	00 00 00 
	b.cnt = 0;
  8001d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001db:	ff 75 0c             	pushl  0xc(%ebp)
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e7:	50                   	push   %eax
  8001e8:	68 7a 01 80 00       	push   $0x80017a
  8001ed:	e8 fb 00 00 00       	call   8002ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f2:	83 c4 08             	add    $0x8,%esp
  8001f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800201:	50                   	push   %eax
  800202:	e8 d4 0a 00 00       	call   800cdb <sys_cputs>

	return b.cnt;
}
  800207:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800215:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800218:	50                   	push   %eax
  800219:	ff 75 08             	pushl  0x8(%ebp)
  80021c:	e8 9d ff ff ff       	call   8001be <vcprintf>
	va_end(ap);

	return cnt;
}
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 1c             	sub    $0x1c,%esp
  80022c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80022f:	89 d3                	mov    %edx,%ebx
  800231:	8b 75 08             	mov    0x8(%ebp),%esi
  800234:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800237:	8b 45 10             	mov    0x10(%ebp),%eax
  80023a:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  80023d:	89 c2                	mov    %eax,%edx
  80023f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800244:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800247:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80024a:	39 c6                	cmp    %eax,%esi
  80024c:	89 f8                	mov    %edi,%eax
  80024e:	19 c8                	sbb    %ecx,%eax
  800250:	73 32                	jae    800284 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800252:	83 ec 08             	sub    $0x8,%esp
  800255:	53                   	push   %ebx
  800256:	83 ec 04             	sub    $0x4,%esp
  800259:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025c:	ff 75 e0             	pushl  -0x20(%ebp)
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	e8 3a 0e 00 00       	call   8010a0 <__umoddi3>
  800266:	83 c4 14             	add    $0x14,%esp
  800269:	0f be 80 cb 12 80 00 	movsbl 0x8012cb(%eax),%eax
  800270:	50                   	push   %eax
  800271:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800274:	ff d0                	call   *%eax
	return remain - 1;
  800276:	8b 45 14             	mov    0x14(%ebp),%eax
  800279:	83 e8 01             	sub    $0x1,%eax
}
  80027c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027f:	5b                   	pop    %ebx
  800280:	5e                   	pop    %esi
  800281:	5f                   	pop    %edi
  800282:	5d                   	pop    %ebp
  800283:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  800284:	83 ec 0c             	sub    $0xc,%esp
  800287:	ff 75 18             	pushl  0x18(%ebp)
  80028a:	ff 75 14             	pushl  0x14(%ebp)
  80028d:	ff 75 d8             	pushl  -0x28(%ebp)
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	51                   	push   %ecx
  800294:	52                   	push   %edx
  800295:	57                   	push   %edi
  800296:	56                   	push   %esi
  800297:	e8 f4 0c 00 00       	call   800f90 <__udivdi3>
  80029c:	83 c4 18             	add    $0x18,%esp
  80029f:	52                   	push   %edx
  8002a0:	50                   	push   %eax
  8002a1:	89 da                	mov    %ebx,%edx
  8002a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a6:	e8 78 ff ff ff       	call   800223 <printnum_helper>
  8002ab:	89 45 14             	mov    %eax,0x14(%ebp)
  8002ae:	83 c4 20             	add    $0x20,%esp
  8002b1:	eb 9f                	jmp    800252 <printnum_helper+0x2f>

008002b3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c2:	73 0a                	jae    8002ce <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	88 02                	mov    %al,(%edx)
}
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <printfmt>:
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d9:	50                   	push   %eax
  8002da:	ff 75 10             	pushl  0x10(%ebp)
  8002dd:	ff 75 0c             	pushl  0xc(%ebp)
  8002e0:	ff 75 08             	pushl  0x8(%ebp)
  8002e3:	e8 05 00 00 00       	call   8002ed <vprintfmt>
}
  8002e8:	83 c4 10             	add    $0x10,%esp
  8002eb:	c9                   	leave  
  8002ec:	c3                   	ret    

008002ed <vprintfmt>:
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	57                   	push   %edi
  8002f1:	56                   	push   %esi
  8002f2:	53                   	push   %ebx
  8002f3:	83 ec 3c             	sub    $0x3c,%esp
  8002f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002fc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002ff:	e9 3f 05 00 00       	jmp    800843 <vprintfmt+0x556>
		padc = ' ';
  800304:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800308:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  80030f:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800316:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  80031d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  800324:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80032b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800330:	8d 47 01             	lea    0x1(%edi),%eax
  800333:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800336:	0f b6 17             	movzbl (%edi),%edx
  800339:	8d 42 dd             	lea    -0x23(%edx),%eax
  80033c:	3c 55                	cmp    $0x55,%al
  80033e:	0f 87 98 05 00 00    	ja     8008dc <vprintfmt+0x5ef>
  800344:	0f b6 c0             	movzbl %al,%eax
  800347:	ff 24 85 00 14 80 00 	jmp    *0x801400(,%eax,4)
  80034e:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  800351:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  800355:	eb d9                	jmp    800330 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800357:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  80035a:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  800361:	eb cd                	jmp    800330 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800363:	0f b6 d2             	movzbl %dl,%edx
  800366:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800369:	b8 00 00 00 00       	mov    $0x0,%eax
  80036e:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  800371:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800374:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800378:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80037b:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80037e:	83 fb 09             	cmp    $0x9,%ebx
  800381:	77 5c                	ja     8003df <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  800383:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800386:	eb e9                	jmp    800371 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  80038b:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  80038f:	eb 9f                	jmp    800330 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  800391:	8b 45 14             	mov    0x14(%ebp),%eax
  800394:	8b 00                	mov    (%eax),%eax
  800396:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800399:	8b 45 14             	mov    0x14(%ebp),%eax
  80039c:	8d 40 04             	lea    0x4(%eax),%eax
  80039f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8003a5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003a9:	79 85                	jns    800330 <vprintfmt+0x43>
				width = precision, precision = -1;
  8003ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b8:	e9 73 ff ff ff       	jmp    800330 <vprintfmt+0x43>
  8003bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c0:	85 c0                	test   %eax,%eax
  8003c2:	0f 48 c1             	cmovs  %ecx,%eax
  8003c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8003cb:	e9 60 ff ff ff       	jmp    800330 <vprintfmt+0x43>
  8003d0:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8003d3:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8003da:	e9 51 ff ff ff       	jmp    800330 <vprintfmt+0x43>
  8003df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003e5:	eb be                	jmp    8003a5 <vprintfmt+0xb8>
			lflag++;
  8003e7:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003eb:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  8003ee:	e9 3d ff ff ff       	jmp    800330 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  8003f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f6:	8d 78 04             	lea    0x4(%eax),%edi
  8003f9:	83 ec 08             	sub    $0x8,%esp
  8003fc:	56                   	push   %esi
  8003fd:	ff 30                	pushl  (%eax)
  8003ff:	ff d3                	call   *%ebx
			break;
  800401:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800404:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800407:	e9 34 04 00 00       	jmp    800840 <vprintfmt+0x553>
			err = va_arg(ap, int);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 78 04             	lea    0x4(%eax),%edi
  800412:	8b 00                	mov    (%eax),%eax
  800414:	99                   	cltd   
  800415:	31 d0                	xor    %edx,%eax
  800417:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800419:	83 f8 08             	cmp    $0x8,%eax
  80041c:	7f 23                	jg     800441 <vprintfmt+0x154>
  80041e:	8b 14 85 60 15 80 00 	mov    0x801560(,%eax,4),%edx
  800425:	85 d2                	test   %edx,%edx
  800427:	74 18                	je     800441 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800429:	52                   	push   %edx
  80042a:	68 ec 12 80 00       	push   $0x8012ec
  80042f:	56                   	push   %esi
  800430:	53                   	push   %ebx
  800431:	e8 9a fe ff ff       	call   8002d0 <printfmt>
  800436:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800439:	89 7d 14             	mov    %edi,0x14(%ebp)
  80043c:	e9 ff 03 00 00       	jmp    800840 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  800441:	50                   	push   %eax
  800442:	68 e3 12 80 00       	push   $0x8012e3
  800447:	56                   	push   %esi
  800448:	53                   	push   %ebx
  800449:	e8 82 fe ff ff       	call   8002d0 <printfmt>
  80044e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800451:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800454:	e9 e7 03 00 00       	jmp    800840 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	83 c0 04             	add    $0x4,%eax
  80045f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800467:	85 c9                	test   %ecx,%ecx
  800469:	b8 dc 12 80 00       	mov    $0x8012dc,%eax
  80046e:	0f 45 c1             	cmovne %ecx,%eax
  800471:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800474:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800478:	7e 06                	jle    800480 <vprintfmt+0x193>
  80047a:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  80047e:	75 0d                	jne    80048d <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800480:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800483:	89 c7                	mov    %eax,%edi
  800485:	03 45 d8             	add    -0x28(%ebp),%eax
  800488:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80048b:	eb 53                	jmp    8004e0 <vprintfmt+0x1f3>
  80048d:	83 ec 08             	sub    $0x8,%esp
  800490:	ff 75 e0             	pushl  -0x20(%ebp)
  800493:	50                   	push   %eax
  800494:	e8 eb 04 00 00       	call   800984 <strnlen>
  800499:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80049c:	29 c1                	sub    %eax,%ecx
  80049e:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004a6:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8004aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ad:	eb 0f                	jmp    8004be <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	56                   	push   %esi
  8004b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b6:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	83 ef 01             	sub    $0x1,%edi
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	85 ff                	test   %edi,%edi
  8004c0:	7f ed                	jg     8004af <vprintfmt+0x1c2>
  8004c2:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8004c5:	85 c9                	test   %ecx,%ecx
  8004c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cc:	0f 49 c1             	cmovns %ecx,%eax
  8004cf:	29 c1                	sub    %eax,%ecx
  8004d1:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8004d4:	eb aa                	jmp    800480 <vprintfmt+0x193>
					putch(ch, putdat);
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	56                   	push   %esi
  8004da:	52                   	push   %edx
  8004db:	ff d3                	call   *%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8004e3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e5:	83 c7 01             	add    $0x1,%edi
  8004e8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ec:	0f be d0             	movsbl %al,%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	74 2e                	je     800521 <vprintfmt+0x234>
  8004f3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f7:	78 06                	js     8004ff <vprintfmt+0x212>
  8004f9:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004fd:	78 1e                	js     80051d <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ff:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800503:	74 d1                	je     8004d6 <vprintfmt+0x1e9>
  800505:	0f be c0             	movsbl %al,%eax
  800508:	83 e8 20             	sub    $0x20,%eax
  80050b:	83 f8 5e             	cmp    $0x5e,%eax
  80050e:	76 c6                	jbe    8004d6 <vprintfmt+0x1e9>
					putch('?', putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	56                   	push   %esi
  800514:	6a 3f                	push   $0x3f
  800516:	ff d3                	call   *%ebx
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	eb c3                	jmp    8004e0 <vprintfmt+0x1f3>
  80051d:	89 cf                	mov    %ecx,%edi
  80051f:	eb 02                	jmp    800523 <vprintfmt+0x236>
  800521:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  800523:	85 ff                	test   %edi,%edi
  800525:	7e 10                	jle    800537 <vprintfmt+0x24a>
				putch(' ', putdat);
  800527:	83 ec 08             	sub    $0x8,%esp
  80052a:	56                   	push   %esi
  80052b:	6a 20                	push   $0x20
  80052d:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80052f:	83 ef 01             	sub    $0x1,%edi
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	eb ec                	jmp    800523 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
  80053d:	e9 fe 02 00 00       	jmp    800840 <vprintfmt+0x553>
	if (lflag >= 2)
  800542:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800546:	7f 21                	jg     800569 <vprintfmt+0x27c>
	else if (lflag)
  800548:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80054c:	74 79                	je     8005c7 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800556:	89 c1                	mov    %eax,%ecx
  800558:	c1 f9 1f             	sar    $0x1f,%ecx
  80055b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 40 04             	lea    0x4(%eax),%eax
  800564:	89 45 14             	mov    %eax,0x14(%ebp)
  800567:	eb 17                	jmp    800580 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 50 04             	mov    0x4(%eax),%edx
  80056f:	8b 00                	mov    (%eax),%eax
  800571:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800574:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 40 08             	lea    0x8(%eax),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  800580:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800583:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800586:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800589:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  80058c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800590:	78 50                	js     8005e2 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  800592:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800595:	c1 fa 1f             	sar    $0x1f,%edx
  800598:	89 d0                	mov    %edx,%eax
  80059a:	2b 45 e0             	sub    -0x20(%ebp),%eax
  80059d:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8005a0:	85 d2                	test   %edx,%edx
  8005a2:	0f 89 14 02 00 00    	jns    8007bc <vprintfmt+0x4cf>
  8005a8:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005ac:	0f 84 0a 02 00 00    	je     8007bc <vprintfmt+0x4cf>
				putch('+', putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	56                   	push   %esi
  8005b6:	6a 2b                	push   $0x2b
  8005b8:	ff d3                	call   *%ebx
  8005ba:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c2:	e9 5c 01 00 00       	jmp    800723 <vprintfmt+0x436>
		return va_arg(*ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cf:	89 c1                	mov    %eax,%ecx
  8005d1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 40 04             	lea    0x4(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e0:	eb 9e                	jmp    800580 <vprintfmt+0x293>
				putch('-', putdat);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	56                   	push   %esi
  8005e6:	6a 2d                	push   $0x2d
  8005e8:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f0:	f7 d8                	neg    %eax
  8005f2:	83 d2 00             	adc    $0x0,%edx
  8005f5:	f7 da                	neg    %edx
  8005f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005fa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005fd:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800600:	b8 0a 00 00 00       	mov    $0xa,%eax
  800605:	e9 19 01 00 00       	jmp    800723 <vprintfmt+0x436>
	if (lflag >= 2)
  80060a:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80060e:	7f 29                	jg     800639 <vprintfmt+0x34c>
	else if (lflag)
  800610:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800614:	74 44                	je     80065a <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 00                	mov    (%eax),%eax
  80061b:	ba 00 00 00 00       	mov    $0x0,%edx
  800620:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800623:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 40 04             	lea    0x4(%eax),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800634:	e9 ea 00 00 00       	jmp    800723 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 50 04             	mov    0x4(%eax),%edx
  80063f:	8b 00                	mov    (%eax),%eax
  800641:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800644:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 40 08             	lea    0x8(%eax),%eax
  80064d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800650:	b8 0a 00 00 00       	mov    $0xa,%eax
  800655:	e9 c9 00 00 00       	jmp    800723 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	ba 00 00 00 00       	mov    $0x0,%edx
  800664:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800667:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8d 40 04             	lea    0x4(%eax),%eax
  800670:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800673:	b8 0a 00 00 00       	mov    $0xa,%eax
  800678:	e9 a6 00 00 00       	jmp    800723 <vprintfmt+0x436>
			putch('0', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	56                   	push   %esi
  800681:	6a 30                	push   $0x30
  800683:	ff d3                	call   *%ebx
	if (lflag >= 2)
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80068c:	7f 26                	jg     8006b4 <vprintfmt+0x3c7>
	else if (lflag)
  80068e:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800692:	74 3e                	je     8006d2 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 00                	mov    (%eax),%eax
  800699:	ba 00 00 00 00       	mov    $0x0,%edx
  80069e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006a1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 40 04             	lea    0x4(%eax),%eax
  8006aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006ad:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b2:	eb 6f                	jmp    800723 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 50 04             	mov    0x4(%eax),%edx
  8006ba:	8b 00                	mov    (%eax),%eax
  8006bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006bf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 40 08             	lea    0x8(%eax),%eax
  8006c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006cb:	b8 08 00 00 00       	mov    $0x8,%eax
  8006d0:	eb 51                	jmp    800723 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8006dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006df:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 40 04             	lea    0x4(%eax),%eax
  8006e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8006f0:	eb 31                	jmp    800723 <vprintfmt+0x436>
			putch('0', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	56                   	push   %esi
  8006f6:	6a 30                	push   $0x30
  8006f8:	ff d3                	call   *%ebx
			putch('x', putdat);
  8006fa:	83 c4 08             	add    $0x8,%esp
  8006fd:	56                   	push   %esi
  8006fe:	6a 78                	push   $0x78
  800700:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8b 00                	mov    (%eax),%eax
  800707:	ba 00 00 00 00       	mov    $0x0,%edx
  80070c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80070f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800712:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800715:	8b 45 14             	mov    0x14(%ebp),%eax
  800718:	8d 40 04             	lea    0x4(%eax),%eax
  80071b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071e:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800723:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800727:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80072a:	89 c1                	mov    %eax,%ecx
  80072c:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  80072f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800732:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800737:	89 c2                	mov    %eax,%edx
  800739:	39 c1                	cmp    %eax,%ecx
  80073b:	0f 87 85 00 00 00    	ja     8007c6 <vprintfmt+0x4d9>
		tmp /= base;
  800741:	89 d0                	mov    %edx,%eax
  800743:	ba 00 00 00 00       	mov    $0x0,%edx
  800748:	f7 f1                	div    %ecx
		len++;
  80074a:	83 c7 01             	add    $0x1,%edi
  80074d:	eb e8                	jmp    800737 <vprintfmt+0x44a>
	if (lflag >= 2)
  80074f:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800753:	7f 26                	jg     80077b <vprintfmt+0x48e>
	else if (lflag)
  800755:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800759:	74 3e                	je     800799 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8b 00                	mov    (%eax),%eax
  800760:	ba 00 00 00 00       	mov    $0x0,%edx
  800765:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800768:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8d 40 04             	lea    0x4(%eax),%eax
  800771:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800774:	b8 10 00 00 00       	mov    $0x10,%eax
  800779:	eb a8                	jmp    800723 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8b 50 04             	mov    0x4(%eax),%edx
  800781:	8b 00                	mov    (%eax),%eax
  800783:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800786:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8d 40 08             	lea    0x8(%eax),%eax
  80078f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800792:	b8 10 00 00 00       	mov    $0x10,%eax
  800797:	eb 8a                	jmp    800723 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8b 00                	mov    (%eax),%eax
  80079e:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007a6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ac:	8d 40 04             	lea    0x4(%eax),%eax
  8007af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b2:	b8 10 00 00 00       	mov    $0x10,%eax
  8007b7:	e9 67 ff ff ff       	jmp    800723 <vprintfmt+0x436>
			base = 10;
  8007bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c1:	e9 5d ff ff ff       	jmp    800723 <vprintfmt+0x436>
  8007c6:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8007c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007cc:	29 f8                	sub    %edi,%eax
  8007ce:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8007d0:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8007d4:	74 15                	je     8007eb <vprintfmt+0x4fe>
		while (width > 0) {
  8007d6:	85 ff                	test   %edi,%edi
  8007d8:	7e 48                	jle    800822 <vprintfmt+0x535>
			putch(padc, putdat);
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	56                   	push   %esi
  8007de:	ff 75 e0             	pushl  -0x20(%ebp)
  8007e1:	ff d3                	call   *%ebx
			width--;
  8007e3:	83 ef 01             	sub    $0x1,%edi
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	eb eb                	jmp    8007d6 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  8007eb:	83 ec 0c             	sub    $0xc,%esp
  8007ee:	6a 2d                	push   $0x2d
  8007f0:	ff 75 cc             	pushl  -0x34(%ebp)
  8007f3:	ff 75 c8             	pushl  -0x38(%ebp)
  8007f6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007f9:	ff 75 d0             	pushl  -0x30(%ebp)
  8007fc:	89 f2                	mov    %esi,%edx
  8007fe:	89 d8                	mov    %ebx,%eax
  800800:	e8 1e fa ff ff       	call   800223 <printnum_helper>
		width -= len;
  800805:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800808:	2b 7d cc             	sub    -0x34(%ebp),%edi
  80080b:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  80080e:	85 ff                	test   %edi,%edi
  800810:	7e 2e                	jle    800840 <vprintfmt+0x553>
			putch(padc, putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	56                   	push   %esi
  800816:	6a 20                	push   $0x20
  800818:	ff d3                	call   *%ebx
			width--;
  80081a:	83 ef 01             	sub    $0x1,%edi
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	eb ec                	jmp    80080e <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800822:	83 ec 0c             	sub    $0xc,%esp
  800825:	ff 75 e0             	pushl  -0x20(%ebp)
  800828:	ff 75 cc             	pushl  -0x34(%ebp)
  80082b:	ff 75 c8             	pushl  -0x38(%ebp)
  80082e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800831:	ff 75 d0             	pushl  -0x30(%ebp)
  800834:	89 f2                	mov    %esi,%edx
  800836:	89 d8                	mov    %ebx,%eax
  800838:	e8 e6 f9 ff ff       	call   800223 <printnum_helper>
  80083d:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800840:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800843:	83 c7 01             	add    $0x1,%edi
  800846:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80084a:	83 f8 25             	cmp    $0x25,%eax
  80084d:	0f 84 b1 fa ff ff    	je     800304 <vprintfmt+0x17>
			if (ch == '\0')
  800853:	85 c0                	test   %eax,%eax
  800855:	0f 84 a1 00 00 00    	je     8008fc <vprintfmt+0x60f>
			putch(ch, putdat);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	56                   	push   %esi
  80085f:	50                   	push   %eax
  800860:	ff d3                	call   *%ebx
  800862:	83 c4 10             	add    $0x10,%esp
  800865:	eb dc                	jmp    800843 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800867:	8b 45 14             	mov    0x14(%ebp),%eax
  80086a:	83 c0 04             	add    $0x4,%eax
  80086d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800875:	85 ff                	test   %edi,%edi
  800877:	74 15                	je     80088e <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800879:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  80087f:	7f 29                	jg     8008aa <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800881:	0f b6 06             	movzbl (%esi),%eax
  800884:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800886:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800889:	89 45 14             	mov    %eax,0x14(%ebp)
  80088c:	eb b2                	jmp    800840 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  80088e:	68 84 13 80 00       	push   $0x801384
  800893:	68 ec 12 80 00       	push   $0x8012ec
  800898:	56                   	push   %esi
  800899:	53                   	push   %ebx
  80089a:	e8 31 fa ff ff       	call   8002d0 <printfmt>
  80089f:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8008a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008a5:	89 45 14             	mov    %eax,0x14(%ebp)
  8008a8:	eb 96                	jmp    800840 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  8008aa:	68 bc 13 80 00       	push   $0x8013bc
  8008af:	68 ec 12 80 00       	push   $0x8012ec
  8008b4:	56                   	push   %esi
  8008b5:	53                   	push   %ebx
  8008b6:	e8 15 fa ff ff       	call   8002d0 <printfmt>
				*res = -1;
  8008bb:	c6 07 ff             	movb   $0xff,(%edi)
  8008be:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8008c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008c4:	89 45 14             	mov    %eax,0x14(%ebp)
  8008c7:	e9 74 ff ff ff       	jmp    800840 <vprintfmt+0x553>
			putch(ch, putdat);
  8008cc:	83 ec 08             	sub    $0x8,%esp
  8008cf:	56                   	push   %esi
  8008d0:	6a 25                	push   $0x25
  8008d2:	ff d3                	call   *%ebx
			break;
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	e9 64 ff ff ff       	jmp    800840 <vprintfmt+0x553>
			putch('%', putdat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	56                   	push   %esi
  8008e0:	6a 25                	push   $0x25
  8008e2:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	89 f8                	mov    %edi,%eax
  8008e9:	eb 03                	jmp    8008ee <vprintfmt+0x601>
  8008eb:	83 e8 01             	sub    $0x1,%eax
  8008ee:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008f2:	75 f7                	jne    8008eb <vprintfmt+0x5fe>
  8008f4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008f7:	e9 44 ff ff ff       	jmp    800840 <vprintfmt+0x553>
}
  8008fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5f                   	pop    %edi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 18             	sub    $0x18,%esp
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800910:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800913:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800917:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80091a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800921:	85 c0                	test   %eax,%eax
  800923:	74 26                	je     80094b <vsnprintf+0x47>
  800925:	85 d2                	test   %edx,%edx
  800927:	7e 22                	jle    80094b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800929:	ff 75 14             	pushl  0x14(%ebp)
  80092c:	ff 75 10             	pushl  0x10(%ebp)
  80092f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800932:	50                   	push   %eax
  800933:	68 b3 02 80 00       	push   $0x8002b3
  800938:	e8 b0 f9 ff ff       	call   8002ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80093d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800940:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800943:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800946:	83 c4 10             	add    $0x10,%esp
}
  800949:	c9                   	leave  
  80094a:	c3                   	ret    
		return -E_INVAL;
  80094b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800950:	eb f7                	jmp    800949 <vsnprintf+0x45>

00800952 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800958:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80095b:	50                   	push   %eax
  80095c:	ff 75 10             	pushl  0x10(%ebp)
  80095f:	ff 75 0c             	pushl  0xc(%ebp)
  800962:	ff 75 08             	pushl  0x8(%ebp)
  800965:	e8 9a ff ff ff       	call   800904 <vsnprintf>
	va_end(ap);

	return rc;
}
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
  800977:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80097b:	74 05                	je     800982 <strlen+0x16>
		n++;
  80097d:	83 c0 01             	add    $0x1,%eax
  800980:	eb f5                	jmp    800977 <strlen+0xb>
	return n;
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80098d:	ba 00 00 00 00       	mov    $0x0,%edx
  800992:	39 c2                	cmp    %eax,%edx
  800994:	74 0d                	je     8009a3 <strnlen+0x1f>
  800996:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80099a:	74 05                	je     8009a1 <strnlen+0x1d>
		n++;
  80099c:	83 c2 01             	add    $0x1,%edx
  80099f:	eb f1                	jmp    800992 <strnlen+0xe>
  8009a1:	89 d0                	mov    %edx,%eax
	return n;
}
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009b8:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009bb:	83 c2 01             	add    $0x1,%edx
  8009be:	84 c9                	test   %cl,%cl
  8009c0:	75 f2                	jne    8009b4 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009c2:	5b                   	pop    %ebx
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	53                   	push   %ebx
  8009c9:	83 ec 10             	sub    $0x10,%esp
  8009cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009cf:	53                   	push   %ebx
  8009d0:	e8 97 ff ff ff       	call   80096c <strlen>
  8009d5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009d8:	ff 75 0c             	pushl  0xc(%ebp)
  8009db:	01 d8                	add    %ebx,%eax
  8009dd:	50                   	push   %eax
  8009de:	e8 c2 ff ff ff       	call   8009a5 <strcpy>
	return dst;
}
  8009e3:	89 d8                	mov    %ebx,%eax
  8009e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	56                   	push   %esi
  8009ee:	53                   	push   %ebx
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f5:	89 c6                	mov    %eax,%esi
  8009f7:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	39 f2                	cmp    %esi,%edx
  8009fe:	74 11                	je     800a11 <strncpy+0x27>
		*dst++ = *src;
  800a00:	83 c2 01             	add    $0x1,%edx
  800a03:	0f b6 19             	movzbl (%ecx),%ebx
  800a06:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a09:	80 fb 01             	cmp    $0x1,%bl
  800a0c:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800a0f:	eb eb                	jmp    8009fc <strncpy+0x12>
	}
	return ret;
}
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a20:	8b 55 10             	mov    0x10(%ebp),%edx
  800a23:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a25:	85 d2                	test   %edx,%edx
  800a27:	74 21                	je     800a4a <strlcpy+0x35>
  800a29:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a2d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800a2f:	39 c2                	cmp    %eax,%edx
  800a31:	74 14                	je     800a47 <strlcpy+0x32>
  800a33:	0f b6 19             	movzbl (%ecx),%ebx
  800a36:	84 db                	test   %bl,%bl
  800a38:	74 0b                	je     800a45 <strlcpy+0x30>
			*dst++ = *src++;
  800a3a:	83 c1 01             	add    $0x1,%ecx
  800a3d:	83 c2 01             	add    $0x1,%edx
  800a40:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a43:	eb ea                	jmp    800a2f <strlcpy+0x1a>
  800a45:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a47:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a4a:	29 f0                	sub    %esi,%eax
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5e                   	pop    %esi
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a56:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a59:	0f b6 01             	movzbl (%ecx),%eax
  800a5c:	84 c0                	test   %al,%al
  800a5e:	74 0c                	je     800a6c <strcmp+0x1c>
  800a60:	3a 02                	cmp    (%edx),%al
  800a62:	75 08                	jne    800a6c <strcmp+0x1c>
		p++, q++;
  800a64:	83 c1 01             	add    $0x1,%ecx
  800a67:	83 c2 01             	add    $0x1,%edx
  800a6a:	eb ed                	jmp    800a59 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6c:	0f b6 c0             	movzbl %al,%eax
  800a6f:	0f b6 12             	movzbl (%edx),%edx
  800a72:	29 d0                	sub    %edx,%eax
}
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	53                   	push   %ebx
  800a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a80:	89 c3                	mov    %eax,%ebx
  800a82:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a85:	eb 06                	jmp    800a8d <strncmp+0x17>
		n--, p++, q++;
  800a87:	83 c0 01             	add    $0x1,%eax
  800a8a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a8d:	39 d8                	cmp    %ebx,%eax
  800a8f:	74 16                	je     800aa7 <strncmp+0x31>
  800a91:	0f b6 08             	movzbl (%eax),%ecx
  800a94:	84 c9                	test   %cl,%cl
  800a96:	74 04                	je     800a9c <strncmp+0x26>
  800a98:	3a 0a                	cmp    (%edx),%cl
  800a9a:	74 eb                	je     800a87 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a9c:	0f b6 00             	movzbl (%eax),%eax
  800a9f:	0f b6 12             	movzbl (%edx),%edx
  800aa2:	29 d0                	sub    %edx,%eax
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    
		return 0;
  800aa7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aac:	eb f6                	jmp    800aa4 <strncmp+0x2e>

00800aae <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab8:	0f b6 10             	movzbl (%eax),%edx
  800abb:	84 d2                	test   %dl,%dl
  800abd:	74 09                	je     800ac8 <strchr+0x1a>
		if (*s == c)
  800abf:	38 ca                	cmp    %cl,%dl
  800ac1:	74 0a                	je     800acd <strchr+0x1f>
	for (; *s; s++)
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	eb f0                	jmp    800ab8 <strchr+0xa>
			return (char *) s;
	return 0;
  800ac8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800adc:	38 ca                	cmp    %cl,%dl
  800ade:	74 09                	je     800ae9 <strfind+0x1a>
  800ae0:	84 d2                	test   %dl,%dl
  800ae2:	74 05                	je     800ae9 <strfind+0x1a>
	for (; *s; s++)
  800ae4:	83 c0 01             	add    $0x1,%eax
  800ae7:	eb f0                	jmp    800ad9 <strfind+0xa>
			break;
	return (char *) s;
}
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	57                   	push   %edi
  800aef:	56                   	push   %esi
  800af0:	53                   	push   %ebx
  800af1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af7:	85 c9                	test   %ecx,%ecx
  800af9:	74 31                	je     800b2c <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800afb:	89 f8                	mov    %edi,%eax
  800afd:	09 c8                	or     %ecx,%eax
  800aff:	a8 03                	test   $0x3,%al
  800b01:	75 23                	jne    800b26 <memset+0x3b>
		c &= 0xFF;
  800b03:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b07:	89 d3                	mov    %edx,%ebx
  800b09:	c1 e3 08             	shl    $0x8,%ebx
  800b0c:	89 d0                	mov    %edx,%eax
  800b0e:	c1 e0 18             	shl    $0x18,%eax
  800b11:	89 d6                	mov    %edx,%esi
  800b13:	c1 e6 10             	shl    $0x10,%esi
  800b16:	09 f0                	or     %esi,%eax
  800b18:	09 c2                	or     %eax,%edx
  800b1a:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b1c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b1f:	89 d0                	mov    %edx,%eax
  800b21:	fc                   	cld    
  800b22:	f3 ab                	rep stos %eax,%es:(%edi)
  800b24:	eb 06                	jmp    800b2c <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b29:	fc                   	cld    
  800b2a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b2c:	89 f8                	mov    %edi,%eax
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b41:	39 c6                	cmp    %eax,%esi
  800b43:	73 32                	jae    800b77 <memmove+0x44>
  800b45:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b48:	39 c2                	cmp    %eax,%edx
  800b4a:	76 2b                	jbe    800b77 <memmove+0x44>
		s += n;
		d += n;
  800b4c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4f:	89 fe                	mov    %edi,%esi
  800b51:	09 ce                	or     %ecx,%esi
  800b53:	09 d6                	or     %edx,%esi
  800b55:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b5b:	75 0e                	jne    800b6b <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b5d:	83 ef 04             	sub    $0x4,%edi
  800b60:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b63:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b66:	fd                   	std    
  800b67:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b69:	eb 09                	jmp    800b74 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b6b:	83 ef 01             	sub    $0x1,%edi
  800b6e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b71:	fd                   	std    
  800b72:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b74:	fc                   	cld    
  800b75:	eb 1a                	jmp    800b91 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b77:	89 c2                	mov    %eax,%edx
  800b79:	09 ca                	or     %ecx,%edx
  800b7b:	09 f2                	or     %esi,%edx
  800b7d:	f6 c2 03             	test   $0x3,%dl
  800b80:	75 0a                	jne    800b8c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b82:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b85:	89 c7                	mov    %eax,%edi
  800b87:	fc                   	cld    
  800b88:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8a:	eb 05                	jmp    800b91 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b8c:	89 c7                	mov    %eax,%edi
  800b8e:	fc                   	cld    
  800b8f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b9b:	ff 75 10             	pushl  0x10(%ebp)
  800b9e:	ff 75 0c             	pushl  0xc(%ebp)
  800ba1:	ff 75 08             	pushl  0x8(%ebp)
  800ba4:	e8 8a ff ff ff       	call   800b33 <memmove>
}
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
  800bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bb6:	89 c6                	mov    %eax,%esi
  800bb8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bbb:	39 f0                	cmp    %esi,%eax
  800bbd:	74 1c                	je     800bdb <memcmp+0x30>
		if (*s1 != *s2)
  800bbf:	0f b6 08             	movzbl (%eax),%ecx
  800bc2:	0f b6 1a             	movzbl (%edx),%ebx
  800bc5:	38 d9                	cmp    %bl,%cl
  800bc7:	75 08                	jne    800bd1 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bc9:	83 c0 01             	add    $0x1,%eax
  800bcc:	83 c2 01             	add    $0x1,%edx
  800bcf:	eb ea                	jmp    800bbb <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800bd1:	0f b6 c1             	movzbl %cl,%eax
  800bd4:	0f b6 db             	movzbl %bl,%ebx
  800bd7:	29 d8                	sub    %ebx,%eax
  800bd9:	eb 05                	jmp    800be0 <memcmp+0x35>
	}

	return 0;
  800bdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bed:	89 c2                	mov    %eax,%edx
  800bef:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bf2:	39 d0                	cmp    %edx,%eax
  800bf4:	73 09                	jae    800bff <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf6:	38 08                	cmp    %cl,(%eax)
  800bf8:	74 05                	je     800bff <memfind+0x1b>
	for (; s < ends; s++)
  800bfa:	83 c0 01             	add    $0x1,%eax
  800bfd:	eb f3                	jmp    800bf2 <memfind+0xe>
			break;
	return (void *) s;
}
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	57                   	push   %edi
  800c05:	56                   	push   %esi
  800c06:	53                   	push   %ebx
  800c07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c0d:	eb 03                	jmp    800c12 <strtol+0x11>
		s++;
  800c0f:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c12:	0f b6 01             	movzbl (%ecx),%eax
  800c15:	3c 20                	cmp    $0x20,%al
  800c17:	74 f6                	je     800c0f <strtol+0xe>
  800c19:	3c 09                	cmp    $0x9,%al
  800c1b:	74 f2                	je     800c0f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c1d:	3c 2b                	cmp    $0x2b,%al
  800c1f:	74 2a                	je     800c4b <strtol+0x4a>
	int neg = 0;
  800c21:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c26:	3c 2d                	cmp    $0x2d,%al
  800c28:	74 2b                	je     800c55 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c2a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c30:	75 0f                	jne    800c41 <strtol+0x40>
  800c32:	80 39 30             	cmpb   $0x30,(%ecx)
  800c35:	74 28                	je     800c5f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c37:	85 db                	test   %ebx,%ebx
  800c39:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c3e:	0f 44 d8             	cmove  %eax,%ebx
  800c41:	b8 00 00 00 00       	mov    $0x0,%eax
  800c46:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c49:	eb 50                	jmp    800c9b <strtol+0x9a>
		s++;
  800c4b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c4e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c53:	eb d5                	jmp    800c2a <strtol+0x29>
		s++, neg = 1;
  800c55:	83 c1 01             	add    $0x1,%ecx
  800c58:	bf 01 00 00 00       	mov    $0x1,%edi
  800c5d:	eb cb                	jmp    800c2a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c5f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c63:	74 0e                	je     800c73 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c65:	85 db                	test   %ebx,%ebx
  800c67:	75 d8                	jne    800c41 <strtol+0x40>
		s++, base = 8;
  800c69:	83 c1 01             	add    $0x1,%ecx
  800c6c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c71:	eb ce                	jmp    800c41 <strtol+0x40>
		s += 2, base = 16;
  800c73:	83 c1 02             	add    $0x2,%ecx
  800c76:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c7b:	eb c4                	jmp    800c41 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c7d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c80:	89 f3                	mov    %esi,%ebx
  800c82:	80 fb 19             	cmp    $0x19,%bl
  800c85:	77 29                	ja     800cb0 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c87:	0f be d2             	movsbl %dl,%edx
  800c8a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c8d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c90:	7d 30                	jge    800cc2 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c92:	83 c1 01             	add    $0x1,%ecx
  800c95:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c99:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c9b:	0f b6 11             	movzbl (%ecx),%edx
  800c9e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ca1:	89 f3                	mov    %esi,%ebx
  800ca3:	80 fb 09             	cmp    $0x9,%bl
  800ca6:	77 d5                	ja     800c7d <strtol+0x7c>
			dig = *s - '0';
  800ca8:	0f be d2             	movsbl %dl,%edx
  800cab:	83 ea 30             	sub    $0x30,%edx
  800cae:	eb dd                	jmp    800c8d <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800cb0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cb3:	89 f3                	mov    %esi,%ebx
  800cb5:	80 fb 19             	cmp    $0x19,%bl
  800cb8:	77 08                	ja     800cc2 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800cba:	0f be d2             	movsbl %dl,%edx
  800cbd:	83 ea 37             	sub    $0x37,%edx
  800cc0:	eb cb                	jmp    800c8d <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cc2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc6:	74 05                	je     800ccd <strtol+0xcc>
		*endptr = (char *) s;
  800cc8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ccb:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ccd:	89 c2                	mov    %eax,%edx
  800ccf:	f7 da                	neg    %edx
  800cd1:	85 ff                	test   %edi,%edi
  800cd3:	0f 45 c2             	cmovne %edx,%eax
}
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	57                   	push   %edi
  800cdf:	56                   	push   %esi
  800ce0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	89 c3                	mov    %eax,%ebx
  800cee:	89 c7                	mov    %eax,%edi
  800cf0:	89 c6                	mov    %eax,%esi
  800cf2:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cff:	ba 00 00 00 00       	mov    $0x0,%edx
  800d04:	b8 01 00 00 00       	mov    $0x1,%eax
  800d09:	89 d1                	mov    %edx,%ecx
  800d0b:	89 d3                	mov    %edx,%ebx
  800d0d:	89 d7                	mov    %edx,%edi
  800d0f:	89 d6                	mov    %edx,%esi
  800d11:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d26:	8b 55 08             	mov    0x8(%ebp),%edx
  800d29:	b8 03 00 00 00       	mov    $0x3,%eax
  800d2e:	89 cb                	mov    %ecx,%ebx
  800d30:	89 cf                	mov    %ecx,%edi
  800d32:	89 ce                	mov    %ecx,%esi
  800d34:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7f 08                	jg     800d42 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d42:	83 ec 0c             	sub    $0xc,%esp
  800d45:	50                   	push   %eax
  800d46:	6a 03                	push   $0x3
  800d48:	68 84 15 80 00       	push   $0x801584
  800d4d:	6a 23                	push   $0x23
  800d4f:	68 a1 15 80 00       	push   $0x8015a1
  800d54:	e8 db f3 ff ff       	call   800134 <_panic>

00800d59 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d64:	b8 02 00 00 00       	mov    $0x2,%eax
  800d69:	89 d1                	mov    %edx,%ecx
  800d6b:	89 d3                	mov    %edx,%ebx
  800d6d:	89 d7                	mov    %edx,%edi
  800d6f:	89 d6                	mov    %edx,%esi
  800d71:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_yield>:

void
sys_yield(void)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d83:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d88:	89 d1                	mov    %edx,%ecx
  800d8a:	89 d3                	mov    %edx,%ebx
  800d8c:	89 d7                	mov    %edx,%edi
  800d8e:	89 d6                	mov    %edx,%esi
  800d90:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da0:	be 00 00 00 00       	mov    $0x0,%esi
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dab:	b8 04 00 00 00       	mov    $0x4,%eax
  800db0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db3:	89 f7                	mov    %esi,%edi
  800db5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db7:	85 c0                	test   %eax,%eax
  800db9:	7f 08                	jg     800dc3 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbe:	5b                   	pop    %ebx
  800dbf:	5e                   	pop    %esi
  800dc0:	5f                   	pop    %edi
  800dc1:	5d                   	pop    %ebp
  800dc2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 04                	push   $0x4
  800dc9:	68 84 15 80 00       	push   $0x801584
  800dce:	6a 23                	push   $0x23
  800dd0:	68 a1 15 80 00       	push   $0x8015a1
  800dd5:	e8 5a f3 ff ff       	call   800134 <_panic>

00800dda <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	57                   	push   %edi
  800dde:	56                   	push   %esi
  800ddf:	53                   	push   %ebx
  800de0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de3:	8b 55 08             	mov    0x8(%ebp),%edx
  800de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de9:	b8 05 00 00 00       	mov    $0x5,%eax
  800dee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df4:	8b 75 18             	mov    0x18(%ebp),%esi
  800df7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	7f 08                	jg     800e05 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 05                	push   $0x5
  800e0b:	68 84 15 80 00       	push   $0x801584
  800e10:	6a 23                	push   $0x23
  800e12:	68 a1 15 80 00       	push   $0x8015a1
  800e17:	e8 18 f3 ff ff       	call   800134 <_panic>

00800e1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	57                   	push   %edi
  800e20:	56                   	push   %esi
  800e21:	53                   	push   %ebx
  800e22:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e30:	b8 06 00 00 00       	mov    $0x6,%eax
  800e35:	89 df                	mov    %ebx,%edi
  800e37:	89 de                	mov    %ebx,%esi
  800e39:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	7f 08                	jg     800e47 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	83 ec 0c             	sub    $0xc,%esp
  800e4a:	50                   	push   %eax
  800e4b:	6a 06                	push   $0x6
  800e4d:	68 84 15 80 00       	push   $0x801584
  800e52:	6a 23                	push   $0x23
  800e54:	68 a1 15 80 00       	push   $0x8015a1
  800e59:	e8 d6 f2 ff ff       	call   800134 <_panic>

00800e5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e72:	b8 08 00 00 00       	mov    $0x8,%eax
  800e77:	89 df                	mov    %ebx,%edi
  800e79:	89 de                	mov    %ebx,%esi
  800e7b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e7d:	85 c0                	test   %eax,%eax
  800e7f:	7f 08                	jg     800e89 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e81:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5f                   	pop    %edi
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	50                   	push   %eax
  800e8d:	6a 08                	push   $0x8
  800e8f:	68 84 15 80 00       	push   $0x801584
  800e94:	6a 23                	push   $0x23
  800e96:	68 a1 15 80 00       	push   $0x8015a1
  800e9b:	e8 94 f2 ff ff       	call   800134 <_panic>

00800ea0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
  800ea6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eae:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb4:	b8 09 00 00 00       	mov    $0x9,%eax
  800eb9:	89 df                	mov    %ebx,%edi
  800ebb:	89 de                	mov    %ebx,%esi
  800ebd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	7f 08                	jg     800ecb <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ec3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecb:	83 ec 0c             	sub    $0xc,%esp
  800ece:	50                   	push   %eax
  800ecf:	6a 09                	push   $0x9
  800ed1:	68 84 15 80 00       	push   $0x801584
  800ed6:	6a 23                	push   $0x23
  800ed8:	68 a1 15 80 00       	push   $0x8015a1
  800edd:	e8 52 f2 ff ff       	call   800134 <_panic>

00800ee2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ee8:	8b 55 08             	mov    0x8(%ebp),%edx
  800eeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eee:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ef3:	be 00 00 00 00       	mov    $0x0,%esi
  800ef8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800efe:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
  800f0b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f0e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f13:	8b 55 08             	mov    0x8(%ebp),%edx
  800f16:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f1b:	89 cb                	mov    %ecx,%ebx
  800f1d:	89 cf                	mov    %ecx,%edi
  800f1f:	89 ce                	mov    %ecx,%esi
  800f21:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f23:	85 c0                	test   %eax,%eax
  800f25:	7f 08                	jg     800f2f <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2f:	83 ec 0c             	sub    $0xc,%esp
  800f32:	50                   	push   %eax
  800f33:	6a 0c                	push   $0xc
  800f35:	68 84 15 80 00       	push   $0x801584
  800f3a:	6a 23                	push   $0x23
  800f3c:	68 a1 15 80 00       	push   $0x8015a1
  800f41:	e8 ee f1 ff ff       	call   800134 <_panic>

00800f46 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	57                   	push   %edi
  800f4a:	56                   	push   %esi
  800f4b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f51:	8b 55 08             	mov    0x8(%ebp),%edx
  800f54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f57:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f5c:	89 df                	mov    %ebx,%edi
  800f5e:	89 de                	mov    %ebx,%esi
  800f60:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f62:	5b                   	pop    %ebx
  800f63:	5e                   	pop    %esi
  800f64:	5f                   	pop    %edi
  800f65:	5d                   	pop    %ebp
  800f66:	c3                   	ret    

00800f67 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	57                   	push   %edi
  800f6b:	56                   	push   %esi
  800f6c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f72:	8b 55 08             	mov    0x8(%ebp),%edx
  800f75:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f7a:	89 cb                	mov    %ecx,%ebx
  800f7c:	89 cf                	mov    %ecx,%edi
  800f7e:	89 ce                	mov    %ecx,%esi
  800f80:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    
  800f87:	66 90                	xchg   %ax,%ax
  800f89:	66 90                	xchg   %ax,%ax
  800f8b:	66 90                	xchg   %ax,%ax
  800f8d:	66 90                	xchg   %ax,%ax
  800f8f:	90                   	nop

00800f90 <__udivdi3>:
  800f90:	55                   	push   %ebp
  800f91:	57                   	push   %edi
  800f92:	56                   	push   %esi
  800f93:	53                   	push   %ebx
  800f94:	83 ec 1c             	sub    $0x1c,%esp
  800f97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f9b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fa3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800fa7:	85 d2                	test   %edx,%edx
  800fa9:	75 4d                	jne    800ff8 <__udivdi3+0x68>
  800fab:	39 f3                	cmp    %esi,%ebx
  800fad:	76 19                	jbe    800fc8 <__udivdi3+0x38>
  800faf:	31 ff                	xor    %edi,%edi
  800fb1:	89 e8                	mov    %ebp,%eax
  800fb3:	89 f2                	mov    %esi,%edx
  800fb5:	f7 f3                	div    %ebx
  800fb7:	89 fa                	mov    %edi,%edx
  800fb9:	83 c4 1c             	add    $0x1c,%esp
  800fbc:	5b                   	pop    %ebx
  800fbd:	5e                   	pop    %esi
  800fbe:	5f                   	pop    %edi
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    
  800fc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc8:	89 d9                	mov    %ebx,%ecx
  800fca:	85 db                	test   %ebx,%ebx
  800fcc:	75 0b                	jne    800fd9 <__udivdi3+0x49>
  800fce:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd3:	31 d2                	xor    %edx,%edx
  800fd5:	f7 f3                	div    %ebx
  800fd7:	89 c1                	mov    %eax,%ecx
  800fd9:	31 d2                	xor    %edx,%edx
  800fdb:	89 f0                	mov    %esi,%eax
  800fdd:	f7 f1                	div    %ecx
  800fdf:	89 c6                	mov    %eax,%esi
  800fe1:	89 e8                	mov    %ebp,%eax
  800fe3:	89 f7                	mov    %esi,%edi
  800fe5:	f7 f1                	div    %ecx
  800fe7:	89 fa                	mov    %edi,%edx
  800fe9:	83 c4 1c             	add    $0x1c,%esp
  800fec:	5b                   	pop    %ebx
  800fed:	5e                   	pop    %esi
  800fee:	5f                   	pop    %edi
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    
  800ff1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ff8:	39 f2                	cmp    %esi,%edx
  800ffa:	77 1c                	ja     801018 <__udivdi3+0x88>
  800ffc:	0f bd fa             	bsr    %edx,%edi
  800fff:	83 f7 1f             	xor    $0x1f,%edi
  801002:	75 2c                	jne    801030 <__udivdi3+0xa0>
  801004:	39 f2                	cmp    %esi,%edx
  801006:	72 06                	jb     80100e <__udivdi3+0x7e>
  801008:	31 c0                	xor    %eax,%eax
  80100a:	39 eb                	cmp    %ebp,%ebx
  80100c:	77 a9                	ja     800fb7 <__udivdi3+0x27>
  80100e:	b8 01 00 00 00       	mov    $0x1,%eax
  801013:	eb a2                	jmp    800fb7 <__udivdi3+0x27>
  801015:	8d 76 00             	lea    0x0(%esi),%esi
  801018:	31 ff                	xor    %edi,%edi
  80101a:	31 c0                	xor    %eax,%eax
  80101c:	89 fa                	mov    %edi,%edx
  80101e:	83 c4 1c             	add    $0x1c,%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    
  801026:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80102d:	8d 76 00             	lea    0x0(%esi),%esi
  801030:	89 f9                	mov    %edi,%ecx
  801032:	b8 20 00 00 00       	mov    $0x20,%eax
  801037:	29 f8                	sub    %edi,%eax
  801039:	d3 e2                	shl    %cl,%edx
  80103b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80103f:	89 c1                	mov    %eax,%ecx
  801041:	89 da                	mov    %ebx,%edx
  801043:	d3 ea                	shr    %cl,%edx
  801045:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801049:	09 d1                	or     %edx,%ecx
  80104b:	89 f2                	mov    %esi,%edx
  80104d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801051:	89 f9                	mov    %edi,%ecx
  801053:	d3 e3                	shl    %cl,%ebx
  801055:	89 c1                	mov    %eax,%ecx
  801057:	d3 ea                	shr    %cl,%edx
  801059:	89 f9                	mov    %edi,%ecx
  80105b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80105f:	89 eb                	mov    %ebp,%ebx
  801061:	d3 e6                	shl    %cl,%esi
  801063:	89 c1                	mov    %eax,%ecx
  801065:	d3 eb                	shr    %cl,%ebx
  801067:	09 de                	or     %ebx,%esi
  801069:	89 f0                	mov    %esi,%eax
  80106b:	f7 74 24 08          	divl   0x8(%esp)
  80106f:	89 d6                	mov    %edx,%esi
  801071:	89 c3                	mov    %eax,%ebx
  801073:	f7 64 24 0c          	mull   0xc(%esp)
  801077:	39 d6                	cmp    %edx,%esi
  801079:	72 15                	jb     801090 <__udivdi3+0x100>
  80107b:	89 f9                	mov    %edi,%ecx
  80107d:	d3 e5                	shl    %cl,%ebp
  80107f:	39 c5                	cmp    %eax,%ebp
  801081:	73 04                	jae    801087 <__udivdi3+0xf7>
  801083:	39 d6                	cmp    %edx,%esi
  801085:	74 09                	je     801090 <__udivdi3+0x100>
  801087:	89 d8                	mov    %ebx,%eax
  801089:	31 ff                	xor    %edi,%edi
  80108b:	e9 27 ff ff ff       	jmp    800fb7 <__udivdi3+0x27>
  801090:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801093:	31 ff                	xor    %edi,%edi
  801095:	e9 1d ff ff ff       	jmp    800fb7 <__udivdi3+0x27>
  80109a:	66 90                	xchg   %ax,%ax
  80109c:	66 90                	xchg   %ax,%ax
  80109e:	66 90                	xchg   %ax,%ax

008010a0 <__umoddi3>:
  8010a0:	55                   	push   %ebp
  8010a1:	57                   	push   %edi
  8010a2:	56                   	push   %esi
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 1c             	sub    $0x1c,%esp
  8010a7:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8010ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8010af:	8b 74 24 30          	mov    0x30(%esp),%esi
  8010b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8010b7:	89 da                	mov    %ebx,%edx
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	75 43                	jne    801100 <__umoddi3+0x60>
  8010bd:	39 df                	cmp    %ebx,%edi
  8010bf:	76 17                	jbe    8010d8 <__umoddi3+0x38>
  8010c1:	89 f0                	mov    %esi,%eax
  8010c3:	f7 f7                	div    %edi
  8010c5:	89 d0                	mov    %edx,%eax
  8010c7:	31 d2                	xor    %edx,%edx
  8010c9:	83 c4 1c             	add    $0x1c,%esp
  8010cc:	5b                   	pop    %ebx
  8010cd:	5e                   	pop    %esi
  8010ce:	5f                   	pop    %edi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    
  8010d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010d8:	89 fd                	mov    %edi,%ebp
  8010da:	85 ff                	test   %edi,%edi
  8010dc:	75 0b                	jne    8010e9 <__umoddi3+0x49>
  8010de:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e3:	31 d2                	xor    %edx,%edx
  8010e5:	f7 f7                	div    %edi
  8010e7:	89 c5                	mov    %eax,%ebp
  8010e9:	89 d8                	mov    %ebx,%eax
  8010eb:	31 d2                	xor    %edx,%edx
  8010ed:	f7 f5                	div    %ebp
  8010ef:	89 f0                	mov    %esi,%eax
  8010f1:	f7 f5                	div    %ebp
  8010f3:	89 d0                	mov    %edx,%eax
  8010f5:	eb d0                	jmp    8010c7 <__umoddi3+0x27>
  8010f7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010fe:	66 90                	xchg   %ax,%ax
  801100:	89 f1                	mov    %esi,%ecx
  801102:	39 d8                	cmp    %ebx,%eax
  801104:	76 0a                	jbe    801110 <__umoddi3+0x70>
  801106:	89 f0                	mov    %esi,%eax
  801108:	83 c4 1c             	add    $0x1c,%esp
  80110b:	5b                   	pop    %ebx
  80110c:	5e                   	pop    %esi
  80110d:	5f                   	pop    %edi
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    
  801110:	0f bd e8             	bsr    %eax,%ebp
  801113:	83 f5 1f             	xor    $0x1f,%ebp
  801116:	75 20                	jne    801138 <__umoddi3+0x98>
  801118:	39 d8                	cmp    %ebx,%eax
  80111a:	0f 82 b0 00 00 00    	jb     8011d0 <__umoddi3+0x130>
  801120:	39 f7                	cmp    %esi,%edi
  801122:	0f 86 a8 00 00 00    	jbe    8011d0 <__umoddi3+0x130>
  801128:	89 c8                	mov    %ecx,%eax
  80112a:	83 c4 1c             	add    $0x1c,%esp
  80112d:	5b                   	pop    %ebx
  80112e:	5e                   	pop    %esi
  80112f:	5f                   	pop    %edi
  801130:	5d                   	pop    %ebp
  801131:	c3                   	ret    
  801132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801138:	89 e9                	mov    %ebp,%ecx
  80113a:	ba 20 00 00 00       	mov    $0x20,%edx
  80113f:	29 ea                	sub    %ebp,%edx
  801141:	d3 e0                	shl    %cl,%eax
  801143:	89 44 24 08          	mov    %eax,0x8(%esp)
  801147:	89 d1                	mov    %edx,%ecx
  801149:	89 f8                	mov    %edi,%eax
  80114b:	d3 e8                	shr    %cl,%eax
  80114d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801151:	89 54 24 04          	mov    %edx,0x4(%esp)
  801155:	8b 54 24 04          	mov    0x4(%esp),%edx
  801159:	09 c1                	or     %eax,%ecx
  80115b:	89 d8                	mov    %ebx,%eax
  80115d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801161:	89 e9                	mov    %ebp,%ecx
  801163:	d3 e7                	shl    %cl,%edi
  801165:	89 d1                	mov    %edx,%ecx
  801167:	d3 e8                	shr    %cl,%eax
  801169:	89 e9                	mov    %ebp,%ecx
  80116b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80116f:	d3 e3                	shl    %cl,%ebx
  801171:	89 c7                	mov    %eax,%edi
  801173:	89 d1                	mov    %edx,%ecx
  801175:	89 f0                	mov    %esi,%eax
  801177:	d3 e8                	shr    %cl,%eax
  801179:	89 e9                	mov    %ebp,%ecx
  80117b:	89 fa                	mov    %edi,%edx
  80117d:	d3 e6                	shl    %cl,%esi
  80117f:	09 d8                	or     %ebx,%eax
  801181:	f7 74 24 08          	divl   0x8(%esp)
  801185:	89 d1                	mov    %edx,%ecx
  801187:	89 f3                	mov    %esi,%ebx
  801189:	f7 64 24 0c          	mull   0xc(%esp)
  80118d:	89 c6                	mov    %eax,%esi
  80118f:	89 d7                	mov    %edx,%edi
  801191:	39 d1                	cmp    %edx,%ecx
  801193:	72 06                	jb     80119b <__umoddi3+0xfb>
  801195:	75 10                	jne    8011a7 <__umoddi3+0x107>
  801197:	39 c3                	cmp    %eax,%ebx
  801199:	73 0c                	jae    8011a7 <__umoddi3+0x107>
  80119b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80119f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8011a3:	89 d7                	mov    %edx,%edi
  8011a5:	89 c6                	mov    %eax,%esi
  8011a7:	89 ca                	mov    %ecx,%edx
  8011a9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011ae:	29 f3                	sub    %esi,%ebx
  8011b0:	19 fa                	sbb    %edi,%edx
  8011b2:	89 d0                	mov    %edx,%eax
  8011b4:	d3 e0                	shl    %cl,%eax
  8011b6:	89 e9                	mov    %ebp,%ecx
  8011b8:	d3 eb                	shr    %cl,%ebx
  8011ba:	d3 ea                	shr    %cl,%edx
  8011bc:	09 d8                	or     %ebx,%eax
  8011be:	83 c4 1c             	add    $0x1c,%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    
  8011c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011cd:	8d 76 00             	lea    0x0(%esi),%esi
  8011d0:	89 da                	mov    %ebx,%edx
  8011d2:	29 fe                	sub    %edi,%esi
  8011d4:	19 c2                	sbb    %eax,%edx
  8011d6:	89 f1                	mov    %esi,%ecx
  8011d8:	89 c8                	mov    %ecx,%eax
  8011da:	e9 4b ff ff ff       	jmp    80112a <__umoddi3+0x8a>
