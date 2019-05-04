
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 20 80 00 60 	movl   $0x801160,0x802000
  800040:	11 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 f7 00 00 00       	call   80013f <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 c6 00 00 00       	call   800120 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	c1 e0 07             	shl    $0x7,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7f 08                	jg     800109 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5f                   	pop    %edi
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 6f 11 80 00       	push   $0x80116f
  800114:	6a 23                	push   $0x23
  800116:	68 8c 11 80 00       	push   $0x80118c
  80011b:	e8 2e 02 00 00       	call   80034e <_panic>

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800172:	b8 04 00 00 00       	mov    $0x4,%eax
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7f 08                	jg     80018a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800182:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 6f 11 80 00       	push   $0x80116f
  800195:	6a 23                	push   $0x23
  800197:	68 8c 11 80 00       	push   $0x80118c
  80019c:	e8 ad 01 00 00       	call   80034e <_panic>

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7f 08                	jg     8001cc <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5f                   	pop    %edi
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 6f 11 80 00       	push   $0x80116f
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 8c 11 80 00       	push   $0x80118c
  8001de:	e8 6b 01 00 00       	call   80034e <_panic>

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7f 08                	jg     80020e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 6f 11 80 00       	push   $0x80116f
  800219:	6a 23                	push   $0x23
  80021b:	68 8c 11 80 00       	push   $0x80118c
  800220:	e8 29 01 00 00       	call   80034e <_panic>

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800239:	b8 08 00 00 00       	mov    $0x8,%eax
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7f 08                	jg     800250 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 6f 11 80 00       	push   $0x80116f
  80025b:	6a 23                	push   $0x23
  80025d:	68 8c 11 80 00       	push   $0x80118c
  800262:	e8 e7 00 00 00       	call   80034e <_panic>

00800267 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	b8 09 00 00 00       	mov    $0x9,%eax
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7f 08                	jg     800292 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 6f 11 80 00       	push   $0x80116f
  80029d:	6a 23                	push   $0x23
  80029f:	68 8c 11 80 00       	push   $0x80118c
  8002a4:	e8 a5 00 00 00       	call   80034e <_panic>

008002a9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002af:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ba:	be 00 00 00 00       	mov    $0x0,%esi
  8002bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e2:	89 cb                	mov    %ecx,%ebx
  8002e4:	89 cf                	mov    %ecx,%edi
  8002e6:	89 ce                	mov    %ecx,%esi
  8002e8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7f 08                	jg     8002f6 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f1:	5b                   	pop    %ebx
  8002f2:	5e                   	pop    %esi
  8002f3:	5f                   	pop    %edi
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f6:	83 ec 0c             	sub    $0xc,%esp
  8002f9:	50                   	push   %eax
  8002fa:	6a 0c                	push   $0xc
  8002fc:	68 6f 11 80 00       	push   $0x80116f
  800301:	6a 23                	push   $0x23
  800303:	68 8c 11 80 00       	push   $0x80118c
  800308:	e8 41 00 00 00       	call   80034e <_panic>

0080030d <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
	asm volatile("int %1\n"
  800313:	bb 00 00 00 00       	mov    $0x0,%ebx
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800323:	89 df                	mov    %ebx,%edi
  800325:	89 de                	mov    %ebx,%esi
  800327:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800329:	5b                   	pop    %ebx
  80032a:	5e                   	pop    %esi
  80032b:	5f                   	pop    %edi
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
	asm volatile("int %1\n"
  800334:	b9 00 00 00 00       	mov    $0x0,%ecx
  800339:	8b 55 08             	mov    0x8(%ebp),%edx
  80033c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800341:	89 cb                	mov    %ecx,%ebx
  800343:	89 cf                	mov    %ecx,%edi
  800345:	89 ce                	mov    %ecx,%esi
  800347:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800349:	5b                   	pop    %ebx
  80034a:	5e                   	pop    %esi
  80034b:	5f                   	pop    %edi
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	56                   	push   %esi
  800352:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800353:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800356:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80035c:	e8 bf fd ff ff       	call   800120 <sys_getenvid>
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 0c             	pushl  0xc(%ebp)
  800367:	ff 75 08             	pushl  0x8(%ebp)
  80036a:	56                   	push   %esi
  80036b:	50                   	push   %eax
  80036c:	68 9c 11 80 00       	push   $0x80119c
  800371:	e8 b3 00 00 00       	call   800429 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800376:	83 c4 18             	add    $0x18,%esp
  800379:	53                   	push   %ebx
  80037a:	ff 75 10             	pushl  0x10(%ebp)
  80037d:	e8 56 00 00 00       	call   8003d8 <vcprintf>
	cprintf("\n");
  800382:	c7 04 24 bf 11 80 00 	movl   $0x8011bf,(%esp)
  800389:	e8 9b 00 00 00       	call   800429 <cprintf>
  80038e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800391:	cc                   	int3   
  800392:	eb fd                	jmp    800391 <_panic+0x43>

00800394 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	53                   	push   %ebx
  800398:	83 ec 04             	sub    $0x4,%esp
  80039b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039e:	8b 13                	mov    (%ebx),%edx
  8003a0:	8d 42 01             	lea    0x1(%edx),%eax
  8003a3:	89 03                	mov    %eax,(%ebx)
  8003a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ac:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b1:	74 09                	je     8003bc <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003b3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ba:	c9                   	leave  
  8003bb:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003bc:	83 ec 08             	sub    $0x8,%esp
  8003bf:	68 ff 00 00 00       	push   $0xff
  8003c4:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c7:	50                   	push   %eax
  8003c8:	e8 d5 fc ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8003cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d3:	83 c4 10             	add    $0x10,%esp
  8003d6:	eb db                	jmp    8003b3 <putch+0x1f>

008003d8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e8:	00 00 00 
	b.cnt = 0;
  8003eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f5:	ff 75 0c             	pushl  0xc(%ebp)
  8003f8:	ff 75 08             	pushl  0x8(%ebp)
  8003fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800401:	50                   	push   %eax
  800402:	68 94 03 80 00       	push   $0x800394
  800407:	e8 fb 00 00 00       	call   800507 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80040c:	83 c4 08             	add    $0x8,%esp
  80040f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800415:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80041b:	50                   	push   %eax
  80041c:	e8 81 fc ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  800421:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800427:	c9                   	leave  
  800428:	c3                   	ret    

00800429 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800432:	50                   	push   %eax
  800433:	ff 75 08             	pushl  0x8(%ebp)
  800436:	e8 9d ff ff ff       	call   8003d8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80043b:	c9                   	leave  
  80043c:	c3                   	ret    

0080043d <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80043d:	55                   	push   %ebp
  80043e:	89 e5                	mov    %esp,%ebp
  800440:	57                   	push   %edi
  800441:	56                   	push   %esi
  800442:	53                   	push   %ebx
  800443:	83 ec 1c             	sub    $0x1c,%esp
  800446:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800449:	89 d3                	mov    %edx,%ebx
  80044b:	8b 75 08             	mov    0x8(%ebp),%esi
  80044e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800451:	8b 45 10             	mov    0x10(%ebp),%eax
  800454:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800457:	89 c2                	mov    %eax,%edx
  800459:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800461:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800464:	39 c6                	cmp    %eax,%esi
  800466:	89 f8                	mov    %edi,%eax
  800468:	19 c8                	sbb    %ecx,%eax
  80046a:	73 32                	jae    80049e <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	53                   	push   %ebx
  800470:	83 ec 04             	sub    $0x4,%esp
  800473:	ff 75 e4             	pushl  -0x1c(%ebp)
  800476:	ff 75 e0             	pushl  -0x20(%ebp)
  800479:	57                   	push   %edi
  80047a:	56                   	push   %esi
  80047b:	e8 90 0b 00 00       	call   801010 <__umoddi3>
  800480:	83 c4 14             	add    $0x14,%esp
  800483:	0f be 80 c1 11 80 00 	movsbl 0x8011c1(%eax),%eax
  80048a:	50                   	push   %eax
  80048b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80048e:	ff d0                	call   *%eax
	return remain - 1;
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	83 e8 01             	sub    $0x1,%eax
}
  800496:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800499:	5b                   	pop    %ebx
  80049a:	5e                   	pop    %esi
  80049b:	5f                   	pop    %edi
  80049c:	5d                   	pop    %ebp
  80049d:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  80049e:	83 ec 0c             	sub    $0xc,%esp
  8004a1:	ff 75 18             	pushl  0x18(%ebp)
  8004a4:	ff 75 14             	pushl  0x14(%ebp)
  8004a7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	51                   	push   %ecx
  8004ae:	52                   	push   %edx
  8004af:	57                   	push   %edi
  8004b0:	56                   	push   %esi
  8004b1:	e8 4a 0a 00 00       	call   800f00 <__udivdi3>
  8004b6:	83 c4 18             	add    $0x18,%esp
  8004b9:	52                   	push   %edx
  8004ba:	50                   	push   %eax
  8004bb:	89 da                	mov    %ebx,%edx
  8004bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c0:	e8 78 ff ff ff       	call   80043d <printnum_helper>
  8004c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c8:	83 c4 20             	add    $0x20,%esp
  8004cb:	eb 9f                	jmp    80046c <printnum_helper+0x2f>

008004cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004cd:	55                   	push   %ebp
  8004ce:	89 e5                	mov    %esp,%ebp
  8004d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d7:	8b 10                	mov    (%eax),%edx
  8004d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004dc:	73 0a                	jae    8004e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e1:	89 08                	mov    %ecx,(%eax)
  8004e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e6:	88 02                	mov    %al,(%edx)
}
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <printfmt>:
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f3:	50                   	push   %eax
  8004f4:	ff 75 10             	pushl  0x10(%ebp)
  8004f7:	ff 75 0c             	pushl  0xc(%ebp)
  8004fa:	ff 75 08             	pushl  0x8(%ebp)
  8004fd:	e8 05 00 00 00       	call   800507 <vprintfmt>
}
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	c9                   	leave  
  800506:	c3                   	ret    

