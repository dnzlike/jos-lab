
obj/user/spin:     file format elf32-i386


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

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 e0 11 80 00       	push   $0x8011e0
  80003f:	e8 5e 01 00 00       	call   8001a2 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 d1 0e 00 00       	call   800f1a <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 58 12 80 00       	push   $0x801258
  800058:	e8 45 01 00 00       	call   8001a2 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 08 12 80 00       	push   $0x801208
  80006c:	e8 31 01 00 00       	call   8001a2 <cprintf>
	sys_yield();
  800071:	e8 95 0c 00 00       	call   800d0b <sys_yield>
	sys_yield();
  800076:	e8 90 0c 00 00       	call   800d0b <sys_yield>
	sys_yield();
  80007b:	e8 8b 0c 00 00       	call   800d0b <sys_yield>
	sys_yield();
  800080:	e8 86 0c 00 00       	call   800d0b <sys_yield>
	sys_yield();
  800085:	e8 81 0c 00 00       	call   800d0b <sys_yield>
	sys_yield();
  80008a:	e8 7c 0c 00 00       	call   800d0b <sys_yield>
	sys_yield();
  80008f:	e8 77 0c 00 00       	call   800d0b <sys_yield>
	sys_yield();
  800094:	e8 72 0c 00 00       	call   800d0b <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 30 12 80 00 	movl   $0x801230,(%esp)
  8000a0:	e8 fd 00 00 00       	call   8001a2 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 fe 0b 00 00       	call   800cab <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
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
  8000c0:	e8 27 0c 00 00       	call   800cec <sys_getenvid>
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
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

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
  800103:	e8 a3 0b 00 00       	call   800cab <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	53                   	push   %ebx
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800117:	8b 13                	mov    (%ebx),%edx
  800119:	8d 42 01             	lea    0x1(%edx),%eax
  80011c:	89 03                	mov    %eax,(%ebx)
  80011e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800121:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800125:	3d ff 00 00 00       	cmp    $0xff,%eax
  80012a:	74 09                	je     800135 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80012c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800130:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800133:	c9                   	leave  
  800134:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800135:	83 ec 08             	sub    $0x8,%esp
  800138:	68 ff 00 00 00       	push   $0xff
  80013d:	8d 43 08             	lea    0x8(%ebx),%eax
  800140:	50                   	push   %eax
  800141:	e8 28 0b 00 00       	call   800c6e <sys_cputs>
		b->idx = 0;
  800146:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014c:	83 c4 10             	add    $0x10,%esp
  80014f:	eb db                	jmp    80012c <putch+0x1f>

00800151 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800161:	00 00 00 
	b.cnt = 0;
  800164:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017a:	50                   	push   %eax
  80017b:	68 0d 01 80 00       	push   $0x80010d
  800180:	e8 fb 00 00 00       	call   800280 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800185:	83 c4 08             	add    $0x8,%esp
  800188:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800194:	50                   	push   %eax
  800195:	e8 d4 0a 00 00       	call   800c6e <sys_cputs>

	return b.cnt;
}
  80019a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ab:	50                   	push   %eax
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	e8 9d ff ff ff       	call   800151 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 1c             	sub    $0x1c,%esp
  8001bf:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001c2:	89 d3                	mov    %edx,%ebx
  8001c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c7:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8001cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  8001d0:	89 c2                	mov    %eax,%edx
  8001d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001da:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001dd:	39 c6                	cmp    %eax,%esi
  8001df:	89 f8                	mov    %edi,%eax
  8001e1:	19 c8                	sbb    %ecx,%eax
  8001e3:	73 32                	jae    800217 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 04             	sub    $0x4,%esp
  8001ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	e8 a7 0e 00 00       	call   8010a0 <__umoddi3>
  8001f9:	83 c4 14             	add    $0x14,%esp
  8001fc:	0f be 80 80 12 80 00 	movsbl 0x801280(%eax),%eax
  800203:	50                   	push   %eax
  800204:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800207:	ff d0                	call   *%eax
	return remain - 1;
  800209:	8b 45 14             	mov    0x14(%ebp),%eax
  80020c:	83 e8 01             	sub    $0x1,%eax
}
  80020f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800212:	5b                   	pop    %ebx
  800213:	5e                   	pop    %esi
  800214:	5f                   	pop    %edi
  800215:	5d                   	pop    %ebp
  800216:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  800217:	83 ec 0c             	sub    $0xc,%esp
  80021a:	ff 75 18             	pushl  0x18(%ebp)
  80021d:	ff 75 14             	pushl  0x14(%ebp)
  800220:	ff 75 d8             	pushl  -0x28(%ebp)
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	51                   	push   %ecx
  800227:	52                   	push   %edx
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	e8 61 0d 00 00       	call   800f90 <__udivdi3>
  80022f:	83 c4 18             	add    $0x18,%esp
  800232:	52                   	push   %edx
  800233:	50                   	push   %eax
  800234:	89 da                	mov    %ebx,%edx
  800236:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800239:	e8 78 ff ff ff       	call   8001b6 <printnum_helper>
  80023e:	89 45 14             	mov    %eax,0x14(%ebp)
  800241:	83 c4 20             	add    $0x20,%esp
  800244:	eb 9f                	jmp    8001e5 <printnum_helper+0x2f>

00800246 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
  800249:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800250:	8b 10                	mov    (%eax),%edx
  800252:	3b 50 04             	cmp    0x4(%eax),%edx
  800255:	73 0a                	jae    800261 <sprintputch+0x1b>
		*b->buf++ = ch;
  800257:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025a:	89 08                	mov    %ecx,(%eax)
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	88 02                	mov    %al,(%edx)
}
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <printfmt>:
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800269:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026c:	50                   	push   %eax
  80026d:	ff 75 10             	pushl  0x10(%ebp)
  800270:	ff 75 0c             	pushl  0xc(%ebp)
  800273:	ff 75 08             	pushl  0x8(%ebp)
  800276:	e8 05 00 00 00       	call   800280 <vprintfmt>
}
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	c9                   	leave  
  80027f:	c3                   	ret    

