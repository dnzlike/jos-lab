
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 04 00 00 00       	call   800035 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $3");
  800033:	cc                   	int3   
}
  800034:	c3                   	ret    

00800035 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800035:	55                   	push   %ebp
  800036:	89 e5                	mov    %esp,%ebp
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800040:	e8 c6 00 00 00       	call   80010b <sys_getenvid>
  800045:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004a:	c1 e0 07             	shl    $0x7,%eax
  80004d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800052:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800057:	85 db                	test   %ebx,%ebx
  800059:	7e 07                	jle    800062 <libmain+0x2d>
		binaryname = argv[0];
  80005b:	8b 06                	mov    (%esi),%eax
  80005d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800062:	83 ec 08             	sub    $0x8,%esp
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	e8 c7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006c:	e8 0a 00 00 00       	call   80007b <exit>
}
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800077:	5b                   	pop    %ebx
  800078:	5e                   	pop    %esi
  800079:	5d                   	pop    %ebp
  80007a:	c3                   	ret    

0080007b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800081:	6a 00                	push   $0x0
  800083:	e8 42 00 00 00       	call   8000ca <sys_env_destroy>
}
  800088:	83 c4 10             	add    $0x10,%esp
  80008b:	c9                   	leave  
  80008c:	c3                   	ret    

