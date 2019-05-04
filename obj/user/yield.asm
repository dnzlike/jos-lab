
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 20 80 00       	mov    0x802004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 a0 11 80 00       	push   $0x8011a0
  800048:	e8 3a 01 00 00       	call   800187 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 96 0c 00 00       	call   800cf0 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 c0 11 80 00       	push   $0x8011c0
  80006c:	e8 16 01 00 00       	call   800187 <cprintf>
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 20 80 00       	mov    0x802004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 ec 11 80 00       	push   $0x8011ec
  80008d:	e8 f5 00 00 00       	call   800187 <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000a5:	e8 27 0c 00 00       	call   800cd1 <sys_getenvid>
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	c1 e0 07             	shl    $0x7,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000e6:	6a 00                	push   $0x0
  8000e8:	e8 a3 0b 00 00       	call   800c90 <sys_env_destroy>
}
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fc:	8b 13                	mov    (%ebx),%edx
  8000fe:	8d 42 01             	lea    0x1(%edx),%eax
  800101:	89 03                	mov    %eax,(%ebx)
  800103:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800106:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010f:	74 09                	je     80011a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800111:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800118:	c9                   	leave  
  800119:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	68 ff 00 00 00       	push   $0xff
  800122:	8d 43 08             	lea    0x8(%ebx),%eax
  800125:	50                   	push   %eax
  800126:	e8 28 0b 00 00       	call   800c53 <sys_cputs>
		b->idx = 0;
  80012b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800131:	83 c4 10             	add    $0x10,%esp
  800134:	eb db                	jmp    800111 <putch+0x1f>

00800136 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80013f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800146:	00 00 00 
	b.cnt = 0;
  800149:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800150:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800153:	ff 75 0c             	pushl  0xc(%ebp)
  800156:	ff 75 08             	pushl  0x8(%ebp)
  800159:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015f:	50                   	push   %eax
  800160:	68 f2 00 80 00       	push   $0x8000f2
  800165:	e8 fb 00 00 00       	call   800265 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016a:	83 c4 08             	add    $0x8,%esp
  80016d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800173:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	e8 d4 0a 00 00       	call   800c53 <sys_cputs>

	return b.cnt;
}
  80017f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800190:	50                   	push   %eax
  800191:	ff 75 08             	pushl  0x8(%ebp)
  800194:	e8 9d ff ff ff       	call   800136 <vcprintf>
	va_end(ap);

	return cnt;
}
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	57                   	push   %edi
  80019f:	56                   	push   %esi
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 1c             	sub    $0x1c,%esp
  8001a4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a7:	89 d3                	mov    %edx,%ebx
  8001a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ac:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001af:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  8001b5:	89 c2                	mov    %eax,%edx
  8001b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001bf:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001c2:	39 c6                	cmp    %eax,%esi
  8001c4:	89 f8                	mov    %edi,%eax
  8001c6:	19 c8                	sbb    %ecx,%eax
  8001c8:	73 32                	jae    8001fc <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  8001ca:	83 ec 08             	sub    $0x8,%esp
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 04             	sub    $0x4,%esp
  8001d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d7:	57                   	push   %edi
  8001d8:	56                   	push   %esi
  8001d9:	e8 82 0e 00 00       	call   801060 <__umoddi3>
  8001de:	83 c4 14             	add    $0x14,%esp
  8001e1:	0f be 80 15 12 80 00 	movsbl 0x801215(%eax),%eax
  8001e8:	50                   	push   %eax
  8001e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001ec:	ff d0                	call   *%eax
	return remain - 1;
  8001ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f1:	83 e8 01             	sub    $0x1,%eax
}
  8001f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f7:	5b                   	pop    %ebx
  8001f8:	5e                   	pop    %esi
  8001f9:	5f                   	pop    %edi
  8001fa:	5d                   	pop    %ebp
  8001fb:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  8001fc:	83 ec 0c             	sub    $0xc,%esp
  8001ff:	ff 75 18             	pushl  0x18(%ebp)
  800202:	ff 75 14             	pushl  0x14(%ebp)
  800205:	ff 75 d8             	pushl  -0x28(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	51                   	push   %ecx
  80020c:	52                   	push   %edx
  80020d:	57                   	push   %edi
  80020e:	56                   	push   %esi
  80020f:	e8 3c 0d 00 00       	call   800f50 <__udivdi3>
  800214:	83 c4 18             	add    $0x18,%esp
  800217:	52                   	push   %edx
  800218:	50                   	push   %eax
  800219:	89 da                	mov    %ebx,%edx
  80021b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021e:	e8 78 ff ff ff       	call   80019b <printnum_helper>
  800223:	89 45 14             	mov    %eax,0x14(%ebp)
  800226:	83 c4 20             	add    $0x20,%esp
  800229:	eb 9f                	jmp    8001ca <printnum_helper+0x2f>

0080022b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800231:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800235:	8b 10                	mov    (%eax),%edx
  800237:	3b 50 04             	cmp    0x4(%eax),%edx
  80023a:	73 0a                	jae    800246 <sprintputch+0x1b>
		*b->buf++ = ch;
  80023c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80023f:	89 08                	mov    %ecx,(%eax)
  800241:	8b 45 08             	mov    0x8(%ebp),%eax
  800244:	88 02                	mov    %al,(%edx)
}
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <printfmt>:
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80024e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800251:	50                   	push   %eax
  800252:	ff 75 10             	pushl  0x10(%ebp)
  800255:	ff 75 0c             	pushl  0xc(%ebp)
  800258:	ff 75 08             	pushl  0x8(%ebp)
  80025b:	e8 05 00 00 00       	call   800265 <vprintfmt>
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	c9                   	leave  
  800264:	c3                   	ret    

