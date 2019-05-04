
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 5d 00 00 00       	call   8000a6 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 c6 00 00 00       	call   800124 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 42 00 00 00       	call   8000e3 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f9:	89 cb                	mov    %ecx,%ebx
  8000fb:	89 cf                	mov    %ecx,%edi
  8000fd:	89 ce                	mov    %ecx,%esi
  8000ff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7f 08                	jg     80010d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 78 11 80 00       	push   $0x801178
  800118:	6a 23                	push   $0x23
  80011a:	68 95 11 80 00       	push   $0x801195
  80011f:	e8 2e 02 00 00       	call   800352 <_panic>

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 02 00 00 00       	mov    $0x2,%eax
  800134:	89 d1                	mov    %edx,%ecx
  800136:	89 d3                	mov    %edx,%ebx
  800138:	89 d7                	mov    %edx,%edi
  80013a:	89 d6                	mov    %edx,%esi
  80013c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_yield>:

void
sys_yield(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80016b:	be 00 00 00 00       	mov    $0x0,%esi
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017e:	89 f7                	mov    %esi,%edi
  800180:	cd 30                	int    $0x30
	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7f 08                	jg     80018e <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800186:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800189:	5b                   	pop    %ebx
  80018a:	5e                   	pop    %esi
  80018b:	5f                   	pop    %edi
  80018c:	5d                   	pop    %ebp
  80018d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 78 11 80 00       	push   $0x801178
  800199:	6a 23                	push   $0x23
  80019b:	68 95 11 80 00       	push   $0x801195
  8001a0:	e8 ad 01 00 00       	call   800352 <_panic>

008001a5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c4:	85 c0                	test   %eax,%eax
  8001c6:	7f 08                	jg     8001d0 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cb:	5b                   	pop    %ebx
  8001cc:	5e                   	pop    %esi
  8001cd:	5f                   	pop    %edi
  8001ce:	5d                   	pop    %ebp
  8001cf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 78 11 80 00       	push   $0x801178
  8001db:	6a 23                	push   $0x23
  8001dd:	68 95 11 80 00       	push   $0x801195
  8001e2:	e8 6b 01 00 00       	call   800352 <_panic>

008001e7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	89 df                	mov    %ebx,%edi
  800202:	89 de                	mov    %ebx,%esi
  800204:	cd 30                	int    $0x30
	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7f 08                	jg     800212 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5f                   	pop    %edi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 78 11 80 00       	push   $0x801178
  80021d:	6a 23                	push   $0x23
  80021f:	68 95 11 80 00       	push   $0x801195
  800224:	e8 29 01 00 00       	call   800352 <_panic>

00800229 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800232:	bb 00 00 00 00       	mov    $0x0,%ebx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	89 df                	mov    %ebx,%edi
  800244:	89 de                	mov    %ebx,%esi
  800246:	cd 30                	int    $0x30
	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7f 08                	jg     800254 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 78 11 80 00       	push   $0x801178
  80025f:	6a 23                	push   $0x23
  800261:	68 95 11 80 00       	push   $0x801195
  800266:	e8 e7 00 00 00       	call   800352 <_panic>

0080026b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	89 df                	mov    %ebx,%edi
  800286:	89 de                	mov    %ebx,%esi
  800288:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7f 08                	jg     800296 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80028e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 78 11 80 00       	push   $0x801178
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 95 11 80 00       	push   $0x801195
  8002a8:	e8 a5 00 00 00       	call   800352 <_panic>

008002ad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002be:	be 00 00 00 00       	mov    $0x0,%esi
  8002c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002de:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e6:	89 cb                	mov    %ecx,%ebx
  8002e8:	89 cf                	mov    %ecx,%edi
  8002ea:	89 ce                	mov    %ecx,%esi
  8002ec:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	7f 08                	jg     8002fa <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5e                   	pop    %esi
  8002f7:	5f                   	pop    %edi
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	50                   	push   %eax
  8002fe:	6a 0c                	push   $0xc
  800300:	68 78 11 80 00       	push   $0x801178
  800305:	6a 23                	push   $0x23
  800307:	68 95 11 80 00       	push   $0x801195
  80030c:	e8 41 00 00 00       	call   800352 <_panic>

00800311 <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	57                   	push   %edi
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	asm volatile("int %1\n"
  800317:	bb 00 00 00 00       	mov    $0x0,%ebx
  80031c:	8b 55 08             	mov    0x8(%ebp),%edx
  80031f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800322:	b8 0d 00 00 00       	mov    $0xd,%eax
  800327:	89 df                	mov    %ebx,%edi
  800329:	89 de                	mov    %ebx,%esi
  80032b:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    

00800332 <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	57                   	push   %edi
  800336:	56                   	push   %esi
  800337:	53                   	push   %ebx
	asm volatile("int %1\n"
  800338:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033d:	8b 55 08             	mov    0x8(%ebp),%edx
  800340:	b8 0e 00 00 00       	mov    $0xe,%eax
  800345:	89 cb                	mov    %ecx,%ebx
  800347:	89 cf                	mov    %ecx,%edi
  800349:	89 ce                	mov    %ecx,%esi
  80034b:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  80034d:	5b                   	pop    %ebx
  80034e:	5e                   	pop    %esi
  80034f:	5f                   	pop    %edi
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	56                   	push   %esi
  800356:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800357:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80035a:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800360:	e8 bf fd ff ff       	call   800124 <sys_getenvid>
  800365:	83 ec 0c             	sub    $0xc,%esp
  800368:	ff 75 0c             	pushl  0xc(%ebp)
  80036b:	ff 75 08             	pushl  0x8(%ebp)
  80036e:	56                   	push   %esi
  80036f:	50                   	push   %eax
  800370:	68 a4 11 80 00       	push   $0x8011a4
  800375:	e8 b3 00 00 00       	call   80042d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80037a:	83 c4 18             	add    $0x18,%esp
  80037d:	53                   	push   %ebx
  80037e:	ff 75 10             	pushl  0x10(%ebp)
  800381:	e8 56 00 00 00       	call   8003dc <vcprintf>
	cprintf("\n");
  800386:	c7 04 24 6c 11 80 00 	movl   $0x80116c,(%esp)
  80038d:	e8 9b 00 00 00       	call   80042d <cprintf>
  800392:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800395:	cc                   	int3   
  800396:	eb fd                	jmp    800395 <_panic+0x43>

00800398 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	53                   	push   %ebx
  80039c:	83 ec 04             	sub    $0x4,%esp
  80039f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003a2:	8b 13                	mov    (%ebx),%edx
  8003a4:	8d 42 01             	lea    0x1(%edx),%eax
  8003a7:	89 03                	mov    %eax,(%ebx)
  8003a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003b0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b5:	74 09                	je     8003c0 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003b7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003be:	c9                   	leave  
  8003bf:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	68 ff 00 00 00       	push   $0xff
  8003c8:	8d 43 08             	lea    0x8(%ebx),%eax
  8003cb:	50                   	push   %eax
  8003cc:	e8 d5 fc ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  8003d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d7:	83 c4 10             	add    $0x10,%esp
  8003da:	eb db                	jmp    8003b7 <putch+0x1f>

008003dc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ec:	00 00 00 
	b.cnt = 0;
  8003ef:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003f6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f9:	ff 75 0c             	pushl  0xc(%ebp)
  8003fc:	ff 75 08             	pushl  0x8(%ebp)
  8003ff:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800405:	50                   	push   %eax
  800406:	68 98 03 80 00       	push   $0x800398
  80040b:	e8 fb 00 00 00       	call   80050b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800410:	83 c4 08             	add    $0x8,%esp
  800413:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800419:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80041f:	50                   	push   %eax
  800420:	e8 81 fc ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  800425:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80042b:	c9                   	leave  
  80042c:	c3                   	ret    

0080042d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800433:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800436:	50                   	push   %eax
  800437:	ff 75 08             	pushl  0x8(%ebp)
  80043a:	e8 9d ff ff ff       	call   8003dc <vcprintf>
	va_end(ap);

	return cnt;
}
  80043f:	c9                   	leave  
  800440:	c3                   	ret    

00800441 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	57                   	push   %edi
  800445:	56                   	push   %esi
  800446:	53                   	push   %ebx
  800447:	83 ec 1c             	sub    $0x1c,%esp
  80044a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80044d:	89 d3                	mov    %edx,%ebx
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800455:	8b 45 10             	mov    0x10(%ebp),%eax
  800458:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  80045b:	89 c2                	mov    %eax,%edx
  80045d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800462:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800465:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800468:	39 c6                	cmp    %eax,%esi
  80046a:	89 f8                	mov    %edi,%eax
  80046c:	19 c8                	sbb    %ecx,%eax
  80046e:	73 32                	jae    8004a2 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	83 ec 04             	sub    $0x4,%esp
  800477:	ff 75 e4             	pushl  -0x1c(%ebp)
  80047a:	ff 75 e0             	pushl  -0x20(%ebp)
  80047d:	57                   	push   %edi
  80047e:	56                   	push   %esi
  80047f:	e8 8c 0b 00 00       	call   801010 <__umoddi3>
  800484:	83 c4 14             	add    $0x14,%esp
  800487:	0f be 80 c7 11 80 00 	movsbl 0x8011c7(%eax),%eax
  80048e:	50                   	push   %eax
  80048f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800492:	ff d0                	call   *%eax
	return remain - 1;
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	83 e8 01             	sub    $0x1,%eax
}
  80049a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049d:	5b                   	pop    %ebx
  80049e:	5e                   	pop    %esi
  80049f:	5f                   	pop    %edi
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  8004a2:	83 ec 0c             	sub    $0xc,%esp
  8004a5:	ff 75 18             	pushl  0x18(%ebp)
  8004a8:	ff 75 14             	pushl  0x14(%ebp)
  8004ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8004ae:	83 ec 08             	sub    $0x8,%esp
  8004b1:	51                   	push   %ecx
  8004b2:	52                   	push   %edx
  8004b3:	57                   	push   %edi
  8004b4:	56                   	push   %esi
  8004b5:	e8 46 0a 00 00       	call   800f00 <__udivdi3>
  8004ba:	83 c4 18             	add    $0x18,%esp
  8004bd:	52                   	push   %edx
  8004be:	50                   	push   %eax
  8004bf:	89 da                	mov    %ebx,%edx
  8004c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004c4:	e8 78 ff ff ff       	call   800441 <printnum_helper>
  8004c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004cc:	83 c4 20             	add    $0x20,%esp
  8004cf:	eb 9f                	jmp    800470 <printnum_helper+0x2f>

008004d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d1:	55                   	push   %ebp
  8004d2:	89 e5                	mov    %esp,%ebp
  8004d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004db:	8b 10                	mov    (%eax),%edx
  8004dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e0:	73 0a                	jae    8004ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e5:	89 08                	mov    %ecx,(%eax)
  8004e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ea:	88 02                	mov    %al,(%edx)
}
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    

