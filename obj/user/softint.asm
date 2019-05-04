
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 05 00 00 00       	call   800036 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $14");	// page fault
  800033:	cd 0e                	int    $0xe
}
  800035:	c3                   	ret    

00800036 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800036:	55                   	push   %ebp
  800037:	89 e5                	mov    %esp,%ebp
  800039:	56                   	push   %esi
  80003a:	53                   	push   %ebx
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800041:	e8 c6 00 00 00       	call   80010c <sys_getenvid>
  800046:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004b:	c1 e0 07             	shl    $0x7,%eax
  80004e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800053:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800058:	85 db                	test   %ebx,%ebx
  80005a:	7e 07                	jle    800063 <libmain+0x2d>
		binaryname = argv[0];
  80005c:	8b 06                	mov    (%esi),%eax
  80005e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	56                   	push   %esi
  800067:	53                   	push   %ebx
  800068:	e8 c6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006d:	e8 0a 00 00 00       	call   80007c <exit>
}
  800072:	83 c4 10             	add    $0x10,%esp
  800075:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800078:	5b                   	pop    %ebx
  800079:	5e                   	pop    %esi
  80007a:	5d                   	pop    %ebp
  80007b:	c3                   	ret    

0080007c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800082:	6a 00                	push   $0x0
  800084:	e8 42 00 00 00       	call   8000cb <sys_env_destroy>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	c9                   	leave  
  80008d:	c3                   	ret    

