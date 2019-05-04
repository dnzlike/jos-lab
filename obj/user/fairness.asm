
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 98 0c 00 00       	call   800cd8 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 20 80 00 80 	cmpl   $0xeec00080,0x802004
  800049:	00 c0 ee 
  80004c:	74 2d                	je     80007b <umain+0x48>
		while (1) {
			ipc_recv(&who, 0, 0);
			cprintf("%x recv from %x\n", id, who);
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  80004e:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	53                   	push   %ebx
  800058:	68 31 12 80 00       	push   $0x801231
  80005d:	e8 2c 01 00 00       	call   80018e <cprintf>
  800062:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  800065:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  80006a:	6a 00                	push   $0x0
  80006c:	6a 00                	push   $0x0
  80006e:	6a 00                	push   $0x0
  800070:	50                   	push   %eax
  800071:	e8 a7 0e 00 00       	call   800f1d <ipc_send>
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	eb ea                	jmp    800065 <umain+0x32>
			ipc_recv(&who, 0, 0);
  80007b:	8d 75 f4             	lea    -0xc(%ebp),%esi
  80007e:	83 ec 04             	sub    $0x4,%esp
  800081:	6a 00                	push   $0x0
  800083:	6a 00                	push   $0x0
  800085:	56                   	push   %esi
  800086:	e8 7b 0e 00 00       	call   800f06 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80008b:	83 c4 0c             	add    $0xc,%esp
  80008e:	ff 75 f4             	pushl  -0xc(%ebp)
  800091:	53                   	push   %ebx
  800092:	68 20 12 80 00       	push   $0x801220
  800097:	e8 f2 00 00 00       	call   80018e <cprintf>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb dd                	jmp    80007e <umain+0x4b>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 27 0c 00 00       	call   800cd8 <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	c1 e0 07             	shl    $0x7,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	e8 a3 0b 00 00       	call   800c97 <sys_env_destroy>
}
  8000f4:	83 c4 10             	add    $0x10,%esp
  8000f7:	c9                   	leave  
  8000f8:	c3                   	ret    

008000f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 04             	sub    $0x4,%esp
  800100:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800103:	8b 13                	mov    (%ebx),%edx
  800105:	8d 42 01             	lea    0x1(%edx),%eax
  800108:	89 03                	mov    %eax,(%ebx)
  80010a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800111:	3d ff 00 00 00       	cmp    $0xff,%eax
  800116:	74 09                	je     800121 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800118:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80011f:	c9                   	leave  
  800120:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800121:	83 ec 08             	sub    $0x8,%esp
  800124:	68 ff 00 00 00       	push   $0xff
  800129:	8d 43 08             	lea    0x8(%ebx),%eax
  80012c:	50                   	push   %eax
  80012d:	e8 28 0b 00 00       	call   800c5a <sys_cputs>
		b->idx = 0;
  800132:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	eb db                	jmp    800118 <putch+0x1f>

0080013d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800146:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014d:	00 00 00 
	b.cnt = 0;
  800150:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800157:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015a:	ff 75 0c             	pushl  0xc(%ebp)
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800166:	50                   	push   %eax
  800167:	68 f9 00 80 00       	push   $0x8000f9
  80016c:	e8 fb 00 00 00       	call   80026c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800171:	83 c4 08             	add    $0x8,%esp
  800174:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	e8 d4 0a 00 00       	call   800c5a <sys_cputs>

	return b.cnt;
}
  800186:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    

0080018e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018e:	55                   	push   %ebp
  80018f:	89 e5                	mov    %esp,%ebp
  800191:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800194:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800197:	50                   	push   %eax
  800198:	ff 75 08             	pushl  0x8(%ebp)
  80019b:	e8 9d ff ff ff       	call   80013d <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    

008001a2 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	57                   	push   %edi
  8001a6:	56                   	push   %esi
  8001a7:	53                   	push   %ebx
  8001a8:	83 ec 1c             	sub    $0x1c,%esp
  8001ab:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001ae:	89 d3                	mov    %edx,%ebx
  8001b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8001b3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8001b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  8001bc:	89 c2                	mov    %eax,%edx
  8001be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001c6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001c9:	39 c6                	cmp    %eax,%esi
  8001cb:	89 f8                	mov    %edi,%eax
  8001cd:	19 c8                	sbb    %ecx,%eax
  8001cf:	73 32                	jae    800203 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	53                   	push   %ebx
  8001d5:	83 ec 04             	sub    $0x4,%esp
  8001d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001db:	ff 75 e0             	pushl  -0x20(%ebp)
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	e8 eb 0e 00 00       	call   8010d0 <__umoddi3>
  8001e5:	83 c4 14             	add    $0x14,%esp
  8001e8:	0f be 80 52 12 80 00 	movsbl 0x801252(%eax),%eax
  8001ef:	50                   	push   %eax
  8001f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f3:	ff d0                	call   *%eax
	return remain - 1;
  8001f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f8:	83 e8 01             	sub    $0x1,%eax
}
  8001fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fe:	5b                   	pop    %ebx
  8001ff:	5e                   	pop    %esi
  800200:	5f                   	pop    %edi
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  800203:	83 ec 0c             	sub    $0xc,%esp
  800206:	ff 75 18             	pushl  0x18(%ebp)
  800209:	ff 75 14             	pushl  0x14(%ebp)
  80020c:	ff 75 d8             	pushl  -0x28(%ebp)
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	51                   	push   %ecx
  800213:	52                   	push   %edx
  800214:	57                   	push   %edi
  800215:	56                   	push   %esi
  800216:	e8 a5 0d 00 00       	call   800fc0 <__udivdi3>
  80021b:	83 c4 18             	add    $0x18,%esp
  80021e:	52                   	push   %edx
  80021f:	50                   	push   %eax
  800220:	89 da                	mov    %ebx,%edx
  800222:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800225:	e8 78 ff ff ff       	call   8001a2 <printnum_helper>
  80022a:	89 45 14             	mov    %eax,0x14(%ebp)
  80022d:	83 c4 20             	add    $0x20,%esp
  800230:	eb 9f                	jmp    8001d1 <printnum_helper+0x2f>

00800232 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800238:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80023c:	8b 10                	mov    (%eax),%edx
  80023e:	3b 50 04             	cmp    0x4(%eax),%edx
  800241:	73 0a                	jae    80024d <sprintputch+0x1b>
		*b->buf++ = ch;
  800243:	8d 4a 01             	lea    0x1(%edx),%ecx
  800246:	89 08                	mov    %ecx,(%eax)
  800248:	8b 45 08             	mov    0x8(%ebp),%eax
  80024b:	88 02                	mov    %al,(%edx)
}
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <printfmt>:
{
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800255:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800258:	50                   	push   %eax
  800259:	ff 75 10             	pushl  0x10(%ebp)
  80025c:	ff 75 0c             	pushl  0xc(%ebp)
  80025f:	ff 75 08             	pushl  0x8(%ebp)
  800262:	e8 05 00 00 00       	call   80026c <vprintfmt>
}
  800267:	83 c4 10             	add    $0x10,%esp
  80026a:	c9                   	leave  
  80026b:	c3                   	ret    