00800507 <vprintfmt>:
{
  800507:	55                   	push   %ebp
  800508:	89 e5                	mov    %esp,%ebp
  80050a:	57                   	push   %edi
  80050b:	56                   	push   %esi
  80050c:	53                   	push   %ebx
  80050d:	83 ec 3c             	sub    $0x3c,%esp
  800510:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800513:	8b 75 0c             	mov    0xc(%ebp),%esi
  800516:	8b 7d 10             	mov    0x10(%ebp),%edi
  800519:	e9 3f 05 00 00       	jmp    800a5d <vprintfmt+0x556>
		padc = ' ';
  80051e:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800522:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800529:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800530:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800537:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  80053e:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800545:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8d 47 01             	lea    0x1(%edi),%eax
  80054d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800550:	0f b6 17             	movzbl (%edi),%edx
  800553:	8d 42 dd             	lea    -0x23(%edx),%eax
  800556:	3c 55                	cmp    $0x55,%al
  800558:	0f 87 98 05 00 00    	ja     800af6 <vprintfmt+0x5ef>
  80055e:	0f b6 c0             	movzbl %al,%eax
  800561:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)
  800568:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  80056b:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80056f:	eb d9                	jmp    80054a <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800574:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  80057b:	eb cd                	jmp    80054a <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	0f b6 d2             	movzbl %dl,%edx
  800580:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800583:	b8 00 00 00 00       	mov    $0x0,%eax
  800588:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  80058b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80058e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800592:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800595:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800598:	83 fb 09             	cmp    $0x9,%ebx
  80059b:	77 5c                	ja     8005f9 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  80059d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005a0:	eb e9                	jmp    80058b <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  8005a5:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  8005a9:	eb 9f                	jmp    80054a <vprintfmt+0x43>
			precision = va_arg(ap, int);
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8b 00                	mov    (%eax),%eax
  8005b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 40 04             	lea    0x4(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8005bf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c3:	79 85                	jns    80054a <vprintfmt+0x43>
				width = precision, precision = -1;
  8005c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005d2:	e9 73 ff ff ff       	jmp    80054a <vprintfmt+0x43>
  8005d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005da:	85 c0                	test   %eax,%eax
  8005dc:	0f 48 c1             	cmovs  %ecx,%eax
  8005df:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005e5:	e9 60 ff ff ff       	jmp    80054a <vprintfmt+0x43>
  8005ea:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8005ed:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8005f4:	e9 51 ff ff ff       	jmp    80054a <vprintfmt+0x43>
  8005f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005ff:	eb be                	jmp    8005bf <vprintfmt+0xb8>
			lflag++;
  800601:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800605:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  800608:	e9 3d ff ff ff       	jmp    80054a <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 78 04             	lea    0x4(%eax),%edi
  800613:	83 ec 08             	sub    $0x8,%esp
  800616:	56                   	push   %esi
  800617:	ff 30                	pushl  (%eax)
  800619:	ff d3                	call   *%ebx
			break;
  80061b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80061e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800621:	e9 34 04 00 00       	jmp    800a5a <vprintfmt+0x553>
			err = va_arg(ap, int);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 78 04             	lea    0x4(%eax),%edi
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	99                   	cltd   
  80062f:	31 d0                	xor    %edx,%eax
  800631:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800633:	83 f8 08             	cmp    $0x8,%eax
  800636:	7f 23                	jg     80065b <vprintfmt+0x154>
  800638:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  80063f:	85 d2                	test   %edx,%edx
  800641:	74 18                	je     80065b <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800643:	52                   	push   %edx
  800644:	68 e2 11 80 00       	push   $0x8011e2
  800649:	56                   	push   %esi
  80064a:	53                   	push   %ebx
  80064b:	e8 9a fe ff ff       	call   8004ea <printfmt>
  800650:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800653:	89 7d 14             	mov    %edi,0x14(%ebp)
  800656:	e9 ff 03 00 00       	jmp    800a5a <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  80065b:	50                   	push   %eax
  80065c:	68 d9 11 80 00       	push   $0x8011d9
  800661:	56                   	push   %esi
  800662:	53                   	push   %ebx
  800663:	e8 82 fe ff ff       	call   8004ea <printfmt>
  800668:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80066b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80066e:	e9 e7 03 00 00       	jmp    800a5a <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	83 c0 04             	add    $0x4,%eax
  800679:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800681:	85 c9                	test   %ecx,%ecx
  800683:	b8 d2 11 80 00       	mov    $0x8011d2,%eax
  800688:	0f 45 c1             	cmovne %ecx,%eax
  80068b:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80068e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800692:	7e 06                	jle    80069a <vprintfmt+0x193>
  800694:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800698:	75 0d                	jne    8006a7 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80069d:	89 c7                	mov    %eax,%edi
  80069f:	03 45 d8             	add    -0x28(%ebp),%eax
  8006a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a5:	eb 53                	jmp    8006fa <vprintfmt+0x1f3>
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ad:	50                   	push   %eax
  8006ae:	e8 eb 04 00 00       	call   800b9e <strnlen>
  8006b3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006b6:	29 c1                	sub    %eax,%ecx
  8006b8:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006c0:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8006c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c7:	eb 0f                	jmp    8006d8 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	56                   	push   %esi
  8006cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8006d0:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d2:	83 ef 01             	sub    $0x1,%edi
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	85 ff                	test   %edi,%edi
  8006da:	7f ed                	jg     8006c9 <vprintfmt+0x1c2>
  8006dc:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8006df:	85 c9                	test   %ecx,%ecx
  8006e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e6:	0f 49 c1             	cmovns %ecx,%eax
  8006e9:	29 c1                	sub    %eax,%ecx
  8006eb:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006ee:	eb aa                	jmp    80069a <vprintfmt+0x193>
					putch(ch, putdat);
  8006f0:	83 ec 08             	sub    $0x8,%esp
  8006f3:	56                   	push   %esi
  8006f4:	52                   	push   %edx
  8006f5:	ff d3                	call   *%ebx
  8006f7:	83 c4 10             	add    $0x10,%esp
  8006fa:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006fd:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ff:	83 c7 01             	add    $0x1,%edi
  800702:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800706:	0f be d0             	movsbl %al,%edx
  800709:	85 d2                	test   %edx,%edx
  80070b:	74 2e                	je     80073b <vprintfmt+0x234>
  80070d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800711:	78 06                	js     800719 <vprintfmt+0x212>
  800713:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800717:	78 1e                	js     800737 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800719:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80071d:	74 d1                	je     8006f0 <vprintfmt+0x1e9>
  80071f:	0f be c0             	movsbl %al,%eax
  800722:	83 e8 20             	sub    $0x20,%eax
  800725:	83 f8 5e             	cmp    $0x5e,%eax
  800728:	76 c6                	jbe    8006f0 <vprintfmt+0x1e9>
					putch('?', putdat);
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	56                   	push   %esi
  80072e:	6a 3f                	push   $0x3f
  800730:	ff d3                	call   *%ebx
  800732:	83 c4 10             	add    $0x10,%esp
  800735:	eb c3                	jmp    8006fa <vprintfmt+0x1f3>
  800737:	89 cf                	mov    %ecx,%edi
  800739:	eb 02                	jmp    80073d <vprintfmt+0x236>
  80073b:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  80073d:	85 ff                	test   %edi,%edi
  80073f:	7e 10                	jle    800751 <vprintfmt+0x24a>
				putch(' ', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	56                   	push   %esi
  800745:	6a 20                	push   $0x20
  800747:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800749:	83 ef 01             	sub    $0x1,%edi
  80074c:	83 c4 10             	add    $0x10,%esp
  80074f:	eb ec                	jmp    80073d <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800751:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800754:	89 45 14             	mov    %eax,0x14(%ebp)
  800757:	e9 fe 02 00 00       	jmp    800a5a <vprintfmt+0x553>
	if (lflag >= 2)
  80075c:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800760:	7f 21                	jg     800783 <vprintfmt+0x27c>
	else if (lflag)
  800762:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800766:	74 79                	je     8007e1 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8b 00                	mov    (%eax),%eax
  80076d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800770:	89 c1                	mov    %eax,%ecx
  800772:	c1 f9 1f             	sar    $0x1f,%ecx
  800775:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8d 40 04             	lea    0x4(%eax),%eax
  80077e:	89 45 14             	mov    %eax,0x14(%ebp)
  800781:	eb 17                	jmp    80079a <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 50 04             	mov    0x4(%eax),%edx
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80078e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 40 08             	lea    0x8(%eax),%eax
  800797:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  80079a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80079d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007a3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  8007a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007aa:	78 50                	js     8007fc <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  8007ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007af:	c1 fa 1f             	sar    $0x1f,%edx
  8007b2:	89 d0                	mov    %edx,%eax
  8007b4:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8007b7:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8007ba:	85 d2                	test   %edx,%edx
  8007bc:	0f 89 14 02 00 00    	jns    8009d6 <vprintfmt+0x4cf>
  8007c2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007c6:	0f 84 0a 02 00 00    	je     8009d6 <vprintfmt+0x4cf>
				putch('+', putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	56                   	push   %esi
  8007d0:	6a 2b                	push   $0x2b
  8007d2:	ff d3                	call   *%ebx
  8007d4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007dc:	e9 5c 01 00 00       	jmp    80093d <vprintfmt+0x436>
		return va_arg(*ap, int);
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8b 00                	mov    (%eax),%eax
  8007e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e9:	89 c1                	mov    %eax,%ecx
  8007eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ee:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8d 40 04             	lea    0x4(%eax),%eax
  8007f7:	89 45 14             	mov    %eax,0x14(%ebp)
  8007fa:	eb 9e                	jmp    80079a <vprintfmt+0x293>
				putch('-', putdat);
  8007fc:	83 ec 08             	sub    $0x8,%esp
  8007ff:	56                   	push   %esi
  800800:	6a 2d                	push   $0x2d
  800802:	ff d3                	call   *%ebx
				num = -(long long) num;
  800804:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800807:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80080a:	f7 d8                	neg    %eax
  80080c:	83 d2 00             	adc    $0x0,%edx
  80080f:	f7 da                	neg    %edx
  800811:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800814:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800817:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80081a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081f:	e9 19 01 00 00       	jmp    80093d <vprintfmt+0x436>
	if (lflag >= 2)
  800824:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800828:	7f 29                	jg     800853 <vprintfmt+0x34c>
	else if (lflag)
  80082a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80082e:	74 44                	je     800874 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800830:	8b 45 14             	mov    0x14(%ebp),%eax
  800833:	8b 00                	mov    (%eax),%eax
  800835:	ba 00 00 00 00       	mov    $0x0,%edx
  80083a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80083d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800840:	8b 45 14             	mov    0x14(%ebp),%eax
  800843:	8d 40 04             	lea    0x4(%eax),%eax
  800846:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800849:	b8 0a 00 00 00       	mov    $0xa,%eax
  80084e:	e9 ea 00 00 00       	jmp    80093d <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800853:	8b 45 14             	mov    0x14(%ebp),%eax
  800856:	8b 50 04             	mov    0x4(%eax),%edx
  800859:	8b 00                	mov    (%eax),%eax
  80085b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80085e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8d 40 08             	lea    0x8(%eax),%eax
  800867:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80086a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80086f:	e9 c9 00 00 00       	jmp    80093d <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800874:	8b 45 14             	mov    0x14(%ebp),%eax
  800877:	8b 00                	mov    (%eax),%eax
  800879:	ba 00 00 00 00       	mov    $0x0,%edx
  80087e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800881:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800884:	8b 45 14             	mov    0x14(%ebp),%eax
  800887:	8d 40 04             	lea    0x4(%eax),%eax
  80088a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80088d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800892:	e9 a6 00 00 00       	jmp    80093d <vprintfmt+0x436>
			putch('0', putdat);
  800897:	83 ec 08             	sub    $0x8,%esp
  80089a:	56                   	push   %esi
  80089b:	6a 30                	push   $0x30
  80089d:	ff d3                	call   *%ebx
	if (lflag >= 2)
  80089f:	83 c4 10             	add    $0x10,%esp
  8008a2:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8008a6:	7f 26                	jg     8008ce <vprintfmt+0x3c7>
	else if (lflag)
  8008a8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8008ac:	74 3e                	je     8008ec <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  8008ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b1:	8b 00                	mov    (%eax),%eax
  8008b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008bb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008be:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c1:	8d 40 04             	lea    0x4(%eax),%eax
  8008c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008c7:	b8 08 00 00 00       	mov    $0x8,%eax
  8008cc:	eb 6f                	jmp    80093d <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8008ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d1:	8b 50 04             	mov    0x4(%eax),%edx
  8008d4:	8b 00                	mov    (%eax),%eax
  8008d6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008d9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008df:	8d 40 08             	lea    0x8(%eax),%eax
  8008e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008e5:	b8 08 00 00 00       	mov    $0x8,%eax
  8008ea:	eb 51                	jmp    80093d <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8008ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ef:	8b 00                	mov    (%eax),%eax
  8008f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008f9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ff:	8d 40 04             	lea    0x4(%eax),%eax
  800902:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800905:	b8 08 00 00 00       	mov    $0x8,%eax
  80090a:	eb 31                	jmp    80093d <vprintfmt+0x436>
			putch('0', putdat);
  80090c:	83 ec 08             	sub    $0x8,%esp
  80090f:	56                   	push   %esi
  800910:	6a 30                	push   $0x30
  800912:	ff d3                	call   *%ebx
			putch('x', putdat);
  800914:	83 c4 08             	add    $0x8,%esp
  800917:	56                   	push   %esi
  800918:	6a 78                	push   $0x78
  80091a:	ff d3                	call   *%ebx
			num = (unsigned long long)
  80091c:	8b 45 14             	mov    0x14(%ebp),%eax
  80091f:	8b 00                	mov    (%eax),%eax
  800921:	ba 00 00 00 00       	mov    $0x0,%edx
  800926:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800929:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  80092c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80092f:	8b 45 14             	mov    0x14(%ebp),%eax
  800932:	8d 40 04             	lea    0x4(%eax),%eax
  800935:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800938:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80093d:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800941:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800944:	89 c1                	mov    %eax,%ecx
  800946:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800949:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80094c:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800951:	89 c2                	mov    %eax,%edx
  800953:	39 c1                	cmp    %eax,%ecx
  800955:	0f 87 85 00 00 00    	ja     8009e0 <vprintfmt+0x4d9>
		tmp /= base;
  80095b:	89 d0                	mov    %edx,%eax
  80095d:	ba 00 00 00 00       	mov    $0x0,%edx
  800962:	f7 f1                	div    %ecx
		len++;
  800964:	83 c7 01             	add    $0x1,%edi
  800967:	eb e8                	jmp    800951 <vprintfmt+0x44a>
	if (lflag >= 2)
  800969:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80096d:	7f 26                	jg     800995 <vprintfmt+0x48e>
	else if (lflag)
  80096f:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800973:	74 3e                	je     8009b3 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800975:	8b 45 14             	mov    0x14(%ebp),%eax
  800978:	8b 00                	mov    (%eax),%eax
  80097a:	ba 00 00 00 00       	mov    $0x0,%edx
  80097f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800982:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800985:	8b 45 14             	mov    0x14(%ebp),%eax
  800988:	8d 40 04             	lea    0x4(%eax),%eax
  80098b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80098e:	b8 10 00 00 00       	mov    $0x10,%eax
  800993:	eb a8                	jmp    80093d <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800995:	8b 45 14             	mov    0x14(%ebp),%eax
  800998:	8b 50 04             	mov    0x4(%eax),%edx
  80099b:	8b 00                	mov    (%eax),%eax
  80099d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a6:	8d 40 08             	lea    0x8(%eax),%eax
  8009a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009ac:	b8 10 00 00 00       	mov    $0x10,%eax
  8009b1:	eb 8a                	jmp    80093d <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8009b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b6:	8b 00                	mov    (%eax),%eax
  8009b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009c0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c6:	8d 40 04             	lea    0x4(%eax),%eax
  8009c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009cc:	b8 10 00 00 00       	mov    $0x10,%eax
  8009d1:	e9 67 ff ff ff       	jmp    80093d <vprintfmt+0x436>
			base = 10;
  8009d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009db:	e9 5d ff ff ff       	jmp    80093d <vprintfmt+0x436>
  8009e0:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8009e3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e6:	29 f8                	sub    %edi,%eax
  8009e8:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8009ea:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8009ee:	74 15                	je     800a05 <vprintfmt+0x4fe>
		while (width > 0) {
  8009f0:	85 ff                	test   %edi,%edi
  8009f2:	7e 48                	jle    800a3c <vprintfmt+0x535>
			putch(padc, putdat);
  8009f4:	83 ec 08             	sub    $0x8,%esp
  8009f7:	56                   	push   %esi
  8009f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8009fb:	ff d3                	call   *%ebx
			width--;
  8009fd:	83 ef 01             	sub    $0x1,%edi
  800a00:	83 c4 10             	add    $0x10,%esp
  800a03:	eb eb                	jmp    8009f0 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a05:	83 ec 0c             	sub    $0xc,%esp
  800a08:	6a 2d                	push   $0x2d
  800a0a:	ff 75 cc             	pushl  -0x34(%ebp)
  800a0d:	ff 75 c8             	pushl  -0x38(%ebp)
  800a10:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a13:	ff 75 d0             	pushl  -0x30(%ebp)
  800a16:	89 f2                	mov    %esi,%edx
  800a18:	89 d8                	mov    %ebx,%eax
  800a1a:	e8 1e fa ff ff       	call   80043d <printnum_helper>
		width -= len;
  800a1f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a22:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800a25:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800a28:	85 ff                	test   %edi,%edi
  800a2a:	7e 2e                	jle    800a5a <vprintfmt+0x553>
			putch(padc, putdat);
  800a2c:	83 ec 08             	sub    $0x8,%esp
  800a2f:	56                   	push   %esi
  800a30:	6a 20                	push   $0x20
  800a32:	ff d3                	call   *%ebx
			width--;
  800a34:	83 ef 01             	sub    $0x1,%edi
  800a37:	83 c4 10             	add    $0x10,%esp
  800a3a:	eb ec                	jmp    800a28 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a3c:	83 ec 0c             	sub    $0xc,%esp
  800a3f:	ff 75 e0             	pushl  -0x20(%ebp)
  800a42:	ff 75 cc             	pushl  -0x34(%ebp)
  800a45:	ff 75 c8             	pushl  -0x38(%ebp)
  800a48:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a4b:	ff 75 d0             	pushl  -0x30(%ebp)
  800a4e:	89 f2                	mov    %esi,%edx
  800a50:	89 d8                	mov    %ebx,%eax
  800a52:	e8 e6 f9 ff ff       	call   80043d <printnum_helper>
  800a57:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800a5a:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a5d:	83 c7 01             	add    $0x1,%edi
  800a60:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a64:	83 f8 25             	cmp    $0x25,%eax
  800a67:	0f 84 b1 fa ff ff    	je     80051e <vprintfmt+0x17>
			if (ch == '\0')
  800a6d:	85 c0                	test   %eax,%eax
  800a6f:	0f 84 a1 00 00 00    	je     800b16 <vprintfmt+0x60f>
			putch(ch, putdat);
  800a75:	83 ec 08             	sub    $0x8,%esp
  800a78:	56                   	push   %esi
  800a79:	50                   	push   %eax
  800a7a:	ff d3                	call   *%ebx
  800a7c:	83 c4 10             	add    $0x10,%esp
  800a7f:	eb dc                	jmp    800a5d <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800a81:	8b 45 14             	mov    0x14(%ebp),%eax
  800a84:	83 c0 04             	add    $0x4,%eax
  800a87:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8d:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800a8f:	85 ff                	test   %edi,%edi
  800a91:	74 15                	je     800aa8 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800a93:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800a99:	7f 29                	jg     800ac4 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800a9b:	0f b6 06             	movzbl (%esi),%eax
  800a9e:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800aa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800aa3:	89 45 14             	mov    %eax,0x14(%ebp)
  800aa6:	eb b2                	jmp    800a5a <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800aa8:	68 78 12 80 00       	push   $0x801278
  800aad:	68 e2 11 80 00       	push   $0x8011e2
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	e8 31 fa ff ff       	call   8004ea <printfmt>
  800ab9:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800abc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800abf:	89 45 14             	mov    %eax,0x14(%ebp)
  800ac2:	eb 96                	jmp    800a5a <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800ac4:	68 b0 12 80 00       	push   $0x8012b0
  800ac9:	68 e2 11 80 00       	push   $0x8011e2
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
  800ad0:	e8 15 fa ff ff       	call   8004ea <printfmt>
				*res = -1;
  800ad5:	c6 07 ff             	movb   $0xff,(%edi)
  800ad8:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800adb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ade:	89 45 14             	mov    %eax,0x14(%ebp)
  800ae1:	e9 74 ff ff ff       	jmp    800a5a <vprintfmt+0x553>
			putch(ch, putdat);
  800ae6:	83 ec 08             	sub    $0x8,%esp
  800ae9:	56                   	push   %esi
  800aea:	6a 25                	push   $0x25
  800aec:	ff d3                	call   *%ebx
			break;
  800aee:	83 c4 10             	add    $0x10,%esp
  800af1:	e9 64 ff ff ff       	jmp    800a5a <vprintfmt+0x553>
			putch('%', putdat);
  800af6:	83 ec 08             	sub    $0x8,%esp
  800af9:	56                   	push   %esi
  800afa:	6a 25                	push   $0x25
  800afc:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800afe:	83 c4 10             	add    $0x10,%esp
  800b01:	89 f8                	mov    %edi,%eax
  800b03:	eb 03                	jmp    800b08 <vprintfmt+0x601>
  800b05:	83 e8 01             	sub    $0x1,%eax
  800b08:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800b0c:	75 f7                	jne    800b05 <vprintfmt+0x5fe>
  800b0e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b11:	e9 44 ff ff ff       	jmp    800a5a <vprintfmt+0x553>
}
  800b16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	83 ec 18             	sub    $0x18,%esp
  800b24:	8b 45 08             	mov    0x8(%ebp),%eax
  800b27:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b2d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b31:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b34:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	74 26                	je     800b65 <vsnprintf+0x47>
  800b3f:	85 d2                	test   %edx,%edx
  800b41:	7e 22                	jle    800b65 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b43:	ff 75 14             	pushl  0x14(%ebp)
  800b46:	ff 75 10             	pushl  0x10(%ebp)
  800b49:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b4c:	50                   	push   %eax
  800b4d:	68 cd 04 80 00       	push   $0x8004cd
  800b52:	e8 b0 f9 ff ff       	call   800507 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b57:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b60:	83 c4 10             	add    $0x10,%esp
}
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    
		return -E_INVAL;
  800b65:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b6a:	eb f7                	jmp    800b63 <vsnprintf+0x45>

00800b6c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b72:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b75:	50                   	push   %eax
  800b76:	ff 75 10             	pushl  0x10(%ebp)
  800b79:	ff 75 0c             	pushl  0xc(%ebp)
  800b7c:	ff 75 08             	pushl  0x8(%ebp)
  800b7f:	e8 9a ff ff ff       	call   800b1e <vsnprintf>
	va_end(ap);

	return rc;
}
  800b84:	c9                   	leave  
  800b85:	c3                   	ret    

00800b86 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b91:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b95:	74 05                	je     800b9c <strlen+0x16>
		n++;
  800b97:	83 c0 01             	add    $0x1,%eax
  800b9a:	eb f5                	jmp    800b91 <strlen+0xb>
	return n;
}
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bac:	39 c2                	cmp    %eax,%edx
  800bae:	74 0d                	je     800bbd <strnlen+0x1f>
  800bb0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800bb4:	74 05                	je     800bbb <strnlen+0x1d>
		n++;
  800bb6:	83 c2 01             	add    $0x1,%edx
  800bb9:	eb f1                	jmp    800bac <strnlen+0xe>
  800bbb:	89 d0                	mov    %edx,%eax
	return n;
}
  800bbd:	5d                   	pop    %ebp
  800bbe:	c3                   	ret    

