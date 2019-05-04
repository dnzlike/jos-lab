
obj/user/faultevilhandler:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 32 01 00 00       	call   800179 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 2c 02 00 00       	call   800282 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 c6 00 00 00       	call   80013b <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	c1 e0 07             	shl    $0x7,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 42 00 00 00       	call   8000fa <sys_env_destroy>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 d1                	mov    %edx,%ecx
  8000ed:	89 d3                	mov    %edx,%ebx
  8000ef:	89 d7                	mov    %edx,%edi
  8000f1:	89 d6                	mov    %edx,%esi
  8000f3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800103:	b9 00 00 00 00       	mov    $0x0,%ecx
  800108:	8b 55 08             	mov    0x8(%ebp),%edx
  80010b:	b8 03 00 00 00       	mov    $0x3,%eax
  800110:	89 cb                	mov    %ecx,%ebx
  800112:	89 cf                	mov    %ecx,%edi
  800114:	89 ce                	mov    %ecx,%esi
  800116:	cd 30                	int    $0x30
	if(check && ret > 0)
  800118:	85 c0                	test   %eax,%eax
  80011a:	7f 08                	jg     800124 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 6a 11 80 00       	push   $0x80116a
  80012f:	6a 23                	push   $0x23
  800131:	68 87 11 80 00       	push   $0x801187
  800136:	e8 2e 02 00 00       	call   800369 <_panic>

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	8b 55 08             	mov    0x8(%ebp),%edx
  80018a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018d:	b8 04 00 00 00       	mov    $0x4,%eax
  800192:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7f 08                	jg     8001a5 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5f                   	pop    %edi
  8001a3:	5d                   	pop    %ebp
  8001a4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 6a 11 80 00       	push   $0x80116a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 87 11 80 00       	push   $0x801187
  8001b7:	e8 ad 01 00 00       	call   800369 <_panic>

008001bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cb:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001db:	85 c0                	test   %eax,%eax
  8001dd:	7f 08                	jg     8001e7 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5f                   	pop    %edi
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 6a 11 80 00       	push   $0x80116a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 87 11 80 00       	push   $0x801187
  8001f9:	e8 6b 01 00 00       	call   800369 <_panic>

008001fe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020c:	8b 55 08             	mov    0x8(%ebp),%edx
  80020f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800212:	b8 06 00 00 00       	mov    $0x6,%eax
  800217:	89 df                	mov    %ebx,%edi
  800219:	89 de                	mov    %ebx,%esi
  80021b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80021d:	85 c0                	test   %eax,%eax
  80021f:	7f 08                	jg     800229 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 6a 11 80 00       	push   $0x80116a
  800234:	6a 23                	push   $0x23
  800236:	68 87 11 80 00       	push   $0x801187
  80023b:	e8 29 01 00 00       	call   800369 <_panic>

00800240 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	8b 55 08             	mov    0x8(%ebp),%edx
  800251:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800254:	b8 08 00 00 00       	mov    $0x8,%eax
  800259:	89 df                	mov    %ebx,%edi
  80025b:	89 de                	mov    %ebx,%esi
  80025d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80025f:	85 c0                	test   %eax,%eax
  800261:	7f 08                	jg     80026b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 6a 11 80 00       	push   $0x80116a
  800276:	6a 23                	push   $0x23
  800278:	68 87 11 80 00       	push   $0x801187
  80027d:	e8 e7 00 00 00       	call   800369 <_panic>

00800282 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80028b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800290:	8b 55 08             	mov    0x8(%ebp),%edx
  800293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800296:	b8 09 00 00 00       	mov    $0x9,%eax
  80029b:	89 df                	mov    %ebx,%edi
  80029d:	89 de                	mov    %ebx,%esi
  80029f:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	7f 08                	jg     8002ad <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 6a 11 80 00       	push   $0x80116a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 87 11 80 00       	push   $0x801187
  8002bf:	e8 a5 00 00 00       	call   800369 <_panic>

008002c4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002d5:	be 00 00 00 00       	mov    $0x0,%esi
  8002da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002dd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002e0:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fd:	89 cb                	mov    %ecx,%ebx
  8002ff:	89 cf                	mov    %ecx,%edi
  800301:	89 ce                	mov    %ecx,%esi
  800303:	cd 30                	int    $0x30
	if(check && ret > 0)
  800305:	85 c0                	test   %eax,%eax
  800307:	7f 08                	jg     800311 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800309:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800311:	83 ec 0c             	sub    $0xc,%esp
  800314:	50                   	push   %eax
  800315:	6a 0c                	push   $0xc
  800317:	68 6a 11 80 00       	push   $0x80116a
  80031c:	6a 23                	push   $0x23
  80031e:	68 87 11 80 00       	push   $0x801187
  800323:	e8 41 00 00 00       	call   800369 <_panic>

00800328 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80032e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800339:	b8 0d 00 00 00       	mov    $0xd,%eax
  80033e:	89 df                	mov    %ebx,%edi
  800340:	89 de                	mov    %ebx,%esi
  800342:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800344:	5b                   	pop    %ebx
  800345:	5e                   	pop    %esi
  800346:	5f                   	pop    %edi
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	57                   	push   %edi
  80034d:	56                   	push   %esi
  80034e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80034f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800354:	8b 55 08             	mov    0x8(%ebp),%edx
  800357:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035c:	89 cb                	mov    %ecx,%ebx
  80035e:	89 cf                	mov    %ecx,%edi
  800360:	89 ce                	mov    %ecx,%esi
  800362:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800364:	5b                   	pop    %ebx
  800365:	5e                   	pop    %esi
  800366:	5f                   	pop    %edi
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	56                   	push   %esi
  80036d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80036e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800371:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800377:	e8 bf fd ff ff       	call   80013b <sys_getenvid>
  80037c:	83 ec 0c             	sub    $0xc,%esp
  80037f:	ff 75 0c             	pushl  0xc(%ebp)
  800382:	ff 75 08             	pushl  0x8(%ebp)
  800385:	56                   	push   %esi
  800386:	50                   	push   %eax
  800387:	68 98 11 80 00       	push   $0x801198
  80038c:	e8 b3 00 00 00       	call   800444 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800391:	83 c4 18             	add    $0x18,%esp
  800394:	53                   	push   %ebx
  800395:	ff 75 10             	pushl  0x10(%ebp)
  800398:	e8 56 00 00 00       	call   8003f3 <vcprintf>
	cprintf("\n");
  80039d:	c7 04 24 bb 11 80 00 	movl   $0x8011bb,(%esp)
  8003a4:	e8 9b 00 00 00       	call   800444 <cprintf>
  8003a9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003ac:	cc                   	int3   
  8003ad:	eb fd                	jmp    8003ac <_panic+0x43>

