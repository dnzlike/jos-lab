
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 58 03 80 00       	push   $0x800358
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	c1 e0 07             	shl    $0x7,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7f 08                	jg     800113 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 0a 12 80 00       	push   $0x80120a
  80011e:	6a 23                	push   $0x23
  800120:	68 27 12 80 00       	push   $0x801227
  800125:	e8 54 02 00 00       	call   80037e <_panic>

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	8b 55 08             	mov    0x8(%ebp),%edx
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	b8 04 00 00 00       	mov    $0x4,%eax
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7f 08                	jg     800194 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018f:	5b                   	pop    %ebx
  800190:	5e                   	pop    %esi
  800191:	5f                   	pop    %edi
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 0a 12 80 00       	push   $0x80120a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 27 12 80 00       	push   $0x801227
  8001a6:	e8 d3 01 00 00       	call   80037e <_panic>

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7f 08                	jg     8001d6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 0a 12 80 00       	push   $0x80120a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 27 12 80 00       	push   $0x801227
  8001e8:	e8 91 01 00 00       	call   80037e <_panic>

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	b8 06 00 00 00       	mov    $0x6,%eax
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7f 08                	jg     800218 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 0a 12 80 00       	push   $0x80120a
  800223:	6a 23                	push   $0x23
  800225:	68 27 12 80 00       	push   $0x801227
  80022a:	e8 4f 01 00 00       	call   80037e <_panic>

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	b8 08 00 00 00       	mov    $0x8,%eax
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7f 08                	jg     80025a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 0a 12 80 00       	push   $0x80120a
  800265:	6a 23                	push   $0x23
  800267:	68 27 12 80 00       	push   $0x801227
  80026c:	e8 0d 01 00 00       	call   80037e <_panic>

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	b8 09 00 00 00       	mov    $0x9,%eax
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7f 08                	jg     80029c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800297:	5b                   	pop    %ebx
  800298:	5e                   	pop    %esi
  800299:	5f                   	pop    %edi
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 0a 12 80 00       	push   $0x80120a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 27 12 80 00       	push   $0x801227
  8002ae:	e8 cb 00 00 00       	call   80037e <_panic>

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c4:	be 00 00 00 00       	mov    $0x0,%esi
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7f 08                	jg     800300 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800300:	83 ec 0c             	sub    $0xc,%esp
  800303:	50                   	push   %eax
  800304:	6a 0c                	push   $0xc
  800306:	68 0a 12 80 00       	push   $0x80120a
  80030b:	6a 23                	push   $0x23
  80030d:	68 27 12 80 00       	push   $0x801227
  800312:	e8 67 00 00 00       	call   80037e <_panic>

00800317 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	57                   	push   %edi
  80031b:	56                   	push   %esi
  80031c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80031d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800322:	8b 55 08             	mov    0x8(%ebp),%edx
  800325:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	89 df                	mov    %ebx,%edi
  80032f:	89 de                	mov    %ebx,%esi
  800331:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800333:	5b                   	pop    %ebx
  800334:	5e                   	pop    %esi
  800335:	5f                   	pop    %edi
  800336:	5d                   	pop    %ebp
  800337:	c3                   	ret    

00800338 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	57                   	push   %edi
  80033c:	56                   	push   %esi
  80033d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80033e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800343:	8b 55 08             	mov    0x8(%ebp),%edx
  800346:	b8 0e 00 00 00       	mov    $0xe,%eax
  80034b:	89 cb                	mov    %ecx,%ebx
  80034d:	89 cf                	mov    %ecx,%edi
  80034f:	89 ce                	mov    %ecx,%esi
  800351:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800353:	5b                   	pop    %ebx
  800354:	5e                   	pop    %esi
  800355:	5f                   	pop    %edi
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800358:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800359:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80035e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800360:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %ebp
  800363:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl 48(%esp), %ebx
  800367:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  80036b:	83 eb 04             	sub    $0x4,%ebx
	movl %ebp, (%ebx)
  80036e:	89 2b                	mov    %ebp,(%ebx)
	movl %ebx, 48(%esp)
  800370:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800374:	83 c4 08             	add    $0x8,%esp
	popal
  800377:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800378:	83 c4 04             	add    $0x4,%esp
	popfl
  80037b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80037c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80037d:	c3                   	ret    

0080037e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	56                   	push   %esi
  800382:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800383:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800386:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80038c:	e8 99 fd ff ff       	call   80012a <sys_getenvid>
  800391:	83 ec 0c             	sub    $0xc,%esp
  800394:	ff 75 0c             	pushl  0xc(%ebp)
  800397:	ff 75 08             	pushl  0x8(%ebp)
  80039a:	56                   	push   %esi
  80039b:	50                   	push   %eax
  80039c:	68 38 12 80 00       	push   $0x801238
  8003a1:	e8 b3 00 00 00       	call   800459 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003a6:	83 c4 18             	add    $0x18,%esp
  8003a9:	53                   	push   %ebx
  8003aa:	ff 75 10             	pushl  0x10(%ebp)
  8003ad:	e8 56 00 00 00       	call   800408 <vcprintf>
	cprintf("\n");
  8003b2:	c7 04 24 5b 12 80 00 	movl   $0x80125b,(%esp)
  8003b9:	e8 9b 00 00 00       	call   800459 <cprintf>
  8003be:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003c1:	cc                   	int3   
  8003c2:	eb fd                	jmp    8003c1 <_panic+0x43>

008003c4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	53                   	push   %ebx
  8003c8:	83 ec 04             	sub    $0x4,%esp
  8003cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003ce:	8b 13                	mov    (%ebx),%edx
  8003d0:	8d 42 01             	lea    0x1(%edx),%eax
  8003d3:	89 03                	mov    %eax,(%ebx)
  8003d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003dc:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003e1:	74 09                	je     8003ec <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003e3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ea:	c9                   	leave  
  8003eb:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	68 ff 00 00 00       	push   $0xff
  8003f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8003f7:	50                   	push   %eax
  8003f8:	e8 af fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800403:	83 c4 10             	add    $0x10,%esp
  800406:	eb db                	jmp    8003e3 <putch+0x1f>

00800408 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800411:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800418:	00 00 00 
	b.cnt = 0;
  80041b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800422:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800425:	ff 75 0c             	pushl  0xc(%ebp)
  800428:	ff 75 08             	pushl  0x8(%ebp)
  80042b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800431:	50                   	push   %eax
  800432:	68 c4 03 80 00       	push   $0x8003c4
  800437:	e8 fb 00 00 00       	call   800537 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80043c:	83 c4 08             	add    $0x8,%esp
  80043f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800445:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80044b:	50                   	push   %eax
  80044c:	e8 5b fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  800451:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800457:	c9                   	leave  
  800458:	c3                   	ret    

00800459 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800459:	55                   	push   %ebp
  80045a:	89 e5                	mov    %esp,%ebp
  80045c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80045f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800462:	50                   	push   %eax
  800463:	ff 75 08             	pushl  0x8(%ebp)
  800466:	e8 9d ff ff ff       	call   800408 <vcprintf>
	va_end(ap);

	return cnt;
}
  80046b:	c9                   	leave  
  80046c:	c3                   	ret    