00800bbf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	53                   	push   %ebx
  800bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bce:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bd2:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bd5:	83 c2 01             	add    $0x1,%edx
  800bd8:	84 c9                	test   %cl,%cl
  800bda:	75 f2                	jne    800bce <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	53                   	push   %ebx
  800be3:	83 ec 10             	sub    $0x10,%esp
  800be6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800be9:	53                   	push   %ebx
  800bea:	e8 97 ff ff ff       	call   800b86 <strlen>
  800bef:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800bf2:	ff 75 0c             	pushl  0xc(%ebp)
  800bf5:	01 d8                	add    %ebx,%eax
  800bf7:	50                   	push   %eax
  800bf8:	e8 c2 ff ff ff       	call   800bbf <strcpy>
	return dst;
}
  800bfd:	89 d8                	mov    %ebx,%eax
  800bff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	89 c6                	mov    %eax,%esi
  800c11:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c14:	89 c2                	mov    %eax,%edx
  800c16:	39 f2                	cmp    %esi,%edx
  800c18:	74 11                	je     800c2b <strncpy+0x27>
		*dst++ = *src;
  800c1a:	83 c2 01             	add    $0x1,%edx
  800c1d:	0f b6 19             	movzbl (%ecx),%ebx
  800c20:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c23:	80 fb 01             	cmp    $0x1,%bl
  800c26:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800c29:	eb eb                	jmp    800c16 <strncpy+0x12>
	}
	return ret;
}
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5d                   	pop    %ebp
  800c2e:	c3                   	ret    

