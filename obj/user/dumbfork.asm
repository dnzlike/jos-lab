
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 a1 01 00 00       	call   8001d2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 43 0e 00 00       	call   800e8d <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	78 4a                	js     80009b <duppage+0x68>
		panic("sys_page_alloc: %e", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800051:	83 ec 0c             	sub    $0xc,%esp
  800054:	6a 07                	push   $0x7
  800056:	68 00 00 40 00       	push   $0x400000
  80005b:	6a 00                	push   $0x0
  80005d:	53                   	push   %ebx
  80005e:	56                   	push   %esi
  80005f:	e8 6c 0e 00 00       	call   800ed0 <sys_page_map>
  800064:	83 c4 20             	add    $0x20,%esp
  800067:	85 c0                	test   %eax,%eax
  800069:	78 42                	js     8000ad <duppage+0x7a>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006b:	83 ec 04             	sub    $0x4,%esp
  80006e:	68 00 10 00 00       	push   $0x1000
  800073:	53                   	push   %ebx
  800074:	68 00 00 40 00       	push   $0x400000
  800079:	e8 ab 0b 00 00       	call   800c29 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80007e:	83 c4 08             	add    $0x8,%esp
  800081:	68 00 00 40 00       	push   $0x400000
  800086:	6a 00                	push   $0x0
  800088:	e8 85 0e 00 00       	call   800f12 <sys_page_unmap>
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	85 c0                	test   %eax,%eax
  800092:	78 2b                	js     8000bf <duppage+0x8c>
		panic("sys_page_unmap: %e", r);
}
  800094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80009b:	50                   	push   %eax
  80009c:	68 e0 12 80 00       	push   $0x8012e0
  8000a1:	6a 20                	push   $0x20
  8000a3:	68 f3 12 80 00       	push   $0x8012f3
  8000a8:	e8 7d 01 00 00       	call   80022a <_panic>
		panic("sys_page_map: %e", r);
  8000ad:	50                   	push   %eax
  8000ae:	68 03 13 80 00       	push   $0x801303
  8000b3:	6a 22                	push   $0x22
  8000b5:	68 f3 12 80 00       	push   $0x8012f3
  8000ba:	e8 6b 01 00 00       	call   80022a <_panic>
		panic("sys_page_unmap: %e", r);
  8000bf:	50                   	push   %eax
  8000c0:	68 14 13 80 00       	push   $0x801314
  8000c5:	6a 25                	push   $0x25
  8000c7:	68 f3 12 80 00       	push   $0x8012f3
  8000cc:	e8 59 01 00 00       	call   80022a <_panic>

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	78 2c                	js     800112 <dumbfork+0x41>
  8000e6:	89 c6                	mov    %eax,%esi
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8000e8:	74 3a                	je     800124 <dumbfork+0x53>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8000ea:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  8000f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8000f4:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
  8000fa:	73 41                	jae    80013d <dumbfork+0x6c>
		duppage(envid, addr);
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	52                   	push   %edx
  800100:	56                   	push   %esi
  800101:	e8 2d ff ff ff       	call   800033 <duppage>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800106:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  80010d:	83 c4 10             	add    $0x10,%esp
  800110:	eb df                	jmp    8000f1 <dumbfork+0x20>
		panic("sys_exofork: %e", envid);
  800112:	50                   	push   %eax
  800113:	68 27 13 80 00       	push   $0x801327
  800118:	6a 37                	push   $0x37
  80011a:	68 f3 12 80 00       	push   $0x8012f3
  80011f:	e8 06 01 00 00       	call   80022a <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  800124:	e8 26 0d 00 00       	call   800e4f <sys_getenvid>
  800129:	25 ff 03 00 00       	and    $0x3ff,%eax
  80012e:	c1 e0 07             	shl    $0x7,%eax
  800131:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800136:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  80013b:	eb 24                	jmp    800161 <dumbfork+0x90>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800148:	50                   	push   %eax
  800149:	53                   	push   %ebx
  80014a:	e8 e4 fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80014f:	83 c4 08             	add    $0x8,%esp
  800152:	6a 02                	push   $0x2
  800154:	53                   	push   %ebx
  800155:	e8 fa 0d 00 00       	call   800f54 <sys_env_set_status>
  80015a:	83 c4 10             	add    $0x10,%esp
  80015d:	85 c0                	test   %eax,%eax
  80015f:	78 09                	js     80016a <dumbfork+0x99>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  800161:	89 d8                	mov    %ebx,%eax
  800163:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800166:	5b                   	pop    %ebx
  800167:	5e                   	pop    %esi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  80016a:	50                   	push   %eax
  80016b:	68 37 13 80 00       	push   $0x801337
  800170:	6a 4c                	push   $0x4c
  800172:	68 f3 12 80 00       	push   $0x8012f3
  800177:	e8 ae 00 00 00       	call   80022a <_panic>

0080017c <umain>:
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	57                   	push   %edi
  800180:	56                   	push   %esi
  800181:	53                   	push   %ebx
  800182:	83 ec 0c             	sub    $0xc,%esp
	who = dumbfork();
  800185:	e8 47 ff ff ff       	call   8000d1 <dumbfork>
  80018a:	89 c7                	mov    %eax,%edi
  80018c:	85 c0                	test   %eax,%eax
  80018e:	be 4e 13 80 00       	mov    $0x80134e,%esi
  800193:	b8 55 13 80 00       	mov    $0x801355,%eax
  800198:	0f 44 f0             	cmove  %eax,%esi
	for (i = 0; i < (who ? 10 : 20); i++) {
  80019b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a0:	eb 1f                	jmp    8001c1 <umain+0x45>
  8001a2:	83 fb 13             	cmp    $0x13,%ebx
  8001a5:	7f 23                	jg     8001ca <umain+0x4e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a7:	83 ec 04             	sub    $0x4,%esp
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	68 5b 13 80 00       	push   $0x80135b
  8001b1:	e8 4f 01 00 00       	call   800305 <cprintf>
		sys_yield();
  8001b6:	e8 b3 0c 00 00       	call   800e6e <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bb:	83 c3 01             	add    $0x1,%ebx
  8001be:	83 c4 10             	add    $0x10,%esp
  8001c1:	85 ff                	test   %edi,%edi
  8001c3:	74 dd                	je     8001a2 <umain+0x26>
  8001c5:	83 fb 09             	cmp    $0x9,%ebx
  8001c8:	7e dd                	jle    8001a7 <umain+0x2b>
}
  8001ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cd:	5b                   	pop    %ebx
  8001ce:	5e                   	pop    %esi
  8001cf:	5f                   	pop    %edi
  8001d0:	5d                   	pop    %ebp
  8001d1:	c3                   	ret    

008001d2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001da:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001dd:	e8 6d 0c 00 00       	call   800e4f <sys_getenvid>
  8001e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e7:	c1 e0 07             	shl    $0x7,%eax
  8001ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ef:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f4:	85 db                	test   %ebx,%ebx
  8001f6:	7e 07                	jle    8001ff <libmain+0x2d>
		binaryname = argv[0];
  8001f8:	8b 06                	mov    (%esi),%eax
  8001fa:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8001ff:	83 ec 08             	sub    $0x8,%esp
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	e8 73 ff ff ff       	call   80017c <umain>

	// exit gracefully
	exit();
  800209:	e8 0a 00 00 00       	call   800218 <exit>
}
  80020e:	83 c4 10             	add    $0x10,%esp
  800211:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    

00800218 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80021e:	6a 00                	push   $0x0
  800220:	e8 e9 0b 00 00       	call   800e0e <sys_env_destroy>
}
  800225:	83 c4 10             	add    $0x10,%esp
  800228:	c9                   	leave  
  800229:	c3                   	ret    

0080022a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80022f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800232:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800238:	e8 12 0c 00 00       	call   800e4f <sys_getenvid>
  80023d:	83 ec 0c             	sub    $0xc,%esp
  800240:	ff 75 0c             	pushl  0xc(%ebp)
  800243:	ff 75 08             	pushl  0x8(%ebp)
  800246:	56                   	push   %esi
  800247:	50                   	push   %eax
  800248:	68 78 13 80 00       	push   $0x801378
  80024d:	e8 b3 00 00 00       	call   800305 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800252:	83 c4 18             	add    $0x18,%esp
  800255:	53                   	push   %ebx
  800256:	ff 75 10             	pushl  0x10(%ebp)
  800259:	e8 56 00 00 00       	call   8002b4 <vcprintf>
	cprintf("\n");
  80025e:	c7 04 24 6b 13 80 00 	movl   $0x80136b,(%esp)
  800265:	e8 9b 00 00 00       	call   800305 <cprintf>
  80026a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026d:	cc                   	int3   
  80026e:	eb fd                	jmp    80026d <_panic+0x43>

00800270 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	53                   	push   %ebx
  800274:	83 ec 04             	sub    $0x4,%esp
  800277:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027a:	8b 13                	mov    (%ebx),%edx
  80027c:	8d 42 01             	lea    0x1(%edx),%eax
  80027f:	89 03                	mov    %eax,(%ebx)
  800281:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800284:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800288:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028d:	74 09                	je     800298 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80028f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800293:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800296:	c9                   	leave  
  800297:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	68 ff 00 00 00       	push   $0xff
  8002a0:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 28 0b 00 00       	call   800dd1 <sys_cputs>
		b->idx = 0;
  8002a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002af:	83 c4 10             	add    $0x10,%esp
  8002b2:	eb db                	jmp    80028f <putch+0x1f>

