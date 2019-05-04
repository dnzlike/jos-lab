
obj/user/pingpongs:     file format elf32-i386


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
  80002c:	e8 d2 00 00 00       	call   800103 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 3e 0f 00 00       	call   800f7f <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 74                	jne    8000bc <umain+0x89>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  800048:	83 ec 04             	sub    $0x4,%esp
  80004b:	6a 00                	push   $0x0
  80004d:	6a 00                	push   $0x0
  80004f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800052:	50                   	push   %eax
  800053:	e8 3e 0f 00 00       	call   800f96 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  800058:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  80005e:	8b 7b 48             	mov    0x48(%ebx),%edi
  800061:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800064:	a1 04 20 80 00       	mov    0x802004,%eax
  800069:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80006c:	e8 c9 0c 00 00       	call   800d3a <sys_getenvid>
  800071:	83 c4 08             	add    $0x8,%esp
  800074:	57                   	push   %edi
  800075:	53                   	push   %ebx
  800076:	56                   	push   %esi
  800077:	ff 75 d4             	pushl  -0x2c(%ebp)
  80007a:	50                   	push   %eax
  80007b:	68 d0 12 80 00       	push   $0x8012d0
  800080:	e8 6b 01 00 00       	call   8001f0 <cprintf>
		if (val == 10)
  800085:	a1 04 20 80 00       	mov    0x802004,%eax
  80008a:	83 c4 20             	add    $0x20,%esp
  80008d:	83 f8 0a             	cmp    $0xa,%eax
  800090:	74 22                	je     8000b4 <umain+0x81>
			return;
		++val;
  800092:	83 c0 01             	add    $0x1,%eax
  800095:	a3 04 20 80 00       	mov    %eax,0x802004
		ipc_send(who, 0, 0, 0);
  80009a:	6a 00                	push   $0x0
  80009c:	6a 00                	push   $0x0
  80009e:	6a 00                	push   $0x0
  8000a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a3:	e8 05 0f 00 00       	call   800fad <ipc_send>
		if (val == 10)
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	83 3d 04 20 80 00 0a 	cmpl   $0xa,0x802004
  8000b2:	75 94                	jne    800048 <umain+0x15>
			return;
	}

}
  8000b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000bc:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8000c2:	e8 73 0c 00 00       	call   800d3a <sys_getenvid>
  8000c7:	83 ec 04             	sub    $0x4,%esp
  8000ca:	53                   	push   %ebx
  8000cb:	50                   	push   %eax
  8000cc:	68 a0 12 80 00       	push   $0x8012a0
  8000d1:	e8 1a 01 00 00       	call   8001f0 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000d9:	e8 5c 0c 00 00       	call   800d3a <sys_getenvid>
  8000de:	83 c4 0c             	add    $0xc,%esp
  8000e1:	53                   	push   %ebx
  8000e2:	50                   	push   %eax
  8000e3:	68 ba 12 80 00       	push   $0x8012ba
  8000e8:	e8 03 01 00 00       	call   8001f0 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	6a 00                	push   $0x0
  8000f1:	6a 00                	push   $0x0
  8000f3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000f6:	e8 b2 0e 00 00       	call   800fad <ipc_send>
  8000fb:	83 c4 20             	add    $0x20,%esp
  8000fe:	e9 45 ff ff ff       	jmp    800048 <umain+0x15>

00800103 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80010e:	e8 27 0c 00 00       	call   800d3a <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	c1 e0 07             	shl    $0x7,%eax
  80011b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800120:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 db                	test   %ebx,%ebx
  800127:	7e 07                	jle    800130 <libmain+0x2d>
		binaryname = argv[0];
  800129:	8b 06                	mov    (%esi),%eax
  80012b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800130:	83 ec 08             	sub    $0x8,%esp
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
  800135:	e8 f9 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013a:	e8 0a 00 00 00       	call   800149 <exit>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80014f:	6a 00                	push   $0x0
  800151:	e8 a3 0b 00 00       	call   800cf9 <sys_env_destroy>
}
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	74 09                	je     800183 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800183:	83 ec 08             	sub    $0x8,%esp
  800186:	68 ff 00 00 00       	push   $0xff
  80018b:	8d 43 08             	lea    0x8(%ebx),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 28 0b 00 00       	call   800cbc <sys_cputs>
		b->idx = 0;
  800194:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	eb db                	jmp    80017a <putch+0x1f>

0080019f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019f:	55                   	push   %ebp
  8001a0:	89 e5                	mov    %esp,%ebp
  8001a2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001af:	00 00 00 
	b.cnt = 0;
  8001b2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bc:	ff 75 0c             	pushl  0xc(%ebp)
  8001bf:	ff 75 08             	pushl  0x8(%ebp)
  8001c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c8:	50                   	push   %eax
  8001c9:	68 5b 01 80 00       	push   $0x80015b
  8001ce:	e8 fb 00 00 00       	call   8002ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d3:	83 c4 08             	add    $0x8,%esp
  8001d6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e2:	50                   	push   %eax
  8001e3:	e8 d4 0a 00 00       	call   800cbc <sys_cputs>

	return b.cnt;
}
  8001e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ee:	c9                   	leave  
  8001ef:	c3                   	ret    

008001f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f9:	50                   	push   %eax
  8001fa:	ff 75 08             	pushl  0x8(%ebp)
  8001fd:	e8 9d ff ff ff       	call   80019f <vcprintf>
	va_end(ap);

	return cnt;
}
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	57                   	push   %edi
  800208:	56                   	push   %esi
  800209:	53                   	push   %ebx
  80020a:	83 ec 1c             	sub    $0x1c,%esp
  80020d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800210:	89 d3                	mov    %edx,%ebx
  800212:	8b 75 08             	mov    0x8(%ebp),%esi
  800215:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800218:	8b 45 10             	mov    0x10(%ebp),%eax
  80021b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  80021e:	89 c2                	mov    %eax,%edx
  800220:	b9 00 00 00 00       	mov    $0x0,%ecx
  800225:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800228:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80022b:	39 c6                	cmp    %eax,%esi
  80022d:	89 f8                	mov    %edi,%eax
  80022f:	19 c8                	sbb    %ecx,%eax
  800231:	73 32                	jae    800265 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800233:	83 ec 08             	sub    $0x8,%esp
  800236:	53                   	push   %ebx
  800237:	83 ec 04             	sub    $0x4,%esp
  80023a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80023d:	ff 75 e0             	pushl  -0x20(%ebp)
  800240:	57                   	push   %edi
  800241:	56                   	push   %esi
  800242:	e8 19 0f 00 00       	call   801160 <__umoddi3>
  800247:	83 c4 14             	add    $0x14,%esp
  80024a:	0f be 80 00 13 80 00 	movsbl 0x801300(%eax),%eax
  800251:	50                   	push   %eax
  800252:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800255:	ff d0                	call   *%eax
	return remain - 1;
  800257:	8b 45 14             	mov    0x14(%ebp),%eax
  80025a:	83 e8 01             	sub    $0x1,%eax
}
  80025d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800260:	5b                   	pop    %ebx
  800261:	5e                   	pop    %esi
  800262:	5f                   	pop    %edi
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	ff 75 18             	pushl  0x18(%ebp)
  80026b:	ff 75 14             	pushl  0x14(%ebp)
  80026e:	ff 75 d8             	pushl  -0x28(%ebp)
  800271:	83 ec 08             	sub    $0x8,%esp
  800274:	51                   	push   %ecx
  800275:	52                   	push   %edx
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	e8 d3 0d 00 00       	call   801050 <__udivdi3>
  80027d:	83 c4 18             	add    $0x18,%esp
  800280:	52                   	push   %edx
  800281:	50                   	push   %eax
  800282:	89 da                	mov    %ebx,%edx
  800284:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800287:	e8 78 ff ff ff       	call   800204 <printnum_helper>
  80028c:	89 45 14             	mov    %eax,0x14(%ebp)
  80028f:	83 c4 20             	add    $0x20,%esp
  800292:	eb 9f                	jmp    800233 <printnum_helper+0x2f>

00800294 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a3:	73 0a                	jae    8002af <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a8:	89 08                	mov    %ecx,(%eax)
  8002aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ad:	88 02                	mov    %al,(%edx)
}
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <printfmt>:
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002b7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 10             	pushl  0x10(%ebp)
  8002be:	ff 75 0c             	pushl  0xc(%ebp)
  8002c1:	ff 75 08             	pushl  0x8(%ebp)
  8002c4:	e8 05 00 00 00       	call   8002ce <vprintfmt>
}
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	c9                   	leave  
  8002cd:	c3                   	ret    

