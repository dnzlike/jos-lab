
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	*(unsigned*)0 = 0;
  800033:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003a:	00 00 00 
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 c6 00 00 00       	call   800114 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	c1 e0 07             	shl    $0x7,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 42 00 00 00       	call   8000d3 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7f 08                	jg     8000fd <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 4a 11 80 00       	push   $0x80114a
  800108:	6a 23                	push   $0x23
  80010a:	68 67 11 80 00       	push   $0x801167
  80010f:	e8 2e 02 00 00       	call   800342 <_panic>

00800114 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 02 00 00 00       	mov    $0x2,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_yield>:

void
sys_yield(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	asm volatile("int %1\n"
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
  800158:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80015b:	be 00 00 00 00       	mov    $0x0,%esi
  800160:	8b 55 08             	mov    0x8(%ebp),%edx
  800163:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800166:	b8 04 00 00 00       	mov    $0x4,%eax
  80016b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016e:	89 f7                	mov    %esi,%edi
  800170:	cd 30                	int    $0x30
	if(check && ret > 0)
  800172:	85 c0                	test   %eax,%eax
  800174:	7f 08                	jg     80017e <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800176:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5f                   	pop    %edi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 4a 11 80 00       	push   $0x80114a
  800189:	6a 23                	push   $0x23
  80018b:	68 67 11 80 00       	push   $0x801167
  800190:	e8 ad 01 00 00       	call   800342 <_panic>

00800195 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80019e:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001af:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	7f 08                	jg     8001c0 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bb:	5b                   	pop    %ebx
  8001bc:	5e                   	pop    %esi
  8001bd:	5f                   	pop    %edi
  8001be:	5d                   	pop    %ebp
  8001bf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 4a 11 80 00       	push   $0x80114a
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 67 11 80 00       	push   $0x801167
  8001d2:	e8 6b 01 00 00       	call   800342 <_panic>

008001d7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	57                   	push   %edi
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f0:	89 df                	mov    %ebx,%edi
  8001f2:	89 de                	mov    %ebx,%esi
  8001f4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7f 08                	jg     800202 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fd:	5b                   	pop    %ebx
  8001fe:	5e                   	pop    %esi
  8001ff:	5f                   	pop    %edi
  800200:	5d                   	pop    %ebp
  800201:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 4a 11 80 00       	push   $0x80114a
  80020d:	6a 23                	push   $0x23
  80020f:	68 67 11 80 00       	push   $0x801167
  800214:	e8 29 01 00 00       	call   800342 <_panic>

00800219 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800222:	bb 00 00 00 00       	mov    $0x0,%ebx
  800227:	8b 55 08             	mov    0x8(%ebp),%edx
  80022a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022d:	b8 08 00 00 00       	mov    $0x8,%eax
  800232:	89 df                	mov    %ebx,%edi
  800234:	89 de                	mov    %ebx,%esi
  800236:	cd 30                	int    $0x30
	if(check && ret > 0)
  800238:	85 c0                	test   %eax,%eax
  80023a:	7f 08                	jg     800244 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80023c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023f:	5b                   	pop    %ebx
  800240:	5e                   	pop    %esi
  800241:	5f                   	pop    %edi
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 4a 11 80 00       	push   $0x80114a
  80024f:	6a 23                	push   $0x23
  800251:	68 67 11 80 00       	push   $0x801167
  800256:	e8 e7 00 00 00       	call   800342 <_panic>

0080025b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	8b 55 08             	mov    0x8(%ebp),%edx
  80026c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026f:	b8 09 00 00 00       	mov    $0x9,%eax
  800274:	89 df                	mov    %ebx,%edi
  800276:	89 de                	mov    %ebx,%esi
  800278:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027a:	85 c0                	test   %eax,%eax
  80027c:	7f 08                	jg     800286 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80027e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 4a 11 80 00       	push   $0x80114a
  800291:	6a 23                	push   $0x23
  800293:	68 67 11 80 00       	push   $0x801167
  800298:	e8 a5 00 00 00       	call   800342 <_panic>

0080029d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ae:	be 00 00 00 00       	mov    $0x0,%esi
  8002b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002bb:	5b                   	pop    %ebx
  8002bc:	5e                   	pop    %esi
  8002bd:	5f                   	pop    %edi
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d6:	89 cb                	mov    %ecx,%ebx
  8002d8:	89 cf                	mov    %ecx,%edi
  8002da:	89 ce                	mov    %ecx,%esi
  8002dc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	7f 08                	jg     8002ea <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e5:	5b                   	pop    %ebx
  8002e6:	5e                   	pop    %esi
  8002e7:	5f                   	pop    %edi
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ea:	83 ec 0c             	sub    $0xc,%esp
  8002ed:	50                   	push   %eax
  8002ee:	6a 0c                	push   $0xc
  8002f0:	68 4a 11 80 00       	push   $0x80114a
  8002f5:	6a 23                	push   $0x23
  8002f7:	68 67 11 80 00       	push   $0x801167
  8002fc:	e8 41 00 00 00       	call   800342 <_panic>

00800301 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	57                   	push   %edi
  800305:	56                   	push   %esi
  800306:	53                   	push   %ebx
	asm volatile("int %1\n"
  800307:	bb 00 00 00 00       	mov    $0x0,%ebx
  80030c:	8b 55 08             	mov    0x8(%ebp),%edx
  80030f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800312:	b8 0d 00 00 00       	mov    $0xd,%eax
  800317:	89 df                	mov    %ebx,%edi
  800319:	89 de                	mov    %ebx,%esi
  80031b:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80031d:	5b                   	pop    %ebx
  80031e:	5e                   	pop    %esi
  80031f:	5f                   	pop    %edi
  800320:	5d                   	pop    %ebp
  800321:	c3                   	ret    

00800322 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800322:	55                   	push   %ebp
  800323:	89 e5                	mov    %esp,%ebp
  800325:	57                   	push   %edi
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
	asm volatile("int %1\n"
  800328:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	b8 0e 00 00 00       	mov    $0xe,%eax
  800335:	89 cb                	mov    %ecx,%ebx
  800337:	89 cf                	mov    %ecx,%edi
  800339:	89 ce                	mov    %ecx,%esi
  80033b:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80033d:	5b                   	pop    %ebx
  80033e:	5e                   	pop    %esi
  80033f:	5f                   	pop    %edi
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	56                   	push   %esi
  800346:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800347:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80034a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800350:	e8 bf fd ff ff       	call   800114 <sys_getenvid>
  800355:	83 ec 0c             	sub    $0xc,%esp
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	56                   	push   %esi
  80035f:	50                   	push   %eax
  800360:	68 78 11 80 00       	push   $0x801178
  800365:	e8 b3 00 00 00       	call   80041d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036a:	83 c4 18             	add    $0x18,%esp
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	e8 56 00 00 00       	call   8003cc <vcprintf>
	cprintf("\n");
  800376:	c7 04 24 9b 11 80 00 	movl   $0x80119b,(%esp)
  80037d:	e8 9b 00 00 00       	call   80041d <cprintf>
  800382:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800385:	cc                   	int3   
  800386:	eb fd                	jmp    800385 <_panic+0x43>

00800388 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	53                   	push   %ebx
  80038c:	83 ec 04             	sub    $0x4,%esp
  80038f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800392:	8b 13                	mov    (%ebx),%edx
  800394:	8d 42 01             	lea    0x1(%edx),%eax
  800397:	89 03                	mov    %eax,(%ebx)
  800399:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a5:	74 09                	je     8003b0 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ae:	c9                   	leave  
  8003af:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	68 ff 00 00 00       	push   $0xff
  8003b8:	8d 43 08             	lea    0x8(%ebx),%eax
  8003bb:	50                   	push   %eax
  8003bc:	e8 d5 fc ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  8003c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	eb db                	jmp    8003a7 <putch+0x1f>

008003cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003dc:	00 00 00 
	b.cnt = 0;
  8003df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e9:	ff 75 0c             	pushl  0xc(%ebp)
  8003ec:	ff 75 08             	pushl  0x8(%ebp)
  8003ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f5:	50                   	push   %eax
  8003f6:	68 88 03 80 00       	push   $0x800388
  8003fb:	e8 fb 00 00 00       	call   8004fb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800409:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040f:	50                   	push   %eax
  800410:	e8 81 fc ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  800415:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041b:	c9                   	leave  
  80041c:	c3                   	ret    

0080041d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800423:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800426:	50                   	push   %eax
  800427:	ff 75 08             	pushl  0x8(%ebp)
  80042a:	e8 9d ff ff ff       	call   8003cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80042f:	c9                   	leave  
  800430:	c3                   	ret    

00800431 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	57                   	push   %edi
  800435:	56                   	push   %esi
  800436:	53                   	push   %ebx
  800437:	83 ec 1c             	sub    $0x1c,%esp
  80043a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80043d:	89 d3                	mov    %edx,%ebx
  80043f:	8b 75 08             	mov    0x8(%ebp),%esi
  800442:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800445:	8b 45 10             	mov    0x10(%ebp),%eax
  800448:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  80044b:	89 c2                	mov    %eax,%edx
  80044d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800452:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800455:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800458:	39 c6                	cmp    %eax,%esi
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	19 c8                	sbb    %ecx,%eax
  80045e:	73 32                	jae    800492 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	53                   	push   %ebx
  800464:	83 ec 04             	sub    $0x4,%esp
  800467:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046a:	ff 75 e0             	pushl  -0x20(%ebp)
  80046d:	57                   	push   %edi
  80046e:	56                   	push   %esi
  80046f:	e8 8c 0b 00 00       	call   801000 <__umoddi3>
  800474:	83 c4 14             	add    $0x14,%esp
  800477:	0f be 80 9d 11 80 00 	movsbl 0x80119d(%eax),%eax
  80047e:	50                   	push   %eax
  80047f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800482:	ff d0                	call   *%eax
	return remain - 1;
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	83 e8 01             	sub    $0x1,%eax
}
  80048a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048d:	5b                   	pop    %ebx
  80048e:	5e                   	pop    %esi
  80048f:	5f                   	pop    %edi
  800490:	5d                   	pop    %ebp
  800491:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  800492:	83 ec 0c             	sub    $0xc,%esp
  800495:	ff 75 18             	pushl  0x18(%ebp)
  800498:	ff 75 14             	pushl  0x14(%ebp)
  80049b:	ff 75 d8             	pushl  -0x28(%ebp)
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	51                   	push   %ecx
  8004a2:	52                   	push   %edx
  8004a3:	57                   	push   %edi
  8004a4:	56                   	push   %esi
  8004a5:	e8 46 0a 00 00       	call   800ef0 <__udivdi3>
  8004aa:	83 c4 18             	add    $0x18,%esp
  8004ad:	52                   	push   %edx
  8004ae:	50                   	push   %eax
  8004af:	89 da                	mov    %ebx,%edx
  8004b1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004b4:	e8 78 ff ff ff       	call   800431 <printnum_helper>
  8004b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004bc:	83 c4 20             	add    $0x20,%esp
  8004bf:	eb 9f                	jmp    800460 <printnum_helper+0x2f>

008004c1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004c7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004cb:	8b 10                	mov    (%eax),%edx
  8004cd:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d0:	73 0a                	jae    8004dc <sprintputch+0x1b>
		*b->buf++ = ch;
  8004d2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004d5:	89 08                	mov    %ecx,(%eax)
  8004d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004da:	88 02                	mov    %al,(%edx)
}
  8004dc:	5d                   	pop    %ebp
  8004dd:	c3                   	ret    

008004de <printfmt>:
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004e4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004e7:	50                   	push   %eax
  8004e8:	ff 75 10             	pushl  0x10(%ebp)
  8004eb:	ff 75 0c             	pushl  0xc(%ebp)
  8004ee:	ff 75 08             	pushl  0x8(%ebp)
  8004f1:	e8 05 00 00 00       	call   8004fb <vprintfmt>
}
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	c9                   	leave  
  8004fa:	c3                   	ret    

008004fb <vprintfmt>:
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	57                   	push   %edi
  8004ff:	56                   	push   %esi
  800500:	53                   	push   %ebx
  800501:	83 ec 3c             	sub    $0x3c,%esp
  800504:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800507:	8b 75 0c             	mov    0xc(%ebp),%esi
  80050a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80050d:	e9 3f 05 00 00       	jmp    800a51 <vprintfmt+0x556>
		padc = ' ';
  800512:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800516:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  80051d:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800524:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  80052b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  800532:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800539:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	8d 47 01             	lea    0x1(%edi),%eax
  800541:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800544:	0f b6 17             	movzbl (%edi),%edx
  800547:	8d 42 dd             	lea    -0x23(%edx),%eax
  80054a:	3c 55                	cmp    $0x55,%al
  80054c:	0f 87 98 05 00 00    	ja     800aea <vprintfmt+0x5ef>
  800552:	0f b6 c0             	movzbl %al,%eax
  800555:	ff 24 85 e0 12 80 00 	jmp    *0x8012e0(,%eax,4)
  80055c:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  80055f:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  800563:	eb d9                	jmp    80053e <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800568:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  80056f:	eb cd                	jmp    80053e <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800571:	0f b6 d2             	movzbl %dl,%edx
  800574:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800577:	b8 00 00 00 00       	mov    $0x0,%eax
  80057c:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  80057f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800582:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800586:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800589:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80058c:	83 fb 09             	cmp    $0x9,%ebx
  80058f:	77 5c                	ja     8005ed <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  800591:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800594:	eb e9                	jmp    80057f <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  800599:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  80059d:	eb 9f                	jmp    80053e <vprintfmt+0x43>
			precision = va_arg(ap, int);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8d 40 04             	lea    0x4(%eax),%eax
  8005ad:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8005b3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b7:	79 85                	jns    80053e <vprintfmt+0x43>
				width = precision, precision = -1;
  8005b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005c6:	e9 73 ff ff ff       	jmp    80053e <vprintfmt+0x43>
  8005cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ce:	85 c0                	test   %eax,%eax
  8005d0:	0f 48 c1             	cmovs  %ecx,%eax
  8005d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005d9:	e9 60 ff ff ff       	jmp    80053e <vprintfmt+0x43>
  8005de:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8005e1:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8005e8:	e9 51 ff ff ff       	jmp    80053e <vprintfmt+0x43>
  8005ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005f3:	eb be                	jmp    8005b3 <vprintfmt+0xb8>
			lflag++;
  8005f5:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  8005fc:	e9 3d ff ff ff       	jmp    80053e <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 78 04             	lea    0x4(%eax),%edi
  800607:	83 ec 08             	sub    $0x8,%esp
  80060a:	56                   	push   %esi
  80060b:	ff 30                	pushl  (%eax)
  80060d:	ff d3                	call   *%ebx
			break;
  80060f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800612:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800615:	e9 34 04 00 00       	jmp    800a4e <vprintfmt+0x553>
			err = va_arg(ap, int);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 78 04             	lea    0x4(%eax),%edi
  800620:	8b 00                	mov    (%eax),%eax
  800622:	99                   	cltd   
  800623:	31 d0                	xor    %edx,%eax
  800625:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800627:	83 f8 08             	cmp    $0x8,%eax
  80062a:	7f 23                	jg     80064f <vprintfmt+0x154>
  80062c:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  800633:	85 d2                	test   %edx,%edx
  800635:	74 18                	je     80064f <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800637:	52                   	push   %edx
  800638:	68 be 11 80 00       	push   $0x8011be
  80063d:	56                   	push   %esi
  80063e:	53                   	push   %ebx
  80063f:	e8 9a fe ff ff       	call   8004de <printfmt>
  800644:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800647:	89 7d 14             	mov    %edi,0x14(%ebp)
  80064a:	e9 ff 03 00 00       	jmp    800a4e <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  80064f:	50                   	push   %eax
  800650:	68 b5 11 80 00       	push   $0x8011b5
  800655:	56                   	push   %esi
  800656:	53                   	push   %ebx
  800657:	e8 82 fe ff ff       	call   8004de <printfmt>
  80065c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80065f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800662:	e9 e7 03 00 00       	jmp    800a4e <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	83 c0 04             	add    $0x4,%eax
  80066d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800675:	85 c9                	test   %ecx,%ecx
  800677:	b8 ae 11 80 00       	mov    $0x8011ae,%eax
  80067c:	0f 45 c1             	cmovne %ecx,%eax
  80067f:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800682:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800686:	7e 06                	jle    80068e <vprintfmt+0x193>
  800688:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  80068c:	75 0d                	jne    80069b <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800691:	89 c7                	mov    %eax,%edi
  800693:	03 45 d8             	add    -0x28(%ebp),%eax
  800696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800699:	eb 53                	jmp    8006ee <vprintfmt+0x1f3>
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a1:	50                   	push   %eax
  8006a2:	e8 eb 04 00 00       	call   800b92 <strnlen>
  8006a7:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006aa:	29 c1                	sub    %eax,%ecx
  8006ac:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006b4:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8006b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bb:	eb 0f                	jmp    8006cc <vprintfmt+0x1d1>
					putch(padc, putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	56                   	push   %esi
  8006c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c4:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c6:	83 ef 01             	sub    $0x1,%edi
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	85 ff                	test   %edi,%edi
  8006ce:	7f ed                	jg     8006bd <vprintfmt+0x1c2>
  8006d0:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8006d3:	85 c9                	test   %ecx,%ecx
  8006d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006da:	0f 49 c1             	cmovns %ecx,%eax
  8006dd:	29 c1                	sub    %eax,%ecx
  8006df:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006e2:	eb aa                	jmp    80068e <vprintfmt+0x193>
					putch(ch, putdat);
  8006e4:	83 ec 08             	sub    $0x8,%esp
  8006e7:	56                   	push   %esi
  8006e8:	52                   	push   %edx
  8006e9:	ff d3                	call   *%ebx
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006f1:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006f3:	83 c7 01             	add    $0x1,%edi
  8006f6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006fa:	0f be d0             	movsbl %al,%edx
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	74 2e                	je     80072f <vprintfmt+0x234>
  800701:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800705:	78 06                	js     80070d <vprintfmt+0x212>
  800707:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80070b:	78 1e                	js     80072b <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  80070d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800711:	74 d1                	je     8006e4 <vprintfmt+0x1e9>
  800713:	0f be c0             	movsbl %al,%eax
  800716:	83 e8 20             	sub    $0x20,%eax
  800719:	83 f8 5e             	cmp    $0x5e,%eax
  80071c:	76 c6                	jbe    8006e4 <vprintfmt+0x1e9>
					putch('?', putdat);
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	56                   	push   %esi
  800722:	6a 3f                	push   $0x3f
  800724:	ff d3                	call   *%ebx
  800726:	83 c4 10             	add    $0x10,%esp
  800729:	eb c3                	jmp    8006ee <vprintfmt+0x1f3>
  80072b:	89 cf                	mov    %ecx,%edi
  80072d:	eb 02                	jmp    800731 <vprintfmt+0x236>
  80072f:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  800731:	85 ff                	test   %edi,%edi
  800733:	7e 10                	jle    800745 <vprintfmt+0x24a>
				putch(' ', putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	56                   	push   %esi
  800739:	6a 20                	push   $0x20
  80073b:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80073d:	83 ef 01             	sub    $0x1,%edi
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	eb ec                	jmp    800731 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800745:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800748:	89 45 14             	mov    %eax,0x14(%ebp)
  80074b:	e9 fe 02 00 00       	jmp    800a4e <vprintfmt+0x553>
	if (lflag >= 2)
  800750:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800754:	7f 21                	jg     800777 <vprintfmt+0x27c>
	else if (lflag)
  800756:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80075a:	74 79                	je     8007d5 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  80075c:	8b 45 14             	mov    0x14(%ebp),%eax
  80075f:	8b 00                	mov    (%eax),%eax
  800761:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800764:	89 c1                	mov    %eax,%ecx
  800766:	c1 f9 1f             	sar    $0x1f,%ecx
  800769:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 40 04             	lea    0x4(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
  800775:	eb 17                	jmp    80078e <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8b 50 04             	mov    0x4(%eax),%edx
  80077d:	8b 00                	mov    (%eax),%eax
  80077f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800782:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8d 40 08             	lea    0x8(%eax),%eax
  80078b:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  80078e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800791:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800794:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800797:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  80079a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80079e:	78 50                	js     8007f0 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  8007a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007a3:	c1 fa 1f             	sar    $0x1f,%edx
  8007a6:	89 d0                	mov    %edx,%eax
  8007a8:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8007ab:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	0f 89 14 02 00 00    	jns    8009ca <vprintfmt+0x4cf>
  8007b6:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007ba:	0f 84 0a 02 00 00    	je     8009ca <vprintfmt+0x4cf>
				putch('+', putdat);
  8007c0:	83 ec 08             	sub    $0x8,%esp
  8007c3:	56                   	push   %esi
  8007c4:	6a 2b                	push   $0x2b
  8007c6:	ff d3                	call   *%ebx
  8007c8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d0:	e9 5c 01 00 00       	jmp    800931 <vprintfmt+0x436>
		return va_arg(*ap, int);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8b 00                	mov    (%eax),%eax
  8007da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007dd:	89 c1                	mov    %eax,%ecx
  8007df:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8d 40 04             	lea    0x4(%eax),%eax
  8007eb:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ee:	eb 9e                	jmp    80078e <vprintfmt+0x293>
				putch('-', putdat);
  8007f0:	83 ec 08             	sub    $0x8,%esp
  8007f3:	56                   	push   %esi
  8007f4:	6a 2d                	push   $0x2d
  8007f6:	ff d3                	call   *%ebx
				num = -(long long) num;
  8007f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007fe:	f7 d8                	neg    %eax
  800800:	83 d2 00             	adc    $0x0,%edx
  800803:	f7 da                	neg    %edx
  800805:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800808:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80080b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80080e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800813:	e9 19 01 00 00       	jmp    800931 <vprintfmt+0x436>
	if (lflag >= 2)
  800818:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80081c:	7f 29                	jg     800847 <vprintfmt+0x34c>
	else if (lflag)
  80081e:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800822:	74 44                	je     800868 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8b 00                	mov    (%eax),%eax
  800829:	ba 00 00 00 00       	mov    $0x0,%edx
  80082e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800831:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800834:	8b 45 14             	mov    0x14(%ebp),%eax
  800837:	8d 40 04             	lea    0x4(%eax),%eax
  80083a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80083d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800842:	e9 ea 00 00 00       	jmp    800931 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800847:	8b 45 14             	mov    0x14(%ebp),%eax
  80084a:	8b 50 04             	mov    0x4(%eax),%edx
  80084d:	8b 00                	mov    (%eax),%eax
  80084f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800852:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800855:	8b 45 14             	mov    0x14(%ebp),%eax
  800858:	8d 40 08             	lea    0x8(%eax),%eax
  80085b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80085e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800863:	e9 c9 00 00 00       	jmp    800931 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8b 00                	mov    (%eax),%eax
  80086d:	ba 00 00 00 00       	mov    $0x0,%edx
  800872:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800875:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8d 40 04             	lea    0x4(%eax),%eax
  80087e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800881:	b8 0a 00 00 00       	mov    $0xa,%eax
  800886:	e9 a6 00 00 00       	jmp    800931 <vprintfmt+0x436>
			putch('0', putdat);
  80088b:	83 ec 08             	sub    $0x8,%esp
  80088e:	56                   	push   %esi
  80088f:	6a 30                	push   $0x30
  800891:	ff d3                	call   *%ebx
	if (lflag >= 2)
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80089a:	7f 26                	jg     8008c2 <vprintfmt+0x3c7>
	else if (lflag)
  80089c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8008a0:	74 3e                	je     8008e0 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  8008a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a5:	8b 00                	mov    (%eax),%eax
  8008a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008af:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 40 04             	lea    0x4(%eax),%eax
  8008b8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008bb:	b8 08 00 00 00       	mov    $0x8,%eax
  8008c0:	eb 6f                	jmp    800931 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8008c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c5:	8b 50 04             	mov    0x4(%eax),%edx
  8008c8:	8b 00                	mov    (%eax),%eax
  8008ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008cd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d3:	8d 40 08             	lea    0x8(%eax),%eax
  8008d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008d9:	b8 08 00 00 00       	mov    $0x8,%eax
  8008de:	eb 51                	jmp    800931 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8b 00                	mov    (%eax),%eax
  8008e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008ed:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f3:	8d 40 04             	lea    0x4(%eax),%eax
  8008f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008f9:	b8 08 00 00 00       	mov    $0x8,%eax
  8008fe:	eb 31                	jmp    800931 <vprintfmt+0x436>
			putch('0', putdat);
  800900:	83 ec 08             	sub    $0x8,%esp
  800903:	56                   	push   %esi
  800904:	6a 30                	push   $0x30
  800906:	ff d3                	call   *%ebx
			putch('x', putdat);
  800908:	83 c4 08             	add    $0x8,%esp
  80090b:	56                   	push   %esi
  80090c:	6a 78                	push   $0x78
  80090e:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800910:	8b 45 14             	mov    0x14(%ebp),%eax
  800913:	8b 00                	mov    (%eax),%eax
  800915:	ba 00 00 00 00       	mov    $0x0,%edx
  80091a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80091d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800920:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800923:	8b 45 14             	mov    0x14(%ebp),%eax
  800926:	8d 40 04             	lea    0x4(%eax),%eax
  800929:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80092c:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800931:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800935:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800938:	89 c1                	mov    %eax,%ecx
  80093a:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  80093d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800940:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800945:	89 c2                	mov    %eax,%edx
  800947:	39 c1                	cmp    %eax,%ecx
  800949:	0f 87 85 00 00 00    	ja     8009d4 <vprintfmt+0x4d9>
		tmp /= base;
  80094f:	89 d0                	mov    %edx,%eax
  800951:	ba 00 00 00 00       	mov    $0x0,%edx
  800956:	f7 f1                	div    %ecx
		len++;
  800958:	83 c7 01             	add    $0x1,%edi
  80095b:	eb e8                	jmp    800945 <vprintfmt+0x44a>
	if (lflag >= 2)
  80095d:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800961:	7f 26                	jg     800989 <vprintfmt+0x48e>
	else if (lflag)
  800963:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800967:	74 3e                	je     8009a7 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800969:	8b 45 14             	mov    0x14(%ebp),%eax
  80096c:	8b 00                	mov    (%eax),%eax
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800976:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800979:	8b 45 14             	mov    0x14(%ebp),%eax
  80097c:	8d 40 04             	lea    0x4(%eax),%eax
  80097f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800982:	b8 10 00 00 00       	mov    $0x10,%eax
  800987:	eb a8                	jmp    800931 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800989:	8b 45 14             	mov    0x14(%ebp),%eax
  80098c:	8b 50 04             	mov    0x4(%eax),%edx
  80098f:	8b 00                	mov    (%eax),%eax
  800991:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800994:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 40 08             	lea    0x8(%eax),%eax
  80099d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009a0:	b8 10 00 00 00       	mov    $0x10,%eax
  8009a5:	eb 8a                	jmp    800931 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8009a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009aa:	8b 00                	mov    (%eax),%eax
  8009ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ba:	8d 40 04             	lea    0x4(%eax),%eax
  8009bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009c0:	b8 10 00 00 00       	mov    $0x10,%eax
  8009c5:	e9 67 ff ff ff       	jmp    800931 <vprintfmt+0x436>
			base = 10;
  8009ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009cf:	e9 5d ff ff ff       	jmp    800931 <vprintfmt+0x436>
  8009d4:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8009d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009da:	29 f8                	sub    %edi,%eax
  8009dc:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8009de:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8009e2:	74 15                	je     8009f9 <vprintfmt+0x4fe>
		while (width > 0) {
  8009e4:	85 ff                	test   %edi,%edi
  8009e6:	7e 48                	jle    800a30 <vprintfmt+0x535>
			putch(padc, putdat);
  8009e8:	83 ec 08             	sub    $0x8,%esp
  8009eb:	56                   	push   %esi
  8009ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ef:	ff d3                	call   *%ebx
			width--;
  8009f1:	83 ef 01             	sub    $0x1,%edi
  8009f4:	83 c4 10             	add    $0x10,%esp
  8009f7:	eb eb                	jmp    8009e4 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	6a 2d                	push   $0x2d
  8009fe:	ff 75 cc             	pushl  -0x34(%ebp)
  800a01:	ff 75 c8             	pushl  -0x38(%ebp)
  800a04:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a07:	ff 75 d0             	pushl  -0x30(%ebp)
  800a0a:	89 f2                	mov    %esi,%edx
  800a0c:	89 d8                	mov    %ebx,%eax
  800a0e:	e8 1e fa ff ff       	call   800431 <printnum_helper>
		width -= len;
  800a13:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a16:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800a19:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800a1c:	85 ff                	test   %edi,%edi
  800a1e:	7e 2e                	jle    800a4e <vprintfmt+0x553>
			putch(padc, putdat);
  800a20:	83 ec 08             	sub    $0x8,%esp
  800a23:	56                   	push   %esi
  800a24:	6a 20                	push   $0x20
  800a26:	ff d3                	call   *%ebx
			width--;
  800a28:	83 ef 01             	sub    $0x1,%edi
  800a2b:	83 c4 10             	add    $0x10,%esp
  800a2e:	eb ec                	jmp    800a1c <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a30:	83 ec 0c             	sub    $0xc,%esp
  800a33:	ff 75 e0             	pushl  -0x20(%ebp)
  800a36:	ff 75 cc             	pushl  -0x34(%ebp)
  800a39:	ff 75 c8             	pushl  -0x38(%ebp)
  800a3c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a3f:	ff 75 d0             	pushl  -0x30(%ebp)
  800a42:	89 f2                	mov    %esi,%edx
  800a44:	89 d8                	mov    %ebx,%eax
  800a46:	e8 e6 f9 ff ff       	call   800431 <printnum_helper>
  800a4b:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800a4e:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a51:	83 c7 01             	add    $0x1,%edi
  800a54:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a58:	83 f8 25             	cmp    $0x25,%eax
  800a5b:	0f 84 b1 fa ff ff    	je     800512 <vprintfmt+0x17>
			if (ch == '\0')
  800a61:	85 c0                	test   %eax,%eax
  800a63:	0f 84 a1 00 00 00    	je     800b0a <vprintfmt+0x60f>
			putch(ch, putdat);
  800a69:	83 ec 08             	sub    $0x8,%esp
  800a6c:	56                   	push   %esi
  800a6d:	50                   	push   %eax
  800a6e:	ff d3                	call   *%ebx
  800a70:	83 c4 10             	add    $0x10,%esp
  800a73:	eb dc                	jmp    800a51 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800a75:	8b 45 14             	mov    0x14(%ebp),%eax
  800a78:	83 c0 04             	add    $0x4,%eax
  800a7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a81:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800a83:	85 ff                	test   %edi,%edi
  800a85:	74 15                	je     800a9c <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800a87:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800a8d:	7f 29                	jg     800ab8 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800a8f:	0f b6 06             	movzbl (%esi),%eax
  800a92:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800a94:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a97:	89 45 14             	mov    %eax,0x14(%ebp)
  800a9a:	eb b2                	jmp    800a4e <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800a9c:	68 54 12 80 00       	push   $0x801254
  800aa1:	68 be 11 80 00       	push   $0x8011be
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	e8 31 fa ff ff       	call   8004de <printfmt>
  800aad:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800ab0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ab3:	89 45 14             	mov    %eax,0x14(%ebp)
  800ab6:	eb 96                	jmp    800a4e <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800ab8:	68 8c 12 80 00       	push   $0x80128c
  800abd:	68 be 11 80 00       	push   $0x8011be
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
  800ac4:	e8 15 fa ff ff       	call   8004de <printfmt>
				*res = -1;
  800ac9:	c6 07 ff             	movb   $0xff,(%edi)
  800acc:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800acf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ad2:	89 45 14             	mov    %eax,0x14(%ebp)
  800ad5:	e9 74 ff ff ff       	jmp    800a4e <vprintfmt+0x553>
			putch(ch, putdat);
  800ada:	83 ec 08             	sub    $0x8,%esp
  800add:	56                   	push   %esi
  800ade:	6a 25                	push   $0x25
  800ae0:	ff d3                	call   *%ebx
			break;
  800ae2:	83 c4 10             	add    $0x10,%esp
  800ae5:	e9 64 ff ff ff       	jmp    800a4e <vprintfmt+0x553>
			putch('%', putdat);
  800aea:	83 ec 08             	sub    $0x8,%esp
  800aed:	56                   	push   %esi
  800aee:	6a 25                	push   $0x25
  800af0:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800af2:	83 c4 10             	add    $0x10,%esp
  800af5:	89 f8                	mov    %edi,%eax
  800af7:	eb 03                	jmp    800afc <vprintfmt+0x601>
  800af9:	83 e8 01             	sub    $0x1,%eax
  800afc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800b00:	75 f7                	jne    800af9 <vprintfmt+0x5fe>
  800b02:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b05:	e9 44 ff ff ff       	jmp    800a4e <vprintfmt+0x553>
}
  800b0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	83 ec 18             	sub    $0x18,%esp
  800b18:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b21:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b25:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	74 26                	je     800b59 <vsnprintf+0x47>
  800b33:	85 d2                	test   %edx,%edx
  800b35:	7e 22                	jle    800b59 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b37:	ff 75 14             	pushl  0x14(%ebp)
  800b3a:	ff 75 10             	pushl  0x10(%ebp)
  800b3d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b40:	50                   	push   %eax
  800b41:	68 c1 04 80 00       	push   $0x8004c1
  800b46:	e8 b0 f9 ff ff       	call   8004fb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b4e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b54:	83 c4 10             	add    $0x10,%esp
}
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    
		return -E_INVAL;
  800b59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b5e:	eb f7                	jmp    800b57 <vsnprintf+0x45>

00800b60 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b66:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b69:	50                   	push   %eax
  800b6a:	ff 75 10             	pushl  0x10(%ebp)
  800b6d:	ff 75 0c             	pushl  0xc(%ebp)
  800b70:	ff 75 08             	pushl  0x8(%ebp)
  800b73:	e8 9a ff ff ff       	call   800b12 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b78:	c9                   	leave  
  800b79:	c3                   	ret    

00800b7a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
  800b85:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b89:	74 05                	je     800b90 <strlen+0x16>
		n++;
  800b8b:	83 c0 01             	add    $0x1,%eax
  800b8e:	eb f5                	jmp    800b85 <strlen+0xb>
	return n;
}
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b98:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	39 c2                	cmp    %eax,%edx
  800ba2:	74 0d                	je     800bb1 <strnlen+0x1f>
  800ba4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ba8:	74 05                	je     800baf <strnlen+0x1d>
		n++;
  800baa:	83 c2 01             	add    $0x1,%edx
  800bad:	eb f1                	jmp    800ba0 <strnlen+0xe>
  800baf:	89 d0                	mov    %edx,%eax
	return n;
}
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	53                   	push   %ebx
  800bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bc6:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bc9:	83 c2 01             	add    $0x1,%edx
  800bcc:	84 c9                	test   %cl,%cl
  800bce:	75 f2                	jne    800bc2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bd0:	5b                   	pop    %ebx
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 10             	sub    $0x10,%esp
  800bda:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bdd:	53                   	push   %ebx
  800bde:	e8 97 ff ff ff       	call   800b7a <strlen>
  800be3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800be6:	ff 75 0c             	pushl  0xc(%ebp)
  800be9:	01 d8                	add    %ebx,%eax
  800beb:	50                   	push   %eax
  800bec:	e8 c2 ff ff ff       	call   800bb3 <strcpy>
	return dst;
}
  800bf1:	89 d8                	mov    %ebx,%eax
  800bf3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	89 c6                	mov    %eax,%esi
  800c05:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c08:	89 c2                	mov    %eax,%edx
  800c0a:	39 f2                	cmp    %esi,%edx
  800c0c:	74 11                	je     800c1f <strncpy+0x27>
		*dst++ = *src;
  800c0e:	83 c2 01             	add    $0x1,%edx
  800c11:	0f b6 19             	movzbl (%ecx),%ebx
  800c14:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c17:	80 fb 01             	cmp    $0x1,%bl
  800c1a:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800c1d:	eb eb                	jmp    800c0a <strncpy+0x12>
	}
	return ret;
}
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	8b 75 08             	mov    0x8(%ebp),%esi
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	8b 55 10             	mov    0x10(%ebp),%edx
  800c31:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c33:	85 d2                	test   %edx,%edx
  800c35:	74 21                	je     800c58 <strlcpy+0x35>
  800c37:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c3b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800c3d:	39 c2                	cmp    %eax,%edx
  800c3f:	74 14                	je     800c55 <strlcpy+0x32>
  800c41:	0f b6 19             	movzbl (%ecx),%ebx
  800c44:	84 db                	test   %bl,%bl
  800c46:	74 0b                	je     800c53 <strlcpy+0x30>
			*dst++ = *src++;
  800c48:	83 c1 01             	add    $0x1,%ecx
  800c4b:	83 c2 01             	add    $0x1,%edx
  800c4e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c51:	eb ea                	jmp    800c3d <strlcpy+0x1a>
  800c53:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c55:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c58:	29 f0                	sub    %esi,%eax
}
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c64:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c67:	0f b6 01             	movzbl (%ecx),%eax
  800c6a:	84 c0                	test   %al,%al
  800c6c:	74 0c                	je     800c7a <strcmp+0x1c>
  800c6e:	3a 02                	cmp    (%edx),%al
  800c70:	75 08                	jne    800c7a <strcmp+0x1c>
		p++, q++;
  800c72:	83 c1 01             	add    $0x1,%ecx
  800c75:	83 c2 01             	add    $0x1,%edx
  800c78:	eb ed                	jmp    800c67 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c7a:	0f b6 c0             	movzbl %al,%eax
  800c7d:	0f b6 12             	movzbl (%edx),%edx
  800c80:	29 d0                	sub    %edx,%eax
}
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	53                   	push   %ebx
  800c88:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c8e:	89 c3                	mov    %eax,%ebx
  800c90:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c93:	eb 06                	jmp    800c9b <strncmp+0x17>
		n--, p++, q++;
  800c95:	83 c0 01             	add    $0x1,%eax
  800c98:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c9b:	39 d8                	cmp    %ebx,%eax
  800c9d:	74 16                	je     800cb5 <strncmp+0x31>
  800c9f:	0f b6 08             	movzbl (%eax),%ecx
  800ca2:	84 c9                	test   %cl,%cl
  800ca4:	74 04                	je     800caa <strncmp+0x26>
  800ca6:	3a 0a                	cmp    (%edx),%cl
  800ca8:	74 eb                	je     800c95 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800caa:	0f b6 00             	movzbl (%eax),%eax
  800cad:	0f b6 12             	movzbl (%edx),%edx
  800cb0:	29 d0                	sub    %edx,%eax
}
  800cb2:	5b                   	pop    %ebx
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    
		return 0;
  800cb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cba:	eb f6                	jmp    800cb2 <strncmp+0x2e>

