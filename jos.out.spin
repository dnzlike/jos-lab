+ ld obj/kern/kernel
+ mk obj/kern/kernel.img
c[?7l[2J[0mSeaBIOS (version 1.11.1-1ubuntu1)


iPXE (http://ipxe.org) 00:03.0 C980 PCI2.10 PnP PMM+07F8D340+07ECD340 C980
Press Ctrl-B to configure iPXE (PCI 00:03.0)...


Booting from Hard Disk..6828 decimal is 015254 octal!
pading space in the right to number 22: 22      .
chnum1: 29 chnum2: 30

error! writing through NULL pointer! (%n argument)

warning! The value %n argument pointed to has been overflowed!
chnum1: -1
show me the sign: +1024, -1024
Physical memory: 131072K available, base = 640K, extended = 130432K
kern_pgdir: 293000
pages: 294000
check_page_free_list() succeeded!
check_page_alloc() succeeded!
check_page() succeeded!
check_kern_pgdir() succeeded!
check_page_free_list() succeeded!
check_page_installed_pgdir() succeeded!
SMP: CPU 0 found 1 CPU(s)
enabled interrupts: 1 2
[00000000] new env 00001000
[00000000] new env 00001001
I am the parent.  Forking the child...
[00001000] user panic in <unknown> at lib/fork.c:81: fork not implemented
TRAP frame at 0xf02d4000 from CPU 0
  edi  0x00000000
  esi  0x00801276
  ebp  0xeebfdf90
  oesp 0xefffffdc
  ebx  0xeebfdfa4
  edx  0xeebfde48
  ecx  0x00000001
  eax  0x00000001
  es   0x----0023
  ds   0x----0023
  trap 0x00000003 Breakpoint
  err  0x00000000
  eip  0x00800f8c
  cs   0x----001b
  flag 0x00000086
  esp  0xeebfdf88
  ss   0x----0023
Welcome to the JOS kernel monitor!
Type 'help' for a list of commands.
qemu-system-i386: terminating on signal 15 from pid 45562 (make)