008002b4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002bd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c4:	00 00 00 
	b.cnt = 0;
  8002c7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ce:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d1:	ff 75 0c             	pushl  0xc(%ebp)
  8002d4:	ff 75 08             	pushl  0x8(%ebp)
  8002d7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002dd:	50                   	push   %eax
  8002de:	68 70 02 80 00       	push   $0x800270
  8002e3:	e8 fb 00 00 00       	call   8003e3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002e8:	83 c4 08             	add    $0x8,%esp
  8002eb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f7:	50                   	push   %eax
  8002f8:	e8 d4 0a 00 00       	call   800dd1 <sys_cputs>

	return b.cnt;
}
  8002fd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80030e:	50                   	push   %eax
  80030f:	ff 75 08             	pushl  0x8(%ebp)
  800312:	e8 9d ff ff ff       	call   8002b4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
  80031f:	83 ec 1c             	sub    $0x1c,%esp
  800322:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800325:	89 d3                	mov    %edx,%ebx
  800327:	8b 75 08             	mov    0x8(%ebp),%esi
  80032a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80032d:	8b 45 10             	mov    0x10(%ebp),%eax
  800330:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800333:	89 c2                	mov    %eax,%edx
  800335:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80033d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800340:	39 c6                	cmp    %eax,%esi
  800342:	89 f8                	mov    %edi,%eax
  800344:	19 c8                	sbb    %ecx,%eax
  800346:	73 32                	jae    80037a <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800348:	83 ec 08             	sub    $0x8,%esp
  80034b:	53                   	push   %ebx
  80034c:	83 ec 04             	sub    $0x4,%esp
  80034f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800352:	ff 75 e0             	pushl  -0x20(%ebp)
  800355:	57                   	push   %edi
  800356:	56                   	push   %esi
  800357:	e8 34 0e 00 00       	call   801190 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 9b 13 80 00 	movsbl 0x80139b(%eax),%eax
  800366:	50                   	push   %eax
  800367:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036a:	ff d0                	call   *%eax
	return remain - 1;
  80036c:	8b 45 14             	mov    0x14(%ebp),%eax
  80036f:	83 e8 01             	sub    $0x1,%eax
}
  800372:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  80037a:	83 ec 0c             	sub    $0xc,%esp
  80037d:	ff 75 18             	pushl  0x18(%ebp)
  800380:	ff 75 14             	pushl  0x14(%ebp)
  800383:	ff 75 d8             	pushl  -0x28(%ebp)
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	51                   	push   %ecx
  80038a:	52                   	push   %edx
  80038b:	57                   	push   %edi
  80038c:	56                   	push   %esi
  80038d:	e8 ee 0c 00 00       	call   801080 <__udivdi3>
  800392:	83 c4 18             	add    $0x18,%esp
  800395:	52                   	push   %edx
  800396:	50                   	push   %eax
  800397:	89 da                	mov    %ebx,%edx
  800399:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80039c:	e8 78 ff ff ff       	call   800319 <printnum_helper>
  8003a1:	89 45 14             	mov    %eax,0x14(%ebp)
  8003a4:	83 c4 20             	add    $0x20,%esp
  8003a7:	eb 9f                	jmp    800348 <printnum_helper+0x2f>

008003a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003af:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b3:	8b 10                	mov    (%eax),%edx
  8003b5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003b8:	73 0a                	jae    8003c4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003ba:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003bd:	89 08                	mov    %ecx,(%eax)
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c2:	88 02                	mov    %al,(%edx)
}
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    

008003c6 <printfmt>:
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003cc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003cf:	50                   	push   %eax
  8003d0:	ff 75 10             	pushl  0x10(%ebp)
  8003d3:	ff 75 0c             	pushl  0xc(%ebp)
  8003d6:	ff 75 08             	pushl  0x8(%ebp)
  8003d9:	e8 05 00 00 00       	call   8003e3 <vprintfmt>
}
  8003de:	83 c4 10             	add    $0x10,%esp
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    