0080046d <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	57                   	push   %edi
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 1c             	sub    $0x1c,%esp
  800476:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800479:	89 d3                	mov    %edx,%ebx
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800481:	8b 45 10             	mov    0x10(%ebp),%eax
  800484:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800487:	89 c2                	mov    %eax,%edx
  800489:	b9 00 00 00 00       	mov    $0x0,%ecx
  80048e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800491:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800494:	39 c6                	cmp    %eax,%esi
  800496:	89 f8                	mov    %edi,%eax
  800498:	19 c8                	sbb    %ecx,%eax
  80049a:	73 32                	jae    8004ce <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  80049c:	83 ec 08             	sub    $0x8,%esp
  80049f:	53                   	push   %ebx
  8004a0:	83 ec 04             	sub    $0x4,%esp
  8004a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a9:	57                   	push   %edi
  8004aa:	56                   	push   %esi
  8004ab:	e8 00 0c 00 00       	call   8010b0 <__umoddi3>
  8004b0:	83 c4 14             	add    $0x14,%esp
  8004b3:	0f be 80 5d 12 80 00 	movsbl 0x80125d(%eax),%eax
  8004ba:	50                   	push   %eax
  8004bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004be:	ff d0                	call   *%eax
	return remain - 1;
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	83 e8 01             	sub    $0x1,%eax
}
  8004c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c9:	5b                   	pop    %ebx
  8004ca:	5e                   	pop    %esi
  8004cb:	5f                   	pop    %edi
  8004cc:	5d                   	pop    %ebp
  8004cd:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  8004ce:	83 ec 0c             	sub    $0xc,%esp
  8004d1:	ff 75 18             	pushl  0x18(%ebp)
  8004d4:	ff 75 14             	pushl  0x14(%ebp)
  8004d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	51                   	push   %ecx
  8004de:	52                   	push   %edx
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	e8 ba 0a 00 00       	call   800fa0 <__udivdi3>
  8004e6:	83 c4 18             	add    $0x18,%esp
  8004e9:	52                   	push   %edx
  8004ea:	50                   	push   %eax
  8004eb:	89 da                	mov    %ebx,%edx
  8004ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004f0:	e8 78 ff ff ff       	call   80046d <printnum_helper>
  8004f5:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f8:	83 c4 20             	add    $0x20,%esp
  8004fb:	eb 9f                	jmp    80049c <printnum_helper+0x2f>

008004fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004fd:	55                   	push   %ebp
  8004fe:	89 e5                	mov    %esp,%ebp
  800500:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800503:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800507:	8b 10                	mov    (%eax),%edx
  800509:	3b 50 04             	cmp    0x4(%eax),%edx
  80050c:	73 0a                	jae    800518 <sprintputch+0x1b>
		*b->buf++ = ch;
  80050e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800511:	89 08                	mov    %ecx,(%eax)
  800513:	8b 45 08             	mov    0x8(%ebp),%eax
  800516:	88 02                	mov    %al,(%edx)
}
  800518:	5d                   	pop    %ebp
  800519:	c3                   	ret    

