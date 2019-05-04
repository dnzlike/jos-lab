
obj/user/faultread:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  800039:	ff 35 00 00 00 00    	pushl  0x0
  80003f:	68 60 11 80 00       	push   $0x801160
  800044:	e8 f2 00 00 00       	call   80013b <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 27 0c 00 00       	call   800c85 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 a3 0b 00 00       	call   800c44 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b0:	8b 13                	mov    (%ebx),%edx
  8000b2:	8d 42 01             	lea    0x1(%edx),%eax
  8000b5:	89 03                	mov    %eax,(%ebx)
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c3:	74 09                	je     8000ce <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000c5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000cc:	c9                   	leave  
  8000cd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	68 ff 00 00 00       	push   $0xff
  8000d6:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d9:	50                   	push   %eax
  8000da:	e8 28 0b 00 00       	call   800c07 <sys_cputs>
		b->idx = 0;
  8000df:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	eb db                	jmp    8000c5 <putch+0x1f>

008000ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fa:	00 00 00 
	b.cnt = 0;
  8000fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800104:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800107:	ff 75 0c             	pushl  0xc(%ebp)
  80010a:	ff 75 08             	pushl  0x8(%ebp)
  80010d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800113:	50                   	push   %eax
  800114:	68 a6 00 80 00       	push   $0x8000a6
  800119:	e8 fb 00 00 00       	call   800219 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011e:	83 c4 08             	add    $0x8,%esp
  800121:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800127:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	e8 d4 0a 00 00       	call   800c07 <sys_cputs>

	return b.cnt;
}
  800133:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800141:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800144:	50                   	push   %eax
  800145:	ff 75 08             	pushl  0x8(%ebp)
  800148:	e8 9d ff ff ff       	call   8000ea <vcprintf>
	va_end(ap);

	return cnt;
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 1c             	sub    $0x1c,%esp
  800158:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	8b 75 08             	mov    0x8(%ebp),%esi
  800160:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800163:	8b 45 10             	mov    0x10(%ebp),%eax
  800166:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800169:	89 c2                	mov    %eax,%edx
  80016b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800170:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800173:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800176:	39 c6                	cmp    %eax,%esi
  800178:	89 f8                	mov    %edi,%eax
  80017a:	19 c8                	sbb    %ecx,%eax
  80017c:	73 32                	jae    8001b0 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  80017e:	83 ec 08             	sub    $0x8,%esp
  800181:	53                   	push   %ebx
  800182:	83 ec 04             	sub    $0x4,%esp
  800185:	ff 75 e4             	pushl  -0x1c(%ebp)
  800188:	ff 75 e0             	pushl  -0x20(%ebp)
  80018b:	57                   	push   %edi
  80018c:	56                   	push   %esi
  80018d:	e8 7e 0e 00 00       	call   801010 <__umoddi3>
  800192:	83 c4 14             	add    $0x14,%esp
  800195:	0f be 80 88 11 80 00 	movsbl 0x801188(%eax),%eax
  80019c:	50                   	push   %eax
  80019d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001a0:	ff d0                	call   *%eax
	return remain - 1;
  8001a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a5:	83 e8 01             	sub    $0x1,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  8001b0:	83 ec 0c             	sub    $0xc,%esp
  8001b3:	ff 75 18             	pushl  0x18(%ebp)
  8001b6:	ff 75 14             	pushl  0x14(%ebp)
  8001b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	51                   	push   %ecx
  8001c0:	52                   	push   %edx
  8001c1:	57                   	push   %edi
  8001c2:	56                   	push   %esi
  8001c3:	e8 38 0d 00 00       	call   800f00 <__udivdi3>
  8001c8:	83 c4 18             	add    $0x18,%esp
  8001cb:	52                   	push   %edx
  8001cc:	50                   	push   %eax
  8001cd:	89 da                	mov    %ebx,%edx
  8001cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d2:	e8 78 ff ff ff       	call   80014f <printnum_helper>
  8001d7:	89 45 14             	mov    %eax,0x14(%ebp)
  8001da:	83 c4 20             	add    $0x20,%esp
  8001dd:	eb 9f                	jmp    80017e <printnum_helper+0x2f>

008001df <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8001e5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8001e9:	8b 10                	mov    (%eax),%edx
  8001eb:	3b 50 04             	cmp    0x4(%eax),%edx
  8001ee:	73 0a                	jae    8001fa <sprintputch+0x1b>
		*b->buf++ = ch;
  8001f0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8001f3:	89 08                	mov    %ecx,(%eax)
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	88 02                	mov    %al,(%edx)
}
  8001fa:	5d                   	pop    %ebp
  8001fb:	c3                   	ret    