00800265 <vprintfmt>:
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	57                   	push   %edi
  800269:	56                   	push   %esi
  80026a:	53                   	push   %ebx
  80026b:	83 ec 3c             	sub    $0x3c,%esp
  80026e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800271:	8b 75 0c             	mov    0xc(%ebp),%esi
  800274:	8b 7d 10             	mov    0x10(%ebp),%edi
  800277:	e9 3f 05 00 00       	jmp    8007bb <vprintfmt+0x556>
		padc = ' ';
  80027c:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800280:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800287:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  80028e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800295:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  80029c:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8002a3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002a8:	8d 47 01             	lea    0x1(%edi),%eax
  8002ab:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002ae:	0f b6 17             	movzbl (%edi),%edx
  8002b1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002b4:	3c 55                	cmp    $0x55,%al
  8002b6:	0f 87 98 05 00 00    	ja     800854 <vprintfmt+0x5ef>
  8002bc:	0f b6 c0             	movzbl %al,%eax
  8002bf:	ff 24 85 60 13 80 00 	jmp    *0x801360(,%eax,4)
  8002c6:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  8002c9:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8002cd:	eb d9                	jmp    8002a8 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8002cf:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  8002d2:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  8002d9:	eb cd                	jmp    8002a8 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8002db:	0f b6 d2             	movzbl %dl,%edx
  8002de:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e6:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  8002e9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ec:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002f0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002f3:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8002f6:	83 fb 09             	cmp    $0x9,%ebx
  8002f9:	77 5c                	ja     800357 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  8002fb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002fe:	eb e9                	jmp    8002e9 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  800303:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  800307:	eb 9f                	jmp    8002a8 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  800309:	8b 45 14             	mov    0x14(%ebp),%eax
  80030c:	8b 00                	mov    (%eax),%eax
  80030e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800311:	8b 45 14             	mov    0x14(%ebp),%eax
  800314:	8d 40 04             	lea    0x4(%eax),%eax
  800317:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  80031d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800321:	79 85                	jns    8002a8 <vprintfmt+0x43>
				width = precision, precision = -1;
  800323:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800326:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800329:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800330:	e9 73 ff ff ff       	jmp    8002a8 <vprintfmt+0x43>
  800335:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800338:	85 c0                	test   %eax,%eax
  80033a:	0f 48 c1             	cmovs  %ecx,%eax
  80033d:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800343:	e9 60 ff ff ff       	jmp    8002a8 <vprintfmt+0x43>
  800348:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  80034b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800352:	e9 51 ff ff ff       	jmp    8002a8 <vprintfmt+0x43>
  800357:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80035d:	eb be                	jmp    80031d <vprintfmt+0xb8>
			lflag++;
  80035f:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800363:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  800366:	e9 3d ff ff ff       	jmp    8002a8 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  80036b:	8b 45 14             	mov    0x14(%ebp),%eax
  80036e:	8d 78 04             	lea    0x4(%eax),%edi
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	56                   	push   %esi
  800375:	ff 30                	pushl  (%eax)
  800377:	ff d3                	call   *%ebx
			break;
  800379:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80037c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80037f:	e9 34 04 00 00       	jmp    8007b8 <vprintfmt+0x553>
			err = va_arg(ap, int);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8d 78 04             	lea    0x4(%eax),%edi
  80038a:	8b 00                	mov    (%eax),%eax
  80038c:	99                   	cltd   
  80038d:	31 d0                	xor    %edx,%eax
  80038f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800391:	83 f8 08             	cmp    $0x8,%eax
  800394:	7f 23                	jg     8003b9 <vprintfmt+0x154>
  800396:	8b 14 85 c0 14 80 00 	mov    0x8014c0(,%eax,4),%edx
  80039d:	85 d2                	test   %edx,%edx
  80039f:	74 18                	je     8003b9 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  8003a1:	52                   	push   %edx
  8003a2:	68 36 12 80 00       	push   $0x801236
  8003a7:	56                   	push   %esi
  8003a8:	53                   	push   %ebx
  8003a9:	e8 9a fe ff ff       	call   800248 <printfmt>
  8003ae:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b1:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003b4:	e9 ff 03 00 00       	jmp    8007b8 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  8003b9:	50                   	push   %eax
  8003ba:	68 2d 12 80 00       	push   $0x80122d
  8003bf:	56                   	push   %esi
  8003c0:	53                   	push   %ebx
  8003c1:	e8 82 fe ff ff       	call   800248 <printfmt>
  8003c6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003c9:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003cc:	e9 e7 03 00 00       	jmp    8007b8 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  8003d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d4:	83 c0 04             	add    $0x4,%eax
  8003d7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003da:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dd:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8003df:	85 c9                	test   %ecx,%ecx
  8003e1:	b8 26 12 80 00       	mov    $0x801226,%eax
  8003e6:	0f 45 c1             	cmovne %ecx,%eax
  8003e9:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  8003ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003f0:	7e 06                	jle    8003f8 <vprintfmt+0x193>
  8003f2:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8003f6:	75 0d                	jne    800405 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003fb:	89 c7                	mov    %eax,%edi
  8003fd:	03 45 d8             	add    -0x28(%ebp),%eax
  800400:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800403:	eb 53                	jmp    800458 <vprintfmt+0x1f3>
  800405:	83 ec 08             	sub    $0x8,%esp
  800408:	ff 75 e0             	pushl  -0x20(%ebp)
  80040b:	50                   	push   %eax
  80040c:	e8 eb 04 00 00       	call   8008fc <strnlen>
  800411:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800414:	29 c1                	sub    %eax,%ecx
  800416:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  800419:	83 c4 10             	add    $0x10,%esp
  80041c:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80041e:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  800422:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800425:	eb 0f                	jmp    800436 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800427:	83 ec 08             	sub    $0x8,%esp
  80042a:	56                   	push   %esi
  80042b:	ff 75 d8             	pushl  -0x28(%ebp)
  80042e:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800430:	83 ef 01             	sub    $0x1,%edi
  800433:	83 c4 10             	add    $0x10,%esp
  800436:	85 ff                	test   %edi,%edi
  800438:	7f ed                	jg     800427 <vprintfmt+0x1c2>
  80043a:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80043d:	85 c9                	test   %ecx,%ecx
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	0f 49 c1             	cmovns %ecx,%eax
  800447:	29 c1                	sub    %eax,%ecx
  800449:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80044c:	eb aa                	jmp    8003f8 <vprintfmt+0x193>
					putch(ch, putdat);
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	56                   	push   %esi
  800452:	52                   	push   %edx
  800453:	ff d3                	call   *%ebx
  800455:	83 c4 10             	add    $0x10,%esp
  800458:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80045b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80045d:	83 c7 01             	add    $0x1,%edi
  800460:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800464:	0f be d0             	movsbl %al,%edx
  800467:	85 d2                	test   %edx,%edx
  800469:	74 2e                	je     800499 <vprintfmt+0x234>
  80046b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80046f:	78 06                	js     800477 <vprintfmt+0x212>
  800471:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800475:	78 1e                	js     800495 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800477:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80047b:	74 d1                	je     80044e <vprintfmt+0x1e9>
  80047d:	0f be c0             	movsbl %al,%eax
  800480:	83 e8 20             	sub    $0x20,%eax
  800483:	83 f8 5e             	cmp    $0x5e,%eax
  800486:	76 c6                	jbe    80044e <vprintfmt+0x1e9>
					putch('?', putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	56                   	push   %esi
  80048c:	6a 3f                	push   $0x3f
  80048e:	ff d3                	call   *%ebx
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	eb c3                	jmp    800458 <vprintfmt+0x1f3>
  800495:	89 cf                	mov    %ecx,%edi
  800497:	eb 02                	jmp    80049b <vprintfmt+0x236>
  800499:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  80049b:	85 ff                	test   %edi,%edi
  80049d:	7e 10                	jle    8004af <vprintfmt+0x24a>
				putch(' ', putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	56                   	push   %esi
  8004a3:	6a 20                	push   $0x20
  8004a5:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8004a7:	83 ef 01             	sub    $0x1,%edi
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	eb ec                	jmp    80049b <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  8004af:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8004b2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b5:	e9 fe 02 00 00       	jmp    8007b8 <vprintfmt+0x553>
	if (lflag >= 2)
  8004ba:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8004be:	7f 21                	jg     8004e1 <vprintfmt+0x27c>
	else if (lflag)
  8004c0:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8004c4:	74 79                	je     80053f <vprintfmt+0x2da>
		return va_arg(*ap, long);
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8b 00                	mov    (%eax),%eax
  8004cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ce:	89 c1                	mov    %eax,%ecx
  8004d0:	c1 f9 1f             	sar    $0x1f,%ecx
  8004d3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 40 04             	lea    0x4(%eax),%eax
  8004dc:	89 45 14             	mov    %eax,0x14(%ebp)
  8004df:	eb 17                	jmp    8004f8 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8b 50 04             	mov    0x4(%eax),%edx
  8004e7:	8b 00                	mov    (%eax),%eax
  8004e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f2:	8d 40 08             	lea    0x8(%eax),%eax
  8004f5:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  8004f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800501:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  800504:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800508:	78 50                	js     80055a <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  80050a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80050d:	c1 fa 1f             	sar    $0x1f,%edx
  800510:	89 d0                	mov    %edx,%eax
  800512:	2b 45 e0             	sub    -0x20(%ebp),%eax
  800515:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  800518:	85 d2                	test   %edx,%edx
  80051a:	0f 89 14 02 00 00    	jns    800734 <vprintfmt+0x4cf>
  800520:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800524:	0f 84 0a 02 00 00    	je     800734 <vprintfmt+0x4cf>
				putch('+', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	56                   	push   %esi
  80052e:	6a 2b                	push   $0x2b
  800530:	ff d3                	call   *%ebx
  800532:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800535:	b8 0a 00 00 00       	mov    $0xa,%eax
  80053a:	e9 5c 01 00 00       	jmp    80069b <vprintfmt+0x436>
		return va_arg(*ap, int);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8b 00                	mov    (%eax),%eax
  800544:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800547:	89 c1                	mov    %eax,%ecx
  800549:	c1 f9 1f             	sar    $0x1f,%ecx
  80054c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 40 04             	lea    0x4(%eax),%eax
  800555:	89 45 14             	mov    %eax,0x14(%ebp)
  800558:	eb 9e                	jmp    8004f8 <vprintfmt+0x293>
				putch('-', putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	56                   	push   %esi
  80055e:	6a 2d                	push   $0x2d
  800560:	ff d3                	call   *%ebx
				num = -(long long) num;
  800562:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800565:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800568:	f7 d8                	neg    %eax
  80056a:	83 d2 00             	adc    $0x0,%edx
  80056d:	f7 da                	neg    %edx
  80056f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800572:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800575:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800578:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057d:	e9 19 01 00 00       	jmp    80069b <vprintfmt+0x436>
	if (lflag >= 2)
  800582:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800586:	7f 29                	jg     8005b1 <vprintfmt+0x34c>
	else if (lflag)
  800588:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80058c:	74 44                	je     8005d2 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8b 00                	mov    (%eax),%eax
  800593:	ba 00 00 00 00       	mov    $0x0,%edx
  800598:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80059b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 40 04             	lea    0x4(%eax),%eax
  8005a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ac:	e9 ea 00 00 00       	jmp    80069b <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8b 50 04             	mov    0x4(%eax),%edx
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005bc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 40 08             	lea    0x8(%eax),%eax
  8005c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cd:	e9 c9 00 00 00       	jmp    80069b <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 00                	mov    (%eax),%eax
  8005d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005df:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 40 04             	lea    0x4(%eax),%eax
  8005e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f0:	e9 a6 00 00 00       	jmp    80069b <vprintfmt+0x436>
			putch('0', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	56                   	push   %esi
  8005f9:	6a 30                	push   $0x30
  8005fb:	ff d3                	call   *%ebx
	if (lflag >= 2)
  8005fd:	83 c4 10             	add    $0x10,%esp
  800600:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800604:	7f 26                	jg     80062c <vprintfmt+0x3c7>
	else if (lflag)
  800606:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80060a:	74 3e                	je     80064a <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 00                	mov    (%eax),%eax
  800611:	ba 00 00 00 00       	mov    $0x0,%edx
  800616:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800619:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800625:	b8 08 00 00 00       	mov    $0x8,%eax
  80062a:	eb 6f                	jmp    80069b <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8b 50 04             	mov    0x4(%eax),%edx
  800632:	8b 00                	mov    (%eax),%eax
  800634:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800637:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8d 40 08             	lea    0x8(%eax),%eax
  800640:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800643:	b8 08 00 00 00       	mov    $0x8,%eax
  800648:	eb 51                	jmp    80069b <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	ba 00 00 00 00       	mov    $0x0,%edx
  800654:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800657:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800663:	b8 08 00 00 00       	mov    $0x8,%eax
  800668:	eb 31                	jmp    80069b <vprintfmt+0x436>
			putch('0', putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	56                   	push   %esi
  80066e:	6a 30                	push   $0x30
  800670:	ff d3                	call   *%ebx
			putch('x', putdat);
  800672:	83 c4 08             	add    $0x8,%esp
  800675:	56                   	push   %esi
  800676:	6a 78                	push   $0x78
  800678:	ff d3                	call   *%ebx
			num = (unsigned long long)
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	ba 00 00 00 00       	mov    $0x0,%edx
  800684:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800687:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  80068a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8d 40 04             	lea    0x4(%eax),%eax
  800693:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800696:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80069b:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  80069f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006a2:	89 c1                	mov    %eax,%ecx
  8006a4:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  8006a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006aa:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  8006af:	89 c2                	mov    %eax,%edx
  8006b1:	39 c1                	cmp    %eax,%ecx
  8006b3:	0f 87 85 00 00 00    	ja     80073e <vprintfmt+0x4d9>
		tmp /= base;
  8006b9:	89 d0                	mov    %edx,%eax
  8006bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c0:	f7 f1                	div    %ecx
		len++;
  8006c2:	83 c7 01             	add    $0x1,%edi
  8006c5:	eb e8                	jmp    8006af <vprintfmt+0x44a>
	if (lflag >= 2)
  8006c7:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8006cb:	7f 26                	jg     8006f3 <vprintfmt+0x48e>
	else if (lflag)
  8006cd:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006d1:	74 3e                	je     800711 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 00                	mov    (%eax),%eax
  8006d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006dd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8d 40 04             	lea    0x4(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ec:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f1:	eb a8                	jmp    80069b <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8b 50 04             	mov    0x4(%eax),%edx
  8006f9:	8b 00                	mov    (%eax),%eax
  8006fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006fe:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 40 08             	lea    0x8(%eax),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070a:	b8 10 00 00 00       	mov    $0x10,%eax
  80070f:	eb 8a                	jmp    80069b <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8b 00                	mov    (%eax),%eax
  800716:	ba 00 00 00 00       	mov    $0x0,%edx
  80071b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80071e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800721:	8b 45 14             	mov    0x14(%ebp),%eax
  800724:	8d 40 04             	lea    0x4(%eax),%eax
  800727:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072a:	b8 10 00 00 00       	mov    $0x10,%eax
  80072f:	e9 67 ff ff ff       	jmp    80069b <vprintfmt+0x436>
			base = 10;
  800734:	b8 0a 00 00 00       	mov    $0xa,%eax
  800739:	e9 5d ff ff ff       	jmp    80069b <vprintfmt+0x436>
  80073e:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  800741:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800744:	29 f8                	sub    %edi,%eax
  800746:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  800748:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  80074c:	74 15                	je     800763 <vprintfmt+0x4fe>
		while (width > 0) {
  80074e:	85 ff                	test   %edi,%edi
  800750:	7e 48                	jle    80079a <vprintfmt+0x535>
			putch(padc, putdat);
  800752:	83 ec 08             	sub    $0x8,%esp
  800755:	56                   	push   %esi
  800756:	ff 75 e0             	pushl  -0x20(%ebp)
  800759:	ff d3                	call   *%ebx
			width--;
  80075b:	83 ef 01             	sub    $0x1,%edi
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	eb eb                	jmp    80074e <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800763:	83 ec 0c             	sub    $0xc,%esp
  800766:	6a 2d                	push   $0x2d
  800768:	ff 75 cc             	pushl  -0x34(%ebp)
  80076b:	ff 75 c8             	pushl  -0x38(%ebp)
  80076e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800771:	ff 75 d0             	pushl  -0x30(%ebp)
  800774:	89 f2                	mov    %esi,%edx
  800776:	89 d8                	mov    %ebx,%eax
  800778:	e8 1e fa ff ff       	call   80019b <printnum_helper>
		width -= len;
  80077d:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800780:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800783:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800786:	85 ff                	test   %edi,%edi
  800788:	7e 2e                	jle    8007b8 <vprintfmt+0x553>
			putch(padc, putdat);
  80078a:	83 ec 08             	sub    $0x8,%esp
  80078d:	56                   	push   %esi
  80078e:	6a 20                	push   $0x20
  800790:	ff d3                	call   *%ebx
			width--;
  800792:	83 ef 01             	sub    $0x1,%edi
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	eb ec                	jmp    800786 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  80079a:	83 ec 0c             	sub    $0xc,%esp
  80079d:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a0:	ff 75 cc             	pushl  -0x34(%ebp)
  8007a3:	ff 75 c8             	pushl  -0x38(%ebp)
  8007a6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007a9:	ff 75 d0             	pushl  -0x30(%ebp)
  8007ac:	89 f2                	mov    %esi,%edx
  8007ae:	89 d8                	mov    %ebx,%eax
  8007b0:	e8 e6 f9 ff ff       	call   80019b <printnum_helper>
  8007b5:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  8007b8:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007bb:	83 c7 01             	add    $0x1,%edi
  8007be:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007c2:	83 f8 25             	cmp    $0x25,%eax
  8007c5:	0f 84 b1 fa ff ff    	je     80027c <vprintfmt+0x17>
			if (ch == '\0')
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	0f 84 a1 00 00 00    	je     800874 <vprintfmt+0x60f>
			putch(ch, putdat);
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	56                   	push   %esi
  8007d7:	50                   	push   %eax
  8007d8:	ff d3                	call   *%ebx
  8007da:	83 c4 10             	add    $0x10,%esp
  8007dd:	eb dc                	jmp    8007bb <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	83 c0 04             	add    $0x4,%eax
  8007e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8007ed:	85 ff                	test   %edi,%edi
  8007ef:	74 15                	je     800806 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  8007f1:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  8007f7:	7f 29                	jg     800822 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  8007f9:	0f b6 06             	movzbl (%esi),%eax
  8007fc:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  8007fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800801:	89 45 14             	mov    %eax,0x14(%ebp)
  800804:	eb b2                	jmp    8007b8 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800806:	68 cc 12 80 00       	push   $0x8012cc
  80080b:	68 36 12 80 00       	push   $0x801236
  800810:	56                   	push   %esi
  800811:	53                   	push   %ebx
  800812:	e8 31 fa ff ff       	call   800248 <printfmt>
  800817:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  80081a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80081d:	89 45 14             	mov    %eax,0x14(%ebp)
  800820:	eb 96                	jmp    8007b8 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800822:	68 04 13 80 00       	push   $0x801304
  800827:	68 36 12 80 00       	push   $0x801236
  80082c:	56                   	push   %esi
  80082d:	53                   	push   %ebx
  80082e:	e8 15 fa ff ff       	call   800248 <printfmt>
				*res = -1;
  800833:	c6 07 ff             	movb   $0xff,(%edi)
  800836:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800839:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80083c:	89 45 14             	mov    %eax,0x14(%ebp)
  80083f:	e9 74 ff ff ff       	jmp    8007b8 <vprintfmt+0x553>
			putch(ch, putdat);
  800844:	83 ec 08             	sub    $0x8,%esp
  800847:	56                   	push   %esi
  800848:	6a 25                	push   $0x25
  80084a:	ff d3                	call   *%ebx
			break;
  80084c:	83 c4 10             	add    $0x10,%esp
  80084f:	e9 64 ff ff ff       	jmp    8007b8 <vprintfmt+0x553>
			putch('%', putdat);
  800854:	83 ec 08             	sub    $0x8,%esp
  800857:	56                   	push   %esi
  800858:	6a 25                	push   $0x25
  80085a:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	89 f8                	mov    %edi,%eax
  800861:	eb 03                	jmp    800866 <vprintfmt+0x601>
  800863:	83 e8 01             	sub    $0x1,%eax
  800866:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80086a:	75 f7                	jne    800863 <vprintfmt+0x5fe>
  80086c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80086f:	e9 44 ff ff ff       	jmp    8007b8 <vprintfmt+0x553>
}
  800874:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800877:	5b                   	pop    %ebx
  800878:	5e                   	pop    %esi
  800879:	5f                   	pop    %edi
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	83 ec 18             	sub    $0x18,%esp
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800888:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80088b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800892:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800899:	85 c0                	test   %eax,%eax
  80089b:	74 26                	je     8008c3 <vsnprintf+0x47>
  80089d:	85 d2                	test   %edx,%edx
  80089f:	7e 22                	jle    8008c3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a1:	ff 75 14             	pushl  0x14(%ebp)
  8008a4:	ff 75 10             	pushl  0x10(%ebp)
  8008a7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008aa:	50                   	push   %eax
  8008ab:	68 2b 02 80 00       	push   $0x80022b
  8008b0:	e8 b0 f9 ff ff       	call   800265 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008be:	83 c4 10             	add    $0x10,%esp
}
  8008c1:	c9                   	leave  
  8008c2:	c3                   	ret    
		return -E_INVAL;
  8008c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008c8:	eb f7                	jmp    8008c1 <vsnprintf+0x45>

008008ca <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008d3:	50                   	push   %eax
  8008d4:	ff 75 10             	pushl  0x10(%ebp)
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	ff 75 08             	pushl  0x8(%ebp)
  8008dd:	e8 9a ff ff ff       	call   80087c <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ef:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f3:	74 05                	je     8008fa <strlen+0x16>
		n++;
  8008f5:	83 c0 01             	add    $0x1,%eax
  8008f8:	eb f5                	jmp    8008ef <strlen+0xb>
	return n;
}
  8008fa:	5d                   	pop    %ebp
  8008fb:	c3                   	ret    

008008fc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800902:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800905:	ba 00 00 00 00       	mov    $0x0,%edx
  80090a:	39 c2                	cmp    %eax,%edx
  80090c:	74 0d                	je     80091b <strnlen+0x1f>
  80090e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800912:	74 05                	je     800919 <strnlen+0x1d>
		n++;
  800914:	83 c2 01             	add    $0x1,%edx
  800917:	eb f1                	jmp    80090a <strnlen+0xe>
  800919:	89 d0                	mov    %edx,%eax
	return n;
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	53                   	push   %ebx
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800927:	ba 00 00 00 00       	mov    $0x0,%edx
  80092c:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800930:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800933:	83 c2 01             	add    $0x1,%edx
  800936:	84 c9                	test   %cl,%cl
  800938:	75 f2                	jne    80092c <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80093a:	5b                   	pop    %ebx
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	53                   	push   %ebx
  800941:	83 ec 10             	sub    $0x10,%esp
  800944:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800947:	53                   	push   %ebx
  800948:	e8 97 ff ff ff       	call   8008e4 <strlen>
  80094d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800950:	ff 75 0c             	pushl  0xc(%ebp)
  800953:	01 d8                	add    %ebx,%eax
  800955:	50                   	push   %eax
  800956:	e8 c2 ff ff ff       	call   80091d <strcpy>
	return dst;
}
  80095b:	89 d8                	mov    %ebx,%eax
  80095d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800960:	c9                   	leave  
  800961:	c3                   	ret    

00800962 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096d:	89 c6                	mov    %eax,%esi
  80096f:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800972:	89 c2                	mov    %eax,%edx
  800974:	39 f2                	cmp    %esi,%edx
  800976:	74 11                	je     800989 <strncpy+0x27>
		*dst++ = *src;
  800978:	83 c2 01             	add    $0x1,%edx
  80097b:	0f b6 19             	movzbl (%ecx),%ebx
  80097e:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800981:	80 fb 01             	cmp    $0x1,%bl
  800984:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800987:	eb eb                	jmp    800974 <strncpy+0x12>
	}
	return ret;
}
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	56                   	push   %esi
  800991:	53                   	push   %ebx
  800992:	8b 75 08             	mov    0x8(%ebp),%esi
  800995:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800998:	8b 55 10             	mov    0x10(%ebp),%edx
  80099b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80099d:	85 d2                	test   %edx,%edx
  80099f:	74 21                	je     8009c2 <strlcpy+0x35>
  8009a1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009a5:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009a7:	39 c2                	cmp    %eax,%edx
  8009a9:	74 14                	je     8009bf <strlcpy+0x32>
  8009ab:	0f b6 19             	movzbl (%ecx),%ebx
  8009ae:	84 db                	test   %bl,%bl
  8009b0:	74 0b                	je     8009bd <strlcpy+0x30>
			*dst++ = *src++;
  8009b2:	83 c1 01             	add    $0x1,%ecx
  8009b5:	83 c2 01             	add    $0x1,%edx
  8009b8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009bb:	eb ea                	jmp    8009a7 <strlcpy+0x1a>
  8009bd:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009bf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c2:	29 f0                	sub    %esi,%eax
}
  8009c4:	5b                   	pop    %ebx
  8009c5:	5e                   	pop    %esi
  8009c6:	5d                   	pop    %ebp
  8009c7:	c3                   	ret    

008009c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d1:	0f b6 01             	movzbl (%ecx),%eax
  8009d4:	84 c0                	test   %al,%al
  8009d6:	74 0c                	je     8009e4 <strcmp+0x1c>
  8009d8:	3a 02                	cmp    (%edx),%al
  8009da:	75 08                	jne    8009e4 <strcmp+0x1c>
		p++, q++;
  8009dc:	83 c1 01             	add    $0x1,%ecx
  8009df:	83 c2 01             	add    $0x1,%edx
  8009e2:	eb ed                	jmp    8009d1 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e4:	0f b6 c0             	movzbl %al,%eax
  8009e7:	0f b6 12             	movzbl (%edx),%edx
  8009ea:	29 d0                	sub    %edx,%eax
}
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	53                   	push   %ebx
  8009f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f8:	89 c3                	mov    %eax,%ebx
  8009fa:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009fd:	eb 06                	jmp    800a05 <strncmp+0x17>
		n--, p++, q++;
  8009ff:	83 c0 01             	add    $0x1,%eax
  800a02:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a05:	39 d8                	cmp    %ebx,%eax
  800a07:	74 16                	je     800a1f <strncmp+0x31>
  800a09:	0f b6 08             	movzbl (%eax),%ecx
  800a0c:	84 c9                	test   %cl,%cl
  800a0e:	74 04                	je     800a14 <strncmp+0x26>
  800a10:	3a 0a                	cmp    (%edx),%cl
  800a12:	74 eb                	je     8009ff <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a14:	0f b6 00             	movzbl (%eax),%eax
  800a17:	0f b6 12             	movzbl (%edx),%edx
  800a1a:	29 d0                	sub    %edx,%eax
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    
		return 0;
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a24:	eb f6                	jmp    800a1c <strncmp+0x2e>

