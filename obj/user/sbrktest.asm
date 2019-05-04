
obj/user/sbrktest:     file format elf32-i386


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
  80002c:	e8 8a 00 00 00       	call   8000bb <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define ALLOCATE_SIZE 4096
#define STRING_SIZE	  64

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 18             	sub    $0x18,%esp
	int i;
	uint32_t start, end;
	char *s;

	start = sys_sbrk(0);
  80003c:	6a 00                	push   $0x0
  80003e:	e8 bd 0e 00 00       	call   800f00 <sys_sbrk>
  800043:	89 c6                	mov    %eax,%esi
  800045:	89 c3                	mov    %eax,%ebx
	end = sys_sbrk(ALLOCATE_SIZE);
  800047:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  80004e:	e8 ad 0e 00 00       	call   800f00 <sys_sbrk>

	if (end - start < ALLOCATE_SIZE) {
  800053:	29 f0                	sub    %esi,%eax
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  80005d:	76 4a                	jbe    8000a9 <umain+0x76>
		cprintf("sbrk not correctly implemented\n");
	}

	s = (char *) start;
	for ( i = 0; i < STRING_SIZE; i++) {
  80005f:	b9 00 00 00 00       	mov    $0x0,%ecx
		s[i] = 'A' + (i % 26);
  800064:	bf 4f ec c4 4e       	mov    $0x4ec4ec4f,%edi
  800069:	89 c8                	mov    %ecx,%eax
  80006b:	f7 ef                	imul   %edi
  80006d:	c1 fa 03             	sar    $0x3,%edx
  800070:	89 c8                	mov    %ecx,%eax
  800072:	c1 f8 1f             	sar    $0x1f,%eax
  800075:	29 c2                	sub    %eax,%edx
  800077:	6b d2 1a             	imul   $0x1a,%edx,%edx
  80007a:	89 c8                	mov    %ecx,%eax
  80007c:	29 d0                	sub    %edx,%eax
  80007e:	83 c0 41             	add    $0x41,%eax
  800081:	88 04 19             	mov    %al,(%ecx,%ebx,1)
	for ( i = 0; i < STRING_SIZE; i++) {
  800084:	83 c1 01             	add    $0x1,%ecx
  800087:	83 f9 40             	cmp    $0x40,%ecx
  80008a:	75 dd                	jne    800069 <umain+0x36>
	}
	s[STRING_SIZE] = '\0';
  80008c:	c6 46 40 00          	movb   $0x0,0x40(%esi)

	cprintf("SBRK_TEST(%s)\n", s);
  800090:	83 ec 08             	sub    $0x8,%esp
  800093:	56                   	push   %esi
  800094:	68 e0 11 80 00       	push   $0x8011e0
  800099:	e8 0a 01 00 00       	call   8001a8 <cprintf>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000a4:	5b                   	pop    %ebx
  8000a5:	5e                   	pop    %esi
  8000a6:	5f                   	pop    %edi
  8000a7:	5d                   	pop    %ebp
  8000a8:	c3                   	ret    
		cprintf("sbrk not correctly implemented\n");
  8000a9:	83 ec 0c             	sub    $0xc,%esp
  8000ac:	68 c0 11 80 00       	push   $0x8011c0
  8000b1:	e8 f2 00 00 00       	call   8001a8 <cprintf>
  8000b6:	83 c4 10             	add    $0x10,%esp
  8000b9:	eb a4                	jmp    80005f <umain+0x2c>

008000bb <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	56                   	push   %esi
  8000bf:	53                   	push   %ebx
  8000c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c6:	e8 27 0c 00 00       	call   800cf2 <sys_getenvid>
  8000cb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d0:	c1 e0 07             	shl    $0x7,%eax
  8000d3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d8:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000dd:	85 db                	test   %ebx,%ebx
  8000df:	7e 07                	jle    8000e8 <libmain+0x2d>
		binaryname = argv[0];
  8000e1:	8b 06                	mov    (%esi),%eax
  8000e3:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e8:	83 ec 08             	sub    $0x8,%esp
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	e8 41 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f2:	e8 0a 00 00 00       	call   800101 <exit>
}
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    

00800101 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800107:	6a 00                	push   $0x0
  800109:	e8 a3 0b 00 00       	call   800cb1 <sys_env_destroy>
}
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	c9                   	leave  
  800112:	c3                   	ret    

00800113 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	53                   	push   %ebx
  800117:	83 ec 04             	sub    $0x4,%esp
  80011a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011d:	8b 13                	mov    (%ebx),%edx
  80011f:	8d 42 01             	lea    0x1(%edx),%eax
  800122:	89 03                	mov    %eax,(%ebx)
  800124:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800127:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800130:	74 09                	je     80013b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800132:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800136:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800139:	c9                   	leave  
  80013a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80013b:	83 ec 08             	sub    $0x8,%esp
  80013e:	68 ff 00 00 00       	push   $0xff
  800143:	8d 43 08             	lea    0x8(%ebx),%eax
  800146:	50                   	push   %eax
  800147:	e8 28 0b 00 00       	call   800c74 <sys_cputs>
		b->idx = 0;
  80014c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800152:	83 c4 10             	add    $0x10,%esp
  800155:	eb db                	jmp    800132 <putch+0x1f>

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 13 01 80 00       	push   $0x800113
  800186:	e8 fb 00 00 00       	call   800286 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 d4 0a 00 00       	call   800c74 <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001c8:	89 d3                	mov    %edx,%ebx
  8001ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8001cd:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  8001d6:	89 c2                	mov    %eax,%edx
  8001d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8001e3:	39 c6                	cmp    %eax,%esi
  8001e5:	89 f8                	mov    %edi,%eax
  8001e7:	19 c8                	sbb    %ecx,%eax
  8001e9:	73 32                	jae    80021d <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 04             	sub    $0x4,%esp
  8001f2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	e8 81 0e 00 00       	call   801080 <__umoddi3>
  8001ff:	83 c4 14             	add    $0x14,%esp
  800202:	0f be 80 f9 11 80 00 	movsbl 0x8011f9(%eax),%eax
  800209:	50                   	push   %eax
  80020a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80020d:	ff d0                	call   *%eax
	return remain - 1;
  80020f:	8b 45 14             	mov    0x14(%ebp),%eax
  800212:	83 e8 01             	sub    $0x1,%eax
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	ff 75 18             	pushl  0x18(%ebp)
  800223:	ff 75 14             	pushl  0x14(%ebp)
  800226:	ff 75 d8             	pushl  -0x28(%ebp)
  800229:	83 ec 08             	sub    $0x8,%esp
  80022c:	51                   	push   %ecx
  80022d:	52                   	push   %edx
  80022e:	57                   	push   %edi
  80022f:	56                   	push   %esi
  800230:	e8 3b 0d 00 00       	call   800f70 <__udivdi3>
  800235:	83 c4 18             	add    $0x18,%esp
  800238:	52                   	push   %edx
  800239:	50                   	push   %eax
  80023a:	89 da                	mov    %ebx,%edx
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	e8 78 ff ff ff       	call   8001bc <printnum_helper>
  800244:	89 45 14             	mov    %eax,0x14(%ebp)
  800247:	83 c4 20             	add    $0x20,%esp
  80024a:	eb 9f                	jmp    8001eb <printnum_helper+0x2f>

0080024c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800252:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800256:	8b 10                	mov    (%eax),%edx
  800258:	3b 50 04             	cmp    0x4(%eax),%edx
  80025b:	73 0a                	jae    800267 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800260:	89 08                	mov    %ecx,(%eax)
  800262:	8b 45 08             	mov    0x8(%ebp),%eax
  800265:	88 02                	mov    %al,(%edx)
}
  800267:	5d                   	pop    %ebp
  800268:	c3                   	ret    

00800269 <printfmt>:
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80026f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800272:	50                   	push   %eax
  800273:	ff 75 10             	pushl  0x10(%ebp)
  800276:	ff 75 0c             	pushl  0xc(%ebp)
  800279:	ff 75 08             	pushl  0x8(%ebp)
  80027c:	e8 05 00 00 00       	call   800286 <vprintfmt>
}
  800281:	83 c4 10             	add    $0x10,%esp
  800284:	c9                   	leave  
  800285:	c3                   	ret    