008001fc <printfmt>:
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800202:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800205:	50                   	push   %eax
  800206:	ff 75 10             	pushl  0x10(%ebp)
  800209:	ff 75 0c             	pushl  0xc(%ebp)
  80020c:	ff 75 08             	pushl  0x8(%ebp)
  80020f:	e8 05 00 00 00       	call   800219 <vprintfmt>
}
  800214:	83 c4 10             	add    $0x10,%esp
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <vprintfmt>:
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 3c             	sub    $0x3c,%esp
  800222:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800225:	8b 75 0c             	mov    0xc(%ebp),%esi
  800228:	8b 7d 10             	mov    0x10(%ebp),%edi
  80022b:	e9 3f 05 00 00       	jmp    80076f <vprintfmt+0x556>
		padc = ' ';
  800230:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800234:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  80023b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800242:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800249:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  800250:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800257:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80025c:	8d 47 01             	lea    0x1(%edi),%eax
  80025f:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800262:	0f b6 17             	movzbl (%edi),%edx
  800265:	8d 42 dd             	lea    -0x23(%edx),%eax
  800268:	3c 55                	cmp    $0x55,%al
  80026a:	0f 87 98 05 00 00    	ja     800808 <vprintfmt+0x5ef>
  800270:	0f b6 c0             	movzbl %al,%eax
  800273:	ff 24 85 c0 12 80 00 	jmp    *0x8012c0(,%eax,4)
  80027a:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  80027d:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  800281:	eb d9                	jmp    80025c <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800283:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800286:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  80028d:	eb cd                	jmp    80025c <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80028f:	0f b6 d2             	movzbl %dl,%edx
  800292:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800295:	b8 00 00 00 00       	mov    $0x0,%eax
  80029a:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  80029d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002a0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002a4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002a7:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8002aa:	83 fb 09             	cmp    $0x9,%ebx
  8002ad:	77 5c                	ja     80030b <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  8002af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002b2:	eb e9                	jmp    80029d <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  8002b4:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  8002b7:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  8002bb:	eb 9f                	jmp    80025c <vprintfmt+0x43>
			precision = va_arg(ap, int);
  8002bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c0:	8b 00                	mov    (%eax),%eax
  8002c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c8:	8d 40 04             	lea    0x4(%eax),%eax
  8002cb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002ce:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8002d1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8002d5:	79 85                	jns    80025c <vprintfmt+0x43>
				width = precision, precision = -1;
  8002d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002dd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002e4:	e9 73 ff ff ff       	jmp    80025c <vprintfmt+0x43>
  8002e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	0f 48 c1             	cmovs  %ecx,%eax
  8002f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002f4:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8002f7:	e9 60 ff ff ff       	jmp    80025c <vprintfmt+0x43>
  8002fc:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8002ff:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800306:	e9 51 ff ff ff       	jmp    80025c <vprintfmt+0x43>
  80030b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80030e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800311:	eb be                	jmp    8002d1 <vprintfmt+0xb8>
			lflag++;
  800313:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800317:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  80031a:	e9 3d ff ff ff       	jmp    80025c <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  80031f:	8b 45 14             	mov    0x14(%ebp),%eax
  800322:	8d 78 04             	lea    0x4(%eax),%edi
  800325:	83 ec 08             	sub    $0x8,%esp
  800328:	56                   	push   %esi
  800329:	ff 30                	pushl  (%eax)
  80032b:	ff d3                	call   *%ebx
			break;
  80032d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800330:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800333:	e9 34 04 00 00       	jmp    80076c <vprintfmt+0x553>
			err = va_arg(ap, int);
  800338:	8b 45 14             	mov    0x14(%ebp),%eax
  80033b:	8d 78 04             	lea    0x4(%eax),%edi
  80033e:	8b 00                	mov    (%eax),%eax
  800340:	99                   	cltd   
  800341:	31 d0                	xor    %edx,%eax
  800343:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800345:	83 f8 08             	cmp    $0x8,%eax
  800348:	7f 23                	jg     80036d <vprintfmt+0x154>
  80034a:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  800351:	85 d2                	test   %edx,%edx
  800353:	74 18                	je     80036d <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800355:	52                   	push   %edx
  800356:	68 a9 11 80 00       	push   $0x8011a9
  80035b:	56                   	push   %esi
  80035c:	53                   	push   %ebx
  80035d:	e8 9a fe ff ff       	call   8001fc <printfmt>
  800362:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800365:	89 7d 14             	mov    %edi,0x14(%ebp)
  800368:	e9 ff 03 00 00       	jmp    80076c <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  80036d:	50                   	push   %eax
  80036e:	68 a0 11 80 00       	push   $0x8011a0
  800373:	56                   	push   %esi
  800374:	53                   	push   %ebx
  800375:	e8 82 fe ff ff       	call   8001fc <printfmt>
  80037a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80037d:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800380:	e9 e7 03 00 00       	jmp    80076c <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  800385:	8b 45 14             	mov    0x14(%ebp),%eax
  800388:	83 c0 04             	add    $0x4,%eax
  80038b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80038e:	8b 45 14             	mov    0x14(%ebp),%eax
  800391:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800393:	85 c9                	test   %ecx,%ecx
  800395:	b8 99 11 80 00       	mov    $0x801199,%eax
  80039a:	0f 45 c1             	cmovne %ecx,%eax
  80039d:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  8003a0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003a4:	7e 06                	jle    8003ac <vprintfmt+0x193>
  8003a6:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8003aa:	75 0d                	jne    8003b9 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ac:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003af:	89 c7                	mov    %eax,%edi
  8003b1:	03 45 d8             	add    -0x28(%ebp),%eax
  8003b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b7:	eb 53                	jmp    80040c <vprintfmt+0x1f3>
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bf:	50                   	push   %eax
  8003c0:	e8 eb 04 00 00       	call   8008b0 <strnlen>
  8003c5:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003c8:	29 c1                	sub    %eax,%ecx
  8003ca:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8003cd:	83 c4 10             	add    $0x10,%esp
  8003d0:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8003d2:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8003d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d9:	eb 0f                	jmp    8003ea <vprintfmt+0x1d1>
					putch(padc, putdat);
  8003db:	83 ec 08             	sub    $0x8,%esp
  8003de:	56                   	push   %esi
  8003df:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e2:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e4:	83 ef 01             	sub    $0x1,%edi
  8003e7:	83 c4 10             	add    $0x10,%esp
  8003ea:	85 ff                	test   %edi,%edi
  8003ec:	7f ed                	jg     8003db <vprintfmt+0x1c2>
  8003ee:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8003f1:	85 c9                	test   %ecx,%ecx
  8003f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f8:	0f 49 c1             	cmovns %ecx,%eax
  8003fb:	29 c1                	sub    %eax,%ecx
  8003fd:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800400:	eb aa                	jmp    8003ac <vprintfmt+0x193>
					putch(ch, putdat);
  800402:	83 ec 08             	sub    $0x8,%esp
  800405:	56                   	push   %esi
  800406:	52                   	push   %edx
  800407:	ff d3                	call   *%ebx
  800409:	83 c4 10             	add    $0x10,%esp
  80040c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80040f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800411:	83 c7 01             	add    $0x1,%edi
  800414:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800418:	0f be d0             	movsbl %al,%edx
  80041b:	85 d2                	test   %edx,%edx
  80041d:	74 2e                	je     80044d <vprintfmt+0x234>
  80041f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800423:	78 06                	js     80042b <vprintfmt+0x212>
  800425:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800429:	78 1e                	js     800449 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  80042b:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80042f:	74 d1                	je     800402 <vprintfmt+0x1e9>
  800431:	0f be c0             	movsbl %al,%eax
  800434:	83 e8 20             	sub    $0x20,%eax
  800437:	83 f8 5e             	cmp    $0x5e,%eax
  80043a:	76 c6                	jbe    800402 <vprintfmt+0x1e9>
					putch('?', putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	56                   	push   %esi
  800440:	6a 3f                	push   $0x3f
  800442:	ff d3                	call   *%ebx
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	eb c3                	jmp    80040c <vprintfmt+0x1f3>
  800449:	89 cf                	mov    %ecx,%edi
  80044b:	eb 02                	jmp    80044f <vprintfmt+0x236>
  80044d:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  80044f:	85 ff                	test   %edi,%edi
  800451:	7e 10                	jle    800463 <vprintfmt+0x24a>
				putch(' ', putdat);
  800453:	83 ec 08             	sub    $0x8,%esp
  800456:	56                   	push   %esi
  800457:	6a 20                	push   $0x20
  800459:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80045b:	83 ef 01             	sub    $0x1,%edi
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	eb ec                	jmp    80044f <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800463:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800466:	89 45 14             	mov    %eax,0x14(%ebp)
  800469:	e9 fe 02 00 00       	jmp    80076c <vprintfmt+0x553>
	if (lflag >= 2)
  80046e:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800472:	7f 21                	jg     800495 <vprintfmt+0x27c>
	else if (lflag)
  800474:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800478:	74 79                	je     8004f3 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	8b 00                	mov    (%eax),%eax
  80047f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800482:	89 c1                	mov    %eax,%ecx
  800484:	c1 f9 1f             	sar    $0x1f,%ecx
  800487:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80048a:	8b 45 14             	mov    0x14(%ebp),%eax
  80048d:	8d 40 04             	lea    0x4(%eax),%eax
  800490:	89 45 14             	mov    %eax,0x14(%ebp)
  800493:	eb 17                	jmp    8004ac <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8b 50 04             	mov    0x4(%eax),%edx
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8d 40 08             	lea    0x8(%eax),%eax
  8004a9:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  8004ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004b5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  8004b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004bc:	78 50                	js     80050e <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  8004be:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c1:	c1 fa 1f             	sar    $0x1f,%edx
  8004c4:	89 d0                	mov    %edx,%eax
  8004c6:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8004c9:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8004cc:	85 d2                	test   %edx,%edx
  8004ce:	0f 89 14 02 00 00    	jns    8006e8 <vprintfmt+0x4cf>
  8004d4:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8004d8:	0f 84 0a 02 00 00    	je     8006e8 <vprintfmt+0x4cf>
				putch('+', putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	56                   	push   %esi
  8004e2:	6a 2b                	push   $0x2b
  8004e4:	ff d3                	call   *%ebx
  8004e6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004ee:	e9 5c 01 00 00       	jmp    80064f <vprintfmt+0x436>
		return va_arg(*ap, int);
  8004f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f6:	8b 00                	mov    (%eax),%eax
  8004f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004fb:	89 c1                	mov    %eax,%ecx
  8004fd:	c1 f9 1f             	sar    $0x1f,%ecx
  800500:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8d 40 04             	lea    0x4(%eax),%eax
  800509:	89 45 14             	mov    %eax,0x14(%ebp)
  80050c:	eb 9e                	jmp    8004ac <vprintfmt+0x293>
				putch('-', putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	56                   	push   %esi
  800512:	6a 2d                	push   $0x2d
  800514:	ff d3                	call   *%ebx
				num = -(long long) num;
  800516:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800519:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80051c:	f7 d8                	neg    %eax
  80051e:	83 d2 00             	adc    $0x0,%edx
  800521:	f7 da                	neg    %edx
  800523:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800526:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80052c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800531:	e9 19 01 00 00       	jmp    80064f <vprintfmt+0x436>
	if (lflag >= 2)
  800536:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80053a:	7f 29                	jg     800565 <vprintfmt+0x34c>
	else if (lflag)
  80053c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800540:	74 44                	je     800586 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8b 00                	mov    (%eax),%eax
  800547:	ba 00 00 00 00       	mov    $0x0,%edx
  80054c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80054f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 40 04             	lea    0x4(%eax),%eax
  800558:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80055b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800560:	e9 ea 00 00 00       	jmp    80064f <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8b 50 04             	mov    0x4(%eax),%edx
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800570:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 40 08             	lea    0x8(%eax),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80057c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800581:	e9 c9 00 00 00       	jmp    80064f <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8b 00                	mov    (%eax),%eax
  80058b:	ba 00 00 00 00       	mov    $0x0,%edx
  800590:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800593:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 40 04             	lea    0x4(%eax),%eax
  80059c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059f:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a4:	e9 a6 00 00 00       	jmp    80064f <vprintfmt+0x436>
			putch('0', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	56                   	push   %esi
  8005ad:	6a 30                	push   $0x30
  8005af:	ff d3                	call   *%ebx
	if (lflag >= 2)
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8005b8:	7f 26                	jg     8005e0 <vprintfmt+0x3c7>
	else if (lflag)
  8005ba:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8005be:	74 3e                	je     8005fe <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005cd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 40 04             	lea    0x4(%eax),%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005d9:	b8 08 00 00 00       	mov    $0x8,%eax
  8005de:	eb 6f                	jmp    80064f <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 50 04             	mov    0x4(%eax),%edx
  8005e6:	8b 00                	mov    (%eax),%eax
  8005e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005eb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8d 40 08             	lea    0x8(%eax),%eax
  8005f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005f7:	b8 08 00 00 00       	mov    $0x8,%eax
  8005fc:	eb 51                	jmp    80064f <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8005fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800601:	8b 00                	mov    (%eax),%eax
  800603:	ba 00 00 00 00       	mov    $0x0,%edx
  800608:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80060b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80060e:	8b 45 14             	mov    0x14(%ebp),%eax
  800611:	8d 40 04             	lea    0x4(%eax),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800617:	b8 08 00 00 00       	mov    $0x8,%eax
  80061c:	eb 31                	jmp    80064f <vprintfmt+0x436>
			putch('0', putdat);
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	56                   	push   %esi
  800622:	6a 30                	push   $0x30
  800624:	ff d3                	call   *%ebx
			putch('x', putdat);
  800626:	83 c4 08             	add    $0x8,%esp
  800629:	56                   	push   %esi
  80062a:	6a 78                	push   $0x78
  80062c:	ff d3                	call   *%ebx
			num = (unsigned long long)
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 00                	mov    (%eax),%eax
  800633:	ba 00 00 00 00       	mov    $0x0,%edx
  800638:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80063b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  80063e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 40 04             	lea    0x4(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80064f:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800653:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800656:	89 c1                	mov    %eax,%ecx
  800658:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  80065b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80065e:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800663:	89 c2                	mov    %eax,%edx
  800665:	39 c1                	cmp    %eax,%ecx
  800667:	0f 87 85 00 00 00    	ja     8006f2 <vprintfmt+0x4d9>
		tmp /= base;
  80066d:	89 d0                	mov    %edx,%eax
  80066f:	ba 00 00 00 00       	mov    $0x0,%edx
  800674:	f7 f1                	div    %ecx
		len++;
  800676:	83 c7 01             	add    $0x1,%edi
  800679:	eb e8                	jmp    800663 <vprintfmt+0x44a>
	if (lflag >= 2)
  80067b:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80067f:	7f 26                	jg     8006a7 <vprintfmt+0x48e>
	else if (lflag)
  800681:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800685:	74 3e                	je     8006c5 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8b 00                	mov    (%eax),%eax
  80068c:	ba 00 00 00 00       	mov    $0x0,%edx
  800691:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800694:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 40 04             	lea    0x4(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a0:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a5:	eb a8                	jmp    80064f <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 50 04             	mov    0x4(%eax),%edx
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006b2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8d 40 08             	lea    0x8(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006be:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c3:	eb 8a                	jmp    80064f <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 00                	mov    (%eax),%eax
  8006ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8006cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006d2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 40 04             	lea    0x4(%eax),%eax
  8006db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006de:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e3:	e9 67 ff ff ff       	jmp    80064f <vprintfmt+0x436>
			base = 10;
  8006e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ed:	e9 5d ff ff ff       	jmp    80064f <vprintfmt+0x436>
  8006f2:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8006f5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006f8:	29 f8                	sub    %edi,%eax
  8006fa:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8006fc:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  800700:	74 15                	je     800717 <vprintfmt+0x4fe>
		while (width > 0) {
  800702:	85 ff                	test   %edi,%edi
  800704:	7e 48                	jle    80074e <vprintfmt+0x535>
			putch(padc, putdat);
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	56                   	push   %esi
  80070a:	ff 75 e0             	pushl  -0x20(%ebp)
  80070d:	ff d3                	call   *%ebx
			width--;
  80070f:	83 ef 01             	sub    $0x1,%edi
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	eb eb                	jmp    800702 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800717:	83 ec 0c             	sub    $0xc,%esp
  80071a:	6a 2d                	push   $0x2d
  80071c:	ff 75 cc             	pushl  -0x34(%ebp)
  80071f:	ff 75 c8             	pushl  -0x38(%ebp)
  800722:	ff 75 d4             	pushl  -0x2c(%ebp)
  800725:	ff 75 d0             	pushl  -0x30(%ebp)
  800728:	89 f2                	mov    %esi,%edx
  80072a:	89 d8                	mov    %ebx,%eax
  80072c:	e8 1e fa ff ff       	call   80014f <printnum_helper>
		width -= len;
  800731:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800734:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800737:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  80073a:	85 ff                	test   %edi,%edi
  80073c:	7e 2e                	jle    80076c <vprintfmt+0x553>
			putch(padc, putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	56                   	push   %esi
  800742:	6a 20                	push   $0x20
  800744:	ff d3                	call   *%ebx
			width--;
  800746:	83 ef 01             	sub    $0x1,%edi
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb ec                	jmp    80073a <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  80074e:	83 ec 0c             	sub    $0xc,%esp
  800751:	ff 75 e0             	pushl  -0x20(%ebp)
  800754:	ff 75 cc             	pushl  -0x34(%ebp)
  800757:	ff 75 c8             	pushl  -0x38(%ebp)
  80075a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80075d:	ff 75 d0             	pushl  -0x30(%ebp)
  800760:	89 f2                	mov    %esi,%edx
  800762:	89 d8                	mov    %ebx,%eax
  800764:	e8 e6 f9 ff ff       	call   80014f <printnum_helper>
  800769:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  80076c:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80076f:	83 c7 01             	add    $0x1,%edi
  800772:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800776:	83 f8 25             	cmp    $0x25,%eax
  800779:	0f 84 b1 fa ff ff    	je     800230 <vprintfmt+0x17>
			if (ch == '\0')
  80077f:	85 c0                	test   %eax,%eax
  800781:	0f 84 a1 00 00 00    	je     800828 <vprintfmt+0x60f>
			putch(ch, putdat);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	56                   	push   %esi
  80078b:	50                   	push   %eax
  80078c:	ff d3                	call   *%ebx
  80078e:	83 c4 10             	add    $0x10,%esp
  800791:	eb dc                	jmp    80076f <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	83 c0 04             	add    $0x4,%eax
  800799:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8007a1:	85 ff                	test   %edi,%edi
  8007a3:	74 15                	je     8007ba <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  8007a5:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  8007ab:	7f 29                	jg     8007d6 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  8007ad:	0f b6 06             	movzbl (%esi),%eax
  8007b0:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  8007b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b8:	eb b2                	jmp    80076c <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8007ba:	68 40 12 80 00       	push   $0x801240
  8007bf:	68 a9 11 80 00       	push   $0x8011a9
  8007c4:	56                   	push   %esi
  8007c5:	53                   	push   %ebx
  8007c6:	e8 31 fa ff ff       	call   8001fc <printfmt>
  8007cb:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8007ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d4:	eb 96                	jmp    80076c <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  8007d6:	68 78 12 80 00       	push   $0x801278
  8007db:	68 a9 11 80 00       	push   $0x8011a9
  8007e0:	56                   	push   %esi
  8007e1:	53                   	push   %ebx
  8007e2:	e8 15 fa ff ff       	call   8001fc <printfmt>
				*res = -1;
  8007e7:	c6 07 ff             	movb   $0xff,(%edi)
  8007ea:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8007ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007f0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f3:	e9 74 ff ff ff       	jmp    80076c <vprintfmt+0x553>
			putch(ch, putdat);
  8007f8:	83 ec 08             	sub    $0x8,%esp
  8007fb:	56                   	push   %esi
  8007fc:	6a 25                	push   $0x25
  8007fe:	ff d3                	call   *%ebx
			break;
  800800:	83 c4 10             	add    $0x10,%esp
  800803:	e9 64 ff ff ff       	jmp    80076c <vprintfmt+0x553>
			putch('%', putdat);
  800808:	83 ec 08             	sub    $0x8,%esp
  80080b:	56                   	push   %esi
  80080c:	6a 25                	push   $0x25
  80080e:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800810:	83 c4 10             	add    $0x10,%esp
  800813:	89 f8                	mov    %edi,%eax
  800815:	eb 03                	jmp    80081a <vprintfmt+0x601>
  800817:	83 e8 01             	sub    $0x1,%eax
  80081a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80081e:	75 f7                	jne    800817 <vprintfmt+0x5fe>
  800820:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800823:	e9 44 ff ff ff       	jmp    80076c <vprintfmt+0x553>
}
  800828:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5f                   	pop    %edi
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	83 ec 18             	sub    $0x18,%esp
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80083c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80083f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800843:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800846:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80084d:	85 c0                	test   %eax,%eax
  80084f:	74 26                	je     800877 <vsnprintf+0x47>
  800851:	85 d2                	test   %edx,%edx
  800853:	7e 22                	jle    800877 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800855:	ff 75 14             	pushl  0x14(%ebp)
  800858:	ff 75 10             	pushl  0x10(%ebp)
  80085b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80085e:	50                   	push   %eax
  80085f:	68 df 01 80 00       	push   $0x8001df
  800864:	e8 b0 f9 ff ff       	call   800219 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800869:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80086c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80086f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800872:	83 c4 10             	add    $0x10,%esp
}
  800875:	c9                   	leave  
  800876:	c3                   	ret    
		return -E_INVAL;
  800877:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80087c:	eb f7                	jmp    800875 <vsnprintf+0x45>

0080087e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800884:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800887:	50                   	push   %eax
  800888:	ff 75 10             	pushl  0x10(%ebp)
  80088b:	ff 75 0c             	pushl  0xc(%ebp)
  80088e:	ff 75 08             	pushl  0x8(%ebp)
  800891:	e8 9a ff ff ff       	call   800830 <vsnprintf>
	va_end(ap);

	return rc;
}
  800896:	c9                   	leave  
  800897:	c3                   	ret    

00800898 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a7:	74 05                	je     8008ae <strlen+0x16>
		n++;
  8008a9:	83 c0 01             	add    $0x1,%eax
  8008ac:	eb f5                	jmp    8008a3 <strlen+0xb>
	return n;
}
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008be:	39 c2                	cmp    %eax,%edx
  8008c0:	74 0d                	je     8008cf <strnlen+0x1f>
  8008c2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008c6:	74 05                	je     8008cd <strnlen+0x1d>
		n++;
  8008c8:	83 c2 01             	add    $0x1,%edx
  8008cb:	eb f1                	jmp    8008be <strnlen+0xe>
  8008cd:	89 d0                	mov    %edx,%eax
	return n;
}
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	53                   	push   %ebx
  8008d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008db:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e0:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008e4:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e7:	83 c2 01             	add    $0x1,%edx
  8008ea:	84 c9                	test   %cl,%cl
  8008ec:	75 f2                	jne    8008e0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	83 ec 10             	sub    $0x10,%esp
  8008f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008fb:	53                   	push   %ebx
  8008fc:	e8 97 ff ff ff       	call   800898 <strlen>
  800901:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800904:	ff 75 0c             	pushl  0xc(%ebp)
  800907:	01 d8                	add    %ebx,%eax
  800909:	50                   	push   %eax
  80090a:	e8 c2 ff ff ff       	call   8008d1 <strcpy>
	return dst;
}
  80090f:	89 d8                	mov    %ebx,%eax
  800911:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800914:	c9                   	leave  
  800915:	c3                   	ret    

00800916 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800921:	89 c6                	mov    %eax,%esi
  800923:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800926:	89 c2                	mov    %eax,%edx
  800928:	39 f2                	cmp    %esi,%edx
  80092a:	74 11                	je     80093d <strncpy+0x27>
		*dst++ = *src;
  80092c:	83 c2 01             	add    $0x1,%edx
  80092f:	0f b6 19             	movzbl (%ecx),%ebx
  800932:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800935:	80 fb 01             	cmp    $0x1,%bl
  800938:	83 d9 ff             	sbb    $0xffffffff,%ecx
  80093b:	eb eb                	jmp    800928 <strncpy+0x12>
	}
	return ret;
}
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	56                   	push   %esi
  800945:	53                   	push   %ebx
  800946:	8b 75 08             	mov    0x8(%ebp),%esi
  800949:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094c:	8b 55 10             	mov    0x10(%ebp),%edx
  80094f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800951:	85 d2                	test   %edx,%edx
  800953:	74 21                	je     800976 <strlcpy+0x35>
  800955:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800959:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80095b:	39 c2                	cmp    %eax,%edx
  80095d:	74 14                	je     800973 <strlcpy+0x32>
  80095f:	0f b6 19             	movzbl (%ecx),%ebx
  800962:	84 db                	test   %bl,%bl
  800964:	74 0b                	je     800971 <strlcpy+0x30>
			*dst++ = *src++;
  800966:	83 c1 01             	add    $0x1,%ecx
  800969:	83 c2 01             	add    $0x1,%edx
  80096c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80096f:	eb ea                	jmp    80095b <strlcpy+0x1a>
  800971:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800973:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800976:	29 f0                	sub    %esi,%eax
}
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800982:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800985:	0f b6 01             	movzbl (%ecx),%eax
  800988:	84 c0                	test   %al,%al
  80098a:	74 0c                	je     800998 <strcmp+0x1c>
  80098c:	3a 02                	cmp    (%edx),%al
  80098e:	75 08                	jne    800998 <strcmp+0x1c>
		p++, q++;
  800990:	83 c1 01             	add    $0x1,%ecx
  800993:	83 c2 01             	add    $0x1,%edx
  800996:	eb ed                	jmp    800985 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 c0             	movzbl %al,%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
}
  8009a0:	5d                   	pop    %ebp
  8009a1:	c3                   	ret    

