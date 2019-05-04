
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 60 11 80 00       	push   $0x801160
  800056:	e8 f2 00 00 00       	call   80014d <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 27 0c 00 00       	call   800c97 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	c1 e0 07             	shl    $0x7,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 a3 0b 00 00       	call   800c56 <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 13                	mov    (%ebx),%edx
  8000c4:	8d 42 01             	lea    0x1(%edx),%eax
  8000c7:	89 03                	mov    %eax,(%ebx)
  8000c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	74 09                	je     8000e0 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	68 ff 00 00 00       	push   $0xff
  8000e8:	8d 43 08             	lea    0x8(%ebx),%eax
  8000eb:	50                   	push   %eax
  8000ec:	e8 28 0b 00 00       	call   800c19 <sys_cputs>
		b->idx = 0;
  8000f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	eb db                	jmp    8000d7 <putch+0x1f>

008000fc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800105:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010c:	00 00 00 
	b.cnt = 0;
  80010f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800116:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800119:	ff 75 0c             	pushl  0xc(%ebp)
  80011c:	ff 75 08             	pushl  0x8(%ebp)
  80011f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800125:	50                   	push   %eax
  800126:	68 b8 00 80 00       	push   $0x8000b8
  80012b:	e8 fb 00 00 00       	call   80022b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800130:	83 c4 08             	add    $0x8,%esp
  800133:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800139:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013f:	50                   	push   %eax
  800140:	e8 d4 0a 00 00       	call   800c19 <sys_cputs>

	return b.cnt;
}
  800145:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800153:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800156:	50                   	push   %eax
  800157:	ff 75 08             	pushl  0x8(%ebp)
  80015a:	e8 9d ff ff ff       	call   8000fc <vcprintf>
	va_end(ap);

	return cnt;
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	57                   	push   %edi
  800165:	56                   	push   %esi
  800166:	53                   	push   %ebx
  800167:	83 ec 1c             	sub    $0x1c,%esp
  80016a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80016d:	89 d3                	mov    %edx,%ebx
  80016f:	8b 75 08             	mov    0x8(%ebp),%esi
  800172:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800175:	8b 45 10             	mov    0x10(%ebp),%eax
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  80017b:	89 c2                	mov    %eax,%edx
  80017d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800182:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800185:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800188:	39 c6                	cmp    %eax,%esi
  80018a:	89 f8                	mov    %edi,%eax
  80018c:	19 c8                	sbb    %ecx,%eax
  80018e:	73 32                	jae    8001c2 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800190:	83 ec 08             	sub    $0x8,%esp
  800193:	53                   	push   %ebx
  800194:	83 ec 04             	sub    $0x4,%esp
  800197:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019a:	ff 75 e0             	pushl  -0x20(%ebp)
  80019d:	57                   	push   %edi
  80019e:	56                   	push   %esi
  80019f:	e8 7c 0e 00 00       	call   801020 <__umoddi3>
  8001a4:	83 c4 14             	add    $0x14,%esp
  8001a7:	0f be 80 78 11 80 00 	movsbl 0x801178(%eax),%eax
  8001ae:	50                   	push   %eax
  8001af:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001b2:	ff d0                	call   *%eax
	return remain - 1;
  8001b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b7:	83 e8 01             	sub    $0x1,%eax
}
  8001ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bd:	5b                   	pop    %ebx
  8001be:	5e                   	pop    %esi
  8001bf:	5f                   	pop    %edi
  8001c0:	5d                   	pop    %ebp
  8001c1:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  8001c2:	83 ec 0c             	sub    $0xc,%esp
  8001c5:	ff 75 18             	pushl  0x18(%ebp)
  8001c8:	ff 75 14             	pushl  0x14(%ebp)
  8001cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	51                   	push   %ecx
  8001d2:	52                   	push   %edx
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	e8 36 0d 00 00       	call   800f10 <__udivdi3>
  8001da:	83 c4 18             	add    $0x18,%esp
  8001dd:	52                   	push   %edx
  8001de:	50                   	push   %eax
  8001df:	89 da                	mov    %ebx,%edx
  8001e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001e4:	e8 78 ff ff ff       	call   800161 <printnum_helper>
  8001e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8001ec:	83 c4 20             	add    $0x20,%esp
  8001ef:	eb 9f                	jmp    800190 <printnum_helper+0x2f>

008001f1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8001f7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8001fb:	8b 10                	mov    (%eax),%edx
  8001fd:	3b 50 04             	cmp    0x4(%eax),%edx
  800200:	73 0a                	jae    80020c <sprintputch+0x1b>
		*b->buf++ = ch;
  800202:	8d 4a 01             	lea    0x1(%edx),%ecx
  800205:	89 08                	mov    %ecx,(%eax)
  800207:	8b 45 08             	mov    0x8(%ebp),%eax
  80020a:	88 02                	mov    %al,(%edx)
}
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    