008003e3 <vprintfmt>:
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	57                   	push   %edi
  8003e7:	56                   	push   %esi
  8003e8:	53                   	push   %ebx
  8003e9:	83 ec 3c             	sub    $0x3c,%esp
  8003ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003f2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003f5:	e9 3f 05 00 00       	jmp    800939 <vprintfmt+0x556>
		padc = ' ';
  8003fa:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  8003fe:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800405:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  80040c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800413:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  80041a:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800421:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8d 47 01             	lea    0x1(%edi),%eax
  800429:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80042c:	0f b6 17             	movzbl (%edi),%edx
  80042f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800432:	3c 55                	cmp    $0x55,%al
  800434:	0f 87 98 05 00 00    	ja     8009d2 <vprintfmt+0x5ef>
  80043a:	0f b6 c0             	movzbl %al,%eax
  80043d:	ff 24 85 e0 14 80 00 	jmp    *0x8014e0(,%eax,4)
  800444:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  800447:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80044b:	eb d9                	jmp    800426 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800450:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  800457:	eb cd                	jmp    800426 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800459:	0f b6 d2             	movzbl %dl,%edx
  80045c:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80045f:	b8 00 00 00 00       	mov    $0x0,%eax
  800464:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  800467:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80046a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80046e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800471:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800474:	83 fb 09             	cmp    $0x9,%ebx
  800477:	77 5c                	ja     8004d5 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  800479:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80047c:	eb e9                	jmp    800467 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  800481:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  800485:	eb 9f                	jmp    800426 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  800487:	8b 45 14             	mov    0x14(%ebp),%eax
  80048a:	8b 00                	mov    (%eax),%eax
  80048c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048f:	8b 45 14             	mov    0x14(%ebp),%eax
  800492:	8d 40 04             	lea    0x4(%eax),%eax
  800495:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  80049b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80049f:	79 85                	jns    800426 <vprintfmt+0x43>
				width = precision, precision = -1;
  8004a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004ae:	e9 73 ff ff ff       	jmp    800426 <vprintfmt+0x43>
  8004b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	0f 48 c1             	cmovs  %ecx,%eax
  8004bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004be:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8004c1:	e9 60 ff ff ff       	jmp    800426 <vprintfmt+0x43>
  8004c6:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8004c9:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004d0:	e9 51 ff ff ff       	jmp    800426 <vprintfmt+0x43>
  8004d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004db:	eb be                	jmp    80049b <vprintfmt+0xb8>
			lflag++;
  8004dd:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  8004e4:	e9 3d ff ff ff       	jmp    800426 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8d 78 04             	lea    0x4(%eax),%edi
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	56                   	push   %esi
  8004f3:	ff 30                	pushl  (%eax)
  8004f5:	ff d3                	call   *%ebx
			break;
  8004f7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004fa:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8004fd:	e9 34 04 00 00       	jmp    800936 <vprintfmt+0x553>
			err = va_arg(ap, int);
  800502:	8b 45 14             	mov    0x14(%ebp),%eax
  800505:	8d 78 04             	lea    0x4(%eax),%edi
  800508:	8b 00                	mov    (%eax),%eax
  80050a:	99                   	cltd   
  80050b:	31 d0                	xor    %edx,%eax
  80050d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050f:	83 f8 08             	cmp    $0x8,%eax
  800512:	7f 23                	jg     800537 <vprintfmt+0x154>
  800514:	8b 14 85 40 16 80 00 	mov    0x801640(,%eax,4),%edx
  80051b:	85 d2                	test   %edx,%edx
  80051d:	74 18                	je     800537 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  80051f:	52                   	push   %edx
  800520:	68 bc 13 80 00       	push   $0x8013bc
  800525:	56                   	push   %esi
  800526:	53                   	push   %ebx
  800527:	e8 9a fe ff ff       	call   8003c6 <printfmt>
  80052c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80052f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800532:	e9 ff 03 00 00       	jmp    800936 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  800537:	50                   	push   %eax
  800538:	68 b3 13 80 00       	push   $0x8013b3
  80053d:	56                   	push   %esi
  80053e:	53                   	push   %ebx
  80053f:	e8 82 fe ff ff       	call   8003c6 <printfmt>
  800544:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800547:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80054a:	e9 e7 03 00 00       	jmp    800936 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	83 c0 04             	add    $0x4,%eax
  800555:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80055d:	85 c9                	test   %ecx,%ecx
  80055f:	b8 ac 13 80 00       	mov    $0x8013ac,%eax
  800564:	0f 45 c1             	cmovne %ecx,%eax
  800567:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80056a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80056e:	7e 06                	jle    800576 <vprintfmt+0x193>
  800570:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800574:	75 0d                	jne    800583 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800576:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800579:	89 c7                	mov    %eax,%edi
  80057b:	03 45 d8             	add    -0x28(%ebp),%eax
  80057e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800581:	eb 53                	jmp    8005d6 <vprintfmt+0x1f3>
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	ff 75 e0             	pushl  -0x20(%ebp)
  800589:	50                   	push   %eax
  80058a:	e8 eb 04 00 00       	call   800a7a <strnlen>
  80058f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800592:	29 c1                	sub    %eax,%ecx
  800594:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80059c:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8005a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a3:	eb 0f                	jmp    8005b4 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	56                   	push   %esi
  8005a9:	ff 75 d8             	pushl  -0x28(%ebp)
  8005ac:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ae:	83 ef 01             	sub    $0x1,%edi
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	85 ff                	test   %edi,%edi
  8005b6:	7f ed                	jg     8005a5 <vprintfmt+0x1c2>
  8005b8:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8005bb:	85 c9                	test   %ecx,%ecx
  8005bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8005c2:	0f 49 c1             	cmovns %ecx,%eax
  8005c5:	29 c1                	sub    %eax,%ecx
  8005c7:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8005ca:	eb aa                	jmp    800576 <vprintfmt+0x193>
					putch(ch, putdat);
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	56                   	push   %esi
  8005d0:	52                   	push   %edx
  8005d1:	ff d3                	call   *%ebx
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8005d9:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005db:	83 c7 01             	add    $0x1,%edi
  8005de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e2:	0f be d0             	movsbl %al,%edx
  8005e5:	85 d2                	test   %edx,%edx
  8005e7:	74 2e                	je     800617 <vprintfmt+0x234>
  8005e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ed:	78 06                	js     8005f5 <vprintfmt+0x212>
  8005ef:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  8005f3:	78 1e                	js     800613 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  8005f5:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005f9:	74 d1                	je     8005cc <vprintfmt+0x1e9>
  8005fb:	0f be c0             	movsbl %al,%eax
  8005fe:	83 e8 20             	sub    $0x20,%eax
  800601:	83 f8 5e             	cmp    $0x5e,%eax
  800604:	76 c6                	jbe    8005cc <vprintfmt+0x1e9>
					putch('?', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	56                   	push   %esi
  80060a:	6a 3f                	push   $0x3f
  80060c:	ff d3                	call   *%ebx
  80060e:	83 c4 10             	add    $0x10,%esp
  800611:	eb c3                	jmp    8005d6 <vprintfmt+0x1f3>
  800613:	89 cf                	mov    %ecx,%edi
  800615:	eb 02                	jmp    800619 <vprintfmt+0x236>
  800617:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  800619:	85 ff                	test   %edi,%edi
  80061b:	7e 10                	jle    80062d <vprintfmt+0x24a>
				putch(' ', putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	56                   	push   %esi
  800621:	6a 20                	push   $0x20
  800623:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800625:	83 ef 01             	sub    $0x1,%edi
  800628:	83 c4 10             	add    $0x10,%esp
  80062b:	eb ec                	jmp    800619 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  80062d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800630:	89 45 14             	mov    %eax,0x14(%ebp)
  800633:	e9 fe 02 00 00       	jmp    800936 <vprintfmt+0x553>
	if (lflag >= 2)
  800638:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80063c:	7f 21                	jg     80065f <vprintfmt+0x27c>
	else if (lflag)
  80063e:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800642:	74 79                	je     8006bd <vprintfmt+0x2da>
		return va_arg(*ap, long);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8b 00                	mov    (%eax),%eax
  800649:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80064c:	89 c1                	mov    %eax,%ecx
  80064e:	c1 f9 1f             	sar    $0x1f,%ecx
  800651:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8d 40 04             	lea    0x4(%eax),%eax
  80065a:	89 45 14             	mov    %eax,0x14(%ebp)
  80065d:	eb 17                	jmp    800676 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8b 50 04             	mov    0x4(%eax),%edx
  800665:	8b 00                	mov    (%eax),%eax
  800667:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80066a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80066d:	8b 45 14             	mov    0x14(%ebp),%eax
  800670:	8d 40 08             	lea    0x8(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  800676:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800679:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80067c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80067f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  800682:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800686:	78 50                	js     8006d8 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  800688:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80068b:	c1 fa 1f             	sar    $0x1f,%edx
  80068e:	89 d0                	mov    %edx,%eax
  800690:	2b 45 e0             	sub    -0x20(%ebp),%eax
  800693:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  800696:	85 d2                	test   %edx,%edx
  800698:	0f 89 14 02 00 00    	jns    8008b2 <vprintfmt+0x4cf>
  80069e:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006a2:	0f 84 0a 02 00 00    	je     8008b2 <vprintfmt+0x4cf>
				putch('+', putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	56                   	push   %esi
  8006ac:	6a 2b                	push   $0x2b
  8006ae:	ff d3                	call   *%ebx
  8006b0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006b8:	e9 5c 01 00 00       	jmp    800819 <vprintfmt+0x436>
		return va_arg(*ap, int);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 00                	mov    (%eax),%eax
  8006c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006c5:	89 c1                	mov    %eax,%ecx
  8006c7:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8d 40 04             	lea    0x4(%eax),%eax
  8006d3:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d6:	eb 9e                	jmp    800676 <vprintfmt+0x293>
				putch('-', putdat);
  8006d8:	83 ec 08             	sub    $0x8,%esp
  8006db:	56                   	push   %esi
  8006dc:	6a 2d                	push   $0x2d
  8006de:	ff d3                	call   *%ebx
				num = -(long long) num;
  8006e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e6:	f7 d8                	neg    %eax
  8006e8:	83 d2 00             	adc    $0x0,%edx
  8006eb:	f7 da                	neg    %edx
  8006ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8006f3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fb:	e9 19 01 00 00       	jmp    800819 <vprintfmt+0x436>
	if (lflag >= 2)
  800700:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800704:	7f 29                	jg     80072f <vprintfmt+0x34c>
	else if (lflag)
  800706:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80070a:	74 44                	je     800750 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	ba 00 00 00 00       	mov    $0x0,%edx
  800716:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800719:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8d 40 04             	lea    0x4(%eax),%eax
  800722:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800725:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072a:	e9 ea 00 00 00       	jmp    800819 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8b 50 04             	mov    0x4(%eax),%edx
  800735:	8b 00                	mov    (%eax),%eax
  800737:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80073a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8d 40 08             	lea    0x8(%eax),%eax
  800743:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800746:	b8 0a 00 00 00       	mov    $0xa,%eax
  80074b:	e9 c9 00 00 00       	jmp    800819 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8b 00                	mov    (%eax),%eax
  800755:	ba 00 00 00 00       	mov    $0x0,%edx
  80075a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80075d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8d 40 04             	lea    0x4(%eax),%eax
  800766:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800769:	b8 0a 00 00 00       	mov    $0xa,%eax
  80076e:	e9 a6 00 00 00       	jmp    800819 <vprintfmt+0x436>
			putch('0', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	56                   	push   %esi
  800777:	6a 30                	push   $0x30
  800779:	ff d3                	call   *%ebx
	if (lflag >= 2)
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800782:	7f 26                	jg     8007aa <vprintfmt+0x3c7>
	else if (lflag)
  800784:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800788:	74 3e                	je     8007c8 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	8b 00                	mov    (%eax),%eax
  80078f:	ba 00 00 00 00       	mov    $0x0,%edx
  800794:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800797:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8d 40 04             	lea    0x4(%eax),%eax
  8007a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8007a3:	b8 08 00 00 00       	mov    $0x8,%eax
  8007a8:	eb 6f                	jmp    800819 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8b 50 04             	mov    0x4(%eax),%edx
  8007b0:	8b 00                	mov    (%eax),%eax
  8007b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007b5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8d 40 08             	lea    0x8(%eax),%eax
  8007be:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8007c1:	b8 08 00 00 00       	mov    $0x8,%eax
  8007c6:	eb 51                	jmp    800819 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8b 00                	mov    (%eax),%eax
  8007cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007d5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8d 40 04             	lea    0x4(%eax),%eax
  8007de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8007e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8007e6:	eb 31                	jmp    800819 <vprintfmt+0x436>
			putch('0', putdat);
  8007e8:	83 ec 08             	sub    $0x8,%esp
  8007eb:	56                   	push   %esi
  8007ec:	6a 30                	push   $0x30
  8007ee:	ff d3                	call   *%ebx
			putch('x', putdat);
  8007f0:	83 c4 08             	add    $0x8,%esp
  8007f3:	56                   	push   %esi
  8007f4:	6a 78                	push   $0x78
  8007f6:	ff d3                	call   *%ebx
			num = (unsigned long long)
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8b 00                	mov    (%eax),%eax
  8007fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800802:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800805:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800808:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 40 04             	lea    0x4(%eax),%eax
  800811:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800814:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800819:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  80081d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800820:	89 c1                	mov    %eax,%ecx
  800822:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800825:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800828:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  80082d:	89 c2                	mov    %eax,%edx
  80082f:	39 c1                	cmp    %eax,%ecx
  800831:	0f 87 85 00 00 00    	ja     8008bc <vprintfmt+0x4d9>
		tmp /= base;
  800837:	89 d0                	mov    %edx,%eax
  800839:	ba 00 00 00 00       	mov    $0x0,%edx
  80083e:	f7 f1                	div    %ecx
		len++;
  800840:	83 c7 01             	add    $0x1,%edi
  800843:	eb e8                	jmp    80082d <vprintfmt+0x44a>
	if (lflag >= 2)
  800845:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800849:	7f 26                	jg     800871 <vprintfmt+0x48e>
	else if (lflag)
  80084b:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80084f:	74 3e                	je     80088f <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8b 00                	mov    (%eax),%eax
  800856:	ba 00 00 00 00       	mov    $0x0,%edx
  80085b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80085e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8d 40 04             	lea    0x4(%eax),%eax
  800867:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80086a:	b8 10 00 00 00       	mov    $0x10,%eax
  80086f:	eb a8                	jmp    800819 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800871:	8b 45 14             	mov    0x14(%ebp),%eax
  800874:	8b 50 04             	mov    0x4(%eax),%edx
  800877:	8b 00                	mov    (%eax),%eax
  800879:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80087c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80087f:	8b 45 14             	mov    0x14(%ebp),%eax
  800882:	8d 40 08             	lea    0x8(%eax),%eax
  800885:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800888:	b8 10 00 00 00       	mov    $0x10,%eax
  80088d:	eb 8a                	jmp    800819 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80088f:	8b 45 14             	mov    0x14(%ebp),%eax
  800892:	8b 00                	mov    (%eax),%eax
  800894:	ba 00 00 00 00       	mov    $0x0,%edx
  800899:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80089c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80089f:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a2:	8d 40 04             	lea    0x4(%eax),%eax
  8008a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008a8:	b8 10 00 00 00       	mov    $0x10,%eax
  8008ad:	e9 67 ff ff ff       	jmp    800819 <vprintfmt+0x436>
			base = 10;
  8008b2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008b7:	e9 5d ff ff ff       	jmp    800819 <vprintfmt+0x436>
  8008bc:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8008bf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008c2:	29 f8                	sub    %edi,%eax
  8008c4:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8008c6:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8008ca:	74 15                	je     8008e1 <vprintfmt+0x4fe>
		while (width > 0) {
  8008cc:	85 ff                	test   %edi,%edi
  8008ce:	7e 48                	jle    800918 <vprintfmt+0x535>
			putch(padc, putdat);
  8008d0:	83 ec 08             	sub    $0x8,%esp
  8008d3:	56                   	push   %esi
  8008d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8008d7:	ff d3                	call   *%ebx
			width--;
  8008d9:	83 ef 01             	sub    $0x1,%edi
  8008dc:	83 c4 10             	add    $0x10,%esp
  8008df:	eb eb                	jmp    8008cc <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  8008e1:	83 ec 0c             	sub    $0xc,%esp
  8008e4:	6a 2d                	push   $0x2d
  8008e6:	ff 75 cc             	pushl  -0x34(%ebp)
  8008e9:	ff 75 c8             	pushl  -0x38(%ebp)
  8008ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8008ef:	ff 75 d0             	pushl  -0x30(%ebp)
  8008f2:	89 f2                	mov    %esi,%edx
  8008f4:	89 d8                	mov    %ebx,%eax
  8008f6:	e8 1e fa ff ff       	call   800319 <printnum_helper>
		width -= len;
  8008fb:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8008fe:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800901:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800904:	85 ff                	test   %edi,%edi
  800906:	7e 2e                	jle    800936 <vprintfmt+0x553>
			putch(padc, putdat);
  800908:	83 ec 08             	sub    $0x8,%esp
  80090b:	56                   	push   %esi
  80090c:	6a 20                	push   $0x20
  80090e:	ff d3                	call   *%ebx
			width--;
  800910:	83 ef 01             	sub    $0x1,%edi
  800913:	83 c4 10             	add    $0x10,%esp
  800916:	eb ec                	jmp    800904 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800918:	83 ec 0c             	sub    $0xc,%esp
  80091b:	ff 75 e0             	pushl  -0x20(%ebp)
  80091e:	ff 75 cc             	pushl  -0x34(%ebp)
  800921:	ff 75 c8             	pushl  -0x38(%ebp)
  800924:	ff 75 d4             	pushl  -0x2c(%ebp)
  800927:	ff 75 d0             	pushl  -0x30(%ebp)
  80092a:	89 f2                	mov    %esi,%edx
  80092c:	89 d8                	mov    %ebx,%eax
  80092e:	e8 e6 f9 ff ff       	call   800319 <printnum_helper>
  800933:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800936:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800939:	83 c7 01             	add    $0x1,%edi
  80093c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800940:	83 f8 25             	cmp    $0x25,%eax
  800943:	0f 84 b1 fa ff ff    	je     8003fa <vprintfmt+0x17>
			if (ch == '\0')
  800949:	85 c0                	test   %eax,%eax
  80094b:	0f 84 a1 00 00 00    	je     8009f2 <vprintfmt+0x60f>
			putch(ch, putdat);
  800951:	83 ec 08             	sub    $0x8,%esp
  800954:	56                   	push   %esi
  800955:	50                   	push   %eax
  800956:	ff d3                	call   *%ebx
  800958:	83 c4 10             	add    $0x10,%esp
  80095b:	eb dc                	jmp    800939 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  80095d:	8b 45 14             	mov    0x14(%ebp),%eax
  800960:	83 c0 04             	add    $0x4,%eax
  800963:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800966:	8b 45 14             	mov    0x14(%ebp),%eax
  800969:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  80096b:	85 ff                	test   %edi,%edi
  80096d:	74 15                	je     800984 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  80096f:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800975:	7f 29                	jg     8009a0 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800977:	0f b6 06             	movzbl (%esi),%eax
  80097a:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  80097c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80097f:	89 45 14             	mov    %eax,0x14(%ebp)
  800982:	eb b2                	jmp    800936 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800984:	68 54 14 80 00       	push   $0x801454
  800989:	68 bc 13 80 00       	push   $0x8013bc
  80098e:	56                   	push   %esi
  80098f:	53                   	push   %ebx
  800990:	e8 31 fa ff ff       	call   8003c6 <printfmt>
  800995:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800998:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80099b:	89 45 14             	mov    %eax,0x14(%ebp)
  80099e:	eb 96                	jmp    800936 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  8009a0:	68 8c 14 80 00       	push   $0x80148c
  8009a5:	68 bc 13 80 00       	push   $0x8013bc
  8009aa:	56                   	push   %esi
  8009ab:	53                   	push   %ebx
  8009ac:	e8 15 fa ff ff       	call   8003c6 <printfmt>
				*res = -1;
  8009b1:	c6 07 ff             	movb   $0xff,(%edi)
  8009b4:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  8009b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009ba:	89 45 14             	mov    %eax,0x14(%ebp)
  8009bd:	e9 74 ff ff ff       	jmp    800936 <vprintfmt+0x553>
			putch(ch, putdat);
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	56                   	push   %esi
  8009c6:	6a 25                	push   $0x25
  8009c8:	ff d3                	call   *%ebx
			break;
  8009ca:	83 c4 10             	add    $0x10,%esp
  8009cd:	e9 64 ff ff ff       	jmp    800936 <vprintfmt+0x553>
			putch('%', putdat);
  8009d2:	83 ec 08             	sub    $0x8,%esp
  8009d5:	56                   	push   %esi
  8009d6:	6a 25                	push   $0x25
  8009d8:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009da:	83 c4 10             	add    $0x10,%esp
  8009dd:	89 f8                	mov    %edi,%eax
  8009df:	eb 03                	jmp    8009e4 <vprintfmt+0x601>
  8009e1:	83 e8 01             	sub    $0x1,%eax
  8009e4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009e8:	75 f7                	jne    8009e1 <vprintfmt+0x5fe>
  8009ea:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8009ed:	e9 44 ff ff ff       	jmp    800936 <vprintfmt+0x553>
}
  8009f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009f5:	5b                   	pop    %ebx
  8009f6:	5e                   	pop    %esi
  8009f7:	5f                   	pop    %edi
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	83 ec 18             	sub    $0x18,%esp
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a06:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a09:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800a0d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800a10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800a17:	85 c0                	test   %eax,%eax
  800a19:	74 26                	je     800a41 <vsnprintf+0x47>
  800a1b:	85 d2                	test   %edx,%edx
  800a1d:	7e 22                	jle    800a41 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a1f:	ff 75 14             	pushl  0x14(%ebp)
  800a22:	ff 75 10             	pushl  0x10(%ebp)
  800a25:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a28:	50                   	push   %eax
  800a29:	68 a9 03 80 00       	push   $0x8003a9
  800a2e:	e8 b0 f9 ff ff       	call   8003e3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a33:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a36:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a3c:	83 c4 10             	add    $0x10,%esp
}
  800a3f:	c9                   	leave  
  800a40:	c3                   	ret    
		return -E_INVAL;
  800a41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a46:	eb f7                	jmp    800a3f <vsnprintf+0x45>

00800a48 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a4e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a51:	50                   	push   %eax
  800a52:	ff 75 10             	pushl  0x10(%ebp)
  800a55:	ff 75 0c             	pushl  0xc(%ebp)
  800a58:	ff 75 08             	pushl  0x8(%ebp)
  800a5b:	e8 9a ff ff ff       	call   8009fa <vsnprintf>
	va_end(ap);

	return rc;
}
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    

00800a62 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a71:	74 05                	je     800a78 <strlen+0x16>
		n++;
  800a73:	83 c0 01             	add    $0x1,%eax
  800a76:	eb f5                	jmp    800a6d <strlen+0xb>
	return n;
}
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a80:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a83:	ba 00 00 00 00       	mov    $0x0,%edx
  800a88:	39 c2                	cmp    %eax,%edx
  800a8a:	74 0d                	je     800a99 <strnlen+0x1f>
  800a8c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a90:	74 05                	je     800a97 <strnlen+0x1d>
		n++;
  800a92:	83 c2 01             	add    $0x1,%edx
  800a95:	eb f1                	jmp    800a88 <strnlen+0xe>
  800a97:	89 d0                	mov    %edx,%eax
	return n;
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	53                   	push   %ebx
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800aa5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aaa:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800aae:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ab1:	83 c2 01             	add    $0x1,%edx
  800ab4:	84 c9                	test   %cl,%cl
  800ab6:	75 f2                	jne    800aaa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ab8:	5b                   	pop    %ebx
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	53                   	push   %ebx
  800abf:	83 ec 10             	sub    $0x10,%esp
  800ac2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ac5:	53                   	push   %ebx
  800ac6:	e8 97 ff ff ff       	call   800a62 <strlen>
  800acb:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800ace:	ff 75 0c             	pushl  0xc(%ebp)
  800ad1:	01 d8                	add    %ebx,%eax
  800ad3:	50                   	push   %eax
  800ad4:	e8 c2 ff ff ff       	call   800a9b <strcpy>
	return dst;
}
  800ad9:	89 d8                	mov    %ebx,%eax
  800adb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ade:	c9                   	leave  
  800adf:	c3                   	ret    

00800ae0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aeb:	89 c6                	mov    %eax,%esi
  800aed:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800af0:	89 c2                	mov    %eax,%edx
  800af2:	39 f2                	cmp    %esi,%edx
  800af4:	74 11                	je     800b07 <strncpy+0x27>
		*dst++ = *src;
  800af6:	83 c2 01             	add    $0x1,%edx
  800af9:	0f b6 19             	movzbl (%ecx),%ebx
  800afc:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aff:	80 fb 01             	cmp    $0x1,%bl
  800b02:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800b05:	eb eb                	jmp    800af2 <strncpy+0x12>
	}
	return ret;
}
  800b07:	5b                   	pop    %ebx
  800b08:	5e                   	pop    %esi
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
  800b10:	8b 75 08             	mov    0x8(%ebp),%esi
  800b13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b16:	8b 55 10             	mov    0x10(%ebp),%edx
  800b19:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b1b:	85 d2                	test   %edx,%edx
  800b1d:	74 21                	je     800b40 <strlcpy+0x35>
  800b1f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b23:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b25:	39 c2                	cmp    %eax,%edx
  800b27:	74 14                	je     800b3d <strlcpy+0x32>
  800b29:	0f b6 19             	movzbl (%ecx),%ebx
  800b2c:	84 db                	test   %bl,%bl
  800b2e:	74 0b                	je     800b3b <strlcpy+0x30>
			*dst++ = *src++;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	83 c2 01             	add    $0x1,%edx
  800b36:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b39:	eb ea                	jmp    800b25 <strlcpy+0x1a>
  800b3b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b3d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b40:	29 f0                	sub    %esi,%eax
}
  800b42:	5b                   	pop    %ebx
  800b43:	5e                   	pop    %esi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b4f:	0f b6 01             	movzbl (%ecx),%eax
  800b52:	84 c0                	test   %al,%al
  800b54:	74 0c                	je     800b62 <strcmp+0x1c>
  800b56:	3a 02                	cmp    (%edx),%al
  800b58:	75 08                	jne    800b62 <strcmp+0x1c>
		p++, q++;
  800b5a:	83 c1 01             	add    $0x1,%ecx
  800b5d:	83 c2 01             	add    $0x1,%edx
  800b60:	eb ed                	jmp    800b4f <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b62:	0f b6 c0             	movzbl %al,%eax
  800b65:	0f b6 12             	movzbl (%edx),%edx
  800b68:	29 d0                	sub    %edx,%eax
}
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	53                   	push   %ebx
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b76:	89 c3                	mov    %eax,%ebx
  800b78:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b7b:	eb 06                	jmp    800b83 <strncmp+0x17>
		n--, p++, q++;
  800b7d:	83 c0 01             	add    $0x1,%eax
  800b80:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b83:	39 d8                	cmp    %ebx,%eax
  800b85:	74 16                	je     800b9d <strncmp+0x31>
  800b87:	0f b6 08             	movzbl (%eax),%ecx
  800b8a:	84 c9                	test   %cl,%cl
  800b8c:	74 04                	je     800b92 <strncmp+0x26>
  800b8e:	3a 0a                	cmp    (%edx),%cl
  800b90:	74 eb                	je     800b7d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b92:	0f b6 00             	movzbl (%eax),%eax
  800b95:	0f b6 12             	movzbl (%edx),%edx
  800b98:	29 d0                	sub    %edx,%eax
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    
		return 0;
  800b9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba2:	eb f6                	jmp    800b9a <strncmp+0x2e>

