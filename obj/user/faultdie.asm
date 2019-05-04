
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 20 12 80 00       	push   $0x801220
  80004a:	e8 1e 01 00 00       	call   80016d <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 63 0c 00 00       	call   800cb7 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 1a 0c 00 00       	call   800c76 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 74 0e 00 00       	call   800ee5 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 27 0c 00 00       	call   800cb7 <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	c1 e0 07             	shl    $0x7,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000cc:	6a 00                	push   $0x0
  8000ce:	e8 a3 0b 00 00       	call   800c76 <sys_env_destroy>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 13                	mov    (%ebx),%edx
  8000e4:	8d 42 01             	lea    0x1(%edx),%eax
  8000e7:	89 03                	mov    %eax,(%ebx)
  8000e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f5:	74 09                	je     800100 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800100:	83 ec 08             	sub    $0x8,%esp
  800103:	68 ff 00 00 00       	push   $0xff
  800108:	8d 43 08             	lea    0x8(%ebx),%eax
  80010b:	50                   	push   %eax
  80010c:	e8 28 0b 00 00       	call   800c39 <sys_cputs>
		b->idx = 0;
  800111:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	eb db                	jmp    8000f7 <putch+0x1f>

0080011c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800125:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012c:	00 00 00 
	b.cnt = 0;
  80012f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800136:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800139:	ff 75 0c             	pushl  0xc(%ebp)
  80013c:	ff 75 08             	pushl  0x8(%ebp)
  80013f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	68 d8 00 80 00       	push   $0x8000d8
  80014b:	e8 fb 00 00 00       	call   80024b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800150:	83 c4 08             	add    $0x8,%esp
  800153:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800159:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015f:	50                   	push   %eax
  800160:	e8 d4 0a 00 00       	call   800c39 <sys_cputs>

	return b.cnt;
}
  800165:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800173:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800176:	50                   	push   %eax
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	e8 9d ff ff ff       	call   80011c <vcprintf>
	va_end(ap);

	return cnt;
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    

00800181 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 1c             	sub    $0x1c,%esp
  80018a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80018d:	89 d3                	mov    %edx,%ebx
  80018f:	8b 75 08             	mov    0x8(%ebp),%esi
  800192:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800195:	8b 45 10             	mov    0x10(%ebp),%eax
  800198:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  80019b:	89 c2                	mov    %eax,%edx
  80019d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001a8:	39 c6                	cmp    %eax,%esi
  8001aa:	89 f8                	mov    %edi,%eax
  8001ac:	19 c8                	sbb    %ecx,%eax
  8001ae:	73 32                	jae    8001e2 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  8001b0:	83 ec 08             	sub    $0x8,%esp
  8001b3:	53                   	push   %ebx
  8001b4:	83 ec 04             	sub    $0x4,%esp
  8001b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bd:	57                   	push   %edi
  8001be:	56                   	push   %esi
  8001bf:	e8 0c 0f 00 00       	call   8010d0 <__umoddi3>
  8001c4:	83 c4 14             	add    $0x14,%esp
  8001c7:	0f be 80 46 12 80 00 	movsbl 0x801246(%eax),%eax
  8001ce:	50                   	push   %eax
  8001cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001d2:	ff d0                	call   *%eax
	return remain - 1;
  8001d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d7:	83 e8 01             	sub    $0x1,%eax
}
  8001da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001dd:	5b                   	pop    %ebx
  8001de:	5e                   	pop    %esi
  8001df:	5f                   	pop    %edi
  8001e0:	5d                   	pop    %ebp
  8001e1:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  8001e2:	83 ec 0c             	sub    $0xc,%esp
  8001e5:	ff 75 18             	pushl  0x18(%ebp)
  8001e8:	ff 75 14             	pushl  0x14(%ebp)
  8001eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	51                   	push   %ecx
  8001f2:	52                   	push   %edx
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	e8 c6 0d 00 00       	call   800fc0 <__udivdi3>
  8001fa:	83 c4 18             	add    $0x18,%esp
  8001fd:	52                   	push   %edx
  8001fe:	50                   	push   %eax
  8001ff:	89 da                	mov    %ebx,%edx
  800201:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800204:	e8 78 ff ff ff       	call   800181 <printnum_helper>
  800209:	89 45 14             	mov    %eax,0x14(%ebp)
  80020c:	83 c4 20             	add    $0x20,%esp
  80020f:	eb 9f                	jmp    8001b0 <printnum_helper+0x2f>