00800280 <vprintfmt>:
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 3c             	sub    $0x3c,%esp
  800289:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80028c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80028f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800292:	e9 3f 05 00 00       	jmp    8007d6 <vprintfmt+0x556>
		padc = ' ';
  800297:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  80029b:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  8002a2:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8002a9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  8002b0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  8002b7:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8002be:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c3:	8d 47 01             	lea    0x1(%edi),%eax
  8002c6:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002c9:	0f b6 17             	movzbl (%edi),%edx
  8002cc:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002cf:	3c 55                	cmp    $0x55,%al
  8002d1:	0f 87 98 05 00 00    	ja     80086f <vprintfmt+0x5ef>
  8002d7:	0f b6 c0             	movzbl %al,%eax
  8002da:	ff 24 85 c0 13 80 00 	jmp    *0x8013c0(,%eax,4)
  8002e1:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  8002e4:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8002e8:	eb d9                	jmp    8002c3 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8002ea:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  8002ed:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  8002f4:	eb cd                	jmp    8002c3 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8002f6:	0f b6 d2             	movzbl %dl,%edx
  8002f9:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800301:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  800304:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800307:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80030b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80030e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800311:	83 fb 09             	cmp    $0x9,%ebx
  800314:	77 5c                	ja     800372 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  800316:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800319:	eb e9                	jmp    800304 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  80031b:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  80031e:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  800322:	eb 9f                	jmp    8002c3 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  800324:	8b 45 14             	mov    0x14(%ebp),%eax
  800327:	8b 00                	mov    (%eax),%eax
  800329:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80032c:	8b 45 14             	mov    0x14(%ebp),%eax
  80032f:	8d 40 04             	lea    0x4(%eax),%eax
  800332:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  800338:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80033c:	79 85                	jns    8002c3 <vprintfmt+0x43>
				width = precision, precision = -1;
  80033e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800341:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800344:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80034b:	e9 73 ff ff ff       	jmp    8002c3 <vprintfmt+0x43>
  800350:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800353:	85 c0                	test   %eax,%eax
  800355:	0f 48 c1             	cmovs  %ecx,%eax
  800358:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80035e:	e9 60 ff ff ff       	jmp    8002c3 <vprintfmt+0x43>
  800363:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  800366:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  80036d:	e9 51 ff ff ff       	jmp    8002c3 <vprintfmt+0x43>
  800372:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800375:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800378:	eb be                	jmp    800338 <vprintfmt+0xb8>
			lflag++;
  80037a:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80037e:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  800381:	e9 3d ff ff ff       	jmp    8002c3 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  800386:	8b 45 14             	mov    0x14(%ebp),%eax
  800389:	8d 78 04             	lea    0x4(%eax),%edi
  80038c:	83 ec 08             	sub    $0x8,%esp
  80038f:	56                   	push   %esi
  800390:	ff 30                	pushl  (%eax)
  800392:	ff d3                	call   *%ebx
			break;
  800394:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800397:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80039a:	e9 34 04 00 00       	jmp    8007d3 <vprintfmt+0x553>
			err = va_arg(ap, int);
  80039f:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a2:	8d 78 04             	lea    0x4(%eax),%edi
  8003a5:	8b 00                	mov    (%eax),%eax
  8003a7:	99                   	cltd   
  8003a8:	31 d0                	xor    %edx,%eax
  8003aa:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ac:	83 f8 08             	cmp    $0x8,%eax
  8003af:	7f 23                	jg     8003d4 <vprintfmt+0x154>
  8003b1:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  8003b8:	85 d2                	test   %edx,%edx
  8003ba:	74 18                	je     8003d4 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  8003bc:	52                   	push   %edx
  8003bd:	68 a1 12 80 00       	push   $0x8012a1
  8003c2:	56                   	push   %esi
  8003c3:	53                   	push   %ebx
  8003c4:	e8 9a fe ff ff       	call   800263 <printfmt>
  8003c9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003cc:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003cf:	e9 ff 03 00 00       	jmp    8007d3 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  8003d4:	50                   	push   %eax
  8003d5:	68 98 12 80 00       	push   $0x801298
  8003da:	56                   	push   %esi
  8003db:	53                   	push   %ebx
  8003dc:	e8 82 fe ff ff       	call   800263 <printfmt>
  8003e1:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e4:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003e7:	e9 e7 03 00 00       	jmp    8007d3 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	83 c0 04             	add    $0x4,%eax
  8003f2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f8:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8003fa:	85 c9                	test   %ecx,%ecx
  8003fc:	b8 91 12 80 00       	mov    $0x801291,%eax
  800401:	0f 45 c1             	cmovne %ecx,%eax
  800404:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800407:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80040b:	7e 06                	jle    800413 <vprintfmt+0x193>
  80040d:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800411:	75 0d                	jne    800420 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800413:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800416:	89 c7                	mov    %eax,%edi
  800418:	03 45 d8             	add    -0x28(%ebp),%eax
  80041b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041e:	eb 53                	jmp    800473 <vprintfmt+0x1f3>
  800420:	83 ec 08             	sub    $0x8,%esp
  800423:	ff 75 e0             	pushl  -0x20(%ebp)
  800426:	50                   	push   %eax
  800427:	e8 eb 04 00 00       	call   800917 <strnlen>
  80042c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80042f:	29 c1                	sub    %eax,%ecx
  800431:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  800434:	83 c4 10             	add    $0x10,%esp
  800437:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800439:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  80043d:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800440:	eb 0f                	jmp    800451 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	56                   	push   %esi
  800446:	ff 75 d8             	pushl  -0x28(%ebp)
  800449:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	83 ef 01             	sub    $0x1,%edi
  80044e:	83 c4 10             	add    $0x10,%esp
  800451:	85 ff                	test   %edi,%edi
  800453:	7f ed                	jg     800442 <vprintfmt+0x1c2>
  800455:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800458:	85 c9                	test   %ecx,%ecx
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	0f 49 c1             	cmovns %ecx,%eax
  800462:	29 c1                	sub    %eax,%ecx
  800464:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800467:	eb aa                	jmp    800413 <vprintfmt+0x193>
					putch(ch, putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	56                   	push   %esi
  80046d:	52                   	push   %edx
  80046e:	ff d3                	call   *%ebx
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800476:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800478:	83 c7 01             	add    $0x1,%edi
  80047b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80047f:	0f be d0             	movsbl %al,%edx
  800482:	85 d2                	test   %edx,%edx
  800484:	74 2e                	je     8004b4 <vprintfmt+0x234>
  800486:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048a:	78 06                	js     800492 <vprintfmt+0x212>
  80048c:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800490:	78 1e                	js     8004b0 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800492:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800496:	74 d1                	je     800469 <vprintfmt+0x1e9>
  800498:	0f be c0             	movsbl %al,%eax
  80049b:	83 e8 20             	sub    $0x20,%eax
  80049e:	83 f8 5e             	cmp    $0x5e,%eax
  8004a1:	76 c6                	jbe    800469 <vprintfmt+0x1e9>
					putch('?', putdat);
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	56                   	push   %esi
  8004a7:	6a 3f                	push   $0x3f
  8004a9:	ff d3                	call   *%ebx
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	eb c3                	jmp    800473 <vprintfmt+0x1f3>
  8004b0:	89 cf                	mov    %ecx,%edi
  8004b2:	eb 02                	jmp    8004b6 <vprintfmt+0x236>
  8004b4:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  8004b6:	85 ff                	test   %edi,%edi
  8004b8:	7e 10                	jle    8004ca <vprintfmt+0x24a>
				putch(' ', putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	56                   	push   %esi
  8004be:	6a 20                	push   $0x20
  8004c0:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8004c2:	83 ef 01             	sub    $0x1,%edi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	eb ec                	jmp    8004b6 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ca:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8004cd:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d0:	e9 fe 02 00 00       	jmp    8007d3 <vprintfmt+0x553>
	if (lflag >= 2)
  8004d5:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8004d9:	7f 21                	jg     8004fc <vprintfmt+0x27c>
	else if (lflag)
  8004db:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8004df:	74 79                	je     80055a <vprintfmt+0x2da>
		return va_arg(*ap, long);
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8b 00                	mov    (%eax),%eax
  8004e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e9:	89 c1                	mov    %eax,%ecx
  8004eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8004ee:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 40 04             	lea    0x4(%eax),%eax
  8004f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fa:	eb 17                	jmp    800513 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	8b 50 04             	mov    0x4(%eax),%edx
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800507:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80050a:	8b 45 14             	mov    0x14(%ebp),%eax
  80050d:	8d 40 08             	lea    0x8(%eax),%eax
  800510:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  800513:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800516:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800519:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80051c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  80051f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800523:	78 50                	js     800575 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  800525:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800528:	c1 fa 1f             	sar    $0x1f,%edx
  80052b:	89 d0                	mov    %edx,%eax
  80052d:	2b 45 e0             	sub    -0x20(%ebp),%eax
  800530:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  800533:	85 d2                	test   %edx,%edx
  800535:	0f 89 14 02 00 00    	jns    80074f <vprintfmt+0x4cf>
  80053b:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80053f:	0f 84 0a 02 00 00    	je     80074f <vprintfmt+0x4cf>
				putch('+', putdat);
  800545:	83 ec 08             	sub    $0x8,%esp
  800548:	56                   	push   %esi
  800549:	6a 2b                	push   $0x2b
  80054b:	ff d3                	call   *%ebx
  80054d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800550:	b8 0a 00 00 00       	mov    $0xa,%eax
  800555:	e9 5c 01 00 00       	jmp    8006b6 <vprintfmt+0x436>
		return va_arg(*ap, int);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8b 00                	mov    (%eax),%eax
  80055f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800562:	89 c1                	mov    %eax,%ecx
  800564:	c1 f9 1f             	sar    $0x1f,%ecx
  800567:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80056a:	8b 45 14             	mov    0x14(%ebp),%eax
  80056d:	8d 40 04             	lea    0x4(%eax),%eax
  800570:	89 45 14             	mov    %eax,0x14(%ebp)
  800573:	eb 9e                	jmp    800513 <vprintfmt+0x293>
				putch('-', putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	56                   	push   %esi
  800579:	6a 2d                	push   $0x2d
  80057b:	ff d3                	call   *%ebx
				num = -(long long) num;
  80057d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800580:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800583:	f7 d8                	neg    %eax
  800585:	83 d2 00             	adc    $0x0,%edx
  800588:	f7 da                	neg    %edx
  80058a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80058d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800590:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800593:	b8 0a 00 00 00       	mov    $0xa,%eax
  800598:	e9 19 01 00 00       	jmp    8006b6 <vprintfmt+0x436>
	if (lflag >= 2)
  80059d:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8005a1:	7f 29                	jg     8005cc <vprintfmt+0x34c>
	else if (lflag)
  8005a3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8005a7:	74 44                	je     8005ed <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 40 04             	lea    0x4(%eax),%eax
  8005bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c7:	e9 ea 00 00 00       	jmp    8006b6 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8b 50 04             	mov    0x4(%eax),%edx
  8005d2:	8b 00                	mov    (%eax),%eax
  8005d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 40 08             	lea    0x8(%eax),%eax
  8005e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e8:	e9 c9 00 00 00       	jmp    8006b6 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 00                	mov    (%eax),%eax
  8005f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005fa:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 40 04             	lea    0x4(%eax),%eax
  800603:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800606:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060b:	e9 a6 00 00 00       	jmp    8006b6 <vprintfmt+0x436>
			putch('0', putdat);
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	56                   	push   %esi
  800614:	6a 30                	push   $0x30
  800616:	ff d3                	call   *%ebx
	if (lflag >= 2)
  800618:	83 c4 10             	add    $0x10,%esp
  80061b:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80061f:	7f 26                	jg     800647 <vprintfmt+0x3c7>
	else if (lflag)
  800621:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800625:	74 3e                	je     800665 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	ba 00 00 00 00       	mov    $0x0,%edx
  800631:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800634:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8d 40 04             	lea    0x4(%eax),%eax
  80063d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800640:	b8 08 00 00 00       	mov    $0x8,%eax
  800645:	eb 6f                	jmp    8006b6 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 50 04             	mov    0x4(%eax),%edx
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800652:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8d 40 08             	lea    0x8(%eax),%eax
  80065b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80065e:	b8 08 00 00 00       	mov    $0x8,%eax
  800663:	eb 51                	jmp    8006b6 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	ba 00 00 00 00       	mov    $0x0,%edx
  80066f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800672:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8d 40 04             	lea    0x4(%eax),%eax
  80067b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80067e:	b8 08 00 00 00       	mov    $0x8,%eax
  800683:	eb 31                	jmp    8006b6 <vprintfmt+0x436>
			putch('0', putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	56                   	push   %esi
  800689:	6a 30                	push   $0x30
  80068b:	ff d3                	call   *%ebx
			putch('x', putdat);
  80068d:	83 c4 08             	add    $0x8,%esp
  800690:	56                   	push   %esi
  800691:	6a 78                	push   $0x78
  800693:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 00                	mov    (%eax),%eax
  80069a:	ba 00 00 00 00       	mov    $0x0,%edx
  80069f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006a2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  8006a5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 40 04             	lea    0x4(%eax),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b1:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006b6:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8006ba:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006bd:	89 c1                	mov    %eax,%ecx
  8006bf:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  8006c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006c5:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  8006ca:	89 c2                	mov    %eax,%edx
  8006cc:	39 c1                	cmp    %eax,%ecx
  8006ce:	0f 87 85 00 00 00    	ja     800759 <vprintfmt+0x4d9>
		tmp /= base;
  8006d4:	89 d0                	mov    %edx,%eax
  8006d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8006db:	f7 f1                	div    %ecx
		len++;
  8006dd:	83 c7 01             	add    $0x1,%edi
  8006e0:	eb e8                	jmp    8006ca <vprintfmt+0x44a>
	if (lflag >= 2)
  8006e2:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8006e6:	7f 26                	jg     80070e <vprintfmt+0x48e>
	else if (lflag)
  8006e8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006ec:	74 3e                	je     80072c <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8b 00                	mov    (%eax),%eax
  8006f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006fb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8d 40 04             	lea    0x4(%eax),%eax
  800704:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800707:	b8 10 00 00 00       	mov    $0x10,%eax
  80070c:	eb a8                	jmp    8006b6 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  80070e:	8b 45 14             	mov    0x14(%ebp),%eax
  800711:	8b 50 04             	mov    0x4(%eax),%edx
  800714:	8b 00                	mov    (%eax),%eax
  800716:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800719:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8d 40 08             	lea    0x8(%eax),%eax
  800722:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800725:	b8 10 00 00 00       	mov    $0x10,%eax
  80072a:	eb 8a                	jmp    8006b6 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8b 00                	mov    (%eax),%eax
  800731:	ba 00 00 00 00       	mov    $0x0,%edx
  800736:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800739:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8d 40 04             	lea    0x4(%eax),%eax
  800742:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800745:	b8 10 00 00 00       	mov    $0x10,%eax
  80074a:	e9 67 ff ff ff       	jmp    8006b6 <vprintfmt+0x436>
			base = 10;
  80074f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800754:	e9 5d ff ff ff       	jmp    8006b6 <vprintfmt+0x436>
  800759:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  80075c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80075f:	29 f8                	sub    %edi,%eax
  800761:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  800763:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  800767:	74 15                	je     80077e <vprintfmt+0x4fe>
		while (width > 0) {
  800769:	85 ff                	test   %edi,%edi
  80076b:	7e 48                	jle    8007b5 <vprintfmt+0x535>
			putch(padc, putdat);
  80076d:	83 ec 08             	sub    $0x8,%esp
  800770:	56                   	push   %esi
  800771:	ff 75 e0             	pushl  -0x20(%ebp)
  800774:	ff d3                	call   *%ebx
			width--;
  800776:	83 ef 01             	sub    $0x1,%edi
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	eb eb                	jmp    800769 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  80077e:	83 ec 0c             	sub    $0xc,%esp
  800781:	6a 2d                	push   $0x2d
  800783:	ff 75 cc             	pushl  -0x34(%ebp)
  800786:	ff 75 c8             	pushl  -0x38(%ebp)
  800789:	ff 75 d4             	pushl  -0x2c(%ebp)
  80078c:	ff 75 d0             	pushl  -0x30(%ebp)
  80078f:	89 f2                	mov    %esi,%edx
  800791:	89 d8                	mov    %ebx,%eax
  800793:	e8 1e fa ff ff       	call   8001b6 <printnum_helper>
		width -= len;
  800798:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80079b:	2b 7d cc             	sub    -0x34(%ebp),%edi
  80079e:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  8007a1:	85 ff                	test   %edi,%edi
  8007a3:	7e 2e                	jle    8007d3 <vprintfmt+0x553>
			putch(padc, putdat);
  8007a5:	83 ec 08             	sub    $0x8,%esp
  8007a8:	56                   	push   %esi
  8007a9:	6a 20                	push   $0x20
  8007ab:	ff d3                	call   *%ebx
			width--;
  8007ad:	83 ef 01             	sub    $0x1,%edi
  8007b0:	83 c4 10             	add    $0x10,%esp
  8007b3:	eb ec                	jmp    8007a1 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  8007b5:	83 ec 0c             	sub    $0xc,%esp
  8007b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8007bb:	ff 75 cc             	pushl  -0x34(%ebp)
  8007be:	ff 75 c8             	pushl  -0x38(%ebp)
  8007c1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007c4:	ff 75 d0             	pushl  -0x30(%ebp)
  8007c7:	89 f2                	mov    %esi,%edx
  8007c9:	89 d8                	mov    %ebx,%eax
  8007cb:	e8 e6 f9 ff ff       	call   8001b6 <printnum_helper>
  8007d0:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  8007d3:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007d6:	83 c7 01             	add    $0x1,%edi
  8007d9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007dd:	83 f8 25             	cmp    $0x25,%eax
  8007e0:	0f 84 b1 fa ff ff    	je     800297 <vprintfmt+0x17>
			if (ch == '\0')
  8007e6:	85 c0                	test   %eax,%eax
  8007e8:	0f 84 a1 00 00 00    	je     80088f <vprintfmt+0x60f>
			putch(ch, putdat);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	56                   	push   %esi
  8007f2:	50                   	push   %eax
  8007f3:	ff d3                	call   *%ebx
  8007f5:	83 c4 10             	add    $0x10,%esp
  8007f8:	eb dc                	jmp    8007d6 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	83 c0 04             	add    $0x4,%eax
  800800:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800803:	8b 45 14             	mov    0x14(%ebp),%eax
  800806:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800808:	85 ff                	test   %edi,%edi
  80080a:	74 15                	je     800821 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  80080c:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800812:	7f 29                	jg     80083d <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800814:	0f b6 06             	movzbl (%esi),%eax
  800817:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800819:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80081c:	89 45 14             	mov    %eax,0x14(%ebp)
  80081f:	eb b2                	jmp    8007d3 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800821:	68 38 13 80 00       	push   $0x801338
  800826:	68 a1 12 80 00       	push   $0x8012a1
  80082b:	56                   	push   %esi
  80082c:	53                   	push   %ebx
  80082d:	e8 31 fa ff ff       	call   800263 <printfmt>
  800832:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800835:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800838:	89 45 14             	mov    %eax,0x14(%ebp)
  80083b:	eb 96                	jmp    8007d3 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  80083d:	68 70 13 80 00       	push   $0x801370
  800842:	68 a1 12 80 00       	push   $0x8012a1
  800847:	56                   	push   %esi
  800848:	53                   	push   %ebx
  800849:	e8 15 fa ff ff       	call   800263 <printfmt>
				*res = -1;
  80084e:	c6 07 ff             	movb   $0xff,(%edi)
  800851:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800854:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800857:	89 45 14             	mov    %eax,0x14(%ebp)
  80085a:	e9 74 ff ff ff       	jmp    8007d3 <vprintfmt+0x553>
			putch(ch, putdat);
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	56                   	push   %esi
  800863:	6a 25                	push   $0x25
  800865:	ff d3                	call   *%ebx
			break;
  800867:	83 c4 10             	add    $0x10,%esp
  80086a:	e9 64 ff ff ff       	jmp    8007d3 <vprintfmt+0x553>
			putch('%', putdat);
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	56                   	push   %esi
  800873:	6a 25                	push   $0x25
  800875:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800877:	83 c4 10             	add    $0x10,%esp
  80087a:	89 f8                	mov    %edi,%eax
  80087c:	eb 03                	jmp    800881 <vprintfmt+0x601>
  80087e:	83 e8 01             	sub    $0x1,%eax
  800881:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800885:	75 f7                	jne    80087e <vprintfmt+0x5fe>
  800887:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80088a:	e9 44 ff ff ff       	jmp    8007d3 <vprintfmt+0x553>
}
  80088f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800892:	5b                   	pop    %ebx
  800893:	5e                   	pop    %esi
  800894:	5f                   	pop    %edi
  800895:	5d                   	pop    %ebp
  800896:	c3                   	ret    

00800897 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800897:	55                   	push   %ebp
  800898:	89 e5                	mov    %esp,%ebp
  80089a:	83 ec 18             	sub    $0x18,%esp
  80089d:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008a6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008b4:	85 c0                	test   %eax,%eax
  8008b6:	74 26                	je     8008de <vsnprintf+0x47>
  8008b8:	85 d2                	test   %edx,%edx
  8008ba:	7e 22                	jle    8008de <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008bc:	ff 75 14             	pushl  0x14(%ebp)
  8008bf:	ff 75 10             	pushl  0x10(%ebp)
  8008c2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008c5:	50                   	push   %eax
  8008c6:	68 46 02 80 00       	push   $0x800246
  8008cb:	e8 b0 f9 ff ff       	call   800280 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d9:	83 c4 10             	add    $0x10,%esp
}
  8008dc:	c9                   	leave  
  8008dd:	c3                   	ret    
		return -E_INVAL;
  8008de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e3:	eb f7                	jmp    8008dc <vsnprintf+0x45>

008008e5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008eb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ee:	50                   	push   %eax
  8008ef:	ff 75 10             	pushl  0x10(%ebp)
  8008f2:	ff 75 0c             	pushl  0xc(%ebp)
  8008f5:	ff 75 08             	pushl  0x8(%ebp)
  8008f8:	e8 9a ff ff ff       	call   800897 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008fd:	c9                   	leave  
  8008fe:	c3                   	ret    

008008ff <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800905:	b8 00 00 00 00       	mov    $0x0,%eax
  80090a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80090e:	74 05                	je     800915 <strlen+0x16>
		n++;
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	eb f5                	jmp    80090a <strlen+0xb>
	return n;
}
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800920:	ba 00 00 00 00       	mov    $0x0,%edx
  800925:	39 c2                	cmp    %eax,%edx
  800927:	74 0d                	je     800936 <strnlen+0x1f>
  800929:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80092d:	74 05                	je     800934 <strnlen+0x1d>
		n++;
  80092f:	83 c2 01             	add    $0x1,%edx
  800932:	eb f1                	jmp    800925 <strnlen+0xe>
  800934:	89 d0                	mov    %edx,%eax
	return n;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	53                   	push   %ebx
  80093c:	8b 45 08             	mov    0x8(%ebp),%eax
  80093f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800942:	ba 00 00 00 00       	mov    $0x0,%edx
  800947:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80094b:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80094e:	83 c2 01             	add    $0x1,%edx
  800951:	84 c9                	test   %cl,%cl
  800953:	75 f2                	jne    800947 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800955:	5b                   	pop    %ebx
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	53                   	push   %ebx
  80095c:	83 ec 10             	sub    $0x10,%esp
  80095f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800962:	53                   	push   %ebx
  800963:	e8 97 ff ff ff       	call   8008ff <strlen>
  800968:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80096b:	ff 75 0c             	pushl  0xc(%ebp)
  80096e:	01 d8                	add    %ebx,%eax
  800970:	50                   	push   %eax
  800971:	e8 c2 ff ff ff       	call   800938 <strcpy>
	return dst;
}
  800976:	89 d8                	mov    %ebx,%eax
  800978:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80097b:	c9                   	leave  
  80097c:	c3                   	ret    

0080097d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	56                   	push   %esi
  800981:	53                   	push   %ebx
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800988:	89 c6                	mov    %eax,%esi
  80098a:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098d:	89 c2                	mov    %eax,%edx
  80098f:	39 f2                	cmp    %esi,%edx
  800991:	74 11                	je     8009a4 <strncpy+0x27>
		*dst++ = *src;
  800993:	83 c2 01             	add    $0x1,%edx
  800996:	0f b6 19             	movzbl (%ecx),%ebx
  800999:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80099c:	80 fb 01             	cmp    $0x1,%bl
  80099f:	83 d9 ff             	sbb    $0xffffffff,%ecx
  8009a2:	eb eb                	jmp    80098f <strncpy+0x12>
	}
	return ret;
}
  8009a4:	5b                   	pop    %ebx
  8009a5:	5e                   	pop    %esi
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	56                   	push   %esi
  8009ac:	53                   	push   %ebx
  8009ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b3:	8b 55 10             	mov    0x10(%ebp),%edx
  8009b6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b8:	85 d2                	test   %edx,%edx
  8009ba:	74 21                	je     8009dd <strlcpy+0x35>
  8009bc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009c0:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009c2:	39 c2                	cmp    %eax,%edx
  8009c4:	74 14                	je     8009da <strlcpy+0x32>
  8009c6:	0f b6 19             	movzbl (%ecx),%ebx
  8009c9:	84 db                	test   %bl,%bl
  8009cb:	74 0b                	je     8009d8 <strlcpy+0x30>
			*dst++ = *src++;
  8009cd:	83 c1 01             	add    $0x1,%ecx
  8009d0:	83 c2 01             	add    $0x1,%edx
  8009d3:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009d6:	eb ea                	jmp    8009c2 <strlcpy+0x1a>
  8009d8:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009da:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009dd:	29 f0                	sub    %esi,%eax
}
  8009df:	5b                   	pop    %ebx
  8009e0:	5e                   	pop    %esi
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ec:	0f b6 01             	movzbl (%ecx),%eax
  8009ef:	84 c0                	test   %al,%al
  8009f1:	74 0c                	je     8009ff <strcmp+0x1c>
  8009f3:	3a 02                	cmp    (%edx),%al
  8009f5:	75 08                	jne    8009ff <strcmp+0x1c>
		p++, q++;
  8009f7:	83 c1 01             	add    $0x1,%ecx
  8009fa:	83 c2 01             	add    $0x1,%edx
  8009fd:	eb ed                	jmp    8009ec <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ff:	0f b6 c0             	movzbl %al,%eax
  800a02:	0f b6 12             	movzbl (%edx),%edx
  800a05:	29 d0                	sub    %edx,%eax
}
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	53                   	push   %ebx
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a13:	89 c3                	mov    %eax,%ebx
  800a15:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a18:	eb 06                	jmp    800a20 <strncmp+0x17>
		n--, p++, q++;
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a20:	39 d8                	cmp    %ebx,%eax
  800a22:	74 16                	je     800a3a <strncmp+0x31>
  800a24:	0f b6 08             	movzbl (%eax),%ecx
  800a27:	84 c9                	test   %cl,%cl
  800a29:	74 04                	je     800a2f <strncmp+0x26>
  800a2b:	3a 0a                	cmp    (%edx),%cl
  800a2d:	74 eb                	je     800a1a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2f:	0f b6 00             	movzbl (%eax),%eax
  800a32:	0f b6 12             	movzbl (%edx),%edx
  800a35:	29 d0                	sub    %edx,%eax
}
  800a37:	5b                   	pop    %ebx
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    
		return 0;
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3f:	eb f6                	jmp    800a37 <strncmp+0x2e>

