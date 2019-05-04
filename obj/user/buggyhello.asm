
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 5d 00 00 00       	call   80009f <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 c6 00 00 00       	call   80011d <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	c1 e0 07             	shl    $0x7,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800093:	6a 00                	push   $0x0
  800095:	e8 42 00 00 00       	call   8000dc <sys_env_destroy>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	89 c3                	mov    %eax,%ebx
  8000b2:	89 c7                	mov    %eax,%edi
  8000b4:	89 c6                	mov    %eax,%esi
  8000b6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b8:	5b                   	pop    %ebx
  8000b9:	5e                   	pop    %esi
  8000ba:	5f                   	pop    %edi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cd:	89 d1                	mov    %edx,%ecx
  8000cf:	89 d3                	mov    %edx,%ebx
  8000d1:	89 d7                	mov    %edx,%edi
  8000d3:	89 d6                	mov    %edx,%esi
  8000d5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
  8000e2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	89 cb                	mov    %ecx,%ebx
  8000f4:	89 cf                	mov    %ecx,%edi
  8000f6:	89 ce                	mov    %ecx,%esi
  8000f8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	7f 08                	jg     800106 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5f                   	pop    %edi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 6a 11 80 00       	push   $0x80116a
  800111:	6a 23                	push   $0x23
  800113:	68 87 11 80 00       	push   $0x801187
  800118:	e8 2e 02 00 00       	call   80034b <_panic>

