
obj/user/pingpong:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 e4 0e 00 00       	call   800f25 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 4f                	jne    800097 <umain+0x64>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800048:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004b:	83 ec 04             	sub    $0x4,%esp
  80004e:	6a 00                	push   $0x0
  800050:	6a 00                	push   $0x0
  800052:	56                   	push   %esi
  800053:	e8 fb 0e 00 00       	call   800f53 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80005d:	e8 95 0c 00 00       	call   800cf7 <sys_getenvid>
  800062:	57                   	push   %edi
  800063:	53                   	push   %ebx
  800064:	50                   	push   %eax
  800065:	68 76 12 80 00       	push   $0x801276
  80006a:	e8 3e 01 00 00       	call   8001ad <cprintf>
		if (i == 10)
  80006f:	83 c4 20             	add    $0x20,%esp
  800072:	83 fb 0a             	cmp    $0xa,%ebx
  800075:	74 18                	je     80008f <umain+0x5c>
			return;
		i++;
  800077:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007a:	6a 00                	push   $0x0
  80007c:	6a 00                	push   $0x0
  80007e:	53                   	push   %ebx
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 e3 0e 00 00       	call   800f6a <ipc_send>
		if (i == 10)
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	83 fb 0a             	cmp    $0xa,%ebx
  80008d:	75 bc                	jne    80004b <umain+0x18>
			return;
	}

}
  80008f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800092:	5b                   	pop    %ebx
  800093:	5e                   	pop    %esi
  800094:	5f                   	pop    %edi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    
  800097:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800099:	e8 59 0c 00 00       	call   800cf7 <sys_getenvid>
  80009e:	83 ec 04             	sub    $0x4,%esp
  8000a1:	53                   	push   %ebx
  8000a2:	50                   	push   %eax
  8000a3:	68 60 12 80 00       	push   $0x801260
  8000a8:	e8 00 01 00 00       	call   8001ad <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ad:	6a 00                	push   $0x0
  8000af:	6a 00                	push   $0x0
  8000b1:	6a 00                	push   $0x0
  8000b3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000b6:	e8 af 0e 00 00       	call   800f6a <ipc_send>
  8000bb:	83 c4 20             	add    $0x20,%esp
  8000be:	eb 88                	jmp    800048 <umain+0x15>

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	56                   	push   %esi
  8000c4:	53                   	push   %ebx
  8000c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000cb:	e8 27 0c 00 00       	call   800cf7 <sys_getenvid>
  8000d0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d5:	c1 e0 07             	shl    $0x7,%eax
  8000d8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000dd:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e2:	85 db                	test   %ebx,%ebx
  8000e4:	7e 07                	jle    8000ed <libmain+0x2d>
		binaryname = argv[0];
  8000e6:	8b 06                	mov    (%esi),%eax
  8000e8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ed:	83 ec 08             	sub    $0x8,%esp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	e8 3c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f7:	e8 0a 00 00 00       	call   800106 <exit>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800102:	5b                   	pop    %ebx
  800103:	5e                   	pop    %esi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80010c:	6a 00                	push   $0x0
  80010e:	e8 a3 0b 00 00       	call   800cb6 <sys_env_destroy>
}
  800113:	83 c4 10             	add    $0x10,%esp
  800116:	c9                   	leave  
  800117:	c3                   	ret    

00800118 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	53                   	push   %ebx
  80011c:	83 ec 04             	sub    $0x4,%esp
  80011f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800122:	8b 13                	mov    (%ebx),%edx
  800124:	8d 42 01             	lea    0x1(%edx),%eax
  800127:	89 03                	mov    %eax,(%ebx)
  800129:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80012c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800130:	3d ff 00 00 00       	cmp    $0xff,%eax
  800135:	74 09                	je     800140 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800137:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 28 0b 00 00       	call   800c79 <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
  80015a:	eb db                	jmp    800137 <putch+0x1f>

0080015c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800165:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80016c:	00 00 00 
	b.cnt = 0;
  80016f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800176:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800179:	ff 75 0c             	pushl  0xc(%ebp)
  80017c:	ff 75 08             	pushl  0x8(%ebp)
  80017f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800185:	50                   	push   %eax
  800186:	68 18 01 80 00       	push   $0x800118
  80018b:	e8 fb 00 00 00       	call   80028b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800190:	83 c4 08             	add    $0x8,%esp
  800193:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800199:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019f:	50                   	push   %eax
  8001a0:	e8 d4 0a 00 00       	call   800c79 <sys_cputs>

	return b.cnt;
}
  8001a5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ab:	c9                   	leave  
  8001ac:	c3                   	ret    

008001ad <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b6:	50                   	push   %eax
  8001b7:	ff 75 08             	pushl  0x8(%ebp)
  8001ba:	e8 9d ff ff ff       	call   80015c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bf:	c9                   	leave  
  8001c0:	c3                   	ret    

008001c1 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c1:	55                   	push   %ebp
  8001c2:	89 e5                	mov    %esp,%ebp
  8001c4:	57                   	push   %edi
  8001c5:	56                   	push   %esi
  8001c6:	53                   	push   %ebx
  8001c7:	83 ec 1c             	sub    $0x1c,%esp
  8001ca:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001cd:	89 d3                	mov    %edx,%ebx
  8001cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8001d2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  8001db:	89 c2                	mov    %eax,%edx
  8001dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001e8:	39 c6                	cmp    %eax,%esi
  8001ea:	89 f8                	mov    %edi,%eax
  8001ec:	19 c8                	sbb    %ecx,%eax
  8001ee:	73 32                	jae    800222 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  8001f0:	83 ec 08             	sub    $0x8,%esp
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 04             	sub    $0x4,%esp
  8001f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fd:	57                   	push   %edi
  8001fe:	56                   	push   %esi
  8001ff:	e8 1c 0f 00 00       	call   801120 <__umoddi3>
  800204:	83 c4 14             	add    $0x14,%esp
  800207:	0f be 80 93 12 80 00 	movsbl 0x801293(%eax),%eax
  80020e:	50                   	push   %eax
  80020f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800212:	ff d0                	call   *%eax
	return remain - 1;
  800214:	8b 45 14             	mov    0x14(%ebp),%eax
  800217:	83 e8 01             	sub    $0x1,%eax
}
  80021a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5f                   	pop    %edi
  800220:	5d                   	pop    %ebp
  800221:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  800222:	83 ec 0c             	sub    $0xc,%esp
  800225:	ff 75 18             	pushl  0x18(%ebp)
  800228:	ff 75 14             	pushl  0x14(%ebp)
  80022b:	ff 75 d8             	pushl  -0x28(%ebp)
  80022e:	83 ec 08             	sub    $0x8,%esp
  800231:	51                   	push   %ecx
  800232:	52                   	push   %edx
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	e8 d6 0d 00 00       	call   801010 <__udivdi3>
  80023a:	83 c4 18             	add    $0x18,%esp
  80023d:	52                   	push   %edx
  80023e:	50                   	push   %eax
  80023f:	89 da                	mov    %ebx,%edx
  800241:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800244:	e8 78 ff ff ff       	call   8001c1 <printnum_helper>
  800249:	89 45 14             	mov    %eax,0x14(%ebp)
  80024c:	83 c4 20             	add    $0x20,%esp
  80024f:	eb 9f                	jmp    8001f0 <printnum_helper+0x2f>

