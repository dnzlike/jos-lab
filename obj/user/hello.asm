
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 60 11 80 00       	push   $0x801160
  80003e:	e8 08 01 00 00       	call   80014b <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 6e 11 80 00       	push   $0x80116e
  800054:	e8 f2 00 00 00       	call   80014b <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 27 0c 00 00       	call   800c95 <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 a3 0b 00 00       	call   800c54 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	53                   	push   %ebx
  8000ba:	83 ec 04             	sub    $0x4,%esp
  8000bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c0:	8b 13                	mov    (%ebx),%edx
  8000c2:	8d 42 01             	lea    0x1(%edx),%eax
  8000c5:	89 03                	mov    %eax,(%ebx)
  8000c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d3:	74 09                	je     8000de <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000d5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000de:	83 ec 08             	sub    $0x8,%esp
  8000e1:	68 ff 00 00 00       	push   $0xff
  8000e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e9:	50                   	push   %eax
  8000ea:	e8 28 0b 00 00       	call   800c17 <sys_cputs>
		b->idx = 0;
  8000ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	eb db                	jmp    8000d5 <putch+0x1f>

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	ff 75 0c             	pushl  0xc(%ebp)
  80011a:	ff 75 08             	pushl  0x8(%ebp)
  80011d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800123:	50                   	push   %eax
  800124:	68 b6 00 80 00       	push   $0x8000b6
  800129:	e8 fb 00 00 00       	call   800229 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012e:	83 c4 08             	add    $0x8,%esp
  800131:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800137:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	e8 d4 0a 00 00       	call   800c17 <sys_cputs>

	return b.cnt;
}
  800143:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800151:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800154:	50                   	push   %eax
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	e8 9d ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 1c             	sub    $0x1c,%esp
  800168:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80016b:	89 d3                	mov    %edx,%ebx
  80016d:	8b 75 08             	mov    0x8(%ebp),%esi
  800170:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800173:	8b 45 10             	mov    0x10(%ebp),%eax
  800176:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800179:	89 c2                	mov    %eax,%edx
  80017b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800180:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800183:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800186:	39 c6                	cmp    %eax,%esi
  800188:	89 f8                	mov    %edi,%eax
  80018a:	19 c8                	sbb    %ecx,%eax
  80018c:	73 32                	jae    8001c0 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  80018e:	83 ec 08             	sub    $0x8,%esp
  800191:	53                   	push   %ebx
  800192:	83 ec 04             	sub    $0x4,%esp
  800195:	ff 75 e4             	pushl  -0x1c(%ebp)
  800198:	ff 75 e0             	pushl  -0x20(%ebp)
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	e8 7e 0e 00 00       	call   801020 <__umoddi3>
  8001a2:	83 c4 14             	add    $0x14,%esp
  8001a5:	0f be 80 8f 11 80 00 	movsbl 0x80118f(%eax),%eax
  8001ac:	50                   	push   %eax
  8001ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b0:	ff d0                	call   *%eax
	return remain - 1;
  8001b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b5:	83 e8 01             	sub    $0x1,%eax
}
  8001b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bb:	5b                   	pop    %ebx
  8001bc:	5e                   	pop    %esi
  8001bd:	5f                   	pop    %edi
  8001be:	5d                   	pop    %ebp
  8001bf:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	ff 75 18             	pushl  0x18(%ebp)
  8001c6:	ff 75 14             	pushl  0x14(%ebp)
  8001c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	51                   	push   %ecx
  8001d0:	52                   	push   %edx
  8001d1:	57                   	push   %edi
  8001d2:	56                   	push   %esi
  8001d3:	e8 38 0d 00 00       	call   800f10 <__udivdi3>
  8001d8:	83 c4 18             	add    $0x18,%esp
  8001db:	52                   	push   %edx
  8001dc:	50                   	push   %eax
  8001dd:	89 da                	mov    %ebx,%edx
  8001df:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e2:	e8 78 ff ff ff       	call   80015f <printnum_helper>
  8001e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8001ea:	83 c4 20             	add    $0x20,%esp
  8001ed:	eb 9f                	jmp    80018e <printnum_helper+0x2f>