00800286 <vprintfmt>:
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
  800289:	57                   	push   %edi
  80028a:	56                   	push   %esi
  80028b:	53                   	push   %ebx
  80028c:	83 ec 3c             	sub    $0x3c,%esp
  80028f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800292:	8b 75 0c             	mov    0xc(%ebp),%esi
  800295:	8b 7d 10             	mov    0x10(%ebp),%edi
  800298:	e9 3f 05 00 00       	jmp    8007dc <vprintfmt+0x556>
		padc = ' ';
  80029d:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  8002a1:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  8002a8:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8002af:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  8002b6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  8002bd:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8002c4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002c9:	8d 47 01             	lea    0x1(%edi),%eax
  8002cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002cf:	0f b6 17             	movzbl (%edi),%edx
  8002d2:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002d5:	3c 55                	cmp    $0x55,%al
  8002d7:	0f 87 98 05 00 00    	ja     800875 <vprintfmt+0x5ef>
  8002dd:	0f b6 c0             	movzbl %al,%eax
  8002e0:	ff 24 85 40 13 80 00 	jmp    *0x801340(,%eax,4)
  8002e7:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  8002ea:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8002ee:	eb d9                	jmp    8002c9 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8002f0:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  8002f3:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  8002fa:	eb cd                	jmp    8002c9 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8002fc:	0f b6 d2             	movzbl %dl,%edx
  8002ff:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800302:	b8 00 00 00 00       	mov    $0x0,%eax
  800307:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  80030a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80030d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800311:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800314:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800317:	83 fb 09             	cmp    $0x9,%ebx
  80031a:	77 5c                	ja     800378 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  80031c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80031f:	eb e9                	jmp    80030a <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  800321:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  800324:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  800328:	eb 9f                	jmp    8002c9 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  80032a:	8b 45 14             	mov    0x14(%ebp),%eax
  80032d:	8b 00                	mov    (%eax),%eax
  80032f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800332:	8b 45 14             	mov    0x14(%ebp),%eax
  800335:	8d 40 04             	lea    0x4(%eax),%eax
  800338:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  80033e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800342:	79 85                	jns    8002c9 <vprintfmt+0x43>
				width = precision, precision = -1;
  800344:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800347:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800351:	e9 73 ff ff ff       	jmp    8002c9 <vprintfmt+0x43>
  800356:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800359:	85 c0                	test   %eax,%eax
  80035b:	0f 48 c1             	cmovs  %ecx,%eax
  80035e:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800364:	e9 60 ff ff ff       	jmp    8002c9 <vprintfmt+0x43>
  800369:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  80036c:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800373:	e9 51 ff ff ff       	jmp    8002c9 <vprintfmt+0x43>
  800378:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80037e:	eb be                	jmp    80033e <vprintfmt+0xb8>
			lflag++;
  800380:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800384:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  800387:	e9 3d ff ff ff       	jmp    8002c9 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  80038c:	8b 45 14             	mov    0x14(%ebp),%eax
  80038f:	8d 78 04             	lea    0x4(%eax),%edi
  800392:	83 ec 08             	sub    $0x8,%esp
  800395:	56                   	push   %esi
  800396:	ff 30                	pushl  (%eax)
  800398:	ff d3                	call   *%ebx
			break;
  80039a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80039d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a0:	e9 34 04 00 00       	jmp    8007d9 <vprintfmt+0x553>
			err = va_arg(ap, int);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8d 78 04             	lea    0x4(%eax),%edi
  8003ab:	8b 00                	mov    (%eax),%eax
  8003ad:	99                   	cltd   
  8003ae:	31 d0                	xor    %edx,%eax
  8003b0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b2:	83 f8 08             	cmp    $0x8,%eax
  8003b5:	7f 23                	jg     8003da <vprintfmt+0x154>
  8003b7:	8b 14 85 a0 14 80 00 	mov    0x8014a0(,%eax,4),%edx
  8003be:	85 d2                	test   %edx,%edx
  8003c0:	74 18                	je     8003da <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  8003c2:	52                   	push   %edx
  8003c3:	68 1a 12 80 00       	push   $0x80121a
  8003c8:	56                   	push   %esi
  8003c9:	53                   	push   %ebx
  8003ca:	e8 9a fe ff ff       	call   800269 <printfmt>
  8003cf:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d2:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003d5:	e9 ff 03 00 00       	jmp    8007d9 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  8003da:	50                   	push   %eax
  8003db:	68 11 12 80 00       	push   $0x801211
  8003e0:	56                   	push   %esi
  8003e1:	53                   	push   %ebx
  8003e2:	e8 82 fe ff ff       	call   800269 <printfmt>
  8003e7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003ea:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003ed:	e9 e7 03 00 00       	jmp    8007d9 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  8003f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f5:	83 c0 04             	add    $0x4,%eax
  8003f8:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800400:	85 c9                	test   %ecx,%ecx
  800402:	b8 0a 12 80 00       	mov    $0x80120a,%eax
  800407:	0f 45 c1             	cmovne %ecx,%eax
  80040a:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80040d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800411:	7e 06                	jle    800419 <vprintfmt+0x193>
  800413:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800417:	75 0d                	jne    800426 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800419:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80041c:	89 c7                	mov    %eax,%edi
  80041e:	03 45 d8             	add    -0x28(%ebp),%eax
  800421:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800424:	eb 53                	jmp    800479 <vprintfmt+0x1f3>
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	ff 75 e0             	pushl  -0x20(%ebp)
  80042c:	50                   	push   %eax
  80042d:	e8 eb 04 00 00       	call   80091d <strnlen>
  800432:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800435:	29 c1                	sub    %eax,%ecx
  800437:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  80043a:	83 c4 10             	add    $0x10,%esp
  80043d:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80043f:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  800443:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800446:	eb 0f                	jmp    800457 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800448:	83 ec 08             	sub    $0x8,%esp
  80044b:	56                   	push   %esi
  80044c:	ff 75 d8             	pushl  -0x28(%ebp)
  80044f:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800451:	83 ef 01             	sub    $0x1,%edi
  800454:	83 c4 10             	add    $0x10,%esp
  800457:	85 ff                	test   %edi,%edi
  800459:	7f ed                	jg     800448 <vprintfmt+0x1c2>
  80045b:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80045e:	85 c9                	test   %ecx,%ecx
  800460:	b8 00 00 00 00       	mov    $0x0,%eax
  800465:	0f 49 c1             	cmovns %ecx,%eax
  800468:	29 c1                	sub    %eax,%ecx
  80046a:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80046d:	eb aa                	jmp    800419 <vprintfmt+0x193>
					putch(ch, putdat);
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	56                   	push   %esi
  800473:	52                   	push   %edx
  800474:	ff d3                	call   *%ebx
  800476:	83 c4 10             	add    $0x10,%esp
  800479:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80047c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80047e:	83 c7 01             	add    $0x1,%edi
  800481:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800485:	0f be d0             	movsbl %al,%edx
  800488:	85 d2                	test   %edx,%edx
  80048a:	74 2e                	je     8004ba <vprintfmt+0x234>
  80048c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800490:	78 06                	js     800498 <vprintfmt+0x212>
  800492:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800496:	78 1e                	js     8004b6 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800498:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80049c:	74 d1                	je     80046f <vprintfmt+0x1e9>
  80049e:	0f be c0             	movsbl %al,%eax
  8004a1:	83 e8 20             	sub    $0x20,%eax
  8004a4:	83 f8 5e             	cmp    $0x5e,%eax
  8004a7:	76 c6                	jbe    80046f <vprintfmt+0x1e9>
					putch('?', putdat);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	56                   	push   %esi
  8004ad:	6a 3f                	push   $0x3f
  8004af:	ff d3                	call   *%ebx
  8004b1:	83 c4 10             	add    $0x10,%esp
  8004b4:	eb c3                	jmp    800479 <vprintfmt+0x1f3>
  8004b6:	89 cf                	mov    %ecx,%edi
  8004b8:	eb 02                	jmp    8004bc <vprintfmt+0x236>
  8004ba:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  8004bc:	85 ff                	test   %edi,%edi
  8004be:	7e 10                	jle    8004d0 <vprintfmt+0x24a>
				putch(' ', putdat);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	56                   	push   %esi
  8004c4:	6a 20                	push   $0x20
  8004c6:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8004c8:	83 ef 01             	sub    $0x1,%edi
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	eb ec                	jmp    8004bc <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  8004d0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8004d3:	89 45 14             	mov    %eax,0x14(%ebp)
  8004d6:	e9 fe 02 00 00       	jmp    8007d9 <vprintfmt+0x553>
	if (lflag >= 2)
  8004db:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8004df:	7f 21                	jg     800502 <vprintfmt+0x27c>
	else if (lflag)
  8004e1:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8004e5:	74 79                	je     800560 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ef:	89 c1                	mov    %eax,%ecx
  8004f1:	c1 f9 1f             	sar    $0x1f,%ecx
  8004f4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 40 04             	lea    0x4(%eax),%eax
  8004fd:	89 45 14             	mov    %eax,0x14(%ebp)
  800500:	eb 17                	jmp    800519 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800502:	8b 45 14             	mov    0x14(%ebp),%eax
  800505:	8b 50 04             	mov    0x4(%eax),%edx
  800508:	8b 00                	mov    (%eax),%eax
  80050a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 40 08             	lea    0x8(%eax),%eax
  800516:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  800519:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80051f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800522:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  800525:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800529:	78 50                	js     80057b <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  80052b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80052e:	c1 fa 1f             	sar    $0x1f,%edx
  800531:	89 d0                	mov    %edx,%eax
  800533:	2b 45 e0             	sub    -0x20(%ebp),%eax
  800536:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  800539:	85 d2                	test   %edx,%edx
  80053b:	0f 89 14 02 00 00    	jns    800755 <vprintfmt+0x4cf>
  800541:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800545:	0f 84 0a 02 00 00    	je     800755 <vprintfmt+0x4cf>
				putch('+', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	56                   	push   %esi
  80054f:	6a 2b                	push   $0x2b
  800551:	ff d3                	call   *%ebx
  800553:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800556:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055b:	e9 5c 01 00 00       	jmp    8006bc <vprintfmt+0x436>
		return va_arg(*ap, int);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 00                	mov    (%eax),%eax
  800565:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800568:	89 c1                	mov    %eax,%ecx
  80056a:	c1 f9 1f             	sar    $0x1f,%ecx
  80056d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8d 40 04             	lea    0x4(%eax),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
  800579:	eb 9e                	jmp    800519 <vprintfmt+0x293>
				putch('-', putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	56                   	push   %esi
  80057f:	6a 2d                	push   $0x2d
  800581:	ff d3                	call   *%ebx
				num = -(long long) num;
  800583:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800586:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800589:	f7 d8                	neg    %eax
  80058b:	83 d2 00             	adc    $0x0,%edx
  80058e:	f7 da                	neg    %edx
  800590:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800593:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800596:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800599:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059e:	e9 19 01 00 00       	jmp    8006bc <vprintfmt+0x436>
	if (lflag >= 2)
  8005a3:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8005a7:	7f 29                	jg     8005d2 <vprintfmt+0x34c>
	else if (lflag)
  8005a9:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8005ad:	74 44                	je     8005f3 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8005b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005bc:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 40 04             	lea    0x4(%eax),%eax
  8005c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cd:	e9 ea 00 00 00       	jmp    8006bc <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 50 04             	mov    0x4(%eax),%edx
  8005d8:	8b 00                	mov    (%eax),%eax
  8005da:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005dd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 40 08             	lea    0x8(%eax),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ee:	e9 c9 00 00 00       	jmp    8006bc <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800600:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8d 40 04             	lea    0x4(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800611:	e9 a6 00 00 00       	jmp    8006bc <vprintfmt+0x436>
			putch('0', putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	56                   	push   %esi
  80061a:	6a 30                	push   $0x30
  80061c:	ff d3                	call   *%ebx
	if (lflag >= 2)
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800625:	7f 26                	jg     80064d <vprintfmt+0x3c7>
	else if (lflag)
  800627:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80062b:	74 3e                	je     80066b <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8b 00                	mov    (%eax),%eax
  800632:	ba 00 00 00 00       	mov    $0x0,%edx
  800637:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80063a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 40 04             	lea    0x4(%eax),%eax
  800643:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800646:	b8 08 00 00 00       	mov    $0x8,%eax
  80064b:	eb 6f                	jmp    8006bc <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  80064d:	8b 45 14             	mov    0x14(%ebp),%eax
  800650:	8b 50 04             	mov    0x4(%eax),%edx
  800653:	8b 00                	mov    (%eax),%eax
  800655:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800658:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8d 40 08             	lea    0x8(%eax),%eax
  800661:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800664:	b8 08 00 00 00       	mov    $0x8,%eax
  800669:	eb 51                	jmp    8006bc <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8b 00                	mov    (%eax),%eax
  800670:	ba 00 00 00 00       	mov    $0x0,%edx
  800675:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800678:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 40 04             	lea    0x4(%eax),%eax
  800681:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800684:	b8 08 00 00 00       	mov    $0x8,%eax
  800689:	eb 31                	jmp    8006bc <vprintfmt+0x436>
			putch('0', putdat);
  80068b:	83 ec 08             	sub    $0x8,%esp
  80068e:	56                   	push   %esi
  80068f:	6a 30                	push   $0x30
  800691:	ff d3                	call   *%ebx
			putch('x', putdat);
  800693:	83 c4 08             	add    $0x8,%esp
  800696:	56                   	push   %esi
  800697:	6a 78                	push   $0x78
  800699:	ff d3                	call   *%ebx
			num = (unsigned long long)
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8b 00                	mov    (%eax),%eax
  8006a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006a8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  8006ab:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 40 04             	lea    0x4(%eax),%eax
  8006b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b7:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006bc:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8006c0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006c3:	89 c1                	mov    %eax,%ecx
  8006c5:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  8006c8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006cb:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  8006d0:	89 c2                	mov    %eax,%edx
  8006d2:	39 c1                	cmp    %eax,%ecx
  8006d4:	0f 87 85 00 00 00    	ja     80075f <vprintfmt+0x4d9>
		tmp /= base;
  8006da:	89 d0                	mov    %edx,%eax
  8006dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e1:	f7 f1                	div    %ecx
		len++;
  8006e3:	83 c7 01             	add    $0x1,%edi
  8006e6:	eb e8                	jmp    8006d0 <vprintfmt+0x44a>
	if (lflag >= 2)
  8006e8:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8006ec:	7f 26                	jg     800714 <vprintfmt+0x48e>
	else if (lflag)
  8006ee:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006f2:	74 3e                	je     800732 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8b 00                	mov    (%eax),%eax
  8006f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800701:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8d 40 04             	lea    0x4(%eax),%eax
  80070a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070d:	b8 10 00 00 00       	mov    $0x10,%eax
  800712:	eb a8                	jmp    8006bc <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8b 50 04             	mov    0x4(%eax),%edx
  80071a:	8b 00                	mov    (%eax),%eax
  80071c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80071f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800722:	8b 45 14             	mov    0x14(%ebp),%eax
  800725:	8d 40 08             	lea    0x8(%eax),%eax
  800728:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80072b:	b8 10 00 00 00       	mov    $0x10,%eax
  800730:	eb 8a                	jmp    8006bc <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 00                	mov    (%eax),%eax
  800737:	ba 00 00 00 00       	mov    $0x0,%edx
  80073c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80073f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800742:	8b 45 14             	mov    0x14(%ebp),%eax
  800745:	8d 40 04             	lea    0x4(%eax),%eax
  800748:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074b:	b8 10 00 00 00       	mov    $0x10,%eax
  800750:	e9 67 ff ff ff       	jmp    8006bc <vprintfmt+0x436>
			base = 10;
  800755:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075a:	e9 5d ff ff ff       	jmp    8006bc <vprintfmt+0x436>
  80075f:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  800762:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800765:	29 f8                	sub    %edi,%eax
  800767:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  800769:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  80076d:	74 15                	je     800784 <vprintfmt+0x4fe>
		while (width > 0) {
  80076f:	85 ff                	test   %edi,%edi
  800771:	7e 48                	jle    8007bb <vprintfmt+0x535>
			putch(padc, putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	56                   	push   %esi
  800777:	ff 75 e0             	pushl  -0x20(%ebp)
  80077a:	ff d3                	call   *%ebx
			width--;
  80077c:	83 ef 01             	sub    $0x1,%edi
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	eb eb                	jmp    80076f <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800784:	83 ec 0c             	sub    $0xc,%esp
  800787:	6a 2d                	push   $0x2d
  800789:	ff 75 cc             	pushl  -0x34(%ebp)
  80078c:	ff 75 c8             	pushl  -0x38(%ebp)
  80078f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800792:	ff 75 d0             	pushl  -0x30(%ebp)
  800795:	89 f2                	mov    %esi,%edx
  800797:	89 d8                	mov    %ebx,%eax
  800799:	e8 1e fa ff ff       	call   8001bc <printnum_helper>
		width -= len;
  80079e:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007a1:	2b 7d cc             	sub    -0x34(%ebp),%edi
  8007a4:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  8007a7:	85 ff                	test   %edi,%edi
  8007a9:	7e 2e                	jle    8007d9 <vprintfmt+0x553>
			putch(padc, putdat);
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	56                   	push   %esi
  8007af:	6a 20                	push   $0x20
  8007b1:	ff d3                	call   *%ebx
			width--;
  8007b3:	83 ef 01             	sub    $0x1,%edi
  8007b6:	83 c4 10             	add    $0x10,%esp
  8007b9:	eb ec                	jmp    8007a7 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  8007bb:	83 ec 0c             	sub    $0xc,%esp
  8007be:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c1:	ff 75 cc             	pushl  -0x34(%ebp)
  8007c4:	ff 75 c8             	pushl  -0x38(%ebp)
  8007c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007ca:	ff 75 d0             	pushl  -0x30(%ebp)
  8007cd:	89 f2                	mov    %esi,%edx
  8007cf:	89 d8                	mov    %ebx,%eax
  8007d1:	e8 e6 f9 ff ff       	call   8001bc <printnum_helper>
  8007d6:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  8007d9:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007dc:	83 c7 01             	add    $0x1,%edi
  8007df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007e3:	83 f8 25             	cmp    $0x25,%eax
  8007e6:	0f 84 b1 fa ff ff    	je     80029d <vprintfmt+0x17>
			if (ch == '\0')
  8007ec:	85 c0                	test   %eax,%eax
  8007ee:	0f 84 a1 00 00 00    	je     800895 <vprintfmt+0x60f>
			putch(ch, putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	50                   	push   %eax
  8007f9:	ff d3                	call   *%ebx
  8007fb:	83 c4 10             	add    $0x10,%esp
  8007fe:	eb dc                	jmp    8007dc <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800800:	8b 45 14             	mov    0x14(%ebp),%eax
  800803:	83 c0 04             	add    $0x4,%eax
  800806:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  80080e:	85 ff                	test   %edi,%edi
  800810:	74 15                	je     800827 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800812:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800818:	7f 29                	jg     800843 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  80081a:	0f b6 06             	movzbl (%esi),%eax
  80081d:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  80081f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800822:	89 45 14             	mov    %eax,0x14(%ebp)
  800825:	eb b2                	jmp    8007d9 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800827:	68 b0 12 80 00       	push   $0x8012b0
  80082c:	68 1a 12 80 00       	push   $0x80121a
  800831:	56                   	push   %esi
  800832:	53                   	push   %ebx
  800833:	e8 31 fa ff ff       	call   800269 <printfmt>
  800838:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  80083b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80083e:	89 45 14             	mov    %eax,0x14(%ebp)
  800841:	eb 96                	jmp    8007d9 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800843:	68 e8 12 80 00       	push   $0x8012e8
  800848:	68 1a 12 80 00       	push   $0x80121a
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	e8 15 fa ff ff       	call   800269 <printfmt>
				*res = -1;
  800854:	c6 07 ff             	movb   $0xff,(%edi)
  800857:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  80085a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80085d:	89 45 14             	mov    %eax,0x14(%ebp)
  800860:	e9 74 ff ff ff       	jmp    8007d9 <vprintfmt+0x553>
			putch(ch, putdat);
  800865:	83 ec 08             	sub    $0x8,%esp
  800868:	56                   	push   %esi
  800869:	6a 25                	push   $0x25
  80086b:	ff d3                	call   *%ebx
			break;
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	e9 64 ff ff ff       	jmp    8007d9 <vprintfmt+0x553>
			putch('%', putdat);
  800875:	83 ec 08             	sub    $0x8,%esp
  800878:	56                   	push   %esi
  800879:	6a 25                	push   $0x25
  80087b:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  80087d:	83 c4 10             	add    $0x10,%esp
  800880:	89 f8                	mov    %edi,%eax
  800882:	eb 03                	jmp    800887 <vprintfmt+0x601>
  800884:	83 e8 01             	sub    $0x1,%eax
  800887:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80088b:	75 f7                	jne    800884 <vprintfmt+0x5fe>
  80088d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800890:	e9 44 ff ff ff       	jmp    8007d9 <vprintfmt+0x553>
}
  800895:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5f                   	pop    %edi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	83 ec 18             	sub    $0x18,%esp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ac:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	74 26                	je     8008e4 <vsnprintf+0x47>
  8008be:	85 d2                	test   %edx,%edx
  8008c0:	7e 22                	jle    8008e4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c2:	ff 75 14             	pushl  0x14(%ebp)
  8008c5:	ff 75 10             	pushl  0x10(%ebp)
  8008c8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008cb:	50                   	push   %eax
  8008cc:	68 4c 02 80 00       	push   $0x80024c
  8008d1:	e8 b0 f9 ff ff       	call   800286 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008df:	83 c4 10             	add    $0x10,%esp
}
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    
		return -E_INVAL;
  8008e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e9:	eb f7                	jmp    8008e2 <vsnprintf+0x45>

008008eb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f4:	50                   	push   %eax
  8008f5:	ff 75 10             	pushl  0x10(%ebp)
  8008f8:	ff 75 0c             	pushl  0xc(%ebp)
  8008fb:	ff 75 08             	pushl  0x8(%ebp)
  8008fe:	e8 9a ff ff ff       	call   80089d <vsnprintf>
	va_end(ap);

	return rc;
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090b:	b8 00 00 00 00       	mov    $0x0,%eax
  800910:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800914:	74 05                	je     80091b <strlen+0x16>
		n++;
  800916:	83 c0 01             	add    $0x1,%eax
  800919:	eb f5                	jmp    800910 <strlen+0xb>
	return n;
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800923:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800926:	ba 00 00 00 00       	mov    $0x0,%edx
  80092b:	39 c2                	cmp    %eax,%edx
  80092d:	74 0d                	je     80093c <strnlen+0x1f>
  80092f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800933:	74 05                	je     80093a <strnlen+0x1d>
		n++;
  800935:	83 c2 01             	add    $0x1,%edx
  800938:	eb f1                	jmp    80092b <strnlen+0xe>
  80093a:	89 d0                	mov    %edx,%eax
	return n;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	53                   	push   %ebx
  800942:	8b 45 08             	mov    0x8(%ebp),%eax
  800945:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800948:	ba 00 00 00 00       	mov    $0x0,%edx
  80094d:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800951:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800954:	83 c2 01             	add    $0x1,%edx
  800957:	84 c9                	test   %cl,%cl
  800959:	75 f2                	jne    80094d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80095b:	5b                   	pop    %ebx
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	53                   	push   %ebx
  800962:	83 ec 10             	sub    $0x10,%esp
  800965:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800968:	53                   	push   %ebx
  800969:	e8 97 ff ff ff       	call   800905 <strlen>
  80096e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800971:	ff 75 0c             	pushl  0xc(%ebp)
  800974:	01 d8                	add    %ebx,%eax
  800976:	50                   	push   %eax
  800977:	e8 c2 ff ff ff       	call   80093e <strcpy>
	return dst;
}
  80097c:	89 d8                	mov    %ebx,%eax
  80097e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098e:	89 c6                	mov    %eax,%esi
  800990:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800993:	89 c2                	mov    %eax,%edx
  800995:	39 f2                	cmp    %esi,%edx
  800997:	74 11                	je     8009aa <strncpy+0x27>
		*dst++ = *src;
  800999:	83 c2 01             	add    $0x1,%edx
  80099c:	0f b6 19             	movzbl (%ecx),%ebx
  80099f:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a2:	80 fb 01             	cmp    $0x1,%bl
  8009a5:	83 d9 ff             	sbb    $0xffffffff,%ecx
  8009a8:	eb eb                	jmp    800995 <strncpy+0x12>
	}
	return ret;
}
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b9:	8b 55 10             	mov    0x10(%ebp),%edx
  8009bc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009be:	85 d2                	test   %edx,%edx
  8009c0:	74 21                	je     8009e3 <strlcpy+0x35>
  8009c2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009c6:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009c8:	39 c2                	cmp    %eax,%edx
  8009ca:	74 14                	je     8009e0 <strlcpy+0x32>
  8009cc:	0f b6 19             	movzbl (%ecx),%ebx
  8009cf:	84 db                	test   %bl,%bl
  8009d1:	74 0b                	je     8009de <strlcpy+0x30>
			*dst++ = *src++;
  8009d3:	83 c1 01             	add    $0x1,%ecx
  8009d6:	83 c2 01             	add    $0x1,%edx
  8009d9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009dc:	eb ea                	jmp    8009c8 <strlcpy+0x1a>
  8009de:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009e0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e3:	29 f0                	sub    %esi,%eax
}
  8009e5:	5b                   	pop    %ebx
  8009e6:	5e                   	pop    %esi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f2:	0f b6 01             	movzbl (%ecx),%eax
  8009f5:	84 c0                	test   %al,%al
  8009f7:	74 0c                	je     800a05 <strcmp+0x1c>
  8009f9:	3a 02                	cmp    (%edx),%al
  8009fb:	75 08                	jne    800a05 <strcmp+0x1c>
		p++, q++;
  8009fd:	83 c1 01             	add    $0x1,%ecx
  800a00:	83 c2 01             	add    $0x1,%edx
  800a03:	eb ed                	jmp    8009f2 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a05:	0f b6 c0             	movzbl %al,%eax
  800a08:	0f b6 12             	movzbl (%edx),%edx
  800a0b:	29 d0                	sub    %edx,%eax
}
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	53                   	push   %ebx
  800a13:	8b 45 08             	mov    0x8(%ebp),%eax
  800a16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a19:	89 c3                	mov    %eax,%ebx
  800a1b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a1e:	eb 06                	jmp    800a26 <strncmp+0x17>
		n--, p++, q++;
  800a20:	83 c0 01             	add    $0x1,%eax
  800a23:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a26:	39 d8                	cmp    %ebx,%eax
  800a28:	74 16                	je     800a40 <strncmp+0x31>
  800a2a:	0f b6 08             	movzbl (%eax),%ecx
  800a2d:	84 c9                	test   %cl,%cl
  800a2f:	74 04                	je     800a35 <strncmp+0x26>
  800a31:	3a 0a                	cmp    (%edx),%cl
  800a33:	74 eb                	je     800a20 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a35:	0f b6 00             	movzbl (%eax),%eax
  800a38:	0f b6 12             	movzbl (%edx),%edx
  800a3b:	29 d0                	sub    %edx,%eax
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    
		return 0;
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
  800a45:	eb f6                	jmp    800a3d <strncmp+0x2e>