008003af <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	53                   	push   %ebx
  8003b3:	83 ec 04             	sub    $0x4,%esp
  8003b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003b9:	8b 13                	mov    (%ebx),%edx
  8003bb:	8d 42 01             	lea    0x1(%edx),%eax
  8003be:	89 03                	mov    %eax,(%ebx)
  8003c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003c7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003cc:	74 09                	je     8003d7 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003ce:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003d5:	c9                   	leave  
  8003d6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003d7:	83 ec 08             	sub    $0x8,%esp
  8003da:	68 ff 00 00 00       	push   $0xff
  8003df:	8d 43 08             	lea    0x8(%ebx),%eax
  8003e2:	50                   	push   %eax
  8003e3:	e8 d5 fc ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  8003e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ee:	83 c4 10             	add    $0x10,%esp
  8003f1:	eb db                	jmp    8003ce <putch+0x1f>

008003f3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003f3:	55                   	push   %ebp
  8003f4:	89 e5                	mov    %esp,%ebp
  8003f6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003fc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800403:	00 00 00 
	b.cnt = 0;
  800406:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80040d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800410:	ff 75 0c             	pushl  0xc(%ebp)
  800413:	ff 75 08             	pushl  0x8(%ebp)
  800416:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80041c:	50                   	push   %eax
  80041d:	68 af 03 80 00       	push   $0x8003af
  800422:	e8 fb 00 00 00       	call   800522 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800427:	83 c4 08             	add    $0x8,%esp
  80042a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800430:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800436:	50                   	push   %eax
  800437:	e8 81 fc ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  80043c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800442:	c9                   	leave  
  800443:	c3                   	ret    

00800444 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
  800447:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80044a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80044d:	50                   	push   %eax
  80044e:	ff 75 08             	pushl  0x8(%ebp)
  800451:	e8 9d ff ff ff       	call   8003f3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800456:	c9                   	leave  
  800457:	c3                   	ret    

00800458 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800458:	55                   	push   %ebp
  800459:	89 e5                	mov    %esp,%ebp
  80045b:	57                   	push   %edi
  80045c:	56                   	push   %esi
  80045d:	53                   	push   %ebx
  80045e:	83 ec 1c             	sub    $0x1c,%esp
  800461:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800464:	89 d3                	mov    %edx,%ebx
  800466:	8b 75 08             	mov    0x8(%ebp),%esi
  800469:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80046c:	8b 45 10             	mov    0x10(%ebp),%eax
  80046f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800472:	89 c2                	mov    %eax,%edx
  800474:	b9 00 00 00 00       	mov    $0x0,%ecx
  800479:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80047f:	39 c6                	cmp    %eax,%esi
  800481:	89 f8                	mov    %edi,%eax
  800483:	19 c8                	sbb    %ecx,%eax
  800485:	73 32                	jae    8004b9 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	53                   	push   %ebx
  80048b:	83 ec 04             	sub    $0x4,%esp
  80048e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800491:	ff 75 e0             	pushl  -0x20(%ebp)
  800494:	57                   	push   %edi
  800495:	56                   	push   %esi
  800496:	e8 85 0b 00 00       	call   801020 <__umoddi3>
  80049b:	83 c4 14             	add    $0x14,%esp
  80049e:	0f be 80 bd 11 80 00 	movsbl 0x8011bd(%eax),%eax
  8004a5:	50                   	push   %eax
  8004a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004a9:	ff d0                	call   *%eax
	return remain - 1;
  8004ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ae:	83 e8 01             	sub    $0x1,%eax
}
  8004b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b4:	5b                   	pop    %ebx
  8004b5:	5e                   	pop    %esi
  8004b6:	5f                   	pop    %edi
  8004b7:	5d                   	pop    %ebp
  8004b8:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  8004b9:	83 ec 0c             	sub    $0xc,%esp
  8004bc:	ff 75 18             	pushl  0x18(%ebp)
  8004bf:	ff 75 14             	pushl  0x14(%ebp)
  8004c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	51                   	push   %ecx
  8004c9:	52                   	push   %edx
  8004ca:	57                   	push   %edi
  8004cb:	56                   	push   %esi
  8004cc:	e8 3f 0a 00 00       	call   800f10 <__udivdi3>
  8004d1:	83 c4 18             	add    $0x18,%esp
  8004d4:	52                   	push   %edx
  8004d5:	50                   	push   %eax
  8004d6:	89 da                	mov    %ebx,%edx
  8004d8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004db:	e8 78 ff ff ff       	call   800458 <printnum_helper>
  8004e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e3:	83 c4 20             	add    $0x20,%esp
  8004e6:	eb 9f                	jmp    800487 <printnum_helper+0x2f>