008002ce <vprintfmt>:
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 3c             	sub    $0x3c,%esp
  8002d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002da:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002dd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e0:	e9 3f 05 00 00       	jmp    800824 <vprintfmt+0x556>
		padc = ' ';
  8002e5:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  8002e9:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  8002f0:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8002f7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  8002fe:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  800305:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  80030c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800311:	8d 47 01             	lea    0x1(%edi),%eax
  800314:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800317:	0f b6 17             	movzbl (%edi),%edx
  80031a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80031d:	3c 55                	cmp    $0x55,%al
  80031f:	0f 87 98 05 00 00    	ja     8008bd <vprintfmt+0x5ef>
  800325:	0f b6 c0             	movzbl %al,%eax
  800328:	ff 24 85 40 14 80 00 	jmp    *0x801440(,%eax,4)
  80032f:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  800332:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  800336:	eb d9                	jmp    800311 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800338:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  80033b:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  800342:	eb cd                	jmp    800311 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800344:	0f b6 d2             	movzbl %dl,%edx
  800347:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80034a:	b8 00 00 00 00       	mov    $0x0,%eax
  80034f:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  800352:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800355:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800359:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80035c:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80035f:	83 fb 09             	cmp    $0x9,%ebx
  800362:	77 5c                	ja     8003c0 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  800364:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800367:	eb e9                	jmp    800352 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  80036c:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  800370:	eb 9f                	jmp    800311 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  800372:	8b 45 14             	mov    0x14(%ebp),%eax
  800375:	8b 00                	mov    (%eax),%eax
  800377:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037a:	8b 45 14             	mov    0x14(%ebp),%eax
  80037d:	8d 40 04             	lea    0x4(%eax),%eax
  800380:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  800386:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80038a:	79 85                	jns    800311 <vprintfmt+0x43>
				width = precision, precision = -1;
  80038c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800392:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800399:	e9 73 ff ff ff       	jmp    800311 <vprintfmt+0x43>
  80039e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003a1:	85 c0                	test   %eax,%eax
  8003a3:	0f 48 c1             	cmovs  %ecx,%eax
  8003a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8003ac:	e9 60 ff ff ff       	jmp    800311 <vprintfmt+0x43>
  8003b1:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8003b4:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8003bb:	e9 51 ff ff ff       	jmp    800311 <vprintfmt+0x43>
  8003c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003c6:	eb be                	jmp    800386 <vprintfmt+0xb8>
			lflag++;
  8003c8:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cc:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  8003cf:	e9 3d ff ff ff       	jmp    800311 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8d 78 04             	lea    0x4(%eax),%edi
  8003da:	83 ec 08             	sub    $0x8,%esp
  8003dd:	56                   	push   %esi
  8003de:	ff 30                	pushl  (%eax)
  8003e0:	ff d3                	call   *%ebx
			break;
  8003e2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003e5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003e8:	e9 34 04 00 00       	jmp    800821 <vprintfmt+0x553>
			err = va_arg(ap, int);
  8003ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f0:	8d 78 04             	lea    0x4(%eax),%edi
  8003f3:	8b 00                	mov    (%eax),%eax
  8003f5:	99                   	cltd   
  8003f6:	31 d0                	xor    %edx,%eax
  8003f8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003fa:	83 f8 08             	cmp    $0x8,%eax
  8003fd:	7f 23                	jg     800422 <vprintfmt+0x154>
  8003ff:	8b 14 85 a0 15 80 00 	mov    0x8015a0(,%eax,4),%edx
  800406:	85 d2                	test   %edx,%edx
  800408:	74 18                	je     800422 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  80040a:	52                   	push   %edx
  80040b:	68 21 13 80 00       	push   $0x801321
  800410:	56                   	push   %esi
  800411:	53                   	push   %ebx
  800412:	e8 9a fe ff ff       	call   8002b1 <printfmt>
  800417:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80041a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80041d:	e9 ff 03 00 00       	jmp    800821 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  800422:	50                   	push   %eax
  800423:	68 18 13 80 00       	push   $0x801318
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
  80042a:	e8 82 fe ff ff       	call   8002b1 <printfmt>
  80042f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800432:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800435:	e9 e7 03 00 00       	jmp    800821 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	83 c0 04             	add    $0x4,%eax
  800440:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800448:	85 c9                	test   %ecx,%ecx
  80044a:	b8 11 13 80 00       	mov    $0x801311,%eax
  80044f:	0f 45 c1             	cmovne %ecx,%eax
  800452:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800455:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800459:	7e 06                	jle    800461 <vprintfmt+0x193>
  80045b:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  80045f:	75 0d                	jne    80046e <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800461:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800464:	89 c7                	mov    %eax,%edi
  800466:	03 45 d8             	add    -0x28(%ebp),%eax
  800469:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80046c:	eb 53                	jmp    8004c1 <vprintfmt+0x1f3>
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	ff 75 e0             	pushl  -0x20(%ebp)
  800474:	50                   	push   %eax
  800475:	e8 eb 04 00 00       	call   800965 <strnlen>
  80047a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80047d:	29 c1                	sub    %eax,%ecx
  80047f:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800487:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  80048b:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80048e:	eb 0f                	jmp    80049f <vprintfmt+0x1d1>
					putch(padc, putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	56                   	push   %esi
  800494:	ff 75 d8             	pushl  -0x28(%ebp)
  800497:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800499:	83 ef 01             	sub    $0x1,%edi
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	85 ff                	test   %edi,%edi
  8004a1:	7f ed                	jg     800490 <vprintfmt+0x1c2>
  8004a3:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8004a6:	85 c9                	test   %ecx,%ecx
  8004a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ad:	0f 49 c1             	cmovns %ecx,%eax
  8004b0:	29 c1                	sub    %eax,%ecx
  8004b2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8004b5:	eb aa                	jmp    800461 <vprintfmt+0x193>
					putch(ch, putdat);
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	56                   	push   %esi
  8004bb:	52                   	push   %edx
  8004bc:	ff d3                	call   *%ebx
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8004c4:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004c6:	83 c7 01             	add    $0x1,%edi
  8004c9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004cd:	0f be d0             	movsbl %al,%edx
  8004d0:	85 d2                	test   %edx,%edx
  8004d2:	74 2e                	je     800502 <vprintfmt+0x234>
  8004d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d8:	78 06                	js     8004e0 <vprintfmt+0x212>
  8004da:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004de:	78 1e                	js     8004fe <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  8004e0:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004e4:	74 d1                	je     8004b7 <vprintfmt+0x1e9>
  8004e6:	0f be c0             	movsbl %al,%eax
  8004e9:	83 e8 20             	sub    $0x20,%eax
  8004ec:	83 f8 5e             	cmp    $0x5e,%eax
  8004ef:	76 c6                	jbe    8004b7 <vprintfmt+0x1e9>
					putch('?', putdat);
  8004f1:	83 ec 08             	sub    $0x8,%esp
  8004f4:	56                   	push   %esi
  8004f5:	6a 3f                	push   $0x3f
  8004f7:	ff d3                	call   *%ebx
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb c3                	jmp    8004c1 <vprintfmt+0x1f3>
  8004fe:	89 cf                	mov    %ecx,%edi
  800500:	eb 02                	jmp    800504 <vprintfmt+0x236>
  800502:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  800504:	85 ff                	test   %edi,%edi
  800506:	7e 10                	jle    800518 <vprintfmt+0x24a>
				putch(' ', putdat);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	56                   	push   %esi
  80050c:	6a 20                	push   $0x20
  80050e:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800510:	83 ef 01             	sub    $0x1,%edi
  800513:	83 c4 10             	add    $0x10,%esp
  800516:	eb ec                	jmp    800504 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800518:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80051b:	89 45 14             	mov    %eax,0x14(%ebp)
  80051e:	e9 fe 02 00 00       	jmp    800821 <vprintfmt+0x553>
	if (lflag >= 2)
  800523:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800527:	7f 21                	jg     80054a <vprintfmt+0x27c>
	else if (lflag)
  800529:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80052d:	74 79                	je     8005a8 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8b 00                	mov    (%eax),%eax
  800534:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800537:	89 c1                	mov    %eax,%ecx
  800539:	c1 f9 1f             	sar    $0x1f,%ecx
  80053c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 40 04             	lea    0x4(%eax),%eax
  800545:	89 45 14             	mov    %eax,0x14(%ebp)
  800548:	eb 17                	jmp    800561 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8b 50 04             	mov    0x4(%eax),%edx
  800550:	8b 00                	mov    (%eax),%eax
  800552:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800555:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 40 08             	lea    0x8(%eax),%eax
  80055e:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  800561:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800564:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800567:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80056a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  80056d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800571:	78 50                	js     8005c3 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  800573:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800576:	c1 fa 1f             	sar    $0x1f,%edx
  800579:	89 d0                	mov    %edx,%eax
  80057b:	2b 45 e0             	sub    -0x20(%ebp),%eax
  80057e:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  800581:	85 d2                	test   %edx,%edx
  800583:	0f 89 14 02 00 00    	jns    80079d <vprintfmt+0x4cf>
  800589:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80058d:	0f 84 0a 02 00 00    	je     80079d <vprintfmt+0x4cf>
				putch('+', putdat);
  800593:	83 ec 08             	sub    $0x8,%esp
  800596:	56                   	push   %esi
  800597:	6a 2b                	push   $0x2b
  800599:	ff d3                	call   *%ebx
  80059b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80059e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a3:	e9 5c 01 00 00       	jmp    800704 <vprintfmt+0x436>
		return va_arg(*ap, int);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b0:	89 c1                	mov    %eax,%ecx
  8005b2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 40 04             	lea    0x4(%eax),%eax
  8005be:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c1:	eb 9e                	jmp    800561 <vprintfmt+0x293>
				putch('-', putdat);
  8005c3:	83 ec 08             	sub    $0x8,%esp
  8005c6:	56                   	push   %esi
  8005c7:	6a 2d                	push   $0x2d
  8005c9:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d1:	f7 d8                	neg    %eax
  8005d3:	83 d2 00             	adc    $0x0,%edx
  8005d6:	f7 da                	neg    %edx
  8005d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005db:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005de:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e6:	e9 19 01 00 00       	jmp    800704 <vprintfmt+0x436>
	if (lflag >= 2)
  8005eb:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8005ef:	7f 29                	jg     80061a <vprintfmt+0x34c>
	else if (lflag)
  8005f1:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8005f5:	74 44                	je     80063b <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 00                	mov    (%eax),%eax
  8005fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800601:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800604:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800607:	8b 45 14             	mov    0x14(%ebp),%eax
  80060a:	8d 40 04             	lea    0x4(%eax),%eax
  80060d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800610:	b8 0a 00 00 00       	mov    $0xa,%eax
  800615:	e9 ea 00 00 00       	jmp    800704 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 50 04             	mov    0x4(%eax),%edx
  800620:	8b 00                	mov    (%eax),%eax
  800622:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800625:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 40 08             	lea    0x8(%eax),%eax
  80062e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800631:	b8 0a 00 00 00       	mov    $0xa,%eax
  800636:	e9 c9 00 00 00       	jmp    800704 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 00                	mov    (%eax),%eax
  800640:	ba 00 00 00 00       	mov    $0x0,%edx
  800645:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800648:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8d 40 04             	lea    0x4(%eax),%eax
  800651:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800654:	b8 0a 00 00 00       	mov    $0xa,%eax
  800659:	e9 a6 00 00 00       	jmp    800704 <vprintfmt+0x436>
			putch('0', putdat);
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	56                   	push   %esi
  800662:	6a 30                	push   $0x30
  800664:	ff d3                	call   *%ebx
	if (lflag >= 2)
  800666:	83 c4 10             	add    $0x10,%esp
  800669:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80066d:	7f 26                	jg     800695 <vprintfmt+0x3c7>
	else if (lflag)
  80066f:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800673:	74 3e                	je     8006b3 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8b 00                	mov    (%eax),%eax
  80067a:	ba 00 00 00 00       	mov    $0x0,%edx
  80067f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800682:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8d 40 04             	lea    0x4(%eax),%eax
  80068b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80068e:	b8 08 00 00 00       	mov    $0x8,%eax
  800693:	eb 6f                	jmp    800704 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 50 04             	mov    0x4(%eax),%edx
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 40 08             	lea    0x8(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b1:	eb 51                	jmp    800704 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 00                	mov    (%eax),%eax
  8006b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006c0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 40 04             	lea    0x4(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8006d1:	eb 31                	jmp    800704 <vprintfmt+0x436>
			putch('0', putdat);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	56                   	push   %esi
  8006d7:	6a 30                	push   $0x30
  8006d9:	ff d3                	call   *%ebx
			putch('x', putdat);
  8006db:	83 c4 08             	add    $0x8,%esp
  8006de:	56                   	push   %esi
  8006df:	6a 78                	push   $0x78
  8006e1:	ff d3                	call   *%ebx
			num = (unsigned long long)
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 00                	mov    (%eax),%eax
  8006e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  8006f3:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8d 40 04             	lea    0x4(%eax),%eax
  8006fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ff:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800704:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800708:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80070b:	89 c1                	mov    %eax,%ecx
  80070d:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800710:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800713:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800718:	89 c2                	mov    %eax,%edx
  80071a:	39 c1                	cmp    %eax,%ecx
  80071c:	0f 87 85 00 00 00    	ja     8007a7 <vprintfmt+0x4d9>
		tmp /= base;
  800722:	89 d0                	mov    %edx,%eax
  800724:	ba 00 00 00 00       	mov    $0x0,%edx
  800729:	f7 f1                	div    %ecx
		len++;
  80072b:	83 c7 01             	add    $0x1,%edi
  80072e:	eb e8                	jmp    800718 <vprintfmt+0x44a>
	if (lflag >= 2)
  800730:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800734:	7f 26                	jg     80075c <vprintfmt+0x48e>
	else if (lflag)
  800736:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80073a:	74 3e                	je     80077a <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	ba 00 00 00 00       	mov    $0x0,%edx
  800746:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800749:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8d 40 04             	lea    0x4(%eax),%eax
  800752:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800755:	b8 10 00 00 00       	mov    $0x10,%eax
  80075a:	eb a8                	jmp    800704 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  80075c:	8b 45 14             	mov    0x14(%ebp),%eax
  80075f:	8b 50 04             	mov    0x4(%eax),%edx
  800762:	8b 00                	mov    (%eax),%eax
  800764:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800767:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8d 40 08             	lea    0x8(%eax),%eax
  800770:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800773:	b8 10 00 00 00       	mov    $0x10,%eax
  800778:	eb 8a                	jmp    800704 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8b 00                	mov    (%eax),%eax
  80077f:	ba 00 00 00 00       	mov    $0x0,%edx
  800784:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800787:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8d 40 04             	lea    0x4(%eax),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800793:	b8 10 00 00 00       	mov    $0x10,%eax
  800798:	e9 67 ff ff ff       	jmp    800704 <vprintfmt+0x436>
			base = 10;
  80079d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a2:	e9 5d ff ff ff       	jmp    800704 <vprintfmt+0x436>
  8007a7:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8007aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007ad:	29 f8                	sub    %edi,%eax
  8007af:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8007b1:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8007b5:	74 15                	je     8007cc <vprintfmt+0x4fe>
		while (width > 0) {
  8007b7:	85 ff                	test   %edi,%edi
  8007b9:	7e 48                	jle    800803 <vprintfmt+0x535>
			putch(padc, putdat);
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	56                   	push   %esi
  8007bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c2:	ff d3                	call   *%ebx
			width--;
  8007c4:	83 ef 01             	sub    $0x1,%edi
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	eb eb                	jmp    8007b7 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  8007cc:	83 ec 0c             	sub    $0xc,%esp
  8007cf:	6a 2d                	push   $0x2d
  8007d1:	ff 75 cc             	pushl  -0x34(%ebp)
  8007d4:	ff 75 c8             	pushl  -0x38(%ebp)
  8007d7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007da:	ff 75 d0             	pushl  -0x30(%ebp)
  8007dd:	89 f2                	mov    %esi,%edx
  8007df:	89 d8                	mov    %ebx,%eax
  8007e1:	e8 1e fa ff ff       	call   800204 <printnum_helper>
		width -= len;
  8007e6:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007e9:	2b 7d cc             	sub    -0x34(%ebp),%edi
  8007ec:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  8007ef:	85 ff                	test   %edi,%edi
  8007f1:	7e 2e                	jle    800821 <vprintfmt+0x553>
			putch(padc, putdat);
  8007f3:	83 ec 08             	sub    $0x8,%esp
  8007f6:	56                   	push   %esi
  8007f7:	6a 20                	push   $0x20
  8007f9:	ff d3                	call   *%ebx
			width--;
  8007fb:	83 ef 01             	sub    $0x1,%edi
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	eb ec                	jmp    8007ef <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800803:	83 ec 0c             	sub    $0xc,%esp
  800806:	ff 75 e0             	pushl  -0x20(%ebp)
  800809:	ff 75 cc             	pushl  -0x34(%ebp)
  80080c:	ff 75 c8             	pushl  -0x38(%ebp)
  80080f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800812:	ff 75 d0             	pushl  -0x30(%ebp)
  800815:	89 f2                	mov    %esi,%edx
  800817:	89 d8                	mov    %ebx,%eax
  800819:	e8 e6 f9 ff ff       	call   800204 <printnum_helper>
  80081e:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800821:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800824:	83 c7 01             	add    $0x1,%edi
  800827:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80082b:	83 f8 25             	cmp    $0x25,%eax
  80082e:	0f 84 b1 fa ff ff    	je     8002e5 <vprintfmt+0x17>
			if (ch == '\0')
  800834:	85 c0                	test   %eax,%eax
  800836:	0f 84 a1 00 00 00    	je     8008dd <vprintfmt+0x60f>
			putch(ch, putdat);
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	56                   	push   %esi
  800840:	50                   	push   %eax
  800841:	ff d3                	call   *%ebx
  800843:	83 c4 10             	add    $0x10,%esp
  800846:	eb dc                	jmp    800824 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800848:	8b 45 14             	mov    0x14(%ebp),%eax
  80084b:	83 c0 04             	add    $0x4,%eax
  80084e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800856:	85 ff                	test   %edi,%edi
  800858:	74 15                	je     80086f <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  80085a:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800860:	7f 29                	jg     80088b <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800862:	0f b6 06             	movzbl (%esi),%eax
  800865:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800867:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80086a:	89 45 14             	mov    %eax,0x14(%ebp)
  80086d:	eb b2                	jmp    800821 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  80086f:	68 b8 13 80 00       	push   $0x8013b8
  800874:	68 21 13 80 00       	push   $0x801321
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	e8 31 fa ff ff       	call   8002b1 <printfmt>
  800880:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800883:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800886:	89 45 14             	mov    %eax,0x14(%ebp)
  800889:	eb 96                	jmp    800821 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  80088b:	68 f0 13 80 00       	push   $0x8013f0
  800890:	68 21 13 80 00       	push   $0x801321
  800895:	56                   	push   %esi
  800896:	53                   	push   %ebx
  800897:	e8 15 fa ff ff       	call   8002b1 <printfmt>
				*res = -1;
  80089c:	c6 07 ff             	movb   $0xff,(%edi)
  80089f:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8008a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008a5:	89 45 14             	mov    %eax,0x14(%ebp)
  8008a8:	e9 74 ff ff ff       	jmp    800821 <vprintfmt+0x553>
			putch(ch, putdat);
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	56                   	push   %esi
  8008b1:	6a 25                	push   $0x25
  8008b3:	ff d3                	call   *%ebx
			break;
  8008b5:	83 c4 10             	add    $0x10,%esp
  8008b8:	e9 64 ff ff ff       	jmp    800821 <vprintfmt+0x553>
			putch('%', putdat);
  8008bd:	83 ec 08             	sub    $0x8,%esp
  8008c0:	56                   	push   %esi
  8008c1:	6a 25                	push   $0x25
  8008c3:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c5:	83 c4 10             	add    $0x10,%esp
  8008c8:	89 f8                	mov    %edi,%eax
  8008ca:	eb 03                	jmp    8008cf <vprintfmt+0x601>
  8008cc:	83 e8 01             	sub    $0x1,%eax
  8008cf:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008d3:	75 f7                	jne    8008cc <vprintfmt+0x5fe>
  8008d5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008d8:	e9 44 ff ff ff       	jmp    800821 <vprintfmt+0x553>
}
  8008dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5f                   	pop    %edi
  8008e3:	5d                   	pop    %ebp
  8008e4:	c3                   	ret    

008008e5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e5:	55                   	push   %ebp
  8008e6:	89 e5                	mov    %esp,%ebp
  8008e8:	83 ec 18             	sub    $0x18,%esp
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800902:	85 c0                	test   %eax,%eax
  800904:	74 26                	je     80092c <vsnprintf+0x47>
  800906:	85 d2                	test   %edx,%edx
  800908:	7e 22                	jle    80092c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80090a:	ff 75 14             	pushl  0x14(%ebp)
  80090d:	ff 75 10             	pushl  0x10(%ebp)
  800910:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800913:	50                   	push   %eax
  800914:	68 94 02 80 00       	push   $0x800294
  800919:	e8 b0 f9 ff ff       	call   8002ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800921:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800924:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800927:	83 c4 10             	add    $0x10,%esp
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    
		return -E_INVAL;
  80092c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800931:	eb f7                	jmp    80092a <vsnprintf+0x45>

00800933 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800939:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80093c:	50                   	push   %eax
  80093d:	ff 75 10             	pushl  0x10(%ebp)
  800940:	ff 75 0c             	pushl  0xc(%ebp)
  800943:	ff 75 08             	pushl  0x8(%ebp)
  800946:	e8 9a ff ff ff       	call   8008e5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
  800958:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80095c:	74 05                	je     800963 <strlen+0x16>
		n++;
  80095e:	83 c0 01             	add    $0x1,%eax
  800961:	eb f5                	jmp    800958 <strlen+0xb>
	return n;
}
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	39 c2                	cmp    %eax,%edx
  800975:	74 0d                	je     800984 <strnlen+0x1f>
  800977:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80097b:	74 05                	je     800982 <strnlen+0x1d>
		n++;
  80097d:	83 c2 01             	add    $0x1,%edx
  800980:	eb f1                	jmp    800973 <strnlen+0xe>
  800982:	89 d0                	mov    %edx,%eax
	return n;
}
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	53                   	push   %ebx
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800990:	ba 00 00 00 00       	mov    $0x0,%edx
  800995:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800999:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80099c:	83 c2 01             	add    $0x1,%edx
  80099f:	84 c9                	test   %cl,%cl
  8009a1:	75 f2                	jne    800995 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009a3:	5b                   	pop    %ebx
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	53                   	push   %ebx
  8009aa:	83 ec 10             	sub    $0x10,%esp
  8009ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009b0:	53                   	push   %ebx
  8009b1:	e8 97 ff ff ff       	call   80094d <strlen>
  8009b6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009b9:	ff 75 0c             	pushl  0xc(%ebp)
  8009bc:	01 d8                	add    %ebx,%eax
  8009be:	50                   	push   %eax
  8009bf:	e8 c2 ff ff ff       	call   800986 <strcpy>
	return dst;
}
  8009c4:	89 d8                	mov    %ebx,%eax
  8009c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d6:	89 c6                	mov    %eax,%esi
  8009d8:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009db:	89 c2                	mov    %eax,%edx
  8009dd:	39 f2                	cmp    %esi,%edx
  8009df:	74 11                	je     8009f2 <strncpy+0x27>
		*dst++ = *src;
  8009e1:	83 c2 01             	add    $0x1,%edx
  8009e4:	0f b6 19             	movzbl (%ecx),%ebx
  8009e7:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ea:	80 fb 01             	cmp    $0x1,%bl
  8009ed:	83 d9 ff             	sbb    $0xffffffff,%ecx
  8009f0:	eb eb                	jmp    8009dd <strncpy+0x12>
	}
	return ret;
}
  8009f2:	5b                   	pop    %ebx
  8009f3:	5e                   	pop    %esi
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a01:	8b 55 10             	mov    0x10(%ebp),%edx
  800a04:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a06:	85 d2                	test   %edx,%edx
  800a08:	74 21                	je     800a2b <strlcpy+0x35>
  800a0a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a0e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800a10:	39 c2                	cmp    %eax,%edx
  800a12:	74 14                	je     800a28 <strlcpy+0x32>
  800a14:	0f b6 19             	movzbl (%ecx),%ebx
  800a17:	84 db                	test   %bl,%bl
  800a19:	74 0b                	je     800a26 <strlcpy+0x30>
			*dst++ = *src++;
  800a1b:	83 c1 01             	add    $0x1,%ecx
  800a1e:	83 c2 01             	add    $0x1,%edx
  800a21:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a24:	eb ea                	jmp    800a10 <strlcpy+0x1a>
  800a26:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a28:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a2b:	29 f0                	sub    %esi,%eax
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a37:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a3a:	0f b6 01             	movzbl (%ecx),%eax
  800a3d:	84 c0                	test   %al,%al
  800a3f:	74 0c                	je     800a4d <strcmp+0x1c>
  800a41:	3a 02                	cmp    (%edx),%al
  800a43:	75 08                	jne    800a4d <strcmp+0x1c>
		p++, q++;
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	83 c2 01             	add    $0x1,%edx
  800a4b:	eb ed                	jmp    800a3a <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a4d:	0f b6 c0             	movzbl %al,%eax
  800a50:	0f b6 12             	movzbl (%edx),%edx
  800a53:	29 d0                	sub    %edx,%eax
}
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a61:	89 c3                	mov    %eax,%ebx
  800a63:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a66:	eb 06                	jmp    800a6e <strncmp+0x17>
		n--, p++, q++;
  800a68:	83 c0 01             	add    $0x1,%eax
  800a6b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a6e:	39 d8                	cmp    %ebx,%eax
  800a70:	74 16                	je     800a88 <strncmp+0x31>
  800a72:	0f b6 08             	movzbl (%eax),%ecx
  800a75:	84 c9                	test   %cl,%cl
  800a77:	74 04                	je     800a7d <strncmp+0x26>
  800a79:	3a 0a                	cmp    (%edx),%cl
  800a7b:	74 eb                	je     800a68 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7d:	0f b6 00             	movzbl (%eax),%eax
  800a80:	0f b6 12             	movzbl (%edx),%edx
  800a83:	29 d0                	sub    %edx,%eax
}
  800a85:	5b                   	pop    %ebx
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    
		return 0;
  800a88:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8d:	eb f6                	jmp    800a85 <strncmp+0x2e>