0080011d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
	asm volatile("int %1\n"
  800123:	ba 00 00 00 00       	mov    $0x0,%edx
  800128:	b8 02 00 00 00       	mov    $0x2,%eax
  80012d:	89 d1                	mov    %edx,%ecx
  80012f:	89 d3                	mov    %edx,%ebx
  800131:	89 d7                	mov    %edx,%edi
  800133:	89 d6                	mov    %edx,%esi
  800135:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <sys_yield>:

void
sys_yield(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	asm volatile("int %1\n"
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014c:	89 d1                	mov    %edx,%ecx
  80014e:	89 d3                	mov    %edx,%ebx
  800150:	89 d7                	mov    %edx,%edi
  800152:	89 d6                	mov    %edx,%esi
  800154:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800164:	be 00 00 00 00       	mov    $0x0,%esi
  800169:	8b 55 08             	mov    0x8(%ebp),%edx
  80016c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016f:	b8 04 00 00 00       	mov    $0x4,%eax
  800174:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800177:	89 f7                	mov    %esi,%edi
  800179:	cd 30                	int    $0x30
	if(check && ret > 0)
  80017b:	85 c0                	test   %eax,%eax
  80017d:	7f 08                	jg     800187 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800182:	5b                   	pop    %ebx
  800183:	5e                   	pop    %esi
  800184:	5f                   	pop    %edi
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 6a 11 80 00       	push   $0x80116a
  800192:	6a 23                	push   $0x23
  800194:	68 87 11 80 00       	push   $0x801187
  800199:	e8 ad 01 00 00       	call   80034b <_panic>

0080019e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	57                   	push   %edi
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b8:	8b 75 18             	mov    0x18(%ebp),%esi
  8001bb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	7f 08                	jg     8001c9 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 6a 11 80 00       	push   $0x80116a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 87 11 80 00       	push   $0x801187
  8001db:	e8 6b 01 00 00       	call   80034b <_panic>

008001e0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f9:	89 df                	mov    %ebx,%edi
  8001fb:	89 de                	mov    %ebx,%esi
  8001fd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ff:	85 c0                	test   %eax,%eax
  800201:	7f 08                	jg     80020b <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800203:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800206:	5b                   	pop    %ebx
  800207:	5e                   	pop    %esi
  800208:	5f                   	pop    %edi
  800209:	5d                   	pop    %ebp
  80020a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 6a 11 80 00       	push   $0x80116a
  800216:	6a 23                	push   $0x23
  800218:	68 87 11 80 00       	push   $0x801187
  80021d:	e8 29 01 00 00       	call   80034b <_panic>

00800222 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	57                   	push   %edi
  800226:	56                   	push   %esi
  800227:	53                   	push   %ebx
  800228:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800230:	8b 55 08             	mov    0x8(%ebp),%edx
  800233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800236:	b8 08 00 00 00       	mov    $0x8,%eax
  80023b:	89 df                	mov    %ebx,%edi
  80023d:	89 de                	mov    %ebx,%esi
  80023f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	7f 08                	jg     80024d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800245:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800248:	5b                   	pop    %ebx
  800249:	5e                   	pop    %esi
  80024a:	5f                   	pop    %edi
  80024b:	5d                   	pop    %ebp
  80024c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 6a 11 80 00       	push   $0x80116a
  800258:	6a 23                	push   $0x23
  80025a:	68 87 11 80 00       	push   $0x801187
  80025f:	e8 e7 00 00 00       	call   80034b <_panic>

00800264 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80026d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800272:	8b 55 08             	mov    0x8(%ebp),%edx
  800275:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800278:	b8 09 00 00 00       	mov    $0x9,%eax
  80027d:	89 df                	mov    %ebx,%edi
  80027f:	89 de                	mov    %ebx,%esi
  800281:	cd 30                	int    $0x30
	if(check && ret > 0)
  800283:	85 c0                	test   %eax,%eax
  800285:	7f 08                	jg     80028f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 6a 11 80 00       	push   $0x80116a
  80029a:	6a 23                	push   $0x23
  80029c:	68 87 11 80 00       	push   $0x801187
  8002a1:	e8 a5 00 00 00       	call   80034b <_panic>

008002a6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	57                   	push   %edi
  8002aa:	56                   	push   %esi
  8002ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8002af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b2:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b7:	be 00 00 00 00       	mov    $0x0,%esi
  8002bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	57                   	push   %edi
  8002cd:	56                   	push   %esi
  8002ce:	53                   	push   %ebx
  8002cf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002df:	89 cb                	mov    %ecx,%ebx
  8002e1:	89 cf                	mov    %ecx,%edi
  8002e3:	89 ce                	mov    %ecx,%esi
  8002e5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	7f 08                	jg     8002f3 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f3:	83 ec 0c             	sub    $0xc,%esp
  8002f6:	50                   	push   %eax
  8002f7:	6a 0c                	push   $0xc
  8002f9:	68 6a 11 80 00       	push   $0x80116a
  8002fe:	6a 23                	push   $0x23
  800300:	68 87 11 80 00       	push   $0x801187
  800305:	e8 41 00 00 00       	call   80034b <_panic>

0080030a <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800310:	bb 00 00 00 00       	mov    $0x0,%ebx
  800315:	8b 55 08             	mov    0x8(%ebp),%edx
  800318:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800320:	89 df                	mov    %ebx,%edi
  800322:	89 de                	mov    %ebx,%esi
  800324:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800326:	5b                   	pop    %ebx
  800327:	5e                   	pop    %esi
  800328:	5f                   	pop    %edi
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    

0080032b <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80032b:	55                   	push   %ebp
  80032c:	89 e5                	mov    %esp,%ebp
  80032e:	57                   	push   %edi
  80032f:	56                   	push   %esi
  800330:	53                   	push   %ebx
	asm volatile("int %1\n"
  800331:	b9 00 00 00 00       	mov    $0x0,%ecx
  800336:	8b 55 08             	mov    0x8(%ebp),%edx
  800339:	b8 0e 00 00 00       	mov    $0xe,%eax
  80033e:	89 cb                	mov    %ecx,%ebx
  800340:	89 cf                	mov    %ecx,%edi
  800342:	89 ce                	mov    %ecx,%esi
  800344:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	56                   	push   %esi
  80034f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800350:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800353:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800359:	e8 bf fd ff ff       	call   80011d <sys_getenvid>
  80035e:	83 ec 0c             	sub    $0xc,%esp
  800361:	ff 75 0c             	pushl  0xc(%ebp)
  800364:	ff 75 08             	pushl  0x8(%ebp)
  800367:	56                   	push   %esi
  800368:	50                   	push   %eax
  800369:	68 98 11 80 00       	push   $0x801198
  80036e:	e8 b3 00 00 00       	call   800426 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800373:	83 c4 18             	add    $0x18,%esp
  800376:	53                   	push   %ebx
  800377:	ff 75 10             	pushl  0x10(%ebp)
  80037a:	e8 56 00 00 00       	call   8003d5 <vcprintf>
	cprintf("\n");
  80037f:	c7 04 24 bb 11 80 00 	movl   $0x8011bb,(%esp)
  800386:	e8 9b 00 00 00       	call   800426 <cprintf>
  80038b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80038e:	cc                   	int3   
  80038f:	eb fd                	jmp    80038e <_panic+0x43>

00800391 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	53                   	push   %ebx
  800395:	83 ec 04             	sub    $0x4,%esp
  800398:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039b:	8b 13                	mov    (%ebx),%edx
  80039d:	8d 42 01             	lea    0x1(%edx),%eax
  8003a0:	89 03                	mov    %eax,(%ebx)
  8003a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ae:	74 09                	je     8003b9 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003b0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003b9:	83 ec 08             	sub    $0x8,%esp
  8003bc:	68 ff 00 00 00       	push   $0xff
  8003c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c4:	50                   	push   %eax
  8003c5:	e8 d5 fc ff ff       	call   80009f <sys_cputs>
		b->idx = 0;
  8003ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d0:	83 c4 10             	add    $0x10,%esp
  8003d3:	eb db                	jmp    8003b0 <putch+0x1f>

008003d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e5:	00 00 00 
	b.cnt = 0;
  8003e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f2:	ff 75 0c             	pushl  0xc(%ebp)
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003fe:	50                   	push   %eax
  8003ff:	68 91 03 80 00       	push   $0x800391
  800404:	e8 fb 00 00 00       	call   800504 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800409:	83 c4 08             	add    $0x8,%esp
  80040c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800412:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800418:	50                   	push   %eax
  800419:	e8 81 fc ff ff       	call   80009f <sys_cputs>

	return b.cnt;
}
  80041e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800424:	c9                   	leave  
  800425:	c3                   	ret    

00800426 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80042f:	50                   	push   %eax
  800430:	ff 75 08             	pushl  0x8(%ebp)
  800433:	e8 9d ff ff ff       	call   8003d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800438:	c9                   	leave  
  800439:	c3                   	ret    

0080043a <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	57                   	push   %edi
  80043e:	56                   	push   %esi
  80043f:	53                   	push   %ebx
  800440:	83 ec 1c             	sub    $0x1c,%esp
  800443:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800446:	89 d3                	mov    %edx,%ebx
  800448:	8b 75 08             	mov    0x8(%ebp),%esi
  80044b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80044e:	8b 45 10             	mov    0x10(%ebp),%eax
  800451:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800454:	89 c2                	mov    %eax,%edx
  800456:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800461:	39 c6                	cmp    %eax,%esi
  800463:	89 f8                	mov    %edi,%eax
  800465:	19 c8                	sbb    %ecx,%eax
  800467:	73 32                	jae    80049b <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	53                   	push   %ebx
  80046d:	83 ec 04             	sub    $0x4,%esp
  800470:	ff 75 e4             	pushl  -0x1c(%ebp)
  800473:	ff 75 e0             	pushl  -0x20(%ebp)
  800476:	57                   	push   %edi
  800477:	56                   	push   %esi
  800478:	e8 93 0b 00 00       	call   801010 <__umoddi3>
  80047d:	83 c4 14             	add    $0x14,%esp
  800480:	0f be 80 bd 11 80 00 	movsbl 0x8011bd(%eax),%eax
  800487:	50                   	push   %eax
  800488:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80048b:	ff d0                	call   *%eax
	return remain - 1;
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	83 e8 01             	sub    $0x1,%eax
}
  800493:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800496:	5b                   	pop    %ebx
  800497:	5e                   	pop    %esi
  800498:	5f                   	pop    %edi
  800499:	5d                   	pop    %ebp
  80049a:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  80049b:	83 ec 0c             	sub    $0xc,%esp
  80049e:	ff 75 18             	pushl  0x18(%ebp)
  8004a1:	ff 75 14             	pushl  0x14(%ebp)
  8004a4:	ff 75 d8             	pushl  -0x28(%ebp)
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	51                   	push   %ecx
  8004ab:	52                   	push   %edx
  8004ac:	57                   	push   %edi
  8004ad:	56                   	push   %esi
  8004ae:	e8 4d 0a 00 00       	call   800f00 <__udivdi3>
  8004b3:	83 c4 18             	add    $0x18,%esp
  8004b6:	52                   	push   %edx
  8004b7:	50                   	push   %eax
  8004b8:	89 da                	mov    %ebx,%edx
  8004ba:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004bd:	e8 78 ff ff ff       	call   80043a <printnum_helper>
  8004c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c5:	83 c4 20             	add    $0x20,%esp
  8004c8:	eb 9f                	jmp    800469 <printnum_helper+0x2f>

008004ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d4:	8b 10                	mov    (%eax),%edx
  8004d6:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d9:	73 0a                	jae    8004e5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004db:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004de:	89 08                	mov    %ecx,(%eax)
  8004e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e3:	88 02                	mov    %al,(%edx)
}
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <printfmt>:
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f0:	50                   	push   %eax
  8004f1:	ff 75 10             	pushl  0x10(%ebp)
  8004f4:	ff 75 0c             	pushl  0xc(%ebp)
  8004f7:	ff 75 08             	pushl  0x8(%ebp)
  8004fa:	e8 05 00 00 00       	call   800504 <vprintfmt>
}
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	c9                   	leave  
  800503:	c3                   	ret    