00800cbc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cc6:	0f b6 10             	movzbl (%eax),%edx
  800cc9:	84 d2                	test   %dl,%dl
  800ccb:	74 09                	je     800cd6 <strchr+0x1a>
		if (*s == c)
  800ccd:	38 ca                	cmp    %cl,%dl
  800ccf:	74 0a                	je     800cdb <strchr+0x1f>
	for (; *s; s++)
  800cd1:	83 c0 01             	add    $0x1,%eax
  800cd4:	eb f0                	jmp    800cc6 <strchr+0xa>
			return (char *) s;
	return 0;
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ce7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cea:	38 ca                	cmp    %cl,%dl
  800cec:	74 09                	je     800cf7 <strfind+0x1a>
  800cee:	84 d2                	test   %dl,%dl
  800cf0:	74 05                	je     800cf7 <strfind+0x1a>
	for (; *s; s++)
  800cf2:	83 c0 01             	add    $0x1,%eax
  800cf5:	eb f0                	jmp    800ce7 <strfind+0xa>
			break;
	return (char *) s;
}
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d05:	85 c9                	test   %ecx,%ecx
  800d07:	74 31                	je     800d3a <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d09:	89 f8                	mov    %edi,%eax
  800d0b:	09 c8                	or     %ecx,%eax
  800d0d:	a8 03                	test   $0x3,%al
  800d0f:	75 23                	jne    800d34 <memset+0x3b>
		c &= 0xFF;
  800d11:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d15:	89 d3                	mov    %edx,%ebx
  800d17:	c1 e3 08             	shl    $0x8,%ebx
  800d1a:	89 d0                	mov    %edx,%eax
  800d1c:	c1 e0 18             	shl    $0x18,%eax
  800d1f:	89 d6                	mov    %edx,%esi
  800d21:	c1 e6 10             	shl    $0x10,%esi
  800d24:	09 f0                	or     %esi,%eax
  800d26:	09 c2                	or     %eax,%edx
  800d28:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d2a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d2d:	89 d0                	mov    %edx,%eax
  800d2f:	fc                   	cld    
  800d30:	f3 ab                	rep stos %eax,%es:(%edi)
  800d32:	eb 06                	jmp    800d3a <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d37:	fc                   	cld    
  800d38:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d3a:	89 f8                	mov    %edi,%eax
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	8b 45 08             	mov    0x8(%ebp),%eax
  800d49:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d4c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d4f:	39 c6                	cmp    %eax,%esi
  800d51:	73 32                	jae    800d85 <memmove+0x44>
  800d53:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d56:	39 c2                	cmp    %eax,%edx
  800d58:	76 2b                	jbe    800d85 <memmove+0x44>
		s += n;
		d += n;
  800d5a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d5d:	89 fe                	mov    %edi,%esi
  800d5f:	09 ce                	or     %ecx,%esi
  800d61:	09 d6                	or     %edx,%esi
  800d63:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d69:	75 0e                	jne    800d79 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d6b:	83 ef 04             	sub    $0x4,%edi
  800d6e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d71:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d74:	fd                   	std    
  800d75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d77:	eb 09                	jmp    800d82 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d79:	83 ef 01             	sub    $0x1,%edi
  800d7c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d7f:	fd                   	std    
  800d80:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d82:	fc                   	cld    
  800d83:	eb 1a                	jmp    800d9f <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d85:	89 c2                	mov    %eax,%edx
  800d87:	09 ca                	or     %ecx,%edx
  800d89:	09 f2                	or     %esi,%edx
  800d8b:	f6 c2 03             	test   $0x3,%dl
  800d8e:	75 0a                	jne    800d9a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d90:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d93:	89 c7                	mov    %eax,%edi
  800d95:	fc                   	cld    
  800d96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d98:	eb 05                	jmp    800d9f <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800d9a:	89 c7                	mov    %eax,%edi
  800d9c:	fc                   	cld    
  800d9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800da9:	ff 75 10             	pushl  0x10(%ebp)
  800dac:	ff 75 0c             	pushl  0xc(%ebp)
  800daf:	ff 75 08             	pushl  0x8(%ebp)
  800db2:	e8 8a ff ff ff       	call   800d41 <memmove>
}
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    