00800a47 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a51:	0f b6 10             	movzbl (%eax),%edx
  800a54:	84 d2                	test   %dl,%dl
  800a56:	74 09                	je     800a61 <strchr+0x1a>
		if (*s == c)
  800a58:	38 ca                	cmp    %cl,%dl
  800a5a:	74 0a                	je     800a66 <strchr+0x1f>
	for (; *s; s++)
  800a5c:	83 c0 01             	add    $0x1,%eax
  800a5f:	eb f0                	jmp    800a51 <strchr+0xa>
			return (char *) s;
	return 0;
  800a61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a72:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a75:	38 ca                	cmp    %cl,%dl
  800a77:	74 09                	je     800a82 <strfind+0x1a>
  800a79:	84 d2                	test   %dl,%dl
  800a7b:	74 05                	je     800a82 <strfind+0x1a>
	for (; *s; s++)
  800a7d:	83 c0 01             	add    $0x1,%eax
  800a80:	eb f0                	jmp    800a72 <strfind+0xa>
			break;
	return (char *) s;
}
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	57                   	push   %edi
  800a88:	56                   	push   %esi
  800a89:	53                   	push   %ebx
  800a8a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a90:	85 c9                	test   %ecx,%ecx
  800a92:	74 31                	je     800ac5 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a94:	89 f8                	mov    %edi,%eax
  800a96:	09 c8                	or     %ecx,%eax
  800a98:	a8 03                	test   $0x3,%al
  800a9a:	75 23                	jne    800abf <memset+0x3b>
		c &= 0xFF;
  800a9c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa0:	89 d3                	mov    %edx,%ebx
  800aa2:	c1 e3 08             	shl    $0x8,%ebx
  800aa5:	89 d0                	mov    %edx,%eax
  800aa7:	c1 e0 18             	shl    $0x18,%eax
  800aaa:	89 d6                	mov    %edx,%esi
  800aac:	c1 e6 10             	shl    $0x10,%esi
  800aaf:	09 f0                	or     %esi,%eax
  800ab1:	09 c2                	or     %eax,%edx
  800ab3:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ab5:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ab8:	89 d0                	mov    %edx,%eax
  800aba:	fc                   	cld    
  800abb:	f3 ab                	rep stos %eax,%es:(%edi)
  800abd:	eb 06                	jmp    800ac5 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac2:	fc                   	cld    
  800ac3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac5:	89 f8                	mov    %edi,%eax
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ada:	39 c6                	cmp    %eax,%esi
  800adc:	73 32                	jae    800b10 <memmove+0x44>
  800ade:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae1:	39 c2                	cmp    %eax,%edx
  800ae3:	76 2b                	jbe    800b10 <memmove+0x44>
		s += n;
		d += n;
  800ae5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae8:	89 fe                	mov    %edi,%esi
  800aea:	09 ce                	or     %ecx,%esi
  800aec:	09 d6                	or     %edx,%esi
  800aee:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af4:	75 0e                	jne    800b04 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800af6:	83 ef 04             	sub    $0x4,%edi
  800af9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800afc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aff:	fd                   	std    
  800b00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b02:	eb 09                	jmp    800b0d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b04:	83 ef 01             	sub    $0x1,%edi
  800b07:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b0a:	fd                   	std    
  800b0b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b0d:	fc                   	cld    
  800b0e:	eb 1a                	jmp    800b2a <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b10:	89 c2                	mov    %eax,%edx
  800b12:	09 ca                	or     %ecx,%edx
  800b14:	09 f2                	or     %esi,%edx
  800b16:	f6 c2 03             	test   $0x3,%dl
  800b19:	75 0a                	jne    800b25 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b1b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b1e:	89 c7                	mov    %eax,%edi
  800b20:	fc                   	cld    
  800b21:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b23:	eb 05                	jmp    800b2a <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b25:	89 c7                	mov    %eax,%edi
  800b27:	fc                   	cld    
  800b28:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b2a:	5e                   	pop    %esi
  800b2b:	5f                   	pop    %edi
  800b2c:	5d                   	pop    %ebp
  800b2d:	c3                   	ret    