00800ba4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  800baa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bae:	0f b6 10             	movzbl (%eax),%edx
  800bb1:	84 d2                	test   %dl,%dl
  800bb3:	74 09                	je     800bbe <strchr+0x1a>
		if (*s == c)
  800bb5:	38 ca                	cmp    %cl,%dl
  800bb7:	74 0a                	je     800bc3 <strchr+0x1f>
	for (; *s; s++)
  800bb9:	83 c0 01             	add    $0x1,%eax
  800bbc:	eb f0                	jmp    800bae <strchr+0xa>
			return (char *) s;
	return 0;
  800bbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bcf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bd2:	38 ca                	cmp    %cl,%dl
  800bd4:	74 09                	je     800bdf <strfind+0x1a>
  800bd6:	84 d2                	test   %dl,%dl
  800bd8:	74 05                	je     800bdf <strfind+0x1a>
	for (; *s; s++)
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	eb f0                	jmp    800bcf <strfind+0xa>
			break;
	return (char *) s;
}
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
  800be7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bed:	85 c9                	test   %ecx,%ecx
  800bef:	74 31                	je     800c22 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf1:	89 f8                	mov    %edi,%eax
  800bf3:	09 c8                	or     %ecx,%eax
  800bf5:	a8 03                	test   $0x3,%al
  800bf7:	75 23                	jne    800c1c <memset+0x3b>
		c &= 0xFF;
  800bf9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bfd:	89 d3                	mov    %edx,%ebx
  800bff:	c1 e3 08             	shl    $0x8,%ebx
  800c02:	89 d0                	mov    %edx,%eax
  800c04:	c1 e0 18             	shl    $0x18,%eax
  800c07:	89 d6                	mov    %edx,%esi
  800c09:	c1 e6 10             	shl    $0x10,%esi
  800c0c:	09 f0                	or     %esi,%eax
  800c0e:	09 c2                	or     %eax,%edx
  800c10:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c12:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800c15:	89 d0                	mov    %edx,%eax
  800c17:	fc                   	cld    
  800c18:	f3 ab                	rep stos %eax,%es:(%edi)
  800c1a:	eb 06                	jmp    800c22 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1f:	fc                   	cld    
  800c20:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c22:	89 f8                	mov    %edi,%eax
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	57                   	push   %edi
  800c2d:	56                   	push   %esi
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c34:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c37:	39 c6                	cmp    %eax,%esi
  800c39:	73 32                	jae    800c6d <memmove+0x44>
  800c3b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c3e:	39 c2                	cmp    %eax,%edx
  800c40:	76 2b                	jbe    800c6d <memmove+0x44>
		s += n;
		d += n;
  800c42:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c45:	89 fe                	mov    %edi,%esi
  800c47:	09 ce                	or     %ecx,%esi
  800c49:	09 d6                	or     %edx,%esi
  800c4b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c51:	75 0e                	jne    800c61 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c53:	83 ef 04             	sub    $0x4,%edi
  800c56:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c59:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c5c:	fd                   	std    
  800c5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c5f:	eb 09                	jmp    800c6a <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c61:	83 ef 01             	sub    $0x1,%edi
  800c64:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c67:	fd                   	std    
  800c68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c6a:	fc                   	cld    
  800c6b:	eb 1a                	jmp    800c87 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6d:	89 c2                	mov    %eax,%edx
  800c6f:	09 ca                	or     %ecx,%edx
  800c71:	09 f2                	or     %esi,%edx
  800c73:	f6 c2 03             	test   $0x3,%dl
  800c76:	75 0a                	jne    800c82 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c78:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c7b:	89 c7                	mov    %eax,%edi
  800c7d:	fc                   	cld    
  800c7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c80:	eb 05                	jmp    800c87 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800c82:	89 c7                	mov    %eax,%edi
  800c84:	fc                   	cld    
  800c85:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c87:	5e                   	pop    %esi
  800c88:	5f                   	pop    %edi
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c91:	ff 75 10             	pushl  0x10(%ebp)
  800c94:	ff 75 0c             	pushl  0xc(%ebp)
  800c97:	ff 75 08             	pushl  0x8(%ebp)
  800c9a:	e8 8a ff ff ff       	call   800c29 <memmove>
}
  800c9f:	c9                   	leave  
  800ca0:	c3                   	ret    