00800251 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800251:	55                   	push   %ebp
  800252:	89 e5                	mov    %esp,%ebp
  800254:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800257:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025b:	8b 10                	mov    (%eax),%edx
  80025d:	3b 50 04             	cmp    0x4(%eax),%edx
  800260:	73 0a                	jae    80026c <sprintputch+0x1b>
		*b->buf++ = ch;
  800262:	8d 4a 01             	lea    0x1(%edx),%ecx
  800265:	89 08                	mov    %ecx,(%eax)
  800267:	8b 45 08             	mov    0x8(%ebp),%eax
  80026a:	88 02                	mov    %al,(%edx)
}
  80026c:	5d                   	pop    %ebp
  80026d:	c3                   	ret    

0080026e <printfmt>:
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800274:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800277:	50                   	push   %eax
  800278:	ff 75 10             	pushl  0x10(%ebp)
  80027b:	ff 75 0c             	pushl  0xc(%ebp)
  80027e:	ff 75 08             	pushl  0x8(%ebp)
  800281:	e8 05 00 00 00       	call   80028b <vprintfmt>
}
  800286:	83 c4 10             	add    $0x10,%esp
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <vprintfmt>:
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 3c             	sub    $0x3c,%esp
  800294:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800297:	8b 75 0c             	mov    0xc(%ebp),%esi
  80029a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80029d:	e9 3f 05 00 00       	jmp    8007e1 <vprintfmt+0x556>
		padc = ' ';
  8002a2:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  8002a6:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  8002ad:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8002b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  8002bb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  8002c2:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8002c9:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002ce:	8d 47 01             	lea    0x1(%edi),%eax
  8002d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002d4:	0f b6 17             	movzbl (%edi),%edx
  8002d7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002da:	3c 55                	cmp    $0x55,%al
  8002dc:	0f 87 98 05 00 00    	ja     80087a <vprintfmt+0x5ef>
  8002e2:	0f b6 c0             	movzbl %al,%eax
  8002e5:	ff 24 85 e0 13 80 00 	jmp    *0x8013e0(,%eax,4)
  8002ec:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  8002ef:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8002f3:	eb d9                	jmp    8002ce <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8002f5:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  8002f8:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  8002ff:	eb cd                	jmp    8002ce <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800301:	0f b6 d2             	movzbl %dl,%edx
  800304:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800307:	b8 00 00 00 00       	mov    $0x0,%eax
  80030c:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  80030f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800312:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800316:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800319:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80031c:	83 fb 09             	cmp    $0x9,%ebx
  80031f:	77 5c                	ja     80037d <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  800321:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800324:	eb e9                	jmp    80030f <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  800329:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  80032d:	eb 9f                	jmp    8002ce <vprintfmt+0x43>
			precision = va_arg(ap, int);
  80032f:	8b 45 14             	mov    0x14(%ebp),%eax
  800332:	8b 00                	mov    (%eax),%eax
  800334:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800337:	8b 45 14             	mov    0x14(%ebp),%eax
  80033a:	8d 40 04             	lea    0x4(%eax),%eax
  80033d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  800343:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800347:	79 85                	jns    8002ce <vprintfmt+0x43>
				width = precision, precision = -1;
  800349:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800356:	e9 73 ff ff ff       	jmp    8002ce <vprintfmt+0x43>
  80035b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80035e:	85 c0                	test   %eax,%eax
  800360:	0f 48 c1             	cmovs  %ecx,%eax
  800363:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800366:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800369:	e9 60 ff ff ff       	jmp    8002ce <vprintfmt+0x43>
  80036e:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  800371:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800378:	e9 51 ff ff ff       	jmp    8002ce <vprintfmt+0x43>
  80037d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800380:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800383:	eb be                	jmp    800343 <vprintfmt+0xb8>
			lflag++;
  800385:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  80038c:	e9 3d ff ff ff       	jmp    8002ce <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  800391:	8b 45 14             	mov    0x14(%ebp),%eax
  800394:	8d 78 04             	lea    0x4(%eax),%edi
  800397:	83 ec 08             	sub    $0x8,%esp
  80039a:	56                   	push   %esi
  80039b:	ff 30                	pushl  (%eax)
  80039d:	ff d3                	call   *%ebx
			break;
  80039f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a5:	e9 34 04 00 00       	jmp    8007de <vprintfmt+0x553>
			err = va_arg(ap, int);
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8d 78 04             	lea    0x4(%eax),%edi
  8003b0:	8b 00                	mov    (%eax),%eax
  8003b2:	99                   	cltd   
  8003b3:	31 d0                	xor    %edx,%eax
  8003b5:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b7:	83 f8 08             	cmp    $0x8,%eax
  8003ba:	7f 23                	jg     8003df <vprintfmt+0x154>
  8003bc:	8b 14 85 40 15 80 00 	mov    0x801540(,%eax,4),%edx
  8003c3:	85 d2                	test   %edx,%edx
  8003c5:	74 18                	je     8003df <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  8003c7:	52                   	push   %edx
  8003c8:	68 b4 12 80 00       	push   $0x8012b4
  8003cd:	56                   	push   %esi
  8003ce:	53                   	push   %ebx
  8003cf:	e8 9a fe ff ff       	call   80026e <printfmt>
  8003d4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003da:	e9 ff 03 00 00       	jmp    8007de <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  8003df:	50                   	push   %eax
  8003e0:	68 ab 12 80 00       	push   $0x8012ab
  8003e5:	56                   	push   %esi
  8003e6:	53                   	push   %ebx
  8003e7:	e8 82 fe ff ff       	call   80026e <printfmt>
  8003ec:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ef:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f2:	e9 e7 03 00 00       	jmp    8007de <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	83 c0 04             	add    $0x4,%eax
  8003fd:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800405:	85 c9                	test   %ecx,%ecx
  800407:	b8 a4 12 80 00       	mov    $0x8012a4,%eax
  80040c:	0f 45 c1             	cmovne %ecx,%eax
  80040f:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800412:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800416:	7e 06                	jle    80041e <vprintfmt+0x193>
  800418:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  80041c:	75 0d                	jne    80042b <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80041e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800421:	89 c7                	mov    %eax,%edi
  800423:	03 45 d8             	add    -0x28(%ebp),%eax
  800426:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800429:	eb 53                	jmp    80047e <vprintfmt+0x1f3>
  80042b:	83 ec 08             	sub    $0x8,%esp
  80042e:	ff 75 e0             	pushl  -0x20(%ebp)
  800431:	50                   	push   %eax
  800432:	e8 eb 04 00 00       	call   800922 <strnlen>
  800437:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80043a:	29 c1                	sub    %eax,%ecx
  80043c:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  80043f:	83 c4 10             	add    $0x10,%esp
  800442:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800444:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  800448:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80044b:	eb 0f                	jmp    80045c <vprintfmt+0x1d1>
					putch(padc, putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	56                   	push   %esi
  800451:	ff 75 d8             	pushl  -0x28(%ebp)
  800454:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800456:	83 ef 01             	sub    $0x1,%edi
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 ff                	test   %edi,%edi
  80045e:	7f ed                	jg     80044d <vprintfmt+0x1c2>
  800460:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800463:	85 c9                	test   %ecx,%ecx
  800465:	b8 00 00 00 00       	mov    $0x0,%eax
  80046a:	0f 49 c1             	cmovns %ecx,%eax
  80046d:	29 c1                	sub    %eax,%ecx
  80046f:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800472:	eb aa                	jmp    80041e <vprintfmt+0x193>
					putch(ch, putdat);
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	56                   	push   %esi
  800478:	52                   	push   %edx
  800479:	ff d3                	call   *%ebx
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800481:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800483:	83 c7 01             	add    $0x1,%edi
  800486:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80048a:	0f be d0             	movsbl %al,%edx
  80048d:	85 d2                	test   %edx,%edx
  80048f:	74 2e                	je     8004bf <vprintfmt+0x234>
  800491:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800495:	78 06                	js     80049d <vprintfmt+0x212>
  800497:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80049b:	78 1e                	js     8004bb <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  80049d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004a1:	74 d1                	je     800474 <vprintfmt+0x1e9>
  8004a3:	0f be c0             	movsbl %al,%eax
  8004a6:	83 e8 20             	sub    $0x20,%eax
  8004a9:	83 f8 5e             	cmp    $0x5e,%eax
  8004ac:	76 c6                	jbe    800474 <vprintfmt+0x1e9>
					putch('?', putdat);
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	56                   	push   %esi
  8004b2:	6a 3f                	push   $0x3f
  8004b4:	ff d3                	call   *%ebx
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	eb c3                	jmp    80047e <vprintfmt+0x1f3>
  8004bb:	89 cf                	mov    %ecx,%edi
  8004bd:	eb 02                	jmp    8004c1 <vprintfmt+0x236>
  8004bf:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  8004c1:	85 ff                	test   %edi,%edi
  8004c3:	7e 10                	jle    8004d5 <vprintfmt+0x24a>
				putch(' ', putdat);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	56                   	push   %esi
  8004c9:	6a 20                	push   $0x20
  8004cb:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8004cd:	83 ef 01             	sub    $0x1,%edi
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	eb ec                	jmp    8004c1 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  8004d5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8004d8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004db:	e9 fe 02 00 00       	jmp    8007de <vprintfmt+0x553>
	if (lflag >= 2)
  8004e0:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8004e4:	7f 21                	jg     800507 <vprintfmt+0x27c>
	else if (lflag)
  8004e6:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8004ea:	74 79                	je     800565 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  8004ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f4:	89 c1                	mov    %eax,%ecx
  8004f6:	c1 f9 1f             	sar    $0x1f,%ecx
  8004f9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ff:	8d 40 04             	lea    0x4(%eax),%eax
  800502:	89 45 14             	mov    %eax,0x14(%ebp)
  800505:	eb 17                	jmp    80051e <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	8b 50 04             	mov    0x4(%eax),%edx
  80050d:	8b 00                	mov    (%eax),%eax
  80050f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800512:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 40 08             	lea    0x8(%eax),%eax
  80051b:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  80051e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800521:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800524:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800527:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  80052a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052e:	78 50                	js     800580 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  800530:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800533:	c1 fa 1f             	sar    $0x1f,%edx
  800536:	89 d0                	mov    %edx,%eax
  800538:	2b 45 e0             	sub    -0x20(%ebp),%eax
  80053b:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  80053e:	85 d2                	test   %edx,%edx
  800540:	0f 89 14 02 00 00    	jns    80075a <vprintfmt+0x4cf>
  800546:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80054a:	0f 84 0a 02 00 00    	je     80075a <vprintfmt+0x4cf>
				putch('+', putdat);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	56                   	push   %esi
  800554:	6a 2b                	push   $0x2b
  800556:	ff d3                	call   *%ebx
  800558:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80055b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800560:	e9 5c 01 00 00       	jmp    8006c1 <vprintfmt+0x436>
		return va_arg(*ap, int);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8b 00                	mov    (%eax),%eax
  80056a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056d:	89 c1                	mov    %eax,%ecx
  80056f:	c1 f9 1f             	sar    $0x1f,%ecx
  800572:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8d 40 04             	lea    0x4(%eax),%eax
  80057b:	89 45 14             	mov    %eax,0x14(%ebp)
  80057e:	eb 9e                	jmp    80051e <vprintfmt+0x293>
				putch('-', putdat);
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	56                   	push   %esi
  800584:	6a 2d                	push   $0x2d
  800586:	ff d3                	call   *%ebx
				num = -(long long) num;
  800588:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058e:	f7 d8                	neg    %eax
  800590:	83 d2 00             	adc    $0x0,%edx
  800593:	f7 da                	neg    %edx
  800595:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800598:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80059b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80059e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a3:	e9 19 01 00 00       	jmp    8006c1 <vprintfmt+0x436>
	if (lflag >= 2)
  8005a8:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8005ac:	7f 29                	jg     8005d7 <vprintfmt+0x34c>
	else if (lflag)
  8005ae:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8005b2:	74 44                	je     8005f8 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 00                	mov    (%eax),%eax
  8005b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005be:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d2:	e9 ea 00 00 00       	jmp    8006c1 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 50 04             	mov    0x4(%eax),%edx
  8005dd:	8b 00                	mov    (%eax),%eax
  8005df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005e2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e8:	8d 40 08             	lea    0x8(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ee:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f3:	e9 c9 00 00 00       	jmp    8006c1 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800602:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800605:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 40 04             	lea    0x4(%eax),%eax
  80060e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800611:	b8 0a 00 00 00       	mov    $0xa,%eax
  800616:	e9 a6 00 00 00       	jmp    8006c1 <vprintfmt+0x436>
			putch('0', putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	56                   	push   %esi
  80061f:	6a 30                	push   $0x30
  800621:	ff d3                	call   *%ebx
	if (lflag >= 2)
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80062a:	7f 26                	jg     800652 <vprintfmt+0x3c7>
	else if (lflag)
  80062c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800630:	74 3e                	je     800670 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 00                	mov    (%eax),%eax
  800637:	ba 00 00 00 00       	mov    $0x0,%edx
  80063c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80063f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 40 04             	lea    0x4(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80064b:	b8 08 00 00 00       	mov    $0x8,%eax
  800650:	eb 6f                	jmp    8006c1 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 50 04             	mov    0x4(%eax),%edx
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80065d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 40 08             	lea    0x8(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800669:	b8 08 00 00 00       	mov    $0x8,%eax
  80066e:	eb 51                	jmp    8006c1 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 00                	mov    (%eax),%eax
  800675:	ba 00 00 00 00       	mov    $0x0,%edx
  80067a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80067d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800689:	b8 08 00 00 00       	mov    $0x8,%eax
  80068e:	eb 31                	jmp    8006c1 <vprintfmt+0x436>
			putch('0', putdat);
  800690:	83 ec 08             	sub    $0x8,%esp
  800693:	56                   	push   %esi
  800694:	6a 30                	push   $0x30
  800696:	ff d3                	call   *%ebx
			putch('x', putdat);
  800698:	83 c4 08             	add    $0x8,%esp
  80069b:	56                   	push   %esi
  80069c:	6a 78                	push   $0x78
  80069e:	ff d3                	call   *%ebx
			num = (unsigned long long)
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8b 00                	mov    (%eax),%eax
  8006a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8006aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006ad:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  8006b0:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006bc:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006c1:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8006c5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006c8:	89 c1                	mov    %eax,%ecx
  8006ca:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  8006cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006d0:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  8006d5:	89 c2                	mov    %eax,%edx
  8006d7:	39 c1                	cmp    %eax,%ecx
  8006d9:	0f 87 85 00 00 00    	ja     800764 <vprintfmt+0x4d9>
		tmp /= base;
  8006df:	89 d0                	mov    %edx,%eax
  8006e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e6:	f7 f1                	div    %ecx
		len++;
  8006e8:	83 c7 01             	add    $0x1,%edi
  8006eb:	eb e8                	jmp    8006d5 <vprintfmt+0x44a>
	if (lflag >= 2)
  8006ed:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8006f1:	7f 26                	jg     800719 <vprintfmt+0x48e>
	else if (lflag)
  8006f3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006f7:	74 3e                	je     800737 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8b 00                	mov    (%eax),%eax
  8006fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800703:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800706:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8d 40 04             	lea    0x4(%eax),%eax
  80070f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800712:	b8 10 00 00 00       	mov    $0x10,%eax
  800717:	eb a8                	jmp    8006c1 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8b 50 04             	mov    0x4(%eax),%edx
  80071f:	8b 00                	mov    (%eax),%eax
  800721:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800724:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	8d 40 08             	lea    0x8(%eax),%eax
  80072d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800730:	b8 10 00 00 00       	mov    $0x10,%eax
  800735:	eb 8a                	jmp    8006c1 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800737:	8b 45 14             	mov    0x14(%ebp),%eax
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	ba 00 00 00 00       	mov    $0x0,%edx
  800741:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800744:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8d 40 04             	lea    0x4(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800750:	b8 10 00 00 00       	mov    $0x10,%eax
  800755:	e9 67 ff ff ff       	jmp    8006c1 <vprintfmt+0x436>
			base = 10;
  80075a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075f:	e9 5d ff ff ff       	jmp    8006c1 <vprintfmt+0x436>
  800764:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  800767:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80076a:	29 f8                	sub    %edi,%eax
  80076c:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  80076e:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  800772:	74 15                	je     800789 <vprintfmt+0x4fe>
		while (width > 0) {
  800774:	85 ff                	test   %edi,%edi
  800776:	7e 48                	jle    8007c0 <vprintfmt+0x535>
			putch(padc, putdat);
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	56                   	push   %esi
  80077c:	ff 75 e0             	pushl  -0x20(%ebp)
  80077f:	ff d3                	call   *%ebx
			width--;
  800781:	83 ef 01             	sub    $0x1,%edi
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb eb                	jmp    800774 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800789:	83 ec 0c             	sub    $0xc,%esp
  80078c:	6a 2d                	push   $0x2d
  80078e:	ff 75 cc             	pushl  -0x34(%ebp)
  800791:	ff 75 c8             	pushl  -0x38(%ebp)
  800794:	ff 75 d4             	pushl  -0x2c(%ebp)
  800797:	ff 75 d0             	pushl  -0x30(%ebp)
  80079a:	89 f2                	mov    %esi,%edx
  80079c:	89 d8                	mov    %ebx,%eax
  80079e:	e8 1e fa ff ff       	call   8001c1 <printnum_helper>
		width -= len;
  8007a3:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007a6:	2b 7d cc             	sub    -0x34(%ebp),%edi
  8007a9:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  8007ac:	85 ff                	test   %edi,%edi
  8007ae:	7e 2e                	jle    8007de <vprintfmt+0x553>
			putch(padc, putdat);
  8007b0:	83 ec 08             	sub    $0x8,%esp
  8007b3:	56                   	push   %esi
  8007b4:	6a 20                	push   $0x20
  8007b6:	ff d3                	call   *%ebx
			width--;
  8007b8:	83 ef 01             	sub    $0x1,%edi
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	eb ec                	jmp    8007ac <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  8007c0:	83 ec 0c             	sub    $0xc,%esp
  8007c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c6:	ff 75 cc             	pushl  -0x34(%ebp)
  8007c9:	ff 75 c8             	pushl  -0x38(%ebp)
  8007cc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007cf:	ff 75 d0             	pushl  -0x30(%ebp)
  8007d2:	89 f2                	mov    %esi,%edx
  8007d4:	89 d8                	mov    %ebx,%eax
  8007d6:	e8 e6 f9 ff ff       	call   8001c1 <printnum_helper>
  8007db:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  8007de:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007e1:	83 c7 01             	add    $0x1,%edi
  8007e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007e8:	83 f8 25             	cmp    $0x25,%eax
  8007eb:	0f 84 b1 fa ff ff    	je     8002a2 <vprintfmt+0x17>
			if (ch == '\0')
  8007f1:	85 c0                	test   %eax,%eax
  8007f3:	0f 84 a1 00 00 00    	je     80089a <vprintfmt+0x60f>
			putch(ch, putdat);
  8007f9:	83 ec 08             	sub    $0x8,%esp
  8007fc:	56                   	push   %esi
  8007fd:	50                   	push   %eax
  8007fe:	ff d3                	call   *%ebx
  800800:	83 c4 10             	add    $0x10,%esp
  800803:	eb dc                	jmp    8007e1 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	83 c0 04             	add    $0x4,%eax
  80080b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80080e:	8b 45 14             	mov    0x14(%ebp),%eax
  800811:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800813:	85 ff                	test   %edi,%edi
  800815:	74 15                	je     80082c <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800817:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  80081d:	7f 29                	jg     800848 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  80081f:	0f b6 06             	movzbl (%esi),%eax
  800822:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800824:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800827:	89 45 14             	mov    %eax,0x14(%ebp)
  80082a:	eb b2                	jmp    8007de <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  80082c:	68 4c 13 80 00       	push   $0x80134c
  800831:	68 b4 12 80 00       	push   $0x8012b4
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	e8 31 fa ff ff       	call   80026e <printfmt>
  80083d:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800840:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800843:	89 45 14             	mov    %eax,0x14(%ebp)
  800846:	eb 96                	jmp    8007de <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800848:	68 84 13 80 00       	push   $0x801384
  80084d:	68 b4 12 80 00       	push   $0x8012b4
  800852:	56                   	push   %esi
  800853:	53                   	push   %ebx
  800854:	e8 15 fa ff ff       	call   80026e <printfmt>
				*res = -1;
  800859:	c6 07 ff             	movb   $0xff,(%edi)
  80085c:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  80085f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800862:	89 45 14             	mov    %eax,0x14(%ebp)
  800865:	e9 74 ff ff ff       	jmp    8007de <vprintfmt+0x553>
			putch(ch, putdat);
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	56                   	push   %esi
  80086e:	6a 25                	push   $0x25
  800870:	ff d3                	call   *%ebx
			break;
  800872:	83 c4 10             	add    $0x10,%esp
  800875:	e9 64 ff ff ff       	jmp    8007de <vprintfmt+0x553>
			putch('%', putdat);
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	56                   	push   %esi
  80087e:	6a 25                	push   $0x25
  800880:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800882:	83 c4 10             	add    $0x10,%esp
  800885:	89 f8                	mov    %edi,%eax
  800887:	eb 03                	jmp    80088c <vprintfmt+0x601>
  800889:	83 e8 01             	sub    $0x1,%eax
  80088c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800890:	75 f7                	jne    800889 <vprintfmt+0x5fe>
  800892:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800895:	e9 44 ff ff ff       	jmp    8007de <vprintfmt+0x553>
}
  80089a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80089d:	5b                   	pop    %ebx
  80089e:	5e                   	pop    %esi
  80089f:	5f                   	pop    %edi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	83 ec 18             	sub    $0x18,%esp
  8008a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008bf:	85 c0                	test   %eax,%eax
  8008c1:	74 26                	je     8008e9 <vsnprintf+0x47>
  8008c3:	85 d2                	test   %edx,%edx
  8008c5:	7e 22                	jle    8008e9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c7:	ff 75 14             	pushl  0x14(%ebp)
  8008ca:	ff 75 10             	pushl  0x10(%ebp)
  8008cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d0:	50                   	push   %eax
  8008d1:	68 51 02 80 00       	push   $0x800251
  8008d6:	e8 b0 f9 ff ff       	call   80028b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008de:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e4:	83 c4 10             	add    $0x10,%esp
}
  8008e7:	c9                   	leave  
  8008e8:	c3                   	ret    
		return -E_INVAL;
  8008e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ee:	eb f7                	jmp    8008e7 <vsnprintf+0x45>

008008f0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f9:	50                   	push   %eax
  8008fa:	ff 75 10             	pushl  0x10(%ebp)
  8008fd:	ff 75 0c             	pushl  0xc(%ebp)
  800900:	ff 75 08             	pushl  0x8(%ebp)
  800903:	e8 9a ff ff ff       	call   8008a2 <vsnprintf>
	va_end(ap);

	return rc;
}
  800908:	c9                   	leave  
  800909:	c3                   	ret    

0080090a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
  800915:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800919:	74 05                	je     800920 <strlen+0x16>
		n++;
  80091b:	83 c0 01             	add    $0x1,%eax
  80091e:	eb f5                	jmp    800915 <strlen+0xb>
	return n;
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800928:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092b:	ba 00 00 00 00       	mov    $0x0,%edx
  800930:	39 c2                	cmp    %eax,%edx
  800932:	74 0d                	je     800941 <strnlen+0x1f>
  800934:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800938:	74 05                	je     80093f <strnlen+0x1d>
		n++;
  80093a:	83 c2 01             	add    $0x1,%edx
  80093d:	eb f1                	jmp    800930 <strnlen+0xe>
  80093f:	89 d0                	mov    %edx,%eax
	return n;
}
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	53                   	push   %ebx
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80094d:	ba 00 00 00 00       	mov    $0x0,%edx
  800952:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800956:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800959:	83 c2 01             	add    $0x1,%edx
  80095c:	84 c9                	test   %cl,%cl
  80095e:	75 f2                	jne    800952 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800960:	5b                   	pop    %ebx
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	83 ec 10             	sub    $0x10,%esp
  80096a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80096d:	53                   	push   %ebx
  80096e:	e8 97 ff ff ff       	call   80090a <strlen>
  800973:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800976:	ff 75 0c             	pushl  0xc(%ebp)
  800979:	01 d8                	add    %ebx,%eax
  80097b:	50                   	push   %eax
  80097c:	e8 c2 ff ff ff       	call   800943 <strcpy>
	return dst;
}
  800981:	89 d8                	mov    %ebx,%eax
  800983:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	56                   	push   %esi
  80098c:	53                   	push   %ebx
  80098d:	8b 45 08             	mov    0x8(%ebp),%eax
  800990:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800993:	89 c6                	mov    %eax,%esi
  800995:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800998:	89 c2                	mov    %eax,%edx
  80099a:	39 f2                	cmp    %esi,%edx
  80099c:	74 11                	je     8009af <strncpy+0x27>
		*dst++ = *src;
  80099e:	83 c2 01             	add    $0x1,%edx
  8009a1:	0f b6 19             	movzbl (%ecx),%ebx
  8009a4:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a7:	80 fb 01             	cmp    $0x1,%bl
  8009aa:	83 d9 ff             	sbb    $0xffffffff,%ecx
  8009ad:	eb eb                	jmp    80099a <strncpy+0x12>
	}
	return ret;
}
  8009af:	5b                   	pop    %ebx
  8009b0:	5e                   	pop    %esi
  8009b1:	5d                   	pop    %ebp
  8009b2:	c3                   	ret    