00800a26 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a30:	0f b6 10             	movzbl (%eax),%edx
  800a33:	84 d2                	test   %dl,%dl
  800a35:	74 09                	je     800a40 <strchr+0x1a>
		if (*s == c)
  800a37:	38 ca                	cmp    %cl,%dl
  800a39:	74 0a                	je     800a45 <strchr+0x1f>
	for (; *s; s++)
  800a3b:	83 c0 01             	add    $0x1,%eax
  800a3e:	eb f0                	jmp    800a30 <strchr+0xa>
			return (char *) s;
	return 0;
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a51:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a54:	38 ca                	cmp    %cl,%dl
  800a56:	74 09                	je     800a61 <strfind+0x1a>
  800a58:	84 d2                	test   %dl,%dl
  800a5a:	74 05                	je     800a61 <strfind+0x1a>
	for (; *s; s++)
  800a5c:	83 c0 01             	add    $0x1,%eax
  800a5f:	eb f0                	jmp    800a51 <strfind+0xa>
			break;
	return (char *) s;
}
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a6c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a6f:	85 c9                	test   %ecx,%ecx
  800a71:	74 31                	je     800aa4 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a73:	89 f8                	mov    %edi,%eax
  800a75:	09 c8                	or     %ecx,%eax
  800a77:	a8 03                	test   $0x3,%al
  800a79:	75 23                	jne    800a9e <memset+0x3b>
		c &= 0xFF;
  800a7b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a7f:	89 d3                	mov    %edx,%ebx
  800a81:	c1 e3 08             	shl    $0x8,%ebx
  800a84:	89 d0                	mov    %edx,%eax
  800a86:	c1 e0 18             	shl    $0x18,%eax
  800a89:	89 d6                	mov    %edx,%esi
  800a8b:	c1 e6 10             	shl    $0x10,%esi
  800a8e:	09 f0                	or     %esi,%eax
  800a90:	09 c2                	or     %eax,%edx
  800a92:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a94:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a97:	89 d0                	mov    %edx,%eax
  800a99:	fc                   	cld    
  800a9a:	f3 ab                	rep stos %eax,%es:(%edi)
  800a9c:	eb 06                	jmp    800aa4 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa1:	fc                   	cld    
  800aa2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa4:	89 f8                	mov    %edi,%eax
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab9:	39 c6                	cmp    %eax,%esi
  800abb:	73 32                	jae    800aef <memmove+0x44>
  800abd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac0:	39 c2                	cmp    %eax,%edx
  800ac2:	76 2b                	jbe    800aef <memmove+0x44>
		s += n;
		d += n;
  800ac4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac7:	89 fe                	mov    %edi,%esi
  800ac9:	09 ce                	or     %ecx,%esi
  800acb:	09 d6                	or     %edx,%esi
  800acd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad3:	75 0e                	jne    800ae3 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ad5:	83 ef 04             	sub    $0x4,%edi
  800ad8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800adb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ade:	fd                   	std    
  800adf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae1:	eb 09                	jmp    800aec <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ae3:	83 ef 01             	sub    $0x1,%edi
  800ae6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ae9:	fd                   	std    
  800aea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aec:	fc                   	cld    
  800aed:	eb 1a                	jmp    800b09 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aef:	89 c2                	mov    %eax,%edx
  800af1:	09 ca                	or     %ecx,%edx
  800af3:	09 f2                	or     %esi,%edx
  800af5:	f6 c2 03             	test   $0x3,%dl
  800af8:	75 0a                	jne    800b04 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800afa:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800afd:	89 c7                	mov    %eax,%edi
  800aff:	fc                   	cld    
  800b00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b02:	eb 05                	jmp    800b09 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	fc                   	cld    
  800b07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
  800b10:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b13:	ff 75 10             	pushl  0x10(%ebp)
  800b16:	ff 75 0c             	pushl  0xc(%ebp)
  800b19:	ff 75 08             	pushl  0x8(%ebp)
  800b1c:	e8 8a ff ff ff       	call   800aab <memmove>
}
  800b21:	c9                   	leave  
  800b22:	c3                   	ret    