0080020e <printfmt>:
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800214:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800217:	50                   	push   %eax
  800218:	ff 75 10             	pushl  0x10(%ebp)
  80021b:	ff 75 0c             	pushl  0xc(%ebp)
  80021e:	ff 75 08             	pushl  0x8(%ebp)
  800221:	e8 05 00 00 00       	call   80022b <vprintfmt>
}
  800226:	83 c4 10             	add    $0x10,%esp
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <vprintfmt>:
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	57                   	push   %edi
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	83 ec 3c             	sub    $0x3c,%esp
  800234:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800237:	8b 75 0c             	mov    0xc(%ebp),%esi
  80023a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80023d:	e9 3f 05 00 00       	jmp    800781 <vprintfmt+0x556>
		padc = ' ';
  800242:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800246:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  80024d:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800254:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  80025b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  800262:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800269:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80026e:	8d 47 01             	lea    0x1(%edi),%eax
  800271:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800274:	0f b6 17             	movzbl (%edi),%edx
  800277:	8d 42 dd             	lea    -0x23(%edx),%eax
  80027a:	3c 55                	cmp    $0x55,%al
  80027c:	0f 87 98 05 00 00    	ja     80081a <vprintfmt+0x5ef>
  800282:	0f b6 c0             	movzbl %al,%eax
  800285:	ff 24 85 c0 12 80 00 	jmp    *0x8012c0(,%eax,4)
  80028c:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  80028f:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  800293:	eb d9                	jmp    80026e <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800295:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800298:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  80029f:	eb cd                	jmp    80026e <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8002a1:	0f b6 d2             	movzbl %dl,%edx
  8002a4:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ac:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  8002af:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002b2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002b6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002b9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8002bc:	83 fb 09             	cmp    $0x9,%ebx
  8002bf:	77 5c                	ja     80031d <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  8002c1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002c4:	eb e9                	jmp    8002af <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  8002c6:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  8002c9:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  8002cd:	eb 9f                	jmp    80026e <vprintfmt+0x43>
			precision = va_arg(ap, int);
  8002cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d2:	8b 00                	mov    (%eax),%eax
  8002d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8002da:	8d 40 04             	lea    0x4(%eax),%eax
  8002dd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002e0:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8002e3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8002e7:	79 85                	jns    80026e <vprintfmt+0x43>
				width = precision, precision = -1;
  8002e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ef:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f6:	e9 73 ff ff ff       	jmp    80026e <vprintfmt+0x43>
  8002fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002fe:	85 c0                	test   %eax,%eax
  800300:	0f 48 c1             	cmovs  %ecx,%eax
  800303:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800309:	e9 60 ff ff ff       	jmp    80026e <vprintfmt+0x43>
  80030e:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  800311:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800318:	e9 51 ff ff ff       	jmp    80026e <vprintfmt+0x43>
  80031d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800320:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800323:	eb be                	jmp    8002e3 <vprintfmt+0xb8>
			lflag++;
  800325:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800329:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  80032c:	e9 3d ff ff ff       	jmp    80026e <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  800331:	8b 45 14             	mov    0x14(%ebp),%eax
  800334:	8d 78 04             	lea    0x4(%eax),%edi
  800337:	83 ec 08             	sub    $0x8,%esp
  80033a:	56                   	push   %esi
  80033b:	ff 30                	pushl  (%eax)
  80033d:	ff d3                	call   *%ebx
			break;
  80033f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800342:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800345:	e9 34 04 00 00       	jmp    80077e <vprintfmt+0x553>
			err = va_arg(ap, int);
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8d 78 04             	lea    0x4(%eax),%edi
  800350:	8b 00                	mov    (%eax),%eax
  800352:	99                   	cltd   
  800353:	31 d0                	xor    %edx,%eax
  800355:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800357:	83 f8 08             	cmp    $0x8,%eax
  80035a:	7f 23                	jg     80037f <vprintfmt+0x154>
  80035c:	8b 14 85 20 14 80 00 	mov    0x801420(,%eax,4),%edx
  800363:	85 d2                	test   %edx,%edx
  800365:	74 18                	je     80037f <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800367:	52                   	push   %edx
  800368:	68 99 11 80 00       	push   $0x801199
  80036d:	56                   	push   %esi
  80036e:	53                   	push   %ebx
  80036f:	e8 9a fe ff ff       	call   80020e <printfmt>
  800374:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800377:	89 7d 14             	mov    %edi,0x14(%ebp)
  80037a:	e9 ff 03 00 00       	jmp    80077e <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  80037f:	50                   	push   %eax
  800380:	68 90 11 80 00       	push   $0x801190
  800385:	56                   	push   %esi
  800386:	53                   	push   %ebx
  800387:	e8 82 fe ff ff       	call   80020e <printfmt>
  80038c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80038f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800392:	e9 e7 03 00 00       	jmp    80077e <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  800397:	8b 45 14             	mov    0x14(%ebp),%eax
  80039a:	83 c0 04             	add    $0x4,%eax
  80039d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8003a5:	85 c9                	test   %ecx,%ecx
  8003a7:	b8 89 11 80 00       	mov    $0x801189,%eax
  8003ac:	0f 45 c1             	cmovne %ecx,%eax
  8003af:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  8003b2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003b6:	7e 06                	jle    8003be <vprintfmt+0x193>
  8003b8:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8003bc:	75 0d                	jne    8003cb <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003be:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8003c1:	89 c7                	mov    %eax,%edi
  8003c3:	03 45 d8             	add    -0x28(%ebp),%eax
  8003c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003c9:	eb 53                	jmp    80041e <vprintfmt+0x1f3>
  8003cb:	83 ec 08             	sub    $0x8,%esp
  8003ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8003d1:	50                   	push   %eax
  8003d2:	e8 eb 04 00 00       	call   8008c2 <strnlen>
  8003d7:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8003da:	29 c1                	sub    %eax,%ecx
  8003dc:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8003df:	83 c4 10             	add    $0x10,%esp
  8003e2:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8003e4:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8003e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8003eb:	eb 0f                	jmp    8003fc <vprintfmt+0x1d1>
					putch(padc, putdat);
  8003ed:	83 ec 08             	sub    $0x8,%esp
  8003f0:	56                   	push   %esi
  8003f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f4:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f6:	83 ef 01             	sub    $0x1,%edi
  8003f9:	83 c4 10             	add    $0x10,%esp
  8003fc:	85 ff                	test   %edi,%edi
  8003fe:	7f ed                	jg     8003ed <vprintfmt+0x1c2>
  800400:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800403:	85 c9                	test   %ecx,%ecx
  800405:	b8 00 00 00 00       	mov    $0x0,%eax
  80040a:	0f 49 c1             	cmovns %ecx,%eax
  80040d:	29 c1                	sub    %eax,%ecx
  80040f:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800412:	eb aa                	jmp    8003be <vprintfmt+0x193>
					putch(ch, putdat);
  800414:	83 ec 08             	sub    $0x8,%esp
  800417:	56                   	push   %esi
  800418:	52                   	push   %edx
  800419:	ff d3                	call   *%ebx
  80041b:	83 c4 10             	add    $0x10,%esp
  80041e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800421:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800423:	83 c7 01             	add    $0x1,%edi
  800426:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80042a:	0f be d0             	movsbl %al,%edx
  80042d:	85 d2                	test   %edx,%edx
  80042f:	74 2e                	je     80045f <vprintfmt+0x234>
  800431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800435:	78 06                	js     80043d <vprintfmt+0x212>
  800437:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80043b:	78 1e                	js     80045b <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  80043d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800441:	74 d1                	je     800414 <vprintfmt+0x1e9>
  800443:	0f be c0             	movsbl %al,%eax
  800446:	83 e8 20             	sub    $0x20,%eax
  800449:	83 f8 5e             	cmp    $0x5e,%eax
  80044c:	76 c6                	jbe    800414 <vprintfmt+0x1e9>
					putch('?', putdat);
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	56                   	push   %esi
  800452:	6a 3f                	push   $0x3f
  800454:	ff d3                	call   *%ebx
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	eb c3                	jmp    80041e <vprintfmt+0x1f3>
  80045b:	89 cf                	mov    %ecx,%edi
  80045d:	eb 02                	jmp    800461 <vprintfmt+0x236>
  80045f:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  800461:	85 ff                	test   %edi,%edi
  800463:	7e 10                	jle    800475 <vprintfmt+0x24a>
				putch(' ', putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	56                   	push   %esi
  800469:	6a 20                	push   $0x20
  80046b:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80046d:	83 ef 01             	sub    $0x1,%edi
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	eb ec                	jmp    800461 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800475:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800478:	89 45 14             	mov    %eax,0x14(%ebp)
  80047b:	e9 fe 02 00 00       	jmp    80077e <vprintfmt+0x553>
	if (lflag >= 2)
  800480:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800484:	7f 21                	jg     8004a7 <vprintfmt+0x27c>
	else if (lflag)
  800486:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80048a:	74 79                	je     800505 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8b 00                	mov    (%eax),%eax
  800491:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800494:	89 c1                	mov    %eax,%ecx
  800496:	c1 f9 1f             	sar    $0x1f,%ecx
  800499:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80049c:	8b 45 14             	mov    0x14(%ebp),%eax
  80049f:	8d 40 04             	lea    0x4(%eax),%eax
  8004a2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a5:	eb 17                	jmp    8004be <vprintfmt+0x293>
		return va_arg(*ap, long long);
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8b 50 04             	mov    0x4(%eax),%edx
  8004ad:	8b 00                	mov    (%eax),%eax
  8004af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b8:	8d 40 08             	lea    0x8(%eax),%eax
  8004bb:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  8004be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004c7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  8004ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ce:	78 50                	js     800520 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  8004d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004d3:	c1 fa 1f             	sar    $0x1f,%edx
  8004d6:	89 d0                	mov    %edx,%eax
  8004d8:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8004db:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8004de:	85 d2                	test   %edx,%edx
  8004e0:	0f 89 14 02 00 00    	jns    8006fa <vprintfmt+0x4cf>
  8004e6:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8004ea:	0f 84 0a 02 00 00    	je     8006fa <vprintfmt+0x4cf>
				putch('+', putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	56                   	push   %esi
  8004f4:	6a 2b                	push   $0x2b
  8004f6:	ff d3                	call   *%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800500:	e9 5c 01 00 00       	jmp    800661 <vprintfmt+0x436>
		return va_arg(*ap, int);
  800505:	8b 45 14             	mov    0x14(%ebp),%eax
  800508:	8b 00                	mov    (%eax),%eax
  80050a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050d:	89 c1                	mov    %eax,%ecx
  80050f:	c1 f9 1f             	sar    $0x1f,%ecx
  800512:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8d 40 04             	lea    0x4(%eax),%eax
  80051b:	89 45 14             	mov    %eax,0x14(%ebp)
  80051e:	eb 9e                	jmp    8004be <vprintfmt+0x293>
				putch('-', putdat);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	56                   	push   %esi
  800524:	6a 2d                	push   $0x2d
  800526:	ff d3                	call   *%ebx
				num = -(long long) num;
  800528:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80052e:	f7 d8                	neg    %eax
  800530:	83 d2 00             	adc    $0x0,%edx
  800533:	f7 da                	neg    %edx
  800535:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800538:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80053b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80053e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800543:	e9 19 01 00 00       	jmp    800661 <vprintfmt+0x436>
	if (lflag >= 2)
  800548:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80054c:	7f 29                	jg     800577 <vprintfmt+0x34c>
	else if (lflag)
  80054e:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800552:	74 44                	je     800598 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800554:	8b 45 14             	mov    0x14(%ebp),%eax
  800557:	8b 00                	mov    (%eax),%eax
  800559:	ba 00 00 00 00       	mov    $0x0,%edx
  80055e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800561:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8d 40 04             	lea    0x4(%eax),%eax
  80056a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800572:	e9 ea 00 00 00       	jmp    800661 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 50 04             	mov    0x4(%eax),%edx
  80057d:	8b 00                	mov    (%eax),%eax
  80057f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800582:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8d 40 08             	lea    0x8(%eax),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800593:	e9 c9 00 00 00       	jmp    800661 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 00                	mov    (%eax),%eax
  80059d:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8d 40 04             	lea    0x4(%eax),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b6:	e9 a6 00 00 00       	jmp    800661 <vprintfmt+0x436>
			putch('0', putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	56                   	push   %esi
  8005bf:	6a 30                	push   $0x30
  8005c1:	ff d3                	call   *%ebx
	if (lflag >= 2)
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8005ca:	7f 26                	jg     8005f2 <vprintfmt+0x3c7>
	else if (lflag)
  8005cc:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8005d0:	74 3e                	je     800610 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 00                	mov    (%eax),%eax
  8005d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005df:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 40 04             	lea    0x4(%eax),%eax
  8005e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005eb:	b8 08 00 00 00       	mov    $0x8,%eax
  8005f0:	eb 6f                	jmp    800661 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 50 04             	mov    0x4(%eax),%edx
  8005f8:	8b 00                	mov    (%eax),%eax
  8005fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005fd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 40 08             	lea    0x8(%eax),%eax
  800606:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800609:	b8 08 00 00 00       	mov    $0x8,%eax
  80060e:	eb 51                	jmp    800661 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8b 00                	mov    (%eax),%eax
  800615:	ba 00 00 00 00       	mov    $0x0,%edx
  80061a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80061d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800620:	8b 45 14             	mov    0x14(%ebp),%eax
  800623:	8d 40 04             	lea    0x4(%eax),%eax
  800626:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800629:	b8 08 00 00 00       	mov    $0x8,%eax
  80062e:	eb 31                	jmp    800661 <vprintfmt+0x436>
			putch('0', putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	56                   	push   %esi
  800634:	6a 30                	push   $0x30
  800636:	ff d3                	call   *%ebx
			putch('x', putdat);
  800638:	83 c4 08             	add    $0x8,%esp
  80063b:	56                   	push   %esi
  80063c:	6a 78                	push   $0x78
  80063e:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 00                	mov    (%eax),%eax
  800645:	ba 00 00 00 00       	mov    $0x0,%edx
  80064a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80064d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800650:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8d 40 04             	lea    0x4(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80065c:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800661:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800665:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800668:	89 c1                	mov    %eax,%ecx
  80066a:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  80066d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800670:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800675:	89 c2                	mov    %eax,%edx
  800677:	39 c1                	cmp    %eax,%ecx
  800679:	0f 87 85 00 00 00    	ja     800704 <vprintfmt+0x4d9>
		tmp /= base;
  80067f:	89 d0                	mov    %edx,%eax
  800681:	ba 00 00 00 00       	mov    $0x0,%edx
  800686:	f7 f1                	div    %ecx
		len++;
  800688:	83 c7 01             	add    $0x1,%edi
  80068b:	eb e8                	jmp    800675 <vprintfmt+0x44a>
	if (lflag >= 2)
  80068d:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800691:	7f 26                	jg     8006b9 <vprintfmt+0x48e>
	else if (lflag)
  800693:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800697:	74 3e                	je     8006d7 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 00                	mov    (%eax),%eax
  80069e:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006a6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ac:	8d 40 04             	lea    0x4(%eax),%eax
  8006af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b2:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b7:	eb a8                	jmp    800661 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 50 04             	mov    0x4(%eax),%edx
  8006bf:	8b 00                	mov    (%eax),%eax
  8006c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ca:	8d 40 08             	lea    0x8(%eax),%eax
  8006cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d0:	b8 10 00 00 00       	mov    $0x10,%eax
  8006d5:	eb 8a                	jmp    800661 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8006d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f0:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f5:	e9 67 ff ff ff       	jmp    800661 <vprintfmt+0x436>
			base = 10;
  8006fa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ff:	e9 5d ff ff ff       	jmp    800661 <vprintfmt+0x436>
  800704:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  800707:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80070a:	29 f8                	sub    %edi,%eax
  80070c:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  80070e:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  800712:	74 15                	je     800729 <vprintfmt+0x4fe>
		while (width > 0) {
  800714:	85 ff                	test   %edi,%edi
  800716:	7e 48                	jle    800760 <vprintfmt+0x535>
			putch(padc, putdat);
  800718:	83 ec 08             	sub    $0x8,%esp
  80071b:	56                   	push   %esi
  80071c:	ff 75 e0             	pushl  -0x20(%ebp)
  80071f:	ff d3                	call   *%ebx
			width--;
  800721:	83 ef 01             	sub    $0x1,%edi
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	eb eb                	jmp    800714 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800729:	83 ec 0c             	sub    $0xc,%esp
  80072c:	6a 2d                	push   $0x2d
  80072e:	ff 75 cc             	pushl  -0x34(%ebp)
  800731:	ff 75 c8             	pushl  -0x38(%ebp)
  800734:	ff 75 d4             	pushl  -0x2c(%ebp)
  800737:	ff 75 d0             	pushl  -0x30(%ebp)
  80073a:	89 f2                	mov    %esi,%edx
  80073c:	89 d8                	mov    %ebx,%eax
  80073e:	e8 1e fa ff ff       	call   800161 <printnum_helper>
		width -= len;
  800743:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800746:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800749:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  80074c:	85 ff                	test   %edi,%edi
  80074e:	7e 2e                	jle    80077e <vprintfmt+0x553>
			putch(padc, putdat);
  800750:	83 ec 08             	sub    $0x8,%esp
  800753:	56                   	push   %esi
  800754:	6a 20                	push   $0x20
  800756:	ff d3                	call   *%ebx
			width--;
  800758:	83 ef 01             	sub    $0x1,%edi
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	eb ec                	jmp    80074c <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800760:	83 ec 0c             	sub    $0xc,%esp
  800763:	ff 75 e0             	pushl  -0x20(%ebp)
  800766:	ff 75 cc             	pushl  -0x34(%ebp)
  800769:	ff 75 c8             	pushl  -0x38(%ebp)
  80076c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80076f:	ff 75 d0             	pushl  -0x30(%ebp)
  800772:	89 f2                	mov    %esi,%edx
  800774:	89 d8                	mov    %ebx,%eax
  800776:	e8 e6 f9 ff ff       	call   800161 <printnum_helper>
  80077b:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  80077e:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800781:	83 c7 01             	add    $0x1,%edi
  800784:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800788:	83 f8 25             	cmp    $0x25,%eax
  80078b:	0f 84 b1 fa ff ff    	je     800242 <vprintfmt+0x17>
			if (ch == '\0')
  800791:	85 c0                	test   %eax,%eax
  800793:	0f 84 a1 00 00 00    	je     80083a <vprintfmt+0x60f>
			putch(ch, putdat);
  800799:	83 ec 08             	sub    $0x8,%esp
  80079c:	56                   	push   %esi
  80079d:	50                   	push   %eax
  80079e:	ff d3                	call   *%ebx
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	eb dc                	jmp    800781 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	83 c0 04             	add    $0x4,%eax
  8007ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8007b3:	85 ff                	test   %edi,%edi
  8007b5:	74 15                	je     8007cc <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  8007b7:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  8007bd:	7f 29                	jg     8007e8 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  8007bf:	0f b6 06             	movzbl (%esi),%eax
  8007c2:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  8007c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ca:	eb b2                	jmp    80077e <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8007cc:	68 30 12 80 00       	push   $0x801230
  8007d1:	68 99 11 80 00       	push   $0x801199
  8007d6:	56                   	push   %esi
  8007d7:	53                   	push   %ebx
  8007d8:	e8 31 fa ff ff       	call   80020e <printfmt>
  8007dd:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8007e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e6:	eb 96                	jmp    80077e <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  8007e8:	68 68 12 80 00       	push   $0x801268
  8007ed:	68 99 11 80 00       	push   $0x801199
  8007f2:	56                   	push   %esi
  8007f3:	53                   	push   %ebx
  8007f4:	e8 15 fa ff ff       	call   80020e <printfmt>
				*res = -1;
  8007f9:	c6 07 ff             	movb   $0xff,(%edi)
  8007fc:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8007ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800802:	89 45 14             	mov    %eax,0x14(%ebp)
  800805:	e9 74 ff ff ff       	jmp    80077e <vprintfmt+0x553>
			putch(ch, putdat);
  80080a:	83 ec 08             	sub    $0x8,%esp
  80080d:	56                   	push   %esi
  80080e:	6a 25                	push   $0x25
  800810:	ff d3                	call   *%ebx
			break;
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	e9 64 ff ff ff       	jmp    80077e <vprintfmt+0x553>
			putch('%', putdat);
  80081a:	83 ec 08             	sub    $0x8,%esp
  80081d:	56                   	push   %esi
  80081e:	6a 25                	push   $0x25
  800820:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800822:	83 c4 10             	add    $0x10,%esp
  800825:	89 f8                	mov    %edi,%eax
  800827:	eb 03                	jmp    80082c <vprintfmt+0x601>
  800829:	83 e8 01             	sub    $0x1,%eax
  80082c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800830:	75 f7                	jne    800829 <vprintfmt+0x5fe>
  800832:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800835:	e9 44 ff ff ff       	jmp    80077e <vprintfmt+0x553>
}
  80083a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5f                   	pop    %edi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	83 ec 18             	sub    $0x18,%esp
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800851:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800855:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800858:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085f:	85 c0                	test   %eax,%eax
  800861:	74 26                	je     800889 <vsnprintf+0x47>
  800863:	85 d2                	test   %edx,%edx
  800865:	7e 22                	jle    800889 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800867:	ff 75 14             	pushl  0x14(%ebp)
  80086a:	ff 75 10             	pushl  0x10(%ebp)
  80086d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	68 f1 01 80 00       	push   $0x8001f1
  800876:	e8 b0 f9 ff ff       	call   80022b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800881:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800884:	83 c4 10             	add    $0x10,%esp
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    
		return -E_INVAL;
  800889:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088e:	eb f7                	jmp    800887 <vsnprintf+0x45>

00800890 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800896:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800899:	50                   	push   %eax
  80089a:	ff 75 10             	pushl  0x10(%ebp)
  80089d:	ff 75 0c             	pushl  0xc(%ebp)
  8008a0:	ff 75 08             	pushl  0x8(%ebp)
  8008a3:	e8 9a ff ff ff       	call   800842 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b9:	74 05                	je     8008c0 <strlen+0x16>
		n++;
  8008bb:	83 c0 01             	add    $0x1,%eax
  8008be:	eb f5                	jmp    8008b5 <strlen+0xb>
	return n;
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8008d0:	39 c2                	cmp    %eax,%edx
  8008d2:	74 0d                	je     8008e1 <strnlen+0x1f>
  8008d4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008d8:	74 05                	je     8008df <strnlen+0x1d>
		n++;
  8008da:	83 c2 01             	add    $0x1,%edx
  8008dd:	eb f1                	jmp    8008d0 <strnlen+0xe>
  8008df:	89 d0                	mov    %edx,%eax
	return n;
}
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	53                   	push   %ebx
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f2:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008f6:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008f9:	83 c2 01             	add    $0x1,%edx
  8008fc:	84 c9                	test   %cl,%cl
  8008fe:	75 f2                	jne    8008f2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800900:	5b                   	pop    %ebx
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	53                   	push   %ebx
  800907:	83 ec 10             	sub    $0x10,%esp
  80090a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090d:	53                   	push   %ebx
  80090e:	e8 97 ff ff ff       	call   8008aa <strlen>
  800913:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800916:	ff 75 0c             	pushl  0xc(%ebp)
  800919:	01 d8                	add    %ebx,%eax
  80091b:	50                   	push   %eax
  80091c:	e8 c2 ff ff ff       	call   8008e3 <strcpy>
	return dst;
}
  800921:	89 d8                	mov    %ebx,%eax
  800923:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800926:	c9                   	leave  
  800927:	c3                   	ret    

00800928 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800933:	89 c6                	mov    %eax,%esi
  800935:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800938:	89 c2                	mov    %eax,%edx
  80093a:	39 f2                	cmp    %esi,%edx
  80093c:	74 11                	je     80094f <strncpy+0x27>
		*dst++ = *src;
  80093e:	83 c2 01             	add    $0x1,%edx
  800941:	0f b6 19             	movzbl (%ecx),%ebx
  800944:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800947:	80 fb 01             	cmp    $0x1,%bl
  80094a:	83 d9 ff             	sbb    $0xffffffff,%ecx
  80094d:	eb eb                	jmp    80093a <strncpy+0x12>
	}
	return ret;
}
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	56                   	push   %esi
  800957:	53                   	push   %ebx
  800958:	8b 75 08             	mov    0x8(%ebp),%esi
  80095b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095e:	8b 55 10             	mov    0x10(%ebp),%edx
  800961:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800963:	85 d2                	test   %edx,%edx
  800965:	74 21                	je     800988 <strlcpy+0x35>
  800967:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80096b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80096d:	39 c2                	cmp    %eax,%edx
  80096f:	74 14                	je     800985 <strlcpy+0x32>
  800971:	0f b6 19             	movzbl (%ecx),%ebx
  800974:	84 db                	test   %bl,%bl
  800976:	74 0b                	je     800983 <strlcpy+0x30>
			*dst++ = *src++;
  800978:	83 c1 01             	add    $0x1,%ecx
  80097b:	83 c2 01             	add    $0x1,%edx
  80097e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800981:	eb ea                	jmp    80096d <strlcpy+0x1a>
  800983:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800985:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800988:	29 f0                	sub    %esi,%eax
}
  80098a:	5b                   	pop    %ebx
  80098b:	5e                   	pop    %esi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800994:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800997:	0f b6 01             	movzbl (%ecx),%eax
  80099a:	84 c0                	test   %al,%al
  80099c:	74 0c                	je     8009aa <strcmp+0x1c>
  80099e:	3a 02                	cmp    (%edx),%al
  8009a0:	75 08                	jne    8009aa <strcmp+0x1c>
		p++, q++;
  8009a2:	83 c1 01             	add    $0x1,%ecx
  8009a5:	83 c2 01             	add    $0x1,%edx
  8009a8:	eb ed                	jmp    800997 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009aa:	0f b6 c0             	movzbl %al,%eax
  8009ad:	0f b6 12             	movzbl (%edx),%edx
  8009b0:	29 d0                	sub    %edx,%eax
}
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	53                   	push   %ebx
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009be:	89 c3                	mov    %eax,%ebx
  8009c0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c3:	eb 06                	jmp    8009cb <strncmp+0x17>
		n--, p++, q++;
  8009c5:	83 c0 01             	add    $0x1,%eax
  8009c8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009cb:	39 d8                	cmp    %ebx,%eax
  8009cd:	74 16                	je     8009e5 <strncmp+0x31>
  8009cf:	0f b6 08             	movzbl (%eax),%ecx
  8009d2:	84 c9                	test   %cl,%cl
  8009d4:	74 04                	je     8009da <strncmp+0x26>
  8009d6:	3a 0a                	cmp    (%edx),%cl
  8009d8:	74 eb                	je     8009c5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009da:	0f b6 00             	movzbl (%eax),%eax
  8009dd:	0f b6 12             	movzbl (%edx),%edx
  8009e0:	29 d0                	sub    %edx,%eax
}
  8009e2:	5b                   	pop    %ebx
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    
		return 0;
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	eb f6                	jmp    8009e2 <strncmp+0x2e>