0080051a <printfmt>:
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800520:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800523:	50                   	push   %eax
  800524:	ff 75 10             	pushl  0x10(%ebp)
  800527:	ff 75 0c             	pushl  0xc(%ebp)
  80052a:	ff 75 08             	pushl  0x8(%ebp)
  80052d:	e8 05 00 00 00       	call   800537 <vprintfmt>
}
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <vprintfmt>:
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	57                   	push   %edi
  80053b:	56                   	push   %esi
  80053c:	53                   	push   %ebx
  80053d:	83 ec 3c             	sub    $0x3c,%esp
  800540:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800543:	8b 75 0c             	mov    0xc(%ebp),%esi
  800546:	8b 7d 10             	mov    0x10(%ebp),%edi
  800549:	e9 3f 05 00 00       	jmp    800a8d <vprintfmt+0x556>
		padc = ' ';
  80054e:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800552:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800559:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800560:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800567:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  80056e:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800575:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8d 47 01             	lea    0x1(%edi),%eax
  80057d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800580:	0f b6 17             	movzbl (%edi),%edx
  800583:	8d 42 dd             	lea    -0x23(%edx),%eax
  800586:	3c 55                	cmp    $0x55,%al
  800588:	0f 87 98 05 00 00    	ja     800b26 <vprintfmt+0x5ef>
  80058e:	0f b6 c0             	movzbl %al,%eax
  800591:	ff 24 85 a0 13 80 00 	jmp    *0x8013a0(,%eax,4)
  800598:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  80059b:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80059f:	eb d9                	jmp    80057a <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8005a1:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  8005a4:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  8005ab:	eb cd                	jmp    80057a <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  8005ad:	0f b6 d2             	movzbl %dl,%edx
  8005b0:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b8:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  8005bb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005be:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005c2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005c5:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005c8:	83 fb 09             	cmp    $0x9,%ebx
  8005cb:	77 5c                	ja     800629 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  8005cd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005d0:	eb e9                	jmp    8005bb <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  8005d2:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  8005d5:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  8005d9:	eb 9f                	jmp    80057a <vprintfmt+0x43>
			precision = va_arg(ap, int);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 40 04             	lea    0x4(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8005ef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f3:	79 85                	jns    80057a <vprintfmt+0x43>
				width = precision, precision = -1;
  8005f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800602:	e9 73 ff ff ff       	jmp    80057a <vprintfmt+0x43>
  800607:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060a:	85 c0                	test   %eax,%eax
  80060c:	0f 48 c1             	cmovs  %ecx,%eax
  80060f:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800612:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800615:	e9 60 ff ff ff       	jmp    80057a <vprintfmt+0x43>
  80061a:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  80061d:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800624:	e9 51 ff ff ff       	jmp    80057a <vprintfmt+0x43>
  800629:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80062c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80062f:	eb be                	jmp    8005ef <vprintfmt+0xb8>
			lflag++;
  800631:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800635:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  800638:	e9 3d ff ff ff       	jmp    80057a <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8d 78 04             	lea    0x4(%eax),%edi
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	56                   	push   %esi
  800647:	ff 30                	pushl  (%eax)
  800649:	ff d3                	call   *%ebx
			break;
  80064b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80064e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800651:	e9 34 04 00 00       	jmp    800a8a <vprintfmt+0x553>
			err = va_arg(ap, int);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8d 78 04             	lea    0x4(%eax),%edi
  80065c:	8b 00                	mov    (%eax),%eax
  80065e:	99                   	cltd   
  80065f:	31 d0                	xor    %edx,%eax
  800661:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800663:	83 f8 08             	cmp    $0x8,%eax
  800666:	7f 23                	jg     80068b <vprintfmt+0x154>
  800668:	8b 14 85 00 15 80 00 	mov    0x801500(,%eax,4),%edx
  80066f:	85 d2                	test   %edx,%edx
  800671:	74 18                	je     80068b <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800673:	52                   	push   %edx
  800674:	68 7e 12 80 00       	push   $0x80127e
  800679:	56                   	push   %esi
  80067a:	53                   	push   %ebx
  80067b:	e8 9a fe ff ff       	call   80051a <printfmt>
  800680:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800683:	89 7d 14             	mov    %edi,0x14(%ebp)
  800686:	e9 ff 03 00 00       	jmp    800a8a <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  80068b:	50                   	push   %eax
  80068c:	68 75 12 80 00       	push   $0x801275
  800691:	56                   	push   %esi
  800692:	53                   	push   %ebx
  800693:	e8 82 fe ff ff       	call   80051a <printfmt>
  800698:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80069b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80069e:	e9 e7 03 00 00       	jmp    800a8a <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	83 c0 04             	add    $0x4,%eax
  8006a9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8006b1:	85 c9                	test   %ecx,%ecx
  8006b3:	b8 6e 12 80 00       	mov    $0x80126e,%eax
  8006b8:	0f 45 c1             	cmovne %ecx,%eax
  8006bb:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  8006be:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c2:	7e 06                	jle    8006ca <vprintfmt+0x193>
  8006c4:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  8006c8:	75 0d                	jne    8006d7 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ca:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006cd:	89 c7                	mov    %eax,%edi
  8006cf:	03 45 d8             	add    -0x28(%ebp),%eax
  8006d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d5:	eb 53                	jmp    80072a <vprintfmt+0x1f3>
  8006d7:	83 ec 08             	sub    $0x8,%esp
  8006da:	ff 75 e0             	pushl  -0x20(%ebp)
  8006dd:	50                   	push   %eax
  8006de:	e8 eb 04 00 00       	call   800bce <strnlen>
  8006e3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006e6:	29 c1                	sub    %eax,%ecx
  8006e8:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006f0:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8006f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f7:	eb 0f                	jmp    800708 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	56                   	push   %esi
  8006fd:	ff 75 d8             	pushl  -0x28(%ebp)
  800700:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800702:	83 ef 01             	sub    $0x1,%edi
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	85 ff                	test   %edi,%edi
  80070a:	7f ed                	jg     8006f9 <vprintfmt+0x1c2>
  80070c:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  80070f:	85 c9                	test   %ecx,%ecx
  800711:	b8 00 00 00 00       	mov    $0x0,%eax
  800716:	0f 49 c1             	cmovns %ecx,%eax
  800719:	29 c1                	sub    %eax,%ecx
  80071b:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  80071e:	eb aa                	jmp    8006ca <vprintfmt+0x193>
					putch(ch, putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	56                   	push   %esi
  800724:	52                   	push   %edx
  800725:	ff d3                	call   *%ebx
  800727:	83 c4 10             	add    $0x10,%esp
  80072a:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80072d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80072f:	83 c7 01             	add    $0x1,%edi
  800732:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800736:	0f be d0             	movsbl %al,%edx
  800739:	85 d2                	test   %edx,%edx
  80073b:	74 2e                	je     80076b <vprintfmt+0x234>
  80073d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800741:	78 06                	js     800749 <vprintfmt+0x212>
  800743:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800747:	78 1e                	js     800767 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800749:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80074d:	74 d1                	je     800720 <vprintfmt+0x1e9>
  80074f:	0f be c0             	movsbl %al,%eax
  800752:	83 e8 20             	sub    $0x20,%eax
  800755:	83 f8 5e             	cmp    $0x5e,%eax
  800758:	76 c6                	jbe    800720 <vprintfmt+0x1e9>
					putch('?', putdat);
  80075a:	83 ec 08             	sub    $0x8,%esp
  80075d:	56                   	push   %esi
  80075e:	6a 3f                	push   $0x3f
  800760:	ff d3                	call   *%ebx
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	eb c3                	jmp    80072a <vprintfmt+0x1f3>
  800767:	89 cf                	mov    %ecx,%edi
  800769:	eb 02                	jmp    80076d <vprintfmt+0x236>
  80076b:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  80076d:	85 ff                	test   %edi,%edi
  80076f:	7e 10                	jle    800781 <vprintfmt+0x24a>
				putch(' ', putdat);
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	56                   	push   %esi
  800775:	6a 20                	push   $0x20
  800777:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800779:	83 ef 01             	sub    $0x1,%edi
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb ec                	jmp    80076d <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800781:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800784:	89 45 14             	mov    %eax,0x14(%ebp)
  800787:	e9 fe 02 00 00       	jmp    800a8a <vprintfmt+0x553>
	if (lflag >= 2)
  80078c:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800790:	7f 21                	jg     8007b3 <vprintfmt+0x27c>
	else if (lflag)
  800792:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800796:	74 79                	je     800811 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8b 00                	mov    (%eax),%eax
  80079d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007a0:	89 c1                	mov    %eax,%ecx
  8007a2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8d 40 04             	lea    0x4(%eax),%eax
  8007ae:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b1:	eb 17                	jmp    8007ca <vprintfmt+0x293>
		return va_arg(*ap, long long);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8b 50 04             	mov    0x4(%eax),%edx
  8007b9:	8b 00                	mov    (%eax),%eax
  8007bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c4:	8d 40 08             	lea    0x8(%eax),%eax
  8007c7:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  8007ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007d3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  8007d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007da:	78 50                	js     80082c <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  8007dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007df:	c1 fa 1f             	sar    $0x1f,%edx
  8007e2:	89 d0                	mov    %edx,%eax
  8007e4:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8007e7:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8007ea:	85 d2                	test   %edx,%edx
  8007ec:	0f 89 14 02 00 00    	jns    800a06 <vprintfmt+0x4cf>
  8007f2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007f6:	0f 84 0a 02 00 00    	je     800a06 <vprintfmt+0x4cf>
				putch('+', putdat);
  8007fc:	83 ec 08             	sub    $0x8,%esp
  8007ff:	56                   	push   %esi
  800800:	6a 2b                	push   $0x2b
  800802:	ff d3                	call   *%ebx
  800804:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800807:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080c:	e9 5c 01 00 00       	jmp    80096d <vprintfmt+0x436>
		return va_arg(*ap, int);
  800811:	8b 45 14             	mov    0x14(%ebp),%eax
  800814:	8b 00                	mov    (%eax),%eax
  800816:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800819:	89 c1                	mov    %eax,%ecx
  80081b:	c1 f9 1f             	sar    $0x1f,%ecx
  80081e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8d 40 04             	lea    0x4(%eax),%eax
  800827:	89 45 14             	mov    %eax,0x14(%ebp)
  80082a:	eb 9e                	jmp    8007ca <vprintfmt+0x293>
				putch('-', putdat);
  80082c:	83 ec 08             	sub    $0x8,%esp
  80082f:	56                   	push   %esi
  800830:	6a 2d                	push   $0x2d
  800832:	ff d3                	call   *%ebx
				num = -(long long) num;
  800834:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800837:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80083a:	f7 d8                	neg    %eax
  80083c:	83 d2 00             	adc    $0x0,%edx
  80083f:	f7 da                	neg    %edx
  800841:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800844:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800847:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80084a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80084f:	e9 19 01 00 00       	jmp    80096d <vprintfmt+0x436>
	if (lflag >= 2)
  800854:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800858:	7f 29                	jg     800883 <vprintfmt+0x34c>
	else if (lflag)
  80085a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80085e:	74 44                	je     8008a4 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800860:	8b 45 14             	mov    0x14(%ebp),%eax
  800863:	8b 00                	mov    (%eax),%eax
  800865:	ba 00 00 00 00       	mov    $0x0,%edx
  80086a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80086d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8d 40 04             	lea    0x4(%eax),%eax
  800876:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800879:	b8 0a 00 00 00       	mov    $0xa,%eax
  80087e:	e9 ea 00 00 00       	jmp    80096d <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800883:	8b 45 14             	mov    0x14(%ebp),%eax
  800886:	8b 50 04             	mov    0x4(%eax),%edx
  800889:	8b 00                	mov    (%eax),%eax
  80088b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80088e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800891:	8b 45 14             	mov    0x14(%ebp),%eax
  800894:	8d 40 08             	lea    0x8(%eax),%eax
  800897:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80089a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80089f:	e9 c9 00 00 00       	jmp    80096d <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8008a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a7:	8b 00                	mov    (%eax),%eax
  8008a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008b1:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	8d 40 04             	lea    0x4(%eax),%eax
  8008ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8008bd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008c2:	e9 a6 00 00 00       	jmp    80096d <vprintfmt+0x436>
			putch('0', putdat);
  8008c7:	83 ec 08             	sub    $0x8,%esp
  8008ca:	56                   	push   %esi
  8008cb:	6a 30                	push   $0x30
  8008cd:	ff d3                	call   *%ebx
	if (lflag >= 2)
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8008d6:	7f 26                	jg     8008fe <vprintfmt+0x3c7>
	else if (lflag)
  8008d8:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8008dc:	74 3e                	je     80091c <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  8008de:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e1:	8b 00                	mov    (%eax),%eax
  8008e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008eb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f1:	8d 40 04             	lea    0x4(%eax),%eax
  8008f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008f7:	b8 08 00 00 00       	mov    $0x8,%eax
  8008fc:	eb 6f                	jmp    80096d <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8008fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800901:	8b 50 04             	mov    0x4(%eax),%edx
  800904:	8b 00                	mov    (%eax),%eax
  800906:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800909:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80090c:	8b 45 14             	mov    0x14(%ebp),%eax
  80090f:	8d 40 08             	lea    0x8(%eax),%eax
  800912:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800915:	b8 08 00 00 00       	mov    $0x8,%eax
  80091a:	eb 51                	jmp    80096d <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80091c:	8b 45 14             	mov    0x14(%ebp),%eax
  80091f:	8b 00                	mov    (%eax),%eax
  800921:	ba 00 00 00 00       	mov    $0x0,%edx
  800926:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800929:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	8d 40 04             	lea    0x4(%eax),%eax
  800932:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800935:	b8 08 00 00 00       	mov    $0x8,%eax
  80093a:	eb 31                	jmp    80096d <vprintfmt+0x436>
			putch('0', putdat);
  80093c:	83 ec 08             	sub    $0x8,%esp
  80093f:	56                   	push   %esi
  800940:	6a 30                	push   $0x30
  800942:	ff d3                	call   *%ebx
			putch('x', putdat);
  800944:	83 c4 08             	add    $0x8,%esp
  800947:	56                   	push   %esi
  800948:	6a 78                	push   $0x78
  80094a:	ff d3                	call   *%ebx
			num = (unsigned long long)
  80094c:	8b 45 14             	mov    0x14(%ebp),%eax
  80094f:	8b 00                	mov    (%eax),%eax
  800951:	ba 00 00 00 00       	mov    $0x0,%edx
  800956:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800959:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  80095c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80095f:	8b 45 14             	mov    0x14(%ebp),%eax
  800962:	8d 40 04             	lea    0x4(%eax),%eax
  800965:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800968:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80096d:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800971:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800974:	89 c1                	mov    %eax,%ecx
  800976:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800979:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80097c:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800981:	89 c2                	mov    %eax,%edx
  800983:	39 c1                	cmp    %eax,%ecx
  800985:	0f 87 85 00 00 00    	ja     800a10 <vprintfmt+0x4d9>
		tmp /= base;
  80098b:	89 d0                	mov    %edx,%eax
  80098d:	ba 00 00 00 00       	mov    $0x0,%edx
  800992:	f7 f1                	div    %ecx
		len++;
  800994:	83 c7 01             	add    $0x1,%edi
  800997:	eb e8                	jmp    800981 <vprintfmt+0x44a>
	if (lflag >= 2)
  800999:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80099d:	7f 26                	jg     8009c5 <vprintfmt+0x48e>
	else if (lflag)
  80099f:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8009a3:	74 3e                	je     8009e3 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  8009a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a8:	8b 00                	mov    (%eax),%eax
  8009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009b2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b8:	8d 40 04             	lea    0x4(%eax),%eax
  8009bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009be:	b8 10 00 00 00       	mov    $0x10,%eax
  8009c3:	eb a8                	jmp    80096d <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8009c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c8:	8b 50 04             	mov    0x4(%eax),%edx
  8009cb:	8b 00                	mov    (%eax),%eax
  8009cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009d0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d6:	8d 40 08             	lea    0x8(%eax),%eax
  8009d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009dc:	b8 10 00 00 00       	mov    $0x10,%eax
  8009e1:	eb 8a                	jmp    80096d <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8009e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e6:	8b 00                	mov    (%eax),%eax
  8009e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009f6:	8d 40 04             	lea    0x4(%eax),%eax
  8009f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009fc:	b8 10 00 00 00       	mov    $0x10,%eax
  800a01:	e9 67 ff ff ff       	jmp    80096d <vprintfmt+0x436>
			base = 10;
  800a06:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a0b:	e9 5d ff ff ff       	jmp    80096d <vprintfmt+0x436>
  800a10:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  800a13:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800a16:	29 f8                	sub    %edi,%eax
  800a18:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  800a1a:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  800a1e:	74 15                	je     800a35 <vprintfmt+0x4fe>
		while (width > 0) {
  800a20:	85 ff                	test   %edi,%edi
  800a22:	7e 48                	jle    800a6c <vprintfmt+0x535>
			putch(padc, putdat);
  800a24:	83 ec 08             	sub    $0x8,%esp
  800a27:	56                   	push   %esi
  800a28:	ff 75 e0             	pushl  -0x20(%ebp)
  800a2b:	ff d3                	call   *%ebx
			width--;
  800a2d:	83 ef 01             	sub    $0x1,%edi
  800a30:	83 c4 10             	add    $0x10,%esp
  800a33:	eb eb                	jmp    800a20 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a35:	83 ec 0c             	sub    $0xc,%esp
  800a38:	6a 2d                	push   $0x2d
  800a3a:	ff 75 cc             	pushl  -0x34(%ebp)
  800a3d:	ff 75 c8             	pushl  -0x38(%ebp)
  800a40:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a43:	ff 75 d0             	pushl  -0x30(%ebp)
  800a46:	89 f2                	mov    %esi,%edx
  800a48:	89 d8                	mov    %ebx,%eax
  800a4a:	e8 1e fa ff ff       	call   80046d <printnum_helper>
		width -= len;
  800a4f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a52:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800a55:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800a58:	85 ff                	test   %edi,%edi
  800a5a:	7e 2e                	jle    800a8a <vprintfmt+0x553>
			putch(padc, putdat);
  800a5c:	83 ec 08             	sub    $0x8,%esp
  800a5f:	56                   	push   %esi
  800a60:	6a 20                	push   $0x20
  800a62:	ff d3                	call   *%ebx
			width--;
  800a64:	83 ef 01             	sub    $0x1,%edi
  800a67:	83 c4 10             	add    $0x10,%esp
  800a6a:	eb ec                	jmp    800a58 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a6c:	83 ec 0c             	sub    $0xc,%esp
  800a6f:	ff 75 e0             	pushl  -0x20(%ebp)
  800a72:	ff 75 cc             	pushl  -0x34(%ebp)
  800a75:	ff 75 c8             	pushl  -0x38(%ebp)
  800a78:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a7b:	ff 75 d0             	pushl  -0x30(%ebp)
  800a7e:	89 f2                	mov    %esi,%edx
  800a80:	89 d8                	mov    %ebx,%eax
  800a82:	e8 e6 f9 ff ff       	call   80046d <printnum_helper>
  800a87:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800a8a:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a8d:	83 c7 01             	add    $0x1,%edi
  800a90:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a94:	83 f8 25             	cmp    $0x25,%eax
  800a97:	0f 84 b1 fa ff ff    	je     80054e <vprintfmt+0x17>
			if (ch == '\0')
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	0f 84 a1 00 00 00    	je     800b46 <vprintfmt+0x60f>
			putch(ch, putdat);
  800aa5:	83 ec 08             	sub    $0x8,%esp
  800aa8:	56                   	push   %esi
  800aa9:	50                   	push   %eax
  800aaa:	ff d3                	call   *%ebx
  800aac:	83 c4 10             	add    $0x10,%esp
  800aaf:	eb dc                	jmp    800a8d <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800ab1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab4:	83 c0 04             	add    $0x4,%eax
  800ab7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800aba:	8b 45 14             	mov    0x14(%ebp),%eax
  800abd:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800abf:	85 ff                	test   %edi,%edi
  800ac1:	74 15                	je     800ad8 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800ac3:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800ac9:	7f 29                	jg     800af4 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800acb:	0f b6 06             	movzbl (%esi),%eax
  800ace:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800ad0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ad3:	89 45 14             	mov    %eax,0x14(%ebp)
  800ad6:	eb b2                	jmp    800a8a <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800ad8:	68 14 13 80 00       	push   $0x801314
  800add:	68 7e 12 80 00       	push   $0x80127e
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
  800ae4:	e8 31 fa ff ff       	call   80051a <printfmt>
  800ae9:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800aec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800aef:	89 45 14             	mov    %eax,0x14(%ebp)
  800af2:	eb 96                	jmp    800a8a <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800af4:	68 4c 13 80 00       	push   $0x80134c
  800af9:	68 7e 12 80 00       	push   $0x80127e
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	e8 15 fa ff ff       	call   80051a <printfmt>
				*res = -1;
  800b05:	c6 07 ff             	movb   $0xff,(%edi)
  800b08:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800b0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b0e:	89 45 14             	mov    %eax,0x14(%ebp)
  800b11:	e9 74 ff ff ff       	jmp    800a8a <vprintfmt+0x553>
			putch(ch, putdat);
  800b16:	83 ec 08             	sub    $0x8,%esp
  800b19:	56                   	push   %esi
  800b1a:	6a 25                	push   $0x25
  800b1c:	ff d3                	call   *%ebx
			break;
  800b1e:	83 c4 10             	add    $0x10,%esp
  800b21:	e9 64 ff ff ff       	jmp    800a8a <vprintfmt+0x553>
			putch('%', putdat);
  800b26:	83 ec 08             	sub    $0x8,%esp
  800b29:	56                   	push   %esi
  800b2a:	6a 25                	push   $0x25
  800b2c:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b2e:	83 c4 10             	add    $0x10,%esp
  800b31:	89 f8                	mov    %edi,%eax
  800b33:	eb 03                	jmp    800b38 <vprintfmt+0x601>
  800b35:	83 e8 01             	sub    $0x1,%eax
  800b38:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800b3c:	75 f7                	jne    800b35 <vprintfmt+0x5fe>
  800b3e:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b41:	e9 44 ff ff ff       	jmp    800a8a <vprintfmt+0x553>
}
  800b46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	83 ec 18             	sub    $0x18,%esp
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b5d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b61:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b64:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b6b:	85 c0                	test   %eax,%eax
  800b6d:	74 26                	je     800b95 <vsnprintf+0x47>
  800b6f:	85 d2                	test   %edx,%edx
  800b71:	7e 22                	jle    800b95 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b73:	ff 75 14             	pushl  0x14(%ebp)
  800b76:	ff 75 10             	pushl  0x10(%ebp)
  800b79:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b7c:	50                   	push   %eax
  800b7d:	68 fd 04 80 00       	push   $0x8004fd
  800b82:	e8 b0 f9 ff ff       	call   800537 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b87:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b8a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b90:	83 c4 10             	add    $0x10,%esp
}
  800b93:	c9                   	leave  
  800b94:	c3                   	ret    
		return -E_INVAL;
  800b95:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b9a:	eb f7                	jmp    800b93 <vsnprintf+0x45>

00800b9c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ba2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ba5:	50                   	push   %eax
  800ba6:	ff 75 10             	pushl  0x10(%ebp)
  800ba9:	ff 75 0c             	pushl  0xc(%ebp)
  800bac:	ff 75 08             	pushl  0x8(%ebp)
  800baf:	e8 9a ff ff ff       	call   800b4e <vsnprintf>
	va_end(ap);

	return rc;
}
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    