0080008d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	57                   	push   %edi
  800091:	56                   	push   %esi
  800092:	53                   	push   %ebx
	asm volatile("int %1\n"
  800093:	b8 00 00 00 00       	mov    $0x0,%eax
  800098:	8b 55 08             	mov    0x8(%ebp),%edx
  80009b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009e:	89 c3                	mov    %eax,%ebx
  8000a0:	89 c7                	mov    %eax,%edi
  8000a2:	89 c6                	mov    %eax,%esi
  8000a4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a6:	5b                   	pop    %ebx
  8000a7:	5e                   	pop    %esi
  8000a8:	5f                   	pop    %edi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bb:	89 d1                	mov    %edx,%ecx
  8000bd:	89 d3                	mov    %edx,%ebx
  8000bf:	89 d7                	mov    %edx,%edi
  8000c1:	89 d6                	mov    %edx,%esi
  8000c3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
  8000d0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e0:	89 cb                	mov    %ecx,%ebx
  8000e2:	89 cf                	mov    %ecx,%edi
  8000e4:	89 ce                	mov    %ecx,%esi
  8000e6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	7f 08                	jg     8000f4 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f4:	83 ec 0c             	sub    $0xc,%esp
  8000f7:	50                   	push   %eax
  8000f8:	6a 03                	push   $0x3
  8000fa:	68 4a 11 80 00       	push   $0x80114a
  8000ff:	6a 23                	push   $0x23
  800101:	68 67 11 80 00       	push   $0x801167
  800106:	e8 2e 02 00 00       	call   800339 <_panic>

0080010b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	57                   	push   %edi
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
	asm volatile("int %1\n"
  800111:	ba 00 00 00 00       	mov    $0x0,%edx
  800116:	b8 02 00 00 00       	mov    $0x2,%eax
  80011b:	89 d1                	mov    %edx,%ecx
  80011d:	89 d3                	mov    %edx,%ebx
  80011f:	89 d7                	mov    %edx,%edi
  800121:	89 d6                	mov    %edx,%esi
  800123:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_yield>:

void
sys_yield(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
  80014f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800152:	be 00 00 00 00       	mov    $0x0,%esi
  800157:	8b 55 08             	mov    0x8(%ebp),%edx
  80015a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80015d:	b8 04 00 00 00       	mov    $0x4,%eax
  800162:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800165:	89 f7                	mov    %esi,%edi
  800167:	cd 30                	int    $0x30
	if(check && ret > 0)
  800169:	85 c0                	test   %eax,%eax
  80016b:	7f 08                	jg     800175 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80016d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800170:	5b                   	pop    %ebx
  800171:	5e                   	pop    %esi
  800172:	5f                   	pop    %edi
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800175:	83 ec 0c             	sub    $0xc,%esp
  800178:	50                   	push   %eax
  800179:	6a 04                	push   $0x4
  80017b:	68 4a 11 80 00       	push   $0x80114a
  800180:	6a 23                	push   $0x23
  800182:	68 67 11 80 00       	push   $0x801167
  800187:	e8 ad 01 00 00       	call   800339 <_panic>

0080018c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
  800192:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800195:	8b 55 08             	mov    0x8(%ebp),%edx
  800198:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019b:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001a6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001a9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ab:	85 c0                	test   %eax,%eax
  8001ad:	7f 08                	jg     8001b7 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b2:	5b                   	pop    %ebx
  8001b3:	5e                   	pop    %esi
  8001b4:	5f                   	pop    %edi
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	50                   	push   %eax
  8001bb:	6a 05                	push   $0x5
  8001bd:	68 4a 11 80 00       	push   $0x80114a
  8001c2:	6a 23                	push   $0x23
  8001c4:	68 67 11 80 00       	push   $0x801167
  8001c9:	e8 6b 01 00 00       	call   800339 <_panic>

008001ce <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	57                   	push   %edi
  8001d2:	56                   	push   %esi
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e7:	89 df                	mov    %ebx,%edi
  8001e9:	89 de                	mov    %ebx,%esi
  8001eb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ed:	85 c0                	test   %eax,%eax
  8001ef:	7f 08                	jg     8001f9 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f4:	5b                   	pop    %ebx
  8001f5:	5e                   	pop    %esi
  8001f6:	5f                   	pop    %edi
  8001f7:	5d                   	pop    %ebp
  8001f8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f9:	83 ec 0c             	sub    $0xc,%esp
  8001fc:	50                   	push   %eax
  8001fd:	6a 06                	push   $0x6
  8001ff:	68 4a 11 80 00       	push   $0x80114a
  800204:	6a 23                	push   $0x23
  800206:	68 67 11 80 00       	push   $0x801167
  80020b:	e8 29 01 00 00       	call   800339 <_panic>

00800210 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021e:	8b 55 08             	mov    0x8(%ebp),%edx
  800221:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800224:	b8 08 00 00 00       	mov    $0x8,%eax
  800229:	89 df                	mov    %ebx,%edi
  80022b:	89 de                	mov    %ebx,%esi
  80022d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80022f:	85 c0                	test   %eax,%eax
  800231:	7f 08                	jg     80023b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800233:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800236:	5b                   	pop    %ebx
  800237:	5e                   	pop    %esi
  800238:	5f                   	pop    %edi
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	50                   	push   %eax
  80023f:	6a 08                	push   $0x8
  800241:	68 4a 11 80 00       	push   $0x80114a
  800246:	6a 23                	push   $0x23
  800248:	68 67 11 80 00       	push   $0x801167
  80024d:	e8 e7 00 00 00       	call   800339 <_panic>

00800252 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	57                   	push   %edi
  800256:	56                   	push   %esi
  800257:	53                   	push   %ebx
  800258:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80025b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800260:	8b 55 08             	mov    0x8(%ebp),%edx
  800263:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800266:	b8 09 00 00 00       	mov    $0x9,%eax
  80026b:	89 df                	mov    %ebx,%edi
  80026d:	89 de                	mov    %ebx,%esi
  80026f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800271:	85 c0                	test   %eax,%eax
  800273:	7f 08                	jg     80027d <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800275:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800278:	5b                   	pop    %ebx
  800279:	5e                   	pop    %esi
  80027a:	5f                   	pop    %edi
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80027d:	83 ec 0c             	sub    $0xc,%esp
  800280:	50                   	push   %eax
  800281:	6a 09                	push   $0x9
  800283:	68 4a 11 80 00       	push   $0x80114a
  800288:	6a 23                	push   $0x23
  80028a:	68 67 11 80 00       	push   $0x801167
  80028f:	e8 a5 00 00 00       	call   800339 <_panic>

00800294 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
	asm volatile("int %1\n"
  80029a:	8b 55 08             	mov    0x8(%ebp),%edx
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a5:	be 00 00 00 00       	mov    $0x0,%esi
  8002aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ad:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b0:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b2:	5b                   	pop    %ebx
  8002b3:	5e                   	pop    %esi
  8002b4:	5f                   	pop    %edi
  8002b5:	5d                   	pop    %ebp
  8002b6:	c3                   	ret    

008002b7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	57                   	push   %edi
  8002bb:	56                   	push   %esi
  8002bc:	53                   	push   %ebx
  8002bd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002cd:	89 cb                	mov    %ecx,%ebx
  8002cf:	89 cf                	mov    %ecx,%edi
  8002d1:	89 ce                	mov    %ecx,%esi
  8002d3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d5:	85 c0                	test   %eax,%eax
  8002d7:	7f 08                	jg     8002e1 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e1:	83 ec 0c             	sub    $0xc,%esp
  8002e4:	50                   	push   %eax
  8002e5:	6a 0c                	push   $0xc
  8002e7:	68 4a 11 80 00       	push   $0x80114a
  8002ec:	6a 23                	push   $0x23
  8002ee:	68 67 11 80 00       	push   $0x801167
  8002f3:	e8 41 00 00 00       	call   800339 <_panic>

008002f8 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	57                   	push   %edi
  8002fc:	56                   	push   %esi
  8002fd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800309:	b8 0d 00 00 00       	mov    $0xd,%eax
  80030e:	89 df                	mov    %ebx,%edi
  800310:	89 de                	mov    %ebx,%esi
  800312:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800314:	5b                   	pop    %ebx
  800315:	5e                   	pop    %esi
  800316:	5f                   	pop    %edi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	8b 55 08             	mov    0x8(%ebp),%edx
  800327:	b8 0e 00 00 00       	mov    $0xe,%eax
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800334:	5b                   	pop    %ebx
  800335:	5e                   	pop    %esi
  800336:	5f                   	pop    %edi
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800341:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800347:	e8 bf fd ff ff       	call   80010b <sys_getenvid>
  80034c:	83 ec 0c             	sub    $0xc,%esp
  80034f:	ff 75 0c             	pushl  0xc(%ebp)
  800352:	ff 75 08             	pushl  0x8(%ebp)
  800355:	56                   	push   %esi
  800356:	50                   	push   %eax
  800357:	68 78 11 80 00       	push   $0x801178
  80035c:	e8 b3 00 00 00       	call   800414 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800361:	83 c4 18             	add    $0x18,%esp
  800364:	53                   	push   %ebx
  800365:	ff 75 10             	pushl  0x10(%ebp)
  800368:	e8 56 00 00 00       	call   8003c3 <vcprintf>
	cprintf("\n");
  80036d:	c7 04 24 9b 11 80 00 	movl   $0x80119b,(%esp)
  800374:	e8 9b 00 00 00       	call   800414 <cprintf>
  800379:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037c:	cc                   	int3   
  80037d:	eb fd                	jmp    80037c <_panic+0x43>

0080037f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037f:	55                   	push   %ebp
  800380:	89 e5                	mov    %esp,%ebp
  800382:	53                   	push   %ebx
  800383:	83 ec 04             	sub    $0x4,%esp
  800386:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800389:	8b 13                	mov    (%ebx),%edx
  80038b:	8d 42 01             	lea    0x1(%edx),%eax
  80038e:	89 03                	mov    %eax,(%ebx)
  800390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800393:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800397:	3d ff 00 00 00       	cmp    $0xff,%eax
  80039c:	74 09                	je     8003a7 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80039e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a5:	c9                   	leave  
  8003a6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	68 ff 00 00 00       	push   $0xff
  8003af:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b2:	50                   	push   %eax
  8003b3:	e8 d5 fc ff ff       	call   80008d <sys_cputs>
		b->idx = 0;
  8003b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	eb db                	jmp    80039e <putch+0x1f>

008003c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d3:	00 00 00 
	b.cnt = 0;
  8003d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e0:	ff 75 0c             	pushl  0xc(%ebp)
  8003e3:	ff 75 08             	pushl  0x8(%ebp)
  8003e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ec:	50                   	push   %eax
  8003ed:	68 7f 03 80 00       	push   $0x80037f
  8003f2:	e8 fb 00 00 00       	call   8004f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f7:	83 c4 08             	add    $0x8,%esp
  8003fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800400:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800406:	50                   	push   %eax
  800407:	e8 81 fc ff ff       	call   80008d <sys_cputs>

	return b.cnt;
}
  80040c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800412:	c9                   	leave  
  800413:	c3                   	ret    

00800414 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80041d:	50                   	push   %eax
  80041e:	ff 75 08             	pushl  0x8(%ebp)
  800421:	e8 9d ff ff ff       	call   8003c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800426:	c9                   	leave  
  800427:	c3                   	ret    

00800428 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800428:	55                   	push   %ebp
  800429:	89 e5                	mov    %esp,%ebp
  80042b:	57                   	push   %edi
  80042c:	56                   	push   %esi
  80042d:	53                   	push   %ebx
  80042e:	83 ec 1c             	sub    $0x1c,%esp
  800431:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800434:	89 d3                	mov    %edx,%ebx
  800436:	8b 75 08             	mov    0x8(%ebp),%esi
  800439:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80043c:	8b 45 10             	mov    0x10(%ebp),%eax
  80043f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800442:	89 c2                	mov    %eax,%edx
  800444:	b9 00 00 00 00       	mov    $0x0,%ecx
  800449:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80044f:	39 c6                	cmp    %eax,%esi
  800451:	89 f8                	mov    %edi,%eax
  800453:	19 c8                	sbb    %ecx,%eax
  800455:	73 32                	jae    800489 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	53                   	push   %ebx
  80045b:	83 ec 04             	sub    $0x4,%esp
  80045e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800461:	ff 75 e0             	pushl  -0x20(%ebp)
  800464:	57                   	push   %edi
  800465:	56                   	push   %esi
  800466:	e8 85 0b 00 00       	call   800ff0 <__umoddi3>
  80046b:	83 c4 14             	add    $0x14,%esp
  80046e:	0f be 80 9d 11 80 00 	movsbl 0x80119d(%eax),%eax
  800475:	50                   	push   %eax
  800476:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800479:	ff d0                	call   *%eax
	return remain - 1;
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	83 e8 01             	sub    $0x1,%eax
}
  800481:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800484:	5b                   	pop    %ebx
  800485:	5e                   	pop    %esi
  800486:	5f                   	pop    %edi
  800487:	5d                   	pop    %ebp
  800488:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  800489:	83 ec 0c             	sub    $0xc,%esp
  80048c:	ff 75 18             	pushl  0x18(%ebp)
  80048f:	ff 75 14             	pushl  0x14(%ebp)
  800492:	ff 75 d8             	pushl  -0x28(%ebp)
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	51                   	push   %ecx
  800499:	52                   	push   %edx
  80049a:	57                   	push   %edi
  80049b:	56                   	push   %esi
  80049c:	e8 3f 0a 00 00       	call   800ee0 <__udivdi3>
  8004a1:	83 c4 18             	add    $0x18,%esp
  8004a4:	52                   	push   %edx
  8004a5:	50                   	push   %eax
  8004a6:	89 da                	mov    %ebx,%edx
  8004a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ab:	e8 78 ff ff ff       	call   800428 <printnum_helper>
  8004b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b3:	83 c4 20             	add    $0x20,%esp
  8004b6:	eb 9f                	jmp    800457 <printnum_helper+0x2f>

008004b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004be:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c7:	73 0a                	jae    8004d3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004c9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d1:	88 02                	mov    %al,(%edx)
}
  8004d3:	5d                   	pop    %ebp
  8004d4:	c3                   	ret    

008004d5 <printfmt>:
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004db:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004de:	50                   	push   %eax
  8004df:	ff 75 10             	pushl  0x10(%ebp)
  8004e2:	ff 75 0c             	pushl  0xc(%ebp)
  8004e5:	ff 75 08             	pushl  0x8(%ebp)
  8004e8:	e8 05 00 00 00       	call   8004f2 <vprintfmt>
}
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	c9                   	leave  
  8004f1:	c3                   	ret    