00800b23 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2e:	89 c6                	mov    %eax,%esi
  800b30:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b33:	39 f0                	cmp    %esi,%eax
  800b35:	74 1c                	je     800b53 <memcmp+0x30>
		if (*s1 != *s2)
  800b37:	0f b6 08             	movzbl (%eax),%ecx
  800b3a:	0f b6 1a             	movzbl (%edx),%ebx
  800b3d:	38 d9                	cmp    %bl,%cl
  800b3f:	75 08                	jne    800b49 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b41:	83 c0 01             	add    $0x1,%eax
  800b44:	83 c2 01             	add    $0x1,%edx
  800b47:	eb ea                	jmp    800b33 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b49:	0f b6 c1             	movzbl %cl,%eax
  800b4c:	0f b6 db             	movzbl %bl,%ebx
  800b4f:	29 d8                	sub    %ebx,%eax
  800b51:	eb 05                	jmp    800b58 <memcmp+0x35>
	}

	return 0;
  800b53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b65:	89 c2                	mov    %eax,%edx
  800b67:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b6a:	39 d0                	cmp    %edx,%eax
  800b6c:	73 09                	jae    800b77 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6e:	38 08                	cmp    %cl,(%eax)
  800b70:	74 05                	je     800b77 <memfind+0x1b>
	for (; s < ends; s++)
  800b72:	83 c0 01             	add    $0x1,%eax
  800b75:	eb f3                	jmp    800b6a <memfind+0xe>
			break;
	return (void *) s;
}
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b85:	eb 03                	jmp    800b8a <strtol+0x11>
		s++;
  800b87:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b8a:	0f b6 01             	movzbl (%ecx),%eax
  800b8d:	3c 20                	cmp    $0x20,%al
  800b8f:	74 f6                	je     800b87 <strtol+0xe>
  800b91:	3c 09                	cmp    $0x9,%al
  800b93:	74 f2                	je     800b87 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b95:	3c 2b                	cmp    $0x2b,%al
  800b97:	74 2a                	je     800bc3 <strtol+0x4a>
	int neg = 0;
  800b99:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b9e:	3c 2d                	cmp    $0x2d,%al
  800ba0:	74 2b                	je     800bcd <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ba8:	75 0f                	jne    800bb9 <strtol+0x40>
  800baa:	80 39 30             	cmpb   $0x30,(%ecx)
  800bad:	74 28                	je     800bd7 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800baf:	85 db                	test   %ebx,%ebx
  800bb1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb6:	0f 44 d8             	cmove  %eax,%ebx
  800bb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbe:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bc1:	eb 50                	jmp    800c13 <strtol+0x9a>
		s++;
  800bc3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bc6:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcb:	eb d5                	jmp    800ba2 <strtol+0x29>
		s++, neg = 1;
  800bcd:	83 c1 01             	add    $0x1,%ecx
  800bd0:	bf 01 00 00 00       	mov    $0x1,%edi
  800bd5:	eb cb                	jmp    800ba2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bdb:	74 0e                	je     800beb <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bdd:	85 db                	test   %ebx,%ebx
  800bdf:	75 d8                	jne    800bb9 <strtol+0x40>
		s++, base = 8;
  800be1:	83 c1 01             	add    $0x1,%ecx
  800be4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800be9:	eb ce                	jmp    800bb9 <strtol+0x40>
		s += 2, base = 16;
  800beb:	83 c1 02             	add    $0x2,%ecx
  800bee:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bf3:	eb c4                	jmp    800bb9 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bf5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bf8:	89 f3                	mov    %esi,%ebx
  800bfa:	80 fb 19             	cmp    $0x19,%bl
  800bfd:	77 29                	ja     800c28 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bff:	0f be d2             	movsbl %dl,%edx
  800c02:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c05:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c08:	7d 30                	jge    800c3a <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c0a:	83 c1 01             	add    $0x1,%ecx
  800c0d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c11:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c13:	0f b6 11             	movzbl (%ecx),%edx
  800c16:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c19:	89 f3                	mov    %esi,%ebx
  800c1b:	80 fb 09             	cmp    $0x9,%bl
  800c1e:	77 d5                	ja     800bf5 <strtol+0x7c>
			dig = *s - '0';
  800c20:	0f be d2             	movsbl %dl,%edx
  800c23:	83 ea 30             	sub    $0x30,%edx
  800c26:	eb dd                	jmp    800c05 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800c28:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c2b:	89 f3                	mov    %esi,%ebx
  800c2d:	80 fb 19             	cmp    $0x19,%bl
  800c30:	77 08                	ja     800c3a <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c32:	0f be d2             	movsbl %dl,%edx
  800c35:	83 ea 37             	sub    $0x37,%edx
  800c38:	eb cb                	jmp    800c05 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3e:	74 05                	je     800c45 <strtol+0xcc>
		*endptr = (char *) s;
  800c40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c43:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c45:	89 c2                	mov    %eax,%edx
  800c47:	f7 da                	neg    %edx
  800c49:	85 ff                	test   %edi,%edi
  800c4b:	0f 45 c2             	cmovne %edx,%eax
}
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    