0080026c <vprintfmt>:
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 3c             	sub    $0x3c,%esp
  800275:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800278:	8b 75 0c             	mov    0xc(%ebp),%esi
  80027b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80027e:	e9 3f 05 00 00       	jmp    8007c2 <vprintfmt+0x556>
		padc = ' ';
  800283:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800287:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  80028e:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800295:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  80029c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  8002a3:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8002aa:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002af:	8d 47 01             	lea    0x1(%edi),%eax
  8002b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002b5:	0f b6 17             	movzbl (%edi),%edx
  8002b8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002bb:	3c 55                	cmp    $0x55,%al
  8002bd:	0f 87 98 05 00 00    	ja     80085b <vprintfmt+0x5ef>
  8002c3:	0f b6 c0             	movzbl %al,%eax
  8002c6:	ff 24 85 a0 13 80 00 	jmp    *0x8013a0(,%eax,4)
  8002cd:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  8002d0:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8002d4:	eb d9                	jmp    8002af <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8002d6:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  8002d9:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  8002e0:	eb cd                	jmp    8002af <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8002e2:	0f b6 d2             	movzbl %dl,%edx
  8002e5:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ed:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  8002f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002f3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002f7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002fa:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8002fd:	83 fb 09             	cmp    $0x9,%ebx
  800300:	77 5c                	ja     80035e <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  800302:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800305:	eb e9                	jmp    8002f0 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  800307:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  80030a:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  80030e:	eb 9f                	jmp    8002af <vprintfmt+0x43>
			precision = va_arg(ap, int);
  800310:	8b 45 14             	mov    0x14(%ebp),%eax
  800313:	8b 00                	mov    (%eax),%eax
  800315:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800318:	8b 45 14             	mov    0x14(%ebp),%eax
  80031b:	8d 40 04             	lea    0x4(%eax),%eax
  80031e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800321:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  800324:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800328:	79 85                	jns    8002af <vprintfmt+0x43>
				width = precision, precision = -1;
  80032a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800330:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800337:	e9 73 ff ff ff       	jmp    8002af <vprintfmt+0x43>
  80033c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80033f:	85 c0                	test   %eax,%eax
  800341:	0f 48 c1             	cmovs  %ecx,%eax
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80034a:	e9 60 ff ff ff       	jmp    8002af <vprintfmt+0x43>
  80034f:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  800352:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800359:	e9 51 ff ff ff       	jmp    8002af <vprintfmt+0x43>
  80035e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800361:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800364:	eb be                	jmp    800324 <vprintfmt+0xb8>
			lflag++;
  800366:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  80036d:	e9 3d ff ff ff       	jmp    8002af <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  800372:	8b 45 14             	mov    0x14(%ebp),%eax
  800375:	8d 78 04             	lea    0x4(%eax),%edi
  800378:	83 ec 08             	sub    $0x8,%esp
  80037b:	56                   	push   %esi
  80037c:	ff 30                	pushl  (%eax)
  80037e:	ff d3                	call   *%ebx
			break;
  800380:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800383:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800386:	e9 34 04 00 00       	jmp    8007bf <vprintfmt+0x553>
			err = va_arg(ap, int);
  80038b:	8b 45 14             	mov    0x14(%ebp),%eax
  80038e:	8d 78 04             	lea    0x4(%eax),%edi
  800391:	8b 00                	mov    (%eax),%eax
  800393:	99                   	cltd   
  800394:	31 d0                	xor    %edx,%eax
  800396:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800398:	83 f8 08             	cmp    $0x8,%eax
  80039b:	7f 23                	jg     8003c0 <vprintfmt+0x154>
  80039d:	8b 14 85 00 15 80 00 	mov    0x801500(,%eax,4),%edx
  8003a4:	85 d2                	test   %edx,%edx
  8003a6:	74 18                	je     8003c0 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  8003a8:	52                   	push   %edx
  8003a9:	68 73 12 80 00       	push   $0x801273
  8003ae:	56                   	push   %esi
  8003af:	53                   	push   %ebx
  8003b0:	e8 9a fe ff ff       	call   80024f <printfmt>
  8003b5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b8:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003bb:	e9 ff 03 00 00       	jmp    8007bf <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  8003c0:	50                   	push   %eax
  8003c1:	68 6a 12 80 00       	push   $0x80126a
  8003c6:	56                   	push   %esi
  8003c7:	53                   	push   %ebx
  8003c8:	e8 82 fe ff ff       	call   80024f <printfmt>
  8003cd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d0:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003d3:	e9 e7 03 00 00       	jmp    8007bf <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	83 c0 04             	add    $0x4,%eax
  8003de:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8003e6:	85 c9                	test   %ecx,%ecx
  8003e8:	b8 63 12 80 00       	mov    $0x801263,%eax
  8003ed:	0f 45 c1             	cmovne %ecx,%eax
  8003f0:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  8003f3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003f7:	7e 06                	jle    8003ff <vprintfmt+0x193>
  8003f9:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8003fd:	75 0d                	jne    80040c <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ff:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800402:	89 c7                	mov    %eax,%edi
  800404:	03 45 d8             	add    -0x28(%ebp),%eax
  800407:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040a:	eb 53                	jmp    80045f <vprintfmt+0x1f3>
  80040c:	83 ec 08             	sub    $0x8,%esp
  80040f:	ff 75 e0             	pushl  -0x20(%ebp)
  800412:	50                   	push   %eax
  800413:	e8 eb 04 00 00       	call   800903 <strnlen>
  800418:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80041b:	29 c1                	sub    %eax,%ecx
  80041d:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  800420:	83 c4 10             	add    $0x10,%esp
  800423:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800425:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  800429:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80042c:	eb 0f                	jmp    80043d <vprintfmt+0x1d1>
					putch(padc, putdat);
  80042e:	83 ec 08             	sub    $0x8,%esp
  800431:	56                   	push   %esi
  800432:	ff 75 d8             	pushl  -0x28(%ebp)
  800435:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800437:	83 ef 01             	sub    $0x1,%edi
  80043a:	83 c4 10             	add    $0x10,%esp
  80043d:	85 ff                	test   %edi,%edi
  80043f:	7f ed                	jg     80042e <vprintfmt+0x1c2>
  800441:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800444:	85 c9                	test   %ecx,%ecx
  800446:	b8 00 00 00 00       	mov    $0x0,%eax
  80044b:	0f 49 c1             	cmovns %ecx,%eax
  80044e:	29 c1                	sub    %eax,%ecx
  800450:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800453:	eb aa                	jmp    8003ff <vprintfmt+0x193>
					putch(ch, putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	56                   	push   %esi
  800459:	52                   	push   %edx
  80045a:	ff d3                	call   *%ebx
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800462:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800464:	83 c7 01             	add    $0x1,%edi
  800467:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80046b:	0f be d0             	movsbl %al,%edx
  80046e:	85 d2                	test   %edx,%edx
  800470:	74 2e                	je     8004a0 <vprintfmt+0x234>
  800472:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800476:	78 06                	js     80047e <vprintfmt+0x212>
  800478:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80047c:	78 1e                	js     80049c <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  80047e:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800482:	74 d1                	je     800455 <vprintfmt+0x1e9>
  800484:	0f be c0             	movsbl %al,%eax
  800487:	83 e8 20             	sub    $0x20,%eax
  80048a:	83 f8 5e             	cmp    $0x5e,%eax
  80048d:	76 c6                	jbe    800455 <vprintfmt+0x1e9>
					putch('?', putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	56                   	push   %esi
  800493:	6a 3f                	push   $0x3f
  800495:	ff d3                	call   *%ebx
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	eb c3                	jmp    80045f <vprintfmt+0x1f3>
  80049c:	89 cf                	mov    %ecx,%edi
  80049e:	eb 02                	jmp    8004a2 <vprintfmt+0x236>
  8004a0:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  8004a2:	85 ff                	test   %edi,%edi
  8004a4:	7e 10                	jle    8004b6 <vprintfmt+0x24a>
				putch(' ', putdat);
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	56                   	push   %esi
  8004aa:	6a 20                	push   $0x20
  8004ac:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8004ae:	83 ef 01             	sub    $0x1,%edi
  8004b1:	83 c4 10             	add    $0x10,%esp
  8004b4:	eb ec                	jmp    8004a2 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  8004b6:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8004b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004bc:	e9 fe 02 00 00       	jmp    8007bf <vprintfmt+0x553>
	if (lflag >= 2)
  8004c1:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8004c5:	7f 21                	jg     8004e8 <vprintfmt+0x27c>
	else if (lflag)
  8004c7:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8004cb:	74 79                	je     800546 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	8b 00                	mov    (%eax),%eax
  8004d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d5:	89 c1                	mov    %eax,%ecx
  8004d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8004da:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 40 04             	lea    0x4(%eax),%eax
  8004e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e6:	eb 17                	jmp    8004ff <vprintfmt+0x293>
		return va_arg(*ap, long long);
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8b 50 04             	mov    0x4(%eax),%edx
  8004ee:	8b 00                	mov    (%eax),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8d 40 08             	lea    0x8(%eax),%eax
  8004fc:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  8004ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800502:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800505:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800508:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  80050b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050f:	78 50                	js     800561 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  800511:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800514:	c1 fa 1f             	sar    $0x1f,%edx
  800517:	89 d0                	mov    %edx,%eax
  800519:	2b 45 e0             	sub    -0x20(%ebp),%eax
  80051c:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  80051f:	85 d2                	test   %edx,%edx
  800521:	0f 89 14 02 00 00    	jns    80073b <vprintfmt+0x4cf>
  800527:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80052b:	0f 84 0a 02 00 00    	je     80073b <vprintfmt+0x4cf>
				putch('+', putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	56                   	push   %esi
  800535:	6a 2b                	push   $0x2b
  800537:	ff d3                	call   *%ebx
  800539:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80053c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800541:	e9 5c 01 00 00       	jmp    8006a2 <vprintfmt+0x436>
		return va_arg(*ap, int);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054e:	89 c1                	mov    %eax,%ecx
  800550:	c1 f9 1f             	sar    $0x1f,%ecx
  800553:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 40 04             	lea    0x4(%eax),%eax
  80055c:	89 45 14             	mov    %eax,0x14(%ebp)
  80055f:	eb 9e                	jmp    8004ff <vprintfmt+0x293>
				putch('-', putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	56                   	push   %esi
  800565:	6a 2d                	push   $0x2d
  800567:	ff d3                	call   *%ebx
				num = -(long long) num;
  800569:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80056c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80056f:	f7 d8                	neg    %eax
  800571:	83 d2 00             	adc    $0x0,%edx
  800574:	f7 da                	neg    %edx
  800576:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800579:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80057c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80057f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800584:	e9 19 01 00 00       	jmp    8006a2 <vprintfmt+0x436>
	if (lflag >= 2)
  800589:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80058d:	7f 29                	jg     8005b8 <vprintfmt+0x34c>
	else if (lflag)
  80058f:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800593:	74 44                	je     8005d9 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8b 00                	mov    (%eax),%eax
  80059a:	ba 00 00 00 00       	mov    $0x0,%edx
  80059f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a8:	8d 40 04             	lea    0x4(%eax),%eax
  8005ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b3:	e9 ea 00 00 00       	jmp    8006a2 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 50 04             	mov    0x4(%eax),%edx
  8005be:	8b 00                	mov    (%eax),%eax
  8005c0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 40 08             	lea    0x8(%eax),%eax
  8005cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d4:	e9 c9 00 00 00       	jmp    8006a2 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8b 00                	mov    (%eax),%eax
  8005de:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005e6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8d 40 04             	lea    0x4(%eax),%eax
  8005ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f7:	e9 a6 00 00 00       	jmp    8006a2 <vprintfmt+0x436>
			putch('0', putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	56                   	push   %esi
  800600:	6a 30                	push   $0x30
  800602:	ff d3                	call   *%ebx
	if (lflag >= 2)
  800604:	83 c4 10             	add    $0x10,%esp
  800607:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80060b:	7f 26                	jg     800633 <vprintfmt+0x3c7>
	else if (lflag)
  80060d:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800611:	74 3e                	je     800651 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8b 00                	mov    (%eax),%eax
  800618:	ba 00 00 00 00       	mov    $0x0,%edx
  80061d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800620:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 40 04             	lea    0x4(%eax),%eax
  800629:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80062c:	b8 08 00 00 00       	mov    $0x8,%eax
  800631:	eb 6f                	jmp    8006a2 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8b 50 04             	mov    0x4(%eax),%edx
  800639:	8b 00                	mov    (%eax),%eax
  80063b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80063e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 40 08             	lea    0x8(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80064a:	b8 08 00 00 00       	mov    $0x8,%eax
  80064f:	eb 51                	jmp    8006a2 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 00                	mov    (%eax),%eax
  800656:	ba 00 00 00 00       	mov    $0x0,%edx
  80065b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80065e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8d 40 04             	lea    0x4(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80066a:	b8 08 00 00 00       	mov    $0x8,%eax
  80066f:	eb 31                	jmp    8006a2 <vprintfmt+0x436>
			putch('0', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	56                   	push   %esi
  800675:	6a 30                	push   $0x30
  800677:	ff d3                	call   *%ebx
			putch('x', putdat);
  800679:	83 c4 08             	add    $0x8,%esp
  80067c:	56                   	push   %esi
  80067d:	6a 78                	push   $0x78
  80067f:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 00                	mov    (%eax),%eax
  800686:	ba 00 00 00 00       	mov    $0x0,%edx
  80068b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80068e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800691:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 40 04             	lea    0x4(%eax),%eax
  80069a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069d:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006a2:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8006a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006a9:	89 c1                	mov    %eax,%ecx
  8006ab:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  8006ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006b1:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  8006b6:	89 c2                	mov    %eax,%edx
  8006b8:	39 c1                	cmp    %eax,%ecx
  8006ba:	0f 87 85 00 00 00    	ja     800745 <vprintfmt+0x4d9>
		tmp /= base;
  8006c0:	89 d0                	mov    %edx,%eax
  8006c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8006c7:	f7 f1                	div    %ecx
		len++;
  8006c9:	83 c7 01             	add    $0x1,%edi
  8006cc:	eb e8                	jmp    8006b6 <vprintfmt+0x44a>
	if (lflag >= 2)
  8006ce:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8006d2:	7f 26                	jg     8006fa <vprintfmt+0x48e>
	else if (lflag)
  8006d4:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006d8:	74 3e                	je     800718 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8b 00                	mov    (%eax),%eax
  8006df:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8d 40 04             	lea    0x4(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f8:	eb a8                	jmp    8006a2 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 50 04             	mov    0x4(%eax),%edx
  800700:	8b 00                	mov    (%eax),%eax
  800702:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800705:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8d 40 08             	lea    0x8(%eax),%eax
  80070e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800711:	b8 10 00 00 00       	mov    $0x10,%eax
  800716:	eb 8a                	jmp    8006a2 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800718:	8b 45 14             	mov    0x14(%ebp),%eax
  80071b:	8b 00                	mov    (%eax),%eax
  80071d:	ba 00 00 00 00       	mov    $0x0,%edx
  800722:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800725:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8d 40 04             	lea    0x4(%eax),%eax
  80072e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800731:	b8 10 00 00 00       	mov    $0x10,%eax
  800736:	e9 67 ff ff ff       	jmp    8006a2 <vprintfmt+0x436>
			base = 10;
  80073b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800740:	e9 5d ff ff ff       	jmp    8006a2 <vprintfmt+0x436>
  800745:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  800748:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80074b:	29 f8                	sub    %edi,%eax
  80074d:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  80074f:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  800753:	74 15                	je     80076a <vprintfmt+0x4fe>
		while (width > 0) {
  800755:	85 ff                	test   %edi,%edi
  800757:	7e 48                	jle    8007a1 <vprintfmt+0x535>
			putch(padc, putdat);
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	56                   	push   %esi
  80075d:	ff 75 e0             	pushl  -0x20(%ebp)
  800760:	ff d3                	call   *%ebx
			width--;
  800762:	83 ef 01             	sub    $0x1,%edi
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	eb eb                	jmp    800755 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  80076a:	83 ec 0c             	sub    $0xc,%esp
  80076d:	6a 2d                	push   $0x2d
  80076f:	ff 75 cc             	pushl  -0x34(%ebp)
  800772:	ff 75 c8             	pushl  -0x38(%ebp)
  800775:	ff 75 d4             	pushl  -0x2c(%ebp)
  800778:	ff 75 d0             	pushl  -0x30(%ebp)
  80077b:	89 f2                	mov    %esi,%edx
  80077d:	89 d8                	mov    %ebx,%eax
  80077f:	e8 1e fa ff ff       	call   8001a2 <printnum_helper>
		width -= len;
  800784:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800787:	2b 7d cc             	sub    -0x34(%ebp),%edi
  80078a:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  80078d:	85 ff                	test   %edi,%edi
  80078f:	7e 2e                	jle    8007bf <vprintfmt+0x553>
			putch(padc, putdat);
  800791:	83 ec 08             	sub    $0x8,%esp
  800794:	56                   	push   %esi
  800795:	6a 20                	push   $0x20
  800797:	ff d3                	call   *%ebx
			width--;
  800799:	83 ef 01             	sub    $0x1,%edi
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	eb ec                	jmp    80078d <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  8007a1:	83 ec 0c             	sub    $0xc,%esp
  8007a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a7:	ff 75 cc             	pushl  -0x34(%ebp)
  8007aa:	ff 75 c8             	pushl  -0x38(%ebp)
  8007ad:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007b0:	ff 75 d0             	pushl  -0x30(%ebp)
  8007b3:	89 f2                	mov    %esi,%edx
  8007b5:	89 d8                	mov    %ebx,%eax
  8007b7:	e8 e6 f9 ff ff       	call   8001a2 <printnum_helper>
  8007bc:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  8007bf:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c2:	83 c7 01             	add    $0x1,%edi
  8007c5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007c9:	83 f8 25             	cmp    $0x25,%eax
  8007cc:	0f 84 b1 fa ff ff    	je     800283 <vprintfmt+0x17>
			if (ch == '\0')
  8007d2:	85 c0                	test   %eax,%eax
  8007d4:	0f 84 a1 00 00 00    	je     80087b <vprintfmt+0x60f>
			putch(ch, putdat);
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	56                   	push   %esi
  8007de:	50                   	push   %eax
  8007df:	ff d3                	call   *%ebx
  8007e1:	83 c4 10             	add    $0x10,%esp
  8007e4:	eb dc                	jmp    8007c2 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	83 c0 04             	add    $0x4,%eax
  8007ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8007f4:	85 ff                	test   %edi,%edi
  8007f6:	74 15                	je     80080d <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  8007f8:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  8007fe:	7f 29                	jg     800829 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800800:	0f b6 06             	movzbl (%esi),%eax
  800803:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800805:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800808:	89 45 14             	mov    %eax,0x14(%ebp)
  80080b:	eb b2                	jmp    8007bf <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  80080d:	68 0c 13 80 00       	push   $0x80130c
  800812:	68 73 12 80 00       	push   $0x801273
  800817:	56                   	push   %esi
  800818:	53                   	push   %ebx
  800819:	e8 31 fa ff ff       	call   80024f <printfmt>
  80081e:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800821:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800824:	89 45 14             	mov    %eax,0x14(%ebp)
  800827:	eb 96                	jmp    8007bf <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800829:	68 44 13 80 00       	push   $0x801344
  80082e:	68 73 12 80 00       	push   $0x801273
  800833:	56                   	push   %esi
  800834:	53                   	push   %ebx
  800835:	e8 15 fa ff ff       	call   80024f <printfmt>
				*res = -1;
  80083a:	c6 07 ff             	movb   $0xff,(%edi)
  80083d:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800840:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800843:	89 45 14             	mov    %eax,0x14(%ebp)
  800846:	e9 74 ff ff ff       	jmp    8007bf <vprintfmt+0x553>
			putch(ch, putdat);
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	56                   	push   %esi
  80084f:	6a 25                	push   $0x25
  800851:	ff d3                	call   *%ebx
			break;
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	e9 64 ff ff ff       	jmp    8007bf <vprintfmt+0x553>
			putch('%', putdat);
  80085b:	83 ec 08             	sub    $0x8,%esp
  80085e:	56                   	push   %esi
  80085f:	6a 25                	push   $0x25
  800861:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800863:	83 c4 10             	add    $0x10,%esp
  800866:	89 f8                	mov    %edi,%eax
  800868:	eb 03                	jmp    80086d <vprintfmt+0x601>
  80086a:	83 e8 01             	sub    $0x1,%eax
  80086d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800871:	75 f7                	jne    80086a <vprintfmt+0x5fe>
  800873:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800876:	e9 44 ff ff ff       	jmp    8007bf <vprintfmt+0x553>
}
  80087b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5f                   	pop    %edi
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	83 ec 18             	sub    $0x18,%esp
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80088f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800892:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800896:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800899:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a0:	85 c0                	test   %eax,%eax
  8008a2:	74 26                	je     8008ca <vsnprintf+0x47>
  8008a4:	85 d2                	test   %edx,%edx
  8008a6:	7e 22                	jle    8008ca <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008a8:	ff 75 14             	pushl  0x14(%ebp)
  8008ab:	ff 75 10             	pushl  0x10(%ebp)
  8008ae:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b1:	50                   	push   %eax
  8008b2:	68 32 02 80 00       	push   $0x800232
  8008b7:	e8 b0 f9 ff ff       	call   80026c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008bf:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c5:	83 c4 10             	add    $0x10,%esp
}
  8008c8:	c9                   	leave  
  8008c9:	c3                   	ret    
		return -E_INVAL;
  8008ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008cf:	eb f7                	jmp    8008c8 <vsnprintf+0x45>

008008d1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008d7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008da:	50                   	push   %eax
  8008db:	ff 75 10             	pushl  0x10(%ebp)
  8008de:	ff 75 0c             	pushl  0xc(%ebp)
  8008e1:	ff 75 08             	pushl  0x8(%ebp)
  8008e4:	e8 9a ff ff ff       	call   800883 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008fa:	74 05                	je     800901 <strlen+0x16>
		n++;
  8008fc:	83 c0 01             	add    $0x1,%eax
  8008ff:	eb f5                	jmp    8008f6 <strlen+0xb>
	return n;
}
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800909:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090c:	ba 00 00 00 00       	mov    $0x0,%edx
  800911:	39 c2                	cmp    %eax,%edx
  800913:	74 0d                	je     800922 <strnlen+0x1f>
  800915:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800919:	74 05                	je     800920 <strnlen+0x1d>
		n++;
  80091b:	83 c2 01             	add    $0x1,%edx
  80091e:	eb f1                	jmp    800911 <strnlen+0xe>
  800920:	89 d0                	mov    %edx,%eax
	return n;
}
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	53                   	push   %ebx
  800928:	8b 45 08             	mov    0x8(%ebp),%eax
  80092b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80092e:	ba 00 00 00 00       	mov    $0x0,%edx
  800933:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800937:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80093a:	83 c2 01             	add    $0x1,%edx
  80093d:	84 c9                	test   %cl,%cl
  80093f:	75 f2                	jne    800933 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800941:	5b                   	pop    %ebx
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	53                   	push   %ebx
  800948:	83 ec 10             	sub    $0x10,%esp
  80094b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80094e:	53                   	push   %ebx
  80094f:	e8 97 ff ff ff       	call   8008eb <strlen>
  800954:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800957:	ff 75 0c             	pushl  0xc(%ebp)
  80095a:	01 d8                	add    %ebx,%eax
  80095c:	50                   	push   %eax
  80095d:	e8 c2 ff ff ff       	call   800924 <strcpy>
	return dst;
}
  800962:	89 d8                	mov    %ebx,%eax
  800964:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800967:	c9                   	leave  
  800968:	c3                   	ret    

00800969 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	56                   	push   %esi
  80096d:	53                   	push   %ebx
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800974:	89 c6                	mov    %eax,%esi
  800976:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800979:	89 c2                	mov    %eax,%edx
  80097b:	39 f2                	cmp    %esi,%edx
  80097d:	74 11                	je     800990 <strncpy+0x27>
		*dst++ = *src;
  80097f:	83 c2 01             	add    $0x1,%edx
  800982:	0f b6 19             	movzbl (%ecx),%ebx
  800985:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800988:	80 fb 01             	cmp    $0x1,%bl
  80098b:	83 d9 ff             	sbb    $0xffffffff,%ecx
  80098e:	eb eb                	jmp    80097b <strncpy+0x12>
	}
	return ret;
}
  800990:	5b                   	pop    %ebx
  800991:	5e                   	pop    %esi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	56                   	push   %esi
  800998:	53                   	push   %ebx
  800999:	8b 75 08             	mov    0x8(%ebp),%esi
  80099c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099f:	8b 55 10             	mov    0x10(%ebp),%edx
  8009a2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a4:	85 d2                	test   %edx,%edx
  8009a6:	74 21                	je     8009c9 <strlcpy+0x35>
  8009a8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009ac:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009ae:	39 c2                	cmp    %eax,%edx
  8009b0:	74 14                	je     8009c6 <strlcpy+0x32>
  8009b2:	0f b6 19             	movzbl (%ecx),%ebx
  8009b5:	84 db                	test   %bl,%bl
  8009b7:	74 0b                	je     8009c4 <strlcpy+0x30>
			*dst++ = *src++;
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	83 c2 01             	add    $0x1,%edx
  8009bf:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009c2:	eb ea                	jmp    8009ae <strlcpy+0x1a>
  8009c4:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009c6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009c9:	29 f0                	sub    %esi,%eax
}
  8009cb:	5b                   	pop    %ebx
  8009cc:	5e                   	pop    %esi
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009d8:	0f b6 01             	movzbl (%ecx),%eax
  8009db:	84 c0                	test   %al,%al
  8009dd:	74 0c                	je     8009eb <strcmp+0x1c>
  8009df:	3a 02                	cmp    (%edx),%al
  8009e1:	75 08                	jne    8009eb <strcmp+0x1c>
		p++, q++;
  8009e3:	83 c1 01             	add    $0x1,%ecx
  8009e6:	83 c2 01             	add    $0x1,%edx
  8009e9:	eb ed                	jmp    8009d8 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009eb:	0f b6 c0             	movzbl %al,%eax
  8009ee:	0f b6 12             	movzbl (%edx),%edx
  8009f1:	29 d0                	sub    %edx,%eax
}
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	53                   	push   %ebx
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ff:	89 c3                	mov    %eax,%ebx
  800a01:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a04:	eb 06                	jmp    800a0c <strncmp+0x17>
		n--, p++, q++;
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a0c:	39 d8                	cmp    %ebx,%eax
  800a0e:	74 16                	je     800a26 <strncmp+0x31>
  800a10:	0f b6 08             	movzbl (%eax),%ecx
  800a13:	84 c9                	test   %cl,%cl
  800a15:	74 04                	je     800a1b <strncmp+0x26>
  800a17:	3a 0a                	cmp    (%edx),%cl
  800a19:	74 eb                	je     800a06 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a1b:	0f b6 00             	movzbl (%eax),%eax
  800a1e:	0f b6 12             	movzbl (%edx),%edx
  800a21:	29 d0                	sub    %edx,%eax
}
  800a23:	5b                   	pop    %ebx
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    
		return 0;
  800a26:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2b:	eb f6                	jmp    800a23 <strncmp+0x2e>