008009a2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	53                   	push   %ebx
  8009a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ac:	89 c3                	mov    %eax,%ebx
  8009ae:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b1:	eb 06                	jmp    8009b9 <strncmp+0x17>
		n--, p++, q++;
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009b9:	39 d8                	cmp    %ebx,%eax
  8009bb:	74 16                	je     8009d3 <strncmp+0x31>
  8009bd:	0f b6 08             	movzbl (%eax),%ecx
  8009c0:	84 c9                	test   %cl,%cl
  8009c2:	74 04                	je     8009c8 <strncmp+0x26>
  8009c4:	3a 0a                	cmp    (%edx),%cl
  8009c6:	74 eb                	je     8009b3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c8:	0f b6 00             	movzbl (%eax),%eax
  8009cb:	0f b6 12             	movzbl (%edx),%edx
  8009ce:	29 d0                	sub    %edx,%eax
}
  8009d0:	5b                   	pop    %ebx
  8009d1:	5d                   	pop    %ebp
  8009d2:	c3                   	ret    
		return 0;
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d8:	eb f6                	jmp    8009d0 <strncmp+0x2e>

008009da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e4:	0f b6 10             	movzbl (%eax),%edx
  8009e7:	84 d2                	test   %dl,%dl
  8009e9:	74 09                	je     8009f4 <strchr+0x1a>
		if (*s == c)
  8009eb:	38 ca                	cmp    %cl,%dl
  8009ed:	74 0a                	je     8009f9 <strchr+0x1f>
	for (; *s; s++)
  8009ef:	83 c0 01             	add    $0x1,%eax
  8009f2:	eb f0                	jmp    8009e4 <strchr+0xa>
			return (char *) s;
	return 0;
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a05:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a08:	38 ca                	cmp    %cl,%dl
  800a0a:	74 09                	je     800a15 <strfind+0x1a>
  800a0c:	84 d2                	test   %dl,%dl
  800a0e:	74 05                	je     800a15 <strfind+0x1a>
	for (; *s; s++)
  800a10:	83 c0 01             	add    $0x1,%eax
  800a13:	eb f0                	jmp    800a05 <strfind+0xa>
			break;
	return (char *) s;
}
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	57                   	push   %edi
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a23:	85 c9                	test   %ecx,%ecx
  800a25:	74 31                	je     800a58 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a27:	89 f8                	mov    %edi,%eax
  800a29:	09 c8                	or     %ecx,%eax
  800a2b:	a8 03                	test   $0x3,%al
  800a2d:	75 23                	jne    800a52 <memset+0x3b>
		c &= 0xFF;
  800a2f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a33:	89 d3                	mov    %edx,%ebx
  800a35:	c1 e3 08             	shl    $0x8,%ebx
  800a38:	89 d0                	mov    %edx,%eax
  800a3a:	c1 e0 18             	shl    $0x18,%eax
  800a3d:	89 d6                	mov    %edx,%esi
  800a3f:	c1 e6 10             	shl    $0x10,%esi
  800a42:	09 f0                	or     %esi,%eax
  800a44:	09 c2                	or     %eax,%edx
  800a46:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a48:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a4b:	89 d0                	mov    %edx,%eax
  800a4d:	fc                   	cld    
  800a4e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a50:	eb 06                	jmp    800a58 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a55:	fc                   	cld    
  800a56:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a58:	89 f8                	mov    %edi,%eax
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a6d:	39 c6                	cmp    %eax,%esi
  800a6f:	73 32                	jae    800aa3 <memmove+0x44>
  800a71:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a74:	39 c2                	cmp    %eax,%edx
  800a76:	76 2b                	jbe    800aa3 <memmove+0x44>
		s += n;
		d += n;
  800a78:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7b:	89 fe                	mov    %edi,%esi
  800a7d:	09 ce                	or     %ecx,%esi
  800a7f:	09 d6                	or     %edx,%esi
  800a81:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a87:	75 0e                	jne    800a97 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a89:	83 ef 04             	sub    $0x4,%edi
  800a8c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a8f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a92:	fd                   	std    
  800a93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a95:	eb 09                	jmp    800aa0 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a97:	83 ef 01             	sub    $0x1,%edi
  800a9a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a9d:	fd                   	std    
  800a9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa0:	fc                   	cld    
  800aa1:	eb 1a                	jmp    800abd <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa3:	89 c2                	mov    %eax,%edx
  800aa5:	09 ca                	or     %ecx,%edx
  800aa7:	09 f2                	or     %esi,%edx
  800aa9:	f6 c2 03             	test   $0x3,%dl
  800aac:	75 0a                	jne    800ab8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aae:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ab1:	89 c7                	mov    %eax,%edi
  800ab3:	fc                   	cld    
  800ab4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab6:	eb 05                	jmp    800abd <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ab8:	89 c7                	mov    %eax,%edi
  800aba:	fc                   	cld    
  800abb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ac7:	ff 75 10             	pushl  0x10(%ebp)
  800aca:	ff 75 0c             	pushl  0xc(%ebp)
  800acd:	ff 75 08             	pushl  0x8(%ebp)
  800ad0:	e8 8a ff ff ff       	call   800a5f <memmove>
}
  800ad5:	c9                   	leave  
  800ad6:	c3                   	ret    