00800db9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc4:	89 c6                	mov    %eax,%esi
  800dc6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dc9:	39 f0                	cmp    %esi,%eax
  800dcb:	74 1c                	je     800de9 <memcmp+0x30>
		if (*s1 != *s2)
  800dcd:	0f b6 08             	movzbl (%eax),%ecx
  800dd0:	0f b6 1a             	movzbl (%edx),%ebx
  800dd3:	38 d9                	cmp    %bl,%cl
  800dd5:	75 08                	jne    800ddf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800dd7:	83 c0 01             	add    $0x1,%eax
  800dda:	83 c2 01             	add    $0x1,%edx
  800ddd:	eb ea                	jmp    800dc9 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800ddf:	0f b6 c1             	movzbl %cl,%eax
  800de2:	0f b6 db             	movzbl %bl,%ebx
  800de5:	29 d8                	sub    %ebx,%eax
  800de7:	eb 05                	jmp    800dee <memcmp+0x35>
	}

	return 0;
  800de9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dee:	5b                   	pop    %ebx
  800def:	5e                   	pop    %esi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800dfb:	89 c2                	mov    %eax,%edx
  800dfd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e00:	39 d0                	cmp    %edx,%eax
  800e02:	73 09                	jae    800e0d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e04:	38 08                	cmp    %cl,(%eax)
  800e06:	74 05                	je     800e0d <memfind+0x1b>
	for (; s < ends; s++)
  800e08:	83 c0 01             	add    $0x1,%eax
  800e0b:	eb f3                	jmp    800e00 <memfind+0xe>
			break;
	return (void *) s;
}
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
  800e15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e1b:	eb 03                	jmp    800e20 <strtol+0x11>
		s++;
  800e1d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e20:	0f b6 01             	movzbl (%ecx),%eax
  800e23:	3c 20                	cmp    $0x20,%al
  800e25:	74 f6                	je     800e1d <strtol+0xe>
  800e27:	3c 09                	cmp    $0x9,%al
  800e29:	74 f2                	je     800e1d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e2b:	3c 2b                	cmp    $0x2b,%al
  800e2d:	74 2a                	je     800e59 <strtol+0x4a>
	int neg = 0;
  800e2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e34:	3c 2d                	cmp    $0x2d,%al
  800e36:	74 2b                	je     800e63 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e3e:	75 0f                	jne    800e4f <strtol+0x40>
  800e40:	80 39 30             	cmpb   $0x30,(%ecx)
  800e43:	74 28                	je     800e6d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e45:	85 db                	test   %ebx,%ebx
  800e47:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4c:	0f 44 d8             	cmove  %eax,%ebx
  800e4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e54:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e57:	eb 50                	jmp    800ea9 <strtol+0x9a>
		s++;
  800e59:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e5c:	bf 00 00 00 00       	mov    $0x0,%edi
  800e61:	eb d5                	jmp    800e38 <strtol+0x29>
		s++, neg = 1;
  800e63:	83 c1 01             	add    $0x1,%ecx
  800e66:	bf 01 00 00 00       	mov    $0x1,%edi
  800e6b:	eb cb                	jmp    800e38 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e6d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e71:	74 0e                	je     800e81 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e73:	85 db                	test   %ebx,%ebx
  800e75:	75 d8                	jne    800e4f <strtol+0x40>
		s++, base = 8;
  800e77:	83 c1 01             	add    $0x1,%ecx
  800e7a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e7f:	eb ce                	jmp    800e4f <strtol+0x40>
		s += 2, base = 16;
  800e81:	83 c1 02             	add    $0x2,%ecx
  800e84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e89:	eb c4                	jmp    800e4f <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800e8b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e8e:	89 f3                	mov    %esi,%ebx
  800e90:	80 fb 19             	cmp    $0x19,%bl
  800e93:	77 29                	ja     800ebe <strtol+0xaf>
			dig = *s - 'a' + 10;
  800e95:	0f be d2             	movsbl %dl,%edx
  800e98:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e9b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e9e:	7d 30                	jge    800ed0 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ea0:	83 c1 01             	add    $0x1,%ecx
  800ea3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ea7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ea9:	0f b6 11             	movzbl (%ecx),%edx
  800eac:	8d 72 d0             	lea    -0x30(%edx),%esi
  800eaf:	89 f3                	mov    %esi,%ebx
  800eb1:	80 fb 09             	cmp    $0x9,%bl
  800eb4:	77 d5                	ja     800e8b <strtol+0x7c>
			dig = *s - '0';
  800eb6:	0f be d2             	movsbl %dl,%edx
  800eb9:	83 ea 30             	sub    $0x30,%edx
  800ebc:	eb dd                	jmp    800e9b <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800ebe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ec1:	89 f3                	mov    %esi,%ebx
  800ec3:	80 fb 19             	cmp    $0x19,%bl
  800ec6:	77 08                	ja     800ed0 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ec8:	0f be d2             	movsbl %dl,%edx
  800ecb:	83 ea 37             	sub    $0x37,%edx
  800ece:	eb cb                	jmp    800e9b <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ed0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed4:	74 05                	je     800edb <strtol+0xcc>
		*endptr = (char *) s;
  800ed6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800edb:	89 c2                	mov    %eax,%edx
  800edd:	f7 da                	neg    %edx
  800edf:	85 ff                	test   %edi,%edi
  800ee1:	0f 45 c2             	cmovne %edx,%eax
}
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    
  800ee9:	66 90                	xchg   %ax,%ax
  800eeb:	66 90                	xchg   %ax,%ax
  800eed:	66 90                	xchg   %ax,%ax
  800eef:	90                   	nop