0080008e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008e:	55                   	push   %ebp
  80008f:	89 e5                	mov    %esp,%ebp
  800091:	57                   	push   %edi
  800092:	56                   	push   %esi
  800093:	53                   	push   %ebx
	asm volatile("int %1\n"
  800094:	b8 00 00 00 00       	mov    $0x0,%eax
  800099:	8b 55 08             	mov    0x8(%ebp),%edx
  80009c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009f:	89 c3                	mov    %eax,%ebx
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	89 c6                	mov    %eax,%esi
  8000a5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5f                   	pop    %edi
  8000aa:	5d                   	pop    %ebp
  8000ab:	c3                   	ret    

008000ac <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bc:	89 d1                	mov    %edx,%ecx
  8000be:	89 d3                	mov    %edx,%ebx
  8000c0:	89 d7                	mov    %edx,%edi
  8000c2:	89 d6                	mov    %edx,%esi
  8000c4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c6:	5b                   	pop    %ebx
  8000c7:	5e                   	pop    %esi
  8000c8:	5f                   	pop    %edi
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    

008000cb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	57                   	push   %edi
  8000cf:	56                   	push   %esi
  8000d0:	53                   	push   %ebx
  8000d1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e1:	89 cb                	mov    %ecx,%ebx
  8000e3:	89 cf                	mov    %ecx,%edi
  8000e5:	89 ce                	mov    %ecx,%esi
  8000e7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000e9:	85 c0                	test   %eax,%eax
  8000eb:	7f 08                	jg     8000f5 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	6a 03                	push   $0x3
  8000fb:	68 4a 11 80 00       	push   $0x80114a
  800100:	6a 23                	push   $0x23
  800102:	68 67 11 80 00       	push   $0x801167
  800107:	e8 2e 02 00 00       	call   80033a <_panic>

0080010c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	57                   	push   %edi
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
	asm volatile("int %1\n"
  800112:	ba 00 00 00 00       	mov    $0x0,%edx
  800117:	b8 02 00 00 00       	mov    $0x2,%eax
  80011c:	89 d1                	mov    %edx,%ecx
  80011e:	89 d3                	mov    %edx,%ebx
  800120:	89 d7                	mov    %edx,%edi
  800122:	89 d6                	mov    %edx,%esi
  800124:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5f                   	pop    %edi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <sys_yield>:

void
sys_yield(void)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	57                   	push   %edi
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
	asm volatile("int %1\n"
  800131:	ba 00 00 00 00       	mov    $0x0,%edx
  800136:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013b:	89 d1                	mov    %edx,%ecx
  80013d:	89 d3                	mov    %edx,%ebx
  80013f:	89 d7                	mov    %edx,%edi
  800141:	89 d6                	mov    %edx,%esi
  800143:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5f                   	pop    %edi
  800148:	5d                   	pop    %ebp
  800149:	c3                   	ret    

0080014a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014a:	55                   	push   %ebp
  80014b:	89 e5                	mov    %esp,%ebp
  80014d:	57                   	push   %edi
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
  800150:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800153:	be 00 00 00 00       	mov    $0x0,%esi
  800158:	8b 55 08             	mov    0x8(%ebp),%edx
  80015b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80015e:	b8 04 00 00 00       	mov    $0x4,%eax
  800163:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800166:	89 f7                	mov    %esi,%edi
  800168:	cd 30                	int    $0x30
	if(check && ret > 0)
  80016a:	85 c0                	test   %eax,%eax
  80016c:	7f 08                	jg     800176 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80016e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5f                   	pop    %edi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	50                   	push   %eax
  80017a:	6a 04                	push   $0x4
  80017c:	68 4a 11 80 00       	push   $0x80114a
  800181:	6a 23                	push   $0x23
  800183:	68 67 11 80 00       	push   $0x801167
  800188:	e8 ad 01 00 00       	call   80033a <_panic>

0080018d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	57                   	push   %edi
  800191:	56                   	push   %esi
  800192:	53                   	push   %ebx
  800193:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019c:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001a7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001aa:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ac:	85 c0                	test   %eax,%eax
  8001ae:	7f 08                	jg     8001b8 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	50                   	push   %eax
  8001bc:	6a 05                	push   $0x5
  8001be:	68 4a 11 80 00       	push   $0x80114a
  8001c3:	6a 23                	push   $0x23
  8001c5:	68 67 11 80 00       	push   $0x801167
  8001ca:	e8 6b 01 00 00       	call   80033a <_panic>

008001cf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	57                   	push   %edi
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
  8001d5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e3:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e8:	89 df                	mov    %ebx,%edi
  8001ea:	89 de                	mov    %ebx,%esi
  8001ec:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7f 08                	jg     8001fa <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f5:	5b                   	pop    %ebx
  8001f6:	5e                   	pop    %esi
  8001f7:	5f                   	pop    %edi
  8001f8:	5d                   	pop    %ebp
  8001f9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	50                   	push   %eax
  8001fe:	6a 06                	push   $0x6
  800200:	68 4a 11 80 00       	push   $0x80114a
  800205:	6a 23                	push   $0x23
  800207:	68 67 11 80 00       	push   $0x801167
  80020c:	e8 29 01 00 00       	call   80033a <_panic>

00800211 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	57                   	push   %edi
  800215:	56                   	push   %esi
  800216:	53                   	push   %ebx
  800217:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80021a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021f:	8b 55 08             	mov    0x8(%ebp),%edx
  800222:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800225:	b8 08 00 00 00       	mov    $0x8,%eax
  80022a:	89 df                	mov    %ebx,%edi
  80022c:	89 de                	mov    %ebx,%esi
  80022e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800230:	85 c0                	test   %eax,%eax
  800232:	7f 08                	jg     80023c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800234:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800237:	5b                   	pop    %ebx
  800238:	5e                   	pop    %esi
  800239:	5f                   	pop    %edi
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	50                   	push   %eax
  800240:	6a 08                	push   $0x8
  800242:	68 4a 11 80 00       	push   $0x80114a
  800247:	6a 23                	push   $0x23
  800249:	68 67 11 80 00       	push   $0x801167
  80024e:	e8 e7 00 00 00       	call   80033a <_panic>

00800253 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	57                   	push   %edi
  800257:	56                   	push   %esi
  800258:	53                   	push   %ebx
  800259:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80025c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800261:	8b 55 08             	mov    0x8(%ebp),%edx
  800264:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800267:	b8 09 00 00 00       	mov    $0x9,%eax
  80026c:	89 df                	mov    %ebx,%edi
  80026e:	89 de                	mov    %ebx,%esi
  800270:	cd 30                	int    $0x30
	if(check && ret > 0)
  800272:	85 c0                	test   %eax,%eax
  800274:	7f 08                	jg     80027e <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800276:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800279:	5b                   	pop    %ebx
  80027a:	5e                   	pop    %esi
  80027b:	5f                   	pop    %edi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	50                   	push   %eax
  800282:	6a 09                	push   $0x9
  800284:	68 4a 11 80 00       	push   $0x80114a
  800289:	6a 23                	push   $0x23
  80028b:	68 67 11 80 00       	push   $0x801167
  800290:	e8 a5 00 00 00       	call   80033a <_panic>

00800295 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	57                   	push   %edi
  800299:	56                   	push   %esi
  80029a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80029b:	8b 55 08             	mov    0x8(%ebp),%edx
  80029e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a6:	be 00 00 00 00       	mov    $0x0,%esi
  8002ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ae:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b1:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	57                   	push   %edi
  8002bc:	56                   	push   %esi
  8002bd:	53                   	push   %ebx
  8002be:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ce:	89 cb                	mov    %ecx,%ebx
  8002d0:	89 cf                	mov    %ecx,%edi
  8002d2:	89 ce                	mov    %ecx,%esi
  8002d4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d6:	85 c0                	test   %eax,%eax
  8002d8:	7f 08                	jg     8002e2 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	50                   	push   %eax
  8002e6:	6a 0c                	push   $0xc
  8002e8:	68 4a 11 80 00       	push   $0x80114a
  8002ed:	6a 23                	push   $0x23
  8002ef:	68 67 11 80 00       	push   $0x801167
  8002f4:	e8 41 00 00 00       	call   80033a <_panic>

008002f9 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  8002f9:	55                   	push   %ebp
  8002fa:	89 e5                	mov    %esp,%ebp
  8002fc:	57                   	push   %edi
  8002fd:	56                   	push   %esi
  8002fe:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800304:	8b 55 08             	mov    0x8(%ebp),%edx
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80030f:	89 df                	mov    %ebx,%edi
  800311:	89 de                	mov    %ebx,%esi
  800313:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800320:	b9 00 00 00 00       	mov    $0x0,%ecx
  800325:	8b 55 08             	mov    0x8(%ebp),%edx
  800328:	b8 0e 00 00 00       	mov    $0xe,%eax
  80032d:	89 cb                	mov    %ecx,%ebx
  80032f:	89 cf                	mov    %ecx,%edi
  800331:	89 ce                	mov    %ecx,%esi
  800333:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800335:	5b                   	pop    %ebx
  800336:	5e                   	pop    %esi
  800337:	5f                   	pop    %edi
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	56                   	push   %esi
  80033e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800342:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800348:	e8 bf fd ff ff       	call   80010c <sys_getenvid>
  80034d:	83 ec 0c             	sub    $0xc,%esp
  800350:	ff 75 0c             	pushl  0xc(%ebp)
  800353:	ff 75 08             	pushl  0x8(%ebp)
  800356:	56                   	push   %esi
  800357:	50                   	push   %eax
  800358:	68 78 11 80 00       	push   $0x801178
  80035d:	e8 b3 00 00 00       	call   800415 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800362:	83 c4 18             	add    $0x18,%esp
  800365:	53                   	push   %ebx
  800366:	ff 75 10             	pushl  0x10(%ebp)
  800369:	e8 56 00 00 00       	call   8003c4 <vcprintf>
	cprintf("\n");
  80036e:	c7 04 24 9b 11 80 00 	movl   $0x80119b,(%esp)
  800375:	e8 9b 00 00 00       	call   800415 <cprintf>
  80037a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037d:	cc                   	int3   
  80037e:	eb fd                	jmp    80037d <_panic+0x43>

00800380 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	53                   	push   %ebx
  800384:	83 ec 04             	sub    $0x4,%esp
  800387:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038a:	8b 13                	mov    (%ebx),%edx
  80038c:	8d 42 01             	lea    0x1(%edx),%eax
  80038f:	89 03                	mov    %eax,(%ebx)
  800391:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800394:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800398:	3d ff 00 00 00       	cmp    $0xff,%eax
  80039d:	74 09                	je     8003a8 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80039f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a6:	c9                   	leave  
  8003a7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003a8:	83 ec 08             	sub    $0x8,%esp
  8003ab:	68 ff 00 00 00       	push   $0xff
  8003b0:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b3:	50                   	push   %eax
  8003b4:	e8 d5 fc ff ff       	call   80008e <sys_cputs>
		b->idx = 0;
  8003b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003bf:	83 c4 10             	add    $0x10,%esp
  8003c2:	eb db                	jmp    80039f <putch+0x1f>

008003c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003cd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d4:	00 00 00 
	b.cnt = 0;
  8003d7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003de:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e1:	ff 75 0c             	pushl  0xc(%ebp)
  8003e4:	ff 75 08             	pushl  0x8(%ebp)
  8003e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ed:	50                   	push   %eax
  8003ee:	68 80 03 80 00       	push   $0x800380
  8003f3:	e8 fb 00 00 00       	call   8004f3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f8:	83 c4 08             	add    $0x8,%esp
  8003fb:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800401:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800407:	50                   	push   %eax
  800408:	e8 81 fc ff ff       	call   80008e <sys_cputs>

	return b.cnt;
}
  80040d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800413:	c9                   	leave  
  800414:	c3                   	ret    

00800415 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800415:	55                   	push   %ebp
  800416:	89 e5                	mov    %esp,%ebp
  800418:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80041e:	50                   	push   %eax
  80041f:	ff 75 08             	pushl  0x8(%ebp)
  800422:	e8 9d ff ff ff       	call   8003c4 <vcprintf>
	va_end(ap);

	return cnt;
}
  800427:	c9                   	leave  
  800428:	c3                   	ret    

00800429 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	57                   	push   %edi
  80042d:	56                   	push   %esi
  80042e:	53                   	push   %ebx
  80042f:	83 ec 1c             	sub    $0x1c,%esp
  800432:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800435:	89 d3                	mov    %edx,%ebx
  800437:	8b 75 08             	mov    0x8(%ebp),%esi
  80043a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80043d:	8b 45 10             	mov    0x10(%ebp),%eax
  800440:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800443:	89 c2                	mov    %eax,%edx
  800445:	b9 00 00 00 00       	mov    $0x0,%ecx
  80044a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800450:	39 c6                	cmp    %eax,%esi
  800452:	89 f8                	mov    %edi,%eax
  800454:	19 c8                	sbb    %ecx,%eax
  800456:	73 32                	jae    80048a <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	53                   	push   %ebx
  80045c:	83 ec 04             	sub    $0x4,%esp
  80045f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800462:	ff 75 e0             	pushl  -0x20(%ebp)
  800465:	57                   	push   %edi
  800466:	56                   	push   %esi
  800467:	e8 94 0b 00 00       	call   801000 <__umoddi3>
  80046c:	83 c4 14             	add    $0x14,%esp
  80046f:	0f be 80 9d 11 80 00 	movsbl 0x80119d(%eax),%eax
  800476:	50                   	push   %eax
  800477:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80047a:	ff d0                	call   *%eax
	return remain - 1;
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	83 e8 01             	sub    $0x1,%eax
}
  800482:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800485:	5b                   	pop    %ebx
  800486:	5e                   	pop    %esi
  800487:	5f                   	pop    %edi
  800488:	5d                   	pop    %ebp
  800489:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  80048a:	83 ec 0c             	sub    $0xc,%esp
  80048d:	ff 75 18             	pushl  0x18(%ebp)
  800490:	ff 75 14             	pushl  0x14(%ebp)
  800493:	ff 75 d8             	pushl  -0x28(%ebp)
  800496:	83 ec 08             	sub    $0x8,%esp
  800499:	51                   	push   %ecx
  80049a:	52                   	push   %edx
  80049b:	57                   	push   %edi
  80049c:	56                   	push   %esi
  80049d:	e8 4e 0a 00 00       	call   800ef0 <__udivdi3>
  8004a2:	83 c4 18             	add    $0x18,%esp
  8004a5:	52                   	push   %edx
  8004a6:	50                   	push   %eax
  8004a7:	89 da                	mov    %ebx,%edx
  8004a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ac:	e8 78 ff ff ff       	call   800429 <printnum_helper>
  8004b1:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b4:	83 c4 20             	add    $0x20,%esp
  8004b7:	eb 9f                	jmp    800458 <printnum_helper+0x2f>

