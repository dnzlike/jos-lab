
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void
umain(int argc, char **argv)
{
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800033:	66 b8 28 00          	mov    $0x28,%ax
  800037:	8e d8                	mov    %eax,%ds
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 c6 00 00 00       	call   800110 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	c1 e0 07             	shl    $0x7,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 42 00 00 00       	call   8000cf <sys_env_destroy>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
	asm volatile("int %1\n"
  800098:	b8 00 00 00 00       	mov    $0x0,%eax
  80009d:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	89 c3                	mov    %eax,%ebx
  8000a5:	89 c7                	mov    %eax,%edi
  8000a7:	89 c6                	mov    %eax,%esi
  8000a9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5f                   	pop    %edi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c0:	89 d1                	mov    %edx,%ecx
  8000c2:	89 d3                	mov    %edx,%ebx
  8000c4:	89 d7                	mov    %edx,%edi
  8000c6:	89 d6                	mov    %edx,%esi
  8000c8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e5:	89 cb                	mov    %ecx,%ebx
  8000e7:	89 cf                	mov    %ecx,%edi
  8000e9:	89 ce                	mov    %ecx,%esi
  8000eb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	7f 08                	jg     8000f9 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 4a 11 80 00       	push   $0x80114a
  800104:	6a 23                	push   $0x23
  800106:	68 67 11 80 00       	push   $0x801167
  80010b:	e8 2e 02 00 00       	call   80033e <_panic>

00800110 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
	asm volatile("int %1\n"
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 02 00 00 00       	mov    $0x2,%eax
  800120:	89 d1                	mov    %edx,%ecx
  800122:	89 d3                	mov    %edx,%ebx
  800124:	89 d7                	mov    %edx,%edi
  800126:	89 d6                	mov    %edx,%esi
  800128:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_yield>:

void
sys_yield(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
  800154:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800157:	be 00 00 00 00       	mov    $0x0,%esi
  80015c:	8b 55 08             	mov    0x8(%ebp),%edx
  80015f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800162:	b8 04 00 00 00       	mov    $0x4,%eax
  800167:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016a:	89 f7                	mov    %esi,%edi
  80016c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7f 08                	jg     80017a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800172:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5f                   	pop    %edi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 4a 11 80 00       	push   $0x80114a
  800185:	6a 23                	push   $0x23
  800187:	68 67 11 80 00       	push   $0x801167
  80018c:	e8 ad 01 00 00       	call   80033e <_panic>

00800191 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ab:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ae:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	7f 08                	jg     8001bc <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 4a 11 80 00       	push   $0x80114a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 67 11 80 00       	push   $0x801167
  8001ce:	e8 6b 01 00 00       	call   80033e <_panic>

008001d3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	57                   	push   %edi
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ec:	89 df                	mov    %ebx,%edi
  8001ee:	89 de                	mov    %ebx,%esi
  8001f0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7f 08                	jg     8001fe <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 4a 11 80 00       	push   $0x80114a
  800209:	6a 23                	push   $0x23
  80020b:	68 67 11 80 00       	push   $0x801167
  800210:	e8 29 01 00 00       	call   80033e <_panic>

00800215 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	57                   	push   %edi
  800219:	56                   	push   %esi
  80021a:	53                   	push   %ebx
  80021b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	8b 55 08             	mov    0x8(%ebp),%edx
  800226:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800229:	b8 08 00 00 00       	mov    $0x8,%eax
  80022e:	89 df                	mov    %ebx,%edi
  800230:	89 de                	mov    %ebx,%esi
  800232:	cd 30                	int    $0x30
	if(check && ret > 0)
  800234:	85 c0                	test   %eax,%eax
  800236:	7f 08                	jg     800240 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 4a 11 80 00       	push   $0x80114a
  80024b:	6a 23                	push   $0x23
  80024d:	68 67 11 80 00       	push   $0x801167
  800252:	e8 e7 00 00 00       	call   80033e <_panic>

00800257 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800260:	bb 00 00 00 00       	mov    $0x0,%ebx
  800265:	8b 55 08             	mov    0x8(%ebp),%edx
  800268:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026b:	b8 09 00 00 00       	mov    $0x9,%eax
  800270:	89 df                	mov    %ebx,%edi
  800272:	89 de                	mov    %ebx,%esi
  800274:	cd 30                	int    $0x30
	if(check && ret > 0)
  800276:	85 c0                	test   %eax,%eax
  800278:	7f 08                	jg     800282 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 4a 11 80 00       	push   $0x80114a
  80028d:	6a 23                	push   $0x23
  80028f:	68 67 11 80 00       	push   $0x801167
  800294:	e8 a5 00 00 00       	call   80033e <_panic>

00800299 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80029f:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002aa:	be 00 00 00 00       	mov    $0x0,%esi
  8002af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d2:	89 cb                	mov    %ecx,%ebx
  8002d4:	89 cf                	mov    %ecx,%edi
  8002d6:	89 ce                	mov    %ecx,%esi
  8002d8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7f 08                	jg     8002e6 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e6:	83 ec 0c             	sub    $0xc,%esp
  8002e9:	50                   	push   %eax
  8002ea:	6a 0c                	push   $0xc
  8002ec:	68 4a 11 80 00       	push   $0x80114a
  8002f1:	6a 23                	push   $0x23
  8002f3:	68 67 11 80 00       	push   $0x801167
  8002f8:	e8 41 00 00 00       	call   80033e <_panic>

008002fd <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	asm volatile("int %1\n"
  800303:	bb 00 00 00 00       	mov    $0x0,%ebx
  800308:	8b 55 08             	mov    0x8(%ebp),%edx
  80030b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800313:	89 df                	mov    %ebx,%edi
  800315:	89 de                	mov    %ebx,%esi
  800317:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  800319:	5b                   	pop    %ebx
  80031a:	5e                   	pop    %esi
  80031b:	5f                   	pop    %edi
  80031c:	5d                   	pop    %ebp
  80031d:	c3                   	ret    

0080031e <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	57                   	push   %edi
  800322:	56                   	push   %esi
  800323:	53                   	push   %ebx
	asm volatile("int %1\n"
  800324:	b9 00 00 00 00       	mov    $0x0,%ecx
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800331:	89 cb                	mov    %ecx,%ebx
  800333:	89 cf                	mov    %ecx,%edi
  800335:	89 ce                	mov    %ecx,%esi
  800337:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  800339:	5b                   	pop    %ebx
  80033a:	5e                   	pop    %esi
  80033b:	5f                   	pop    %edi
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800343:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800346:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80034c:	e8 bf fd ff ff       	call   800110 <sys_getenvid>
  800351:	83 ec 0c             	sub    $0xc,%esp
  800354:	ff 75 0c             	pushl  0xc(%ebp)
  800357:	ff 75 08             	pushl  0x8(%ebp)
  80035a:	56                   	push   %esi
  80035b:	50                   	push   %eax
  80035c:	68 78 11 80 00       	push   $0x801178
  800361:	e8 b3 00 00 00       	call   800419 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800366:	83 c4 18             	add    $0x18,%esp
  800369:	53                   	push   %ebx
  80036a:	ff 75 10             	pushl  0x10(%ebp)
  80036d:	e8 56 00 00 00       	call   8003c8 <vcprintf>
	cprintf("\n");
  800372:	c7 04 24 9b 11 80 00 	movl   $0x80119b,(%esp)
  800379:	e8 9b 00 00 00       	call   800419 <cprintf>
  80037e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800381:	cc                   	int3   
  800382:	eb fd                	jmp    800381 <_panic+0x43>

00800384 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	53                   	push   %ebx
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038e:	8b 13                	mov    (%ebx),%edx
  800390:	8d 42 01             	lea    0x1(%edx),%eax
  800393:	89 03                	mov    %eax,(%ebx)
  800395:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800398:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a1:	74 09                	je     8003ac <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003aa:	c9                   	leave  
  8003ab:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ac:	83 ec 08             	sub    $0x8,%esp
  8003af:	68 ff 00 00 00       	push   $0xff
  8003b4:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b7:	50                   	push   %eax
  8003b8:	e8 d5 fc ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  8003bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c3:	83 c4 10             	add    $0x10,%esp
  8003c6:	eb db                	jmp    8003a3 <putch+0x1f>

008003c8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d8:	00 00 00 
	b.cnt = 0;
  8003db:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e5:	ff 75 0c             	pushl  0xc(%ebp)
  8003e8:	ff 75 08             	pushl  0x8(%ebp)
  8003eb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f1:	50                   	push   %eax
  8003f2:	68 84 03 80 00       	push   $0x800384
  8003f7:	e8 fb 00 00 00       	call   8004f7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003fc:	83 c4 08             	add    $0x8,%esp
  8003ff:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800405:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040b:	50                   	push   %eax
  80040c:	e8 81 fc ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  800411:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800417:	c9                   	leave  
  800418:	c3                   	ret    

00800419 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800419:	55                   	push   %ebp
  80041a:	89 e5                	mov    %esp,%ebp
  80041c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800422:	50                   	push   %eax
  800423:	ff 75 08             	pushl  0x8(%ebp)
  800426:	e8 9d ff ff ff       	call   8003c8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80042b:	c9                   	leave  
  80042c:	c3                   	ret    

0080042d <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	57                   	push   %edi
  800431:	56                   	push   %esi
  800432:	53                   	push   %ebx
  800433:	83 ec 1c             	sub    $0x1c,%esp
  800436:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800439:	89 d3                	mov    %edx,%ebx
  80043b:	8b 75 08             	mov    0x8(%ebp),%esi
  80043e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800441:	8b 45 10             	mov    0x10(%ebp),%eax
  800444:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800447:	89 c2                	mov    %eax,%edx
  800449:	b9 00 00 00 00       	mov    $0x0,%ecx
  80044e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800451:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800454:	39 c6                	cmp    %eax,%esi
  800456:	89 f8                	mov    %edi,%eax
  800458:	19 c8                	sbb    %ecx,%eax
  80045a:	73 32                	jae    80048e <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  80045c:	83 ec 08             	sub    $0x8,%esp
  80045f:	53                   	push   %ebx
  800460:	83 ec 04             	sub    $0x4,%esp
  800463:	ff 75 e4             	pushl  -0x1c(%ebp)
  800466:	ff 75 e0             	pushl  -0x20(%ebp)
  800469:	57                   	push   %edi
  80046a:	56                   	push   %esi
  80046b:	e8 90 0b 00 00       	call   801000 <__umoddi3>
  800470:	83 c4 14             	add    $0x14,%esp
  800473:	0f be 80 9d 11 80 00 	movsbl 0x80119d(%eax),%eax
  80047a:	50                   	push   %eax
  80047b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80047e:	ff d0                	call   *%eax
	return remain - 1;
  800480:	8b 45 14             	mov    0x14(%ebp),%eax
  800483:	83 e8 01             	sub    $0x1,%eax
}
  800486:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800489:	5b                   	pop    %ebx
  80048a:	5e                   	pop    %esi
  80048b:	5f                   	pop    %edi
  80048c:	5d                   	pop    %ebp
  80048d:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  80048e:	83 ec 0c             	sub    $0xc,%esp
  800491:	ff 75 18             	pushl  0x18(%ebp)
  800494:	ff 75 14             	pushl  0x14(%ebp)
  800497:	ff 75 d8             	pushl  -0x28(%ebp)
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	51                   	push   %ecx
  80049e:	52                   	push   %edx
  80049f:	57                   	push   %edi
  8004a0:	56                   	push   %esi
  8004a1:	e8 4a 0a 00 00       	call   800ef0 <__udivdi3>
  8004a6:	83 c4 18             	add    $0x18,%esp
  8004a9:	52                   	push   %edx
  8004aa:	50                   	push   %eax
  8004ab:	89 da                	mov    %ebx,%edx
  8004ad:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004b0:	e8 78 ff ff ff       	call   80042d <printnum_helper>
  8004b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b8:	83 c4 20             	add    $0x20,%esp
  8004bb:	eb 9f                	jmp    80045c <printnum_helper+0x2f>

008004bd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004bd:	55                   	push   %ebp
  8004be:	89 e5                	mov    %esp,%ebp
  8004c0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004c3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004cc:	73 0a                	jae    8004d8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ce:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004d1:	89 08                	mov    %ecx,(%eax)
  8004d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d6:	88 02                	mov    %al,(%edx)
}
  8004d8:	5d                   	pop    %ebp
  8004d9:	c3                   	ret    

008004da <printfmt>:
{
  8004da:	55                   	push   %ebp
  8004db:	89 e5                	mov    %esp,%ebp
  8004dd:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004e3:	50                   	push   %eax
  8004e4:	ff 75 10             	pushl  0x10(%ebp)
  8004e7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ea:	ff 75 08             	pushl  0x8(%ebp)
  8004ed:	e8 05 00 00 00       	call   8004f7 <vprintfmt>
}
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	c9                   	leave  
  8004f6:	c3                   	ret    

008004f7 <vprintfmt>:
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	57                   	push   %edi
  8004fb:	56                   	push   %esi
  8004fc:	53                   	push   %ebx
  8004fd:	83 ec 3c             	sub    $0x3c,%esp
  800500:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800503:	8b 75 0c             	mov    0xc(%ebp),%esi
  800506:	8b 7d 10             	mov    0x10(%ebp),%edi
  800509:	e9 3f 05 00 00       	jmp    800a4d <vprintfmt+0x556>
		padc = ' ';
  80050e:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800512:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800519:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800520:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800527:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  80052e:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800535:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8d 47 01             	lea    0x1(%edi),%eax
  80053d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800540:	0f b6 17             	movzbl (%edi),%edx
  800543:	8d 42 dd             	lea    -0x23(%edx),%eax
  800546:	3c 55                	cmp    $0x55,%al
  800548:	0f 87 98 05 00 00    	ja     800ae6 <vprintfmt+0x5ef>
  80054e:	0f b6 c0             	movzbl %al,%eax
  800551:	ff 24 85 e0 12 80 00 	jmp    *0x8012e0(,%eax,4)
  800558:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  80055b:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80055f:	eb d9                	jmp    80053a <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800561:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800564:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  80056b:	eb cd                	jmp    80053a <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	0f b6 d2             	movzbl %dl,%edx
  800570:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800573:	b8 00 00 00 00       	mov    $0x0,%eax
  800578:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  80057b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80057e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800582:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800585:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800588:	83 fb 09             	cmp    $0x9,%ebx
  80058b:	77 5c                	ja     8005e9 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  80058d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800590:	eb e9                	jmp    80057b <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  800592:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  800595:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  800599:	eb 9f                	jmp    80053a <vprintfmt+0x43>
			precision = va_arg(ap, int);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 00                	mov    (%eax),%eax
  8005a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8d 40 04             	lea    0x4(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ac:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8005af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b3:	79 85                	jns    80053a <vprintfmt+0x43>
				width = precision, precision = -1;
  8005b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005c2:	e9 73 ff ff ff       	jmp    80053a <vprintfmt+0x43>
  8005c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ca:	85 c0                	test   %eax,%eax
  8005cc:	0f 48 c1             	cmovs  %ecx,%eax
  8005cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d2:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005d5:	e9 60 ff ff ff       	jmp    80053a <vprintfmt+0x43>
  8005da:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8005dd:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8005e4:	e9 51 ff ff ff       	jmp    80053a <vprintfmt+0x43>
  8005e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005ef:	eb be                	jmp    8005af <vprintfmt+0xb8>
			lflag++;
  8005f1:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f5:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  8005f8:	e9 3d ff ff ff       	jmp    80053a <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  8005fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800600:	8d 78 04             	lea    0x4(%eax),%edi
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	56                   	push   %esi
  800607:	ff 30                	pushl  (%eax)
  800609:	ff d3                	call   *%ebx
			break;
  80060b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80060e:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800611:	e9 34 04 00 00       	jmp    800a4a <vprintfmt+0x553>
			err = va_arg(ap, int);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 78 04             	lea    0x4(%eax),%edi
  80061c:	8b 00                	mov    (%eax),%eax
  80061e:	99                   	cltd   
  80061f:	31 d0                	xor    %edx,%eax
  800621:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800623:	83 f8 08             	cmp    $0x8,%eax
  800626:	7f 23                	jg     80064b <vprintfmt+0x154>
  800628:	8b 14 85 40 14 80 00 	mov    0x801440(,%eax,4),%edx
  80062f:	85 d2                	test   %edx,%edx
  800631:	74 18                	je     80064b <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800633:	52                   	push   %edx
  800634:	68 be 11 80 00       	push   $0x8011be
  800639:	56                   	push   %esi
  80063a:	53                   	push   %ebx
  80063b:	e8 9a fe ff ff       	call   8004da <printfmt>
  800640:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800643:	89 7d 14             	mov    %edi,0x14(%ebp)
  800646:	e9 ff 03 00 00       	jmp    800a4a <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  80064b:	50                   	push   %eax
  80064c:	68 b5 11 80 00       	push   $0x8011b5
  800651:	56                   	push   %esi
  800652:	53                   	push   %ebx
  800653:	e8 82 fe ff ff       	call   8004da <printfmt>
  800658:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80065b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80065e:	e9 e7 03 00 00       	jmp    800a4a <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	83 c0 04             	add    $0x4,%eax
  800669:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800671:	85 c9                	test   %ecx,%ecx
  800673:	b8 ae 11 80 00       	mov    $0x8011ae,%eax
  800678:	0f 45 c1             	cmovne %ecx,%eax
  80067b:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80067e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800682:	7e 06                	jle    80068a <vprintfmt+0x193>
  800684:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800688:	75 0d                	jne    800697 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80068d:	89 c7                	mov    %eax,%edi
  80068f:	03 45 d8             	add    -0x28(%ebp),%eax
  800692:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800695:	eb 53                	jmp    8006ea <vprintfmt+0x1f3>
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	ff 75 e0             	pushl  -0x20(%ebp)
  80069d:	50                   	push   %eax
  80069e:	e8 eb 04 00 00       	call   800b8e <strnlen>
  8006a3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006a6:	29 c1                	sub    %eax,%ecx
  8006a8:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006b0:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8006b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b7:	eb 0f                	jmp    8006c8 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	56                   	push   %esi
  8006bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8006c0:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c2:	83 ef 01             	sub    $0x1,%edi
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	85 ff                	test   %edi,%edi
  8006ca:	7f ed                	jg     8006b9 <vprintfmt+0x1c2>
  8006cc:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8006cf:	85 c9                	test   %ecx,%ecx
  8006d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d6:	0f 49 c1             	cmovns %ecx,%eax
  8006d9:	29 c1                	sub    %eax,%ecx
  8006db:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006de:	eb aa                	jmp    80068a <vprintfmt+0x193>
					putch(ch, putdat);
  8006e0:	83 ec 08             	sub    $0x8,%esp
  8006e3:	56                   	push   %esi
  8006e4:	52                   	push   %edx
  8006e5:	ff d3                	call   *%ebx
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006ed:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ef:	83 c7 01             	add    $0x1,%edi
  8006f2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f6:	0f be d0             	movsbl %al,%edx
  8006f9:	85 d2                	test   %edx,%edx
  8006fb:	74 2e                	je     80072b <vprintfmt+0x234>
  8006fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800701:	78 06                	js     800709 <vprintfmt+0x212>
  800703:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800707:	78 1e                	js     800727 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800709:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  80070d:	74 d1                	je     8006e0 <vprintfmt+0x1e9>
  80070f:	0f be c0             	movsbl %al,%eax
  800712:	83 e8 20             	sub    $0x20,%eax
  800715:	83 f8 5e             	cmp    $0x5e,%eax
  800718:	76 c6                	jbe    8006e0 <vprintfmt+0x1e9>
					putch('?', putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	56                   	push   %esi
  80071e:	6a 3f                	push   $0x3f
  800720:	ff d3                	call   *%ebx
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	eb c3                	jmp    8006ea <vprintfmt+0x1f3>
  800727:	89 cf                	mov    %ecx,%edi
  800729:	eb 02                	jmp    80072d <vprintfmt+0x236>
  80072b:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  80072d:	85 ff                	test   %edi,%edi
  80072f:	7e 10                	jle    800741 <vprintfmt+0x24a>
				putch(' ', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	56                   	push   %esi
  800735:	6a 20                	push   $0x20
  800737:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800739:	83 ef 01             	sub    $0x1,%edi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	eb ec                	jmp    80072d <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800741:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800744:	89 45 14             	mov    %eax,0x14(%ebp)
  800747:	e9 fe 02 00 00       	jmp    800a4a <vprintfmt+0x553>
	if (lflag >= 2)
  80074c:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800750:	7f 21                	jg     800773 <vprintfmt+0x27c>
	else if (lflag)
  800752:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800756:	74 79                	je     8007d1 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  800758:	8b 45 14             	mov    0x14(%ebp),%eax
  80075b:	8b 00                	mov    (%eax),%eax
  80075d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800760:	89 c1                	mov    %eax,%ecx
  800762:	c1 f9 1f             	sar    $0x1f,%ecx
  800765:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800768:	8b 45 14             	mov    0x14(%ebp),%eax
  80076b:	8d 40 04             	lea    0x4(%eax),%eax
  80076e:	89 45 14             	mov    %eax,0x14(%ebp)
  800771:	eb 17                	jmp    80078a <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	8b 50 04             	mov    0x4(%eax),%edx
  800779:	8b 00                	mov    (%eax),%eax
  80077b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80077e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8d 40 08             	lea    0x8(%eax),%eax
  800787:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  80078a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80078d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800790:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800793:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  800796:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80079a:	78 50                	js     8007ec <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  80079c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80079f:	c1 fa 1f             	sar    $0x1f,%edx
  8007a2:	89 d0                	mov    %edx,%eax
  8007a4:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8007a7:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	0f 89 14 02 00 00    	jns    8009c6 <vprintfmt+0x4cf>
  8007b2:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007b6:	0f 84 0a 02 00 00    	je     8009c6 <vprintfmt+0x4cf>
				putch('+', putdat);
  8007bc:	83 ec 08             	sub    $0x8,%esp
  8007bf:	56                   	push   %esi
  8007c0:	6a 2b                	push   $0x2b
  8007c2:	ff d3                	call   *%ebx
  8007c4:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007cc:	e9 5c 01 00 00       	jmp    80092d <vprintfmt+0x436>
		return va_arg(*ap, int);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8b 00                	mov    (%eax),%eax
  8007d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007d9:	89 c1                	mov    %eax,%ecx
  8007db:	c1 f9 1f             	sar    $0x1f,%ecx
  8007de:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8d 40 04             	lea    0x4(%eax),%eax
  8007e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ea:	eb 9e                	jmp    80078a <vprintfmt+0x293>
				putch('-', putdat);
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	56                   	push   %esi
  8007f0:	6a 2d                	push   $0x2d
  8007f2:	ff d3                	call   *%ebx
				num = -(long long) num;
  8007f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007fa:	f7 d8                	neg    %eax
  8007fc:	83 d2 00             	adc    $0x0,%edx
  8007ff:	f7 da                	neg    %edx
  800801:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800804:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800807:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80080a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80080f:	e9 19 01 00 00       	jmp    80092d <vprintfmt+0x436>
	if (lflag >= 2)
  800814:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800818:	7f 29                	jg     800843 <vprintfmt+0x34c>
	else if (lflag)
  80081a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80081e:	74 44                	je     800864 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800820:	8b 45 14             	mov    0x14(%ebp),%eax
  800823:	8b 00                	mov    (%eax),%eax
  800825:	ba 00 00 00 00       	mov    $0x0,%edx
  80082a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80082d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800830:	8b 45 14             	mov    0x14(%ebp),%eax
  800833:	8d 40 04             	lea    0x4(%eax),%eax
  800836:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800839:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083e:	e9 ea 00 00 00       	jmp    80092d <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800843:	8b 45 14             	mov    0x14(%ebp),%eax
  800846:	8b 50 04             	mov    0x4(%eax),%edx
  800849:	8b 00                	mov    (%eax),%eax
  80084b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80084e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8d 40 08             	lea    0x8(%eax),%eax
  800857:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80085a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085f:	e9 c9 00 00 00       	jmp    80092d <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800864:	8b 45 14             	mov    0x14(%ebp),%eax
  800867:	8b 00                	mov    (%eax),%eax
  800869:	ba 00 00 00 00       	mov    $0x0,%edx
  80086e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800871:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800874:	8b 45 14             	mov    0x14(%ebp),%eax
  800877:	8d 40 04             	lea    0x4(%eax),%eax
  80087a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80087d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800882:	e9 a6 00 00 00       	jmp    80092d <vprintfmt+0x436>
			putch('0', putdat);
  800887:	83 ec 08             	sub    $0x8,%esp
  80088a:	56                   	push   %esi
  80088b:	6a 30                	push   $0x30
  80088d:	ff d3                	call   *%ebx
	if (lflag >= 2)
  80088f:	83 c4 10             	add    $0x10,%esp
  800892:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800896:	7f 26                	jg     8008be <vprintfmt+0x3c7>
	else if (lflag)
  800898:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80089c:	74 3e                	je     8008dc <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  80089e:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a1:	8b 00                	mov    (%eax),%eax
  8008a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008ab:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b1:	8d 40 04             	lea    0x4(%eax),%eax
  8008b4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008b7:	b8 08 00 00 00       	mov    $0x8,%eax
  8008bc:	eb 6f                	jmp    80092d <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8008be:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c1:	8b 50 04             	mov    0x4(%eax),%edx
  8008c4:	8b 00                	mov    (%eax),%eax
  8008c6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008c9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cf:	8d 40 08             	lea    0x8(%eax),%eax
  8008d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008d5:	b8 08 00 00 00       	mov    $0x8,%eax
  8008da:	eb 51                	jmp    80092d <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8008dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008df:	8b 00                	mov    (%eax),%eax
  8008e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008e9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ef:	8d 40 04             	lea    0x4(%eax),%eax
  8008f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008f5:	b8 08 00 00 00       	mov    $0x8,%eax
  8008fa:	eb 31                	jmp    80092d <vprintfmt+0x436>
			putch('0', putdat);
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	56                   	push   %esi
  800900:	6a 30                	push   $0x30
  800902:	ff d3                	call   *%ebx
			putch('x', putdat);
  800904:	83 c4 08             	add    $0x8,%esp
  800907:	56                   	push   %esi
  800908:	6a 78                	push   $0x78
  80090a:	ff d3                	call   *%ebx
			num = (unsigned long long)
  80090c:	8b 45 14             	mov    0x14(%ebp),%eax
  80090f:	8b 00                	mov    (%eax),%eax
  800911:	ba 00 00 00 00       	mov    $0x0,%edx
  800916:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800919:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  80091c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80091f:	8b 45 14             	mov    0x14(%ebp),%eax
  800922:	8d 40 04             	lea    0x4(%eax),%eax
  800925:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800928:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80092d:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800931:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800934:	89 c1                	mov    %eax,%ecx
  800936:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800939:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80093c:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800941:	89 c2                	mov    %eax,%edx
  800943:	39 c1                	cmp    %eax,%ecx
  800945:	0f 87 85 00 00 00    	ja     8009d0 <vprintfmt+0x4d9>
		tmp /= base;
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	ba 00 00 00 00       	mov    $0x0,%edx
  800952:	f7 f1                	div    %ecx
		len++;
  800954:	83 c7 01             	add    $0x1,%edi
  800957:	eb e8                	jmp    800941 <vprintfmt+0x44a>
	if (lflag >= 2)
  800959:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80095d:	7f 26                	jg     800985 <vprintfmt+0x48e>
	else if (lflag)
  80095f:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800963:	74 3e                	je     8009a3 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800965:	8b 45 14             	mov    0x14(%ebp),%eax
  800968:	8b 00                	mov    (%eax),%eax
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800972:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800975:	8b 45 14             	mov    0x14(%ebp),%eax
  800978:	8d 40 04             	lea    0x4(%eax),%eax
  80097b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80097e:	b8 10 00 00 00       	mov    $0x10,%eax
  800983:	eb a8                	jmp    80092d <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800985:	8b 45 14             	mov    0x14(%ebp),%eax
  800988:	8b 50 04             	mov    0x4(%eax),%edx
  80098b:	8b 00                	mov    (%eax),%eax
  80098d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800990:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800993:	8b 45 14             	mov    0x14(%ebp),%eax
  800996:	8d 40 08             	lea    0x8(%eax),%eax
  800999:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80099c:	b8 10 00 00 00       	mov    $0x10,%eax
  8009a1:	eb 8a                	jmp    80092d <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8009a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a6:	8b 00                	mov    (%eax),%eax
  8009a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b6:	8d 40 04             	lea    0x4(%eax),%eax
  8009b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009bc:	b8 10 00 00 00       	mov    $0x10,%eax
  8009c1:	e9 67 ff ff ff       	jmp    80092d <vprintfmt+0x436>
			base = 10;
  8009c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009cb:	e9 5d ff ff ff       	jmp    80092d <vprintfmt+0x436>
  8009d0:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8009d3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009d6:	29 f8                	sub    %edi,%eax
  8009d8:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8009da:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8009de:	74 15                	je     8009f5 <vprintfmt+0x4fe>
		while (width > 0) {
  8009e0:	85 ff                	test   %edi,%edi
  8009e2:	7e 48                	jle    800a2c <vprintfmt+0x535>
			putch(padc, putdat);
  8009e4:	83 ec 08             	sub    $0x8,%esp
  8009e7:	56                   	push   %esi
  8009e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8009eb:	ff d3                	call   *%ebx
			width--;
  8009ed:	83 ef 01             	sub    $0x1,%edi
  8009f0:	83 c4 10             	add    $0x10,%esp
  8009f3:	eb eb                	jmp    8009e0 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  8009f5:	83 ec 0c             	sub    $0xc,%esp
  8009f8:	6a 2d                	push   $0x2d
  8009fa:	ff 75 cc             	pushl  -0x34(%ebp)
  8009fd:	ff 75 c8             	pushl  -0x38(%ebp)
  800a00:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a03:	ff 75 d0             	pushl  -0x30(%ebp)
  800a06:	89 f2                	mov    %esi,%edx
  800a08:	89 d8                	mov    %ebx,%eax
  800a0a:	e8 1e fa ff ff       	call   80042d <printnum_helper>
		width -= len;
  800a0f:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a12:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800a15:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800a18:	85 ff                	test   %edi,%edi
  800a1a:	7e 2e                	jle    800a4a <vprintfmt+0x553>
			putch(padc, putdat);
  800a1c:	83 ec 08             	sub    $0x8,%esp
  800a1f:	56                   	push   %esi
  800a20:	6a 20                	push   $0x20
  800a22:	ff d3                	call   *%ebx
			width--;
  800a24:	83 ef 01             	sub    $0x1,%edi
  800a27:	83 c4 10             	add    $0x10,%esp
  800a2a:	eb ec                	jmp    800a18 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a2c:	83 ec 0c             	sub    $0xc,%esp
  800a2f:	ff 75 e0             	pushl  -0x20(%ebp)
  800a32:	ff 75 cc             	pushl  -0x34(%ebp)
  800a35:	ff 75 c8             	pushl  -0x38(%ebp)
  800a38:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a3b:	ff 75 d0             	pushl  -0x30(%ebp)
  800a3e:	89 f2                	mov    %esi,%edx
  800a40:	89 d8                	mov    %ebx,%eax
  800a42:	e8 e6 f9 ff ff       	call   80042d <printnum_helper>
  800a47:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800a4a:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a4d:	83 c7 01             	add    $0x1,%edi
  800a50:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a54:	83 f8 25             	cmp    $0x25,%eax
  800a57:	0f 84 b1 fa ff ff    	je     80050e <vprintfmt+0x17>
			if (ch == '\0')
  800a5d:	85 c0                	test   %eax,%eax
  800a5f:	0f 84 a1 00 00 00    	je     800b06 <vprintfmt+0x60f>
			putch(ch, putdat);
  800a65:	83 ec 08             	sub    $0x8,%esp
  800a68:	56                   	push   %esi
  800a69:	50                   	push   %eax
  800a6a:	ff d3                	call   *%ebx
  800a6c:	83 c4 10             	add    $0x10,%esp
  800a6f:	eb dc                	jmp    800a4d <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800a71:	8b 45 14             	mov    0x14(%ebp),%eax
  800a74:	83 c0 04             	add    $0x4,%eax
  800a77:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a7a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7d:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800a7f:	85 ff                	test   %edi,%edi
  800a81:	74 15                	je     800a98 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800a83:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800a89:	7f 29                	jg     800ab4 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800a8b:	0f b6 06             	movzbl (%esi),%eax
  800a8e:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800a90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a93:	89 45 14             	mov    %eax,0x14(%ebp)
  800a96:	eb b2                	jmp    800a4a <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800a98:	68 54 12 80 00       	push   $0x801254
  800a9d:	68 be 11 80 00       	push   $0x8011be
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	e8 31 fa ff ff       	call   8004da <printfmt>
  800aa9:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800aac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800aaf:	89 45 14             	mov    %eax,0x14(%ebp)
  800ab2:	eb 96                	jmp    800a4a <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800ab4:	68 8c 12 80 00       	push   $0x80128c
  800ab9:	68 be 11 80 00       	push   $0x8011be
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	e8 15 fa ff ff       	call   8004da <printfmt>
				*res = -1;
  800ac5:	c6 07 ff             	movb   $0xff,(%edi)
  800ac8:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800acb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ace:	89 45 14             	mov    %eax,0x14(%ebp)
  800ad1:	e9 74 ff ff ff       	jmp    800a4a <vprintfmt+0x553>
			putch(ch, putdat);
  800ad6:	83 ec 08             	sub    $0x8,%esp
  800ad9:	56                   	push   %esi
  800ada:	6a 25                	push   $0x25
  800adc:	ff d3                	call   *%ebx
			break;
  800ade:	83 c4 10             	add    $0x10,%esp
  800ae1:	e9 64 ff ff ff       	jmp    800a4a <vprintfmt+0x553>
			putch('%', putdat);
  800ae6:	83 ec 08             	sub    $0x8,%esp
  800ae9:	56                   	push   %esi
  800aea:	6a 25                	push   $0x25
  800aec:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aee:	83 c4 10             	add    $0x10,%esp
  800af1:	89 f8                	mov    %edi,%eax
  800af3:	eb 03                	jmp    800af8 <vprintfmt+0x601>
  800af5:	83 e8 01             	sub    $0x1,%eax
  800af8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800afc:	75 f7                	jne    800af5 <vprintfmt+0x5fe>
  800afe:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b01:	e9 44 ff ff ff       	jmp    800a4a <vprintfmt+0x553>
}
  800b06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	83 ec 18             	sub    $0x18,%esp
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b1a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b1d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b21:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	74 26                	je     800b55 <vsnprintf+0x47>
  800b2f:	85 d2                	test   %edx,%edx
  800b31:	7e 22                	jle    800b55 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b33:	ff 75 14             	pushl  0x14(%ebp)
  800b36:	ff 75 10             	pushl  0x10(%ebp)
  800b39:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b3c:	50                   	push   %eax
  800b3d:	68 bd 04 80 00       	push   $0x8004bd
  800b42:	e8 b0 f9 ff ff       	call   8004f7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b47:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b4a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b50:	83 c4 10             	add    $0x10,%esp
}
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    
		return -E_INVAL;
  800b55:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b5a:	eb f7                	jmp    800b53 <vsnprintf+0x45>

00800b5c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b62:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b65:	50                   	push   %eax
  800b66:	ff 75 10             	pushl  0x10(%ebp)
  800b69:	ff 75 0c             	pushl  0xc(%ebp)
  800b6c:	ff 75 08             	pushl  0x8(%ebp)
  800b6f:	e8 9a ff ff ff       	call   800b0e <vsnprintf>
	va_end(ap);

	return rc;
}
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b85:	74 05                	je     800b8c <strlen+0x16>
		n++;
  800b87:	83 c0 01             	add    $0x1,%eax
  800b8a:	eb f5                	jmp    800b81 <strlen+0xb>
	return n;
}
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    

00800b8e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b94:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	39 c2                	cmp    %eax,%edx
  800b9e:	74 0d                	je     800bad <strnlen+0x1f>
  800ba0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800ba4:	74 05                	je     800bab <strnlen+0x1d>
		n++;
  800ba6:	83 c2 01             	add    $0x1,%edx
  800ba9:	eb f1                	jmp    800b9c <strnlen+0xe>
  800bab:	89 d0                	mov    %edx,%eax
	return n;
}
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	53                   	push   %ebx
  800bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbe:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bc2:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bc5:	83 c2 01             	add    $0x1,%edx
  800bc8:	84 c9                	test   %cl,%cl
  800bca:	75 f2                	jne    800bbe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5d                   	pop    %ebp
  800bce:	c3                   	ret    

00800bcf <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 10             	sub    $0x10,%esp
  800bd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bd9:	53                   	push   %ebx
  800bda:	e8 97 ff ff ff       	call   800b76 <strlen>
  800bdf:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800be2:	ff 75 0c             	pushl  0xc(%ebp)
  800be5:	01 d8                	add    %ebx,%eax
  800be7:	50                   	push   %eax
  800be8:	e8 c2 ff ff ff       	call   800baf <strcpy>
	return dst;
}
  800bed:	89 d8                	mov    %ebx,%eax
  800bef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	56                   	push   %esi
  800bf8:	53                   	push   %ebx
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bff:	89 c6                	mov    %eax,%esi
  800c01:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c04:	89 c2                	mov    %eax,%edx
  800c06:	39 f2                	cmp    %esi,%edx
  800c08:	74 11                	je     800c1b <strncpy+0x27>
		*dst++ = *src;
  800c0a:	83 c2 01             	add    $0x1,%edx
  800c0d:	0f b6 19             	movzbl (%ecx),%ebx
  800c10:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c13:	80 fb 01             	cmp    $0x1,%bl
  800c16:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800c19:	eb eb                	jmp    800c06 <strncpy+0x12>
	}
	return ret;
}
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	8b 75 08             	mov    0x8(%ebp),%esi
  800c27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2a:	8b 55 10             	mov    0x10(%ebp),%edx
  800c2d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c2f:	85 d2                	test   %edx,%edx
  800c31:	74 21                	je     800c54 <strlcpy+0x35>
  800c33:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c37:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800c39:	39 c2                	cmp    %eax,%edx
  800c3b:	74 14                	je     800c51 <strlcpy+0x32>
  800c3d:	0f b6 19             	movzbl (%ecx),%ebx
  800c40:	84 db                	test   %bl,%bl
  800c42:	74 0b                	je     800c4f <strlcpy+0x30>
			*dst++ = *src++;
  800c44:	83 c1 01             	add    $0x1,%ecx
  800c47:	83 c2 01             	add    $0x1,%edx
  800c4a:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c4d:	eb ea                	jmp    800c39 <strlcpy+0x1a>
  800c4f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c51:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c54:	29 f0                	sub    %esi,%eax
}
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c60:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c63:	0f b6 01             	movzbl (%ecx),%eax
  800c66:	84 c0                	test   %al,%al
  800c68:	74 0c                	je     800c76 <strcmp+0x1c>
  800c6a:	3a 02                	cmp    (%edx),%al
  800c6c:	75 08                	jne    800c76 <strcmp+0x1c>
		p++, q++;
  800c6e:	83 c1 01             	add    $0x1,%ecx
  800c71:	83 c2 01             	add    $0x1,%edx
  800c74:	eb ed                	jmp    800c63 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c76:	0f b6 c0             	movzbl %al,%eax
  800c79:	0f b6 12             	movzbl (%edx),%edx
  800c7c:	29 d0                	sub    %edx,%eax
}
  800c7e:	5d                   	pop    %ebp
  800c7f:	c3                   	ret    