00800b2e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b34:	ff 75 10             	pushl  0x10(%ebp)
  800b37:	ff 75 0c             	pushl  0xc(%ebp)
  800b3a:	ff 75 08             	pushl  0x8(%ebp)
  800b3d:	e8 8a ff ff ff       	call   800acc <memmove>
}
  800b42:	c9                   	leave  
  800b43:	c3                   	ret    

00800b44 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	56                   	push   %esi
  800b48:	53                   	push   %ebx
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4f:	89 c6                	mov    %eax,%esi
  800b51:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b54:	39 f0                	cmp    %esi,%eax
  800b56:	74 1c                	je     800b74 <memcmp+0x30>
		if (*s1 != *s2)
  800b58:	0f b6 08             	movzbl (%eax),%ecx
  800b5b:	0f b6 1a             	movzbl (%edx),%ebx
  800b5e:	38 d9                	cmp    %bl,%cl
  800b60:	75 08                	jne    800b6a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b62:	83 c0 01             	add    $0x1,%eax
  800b65:	83 c2 01             	add    $0x1,%edx
  800b68:	eb ea                	jmp    800b54 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b6a:	0f b6 c1             	movzbl %cl,%eax
  800b6d:	0f b6 db             	movzbl %bl,%ebx
  800b70:	29 d8                	sub    %ebx,%eax
  800b72:	eb 05                	jmp    800b79 <memcmp+0x35>
	}

	return 0;
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5e                   	pop    %esi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b86:	89 c2                	mov    %eax,%edx
  800b88:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b8b:	39 d0                	cmp    %edx,%eax
  800b8d:	73 09                	jae    800b98 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b8f:	38 08                	cmp    %cl,(%eax)
  800b91:	74 05                	je     800b98 <memfind+0x1b>
	for (; s < ends; s++)
  800b93:	83 c0 01             	add    $0x1,%eax
  800b96:	eb f3                	jmp    800b8b <memfind+0xe>
			break;
	return (void *) s;
}
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ba6:	eb 03                	jmp    800bab <strtol+0x11>
		s++;
  800ba8:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bab:	0f b6 01             	movzbl (%ecx),%eax
  800bae:	3c 20                	cmp    $0x20,%al
  800bb0:	74 f6                	je     800ba8 <strtol+0xe>
  800bb2:	3c 09                	cmp    $0x9,%al
  800bb4:	74 f2                	je     800ba8 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bb6:	3c 2b                	cmp    $0x2b,%al
  800bb8:	74 2a                	je     800be4 <strtol+0x4a>
	int neg = 0;
  800bba:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bbf:	3c 2d                	cmp    $0x2d,%al
  800bc1:	74 2b                	je     800bee <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bc9:	75 0f                	jne    800bda <strtol+0x40>
  800bcb:	80 39 30             	cmpb   $0x30,(%ecx)
  800bce:	74 28                	je     800bf8 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bd0:	85 db                	test   %ebx,%ebx
  800bd2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd7:	0f 44 d8             	cmove  %eax,%ebx
  800bda:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800be2:	eb 50                	jmp    800c34 <strtol+0x9a>
		s++;
  800be4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800be7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bec:	eb d5                	jmp    800bc3 <strtol+0x29>
		s++, neg = 1;
  800bee:	83 c1 01             	add    $0x1,%ecx
  800bf1:	bf 01 00 00 00       	mov    $0x1,%edi
  800bf6:	eb cb                	jmp    800bc3 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bfc:	74 0e                	je     800c0c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bfe:	85 db                	test   %ebx,%ebx
  800c00:	75 d8                	jne    800bda <strtol+0x40>
		s++, base = 8;
  800c02:	83 c1 01             	add    $0x1,%ecx
  800c05:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c0a:	eb ce                	jmp    800bda <strtol+0x40>
		s += 2, base = 16;
  800c0c:	83 c1 02             	add    $0x2,%ecx
  800c0f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c14:	eb c4                	jmp    800bda <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c16:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c19:	89 f3                	mov    %esi,%ebx
  800c1b:	80 fb 19             	cmp    $0x19,%bl
  800c1e:	77 29                	ja     800c49 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c20:	0f be d2             	movsbl %dl,%edx
  800c23:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c26:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c29:	7d 30                	jge    800c5b <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c2b:	83 c1 01             	add    $0x1,%ecx
  800c2e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c32:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c34:	0f b6 11             	movzbl (%ecx),%edx
  800c37:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c3a:	89 f3                	mov    %esi,%ebx
  800c3c:	80 fb 09             	cmp    $0x9,%bl
  800c3f:	77 d5                	ja     800c16 <strtol+0x7c>
			dig = *s - '0';
  800c41:	0f be d2             	movsbl %dl,%edx
  800c44:	83 ea 30             	sub    $0x30,%edx
  800c47:	eb dd                	jmp    800c26 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800c49:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c4c:	89 f3                	mov    %esi,%ebx
  800c4e:	80 fb 19             	cmp    $0x19,%bl
  800c51:	77 08                	ja     800c5b <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c53:	0f be d2             	movsbl %dl,%edx
  800c56:	83 ea 37             	sub    $0x37,%edx
  800c59:	eb cb                	jmp    800c26 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c5f:	74 05                	je     800c66 <strtol+0xcc>
		*endptr = (char *) s;
  800c61:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c64:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c66:	89 c2                	mov    %eax,%edx
  800c68:	f7 da                	neg    %edx
  800c6a:	85 ff                	test   %edi,%edi
  800c6c:	0f 45 c2             	cmovne %edx,%eax
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	89 c3                	mov    %eax,%ebx
  800c87:	89 c7                	mov    %eax,%edi
  800c89:	89 c6                	mov    %eax,%esi
  800c8b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	57                   	push   %edi
  800c96:	56                   	push   %esi
  800c97:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c98:	ba 00 00 00 00       	mov    $0x0,%edx
  800c9d:	b8 01 00 00 00       	mov    $0x1,%eax
  800ca2:	89 d1                	mov    %edx,%ecx
  800ca4:	89 d3                	mov    %edx,%ebx
  800ca6:	89 d7                	mov    %edx,%edi
  800ca8:	89 d6                	mov    %edx,%esi
  800caa:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cba:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc2:	b8 03 00 00 00       	mov    $0x3,%eax
  800cc7:	89 cb                	mov    %ecx,%ebx
  800cc9:	89 cf                	mov    %ecx,%edi
  800ccb:	89 ce                	mov    %ecx,%esi
  800ccd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	7f 08                	jg     800cdb <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5f                   	pop    %edi
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	83 ec 0c             	sub    $0xc,%esp
  800cde:	50                   	push   %eax
  800cdf:	6a 03                	push   $0x3
  800ce1:	68 c4 14 80 00       	push   $0x8014c4
  800ce6:	6a 23                	push   $0x23
  800ce8:	68 e1 14 80 00       	push   $0x8014e1
  800ced:	e8 2e 02 00 00       	call   800f20 <_panic>