00800ad7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae2:	89 c6                	mov    %eax,%esi
  800ae4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae7:	39 f0                	cmp    %esi,%eax
  800ae9:	74 1c                	je     800b07 <memcmp+0x30>
		if (*s1 != *s2)
  800aeb:	0f b6 08             	movzbl (%eax),%ecx
  800aee:	0f b6 1a             	movzbl (%edx),%ebx
  800af1:	38 d9                	cmp    %bl,%cl
  800af3:	75 08                	jne    800afd <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800af5:	83 c0 01             	add    $0x1,%eax
  800af8:	83 c2 01             	add    $0x1,%edx
  800afb:	eb ea                	jmp    800ae7 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800afd:	0f b6 c1             	movzbl %cl,%eax
  800b00:	0f b6 db             	movzbl %bl,%ebx
  800b03:	29 d8                	sub    %ebx,%eax
  800b05:	eb 05                	jmp    800b0c <memcmp+0x35>
	}

	return 0;
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	8b 45 08             	mov    0x8(%ebp),%eax
  800b16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b19:	89 c2                	mov    %eax,%edx
  800b1b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1e:	39 d0                	cmp    %edx,%eax
  800b20:	73 09                	jae    800b2b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b22:	38 08                	cmp    %cl,(%eax)
  800b24:	74 05                	je     800b2b <memfind+0x1b>
	for (; s < ends; s++)
  800b26:	83 c0 01             	add    $0x1,%eax
  800b29:	eb f3                	jmp    800b1e <memfind+0xe>
			break;
	return (void *) s;
}
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b39:	eb 03                	jmp    800b3e <strtol+0x11>
		s++;
  800b3b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b3e:	0f b6 01             	movzbl (%ecx),%eax
  800b41:	3c 20                	cmp    $0x20,%al
  800b43:	74 f6                	je     800b3b <strtol+0xe>
  800b45:	3c 09                	cmp    $0x9,%al
  800b47:	74 f2                	je     800b3b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b49:	3c 2b                	cmp    $0x2b,%al
  800b4b:	74 2a                	je     800b77 <strtol+0x4a>
	int neg = 0;
  800b4d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b52:	3c 2d                	cmp    $0x2d,%al
  800b54:	74 2b                	je     800b81 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b56:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5c:	75 0f                	jne    800b6d <strtol+0x40>
  800b5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b61:	74 28                	je     800b8b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b63:	85 db                	test   %ebx,%ebx
  800b65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6a:	0f 44 d8             	cmove  %eax,%ebx
  800b6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b72:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b75:	eb 50                	jmp    800bc7 <strtol+0x9a>
		s++;
  800b77:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7f:	eb d5                	jmp    800b56 <strtol+0x29>
		s++, neg = 1;
  800b81:	83 c1 01             	add    $0x1,%ecx
  800b84:	bf 01 00 00 00       	mov    $0x1,%edi
  800b89:	eb cb                	jmp    800b56 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b8f:	74 0e                	je     800b9f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b91:	85 db                	test   %ebx,%ebx
  800b93:	75 d8                	jne    800b6d <strtol+0x40>
		s++, base = 8;
  800b95:	83 c1 01             	add    $0x1,%ecx
  800b98:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b9d:	eb ce                	jmp    800b6d <strtol+0x40>
		s += 2, base = 16;
  800b9f:	83 c1 02             	add    $0x2,%ecx
  800ba2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba7:	eb c4                	jmp    800b6d <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ba9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bac:	89 f3                	mov    %esi,%ebx
  800bae:	80 fb 19             	cmp    $0x19,%bl
  800bb1:	77 29                	ja     800bdc <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bb3:	0f be d2             	movsbl %dl,%edx
  800bb6:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bbc:	7d 30                	jge    800bee <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bbe:	83 c1 01             	add    $0x1,%ecx
  800bc1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bc7:	0f b6 11             	movzbl (%ecx),%edx
  800bca:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bcd:	89 f3                	mov    %esi,%ebx
  800bcf:	80 fb 09             	cmp    $0x9,%bl
  800bd2:	77 d5                	ja     800ba9 <strtol+0x7c>
			dig = *s - '0';
  800bd4:	0f be d2             	movsbl %dl,%edx
  800bd7:	83 ea 30             	sub    $0x30,%edx
  800bda:	eb dd                	jmp    800bb9 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800bdc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bdf:	89 f3                	mov    %esi,%ebx
  800be1:	80 fb 19             	cmp    $0x19,%bl
  800be4:	77 08                	ja     800bee <strtol+0xc1>
			dig = *s - 'A' + 10;
  800be6:	0f be d2             	movsbl %dl,%edx
  800be9:	83 ea 37             	sub    $0x37,%edx
  800bec:	eb cb                	jmp    800bb9 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf2:	74 05                	je     800bf9 <strtol+0xcc>
		*endptr = (char *) s;
  800bf4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bf9:	89 c2                	mov    %eax,%edx
  800bfb:	f7 da                	neg    %edx
  800bfd:	85 ff                	test   %edi,%edi
  800bff:	0f 45 c2             	cmovne %edx,%eax
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c12:	8b 55 08             	mov    0x8(%ebp),%edx
  800c15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c18:	89 c3                	mov    %eax,%ebx
  800c1a:	89 c7                	mov    %eax,%edi
  800c1c:	89 c6                	mov    %eax,%esi
  800c1e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	57                   	push   %edi
  800c29:	56                   	push   %esi
  800c2a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c30:	b8 01 00 00 00       	mov    $0x1,%eax
  800c35:	89 d1                	mov    %edx,%ecx
  800c37:	89 d3                	mov    %edx,%ebx
  800c39:	89 d7                	mov    %edx,%edi
  800c3b:	89 d6                	mov    %edx,%esi
  800c3d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c52:	8b 55 08             	mov    0x8(%ebp),%edx
  800c55:	b8 03 00 00 00       	mov    $0x3,%eax
  800c5a:	89 cb                	mov    %ecx,%ebx
  800c5c:	89 cf                	mov    %ecx,%edi
  800c5e:	89 ce                	mov    %ecx,%esi
  800c60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7f 08                	jg     800c6e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	83 ec 0c             	sub    $0xc,%esp
  800c71:	50                   	push   %eax
  800c72:	6a 03                	push   $0x3
  800c74:	68 44 14 80 00       	push   $0x801444
  800c79:	6a 23                	push   $0x23
  800c7b:	68 61 14 80 00       	push   $0x801461
  800c80:	e8 2e 02 00 00       	call   800eb3 <_panic>