008001ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8001f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8001f9:	8b 10                	mov    (%eax),%edx
  8001fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8001fe:	73 0a                	jae    80020a <sprintputch+0x1b>
		*b->buf++ = ch;
  800200:	8d 4a 01             	lea    0x1(%edx),%ecx
  800203:	89 08                	mov    %ecx,(%eax)
  800205:	8b 45 08             	mov    0x8(%ebp),%eax
  800208:	88 02                	mov    %al,(%edx)
}
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <printfmt>:
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800212:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800215:	50                   	push   %eax
  800216:	ff 75 10             	pushl  0x10(%ebp)
  800219:	ff 75 0c             	pushl  0xc(%ebp)
  80021c:	ff 75 08             	pushl  0x8(%ebp)
  80021f:	e8 05 00 00 00       	call   800229 <vprintfmt>
}
  800224:	83 c4 10             	add    $0x10,%esp
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <vprintfmt>:
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 3c             	sub    $0x3c,%esp
  800232:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800235:	8b 75 0c             	mov    0xc(%ebp),%esi
  800238:	8b 7d 10             	mov    0x10(%ebp),%edi
  80023b:	e9 3f 05 00 00       	jmp    80077f <vprintfmt+0x556>
		padc = ' ';
  800240:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800244:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  80024b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800252:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800259:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  800260:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800267:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80026c:	8d 47 01             	lea    0x1(%edi),%eax
  80026f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800272:	0f b6 17             	movzbl (%edi),%edx
  800275:	8d 42 dd             	lea    -0x23(%edx),%eax
  800278:	3c 55                	cmp    $0x55,%al
  80027a:	0f 87 98 05 00 00    	ja     800818 <vprintfmt+0x5ef>
  800280:	0f b6 c0             	movzbl %al,%eax
  800283:	ff 24 85 e0 12 80 00 	jmp    *0x8012e0(,%eax,4)
  80028a:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  80028d:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  800291:	eb d9                	jmp    80026c <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800293:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800296:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  80029d:	eb cd                	jmp    80026c <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80029f:	0f b6 d2             	movzbl %dl,%edx
  8002a2:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8002aa:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  8002ad:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002b0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002b4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002b7:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8002ba:	83 fb 09             	cmp    $0x9,%ebx
  8002bd:	77 5c                	ja     80031b <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  8002bf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002c2:	eb e9                	jmp    8002ad <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  8002c4:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  8002c7:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  8002cb:	eb 9f                	jmp    80026c <vprintfmt+0x43>
			precision = va_arg(ap, int);
  8002cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d0:	8b 00                	mov    (%eax),%eax
  8002d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d8:	8d 40 04             	lea    0x4(%eax),%eax
  8002db:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002de:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8002e1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8002e5:	79 85                	jns    80026c <vprintfmt+0x43>
				width = precision, precision = -1;
  8002e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ed:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f4:	e9 73 ff ff ff       	jmp    80026c <vprintfmt+0x43>
  8002f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	0f 48 c1             	cmovs  %ecx,%eax
  800301:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800307:	e9 60 ff ff ff       	jmp    80026c <vprintfmt+0x43>
  80030c:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  80030f:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800316:	e9 51 ff ff ff       	jmp    80026c <vprintfmt+0x43>
  80031b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800321:	eb be                	jmp    8002e1 <vprintfmt+0xb8>
			lflag++;
  800323:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800327:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  80032a:	e9 3d ff ff ff       	jmp    80026c <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  80032f:	8b 45 14             	mov    0x14(%ebp),%eax
  800332:	8d 78 04             	lea    0x4(%eax),%edi
  800335:	83 ec 08             	sub    $0x8,%esp
  800338:	56                   	push   %esi
  800339:	ff 30                	pushl  (%eax)
  80033b:	ff d3                	call   *%ebx
			break;
  80033d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800340:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800343:	e9 34 04 00 00       	jmp    80077c <vprintfmt+0x553>
			err = va_arg(ap, int);
  800348:	8b 45 14             	mov    0x14(%ebp),%eax
  80034b:	8d 78 04             	lea    0x4(%eax),%edi
  80034e:	8b 00                	mov    (%eax),%eax
  800350:	99                   	cltd   
  800351:	31 d0                	xor    %edx,%eax
  800353:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800355:	83 f8 08             	cmp    $0x8,%eax
  800358:	7f 23                	jg     80037d <vprintfmt+0x154>
  80035a:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  800361:	85 d2                	test   %edx,%edx
  800363:	74 18                	je     80037d <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800365:	52                   	push   %edx
  800366:	68 b0 11 80 00       	push   $0x8011b0
  80036b:	56                   	push   %esi
  80036c:	53                   	push   %ebx
  80036d:	e8 9a fe ff ff       	call   80020c <printfmt>
  800372:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800375:	89 7d 14             	mov    %edi,0x14(%ebp)
  800378:	e9 ff 03 00 00       	jmp    80077c <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  80037d:	50                   	push   %eax
  80037e:	68 a7 11 80 00       	push   $0x8011a7
  800383:	56                   	push   %esi
  800384:	53                   	push   %ebx
  800385:	e8 82 fe ff ff       	call   80020c <printfmt>
  80038a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80038d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800390:	e9 e7 03 00 00       	jmp    80077c <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  800395:	8b 45 14             	mov    0x14(%ebp),%eax
  800398:	83 c0 04             	add    $0x4,%eax
  80039b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80039e:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a1:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8003a3:	85 c9                	test   %ecx,%ecx
  8003a5:	b8 a0 11 80 00       	mov    $0x8011a0,%eax
  8003aa:	0f 45 c1             	cmovne %ecx,%eax
  8003ad:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  8003b0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003b4:	7e 06                	jle    8003bc <vprintfmt+0x193>
  8003b6:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8003ba:	75 0d                	jne    8003c9 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003bc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003bf:	89 c7                	mov    %eax,%edi
  8003c1:	03 45 d8             	add    -0x28(%ebp),%eax
  8003c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c7:	eb 53                	jmp    80041c <vprintfmt+0x1f3>
  8003c9:	83 ec 08             	sub    $0x8,%esp
  8003cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8003cf:	50                   	push   %eax
  8003d0:	e8 eb 04 00 00       	call   8008c0 <strnlen>
  8003d5:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003d8:	29 c1                	sub    %eax,%ecx
  8003da:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8003dd:	83 c4 10             	add    $0x10,%esp
  8003e0:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8003e2:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8003e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e9:	eb 0f                	jmp    8003fa <vprintfmt+0x1d1>
					putch(padc, putdat);
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	56                   	push   %esi
  8003ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f2:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f4:	83 ef 01             	sub    $0x1,%edi
  8003f7:	83 c4 10             	add    $0x10,%esp
  8003fa:	85 ff                	test   %edi,%edi
  8003fc:	7f ed                	jg     8003eb <vprintfmt+0x1c2>
  8003fe:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800401:	85 c9                	test   %ecx,%ecx
  800403:	b8 00 00 00 00       	mov    $0x0,%eax
  800408:	0f 49 c1             	cmovns %ecx,%eax
  80040b:	29 c1                	sub    %eax,%ecx
  80040d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800410:	eb aa                	jmp    8003bc <vprintfmt+0x193>
					putch(ch, putdat);
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	56                   	push   %esi
  800416:	52                   	push   %edx
  800417:	ff d3                	call   *%ebx
  800419:	83 c4 10             	add    $0x10,%esp
  80041c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80041f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800421:	83 c7 01             	add    $0x1,%edi
  800424:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800428:	0f be d0             	movsbl %al,%edx
  80042b:	85 d2                	test   %edx,%edx
  80042d:	74 2e                	je     80045d <vprintfmt+0x234>
  80042f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800433:	78 06                	js     80043b <vprintfmt+0x212>
  800435:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800439:	78 1e                	js     800459 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  80043b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80043f:	74 d1                	je     800412 <vprintfmt+0x1e9>
  800441:	0f be c0             	movsbl %al,%eax
  800444:	83 e8 20             	sub    $0x20,%eax
  800447:	83 f8 5e             	cmp    $0x5e,%eax
  80044a:	76 c6                	jbe    800412 <vprintfmt+0x1e9>
					putch('?', putdat);
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	56                   	push   %esi
  800450:	6a 3f                	push   $0x3f
  800452:	ff d3                	call   *%ebx
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	eb c3                	jmp    80041c <vprintfmt+0x1f3>
  800459:	89 cf                	mov    %ecx,%edi
  80045b:	eb 02                	jmp    80045f <vprintfmt+0x236>
  80045d:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  80045f:	85 ff                	test   %edi,%edi
  800461:	7e 10                	jle    800473 <vprintfmt+0x24a>
				putch(' ', putdat);
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	56                   	push   %esi
  800467:	6a 20                	push   $0x20
  800469:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80046b:	83 ef 01             	sub    $0x1,%edi
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	eb ec                	jmp    80045f <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800473:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800476:	89 45 14             	mov    %eax,0x14(%ebp)
  800479:	e9 fe 02 00 00       	jmp    80077c <vprintfmt+0x553>
	if (lflag >= 2)
  80047e:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800482:	7f 21                	jg     8004a5 <vprintfmt+0x27c>
	else if (lflag)
  800484:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800488:	74 79                	je     800503 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8b 00                	mov    (%eax),%eax
  80048f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800492:	89 c1                	mov    %eax,%ecx
  800494:	c1 f9 1f             	sar    $0x1f,%ecx
  800497:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 40 04             	lea    0x4(%eax),%eax
  8004a0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a3:	eb 17                	jmp    8004bc <vprintfmt+0x293>
		return va_arg(*ap, long long);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8b 50 04             	mov    0x4(%eax),%edx
  8004ab:	8b 00                	mov    (%eax),%eax
  8004ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b6:	8d 40 08             	lea    0x8(%eax),%eax
  8004b9:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  8004bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004c5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  8004c8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004cc:	78 50                	js     80051e <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  8004ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004d1:	c1 fa 1f             	sar    $0x1f,%edx
  8004d4:	89 d0                	mov    %edx,%eax
  8004d6:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8004d9:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8004dc:	85 d2                	test   %edx,%edx
  8004de:	0f 89 14 02 00 00    	jns    8006f8 <vprintfmt+0x4cf>
  8004e4:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8004e8:	0f 84 0a 02 00 00    	je     8006f8 <vprintfmt+0x4cf>
				putch('+', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	56                   	push   %esi
  8004f2:	6a 2b                	push   $0x2b
  8004f4:	ff d3                	call   *%ebx
  8004f6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004fe:	e9 5c 01 00 00       	jmp    80065f <vprintfmt+0x436>
		return va_arg(*ap, int);
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8b 00                	mov    (%eax),%eax
  800508:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050b:	89 c1                	mov    %eax,%ecx
  80050d:	c1 f9 1f             	sar    $0x1f,%ecx
  800510:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8d 40 04             	lea    0x4(%eax),%eax
  800519:	89 45 14             	mov    %eax,0x14(%ebp)
  80051c:	eb 9e                	jmp    8004bc <vprintfmt+0x293>
				putch('-', putdat);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	56                   	push   %esi
  800522:	6a 2d                	push   $0x2d
  800524:	ff d3                	call   *%ebx
				num = -(long long) num;
  800526:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800529:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80052c:	f7 d8                	neg    %eax
  80052e:	83 d2 00             	adc    $0x0,%edx
  800531:	f7 da                	neg    %edx
  800533:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800536:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800539:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80053c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800541:	e9 19 01 00 00       	jmp    80065f <vprintfmt+0x436>
	if (lflag >= 2)
  800546:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80054a:	7f 29                	jg     800575 <vprintfmt+0x34c>
	else if (lflag)
  80054c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800550:	74 44                	je     800596 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8b 00                	mov    (%eax),%eax
  800557:	ba 00 00 00 00       	mov    $0x0,%edx
  80055c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80055f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800562:	8b 45 14             	mov    0x14(%ebp),%eax
  800565:	8d 40 04             	lea    0x4(%eax),%eax
  800568:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800570:	e9 ea 00 00 00       	jmp    80065f <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8b 50 04             	mov    0x4(%eax),%edx
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800580:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8d 40 08             	lea    0x8(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800591:	e9 c9 00 00 00       	jmp    80065f <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8b 00                	mov    (%eax),%eax
  80059b:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 40 04             	lea    0x4(%eax),%eax
  8005ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b4:	e9 a6 00 00 00       	jmp    80065f <vprintfmt+0x436>
			putch('0', putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	56                   	push   %esi
  8005bd:	6a 30                	push   $0x30
  8005bf:	ff d3                	call   *%ebx
	if (lflag >= 2)
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8005c8:	7f 26                	jg     8005f0 <vprintfmt+0x3c7>
	else if (lflag)
  8005ca:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8005ce:	74 3e                	je     80060e <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8005da:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005dd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 40 04             	lea    0x4(%eax),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005e9:	b8 08 00 00 00       	mov    $0x8,%eax
  8005ee:	eb 6f                	jmp    80065f <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8b 50 04             	mov    0x4(%eax),%edx
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005fb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8d 40 08             	lea    0x8(%eax),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800607:	b8 08 00 00 00       	mov    $0x8,%eax
  80060c:	eb 51                	jmp    80065f <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8b 00                	mov    (%eax),%eax
  800613:	ba 00 00 00 00       	mov    $0x0,%edx
  800618:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80061b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 40 04             	lea    0x4(%eax),%eax
  800624:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800627:	b8 08 00 00 00       	mov    $0x8,%eax
  80062c:	eb 31                	jmp    80065f <vprintfmt+0x436>
			putch('0', putdat);
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	56                   	push   %esi
  800632:	6a 30                	push   $0x30
  800634:	ff d3                	call   *%ebx
			putch('x', putdat);
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	56                   	push   %esi
  80063a:	6a 78                	push   $0x78
  80063c:	ff d3                	call   *%ebx
			num = (unsigned long long)
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8b 00                	mov    (%eax),%eax
  800643:	ba 00 00 00 00       	mov    $0x0,%edx
  800648:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80064b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  80064e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 40 04             	lea    0x4(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80065f:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800663:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800666:	89 c1                	mov    %eax,%ecx
  800668:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  80066b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80066e:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800673:	89 c2                	mov    %eax,%edx
  800675:	39 c1                	cmp    %eax,%ecx
  800677:	0f 87 85 00 00 00    	ja     800702 <vprintfmt+0x4d9>
		tmp /= base;
  80067d:	89 d0                	mov    %edx,%eax
  80067f:	ba 00 00 00 00       	mov    $0x0,%edx
  800684:	f7 f1                	div    %ecx
		len++;
  800686:	83 c7 01             	add    $0x1,%edi
  800689:	eb e8                	jmp    800673 <vprintfmt+0x44a>
	if (lflag >= 2)
  80068b:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80068f:	7f 26                	jg     8006b7 <vprintfmt+0x48e>
	else if (lflag)
  800691:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800695:	74 3e                	je     8006d5 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8b 00                	mov    (%eax),%eax
  80069c:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8d 40 04             	lea    0x4(%eax),%eax
  8006ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b0:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b5:	eb a8                	jmp    80065f <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8006b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ba:	8b 50 04             	mov    0x4(%eax),%edx
  8006bd:	8b 00                	mov    (%eax),%eax
  8006bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006c2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8d 40 08             	lea    0x8(%eax),%eax
  8006cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ce:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d3:	eb 8a                	jmp    80065f <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8b 00                	mov    (%eax),%eax
  8006da:	ba 00 00 00 00       	mov    $0x0,%edx
  8006df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8d 40 04             	lea    0x4(%eax),%eax
  8006eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ee:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f3:	e9 67 ff ff ff       	jmp    80065f <vprintfmt+0x436>
			base = 10;
  8006f8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fd:	e9 5d ff ff ff       	jmp    80065f <vprintfmt+0x436>
  800702:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  800705:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800708:	29 f8                	sub    %edi,%eax
  80070a:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  80070c:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  800710:	74 15                	je     800727 <vprintfmt+0x4fe>
		while (width > 0) {
  800712:	85 ff                	test   %edi,%edi
  800714:	7e 48                	jle    80075e <vprintfmt+0x535>
			putch(padc, putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	56                   	push   %esi
  80071a:	ff 75 e0             	pushl  -0x20(%ebp)
  80071d:	ff d3                	call   *%ebx
			width--;
  80071f:	83 ef 01             	sub    $0x1,%edi
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	eb eb                	jmp    800712 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800727:	83 ec 0c             	sub    $0xc,%esp
  80072a:	6a 2d                	push   $0x2d
  80072c:	ff 75 cc             	pushl  -0x34(%ebp)
  80072f:	ff 75 c8             	pushl  -0x38(%ebp)
  800732:	ff 75 d4             	pushl  -0x2c(%ebp)
  800735:	ff 75 d0             	pushl  -0x30(%ebp)
  800738:	89 f2                	mov    %esi,%edx
  80073a:	89 d8                	mov    %ebx,%eax
  80073c:	e8 1e fa ff ff       	call   80015f <printnum_helper>
		width -= len;
  800741:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800744:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800747:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  80074a:	85 ff                	test   %edi,%edi
  80074c:	7e 2e                	jle    80077c <vprintfmt+0x553>
			putch(padc, putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	56                   	push   %esi
  800752:	6a 20                	push   $0x20
  800754:	ff d3                	call   *%ebx
			width--;
  800756:	83 ef 01             	sub    $0x1,%edi
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	eb ec                	jmp    80074a <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  80075e:	83 ec 0c             	sub    $0xc,%esp
  800761:	ff 75 e0             	pushl  -0x20(%ebp)
  800764:	ff 75 cc             	pushl  -0x34(%ebp)
  800767:	ff 75 c8             	pushl  -0x38(%ebp)
  80076a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80076d:	ff 75 d0             	pushl  -0x30(%ebp)
  800770:	89 f2                	mov    %esi,%edx
  800772:	89 d8                	mov    %ebx,%eax
  800774:	e8 e6 f9 ff ff       	call   80015f <printnum_helper>
  800779:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  80077c:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80077f:	83 c7 01             	add    $0x1,%edi
  800782:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800786:	83 f8 25             	cmp    $0x25,%eax
  800789:	0f 84 b1 fa ff ff    	je     800240 <vprintfmt+0x17>
			if (ch == '\0')
  80078f:	85 c0                	test   %eax,%eax
  800791:	0f 84 a1 00 00 00    	je     800838 <vprintfmt+0x60f>
			putch(ch, putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	56                   	push   %esi
  80079b:	50                   	push   %eax
  80079c:	ff d3                	call   *%ebx
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	eb dc                	jmp    80077f <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	83 c0 04             	add    $0x4,%eax
  8007a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8007af:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8007b1:	85 ff                	test   %edi,%edi
  8007b3:	74 15                	je     8007ca <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  8007b5:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  8007bb:	7f 29                	jg     8007e6 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  8007bd:	0f b6 06             	movzbl (%esi),%eax
  8007c0:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  8007c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c8:	eb b2                	jmp    80077c <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8007ca:	68 48 12 80 00       	push   $0x801248
  8007cf:	68 b0 11 80 00       	push   $0x8011b0
  8007d4:	56                   	push   %esi
  8007d5:	53                   	push   %ebx
  8007d6:	e8 31 fa ff ff       	call   80020c <printfmt>
  8007db:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8007de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e4:	eb 96                	jmp    80077c <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  8007e6:	68 80 12 80 00       	push   $0x801280
  8007eb:	68 b0 11 80 00       	push   $0x8011b0
  8007f0:	56                   	push   %esi
  8007f1:	53                   	push   %ebx
  8007f2:	e8 15 fa ff ff       	call   80020c <printfmt>
				*res = -1;
  8007f7:	c6 07 ff             	movb   $0xff,(%edi)
  8007fa:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8007fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800800:	89 45 14             	mov    %eax,0x14(%ebp)
  800803:	e9 74 ff ff ff       	jmp    80077c <vprintfmt+0x553>
			putch(ch, putdat);
  800808:	83 ec 08             	sub    $0x8,%esp
  80080b:	56                   	push   %esi
  80080c:	6a 25                	push   $0x25
  80080e:	ff d3                	call   *%ebx
			break;
  800810:	83 c4 10             	add    $0x10,%esp
  800813:	e9 64 ff ff ff       	jmp    80077c <vprintfmt+0x553>
			putch('%', putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	56                   	push   %esi
  80081c:	6a 25                	push   $0x25
  80081e:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	89 f8                	mov    %edi,%eax
  800825:	eb 03                	jmp    80082a <vprintfmt+0x601>
  800827:	83 e8 01             	sub    $0x1,%eax
  80082a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80082e:	75 f7                	jne    800827 <vprintfmt+0x5fe>
  800830:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800833:	e9 44 ff ff ff       	jmp    80077c <vprintfmt+0x553>
}
  800838:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5f                   	pop    %edi
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	83 ec 18             	sub    $0x18,%esp
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800853:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800856:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085d:	85 c0                	test   %eax,%eax
  80085f:	74 26                	je     800887 <vsnprintf+0x47>
  800861:	85 d2                	test   %edx,%edx
  800863:	7e 22                	jle    800887 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800865:	ff 75 14             	pushl  0x14(%ebp)
  800868:	ff 75 10             	pushl  0x10(%ebp)
  80086b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086e:	50                   	push   %eax
  80086f:	68 ef 01 80 00       	push   $0x8001ef
  800874:	e8 b0 f9 ff ff       	call   800229 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800879:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 c4 10             	add    $0x10,%esp
}
  800885:	c9                   	leave  
  800886:	c3                   	ret    
		return -E_INVAL;
  800887:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088c:	eb f7                	jmp    800885 <vsnprintf+0x45>

0080088e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800894:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800897:	50                   	push   %eax
  800898:	ff 75 10             	pushl  0x10(%ebp)
  80089b:	ff 75 0c             	pushl  0xc(%ebp)
  80089e:	ff 75 08             	pushl  0x8(%ebp)
  8008a1:	e8 9a ff ff ff       	call   800840 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b7:	74 05                	je     8008be <strlen+0x16>
		n++;
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	eb f5                	jmp    8008b3 <strlen+0xb>
	return n;
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ce:	39 c2                	cmp    %eax,%edx
  8008d0:	74 0d                	je     8008df <strnlen+0x1f>
  8008d2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008d6:	74 05                	je     8008dd <strnlen+0x1d>
		n++;
  8008d8:	83 c2 01             	add    $0x1,%edx
  8008db:	eb f1                	jmp    8008ce <strnlen+0xe>
  8008dd:	89 d0                	mov    %edx,%eax
	return n;
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	53                   	push   %ebx
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008f4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008f7:	83 c2 01             	add    $0x1,%edx
  8008fa:	84 c9                	test   %cl,%cl
  8008fc:	75 f2                	jne    8008f0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008fe:	5b                   	pop    %ebx
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	53                   	push   %ebx
  800905:	83 ec 10             	sub    $0x10,%esp
  800908:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090b:	53                   	push   %ebx
  80090c:	e8 97 ff ff ff       	call   8008a8 <strlen>
  800911:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800914:	ff 75 0c             	pushl  0xc(%ebp)
  800917:	01 d8                	add    %ebx,%eax
  800919:	50                   	push   %eax
  80091a:	e8 c2 ff ff ff       	call   8008e1 <strcpy>
	return dst;
}
  80091f:	89 d8                	mov    %ebx,%eax
  800921:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800924:	c9                   	leave  
  800925:	c3                   	ret    

00800926 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800931:	89 c6                	mov    %eax,%esi
  800933:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800936:	89 c2                	mov    %eax,%edx
  800938:	39 f2                	cmp    %esi,%edx
  80093a:	74 11                	je     80094d <strncpy+0x27>
		*dst++ = *src;
  80093c:	83 c2 01             	add    $0x1,%edx
  80093f:	0f b6 19             	movzbl (%ecx),%ebx
  800942:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800945:	80 fb 01             	cmp    $0x1,%bl
  800948:	83 d9 ff             	sbb    $0xffffffff,%ecx
  80094b:	eb eb                	jmp    800938 <strncpy+0x12>
	}
	return ret;
}
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	56                   	push   %esi
  800955:	53                   	push   %ebx
  800956:	8b 75 08             	mov    0x8(%ebp),%esi
  800959:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095c:	8b 55 10             	mov    0x10(%ebp),%edx
  80095f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800961:	85 d2                	test   %edx,%edx
  800963:	74 21                	je     800986 <strlcpy+0x35>
  800965:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800969:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80096b:	39 c2                	cmp    %eax,%edx
  80096d:	74 14                	je     800983 <strlcpy+0x32>
  80096f:	0f b6 19             	movzbl (%ecx),%ebx
  800972:	84 db                	test   %bl,%bl
  800974:	74 0b                	je     800981 <strlcpy+0x30>
			*dst++ = *src++;
  800976:	83 c1 01             	add    $0x1,%ecx
  800979:	83 c2 01             	add    $0x1,%edx
  80097c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80097f:	eb ea                	jmp    80096b <strlcpy+0x1a>
  800981:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800983:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800986:	29 f0                	sub    %esi,%eax
}
  800988:	5b                   	pop    %ebx
  800989:	5e                   	pop    %esi
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800995:	0f b6 01             	movzbl (%ecx),%eax
  800998:	84 c0                	test   %al,%al
  80099a:	74 0c                	je     8009a8 <strcmp+0x1c>
  80099c:	3a 02                	cmp    (%edx),%al
  80099e:	75 08                	jne    8009a8 <strcmp+0x1c>
		p++, q++;
  8009a0:	83 c1 01             	add    $0x1,%ecx
  8009a3:	83 c2 01             	add    $0x1,%edx
  8009a6:	eb ed                	jmp    800995 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a8:	0f b6 c0             	movzbl %al,%eax
  8009ab:	0f b6 12             	movzbl (%edx),%edx
  8009ae:	29 d0                	sub    %edx,%eax
}
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	53                   	push   %ebx
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bc:	89 c3                	mov    %eax,%ebx
  8009be:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c1:	eb 06                	jmp    8009c9 <strncmp+0x17>
		n--, p++, q++;
  8009c3:	83 c0 01             	add    $0x1,%eax
  8009c6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009c9:	39 d8                	cmp    %ebx,%eax
  8009cb:	74 16                	je     8009e3 <strncmp+0x31>
  8009cd:	0f b6 08             	movzbl (%eax),%ecx
  8009d0:	84 c9                	test   %cl,%cl
  8009d2:	74 04                	je     8009d8 <strncmp+0x26>
  8009d4:	3a 0a                	cmp    (%edx),%cl
  8009d6:	74 eb                	je     8009c3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d8:	0f b6 00             	movzbl (%eax),%eax
  8009db:	0f b6 12             	movzbl (%edx),%edx
  8009de:	29 d0                	sub    %edx,%eax
}
  8009e0:	5b                   	pop    %ebx
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    
		return 0;
  8009e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e8:	eb f6                	jmp    8009e0 <strncmp+0x2e>

008009ea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f4:	0f b6 10             	movzbl (%eax),%edx
  8009f7:	84 d2                	test   %dl,%dl
  8009f9:	74 09                	je     800a04 <strchr+0x1a>
		if (*s == c)
  8009fb:	38 ca                	cmp    %cl,%dl
  8009fd:	74 0a                	je     800a09 <strchr+0x1f>
	for (; *s; s++)
  8009ff:	83 c0 01             	add    $0x1,%eax
  800a02:	eb f0                	jmp    8009f4 <strchr+0xa>
			return (char *) s;
	return 0;
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a15:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a18:	38 ca                	cmp    %cl,%dl
  800a1a:	74 09                	je     800a25 <strfind+0x1a>
  800a1c:	84 d2                	test   %dl,%dl
  800a1e:	74 05                	je     800a25 <strfind+0x1a>
	for (; *s; s++)
  800a20:	83 c0 01             	add    $0x1,%eax
  800a23:	eb f0                	jmp    800a15 <strfind+0xa>
			break;
	return (char *) s;
}
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	57                   	push   %edi
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a33:	85 c9                	test   %ecx,%ecx
  800a35:	74 31                	je     800a68 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a37:	89 f8                	mov    %edi,%eax
  800a39:	09 c8                	or     %ecx,%eax
  800a3b:	a8 03                	test   $0x3,%al
  800a3d:	75 23                	jne    800a62 <memset+0x3b>
		c &= 0xFF;
  800a3f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a43:	89 d3                	mov    %edx,%ebx
  800a45:	c1 e3 08             	shl    $0x8,%ebx
  800a48:	89 d0                	mov    %edx,%eax
  800a4a:	c1 e0 18             	shl    $0x18,%eax
  800a4d:	89 d6                	mov    %edx,%esi
  800a4f:	c1 e6 10             	shl    $0x10,%esi
  800a52:	09 f0                	or     %esi,%eax
  800a54:	09 c2                	or     %eax,%edx
  800a56:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a58:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a5b:	89 d0                	mov    %edx,%eax
  800a5d:	fc                   	cld    
  800a5e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a60:	eb 06                	jmp    800a68 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a65:	fc                   	cld    
  800a66:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a68:	89 f8                	mov    %edi,%eax
  800a6a:	5b                   	pop    %ebx
  800a6b:	5e                   	pop    %esi
  800a6c:	5f                   	pop    %edi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7d:	39 c6                	cmp    %eax,%esi
  800a7f:	73 32                	jae    800ab3 <memmove+0x44>
  800a81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a84:	39 c2                	cmp    %eax,%edx
  800a86:	76 2b                	jbe    800ab3 <memmove+0x44>
		s += n;
		d += n;
  800a88:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8b:	89 fe                	mov    %edi,%esi
  800a8d:	09 ce                	or     %ecx,%esi
  800a8f:	09 d6                	or     %edx,%esi
  800a91:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a97:	75 0e                	jne    800aa7 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a99:	83 ef 04             	sub    $0x4,%edi
  800a9c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aa2:	fd                   	std    
  800aa3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa5:	eb 09                	jmp    800ab0 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa7:	83 ef 01             	sub    $0x1,%edi
  800aaa:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aad:	fd                   	std    
  800aae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab0:	fc                   	cld    
  800ab1:	eb 1a                	jmp    800acd <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab3:	89 c2                	mov    %eax,%edx
  800ab5:	09 ca                	or     %ecx,%edx
  800ab7:	09 f2                	or     %esi,%edx
  800ab9:	f6 c2 03             	test   $0x3,%dl
  800abc:	75 0a                	jne    800ac8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800abe:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ac1:	89 c7                	mov    %eax,%edi
  800ac3:	fc                   	cld    
  800ac4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac6:	eb 05                	jmp    800acd <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ac8:	89 c7                	mov    %eax,%edi
  800aca:	fc                   	cld    
  800acb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad7:	ff 75 10             	pushl  0x10(%ebp)
  800ada:	ff 75 0c             	pushl  0xc(%ebp)
  800add:	ff 75 08             	pushl  0x8(%ebp)
  800ae0:	e8 8a ff ff ff       	call   800a6f <memmove>
}
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    

