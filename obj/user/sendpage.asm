
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 73 01 00 00       	call   8001a4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 cb 0f 00 00       	call   801009 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 84 a5 00 00 00    	je     8000ee <umain+0xbb>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
		return;
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800049:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80004e:	8b 40 48             	mov    0x48(%eax),%eax
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 07                	push   $0x7
  800056:	68 00 00 a0 00       	push   $0xa00000
  80005b:	50                   	push   %eax
  80005c:	e8 b8 0d 00 00       	call   800e19 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800061:	83 c4 04             	add    $0x4,%esp
  800064:	ff 35 04 20 80 00    	pushl  0x802004
  80006a:	e8 7f 09 00 00       	call   8009ee <strlen>
  80006f:	83 c4 0c             	add    $0xc,%esp
  800072:	83 c0 01             	add    $0x1,%eax
  800075:	50                   	push   %eax
  800076:	ff 35 04 20 80 00    	pushl  0x802004
  80007c:	68 00 00 a0 00       	push   $0xa00000
  800081:	e8 91 0b 00 00       	call   800c17 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800086:	6a 07                	push   $0x7
  800088:	68 00 00 a0 00       	push   $0xa00000
  80008d:	6a 00                	push   $0x0
  80008f:	ff 75 f4             	pushl  -0xc(%ebp)
  800092:	e8 b7 0f 00 00       	call   80104e <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800097:	83 c4 1c             	add    $0x1c,%esp
  80009a:	6a 00                	push   $0x0
  80009c:	68 00 00 a0 00       	push   $0xa00000
  8000a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a4:	50                   	push   %eax
  8000a5:	e8 8d 0f 00 00       	call   801037 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  8000aa:	83 c4 0c             	add    $0xc,%esp
  8000ad:	68 00 00 a0 00       	push   $0xa00000
  8000b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8000b5:	68 40 13 80 00       	push   $0x801340
  8000ba:	e8 d2 01 00 00       	call   800291 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8000bf:	83 c4 04             	add    $0x4,%esp
  8000c2:	ff 35 00 20 80 00    	pushl  0x802000
  8000c8:	e8 21 09 00 00       	call   8009ee <strlen>
  8000cd:	83 c4 0c             	add    $0xc,%esp
  8000d0:	50                   	push   %eax
  8000d1:	ff 35 00 20 80 00    	pushl  0x802000
  8000d7:	68 00 00 a0 00       	push   $0xa00000
  8000dc:	e8 17 0a 00 00       	call   800af8 <strncmp>
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	85 c0                	test   %eax,%eax
  8000e6:	0f 84 a3 00 00 00    	je     80018f <umain+0x15c>
		cprintf("parent received correct message\n");
	return;
}
  8000ec:	c9                   	leave  
  8000ed:	c3                   	ret    
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  8000ee:	83 ec 04             	sub    $0x4,%esp
  8000f1:	6a 00                	push   $0x0
  8000f3:	68 00 00 b0 00       	push   $0xb00000
  8000f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000fb:	50                   	push   %eax
  8000fc:	e8 36 0f 00 00       	call   801037 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800101:	83 c4 0c             	add    $0xc,%esp
  800104:	68 00 00 b0 00       	push   $0xb00000
  800109:	ff 75 f4             	pushl  -0xc(%ebp)
  80010c:	68 40 13 80 00       	push   $0x801340
  800111:	e8 7b 01 00 00       	call   800291 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800116:	83 c4 04             	add    $0x4,%esp
  800119:	ff 35 04 20 80 00    	pushl  0x802004
  80011f:	e8 ca 08 00 00       	call   8009ee <strlen>
  800124:	83 c4 0c             	add    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	ff 35 04 20 80 00    	pushl  0x802004
  80012e:	68 00 00 b0 00       	push   $0xb00000
  800133:	e8 c0 09 00 00       	call   800af8 <strncmp>
  800138:	83 c4 10             	add    $0x10,%esp
  80013b:	85 c0                	test   %eax,%eax
  80013d:	74 3e                	je     80017d <umain+0x14a>
		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80013f:	83 ec 0c             	sub    $0xc,%esp
  800142:	ff 35 00 20 80 00    	pushl  0x802000
  800148:	e8 a1 08 00 00       	call   8009ee <strlen>
  80014d:	83 c4 0c             	add    $0xc,%esp
  800150:	83 c0 01             	add    $0x1,%eax
  800153:	50                   	push   %eax
  800154:	ff 35 00 20 80 00    	pushl  0x802000
  80015a:	68 00 00 b0 00       	push   $0xb00000
  80015f:	e8 b3 0a 00 00       	call   800c17 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  800164:	6a 07                	push   $0x7
  800166:	68 00 00 b0 00       	push   $0xb00000
  80016b:	6a 00                	push   $0x0
  80016d:	ff 75 f4             	pushl  -0xc(%ebp)
  800170:	e8 d9 0e 00 00       	call   80104e <ipc_send>
		return;
  800175:	83 c4 20             	add    $0x20,%esp
  800178:	e9 6f ff ff ff       	jmp    8000ec <umain+0xb9>
			cprintf("child received correct message\n");
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	68 54 13 80 00       	push   $0x801354
  800185:	e8 07 01 00 00       	call   800291 <cprintf>
  80018a:	83 c4 10             	add    $0x10,%esp
  80018d:	eb b0                	jmp    80013f <umain+0x10c>
		cprintf("parent received correct message\n");
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	68 74 13 80 00       	push   $0x801374
  800197:	e8 f5 00 00 00       	call   800291 <cprintf>
  80019c:	83 c4 10             	add    $0x10,%esp
  80019f:	e9 48 ff ff ff       	jmp    8000ec <umain+0xb9>

008001a4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ac:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001af:	e8 27 0c 00 00       	call   800ddb <sys_getenvid>
  8001b4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001b9:	c1 e0 07             	shl    $0x7,%eax
  8001bc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001c1:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001c6:	85 db                	test   %ebx,%ebx
  8001c8:	7e 07                	jle    8001d1 <libmain+0x2d>
		binaryname = argv[0];
  8001ca:	8b 06                	mov    (%esi),%eax
  8001cc:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  8001d1:	83 ec 08             	sub    $0x8,%esp
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	e8 58 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001db:	e8 0a 00 00 00       	call   8001ea <exit>
}
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5d                   	pop    %ebp
  8001e9:	c3                   	ret    

008001ea <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8001f0:	6a 00                	push   $0x0
  8001f2:	e8 a3 0b 00 00       	call   800d9a <sys_env_destroy>
}
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	53                   	push   %ebx
  800200:	83 ec 04             	sub    $0x4,%esp
  800203:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800206:	8b 13                	mov    (%ebx),%edx
  800208:	8d 42 01             	lea    0x1(%edx),%eax
  80020b:	89 03                	mov    %eax,(%ebx)
  80020d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800210:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800214:	3d ff 00 00 00       	cmp    $0xff,%eax
  800219:	74 09                	je     800224 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80021b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80021f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800222:	c9                   	leave  
  800223:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	68 ff 00 00 00       	push   $0xff
  80022c:	8d 43 08             	lea    0x8(%ebx),%eax
  80022f:	50                   	push   %eax
  800230:	e8 28 0b 00 00       	call   800d5d <sys_cputs>
		b->idx = 0;
  800235:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	eb db                	jmp    80021b <putch+0x1f>

00800240 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800249:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800250:	00 00 00 
	b.cnt = 0;
  800253:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80025a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80025d:	ff 75 0c             	pushl  0xc(%ebp)
  800260:	ff 75 08             	pushl  0x8(%ebp)
  800263:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800269:	50                   	push   %eax
  80026a:	68 fc 01 80 00       	push   $0x8001fc
  80026f:	e8 fb 00 00 00       	call   80036f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800274:	83 c4 08             	add    $0x8,%esp
  800277:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80027d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800283:	50                   	push   %eax
  800284:	e8 d4 0a 00 00       	call   800d5d <sys_cputs>

	return b.cnt;
}
  800289:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800297:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80029a:	50                   	push   %eax
  80029b:	ff 75 08             	pushl  0x8(%ebp)
  80029e:	e8 9d ff ff ff       	call   800240 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 1c             	sub    $0x1c,%esp
  8002ae:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002b1:	89 d3                	mov    %edx,%ebx
  8002b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8002b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  8002bf:	89 c2                	mov    %eax,%edx
  8002c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8002cc:	39 c6                	cmp    %eax,%esi
  8002ce:	89 f8                	mov    %edi,%eax
  8002d0:	19 c8                	sbb    %ecx,%eax
  8002d2:	73 32                	jae    800306 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  8002d4:	83 ec 08             	sub    $0x8,%esp
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 04             	sub    $0x4,%esp
  8002db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002de:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	e8 18 0f 00 00       	call   801200 <__umoddi3>
  8002e8:	83 c4 14             	add    $0x14,%esp
  8002eb:	0f be 80 ec 13 80 00 	movsbl 0x8013ec(%eax),%eax
  8002f2:	50                   	push   %eax
  8002f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f6:	ff d0                	call   *%eax
	return remain - 1;
  8002f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fb:	83 e8 01             	sub    $0x1,%eax
}
  8002fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  800306:	83 ec 0c             	sub    $0xc,%esp
  800309:	ff 75 18             	pushl  0x18(%ebp)
  80030c:	ff 75 14             	pushl  0x14(%ebp)
  80030f:	ff 75 d8             	pushl  -0x28(%ebp)
  800312:	83 ec 08             	sub    $0x8,%esp
  800315:	51                   	push   %ecx
  800316:	52                   	push   %edx
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	e8 d2 0d 00 00       	call   8010f0 <__udivdi3>
  80031e:	83 c4 18             	add    $0x18,%esp
  800321:	52                   	push   %edx
  800322:	50                   	push   %eax
  800323:	89 da                	mov    %ebx,%edx
  800325:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800328:	e8 78 ff ff ff       	call   8002a5 <printnum_helper>
  80032d:	89 45 14             	mov    %eax,0x14(%ebp)
  800330:	83 c4 20             	add    $0x20,%esp
  800333:	eb 9f                	jmp    8002d4 <printnum_helper+0x2f>