008004f2 <vprintfmt>:
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	57                   	push   %edi
  8004f6:	56                   	push   %esi
  8004f7:	53                   	push   %ebx
  8004f8:	83 ec 3c             	sub    $0x3c,%esp
  8004fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800501:	8b 7d 10             	mov    0x10(%ebp),%edi
  800504:	e9 3f 05 00 00       	jmp    800a48 <vprintfmt+0x556>
		padc = ' ';
  800509:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  80050d:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800514:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  80051b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800522:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  800529:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800530:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8d 47 01             	lea    0x1(%edi),%eax
  800538:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80053b:	0f b6 17             	movzbl (%edi),%edx
  80053e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800541:	3c 55                	cmp    $0x55,%al
  800543:	0f 87 98 05 00 00    	ja     800ae1 <vprintfmt+0x5ef>
  800549:	0f b6 c0             	movzbl %al,%eax
  80054c:	ff 24 85 e0 12 80 00 	jmp    *0x8012e0(,%eax,4)
  800553:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  800556:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80055a:	eb d9                	jmp    800535 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  80055f:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  800566:	eb cd                	jmp    800535 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800568:	0f b6 d2             	movzbl %dl,%edx
  80056b:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80056e:	b8 00 00 00 00       	mov    $0x0,%eax
  800573:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  800576:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800579:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80057d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800580:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800583:	83 fb 09             	cmp    $0x9,%ebx
  800586:	77 5c                	ja     8005e4 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  800588:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80058b:	eb e9                	jmp    800576 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  800590:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  800594:	eb 9f                	jmp    800535 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8b 00                	mov    (%eax),%eax
  80059b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059e:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a1:	8d 40 04             	lea    0x4(%eax),%eax
  8005a4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8005aa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005ae:	79 85                	jns    800535 <vprintfmt+0x43>
				width = precision, precision = -1;
  8005b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005bd:	e9 73 ff ff ff       	jmp    800535 <vprintfmt+0x43>
  8005c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	0f 48 c1             	cmovs  %ecx,%eax
  8005ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005cd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005d0:	e9 60 ff ff ff       	jmp    800535 <vprintfmt+0x43>
  8005d5:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8005d8:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8005df:	e9 51 ff ff ff       	jmp    800535 <vprintfmt+0x43>
  8005e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005ea:	eb be                	jmp    8005aa <vprintfmt+0xb8>
			lflag++;
  8005ec:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  8005f3:	e9 3d ff ff ff       	jmp    800535 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 78 04             	lea    0x4(%eax),%edi
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	56                   	push   %esi
  800602:	ff 30                	pushl  (%eax)
  800604:	ff d3                	call   *%ebx
			break;
  800606:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800609:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80060c:	e9 34 04 00 00       	jmp    800a45 <vprintfmt+0x553>
			err = va_arg(ap, int);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 78 04             	lea    0x4(%eax),%edi
  800617:	8b 00                	mov    (%eax),%eax
  800619:	99                   	cltd   
  80061a:	31 d0                	xor    %edx,%eax
  80061c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061e:	83 f8 08             	cmp    $0x8,%eax
  800621:	7f 23                	jg     800646 <vprintfmt+0x154>
  800623:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  80062a:	85 d2                	test   %edx,%edx
  80062c:	74 18                	je     800646 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  80062e:	52                   	push   %edx
  80062f:	68 be 11 80 00       	push   $0x8011be
  800634:	56                   	push   %esi
  800635:	53                   	push   %ebx
  800636:	e8 9a fe ff ff       	call   8004d5 <printfmt>
  80063b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80063e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800641:	e9 ff 03 00 00       	jmp    800a45 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  800646:	50                   	push   %eax
  800647:	68 b5 11 80 00       	push   $0x8011b5
  80064c:	56                   	push   %esi
  80064d:	53                   	push   %ebx
  80064e:	e8 82 fe ff ff       	call   8004d5 <printfmt>
  800653:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800656:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800659:	e9 e7 03 00 00       	jmp    800a45 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	83 c0 04             	add    $0x4,%eax
  800664:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80066c:	85 c9                	test   %ecx,%ecx
  80066e:	b8 ae 11 80 00       	mov    $0x8011ae,%eax
  800673:	0f 45 c1             	cmovne %ecx,%eax
  800676:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800679:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80067d:	7e 06                	jle    800685 <vprintfmt+0x193>
  80067f:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800683:	75 0d                	jne    800692 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800685:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800688:	89 c7                	mov    %eax,%edi
  80068a:	03 45 d8             	add    -0x28(%ebp),%eax
  80068d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800690:	eb 53                	jmp    8006e5 <vprintfmt+0x1f3>
  800692:	83 ec 08             	sub    $0x8,%esp
  800695:	ff 75 e0             	pushl  -0x20(%ebp)
  800698:	50                   	push   %eax
  800699:	e8 eb 04 00 00       	call   800b89 <strnlen>
  80069e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006a1:	29 c1                	sub    %eax,%ecx
  8006a3:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8006a6:	83 c4 10             	add    $0x10,%esp
  8006a9:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006ab:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8006af:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b2:	eb 0f                	jmp    8006c3 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	56                   	push   %esi
  8006b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8006bb:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 ef 01             	sub    $0x1,%edi
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	85 ff                	test   %edi,%edi
  8006c5:	7f ed                	jg     8006b4 <vprintfmt+0x1c2>
  8006c7:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8006ca:	85 c9                	test   %ecx,%ecx
  8006cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d1:	0f 49 c1             	cmovns %ecx,%eax
  8006d4:	29 c1                	sub    %eax,%ecx
  8006d6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006d9:	eb aa                	jmp    800685 <vprintfmt+0x193>
					putch(ch, putdat);
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	56                   	push   %esi
  8006df:	52                   	push   %edx
  8006e0:	ff d3                	call   *%ebx
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006e8:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ea:	83 c7 01             	add    $0x1,%edi
  8006ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f1:	0f be d0             	movsbl %al,%edx
  8006f4:	85 d2                	test   %edx,%edx
  8006f6:	74 2e                	je     800726 <vprintfmt+0x234>
  8006f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006fc:	78 06                	js     800704 <vprintfmt+0x212>
  8006fe:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800702:	78 1e                	js     800722 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800704:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800708:	74 d1                	je     8006db <vprintfmt+0x1e9>
  80070a:	0f be c0             	movsbl %al,%eax
  80070d:	83 e8 20             	sub    $0x20,%eax
  800710:	83 f8 5e             	cmp    $0x5e,%eax
  800713:	76 c6                	jbe    8006db <vprintfmt+0x1e9>
					putch('?', putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	56                   	push   %esi
  800719:	6a 3f                	push   $0x3f
  80071b:	ff d3                	call   *%ebx
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	eb c3                	jmp    8006e5 <vprintfmt+0x1f3>
  800722:	89 cf                	mov    %ecx,%edi
  800724:	eb 02                	jmp    800728 <vprintfmt+0x236>
  800726:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  800728:	85 ff                	test   %edi,%edi
  80072a:	7e 10                	jle    80073c <vprintfmt+0x24a>
				putch(' ', putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	56                   	push   %esi
  800730:	6a 20                	push   $0x20
  800732:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800734:	83 ef 01             	sub    $0x1,%edi
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	eb ec                	jmp    800728 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  80073c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
  800742:	e9 fe 02 00 00       	jmp    800a45 <vprintfmt+0x553>
	if (lflag >= 2)
  800747:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80074b:	7f 21                	jg     80076e <vprintfmt+0x27c>
	else if (lflag)
  80074d:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800751:	74 79                	je     8007cc <vprintfmt+0x2da>
		return va_arg(*ap, long);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8b 00                	mov    (%eax),%eax
  800758:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80075b:	89 c1                	mov    %eax,%ecx
  80075d:	c1 f9 1f             	sar    $0x1f,%ecx
  800760:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 40 04             	lea    0x4(%eax),%eax
  800769:	89 45 14             	mov    %eax,0x14(%ebp)
  80076c:	eb 17                	jmp    800785 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  80076e:	8b 45 14             	mov    0x14(%ebp),%eax
  800771:	8b 50 04             	mov    0x4(%eax),%edx
  800774:	8b 00                	mov    (%eax),%eax
  800776:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800779:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	8d 40 08             	lea    0x8(%eax),%eax
  800782:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  800785:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800788:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80078b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80078e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  800791:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800795:	78 50                	js     8007e7 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  800797:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80079a:	c1 fa 1f             	sar    $0x1f,%edx
  80079d:	89 d0                	mov    %edx,%eax
  80079f:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8007a2:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8007a5:	85 d2                	test   %edx,%edx
  8007a7:	0f 89 14 02 00 00    	jns    8009c1 <vprintfmt+0x4cf>
  8007ad:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007b1:	0f 84 0a 02 00 00    	je     8009c1 <vprintfmt+0x4cf>
				putch('+', putdat);
  8007b7:	83 ec 08             	sub    $0x8,%esp
  8007ba:	56                   	push   %esi
  8007bb:	6a 2b                	push   $0x2b
  8007bd:	ff d3                	call   *%ebx
  8007bf:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c7:	e9 5c 01 00 00       	jmp    800928 <vprintfmt+0x436>
		return va_arg(*ap, int);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8b 00                	mov    (%eax),%eax
  8007d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007d4:	89 c1                	mov    %eax,%ecx
  8007d6:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	8d 40 04             	lea    0x4(%eax),%eax
  8007e2:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e5:	eb 9e                	jmp    800785 <vprintfmt+0x293>
				putch('-', putdat);
  8007e7:	83 ec 08             	sub    $0x8,%esp
  8007ea:	56                   	push   %esi
  8007eb:	6a 2d                	push   $0x2d
  8007ed:	ff d3                	call   *%ebx
				num = -(long long) num;
  8007ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007f5:	f7 d8                	neg    %eax
  8007f7:	83 d2 00             	adc    $0x0,%edx
  8007fa:	f7 da                	neg    %edx
  8007fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007ff:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800802:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800805:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080a:	e9 19 01 00 00       	jmp    800928 <vprintfmt+0x436>
	if (lflag >= 2)
  80080f:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800813:	7f 29                	jg     80083e <vprintfmt+0x34c>
	else if (lflag)
  800815:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800819:	74 44                	je     80085f <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  80081b:	8b 45 14             	mov    0x14(%ebp),%eax
  80081e:	8b 00                	mov    (%eax),%eax
  800820:	ba 00 00 00 00       	mov    $0x0,%edx
  800825:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800828:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80082b:	8b 45 14             	mov    0x14(%ebp),%eax
  80082e:	8d 40 04             	lea    0x4(%eax),%eax
  800831:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800834:	b8 0a 00 00 00       	mov    $0xa,%eax
  800839:	e9 ea 00 00 00       	jmp    800928 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 50 04             	mov    0x4(%eax),%edx
  800844:	8b 00                	mov    (%eax),%eax
  800846:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800849:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8d 40 08             	lea    0x8(%eax),%eax
  800852:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800855:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085a:	e9 c9 00 00 00       	jmp    800928 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8b 00                	mov    (%eax),%eax
  800864:	ba 00 00 00 00       	mov    $0x0,%edx
  800869:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80086c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80086f:	8b 45 14             	mov    0x14(%ebp),%eax
  800872:	8d 40 04             	lea    0x4(%eax),%eax
  800875:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800878:	b8 0a 00 00 00       	mov    $0xa,%eax
  80087d:	e9 a6 00 00 00       	jmp    800928 <vprintfmt+0x436>
			putch('0', putdat);
  800882:	83 ec 08             	sub    $0x8,%esp
  800885:	56                   	push   %esi
  800886:	6a 30                	push   $0x30
  800888:	ff d3                	call   *%ebx
	if (lflag >= 2)
  80088a:	83 c4 10             	add    $0x10,%esp
  80088d:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800891:	7f 26                	jg     8008b9 <vprintfmt+0x3c7>
	else if (lflag)
  800893:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800897:	74 3e                	je     8008d7 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  800899:	8b 45 14             	mov    0x14(%ebp),%eax
  80089c:	8b 00                	mov    (%eax),%eax
  80089e:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008a6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ac:	8d 40 04             	lea    0x4(%eax),%eax
  8008af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008b2:	b8 08 00 00 00       	mov    $0x8,%eax
  8008b7:	eb 6f                	jmp    800928 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8008b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bc:	8b 50 04             	mov    0x4(%eax),%edx
  8008bf:	8b 00                	mov    (%eax),%eax
  8008c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ca:	8d 40 08             	lea    0x8(%eax),%eax
  8008cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8008d5:	eb 51                	jmp    800928 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8008d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008da:	8b 00                	mov    (%eax),%eax
  8008dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008e4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ea:	8d 40 04             	lea    0x4(%eax),%eax
  8008ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8008f5:	eb 31                	jmp    800928 <vprintfmt+0x436>
			putch('0', putdat);
  8008f7:	83 ec 08             	sub    $0x8,%esp
  8008fa:	56                   	push   %esi
  8008fb:	6a 30                	push   $0x30
  8008fd:	ff d3                	call   *%ebx
			putch('x', putdat);
  8008ff:	83 c4 08             	add    $0x8,%esp
  800902:	56                   	push   %esi
  800903:	6a 78                	push   $0x78
  800905:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800907:	8b 45 14             	mov    0x14(%ebp),%eax
  80090a:	8b 00                	mov    (%eax),%eax
  80090c:	ba 00 00 00 00       	mov    $0x0,%edx
  800911:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800914:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800917:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80091a:	8b 45 14             	mov    0x14(%ebp),%eax
  80091d:	8d 40 04             	lea    0x4(%eax),%eax
  800920:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800923:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800928:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  80092c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80092f:	89 c1                	mov    %eax,%ecx
  800931:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800934:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800937:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  80093c:	89 c2                	mov    %eax,%edx
  80093e:	39 c1                	cmp    %eax,%ecx
  800940:	0f 87 85 00 00 00    	ja     8009cb <vprintfmt+0x4d9>
		tmp /= base;
  800946:	89 d0                	mov    %edx,%eax
  800948:	ba 00 00 00 00       	mov    $0x0,%edx
  80094d:	f7 f1                	div    %ecx
		len++;
  80094f:	83 c7 01             	add    $0x1,%edi
  800952:	eb e8                	jmp    80093c <vprintfmt+0x44a>
	if (lflag >= 2)
  800954:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800958:	7f 26                	jg     800980 <vprintfmt+0x48e>
	else if (lflag)
  80095a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80095e:	74 3e                	je     80099e <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800960:	8b 45 14             	mov    0x14(%ebp),%eax
  800963:	8b 00                	mov    (%eax),%eax
  800965:	ba 00 00 00 00       	mov    $0x0,%edx
  80096a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80096d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800970:	8b 45 14             	mov    0x14(%ebp),%eax
  800973:	8d 40 04             	lea    0x4(%eax),%eax
  800976:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800979:	b8 10 00 00 00       	mov    $0x10,%eax
  80097e:	eb a8                	jmp    800928 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800980:	8b 45 14             	mov    0x14(%ebp),%eax
  800983:	8b 50 04             	mov    0x4(%eax),%edx
  800986:	8b 00                	mov    (%eax),%eax
  800988:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80098b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80098e:	8b 45 14             	mov    0x14(%ebp),%eax
  800991:	8d 40 08             	lea    0x8(%eax),%eax
  800994:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800997:	b8 10 00 00 00       	mov    $0x10,%eax
  80099c:	eb 8a                	jmp    800928 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80099e:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a1:	8b 00                	mov    (%eax),%eax
  8009a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009ab:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b1:	8d 40 04             	lea    0x4(%eax),%eax
  8009b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009b7:	b8 10 00 00 00       	mov    $0x10,%eax
  8009bc:	e9 67 ff ff ff       	jmp    800928 <vprintfmt+0x436>
			base = 10;
  8009c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009c6:	e9 5d ff ff ff       	jmp    800928 <vprintfmt+0x436>
  8009cb:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8009ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009d1:	29 f8                	sub    %edi,%eax
  8009d3:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8009d5:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8009d9:	74 15                	je     8009f0 <vprintfmt+0x4fe>
		while (width > 0) {
  8009db:	85 ff                	test   %edi,%edi
  8009dd:	7e 48                	jle    800a27 <vprintfmt+0x535>
			putch(padc, putdat);
  8009df:	83 ec 08             	sub    $0x8,%esp
  8009e2:	56                   	push   %esi
  8009e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8009e6:	ff d3                	call   *%ebx
			width--;
  8009e8:	83 ef 01             	sub    $0x1,%edi
  8009eb:	83 c4 10             	add    $0x10,%esp
  8009ee:	eb eb                	jmp    8009db <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  8009f0:	83 ec 0c             	sub    $0xc,%esp
  8009f3:	6a 2d                	push   $0x2d
  8009f5:	ff 75 cc             	pushl  -0x34(%ebp)
  8009f8:	ff 75 c8             	pushl  -0x38(%ebp)
  8009fb:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009fe:	ff 75 d0             	pushl  -0x30(%ebp)
  800a01:	89 f2                	mov    %esi,%edx
  800a03:	89 d8                	mov    %ebx,%eax
  800a05:	e8 1e fa ff ff       	call   800428 <printnum_helper>
		width -= len;
  800a0a:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a0d:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800a10:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800a13:	85 ff                	test   %edi,%edi
  800a15:	7e 2e                	jle    800a45 <vprintfmt+0x553>
			putch(padc, putdat);
  800a17:	83 ec 08             	sub    $0x8,%esp
  800a1a:	56                   	push   %esi
  800a1b:	6a 20                	push   $0x20
  800a1d:	ff d3                	call   *%ebx
			width--;
  800a1f:	83 ef 01             	sub    $0x1,%edi
  800a22:	83 c4 10             	add    $0x10,%esp
  800a25:	eb ec                	jmp    800a13 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a27:	83 ec 0c             	sub    $0xc,%esp
  800a2a:	ff 75 e0             	pushl  -0x20(%ebp)
  800a2d:	ff 75 cc             	pushl  -0x34(%ebp)
  800a30:	ff 75 c8             	pushl  -0x38(%ebp)
  800a33:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a36:	ff 75 d0             	pushl  -0x30(%ebp)
  800a39:	89 f2                	mov    %esi,%edx
  800a3b:	89 d8                	mov    %ebx,%eax
  800a3d:	e8 e6 f9 ff ff       	call   800428 <printnum_helper>
  800a42:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800a45:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a48:	83 c7 01             	add    $0x1,%edi
  800a4b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a4f:	83 f8 25             	cmp    $0x25,%eax
  800a52:	0f 84 b1 fa ff ff    	je     800509 <vprintfmt+0x17>
			if (ch == '\0')
  800a58:	85 c0                	test   %eax,%eax
  800a5a:	0f 84 a1 00 00 00    	je     800b01 <vprintfmt+0x60f>
			putch(ch, putdat);
  800a60:	83 ec 08             	sub    $0x8,%esp
  800a63:	56                   	push   %esi
  800a64:	50                   	push   %eax
  800a65:	ff d3                	call   *%ebx
  800a67:	83 c4 10             	add    $0x10,%esp
  800a6a:	eb dc                	jmp    800a48 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800a6c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6f:	83 c0 04             	add    $0x4,%eax
  800a72:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a75:	8b 45 14             	mov    0x14(%ebp),%eax
  800a78:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800a7a:	85 ff                	test   %edi,%edi
  800a7c:	74 15                	je     800a93 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800a7e:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800a84:	7f 29                	jg     800aaf <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800a86:	0f b6 06             	movzbl (%esi),%eax
  800a89:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800a8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a8e:	89 45 14             	mov    %eax,0x14(%ebp)
  800a91:	eb b2                	jmp    800a45 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800a93:	68 54 12 80 00       	push   $0x801254
  800a98:	68 be 11 80 00       	push   $0x8011be
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	e8 31 fa ff ff       	call   8004d5 <printfmt>
  800aa4:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800aa7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800aaa:	89 45 14             	mov    %eax,0x14(%ebp)
  800aad:	eb 96                	jmp    800a45 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800aaf:	68 8c 12 80 00       	push   $0x80128c
  800ab4:	68 be 11 80 00       	push   $0x8011be
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
  800abb:	e8 15 fa ff ff       	call   8004d5 <printfmt>
				*res = -1;
  800ac0:	c6 07 ff             	movb   $0xff,(%edi)
  800ac3:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800ac6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ac9:	89 45 14             	mov    %eax,0x14(%ebp)
  800acc:	e9 74 ff ff ff       	jmp    800a45 <vprintfmt+0x553>
			putch(ch, putdat);
  800ad1:	83 ec 08             	sub    $0x8,%esp
  800ad4:	56                   	push   %esi
  800ad5:	6a 25                	push   $0x25
  800ad7:	ff d3                	call   *%ebx
			break;
  800ad9:	83 c4 10             	add    $0x10,%esp
  800adc:	e9 64 ff ff ff       	jmp    800a45 <vprintfmt+0x553>
			putch('%', putdat);
  800ae1:	83 ec 08             	sub    $0x8,%esp
  800ae4:	56                   	push   %esi
  800ae5:	6a 25                	push   $0x25
  800ae7:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae9:	83 c4 10             	add    $0x10,%esp
  800aec:	89 f8                	mov    %edi,%eax
  800aee:	eb 03                	jmp    800af3 <vprintfmt+0x601>
  800af0:	83 e8 01             	sub    $0x1,%eax
  800af3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800af7:	75 f7                	jne    800af0 <vprintfmt+0x5fe>
  800af9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800afc:	e9 44 ff ff ff       	jmp    800a45 <vprintfmt+0x553>
}
  800b01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5f                   	pop    %edi
  800b07:	5d                   	pop    %ebp
  800b08:	c3                   	ret    

00800b09 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b09:	55                   	push   %ebp
  800b0a:	89 e5                	mov    %esp,%ebp
  800b0c:	83 ec 18             	sub    $0x18,%esp
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b12:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b15:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b18:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b1c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b26:	85 c0                	test   %eax,%eax
  800b28:	74 26                	je     800b50 <vsnprintf+0x47>
  800b2a:	85 d2                	test   %edx,%edx
  800b2c:	7e 22                	jle    800b50 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b2e:	ff 75 14             	pushl  0x14(%ebp)
  800b31:	ff 75 10             	pushl  0x10(%ebp)
  800b34:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b37:	50                   	push   %eax
  800b38:	68 b8 04 80 00       	push   $0x8004b8
  800b3d:	e8 b0 f9 ff ff       	call   8004f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b42:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b45:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b4b:	83 c4 10             	add    $0x10,%esp
}
  800b4e:	c9                   	leave  
  800b4f:	c3                   	ret    
		return -E_INVAL;
  800b50:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b55:	eb f7                	jmp    800b4e <vsnprintf+0x45>

00800b57 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b5d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b60:	50                   	push   %eax
  800b61:	ff 75 10             	pushl  0x10(%ebp)
  800b64:	ff 75 0c             	pushl  0xc(%ebp)
  800b67:	ff 75 08             	pushl  0x8(%ebp)
  800b6a:	e8 9a ff ff ff       	call   800b09 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b6f:	c9                   	leave  
  800b70:	c3                   	ret    

00800b71 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b80:	74 05                	je     800b87 <strlen+0x16>
		n++;
  800b82:	83 c0 01             	add    $0x1,%eax
  800b85:	eb f5                	jmp    800b7c <strlen+0xb>
	return n;
}
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b92:	ba 00 00 00 00       	mov    $0x0,%edx
  800b97:	39 c2                	cmp    %eax,%edx
  800b99:	74 0d                	je     800ba8 <strnlen+0x1f>
  800b9b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800b9f:	74 05                	je     800ba6 <strnlen+0x1d>
		n++;
  800ba1:	83 c2 01             	add    $0x1,%edx
  800ba4:	eb f1                	jmp    800b97 <strnlen+0xe>
  800ba6:	89 d0                	mov    %edx,%eax
	return n;
}
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	53                   	push   %ebx
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bbd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bc0:	83 c2 01             	add    $0x1,%edx
  800bc3:	84 c9                	test   %cl,%cl
  800bc5:	75 f2                	jne    800bb9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bc7:	5b                   	pop    %ebx
  800bc8:	5d                   	pop    %ebp
  800bc9:	c3                   	ret    