00800a41 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4b:	0f b6 10             	movzbl (%eax),%edx
  800a4e:	84 d2                	test   %dl,%dl
  800a50:	74 09                	je     800a5b <strchr+0x1a>
		if (*s == c)
  800a52:	38 ca                	cmp    %cl,%dl
  800a54:	74 0a                	je     800a60 <strchr+0x1f>
	for (; *s; s++)
  800a56:	83 c0 01             	add    $0x1,%eax
  800a59:	eb f0                	jmp    800a4b <strchr+0xa>
			return (char *) s;
	return 0;
  800a5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a60:	5d                   	pop    %ebp
  800a61:	c3                   	ret    

00800a62 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	8b 45 08             	mov    0x8(%ebp),%eax
  800a68:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a6c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a6f:	38 ca                	cmp    %cl,%dl
  800a71:	74 09                	je     800a7c <strfind+0x1a>
  800a73:	84 d2                	test   %dl,%dl
  800a75:	74 05                	je     800a7c <strfind+0x1a>
	for (; *s; s++)
  800a77:	83 c0 01             	add    $0x1,%eax
  800a7a:	eb f0                	jmp    800a6c <strfind+0xa>
			break;
	return (char *) s;
}
  800a7c:	5d                   	pop    %ebp
  800a7d:	c3                   	ret    