00800335 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	3b 50 04             	cmp    0x4(%eax),%edx
  800344:	73 0a                	jae    800350 <sprintputch+0x1b>
		*b->buf++ = ch;
  800346:	8d 4a 01             	lea    0x1(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 45 08             	mov    0x8(%ebp),%eax
  80034e:	88 02                	mov    %al,(%edx)
}
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <printfmt>:
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800358:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035b:	50                   	push   %eax
  80035c:	ff 75 10             	pushl  0x10(%ebp)
  80035f:	ff 75 0c             	pushl  0xc(%ebp)
  800362:	ff 75 08             	pushl  0x8(%ebp)
  800365:	e8 05 00 00 00       	call   80036f <vprintfmt>
}
  80036a:	83 c4 10             	add    $0x10,%esp
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    

0080036f <vprintfmt>:
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	57                   	push   %edi
  800373:	56                   	push   %esi
  800374:	53                   	push   %ebx
  800375:	83 ec 3c             	sub    $0x3c,%esp
  800378:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80037b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80037e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800381:	e9 3f 05 00 00       	jmp    8008c5 <vprintfmt+0x556>
		padc = ' ';
  800386:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  80038a:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800391:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800398:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  80039f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  8003a6:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  8003ad:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8d 47 01             	lea    0x1(%edi),%eax
  8003b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003b8:	0f b6 17             	movzbl (%edi),%edx
  8003bb:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003be:	3c 55                	cmp    $0x55,%al
  8003c0:	0f 87 98 05 00 00    	ja     80095e <vprintfmt+0x5ef>
  8003c6:	0f b6 c0             	movzbl %al,%eax
  8003c9:	ff 24 85 20 15 80 00 	jmp    *0x801520(,%eax,4)
  8003d0:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  8003d3:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  8003d7:	eb d9                	jmp    8003b2 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  8003dc:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  8003e3:	eb cd                	jmp    8003b2 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	0f b6 d2             	movzbl %dl,%edx
  8003e8:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f0:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  8003f3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003fa:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003fd:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800400:	83 fb 09             	cmp    $0x9,%ebx
  800403:	77 5c                	ja     800461 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  800405:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800408:	eb e9                	jmp    8003f3 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  80040d:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  800411:	eb 9f                	jmp    8003b2 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8b 00                	mov    (%eax),%eax
  800418:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8d 40 04             	lea    0x4(%eax),%eax
  800421:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  800427:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80042b:	79 85                	jns    8003b2 <vprintfmt+0x43>
				width = precision, precision = -1;
  80042d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800430:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800433:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80043a:	e9 73 ff ff ff       	jmp    8003b2 <vprintfmt+0x43>
  80043f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800442:	85 c0                	test   %eax,%eax
  800444:	0f 48 c1             	cmovs  %ecx,%eax
  800447:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80044d:	e9 60 ff ff ff       	jmp    8003b2 <vprintfmt+0x43>
  800452:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  800455:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  80045c:	e9 51 ff ff ff       	jmp    8003b2 <vprintfmt+0x43>
  800461:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800464:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800467:	eb be                	jmp    800427 <vprintfmt+0xb8>
			lflag++;
  800469:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  800470:	e9 3d ff ff ff       	jmp    8003b2 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 78 04             	lea    0x4(%eax),%edi
  80047b:	83 ec 08             	sub    $0x8,%esp
  80047e:	56                   	push   %esi
  80047f:	ff 30                	pushl  (%eax)
  800481:	ff d3                	call   *%ebx
			break;
  800483:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800486:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800489:	e9 34 04 00 00       	jmp    8008c2 <vprintfmt+0x553>
			err = va_arg(ap, int);
  80048e:	8b 45 14             	mov    0x14(%ebp),%eax
  800491:	8d 78 04             	lea    0x4(%eax),%edi
  800494:	8b 00                	mov    (%eax),%eax
  800496:	99                   	cltd   
  800497:	31 d0                	xor    %edx,%eax
  800499:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049b:	83 f8 08             	cmp    $0x8,%eax
  80049e:	7f 23                	jg     8004c3 <vprintfmt+0x154>
  8004a0:	8b 14 85 80 16 80 00 	mov    0x801680(,%eax,4),%edx
  8004a7:	85 d2                	test   %edx,%edx
  8004a9:	74 18                	je     8004c3 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  8004ab:	52                   	push   %edx
  8004ac:	68 0d 14 80 00       	push   $0x80140d
  8004b1:	56                   	push   %esi
  8004b2:	53                   	push   %ebx
  8004b3:	e8 9a fe ff ff       	call   800352 <printfmt>
  8004b8:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004bb:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004be:	e9 ff 03 00 00       	jmp    8008c2 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  8004c3:	50                   	push   %eax
  8004c4:	68 04 14 80 00       	push   $0x801404
  8004c9:	56                   	push   %esi
  8004ca:	53                   	push   %ebx
  8004cb:	e8 82 fe ff ff       	call   800352 <printfmt>
  8004d0:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004d3:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004d6:	e9 e7 03 00 00       	jmp    8008c2 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  8004db:	8b 45 14             	mov    0x14(%ebp),%eax
  8004de:	83 c0 04             	add    $0x4,%eax
  8004e1:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8004e9:	85 c9                	test   %ecx,%ecx
  8004eb:	b8 fd 13 80 00       	mov    $0x8013fd,%eax
  8004f0:	0f 45 c1             	cmovne %ecx,%eax
  8004f3:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  8004f6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fa:	7e 06                	jle    800502 <vprintfmt+0x193>
  8004fc:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800500:	75 0d                	jne    80050f <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800502:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800505:	89 c7                	mov    %eax,%edi
  800507:	03 45 d8             	add    -0x28(%ebp),%eax
  80050a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050d:	eb 53                	jmp    800562 <vprintfmt+0x1f3>
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	ff 75 e0             	pushl  -0x20(%ebp)
  800515:	50                   	push   %eax
  800516:	e8 eb 04 00 00       	call   800a06 <strnlen>
  80051b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80051e:	29 c1                	sub    %eax,%ecx
  800520:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800528:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  80052c:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	eb 0f                	jmp    800540 <vprintfmt+0x1d1>
					putch(padc, putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	56                   	push   %esi
  800535:	ff 75 d8             	pushl  -0x28(%ebp)
  800538:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80053a:	83 ef 01             	sub    $0x1,%edi
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	85 ff                	test   %edi,%edi
  800542:	7f ed                	jg     800531 <vprintfmt+0x1c2>
  800544:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  800547:	85 c9                	test   %ecx,%ecx
  800549:	b8 00 00 00 00       	mov    $0x0,%eax
  80054e:	0f 49 c1             	cmovns %ecx,%eax
  800551:	29 c1                	sub    %eax,%ecx
  800553:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800556:	eb aa                	jmp    800502 <vprintfmt+0x193>
					putch(ch, putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	56                   	push   %esi
  80055c:	52                   	push   %edx
  80055d:	ff d3                	call   *%ebx
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800565:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800567:	83 c7 01             	add    $0x1,%edi
  80056a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056e:	0f be d0             	movsbl %al,%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	74 2e                	je     8005a3 <vprintfmt+0x234>
  800575:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800579:	78 06                	js     800581 <vprintfmt+0x212>
  80057b:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80057f:	78 1e                	js     80059f <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800581:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800585:	74 d1                	je     800558 <vprintfmt+0x1e9>
  800587:	0f be c0             	movsbl %al,%eax
  80058a:	83 e8 20             	sub    $0x20,%eax
  80058d:	83 f8 5e             	cmp    $0x5e,%eax
  800590:	76 c6                	jbe    800558 <vprintfmt+0x1e9>
					putch('?', putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	56                   	push   %esi
  800596:	6a 3f                	push   $0x3f
  800598:	ff d3                	call   *%ebx
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	eb c3                	jmp    800562 <vprintfmt+0x1f3>
  80059f:	89 cf                	mov    %ecx,%edi
  8005a1:	eb 02                	jmp    8005a5 <vprintfmt+0x236>
  8005a3:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  8005a5:	85 ff                	test   %edi,%edi
  8005a7:	7e 10                	jle    8005b9 <vprintfmt+0x24a>
				putch(' ', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	56                   	push   %esi
  8005ad:	6a 20                	push   $0x20
  8005af:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8005b1:	83 ef 01             	sub    $0x1,%edi
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	eb ec                	jmp    8005a5 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  8005b9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bf:	e9 fe 02 00 00       	jmp    8008c2 <vprintfmt+0x553>
	if (lflag >= 2)
  8005c4:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8005c8:	7f 21                	jg     8005eb <vprintfmt+0x27c>
	else if (lflag)
  8005ca:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8005ce:	74 79                	je     800649 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d8:	89 c1                	mov    %eax,%ecx
  8005da:	c1 f9 1f             	sar    $0x1f,%ecx
  8005dd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8d 40 04             	lea    0x4(%eax),%eax
  8005e6:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e9:	eb 17                	jmp    800602 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 50 04             	mov    0x4(%eax),%edx
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 40 08             	lea    0x8(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  800602:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800605:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800608:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80060b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  80060e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800612:	78 50                	js     800664 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  800614:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800617:	c1 fa 1f             	sar    $0x1f,%edx
  80061a:	89 d0                	mov    %edx,%eax
  80061c:	2b 45 e0             	sub    -0x20(%ebp),%eax
  80061f:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  800622:	85 d2                	test   %edx,%edx
  800624:	0f 89 14 02 00 00    	jns    80083e <vprintfmt+0x4cf>
  80062a:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  80062e:	0f 84 0a 02 00 00    	je     80083e <vprintfmt+0x4cf>
				putch('+', putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	56                   	push   %esi
  800638:	6a 2b                	push   $0x2b
  80063a:	ff d3                	call   *%ebx
  80063c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80063f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800644:	e9 5c 01 00 00       	jmp    8007a5 <vprintfmt+0x436>
		return va_arg(*ap, int);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 00                	mov    (%eax),%eax
  80064e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800651:	89 c1                	mov    %eax,%ecx
  800653:	c1 f9 1f             	sar    $0x1f,%ecx
  800656:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 40 04             	lea    0x4(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
  800662:	eb 9e                	jmp    800602 <vprintfmt+0x293>
				putch('-', putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	56                   	push   %esi
  800668:	6a 2d                	push   $0x2d
  80066a:	ff d3                	call   *%ebx
				num = -(long long) num;
  80066c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80066f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800672:	f7 d8                	neg    %eax
  800674:	83 d2 00             	adc    $0x0,%edx
  800677:	f7 da                	neg    %edx
  800679:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80067c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80067f:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800682:	b8 0a 00 00 00       	mov    $0xa,%eax
  800687:	e9 19 01 00 00       	jmp    8007a5 <vprintfmt+0x436>
	if (lflag >= 2)
  80068c:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800690:	7f 29                	jg     8006bb <vprintfmt+0x34c>
	else if (lflag)
  800692:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800696:	74 44                	je     8006dc <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800698:	8b 45 14             	mov    0x14(%ebp),%eax
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	ba 00 00 00 00       	mov    $0x0,%edx
  8006a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006a5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 40 04             	lea    0x4(%eax),%eax
  8006ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b6:	e9 ea 00 00 00       	jmp    8007a5 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8b 50 04             	mov    0x4(%eax),%edx
  8006c1:	8b 00                	mov    (%eax),%eax
  8006c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006c6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8d 40 08             	lea    0x8(%eax),%eax
  8006cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006d7:	e9 c9 00 00 00       	jmp    8007a5 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8006e6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ef:	8d 40 04             	lea    0x4(%eax),%eax
  8006f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fa:	e9 a6 00 00 00       	jmp    8007a5 <vprintfmt+0x436>
			putch('0', putdat);
  8006ff:	83 ec 08             	sub    $0x8,%esp
  800702:	56                   	push   %esi
  800703:	6a 30                	push   $0x30
  800705:	ff d3                	call   *%ebx
	if (lflag >= 2)
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80070e:	7f 26                	jg     800736 <vprintfmt+0x3c7>
	else if (lflag)
  800710:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800714:	74 3e                	je     800754 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8b 00                	mov    (%eax),%eax
  80071b:	ba 00 00 00 00       	mov    $0x0,%edx
  800720:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800723:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 40 04             	lea    0x4(%eax),%eax
  80072c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80072f:	b8 08 00 00 00       	mov    $0x8,%eax
  800734:	eb 6f                	jmp    8007a5 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	8b 50 04             	mov    0x4(%eax),%edx
  80073c:	8b 00                	mov    (%eax),%eax
  80073e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800741:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8d 40 08             	lea    0x8(%eax),%eax
  80074a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80074d:	b8 08 00 00 00       	mov    $0x8,%eax
  800752:	eb 51                	jmp    8007a5 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8b 00                	mov    (%eax),%eax
  800759:	ba 00 00 00 00       	mov    $0x0,%edx
  80075e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800761:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8d 40 04             	lea    0x4(%eax),%eax
  80076a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80076d:	b8 08 00 00 00       	mov    $0x8,%eax
  800772:	eb 31                	jmp    8007a5 <vprintfmt+0x436>
			putch('0', putdat);
  800774:	83 ec 08             	sub    $0x8,%esp
  800777:	56                   	push   %esi
  800778:	6a 30                	push   $0x30
  80077a:	ff d3                	call   *%ebx
			putch('x', putdat);
  80077c:	83 c4 08             	add    $0x8,%esp
  80077f:	56                   	push   %esi
  800780:	6a 78                	push   $0x78
  800782:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8b 00                	mov    (%eax),%eax
  800789:	ba 00 00 00 00       	mov    $0x0,%edx
  80078e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800791:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800794:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 40 04             	lea    0x4(%eax),%eax
  80079d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a0:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007a5:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  8007a9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8007ac:	89 c1                	mov    %eax,%ecx
  8007ae:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  8007b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8007b4:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  8007b9:	89 c2                	mov    %eax,%edx
  8007bb:	39 c1                	cmp    %eax,%ecx
  8007bd:	0f 87 85 00 00 00    	ja     800848 <vprintfmt+0x4d9>
		tmp /= base;
  8007c3:	89 d0                	mov    %edx,%eax
  8007c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ca:	f7 f1                	div    %ecx
		len++;
  8007cc:	83 c7 01             	add    $0x1,%edi
  8007cf:	eb e8                	jmp    8007b9 <vprintfmt+0x44a>
	if (lflag >= 2)
  8007d1:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8007d5:	7f 26                	jg     8007fd <vprintfmt+0x48e>
	else if (lflag)
  8007d7:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8007db:	74 3e                	je     80081b <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8b 00                	mov    (%eax),%eax
  8007e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007ea:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	8d 40 04             	lea    0x4(%eax),%eax
  8007f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f6:	b8 10 00 00 00       	mov    $0x10,%eax
  8007fb:	eb a8                	jmp    8007a5 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8b 50 04             	mov    0x4(%eax),%edx
  800803:	8b 00                	mov    (%eax),%eax
  800805:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800808:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 40 08             	lea    0x8(%eax),%eax
  800811:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800814:	b8 10 00 00 00       	mov    $0x10,%eax
  800819:	eb 8a                	jmp    8007a5 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80081b:	8b 45 14             	mov    0x14(%ebp),%eax
  80081e:	8b 00                	mov    (%eax),%eax
  800820:	ba 00 00 00 00       	mov    $0x0,%edx
  800825:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800828:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80082b:	8b 45 14             	mov    0x14(%ebp),%eax
  80082e:	8d 40 04             	lea    0x4(%eax),%eax
  800831:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800834:	b8 10 00 00 00       	mov    $0x10,%eax
  800839:	e9 67 ff ff ff       	jmp    8007a5 <vprintfmt+0x436>
			base = 10;
  80083e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800843:	e9 5d ff ff ff       	jmp    8007a5 <vprintfmt+0x436>
  800848:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  80084b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80084e:	29 f8                	sub    %edi,%eax
  800850:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  800852:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  800856:	74 15                	je     80086d <vprintfmt+0x4fe>
		while (width > 0) {
  800858:	85 ff                	test   %edi,%edi
  80085a:	7e 48                	jle    8008a4 <vprintfmt+0x535>
			putch(padc, putdat);
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	56                   	push   %esi
  800860:	ff 75 e0             	pushl  -0x20(%ebp)
  800863:	ff d3                	call   *%ebx
			width--;
  800865:	83 ef 01             	sub    $0x1,%edi
  800868:	83 c4 10             	add    $0x10,%esp
  80086b:	eb eb                	jmp    800858 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  80086d:	83 ec 0c             	sub    $0xc,%esp
  800870:	6a 2d                	push   $0x2d
  800872:	ff 75 cc             	pushl  -0x34(%ebp)
  800875:	ff 75 c8             	pushl  -0x38(%ebp)
  800878:	ff 75 d4             	pushl  -0x2c(%ebp)
  80087b:	ff 75 d0             	pushl  -0x30(%ebp)
  80087e:	89 f2                	mov    %esi,%edx
  800880:	89 d8                	mov    %ebx,%eax
  800882:	e8 1e fa ff ff       	call   8002a5 <printnum_helper>
		width -= len;
  800887:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80088a:	2b 7d cc             	sub    -0x34(%ebp),%edi
  80088d:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800890:	85 ff                	test   %edi,%edi
  800892:	7e 2e                	jle    8008c2 <vprintfmt+0x553>
			putch(padc, putdat);
  800894:	83 ec 08             	sub    $0x8,%esp
  800897:	56                   	push   %esi
  800898:	6a 20                	push   $0x20
  80089a:	ff d3                	call   *%ebx
			width--;
  80089c:	83 ef 01             	sub    $0x1,%edi
  80089f:	83 c4 10             	add    $0x10,%esp
  8008a2:	eb ec                	jmp    800890 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  8008a4:	83 ec 0c             	sub    $0xc,%esp
  8008a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8008aa:	ff 75 cc             	pushl  -0x34(%ebp)
  8008ad:	ff 75 c8             	pushl  -0x38(%ebp)
  8008b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8008b3:	ff 75 d0             	pushl  -0x30(%ebp)
  8008b6:	89 f2                	mov    %esi,%edx
  8008b8:	89 d8                	mov    %ebx,%eax
  8008ba:	e8 e6 f9 ff ff       	call   8002a5 <printnum_helper>
  8008bf:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  8008c2:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008c5:	83 c7 01             	add    $0x1,%edi
  8008c8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008cc:	83 f8 25             	cmp    $0x25,%eax
  8008cf:	0f 84 b1 fa ff ff    	je     800386 <vprintfmt+0x17>
			if (ch == '\0')
  8008d5:	85 c0                	test   %eax,%eax
  8008d7:	0f 84 a1 00 00 00    	je     80097e <vprintfmt+0x60f>
			putch(ch, putdat);
  8008dd:	83 ec 08             	sub    $0x8,%esp
  8008e0:	56                   	push   %esi
  8008e1:	50                   	push   %eax
  8008e2:	ff d3                	call   *%ebx
  8008e4:	83 c4 10             	add    $0x10,%esp
  8008e7:	eb dc                	jmp    8008c5 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  8008e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ec:	83 c0 04             	add    $0x4,%eax
  8008ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8008f7:	85 ff                	test   %edi,%edi
  8008f9:	74 15                	je     800910 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  8008fb:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800901:	7f 29                	jg     80092c <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800903:	0f b6 06             	movzbl (%esi),%eax
  800906:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800908:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80090b:	89 45 14             	mov    %eax,0x14(%ebp)
  80090e:	eb b2                	jmp    8008c2 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800910:	68 a4 14 80 00       	push   $0x8014a4
  800915:	68 0d 14 80 00       	push   $0x80140d
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
  80091c:	e8 31 fa ff ff       	call   800352 <printfmt>
  800921:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800924:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800927:	89 45 14             	mov    %eax,0x14(%ebp)
  80092a:	eb 96                	jmp    8008c2 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  80092c:	68 dc 14 80 00       	push   $0x8014dc
  800931:	68 0d 14 80 00       	push   $0x80140d
  800936:	56                   	push   %esi
  800937:	53                   	push   %ebx
  800938:	e8 15 fa ff ff       	call   800352 <printfmt>
				*res = -1;
  80093d:	c6 07 ff             	movb   $0xff,(%edi)
  800940:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800943:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800946:	89 45 14             	mov    %eax,0x14(%ebp)
  800949:	e9 74 ff ff ff       	jmp    8008c2 <vprintfmt+0x553>
			putch(ch, putdat);
  80094e:	83 ec 08             	sub    $0x8,%esp
  800951:	56                   	push   %esi
  800952:	6a 25                	push   $0x25
  800954:	ff d3                	call   *%ebx
			break;
  800956:	83 c4 10             	add    $0x10,%esp
  800959:	e9 64 ff ff ff       	jmp    8008c2 <vprintfmt+0x553>
			putch('%', putdat);
  80095e:	83 ec 08             	sub    $0x8,%esp
  800961:	56                   	push   %esi
  800962:	6a 25                	push   $0x25
  800964:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800966:	83 c4 10             	add    $0x10,%esp
  800969:	89 f8                	mov    %edi,%eax
  80096b:	eb 03                	jmp    800970 <vprintfmt+0x601>
  80096d:	83 e8 01             	sub    $0x1,%eax
  800970:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800974:	75 f7                	jne    80096d <vprintfmt+0x5fe>
  800976:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800979:	e9 44 ff ff ff       	jmp    8008c2 <vprintfmt+0x553>
}
  80097e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800981:	5b                   	pop    %ebx
  800982:	5e                   	pop    %esi
  800983:	5f                   	pop    %edi
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	83 ec 18             	sub    $0x18,%esp
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800992:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800995:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800999:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80099c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009a3:	85 c0                	test   %eax,%eax
  8009a5:	74 26                	je     8009cd <vsnprintf+0x47>
  8009a7:	85 d2                	test   %edx,%edx
  8009a9:	7e 22                	jle    8009cd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ab:	ff 75 14             	pushl  0x14(%ebp)
  8009ae:	ff 75 10             	pushl  0x10(%ebp)
  8009b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b4:	50                   	push   %eax
  8009b5:	68 35 03 80 00       	push   $0x800335
  8009ba:	e8 b0 f9 ff ff       	call   80036f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009bf:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009c2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c8:	83 c4 10             	add    $0x10,%esp
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    
		return -E_INVAL;
  8009cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009d2:	eb f7                	jmp    8009cb <vsnprintf+0x45>

008009d4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009da:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009dd:	50                   	push   %eax
  8009de:	ff 75 10             	pushl  0x10(%ebp)
  8009e1:	ff 75 0c             	pushl  0xc(%ebp)
  8009e4:	ff 75 08             	pushl  0x8(%ebp)
  8009e7:	e8 9a ff ff ff       	call   800986 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009fd:	74 05                	je     800a04 <strlen+0x16>
		n++;
  8009ff:	83 c0 01             	add    $0x1,%eax
  800a02:	eb f5                	jmp    8009f9 <strlen+0xb>
	return n;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a14:	39 c2                	cmp    %eax,%edx
  800a16:	74 0d                	je     800a25 <strnlen+0x1f>
  800a18:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a1c:	74 05                	je     800a23 <strnlen+0x1d>
		n++;
  800a1e:	83 c2 01             	add    $0x1,%edx
  800a21:	eb f1                	jmp    800a14 <strnlen+0xe>
  800a23:	89 d0                	mov    %edx,%eax
	return n;
}
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	53                   	push   %ebx
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a31:	ba 00 00 00 00       	mov    $0x0,%edx
  800a36:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a3a:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a3d:	83 c2 01             	add    $0x1,%edx
  800a40:	84 c9                	test   %cl,%cl
  800a42:	75 f2                	jne    800a36 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a44:	5b                   	pop    %ebx
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	53                   	push   %ebx
  800a4b:	83 ec 10             	sub    $0x10,%esp
  800a4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a51:	53                   	push   %ebx
  800a52:	e8 97 ff ff ff       	call   8009ee <strlen>
  800a57:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a5a:	ff 75 0c             	pushl  0xc(%ebp)
  800a5d:	01 d8                	add    %ebx,%eax
  800a5f:	50                   	push   %eax
  800a60:	e8 c2 ff ff ff       	call   800a27 <strcpy>
	return dst;
}
  800a65:	89 d8                	mov    %ebx,%eax
  800a67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a77:	89 c6                	mov    %eax,%esi
  800a79:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a7c:	89 c2                	mov    %eax,%edx
  800a7e:	39 f2                	cmp    %esi,%edx
  800a80:	74 11                	je     800a93 <strncpy+0x27>
		*dst++ = *src;
  800a82:	83 c2 01             	add    $0x1,%edx
  800a85:	0f b6 19             	movzbl (%ecx),%ebx
  800a88:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a8b:	80 fb 01             	cmp    $0x1,%bl
  800a8e:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800a91:	eb eb                	jmp    800a7e <strncpy+0x12>
	}
	return ret;
}
  800a93:	5b                   	pop    %ebx
  800a94:	5e                   	pop    %esi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa2:	8b 55 10             	mov    0x10(%ebp),%edx
  800aa5:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa7:	85 d2                	test   %edx,%edx
  800aa9:	74 21                	je     800acc <strlcpy+0x35>
  800aab:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aaf:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800ab1:	39 c2                	cmp    %eax,%edx
  800ab3:	74 14                	je     800ac9 <strlcpy+0x32>
  800ab5:	0f b6 19             	movzbl (%ecx),%ebx
  800ab8:	84 db                	test   %bl,%bl
  800aba:	74 0b                	je     800ac7 <strlcpy+0x30>
			*dst++ = *src++;
  800abc:	83 c1 01             	add    $0x1,%ecx
  800abf:	83 c2 01             	add    $0x1,%edx
  800ac2:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ac5:	eb ea                	jmp    800ab1 <strlcpy+0x1a>
  800ac7:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800ac9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800acc:	29 f0                	sub    %esi,%eax
}
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800adb:	0f b6 01             	movzbl (%ecx),%eax
  800ade:	84 c0                	test   %al,%al
  800ae0:	74 0c                	je     800aee <strcmp+0x1c>
  800ae2:	3a 02                	cmp    (%edx),%al
  800ae4:	75 08                	jne    800aee <strcmp+0x1c>
		p++, q++;
  800ae6:	83 c1 01             	add    $0x1,%ecx
  800ae9:	83 c2 01             	add    $0x1,%edx
  800aec:	eb ed                	jmp    800adb <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aee:	0f b6 c0             	movzbl %al,%eax
  800af1:	0f b6 12             	movzbl (%edx),%edx
  800af4:	29 d0                	sub    %edx,%eax
}
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	53                   	push   %ebx
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b02:	89 c3                	mov    %eax,%ebx
  800b04:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b07:	eb 06                	jmp    800b0f <strncmp+0x17>
		n--, p++, q++;
  800b09:	83 c0 01             	add    $0x1,%eax
  800b0c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b0f:	39 d8                	cmp    %ebx,%eax
  800b11:	74 16                	je     800b29 <strncmp+0x31>
  800b13:	0f b6 08             	movzbl (%eax),%ecx
  800b16:	84 c9                	test   %cl,%cl
  800b18:	74 04                	je     800b1e <strncmp+0x26>
  800b1a:	3a 0a                	cmp    (%edx),%cl
  800b1c:	74 eb                	je     800b09 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b1e:	0f b6 00             	movzbl (%eax),%eax
  800b21:	0f b6 12             	movzbl (%edx),%edx
  800b24:	29 d0                	sub    %edx,%eax
}
  800b26:	5b                   	pop    %ebx
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    
		return 0;
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2e:	eb f6                	jmp    800b26 <strncmp+0x2e>

00800b30 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b3a:	0f b6 10             	movzbl (%eax),%edx
  800b3d:	84 d2                	test   %dl,%dl
  800b3f:	74 09                	je     800b4a <strchr+0x1a>
		if (*s == c)
  800b41:	38 ca                	cmp    %cl,%dl
  800b43:	74 0a                	je     800b4f <strchr+0x1f>
	for (; *s; s++)
  800b45:	83 c0 01             	add    $0x1,%eax
  800b48:	eb f0                	jmp    800b3a <strchr+0xa>
			return (char *) s;
	return 0;
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b5e:	38 ca                	cmp    %cl,%dl
  800b60:	74 09                	je     800b6b <strfind+0x1a>
  800b62:	84 d2                	test   %dl,%dl
  800b64:	74 05                	je     800b6b <strfind+0x1a>
	for (; *s; s++)
  800b66:	83 c0 01             	add    $0x1,%eax
  800b69:	eb f0                	jmp    800b5b <strfind+0xa>
			break;
	return (char *) s;
}
  800b6b:	5d                   	pop    %ebp
  800b6c:	c3                   	ret    

