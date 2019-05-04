
obj/user/primes:     file format elf32-i386


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
  80002c:	e8 c5 00 00 00       	call   8000f6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 83 0f 00 00       	call   800fcf <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 20 80 00       	mov    0x802004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 a0 12 80 00       	push   $0x8012a0
  800060:	e8 c4 01 00 00       	call   800229 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 37 0f 00 00       	call   800fa1 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	78 07                	js     80007a <primeproc+0x47>
		panic("fork: %e", id);
	if (id == 0)
  800073:	74 ca                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800075:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800078:	eb 20                	jmp    80009a <primeproc+0x67>
		panic("fork: %e", id);
  80007a:	50                   	push   %eax
  80007b:	68 ac 12 80 00       	push   $0x8012ac
  800080:	6a 1a                	push   $0x1a
  800082:	68 b5 12 80 00       	push   $0x8012b5
  800087:	e8 c2 00 00 00       	call   80014e <_panic>
		if (i % p)
			ipc_send(id, i, 0, 0);
  80008c:	6a 00                	push   $0x0
  80008e:	6a 00                	push   $0x0
  800090:	51                   	push   %ecx
  800091:	57                   	push   %edi
  800092:	e8 4f 0f 00 00       	call   800fe6 <ipc_send>
  800097:	83 c4 10             	add    $0x10,%esp
		i = ipc_recv(&envid, 0, 0);
  80009a:	83 ec 04             	sub    $0x4,%esp
  80009d:	6a 00                	push   $0x0
  80009f:	6a 00                	push   $0x0
  8000a1:	56                   	push   %esi
  8000a2:	e8 28 0f 00 00       	call   800fcf <ipc_recv>
  8000a7:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000a9:	99                   	cltd   
  8000aa:	f7 fb                	idiv   %ebx
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	85 d2                	test   %edx,%edx
  8000b1:	74 e7                	je     80009a <primeproc+0x67>
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 e2 0e 00 00       	call   800fa1 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	78 1a                	js     8000df <umain+0x2a>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000c5:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000ca:	74 25                	je     8000f1 <umain+0x3c>
		ipc_send(id, i, 0, 0);
  8000cc:	6a 00                	push   $0x0
  8000ce:	6a 00                	push   $0x0
  8000d0:	53                   	push   %ebx
  8000d1:	56                   	push   %esi
  8000d2:	e8 0f 0f 00 00       	call   800fe6 <ipc_send>
	for (i = 2; ; i++)
  8000d7:	83 c3 01             	add    $0x1,%ebx
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	eb ed                	jmp    8000cc <umain+0x17>
		panic("fork: %e", id);
  8000df:	50                   	push   %eax
  8000e0:	68 ac 12 80 00       	push   $0x8012ac
  8000e5:	6a 2d                	push   $0x2d
  8000e7:	68 b5 12 80 00       	push   $0x8012b5
  8000ec:	e8 5d 00 00 00       	call   80014e <_panic>
		primeproc();
  8000f1:	e8 3d ff ff ff       	call   800033 <primeproc>

008000f6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000fe:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800101:	e8 6d 0c 00 00       	call   800d73 <sys_getenvid>
  800106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010b:	c1 e0 07             	shl    $0x7,%eax
  80010e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800113:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800118:	85 db                	test   %ebx,%ebx
  80011a:	7e 07                	jle    800123 <libmain+0x2d>
		binaryname = argv[0];
  80011c:	8b 06                	mov    (%esi),%eax
  80011e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800123:	83 ec 08             	sub    $0x8,%esp
  800126:	56                   	push   %esi
  800127:	53                   	push   %ebx
  800128:	e8 88 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012d:	e8 0a 00 00 00       	call   80013c <exit>
}
  800132:	83 c4 10             	add    $0x10,%esp
  800135:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800138:	5b                   	pop    %ebx
  800139:	5e                   	pop    %esi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800142:	6a 00                	push   $0x0
  800144:	e8 e9 0b 00 00       	call   800d32 <sys_env_destroy>
}
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    

0080014e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800153:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800156:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015c:	e8 12 0c 00 00       	call   800d73 <sys_getenvid>
  800161:	83 ec 0c             	sub    $0xc,%esp
  800164:	ff 75 0c             	pushl  0xc(%ebp)
  800167:	ff 75 08             	pushl  0x8(%ebp)
  80016a:	56                   	push   %esi
  80016b:	50                   	push   %eax
  80016c:	68 d0 12 80 00       	push   $0x8012d0
  800171:	e8 b3 00 00 00       	call   800229 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800176:	83 c4 18             	add    $0x18,%esp
  800179:	53                   	push   %ebx
  80017a:	ff 75 10             	pushl  0x10(%ebp)
  80017d:	e8 56 00 00 00       	call   8001d8 <vcprintf>
	cprintf("\n");
  800182:	c7 04 24 f3 12 80 00 	movl   $0x8012f3,(%esp)
  800189:	e8 9b 00 00 00       	call   800229 <cprintf>
  80018e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800191:	cc                   	int3   
  800192:	eb fd                	jmp    800191 <_panic+0x43>

00800194 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	53                   	push   %ebx
  800198:	83 ec 04             	sub    $0x4,%esp
  80019b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019e:	8b 13                	mov    (%ebx),%edx
  8001a0:	8d 42 01             	lea    0x1(%edx),%eax
  8001a3:	89 03                	mov    %eax,(%ebx)
  8001a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b1:	74 09                	je     8001bc <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001b3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	68 ff 00 00 00       	push   $0xff
  8001c4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c7:	50                   	push   %eax
  8001c8:	e8 28 0b 00 00       	call   800cf5 <sys_cputs>
		b->idx = 0;
  8001cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	eb db                	jmp    8001b3 <putch+0x1f>

008001d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e8:	00 00 00 
	b.cnt = 0;
  8001eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f5:	ff 75 0c             	pushl  0xc(%ebp)
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800201:	50                   	push   %eax
  800202:	68 94 01 80 00       	push   $0x800194
  800207:	e8 fb 00 00 00       	call   800307 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020c:	83 c4 08             	add    $0x8,%esp
  80020f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800215:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021b:	50                   	push   %eax
  80021c:	e8 d4 0a 00 00       	call   800cf5 <sys_cputs>

	return b.cnt;
}
  800221:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800227:	c9                   	leave  
  800228:	c3                   	ret    

00800229 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800232:	50                   	push   %eax
  800233:	ff 75 08             	pushl  0x8(%ebp)
  800236:	e8 9d ff ff ff       	call   8001d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	57                   	push   %edi
  800241:	56                   	push   %esi
  800242:	53                   	push   %ebx
  800243:	83 ec 1c             	sub    $0x1c,%esp
  800246:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800249:	89 d3                	mov    %edx,%ebx
  80024b:	8b 75 08             	mov    0x8(%ebp),%esi
  80024e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800251:	8b 45 10             	mov    0x10(%ebp),%eax
  800254:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800257:	89 c2                	mov    %eax,%edx
  800259:	b9 00 00 00 00       	mov    $0x0,%ecx
  80025e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800261:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800264:	39 c6                	cmp    %eax,%esi
  800266:	89 f8                	mov    %edi,%eax
  800268:	19 c8                	sbb    %ecx,%eax
  80026a:	73 32                	jae    80029e <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	53                   	push   %ebx
  800270:	83 ec 04             	sub    $0x4,%esp
  800273:	ff 75 e4             	pushl  -0x1c(%ebp)
  800276:	ff 75 e0             	pushl  -0x20(%ebp)
  800279:	57                   	push   %edi
  80027a:	56                   	push   %esi
  80027b:	e8 d0 0e 00 00       	call   801150 <__umoddi3>
  800280:	83 c4 14             	add    $0x14,%esp
  800283:	0f be 80 f5 12 80 00 	movsbl 0x8012f5(%eax),%eax
  80028a:	50                   	push   %eax
  80028b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028e:	ff d0                	call   *%eax
	return remain - 1;
  800290:	8b 45 14             	mov    0x14(%ebp),%eax
  800293:	83 e8 01             	sub    $0x1,%eax
}
  800296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  80029e:	83 ec 0c             	sub    $0xc,%esp
  8002a1:	ff 75 18             	pushl  0x18(%ebp)
  8002a4:	ff 75 14             	pushl  0x14(%ebp)
  8002a7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	51                   	push   %ecx
  8002ae:	52                   	push   %edx
  8002af:	57                   	push   %edi
  8002b0:	56                   	push   %esi
  8002b1:	e8 8a 0d 00 00       	call   801040 <__udivdi3>
  8002b6:	83 c4 18             	add    $0x18,%esp
  8002b9:	52                   	push   %edx
  8002ba:	50                   	push   %eax
  8002bb:	89 da                	mov    %ebx,%edx
  8002bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c0:	e8 78 ff ff ff       	call   80023d <printnum_helper>
  8002c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8002c8:	83 c4 20             	add    $0x20,%esp
  8002cb:	eb 9f                	jmp    80026c <printnum_helper+0x2f>

