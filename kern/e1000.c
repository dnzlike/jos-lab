#include <kern/e1000.h>
#include <kern/pmap.h>
#include <inc/string.h>
#include <inc/error.h>

#define TX_PKT_SIZE (1518)
#define RX_PKT_SIZE (1518)
#define N_TXDESC (PGSIZE / sizeof(struct tx_desc))
#define N_RXDESC (PGSIZE / sizeof(struct rx_desc))

static struct E1000 *base;

struct tx_desc tx_descs[N_TXDESC];
char tx_buf[N_TXDESC][TX_PKT_SIZE];

int
e1000_tx_init()
{
	// Allocate one page for descriptors

	// Initialize all descriptors

	// Set hardward registers
	// Look kern/e1000.h to find useful definations

	memset(tx_descs, 0, sizeof(tx_descs));
	memset(tx_buf, 0, sizeof(tx_buf));

	for (int i = 0; i < N_TXDESC; i++) {
		tx_descs[i].addr = PADDR(tx_buf[i]);
		// tx_descs[i].cmd = 0;
		tx_descs[i].status = E1000_TX_STATUS_DD;
	}


	base->TDBAL = PADDR(tx_descs);
	base->TDBAH = 0;
	base->TDLEN = sizeof(tx_descs);
	base->TDH = 0;
	base->TDT = 0;
	base->TCTL |= E1000_TCTL_EN;
	base->TCTL |= E1000_TCTL_PSP;
	base->TCTL |= E1000_TCTL_CT_ETHER;
	base->TCTL |= E1000_TCTL_COLD_FULL_DUPLEX;
	// cprintf("TCTL: %d\n", base->TCTL);
	base->TIPG |= E1000_TIPG_DEFAULT;

	return 0;
}

struct rx_desc rx_descs[N_RXDESC];
char rx_buf[N_RXDESC][RX_PKT_SIZE];

int
e1000_rx_init()
{
	// Allocate one page for descriptors

	// Initialize all descriptors
	// You should allocate some pages as receive buffer

	// Set hardward registers
	// Look kern/e1000.h to find useful definations

	memset(rx_descs, 0, sizeof(rx_descs));
	memset(rx_buf, 0, sizeof(rx_buf));

	for (int i = 0; i < N_RXDESC; i++) {
		rx_descs[i].addr = PADDR(rx_buf[i]);
		// rx_descs[i].status = E1000_RX_STATUS_DD;
	}

	base->RAL = QEMU_MAC_LOW;
	base->RAH = QEMU_MAC_HIGH;

	// memset(base->MTA, 0, sizeof(base->MTA));

	base->RDBAL = PADDR(rx_descs);
	base->RDBAH = 0;
	base->RDLEN = sizeof(rx_descs);
	base->RDH = 0;
	base->RDT = N_RXDESC - 1;
	base->RCTL |= E1000_RCTL_EN;
	base->RCTL |= E1000_RCTL_BSIZE_2048;
	base->RCTL |= E1000_RCTL_SECRC;

	return 0;
}

int
pci_e1000_attach(struct pci_func *pcif)
{
	// Enable PCI function
	// Map MMIO region and save the address in 'base;

	pci_func_enable(pcif);
	base = (struct E1000 *)mmio_map_region(pcif->reg_base[0], pcif->reg_size[0]);

	cprintf("E1000 STATUS: 0x%.8x\n", base->STATUS);
	// cprintf("N_TXDESC: %d, N_RXDESC: %d\n", N_TXDESC, N_RXDESC);

	e1000_tx_init();
	e1000_rx_init();
	return 0;
}

int
e1000_tx(const void *buf, uint32_t len)
{
	// Send 'len' bytes in 'buf' to ethernet
	// Hint: buf is a kernel virtual address

	// cprintf("0x%.8x\n", (void *)buf);	

	if (!buf || len > TX_PKT_SIZE) {
		return -E_INVAL;
	}

	uint32_t tail = base->TDT;
	if (!(tx_descs[tail].status & E1000_TX_STATUS_DD)) {
		return -E_AGAIN;
	}

	tx_descs[tail].length = len;
	tx_descs[tail].status &= ~E1000_TX_STATUS_DD;
	tx_descs[tail].cmd |= E1000_TX_CMD_EOP;
	tx_descs[tail].cmd |= E1000_TX_CMD_RS;

	memset(tx_buf[tail], 0, TX_PKT_SIZE);
	memcpy(tx_buf[tail], buf, len);
	base->TDT = (tail + 1) % N_TXDESC;

	// cprintf("TDH: %d, TDT: %d\n", base->TDH, base->TDT);

	return 0;
}

int
e1000_rx(void *buf, uint32_t *len)
{
	// Copy one received buffer to buf
	// You could return -E_AGAIN if there is no packet
	// Check whether the buf is large enough to hold
	// the packet
	// Do not forget to reset the decscriptor and
	// give it back to hardware by modifying RDT

	// if (!buf || len > RX_PKT_SIZE) {
	// 	return -E_INVAL;
	// }

	static uint32_t next = 0;

	// uint32_t head = base->RDH;
	if (!(rx_descs[next].status & E1000_RX_STATUS_DD)) {
		// cprintf("wtf?\n");
		return -E_AGAIN;
	}

	*len = rx_descs[next].length;
	memset(buf, 0, rx_descs[next].length);
	memcpy(buf, rx_buf[next], rx_descs[next].length);

	base->RDT = (base->RDT + 1) % N_RXDESC;
	next = (next + 1) % N_RXDESC;

	return 0;
}