00800ae7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
  800aef:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af2:	89 c6                	mov    %eax,%esi
  800af4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af7:	39 f0                	cmp    %esi,%eax
  800af9:	74 1c                	je     800b17 <memcmp+0x30>
		if (*s1 != *s2)
  800afb:	0f b6 08             	movzbl (%eax),%ecx
  800afe:	0f b6 1a             	movzbl (%edx),%ebx
  800b01:	38 d9                	cmp    %bl,%cl
  800b03:	75 08                	jne    800b0d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b05:	83 c0 01             	add    $0x1,%eax
  800b08:	83 c2 01             	add    $0x1,%edx
  800b0b:	eb ea                	jmp    800af7 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b0d:	0f b6 c1             	movzbl %cl,%eax
  800b10:	0f b6 db             	movzbl %bl,%ebx
  800b13:	29 d8                	sub    %ebx,%eax
  800b15:	eb 05                	jmp    800b1c <memcmp+0x35>
	}

	return 0;
  800b17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b29:	89 c2                	mov    %eax,%edx
  800b2b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b2e:	39 d0                	cmp    %edx,%eax
  800b30:	73 09                	jae    800b3b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b32:	38 08                	cmp    %cl,(%eax)
  800b34:	74 05                	je     800b3b <memfind+0x1b>
	for (; s < ends; s++)
  800b36:	83 c0 01             	add    $0x1,%eax
  800b39:	eb f3                	jmp    800b2e <memfind+0xe>
			break;
	return (void *) s;
}
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b49:	eb 03                	jmp    800b4e <strtol+0x11>
		s++;
  800b4b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b4e:	0f b6 01             	movzbl (%ecx),%eax
  800b51:	3c 20                	cmp    $0x20,%al
  800b53:	74 f6                	je     800b4b <strtol+0xe>
  800b55:	3c 09                	cmp    $0x9,%al
  800b57:	74 f2                	je     800b4b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b59:	3c 2b                	cmp    $0x2b,%al
  800b5b:	74 2a                	je     800b87 <strtol+0x4a>
	int neg = 0;
  800b5d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b62:	3c 2d                	cmp    $0x2d,%al
  800b64:	74 2b                	je     800b91 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b66:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6c:	75 0f                	jne    800b7d <strtol+0x40>
  800b6e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b71:	74 28                	je     800b9b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b73:	85 db                	test   %ebx,%ebx
  800b75:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7a:	0f 44 d8             	cmove  %eax,%ebx
  800b7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b82:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b85:	eb 50                	jmp    800bd7 <strtol+0x9a>
		s++;
  800b87:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b8a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8f:	eb d5                	jmp    800b66 <strtol+0x29>
		s++, neg = 1;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	bf 01 00 00 00       	mov    $0x1,%edi
  800b99:	eb cb                	jmp    800b66 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b9f:	74 0e                	je     800baf <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ba1:	85 db                	test   %ebx,%ebx
  800ba3:	75 d8                	jne    800b7d <strtol+0x40>
		s++, base = 8;
  800ba5:	83 c1 01             	add    $0x1,%ecx
  800ba8:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bad:	eb ce                	jmp    800b7d <strtol+0x40>
		s += 2, base = 16;
  800baf:	83 c1 02             	add    $0x2,%ecx
  800bb2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb7:	eb c4                	jmp    800b7d <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bb9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bbc:	89 f3                	mov    %esi,%ebx
  800bbe:	80 fb 19             	cmp    $0x19,%bl
  800bc1:	77 29                	ja     800bec <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bc3:	0f be d2             	movsbl %dl,%edx
  800bc6:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bc9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bcc:	7d 30                	jge    800bfe <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bce:	83 c1 01             	add    $0x1,%ecx
  800bd1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bd7:	0f b6 11             	movzbl (%ecx),%edx
  800bda:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bdd:	89 f3                	mov    %esi,%ebx
  800bdf:	80 fb 09             	cmp    $0x9,%bl
  800be2:	77 d5                	ja     800bb9 <strtol+0x7c>
			dig = *s - '0';
  800be4:	0f be d2             	movsbl %dl,%edx
  800be7:	83 ea 30             	sub    $0x30,%edx
  800bea:	eb dd                	jmp    800bc9 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800bec:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bef:	89 f3                	mov    %esi,%ebx
  800bf1:	80 fb 19             	cmp    $0x19,%bl
  800bf4:	77 08                	ja     800bfe <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bf6:	0f be d2             	movsbl %dl,%edx
  800bf9:	83 ea 37             	sub    $0x37,%edx
  800bfc:	eb cb                	jmp    800bc9 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bfe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c02:	74 05                	je     800c09 <strtol+0xcc>
		*endptr = (char *) s;
  800c04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c07:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c09:	89 c2                	mov    %eax,%edx
  800c0b:	f7 da                	neg    %edx
  800c0d:	85 ff                	test   %edi,%edi
  800c0f:	0f 45 c2             	cmovne %edx,%eax
}
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c22:	8b 55 08             	mov    0x8(%ebp),%edx
  800c25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c28:	89 c3                	mov    %eax,%ebx
  800c2a:	89 c7                	mov    %eax,%edi
  800c2c:	89 c6                	mov    %eax,%esi
  800c2e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c40:	b8 01 00 00 00       	mov    $0x1,%eax
  800c45:	89 d1                	mov    %edx,%ecx
  800c47:	89 d3                	mov    %edx,%ebx
  800c49:	89 d7                	mov    %edx,%edi
  800c4b:	89 d6                	mov    %edx,%esi
  800c4d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    