008002cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d7:	8b 10                	mov    (%eax),%edx
  8002d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8002dc:	73 0a                	jae    8002e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e1:	89 08                	mov    %ecx,(%eax)
  8002e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e6:	88 02                	mov    %al,(%edx)
}
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    

008002ea <printfmt>:
{
  8002ea:	55                   	push   %ebp
  8002eb:	89 e5                	mov    %esp,%ebp
  8002ed:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f3:	50                   	push   %eax
  8002f4:	ff 75 10             	pushl  0x10(%ebp)
  8002f7:	ff 75 0c             	pushl  0xc(%ebp)
  8002fa:	ff 75 08             	pushl  0x8(%ebp)
  8002fd:	e8 05 00 00 00       	call   800307 <vprintfmt>
}
  800302:	83 c4 10             	add    $0x10,%esp
  800305:	c9                   	leave  
  800306:	c3                   	ret    

00800307 <vprintfmt>:
{
  800307:	55                   	push   %ebp
  800308:	89 e5                	mov    %esp,%ebp
  80030a:	57                   	push   %edi
  80030b:	56                   	push   %esi
  80030c:	53                   	push   %ebx
  80030d:	83 ec 3c             	sub    $0x3c,%esp
  800310:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800313:	8b 75 0c             	mov    0xc(%ebp),%esi
  800316:	8b 7d 10             	mov    0x10(%ebp),%edi
  800319:	e9 3f 05 00 00       	jmp    80085d <vprintfmt+0x556>
		padc = ' ';
  80031e:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800322:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800329:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800330:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800337:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  80033e:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800345:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8d 47 01             	lea    0x1(%edi),%eax
  80034d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800350:	0f b6 17             	movzbl (%edi),%edx
  800353:	8d 42 dd             	lea    -0x23(%edx),%eax
  800356:	3c 55                	cmp    $0x55,%al
  800358:	0f 87 98 05 00 00    	ja     8008f6 <vprintfmt+0x5ef>
  80035e:	0f b6 c0             	movzbl %al,%eax
  800361:	ff 24 85 40 14 80 00 	jmp    *0x801440(,%eax,4)
  800368:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  80036b:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80036f:	eb d9                	jmp    80034a <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800374:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  80037b:	eb cd                	jmp    80034a <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	0f b6 d2             	movzbl %dl,%edx
  800380:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800383:	b8 00 00 00 00       	mov    $0x0,%eax
  800388:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  80038b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800392:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800395:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800398:	83 fb 09             	cmp    $0x9,%ebx
  80039b:	77 5c                	ja     8003f9 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  80039d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a0:	eb e9                	jmp    80038b <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  8003a2:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  8003a5:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  8003a9:	eb 9f                	jmp    80034a <vprintfmt+0x43>
			precision = va_arg(ap, int);
  8003ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ae:	8b 00                	mov    (%eax),%eax
  8003b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 40 04             	lea    0x4(%eax),%eax
  8003b9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8003bf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8003c3:	79 85                	jns    80034a <vprintfmt+0x43>
				width = precision, precision = -1;
  8003c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003cb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003d2:	e9 73 ff ff ff       	jmp    80034a <vprintfmt+0x43>
  8003d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003da:	85 c0                	test   %eax,%eax
  8003dc:	0f 48 c1             	cmovs  %ecx,%eax
  8003df:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8003e5:	e9 60 ff ff ff       	jmp    80034a <vprintfmt+0x43>
  8003ea:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8003ed:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8003f4:	e9 51 ff ff ff       	jmp    80034a <vprintfmt+0x43>
  8003f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003ff:	eb be                	jmp    8003bf <vprintfmt+0xb8>
			lflag++;
  800401:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  800408:	e9 3d ff ff ff       	jmp    80034a <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  80040d:	8b 45 14             	mov    0x14(%ebp),%eax
  800410:	8d 78 04             	lea    0x4(%eax),%edi
  800413:	83 ec 08             	sub    $0x8,%esp
  800416:	56                   	push   %esi
  800417:	ff 30                	pushl  (%eax)
  800419:	ff d3                	call   *%ebx
			break;
  80041b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800421:	e9 34 04 00 00       	jmp    80085a <vprintfmt+0x553>
			err = va_arg(ap, int);
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 78 04             	lea    0x4(%eax),%edi
  80042c:	8b 00                	mov    (%eax),%eax
  80042e:	99                   	cltd   
  80042f:	31 d0                	xor    %edx,%eax
  800431:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800433:	83 f8 08             	cmp    $0x8,%eax
  800436:	7f 23                	jg     80045b <vprintfmt+0x154>
  800438:	8b 14 85 a0 15 80 00 	mov    0x8015a0(,%eax,4),%edx
  80043f:	85 d2                	test   %edx,%edx
  800441:	74 18                	je     80045b <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800443:	52                   	push   %edx
  800444:	68 16 13 80 00       	push   $0x801316
  800449:	56                   	push   %esi
  80044a:	53                   	push   %ebx
  80044b:	e8 9a fe ff ff       	call   8002ea <printfmt>
  800450:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800453:	89 7d 14             	mov    %edi,0x14(%ebp)
  800456:	e9 ff 03 00 00       	jmp    80085a <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  80045b:	50                   	push   %eax
  80045c:	68 0d 13 80 00       	push   $0x80130d
  800461:	56                   	push   %esi
  800462:	53                   	push   %ebx
  800463:	e8 82 fe ff ff       	call   8002ea <printfmt>
  800468:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80046e:	e9 e7 03 00 00       	jmp    80085a <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  800473:	8b 45 14             	mov    0x14(%ebp),%eax
  800476:	83 c0 04             	add    $0x4,%eax
  800479:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800481:	85 c9                	test   %ecx,%ecx
  800483:	b8 06 13 80 00       	mov    $0x801306,%eax
  800488:	0f 45 c1             	cmovne %ecx,%eax
  80048b:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80048e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800492:	7e 06                	jle    80049a <vprintfmt+0x193>
  800494:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800498:	75 0d                	jne    8004a7 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80049d:	89 c7                	mov    %eax,%edi
  80049f:	03 45 d8             	add    -0x28(%ebp),%eax
  8004a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a5:	eb 53                	jmp    8004fa <vprintfmt+0x1f3>
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ad:	50                   	push   %eax
  8004ae:	e8 eb 04 00 00       	call   80099e <strnlen>
  8004b3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8004b6:	29 c1                	sub    %eax,%ecx
  8004b8:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004c0:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8004c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	eb 0f                	jmp    8004d8 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	56                   	push   %esi
  8004cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d0:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d2:	83 ef 01             	sub    $0x1,%edi
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	85 ff                	test   %edi,%edi
  8004da:	7f ed                	jg     8004c9 <vprintfmt+0x1c2>
  8004dc:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8004df:	85 c9                	test   %ecx,%ecx
  8004e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e6:	0f 49 c1             	cmovns %ecx,%eax
  8004e9:	29 c1                	sub    %eax,%ecx
  8004eb:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8004ee:	eb aa                	jmp    80049a <vprintfmt+0x193>
					putch(ch, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	56                   	push   %esi
  8004f4:	52                   	push   %edx
  8004f5:	ff d3                	call   *%ebx
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8004fd:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ff:	83 c7 01             	add    $0x1,%edi
  800502:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800506:	0f be d0             	movsbl %al,%edx
  800509:	85 d2                	test   %edx,%edx
  80050b:	74 2e                	je     80053b <vprintfmt+0x234>
  80050d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800511:	78 06                	js     800519 <vprintfmt+0x212>
  800513:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800517:	78 1e                	js     800537 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80051d:	74 d1                	je     8004f0 <vprintfmt+0x1e9>
  80051f:	0f be c0             	movsbl %al,%eax
  800522:	83 e8 20             	sub    $0x20,%eax
  800525:	83 f8 5e             	cmp    $0x5e,%eax
  800528:	76 c6                	jbe    8004f0 <vprintfmt+0x1e9>
					putch('?', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	56                   	push   %esi
  80052e:	6a 3f                	push   $0x3f
  800530:	ff d3                	call   *%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	eb c3                	jmp    8004fa <vprintfmt+0x1f3>
  800537:	89 cf                	mov    %ecx,%edi
  800539:	eb 02                	jmp    80053d <vprintfmt+0x236>
  80053b:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  80053d:	85 ff                	test   %edi,%edi
  80053f:	7e 10                	jle    800551 <vprintfmt+0x24a>
				putch(' ', putdat);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	56                   	push   %esi
  800545:	6a 20                	push   $0x20
  800547:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800549:	83 ef 01             	sub    $0x1,%edi
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	eb ec                	jmp    80053d <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800551:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800554:	89 45 14             	mov    %eax,0x14(%ebp)
  800557:	e9 fe 02 00 00       	jmp    80085a <vprintfmt+0x553>
	if (lflag >= 2)
  80055c:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800560:	7f 21                	jg     800583 <vprintfmt+0x27c>
	else if (lflag)
  800562:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800566:	74 79                	je     8005e1 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800570:	89 c1                	mov    %eax,%ecx
  800572:	c1 f9 1f             	sar    $0x1f,%ecx
  800575:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8d 40 04             	lea    0x4(%eax),%eax
  80057e:	89 45 14             	mov    %eax,0x14(%ebp)
  800581:	eb 17                	jmp    80059a <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800583:	8b 45 14             	mov    0x14(%ebp),%eax
  800586:	8b 50 04             	mov    0x4(%eax),%edx
  800589:	8b 00                	mov    (%eax),%eax
  80058b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 40 08             	lea    0x8(%eax),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  80059a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80059d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  8005a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005aa:	78 50                	js     8005fc <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  8005ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005af:	c1 fa 1f             	sar    $0x1f,%edx
  8005b2:	89 d0                	mov    %edx,%eax
  8005b4:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8005b7:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8005ba:	85 d2                	test   %edx,%edx
  8005bc:	0f 89 14 02 00 00    	jns    8007d6 <vprintfmt+0x4cf>
  8005c2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005c6:	0f 84 0a 02 00 00    	je     8007d6 <vprintfmt+0x4cf>
				putch('+', putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	56                   	push   %esi
  8005d0:	6a 2b                	push   $0x2b
  8005d2:	ff d3                	call   *%ebx
  8005d4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005dc:	e9 5c 01 00 00       	jmp    80073d <vprintfmt+0x436>
		return va_arg(*ap, int);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e9:	89 c1                	mov    %eax,%ecx
  8005eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ee:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 40 04             	lea    0x4(%eax),%eax
  8005f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fa:	eb 9e                	jmp    80059a <vprintfmt+0x293>
				putch('-', putdat);
  8005fc:	83 ec 08             	sub    $0x8,%esp
  8005ff:	56                   	push   %esi
  800600:	6a 2d                	push   $0x2d
  800602:	ff d3                	call   *%ebx
				num = -(long long) num;
  800604:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800607:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80060a:	f7 d8                	neg    %eax
  80060c:	83 d2 00             	adc    $0x0,%edx
  80060f:	f7 da                	neg    %edx
  800611:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800614:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800617:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80061a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061f:	e9 19 01 00 00       	jmp    80073d <vprintfmt+0x436>
	if (lflag >= 2)
  800624:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800628:	7f 29                	jg     800653 <vprintfmt+0x34c>
	else if (lflag)
  80062a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80062e:	74 44                	je     800674 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 00                	mov    (%eax),%eax
  800635:	ba 00 00 00 00       	mov    $0x0,%edx
  80063a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80063d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 40 04             	lea    0x4(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800649:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064e:	e9 ea 00 00 00       	jmp    80073d <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 50 04             	mov    0x4(%eax),%edx
  800659:	8b 00                	mov    (%eax),%eax
  80065b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80065e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8d 40 08             	lea    0x8(%eax),%eax
  800667:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80066a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80066f:	e9 c9 00 00 00       	jmp    80073d <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 00                	mov    (%eax),%eax
  800679:	ba 00 00 00 00       	mov    $0x0,%edx
  80067e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800681:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8d 40 04             	lea    0x4(%eax),%eax
  80068a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80068d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800692:	e9 a6 00 00 00       	jmp    80073d <vprintfmt+0x436>
			putch('0', putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	56                   	push   %esi
  80069b:	6a 30                	push   $0x30
  80069d:	ff d3                	call   *%ebx
	if (lflag >= 2)
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8006a6:	7f 26                	jg     8006ce <vprintfmt+0x3c7>
	else if (lflag)
  8006a8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8006ac:	74 3e                	je     8006ec <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8b 00                	mov    (%eax),%eax
  8006b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006bb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8d 40 04             	lea    0x4(%eax),%eax
  8006c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006c7:	b8 08 00 00 00       	mov    $0x8,%eax
  8006cc:	eb 6f                	jmp    80073d <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 50 04             	mov    0x4(%eax),%edx
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006d9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 40 08             	lea    0x8(%eax),%eax
  8006e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8006e5:	b8 08 00 00 00       	mov    $0x8,%eax
  8006ea:	eb 51                	jmp    80073d <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8006ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ef:	8b 00                	mov    (%eax),%eax
  8006f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006f9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 40 04             	lea    0x4(%eax),%eax
  800702:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800705:	b8 08 00 00 00       	mov    $0x8,%eax
  80070a:	eb 31                	jmp    80073d <vprintfmt+0x436>
			putch('0', putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	56                   	push   %esi
  800710:	6a 30                	push   $0x30
  800712:	ff d3                	call   *%ebx
			putch('x', putdat);
  800714:	83 c4 08             	add    $0x8,%esp
  800717:	56                   	push   %esi
  800718:	6a 78                	push   $0x78
  80071a:	ff d3                	call   *%ebx
			num = (unsigned long long)
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 00                	mov    (%eax),%eax
  800721:	ba 00 00 00 00       	mov    $0x0,%edx
  800726:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800729:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  80072c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800738:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80073d:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800741:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800744:	89 c1                	mov    %eax,%ecx
  800746:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800749:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80074c:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800751:	89 c2                	mov    %eax,%edx
  800753:	39 c1                	cmp    %eax,%ecx
  800755:	0f 87 85 00 00 00    	ja     8007e0 <vprintfmt+0x4d9>
		tmp /= base;
  80075b:	89 d0                	mov    %edx,%eax
  80075d:	ba 00 00 00 00       	mov    $0x0,%edx
  800762:	f7 f1                	div    %ecx
		len++;
  800764:	83 c7 01             	add    $0x1,%edi
  800767:	eb e8                	jmp    800751 <vprintfmt+0x44a>
	if (lflag >= 2)
  800769:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80076d:	7f 26                	jg     800795 <vprintfmt+0x48e>
	else if (lflag)
  80076f:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800773:	74 3e                	je     8007b3 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8b 00                	mov    (%eax),%eax
  80077a:	ba 00 00 00 00       	mov    $0x0,%edx
  80077f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800782:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8d 40 04             	lea    0x4(%eax),%eax
  80078b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80078e:	b8 10 00 00 00       	mov    $0x10,%eax
  800793:	eb a8                	jmp    80073d <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8b 50 04             	mov    0x4(%eax),%edx
  80079b:	8b 00                	mov    (%eax),%eax
  80079d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8d 40 08             	lea    0x8(%eax),%eax
  8007a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ac:	b8 10 00 00 00       	mov    $0x10,%eax
  8007b1:	eb 8a                	jmp    80073d <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8b 00                	mov    (%eax),%eax
  8007b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8007bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007c0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8d 40 04             	lea    0x4(%eax),%eax
  8007c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007cc:	b8 10 00 00 00       	mov    $0x10,%eax
  8007d1:	e9 67 ff ff ff       	jmp    80073d <vprintfmt+0x436>
			base = 10;
  8007d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007db:	e9 5d ff ff ff       	jmp    80073d <vprintfmt+0x436>
  8007e0:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8007e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e6:	29 f8                	sub    %edi,%eax
  8007e8:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8007ea:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8007ee:	74 15                	je     800805 <vprintfmt+0x4fe>
		while (width > 0) {
  8007f0:	85 ff                	test   %edi,%edi
  8007f2:	7e 48                	jle    80083c <vprintfmt+0x535>
			putch(padc, putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8007fb:	ff d3                	call   *%ebx
			width--;
  8007fd:	83 ef 01             	sub    $0x1,%edi
  800800:	83 c4 10             	add    $0x10,%esp
  800803:	eb eb                	jmp    8007f0 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800805:	83 ec 0c             	sub    $0xc,%esp
  800808:	6a 2d                	push   $0x2d
  80080a:	ff 75 cc             	pushl  -0x34(%ebp)
  80080d:	ff 75 c8             	pushl  -0x38(%ebp)
  800810:	ff 75 d4             	pushl  -0x2c(%ebp)
  800813:	ff 75 d0             	pushl  -0x30(%ebp)
  800816:	89 f2                	mov    %esi,%edx
  800818:	89 d8                	mov    %ebx,%eax
  80081a:	e8 1e fa ff ff       	call   80023d <printnum_helper>
		width -= len;
  80081f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800822:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800825:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800828:	85 ff                	test   %edi,%edi
  80082a:	7e 2e                	jle    80085a <vprintfmt+0x553>
			putch(padc, putdat);
  80082c:	83 ec 08             	sub    $0x8,%esp
  80082f:	56                   	push   %esi
  800830:	6a 20                	push   $0x20
  800832:	ff d3                	call   *%ebx
			width--;
  800834:	83 ef 01             	sub    $0x1,%edi
  800837:	83 c4 10             	add    $0x10,%esp
  80083a:	eb ec                	jmp    800828 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  80083c:	83 ec 0c             	sub    $0xc,%esp
  80083f:	ff 75 e0             	pushl  -0x20(%ebp)
  800842:	ff 75 cc             	pushl  -0x34(%ebp)
  800845:	ff 75 c8             	pushl  -0x38(%ebp)
  800848:	ff 75 d4             	pushl  -0x2c(%ebp)
  80084b:	ff 75 d0             	pushl  -0x30(%ebp)
  80084e:	89 f2                	mov    %esi,%edx
  800850:	89 d8                	mov    %ebx,%eax
  800852:	e8 e6 f9 ff ff       	call   80023d <printnum_helper>
  800857:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  80085a:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80085d:	83 c7 01             	add    $0x1,%edi
  800860:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800864:	83 f8 25             	cmp    $0x25,%eax
  800867:	0f 84 b1 fa ff ff    	je     80031e <vprintfmt+0x17>
			if (ch == '\0')
  80086d:	85 c0                	test   %eax,%eax
  80086f:	0f 84 a1 00 00 00    	je     800916 <vprintfmt+0x60f>
			putch(ch, putdat);
  800875:	83 ec 08             	sub    $0x8,%esp
  800878:	56                   	push   %esi
  800879:	50                   	push   %eax
  80087a:	ff d3                	call   *%ebx
  80087c:	83 c4 10             	add    $0x10,%esp
  80087f:	eb dc                	jmp    80085d <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800881:	8b 45 14             	mov    0x14(%ebp),%eax
  800884:	83 c0 04             	add    $0x4,%eax
  800887:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80088a:	8b 45 14             	mov    0x14(%ebp),%eax
  80088d:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  80088f:	85 ff                	test   %edi,%edi
  800891:	74 15                	je     8008a8 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800893:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800899:	7f 29                	jg     8008c4 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  80089b:	0f b6 06             	movzbl (%esi),%eax
  80089e:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  8008a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8008a6:	eb b2                	jmp    80085a <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  8008a8:	68 ac 13 80 00       	push   $0x8013ac
  8008ad:	68 16 13 80 00       	push   $0x801316
  8008b2:	56                   	push   %esi
  8008b3:	53                   	push   %ebx
  8008b4:	e8 31 fa ff ff       	call   8002ea <printfmt>
  8008b9:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8008bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8008c2:	eb 96                	jmp    80085a <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  8008c4:	68 e4 13 80 00       	push   $0x8013e4
  8008c9:	68 16 13 80 00       	push   $0x801316
  8008ce:	56                   	push   %esi
  8008cf:	53                   	push   %ebx
  8008d0:	e8 15 fa ff ff       	call   8002ea <printfmt>
				*res = -1;
  8008d5:	c6 07 ff             	movb   $0xff,(%edi)
  8008d8:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8008db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008de:	89 45 14             	mov    %eax,0x14(%ebp)
  8008e1:	e9 74 ff ff ff       	jmp    80085a <vprintfmt+0x553>
			putch(ch, putdat);
  8008e6:	83 ec 08             	sub    $0x8,%esp
  8008e9:	56                   	push   %esi
  8008ea:	6a 25                	push   $0x25
  8008ec:	ff d3                	call   *%ebx
			break;
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	e9 64 ff ff ff       	jmp    80085a <vprintfmt+0x553>
			putch('%', putdat);
  8008f6:	83 ec 08             	sub    $0x8,%esp
  8008f9:	56                   	push   %esi
  8008fa:	6a 25                	push   $0x25
  8008fc:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	89 f8                	mov    %edi,%eax
  800903:	eb 03                	jmp    800908 <vprintfmt+0x601>
  800905:	83 e8 01             	sub    $0x1,%eax
  800908:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80090c:	75 f7                	jne    800905 <vprintfmt+0x5fe>
  80090e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800911:	e9 44 ff ff ff       	jmp    80085a <vprintfmt+0x553>
}
  800916:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800919:	5b                   	pop    %ebx
  80091a:	5e                   	pop    %esi
  80091b:	5f                   	pop    %edi
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	83 ec 18             	sub    $0x18,%esp
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80092a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800931:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800934:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80093b:	85 c0                	test   %eax,%eax
  80093d:	74 26                	je     800965 <vsnprintf+0x47>
  80093f:	85 d2                	test   %edx,%edx
  800941:	7e 22                	jle    800965 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800943:	ff 75 14             	pushl  0x14(%ebp)
  800946:	ff 75 10             	pushl  0x10(%ebp)
  800949:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80094c:	50                   	push   %eax
  80094d:	68 cd 02 80 00       	push   $0x8002cd
  800952:	e8 b0 f9 ff ff       	call   800307 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800957:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800960:	83 c4 10             	add    $0x10,%esp
}
  800963:	c9                   	leave  
  800964:	c3                   	ret    
		return -E_INVAL;
  800965:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80096a:	eb f7                	jmp    800963 <vsnprintf+0x45>

0080096c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800972:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800975:	50                   	push   %eax
  800976:	ff 75 10             	pushl  0x10(%ebp)
  800979:	ff 75 0c             	pushl  0xc(%ebp)
  80097c:	ff 75 08             	pushl  0x8(%ebp)
  80097f:	e8 9a ff ff ff       	call   80091e <vsnprintf>
	va_end(ap);

	return rc;
}
  800984:	c9                   	leave  
  800985:	c3                   	ret    

00800986 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80098c:	b8 00 00 00 00       	mov    $0x0,%eax
  800991:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800995:	74 05                	je     80099c <strlen+0x16>
		n++;
  800997:	83 c0 01             	add    $0x1,%eax
  80099a:	eb f5                	jmp    800991 <strlen+0xb>
	return n;
}
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	39 c2                	cmp    %eax,%edx
  8009ae:	74 0d                	je     8009bd <strnlen+0x1f>
  8009b0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009b4:	74 05                	je     8009bb <strnlen+0x1d>
		n++;
  8009b6:	83 c2 01             	add    $0x1,%edx
  8009b9:	eb f1                	jmp    8009ac <strnlen+0xe>
  8009bb:	89 d0                	mov    %edx,%eax
	return n;
}
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	53                   	push   %ebx
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ce:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009d2:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009d5:	83 c2 01             	add    $0x1,%edx
  8009d8:	84 c9                	test   %cl,%cl
  8009da:	75 f2                	jne    8009ce <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009dc:	5b                   	pop    %ebx
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	53                   	push   %ebx
  8009e3:	83 ec 10             	sub    $0x10,%esp
  8009e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e9:	53                   	push   %ebx
  8009ea:	e8 97 ff ff ff       	call   800986 <strlen>
  8009ef:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009f2:	ff 75 0c             	pushl  0xc(%ebp)
  8009f5:	01 d8                	add    %ebx,%eax
  8009f7:	50                   	push   %eax
  8009f8:	e8 c2 ff ff ff       	call   8009bf <strcpy>
	return dst;
}
  8009fd:	89 d8                	mov    %ebx,%eax
  8009ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a02:	c9                   	leave  
  800a03:	c3                   	ret    

00800a04 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a0f:	89 c6                	mov    %eax,%esi
  800a11:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a14:	89 c2                	mov    %eax,%edx
  800a16:	39 f2                	cmp    %esi,%edx
  800a18:	74 11                	je     800a2b <strncpy+0x27>
		*dst++ = *src;
  800a1a:	83 c2 01             	add    $0x1,%edx
  800a1d:	0f b6 19             	movzbl (%ecx),%ebx
  800a20:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a23:	80 fb 01             	cmp    $0x1,%bl
  800a26:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800a29:	eb eb                	jmp    800a16 <strncpy+0x12>
	}
	return ret;
}
  800a2b:	5b                   	pop    %ebx
  800a2c:	5e                   	pop    %esi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	56                   	push   %esi
  800a33:	53                   	push   %ebx
  800a34:	8b 75 08             	mov    0x8(%ebp),%esi
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3a:	8b 55 10             	mov    0x10(%ebp),%edx
  800a3d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a3f:	85 d2                	test   %edx,%edx
  800a41:	74 21                	je     800a64 <strlcpy+0x35>
  800a43:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a47:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800a49:	39 c2                	cmp    %eax,%edx
  800a4b:	74 14                	je     800a61 <strlcpy+0x32>
  800a4d:	0f b6 19             	movzbl (%ecx),%ebx
  800a50:	84 db                	test   %bl,%bl
  800a52:	74 0b                	je     800a5f <strlcpy+0x30>
			*dst++ = *src++;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	83 c2 01             	add    $0x1,%edx
  800a5a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a5d:	eb ea                	jmp    800a49 <strlcpy+0x1a>
  800a5f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a61:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a64:	29 f0                	sub    %esi,%eax
}
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a70:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a73:	0f b6 01             	movzbl (%ecx),%eax
  800a76:	84 c0                	test   %al,%al
  800a78:	74 0c                	je     800a86 <strcmp+0x1c>
  800a7a:	3a 02                	cmp    (%edx),%al
  800a7c:	75 08                	jne    800a86 <strcmp+0x1c>
		p++, q++;
  800a7e:	83 c1 01             	add    $0x1,%ecx
  800a81:	83 c2 01             	add    $0x1,%edx
  800a84:	eb ed                	jmp    800a73 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a86:	0f b6 c0             	movzbl %al,%eax
  800a89:	0f b6 12             	movzbl (%edx),%edx
  800a8c:	29 d0                	sub    %edx,%eax
}
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	53                   	push   %ebx
  800a94:	8b 45 08             	mov    0x8(%ebp),%eax
  800a97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9a:	89 c3                	mov    %eax,%ebx
  800a9c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a9f:	eb 06                	jmp    800aa7 <strncmp+0x17>
		n--, p++, q++;
  800aa1:	83 c0 01             	add    $0x1,%eax
  800aa4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800aa7:	39 d8                	cmp    %ebx,%eax
  800aa9:	74 16                	je     800ac1 <strncmp+0x31>
  800aab:	0f b6 08             	movzbl (%eax),%ecx
  800aae:	84 c9                	test   %cl,%cl
  800ab0:	74 04                	je     800ab6 <strncmp+0x26>
  800ab2:	3a 0a                	cmp    (%edx),%cl
  800ab4:	74 eb                	je     800aa1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab6:	0f b6 00             	movzbl (%eax),%eax
  800ab9:	0f b6 12             	movzbl (%edx),%edx
  800abc:	29 d0                	sub    %edx,%eax
}
  800abe:	5b                   	pop    %ebx
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    
		return 0;
  800ac1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac6:	eb f6                	jmp    800abe <strncmp+0x2e>