008009b3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	56                   	push   %esi
  8009b7:	53                   	push   %ebx
  8009b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009be:	8b 55 10             	mov    0x10(%ebp),%edx
  8009c1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c3:	85 d2                	test   %edx,%edx
  8009c5:	74 21                	je     8009e8 <strlcpy+0x35>
  8009c7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009cb:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009cd:	39 c2                	cmp    %eax,%edx
  8009cf:	74 14                	je     8009e5 <strlcpy+0x32>
  8009d1:	0f b6 19             	movzbl (%ecx),%ebx
  8009d4:	84 db                	test   %bl,%bl
  8009d6:	74 0b                	je     8009e3 <strlcpy+0x30>
			*dst++ = *src++;
  8009d8:	83 c1 01             	add    $0x1,%ecx
  8009db:	83 c2 01             	add    $0x1,%edx
  8009de:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009e1:	eb ea                	jmp    8009cd <strlcpy+0x1a>
  8009e3:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009e5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e8:	29 f0                	sub    %esi,%eax
}
  8009ea:	5b                   	pop    %ebx
  8009eb:	5e                   	pop    %esi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f7:	0f b6 01             	movzbl (%ecx),%eax
  8009fa:	84 c0                	test   %al,%al
  8009fc:	74 0c                	je     800a0a <strcmp+0x1c>
  8009fe:	3a 02                	cmp    (%edx),%al
  800a00:	75 08                	jne    800a0a <strcmp+0x1c>
		p++, q++;
  800a02:	83 c1 01             	add    $0x1,%ecx
  800a05:	83 c2 01             	add    $0x1,%edx
  800a08:	eb ed                	jmp    8009f7 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0a:	0f b6 c0             	movzbl %al,%eax
  800a0d:	0f b6 12             	movzbl (%edx),%edx
  800a10:	29 d0                	sub    %edx,%eax
}
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1e:	89 c3                	mov    %eax,%ebx
  800a20:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a23:	eb 06                	jmp    800a2b <strncmp+0x17>
		n--, p++, q++;
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a2b:	39 d8                	cmp    %ebx,%eax
  800a2d:	74 16                	je     800a45 <strncmp+0x31>
  800a2f:	0f b6 08             	movzbl (%eax),%ecx
  800a32:	84 c9                	test   %cl,%cl
  800a34:	74 04                	je     800a3a <strncmp+0x26>
  800a36:	3a 0a                	cmp    (%edx),%cl
  800a38:	74 eb                	je     800a25 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3a:	0f b6 00             	movzbl (%eax),%eax
  800a3d:	0f b6 12             	movzbl (%edx),%edx
  800a40:	29 d0                	sub    %edx,%eax
}
  800a42:	5b                   	pop    %ebx
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    
		return 0;
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	eb f6                	jmp    800a42 <strncmp+0x2e>