00800c2f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	8b 75 08             	mov    0x8(%ebp),%esi
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3a:	8b 55 10             	mov    0x10(%ebp),%edx
  800c3d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c3f:	85 d2                	test   %edx,%edx
  800c41:	74 21                	je     800c64 <strlcpy+0x35>
  800c43:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c47:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800c49:	39 c2                	cmp    %eax,%edx
  800c4b:	74 14                	je     800c61 <strlcpy+0x32>
  800c4d:	0f b6 19             	movzbl (%ecx),%ebx
  800c50:	84 db                	test   %bl,%bl
  800c52:	74 0b                	je     800c5f <strlcpy+0x30>
			*dst++ = *src++;
  800c54:	83 c1 01             	add    $0x1,%ecx
  800c57:	83 c2 01             	add    $0x1,%edx
  800c5a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c5d:	eb ea                	jmp    800c49 <strlcpy+0x1a>
  800c5f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c61:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c64:	29 f0                	sub    %esi,%eax
}
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c70:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c73:	0f b6 01             	movzbl (%ecx),%eax
  800c76:	84 c0                	test   %al,%al
  800c78:	74 0c                	je     800c86 <strcmp+0x1c>
  800c7a:	3a 02                	cmp    (%edx),%al
  800c7c:	75 08                	jne    800c86 <strcmp+0x1c>
		p++, q++;
  800c7e:	83 c1 01             	add    $0x1,%ecx
  800c81:	83 c2 01             	add    $0x1,%edx
  800c84:	eb ed                	jmp    800c73 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c86:	0f b6 c0             	movzbl %al,%eax
  800c89:	0f b6 12             	movzbl (%edx),%edx
  800c8c:	29 d0                	sub    %edx,%eax
}
  800c8e:	5d                   	pop    %ebp
  800c8f:	c3                   	ret    