008004e8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f2:	8b 10                	mov    (%eax),%edx
  8004f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f7:	73 0a                	jae    800503 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fc:	89 08                	mov    %ecx,(%eax)
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	88 02                	mov    %al,(%edx)
}
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <printfmt>:
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80050b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050e:	50                   	push   %eax
  80050f:	ff 75 10             	pushl  0x10(%ebp)
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	ff 75 08             	pushl  0x8(%ebp)
  800518:	e8 05 00 00 00       	call   800522 <vprintfmt>
}
  80051d:	83 c4 10             	add    $0x10,%esp
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <vprintfmt>:
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	53                   	push   %ebx
  800528:	83 ec 3c             	sub    $0x3c,%esp
  80052b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80052e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800531:	8b 7d 10             	mov    0x10(%ebp),%edi
  800534:	e9 3f 05 00 00       	jmp    800a78 <vprintfmt+0x556>
		padc = ' ';
  800539:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  80053d:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800544:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  80054b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800552:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  800559:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800560:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8d 47 01             	lea    0x1(%edi),%eax
  800568:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80056b:	0f b6 17             	movzbl (%edi),%edx
  80056e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800571:	3c 55                	cmp    $0x55,%al
  800573:	0f 87 98 05 00 00    	ja     800b11 <vprintfmt+0x5ef>
  800579:	0f b6 c0             	movzbl %al,%eax
  80057c:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)
  800583:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  800586:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80058a:	eb d9                	jmp    800565 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80058c:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  80058f:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  800596:	eb cd                	jmp    800565 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800598:	0f b6 d2             	movzbl %dl,%edx
  80059b:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80059e:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a3:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  8005a6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005ad:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005b0:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005b3:	83 fb 09             	cmp    $0x9,%ebx
  8005b6:	77 5c                	ja     800614 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  8005b8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005bb:	eb e9                	jmp    8005a6 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  8005c0:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  8005c4:	eb 9f                	jmp    800565 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8b 00                	mov    (%eax),%eax
  8005cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 40 04             	lea    0x4(%eax),%eax
  8005d4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8005da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005de:	79 85                	jns    800565 <vprintfmt+0x43>
				width = precision, precision = -1;
  8005e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005ed:	e9 73 ff ff ff       	jmp    800565 <vprintfmt+0x43>
  8005f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f5:	85 c0                	test   %eax,%eax
  8005f7:	0f 48 c1             	cmovs  %ecx,%eax
  8005fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005fd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800600:	e9 60 ff ff ff       	jmp    800565 <vprintfmt+0x43>
  800605:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  800608:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  80060f:	e9 51 ff ff ff       	jmp    800565 <vprintfmt+0x43>
  800614:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800617:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80061a:	eb be                	jmp    8005da <vprintfmt+0xb8>
			lflag++;
  80061c:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800620:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  800623:	e9 3d ff ff ff       	jmp    800565 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8d 78 04             	lea    0x4(%eax),%edi
  80062e:	83 ec 08             	sub    $0x8,%esp
  800631:	56                   	push   %esi
  800632:	ff 30                	pushl  (%eax)
  800634:	ff d3                	call   *%ebx
			break;
  800636:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800639:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80063c:	e9 34 04 00 00       	jmp    800a75 <vprintfmt+0x553>
			err = va_arg(ap, int);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 78 04             	lea    0x4(%eax),%edi
  800647:	8b 00                	mov    (%eax),%eax
  800649:	99                   	cltd   
  80064a:	31 d0                	xor    %edx,%eax
  80064c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064e:	83 f8 08             	cmp    $0x8,%eax
  800651:	7f 23                	jg     800676 <vprintfmt+0x154>
  800653:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  80065a:	85 d2                	test   %edx,%edx
  80065c:	74 18                	je     800676 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  80065e:	52                   	push   %edx
  80065f:	68 de 11 80 00       	push   $0x8011de
  800664:	56                   	push   %esi
  800665:	53                   	push   %ebx
  800666:	e8 9a fe ff ff       	call   800505 <printfmt>
  80066b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80066e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800671:	e9 ff 03 00 00       	jmp    800a75 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  800676:	50                   	push   %eax
  800677:	68 d5 11 80 00       	push   $0x8011d5
  80067c:	56                   	push   %esi
  80067d:	53                   	push   %ebx
  80067e:	e8 82 fe ff ff       	call   800505 <printfmt>
  800683:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800686:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800689:	e9 e7 03 00 00       	jmp    800a75 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	83 c0 04             	add    $0x4,%eax
  800694:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80069c:	85 c9                	test   %ecx,%ecx
  80069e:	b8 ce 11 80 00       	mov    $0x8011ce,%eax
  8006a3:	0f 45 c1             	cmovne %ecx,%eax
  8006a6:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  8006a9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006ad:	7e 06                	jle    8006b5 <vprintfmt+0x193>
  8006af:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8006b3:	75 0d                	jne    8006c2 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006b8:	89 c7                	mov    %eax,%edi
  8006ba:	03 45 d8             	add    -0x28(%ebp),%eax
  8006bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c0:	eb 53                	jmp    800715 <vprintfmt+0x1f3>
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c8:	50                   	push   %eax
  8006c9:	e8 eb 04 00 00       	call   800bb9 <strnlen>
  8006ce:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006d1:	29 c1                	sub    %eax,%ecx
  8006d3:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006db:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8006df:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e2:	eb 0f                	jmp    8006f3 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	56                   	push   %esi
  8006e8:	ff 75 d8             	pushl  -0x28(%ebp)
  8006eb:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ed:	83 ef 01             	sub    $0x1,%edi
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	85 ff                	test   %edi,%edi
  8006f5:	7f ed                	jg     8006e4 <vprintfmt+0x1c2>
  8006f7:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8006fa:	85 c9                	test   %ecx,%ecx
  8006fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800701:	0f 49 c1             	cmovns %ecx,%eax
  800704:	29 c1                	sub    %eax,%ecx
  800706:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  800709:	eb aa                	jmp    8006b5 <vprintfmt+0x193>
					putch(ch, putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	56                   	push   %esi
  80070f:	52                   	push   %edx
  800710:	ff d3                	call   *%ebx
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800718:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80071a:	83 c7 01             	add    $0x1,%edi
  80071d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800721:	0f be d0             	movsbl %al,%edx
  800724:	85 d2                	test   %edx,%edx
  800726:	74 2e                	je     800756 <vprintfmt+0x234>
  800728:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80072c:	78 06                	js     800734 <vprintfmt+0x212>
  80072e:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800732:	78 1e                	js     800752 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800734:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800738:	74 d1                	je     80070b <vprintfmt+0x1e9>
  80073a:	0f be c0             	movsbl %al,%eax
  80073d:	83 e8 20             	sub    $0x20,%eax
  800740:	83 f8 5e             	cmp    $0x5e,%eax
  800743:	76 c6                	jbe    80070b <vprintfmt+0x1e9>
					putch('?', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	56                   	push   %esi
  800749:	6a 3f                	push   $0x3f
  80074b:	ff d3                	call   *%ebx
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	eb c3                	jmp    800715 <vprintfmt+0x1f3>
  800752:	89 cf                	mov    %ecx,%edi
  800754:	eb 02                	jmp    800758 <vprintfmt+0x236>
  800756:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  800758:	85 ff                	test   %edi,%edi
  80075a:	7e 10                	jle    80076c <vprintfmt+0x24a>
				putch(' ', putdat);
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	56                   	push   %esi
  800760:	6a 20                	push   $0x20
  800762:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800764:	83 ef 01             	sub    $0x1,%edi
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	eb ec                	jmp    800758 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  80076c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  80076f:	89 45 14             	mov    %eax,0x14(%ebp)
  800772:	e9 fe 02 00 00       	jmp    800a75 <vprintfmt+0x553>
	if (lflag >= 2)
  800777:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80077b:	7f 21                	jg     80079e <vprintfmt+0x27c>
	else if (lflag)
  80077d:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800781:	74 79                	je     8007fc <vprintfmt+0x2da>
		return va_arg(*ap, long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 00                	mov    (%eax),%eax
  800788:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80078b:	89 c1                	mov    %eax,%ecx
  80078d:	c1 f9 1f             	sar    $0x1f,%ecx
  800790:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8d 40 04             	lea    0x4(%eax),%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)
  80079c:	eb 17                	jmp    8007b5 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8b 50 04             	mov    0x4(%eax),%edx
  8007a4:	8b 00                	mov    (%eax),%eax
  8007a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8007af:	8d 40 08             	lea    0x8(%eax),%eax
  8007b2:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  8007b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007be:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  8007c1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007c5:	78 50                	js     800817 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  8007c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ca:	c1 fa 1f             	sar    $0x1f,%edx
  8007cd:	89 d0                	mov    %edx,%eax
  8007cf:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8007d2:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8007d5:	85 d2                	test   %edx,%edx
  8007d7:	0f 89 14 02 00 00    	jns    8009f1 <vprintfmt+0x4cf>
  8007dd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007e1:	0f 84 0a 02 00 00    	je     8009f1 <vprintfmt+0x4cf>
				putch('+', putdat);
  8007e7:	83 ec 08             	sub    $0x8,%esp
  8007ea:	56                   	push   %esi
  8007eb:	6a 2b                	push   $0x2b
  8007ed:	ff d3                	call   *%ebx
  8007ef:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f7:	e9 5c 01 00 00       	jmp    800958 <vprintfmt+0x436>
		return va_arg(*ap, int);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	8b 00                	mov    (%eax),%eax
  800801:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800804:	89 c1                	mov    %eax,%ecx
  800806:	c1 f9 1f             	sar    $0x1f,%ecx
  800809:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	8d 40 04             	lea    0x4(%eax),%eax
  800812:	89 45 14             	mov    %eax,0x14(%ebp)
  800815:	eb 9e                	jmp    8007b5 <vprintfmt+0x293>
				putch('-', putdat);
  800817:	83 ec 08             	sub    $0x8,%esp
  80081a:	56                   	push   %esi
  80081b:	6a 2d                	push   $0x2d
  80081d:	ff d3                	call   *%ebx
				num = -(long long) num;
  80081f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800822:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800825:	f7 d8                	neg    %eax
  800827:	83 d2 00             	adc    $0x0,%edx
  80082a:	f7 da                	neg    %edx
  80082c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80082f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800832:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800835:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083a:	e9 19 01 00 00       	jmp    800958 <vprintfmt+0x436>
	if (lflag >= 2)
  80083f:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800843:	7f 29                	jg     80086e <vprintfmt+0x34c>
	else if (lflag)
  800845:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800849:	74 44                	je     80088f <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  80084b:	8b 45 14             	mov    0x14(%ebp),%eax
  80084e:	8b 00                	mov    (%eax),%eax
  800850:	ba 00 00 00 00       	mov    $0x0,%edx
  800855:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800858:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	8d 40 04             	lea    0x4(%eax),%eax
  800861:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800864:	b8 0a 00 00 00       	mov    $0xa,%eax
  800869:	e9 ea 00 00 00       	jmp    800958 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  80086e:	8b 45 14             	mov    0x14(%ebp),%eax
  800871:	8b 50 04             	mov    0x4(%eax),%edx
  800874:	8b 00                	mov    (%eax),%eax
  800876:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800879:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80087c:	8b 45 14             	mov    0x14(%ebp),%eax
  80087f:	8d 40 08             	lea    0x8(%eax),%eax
  800882:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800885:	b8 0a 00 00 00       	mov    $0xa,%eax
  80088a:	e9 c9 00 00 00       	jmp    800958 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80088f:	8b 45 14             	mov    0x14(%ebp),%eax
  800892:	8b 00                	mov    (%eax),%eax
  800894:	ba 00 00 00 00       	mov    $0x0,%edx
  800899:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80089c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80089f:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a2:	8d 40 04             	lea    0x4(%eax),%eax
  8008a5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008ad:	e9 a6 00 00 00       	jmp    800958 <vprintfmt+0x436>
			putch('0', putdat);
  8008b2:	83 ec 08             	sub    $0x8,%esp
  8008b5:	56                   	push   %esi
  8008b6:	6a 30                	push   $0x30
  8008b8:	ff d3                	call   *%ebx
	if (lflag >= 2)
  8008ba:	83 c4 10             	add    $0x10,%esp
  8008bd:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8008c1:	7f 26                	jg     8008e9 <vprintfmt+0x3c7>
	else if (lflag)
  8008c3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8008c7:	74 3e                	je     800907 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  8008c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cc:	8b 00                	mov    (%eax),%eax
  8008ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8008d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008d6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dc:	8d 40 04             	lea    0x4(%eax),%eax
  8008df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8008e7:	eb 6f                	jmp    800958 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8008e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ec:	8b 50 04             	mov    0x4(%eax),%edx
  8008ef:	8b 00                	mov    (%eax),%eax
  8008f1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008f4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fa:	8d 40 08             	lea    0x8(%eax),%eax
  8008fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800900:	b8 08 00 00 00       	mov    $0x8,%eax
  800905:	eb 51                	jmp    800958 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800907:	8b 45 14             	mov    0x14(%ebp),%eax
  80090a:	8b 00                	mov    (%eax),%eax
  80090c:	ba 00 00 00 00       	mov    $0x0,%edx
  800911:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800914:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800917:	8b 45 14             	mov    0x14(%ebp),%eax
  80091a:	8d 40 04             	lea    0x4(%eax),%eax
  80091d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800920:	b8 08 00 00 00       	mov    $0x8,%eax
  800925:	eb 31                	jmp    800958 <vprintfmt+0x436>
			putch('0', putdat);
  800927:	83 ec 08             	sub    $0x8,%esp
  80092a:	56                   	push   %esi
  80092b:	6a 30                	push   $0x30
  80092d:	ff d3                	call   *%ebx
			putch('x', putdat);
  80092f:	83 c4 08             	add    $0x8,%esp
  800932:	56                   	push   %esi
  800933:	6a 78                	push   $0x78
  800935:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800937:	8b 45 14             	mov    0x14(%ebp),%eax
  80093a:	8b 00                	mov    (%eax),%eax
  80093c:	ba 00 00 00 00       	mov    $0x0,%edx
  800941:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800944:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800947:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80094a:	8b 45 14             	mov    0x14(%ebp),%eax
  80094d:	8d 40 04             	lea    0x4(%eax),%eax
  800950:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800953:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800958:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  80095c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80095f:	89 c1                	mov    %eax,%ecx
  800961:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800964:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800967:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  80096c:	89 c2                	mov    %eax,%edx
  80096e:	39 c1                	cmp    %eax,%ecx
  800970:	0f 87 85 00 00 00    	ja     8009fb <vprintfmt+0x4d9>
		tmp /= base;
  800976:	89 d0                	mov    %edx,%eax
  800978:	ba 00 00 00 00       	mov    $0x0,%edx
  80097d:	f7 f1                	div    %ecx
		len++;
  80097f:	83 c7 01             	add    $0x1,%edi
  800982:	eb e8                	jmp    80096c <vprintfmt+0x44a>
	if (lflag >= 2)
  800984:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800988:	7f 26                	jg     8009b0 <vprintfmt+0x48e>
	else if (lflag)
  80098a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80098e:	74 3e                	je     8009ce <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800990:	8b 45 14             	mov    0x14(%ebp),%eax
  800993:	8b 00                	mov    (%eax),%eax
  800995:	ba 00 00 00 00       	mov    $0x0,%edx
  80099a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80099d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a3:	8d 40 04             	lea    0x4(%eax),%eax
  8009a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009a9:	b8 10 00 00 00       	mov    $0x10,%eax
  8009ae:	eb a8                	jmp    800958 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8009b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b3:	8b 50 04             	mov    0x4(%eax),%edx
  8009b6:	8b 00                	mov    (%eax),%eax
  8009b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009bb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009be:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c1:	8d 40 08             	lea    0x8(%eax),%eax
  8009c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009c7:	b8 10 00 00 00       	mov    $0x10,%eax
  8009cc:	eb 8a                	jmp    800958 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8009ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d1:	8b 00                	mov    (%eax),%eax
  8009d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009db:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009de:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e1:	8d 40 04             	lea    0x4(%eax),%eax
  8009e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009e7:	b8 10 00 00 00       	mov    $0x10,%eax
  8009ec:	e9 67 ff ff ff       	jmp    800958 <vprintfmt+0x436>
			base = 10;
  8009f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009f6:	e9 5d ff ff ff       	jmp    800958 <vprintfmt+0x436>
  8009fb:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8009fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a01:	29 f8                	sub    %edi,%eax
  800a03:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  800a05:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  800a09:	74 15                	je     800a20 <vprintfmt+0x4fe>
		while (width > 0) {
  800a0b:	85 ff                	test   %edi,%edi
  800a0d:	7e 48                	jle    800a57 <vprintfmt+0x535>
			putch(padc, putdat);
  800a0f:	83 ec 08             	sub    $0x8,%esp
  800a12:	56                   	push   %esi
  800a13:	ff 75 e0             	pushl  -0x20(%ebp)
  800a16:	ff d3                	call   *%ebx
			width--;
  800a18:	83 ef 01             	sub    $0x1,%edi
  800a1b:	83 c4 10             	add    $0x10,%esp
  800a1e:	eb eb                	jmp    800a0b <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a20:	83 ec 0c             	sub    $0xc,%esp
  800a23:	6a 2d                	push   $0x2d
  800a25:	ff 75 cc             	pushl  -0x34(%ebp)
  800a28:	ff 75 c8             	pushl  -0x38(%ebp)
  800a2b:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a2e:	ff 75 d0             	pushl  -0x30(%ebp)
  800a31:	89 f2                	mov    %esi,%edx
  800a33:	89 d8                	mov    %ebx,%eax
  800a35:	e8 1e fa ff ff       	call   800458 <printnum_helper>
		width -= len;
  800a3a:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a3d:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800a40:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800a43:	85 ff                	test   %edi,%edi
  800a45:	7e 2e                	jle    800a75 <vprintfmt+0x553>
			putch(padc, putdat);
  800a47:	83 ec 08             	sub    $0x8,%esp
  800a4a:	56                   	push   %esi
  800a4b:	6a 20                	push   $0x20
  800a4d:	ff d3                	call   *%ebx
			width--;
  800a4f:	83 ef 01             	sub    $0x1,%edi
  800a52:	83 c4 10             	add    $0x10,%esp
  800a55:	eb ec                	jmp    800a43 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a57:	83 ec 0c             	sub    $0xc,%esp
  800a5a:	ff 75 e0             	pushl  -0x20(%ebp)
  800a5d:	ff 75 cc             	pushl  -0x34(%ebp)
  800a60:	ff 75 c8             	pushl  -0x38(%ebp)
  800a63:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a66:	ff 75 d0             	pushl  -0x30(%ebp)
  800a69:	89 f2                	mov    %esi,%edx
  800a6b:	89 d8                	mov    %ebx,%eax
  800a6d:	e8 e6 f9 ff ff       	call   800458 <printnum_helper>
  800a72:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800a75:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a78:	83 c7 01             	add    $0x1,%edi
  800a7b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a7f:	83 f8 25             	cmp    $0x25,%eax
  800a82:	0f 84 b1 fa ff ff    	je     800539 <vprintfmt+0x17>
			if (ch == '\0')
  800a88:	85 c0                	test   %eax,%eax
  800a8a:	0f 84 a1 00 00 00    	je     800b31 <vprintfmt+0x60f>
			putch(ch, putdat);
  800a90:	83 ec 08             	sub    $0x8,%esp
  800a93:	56                   	push   %esi
  800a94:	50                   	push   %eax
  800a95:	ff d3                	call   *%ebx
  800a97:	83 c4 10             	add    $0x10,%esp
  800a9a:	eb dc                	jmp    800a78 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800a9c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a9f:	83 c0 04             	add    $0x4,%eax
  800aa2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800aa5:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa8:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800aaa:	85 ff                	test   %edi,%edi
  800aac:	74 15                	je     800ac3 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800aae:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800ab4:	7f 29                	jg     800adf <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800ab6:	0f b6 06             	movzbl (%esi),%eax
  800ab9:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800abb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800abe:	89 45 14             	mov    %eax,0x14(%ebp)
  800ac1:	eb b2                	jmp    800a75 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800ac3:	68 74 12 80 00       	push   $0x801274
  800ac8:	68 de 11 80 00       	push   $0x8011de
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	e8 31 fa ff ff       	call   800505 <printfmt>
  800ad4:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800ad7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ada:	89 45 14             	mov    %eax,0x14(%ebp)
  800add:	eb 96                	jmp    800a75 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800adf:	68 ac 12 80 00       	push   $0x8012ac
  800ae4:	68 de 11 80 00       	push   $0x8011de
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	e8 15 fa ff ff       	call   800505 <printfmt>
				*res = -1;
  800af0:	c6 07 ff             	movb   $0xff,(%edi)
  800af3:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800af6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800af9:	89 45 14             	mov    %eax,0x14(%ebp)
  800afc:	e9 74 ff ff ff       	jmp    800a75 <vprintfmt+0x553>
			putch(ch, putdat);
  800b01:	83 ec 08             	sub    $0x8,%esp
  800b04:	56                   	push   %esi
  800b05:	6a 25                	push   $0x25
  800b07:	ff d3                	call   *%ebx
			break;
  800b09:	83 c4 10             	add    $0x10,%esp
  800b0c:	e9 64 ff ff ff       	jmp    800a75 <vprintfmt+0x553>
			putch('%', putdat);
  800b11:	83 ec 08             	sub    $0x8,%esp
  800b14:	56                   	push   %esi
  800b15:	6a 25                	push   $0x25
  800b17:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b19:	83 c4 10             	add    $0x10,%esp
  800b1c:	89 f8                	mov    %edi,%eax
  800b1e:	eb 03                	jmp    800b23 <vprintfmt+0x601>
  800b20:	83 e8 01             	sub    $0x1,%eax
  800b23:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800b27:	75 f7                	jne    800b20 <vprintfmt+0x5fe>
  800b29:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b2c:	e9 44 ff ff ff       	jmp    800a75 <vprintfmt+0x553>
}
  800b31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	83 ec 18             	sub    $0x18,%esp
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b45:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b48:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b4c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b56:	85 c0                	test   %eax,%eax
  800b58:	74 26                	je     800b80 <vsnprintf+0x47>
  800b5a:	85 d2                	test   %edx,%edx
  800b5c:	7e 22                	jle    800b80 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b5e:	ff 75 14             	pushl  0x14(%ebp)
  800b61:	ff 75 10             	pushl  0x10(%ebp)
  800b64:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b67:	50                   	push   %eax
  800b68:	68 e8 04 80 00       	push   $0x8004e8
  800b6d:	e8 b0 f9 ff ff       	call   800522 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b75:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b7b:	83 c4 10             	add    $0x10,%esp
}
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    
		return -E_INVAL;
  800b80:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b85:	eb f7                	jmp    800b7e <vsnprintf+0x45>

00800b87 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b8d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b90:	50                   	push   %eax
  800b91:	ff 75 10             	pushl  0x10(%ebp)
  800b94:	ff 75 0c             	pushl  0xc(%ebp)
  800b97:	ff 75 08             	pushl  0x8(%ebp)
  800b9a:	e8 9a ff ff ff       	call   800b39 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ba7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bac:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bb0:	74 05                	je     800bb7 <strlen+0x16>
		n++;
  800bb2:	83 c0 01             	add    $0x1,%eax
  800bb5:	eb f5                	jmp    800bac <strlen+0xb>
	return n;
}
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	39 c2                	cmp    %eax,%edx
  800bc9:	74 0d                	je     800bd8 <strnlen+0x1f>
  800bcb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800bcf:	74 05                	je     800bd6 <strnlen+0x1d>
		n++;
  800bd1:	83 c2 01             	add    $0x1,%edx
  800bd4:	eb f1                	jmp    800bc7 <strnlen+0xe>
  800bd6:	89 d0                	mov    %edx,%eax
	return n;
}
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	53                   	push   %ebx
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800be4:	ba 00 00 00 00       	mov    $0x0,%edx
  800be9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bf0:	83 c2 01             	add    $0x1,%edx
  800bf3:	84 c9                	test   %cl,%cl
  800bf5:	75 f2                	jne    800be9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	53                   	push   %ebx
  800bfe:	83 ec 10             	sub    $0x10,%esp
  800c01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c04:	53                   	push   %ebx
  800c05:	e8 97 ff ff ff       	call   800ba1 <strlen>
  800c0a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800c0d:	ff 75 0c             	pushl  0xc(%ebp)
  800c10:	01 d8                	add    %ebx,%eax
  800c12:	50                   	push   %eax
  800c13:	e8 c2 ff ff ff       	call   800bda <strcpy>
	return dst;
}
  800c18:	89 d8                	mov    %ebx,%eax
  800c1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	8b 45 08             	mov    0x8(%ebp),%eax
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	89 c6                	mov    %eax,%esi
  800c2c:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c2f:	89 c2                	mov    %eax,%edx
  800c31:	39 f2                	cmp    %esi,%edx
  800c33:	74 11                	je     800c46 <strncpy+0x27>
		*dst++ = *src;
  800c35:	83 c2 01             	add    $0x1,%edx
  800c38:	0f b6 19             	movzbl (%ecx),%ebx
  800c3b:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c3e:	80 fb 01             	cmp    $0x1,%bl
  800c41:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800c44:	eb eb                	jmp    800c31 <strncpy+0x12>
	}
	return ret;
}
  800c46:	5b                   	pop    %ebx
  800c47:	5e                   	pop    %esi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	56                   	push   %esi
  800c4e:	53                   	push   %ebx
  800c4f:	8b 75 08             	mov    0x8(%ebp),%esi
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	8b 55 10             	mov    0x10(%ebp),%edx
  800c58:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c5a:	85 d2                	test   %edx,%edx
  800c5c:	74 21                	je     800c7f <strlcpy+0x35>
  800c5e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c62:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800c64:	39 c2                	cmp    %eax,%edx
  800c66:	74 14                	je     800c7c <strlcpy+0x32>
  800c68:	0f b6 19             	movzbl (%ecx),%ebx
  800c6b:	84 db                	test   %bl,%bl
  800c6d:	74 0b                	je     800c7a <strlcpy+0x30>
			*dst++ = *src++;
  800c6f:	83 c1 01             	add    $0x1,%ecx
  800c72:	83 c2 01             	add    $0x1,%edx
  800c75:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c78:	eb ea                	jmp    800c64 <strlcpy+0x1a>
  800c7a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c7c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c7f:	29 f0                	sub    %esi,%eax
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5d                   	pop    %ebp
  800c84:	c3                   	ret    