00800c54 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	57                   	push   %edi
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c62:	8b 55 08             	mov    0x8(%ebp),%edx
  800c65:	b8 03 00 00 00       	mov    $0x3,%eax
  800c6a:	89 cb                	mov    %ecx,%ebx
  800c6c:	89 cf                	mov    %ecx,%edi
  800c6e:	89 ce                	mov    %ecx,%esi
  800c70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c72:	85 c0                	test   %eax,%eax
  800c74:	7f 08                	jg     800c7e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 03                	push   $0x3
  800c84:	68 64 14 80 00       	push   $0x801464
  800c89:	6a 23                	push   $0x23
  800c8b:	68 81 14 80 00       	push   $0x801481
  800c90:	e8 2e 02 00 00       	call   800ec3 <_panic>

00800c95 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ca5:	89 d1                	mov    %edx,%ecx
  800ca7:	89 d3                	mov    %edx,%ebx
  800ca9:	89 d7                	mov    %edx,%edi
  800cab:	89 d6                	mov    %edx,%esi
  800cad:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <sys_yield>:

void
sys_yield(void)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cba:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc4:	89 d1                	mov    %edx,%ecx
  800cc6:	89 d3                	mov    %edx,%ebx
  800cc8:	89 d7                	mov    %edx,%edi
  800cca:	89 d6                	mov    %edx,%esi
  800ccc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdc:	be 00 00 00 00       	mov    $0x0,%esi
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cef:	89 f7                	mov    %esi,%edi
  800cf1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	7f 08                	jg     800cff <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cff:	83 ec 0c             	sub    $0xc,%esp
  800d02:	50                   	push   %eax
  800d03:	6a 04                	push   $0x4
  800d05:	68 64 14 80 00       	push   $0x801464
  800d0a:	6a 23                	push   $0x23
  800d0c:	68 81 14 80 00       	push   $0x801481
  800d11:	e8 ad 01 00 00       	call   800ec3 <_panic>