00800a4c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a52:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a56:	0f b6 10             	movzbl (%eax),%edx
  800a59:	84 d2                	test   %dl,%dl
  800a5b:	74 09                	je     800a66 <strchr+0x1a>
		if (*s == c)
  800a5d:	38 ca                	cmp    %cl,%dl
  800a5f:	74 0a                	je     800a6b <strchr+0x1f>
	for (; *s; s++)
  800a61:	83 c0 01             	add    $0x1,%eax
  800a64:	eb f0                	jmp    800a56 <strchr+0xa>
			return (char *) s;
	return 0;
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    

00800a6d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6d:	55                   	push   %ebp
  800a6e:	89 e5                	mov    %esp,%ebp
  800a70:	8b 45 08             	mov    0x8(%ebp),%eax
  800a73:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a77:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a7a:	38 ca                	cmp    %cl,%dl
  800a7c:	74 09                	je     800a87 <strfind+0x1a>
  800a7e:	84 d2                	test   %dl,%dl
  800a80:	74 05                	je     800a87 <strfind+0x1a>
	for (; *s; s++)
  800a82:	83 c0 01             	add    $0x1,%eax
  800a85:	eb f0                	jmp    800a77 <strfind+0xa>
			break;
	return (char *) s;
}
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	57                   	push   %edi
  800a8d:	56                   	push   %esi
  800a8e:	53                   	push   %ebx
  800a8f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a95:	85 c9                	test   %ecx,%ecx
  800a97:	74 31                	je     800aca <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a99:	89 f8                	mov    %edi,%eax
  800a9b:	09 c8                	or     %ecx,%eax
  800a9d:	a8 03                	test   $0x3,%al
  800a9f:	75 23                	jne    800ac4 <memset+0x3b>
		c &= 0xFF;
  800aa1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa5:	89 d3                	mov    %edx,%ebx
  800aa7:	c1 e3 08             	shl    $0x8,%ebx
  800aaa:	89 d0                	mov    %edx,%eax
  800aac:	c1 e0 18             	shl    $0x18,%eax
  800aaf:	89 d6                	mov    %edx,%esi
  800ab1:	c1 e6 10             	shl    $0x10,%esi
  800ab4:	09 f0                	or     %esi,%eax
  800ab6:	09 c2                	or     %eax,%edx
  800ab8:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aba:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800abd:	89 d0                	mov    %edx,%eax
  800abf:	fc                   	cld    
  800ac0:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac2:	eb 06                	jmp    800aca <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac7:	fc                   	cld    
  800ac8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aca:	89 f8                	mov    %edi,%eax
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5f                   	pop    %edi
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	57                   	push   %edi
  800ad5:	56                   	push   %esi
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800adf:	39 c6                	cmp    %eax,%esi
  800ae1:	73 32                	jae    800b15 <memmove+0x44>
  800ae3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae6:	39 c2                	cmp    %eax,%edx
  800ae8:	76 2b                	jbe    800b15 <memmove+0x44>
		s += n;
		d += n;
  800aea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aed:	89 fe                	mov    %edi,%esi
  800aef:	09 ce                	or     %ecx,%esi
  800af1:	09 d6                	or     %edx,%esi
  800af3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af9:	75 0e                	jne    800b09 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800afb:	83 ef 04             	sub    $0x4,%edi
  800afe:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b01:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b04:	fd                   	std    
  800b05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b07:	eb 09                	jmp    800b12 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b09:	83 ef 01             	sub    $0x1,%edi
  800b0c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b0f:	fd                   	std    
  800b10:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b12:	fc                   	cld    
  800b13:	eb 1a                	jmp    800b2f <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b15:	89 c2                	mov    %eax,%edx
  800b17:	09 ca                	or     %ecx,%edx
  800b19:	09 f2                	or     %esi,%edx
  800b1b:	f6 c2 03             	test   $0x3,%dl
  800b1e:	75 0a                	jne    800b2a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b20:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b23:	89 c7                	mov    %eax,%edi
  800b25:	fc                   	cld    
  800b26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b28:	eb 05                	jmp    800b2f <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b2a:	89 c7                	mov    %eax,%edi
  800b2c:	fc                   	cld    
  800b2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b39:	ff 75 10             	pushl  0x10(%ebp)
  800b3c:	ff 75 0c             	pushl  0xc(%ebp)
  800b3f:	ff 75 08             	pushl  0x8(%ebp)
  800b42:	e8 8a ff ff ff       	call   800ad1 <memmove>
}
  800b47:	c9                   	leave  
  800b48:	c3                   	ret    

