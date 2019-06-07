#include "ns.h"

#define RX_PKT_SIZE (1518)
#define SLEEP (50)

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
	binaryname = "ns_input";

	// LAB 6: Your code here:
	// 	- read a packet from the device driver
	//	- send it to the network server (using ipc_send with NSREQ_INPUT as value)
	//	do the above things in a loop
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
	char buf[RX_PKT_SIZE];
	uint32_t len;
	int r;

	while (true) {
		if ((r = sys_net_recv(buf, &len)) < 0) {
			// sys_yield();
			continue;
		}

		memcpy(nsipcbuf.pkt.jp_data, buf, len);
		nsipcbuf.pkt.jp_len = len;
		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P|PTE_U|PTE_W);
		
		for (int i = 0; i < SLEEP; i++)
			sys_yield();
	}
}