008004b9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b9:	55                   	push   %ebp
  8004ba:	89 e5                	mov    %esp,%ebp
  8004bc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004bf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004c3:	8b 10                	mov    (%eax),%edx
  8004c5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c8:	73 0a                	jae    8004d4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ca:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004cd:	89 08                	mov    %ecx,(%eax)
  8004cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d2:	88 02                	mov    %al,(%edx)
}
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <printfmt>:
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004dc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004df:	50                   	push   %eax
  8004e0:	ff 75 10             	pushl  0x10(%ebp)
  8004e3:	ff 75 0c             	pushl  0xc(%ebp)
  8004e6:	ff 75 08             	pushl  0x8(%ebp)
  8004e9:	e8 05 00 00 00       	call   8004f3 <vprintfmt>
}
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	c9                   	leave  
  8004f2:	c3                   	ret    

008004f3 <vprintfmt>:
{
  8004f3:	55                   	push   %ebp
  8004f4:	89 e5                	mov    %esp,%ebp
  8004f6:	57                   	push   %edi
  8004f7:	56                   	push   %esi
  8004f8:	53                   	push   %ebx
  8004f9:	83 ec 3c             	sub    $0x3c,%esp
  8004fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800502:	8b 7d 10             	mov    0x10(%ebp),%edi
  800505:	e9 3f 05 00 00       	jmp    800a49 <vprintfmt+0x556>
		padc = ' ';
  80050a:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  80050e:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800515:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  80051c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800523:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  80052a:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800531:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800536:	8d 47 01             	lea    0x1(%edi),%eax
  800539:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80053c:	0f b6 17             	movzbl (%edi),%edx
  80053f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800542:	3c 55                	cmp    $0x55,%al
  800544:	0f 87 98 05 00 00    	ja     800ae2 <vprintfmt+0x5ef>
  80054a:	0f b6 c0             	movzbl %al,%eax
  80054d:	ff 24 85 e0 12 80 00 	jmp    *0x8012e0(,%eax,4)
  800554:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  800557:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80055b:	eb d9                	jmp    800536 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80055d:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800560:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  800567:	eb cd                	jmp    800536 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800569:	0f b6 d2             	movzbl %dl,%edx
  80056c:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80056f:	b8 00 00 00 00       	mov    $0x0,%eax
  800574:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  800577:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80057a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80057e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800581:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800584:	83 fb 09             	cmp    $0x9,%ebx
  800587:	77 5c                	ja     8005e5 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  800589:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80058c:	eb e9                	jmp    800577 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  800591:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  800595:	eb 9f                	jmp    800536 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 40 04             	lea    0x4(%eax),%eax
  8005a5:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8005ab:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005af:	79 85                	jns    800536 <vprintfmt+0x43>
				width = precision, precision = -1;
  8005b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005be:	e9 73 ff ff ff       	jmp    800536 <vprintfmt+0x43>
  8005c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c6:	85 c0                	test   %eax,%eax
  8005c8:	0f 48 c1             	cmovs  %ecx,%eax
  8005cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005d1:	e9 60 ff ff ff       	jmp    800536 <vprintfmt+0x43>
  8005d6:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8005d9:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8005e0:	e9 51 ff ff ff       	jmp    800536 <vprintfmt+0x43>
  8005e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005eb:	eb be                	jmp    8005ab <vprintfmt+0xb8>
			lflag++;
  8005ed:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  8005f4:	e9 3d ff ff ff       	jmp    800536 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 78 04             	lea    0x4(%eax),%edi
  8005ff:	83 ec 08             	sub    $0x8,%esp
  800602:	56                   	push   %esi
  800603:	ff 30                	pushl  (%eax)
  800605:	ff d3                	call   *%ebx
			break;
  800607:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80060a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80060d:	e9 34 04 00 00       	jmp    800a46 <vprintfmt+0x553>
			err = va_arg(ap, int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 78 04             	lea    0x4(%eax),%edi
  800618:	8b 00                	mov    (%eax),%eax
  80061a:	99                   	cltd   
  80061b:	31 d0                	xor    %edx,%eax
  80061d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061f:	83 f8 08             	cmp    $0x8,%eax
  800622:	7f 23                	jg     800647 <vprintfmt+0x154>
  800624:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  80062b:	85 d2                	test   %edx,%edx
  80062d:	74 18                	je     800647 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  80062f:	52                   	push   %edx
  800630:	68 be 11 80 00       	push   $0x8011be
  800635:	56                   	push   %esi
  800636:	53                   	push   %ebx
  800637:	e8 9a fe ff ff       	call   8004d6 <printfmt>
  80063c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80063f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800642:	e9 ff 03 00 00       	jmp    800a46 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  800647:	50                   	push   %eax
  800648:	68 b5 11 80 00       	push   $0x8011b5
  80064d:	56                   	push   %esi
  80064e:	53                   	push   %ebx
  80064f:	e8 82 fe ff ff       	call   8004d6 <printfmt>
  800654:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800657:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80065a:	e9 e7 03 00 00       	jmp    800a46 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	83 c0 04             	add    $0x4,%eax
  800665:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80066d:	85 c9                	test   %ecx,%ecx
  80066f:	b8 ae 11 80 00       	mov    $0x8011ae,%eax
  800674:	0f 45 c1             	cmovne %ecx,%eax
  800677:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80067a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80067e:	7e 06                	jle    800686 <vprintfmt+0x193>
  800680:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800684:	75 0d                	jne    800693 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800686:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800689:	89 c7                	mov    %eax,%edi
  80068b:	03 45 d8             	add    -0x28(%ebp),%eax
  80068e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800691:	eb 53                	jmp    8006e6 <vprintfmt+0x1f3>
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	ff 75 e0             	pushl  -0x20(%ebp)
  800699:	50                   	push   %eax
  80069a:	e8 eb 04 00 00       	call   800b8a <strnlen>
  80069f:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006a2:	29 c1                	sub    %eax,%ecx
  8006a4:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006ac:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8006b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b3:	eb 0f                	jmp    8006c4 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	56                   	push   %esi
  8006b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8006bc:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8006be:	83 ef 01             	sub    $0x1,%edi
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	85 ff                	test   %edi,%edi
  8006c6:	7f ed                	jg     8006b5 <vprintfmt+0x1c2>
  8006c8:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8006cb:	85 c9                	test   %ecx,%ecx
  8006cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d2:	0f 49 c1             	cmovns %ecx,%eax
  8006d5:	29 c1                	sub    %eax,%ecx
  8006d7:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006da:	eb aa                	jmp    800686 <vprintfmt+0x193>
					putch(ch, putdat);
  8006dc:	83 ec 08             	sub    $0x8,%esp
  8006df:	56                   	push   %esi
  8006e0:	52                   	push   %edx
  8006e1:	ff d3                	call   *%ebx
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006e9:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006eb:	83 c7 01             	add    $0x1,%edi
  8006ee:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f2:	0f be d0             	movsbl %al,%edx
  8006f5:	85 d2                	test   %edx,%edx
  8006f7:	74 2e                	je     800727 <vprintfmt+0x234>
  8006f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006fd:	78 06                	js     800705 <vprintfmt+0x212>
  8006ff:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800703:	78 1e                	js     800723 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800705:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800709:	74 d1                	je     8006dc <vprintfmt+0x1e9>
  80070b:	0f be c0             	movsbl %al,%eax
  80070e:	83 e8 20             	sub    $0x20,%eax
  800711:	83 f8 5e             	cmp    $0x5e,%eax
  800714:	76 c6                	jbe    8006dc <vprintfmt+0x1e9>
					putch('?', putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	56                   	push   %esi
  80071a:	6a 3f                	push   $0x3f
  80071c:	ff d3                	call   *%ebx
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	eb c3                	jmp    8006e6 <vprintfmt+0x1f3>
  800723:	89 cf                	mov    %ecx,%edi
  800725:	eb 02                	jmp    800729 <vprintfmt+0x236>
  800727:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  800729:	85 ff                	test   %edi,%edi
  80072b:	7e 10                	jle    80073d <vprintfmt+0x24a>
				putch(' ', putdat);
  80072d:	83 ec 08             	sub    $0x8,%esp
  800730:	56                   	push   %esi
  800731:	6a 20                	push   $0x20
  800733:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800735:	83 ef 01             	sub    $0x1,%edi
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	eb ec                	jmp    800729 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  80073d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800740:	89 45 14             	mov    %eax,0x14(%ebp)
  800743:	e9 fe 02 00 00       	jmp    800a46 <vprintfmt+0x553>
	if (lflag >= 2)
  800748:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80074c:	7f 21                	jg     80076f <vprintfmt+0x27c>
	else if (lflag)
  80074e:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800752:	74 79                	je     8007cd <vprintfmt+0x2da>
		return va_arg(*ap, long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8b 00                	mov    (%eax),%eax
  800759:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80075c:	89 c1                	mov    %eax,%ecx
  80075e:	c1 f9 1f             	sar    $0x1f,%ecx
  800761:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800764:	8b 45 14             	mov    0x14(%ebp),%eax
  800767:	8d 40 04             	lea    0x4(%eax),%eax
  80076a:	89 45 14             	mov    %eax,0x14(%ebp)
  80076d:	eb 17                	jmp    800786 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8b 50 04             	mov    0x4(%eax),%edx
  800775:	8b 00                	mov    (%eax),%eax
  800777:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80077a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80077d:	8b 45 14             	mov    0x14(%ebp),%eax
  800780:	8d 40 08             	lea    0x8(%eax),%eax
  800783:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  800786:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800789:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80078c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80078f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  800792:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800796:	78 50                	js     8007e8 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  800798:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80079b:	c1 fa 1f             	sar    $0x1f,%edx
  80079e:	89 d0                	mov    %edx,%eax
  8007a0:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8007a3:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8007a6:	85 d2                	test   %edx,%edx
  8007a8:	0f 89 14 02 00 00    	jns    8009c2 <vprintfmt+0x4cf>
  8007ae:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007b2:	0f 84 0a 02 00 00    	je     8009c2 <vprintfmt+0x4cf>
				putch('+', putdat);
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	56                   	push   %esi
  8007bc:	6a 2b                	push   $0x2b
  8007be:	ff d3                	call   *%ebx
  8007c0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c8:	e9 5c 01 00 00       	jmp    800929 <vprintfmt+0x436>
		return va_arg(*ap, int);
  8007cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d0:	8b 00                	mov    (%eax),%eax
  8007d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007d5:	89 c1                	mov    %eax,%ecx
  8007d7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007da:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	8d 40 04             	lea    0x4(%eax),%eax
  8007e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e6:	eb 9e                	jmp    800786 <vprintfmt+0x293>
				putch('-', putdat);
  8007e8:	83 ec 08             	sub    $0x8,%esp
  8007eb:	56                   	push   %esi
  8007ec:	6a 2d                	push   $0x2d
  8007ee:	ff d3                	call   *%ebx
				num = -(long long) num;
  8007f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007f3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007f6:	f7 d8                	neg    %eax
  8007f8:	83 d2 00             	adc    $0x0,%edx
  8007fb:	f7 da                	neg    %edx
  8007fd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800800:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800803:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800806:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080b:	e9 19 01 00 00       	jmp    800929 <vprintfmt+0x436>
	if (lflag >= 2)
  800810:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800814:	7f 29                	jg     80083f <vprintfmt+0x34c>
	else if (lflag)
  800816:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80081a:	74 44                	je     800860 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  80081c:	8b 45 14             	mov    0x14(%ebp),%eax
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	ba 00 00 00 00       	mov    $0x0,%edx
  800826:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800829:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8d 40 04             	lea    0x4(%eax),%eax
  800832:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800835:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083a:	e9 ea 00 00 00       	jmp    800929 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  80083f:	8b 45 14             	mov    0x14(%ebp),%eax
  800842:	8b 50 04             	mov    0x4(%eax),%edx
  800845:	8b 00                	mov    (%eax),%eax
  800847:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80084a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80084d:	8b 45 14             	mov    0x14(%ebp),%eax
  800850:	8d 40 08             	lea    0x8(%eax),%eax
  800853:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800856:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085b:	e9 c9 00 00 00       	jmp    800929 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
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
  80087e:	e9 a6 00 00 00       	jmp    800929 <vprintfmt+0x436>
			putch('0', putdat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	56                   	push   %esi
  800887:	6a 30                	push   $0x30
  800889:	ff d3                	call   *%ebx
	if (lflag >= 2)
  80088b:	83 c4 10             	add    $0x10,%esp
  80088e:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800892:	7f 26                	jg     8008ba <vprintfmt+0x3c7>
	else if (lflag)
  800894:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800898:	74 3e                	je     8008d8 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  80089a:	8b 45 14             	mov    0x14(%ebp),%eax
  80089d:	8b 00                	mov    (%eax),%eax
  80089f:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008a7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ad:	8d 40 04             	lea    0x4(%eax),%eax
  8008b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008b3:	b8 08 00 00 00       	mov    $0x8,%eax
  8008b8:	eb 6f                	jmp    800929 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8008ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bd:	8b 50 04             	mov    0x4(%eax),%edx
  8008c0:	8b 00                	mov    (%eax),%eax
  8008c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008c5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cb:	8d 40 08             	lea    0x8(%eax),%eax
  8008ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008d1:	b8 08 00 00 00       	mov    $0x8,%eax
  8008d6:	eb 51                	jmp    800929 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8008d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008db:	8b 00                	mov    (%eax),%eax
  8008dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008e5:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008eb:	8d 40 04             	lea    0x4(%eax),%eax
  8008ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008f1:	b8 08 00 00 00       	mov    $0x8,%eax
  8008f6:	eb 31                	jmp    800929 <vprintfmt+0x436>
			putch('0', putdat);
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	56                   	push   %esi
  8008fc:	6a 30                	push   $0x30
  8008fe:	ff d3                	call   *%ebx
			putch('x', putdat);
  800900:	83 c4 08             	add    $0x8,%esp
  800903:	56                   	push   %esi
  800904:	6a 78                	push   $0x78
  800906:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800908:	8b 45 14             	mov    0x14(%ebp),%eax
  80090b:	8b 00                	mov    (%eax),%eax
  80090d:	ba 00 00 00 00       	mov    $0x0,%edx
  800912:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800915:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800918:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80091b:	8b 45 14             	mov    0x14(%ebp),%eax
  80091e:	8d 40 04             	lea    0x4(%eax),%eax
  800921:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800924:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800929:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  80092d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800930:	89 c1                	mov    %eax,%ecx
  800932:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800935:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800938:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  80093d:	89 c2                	mov    %eax,%edx
  80093f:	39 c1                	cmp    %eax,%ecx
  800941:	0f 87 85 00 00 00    	ja     8009cc <vprintfmt+0x4d9>
		tmp /= base;
  800947:	89 d0                	mov    %edx,%eax
  800949:	ba 00 00 00 00       	mov    $0x0,%edx
  80094e:	f7 f1                	div    %ecx
		len++;
  800950:	83 c7 01             	add    $0x1,%edi
  800953:	eb e8                	jmp    80093d <vprintfmt+0x44a>
	if (lflag >= 2)
  800955:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800959:	7f 26                	jg     800981 <vprintfmt+0x48e>
	else if (lflag)
  80095b:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80095f:	74 3e                	je     80099f <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800961:	8b 45 14             	mov    0x14(%ebp),%eax
  800964:	8b 00                	mov    (%eax),%eax
  800966:	ba 00 00 00 00       	mov    $0x0,%edx
  80096b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80096e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800971:	8b 45 14             	mov    0x14(%ebp),%eax
  800974:	8d 40 04             	lea    0x4(%eax),%eax
  800977:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80097a:	b8 10 00 00 00       	mov    $0x10,%eax
  80097f:	eb a8                	jmp    800929 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800981:	8b 45 14             	mov    0x14(%ebp),%eax
  800984:	8b 50 04             	mov    0x4(%eax),%edx
  800987:	8b 00                	mov    (%eax),%eax
  800989:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80098c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80098f:	8b 45 14             	mov    0x14(%ebp),%eax
  800992:	8d 40 08             	lea    0x8(%eax),%eax
  800995:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800998:	b8 10 00 00 00       	mov    $0x10,%eax
  80099d:	eb 8a                	jmp    800929 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  80099f:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a2:	8b 00                	mov    (%eax),%eax
  8009a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009ac:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 40 04             	lea    0x4(%eax),%eax
  8009b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009b8:	b8 10 00 00 00       	mov    $0x10,%eax
  8009bd:	e9 67 ff ff ff       	jmp    800929 <vprintfmt+0x436>
			base = 10;
  8009c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009c7:	e9 5d ff ff ff       	jmp    800929 <vprintfmt+0x436>
  8009cc:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8009cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009d2:	29 f8                	sub    %edi,%eax
  8009d4:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8009d6:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8009da:	74 15                	je     8009f1 <vprintfmt+0x4fe>
		while (width > 0) {
  8009dc:	85 ff                	test   %edi,%edi
  8009de:	7e 48                	jle    800a28 <vprintfmt+0x535>
			putch(padc, putdat);
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	56                   	push   %esi
  8009e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8009e7:	ff d3                	call   *%ebx
			width--;
  8009e9:	83 ef 01             	sub    $0x1,%edi
  8009ec:	83 c4 10             	add    $0x10,%esp
  8009ef:	eb eb                	jmp    8009dc <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  8009f1:	83 ec 0c             	sub    $0xc,%esp
  8009f4:	6a 2d                	push   $0x2d
  8009f6:	ff 75 cc             	pushl  -0x34(%ebp)
  8009f9:	ff 75 c8             	pushl  -0x38(%ebp)
  8009fc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8009ff:	ff 75 d0             	pushl  -0x30(%ebp)
  800a02:	89 f2                	mov    %esi,%edx
  800a04:	89 d8                	mov    %ebx,%eax
  800a06:	e8 1e fa ff ff       	call   800429 <printnum_helper>
		width -= len;
  800a0b:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a0e:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800a11:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800a14:	85 ff                	test   %edi,%edi
  800a16:	7e 2e                	jle    800a46 <vprintfmt+0x553>
			putch(padc, putdat);
  800a18:	83 ec 08             	sub    $0x8,%esp
  800a1b:	56                   	push   %esi
  800a1c:	6a 20                	push   $0x20
  800a1e:	ff d3                	call   *%ebx
			width--;
  800a20:	83 ef 01             	sub    $0x1,%edi
  800a23:	83 c4 10             	add    $0x10,%esp
  800a26:	eb ec                	jmp    800a14 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	ff 75 e0             	pushl  -0x20(%ebp)
  800a2e:	ff 75 cc             	pushl  -0x34(%ebp)
  800a31:	ff 75 c8             	pushl  -0x38(%ebp)
  800a34:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a37:	ff 75 d0             	pushl  -0x30(%ebp)
  800a3a:	89 f2                	mov    %esi,%edx
  800a3c:	89 d8                	mov    %ebx,%eax
  800a3e:	e8 e6 f9 ff ff       	call   800429 <printnum_helper>
  800a43:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800a46:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a49:	83 c7 01             	add    $0x1,%edi
  800a4c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a50:	83 f8 25             	cmp    $0x25,%eax
  800a53:	0f 84 b1 fa ff ff    	je     80050a <vprintfmt+0x17>
			if (ch == '\0')
  800a59:	85 c0                	test   %eax,%eax
  800a5b:	0f 84 a1 00 00 00    	je     800b02 <vprintfmt+0x60f>
			putch(ch, putdat);
  800a61:	83 ec 08             	sub    $0x8,%esp
  800a64:	56                   	push   %esi
  800a65:	50                   	push   %eax
  800a66:	ff d3                	call   *%ebx
  800a68:	83 c4 10             	add    $0x10,%esp
  800a6b:	eb dc                	jmp    800a49 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800a6d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a70:	83 c0 04             	add    $0x4,%eax
  800a73:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a76:	8b 45 14             	mov    0x14(%ebp),%eax
  800a79:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800a7b:	85 ff                	test   %edi,%edi
  800a7d:	74 15                	je     800a94 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800a7f:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800a85:	7f 29                	jg     800ab0 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800a87:	0f b6 06             	movzbl (%esi),%eax
  800a8a:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800a8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a8f:	89 45 14             	mov    %eax,0x14(%ebp)
  800a92:	eb b2                	jmp    800a46 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800a94:	68 54 12 80 00       	push   $0x801254
  800a99:	68 be 11 80 00       	push   $0x8011be
  800a9e:	56                   	push   %esi
  800a9f:	53                   	push   %ebx
  800aa0:	e8 31 fa ff ff       	call   8004d6 <printfmt>
  800aa5:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800aa8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800aab:	89 45 14             	mov    %eax,0x14(%ebp)
  800aae:	eb 96                	jmp    800a46 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800ab0:	68 8c 12 80 00       	push   $0x80128c
  800ab5:	68 be 11 80 00       	push   $0x8011be
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
  800abc:	e8 15 fa ff ff       	call   8004d6 <printfmt>
				*res = -1;
  800ac1:	c6 07 ff             	movb   $0xff,(%edi)
  800ac4:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800ac7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800aca:	89 45 14             	mov    %eax,0x14(%ebp)
  800acd:	e9 74 ff ff ff       	jmp    800a46 <vprintfmt+0x553>
			putch(ch, putdat);
  800ad2:	83 ec 08             	sub    $0x8,%esp
  800ad5:	56                   	push   %esi
  800ad6:	6a 25                	push   $0x25
  800ad8:	ff d3                	call   *%ebx
			break;
  800ada:	83 c4 10             	add    $0x10,%esp
  800add:	e9 64 ff ff ff       	jmp    800a46 <vprintfmt+0x553>
			putch('%', putdat);
  800ae2:	83 ec 08             	sub    $0x8,%esp
  800ae5:	56                   	push   %esi
  800ae6:	6a 25                	push   $0x25
  800ae8:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aea:	83 c4 10             	add    $0x10,%esp
  800aed:	89 f8                	mov    %edi,%eax
  800aef:	eb 03                	jmp    800af4 <vprintfmt+0x601>
  800af1:	83 e8 01             	sub    $0x1,%eax
  800af4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800af8:	75 f7                	jne    800af1 <vprintfmt+0x5fe>
  800afa:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800afd:	e9 44 ff ff ff       	jmp    800a46 <vprintfmt+0x553>
}
  800b02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	83 ec 18             	sub    $0x18,%esp
  800b10:	8b 45 08             	mov    0x8(%ebp),%eax
  800b13:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b16:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b19:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b1d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b27:	85 c0                	test   %eax,%eax
  800b29:	74 26                	je     800b51 <vsnprintf+0x47>
  800b2b:	85 d2                	test   %edx,%edx
  800b2d:	7e 22                	jle    800b51 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b2f:	ff 75 14             	pushl  0x14(%ebp)
  800b32:	ff 75 10             	pushl  0x10(%ebp)
  800b35:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b38:	50                   	push   %eax
  800b39:	68 b9 04 80 00       	push   $0x8004b9
  800b3e:	e8 b0 f9 ff ff       	call   8004f3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b46:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b4c:	83 c4 10             	add    $0x10,%esp
}
  800b4f:	c9                   	leave  
  800b50:	c3                   	ret    
		return -E_INVAL;
  800b51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b56:	eb f7                	jmp    800b4f <vsnprintf+0x45>

00800b58 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b5e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b61:	50                   	push   %eax
  800b62:	ff 75 10             	pushl  0x10(%ebp)
  800b65:	ff 75 0c             	pushl  0xc(%ebp)
  800b68:	ff 75 08             	pushl  0x8(%ebp)
  800b6b:	e8 9a ff ff ff       	call   800b0a <vsnprintf>
	va_end(ap);

	return rc;
}
  800b70:	c9                   	leave  
  800b71:	c3                   	ret    

00800b72 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b81:	74 05                	je     800b88 <strlen+0x16>
		n++;
  800b83:	83 c0 01             	add    $0x1,%eax
  800b86:	eb f5                	jmp    800b7d <strlen+0xb>
	return n;
}
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    

00800b8a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b90:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b93:	ba 00 00 00 00       	mov    $0x0,%edx
  800b98:	39 c2                	cmp    %eax,%edx
  800b9a:	74 0d                	je     800ba9 <strnlen+0x1f>
  800b9c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ba0:	74 05                	je     800ba7 <strnlen+0x1d>
		n++;
  800ba2:	83 c2 01             	add    $0x1,%edx
  800ba5:	eb f1                	jmp    800b98 <strnlen+0xe>
  800ba7:	89 d0                	mov    %edx,%eax
	return n;
}
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	53                   	push   %ebx
  800baf:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bbe:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bc1:	83 c2 01             	add    $0x1,%edx
  800bc4:	84 c9                	test   %cl,%cl
  800bc6:	75 f2                	jne    800bba <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 10             	sub    $0x10,%esp
  800bd2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bd5:	53                   	push   %ebx
  800bd6:	e8 97 ff ff ff       	call   800b72 <strlen>
  800bdb:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800bde:	ff 75 0c             	pushl  0xc(%ebp)
  800be1:	01 d8                	add    %ebx,%eax
  800be3:	50                   	push   %eax
  800be4:	e8 c2 ff ff ff       	call   800bab <strcpy>
	return dst;
}
  800be9:	89 d8                	mov    %ebx,%eax
  800beb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bee:	c9                   	leave  
  800bef:	c3                   	ret    