00800a7e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a7e:	55                   	push   %ebp
  800a7f:	89 e5                	mov    %esp,%ebp
  800a81:	57                   	push   %edi
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a87:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a8a:	85 c9                	test   %ecx,%ecx
  800a8c:	74 31                	je     800abf <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a8e:	89 f8                	mov    %edi,%eax
  800a90:	09 c8                	or     %ecx,%eax
  800a92:	a8 03                	test   $0x3,%al
  800a94:	75 23                	jne    800ab9 <memset+0x3b>
		c &= 0xFF;
  800a96:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a9a:	89 d3                	mov    %edx,%ebx
  800a9c:	c1 e3 08             	shl    $0x8,%ebx
  800a9f:	89 d0                	mov    %edx,%eax
  800aa1:	c1 e0 18             	shl    $0x18,%eax
  800aa4:	89 d6                	mov    %edx,%esi
  800aa6:	c1 e6 10             	shl    $0x10,%esi
  800aa9:	09 f0                	or     %esi,%eax
  800aab:	09 c2                	or     %eax,%edx
  800aad:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aaf:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ab2:	89 d0                	mov    %edx,%eax
  800ab4:	fc                   	cld    
  800ab5:	f3 ab                	rep stos %eax,%es:(%edi)
  800ab7:	eb 06                	jmp    800abf <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	fc                   	cld    
  800abd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800abf:	89 f8                	mov    %edi,%eax
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	57                   	push   %edi
  800aca:	56                   	push   %esi
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad4:	39 c6                	cmp    %eax,%esi
  800ad6:	73 32                	jae    800b0a <memmove+0x44>
  800ad8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800adb:	39 c2                	cmp    %eax,%edx
  800add:	76 2b                	jbe    800b0a <memmove+0x44>
		s += n;
		d += n;
  800adf:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae2:	89 fe                	mov    %edi,%esi
  800ae4:	09 ce                	or     %ecx,%esi
  800ae6:	09 d6                	or     %edx,%esi
  800ae8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aee:	75 0e                	jne    800afe <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af0:	83 ef 04             	sub    $0x4,%edi
  800af3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800af9:	fd                   	std    
  800afa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800afc:	eb 09                	jmp    800b07 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800afe:	83 ef 01             	sub    $0x1,%edi
  800b01:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b04:	fd                   	std    
  800b05:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b07:	fc                   	cld    
  800b08:	eb 1a                	jmp    800b24 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b0a:	89 c2                	mov    %eax,%edx
  800b0c:	09 ca                	or     %ecx,%edx
  800b0e:	09 f2                	or     %esi,%edx
  800b10:	f6 c2 03             	test   $0x3,%dl
  800b13:	75 0a                	jne    800b1f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b15:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b18:	89 c7                	mov    %eax,%edi
  800b1a:	fc                   	cld    
  800b1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b1d:	eb 05                	jmp    800b24 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b1f:	89 c7                	mov    %eax,%edi
  800b21:	fc                   	cld    
  800b22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b24:	5e                   	pop    %esi
  800b25:	5f                   	pop    %edi
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b2e:	ff 75 10             	pushl  0x10(%ebp)
  800b31:	ff 75 0c             	pushl  0xc(%ebp)
  800b34:	ff 75 08             	pushl  0x8(%ebp)
  800b37:	e8 8a ff ff ff       	call   800ac6 <memmove>
}
  800b3c:	c9                   	leave  
  800b3d:	c3                   	ret    