00800c85 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c8e:	0f b6 01             	movzbl (%ecx),%eax
  800c91:	84 c0                	test   %al,%al
  800c93:	74 0c                	je     800ca1 <strcmp+0x1c>
  800c95:	3a 02                	cmp    (%edx),%al
  800c97:	75 08                	jne    800ca1 <strcmp+0x1c>
		p++, q++;
  800c99:	83 c1 01             	add    $0x1,%ecx
  800c9c:	83 c2 01             	add    $0x1,%edx
  800c9f:	eb ed                	jmp    800c8e <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca1:	0f b6 c0             	movzbl %al,%eax
  800ca4:	0f b6 12             	movzbl (%edx),%edx
  800ca7:	29 d0                	sub    %edx,%eax
}
  800ca9:	5d                   	pop    %ebp
  800caa:	c3                   	ret    

00800cab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	53                   	push   %ebx
  800caf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cb5:	89 c3                	mov    %eax,%ebx
  800cb7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800cba:	eb 06                	jmp    800cc2 <strncmp+0x17>
		n--, p++, q++;
  800cbc:	83 c0 01             	add    $0x1,%eax
  800cbf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800cc2:	39 d8                	cmp    %ebx,%eax
  800cc4:	74 16                	je     800cdc <strncmp+0x31>
  800cc6:	0f b6 08             	movzbl (%eax),%ecx
  800cc9:	84 c9                	test   %cl,%cl
  800ccb:	74 04                	je     800cd1 <strncmp+0x26>
  800ccd:	3a 0a                	cmp    (%edx),%cl
  800ccf:	74 eb                	je     800cbc <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cd1:	0f b6 00             	movzbl (%eax),%eax
  800cd4:	0f b6 12             	movzbl (%edx),%edx
  800cd7:	29 d0                	sub    %edx,%eax
}
  800cd9:	5b                   	pop    %ebx
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    
		return 0;
  800cdc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce1:	eb f6                	jmp    800cd9 <strncmp+0x2e>