00800211 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800217:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80021b:	8b 10                	mov    (%eax),%edx
  80021d:	3b 50 04             	cmp    0x4(%eax),%edx
  800220:	73 0a                	jae    80022c <sprintputch+0x1b>
		*b->buf++ = ch;
  800222:	8d 4a 01             	lea    0x1(%edx),%ecx
  800225:	89 08                	mov    %ecx,(%eax)
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	88 02                	mov    %al,(%edx)
}
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <printfmt>:
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800234:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800237:	50                   	push   %eax
  800238:	ff 75 10             	pushl  0x10(%ebp)
  80023b:	ff 75 0c             	pushl  0xc(%ebp)
  80023e:	ff 75 08             	pushl  0x8(%ebp)
  800241:	e8 05 00 00 00       	call   80024b <vprintfmt>
}
  800246:	83 c4 10             	add    $0x10,%esp
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <vprintfmt>:
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	57                   	push   %edi
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
  800251:	83 ec 3c             	sub    $0x3c,%esp
  800254:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800257:	8b 75 0c             	mov    0xc(%ebp),%esi
  80025a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80025d:	e9 3f 05 00 00       	jmp    8007a1 <vprintfmt+0x556>
		padc = ' ';
  800262:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800266:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  80026d:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800274:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  80027b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  800282:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800289:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80028e:	8d 47 01             	lea    0x1(%edi),%eax
  800291:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800294:	0f b6 17             	movzbl (%edi),%edx
  800297:	8d 42 dd             	lea    -0x23(%edx),%eax
  80029a:	3c 55                	cmp    $0x55,%al
  80029c:	0f 87 98 05 00 00    	ja     80083a <vprintfmt+0x5ef>
  8002a2:	0f b6 c0             	movzbl %al,%eax
  8002a5:	ff 24 85 80 13 80 00 	jmp    *0x801380(,%eax,4)
  8002ac:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  8002af:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8002b3:	eb d9                	jmp    80028e <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8002b5:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  8002b8:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  8002bf:	eb cd                	jmp    80028e <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8002c1:	0f b6 d2             	movzbl %dl,%edx
  8002c4:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8002cc:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  8002cf:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002d2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002d6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8002dc:	83 fb 09             	cmp    $0x9,%ebx
  8002df:	77 5c                	ja     80033d <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  8002e1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002e4:	eb e9                	jmp    8002cf <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  8002e6:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  8002e9:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  8002ed:	eb 9f                	jmp    80028e <vprintfmt+0x43>
			precision = va_arg(ap, int);
  8002ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f2:	8b 00                	mov    (%eax),%eax
  8002f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fa:	8d 40 04             	lea    0x4(%eax),%eax
  8002fd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  800303:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800307:	79 85                	jns    80028e <vprintfmt+0x43>
				width = precision, precision = -1;
  800309:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80030f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800316:	e9 73 ff ff ff       	jmp    80028e <vprintfmt+0x43>
  80031b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80031e:	85 c0                	test   %eax,%eax
  800320:	0f 48 c1             	cmovs  %ecx,%eax
  800323:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800329:	e9 60 ff ff ff       	jmp    80028e <vprintfmt+0x43>
  80032e:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  800331:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800338:	e9 51 ff ff ff       	jmp    80028e <vprintfmt+0x43>
  80033d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800340:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800343:	eb be                	jmp    800303 <vprintfmt+0xb8>
			lflag++;
  800345:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  80034c:	e9 3d ff ff ff       	jmp    80028e <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  800351:	8b 45 14             	mov    0x14(%ebp),%eax
  800354:	8d 78 04             	lea    0x4(%eax),%edi
  800357:	83 ec 08             	sub    $0x8,%esp
  80035a:	56                   	push   %esi
  80035b:	ff 30                	pushl  (%eax)
  80035d:	ff d3                	call   *%ebx
			break;
  80035f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800362:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800365:	e9 34 04 00 00       	jmp    80079e <vprintfmt+0x553>
			err = va_arg(ap, int);
  80036a:	8b 45 14             	mov    0x14(%ebp),%eax
  80036d:	8d 78 04             	lea    0x4(%eax),%edi
  800370:	8b 00                	mov    (%eax),%eax
  800372:	99                   	cltd   
  800373:	31 d0                	xor    %edx,%eax
  800375:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800377:	83 f8 08             	cmp    $0x8,%eax
  80037a:	7f 23                	jg     80039f <vprintfmt+0x154>
  80037c:	8b 14 85 e0 14 80 00 	mov    0x8014e0(,%eax,4),%edx
  800383:	85 d2                	test   %edx,%edx
  800385:	74 18                	je     80039f <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800387:	52                   	push   %edx
  800388:	68 67 12 80 00       	push   $0x801267
  80038d:	56                   	push   %esi
  80038e:	53                   	push   %ebx
  80038f:	e8 9a fe ff ff       	call   80022e <printfmt>
  800394:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800397:	89 7d 14             	mov    %edi,0x14(%ebp)
  80039a:	e9 ff 03 00 00       	jmp    80079e <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  80039f:	50                   	push   %eax
  8003a0:	68 5e 12 80 00       	push   $0x80125e
  8003a5:	56                   	push   %esi
  8003a6:	53                   	push   %ebx
  8003a7:	e8 82 fe ff ff       	call   80022e <printfmt>
  8003ac:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003af:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003b2:	e9 e7 03 00 00       	jmp    80079e <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  8003b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ba:	83 c0 04             	add    $0x4,%eax
  8003bd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c3:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8003c5:	85 c9                	test   %ecx,%ecx
  8003c7:	b8 57 12 80 00       	mov    $0x801257,%eax
  8003cc:	0f 45 c1             	cmovne %ecx,%eax
  8003cf:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  8003d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003d6:	7e 06                	jle    8003de <vprintfmt+0x193>
  8003d8:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8003dc:	75 0d                	jne    8003eb <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003de:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003e1:	89 c7                	mov    %eax,%edi
  8003e3:	03 45 d8             	add    -0x28(%ebp),%eax
  8003e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e9:	eb 53                	jmp    80043e <vprintfmt+0x1f3>
  8003eb:	83 ec 08             	sub    $0x8,%esp
  8003ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8003f1:	50                   	push   %eax
  8003f2:	e8 eb 04 00 00       	call   8008e2 <strnlen>
  8003f7:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003fa:	29 c1                	sub    %eax,%ecx
  8003fc:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8003ff:	83 c4 10             	add    $0x10,%esp
  800402:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800404:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  800408:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80040b:	eb 0f                	jmp    80041c <vprintfmt+0x1d1>
					putch(padc, putdat);
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	56                   	push   %esi
  800411:	ff 75 d8             	pushl  -0x28(%ebp)
  800414:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800416:	83 ef 01             	sub    $0x1,%edi
  800419:	83 c4 10             	add    $0x10,%esp
  80041c:	85 ff                	test   %edi,%edi
  80041e:	7f ed                	jg     80040d <vprintfmt+0x1c2>
  800420:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800423:	85 c9                	test   %ecx,%ecx
  800425:	b8 00 00 00 00       	mov    $0x0,%eax
  80042a:	0f 49 c1             	cmovns %ecx,%eax
  80042d:	29 c1                	sub    %eax,%ecx
  80042f:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800432:	eb aa                	jmp    8003de <vprintfmt+0x193>
					putch(ch, putdat);
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	56                   	push   %esi
  800438:	52                   	push   %edx
  800439:	ff d3                	call   *%ebx
  80043b:	83 c4 10             	add    $0x10,%esp
  80043e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800441:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800443:	83 c7 01             	add    $0x1,%edi
  800446:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80044a:	0f be d0             	movsbl %al,%edx
  80044d:	85 d2                	test   %edx,%edx
  80044f:	74 2e                	je     80047f <vprintfmt+0x234>
  800451:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800455:	78 06                	js     80045d <vprintfmt+0x212>
  800457:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80045b:	78 1e                	js     80047b <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  80045d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800461:	74 d1                	je     800434 <vprintfmt+0x1e9>
  800463:	0f be c0             	movsbl %al,%eax
  800466:	83 e8 20             	sub    $0x20,%eax
  800469:	83 f8 5e             	cmp    $0x5e,%eax
  80046c:	76 c6                	jbe    800434 <vprintfmt+0x1e9>
					putch('?', putdat);
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	56                   	push   %esi
  800472:	6a 3f                	push   $0x3f
  800474:	ff d3                	call   *%ebx
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	eb c3                	jmp    80043e <vprintfmt+0x1f3>
  80047b:	89 cf                	mov    %ecx,%edi
  80047d:	eb 02                	jmp    800481 <vprintfmt+0x236>
  80047f:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  800481:	85 ff                	test   %edi,%edi
  800483:	7e 10                	jle    800495 <vprintfmt+0x24a>
				putch(' ', putdat);
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	56                   	push   %esi
  800489:	6a 20                	push   $0x20
  80048b:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80048d:	83 ef 01             	sub    $0x1,%edi
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	eb ec                	jmp    800481 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800495:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800498:	89 45 14             	mov    %eax,0x14(%ebp)
  80049b:	e9 fe 02 00 00       	jmp    80079e <vprintfmt+0x553>
	if (lflag >= 2)
  8004a0:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8004a4:	7f 21                	jg     8004c7 <vprintfmt+0x27c>
	else if (lflag)
  8004a6:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8004aa:	74 79                	je     800525 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b4:	89 c1                	mov    %eax,%ecx
  8004b6:	c1 f9 1f             	sar    $0x1f,%ecx
  8004b9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bf:	8d 40 04             	lea    0x4(%eax),%eax
  8004c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c5:	eb 17                	jmp    8004de <vprintfmt+0x293>
		return va_arg(*ap, long long);
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8b 50 04             	mov    0x4(%eax),%edx
  8004cd:	8b 00                	mov    (%eax),%eax
  8004cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d8:	8d 40 08             	lea    0x8(%eax),%eax
  8004db:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  8004de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  8004ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ee:	78 50                	js     800540 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  8004f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004f3:	c1 fa 1f             	sar    $0x1f,%edx
  8004f6:	89 d0                	mov    %edx,%eax
  8004f8:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8004fb:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8004fe:	85 d2                	test   %edx,%edx
  800500:	0f 89 14 02 00 00    	jns    80071a <vprintfmt+0x4cf>
  800506:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80050a:	0f 84 0a 02 00 00    	je     80071a <vprintfmt+0x4cf>
				putch('+', putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	56                   	push   %esi
  800514:	6a 2b                	push   $0x2b
  800516:	ff d3                	call   *%ebx
  800518:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80051b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800520:	e9 5c 01 00 00       	jmp    800681 <vprintfmt+0x436>
		return va_arg(*ap, int);
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8b 00                	mov    (%eax),%eax
  80052a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052d:	89 c1                	mov    %eax,%ecx
  80052f:	c1 f9 1f             	sar    $0x1f,%ecx
  800532:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 40 04             	lea    0x4(%eax),%eax
  80053b:	89 45 14             	mov    %eax,0x14(%ebp)
  80053e:	eb 9e                	jmp    8004de <vprintfmt+0x293>
				putch('-', putdat);
  800540:	83 ec 08             	sub    $0x8,%esp
  800543:	56                   	push   %esi
  800544:	6a 2d                	push   $0x2d
  800546:	ff d3                	call   *%ebx
				num = -(long long) num;
  800548:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80054b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80054e:	f7 d8                	neg    %eax
  800550:	83 d2 00             	adc    $0x0,%edx
  800553:	f7 da                	neg    %edx
  800555:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800558:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80055b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80055e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800563:	e9 19 01 00 00       	jmp    800681 <vprintfmt+0x436>
	if (lflag >= 2)
  800568:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80056c:	7f 29                	jg     800597 <vprintfmt+0x34c>
	else if (lflag)
  80056e:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800572:	74 44                	je     8005b8 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8b 00                	mov    (%eax),%eax
  800579:	ba 00 00 00 00       	mov    $0x0,%edx
  80057e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800581:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 40 04             	lea    0x4(%eax),%eax
  80058a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800592:	e9 ea 00 00 00       	jmp    800681 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 50 04             	mov    0x4(%eax),%edx
  80059d:	8b 00                	mov    (%eax),%eax
  80059f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 40 08             	lea    0x8(%eax),%eax
  8005ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b3:	e9 c9 00 00 00       	jmp    800681 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005d1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d6:	e9 a6 00 00 00       	jmp    800681 <vprintfmt+0x436>
			putch('0', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	56                   	push   %esi
  8005df:	6a 30                	push   $0x30
  8005e1:	ff d3                	call   *%ebx
	if (lflag >= 2)
  8005e3:	83 c4 10             	add    $0x10,%esp
  8005e6:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8005ea:	7f 26                	jg     800612 <vprintfmt+0x3c7>
	else if (lflag)
  8005ec:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8005f0:	74 3e                	je     800630 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ff:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 40 04             	lea    0x4(%eax),%eax
  800608:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80060b:	b8 08 00 00 00       	mov    $0x8,%eax
  800610:	eb 6f                	jmp    800681 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8b 50 04             	mov    0x4(%eax),%edx
  800618:	8b 00                	mov    (%eax),%eax
  80061a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80061d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 40 08             	lea    0x8(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800629:	b8 08 00 00 00       	mov    $0x8,%eax
  80062e:	eb 51                	jmp    800681 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 00                	mov    (%eax),%eax
  800635:	ba 00 00 00 00       	mov    $0x0,%edx
  80063a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80063d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 40 04             	lea    0x4(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800649:	b8 08 00 00 00       	mov    $0x8,%eax
  80064e:	eb 31                	jmp    800681 <vprintfmt+0x436>
			putch('0', putdat);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	56                   	push   %esi
  800654:	6a 30                	push   $0x30
  800656:	ff d3                	call   *%ebx
			putch('x', putdat);
  800658:	83 c4 08             	add    $0x8,%esp
  80065b:	56                   	push   %esi
  80065c:	6a 78                	push   $0x78
  80065e:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8b 00                	mov    (%eax),%eax
  800665:	ba 00 00 00 00       	mov    $0x0,%edx
  80066a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80066d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800670:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8d 40 04             	lea    0x4(%eax),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80067c:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800681:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800685:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800688:	89 c1                	mov    %eax,%ecx
  80068a:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  80068d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800690:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800695:	89 c2                	mov    %eax,%edx
  800697:	39 c1                	cmp    %eax,%ecx
  800699:	0f 87 85 00 00 00    	ja     800724 <vprintfmt+0x4d9>
		tmp /= base;
  80069f:	89 d0                	mov    %edx,%eax
  8006a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a6:	f7 f1                	div    %ecx
		len++;
  8006a8:	83 c7 01             	add    $0x1,%edi
  8006ab:	eb e8                	jmp    800695 <vprintfmt+0x44a>
	if (lflag >= 2)
  8006ad:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8006b1:	7f 26                	jg     8006d9 <vprintfmt+0x48e>
	else if (lflag)
  8006b3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006b7:	74 3e                	je     8006f7 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 00                	mov    (%eax),%eax
  8006be:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006c6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 40 04             	lea    0x4(%eax),%eax
  8006cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d2:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d7:	eb a8                	jmp    800681 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8b 50 04             	mov    0x4(%eax),%edx
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8d 40 08             	lea    0x8(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f0:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f5:	eb 8a                	jmp    800681 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8b 00                	mov    (%eax),%eax
  8006fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800701:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800704:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800707:	8b 45 14             	mov    0x14(%ebp),%eax
  80070a:	8d 40 04             	lea    0x4(%eax),%eax
  80070d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800710:	b8 10 00 00 00       	mov    $0x10,%eax
  800715:	e9 67 ff ff ff       	jmp    800681 <vprintfmt+0x436>
			base = 10;
  80071a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80071f:	e9 5d ff ff ff       	jmp    800681 <vprintfmt+0x436>
  800724:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  800727:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80072a:	29 f8                	sub    %edi,%eax
  80072c:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  80072e:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  800732:	74 15                	je     800749 <vprintfmt+0x4fe>
		while (width > 0) {
  800734:	85 ff                	test   %edi,%edi
  800736:	7e 48                	jle    800780 <vprintfmt+0x535>
			putch(padc, putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	56                   	push   %esi
  80073c:	ff 75 e0             	pushl  -0x20(%ebp)
  80073f:	ff d3                	call   *%ebx
			width--;
  800741:	83 ef 01             	sub    $0x1,%edi
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	eb eb                	jmp    800734 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800749:	83 ec 0c             	sub    $0xc,%esp
  80074c:	6a 2d                	push   $0x2d
  80074e:	ff 75 cc             	pushl  -0x34(%ebp)
  800751:	ff 75 c8             	pushl  -0x38(%ebp)
  800754:	ff 75 d4             	pushl  -0x2c(%ebp)
  800757:	ff 75 d0             	pushl  -0x30(%ebp)
  80075a:	89 f2                	mov    %esi,%edx
  80075c:	89 d8                	mov    %ebx,%eax
  80075e:	e8 1e fa ff ff       	call   800181 <printnum_helper>
		width -= len;
  800763:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800766:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800769:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  80076c:	85 ff                	test   %edi,%edi
  80076e:	7e 2e                	jle    80079e <vprintfmt+0x553>
			putch(padc, putdat);
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	56                   	push   %esi
  800774:	6a 20                	push   $0x20
  800776:	ff d3                	call   *%ebx
			width--;
  800778:	83 ef 01             	sub    $0x1,%edi
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	eb ec                	jmp    80076c <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800780:	83 ec 0c             	sub    $0xc,%esp
  800783:	ff 75 e0             	pushl  -0x20(%ebp)
  800786:	ff 75 cc             	pushl  -0x34(%ebp)
  800789:	ff 75 c8             	pushl  -0x38(%ebp)
  80078c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80078f:	ff 75 d0             	pushl  -0x30(%ebp)
  800792:	89 f2                	mov    %esi,%edx
  800794:	89 d8                	mov    %ebx,%eax
  800796:	e8 e6 f9 ff ff       	call   800181 <printnum_helper>
  80079b:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  80079e:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007a1:	83 c7 01             	add    $0x1,%edi
  8007a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007a8:	83 f8 25             	cmp    $0x25,%eax
  8007ab:	0f 84 b1 fa ff ff    	je     800262 <vprintfmt+0x17>
			if (ch == '\0')
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	0f 84 a1 00 00 00    	je     80085a <vprintfmt+0x60f>
			putch(ch, putdat);
  8007b9:	83 ec 08             	sub    $0x8,%esp
  8007bc:	56                   	push   %esi
  8007bd:	50                   	push   %eax
  8007be:	ff d3                	call   *%ebx
  8007c0:	83 c4 10             	add    $0x10,%esp
  8007c3:	eb dc                	jmp    8007a1 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	83 c0 04             	add    $0x4,%eax
  8007cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d1:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8007d3:	85 ff                	test   %edi,%edi
  8007d5:	74 15                	je     8007ec <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  8007d7:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  8007dd:	7f 29                	jg     800808 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  8007df:	0f b6 06             	movzbl (%esi),%eax
  8007e2:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  8007e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ea:	eb b2                	jmp    80079e <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8007ec:	68 00 13 80 00       	push   $0x801300
  8007f1:	68 67 12 80 00       	push   $0x801267
  8007f6:	56                   	push   %esi
  8007f7:	53                   	push   %ebx
  8007f8:	e8 31 fa ff ff       	call   80022e <printfmt>
  8007fd:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800800:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800803:	89 45 14             	mov    %eax,0x14(%ebp)
  800806:	eb 96                	jmp    80079e <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800808:	68 38 13 80 00       	push   $0x801338
  80080d:	68 67 12 80 00       	push   $0x801267
  800812:	56                   	push   %esi
  800813:	53                   	push   %ebx
  800814:	e8 15 fa ff ff       	call   80022e <printfmt>
				*res = -1;
  800819:	c6 07 ff             	movb   $0xff,(%edi)
  80081c:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  80081f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800822:	89 45 14             	mov    %eax,0x14(%ebp)
  800825:	e9 74 ff ff ff       	jmp    80079e <vprintfmt+0x553>
			putch(ch, putdat);
  80082a:	83 ec 08             	sub    $0x8,%esp
  80082d:	56                   	push   %esi
  80082e:	6a 25                	push   $0x25
  800830:	ff d3                	call   *%ebx
			break;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	e9 64 ff ff ff       	jmp    80079e <vprintfmt+0x553>
			putch('%', putdat);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	56                   	push   %esi
  80083e:	6a 25                	push   $0x25
  800840:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800842:	83 c4 10             	add    $0x10,%esp
  800845:	89 f8                	mov    %edi,%eax
  800847:	eb 03                	jmp    80084c <vprintfmt+0x601>
  800849:	83 e8 01             	sub    $0x1,%eax
  80084c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800850:	75 f7                	jne    800849 <vprintfmt+0x5fe>
  800852:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800855:	e9 44 ff ff ff       	jmp    80079e <vprintfmt+0x553>
}
  80085a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5f                   	pop    %edi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	83 ec 18             	sub    $0x18,%esp
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80086e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800871:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800875:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800878:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80087f:	85 c0                	test   %eax,%eax
  800881:	74 26                	je     8008a9 <vsnprintf+0x47>
  800883:	85 d2                	test   %edx,%edx
  800885:	7e 22                	jle    8008a9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800887:	ff 75 14             	pushl  0x14(%ebp)
  80088a:	ff 75 10             	pushl  0x10(%ebp)
  80088d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800890:	50                   	push   %eax
  800891:	68 11 02 80 00       	push   $0x800211
  800896:	e8 b0 f9 ff ff       	call   80024b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80089b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80089e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a4:	83 c4 10             	add    $0x10,%esp
}
  8008a7:	c9                   	leave  
  8008a8:	c3                   	ret    
		return -E_INVAL;
  8008a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ae:	eb f7                	jmp    8008a7 <vsnprintf+0x45>

008008b0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008b6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008b9:	50                   	push   %eax
  8008ba:	ff 75 10             	pushl  0x10(%ebp)
  8008bd:	ff 75 0c             	pushl  0xc(%ebp)
  8008c0:	ff 75 08             	pushl  0x8(%ebp)
  8008c3:	e8 9a ff ff ff       	call   800862 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008c8:	c9                   	leave  
  8008c9:	c3                   	ret    

008008ca <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d9:	74 05                	je     8008e0 <strlen+0x16>
		n++;
  8008db:	83 c0 01             	add    $0x1,%eax
  8008de:	eb f5                	jmp    8008d5 <strlen+0xb>
	return n;
}
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f0:	39 c2                	cmp    %eax,%edx
  8008f2:	74 0d                	je     800901 <strnlen+0x1f>
  8008f4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008f8:	74 05                	je     8008ff <strnlen+0x1d>
		n++;
  8008fa:	83 c2 01             	add    $0x1,%edx
  8008fd:	eb f1                	jmp    8008f0 <strnlen+0xe>
  8008ff:	89 d0                	mov    %edx,%eax
	return n;
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80090d:	ba 00 00 00 00       	mov    $0x0,%edx
  800912:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800916:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800919:	83 c2 01             	add    $0x1,%edx
  80091c:	84 c9                	test   %cl,%cl
  80091e:	75 f2                	jne    800912 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800920:	5b                   	pop    %ebx
  800921:	5d                   	pop    %ebp
  800922:	c3                   	ret    

00800923 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	53                   	push   %ebx
  800927:	83 ec 10             	sub    $0x10,%esp
  80092a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80092d:	53                   	push   %ebx
  80092e:	e8 97 ff ff ff       	call   8008ca <strlen>
  800933:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800936:	ff 75 0c             	pushl  0xc(%ebp)
  800939:	01 d8                	add    %ebx,%eax
  80093b:	50                   	push   %eax
  80093c:	e8 c2 ff ff ff       	call   800903 <strcpy>
	return dst;
}
  800941:	89 d8                	mov    %ebx,%eax
  800943:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800946:	c9                   	leave  
  800947:	c3                   	ret    

00800948 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800953:	89 c6                	mov    %eax,%esi
  800955:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800958:	89 c2                	mov    %eax,%edx
  80095a:	39 f2                	cmp    %esi,%edx
  80095c:	74 11                	je     80096f <strncpy+0x27>
		*dst++ = *src;
  80095e:	83 c2 01             	add    $0x1,%edx
  800961:	0f b6 19             	movzbl (%ecx),%ebx
  800964:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800967:	80 fb 01             	cmp    $0x1,%bl
  80096a:	83 d9 ff             	sbb    $0xffffffff,%ecx
  80096d:	eb eb                	jmp    80095a <strncpy+0x12>
	}
	return ret;
}
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	56                   	push   %esi
  800977:	53                   	push   %ebx
  800978:	8b 75 08             	mov    0x8(%ebp),%esi
  80097b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80097e:	8b 55 10             	mov    0x10(%ebp),%edx
  800981:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800983:	85 d2                	test   %edx,%edx
  800985:	74 21                	je     8009a8 <strlcpy+0x35>
  800987:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80098b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80098d:	39 c2                	cmp    %eax,%edx
  80098f:	74 14                	je     8009a5 <strlcpy+0x32>
  800991:	0f b6 19             	movzbl (%ecx),%ebx
  800994:	84 db                	test   %bl,%bl
  800996:	74 0b                	je     8009a3 <strlcpy+0x30>
			*dst++ = *src++;
  800998:	83 c1 01             	add    $0x1,%ecx
  80099b:	83 c2 01             	add    $0x1,%edx
  80099e:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a1:	eb ea                	jmp    80098d <strlcpy+0x1a>
  8009a3:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009a5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009a8:	29 f0                	sub    %esi,%eax
}
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009b7:	0f b6 01             	movzbl (%ecx),%eax
  8009ba:	84 c0                	test   %al,%al
  8009bc:	74 0c                	je     8009ca <strcmp+0x1c>
  8009be:	3a 02                	cmp    (%edx),%al
  8009c0:	75 08                	jne    8009ca <strcmp+0x1c>
		p++, q++;
  8009c2:	83 c1 01             	add    $0x1,%ecx
  8009c5:	83 c2 01             	add    $0x1,%edx
  8009c8:	eb ed                	jmp    8009b7 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ca:	0f b6 c0             	movzbl %al,%eax
  8009cd:	0f b6 12             	movzbl (%edx),%edx
  8009d0:	29 d0                	sub    %edx,%eax
}
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	53                   	push   %ebx
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009de:	89 c3                	mov    %eax,%ebx
  8009e0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009e3:	eb 06                	jmp    8009eb <strncmp+0x17>
		n--, p++, q++;
  8009e5:	83 c0 01             	add    $0x1,%eax
  8009e8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009eb:	39 d8                	cmp    %ebx,%eax
  8009ed:	74 16                	je     800a05 <strncmp+0x31>
  8009ef:	0f b6 08             	movzbl (%eax),%ecx
  8009f2:	84 c9                	test   %cl,%cl
  8009f4:	74 04                	je     8009fa <strncmp+0x26>
  8009f6:	3a 0a                	cmp    (%edx),%cl
  8009f8:	74 eb                	je     8009e5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009fa:	0f b6 00             	movzbl (%eax),%eax
  8009fd:	0f b6 12             	movzbl (%edx),%edx
  800a00:	29 d0                	sub    %edx,%eax
}
  800a02:	5b                   	pop    %ebx
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    
		return 0;
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0a:	eb f6                	jmp    800a02 <strncmp+0x2e>