00800a8f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a99:	0f b6 10             	movzbl (%eax),%edx
  800a9c:	84 d2                	test   %dl,%dl
  800a9e:	74 09                	je     800aa9 <strchr+0x1a>
		if (*s == c)
  800aa0:	38 ca                	cmp    %cl,%dl
  800aa2:	74 0a                	je     800aae <strchr+0x1f>
	for (; *s; s++)
  800aa4:	83 c0 01             	add    $0x1,%eax
  800aa7:	eb f0                	jmp    800a99 <strchr+0xa>
			return (char *) s;
	return 0;
  800aa9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aba:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800abd:	38 ca                	cmp    %cl,%dl
  800abf:	74 09                	je     800aca <strfind+0x1a>
  800ac1:	84 d2                	test   %dl,%dl
  800ac3:	74 05                	je     800aca <strfind+0x1a>
	for (; *s; s++)
  800ac5:	83 c0 01             	add    $0x1,%eax
  800ac8:	eb f0                	jmp    800aba <strfind+0xa>
			break;
	return (char *) s;
}
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ad5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad8:	85 c9                	test   %ecx,%ecx
  800ada:	74 31                	je     800b0d <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800adc:	89 f8                	mov    %edi,%eax
  800ade:	09 c8                	or     %ecx,%eax
  800ae0:	a8 03                	test   $0x3,%al
  800ae2:	75 23                	jne    800b07 <memset+0x3b>
		c &= 0xFF;
  800ae4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae8:	89 d3                	mov    %edx,%ebx
  800aea:	c1 e3 08             	shl    $0x8,%ebx
  800aed:	89 d0                	mov    %edx,%eax
  800aef:	c1 e0 18             	shl    $0x18,%eax
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	c1 e6 10             	shl    $0x10,%esi
  800af7:	09 f0                	or     %esi,%eax
  800af9:	09 c2                	or     %eax,%edx
  800afb:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800afd:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b00:	89 d0                	mov    %edx,%eax
  800b02:	fc                   	cld    
  800b03:	f3 ab                	rep stos %eax,%es:(%edi)
  800b05:	eb 06                	jmp    800b0d <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0a:	fc                   	cld    
  800b0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b0d:	89 f8                	mov    %edi,%eax
  800b0f:	5b                   	pop    %ebx
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b22:	39 c6                	cmp    %eax,%esi
  800b24:	73 32                	jae    800b58 <memmove+0x44>
  800b26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b29:	39 c2                	cmp    %eax,%edx
  800b2b:	76 2b                	jbe    800b58 <memmove+0x44>
		s += n;
		d += n;
  800b2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b30:	89 fe                	mov    %edi,%esi
  800b32:	09 ce                	or     %ecx,%esi
  800b34:	09 d6                	or     %edx,%esi
  800b36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b3c:	75 0e                	jne    800b4c <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b3e:	83 ef 04             	sub    $0x4,%edi
  800b41:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b44:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b47:	fd                   	std    
  800b48:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4a:	eb 09                	jmp    800b55 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b4c:	83 ef 01             	sub    $0x1,%edi
  800b4f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b52:	fd                   	std    
  800b53:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b55:	fc                   	cld    
  800b56:	eb 1a                	jmp    800b72 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b58:	89 c2                	mov    %eax,%edx
  800b5a:	09 ca                	or     %ecx,%edx
  800b5c:	09 f2                	or     %esi,%edx
  800b5e:	f6 c2 03             	test   $0x3,%dl
  800b61:	75 0a                	jne    800b6d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b63:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b66:	89 c7                	mov    %eax,%edi
  800b68:	fc                   	cld    
  800b69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6b:	eb 05                	jmp    800b72 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b6d:	89 c7                	mov    %eax,%edi
  800b6f:	fc                   	cld    
  800b70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b7c:	ff 75 10             	pushl  0x10(%ebp)
  800b7f:	ff 75 0c             	pushl  0xc(%ebp)
  800b82:	ff 75 08             	pushl  0x8(%ebp)
  800b85:	e8 8a ff ff ff       	call   800b14 <memmove>
}
  800b8a:	c9                   	leave  
  800b8b:	c3                   	ret    