00800504 <vprintfmt>:
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	57                   	push   %edi
  800508:	56                   	push   %esi
  800509:	53                   	push   %ebx
  80050a:	83 ec 3c             	sub    $0x3c,%esp
  80050d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800510:	8b 75 0c             	mov    0xc(%ebp),%esi
  800513:	8b 7d 10             	mov    0x10(%ebp),%edi
  800516:	e9 3f 05 00 00       	jmp    800a5a <vprintfmt+0x556>
		padc = ' ';
  80051b:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  80051f:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800526:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  80052d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800534:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  80053b:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800542:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800547:	8d 47 01             	lea    0x1(%edi),%eax
  80054a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80054d:	0f b6 17             	movzbl (%edi),%edx
  800550:	8d 42 dd             	lea    -0x23(%edx),%eax
  800553:	3c 55                	cmp    $0x55,%al
  800555:	0f 87 98 05 00 00    	ja     800af3 <vprintfmt+0x5ef>
  80055b:	0f b6 c0             	movzbl %al,%eax
  80055e:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)
  800565:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  800568:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80056c:	eb d9                	jmp    800547 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800571:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  800578:	eb cd                	jmp    800547 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	0f b6 d2             	movzbl %dl,%edx
  80057d:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800580:	b8 00 00 00 00       	mov    $0x0,%eax
  800585:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  800588:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80058b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80058f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800592:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800595:	83 fb 09             	cmp    $0x9,%ebx
  800598:	77 5c                	ja     8005f6 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  80059a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80059d:	eb e9                	jmp    800588 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  8005a2:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  8005a6:	eb 9f                	jmp    800547 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  8005a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ab:	8b 00                	mov    (%eax),%eax
  8005ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8d 40 04             	lea    0x4(%eax),%eax
  8005b6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8005bc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c0:	79 85                	jns    800547 <vprintfmt+0x43>
				width = precision, precision = -1;
  8005c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005cf:	e9 73 ff ff ff       	jmp    800547 <vprintfmt+0x43>
  8005d4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	0f 48 c1             	cmovs  %ecx,%eax
  8005dc:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005e2:	e9 60 ff ff ff       	jmp    800547 <vprintfmt+0x43>
  8005e7:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8005ea:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8005f1:	e9 51 ff ff ff       	jmp    800547 <vprintfmt+0x43>
  8005f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005fc:	eb be                	jmp    8005bc <vprintfmt+0xb8>
			lflag++;
  8005fe:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800602:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  800605:	e9 3d ff ff ff       	jmp    800547 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8d 78 04             	lea    0x4(%eax),%edi
  800610:	83 ec 08             	sub    $0x8,%esp
  800613:	56                   	push   %esi
  800614:	ff 30                	pushl  (%eax)
  800616:	ff d3                	call   *%ebx
			break;
  800618:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80061b:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80061e:	e9 34 04 00 00       	jmp    800a57 <vprintfmt+0x553>
			err = va_arg(ap, int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 78 04             	lea    0x4(%eax),%edi
  800629:	8b 00                	mov    (%eax),%eax
  80062b:	99                   	cltd   
  80062c:	31 d0                	xor    %edx,%eax
  80062e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800630:	83 f8 08             	cmp    $0x8,%eax
  800633:	7f 23                	jg     800658 <vprintfmt+0x154>
  800635:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  80063c:	85 d2                	test   %edx,%edx
  80063e:	74 18                	je     800658 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800640:	52                   	push   %edx
  800641:	68 de 11 80 00       	push   $0x8011de
  800646:	56                   	push   %esi
  800647:	53                   	push   %ebx
  800648:	e8 9a fe ff ff       	call   8004e7 <printfmt>
  80064d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800650:	89 7d 14             	mov    %edi,0x14(%ebp)
  800653:	e9 ff 03 00 00       	jmp    800a57 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  800658:	50                   	push   %eax
  800659:	68 d5 11 80 00       	push   $0x8011d5
  80065e:	56                   	push   %esi
  80065f:	53                   	push   %ebx
  800660:	e8 82 fe ff ff       	call   8004e7 <printfmt>
  800665:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800668:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80066b:	e9 e7 03 00 00       	jmp    800a57 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  800670:	8b 45 14             	mov    0x14(%ebp),%eax
  800673:	83 c0 04             	add    $0x4,%eax
  800676:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80067e:	85 c9                	test   %ecx,%ecx
  800680:	b8 ce 11 80 00       	mov    $0x8011ce,%eax
  800685:	0f 45 c1             	cmovne %ecx,%eax
  800688:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80068b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80068f:	7e 06                	jle    800697 <vprintfmt+0x193>
  800691:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800695:	75 0d                	jne    8006a4 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800697:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80069a:	89 c7                	mov    %eax,%edi
  80069c:	03 45 d8             	add    -0x28(%ebp),%eax
  80069f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a2:	eb 53                	jmp    8006f7 <vprintfmt+0x1f3>
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006aa:	50                   	push   %eax
  8006ab:	e8 eb 04 00 00       	call   800b9b <strnlen>
  8006b0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006b3:	29 c1                	sub    %eax,%ecx
  8006b5:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006bd:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8006c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c4:	eb 0f                	jmp    8006d5 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	56                   	push   %esi
  8006ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8006cd:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	83 ef 01             	sub    $0x1,%edi
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	85 ff                	test   %edi,%edi
  8006d7:	7f ed                	jg     8006c6 <vprintfmt+0x1c2>
  8006d9:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8006dc:	85 c9                	test   %ecx,%ecx
  8006de:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e3:	0f 49 c1             	cmovns %ecx,%eax
  8006e6:	29 c1                	sub    %eax,%ecx
  8006e8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006eb:	eb aa                	jmp    800697 <vprintfmt+0x193>
					putch(ch, putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	56                   	push   %esi
  8006f1:	52                   	push   %edx
  8006f2:	ff d3                	call   *%ebx
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006fa:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fc:	83 c7 01             	add    $0x1,%edi
  8006ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800703:	0f be d0             	movsbl %al,%edx
  800706:	85 d2                	test   %edx,%edx
  800708:	74 2e                	je     800738 <vprintfmt+0x234>
  80070a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80070e:	78 06                	js     800716 <vprintfmt+0x212>
  800710:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800714:	78 1e                	js     800734 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800716:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80071a:	74 d1                	je     8006ed <vprintfmt+0x1e9>
  80071c:	0f be c0             	movsbl %al,%eax
  80071f:	83 e8 20             	sub    $0x20,%eax
  800722:	83 f8 5e             	cmp    $0x5e,%eax
  800725:	76 c6                	jbe    8006ed <vprintfmt+0x1e9>
					putch('?', putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	56                   	push   %esi
  80072b:	6a 3f                	push   $0x3f
  80072d:	ff d3                	call   *%ebx
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	eb c3                	jmp    8006f7 <vprintfmt+0x1f3>
  800734:	89 cf                	mov    %ecx,%edi
  800736:	eb 02                	jmp    80073a <vprintfmt+0x236>
  800738:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  80073a:	85 ff                	test   %edi,%edi
  80073c:	7e 10                	jle    80074e <vprintfmt+0x24a>
				putch(' ', putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	56                   	push   %esi
  800742:	6a 20                	push   $0x20
  800744:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800746:	83 ef 01             	sub    $0x1,%edi
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb ec                	jmp    80073a <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  80074e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800751:	89 45 14             	mov    %eax,0x14(%ebp)
  800754:	e9 fe 02 00 00       	jmp    800a57 <vprintfmt+0x553>
	if (lflag >= 2)
  800759:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80075d:	7f 21                	jg     800780 <vprintfmt+0x27c>
	else if (lflag)
  80075f:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800763:	74 79                	je     8007de <vprintfmt+0x2da>
		return va_arg(*ap, long);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8b 00                	mov    (%eax),%eax
  80076a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80076d:	89 c1                	mov    %eax,%ecx
  80076f:	c1 f9 1f             	sar    $0x1f,%ecx
  800772:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8d 40 04             	lea    0x4(%eax),%eax
  80077b:	89 45 14             	mov    %eax,0x14(%ebp)
  80077e:	eb 17                	jmp    800797 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8b 50 04             	mov    0x4(%eax),%edx
  800786:	8b 00                	mov    (%eax),%eax
  800788:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80078b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80078e:	8b 45 14             	mov    0x14(%ebp),%eax
  800791:	8d 40 08             	lea    0x8(%eax),%eax
  800794:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  800797:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80079a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80079d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  8007a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a7:	78 50                	js     8007f9 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  8007a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ac:	c1 fa 1f             	sar    $0x1f,%edx
  8007af:	89 d0                	mov    %edx,%eax
  8007b1:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8007b4:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8007b7:	85 d2                	test   %edx,%edx
  8007b9:	0f 89 14 02 00 00    	jns    8009d3 <vprintfmt+0x4cf>
  8007bf:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007c3:	0f 84 0a 02 00 00    	je     8009d3 <vprintfmt+0x4cf>
				putch('+', putdat);
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	56                   	push   %esi
  8007cd:	6a 2b                	push   $0x2b
  8007cf:	ff d3                	call   *%ebx
  8007d1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007d4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d9:	e9 5c 01 00 00       	jmp    80093a <vprintfmt+0x436>
		return va_arg(*ap, int);
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8b 00                	mov    (%eax),%eax
  8007e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007e6:	89 c1                	mov    %eax,%ecx
  8007e8:	c1 f9 1f             	sar    $0x1f,%ecx
  8007eb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8007ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f1:	8d 40 04             	lea    0x4(%eax),%eax
  8007f4:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f7:	eb 9e                	jmp    800797 <vprintfmt+0x293>
				putch('-', putdat);
  8007f9:	83 ec 08             	sub    $0x8,%esp
  8007fc:	56                   	push   %esi
  8007fd:	6a 2d                	push   $0x2d
  8007ff:	ff d3                	call   *%ebx
				num = -(long long) num;
  800801:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800804:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800807:	f7 d8                	neg    %eax
  800809:	83 d2 00             	adc    $0x0,%edx
  80080c:	f7 da                	neg    %edx
  80080e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800811:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800814:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800817:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081c:	e9 19 01 00 00       	jmp    80093a <vprintfmt+0x436>
	if (lflag >= 2)
  800821:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800825:	7f 29                	jg     800850 <vprintfmt+0x34c>
	else if (lflag)
  800827:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80082b:	74 44                	je     800871 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  80082d:	8b 45 14             	mov    0x14(%ebp),%eax
  800830:	8b 00                	mov    (%eax),%eax
  800832:	ba 00 00 00 00       	mov    $0x0,%edx
  800837:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80083a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80083d:	8b 45 14             	mov    0x14(%ebp),%eax
  800840:	8d 40 04             	lea    0x4(%eax),%eax
  800843:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800846:	b8 0a 00 00 00       	mov    $0xa,%eax
  80084b:	e9 ea 00 00 00       	jmp    80093a <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8b 50 04             	mov    0x4(%eax),%edx
  800856:	8b 00                	mov    (%eax),%eax
  800858:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80085b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8d 40 08             	lea    0x8(%eax),%eax
  800864:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800867:	b8 0a 00 00 00       	mov    $0xa,%eax
  80086c:	e9 c9 00 00 00       	jmp    80093a <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800871:	8b 45 14             	mov    0x14(%ebp),%eax
  800874:	8b 00                	mov    (%eax),%eax
  800876:	ba 00 00 00 00       	mov    $0x0,%edx
  80087b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80087e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800881:	8b 45 14             	mov    0x14(%ebp),%eax
  800884:	8d 40 04             	lea    0x4(%eax),%eax
  800887:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80088a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80088f:	e9 a6 00 00 00       	jmp    80093a <vprintfmt+0x436>
			putch('0', putdat);
  800894:	83 ec 08             	sub    $0x8,%esp
  800897:	56                   	push   %esi
  800898:	6a 30                	push   $0x30
  80089a:	ff d3                	call   *%ebx
	if (lflag >= 2)
  80089c:	83 c4 10             	add    $0x10,%esp
  80089f:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8008a3:	7f 26                	jg     8008cb <vprintfmt+0x3c7>
	else if (lflag)
  8008a5:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8008a9:	74 3e                	je     8008e9 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  8008ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ae:	8b 00                	mov    (%eax),%eax
  8008b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008b8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008be:	8d 40 04             	lea    0x4(%eax),%eax
  8008c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8008c9:	eb 6f                	jmp    80093a <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	8b 50 04             	mov    0x4(%eax),%edx
  8008d1:	8b 00                	mov    (%eax),%eax
  8008d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008d6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dc:	8d 40 08             	lea    0x8(%eax),%eax
  8008df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008e2:	b8 08 00 00 00       	mov    $0x8,%eax
  8008e7:	eb 51                	jmp    80093a <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8008e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ec:	8b 00                	mov    (%eax),%eax
  8008ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8008f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008f6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fc:	8d 40 04             	lea    0x4(%eax),%eax
  8008ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800902:	b8 08 00 00 00       	mov    $0x8,%eax
  800907:	eb 31                	jmp    80093a <vprintfmt+0x436>
			putch('0', putdat);
  800909:	83 ec 08             	sub    $0x8,%esp
  80090c:	56                   	push   %esi
  80090d:	6a 30                	push   $0x30
  80090f:	ff d3                	call   *%ebx
			putch('x', putdat);
  800911:	83 c4 08             	add    $0x8,%esp
  800914:	56                   	push   %esi
  800915:	6a 78                	push   $0x78
  800917:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800919:	8b 45 14             	mov    0x14(%ebp),%eax
  80091c:	8b 00                	mov    (%eax),%eax
  80091e:	ba 00 00 00 00       	mov    $0x0,%edx
  800923:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800926:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800929:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	8d 40 04             	lea    0x4(%eax),%eax
  800932:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800935:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80093a:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  80093e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800941:	89 c1                	mov    %eax,%ecx
  800943:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800946:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800949:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  80094e:	89 c2                	mov    %eax,%edx
  800950:	39 c1                	cmp    %eax,%ecx
  800952:	0f 87 85 00 00 00    	ja     8009dd <vprintfmt+0x4d9>
		tmp /= base;
  800958:	89 d0                	mov    %edx,%eax
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	f7 f1                	div    %ecx
		len++;
  800961:	83 c7 01             	add    $0x1,%edi
  800964:	eb e8                	jmp    80094e <vprintfmt+0x44a>
	if (lflag >= 2)
  800966:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80096a:	7f 26                	jg     800992 <vprintfmt+0x48e>
	else if (lflag)
  80096c:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800970:	74 3e                	je     8009b0 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8b 00                	mov    (%eax),%eax
  800977:	ba 00 00 00 00       	mov    $0x0,%edx
  80097c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80097f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800982:	8b 45 14             	mov    0x14(%ebp),%eax
  800985:	8d 40 04             	lea    0x4(%eax),%eax
  800988:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80098b:	b8 10 00 00 00       	mov    $0x10,%eax
  800990:	eb a8                	jmp    80093a <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800992:	8b 45 14             	mov    0x14(%ebp),%eax
  800995:	8b 50 04             	mov    0x4(%eax),%edx
  800998:	8b 00                	mov    (%eax),%eax
  80099a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80099d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a3:	8d 40 08             	lea    0x8(%eax),%eax
  8009a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009a9:	b8 10 00 00 00       	mov    $0x10,%eax
  8009ae:	eb 8a                	jmp    80093a <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8009b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b3:	8b 00                	mov    (%eax),%eax
  8009b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009bd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c3:	8d 40 04             	lea    0x4(%eax),%eax
  8009c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009c9:	b8 10 00 00 00       	mov    $0x10,%eax
  8009ce:	e9 67 ff ff ff       	jmp    80093a <vprintfmt+0x436>
			base = 10;
  8009d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d8:	e9 5d ff ff ff       	jmp    80093a <vprintfmt+0x436>
  8009dd:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8009e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e3:	29 f8                	sub    %edi,%eax
  8009e5:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8009e7:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8009eb:	74 15                	je     800a02 <vprintfmt+0x4fe>
		while (width > 0) {
  8009ed:	85 ff                	test   %edi,%edi
  8009ef:	7e 48                	jle    800a39 <vprintfmt+0x535>
			putch(padc, putdat);
  8009f1:	83 ec 08             	sub    $0x8,%esp
  8009f4:	56                   	push   %esi
  8009f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8009f8:	ff d3                	call   *%ebx
			width--;
  8009fa:	83 ef 01             	sub    $0x1,%edi
  8009fd:	83 c4 10             	add    $0x10,%esp
  800a00:	eb eb                	jmp    8009ed <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a02:	83 ec 0c             	sub    $0xc,%esp
  800a05:	6a 2d                	push   $0x2d
  800a07:	ff 75 cc             	pushl  -0x34(%ebp)
  800a0a:	ff 75 c8             	pushl  -0x38(%ebp)
  800a0d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a10:	ff 75 d0             	pushl  -0x30(%ebp)
  800a13:	89 f2                	mov    %esi,%edx
  800a15:	89 d8                	mov    %ebx,%eax
  800a17:	e8 1e fa ff ff       	call   80043a <printnum_helper>
		width -= len;
  800a1c:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a1f:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800a22:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800a25:	85 ff                	test   %edi,%edi
  800a27:	7e 2e                	jle    800a57 <vprintfmt+0x553>
			putch(padc, putdat);
  800a29:	83 ec 08             	sub    $0x8,%esp
  800a2c:	56                   	push   %esi
  800a2d:	6a 20                	push   $0x20
  800a2f:	ff d3                	call   *%ebx
			width--;
  800a31:	83 ef 01             	sub    $0x1,%edi
  800a34:	83 c4 10             	add    $0x10,%esp
  800a37:	eb ec                	jmp    800a25 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a39:	83 ec 0c             	sub    $0xc,%esp
  800a3c:	ff 75 e0             	pushl  -0x20(%ebp)
  800a3f:	ff 75 cc             	pushl  -0x34(%ebp)
  800a42:	ff 75 c8             	pushl  -0x38(%ebp)
  800a45:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a48:	ff 75 d0             	pushl  -0x30(%ebp)
  800a4b:	89 f2                	mov    %esi,%edx
  800a4d:	89 d8                	mov    %ebx,%eax
  800a4f:	e8 e6 f9 ff ff       	call   80043a <printnum_helper>
  800a54:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800a57:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a5a:	83 c7 01             	add    $0x1,%edi
  800a5d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a61:	83 f8 25             	cmp    $0x25,%eax
  800a64:	0f 84 b1 fa ff ff    	je     80051b <vprintfmt+0x17>
			if (ch == '\0')
  800a6a:	85 c0                	test   %eax,%eax
  800a6c:	0f 84 a1 00 00 00    	je     800b13 <vprintfmt+0x60f>
			putch(ch, putdat);
  800a72:	83 ec 08             	sub    $0x8,%esp
  800a75:	56                   	push   %esi
  800a76:	50                   	push   %eax
  800a77:	ff d3                	call   *%ebx
  800a79:	83 c4 10             	add    $0x10,%esp
  800a7c:	eb dc                	jmp    800a5a <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800a7e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a81:	83 c0 04             	add    $0x4,%eax
  800a84:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a87:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8a:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800a8c:	85 ff                	test   %edi,%edi
  800a8e:	74 15                	je     800aa5 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800a90:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800a96:	7f 29                	jg     800ac1 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800a98:	0f b6 06             	movzbl (%esi),%eax
  800a9b:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800a9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800aa0:	89 45 14             	mov    %eax,0x14(%ebp)
  800aa3:	eb b2                	jmp    800a57 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800aa5:	68 74 12 80 00       	push   $0x801274
  800aaa:	68 de 11 80 00       	push   $0x8011de
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	e8 31 fa ff ff       	call   8004e7 <printfmt>
  800ab6:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800ab9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800abc:	89 45 14             	mov    %eax,0x14(%ebp)
  800abf:	eb 96                	jmp    800a57 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800ac1:	68 ac 12 80 00       	push   $0x8012ac
  800ac6:	68 de 11 80 00       	push   $0x8011de
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	e8 15 fa ff ff       	call   8004e7 <printfmt>
				*res = -1;
  800ad2:	c6 07 ff             	movb   $0xff,(%edi)
  800ad5:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800ad8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800adb:	89 45 14             	mov    %eax,0x14(%ebp)
  800ade:	e9 74 ff ff ff       	jmp    800a57 <vprintfmt+0x553>
			putch(ch, putdat);
  800ae3:	83 ec 08             	sub    $0x8,%esp
  800ae6:	56                   	push   %esi
  800ae7:	6a 25                	push   $0x25
  800ae9:	ff d3                	call   *%ebx
			break;
  800aeb:	83 c4 10             	add    $0x10,%esp
  800aee:	e9 64 ff ff ff       	jmp    800a57 <vprintfmt+0x553>
			putch('%', putdat);
  800af3:	83 ec 08             	sub    $0x8,%esp
  800af6:	56                   	push   %esi
  800af7:	6a 25                	push   $0x25
  800af9:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800afb:	83 c4 10             	add    $0x10,%esp
  800afe:	89 f8                	mov    %edi,%eax
  800b00:	eb 03                	jmp    800b05 <vprintfmt+0x601>
  800b02:	83 e8 01             	sub    $0x1,%eax
  800b05:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800b09:	75 f7                	jne    800b02 <vprintfmt+0x5fe>
  800b0b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b0e:	e9 44 ff ff ff       	jmp    800a57 <vprintfmt+0x553>
}
  800b13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	83 ec 18             	sub    $0x18,%esp
  800b21:	8b 45 08             	mov    0x8(%ebp),%eax
  800b24:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b27:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b2a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b2e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b38:	85 c0                	test   %eax,%eax
  800b3a:	74 26                	je     800b62 <vsnprintf+0x47>
  800b3c:	85 d2                	test   %edx,%edx
  800b3e:	7e 22                	jle    800b62 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b40:	ff 75 14             	pushl  0x14(%ebp)
  800b43:	ff 75 10             	pushl  0x10(%ebp)
  800b46:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b49:	50                   	push   %eax
  800b4a:	68 ca 04 80 00       	push   $0x8004ca
  800b4f:	e8 b0 f9 ff ff       	call   800504 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b54:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b57:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b5d:	83 c4 10             	add    $0x10,%esp
}
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    
		return -E_INVAL;
  800b62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b67:	eb f7                	jmp    800b60 <vsnprintf+0x45>

00800b69 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b6f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b72:	50                   	push   %eax
  800b73:	ff 75 10             	pushl  0x10(%ebp)
  800b76:	ff 75 0c             	pushl  0xc(%ebp)
  800b79:	ff 75 08             	pushl  0x8(%ebp)
  800b7c:	e8 9a ff ff ff       	call   800b1b <vsnprintf>
	va_end(ap);

	return rc;
}
  800b81:	c9                   	leave  
  800b82:	c3                   	ret    

00800b83 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b83:	55                   	push   %ebp
  800b84:	89 e5                	mov    %esp,%ebp
  800b86:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b89:	b8 00 00 00 00       	mov    $0x0,%eax
  800b8e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b92:	74 05                	je     800b99 <strlen+0x16>
		n++;
  800b94:	83 c0 01             	add    $0x1,%eax
  800b97:	eb f5                	jmp    800b8e <strlen+0xb>
	return n;
}
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba9:	39 c2                	cmp    %eax,%edx
  800bab:	74 0d                	je     800bba <strnlen+0x1f>
  800bad:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800bb1:	74 05                	je     800bb8 <strnlen+0x1d>
		n++;
  800bb3:	83 c2 01             	add    $0x1,%edx
  800bb6:	eb f1                	jmp    800ba9 <strnlen+0xe>
  800bb8:	89 d0                	mov    %edx,%eax
	return n;
}
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	53                   	push   %ebx
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcb:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bcf:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bd2:	83 c2 01             	add    $0x1,%edx
  800bd5:	84 c9                	test   %cl,%cl
  800bd7:	75 f2                	jne    800bcb <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 10             	sub    $0x10,%esp
  800be3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800be6:	53                   	push   %ebx
  800be7:	e8 97 ff ff ff       	call   800b83 <strlen>
  800bec:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800bef:	ff 75 0c             	pushl  0xc(%ebp)
  800bf2:	01 d8                	add    %ebx,%eax
  800bf4:	50                   	push   %eax
  800bf5:	e8 c2 ff ff ff       	call   800bbc <strcpy>
	return dst;
}
  800bfa:	89 d8                	mov    %ebx,%eax
  800bfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	8b 45 08             	mov    0x8(%ebp),%eax
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	89 c6                	mov    %eax,%esi
  800c0e:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c11:	89 c2                	mov    %eax,%edx
  800c13:	39 f2                	cmp    %esi,%edx
  800c15:	74 11                	je     800c28 <strncpy+0x27>
		*dst++ = *src;
  800c17:	83 c2 01             	add    $0x1,%edx
  800c1a:	0f b6 19             	movzbl (%ecx),%ebx
  800c1d:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c20:	80 fb 01             	cmp    $0x1,%bl
  800c23:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800c26:	eb eb                	jmp    800c13 <strncpy+0x12>
	}
	return ret;
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	8b 75 08             	mov    0x8(%ebp),%esi
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8b 55 10             	mov    0x10(%ebp),%edx
  800c3a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c3c:	85 d2                	test   %edx,%edx
  800c3e:	74 21                	je     800c61 <strlcpy+0x35>
  800c40:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c44:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800c46:	39 c2                	cmp    %eax,%edx
  800c48:	74 14                	je     800c5e <strlcpy+0x32>
  800c4a:	0f b6 19             	movzbl (%ecx),%ebx
  800c4d:	84 db                	test   %bl,%bl
  800c4f:	74 0b                	je     800c5c <strlcpy+0x30>
			*dst++ = *src++;
  800c51:	83 c1 01             	add    $0x1,%ecx
  800c54:	83 c2 01             	add    $0x1,%edx
  800c57:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c5a:	eb ea                	jmp    800c46 <strlcpy+0x1a>
  800c5c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c5e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c61:	29 f0                	sub    %esi,%eax
}
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c70:	0f b6 01             	movzbl (%ecx),%eax
  800c73:	84 c0                	test   %al,%al
  800c75:	74 0c                	je     800c83 <strcmp+0x1c>
  800c77:	3a 02                	cmp    (%edx),%al
  800c79:	75 08                	jne    800c83 <strcmp+0x1c>
		p++, q++;
  800c7b:	83 c1 01             	add    $0x1,%ecx
  800c7e:	83 c2 01             	add    $0x1,%edx
  800c81:	eb ed                	jmp    800c70 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c83:	0f b6 c0             	movzbl %al,%eax
  800c86:	0f b6 12             	movzbl (%edx),%edx
  800c89:	29 d0                	sub    %edx,%eax
}
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    