00800c80 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	53                   	push   %ebx
  800c84:	8b 45 08             	mov    0x8(%ebp),%eax
  800c87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c8a:	89 c3                	mov    %eax,%ebx
  800c8c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c8f:	eb 06                	jmp    800c97 <strncmp+0x17>
		n--, p++, q++;
  800c91:	83 c0 01             	add    $0x1,%eax
  800c94:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c97:	39 d8                	cmp    %ebx,%eax
  800c99:	74 16                	je     800cb1 <strncmp+0x31>
  800c9b:	0f b6 08             	movzbl (%eax),%ecx
  800c9e:	84 c9                	test   %cl,%cl
  800ca0:	74 04                	je     800ca6 <strncmp+0x26>
  800ca2:	3a 0a                	cmp    (%edx),%cl
  800ca4:	74 eb                	je     800c91 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ca6:	0f b6 00             	movzbl (%eax),%eax
  800ca9:	0f b6 12             	movzbl (%edx),%edx
  800cac:	29 d0                	sub    %edx,%eax
}
  800cae:	5b                   	pop    %ebx
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    
		return 0;
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	eb f6                	jmp    800cae <strncmp+0x2e>

00800cb8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cc2:	0f b6 10             	movzbl (%eax),%edx
  800cc5:	84 d2                	test   %dl,%dl
  800cc7:	74 09                	je     800cd2 <strchr+0x1a>
		if (*s == c)
  800cc9:	38 ca                	cmp    %cl,%dl
  800ccb:	74 0a                	je     800cd7 <strchr+0x1f>
	for (; *s; s++)
  800ccd:	83 c0 01             	add    $0x1,%eax
  800cd0:	eb f0                	jmp    800cc2 <strchr+0xa>
			return (char *) s;
	return 0;
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ce3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ce6:	38 ca                	cmp    %cl,%dl
  800ce8:	74 09                	je     800cf3 <strfind+0x1a>
  800cea:	84 d2                	test   %dl,%dl
  800cec:	74 05                	je     800cf3 <strfind+0x1a>
	for (; *s; s++)
  800cee:	83 c0 01             	add    $0x1,%eax
  800cf1:	eb f0                	jmp    800ce3 <strfind+0xa>
			break;
	return (char *) s;
}
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	57                   	push   %edi
  800cf9:	56                   	push   %esi
  800cfa:	53                   	push   %ebx
  800cfb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cfe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d01:	85 c9                	test   %ecx,%ecx
  800d03:	74 31                	je     800d36 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d05:	89 f8                	mov    %edi,%eax
  800d07:	09 c8                	or     %ecx,%eax
  800d09:	a8 03                	test   $0x3,%al
  800d0b:	75 23                	jne    800d30 <memset+0x3b>
		c &= 0xFF;
  800d0d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d11:	89 d3                	mov    %edx,%ebx
  800d13:	c1 e3 08             	shl    $0x8,%ebx
  800d16:	89 d0                	mov    %edx,%eax
  800d18:	c1 e0 18             	shl    $0x18,%eax
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	c1 e6 10             	shl    $0x10,%esi
  800d20:	09 f0                	or     %esi,%eax
  800d22:	09 c2                	or     %eax,%edx
  800d24:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d26:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d29:	89 d0                	mov    %edx,%eax
  800d2b:	fc                   	cld    
  800d2c:	f3 ab                	rep stos %eax,%es:(%edi)
  800d2e:	eb 06                	jmp    800d36 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d33:	fc                   	cld    
  800d34:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d36:	89 f8                	mov    %edi,%eax
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	8b 45 08             	mov    0x8(%ebp),%eax
  800d45:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d48:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d4b:	39 c6                	cmp    %eax,%esi
  800d4d:	73 32                	jae    800d81 <memmove+0x44>
  800d4f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d52:	39 c2                	cmp    %eax,%edx
  800d54:	76 2b                	jbe    800d81 <memmove+0x44>
		s += n;
		d += n;
  800d56:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d59:	89 fe                	mov    %edi,%esi
  800d5b:	09 ce                	or     %ecx,%esi
  800d5d:	09 d6                	or     %edx,%esi
  800d5f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d65:	75 0e                	jne    800d75 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d67:	83 ef 04             	sub    $0x4,%edi
  800d6a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d6d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d70:	fd                   	std    
  800d71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d73:	eb 09                	jmp    800d7e <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d75:	83 ef 01             	sub    $0x1,%edi
  800d78:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d7b:	fd                   	std    
  800d7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d7e:	fc                   	cld    
  800d7f:	eb 1a                	jmp    800d9b <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d81:	89 c2                	mov    %eax,%edx
  800d83:	09 ca                	or     %ecx,%edx
  800d85:	09 f2                	or     %esi,%edx
  800d87:	f6 c2 03             	test   $0x3,%dl
  800d8a:	75 0a                	jne    800d96 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d8c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d8f:	89 c7                	mov    %eax,%edi
  800d91:	fc                   	cld    
  800d92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d94:	eb 05                	jmp    800d9b <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800d96:	89 c7                	mov    %eax,%edi
  800d98:	fc                   	cld    
  800d99:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800da5:	ff 75 10             	pushl  0x10(%ebp)
  800da8:	ff 75 0c             	pushl  0xc(%ebp)
  800dab:	ff 75 08             	pushl  0x8(%ebp)
  800dae:	e8 8a ff ff ff       	call   800d3d <memmove>
}
  800db3:	c9                   	leave  
  800db4:	c3                   	ret    