008004ee <printfmt>:
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f7:	50                   	push   %eax
  8004f8:	ff 75 10             	pushl  0x10(%ebp)
  8004fb:	ff 75 0c             	pushl  0xc(%ebp)
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 05 00 00 00       	call   80050b <vprintfmt>
}
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	c9                   	leave  
  80050a:	c3                   	ret    

0080050b <vprintfmt>:
{
  80050b:	55                   	push   %ebp
  80050c:	89 e5                	mov    %esp,%ebp
  80050e:	57                   	push   %edi
  80050f:	56                   	push   %esi
  800510:	53                   	push   %ebx
  800511:	83 ec 3c             	sub    $0x3c,%esp
  800514:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800517:	8b 75 0c             	mov    0xc(%ebp),%esi
  80051a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80051d:	e9 3f 05 00 00       	jmp    800a61 <vprintfmt+0x556>
		padc = ' ';
  800522:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  800526:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  80052d:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  800534:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  80053b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  800542:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800549:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8d 47 01             	lea    0x1(%edi),%eax
  800551:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800554:	0f b6 17             	movzbl (%edi),%edx
  800557:	8d 42 dd             	lea    -0x23(%edx),%eax
  80055a:	3c 55                	cmp    $0x55,%al
  80055c:	0f 87 98 05 00 00    	ja     800afa <vprintfmt+0x5ef>
  800562:	0f b6 c0             	movzbl %al,%eax
  800565:	ff 24 85 00 13 80 00 	jmp    *0x801300(,%eax,4)
  80056c:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  80056f:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  800573:	eb d9                	jmp    80054e <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  800578:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  80057f:	eb cd                	jmp    80054e <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800581:	0f b6 d2             	movzbl %dl,%edx
  800584:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800587:	b8 00 00 00 00       	mov    $0x0,%eax
  80058c:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  80058f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800592:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800596:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800599:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80059c:	83 fb 09             	cmp    $0x9,%ebx
  80059f:	77 5c                	ja     8005fd <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  8005a1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005a4:	eb e9                	jmp    80058f <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  8005a9:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  8005ad:	eb 9f                	jmp    80054e <vprintfmt+0x43>
			precision = va_arg(ap, int);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ba:	8d 40 04             	lea    0x4(%eax),%eax
  8005bd:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c0:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8005c3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c7:	79 85                	jns    80054e <vprintfmt+0x43>
				width = precision, precision = -1;
  8005c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005d6:	e9 73 ff ff ff       	jmp    80054e <vprintfmt+0x43>
  8005db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	0f 48 c1             	cmovs  %ecx,%eax
  8005e3:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005e9:	e9 60 ff ff ff       	jmp    80054e <vprintfmt+0x43>
  8005ee:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8005f1:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8005f8:	e9 51 ff ff ff       	jmp    80054e <vprintfmt+0x43>
  8005fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800600:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800603:	eb be                	jmp    8005c3 <vprintfmt+0xb8>
			lflag++;
  800605:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800609:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  80060c:	e9 3d ff ff ff       	jmp    80054e <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 78 04             	lea    0x4(%eax),%edi
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	56                   	push   %esi
  80061b:	ff 30                	pushl  (%eax)
  80061d:	ff d3                	call   *%ebx
			break;
  80061f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800622:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800625:	e9 34 04 00 00       	jmp    800a5e <vprintfmt+0x553>
			err = va_arg(ap, int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 78 04             	lea    0x4(%eax),%edi
  800630:	8b 00                	mov    (%eax),%eax
  800632:	99                   	cltd   
  800633:	31 d0                	xor    %edx,%eax
  800635:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800637:	83 f8 08             	cmp    $0x8,%eax
  80063a:	7f 23                	jg     80065f <vprintfmt+0x154>
  80063c:	8b 14 85 60 14 80 00 	mov    0x801460(,%eax,4),%edx
  800643:	85 d2                	test   %edx,%edx
  800645:	74 18                	je     80065f <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  800647:	52                   	push   %edx
  800648:	68 e8 11 80 00       	push   $0x8011e8
  80064d:	56                   	push   %esi
  80064e:	53                   	push   %ebx
  80064f:	e8 9a fe ff ff       	call   8004ee <printfmt>
  800654:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800657:	89 7d 14             	mov    %edi,0x14(%ebp)
  80065a:	e9 ff 03 00 00       	jmp    800a5e <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  80065f:	50                   	push   %eax
  800660:	68 df 11 80 00       	push   $0x8011df
  800665:	56                   	push   %esi
  800666:	53                   	push   %ebx
  800667:	e8 82 fe ff ff       	call   8004ee <printfmt>
  80066c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80066f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800672:	e9 e7 03 00 00       	jmp    800a5e <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	83 c0 04             	add    $0x4,%eax
  80067d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800685:	85 c9                	test   %ecx,%ecx
  800687:	b8 d8 11 80 00       	mov    $0x8011d8,%eax
  80068c:	0f 45 c1             	cmovne %ecx,%eax
  80068f:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800692:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800696:	7e 06                	jle    80069e <vprintfmt+0x193>
  800698:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  80069c:	75 0d                	jne    8006ab <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006a1:	89 c7                	mov    %eax,%edi
  8006a3:	03 45 d8             	add    -0x28(%ebp),%eax
  8006a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a9:	eb 53                	jmp    8006fe <vprintfmt+0x1f3>
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b1:	50                   	push   %eax
  8006b2:	e8 eb 04 00 00       	call   800ba2 <strnlen>
  8006b7:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8006ba:	29 c1                	sub    %eax,%ecx
  8006bc:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006c4:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8006c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cb:	eb 0f                	jmp    8006dc <vprintfmt+0x1d1>
					putch(padc, putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	56                   	push   %esi
  8006d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8006d4:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d6:	83 ef 01             	sub    $0x1,%edi
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	85 ff                	test   %edi,%edi
  8006de:	7f ed                	jg     8006cd <vprintfmt+0x1c2>
  8006e0:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8006e3:	85 c9                	test   %ecx,%ecx
  8006e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ea:	0f 49 c1             	cmovns %ecx,%eax
  8006ed:	29 c1                	sub    %eax,%ecx
  8006ef:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8006f2:	eb aa                	jmp    80069e <vprintfmt+0x193>
					putch(ch, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	56                   	push   %esi
  8006f8:	52                   	push   %edx
  8006f9:	ff d3                	call   *%ebx
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800701:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800703:	83 c7 01             	add    $0x1,%edi
  800706:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070a:	0f be d0             	movsbl %al,%edx
  80070d:	85 d2                	test   %edx,%edx
  80070f:	74 2e                	je     80073f <vprintfmt+0x234>
  800711:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800715:	78 06                	js     80071d <vprintfmt+0x212>
  800717:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80071b:	78 1e                	js     80073b <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  80071d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800721:	74 d1                	je     8006f4 <vprintfmt+0x1e9>
  800723:	0f be c0             	movsbl %al,%eax
  800726:	83 e8 20             	sub    $0x20,%eax
  800729:	83 f8 5e             	cmp    $0x5e,%eax
  80072c:	76 c6                	jbe    8006f4 <vprintfmt+0x1e9>
					putch('?', putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	56                   	push   %esi
  800732:	6a 3f                	push   $0x3f
  800734:	ff d3                	call   *%ebx
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb c3                	jmp    8006fe <vprintfmt+0x1f3>
  80073b:	89 cf                	mov    %ecx,%edi
  80073d:	eb 02                	jmp    800741 <vprintfmt+0x236>
  80073f:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  800741:	85 ff                	test   %edi,%edi
  800743:	7e 10                	jle    800755 <vprintfmt+0x24a>
				putch(' ', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	56                   	push   %esi
  800749:	6a 20                	push   $0x20
  80074b:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80074d:	83 ef 01             	sub    $0x1,%edi
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	eb ec                	jmp    800741 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800755:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800758:	89 45 14             	mov    %eax,0x14(%ebp)
  80075b:	e9 fe 02 00 00       	jmp    800a5e <vprintfmt+0x553>
	if (lflag >= 2)
  800760:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800764:	7f 21                	jg     800787 <vprintfmt+0x27c>
	else if (lflag)
  800766:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  80076a:	74 79                	je     8007e5 <vprintfmt+0x2da>
		return va_arg(*ap, long);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8b 00                	mov    (%eax),%eax
  800771:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800774:	89 c1                	mov    %eax,%ecx
  800776:	c1 f9 1f             	sar    $0x1f,%ecx
  800779:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	8d 40 04             	lea    0x4(%eax),%eax
  800782:	89 45 14             	mov    %eax,0x14(%ebp)
  800785:	eb 17                	jmp    80079e <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	8b 50 04             	mov    0x4(%eax),%edx
  80078d:	8b 00                	mov    (%eax),%eax
  80078f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800792:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8d 40 08             	lea    0x8(%eax),%eax
  80079b:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  80079e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007a1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007a7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  8007aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007ae:	78 50                	js     800800 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  8007b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007b3:	c1 fa 1f             	sar    $0x1f,%edx
  8007b6:	89 d0                	mov    %edx,%eax
  8007b8:	2b 45 e0             	sub    -0x20(%ebp),%eax
  8007bb:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  8007be:	85 d2                	test   %edx,%edx
  8007c0:	0f 89 14 02 00 00    	jns    8009da <vprintfmt+0x4cf>
  8007c6:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007ca:	0f 84 0a 02 00 00    	je     8009da <vprintfmt+0x4cf>
				putch('+', putdat);
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	56                   	push   %esi
  8007d4:	6a 2b                	push   $0x2b
  8007d6:	ff d3                	call   *%ebx
  8007d8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007db:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e0:	e9 5c 01 00 00       	jmp    800941 <vprintfmt+0x436>
		return va_arg(*ap, int);
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007ed:	89 c1                	mov    %eax,%ecx
  8007ef:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8d 40 04             	lea    0x4(%eax),%eax
  8007fb:	89 45 14             	mov    %eax,0x14(%ebp)
  8007fe:	eb 9e                	jmp    80079e <vprintfmt+0x293>
				putch('-', putdat);
  800800:	83 ec 08             	sub    $0x8,%esp
  800803:	56                   	push   %esi
  800804:	6a 2d                	push   $0x2d
  800806:	ff d3                	call   *%ebx
				num = -(long long) num;
  800808:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80080b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80080e:	f7 d8                	neg    %eax
  800810:	83 d2 00             	adc    $0x0,%edx
  800813:	f7 da                	neg    %edx
  800815:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800818:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80081b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800823:	e9 19 01 00 00       	jmp    800941 <vprintfmt+0x436>
	if (lflag >= 2)
  800828:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  80082c:	7f 29                	jg     800857 <vprintfmt+0x34c>
	else if (lflag)
  80082e:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800832:	74 44                	je     800878 <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800834:	8b 45 14             	mov    0x14(%ebp),%eax
  800837:	8b 00                	mov    (%eax),%eax
  800839:	ba 00 00 00 00       	mov    $0x0,%edx
  80083e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800841:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	8d 40 04             	lea    0x4(%eax),%eax
  80084a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80084d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800852:	e9 ea 00 00 00       	jmp    800941 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	8b 50 04             	mov    0x4(%eax),%edx
  80085d:	8b 00                	mov    (%eax),%eax
  80085f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800862:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800865:	8b 45 14             	mov    0x14(%ebp),%eax
  800868:	8d 40 08             	lea    0x8(%eax),%eax
  80086b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80086e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800873:	e9 c9 00 00 00       	jmp    800941 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8b 00                	mov    (%eax),%eax
  80087d:	ba 00 00 00 00       	mov    $0x0,%edx
  800882:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800885:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800888:	8b 45 14             	mov    0x14(%ebp),%eax
  80088b:	8d 40 04             	lea    0x4(%eax),%eax
  80088e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800891:	b8 0a 00 00 00       	mov    $0xa,%eax
  800896:	e9 a6 00 00 00       	jmp    800941 <vprintfmt+0x436>
			putch('0', putdat);
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	56                   	push   %esi
  80089f:	6a 30                	push   $0x30
  8008a1:	ff d3                	call   *%ebx
	if (lflag >= 2)
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  8008aa:	7f 26                	jg     8008d2 <vprintfmt+0x3c7>
	else if (lflag)
  8008ac:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  8008b0:	74 3e                	je     8008f0 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8b 00                	mov    (%eax),%eax
  8008b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8008bc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008bf:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c5:	8d 40 04             	lea    0x4(%eax),%eax
  8008c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008cb:	b8 08 00 00 00       	mov    $0x8,%eax
  8008d0:	eb 6f                	jmp    800941 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  8008d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d5:	8b 50 04             	mov    0x4(%eax),%edx
  8008d8:	8b 00                	mov    (%eax),%eax
  8008da:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008dd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8d 40 08             	lea    0x8(%eax),%eax
  8008e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8008e9:	b8 08 00 00 00       	mov    $0x8,%eax
  8008ee:	eb 51                	jmp    800941 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8008f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f3:	8b 00                	mov    (%eax),%eax
  8008f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008fd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800900:	8b 45 14             	mov    0x14(%ebp),%eax
  800903:	8d 40 04             	lea    0x4(%eax),%eax
  800906:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800909:	b8 08 00 00 00       	mov    $0x8,%eax
  80090e:	eb 31                	jmp    800941 <vprintfmt+0x436>
			putch('0', putdat);
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	56                   	push   %esi
  800914:	6a 30                	push   $0x30
  800916:	ff d3                	call   *%ebx
			putch('x', putdat);
  800918:	83 c4 08             	add    $0x8,%esp
  80091b:	56                   	push   %esi
  80091c:	6a 78                	push   $0x78
  80091e:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800920:	8b 45 14             	mov    0x14(%ebp),%eax
  800923:	8b 00                	mov    (%eax),%eax
  800925:	ba 00 00 00 00       	mov    $0x0,%edx
  80092a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80092d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800930:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800933:	8b 45 14             	mov    0x14(%ebp),%eax
  800936:	8d 40 04             	lea    0x4(%eax),%eax
  800939:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80093c:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800941:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800945:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800948:	89 c1                	mov    %eax,%ecx
  80094a:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  80094d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800950:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800955:	89 c2                	mov    %eax,%edx
  800957:	39 c1                	cmp    %eax,%ecx
  800959:	0f 87 85 00 00 00    	ja     8009e4 <vprintfmt+0x4d9>
		tmp /= base;
  80095f:	89 d0                	mov    %edx,%eax
  800961:	ba 00 00 00 00       	mov    $0x0,%edx
  800966:	f7 f1                	div    %ecx
		len++;
  800968:	83 c7 01             	add    $0x1,%edi
  80096b:	eb e8                	jmp    800955 <vprintfmt+0x44a>
	if (lflag >= 2)
  80096d:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800971:	7f 26                	jg     800999 <vprintfmt+0x48e>
	else if (lflag)
  800973:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800977:	74 3e                	je     8009b7 <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800979:	8b 45 14             	mov    0x14(%ebp),%eax
  80097c:	8b 00                	mov    (%eax),%eax
  80097e:	ba 00 00 00 00       	mov    $0x0,%edx
  800983:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800986:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800989:	8b 45 14             	mov    0x14(%ebp),%eax
  80098c:	8d 40 04             	lea    0x4(%eax),%eax
  80098f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800992:	b8 10 00 00 00       	mov    $0x10,%eax
  800997:	eb a8                	jmp    800941 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800999:	8b 45 14             	mov    0x14(%ebp),%eax
  80099c:	8b 50 04             	mov    0x4(%eax),%edx
  80099f:	8b 00                	mov    (%eax),%eax
  8009a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009a4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009aa:	8d 40 08             	lea    0x8(%eax),%eax
  8009ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009b0:	b8 10 00 00 00       	mov    $0x10,%eax
  8009b5:	eb 8a                	jmp    800941 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  8009b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ba:	8b 00                	mov    (%eax),%eax
  8009bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8009c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ca:	8d 40 04             	lea    0x4(%eax),%eax
  8009cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8009d0:	b8 10 00 00 00       	mov    $0x10,%eax
  8009d5:	e9 67 ff ff ff       	jmp    800941 <vprintfmt+0x436>
			base = 10;
  8009da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009df:	e9 5d ff ff ff       	jmp    800941 <vprintfmt+0x436>
  8009e4:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  8009e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009ea:	29 f8                	sub    %edi,%eax
  8009ec:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  8009ee:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  8009f2:	74 15                	je     800a09 <vprintfmt+0x4fe>
		while (width > 0) {
  8009f4:	85 ff                	test   %edi,%edi
  8009f6:	7e 48                	jle    800a40 <vprintfmt+0x535>
			putch(padc, putdat);
  8009f8:	83 ec 08             	sub    $0x8,%esp
  8009fb:	56                   	push   %esi
  8009fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8009ff:	ff d3                	call   *%ebx
			width--;
  800a01:	83 ef 01             	sub    $0x1,%edi
  800a04:	83 c4 10             	add    $0x10,%esp
  800a07:	eb eb                	jmp    8009f4 <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a09:	83 ec 0c             	sub    $0xc,%esp
  800a0c:	6a 2d                	push   $0x2d
  800a0e:	ff 75 cc             	pushl  -0x34(%ebp)
  800a11:	ff 75 c8             	pushl  -0x38(%ebp)
  800a14:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a17:	ff 75 d0             	pushl  -0x30(%ebp)
  800a1a:	89 f2                	mov    %esi,%edx
  800a1c:	89 d8                	mov    %ebx,%eax
  800a1e:	e8 1e fa ff ff       	call   800441 <printnum_helper>
		width -= len;
  800a23:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800a26:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800a29:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800a2c:	85 ff                	test   %edi,%edi
  800a2e:	7e 2e                	jle    800a5e <vprintfmt+0x553>
			putch(padc, putdat);
  800a30:	83 ec 08             	sub    $0x8,%esp
  800a33:	56                   	push   %esi
  800a34:	6a 20                	push   $0x20
  800a36:	ff d3                	call   *%ebx
			width--;
  800a38:	83 ef 01             	sub    $0x1,%edi
  800a3b:	83 c4 10             	add    $0x10,%esp
  800a3e:	eb ec                	jmp    800a2c <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800a40:	83 ec 0c             	sub    $0xc,%esp
  800a43:	ff 75 e0             	pushl  -0x20(%ebp)
  800a46:	ff 75 cc             	pushl  -0x34(%ebp)
  800a49:	ff 75 c8             	pushl  -0x38(%ebp)
  800a4c:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a4f:	ff 75 d0             	pushl  -0x30(%ebp)
  800a52:	89 f2                	mov    %esi,%edx
  800a54:	89 d8                	mov    %ebx,%eax
  800a56:	e8 e6 f9 ff ff       	call   800441 <printnum_helper>
  800a5b:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800a5e:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a61:	83 c7 01             	add    $0x1,%edi
  800a64:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a68:	83 f8 25             	cmp    $0x25,%eax
  800a6b:	0f 84 b1 fa ff ff    	je     800522 <vprintfmt+0x17>
			if (ch == '\0')
  800a71:	85 c0                	test   %eax,%eax
  800a73:	0f 84 a1 00 00 00    	je     800b1a <vprintfmt+0x60f>
			putch(ch, putdat);
  800a79:	83 ec 08             	sub    $0x8,%esp
  800a7c:	56                   	push   %esi
  800a7d:	50                   	push   %eax
  800a7e:	ff d3                	call   *%ebx
  800a80:	83 c4 10             	add    $0x10,%esp
  800a83:	eb dc                	jmp    800a61 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800a85:	8b 45 14             	mov    0x14(%ebp),%eax
  800a88:	83 c0 04             	add    $0x4,%eax
  800a8b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a8e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a91:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800a93:	85 ff                	test   %edi,%edi
  800a95:	74 15                	je     800aac <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800a97:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800a9d:	7f 29                	jg     800ac8 <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800a9f:	0f b6 06             	movzbl (%esi),%eax
  800aa2:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800aa4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800aa7:	89 45 14             	mov    %eax,0x14(%ebp)
  800aaa:	eb b2                	jmp    800a5e <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800aac:	68 80 12 80 00       	push   $0x801280
  800ab1:	68 e8 11 80 00       	push   $0x8011e8
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
  800ab8:	e8 31 fa ff ff       	call   8004ee <printfmt>
  800abd:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800ac0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ac3:	89 45 14             	mov    %eax,0x14(%ebp)
  800ac6:	eb 96                	jmp    800a5e <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800ac8:	68 b8 12 80 00       	push   $0x8012b8
  800acd:	68 e8 11 80 00       	push   $0x8011e8
  800ad2:	56                   	push   %esi
  800ad3:	53                   	push   %ebx
  800ad4:	e8 15 fa ff ff       	call   8004ee <printfmt>
				*res = -1;
  800ad9:	c6 07 ff             	movb   $0xff,(%edi)
  800adc:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800adf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ae2:	89 45 14             	mov    %eax,0x14(%ebp)
  800ae5:	e9 74 ff ff ff       	jmp    800a5e <vprintfmt+0x553>
			putch(ch, putdat);
  800aea:	83 ec 08             	sub    $0x8,%esp
  800aed:	56                   	push   %esi
  800aee:	6a 25                	push   $0x25
  800af0:	ff d3                	call   *%ebx
			break;
  800af2:	83 c4 10             	add    $0x10,%esp
  800af5:	e9 64 ff ff ff       	jmp    800a5e <vprintfmt+0x553>
			putch('%', putdat);
  800afa:	83 ec 08             	sub    $0x8,%esp
  800afd:	56                   	push   %esi
  800afe:	6a 25                	push   $0x25
  800b00:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	89 f8                	mov    %edi,%eax
  800b07:	eb 03                	jmp    800b0c <vprintfmt+0x601>
  800b09:	83 e8 01             	sub    $0x1,%eax
  800b0c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800b10:	75 f7                	jne    800b09 <vprintfmt+0x5fe>
  800b12:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b15:	e9 44 ff ff ff       	jmp    800a5e <vprintfmt+0x553>
}
  800b1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	83 ec 18             	sub    $0x18,%esp
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b31:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b35:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b38:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	74 26                	je     800b69 <vsnprintf+0x47>
  800b43:	85 d2                	test   %edx,%edx
  800b45:	7e 22                	jle    800b69 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b47:	ff 75 14             	pushl  0x14(%ebp)
  800b4a:	ff 75 10             	pushl  0x10(%ebp)
  800b4d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b50:	50                   	push   %eax
  800b51:	68 d1 04 80 00       	push   $0x8004d1
  800b56:	e8 b0 f9 ff ff       	call   80050b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b64:	83 c4 10             	add    $0x10,%esp
}
  800b67:	c9                   	leave  
  800b68:	c3                   	ret    
		return -E_INVAL;
  800b69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b6e:	eb f7                	jmp    800b67 <vsnprintf+0x45>

00800b70 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b76:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b79:	50                   	push   %eax
  800b7a:	ff 75 10             	pushl  0x10(%ebp)
  800b7d:	ff 75 0c             	pushl  0xc(%ebp)
  800b80:	ff 75 08             	pushl  0x8(%ebp)
  800b83:	e8 9a ff ff ff       	call   800b22 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b88:	c9                   	leave  
  800b89:	c3                   	ret    

00800b8a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b90:	b8 00 00 00 00       	mov    $0x0,%eax
  800b95:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b99:	74 05                	je     800ba0 <strlen+0x16>
		n++;
  800b9b:	83 c0 01             	add    $0x1,%eax
  800b9e:	eb f5                	jmp    800b95 <strlen+0xb>
	return n;
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	39 c2                	cmp    %eax,%edx
  800bb2:	74 0d                	je     800bc1 <strnlen+0x1f>
  800bb4:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800bb8:	74 05                	je     800bbf <strnlen+0x1d>
		n++;
  800bba:	83 c2 01             	add    $0x1,%edx
  800bbd:	eb f1                	jmp    800bb0 <strnlen+0xe>
  800bbf:	89 d0                	mov    %edx,%eax
	return n;
}
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	53                   	push   %ebx
  800bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd2:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bd6:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bd9:	83 c2 01             	add    $0x1,%edx
  800bdc:	84 c9                	test   %cl,%cl
  800bde:	75 f2                	jne    800bd2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800be0:	5b                   	pop    %ebx
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	53                   	push   %ebx
  800be7:	83 ec 10             	sub    $0x10,%esp
  800bea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bed:	53                   	push   %ebx
  800bee:	e8 97 ff ff ff       	call   800b8a <strlen>
  800bf3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800bf6:	ff 75 0c             	pushl  0xc(%ebp)
  800bf9:	01 d8                	add    %ebx,%eax
  800bfb:	50                   	push   %eax
  800bfc:	e8 c2 ff ff ff       	call   800bc3 <strcpy>
	return dst;
}
  800c01:	89 d8                	mov    %ebx,%eax
  800c03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c06:	c9                   	leave  
  800c07:	c3                   	ret    

00800c08 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
  800c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c13:	89 c6                	mov    %eax,%esi
  800c15:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c18:	89 c2                	mov    %eax,%edx
  800c1a:	39 f2                	cmp    %esi,%edx
  800c1c:	74 11                	je     800c2f <strncpy+0x27>
		*dst++ = *src;
  800c1e:	83 c2 01             	add    $0x1,%edx
  800c21:	0f b6 19             	movzbl (%ecx),%ebx
  800c24:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c27:	80 fb 01             	cmp    $0x1,%bl
  800c2a:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800c2d:	eb eb                	jmp    800c1a <strncpy+0x12>
	}
	return ret;
}
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	8b 75 08             	mov    0x8(%ebp),%esi
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	8b 55 10             	mov    0x10(%ebp),%edx
  800c41:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c43:	85 d2                	test   %edx,%edx
  800c45:	74 21                	je     800c68 <strlcpy+0x35>
  800c47:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c4b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800c4d:	39 c2                	cmp    %eax,%edx
  800c4f:	74 14                	je     800c65 <strlcpy+0x32>
  800c51:	0f b6 19             	movzbl (%ecx),%ebx
  800c54:	84 db                	test   %bl,%bl
  800c56:	74 0b                	je     800c63 <strlcpy+0x30>
			*dst++ = *src++;
  800c58:	83 c1 01             	add    $0x1,%ecx
  800c5b:	83 c2 01             	add    $0x1,%edx
  800c5e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c61:	eb ea                	jmp    800c4d <strlcpy+0x1a>
  800c63:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c65:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c68:	29 f0                	sub    %esi,%eax
}
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c74:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c77:	0f b6 01             	movzbl (%ecx),%eax
  800c7a:	84 c0                	test   %al,%al
  800c7c:	74 0c                	je     800c8a <strcmp+0x1c>
  800c7e:	3a 02                	cmp    (%edx),%al
  800c80:	75 08                	jne    800c8a <strcmp+0x1c>
		p++, q++;
  800c82:	83 c1 01             	add    $0x1,%ecx
  800c85:	83 c2 01             	add    $0x1,%edx
  800c88:	eb ed                	jmp    800c77 <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c8a:	0f b6 c0             	movzbl %al,%eax
  800c8d:	0f b6 12             	movzbl (%edx),%edx
  800c90:	29 d0                	sub    %edx,%eax
}
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	53                   	push   %ebx
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9e:	89 c3                	mov    %eax,%ebx
  800ca0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ca3:	eb 06                	jmp    800cab <strncmp+0x17>
		n--, p++, q++;
  800ca5:	83 c0 01             	add    $0x1,%eax
  800ca8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800cab:	39 d8                	cmp    %ebx,%eax
  800cad:	74 16                	je     800cc5 <strncmp+0x31>
  800caf:	0f b6 08             	movzbl (%eax),%ecx
  800cb2:	84 c9                	test   %cl,%cl
  800cb4:	74 04                	je     800cba <strncmp+0x26>
  800cb6:	3a 0a                	cmp    (%edx),%cl
  800cb8:	74 eb                	je     800ca5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cba:	0f b6 00             	movzbl (%eax),%eax
  800cbd:	0f b6 12             	movzbl (%edx),%edx
  800cc0:	29 d0                	sub    %edx,%eax
}
  800cc2:	5b                   	pop    %ebx
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    
		return 0;
  800cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cca:	eb f6                	jmp    800cc2 <strncmp+0x2e>