00800c53 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c59:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c64:	89 c3                	mov    %eax,%ebx
  800c66:	89 c7                	mov    %eax,%edi
  800c68:	89 c6                	mov    %eax,%esi
  800c6a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5f                   	pop    %edi
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	57                   	push   %edi
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c77:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7c:	b8 01 00 00 00       	mov    $0x1,%eax
  800c81:	89 d1                	mov    %edx,%ecx
  800c83:	89 d3                	mov    %edx,%ebx
  800c85:	89 d7                	mov    %edx,%edi
  800c87:	89 d6                	mov    %edx,%esi
  800c89:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c8b:	5b                   	pop    %ebx
  800c8c:	5e                   	pop    %esi
  800c8d:	5f                   	pop    %edi
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	57                   	push   %edi
  800c94:	56                   	push   %esi
  800c95:	53                   	push   %ebx
  800c96:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca1:	b8 03 00 00 00       	mov    $0x3,%eax
  800ca6:	89 cb                	mov    %ecx,%ebx
  800ca8:	89 cf                	mov    %ecx,%edi
  800caa:	89 ce                	mov    %ecx,%esi
  800cac:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7f 08                	jg     800cba <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	50                   	push   %eax
  800cbe:	6a 03                	push   $0x3
  800cc0:	68 e4 14 80 00       	push   $0x8014e4
  800cc5:	6a 23                	push   $0x23
  800cc7:	68 01 15 80 00       	push   $0x801501
  800ccc:	e8 2e 02 00 00       	call   800eff <_panic>