008009ec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f6:	0f b6 10             	movzbl (%eax),%edx
  8009f9:	84 d2                	test   %dl,%dl
  8009fb:	74 09                	je     800a06 <strchr+0x1a>
		if (*s == c)
  8009fd:	38 ca                	cmp    %cl,%dl
  8009ff:	74 0a                	je     800a0b <strchr+0x1f>
	for (; *s; s++)
  800a01:	83 c0 01             	add    $0x1,%eax
  800a04:	eb f0                	jmp    8009f6 <strchr+0xa>
			return (char *) s;
	return 0;
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0b:	5d                   	pop    %ebp
  800a0c:	c3                   	ret    

00800a0d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	8b 45 08             	mov    0x8(%ebp),%eax
  800a13:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a17:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a1a:	38 ca                	cmp    %cl,%dl
  800a1c:	74 09                	je     800a27 <strfind+0x1a>
  800a1e:	84 d2                	test   %dl,%dl
  800a20:	74 05                	je     800a27 <strfind+0x1a>
	for (; *s; s++)
  800a22:	83 c0 01             	add    $0x1,%eax
  800a25:	eb f0                	jmp    800a17 <strfind+0xa>
			break;
	return (char *) s;
}
  800a27:	5d                   	pop    %ebp
  800a28:	c3                   	ret    