00800ef0 <__udivdi3>:
  800ef0:	55                   	push   %ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 1c             	sub    $0x1c,%esp
  800ef7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800efb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800eff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f03:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f07:	85 d2                	test   %edx,%edx
  800f09:	75 4d                	jne    800f58 <__udivdi3+0x68>
  800f0b:	39 f3                	cmp    %esi,%ebx
  800f0d:	76 19                	jbe    800f28 <__udivdi3+0x38>
  800f0f:	31 ff                	xor    %edi,%edi
  800f11:	89 e8                	mov    %ebp,%eax
  800f13:	89 f2                	mov    %esi,%edx
  800f15:	f7 f3                	div    %ebx
  800f17:	89 fa                	mov    %edi,%edx
  800f19:	83 c4 1c             	add    $0x1c,%esp
  800f1c:	5b                   	pop    %ebx
  800f1d:	5e                   	pop    %esi
  800f1e:	5f                   	pop    %edi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    
  800f21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f28:	89 d9                	mov    %ebx,%ecx
  800f2a:	85 db                	test   %ebx,%ebx
  800f2c:	75 0b                	jne    800f39 <__udivdi3+0x49>
  800f2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f33:	31 d2                	xor    %edx,%edx
  800f35:	f7 f3                	div    %ebx
  800f37:	89 c1                	mov    %eax,%ecx
  800f39:	31 d2                	xor    %edx,%edx
  800f3b:	89 f0                	mov    %esi,%eax
  800f3d:	f7 f1                	div    %ecx
  800f3f:	89 c6                	mov    %eax,%esi
  800f41:	89 e8                	mov    %ebp,%eax
  800f43:	89 f7                	mov    %esi,%edi
  800f45:	f7 f1                	div    %ecx
  800f47:	89 fa                	mov    %edi,%edx
  800f49:	83 c4 1c             	add    $0x1c,%esp
  800f4c:	5b                   	pop    %ebx
  800f4d:	5e                   	pop    %esi
  800f4e:	5f                   	pop    %edi
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    
  800f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f58:	39 f2                	cmp    %esi,%edx
  800f5a:	77 1c                	ja     800f78 <__udivdi3+0x88>
  800f5c:	0f bd fa             	bsr    %edx,%edi
  800f5f:	83 f7 1f             	xor    $0x1f,%edi
  800f62:	75 2c                	jne    800f90 <__udivdi3+0xa0>
  800f64:	39 f2                	cmp    %esi,%edx
  800f66:	72 06                	jb     800f6e <__udivdi3+0x7e>
  800f68:	31 c0                	xor    %eax,%eax
  800f6a:	39 eb                	cmp    %ebp,%ebx
  800f6c:	77 a9                	ja     800f17 <__udivdi3+0x27>
  800f6e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f73:	eb a2                	jmp    800f17 <__udivdi3+0x27>
  800f75:	8d 76 00             	lea    0x0(%esi),%esi
  800f78:	31 ff                	xor    %edi,%edi
  800f7a:	31 c0                	xor    %eax,%eax
  800f7c:	89 fa                	mov    %edi,%edx
  800f7e:	83 c4 1c             	add    $0x1c,%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    
  800f86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	89 f9                	mov    %edi,%ecx
  800f92:	b8 20 00 00 00       	mov    $0x20,%eax
  800f97:	29 f8                	sub    %edi,%eax
  800f99:	d3 e2                	shl    %cl,%edx
  800f9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f9f:	89 c1                	mov    %eax,%ecx
  800fa1:	89 da                	mov    %ebx,%edx
  800fa3:	d3 ea                	shr    %cl,%edx
  800fa5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fa9:	09 d1                	or     %edx,%ecx
  800fab:	89 f2                	mov    %esi,%edx
  800fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fb1:	89 f9                	mov    %edi,%ecx
  800fb3:	d3 e3                	shl    %cl,%ebx
  800fb5:	89 c1                	mov    %eax,%ecx
  800fb7:	d3 ea                	shr    %cl,%edx
  800fb9:	89 f9                	mov    %edi,%ecx
  800fbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fbf:	89 eb                	mov    %ebp,%ebx
  800fc1:	d3 e6                	shl    %cl,%esi
  800fc3:	89 c1                	mov    %eax,%ecx
  800fc5:	d3 eb                	shr    %cl,%ebx
  800fc7:	09 de                	or     %ebx,%esi
  800fc9:	89 f0                	mov    %esi,%eax
  800fcb:	f7 74 24 08          	divl   0x8(%esp)
  800fcf:	89 d6                	mov    %edx,%esi
  800fd1:	89 c3                	mov    %eax,%ebx
  800fd3:	f7 64 24 0c          	mull   0xc(%esp)
  800fd7:	39 d6                	cmp    %edx,%esi
  800fd9:	72 15                	jb     800ff0 <__udivdi3+0x100>
  800fdb:	89 f9                	mov    %edi,%ecx
  800fdd:	d3 e5                	shl    %cl,%ebp
  800fdf:	39 c5                	cmp    %eax,%ebp
  800fe1:	73 04                	jae    800fe7 <__udivdi3+0xf7>
  800fe3:	39 d6                	cmp    %edx,%esi
  800fe5:	74 09                	je     800ff0 <__udivdi3+0x100>
  800fe7:	89 d8                	mov    %ebx,%eax
  800fe9:	31 ff                	xor    %edi,%edi
  800feb:	e9 27 ff ff ff       	jmp    800f17 <__udivdi3+0x27>
  800ff0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ff3:	31 ff                	xor    %edi,%edi
  800ff5:	e9 1d ff ff ff       	jmp    800f17 <__udivdi3+0x27>
  800ffa:	66 90                	xchg   %ax,%ax
  800ffc:	66 90                	xchg   %ax,%ax
  800ffe:	66 90                	xchg   %ax,%ax