00800cf2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf8:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfd:	b8 02 00 00 00       	mov    $0x2,%eax
  800d02:	89 d1                	mov    %edx,%ecx
  800d04:	89 d3                	mov    %edx,%ebx
  800d06:	89 d7                	mov    %edx,%edi
  800d08:	89 d6                	mov    %edx,%esi
  800d0a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d0c:	5b                   	pop    %ebx
  800d0d:	5e                   	pop    %esi
  800d0e:	5f                   	pop    %edi
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <sys_yield>:

void
sys_yield(void)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d17:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d21:	89 d1                	mov    %edx,%ecx
  800d23:	89 d3                	mov    %edx,%ebx
  800d25:	89 d7                	mov    %edx,%edi
  800d27:	89 d6                	mov    %edx,%esi
  800d29:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d39:	be 00 00 00 00       	mov    $0x0,%esi
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	b8 04 00 00 00       	mov    $0x4,%eax
  800d49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4c:	89 f7                	mov    %esi,%edi
  800d4e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	7f 08                	jg     800d5c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d57:	5b                   	pop    %ebx
  800d58:	5e                   	pop    %esi
  800d59:	5f                   	pop    %edi
  800d5a:	5d                   	pop    %ebp
  800d5b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5c:	83 ec 0c             	sub    $0xc,%esp
  800d5f:	50                   	push   %eax
  800d60:	6a 04                	push   $0x4
  800d62:	68 c4 14 80 00       	push   $0x8014c4
  800d67:	6a 23                	push   $0x23
  800d69:	68 e1 14 80 00       	push   $0x8014e1
  800d6e:	e8 ad 01 00 00       	call   800f20 <_panic>