00800a0c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a16:	0f b6 10             	movzbl (%eax),%edx
  800a19:	84 d2                	test   %dl,%dl
  800a1b:	74 09                	je     800a26 <strchr+0x1a>
		if (*s == c)
  800a1d:	38 ca                	cmp    %cl,%dl
  800a1f:	74 0a                	je     800a2b <strchr+0x1f>
	for (; *s; s++)
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	eb f0                	jmp    800a16 <strchr+0xa>
			return (char *) s;
	return 0;
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a37:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a3a:	38 ca                	cmp    %cl,%dl
  800a3c:	74 09                	je     800a47 <strfind+0x1a>
  800a3e:	84 d2                	test   %dl,%dl
  800a40:	74 05                	je     800a47 <strfind+0x1a>
	for (; *s; s++)
  800a42:	83 c0 01             	add    $0x1,%eax
  800a45:	eb f0                	jmp    800a37 <strfind+0xa>
			break;
	return (char *) s;
}
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	57                   	push   %edi
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a55:	85 c9                	test   %ecx,%ecx
  800a57:	74 31                	je     800a8a <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a59:	89 f8                	mov    %edi,%eax
  800a5b:	09 c8                	or     %ecx,%eax
  800a5d:	a8 03                	test   $0x3,%al
  800a5f:	75 23                	jne    800a84 <memset+0x3b>
		c &= 0xFF;
  800a61:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a65:	89 d3                	mov    %edx,%ebx
  800a67:	c1 e3 08             	shl    $0x8,%ebx
  800a6a:	89 d0                	mov    %edx,%eax
  800a6c:	c1 e0 18             	shl    $0x18,%eax
  800a6f:	89 d6                	mov    %edx,%esi
  800a71:	c1 e6 10             	shl    $0x10,%esi
  800a74:	09 f0                	or     %esi,%eax
  800a76:	09 c2                	or     %eax,%edx
  800a78:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a7a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a7d:	89 d0                	mov    %edx,%eax
  800a7f:	fc                   	cld    
  800a80:	f3 ab                	rep stos %eax,%es:(%edi)
  800a82:	eb 06                	jmp    800a8a <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a87:	fc                   	cld    
  800a88:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a8a:	89 f8                	mov    %edi,%eax
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5f                   	pop    %edi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	57                   	push   %edi
  800a95:	56                   	push   %esi
  800a96:	8b 45 08             	mov    0x8(%ebp),%eax
  800a99:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a9f:	39 c6                	cmp    %eax,%esi
  800aa1:	73 32                	jae    800ad5 <memmove+0x44>
  800aa3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa6:	39 c2                	cmp    %eax,%edx
  800aa8:	76 2b                	jbe    800ad5 <memmove+0x44>
		s += n;
		d += n;
  800aaa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aad:	89 fe                	mov    %edi,%esi
  800aaf:	09 ce                	or     %ecx,%esi
  800ab1:	09 d6                	or     %edx,%esi
  800ab3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ab9:	75 0e                	jne    800ac9 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800abb:	83 ef 04             	sub    $0x4,%edi
  800abe:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ac4:	fd                   	std    
  800ac5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac7:	eb 09                	jmp    800ad2 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ac9:	83 ef 01             	sub    $0x1,%edi
  800acc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800acf:	fd                   	std    
  800ad0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad2:	fc                   	cld    
  800ad3:	eb 1a                	jmp    800aef <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad5:	89 c2                	mov    %eax,%edx
  800ad7:	09 ca                	or     %ecx,%edx
  800ad9:	09 f2                	or     %esi,%edx
  800adb:	f6 c2 03             	test   $0x3,%dl
  800ade:	75 0a                	jne    800aea <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ae0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ae3:	89 c7                	mov    %eax,%edi
  800ae5:	fc                   	cld    
  800ae6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae8:	eb 05                	jmp    800aef <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800aea:	89 c7                	mov    %eax,%edi
  800aec:	fc                   	cld    
  800aed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800af9:	ff 75 10             	pushl  0x10(%ebp)
  800afc:	ff 75 0c             	pushl  0xc(%ebp)
  800aff:	ff 75 08             	pushl  0x8(%ebp)
  800b02:	e8 8a ff ff ff       	call   800a91 <memmove>
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    