00800c90 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	53                   	push   %ebx
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9a:	89 c3                	mov    %eax,%ebx
  800c9c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c9f:	eb 06                	jmp    800ca7 <strncmp+0x17>
		n--, p++, q++;
  800ca1:	83 c0 01             	add    $0x1,%eax
  800ca4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ca7:	39 d8                	cmp    %ebx,%eax
  800ca9:	74 16                	je     800cc1 <strncmp+0x31>
  800cab:	0f b6 08             	movzbl (%eax),%ecx
  800cae:	84 c9                	test   %cl,%cl
  800cb0:	74 04                	je     800cb6 <strncmp+0x26>
  800cb2:	3a 0a                	cmp    (%edx),%cl
  800cb4:	74 eb                	je     800ca1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb6:	0f b6 00             	movzbl (%eax),%eax
  800cb9:	0f b6 12             	movzbl (%edx),%edx
  800cbc:	29 d0                	sub    %edx,%eax
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    
		return 0;
  800cc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc6:	eb f6                	jmp    800cbe <strncmp+0x2e>

00800cc8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd2:	0f b6 10             	movzbl (%eax),%edx
  800cd5:	84 d2                	test   %dl,%dl
  800cd7:	74 09                	je     800ce2 <strchr+0x1a>
		if (*s == c)
  800cd9:	38 ca                	cmp    %cl,%dl
  800cdb:	74 0a                	je     800ce7 <strchr+0x1f>
	for (; *s; s++)
  800cdd:	83 c0 01             	add    $0x1,%eax
  800ce0:	eb f0                	jmp    800cd2 <strchr+0xa>
			return (char *) s;
	return 0;
  800ce2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	8b 45 08             	mov    0x8(%ebp),%eax
  800cef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cf6:	38 ca                	cmp    %cl,%dl
  800cf8:	74 09                	je     800d03 <strfind+0x1a>
  800cfa:	84 d2                	test   %dl,%dl
  800cfc:	74 05                	je     800d03 <strfind+0x1a>
	for (; *s; s++)
  800cfe:	83 c0 01             	add    $0x1,%eax
  800d01:	eb f0                	jmp    800cf3 <strfind+0xa>
			break;
	return (char *) s;
}
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    