00800ca1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
  800ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cac:	89 c6                	mov    %eax,%esi
  800cae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb1:	39 f0                	cmp    %esi,%eax
  800cb3:	74 1c                	je     800cd1 <memcmp+0x30>
		if (*s1 != *s2)
  800cb5:	0f b6 08             	movzbl (%eax),%ecx
  800cb8:	0f b6 1a             	movzbl (%edx),%ebx
  800cbb:	38 d9                	cmp    %bl,%cl
  800cbd:	75 08                	jne    800cc7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cbf:	83 c0 01             	add    $0x1,%eax
  800cc2:	83 c2 01             	add    $0x1,%edx
  800cc5:	eb ea                	jmp    800cb1 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800cc7:	0f b6 c1             	movzbl %cl,%eax
  800cca:	0f b6 db             	movzbl %bl,%ebx
  800ccd:	29 d8                	sub    %ebx,%eax
  800ccf:	eb 05                	jmp    800cd6 <memcmp+0x35>
	}

	return 0;
  800cd1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd6:	5b                   	pop    %ebx
  800cd7:	5e                   	pop    %esi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ce3:	89 c2                	mov    %eax,%edx
  800ce5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ce8:	39 d0                	cmp    %edx,%eax
  800cea:	73 09                	jae    800cf5 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cec:	38 08                	cmp    %cl,(%eax)
  800cee:	74 05                	je     800cf5 <memfind+0x1b>
	for (; s < ends; s++)
  800cf0:	83 c0 01             	add    $0x1,%eax
  800cf3:	eb f3                	jmp    800ce8 <memfind+0xe>
			break;
	return (void *) s;
}
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
  800cfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d03:	eb 03                	jmp    800d08 <strtol+0x11>
		s++;
  800d05:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d08:	0f b6 01             	movzbl (%ecx),%eax
  800d0b:	3c 20                	cmp    $0x20,%al
  800d0d:	74 f6                	je     800d05 <strtol+0xe>
  800d0f:	3c 09                	cmp    $0x9,%al
  800d11:	74 f2                	je     800d05 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800d13:	3c 2b                	cmp    $0x2b,%al
  800d15:	74 2a                	je     800d41 <strtol+0x4a>
	int neg = 0;
  800d17:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d1c:	3c 2d                	cmp    $0x2d,%al
  800d1e:	74 2b                	je     800d4b <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d20:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d26:	75 0f                	jne    800d37 <strtol+0x40>
  800d28:	80 39 30             	cmpb   $0x30,(%ecx)
  800d2b:	74 28                	je     800d55 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d2d:	85 db                	test   %ebx,%ebx
  800d2f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d34:	0f 44 d8             	cmove  %eax,%ebx
  800d37:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d3f:	eb 50                	jmp    800d91 <strtol+0x9a>
		s++;
  800d41:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d44:	bf 00 00 00 00       	mov    $0x0,%edi
  800d49:	eb d5                	jmp    800d20 <strtol+0x29>
		s++, neg = 1;
  800d4b:	83 c1 01             	add    $0x1,%ecx
  800d4e:	bf 01 00 00 00       	mov    $0x1,%edi
  800d53:	eb cb                	jmp    800d20 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d55:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d59:	74 0e                	je     800d69 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800d5b:	85 db                	test   %ebx,%ebx
  800d5d:	75 d8                	jne    800d37 <strtol+0x40>
		s++, base = 8;
  800d5f:	83 c1 01             	add    $0x1,%ecx
  800d62:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d67:	eb ce                	jmp    800d37 <strtol+0x40>
		s += 2, base = 16;
  800d69:	83 c1 02             	add    $0x2,%ecx
  800d6c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d71:	eb c4                	jmp    800d37 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800d73:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d76:	89 f3                	mov    %esi,%ebx
  800d78:	80 fb 19             	cmp    $0x19,%bl
  800d7b:	77 29                	ja     800da6 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800d7d:	0f be d2             	movsbl %dl,%edx
  800d80:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d83:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d86:	7d 30                	jge    800db8 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800d88:	83 c1 01             	add    $0x1,%ecx
  800d8b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d8f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d91:	0f b6 11             	movzbl (%ecx),%edx
  800d94:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d97:	89 f3                	mov    %esi,%ebx
  800d99:	80 fb 09             	cmp    $0x9,%bl
  800d9c:	77 d5                	ja     800d73 <strtol+0x7c>
			dig = *s - '0';
  800d9e:	0f be d2             	movsbl %dl,%edx
  800da1:	83 ea 30             	sub    $0x30,%edx
  800da4:	eb dd                	jmp    800d83 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800da6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800da9:	89 f3                	mov    %esi,%ebx
  800dab:	80 fb 19             	cmp    $0x19,%bl
  800dae:	77 08                	ja     800db8 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800db0:	0f be d2             	movsbl %dl,%edx
  800db3:	83 ea 37             	sub    $0x37,%edx
  800db6:	eb cb                	jmp    800d83 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800db8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dbc:	74 05                	je     800dc3 <strtol+0xcc>
		*endptr = (char *) s;
  800dbe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dc1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800dc3:	89 c2                	mov    %eax,%edx
  800dc5:	f7 da                	neg    %edx
  800dc7:	85 ff                	test   %edi,%edi
  800dc9:	0f 45 c2             	cmovne %edx,%eax
}
  800dcc:	5b                   	pop    %ebx
  800dcd:	5e                   	pop    %esi
  800dce:	5f                   	pop    %edi
  800dcf:	5d                   	pop    %ebp
  800dd0:	c3                   	ret    