00800a2d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	8b 45 08             	mov    0x8(%ebp),%eax
  800a33:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a37:	0f b6 10             	movzbl (%eax),%edx
  800a3a:	84 d2                	test   %dl,%dl
  800a3c:	74 09                	je     800a47 <strchr+0x1a>
		if (*s == c)
  800a3e:	38 ca                	cmp    %cl,%dl
  800a40:	74 0a                	je     800a4c <strchr+0x1f>
	for (; *s; s++)
  800a42:	83 c0 01             	add    $0x1,%eax
  800a45:	eb f0                	jmp    800a37 <strchr+0xa>
			return (char *) s;
	return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
  800a54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a58:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a5b:	38 ca                	cmp    %cl,%dl
  800a5d:	74 09                	je     800a68 <strfind+0x1a>
  800a5f:	84 d2                	test   %dl,%dl
  800a61:	74 05                	je     800a68 <strfind+0x1a>
	for (; *s; s++)
  800a63:	83 c0 01             	add    $0x1,%eax
  800a66:	eb f0                	jmp    800a58 <strfind+0xa>
			break;
	return (char *) s;
}
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	57                   	push   %edi
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a73:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a76:	85 c9                	test   %ecx,%ecx
  800a78:	74 31                	je     800aab <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7a:	89 f8                	mov    %edi,%eax
  800a7c:	09 c8                	or     %ecx,%eax
  800a7e:	a8 03                	test   $0x3,%al
  800a80:	75 23                	jne    800aa5 <memset+0x3b>
		c &= 0xFF;
  800a82:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a86:	89 d3                	mov    %edx,%ebx
  800a88:	c1 e3 08             	shl    $0x8,%ebx
  800a8b:	89 d0                	mov    %edx,%eax
  800a8d:	c1 e0 18             	shl    $0x18,%eax
  800a90:	89 d6                	mov    %edx,%esi
  800a92:	c1 e6 10             	shl    $0x10,%esi
  800a95:	09 f0                	or     %esi,%eax
  800a97:	09 c2                	or     %eax,%edx
  800a99:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a9b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a9e:	89 d0                	mov    %edx,%eax
  800aa0:	fc                   	cld    
  800aa1:	f3 ab                	rep stos %eax,%es:(%edi)
  800aa3:	eb 06                	jmp    800aab <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa8:	fc                   	cld    
  800aa9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aab:	89 f8                	mov    %edi,%eax
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5f                   	pop    %edi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac0:	39 c6                	cmp    %eax,%esi
  800ac2:	73 32                	jae    800af6 <memmove+0x44>
  800ac4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac7:	39 c2                	cmp    %eax,%edx
  800ac9:	76 2b                	jbe    800af6 <memmove+0x44>
		s += n;
		d += n;
  800acb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ace:	89 fe                	mov    %edi,%esi
  800ad0:	09 ce                	or     %ecx,%esi
  800ad2:	09 d6                	or     %edx,%esi
  800ad4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ada:	75 0e                	jne    800aea <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800adc:	83 ef 04             	sub    $0x4,%edi
  800adf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ae5:	fd                   	std    
  800ae6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae8:	eb 09                	jmp    800af3 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aea:	83 ef 01             	sub    $0x1,%edi
  800aed:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800af0:	fd                   	std    
  800af1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af3:	fc                   	cld    
  800af4:	eb 1a                	jmp    800b10 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af6:	89 c2                	mov    %eax,%edx
  800af8:	09 ca                	or     %ecx,%edx
  800afa:	09 f2                	or     %esi,%edx
  800afc:	f6 c2 03             	test   $0x3,%dl
  800aff:	75 0a                	jne    800b0b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b01:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	fc                   	cld    
  800b07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b09:	eb 05                	jmp    800b10 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	fc                   	cld    
  800b0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b1a:	ff 75 10             	pushl  0x10(%ebp)
  800b1d:	ff 75 0c             	pushl  0xc(%ebp)
  800b20:	ff 75 08             	pushl  0x8(%ebp)
  800b23:	e8 8a ff ff ff       	call   800ab2 <memmove>
}
  800b28:	c9                   	leave  
  800b29:	c3                   	ret    

