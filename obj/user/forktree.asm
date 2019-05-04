
obj/user/forktree:     file format elf32-i386


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
  80002c:	e8 b2 00 00 00       	call   8000e3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 d8 0c 00 00       	call   800d1a <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 20 12 80 00       	push   $0x801220
  80004c:	e8 7f 01 00 00       	call   8001d0 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 aa 08 00 00       	call   80092d <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7e 07                	jle    800092 <forkchild+0x23>
}
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	89 f0                	mov    %esi,%eax
  800097:	0f be f0             	movsbl %al,%esi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	68 31 12 80 00       	push   $0x801231
  8000a1:	6a 04                	push   $0x4
  8000a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a6:	50                   	push   %eax
  8000a7:	e8 67 08 00 00       	call   800913 <snprintf>
	if (fork() == 0) {
  8000ac:	83 c4 20             	add    $0x20,%esp
  8000af:	e8 94 0e 00 00       	call   800f48 <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	75 d3                	jne    80008b <forkchild+0x1c>
		forktree(nxt);
  8000b8:	83 ec 0c             	sub    $0xc,%esp
  8000bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000be:	50                   	push   %eax
  8000bf:	e8 6f ff ff ff       	call   800033 <forktree>
		exit();
  8000c4:	e8 60 00 00 00       	call   800129 <exit>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb bd                	jmp    80008b <forkchild+0x1c>

008000ce <umain>:

void
umain(int argc, char **argv)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d4:	68 30 12 80 00       	push   $0x801230
  8000d9:	e8 55 ff ff ff       	call   800033 <forktree>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ee:	e8 27 0c 00 00       	call   800d1a <sys_getenvid>
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	c1 e0 07             	shl    $0x7,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x2d>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800110:	83 ec 08             	sub    $0x8,%esp
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
  800115:	e8 b4 ff ff ff       	call   8000ce <umain>

	// exit gracefully
	exit();
  80011a:	e8 0a 00 00 00       	call   800129 <exit>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012f:	6a 00                	push   $0x0
  800131:	e8 a3 0b 00 00       	call   800cd9 <sys_env_destroy>
}
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	53                   	push   %ebx
  80013f:	83 ec 04             	sub    $0x4,%esp
  800142:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800145:	8b 13                	mov    (%ebx),%edx
  800147:	8d 42 01             	lea    0x1(%edx),%eax
  80014a:	89 03                	mov    %eax,(%ebx)
  80014c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800153:	3d ff 00 00 00       	cmp    $0xff,%eax
  800158:	74 09                	je     800163 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800163:	83 ec 08             	sub    $0x8,%esp
  800166:	68 ff 00 00 00       	push   $0xff
  80016b:	8d 43 08             	lea    0x8(%ebx),%eax
  80016e:	50                   	push   %eax
  80016f:	e8 28 0b 00 00       	call   800c9c <sys_cputs>
		b->idx = 0;
  800174:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	eb db                	jmp    80015a <putch+0x1f>

0080017f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800188:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018f:	00 00 00 
	b.cnt = 0;
  800192:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800199:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80019c:	ff 75 0c             	pushl  0xc(%ebp)
  80019f:	ff 75 08             	pushl  0x8(%ebp)
  8001a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a8:	50                   	push   %eax
  8001a9:	68 3b 01 80 00       	push   $0x80013b
  8001ae:	e8 fb 00 00 00       	call   8002ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b3:	83 c4 08             	add    $0x8,%esp
  8001b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c2:	50                   	push   %eax
  8001c3:	e8 d4 0a 00 00       	call   800c9c <sys_cputs>

	return b.cnt;
}
  8001c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ce:	c9                   	leave  
  8001cf:	c3                   	ret    

008001d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d9:	50                   	push   %eax
  8001da:	ff 75 08             	pushl  0x8(%ebp)
  8001dd:	e8 9d ff ff ff       	call   80017f <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e2:	c9                   	leave  
  8001e3:	c3                   	ret    