00800bca <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 10             	sub    $0x10,%esp
  800bd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bd4:	53                   	push   %ebx
  800bd5:	e8 97 ff ff ff       	call   800b71 <strlen>
  800bda:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800bdd:	ff 75 0c             	pushl  0xc(%ebp)
  800be0:	01 d8                	add    %ebx,%eax
  800be2:	50                   	push   %eax
  800be3:	e8 c2 ff ff ff       	call   800baa <strcpy>
	return dst;
}
  800be8:	89 d8                	mov    %ebx,%eax
  800bea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bed:	c9                   	leave  
  800bee:	c3                   	ret    

00800bef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfa:	89 c6                	mov    %eax,%esi
  800bfc:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bff:	89 c2                	mov    %eax,%edx
  800c01:	39 f2                	cmp    %esi,%edx
  800c03:	74 11                	je     800c16 <strncpy+0x27>
		*dst++ = *src;
  800c05:	83 c2 01             	add    $0x1,%edx
  800c08:	0f b6 19             	movzbl (%ecx),%ebx
  800c0b:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c0e:	80 fb 01             	cmp    $0x1,%bl
  800c11:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800c14:	eb eb                	jmp    800c01 <strncpy+0x12>
	}
	return ret;
}
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	8b 75 08             	mov    0x8(%ebp),%esi
  800c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c25:	8b 55 10             	mov    0x10(%ebp),%edx
  800c28:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c2a:	85 d2                	test   %edx,%edx
  800c2c:	74 21                	je     800c4f <strlcpy+0x35>
  800c2e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c32:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800c34:	39 c2                	cmp    %eax,%edx
  800c36:	74 14                	je     800c4c <strlcpy+0x32>
  800c38:	0f b6 19             	movzbl (%ecx),%ebx
  800c3b:	84 db                	test   %bl,%bl
  800c3d:	74 0b                	je     800c4a <strlcpy+0x30>
			*dst++ = *src++;
  800c3f:	83 c1 01             	add    $0x1,%ecx
  800c42:	83 c2 01             	add    $0x1,%edx
  800c45:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c48:	eb ea                	jmp    800c34 <strlcpy+0x1a>
  800c4a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c4c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c4f:	29 f0                	sub    %esi,%eax
}
  800c51:	5b                   	pop    %ebx
  800c52:	5e                   	pop    %esi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c5e:	0f b6 01             	movzbl (%ecx),%eax
  800c61:	84 c0                	test   %al,%al
  800c63:	74 0c                	je     800c71 <strcmp+0x1c>
  800c65:	3a 02                	cmp    (%edx),%al
  800c67:	75 08                	jne    800c71 <strcmp+0x1c>
		p++, q++;
  800c69:	83 c1 01             	add    $0x1,%ecx
  800c6c:	83 c2 01             	add    $0x1,%edx
  800c6f:	eb ed                	jmp    800c5e <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c71:	0f b6 c0             	movzbl %al,%eax
  800c74:	0f b6 12             	movzbl (%edx),%edx
  800c77:	29 d0                	sub    %edx,%eax
}
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	53                   	push   %ebx
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c85:	89 c3                	mov    %eax,%ebx
  800c87:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c8a:	eb 06                	jmp    800c92 <strncmp+0x17>
		n--, p++, q++;
  800c8c:	83 c0 01             	add    $0x1,%eax
  800c8f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c92:	39 d8                	cmp    %ebx,%eax
  800c94:	74 16                	je     800cac <strncmp+0x31>
  800c96:	0f b6 08             	movzbl (%eax),%ecx
  800c99:	84 c9                	test   %cl,%cl
  800c9b:	74 04                	je     800ca1 <strncmp+0x26>
  800c9d:	3a 0a                	cmp    (%edx),%cl
  800c9f:	74 eb                	je     800c8c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca1:	0f b6 00             	movzbl (%eax),%eax
  800ca4:	0f b6 12             	movzbl (%edx),%edx
  800ca7:	29 d0                	sub    %edx,%eax
}
  800ca9:	5b                   	pop    %ebx
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    
		return 0;
  800cac:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb1:	eb f6                	jmp    800ca9 <strncmp+0x2e>