00800b2a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b35:	89 c6                	mov    %eax,%esi
  800b37:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3a:	39 f0                	cmp    %esi,%eax
  800b3c:	74 1c                	je     800b5a <memcmp+0x30>
		if (*s1 != *s2)
  800b3e:	0f b6 08             	movzbl (%eax),%ecx
  800b41:	0f b6 1a             	movzbl (%edx),%ebx
  800b44:	38 d9                	cmp    %bl,%cl
  800b46:	75 08                	jne    800b50 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b48:	83 c0 01             	add    $0x1,%eax
  800b4b:	83 c2 01             	add    $0x1,%edx
  800b4e:	eb ea                	jmp    800b3a <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b50:	0f b6 c1             	movzbl %cl,%eax
  800b53:	0f b6 db             	movzbl %bl,%ebx
  800b56:	29 d8                	sub    %ebx,%eax
  800b58:	eb 05                	jmp    800b5f <memcmp+0x35>
	}

	return 0;
  800b5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	8b 45 08             	mov    0x8(%ebp),%eax
  800b69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b6c:	89 c2                	mov    %eax,%edx
  800b6e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b71:	39 d0                	cmp    %edx,%eax
  800b73:	73 09                	jae    800b7e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b75:	38 08                	cmp    %cl,(%eax)
  800b77:	74 05                	je     800b7e <memfind+0x1b>
	for (; s < ends; s++)
  800b79:	83 c0 01             	add    $0x1,%eax
  800b7c:	eb f3                	jmp    800b71 <memfind+0xe>
			break;
	return (void *) s;
}
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8c:	eb 03                	jmp    800b91 <strtol+0x11>
		s++;
  800b8e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b91:	0f b6 01             	movzbl (%ecx),%eax
  800b94:	3c 20                	cmp    $0x20,%al
  800b96:	74 f6                	je     800b8e <strtol+0xe>
  800b98:	3c 09                	cmp    $0x9,%al
  800b9a:	74 f2                	je     800b8e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b9c:	3c 2b                	cmp    $0x2b,%al
  800b9e:	74 2a                	je     800bca <strtol+0x4a>
	int neg = 0;
  800ba0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ba5:	3c 2d                	cmp    $0x2d,%al
  800ba7:	74 2b                	je     800bd4 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800baf:	75 0f                	jne    800bc0 <strtol+0x40>
  800bb1:	80 39 30             	cmpb   $0x30,(%ecx)
  800bb4:	74 28                	je     800bde <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bb6:	85 db                	test   %ebx,%ebx
  800bb8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bbd:	0f 44 d8             	cmove  %eax,%ebx
  800bc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bc8:	eb 50                	jmp    800c1a <strtol+0x9a>
		s++;
  800bca:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bcd:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd2:	eb d5                	jmp    800ba9 <strtol+0x29>
		s++, neg = 1;
  800bd4:	83 c1 01             	add    $0x1,%ecx
  800bd7:	bf 01 00 00 00       	mov    $0x1,%edi
  800bdc:	eb cb                	jmp    800ba9 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bde:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800be2:	74 0e                	je     800bf2 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800be4:	85 db                	test   %ebx,%ebx
  800be6:	75 d8                	jne    800bc0 <strtol+0x40>
		s++, base = 8;
  800be8:	83 c1 01             	add    $0x1,%ecx
  800beb:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bf0:	eb ce                	jmp    800bc0 <strtol+0x40>
		s += 2, base = 16;
  800bf2:	83 c1 02             	add    $0x2,%ecx
  800bf5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bfa:	eb c4                	jmp    800bc0 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bfc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 19             	cmp    $0x19,%bl
  800c04:	77 29                	ja     800c2f <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c06:	0f be d2             	movsbl %dl,%edx
  800c09:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c0c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0f:	7d 30                	jge    800c41 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c11:	83 c1 01             	add    $0x1,%ecx
  800c14:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c18:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c1a:	0f b6 11             	movzbl (%ecx),%edx
  800c1d:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c20:	89 f3                	mov    %esi,%ebx
  800c22:	80 fb 09             	cmp    $0x9,%bl
  800c25:	77 d5                	ja     800bfc <strtol+0x7c>
			dig = *s - '0';
  800c27:	0f be d2             	movsbl %dl,%edx
  800c2a:	83 ea 30             	sub    $0x30,%edx
  800c2d:	eb dd                	jmp    800c0c <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800c2f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c32:	89 f3                	mov    %esi,%ebx
  800c34:	80 fb 19             	cmp    $0x19,%bl
  800c37:	77 08                	ja     800c41 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c39:	0f be d2             	movsbl %dl,%edx
  800c3c:	83 ea 37             	sub    $0x37,%edx
  800c3f:	eb cb                	jmp    800c0c <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c41:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c45:	74 05                	je     800c4c <strtol+0xcc>
		*endptr = (char *) s;
  800c47:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c4c:	89 c2                	mov    %eax,%edx
  800c4e:	f7 da                	neg    %edx
  800c50:	85 ff                	test   %edi,%edi
  800c52:	0f 45 c2             	cmovne %edx,%eax
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c60:	b8 00 00 00 00       	mov    $0x0,%eax
  800c65:	8b 55 08             	mov    0x8(%ebp),%edx
  800c68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6b:	89 c3                	mov    %eax,%ebx
  800c6d:	89 c7                	mov    %eax,%edi
  800c6f:	89 c6                	mov    %eax,%esi
  800c71:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c83:	b8 01 00 00 00       	mov    $0x1,%eax
  800c88:	89 d1                	mov    %edx,%ecx
  800c8a:	89 d3                	mov    %edx,%ebx
  800c8c:	89 d7                	mov    %edx,%edi
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	b8 03 00 00 00       	mov    $0x3,%eax
  800cad:	89 cb                	mov    %ecx,%ebx
  800caf:	89 cf                	mov    %ecx,%edi
  800cb1:	89 ce                	mov    %ecx,%esi
  800cb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7f 08                	jg     800cc1 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	6a 03                	push   $0x3
  800cc7:	68 24 15 80 00       	push   $0x801524
  800ccc:	6a 23                	push   $0x23
  800cce:	68 41 15 80 00       	push   $0x801541
  800cd3:	e8 97 02 00 00       	call   800f6f <_panic>