00800b49 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b54:	89 c6                	mov    %eax,%esi
  800b56:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b59:	39 f0                	cmp    %esi,%eax
  800b5b:	74 1c                	je     800b79 <memcmp+0x30>
		if (*s1 != *s2)
  800b5d:	0f b6 08             	movzbl (%eax),%ecx
  800b60:	0f b6 1a             	movzbl (%edx),%ebx
  800b63:	38 d9                	cmp    %bl,%cl
  800b65:	75 08                	jne    800b6f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b67:	83 c0 01             	add    $0x1,%eax
  800b6a:	83 c2 01             	add    $0x1,%edx
  800b6d:	eb ea                	jmp    800b59 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b6f:	0f b6 c1             	movzbl %cl,%eax
  800b72:	0f b6 db             	movzbl %bl,%ebx
  800b75:	29 d8                	sub    %ebx,%eax
  800b77:	eb 05                	jmp    800b7e <memcmp+0x35>
	}

	return 0;
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5e                   	pop    %esi
  800b80:	5d                   	pop    %ebp
  800b81:	c3                   	ret    

00800b82 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	8b 45 08             	mov    0x8(%ebp),%eax
  800b88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b8b:	89 c2                	mov    %eax,%edx
  800b8d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b90:	39 d0                	cmp    %edx,%eax
  800b92:	73 09                	jae    800b9d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b94:	38 08                	cmp    %cl,(%eax)
  800b96:	74 05                	je     800b9d <memfind+0x1b>
	for (; s < ends; s++)
  800b98:	83 c0 01             	add    $0x1,%eax
  800b9b:	eb f3                	jmp    800b90 <memfind+0xe>
			break;
	return (void *) s;
}
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bab:	eb 03                	jmp    800bb0 <strtol+0x11>
		s++;
  800bad:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bb0:	0f b6 01             	movzbl (%ecx),%eax
  800bb3:	3c 20                	cmp    $0x20,%al
  800bb5:	74 f6                	je     800bad <strtol+0xe>
  800bb7:	3c 09                	cmp    $0x9,%al
  800bb9:	74 f2                	je     800bad <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bbb:	3c 2b                	cmp    $0x2b,%al
  800bbd:	74 2a                	je     800be9 <strtol+0x4a>
	int neg = 0;
  800bbf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bc4:	3c 2d                	cmp    $0x2d,%al
  800bc6:	74 2b                	je     800bf3 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bce:	75 0f                	jne    800bdf <strtol+0x40>
  800bd0:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd3:	74 28                	je     800bfd <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bd5:	85 db                	test   %ebx,%ebx
  800bd7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bdc:	0f 44 d8             	cmove  %eax,%ebx
  800bdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800be4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800be7:	eb 50                	jmp    800c39 <strtol+0x9a>
		s++;
  800be9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bec:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf1:	eb d5                	jmp    800bc8 <strtol+0x29>
		s++, neg = 1;
  800bf3:	83 c1 01             	add    $0x1,%ecx
  800bf6:	bf 01 00 00 00       	mov    $0x1,%edi
  800bfb:	eb cb                	jmp    800bc8 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bfd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c01:	74 0e                	je     800c11 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c03:	85 db                	test   %ebx,%ebx
  800c05:	75 d8                	jne    800bdf <strtol+0x40>
		s++, base = 8;
  800c07:	83 c1 01             	add    $0x1,%ecx
  800c0a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c0f:	eb ce                	jmp    800bdf <strtol+0x40>
		s += 2, base = 16;
  800c11:	83 c1 02             	add    $0x2,%ecx
  800c14:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c19:	eb c4                	jmp    800bdf <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c1b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c1e:	89 f3                	mov    %esi,%ebx
  800c20:	80 fb 19             	cmp    $0x19,%bl
  800c23:	77 29                	ja     800c4e <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c25:	0f be d2             	movsbl %dl,%edx
  800c28:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c2b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c2e:	7d 30                	jge    800c60 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c30:	83 c1 01             	add    $0x1,%ecx
  800c33:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c37:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c39:	0f b6 11             	movzbl (%ecx),%edx
  800c3c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c3f:	89 f3                	mov    %esi,%ebx
  800c41:	80 fb 09             	cmp    $0x9,%bl
  800c44:	77 d5                	ja     800c1b <strtol+0x7c>
			dig = *s - '0';
  800c46:	0f be d2             	movsbl %dl,%edx
  800c49:	83 ea 30             	sub    $0x30,%edx
  800c4c:	eb dd                	jmp    800c2b <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800c4e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c51:	89 f3                	mov    %esi,%ebx
  800c53:	80 fb 19             	cmp    $0x19,%bl
  800c56:	77 08                	ja     800c60 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c58:	0f be d2             	movsbl %dl,%edx
  800c5b:	83 ea 37             	sub    $0x37,%edx
  800c5e:	eb cb                	jmp    800c2b <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c64:	74 05                	je     800c6b <strtol+0xcc>
		*endptr = (char *) s;
  800c66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c69:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c6b:	89 c2                	mov    %eax,%edx
  800c6d:	f7 da                	neg    %edx
  800c6f:	85 ff                	test   %edi,%edi
  800c71:	0f 45 c2             	cmovne %edx,%eax
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	89 c3                	mov    %eax,%ebx
  800c8c:	89 c7                	mov    %eax,%edi
  800c8e:	89 c6                	mov    %eax,%esi
  800c90:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca7:	89 d1                	mov    %edx,%ecx
  800ca9:	89 d3                	mov    %edx,%ebx
  800cab:	89 d7                	mov    %edx,%edi
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cbf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	b8 03 00 00 00       	mov    $0x3,%eax
  800ccc:	89 cb                	mov    %ecx,%ebx
  800cce:	89 cf                	mov    %ecx,%edi
  800cd0:	89 ce                	mov    %ecx,%esi
  800cd2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	7f 08                	jg     800ce0 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	83 ec 0c             	sub    $0xc,%esp
  800ce3:	50                   	push   %eax
  800ce4:	6a 03                	push   $0x3
  800ce6:	68 64 15 80 00       	push   $0x801564
  800ceb:	6a 23                	push   $0x23
  800ced:	68 81 15 80 00       	push   $0x801581
  800cf2:	e8 c5 02 00 00       	call   800fbc <_panic>