00800b8c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	8b 45 08             	mov    0x8(%ebp),%eax
  800b94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b97:	89 c6                	mov    %eax,%esi
  800b99:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9c:	39 f0                	cmp    %esi,%eax
  800b9e:	74 1c                	je     800bbc <memcmp+0x30>
		if (*s1 != *s2)
  800ba0:	0f b6 08             	movzbl (%eax),%ecx
  800ba3:	0f b6 1a             	movzbl (%edx),%ebx
  800ba6:	38 d9                	cmp    %bl,%cl
  800ba8:	75 08                	jne    800bb2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800baa:	83 c0 01             	add    $0x1,%eax
  800bad:	83 c2 01             	add    $0x1,%edx
  800bb0:	eb ea                	jmp    800b9c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800bb2:	0f b6 c1             	movzbl %cl,%eax
  800bb5:	0f b6 db             	movzbl %bl,%ebx
  800bb8:	29 d8                	sub    %ebx,%eax
  800bba:	eb 05                	jmp    800bc1 <memcmp+0x35>
	}

	return 0;
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc1:	5b                   	pop    %ebx
  800bc2:	5e                   	pop    %esi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bce:	89 c2                	mov    %eax,%edx
  800bd0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd3:	39 d0                	cmp    %edx,%eax
  800bd5:	73 09                	jae    800be0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd7:	38 08                	cmp    %cl,(%eax)
  800bd9:	74 05                	je     800be0 <memfind+0x1b>
	for (; s < ends; s++)
  800bdb:	83 c0 01             	add    $0x1,%eax
  800bde:	eb f3                	jmp    800bd3 <memfind+0xe>
			break;
	return (void *) s;
}
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800beb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bee:	eb 03                	jmp    800bf3 <strtol+0x11>
		s++;
  800bf0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bf3:	0f b6 01             	movzbl (%ecx),%eax
  800bf6:	3c 20                	cmp    $0x20,%al
  800bf8:	74 f6                	je     800bf0 <strtol+0xe>
  800bfa:	3c 09                	cmp    $0x9,%al
  800bfc:	74 f2                	je     800bf0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bfe:	3c 2b                	cmp    $0x2b,%al
  800c00:	74 2a                	je     800c2c <strtol+0x4a>
	int neg = 0;
  800c02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c07:	3c 2d                	cmp    $0x2d,%al
  800c09:	74 2b                	je     800c36 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c11:	75 0f                	jne    800c22 <strtol+0x40>
  800c13:	80 39 30             	cmpb   $0x30,(%ecx)
  800c16:	74 28                	je     800c40 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c18:	85 db                	test   %ebx,%ebx
  800c1a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c1f:	0f 44 d8             	cmove  %eax,%ebx
  800c22:	b8 00 00 00 00       	mov    $0x0,%eax
  800c27:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c2a:	eb 50                	jmp    800c7c <strtol+0x9a>
		s++;
  800c2c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c2f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c34:	eb d5                	jmp    800c0b <strtol+0x29>
		s++, neg = 1;
  800c36:	83 c1 01             	add    $0x1,%ecx
  800c39:	bf 01 00 00 00       	mov    $0x1,%edi
  800c3e:	eb cb                	jmp    800c0b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c40:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c44:	74 0e                	je     800c54 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c46:	85 db                	test   %ebx,%ebx
  800c48:	75 d8                	jne    800c22 <strtol+0x40>
		s++, base = 8;
  800c4a:	83 c1 01             	add    $0x1,%ecx
  800c4d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c52:	eb ce                	jmp    800c22 <strtol+0x40>
		s += 2, base = 16;
  800c54:	83 c1 02             	add    $0x2,%ecx
  800c57:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c5c:	eb c4                	jmp    800c22 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c5e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c61:	89 f3                	mov    %esi,%ebx
  800c63:	80 fb 19             	cmp    $0x19,%bl
  800c66:	77 29                	ja     800c91 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c68:	0f be d2             	movsbl %dl,%edx
  800c6b:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c6e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c71:	7d 30                	jge    800ca3 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c73:	83 c1 01             	add    $0x1,%ecx
  800c76:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c7a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c7c:	0f b6 11             	movzbl (%ecx),%edx
  800c7f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c82:	89 f3                	mov    %esi,%ebx
  800c84:	80 fb 09             	cmp    $0x9,%bl
  800c87:	77 d5                	ja     800c5e <strtol+0x7c>
			dig = *s - '0';
  800c89:	0f be d2             	movsbl %dl,%edx
  800c8c:	83 ea 30             	sub    $0x30,%edx
  800c8f:	eb dd                	jmp    800c6e <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800c91:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c94:	89 f3                	mov    %esi,%ebx
  800c96:	80 fb 19             	cmp    $0x19,%bl
  800c99:	77 08                	ja     800ca3 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c9b:	0f be d2             	movsbl %dl,%edx
  800c9e:	83 ea 37             	sub    $0x37,%edx
  800ca1:	eb cb                	jmp    800c6e <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ca3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca7:	74 05                	je     800cae <strtol+0xcc>
		*endptr = (char *) s;
  800ca9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cac:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cae:	89 c2                	mov    %eax,%edx
  800cb0:	f7 da                	neg    %edx
  800cb2:	85 ff                	test   %edi,%edi
  800cb4:	0f 45 c2             	cmovne %edx,%eax
}
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccd:	89 c3                	mov    %eax,%ebx
  800ccf:	89 c7                	mov    %eax,%edi
  800cd1:	89 c6                	mov    %eax,%esi
  800cd3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_cgetc>:

int
sys_cgetc(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	b8 03 00 00 00       	mov    $0x3,%eax
  800d0f:	89 cb                	mov    %ecx,%ebx
  800d11:	89 cf                	mov    %ecx,%edi
  800d13:	89 ce                	mov    %ecx,%esi
  800d15:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	7f 08                	jg     800d23 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d23:	83 ec 0c             	sub    $0xc,%esp
  800d26:	50                   	push   %eax
  800d27:	6a 03                	push   $0x3
  800d29:	68 c4 15 80 00       	push   $0x8015c4
  800d2e:	6a 23                	push   $0x23
  800d30:	68 e1 15 80 00       	push   $0x8015e1
  800d35:	e8 c5 02 00 00       	call   800fff <_panic>

00800d3a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d40:	ba 00 00 00 00       	mov    $0x0,%edx
  800d45:	b8 02 00 00 00       	mov    $0x2,%eax
  800d4a:	89 d1                	mov    %edx,%ecx
  800d4c:	89 d3                	mov    %edx,%ebx
  800d4e:	89 d7                	mov    %edx,%edi
  800d50:	89 d6                	mov    %edx,%esi
  800d52:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_yield>:

void
sys_yield(void)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d64:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d69:	89 d1                	mov    %edx,%ecx
  800d6b:	89 d3                	mov    %edx,%ebx
  800d6d:	89 d7                	mov    %edx,%edi
  800d6f:	89 d6                	mov    %edx,%esi
  800d71:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
  800d7e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d81:	be 00 00 00 00       	mov    $0x0,%esi
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8c:	b8 04 00 00 00       	mov    $0x4,%eax
  800d91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d94:	89 f7                	mov    %esi,%edi
  800d96:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7f 08                	jg     800da4 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9f:	5b                   	pop    %ebx
  800da0:	5e                   	pop    %esi
  800da1:	5f                   	pop    %edi
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da4:	83 ec 0c             	sub    $0xc,%esp
  800da7:	50                   	push   %eax
  800da8:	6a 04                	push   $0x4
  800daa:	68 c4 15 80 00       	push   $0x8015c4
  800daf:	6a 23                	push   $0x23
  800db1:	68 e1 15 80 00       	push   $0x8015e1
  800db6:	e8 44 02 00 00       	call   800fff <_panic>

00800dbb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dca:	b8 05 00 00 00       	mov    $0x5,%eax
  800dcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd5:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	7f 08                	jg     800de6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	50                   	push   %eax
  800dea:	6a 05                	push   $0x5
  800dec:	68 c4 15 80 00       	push   $0x8015c4
  800df1:	6a 23                	push   $0x23
  800df3:	68 e1 15 80 00       	push   $0x8015e1
  800df8:	e8 02 02 00 00       	call   800fff <_panic>

00800dfd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e11:	b8 06 00 00 00       	mov    $0x6,%eax
  800e16:	89 df                	mov    %ebx,%edi
  800e18:	89 de                	mov    %ebx,%esi
  800e1a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	7f 08                	jg     800e28 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5f                   	pop    %edi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e28:	83 ec 0c             	sub    $0xc,%esp
  800e2b:	50                   	push   %eax
  800e2c:	6a 06                	push   $0x6
  800e2e:	68 c4 15 80 00       	push   $0x8015c4
  800e33:	6a 23                	push   $0x23
  800e35:	68 e1 15 80 00       	push   $0x8015e1
  800e3a:	e8 c0 01 00 00       	call   800fff <_panic>

00800e3f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	57                   	push   %edi
  800e43:	56                   	push   %esi
  800e44:	53                   	push   %ebx
  800e45:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e53:	b8 08 00 00 00       	mov    $0x8,%eax
  800e58:	89 df                	mov    %ebx,%edi
  800e5a:	89 de                	mov    %ebx,%esi
  800e5c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	7f 08                	jg     800e6a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	83 ec 0c             	sub    $0xc,%esp
  800e6d:	50                   	push   %eax
  800e6e:	6a 08                	push   $0x8
  800e70:	68 c4 15 80 00       	push   $0x8015c4
  800e75:	6a 23                	push   $0x23
  800e77:	68 e1 15 80 00       	push   $0x8015e1
  800e7c:	e8 7e 01 00 00       	call   800fff <_panic>

00800e81 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e95:	b8 09 00 00 00       	mov    $0x9,%eax
  800e9a:	89 df                	mov    %ebx,%edi
  800e9c:	89 de                	mov    %ebx,%esi
  800e9e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	7f 08                	jg     800eac <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eac:	83 ec 0c             	sub    $0xc,%esp
  800eaf:	50                   	push   %eax
  800eb0:	6a 09                	push   $0x9
  800eb2:	68 c4 15 80 00       	push   $0x8015c4
  800eb7:	6a 23                	push   $0x23
  800eb9:	68 e1 15 80 00       	push   $0x8015e1
  800ebe:	e8 3c 01 00 00       	call   800fff <_panic>

00800ec3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ec9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ed4:	be 00 00 00 00       	mov    $0x0,%esi
  800ed9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800edc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800edf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
  800eec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800efc:	89 cb                	mov    %ecx,%ebx
  800efe:	89 cf                	mov    %ecx,%edi
  800f00:	89 ce                	mov    %ecx,%esi
  800f02:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	7f 08                	jg     800f10 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0b:	5b                   	pop    %ebx
  800f0c:	5e                   	pop    %esi
  800f0d:	5f                   	pop    %edi
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	50                   	push   %eax
  800f14:	6a 0c                	push   $0xc
  800f16:	68 c4 15 80 00       	push   $0x8015c4
  800f1b:	6a 23                	push   $0x23
  800f1d:	68 e1 15 80 00       	push   $0x8015e1
  800f22:	e8 d8 00 00 00       	call   800fff <_panic>

00800f27 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f32:	8b 55 08             	mov    0x8(%ebp),%edx
  800f35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f38:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f3d:	89 df                	mov    %ebx,%edi
  800f3f:	89 de                	mov    %ebx,%esi
  800f41:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	57                   	push   %edi
  800f4c:	56                   	push   %esi
  800f4d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f53:	8b 55 08             	mov    0x8(%ebp),%edx
  800f56:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f5b:	89 cb                	mov    %ecx,%ebx
  800f5d:	89 cf                	mov    %ecx,%edi
  800f5f:	89 ce                	mov    %ecx,%esi
  800f61:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f63:	5b                   	pop    %ebx
  800f64:	5e                   	pop    %esi
  800f65:	5f                   	pop    %edi
  800f66:	5d                   	pop    %ebp
  800f67:	c3                   	ret    

00800f68 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f6e:	68 fb 15 80 00       	push   $0x8015fb
  800f73:	6a 53                	push   $0x53
  800f75:	68 ef 15 80 00       	push   $0x8015ef
  800f7a:	e8 80 00 00 00       	call   800fff <_panic>

00800f7f <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f85:	68 fa 15 80 00       	push   $0x8015fa
  800f8a:	6a 5a                	push   $0x5a
  800f8c:	68 ef 15 80 00       	push   $0x8015ef
  800f91:	e8 69 00 00 00       	call   800fff <_panic>

00800f96 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800f9c:	68 10 16 80 00       	push   $0x801610
  800fa1:	6a 1a                	push   $0x1a
  800fa3:	68 29 16 80 00       	push   $0x801629
  800fa8:	e8 52 00 00 00       	call   800fff <_panic>

00800fad <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800fb3:	68 33 16 80 00       	push   $0x801633
  800fb8:	6a 2a                	push   $0x2a
  800fba:	68 29 16 80 00       	push   $0x801629
  800fbf:	e8 3b 00 00 00       	call   800fff <_panic>

00800fc4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800fca:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800fcf:	89 c2                	mov    %eax,%edx
  800fd1:	c1 e2 07             	shl    $0x7,%edx
  800fd4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800fda:	8b 52 50             	mov    0x50(%edx),%edx
  800fdd:	39 ca                	cmp    %ecx,%edx
  800fdf:	74 11                	je     800ff2 <ipc_find_env+0x2e>
	for (i = 0; i < NENV; i++)
  800fe1:	83 c0 01             	add    $0x1,%eax
  800fe4:	3d 00 04 00 00       	cmp    $0x400,%eax
  800fe9:	75 e4                	jne    800fcf <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800feb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff0:	eb 0b                	jmp    800ffd <ipc_find_env+0x39>
			return envs[i].env_id;
  800ff2:	c1 e0 07             	shl    $0x7,%eax
  800ff5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ffa:	8b 40 48             	mov    0x48(%eax),%eax
}
  800ffd:	5d                   	pop    %ebp
  800ffe:	c3                   	ret    