00800cd8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cde:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce8:	89 d1                	mov    %edx,%ecx
  800cea:	89 d3                	mov    %edx,%ebx
  800cec:	89 d7                	mov    %edx,%edi
  800cee:	89 d6                	mov    %edx,%esi
  800cf0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_yield>:

void
sys_yield(void)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800d02:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d07:	89 d1                	mov    %edx,%ecx
  800d09:	89 d3                	mov    %edx,%ebx
  800d0b:	89 d7                	mov    %edx,%edi
  800d0d:	89 d6                	mov    %edx,%esi
  800d0f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
  800d1c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1f:	be 00 00 00 00       	mov    $0x0,%esi
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2a:	b8 04 00 00 00       	mov    $0x4,%eax
  800d2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d32:	89 f7                	mov    %esi,%edi
  800d34:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7f 08                	jg     800d42 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800d46:	6a 04                	push   $0x4
  800d48:	68 24 15 80 00       	push   $0x801524
  800d4d:	6a 23                	push   $0x23
  800d4f:	68 41 15 80 00       	push   $0x801541
  800d54:	e8 16 02 00 00       	call   800f6f <_panic>

00800d59 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d68:	b8 05 00 00 00       	mov    $0x5,%eax
  800d6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d70:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d73:	8b 75 18             	mov    0x18(%ebp),%esi
  800d76:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7f 08                	jg     800d84 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d84:	83 ec 0c             	sub    $0xc,%esp
  800d87:	50                   	push   %eax
  800d88:	6a 05                	push   $0x5
  800d8a:	68 24 15 80 00       	push   $0x801524
  800d8f:	6a 23                	push   $0x23
  800d91:	68 41 15 80 00       	push   $0x801541
  800d96:	e8 d4 01 00 00       	call   800f6f <_panic>