00800c85 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c90:	b8 02 00 00 00       	mov    $0x2,%eax
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	89 d3                	mov    %edx,%ebx
  800c99:	89 d7                	mov    %edx,%edi
  800c9b:	89 d6                	mov    %edx,%esi
  800c9d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_yield>:

void
sys_yield(void)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	89 d3                	mov    %edx,%ebx
  800cb8:	89 d7                	mov    %edx,%edi
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccc:	be 00 00 00 00       	mov    $0x0,%esi
  800cd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	b8 04 00 00 00       	mov    $0x4,%eax
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	89 f7                	mov    %esi,%edi
  800ce1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7f 08                	jg     800cef <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cea:	5b                   	pop    %ebx
  800ceb:	5e                   	pop    %esi
  800cec:	5f                   	pop    %edi
  800ced:	5d                   	pop    %ebp
  800cee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cef:	83 ec 0c             	sub    $0xc,%esp
  800cf2:	50                   	push   %eax
  800cf3:	6a 04                	push   $0x4
  800cf5:	68 44 14 80 00       	push   $0x801444
  800cfa:	6a 23                	push   $0x23
  800cfc:	68 61 14 80 00       	push   $0x801461
  800d01:	e8 ad 01 00 00       	call   800eb3 <_panic>

00800d06 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	b8 05 00 00 00       	mov    $0x5,%eax
  800d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d20:	8b 75 18             	mov    0x18(%ebp),%esi
  800d23:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7f 08                	jg     800d31 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2c:	5b                   	pop    %ebx
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	6a 05                	push   $0x5
  800d37:	68 44 14 80 00       	push   $0x801444
  800d3c:	6a 23                	push   $0x23
  800d3e:	68 61 14 80 00       	push   $0x801461
  800d43:	e8 6b 01 00 00       	call   800eb3 <_panic>