00800cf7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800d02:	b8 02 00 00 00       	mov    $0x2,%eax
  800d07:	89 d1                	mov    %edx,%ecx
  800d09:	89 d3                	mov    %edx,%ebx
  800d0b:	89 d7                	mov    %edx,%edi
  800d0d:	89 d6                	mov    %edx,%esi
  800d0f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_yield>:

void
sys_yield(void)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d21:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d26:	89 d1                	mov    %edx,%ecx
  800d28:	89 d3                	mov    %edx,%ebx
  800d2a:	89 d7                	mov    %edx,%edi
  800d2c:	89 d6                	mov    %edx,%esi
  800d2e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3e:	be 00 00 00 00       	mov    $0x0,%esi
  800d43:	8b 55 08             	mov    0x8(%ebp),%edx
  800d46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d49:	b8 04 00 00 00       	mov    $0x4,%eax
  800d4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d51:	89 f7                	mov    %esi,%edi
  800d53:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7f 08                	jg     800d61 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d61:	83 ec 0c             	sub    $0xc,%esp
  800d64:	50                   	push   %eax
  800d65:	6a 04                	push   $0x4
  800d67:	68 64 15 80 00       	push   $0x801564
  800d6c:	6a 23                	push   $0x23
  800d6e:	68 81 15 80 00       	push   $0x801581
  800d73:	e8 44 02 00 00       	call   800fbc <_panic>