00800ce3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ced:	0f b6 10             	movzbl (%eax),%edx
  800cf0:	84 d2                	test   %dl,%dl
  800cf2:	74 09                	je     800cfd <strchr+0x1a>
		if (*s == c)
  800cf4:	38 ca                	cmp    %cl,%dl
  800cf6:	74 0a                	je     800d02 <strchr+0x1f>
	for (; *s; s++)
  800cf8:	83 c0 01             	add    $0x1,%eax
  800cfb:	eb f0                	jmp    800ced <strchr+0xa>
			return (char *) s;
	return 0;
  800cfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d0e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d11:	38 ca                	cmp    %cl,%dl
  800d13:	74 09                	je     800d1e <strfind+0x1a>
  800d15:	84 d2                	test   %dl,%dl
  800d17:	74 05                	je     800d1e <strfind+0x1a>
	for (; *s; s++)
  800d19:	83 c0 01             	add    $0x1,%eax
  800d1c:	eb f0                	jmp    800d0e <strfind+0xa>
			break;
	return (char *) s;
}
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    

00800d20 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d20:	55                   	push   %ebp
  800d21:	89 e5                	mov    %esp,%ebp
  800d23:	57                   	push   %edi
  800d24:	56                   	push   %esi
  800d25:	53                   	push   %ebx
  800d26:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d29:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d2c:	85 c9                	test   %ecx,%ecx
  800d2e:	74 31                	je     800d61 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d30:	89 f8                	mov    %edi,%eax
  800d32:	09 c8                	or     %ecx,%eax
  800d34:	a8 03                	test   $0x3,%al
  800d36:	75 23                	jne    800d5b <memset+0x3b>
		c &= 0xFF;
  800d38:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d3c:	89 d3                	mov    %edx,%ebx
  800d3e:	c1 e3 08             	shl    $0x8,%ebx
  800d41:	89 d0                	mov    %edx,%eax
  800d43:	c1 e0 18             	shl    $0x18,%eax
  800d46:	89 d6                	mov    %edx,%esi
  800d48:	c1 e6 10             	shl    $0x10,%esi
  800d4b:	09 f0                	or     %esi,%eax
  800d4d:	09 c2                	or     %eax,%edx
  800d4f:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d51:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d54:	89 d0                	mov    %edx,%eax
  800d56:	fc                   	cld    
  800d57:	f3 ab                	rep stos %eax,%es:(%edi)
  800d59:	eb 06                	jmp    800d61 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5e:	fc                   	cld    
  800d5f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d61:	89 f8                	mov    %edi,%eax
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d73:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d76:	39 c6                	cmp    %eax,%esi
  800d78:	73 32                	jae    800dac <memmove+0x44>
  800d7a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d7d:	39 c2                	cmp    %eax,%edx
  800d7f:	76 2b                	jbe    800dac <memmove+0x44>
		s += n;
		d += n;
  800d81:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d84:	89 fe                	mov    %edi,%esi
  800d86:	09 ce                	or     %ecx,%esi
  800d88:	09 d6                	or     %edx,%esi
  800d8a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d90:	75 0e                	jne    800da0 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d92:	83 ef 04             	sub    $0x4,%edi
  800d95:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d98:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d9b:	fd                   	std    
  800d9c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d9e:	eb 09                	jmp    800da9 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800da0:	83 ef 01             	sub    $0x1,%edi
  800da3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800da6:	fd                   	std    
  800da7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800da9:	fc                   	cld    
  800daa:	eb 1a                	jmp    800dc6 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dac:	89 c2                	mov    %eax,%edx
  800dae:	09 ca                	or     %ecx,%edx
  800db0:	09 f2                	or     %esi,%edx
  800db2:	f6 c2 03             	test   $0x3,%dl
  800db5:	75 0a                	jne    800dc1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800db7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800dba:	89 c7                	mov    %eax,%edi
  800dbc:	fc                   	cld    
  800dbd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dbf:	eb 05                	jmp    800dc6 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800dc1:	89 c7                	mov    %eax,%edi
  800dc3:	fc                   	cld    
  800dc4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800dd0:	ff 75 10             	pushl  0x10(%ebp)
  800dd3:	ff 75 0c             	pushl  0xc(%ebp)
  800dd6:	ff 75 08             	pushl  0x8(%ebp)
  800dd9:	e8 8a ff ff ff       	call   800d68 <memmove>
}
  800dde:	c9                   	leave  
  800ddf:	c3                   	ret    