00800d16 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
  800d1c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d25:	b8 05 00 00 00       	mov    $0x5,%eax
  800d2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d30:	8b 75 18             	mov    0x18(%ebp),%esi
  800d33:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d35:	85 c0                	test   %eax,%eax
  800d37:	7f 08                	jg     800d41 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d41:	83 ec 0c             	sub    $0xc,%esp
  800d44:	50                   	push   %eax
  800d45:	6a 05                	push   $0x5
  800d47:	68 64 14 80 00       	push   $0x801464
  800d4c:	6a 23                	push   $0x23
  800d4e:	68 81 14 80 00       	push   $0x801481
  800d53:	e8 6b 01 00 00       	call   800ec3 <_panic>

00800d58 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	57                   	push   %edi
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
  800d5e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d61:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d71:	89 df                	mov    %ebx,%edi
  800d73:	89 de                	mov    %ebx,%esi
  800d75:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d77:	85 c0                	test   %eax,%eax
  800d79:	7f 08                	jg     800d83 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d83:	83 ec 0c             	sub    $0xc,%esp
  800d86:	50                   	push   %eax
  800d87:	6a 06                	push   $0x6
  800d89:	68 64 14 80 00       	push   $0x801464
  800d8e:	6a 23                	push   $0x23
  800d90:	68 81 14 80 00       	push   $0x801481
  800d95:	e8 29 01 00 00       	call   800ec3 <_panic>