00800d48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d61:	89 df                	mov    %ebx,%edi
  800d63:	89 de                	mov    %ebx,%esi
  800d65:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d67:	85 c0                	test   %eax,%eax
  800d69:	7f 08                	jg     800d73 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d6b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d73:	83 ec 0c             	sub    $0xc,%esp
  800d76:	50                   	push   %eax
  800d77:	6a 06                	push   $0x6
  800d79:	68 44 14 80 00       	push   $0x801444
  800d7e:	6a 23                	push   $0x23
  800d80:	68 61 14 80 00       	push   $0x801461
  800d85:	e8 29 01 00 00       	call   800eb3 <_panic>

00800d8a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9e:	b8 08 00 00 00       	mov    $0x8,%eax
  800da3:	89 df                	mov    %ebx,%edi
  800da5:	89 de                	mov    %ebx,%esi
  800da7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7f 08                	jg     800db5 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db5:	83 ec 0c             	sub    $0xc,%esp
  800db8:	50                   	push   %eax
  800db9:	6a 08                	push   $0x8
  800dbb:	68 44 14 80 00       	push   $0x801444
  800dc0:	6a 23                	push   $0x23
  800dc2:	68 61 14 80 00       	push   $0x801461
  800dc7:	e8 e7 00 00 00       	call   800eb3 <_panic>

00800dcc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dda:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de0:	b8 09 00 00 00       	mov    $0x9,%eax
  800de5:	89 df                	mov    %ebx,%edi
  800de7:	89 de                	mov    %ebx,%esi
  800de9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7f 08                	jg     800df7 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  800dfb:	6a 09                	push   $0x9
  800dfd:	68 44 14 80 00       	push   $0x801444
  800e02:	6a 23                	push   $0x23
  800e04:	68 61 14 80 00       	push   $0x801461
  800e09:	e8 a5 00 00 00       	call   800eb3 <_panic>