00800b3e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	8b 45 08             	mov    0x8(%ebp),%eax
  800b46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b49:	89 c6                	mov    %eax,%esi
  800b4b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4e:	39 f0                	cmp    %esi,%eax
  800b50:	74 1c                	je     800b6e <memcmp+0x30>
		if (*s1 != *s2)
  800b52:	0f b6 08             	movzbl (%eax),%ecx
  800b55:	0f b6 1a             	movzbl (%edx),%ebx
  800b58:	38 d9                	cmp    %bl,%cl
  800b5a:	75 08                	jne    800b64 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b5c:	83 c0 01             	add    $0x1,%eax
  800b5f:	83 c2 01             	add    $0x1,%edx
  800b62:	eb ea                	jmp    800b4e <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b64:	0f b6 c1             	movzbl %cl,%eax
  800b67:	0f b6 db             	movzbl %bl,%ebx
  800b6a:	29 d8                	sub    %ebx,%eax
  800b6c:	eb 05                	jmp    800b73 <memcmp+0x35>
	}

	return 0;
  800b6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b73:	5b                   	pop    %ebx
  800b74:	5e                   	pop    %esi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b80:	89 c2                	mov    %eax,%edx
  800b82:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b85:	39 d0                	cmp    %edx,%eax
  800b87:	73 09                	jae    800b92 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b89:	38 08                	cmp    %cl,(%eax)
  800b8b:	74 05                	je     800b92 <memfind+0x1b>
	for (; s < ends; s++)
  800b8d:	83 c0 01             	add    $0x1,%eax
  800b90:	eb f3                	jmp    800b85 <memfind+0xe>
			break;
	return (void *) s;
}
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	57                   	push   %edi
  800b98:	56                   	push   %esi
  800b99:	53                   	push   %ebx
  800b9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba0:	eb 03                	jmp    800ba5 <strtol+0x11>
		s++;
  800ba2:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ba5:	0f b6 01             	movzbl (%ecx),%eax
  800ba8:	3c 20                	cmp    $0x20,%al
  800baa:	74 f6                	je     800ba2 <strtol+0xe>
  800bac:	3c 09                	cmp    $0x9,%al
  800bae:	74 f2                	je     800ba2 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bb0:	3c 2b                	cmp    $0x2b,%al
  800bb2:	74 2a                	je     800bde <strtol+0x4a>
	int neg = 0;
  800bb4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bb9:	3c 2d                	cmp    $0x2d,%al
  800bbb:	74 2b                	je     800be8 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bbd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bc3:	75 0f                	jne    800bd4 <strtol+0x40>
  800bc5:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc8:	74 28                	je     800bf2 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bca:	85 db                	test   %ebx,%ebx
  800bcc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd1:	0f 44 d8             	cmove  %eax,%ebx
  800bd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bdc:	eb 50                	jmp    800c2e <strtol+0x9a>
		s++;
  800bde:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800be1:	bf 00 00 00 00       	mov    $0x0,%edi
  800be6:	eb d5                	jmp    800bbd <strtol+0x29>
		s++, neg = 1;
  800be8:	83 c1 01             	add    $0x1,%ecx
  800beb:	bf 01 00 00 00       	mov    $0x1,%edi
  800bf0:	eb cb                	jmp    800bbd <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf6:	74 0e                	je     800c06 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bf8:	85 db                	test   %ebx,%ebx
  800bfa:	75 d8                	jne    800bd4 <strtol+0x40>
		s++, base = 8;
  800bfc:	83 c1 01             	add    $0x1,%ecx
  800bff:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c04:	eb ce                	jmp    800bd4 <strtol+0x40>
		s += 2, base = 16;
  800c06:	83 c1 02             	add    $0x2,%ecx
  800c09:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c0e:	eb c4                	jmp    800bd4 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c10:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c13:	89 f3                	mov    %esi,%ebx
  800c15:	80 fb 19             	cmp    $0x19,%bl
  800c18:	77 29                	ja     800c43 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c1a:	0f be d2             	movsbl %dl,%edx
  800c1d:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c20:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c23:	7d 30                	jge    800c55 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c25:	83 c1 01             	add    $0x1,%ecx
  800c28:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c2c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c2e:	0f b6 11             	movzbl (%ecx),%edx
  800c31:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c34:	89 f3                	mov    %esi,%ebx
  800c36:	80 fb 09             	cmp    $0x9,%bl
  800c39:	77 d5                	ja     800c10 <strtol+0x7c>
			dig = *s - '0';
  800c3b:	0f be d2             	movsbl %dl,%edx
  800c3e:	83 ea 30             	sub    $0x30,%edx
  800c41:	eb dd                	jmp    800c20 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800c43:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c46:	89 f3                	mov    %esi,%ebx
  800c48:	80 fb 19             	cmp    $0x19,%bl
  800c4b:	77 08                	ja     800c55 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c4d:	0f be d2             	movsbl %dl,%edx
  800c50:	83 ea 37             	sub    $0x37,%edx
  800c53:	eb cb                	jmp    800c20 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c59:	74 05                	je     800c60 <strtol+0xcc>
		*endptr = (char *) s;
  800c5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c5e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c60:	89 c2                	mov    %eax,%edx
  800c62:	f7 da                	neg    %edx
  800c64:	85 ff                	test   %edi,%edi
  800c66:	0f 45 c2             	cmovne %edx,%eax
}
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c74:	b8 00 00 00 00       	mov    $0x0,%eax
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7f:	89 c3                	mov    %eax,%ebx
  800c81:	89 c7                	mov    %eax,%edi
  800c83:	89 c6                	mov    %eax,%esi
  800c85:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_cgetc>:

int
sys_cgetc(void)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c92:	ba 00 00 00 00       	mov    $0x0,%edx
  800c97:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9c:	89 d1                	mov    %edx,%ecx
  800c9e:	89 d3                	mov    %edx,%ebx
  800ca0:	89 d7                	mov    %edx,%edi
  800ca2:	89 d6                	mov    %edx,%esi
  800ca4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ca6:	5b                   	pop    %ebx
  800ca7:	5e                   	pop    %esi
  800ca8:	5f                   	pop    %edi
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	57                   	push   %edi
  800caf:	56                   	push   %esi
  800cb0:	53                   	push   %ebx
  800cb1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	b8 03 00 00 00       	mov    $0x3,%eax
  800cc1:	89 cb                	mov    %ecx,%ebx
  800cc3:	89 cf                	mov    %ecx,%edi
  800cc5:	89 ce                	mov    %ecx,%esi
  800cc7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	7f 08                	jg     800cd5 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ccd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd5:	83 ec 0c             	sub    $0xc,%esp
  800cd8:	50                   	push   %eax
  800cd9:	6a 03                	push   $0x3
  800cdb:	68 44 15 80 00       	push   $0x801544
  800ce0:	6a 23                	push   $0x23
  800ce2:	68 61 15 80 00       	push   $0x801561
  800ce7:	e8 5c 02 00 00       	call   800f48 <_panic>