00800d73 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	b8 05 00 00 00       	mov    $0x5,%eax
  800d87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8d:	8b 75 18             	mov    0x18(%ebp),%esi
  800d90:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7f 08                	jg     800d9e <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	50                   	push   %eax
  800da2:	6a 05                	push   $0x5
  800da4:	68 c4 14 80 00       	push   $0x8014c4
  800da9:	6a 23                	push   $0x23
  800dab:	68 e1 14 80 00       	push   $0x8014e1
  800db0:	e8 6b 01 00 00       	call   800f20 <_panic>

00800db5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	57                   	push   %edi
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dbe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc9:	b8 06 00 00 00       	mov    $0x6,%eax
  800dce:	89 df                	mov    %ebx,%edi
  800dd0:	89 de                	mov    %ebx,%esi
  800dd2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	7f 08                	jg     800de0 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800de0:	83 ec 0c             	sub    $0xc,%esp
  800de3:	50                   	push   %eax
  800de4:	6a 06                	push   $0x6
  800de6:	68 c4 14 80 00       	push   $0x8014c4
  800deb:	6a 23                	push   $0x23
  800ded:	68 e1 14 80 00       	push   $0x8014e1
  800df2:	e8 29 01 00 00       	call   800f20 <_panic>

00800df7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	57                   	push   %edi
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e05:	8b 55 08             	mov    0x8(%ebp),%edx
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0b:	b8 08 00 00 00       	mov    $0x8,%eax
  800e10:	89 df                	mov    %ebx,%edi
  800e12:	89 de                	mov    %ebx,%esi
  800e14:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e16:	85 c0                	test   %eax,%eax
  800e18:	7f 08                	jg     800e22 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e22:	83 ec 0c             	sub    $0xc,%esp
  800e25:	50                   	push   %eax
  800e26:	6a 08                	push   $0x8
  800e28:	68 c4 14 80 00       	push   $0x8014c4
  800e2d:	6a 23                	push   $0x23
  800e2f:	68 e1 14 80 00       	push   $0x8014e1
  800e34:	e8 e7 00 00 00       	call   800f20 <_panic>

