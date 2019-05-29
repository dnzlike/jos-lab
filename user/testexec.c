#include <inc/lib.h>

void
umain(int argc, char **argv)
{
    int r;
	cprintf("testexec: exec /init\n");
	if ((r = execl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
		panic("testexec: exec /init: %e", r);

    cprintf("testexec: should never print this!\n");
}