00800b6d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	57                   	push   %edi
  800b71:	56                   	push   %esi
  800b72:	53                   	push   %ebx
  800b73:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b79:	85 c9                	test   %ecx,%ecx
  800b7b:	74 31                	je     800bae <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b7d:	89 f8                	mov    %edi,%eax
  800b7f:	09 c8                	or     %ecx,%eax
  800b81:	a8 03                	test   $0x3,%al
  800b83:	75 23                	jne    800ba8 <memset+0x3b>
		c &= 0xFF;
  800b85:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b89:	89 d3                	mov    %edx,%ebx
  800b8b:	c1 e3 08             	shl    $0x8,%ebx
  800b8e:	89 d0                	mov    %edx,%eax
  800b90:	c1 e0 18             	shl    $0x18,%eax
  800b93:	89 d6                	mov    %edx,%esi
  800b95:	c1 e6 10             	shl    $0x10,%esi
  800b98:	09 f0                	or     %esi,%eax
  800b9a:	09 c2                	or     %eax,%edx
  800b9c:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b9e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ba1:	89 d0                	mov    %edx,%eax
  800ba3:	fc                   	cld    
  800ba4:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba6:	eb 06                	jmp    800bae <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bab:	fc                   	cld    
  800bac:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bae:	89 f8                	mov    %edi,%eax
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc3:	39 c6                	cmp    %eax,%esi
  800bc5:	73 32                	jae    800bf9 <memmove+0x44>
  800bc7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bca:	39 c2                	cmp    %eax,%edx
  800bcc:	76 2b                	jbe    800bf9 <memmove+0x44>
		s += n;
		d += n;
  800bce:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd1:	89 fe                	mov    %edi,%esi
  800bd3:	09 ce                	or     %ecx,%esi
  800bd5:	09 d6                	or     %edx,%esi
  800bd7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bdd:	75 0e                	jne    800bed <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bdf:	83 ef 04             	sub    $0x4,%edi
  800be2:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800be8:	fd                   	std    
  800be9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800beb:	eb 09                	jmp    800bf6 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bed:	83 ef 01             	sub    $0x1,%edi
  800bf0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bf3:	fd                   	std    
  800bf4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf6:	fc                   	cld    
  800bf7:	eb 1a                	jmp    800c13 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf9:	89 c2                	mov    %eax,%edx
  800bfb:	09 ca                	or     %ecx,%edx
  800bfd:	09 f2                	or     %esi,%edx
  800bff:	f6 c2 03             	test   $0x3,%dl
  800c02:	75 0a                	jne    800c0e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c04:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c07:	89 c7                	mov    %eax,%edi
  800c09:	fc                   	cld    
  800c0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0c:	eb 05                	jmp    800c13 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800c0e:	89 c7                	mov    %eax,%edi
  800c10:	fc                   	cld    
  800c11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c1d:	ff 75 10             	pushl  0x10(%ebp)
  800c20:	ff 75 0c             	pushl  0xc(%ebp)
  800c23:	ff 75 08             	pushl  0x8(%ebp)
  800c26:	e8 8a ff ff ff       	call   800bb5 <memmove>
}
  800c2b:	c9                   	leave  
  800c2c:	c3                   	ret    