00800a29 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a35:	85 c9                	test   %ecx,%ecx
  800a37:	74 31                	je     800a6a <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a39:	89 f8                	mov    %edi,%eax
  800a3b:	09 c8                	or     %ecx,%eax
  800a3d:	a8 03                	test   $0x3,%al
  800a3f:	75 23                	jne    800a64 <memset+0x3b>
		c &= 0xFF;
  800a41:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a45:	89 d3                	mov    %edx,%ebx
  800a47:	c1 e3 08             	shl    $0x8,%ebx
  800a4a:	89 d0                	mov    %edx,%eax
  800a4c:	c1 e0 18             	shl    $0x18,%eax
  800a4f:	89 d6                	mov    %edx,%esi
  800a51:	c1 e6 10             	shl    $0x10,%esi
  800a54:	09 f0                	or     %esi,%eax
  800a56:	09 c2                	or     %eax,%edx
  800a58:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a5a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a5d:	89 d0                	mov    %edx,%eax
  800a5f:	fc                   	cld    
  800a60:	f3 ab                	rep stos %eax,%es:(%edi)
  800a62:	eb 06                	jmp    800a6a <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a67:	fc                   	cld    
  800a68:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a6a:	89 f8                	mov    %edi,%eax
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5f                   	pop    %edi
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	57                   	push   %edi
  800a75:	56                   	push   %esi
  800a76:	8b 45 08             	mov    0x8(%ebp),%eax
  800a79:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a7c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7f:	39 c6                	cmp    %eax,%esi
  800a81:	73 32                	jae    800ab5 <memmove+0x44>
  800a83:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a86:	39 c2                	cmp    %eax,%edx
  800a88:	76 2b                	jbe    800ab5 <memmove+0x44>
		s += n;
		d += n;
  800a8a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8d:	89 fe                	mov    %edi,%esi
  800a8f:	09 ce                	or     %ecx,%esi
  800a91:	09 d6                	or     %edx,%esi
  800a93:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a99:	75 0e                	jne    800aa9 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a9b:	83 ef 04             	sub    $0x4,%edi
  800a9e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aa4:	fd                   	std    
  800aa5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa7:	eb 09                	jmp    800ab2 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa9:	83 ef 01             	sub    $0x1,%edi
  800aac:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aaf:	fd                   	std    
  800ab0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab2:	fc                   	cld    
  800ab3:	eb 1a                	jmp    800acf <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab5:	89 c2                	mov    %eax,%edx
  800ab7:	09 ca                	or     %ecx,%edx
  800ab9:	09 f2                	or     %esi,%edx
  800abb:	f6 c2 03             	test   $0x3,%dl
  800abe:	75 0a                	jne    800aca <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ac3:	89 c7                	mov    %eax,%edi
  800ac5:	fc                   	cld    
  800ac6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac8:	eb 05                	jmp    800acf <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800aca:	89 c7                	mov    %eax,%edi
  800acc:	fc                   	cld    
  800acd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad9:	ff 75 10             	pushl  0x10(%ebp)
  800adc:	ff 75 0c             	pushl  0xc(%ebp)
  800adf:	ff 75 08             	pushl  0x8(%ebp)
  800ae2:	e8 8a ff ff ff       	call   800a71 <memmove>
}
  800ae7:	c9                   	leave  
  800ae8:	c3                   	ret    