00800dd1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dd1:	55                   	push   %ebp
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	57                   	push   %edi
  800dd5:	56                   	push   %esi
  800dd6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddc:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	89 c3                	mov    %eax,%ebx
  800de4:	89 c7                	mov    %eax,%edi
  800de6:	89 c6                	mov    %eax,%esi
  800de8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_cgetc>:

int
sys_cgetc(void)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	57                   	push   %edi
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfa:	b8 01 00 00 00       	mov    $0x1,%eax
  800dff:	89 d1                	mov    %edx,%ecx
  800e01:	89 d3                	mov    %edx,%ebx
  800e03:	89 d7                	mov    %edx,%edi
  800e05:	89 d6                	mov    %edx,%esi
  800e07:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e17:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800e24:	89 cb                	mov    %ecx,%ebx
  800e26:	89 cf                	mov    %ecx,%edi
  800e28:	89 ce                	mov    %ecx,%esi
  800e2a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	7f 08                	jg     800e38 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e33:	5b                   	pop    %ebx
  800e34:	5e                   	pop    %esi
  800e35:	5f                   	pop    %edi
  800e36:	5d                   	pop    %ebp
  800e37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e38:	83 ec 0c             	sub    $0xc,%esp
  800e3b:	50                   	push   %eax
  800e3c:	6a 03                	push   $0x3
  800e3e:	68 64 16 80 00       	push   $0x801664
  800e43:	6a 23                	push   $0x23
  800e45:	68 81 16 80 00       	push   $0x801681
  800e4a:	e8 db f3 ff ff       	call   80022a <_panic>

00800e4f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e55:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5a:	b8 02 00 00 00       	mov    $0x2,%eax
  800e5f:	89 d1                	mov    %edx,%ecx
  800e61:	89 d3                	mov    %edx,%ebx
  800e63:	89 d7                	mov    %edx,%edi
  800e65:	89 d6                	mov    %edx,%esi
  800e67:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e69:	5b                   	pop    %ebx
  800e6a:	5e                   	pop    %esi
  800e6b:	5f                   	pop    %edi
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <sys_yield>:

void
sys_yield(void)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e74:	ba 00 00 00 00       	mov    $0x0,%edx
  800e79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e7e:	89 d1                	mov    %edx,%ecx
  800e80:	89 d3                	mov    %edx,%ebx
  800e82:	89 d7                	mov    %edx,%edi
  800e84:	89 d6                	mov    %edx,%esi
  800e86:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5f                   	pop    %edi
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	57                   	push   %edi
  800e91:	56                   	push   %esi
  800e92:	53                   	push   %ebx
  800e93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e96:	be 00 00 00 00       	mov    $0x0,%esi
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ea9:	89 f7                	mov    %esi,%edi
  800eab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ead:	85 c0                	test   %eax,%eax
  800eaf:	7f 08                	jg     800eb9 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb9:	83 ec 0c             	sub    $0xc,%esp
  800ebc:	50                   	push   %eax
  800ebd:	6a 04                	push   $0x4
  800ebf:	68 64 16 80 00       	push   $0x801664
  800ec4:	6a 23                	push   $0x23
  800ec6:	68 81 16 80 00       	push   $0x801681
  800ecb:	e8 5a f3 ff ff       	call   80022a <_panic>

00800ed0 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	57                   	push   %edi
  800ed4:	56                   	push   %esi
  800ed5:	53                   	push   %ebx
  800ed6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edf:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ee7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eea:	8b 75 18             	mov    0x18(%ebp),%esi
  800eed:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	7f 08                	jg     800efb <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ef3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800efb:	83 ec 0c             	sub    $0xc,%esp
  800efe:	50                   	push   %eax
  800eff:	6a 05                	push   $0x5
  800f01:	68 64 16 80 00       	push   $0x801664
  800f06:	6a 23                	push   $0x23
  800f08:	68 81 16 80 00       	push   $0x801681
  800f0d:	e8 18 f3 ff ff       	call   80022a <_panic>

