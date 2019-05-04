
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 b0 05 00 00       	call   8005e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 b1 17 80 00       	push   $0x8017b1
  800049:	68 80 17 80 00       	push   $0x801780
  80004e:	e8 c1 06 00 00       	call   800714 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 90 17 80 00       	push   $0x801790
  80005c:	68 94 17 80 00       	push   $0x801794
  800061:	e8 ae 06 00 00       	call   800714 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 2e 02 00 00    	je     8002a1 <check_regs+0x26e>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 a8 17 80 00       	push   $0x8017a8
  80007b:	e8 94 06 00 00       	call   800714 <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	pushl  0x4(%ebx)
  80008b:	ff 76 04             	pushl  0x4(%esi)
  80008e:	68 b2 17 80 00       	push   $0x8017b2
  800093:	68 94 17 80 00       	push   $0x801794
  800098:	e8 77 06 00 00       	call   800714 <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 0f 02 00 00    	je     8002bb <check_regs+0x288>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 a8 17 80 00       	push   $0x8017a8
  8000b4:	e8 5b 06 00 00       	call   800714 <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	pushl  0x8(%ebx)
  8000c4:	ff 76 08             	pushl  0x8(%esi)
  8000c7:	68 b6 17 80 00       	push   $0x8017b6
  8000cc:	68 94 17 80 00       	push   $0x801794
  8000d1:	e8 3e 06 00 00       	call   800714 <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 eb 01 00 00    	je     8002d0 <check_regs+0x29d>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 a8 17 80 00       	push   $0x8017a8
  8000ed:	e8 22 06 00 00       	call   800714 <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	pushl  0x10(%ebx)
  8000fd:	ff 76 10             	pushl  0x10(%esi)
  800100:	68 ba 17 80 00       	push   $0x8017ba
  800105:	68 94 17 80 00       	push   $0x801794
  80010a:	e8 05 06 00 00       	call   800714 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 c7 01 00 00    	je     8002e5 <check_regs+0x2b2>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 a8 17 80 00       	push   $0x8017a8
  800126:	e8 e9 05 00 00       	call   800714 <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	pushl  0x14(%ebx)
  800136:	ff 76 14             	pushl  0x14(%esi)
  800139:	68 be 17 80 00       	push   $0x8017be
  80013e:	68 94 17 80 00       	push   $0x801794
  800143:	e8 cc 05 00 00       	call   800714 <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a3 01 00 00    	je     8002fa <check_regs+0x2c7>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 a8 17 80 00       	push   $0x8017a8
  80015f:	e8 b0 05 00 00       	call   800714 <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	pushl  0x18(%ebx)
  80016f:	ff 76 18             	pushl  0x18(%esi)
  800172:	68 c2 17 80 00       	push   $0x8017c2
  800177:	68 94 17 80 00       	push   $0x801794
  80017c:	e8 93 05 00 00       	call   800714 <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 7f 01 00 00    	je     80030f <check_regs+0x2dc>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 a8 17 80 00       	push   $0x8017a8
  800198:	e8 77 05 00 00       	call   800714 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	pushl  0x1c(%ebx)
  8001a8:	ff 76 1c             	pushl  0x1c(%esi)
  8001ab:	68 c6 17 80 00       	push   $0x8017c6
  8001b0:	68 94 17 80 00       	push   $0x801794
  8001b5:	e8 5a 05 00 00       	call   800714 <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5b 01 00 00    	je     800324 <check_regs+0x2f1>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 a8 17 80 00       	push   $0x8017a8
  8001d1:	e8 3e 05 00 00       	call   800714 <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	pushl  0x20(%ebx)
  8001e1:	ff 76 20             	pushl  0x20(%esi)
  8001e4:	68 ca 17 80 00       	push   $0x8017ca
  8001e9:	68 94 17 80 00       	push   $0x801794
  8001ee:	e8 21 05 00 00       	call   800714 <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 37 01 00 00    	je     800339 <check_regs+0x306>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 a8 17 80 00       	push   $0x8017a8
  80020a:	e8 05 05 00 00       	call   800714 <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	pushl  0x24(%ebx)
  80021a:	ff 76 24             	pushl  0x24(%esi)
  80021d:	68 ce 17 80 00       	push   $0x8017ce
  800222:	68 94 17 80 00       	push   $0x801794
  800227:	e8 e8 04 00 00       	call   800714 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 13 01 00 00    	je     80034e <check_regs+0x31b>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 a8 17 80 00       	push   $0x8017a8
  800243:	e8 cc 04 00 00       	call   800714 <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	pushl  0x28(%ebx)
  80024b:	ff 76 28             	pushl  0x28(%esi)
  80024e:	68 d5 17 80 00       	push   $0x8017d5
  800253:	68 94 17 80 00       	push   $0x801794
  800258:	e8 b7 04 00 00       	call   800714 <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 a8 17 80 00       	push   $0x8017a8
  800274:	e8 9b 04 00 00       	call   800714 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	68 d9 17 80 00       	push   $0x8017d9
  800284:	e8 8b 04 00 00       	call   800714 <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 a8 17 80 00       	push   $0x8017a8
  800294:	e8 7b 04 00 00       	call   800714 <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	e9 16 01 00 00       	jmp    8003b7 <check_regs+0x384>
	CHECK(edi, regs.reg_edi);
  8002a1:	83 ec 0c             	sub    $0xc,%esp
  8002a4:	68 a4 17 80 00       	push   $0x8017a4
  8002a9:	e8 66 04 00 00       	call   800714 <cprintf>
  8002ae:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b1:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b6:	e9 cd fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	68 a4 17 80 00       	push   $0x8017a4
  8002c3:	e8 4c 04 00 00       	call   800714 <cprintf>
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	e9 f1 fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	68 a4 17 80 00       	push   $0x8017a4
  8002d8:	e8 37 04 00 00       	call   800714 <cprintf>
  8002dd:	83 c4 10             	add    $0x10,%esp
  8002e0:	e9 15 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	68 a4 17 80 00       	push   $0x8017a4
  8002ed:	e8 22 04 00 00       	call   800714 <cprintf>
  8002f2:	83 c4 10             	add    $0x10,%esp
  8002f5:	e9 39 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	68 a4 17 80 00       	push   $0x8017a4
  800302:	e8 0d 04 00 00       	call   800714 <cprintf>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 5d fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	68 a4 17 80 00       	push   $0x8017a4
  800317:	e8 f8 03 00 00       	call   800714 <cprintf>
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	e9 81 fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	68 a4 17 80 00       	push   $0x8017a4
  80032c:	e8 e3 03 00 00       	call   800714 <cprintf>
  800331:	83 c4 10             	add    $0x10,%esp
  800334:	e9 a5 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  800339:	83 ec 0c             	sub    $0xc,%esp
  80033c:	68 a4 17 80 00       	push   $0x8017a4
  800341:	e8 ce 03 00 00       	call   800714 <cprintf>
  800346:	83 c4 10             	add    $0x10,%esp
  800349:	e9 c9 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	68 a4 17 80 00       	push   $0x8017a4
  800356:	e8 b9 03 00 00       	call   800714 <cprintf>
	CHECK(esp, esp);
  80035b:	ff 73 28             	pushl  0x28(%ebx)
  80035e:	ff 76 28             	pushl  0x28(%esi)
  800361:	68 d5 17 80 00       	push   $0x8017d5
  800366:	68 94 17 80 00       	push   $0x801794
  80036b:	e8 a4 03 00 00       	call   800714 <cprintf>
  800370:	83 c4 20             	add    $0x20,%esp
  800373:	8b 43 28             	mov    0x28(%ebx),%eax
  800376:	39 46 28             	cmp    %eax,0x28(%esi)
  800379:	0f 85 ed fe ff ff    	jne    80026c <check_regs+0x239>
  80037f:	83 ec 0c             	sub    $0xc,%esp
  800382:	68 a4 17 80 00       	push   $0x8017a4
  800387:	e8 88 03 00 00       	call   800714 <cprintf>
	cprintf("Registers %s ", testname);
  80038c:	83 c4 08             	add    $0x8,%esp
  80038f:	ff 75 0c             	pushl  0xc(%ebp)
  800392:	68 d9 17 80 00       	push   $0x8017d9
  800397:	e8 78 03 00 00       	call   800714 <cprintf>
	if (!mismatch)
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 ff                	test   %edi,%edi
  8003a1:	0f 85 e5 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003a7:	83 ec 0c             	sub    $0xc,%esp
  8003aa:	68 a4 17 80 00       	push   $0x8017a4
  8003af:	e8 60 03 00 00       	call   800714 <cprintf>
  8003b4:	83 c4 10             	add    $0x10,%esp
}
  8003b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ba:	5b                   	pop    %ebx
  8003bb:	5e                   	pop    %esi
  8003bc:	5f                   	pop    %edi
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    
	CHECK(esp, esp);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	68 a4 17 80 00       	push   $0x8017a4
  8003c7:	e8 48 03 00 00       	call   800714 <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	68 d9 17 80 00       	push   $0x8017d9
  8003d7:	e8 38 03 00 00       	call   800714 <cprintf>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 a8 fe ff ff       	jmp    80028c <check_regs+0x259>

008003e4 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003f5:	0f 85 a3 00 00 00    	jne    80049e <pgfault+0xba>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003fb:	8b 50 08             	mov    0x8(%eax),%edx
  8003fe:	89 15 60 20 80 00    	mov    %edx,0x802060
  800404:	8b 50 0c             	mov    0xc(%eax),%edx
  800407:	89 15 64 20 80 00    	mov    %edx,0x802064
  80040d:	8b 50 10             	mov    0x10(%eax),%edx
  800410:	89 15 68 20 80 00    	mov    %edx,0x802068
  800416:	8b 50 14             	mov    0x14(%eax),%edx
  800419:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  80041f:	8b 50 18             	mov    0x18(%eax),%edx
  800422:	89 15 70 20 80 00    	mov    %edx,0x802070
  800428:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042b:	89 15 74 20 80 00    	mov    %edx,0x802074
  800431:	8b 50 20             	mov    0x20(%eax),%edx
  800434:	89 15 78 20 80 00    	mov    %edx,0x802078
  80043a:	8b 50 24             	mov    0x24(%eax),%edx
  80043d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800443:	8b 50 28             	mov    0x28(%eax),%edx
  800446:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags & ~FL_RF;
  80044c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80044f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800455:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  80045b:	8b 40 30             	mov    0x30(%eax),%eax
  80045e:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	68 ff 17 80 00       	push   $0x8017ff
  80046b:	68 0d 18 80 00       	push   $0x80180d
  800470:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800475:	ba f8 17 80 00       	mov    $0x8017f8,%edx
  80047a:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80047f:	e8 af fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800484:	83 c4 0c             	add    $0xc,%esp
  800487:	6a 07                	push   $0x7
  800489:	68 00 00 40 00       	push   $0x400000
  80048e:	6a 00                	push   $0x0
  800490:	e8 07 0e 00 00       	call   80129c <sys_page_alloc>
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	85 c0                	test   %eax,%eax
  80049a:	78 1a                	js     8004b6 <pgfault+0xd2>
		panic("sys_page_alloc: %e", r);
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  80049e:	83 ec 0c             	sub    $0xc,%esp
  8004a1:	ff 70 28             	pushl  0x28(%eax)
  8004a4:	52                   	push   %edx
  8004a5:	68 40 18 80 00       	push   $0x801840
  8004aa:	6a 51                	push   $0x51
  8004ac:	68 e7 17 80 00       	push   $0x8017e7
  8004b1:	e8 83 01 00 00       	call   800639 <_panic>
		panic("sys_page_alloc: %e", r);
  8004b6:	50                   	push   %eax
  8004b7:	68 14 18 80 00       	push   $0x801814
  8004bc:	6a 5c                	push   $0x5c
  8004be:	68 e7 17 80 00       	push   $0x8017e7
  8004c3:	e8 71 01 00 00       	call   800639 <_panic>

008004c8 <umain>:

void
umain(int argc, char **argv)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004ce:	68 e4 03 80 00       	push   $0x8003e4
  8004d3:	e8 b4 0f 00 00       	call   80148c <set_pgfault_handler>

	asm volatile(
  8004d8:	50                   	push   %eax
  8004d9:	9c                   	pushf  
  8004da:	58                   	pop    %eax
  8004db:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e0:	50                   	push   %eax
  8004e1:	9d                   	popf   
  8004e2:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004e7:	8d 05 22 05 80 00    	lea    0x800522,%eax
  8004ed:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004f2:	58                   	pop    %eax
  8004f3:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004f9:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004ff:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  800505:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  80050b:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  800511:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  800517:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  80051c:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  800522:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800529:	00 00 00 
  80052c:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800532:	89 35 24 20 80 00    	mov    %esi,0x802024
  800538:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  80053e:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800544:	89 15 34 20 80 00    	mov    %edx,0x802034
  80054a:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800550:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800555:	89 25 48 20 80 00    	mov    %esp,0x802048
  80055b:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800561:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800567:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80056d:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800573:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800579:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  80057f:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800584:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  80058a:	50                   	push   %eax
  80058b:	9c                   	pushf  
  80058c:	58                   	pop    %eax
  80058d:	a3 44 20 80 00       	mov    %eax,0x802044
  800592:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80059d:	75 30                	jne    8005cf <umain+0x107>
		cprintf("EIP after page-fault MISMATCH\n");
	after.eip = before.eip;
  80059f:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  8005a4:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	68 27 18 80 00       	push   $0x801827
  8005b1:	68 38 18 80 00       	push   $0x801838
  8005b6:	b9 20 20 80 00       	mov    $0x802020,%ecx
  8005bb:	ba f8 17 80 00       	mov    $0x8017f8,%edx
  8005c0:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  8005c5:	e8 69 fa ff ff       	call   800033 <check_regs>
}
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	c9                   	leave  
  8005ce:	c3                   	ret    
		cprintf("EIP after page-fault MISMATCH\n");
  8005cf:	83 ec 0c             	sub    $0xc,%esp
  8005d2:	68 74 18 80 00       	push   $0x801874
  8005d7:	e8 38 01 00 00       	call   800714 <cprintf>
  8005dc:	83 c4 10             	add    $0x10,%esp
  8005df:	eb be                	jmp    80059f <umain+0xd7>

008005e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	56                   	push   %esi
  8005e5:	53                   	push   %ebx
  8005e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8005ec:	e8 6d 0c 00 00       	call   80125e <sys_getenvid>
  8005f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005f6:	c1 e0 07             	shl    $0x7,%eax
  8005f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005fe:	a3 cc 20 80 00       	mov    %eax,0x8020cc

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800603:	85 db                	test   %ebx,%ebx
  800605:	7e 07                	jle    80060e <libmain+0x2d>
		binaryname = argv[0];
  800607:	8b 06                	mov    (%esi),%eax
  800609:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	56                   	push   %esi
  800612:	53                   	push   %ebx
  800613:	e8 b0 fe ff ff       	call   8004c8 <umain>

	// exit gracefully
	exit();
  800618:	e8 0a 00 00 00       	call   800627 <exit>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80062d:	6a 00                	push   $0x0
  80062f:	e8 e9 0b 00 00       	call   80121d <sys_env_destroy>
}
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	c9                   	leave  
  800638:	c3                   	ret    

00800639 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800639:	55                   	push   %ebp
  80063a:	89 e5                	mov    %esp,%ebp
  80063c:	56                   	push   %esi
  80063d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80063e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800641:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800647:	e8 12 0c 00 00       	call   80125e <sys_getenvid>
  80064c:	83 ec 0c             	sub    $0xc,%esp
  80064f:	ff 75 0c             	pushl  0xc(%ebp)
  800652:	ff 75 08             	pushl  0x8(%ebp)
  800655:	56                   	push   %esi
  800656:	50                   	push   %eax
  800657:	68 a0 18 80 00       	push   $0x8018a0
  80065c:	e8 b3 00 00 00       	call   800714 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800661:	83 c4 18             	add    $0x18,%esp
  800664:	53                   	push   %ebx
  800665:	ff 75 10             	pushl  0x10(%ebp)
  800668:	e8 56 00 00 00       	call   8006c3 <vcprintf>
	cprintf("\n");
  80066d:	c7 04 24 b0 17 80 00 	movl   $0x8017b0,(%esp)
  800674:	e8 9b 00 00 00       	call   800714 <cprintf>
  800679:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80067c:	cc                   	int3   
  80067d:	eb fd                	jmp    80067c <_panic+0x43>

0080067f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	53                   	push   %ebx
  800683:	83 ec 04             	sub    $0x4,%esp
  800686:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800689:	8b 13                	mov    (%ebx),%edx
  80068b:	8d 42 01             	lea    0x1(%edx),%eax
  80068e:	89 03                	mov    %eax,(%ebx)
  800690:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800693:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800697:	3d ff 00 00 00       	cmp    $0xff,%eax
  80069c:	74 09                	je     8006a7 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80069e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006a5:	c9                   	leave  
  8006a6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	68 ff 00 00 00       	push   $0xff
  8006af:	8d 43 08             	lea    0x8(%ebx),%eax
  8006b2:	50                   	push   %eax
  8006b3:	e8 28 0b 00 00       	call   8011e0 <sys_cputs>
		b->idx = 0;
  8006b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006be:	83 c4 10             	add    $0x10,%esp
  8006c1:	eb db                	jmp    80069e <putch+0x1f>

008006c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006d3:	00 00 00 
	b.cnt = 0;
  8006d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006e0:	ff 75 0c             	pushl  0xc(%ebp)
  8006e3:	ff 75 08             	pushl  0x8(%ebp)
  8006e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006ec:	50                   	push   %eax
  8006ed:	68 7f 06 80 00       	push   $0x80067f
  8006f2:	e8 fb 00 00 00       	call   8007f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006f7:	83 c4 08             	add    $0x8,%esp
  8006fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800700:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800706:	50                   	push   %eax
  800707:	e8 d4 0a 00 00       	call   8011e0 <sys_cputs>

	return b.cnt;
}
  80070c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800712:	c9                   	leave  
  800713:	c3                   	ret    

00800714 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80071a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80071d:	50                   	push   %eax
  80071e:	ff 75 08             	pushl  0x8(%ebp)
  800721:	e8 9d ff ff ff       	call   8006c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800726:	c9                   	leave  
  800727:	c3                   	ret    

00800728 <printnum_helper>:
};

static int
printnum_helper(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	57                   	push   %edi
  80072c:	56                   	push   %esi
  80072d:	53                   	push   %ebx
  80072e:	83 ec 1c             	sub    $0x1c,%esp
  800731:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800734:	89 d3                	mov    %edx,%ebx
  800736:	8b 75 08             	mov    0x8(%ebp),%esi
  800739:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80073c:	8b 45 10             	mov    0x10(%ebp),%eax
  80073f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	int remain = width;
	if (num >= base) {
  800742:	89 c2                	mov    %eax,%edx
  800744:	b9 00 00 00 00       	mov    $0x0,%ecx
  800749:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80074c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  80074f:	39 c6                	cmp    %eax,%esi
  800751:	89 f8                	mov    %edi,%eax
  800753:	19 c8                	sbb    %ecx,%eax
  800755:	73 32                	jae    800789 <printnum_helper+0x61>
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
	}
	putch("0123456789abcdef"[num % base], putdat);
  800757:	83 ec 08             	sub    $0x8,%esp
  80075a:	53                   	push   %ebx
  80075b:	83 ec 04             	sub    $0x4,%esp
  80075e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800761:	ff 75 e0             	pushl  -0x20(%ebp)
  800764:	57                   	push   %edi
  800765:	56                   	push   %esi
  800766:	e8 d5 0e 00 00       	call   801640 <__umoddi3>
  80076b:	83 c4 14             	add    $0x14,%esp
  80076e:	0f be 80 c3 18 80 00 	movsbl 0x8018c3(%eax),%eax
  800775:	50                   	push   %eax
  800776:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800779:	ff d0                	call   *%eax
	return remain - 1;
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	83 e8 01             	sub    $0x1,%eax
}
  800781:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800784:	5b                   	pop    %ebx
  800785:	5e                   	pop    %esi
  800786:	5f                   	pop    %edi
  800787:	5d                   	pop    %ebp
  800788:	c3                   	ret    
		remain = printnum_helper(putch, putdat, num / base, base, width, padc);
  800789:	83 ec 0c             	sub    $0xc,%esp
  80078c:	ff 75 18             	pushl  0x18(%ebp)
  80078f:	ff 75 14             	pushl  0x14(%ebp)
  800792:	ff 75 d8             	pushl  -0x28(%ebp)
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	51                   	push   %ecx
  800799:	52                   	push   %edx
  80079a:	57                   	push   %edi
  80079b:	56                   	push   %esi
  80079c:	e8 8f 0d 00 00       	call   801530 <__udivdi3>
  8007a1:	83 c4 18             	add    $0x18,%esp
  8007a4:	52                   	push   %edx
  8007a5:	50                   	push   %eax
  8007a6:	89 da                	mov    %ebx,%edx
  8007a8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007ab:	e8 78 ff ff ff       	call   800728 <printnum_helper>
  8007b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b3:	83 c4 20             	add    $0x20,%esp
  8007b6:	eb 9f                	jmp    800757 <printnum_helper+0x2f>

008007b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007be:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007c2:	8b 10                	mov    (%eax),%edx
  8007c4:	3b 50 04             	cmp    0x4(%eax),%edx
  8007c7:	73 0a                	jae    8007d3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007c9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007cc:	89 08                	mov    %ecx,(%eax)
  8007ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d1:	88 02                	mov    %al,(%edx)
}
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <printfmt>:
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8007db:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007de:	50                   	push   %eax
  8007df:	ff 75 10             	pushl  0x10(%ebp)
  8007e2:	ff 75 0c             	pushl  0xc(%ebp)
  8007e5:	ff 75 08             	pushl  0x8(%ebp)
  8007e8:	e8 05 00 00 00       	call   8007f2 <vprintfmt>
}
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	c9                   	leave  
  8007f1:	c3                   	ret    