00800d9a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dae:	b8 08 00 00 00       	mov    $0x8,%eax
  800db3:	89 df                	mov    %ebx,%edi
  800db5:	89 de                	mov    %ebx,%esi
  800db7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7f 08                	jg     800dc5 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc5:	83 ec 0c             	sub    $0xc,%esp
  800dc8:	50                   	push   %eax
  800dc9:	6a 08                	push   $0x8
  800dcb:	68 64 14 80 00       	push   $0x801464
  800dd0:	6a 23                	push   $0x23
  800dd2:	68 81 14 80 00       	push   $0x801481
  800dd7:	e8 e7 00 00 00       	call   800ec3 <_panic>

00800ddc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	57                   	push   %edi
  800de0:	56                   	push   %esi
  800de1:	53                   	push   %ebx
  800de2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	b8 09 00 00 00       	mov    $0x9,%eax
  800df5:	89 df                	mov    %ebx,%edi
  800df7:	89 de                	mov    %ebx,%esi
  800df9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	7f 08                	jg     800e07 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e02:	5b                   	pop    %ebx
  800e03:	5e                   	pop    %esi
  800e04:	5f                   	pop    %edi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e07:	83 ec 0c             	sub    $0xc,%esp
  800e0a:	50                   	push   %eax
  800e0b:	6a 09                	push   $0x9
  800e0d:	68 64 14 80 00       	push   $0x801464
  800e12:	6a 23                	push   $0x23
  800e14:	68 81 14 80 00       	push   $0x801481
  800e19:	e8 a5 00 00 00       	call   800ec3 <_panic>