00800e39 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	57                   	push   %edi
  800e3d:	56                   	push   %esi
  800e3e:	53                   	push   %ebx
  800e3f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e47:	8b 55 08             	mov    0x8(%ebp),%edx
  800e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e52:	89 df                	mov    %ebx,%edi
  800e54:	89 de                	mov    %ebx,%esi
  800e56:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e58:	85 c0                	test   %eax,%eax
  800e5a:	7f 08                	jg     800e64 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5f:	5b                   	pop    %ebx
  800e60:	5e                   	pop    %esi
  800e61:	5f                   	pop    %edi
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e64:	83 ec 0c             	sub    $0xc,%esp
  800e67:	50                   	push   %eax
  800e68:	6a 09                	push   $0x9
  800e6a:	68 c4 14 80 00       	push   $0x8014c4
  800e6f:	6a 23                	push   $0x23
  800e71:	68 e1 14 80 00       	push   $0x8014e1
  800e76:	e8 a5 00 00 00       	call   800f20 <_panic>

00800e7b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	57                   	push   %edi
  800e7f:	56                   	push   %esi
  800e80:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e81:	8b 55 08             	mov    0x8(%ebp),%edx
  800e84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e87:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e8c:	be 00 00 00 00       	mov    $0x0,%esi
  800e91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e94:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e97:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e99:	5b                   	pop    %ebx
  800e9a:	5e                   	pop    %esi
  800e9b:	5f                   	pop    %edi
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb4:	89 cb                	mov    %ecx,%ebx
  800eb6:	89 cf                	mov    %ecx,%edi
  800eb8:	89 ce                	mov    %ecx,%esi
  800eba:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	7f 08                	jg     800ec8 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ec0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec3:	5b                   	pop    %ebx
  800ec4:	5e                   	pop    %esi
  800ec5:	5f                   	pop    %edi
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec8:	83 ec 0c             	sub    $0xc,%esp
  800ecb:	50                   	push   %eax
  800ecc:	6a 0c                	push   $0xc
  800ece:	68 c4 14 80 00       	push   $0x8014c4
  800ed3:	6a 23                	push   $0x23
  800ed5:	68 e1 14 80 00       	push   $0x8014e1
  800eda:	e8 41 00 00 00       	call   800f20 <_panic>

00800edf <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ee5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eea:	8b 55 08             	mov    0x8(%ebp),%edx
  800eed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ef5:	89 df                	mov    %ebx,%edi
  800ef7:	89 de                	mov    %ebx,%esi
  800ef9:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    

00800f00 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800f00:	55                   	push   %ebp
  800f01:	89 e5                	mov    %esp,%ebp
  800f03:	57                   	push   %edi
  800f04:	56                   	push   %esi
  800f05:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f06:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f0e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f13:	89 cb                	mov    %ecx,%ebx
  800f15:	89 cf                	mov    %ecx,%edi
  800f17:	89 ce                	mov    %ecx,%esi
  800f19:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f1b:	5b                   	pop    %ebx
  800f1c:	5e                   	pop    %esi
  800f1d:	5f                   	pop    %edi
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800f25:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f28:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f2e:	e8 bf fd ff ff       	call   800cf2 <sys_getenvid>
  800f33:	83 ec 0c             	sub    $0xc,%esp
  800f36:	ff 75 0c             	pushl  0xc(%ebp)
  800f39:	ff 75 08             	pushl  0x8(%ebp)
  800f3c:	56                   	push   %esi
  800f3d:	50                   	push   %eax
  800f3e:	68 f0 14 80 00       	push   $0x8014f0
  800f43:	e8 60 f2 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f48:	83 c4 18             	add    $0x18,%esp
  800f4b:	53                   	push   %ebx
  800f4c:	ff 75 10             	pushl  0x10(%ebp)
  800f4f:	e8 03 f2 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  800f54:	c7 04 24 ed 11 80 00 	movl   $0x8011ed,(%esp)
  800f5b:	e8 48 f2 ff ff       	call   8001a8 <cprintf>
  800f60:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f63:	cc                   	int3   
  800f64:	eb fd                	jmp    800f63 <_panic+0x43>
  800f66:	66 90                	xchg   %ax,%ax
  800f68:	66 90                	xchg   %ax,%ax
  800f6a:	66 90                	xchg   %ax,%ax
  800f6c:	66 90                	xchg   %ax,%ax
  800f6e:	66 90                	xchg   %ax,%ax

00800f70 <__udivdi3>:
  800f70:	55                   	push   %ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
  800f74:	83 ec 1c             	sub    $0x1c,%esp
  800f77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f7b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f83:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f87:	85 d2                	test   %edx,%edx
  800f89:	75 4d                	jne    800fd8 <__udivdi3+0x68>
  800f8b:	39 f3                	cmp    %esi,%ebx
  800f8d:	76 19                	jbe    800fa8 <__udivdi3+0x38>
  800f8f:	31 ff                	xor    %edi,%edi
  800f91:	89 e8                	mov    %ebp,%eax
  800f93:	89 f2                	mov    %esi,%edx
  800f95:	f7 f3                	div    %ebx
  800f97:	89 fa                	mov    %edi,%edx
  800f99:	83 c4 1c             	add    $0x1c,%esp
  800f9c:	5b                   	pop    %ebx
  800f9d:	5e                   	pop    %esi
  800f9e:	5f                   	pop    %edi
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    
  800fa1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fa8:	89 d9                	mov    %ebx,%ecx
  800faa:	85 db                	test   %ebx,%ebx
  800fac:	75 0b                	jne    800fb9 <__udivdi3+0x49>
  800fae:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb3:	31 d2                	xor    %edx,%edx
  800fb5:	f7 f3                	div    %ebx
  800fb7:	89 c1                	mov    %eax,%ecx
  800fb9:	31 d2                	xor    %edx,%edx
  800fbb:	89 f0                	mov    %esi,%eax
  800fbd:	f7 f1                	div    %ecx
  800fbf:	89 c6                	mov    %eax,%esi
  800fc1:	89 e8                	mov    %ebp,%eax
  800fc3:	89 f7                	mov    %esi,%edi
  800fc5:	f7 f1                	div    %ecx
  800fc7:	89 fa                	mov    %edi,%edx
  800fc9:	83 c4 1c             	add    $0x1c,%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5f                   	pop    %edi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    
  800fd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fd8:	39 f2                	cmp    %esi,%edx
  800fda:	77 1c                	ja     800ff8 <__udivdi3+0x88>
  800fdc:	0f bd fa             	bsr    %edx,%edi
  800fdf:	83 f7 1f             	xor    $0x1f,%edi
  800fe2:	75 2c                	jne    801010 <__udivdi3+0xa0>
  800fe4:	39 f2                	cmp    %esi,%edx
  800fe6:	72 06                	jb     800fee <__udivdi3+0x7e>
  800fe8:	31 c0                	xor    %eax,%eax
  800fea:	39 eb                	cmp    %ebp,%ebx
  800fec:	77 a9                	ja     800f97 <__udivdi3+0x27>
  800fee:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff3:	eb a2                	jmp    800f97 <__udivdi3+0x27>
  800ff5:	8d 76 00             	lea    0x0(%esi),%esi
  800ff8:	31 ff                	xor    %edi,%edi
  800ffa:	31 c0                	xor    %eax,%eax
  800ffc:	89 fa                	mov    %edi,%edx
  800ffe:	83 c4 1c             	add    $0x1c,%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    
  801006:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	89 f9                	mov    %edi,%ecx
  801012:	b8 20 00 00 00       	mov    $0x20,%eax
  801017:	29 f8                	sub    %edi,%eax
  801019:	d3 e2                	shl    %cl,%edx
  80101b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80101f:	89 c1                	mov    %eax,%ecx
  801021:	89 da                	mov    %ebx,%edx
  801023:	d3 ea                	shr    %cl,%edx
  801025:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801029:	09 d1                	or     %edx,%ecx
  80102b:	89 f2                	mov    %esi,%edx
  80102d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801031:	89 f9                	mov    %edi,%ecx
  801033:	d3 e3                	shl    %cl,%ebx
  801035:	89 c1                	mov    %eax,%ecx
  801037:	d3 ea                	shr    %cl,%edx
  801039:	89 f9                	mov    %edi,%ecx
  80103b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80103f:	89 eb                	mov    %ebp,%ebx
  801041:	d3 e6                	shl    %cl,%esi
  801043:	89 c1                	mov    %eax,%ecx
  801045:	d3 eb                	shr    %cl,%ebx
  801047:	09 de                	or     %ebx,%esi
  801049:	89 f0                	mov    %esi,%eax
  80104b:	f7 74 24 08          	divl   0x8(%esp)
  80104f:	89 d6                	mov    %edx,%esi
  801051:	89 c3                	mov    %eax,%ebx
  801053:	f7 64 24 0c          	mull   0xc(%esp)
  801057:	39 d6                	cmp    %edx,%esi
  801059:	72 15                	jb     801070 <__udivdi3+0x100>
  80105b:	89 f9                	mov    %edi,%ecx
  80105d:	d3 e5                	shl    %cl,%ebp
  80105f:	39 c5                	cmp    %eax,%ebp
  801061:	73 04                	jae    801067 <__udivdi3+0xf7>
  801063:	39 d6                	cmp    %edx,%esi
  801065:	74 09                	je     801070 <__udivdi3+0x100>
  801067:	89 d8                	mov    %ebx,%eax
  801069:	31 ff                	xor    %edi,%edi
  80106b:	e9 27 ff ff ff       	jmp    800f97 <__udivdi3+0x27>
  801070:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801073:	31 ff                	xor    %edi,%edi
  801075:	e9 1d ff ff ff       	jmp    800f97 <__udivdi3+0x27>
  80107a:	66 90                	xchg   %ax,%ax
  80107c:	66 90                	xchg   %ax,%ax
  80107e:	66 90                	xchg   %ax,%ax