00800cb3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cbd:	0f b6 10             	movzbl (%eax),%edx
  800cc0:	84 d2                	test   %dl,%dl
  800cc2:	74 09                	je     800ccd <strchr+0x1a>
		if (*s == c)
  800cc4:	38 ca                	cmp    %cl,%dl
  800cc6:	74 0a                	je     800cd2 <strchr+0x1f>
	for (; *s; s++)
  800cc8:	83 c0 01             	add    $0x1,%eax
  800ccb:	eb f0                	jmp    800cbd <strchr+0xa>
			return (char *) s;
	return 0;
  800ccd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cda:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cde:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ce1:	38 ca                	cmp    %cl,%dl
  800ce3:	74 09                	je     800cee <strfind+0x1a>
  800ce5:	84 d2                	test   %dl,%dl
  800ce7:	74 05                	je     800cee <strfind+0x1a>
	for (; *s; s++)
  800ce9:	83 c0 01             	add    $0x1,%eax
  800cec:	eb f0                	jmp    800cde <strfind+0xa>
			break;
	return (char *) s;
}
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	57                   	push   %edi
  800cf4:	56                   	push   %esi
  800cf5:	53                   	push   %ebx
  800cf6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cf9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cfc:	85 c9                	test   %ecx,%ecx
  800cfe:	74 31                	je     800d31 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d00:	89 f8                	mov    %edi,%eax
  800d02:	09 c8                	or     %ecx,%eax
  800d04:	a8 03                	test   $0x3,%al
  800d06:	75 23                	jne    800d2b <memset+0x3b>
		c &= 0xFF;
  800d08:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d0c:	89 d3                	mov    %edx,%ebx
  800d0e:	c1 e3 08             	shl    $0x8,%ebx
  800d11:	89 d0                	mov    %edx,%eax
  800d13:	c1 e0 18             	shl    $0x18,%eax
  800d16:	89 d6                	mov    %edx,%esi
  800d18:	c1 e6 10             	shl    $0x10,%esi
  800d1b:	09 f0                	or     %esi,%eax
  800d1d:	09 c2                	or     %eax,%edx
  800d1f:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d21:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d24:	89 d0                	mov    %edx,%eax
  800d26:	fc                   	cld    
  800d27:	f3 ab                	rep stos %eax,%es:(%edi)
  800d29:	eb 06                	jmp    800d31 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2e:	fc                   	cld    
  800d2f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d31:	89 f8                	mov    %edi,%eax
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d46:	39 c6                	cmp    %eax,%esi
  800d48:	73 32                	jae    800d7c <memmove+0x44>
  800d4a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d4d:	39 c2                	cmp    %eax,%edx
  800d4f:	76 2b                	jbe    800d7c <memmove+0x44>
		s += n;
		d += n;
  800d51:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d54:	89 fe                	mov    %edi,%esi
  800d56:	09 ce                	or     %ecx,%esi
  800d58:	09 d6                	or     %edx,%esi
  800d5a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d60:	75 0e                	jne    800d70 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d62:	83 ef 04             	sub    $0x4,%edi
  800d65:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d68:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d6b:	fd                   	std    
  800d6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d6e:	eb 09                	jmp    800d79 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d70:	83 ef 01             	sub    $0x1,%edi
  800d73:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d76:	fd                   	std    
  800d77:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d79:	fc                   	cld    
  800d7a:	eb 1a                	jmp    800d96 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d7c:	89 c2                	mov    %eax,%edx
  800d7e:	09 ca                	or     %ecx,%edx
  800d80:	09 f2                	or     %esi,%edx
  800d82:	f6 c2 03             	test   $0x3,%dl
  800d85:	75 0a                	jne    800d91 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d87:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d8a:	89 c7                	mov    %eax,%edi
  800d8c:	fc                   	cld    
  800d8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d8f:	eb 05                	jmp    800d96 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800d91:	89 c7                	mov    %eax,%edi
  800d93:	fc                   	cld    
  800d94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d96:	5e                   	pop    %esi
  800d97:	5f                   	pop    %edi
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
  800d9d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800da0:	ff 75 10             	pushl  0x10(%ebp)
  800da3:	ff 75 0c             	pushl  0xc(%ebp)
  800da6:	ff 75 08             	pushl  0x8(%ebp)
  800da9:	e8 8a ff ff ff       	call   800d38 <memmove>
}
  800dae:	c9                   	leave  
  800daf:	c3                   	ret    