00800ccc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cd6:	0f b6 10             	movzbl (%eax),%edx
  800cd9:	84 d2                	test   %dl,%dl
  800cdb:	74 09                	je     800ce6 <strchr+0x1a>
		if (*s == c)
  800cdd:	38 ca                	cmp    %cl,%dl
  800cdf:	74 0a                	je     800ceb <strchr+0x1f>
	for (; *s; s++)
  800ce1:	83 c0 01             	add    $0x1,%eax
  800ce4:	eb f0                	jmp    800cd6 <strchr+0xa>
			return (char *) s;
	return 0;
  800ce6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800cfa:	38 ca                	cmp    %cl,%dl
  800cfc:	74 09                	je     800d07 <strfind+0x1a>
  800cfe:	84 d2                	test   %dl,%dl
  800d00:	74 05                	je     800d07 <strfind+0x1a>
	for (; *s; s++)
  800d02:	83 c0 01             	add    $0x1,%eax
  800d05:	eb f0                	jmp    800cf7 <strfind+0xa>
			break;
	return (char *) s;
}
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    

00800d09 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d15:	85 c9                	test   %ecx,%ecx
  800d17:	74 31                	je     800d4a <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d19:	89 f8                	mov    %edi,%eax
  800d1b:	09 c8                	or     %ecx,%eax
  800d1d:	a8 03                	test   $0x3,%al
  800d1f:	75 23                	jne    800d44 <memset+0x3b>
		c &= 0xFF;
  800d21:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d25:	89 d3                	mov    %edx,%ebx
  800d27:	c1 e3 08             	shl    $0x8,%ebx
  800d2a:	89 d0                	mov    %edx,%eax
  800d2c:	c1 e0 18             	shl    $0x18,%eax
  800d2f:	89 d6                	mov    %edx,%esi
  800d31:	c1 e6 10             	shl    $0x10,%esi
  800d34:	09 f0                	or     %esi,%eax
  800d36:	09 c2                	or     %eax,%edx
  800d38:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d3a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800d3d:	89 d0                	mov    %edx,%eax
  800d3f:	fc                   	cld    
  800d40:	f3 ab                	rep stos %eax,%es:(%edi)
  800d42:	eb 06                	jmp    800d4a <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d47:	fc                   	cld    
  800d48:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d4a:	89 f8                	mov    %edi,%eax
  800d4c:	5b                   	pop    %ebx
  800d4d:	5e                   	pop    %esi
  800d4e:	5f                   	pop    %edi
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	57                   	push   %edi
  800d55:	56                   	push   %esi
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
  800d59:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d5c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d5f:	39 c6                	cmp    %eax,%esi
  800d61:	73 32                	jae    800d95 <memmove+0x44>
  800d63:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d66:	39 c2                	cmp    %eax,%edx
  800d68:	76 2b                	jbe    800d95 <memmove+0x44>
		s += n;
		d += n;
  800d6a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d6d:	89 fe                	mov    %edi,%esi
  800d6f:	09 ce                	or     %ecx,%esi
  800d71:	09 d6                	or     %edx,%esi
  800d73:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d79:	75 0e                	jne    800d89 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d7b:	83 ef 04             	sub    $0x4,%edi
  800d7e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d81:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d84:	fd                   	std    
  800d85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d87:	eb 09                	jmp    800d92 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d89:	83 ef 01             	sub    $0x1,%edi
  800d8c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d8f:	fd                   	std    
  800d90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d92:	fc                   	cld    
  800d93:	eb 1a                	jmp    800daf <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d95:	89 c2                	mov    %eax,%edx
  800d97:	09 ca                	or     %ecx,%edx
  800d99:	09 f2                	or     %esi,%edx
  800d9b:	f6 c2 03             	test   $0x3,%dl
  800d9e:	75 0a                	jne    800daa <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800da0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800da3:	89 c7                	mov    %eax,%edi
  800da5:	fc                   	cld    
  800da6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800da8:	eb 05                	jmp    800daf <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800daa:	89 c7                	mov    %eax,%edi
  800dac:	fc                   	cld    
  800dad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    