008001e4 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	57                   	push   %edi
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	83 ec 1c             	sub    $0x1c,%esp
  8001ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f0:	89 d3                	mov    %edx,%ebx
  8001f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8001f5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  8001fe:	89 c2                	mov    %eax,%edx
  800200:	b9 00 00 00 00       	mov    $0x0,%ecx
  800205:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800208:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80020b:	39 c6                	cmp    %eax,%esi
  80020d:	89 f8                	mov    %edi,%eax
  80020f:	19 c8                	sbb    %ecx,%eax
  800211:	73 32                	jae    800245 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800213:	83 ec 08             	sub    $0x8,%esp
  800216:	53                   	push   %ebx
  800217:	83 ec 04             	sub    $0x4,%esp
  80021a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021d:	ff 75 e0             	pushl  -0x20(%ebp)
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	e8 a9 0e 00 00       	call   8010d0 <__umoddi3>
  800227:	83 c4 14             	add    $0x14,%esp
  80022a:	0f be 80 40 12 80 00 	movsbl 0x801240(%eax),%eax
  800231:	50                   	push   %eax
  800232:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800235:	ff d0                	call   *%eax
	return remain - 1;
  800237:	8b 45 14             	mov    0x14(%ebp),%eax
  80023a:	83 e8 01             	sub    $0x1,%eax
}
  80023d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800240:	5b                   	pop    %ebx
  800241:	5e                   	pop    %esi
  800242:	5f                   	pop    %edi
  800243:	5d                   	pop    %ebp
  800244:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  800245:	83 ec 0c             	sub    $0xc,%esp
  800248:	ff 75 18             	pushl  0x18(%ebp)
  80024b:	ff 75 14             	pushl  0x14(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	51                   	push   %ecx
  800255:	52                   	push   %edx
  800256:	57                   	push   %edi
  800257:	56                   	push   %esi
  800258:	e8 63 0d 00 00       	call   800fc0 <__udivdi3>
  80025d:	83 c4 18             	add    $0x18,%esp
  800260:	52                   	push   %edx
  800261:	50                   	push   %eax
  800262:	89 da                	mov    %ebx,%edx
  800264:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800267:	e8 78 ff ff ff       	call   8001e4 <printnum_helper>
  80026c:	89 45 14             	mov    %eax,0x14(%ebp)
  80026f:	83 c4 20             	add    $0x20,%esp
  800272:	eb 9f                	jmp    800213 <printnum_helper+0x2f>

00800274 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	3b 50 04             	cmp    0x4(%eax),%edx
  800283:	73 0a                	jae    80028f <sprintputch+0x1b>
		*b->buf++ = ch;
  800285:	8d 4a 01             	lea    0x1(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	88 02                	mov    %al,(%edx)
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <printfmt>:
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800297:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029a:	50                   	push   %eax
  80029b:	ff 75 10             	pushl  0x10(%ebp)
  80029e:	ff 75 0c             	pushl  0xc(%ebp)
  8002a1:	ff 75 08             	pushl  0x8(%ebp)
  8002a4:	e8 05 00 00 00       	call   8002ae <vprintfmt>
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <vprintfmt>:
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 3c             	sub    $0x3c,%esp
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c0:	e9 3f 05 00 00       	jmp    800804 <vprintfmt+0x556>
		padc = ' ';
  8002c5:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  8002c9:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  8002d0:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8002d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  8002de:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  8002e5:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8002ec:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002f1:	8d 47 01             	lea    0x1(%edi),%eax
  8002f4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f7:	0f b6 17             	movzbl (%edi),%edx
  8002fa:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002fd:	3c 55                	cmp    $0x55,%al
  8002ff:	0f 87 98 05 00 00    	ja     80089d <vprintfmt+0x5ef>
  800305:	0f b6 c0             	movzbl %al,%eax
  800308:	ff 24 85 80 13 80 00 	jmp    *0x801380(,%eax,4)
  80030f:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  800312:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  800316:	eb d9                	jmp    8002f1 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800318:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  80031b:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  800322:	eb cd                	jmp    8002f1 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800324:	0f b6 d2             	movzbl %dl,%edx
  800327:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80032a:	b8 00 00 00 00       	mov    $0x0,%eax
  80032f:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  800332:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800335:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800339:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80033c:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80033f:	83 fb 09             	cmp    $0x9,%ebx
  800342:	77 5c                	ja     8003a0 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  800344:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800347:	eb e9                	jmp    800332 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  800349:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  80034c:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  800350:	eb 9f                	jmp    8002f1 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  800352:	8b 45 14             	mov    0x14(%ebp),%eax
  800355:	8b 00                	mov    (%eax),%eax
  800357:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8d 40 04             	lea    0x4(%eax),%eax
  800360:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800363:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  800366:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80036a:	79 85                	jns    8002f1 <vprintfmt+0x43>
				width = precision, precision = -1;
  80036c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800372:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800379:	e9 73 ff ff ff       	jmp    8002f1 <vprintfmt+0x43>
  80037e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800381:	85 c0                	test   %eax,%eax
  800383:	0f 48 c1             	cmovs  %ecx,%eax
  800386:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80038c:	e9 60 ff ff ff       	jmp    8002f1 <vprintfmt+0x43>
  800391:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  800394:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  80039b:	e9 51 ff ff ff       	jmp    8002f1 <vprintfmt+0x43>
  8003a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a6:	eb be                	jmp    800366 <vprintfmt+0xb8>
			lflag++;
  8003a8:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  8003af:	e9 3d ff ff ff       	jmp    8002f1 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  8003b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b7:	8d 78 04             	lea    0x4(%eax),%edi
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	56                   	push   %esi
  8003be:	ff 30                	pushl  (%eax)
  8003c0:	ff d3                	call   *%ebx
			break;
  8003c2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003c5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003c8:	e9 34 04 00 00       	jmp    800801 <vprintfmt+0x553>
			err = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 78 04             	lea    0x4(%eax),%edi
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	99                   	cltd   
  8003d6:	31 d0                	xor    %edx,%eax
  8003d8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003da:	83 f8 08             	cmp    $0x8,%eax
  8003dd:	7f 23                	jg     800402 <vprintfmt+0x154>
  8003df:	8b 14 85 e0 14 80 00 	mov    0x8014e0(,%eax,4),%edx
  8003e6:	85 d2                	test   %edx,%edx
  8003e8:	74 18                	je     800402 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  8003ea:	52                   	push   %edx
  8003eb:	68 61 12 80 00       	push   $0x801261
  8003f0:	56                   	push   %esi
  8003f1:	53                   	push   %ebx
  8003f2:	e8 9a fe ff ff       	call   800291 <printfmt>
  8003f7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003fa:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003fd:	e9 ff 03 00 00       	jmp    800801 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  800402:	50                   	push   %eax
  800403:	68 58 12 80 00       	push   $0x801258
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
  80040a:	e8 82 fe ff ff       	call   800291 <printfmt>
  80040f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800412:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800415:	e9 e7 03 00 00       	jmp    800801 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	83 c0 04             	add    $0x4,%eax
  800420:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800428:	85 c9                	test   %ecx,%ecx
  80042a:	b8 51 12 80 00       	mov    $0x801251,%eax
  80042f:	0f 45 c1             	cmovne %ecx,%eax
  800432:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800435:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800439:	7e 06                	jle    800441 <vprintfmt+0x193>
  80043b:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  80043f:	75 0d                	jne    80044e <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800441:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800444:	89 c7                	mov    %eax,%edi
  800446:	03 45 d8             	add    -0x28(%ebp),%eax
  800449:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80044c:	eb 53                	jmp    8004a1 <vprintfmt+0x1f3>
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	ff 75 e0             	pushl  -0x20(%ebp)
  800454:	50                   	push   %eax
  800455:	e8 eb 04 00 00       	call   800945 <strnlen>
  80045a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80045d:	29 c1                	sub    %eax,%ecx
  80045f:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  800462:	83 c4 10             	add    $0x10,%esp
  800465:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800467:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  80046b:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80046e:	eb 0f                	jmp    80047f <vprintfmt+0x1d1>
					putch(padc, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	56                   	push   %esi
  800474:	ff 75 d8             	pushl  -0x28(%ebp)
  800477:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800479:	83 ef 01             	sub    $0x1,%edi
  80047c:	83 c4 10             	add    $0x10,%esp
  80047f:	85 ff                	test   %edi,%edi
  800481:	7f ed                	jg     800470 <vprintfmt+0x1c2>
  800483:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800486:	85 c9                	test   %ecx,%ecx
  800488:	b8 00 00 00 00       	mov    $0x0,%eax
  80048d:	0f 49 c1             	cmovns %ecx,%eax
  800490:	29 c1                	sub    %eax,%ecx
  800492:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800495:	eb aa                	jmp    800441 <vprintfmt+0x193>
					putch(ch, putdat);
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	56                   	push   %esi
  80049b:	52                   	push   %edx
  80049c:	ff d3                	call   *%ebx
  80049e:	83 c4 10             	add    $0x10,%esp
  8004a1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8004a4:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a6:	83 c7 01             	add    $0x1,%edi
  8004a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ad:	0f be d0             	movsbl %al,%edx
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	74 2e                	je     8004e2 <vprintfmt+0x234>
  8004b4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b8:	78 06                	js     8004c0 <vprintfmt+0x212>
  8004ba:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8004be:	78 1e                	js     8004de <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c0:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004c4:	74 d1                	je     800497 <vprintfmt+0x1e9>
  8004c6:	0f be c0             	movsbl %al,%eax
  8004c9:	83 e8 20             	sub    $0x20,%eax
  8004cc:	83 f8 5e             	cmp    $0x5e,%eax
  8004cf:	76 c6                	jbe    800497 <vprintfmt+0x1e9>
					putch('?', putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	56                   	push   %esi
  8004d5:	6a 3f                	push   $0x3f
  8004d7:	ff d3                	call   *%ebx
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	eb c3                	jmp    8004a1 <vprintfmt+0x1f3>
  8004de:	89 cf                	mov    %ecx,%edi
  8004e0:	eb 02                	jmp    8004e4 <vprintfmt+0x236>
  8004e2:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  8004e4:	85 ff                	test   %edi,%edi
  8004e6:	7e 10                	jle    8004f8 <vprintfmt+0x24a>
				putch(' ', putdat);
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	56                   	push   %esi
  8004ec:	6a 20                	push   $0x20
  8004ee:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8004f0:	83 ef 01             	sub    $0x1,%edi
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	eb ec                	jmp    8004e4 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  8004f8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8004fb:	89 45 14             	mov    %eax,0x14(%ebp)
  8004fe:	e9 fe 02 00 00       	jmp    800801 <vprintfmt+0x553>
	if (lflag >= 2)
  800503:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800507:	7f 21                	jg     80052a <vprintfmt+0x27c>
	else if (lflag)
  800509:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80050d:	74 79                	je     800588 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8b 00                	mov    (%eax),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	89 c1                	mov    %eax,%ecx
  800519:	c1 f9 1f             	sar    $0x1f,%ecx
  80051c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8d 40 04             	lea    0x4(%eax),%eax
  800525:	89 45 14             	mov    %eax,0x14(%ebp)
  800528:	eb 17                	jmp    800541 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  80052a:	8b 45 14             	mov    0x14(%ebp),%eax
  80052d:	8b 50 04             	mov    0x4(%eax),%edx
  800530:	8b 00                	mov    (%eax),%eax
  800532:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800535:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 40 08             	lea    0x8(%eax),%eax
  80053e:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  800541:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800544:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800547:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80054a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  80054d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800551:	78 50                	js     8005a3 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  800553:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800556:	c1 fa 1f             	sar    $0x1f,%edx
  800559:	89 d0                	mov    %edx,%eax
  80055b:	2b 45 e0             	sub    -0x20(%ebp),%eax
  80055e:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  800561:	85 d2                	test   %edx,%edx
  800563:	0f 89 14 02 00 00    	jns    80077d <vprintfmt+0x4cf>
  800569:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80056d:	0f 84 0a 02 00 00    	je     80077d <vprintfmt+0x4cf>
				putch('+', putdat);
  800573:	83 ec 08             	sub    $0x8,%esp
  800576:	56                   	push   %esi
  800577:	6a 2b                	push   $0x2b
  800579:	ff d3                	call   *%ebx
  80057b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80057e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800583:	e9 5c 01 00 00       	jmp    8006e4 <vprintfmt+0x436>
		return va_arg(*ap, int);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800590:	89 c1                	mov    %eax,%ecx
  800592:	c1 f9 1f             	sar    $0x1f,%ecx
  800595:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8d 40 04             	lea    0x4(%eax),%eax
  80059e:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a1:	eb 9e                	jmp    800541 <vprintfmt+0x293>
				putch('-', putdat);
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	56                   	push   %esi
  8005a7:	6a 2d                	push   $0x2d
  8005a9:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005ab:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b1:	f7 d8                	neg    %eax
  8005b3:	83 d2 00             	adc    $0x0,%edx
  8005b6:	f7 da                	neg    %edx
  8005b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005bb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005be:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c6:	e9 19 01 00 00       	jmp    8006e4 <vprintfmt+0x436>
	if (lflag >= 2)
  8005cb:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8005cf:	7f 29                	jg     8005fa <vprintfmt+0x34c>
	else if (lflag)
  8005d1:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8005d5:	74 44                	je     80061b <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005e4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	8d 40 04             	lea    0x4(%eax),%eax
  8005ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f5:	e9 ea 00 00 00       	jmp    8006e4 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8b 50 04             	mov    0x4(%eax),%edx
  800600:	8b 00                	mov    (%eax),%eax
  800602:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800605:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 40 08             	lea    0x8(%eax),%eax
  80060e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800611:	b8 0a 00 00 00       	mov    $0xa,%eax
  800616:	e9 c9 00 00 00       	jmp    8006e4 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	ba 00 00 00 00       	mov    $0x0,%edx
  800625:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800628:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 40 04             	lea    0x4(%eax),%eax
  800631:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800634:	b8 0a 00 00 00       	mov    $0xa,%eax
  800639:	e9 a6 00 00 00       	jmp    8006e4 <vprintfmt+0x436>
			putch('0', putdat);
  80063e:	83 ec 08             	sub    $0x8,%esp
  800641:	56                   	push   %esi
  800642:	6a 30                	push   $0x30
  800644:	ff d3                	call   *%ebx
	if (lflag >= 2)
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80064d:	7f 26                	jg     800675 <vprintfmt+0x3c7>
	else if (lflag)
  80064f:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800653:	74 3e                	je     800693 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  800655:	8b 45 14             	mov    0x14(%ebp),%eax
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	ba 00 00 00 00       	mov    $0x0,%edx
  80065f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800662:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8d 40 04             	lea    0x4(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80066e:	b8 08 00 00 00       	mov    $0x8,%eax
  800673:	eb 6f                	jmp    8006e4 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800675:	8b 45 14             	mov    0x14(%ebp),%eax
  800678:	8b 50 04             	mov    0x4(%eax),%edx
  80067b:	8b 00                	mov    (%eax),%eax
  80067d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800680:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 40 08             	lea    0x8(%eax),%eax
  800689:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80068c:	b8 08 00 00 00       	mov    $0x8,%eax
  800691:	eb 51                	jmp    8006e4 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8b 00                	mov    (%eax),%eax
  800698:	ba 00 00 00 00       	mov    $0x0,%edx
  80069d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 40 04             	lea    0x4(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8006b1:	eb 31                	jmp    8006e4 <vprintfmt+0x436>
			putch('0', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	56                   	push   %esi
  8006b7:	6a 30                	push   $0x30
  8006b9:	ff d3                	call   *%ebx
			putch('x', putdat);
  8006bb:	83 c4 08             	add    $0x8,%esp
  8006be:	56                   	push   %esi
  8006bf:	6a 78                	push   $0x78
  8006c1:	ff d3                	call   *%ebx
			num = (unsigned long long)
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8b 00                	mov    (%eax),%eax
  8006c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8006cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006d0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  8006d3:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8d 40 04             	lea    0x4(%eax),%eax
  8006dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006df:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006e4:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8006e8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8006eb:	89 c1                	mov    %eax,%ecx
  8006ed:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  8006f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006f3:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  8006f8:	89 c2                	mov    %eax,%edx
  8006fa:	39 c1                	cmp    %eax,%ecx
  8006fc:	0f 87 85 00 00 00    	ja     800787 <vprintfmt+0x4d9>
		tmp /= base;
  800702:	89 d0                	mov    %edx,%eax
  800704:	ba 00 00 00 00       	mov    $0x0,%edx
  800709:	f7 f1                	div    %ecx
		len++;
  80070b:	83 c7 01             	add    $0x1,%edi
  80070e:	eb e8                	jmp    8006f8 <vprintfmt+0x44a>
	if (lflag >= 2)
  800710:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800714:	7f 26                	jg     80073c <vprintfmt+0x48e>
	else if (lflag)
  800716:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80071a:	74 3e                	je     80075a <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 00                	mov    (%eax),%eax
  800721:	ba 00 00 00 00       	mov    $0x0,%edx
  800726:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800729:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 40 04             	lea    0x4(%eax),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800735:	b8 10 00 00 00       	mov    $0x10,%eax
  80073a:	eb a8                	jmp    8006e4 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  80073c:	8b 45 14             	mov    0x14(%ebp),%eax
  80073f:	8b 50 04             	mov    0x4(%eax),%edx
  800742:	8b 00                	mov    (%eax),%eax
  800744:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800747:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	8d 40 08             	lea    0x8(%eax),%eax
  800750:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800753:	b8 10 00 00 00       	mov    $0x10,%eax
  800758:	eb 8a                	jmp    8006e4 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	8b 00                	mov    (%eax),%eax
  80075f:	ba 00 00 00 00       	mov    $0x0,%edx
  800764:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800767:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8d 40 04             	lea    0x4(%eax),%eax
  800770:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800773:	b8 10 00 00 00       	mov    $0x10,%eax
  800778:	e9 67 ff ff ff       	jmp    8006e4 <vprintfmt+0x436>
			base = 10;
  80077d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800782:	e9 5d ff ff ff       	jmp    8006e4 <vprintfmt+0x436>
  800787:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  80078a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80078d:	29 f8                	sub    %edi,%eax
  80078f:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  800791:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  800795:	74 15                	je     8007ac <vprintfmt+0x4fe>
		while (width > 0) {
  800797:	85 ff                	test   %edi,%edi
  800799:	7e 48                	jle    8007e3 <vprintfmt+0x535>
			putch(padc, putdat);
  80079b:	83 ec 08             	sub    $0x8,%esp
  80079e:	56                   	push   %esi
  80079f:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a2:	ff d3                	call   *%ebx
			width--;
  8007a4:	83 ef 01             	sub    $0x1,%edi
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	eb eb                	jmp    800797 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  8007ac:	83 ec 0c             	sub    $0xc,%esp
  8007af:	6a 2d                	push   $0x2d
  8007b1:	ff 75 cc             	pushl  -0x34(%ebp)
  8007b4:	ff 75 c8             	pushl  -0x38(%ebp)
  8007b7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007ba:	ff 75 d0             	pushl  -0x30(%ebp)
  8007bd:	89 f2                	mov    %esi,%edx
  8007bf:	89 d8                	mov    %ebx,%eax
  8007c1:	e8 1e fa ff ff       	call   8001e4 <printnum_helper>
		width -= len;
  8007c6:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8007c9:	2b 7d cc             	sub    -0x34(%ebp),%edi
  8007cc:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  8007cf:	85 ff                	test   %edi,%edi
  8007d1:	7e 2e                	jle    800801 <vprintfmt+0x553>
			putch(padc, putdat);
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	56                   	push   %esi
  8007d7:	6a 20                	push   $0x20
  8007d9:	ff d3                	call   *%ebx
			width--;
  8007db:	83 ef 01             	sub    $0x1,%edi
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	eb ec                	jmp    8007cf <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  8007e3:	83 ec 0c             	sub    $0xc,%esp
  8007e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8007e9:	ff 75 cc             	pushl  -0x34(%ebp)
  8007ec:	ff 75 c8             	pushl  -0x38(%ebp)
  8007ef:	ff 75 d4             	pushl  -0x2c(%ebp)
  8007f2:	ff 75 d0             	pushl  -0x30(%ebp)
  8007f5:	89 f2                	mov    %esi,%edx
  8007f7:	89 d8                	mov    %ebx,%eax
  8007f9:	e8 e6 f9 ff ff       	call   8001e4 <printnum_helper>
  8007fe:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800801:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800804:	83 c7 01             	add    $0x1,%edi
  800807:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80080b:	83 f8 25             	cmp    $0x25,%eax
  80080e:	0f 84 b1 fa ff ff    	je     8002c5 <vprintfmt+0x17>
			if (ch == '\0')
  800814:	85 c0                	test   %eax,%eax
  800816:	0f 84 a1 00 00 00    	je     8008bd <vprintfmt+0x60f>
			putch(ch, putdat);
  80081c:	83 ec 08             	sub    $0x8,%esp
  80081f:	56                   	push   %esi
  800820:	50                   	push   %eax
  800821:	ff d3                	call   *%ebx
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	eb dc                	jmp    800804 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800828:	8b 45 14             	mov    0x14(%ebp),%eax
  80082b:	83 c0 04             	add    $0x4,%eax
  80082e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800831:	8b 45 14             	mov    0x14(%ebp),%eax
  800834:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800836:	85 ff                	test   %edi,%edi
  800838:	74 15                	je     80084f <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  80083a:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800840:	7f 29                	jg     80086b <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800842:	0f b6 06             	movzbl (%esi),%eax
  800845:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800847:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80084a:	89 45 14             	mov    %eax,0x14(%ebp)
  80084d:	eb b2                	jmp    800801 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  80084f:	68 f8 12 80 00       	push   $0x8012f8
  800854:	68 61 12 80 00       	push   $0x801261
  800859:	56                   	push   %esi
  80085a:	53                   	push   %ebx
  80085b:	e8 31 fa ff ff       	call   800291 <printfmt>
  800860:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800863:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800866:	89 45 14             	mov    %eax,0x14(%ebp)
  800869:	eb 96                	jmp    800801 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  80086b:	68 30 13 80 00       	push   $0x801330
  800870:	68 61 12 80 00       	push   $0x801261
  800875:	56                   	push   %esi
  800876:	53                   	push   %ebx
  800877:	e8 15 fa ff ff       	call   800291 <printfmt>
				*res = -1;
  80087c:	c6 07 ff             	movb   $0xff,(%edi)
  80087f:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800882:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800885:	89 45 14             	mov    %eax,0x14(%ebp)
  800888:	e9 74 ff ff ff       	jmp    800801 <vprintfmt+0x553>
			putch(ch, putdat);
  80088d:	83 ec 08             	sub    $0x8,%esp
  800890:	56                   	push   %esi
  800891:	6a 25                	push   $0x25
  800893:	ff d3                	call   *%ebx
			break;
  800895:	83 c4 10             	add    $0x10,%esp
  800898:	e9 64 ff ff ff       	jmp    800801 <vprintfmt+0x553>
			putch('%', putdat);
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	56                   	push   %esi
  8008a1:	6a 25                	push   $0x25
  8008a3:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008a5:	83 c4 10             	add    $0x10,%esp
  8008a8:	89 f8                	mov    %edi,%eax
  8008aa:	eb 03                	jmp    8008af <vprintfmt+0x601>
  8008ac:	83 e8 01             	sub    $0x1,%eax
  8008af:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008b3:	75 f7                	jne    8008ac <vprintfmt+0x5fe>
  8008b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8008b8:	e9 44 ff ff ff       	jmp    800801 <vprintfmt+0x553>
}
  8008bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5f                   	pop    %edi
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	83 ec 18             	sub    $0x18,%esp
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008d4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008d8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008e2:	85 c0                	test   %eax,%eax
  8008e4:	74 26                	je     80090c <vsnprintf+0x47>
  8008e6:	85 d2                	test   %edx,%edx
  8008e8:	7e 22                	jle    80090c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ea:	ff 75 14             	pushl  0x14(%ebp)
  8008ed:	ff 75 10             	pushl  0x10(%ebp)
  8008f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008f3:	50                   	push   %eax
  8008f4:	68 74 02 80 00       	push   $0x800274
  8008f9:	e8 b0 f9 ff ff       	call   8002ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800901:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800904:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800907:	83 c4 10             	add    $0x10,%esp
}
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    
		return -E_INVAL;
  80090c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800911:	eb f7                	jmp    80090a <vsnprintf+0x45>

00800913 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800919:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80091c:	50                   	push   %eax
  80091d:	ff 75 10             	pushl  0x10(%ebp)
  800920:	ff 75 0c             	pushl  0xc(%ebp)
  800923:	ff 75 08             	pushl  0x8(%ebp)
  800926:	e8 9a ff ff ff       	call   8008c5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80092b:	c9                   	leave  
  80092c:	c3                   	ret    

0080092d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
  800938:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80093c:	74 05                	je     800943 <strlen+0x16>
		n++;
  80093e:	83 c0 01             	add    $0x1,%eax
  800941:	eb f5                	jmp    800938 <strlen+0xb>
	return n;
}
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80094b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094e:	ba 00 00 00 00       	mov    $0x0,%edx
  800953:	39 c2                	cmp    %eax,%edx
  800955:	74 0d                	je     800964 <strnlen+0x1f>
  800957:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80095b:	74 05                	je     800962 <strnlen+0x1d>
		n++;
  80095d:	83 c2 01             	add    $0x1,%edx
  800960:	eb f1                	jmp    800953 <strnlen+0xe>
  800962:	89 d0                	mov    %edx,%eax
	return n;
}
  800964:	5d                   	pop    %ebp
  800965:	c3                   	ret    

00800966 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	53                   	push   %ebx
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800970:	ba 00 00 00 00       	mov    $0x0,%edx
  800975:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800979:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80097c:	83 c2 01             	add    $0x1,%edx
  80097f:	84 c9                	test   %cl,%cl
  800981:	75 f2                	jne    800975 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800983:	5b                   	pop    %ebx
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	53                   	push   %ebx
  80098a:	83 ec 10             	sub    $0x10,%esp
  80098d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800990:	53                   	push   %ebx
  800991:	e8 97 ff ff ff       	call   80092d <strlen>
  800996:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800999:	ff 75 0c             	pushl  0xc(%ebp)
  80099c:	01 d8                	add    %ebx,%eax
  80099e:	50                   	push   %eax
  80099f:	e8 c2 ff ff ff       	call   800966 <strcpy>
	return dst;
}
  8009a4:	89 d8                	mov    %ebx,%eax
  8009a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	56                   	push   %esi
  8009af:	53                   	push   %ebx
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009b6:	89 c6                	mov    %eax,%esi
  8009b8:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009bb:	89 c2                	mov    %eax,%edx
  8009bd:	39 f2                	cmp    %esi,%edx
  8009bf:	74 11                	je     8009d2 <strncpy+0x27>
		*dst++ = *src;
  8009c1:	83 c2 01             	add    $0x1,%edx
  8009c4:	0f b6 19             	movzbl (%ecx),%ebx
  8009c7:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009ca:	80 fb 01             	cmp    $0x1,%bl
  8009cd:	83 d9 ff             	sbb    $0xffffffff,%ecx
  8009d0:	eb eb                	jmp    8009bd <strncpy+0x12>
	}
	return ret;
}
  8009d2:	5b                   	pop    %ebx
  8009d3:	5e                   	pop    %esi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	56                   	push   %esi
  8009da:	53                   	push   %ebx
  8009db:	8b 75 08             	mov    0x8(%ebp),%esi
  8009de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009e1:	8b 55 10             	mov    0x10(%ebp),%edx
  8009e4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e6:	85 d2                	test   %edx,%edx
  8009e8:	74 21                	je     800a0b <strlcpy+0x35>
  8009ea:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009ee:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8009f0:	39 c2                	cmp    %eax,%edx
  8009f2:	74 14                	je     800a08 <strlcpy+0x32>
  8009f4:	0f b6 19             	movzbl (%ecx),%ebx
  8009f7:	84 db                	test   %bl,%bl
  8009f9:	74 0b                	je     800a06 <strlcpy+0x30>
			*dst++ = *src++;
  8009fb:	83 c1 01             	add    $0x1,%ecx
  8009fe:	83 c2 01             	add    $0x1,%edx
  800a01:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a04:	eb ea                	jmp    8009f0 <strlcpy+0x1a>
  800a06:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a08:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a0b:	29 f0                	sub    %esi,%eax
}
  800a0d:	5b                   	pop    %ebx
  800a0e:	5e                   	pop    %esi
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a17:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a1a:	0f b6 01             	movzbl (%ecx),%eax
  800a1d:	84 c0                	test   %al,%al
  800a1f:	74 0c                	je     800a2d <strcmp+0x1c>
  800a21:	3a 02                	cmp    (%edx),%al
  800a23:	75 08                	jne    800a2d <strcmp+0x1c>
		p++, q++;
  800a25:	83 c1 01             	add    $0x1,%ecx
  800a28:	83 c2 01             	add    $0x1,%edx
  800a2b:	eb ed                	jmp    800a1a <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a2d:	0f b6 c0             	movzbl %al,%eax
  800a30:	0f b6 12             	movzbl (%edx),%edx
  800a33:	29 d0                	sub    %edx,%eax
}
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	53                   	push   %ebx
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a41:	89 c3                	mov    %eax,%ebx
  800a43:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a46:	eb 06                	jmp    800a4e <strncmp+0x17>
		n--, p++, q++;
  800a48:	83 c0 01             	add    $0x1,%eax
  800a4b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a4e:	39 d8                	cmp    %ebx,%eax
  800a50:	74 16                	je     800a68 <strncmp+0x31>
  800a52:	0f b6 08             	movzbl (%eax),%ecx
  800a55:	84 c9                	test   %cl,%cl
  800a57:	74 04                	je     800a5d <strncmp+0x26>
  800a59:	3a 0a                	cmp    (%edx),%cl
  800a5b:	74 eb                	je     800a48 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5d:	0f b6 00             	movzbl (%eax),%eax
  800a60:	0f b6 12             	movzbl (%edx),%edx
  800a63:	29 d0                	sub    %edx,%eax
}
  800a65:	5b                   	pop    %ebx
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    
		return 0;
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6d:	eb f6                	jmp    800a65 <strncmp+0x2e>