00800bb6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bc5:	74 05                	je     800bcc <strlen+0x16>
		n++;
  800bc7:	83 c0 01             	add    $0x1,%eax
  800bca:	eb f5                	jmp    800bc1 <strlen+0xb>
	return n;
}
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	39 c2                	cmp    %eax,%edx
  800bde:	74 0d                	je     800bed <strnlen+0x1f>
  800be0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800be4:	74 05                	je     800beb <strnlen+0x1d>
		n++;
  800be6:	83 c2 01             	add    $0x1,%edx
  800be9:	eb f1                	jmp    800bdc <strnlen+0xe>
  800beb:	89 d0                	mov    %edx,%eax
	return n;
}
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	53                   	push   %ebx
  800bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bf9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfe:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c02:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c05:	83 c2 01             	add    $0x1,%edx
  800c08:	84 c9                	test   %cl,%cl
  800c0a:	75 f2                	jne    800bfe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c0c:	5b                   	pop    %ebx
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	53                   	push   %ebx
  800c13:	83 ec 10             	sub    $0x10,%esp
  800c16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c19:	53                   	push   %ebx
  800c1a:	e8 97 ff ff ff       	call   800bb6 <strlen>
  800c1f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800c22:	ff 75 0c             	pushl  0xc(%ebp)
  800c25:	01 d8                	add    %ebx,%eax
  800c27:	50                   	push   %eax
  800c28:	e8 c2 ff ff ff       	call   800bef <strcpy>
	return dst;
}
  800c2d:	89 d8                	mov    %ebx,%eax
  800c2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c32:	c9                   	leave  
  800c33:	c3                   	ret    