00800ac8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad2:	0f b6 10             	movzbl (%eax),%edx
  800ad5:	84 d2                	test   %dl,%dl
  800ad7:	74 09                	je     800ae2 <strchr+0x1a>
		if (*s == c)
  800ad9:	38 ca                	cmp    %cl,%dl
  800adb:	74 0a                	je     800ae7 <strchr+0x1f>
	for (; *s; s++)
  800add:	83 c0 01             	add    $0x1,%eax
  800ae0:	eb f0                	jmp    800ad2 <strchr+0xa>
			return (char *) s;
	return 0;
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae7:	5d                   	pop    %ebp
  800ae8:	c3                   	ret    

00800ae9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
  800aef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800af6:	38 ca                	cmp    %cl,%dl
  800af8:	74 09                	je     800b03 <strfind+0x1a>
  800afa:	84 d2                	test   %dl,%dl
  800afc:	74 05                	je     800b03 <strfind+0x1a>
	for (; *s; s++)
  800afe:	83 c0 01             	add    $0x1,%eax
  800b01:	eb f0                	jmp    800af3 <strfind+0xa>
			break;
	return (char *) s;
}
  800b03:	5d                   	pop    %ebp
  800b04:	c3                   	ret    

00800b05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b05:	55                   	push   %ebp
  800b06:	89 e5                	mov    %esp,%ebp
  800b08:	57                   	push   %edi
  800b09:	56                   	push   %esi
  800b0a:	53                   	push   %ebx
  800b0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b11:	85 c9                	test   %ecx,%ecx
  800b13:	74 31                	je     800b46 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b15:	89 f8                	mov    %edi,%eax
  800b17:	09 c8                	or     %ecx,%eax
  800b19:	a8 03                	test   $0x3,%al
  800b1b:	75 23                	jne    800b40 <memset+0x3b>
		c &= 0xFF;
  800b1d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b21:	89 d3                	mov    %edx,%ebx
  800b23:	c1 e3 08             	shl    $0x8,%ebx
  800b26:	89 d0                	mov    %edx,%eax
  800b28:	c1 e0 18             	shl    $0x18,%eax
  800b2b:	89 d6                	mov    %edx,%esi
  800b2d:	c1 e6 10             	shl    $0x10,%esi
  800b30:	09 f0                	or     %esi,%eax
  800b32:	09 c2                	or     %eax,%edx
  800b34:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b36:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b39:	89 d0                	mov    %edx,%eax
  800b3b:	fc                   	cld    
  800b3c:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3e:	eb 06                	jmp    800b46 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	fc                   	cld    
  800b44:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b46:	89 f8                	mov    %edi,%eax
  800b48:	5b                   	pop    %ebx
  800b49:	5e                   	pop    %esi
  800b4a:	5f                   	pop    %edi
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b5b:	39 c6                	cmp    %eax,%esi
  800b5d:	73 32                	jae    800b91 <memmove+0x44>
  800b5f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b62:	39 c2                	cmp    %eax,%edx
  800b64:	76 2b                	jbe    800b91 <memmove+0x44>
		s += n;
		d += n;
  800b66:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b69:	89 fe                	mov    %edi,%esi
  800b6b:	09 ce                	or     %ecx,%esi
  800b6d:	09 d6                	or     %edx,%esi
  800b6f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b75:	75 0e                	jne    800b85 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b77:	83 ef 04             	sub    $0x4,%edi
  800b7a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b80:	fd                   	std    
  800b81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b83:	eb 09                	jmp    800b8e <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b85:	83 ef 01             	sub    $0x1,%edi
  800b88:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b8b:	fd                   	std    
  800b8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b8e:	fc                   	cld    
  800b8f:	eb 1a                	jmp    800bab <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b91:	89 c2                	mov    %eax,%edx
  800b93:	09 ca                	or     %ecx,%edx
  800b95:	09 f2                	or     %esi,%edx
  800b97:	f6 c2 03             	test   $0x3,%dl
  800b9a:	75 0a                	jne    800ba6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b9c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b9f:	89 c7                	mov    %eax,%edi
  800ba1:	fc                   	cld    
  800ba2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba4:	eb 05                	jmp    800bab <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ba6:	89 c7                	mov    %eax,%edi
  800ba8:	fc                   	cld    
  800ba9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb5:	ff 75 10             	pushl  0x10(%ebp)
  800bb8:	ff 75 0c             	pushl  0xc(%ebp)
  800bbb:	ff 75 08             	pushl  0x8(%ebp)
  800bbe:	e8 8a ff ff ff       	call   800b4d <memmove>
}
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	56                   	push   %esi
  800bc9:	53                   	push   %ebx
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd0:	89 c6                	mov    %eax,%esi
  800bd2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd5:	39 f0                	cmp    %esi,%eax
  800bd7:	74 1c                	je     800bf5 <memcmp+0x30>
		if (*s1 != *s2)
  800bd9:	0f b6 08             	movzbl (%eax),%ecx
  800bdc:	0f b6 1a             	movzbl (%edx),%ebx
  800bdf:	38 d9                	cmp    %bl,%cl
  800be1:	75 08                	jne    800beb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800be3:	83 c0 01             	add    $0x1,%eax
  800be6:	83 c2 01             	add    $0x1,%edx
  800be9:	eb ea                	jmp    800bd5 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800beb:	0f b6 c1             	movzbl %cl,%eax
  800bee:	0f b6 db             	movzbl %bl,%ebx
  800bf1:	29 d8                	sub    %ebx,%eax
  800bf3:	eb 05                	jmp    800bfa <memcmp+0x35>
	}

	return 0;
  800bf5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c07:	89 c2                	mov    %eax,%edx
  800c09:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c0c:	39 d0                	cmp    %edx,%eax
  800c0e:	73 09                	jae    800c19 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c10:	38 08                	cmp    %cl,(%eax)
  800c12:	74 05                	je     800c19 <memfind+0x1b>
	for (; s < ends; s++)
  800c14:	83 c0 01             	add    $0x1,%eax
  800c17:	eb f3                	jmp    800c0c <memfind+0xe>
			break;
	return (void *) s;
}
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c27:	eb 03                	jmp    800c2c <strtol+0x11>
		s++;
  800c29:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c2c:	0f b6 01             	movzbl (%ecx),%eax
  800c2f:	3c 20                	cmp    $0x20,%al
  800c31:	74 f6                	je     800c29 <strtol+0xe>
  800c33:	3c 09                	cmp    $0x9,%al
  800c35:	74 f2                	je     800c29 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c37:	3c 2b                	cmp    $0x2b,%al
  800c39:	74 2a                	je     800c65 <strtol+0x4a>
	int neg = 0;
  800c3b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c40:	3c 2d                	cmp    $0x2d,%al
  800c42:	74 2b                	je     800c6f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c44:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c4a:	75 0f                	jne    800c5b <strtol+0x40>
  800c4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4f:	74 28                	je     800c79 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c51:	85 db                	test   %ebx,%ebx
  800c53:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c58:	0f 44 d8             	cmove  %eax,%ebx
  800c5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c60:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c63:	eb 50                	jmp    800cb5 <strtol+0x9a>
		s++;
  800c65:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c68:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6d:	eb d5                	jmp    800c44 <strtol+0x29>
		s++, neg = 1;
  800c6f:	83 c1 01             	add    $0x1,%ecx
  800c72:	bf 01 00 00 00       	mov    $0x1,%edi
  800c77:	eb cb                	jmp    800c44 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c79:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c7d:	74 0e                	je     800c8d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c7f:	85 db                	test   %ebx,%ebx
  800c81:	75 d8                	jne    800c5b <strtol+0x40>
		s++, base = 8;
  800c83:	83 c1 01             	add    $0x1,%ecx
  800c86:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c8b:	eb ce                	jmp    800c5b <strtol+0x40>
		s += 2, base = 16;
  800c8d:	83 c1 02             	add    $0x2,%ecx
  800c90:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c95:	eb c4                	jmp    800c5b <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800c97:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c9a:	89 f3                	mov    %esi,%ebx
  800c9c:	80 fb 19             	cmp    $0x19,%bl
  800c9f:	77 29                	ja     800cca <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ca1:	0f be d2             	movsbl %dl,%edx
  800ca4:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ca7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800caa:	7d 30                	jge    800cdc <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800cac:	83 c1 01             	add    $0x1,%ecx
  800caf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cb3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800cb5:	0f b6 11             	movzbl (%ecx),%edx
  800cb8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cbb:	89 f3                	mov    %esi,%ebx
  800cbd:	80 fb 09             	cmp    $0x9,%bl
  800cc0:	77 d5                	ja     800c97 <strtol+0x7c>
			dig = *s - '0';
  800cc2:	0f be d2             	movsbl %dl,%edx
  800cc5:	83 ea 30             	sub    $0x30,%edx
  800cc8:	eb dd                	jmp    800ca7 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800cca:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ccd:	89 f3                	mov    %esi,%ebx
  800ccf:	80 fb 19             	cmp    $0x19,%bl
  800cd2:	77 08                	ja     800cdc <strtol+0xc1>
			dig = *s - 'A' + 10;
  800cd4:	0f be d2             	movsbl %dl,%edx
  800cd7:	83 ea 37             	sub    $0x37,%edx
  800cda:	eb cb                	jmp    800ca7 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cdc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce0:	74 05                	je     800ce7 <strtol+0xcc>
		*endptr = (char *) s;
  800ce2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ce7:	89 c2                	mov    %eax,%edx
  800ce9:	f7 da                	neg    %edx
  800ceb:	85 ff                	test   %edi,%edi
  800ced:	0f 45 c2             	cmovne %edx,%eax
}
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cfb:	b8 00 00 00 00       	mov    $0x0,%eax
  800d00:	8b 55 08             	mov    0x8(%ebp),%edx
  800d03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d06:	89 c3                	mov    %eax,%ebx
  800d08:	89 c7                	mov    %eax,%edi
  800d0a:	89 c6                	mov    %eax,%esi
  800d0c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d19:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800d23:	89 d1                	mov    %edx,%ecx
  800d25:	89 d3                	mov    %edx,%ebx
  800d27:	89 d7                	mov    %edx,%edi
  800d29:	89 d6                	mov    %edx,%esi
  800d2b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	b8 03 00 00 00       	mov    $0x3,%eax
  800d48:	89 cb                	mov    %ecx,%ebx
  800d4a:	89 cf                	mov    %ecx,%edi
  800d4c:	89 ce                	mov    %ecx,%esi
  800d4e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d50:	85 c0                	test   %eax,%eax
  800d52:	7f 08                	jg     800d5c <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
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
  800d60:	6a 03                	push   $0x3
  800d62:	68 c4 15 80 00       	push   $0x8015c4
  800d67:	6a 23                	push   $0x23
  800d69:	68 e1 15 80 00       	push   $0x8015e1
  800d6e:	e8 db f3 ff ff       	call   80014e <_panic>