00800db5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
  800dba:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dc0:	89 c6                	mov    %eax,%esi
  800dc2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dc5:	39 f0                	cmp    %esi,%eax
  800dc7:	74 1c                	je     800de5 <memcmp+0x30>
		if (*s1 != *s2)
  800dc9:	0f b6 08             	movzbl (%eax),%ecx
  800dcc:	0f b6 1a             	movzbl (%edx),%ebx
  800dcf:	38 d9                	cmp    %bl,%cl
  800dd1:	75 08                	jne    800ddb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800dd3:	83 c0 01             	add    $0x1,%eax
  800dd6:	83 c2 01             	add    $0x1,%edx
  800dd9:	eb ea                	jmp    800dc5 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800ddb:	0f b6 c1             	movzbl %cl,%eax
  800dde:	0f b6 db             	movzbl %bl,%ebx
  800de1:	29 d8                	sub    %ebx,%eax
  800de3:	eb 05                	jmp    800dea <memcmp+0x35>
	}

	return 0;
  800de5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
  800df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800df7:	89 c2                	mov    %eax,%edx
  800df9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800dfc:	39 d0                	cmp    %edx,%eax
  800dfe:	73 09                	jae    800e09 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e00:	38 08                	cmp    %cl,(%eax)
  800e02:	74 05                	je     800e09 <memfind+0x1b>
	for (; s < ends; s++)
  800e04:	83 c0 01             	add    $0x1,%eax
  800e07:	eb f3                	jmp    800dfc <memfind+0xe>
			break;
	return (void *) s;
}
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    