00800c34 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3f:	89 c6                	mov    %eax,%esi
  800c41:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c44:	89 c2                	mov    %eax,%edx
  800c46:	39 f2                	cmp    %esi,%edx
  800c48:	74 11                	je     800c5b <strncpy+0x27>
		*dst++ = *src;
  800c4a:	83 c2 01             	add    $0x1,%edx
  800c4d:	0f b6 19             	movzbl (%ecx),%ebx
  800c50:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c53:	80 fb 01             	cmp    $0x1,%bl
  800c56:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800c59:	eb eb                	jmp    800c46 <strncpy+0x12>
	}
	return ret;
}
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	56                   	push   %esi
  800c63:	53                   	push   %ebx
  800c64:	8b 75 08             	mov    0x8(%ebp),%esi
  800c67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6a:	8b 55 10             	mov    0x10(%ebp),%edx
  800c6d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c6f:	85 d2                	test   %edx,%edx
  800c71:	74 21                	je     800c94 <strlcpy+0x35>
  800c73:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c77:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800c79:	39 c2                	cmp    %eax,%edx
  800c7b:	74 14                	je     800c91 <strlcpy+0x32>
  800c7d:	0f b6 19             	movzbl (%ecx),%ebx
  800c80:	84 db                	test   %bl,%bl
  800c82:	74 0b                	je     800c8f <strlcpy+0x30>
			*dst++ = *src++;
  800c84:	83 c1 01             	add    $0x1,%ecx
  800c87:	83 c2 01             	add    $0x1,%edx
  800c8a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c8d:	eb ea                	jmp    800c79 <strlcpy+0x1a>
  800c8f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c91:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c94:	29 f0                	sub    %esi,%eax
}
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ca3:	0f b6 01             	movzbl (%ecx),%eax
  800ca6:	84 c0                	test   %al,%al
  800ca8:	74 0c                	je     800cb6 <strcmp+0x1c>
  800caa:	3a 02                	cmp    (%edx),%al
  800cac:	75 08                	jne    800cb6 <strcmp+0x1c>
		p++, q++;
  800cae:	83 c1 01             	add    $0x1,%ecx
  800cb1:	83 c2 01             	add    $0x1,%edx
  800cb4:	eb ed                	jmp    800ca3 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb6:	0f b6 c0             	movzbl %al,%eax
  800cb9:	0f b6 12             	movzbl (%edx),%edx
  800cbc:	29 d0                	sub    %edx,%eax
}
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	53                   	push   %ebx
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cca:	89 c3                	mov    %eax,%ebx
  800ccc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ccf:	eb 06                	jmp    800cd7 <strncmp+0x17>
		n--, p++, q++;
  800cd1:	83 c0 01             	add    $0x1,%eax
  800cd4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800cd7:	39 d8                	cmp    %ebx,%eax
  800cd9:	74 16                	je     800cf1 <strncmp+0x31>
  800cdb:	0f b6 08             	movzbl (%eax),%ecx
  800cde:	84 c9                	test   %cl,%cl
  800ce0:	74 04                	je     800ce6 <strncmp+0x26>
  800ce2:	3a 0a                	cmp    (%edx),%cl
  800ce4:	74 eb                	je     800cd1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ce6:	0f b6 00             	movzbl (%eax),%eax
  800ce9:	0f b6 12             	movzbl (%edx),%edx
  800cec:	29 d0                	sub    %edx,%eax
}
  800cee:	5b                   	pop    %ebx
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    
		return 0;
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf6:	eb f6                	jmp    800cee <strncmp+0x2e>

00800cf8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d02:	0f b6 10             	movzbl (%eax),%edx
  800d05:	84 d2                	test   %dl,%dl
  800d07:	74 09                	je     800d12 <strchr+0x1a>
		if (*s == c)
  800d09:	38 ca                	cmp    %cl,%dl
  800d0b:	74 0a                	je     800d17 <strchr+0x1f>
	for (; *s; s++)
  800d0d:	83 c0 01             	add    $0x1,%eax
  800d10:	eb f0                	jmp    800d02 <strchr+0xa>
			return (char *) s;
	return 0;
  800d12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    