00800d73 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d79:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800d83:	89 d1                	mov    %edx,%ecx
  800d85:	89 d3                	mov    %edx,%ebx
  800d87:	89 d7                	mov    %edx,%edi
  800d89:	89 d6                	mov    %edx,%esi
  800d8b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <sys_yield>:

void
sys_yield(void)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	57                   	push   %edi
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d98:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800da2:	89 d1                	mov    %edx,%ecx
  800da4:	89 d3                	mov    %edx,%ebx
  800da6:	89 d7                	mov    %edx,%edi
  800da8:	89 d6                	mov    %edx,%esi
  800daa:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dac:	5b                   	pop    %ebx
  800dad:	5e                   	pop    %esi
  800dae:	5f                   	pop    %edi
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	57                   	push   %edi
  800db5:	56                   	push   %esi
  800db6:	53                   	push   %ebx
  800db7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dba:	be 00 00 00 00       	mov    $0x0,%esi
  800dbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc5:	b8 04 00 00 00       	mov    $0x4,%eax
  800dca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dcd:	89 f7                	mov    %esi,%edi
  800dcf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	7f 08                	jg     800ddd <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddd:	83 ec 0c             	sub    $0xc,%esp
  800de0:	50                   	push   %eax
  800de1:	6a 04                	push   $0x4
  800de3:	68 c4 15 80 00       	push   $0x8015c4
  800de8:	6a 23                	push   $0x23
  800dea:	68 e1 15 80 00       	push   $0x8015e1
  800def:	e8 5a f3 ff ff       	call   80014e <_panic>