00800e0e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e14:	8b 55 08             	mov    0x8(%ebp),%edx
  800e17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e1f:	be 00 00 00 00       	mov    $0x0,%esi
  800e24:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	57                   	push   %edi
  800e35:	56                   	push   %esi
  800e36:	53                   	push   %ebx
  800e37:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e42:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e47:	89 cb                	mov    %ecx,%ebx
  800e49:	89 cf                	mov    %ecx,%edi
  800e4b:	89 ce                	mov    %ecx,%esi
  800e4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	7f 08                	jg     800e5b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e56:	5b                   	pop    %ebx
  800e57:	5e                   	pop    %esi
  800e58:	5f                   	pop    %edi
  800e59:	5d                   	pop    %ebp
  800e5a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5b:	83 ec 0c             	sub    $0xc,%esp
  800e5e:	50                   	push   %eax
  800e5f:	6a 0c                	push   $0xc
  800e61:	68 44 14 80 00       	push   $0x801444
  800e66:	6a 23                	push   $0x23
  800e68:	68 61 14 80 00       	push   $0x801461
  800e6d:	e8 41 00 00 00       	call   800eb3 <_panic>

00800e72 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e78:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e83:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e88:	89 df                	mov    %ebx,%edi
  800e8a:	89 de                	mov    %ebx,%esi
  800e8c:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	57                   	push   %edi
  800e97:	56                   	push   %esi
  800e98:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ea6:	89 cb                	mov    %ecx,%ebx
  800ea8:	89 cf                	mov    %ecx,%edi
  800eaa:	89 ce                	mov    %ecx,%esi
  800eac:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800eae:	5b                   	pop    %ebx
  800eaf:	5e                   	pop    %esi
  800eb0:	5f                   	pop    %edi
  800eb1:	5d                   	pop    %ebp
  800eb2:	c3                   	ret    

00800eb3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800eb3:	55                   	push   %ebp
  800eb4:	89 e5                	mov    %esp,%ebp
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800eb8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ebb:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ec1:	e8 bf fd ff ff       	call   800c85 <sys_getenvid>
  800ec6:	83 ec 0c             	sub    $0xc,%esp
  800ec9:	ff 75 0c             	pushl  0xc(%ebp)
  800ecc:	ff 75 08             	pushl  0x8(%ebp)
  800ecf:	56                   	push   %esi
  800ed0:	50                   	push   %eax
  800ed1:	68 70 14 80 00       	push   $0x801470
  800ed6:	e8 60 f2 ff ff       	call   80013b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800edb:	83 c4 18             	add    $0x18,%esp
  800ede:	53                   	push   %ebx
  800edf:	ff 75 10             	pushl  0x10(%ebp)
  800ee2:	e8 03 f2 ff ff       	call   8000ea <vcprintf>
	cprintf("\n");
  800ee7:	c7 04 24 7c 11 80 00 	movl   $0x80117c,(%esp)
  800eee:	e8 48 f2 ff ff       	call   80013b <cprintf>
  800ef3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ef6:	cc                   	int3   
  800ef7:	eb fd                	jmp    800ef6 <_panic+0x43>
  800ef9:	66 90                	xchg   %ax,%ax
  800efb:	66 90                	xchg   %ax,%ax
  800efd:	66 90                	xchg   %ax,%ax
  800eff:	90                   	nop

00800f00 <__udivdi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 1c             	sub    $0x1c,%esp
  800f07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f0b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f13:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f17:	85 d2                	test   %edx,%edx
  800f19:	75 4d                	jne    800f68 <__udivdi3+0x68>
  800f1b:	39 f3                	cmp    %esi,%ebx
  800f1d:	76 19                	jbe    800f38 <__udivdi3+0x38>
  800f1f:	31 ff                	xor    %edi,%edi
  800f21:	89 e8                	mov    %ebp,%eax
  800f23:	89 f2                	mov    %esi,%edx
  800f25:	f7 f3                	div    %ebx
  800f27:	89 fa                	mov    %edi,%edx
  800f29:	83 c4 1c             	add    $0x1c,%esp
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    
  800f31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f38:	89 d9                	mov    %ebx,%ecx
  800f3a:	85 db                	test   %ebx,%ebx
  800f3c:	75 0b                	jne    800f49 <__udivdi3+0x49>
  800f3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f43:	31 d2                	xor    %edx,%edx
  800f45:	f7 f3                	div    %ebx
  800f47:	89 c1                	mov    %eax,%ecx
  800f49:	31 d2                	xor    %edx,%edx
  800f4b:	89 f0                	mov    %esi,%eax
  800f4d:	f7 f1                	div    %ecx
  800f4f:	89 c6                	mov    %eax,%esi
  800f51:	89 e8                	mov    %ebp,%eax
  800f53:	89 f7                	mov    %esi,%edi
  800f55:	f7 f1                	div    %ecx
  800f57:	89 fa                	mov    %edi,%edx
  800f59:	83 c4 1c             	add    $0x1c,%esp
  800f5c:	5b                   	pop    %ebx
  800f5d:	5e                   	pop    %esi
  800f5e:	5f                   	pop    %edi
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    
  800f61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f68:	39 f2                	cmp    %esi,%edx
  800f6a:	77 1c                	ja     800f88 <__udivdi3+0x88>
  800f6c:	0f bd fa             	bsr    %edx,%edi
  800f6f:	83 f7 1f             	xor    $0x1f,%edi
  800f72:	75 2c                	jne    800fa0 <__udivdi3+0xa0>
  800f74:	39 f2                	cmp    %esi,%edx
  800f76:	72 06                	jb     800f7e <__udivdi3+0x7e>
  800f78:	31 c0                	xor    %eax,%eax
  800f7a:	39 eb                	cmp    %ebp,%ebx
  800f7c:	77 a9                	ja     800f27 <__udivdi3+0x27>
  800f7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f83:	eb a2                	jmp    800f27 <__udivdi3+0x27>
  800f85:	8d 76 00             	lea    0x0(%esi),%esi
  800f88:	31 ff                	xor    %edi,%edi
  800f8a:	31 c0                	xor    %eax,%eax
  800f8c:	89 fa                	mov    %edi,%edx
  800f8e:	83 c4 1c             	add    $0x1c,%esp
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    
  800f96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f9d:	8d 76 00             	lea    0x0(%esi),%esi
  800fa0:	89 f9                	mov    %edi,%ecx
  800fa2:	b8 20 00 00 00       	mov    $0x20,%eax
  800fa7:	29 f8                	sub    %edi,%eax
  800fa9:	d3 e2                	shl    %cl,%edx
  800fab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800faf:	89 c1                	mov    %eax,%ecx
  800fb1:	89 da                	mov    %ebx,%edx
  800fb3:	d3 ea                	shr    %cl,%edx
  800fb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fb9:	09 d1                	or     %edx,%ecx
  800fbb:	89 f2                	mov    %esi,%edx
  800fbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fc1:	89 f9                	mov    %edi,%ecx
  800fc3:	d3 e3                	shl    %cl,%ebx
  800fc5:	89 c1                	mov    %eax,%ecx
  800fc7:	d3 ea                	shr    %cl,%edx
  800fc9:	89 f9                	mov    %edi,%ecx
  800fcb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fcf:	89 eb                	mov    %ebp,%ebx
  800fd1:	d3 e6                	shl    %cl,%esi
  800fd3:	89 c1                	mov    %eax,%ecx
  800fd5:	d3 eb                	shr    %cl,%ebx
  800fd7:	09 de                	or     %ebx,%esi
  800fd9:	89 f0                	mov    %esi,%eax
  800fdb:	f7 74 24 08          	divl   0x8(%esp)
  800fdf:	89 d6                	mov    %edx,%esi
  800fe1:	89 c3                	mov    %eax,%ebx
  800fe3:	f7 64 24 0c          	mull   0xc(%esp)
  800fe7:	39 d6                	cmp    %edx,%esi
  800fe9:	72 15                	jb     801000 <__udivdi3+0x100>
  800feb:	89 f9                	mov    %edi,%ecx
  800fed:	d3 e5                	shl    %cl,%ebp
  800fef:	39 c5                	cmp    %eax,%ebp
  800ff1:	73 04                	jae    800ff7 <__udivdi3+0xf7>
  800ff3:	39 d6                	cmp    %edx,%esi
  800ff5:	74 09                	je     801000 <__udivdi3+0x100>
  800ff7:	89 d8                	mov    %ebx,%eax
  800ff9:	31 ff                	xor    %edi,%edi
  800ffb:	e9 27 ff ff ff       	jmp    800f27 <__udivdi3+0x27>
  801000:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801003:	31 ff                	xor    %edi,%edi
  801005:	e9 1d ff ff ff       	jmp    800f27 <__udivdi3+0x27>
  80100a:	66 90                	xchg   %ax,%ax
  80100c:	66 90                	xchg   %ax,%ax
  80100e:	66 90                	xchg   %ax,%ax