00800e1e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e2f:	be 00 00 00 00       	mov    $0x0,%esi
  800e34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e37:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
  800e45:	56                   	push   %esi
  800e46:	53                   	push   %ebx
  800e47:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e4a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e52:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e57:	89 cb                	mov    %ecx,%ebx
  800e59:	89 cf                	mov    %ecx,%edi
  800e5b:	89 ce                	mov    %ecx,%esi
  800e5d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	7f 08                	jg     800e6b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e66:	5b                   	pop    %ebx
  800e67:	5e                   	pop    %esi
  800e68:	5f                   	pop    %edi
  800e69:	5d                   	pop    %ebp
  800e6a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6b:	83 ec 0c             	sub    $0xc,%esp
  800e6e:	50                   	push   %eax
  800e6f:	6a 0c                	push   $0xc
  800e71:	68 64 14 80 00       	push   $0x801464
  800e76:	6a 23                	push   $0x23
  800e78:	68 81 14 80 00       	push   $0x801481
  800e7d:	e8 41 00 00 00       	call   800ec3 <_panic>

00800e82 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e93:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e98:	89 df                	mov    %ebx,%edi
  800e9a:	89 de                	mov    %ebx,%esi
  800e9c:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ea9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eae:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800eb6:	89 cb                	mov    %ecx,%ebx
  800eb8:	89 cf                	mov    %ecx,%edi
  800eba:	89 ce                	mov    %ecx,%esi
  800ebc:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ec8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ecb:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ed1:	e8 bf fd ff ff       	call   800c95 <sys_getenvid>
  800ed6:	83 ec 0c             	sub    $0xc,%esp
  800ed9:	ff 75 0c             	pushl  0xc(%ebp)
  800edc:	ff 75 08             	pushl  0x8(%ebp)
  800edf:	56                   	push   %esi
  800ee0:	50                   	push   %eax
  800ee1:	68 90 14 80 00       	push   $0x801490
  800ee6:	e8 60 f2 ff ff       	call   80014b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800eeb:	83 c4 18             	add    $0x18,%esp
  800eee:	53                   	push   %ebx
  800eef:	ff 75 10             	pushl  0x10(%ebp)
  800ef2:	e8 03 f2 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  800ef7:	c7 04 24 6c 11 80 00 	movl   $0x80116c,(%esp)
  800efe:	e8 48 f2 ff ff       	call   80014b <cprintf>
  800f03:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f06:	cc                   	int3   
  800f07:	eb fd                	jmp    800f06 <_panic+0x43>
  800f09:	66 90                	xchg   %ax,%ax
  800f0b:	66 90                	xchg   %ax,%ax
  800f0d:	66 90                	xchg   %ax,%ax
  800f0f:	90                   	nop

00800f10 <__udivdi3>:
  800f10:	55                   	push   %ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	83 ec 1c             	sub    $0x1c,%esp
  800f17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f1b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f23:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f27:	85 d2                	test   %edx,%edx
  800f29:	75 4d                	jne    800f78 <__udivdi3+0x68>
  800f2b:	39 f3                	cmp    %esi,%ebx
  800f2d:	76 19                	jbe    800f48 <__udivdi3+0x38>
  800f2f:	31 ff                	xor    %edi,%edi
  800f31:	89 e8                	mov    %ebp,%eax
  800f33:	89 f2                	mov    %esi,%edx
  800f35:	f7 f3                	div    %ebx
  800f37:	89 fa                	mov    %edi,%edx
  800f39:	83 c4 1c             	add    $0x1c,%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    
  800f41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f48:	89 d9                	mov    %ebx,%ecx
  800f4a:	85 db                	test   %ebx,%ebx
  800f4c:	75 0b                	jne    800f59 <__udivdi3+0x49>
  800f4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	f7 f3                	div    %ebx
  800f57:	89 c1                	mov    %eax,%ecx
  800f59:	31 d2                	xor    %edx,%edx
  800f5b:	89 f0                	mov    %esi,%eax
  800f5d:	f7 f1                	div    %ecx
  800f5f:	89 c6                	mov    %eax,%esi
  800f61:	89 e8                	mov    %ebp,%eax
  800f63:	89 f7                	mov    %esi,%edi
  800f65:	f7 f1                	div    %ecx
  800f67:	89 fa                	mov    %edi,%edx
  800f69:	83 c4 1c             	add    $0x1c,%esp
  800f6c:	5b                   	pop    %ebx
  800f6d:	5e                   	pop    %esi
  800f6e:	5f                   	pop    %edi
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    
  800f71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f78:	39 f2                	cmp    %esi,%edx
  800f7a:	77 1c                	ja     800f98 <__udivdi3+0x88>
  800f7c:	0f bd fa             	bsr    %edx,%edi
  800f7f:	83 f7 1f             	xor    $0x1f,%edi
  800f82:	75 2c                	jne    800fb0 <__udivdi3+0xa0>
  800f84:	39 f2                	cmp    %esi,%edx
  800f86:	72 06                	jb     800f8e <__udivdi3+0x7e>
  800f88:	31 c0                	xor    %eax,%eax
  800f8a:	39 eb                	cmp    %ebp,%ebx
  800f8c:	77 a9                	ja     800f37 <__udivdi3+0x27>
  800f8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f93:	eb a2                	jmp    800f37 <__udivdi3+0x27>
  800f95:	8d 76 00             	lea    0x0(%esi),%esi
  800f98:	31 ff                	xor    %edi,%edi
  800f9a:	31 c0                	xor    %eax,%eax
  800f9c:	89 fa                	mov    %edi,%edx
  800f9e:	83 c4 1c             	add    $0x1c,%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    
  800fa6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fad:	8d 76 00             	lea    0x0(%esi),%esi
  800fb0:	89 f9                	mov    %edi,%ecx
  800fb2:	b8 20 00 00 00       	mov    $0x20,%eax
  800fb7:	29 f8                	sub    %edi,%eax
  800fb9:	d3 e2                	shl    %cl,%edx
  800fbb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fbf:	89 c1                	mov    %eax,%ecx
  800fc1:	89 da                	mov    %ebx,%edx
  800fc3:	d3 ea                	shr    %cl,%edx
  800fc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fc9:	09 d1                	or     %edx,%ecx
  800fcb:	89 f2                	mov    %esi,%edx
  800fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd1:	89 f9                	mov    %edi,%ecx
  800fd3:	d3 e3                	shl    %cl,%ebx
  800fd5:	89 c1                	mov    %eax,%ecx
  800fd7:	d3 ea                	shr    %cl,%edx
  800fd9:	89 f9                	mov    %edi,%ecx
  800fdb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fdf:	89 eb                	mov    %ebp,%ebx
  800fe1:	d3 e6                	shl    %cl,%esi
  800fe3:	89 c1                	mov    %eax,%ecx
  800fe5:	d3 eb                	shr    %cl,%ebx
  800fe7:	09 de                	or     %ebx,%esi
  800fe9:	89 f0                	mov    %esi,%eax
  800feb:	f7 74 24 08          	divl   0x8(%esp)
  800fef:	89 d6                	mov    %edx,%esi
  800ff1:	89 c3                	mov    %eax,%ebx
  800ff3:	f7 64 24 0c          	mull   0xc(%esp)
  800ff7:	39 d6                	cmp    %edx,%esi
  800ff9:	72 15                	jb     801010 <__udivdi3+0x100>
  800ffb:	89 f9                	mov    %edi,%ecx
  800ffd:	d3 e5                	shl    %cl,%ebp
  800fff:	39 c5                	cmp    %eax,%ebp
  801001:	73 04                	jae    801007 <__udivdi3+0xf7>
  801003:	39 d6                	cmp    %edx,%esi
  801005:	74 09                	je     801010 <__udivdi3+0x100>
  801007:	89 d8                	mov    %ebx,%eax
  801009:	31 ff                	xor    %edi,%edi
  80100b:	e9 27 ff ff ff       	jmp    800f37 <__udivdi3+0x27>
  801010:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801013:	31 ff                	xor    %edi,%edi
  801015:	e9 1d ff ff ff       	jmp    800f37 <__udivdi3+0x27>
  80101a:	66 90                	xchg   %ax,%ax
  80101c:	66 90                	xchg   %ax,%ax
  80101e:	66 90                	xchg   %ax,%ax