00800c8d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c8d:	55                   	push   %ebp
  800c8e:	89 e5                	mov    %esp,%ebp
  800c90:	53                   	push   %ebx
  800c91:	8b 45 08             	mov    0x8(%ebp),%eax
  800c94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c97:	89 c3                	mov    %eax,%ebx
  800c99:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c9c:	eb 06                	jmp    800ca4 <strncmp+0x17>
		n--, p++, q++;
  800c9e:	83 c0 01             	add    $0x1,%eax
  800ca1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ca4:	39 d8                	cmp    %ebx,%eax
  800ca6:	74 16                	je     800cbe <strncmp+0x31>
  800ca8:	0f b6 08             	movzbl (%eax),%ecx
  800cab:	84 c9                	test   %cl,%cl
  800cad:	74 04                	je     800cb3 <strncmp+0x26>
  800caf:	3a 0a                	cmp    (%edx),%cl
  800cb1:	74 eb                	je     800c9e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb3:	0f b6 00             	movzbl (%eax),%eax
  800cb6:	0f b6 12             	movzbl (%edx),%edx
  800cb9:	29 d0                	sub    %edx,%eax
}
  800cbb:	5b                   	pop    %ebx
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    
		return 0;
  800cbe:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc3:	eb f6                	jmp    800cbb <strncmp+0x2e>