00800db0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	56                   	push   %esi
  800db4:	53                   	push   %ebx
  800db5:	8b 45 08             	mov    0x8(%ebp),%eax
  800db8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dbb:	89 c6                	mov    %eax,%esi
  800dbd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dc0:	39 f0                	cmp    %esi,%eax
  800dc2:	74 1c                	je     800de0 <memcmp+0x30>
		if (*s1 != *s2)
  800dc4:	0f b6 08             	movzbl (%eax),%ecx
  800dc7:	0f b6 1a             	movzbl (%edx),%ebx
  800dca:	38 d9                	cmp    %bl,%cl
  800dcc:	75 08                	jne    800dd6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800dce:	83 c0 01             	add    $0x1,%eax
  800dd1:	83 c2 01             	add    $0x1,%edx
  800dd4:	eb ea                	jmp    800dc0 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800dd6:	0f b6 c1             	movzbl %cl,%eax
  800dd9:	0f b6 db             	movzbl %bl,%ebx
  800ddc:	29 d8                	sub    %ebx,%eax
  800dde:	eb 05                	jmp    800de5 <memcmp+0x35>
	}

	return 0;
  800de0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
  800def:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800df2:	89 c2                	mov    %eax,%edx
  800df4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df7:	39 d0                	cmp    %edx,%eax
  800df9:	73 09                	jae    800e04 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dfb:	38 08                	cmp    %cl,(%eax)
  800dfd:	74 05                	je     800e04 <memfind+0x1b>
	for (; s < ends; s++)
  800dff:	83 c0 01             	add    $0x1,%eax
  800e02:	eb f3                	jmp    800df7 <memfind+0xe>
			break;
	return (void *) s;
}
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	57                   	push   %edi
  800e0a:	56                   	push   %esi
  800e0b:	53                   	push   %ebx
  800e0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e12:	eb 03                	jmp    800e17 <strtol+0x11>
		s++;
  800e14:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e17:	0f b6 01             	movzbl (%ecx),%eax
  800e1a:	3c 20                	cmp    $0x20,%al
  800e1c:	74 f6                	je     800e14 <strtol+0xe>
  800e1e:	3c 09                	cmp    $0x9,%al
  800e20:	74 f2                	je     800e14 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e22:	3c 2b                	cmp    $0x2b,%al
  800e24:	74 2a                	je     800e50 <strtol+0x4a>
	int neg = 0;
  800e26:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e2b:	3c 2d                	cmp    $0x2d,%al
  800e2d:	74 2b                	je     800e5a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e2f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e35:	75 0f                	jne    800e46 <strtol+0x40>
  800e37:	80 39 30             	cmpb   $0x30,(%ecx)
  800e3a:	74 28                	je     800e64 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e3c:	85 db                	test   %ebx,%ebx
  800e3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e43:	0f 44 d8             	cmove  %eax,%ebx
  800e46:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e4e:	eb 50                	jmp    800ea0 <strtol+0x9a>
		s++;
  800e50:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e53:	bf 00 00 00 00       	mov    $0x0,%edi
  800e58:	eb d5                	jmp    800e2f <strtol+0x29>
		s++, neg = 1;
  800e5a:	83 c1 01             	add    $0x1,%ecx
  800e5d:	bf 01 00 00 00       	mov    $0x1,%edi
  800e62:	eb cb                	jmp    800e2f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e64:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e68:	74 0e                	je     800e78 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e6a:	85 db                	test   %ebx,%ebx
  800e6c:	75 d8                	jne    800e46 <strtol+0x40>
		s++, base = 8;
  800e6e:	83 c1 01             	add    $0x1,%ecx
  800e71:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e76:	eb ce                	jmp    800e46 <strtol+0x40>
		s += 2, base = 16;
  800e78:	83 c1 02             	add    $0x2,%ecx
  800e7b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e80:	eb c4                	jmp    800e46 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800e82:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e85:	89 f3                	mov    %esi,%ebx
  800e87:	80 fb 19             	cmp    $0x19,%bl
  800e8a:	77 29                	ja     800eb5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800e8c:	0f be d2             	movsbl %dl,%edx
  800e8f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e92:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e95:	7d 30                	jge    800ec7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800e97:	83 c1 01             	add    $0x1,%ecx
  800e9a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e9e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ea0:	0f b6 11             	movzbl (%ecx),%edx
  800ea3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ea6:	89 f3                	mov    %esi,%ebx
  800ea8:	80 fb 09             	cmp    $0x9,%bl
  800eab:	77 d5                	ja     800e82 <strtol+0x7c>
			dig = *s - '0';
  800ead:	0f be d2             	movsbl %dl,%edx
  800eb0:	83 ea 30             	sub    $0x30,%edx
  800eb3:	eb dd                	jmp    800e92 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800eb5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800eb8:	89 f3                	mov    %esi,%ebx
  800eba:	80 fb 19             	cmp    $0x19,%bl
  800ebd:	77 08                	ja     800ec7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ebf:	0f be d2             	movsbl %dl,%edx
  800ec2:	83 ea 37             	sub    $0x37,%edx
  800ec5:	eb cb                	jmp    800e92 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ec7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ecb:	74 05                	je     800ed2 <strtol+0xcc>
		*endptr = (char *) s;
  800ecd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ed2:	89 c2                	mov    %eax,%edx
  800ed4:	f7 da                	neg    %edx
  800ed6:	85 ff                	test   %edi,%edi
  800ed8:	0f 45 c2             	cmovne %edx,%eax
}
  800edb:	5b                   	pop    %ebx
  800edc:	5e                   	pop    %esi
  800edd:	5f                   	pop    %edi
  800ede:	5d                   	pop    %ebp
  800edf:	c3                   	ret    