00800d05 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	57                   	push   %edi
  800d09:	56                   	push   %esi
  800d0a:	53                   	push   %ebx
  800d0b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d11:	85 c9                	test   %ecx,%ecx
  800d13:	74 31                	je     800d46 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d15:	89 f8                	mov    %edi,%eax
  800d17:	09 c8                	or     %ecx,%eax
  800d19:	a8 03                	test   $0x3,%al
  800d1b:	75 23                	jne    800d40 <memset+0x3b>
		c &= 0xFF;
  800d1d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d21:	89 d3                	mov    %edx,%ebx
  800d23:	c1 e3 08             	shl    $0x8,%ebx
  800d26:	89 d0                	mov    %edx,%eax
  800d28:	c1 e0 18             	shl    $0x18,%eax
  800d2b:	89 d6                	mov    %edx,%esi
  800d2d:	c1 e6 10             	shl    $0x10,%esi
  800d30:	09 f0                	or     %esi,%eax
  800d32:	09 c2                	or     %eax,%edx
  800d34:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d36:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d39:	89 d0                	mov    %edx,%eax
  800d3b:	fc                   	cld    
  800d3c:	f3 ab                	rep stos %eax,%es:(%edi)
  800d3e:	eb 06                	jmp    800d46 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d43:	fc                   	cld    
  800d44:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d46:	89 f8                	mov    %edi,%eax
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d58:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d5b:	39 c6                	cmp    %eax,%esi
  800d5d:	73 32                	jae    800d91 <memmove+0x44>
  800d5f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d62:	39 c2                	cmp    %eax,%edx
  800d64:	76 2b                	jbe    800d91 <memmove+0x44>
		s += n;
		d += n;
  800d66:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d69:	89 fe                	mov    %edi,%esi
  800d6b:	09 ce                	or     %ecx,%esi
  800d6d:	09 d6                	or     %edx,%esi
  800d6f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d75:	75 0e                	jne    800d85 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d77:	83 ef 04             	sub    $0x4,%edi
  800d7a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d7d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d80:	fd                   	std    
  800d81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d83:	eb 09                	jmp    800d8e <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d85:	83 ef 01             	sub    $0x1,%edi
  800d88:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d8b:	fd                   	std    
  800d8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d8e:	fc                   	cld    
  800d8f:	eb 1a                	jmp    800dab <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	09 ca                	or     %ecx,%edx
  800d95:	09 f2                	or     %esi,%edx
  800d97:	f6 c2 03             	test   $0x3,%dl
  800d9a:	75 0a                	jne    800da6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d9c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d9f:	89 c7                	mov    %eax,%edi
  800da1:	fc                   	cld    
  800da2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800da4:	eb 05                	jmp    800dab <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800da6:	89 c7                	mov    %eax,%edi
  800da8:	fc                   	cld    
  800da9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dab:	5e                   	pop    %esi
  800dac:	5f                   	pop    %edi
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800db5:	ff 75 10             	pushl  0x10(%ebp)
  800db8:	ff 75 0c             	pushl  0xc(%ebp)
  800dbb:	ff 75 08             	pushl  0x8(%ebp)
  800dbe:	e8 8a ff ff ff       	call   800d4d <memmove>
}
  800dc3:	c9                   	leave  
  800dc4:	c3                   	ret    

00800dc5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd0:	89 c6                	mov    %eax,%esi
  800dd2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd5:	39 f0                	cmp    %esi,%eax
  800dd7:	74 1c                	je     800df5 <memcmp+0x30>
		if (*s1 != *s2)
  800dd9:	0f b6 08             	movzbl (%eax),%ecx
  800ddc:	0f b6 1a             	movzbl (%edx),%ebx
  800ddf:	38 d9                	cmp    %bl,%cl
  800de1:	75 08                	jne    800deb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800de3:	83 c0 01             	add    $0x1,%eax
  800de6:	83 c2 01             	add    $0x1,%edx
  800de9:	eb ea                	jmp    800dd5 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800deb:	0f b6 c1             	movzbl %cl,%eax
  800dee:	0f b6 db             	movzbl %bl,%ebx
  800df1:	29 d8                	sub    %ebx,%eax
  800df3:	eb 05                	jmp    800dfa <memcmp+0x35>
	}

	return 0;
  800df5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e07:	89 c2                	mov    %eax,%edx
  800e09:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e0c:	39 d0                	cmp    %edx,%eax
  800e0e:	73 09                	jae    800e19 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e10:	38 08                	cmp    %cl,(%eax)
  800e12:	74 05                	je     800e19 <memfind+0x1b>
	for (; s < ends; s++)
  800e14:	83 c0 01             	add    $0x1,%eax
  800e17:	eb f3                	jmp    800e0c <memfind+0xe>
			break;
	return (void *) s;
}
  800e19:	5d                   	pop    %ebp
  800e1a:	c3                   	ret    