00800c2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	8b 45 08             	mov    0x8(%ebp),%eax
  800c35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c38:	89 c6                	mov    %eax,%esi
  800c3a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3d:	39 f0                	cmp    %esi,%eax
  800c3f:	74 1c                	je     800c5d <memcmp+0x30>
		if (*s1 != *s2)
  800c41:	0f b6 08             	movzbl (%eax),%ecx
  800c44:	0f b6 1a             	movzbl (%edx),%ebx
  800c47:	38 d9                	cmp    %bl,%cl
  800c49:	75 08                	jne    800c53 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c4b:	83 c0 01             	add    $0x1,%eax
  800c4e:	83 c2 01             	add    $0x1,%edx
  800c51:	eb ea                	jmp    800c3d <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c53:	0f b6 c1             	movzbl %cl,%eax
  800c56:	0f b6 db             	movzbl %bl,%ebx
  800c59:	29 d8                	sub    %ebx,%eax
  800c5b:	eb 05                	jmp    800c62 <memcmp+0x35>
	}

	return 0;
  800c5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c6f:	89 c2                	mov    %eax,%edx
  800c71:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c74:	39 d0                	cmp    %edx,%eax
  800c76:	73 09                	jae    800c81 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c78:	38 08                	cmp    %cl,(%eax)
  800c7a:	74 05                	je     800c81 <memfind+0x1b>
	for (; s < ends; s++)
  800c7c:	83 c0 01             	add    $0x1,%eax
  800c7f:	eb f3                	jmp    800c74 <memfind+0xe>
			break;
	return (void *) s;
}
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8f:	eb 03                	jmp    800c94 <strtol+0x11>
		s++;
  800c91:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c94:	0f b6 01             	movzbl (%ecx),%eax
  800c97:	3c 20                	cmp    $0x20,%al
  800c99:	74 f6                	je     800c91 <strtol+0xe>
  800c9b:	3c 09                	cmp    $0x9,%al
  800c9d:	74 f2                	je     800c91 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c9f:	3c 2b                	cmp    $0x2b,%al
  800ca1:	74 2a                	je     800ccd <strtol+0x4a>
	int neg = 0;
  800ca3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ca8:	3c 2d                	cmp    $0x2d,%al
  800caa:	74 2b                	je     800cd7 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cac:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cb2:	75 0f                	jne    800cc3 <strtol+0x40>
  800cb4:	80 39 30             	cmpb   $0x30,(%ecx)
  800cb7:	74 28                	je     800ce1 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cb9:	85 db                	test   %ebx,%ebx
  800cbb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc0:	0f 44 d8             	cmove  %eax,%ebx
  800cc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc8:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ccb:	eb 50                	jmp    800d1d <strtol+0x9a>
		s++;
  800ccd:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cd0:	bf 00 00 00 00       	mov    $0x0,%edi
  800cd5:	eb d5                	jmp    800cac <strtol+0x29>
		s++, neg = 1;
  800cd7:	83 c1 01             	add    $0x1,%ecx
  800cda:	bf 01 00 00 00       	mov    $0x1,%edi
  800cdf:	eb cb                	jmp    800cac <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ce1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ce5:	74 0e                	je     800cf5 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ce7:	85 db                	test   %ebx,%ebx
  800ce9:	75 d8                	jne    800cc3 <strtol+0x40>
		s++, base = 8;
  800ceb:	83 c1 01             	add    $0x1,%ecx
  800cee:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cf3:	eb ce                	jmp    800cc3 <strtol+0x40>
		s += 2, base = 16;
  800cf5:	83 c1 02             	add    $0x2,%ecx
  800cf8:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cfd:	eb c4                	jmp    800cc3 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cff:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d02:	89 f3                	mov    %esi,%ebx
  800d04:	80 fb 19             	cmp    $0x19,%bl
  800d07:	77 29                	ja     800d32 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800d09:	0f be d2             	movsbl %dl,%edx
  800d0c:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d0f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d12:	7d 30                	jge    800d44 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d14:	83 c1 01             	add    $0x1,%ecx
  800d17:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d1b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d1d:	0f b6 11             	movzbl (%ecx),%edx
  800d20:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d23:	89 f3                	mov    %esi,%ebx
  800d25:	80 fb 09             	cmp    $0x9,%bl
  800d28:	77 d5                	ja     800cff <strtol+0x7c>
			dig = *s - '0';
  800d2a:	0f be d2             	movsbl %dl,%edx
  800d2d:	83 ea 30             	sub    $0x30,%edx
  800d30:	eb dd                	jmp    800d0f <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800d32:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d35:	89 f3                	mov    %esi,%ebx
  800d37:	80 fb 19             	cmp    $0x19,%bl
  800d3a:	77 08                	ja     800d44 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800d3c:	0f be d2             	movsbl %dl,%edx
  800d3f:	83 ea 37             	sub    $0x37,%edx
  800d42:	eb cb                	jmp    800d0f <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d44:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d48:	74 05                	je     800d4f <strtol+0xcc>
		*endptr = (char *) s;
  800d4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d4d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d4f:	89 c2                	mov    %eax,%edx
  800d51:	f7 da                	neg    %edx
  800d53:	85 ff                	test   %edi,%edi
  800d55:	0f 45 c2             	cmovne %edx,%eax
}
  800d58:	5b                   	pop    %ebx
  800d59:	5e                   	pop    %esi
  800d5a:	5f                   	pop    %edi
  800d5b:	5d                   	pop    %ebp
  800d5c:	c3                   	ret    