00801010 <__umoddi3>:
  801010:	55                   	push   %ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	83 ec 1c             	sub    $0x1c,%esp
  801017:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80101b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80101f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801027:	89 da                	mov    %ebx,%edx
  801029:	85 c0                	test   %eax,%eax
  80102b:	75 43                	jne    801070 <__umoddi3+0x60>
  80102d:	39 df                	cmp    %ebx,%edi
  80102f:	76 17                	jbe    801048 <__umoddi3+0x38>
  801031:	89 f0                	mov    %esi,%eax
  801033:	f7 f7                	div    %edi
  801035:	89 d0                	mov    %edx,%eax
  801037:	31 d2                	xor    %edx,%edx
  801039:	83 c4 1c             	add    $0x1c,%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    
  801041:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801048:	89 fd                	mov    %edi,%ebp
  80104a:	85 ff                	test   %edi,%edi
  80104c:	75 0b                	jne    801059 <__umoddi3+0x49>
  80104e:	b8 01 00 00 00       	mov    $0x1,%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	f7 f7                	div    %edi
  801057:	89 c5                	mov    %eax,%ebp
  801059:	89 d8                	mov    %ebx,%eax
  80105b:	31 d2                	xor    %edx,%edx
  80105d:	f7 f5                	div    %ebp
  80105f:	89 f0                	mov    %esi,%eax
  801061:	f7 f5                	div    %ebp
  801063:	89 d0                	mov    %edx,%eax
  801065:	eb d0                	jmp    801037 <__umoddi3+0x27>
  801067:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80106e:	66 90                	xchg   %ax,%ax
  801070:	89 f1                	mov    %esi,%ecx
  801072:	39 d8                	cmp    %ebx,%eax
  801074:	76 0a                	jbe    801080 <__umoddi3+0x70>
  801076:	89 f0                	mov    %esi,%eax
  801078:	83 c4 1c             	add    $0x1c,%esp
  80107b:	5b                   	pop    %ebx
  80107c:	5e                   	pop    %esi
  80107d:	5f                   	pop    %edi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    
  801080:	0f bd e8             	bsr    %eax,%ebp
  801083:	83 f5 1f             	xor    $0x1f,%ebp
  801086:	75 20                	jne    8010a8 <__umoddi3+0x98>
  801088:	39 d8                	cmp    %ebx,%eax
  80108a:	0f 82 b0 00 00 00    	jb     801140 <__umoddi3+0x130>
  801090:	39 f7                	cmp    %esi,%edi
  801092:	0f 86 a8 00 00 00    	jbe    801140 <__umoddi3+0x130>
  801098:	89 c8                	mov    %ecx,%eax
  80109a:	83 c4 1c             	add    $0x1c,%esp
  80109d:	5b                   	pop    %ebx
  80109e:	5e                   	pop    %esi
  80109f:	5f                   	pop    %edi
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    
  8010a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010a8:	89 e9                	mov    %ebp,%ecx
  8010aa:	ba 20 00 00 00       	mov    $0x20,%edx
  8010af:	29 ea                	sub    %ebp,%edx
  8010b1:	d3 e0                	shl    %cl,%eax
  8010b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b7:	89 d1                	mov    %edx,%ecx
  8010b9:	89 f8                	mov    %edi,%eax
  8010bb:	d3 e8                	shr    %cl,%eax
  8010bd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010c5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010c9:	09 c1                	or     %eax,%ecx
  8010cb:	89 d8                	mov    %ebx,%eax
  8010cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010d1:	89 e9                	mov    %ebp,%ecx
  8010d3:	d3 e7                	shl    %cl,%edi
  8010d5:	89 d1                	mov    %edx,%ecx
  8010d7:	d3 e8                	shr    %cl,%eax
  8010d9:	89 e9                	mov    %ebp,%ecx
  8010db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010df:	d3 e3                	shl    %cl,%ebx
  8010e1:	89 c7                	mov    %eax,%edi
  8010e3:	89 d1                	mov    %edx,%ecx
  8010e5:	89 f0                	mov    %esi,%eax
  8010e7:	d3 e8                	shr    %cl,%eax
  8010e9:	89 e9                	mov    %ebp,%ecx
  8010eb:	89 fa                	mov    %edi,%edx
  8010ed:	d3 e6                	shl    %cl,%esi
  8010ef:	09 d8                	or     %ebx,%eax
  8010f1:	f7 74 24 08          	divl   0x8(%esp)
  8010f5:	89 d1                	mov    %edx,%ecx
  8010f7:	89 f3                	mov    %esi,%ebx
  8010f9:	f7 64 24 0c          	mull   0xc(%esp)
  8010fd:	89 c6                	mov    %eax,%esi
  8010ff:	89 d7                	mov    %edx,%edi
  801101:	39 d1                	cmp    %edx,%ecx
  801103:	72 06                	jb     80110b <__umoddi3+0xfb>
  801105:	75 10                	jne    801117 <__umoddi3+0x107>
  801107:	39 c3                	cmp    %eax,%ebx
  801109:	73 0c                	jae    801117 <__umoddi3+0x107>
  80110b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80110f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801113:	89 d7                	mov    %edx,%edi
  801115:	89 c6                	mov    %eax,%esi
  801117:	89 ca                	mov    %ecx,%edx
  801119:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80111e:	29 f3                	sub    %esi,%ebx
  801120:	19 fa                	sbb    %edi,%edx
  801122:	89 d0                	mov    %edx,%eax
  801124:	d3 e0                	shl    %cl,%eax
  801126:	89 e9                	mov    %ebp,%ecx
  801128:	d3 eb                	shr    %cl,%ebx
  80112a:	d3 ea                	shr    %cl,%edx
  80112c:	09 d8                	or     %ebx,%eax
  80112e:	83 c4 1c             	add    $0x1c,%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    
  801136:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80113d:	8d 76 00             	lea    0x0(%esi),%esi
  801140:	89 da                	mov    %ebx,%edx
  801142:	29 fe                	sub    %edi,%esi
  801144:	19 c2                	sbb    %eax,%edx
  801146:	89 f1                	mov    %esi,%ecx
  801148:	89 c8                	mov    %ecx,%eax
  80114a:	e9 4b ff ff ff       	jmp    80109a <__umoddi3+0x8a>