00800ae9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af4:	89 c6                	mov    %eax,%esi
  800af6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af9:	39 f0                	cmp    %esi,%eax
  800afb:	74 1c                	je     800b19 <memcmp+0x30>
		if (*s1 != *s2)
  800afd:	0f b6 08             	movzbl (%eax),%ecx
  800b00:	0f b6 1a             	movzbl (%edx),%ebx
  800b03:	38 d9                	cmp    %bl,%cl
  800b05:	75 08                	jne    800b0f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b07:	83 c0 01             	add    $0x1,%eax
  800b0a:	83 c2 01             	add    $0x1,%edx
  800b0d:	eb ea                	jmp    800af9 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b0f:	0f b6 c1             	movzbl %cl,%eax
  800b12:	0f b6 db             	movzbl %bl,%ebx
  800b15:	29 d8                	sub    %ebx,%eax
  800b17:	eb 05                	jmp    800b1e <memcmp+0x35>
	}

	return 0;
  800b19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	8b 45 08             	mov    0x8(%ebp),%eax
  800b28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b30:	39 d0                	cmp    %edx,%eax
  800b32:	73 09                	jae    800b3d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b34:	38 08                	cmp    %cl,(%eax)
  800b36:	74 05                	je     800b3d <memfind+0x1b>
	for (; s < ends; s++)
  800b38:	83 c0 01             	add    $0x1,%eax
  800b3b:	eb f3                	jmp    800b30 <memfind+0xe>
			break;
	return (void *) s;
}
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	57                   	push   %edi
  800b43:	56                   	push   %esi
  800b44:	53                   	push   %ebx
  800b45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b4b:	eb 03                	jmp    800b50 <strtol+0x11>
		s++;
  800b4d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800b50:	0f b6 01             	movzbl (%ecx),%eax
  800b53:	3c 20                	cmp    $0x20,%al
  800b55:	74 f6                	je     800b4d <strtol+0xe>
  800b57:	3c 09                	cmp    $0x9,%al
  800b59:	74 f2                	je     800b4d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b5b:	3c 2b                	cmp    $0x2b,%al
  800b5d:	74 2a                	je     800b89 <strtol+0x4a>
	int neg = 0;
  800b5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b64:	3c 2d                	cmp    $0x2d,%al
  800b66:	74 2b                	je     800b93 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b68:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6e:	75 0f                	jne    800b7f <strtol+0x40>
  800b70:	80 39 30             	cmpb   $0x30,(%ecx)
  800b73:	74 28                	je     800b9d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b75:	85 db                	test   %ebx,%ebx
  800b77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7c:	0f 44 d8             	cmove  %eax,%ebx
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b84:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b87:	eb 50                	jmp    800bd9 <strtol+0x9a>
		s++;
  800b89:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b91:	eb d5                	jmp    800b68 <strtol+0x29>
		s++, neg = 1;
  800b93:	83 c1 01             	add    $0x1,%ecx
  800b96:	bf 01 00 00 00       	mov    $0x1,%edi
  800b9b:	eb cb                	jmp    800b68 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ba1:	74 0e                	je     800bb1 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ba3:	85 db                	test   %ebx,%ebx
  800ba5:	75 d8                	jne    800b7f <strtol+0x40>
		s++, base = 8;
  800ba7:	83 c1 01             	add    $0x1,%ecx
  800baa:	bb 08 00 00 00       	mov    $0x8,%ebx
  800baf:	eb ce                	jmp    800b7f <strtol+0x40>
		s += 2, base = 16;
  800bb1:	83 c1 02             	add    $0x2,%ecx
  800bb4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb9:	eb c4                	jmp    800b7f <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800bbb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bbe:	89 f3                	mov    %esi,%ebx
  800bc0:	80 fb 19             	cmp    $0x19,%bl
  800bc3:	77 29                	ja     800bee <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bc5:	0f be d2             	movsbl %dl,%edx
  800bc8:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bcb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bce:	7d 30                	jge    800c00 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800bd9:	0f b6 11             	movzbl (%ecx),%edx
  800bdc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bdf:	89 f3                	mov    %esi,%ebx
  800be1:	80 fb 09             	cmp    $0x9,%bl
  800be4:	77 d5                	ja     800bbb <strtol+0x7c>
			dig = *s - '0';
  800be6:	0f be d2             	movsbl %dl,%edx
  800be9:	83 ea 30             	sub    $0x30,%edx
  800bec:	eb dd                	jmp    800bcb <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800bee:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bf1:	89 f3                	mov    %esi,%ebx
  800bf3:	80 fb 19             	cmp    $0x19,%bl
  800bf6:	77 08                	ja     800c00 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bf8:	0f be d2             	movsbl %dl,%edx
  800bfb:	83 ea 37             	sub    $0x37,%edx
  800bfe:	eb cb                	jmp    800bcb <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c04:	74 05                	je     800c0b <strtol+0xcc>
		*endptr = (char *) s;
  800c06:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c09:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c0b:	89 c2                	mov    %eax,%edx
  800c0d:	f7 da                	neg    %edx
  800c0f:	85 ff                	test   %edi,%edi
  800c11:	0f 45 c2             	cmovne %edx,%eax
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c24:	8b 55 08             	mov    0x8(%ebp),%edx
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	89 c3                	mov    %eax,%ebx
  800c2c:	89 c7                	mov    %eax,%edi
  800c2e:	89 c6                	mov    %eax,%esi
  800c30:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c42:	b8 01 00 00 00       	mov    $0x1,%eax
  800c47:	89 d1                	mov    %edx,%ecx
  800c49:	89 d3                	mov    %edx,%ebx
  800c4b:	89 d7                	mov    %edx,%edi
  800c4d:	89 d6                	mov    %edx,%esi
  800c4f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5f                   	pop    %edi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	b8 03 00 00 00       	mov    $0x3,%eax
  800c6c:	89 cb                	mov    %ecx,%ebx
  800c6e:	89 cf                	mov    %ecx,%edi
  800c70:	89 ce                	mov    %ecx,%esi
  800c72:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c74:	85 c0                	test   %eax,%eax
  800c76:	7f 08                	jg     800c80 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7b:	5b                   	pop    %ebx
  800c7c:	5e                   	pop    %esi
  800c7d:	5f                   	pop    %edi
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c80:	83 ec 0c             	sub    $0xc,%esp
  800c83:	50                   	push   %eax
  800c84:	6a 03                	push   $0x3
  800c86:	68 44 14 80 00       	push   $0x801444
  800c8b:	6a 23                	push   $0x23
  800c8d:	68 61 14 80 00       	push   $0x801461
  800c92:	e8 2e 02 00 00       	call   800ec5 <_panic>

