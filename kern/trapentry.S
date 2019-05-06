/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(H_DIVIDE, T_DIVIDE)
TRAPHANDLER_NOEC(H_DEBUG, T_DEBUG)
TRAPHANDLER_NOEC(H_NMI, T_NMI)
TRAPHANDLER_NOEC(H_BRKPT, T_BRKPT)
TRAPHANDLER_NOEC(H_OFLOW, T_OFLOW)
TRAPHANDLER_NOEC(H_BOUND, T_BOUND)
TRAPHANDLER_NOEC(H_ILLOP, T_ILLOP)
TRAPHANDLER_NOEC(H_DEVICE, T_DEVICE)
TRAPHANDLER(H_DBLFLT, T_DBLFLT)
/* TRAPHANDLER_NOEC(H_COPROC, T_COPROC) */
TRAPHANDLER(H_TSS, T_TSS)
TRAPHANDLER(H_SEGNP, T_SEGNP)
TRAPHANDLER(H_STACK, T_STACK)
TRAPHANDLER(H_GPFLT, T_GPFLT)
TRAPHANDLER(H_PGFLT, T_PGFLT)
/* TRAPHANDLER_NOEC(H_RES, T_RES) */
TRAPHANDLER_NOEC(H_FPERR, T_FPERR)
TRAPHANDLER_NOEC(H_ALIGN, T_ALIGN)
TRAPHANDLER_NOEC(H_MCHK, T_MCHK)
TRAPHANDLER_NOEC(H_SIMDERR, T_SIMDERR)

TRAPHANDLER_NOEC(H_TIMER, IRQ_OFFSET + 0)
TRAPHANDLER_NOEC(H_KBD, IRQ_OFFSET + 1)
TRAPHANDLER_NOEC(H_SERIAL, IRQ_OFFSET + 4)
TRAPHANDLER_NOEC(H_SPURIOUS, IRQ_OFFSET + 7)
TRAPHANDLER_NOEC(H_IDE, IRQ_OFFSET + 14)
TRAPHANDLER_NOEC(H_ERROR, IRQ_OFFSET + 19)

TRAPHANDLER_NOEC(H_SYSCALL, T_SYSCALL)


/*
 * Lab 3: Your code here for _alltraps
 */
.global _alltraps
_alltraps:
	pushl %ds
	pushl %es
	pushal
	movl $GD_KD, %eax
	movw %ax, %ds
	movw %ax, %es
	pushl %esp
	call trap