00800df4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
  800dfa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800e00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e03:	b8 05 00 00 00       	mov    $0x5,%eax
  800e08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0e:	8b 75 18             	mov    0x18(%ebp),%esi
  800e11:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e13:	85 c0                	test   %eax,%eax
  800e15:	7f 08                	jg     800e1f <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	50                   	push   %eax
  800e23:	6a 05                	push   $0x5
  800e25:	68 c4 15 80 00       	push   $0x8015c4
  800e2a:	6a 23                	push   $0x23
  800e2c:	68 e1 15 80 00       	push   $0x8015e1
  800e31:	e8 18 f3 ff ff       	call   80014e <_panic>

00800e36 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
  800e3c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e44:	8b 55 08             	mov    0x8(%ebp),%edx
  800e47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e4a:	b8 06 00 00 00       	mov    $0x6,%eax
  800e4f:	89 df                	mov    %ebx,%edi
  800e51:	89 de                	mov    %ebx,%esi
  800e53:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e55:	85 c0                	test   %eax,%eax
  800e57:	7f 08                	jg     800e61 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e61:	83 ec 0c             	sub    $0xc,%esp
  800e64:	50                   	push   %eax
  800e65:	6a 06                	push   $0x6
  800e67:	68 c4 15 80 00       	push   $0x8015c4
  800e6c:	6a 23                	push   $0x23
  800e6e:	68 e1 15 80 00       	push   $0x8015e1
  800e73:	e8 d6 f2 ff ff       	call   80014e <_panic>

