#include "ns.h"

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
	binaryname = "ns_output";

	// LAB 6: Your code here:
	// 	- read a packet request (using ipc_recv)
	//	- send the packet to the device driver (using sys_net_send)
	//	do the above things in a loop
	envid_t from_env_store;
	int perm;
	int r;

	while (true) {
		r = ipc_recv(&from_env_store, &nsipcbuf, &perm);
		if (r != NSREQ_OUTPUT) {
			continue;
		}
		
		while ((r = sys_net_send(nsipcbuf.pkt.jp_data, nsipcbuf.pkt.jp_len)) < 0) {
			sys_yield();
		}
	}

}