00800c97 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ca7:	89 d1                	mov    %edx,%ecx
  800ca9:	89 d3                	mov    %edx,%ebx
  800cab:	89 d7                	mov    %edx,%edi
  800cad:	89 d6                	mov    %edx,%esi
  800caf:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <sys_yield>:

void
sys_yield(void)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc6:	89 d1                	mov    %edx,%ecx
  800cc8:	89 d3                	mov    %edx,%ebx
  800cca:	89 d7                	mov    %edx,%edi
  800ccc:	89 d6                	mov    %edx,%esi
  800cce:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cde:	be 00 00 00 00       	mov    $0x0,%esi
  800ce3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce9:	b8 04 00 00 00       	mov    $0x4,%eax
  800cee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf1:	89 f7                	mov    %esi,%edi
  800cf3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7f 08                	jg     800d01 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	50                   	push   %eax
  800d05:	6a 04                	push   $0x4
  800d07:	68 44 14 80 00       	push   $0x801444
  800d0c:	6a 23                	push   $0x23
  800d0e:	68 61 14 80 00       	push   $0x801461
  800d13:	e8 ad 01 00 00       	call   800ec5 <_panic>

00800d18 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	b8 05 00 00 00       	mov    $0x5,%eax
  800d2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d32:	8b 75 18             	mov    0x18(%ebp),%esi
  800d35:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d37:	85 c0                	test   %eax,%eax
  800d39:	7f 08                	jg     800d43 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d43:	83 ec 0c             	sub    $0xc,%esp
  800d46:	50                   	push   %eax
  800d47:	6a 05                	push   $0x5
  800d49:	68 44 14 80 00       	push   $0x801444
  800d4e:	6a 23                	push   $0x23
  800d50:	68 61 14 80 00       	push   $0x801461
  800d55:	e8 6b 01 00 00       	call   800ec5 <_panic>