00800fff <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801004:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801007:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80100d:	e8 28 fd ff ff       	call   800d3a <sys_getenvid>
  801012:	83 ec 0c             	sub    $0xc,%esp
  801015:	ff 75 0c             	pushl  0xc(%ebp)
  801018:	ff 75 08             	pushl  0x8(%ebp)
  80101b:	56                   	push   %esi
  80101c:	50                   	push   %eax
  80101d:	68 4c 16 80 00       	push   $0x80164c
  801022:	e8 c9 f1 ff ff       	call   8001f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801027:	83 c4 18             	add    $0x18,%esp
  80102a:	53                   	push   %ebx
  80102b:	ff 75 10             	pushl  0x10(%ebp)
  80102e:	e8 6c f1 ff ff       	call   80019f <vcprintf>
	cprintf("\n");
  801033:	c7 04 24 b8 12 80 00 	movl   $0x8012b8,(%esp)
  80103a:	e8 b1 f1 ff ff       	call   8001f0 <cprintf>
  80103f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801042:	cc                   	int3   
  801043:	eb fd                	jmp    801042 <_panic+0x43>
  801045:	66 90                	xchg   %ax,%ax
  801047:	66 90                	xchg   %ax,%ax
  801049:	66 90                	xchg   %ax,%ax
  80104b:	66 90                	xchg   %ax,%ax
  80104d:	66 90                	xchg   %ax,%ax
  80104f:	90                   	nop