00800ee0 <__udivdi3>:
  800ee0:	55                   	push   %ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 1c             	sub    $0x1c,%esp
  800ee7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800eeb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800eef:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ef3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800ef7:	85 d2                	test   %edx,%edx
  800ef9:	75 4d                	jne    800f48 <__udivdi3+0x68>
  800efb:	39 f3                	cmp    %esi,%ebx
  800efd:	76 19                	jbe    800f18 <__udivdi3+0x38>
  800eff:	31 ff                	xor    %edi,%edi
  800f01:	89 e8                	mov    %ebp,%eax
  800f03:	89 f2                	mov    %esi,%edx
  800f05:	f7 f3                	div    %ebx
  800f07:	89 fa                	mov    %edi,%edx
  800f09:	83 c4 1c             	add    $0x1c,%esp
  800f0c:	5b                   	pop    %ebx
  800f0d:	5e                   	pop    %esi
  800f0e:	5f                   	pop    %edi
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    
  800f11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f18:	89 d9                	mov    %ebx,%ecx
  800f1a:	85 db                	test   %ebx,%ebx
  800f1c:	75 0b                	jne    800f29 <__udivdi3+0x49>
  800f1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f23:	31 d2                	xor    %edx,%edx
  800f25:	f7 f3                	div    %ebx
  800f27:	89 c1                	mov    %eax,%ecx
  800f29:	31 d2                	xor    %edx,%edx
  800f2b:	89 f0                	mov    %esi,%eax
  800f2d:	f7 f1                	div    %ecx
  800f2f:	89 c6                	mov    %eax,%esi
  800f31:	89 e8                	mov    %ebp,%eax
  800f33:	89 f7                	mov    %esi,%edi
  800f35:	f7 f1                	div    %ecx
  800f37:	89 fa                	mov    %edi,%edx
  800f39:	83 c4 1c             	add    $0x1c,%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    
  800f41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f48:	39 f2                	cmp    %esi,%edx
  800f4a:	77 1c                	ja     800f68 <__udivdi3+0x88>
  800f4c:	0f bd fa             	bsr    %edx,%edi
  800f4f:	83 f7 1f             	xor    $0x1f,%edi
  800f52:	75 2c                	jne    800f80 <__udivdi3+0xa0>
  800f54:	39 f2                	cmp    %esi,%edx
  800f56:	72 06                	jb     800f5e <__udivdi3+0x7e>
  800f58:	31 c0                	xor    %eax,%eax
  800f5a:	39 eb                	cmp    %ebp,%ebx
  800f5c:	77 a9                	ja     800f07 <__udivdi3+0x27>
  800f5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f63:	eb a2                	jmp    800f07 <__udivdi3+0x27>
  800f65:	8d 76 00             	lea    0x0(%esi),%esi
  800f68:	31 ff                	xor    %edi,%edi
  800f6a:	31 c0                	xor    %eax,%eax
  800f6c:	89 fa                	mov    %edi,%edx
  800f6e:	83 c4 1c             	add    $0x1c,%esp
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    
  800f76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	89 f9                	mov    %edi,%ecx
  800f82:	b8 20 00 00 00       	mov    $0x20,%eax
  800f87:	29 f8                	sub    %edi,%eax
  800f89:	d3 e2                	shl    %cl,%edx
  800f8b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f8f:	89 c1                	mov    %eax,%ecx
  800f91:	89 da                	mov    %ebx,%edx
  800f93:	d3 ea                	shr    %cl,%edx
  800f95:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f99:	09 d1                	or     %edx,%ecx
  800f9b:	89 f2                	mov    %esi,%edx
  800f9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fa1:	89 f9                	mov    %edi,%ecx
  800fa3:	d3 e3                	shl    %cl,%ebx
  800fa5:	89 c1                	mov    %eax,%ecx
  800fa7:	d3 ea                	shr    %cl,%edx
  800fa9:	89 f9                	mov    %edi,%ecx
  800fab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800faf:	89 eb                	mov    %ebp,%ebx
  800fb1:	d3 e6                	shl    %cl,%esi
  800fb3:	89 c1                	mov    %eax,%ecx
  800fb5:	d3 eb                	shr    %cl,%ebx
  800fb7:	09 de                	or     %ebx,%esi
  800fb9:	89 f0                	mov    %esi,%eax
  800fbb:	f7 74 24 08          	divl   0x8(%esp)
  800fbf:	89 d6                	mov    %edx,%esi
  800fc1:	89 c3                	mov    %eax,%ebx
  800fc3:	f7 64 24 0c          	mull   0xc(%esp)
  800fc7:	39 d6                	cmp    %edx,%esi
  800fc9:	72 15                	jb     800fe0 <__udivdi3+0x100>
  800fcb:	89 f9                	mov    %edi,%ecx
  800fcd:	d3 e5                	shl    %cl,%ebp
  800fcf:	39 c5                	cmp    %eax,%ebp
  800fd1:	73 04                	jae    800fd7 <__udivdi3+0xf7>
  800fd3:	39 d6                	cmp    %edx,%esi
  800fd5:	74 09                	je     800fe0 <__udivdi3+0x100>
  800fd7:	89 d8                	mov    %ebx,%eax
  800fd9:	31 ff                	xor    %edi,%edi
  800fdb:	e9 27 ff ff ff       	jmp    800f07 <__udivdi3+0x27>
  800fe0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800fe3:	31 ff                	xor    %edi,%edi
  800fe5:	e9 1d ff ff ff       	jmp    800f07 <__udivdi3+0x27>
  800fea:	66 90                	xchg   %ax,%ax
  800fec:	66 90                	xchg   %ax,%ax
  800fee:	66 90                	xchg   %ax,%ax