00800f12 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f20:	8b 55 08             	mov    0x8(%ebp),%edx
  800f23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f26:	b8 06 00 00 00       	mov    $0x6,%eax
  800f2b:	89 df                	mov    %ebx,%edi
  800f2d:	89 de                	mov    %ebx,%esi
  800f2f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f31:	85 c0                	test   %eax,%eax
  800f33:	7f 08                	jg     800f3d <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3d:	83 ec 0c             	sub    $0xc,%esp
  800f40:	50                   	push   %eax
  800f41:	6a 06                	push   $0x6
  800f43:	68 64 16 80 00       	push   $0x801664
  800f48:	6a 23                	push   $0x23
  800f4a:	68 81 16 80 00       	push   $0x801681
  800f4f:	e8 d6 f2 ff ff       	call   80022a <_panic>

00800f54 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	57                   	push   %edi
  800f58:	56                   	push   %esi
  800f59:	53                   	push   %ebx
  800f5a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f62:	8b 55 08             	mov    0x8(%ebp),%edx
  800f65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f68:	b8 08 00 00 00       	mov    $0x8,%eax
  800f6d:	89 df                	mov    %ebx,%edi
  800f6f:	89 de                	mov    %ebx,%esi
  800f71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f73:	85 c0                	test   %eax,%eax
  800f75:	7f 08                	jg     800f7f <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7f:	83 ec 0c             	sub    $0xc,%esp
  800f82:	50                   	push   %eax
  800f83:	6a 08                	push   $0x8
  800f85:	68 64 16 80 00       	push   $0x801664
  800f8a:	6a 23                	push   $0x23
  800f8c:	68 81 16 80 00       	push   $0x801681
  800f91:	e8 94 f2 ff ff       	call   80022a <_panic>

00800f96 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	57                   	push   %edi
  800f9a:	56                   	push   %esi
  800f9b:	53                   	push   %ebx
  800f9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800faa:	b8 09 00 00 00       	mov    $0x9,%eax
  800faf:	89 df                	mov    %ebx,%edi
  800fb1:	89 de                	mov    %ebx,%esi
  800fb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	7f 08                	jg     800fc1 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbc:	5b                   	pop    %ebx
  800fbd:	5e                   	pop    %esi
  800fbe:	5f                   	pop    %edi
  800fbf:	5d                   	pop    %ebp
  800fc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc1:	83 ec 0c             	sub    $0xc,%esp
  800fc4:	50                   	push   %eax
  800fc5:	6a 09                	push   $0x9
  800fc7:	68 64 16 80 00       	push   $0x801664
  800fcc:	6a 23                	push   $0x23
  800fce:	68 81 16 80 00       	push   $0x801681
  800fd3:	e8 52 f2 ff ff       	call   80022a <_panic>

00800fd8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	57                   	push   %edi
  800fdc:	56                   	push   %esi
  800fdd:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fde:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fe9:	be 00 00 00 00       	mov    $0x0,%esi
  800fee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ff1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ff4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ff6:	5b                   	pop    %ebx
  800ff7:	5e                   	pop    %esi
  800ff8:	5f                   	pop    %edi
  800ff9:	5d                   	pop    %ebp
  800ffa:	c3                   	ret    

00800ffb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	57                   	push   %edi
  800fff:	56                   	push   %esi
  801000:	53                   	push   %ebx
  801001:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801004:	b9 00 00 00 00       	mov    $0x0,%ecx
  801009:	8b 55 08             	mov    0x8(%ebp),%edx
  80100c:	b8 0c 00 00 00       	mov    $0xc,%eax
  801011:	89 cb                	mov    %ecx,%ebx
  801013:	89 cf                	mov    %ecx,%edi
  801015:	89 ce                	mov    %ecx,%esi
  801017:	cd 30                	int    $0x30
	if(check && ret > 0)
  801019:	85 c0                	test   %eax,%eax
  80101b:	7f 08                	jg     801025 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80101d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5f                   	pop    %edi
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	50                   	push   %eax
  801029:	6a 0c                	push   $0xc
  80102b:	68 64 16 80 00       	push   $0x801664
  801030:	6a 23                	push   $0x23
  801032:	68 81 16 80 00       	push   $0x801681
  801037:	e8 ee f1 ff ff       	call   80022a <_panic>