00800cd1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdc:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce1:	89 d1                	mov    %edx,%ecx
  800ce3:	89 d3                	mov    %edx,%ebx
  800ce5:	89 d7                	mov    %edx,%edi
  800ce7:	89 d6                	mov    %edx,%esi
  800ce9:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <sys_yield>:

void
sys_yield(void)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf6:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d00:	89 d1                	mov    %edx,%ecx
  800d02:	89 d3                	mov    %edx,%ebx
  800d04:	89 d7                	mov    %edx,%edi
  800d06:	89 d6                	mov    %edx,%esi
  800d08:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d18:	be 00 00 00 00       	mov    $0x0,%esi
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	b8 04 00 00 00       	mov    $0x4,%eax
  800d28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2b:	89 f7                	mov    %esi,%edi
  800d2d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	7f 08                	jg     800d3b <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3b:	83 ec 0c             	sub    $0xc,%esp
  800d3e:	50                   	push   %eax
  800d3f:	6a 04                	push   $0x4
  800d41:	68 e4 14 80 00       	push   $0x8014e4
  800d46:	6a 23                	push   $0x23
  800d48:	68 01 15 80 00       	push   $0x801501
  800d4d:	e8 ad 01 00 00       	call   800eff <_panic>

00800d52 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	b8 05 00 00 00       	mov    $0x5,%eax
  800d66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d69:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d6c:	8b 75 18             	mov    0x18(%ebp),%esi
  800d6f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d71:	85 c0                	test   %eax,%eax
  800d73:	7f 08                	jg     800d7d <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	50                   	push   %eax
  800d81:	6a 05                	push   $0x5
  800d83:	68 e4 14 80 00       	push   $0x8014e4
  800d88:	6a 23                	push   $0x23
  800d8a:	68 01 15 80 00       	push   $0x801501
  800d8f:	e8 6b 01 00 00       	call   800eff <_panic>

00800d94 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	57                   	push   %edi
  800d98:	56                   	push   %esi
  800d99:	53                   	push   %ebx
  800d9a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d9d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da2:	8b 55 08             	mov    0x8(%ebp),%edx
  800da5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da8:	b8 06 00 00 00       	mov    $0x6,%eax
  800dad:	89 df                	mov    %ebx,%edi
  800daf:	89 de                	mov    %ebx,%esi
  800db1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db3:	85 c0                	test   %eax,%eax
  800db5:	7f 08                	jg     800dbf <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	50                   	push   %eax
  800dc3:	6a 06                	push   $0x6
  800dc5:	68 e4 14 80 00       	push   $0x8014e4
  800dca:	6a 23                	push   $0x23
  800dcc:	68 01 15 80 00       	push   $0x801501
  800dd1:	e8 29 01 00 00       	call   800eff <_panic>

00800dd6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	57                   	push   %edi
  800dda:	56                   	push   %esi
  800ddb:	53                   	push   %ebx
  800ddc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ddf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dea:	b8 08 00 00 00       	mov    $0x8,%eax
  800def:	89 df                	mov    %ebx,%edi
  800df1:	89 de                	mov    %ebx,%esi
  800df3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800df5:	85 c0                	test   %eax,%eax
  800df7:	7f 08                	jg     800e01 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	50                   	push   %eax
  800e05:	6a 08                	push   $0x8
  800e07:	68 e4 14 80 00       	push   $0x8014e4
  800e0c:	6a 23                	push   $0x23
  800e0e:	68 01 15 80 00       	push   $0x801501
  800e13:	e8 e7 00 00 00       	call   800eff <_panic>