00800e78 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	57                   	push   %edi
  800e7c:	56                   	push   %esi
  800e7d:	53                   	push   %ebx
  800e7e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e81:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e86:	8b 55 08             	mov    0x8(%ebp),%edx
  800e89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8c:	b8 08 00 00 00       	mov    $0x8,%eax
  800e91:	89 df                	mov    %ebx,%edi
  800e93:	89 de                	mov    %ebx,%esi
  800e95:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e97:	85 c0                	test   %eax,%eax
  800e99:	7f 08                	jg     800ea3 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea3:	83 ec 0c             	sub    $0xc,%esp
  800ea6:	50                   	push   %eax
  800ea7:	6a 08                	push   $0x8
  800ea9:	68 c4 15 80 00       	push   $0x8015c4
  800eae:	6a 23                	push   $0x23
  800eb0:	68 e1 15 80 00       	push   $0x8015e1
  800eb5:	e8 94 f2 ff ff       	call   80014e <_panic>

00800eba <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
  800ec0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ec3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ece:	b8 09 00 00 00       	mov    $0x9,%eax
  800ed3:	89 df                	mov    %ebx,%edi
  800ed5:	89 de                	mov    %ebx,%esi
  800ed7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	7f 08                	jg     800ee5 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800edd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee5:	83 ec 0c             	sub    $0xc,%esp
  800ee8:	50                   	push   %eax
  800ee9:	6a 09                	push   $0x9
  800eeb:	68 c4 15 80 00       	push   $0x8015c4
  800ef0:	6a 23                	push   $0x23
  800ef2:	68 e1 15 80 00       	push   $0x8015e1
  800ef7:	e8 52 f2 ff ff       	call   80014e <_panic>