00800e0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e17:	eb 03                	jmp    800e1c <strtol+0x11>
		s++;
  800e19:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e1c:	0f b6 01             	movzbl (%ecx),%eax
  800e1f:	3c 20                	cmp    $0x20,%al
  800e21:	74 f6                	je     800e19 <strtol+0xe>
  800e23:	3c 09                	cmp    $0x9,%al
  800e25:	74 f2                	je     800e19 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e27:	3c 2b                	cmp    $0x2b,%al
  800e29:	74 2a                	je     800e55 <strtol+0x4a>
	int neg = 0;
  800e2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e30:	3c 2d                	cmp    $0x2d,%al
  800e32:	74 2b                	je     800e5f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e3a:	75 0f                	jne    800e4b <strtol+0x40>
  800e3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e3f:	74 28                	je     800e69 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e41:	85 db                	test   %ebx,%ebx
  800e43:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e48:	0f 44 d8             	cmove  %eax,%ebx
  800e4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e50:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e53:	eb 50                	jmp    800ea5 <strtol+0x9a>
		s++;
  800e55:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e58:	bf 00 00 00 00       	mov    $0x0,%edi
  800e5d:	eb d5                	jmp    800e34 <strtol+0x29>
		s++, neg = 1;
  800e5f:	83 c1 01             	add    $0x1,%ecx
  800e62:	bf 01 00 00 00       	mov    $0x1,%edi
  800e67:	eb cb                	jmp    800e34 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e69:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e6d:	74 0e                	je     800e7d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e6f:	85 db                	test   %ebx,%ebx
  800e71:	75 d8                	jne    800e4b <strtol+0x40>
		s++, base = 8;
  800e73:	83 c1 01             	add    $0x1,%ecx
  800e76:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e7b:	eb ce                	jmp    800e4b <strtol+0x40>
		s += 2, base = 16;
  800e7d:	83 c1 02             	add    $0x2,%ecx
  800e80:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e85:	eb c4                	jmp    800e4b <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800e87:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e8a:	89 f3                	mov    %esi,%ebx
  800e8c:	80 fb 19             	cmp    $0x19,%bl
  800e8f:	77 29                	ja     800eba <strtol+0xaf>
			dig = *s - 'a' + 10;
  800e91:	0f be d2             	movsbl %dl,%edx
  800e94:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e97:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e9a:	7d 30                	jge    800ecc <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800e9c:	83 c1 01             	add    $0x1,%ecx
  800e9f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ea3:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ea5:	0f b6 11             	movzbl (%ecx),%edx
  800ea8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800eab:	89 f3                	mov    %esi,%ebx
  800ead:	80 fb 09             	cmp    $0x9,%bl
  800eb0:	77 d5                	ja     800e87 <strtol+0x7c>
			dig = *s - '0';
  800eb2:	0f be d2             	movsbl %dl,%edx
  800eb5:	83 ea 30             	sub    $0x30,%edx
  800eb8:	eb dd                	jmp    800e97 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800eba:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ebd:	89 f3                	mov    %esi,%ebx
  800ebf:	80 fb 19             	cmp    $0x19,%bl
  800ec2:	77 08                	ja     800ecc <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ec4:	0f be d2             	movsbl %dl,%edx
  800ec7:	83 ea 37             	sub    $0x37,%edx
  800eca:	eb cb                	jmp    800e97 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ecc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed0:	74 05                	je     800ed7 <strtol+0xcc>
		*endptr = (char *) s;
  800ed2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ed7:	89 c2                	mov    %eax,%edx
  800ed9:	f7 da                	neg    %edx
  800edb:	85 ff                	test   %edi,%edi
  800edd:	0f 45 c2             	cmovne %edx,%eax
}
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
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