0080103c <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  80103c:	55                   	push   %ebp
  80103d:	89 e5                	mov    %esp,%ebp
  80103f:	57                   	push   %edi
  801040:	56                   	push   %esi
  801041:	53                   	push   %ebx
	asm volatile("int %1\n"
  801042:	bb 00 00 00 00       	mov    $0x0,%ebx
  801047:	8b 55 08             	mov    0x8(%ebp),%edx
  80104a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80104d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801052:	89 df                	mov    %ebx,%edi
  801054:	89 de                	mov    %ebx,%esi
  801056:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	57                   	push   %edi
  801061:	56                   	push   %esi
  801062:	53                   	push   %ebx
	asm volatile("int %1\n"
  801063:	b9 00 00 00 00       	mov    $0x0,%ecx
  801068:	8b 55 08             	mov    0x8(%ebp),%edx
  80106b:	b8 0e 00 00 00       	mov    $0xe,%eax
  801070:	89 cb                	mov    %ecx,%ebx
  801072:	89 cf                	mov    %ecx,%edi
  801074:	89 ce                	mov    %ecx,%esi
  801076:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    
  80107d:	66 90                	xchg   %ax,%ax
  80107f:	90                   	nop

00801080 <__udivdi3>:
  801080:	55                   	push   %ebp
  801081:	57                   	push   %edi
  801082:	56                   	push   %esi
  801083:	53                   	push   %ebx
  801084:	83 ec 1c             	sub    $0x1c,%esp
  801087:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80108b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80108f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801093:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801097:	85 d2                	test   %edx,%edx
  801099:	75 4d                	jne    8010e8 <__udivdi3+0x68>
  80109b:	39 f3                	cmp    %esi,%ebx
  80109d:	76 19                	jbe    8010b8 <__udivdi3+0x38>
  80109f:	31 ff                	xor    %edi,%edi
  8010a1:	89 e8                	mov    %ebp,%eax
  8010a3:	89 f2                	mov    %esi,%edx
  8010a5:	f7 f3                	div    %ebx
  8010a7:	89 fa                	mov    %edi,%edx
  8010a9:	83 c4 1c             	add    $0x1c,%esp
  8010ac:	5b                   	pop    %ebx
  8010ad:	5e                   	pop    %esi
  8010ae:	5f                   	pop    %edi
  8010af:	5d                   	pop    %ebp
  8010b0:	c3                   	ret    
  8010b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010b8:	89 d9                	mov    %ebx,%ecx
  8010ba:	85 db                	test   %ebx,%ebx
  8010bc:	75 0b                	jne    8010c9 <__udivdi3+0x49>
  8010be:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c3:	31 d2                	xor    %edx,%edx
  8010c5:	f7 f3                	div    %ebx
  8010c7:	89 c1                	mov    %eax,%ecx
  8010c9:	31 d2                	xor    %edx,%edx
  8010cb:	89 f0                	mov    %esi,%eax
  8010cd:	f7 f1                	div    %ecx
  8010cf:	89 c6                	mov    %eax,%esi
  8010d1:	89 e8                	mov    %ebp,%eax
  8010d3:	89 f7                	mov    %esi,%edi
  8010d5:	f7 f1                	div    %ecx
  8010d7:	89 fa                	mov    %edi,%edx
  8010d9:	83 c4 1c             	add    $0x1c,%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    
  8010e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010e8:	39 f2                	cmp    %esi,%edx
  8010ea:	77 1c                	ja     801108 <__udivdi3+0x88>
  8010ec:	0f bd fa             	bsr    %edx,%edi
  8010ef:	83 f7 1f             	xor    $0x1f,%edi
  8010f2:	75 2c                	jne    801120 <__udivdi3+0xa0>
  8010f4:	39 f2                	cmp    %esi,%edx
  8010f6:	72 06                	jb     8010fe <__udivdi3+0x7e>
  8010f8:	31 c0                	xor    %eax,%eax
  8010fa:	39 eb                	cmp    %ebp,%ebx
  8010fc:	77 a9                	ja     8010a7 <__udivdi3+0x27>
  8010fe:	b8 01 00 00 00       	mov    $0x1,%eax
  801103:	eb a2                	jmp    8010a7 <__udivdi3+0x27>
  801105:	8d 76 00             	lea    0x0(%esi),%esi
  801108:	31 ff                	xor    %edi,%edi
  80110a:	31 c0                	xor    %eax,%eax
  80110c:	89 fa                	mov    %edi,%edx
  80110e:	83 c4 1c             	add    $0x1c,%esp
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5f                   	pop    %edi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    
  801116:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80111d:	8d 76 00             	lea    0x0(%esi),%esi
  801120:	89 f9                	mov    %edi,%ecx
  801122:	b8 20 00 00 00       	mov    $0x20,%eax
  801127:	29 f8                	sub    %edi,%eax
  801129:	d3 e2                	shl    %cl,%edx
  80112b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80112f:	89 c1                	mov    %eax,%ecx
  801131:	89 da                	mov    %ebx,%edx
  801133:	d3 ea                	shr    %cl,%edx
  801135:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801139:	09 d1                	or     %edx,%ecx
  80113b:	89 f2                	mov    %esi,%edx
  80113d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801141:	89 f9                	mov    %edi,%ecx
  801143:	d3 e3                	shl    %cl,%ebx
  801145:	89 c1                	mov    %eax,%ecx
  801147:	d3 ea                	shr    %cl,%edx
  801149:	89 f9                	mov    %edi,%ecx
  80114b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80114f:	89 eb                	mov    %ebp,%ebx
  801151:	d3 e6                	shl    %cl,%esi
  801153:	89 c1                	mov    %eax,%ecx
  801155:	d3 eb                	shr    %cl,%ebx
  801157:	09 de                	or     %ebx,%esi
  801159:	89 f0                	mov    %esi,%eax
  80115b:	f7 74 24 08          	divl   0x8(%esp)
  80115f:	89 d6                	mov    %edx,%esi
  801161:	89 c3                	mov    %eax,%ebx
  801163:	f7 64 24 0c          	mull   0xc(%esp)
  801167:	39 d6                	cmp    %edx,%esi
  801169:	72 15                	jb     801180 <__udivdi3+0x100>
  80116b:	89 f9                	mov    %edi,%ecx
  80116d:	d3 e5                	shl    %cl,%ebp
  80116f:	39 c5                	cmp    %eax,%ebp
  801171:	73 04                	jae    801177 <__udivdi3+0xf7>
  801173:	39 d6                	cmp    %edx,%esi
  801175:	74 09                	je     801180 <__udivdi3+0x100>
  801177:	89 d8                	mov    %ebx,%eax
  801179:	31 ff                	xor    %edi,%edi
  80117b:	e9 27 ff ff ff       	jmp    8010a7 <__udivdi3+0x27>
  801180:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801183:	31 ff                	xor    %edi,%edi
  801185:	e9 1d ff ff ff       	jmp    8010a7 <__udivdi3+0x27>
  80118a:	66 90                	xchg   %ax,%ax
  80118c:	66 90                	xchg   %ax,%ax
  80118e:	66 90                	xchg   %ax,%ax

00801190 <__umoddi3>:
  801190:	55                   	push   %ebp
  801191:	57                   	push   %edi
  801192:	56                   	push   %esi
  801193:	53                   	push   %ebx
  801194:	83 ec 1c             	sub    $0x1c,%esp
  801197:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80119b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80119f:	8b 74 24 30          	mov    0x30(%esp),%esi
  8011a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8011a7:	89 da                	mov    %ebx,%edx
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	75 43                	jne    8011f0 <__umoddi3+0x60>
  8011ad:	39 df                	cmp    %ebx,%edi
  8011af:	76 17                	jbe    8011c8 <__umoddi3+0x38>
  8011b1:	89 f0                	mov    %esi,%eax
  8011b3:	f7 f7                	div    %edi
  8011b5:	89 d0                	mov    %edx,%eax
  8011b7:	31 d2                	xor    %edx,%edx
  8011b9:	83 c4 1c             	add    $0x1c,%esp
  8011bc:	5b                   	pop    %ebx
  8011bd:	5e                   	pop    %esi
  8011be:	5f                   	pop    %edi
  8011bf:	5d                   	pop    %ebp
  8011c0:	c3                   	ret    
  8011c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	89 fd                	mov    %edi,%ebp
  8011ca:	85 ff                	test   %edi,%edi
  8011cc:	75 0b                	jne    8011d9 <__umoddi3+0x49>
  8011ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d3:	31 d2                	xor    %edx,%edx
  8011d5:	f7 f7                	div    %edi
  8011d7:	89 c5                	mov    %eax,%ebp
  8011d9:	89 d8                	mov    %ebx,%eax
  8011db:	31 d2                	xor    %edx,%edx
  8011dd:	f7 f5                	div    %ebp
  8011df:	89 f0                	mov    %esi,%eax
  8011e1:	f7 f5                	div    %ebp
  8011e3:	89 d0                	mov    %edx,%eax
  8011e5:	eb d0                	jmp    8011b7 <__umoddi3+0x27>
  8011e7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011ee:	66 90                	xchg   %ax,%ax
  8011f0:	89 f1                	mov    %esi,%ecx
  8011f2:	39 d8                	cmp    %ebx,%eax
  8011f4:	76 0a                	jbe    801200 <__umoddi3+0x70>
  8011f6:	89 f0                	mov    %esi,%eax
  8011f8:	83 c4 1c             	add    $0x1c,%esp
  8011fb:	5b                   	pop    %ebx
  8011fc:	5e                   	pop    %esi
  8011fd:	5f                   	pop    %edi
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    
  801200:	0f bd e8             	bsr    %eax,%ebp
  801203:	83 f5 1f             	xor    $0x1f,%ebp
  801206:	75 20                	jne    801228 <__umoddi3+0x98>
  801208:	39 d8                	cmp    %ebx,%eax
  80120a:	0f 82 b0 00 00 00    	jb     8012c0 <__umoddi3+0x130>
  801210:	39 f7                	cmp    %esi,%edi
  801212:	0f 86 a8 00 00 00    	jbe    8012c0 <__umoddi3+0x130>
  801218:	89 c8                	mov    %ecx,%eax
  80121a:	83 c4 1c             	add    $0x1c,%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5e                   	pop    %esi
  80121f:	5f                   	pop    %edi
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    
  801222:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801228:	89 e9                	mov    %ebp,%ecx
  80122a:	ba 20 00 00 00       	mov    $0x20,%edx
  80122f:	29 ea                	sub    %ebp,%edx
  801231:	d3 e0                	shl    %cl,%eax
  801233:	89 44 24 08          	mov    %eax,0x8(%esp)
  801237:	89 d1                	mov    %edx,%ecx
  801239:	89 f8                	mov    %edi,%eax
  80123b:	d3 e8                	shr    %cl,%eax
  80123d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801241:	89 54 24 04          	mov    %edx,0x4(%esp)
  801245:	8b 54 24 04          	mov    0x4(%esp),%edx
  801249:	09 c1                	or     %eax,%ecx
  80124b:	89 d8                	mov    %ebx,%eax
  80124d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801251:	89 e9                	mov    %ebp,%ecx
  801253:	d3 e7                	shl    %cl,%edi
  801255:	89 d1                	mov    %edx,%ecx
  801257:	d3 e8                	shr    %cl,%eax
  801259:	89 e9                	mov    %ebp,%ecx
  80125b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80125f:	d3 e3                	shl    %cl,%ebx
  801261:	89 c7                	mov    %eax,%edi
  801263:	89 d1                	mov    %edx,%ecx
  801265:	89 f0                	mov    %esi,%eax
  801267:	d3 e8                	shr    %cl,%eax
  801269:	89 e9                	mov    %ebp,%ecx
  80126b:	89 fa                	mov    %edi,%edx
  80126d:	d3 e6                	shl    %cl,%esi
  80126f:	09 d8                	or     %ebx,%eax
  801271:	f7 74 24 08          	divl   0x8(%esp)
  801275:	89 d1                	mov    %edx,%ecx
  801277:	89 f3                	mov    %esi,%ebx
  801279:	f7 64 24 0c          	mull   0xc(%esp)
  80127d:	89 c6                	mov    %eax,%esi
  80127f:	89 d7                	mov    %edx,%edi
  801281:	39 d1                	cmp    %edx,%ecx
  801283:	72 06                	jb     80128b <__umoddi3+0xfb>
  801285:	75 10                	jne    801297 <__umoddi3+0x107>
  801287:	39 c3                	cmp    %eax,%ebx
  801289:	73 0c                	jae    801297 <__umoddi3+0x107>
  80128b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80128f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801293:	89 d7                	mov    %edx,%edi
  801295:	89 c6                	mov    %eax,%esi
  801297:	89 ca                	mov    %ecx,%edx
  801299:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80129e:	29 f3                	sub    %esi,%ebx
  8012a0:	19 fa                	sbb    %edi,%edx
  8012a2:	89 d0                	mov    %edx,%eax
  8012a4:	d3 e0                	shl    %cl,%eax
  8012a6:	89 e9                	mov    %ebp,%ecx
  8012a8:	d3 eb                	shr    %cl,%ebx
  8012aa:	d3 ea                	shr    %cl,%edx
  8012ac:	09 d8                	or     %ebx,%eax
  8012ae:	83 c4 1c             	add    $0x1c,%esp
  8012b1:	5b                   	pop    %ebx
  8012b2:	5e                   	pop    %esi
  8012b3:	5f                   	pop    %edi
  8012b4:	5d                   	pop    %ebp
  8012b5:	c3                   	ret    
  8012b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012bd:	8d 76 00             	lea    0x0(%esi),%esi
  8012c0:	89 da                	mov    %ebx,%edx
  8012c2:	29 fe                	sub    %edi,%esi
  8012c4:	19 c2                	sbb    %eax,%edx
  8012c6:	89 f1                	mov    %esi,%ecx
  8012c8:	89 c8                	mov    %ecx,%eax
  8012ca:	e9 4b ff ff ff       	jmp    80121a <__umoddi3+0x8a>