00800a6f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a79:	0f b6 10             	movzbl (%eax),%edx
  800a7c:	84 d2                	test   %dl,%dl
  800a7e:	74 09                	je     800a89 <strchr+0x1a>
		if (*s == c)
  800a80:	38 ca                	cmp    %cl,%dl
  800a82:	74 0a                	je     800a8e <strchr+0x1f>
	for (; *s; s++)
  800a84:	83 c0 01             	add    $0x1,%eax
  800a87:	eb f0                	jmp    800a79 <strchr+0xa>
			return (char *) s;
	return 0;
  800a89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	8b 45 08             	mov    0x8(%ebp),%eax
  800a96:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a9a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a9d:	38 ca                	cmp    %cl,%dl
  800a9f:	74 09                	je     800aaa <strfind+0x1a>
  800aa1:	84 d2                	test   %dl,%dl
  800aa3:	74 05                	je     800aaa <strfind+0x1a>
	for (; *s; s++)
  800aa5:	83 c0 01             	add    $0x1,%eax
  800aa8:	eb f0                	jmp    800a9a <strfind+0xa>
			break;
	return (char *) s;
}
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	57                   	push   %edi
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab8:	85 c9                	test   %ecx,%ecx
  800aba:	74 31                	je     800aed <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800abc:	89 f8                	mov    %edi,%eax
  800abe:	09 c8                	or     %ecx,%eax
  800ac0:	a8 03                	test   $0x3,%al
  800ac2:	75 23                	jne    800ae7 <memset+0x3b>
		c &= 0xFF;
  800ac4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac8:	89 d3                	mov    %edx,%ebx
  800aca:	c1 e3 08             	shl    $0x8,%ebx
  800acd:	89 d0                	mov    %edx,%eax
  800acf:	c1 e0 18             	shl    $0x18,%eax
  800ad2:	89 d6                	mov    %edx,%esi
  800ad4:	c1 e6 10             	shl    $0x10,%esi
  800ad7:	09 f0                	or     %esi,%eax
  800ad9:	09 c2                	or     %eax,%edx
  800adb:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800add:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ae0:	89 d0                	mov    %edx,%eax
  800ae2:	fc                   	cld    
  800ae3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae5:	eb 06                	jmp    800aed <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aea:	fc                   	cld    
  800aeb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aed:	89 f8                	mov    %edi,%eax
  800aef:	5b                   	pop    %ebx
  800af0:	5e                   	pop    %esi
  800af1:	5f                   	pop    %edi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b02:	39 c6                	cmp    %eax,%esi
  800b04:	73 32                	jae    800b38 <memmove+0x44>
  800b06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b09:	39 c2                	cmp    %eax,%edx
  800b0b:	76 2b                	jbe    800b38 <memmove+0x44>
		s += n;
		d += n;
  800b0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b10:	89 fe                	mov    %edi,%esi
  800b12:	09 ce                	or     %ecx,%esi
  800b14:	09 d6                	or     %edx,%esi
  800b16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b1c:	75 0e                	jne    800b2c <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b1e:	83 ef 04             	sub    $0x4,%edi
  800b21:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b24:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b27:	fd                   	std    
  800b28:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2a:	eb 09                	jmp    800b35 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b2c:	83 ef 01             	sub    $0x1,%edi
  800b2f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b32:	fd                   	std    
  800b33:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b35:	fc                   	cld    
  800b36:	eb 1a                	jmp    800b52 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b38:	89 c2                	mov    %eax,%edx
  800b3a:	09 ca                	or     %ecx,%edx
  800b3c:	09 f2                	or     %esi,%edx
  800b3e:	f6 c2 03             	test   $0x3,%dl
  800b41:	75 0a                	jne    800b4d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b43:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b46:	89 c7                	mov    %eax,%edi
  800b48:	fc                   	cld    
  800b49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4b:	eb 05                	jmp    800b52 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b4d:	89 c7                	mov    %eax,%edi
  800b4f:	fc                   	cld    
  800b50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b52:	5e                   	pop    %esi
  800b53:	5f                   	pop    %edi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b5c:	ff 75 10             	pushl  0x10(%ebp)
  800b5f:	ff 75 0c             	pushl  0xc(%ebp)
  800b62:	ff 75 08             	pushl  0x8(%ebp)
  800b65:	e8 8a ff ff ff       	call   800af4 <memmove>
}
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b77:	89 c6                	mov    %eax,%esi
  800b79:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7c:	39 f0                	cmp    %esi,%eax
  800b7e:	74 1c                	je     800b9c <memcmp+0x30>
		if (*s1 != *s2)
  800b80:	0f b6 08             	movzbl (%eax),%ecx
  800b83:	0f b6 1a             	movzbl (%edx),%ebx
  800b86:	38 d9                	cmp    %bl,%cl
  800b88:	75 08                	jne    800b92 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b8a:	83 c0 01             	add    $0x1,%eax
  800b8d:	83 c2 01             	add    $0x1,%edx
  800b90:	eb ea                	jmp    800b7c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800b92:	0f b6 c1             	movzbl %cl,%eax
  800b95:	0f b6 db             	movzbl %bl,%ebx
  800b98:	29 d8                	sub    %ebx,%eax
  800b9a:	eb 05                	jmp    800ba1 <memcmp+0x35>
	}

	return 0;
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ba1:	5b                   	pop    %ebx
  800ba2:	5e                   	pop    %esi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bae:	89 c2                	mov    %eax,%edx
  800bb0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb3:	39 d0                	cmp    %edx,%eax
  800bb5:	73 09                	jae    800bc0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb7:	38 08                	cmp    %cl,(%eax)
  800bb9:	74 05                	je     800bc0 <memfind+0x1b>
	for (; s < ends; s++)
  800bbb:	83 c0 01             	add    $0x1,%eax
  800bbe:	eb f3                	jmp    800bb3 <memfind+0xe>
			break;
	return (void *) s;
}
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bce:	eb 03                	jmp    800bd3 <strtol+0x11>
		s++;
  800bd0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800bd3:	0f b6 01             	movzbl (%ecx),%eax
  800bd6:	3c 20                	cmp    $0x20,%al
  800bd8:	74 f6                	je     800bd0 <strtol+0xe>
  800bda:	3c 09                	cmp    $0x9,%al
  800bdc:	74 f2                	je     800bd0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bde:	3c 2b                	cmp    $0x2b,%al
  800be0:	74 2a                	je     800c0c <strtol+0x4a>
	int neg = 0;
  800be2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800be7:	3c 2d                	cmp    $0x2d,%al
  800be9:	74 2b                	je     800c16 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800beb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bf1:	75 0f                	jne    800c02 <strtol+0x40>
  800bf3:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf6:	74 28                	je     800c20 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bf8:	85 db                	test   %ebx,%ebx
  800bfa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bff:	0f 44 d8             	cmove  %eax,%ebx
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
  800c07:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c0a:	eb 50                	jmp    800c5c <strtol+0x9a>
		s++;
  800c0c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c0f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c14:	eb d5                	jmp    800beb <strtol+0x29>
		s++, neg = 1;
  800c16:	83 c1 01             	add    $0x1,%ecx
  800c19:	bf 01 00 00 00       	mov    $0x1,%edi
  800c1e:	eb cb                	jmp    800beb <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c20:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c24:	74 0e                	je     800c34 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c26:	85 db                	test   %ebx,%ebx
  800c28:	75 d8                	jne    800c02 <strtol+0x40>
		s++, base = 8;
  800c2a:	83 c1 01             	add    $0x1,%ecx
  800c2d:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c32:	eb ce                	jmp    800c02 <strtol+0x40>
		s += 2, base = 16;
  800c34:	83 c1 02             	add    $0x2,%ecx
  800c37:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c3c:	eb c4                	jmp    800c02 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c3e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c41:	89 f3                	mov    %esi,%ebx
  800c43:	80 fb 19             	cmp    $0x19,%bl
  800c46:	77 29                	ja     800c71 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c48:	0f be d2             	movsbl %dl,%edx
  800c4b:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c4e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c51:	7d 30                	jge    800c83 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c53:	83 c1 01             	add    $0x1,%ecx
  800c56:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c5a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c5c:	0f b6 11             	movzbl (%ecx),%edx
  800c5f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c62:	89 f3                	mov    %esi,%ebx
  800c64:	80 fb 09             	cmp    $0x9,%bl
  800c67:	77 d5                	ja     800c3e <strtol+0x7c>
			dig = *s - '0';
  800c69:	0f be d2             	movsbl %dl,%edx
  800c6c:	83 ea 30             	sub    $0x30,%edx
  800c6f:	eb dd                	jmp    800c4e <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800c71:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c74:	89 f3                	mov    %esi,%ebx
  800c76:	80 fb 19             	cmp    $0x19,%bl
  800c79:	77 08                	ja     800c83 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c7b:	0f be d2             	movsbl %dl,%edx
  800c7e:	83 ea 37             	sub    $0x37,%edx
  800c81:	eb cb                	jmp    800c4e <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c83:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c87:	74 05                	je     800c8e <strtol+0xcc>
		*endptr = (char *) s;
  800c89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c8c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c8e:	89 c2                	mov    %eax,%edx
  800c90:	f7 da                	neg    %edx
  800c92:	85 ff                	test   %edi,%edi
  800c94:	0f 45 c2             	cmovne %edx,%eax
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca7:	8b 55 08             	mov    0x8(%ebp),%edx
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	89 c3                	mov    %eax,%ebx
  800caf:	89 c7                	mov    %eax,%edi
  800cb1:	89 c6                	mov    %eax,%esi
  800cb3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_cgetc>:

int
sys_cgetc(void)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cca:	89 d1                	mov    %edx,%ecx
  800ccc:	89 d3                	mov    %edx,%ebx
  800cce:	89 d7                	mov    %edx,%edi
  800cd0:	89 d6                	mov    %edx,%esi
  800cd2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
  800cdf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	b8 03 00 00 00       	mov    $0x3,%eax
  800cef:	89 cb                	mov    %ecx,%ebx
  800cf1:	89 cf                	mov    %ecx,%edi
  800cf3:	89 ce                	mov    %ecx,%esi
  800cf5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf7:	85 c0                	test   %eax,%eax
  800cf9:	7f 08                	jg     800d03 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d03:	83 ec 0c             	sub    $0xc,%esp
  800d06:	50                   	push   %eax
  800d07:	6a 03                	push   $0x3
  800d09:	68 04 15 80 00       	push   $0x801504
  800d0e:	6a 23                	push   $0x23
  800d10:	68 21 15 80 00       	push   $0x801521
  800d15:	e8 5c 02 00 00       	call   800f76 <_panic>

00800d1a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	57                   	push   %edi
  800d1e:	56                   	push   %esi
  800d1f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d20:	ba 00 00 00 00       	mov    $0x0,%edx
  800d25:	b8 02 00 00 00       	mov    $0x2,%eax
  800d2a:	89 d1                	mov    %edx,%ecx
  800d2c:	89 d3                	mov    %edx,%ebx
  800d2e:	89 d7                	mov    %edx,%edi
  800d30:	89 d6                	mov    %edx,%esi
  800d32:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_yield>:

void
sys_yield(void)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d44:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d49:	89 d1                	mov    %edx,%ecx
  800d4b:	89 d3                	mov    %edx,%ebx
  800d4d:	89 d7                	mov    %edx,%edi
  800d4f:	89 d6                	mov    %edx,%esi
  800d51:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	57                   	push   %edi
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
  800d5e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d61:	be 00 00 00 00       	mov    $0x0,%esi
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6c:	b8 04 00 00 00       	mov    $0x4,%eax
  800d71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d74:	89 f7                	mov    %esi,%edi
  800d76:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7f 08                	jg     800d84 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800d88:	6a 04                	push   $0x4
  800d8a:	68 04 15 80 00       	push   $0x801504
  800d8f:	6a 23                	push   $0x23
  800d91:	68 21 15 80 00       	push   $0x801521
  800d96:	e8 db 01 00 00       	call   800f76 <_panic>

00800d9b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daa:	b8 05 00 00 00       	mov    $0x5,%eax
  800daf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db5:	8b 75 18             	mov    0x18(%ebp),%esi
  800db8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7f 08                	jg     800dc6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800dca:	6a 05                	push   $0x5
  800dcc:	68 04 15 80 00       	push   $0x801504
  800dd1:	6a 23                	push   $0x23
  800dd3:	68 21 15 80 00       	push   $0x801521
  800dd8:	e8 99 01 00 00       	call   800f76 <_panic>