00800d5a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7f 08                	jg     800d85 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d85:	83 ec 0c             	sub    $0xc,%esp
  800d88:	50                   	push   %eax
  800d89:	6a 06                	push   $0x6
  800d8b:	68 44 14 80 00       	push   $0x801444
  800d90:	6a 23                	push   $0x23
  800d92:	68 61 14 80 00       	push   $0x801461
  800d97:	e8 29 01 00 00       	call   800ec5 <_panic>

00800d9c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
  800da2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	b8 08 00 00 00       	mov    $0x8,%eax
  800db5:	89 df                	mov    %ebx,%edi
  800db7:	89 de                	mov    %ebx,%esi
  800db9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	7f 08                	jg     800dc7 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	50                   	push   %eax
  800dcb:	6a 08                	push   $0x8
  800dcd:	68 44 14 80 00       	push   $0x801444
  800dd2:	6a 23                	push   $0x23
  800dd4:	68 61 14 80 00       	push   $0x801461
  800dd9:	e8 e7 00 00 00       	call   800ec5 <_panic>

00800dde <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dec:	8b 55 08             	mov    0x8(%ebp),%edx
  800def:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df2:	b8 09 00 00 00       	mov    $0x9,%eax
  800df7:	89 df                	mov    %ebx,%edi
  800df9:	89 de                	mov    %ebx,%esi
  800dfb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	7f 08                	jg     800e09 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e09:	83 ec 0c             	sub    $0xc,%esp
  800e0c:	50                   	push   %eax
  800e0d:	6a 09                	push   $0x9
  800e0f:	68 44 14 80 00       	push   $0x801444
  800e14:	6a 23                	push   $0x23
  800e16:	68 61 14 80 00       	push   $0x801461
  800e1b:	e8 a5 00 00 00       	call   800ec5 <_panic>