00800e1b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	57                   	push   %edi
  800e1f:	56                   	push   %esi
  800e20:	53                   	push   %ebx
  800e21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e27:	eb 03                	jmp    800e2c <strtol+0x11>
		s++;
  800e29:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e2c:	0f b6 01             	movzbl (%ecx),%eax
  800e2f:	3c 20                	cmp    $0x20,%al
  800e31:	74 f6                	je     800e29 <strtol+0xe>
  800e33:	3c 09                	cmp    $0x9,%al
  800e35:	74 f2                	je     800e29 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e37:	3c 2b                	cmp    $0x2b,%al
  800e39:	74 2a                	je     800e65 <strtol+0x4a>
	int neg = 0;
  800e3b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e40:	3c 2d                	cmp    $0x2d,%al
  800e42:	74 2b                	je     800e6f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e44:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e4a:	75 0f                	jne    800e5b <strtol+0x40>
  800e4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e4f:	74 28                	je     800e79 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e51:	85 db                	test   %ebx,%ebx
  800e53:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e58:	0f 44 d8             	cmove  %eax,%ebx
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e60:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e63:	eb 50                	jmp    800eb5 <strtol+0x9a>
		s++;
  800e65:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e68:	bf 00 00 00 00       	mov    $0x0,%edi
  800e6d:	eb d5                	jmp    800e44 <strtol+0x29>
		s++, neg = 1;
  800e6f:	83 c1 01             	add    $0x1,%ecx
  800e72:	bf 01 00 00 00       	mov    $0x1,%edi
  800e77:	eb cb                	jmp    800e44 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e79:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e7d:	74 0e                	je     800e8d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e7f:	85 db                	test   %ebx,%ebx
  800e81:	75 d8                	jne    800e5b <strtol+0x40>
		s++, base = 8;
  800e83:	83 c1 01             	add    $0x1,%ecx
  800e86:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e8b:	eb ce                	jmp    800e5b <strtol+0x40>
		s += 2, base = 16;
  800e8d:	83 c1 02             	add    $0x2,%ecx
  800e90:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e95:	eb c4                	jmp    800e5b <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800e97:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e9a:	89 f3                	mov    %esi,%ebx
  800e9c:	80 fb 19             	cmp    $0x19,%bl
  800e9f:	77 29                	ja     800eca <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ea1:	0f be d2             	movsbl %dl,%edx
  800ea4:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ea7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800eaa:	7d 30                	jge    800edc <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800eac:	83 c1 01             	add    $0x1,%ecx
  800eaf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800eb3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800eb5:	0f b6 11             	movzbl (%ecx),%edx
  800eb8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ebb:	89 f3                	mov    %esi,%ebx
  800ebd:	80 fb 09             	cmp    $0x9,%bl
  800ec0:	77 d5                	ja     800e97 <strtol+0x7c>
			dig = *s - '0';
  800ec2:	0f be d2             	movsbl %dl,%edx
  800ec5:	83 ea 30             	sub    $0x30,%edx
  800ec8:	eb dd                	jmp    800ea7 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800eca:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ecd:	89 f3                	mov    %esi,%ebx
  800ecf:	80 fb 19             	cmp    $0x19,%bl
  800ed2:	77 08                	ja     800edc <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ed4:	0f be d2             	movsbl %dl,%edx
  800ed7:	83 ea 37             	sub    $0x37,%edx
  800eda:	eb cb                	jmp    800ea7 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800edc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ee0:	74 05                	je     800ee7 <strtol+0xcc>
		*endptr = (char *) s;
  800ee2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ee5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ee7:	89 c2                	mov    %eax,%edx
  800ee9:	f7 da                	neg    %edx
  800eeb:	85 ff                	test   %edi,%edi
  800eed:	0f 45 c2             	cmovne %edx,%eax
}
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	66 90                	xchg   %ax,%ax
  800ef7:	66 90                	xchg   %ax,%ax
  800ef9:	66 90                	xchg   %ax,%ax
  800efb:	66 90                	xchg   %ax,%ax
  800efd:	66 90                	xchg   %ax,%ax
  800eff:	90                   	nop

00800f00 <__udivdi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 1c             	sub    $0x1c,%esp
  800f07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f0b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f13:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f17:	85 d2                	test   %edx,%edx
  800f19:	75 4d                	jne    800f68 <__udivdi3+0x68>
  800f1b:	39 f3                	cmp    %esi,%ebx
  800f1d:	76 19                	jbe    800f38 <__udivdi3+0x38>
  800f1f:	31 ff                	xor    %edi,%edi
  800f21:	89 e8                	mov    %ebp,%eax
  800f23:	89 f2                	mov    %esi,%edx
  800f25:	f7 f3                	div    %ebx
  800f27:	89 fa                	mov    %edi,%edx
  800f29:	83 c4 1c             	add    $0x1c,%esp
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    
  800f31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f38:	89 d9                	mov    %ebx,%ecx
  800f3a:	85 db                	test   %ebx,%ebx
  800f3c:	75 0b                	jne    800f49 <__udivdi3+0x49>
  800f3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f43:	31 d2                	xor    %edx,%edx
  800f45:	f7 f3                	div    %ebx
  800f47:	89 c1                	mov    %eax,%ecx
  800f49:	31 d2                	xor    %edx,%edx
  800f4b:	89 f0                	mov    %esi,%eax
  800f4d:	f7 f1                	div    %ecx
  800f4f:	89 c6                	mov    %eax,%esi
  800f51:	89 e8                	mov    %ebp,%eax
  800f53:	89 f7                	mov    %esi,%edi
  800f55:	f7 f1                	div    %ecx
  800f57:	89 fa                	mov    %edi,%edx
  800f59:	83 c4 1c             	add    $0x1c,%esp
  800f5c:	5b                   	pop    %ebx
  800f5d:	5e                   	pop    %esi
  800f5e:	5f                   	pop    %edi
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    
  800f61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f68:	39 f2                	cmp    %esi,%edx
  800f6a:	77 1c                	ja     800f88 <__udivdi3+0x88>
  800f6c:	0f bd fa             	bsr    %edx,%edi
  800f6f:	83 f7 1f             	xor    $0x1f,%edi
  800f72:	75 2c                	jne    800fa0 <__udivdi3+0xa0>
  800f74:	39 f2                	cmp    %esi,%edx
  800f76:	72 06                	jb     800f7e <__udivdi3+0x7e>
  800f78:	31 c0                	xor    %eax,%eax
  800f7a:	39 eb                	cmp    %ebp,%ebx
  800f7c:	77 a9                	ja     800f27 <__udivdi3+0x27>
  800f7e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f83:	eb a2                	jmp    800f27 <__udivdi3+0x27>
  800f85:	8d 76 00             	lea    0x0(%esi),%esi
  800f88:	31 ff                	xor    %edi,%edi
  800f8a:	31 c0                	xor    %eax,%eax
  800f8c:	89 fa                	mov    %edi,%edx
  800f8e:	83 c4 1c             	add    $0x1c,%esp
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    
  800f96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f9d:	8d 76 00             	lea    0x0(%esi),%esi
  800fa0:	89 f9                	mov    %edi,%ecx
  800fa2:	b8 20 00 00 00       	mov    $0x20,%eax
  800fa7:	29 f8                	sub    %edi,%eax
  800fa9:	d3 e2                	shl    %cl,%edx
  800fab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800faf:	89 c1                	mov    %eax,%ecx
  800fb1:	89 da                	mov    %ebx,%edx
  800fb3:	d3 ea                	shr    %cl,%edx
  800fb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fb9:	09 d1                	or     %edx,%ecx
  800fbb:	89 f2                	mov    %esi,%edx
  800fbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fc1:	89 f9                	mov    %edi,%ecx
  800fc3:	d3 e3                	shl    %cl,%ebx
  800fc5:	89 c1                	mov    %eax,%ecx
  800fc7:	d3 ea                	shr    %cl,%edx
  800fc9:	89 f9                	mov    %edi,%ecx
  800fcb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fcf:	89 eb                	mov    %ebp,%ebx
  800fd1:	d3 e6                	shl    %cl,%esi
  800fd3:	89 c1                	mov    %eax,%ecx
  800fd5:	d3 eb                	shr    %cl,%ebx
  800fd7:	09 de                	or     %ebx,%esi
  800fd9:	89 f0                	mov    %esi,%eax
  800fdb:	f7 74 24 08          	divl   0x8(%esp)
  800fdf:	89 d6                	mov    %edx,%esi
  800fe1:	89 c3                	mov    %eax,%ebx
  800fe3:	f7 64 24 0c          	mull   0xc(%esp)
  800fe7:	39 d6                	cmp    %edx,%esi
  800fe9:	72 15                	jb     801000 <__udivdi3+0x100>
  800feb:	89 f9                	mov    %edi,%ecx
  800fed:	d3 e5                	shl    %cl,%ebp
  800fef:	39 c5                	cmp    %eax,%ebp
  800ff1:	73 04                	jae    800ff7 <__udivdi3+0xf7>
  800ff3:	39 d6                	cmp    %edx,%esi
  800ff5:	74 09                	je     801000 <__udivdi3+0x100>
  800ff7:	89 d8                	mov    %ebx,%eax
  800ff9:	31 ff                	xor    %edi,%edi
  800ffb:	e9 27 ff ff ff       	jmp    800f27 <__udivdi3+0x27>
  801000:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801003:	31 ff                	xor    %edi,%edi
  801005:	e9 1d ff ff ff       	jmp    800f27 <__udivdi3+0x27>
  80100a:	66 90                	xchg   %ax,%ax
  80100c:	66 90                	xchg   %ax,%ax
  80100e:	66 90                	xchg   %ax,%ax