008007f2 <vprintfmt>:
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	57                   	push   %edi
  8007f6:	56                   	push   %esi
  8007f7:	53                   	push   %ebx
  8007f8:	83 ec 3c             	sub    $0x3c,%esp
  8007fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800801:	8b 7d 10             	mov    0x10(%ebp),%edi
  800804:	e9 3f 05 00 00       	jmp    800d48 <vprintfmt+0x556>
		padc = ' ';
  800809:	c6 45 cc 20          	movb   $0x20,-0x34(%ebp)
		precede = 0;
  80080d:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		altflag = 0;
  800814:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  80081b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		width = -1;
  800822:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		lflag = 0;
  800829:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
  800830:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800835:	8d 47 01             	lea    0x1(%edi),%eax
  800838:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80083b:	0f b6 17             	movzbl (%edi),%edx
  80083e:	8d 42 dd             	lea    -0x23(%edx),%eax
  800841:	3c 55                	cmp    $0x55,%al
  800843:	0f 87 98 05 00 00    	ja     800de1 <vprintfmt+0x5ef>
  800849:	0f b6 c0             	movzbl %al,%eax
  80084c:	ff 24 85 00 1a 80 00 	jmp    *0x801a00(,%eax,4)
  800853:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '-';
  800856:	c6 45 cc 2d          	movb   $0x2d,-0x34(%ebp)
  80085a:	eb d9                	jmp    800835 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  80085c:	8b 7d dc             	mov    -0x24(%ebp),%edi
			precede = 1;
  80085f:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  800866:	eb cd                	jmp    800835 <vprintfmt+0x43>
		switch (ch = *(unsigned char *) fmt++) {
  800868:	0f b6 d2             	movzbl %dl,%edx
  80086b:	8b 7d dc             	mov    -0x24(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80086e:	b8 00 00 00 00       	mov    $0x0,%eax
  800873:	89 5d 08             	mov    %ebx,0x8(%ebp)
				precision = precision * 10 + ch - '0';
  800876:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800879:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80087d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800880:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800883:	83 fb 09             	cmp    $0x9,%ebx
  800886:	77 5c                	ja     8008e4 <vprintfmt+0xf2>
			for (precision = 0; ; ++fmt) {
  800888:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80088b:	eb e9                	jmp    800876 <vprintfmt+0x84>
		switch (ch = *(unsigned char *) fmt++) {
  80088d:	8b 7d dc             	mov    -0x24(%ebp),%edi
			padc = '0';
  800890:	c6 45 cc 30          	movb   $0x30,-0x34(%ebp)
			goto reswitch;
  800894:	eb 9f                	jmp    800835 <vprintfmt+0x43>
			precision = va_arg(ap, int);
  800896:	8b 45 14             	mov    0x14(%ebp),%eax
  800899:	8b 00                	mov    (%eax),%eax
  80089b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80089e:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a1:	8d 40 04             	lea    0x4(%eax),%eax
  8008a4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008a7:	8b 7d dc             	mov    -0x24(%ebp),%edi
			if (width < 0)
  8008aa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8008ae:	79 85                	jns    800835 <vprintfmt+0x43>
				width = precision, precision = -1;
  8008b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008bd:	e9 73 ff ff ff       	jmp    800835 <vprintfmt+0x43>
  8008c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	0f 48 c1             	cmovs  %ecx,%eax
  8008ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008cd:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8008d0:	e9 60 ff ff ff       	jmp    800835 <vprintfmt+0x43>
  8008d5:	8b 7d dc             	mov    -0x24(%ebp),%edi
			altflag = 1;
  8008d8:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8008df:	e9 51 ff ff ff       	jmp    800835 <vprintfmt+0x43>
  8008e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008ea:	eb be                	jmp    8008aa <vprintfmt+0xb8>
			lflag++;
  8008ec:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008f0:	8b 7d dc             	mov    -0x24(%ebp),%edi
			goto reswitch;
  8008f3:	e9 3d ff ff ff       	jmp    800835 <vprintfmt+0x43>
			putch(va_arg(ap, int), putdat);
  8008f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fb:	8d 78 04             	lea    0x4(%eax),%edi
  8008fe:	83 ec 08             	sub    $0x8,%esp
  800901:	56                   	push   %esi
  800902:	ff 30                	pushl  (%eax)
  800904:	ff d3                	call   *%ebx
			break;
  800906:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800909:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80090c:	e9 34 04 00 00       	jmp    800d45 <vprintfmt+0x553>
			err = va_arg(ap, int);
  800911:	8b 45 14             	mov    0x14(%ebp),%eax
  800914:	8d 78 04             	lea    0x4(%eax),%edi
  800917:	8b 00                	mov    (%eax),%eax
  800919:	99                   	cltd   
  80091a:	31 d0                	xor    %edx,%eax
  80091c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80091e:	83 f8 08             	cmp    $0x8,%eax
  800921:	7f 23                	jg     800946 <vprintfmt+0x154>
  800923:	8b 14 85 60 1b 80 00 	mov    0x801b60(,%eax,4),%edx
  80092a:	85 d2                	test   %edx,%edx
  80092c:	74 18                	je     800946 <vprintfmt+0x154>
				printfmt(putch, putdat, "%s", p);
  80092e:	52                   	push   %edx
  80092f:	68 e4 18 80 00       	push   $0x8018e4
  800934:	56                   	push   %esi
  800935:	53                   	push   %ebx
  800936:	e8 9a fe ff ff       	call   8007d5 <printfmt>
  80093b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80093e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800941:	e9 ff 03 00 00       	jmp    800d45 <vprintfmt+0x553>
				printfmt(putch, putdat, "error %d", err);
  800946:	50                   	push   %eax
  800947:	68 db 18 80 00       	push   $0x8018db
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	e8 82 fe ff ff       	call   8007d5 <printfmt>
  800953:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800956:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800959:	e9 e7 03 00 00       	jmp    800d45 <vprintfmt+0x553>
			if ((p = va_arg(ap, char *)) == NULL)
  80095e:	8b 45 14             	mov    0x14(%ebp),%eax
  800961:	83 c0 04             	add    $0x4,%eax
  800964:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800967:	8b 45 14             	mov    0x14(%ebp),%eax
  80096a:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80096c:	85 c9                	test   %ecx,%ecx
  80096e:	b8 d4 18 80 00       	mov    $0x8018d4,%eax
  800973:	0f 45 c1             	cmovne %ecx,%eax
  800976:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800979:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80097d:	7e 06                	jle    800985 <vprintfmt+0x193>
  80097f:	80 7d cc 2d          	cmpb   $0x2d,-0x34(%ebp)
  800983:	75 0d                	jne    800992 <vprintfmt+0x1a0>
				for (width -= strnlen(p, precision); width > 0; width--)
  800985:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800988:	89 c7                	mov    %eax,%edi
  80098a:	03 45 d8             	add    -0x28(%ebp),%eax
  80098d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800990:	eb 53                	jmp    8009e5 <vprintfmt+0x1f3>
  800992:	83 ec 08             	sub    $0x8,%esp
  800995:	ff 75 e0             	pushl  -0x20(%ebp)
  800998:	50                   	push   %eax
  800999:	e8 eb 04 00 00       	call   800e89 <strnlen>
  80099e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8009a1:	29 c1                	sub    %eax,%ecx
  8009a3:	89 4d c0             	mov    %ecx,-0x40(%ebp)
  8009a6:	83 c4 10             	add    $0x10,%esp
  8009a9:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8009ab:	0f be 45 cc          	movsbl -0x34(%ebp),%eax
  8009af:	89 45 d8             	mov    %eax,-0x28(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8009b2:	eb 0f                	jmp    8009c3 <vprintfmt+0x1d1>
					putch(padc, putdat);
  8009b4:	83 ec 08             	sub    $0x8,%esp
  8009b7:	56                   	push   %esi
  8009b8:	ff 75 d8             	pushl  -0x28(%ebp)
  8009bb:	ff d3                	call   *%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bd:	83 ef 01             	sub    $0x1,%edi
  8009c0:	83 c4 10             	add    $0x10,%esp
  8009c3:	85 ff                	test   %edi,%edi
  8009c5:	7f ed                	jg     8009b4 <vprintfmt+0x1c2>
  8009c7:	8b 4d c0             	mov    -0x40(%ebp),%ecx
  8009ca:	85 c9                	test   %ecx,%ecx
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d1:	0f 49 c1             	cmovns %ecx,%eax
  8009d4:	29 c1                	sub    %eax,%ecx
  8009d6:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  8009d9:	eb aa                	jmp    800985 <vprintfmt+0x193>
					putch(ch, putdat);
  8009db:	83 ec 08             	sub    $0x8,%esp
  8009de:	56                   	push   %esi
  8009df:	52                   	push   %edx
  8009e0:	ff d3                	call   *%ebx
  8009e2:	83 c4 10             	add    $0x10,%esp
  8009e5:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8009e8:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009ea:	83 c7 01             	add    $0x1,%edi
  8009ed:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8009f1:	0f be d0             	movsbl %al,%edx
  8009f4:	85 d2                	test   %edx,%edx
  8009f6:	74 2e                	je     800a26 <vprintfmt+0x234>
  8009f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009fc:	78 06                	js     800a04 <vprintfmt+0x212>
  8009fe:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800a02:	78 1e                	js     800a22 <vprintfmt+0x230>
				if (altflag && (ch < ' ' || ch > '~'))
  800a04:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800a08:	74 d1                	je     8009db <vprintfmt+0x1e9>
  800a0a:	0f be c0             	movsbl %al,%eax
  800a0d:	83 e8 20             	sub    $0x20,%eax
  800a10:	83 f8 5e             	cmp    $0x5e,%eax
  800a13:	76 c6                	jbe    8009db <vprintfmt+0x1e9>
					putch('?', putdat);
  800a15:	83 ec 08             	sub    $0x8,%esp
  800a18:	56                   	push   %esi
  800a19:	6a 3f                	push   $0x3f
  800a1b:	ff d3                	call   *%ebx
  800a1d:	83 c4 10             	add    $0x10,%esp
  800a20:	eb c3                	jmp    8009e5 <vprintfmt+0x1f3>
  800a22:	89 cf                	mov    %ecx,%edi
  800a24:	eb 02                	jmp    800a28 <vprintfmt+0x236>
  800a26:	89 cf                	mov    %ecx,%edi
			for (; width > 0; width--)
  800a28:	85 ff                	test   %edi,%edi
  800a2a:	7e 10                	jle    800a3c <vprintfmt+0x24a>
				putch(' ', putdat);
  800a2c:	83 ec 08             	sub    $0x8,%esp
  800a2f:	56                   	push   %esi
  800a30:	6a 20                	push   $0x20
  800a32:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800a34:	83 ef 01             	sub    $0x1,%edi
  800a37:	83 c4 10             	add    $0x10,%esp
  800a3a:	eb ec                	jmp    800a28 <vprintfmt+0x236>
			if ((p = va_arg(ap, char *)) == NULL)
  800a3c:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800a3f:	89 45 14             	mov    %eax,0x14(%ebp)
  800a42:	e9 fe 02 00 00       	jmp    800d45 <vprintfmt+0x553>
	if (lflag >= 2)
  800a47:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800a4b:	7f 21                	jg     800a6e <vprintfmt+0x27c>
	else if (lflag)
  800a4d:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800a51:	74 79                	je     800acc <vprintfmt+0x2da>
		return va_arg(*ap, long);
  800a53:	8b 45 14             	mov    0x14(%ebp),%eax
  800a56:	8b 00                	mov    (%eax),%eax
  800a58:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a5b:	89 c1                	mov    %eax,%ecx
  800a5d:	c1 f9 1f             	sar    $0x1f,%ecx
  800a60:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800a63:	8b 45 14             	mov    0x14(%ebp),%eax
  800a66:	8d 40 04             	lea    0x4(%eax),%eax
  800a69:	89 45 14             	mov    %eax,0x14(%ebp)
  800a6c:	eb 17                	jmp    800a85 <vprintfmt+0x293>
		return va_arg(*ap, long long);
  800a6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a71:	8b 50 04             	mov    0x4(%eax),%edx
  800a74:	8b 00                	mov    (%eax),%eax
  800a76:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a79:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7f:	8d 40 08             	lea    0x8(%eax),%eax
  800a82:	89 45 14             	mov    %eax,0x14(%ebp)
			num = getint(&ap, lflag);
  800a85:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a88:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a8b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800a8e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			if ((long long) num < 0) {
  800a91:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a95:	78 50                	js     800ae7 <vprintfmt+0x2f5>
			else if ((long long) num > 0 && precede) {
  800a97:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a9a:	c1 fa 1f             	sar    $0x1f,%edx
  800a9d:	89 d0                	mov    %edx,%eax
  800a9f:	2b 45 e0             	sub    -0x20(%ebp),%eax
  800aa2:	1b 55 e4             	sbb    -0x1c(%ebp),%edx
  800aa5:	85 d2                	test   %edx,%edx
  800aa7:	0f 89 14 02 00 00    	jns    800cc1 <vprintfmt+0x4cf>
  800aad:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800ab1:	0f 84 0a 02 00 00    	je     800cc1 <vprintfmt+0x4cf>
				putch('+', putdat);
  800ab7:	83 ec 08             	sub    $0x8,%esp
  800aba:	56                   	push   %esi
  800abb:	6a 2b                	push   $0x2b
  800abd:	ff d3                	call   *%ebx
  800abf:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800ac2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ac7:	e9 5c 01 00 00       	jmp    800c28 <vprintfmt+0x436>
		return va_arg(*ap, int);
  800acc:	8b 45 14             	mov    0x14(%ebp),%eax
  800acf:	8b 00                	mov    (%eax),%eax
  800ad1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ad4:	89 c1                	mov    %eax,%ecx
  800ad6:	c1 f9 1f             	sar    $0x1f,%ecx
  800ad9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  800adc:	8b 45 14             	mov    0x14(%ebp),%eax
  800adf:	8d 40 04             	lea    0x4(%eax),%eax
  800ae2:	89 45 14             	mov    %eax,0x14(%ebp)
  800ae5:	eb 9e                	jmp    800a85 <vprintfmt+0x293>
				putch('-', putdat);
  800ae7:	83 ec 08             	sub    $0x8,%esp
  800aea:	56                   	push   %esi
  800aeb:	6a 2d                	push   $0x2d
  800aed:	ff d3                	call   *%ebx
				num = -(long long) num;
  800aef:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800af2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800af5:	f7 d8                	neg    %eax
  800af7:	83 d2 00             	adc    $0x0,%edx
  800afa:	f7 da                	neg    %edx
  800afc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800aff:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800b02:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800b05:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b0a:	e9 19 01 00 00       	jmp    800c28 <vprintfmt+0x436>
	if (lflag >= 2)
  800b0f:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800b13:	7f 29                	jg     800b3e <vprintfmt+0x34c>
	else if (lflag)
  800b15:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800b19:	74 44                	je     800b5f <vprintfmt+0x36d>
		return va_arg(*ap, unsigned long);
  800b1b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b1e:	8b 00                	mov    (%eax),%eax
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b28:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800b2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2e:	8d 40 04             	lea    0x4(%eax),%eax
  800b31:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b34:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b39:	e9 ea 00 00 00       	jmp    800c28 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800b3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800b41:	8b 50 04             	mov    0x4(%eax),%edx
  800b44:	8b 00                	mov    (%eax),%eax
  800b46:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b49:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800b4c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4f:	8d 40 08             	lea    0x8(%eax),%eax
  800b52:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b55:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b5a:	e9 c9 00 00 00       	jmp    800c28 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800b5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b62:	8b 00                	mov    (%eax),%eax
  800b64:	ba 00 00 00 00       	mov    $0x0,%edx
  800b69:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b6c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800b6f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b72:	8d 40 04             	lea    0x4(%eax),%eax
  800b75:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b78:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7d:	e9 a6 00 00 00       	jmp    800c28 <vprintfmt+0x436>
			putch('0', putdat);
  800b82:	83 ec 08             	sub    $0x8,%esp
  800b85:	56                   	push   %esi
  800b86:	6a 30                	push   $0x30
  800b88:	ff d3                	call   *%ebx
	if (lflag >= 2)
  800b8a:	83 c4 10             	add    $0x10,%esp
  800b8d:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800b91:	7f 26                	jg     800bb9 <vprintfmt+0x3c7>
	else if (lflag)
  800b93:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800b97:	74 3e                	je     800bd7 <vprintfmt+0x3e5>
		return va_arg(*ap, unsigned long);
  800b99:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9c:	8b 00                	mov    (%eax),%eax
  800b9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800ba6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800ba9:	8b 45 14             	mov    0x14(%ebp),%eax
  800bac:	8d 40 04             	lea    0x4(%eax),%eax
  800baf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800bb2:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb7:	eb 6f                	jmp    800c28 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800bb9:	8b 45 14             	mov    0x14(%ebp),%eax
  800bbc:	8b 50 04             	mov    0x4(%eax),%edx
  800bbf:	8b 00                	mov    (%eax),%eax
  800bc1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800bc4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800bc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bca:	8d 40 08             	lea    0x8(%eax),%eax
  800bcd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800bd0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bd5:	eb 51                	jmp    800c28 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800bd7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bda:	8b 00                	mov    (%eax),%eax
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800be4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800be7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bea:	8d 40 04             	lea    0x4(%eax),%eax
  800bed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800bf0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf5:	eb 31                	jmp    800c28 <vprintfmt+0x436>
			putch('0', putdat);
  800bf7:	83 ec 08             	sub    $0x8,%esp
  800bfa:	56                   	push   %esi
  800bfb:	6a 30                	push   $0x30
  800bfd:	ff d3                	call   *%ebx
			putch('x', putdat);
  800bff:	83 c4 08             	add    $0x8,%esp
  800c02:	56                   	push   %esi
  800c03:	6a 78                	push   $0x78
  800c05:	ff d3                	call   *%ebx
			num = (unsigned long long)
  800c07:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0a:	8b 00                	mov    (%eax),%eax
  800c0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c11:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800c14:	89 55 d4             	mov    %edx,-0x2c(%ebp)
			goto number;
  800c17:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800c1a:	8b 45 14             	mov    0x14(%ebp),%eax
  800c1d:	8d 40 04             	lea    0x4(%eax),%eax
  800c20:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c23:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800c28:	0f be 4d cc          	movsbl -0x34(%ebp),%ecx
  800c2c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800c2f:	89 c1                	mov    %eax,%ecx
  800c31:	89 45 c8             	mov    %eax,-0x38(%ebp)
	int len = 1, tmp = num;
  800c34:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800c37:	bf 01 00 00 00       	mov    $0x1,%edi
	while (tmp >= base) {
  800c3c:	89 c2                	mov    %eax,%edx
  800c3e:	39 c1                	cmp    %eax,%ecx
  800c40:	0f 87 85 00 00 00    	ja     800ccb <vprintfmt+0x4d9>
		tmp /= base;
  800c46:	89 d0                	mov    %edx,%eax
  800c48:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4d:	f7 f1                	div    %ecx
		len++;
  800c4f:	83 c7 01             	add    $0x1,%edi
  800c52:	eb e8                	jmp    800c3c <vprintfmt+0x44a>
	if (lflag >= 2)
  800c54:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
  800c58:	7f 26                	jg     800c80 <vprintfmt+0x48e>
	else if (lflag)
  800c5a:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  800c5e:	74 3e                	je     800c9e <vprintfmt+0x4ac>
		return va_arg(*ap, unsigned long);
  800c60:	8b 45 14             	mov    0x14(%ebp),%eax
  800c63:	8b 00                	mov    (%eax),%eax
  800c65:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800c6d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800c70:	8b 45 14             	mov    0x14(%ebp),%eax
  800c73:	8d 40 04             	lea    0x4(%eax),%eax
  800c76:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c79:	b8 10 00 00 00       	mov    $0x10,%eax
  800c7e:	eb a8                	jmp    800c28 <vprintfmt+0x436>
		return va_arg(*ap, unsigned long long);
  800c80:	8b 45 14             	mov    0x14(%ebp),%eax
  800c83:	8b 50 04             	mov    0x4(%eax),%edx
  800c86:	8b 00                	mov    (%eax),%eax
  800c88:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800c8b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800c8e:	8b 45 14             	mov    0x14(%ebp),%eax
  800c91:	8d 40 08             	lea    0x8(%eax),%eax
  800c94:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c97:	b8 10 00 00 00       	mov    $0x10,%eax
  800c9c:	eb 8a                	jmp    800c28 <vprintfmt+0x436>
		return va_arg(*ap, unsigned int);
  800c9e:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca1:	8b 00                	mov    (%eax),%eax
  800ca3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800cab:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800cae:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb1:	8d 40 04             	lea    0x4(%eax),%eax
  800cb4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800cb7:	b8 10 00 00 00       	mov    $0x10,%eax
  800cbc:	e9 67 ff ff ff       	jmp    800c28 <vprintfmt+0x436>
			base = 10;
  800cc1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc6:	e9 5d ff ff ff       	jmp    800c28 <vprintfmt+0x436>
  800ccb:	89 7d cc             	mov    %edi,-0x34(%ebp)
		width -= len;
  800cce:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800cd1:	29 f8                	sub    %edi,%eax
  800cd3:	89 c7                	mov    %eax,%edi
	if (padc == '-') {
  800cd5:	83 7d e0 2d          	cmpl   $0x2d,-0x20(%ebp)
  800cd9:	74 15                	je     800cf0 <vprintfmt+0x4fe>
		while (width > 0) {
  800cdb:	85 ff                	test   %edi,%edi
  800cdd:	7e 48                	jle    800d27 <vprintfmt+0x535>
			putch(padc, putdat);
  800cdf:	83 ec 08             	sub    $0x8,%esp
  800ce2:	56                   	push   %esi
  800ce3:	ff 75 e0             	pushl  -0x20(%ebp)
  800ce6:	ff d3                	call   *%ebx
			width--;
  800ce8:	83 ef 01             	sub    $0x1,%edi
  800ceb:	83 c4 10             	add    $0x10,%esp
  800cee:	eb eb                	jmp    800cdb <vprintfmt+0x4e9>
		printnum_helper(putch, putdat, num, base, len, padc);
  800cf0:	83 ec 0c             	sub    $0xc,%esp
  800cf3:	6a 2d                	push   $0x2d
  800cf5:	ff 75 cc             	pushl  -0x34(%ebp)
  800cf8:	ff 75 c8             	pushl  -0x38(%ebp)
  800cfb:	ff 75 d4             	pushl  -0x2c(%ebp)
  800cfe:	ff 75 d0             	pushl  -0x30(%ebp)
  800d01:	89 f2                	mov    %esi,%edx
  800d03:	89 d8                	mov    %ebx,%eax
  800d05:	e8 1e fa ff ff       	call   800728 <printnum_helper>
		width -= len;
  800d0a:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800d0d:	2b 7d cc             	sub    -0x34(%ebp),%edi
  800d10:	83 c4 20             	add    $0x20,%esp
		while (width > 0) {
  800d13:	85 ff                	test   %edi,%edi
  800d15:	7e 2e                	jle    800d45 <vprintfmt+0x553>
			putch(padc, putdat);
  800d17:	83 ec 08             	sub    $0x8,%esp
  800d1a:	56                   	push   %esi
  800d1b:	6a 20                	push   $0x20
  800d1d:	ff d3                	call   *%ebx
			width--;
  800d1f:	83 ef 01             	sub    $0x1,%edi
  800d22:	83 c4 10             	add    $0x10,%esp
  800d25:	eb ec                	jmp    800d13 <vprintfmt+0x521>
		printnum_helper(putch, putdat, num, base, len, padc);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	ff 75 e0             	pushl  -0x20(%ebp)
  800d2d:	ff 75 cc             	pushl  -0x34(%ebp)
  800d30:	ff 75 c8             	pushl  -0x38(%ebp)
  800d33:	ff 75 d4             	pushl  -0x2c(%ebp)
  800d36:	ff 75 d0             	pushl  -0x30(%ebp)
  800d39:	89 f2                	mov    %esi,%edx
  800d3b:	89 d8                	mov    %ebx,%eax
  800d3d:	e8 e6 f9 ff ff       	call   800728 <printnum_helper>
  800d42:	83 c4 20             	add    $0x20,%esp
			char *res = va_arg(ap, char *);
  800d45:	8b 7d dc             	mov    -0x24(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800d48:	83 c7 01             	add    $0x1,%edi
  800d4b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800d4f:	83 f8 25             	cmp    $0x25,%eax
  800d52:	0f 84 b1 fa ff ff    	je     800809 <vprintfmt+0x17>
			if (ch == '\0')
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	0f 84 a1 00 00 00    	je     800e01 <vprintfmt+0x60f>
			putch(ch, putdat);
  800d60:	83 ec 08             	sub    $0x8,%esp
  800d63:	56                   	push   %esi
  800d64:	50                   	push   %eax
  800d65:	ff d3                	call   *%ebx
  800d67:	83 c4 10             	add    $0x10,%esp
  800d6a:	eb dc                	jmp    800d48 <vprintfmt+0x556>
			char *res = va_arg(ap, char *);
  800d6c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d6f:	83 c0 04             	add    $0x4,%eax
  800d72:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d75:	8b 45 14             	mov    0x14(%ebp),%eax
  800d78:	8b 38                	mov    (%eax),%edi
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800d7a:	85 ff                	test   %edi,%edi
  800d7c:	74 15                	je     800d93 <vprintfmt+0x5a1>
			else if (*((int*)putdat) > 240) { // 240 ~ 254 all ok
  800d7e:	81 3e f0 00 00 00    	cmpl   $0xf0,(%esi)
  800d84:	7f 29                	jg     800daf <vprintfmt+0x5bd>
				*res = *(char *)putdat;
  800d86:	0f b6 06             	movzbl (%esi),%eax
  800d89:	88 07                	mov    %al,(%edi)
			char *res = va_arg(ap, char *);
  800d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d8e:	89 45 14             	mov    %eax,0x14(%ebp)
  800d91:	eb b2                	jmp    800d45 <vprintfmt+0x553>
			if (!res) printfmt(putch, putdat, "%s", null_error);
  800d93:	68 7c 19 80 00       	push   $0x80197c
  800d98:	68 e4 18 80 00       	push   $0x8018e4
  800d9d:	56                   	push   %esi
  800d9e:	53                   	push   %ebx
  800d9f:	e8 31 fa ff ff       	call   8007d5 <printfmt>
  800da4:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800da7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800daa:	89 45 14             	mov    %eax,0x14(%ebp)
  800dad:	eb 96                	jmp    800d45 <vprintfmt+0x553>
				printfmt(putch, putdat, "%s", overflow_error);
  800daf:	68 b4 19 80 00       	push   $0x8019b4
  800db4:	68 e4 18 80 00       	push   $0x8018e4
  800db9:	56                   	push   %esi
  800dba:	53                   	push   %ebx
  800dbb:	e8 15 fa ff ff       	call   8007d5 <printfmt>
				*res = -1;
  800dc0:	c6 07 ff             	movb   $0xff,(%edi)
  800dc3:	83 c4 10             	add    $0x10,%esp
			char *res = va_arg(ap, char *);
  800dc6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800dc9:	89 45 14             	mov    %eax,0x14(%ebp)
  800dcc:	e9 74 ff ff ff       	jmp    800d45 <vprintfmt+0x553>
			putch(ch, putdat);
  800dd1:	83 ec 08             	sub    $0x8,%esp
  800dd4:	56                   	push   %esi
  800dd5:	6a 25                	push   $0x25
  800dd7:	ff d3                	call   *%ebx
			break;
  800dd9:	83 c4 10             	add    $0x10,%esp
  800ddc:	e9 64 ff ff ff       	jmp    800d45 <vprintfmt+0x553>
			putch('%', putdat);
  800de1:	83 ec 08             	sub    $0x8,%esp
  800de4:	56                   	push   %esi
  800de5:	6a 25                	push   $0x25
  800de7:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800de9:	83 c4 10             	add    $0x10,%esp
  800dec:	89 f8                	mov    %edi,%eax
  800dee:	eb 03                	jmp    800df3 <vprintfmt+0x601>
  800df0:	83 e8 01             	sub    $0x1,%eax
  800df3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800df7:	75 f7                	jne    800df0 <vprintfmt+0x5fe>
  800df9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800dfc:	e9 44 ff ff ff       	jmp    800d45 <vprintfmt+0x553>
}
  800e01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e04:	5b                   	pop    %ebx
  800e05:	5e                   	pop    %esi
  800e06:	5f                   	pop    %edi
  800e07:	5d                   	pop    %ebp
  800e08:	c3                   	ret    

00800e09 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	83 ec 18             	sub    $0x18,%esp
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800e15:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800e18:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800e1c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800e1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800e26:	85 c0                	test   %eax,%eax
  800e28:	74 26                	je     800e50 <vsnprintf+0x47>
  800e2a:	85 d2                	test   %edx,%edx
  800e2c:	7e 22                	jle    800e50 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800e2e:	ff 75 14             	pushl  0x14(%ebp)
  800e31:	ff 75 10             	pushl  0x10(%ebp)
  800e34:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800e37:	50                   	push   %eax
  800e38:	68 b8 07 80 00       	push   $0x8007b8
  800e3d:	e8 b0 f9 ff ff       	call   8007f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e42:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e45:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4b:	83 c4 10             	add    $0x10,%esp
}
  800e4e:	c9                   	leave  
  800e4f:	c3                   	ret    
		return -E_INVAL;
  800e50:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e55:	eb f7                	jmp    800e4e <vsnprintf+0x45>

00800e57 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e5d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e60:	50                   	push   %eax
  800e61:	ff 75 10             	pushl  0x10(%ebp)
  800e64:	ff 75 0c             	pushl  0xc(%ebp)
  800e67:	ff 75 08             	pushl  0x8(%ebp)
  800e6a:	e8 9a ff ff ff       	call   800e09 <vsnprintf>
	va_end(ap);

	return rc;
}
  800e6f:	c9                   	leave  
  800e70:	c3                   	ret    

00800e71 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800e77:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800e80:	74 05                	je     800e87 <strlen+0x16>
		n++;
  800e82:	83 c0 01             	add    $0x1,%eax
  800e85:	eb f5                	jmp    800e7c <strlen+0xb>
	return n;
}
  800e87:	5d                   	pop    %ebp
  800e88:	c3                   	ret    

00800e89 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e92:	ba 00 00 00 00       	mov    $0x0,%edx
  800e97:	39 c2                	cmp    %eax,%edx
  800e99:	74 0d                	je     800ea8 <strnlen+0x1f>
  800e9b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800e9f:	74 05                	je     800ea6 <strnlen+0x1d>
		n++;
  800ea1:	83 c2 01             	add    $0x1,%edx
  800ea4:	eb f1                	jmp    800e97 <strnlen+0xe>
  800ea6:	89 d0                	mov    %edx,%eax
	return n;
}
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	53                   	push   %ebx
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800eb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800ebd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ec0:	83 c2 01             	add    $0x1,%edx
  800ec3:	84 c9                	test   %cl,%cl
  800ec5:	75 f2                	jne    800eb9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ec7:	5b                   	pop    %ebx
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    

00800eca <strcat>:

char *
strcat(char *dst, const char *src)
{
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	53                   	push   %ebx
  800ece:	83 ec 10             	sub    $0x10,%esp
  800ed1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ed4:	53                   	push   %ebx
  800ed5:	e8 97 ff ff ff       	call   800e71 <strlen>
  800eda:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800edd:	ff 75 0c             	pushl  0xc(%ebp)
  800ee0:	01 d8                	add    %ebx,%eax
  800ee2:	50                   	push   %eax
  800ee3:	e8 c2 ff ff ff       	call   800eaa <strcpy>
	return dst;
}
  800ee8:	89 d8                	mov    %ebx,%eax
  800eea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efa:	89 c6                	mov    %eax,%esi
  800efc:	03 75 10             	add    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800eff:	89 c2                	mov    %eax,%edx
  800f01:	39 f2                	cmp    %esi,%edx
  800f03:	74 11                	je     800f16 <strncpy+0x27>
		*dst++ = *src;
  800f05:	83 c2 01             	add    $0x1,%edx
  800f08:	0f b6 19             	movzbl (%ecx),%ebx
  800f0b:	88 5a ff             	mov    %bl,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800f0e:	80 fb 01             	cmp    $0x1,%bl
  800f11:	83 d9 ff             	sbb    $0xffffffff,%ecx
  800f14:	eb eb                	jmp    800f01 <strncpy+0x12>
	}
	return ret;
}
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	56                   	push   %esi
  800f1e:	53                   	push   %ebx
  800f1f:	8b 75 08             	mov    0x8(%ebp),%esi
  800f22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f25:	8b 55 10             	mov    0x10(%ebp),%edx
  800f28:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f2a:	85 d2                	test   %edx,%edx
  800f2c:	74 21                	je     800f4f <strlcpy+0x35>
  800f2e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800f32:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800f34:	39 c2                	cmp    %eax,%edx
  800f36:	74 14                	je     800f4c <strlcpy+0x32>
  800f38:	0f b6 19             	movzbl (%ecx),%ebx
  800f3b:	84 db                	test   %bl,%bl
  800f3d:	74 0b                	je     800f4a <strlcpy+0x30>
			*dst++ = *src++;
  800f3f:	83 c1 01             	add    $0x1,%ecx
  800f42:	83 c2 01             	add    $0x1,%edx
  800f45:	88 5a ff             	mov    %bl,-0x1(%edx)
  800f48:	eb ea                	jmp    800f34 <strlcpy+0x1a>
  800f4a:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800f4c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800f4f:	29 f0                	sub    %esi,%eax
}
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f5e:	0f b6 01             	movzbl (%ecx),%eax
  800f61:	84 c0                	test   %al,%al
  800f63:	74 0c                	je     800f71 <strcmp+0x1c>
  800f65:	3a 02                	cmp    (%edx),%al
  800f67:	75 08                	jne    800f71 <strcmp+0x1c>
		p++, q++;
  800f69:	83 c1 01             	add    $0x1,%ecx
  800f6c:	83 c2 01             	add    $0x1,%edx
  800f6f:	eb ed                	jmp    800f5e <strcmp+0x9>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f71:	0f b6 c0             	movzbl %al,%eax
  800f74:	0f b6 12             	movzbl (%edx),%edx
  800f77:	29 d0                	sub    %edx,%eax
}
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	53                   	push   %ebx
  800f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f85:	89 c3                	mov    %eax,%ebx
  800f87:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800f8a:	eb 06                	jmp    800f92 <strncmp+0x17>
		n--, p++, q++;
  800f8c:	83 c0 01             	add    $0x1,%eax
  800f8f:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800f92:	39 d8                	cmp    %ebx,%eax
  800f94:	74 16                	je     800fac <strncmp+0x31>
  800f96:	0f b6 08             	movzbl (%eax),%ecx
  800f99:	84 c9                	test   %cl,%cl
  800f9b:	74 04                	je     800fa1 <strncmp+0x26>
  800f9d:	3a 0a                	cmp    (%edx),%cl
  800f9f:	74 eb                	je     800f8c <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800fa1:	0f b6 00             	movzbl (%eax),%eax
  800fa4:	0f b6 12             	movzbl (%edx),%edx
  800fa7:	29 d0                	sub    %edx,%eax
}
  800fa9:	5b                   	pop    %ebx
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    
		return 0;
  800fac:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb1:	eb f6                	jmp    800fa9 <strncmp+0x2e>

00800fb3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800fbd:	0f b6 10             	movzbl (%eax),%edx
  800fc0:	84 d2                	test   %dl,%dl
  800fc2:	74 09                	je     800fcd <strchr+0x1a>
		if (*s == c)
  800fc4:	38 ca                	cmp    %cl,%dl
  800fc6:	74 0a                	je     800fd2 <strchr+0x1f>
	for (; *s; s++)
  800fc8:	83 c0 01             	add    $0x1,%eax
  800fcb:	eb f0                	jmp    800fbd <strchr+0xa>
			return (char *) s;
	return 0;
  800fcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fda:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800fde:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800fe1:	38 ca                	cmp    %cl,%dl
  800fe3:	74 09                	je     800fee <strfind+0x1a>
  800fe5:	84 d2                	test   %dl,%dl
  800fe7:	74 05                	je     800fee <strfind+0x1a>
	for (; *s; s++)
  800fe9:	83 c0 01             	add    $0x1,%eax
  800fec:	eb f0                	jmp    800fde <strfind+0xa>
			break;
	return (char *) s;
}
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	53                   	push   %ebx
  800ff6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ff9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ffc:	85 c9                	test   %ecx,%ecx
  800ffe:	74 31                	je     801031 <memset+0x41>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801000:	89 f8                	mov    %edi,%eax
  801002:	09 c8                	or     %ecx,%eax
  801004:	a8 03                	test   $0x3,%al
  801006:	75 23                	jne    80102b <memset+0x3b>
		c &= 0xFF;
  801008:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80100c:	89 d3                	mov    %edx,%ebx
  80100e:	c1 e3 08             	shl    $0x8,%ebx
  801011:	89 d0                	mov    %edx,%eax
  801013:	c1 e0 18             	shl    $0x18,%eax
  801016:	89 d6                	mov    %edx,%esi
  801018:	c1 e6 10             	shl    $0x10,%esi
  80101b:	09 f0                	or     %esi,%eax
  80101d:	09 c2                	or     %eax,%edx
  80101f:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801021:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801024:	89 d0                	mov    %edx,%eax
  801026:	fc                   	cld    
  801027:	f3 ab                	rep stos %eax,%es:(%edi)
  801029:	eb 06                	jmp    801031 <memset+0x41>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80102b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102e:	fc                   	cld    
  80102f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801031:	89 f8                	mov    %edi,%eax
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	57                   	push   %edi
  80103c:	56                   	push   %esi
  80103d:	8b 45 08             	mov    0x8(%ebp),%eax
  801040:	8b 75 0c             	mov    0xc(%ebp),%esi
  801043:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801046:	39 c6                	cmp    %eax,%esi
  801048:	73 32                	jae    80107c <memmove+0x44>
  80104a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80104d:	39 c2                	cmp    %eax,%edx
  80104f:	76 2b                	jbe    80107c <memmove+0x44>
		s += n;
		d += n;
  801051:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801054:	89 fe                	mov    %edi,%esi
  801056:	09 ce                	or     %ecx,%esi
  801058:	09 d6                	or     %edx,%esi
  80105a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801060:	75 0e                	jne    801070 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801062:	83 ef 04             	sub    $0x4,%edi
  801065:	8d 72 fc             	lea    -0x4(%edx),%esi
  801068:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80106b:	fd                   	std    
  80106c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80106e:	eb 09                	jmp    801079 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801070:	83 ef 01             	sub    $0x1,%edi
  801073:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801076:	fd                   	std    
  801077:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801079:	fc                   	cld    
  80107a:	eb 1a                	jmp    801096 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80107c:	89 c2                	mov    %eax,%edx
  80107e:	09 ca                	or     %ecx,%edx
  801080:	09 f2                	or     %esi,%edx
  801082:	f6 c2 03             	test   $0x3,%dl
  801085:	75 0a                	jne    801091 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801087:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80108a:	89 c7                	mov    %eax,%edi
  80108c:	fc                   	cld    
  80108d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80108f:	eb 05                	jmp    801096 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801091:	89 c7                	mov    %eax,%edi
  801093:	fc                   	cld    
  801094:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801096:	5e                   	pop    %esi
  801097:	5f                   	pop    %edi
  801098:	5d                   	pop    %ebp
  801099:	c3                   	ret    

0080109a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8010a0:	ff 75 10             	pushl  0x10(%ebp)
  8010a3:	ff 75 0c             	pushl  0xc(%ebp)
  8010a6:	ff 75 08             	pushl  0x8(%ebp)
  8010a9:	e8 8a ff ff ff       	call   801038 <memmove>
}
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    

008010b0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	56                   	push   %esi
  8010b4:	53                   	push   %ebx
  8010b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010bb:	89 c6                	mov    %eax,%esi
  8010bd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010c0:	39 f0                	cmp    %esi,%eax
  8010c2:	74 1c                	je     8010e0 <memcmp+0x30>
		if (*s1 != *s2)
  8010c4:	0f b6 08             	movzbl (%eax),%ecx
  8010c7:	0f b6 1a             	movzbl (%edx),%ebx
  8010ca:	38 d9                	cmp    %bl,%cl
  8010cc:	75 08                	jne    8010d6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8010ce:	83 c0 01             	add    $0x1,%eax
  8010d1:	83 c2 01             	add    $0x1,%edx
  8010d4:	eb ea                	jmp    8010c0 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8010d6:	0f b6 c1             	movzbl %cl,%eax
  8010d9:	0f b6 db             	movzbl %bl,%ebx
  8010dc:	29 d8                	sub    %ebx,%eax
  8010de:	eb 05                	jmp    8010e5 <memcmp+0x35>
	}

	return 0;
  8010e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8010f2:	89 c2                	mov    %eax,%edx
  8010f4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010f7:	39 d0                	cmp    %edx,%eax
  8010f9:	73 09                	jae    801104 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010fb:	38 08                	cmp    %cl,(%eax)
  8010fd:	74 05                	je     801104 <memfind+0x1b>
	for (; s < ends; s++)
  8010ff:	83 c0 01             	add    $0x1,%eax
  801102:	eb f3                	jmp    8010f7 <memfind+0xe>
			break;
	return (void *) s;
}
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    