00800cec <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf7:	b8 02 00 00 00       	mov    $0x2,%eax
  800cfc:	89 d1                	mov    %edx,%ecx
  800cfe:	89 d3                	mov    %edx,%ebx
  800d00:	89 d7                	mov    %edx,%edi
  800d02:	89 d6                	mov    %edx,%esi
  800d04:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_yield>:

void
sys_yield(void)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d11:	ba 00 00 00 00       	mov    $0x0,%edx
  800d16:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d1b:	89 d1                	mov    %edx,%ecx
  800d1d:	89 d3                	mov    %edx,%ebx
  800d1f:	89 d7                	mov    %edx,%edi
  800d21:	89 d6                	mov    %edx,%esi
  800d23:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d33:	be 00 00 00 00       	mov    $0x0,%esi
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3e:	b8 04 00 00 00       	mov    $0x4,%eax
  800d43:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d46:	89 f7                	mov    %esi,%edi
  800d48:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4a:	85 c0                	test   %eax,%eax
  800d4c:	7f 08                	jg     800d56 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5e                   	pop    %esi
  800d53:	5f                   	pop    %edi
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d56:	83 ec 0c             	sub    $0xc,%esp
  800d59:	50                   	push   %eax
  800d5a:	6a 04                	push   $0x4
  800d5c:	68 44 15 80 00       	push   $0x801544
  800d61:	6a 23                	push   $0x23
  800d63:	68 61 15 80 00       	push   $0x801561
  800d68:	e8 db 01 00 00       	call   800f48 <_panic>