00800b09 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	56                   	push   %esi
  800b0d:	53                   	push   %ebx
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b14:	89 c6                	mov    %eax,%esi
  800b16:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b19:	39 f0                	cmp    %esi,%eax
  800b1b:	74 1c                	je     800b39 <memcmp+0x30>
		if (*s1 != *s2)
  800b1d:	0f b6 08             	movzbl (%eax),%ecx
  800b20:	0f b6 1a             	movzbl (%edx),%ebx
  800b23:	38 d9                	cmp    %bl,%cl
  800b25:	75 08                	jne    800b2f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b27:	83 c0 01             	add    $0x1,%eax
  800b2a:	83 c2 01             	add    $0x1,%edx
  800b2d:	eb ea                	jmp    800b19 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b2f:	0f b6 c1             	movzbl %cl,%eax
  800b32:	0f b6 db             	movzbl %bl,%ebx
  800b35:	29 d8                	sub    %ebx,%eax
  800b37:	eb 05                	jmp    800b3e <memcmp+0x35>
	}

	return 0;
  800b39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b50:	39 d0                	cmp    %edx,%eax
  800b52:	73 09                	jae    800b5d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b54:	38 08                	cmp    %cl,(%eax)
  800b56:	74 05                	je     800b5d <memfind+0x1b>
	for (; s < ends; s++)
  800b58:	83 c0 01             	add    $0x1,%eax
  800b5b:	eb f3                	jmp    800b50 <memfind+0xe>
			break;
	return (void *) s;
}
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6b:	eb 03                	jmp    800b70 <strtol+0x11>
		s++;
  800b6d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b70:	0f b6 01             	movzbl (%ecx),%eax
  800b73:	3c 20                	cmp    $0x20,%al
  800b75:	74 f6                	je     800b6d <strtol+0xe>
  800b77:	3c 09                	cmp    $0x9,%al
  800b79:	74 f2                	je     800b6d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b7b:	3c 2b                	cmp    $0x2b,%al
  800b7d:	74 2a                	je     800ba9 <strtol+0x4a>
	int neg = 0;
  800b7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b84:	3c 2d                	cmp    $0x2d,%al
  800b86:	74 2b                	je     800bb3 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b88:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b8e:	75 0f                	jne    800b9f <strtol+0x40>
  800b90:	80 39 30             	cmpb   $0x30,(%ecx)
  800b93:	74 28                	je     800bbd <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b95:	85 db                	test   %ebx,%ebx
  800b97:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b9c:	0f 44 d8             	cmove  %eax,%ebx
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ba7:	eb 50                	jmp    800bf9 <strtol+0x9a>
		s++;
  800ba9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bac:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb1:	eb d5                	jmp    800b88 <strtol+0x29>
		s++, neg = 1;
  800bb3:	83 c1 01             	add    $0x1,%ecx
  800bb6:	bf 01 00 00 00       	mov    $0x1,%edi
  800bbb:	eb cb                	jmp    800b88 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bbd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bc1:	74 0e                	je     800bd1 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bc3:	85 db                	test   %ebx,%ebx
  800bc5:	75 d8                	jne    800b9f <strtol+0x40>
		s++, base = 8;
  800bc7:	83 c1 01             	add    $0x1,%ecx
  800bca:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bcf:	eb ce                	jmp    800b9f <strtol+0x40>
		s += 2, base = 16;
  800bd1:	83 c1 02             	add    $0x2,%ecx
  800bd4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd9:	eb c4                	jmp    800b9f <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bdb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bde:	89 f3                	mov    %esi,%ebx
  800be0:	80 fb 19             	cmp    $0x19,%bl
  800be3:	77 29                	ja     800c0e <strtol+0xaf>
			dig = *s - 'a' + 10;
  800be5:	0f be d2             	movsbl %dl,%edx
  800be8:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800beb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bee:	7d 30                	jge    800c20 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bf0:	83 c1 01             	add    $0x1,%ecx
  800bf3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bf7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bf9:	0f b6 11             	movzbl (%ecx),%edx
  800bfc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 09             	cmp    $0x9,%bl
  800c04:	77 d5                	ja     800bdb <strtol+0x7c>
			dig = *s - '0';
  800c06:	0f be d2             	movsbl %dl,%edx
  800c09:	83 ea 30             	sub    $0x30,%edx
  800c0c:	eb dd                	jmp    800beb <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800c0e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c11:	89 f3                	mov    %esi,%ebx
  800c13:	80 fb 19             	cmp    $0x19,%bl
  800c16:	77 08                	ja     800c20 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c18:	0f be d2             	movsbl %dl,%edx
  800c1b:	83 ea 37             	sub    $0x37,%edx
  800c1e:	eb cb                	jmp    800beb <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c20:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c24:	74 05                	je     800c2b <strtol+0xcc>
		*endptr = (char *) s;
  800c26:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c29:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c2b:	89 c2                	mov    %eax,%edx
  800c2d:	f7 da                	neg    %edx
  800c2f:	85 ff                	test   %edi,%edi
  800c31:	0f 45 c2             	cmovne %edx,%eax
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	89 c3                	mov    %eax,%ebx
  800c4c:	89 c7                	mov    %eax,%edi
  800c4e:	89 c6                	mov    %eax,%esi
  800c50:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	57                   	push   %edi
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c62:	b8 01 00 00 00       	mov    $0x1,%eax
  800c67:	89 d1                	mov    %edx,%ecx
  800c69:	89 d3                	mov    %edx,%ebx
  800c6b:	89 d7                	mov    %edx,%edi
  800c6d:	89 d6                	mov    %edx,%esi
  800c6f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8c:	89 cb                	mov    %ecx,%ebx
  800c8e:	89 cf                	mov    %ecx,%edi
  800c90:	89 ce                	mov    %ecx,%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 03                	push   $0x3
  800ca6:	68 04 15 80 00       	push   $0x801504
  800cab:	6a 23                	push   $0x23
  800cad:	68 21 15 80 00       	push   $0x801521
  800cb2:	e8 c3 02 00 00       	call   800f7a <_panic>