00800e18 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	57                   	push   %edi
  800e1c:	56                   	push   %esi
  800e1d:	53                   	push   %ebx
  800e1e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2c:	b8 09 00 00 00       	mov    $0x9,%eax
  800e31:	89 df                	mov    %ebx,%edi
  800e33:	89 de                	mov    %ebx,%esi
  800e35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e37:	85 c0                	test   %eax,%eax
  800e39:	7f 08                	jg     800e43 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e43:	83 ec 0c             	sub    $0xc,%esp
  800e46:	50                   	push   %eax
  800e47:	6a 09                	push   $0x9
  800e49:	68 e4 14 80 00       	push   $0x8014e4
  800e4e:	6a 23                	push   $0x23
  800e50:	68 01 15 80 00       	push   $0x801501
  800e55:	e8 a5 00 00 00       	call   800eff <_panic>

00800e5a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	57                   	push   %edi
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e60:	8b 55 08             	mov    0x8(%ebp),%edx
  800e63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e66:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e6b:	be 00 00 00 00       	mov    $0x0,%esi
  800e70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e73:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e76:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	57                   	push   %edi
  800e81:	56                   	push   %esi
  800e82:	53                   	push   %ebx
  800e83:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e8b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e93:	89 cb                	mov    %ecx,%ebx
  800e95:	89 cf                	mov    %ecx,%edi
  800e97:	89 ce                	mov    %ecx,%esi
  800e99:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	7f 08                	jg     800ea7 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea7:	83 ec 0c             	sub    $0xc,%esp
  800eaa:	50                   	push   %eax
  800eab:	6a 0c                	push   $0xc
  800ead:	68 e4 14 80 00       	push   $0x8014e4
  800eb2:	6a 23                	push   $0x23
  800eb4:	68 01 15 80 00       	push   $0x801501
  800eb9:	e8 41 00 00 00       	call   800eff <_panic>

00800ebe <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ec4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ed4:	89 df                	mov    %ebx,%edi
  800ed6:	89 de                	mov    %ebx,%esi
  800ed8:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800eda:	5b                   	pop    %ebx
  800edb:	5e                   	pop    %esi
  800edc:	5f                   	pop    %edi
  800edd:	5d                   	pop    %ebp
  800ede:	c3                   	ret    

00800edf <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ee5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eea:	8b 55 08             	mov    0x8(%ebp),%edx
  800eed:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ef2:	89 cb                	mov    %ecx,%ebx
  800ef4:	89 cf                	mov    %ecx,%edi
  800ef6:	89 ce                	mov    %ecx,%esi
  800ef8:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800efa:	5b                   	pop    %ebx
  800efb:	5e                   	pop    %esi
  800efc:	5f                   	pop    %edi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800f04:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f07:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f0d:	e8 bf fd ff ff       	call   800cd1 <sys_getenvid>
  800f12:	83 ec 0c             	sub    $0xc,%esp
  800f15:	ff 75 0c             	pushl  0xc(%ebp)
  800f18:	ff 75 08             	pushl  0x8(%ebp)
  800f1b:	56                   	push   %esi
  800f1c:	50                   	push   %eax
  800f1d:	68 10 15 80 00       	push   $0x801510
  800f22:	e8 60 f2 ff ff       	call   800187 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f27:	83 c4 18             	add    $0x18,%esp
  800f2a:	53                   	push   %ebx
  800f2b:	ff 75 10             	pushl  0x10(%ebp)
  800f2e:	e8 03 f2 ff ff       	call   800136 <vcprintf>
	cprintf("\n");
  800f33:	c7 04 24 34 15 80 00 	movl   $0x801534,(%esp)
  800f3a:	e8 48 f2 ff ff       	call   800187 <cprintf>
  800f3f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f42:	cc                   	int3   
  800f43:	eb fd                	jmp    800f42 <_panic+0x43>
  800f45:	66 90                	xchg   %ax,%ax
  800f47:	66 90                	xchg   %ax,%ax
  800f49:	66 90                	xchg   %ax,%ax
  800f4b:	66 90                	xchg   %ax,%ax
  800f4d:	66 90                	xchg   %ax,%ax
  800f4f:	90                   	nop

00800f50 <__udivdi3>:
  800f50:	55                   	push   %ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 1c             	sub    $0x1c,%esp
  800f57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f5b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f63:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f67:	85 d2                	test   %edx,%edx
  800f69:	75 4d                	jne    800fb8 <__udivdi3+0x68>
  800f6b:	39 f3                	cmp    %esi,%ebx
  800f6d:	76 19                	jbe    800f88 <__udivdi3+0x38>
  800f6f:	31 ff                	xor    %edi,%edi
  800f71:	89 e8                	mov    %ebp,%eax
  800f73:	89 f2                	mov    %esi,%edx
  800f75:	f7 f3                	div    %ebx
  800f77:	89 fa                	mov    %edi,%edx
  800f79:	83 c4 1c             	add    $0x1c,%esp
  800f7c:	5b                   	pop    %ebx
  800f7d:	5e                   	pop    %esi
  800f7e:	5f                   	pop    %edi
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    
  800f81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f88:	89 d9                	mov    %ebx,%ecx
  800f8a:	85 db                	test   %ebx,%ebx
  800f8c:	75 0b                	jne    800f99 <__udivdi3+0x49>
  800f8e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f93:	31 d2                	xor    %edx,%edx
  800f95:	f7 f3                	div    %ebx
  800f97:	89 c1                	mov    %eax,%ecx
  800f99:	31 d2                	xor    %edx,%edx
  800f9b:	89 f0                	mov    %esi,%eax
  800f9d:	f7 f1                	div    %ecx
  800f9f:	89 c6                	mov    %eax,%esi
  800fa1:	89 e8                	mov    %ebp,%eax
  800fa3:	89 f7                	mov    %esi,%edi
  800fa5:	f7 f1                	div    %ecx
  800fa7:	89 fa                	mov    %edi,%edx
  800fa9:	83 c4 1c             	add    $0x1c,%esp
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    
  800fb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb8:	39 f2                	cmp    %esi,%edx
  800fba:	77 1c                	ja     800fd8 <__udivdi3+0x88>
  800fbc:	0f bd fa             	bsr    %edx,%edi
  800fbf:	83 f7 1f             	xor    $0x1f,%edi
  800fc2:	75 2c                	jne    800ff0 <__udivdi3+0xa0>
  800fc4:	39 f2                	cmp    %esi,%edx
  800fc6:	72 06                	jb     800fce <__udivdi3+0x7e>
  800fc8:	31 c0                	xor    %eax,%eax
  800fca:	39 eb                	cmp    %ebp,%ebx
  800fcc:	77 a9                	ja     800f77 <__udivdi3+0x27>
  800fce:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd3:	eb a2                	jmp    800f77 <__udivdi3+0x27>
  800fd5:	8d 76 00             	lea    0x0(%esi),%esi
  800fd8:	31 ff                	xor    %edi,%edi
  800fda:	31 c0                	xor    %eax,%eax
  800fdc:	89 fa                	mov    %edi,%edx
  800fde:	83 c4 1c             	add    $0x1c,%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    
  800fe6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fed:	8d 76 00             	lea    0x0(%esi),%esi
  800ff0:	89 f9                	mov    %edi,%ecx
  800ff2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ff7:	29 f8                	sub    %edi,%eax
  800ff9:	d3 e2                	shl    %cl,%edx
  800ffb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fff:	89 c1                	mov    %eax,%ecx
  801001:	89 da                	mov    %ebx,%edx
  801003:	d3 ea                	shr    %cl,%edx
  801005:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801009:	09 d1                	or     %edx,%ecx
  80100b:	89 f2                	mov    %esi,%edx
  80100d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801011:	89 f9                	mov    %edi,%ecx
  801013:	d3 e3                	shl    %cl,%ebx
  801015:	89 c1                	mov    %eax,%ecx
  801017:	d3 ea                	shr    %cl,%edx
  801019:	89 f9                	mov    %edi,%ecx
  80101b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80101f:	89 eb                	mov    %ebp,%ebx
  801021:	d3 e6                	shl    %cl,%esi
  801023:	89 c1                	mov    %eax,%ecx
  801025:	d3 eb                	shr    %cl,%ebx
  801027:	09 de                	or     %ebx,%esi
  801029:	89 f0                	mov    %esi,%eax
  80102b:	f7 74 24 08          	divl   0x8(%esp)
  80102f:	89 d6                	mov    %edx,%esi
  801031:	89 c3                	mov    %eax,%ebx
  801033:	f7 64 24 0c          	mull   0xc(%esp)
  801037:	39 d6                	cmp    %edx,%esi
  801039:	72 15                	jb     801050 <__udivdi3+0x100>
  80103b:	89 f9                	mov    %edi,%ecx
  80103d:	d3 e5                	shl    %cl,%ebp
  80103f:	39 c5                	cmp    %eax,%ebp
  801041:	73 04                	jae    801047 <__udivdi3+0xf7>
  801043:	39 d6                	cmp    %edx,%esi
  801045:	74 09                	je     801050 <__udivdi3+0x100>
  801047:	89 d8                	mov    %ebx,%eax
  801049:	31 ff                	xor    %edi,%edi
  80104b:	e9 27 ff ff ff       	jmp    800f77 <__udivdi3+0x27>
  801050:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801053:	31 ff                	xor    %edi,%edi
  801055:	e9 1d ff ff ff       	jmp    800f77 <__udivdi3+0x27>
  80105a:	66 90                	xchg   %ax,%ax
  80105c:	66 90                	xchg   %ax,%ax
  80105e:	66 90                	xchg   %ax,%ax