00800efc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f02:	8b 55 08             	mov    0x8(%ebp),%edx
  800f05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f08:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f0d:	be 00 00 00 00       	mov    $0x0,%esi
  800f12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f18:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f1a:	5b                   	pop    %ebx
  800f1b:	5e                   	pop    %esi
  800f1c:	5f                   	pop    %edi
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    

00800f1f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	57                   	push   %edi
  800f23:	56                   	push   %esi
  800f24:	53                   	push   %ebx
  800f25:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f30:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f35:	89 cb                	mov    %ecx,%ebx
  800f37:	89 cf                	mov    %ecx,%edi
  800f39:	89 ce                	mov    %ecx,%esi
  800f3b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	7f 08                	jg     800f49 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f49:	83 ec 0c             	sub    $0xc,%esp
  800f4c:	50                   	push   %eax
  800f4d:	6a 0c                	push   $0xc
  800f4f:	68 c4 15 80 00       	push   $0x8015c4
  800f54:	6a 23                	push   $0x23
  800f56:	68 e1 15 80 00       	push   $0x8015e1
  800f5b:	e8 ee f1 ff ff       	call   80014e <_panic>

00800f60 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	57                   	push   %edi
  800f64:	56                   	push   %esi
  800f65:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f66:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f71:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f76:	89 df                	mov    %ebx,%edi
  800f78:	89 de                	mov    %ebx,%esi
  800f7a:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800f7c:	5b                   	pop    %ebx
  800f7d:	5e                   	pop    %esi
  800f7e:	5f                   	pop    %edi
  800f7f:	5d                   	pop    %ebp
  800f80:	c3                   	ret    

00800f81 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	57                   	push   %edi
  800f85:	56                   	push   %esi
  800f86:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f94:	89 cb                	mov    %ecx,%ebx
  800f96:	89 cf                	mov    %ecx,%edi
  800f98:	89 ce                	mov    %ecx,%esi
  800f9a:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800f9c:	5b                   	pop    %ebx
  800f9d:	5e                   	pop    %esi
  800f9e:	5f                   	pop    %edi
  800f9f:	5d                   	pop    %ebp
  800fa0:	c3                   	ret    

00800fa1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  800fa7:	68 fb 15 80 00       	push   $0x8015fb
  800fac:	6a 53                	push   $0x53
  800fae:	68 ef 15 80 00       	push   $0x8015ef
  800fb3:	e8 96 f1 ff ff       	call   80014e <_panic>

00800fb8 <sfork>:
}

// Challenge!
int
sfork(void)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fbe:	68 fa 15 80 00       	push   $0x8015fa
  800fc3:	6a 5a                	push   $0x5a
  800fc5:	68 ef 15 80 00       	push   $0x8015ef
  800fca:	e8 7f f1 ff ff       	call   80014e <_panic>

00800fcf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  800fd5:	68 10 16 80 00       	push   $0x801610
  800fda:	6a 1a                	push   $0x1a
  800fdc:	68 29 16 80 00       	push   $0x801629
  800fe1:	e8 68 f1 ff ff       	call   80014e <_panic>

00800fe6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800fe6:	55                   	push   %ebp
  800fe7:	89 e5                	mov    %esp,%ebp
  800fe9:	83 ec 0c             	sub    $0xc,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  800fec:	68 33 16 80 00       	push   $0x801633
  800ff1:	6a 2a                	push   $0x2a
  800ff3:	68 29 16 80 00       	push   $0x801629
  800ff8:	e8 51 f1 ff ff       	call   80014e <_panic>

00800ffd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801003:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801008:	89 c2                	mov    %eax,%edx
  80100a:	c1 e2 07             	shl    $0x7,%edx
  80100d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801013:	8b 52 50             	mov    0x50(%edx),%edx
  801016:	39 ca                	cmp    %ecx,%edx
  801018:	74 11                	je     80102b <ipc_find_env+0x2e>
	for (i = 0; i < NENV; i++)
  80101a:	83 c0 01             	add    $0x1,%eax
  80101d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801022:	75 e4                	jne    801008 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801024:	b8 00 00 00 00       	mov    $0x0,%eax
  801029:	eb 0b                	jmp    801036 <ipc_find_env+0x39>
			return envs[i].env_id;
  80102b:	c1 e0 07             	shl    $0x7,%eax
  80102e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801033:	8b 40 48             	mov    0x48(%eax),%eax
}
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    
  801038:	66 90                	xchg   %ax,%ax
  80103a:	66 90                	xchg   %ax,%ax
  80103c:	66 90                	xchg   %ax,%ax
  80103e:	66 90                	xchg   %ax,%ax

00801040 <__udivdi3>:
  801040:	55                   	push   %ebp
  801041:	57                   	push   %edi
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
  801044:	83 ec 1c             	sub    $0x1c,%esp
  801047:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80104b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80104f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801053:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801057:	85 d2                	test   %edx,%edx
  801059:	75 4d                	jne    8010a8 <__udivdi3+0x68>
  80105b:	39 f3                	cmp    %esi,%ebx
  80105d:	76 19                	jbe    801078 <__udivdi3+0x38>
  80105f:	31 ff                	xor    %edi,%edi
  801061:	89 e8                	mov    %ebp,%eax
  801063:	89 f2                	mov    %esi,%edx
  801065:	f7 f3                	div    %ebx
  801067:	89 fa                	mov    %edi,%edx
  801069:	83 c4 1c             	add    $0x1c,%esp
  80106c:	5b                   	pop    %ebx
  80106d:	5e                   	pop    %esi
  80106e:	5f                   	pop    %edi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    
  801071:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801078:	89 d9                	mov    %ebx,%ecx
  80107a:	85 db                	test   %ebx,%ebx
  80107c:	75 0b                	jne    801089 <__udivdi3+0x49>
  80107e:	b8 01 00 00 00       	mov    $0x1,%eax
  801083:	31 d2                	xor    %edx,%edx
  801085:	f7 f3                	div    %ebx
  801087:	89 c1                	mov    %eax,%ecx
  801089:	31 d2                	xor    %edx,%edx
  80108b:	89 f0                	mov    %esi,%eax
  80108d:	f7 f1                	div    %ecx
  80108f:	89 c6                	mov    %eax,%esi
  801091:	89 e8                	mov    %ebp,%eax
  801093:	89 f7                	mov    %esi,%edi
  801095:	f7 f1                	div    %ecx
  801097:	89 fa                	mov    %edi,%edx
  801099:	83 c4 1c             	add    $0x1c,%esp
  80109c:	5b                   	pop    %ebx
  80109d:	5e                   	pop    %esi
  80109e:	5f                   	pop    %edi
  80109f:	5d                   	pop    %ebp
  8010a0:	c3                   	ret    
  8010a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010a8:	39 f2                	cmp    %esi,%edx
  8010aa:	77 1c                	ja     8010c8 <__udivdi3+0x88>
  8010ac:	0f bd fa             	bsr    %edx,%edi
  8010af:	83 f7 1f             	xor    $0x1f,%edi
  8010b2:	75 2c                	jne    8010e0 <__udivdi3+0xa0>
  8010b4:	39 f2                	cmp    %esi,%edx
  8010b6:	72 06                	jb     8010be <__udivdi3+0x7e>
  8010b8:	31 c0                	xor    %eax,%eax
  8010ba:	39 eb                	cmp    %ebp,%ebx
  8010bc:	77 a9                	ja     801067 <__udivdi3+0x27>
  8010be:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c3:	eb a2                	jmp    801067 <__udivdi3+0x27>
  8010c5:	8d 76 00             	lea    0x0(%esi),%esi
  8010c8:	31 ff                	xor    %edi,%edi
  8010ca:	31 c0                	xor    %eax,%eax
  8010cc:	89 fa                	mov    %edi,%edx
  8010ce:	83 c4 1c             	add    $0x1c,%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    
  8010d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010dd:	8d 76 00             	lea    0x0(%esi),%esi
  8010e0:	89 f9                	mov    %edi,%ecx
  8010e2:	b8 20 00 00 00       	mov    $0x20,%eax
  8010e7:	29 f8                	sub    %edi,%eax
  8010e9:	d3 e2                	shl    %cl,%edx
  8010eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8010ef:	89 c1                	mov    %eax,%ecx
  8010f1:	89 da                	mov    %ebx,%edx
  8010f3:	d3 ea                	shr    %cl,%edx
  8010f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010f9:	09 d1                	or     %edx,%ecx
  8010fb:	89 f2                	mov    %esi,%edx
  8010fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801101:	89 f9                	mov    %edi,%ecx
  801103:	d3 e3                	shl    %cl,%ebx
  801105:	89 c1                	mov    %eax,%ecx
  801107:	d3 ea                	shr    %cl,%edx
  801109:	89 f9                	mov    %edi,%ecx
  80110b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80110f:	89 eb                	mov    %ebp,%ebx
  801111:	d3 e6                	shl    %cl,%esi
  801113:	89 c1                	mov    %eax,%ecx
  801115:	d3 eb                	shr    %cl,%ebx
  801117:	09 de                	or     %ebx,%esi
  801119:	89 f0                	mov    %esi,%eax
  80111b:	f7 74 24 08          	divl   0x8(%esp)
  80111f:	89 d6                	mov    %edx,%esi
  801121:	89 c3                	mov    %eax,%ebx
  801123:	f7 64 24 0c          	mull   0xc(%esp)
  801127:	39 d6                	cmp    %edx,%esi
  801129:	72 15                	jb     801140 <__udivdi3+0x100>
  80112b:	89 f9                	mov    %edi,%ecx
  80112d:	d3 e5                	shl    %cl,%ebp
  80112f:	39 c5                	cmp    %eax,%ebp
  801131:	73 04                	jae    801137 <__udivdi3+0xf7>
  801133:	39 d6                	cmp    %edx,%esi
  801135:	74 09                	je     801140 <__udivdi3+0x100>
  801137:	89 d8                	mov    %ebx,%eax
  801139:	31 ff                	xor    %edi,%edi
  80113b:	e9 27 ff ff ff       	jmp    801067 <__udivdi3+0x27>
  801140:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801143:	31 ff                	xor    %edi,%edi
  801145:	e9 1d ff ff ff       	jmp    801067 <__udivdi3+0x27>
  80114a:	66 90                	xchg   %ax,%ax
  80114c:	66 90                	xchg   %ax,%ax
  80114e:	66 90                	xchg   %ax,%ax