00800bf0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
  800bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfb:	89 c6                	mov    %eax,%esi
  800bfd:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c00:	89 c2                	mov    %eax,%edx
  800c02:	39 f2                	cmp    %esi,%edx
  800c04:	74 11                	je     800c17 <strncpy+0x27>
		*dst++ = *src;
  800c06:	83 c2 01             	add    $0x1,%edx
  800c09:	0f b6 19             	movzbl (%ecx),%ebx
  800c0c:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c0f:	80 fb 01             	cmp    $0x1,%bl
  800c12:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800c15:	eb eb                	jmp    800c02 <strncpy+0x12>
	}
	return ret;
}
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	8b 75 08             	mov    0x8(%ebp),%esi
  800c23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c26:	8b 55 10             	mov    0x10(%ebp),%edx
  800c29:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c2b:	85 d2                	test   %edx,%edx
  800c2d:	74 21                	je     800c50 <strlcpy+0x35>
  800c2f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c33:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800c35:	39 c2                	cmp    %eax,%edx
  800c37:	74 14                	je     800c4d <strlcpy+0x32>
  800c39:	0f b6 19             	movzbl (%ecx),%ebx
  800c3c:	84 db                	test   %bl,%bl
  800c3e:	74 0b                	je     800c4b <strlcpy+0x30>
			*dst++ = *src++;
  800c40:	83 c1 01             	add    $0x1,%ecx
  800c43:	83 c2 01             	add    $0x1,%edx
  800c46:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c49:	eb ea                	jmp    800c35 <strlcpy+0x1a>
  800c4b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c4d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c50:	29 f0                	sub    %esi,%eax
}
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c5f:	0f b6 01             	movzbl (%ecx),%eax
  800c62:	84 c0                	test   %al,%al
  800c64:	74 0c                	je     800c72 <strcmp+0x1c>
  800c66:	3a 02                	cmp    (%edx),%al
  800c68:	75 08                	jne    800c72 <strcmp+0x1c>
		p++, q++;
  800c6a:	83 c1 01             	add    $0x1,%ecx
  800c6d:	83 c2 01             	add    $0x1,%edx
  800c70:	eb ed                	jmp    800c5f <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c72:	0f b6 c0             	movzbl %al,%eax
  800c75:	0f b6 12             	movzbl (%edx),%edx
  800c78:	29 d0                	sub    %edx,%eax
}
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	53                   	push   %ebx
  800c80:	8b 45 08             	mov    0x8(%ebp),%eax
  800c83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c86:	89 c3                	mov    %eax,%ebx
  800c88:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c8b:	eb 06                	jmp    800c93 <strncmp+0x17>
		n--, p++, q++;
  800c8d:	83 c0 01             	add    $0x1,%eax
  800c90:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c93:	39 d8                	cmp    %ebx,%eax
  800c95:	74 16                	je     800cad <strncmp+0x31>
  800c97:	0f b6 08             	movzbl (%eax),%ecx
  800c9a:	84 c9                	test   %cl,%cl
  800c9c:	74 04                	je     800ca2 <strncmp+0x26>
  800c9e:	3a 0a                	cmp    (%edx),%cl
  800ca0:	74 eb                	je     800c8d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca2:	0f b6 00             	movzbl (%eax),%eax
  800ca5:	0f b6 12             	movzbl (%edx),%edx
  800ca8:	29 d0                	sub    %edx,%eax
}
  800caa:	5b                   	pop    %ebx
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    
		return 0;
  800cad:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb2:	eb f6                	jmp    800caa <strncmp+0x2e>