00801010 <__umoddi3>:
  801010:	55                   	push   %ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	83 ec 1c             	sub    $0x1c,%esp
  801017:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80101b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80101f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801027:	89 da                	mov    %ebx,%edx
  801029:	85 c0                	test   %eax,%eax
  80102b:	75 43                	jne    801070 <__umoddi3+0x60>
  80102d:	39 df                	cmp    %ebx,%edi
  80102f:	76 17                	jbe    801048 <__umoddi3+0x38>
  801031:	89 f0                	mov    %esi,%eax
  801033:	f7 f7                	div    %edi
  801035:	89 d0                	mov    %edx,%eax
  801037:	31 d2                	xor    %edx,%edx
  801039:	83 c4 1c             	add    $0x1c,%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    
  801041:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801048:	89 fd                	mov    %edi,%ebp
  80104a:	85 ff                	test   %edi,%edi
  80104c:	75 0b                	jne    801059 <__umoddi3+0x49>
  80104e:	b8 01 00 00 00       	mov    $0x1,%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	f7 f7                	div    %edi
  801057:	89 c5                	mov    %eax,%ebp
  801059:	89 d8                	mov    %ebx,%eax
  80105b:	31 d2                	xor    %edx,%edx
  80105d:	f7 f5                	div    %ebp
  80105f:	89 f0                	mov    %esi,%eax
  801061:	f7 f5                	div    %ebp
  801063:	89 d0                	mov    %edx,%eax
  801065:	eb d0                	jmp    801037 <__umoddi3+0x27>
  801067:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80106e:	66 90                	xchg   %ax,%ax
  801070:	89 f1                	mov    %esi,%ecx
  801072:	39 d8                	cmp    %ebx,%eax
  801074:	76 0a                	jbe    801080 <__umoddi3+0x70>
  801076:	89 f0                	mov    %esi,%eax
  801078:	83 c4 1c             	add    $0x1c,%esp
  80107b:	5b                   	pop    %ebx
  80107c:	5e                   	pop    %esi
  80107d:	5f                   	pop    %edi
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    
  801080:	0f bd e8             	bsr    %eax,%ebp
  801083:	83 f5 1f             	xor    $0x1f,%ebp
  801086:	75 20                	jne    8010a8 <__umoddi3+0x98>
  801088:	39 d8                	cmp    %ebx,%eax
  80108a:	0f 82 b0 00 00 00    	jb     801140 <__umoddi3+0x130>
  801090:	39 f7                	cmp    %esi,%edi
  801092:	0f 86 a8 00 00 00    	jbe    801140 <__umoddi3+0x130>
  801098:	89 c8                	mov    %ecx,%eax
  80109a:	83 c4 1c             	add    $0x1c,%esp
  80109d:	5b                   	pop    %ebx
  80109e:	5e                   	pop    %esi
  80109f:	5f                   	pop    %edi
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    
  8010a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010a8:	89 e9                	mov    %ebp,%ecx
  8010aa:	ba 20 00 00 00       	mov    $0x20,%edx
  8010af:	29 ea                	sub    %ebp,%edx
  8010b1:	d3 e0                	shl    %cl,%eax
  8010b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010b7:	89 d1                	mov    %edx,%ecx
  8010b9:	89 f8                	mov    %edi,%eax
  8010bb:	d3 e8                	shr    %cl,%eax
  8010bd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010c5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010c9:	09 c1                	or     %eax,%ecx
  8010cb:	89 d8                	mov    %ebx,%eax
  8010cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010d1:	89 e9                	mov    %ebp,%ecx
  8010d3:	d3 e7                	shl    %cl,%edi
  8010d5:	89 d1                	mov    %edx,%ecx
  8010d7:	d3 e8                	shr    %cl,%eax
  8010d9:	89 e9                	mov    %ebp,%ecx
  8010db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010df:	d3 e3                	shl    %cl,%ebx
  8010e1:	89 c7                	mov    %eax,%edi
  8010e3:	89 d1                	mov    %edx,%ecx
  8010e5:	89 f0                	mov    %esi,%eax
  8010e7:	d3 e8                	shr    %cl,%eax
  8010e9:	89 e9                	mov    %ebp,%ecx
  8010eb:	89 fa                	mov    %edi,%edx
  8010ed:	d3 e6                	shl    %cl,%esi
  8010ef:	09 d8                	or     %ebx,%eax
  8010f1:	f7 74 24 08          	divl   0x8(%esp)
  8010f5:	89 d1                	mov    %edx,%ecx
  8010f7:	89 f3                	mov    %esi,%ebx
  8010f9:	f7 64 24 0c          	mull   0xc(%esp)
  8010fd:	89 c6                	mov    %eax,%esi
  8010ff:	89 d7                	mov    %edx,%edi
  801101:	39 d1                	cmp    %edx,%ecx
  801103:	72 06                	jb     80110b <__umoddi3+0xfb>
  801105:	75 10                	jne    801117 <__umoddi3+0x107>
  801107:	39 c3                	cmp    %eax,%ebx
  801109:	73 0c                	jae    801117 <__umoddi3+0x107>
  80110b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80110f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801113:	89 d7                	mov    %edx,%edi
  801115:	89 c6                	mov    %eax,%esi
  801117:	89 ca                	mov    %ecx,%edx
  801119:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80111e:	29 f3                	sub    %esi,%ebx
  801120:	19 fa                	sbb    %edi,%edx
  801122:	89 d0                	mov    %edx,%eax
  801124:	d3 e0                	shl    %cl,%eax
  801126:	89 e9                	mov    %ebp,%ecx
  801128:	d3 eb                	shr    %cl,%ebx
  80112a:	d3 ea                	shr    %cl,%edx
  80112c:	09 d8                	or     %ebx,%eax
  80112e:	83 c4 1c             	add    $0x1c,%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    
  801136:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80113d:	8d 76 00             	lea    0x0(%esi),%esi
  801140:	89 da                	mov    %ebx,%edx
  801142:	29 fe                	sub    %edi,%esi
  801144:	19 c2                	sbb    %eax,%edx
  801146:	89 f1                	mov    %esi,%ecx
  801148:	89 c8                	mov    %ecx,%eax
  80114a:	e9 4b ff ff ff       	jmp    80109a <__umoddi3+0x8a>