00801080 <__umoddi3>:
  801080:	55                   	push   %ebp
  801081:	57                   	push   %edi
  801082:	56                   	push   %esi
  801083:	53                   	push   %ebx
  801084:	83 ec 1c             	sub    $0x1c,%esp
  801087:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80108b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80108f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801093:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801097:	89 da                	mov    %ebx,%edx
  801099:	85 c0                	test   %eax,%eax
  80109b:	75 43                	jne    8010e0 <__umoddi3+0x60>
  80109d:	39 df                	cmp    %ebx,%edi
  80109f:	76 17                	jbe    8010b8 <__umoddi3+0x38>
  8010a1:	89 f0                	mov    %esi,%eax
  8010a3:	f7 f7                	div    %edi
  8010a5:	89 d0                	mov    %edx,%eax
  8010a7:	31 d2                	xor    %edx,%edx
  8010a9:	83 c4 1c             	add    $0x1c,%esp
  8010ac:	5b                   	pop    %ebx
  8010ad:	5e                   	pop    %esi
  8010ae:	5f                   	pop    %edi
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    
  8010b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010b8:	89 fd                	mov    %edi,%ebp
  8010ba:	85 ff                	test   %edi,%edi
  8010bc:	75 0b                	jne    8010c9 <__umoddi3+0x49>
  8010be:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c3:	31 d2                	xor    %edx,%edx
  8010c5:	f7 f7                	div    %edi
  8010c7:	89 c5                	mov    %eax,%ebp
  8010c9:	89 d8                	mov    %ebx,%eax
  8010cb:	31 d2                	xor    %edx,%edx
  8010cd:	f7 f5                	div    %ebp
  8010cf:	89 f0                	mov    %esi,%eax
  8010d1:	f7 f5                	div    %ebp
  8010d3:	89 d0                	mov    %edx,%eax
  8010d5:	eb d0                	jmp    8010a7 <__umoddi3+0x27>
  8010d7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010de:	66 90                	xchg   %ax,%ax
  8010e0:	89 f1                	mov    %esi,%ecx
  8010e2:	39 d8                	cmp    %ebx,%eax
  8010e4:	76 0a                	jbe    8010f0 <__umoddi3+0x70>
  8010e6:	89 f0                	mov    %esi,%eax
  8010e8:	83 c4 1c             	add    $0x1c,%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    
  8010f0:	0f bd e8             	bsr    %eax,%ebp
  8010f3:	83 f5 1f             	xor    $0x1f,%ebp
  8010f6:	75 20                	jne    801118 <__umoddi3+0x98>
  8010f8:	39 d8                	cmp    %ebx,%eax
  8010fa:	0f 82 b0 00 00 00    	jb     8011b0 <__umoddi3+0x130>
  801100:	39 f7                	cmp    %esi,%edi
  801102:	0f 86 a8 00 00 00    	jbe    8011b0 <__umoddi3+0x130>
  801108:	89 c8                	mov    %ecx,%eax
  80110a:	83 c4 1c             	add    $0x1c,%esp
  80110d:	5b                   	pop    %ebx
  80110e:	5e                   	pop    %esi
  80110f:	5f                   	pop    %edi
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    
  801112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801118:	89 e9                	mov    %ebp,%ecx
  80111a:	ba 20 00 00 00       	mov    $0x20,%edx
  80111f:	29 ea                	sub    %ebp,%edx
  801121:	d3 e0                	shl    %cl,%eax
  801123:	89 44 24 08          	mov    %eax,0x8(%esp)
  801127:	89 d1                	mov    %edx,%ecx
  801129:	89 f8                	mov    %edi,%eax
  80112b:	d3 e8                	shr    %cl,%eax
  80112d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801131:	89 54 24 04          	mov    %edx,0x4(%esp)
  801135:	8b 54 24 04          	mov    0x4(%esp),%edx
  801139:	09 c1                	or     %eax,%ecx
  80113b:	89 d8                	mov    %ebx,%eax
  80113d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801141:	89 e9                	mov    %ebp,%ecx
  801143:	d3 e7                	shl    %cl,%edi
  801145:	89 d1                	mov    %edx,%ecx
  801147:	d3 e8                	shr    %cl,%eax
  801149:	89 e9                	mov    %ebp,%ecx
  80114b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80114f:	d3 e3                	shl    %cl,%ebx
  801151:	89 c7                	mov    %eax,%edi
  801153:	89 d1                	mov    %edx,%ecx
  801155:	89 f0                	mov    %esi,%eax
  801157:	d3 e8                	shr    %cl,%eax
  801159:	89 e9                	mov    %ebp,%ecx
  80115b:	89 fa                	mov    %edi,%edx
  80115d:	d3 e6                	shl    %cl,%esi
  80115f:	09 d8                	or     %ebx,%eax
  801161:	f7 74 24 08          	divl   0x8(%esp)
  801165:	89 d1                	mov    %edx,%ecx
  801167:	89 f3                	mov    %esi,%ebx
  801169:	f7 64 24 0c          	mull   0xc(%esp)
  80116d:	89 c6                	mov    %eax,%esi
  80116f:	89 d7                	mov    %edx,%edi
  801171:	39 d1                	cmp    %edx,%ecx
  801173:	72 06                	jb     80117b <__umoddi3+0xfb>
  801175:	75 10                	jne    801187 <__umoddi3+0x107>
  801177:	39 c3                	cmp    %eax,%ebx
  801179:	73 0c                	jae    801187 <__umoddi3+0x107>
  80117b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80117f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801183:	89 d7                	mov    %edx,%edi
  801185:	89 c6                	mov    %eax,%esi
  801187:	89 ca                	mov    %ecx,%edx
  801189:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80118e:	29 f3                	sub    %esi,%ebx
  801190:	19 fa                	sbb    %edi,%edx
  801192:	89 d0                	mov    %edx,%eax
  801194:	d3 e0                	shl    %cl,%eax
  801196:	89 e9                	mov    %ebp,%ecx
  801198:	d3 eb                	shr    %cl,%ebx
  80119a:	d3 ea                	shr    %cl,%edx
  80119c:	09 d8                	or     %ebx,%eax
  80119e:	83 c4 1c             	add    $0x1c,%esp
  8011a1:	5b                   	pop    %ebx
  8011a2:	5e                   	pop    %esi
  8011a3:	5f                   	pop    %edi
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    
  8011a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011ad:	8d 76 00             	lea    0x0(%esi),%esi
  8011b0:	89 da                	mov    %ebx,%edx
  8011b2:	29 fe                	sub    %edi,%esi
  8011b4:	19 c2                	sbb    %eax,%edx
  8011b6:	89 f1                	mov    %esi,%ecx
  8011b8:	89 c8                	mov    %ecx,%eax
  8011ba:	e9 4b ff ff ff       	jmp    80110a <__umoddi3+0x8a>