00800e20 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e31:	be 00 00 00 00       	mov    $0x0,%esi
  800e36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e51:	8b 55 08             	mov    0x8(%ebp),%edx
  800e54:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e59:	89 cb                	mov    %ecx,%ebx
  800e5b:	89 cf                	mov    %ecx,%edi
  800e5d:	89 ce                	mov    %ecx,%esi
  800e5f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e61:	85 c0                	test   %eax,%eax
  800e63:	7f 08                	jg     800e6d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5f                   	pop    %edi
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6d:	83 ec 0c             	sub    $0xc,%esp
  800e70:	50                   	push   %eax
  800e71:	6a 0c                	push   $0xc
  800e73:	68 44 14 80 00       	push   $0x801444
  800e78:	6a 23                	push   $0x23
  800e7a:	68 61 14 80 00       	push   $0x801461
  800e7f:	e8 41 00 00 00       	call   800ec5 <_panic>

00800e84 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e95:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e9a:	89 df                	mov    %ebx,%edi
  800e9c:	89 de                	mov    %ebx,%esi
  800e9e:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    

00800ea5 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	57                   	push   %edi
  800ea9:	56                   	push   %esi
  800eaa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eab:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	b8 0e 00 00 00       	mov    $0xe,%eax
  800eb8:	89 cb                	mov    %ecx,%ebx
  800eba:	89 cf                	mov    %ecx,%edi
  800ebc:	89 ce                	mov    %ecx,%esi
  800ebe:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	56                   	push   %esi
  800ec9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800eca:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ecd:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ed3:	e8 bf fd ff ff       	call   800c97 <sys_getenvid>
  800ed8:	83 ec 0c             	sub    $0xc,%esp
  800edb:	ff 75 0c             	pushl  0xc(%ebp)
  800ede:	ff 75 08             	pushl  0x8(%ebp)
  800ee1:	56                   	push   %esi
  800ee2:	50                   	push   %eax
  800ee3:	68 70 14 80 00       	push   $0x801470
  800ee8:	e8 60 f2 ff ff       	call   80014d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800eed:	83 c4 18             	add    $0x18,%esp
  800ef0:	53                   	push   %ebx
  800ef1:	ff 75 10             	pushl  0x10(%ebp)
  800ef4:	e8 03 f2 ff ff       	call   8000fc <vcprintf>
	cprintf("\n");
  800ef9:	c7 04 24 6c 11 80 00 	movl   $0x80116c,(%esp)
  800f00:	e8 48 f2 ff ff       	call   80014d <cprintf>
  800f05:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f08:	cc                   	int3   
  800f09:	eb fd                	jmp    800f08 <_panic+0x43>
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