00801050 <__udivdi3>:
  801050:	55                   	push   %ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
  801054:	83 ec 1c             	sub    $0x1c,%esp
  801057:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80105b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80105f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801063:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801067:	85 d2                	test   %edx,%edx
  801069:	75 4d                	jne    8010b8 <__udivdi3+0x68>
  80106b:	39 f3                	cmp    %esi,%ebx
  80106d:	76 19                	jbe    801088 <__udivdi3+0x38>
  80106f:	31 ff                	xor    %edi,%edi
  801071:	89 e8                	mov    %ebp,%eax
  801073:	89 f2                	mov    %esi,%edx
  801075:	f7 f3                	div    %ebx
  801077:	89 fa                	mov    %edi,%edx
  801079:	83 c4 1c             	add    $0x1c,%esp
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    
  801081:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801088:	89 d9                	mov    %ebx,%ecx
  80108a:	85 db                	test   %ebx,%ebx
  80108c:	75 0b                	jne    801099 <__udivdi3+0x49>
  80108e:	b8 01 00 00 00       	mov    $0x1,%eax
  801093:	31 d2                	xor    %edx,%edx
  801095:	f7 f3                	div    %ebx
  801097:	89 c1                	mov    %eax,%ecx
  801099:	31 d2                	xor    %edx,%edx
  80109b:	89 f0                	mov    %esi,%eax
  80109d:	f7 f1                	div    %ecx
  80109f:	89 c6                	mov    %eax,%esi
  8010a1:	89 e8                	mov    %ebp,%eax
  8010a3:	89 f7                	mov    %esi,%edi
  8010a5:	f7 f1                	div    %ecx
  8010a7:	89 fa                	mov    %edi,%edx
  8010a9:	83 c4 1c             	add    $0x1c,%esp
  8010ac:	5b                   	pop    %ebx
  8010ad:	5e                   	pop    %esi
  8010ae:	5f                   	pop    %edi
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    
  8010b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010b8:	39 f2                	cmp    %esi,%edx
  8010ba:	77 1c                	ja     8010d8 <__udivdi3+0x88>
  8010bc:	0f bd fa             	bsr    %edx,%edi
  8010bf:	83 f7 1f             	xor    $0x1f,%edi
  8010c2:	75 2c                	jne    8010f0 <__udivdi3+0xa0>
  8010c4:	39 f2                	cmp    %esi,%edx
  8010c6:	72 06                	jb     8010ce <__udivdi3+0x7e>
  8010c8:	31 c0                	xor    %eax,%eax
  8010ca:	39 eb                	cmp    %ebp,%ebx
  8010cc:	77 a9                	ja     801077 <__udivdi3+0x27>
  8010ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d3:	eb a2                	jmp    801077 <__udivdi3+0x27>
  8010d5:	8d 76 00             	lea    0x0(%esi),%esi
  8010d8:	31 ff                	xor    %edi,%edi
  8010da:	31 c0                	xor    %eax,%eax
  8010dc:	89 fa                	mov    %edi,%edx
  8010de:	83 c4 1c             	add    $0x1c,%esp
  8010e1:	5b                   	pop    %ebx
  8010e2:	5e                   	pop    %esi
  8010e3:	5f                   	pop    %edi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    
  8010e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010ed:	8d 76 00             	lea    0x0(%esi),%esi
  8010f0:	89 f9                	mov    %edi,%ecx
  8010f2:	b8 20 00 00 00       	mov    $0x20,%eax
  8010f7:	29 f8                	sub    %edi,%eax
  8010f9:	d3 e2                	shl    %cl,%edx
  8010fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8010ff:	89 c1                	mov    %eax,%ecx
  801101:	89 da                	mov    %ebx,%edx
  801103:	d3 ea                	shr    %cl,%edx
  801105:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801109:	09 d1                	or     %edx,%ecx
  80110b:	89 f2                	mov    %esi,%edx
  80110d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801111:	89 f9                	mov    %edi,%ecx
  801113:	d3 e3                	shl    %cl,%ebx
  801115:	89 c1                	mov    %eax,%ecx
  801117:	d3 ea                	shr    %cl,%edx
  801119:	89 f9                	mov    %edi,%ecx
  80111b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80111f:	89 eb                	mov    %ebp,%ebx
  801121:	d3 e6                	shl    %cl,%esi
  801123:	89 c1                	mov    %eax,%ecx
  801125:	d3 eb                	shr    %cl,%ebx
  801127:	09 de                	or     %ebx,%esi
  801129:	89 f0                	mov    %esi,%eax
  80112b:	f7 74 24 08          	divl   0x8(%esp)
  80112f:	89 d6                	mov    %edx,%esi
  801131:	89 c3                	mov    %eax,%ebx
  801133:	f7 64 24 0c          	mull   0xc(%esp)
  801137:	39 d6                	cmp    %edx,%esi
  801139:	72 15                	jb     801150 <__udivdi3+0x100>
  80113b:	89 f9                	mov    %edi,%ecx
  80113d:	d3 e5                	shl    %cl,%ebp
  80113f:	39 c5                	cmp    %eax,%ebp
  801141:	73 04                	jae    801147 <__udivdi3+0xf7>
  801143:	39 d6                	cmp    %edx,%esi
  801145:	74 09                	je     801150 <__udivdi3+0x100>
  801147:	89 d8                	mov    %ebx,%eax
  801149:	31 ff                	xor    %edi,%edi
  80114b:	e9 27 ff ff ff       	jmp    801077 <__udivdi3+0x27>
  801150:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801153:	31 ff                	xor    %edi,%edi
  801155:	e9 1d ff ff ff       	jmp    801077 <__udivdi3+0x27>
  80115a:	66 90                	xchg   %ax,%ax
  80115c:	66 90                	xchg   %ax,%ax
  80115e:	66 90                	xchg   %ax,%ax