00800db3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800db3:	55                   	push   %ebp
  800db4:	89 e5                	mov    %esp,%ebp
  800db6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800db9:	ff 75 10             	pushl  0x10(%ebp)
  800dbc:	ff 75 0c             	pushl  0xc(%ebp)
  800dbf:	ff 75 08             	pushl  0x8(%ebp)
  800dc2:	e8 8a ff ff ff       	call   800d51 <memmove>
}
  800dc7:	c9                   	leave  
  800dc8:	c3                   	ret    

00800dc9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
  800dce:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dd4:	89 c6                	mov    %eax,%esi
  800dd6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dd9:	39 f0                	cmp    %esi,%eax
  800ddb:	74 1c                	je     800df9 <memcmp+0x30>
		if (*s1 != *s2)
  800ddd:	0f b6 08             	movzbl (%eax),%ecx
  800de0:	0f b6 1a             	movzbl (%edx),%ebx
  800de3:	38 d9                	cmp    %bl,%cl
  800de5:	75 08                	jne    800def <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800de7:	83 c0 01             	add    $0x1,%eax
  800dea:	83 c2 01             	add    $0x1,%edx
  800ded:	eb ea                	jmp    800dd9 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800def:	0f b6 c1             	movzbl %cl,%eax
  800df2:	0f b6 db             	movzbl %bl,%ebx
  800df5:	29 d8                	sub    %ebx,%eax
  800df7:	eb 05                	jmp    800dfe <memcmp+0x35>
	}

	return 0;
  800df9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e0b:	89 c2                	mov    %eax,%edx
  800e0d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e10:	39 d0                	cmp    %edx,%eax
  800e12:	73 09                	jae    800e1d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e14:	38 08                	cmp    %cl,(%eax)
  800e16:	74 05                	je     800e1d <memfind+0x1b>
	for (; s < ends; s++)
  800e18:	83 c0 01             	add    $0x1,%eax
  800e1b:	eb f3                	jmp    800e10 <memfind+0xe>
			break;
	return (void *) s;
}
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e2b:	eb 03                	jmp    800e30 <strtol+0x11>
		s++;
  800e2d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e30:	0f b6 01             	movzbl (%ecx),%eax
  800e33:	3c 20                	cmp    $0x20,%al
  800e35:	74 f6                	je     800e2d <strtol+0xe>
  800e37:	3c 09                	cmp    $0x9,%al
  800e39:	74 f2                	je     800e2d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800e3b:	3c 2b                	cmp    $0x2b,%al
  800e3d:	74 2a                	je     800e69 <strtol+0x4a>
	int neg = 0;
  800e3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e44:	3c 2d                	cmp    $0x2d,%al
  800e46:	74 2b                	je     800e73 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e48:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e4e:	75 0f                	jne    800e5f <strtol+0x40>
  800e50:	80 39 30             	cmpb   $0x30,(%ecx)
  800e53:	74 28                	je     800e7d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e55:	85 db                	test   %ebx,%ebx
  800e57:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e5c:	0f 44 d8             	cmove  %eax,%ebx
  800e5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e64:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e67:	eb 50                	jmp    800eb9 <strtol+0x9a>
		s++;
  800e69:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e6c:	bf 00 00 00 00       	mov    $0x0,%edi
  800e71:	eb d5                	jmp    800e48 <strtol+0x29>
		s++, neg = 1;
  800e73:	83 c1 01             	add    $0x1,%ecx
  800e76:	bf 01 00 00 00       	mov    $0x1,%edi
  800e7b:	eb cb                	jmp    800e48 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e7d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e81:	74 0e                	je     800e91 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800e83:	85 db                	test   %ebx,%ebx
  800e85:	75 d8                	jne    800e5f <strtol+0x40>
		s++, base = 8;
  800e87:	83 c1 01             	add    $0x1,%ecx
  800e8a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e8f:	eb ce                	jmp    800e5f <strtol+0x40>
		s += 2, base = 16;
  800e91:	83 c1 02             	add    $0x2,%ecx
  800e94:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e99:	eb c4                	jmp    800e5f <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800e9b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800e9e:	89 f3                	mov    %esi,%ebx
  800ea0:	80 fb 19             	cmp    $0x19,%bl
  800ea3:	77 29                	ja     800ece <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ea5:	0f be d2             	movsbl %dl,%edx
  800ea8:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800eab:	3b 55 10             	cmp    0x10(%ebp),%edx
  800eae:	7d 30                	jge    800ee0 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800eb0:	83 c1 01             	add    $0x1,%ecx
  800eb3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800eb7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800eb9:	0f b6 11             	movzbl (%ecx),%edx
  800ebc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ebf:	89 f3                	mov    %esi,%ebx
  800ec1:	80 fb 09             	cmp    $0x9,%bl
  800ec4:	77 d5                	ja     800e9b <strtol+0x7c>
			dig = *s - '0';
  800ec6:	0f be d2             	movsbl %dl,%edx
  800ec9:	83 ea 30             	sub    $0x30,%edx
  800ecc:	eb dd                	jmp    800eab <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  800ece:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ed1:	89 f3                	mov    %esi,%ebx
  800ed3:	80 fb 19             	cmp    $0x19,%bl
  800ed6:	77 08                	ja     800ee0 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ed8:	0f be d2             	movsbl %dl,%edx
  800edb:	83 ea 37             	sub    $0x37,%edx
  800ede:	eb cb                	jmp    800eab <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ee0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ee4:	74 05                	je     800eeb <strtol+0xcc>
		*endptr = (char *) s;
  800ee6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ee9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800eeb:	89 c2                	mov    %eax,%edx
  800eed:	f7 da                	neg    %edx
  800eef:	85 ff                	test   %edi,%edi
  800ef1:	0f 45 c2             	cmovne %edx,%eax
}
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    
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