00800cb7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc2:	b8 02 00 00 00       	mov    $0x2,%eax
  800cc7:	89 d1                	mov    %edx,%ecx
  800cc9:	89 d3                	mov    %edx,%ebx
  800ccb:	89 d7                	mov    %edx,%edi
  800ccd:	89 d6                	mov    %edx,%esi
  800ccf:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_yield>:

void
sys_yield(void)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce6:	89 d1                	mov    %edx,%ecx
  800ce8:	89 d3                	mov    %edx,%ebx
  800cea:	89 d7                	mov    %edx,%edi
  800cec:	89 d6                	mov    %edx,%esi
  800cee:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
  800cfb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cfe:	be 00 00 00 00       	mov    $0x0,%esi
  800d03:	8b 55 08             	mov    0x8(%ebp),%edx
  800d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d09:	b8 04 00 00 00       	mov    $0x4,%eax
  800d0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d11:	89 f7                	mov    %esi,%edi
  800d13:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d15:	85 c0                	test   %eax,%eax
  800d17:	7f 08                	jg     800d21 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 04                	push   $0x4
  800d27:	68 04 15 80 00       	push   $0x801504
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 21 15 80 00       	push   $0x801521
  800d33:	e8 42 02 00 00       	call   800f7a <_panic>

00800d38 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	b8 05 00 00 00       	mov    $0x5,%eax
  800d4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d52:	8b 75 18             	mov    0x18(%ebp),%esi
  800d55:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d57:	85 c0                	test   %eax,%eax
  800d59:	7f 08                	jg     800d63 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5e:	5b                   	pop    %ebx
  800d5f:	5e                   	pop    %esi
  800d60:	5f                   	pop    %edi
  800d61:	5d                   	pop    %ebp
  800d62:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 05                	push   $0x5
  800d69:	68 04 15 80 00       	push   $0x801504
  800d6e:	6a 23                	push   $0x23
  800d70:	68 21 15 80 00       	push   $0x801521
  800d75:	e8 00 02 00 00       	call   800f7a <_panic>