00801020 <__umoddi3>:
  801020:	55                   	push   %ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
  801024:	83 ec 1c             	sub    $0x1c,%esp
  801027:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80102b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80102f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801033:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801037:	89 da                	mov    %ebx,%edx
  801039:	85 c0                	test   %eax,%eax
  80103b:	75 43                	jne    801080 <__umoddi3+0x60>
  80103d:	39 df                	cmp    %ebx,%edi
  80103f:	76 17                	jbe    801058 <__umoddi3+0x38>
  801041:	89 f0                	mov    %esi,%eax
  801043:	f7 f7                	div    %edi
  801045:	89 d0                	mov    %edx,%eax
  801047:	31 d2                	xor    %edx,%edx
  801049:	83 c4 1c             	add    $0x1c,%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    
  801051:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801058:	89 fd                	mov    %edi,%ebp
  80105a:	85 ff                	test   %edi,%edi
  80105c:	75 0b                	jne    801069 <__umoddi3+0x49>
  80105e:	b8 01 00 00 00       	mov    $0x1,%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	f7 f7                	div    %edi
  801067:	89 c5                	mov    %eax,%ebp
  801069:	89 d8                	mov    %ebx,%eax
  80106b:	31 d2                	xor    %edx,%edx
  80106d:	f7 f5                	div    %ebp
  80106f:	89 f0                	mov    %esi,%eax
  801071:	f7 f5                	div    %ebp
  801073:	89 d0                	mov    %edx,%eax
  801075:	eb d0                	jmp    801047 <__umoddi3+0x27>
  801077:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80107e:	66 90                	xchg   %ax,%ax
  801080:	89 f1                	mov    %esi,%ecx
  801082:	39 d8                	cmp    %ebx,%eax
  801084:	76 0a                	jbe    801090 <__umoddi3+0x70>
  801086:	89 f0                	mov    %esi,%eax
  801088:	83 c4 1c             	add    $0x1c,%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    
  801090:	0f bd e8             	bsr    %eax,%ebp
  801093:	83 f5 1f             	xor    $0x1f,%ebp
  801096:	75 20                	jne    8010b8 <__umoddi3+0x98>
  801098:	39 d8                	cmp    %ebx,%eax
  80109a:	0f 82 b0 00 00 00    	jb     801150 <__umoddi3+0x130>
  8010a0:	39 f7                	cmp    %esi,%edi
  8010a2:	0f 86 a8 00 00 00    	jbe    801150 <__umoddi3+0x130>
  8010a8:	89 c8                	mov    %ecx,%eax
  8010aa:	83 c4 1c             	add    $0x1c,%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    
  8010b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010b8:	89 e9                	mov    %ebp,%ecx
  8010ba:	ba 20 00 00 00       	mov    $0x20,%edx
  8010bf:	29 ea                	sub    %ebp,%edx
  8010c1:	d3 e0                	shl    %cl,%eax
  8010c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c7:	89 d1                	mov    %edx,%ecx
  8010c9:	89 f8                	mov    %edi,%eax
  8010cb:	d3 e8                	shr    %cl,%eax
  8010cd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010d5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010d9:	09 c1                	or     %eax,%ecx
  8010db:	89 d8                	mov    %ebx,%eax
  8010dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010e1:	89 e9                	mov    %ebp,%ecx
  8010e3:	d3 e7                	shl    %cl,%edi
  8010e5:	89 d1                	mov    %edx,%ecx
  8010e7:	d3 e8                	shr    %cl,%eax
  8010e9:	89 e9                	mov    %ebp,%ecx
  8010eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010ef:	d3 e3                	shl    %cl,%ebx
  8010f1:	89 c7                	mov    %eax,%edi
  8010f3:	89 d1                	mov    %edx,%ecx
  8010f5:	89 f0                	mov    %esi,%eax
  8010f7:	d3 e8                	shr    %cl,%eax
  8010f9:	89 e9                	mov    %ebp,%ecx
  8010fb:	89 fa                	mov    %edi,%edx
  8010fd:	d3 e6                	shl    %cl,%esi
  8010ff:	09 d8                	or     %ebx,%eax
  801101:	f7 74 24 08          	divl   0x8(%esp)
  801105:	89 d1                	mov    %edx,%ecx
  801107:	89 f3                	mov    %esi,%ebx
  801109:	f7 64 24 0c          	mull   0xc(%esp)
  80110d:	89 c6                	mov    %eax,%esi
  80110f:	89 d7                	mov    %edx,%edi
  801111:	39 d1                	cmp    %edx,%ecx
  801113:	72 06                	jb     80111b <__umoddi3+0xfb>
  801115:	75 10                	jne    801127 <__umoddi3+0x107>
  801117:	39 c3                	cmp    %eax,%ebx
  801119:	73 0c                	jae    801127 <__umoddi3+0x107>
  80111b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80111f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801123:	89 d7                	mov    %edx,%edi
  801125:	89 c6                	mov    %eax,%esi
  801127:	89 ca                	mov    %ecx,%edx
  801129:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80112e:	29 f3                	sub    %esi,%ebx
  801130:	19 fa                	sbb    %edi,%edx
  801132:	89 d0                	mov    %edx,%eax
  801134:	d3 e0                	shl    %cl,%eax
  801136:	89 e9                	mov    %ebp,%ecx
  801138:	d3 eb                	shr    %cl,%ebx
  80113a:	d3 ea                	shr    %cl,%edx
  80113c:	09 d8                	or     %ebx,%eax
  80113e:	83 c4 1c             	add    $0x1c,%esp
  801141:	5b                   	pop    %ebx
  801142:	5e                   	pop    %esi
  801143:	5f                   	pop    %edi
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    
  801146:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80114d:	8d 76 00             	lea    0x0(%esi),%esi
  801150:	89 da                	mov    %ebx,%edx
  801152:	29 fe                	sub    %edi,%esi
  801154:	19 c2                	sbb    %eax,%edx
  801156:	89 f1                	mov    %esi,%ecx
  801158:	89 c8                	mov    %ecx,%eax
  80115a:	e9 4b ff ff ff       	jmp    8010aa <__umoddi3+0x8a>