00800cb4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cbe:	0f b6 10             	movzbl (%eax),%edx
  800cc1:	84 d2                	test   %dl,%dl
  800cc3:	74 09                	je     800cce <strchr+0x1a>
		if (*s == c)
  800cc5:	38 ca                	cmp    %cl,%dl
  800cc7:	74 0a                	je     800cd3 <strchr+0x1f>
	for (; *s; s++)
  800cc9:	83 c0 01             	add    $0x1,%eax
  800ccc:	eb f0                	jmp    800cbe <strchr+0xa>
			return (char *) s;
	return 0;
  800cce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cdf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ce2:	38 ca                	cmp    %cl,%dl
  800ce4:	74 09                	je     800cef <strfind+0x1a>
  800ce6:	84 d2                	test   %dl,%dl
  800ce8:	74 05                	je     800cef <strfind+0x1a>
	for (; *s; s++)
  800cea:	83 c0 01             	add    $0x1,%eax
  800ced:	eb f0                	jmp    800cdf <strfind+0xa>
			break;
	return (char *) s;
}
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	57                   	push   %edi
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cfa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800cfd:	85 c9                	test   %ecx,%ecx
  800cff:	74 31                	je     800d32 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d01:	89 f8                	mov    %edi,%eax
  800d03:	09 c8                	or     %ecx,%eax
  800d05:	a8 03                	test   $0x3,%al
  800d07:	75 23                	jne    800d2c <memset+0x3b>
		c &= 0xFF;
  800d09:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d0d:	89 d3                	mov    %edx,%ebx
  800d0f:	c1 e3 08             	shl    $0x8,%ebx
  800d12:	89 d0                	mov    %edx,%eax
  800d14:	c1 e0 18             	shl    $0x18,%eax
  800d17:	89 d6                	mov    %edx,%esi
  800d19:	c1 e6 10             	shl    $0x10,%esi
  800d1c:	09 f0                	or     %esi,%eax
  800d1e:	09 c2                	or     %eax,%edx
  800d20:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d22:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d25:	89 d0                	mov    %edx,%eax
  800d27:	fc                   	cld    
  800d28:	f3 ab                	rep stos %eax,%es:(%edi)
  800d2a:	eb 06                	jmp    800d32 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2f:	fc                   	cld    
  800d30:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d32:	89 f8                	mov    %edi,%eax
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d47:	39 c6                	cmp    %eax,%esi
  800d49:	73 32                	jae    800d7d <memmove+0x44>
  800d4b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d4e:	39 c2                	cmp    %eax,%edx
  800d50:	76 2b                	jbe    800d7d <memmove+0x44>
		s += n;
		d += n;
  800d52:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d55:	89 fe                	mov    %edi,%esi
  800d57:	09 ce                	or     %ecx,%esi
  800d59:	09 d6                	or     %edx,%esi
  800d5b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d61:	75 0e                	jne    800d71 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d63:	83 ef 04             	sub    $0x4,%edi
  800d66:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d69:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d6c:	fd                   	std    
  800d6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d6f:	eb 09                	jmp    800d7a <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d71:	83 ef 01             	sub    $0x1,%edi
  800d74:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d77:	fd                   	std    
  800d78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d7a:	fc                   	cld    
  800d7b:	eb 1a                	jmp    800d97 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d7d:	89 c2                	mov    %eax,%edx
  800d7f:	09 ca                	or     %ecx,%edx
  800d81:	09 f2                	or     %esi,%edx
  800d83:	f6 c2 03             	test   $0x3,%dl
  800d86:	75 0a                	jne    800d92 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d88:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d8b:	89 c7                	mov    %eax,%edi
  800d8d:	fc                   	cld    
  800d8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d90:	eb 05                	jmp    800d97 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800d92:	89 c7                	mov    %eax,%edi
  800d94:	fc                   	cld    
  800d95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800da1:	ff 75 10             	pushl  0x10(%ebp)
  800da4:	ff 75 0c             	pushl  0xc(%ebp)
  800da7:	ff 75 08             	pushl  0x8(%ebp)
  800daa:	e8 8a ff ff ff       	call   800d39 <memmove>
}
  800daf:	c9                   	leave  
  800db0:	c3                   	ret    