00800d9b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daf:	b8 06 00 00 00       	mov    $0x6,%eax
  800db4:	89 df                	mov    %ebx,%edi
  800db6:	89 de                	mov    %ebx,%esi
  800db8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7f 08                	jg     800dc6 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	50                   	push   %eax
  800dca:	6a 06                	push   $0x6
  800dcc:	68 24 15 80 00       	push   $0x801524
  800dd1:	6a 23                	push   $0x23
  800dd3:	68 41 15 80 00       	push   $0x801541
  800dd8:	e8 92 01 00 00       	call   800f6f <_panic>

00800ddd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	b8 08 00 00 00       	mov    $0x8,%eax
  800df6:	89 df                	mov    %ebx,%edi
  800df8:	89 de                	mov    %ebx,%esi
  800dfa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7f 08                	jg     800e08 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	50                   	push   %eax
  800e0c:	6a 08                	push   $0x8
  800e0e:	68 24 15 80 00       	push   $0x801524
  800e13:	6a 23                	push   $0x23
  800e15:	68 41 15 80 00       	push   $0x801541
  800e1a:	e8 50 01 00 00       	call   800f6f <_panic>

00800e1f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e33:	b8 09 00 00 00       	mov    $0x9,%eax
  800e38:	89 df                	mov    %ebx,%edi
  800e3a:	89 de                	mov    %ebx,%esi
  800e3c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	7f 08                	jg     800e4a <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4a:	83 ec 0c             	sub    $0xc,%esp
  800e4d:	50                   	push   %eax
  800e4e:	6a 09                	push   $0x9
  800e50:	68 24 15 80 00       	push   $0x801524
  800e55:	6a 23                	push   $0x23
  800e57:	68 41 15 80 00       	push   $0x801541
  800e5c:	e8 0e 01 00 00       	call   800f6f <_panic>