00800d78 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
  800d7e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d81:	8b 55 08             	mov    0x8(%ebp),%edx
  800d84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d87:	b8 05 00 00 00       	mov    $0x5,%eax
  800d8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d92:	8b 75 18             	mov    0x18(%ebp),%esi
  800d95:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d97:	85 c0                	test   %eax,%eax
  800d99:	7f 08                	jg     800da3 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	50                   	push   %eax
  800da7:	6a 05                	push   $0x5
  800da9:	68 64 15 80 00       	push   $0x801564
  800dae:	6a 23                	push   $0x23
  800db0:	68 81 15 80 00       	push   $0x801581
  800db5:	e8 02 02 00 00       	call   800fbc <_panic>

00800dba <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dce:	b8 06 00 00 00       	mov    $0x6,%eax
  800dd3:	89 df                	mov    %ebx,%edi
  800dd5:	89 de                	mov    %ebx,%esi
  800dd7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	7f 08                	jg     800de5 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ddd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de5:	83 ec 0c             	sub    $0xc,%esp
  800de8:	50                   	push   %eax
  800de9:	6a 06                	push   $0x6
  800deb:	68 64 15 80 00       	push   $0x801564
  800df0:	6a 23                	push   $0x23
  800df2:	68 81 15 80 00       	push   $0x801581
  800df7:	e8 c0 01 00 00       	call   800fbc <_panic>