00800cc5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ccf:	0f b6 10             	movzbl (%eax),%edx
  800cd2:	84 d2                	test   %dl,%dl
  800cd4:	74 09                	je     800cdf <strchr+0x1a>
		if (*s == c)
  800cd6:	38 ca                	cmp    %cl,%dl
  800cd8:	74 0a                	je     800ce4 <strchr+0x1f>
	for (; *s; s++)
  800cda:	83 c0 01             	add    $0x1,%eax
  800cdd:	eb f0                	jmp    800ccf <strchr+0xa>
			return (char *) s;
	return 0;
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cf3:	38 ca                	cmp    %cl,%dl
  800cf5:	74 09                	je     800d00 <strfind+0x1a>
  800cf7:	84 d2                	test   %dl,%dl
  800cf9:	74 05                	je     800d00 <strfind+0x1a>
	for (; *s; s++)
  800cfb:	83 c0 01             	add    $0x1,%eax
  800cfe:	eb f0                	jmp    800cf0 <strfind+0xa>
			break;
	return (char *) s;
}
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d0e:	85 c9                	test   %ecx,%ecx
  800d10:	74 31                	je     800d43 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d12:	89 f8                	mov    %edi,%eax
  800d14:	09 c8                	or     %ecx,%eax
  800d16:	a8 03                	test   $0x3,%al
  800d18:	75 23                	jne    800d3d <memset+0x3b>
		c &= 0xFF;
  800d1a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d1e:	89 d3                	mov    %edx,%ebx
  800d20:	c1 e3 08             	shl    $0x8,%ebx
  800d23:	89 d0                	mov    %edx,%eax
  800d25:	c1 e0 18             	shl    $0x18,%eax
  800d28:	89 d6                	mov    %edx,%esi
  800d2a:	c1 e6 10             	shl    $0x10,%esi
  800d2d:	09 f0                	or     %esi,%eax
  800d2f:	09 c2                	or     %eax,%edx
  800d31:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d33:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d36:	89 d0                	mov    %edx,%eax
  800d38:	fc                   	cld    
  800d39:	f3 ab                	rep stos %eax,%es:(%edi)
  800d3b:	eb 06                	jmp    800d43 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d40:	fc                   	cld    
  800d41:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d43:	89 f8                	mov    %edi,%eax
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	57                   	push   %edi
  800d4e:	56                   	push   %esi
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d58:	39 c6                	cmp    %eax,%esi
  800d5a:	73 32                	jae    800d8e <memmove+0x44>
  800d5c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d5f:	39 c2                	cmp    %eax,%edx
  800d61:	76 2b                	jbe    800d8e <memmove+0x44>
		s += n;
		d += n;
  800d63:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d66:	89 fe                	mov    %edi,%esi
  800d68:	09 ce                	or     %ecx,%esi
  800d6a:	09 d6                	or     %edx,%esi
  800d6c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d72:	75 0e                	jne    800d82 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d74:	83 ef 04             	sub    $0x4,%edi
  800d77:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d7a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d7d:	fd                   	std    
  800d7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d80:	eb 09                	jmp    800d8b <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d82:	83 ef 01             	sub    $0x1,%edi
  800d85:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d88:	fd                   	std    
  800d89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d8b:	fc                   	cld    
  800d8c:	eb 1a                	jmp    800da8 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d8e:	89 c2                	mov    %eax,%edx
  800d90:	09 ca                	or     %ecx,%edx
  800d92:	09 f2                	or     %esi,%edx
  800d94:	f6 c2 03             	test   $0x3,%dl
  800d97:	75 0a                	jne    800da3 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d99:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d9c:	89 c7                	mov    %eax,%edi
  800d9e:	fc                   	cld    
  800d9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800da1:	eb 05                	jmp    800da8 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800da3:	89 c7                	mov    %eax,%edi
  800da5:	fc                   	cld    
  800da6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800db2:	ff 75 10             	pushl  0x10(%ebp)
  800db5:	ff 75 0c             	pushl  0xc(%ebp)
  800db8:	ff 75 08             	pushl  0x8(%ebp)
  800dbb:	e8 8a ff ff ff       	call   800d4a <memmove>
}
  800dc0:	c9                   	leave  
  800dc1:	c3                   	ret    