00800d6d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d76:	8b 55 08             	mov    0x8(%ebp),%edx
  800d79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7c:	b8 05 00 00 00       	mov    $0x5,%eax
  800d81:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d84:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d87:	8b 75 18             	mov    0x18(%ebp),%esi
  800d8a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7f 08                	jg     800d98 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d98:	83 ec 0c             	sub    $0xc,%esp
  800d9b:	50                   	push   %eax
  800d9c:	6a 05                	push   $0x5
  800d9e:	68 44 15 80 00       	push   $0x801544
  800da3:	6a 23                	push   $0x23
  800da5:	68 61 15 80 00       	push   $0x801561
  800daa:	e8 99 01 00 00       	call   800f48 <_panic>

00800daf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	57                   	push   %edi
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc3:	b8 06 00 00 00       	mov    $0x6,%eax
  800dc8:	89 df                	mov    %ebx,%edi
  800dca:	89 de                	mov    %ebx,%esi
  800dcc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	7f 08                	jg     800dda <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd5:	5b                   	pop    %ebx
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dda:	83 ec 0c             	sub    $0xc,%esp
  800ddd:	50                   	push   %eax
  800dde:	6a 06                	push   $0x6
  800de0:	68 44 15 80 00       	push   $0x801544
  800de5:	6a 23                	push   $0x23
  800de7:	68 61 15 80 00       	push   $0x801561
  800dec:	e8 57 01 00 00       	call   800f48 <_panic>

00800df1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
  800df7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dfa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dff:	8b 55 08             	mov    0x8(%ebp),%edx
  800e02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e05:	b8 08 00 00 00       	mov    $0x8,%eax
  800e0a:	89 df                	mov    %ebx,%edi
  800e0c:	89 de                	mov    %ebx,%esi
  800e0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e10:	85 c0                	test   %eax,%eax
  800e12:	7f 08                	jg     800e1c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e17:	5b                   	pop    %ebx
  800e18:	5e                   	pop    %esi
  800e19:	5f                   	pop    %edi
  800e1a:	5d                   	pop    %ebp
  800e1b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1c:	83 ec 0c             	sub    $0xc,%esp
  800e1f:	50                   	push   %eax
  800e20:	6a 08                	push   $0x8
  800e22:	68 44 15 80 00       	push   $0x801544
  800e27:	6a 23                	push   $0x23
  800e29:	68 61 15 80 00       	push   $0x801561
  800e2e:	e8 15 01 00 00       	call   800f48 <_panic>

00800e33 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	57                   	push   %edi
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e41:	8b 55 08             	mov    0x8(%ebp),%edx
  800e44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e47:	b8 09 00 00 00       	mov    $0x9,%eax
  800e4c:	89 df                	mov    %ebx,%edi
  800e4e:	89 de                	mov    %ebx,%esi
  800e50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e52:	85 c0                	test   %eax,%eax
  800e54:	7f 08                	jg     800e5e <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e59:	5b                   	pop    %ebx
  800e5a:	5e                   	pop    %esi
  800e5b:	5f                   	pop    %edi
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5e:	83 ec 0c             	sub    $0xc,%esp
  800e61:	50                   	push   %eax
  800e62:	6a 09                	push   $0x9
  800e64:	68 44 15 80 00       	push   $0x801544
  800e69:	6a 23                	push   $0x23
  800e6b:	68 61 15 80 00       	push   $0x801561
  800e70:	e8 d3 00 00 00       	call   800f48 <_panic>

00800e75 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	57                   	push   %edi
  800e79:	56                   	push   %esi
  800e7a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e81:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e86:	be 00 00 00 00       	mov    $0x0,%esi
  800e8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e91:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e93:	5b                   	pop    %ebx
  800e94:	5e                   	pop    %esi
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	57                   	push   %edi
  800e9c:	56                   	push   %esi
  800e9d:	53                   	push   %ebx
  800e9e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea9:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eae:	89 cb                	mov    %ecx,%ebx
  800eb0:	89 cf                	mov    %ecx,%edi
  800eb2:	89 ce                	mov    %ecx,%esi
  800eb4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	7f 08                	jg     800ec2 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebd:	5b                   	pop    %ebx
  800ebe:	5e                   	pop    %esi
  800ebf:	5f                   	pop    %edi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec2:	83 ec 0c             	sub    $0xc,%esp
  800ec5:	50                   	push   %eax
  800ec6:	6a 0c                	push   $0xc
  800ec8:	68 44 15 80 00       	push   $0x801544
  800ecd:	6a 23                	push   $0x23
  800ecf:	68 61 15 80 00       	push   $0x801561
  800ed4:	e8 6f 00 00 00       	call   800f48 <_panic>

00800ed9 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	57                   	push   %edi
  800edd:	56                   	push   %esi
  800ede:	53                   	push   %ebx
	asm volatile("int %1\n"
  800edf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eea:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eef:	89 df                	mov    %ebx,%edi
  800ef1:	89 de                	mov    %ebx,%esi
  800ef3:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	57                   	push   %edi
  800efe:	56                   	push   %esi
  800eff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f00:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f05:	8b 55 08             	mov    0x8(%ebp),%edx
  800f08:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f0d:	89 cb                	mov    %ecx,%ebx
  800f0f:	89 cf                	mov    %ecx,%edi
  800f11:	89 ce                	mov    %ecx,%esi
  800f13:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f20:	68 7b 15 80 00       	push   $0x80157b
  800f25:	6a 53                	push   $0x53
  800f27:	68 6f 15 80 00       	push   $0x80156f
  800f2c:	e8 17 00 00 00       	call   800f48 <_panic>

00800f31 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f37:	68 7a 15 80 00       	push   $0x80157a
  800f3c:	6a 5a                	push   $0x5a
  800f3e:	68 6f 15 80 00       	push   $0x80156f
  800f43:	e8 00 00 00 00       	call   800f48 <_panic>

00800f48 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800f4d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f50:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f56:	e8 91 fd ff ff       	call   800cec <sys_getenvid>
  800f5b:	83 ec 0c             	sub    $0xc,%esp
  800f5e:	ff 75 0c             	pushl  0xc(%ebp)
  800f61:	ff 75 08             	pushl  0x8(%ebp)
  800f64:	56                   	push   %esi
  800f65:	50                   	push   %eax
  800f66:	68 90 15 80 00       	push   $0x801590
  800f6b:	e8 32 f2 ff ff       	call   8001a2 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f70:	83 c4 18             	add    $0x18,%esp
  800f73:	53                   	push   %ebx
  800f74:	ff 75 10             	pushl  0x10(%ebp)
  800f77:	e8 d5 f1 ff ff       	call   800151 <vcprintf>
	cprintf("\n");
  800f7c:	c7 04 24 74 12 80 00 	movl   $0x801274,(%esp)
  800f83:	e8 1a f2 ff ff       	call   8001a2 <cprintf>
  800f88:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f8b:	cc                   	int3   
  800f8c:	eb fd                	jmp    800f8b <_panic+0x43>
  800f8e:	66 90                	xchg   %ax,%ax

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