00800d5d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	57                   	push   %edi
  800d61:	56                   	push   %esi
  800d62:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d63:	b8 00 00 00 00       	mov    $0x0,%eax
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	89 c3                	mov    %eax,%ebx
  800d70:	89 c7                	mov    %eax,%edi
  800d72:	89 c6                	mov    %eax,%esi
  800d74:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <sys_cgetc>:

int
sys_cgetc(void)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d81:	ba 00 00 00 00       	mov    $0x0,%edx
  800d86:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8b:	89 d1                	mov    %edx,%ecx
  800d8d:	89 d3                	mov    %edx,%ebx
  800d8f:	89 d7                	mov    %edx,%edi
  800d91:	89 d6                	mov    %edx,%esi
  800d93:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d95:	5b                   	pop    %ebx
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	57                   	push   %edi
  800d9e:	56                   	push   %esi
  800d9f:	53                   	push   %ebx
  800da0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	b8 03 00 00 00       	mov    $0x3,%eax
  800db0:	89 cb                	mov    %ecx,%ebx
  800db2:	89 cf                	mov    %ecx,%edi
  800db4:	89 ce                	mov    %ecx,%esi
  800db6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db8:	85 c0                	test   %eax,%eax
  800dba:	7f 08                	jg     800dc4 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	50                   	push   %eax
  800dc8:	6a 03                	push   $0x3
  800dca:	68 a4 16 80 00       	push   $0x8016a4
  800dcf:	6a 23                	push   $0x23
  800dd1:	68 c1 16 80 00       	push   $0x8016c1
  800dd6:	e8 c5 02 00 00       	call   8010a0 <_panic>