00800e61 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e72:	be 00 00 00 00       	mov    $0x0,%esi
  800e77:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e92:	8b 55 08             	mov    0x8(%ebp),%edx
  800e95:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e9a:	89 cb                	mov    %ecx,%ebx
  800e9c:	89 cf                	mov    %ecx,%edi
  800e9e:	89 ce                	mov    %ecx,%esi
  800ea0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	7f 08                	jg     800eae <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea9:	5b                   	pop    %ebx
  800eaa:	5e                   	pop    %esi
  800eab:	5f                   	pop    %edi
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eae:	83 ec 0c             	sub    $0xc,%esp
  800eb1:	50                   	push   %eax
  800eb2:	6a 0c                	push   $0xc
  800eb4:	68 24 15 80 00       	push   $0x801524
  800eb9:	6a 23                	push   $0x23
  800ebb:	68 41 15 80 00       	push   $0x801541
  800ec0:	e8 aa 00 00 00       	call   800f6f <_panic>

00800ec5 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	57                   	push   %edi
  800ec9:	56                   	push   %esi
  800eca:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ecb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800edb:	89 df                	mov    %ebx,%edi
  800edd:	89 de                	mov    %ebx,%esi
  800edf:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ef9:	89 cb                	mov    %ecx,%ebx
  800efb:	89 cf                	mov    %ecx,%edi
  800efd:	89 ce                	mov    %ecx,%esi
  800eff:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f01:	5b                   	pop    %ebx
  800f02:	5e                   	pop    %esi
  800f03:	5f                   	pop    %edi
  800f04:	5d                   	pop    %ebp
  800f05:	c3                   	ret    