00800d19 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d23:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d26:	38 ca                	cmp    %cl,%dl
  800d28:	74 09                	je     800d33 <strfind+0x1a>
  800d2a:	84 d2                	test   %dl,%dl
  800d2c:	74 05                	je     800d33 <strfind+0x1a>
	for (; *s; s++)
  800d2e:	83 c0 01             	add    $0x1,%eax
  800d31:	eb f0                	jmp    800d23 <strfind+0xa>
			break;
	return (char *) s;
}
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	57                   	push   %edi
  800d39:	56                   	push   %esi
  800d3a:	53                   	push   %ebx
  800d3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d41:	85 c9                	test   %ecx,%ecx
  800d43:	74 31                	je     800d76 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d45:	89 f8                	mov    %edi,%eax
  800d47:	09 c8                	or     %ecx,%eax
  800d49:	a8 03                	test   $0x3,%al
  800d4b:	75 23                	jne    800d70 <memset+0x3b>
		c &= 0xFF;
  800d4d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d51:	89 d3                	mov    %edx,%ebx
  800d53:	c1 e3 08             	shl    $0x8,%ebx
  800d56:	89 d0                	mov    %edx,%eax
  800d58:	c1 e0 18             	shl    $0x18,%eax
  800d5b:	89 d6                	mov    %edx,%esi
  800d5d:	c1 e6 10             	shl    $0x10,%esi
  800d60:	09 f0                	or     %esi,%eax
  800d62:	09 c2                	or     %eax,%edx
  800d64:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d66:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d69:	89 d0                	mov    %edx,%eax
  800d6b:	fc                   	cld    
  800d6c:	f3 ab                	rep stos %eax,%es:(%edi)
  800d6e:	eb 06                	jmp    800d76 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d73:	fc                   	cld    
  800d74:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d76:	89 f8                	mov    %edi,%eax
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	8b 45 08             	mov    0x8(%ebp),%eax
  800d85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d88:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d8b:	39 c6                	cmp    %eax,%esi
  800d8d:	73 32                	jae    800dc1 <memmove+0x44>
  800d8f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d92:	39 c2                	cmp    %eax,%edx
  800d94:	76 2b                	jbe    800dc1 <memmove+0x44>
		s += n;
		d += n;
  800d96:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d99:	89 fe                	mov    %edi,%esi
  800d9b:	09 ce                	or     %ecx,%esi
  800d9d:	09 d6                	or     %edx,%esi
  800d9f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800da5:	75 0e                	jne    800db5 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800da7:	83 ef 04             	sub    $0x4,%edi
  800daa:	8d 72 fc             	lea    -0x4(%edx),%esi
  800dad:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800db0:	fd                   	std    
  800db1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800db3:	eb 09                	jmp    800dbe <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800db5:	83 ef 01             	sub    $0x1,%edi
  800db8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800dbb:	fd                   	std    
  800dbc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800dbe:	fc                   	cld    
  800dbf:	eb 1a                	jmp    800ddb <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dc1:	89 c2                	mov    %eax,%edx
  800dc3:	09 ca                	or     %ecx,%edx
  800dc5:	09 f2                	or     %esi,%edx
  800dc7:	f6 c2 03             	test   $0x3,%dl
  800dca:	75 0a                	jne    800dd6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800dcc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800dcf:	89 c7                	mov    %eax,%edi
  800dd1:	fc                   	cld    
  800dd2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dd4:	eb 05                	jmp    800ddb <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800dd6:	89 c7                	mov    %eax,%edi
  800dd8:	fc                   	cld    
  800dd9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800de5:	ff 75 10             	pushl  0x10(%ebp)
  800de8:	ff 75 0c             	pushl  0xc(%ebp)
  800deb:	ff 75 08             	pushl  0x8(%ebp)
  800dee:	e8 8a ff ff ff       	call   800d7d <memmove>
}
  800df3:	c9                   	leave  
  800df4:	c3                   	ret    

00800df5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
  800dfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e00:	89 c6                	mov    %eax,%esi
  800e02:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e05:	39 f0                	cmp    %esi,%eax
  800e07:	74 1c                	je     800e25 <memcmp+0x30>
		if (*s1 != *s2)
  800e09:	0f b6 08             	movzbl (%eax),%ecx
  800e0c:	0f b6 1a             	movzbl (%edx),%ebx
  800e0f:	38 d9                	cmp    %bl,%cl
  800e11:	75 08                	jne    800e1b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800e13:	83 c0 01             	add    $0x1,%eax
  800e16:	83 c2 01             	add    $0x1,%edx
  800e19:	eb ea                	jmp    800e05 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800e1b:	0f b6 c1             	movzbl %cl,%eax
  800e1e:	0f b6 db             	movzbl %bl,%ebx
  800e21:	29 d8                	sub    %ebx,%eax
  800e23:	eb 05                	jmp    800e2a <memcmp+0x35>
	}

	return 0;
  800e25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e2a:	5b                   	pop    %ebx
  800e2b:	5e                   	pop    %esi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e37:	89 c2                	mov    %eax,%edx
  800e39:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e3c:	39 d0                	cmp    %edx,%eax
  800e3e:	73 09                	jae    800e49 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e40:	38 08                	cmp    %cl,(%eax)
  800e42:	74 05                	je     800e49 <memfind+0x1b>
	for (; s < ends; s++)
  800e44:	83 c0 01             	add    $0x1,%eax
  800e47:	eb f3                	jmp    800e3c <memfind+0xe>
			break;
	return (void *) s;
}
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e4b:	55                   	push   %ebp
  800e4c:	89 e5                	mov    %esp,%ebp
  800e4e:	57                   	push   %edi
  800e4f:	56                   	push   %esi
  800e50:	53                   	push   %ebx
  800e51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e57:	eb 03                	jmp    800e5c <strtol+0x11>
		s++;
  800e59:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e5c:	0f b6 01             	movzbl (%ecx),%eax
  800e5f:	3c 20                	cmp    $0x20,%al
  800e61:	74 f6                	je     800e59 <strtol+0xe>
  800e63:	3c 09                	cmp    $0x9,%al
  800e65:	74 f2                	je     800e59 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e67:	3c 2b                	cmp    $0x2b,%al
  800e69:	74 2a                	je     800e95 <strtol+0x4a>
	int neg = 0;
  800e6b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e70:	3c 2d                	cmp    $0x2d,%al
  800e72:	74 2b                	je     800e9f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e74:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e7a:	75 0f                	jne    800e8b <strtol+0x40>
  800e7c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e7f:	74 28                	je     800ea9 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e81:	85 db                	test   %ebx,%ebx
  800e83:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e88:	0f 44 d8             	cmove  %eax,%ebx
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e90:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e93:	eb 50                	jmp    800ee5 <strtol+0x9a>
		s++;
  800e95:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e98:	bf 00 00 00 00       	mov    $0x0,%edi
  800e9d:	eb d5                	jmp    800e74 <strtol+0x29>
		s++, neg = 1;
  800e9f:	83 c1 01             	add    $0x1,%ecx
  800ea2:	bf 01 00 00 00       	mov    $0x1,%edi
  800ea7:	eb cb                	jmp    800e74 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ea9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ead:	74 0e                	je     800ebd <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800eaf:	85 db                	test   %ebx,%ebx
  800eb1:	75 d8                	jne    800e8b <strtol+0x40>
		s++, base = 8;
  800eb3:	83 c1 01             	add    $0x1,%ecx
  800eb6:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ebb:	eb ce                	jmp    800e8b <strtol+0x40>
		s += 2, base = 16;
  800ebd:	83 c1 02             	add    $0x2,%ecx
  800ec0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ec5:	eb c4                	jmp    800e8b <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ec7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800eca:	89 f3                	mov    %esi,%ebx
  800ecc:	80 fb 19             	cmp    $0x19,%bl
  800ecf:	77 29                	ja     800efa <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ed1:	0f be d2             	movsbl %dl,%edx
  800ed4:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ed7:	3b 55 10             	cmp    0x10(%ebp),%edx
  800eda:	7d 30                	jge    800f0c <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800edc:	83 c1 01             	add    $0x1,%ecx
  800edf:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ee3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ee5:	0f b6 11             	movzbl (%ecx),%edx
  800ee8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800eeb:	89 f3                	mov    %esi,%ebx
  800eed:	80 fb 09             	cmp    $0x9,%bl
  800ef0:	77 d5                	ja     800ec7 <strtol+0x7c>
			dig = *s - '0';
  800ef2:	0f be d2             	movsbl %dl,%edx
  800ef5:	83 ea 30             	sub    $0x30,%edx
  800ef8:	eb dd                	jmp    800ed7 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800efa:	8d 72 bf             	lea    -0x41(%edx),%esi
  800efd:	89 f3                	mov    %esi,%ebx
  800eff:	80 fb 19             	cmp    $0x19,%bl
  800f02:	77 08                	ja     800f0c <strtol+0xc1>
			dig = *s - 'A' + 10;
  800f04:	0f be d2             	movsbl %dl,%edx
  800f07:	83 ea 37             	sub    $0x37,%edx
  800f0a:	eb cb                	jmp    800ed7 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800f0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f10:	74 05                	je     800f17 <strtol+0xcc>
		*endptr = (char *) s;
  800f12:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f15:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800f17:	89 c2                	mov    %eax,%edx
  800f19:	f7 da                	neg    %edx
  800f1b:	85 ff                	test   %edi,%edi
  800f1d:	0f 45 c2             	cmovne %edx,%eax
}
  800f20:	5b                   	pop    %ebx
  800f21:	5e                   	pop    %esi
  800f22:	5f                   	pop    %edi
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    