00800ddb <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	57                   	push   %edi
  800ddf:	56                   	push   %esi
  800de0:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de1:	ba 00 00 00 00       	mov    $0x0,%edx
  800de6:	b8 02 00 00 00       	mov    $0x2,%eax
  800deb:	89 d1                	mov    %edx,%ecx
  800ded:	89 d3                	mov    %edx,%ebx
  800def:	89 d7                	mov    %edx,%edi
  800df1:	89 d6                	mov    %edx,%esi
  800df3:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <sys_yield>:

void
sys_yield(void)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e00:	ba 00 00 00 00       	mov    $0x0,%edx
  800e05:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e0a:	89 d1                	mov    %edx,%ecx
  800e0c:	89 d3                	mov    %edx,%ebx
  800e0e:	89 d7                	mov    %edx,%edi
  800e10:	89 d6                	mov    %edx,%esi
  800e12:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e14:	5b                   	pop    %ebx
  800e15:	5e                   	pop    %esi
  800e16:	5f                   	pop    %edi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e22:	be 00 00 00 00       	mov    $0x0,%esi
  800e27:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2d:	b8 04 00 00 00       	mov    $0x4,%eax
  800e32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e35:	89 f7                	mov    %esi,%edi
  800e37:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e39:	85 c0                	test   %eax,%eax
  800e3b:	7f 08                	jg     800e45 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e45:	83 ec 0c             	sub    $0xc,%esp
  800e48:	50                   	push   %eax
  800e49:	6a 04                	push   $0x4
  800e4b:	68 a4 16 80 00       	push   $0x8016a4
  800e50:	6a 23                	push   $0x23
  800e52:	68 c1 16 80 00       	push   $0x8016c1
  800e57:	e8 44 02 00 00       	call   8010a0 <_panic>

00800e5c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
  800e62:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e65:	8b 55 08             	mov    0x8(%ebp),%edx
  800e68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6b:	b8 05 00 00 00       	mov    $0x5,%eax
  800e70:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e73:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e76:	8b 75 18             	mov    0x18(%ebp),%esi
  800e79:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	7f 08                	jg     800e87 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e82:	5b                   	pop    %ebx
  800e83:	5e                   	pop    %esi
  800e84:	5f                   	pop    %edi
  800e85:	5d                   	pop    %ebp
  800e86:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e87:	83 ec 0c             	sub    $0xc,%esp
  800e8a:	50                   	push   %eax
  800e8b:	6a 05                	push   $0x5
  800e8d:	68 a4 16 80 00       	push   $0x8016a4
  800e92:	6a 23                	push   $0x23
  800e94:	68 c1 16 80 00       	push   $0x8016c1
  800e99:	e8 02 02 00 00       	call   8010a0 <_panic>

00800e9e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ea7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb2:	b8 06 00 00 00       	mov    $0x6,%eax
  800eb7:	89 df                	mov    %ebx,%edi
  800eb9:	89 de                	mov    %ebx,%esi
  800ebb:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	7f 08                	jg     800ec9 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ec1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ec4:	5b                   	pop    %ebx
  800ec5:	5e                   	pop    %esi
  800ec6:	5f                   	pop    %edi
  800ec7:	5d                   	pop    %ebp
  800ec8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec9:	83 ec 0c             	sub    $0xc,%esp
  800ecc:	50                   	push   %eax
  800ecd:	6a 06                	push   $0x6
  800ecf:	68 a4 16 80 00       	push   $0x8016a4
  800ed4:	6a 23                	push   $0x23
  800ed6:	68 c1 16 80 00       	push   $0x8016c1
  800edb:	e8 c0 01 00 00       	call   8010a0 <_panic>

00800ee0 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	57                   	push   %edi
  800ee4:	56                   	push   %esi
  800ee5:	53                   	push   %ebx
  800ee6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ee9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef4:	b8 08 00 00 00       	mov    $0x8,%eax
  800ef9:	89 df                	mov    %ebx,%edi
  800efb:	89 de                	mov    %ebx,%esi
  800efd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eff:	85 c0                	test   %eax,%eax
  800f01:	7f 08                	jg     800f0b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f06:	5b                   	pop    %ebx
  800f07:	5e                   	pop    %esi
  800f08:	5f                   	pop    %edi
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0b:	83 ec 0c             	sub    $0xc,%esp
  800f0e:	50                   	push   %eax
  800f0f:	6a 08                	push   $0x8
  800f11:	68 a4 16 80 00       	push   $0x8016a4
  800f16:	6a 23                	push   $0x23
  800f18:	68 c1 16 80 00       	push   $0x8016c1
  800f1d:	e8 7e 01 00 00       	call   8010a0 <_panic>

00800f22 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	57                   	push   %edi
  800f26:	56                   	push   %esi
  800f27:	53                   	push   %ebx
  800f28:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f2b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f30:	8b 55 08             	mov    0x8(%ebp),%edx
  800f33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f36:	b8 09 00 00 00       	mov    $0x9,%eax
  800f3b:	89 df                	mov    %ebx,%edi
  800f3d:	89 de                	mov    %ebx,%esi
  800f3f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f41:	85 c0                	test   %eax,%eax
  800f43:	7f 08                	jg     800f4d <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5f                   	pop    %edi
  800f4b:	5d                   	pop    %ebp
  800f4c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4d:	83 ec 0c             	sub    $0xc,%esp
  800f50:	50                   	push   %eax
  800f51:	6a 09                	push   $0x9
  800f53:	68 a4 16 80 00       	push   $0x8016a4
  800f58:	6a 23                	push   $0x23
  800f5a:	68 c1 16 80 00       	push   $0x8016c1
  800f5f:	e8 3c 01 00 00       	call   8010a0 <_panic>