00800d7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	57                   	push   %edi
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d88:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d93:	89 df                	mov    %ebx,%edi
  800d95:	89 de                	mov    %ebx,%esi
  800d97:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	7f 08                	jg     800da5 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 06                	push   $0x6
  800dab:	68 04 15 80 00       	push   $0x801504
  800db0:	6a 23                	push   $0x23
  800db2:	68 21 15 80 00       	push   $0x801521
  800db7:	e8 be 01 00 00       	call   800f7a <_panic>

00800dbc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	57                   	push   %edi
  800dc0:	56                   	push   %esi
  800dc1:	53                   	push   %ebx
  800dc2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd5:	89 df                	mov    %ebx,%edi
  800dd7:	89 de                	mov    %ebx,%esi
  800dd9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ddb:	85 c0                	test   %eax,%eax
  800ddd:	7f 08                	jg     800de7 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ddf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5f                   	pop    %edi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	50                   	push   %eax
  800deb:	6a 08                	push   $0x8
  800ded:	68 04 15 80 00       	push   $0x801504
  800df2:	6a 23                	push   $0x23
  800df4:	68 21 15 80 00       	push   $0x801521
  800df9:	e8 7c 01 00 00       	call   800f7a <_panic>

00800dfe <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e12:	b8 09 00 00 00       	mov    $0x9,%eax
  800e17:	89 df                	mov    %ebx,%edi
  800e19:	89 de                	mov    %ebx,%esi
  800e1b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e1d:	85 c0                	test   %eax,%eax
  800e1f:	7f 08                	jg     800e29 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e29:	83 ec 0c             	sub    $0xc,%esp
  800e2c:	50                   	push   %eax
  800e2d:	6a 09                	push   $0x9
  800e2f:	68 04 15 80 00       	push   $0x801504
  800e34:	6a 23                	push   $0x23
  800e36:	68 21 15 80 00       	push   $0x801521
  800e3b:	e8 3a 01 00 00       	call   800f7a <_panic>