00800de0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800deb:	89 c6                	mov    %eax,%esi
  800ded:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800df0:	39 f0                	cmp    %esi,%eax
  800df2:	74 1c                	je     800e10 <memcmp+0x30>
		if (*s1 != *s2)
  800df4:	0f b6 08             	movzbl (%eax),%ecx
  800df7:	0f b6 1a             	movzbl (%edx),%ebx
  800dfa:	38 d9                	cmp    %bl,%cl
  800dfc:	75 08                	jne    800e06 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800dfe:	83 c0 01             	add    $0x1,%eax
  800e01:	83 c2 01             	add    $0x1,%edx
  800e04:	eb ea                	jmp    800df0 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800e06:	0f b6 c1             	movzbl %cl,%eax
  800e09:	0f b6 db             	movzbl %bl,%ebx
  800e0c:	29 d8                	sub    %ebx,%eax
  800e0e:	eb 05                	jmp    800e15 <memcmp+0x35>
	}

	return 0;
  800e10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e22:	89 c2                	mov    %eax,%edx
  800e24:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e27:	39 d0                	cmp    %edx,%eax
  800e29:	73 09                	jae    800e34 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e2b:	38 08                	cmp    %cl,(%eax)
  800e2d:	74 05                	je     800e34 <memfind+0x1b>
	for (; s < ends; s++)
  800e2f:	83 c0 01             	add    $0x1,%eax
  800e32:	eb f3                	jmp    800e27 <memfind+0xe>
			break;
	return (void *) s;
}
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
  800e3c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e42:	eb 03                	jmp    800e47 <strtol+0x11>
		s++;
  800e44:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e47:	0f b6 01             	movzbl (%ecx),%eax
  800e4a:	3c 20                	cmp    $0x20,%al
  800e4c:	74 f6                	je     800e44 <strtol+0xe>
  800e4e:	3c 09                	cmp    $0x9,%al
  800e50:	74 f2                	je     800e44 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e52:	3c 2b                	cmp    $0x2b,%al
  800e54:	74 2a                	je     800e80 <strtol+0x4a>
	int neg = 0;
  800e56:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e5b:	3c 2d                	cmp    $0x2d,%al
  800e5d:	74 2b                	je     800e8a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e5f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e65:	75 0f                	jne    800e76 <strtol+0x40>
  800e67:	80 39 30             	cmpb   $0x30,(%ecx)
  800e6a:	74 28                	je     800e94 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e6c:	85 db                	test   %ebx,%ebx
  800e6e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e73:	0f 44 d8             	cmove  %eax,%ebx
  800e76:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e7e:	eb 50                	jmp    800ed0 <strtol+0x9a>
		s++;
  800e80:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e83:	bf 00 00 00 00       	mov    $0x0,%edi
  800e88:	eb d5                	jmp    800e5f <strtol+0x29>
		s++, neg = 1;
  800e8a:	83 c1 01             	add    $0x1,%ecx
  800e8d:	bf 01 00 00 00       	mov    $0x1,%edi
  800e92:	eb cb                	jmp    800e5f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e94:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e98:	74 0e                	je     800ea8 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e9a:	85 db                	test   %ebx,%ebx
  800e9c:	75 d8                	jne    800e76 <strtol+0x40>
		s++, base = 8;
  800e9e:	83 c1 01             	add    $0x1,%ecx
  800ea1:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ea6:	eb ce                	jmp    800e76 <strtol+0x40>
		s += 2, base = 16;
  800ea8:	83 c1 02             	add    $0x2,%ecx
  800eab:	bb 10 00 00 00       	mov    $0x10,%ebx
  800eb0:	eb c4                	jmp    800e76 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800eb2:	8d 72 9f             	lea    -0x61(%edx),%esi
  800eb5:	89 f3                	mov    %esi,%ebx
  800eb7:	80 fb 19             	cmp    $0x19,%bl
  800eba:	77 29                	ja     800ee5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ebc:	0f be d2             	movsbl %dl,%edx
  800ebf:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ec2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ec5:	7d 30                	jge    800ef7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ec7:	83 c1 01             	add    $0x1,%ecx
  800eca:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ece:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ed0:	0f b6 11             	movzbl (%ecx),%edx
  800ed3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ed6:	89 f3                	mov    %esi,%ebx
  800ed8:	80 fb 09             	cmp    $0x9,%bl
  800edb:	77 d5                	ja     800eb2 <strtol+0x7c>
			dig = *s - '0';
  800edd:	0f be d2             	movsbl %dl,%edx
  800ee0:	83 ea 30             	sub    $0x30,%edx
  800ee3:	eb dd                	jmp    800ec2 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800ee5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ee8:	89 f3                	mov    %esi,%ebx
  800eea:	80 fb 19             	cmp    $0x19,%bl
  800eed:	77 08                	ja     800ef7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800eef:	0f be d2             	movsbl %dl,%edx
  800ef2:	83 ea 37             	sub    $0x37,%edx
  800ef5:	eb cb                	jmp    800ec2 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ef7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800efb:	74 05                	je     800f02 <strtol+0xcc>
		*endptr = (char *) s;
  800efd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f00:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800f02:	89 c2                	mov    %eax,%edx
  800f04:	f7 da                	neg    %edx
  800f06:	85 ff                	test   %edi,%edi
  800f08:	0f 45 c2             	cmovne %edx,%eax
}
  800f0b:	5b                   	pop    %ebx
  800f0c:	5e                   	pop    %esi
  800f0d:	5f                   	pop    %edi
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

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