00800f64 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	57                   	push   %edi
  800f68:	56                   	push   %esi
  800f69:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f70:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f75:	be 00 00 00 00       	mov    $0x0,%esi
  800f7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f7d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f80:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f95:	8b 55 08             	mov    0x8(%ebp),%edx
  800f98:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f9d:	89 cb                	mov    %ecx,%ebx
  800f9f:	89 cf                	mov    %ecx,%edi
  800fa1:	89 ce                	mov    %ecx,%esi
  800fa3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	7f 08                	jg     800fb1 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fac:	5b                   	pop    %ebx
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb1:	83 ec 0c             	sub    $0xc,%esp
  800fb4:	50                   	push   %eax
  800fb5:	6a 0c                	push   $0xc
  800fb7:	68 a4 16 80 00       	push   $0x8016a4
  800fbc:	6a 23                	push   $0x23
  800fbe:	68 c1 16 80 00       	push   $0x8016c1
  800fc3:	e8 d8 00 00 00       	call   8010a0 <_panic>

00800fc8 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	57                   	push   %edi
  800fcc:	56                   	push   %esi
  800fcd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fd9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fde:	89 df                	mov    %ebx,%edi
  800fe0:	89 de                	mov    %ebx,%esi
  800fe2:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800fe4:	5b                   	pop    %ebx
  800fe5:	5e                   	pop    %esi
  800fe6:	5f                   	pop    %edi
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    

00800fe9 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ffc:	89 cb                	mov    %ecx,%ebx
  800ffe:	89 cf                	mov    %ecx,%edi
  801000:	89 ce                	mov    %ecx,%esi
  801002:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801004:	5b                   	pop    %ebx
  801005:	5e                   	pop    %esi
  801006:	5f                   	pop    %edi
  801007:	5d                   	pop    %ebp
  801008:	c3                   	ret    

00801009 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
  80100c:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  80100f:	68 db 16 80 00       	push   $0x8016db
  801014:	6a 53                	push   $0x53
  801016:	68 cf 16 80 00       	push   $0x8016cf
  80101b:	e8 80 00 00 00       	call   8010a0 <_panic>

00801020 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801026:	68 da 16 80 00       	push   $0x8016da
  80102b:	6a 5a                	push   $0x5a
  80102d:	68 cf 16 80 00       	push   $0x8016cf
  801032:	e8 69 00 00 00       	call   8010a0 <_panic>

00801037 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  80103d:	68 f0 16 80 00       	push   $0x8016f0
  801042:	6a 1a                	push   $0x1a
  801044:	68 09 17 80 00       	push   $0x801709
  801049:	e8 52 00 00 00       	call   8010a0 <_panic>

0080104e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801054:	68 13 17 80 00       	push   $0x801713
  801059:	6a 2a                	push   $0x2a
  80105b:	68 09 17 80 00       	push   $0x801709
  801060:	e8 3b 00 00 00       	call   8010a0 <_panic>

00801065 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80106b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801070:	89 c2                	mov    %eax,%edx
  801072:	c1 e2 07             	shl    $0x7,%edx
  801075:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80107b:	8b 52 50             	mov    0x50(%edx),%edx
  80107e:	39 ca                	cmp    %ecx,%edx
  801080:	74 11                	je     801093 <ipc_find_env+0x2e>
	for (i = 0; i < NENV; i++)
  801082:	83 c0 01             	add    $0x1,%eax
  801085:	3d 00 04 00 00       	cmp    $0x400,%eax
  80108a:	75 e4                	jne    801070 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80108c:	b8 00 00 00 00       	mov    $0x0,%eax
  801091:	eb 0b                	jmp    80109e <ipc_find_env+0x39>
			return envs[i].env_id;
  801093:	c1 e0 07             	shl    $0x7,%eax
  801096:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80109b:	8b 40 48             	mov    0x48(%eax),%eax
}
  80109e:	5d                   	pop    %ebp
  80109f:	c3                   	ret    

008010a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	56                   	push   %esi
  8010a4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8010a5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8010a8:	8b 35 08 20 80 00    	mov    0x802008,%esi
  8010ae:	e8 28 fd ff ff       	call   800ddb <sys_getenvid>
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	ff 75 0c             	pushl  0xc(%ebp)
  8010b9:	ff 75 08             	pushl  0x8(%ebp)
  8010bc:	56                   	push   %esi
  8010bd:	50                   	push   %eax
  8010be:	68 2c 17 80 00       	push   $0x80172c
  8010c3:	e8 c9 f1 ff ff       	call   800291 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010c8:	83 c4 18             	add    $0x18,%esp
  8010cb:	53                   	push   %ebx
  8010cc:	ff 75 10             	pushl  0x10(%ebp)
  8010cf:	e8 6c f1 ff ff       	call   800240 <vcprintf>
	cprintf("\n");
  8010d4:	c7 04 24 52 13 80 00 	movl   $0x801352,(%esp)
  8010db:	e8 b1 f1 ff ff       	call   800291 <cprintf>
  8010e0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010e3:	cc                   	int3   
  8010e4:	eb fd                	jmp    8010e3 <_panic+0x43>
  8010e6:	66 90                	xchg   %ax,%ax
  8010e8:	66 90                	xchg   %ax,%ax
  8010ea:	66 90                	xchg   %ax,%ax
  8010ec:	66 90                	xchg   %ax,%ax
  8010ee:	66 90                	xchg   %ax,%ax

008010f0 <__udivdi3>:
  8010f0:	55                   	push   %ebp
  8010f1:	57                   	push   %edi
  8010f2:	56                   	push   %esi
  8010f3:	53                   	push   %ebx
  8010f4:	83 ec 1c             	sub    $0x1c,%esp
  8010f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8010fb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8010ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801103:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801107:	85 d2                	test   %edx,%edx
  801109:	75 4d                	jne    801158 <__udivdi3+0x68>
  80110b:	39 f3                	cmp    %esi,%ebx
  80110d:	76 19                	jbe    801128 <__udivdi3+0x38>
  80110f:	31 ff                	xor    %edi,%edi
  801111:	89 e8                	mov    %ebp,%eax
  801113:	89 f2                	mov    %esi,%edx
  801115:	f7 f3                	div    %ebx
  801117:	89 fa                	mov    %edi,%edx
  801119:	83 c4 1c             	add    $0x1c,%esp
  80111c:	5b                   	pop    %ebx
  80111d:	5e                   	pop    %esi
  80111e:	5f                   	pop    %edi
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    
  801121:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801128:	89 d9                	mov    %ebx,%ecx
  80112a:	85 db                	test   %ebx,%ebx
  80112c:	75 0b                	jne    801139 <__udivdi3+0x49>
  80112e:	b8 01 00 00 00       	mov    $0x1,%eax
  801133:	31 d2                	xor    %edx,%edx
  801135:	f7 f3                	div    %ebx
  801137:	89 c1                	mov    %eax,%ecx
  801139:	31 d2                	xor    %edx,%edx
  80113b:	89 f0                	mov    %esi,%eax
  80113d:	f7 f1                	div    %ecx
  80113f:	89 c6                	mov    %eax,%esi
  801141:	89 e8                	mov    %ebp,%eax
  801143:	89 f7                	mov    %esi,%edi
  801145:	f7 f1                	div    %ecx
  801147:	89 fa                	mov    %edi,%edx
  801149:	83 c4 1c             	add    $0x1c,%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    
  801151:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801158:	39 f2                	cmp    %esi,%edx
  80115a:	77 1c                	ja     801178 <__udivdi3+0x88>
  80115c:	0f bd fa             	bsr    %edx,%edi
  80115f:	83 f7 1f             	xor    $0x1f,%edi
  801162:	75 2c                	jne    801190 <__udivdi3+0xa0>
  801164:	39 f2                	cmp    %esi,%edx
  801166:	72 06                	jb     80116e <__udivdi3+0x7e>
  801168:	31 c0                	xor    %eax,%eax
  80116a:	39 eb                	cmp    %ebp,%ebx
  80116c:	77 a9                	ja     801117 <__udivdi3+0x27>
  80116e:	b8 01 00 00 00       	mov    $0x1,%eax
  801173:	eb a2                	jmp    801117 <__udivdi3+0x27>
  801175:	8d 76 00             	lea    0x0(%esi),%esi
  801178:	31 ff                	xor    %edi,%edi
  80117a:	31 c0                	xor    %eax,%eax
  80117c:	89 fa                	mov    %edi,%edx
  80117e:	83 c4 1c             	add    $0x1c,%esp
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5f                   	pop    %edi
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    
  801186:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80118d:	8d 76 00             	lea    0x0(%esi),%esi
  801190:	89 f9                	mov    %edi,%ecx
  801192:	b8 20 00 00 00       	mov    $0x20,%eax
  801197:	29 f8                	sub    %edi,%eax
  801199:	d3 e2                	shl    %cl,%edx
  80119b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80119f:	89 c1                	mov    %eax,%ecx
  8011a1:	89 da                	mov    %ebx,%edx
  8011a3:	d3 ea                	shr    %cl,%edx
  8011a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8011a9:	09 d1                	or     %edx,%ecx
  8011ab:	89 f2                	mov    %esi,%edx
  8011ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011b1:	89 f9                	mov    %edi,%ecx
  8011b3:	d3 e3                	shl    %cl,%ebx
  8011b5:	89 c1                	mov    %eax,%ecx
  8011b7:	d3 ea                	shr    %cl,%edx
  8011b9:	89 f9                	mov    %edi,%ecx
  8011bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011bf:	89 eb                	mov    %ebp,%ebx
  8011c1:	d3 e6                	shl    %cl,%esi
  8011c3:	89 c1                	mov    %eax,%ecx
  8011c5:	d3 eb                	shr    %cl,%ebx
  8011c7:	09 de                	or     %ebx,%esi
  8011c9:	89 f0                	mov    %esi,%eax
  8011cb:	f7 74 24 08          	divl   0x8(%esp)
  8011cf:	89 d6                	mov    %edx,%esi
  8011d1:	89 c3                	mov    %eax,%ebx
  8011d3:	f7 64 24 0c          	mull   0xc(%esp)
  8011d7:	39 d6                	cmp    %edx,%esi
  8011d9:	72 15                	jb     8011f0 <__udivdi3+0x100>
  8011db:	89 f9                	mov    %edi,%ecx
  8011dd:	d3 e5                	shl    %cl,%ebp
  8011df:	39 c5                	cmp    %eax,%ebp
  8011e1:	73 04                	jae    8011e7 <__udivdi3+0xf7>
  8011e3:	39 d6                	cmp    %edx,%esi
  8011e5:	74 09                	je     8011f0 <__udivdi3+0x100>
  8011e7:	89 d8                	mov    %ebx,%eax
  8011e9:	31 ff                	xor    %edi,%edi
  8011eb:	e9 27 ff ff ff       	jmp    801117 <__udivdi3+0x27>
  8011f0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8011f3:	31 ff                	xor    %edi,%edi
  8011f5:	e9 1d ff ff ff       	jmp    801117 <__udivdi3+0x27>
  8011fa:	66 90                	xchg   %ax,%ax
  8011fc:	66 90                	xchg   %ax,%ax
  8011fe:	66 90                	xchg   %ax,%ax

