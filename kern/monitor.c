// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display information about current program", mon_backtrace },
	{ "time", "Counts the running time (in clocks cycles) of the command", mon_time },
	{ "showmappings", "Display information about mapping and permisions", mon_showmappings },
	{ "setpermisions", "Set clear or change the permissions of any mapping in the current address space", mon_setpermisions },
};

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
    return pretaddr;
}

void
do_overflow(void)
{
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
	// You should use a techique similar to buffer overflow
	// to invoke the do_overflow function and
	// the procedure must return normally.

    // And you must use the "cprintf" function with %n specifier
    // you augmented in the "Exercise 9" to do this job.

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;

	char * pret_addr = (char *) read_pretaddr();

    uint32_t overflow_ra = (uint32_t) do_overflow;
    for (int i = 0; i < 4; i++) {
		// try to make do_overflow return normally
		// print spaces in stdout
    	cprintf("%*s%n\n", pret_addr[i] & 0xff, "", pret_addr + 4 + i);
	}
    for (int i = 0; i < 4; i++) {
		// change start_overflow's RA to do_overflow's RA
    	cprintf("%*s%n\n", (overflow_ra >> (8 * i)) & 0xff, "", pret_addr + i);
	}
	// Your code here.
    


}

void
overflow_me(void)
{
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	
	overflow_me();
    cprintf("Stack backtrace:\n");
	uint32_t *ebp = (uint32_t *)read_ebp();
    while (ebp != NULL) {
		// ebp means the address ebp points to
		// *ebp = ebp[0] means the value in the address
		// ebp points to
    	cprintf("  eip %08x  ebp %08x  args %08x %08x %08x %08x %08x\n",
        	ebp[1], 
			(uint32_t)ebp, 
			ebp[2], 
			ebp[3], 
			ebp[4], 
			ebp[5], 
			ebp[6]);
		
		struct Eipdebuginfo info;
		debuginfo_eip((uintptr_t)ebp[1], &info);
		//	 kern/monitor.c:143 monitor+106
		// %.*s means precision
		cprintf("      %s:%u %.*s+%u\n",
    		info.eip_file, 
			info.eip_line, 
			info.eip_fn_namelen, 
			info.eip_fn_name, 
			ebp[1] - (uint32_t)info.eip_fn_addr);
		// cprintf("%s:%u\n", info.eip_file, info.eip_line);
    	ebp = (uint32_t *)(ebp[0]);
    }
	cprintf("Backtrace success\n");
	return 0;
}

int
mon_time(int argc, char **argv, struct Trapframe *tf)
{
	if (argc != 2) {
		cprintf("Usage: time [command]\n");
		return 0;
	}
	else if (argc == 1 && strcmp(argv[0], "time")) {
		return commands[3].func(argc - 1, argv + 1, tf);
	}

	for (int i = 0; i < ARRAY_SIZE(commands); i++) {
		if (!strcmp(argv[1], commands[i].name) && strcmp(argv[1], "time")) {
			uint32_t lo, hi;
			uint64_t start = 0, end = 0;
			__asm __volatile("rdtsc":"=a"(lo),"=d"(hi));
			start = (uint64_t)hi << 32 | lo;
			commands[i].func(argc - 1, argv + 1, tf);
			__asm __volatile("rdtsc":"=a"(lo),"=d"(hi));
			end = (uint64_t)hi << 32 | lo;
			cprintf("%s cycles: %d\n", commands[i].name, end - start);
			return 0;
		}
	}

	cprintf("Unknown command:'%s'\n", argv[1]);
	return 0;
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
	extern pde_t *kern_pgdir;
	uintptr_t start, end;
	if (argc != 3) {
		cprintf("usage: %s start end\n", argv[0]);
		return -1;
	}
	start = ROUNDDOWN(strtol(argv[1], NULL, 16), PGSIZE);
	end = ROUNDDOWN(strtol(argv[2], NULL, 16), PGSIZE);
	if (start > end) {
		cprintf("start cannot be larger than end\n");
		return -1;
	}
	for (uintptr_t i = start; i <= end; i += PGSIZE) {
		pte_t* pte = pgdir_walk(kern_pgdir, (void*)i, 0);
		if (!pte) cprintf("  0x%08x(virt)  not mapped(phys)\n", i);
		else cprintf("  0x%08x(virt)  0x%08x(phys) PTE_P  %x  PTE_W  %x  PTE_U  %x\n",
			i, *pte & (~0xfff), *pte & PTE_P, *pte & PTE_W, *pte & PTE_U);
	}
	return 0;
}

int
mon_setpermisions(int argc, char **argv, struct Trapframe *tf)
{
	extern pde_t *kern_pgdir;
	uintptr_t addr, perm;
	if (argc != 3) {
		cprintf("usage: %s addr perm\n", argv[0]);
		return -1;
	}
	addr = ROUNDDOWN(strtol(argv[1], NULL, 16), PGSIZE);
	perm = strtol(argv[2], NULL, 16);
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 0);
	if (!pte) cprintf("  0x%08x(virt)  not mapped(phys)\n", addr);
	else {
		*pte = (*pte & (~0xfff)) | (perm & 0xfff);
		cprintf("  0x%08x(virt)  0x%08x(phys) PTE_P  %x  PTE_W  %x  PTE_U  %x\n",
			addr, *pte & (~0xfff), *pte & PTE_P, *pte & PTE_W, *pte & PTE_U);
	}
	return 0;
}

/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	// int x = 1, y = 3, z = 4;
	// cprintf("x %d, y %x, z %d\n", x, y, z);

	// unsigned int i = 0x00646c72;
    // cprintf("H%x Wo%s\n", 57616, &i);

	// cprintf("test:[%3d]\n", 32);

	// cprintf("test:[%-3d]\n", 32);

	// cprintf("test:[%5x]\n", 32);

	// cprintf("test:[%-5x]\n", 32);
	
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