00800dfc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e10:	b8 08 00 00 00       	mov    $0x8,%eax
  800e15:	89 df                	mov    %ebx,%edi
  800e17:	89 de                	mov    %ebx,%esi
  800e19:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	7f 08                	jg     800e27 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e22:	5b                   	pop    %ebx
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	50                   	push   %eax
  800e2b:	6a 08                	push   $0x8
  800e2d:	68 64 15 80 00       	push   $0x801564
  800e32:	6a 23                	push   $0x23
  800e34:	68 81 15 80 00       	push   $0x801581
  800e39:	e8 7e 01 00 00       	call   800fbc <_panic>

00800e3e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	57                   	push   %edi
  800e42:	56                   	push   %esi
  800e43:	53                   	push   %ebx
  800e44:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e52:	b8 09 00 00 00       	mov    $0x9,%eax
  800e57:	89 df                	mov    %ebx,%edi
  800e59:	89 de                	mov    %ebx,%esi
  800e5b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	7f 08                	jg     800e69 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e69:	83 ec 0c             	sub    $0xc,%esp
  800e6c:	50                   	push   %eax
  800e6d:	6a 09                	push   $0x9
  800e6f:	68 64 15 80 00       	push   $0x801564
  800e74:	6a 23                	push   $0x23
  800e76:	68 81 15 80 00       	push   $0x801581
  800e7b:	e8 3c 01 00 00       	call   800fbc <_panic>

00800e80 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	57                   	push   %edi
  800e84:	56                   	push   %esi
  800e85:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e86:	8b 55 08             	mov    0x8(%ebp),%edx
  800e89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e91:	be 00 00 00 00       	mov    $0x0,%esi
  800e96:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e99:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e9c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb9:	89 cb                	mov    %ecx,%ebx
  800ebb:	89 cf                	mov    %ecx,%edi
  800ebd:	89 ce                	mov    %ecx,%esi
  800ebf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	7f 08                	jg     800ecd <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec8:	5b                   	pop    %ebx
  800ec9:	5e                   	pop    %esi
  800eca:	5f                   	pop    %edi
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecd:	83 ec 0c             	sub    $0xc,%esp
  800ed0:	50                   	push   %eax
  800ed1:	6a 0c                	push   $0xc
  800ed3:	68 64 15 80 00       	push   $0x801564
  800ed8:	6a 23                	push   $0x23
  800eda:	68 81 15 80 00       	push   $0x801581
  800edf:	e8 d8 00 00 00       	call   800fbc <_panic>

00800ee4 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	57                   	push   %edi
  800ee8:	56                   	push   %esi
  800ee9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eef:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800efa:	89 df                	mov    %ebx,%edi
  800efc:	89 de                	mov    %ebx,%esi
  800efe:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f10:	8b 55 08             	mov    0x8(%ebp),%edx
  800f13:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f18:	89 cb                	mov    %ecx,%ebx
  800f1a:	89 cf                	mov    %ecx,%edi
  800f1c:	89 ce                	mov    %ecx,%esi
  800f1e:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f2b:	68 9b 15 80 00       	push   $0x80159b
  800f30:	6a 53                	push   $0x53
  800f32:	68 8f 15 80 00       	push   $0x80158f
  800f37:	e8 80 00 00 00       	call   800fbc <_panic>

00800f3c <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f42:	68 9a 15 80 00       	push   $0x80159a
  800f47:	6a 5a                	push   $0x5a
  800f49:	68 8f 15 80 00       	push   $0x80158f
  800f4e:	e8 69 00 00 00       	call   800fbc <_panic>

00800f53 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800f59:	68 b0 15 80 00       	push   $0x8015b0
  800f5e:	6a 1a                	push   $0x1a
  800f60:	68 c9 15 80 00       	push   $0x8015c9
  800f65:	e8 52 00 00 00       	call   800fbc <_panic>

00800f6a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800f70:	68 d3 15 80 00       	push   $0x8015d3
  800f75:	6a 2a                	push   $0x2a
  800f77:	68 c9 15 80 00       	push   $0x8015c9
  800f7c:	e8 3b 00 00 00       	call   800fbc <_panic>

00800f81 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800f87:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800f8c:	89 c2                	mov    %eax,%edx
  800f8e:	c1 e2 07             	shl    $0x7,%edx
  800f91:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800f97:	8b 52 50             	mov    0x50(%edx),%edx
  800f9a:	39 ca                	cmp    %ecx,%edx
  800f9c:	74 11                	je     800faf <ipc_find_env+0x2e>
	for (i = 0; i < NENV; i++)
  800f9e:	83 c0 01             	add    $0x1,%eax
  800fa1:	3d 00 04 00 00       	cmp    $0x400,%eax
  800fa6:	75 e4                	jne    800f8c <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800fa8:	b8 00 00 00 00       	mov    $0x0,%eax
  800fad:	eb 0b                	jmp    800fba <ipc_find_env+0x39>
			return envs[i].env_id;
  800faf:	c1 e0 07             	shl    $0x7,%eax
  800fb2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fb7:	8b 40 48             	mov    0x48(%eax),%eax
}
  800fba:	5d                   	pop    %ebp
  800fbb:	c3                   	ret    

00800fbc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	56                   	push   %esi
  800fc0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fc1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fc4:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800fca:	e8 28 fd ff ff       	call   800cf7 <sys_getenvid>
  800fcf:	83 ec 0c             	sub    $0xc,%esp
  800fd2:	ff 75 0c             	pushl  0xc(%ebp)
  800fd5:	ff 75 08             	pushl  0x8(%ebp)
  800fd8:	56                   	push   %esi
  800fd9:	50                   	push   %eax
  800fda:	68 ec 15 80 00       	push   $0x8015ec
  800fdf:	e8 c9 f1 ff ff       	call   8001ad <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fe4:	83 c4 18             	add    $0x18,%esp
  800fe7:	53                   	push   %ebx
  800fe8:	ff 75 10             	pushl  0x10(%ebp)
  800feb:	e8 6c f1 ff ff       	call   80015c <vcprintf>
	cprintf("\n");
  800ff0:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  800ff7:	e8 b1 f1 ff ff       	call   8001ad <cprintf>
  800ffc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fff:	cc                   	int3   
  801000:	eb fd                	jmp    800fff <_panic+0x43>
  801002:	66 90                	xchg   %ax,%ax
  801004:	66 90                	xchg   %ax,%ax
  801006:	66 90                	xchg   %ax,%ax
  801008:	66 90                	xchg   %ax,%ax
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