00800f06 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800f0c:	68 4f 15 80 00       	push   $0x80154f
  800f11:	6a 1a                	push   $0x1a
  800f13:	68 68 15 80 00       	push   $0x801568
  800f18:	e8 52 00 00 00       	call   800f6f <_panic>

00800f1d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800f23:	68 72 15 80 00       	push   $0x801572
  800f28:	6a 2a                	push   $0x2a
  800f2a:	68 68 15 80 00       	push   $0x801568
  800f2f:	e8 3b 00 00 00       	call   800f6f <_panic>

00800f34 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800f3a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800f3f:	89 c2                	mov    %eax,%edx
  800f41:	c1 e2 07             	shl    $0x7,%edx
  800f44:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800f4a:	8b 52 50             	mov    0x50(%edx),%edx
  800f4d:	39 ca                	cmp    %ecx,%edx
  800f4f:	74 11                	je     800f62 <ipc_find_env+0x2e>
	for (i = 0; i < NENV; i++)
  800f51:	83 c0 01             	add    $0x1,%eax
  800f54:	3d 00 04 00 00       	cmp    $0x400,%eax
  800f59:	75 e4                	jne    800f3f <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  800f5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f60:	eb 0b                	jmp    800f6d <ipc_find_env+0x39>
			return envs[i].env_id;
  800f62:	c1 e0 07             	shl    $0x7,%eax
  800f65:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f6a:	8b 40 48             	mov    0x48(%eax),%eax
}
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800f74:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f77:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f7d:	e8 56 fd ff ff       	call   800cd8 <sys_getenvid>
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	ff 75 0c             	pushl  0xc(%ebp)
  800f88:	ff 75 08             	pushl  0x8(%ebp)
  800f8b:	56                   	push   %esi
  800f8c:	50                   	push   %eax
  800f8d:	68 8c 15 80 00       	push   $0x80158c
  800f92:	e8 f7 f1 ff ff       	call   80018e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f97:	83 c4 18             	add    $0x18,%esp
  800f9a:	53                   	push   %ebx
  800f9b:	ff 75 10             	pushl  0x10(%ebp)
  800f9e:	e8 9a f1 ff ff       	call   80013d <vcprintf>
	cprintf("\n");
  800fa3:	c7 04 24 2f 12 80 00 	movl   $0x80122f,(%esp)
  800faa:	e8 df f1 ff ff       	call   80018e <cprintf>
  800faf:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fb2:	cc                   	int3   
  800fb3:	eb fd                	jmp    800fb2 <_panic+0x43>
  800fb5:	66 90                	xchg   %ax,%ax
  800fb7:	66 90                	xchg   %ax,%ax
  800fb9:	66 90                	xchg   %ax,%ax
  800fbb:	66 90                	xchg   %ax,%ax
  800fbd:	66 90                	xchg   %ax,%ax
  800fbf:	90                   	nop

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