00800e40 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e40:	55                   	push   %ebp
  800e41:	89 e5                	mov    %esp,%ebp
  800e43:	57                   	push   %edi
  800e44:	56                   	push   %esi
  800e45:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e51:	be 00 00 00 00       	mov    $0x0,%esi
  800e56:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e59:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e5c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
  800e69:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e71:	8b 55 08             	mov    0x8(%ebp),%edx
  800e74:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e79:	89 cb                	mov    %ecx,%ebx
  800e7b:	89 cf                	mov    %ecx,%edi
  800e7d:	89 ce                	mov    %ecx,%esi
  800e7f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e81:	85 c0                	test   %eax,%eax
  800e83:	7f 08                	jg     800e8d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8d:	83 ec 0c             	sub    $0xc,%esp
  800e90:	50                   	push   %eax
  800e91:	6a 0c                	push   $0xc
  800e93:	68 04 15 80 00       	push   $0x801504
  800e98:	6a 23                	push   $0x23
  800e9a:	68 21 15 80 00       	push   $0x801521
  800e9f:	e8 d6 00 00 00       	call   800f7a <_panic>

00800ea4 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eaa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eaf:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eba:	89 df                	mov    %ebx,%edi
  800ebc:	89 de                	mov    %ebx,%esi
  800ebe:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	57                   	push   %edi
  800ec9:	56                   	push   %esi
  800eca:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ecb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed3:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ed8:	89 cb                	mov    %ecx,%ebx
  800eda:	89 cf                	mov    %ecx,%edi
  800edc:	89 ce                	mov    %ecx,%esi
  800ede:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800eeb:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800ef2:	74 0a                	je     800efe <set_pgfault_handler+0x19>
		if ((r = sys_env_set_pgfault_upcall((envid_t)0, _pgfault_upcall)) < 0)
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef7:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800efc:	c9                   	leave  
  800efd:	c3                   	ret    
		if ((r = sys_page_alloc((envid_t)0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W)) < 0) 
  800efe:	83 ec 04             	sub    $0x4,%esp
  800f01:	6a 07                	push   $0x7
  800f03:	68 00 f0 bf ee       	push   $0xeebff000
  800f08:	6a 00                	push   $0x0
  800f0a:	e8 e6 fd ff ff       	call   800cf5 <sys_page_alloc>
  800f0f:	83 c4 10             	add    $0x10,%esp
  800f12:	85 c0                	test   %eax,%eax
  800f14:	78 2a                	js     800f40 <set_pgfault_handler+0x5b>
		if ((r = sys_env_set_pgfault_upcall((envid_t)0, _pgfault_upcall)) < 0)
  800f16:	83 ec 08             	sub    $0x8,%esp
  800f19:	68 54 0f 80 00       	push   $0x800f54
  800f1e:	6a 00                	push   $0x0
  800f20:	e8 d9 fe ff ff       	call   800dfe <sys_env_set_pgfault_upcall>
  800f25:	83 c4 10             	add    $0x10,%esp
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	79 c8                	jns    800ef4 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail");
  800f2c:	83 ec 04             	sub    $0x4,%esp
  800f2f:	68 5c 15 80 00       	push   $0x80155c
  800f34:	6a 23                	push   $0x23
  800f36:	68 91 15 80 00       	push   $0x801591
  800f3b:	e8 3a 00 00 00       	call   800f7a <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail");
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	68 30 15 80 00       	push   $0x801530
  800f48:	6a 21                	push   $0x21
  800f4a:	68 91 15 80 00       	push   $0x801591
  800f4f:	e8 26 00 00 00       	call   800f7a <_panic>