00800ddd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800df1:	b8 06 00 00 00       	mov    $0x6,%eax
  800df6:	89 df                	mov    %ebx,%edi
  800df8:	89 de                	mov    %ebx,%esi
  800dfa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7f 08                	jg     800e08 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800e0c:	6a 06                	push   $0x6
  800e0e:	68 04 15 80 00       	push   $0x801504
  800e13:	6a 23                	push   $0x23
  800e15:	68 21 15 80 00       	push   $0x801521
  800e1a:	e8 57 01 00 00       	call   800f76 <_panic>

00800e1f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800e33:	b8 08 00 00 00       	mov    $0x8,%eax
  800e38:	89 df                	mov    %ebx,%edi
  800e3a:	89 de                	mov    %ebx,%esi
  800e3c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	7f 08                	jg     800e4a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  800e4e:	6a 08                	push   $0x8
  800e50:	68 04 15 80 00       	push   $0x801504
  800e55:	6a 23                	push   $0x23
  800e57:	68 21 15 80 00       	push   $0x801521
  800e5c:	e8 15 01 00 00       	call   800f76 <_panic>

00800e61 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e75:	b8 09 00 00 00       	mov    $0x9,%eax
  800e7a:	89 df                	mov    %ebx,%edi
  800e7c:	89 de                	mov    %ebx,%esi
  800e7e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7f 08                	jg     800e8c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e87:	5b                   	pop    %ebx
  800e88:	5e                   	pop    %esi
  800e89:	5f                   	pop    %edi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8c:	83 ec 0c             	sub    $0xc,%esp
  800e8f:	50                   	push   %eax
  800e90:	6a 09                	push   $0x9
  800e92:	68 04 15 80 00       	push   $0x801504
  800e97:	6a 23                	push   $0x23
  800e99:	68 21 15 80 00       	push   $0x801521
  800e9e:	e8 d3 00 00 00       	call   800f76 <_panic>