00801060 <__umoddi3>:
  801060:	55                   	push   %ebp
  801061:	57                   	push   %edi
  801062:	56                   	push   %esi
  801063:	53                   	push   %ebx
  801064:	83 ec 1c             	sub    $0x1c,%esp
  801067:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80106b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80106f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801077:	89 da                	mov    %ebx,%edx
  801079:	85 c0                	test   %eax,%eax
  80107b:	75 43                	jne    8010c0 <__umoddi3+0x60>
  80107d:	39 df                	cmp    %ebx,%edi
  80107f:	76 17                	jbe    801098 <__umoddi3+0x38>
  801081:	89 f0                	mov    %esi,%eax
  801083:	f7 f7                	div    %edi
  801085:	89 d0                	mov    %edx,%eax
  801087:	31 d2                	xor    %edx,%edx
  801089:	83 c4 1c             	add    $0x1c,%esp
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5f                   	pop    %edi
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    
  801091:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801098:	89 fd                	mov    %edi,%ebp
  80109a:	85 ff                	test   %edi,%edi
  80109c:	75 0b                	jne    8010a9 <__umoddi3+0x49>
  80109e:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a3:	31 d2                	xor    %edx,%edx
  8010a5:	f7 f7                	div    %edi
  8010a7:	89 c5                	mov    %eax,%ebp
  8010a9:	89 d8                	mov    %ebx,%eax
  8010ab:	31 d2                	xor    %edx,%edx
  8010ad:	f7 f5                	div    %ebp
  8010af:	89 f0                	mov    %esi,%eax
  8010b1:	f7 f5                	div    %ebp
  8010b3:	89 d0                	mov    %edx,%eax
  8010b5:	eb d0                	jmp    801087 <__umoddi3+0x27>
  8010b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010be:	66 90                	xchg   %ax,%ax
  8010c0:	89 f1                	mov    %esi,%ecx
  8010c2:	39 d8                	cmp    %ebx,%eax
  8010c4:	76 0a                	jbe    8010d0 <__umoddi3+0x70>
  8010c6:	89 f0                	mov    %esi,%eax
  8010c8:	83 c4 1c             	add    $0x1c,%esp
  8010cb:	5b                   	pop    %ebx
  8010cc:	5e                   	pop    %esi
  8010cd:	5f                   	pop    %edi
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    
  8010d0:	0f bd e8             	bsr    %eax,%ebp
  8010d3:	83 f5 1f             	xor    $0x1f,%ebp
  8010d6:	75 20                	jne    8010f8 <__umoddi3+0x98>
  8010d8:	39 d8                	cmp    %ebx,%eax
  8010da:	0f 82 b0 00 00 00    	jb     801190 <__umoddi3+0x130>
  8010e0:	39 f7                	cmp    %esi,%edi
  8010e2:	0f 86 a8 00 00 00    	jbe    801190 <__umoddi3+0x130>
  8010e8:	89 c8                	mov    %ecx,%eax
  8010ea:	83 c4 1c             	add    $0x1c,%esp
  8010ed:	5b                   	pop    %ebx
  8010ee:	5e                   	pop    %esi
  8010ef:	5f                   	pop    %edi
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    
  8010f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010f8:	89 e9                	mov    %ebp,%ecx
  8010fa:	ba 20 00 00 00       	mov    $0x20,%edx
  8010ff:	29 ea                	sub    %ebp,%edx
  801101:	d3 e0                	shl    %cl,%eax
  801103:	89 44 24 08          	mov    %eax,0x8(%esp)
  801107:	89 d1                	mov    %edx,%ecx
  801109:	89 f8                	mov    %edi,%eax
  80110b:	d3 e8                	shr    %cl,%eax
  80110d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801111:	89 54 24 04          	mov    %edx,0x4(%esp)
  801115:	8b 54 24 04          	mov    0x4(%esp),%edx
  801119:	09 c1                	or     %eax,%ecx
  80111b:	89 d8                	mov    %ebx,%eax
  80111d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801121:	89 e9                	mov    %ebp,%ecx
  801123:	d3 e7                	shl    %cl,%edi
  801125:	89 d1                	mov    %edx,%ecx
  801127:	d3 e8                	shr    %cl,%eax
  801129:	89 e9                	mov    %ebp,%ecx
  80112b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80112f:	d3 e3                	shl    %cl,%ebx
  801131:	89 c7                	mov    %eax,%edi
  801133:	89 d1                	mov    %edx,%ecx
  801135:	89 f0                	mov    %esi,%eax
  801137:	d3 e8                	shr    %cl,%eax
  801139:	89 e9                	mov    %ebp,%ecx
  80113b:	89 fa                	mov    %edi,%edx
  80113d:	d3 e6                	shl    %cl,%esi
  80113f:	09 d8                	or     %ebx,%eax
  801141:	f7 74 24 08          	divl   0x8(%esp)
  801145:	89 d1                	mov    %edx,%ecx
  801147:	89 f3                	mov    %esi,%ebx
  801149:	f7 64 24 0c          	mull   0xc(%esp)
  80114d:	89 c6                	mov    %eax,%esi
  80114f:	89 d7                	mov    %edx,%edi
  801151:	39 d1                	cmp    %edx,%ecx
  801153:	72 06                	jb     80115b <__umoddi3+0xfb>
  801155:	75 10                	jne    801167 <__umoddi3+0x107>
  801157:	39 c3                	cmp    %eax,%ebx
  801159:	73 0c                	jae    801167 <__umoddi3+0x107>
  80115b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80115f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801163:	89 d7                	mov    %edx,%edi
  801165:	89 c6                	mov    %eax,%esi
  801167:	89 ca                	mov    %ecx,%edx
  801169:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80116e:	29 f3                	sub    %esi,%ebx
  801170:	19 fa                	sbb    %edi,%edx
  801172:	89 d0                	mov    %edx,%eax
  801174:	d3 e0                	shl    %cl,%eax
  801176:	89 e9                	mov    %ebp,%ecx
  801178:	d3 eb                	shr    %cl,%ebx
  80117a:	d3 ea                	shr    %cl,%edx
  80117c:	09 d8                	or     %ebx,%eax
  80117e:	83 c4 1c             	add    $0x1c,%esp
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5f                   	pop    %edi
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    
  801186:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80118d:	8d 76 00             	lea    0x0(%esi),%esi
  801190:	89 da                	mov    %ebx,%edx
  801192:	29 fe                	sub    %edi,%esi
  801194:	19 c2                	sbb    %eax,%edx
  801196:	89 f1                	mov    %esi,%ecx
  801198:	89 c8                	mov    %ecx,%eax
  80119a:	e9 4b ff ff ff       	jmp    8010ea <__umoddi3+0x8a>