00800f25 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800f25:	55                   	push   %ebp
  800f26:	89 e5                	mov    %esp,%ebp
  800f28:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800f2b:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800f32:	74 0a                	je     800f3e <set_pgfault_handler+0x19>
		if ((r = sys_env_set_pgfault_upcall((envid_t)0, _pgfault_upcall)) < 0)
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800f34:	8b 45 08             	mov    0x8(%ebp),%eax
  800f37:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800f3c:	c9                   	leave  
  800f3d:	c3                   	ret    
		if ((r = sys_page_alloc((envid_t)0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W)) < 0) 
  800f3e:	83 ec 04             	sub    $0x4,%esp
  800f41:	6a 07                	push   $0x7
  800f43:	68 00 f0 bf ee       	push   $0xeebff000
  800f48:	6a 00                	push   $0x0
  800f4a:	e8 19 f2 ff ff       	call   800168 <sys_page_alloc>
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	78 2a                	js     800f80 <set_pgfault_handler+0x5b>
		if ((r = sys_env_set_pgfault_upcall((envid_t)0, _pgfault_upcall)) < 0)
  800f56:	83 ec 08             	sub    $0x8,%esp
  800f59:	68 58 03 80 00       	push   $0x800358
  800f5e:	6a 00                	push   $0x0
  800f60:	e8 0c f3 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
  800f65:	83 c4 10             	add    $0x10,%esp
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	79 c8                	jns    800f34 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail");
  800f6c:	83 ec 04             	sub    $0x4,%esp
  800f6f:	68 50 15 80 00       	push   $0x801550
  800f74:	6a 23                	push   $0x23
  800f76:	68 88 15 80 00       	push   $0x801588
  800f7b:	e8 fe f3 ff ff       	call   80037e <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail");
  800f80:	83 ec 04             	sub    $0x4,%esp
  800f83:	68 24 15 80 00       	push   $0x801524
  800f88:	6a 21                	push   $0x21
  800f8a:	68 88 15 80 00       	push   $0x801588
  800f8f:	e8 ea f3 ff ff       	call   80037e <_panic>
  800f94:	66 90                	xchg   %ax,%ax
  800f96:	66 90                	xchg   %ax,%ax
  800f98:	66 90                	xchg   %ax,%ax
  800f9a:	66 90                	xchg   %ax,%ax
  800f9c:	66 90                	xchg   %ax,%ax
  800f9e:	66 90                	xchg   %ax,%ax

00800fa0 <__udivdi3>:
  800fa0:	55                   	push   %ebp
  800fa1:	57                   	push   %edi
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
  800fa4:	83 ec 1c             	sub    $0x1c,%esp
  800fa7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800fab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800faf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fb3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800fb7:	85 d2                	test   %edx,%edx
  800fb9:	75 4d                	jne    801008 <__udivdi3+0x68>
  800fbb:	39 f3                	cmp    %esi,%ebx
  800fbd:	76 19                	jbe    800fd8 <__udivdi3+0x38>
  800fbf:	31 ff                	xor    %edi,%edi
  800fc1:	89 e8                	mov    %ebp,%eax
  800fc3:	89 f2                	mov    %esi,%edx
  800fc5:	f7 f3                	div    %ebx
  800fc7:	89 fa                	mov    %edi,%edx
  800fc9:	83 c4 1c             	add    $0x1c,%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5f                   	pop    %edi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    
  800fd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fd8:	89 d9                	mov    %ebx,%ecx
  800fda:	85 db                	test   %ebx,%ebx
  800fdc:	75 0b                	jne    800fe9 <__udivdi3+0x49>
  800fde:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe3:	31 d2                	xor    %edx,%edx
  800fe5:	f7 f3                	div    %ebx
  800fe7:	89 c1                	mov    %eax,%ecx
  800fe9:	31 d2                	xor    %edx,%edx
  800feb:	89 f0                	mov    %esi,%eax
  800fed:	f7 f1                	div    %ecx
  800fef:	89 c6                	mov    %eax,%esi
  800ff1:	89 e8                	mov    %ebp,%eax
  800ff3:	89 f7                	mov    %esi,%edi
  800ff5:	f7 f1                	div    %ecx
  800ff7:	89 fa                	mov    %edi,%edx
  800ff9:	83 c4 1c             	add    $0x1c,%esp
  800ffc:	5b                   	pop    %ebx
  800ffd:	5e                   	pop    %esi
  800ffe:	5f                   	pop    %edi
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    
  801001:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801008:	39 f2                	cmp    %esi,%edx
  80100a:	77 1c                	ja     801028 <__udivdi3+0x88>
  80100c:	0f bd fa             	bsr    %edx,%edi
  80100f:	83 f7 1f             	xor    $0x1f,%edi
  801012:	75 2c                	jne    801040 <__udivdi3+0xa0>
  801014:	39 f2                	cmp    %esi,%edx
  801016:	72 06                	jb     80101e <__udivdi3+0x7e>
  801018:	31 c0                	xor    %eax,%eax
  80101a:	39 eb                	cmp    %ebp,%ebx
  80101c:	77 a9                	ja     800fc7 <__udivdi3+0x27>
  80101e:	b8 01 00 00 00       	mov    $0x1,%eax
  801023:	eb a2                	jmp    800fc7 <__udivdi3+0x27>
  801025:	8d 76 00             	lea    0x0(%esi),%esi
  801028:	31 ff                	xor    %edi,%edi
  80102a:	31 c0                	xor    %eax,%eax
  80102c:	89 fa                	mov    %edi,%edx
  80102e:	83 c4 1c             	add    $0x1c,%esp
  801031:	5b                   	pop    %ebx
  801032:	5e                   	pop    %esi
  801033:	5f                   	pop    %edi
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    
  801036:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80103d:	8d 76 00             	lea    0x0(%esi),%esi
  801040:	89 f9                	mov    %edi,%ecx
  801042:	b8 20 00 00 00       	mov    $0x20,%eax
  801047:	29 f8                	sub    %edi,%eax
  801049:	d3 e2                	shl    %cl,%edx
  80104b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80104f:	89 c1                	mov    %eax,%ecx
  801051:	89 da                	mov    %ebx,%edx
  801053:	d3 ea                	shr    %cl,%edx
  801055:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801059:	09 d1                	or     %edx,%ecx
  80105b:	89 f2                	mov    %esi,%edx
  80105d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801061:	89 f9                	mov    %edi,%ecx
  801063:	d3 e3                	shl    %cl,%ebx
  801065:	89 c1                	mov    %eax,%ecx
  801067:	d3 ea                	shr    %cl,%edx
  801069:	89 f9                	mov    %edi,%ecx
  80106b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80106f:	89 eb                	mov    %ebp,%ebx
  801071:	d3 e6                	shl    %cl,%esi
  801073:	89 c1                	mov    %eax,%ecx
  801075:	d3 eb                	shr    %cl,%ebx
  801077:	09 de                	or     %ebx,%esi
  801079:	89 f0                	mov    %esi,%eax
  80107b:	f7 74 24 08          	divl   0x8(%esp)
  80107f:	89 d6                	mov    %edx,%esi
  801081:	89 c3                	mov    %eax,%ebx
  801083:	f7 64 24 0c          	mull   0xc(%esp)
  801087:	39 d6                	cmp    %edx,%esi
  801089:	72 15                	jb     8010a0 <__udivdi3+0x100>
  80108b:	89 f9                	mov    %edi,%ecx
  80108d:	d3 e5                	shl    %cl,%ebp
  80108f:	39 c5                	cmp    %eax,%ebp
  801091:	73 04                	jae    801097 <__udivdi3+0xf7>
  801093:	39 d6                	cmp    %edx,%esi
  801095:	74 09                	je     8010a0 <__udivdi3+0x100>
  801097:	89 d8                	mov    %ebx,%eax
  801099:	31 ff                	xor    %edi,%edi
  80109b:	e9 27 ff ff ff       	jmp    800fc7 <__udivdi3+0x27>
  8010a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8010a3:	31 ff                	xor    %edi,%edi
  8010a5:	e9 1d ff ff ff       	jmp    800fc7 <__udivdi3+0x27>
  8010aa:	66 90                	xchg   %ax,%ax
  8010ac:	66 90                	xchg   %ax,%ax
  8010ae:	66 90                	xchg   %ax,%ax