00801150 <__umoddi3>:
  801150:	55                   	push   %ebp
  801151:	57                   	push   %edi
  801152:	56                   	push   %esi
  801153:	53                   	push   %ebx
  801154:	83 ec 1c             	sub    $0x1c,%esp
  801157:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80115b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80115f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801163:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801167:	89 da                	mov    %ebx,%edx
  801169:	85 c0                	test   %eax,%eax
  80116b:	75 43                	jne    8011b0 <__umoddi3+0x60>
  80116d:	39 df                	cmp    %ebx,%edi
  80116f:	76 17                	jbe    801188 <__umoddi3+0x38>
  801171:	89 f0                	mov    %esi,%eax
  801173:	f7 f7                	div    %edi
  801175:	89 d0                	mov    %edx,%eax
  801177:	31 d2                	xor    %edx,%edx
  801179:	83 c4 1c             	add    $0x1c,%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5f                   	pop    %edi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    
  801181:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801188:	89 fd                	mov    %edi,%ebp
  80118a:	85 ff                	test   %edi,%edi
  80118c:	75 0b                	jne    801199 <__umoddi3+0x49>
  80118e:	b8 01 00 00 00       	mov    $0x1,%eax
  801193:	31 d2                	xor    %edx,%edx
  801195:	f7 f7                	div    %edi
  801197:	89 c5                	mov    %eax,%ebp
  801199:	89 d8                	mov    %ebx,%eax
  80119b:	31 d2                	xor    %edx,%edx
  80119d:	f7 f5                	div    %ebp
  80119f:	89 f0                	mov    %esi,%eax
  8011a1:	f7 f5                	div    %ebp
  8011a3:	89 d0                	mov    %edx,%eax
  8011a5:	eb d0                	jmp    801177 <__umoddi3+0x27>
  8011a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011ae:	66 90                	xchg   %ax,%ax
  8011b0:	89 f1                	mov    %esi,%ecx
  8011b2:	39 d8                	cmp    %ebx,%eax
  8011b4:	76 0a                	jbe    8011c0 <__umoddi3+0x70>
  8011b6:	89 f0                	mov    %esi,%eax
  8011b8:	83 c4 1c             	add    $0x1c,%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    
  8011c0:	0f bd e8             	bsr    %eax,%ebp
  8011c3:	83 f5 1f             	xor    $0x1f,%ebp
  8011c6:	75 20                	jne    8011e8 <__umoddi3+0x98>
  8011c8:	39 d8                	cmp    %ebx,%eax
  8011ca:	0f 82 b0 00 00 00    	jb     801280 <__umoddi3+0x130>
  8011d0:	39 f7                	cmp    %esi,%edi
  8011d2:	0f 86 a8 00 00 00    	jbe    801280 <__umoddi3+0x130>
  8011d8:	89 c8                	mov    %ecx,%eax
  8011da:	83 c4 1c             	add    $0x1c,%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    
  8011e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011e8:	89 e9                	mov    %ebp,%ecx
  8011ea:	ba 20 00 00 00       	mov    $0x20,%edx
  8011ef:	29 ea                	sub    %ebp,%edx
  8011f1:	d3 e0                	shl    %cl,%eax
  8011f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f7:	89 d1                	mov    %edx,%ecx
  8011f9:	89 f8                	mov    %edi,%eax
  8011fb:	d3 e8                	shr    %cl,%eax
  8011fd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801201:	89 54 24 04          	mov    %edx,0x4(%esp)
  801205:	8b 54 24 04          	mov    0x4(%esp),%edx
  801209:	09 c1                	or     %eax,%ecx
  80120b:	89 d8                	mov    %ebx,%eax
  80120d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801211:	89 e9                	mov    %ebp,%ecx
  801213:	d3 e7                	shl    %cl,%edi
  801215:	89 d1                	mov    %edx,%ecx
  801217:	d3 e8                	shr    %cl,%eax
  801219:	89 e9                	mov    %ebp,%ecx
  80121b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80121f:	d3 e3                	shl    %cl,%ebx
  801221:	89 c7                	mov    %eax,%edi
  801223:	89 d1                	mov    %edx,%ecx
  801225:	89 f0                	mov    %esi,%eax
  801227:	d3 e8                	shr    %cl,%eax
  801229:	89 e9                	mov    %ebp,%ecx
  80122b:	89 fa                	mov    %edi,%edx
  80122d:	d3 e6                	shl    %cl,%esi
  80122f:	09 d8                	or     %ebx,%eax
  801231:	f7 74 24 08          	divl   0x8(%esp)
  801235:	89 d1                	mov    %edx,%ecx
  801237:	89 f3                	mov    %esi,%ebx
  801239:	f7 64 24 0c          	mull   0xc(%esp)
  80123d:	89 c6                	mov    %eax,%esi
  80123f:	89 d7                	mov    %edx,%edi
  801241:	39 d1                	cmp    %edx,%ecx
  801243:	72 06                	jb     80124b <__umoddi3+0xfb>
  801245:	75 10                	jne    801257 <__umoddi3+0x107>
  801247:	39 c3                	cmp    %eax,%ebx
  801249:	73 0c                	jae    801257 <__umoddi3+0x107>
  80124b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80124f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801253:	89 d7                	mov    %edx,%edi
  801255:	89 c6                	mov    %eax,%esi
  801257:	89 ca                	mov    %ecx,%edx
  801259:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80125e:	29 f3                	sub    %esi,%ebx
  801260:	19 fa                	sbb    %edi,%edx
  801262:	89 d0                	mov    %edx,%eax
  801264:	d3 e0                	shl    %cl,%eax
  801266:	89 e9                	mov    %ebp,%ecx
  801268:	d3 eb                	shr    %cl,%ebx
  80126a:	d3 ea                	shr    %cl,%edx
  80126c:	09 d8                	or     %ebx,%eax
  80126e:	83 c4 1c             	add    $0x1c,%esp
  801271:	5b                   	pop    %ebx
  801272:	5e                   	pop    %esi
  801273:	5f                   	pop    %edi
  801274:	5d                   	pop    %ebp
  801275:	c3                   	ret    
  801276:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80127d:	8d 76 00             	lea    0x0(%esi),%esi
  801280:	89 da                	mov    %ebx,%edx
  801282:	29 fe                	sub    %edi,%esi
  801284:	19 c2                	sbb    %eax,%edx
  801286:	89 f1                	mov    %esi,%ecx
  801288:	89 c8                	mov    %ecx,%eax
  80128a:	e9 4b ff ff ff       	jmp    8011da <__umoddi3+0x8a>