00800dc2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dcd:	89 c6                	mov    %eax,%esi
  800dcf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd2:	39 f0                	cmp    %esi,%eax
  800dd4:	74 1c                	je     800df2 <memcmp+0x30>
		if (*s1 != *s2)
  800dd6:	0f b6 08             	movzbl (%eax),%ecx
  800dd9:	0f b6 1a             	movzbl (%edx),%ebx
  800ddc:	38 d9                	cmp    %bl,%cl
  800dde:	75 08                	jne    800de8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800de0:	83 c0 01             	add    $0x1,%eax
  800de3:	83 c2 01             	add    $0x1,%edx
  800de6:	eb ea                	jmp    800dd2 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800de8:	0f b6 c1             	movzbl %cl,%eax
  800deb:	0f b6 db             	movzbl %bl,%ebx
  800dee:	29 d8                	sub    %ebx,%eax
  800df0:	eb 05                	jmp    800df7 <memcmp+0x35>
	}

	return 0;
  800df2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e04:	89 c2                	mov    %eax,%edx
  800e06:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e09:	39 d0                	cmp    %edx,%eax
  800e0b:	73 09                	jae    800e16 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e0d:	38 08                	cmp    %cl,(%eax)
  800e0f:	74 05                	je     800e16 <memfind+0x1b>
	for (; s < ends; s++)
  800e11:	83 c0 01             	add    $0x1,%eax
  800e14:	eb f3                	jmp    800e09 <memfind+0xe>
			break;
	return (void *) s;
}
  800e16:	5d                   	pop    %ebp
  800e17:	c3                   	ret    