008010b0 <__umoddi3>:
  8010b0:	55                   	push   %ebp
  8010b1:	57                   	push   %edi
  8010b2:	56                   	push   %esi
  8010b3:	53                   	push   %ebx
  8010b4:	83 ec 1c             	sub    $0x1c,%esp
  8010b7:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8010bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8010bf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8010c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8010c7:	89 da                	mov    %ebx,%edx
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	75 43                	jne    801110 <__umoddi3+0x60>
  8010cd:	39 df                	cmp    %ebx,%edi
  8010cf:	76 17                	jbe    8010e8 <__umoddi3+0x38>
  8010d1:	89 f0                	mov    %esi,%eax
  8010d3:	f7 f7                	div    %edi
  8010d5:	89 d0                	mov    %edx,%eax
  8010d7:	31 d2                	xor    %edx,%edx
  8010d9:	83 c4 1c             	add    $0x1c,%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    
  8010e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010e8:	89 fd                	mov    %edi,%ebp
  8010ea:	85 ff                	test   %edi,%edi
  8010ec:	75 0b                	jne    8010f9 <__umoddi3+0x49>
  8010ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f3:	31 d2                	xor    %edx,%edx
  8010f5:	f7 f7                	div    %edi
  8010f7:	89 c5                	mov    %eax,%ebp
  8010f9:	89 d8                	mov    %ebx,%eax
  8010fb:	31 d2                	xor    %edx,%edx
  8010fd:	f7 f5                	div    %ebp
  8010ff:	89 f0                	mov    %esi,%eax
  801101:	f7 f5                	div    %ebp
  801103:	89 d0                	mov    %edx,%eax
  801105:	eb d0                	jmp    8010d7 <__umoddi3+0x27>
  801107:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80110e:	66 90                	xchg   %ax,%ax
  801110:	89 f1                	mov    %esi,%ecx
  801112:	39 d8                	cmp    %ebx,%eax
  801114:	76 0a                	jbe    801120 <__umoddi3+0x70>
  801116:	89 f0                	mov    %esi,%eax
  801118:	83 c4 1c             	add    $0x1c,%esp
  80111b:	5b                   	pop    %ebx
  80111c:	5e                   	pop    %esi
  80111d:	5f                   	pop    %edi
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    
  801120:	0f bd e8             	bsr    %eax,%ebp
  801123:	83 f5 1f             	xor    $0x1f,%ebp
  801126:	75 20                	jne    801148 <__umoddi3+0x98>
  801128:	39 d8                	cmp    %ebx,%eax
  80112a:	0f 82 b0 00 00 00    	jb     8011e0 <__umoddi3+0x130>
  801130:	39 f7                	cmp    %esi,%edi
  801132:	0f 86 a8 00 00 00    	jbe    8011e0 <__umoddi3+0x130>
  801138:	89 c8                	mov    %ecx,%eax
  80113a:	83 c4 1c             	add    $0x1c,%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5f                   	pop    %edi
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    
  801142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801148:	89 e9                	mov    %ebp,%ecx
  80114a:	ba 20 00 00 00       	mov    $0x20,%edx
  80114f:	29 ea                	sub    %ebp,%edx
  801151:	d3 e0                	shl    %cl,%eax
  801153:	89 44 24 08          	mov    %eax,0x8(%esp)
  801157:	89 d1                	mov    %edx,%ecx
  801159:	89 f8                	mov    %edi,%eax
  80115b:	d3 e8                	shr    %cl,%eax
  80115d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801161:	89 54 24 04          	mov    %edx,0x4(%esp)
  801165:	8b 54 24 04          	mov    0x4(%esp),%edx
  801169:	09 c1                	or     %eax,%ecx
  80116b:	89 d8                	mov    %ebx,%eax
  80116d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801171:	89 e9                	mov    %ebp,%ecx
  801173:	d3 e7                	shl    %cl,%edi
  801175:	89 d1                	mov    %edx,%ecx
  801177:	d3 e8                	shr    %cl,%eax
  801179:	89 e9                	mov    %ebp,%ecx
  80117b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80117f:	d3 e3                	shl    %cl,%ebx
  801181:	89 c7                	mov    %eax,%edi
  801183:	89 d1                	mov    %edx,%ecx
  801185:	89 f0                	mov    %esi,%eax
  801187:	d3 e8                	shr    %cl,%eax
  801189:	89 e9                	mov    %ebp,%ecx
  80118b:	89 fa                	mov    %edi,%edx
  80118d:	d3 e6                	shl    %cl,%esi
  80118f:	09 d8                	or     %ebx,%eax
  801191:	f7 74 24 08          	divl   0x8(%esp)
  801195:	89 d1                	mov    %edx,%ecx
  801197:	89 f3                	mov    %esi,%ebx
  801199:	f7 64 24 0c          	mull   0xc(%esp)
  80119d:	89 c6                	mov    %eax,%esi
  80119f:	89 d7                	mov    %edx,%edi
  8011a1:	39 d1                	cmp    %edx,%ecx
  8011a3:	72 06                	jb     8011ab <__umoddi3+0xfb>
  8011a5:	75 10                	jne    8011b7 <__umoddi3+0x107>
  8011a7:	39 c3                	cmp    %eax,%ebx
  8011a9:	73 0c                	jae    8011b7 <__umoddi3+0x107>
  8011ab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8011af:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8011b3:	89 d7                	mov    %edx,%edi
  8011b5:	89 c6                	mov    %eax,%esi
  8011b7:	89 ca                	mov    %ecx,%edx
  8011b9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8011be:	29 f3                	sub    %esi,%ebx
  8011c0:	19 fa                	sbb    %edi,%edx
  8011c2:	89 d0                	mov    %edx,%eax
  8011c4:	d3 e0                	shl    %cl,%eax
  8011c6:	89 e9                	mov    %ebp,%ecx
  8011c8:	d3 eb                	shr    %cl,%ebx
  8011ca:	d3 ea                	shr    %cl,%edx
  8011cc:	09 d8                	or     %ebx,%eax
  8011ce:	83 c4 1c             	add    $0x1c,%esp
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5f                   	pop    %edi
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    
  8011d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011dd:	8d 76 00             	lea    0x0(%esi),%esi
  8011e0:	89 da                	mov    %ebx,%edx
  8011e2:	29 fe                	sub    %edi,%esi
  8011e4:	19 c2                	sbb    %eax,%edx
  8011e6:	89 f1                	mov    %esi,%ecx
  8011e8:	89 c8                	mov    %ecx,%eax
  8011ea:	e9 4b ff ff ff       	jmp    80113a <__umoddi3+0x8a>