00800db1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	56                   	push   %esi
  800db5:	53                   	push   %ebx
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dbc:	89 c6                	mov    %eax,%esi
  800dbe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dc1:	39 f0                	cmp    %esi,%eax
  800dc3:	74 1c                	je     800de1 <memcmp+0x30>
		if (*s1 != *s2)
  800dc5:	0f b6 08             	movzbl (%eax),%ecx
  800dc8:	0f b6 1a             	movzbl (%edx),%ebx
  800dcb:	38 d9                	cmp    %bl,%cl
  800dcd:	75 08                	jne    800dd7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800dcf:	83 c0 01             	add    $0x1,%eax
  800dd2:	83 c2 01             	add    $0x1,%edx
  800dd5:	eb ea                	jmp    800dc1 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800dd7:	0f b6 c1             	movzbl %cl,%eax
  800dda:	0f b6 db             	movzbl %bl,%ebx
  800ddd:	29 d8                	sub    %ebx,%eax
  800ddf:	eb 05                	jmp    800de6 <memcmp+0x35>
	}

	return 0;
  800de1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    

00800dea <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800df3:	89 c2                	mov    %eax,%edx
  800df5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df8:	39 d0                	cmp    %edx,%eax
  800dfa:	73 09                	jae    800e05 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dfc:	38 08                	cmp    %cl,(%eax)
  800dfe:	74 05                	je     800e05 <memfind+0x1b>
	for (; s < ends; s++)
  800e00:	83 c0 01             	add    $0x1,%eax
  800e03:	eb f3                	jmp    800df8 <memfind+0xe>
			break;
	return (void *) s;
}
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e13:	eb 03                	jmp    800e18 <strtol+0x11>
		s++;
  800e15:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e18:	0f b6 01             	movzbl (%ecx),%eax
  800e1b:	3c 20                	cmp    $0x20,%al
  800e1d:	74 f6                	je     800e15 <strtol+0xe>
  800e1f:	3c 09                	cmp    $0x9,%al
  800e21:	74 f2                	je     800e15 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e23:	3c 2b                	cmp    $0x2b,%al
  800e25:	74 2a                	je     800e51 <strtol+0x4a>
	int neg = 0;
  800e27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e2c:	3c 2d                	cmp    $0x2d,%al
  800e2e:	74 2b                	je     800e5b <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e30:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e36:	75 0f                	jne    800e47 <strtol+0x40>
  800e38:	80 39 30             	cmpb   $0x30,(%ecx)
  800e3b:	74 28                	je     800e65 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e3d:	85 db                	test   %ebx,%ebx
  800e3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e44:	0f 44 d8             	cmove  %eax,%ebx
  800e47:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e4f:	eb 50                	jmp    800ea1 <strtol+0x9a>
		s++;
  800e51:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e54:	bf 00 00 00 00       	mov    $0x0,%edi
  800e59:	eb d5                	jmp    800e30 <strtol+0x29>
		s++, neg = 1;
  800e5b:	83 c1 01             	add    $0x1,%ecx
  800e5e:	bf 01 00 00 00       	mov    $0x1,%edi
  800e63:	eb cb                	jmp    800e30 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e65:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e69:	74 0e                	je     800e79 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e6b:	85 db                	test   %ebx,%ebx
  800e6d:	75 d8                	jne    800e47 <strtol+0x40>
		s++, base = 8;
  800e6f:	83 c1 01             	add    $0x1,%ecx
  800e72:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e77:	eb ce                	jmp    800e47 <strtol+0x40>
		s += 2, base = 16;
  800e79:	83 c1 02             	add    $0x2,%ecx
  800e7c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e81:	eb c4                	jmp    800e47 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800e83:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e86:	89 f3                	mov    %esi,%ebx
  800e88:	80 fb 19             	cmp    $0x19,%bl
  800e8b:	77 29                	ja     800eb6 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800e8d:	0f be d2             	movsbl %dl,%edx
  800e90:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e93:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e96:	7d 30                	jge    800ec8 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800e98:	83 c1 01             	add    $0x1,%ecx
  800e9b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e9f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ea1:	0f b6 11             	movzbl (%ecx),%edx
  800ea4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ea7:	89 f3                	mov    %esi,%ebx
  800ea9:	80 fb 09             	cmp    $0x9,%bl
  800eac:	77 d5                	ja     800e83 <strtol+0x7c>
			dig = *s - '0';
  800eae:	0f be d2             	movsbl %dl,%edx
  800eb1:	83 ea 30             	sub    $0x30,%edx
  800eb4:	eb dd                	jmp    800e93 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800eb6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800eb9:	89 f3                	mov    %esi,%ebx
  800ebb:	80 fb 19             	cmp    $0x19,%bl
  800ebe:	77 08                	ja     800ec8 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ec0:	0f be d2             	movsbl %dl,%edx
  800ec3:	83 ea 37             	sub    $0x37,%edx
  800ec6:	eb cb                	jmp    800e93 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ec8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ecc:	74 05                	je     800ed3 <strtol+0xcc>
		*endptr = (char *) s;
  800ece:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ed3:	89 c2                	mov    %eax,%edx
  800ed5:	f7 da                	neg    %edx
  800ed7:	85 ff                	test   %edi,%edi
  800ed9:	0f 45 c2             	cmovne %edx,%eax
}
  800edc:	5b                   	pop    %ebx
  800edd:	5e                   	pop    %esi
  800ede:	5f                   	pop    %edi
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    
  800ee1:	66 90                	xchg   %ax,%ax
  800ee3:	66 90                	xchg   %ax,%ax
  800ee5:	66 90                	xchg   %ax,%ax
  800ee7:	66 90                	xchg   %ax,%ax
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