00800e18 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e18:	55                   	push   %ebp
  800e19:	89 e5                	mov    %esp,%ebp
  800e1b:	57                   	push   %edi
  800e1c:	56                   	push   %esi
  800e1d:	53                   	push   %ebx
  800e1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e24:	eb 03                	jmp    800e29 <strtol+0x11>
		s++;
  800e26:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e29:	0f b6 01             	movzbl (%ecx),%eax
  800e2c:	3c 20                	cmp    $0x20,%al
  800e2e:	74 f6                	je     800e26 <strtol+0xe>
  800e30:	3c 09                	cmp    $0x9,%al
  800e32:	74 f2                	je     800e26 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e34:	3c 2b                	cmp    $0x2b,%al
  800e36:	74 2a                	je     800e62 <strtol+0x4a>
	int neg = 0;
  800e38:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e3d:	3c 2d                	cmp    $0x2d,%al
  800e3f:	74 2b                	je     800e6c <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e41:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e47:	75 0f                	jne    800e58 <strtol+0x40>
  800e49:	80 39 30             	cmpb   $0x30,(%ecx)
  800e4c:	74 28                	je     800e76 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e4e:	85 db                	test   %ebx,%ebx
  800e50:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e55:	0f 44 d8             	cmove  %eax,%ebx
  800e58:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5d:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e60:	eb 50                	jmp    800eb2 <strtol+0x9a>
		s++;
  800e62:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e65:	bf 00 00 00 00       	mov    $0x0,%edi
  800e6a:	eb d5                	jmp    800e41 <strtol+0x29>
		s++, neg = 1;
  800e6c:	83 c1 01             	add    $0x1,%ecx
  800e6f:	bf 01 00 00 00       	mov    $0x1,%edi
  800e74:	eb cb                	jmp    800e41 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e76:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e7a:	74 0e                	je     800e8a <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e7c:	85 db                	test   %ebx,%ebx
  800e7e:	75 d8                	jne    800e58 <strtol+0x40>
		s++, base = 8;
  800e80:	83 c1 01             	add    $0x1,%ecx
  800e83:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e88:	eb ce                	jmp    800e58 <strtol+0x40>
		s += 2, base = 16;
  800e8a:	83 c1 02             	add    $0x2,%ecx
  800e8d:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e92:	eb c4                	jmp    800e58 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800e94:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e97:	89 f3                	mov    %esi,%ebx
  800e99:	80 fb 19             	cmp    $0x19,%bl
  800e9c:	77 29                	ja     800ec7 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800e9e:	0f be d2             	movsbl %dl,%edx
  800ea1:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ea4:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ea7:	7d 30                	jge    800ed9 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ea9:	83 c1 01             	add    $0x1,%ecx
  800eac:	0f af 45 10          	imul   0x10(%ebp),%eax
  800eb0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800eb2:	0f b6 11             	movzbl (%ecx),%edx
  800eb5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800eb8:	89 f3                	mov    %esi,%ebx
  800eba:	80 fb 09             	cmp    $0x9,%bl
  800ebd:	77 d5                	ja     800e94 <strtol+0x7c>
			dig = *s - '0';
  800ebf:	0f be d2             	movsbl %dl,%edx
  800ec2:	83 ea 30             	sub    $0x30,%edx
  800ec5:	eb dd                	jmp    800ea4 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800ec7:	8d 72 bf             	lea    -0x41(%edx),%esi
  800eca:	89 f3                	mov    %esi,%ebx
  800ecc:	80 fb 19             	cmp    $0x19,%bl
  800ecf:	77 08                	ja     800ed9 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ed1:	0f be d2             	movsbl %dl,%edx
  800ed4:	83 ea 37             	sub    $0x37,%edx
  800ed7:	eb cb                	jmp    800ea4 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ed9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800edd:	74 05                	je     800ee4 <strtol+0xcc>
		*endptr = (char *) s;
  800edf:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ee2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ee4:	89 c2                	mov    %eax,%edx
  800ee6:	f7 da                	neg    %edx
  800ee8:	85 ff                	test   %edi,%edi
  800eea:	0f 45 c2             	cmovne %edx,%eax
}
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5f                   	pop    %edi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    
  800ef2:	66 90                	xchg   %ax,%ax
  800ef4:	66 90                	xchg   %ax,%ax
  800ef6:	66 90                	xchg   %ax,%ax
  800ef8:	66 90                	xchg   %ax,%ax
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

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