00800ea3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ea9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eaf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800eb4:	be 00 00 00 00       	mov    $0x0,%esi
  800eb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ebf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800edc:	89 cb                	mov    %ecx,%ebx
  800ede:	89 cf                	mov    %ecx,%edi
  800ee0:	89 ce                	mov    %ecx,%esi
  800ee2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7f 08                	jg     800ef0 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	5f                   	pop    %edi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef0:	83 ec 0c             	sub    $0xc,%esp
  800ef3:	50                   	push   %eax
  800ef4:	6a 0c                	push   $0xc
  800ef6:	68 04 15 80 00       	push   $0x801504
  800efb:	6a 23                	push   $0x23
  800efd:	68 21 15 80 00       	push   $0x801521
  800f02:	e8 6f 00 00 00       	call   800f76 <_panic>

00800f07 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f0d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f12:	8b 55 08             	mov    0x8(%ebp),%edx
  800f15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f18:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f1d:	89 df                	mov    %ebx,%edi
  800f1f:	89 de                	mov    %ebx,%esi
  800f21:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	57                   	push   %edi
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f33:	8b 55 08             	mov    0x8(%ebp),%edx
  800f36:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f3b:	89 cb                	mov    %ecx,%ebx
  800f3d:	89 cf                	mov    %ecx,%edi
  800f3f:	89 ce                	mov    %ecx,%esi
  800f41:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800f4e:	68 3b 15 80 00       	push   $0x80153b
  800f53:	6a 53                	push   $0x53
  800f55:	68 2f 15 80 00       	push   $0x80152f
  800f5a:	e8 17 00 00 00       	call   800f76 <_panic>