00801200 <__umoddi3>:
  801200:	55                   	push   %ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
  801204:	83 ec 1c             	sub    $0x1c,%esp
  801207:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80120b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80120f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801217:	89 da                	mov    %ebx,%edx
  801219:	85 c0                	test   %eax,%eax
  80121b:	75 43                	jne    801260 <__umoddi3+0x60>
  80121d:	39 df                	cmp    %ebx,%edi
  80121f:	76 17                	jbe    801238 <__umoddi3+0x38>
  801221:	89 f0                	mov    %esi,%eax
  801223:	f7 f7                	div    %edi
  801225:	89 d0                	mov    %edx,%eax
  801227:	31 d2                	xor    %edx,%edx
  801229:	83 c4 1c             	add    $0x1c,%esp
  80122c:	5b                   	pop    %ebx
  80122d:	5e                   	pop    %esi
  80122e:	5f                   	pop    %edi
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    
  801231:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801238:	89 fd                	mov    %edi,%ebp
  80123a:	85 ff                	test   %edi,%edi
  80123c:	75 0b                	jne    801249 <__umoddi3+0x49>
  80123e:	b8 01 00 00 00       	mov    $0x1,%eax
  801243:	31 d2                	xor    %edx,%edx
  801245:	f7 f7                	div    %edi
  801247:	89 c5                	mov    %eax,%ebp
  801249:	89 d8                	mov    %ebx,%eax
  80124b:	31 d2                	xor    %edx,%edx
  80124d:	f7 f5                	div    %ebp
  80124f:	89 f0                	mov    %esi,%eax
  801251:	f7 f5                	div    %ebp
  801253:	89 d0                	mov    %edx,%eax
  801255:	eb d0                	jmp    801227 <__umoddi3+0x27>
  801257:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80125e:	66 90                	xchg   %ax,%ax
  801260:	89 f1                	mov    %esi,%ecx
  801262:	39 d8                	cmp    %ebx,%eax
  801264:	76 0a                	jbe    801270 <__umoddi3+0x70>
  801266:	89 f0                	mov    %esi,%eax
  801268:	83 c4 1c             	add    $0x1c,%esp
  80126b:	5b                   	pop    %ebx
  80126c:	5e                   	pop    %esi
  80126d:	5f                   	pop    %edi
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    
  801270:	0f bd e8             	bsr    %eax,%ebp
  801273:	83 f5 1f             	xor    $0x1f,%ebp
  801276:	75 20                	jne    801298 <__umoddi3+0x98>
  801278:	39 d8                	cmp    %ebx,%eax
  80127a:	0f 82 b0 00 00 00    	jb     801330 <__umoddi3+0x130>
  801280:	39 f7                	cmp    %esi,%edi
  801282:	0f 86 a8 00 00 00    	jbe    801330 <__umoddi3+0x130>
  801288:	89 c8                	mov    %ecx,%eax
  80128a:	83 c4 1c             	add    $0x1c,%esp
  80128d:	5b                   	pop    %ebx
  80128e:	5e                   	pop    %esi
  80128f:	5f                   	pop    %edi
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    
  801292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801298:	89 e9                	mov    %ebp,%ecx
  80129a:	ba 20 00 00 00       	mov    $0x20,%edx
  80129f:	29 ea                	sub    %ebp,%edx
  8012a1:	d3 e0                	shl    %cl,%eax
  8012a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a7:	89 d1                	mov    %edx,%ecx
  8012a9:	89 f8                	mov    %edi,%eax
  8012ab:	d3 e8                	shr    %cl,%eax
  8012ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8012b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012b5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012b9:	09 c1                	or     %eax,%ecx
  8012bb:	89 d8                	mov    %ebx,%eax
  8012bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012c1:	89 e9                	mov    %ebp,%ecx
  8012c3:	d3 e7                	shl    %cl,%edi
  8012c5:	89 d1                	mov    %edx,%ecx
  8012c7:	d3 e8                	shr    %cl,%eax
  8012c9:	89 e9                	mov    %ebp,%ecx
  8012cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012cf:	d3 e3                	shl    %cl,%ebx
  8012d1:	89 c7                	mov    %eax,%edi
  8012d3:	89 d1                	mov    %edx,%ecx
  8012d5:	89 f0                	mov    %esi,%eax
  8012d7:	d3 e8                	shr    %cl,%eax
  8012d9:	89 e9                	mov    %ebp,%ecx
  8012db:	89 fa                	mov    %edi,%edx
  8012dd:	d3 e6                	shl    %cl,%esi
  8012df:	09 d8                	or     %ebx,%eax
  8012e1:	f7 74 24 08          	divl   0x8(%esp)
  8012e5:	89 d1                	mov    %edx,%ecx
  8012e7:	89 f3                	mov    %esi,%ebx
  8012e9:	f7 64 24 0c          	mull   0xc(%esp)
  8012ed:	89 c6                	mov    %eax,%esi
  8012ef:	89 d7                	mov    %edx,%edi
  8012f1:	39 d1                	cmp    %edx,%ecx
  8012f3:	72 06                	jb     8012fb <__umoddi3+0xfb>
  8012f5:	75 10                	jne    801307 <__umoddi3+0x107>
  8012f7:	39 c3                	cmp    %eax,%ebx
  8012f9:	73 0c                	jae    801307 <__umoddi3+0x107>
  8012fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8012ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801303:	89 d7                	mov    %edx,%edi
  801305:	89 c6                	mov    %eax,%esi
  801307:	89 ca                	mov    %ecx,%edx
  801309:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80130e:	29 f3                	sub    %esi,%ebx
  801310:	19 fa                	sbb    %edi,%edx
  801312:	89 d0                	mov    %edx,%eax
  801314:	d3 e0                	shl    %cl,%eax
  801316:	89 e9                	mov    %ebp,%ecx
  801318:	d3 eb                	shr    %cl,%ebx
  80131a:	d3 ea                	shr    %cl,%edx
  80131c:	09 d8                	or     %ebx,%eax
  80131e:	83 c4 1c             	add    $0x1c,%esp
  801321:	5b                   	pop    %ebx
  801322:	5e                   	pop    %esi
  801323:	5f                   	pop    %edi
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    
  801326:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80132d:	8d 76 00             	lea    0x0(%esi),%esi
  801330:	89 da                	mov    %ebx,%edx
  801332:	29 fe                	sub    %edi,%esi
  801334:	19 c2                	sbb    %eax,%edx
  801336:	89 f1                	mov    %esi,%ecx
  801338:	89 c8                	mov    %ecx,%eax
  80133a:	e9 4b ff ff ff       	jmp    80128a <__umoddi3+0x8a>