00800ff0 <__umoddi3>:
  800ff0:	55                   	push   %ebp
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 1c             	sub    $0x1c,%esp
  800ff7:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ffb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800fff:	8b 74 24 30          	mov    0x30(%esp),%esi
  801003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801007:	89 da                	mov    %ebx,%edx
  801009:	85 c0                	test   %eax,%eax
  80100b:	75 43                	jne    801050 <__umoddi3+0x60>
  80100d:	39 df                	cmp    %ebx,%edi
  80100f:	76 17                	jbe    801028 <__umoddi3+0x38>
  801011:	89 f0                	mov    %esi,%eax
  801013:	f7 f7                	div    %edi
  801015:	89 d0                	mov    %edx,%eax
  801017:	31 d2                	xor    %edx,%edx
  801019:	83 c4 1c             	add    $0x1c,%esp
  80101c:	5b                   	pop    %ebx
  80101d:	5e                   	pop    %esi
  80101e:	5f                   	pop    %edi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    
  801021:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801028:	89 fd                	mov    %edi,%ebp
  80102a:	85 ff                	test   %edi,%edi
  80102c:	75 0b                	jne    801039 <__umoddi3+0x49>
  80102e:	b8 01 00 00 00       	mov    $0x1,%eax
  801033:	31 d2                	xor    %edx,%edx
  801035:	f7 f7                	div    %edi
  801037:	89 c5                	mov    %eax,%ebp
  801039:	89 d8                	mov    %ebx,%eax
  80103b:	31 d2                	xor    %edx,%edx
  80103d:	f7 f5                	div    %ebp
  80103f:	89 f0                	mov    %esi,%eax
  801041:	f7 f5                	div    %ebp
  801043:	89 d0                	mov    %edx,%eax
  801045:	eb d0                	jmp    801017 <__umoddi3+0x27>
  801047:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80104e:	66 90                	xchg   %ax,%ax
  801050:	89 f1                	mov    %esi,%ecx
  801052:	39 d8                	cmp    %ebx,%eax
  801054:	76 0a                	jbe    801060 <__umoddi3+0x70>
  801056:	89 f0                	mov    %esi,%eax
  801058:	83 c4 1c             	add    $0x1c,%esp
  80105b:	5b                   	pop    %ebx
  80105c:	5e                   	pop    %esi
  80105d:	5f                   	pop    %edi
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    
  801060:	0f bd e8             	bsr    %eax,%ebp
  801063:	83 f5 1f             	xor    $0x1f,%ebp
  801066:	75 20                	jne    801088 <__umoddi3+0x98>
  801068:	39 d8                	cmp    %ebx,%eax
  80106a:	0f 82 b0 00 00 00    	jb     801120 <__umoddi3+0x130>
  801070:	39 f7                	cmp    %esi,%edi
  801072:	0f 86 a8 00 00 00    	jbe    801120 <__umoddi3+0x130>
  801078:	89 c8                	mov    %ecx,%eax
  80107a:	83 c4 1c             	add    $0x1c,%esp
  80107d:	5b                   	pop    %ebx
  80107e:	5e                   	pop    %esi
  80107f:	5f                   	pop    %edi
  801080:	5d                   	pop    %ebp
  801081:	c3                   	ret    
  801082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801088:	89 e9                	mov    %ebp,%ecx
  80108a:	ba 20 00 00 00       	mov    $0x20,%edx
  80108f:	29 ea                	sub    %ebp,%edx
  801091:	d3 e0                	shl    %cl,%eax
  801093:	89 44 24 08          	mov    %eax,0x8(%esp)
  801097:	89 d1                	mov    %edx,%ecx
  801099:	89 f8                	mov    %edi,%eax
  80109b:	d3 e8                	shr    %cl,%eax
  80109d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010a5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010a9:	09 c1                	or     %eax,%ecx
  8010ab:	89 d8                	mov    %ebx,%eax
  8010ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010b1:	89 e9                	mov    %ebp,%ecx
  8010b3:	d3 e7                	shl    %cl,%edi
  8010b5:	89 d1                	mov    %edx,%ecx
  8010b7:	d3 e8                	shr    %cl,%eax
  8010b9:	89 e9                	mov    %ebp,%ecx
  8010bb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010bf:	d3 e3                	shl    %cl,%ebx
  8010c1:	89 c7                	mov    %eax,%edi
  8010c3:	89 d1                	mov    %edx,%ecx
  8010c5:	89 f0                	mov    %esi,%eax
  8010c7:	d3 e8                	shr    %cl,%eax
  8010c9:	89 e9                	mov    %ebp,%ecx
  8010cb:	89 fa                	mov    %edi,%edx
  8010cd:	d3 e6                	shl    %cl,%esi
  8010cf:	09 d8                	or     %ebx,%eax
  8010d1:	f7 74 24 08          	divl   0x8(%esp)
  8010d5:	89 d1                	mov    %edx,%ecx
  8010d7:	89 f3                	mov    %esi,%ebx
  8010d9:	f7 64 24 0c          	mull   0xc(%esp)
  8010dd:	89 c6                	mov    %eax,%esi
  8010df:	89 d7                	mov    %edx,%edi
  8010e1:	39 d1                	cmp    %edx,%ecx
  8010e3:	72 06                	jb     8010eb <__umoddi3+0xfb>
  8010e5:	75 10                	jne    8010f7 <__umoddi3+0x107>
  8010e7:	39 c3                	cmp    %eax,%ebx
  8010e9:	73 0c                	jae    8010f7 <__umoddi3+0x107>
  8010eb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8010ef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8010f3:	89 d7                	mov    %edx,%edi
  8010f5:	89 c6                	mov    %eax,%esi
  8010f7:	89 ca                	mov    %ecx,%edx
  8010f9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8010fe:	29 f3                	sub    %esi,%ebx
  801100:	19 fa                	sbb    %edi,%edx
  801102:	89 d0                	mov    %edx,%eax
  801104:	d3 e0                	shl    %cl,%eax
  801106:	89 e9                	mov    %ebp,%ecx
  801108:	d3 eb                	shr    %cl,%ebx
  80110a:	d3 ea                	shr    %cl,%edx
  80110c:	09 d8                	or     %ebx,%eax
  80110e:	83 c4 1c             	add    $0x1c,%esp
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5f                   	pop    %edi
  801114:	5d                   	pop    %ebp
  801115:	c3                   	ret    
  801116:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80111d:	8d 76 00             	lea    0x0(%esi),%esi
  801120:	89 da                	mov    %ebx,%edx
  801122:	29 fe                	sub    %edi,%esi
  801124:	19 c2                	sbb    %eax,%edx
  801126:	89 f1                	mov    %esi,%ecx
  801128:	89 c8                	mov    %ecx,%eax
  80112a:	e9 4b ff ff ff       	jmp    80107a <__umoddi3+0x8a>