00800f5f <sfork>:
}

// Challenge!
int
sfork(void)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
  800f62:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800f65:	68 3a 15 80 00       	push   $0x80153a
  800f6a:	6a 5a                	push   $0x5a
  800f6c:	68 2f 15 80 00       	push   $0x80152f
  800f71:	e8 00 00 00 00       	call   800f76 <_panic>

00800f76 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	56                   	push   %esi
  800f7a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800f7b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f7e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800f84:	e8 91 fd ff ff       	call   800d1a <sys_getenvid>
  800f89:	83 ec 0c             	sub    $0xc,%esp
  800f8c:	ff 75 0c             	pushl  0xc(%ebp)
  800f8f:	ff 75 08             	pushl  0x8(%ebp)
  800f92:	56                   	push   %esi
  800f93:	50                   	push   %eax
  800f94:	68 50 15 80 00       	push   $0x801550
  800f99:	e8 32 f2 ff ff       	call   8001d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800f9e:	83 c4 18             	add    $0x18,%esp
  800fa1:	53                   	push   %ebx
  800fa2:	ff 75 10             	pushl  0x10(%ebp)
  800fa5:	e8 d5 f1 ff ff       	call   80017f <vcprintf>
	cprintf("\n");
  800faa:	c7 04 24 2f 12 80 00 	movl   $0x80122f,(%esp)
  800fb1:	e8 1a f2 ff ff       	call   8001d0 <cprintf>
  800fb6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fb9:	cc                   	int3   
  800fba:	eb fd                	jmp    800fb9 <_panic+0x43>
  800fbc:	66 90                	xchg   %ax,%ax
  800fbe:	66 90                	xchg   %ax,%ax

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