00801000 <__umoddi3>:
  801000:	55                   	push   %ebp
  801001:	57                   	push   %edi
  801002:	56                   	push   %esi
  801003:	53                   	push   %ebx
  801004:	83 ec 1c             	sub    $0x1c,%esp
  801007:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80100b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80100f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801013:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801017:	89 da                	mov    %ebx,%edx
  801019:	85 c0                	test   %eax,%eax
  80101b:	75 43                	jne    801060 <__umoddi3+0x60>
  80101d:	39 df                	cmp    %ebx,%edi
  80101f:	76 17                	jbe    801038 <__umoddi3+0x38>
  801021:	89 f0                	mov    %esi,%eax
  801023:	f7 f7                	div    %edi
  801025:	89 d0                	mov    %edx,%eax
  801027:	31 d2                	xor    %edx,%edx
  801029:	83 c4 1c             	add    $0x1c,%esp
  80102c:	5b                   	pop    %ebx
  80102d:	5e                   	pop    %esi
  80102e:	5f                   	pop    %edi
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    
  801031:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801038:	89 fd                	mov    %edi,%ebp
  80103a:	85 ff                	test   %edi,%edi
  80103c:	75 0b                	jne    801049 <__umoddi3+0x49>
  80103e:	b8 01 00 00 00       	mov    $0x1,%eax
  801043:	31 d2                	xor    %edx,%edx
  801045:	f7 f7                	div    %edi
  801047:	89 c5                	mov    %eax,%ebp
  801049:	89 d8                	mov    %ebx,%eax
  80104b:	31 d2                	xor    %edx,%edx
  80104d:	f7 f5                	div    %ebp
  80104f:	89 f0                	mov    %esi,%eax
  801051:	f7 f5                	div    %ebp
  801053:	89 d0                	mov    %edx,%eax
  801055:	eb d0                	jmp    801027 <__umoddi3+0x27>
  801057:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80105e:	66 90                	xchg   %ax,%ax
  801060:	89 f1                	mov    %esi,%ecx
  801062:	39 d8                	cmp    %ebx,%eax
  801064:	76 0a                	jbe    801070 <__umoddi3+0x70>
  801066:	89 f0                	mov    %esi,%eax
  801068:	83 c4 1c             	add    $0x1c,%esp
  80106b:	5b                   	pop    %ebx
  80106c:	5e                   	pop    %esi
  80106d:	5f                   	pop    %edi
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    
  801070:	0f bd e8             	bsr    %eax,%ebp
  801073:	83 f5 1f             	xor    $0x1f,%ebp
  801076:	75 20                	jne    801098 <__umoddi3+0x98>
  801078:	39 d8                	cmp    %ebx,%eax
  80107a:	0f 82 b0 00 00 00    	jb     801130 <__umoddi3+0x130>
  801080:	39 f7                	cmp    %esi,%edi
  801082:	0f 86 a8 00 00 00    	jbe    801130 <__umoddi3+0x130>
  801088:	89 c8                	mov    %ecx,%eax
  80108a:	83 c4 1c             	add    $0x1c,%esp
  80108d:	5b                   	pop    %ebx
  80108e:	5e                   	pop    %esi
  80108f:	5f                   	pop    %edi
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    
  801092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801098:	89 e9                	mov    %ebp,%ecx
  80109a:	ba 20 00 00 00       	mov    $0x20,%edx
  80109f:	29 ea                	sub    %ebp,%edx
  8010a1:	d3 e0                	shl    %cl,%eax
  8010a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a7:	89 d1                	mov    %edx,%ecx
  8010a9:	89 f8                	mov    %edi,%eax
  8010ab:	d3 e8                	shr    %cl,%eax
  8010ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010b5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010b9:	09 c1                	or     %eax,%ecx
  8010bb:	89 d8                	mov    %ebx,%eax
  8010bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010c1:	89 e9                	mov    %ebp,%ecx
  8010c3:	d3 e7                	shl    %cl,%edi
  8010c5:	89 d1                	mov    %edx,%ecx
  8010c7:	d3 e8                	shr    %cl,%eax
  8010c9:	89 e9                	mov    %ebp,%ecx
  8010cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010cf:	d3 e3                	shl    %cl,%ebx
  8010d1:	89 c7                	mov    %eax,%edi
  8010d3:	89 d1                	mov    %edx,%ecx
  8010d5:	89 f0                	mov    %esi,%eax
  8010d7:	d3 e8                	shr    %cl,%eax
  8010d9:	89 e9                	mov    %ebp,%ecx
  8010db:	89 fa                	mov    %edi,%edx
  8010dd:	d3 e6                	shl    %cl,%esi
  8010df:	09 d8                	or     %ebx,%eax
  8010e1:	f7 74 24 08          	divl   0x8(%esp)
  8010e5:	89 d1                	mov    %edx,%ecx
  8010e7:	89 f3                	mov    %esi,%ebx
  8010e9:	f7 64 24 0c          	mull   0xc(%esp)
  8010ed:	89 c6                	mov    %eax,%esi
  8010ef:	89 d7                	mov    %edx,%edi
  8010f1:	39 d1                	cmp    %edx,%ecx
  8010f3:	72 06                	jb     8010fb <__umoddi3+0xfb>
  8010f5:	75 10                	jne    801107 <__umoddi3+0x107>
  8010f7:	39 c3                	cmp    %eax,%ebx
  8010f9:	73 0c                	jae    801107 <__umoddi3+0x107>
  8010fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8010ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801103:	89 d7                	mov    %edx,%edi
  801105:	89 c6                	mov    %eax,%esi
  801107:	89 ca                	mov    %ecx,%edx
  801109:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80110e:	29 f3                	sub    %esi,%ebx
  801110:	19 fa                	sbb    %edi,%edx
  801112:	89 d0                	mov    %edx,%eax
  801114:	d3 e0                	shl    %cl,%eax
  801116:	89 e9                	mov    %ebp,%ecx
  801118:	d3 eb                	shr    %cl,%ebx
  80111a:	d3 ea                	shr    %cl,%edx
  80111c:	09 d8                	or     %ebx,%eax
  80111e:	83 c4 1c             	add    $0x1c,%esp
  801121:	5b                   	pop    %ebx
  801122:	5e                   	pop    %esi
  801123:	5f                   	pop    %edi
  801124:	5d                   	pop    %ebp
  801125:	c3                   	ret    
  801126:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80112d:	8d 76 00             	lea    0x0(%esi),%esi
  801130:	89 da                	mov    %ebx,%edx
  801132:	29 fe                	sub    %edi,%esi
  801134:	19 c2                	sbb    %eax,%edx
  801136:	89 f1                	mov    %esi,%ecx
  801138:	89 c8                	mov    %ecx,%eax
  80113a:	e9 4b ff ff ff       	jmp    80108a <__umoddi3+0x8a>