00800f54 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800f54:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800f55:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800f5a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800f5c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %ebp
  800f5f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl 48(%esp), %ebx
  800f63:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800f67:	83 eb 04             	sub    $0x4,%ebx
	movl %ebp, (%ebx)
  800f6a:	89 2b                	mov    %ebp,(%ebx)
	movl %ebx, 48(%esp)
  800f6c:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800f70:	83 c4 08             	add    $0x8,%esp
	popal
  800f73:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800f74:	83 c4 04             	add    $0x4,%esp
	popfl
  800f77:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800f78:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800f79:	c3                   	ret    

00800f7a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	56                   	push   %esi
  800f7e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800f7f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f82:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f88:	e8 2a fd ff ff       	call   800cb7 <sys_getenvid>
  800f8d:	83 ec 0c             	sub    $0xc,%esp
  800f90:	ff 75 0c             	pushl  0xc(%ebp)
  800f93:	ff 75 08             	pushl  0x8(%ebp)
  800f96:	56                   	push   %esi
  800f97:	50                   	push   %eax
  800f98:	68 a0 15 80 00       	push   $0x8015a0
  800f9d:	e8 cb f1 ff ff       	call   80016d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fa2:	83 c4 18             	add    $0x18,%esp
  800fa5:	53                   	push   %ebx
  800fa6:	ff 75 10             	pushl  0x10(%ebp)
  800fa9:	e8 6e f1 ff ff       	call   80011c <vcprintf>
	cprintf("\n");
  800fae:	c7 04 24 3a 12 80 00 	movl   $0x80123a,(%esp)
  800fb5:	e8 b3 f1 ff ff       	call   80016d <cprintf>
  800fba:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fbd:	cc                   	int3   
  800fbe:	eb fd                	jmp    800fbd <_panic+0x43>

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