00801160 <__umoddi3>:
  801160:	55                   	push   %ebp
  801161:	57                   	push   %edi
  801162:	56                   	push   %esi
  801163:	53                   	push   %ebx
  801164:	83 ec 1c             	sub    $0x1c,%esp
  801167:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80116b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80116f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801177:	89 da                	mov    %ebx,%edx
  801179:	85 c0                	test   %eax,%eax
  80117b:	75 43                	jne    8011c0 <__umoddi3+0x60>
  80117d:	39 df                	cmp    %ebx,%edi
  80117f:	76 17                	jbe    801198 <__umoddi3+0x38>
  801181:	89 f0                	mov    %esi,%eax
  801183:	f7 f7                	div    %edi
  801185:	89 d0                	mov    %edx,%eax
  801187:	31 d2                	xor    %edx,%edx
  801189:	83 c4 1c             	add    $0x1c,%esp
  80118c:	5b                   	pop    %ebx
  80118d:	5e                   	pop    %esi
  80118e:	5f                   	pop    %edi
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    
  801191:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801198:	89 fd                	mov    %edi,%ebp
  80119a:	85 ff                	test   %edi,%edi
  80119c:	75 0b                	jne    8011a9 <__umoddi3+0x49>
  80119e:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a3:	31 d2                	xor    %edx,%edx
  8011a5:	f7 f7                	div    %edi
  8011a7:	89 c5                	mov    %eax,%ebp
  8011a9:	89 d8                	mov    %ebx,%eax
  8011ab:	31 d2                	xor    %edx,%edx
  8011ad:	f7 f5                	div    %ebp
  8011af:	89 f0                	mov    %esi,%eax
  8011b1:	f7 f5                	div    %ebp
  8011b3:	89 d0                	mov    %edx,%eax
  8011b5:	eb d0                	jmp    801187 <__umoddi3+0x27>
  8011b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011be:	66 90                	xchg   %ax,%ax
  8011c0:	89 f1                	mov    %esi,%ecx
  8011c2:	39 d8                	cmp    %ebx,%eax
  8011c4:	76 0a                	jbe    8011d0 <__umoddi3+0x70>
  8011c6:	89 f0                	mov    %esi,%eax
  8011c8:	83 c4 1c             	add    $0x1c,%esp
  8011cb:	5b                   	pop    %ebx
  8011cc:	5e                   	pop    %esi
  8011cd:	5f                   	pop    %edi
  8011ce:	5d                   	pop    %ebp
  8011cf:	c3                   	ret    
  8011d0:	0f bd e8             	bsr    %eax,%ebp
  8011d3:	83 f5 1f             	xor    $0x1f,%ebp
  8011d6:	75 20                	jne    8011f8 <__umoddi3+0x98>
  8011d8:	39 d8                	cmp    %ebx,%eax
  8011da:	0f 82 b0 00 00 00    	jb     801290 <__umoddi3+0x130>
  8011e0:	39 f7                	cmp    %esi,%edi
  8011e2:	0f 86 a8 00 00 00    	jbe    801290 <__umoddi3+0x130>
  8011e8:	89 c8                	mov    %ecx,%eax
  8011ea:	83 c4 1c             	add    $0x1c,%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    
  8011f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011f8:	89 e9                	mov    %ebp,%ecx
  8011fa:	ba 20 00 00 00       	mov    $0x20,%edx
  8011ff:	29 ea                	sub    %ebp,%edx
  801201:	d3 e0                	shl    %cl,%eax
  801203:	89 44 24 08          	mov    %eax,0x8(%esp)
  801207:	89 d1                	mov    %edx,%ecx
  801209:	89 f8                	mov    %edi,%eax
  80120b:	d3 e8                	shr    %cl,%eax
  80120d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801211:	89 54 24 04          	mov    %edx,0x4(%esp)
  801215:	8b 54 24 04          	mov    0x4(%esp),%edx
  801219:	09 c1                	or     %eax,%ecx
  80121b:	89 d8                	mov    %ebx,%eax
  80121d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801221:	89 e9                	mov    %ebp,%ecx
  801223:	d3 e7                	shl    %cl,%edi
  801225:	89 d1                	mov    %edx,%ecx
  801227:	d3 e8                	shr    %cl,%eax
  801229:	89 e9                	mov    %ebp,%ecx
  80122b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80122f:	d3 e3                	shl    %cl,%ebx
  801231:	89 c7                	mov    %eax,%edi
  801233:	89 d1                	mov    %edx,%ecx
  801235:	89 f0                	mov    %esi,%eax
  801237:	d3 e8                	shr    %cl,%eax
  801239:	89 e9                	mov    %ebp,%ecx
  80123b:	89 fa                	mov    %edi,%edx
  80123d:	d3 e6                	shl    %cl,%esi
  80123f:	09 d8                	or     %ebx,%eax
  801241:	f7 74 24 08          	divl   0x8(%esp)
  801245:	89 d1                	mov    %edx,%ecx
  801247:	89 f3                	mov    %esi,%ebx
  801249:	f7 64 24 0c          	mull   0xc(%esp)
  80124d:	89 c6                	mov    %eax,%esi
  80124f:	89 d7                	mov    %edx,%edi
  801251:	39 d1                	cmp    %edx,%ecx
  801253:	72 06                	jb     80125b <__umoddi3+0xfb>
  801255:	75 10                	jne    801267 <__umoddi3+0x107>
  801257:	39 c3                	cmp    %eax,%ebx
  801259:	73 0c                	jae    801267 <__umoddi3+0x107>
  80125b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80125f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801263:	89 d7                	mov    %edx,%edi
  801265:	89 c6                	mov    %eax,%esi
  801267:	89 ca                	mov    %ecx,%edx
  801269:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80126e:	29 f3                	sub    %esi,%ebx
  801270:	19 fa                	sbb    %edi,%edx
  801272:	89 d0                	mov    %edx,%eax
  801274:	d3 e0                	shl    %cl,%eax
  801276:	89 e9                	mov    %ebp,%ecx
  801278:	d3 eb                	shr    %cl,%ebx
  80127a:	d3 ea                	shr    %cl,%edx
  80127c:	09 d8                	or     %ebx,%eax
  80127e:	83 c4 1c             	add    $0x1c,%esp
  801281:	5b                   	pop    %ebx
  801282:	5e                   	pop    %esi
  801283:	5f                   	pop    %edi
  801284:	5d                   	pop    %ebp
  801285:	c3                   	ret    
  801286:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80128d:	8d 76 00             	lea    0x0(%esi),%esi
  801290:	89 da                	mov    %ebx,%edx
  801292:	29 fe                	sub    %edi,%esi
  801294:	19 c2                	sbb    %eax,%edx
  801296:	89 f1                	mov    %esi,%ecx
  801298:	89 c8                	mov    %ecx,%eax
  80129a:	e9 4b ff ff ff       	jmp    8011ea <__umoddi3+0x8a>