00801106 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	57                   	push   %edi
  80110a:	56                   	push   %esi
  80110b:	53                   	push   %ebx
  80110c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801112:	eb 03                	jmp    801117 <strtol+0x11>
		s++;
  801114:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801117:	0f b6 01             	movzbl (%ecx),%eax
  80111a:	3c 20                	cmp    $0x20,%al
  80111c:	74 f6                	je     801114 <strtol+0xe>
  80111e:	3c 09                	cmp    $0x9,%al
  801120:	74 f2                	je     801114 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801122:	3c 2b                	cmp    $0x2b,%al
  801124:	74 2a                	je     801150 <strtol+0x4a>
	int neg = 0;
  801126:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80112b:	3c 2d                	cmp    $0x2d,%al
  80112d:	74 2b                	je     80115a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80112f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801135:	75 0f                	jne    801146 <strtol+0x40>
  801137:	80 39 30             	cmpb   $0x30,(%ecx)
  80113a:	74 28                	je     801164 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80113c:	85 db                	test   %ebx,%ebx
  80113e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801143:	0f 44 d8             	cmove  %eax,%ebx
  801146:	b8 00 00 00 00       	mov    $0x0,%eax
  80114b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80114e:	eb 50                	jmp    8011a0 <strtol+0x9a>
		s++;
  801150:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801153:	bf 00 00 00 00       	mov    $0x0,%edi
  801158:	eb d5                	jmp    80112f <strtol+0x29>
		s++, neg = 1;
  80115a:	83 c1 01             	add    $0x1,%ecx
  80115d:	bf 01 00 00 00       	mov    $0x1,%edi
  801162:	eb cb                	jmp    80112f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801164:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801168:	74 0e                	je     801178 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  80116a:	85 db                	test   %ebx,%ebx
  80116c:	75 d8                	jne    801146 <strtol+0x40>
		s++, base = 8;
  80116e:	83 c1 01             	add    $0x1,%ecx
  801171:	bb 08 00 00 00       	mov    $0x8,%ebx
  801176:	eb ce                	jmp    801146 <strtol+0x40>
		s += 2, base = 16;
  801178:	83 c1 02             	add    $0x2,%ecx
  80117b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801180:	eb c4                	jmp    801146 <strtol+0x40>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801182:	8d 72 9f             	lea    -0x61(%edx),%esi
  801185:	89 f3                	mov    %esi,%ebx
  801187:	80 fb 19             	cmp    $0x19,%bl
  80118a:	77 29                	ja     8011b5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  80118c:	0f be d2             	movsbl %dl,%edx
  80118f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801192:	3b 55 10             	cmp    0x10(%ebp),%edx
  801195:	7d 30                	jge    8011c7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801197:	83 c1 01             	add    $0x1,%ecx
  80119a:	0f af 45 10          	imul   0x10(%ebp),%eax
  80119e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8011a0:	0f b6 11             	movzbl (%ecx),%edx
  8011a3:	8d 72 d0             	lea    -0x30(%edx),%esi
  8011a6:	89 f3                	mov    %esi,%ebx
  8011a8:	80 fb 09             	cmp    $0x9,%bl
  8011ab:	77 d5                	ja     801182 <strtol+0x7c>
			dig = *s - '0';
  8011ad:	0f be d2             	movsbl %dl,%edx
  8011b0:	83 ea 30             	sub    $0x30,%edx
  8011b3:	eb dd                	jmp    801192 <strtol+0x8c>
		else if (*s >= 'A' && *s <= 'Z')
  8011b5:	8d 72 bf             	lea    -0x41(%edx),%esi
  8011b8:	89 f3                	mov    %esi,%ebx
  8011ba:	80 fb 19             	cmp    $0x19,%bl
  8011bd:	77 08                	ja     8011c7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8011bf:	0f be d2             	movsbl %dl,%edx
  8011c2:	83 ea 37             	sub    $0x37,%edx
  8011c5:	eb cb                	jmp    801192 <strtol+0x8c>
		// we don't properly detect overflow!
	}

	if (endptr)
  8011c7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011cb:	74 05                	je     8011d2 <strtol+0xcc>
		*endptr = (char *) s;
  8011cd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011d0:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	f7 da                	neg    %edx
  8011d6:	85 ff                	test   %edi,%edi
  8011d8:	0f 45 c2             	cmovne %edx,%eax
}
  8011db:	5b                   	pop    %ebx
  8011dc:	5e                   	pop    %esi
  8011dd:	5f                   	pop    %edi
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	57                   	push   %edi
  8011e4:	56                   	push   %esi
  8011e5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8011e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f1:	89 c3                	mov    %eax,%ebx
  8011f3:	89 c7                	mov    %eax,%edi
  8011f5:	89 c6                	mov    %eax,%esi
  8011f7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8011f9:	5b                   	pop    %ebx
  8011fa:	5e                   	pop    %esi
  8011fb:	5f                   	pop    %edi
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <sys_cgetc>:

int
sys_cgetc(void)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	57                   	push   %edi
  801202:	56                   	push   %esi
  801203:	53                   	push   %ebx
	asm volatile("int %1\n"
  801204:	ba 00 00 00 00       	mov    $0x0,%edx
  801209:	b8 01 00 00 00       	mov    $0x1,%eax
  80120e:	89 d1                	mov    %edx,%ecx
  801210:	89 d3                	mov    %edx,%ebx
  801212:	89 d7                	mov    %edx,%edi
  801214:	89 d6                	mov    %edx,%esi
  801216:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801218:	5b                   	pop    %ebx
  801219:	5e                   	pop    %esi
  80121a:	5f                   	pop    %edi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	57                   	push   %edi
  801221:	56                   	push   %esi
  801222:	53                   	push   %ebx
  801223:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801226:	b9 00 00 00 00       	mov    $0x0,%ecx
  80122b:	8b 55 08             	mov    0x8(%ebp),%edx
  80122e:	b8 03 00 00 00       	mov    $0x3,%eax
  801233:	89 cb                	mov    %ecx,%ebx
  801235:	89 cf                	mov    %ecx,%edi
  801237:	89 ce                	mov    %ecx,%esi
  801239:	cd 30                	int    $0x30
	if(check && ret > 0)
  80123b:	85 c0                	test   %eax,%eax
  80123d:	7f 08                	jg     801247 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80123f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801242:	5b                   	pop    %ebx
  801243:	5e                   	pop    %esi
  801244:	5f                   	pop    %edi
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801247:	83 ec 0c             	sub    $0xc,%esp
  80124a:	50                   	push   %eax
  80124b:	6a 03                	push   $0x3
  80124d:	68 84 1b 80 00       	push   $0x801b84
  801252:	6a 23                	push   $0x23
  801254:	68 a1 1b 80 00       	push   $0x801ba1
  801259:	e8 db f3 ff ff       	call   800639 <_panic>

0080125e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
	asm volatile("int %1\n"
  801264:	ba 00 00 00 00       	mov    $0x0,%edx
  801269:	b8 02 00 00 00       	mov    $0x2,%eax
  80126e:	89 d1                	mov    %edx,%ecx
  801270:	89 d3                	mov    %edx,%ebx
  801272:	89 d7                	mov    %edx,%edi
  801274:	89 d6                	mov    %edx,%esi
  801276:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <sys_yield>:

void
sys_yield(void)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
  801280:	57                   	push   %edi
  801281:	56                   	push   %esi
  801282:	53                   	push   %ebx
	asm volatile("int %1\n"
  801283:	ba 00 00 00 00       	mov    $0x0,%edx
  801288:	b8 0a 00 00 00       	mov    $0xa,%eax
  80128d:	89 d1                	mov    %edx,%ecx
  80128f:	89 d3                	mov    %edx,%ebx
  801291:	89 d7                	mov    %edx,%edi
  801293:	89 d6                	mov    %edx,%esi
  801295:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801297:	5b                   	pop    %ebx
  801298:	5e                   	pop    %esi
  801299:	5f                   	pop    %edi
  80129a:	5d                   	pop    %ebp
  80129b:	c3                   	ret    

0080129c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	57                   	push   %edi
  8012a0:	56                   	push   %esi
  8012a1:	53                   	push   %ebx
  8012a2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012a5:	be 00 00 00 00       	mov    $0x0,%esi
  8012aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8012ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8012b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012b8:	89 f7                	mov    %esi,%edi
  8012ba:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	7f 08                	jg     8012c8 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c3:	5b                   	pop    %ebx
  8012c4:	5e                   	pop    %esi
  8012c5:	5f                   	pop    %edi
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c8:	83 ec 0c             	sub    $0xc,%esp
  8012cb:	50                   	push   %eax
  8012cc:	6a 04                	push   $0x4
  8012ce:	68 84 1b 80 00       	push   $0x801b84
  8012d3:	6a 23                	push   $0x23
  8012d5:	68 a1 1b 80 00       	push   $0x801ba1
  8012da:	e8 5a f3 ff ff       	call   800639 <_panic>

008012df <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	57                   	push   %edi
  8012e3:	56                   	push   %esi
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8012eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8012f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012f6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012f9:	8b 75 18             	mov    0x18(%ebp),%esi
  8012fc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012fe:	85 c0                	test   %eax,%eax
  801300:	7f 08                	jg     80130a <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801302:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801305:	5b                   	pop    %ebx
  801306:	5e                   	pop    %esi
  801307:	5f                   	pop    %edi
  801308:	5d                   	pop    %ebp
  801309:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80130a:	83 ec 0c             	sub    $0xc,%esp
  80130d:	50                   	push   %eax
  80130e:	6a 05                	push   $0x5
  801310:	68 84 1b 80 00       	push   $0x801b84
  801315:	6a 23                	push   $0x23
  801317:	68 a1 1b 80 00       	push   $0x801ba1
  80131c:	e8 18 f3 ff ff       	call   800639 <_panic>

00801321 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	57                   	push   %edi
  801325:	56                   	push   %esi
  801326:	53                   	push   %ebx
  801327:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80132a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80132f:	8b 55 08             	mov    0x8(%ebp),%edx
  801332:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801335:	b8 06 00 00 00       	mov    $0x6,%eax
  80133a:	89 df                	mov    %ebx,%edi
  80133c:	89 de                	mov    %ebx,%esi
  80133e:	cd 30                	int    $0x30
	if(check && ret > 0)
  801340:	85 c0                	test   %eax,%eax
  801342:	7f 08                	jg     80134c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801344:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5f                   	pop    %edi
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80134c:	83 ec 0c             	sub    $0xc,%esp
  80134f:	50                   	push   %eax
  801350:	6a 06                	push   $0x6
  801352:	68 84 1b 80 00       	push   $0x801b84
  801357:	6a 23                	push   $0x23
  801359:	68 a1 1b 80 00       	push   $0x801ba1
  80135e:	e8 d6 f2 ff ff       	call   800639 <_panic>

00801363 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	57                   	push   %edi
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
  801369:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80136c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801371:	8b 55 08             	mov    0x8(%ebp),%edx
  801374:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801377:	b8 08 00 00 00       	mov    $0x8,%eax
  80137c:	89 df                	mov    %ebx,%edi
  80137e:	89 de                	mov    %ebx,%esi
  801380:	cd 30                	int    $0x30
	if(check && ret > 0)
  801382:	85 c0                	test   %eax,%eax
  801384:	7f 08                	jg     80138e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801386:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801389:	5b                   	pop    %ebx
  80138a:	5e                   	pop    %esi
  80138b:	5f                   	pop    %edi
  80138c:	5d                   	pop    %ebp
  80138d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80138e:	83 ec 0c             	sub    $0xc,%esp
  801391:	50                   	push   %eax
  801392:	6a 08                	push   $0x8
  801394:	68 84 1b 80 00       	push   $0x801b84
  801399:	6a 23                	push   $0x23
  80139b:	68 a1 1b 80 00       	push   $0x801ba1
  8013a0:	e8 94 f2 ff ff       	call   800639 <_panic>

008013a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	57                   	push   %edi
  8013a9:	56                   	push   %esi
  8013aa:	53                   	push   %ebx
  8013ab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8013ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013b9:	b8 09 00 00 00       	mov    $0x9,%eax
  8013be:	89 df                	mov    %ebx,%edi
  8013c0:	89 de                	mov    %ebx,%esi
  8013c2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	7f 08                	jg     8013d0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8013c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013cb:	5b                   	pop    %ebx
  8013cc:	5e                   	pop    %esi
  8013cd:	5f                   	pop    %edi
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	50                   	push   %eax
  8013d4:	6a 09                	push   $0x9
  8013d6:	68 84 1b 80 00       	push   $0x801b84
  8013db:	6a 23                	push   $0x23
  8013dd:	68 a1 1b 80 00       	push   $0x801ba1
  8013e2:	e8 52 f2 ff ff       	call   800639 <_panic>

008013e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	57                   	push   %edi
  8013eb:	56                   	push   %esi
  8013ec:	53                   	push   %ebx
	asm volatile("int %1\n"
  8013ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013f3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8013f8:	be 00 00 00 00       	mov    $0x0,%esi
  8013fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801400:	8b 7d 14             	mov    0x14(%ebp),%edi
  801403:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801405:	5b                   	pop    %ebx
  801406:	5e                   	pop    %esi
  801407:	5f                   	pop    %edi
  801408:	5d                   	pop    %ebp
  801409:	c3                   	ret    

0080140a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	57                   	push   %edi
  80140e:	56                   	push   %esi
  80140f:	53                   	push   %ebx
  801410:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801413:	b9 00 00 00 00       	mov    $0x0,%ecx
  801418:	8b 55 08             	mov    0x8(%ebp),%edx
  80141b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801420:	89 cb                	mov    %ecx,%ebx
  801422:	89 cf                	mov    %ecx,%edi
  801424:	89 ce                	mov    %ecx,%esi
  801426:	cd 30                	int    $0x30
	if(check && ret > 0)
  801428:	85 c0                	test   %eax,%eax
  80142a:	7f 08                	jg     801434 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80142c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142f:	5b                   	pop    %ebx
  801430:	5e                   	pop    %esi
  801431:	5f                   	pop    %edi
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801434:	83 ec 0c             	sub    $0xc,%esp
  801437:	50                   	push   %eax
  801438:	6a 0c                	push   $0xc
  80143a:	68 84 1b 80 00       	push   $0x801b84
  80143f:	6a 23                	push   $0x23
  801441:	68 a1 1b 80 00       	push   $0x801ba1
  801446:	e8 ee f1 ff ff       	call   800639 <_panic>

0080144b <sys_map_kernel_page>:

int
sys_map_kernel_page(void* kpage, void* va)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	57                   	push   %edi
  80144f:	56                   	push   %esi
  801450:	53                   	push   %ebx
	asm volatile("int %1\n"
  801451:	bb 00 00 00 00       	mov    $0x0,%ebx
  801456:	8b 55 08             	mov    0x8(%ebp),%edx
  801459:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80145c:	b8 0d 00 00 00       	mov    $0xd,%eax
  801461:	89 df                	mov    %ebx,%edi
  801463:	89 de                	mov    %ebx,%esi
  801465:	cd 30                	int    $0x30
	return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}
  801467:	5b                   	pop    %ebx
  801468:	5e                   	pop    %esi
  801469:	5f                   	pop    %edi
  80146a:	5d                   	pop    %ebp
  80146b:	c3                   	ret    

0080146c <sys_sbrk>:

int
sys_sbrk(uint32_t inc)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	57                   	push   %edi
  801470:	56                   	push   %esi
  801471:	53                   	push   %ebx
	asm volatile("int %1\n"
  801472:	b9 00 00 00 00       	mov    $0x0,%ecx
  801477:	8b 55 08             	mov    0x8(%ebp),%edx
  80147a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80147f:	89 cb                	mov    %ecx,%ebx
  801481:	89 cf                	mov    %ecx,%edi
  801483:	89 ce                	mov    %ecx,%esi
  801485:	cd 30                	int    $0x30
	return syscall(SYS_sbrk, 0, (uint32_t)inc, (uint32_t)0, 0, 0, 0);
}
  801487:	5b                   	pop    %ebx
  801488:	5e                   	pop    %esi
  801489:	5f                   	pop    %edi
  80148a:	5d                   	pop    %ebp
  80148b:	c3                   	ret    

0080148c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801492:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  801499:	74 0a                	je     8014a5 <set_pgfault_handler+0x19>
		if ((r = sys_env_set_pgfault_upcall((envid_t)0, _pgfault_upcall)) < 0)
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80149b:	8b 45 08             	mov    0x8(%ebp),%eax
  80149e:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  8014a3:	c9                   	leave  
  8014a4:	c3                   	ret    
		if ((r = sys_page_alloc((envid_t)0, (void *)(UXSTACKTOP - PGSIZE), PTE_U | PTE_P | PTE_W)) < 0) 
  8014a5:	83 ec 04             	sub    $0x4,%esp
  8014a8:	6a 07                	push   $0x7
  8014aa:	68 00 f0 bf ee       	push   $0xeebff000
  8014af:	6a 00                	push   $0x0
  8014b1:	e8 e6 fd ff ff       	call   80129c <sys_page_alloc>
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 2a                	js     8014e7 <set_pgfault_handler+0x5b>
		if ((r = sys_env_set_pgfault_upcall((envid_t)0, _pgfault_upcall)) < 0)
  8014bd:	83 ec 08             	sub    $0x8,%esp
  8014c0:	68 fb 14 80 00       	push   $0x8014fb
  8014c5:	6a 00                	push   $0x0
  8014c7:	e8 d9 fe ff ff       	call   8013a5 <sys_env_set_pgfault_upcall>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	79 c8                	jns    80149b <set_pgfault_handler+0xf>
			panic("set_pgfault_handler: sys_env_set_pgfault_upcall fail");
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	68 dc 1b 80 00       	push   $0x801bdc
  8014db:	6a 23                	push   $0x23
  8014dd:	68 14 1c 80 00       	push   $0x801c14
  8014e2:	e8 52 f1 ff ff       	call   800639 <_panic>
			panic("set_pgfault_handler: sys_page_alloc fail");
  8014e7:	83 ec 04             	sub    $0x4,%esp
  8014ea:	68 b0 1b 80 00       	push   $0x801bb0
  8014ef:	6a 21                	push   $0x21
  8014f1:	68 14 1c 80 00       	push   $0x801c14
  8014f6:	e8 3e f1 ff ff       	call   800639 <_panic>

008014fb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014fb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014fc:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  801501:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801503:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %ebp
  801506:	8b 6c 24 28          	mov    0x28(%esp),%ebp
	movl 48(%esp), %ebx
  80150a:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  80150e:	83 eb 04             	sub    $0x4,%ebx
	movl %ebp, (%ebx)
  801511:	89 2b                	mov    %ebp,(%ebx)
	movl %ebx, 48(%esp)
  801513:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801517:	83 c4 08             	add    $0x8,%esp
	popal
  80151a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80151b:	83 c4 04             	add    $0x4,%esp
	popfl
  80151e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80151f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801520:	c3                   	ret    
  801521:	66 90                	xchg   %ax,%ax
  801523:	66 90                	xchg   %ax,%ax
  801525:	66 90                	xchg   %ax,%ax
  801527:	66 90                	xchg   %ax,%ax
  801529:	66 90                	xchg   %ax,%ax
  80152b:	66 90                	xchg   %ax,%ax
  80152d:	66 90                	xchg   %ax,%ax
  80152f:	90                   	nop

00801530 <__udivdi3>:
  801530:	55                   	push   %ebp
  801531:	57                   	push   %edi
  801532:	56                   	push   %esi
  801533:	53                   	push   %ebx
  801534:	83 ec 1c             	sub    $0x1c,%esp
  801537:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80153b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80153f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801543:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801547:	85 d2                	test   %edx,%edx
  801549:	75 4d                	jne    801598 <__udivdi3+0x68>
  80154b:	39 f3                	cmp    %esi,%ebx
  80154d:	76 19                	jbe    801568 <__udivdi3+0x38>
  80154f:	31 ff                	xor    %edi,%edi
  801551:	89 e8                	mov    %ebp,%eax
  801553:	89 f2                	mov    %esi,%edx
  801555:	f7 f3                	div    %ebx
  801557:	89 fa                	mov    %edi,%edx
  801559:	83 c4 1c             	add    $0x1c,%esp
  80155c:	5b                   	pop    %ebx
  80155d:	5e                   	pop    %esi
  80155e:	5f                   	pop    %edi
  80155f:	5d                   	pop    %ebp
  801560:	c3                   	ret    
  801561:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801568:	89 d9                	mov    %ebx,%ecx
  80156a:	85 db                	test   %ebx,%ebx
  80156c:	75 0b                	jne    801579 <__udivdi3+0x49>
  80156e:	b8 01 00 00 00       	mov    $0x1,%eax
  801573:	31 d2                	xor    %edx,%edx
  801575:	f7 f3                	div    %ebx
  801577:	89 c1                	mov    %eax,%ecx
  801579:	31 d2                	xor    %edx,%edx
  80157b:	89 f0                	mov    %esi,%eax
  80157d:	f7 f1                	div    %ecx
  80157f:	89 c6                	mov    %eax,%esi
  801581:	89 e8                	mov    %ebp,%eax
  801583:	89 f7                	mov    %esi,%edi
  801585:	f7 f1                	div    %ecx
  801587:	89 fa                	mov    %edi,%edx
  801589:	83 c4 1c             	add    $0x1c,%esp
  80158c:	5b                   	pop    %ebx
  80158d:	5e                   	pop    %esi
  80158e:	5f                   	pop    %edi
  80158f:	5d                   	pop    %ebp
  801590:	c3                   	ret    
  801591:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801598:	39 f2                	cmp    %esi,%edx
  80159a:	77 1c                	ja     8015b8 <__udivdi3+0x88>
  80159c:	0f bd fa             	bsr    %edx,%edi
  80159f:	83 f7 1f             	xor    $0x1f,%edi
  8015a2:	75 2c                	jne    8015d0 <__udivdi3+0xa0>
  8015a4:	39 f2                	cmp    %esi,%edx
  8015a6:	72 06                	jb     8015ae <__udivdi3+0x7e>
  8015a8:	31 c0                	xor    %eax,%eax
  8015aa:	39 eb                	cmp    %ebp,%ebx
  8015ac:	77 a9                	ja     801557 <__udivdi3+0x27>
  8015ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8015b3:	eb a2                	jmp    801557 <__udivdi3+0x27>
  8015b5:	8d 76 00             	lea    0x0(%esi),%esi
  8015b8:	31 ff                	xor    %edi,%edi
  8015ba:	31 c0                	xor    %eax,%eax
  8015bc:	89 fa                	mov    %edi,%edx
  8015be:	83 c4 1c             	add    $0x1c,%esp
  8015c1:	5b                   	pop    %ebx
  8015c2:	5e                   	pop    %esi
  8015c3:	5f                   	pop    %edi
  8015c4:	5d                   	pop    %ebp
  8015c5:	c3                   	ret    
  8015c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8015cd:	8d 76 00             	lea    0x0(%esi),%esi
  8015d0:	89 f9                	mov    %edi,%ecx
  8015d2:	b8 20 00 00 00       	mov    $0x20,%eax
  8015d7:	29 f8                	sub    %edi,%eax
  8015d9:	d3 e2                	shl    %cl,%edx
  8015db:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015df:	89 c1                	mov    %eax,%ecx
  8015e1:	89 da                	mov    %ebx,%edx
  8015e3:	d3 ea                	shr    %cl,%edx
  8015e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8015e9:	09 d1                	or     %edx,%ecx
  8015eb:	89 f2                	mov    %esi,%edx
  8015ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015f1:	89 f9                	mov    %edi,%ecx
  8015f3:	d3 e3                	shl    %cl,%ebx
  8015f5:	89 c1                	mov    %eax,%ecx
  8015f7:	d3 ea                	shr    %cl,%edx
  8015f9:	89 f9                	mov    %edi,%ecx
  8015fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8015ff:	89 eb                	mov    %ebp,%ebx
  801601:	d3 e6                	shl    %cl,%esi
  801603:	89 c1                	mov    %eax,%ecx
  801605:	d3 eb                	shr    %cl,%ebx
  801607:	09 de                	or     %ebx,%esi
  801609:	89 f0                	mov    %esi,%eax
  80160b:	f7 74 24 08          	divl   0x8(%esp)
  80160f:	89 d6                	mov    %edx,%esi
  801611:	89 c3                	mov    %eax,%ebx
  801613:	f7 64 24 0c          	mull   0xc(%esp)
  801617:	39 d6                	cmp    %edx,%esi
  801619:	72 15                	jb     801630 <__udivdi3+0x100>
  80161b:	89 f9                	mov    %edi,%ecx
  80161d:	d3 e5                	shl    %cl,%ebp
  80161f:	39 c5                	cmp    %eax,%ebp
  801621:	73 04                	jae    801627 <__udivdi3+0xf7>
  801623:	39 d6                	cmp    %edx,%esi
  801625:	74 09                	je     801630 <__udivdi3+0x100>
  801627:	89 d8                	mov    %ebx,%eax
  801629:	31 ff                	xor    %edi,%edi
  80162b:	e9 27 ff ff ff       	jmp    801557 <__udivdi3+0x27>
  801630:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801633:	31 ff                	xor    %edi,%edi
  801635:	e9 1d ff ff ff       	jmp    801557 <__udivdi3+0x27>
  80163a:	66 90                	xchg   %ax,%ax
  80163c:	66 90                	xchg   %ax,%ax
  80163e:	66 90                	xchg   %ax,%ax

00801640 <__umoddi3>:
  801640:	55                   	push   %ebp
  801641:	57                   	push   %edi
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
  801644:	83 ec 1c             	sub    $0x1c,%esp
  801647:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  80164b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80164f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801653:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801657:	89 da                	mov    %ebx,%edx
  801659:	85 c0                	test   %eax,%eax
  80165b:	75 43                	jne    8016a0 <__umoddi3+0x60>
  80165d:	39 df                	cmp    %ebx,%edi
  80165f:	76 17                	jbe    801678 <__umoddi3+0x38>
  801661:	89 f0                	mov    %esi,%eax
  801663:	f7 f7                	div    %edi
  801665:	89 d0                	mov    %edx,%eax
  801667:	31 d2                	xor    %edx,%edx
  801669:	83 c4 1c             	add    $0x1c,%esp
  80166c:	5b                   	pop    %ebx
  80166d:	5e                   	pop    %esi
  80166e:	5f                   	pop    %edi
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    
  801671:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801678:	89 fd                	mov    %edi,%ebp
  80167a:	85 ff                	test   %edi,%edi
  80167c:	75 0b                	jne    801689 <__umoddi3+0x49>
  80167e:	b8 01 00 00 00       	mov    $0x1,%eax
  801683:	31 d2                	xor    %edx,%edx
  801685:	f7 f7                	div    %edi
  801687:	89 c5                	mov    %eax,%ebp
  801689:	89 d8                	mov    %ebx,%eax
  80168b:	31 d2                	xor    %edx,%edx
  80168d:	f7 f5                	div    %ebp
  80168f:	89 f0                	mov    %esi,%eax
  801691:	f7 f5                	div    %ebp
  801693:	89 d0                	mov    %edx,%eax
  801695:	eb d0                	jmp    801667 <__umoddi3+0x27>
  801697:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80169e:	66 90                	xchg   %ax,%ax
  8016a0:	89 f1                	mov    %esi,%ecx
  8016a2:	39 d8                	cmp    %ebx,%eax
  8016a4:	76 0a                	jbe    8016b0 <__umoddi3+0x70>
  8016a6:	89 f0                	mov    %esi,%eax
  8016a8:	83 c4 1c             	add    $0x1c,%esp
  8016ab:	5b                   	pop    %ebx
  8016ac:	5e                   	pop    %esi
  8016ad:	5f                   	pop    %edi
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    
  8016b0:	0f bd e8             	bsr    %eax,%ebp
  8016b3:	83 f5 1f             	xor    $0x1f,%ebp
  8016b6:	75 20                	jne    8016d8 <__umoddi3+0x98>
  8016b8:	39 d8                	cmp    %ebx,%eax
  8016ba:	0f 82 b0 00 00 00    	jb     801770 <__umoddi3+0x130>
  8016c0:	39 f7                	cmp    %esi,%edi
  8016c2:	0f 86 a8 00 00 00    	jbe    801770 <__umoddi3+0x130>
  8016c8:	89 c8                	mov    %ecx,%eax
  8016ca:	83 c4 1c             	add    $0x1c,%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5f                   	pop    %edi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    
  8016d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8016d8:	89 e9                	mov    %ebp,%ecx
  8016da:	ba 20 00 00 00       	mov    $0x20,%edx
  8016df:	29 ea                	sub    %ebp,%edx
  8016e1:	d3 e0                	shl    %cl,%eax
  8016e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e7:	89 d1                	mov    %edx,%ecx
  8016e9:	89 f8                	mov    %edi,%eax
  8016eb:	d3 e8                	shr    %cl,%eax
  8016ed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8016f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016f5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8016f9:	09 c1                	or     %eax,%ecx
  8016fb:	89 d8                	mov    %ebx,%eax
  8016fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801701:	89 e9                	mov    %ebp,%ecx
  801703:	d3 e7                	shl    %cl,%edi
  801705:	89 d1                	mov    %edx,%ecx
  801707:	d3 e8                	shr    %cl,%eax
  801709:	89 e9                	mov    %ebp,%ecx
  80170b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80170f:	d3 e3                	shl    %cl,%ebx
  801711:	89 c7                	mov    %eax,%edi
  801713:	89 d1                	mov    %edx,%ecx
  801715:	89 f0                	mov    %esi,%eax
  801717:	d3 e8                	shr    %cl,%eax
  801719:	89 e9                	mov    %ebp,%ecx
  80171b:	89 fa                	mov    %edi,%edx
  80171d:	d3 e6                	shl    %cl,%esi
  80171f:	09 d8                	or     %ebx,%eax
  801721:	f7 74 24 08          	divl   0x8(%esp)
  801725:	89 d1                	mov    %edx,%ecx
  801727:	89 f3                	mov    %esi,%ebx
  801729:	f7 64 24 0c          	mull   0xc(%esp)
  80172d:	89 c6                	mov    %eax,%esi
  80172f:	89 d7                	mov    %edx,%edi
  801731:	39 d1                	cmp    %edx,%ecx
  801733:	72 06                	jb     80173b <__umoddi3+0xfb>
  801735:	75 10                	jne    801747 <__umoddi3+0x107>
  801737:	39 c3                	cmp    %eax,%ebx
  801739:	73 0c                	jae    801747 <__umoddi3+0x107>
  80173b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80173f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801743:	89 d7                	mov    %edx,%edi
  801745:	89 c6                	mov    %eax,%esi
  801747:	89 ca                	mov    %ecx,%edx
  801749:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80174e:	29 f3                	sub    %esi,%ebx
  801750:	19 fa                	sbb    %edi,%edx
  801752:	89 d0                	mov    %edx,%eax
  801754:	d3 e0                	shl    %cl,%eax
  801756:	89 e9                	mov    %ebp,%ecx
  801758:	d3 eb                	shr    %cl,%ebx
  80175a:	d3 ea                	shr    %cl,%edx
  80175c:	09 d8                	or     %ebx,%eax
  80175e:	83 c4 1c             	add    $0x1c,%esp
  801761:	5b                   	pop    %ebx
  801762:	5e                   	pop    %esi
  801763:	5f                   	pop    %edi
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    
  801766:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80176d:	8d 76 00             	lea    0x0(%esi),%esi
  801770:	89 da                	mov    %ebx,%edx
  801772:	29 fe                	sub    %edi,%esi
  801774:	19 c2                	sbb    %eax,%edx
  801776:	89 f1                	mov    %esi,%ecx
  801778:	89 c8                	mov    %ecx,%eax
  80177a:	e9 4b ff ff ff       	jmp    8016ca <__umoddi3+0x8a>
