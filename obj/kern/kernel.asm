
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 0e 23 f0 00 	cmpl   $0x0,0xf0230e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 0e 23 f0    	mov    %esi,0xf0230e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 a1 60 00 00       	call   f0106102 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 a0 67 10 f0       	push   $0xf01067a0
f010006d:	e8 e3 35 00 00       	call   f0103655 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 b3 35 00 00       	call   f010362f <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 ad 79 10 f0 	movl   $0xf01079ad,(%esp)
f0100083:	e8 cd 35 00 00       	call   f0103655 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 a6 08 00 00       	call   f010093b <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 20 27 f0       	mov    $0xf0272008,%eax
f01000a6:	2d 28 fa 22 f0       	sub    $0xf022fa28,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 28 fa 22 f0       	push   $0xf022fa28
f01000b3:	e8 29 5a 00 00       	call   f0105ae1 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 af 05 00 00       	call   f010066c <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 0c 68 10 f0       	push   $0xf010680c
f01000ca:	e8 86 35 00 00       	call   f0103655 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 e6 11 00 00       	call   f01012ba <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 04 2e 00 00       	call   f0102edd <env_init>
	trap_init();
f01000d9:	e8 6e 36 00 00       	call   f010374c <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 15 5d 00 00       	call   f0105df8 <mp_init>
	lapic_init();
f01000e3:	e8 35 60 00 00       	call   f010611d <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 8f 34 00 00       	call   f010357c <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 17 12 f0 	movl   $0xf01217c0,(%esp)
f01000f4:	e8 77 62 00 00       	call   f0106370 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 0e 23 f0 07 	cmpl   $0x7,0xf0230e88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 c4 67 10 f0       	push   $0xf01067c4
f010010f:	6a 56                	push   $0x56
f0100111:	68 27 68 10 f0       	push   $0xf0106827
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 5e 5d 10 f0       	mov    $0xf0105d5e,%eax
f0100123:	2d e4 5c 10 f0       	sub    $0xf0105ce4,%eax
f0100128:	50                   	push   %eax
f0100129:	68 e4 5c 10 f0       	push   $0xf0105ce4
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 f6 59 00 00       	call   f0105b2e <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 10 23 f0       	mov    $0xf0231020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 bb 5f 00 00       	call   f0106102 <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 10 23 f0       	add    $0xf0231020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 10 23 f0       	sub    $0xf0231020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 a0 23 f0       	add    $0xf023a000,%eax
f010016b:	a3 84 0e 23 f0       	mov    %eax,0xf0230e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 ea 60 00 00       	call   f010626b <lapic_startap>
f0100181:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100184:	8b 43 04             	mov    0x4(%ebx),%eax
f0100187:	83 f8 01             	cmp    $0x1,%eax
f010018a:	75 f8                	jne    f0100184 <i386_init+0xea>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010018c:	83 c3 74             	add    $0x74,%ebx
f010018f:	6b 05 c4 13 23 f0 74 	imul   $0x74,0xf02313c4,%eax
f0100196:	05 20 10 23 f0       	add    $0xf0231020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_primes, ENV_TYPE_USER);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 00                	push   $0x0
f01001a4:	68 fc 5f 22 f0       	push   $0xf0225ffc
f01001a9:	e8 0d 2f 00 00       	call   f01030bb <env_create>
#endif // TEST*
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 00                	push   $0x0
f01001b3:	68 9c 96 19 f0       	push   $0xf019969c
f01001b8:	e8 fe 2e 00 00       	call   f01030bb <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001bd:	83 c4 08             	add    $0x8,%esp
f01001c0:	6a 00                	push   $0x0
f01001c2:	68 9c 96 19 f0       	push   $0xf019969c
f01001c7:	e8 ef 2e 00 00       	call   f01030bb <env_create>
	ENV_CREATE(user_yield, ENV_TYPE_USER);
f01001cc:	83 c4 08             	add    $0x8,%esp
f01001cf:	6a 00                	push   $0x0
f01001d1:	68 9c 96 19 f0       	push   $0xf019969c
f01001d6:	e8 e0 2e 00 00       	call   f01030bb <env_create>
	// Schedule and run the first user environment!
	sched_yield();
f01001db:	e8 22 47 00 00       	call   f0104902 <sched_yield>

f01001e0 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01001e0:	55                   	push   %ebp
f01001e1:	89 e5                	mov    %esp,%ebp
f01001e3:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001e6:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001eb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001f0:	77 12                	ja     f0100204 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001f2:	50                   	push   %eax
f01001f3:	68 e8 67 10 f0       	push   $0xf01067e8
f01001f8:	6a 6d                	push   $0x6d
f01001fa:	68 27 68 10 f0       	push   $0xf0106827
f01001ff:	e8 3c fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0100204:	05 00 00 00 10       	add    $0x10000000,%eax
f0100209:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010020c:	e8 f1 5e 00 00       	call   f0106102 <cpunum>
f0100211:	83 ec 08             	sub    $0x8,%esp
f0100214:	50                   	push   %eax
f0100215:	68 33 68 10 f0       	push   $0xf0106833
f010021a:	e8 36 34 00 00       	call   f0103655 <cprintf>

	lapic_init();
f010021f:	e8 f9 5e 00 00       	call   f010611d <lapic_init>
	env_init_percpu();
f0100224:	e8 84 2c 00 00       	call   f0102ead <env_init_percpu>
	trap_init_percpu();
f0100229:	e8 3b 34 00 00       	call   f0103669 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010022e:	e8 cf 5e 00 00       	call   f0106102 <cpunum>
f0100233:	6b d0 74             	imul   $0x74,%eax,%edx
f0100236:	81 c2 20 10 23 f0    	add    $0xf0231020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010023c:	b8 01 00 00 00       	mov    $0x1,%eax
f0100241:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100245:	c7 04 24 c0 17 12 f0 	movl   $0xf01217c0,(%esp)
f010024c:	e8 1f 61 00 00       	call   f0106370 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100251:	e8 ac 46 00 00       	call   f0104902 <sched_yield>

f0100256 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100256:	55                   	push   %ebp
f0100257:	89 e5                	mov    %esp,%ebp
f0100259:	53                   	push   %ebx
f010025a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010025d:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100260:	ff 75 0c             	pushl  0xc(%ebp)
f0100263:	ff 75 08             	pushl  0x8(%ebp)
f0100266:	68 49 68 10 f0       	push   $0xf0106849
f010026b:	e8 e5 33 00 00       	call   f0103655 <cprintf>
	vcprintf(fmt, ap);
f0100270:	83 c4 08             	add    $0x8,%esp
f0100273:	53                   	push   %ebx
f0100274:	ff 75 10             	pushl  0x10(%ebp)
f0100277:	e8 b3 33 00 00       	call   f010362f <vcprintf>
	cprintf("\n");
f010027c:	c7 04 24 ad 79 10 f0 	movl   $0xf01079ad,(%esp)
f0100283:	e8 cd 33 00 00       	call   f0103655 <cprintf>
	va_end(ap);
}
f0100288:	83 c4 10             	add    $0x10,%esp
f010028b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010028e:	c9                   	leave  
f010028f:	c3                   	ret    

f0100290 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100290:	55                   	push   %ebp
f0100291:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100293:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100298:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100299:	a8 01                	test   $0x1,%al
f010029b:	74 0b                	je     f01002a8 <serial_proc_data+0x18>
f010029d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002a2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002a3:	0f b6 c0             	movzbl %al,%eax
f01002a6:	eb 05                	jmp    f01002ad <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002ad:	5d                   	pop    %ebp
f01002ae:	c3                   	ret    

f01002af <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002af:	55                   	push   %ebp
f01002b0:	89 e5                	mov    %esp,%ebp
f01002b2:	53                   	push   %ebx
f01002b3:	83 ec 04             	sub    $0x4,%esp
f01002b6:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002b8:	eb 2b                	jmp    f01002e5 <cons_intr+0x36>
		if (c == 0)
f01002ba:	85 c0                	test   %eax,%eax
f01002bc:	74 27                	je     f01002e5 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002be:	8b 0d 24 02 23 f0    	mov    0xf0230224,%ecx
f01002c4:	8d 51 01             	lea    0x1(%ecx),%edx
f01002c7:	89 15 24 02 23 f0    	mov    %edx,0xf0230224
f01002cd:	88 81 20 00 23 f0    	mov    %al,-0xfdcffe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002d3:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002d9:	75 0a                	jne    f01002e5 <cons_intr+0x36>
			cons.wpos = 0;
f01002db:	c7 05 24 02 23 f0 00 	movl   $0x0,0xf0230224
f01002e2:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002e5:	ff d3                	call   *%ebx
f01002e7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002ea:	75 ce                	jne    f01002ba <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002ec:	83 c4 04             	add    $0x4,%esp
f01002ef:	5b                   	pop    %ebx
f01002f0:	5d                   	pop    %ebp
f01002f1:	c3                   	ret    

f01002f2 <kbd_proc_data>:
f01002f2:	ba 64 00 00 00       	mov    $0x64,%edx
f01002f7:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002f8:	a8 01                	test   $0x1,%al
f01002fa:	0f 84 f8 00 00 00    	je     f01003f8 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f0100300:	a8 20                	test   $0x20,%al
f0100302:	0f 85 f6 00 00 00    	jne    f01003fe <kbd_proc_data+0x10c>
f0100308:	ba 60 00 00 00       	mov    $0x60,%edx
f010030d:	ec                   	in     (%dx),%al
f010030e:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100310:	3c e0                	cmp    $0xe0,%al
f0100312:	75 0d                	jne    f0100321 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100314:	83 0d 00 00 23 f0 40 	orl    $0x40,0xf0230000
		return 0;
f010031b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100320:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100321:	55                   	push   %ebp
f0100322:	89 e5                	mov    %esp,%ebp
f0100324:	53                   	push   %ebx
f0100325:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100328:	84 c0                	test   %al,%al
f010032a:	79 36                	jns    f0100362 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010032c:	8b 0d 00 00 23 f0    	mov    0xf0230000,%ecx
f0100332:	89 cb                	mov    %ecx,%ebx
f0100334:	83 e3 40             	and    $0x40,%ebx
f0100337:	83 e0 7f             	and    $0x7f,%eax
f010033a:	85 db                	test   %ebx,%ebx
f010033c:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010033f:	0f b6 d2             	movzbl %dl,%edx
f0100342:	0f b6 82 c0 69 10 f0 	movzbl -0xfef9640(%edx),%eax
f0100349:	83 c8 40             	or     $0x40,%eax
f010034c:	0f b6 c0             	movzbl %al,%eax
f010034f:	f7 d0                	not    %eax
f0100351:	21 c8                	and    %ecx,%eax
f0100353:	a3 00 00 23 f0       	mov    %eax,0xf0230000
		return 0;
f0100358:	b8 00 00 00 00       	mov    $0x0,%eax
f010035d:	e9 a4 00 00 00       	jmp    f0100406 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100362:	8b 0d 00 00 23 f0    	mov    0xf0230000,%ecx
f0100368:	f6 c1 40             	test   $0x40,%cl
f010036b:	74 0e                	je     f010037b <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010036d:	83 c8 80             	or     $0xffffff80,%eax
f0100370:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100372:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100375:	89 0d 00 00 23 f0    	mov    %ecx,0xf0230000
	}

	shift |= shiftcode[data];
f010037b:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010037e:	0f b6 82 c0 69 10 f0 	movzbl -0xfef9640(%edx),%eax
f0100385:	0b 05 00 00 23 f0    	or     0xf0230000,%eax
f010038b:	0f b6 8a c0 68 10 f0 	movzbl -0xfef9740(%edx),%ecx
f0100392:	31 c8                	xor    %ecx,%eax
f0100394:	a3 00 00 23 f0       	mov    %eax,0xf0230000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100399:	89 c1                	mov    %eax,%ecx
f010039b:	83 e1 03             	and    $0x3,%ecx
f010039e:	8b 0c 8d a0 68 10 f0 	mov    -0xfef9760(,%ecx,4),%ecx
f01003a5:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01003a9:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01003ac:	a8 08                	test   $0x8,%al
f01003ae:	74 1b                	je     f01003cb <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f01003b0:	89 da                	mov    %ebx,%edx
f01003b2:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01003b5:	83 f9 19             	cmp    $0x19,%ecx
f01003b8:	77 05                	ja     f01003bf <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01003ba:	83 eb 20             	sub    $0x20,%ebx
f01003bd:	eb 0c                	jmp    f01003cb <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01003bf:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003c2:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003c5:	83 fa 19             	cmp    $0x19,%edx
f01003c8:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003cb:	f7 d0                	not    %eax
f01003cd:	a8 06                	test   $0x6,%al
f01003cf:	75 33                	jne    f0100404 <kbd_proc_data+0x112>
f01003d1:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003d7:	75 2b                	jne    f0100404 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003d9:	83 ec 0c             	sub    $0xc,%esp
f01003dc:	68 63 68 10 f0       	push   $0xf0106863
f01003e1:	e8 6f 32 00 00       	call   f0103655 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003e6:	ba 92 00 00 00       	mov    $0x92,%edx
f01003eb:	b8 03 00 00 00       	mov    $0x3,%eax
f01003f0:	ee                   	out    %al,(%dx)
f01003f1:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003f4:	89 d8                	mov    %ebx,%eax
f01003f6:	eb 0e                	jmp    f0100406 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003fd:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100403:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100404:	89 d8                	mov    %ebx,%eax
}
f0100406:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100409:	c9                   	leave  
f010040a:	c3                   	ret    

f010040b <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010040b:	55                   	push   %ebp
f010040c:	89 e5                	mov    %esp,%ebp
f010040e:	57                   	push   %edi
f010040f:	56                   	push   %esi
f0100410:	53                   	push   %ebx
f0100411:	83 ec 1c             	sub    $0x1c,%esp
f0100414:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100416:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010041b:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100420:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100425:	eb 09                	jmp    f0100430 <cons_putc+0x25>
f0100427:	89 ca                	mov    %ecx,%edx
f0100429:	ec                   	in     (%dx),%al
f010042a:	ec                   	in     (%dx),%al
f010042b:	ec                   	in     (%dx),%al
f010042c:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f010042d:	83 c3 01             	add    $0x1,%ebx
f0100430:	89 f2                	mov    %esi,%edx
f0100432:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100433:	a8 20                	test   $0x20,%al
f0100435:	75 08                	jne    f010043f <cons_putc+0x34>
f0100437:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010043d:	7e e8                	jle    f0100427 <cons_putc+0x1c>
f010043f:	89 f8                	mov    %edi,%eax
f0100441:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100444:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100449:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010044a:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010044f:	be 79 03 00 00       	mov    $0x379,%esi
f0100454:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100459:	eb 09                	jmp    f0100464 <cons_putc+0x59>
f010045b:	89 ca                	mov    %ecx,%edx
f010045d:	ec                   	in     (%dx),%al
f010045e:	ec                   	in     (%dx),%al
f010045f:	ec                   	in     (%dx),%al
f0100460:	ec                   	in     (%dx),%al
f0100461:	83 c3 01             	add    $0x1,%ebx
f0100464:	89 f2                	mov    %esi,%edx
f0100466:	ec                   	in     (%dx),%al
f0100467:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010046d:	7f 04                	jg     f0100473 <cons_putc+0x68>
f010046f:	84 c0                	test   %al,%al
f0100471:	79 e8                	jns    f010045b <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100473:	ba 78 03 00 00       	mov    $0x378,%edx
f0100478:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010047c:	ee                   	out    %al,(%dx)
f010047d:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100482:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100487:	ee                   	out    %al,(%dx)
f0100488:	b8 08 00 00 00       	mov    $0x8,%eax
f010048d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010048e:	89 fa                	mov    %edi,%edx
f0100490:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100496:	89 f8                	mov    %edi,%eax
f0100498:	80 cc 07             	or     $0x7,%ah
f010049b:	85 d2                	test   %edx,%edx
f010049d:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01004a0:	89 f8                	mov    %edi,%eax
f01004a2:	0f b6 c0             	movzbl %al,%eax
f01004a5:	83 f8 09             	cmp    $0x9,%eax
f01004a8:	74 74                	je     f010051e <cons_putc+0x113>
f01004aa:	83 f8 09             	cmp    $0x9,%eax
f01004ad:	7f 0a                	jg     f01004b9 <cons_putc+0xae>
f01004af:	83 f8 08             	cmp    $0x8,%eax
f01004b2:	74 14                	je     f01004c8 <cons_putc+0xbd>
f01004b4:	e9 99 00 00 00       	jmp    f0100552 <cons_putc+0x147>
f01004b9:	83 f8 0a             	cmp    $0xa,%eax
f01004bc:	74 3a                	je     f01004f8 <cons_putc+0xed>
f01004be:	83 f8 0d             	cmp    $0xd,%eax
f01004c1:	74 3d                	je     f0100500 <cons_putc+0xf5>
f01004c3:	e9 8a 00 00 00       	jmp    f0100552 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004c8:	0f b7 05 28 02 23 f0 	movzwl 0xf0230228,%eax
f01004cf:	66 85 c0             	test   %ax,%ax
f01004d2:	0f 84 e6 00 00 00    	je     f01005be <cons_putc+0x1b3>
			crt_pos--;
f01004d8:	83 e8 01             	sub    $0x1,%eax
f01004db:	66 a3 28 02 23 f0    	mov    %ax,0xf0230228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004e1:	0f b7 c0             	movzwl %ax,%eax
f01004e4:	66 81 e7 00 ff       	and    $0xff00,%di
f01004e9:	83 cf 20             	or     $0x20,%edi
f01004ec:	8b 15 2c 02 23 f0    	mov    0xf023022c,%edx
f01004f2:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004f6:	eb 78                	jmp    f0100570 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004f8:	66 83 05 28 02 23 f0 	addw   $0x50,0xf0230228
f01004ff:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100500:	0f b7 05 28 02 23 f0 	movzwl 0xf0230228,%eax
f0100507:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010050d:	c1 e8 16             	shr    $0x16,%eax
f0100510:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100513:	c1 e0 04             	shl    $0x4,%eax
f0100516:	66 a3 28 02 23 f0    	mov    %ax,0xf0230228
f010051c:	eb 52                	jmp    f0100570 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f010051e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100523:	e8 e3 fe ff ff       	call   f010040b <cons_putc>
		cons_putc(' ');
f0100528:	b8 20 00 00 00       	mov    $0x20,%eax
f010052d:	e8 d9 fe ff ff       	call   f010040b <cons_putc>
		cons_putc(' ');
f0100532:	b8 20 00 00 00       	mov    $0x20,%eax
f0100537:	e8 cf fe ff ff       	call   f010040b <cons_putc>
		cons_putc(' ');
f010053c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100541:	e8 c5 fe ff ff       	call   f010040b <cons_putc>
		cons_putc(' ');
f0100546:	b8 20 00 00 00       	mov    $0x20,%eax
f010054b:	e8 bb fe ff ff       	call   f010040b <cons_putc>
f0100550:	eb 1e                	jmp    f0100570 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100552:	0f b7 05 28 02 23 f0 	movzwl 0xf0230228,%eax
f0100559:	8d 50 01             	lea    0x1(%eax),%edx
f010055c:	66 89 15 28 02 23 f0 	mov    %dx,0xf0230228
f0100563:	0f b7 c0             	movzwl %ax,%eax
f0100566:	8b 15 2c 02 23 f0    	mov    0xf023022c,%edx
f010056c:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100570:	66 81 3d 28 02 23 f0 	cmpw   $0x7cf,0xf0230228
f0100577:	cf 07 
f0100579:	76 43                	jbe    f01005be <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010057b:	a1 2c 02 23 f0       	mov    0xf023022c,%eax
f0100580:	83 ec 04             	sub    $0x4,%esp
f0100583:	68 00 0f 00 00       	push   $0xf00
f0100588:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010058e:	52                   	push   %edx
f010058f:	50                   	push   %eax
f0100590:	e8 99 55 00 00       	call   f0105b2e <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100595:	8b 15 2c 02 23 f0    	mov    0xf023022c,%edx
f010059b:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005a1:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005a7:	83 c4 10             	add    $0x10,%esp
f01005aa:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005af:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005b2:	39 d0                	cmp    %edx,%eax
f01005b4:	75 f4                	jne    f01005aa <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005b6:	66 83 2d 28 02 23 f0 	subw   $0x50,0xf0230228
f01005bd:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005be:	8b 0d 30 02 23 f0    	mov    0xf0230230,%ecx
f01005c4:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005c9:	89 ca                	mov    %ecx,%edx
f01005cb:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005cc:	0f b7 1d 28 02 23 f0 	movzwl 0xf0230228,%ebx
f01005d3:	8d 71 01             	lea    0x1(%ecx),%esi
f01005d6:	89 d8                	mov    %ebx,%eax
f01005d8:	66 c1 e8 08          	shr    $0x8,%ax
f01005dc:	89 f2                	mov    %esi,%edx
f01005de:	ee                   	out    %al,(%dx)
f01005df:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005e4:	89 ca                	mov    %ecx,%edx
f01005e6:	ee                   	out    %al,(%dx)
f01005e7:	89 d8                	mov    %ebx,%eax
f01005e9:	89 f2                	mov    %esi,%edx
f01005eb:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005ef:	5b                   	pop    %ebx
f01005f0:	5e                   	pop    %esi
f01005f1:	5f                   	pop    %edi
f01005f2:	5d                   	pop    %ebp
f01005f3:	c3                   	ret    

f01005f4 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005f4:	80 3d 34 02 23 f0 00 	cmpb   $0x0,0xf0230234
f01005fb:	74 11                	je     f010060e <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005fd:	55                   	push   %ebp
f01005fe:	89 e5                	mov    %esp,%ebp
f0100600:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100603:	b8 90 02 10 f0       	mov    $0xf0100290,%eax
f0100608:	e8 a2 fc ff ff       	call   f01002af <cons_intr>
}
f010060d:	c9                   	leave  
f010060e:	f3 c3                	repz ret 

f0100610 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100616:	b8 f2 02 10 f0       	mov    $0xf01002f2,%eax
f010061b:	e8 8f fc ff ff       	call   f01002af <cons_intr>
}
f0100620:	c9                   	leave  
f0100621:	c3                   	ret    

f0100622 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100622:	55                   	push   %ebp
f0100623:	89 e5                	mov    %esp,%ebp
f0100625:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100628:	e8 c7 ff ff ff       	call   f01005f4 <serial_intr>
	kbd_intr();
f010062d:	e8 de ff ff ff       	call   f0100610 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100632:	a1 20 02 23 f0       	mov    0xf0230220,%eax
f0100637:	3b 05 24 02 23 f0    	cmp    0xf0230224,%eax
f010063d:	74 26                	je     f0100665 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f010063f:	8d 50 01             	lea    0x1(%eax),%edx
f0100642:	89 15 20 02 23 f0    	mov    %edx,0xf0230220
f0100648:	0f b6 88 20 00 23 f0 	movzbl -0xfdcffe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f010064f:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100651:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100657:	75 11                	jne    f010066a <cons_getc+0x48>
			cons.rpos = 0;
f0100659:	c7 05 20 02 23 f0 00 	movl   $0x0,0xf0230220
f0100660:	00 00 00 
f0100663:	eb 05                	jmp    f010066a <cons_getc+0x48>
		return c;
	}
	return 0;
f0100665:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010066a:	c9                   	leave  
f010066b:	c3                   	ret    

f010066c <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010066c:	55                   	push   %ebp
f010066d:	89 e5                	mov    %esp,%ebp
f010066f:	57                   	push   %edi
f0100670:	56                   	push   %esi
f0100671:	53                   	push   %ebx
f0100672:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100675:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010067c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100683:	5a a5 
	if (*cp != 0xA55A) {
f0100685:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010068c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100690:	74 11                	je     f01006a3 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100692:	c7 05 30 02 23 f0 b4 	movl   $0x3b4,0xf0230230
f0100699:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010069c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006a1:	eb 16                	jmp    f01006b9 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006a3:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006aa:	c7 05 30 02 23 f0 d4 	movl   $0x3d4,0xf0230230
f01006b1:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006b4:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006b9:	8b 3d 30 02 23 f0    	mov    0xf0230230,%edi
f01006bf:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006c4:	89 fa                	mov    %edi,%edx
f01006c6:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006c7:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ca:	89 da                	mov    %ebx,%edx
f01006cc:	ec                   	in     (%dx),%al
f01006cd:	0f b6 c8             	movzbl %al,%ecx
f01006d0:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006d8:	89 fa                	mov    %edi,%edx
f01006da:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006db:	89 da                	mov    %ebx,%edx
f01006dd:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006de:	89 35 2c 02 23 f0    	mov    %esi,0xf023022c
	crt_pos = pos;
f01006e4:	0f b6 c0             	movzbl %al,%eax
f01006e7:	09 c8                	or     %ecx,%eax
f01006e9:	66 a3 28 02 23 f0    	mov    %ax,0xf0230228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006ef:	e8 1c ff ff ff       	call   f0100610 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006f4:	83 ec 0c             	sub    $0xc,%esp
f01006f7:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f01006fe:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100703:	50                   	push   %eax
f0100704:	e8 fb 2d 00 00       	call   f0103504 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100709:	be fa 03 00 00       	mov    $0x3fa,%esi
f010070e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100713:	89 f2                	mov    %esi,%edx
f0100715:	ee                   	out    %al,(%dx)
f0100716:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010071b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100720:	ee                   	out    %al,(%dx)
f0100721:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100726:	b8 0c 00 00 00       	mov    $0xc,%eax
f010072b:	89 da                	mov    %ebx,%edx
f010072d:	ee                   	out    %al,(%dx)
f010072e:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100733:	b8 00 00 00 00       	mov    $0x0,%eax
f0100738:	ee                   	out    %al,(%dx)
f0100739:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010073e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100743:	ee                   	out    %al,(%dx)
f0100744:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100749:	b8 00 00 00 00       	mov    $0x0,%eax
f010074e:	ee                   	out    %al,(%dx)
f010074f:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100754:	b8 01 00 00 00       	mov    $0x1,%eax
f0100759:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010075a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010075f:	ec                   	in     (%dx),%al
f0100760:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100762:	83 c4 10             	add    $0x10,%esp
f0100765:	3c ff                	cmp    $0xff,%al
f0100767:	0f 95 05 34 02 23 f0 	setne  0xf0230234
f010076e:	89 f2                	mov    %esi,%edx
f0100770:	ec                   	in     (%dx),%al
f0100771:	89 da                	mov    %ebx,%edx
f0100773:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100774:	80 f9 ff             	cmp    $0xff,%cl
f0100777:	75 10                	jne    f0100789 <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f0100779:	83 ec 0c             	sub    $0xc,%esp
f010077c:	68 6f 68 10 f0       	push   $0xf010686f
f0100781:	e8 cf 2e 00 00       	call   f0103655 <cprintf>
f0100786:	83 c4 10             	add    $0x10,%esp
}
f0100789:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010078c:	5b                   	pop    %ebx
f010078d:	5e                   	pop    %esi
f010078e:	5f                   	pop    %edi
f010078f:	5d                   	pop    %ebp
f0100790:	c3                   	ret    

f0100791 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100791:	55                   	push   %ebp
f0100792:	89 e5                	mov    %esp,%ebp
f0100794:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100797:	8b 45 08             	mov    0x8(%ebp),%eax
f010079a:	e8 6c fc ff ff       	call   f010040b <cons_putc>
}
f010079f:	c9                   	leave  
f01007a0:	c3                   	ret    

f01007a1 <getchar>:

int
getchar(void)
{
f01007a1:	55                   	push   %ebp
f01007a2:	89 e5                	mov    %esp,%ebp
f01007a4:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007a7:	e8 76 fe ff ff       	call   f0100622 <cons_getc>
f01007ac:	85 c0                	test   %eax,%eax
f01007ae:	74 f7                	je     f01007a7 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007b0:	c9                   	leave  
f01007b1:	c3                   	ret    

f01007b2 <iscons>:

int
iscons(int fdnum)
{
f01007b2:	55                   	push   %ebp
f01007b3:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007b5:	b8 01 00 00 00       	mov    $0x1,%eax
f01007ba:	5d                   	pop    %ebp
f01007bb:	c3                   	ret    

f01007bc <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007bc:	55                   	push   %ebp
f01007bd:	89 e5                	mov    %esp,%ebp
f01007bf:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007c2:	68 c0 6a 10 f0       	push   $0xf0106ac0
f01007c7:	68 de 6a 10 f0       	push   $0xf0106ade
f01007cc:	68 e3 6a 10 f0       	push   $0xf0106ae3
f01007d1:	e8 7f 2e 00 00       	call   f0103655 <cprintf>
f01007d6:	83 c4 0c             	add    $0xc,%esp
f01007d9:	68 6c 6b 10 f0       	push   $0xf0106b6c
f01007de:	68 ec 6a 10 f0       	push   $0xf0106aec
f01007e3:	68 e3 6a 10 f0       	push   $0xf0106ae3
f01007e8:	e8 68 2e 00 00       	call   f0103655 <cprintf>
f01007ed:	83 c4 0c             	add    $0xc,%esp
f01007f0:	68 98 6b 10 f0       	push   $0xf0106b98
f01007f5:	68 f6 6a 10 f0       	push   $0xf0106af6
f01007fa:	68 e3 6a 10 f0       	push   $0xf0106ae3
f01007ff:	e8 51 2e 00 00       	call   f0103655 <cprintf>
	return 0;
}
f0100804:	b8 00 00 00 00       	mov    $0x0,%eax
f0100809:	c9                   	leave  
f010080a:	c3                   	ret    

f010080b <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f010080b:	55                   	push   %ebp
f010080c:	89 e5                	mov    %esp,%ebp
f010080e:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100811:	68 ff 6a 10 f0       	push   $0xf0106aff
f0100816:	e8 3a 2e 00 00       	call   f0103655 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010081b:	83 c4 08             	add    $0x8,%esp
f010081e:	68 0c 00 10 00       	push   $0x10000c
f0100823:	68 c0 6b 10 f0       	push   $0xf0106bc0
f0100828:	e8 28 2e 00 00       	call   f0103655 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010082d:	83 c4 0c             	add    $0xc,%esp
f0100830:	68 0c 00 10 00       	push   $0x10000c
f0100835:	68 0c 00 10 f0       	push   $0xf010000c
f010083a:	68 e8 6b 10 f0       	push   $0xf0106be8
f010083f:	e8 11 2e 00 00       	call   f0103655 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100844:	83 c4 0c             	add    $0xc,%esp
f0100847:	68 81 67 10 00       	push   $0x106781
f010084c:	68 81 67 10 f0       	push   $0xf0106781
f0100851:	68 0c 6c 10 f0       	push   $0xf0106c0c
f0100856:	e8 fa 2d 00 00       	call   f0103655 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010085b:	83 c4 0c             	add    $0xc,%esp
f010085e:	68 28 fa 22 00       	push   $0x22fa28
f0100863:	68 28 fa 22 f0       	push   $0xf022fa28
f0100868:	68 30 6c 10 f0       	push   $0xf0106c30
f010086d:	e8 e3 2d 00 00       	call   f0103655 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100872:	83 c4 0c             	add    $0xc,%esp
f0100875:	68 08 20 27 00       	push   $0x272008
f010087a:	68 08 20 27 f0       	push   $0xf0272008
f010087f:	68 54 6c 10 f0       	push   $0xf0106c54
f0100884:	e8 cc 2d 00 00       	call   f0103655 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100889:	b8 07 24 27 f0       	mov    $0xf0272407,%eax
f010088e:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100893:	83 c4 08             	add    $0x8,%esp
f0100896:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010089b:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01008a1:	85 c0                	test   %eax,%eax
f01008a3:	0f 48 c2             	cmovs  %edx,%eax
f01008a6:	c1 f8 0a             	sar    $0xa,%eax
f01008a9:	50                   	push   %eax
f01008aa:	68 78 6c 10 f0       	push   $0xf0106c78
f01008af:	e8 a1 2d 00 00       	call   f0103655 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b9:	c9                   	leave  
f01008ba:	c3                   	ret    

f01008bb <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008bb:	55                   	push   %ebp
f01008bc:	89 e5                	mov    %esp,%ebp
f01008be:	56                   	push   %esi
f01008bf:	53                   	push   %ebx
f01008c0:	83 ec 20             	sub    $0x20,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008c3:	89 eb                	mov    %ebp,%ebx
	uint32_t ebp = read_ebp();
	uint32_t *arg = (uint32_t *)ebp;
	struct Eipdebuginfo info;

	do {
		debuginfo_eip(arg[1], &info);
f01008c5:	8d 75 e0             	lea    -0x20(%ebp),%esi
f01008c8:	83 ec 08             	sub    $0x8,%esp
f01008cb:	56                   	push   %esi
f01008cc:	ff 73 04             	pushl  0x4(%ebx)
f01008cf:	e8 2d 47 00 00       	call   f0105001 <debuginfo_eip>
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",
f01008d4:	ff 73 18             	pushl  0x18(%ebx)
f01008d7:	ff 73 14             	pushl  0x14(%ebx)
f01008da:	ff 73 10             	pushl  0x10(%ebx)
f01008dd:	ff 73 0c             	pushl  0xc(%ebx)
f01008e0:	ff 73 08             	pushl  0x8(%ebx)
f01008e3:	ff 73 04             	pushl  0x4(%ebx)
f01008e6:	ff 33                	pushl  (%ebx)
f01008e8:	68 a4 6c 10 f0       	push   $0xf0106ca4
f01008ed:	e8 63 2d 00 00       	call   f0103655 <cprintf>
				arg[0], arg[1], arg[2], arg[3], arg[4], arg[5], arg[6]);
		cprintf("\tfile %s:", info.eip_file);
f01008f2:	83 c4 28             	add    $0x28,%esp
f01008f5:	ff 75 e0             	pushl  -0x20(%ebp)
f01008f8:	68 18 6b 10 f0       	push   $0xf0106b18
f01008fd:	e8 53 2d 00 00       	call   f0103655 <cprintf>
		cprintf("%d:", info.eip_line);
f0100902:	83 c4 08             	add    $0x8,%esp
f0100905:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100908:	68 22 6b 10 f0       	push   $0xf0106b22
f010090d:	e8 43 2d 00 00       	call   f0103655 <cprintf>
		cprintf(" %.*s\n", info.eip_fn_namelen, info.eip_fn_name);
f0100912:	83 c4 0c             	add    $0xc,%esp
f0100915:	ff 75 e8             	pushl  -0x18(%ebp)
f0100918:	ff 75 ec             	pushl  -0x14(%ebp)
f010091b:	68 26 6b 10 f0       	push   $0xf0106b26
f0100920:	e8 30 2d 00 00       	call   f0103655 <cprintf>
		arg = (uint32_t *)arg[0];
f0100925:	8b 1b                	mov    (%ebx),%ebx
	}while(arg[0] != 0);
f0100927:	83 c4 10             	add    $0x10,%esp
f010092a:	83 3b 00             	cmpl   $0x0,(%ebx)
f010092d:	75 99                	jne    f01008c8 <mon_backtrace+0xd>
	return 0;
}
f010092f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100934:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100937:	5b                   	pop    %ebx
f0100938:	5e                   	pop    %esi
f0100939:	5d                   	pop    %ebp
f010093a:	c3                   	ret    

f010093b <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010093b:	55                   	push   %ebp
f010093c:	89 e5                	mov    %esp,%ebp
f010093e:	57                   	push   %edi
f010093f:	56                   	push   %esi
f0100940:	53                   	push   %ebx
f0100941:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100944:	68 d8 6c 10 f0       	push   $0xf0106cd8
f0100949:	e8 07 2d 00 00       	call   f0103655 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010094e:	c7 04 24 fc 6c 10 f0 	movl   $0xf0106cfc,(%esp)
f0100955:	e8 fb 2c 00 00       	call   f0103655 <cprintf>

	if (tf != NULL)
f010095a:	83 c4 10             	add    $0x10,%esp
f010095d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100961:	74 0e                	je     f0100971 <monitor+0x36>
		print_trapframe(tf);
f0100963:	83 ec 0c             	sub    $0xc,%esp
f0100966:	ff 75 08             	pushl  0x8(%ebp)
f0100969:	e8 12 2f 00 00       	call   f0103880 <print_trapframe>
f010096e:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100971:	83 ec 0c             	sub    $0xc,%esp
f0100974:	68 2d 6b 10 f0       	push   $0xf0106b2d
f0100979:	e8 0c 4f 00 00       	call   f010588a <readline>
f010097e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100980:	83 c4 10             	add    $0x10,%esp
f0100983:	85 c0                	test   %eax,%eax
f0100985:	74 ea                	je     f0100971 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100987:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010098e:	be 00 00 00 00       	mov    $0x0,%esi
f0100993:	eb 0a                	jmp    f010099f <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100995:	c6 03 00             	movb   $0x0,(%ebx)
f0100998:	89 f7                	mov    %esi,%edi
f010099a:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010099d:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010099f:	0f b6 03             	movzbl (%ebx),%eax
f01009a2:	84 c0                	test   %al,%al
f01009a4:	74 63                	je     f0100a09 <monitor+0xce>
f01009a6:	83 ec 08             	sub    $0x8,%esp
f01009a9:	0f be c0             	movsbl %al,%eax
f01009ac:	50                   	push   %eax
f01009ad:	68 31 6b 10 f0       	push   $0xf0106b31
f01009b2:	e8 ed 50 00 00       	call   f0105aa4 <strchr>
f01009b7:	83 c4 10             	add    $0x10,%esp
f01009ba:	85 c0                	test   %eax,%eax
f01009bc:	75 d7                	jne    f0100995 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009be:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009c1:	74 46                	je     f0100a09 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009c3:	83 fe 0f             	cmp    $0xf,%esi
f01009c6:	75 14                	jne    f01009dc <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009c8:	83 ec 08             	sub    $0x8,%esp
f01009cb:	6a 10                	push   $0x10
f01009cd:	68 36 6b 10 f0       	push   $0xf0106b36
f01009d2:	e8 7e 2c 00 00       	call   f0103655 <cprintf>
f01009d7:	83 c4 10             	add    $0x10,%esp
f01009da:	eb 95                	jmp    f0100971 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01009dc:	8d 7e 01             	lea    0x1(%esi),%edi
f01009df:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009e3:	eb 03                	jmp    f01009e8 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009e5:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009e8:	0f b6 03             	movzbl (%ebx),%eax
f01009eb:	84 c0                	test   %al,%al
f01009ed:	74 ae                	je     f010099d <monitor+0x62>
f01009ef:	83 ec 08             	sub    $0x8,%esp
f01009f2:	0f be c0             	movsbl %al,%eax
f01009f5:	50                   	push   %eax
f01009f6:	68 31 6b 10 f0       	push   $0xf0106b31
f01009fb:	e8 a4 50 00 00       	call   f0105aa4 <strchr>
f0100a00:	83 c4 10             	add    $0x10,%esp
f0100a03:	85 c0                	test   %eax,%eax
f0100a05:	74 de                	je     f01009e5 <monitor+0xaa>
f0100a07:	eb 94                	jmp    f010099d <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100a09:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a10:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100a11:	85 f6                	test   %esi,%esi
f0100a13:	0f 84 58 ff ff ff    	je     f0100971 <monitor+0x36>
f0100a19:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a1e:	83 ec 08             	sub    $0x8,%esp
f0100a21:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a24:	ff 34 85 40 6d 10 f0 	pushl  -0xfef92c0(,%eax,4)
f0100a2b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a2e:	e8 13 50 00 00       	call   f0105a46 <strcmp>
f0100a33:	83 c4 10             	add    $0x10,%esp
f0100a36:	85 c0                	test   %eax,%eax
f0100a38:	75 21                	jne    f0100a5b <monitor+0x120>
			return commands[i].func(argc, argv, tf);
f0100a3a:	83 ec 04             	sub    $0x4,%esp
f0100a3d:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a40:	ff 75 08             	pushl  0x8(%ebp)
f0100a43:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a46:	52                   	push   %edx
f0100a47:	56                   	push   %esi
f0100a48:	ff 14 85 48 6d 10 f0 	call   *-0xfef92b8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a4f:	83 c4 10             	add    $0x10,%esp
f0100a52:	85 c0                	test   %eax,%eax
f0100a54:	78 25                	js     f0100a7b <monitor+0x140>
f0100a56:	e9 16 ff ff ff       	jmp    f0100971 <monitor+0x36>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a5b:	83 c3 01             	add    $0x1,%ebx
f0100a5e:	83 fb 03             	cmp    $0x3,%ebx
f0100a61:	75 bb                	jne    f0100a1e <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a63:	83 ec 08             	sub    $0x8,%esp
f0100a66:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a69:	68 53 6b 10 f0       	push   $0xf0106b53
f0100a6e:	e8 e2 2b 00 00       	call   f0103655 <cprintf>
f0100a73:	83 c4 10             	add    $0x10,%esp
f0100a76:	e9 f6 fe ff ff       	jmp    f0100971 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a7e:	5b                   	pop    %ebx
f0100a7f:	5e                   	pop    %esi
f0100a80:	5f                   	pop    %edi
f0100a81:	5d                   	pop    %ebp
f0100a82:	c3                   	ret    

f0100a83 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a83:	55                   	push   %ebp
f0100a84:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a86:	83 3d 38 02 23 f0 00 	cmpl   $0x0,0xf0230238
f0100a8d:	75 11                	jne    f0100aa0 <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a8f:	ba 07 30 27 f0       	mov    $0xf0273007,%edx
f0100a94:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a9a:	89 15 38 02 23 f0    	mov    %edx,0xf0230238
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100aa0:	8b 15 38 02 23 f0    	mov    0xf0230238,%edx
	if (n != 0) {
f0100aa6:	85 c0                	test   %eax,%eax
f0100aa8:	74 11                	je     f0100abb <boot_alloc+0x38>
		nextfree = ROUNDUP(nextfree + n, PGSIZE);
f0100aaa:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100ab1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ab6:	a3 38 02 23 f0       	mov    %eax,0xf0230238
	}
	return result;

	return NULL;
}
f0100abb:	89 d0                	mov    %edx,%eax
f0100abd:	5d                   	pop    %ebp
f0100abe:	c3                   	ret    

f0100abf <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100abf:	55                   	push   %ebp
f0100ac0:	89 e5                	mov    %esp,%ebp
f0100ac2:	56                   	push   %esi
f0100ac3:	53                   	push   %ebx
f0100ac4:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ac6:	83 ec 0c             	sub    $0xc,%esp
f0100ac9:	50                   	push   %eax
f0100aca:	e8 07 2a 00 00       	call   f01034d6 <mc146818_read>
f0100acf:	89 c6                	mov    %eax,%esi
f0100ad1:	83 c3 01             	add    $0x1,%ebx
f0100ad4:	89 1c 24             	mov    %ebx,(%esp)
f0100ad7:	e8 fa 29 00 00       	call   f01034d6 <mc146818_read>
f0100adc:	c1 e0 08             	shl    $0x8,%eax
f0100adf:	09 f0                	or     %esi,%eax
}
f0100ae1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ae4:	5b                   	pop    %ebx
f0100ae5:	5e                   	pop    %esi
f0100ae6:	5d                   	pop    %ebp
f0100ae7:	c3                   	ret    

f0100ae8 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100ae8:	89 d1                	mov    %edx,%ecx
f0100aea:	c1 e9 16             	shr    $0x16,%ecx
f0100aed:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100af0:	a8 01                	test   $0x1,%al
f0100af2:	74 52                	je     f0100b46 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100af4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100af9:	89 c1                	mov    %eax,%ecx
f0100afb:	c1 e9 0c             	shr    $0xc,%ecx
f0100afe:	3b 0d 88 0e 23 f0    	cmp    0xf0230e88,%ecx
f0100b04:	72 1b                	jb     f0100b21 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b06:	55                   	push   %ebp
f0100b07:	89 e5                	mov    %esp,%ebp
f0100b09:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b0c:	50                   	push   %eax
f0100b0d:	68 c4 67 10 f0       	push   $0xf01067c4
f0100b12:	68 6c 03 00 00       	push   $0x36c
f0100b17:	68 cd 76 10 f0       	push   $0xf01076cd
f0100b1c:	e8 1f f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b21:	c1 ea 0c             	shr    $0xc,%edx
f0100b24:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b2a:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b31:	89 c2                	mov    %eax,%edx
f0100b33:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b3b:	85 d2                	test   %edx,%edx
f0100b3d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b42:	0f 44 c2             	cmove  %edx,%eax
f0100b45:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b4b:	c3                   	ret    

f0100b4c <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b4c:	55                   	push   %ebp
f0100b4d:	89 e5                	mov    %esp,%ebp
f0100b4f:	57                   	push   %edi
f0100b50:	56                   	push   %esi
f0100b51:	53                   	push   %ebx
f0100b52:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b55:	84 c0                	test   %al,%al
f0100b57:	0f 85 a0 02 00 00    	jne    f0100dfd <check_page_free_list+0x2b1>
f0100b5d:	e9 ad 02 00 00       	jmp    f0100e0f <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b62:	83 ec 04             	sub    $0x4,%esp
f0100b65:	68 64 6d 10 f0       	push   $0xf0106d64
f0100b6a:	68 9f 02 00 00       	push   $0x29f
f0100b6f:	68 cd 76 10 f0       	push   $0xf01076cd
f0100b74:	e8 c7 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b79:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b7c:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b7f:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b82:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b85:	89 c2                	mov    %eax,%edx
f0100b87:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0100b8d:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b93:	0f 95 c2             	setne  %dl
f0100b96:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b99:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b9d:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b9f:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ba3:	8b 00                	mov    (%eax),%eax
f0100ba5:	85 c0                	test   %eax,%eax
f0100ba7:	75 dc                	jne    f0100b85 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100ba9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100bb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bb5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100bb8:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bba:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bbd:	a3 40 02 23 f0       	mov    %eax,0xf0230240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bc2:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bc7:	8b 1d 40 02 23 f0    	mov    0xf0230240,%ebx
f0100bcd:	eb 53                	jmp    f0100c22 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bcf:	89 d8                	mov    %ebx,%eax
f0100bd1:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0100bd7:	c1 f8 03             	sar    $0x3,%eax
f0100bda:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bdd:	89 c2                	mov    %eax,%edx
f0100bdf:	c1 ea 16             	shr    $0x16,%edx
f0100be2:	39 f2                	cmp    %esi,%edx
f0100be4:	73 3a                	jae    f0100c20 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100be6:	89 c2                	mov    %eax,%edx
f0100be8:	c1 ea 0c             	shr    $0xc,%edx
f0100beb:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0100bf1:	72 12                	jb     f0100c05 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bf3:	50                   	push   %eax
f0100bf4:	68 c4 67 10 f0       	push   $0xf01067c4
f0100bf9:	6a 58                	push   $0x58
f0100bfb:	68 d9 76 10 f0       	push   $0xf01076d9
f0100c00:	e8 3b f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c05:	83 ec 04             	sub    $0x4,%esp
f0100c08:	68 80 00 00 00       	push   $0x80
f0100c0d:	68 97 00 00 00       	push   $0x97
f0100c12:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c17:	50                   	push   %eax
f0100c18:	e8 c4 4e 00 00       	call   f0105ae1 <memset>
f0100c1d:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c20:	8b 1b                	mov    (%ebx),%ebx
f0100c22:	85 db                	test   %ebx,%ebx
f0100c24:	75 a9                	jne    f0100bcf <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c26:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c2b:	e8 53 fe ff ff       	call   f0100a83 <boot_alloc>
f0100c30:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c33:	8b 15 40 02 23 f0    	mov    0xf0230240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c39:	8b 0d 90 0e 23 f0    	mov    0xf0230e90,%ecx
		assert(pp < pages + npages);
f0100c3f:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f0100c44:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c47:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c4a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c4d:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c50:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c55:	e9 52 01 00 00       	jmp    f0100dac <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c5a:	39 ca                	cmp    %ecx,%edx
f0100c5c:	73 19                	jae    f0100c77 <check_page_free_list+0x12b>
f0100c5e:	68 e7 76 10 f0       	push   $0xf01076e7
f0100c63:	68 f3 76 10 f0       	push   $0xf01076f3
f0100c68:	68 b9 02 00 00       	push   $0x2b9
f0100c6d:	68 cd 76 10 f0       	push   $0xf01076cd
f0100c72:	e8 c9 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c77:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c7a:	72 19                	jb     f0100c95 <check_page_free_list+0x149>
f0100c7c:	68 08 77 10 f0       	push   $0xf0107708
f0100c81:	68 f3 76 10 f0       	push   $0xf01076f3
f0100c86:	68 ba 02 00 00       	push   $0x2ba
f0100c8b:	68 cd 76 10 f0       	push   $0xf01076cd
f0100c90:	e8 ab f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c95:	89 d0                	mov    %edx,%eax
f0100c97:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c9a:	a8 07                	test   $0x7,%al
f0100c9c:	74 19                	je     f0100cb7 <check_page_free_list+0x16b>
f0100c9e:	68 88 6d 10 f0       	push   $0xf0106d88
f0100ca3:	68 f3 76 10 f0       	push   $0xf01076f3
f0100ca8:	68 bb 02 00 00       	push   $0x2bb
f0100cad:	68 cd 76 10 f0       	push   $0xf01076cd
f0100cb2:	e8 89 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cb7:	c1 f8 03             	sar    $0x3,%eax
f0100cba:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cbd:	85 c0                	test   %eax,%eax
f0100cbf:	75 19                	jne    f0100cda <check_page_free_list+0x18e>
f0100cc1:	68 1c 77 10 f0       	push   $0xf010771c
f0100cc6:	68 f3 76 10 f0       	push   $0xf01076f3
f0100ccb:	68 be 02 00 00       	push   $0x2be
f0100cd0:	68 cd 76 10 f0       	push   $0xf01076cd
f0100cd5:	e8 66 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cda:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cdf:	75 19                	jne    f0100cfa <check_page_free_list+0x1ae>
f0100ce1:	68 2d 77 10 f0       	push   $0xf010772d
f0100ce6:	68 f3 76 10 f0       	push   $0xf01076f3
f0100ceb:	68 bf 02 00 00       	push   $0x2bf
f0100cf0:	68 cd 76 10 f0       	push   $0xf01076cd
f0100cf5:	e8 46 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100cfa:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100cff:	75 19                	jne    f0100d1a <check_page_free_list+0x1ce>
f0100d01:	68 bc 6d 10 f0       	push   $0xf0106dbc
f0100d06:	68 f3 76 10 f0       	push   $0xf01076f3
f0100d0b:	68 c0 02 00 00       	push   $0x2c0
f0100d10:	68 cd 76 10 f0       	push   $0xf01076cd
f0100d15:	e8 26 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d1a:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d1f:	75 19                	jne    f0100d3a <check_page_free_list+0x1ee>
f0100d21:	68 46 77 10 f0       	push   $0xf0107746
f0100d26:	68 f3 76 10 f0       	push   $0xf01076f3
f0100d2b:	68 c1 02 00 00       	push   $0x2c1
f0100d30:	68 cd 76 10 f0       	push   $0xf01076cd
f0100d35:	e8 06 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d3a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d3f:	0f 86 f1 00 00 00    	jbe    f0100e36 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d45:	89 c7                	mov    %eax,%edi
f0100d47:	c1 ef 0c             	shr    $0xc,%edi
f0100d4a:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100d4d:	77 12                	ja     f0100d61 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d4f:	50                   	push   %eax
f0100d50:	68 c4 67 10 f0       	push   $0xf01067c4
f0100d55:	6a 58                	push   $0x58
f0100d57:	68 d9 76 10 f0       	push   $0xf01076d9
f0100d5c:	e8 df f2 ff ff       	call   f0100040 <_panic>
f0100d61:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100d67:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100d6a:	0f 86 b6 00 00 00    	jbe    f0100e26 <check_page_free_list+0x2da>
f0100d70:	68 e0 6d 10 f0       	push   $0xf0106de0
f0100d75:	68 f3 76 10 f0       	push   $0xf01076f3
f0100d7a:	68 c2 02 00 00       	push   $0x2c2
f0100d7f:	68 cd 76 10 f0       	push   $0xf01076cd
f0100d84:	e8 b7 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d89:	68 60 77 10 f0       	push   $0xf0107760
f0100d8e:	68 f3 76 10 f0       	push   $0xf01076f3
f0100d93:	68 c4 02 00 00       	push   $0x2c4
f0100d98:	68 cd 76 10 f0       	push   $0xf01076cd
f0100d9d:	e8 9e f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100da2:	83 c6 01             	add    $0x1,%esi
f0100da5:	eb 03                	jmp    f0100daa <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100da7:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100daa:	8b 12                	mov    (%edx),%edx
f0100dac:	85 d2                	test   %edx,%edx
f0100dae:	0f 85 a6 fe ff ff    	jne    f0100c5a <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100db4:	85 f6                	test   %esi,%esi
f0100db6:	7f 19                	jg     f0100dd1 <check_page_free_list+0x285>
f0100db8:	68 7d 77 10 f0       	push   $0xf010777d
f0100dbd:	68 f3 76 10 f0       	push   $0xf01076f3
f0100dc2:	68 cc 02 00 00       	push   $0x2cc
f0100dc7:	68 cd 76 10 f0       	push   $0xf01076cd
f0100dcc:	e8 6f f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100dd1:	85 db                	test   %ebx,%ebx
f0100dd3:	7f 19                	jg     f0100dee <check_page_free_list+0x2a2>
f0100dd5:	68 8f 77 10 f0       	push   $0xf010778f
f0100dda:	68 f3 76 10 f0       	push   $0xf01076f3
f0100ddf:	68 cd 02 00 00       	push   $0x2cd
f0100de4:	68 cd 76 10 f0       	push   $0xf01076cd
f0100de9:	e8 52 f2 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100dee:	83 ec 0c             	sub    $0xc,%esp
f0100df1:	68 28 6e 10 f0       	push   $0xf0106e28
f0100df6:	e8 5a 28 00 00       	call   f0103655 <cprintf>
}
f0100dfb:	eb 49                	jmp    f0100e46 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100dfd:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f0100e02:	85 c0                	test   %eax,%eax
f0100e04:	0f 85 6f fd ff ff    	jne    f0100b79 <check_page_free_list+0x2d>
f0100e0a:	e9 53 fd ff ff       	jmp    f0100b62 <check_page_free_list+0x16>
f0100e0f:	83 3d 40 02 23 f0 00 	cmpl   $0x0,0xf0230240
f0100e16:	0f 84 46 fd ff ff    	je     f0100b62 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e1c:	be 00 04 00 00       	mov    $0x400,%esi
f0100e21:	e9 a1 fd ff ff       	jmp    f0100bc7 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e26:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e2b:	0f 85 76 ff ff ff    	jne    f0100da7 <check_page_free_list+0x25b>
f0100e31:	e9 53 ff ff ff       	jmp    f0100d89 <check_page_free_list+0x23d>
f0100e36:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e3b:	0f 85 61 ff ff ff    	jne    f0100da2 <check_page_free_list+0x256>
f0100e41:	e9 43 ff ff ff       	jmp    f0100d89 <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100e46:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e49:	5b                   	pop    %ebx
f0100e4a:	5e                   	pop    %esi
f0100e4b:	5f                   	pop    %edi
f0100e4c:	5d                   	pop    %ebp
f0100e4d:	c3                   	ret    

f0100e4e <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e4e:	55                   	push   %ebp
f0100e4f:	89 e5                	mov    %esp,%ebp
f0100e51:	57                   	push   %edi
f0100e52:	56                   	push   %esi
f0100e53:	53                   	push   %ebx
f0100e54:	83 ec 0c             	sub    $0xc,%esp
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	physaddr_t pa;
	char *va;
	for (i = 0; i < npages; i++) {
f0100e57:	be 00 00 00 00       	mov    $0x0,%esi
f0100e5c:	bf 00 00 00 00       	mov    $0x0,%edi
f0100e61:	e9 90 00 00 00       	jmp    f0100ef6 <page_init+0xa8>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e66:	89 f3                	mov    %esi,%ebx
f0100e68:	c1 fb 03             	sar    $0x3,%ebx
f0100e6b:	c1 e3 0c             	shl    $0xc,%ebx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e6e:	89 da                	mov    %ebx,%edx
f0100e70:	c1 ea 0c             	shr    $0xc,%edx
f0100e73:	39 d0                	cmp    %edx,%eax
f0100e75:	77 12                	ja     f0100e89 <page_init+0x3b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e77:	53                   	push   %ebx
f0100e78:	68 c4 67 10 f0       	push   $0xf01067c4
f0100e7d:	6a 58                	push   $0x58
f0100e7f:	68 d9 76 10 f0       	push   $0xf01076d9
f0100e84:	e8 b7 f1 ff ff       	call   f0100040 <_panic>
		pa = page2pa(&pages[i]);
		va = page2kva(&pages[i]);
		if (i == 0 || (IOPHYSMEM <= pa && va < (char *)boot_alloc(0))
f0100e89:	85 ff                	test   %edi,%edi
f0100e8b:	74 2a                	je     f0100eb7 <page_init+0x69>
f0100e8d:	81 fb ff ff 09 00    	cmp    $0x9ffff,%ebx
f0100e93:	76 14                	jbe    f0100ea9 <page_init+0x5b>
f0100e95:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e9a:	e8 e4 fb ff ff       	call   f0100a83 <boot_alloc>
f0100e9f:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0100ea5:	39 d0                	cmp    %edx,%eax
f0100ea7:	77 0e                	ja     f0100eb7 <page_init+0x69>
				|| (MPENTRY_PADDR <= pa && pa < MPENTRY_PADDR + PGSIZE)) {
f0100ea9:	81 eb 00 70 00 00    	sub    $0x7000,%ebx
f0100eaf:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
f0100eb5:	77 16                	ja     f0100ecd <page_init+0x7f>
			pages[i].pp_ref = 1;
f0100eb7:	89 f0                	mov    %esi,%eax
f0100eb9:	03 05 90 0e 23 f0    	add    0xf0230e90,%eax
f0100ebf:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100ec5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ecb:	eb 23                	jmp    f0100ef0 <page_init+0xa2>
		}else {
			pages[i].pp_ref = 0;
f0100ecd:	89 f0                	mov    %esi,%eax
f0100ecf:	03 05 90 0e 23 f0    	add    0xf0230e90,%eax
f0100ed5:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100edb:	8b 15 40 02 23 f0    	mov    0xf0230240,%edx
f0100ee1:	89 10                	mov    %edx,(%eax)
			page_free_list = &pages[i];
f0100ee3:	89 f0                	mov    %esi,%eax
f0100ee5:	03 05 90 0e 23 f0    	add    0xf0230e90,%eax
f0100eeb:	a3 40 02 23 f0       	mov    %eax,0xf0230240
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	physaddr_t pa;
	char *va;
	for (i = 0; i < npages; i++) {
f0100ef0:	83 c7 01             	add    $0x1,%edi
f0100ef3:	83 c6 08             	add    $0x8,%esi
f0100ef6:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f0100efb:	39 c7                	cmp    %eax,%edi
f0100efd:	0f 82 63 ff ff ff    	jb     f0100e66 <page_init+0x18>
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100f03:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f06:	5b                   	pop    %ebx
f0100f07:	5e                   	pop    %esi
f0100f08:	5f                   	pop    %edi
f0100f09:	5d                   	pop    %ebp
f0100f0a:	c3                   	ret    

f0100f0b <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f0b:	55                   	push   %ebp
f0100f0c:	89 e5                	mov    %esp,%ebp
f0100f0e:	53                   	push   %ebx
f0100f0f:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo *result = page_free_list;
f0100f12:	8b 1d 40 02 23 f0    	mov    0xf0230240,%ebx
	// Fill this function in
	if (page_free_list < pages || &pages[npages] < page_free_list) {
f0100f18:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
f0100f1d:	39 c3                	cmp    %eax,%ebx
f0100f1f:	72 68                	jb     f0100f89 <page_alloc+0x7e>
f0100f21:	8b 15 88 0e 23 f0    	mov    0xf0230e88,%edx
f0100f27:	8d 0c d0             	lea    (%eax,%edx,8),%ecx
f0100f2a:	39 cb                	cmp    %ecx,%ebx
f0100f2c:	77 62                	ja     f0100f90 <page_alloc+0x85>
		return NULL;
	}
	if (alloc_flags & ALLOC_ZERO) {
f0100f2e:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f32:	74 3f                	je     f0100f73 <page_alloc+0x68>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f34:	89 d9                	mov    %ebx,%ecx
f0100f36:	29 c1                	sub    %eax,%ecx
f0100f38:	89 c8                	mov    %ecx,%eax
f0100f3a:	c1 f8 03             	sar    $0x3,%eax
f0100f3d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f40:	89 c1                	mov    %eax,%ecx
f0100f42:	c1 e9 0c             	shr    $0xc,%ecx
f0100f45:	39 ca                	cmp    %ecx,%edx
f0100f47:	77 12                	ja     f0100f5b <page_alloc+0x50>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f49:	50                   	push   %eax
f0100f4a:	68 c4 67 10 f0       	push   $0xf01067c4
f0100f4f:	6a 58                	push   $0x58
f0100f51:	68 d9 76 10 f0       	push   $0xf01076d9
f0100f56:	e8 e5 f0 ff ff       	call   f0100040 <_panic>
		memset(page2kva(page_free_list), 0, PGSIZE);
f0100f5b:	83 ec 04             	sub    $0x4,%esp
f0100f5e:	68 00 10 00 00       	push   $0x1000
f0100f63:	6a 00                	push   $0x0
f0100f65:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f6a:	50                   	push   %eax
f0100f6b:	e8 71 4b 00 00       	call   f0105ae1 <memset>
f0100f70:	83 c4 10             	add    $0x10,%esp
	}
	page_free_list = page_free_list->pp_link;
f0100f73:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f0100f78:	8b 00                	mov    (%eax),%eax
f0100f7a:	a3 40 02 23 f0       	mov    %eax,0xf0230240
	result->pp_link = NULL;
f0100f7f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return result;
f0100f85:	89 d8                	mov    %ebx,%eax
f0100f87:	eb 0c                	jmp    f0100f95 <page_alloc+0x8a>
page_alloc(int alloc_flags)
{
	struct PageInfo *result = page_free_list;
	// Fill this function in
	if (page_free_list < pages || &pages[npages] < page_free_list) {
		return NULL;
f0100f89:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f8e:	eb 05                	jmp    f0100f95 <page_alloc+0x8a>
f0100f90:	b8 00 00 00 00       	mov    $0x0,%eax
		memset(page2kva(page_free_list), 0, PGSIZE);
	}
	page_free_list = page_free_list->pp_link;
	result->pp_link = NULL;
	return result;
}
f0100f95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f98:	c9                   	leave  
f0100f99:	c3                   	ret    

f0100f9a <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f9a:	55                   	push   %ebp
f0100f9b:	89 e5                	mov    %esp,%ebp
f0100f9d:	83 ec 08             	sub    $0x8,%esp
f0100fa0:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0)
f0100fa3:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fa8:	74 17                	je     f0100fc1 <page_free+0x27>
		panic("page_free: pp->pp_ref is nonzero\n");
f0100faa:	83 ec 04             	sub    $0x4,%esp
f0100fad:	68 4c 6e 10 f0       	push   $0xf0106e4c
f0100fb2:	68 76 01 00 00       	push   $0x176
f0100fb7:	68 cd 76 10 f0       	push   $0xf01076cd
f0100fbc:	e8 7f f0 ff ff       	call   f0100040 <_panic>
	if (pp->pp_ref != 0 || pp->pp_link != NULL)
f0100fc1:	83 38 00             	cmpl   $0x0,(%eax)
f0100fc4:	74 17                	je     f0100fdd <page_free+0x43>
		panic("page_free: pp->pp_link is not NULL\n");
f0100fc6:	83 ec 04             	sub    $0x4,%esp
f0100fc9:	68 70 6e 10 f0       	push   $0xf0106e70
f0100fce:	68 78 01 00 00       	push   $0x178
f0100fd3:	68 cd 76 10 f0       	push   $0xf01076cd
f0100fd8:	e8 63 f0 ff ff       	call   f0100040 <_panic>
	pp->pp_link = page_free_list;
f0100fdd:	8b 15 40 02 23 f0    	mov    0xf0230240,%edx
f0100fe3:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100fe5:	a3 40 02 23 f0       	mov    %eax,0xf0230240
}
f0100fea:	c9                   	leave  
f0100feb:	c3                   	ret    

f0100fec <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100fec:	55                   	push   %ebp
f0100fed:	89 e5                	mov    %esp,%ebp
f0100fef:	83 ec 08             	sub    $0x8,%esp
f0100ff2:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100ff5:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100ff9:	83 e8 01             	sub    $0x1,%eax
f0100ffc:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101000:	66 85 c0             	test   %ax,%ax
f0101003:	75 0c                	jne    f0101011 <page_decref+0x25>
		page_free(pp);
f0101005:	83 ec 0c             	sub    $0xc,%esp
f0101008:	52                   	push   %edx
f0101009:	e8 8c ff ff ff       	call   f0100f9a <page_free>
f010100e:	83 c4 10             	add    $0x10,%esp
}
f0101011:	c9                   	leave  
f0101012:	c3                   	ret    

f0101013 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101013:	55                   	push   %ebp
f0101014:	89 e5                	mov    %esp,%ebp
f0101016:	56                   	push   %esi
f0101017:	53                   	push   %ebx
f0101018:	8b 45 0c             	mov    0xc(%ebp),%eax
	// Fill this function in
	pte_t *pte = (pte_t *)PTE_ADDR(pgdir[PDX(va)]);
f010101b:	89 c3                	mov    %eax,%ebx
f010101d:	c1 eb 16             	shr    $0x16,%ebx
f0101020:	c1 e3 02             	shl    $0x2,%ebx
f0101023:	03 5d 08             	add    0x8(%ebp),%ebx
f0101026:	8b 13                	mov    (%ebx),%edx
f0101028:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	pte_t *pte_result = &pte[PTX(va)];
f010102e:	c1 e8 0a             	shr    $0xa,%eax
f0101031:	25 fc 0f 00 00       	and    $0xffc,%eax
f0101036:	89 c6                	mov    %eax,%esi
f0101038:	8d 04 02             	lea    (%edx,%eax,1),%eax
	struct PageInfo *page;
	if (!pte || !pte_result) {
f010103b:	85 d2                	test   %edx,%edx
f010103d:	74 04                	je     f0101043 <pgdir_walk+0x30>
f010103f:	85 c0                	test   %eax,%eax
f0101041:	75 5c                	jne    f010109f <pgdir_walk+0x8c>
		physaddr_t pa;
		if (create == false) return NULL;
f0101043:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101047:	74 7f                	je     f01010c8 <pgdir_walk+0xb5>
		if (!(page = page_alloc(ALLOC_ZERO))) return NULL;
f0101049:	83 ec 0c             	sub    $0xc,%esp
f010104c:	6a 01                	push   $0x1
f010104e:	e8 b8 fe ff ff       	call   f0100f0b <page_alloc>
f0101053:	83 c4 10             	add    $0x10,%esp
f0101056:	85 c0                	test   %eax,%eax
f0101058:	74 75                	je     f01010cf <pgdir_walk+0xbc>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010105a:	89 c2                	mov    %eax,%edx
f010105c:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0101062:	c1 fa 03             	sar    $0x3,%edx
f0101065:	c1 e2 0c             	shl    $0xc,%edx
		pa = page2pa(page);
		pgdir[PDX(va)] = pa | PTE_P | PTE_W | PTE_U;
f0101068:	89 d1                	mov    %edx,%ecx
f010106a:	83 c9 07             	or     $0x7,%ecx
f010106d:	89 0b                	mov    %ecx,(%ebx)
		page->pp_ref++;
f010106f:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101074:	89 d0                	mov    %edx,%eax
f0101076:	c1 e8 0c             	shr    $0xc,%eax
f0101079:	39 05 88 0e 23 f0    	cmp    %eax,0xf0230e88
f010107f:	77 15                	ja     f0101096 <pgdir_walk+0x83>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101081:	52                   	push   %edx
f0101082:	68 c4 67 10 f0       	push   $0xf01067c4
f0101087:	68 ac 01 00 00       	push   $0x1ac
f010108c:	68 cd 76 10 f0       	push   $0xf01076cd
f0101091:	e8 aa ef ff ff       	call   f0100040 <_panic>
		return (pte_t *)KADDR(pa) + PTX(va);
f0101096:	8d 84 16 00 00 00 f0 	lea    -0x10000000(%esi,%edx,1),%eax
f010109d:	eb 35                	jmp    f01010d4 <pgdir_walk+0xc1>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010109f:	89 c2                	mov    %eax,%edx
f01010a1:	c1 ea 0c             	shr    $0xc,%edx
f01010a4:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f01010aa:	72 15                	jb     f01010c1 <pgdir_walk+0xae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010ac:	50                   	push   %eax
f01010ad:	68 c4 67 10 f0       	push   $0xf01067c4
f01010b2:	68 ae 01 00 00       	push   $0x1ae
f01010b7:	68 cd 76 10 f0       	push   $0xf01076cd
f01010bc:	e8 7f ef ff ff       	call   f0100040 <_panic>
	}
	return KADDR((physaddr_t)pte_result);
f01010c1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01010c6:	eb 0c                	jmp    f01010d4 <pgdir_walk+0xc1>
	pte_t *pte = (pte_t *)PTE_ADDR(pgdir[PDX(va)]);
	pte_t *pte_result = &pte[PTX(va)];
	struct PageInfo *page;
	if (!pte || !pte_result) {
		physaddr_t pa;
		if (create == false) return NULL;
f01010c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01010cd:	eb 05                	jmp    f01010d4 <pgdir_walk+0xc1>
		if (!(page = page_alloc(ALLOC_ZERO))) return NULL;
f01010cf:	b8 00 00 00 00       	mov    $0x0,%eax
		pgdir[PDX(va)] = pa | PTE_P | PTE_W | PTE_U;
		page->pp_ref++;
		return (pte_t *)KADDR(pa) + PTX(va);
	}
	return KADDR((physaddr_t)pte_result);
}
f01010d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010d7:	5b                   	pop    %ebx
f01010d8:	5e                   	pop    %esi
f01010d9:	5d                   	pop    %ebp
f01010da:	c3                   	ret    

f01010db <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01010db:	55                   	push   %ebp
f01010dc:	89 e5                	mov    %esp,%ebp
f01010de:	57                   	push   %edi
f01010df:	56                   	push   %esi
f01010e0:	53                   	push   %ebx
f01010e1:	83 ec 1c             	sub    $0x1c,%esp
f01010e4:	89 c7                	mov    %eax,%edi
f01010e6:	89 d6                	mov    %edx,%esi
f01010e8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f01010eb:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		*pte = (pa + i) | perm | PTE_P;
f01010f0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010f3:	83 c8 01             	or     $0x1,%eax
f01010f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f01010f9:	eb 22                	jmp    f010111d <boot_map_region+0x42>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
f01010fb:	83 ec 04             	sub    $0x4,%esp
f01010fe:	6a 01                	push   $0x1
f0101100:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101103:	50                   	push   %eax
f0101104:	57                   	push   %edi
f0101105:	e8 09 ff ff ff       	call   f0101013 <pgdir_walk>
		*pte = (pa + i) | perm | PTE_P;
f010110a:	89 da                	mov    %ebx,%edx
f010110c:	03 55 08             	add    0x8(%ebp),%edx
f010110f:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101112:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f0101114:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010111a:	83 c4 10             	add    $0x10,%esp
f010111d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101120:	72 d9                	jb     f01010fb <boot_map_region+0x20>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		*pte = (pa + i) | perm | PTE_P;
	}
}
f0101122:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101125:	5b                   	pop    %ebx
f0101126:	5e                   	pop    %esi
f0101127:	5f                   	pop    %edi
f0101128:	5d                   	pop    %ebp
f0101129:	c3                   	ret    

f010112a <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010112a:	55                   	push   %ebp
f010112b:	89 e5                	mov    %esp,%ebp
f010112d:	53                   	push   %ebx
f010112e:	83 ec 08             	sub    $0x8,%esp
f0101131:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101134:	6a 00                	push   $0x0
f0101136:	ff 75 0c             	pushl  0xc(%ebp)
f0101139:	ff 75 08             	pushl  0x8(%ebp)
f010113c:	e8 d2 fe ff ff       	call   f0101013 <pgdir_walk>
	if (!pte) return NULL;
f0101141:	83 c4 10             	add    $0x10,%esp
f0101144:	85 c0                	test   %eax,%eax
f0101146:	74 32                	je     f010117a <page_lookup+0x50>
	if (pte_store)
f0101148:	85 db                	test   %ebx,%ebx
f010114a:	74 02                	je     f010114e <page_lookup+0x24>
		*pte_store = pte;
f010114c:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010114e:	8b 00                	mov    (%eax),%eax
f0101150:	c1 e8 0c             	shr    $0xc,%eax
f0101153:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f0101159:	72 14                	jb     f010116f <page_lookup+0x45>
		panic("pa2page called with invalid pa");
f010115b:	83 ec 04             	sub    $0x4,%esp
f010115e:	68 94 6e 10 f0       	push   $0xf0106e94
f0101163:	6a 51                	push   $0x51
f0101165:	68 d9 76 10 f0       	push   $0xf01076d9
f010116a:	e8 d1 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f010116f:	8b 15 90 0e 23 f0    	mov    0xf0230e90,%edx
f0101175:	8d 04 c2             	lea    (%edx,%eax,8),%eax

	struct PageInfo *result = pa2page(PTE_ADDR(*pte));

	return result;
f0101178:	eb 05                	jmp    f010117f <page_lookup+0x55>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
	if (!pte) return NULL;
f010117a:	b8 00 00 00 00       	mov    $0x0,%eax
		*pte_store = pte;

	struct PageInfo *result = pa2page(PTE_ADDR(*pte));

	return result;
}
f010117f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101182:	c9                   	leave  
f0101183:	c3                   	ret    

f0101184 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101184:	55                   	push   %ebp
f0101185:	89 e5                	mov    %esp,%ebp
f0101187:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f010118a:	e8 73 4f 00 00       	call   f0106102 <cpunum>
f010118f:	6b c0 74             	imul   $0x74,%eax,%eax
f0101192:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f0101199:	74 16                	je     f01011b1 <tlb_invalidate+0x2d>
f010119b:	e8 62 4f 00 00       	call   f0106102 <cpunum>
f01011a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01011a3:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f01011a9:	8b 55 08             	mov    0x8(%ebp),%edx
f01011ac:	39 50 60             	cmp    %edx,0x60(%eax)
f01011af:	75 06                	jne    f01011b7 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011b1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011b4:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01011b7:	c9                   	leave  
f01011b8:	c3                   	ret    

f01011b9 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011b9:	55                   	push   %ebp
f01011ba:	89 e5                	mov    %esp,%ebp
f01011bc:	57                   	push   %edi
f01011bd:	56                   	push   %esi
f01011be:	53                   	push   %ebx
f01011bf:	83 ec 20             	sub    $0x20,%esp
f01011c2:	8b 75 08             	mov    0x8(%ebp),%esi
f01011c5:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pte_t *pte;
	struct PageInfo *page = page_lookup(pgdir, va, &pte);
f01011c8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01011cb:	50                   	push   %eax
f01011cc:	57                   	push   %edi
f01011cd:	56                   	push   %esi
f01011ce:	e8 57 ff ff ff       	call   f010112a <page_lookup>
	if (!page) return;
f01011d3:	83 c4 10             	add    $0x10,%esp
f01011d6:	85 c0                	test   %eax,%eax
f01011d8:	74 24                	je     f01011fe <page_remove+0x45>
f01011da:	89 c3                	mov    %eax,%ebx

	tlb_invalidate(pgdir, va);
f01011dc:	83 ec 08             	sub    $0x8,%esp
f01011df:	57                   	push   %edi
f01011e0:	56                   	push   %esi
f01011e1:	e8 9e ff ff ff       	call   f0101184 <tlb_invalidate>
	page_decref(page);
f01011e6:	89 1c 24             	mov    %ebx,(%esp)
f01011e9:	e8 fe fd ff ff       	call   f0100fec <page_decref>
	if (pte) {
f01011ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01011f1:	83 c4 10             	add    $0x10,%esp
f01011f4:	85 c0                	test   %eax,%eax
f01011f6:	74 06                	je     f01011fe <page_remove+0x45>
		*pte = 0;
f01011f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
}
f01011fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101201:	5b                   	pop    %ebx
f0101202:	5e                   	pop    %esi
f0101203:	5f                   	pop    %edi
f0101204:	5d                   	pop    %ebp
f0101205:	c3                   	ret    

f0101206 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101206:	55                   	push   %ebp
f0101207:	89 e5                	mov    %esp,%ebp
f0101209:	57                   	push   %edi
f010120a:	56                   	push   %esi
f010120b:	53                   	push   %ebx
f010120c:	83 ec 10             	sub    $0x10,%esp
f010120f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101212:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101215:	6a 01                	push   $0x1
f0101217:	57                   	push   %edi
f0101218:	ff 75 08             	pushl  0x8(%ebp)
f010121b:	e8 f3 fd ff ff       	call   f0101013 <pgdir_walk>
	if (!pte)return -E_NO_MEM;
f0101220:	83 c4 10             	add    $0x10,%esp
f0101223:	85 c0                	test   %eax,%eax
f0101225:	74 47                	je     f010126e <page_insert+0x68>
f0101227:	89 c6                	mov    %eax,%esi
	tlb_invalidate(pgdir, va);
f0101229:	83 ec 08             	sub    $0x8,%esp
f010122c:	57                   	push   %edi
f010122d:	ff 75 08             	pushl  0x8(%ebp)
f0101230:	e8 4f ff ff ff       	call   f0101184 <tlb_invalidate>
	pp->pp_ref++;
f0101235:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte) {
f010123a:	83 c4 10             	add    $0x10,%esp
f010123d:	83 3e 00             	cmpl   $0x0,(%esi)
f0101240:	74 0f                	je     f0101251 <page_insert+0x4b>
		page_remove(pgdir, va);
f0101242:	83 ec 08             	sub    $0x8,%esp
f0101245:	57                   	push   %edi
f0101246:	ff 75 08             	pushl  0x8(%ebp)
f0101249:	e8 6b ff ff ff       	call   f01011b9 <page_remove>
f010124e:	83 c4 10             	add    $0x10,%esp
	}
	*pte = page2pa(pp) | perm | PTE_P;
f0101251:	2b 1d 90 0e 23 f0    	sub    0xf0230e90,%ebx
f0101257:	c1 fb 03             	sar    $0x3,%ebx
f010125a:	c1 e3 0c             	shl    $0xc,%ebx
f010125d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101260:	83 c8 01             	or     $0x1,%eax
f0101263:	09 c3                	or     %eax,%ebx
f0101265:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101267:	b8 00 00 00 00       	mov    $0x0,%eax
f010126c:	eb 05                	jmp    f0101273 <page_insert+0x6d>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	if (!pte)return -E_NO_MEM;
f010126e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	if (*pte) {
		page_remove(pgdir, va);
	}
	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f0101273:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101276:	5b                   	pop    %ebx
f0101277:	5e                   	pop    %esi
f0101278:	5f                   	pop    %edi
f0101279:	5d                   	pop    %ebp
f010127a:	c3                   	ret    

f010127b <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f010127b:	55                   	push   %ebp
f010127c:	89 e5                	mov    %esp,%ebp
f010127e:	56                   	push   %esi
f010127f:	53                   	push   %ebx
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	size = ROUNDUP(size, PGSIZE);
f0101280:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101283:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f0101289:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uintptr_t tmp = base;
f010128f:	8b 35 00 13 12 f0    	mov    0xf0121300,%esi
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD | PTE_PWT | PTE_W);
f0101295:	83 ec 08             	sub    $0x8,%esp
f0101298:	6a 1a                	push   $0x1a
f010129a:	ff 75 08             	pushl  0x8(%ebp)
f010129d:	89 d9                	mov    %ebx,%ecx
f010129f:	89 f2                	mov    %esi,%edx
f01012a1:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01012a6:	e8 30 fe ff ff       	call   f01010db <boot_map_region>
	base += size;
f01012ab:	01 1d 00 13 12 f0    	add    %ebx,0xf0121300
	return (void *)tmp;
}
f01012b1:	89 f0                	mov    %esi,%eax
f01012b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01012b6:	5b                   	pop    %ebx
f01012b7:	5e                   	pop    %esi
f01012b8:	5d                   	pop    %ebp
f01012b9:	c3                   	ret    

f01012ba <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01012ba:	55                   	push   %ebp
f01012bb:	89 e5                	mov    %esp,%ebp
f01012bd:	57                   	push   %edi
f01012be:	56                   	push   %esi
f01012bf:	53                   	push   %ebx
f01012c0:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01012c3:	b8 15 00 00 00       	mov    $0x15,%eax
f01012c8:	e8 f2 f7 ff ff       	call   f0100abf <nvram_read>
f01012cd:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01012cf:	b8 17 00 00 00       	mov    $0x17,%eax
f01012d4:	e8 e6 f7 ff ff       	call   f0100abf <nvram_read>
f01012d9:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01012db:	b8 34 00 00 00       	mov    $0x34,%eax
f01012e0:	e8 da f7 ff ff       	call   f0100abf <nvram_read>
f01012e5:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01012e8:	85 c0                	test   %eax,%eax
f01012ea:	74 07                	je     f01012f3 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01012ec:	05 00 40 00 00       	add    $0x4000,%eax
f01012f1:	eb 0b                	jmp    f01012fe <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01012f3:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01012f9:	85 f6                	test   %esi,%esi
f01012fb:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01012fe:	89 c2                	mov    %eax,%edx
f0101300:	c1 ea 02             	shr    $0x2,%edx
f0101303:	89 15 88 0e 23 f0    	mov    %edx,0xf0230e88
	npages_basemem = basemem / (PGSIZE / 1024);

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101309:	89 c2                	mov    %eax,%edx
f010130b:	29 da                	sub    %ebx,%edx
f010130d:	52                   	push   %edx
f010130e:	53                   	push   %ebx
f010130f:	50                   	push   %eax
f0101310:	68 b4 6e 10 f0       	push   $0xf0106eb4
f0101315:	e8 3b 23 00 00       	call   f0103655 <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010131a:	b8 00 10 00 00       	mov    $0x1000,%eax
f010131f:	e8 5f f7 ff ff       	call   f0100a83 <boot_alloc>
f0101324:	a3 8c 0e 23 f0       	mov    %eax,0xf0230e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101329:	83 c4 0c             	add    $0xc,%esp
f010132c:	68 00 10 00 00       	push   $0x1000
f0101331:	6a 00                	push   $0x0
f0101333:	50                   	push   %eax
f0101334:	e8 a8 47 00 00       	call   f0105ae1 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101339:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010133e:	83 c4 10             	add    $0x10,%esp
f0101341:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101346:	77 15                	ja     f010135d <mem_init+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101348:	50                   	push   %eax
f0101349:	68 e8 67 10 f0       	push   $0xf01067e8
f010134e:	68 93 00 00 00       	push   $0x93
f0101353:	68 cd 76 10 f0       	push   $0xf01076cd
f0101358:	e8 e3 ec ff ff       	call   f0100040 <_panic>
f010135d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101363:	83 ca 05             	or     $0x5,%edx
f0101366:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *)boot_alloc(npages * sizeof(struct PageInfo));
f010136c:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f0101371:	c1 e0 03             	shl    $0x3,%eax
f0101374:	e8 0a f7 ff ff       	call   f0100a83 <boot_alloc>
f0101379:	a3 90 0e 23 f0       	mov    %eax,0xf0230e90
	memset(pages, 0, npages * sizeof(struct PageInfo));
f010137e:	83 ec 04             	sub    $0x4,%esp
f0101381:	8b 0d 88 0e 23 f0    	mov    0xf0230e88,%ecx
f0101387:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f010138e:	52                   	push   %edx
f010138f:	6a 00                	push   $0x0
f0101391:	50                   	push   %eax
f0101392:	e8 4a 47 00 00       	call   f0105ae1 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f0101397:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010139c:	e8 e2 f6 ff ff       	call   f0100a83 <boot_alloc>
f01013a1:	a3 44 02 23 f0       	mov    %eax,0xf0230244
	memset(envs, 0, NENV * sizeof(struct Env));
f01013a6:	83 c4 0c             	add    $0xc,%esp
f01013a9:	68 00 f0 01 00       	push   $0x1f000
f01013ae:	6a 00                	push   $0x0
f01013b0:	50                   	push   %eax
f01013b1:	e8 2b 47 00 00       	call   f0105ae1 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01013b6:	e8 93 fa ff ff       	call   f0100e4e <page_init>

	check_page_free_list(1);
f01013bb:	b8 01 00 00 00       	mov    $0x1,%eax
f01013c0:	e8 87 f7 ff ff       	call   f0100b4c <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01013c5:	83 c4 10             	add    $0x10,%esp
f01013c8:	83 3d 90 0e 23 f0 00 	cmpl   $0x0,0xf0230e90
f01013cf:	75 17                	jne    f01013e8 <mem_init+0x12e>
		panic("'pages' is a null pointer!");
f01013d1:	83 ec 04             	sub    $0x4,%esp
f01013d4:	68 a0 77 10 f0       	push   $0xf01077a0
f01013d9:	68 e0 02 00 00       	push   $0x2e0
f01013de:	68 cd 76 10 f0       	push   $0xf01076cd
f01013e3:	e8 58 ec ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013e8:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f01013ed:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013f2:	eb 05                	jmp    f01013f9 <mem_init+0x13f>
		++nfree;
f01013f4:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013f7:	8b 00                	mov    (%eax),%eax
f01013f9:	85 c0                	test   %eax,%eax
f01013fb:	75 f7                	jne    f01013f4 <mem_init+0x13a>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013fd:	83 ec 0c             	sub    $0xc,%esp
f0101400:	6a 00                	push   $0x0
f0101402:	e8 04 fb ff ff       	call   f0100f0b <page_alloc>
f0101407:	89 c7                	mov    %eax,%edi
f0101409:	83 c4 10             	add    $0x10,%esp
f010140c:	85 c0                	test   %eax,%eax
f010140e:	75 19                	jne    f0101429 <mem_init+0x16f>
f0101410:	68 bb 77 10 f0       	push   $0xf01077bb
f0101415:	68 f3 76 10 f0       	push   $0xf01076f3
f010141a:	68 e8 02 00 00       	push   $0x2e8
f010141f:	68 cd 76 10 f0       	push   $0xf01076cd
f0101424:	e8 17 ec ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101429:	83 ec 0c             	sub    $0xc,%esp
f010142c:	6a 00                	push   $0x0
f010142e:	e8 d8 fa ff ff       	call   f0100f0b <page_alloc>
f0101433:	89 c6                	mov    %eax,%esi
f0101435:	83 c4 10             	add    $0x10,%esp
f0101438:	85 c0                	test   %eax,%eax
f010143a:	75 19                	jne    f0101455 <mem_init+0x19b>
f010143c:	68 d1 77 10 f0       	push   $0xf01077d1
f0101441:	68 f3 76 10 f0       	push   $0xf01076f3
f0101446:	68 e9 02 00 00       	push   $0x2e9
f010144b:	68 cd 76 10 f0       	push   $0xf01076cd
f0101450:	e8 eb eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101455:	83 ec 0c             	sub    $0xc,%esp
f0101458:	6a 00                	push   $0x0
f010145a:	e8 ac fa ff ff       	call   f0100f0b <page_alloc>
f010145f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101462:	83 c4 10             	add    $0x10,%esp
f0101465:	85 c0                	test   %eax,%eax
f0101467:	75 19                	jne    f0101482 <mem_init+0x1c8>
f0101469:	68 e7 77 10 f0       	push   $0xf01077e7
f010146e:	68 f3 76 10 f0       	push   $0xf01076f3
f0101473:	68 ea 02 00 00       	push   $0x2ea
f0101478:	68 cd 76 10 f0       	push   $0xf01076cd
f010147d:	e8 be eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101482:	39 f7                	cmp    %esi,%edi
f0101484:	75 19                	jne    f010149f <mem_init+0x1e5>
f0101486:	68 fd 77 10 f0       	push   $0xf01077fd
f010148b:	68 f3 76 10 f0       	push   $0xf01076f3
f0101490:	68 ed 02 00 00       	push   $0x2ed
f0101495:	68 cd 76 10 f0       	push   $0xf01076cd
f010149a:	e8 a1 eb ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010149f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014a2:	39 c6                	cmp    %eax,%esi
f01014a4:	74 04                	je     f01014aa <mem_init+0x1f0>
f01014a6:	39 c7                	cmp    %eax,%edi
f01014a8:	75 19                	jne    f01014c3 <mem_init+0x209>
f01014aa:	68 f0 6e 10 f0       	push   $0xf0106ef0
f01014af:	68 f3 76 10 f0       	push   $0xf01076f3
f01014b4:	68 ee 02 00 00       	push   $0x2ee
f01014b9:	68 cd 76 10 f0       	push   $0xf01076cd
f01014be:	e8 7d eb ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014c3:	8b 0d 90 0e 23 f0    	mov    0xf0230e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01014c9:	8b 15 88 0e 23 f0    	mov    0xf0230e88,%edx
f01014cf:	c1 e2 0c             	shl    $0xc,%edx
f01014d2:	89 f8                	mov    %edi,%eax
f01014d4:	29 c8                	sub    %ecx,%eax
f01014d6:	c1 f8 03             	sar    $0x3,%eax
f01014d9:	c1 e0 0c             	shl    $0xc,%eax
f01014dc:	39 d0                	cmp    %edx,%eax
f01014de:	72 19                	jb     f01014f9 <mem_init+0x23f>
f01014e0:	68 0f 78 10 f0       	push   $0xf010780f
f01014e5:	68 f3 76 10 f0       	push   $0xf01076f3
f01014ea:	68 ef 02 00 00       	push   $0x2ef
f01014ef:	68 cd 76 10 f0       	push   $0xf01076cd
f01014f4:	e8 47 eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01014f9:	89 f0                	mov    %esi,%eax
f01014fb:	29 c8                	sub    %ecx,%eax
f01014fd:	c1 f8 03             	sar    $0x3,%eax
f0101500:	c1 e0 0c             	shl    $0xc,%eax
f0101503:	39 c2                	cmp    %eax,%edx
f0101505:	77 19                	ja     f0101520 <mem_init+0x266>
f0101507:	68 2c 78 10 f0       	push   $0xf010782c
f010150c:	68 f3 76 10 f0       	push   $0xf01076f3
f0101511:	68 f0 02 00 00       	push   $0x2f0
f0101516:	68 cd 76 10 f0       	push   $0xf01076cd
f010151b:	e8 20 eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101520:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101523:	29 c8                	sub    %ecx,%eax
f0101525:	c1 f8 03             	sar    $0x3,%eax
f0101528:	c1 e0 0c             	shl    $0xc,%eax
f010152b:	39 c2                	cmp    %eax,%edx
f010152d:	77 19                	ja     f0101548 <mem_init+0x28e>
f010152f:	68 49 78 10 f0       	push   $0xf0107849
f0101534:	68 f3 76 10 f0       	push   $0xf01076f3
f0101539:	68 f1 02 00 00       	push   $0x2f1
f010153e:	68 cd 76 10 f0       	push   $0xf01076cd
f0101543:	e8 f8 ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101548:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f010154d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101550:	c7 05 40 02 23 f0 00 	movl   $0x0,0xf0230240
f0101557:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010155a:	83 ec 0c             	sub    $0xc,%esp
f010155d:	6a 00                	push   $0x0
f010155f:	e8 a7 f9 ff ff       	call   f0100f0b <page_alloc>
f0101564:	83 c4 10             	add    $0x10,%esp
f0101567:	85 c0                	test   %eax,%eax
f0101569:	74 19                	je     f0101584 <mem_init+0x2ca>
f010156b:	68 66 78 10 f0       	push   $0xf0107866
f0101570:	68 f3 76 10 f0       	push   $0xf01076f3
f0101575:	68 f8 02 00 00       	push   $0x2f8
f010157a:	68 cd 76 10 f0       	push   $0xf01076cd
f010157f:	e8 bc ea ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101584:	83 ec 0c             	sub    $0xc,%esp
f0101587:	57                   	push   %edi
f0101588:	e8 0d fa ff ff       	call   f0100f9a <page_free>
	page_free(pp1);
f010158d:	89 34 24             	mov    %esi,(%esp)
f0101590:	e8 05 fa ff ff       	call   f0100f9a <page_free>
	page_free(pp2);
f0101595:	83 c4 04             	add    $0x4,%esp
f0101598:	ff 75 d4             	pushl  -0x2c(%ebp)
f010159b:	e8 fa f9 ff ff       	call   f0100f9a <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015a7:	e8 5f f9 ff ff       	call   f0100f0b <page_alloc>
f01015ac:	89 c6                	mov    %eax,%esi
f01015ae:	83 c4 10             	add    $0x10,%esp
f01015b1:	85 c0                	test   %eax,%eax
f01015b3:	75 19                	jne    f01015ce <mem_init+0x314>
f01015b5:	68 bb 77 10 f0       	push   $0xf01077bb
f01015ba:	68 f3 76 10 f0       	push   $0xf01076f3
f01015bf:	68 ff 02 00 00       	push   $0x2ff
f01015c4:	68 cd 76 10 f0       	push   $0xf01076cd
f01015c9:	e8 72 ea ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01015ce:	83 ec 0c             	sub    $0xc,%esp
f01015d1:	6a 00                	push   $0x0
f01015d3:	e8 33 f9 ff ff       	call   f0100f0b <page_alloc>
f01015d8:	89 c7                	mov    %eax,%edi
f01015da:	83 c4 10             	add    $0x10,%esp
f01015dd:	85 c0                	test   %eax,%eax
f01015df:	75 19                	jne    f01015fa <mem_init+0x340>
f01015e1:	68 d1 77 10 f0       	push   $0xf01077d1
f01015e6:	68 f3 76 10 f0       	push   $0xf01076f3
f01015eb:	68 00 03 00 00       	push   $0x300
f01015f0:	68 cd 76 10 f0       	push   $0xf01076cd
f01015f5:	e8 46 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01015fa:	83 ec 0c             	sub    $0xc,%esp
f01015fd:	6a 00                	push   $0x0
f01015ff:	e8 07 f9 ff ff       	call   f0100f0b <page_alloc>
f0101604:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101607:	83 c4 10             	add    $0x10,%esp
f010160a:	85 c0                	test   %eax,%eax
f010160c:	75 19                	jne    f0101627 <mem_init+0x36d>
f010160e:	68 e7 77 10 f0       	push   $0xf01077e7
f0101613:	68 f3 76 10 f0       	push   $0xf01076f3
f0101618:	68 01 03 00 00       	push   $0x301
f010161d:	68 cd 76 10 f0       	push   $0xf01076cd
f0101622:	e8 19 ea ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101627:	39 fe                	cmp    %edi,%esi
f0101629:	75 19                	jne    f0101644 <mem_init+0x38a>
f010162b:	68 fd 77 10 f0       	push   $0xf01077fd
f0101630:	68 f3 76 10 f0       	push   $0xf01076f3
f0101635:	68 03 03 00 00       	push   $0x303
f010163a:	68 cd 76 10 f0       	push   $0xf01076cd
f010163f:	e8 fc e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101644:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101647:	39 c7                	cmp    %eax,%edi
f0101649:	74 04                	je     f010164f <mem_init+0x395>
f010164b:	39 c6                	cmp    %eax,%esi
f010164d:	75 19                	jne    f0101668 <mem_init+0x3ae>
f010164f:	68 f0 6e 10 f0       	push   $0xf0106ef0
f0101654:	68 f3 76 10 f0       	push   $0xf01076f3
f0101659:	68 04 03 00 00       	push   $0x304
f010165e:	68 cd 76 10 f0       	push   $0xf01076cd
f0101663:	e8 d8 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101668:	83 ec 0c             	sub    $0xc,%esp
f010166b:	6a 00                	push   $0x0
f010166d:	e8 99 f8 ff ff       	call   f0100f0b <page_alloc>
f0101672:	83 c4 10             	add    $0x10,%esp
f0101675:	85 c0                	test   %eax,%eax
f0101677:	74 19                	je     f0101692 <mem_init+0x3d8>
f0101679:	68 66 78 10 f0       	push   $0xf0107866
f010167e:	68 f3 76 10 f0       	push   $0xf01076f3
f0101683:	68 05 03 00 00       	push   $0x305
f0101688:	68 cd 76 10 f0       	push   $0xf01076cd
f010168d:	e8 ae e9 ff ff       	call   f0100040 <_panic>
f0101692:	89 f0                	mov    %esi,%eax
f0101694:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f010169a:	c1 f8 03             	sar    $0x3,%eax
f010169d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016a0:	89 c2                	mov    %eax,%edx
f01016a2:	c1 ea 0c             	shr    $0xc,%edx
f01016a5:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f01016ab:	72 12                	jb     f01016bf <mem_init+0x405>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016ad:	50                   	push   %eax
f01016ae:	68 c4 67 10 f0       	push   $0xf01067c4
f01016b3:	6a 58                	push   $0x58
f01016b5:	68 d9 76 10 f0       	push   $0xf01076d9
f01016ba:	e8 81 e9 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01016bf:	83 ec 04             	sub    $0x4,%esp
f01016c2:	68 00 10 00 00       	push   $0x1000
f01016c7:	6a 01                	push   $0x1
f01016c9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016ce:	50                   	push   %eax
f01016cf:	e8 0d 44 00 00       	call   f0105ae1 <memset>
	page_free(pp0);
f01016d4:	89 34 24             	mov    %esi,(%esp)
f01016d7:	e8 be f8 ff ff       	call   f0100f9a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01016e3:	e8 23 f8 ff ff       	call   f0100f0b <page_alloc>
f01016e8:	83 c4 10             	add    $0x10,%esp
f01016eb:	85 c0                	test   %eax,%eax
f01016ed:	75 19                	jne    f0101708 <mem_init+0x44e>
f01016ef:	68 75 78 10 f0       	push   $0xf0107875
f01016f4:	68 f3 76 10 f0       	push   $0xf01076f3
f01016f9:	68 0a 03 00 00       	push   $0x30a
f01016fe:	68 cd 76 10 f0       	push   $0xf01076cd
f0101703:	e8 38 e9 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101708:	39 c6                	cmp    %eax,%esi
f010170a:	74 19                	je     f0101725 <mem_init+0x46b>
f010170c:	68 93 78 10 f0       	push   $0xf0107893
f0101711:	68 f3 76 10 f0       	push   $0xf01076f3
f0101716:	68 0b 03 00 00       	push   $0x30b
f010171b:	68 cd 76 10 f0       	push   $0xf01076cd
f0101720:	e8 1b e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101725:	89 f0                	mov    %esi,%eax
f0101727:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f010172d:	c1 f8 03             	sar    $0x3,%eax
f0101730:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101733:	89 c2                	mov    %eax,%edx
f0101735:	c1 ea 0c             	shr    $0xc,%edx
f0101738:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f010173e:	72 12                	jb     f0101752 <mem_init+0x498>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101740:	50                   	push   %eax
f0101741:	68 c4 67 10 f0       	push   $0xf01067c4
f0101746:	6a 58                	push   $0x58
f0101748:	68 d9 76 10 f0       	push   $0xf01076d9
f010174d:	e8 ee e8 ff ff       	call   f0100040 <_panic>
f0101752:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101758:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010175e:	80 38 00             	cmpb   $0x0,(%eax)
f0101761:	74 19                	je     f010177c <mem_init+0x4c2>
f0101763:	68 a3 78 10 f0       	push   $0xf01078a3
f0101768:	68 f3 76 10 f0       	push   $0xf01076f3
f010176d:	68 0e 03 00 00       	push   $0x30e
f0101772:	68 cd 76 10 f0       	push   $0xf01076cd
f0101777:	e8 c4 e8 ff ff       	call   f0100040 <_panic>
f010177c:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010177f:	39 d0                	cmp    %edx,%eax
f0101781:	75 db                	jne    f010175e <mem_init+0x4a4>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101783:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101786:	a3 40 02 23 f0       	mov    %eax,0xf0230240

	// free the pages we took
	page_free(pp0);
f010178b:	83 ec 0c             	sub    $0xc,%esp
f010178e:	56                   	push   %esi
f010178f:	e8 06 f8 ff ff       	call   f0100f9a <page_free>
	page_free(pp1);
f0101794:	89 3c 24             	mov    %edi,(%esp)
f0101797:	e8 fe f7 ff ff       	call   f0100f9a <page_free>
	page_free(pp2);
f010179c:	83 c4 04             	add    $0x4,%esp
f010179f:	ff 75 d4             	pushl  -0x2c(%ebp)
f01017a2:	e8 f3 f7 ff ff       	call   f0100f9a <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017a7:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f01017ac:	83 c4 10             	add    $0x10,%esp
f01017af:	eb 05                	jmp    f01017b6 <mem_init+0x4fc>
		--nfree;
f01017b1:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017b4:	8b 00                	mov    (%eax),%eax
f01017b6:	85 c0                	test   %eax,%eax
f01017b8:	75 f7                	jne    f01017b1 <mem_init+0x4f7>
		--nfree;
	assert(nfree == 0);
f01017ba:	85 db                	test   %ebx,%ebx
f01017bc:	74 19                	je     f01017d7 <mem_init+0x51d>
f01017be:	68 ad 78 10 f0       	push   $0xf01078ad
f01017c3:	68 f3 76 10 f0       	push   $0xf01076f3
f01017c8:	68 1b 03 00 00       	push   $0x31b
f01017cd:	68 cd 76 10 f0       	push   $0xf01076cd
f01017d2:	e8 69 e8 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01017d7:	83 ec 0c             	sub    $0xc,%esp
f01017da:	68 10 6f 10 f0       	push   $0xf0106f10
f01017df:	e8 71 1e 00 00       	call   f0103655 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017eb:	e8 1b f7 ff ff       	call   f0100f0b <page_alloc>
f01017f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017f3:	83 c4 10             	add    $0x10,%esp
f01017f6:	85 c0                	test   %eax,%eax
f01017f8:	75 19                	jne    f0101813 <mem_init+0x559>
f01017fa:	68 bb 77 10 f0       	push   $0xf01077bb
f01017ff:	68 f3 76 10 f0       	push   $0xf01076f3
f0101804:	68 81 03 00 00       	push   $0x381
f0101809:	68 cd 76 10 f0       	push   $0xf01076cd
f010180e:	e8 2d e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101813:	83 ec 0c             	sub    $0xc,%esp
f0101816:	6a 00                	push   $0x0
f0101818:	e8 ee f6 ff ff       	call   f0100f0b <page_alloc>
f010181d:	89 c3                	mov    %eax,%ebx
f010181f:	83 c4 10             	add    $0x10,%esp
f0101822:	85 c0                	test   %eax,%eax
f0101824:	75 19                	jne    f010183f <mem_init+0x585>
f0101826:	68 d1 77 10 f0       	push   $0xf01077d1
f010182b:	68 f3 76 10 f0       	push   $0xf01076f3
f0101830:	68 82 03 00 00       	push   $0x382
f0101835:	68 cd 76 10 f0       	push   $0xf01076cd
f010183a:	e8 01 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010183f:	83 ec 0c             	sub    $0xc,%esp
f0101842:	6a 00                	push   $0x0
f0101844:	e8 c2 f6 ff ff       	call   f0100f0b <page_alloc>
f0101849:	89 c6                	mov    %eax,%esi
f010184b:	83 c4 10             	add    $0x10,%esp
f010184e:	85 c0                	test   %eax,%eax
f0101850:	75 19                	jne    f010186b <mem_init+0x5b1>
f0101852:	68 e7 77 10 f0       	push   $0xf01077e7
f0101857:	68 f3 76 10 f0       	push   $0xf01076f3
f010185c:	68 83 03 00 00       	push   $0x383
f0101861:	68 cd 76 10 f0       	push   $0xf01076cd
f0101866:	e8 d5 e7 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010186b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010186e:	75 19                	jne    f0101889 <mem_init+0x5cf>
f0101870:	68 fd 77 10 f0       	push   $0xf01077fd
f0101875:	68 f3 76 10 f0       	push   $0xf01076f3
f010187a:	68 86 03 00 00       	push   $0x386
f010187f:	68 cd 76 10 f0       	push   $0xf01076cd
f0101884:	e8 b7 e7 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101889:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010188c:	74 04                	je     f0101892 <mem_init+0x5d8>
f010188e:	39 c3                	cmp    %eax,%ebx
f0101890:	75 19                	jne    f01018ab <mem_init+0x5f1>
f0101892:	68 f0 6e 10 f0       	push   $0xf0106ef0
f0101897:	68 f3 76 10 f0       	push   $0xf01076f3
f010189c:	68 87 03 00 00       	push   $0x387
f01018a1:	68 cd 76 10 f0       	push   $0xf01076cd
f01018a6:	e8 95 e7 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018ab:	a1 40 02 23 f0       	mov    0xf0230240,%eax
f01018b0:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01018b3:	c7 05 40 02 23 f0 00 	movl   $0x0,0xf0230240
f01018ba:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018bd:	83 ec 0c             	sub    $0xc,%esp
f01018c0:	6a 00                	push   $0x0
f01018c2:	e8 44 f6 ff ff       	call   f0100f0b <page_alloc>
f01018c7:	83 c4 10             	add    $0x10,%esp
f01018ca:	85 c0                	test   %eax,%eax
f01018cc:	74 19                	je     f01018e7 <mem_init+0x62d>
f01018ce:	68 66 78 10 f0       	push   $0xf0107866
f01018d3:	68 f3 76 10 f0       	push   $0xf01076f3
f01018d8:	68 8e 03 00 00       	push   $0x38e
f01018dd:	68 cd 76 10 f0       	push   $0xf01076cd
f01018e2:	e8 59 e7 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018e7:	83 ec 04             	sub    $0x4,%esp
f01018ea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018ed:	50                   	push   %eax
f01018ee:	6a 00                	push   $0x0
f01018f0:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f01018f6:	e8 2f f8 ff ff       	call   f010112a <page_lookup>
f01018fb:	83 c4 10             	add    $0x10,%esp
f01018fe:	85 c0                	test   %eax,%eax
f0101900:	74 19                	je     f010191b <mem_init+0x661>
f0101902:	68 30 6f 10 f0       	push   $0xf0106f30
f0101907:	68 f3 76 10 f0       	push   $0xf01076f3
f010190c:	68 91 03 00 00       	push   $0x391
f0101911:	68 cd 76 10 f0       	push   $0xf01076cd
f0101916:	e8 25 e7 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010191b:	6a 02                	push   $0x2
f010191d:	6a 00                	push   $0x0
f010191f:	53                   	push   %ebx
f0101920:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0101926:	e8 db f8 ff ff       	call   f0101206 <page_insert>
f010192b:	83 c4 10             	add    $0x10,%esp
f010192e:	85 c0                	test   %eax,%eax
f0101930:	78 19                	js     f010194b <mem_init+0x691>
f0101932:	68 68 6f 10 f0       	push   $0xf0106f68
f0101937:	68 f3 76 10 f0       	push   $0xf01076f3
f010193c:	68 94 03 00 00       	push   $0x394
f0101941:	68 cd 76 10 f0       	push   $0xf01076cd
f0101946:	e8 f5 e6 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010194b:	83 ec 0c             	sub    $0xc,%esp
f010194e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101951:	e8 44 f6 ff ff       	call   f0100f9a <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101956:	6a 02                	push   $0x2
f0101958:	6a 00                	push   $0x0
f010195a:	53                   	push   %ebx
f010195b:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0101961:	e8 a0 f8 ff ff       	call   f0101206 <page_insert>
f0101966:	83 c4 20             	add    $0x20,%esp
f0101969:	85 c0                	test   %eax,%eax
f010196b:	74 19                	je     f0101986 <mem_init+0x6cc>
f010196d:	68 98 6f 10 f0       	push   $0xf0106f98
f0101972:	68 f3 76 10 f0       	push   $0xf01076f3
f0101977:	68 98 03 00 00       	push   $0x398
f010197c:	68 cd 76 10 f0       	push   $0xf01076cd
f0101981:	e8 ba e6 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101986:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010198c:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
f0101991:	89 c1                	mov    %eax,%ecx
f0101993:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101996:	8b 17                	mov    (%edi),%edx
f0101998:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010199e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019a1:	29 c8                	sub    %ecx,%eax
f01019a3:	c1 f8 03             	sar    $0x3,%eax
f01019a6:	c1 e0 0c             	shl    $0xc,%eax
f01019a9:	39 c2                	cmp    %eax,%edx
f01019ab:	74 19                	je     f01019c6 <mem_init+0x70c>
f01019ad:	68 c8 6f 10 f0       	push   $0xf0106fc8
f01019b2:	68 f3 76 10 f0       	push   $0xf01076f3
f01019b7:	68 99 03 00 00       	push   $0x399
f01019bc:	68 cd 76 10 f0       	push   $0xf01076cd
f01019c1:	e8 7a e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019c6:	ba 00 00 00 00       	mov    $0x0,%edx
f01019cb:	89 f8                	mov    %edi,%eax
f01019cd:	e8 16 f1 ff ff       	call   f0100ae8 <check_va2pa>
f01019d2:	89 da                	mov    %ebx,%edx
f01019d4:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01019d7:	c1 fa 03             	sar    $0x3,%edx
f01019da:	c1 e2 0c             	shl    $0xc,%edx
f01019dd:	39 d0                	cmp    %edx,%eax
f01019df:	74 19                	je     f01019fa <mem_init+0x740>
f01019e1:	68 f0 6f 10 f0       	push   $0xf0106ff0
f01019e6:	68 f3 76 10 f0       	push   $0xf01076f3
f01019eb:	68 9a 03 00 00       	push   $0x39a
f01019f0:	68 cd 76 10 f0       	push   $0xf01076cd
f01019f5:	e8 46 e6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01019fa:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019ff:	74 19                	je     f0101a1a <mem_init+0x760>
f0101a01:	68 b8 78 10 f0       	push   $0xf01078b8
f0101a06:	68 f3 76 10 f0       	push   $0xf01076f3
f0101a0b:	68 9b 03 00 00       	push   $0x39b
f0101a10:	68 cd 76 10 f0       	push   $0xf01076cd
f0101a15:	e8 26 e6 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101a1a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a1d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101a22:	74 19                	je     f0101a3d <mem_init+0x783>
f0101a24:	68 c9 78 10 f0       	push   $0xf01078c9
f0101a29:	68 f3 76 10 f0       	push   $0xf01076f3
f0101a2e:	68 9c 03 00 00       	push   $0x39c
f0101a33:	68 cd 76 10 f0       	push   $0xf01076cd
f0101a38:	e8 03 e6 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a3d:	6a 02                	push   $0x2
f0101a3f:	68 00 10 00 00       	push   $0x1000
f0101a44:	56                   	push   %esi
f0101a45:	57                   	push   %edi
f0101a46:	e8 bb f7 ff ff       	call   f0101206 <page_insert>
f0101a4b:	83 c4 10             	add    $0x10,%esp
f0101a4e:	85 c0                	test   %eax,%eax
f0101a50:	74 19                	je     f0101a6b <mem_init+0x7b1>
f0101a52:	68 20 70 10 f0       	push   $0xf0107020
f0101a57:	68 f3 76 10 f0       	push   $0xf01076f3
f0101a5c:	68 9f 03 00 00       	push   $0x39f
f0101a61:	68 cd 76 10 f0       	push   $0xf01076cd
f0101a66:	e8 d5 e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a6b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a70:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101a75:	e8 6e f0 ff ff       	call   f0100ae8 <check_va2pa>
f0101a7a:	89 f2                	mov    %esi,%edx
f0101a7c:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0101a82:	c1 fa 03             	sar    $0x3,%edx
f0101a85:	c1 e2 0c             	shl    $0xc,%edx
f0101a88:	39 d0                	cmp    %edx,%eax
f0101a8a:	74 19                	je     f0101aa5 <mem_init+0x7eb>
f0101a8c:	68 5c 70 10 f0       	push   $0xf010705c
f0101a91:	68 f3 76 10 f0       	push   $0xf01076f3
f0101a96:	68 a0 03 00 00       	push   $0x3a0
f0101a9b:	68 cd 76 10 f0       	push   $0xf01076cd
f0101aa0:	e8 9b e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101aa5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101aaa:	74 19                	je     f0101ac5 <mem_init+0x80b>
f0101aac:	68 da 78 10 f0       	push   $0xf01078da
f0101ab1:	68 f3 76 10 f0       	push   $0xf01076f3
f0101ab6:	68 a1 03 00 00       	push   $0x3a1
f0101abb:	68 cd 76 10 f0       	push   $0xf01076cd
f0101ac0:	e8 7b e5 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ac5:	83 ec 0c             	sub    $0xc,%esp
f0101ac8:	6a 00                	push   $0x0
f0101aca:	e8 3c f4 ff ff       	call   f0100f0b <page_alloc>
f0101acf:	83 c4 10             	add    $0x10,%esp
f0101ad2:	85 c0                	test   %eax,%eax
f0101ad4:	74 19                	je     f0101aef <mem_init+0x835>
f0101ad6:	68 66 78 10 f0       	push   $0xf0107866
f0101adb:	68 f3 76 10 f0       	push   $0xf01076f3
f0101ae0:	68 a4 03 00 00       	push   $0x3a4
f0101ae5:	68 cd 76 10 f0       	push   $0xf01076cd
f0101aea:	e8 51 e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101aef:	6a 02                	push   $0x2
f0101af1:	68 00 10 00 00       	push   $0x1000
f0101af6:	56                   	push   %esi
f0101af7:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0101afd:	e8 04 f7 ff ff       	call   f0101206 <page_insert>
f0101b02:	83 c4 10             	add    $0x10,%esp
f0101b05:	85 c0                	test   %eax,%eax
f0101b07:	74 19                	je     f0101b22 <mem_init+0x868>
f0101b09:	68 20 70 10 f0       	push   $0xf0107020
f0101b0e:	68 f3 76 10 f0       	push   $0xf01076f3
f0101b13:	68 a7 03 00 00       	push   $0x3a7
f0101b18:	68 cd 76 10 f0       	push   $0xf01076cd
f0101b1d:	e8 1e e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b22:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b27:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101b2c:	e8 b7 ef ff ff       	call   f0100ae8 <check_va2pa>
f0101b31:	89 f2                	mov    %esi,%edx
f0101b33:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0101b39:	c1 fa 03             	sar    $0x3,%edx
f0101b3c:	c1 e2 0c             	shl    $0xc,%edx
f0101b3f:	39 d0                	cmp    %edx,%eax
f0101b41:	74 19                	je     f0101b5c <mem_init+0x8a2>
f0101b43:	68 5c 70 10 f0       	push   $0xf010705c
f0101b48:	68 f3 76 10 f0       	push   $0xf01076f3
f0101b4d:	68 a8 03 00 00       	push   $0x3a8
f0101b52:	68 cd 76 10 f0       	push   $0xf01076cd
f0101b57:	e8 e4 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b5c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b61:	74 19                	je     f0101b7c <mem_init+0x8c2>
f0101b63:	68 da 78 10 f0       	push   $0xf01078da
f0101b68:	68 f3 76 10 f0       	push   $0xf01076f3
f0101b6d:	68 a9 03 00 00       	push   $0x3a9
f0101b72:	68 cd 76 10 f0       	push   $0xf01076cd
f0101b77:	e8 c4 e4 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b7c:	83 ec 0c             	sub    $0xc,%esp
f0101b7f:	6a 00                	push   $0x0
f0101b81:	e8 85 f3 ff ff       	call   f0100f0b <page_alloc>
f0101b86:	83 c4 10             	add    $0x10,%esp
f0101b89:	85 c0                	test   %eax,%eax
f0101b8b:	74 19                	je     f0101ba6 <mem_init+0x8ec>
f0101b8d:	68 66 78 10 f0       	push   $0xf0107866
f0101b92:	68 f3 76 10 f0       	push   $0xf01076f3
f0101b97:	68 ad 03 00 00       	push   $0x3ad
f0101b9c:	68 cd 76 10 f0       	push   $0xf01076cd
f0101ba1:	e8 9a e4 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ba6:	8b 15 8c 0e 23 f0    	mov    0xf0230e8c,%edx
f0101bac:	8b 02                	mov    (%edx),%eax
f0101bae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101bb3:	89 c1                	mov    %eax,%ecx
f0101bb5:	c1 e9 0c             	shr    $0xc,%ecx
f0101bb8:	3b 0d 88 0e 23 f0    	cmp    0xf0230e88,%ecx
f0101bbe:	72 15                	jb     f0101bd5 <mem_init+0x91b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101bc0:	50                   	push   %eax
f0101bc1:	68 c4 67 10 f0       	push   $0xf01067c4
f0101bc6:	68 b0 03 00 00       	push   $0x3b0
f0101bcb:	68 cd 76 10 f0       	push   $0xf01076cd
f0101bd0:	e8 6b e4 ff ff       	call   f0100040 <_panic>
f0101bd5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101bda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101bdd:	83 ec 04             	sub    $0x4,%esp
f0101be0:	6a 00                	push   $0x0
f0101be2:	68 00 10 00 00       	push   $0x1000
f0101be7:	52                   	push   %edx
f0101be8:	e8 26 f4 ff ff       	call   f0101013 <pgdir_walk>
f0101bed:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101bf0:	8d 51 04             	lea    0x4(%ecx),%edx
f0101bf3:	83 c4 10             	add    $0x10,%esp
f0101bf6:	39 d0                	cmp    %edx,%eax
f0101bf8:	74 19                	je     f0101c13 <mem_init+0x959>
f0101bfa:	68 8c 70 10 f0       	push   $0xf010708c
f0101bff:	68 f3 76 10 f0       	push   $0xf01076f3
f0101c04:	68 b1 03 00 00       	push   $0x3b1
f0101c09:	68 cd 76 10 f0       	push   $0xf01076cd
f0101c0e:	e8 2d e4 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c13:	6a 06                	push   $0x6
f0101c15:	68 00 10 00 00       	push   $0x1000
f0101c1a:	56                   	push   %esi
f0101c1b:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0101c21:	e8 e0 f5 ff ff       	call   f0101206 <page_insert>
f0101c26:	83 c4 10             	add    $0x10,%esp
f0101c29:	85 c0                	test   %eax,%eax
f0101c2b:	74 19                	je     f0101c46 <mem_init+0x98c>
f0101c2d:	68 cc 70 10 f0       	push   $0xf01070cc
f0101c32:	68 f3 76 10 f0       	push   $0xf01076f3
f0101c37:	68 b4 03 00 00       	push   $0x3b4
f0101c3c:	68 cd 76 10 f0       	push   $0xf01076cd
f0101c41:	e8 fa e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c46:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f0101c4c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c51:	89 f8                	mov    %edi,%eax
f0101c53:	e8 90 ee ff ff       	call   f0100ae8 <check_va2pa>
f0101c58:	89 f2                	mov    %esi,%edx
f0101c5a:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0101c60:	c1 fa 03             	sar    $0x3,%edx
f0101c63:	c1 e2 0c             	shl    $0xc,%edx
f0101c66:	39 d0                	cmp    %edx,%eax
f0101c68:	74 19                	je     f0101c83 <mem_init+0x9c9>
f0101c6a:	68 5c 70 10 f0       	push   $0xf010705c
f0101c6f:	68 f3 76 10 f0       	push   $0xf01076f3
f0101c74:	68 b5 03 00 00       	push   $0x3b5
f0101c79:	68 cd 76 10 f0       	push   $0xf01076cd
f0101c7e:	e8 bd e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101c83:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c88:	74 19                	je     f0101ca3 <mem_init+0x9e9>
f0101c8a:	68 da 78 10 f0       	push   $0xf01078da
f0101c8f:	68 f3 76 10 f0       	push   $0xf01076f3
f0101c94:	68 b6 03 00 00       	push   $0x3b6
f0101c99:	68 cd 76 10 f0       	push   $0xf01076cd
f0101c9e:	e8 9d e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ca3:	83 ec 04             	sub    $0x4,%esp
f0101ca6:	6a 00                	push   $0x0
f0101ca8:	68 00 10 00 00       	push   $0x1000
f0101cad:	57                   	push   %edi
f0101cae:	e8 60 f3 ff ff       	call   f0101013 <pgdir_walk>
f0101cb3:	83 c4 10             	add    $0x10,%esp
f0101cb6:	f6 00 04             	testb  $0x4,(%eax)
f0101cb9:	75 19                	jne    f0101cd4 <mem_init+0xa1a>
f0101cbb:	68 0c 71 10 f0       	push   $0xf010710c
f0101cc0:	68 f3 76 10 f0       	push   $0xf01076f3
f0101cc5:	68 b7 03 00 00       	push   $0x3b7
f0101cca:	68 cd 76 10 f0       	push   $0xf01076cd
f0101ccf:	e8 6c e3 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101cd4:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0101cd9:	f6 00 04             	testb  $0x4,(%eax)
f0101cdc:	75 19                	jne    f0101cf7 <mem_init+0xa3d>
f0101cde:	68 eb 78 10 f0       	push   $0xf01078eb
f0101ce3:	68 f3 76 10 f0       	push   $0xf01076f3
f0101ce8:	68 b8 03 00 00       	push   $0x3b8
f0101ced:	68 cd 76 10 f0       	push   $0xf01076cd
f0101cf2:	e8 49 e3 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cf7:	6a 02                	push   $0x2
f0101cf9:	68 00 10 00 00       	push   $0x1000
f0101cfe:	56                   	push   %esi
f0101cff:	50                   	push   %eax
f0101d00:	e8 01 f5 ff ff       	call   f0101206 <page_insert>
f0101d05:	83 c4 10             	add    $0x10,%esp
f0101d08:	85 c0                	test   %eax,%eax
f0101d0a:	74 19                	je     f0101d25 <mem_init+0xa6b>
f0101d0c:	68 20 70 10 f0       	push   $0xf0107020
f0101d11:	68 f3 76 10 f0       	push   $0xf01076f3
f0101d16:	68 bb 03 00 00       	push   $0x3bb
f0101d1b:	68 cd 76 10 f0       	push   $0xf01076cd
f0101d20:	e8 1b e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101d25:	83 ec 04             	sub    $0x4,%esp
f0101d28:	6a 00                	push   $0x0
f0101d2a:	68 00 10 00 00       	push   $0x1000
f0101d2f:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0101d35:	e8 d9 f2 ff ff       	call   f0101013 <pgdir_walk>
f0101d3a:	83 c4 10             	add    $0x10,%esp
f0101d3d:	f6 00 02             	testb  $0x2,(%eax)
f0101d40:	75 19                	jne    f0101d5b <mem_init+0xaa1>
f0101d42:	68 40 71 10 f0       	push   $0xf0107140
f0101d47:	68 f3 76 10 f0       	push   $0xf01076f3
f0101d4c:	68 bc 03 00 00       	push   $0x3bc
f0101d51:	68 cd 76 10 f0       	push   $0xf01076cd
f0101d56:	e8 e5 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d5b:	83 ec 04             	sub    $0x4,%esp
f0101d5e:	6a 00                	push   $0x0
f0101d60:	68 00 10 00 00       	push   $0x1000
f0101d65:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0101d6b:	e8 a3 f2 ff ff       	call   f0101013 <pgdir_walk>
f0101d70:	83 c4 10             	add    $0x10,%esp
f0101d73:	f6 00 04             	testb  $0x4,(%eax)
f0101d76:	74 19                	je     f0101d91 <mem_init+0xad7>
f0101d78:	68 74 71 10 f0       	push   $0xf0107174
f0101d7d:	68 f3 76 10 f0       	push   $0xf01076f3
f0101d82:	68 bd 03 00 00       	push   $0x3bd
f0101d87:	68 cd 76 10 f0       	push   $0xf01076cd
f0101d8c:	e8 af e2 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101d91:	6a 02                	push   $0x2
f0101d93:	68 00 00 40 00       	push   $0x400000
f0101d98:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d9b:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0101da1:	e8 60 f4 ff ff       	call   f0101206 <page_insert>
f0101da6:	83 c4 10             	add    $0x10,%esp
f0101da9:	85 c0                	test   %eax,%eax
f0101dab:	78 19                	js     f0101dc6 <mem_init+0xb0c>
f0101dad:	68 ac 71 10 f0       	push   $0xf01071ac
f0101db2:	68 f3 76 10 f0       	push   $0xf01076f3
f0101db7:	68 c0 03 00 00       	push   $0x3c0
f0101dbc:	68 cd 76 10 f0       	push   $0xf01076cd
f0101dc1:	e8 7a e2 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101dc6:	6a 02                	push   $0x2
f0101dc8:	68 00 10 00 00       	push   $0x1000
f0101dcd:	53                   	push   %ebx
f0101dce:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0101dd4:	e8 2d f4 ff ff       	call   f0101206 <page_insert>
f0101dd9:	83 c4 10             	add    $0x10,%esp
f0101ddc:	85 c0                	test   %eax,%eax
f0101dde:	74 19                	je     f0101df9 <mem_init+0xb3f>
f0101de0:	68 e4 71 10 f0       	push   $0xf01071e4
f0101de5:	68 f3 76 10 f0       	push   $0xf01076f3
f0101dea:	68 c3 03 00 00       	push   $0x3c3
f0101def:	68 cd 76 10 f0       	push   $0xf01076cd
f0101df4:	e8 47 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101df9:	83 ec 04             	sub    $0x4,%esp
f0101dfc:	6a 00                	push   $0x0
f0101dfe:	68 00 10 00 00       	push   $0x1000
f0101e03:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0101e09:	e8 05 f2 ff ff       	call   f0101013 <pgdir_walk>
f0101e0e:	83 c4 10             	add    $0x10,%esp
f0101e11:	f6 00 04             	testb  $0x4,(%eax)
f0101e14:	74 19                	je     f0101e2f <mem_init+0xb75>
f0101e16:	68 74 71 10 f0       	push   $0xf0107174
f0101e1b:	68 f3 76 10 f0       	push   $0xf01076f3
f0101e20:	68 c4 03 00 00       	push   $0x3c4
f0101e25:	68 cd 76 10 f0       	push   $0xf01076cd
f0101e2a:	e8 11 e2 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101e2f:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f0101e35:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e3a:	89 f8                	mov    %edi,%eax
f0101e3c:	e8 a7 ec ff ff       	call   f0100ae8 <check_va2pa>
f0101e41:	89 c1                	mov    %eax,%ecx
f0101e43:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101e46:	89 d8                	mov    %ebx,%eax
f0101e48:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0101e4e:	c1 f8 03             	sar    $0x3,%eax
f0101e51:	c1 e0 0c             	shl    $0xc,%eax
f0101e54:	39 c1                	cmp    %eax,%ecx
f0101e56:	74 19                	je     f0101e71 <mem_init+0xbb7>
f0101e58:	68 20 72 10 f0       	push   $0xf0107220
f0101e5d:	68 f3 76 10 f0       	push   $0xf01076f3
f0101e62:	68 c7 03 00 00       	push   $0x3c7
f0101e67:	68 cd 76 10 f0       	push   $0xf01076cd
f0101e6c:	e8 cf e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e71:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e76:	89 f8                	mov    %edi,%eax
f0101e78:	e8 6b ec ff ff       	call   f0100ae8 <check_va2pa>
f0101e7d:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101e80:	74 19                	je     f0101e9b <mem_init+0xbe1>
f0101e82:	68 4c 72 10 f0       	push   $0xf010724c
f0101e87:	68 f3 76 10 f0       	push   $0xf01076f3
f0101e8c:	68 c8 03 00 00       	push   $0x3c8
f0101e91:	68 cd 76 10 f0       	push   $0xf01076cd
f0101e96:	e8 a5 e1 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e9b:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101ea0:	74 19                	je     f0101ebb <mem_init+0xc01>
f0101ea2:	68 01 79 10 f0       	push   $0xf0107901
f0101ea7:	68 f3 76 10 f0       	push   $0xf01076f3
f0101eac:	68 ca 03 00 00       	push   $0x3ca
f0101eb1:	68 cd 76 10 f0       	push   $0xf01076cd
f0101eb6:	e8 85 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101ebb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ec0:	74 19                	je     f0101edb <mem_init+0xc21>
f0101ec2:	68 12 79 10 f0       	push   $0xf0107912
f0101ec7:	68 f3 76 10 f0       	push   $0xf01076f3
f0101ecc:	68 cb 03 00 00       	push   $0x3cb
f0101ed1:	68 cd 76 10 f0       	push   $0xf01076cd
f0101ed6:	e8 65 e1 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101edb:	83 ec 0c             	sub    $0xc,%esp
f0101ede:	6a 00                	push   $0x0
f0101ee0:	e8 26 f0 ff ff       	call   f0100f0b <page_alloc>
f0101ee5:	83 c4 10             	add    $0x10,%esp
f0101ee8:	39 c6                	cmp    %eax,%esi
f0101eea:	75 04                	jne    f0101ef0 <mem_init+0xc36>
f0101eec:	85 c0                	test   %eax,%eax
f0101eee:	75 19                	jne    f0101f09 <mem_init+0xc4f>
f0101ef0:	68 7c 72 10 f0       	push   $0xf010727c
f0101ef5:	68 f3 76 10 f0       	push   $0xf01076f3
f0101efa:	68 ce 03 00 00       	push   $0x3ce
f0101eff:	68 cd 76 10 f0       	push   $0xf01076cd
f0101f04:	e8 37 e1 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101f09:	83 ec 08             	sub    $0x8,%esp
f0101f0c:	6a 00                	push   $0x0
f0101f0e:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0101f14:	e8 a0 f2 ff ff       	call   f01011b9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f19:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f0101f1f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f24:	89 f8                	mov    %edi,%eax
f0101f26:	e8 bd eb ff ff       	call   f0100ae8 <check_va2pa>
f0101f2b:	83 c4 10             	add    $0x10,%esp
f0101f2e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f31:	74 19                	je     f0101f4c <mem_init+0xc92>
f0101f33:	68 a0 72 10 f0       	push   $0xf01072a0
f0101f38:	68 f3 76 10 f0       	push   $0xf01076f3
f0101f3d:	68 d2 03 00 00       	push   $0x3d2
f0101f42:	68 cd 76 10 f0       	push   $0xf01076cd
f0101f47:	e8 f4 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f4c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f51:	89 f8                	mov    %edi,%eax
f0101f53:	e8 90 eb ff ff       	call   f0100ae8 <check_va2pa>
f0101f58:	89 da                	mov    %ebx,%edx
f0101f5a:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0101f60:	c1 fa 03             	sar    $0x3,%edx
f0101f63:	c1 e2 0c             	shl    $0xc,%edx
f0101f66:	39 d0                	cmp    %edx,%eax
f0101f68:	74 19                	je     f0101f83 <mem_init+0xcc9>
f0101f6a:	68 4c 72 10 f0       	push   $0xf010724c
f0101f6f:	68 f3 76 10 f0       	push   $0xf01076f3
f0101f74:	68 d3 03 00 00       	push   $0x3d3
f0101f79:	68 cd 76 10 f0       	push   $0xf01076cd
f0101f7e:	e8 bd e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101f83:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f88:	74 19                	je     f0101fa3 <mem_init+0xce9>
f0101f8a:	68 b8 78 10 f0       	push   $0xf01078b8
f0101f8f:	68 f3 76 10 f0       	push   $0xf01076f3
f0101f94:	68 d4 03 00 00       	push   $0x3d4
f0101f99:	68 cd 76 10 f0       	push   $0xf01076cd
f0101f9e:	e8 9d e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101fa3:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fa8:	74 19                	je     f0101fc3 <mem_init+0xd09>
f0101faa:	68 12 79 10 f0       	push   $0xf0107912
f0101faf:	68 f3 76 10 f0       	push   $0xf01076f3
f0101fb4:	68 d5 03 00 00       	push   $0x3d5
f0101fb9:	68 cd 76 10 f0       	push   $0xf01076cd
f0101fbe:	e8 7d e0 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101fc3:	6a 00                	push   $0x0
f0101fc5:	68 00 10 00 00       	push   $0x1000
f0101fca:	53                   	push   %ebx
f0101fcb:	57                   	push   %edi
f0101fcc:	e8 35 f2 ff ff       	call   f0101206 <page_insert>
f0101fd1:	83 c4 10             	add    $0x10,%esp
f0101fd4:	85 c0                	test   %eax,%eax
f0101fd6:	74 19                	je     f0101ff1 <mem_init+0xd37>
f0101fd8:	68 c4 72 10 f0       	push   $0xf01072c4
f0101fdd:	68 f3 76 10 f0       	push   $0xf01076f3
f0101fe2:	68 d8 03 00 00       	push   $0x3d8
f0101fe7:	68 cd 76 10 f0       	push   $0xf01076cd
f0101fec:	e8 4f e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0101ff1:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ff6:	75 19                	jne    f0102011 <mem_init+0xd57>
f0101ff8:	68 23 79 10 f0       	push   $0xf0107923
f0101ffd:	68 f3 76 10 f0       	push   $0xf01076f3
f0102002:	68 d9 03 00 00       	push   $0x3d9
f0102007:	68 cd 76 10 f0       	push   $0xf01076cd
f010200c:	e8 2f e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102011:	83 3b 00             	cmpl   $0x0,(%ebx)
f0102014:	74 19                	je     f010202f <mem_init+0xd75>
f0102016:	68 2f 79 10 f0       	push   $0xf010792f
f010201b:	68 f3 76 10 f0       	push   $0xf01076f3
f0102020:	68 da 03 00 00       	push   $0x3da
f0102025:	68 cd 76 10 f0       	push   $0xf01076cd
f010202a:	e8 11 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010202f:	83 ec 08             	sub    $0x8,%esp
f0102032:	68 00 10 00 00       	push   $0x1000
f0102037:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f010203d:	e8 77 f1 ff ff       	call   f01011b9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102042:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f0102048:	ba 00 00 00 00       	mov    $0x0,%edx
f010204d:	89 f8                	mov    %edi,%eax
f010204f:	e8 94 ea ff ff       	call   f0100ae8 <check_va2pa>
f0102054:	83 c4 10             	add    $0x10,%esp
f0102057:	83 f8 ff             	cmp    $0xffffffff,%eax
f010205a:	74 19                	je     f0102075 <mem_init+0xdbb>
f010205c:	68 a0 72 10 f0       	push   $0xf01072a0
f0102061:	68 f3 76 10 f0       	push   $0xf01076f3
f0102066:	68 de 03 00 00       	push   $0x3de
f010206b:	68 cd 76 10 f0       	push   $0xf01076cd
f0102070:	e8 cb df ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102075:	ba 00 10 00 00       	mov    $0x1000,%edx
f010207a:	89 f8                	mov    %edi,%eax
f010207c:	e8 67 ea ff ff       	call   f0100ae8 <check_va2pa>
f0102081:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102084:	74 19                	je     f010209f <mem_init+0xde5>
f0102086:	68 fc 72 10 f0       	push   $0xf01072fc
f010208b:	68 f3 76 10 f0       	push   $0xf01076f3
f0102090:	68 df 03 00 00       	push   $0x3df
f0102095:	68 cd 76 10 f0       	push   $0xf01076cd
f010209a:	e8 a1 df ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010209f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020a4:	74 19                	je     f01020bf <mem_init+0xe05>
f01020a6:	68 44 79 10 f0       	push   $0xf0107944
f01020ab:	68 f3 76 10 f0       	push   $0xf01076f3
f01020b0:	68 e0 03 00 00       	push   $0x3e0
f01020b5:	68 cd 76 10 f0       	push   $0xf01076cd
f01020ba:	e8 81 df ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01020bf:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01020c4:	74 19                	je     f01020df <mem_init+0xe25>
f01020c6:	68 12 79 10 f0       	push   $0xf0107912
f01020cb:	68 f3 76 10 f0       	push   $0xf01076f3
f01020d0:	68 e1 03 00 00       	push   $0x3e1
f01020d5:	68 cd 76 10 f0       	push   $0xf01076cd
f01020da:	e8 61 df ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01020df:	83 ec 0c             	sub    $0xc,%esp
f01020e2:	6a 00                	push   $0x0
f01020e4:	e8 22 ee ff ff       	call   f0100f0b <page_alloc>
f01020e9:	83 c4 10             	add    $0x10,%esp
f01020ec:	85 c0                	test   %eax,%eax
f01020ee:	74 04                	je     f01020f4 <mem_init+0xe3a>
f01020f0:	39 c3                	cmp    %eax,%ebx
f01020f2:	74 19                	je     f010210d <mem_init+0xe53>
f01020f4:	68 24 73 10 f0       	push   $0xf0107324
f01020f9:	68 f3 76 10 f0       	push   $0xf01076f3
f01020fe:	68 e4 03 00 00       	push   $0x3e4
f0102103:	68 cd 76 10 f0       	push   $0xf01076cd
f0102108:	e8 33 df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010210d:	83 ec 0c             	sub    $0xc,%esp
f0102110:	6a 00                	push   $0x0
f0102112:	e8 f4 ed ff ff       	call   f0100f0b <page_alloc>
f0102117:	83 c4 10             	add    $0x10,%esp
f010211a:	85 c0                	test   %eax,%eax
f010211c:	74 19                	je     f0102137 <mem_init+0xe7d>
f010211e:	68 66 78 10 f0       	push   $0xf0107866
f0102123:	68 f3 76 10 f0       	push   $0xf01076f3
f0102128:	68 e7 03 00 00       	push   $0x3e7
f010212d:	68 cd 76 10 f0       	push   $0xf01076cd
f0102132:	e8 09 df ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102137:	8b 0d 8c 0e 23 f0    	mov    0xf0230e8c,%ecx
f010213d:	8b 11                	mov    (%ecx),%edx
f010213f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102145:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102148:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f010214e:	c1 f8 03             	sar    $0x3,%eax
f0102151:	c1 e0 0c             	shl    $0xc,%eax
f0102154:	39 c2                	cmp    %eax,%edx
f0102156:	74 19                	je     f0102171 <mem_init+0xeb7>
f0102158:	68 c8 6f 10 f0       	push   $0xf0106fc8
f010215d:	68 f3 76 10 f0       	push   $0xf01076f3
f0102162:	68 ea 03 00 00       	push   $0x3ea
f0102167:	68 cd 76 10 f0       	push   $0xf01076cd
f010216c:	e8 cf de ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102171:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102177:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010217a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010217f:	74 19                	je     f010219a <mem_init+0xee0>
f0102181:	68 c9 78 10 f0       	push   $0xf01078c9
f0102186:	68 f3 76 10 f0       	push   $0xf01076f3
f010218b:	68 ec 03 00 00       	push   $0x3ec
f0102190:	68 cd 76 10 f0       	push   $0xf01076cd
f0102195:	e8 a6 de ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010219a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010219d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01021a3:	83 ec 0c             	sub    $0xc,%esp
f01021a6:	50                   	push   %eax
f01021a7:	e8 ee ed ff ff       	call   f0100f9a <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01021ac:	83 c4 0c             	add    $0xc,%esp
f01021af:	6a 01                	push   $0x1
f01021b1:	68 00 10 40 00       	push   $0x401000
f01021b6:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f01021bc:	e8 52 ee ff ff       	call   f0101013 <pgdir_walk>
f01021c1:	89 c7                	mov    %eax,%edi
f01021c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01021c6:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01021cb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01021ce:	8b 40 04             	mov    0x4(%eax),%eax
f01021d1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021d6:	8b 0d 88 0e 23 f0    	mov    0xf0230e88,%ecx
f01021dc:	89 c2                	mov    %eax,%edx
f01021de:	c1 ea 0c             	shr    $0xc,%edx
f01021e1:	83 c4 10             	add    $0x10,%esp
f01021e4:	39 ca                	cmp    %ecx,%edx
f01021e6:	72 15                	jb     f01021fd <mem_init+0xf43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021e8:	50                   	push   %eax
f01021e9:	68 c4 67 10 f0       	push   $0xf01067c4
f01021ee:	68 f3 03 00 00       	push   $0x3f3
f01021f3:	68 cd 76 10 f0       	push   $0xf01076cd
f01021f8:	e8 43 de ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01021fd:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102202:	39 c7                	cmp    %eax,%edi
f0102204:	74 19                	je     f010221f <mem_init+0xf65>
f0102206:	68 55 79 10 f0       	push   $0xf0107955
f010220b:	68 f3 76 10 f0       	push   $0xf01076f3
f0102210:	68 f4 03 00 00       	push   $0x3f4
f0102215:	68 cd 76 10 f0       	push   $0xf01076cd
f010221a:	e8 21 de ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010221f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102222:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102229:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010222c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102232:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0102238:	c1 f8 03             	sar    $0x3,%eax
f010223b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010223e:	89 c2                	mov    %eax,%edx
f0102240:	c1 ea 0c             	shr    $0xc,%edx
f0102243:	39 d1                	cmp    %edx,%ecx
f0102245:	77 12                	ja     f0102259 <mem_init+0xf9f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102247:	50                   	push   %eax
f0102248:	68 c4 67 10 f0       	push   $0xf01067c4
f010224d:	6a 58                	push   $0x58
f010224f:	68 d9 76 10 f0       	push   $0xf01076d9
f0102254:	e8 e7 dd ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102259:	83 ec 04             	sub    $0x4,%esp
f010225c:	68 00 10 00 00       	push   $0x1000
f0102261:	68 ff 00 00 00       	push   $0xff
f0102266:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010226b:	50                   	push   %eax
f010226c:	e8 70 38 00 00       	call   f0105ae1 <memset>
	page_free(pp0);
f0102271:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102274:	89 3c 24             	mov    %edi,(%esp)
f0102277:	e8 1e ed ff ff       	call   f0100f9a <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010227c:	83 c4 0c             	add    $0xc,%esp
f010227f:	6a 01                	push   $0x1
f0102281:	6a 00                	push   $0x0
f0102283:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0102289:	e8 85 ed ff ff       	call   f0101013 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010228e:	89 fa                	mov    %edi,%edx
f0102290:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0102296:	c1 fa 03             	sar    $0x3,%edx
f0102299:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010229c:	89 d0                	mov    %edx,%eax
f010229e:	c1 e8 0c             	shr    $0xc,%eax
f01022a1:	83 c4 10             	add    $0x10,%esp
f01022a4:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f01022aa:	72 12                	jb     f01022be <mem_init+0x1004>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01022ac:	52                   	push   %edx
f01022ad:	68 c4 67 10 f0       	push   $0xf01067c4
f01022b2:	6a 58                	push   $0x58
f01022b4:	68 d9 76 10 f0       	push   $0xf01076d9
f01022b9:	e8 82 dd ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01022be:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01022c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01022c7:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01022cd:	f6 00 01             	testb  $0x1,(%eax)
f01022d0:	74 19                	je     f01022eb <mem_init+0x1031>
f01022d2:	68 6d 79 10 f0       	push   $0xf010796d
f01022d7:	68 f3 76 10 f0       	push   $0xf01076f3
f01022dc:	68 fe 03 00 00       	push   $0x3fe
f01022e1:	68 cd 76 10 f0       	push   $0xf01076cd
f01022e6:	e8 55 dd ff ff       	call   f0100040 <_panic>
f01022eb:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01022ee:	39 d0                	cmp    %edx,%eax
f01022f0:	75 db                	jne    f01022cd <mem_init+0x1013>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01022f2:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01022f7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01022fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102300:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102306:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102309:	89 0d 40 02 23 f0    	mov    %ecx,0xf0230240

	// free the pages we took
	page_free(pp0);
f010230f:	83 ec 0c             	sub    $0xc,%esp
f0102312:	50                   	push   %eax
f0102313:	e8 82 ec ff ff       	call   f0100f9a <page_free>
	page_free(pp1);
f0102318:	89 1c 24             	mov    %ebx,(%esp)
f010231b:	e8 7a ec ff ff       	call   f0100f9a <page_free>
	page_free(pp2);
f0102320:	89 34 24             	mov    %esi,(%esp)
f0102323:	e8 72 ec ff ff       	call   f0100f9a <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102328:	83 c4 08             	add    $0x8,%esp
f010232b:	68 01 10 00 00       	push   $0x1001
f0102330:	6a 00                	push   $0x0
f0102332:	e8 44 ef ff ff       	call   f010127b <mmio_map_region>
f0102337:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102339:	83 c4 08             	add    $0x8,%esp
f010233c:	68 00 10 00 00       	push   $0x1000
f0102341:	6a 00                	push   $0x0
f0102343:	e8 33 ef ff ff       	call   f010127b <mmio_map_region>
f0102348:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010234a:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102350:	83 c4 10             	add    $0x10,%esp
f0102353:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102359:	76 07                	jbe    f0102362 <mem_init+0x10a8>
f010235b:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102360:	76 19                	jbe    f010237b <mem_init+0x10c1>
f0102362:	68 48 73 10 f0       	push   $0xf0107348
f0102367:	68 f3 76 10 f0       	push   $0xf01076f3
f010236c:	68 0e 04 00 00       	push   $0x40e
f0102371:	68 cd 76 10 f0       	push   $0xf01076cd
f0102376:	e8 c5 dc ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f010237b:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f0102381:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102387:	77 08                	ja     f0102391 <mem_init+0x10d7>
f0102389:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010238f:	77 19                	ja     f01023aa <mem_init+0x10f0>
f0102391:	68 70 73 10 f0       	push   $0xf0107370
f0102396:	68 f3 76 10 f0       	push   $0xf01076f3
f010239b:	68 0f 04 00 00       	push   $0x40f
f01023a0:	68 cd 76 10 f0       	push   $0xf01076cd
f01023a5:	e8 96 dc ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01023aa:	89 da                	mov    %ebx,%edx
f01023ac:	09 f2                	or     %esi,%edx
f01023ae:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01023b4:	74 19                	je     f01023cf <mem_init+0x1115>
f01023b6:	68 98 73 10 f0       	push   $0xf0107398
f01023bb:	68 f3 76 10 f0       	push   $0xf01076f3
f01023c0:	68 11 04 00 00       	push   $0x411
f01023c5:	68 cd 76 10 f0       	push   $0xf01076cd
f01023ca:	e8 71 dc ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01023cf:	39 c6                	cmp    %eax,%esi
f01023d1:	73 19                	jae    f01023ec <mem_init+0x1132>
f01023d3:	68 84 79 10 f0       	push   $0xf0107984
f01023d8:	68 f3 76 10 f0       	push   $0xf01076f3
f01023dd:	68 13 04 00 00       	push   $0x413
f01023e2:	68 cd 76 10 f0       	push   $0xf01076cd
f01023e7:	e8 54 dc ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01023ec:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi
f01023f2:	89 da                	mov    %ebx,%edx
f01023f4:	89 f8                	mov    %edi,%eax
f01023f6:	e8 ed e6 ff ff       	call   f0100ae8 <check_va2pa>
f01023fb:	85 c0                	test   %eax,%eax
f01023fd:	74 19                	je     f0102418 <mem_init+0x115e>
f01023ff:	68 c0 73 10 f0       	push   $0xf01073c0
f0102404:	68 f3 76 10 f0       	push   $0xf01076f3
f0102409:	68 15 04 00 00       	push   $0x415
f010240e:	68 cd 76 10 f0       	push   $0xf01076cd
f0102413:	e8 28 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102418:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010241e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102421:	89 c2                	mov    %eax,%edx
f0102423:	89 f8                	mov    %edi,%eax
f0102425:	e8 be e6 ff ff       	call   f0100ae8 <check_va2pa>
f010242a:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010242f:	74 19                	je     f010244a <mem_init+0x1190>
f0102431:	68 e4 73 10 f0       	push   $0xf01073e4
f0102436:	68 f3 76 10 f0       	push   $0xf01076f3
f010243b:	68 16 04 00 00       	push   $0x416
f0102440:	68 cd 76 10 f0       	push   $0xf01076cd
f0102445:	e8 f6 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010244a:	89 f2                	mov    %esi,%edx
f010244c:	89 f8                	mov    %edi,%eax
f010244e:	e8 95 e6 ff ff       	call   f0100ae8 <check_va2pa>
f0102453:	85 c0                	test   %eax,%eax
f0102455:	74 19                	je     f0102470 <mem_init+0x11b6>
f0102457:	68 14 74 10 f0       	push   $0xf0107414
f010245c:	68 f3 76 10 f0       	push   $0xf01076f3
f0102461:	68 17 04 00 00       	push   $0x417
f0102466:	68 cd 76 10 f0       	push   $0xf01076cd
f010246b:	e8 d0 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102470:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102476:	89 f8                	mov    %edi,%eax
f0102478:	e8 6b e6 ff ff       	call   f0100ae8 <check_va2pa>
f010247d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102480:	74 19                	je     f010249b <mem_init+0x11e1>
f0102482:	68 38 74 10 f0       	push   $0xf0107438
f0102487:	68 f3 76 10 f0       	push   $0xf01076f3
f010248c:	68 18 04 00 00       	push   $0x418
f0102491:	68 cd 76 10 f0       	push   $0xf01076cd
f0102496:	e8 a5 db ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f010249b:	83 ec 04             	sub    $0x4,%esp
f010249e:	6a 00                	push   $0x0
f01024a0:	53                   	push   %ebx
f01024a1:	57                   	push   %edi
f01024a2:	e8 6c eb ff ff       	call   f0101013 <pgdir_walk>
f01024a7:	83 c4 10             	add    $0x10,%esp
f01024aa:	f6 00 1a             	testb  $0x1a,(%eax)
f01024ad:	75 19                	jne    f01024c8 <mem_init+0x120e>
f01024af:	68 64 74 10 f0       	push   $0xf0107464
f01024b4:	68 f3 76 10 f0       	push   $0xf01076f3
f01024b9:	68 1a 04 00 00       	push   $0x41a
f01024be:	68 cd 76 10 f0       	push   $0xf01076cd
f01024c3:	e8 78 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01024c8:	83 ec 04             	sub    $0x4,%esp
f01024cb:	6a 00                	push   $0x0
f01024cd:	53                   	push   %ebx
f01024ce:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f01024d4:	e8 3a eb ff ff       	call   f0101013 <pgdir_walk>
f01024d9:	8b 00                	mov    (%eax),%eax
f01024db:	83 c4 10             	add    $0x10,%esp
f01024de:	83 e0 04             	and    $0x4,%eax
f01024e1:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01024e4:	74 19                	je     f01024ff <mem_init+0x1245>
f01024e6:	68 a8 74 10 f0       	push   $0xf01074a8
f01024eb:	68 f3 76 10 f0       	push   $0xf01076f3
f01024f0:	68 1b 04 00 00       	push   $0x41b
f01024f5:	68 cd 76 10 f0       	push   $0xf01076cd
f01024fa:	e8 41 db ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f01024ff:	83 ec 04             	sub    $0x4,%esp
f0102502:	6a 00                	push   $0x0
f0102504:	53                   	push   %ebx
f0102505:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f010250b:	e8 03 eb ff ff       	call   f0101013 <pgdir_walk>
f0102510:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102516:	83 c4 0c             	add    $0xc,%esp
f0102519:	6a 00                	push   $0x0
f010251b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010251e:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0102524:	e8 ea ea ff ff       	call   f0101013 <pgdir_walk>
f0102529:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010252f:	83 c4 0c             	add    $0xc,%esp
f0102532:	6a 00                	push   $0x0
f0102534:	56                   	push   %esi
f0102535:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f010253b:	e8 d3 ea ff ff       	call   f0101013 <pgdir_walk>
f0102540:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102546:	c7 04 24 96 79 10 f0 	movl   $0xf0107996,(%esp)
f010254d:	e8 03 11 00 00       	call   f0103655 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	size_t psize = sizeof(struct PageInfo);
	boot_map_region(kern_pgdir, UPAGES + psize, ROUNDUP((npages - 1) * psize, PGSIZE), PADDR(pages + psize), PTE_U | PTE_P);
f0102552:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
f0102557:	83 c0 40             	add    $0x40,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010255a:	83 c4 10             	add    $0x10,%esp
f010255d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102562:	77 15                	ja     f0102579 <mem_init+0x12bf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102564:	50                   	push   %eax
f0102565:	68 e8 67 10 f0       	push   $0xf01067e8
f010256a:	68 bc 00 00 00       	push   $0xbc
f010256f:	68 cd 76 10 f0       	push   $0xf01076cd
f0102574:	e8 c7 da ff ff       	call   f0100040 <_panic>
f0102579:	8b 15 88 0e 23 f0    	mov    0xf0230e88,%edx
f010257f:	8d 0c d5 f7 0f 00 00 	lea    0xff7(,%edx,8),%ecx
f0102586:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010258c:	83 ec 08             	sub    $0x8,%esp
f010258f:	6a 05                	push   $0x5
f0102591:	05 00 00 00 10       	add    $0x10000000,%eax
f0102596:	50                   	push   %eax
f0102597:	ba 08 00 00 ef       	mov    $0xef000008,%edx
f010259c:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01025a1:	e8 35 eb ff ff       	call   f01010db <boot_map_region>
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(psize, PGSIZE), PADDR(pages), PTE_W | PTE_P);
f01025a6:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025ab:	83 c4 10             	add    $0x10,%esp
f01025ae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025b3:	77 15                	ja     f01025ca <mem_init+0x1310>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025b5:	50                   	push   %eax
f01025b6:	68 e8 67 10 f0       	push   $0xf01067e8
f01025bb:	68 bd 00 00 00       	push   $0xbd
f01025c0:	68 cd 76 10 f0       	push   $0xf01076cd
f01025c5:	e8 76 da ff ff       	call   f0100040 <_panic>
f01025ca:	83 ec 08             	sub    $0x8,%esp
f01025cd:	6a 03                	push   $0x3
f01025cf:	05 00 00 00 10       	add    $0x10000000,%eax
f01025d4:	50                   	push   %eax
f01025d5:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01025da:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01025df:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01025e4:	e8 f2 ea ff ff       	call   f01010db <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, ROUNDUP(NENV * sizeof(struct Env), PGSIZE), PADDR(envs), PTE_U | PTE_P);
f01025e9:	a1 44 02 23 f0       	mov    0xf0230244,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025ee:	83 c4 10             	add    $0x10,%esp
f01025f1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025f6:	77 15                	ja     f010260d <mem_init+0x1353>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025f8:	50                   	push   %eax
f01025f9:	68 e8 67 10 f0       	push   $0xf01067e8
f01025fe:	68 c6 00 00 00       	push   $0xc6
f0102603:	68 cd 76 10 f0       	push   $0xf01076cd
f0102608:	e8 33 da ff ff       	call   f0100040 <_panic>
f010260d:	83 ec 08             	sub    $0x8,%esp
f0102610:	6a 05                	push   $0x5
f0102612:	05 00 00 00 10       	add    $0x10000000,%eax
f0102617:	50                   	push   %eax
f0102618:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f010261d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102622:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102627:	e8 af ea ff ff       	call   f01010db <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010262c:	83 c4 10             	add    $0x10,%esp
f010262f:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102634:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102639:	77 15                	ja     f0102650 <mem_init+0x1396>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010263b:	50                   	push   %eax
f010263c:	68 e8 67 10 f0       	push   $0xf01067e8
f0102641:	68 d3 00 00 00       	push   $0xd3
f0102646:	68 cd 76 10 f0       	push   $0xf01076cd
f010264b:	e8 f0 d9 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), PTE_W | PTE_P);
f0102650:	83 ec 08             	sub    $0x8,%esp
f0102653:	6a 03                	push   $0x3
f0102655:	68 00 70 11 00       	push   $0x117000
f010265a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010265f:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102664:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102669:	e8 6d ea ff ff       	call   f01010db <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, ROUNDUP(~0 - KERNBASE + 1, PGSIZE), 0, PTE_W | PTE_P);
f010266e:	83 c4 08             	add    $0x8,%esp
f0102671:	6a 03                	push   $0x3
f0102673:	6a 00                	push   $0x0
f0102675:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010267a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010267f:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f0102684:	e8 52 ea ff ff       	call   f01010db <boot_map_region>
f0102689:	c7 45 c4 00 20 23 f0 	movl   $0xf0232000,-0x3c(%ebp)
f0102690:	83 c4 10             	add    $0x10,%esp
f0102693:	bb 00 20 23 f0       	mov    $0xf0232000,%ebx
f0102698:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010269d:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01026a3:	77 15                	ja     f01026ba <mem_init+0x1400>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026a5:	53                   	push   %ebx
f01026a6:	68 e8 67 10 f0       	push   $0xf01067e8
f01026ab:	68 14 01 00 00       	push   $0x114
f01026b0:	68 cd 76 10 f0       	push   $0xf01076cd
f01026b5:	e8 86 d9 ff ff       	call   f0100040 <_panic>
	//
	// LAB 4: Your code here:
	uint32_t i;
	for (i = 0; i < NCPU; i++) {
		uint32_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f01026ba:	83 ec 08             	sub    $0x8,%esp
f01026bd:	6a 02                	push   $0x2
f01026bf:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01026c5:	50                   	push   %eax
f01026c6:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026cb:	89 f2                	mov    %esi,%edx
f01026cd:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
f01026d2:	e8 04 ea ff ff       	call   f01010db <boot_map_region>
f01026d7:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01026dd:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	uint32_t i;
	for (i = 0; i < NCPU; i++) {
f01026e3:	83 c4 10             	add    $0x10,%esp
f01026e6:	b8 00 20 27 f0       	mov    $0xf0272000,%eax
f01026eb:	39 d8                	cmp    %ebx,%eax
f01026ed:	75 ae                	jne    f010269d <mem_init+0x13e3>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026ef:	8b 3d 8c 0e 23 f0    	mov    0xf0230e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026f5:	a1 88 0e 23 f0       	mov    0xf0230e88,%eax
f01026fa:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01026fd:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102704:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102709:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010270c:	8b 35 90 0e 23 f0    	mov    0xf0230e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102712:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102715:	bb 00 00 00 00       	mov    $0x0,%ebx
f010271a:	eb 55                	jmp    f0102771 <mem_init+0x14b7>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010271c:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102722:	89 f8                	mov    %edi,%eax
f0102724:	e8 bf e3 ff ff       	call   f0100ae8 <check_va2pa>
f0102729:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102730:	77 15                	ja     f0102747 <mem_init+0x148d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102732:	56                   	push   %esi
f0102733:	68 e8 67 10 f0       	push   $0xf01067e8
f0102738:	68 33 03 00 00       	push   $0x333
f010273d:	68 cd 76 10 f0       	push   $0xf01076cd
f0102742:	e8 f9 d8 ff ff       	call   f0100040 <_panic>
f0102747:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f010274e:	39 c2                	cmp    %eax,%edx
f0102750:	74 19                	je     f010276b <mem_init+0x14b1>
f0102752:	68 dc 74 10 f0       	push   $0xf01074dc
f0102757:	68 f3 76 10 f0       	push   $0xf01076f3
f010275c:	68 33 03 00 00       	push   $0x333
f0102761:	68 cd 76 10 f0       	push   $0xf01076cd
f0102766:	e8 d5 d8 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010276b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102771:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102774:	77 a6                	ja     f010271c <mem_init+0x1462>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102776:	8b 35 44 02 23 f0    	mov    0xf0230244,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010277c:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010277f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102784:	89 da                	mov    %ebx,%edx
f0102786:	89 f8                	mov    %edi,%eax
f0102788:	e8 5b e3 ff ff       	call   f0100ae8 <check_va2pa>
f010278d:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102794:	77 15                	ja     f01027ab <mem_init+0x14f1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102796:	56                   	push   %esi
f0102797:	68 e8 67 10 f0       	push   $0xf01067e8
f010279c:	68 38 03 00 00       	push   $0x338
f01027a1:	68 cd 76 10 f0       	push   $0xf01076cd
f01027a6:	e8 95 d8 ff ff       	call   f0100040 <_panic>
f01027ab:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01027b2:	39 d0                	cmp    %edx,%eax
f01027b4:	74 19                	je     f01027cf <mem_init+0x1515>
f01027b6:	68 10 75 10 f0       	push   $0xf0107510
f01027bb:	68 f3 76 10 f0       	push   $0xf01076f3
f01027c0:	68 38 03 00 00       	push   $0x338
f01027c5:	68 cd 76 10 f0       	push   $0xf01076cd
f01027ca:	e8 71 d8 ff ff       	call   f0100040 <_panic>
f01027cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027d5:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01027db:	75 a7                	jne    f0102784 <mem_init+0x14ca>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027dd:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01027e0:	c1 e6 0c             	shl    $0xc,%esi
f01027e3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01027e8:	eb 30                	jmp    f010281a <mem_init+0x1560>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01027ea:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01027f0:	89 f8                	mov    %edi,%eax
f01027f2:	e8 f1 e2 ff ff       	call   f0100ae8 <check_va2pa>
f01027f7:	39 c3                	cmp    %eax,%ebx
f01027f9:	74 19                	je     f0102814 <mem_init+0x155a>
f01027fb:	68 44 75 10 f0       	push   $0xf0107544
f0102800:	68 f3 76 10 f0       	push   $0xf01076f3
f0102805:	68 3c 03 00 00       	push   $0x33c
f010280a:	68 cd 76 10 f0       	push   $0xf01076cd
f010280f:	e8 2c d8 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102814:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010281a:	39 f3                	cmp    %esi,%ebx
f010281c:	72 cc                	jb     f01027ea <mem_init+0x1530>
f010281e:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102823:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102826:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102829:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010282c:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102832:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102835:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102837:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010283a:	05 00 80 00 20       	add    $0x20008000,%eax
f010283f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102842:	89 da                	mov    %ebx,%edx
f0102844:	89 f8                	mov    %edi,%eax
f0102846:	e8 9d e2 ff ff       	call   f0100ae8 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010284b:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102851:	77 15                	ja     f0102868 <mem_init+0x15ae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102853:	56                   	push   %esi
f0102854:	68 e8 67 10 f0       	push   $0xf01067e8
f0102859:	68 44 03 00 00       	push   $0x344
f010285e:	68 cd 76 10 f0       	push   $0xf01076cd
f0102863:	e8 d8 d7 ff ff       	call   f0100040 <_panic>
f0102868:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010286b:	8d 94 0b 00 20 23 f0 	lea    -0xfdce000(%ebx,%ecx,1),%edx
f0102872:	39 d0                	cmp    %edx,%eax
f0102874:	74 19                	je     f010288f <mem_init+0x15d5>
f0102876:	68 6c 75 10 f0       	push   $0xf010756c
f010287b:	68 f3 76 10 f0       	push   $0xf01076f3
f0102880:	68 44 03 00 00       	push   $0x344
f0102885:	68 cd 76 10 f0       	push   $0xf01076cd
f010288a:	e8 b1 d7 ff ff       	call   f0100040 <_panic>
f010288f:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102895:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f0102898:	75 a8                	jne    f0102842 <mem_init+0x1588>
f010289a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010289d:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f01028a3:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01028a6:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01028a8:	89 da                	mov    %ebx,%edx
f01028aa:	89 f8                	mov    %edi,%eax
f01028ac:	e8 37 e2 ff ff       	call   f0100ae8 <check_va2pa>
f01028b1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028b4:	74 19                	je     f01028cf <mem_init+0x1615>
f01028b6:	68 b4 75 10 f0       	push   $0xf01075b4
f01028bb:	68 f3 76 10 f0       	push   $0xf01076f3
f01028c0:	68 46 03 00 00       	push   $0x346
f01028c5:	68 cd 76 10 f0       	push   $0xf01076cd
f01028ca:	e8 71 d7 ff ff       	call   f0100040 <_panic>
f01028cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01028d5:	39 f3                	cmp    %esi,%ebx
f01028d7:	75 cf                	jne    f01028a8 <mem_init+0x15ee>
f01028d9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01028dc:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01028e3:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01028ea:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01028f0:	b8 00 20 27 f0       	mov    $0xf0272000,%eax
f01028f5:	39 f0                	cmp    %esi,%eax
f01028f7:	0f 85 2c ff ff ff    	jne    f0102829 <mem_init+0x156f>
f01028fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0102902:	eb 2a                	jmp    f010292e <mem_init+0x1674>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102904:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010290a:	83 fa 04             	cmp    $0x4,%edx
f010290d:	77 1f                	ja     f010292e <mem_init+0x1674>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010290f:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102913:	75 7e                	jne    f0102993 <mem_init+0x16d9>
f0102915:	68 af 79 10 f0       	push   $0xf01079af
f010291a:	68 f3 76 10 f0       	push   $0xf01076f3
f010291f:	68 51 03 00 00       	push   $0x351
f0102924:	68 cd 76 10 f0       	push   $0xf01076cd
f0102929:	e8 12 d7 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010292e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102933:	76 3f                	jbe    f0102974 <mem_init+0x16ba>
				assert(pgdir[i] & PTE_P);
f0102935:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102938:	f6 c2 01             	test   $0x1,%dl
f010293b:	75 19                	jne    f0102956 <mem_init+0x169c>
f010293d:	68 af 79 10 f0       	push   $0xf01079af
f0102942:	68 f3 76 10 f0       	push   $0xf01076f3
f0102947:	68 55 03 00 00       	push   $0x355
f010294c:	68 cd 76 10 f0       	push   $0xf01076cd
f0102951:	e8 ea d6 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102956:	f6 c2 02             	test   $0x2,%dl
f0102959:	75 38                	jne    f0102993 <mem_init+0x16d9>
f010295b:	68 c0 79 10 f0       	push   $0xf01079c0
f0102960:	68 f3 76 10 f0       	push   $0xf01076f3
f0102965:	68 56 03 00 00       	push   $0x356
f010296a:	68 cd 76 10 f0       	push   $0xf01076cd
f010296f:	e8 cc d6 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102974:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102978:	74 19                	je     f0102993 <mem_init+0x16d9>
f010297a:	68 d1 79 10 f0       	push   $0xf01079d1
f010297f:	68 f3 76 10 f0       	push   $0xf01076f3
f0102984:	68 58 03 00 00       	push   $0x358
f0102989:	68 cd 76 10 f0       	push   $0xf01076cd
f010298e:	e8 ad d6 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102993:	83 c0 01             	add    $0x1,%eax
f0102996:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010299b:	0f 86 63 ff ff ff    	jbe    f0102904 <mem_init+0x164a>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01029a1:	83 ec 0c             	sub    $0xc,%esp
f01029a4:	68 d8 75 10 f0       	push   $0xf01075d8
f01029a9:	e8 a7 0c 00 00       	call   f0103655 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01029ae:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01029b3:	83 c4 10             	add    $0x10,%esp
f01029b6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01029bb:	77 15                	ja     f01029d2 <mem_init+0x1718>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01029bd:	50                   	push   %eax
f01029be:	68 e8 67 10 f0       	push   $0xf01067e8
f01029c3:	68 ec 00 00 00       	push   $0xec
f01029c8:	68 cd 76 10 f0       	push   $0xf01076cd
f01029cd:	e8 6e d6 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01029d2:	05 00 00 00 10       	add    $0x10000000,%eax
f01029d7:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01029da:	b8 00 00 00 00       	mov    $0x0,%eax
f01029df:	e8 68 e1 ff ff       	call   f0100b4c <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01029e4:	0f 20 c0             	mov    %cr0,%eax
f01029e7:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01029ea:	0d 23 00 05 80       	or     $0x80050023,%eax
f01029ef:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029f2:	83 ec 0c             	sub    $0xc,%esp
f01029f5:	6a 00                	push   $0x0
f01029f7:	e8 0f e5 ff ff       	call   f0100f0b <page_alloc>
f01029fc:	89 c3                	mov    %eax,%ebx
f01029fe:	83 c4 10             	add    $0x10,%esp
f0102a01:	85 c0                	test   %eax,%eax
f0102a03:	75 19                	jne    f0102a1e <mem_init+0x1764>
f0102a05:	68 bb 77 10 f0       	push   $0xf01077bb
f0102a0a:	68 f3 76 10 f0       	push   $0xf01076f3
f0102a0f:	68 30 04 00 00       	push   $0x430
f0102a14:	68 cd 76 10 f0       	push   $0xf01076cd
f0102a19:	e8 22 d6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a1e:	83 ec 0c             	sub    $0xc,%esp
f0102a21:	6a 00                	push   $0x0
f0102a23:	e8 e3 e4 ff ff       	call   f0100f0b <page_alloc>
f0102a28:	89 c7                	mov    %eax,%edi
f0102a2a:	83 c4 10             	add    $0x10,%esp
f0102a2d:	85 c0                	test   %eax,%eax
f0102a2f:	75 19                	jne    f0102a4a <mem_init+0x1790>
f0102a31:	68 d1 77 10 f0       	push   $0xf01077d1
f0102a36:	68 f3 76 10 f0       	push   $0xf01076f3
f0102a3b:	68 31 04 00 00       	push   $0x431
f0102a40:	68 cd 76 10 f0       	push   $0xf01076cd
f0102a45:	e8 f6 d5 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a4a:	83 ec 0c             	sub    $0xc,%esp
f0102a4d:	6a 00                	push   $0x0
f0102a4f:	e8 b7 e4 ff ff       	call   f0100f0b <page_alloc>
f0102a54:	89 c6                	mov    %eax,%esi
f0102a56:	83 c4 10             	add    $0x10,%esp
f0102a59:	85 c0                	test   %eax,%eax
f0102a5b:	75 19                	jne    f0102a76 <mem_init+0x17bc>
f0102a5d:	68 e7 77 10 f0       	push   $0xf01077e7
f0102a62:	68 f3 76 10 f0       	push   $0xf01076f3
f0102a67:	68 32 04 00 00       	push   $0x432
f0102a6c:	68 cd 76 10 f0       	push   $0xf01076cd
f0102a71:	e8 ca d5 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102a76:	83 ec 0c             	sub    $0xc,%esp
f0102a79:	53                   	push   %ebx
f0102a7a:	e8 1b e5 ff ff       	call   f0100f9a <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a7f:	89 f8                	mov    %edi,%eax
f0102a81:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0102a87:	c1 f8 03             	sar    $0x3,%eax
f0102a8a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a8d:	89 c2                	mov    %eax,%edx
f0102a8f:	c1 ea 0c             	shr    $0xc,%edx
f0102a92:	83 c4 10             	add    $0x10,%esp
f0102a95:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0102a9b:	72 12                	jb     f0102aaf <mem_init+0x17f5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a9d:	50                   	push   %eax
f0102a9e:	68 c4 67 10 f0       	push   $0xf01067c4
f0102aa3:	6a 58                	push   $0x58
f0102aa5:	68 d9 76 10 f0       	push   $0xf01076d9
f0102aaa:	e8 91 d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102aaf:	83 ec 04             	sub    $0x4,%esp
f0102ab2:	68 00 10 00 00       	push   $0x1000
f0102ab7:	6a 01                	push   $0x1
f0102ab9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102abe:	50                   	push   %eax
f0102abf:	e8 1d 30 00 00       	call   f0105ae1 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ac4:	89 f0                	mov    %esi,%eax
f0102ac6:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0102acc:	c1 f8 03             	sar    $0x3,%eax
f0102acf:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ad2:	89 c2                	mov    %eax,%edx
f0102ad4:	c1 ea 0c             	shr    $0xc,%edx
f0102ad7:	83 c4 10             	add    $0x10,%esp
f0102ada:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0102ae0:	72 12                	jb     f0102af4 <mem_init+0x183a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ae2:	50                   	push   %eax
f0102ae3:	68 c4 67 10 f0       	push   $0xf01067c4
f0102ae8:	6a 58                	push   $0x58
f0102aea:	68 d9 76 10 f0       	push   $0xf01076d9
f0102aef:	e8 4c d5 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102af4:	83 ec 04             	sub    $0x4,%esp
f0102af7:	68 00 10 00 00       	push   $0x1000
f0102afc:	6a 02                	push   $0x2
f0102afe:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b03:	50                   	push   %eax
f0102b04:	e8 d8 2f 00 00       	call   f0105ae1 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b09:	6a 02                	push   $0x2
f0102b0b:	68 00 10 00 00       	push   $0x1000
f0102b10:	57                   	push   %edi
f0102b11:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0102b17:	e8 ea e6 ff ff       	call   f0101206 <page_insert>
	assert(pp1->pp_ref == 1);
f0102b1c:	83 c4 20             	add    $0x20,%esp
f0102b1f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b24:	74 19                	je     f0102b3f <mem_init+0x1885>
f0102b26:	68 b8 78 10 f0       	push   $0xf01078b8
f0102b2b:	68 f3 76 10 f0       	push   $0xf01076f3
f0102b30:	68 37 04 00 00       	push   $0x437
f0102b35:	68 cd 76 10 f0       	push   $0xf01076cd
f0102b3a:	e8 01 d5 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b3f:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b46:	01 01 01 
f0102b49:	74 19                	je     f0102b64 <mem_init+0x18aa>
f0102b4b:	68 f8 75 10 f0       	push   $0xf01075f8
f0102b50:	68 f3 76 10 f0       	push   $0xf01076f3
f0102b55:	68 38 04 00 00       	push   $0x438
f0102b5a:	68 cd 76 10 f0       	push   $0xf01076cd
f0102b5f:	e8 dc d4 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102b64:	6a 02                	push   $0x2
f0102b66:	68 00 10 00 00       	push   $0x1000
f0102b6b:	56                   	push   %esi
f0102b6c:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0102b72:	e8 8f e6 ff ff       	call   f0101206 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b77:	83 c4 10             	add    $0x10,%esp
f0102b7a:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b81:	02 02 02 
f0102b84:	74 19                	je     f0102b9f <mem_init+0x18e5>
f0102b86:	68 1c 76 10 f0       	push   $0xf010761c
f0102b8b:	68 f3 76 10 f0       	push   $0xf01076f3
f0102b90:	68 3a 04 00 00       	push   $0x43a
f0102b95:	68 cd 76 10 f0       	push   $0xf01076cd
f0102b9a:	e8 a1 d4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102b9f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ba4:	74 19                	je     f0102bbf <mem_init+0x1905>
f0102ba6:	68 da 78 10 f0       	push   $0xf01078da
f0102bab:	68 f3 76 10 f0       	push   $0xf01076f3
f0102bb0:	68 3b 04 00 00       	push   $0x43b
f0102bb5:	68 cd 76 10 f0       	push   $0xf01076cd
f0102bba:	e8 81 d4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102bbf:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102bc4:	74 19                	je     f0102bdf <mem_init+0x1925>
f0102bc6:	68 44 79 10 f0       	push   $0xf0107944
f0102bcb:	68 f3 76 10 f0       	push   $0xf01076f3
f0102bd0:	68 3c 04 00 00       	push   $0x43c
f0102bd5:	68 cd 76 10 f0       	push   $0xf01076cd
f0102bda:	e8 61 d4 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102bdf:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102be6:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102be9:	89 f0                	mov    %esi,%eax
f0102beb:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0102bf1:	c1 f8 03             	sar    $0x3,%eax
f0102bf4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bf7:	89 c2                	mov    %eax,%edx
f0102bf9:	c1 ea 0c             	shr    $0xc,%edx
f0102bfc:	3b 15 88 0e 23 f0    	cmp    0xf0230e88,%edx
f0102c02:	72 12                	jb     f0102c16 <mem_init+0x195c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c04:	50                   	push   %eax
f0102c05:	68 c4 67 10 f0       	push   $0xf01067c4
f0102c0a:	6a 58                	push   $0x58
f0102c0c:	68 d9 76 10 f0       	push   $0xf01076d9
f0102c11:	e8 2a d4 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c16:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c1d:	03 03 03 
f0102c20:	74 19                	je     f0102c3b <mem_init+0x1981>
f0102c22:	68 40 76 10 f0       	push   $0xf0107640
f0102c27:	68 f3 76 10 f0       	push   $0xf01076f3
f0102c2c:	68 3e 04 00 00       	push   $0x43e
f0102c31:	68 cd 76 10 f0       	push   $0xf01076cd
f0102c36:	e8 05 d4 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c3b:	83 ec 08             	sub    $0x8,%esp
f0102c3e:	68 00 10 00 00       	push   $0x1000
f0102c43:	ff 35 8c 0e 23 f0    	pushl  0xf0230e8c
f0102c49:	e8 6b e5 ff ff       	call   f01011b9 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c4e:	83 c4 10             	add    $0x10,%esp
f0102c51:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102c56:	74 19                	je     f0102c71 <mem_init+0x19b7>
f0102c58:	68 12 79 10 f0       	push   $0xf0107912
f0102c5d:	68 f3 76 10 f0       	push   $0xf01076f3
f0102c62:	68 40 04 00 00       	push   $0x440
f0102c67:	68 cd 76 10 f0       	push   $0xf01076cd
f0102c6c:	e8 cf d3 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c71:	8b 0d 8c 0e 23 f0    	mov    0xf0230e8c,%ecx
f0102c77:	8b 11                	mov    (%ecx),%edx
f0102c79:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102c7f:	89 d8                	mov    %ebx,%eax
f0102c81:	2b 05 90 0e 23 f0    	sub    0xf0230e90,%eax
f0102c87:	c1 f8 03             	sar    $0x3,%eax
f0102c8a:	c1 e0 0c             	shl    $0xc,%eax
f0102c8d:	39 c2                	cmp    %eax,%edx
f0102c8f:	74 19                	je     f0102caa <mem_init+0x19f0>
f0102c91:	68 c8 6f 10 f0       	push   $0xf0106fc8
f0102c96:	68 f3 76 10 f0       	push   $0xf01076f3
f0102c9b:	68 43 04 00 00       	push   $0x443
f0102ca0:	68 cd 76 10 f0       	push   $0xf01076cd
f0102ca5:	e8 96 d3 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102caa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102cb0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102cb5:	74 19                	je     f0102cd0 <mem_init+0x1a16>
f0102cb7:	68 c9 78 10 f0       	push   $0xf01078c9
f0102cbc:	68 f3 76 10 f0       	push   $0xf01076f3
f0102cc1:	68 45 04 00 00       	push   $0x445
f0102cc6:	68 cd 76 10 f0       	push   $0xf01076cd
f0102ccb:	e8 70 d3 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102cd0:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102cd6:	83 ec 0c             	sub    $0xc,%esp
f0102cd9:	53                   	push   %ebx
f0102cda:	e8 bb e2 ff ff       	call   f0100f9a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102cdf:	c7 04 24 6c 76 10 f0 	movl   $0xf010766c,(%esp)
f0102ce6:	e8 6a 09 00 00       	call   f0103655 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102ceb:	83 c4 10             	add    $0x10,%esp
f0102cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cf1:	5b                   	pop    %ebx
f0102cf2:	5e                   	pop    %esi
f0102cf3:	5f                   	pop    %edi
f0102cf4:	5d                   	pop    %ebp
f0102cf5:	c3                   	ret    

f0102cf6 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102cf6:	55                   	push   %ebp
f0102cf7:	89 e5                	mov    %esp,%ebp
f0102cf9:	57                   	push   %edi
f0102cfa:	56                   	push   %esi
f0102cfb:	53                   	push   %ebx
f0102cfc:	83 ec 1c             	sub    $0x1c,%esp
f0102cff:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102d02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d05:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	const void *max = ROUNDUP(va + len, PGSIZE);
f0102d08:	89 d8                	mov    %ebx,%eax
f0102d0a:	03 45 10             	add    0x10(%ebp),%eax
f0102d0d:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102d12:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102d17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (; va < max; va = ROUNDDOWN(va + PGSIZE, PGSIZE)) {
f0102d1a:	eb 3e                	jmp    f0102d5a <user_mem_check+0x64>
		pte_t *pte = pgdir_walk(env->env_pgdir, va, false);
f0102d1c:	83 ec 04             	sub    $0x4,%esp
f0102d1f:	6a 00                	push   $0x0
f0102d21:	53                   	push   %ebx
f0102d22:	ff 77 60             	pushl  0x60(%edi)
f0102d25:	e8 e9 e2 ff ff       	call   f0101013 <pgdir_walk>
		if (pte == NULL || va > (void *)ULIM || (int)(*pte & perm) != perm) {
f0102d2a:	83 c4 10             	add    $0x10,%esp
f0102d2d:	85 c0                	test   %eax,%eax
f0102d2f:	74 10                	je     f0102d41 <user_mem_check+0x4b>
f0102d31:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0102d37:	77 08                	ja     f0102d41 <user_mem_check+0x4b>
f0102d39:	89 f2                	mov    %esi,%edx
f0102d3b:	23 10                	and    (%eax),%edx
f0102d3d:	39 d6                	cmp    %edx,%esi
f0102d3f:	74 0d                	je     f0102d4e <user_mem_check+0x58>
			user_mem_check_addr = (uintptr_t)va;
f0102d41:	89 1d 3c 02 23 f0    	mov    %ebx,0xf023023c
			return -E_FAULT;
f0102d47:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102d4c:	eb 16                	jmp    f0102d64 <user_mem_check+0x6e>
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	const void *max = ROUNDUP(va + len, PGSIZE);
	for (; va < max; va = ROUNDDOWN(va + PGSIZE, PGSIZE)) {
f0102d4e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d54:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102d5a:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102d5d:	72 bd                	jb     f0102d1c <user_mem_check+0x26>
			user_mem_check_addr = (uintptr_t)va;
			return -E_FAULT;
		}
	}

	return 0;
f0102d5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d67:	5b                   	pop    %ebx
f0102d68:	5e                   	pop    %esi
f0102d69:	5f                   	pop    %edi
f0102d6a:	5d                   	pop    %ebp
f0102d6b:	c3                   	ret    

f0102d6c <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102d6c:	55                   	push   %ebp
f0102d6d:	89 e5                	mov    %esp,%ebp
f0102d6f:	53                   	push   %ebx
f0102d70:	83 ec 04             	sub    $0x4,%esp
f0102d73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U | PTE_P) < 0) {
f0102d76:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d79:	83 c8 05             	or     $0x5,%eax
f0102d7c:	50                   	push   %eax
f0102d7d:	ff 75 10             	pushl  0x10(%ebp)
f0102d80:	ff 75 0c             	pushl  0xc(%ebp)
f0102d83:	53                   	push   %ebx
f0102d84:	e8 6d ff ff ff       	call   f0102cf6 <user_mem_check>
f0102d89:	83 c4 10             	add    $0x10,%esp
f0102d8c:	85 c0                	test   %eax,%eax
f0102d8e:	79 21                	jns    f0102db1 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102d90:	83 ec 04             	sub    $0x4,%esp
f0102d93:	ff 35 3c 02 23 f0    	pushl  0xf023023c
f0102d99:	ff 73 48             	pushl  0x48(%ebx)
f0102d9c:	68 98 76 10 f0       	push   $0xf0107698
f0102da1:	e8 af 08 00 00       	call   f0103655 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102da6:	89 1c 24             	mov    %ebx,(%esp)
f0102da9:	e8 ee 05 00 00       	call   f010339c <env_destroy>
f0102dae:	83 c4 10             	add    $0x10,%esp
	}
}
f0102db1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102db4:	c9                   	leave  
f0102db5:	c3                   	ret    

f0102db6 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102db6:	55                   	push   %ebp
f0102db7:	89 e5                	mov    %esp,%ebp
f0102db9:	57                   	push   %edi
f0102dba:	56                   	push   %esi
f0102dbb:	53                   	push   %ebx
f0102dbc:	83 ec 1c             	sub    $0x1c,%esp
f0102dbf:	89 c7                	mov    %eax,%edi
f0102dc1:	89 d6                	mov    %edx,%esi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	size_t size = ROUNDUP(va + len, PGSIZE) - ROUNDDOWN(va, PGSIZE);
f0102dc3:	8d 84 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%eax
f0102dca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102dcf:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102dd5:	29 d0                	sub    %edx,%eax
f0102dd7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int i;
	for (i = 0; i < size; i += PGSIZE) {
f0102dda:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102ddf:	eb 22                	jmp    f0102e03 <region_alloc+0x4d>
		struct PageInfo *page = page_alloc(0);
f0102de1:	83 ec 0c             	sub    $0xc,%esp
f0102de4:	6a 00                	push   $0x0
f0102de6:	e8 20 e1 ff ff       	call   f0100f0b <page_alloc>
		page_insert(e->env_pgdir, page, va + i, PTE_P | PTE_W | PTE_U);
f0102deb:	6a 07                	push   $0x7
f0102ded:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102df0:	52                   	push   %edx
f0102df1:	50                   	push   %eax
f0102df2:	ff 77 60             	pushl  0x60(%edi)
f0102df5:	e8 0c e4 ff ff       	call   f0101206 <page_insert>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	size_t size = ROUNDUP(va + len, PGSIZE) - ROUNDDOWN(va, PGSIZE);
	int i;
	for (i = 0; i < size; i += PGSIZE) {
f0102dfa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e00:	83 c4 20             	add    $0x20,%esp
f0102e03:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102e06:	77 d9                	ja     f0102de1 <region_alloc+0x2b>
		struct PageInfo *page = page_alloc(0);
		page_insert(e->env_pgdir, page, va + i, PTE_P | PTE_W | PTE_U);
	}
}
f0102e08:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e0b:	5b                   	pop    %ebx
f0102e0c:	5e                   	pop    %esi
f0102e0d:	5f                   	pop    %edi
f0102e0e:	5d                   	pop    %ebp
f0102e0f:	c3                   	ret    

f0102e10 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e10:	55                   	push   %ebp
f0102e11:	89 e5                	mov    %esp,%ebp
f0102e13:	56                   	push   %esi
f0102e14:	53                   	push   %ebx
f0102e15:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e18:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e1b:	85 c0                	test   %eax,%eax
f0102e1d:	75 1a                	jne    f0102e39 <envid2env+0x29>
		*env_store = curenv;
f0102e1f:	e8 de 32 00 00       	call   f0106102 <cpunum>
f0102e24:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e27:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0102e2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e30:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102e32:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e37:	eb 70                	jmp    f0102ea9 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e39:	89 c3                	mov    %eax,%ebx
f0102e3b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102e41:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102e44:	03 1d 44 02 23 f0    	add    0xf0230244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102e4a:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102e4e:	74 05                	je     f0102e55 <envid2env+0x45>
f0102e50:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102e53:	74 10                	je     f0102e65 <envid2env+0x55>
		*env_store = 0;
f0102e55:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e58:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102e5e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e63:	eb 44                	jmp    f0102ea9 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102e65:	84 d2                	test   %dl,%dl
f0102e67:	74 36                	je     f0102e9f <envid2env+0x8f>
f0102e69:	e8 94 32 00 00       	call   f0106102 <cpunum>
f0102e6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e71:	3b 98 28 10 23 f0    	cmp    -0xfdcefd8(%eax),%ebx
f0102e77:	74 26                	je     f0102e9f <envid2env+0x8f>
f0102e79:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102e7c:	e8 81 32 00 00       	call   f0106102 <cpunum>
f0102e81:	6b c0 74             	imul   $0x74,%eax,%eax
f0102e84:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0102e8a:	3b 70 48             	cmp    0x48(%eax),%esi
f0102e8d:	74 10                	je     f0102e9f <envid2env+0x8f>
		*env_store = 0;
f0102e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e92:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102e98:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e9d:	eb 0a                	jmp    f0102ea9 <envid2env+0x99>
	}

	*env_store = e;
f0102e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ea2:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102ea4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102ea9:	5b                   	pop    %ebx
f0102eaa:	5e                   	pop    %esi
f0102eab:	5d                   	pop    %ebp
f0102eac:	c3                   	ret    

f0102ead <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102ead:	55                   	push   %ebp
f0102eae:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102eb0:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f0102eb5:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102eb8:	b8 23 00 00 00       	mov    $0x23,%eax
f0102ebd:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102ebf:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102ec1:	b8 10 00 00 00       	mov    $0x10,%eax
f0102ec6:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102ec8:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102eca:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102ecc:	ea d3 2e 10 f0 08 00 	ljmp   $0x8,$0xf0102ed3
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102ed3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ed8:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102edb:	5d                   	pop    %ebp
f0102edc:	c3                   	ret    

f0102edd <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102edd:	55                   	push   %ebp
f0102ede:	89 e5                	mov    %esp,%ebp
f0102ee0:	56                   	push   %esi
f0102ee1:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;
	for (i = NENV - 1; i >= 0; i--) {
		envs[i].env_status = ENV_FREE;
f0102ee2:	8b 35 44 02 23 f0    	mov    0xf0230244,%esi
f0102ee8:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102eee:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102ef1:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ef6:	89 c1                	mov    %eax,%ecx
f0102ef8:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0102eff:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102f06:	89 50 44             	mov    %edx,0x44(%eax)
f0102f09:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = &envs[i];
f0102f0c:	89 ca                	mov    %ecx,%edx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;
	for (i = NENV - 1; i >= 0; i--) {
f0102f0e:	39 d8                	cmp    %ebx,%eax
f0102f10:	75 e4                	jne    f0102ef6 <env_init+0x19>
f0102f12:	89 35 48 02 23 f0    	mov    %esi,0xf0230248
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}

	// Per-CPU part of the initialization
	env_init_percpu();
f0102f18:	e8 90 ff ff ff       	call   f0102ead <env_init_percpu>
}
f0102f1d:	5b                   	pop    %ebx
f0102f1e:	5e                   	pop    %esi
f0102f1f:	5d                   	pop    %ebp
f0102f20:	c3                   	ret    

f0102f21 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102f21:	55                   	push   %ebp
f0102f22:	89 e5                	mov    %esp,%ebp
f0102f24:	56                   	push   %esi
f0102f25:	53                   	push   %ebx
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102f26:	8b 1d 48 02 23 f0    	mov    0xf0230248,%ebx
f0102f2c:	85 db                	test   %ebx,%ebx
f0102f2e:	0f 84 74 01 00 00    	je     f01030a8 <env_alloc+0x187>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102f34:	83 ec 0c             	sub    $0xc,%esp
f0102f37:	6a 01                	push   $0x1
f0102f39:	e8 cd df ff ff       	call   f0100f0b <page_alloc>
f0102f3e:	83 c4 10             	add    $0x10,%esp
f0102f41:	85 c0                	test   %eax,%eax
f0102f43:	0f 84 66 01 00 00    	je     f01030af <env_alloc+0x18e>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f49:	89 c2                	mov    %eax,%edx
f0102f4b:	2b 15 90 0e 23 f0    	sub    0xf0230e90,%edx
f0102f51:	c1 fa 03             	sar    $0x3,%edx
f0102f54:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f57:	89 d1                	mov    %edx,%ecx
f0102f59:	c1 e9 0c             	shr    $0xc,%ecx
f0102f5c:	3b 0d 88 0e 23 f0    	cmp    0xf0230e88,%ecx
f0102f62:	72 12                	jb     f0102f76 <env_alloc+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102f64:	52                   	push   %edx
f0102f65:	68 c4 67 10 f0       	push   $0xf01067c4
f0102f6a:	6a 58                	push   $0x58
f0102f6c:	68 d9 76 10 f0       	push   $0xf01076d9
f0102f71:	e8 ca d0 ff ff       	call   f0100040 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = (pde_t *)page2kva(p);
f0102f76:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102f7c:	89 53 60             	mov    %edx,0x60(%ebx)
f0102f7f:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < NPDENTRIES; i++) {
		e->env_pgdir[i] = kern_pgdir[i];
f0102f84:	8b 0d 8c 0e 23 f0    	mov    0xf0230e8c,%ecx
f0102f8a:	8b 34 11             	mov    (%ecx,%edx,1),%esi
f0102f8d:	8b 4b 60             	mov    0x60(%ebx),%ecx
f0102f90:	89 34 11             	mov    %esi,(%ecx,%edx,1)
f0102f93:	83 c2 04             	add    $0x4,%edx
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = (pde_t *)page2kva(p);
	for (i = 0; i < NPDENTRIES; i++) {
f0102f96:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0102f9c:	75 e6                	jne    f0102f84 <env_alloc+0x63>
		e->env_pgdir[i] = kern_pgdir[i];
	}
	p->pp_ref++;
f0102f9e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102fa3:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fa6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fab:	77 15                	ja     f0102fc2 <env_alloc+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fad:	50                   	push   %eax
f0102fae:	68 e8 67 10 f0       	push   $0xf01067e8
f0102fb3:	68 c9 00 00 00       	push   $0xc9
f0102fb8:	68 df 79 10 f0       	push   $0xf01079df
f0102fbd:	e8 7e d0 ff ff       	call   f0100040 <_panic>
f0102fc2:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102fc8:	83 ca 05             	or     $0x5,%edx
f0102fcb:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102fd1:	8b 43 48             	mov    0x48(%ebx),%eax
f0102fd4:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102fd9:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102fde:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102fe3:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102fe6:	89 da                	mov    %ebx,%edx
f0102fe8:	2b 15 44 02 23 f0    	sub    0xf0230244,%edx
f0102fee:	c1 fa 02             	sar    $0x2,%edx
f0102ff1:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0102ff7:	09 d0                	or     %edx,%eax
f0102ff9:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102ffc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102fff:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103002:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103009:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103010:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103017:	83 ec 04             	sub    $0x4,%esp
f010301a:	6a 44                	push   $0x44
f010301c:	6a 00                	push   $0x0
f010301e:	53                   	push   %ebx
f010301f:	e8 bd 2a 00 00       	call   f0105ae1 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103024:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010302a:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103030:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103036:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010303d:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags = FL_IF;
f0103043:	c7 43 38 00 02 00 00 	movl   $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010304a:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103051:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103055:	8b 43 44             	mov    0x44(%ebx),%eax
f0103058:	a3 48 02 23 f0       	mov    %eax,0xf0230248
	*newenv_store = e;
f010305d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103060:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103062:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103065:	e8 98 30 00 00       	call   f0106102 <cpunum>
f010306a:	6b c0 74             	imul   $0x74,%eax,%eax
f010306d:	83 c4 10             	add    $0x10,%esp
f0103070:	ba 00 00 00 00       	mov    $0x0,%edx
f0103075:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f010307c:	74 11                	je     f010308f <env_alloc+0x16e>
f010307e:	e8 7f 30 00 00       	call   f0106102 <cpunum>
f0103083:	6b c0 74             	imul   $0x74,%eax,%eax
f0103086:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f010308c:	8b 50 48             	mov    0x48(%eax),%edx
f010308f:	83 ec 04             	sub    $0x4,%esp
f0103092:	53                   	push   %ebx
f0103093:	52                   	push   %edx
f0103094:	68 ea 79 10 f0       	push   $0xf01079ea
f0103099:	e8 b7 05 00 00       	call   f0103655 <cprintf>
	return 0;
f010309e:	83 c4 10             	add    $0x10,%esp
f01030a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01030a6:	eb 0c                	jmp    f01030b4 <env_alloc+0x193>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01030a8:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01030ad:	eb 05                	jmp    f01030b4 <env_alloc+0x193>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01030af:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01030b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01030b7:	5b                   	pop    %ebx
f01030b8:	5e                   	pop    %esi
f01030b9:	5d                   	pop    %ebp
f01030ba:	c3                   	ret    

f01030bb <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01030bb:	55                   	push   %ebp
f01030bc:	89 e5                	mov    %esp,%ebp
f01030be:	57                   	push   %edi
f01030bf:	56                   	push   %esi
f01030c0:	53                   	push   %ebx
f01030c1:	83 ec 34             	sub    $0x34,%esp
f01030c4:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	if (env_alloc(&e, 0) < 0) {
f01030c7:	6a 00                	push   $0x0
f01030c9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01030cc:	50                   	push   %eax
f01030cd:	e8 4f fe ff ff       	call   f0102f21 <env_alloc>
f01030d2:	83 c4 10             	add    $0x10,%esp
f01030d5:	85 c0                	test   %eax,%eax
f01030d7:	79 17                	jns    f01030f0 <env_create+0x35>
		panic("env_create: env_alloc failed");
f01030d9:	83 ec 04             	sub    $0x4,%esp
f01030dc:	68 ff 79 10 f0       	push   $0xf01079ff
f01030e1:	68 87 01 00 00       	push   $0x187
f01030e6:	68 df 79 10 f0       	push   $0xf01079df
f01030eb:	e8 50 cf ff ff       	call   f0100040 <_panic>
	}
	load_icode(e ,binary);
f01030f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01030f3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	//  to make sure that the environment starts executing there.
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *)binary;
	struct Proghdr *eph, *ph = (struct Proghdr *) (binary + (elf->e_phoff));
f01030f6:	89 fb                	mov    %edi,%ebx
f01030f8:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + elf->e_phnum;
f01030fb:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f01030ff:	c1 e6 05             	shl    $0x5,%esi
f0103102:	01 de                	add    %ebx,%esi
	lcr3(PADDR(e->env_pgdir));
f0103104:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103107:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010310c:	77 15                	ja     f0103123 <env_create+0x68>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010310e:	50                   	push   %eax
f010310f:	68 e8 67 10 f0       	push   $0xf01067e8
f0103114:	68 69 01 00 00       	push   $0x169
f0103119:	68 df 79 10 f0       	push   $0xf01079df
f010311e:	e8 1d cf ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103123:	05 00 00 00 10       	add    $0x10000000,%eax
f0103128:	0f 22 d8             	mov    %eax,%cr3
f010312b:	eb 44                	jmp    f0103171 <env_create+0xb6>
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
f010312d:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103130:	75 3c                	jne    f010316e <env_create+0xb3>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103132:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103135:	8b 53 08             	mov    0x8(%ebx),%edx
f0103138:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010313b:	e8 76 fc ff ff       	call   f0102db6 <region_alloc>
			memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0103140:	83 ec 04             	sub    $0x4,%esp
f0103143:	ff 73 10             	pushl  0x10(%ebx)
f0103146:	89 f8                	mov    %edi,%eax
f0103148:	03 43 04             	add    0x4(%ebx),%eax
f010314b:	50                   	push   %eax
f010314c:	ff 73 08             	pushl  0x8(%ebx)
f010314f:	e8 da 29 00 00       	call   f0105b2e <memmove>
			memset((void *)ph->p_va+ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0103154:	8b 43 10             	mov    0x10(%ebx),%eax
f0103157:	83 c4 0c             	add    $0xc,%esp
f010315a:	8b 53 14             	mov    0x14(%ebx),%edx
f010315d:	29 c2                	sub    %eax,%edx
f010315f:	52                   	push   %edx
f0103160:	6a 00                	push   $0x0
f0103162:	03 43 08             	add    0x8(%ebx),%eax
f0103165:	50                   	push   %eax
f0103166:	e8 76 29 00 00       	call   f0105ae1 <memset>
f010316b:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
	struct Elf *elf = (struct Elf *)binary;
	struct Proghdr *eph, *ph = (struct Proghdr *) (binary + (elf->e_phoff));
	eph = ph + elf->e_phnum;
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++)
f010316e:	83 c3 20             	add    $0x20,%ebx
f0103171:	39 de                	cmp    %ebx,%esi
f0103173:	77 b8                	ja     f010312d <env_create+0x72>

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103175:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010317a:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010317f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103182:	e8 2f fc ff ff       	call   f0102db6 <region_alloc>
	lcr3(PADDR(kern_pgdir));
f0103187:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010318c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103191:	77 15                	ja     f01031a8 <env_create+0xed>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103193:	50                   	push   %eax
f0103194:	68 e8 67 10 f0       	push   $0xf01067e8
f0103199:	68 76 01 00 00       	push   $0x176
f010319e:	68 df 79 10 f0       	push   $0xf01079df
f01031a3:	e8 98 ce ff ff       	call   f0100040 <_panic>
f01031a8:	05 00 00 00 10       	add    $0x10000000,%eax
f01031ad:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = elf->e_entry;
f01031b0:	8b 47 18             	mov    0x18(%edi),%eax
f01031b3:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01031b6:	89 41 30             	mov    %eax,0x30(%ecx)
	struct Env *e;
	if (env_alloc(&e, 0) < 0) {
		panic("env_create: env_alloc failed");
	}
	load_icode(e ,binary);
}
f01031b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031bc:	5b                   	pop    %ebx
f01031bd:	5e                   	pop    %esi
f01031be:	5f                   	pop    %edi
f01031bf:	5d                   	pop    %ebp
f01031c0:	c3                   	ret    

f01031c1 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01031c1:	55                   	push   %ebp
f01031c2:	89 e5                	mov    %esp,%ebp
f01031c4:	57                   	push   %edi
f01031c5:	56                   	push   %esi
f01031c6:	53                   	push   %ebx
f01031c7:	83 ec 1c             	sub    $0x1c,%esp
f01031ca:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01031cd:	e8 30 2f 00 00       	call   f0106102 <cpunum>
f01031d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01031d5:	39 b8 28 10 23 f0    	cmp    %edi,-0xfdcefd8(%eax)
f01031db:	75 29                	jne    f0103206 <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01031dd:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031e2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031e7:	77 15                	ja     f01031fe <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031e9:	50                   	push   %eax
f01031ea:	68 e8 67 10 f0       	push   $0xf01067e8
f01031ef:	68 9a 01 00 00       	push   $0x19a
f01031f4:	68 df 79 10 f0       	push   $0xf01079df
f01031f9:	e8 42 ce ff ff       	call   f0100040 <_panic>
f01031fe:	05 00 00 00 10       	add    $0x10000000,%eax
f0103203:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103206:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103209:	e8 f4 2e 00 00       	call   f0106102 <cpunum>
f010320e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103211:	ba 00 00 00 00       	mov    $0x0,%edx
f0103216:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f010321d:	74 11                	je     f0103230 <env_free+0x6f>
f010321f:	e8 de 2e 00 00       	call   f0106102 <cpunum>
f0103224:	6b c0 74             	imul   $0x74,%eax,%eax
f0103227:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f010322d:	8b 50 48             	mov    0x48(%eax),%edx
f0103230:	83 ec 04             	sub    $0x4,%esp
f0103233:	53                   	push   %ebx
f0103234:	52                   	push   %edx
f0103235:	68 1c 7a 10 f0       	push   $0xf0107a1c
f010323a:	e8 16 04 00 00       	call   f0103655 <cprintf>
f010323f:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103242:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103249:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010324c:	89 d0                	mov    %edx,%eax
f010324e:	c1 e0 02             	shl    $0x2,%eax
f0103251:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103254:	8b 47 60             	mov    0x60(%edi),%eax
f0103257:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010325a:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103260:	0f 84 a8 00 00 00    	je     f010330e <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103266:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010326c:	89 f0                	mov    %esi,%eax
f010326e:	c1 e8 0c             	shr    $0xc,%eax
f0103271:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103274:	39 05 88 0e 23 f0    	cmp    %eax,0xf0230e88
f010327a:	77 15                	ja     f0103291 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010327c:	56                   	push   %esi
f010327d:	68 c4 67 10 f0       	push   $0xf01067c4
f0103282:	68 a9 01 00 00       	push   $0x1a9
f0103287:	68 df 79 10 f0       	push   $0xf01079df
f010328c:	e8 af cd ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103291:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103294:	c1 e0 16             	shl    $0x16,%eax
f0103297:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010329a:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010329f:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01032a6:	01 
f01032a7:	74 17                	je     f01032c0 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01032a9:	83 ec 08             	sub    $0x8,%esp
f01032ac:	89 d8                	mov    %ebx,%eax
f01032ae:	c1 e0 0c             	shl    $0xc,%eax
f01032b1:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01032b4:	50                   	push   %eax
f01032b5:	ff 77 60             	pushl  0x60(%edi)
f01032b8:	e8 fc de ff ff       	call   f01011b9 <page_remove>
f01032bd:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01032c0:	83 c3 01             	add    $0x1,%ebx
f01032c3:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01032c9:	75 d4                	jne    f010329f <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01032cb:	8b 47 60             	mov    0x60(%edi),%eax
f01032ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01032d1:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01032d8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01032db:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f01032e1:	72 14                	jb     f01032f7 <env_free+0x136>
		panic("pa2page called with invalid pa");
f01032e3:	83 ec 04             	sub    $0x4,%esp
f01032e6:	68 94 6e 10 f0       	push   $0xf0106e94
f01032eb:	6a 51                	push   $0x51
f01032ed:	68 d9 76 10 f0       	push   $0xf01076d9
f01032f2:	e8 49 cd ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01032f7:	83 ec 0c             	sub    $0xc,%esp
f01032fa:	a1 90 0e 23 f0       	mov    0xf0230e90,%eax
f01032ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103302:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103305:	50                   	push   %eax
f0103306:	e8 e1 dc ff ff       	call   f0100fec <page_decref>
f010330b:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010330e:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103312:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103315:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010331a:	0f 85 29 ff ff ff    	jne    f0103249 <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103320:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103323:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103328:	77 15                	ja     f010333f <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010332a:	50                   	push   %eax
f010332b:	68 e8 67 10 f0       	push   $0xf01067e8
f0103330:	68 b7 01 00 00       	push   $0x1b7
f0103335:	68 df 79 10 f0       	push   $0xf01079df
f010333a:	e8 01 cd ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f010333f:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103346:	05 00 00 00 10       	add    $0x10000000,%eax
f010334b:	c1 e8 0c             	shr    $0xc,%eax
f010334e:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f0103354:	72 14                	jb     f010336a <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f0103356:	83 ec 04             	sub    $0x4,%esp
f0103359:	68 94 6e 10 f0       	push   $0xf0106e94
f010335e:	6a 51                	push   $0x51
f0103360:	68 d9 76 10 f0       	push   $0xf01076d9
f0103365:	e8 d6 cc ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f010336a:	83 ec 0c             	sub    $0xc,%esp
f010336d:	8b 15 90 0e 23 f0    	mov    0xf0230e90,%edx
f0103373:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103376:	50                   	push   %eax
f0103377:	e8 70 dc ff ff       	call   f0100fec <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010337c:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103383:	a1 48 02 23 f0       	mov    0xf0230248,%eax
f0103388:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010338b:	89 3d 48 02 23 f0    	mov    %edi,0xf0230248
}
f0103391:	83 c4 10             	add    $0x10,%esp
f0103394:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103397:	5b                   	pop    %ebx
f0103398:	5e                   	pop    %esi
f0103399:	5f                   	pop    %edi
f010339a:	5d                   	pop    %ebp
f010339b:	c3                   	ret    

f010339c <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010339c:	55                   	push   %ebp
f010339d:	89 e5                	mov    %esp,%ebp
f010339f:	53                   	push   %ebx
f01033a0:	83 ec 04             	sub    $0x4,%esp
f01033a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01033a6:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01033aa:	75 19                	jne    f01033c5 <env_destroy+0x29>
f01033ac:	e8 51 2d 00 00       	call   f0106102 <cpunum>
f01033b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01033b4:	3b 98 28 10 23 f0    	cmp    -0xfdcefd8(%eax),%ebx
f01033ba:	74 09                	je     f01033c5 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01033bc:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01033c3:	eb 33                	jmp    f01033f8 <env_destroy+0x5c>
	}

	env_free(e);
f01033c5:	83 ec 0c             	sub    $0xc,%esp
f01033c8:	53                   	push   %ebx
f01033c9:	e8 f3 fd ff ff       	call   f01031c1 <env_free>

	if (curenv == e) {
f01033ce:	e8 2f 2d 00 00       	call   f0106102 <cpunum>
f01033d3:	6b c0 74             	imul   $0x74,%eax,%eax
f01033d6:	83 c4 10             	add    $0x10,%esp
f01033d9:	3b 98 28 10 23 f0    	cmp    -0xfdcefd8(%eax),%ebx
f01033df:	75 17                	jne    f01033f8 <env_destroy+0x5c>
		curenv = NULL;
f01033e1:	e8 1c 2d 00 00       	call   f0106102 <cpunum>
f01033e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01033e9:	c7 80 28 10 23 f0 00 	movl   $0x0,-0xfdcefd8(%eax)
f01033f0:	00 00 00 
		sched_yield();
f01033f3:	e8 0a 15 00 00       	call   f0104902 <sched_yield>
	}
}
f01033f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01033fb:	c9                   	leave  
f01033fc:	c3                   	ret    

f01033fd <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01033fd:	55                   	push   %ebp
f01033fe:	89 e5                	mov    %esp,%ebp
f0103400:	53                   	push   %ebx
f0103401:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103404:	e8 f9 2c 00 00       	call   f0106102 <cpunum>
f0103409:	6b c0 74             	imul   $0x74,%eax,%eax
f010340c:	8b 98 28 10 23 f0    	mov    -0xfdcefd8(%eax),%ebx
f0103412:	e8 eb 2c 00 00       	call   f0106102 <cpunum>
f0103417:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f010341a:	8b 65 08             	mov    0x8(%ebp),%esp
f010341d:	61                   	popa   
f010341e:	07                   	pop    %es
f010341f:	1f                   	pop    %ds
f0103420:	83 c4 08             	add    $0x8,%esp
f0103423:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103424:	83 ec 04             	sub    $0x4,%esp
f0103427:	68 32 7a 10 f0       	push   $0xf0107a32
f010342c:	68 ee 01 00 00       	push   $0x1ee
f0103431:	68 df 79 10 f0       	push   $0xf01079df
f0103436:	e8 05 cc ff ff       	call   f0100040 <_panic>

f010343b <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010343b:	55                   	push   %ebp
f010343c:	89 e5                	mov    %esp,%ebp
f010343e:	53                   	push   %ebx
f010343f:	83 ec 04             	sub    $0x4,%esp
f0103442:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv && curenv->env_status == ENV_RUNNING) {
f0103445:	e8 b8 2c 00 00       	call   f0106102 <cpunum>
f010344a:	6b c0 74             	imul   $0x74,%eax,%eax
f010344d:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f0103454:	74 29                	je     f010347f <env_run+0x44>
f0103456:	e8 a7 2c 00 00       	call   f0106102 <cpunum>
f010345b:	6b c0 74             	imul   $0x74,%eax,%eax
f010345e:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103464:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103468:	75 15                	jne    f010347f <env_run+0x44>
		curenv->env_status = ENV_RUNNABLE;
f010346a:	e8 93 2c 00 00       	call   f0106102 <cpunum>
f010346f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103472:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103478:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	}
	curenv = e;
f010347f:	e8 7e 2c 00 00       	call   f0106102 <cpunum>
f0103484:	6b c0 74             	imul   $0x74,%eax,%eax
f0103487:	89 98 28 10 23 f0    	mov    %ebx,-0xfdcefd8(%eax)
	e->env_status = ENV_RUNNING;
f010348d:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f0103494:	83 43 58 01          	addl   $0x1,0x58(%ebx)
	lcr3(PADDR(e->env_pgdir));
f0103498:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010349b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034a0:	77 15                	ja     f01034b7 <env_run+0x7c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034a2:	50                   	push   %eax
f01034a3:	68 e8 67 10 f0       	push   $0xf01067e8
f01034a8:	68 12 02 00 00       	push   $0x212
f01034ad:	68 df 79 10 f0       	push   $0xf01079df
f01034b2:	e8 89 cb ff ff       	call   f0100040 <_panic>
f01034b7:	05 00 00 00 10       	add    $0x10000000,%eax
f01034bc:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01034bf:	83 ec 0c             	sub    $0xc,%esp
f01034c2:	68 c0 17 12 f0       	push   $0xf01217c0
f01034c7:	e8 41 2f 00 00       	call   f010640d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01034cc:	f3 90                	pause  
	unlock_kernel();
	env_pop_tf(&e->env_tf);
f01034ce:	89 1c 24             	mov    %ebx,(%esp)
f01034d1:	e8 27 ff ff ff       	call   f01033fd <env_pop_tf>

f01034d6 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01034d6:	55                   	push   %ebp
f01034d7:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034d9:	ba 70 00 00 00       	mov    $0x70,%edx
f01034de:	8b 45 08             	mov    0x8(%ebp),%eax
f01034e1:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034e2:	ba 71 00 00 00       	mov    $0x71,%edx
f01034e7:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01034e8:	0f b6 c0             	movzbl %al,%eax
}
f01034eb:	5d                   	pop    %ebp
f01034ec:	c3                   	ret    

f01034ed <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01034ed:	55                   	push   %ebp
f01034ee:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034f0:	ba 70 00 00 00       	mov    $0x70,%edx
f01034f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01034f8:	ee                   	out    %al,(%dx)
f01034f9:	ba 71 00 00 00       	mov    $0x71,%edx
f01034fe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103501:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103502:	5d                   	pop    %ebp
f0103503:	c3                   	ret    

f0103504 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103504:	55                   	push   %ebp
f0103505:	89 e5                	mov    %esp,%ebp
f0103507:	56                   	push   %esi
f0103508:	53                   	push   %ebx
f0103509:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010350c:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103512:	80 3d 4c 02 23 f0 00 	cmpb   $0x0,0xf023024c
f0103519:	74 5a                	je     f0103575 <irq_setmask_8259A+0x71>
f010351b:	89 c6                	mov    %eax,%esi
f010351d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103522:	ee                   	out    %al,(%dx)
f0103523:	66 c1 e8 08          	shr    $0x8,%ax
f0103527:	ba a1 00 00 00       	mov    $0xa1,%edx
f010352c:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010352d:	83 ec 0c             	sub    $0xc,%esp
f0103530:	68 3e 7a 10 f0       	push   $0xf0107a3e
f0103535:	e8 1b 01 00 00       	call   f0103655 <cprintf>
f010353a:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010353d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103542:	0f b7 f6             	movzwl %si,%esi
f0103545:	f7 d6                	not    %esi
f0103547:	0f a3 de             	bt     %ebx,%esi
f010354a:	73 11                	jae    f010355d <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f010354c:	83 ec 08             	sub    $0x8,%esp
f010354f:	53                   	push   %ebx
f0103550:	68 1b 7f 10 f0       	push   $0xf0107f1b
f0103555:	e8 fb 00 00 00       	call   f0103655 <cprintf>
f010355a:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010355d:	83 c3 01             	add    $0x1,%ebx
f0103560:	83 fb 10             	cmp    $0x10,%ebx
f0103563:	75 e2                	jne    f0103547 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103565:	83 ec 0c             	sub    $0xc,%esp
f0103568:	68 ad 79 10 f0       	push   $0xf01079ad
f010356d:	e8 e3 00 00 00       	call   f0103655 <cprintf>
f0103572:	83 c4 10             	add    $0x10,%esp
}
f0103575:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103578:	5b                   	pop    %ebx
f0103579:	5e                   	pop    %esi
f010357a:	5d                   	pop    %ebp
f010357b:	c3                   	ret    

f010357c <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010357c:	c6 05 4c 02 23 f0 01 	movb   $0x1,0xf023024c
f0103583:	ba 21 00 00 00       	mov    $0x21,%edx
f0103588:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010358d:	ee                   	out    %al,(%dx)
f010358e:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103593:	ee                   	out    %al,(%dx)
f0103594:	ba 20 00 00 00       	mov    $0x20,%edx
f0103599:	b8 11 00 00 00       	mov    $0x11,%eax
f010359e:	ee                   	out    %al,(%dx)
f010359f:	ba 21 00 00 00       	mov    $0x21,%edx
f01035a4:	b8 20 00 00 00       	mov    $0x20,%eax
f01035a9:	ee                   	out    %al,(%dx)
f01035aa:	b8 04 00 00 00       	mov    $0x4,%eax
f01035af:	ee                   	out    %al,(%dx)
f01035b0:	b8 03 00 00 00       	mov    $0x3,%eax
f01035b5:	ee                   	out    %al,(%dx)
f01035b6:	ba a0 00 00 00       	mov    $0xa0,%edx
f01035bb:	b8 11 00 00 00       	mov    $0x11,%eax
f01035c0:	ee                   	out    %al,(%dx)
f01035c1:	ba a1 00 00 00       	mov    $0xa1,%edx
f01035c6:	b8 28 00 00 00       	mov    $0x28,%eax
f01035cb:	ee                   	out    %al,(%dx)
f01035cc:	b8 02 00 00 00       	mov    $0x2,%eax
f01035d1:	ee                   	out    %al,(%dx)
f01035d2:	b8 01 00 00 00       	mov    $0x1,%eax
f01035d7:	ee                   	out    %al,(%dx)
f01035d8:	ba 20 00 00 00       	mov    $0x20,%edx
f01035dd:	b8 68 00 00 00       	mov    $0x68,%eax
f01035e2:	ee                   	out    %al,(%dx)
f01035e3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01035e8:	ee                   	out    %al,(%dx)
f01035e9:	ba a0 00 00 00       	mov    $0xa0,%edx
f01035ee:	b8 68 00 00 00       	mov    $0x68,%eax
f01035f3:	ee                   	out    %al,(%dx)
f01035f4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01035f9:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01035fa:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103601:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103605:	74 13                	je     f010361a <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103607:	55                   	push   %ebp
f0103608:	89 e5                	mov    %esp,%ebp
f010360a:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f010360d:	0f b7 c0             	movzwl %ax,%eax
f0103610:	50                   	push   %eax
f0103611:	e8 ee fe ff ff       	call   f0103504 <irq_setmask_8259A>
f0103616:	83 c4 10             	add    $0x10,%esp
}
f0103619:	c9                   	leave  
f010361a:	f3 c3                	repz ret 

f010361c <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010361c:	55                   	push   %ebp
f010361d:	89 e5                	mov    %esp,%ebp
f010361f:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103622:	ff 75 08             	pushl  0x8(%ebp)
f0103625:	e8 67 d1 ff ff       	call   f0100791 <cputchar>
	*cnt++;
}
f010362a:	83 c4 10             	add    $0x10,%esp
f010362d:	c9                   	leave  
f010362e:	c3                   	ret    

f010362f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010362f:	55                   	push   %ebp
f0103630:	89 e5                	mov    %esp,%ebp
f0103632:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103635:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010363c:	ff 75 0c             	pushl  0xc(%ebp)
f010363f:	ff 75 08             	pushl  0x8(%ebp)
f0103642:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103645:	50                   	push   %eax
f0103646:	68 1c 36 10 f0       	push   $0xf010361c
f010364b:	e8 6c 1d 00 00       	call   f01053bc <vprintfmt>
	return cnt;
}
f0103650:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103653:	c9                   	leave  
f0103654:	c3                   	ret    

f0103655 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103655:	55                   	push   %ebp
f0103656:	89 e5                	mov    %esp,%ebp
f0103658:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010365b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010365e:	50                   	push   %eax
f010365f:	ff 75 08             	pushl  0x8(%ebp)
f0103662:	e8 c8 ff ff ff       	call   f010362f <vcprintf>
	va_end(ap);

	return cnt;
}
f0103667:	c9                   	leave  
f0103668:	c3                   	ret    

f0103669 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103669:	55                   	push   %ebp
f010366a:	89 e5                	mov    %esp,%ebp
f010366c:	57                   	push   %edi
f010366d:	56                   	push   %esi
f010366e:	53                   	push   %ebx
f010366f:	83 ec 0c             	sub    $0xc,%esp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cpunum() * (KSTKSIZE + KSTKGAP);
f0103672:	e8 8b 2a 00 00       	call   f0106102 <cpunum>
f0103677:	89 c3                	mov    %eax,%ebx
f0103679:	e8 84 2a 00 00       	call   f0106102 <cpunum>
f010367e:	6b db 74             	imul   $0x74,%ebx,%ebx
f0103681:	c1 e0 10             	shl    $0x10,%eax
f0103684:	89 c2                	mov    %eax,%edx
f0103686:	b8 00 00 00 f0       	mov    $0xf0000000,%eax
f010368b:	29 d0                	sub    %edx,%eax
f010368d:	89 83 30 10 23 f0    	mov    %eax,-0xfdcefd0(%ebx)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103693:	e8 6a 2a 00 00       	call   f0106102 <cpunum>
f0103698:	6b c0 74             	imul   $0x74,%eax,%eax
f010369b:	66 c7 80 34 10 23 f0 	movw   $0x10,-0xfdcefcc(%eax)
f01036a2:	10 00 
	thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate);
f01036a4:	e8 59 2a 00 00       	call   f0106102 <cpunum>
f01036a9:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ac:	66 c7 80 92 10 23 f0 	movw   $0x68,-0xfdcef6e(%eax)
f01036b3:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f01036b5:	e8 48 2a 00 00       	call   f0106102 <cpunum>
f01036ba:	8d 58 05             	lea    0x5(%eax),%ebx
f01036bd:	e8 40 2a 00 00       	call   f0106102 <cpunum>
f01036c2:	89 c7                	mov    %eax,%edi
f01036c4:	e8 39 2a 00 00       	call   f0106102 <cpunum>
f01036c9:	89 c6                	mov    %eax,%esi
f01036cb:	e8 32 2a 00 00       	call   f0106102 <cpunum>
f01036d0:	66 c7 04 dd 40 13 12 	movw   $0x67,-0xfedecc0(,%ebx,8)
f01036d7:	f0 67 00 
f01036da:	6b ff 74             	imul   $0x74,%edi,%edi
f01036dd:	81 c7 2c 10 23 f0    	add    $0xf023102c,%edi
f01036e3:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f01036ea:	f0 
f01036eb:	6b d6 74             	imul   $0x74,%esi,%edx
f01036ee:	81 c2 2c 10 23 f0    	add    $0xf023102c,%edx
f01036f4:	c1 ea 10             	shr    $0x10,%edx
f01036f7:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f01036fe:	c6 04 dd 45 13 12 f0 	movb   $0x99,-0xfedecbb(,%ebx,8)
f0103705:	99 
f0103706:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f010370d:	40 
f010370e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103711:	05 2c 10 23 f0       	add    $0xf023102c,%eax
f0103716:	c1 e8 18             	shr    $0x18,%eax
f0103719:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0103720:	e8 dd 29 00 00       	call   f0106102 <cpunum>
f0103725:	80 24 c5 6d 13 12 f0 	andb   $0xef,-0xfedec93(,%eax,8)
f010372c:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * cpunum());
f010372d:	e8 d0 29 00 00       	call   f0106102 <cpunum>
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103732:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
f0103739:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f010373c:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f0103741:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103744:	83 c4 0c             	add    $0xc,%esp
f0103747:	5b                   	pop    %ebx
f0103748:	5e                   	pop    %esi
f0103749:	5f                   	pop    %edi
f010374a:	5d                   	pop    %ebp
f010374b:	c3                   	ret    

f010374c <trap_init>:
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	int i;
	for (i = 0; i < 256; i++) {
f010374c:	b8 00 00 00 00       	mov    $0x0,%eax
		SETGATE(idt[i], 0, GD_KT, handlers[i], 0);
f0103751:	8b 14 85 b2 13 12 f0 	mov    -0xfedec4e(,%eax,4),%edx
f0103758:	66 89 14 c5 60 02 23 	mov    %dx,-0xfdcfda0(,%eax,8)
f010375f:	f0 
f0103760:	66 c7 04 c5 62 02 23 	movw   $0x8,-0xfdcfd9e(,%eax,8)
f0103767:	f0 08 00 
f010376a:	c6 04 c5 64 02 23 f0 	movb   $0x0,-0xfdcfd9c(,%eax,8)
f0103771:	00 
f0103772:	c6 04 c5 65 02 23 f0 	movb   $0x8e,-0xfdcfd9b(,%eax,8)
f0103779:	8e 
f010377a:	c1 ea 10             	shr    $0x10,%edx
f010377d:	66 89 14 c5 66 02 23 	mov    %dx,-0xfdcfd9a(,%eax,8)
f0103784:	f0 
{
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	int i;
	for (i = 0; i < 256; i++) {
f0103785:	83 c0 01             	add    $0x1,%eax
f0103788:	3d 00 01 00 00       	cmp    $0x100,%eax
f010378d:	75 c2                	jne    f0103751 <trap_init+0x5>

extern unsigned handlers[];

void
trap_init(void)
{
f010378f:	55                   	push   %ebp
f0103790:	89 e5                	mov    %esp,%ebp
f0103792:	83 ec 08             	sub    $0x8,%esp
	// LAB 3: Your code here.
	int i;
	for (i = 0; i < 256; i++) {
		SETGATE(idt[i], 0, GD_KT, handlers[i], 0);
	}
	SETGATE(idt[T_BRKPT], 0, GD_KT, handlers[T_BRKPT], 3);
f0103795:	a1 be 13 12 f0       	mov    0xf01213be,%eax
f010379a:	66 a3 78 02 23 f0    	mov    %ax,0xf0230278
f01037a0:	66 c7 05 7a 02 23 f0 	movw   $0x8,0xf023027a
f01037a7:	08 00 
f01037a9:	c6 05 7c 02 23 f0 00 	movb   $0x0,0xf023027c
f01037b0:	c6 05 7d 02 23 f0 ee 	movb   $0xee,0xf023027d
f01037b7:	c1 e8 10             	shr    $0x10,%eax
f01037ba:	66 a3 7e 02 23 f0    	mov    %ax,0xf023027e
	SETGATE(idt[T_SYSCALL], 0, GD_KT, handlers[T_SYSCALL], 3);
f01037c0:	a1 72 14 12 f0       	mov    0xf0121472,%eax
f01037c5:	66 a3 e0 03 23 f0    	mov    %ax,0xf02303e0
f01037cb:	66 c7 05 e2 03 23 f0 	movw   $0x8,0xf02303e2
f01037d2:	08 00 
f01037d4:	c6 05 e4 03 23 f0 00 	movb   $0x0,0xf02303e4
f01037db:	c6 05 e5 03 23 f0 ee 	movb   $0xee,0xf02303e5
f01037e2:	c1 e8 10             	shr    $0x10,%eax
f01037e5:	66 a3 e6 03 23 f0    	mov    %ax,0xf02303e6

	// Per-CPU setup 
	trap_init_percpu();
f01037eb:	e8 79 fe ff ff       	call   f0103669 <trap_init_percpu>
}
f01037f0:	c9                   	leave  
f01037f1:	c3                   	ret    

f01037f2 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01037f2:	55                   	push   %ebp
f01037f3:	89 e5                	mov    %esp,%ebp
f01037f5:	53                   	push   %ebx
f01037f6:	83 ec 0c             	sub    $0xc,%esp
f01037f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01037fc:	ff 33                	pushl  (%ebx)
f01037fe:	68 52 7a 10 f0       	push   $0xf0107a52
f0103803:	e8 4d fe ff ff       	call   f0103655 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103808:	83 c4 08             	add    $0x8,%esp
f010380b:	ff 73 04             	pushl  0x4(%ebx)
f010380e:	68 61 7a 10 f0       	push   $0xf0107a61
f0103813:	e8 3d fe ff ff       	call   f0103655 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103818:	83 c4 08             	add    $0x8,%esp
f010381b:	ff 73 08             	pushl  0x8(%ebx)
f010381e:	68 70 7a 10 f0       	push   $0xf0107a70
f0103823:	e8 2d fe ff ff       	call   f0103655 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103828:	83 c4 08             	add    $0x8,%esp
f010382b:	ff 73 0c             	pushl  0xc(%ebx)
f010382e:	68 7f 7a 10 f0       	push   $0xf0107a7f
f0103833:	e8 1d fe ff ff       	call   f0103655 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103838:	83 c4 08             	add    $0x8,%esp
f010383b:	ff 73 10             	pushl  0x10(%ebx)
f010383e:	68 8e 7a 10 f0       	push   $0xf0107a8e
f0103843:	e8 0d fe ff ff       	call   f0103655 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103848:	83 c4 08             	add    $0x8,%esp
f010384b:	ff 73 14             	pushl  0x14(%ebx)
f010384e:	68 9d 7a 10 f0       	push   $0xf0107a9d
f0103853:	e8 fd fd ff ff       	call   f0103655 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103858:	83 c4 08             	add    $0x8,%esp
f010385b:	ff 73 18             	pushl  0x18(%ebx)
f010385e:	68 ac 7a 10 f0       	push   $0xf0107aac
f0103863:	e8 ed fd ff ff       	call   f0103655 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103868:	83 c4 08             	add    $0x8,%esp
f010386b:	ff 73 1c             	pushl  0x1c(%ebx)
f010386e:	68 bb 7a 10 f0       	push   $0xf0107abb
f0103873:	e8 dd fd ff ff       	call   f0103655 <cprintf>
}
f0103878:	83 c4 10             	add    $0x10,%esp
f010387b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010387e:	c9                   	leave  
f010387f:	c3                   	ret    

f0103880 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103880:	55                   	push   %ebp
f0103881:	89 e5                	mov    %esp,%ebp
f0103883:	56                   	push   %esi
f0103884:	53                   	push   %ebx
f0103885:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103888:	e8 75 28 00 00       	call   f0106102 <cpunum>
f010388d:	83 ec 04             	sub    $0x4,%esp
f0103890:	50                   	push   %eax
f0103891:	53                   	push   %ebx
f0103892:	68 1f 7b 10 f0       	push   $0xf0107b1f
f0103897:	e8 b9 fd ff ff       	call   f0103655 <cprintf>
	print_regs(&tf->tf_regs);
f010389c:	89 1c 24             	mov    %ebx,(%esp)
f010389f:	e8 4e ff ff ff       	call   f01037f2 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01038a4:	83 c4 08             	add    $0x8,%esp
f01038a7:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01038ab:	50                   	push   %eax
f01038ac:	68 3d 7b 10 f0       	push   $0xf0107b3d
f01038b1:	e8 9f fd ff ff       	call   f0103655 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01038b6:	83 c4 08             	add    $0x8,%esp
f01038b9:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01038bd:	50                   	push   %eax
f01038be:	68 50 7b 10 f0       	push   $0xf0107b50
f01038c3:	e8 8d fd ff ff       	call   f0103655 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01038c8:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f01038cb:	83 c4 10             	add    $0x10,%esp
f01038ce:	83 f8 13             	cmp    $0x13,%eax
f01038d1:	77 09                	ja     f01038dc <print_trapframe+0x5c>
		return excnames[trapno];
f01038d3:	8b 14 85 00 7e 10 f0 	mov    -0xfef8200(,%eax,4),%edx
f01038da:	eb 1f                	jmp    f01038fb <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f01038dc:	83 f8 30             	cmp    $0x30,%eax
f01038df:	74 15                	je     f01038f6 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01038e1:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f01038e4:	83 fa 10             	cmp    $0x10,%edx
f01038e7:	b9 e9 7a 10 f0       	mov    $0xf0107ae9,%ecx
f01038ec:	ba d6 7a 10 f0       	mov    $0xf0107ad6,%edx
f01038f1:	0f 43 d1             	cmovae %ecx,%edx
f01038f4:	eb 05                	jmp    f01038fb <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01038f6:	ba ca 7a 10 f0       	mov    $0xf0107aca,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01038fb:	83 ec 04             	sub    $0x4,%esp
f01038fe:	52                   	push   %edx
f01038ff:	50                   	push   %eax
f0103900:	68 63 7b 10 f0       	push   $0xf0107b63
f0103905:	e8 4b fd ff ff       	call   f0103655 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010390a:	83 c4 10             	add    $0x10,%esp
f010390d:	3b 1d 60 0a 23 f0    	cmp    0xf0230a60,%ebx
f0103913:	75 1a                	jne    f010392f <print_trapframe+0xaf>
f0103915:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103919:	75 14                	jne    f010392f <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010391b:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010391e:	83 ec 08             	sub    $0x8,%esp
f0103921:	50                   	push   %eax
f0103922:	68 75 7b 10 f0       	push   $0xf0107b75
f0103927:	e8 29 fd ff ff       	call   f0103655 <cprintf>
f010392c:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f010392f:	83 ec 08             	sub    $0x8,%esp
f0103932:	ff 73 2c             	pushl  0x2c(%ebx)
f0103935:	68 84 7b 10 f0       	push   $0xf0107b84
f010393a:	e8 16 fd ff ff       	call   f0103655 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010393f:	83 c4 10             	add    $0x10,%esp
f0103942:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103946:	75 49                	jne    f0103991 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103948:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010394b:	89 c2                	mov    %eax,%edx
f010394d:	83 e2 01             	and    $0x1,%edx
f0103950:	ba 03 7b 10 f0       	mov    $0xf0107b03,%edx
f0103955:	b9 f8 7a 10 f0       	mov    $0xf0107af8,%ecx
f010395a:	0f 44 ca             	cmove  %edx,%ecx
f010395d:	89 c2                	mov    %eax,%edx
f010395f:	83 e2 02             	and    $0x2,%edx
f0103962:	ba 15 7b 10 f0       	mov    $0xf0107b15,%edx
f0103967:	be 0f 7b 10 f0       	mov    $0xf0107b0f,%esi
f010396c:	0f 45 d6             	cmovne %esi,%edx
f010396f:	83 e0 04             	and    $0x4,%eax
f0103972:	be 4f 7c 10 f0       	mov    $0xf0107c4f,%esi
f0103977:	b8 1a 7b 10 f0       	mov    $0xf0107b1a,%eax
f010397c:	0f 44 c6             	cmove  %esi,%eax
f010397f:	51                   	push   %ecx
f0103980:	52                   	push   %edx
f0103981:	50                   	push   %eax
f0103982:	68 92 7b 10 f0       	push   $0xf0107b92
f0103987:	e8 c9 fc ff ff       	call   f0103655 <cprintf>
f010398c:	83 c4 10             	add    $0x10,%esp
f010398f:	eb 10                	jmp    f01039a1 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103991:	83 ec 0c             	sub    $0xc,%esp
f0103994:	68 ad 79 10 f0       	push   $0xf01079ad
f0103999:	e8 b7 fc ff ff       	call   f0103655 <cprintf>
f010399e:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01039a1:	83 ec 08             	sub    $0x8,%esp
f01039a4:	ff 73 30             	pushl  0x30(%ebx)
f01039a7:	68 a1 7b 10 f0       	push   $0xf0107ba1
f01039ac:	e8 a4 fc ff ff       	call   f0103655 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01039b1:	83 c4 08             	add    $0x8,%esp
f01039b4:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01039b8:	50                   	push   %eax
f01039b9:	68 b0 7b 10 f0       	push   $0xf0107bb0
f01039be:	e8 92 fc ff ff       	call   f0103655 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01039c3:	83 c4 08             	add    $0x8,%esp
f01039c6:	ff 73 38             	pushl  0x38(%ebx)
f01039c9:	68 c3 7b 10 f0       	push   $0xf0107bc3
f01039ce:	e8 82 fc ff ff       	call   f0103655 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01039d3:	83 c4 10             	add    $0x10,%esp
f01039d6:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01039da:	74 25                	je     f0103a01 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01039dc:	83 ec 08             	sub    $0x8,%esp
f01039df:	ff 73 3c             	pushl  0x3c(%ebx)
f01039e2:	68 d2 7b 10 f0       	push   $0xf0107bd2
f01039e7:	e8 69 fc ff ff       	call   f0103655 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01039ec:	83 c4 08             	add    $0x8,%esp
f01039ef:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01039f3:	50                   	push   %eax
f01039f4:	68 e1 7b 10 f0       	push   $0xf0107be1
f01039f9:	e8 57 fc ff ff       	call   f0103655 <cprintf>
f01039fe:	83 c4 10             	add    $0x10,%esp
	}
}
f0103a01:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a04:	5b                   	pop    %ebx
f0103a05:	5e                   	pop    %esi
f0103a06:	5d                   	pop    %ebp
f0103a07:	c3                   	ret    

f0103a08 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103a08:	55                   	push   %ebp
f0103a09:	89 e5                	mov    %esp,%ebp
f0103a0b:	57                   	push   %edi
f0103a0c:	56                   	push   %esi
f0103a0d:	53                   	push   %ebx
f0103a0e:	83 ec 1c             	sub    $0x1c,%esp
f0103a11:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103a14:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if (tf->tf_cs == GD_KT)
f0103a17:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0103a1c:	75 17                	jne    f0103a35 <page_fault_handler+0x2d>
		panic("a page fault happens in kernel [eip:%x]", tf->tf_eip);
f0103a1e:	ff 73 30             	pushl  0x30(%ebx)
f0103a21:	68 9c 7d 10 f0       	push   $0xf0107d9c
f0103a26:	68 31 01 00 00       	push   $0x131
f0103a2b:	68 f4 7b 10 f0       	push   $0xf0107bf4
f0103a30:	e8 0b c6 ff ff       	call   f0100040 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0103a35:	e8 c8 26 00 00       	call   f0106102 <cpunum>
f0103a3a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a3d:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103a43:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103a47:	0f 84 8f 00 00 00    	je     f0103adc <page_fault_handler+0xd4>
		uintptr_t stacktop = UXSTACKTOP;
		if (UXSTACKTOP - PGSIZE < tf->tf_esp && tf->tf_esp < UXSTACKTOP) {
f0103a4d:	8b 7b 3c             	mov    0x3c(%ebx),%edi
f0103a50:	8d 87 ff 0f 40 11    	lea    0x11400fff(%edi),%eax
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
		uintptr_t stacktop = UXSTACKTOP;
f0103a56:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f0103a5b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
f0103a60:	0f 43 f8             	cmovae %eax,%edi
		if (UXSTACKTOP - PGSIZE < tf->tf_esp && tf->tf_esp < UXSTACKTOP) {
			stacktop = tf->tf_esp;
		}
		uint32_t size = sizeof(struct UTrapframe) + sizeof(uint32_t);
		user_mem_assert(curenv, (void *)stacktop - size, size, PTE_U | PTE_W);
f0103a63:	8d 47 c8             	lea    -0x38(%edi),%eax
f0103a66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103a69:	e8 94 26 00 00       	call   f0106102 <cpunum>
f0103a6e:	6a 06                	push   $0x6
f0103a70:	6a 38                	push   $0x38
f0103a72:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103a75:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a78:	ff b0 28 10 23 f0    	pushl  -0xfdcefd8(%eax)
f0103a7e:	e8 e9 f2 ff ff       	call   f0102d6c <user_mem_assert>
		struct UTrapframe *utr = (struct UTrapframe *)(stacktop - size);
		utr->utf_fault_va = fault_va;
f0103a83:	89 77 c8             	mov    %esi,-0x38(%edi)
		utr->utf_err = tf->tf_err;
f0103a86:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103a89:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103a8c:	89 42 04             	mov    %eax,0x4(%edx)
		utr->utf_regs = tf->tf_regs;
f0103a8f:	83 ef 30             	sub    $0x30,%edi
f0103a92:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103a97:	89 de                	mov    %ebx,%esi
f0103a99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utr->utf_eflags = tf->tf_eflags;
f0103a9b:	8b 43 38             	mov    0x38(%ebx),%eax
f0103a9e:	89 42 2c             	mov    %eax,0x2c(%edx)
		utr->utf_esp = tf->tf_esp;
f0103aa1:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103aa4:	89 d6                	mov    %edx,%esi
f0103aa6:	89 42 30             	mov    %eax,0x30(%edx)
		utr->utf_eip = tf->tf_eip;
f0103aa9:	8b 43 30             	mov    0x30(%ebx),%eax
f0103aac:	89 42 28             	mov    %eax,0x28(%edx)
		tf->tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0103aaf:	e8 4e 26 00 00       	call   f0106102 <cpunum>
f0103ab4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ab7:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103abd:	8b 40 64             	mov    0x64(%eax),%eax
f0103ac0:	89 43 30             	mov    %eax,0x30(%ebx)
		tf->tf_esp = (uintptr_t)utr;
f0103ac3:	89 73 3c             	mov    %esi,0x3c(%ebx)
		env_run(curenv);
f0103ac6:	e8 37 26 00 00       	call   f0106102 <cpunum>
f0103acb:	83 c4 04             	add    $0x4,%esp
f0103ace:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ad1:	ff b0 28 10 23 f0    	pushl  -0xfdcefd8(%eax)
f0103ad7:	e8 5f f9 ff ff       	call   f010343b <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103adc:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0103adf:	e8 1e 26 00 00       	call   f0106102 <cpunum>
		tf->tf_esp = (uintptr_t)utr;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ae4:	57                   	push   %edi
f0103ae5:	56                   	push   %esi
		curenv->env_id, fault_va, tf->tf_eip);
f0103ae6:	6b c0 74             	imul   $0x74,%eax,%eax
		tf->tf_esp = (uintptr_t)utr;
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ae9:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103aef:	ff 70 48             	pushl  0x48(%eax)
f0103af2:	68 c4 7d 10 f0       	push   $0xf0107dc4
f0103af7:	e8 59 fb ff ff       	call   f0103655 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103afc:	89 1c 24             	mov    %ebx,(%esp)
f0103aff:	e8 7c fd ff ff       	call   f0103880 <print_trapframe>
	env_destroy(curenv);
f0103b04:	e8 f9 25 00 00       	call   f0106102 <cpunum>
f0103b09:	83 c4 04             	add    $0x4,%esp
f0103b0c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b0f:	ff b0 28 10 23 f0    	pushl  -0xfdcefd8(%eax)
f0103b15:	e8 82 f8 ff ff       	call   f010339c <env_destroy>
}
f0103b1a:	83 c4 10             	add    $0x10,%esp
f0103b1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103b20:	5b                   	pop    %ebx
f0103b21:	5e                   	pop    %esi
f0103b22:	5f                   	pop    %edi
f0103b23:	5d                   	pop    %ebp
f0103b24:	c3                   	ret    

f0103b25 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103b25:	55                   	push   %ebp
f0103b26:	89 e5                	mov    %esp,%ebp
f0103b28:	57                   	push   %edi
f0103b29:	56                   	push   %esi
f0103b2a:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103b2d:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103b2e:	83 3d 80 0e 23 f0 00 	cmpl   $0x0,0xf0230e80
f0103b35:	74 01                	je     f0103b38 <trap+0x13>
		asm volatile("hlt");
f0103b37:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103b38:	e8 c5 25 00 00       	call   f0106102 <cpunum>
f0103b3d:	6b d0 74             	imul   $0x74,%eax,%edx
f0103b40:	81 c2 20 10 23 f0    	add    $0xf0231020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0103b46:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b4b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103b4f:	83 f8 02             	cmp    $0x2,%eax
f0103b52:	75 10                	jne    f0103b64 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103b54:	83 ec 0c             	sub    $0xc,%esp
f0103b57:	68 c0 17 12 f0       	push   $0xf01217c0
f0103b5c:	e8 0f 28 00 00       	call   f0106370 <spin_lock>
f0103b61:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103b64:	9c                   	pushf  
f0103b65:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103b66:	f6 c4 02             	test   $0x2,%ah
f0103b69:	74 19                	je     f0103b84 <trap+0x5f>
f0103b6b:	68 00 7c 10 f0       	push   $0xf0107c00
f0103b70:	68 f3 76 10 f0       	push   $0xf01076f3
f0103b75:	68 fb 00 00 00       	push   $0xfb
f0103b7a:	68 f4 7b 10 f0       	push   $0xf0107bf4
f0103b7f:	e8 bc c4 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103b84:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103b88:	83 e0 03             	and    $0x3,%eax
f0103b8b:	66 83 f8 03          	cmp    $0x3,%ax
f0103b8f:	0f 85 a0 00 00 00    	jne    f0103c35 <trap+0x110>
f0103b95:	83 ec 0c             	sub    $0xc,%esp
f0103b98:	68 c0 17 12 f0       	push   $0xf01217c0
f0103b9d:	e8 ce 27 00 00       	call   f0106370 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0103ba2:	e8 5b 25 00 00       	call   f0106102 <cpunum>
f0103ba7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103baa:	83 c4 10             	add    $0x10,%esp
f0103bad:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f0103bb4:	75 19                	jne    f0103bcf <trap+0xaa>
f0103bb6:	68 19 7c 10 f0       	push   $0xf0107c19
f0103bbb:	68 f3 76 10 f0       	push   $0xf01076f3
f0103bc0:	68 03 01 00 00       	push   $0x103
f0103bc5:	68 f4 7b 10 f0       	push   $0xf0107bf4
f0103bca:	e8 71 c4 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103bcf:	e8 2e 25 00 00       	call   f0106102 <cpunum>
f0103bd4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bd7:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103bdd:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103be1:	75 2d                	jne    f0103c10 <trap+0xeb>
			env_free(curenv);
f0103be3:	e8 1a 25 00 00       	call   f0106102 <cpunum>
f0103be8:	83 ec 0c             	sub    $0xc,%esp
f0103beb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bee:	ff b0 28 10 23 f0    	pushl  -0xfdcefd8(%eax)
f0103bf4:	e8 c8 f5 ff ff       	call   f01031c1 <env_free>
			curenv = NULL;
f0103bf9:	e8 04 25 00 00       	call   f0106102 <cpunum>
f0103bfe:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c01:	c7 80 28 10 23 f0 00 	movl   $0x0,-0xfdcefd8(%eax)
f0103c08:	00 00 00 
			sched_yield();
f0103c0b:	e8 f2 0c 00 00       	call   f0104902 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103c10:	e8 ed 24 00 00       	call   f0106102 <cpunum>
f0103c15:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c18:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103c1e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103c23:	89 c7                	mov    %eax,%edi
f0103c25:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103c27:	e8 d6 24 00 00       	call   f0106102 <cpunum>
f0103c2c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c2f:	8b b0 28 10 23 f0    	mov    -0xfdcefd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103c35:	89 35 60 0a 23 f0    	mov    %esi,0xf0230a60
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	switch (tf->tf_trapno) {
f0103c3b:	8b 46 28             	mov    0x28(%esi),%eax
f0103c3e:	83 f8 0e             	cmp    $0xe,%eax
f0103c41:	74 0c                	je     f0103c4f <trap+0x12a>
f0103c43:	83 f8 30             	cmp    $0x30,%eax
f0103c46:	74 26                	je     f0103c6e <trap+0x149>
f0103c48:	83 f8 03             	cmp    $0x3,%eax
f0103c4b:	75 42                	jne    f0103c8f <trap+0x16a>
f0103c4d:	eb 11                	jmp    f0103c60 <trap+0x13b>
	case T_PGFLT:
		page_fault_handler(tf);
f0103c4f:	83 ec 0c             	sub    $0xc,%esp
f0103c52:	56                   	push   %esi
f0103c53:	e8 b0 fd ff ff       	call   f0103a08 <page_fault_handler>
f0103c58:	83 c4 10             	add    $0x10,%esp
f0103c5b:	e9 a3 00 00 00       	jmp    f0103d03 <trap+0x1de>
		return;
	case T_BRKPT:
		monitor(tf);
f0103c60:	83 ec 0c             	sub    $0xc,%esp
f0103c63:	56                   	push   %esi
f0103c64:	e8 d2 cc ff ff       	call   f010093b <monitor>
f0103c69:	83 c4 10             	add    $0x10,%esp
f0103c6c:	eb 21                	jmp    f0103c8f <trap+0x16a>
		break;
	case T_SYSCALL:
		tf->tf_regs.reg_eax = syscall(
f0103c6e:	83 ec 08             	sub    $0x8,%esp
f0103c71:	ff 76 04             	pushl  0x4(%esi)
f0103c74:	ff 36                	pushl  (%esi)
f0103c76:	ff 76 10             	pushl  0x10(%esi)
f0103c79:	ff 76 18             	pushl  0x18(%esi)
f0103c7c:	ff 76 14             	pushl  0x14(%esi)
f0103c7f:	ff 76 1c             	pushl  0x1c(%esi)
f0103c82:	e8 32 0d 00 00       	call   f01049b9 <syscall>
f0103c87:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103c8a:	83 c4 20             	add    $0x20,%esp
f0103c8d:	eb 74                	jmp    f0103d03 <trap+0x1de>
	}

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103c8f:	8b 46 28             	mov    0x28(%esi),%eax
f0103c92:	83 f8 27             	cmp    $0x27,%eax
f0103c95:	75 1a                	jne    f0103cb1 <trap+0x18c>
		cprintf("Spurious interrupt on irq 7\n");
f0103c97:	83 ec 0c             	sub    $0xc,%esp
f0103c9a:	68 20 7c 10 f0       	push   $0xf0107c20
f0103c9f:	e8 b1 f9 ff ff       	call   f0103655 <cprintf>
		print_trapframe(tf);
f0103ca4:	89 34 24             	mov    %esi,(%esp)
f0103ca7:	e8 d4 fb ff ff       	call   f0103880 <print_trapframe>
f0103cac:	83 c4 10             	add    $0x10,%esp
f0103caf:	eb 52                	jmp    f0103d03 <trap+0x1de>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0103cb1:	83 f8 20             	cmp    $0x20,%eax
f0103cb4:	75 0a                	jne    f0103cc0 <trap+0x19b>
		lapic_eoi();
f0103cb6:	e8 92 25 00 00       	call   f010624d <lapic_eoi>
		sched_yield();
f0103cbb:	e8 42 0c 00 00       	call   f0104902 <sched_yield>
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103cc0:	83 ec 0c             	sub    $0xc,%esp
f0103cc3:	56                   	push   %esi
f0103cc4:	e8 b7 fb ff ff       	call   f0103880 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103cc9:	83 c4 10             	add    $0x10,%esp
f0103ccc:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103cd1:	75 17                	jne    f0103cea <trap+0x1c5>
		panic("unhandled trap in kernel");
f0103cd3:	83 ec 04             	sub    $0x4,%esp
f0103cd6:	68 3d 7c 10 f0       	push   $0xf0107c3d
f0103cdb:	68 e1 00 00 00       	push   $0xe1
f0103ce0:	68 f4 7b 10 f0       	push   $0xf0107bf4
f0103ce5:	e8 56 c3 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0103cea:	e8 13 24 00 00       	call   f0106102 <cpunum>
f0103cef:	83 ec 0c             	sub    $0xc,%esp
f0103cf2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cf5:	ff b0 28 10 23 f0    	pushl  -0xfdcefd8(%eax)
f0103cfb:	e8 9c f6 ff ff       	call   f010339c <env_destroy>
f0103d00:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103d03:	e8 fa 23 00 00       	call   f0106102 <cpunum>
f0103d08:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d0b:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f0103d12:	74 2a                	je     f0103d3e <trap+0x219>
f0103d14:	e8 e9 23 00 00       	call   f0106102 <cpunum>
f0103d19:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d1c:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0103d22:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103d26:	75 16                	jne    f0103d3e <trap+0x219>
		env_run(curenv);
f0103d28:	e8 d5 23 00 00       	call   f0106102 <cpunum>
f0103d2d:	83 ec 0c             	sub    $0xc,%esp
f0103d30:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d33:	ff b0 28 10 23 f0    	pushl  -0xfdcefd8(%eax)
f0103d39:	e8 fd f6 ff ff       	call   f010343b <env_run>
	else
		sched_yield();
f0103d3e:	e8 bf 0b 00 00       	call   f0104902 <sched_yield>
f0103d43:	90                   	nop

f0103d44 <handler0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handler0, 0)
f0103d44:	6a 00                	push   $0x0
f0103d46:	6a 00                	push   $0x0
f0103d48:	e9 d0 0a 00 00       	jmp    f010481d <_alltraps>
f0103d4d:	90                   	nop

f0103d4e <handler1>:
TRAPHANDLER_NOEC(handler1, 1)
f0103d4e:	6a 00                	push   $0x0
f0103d50:	6a 01                	push   $0x1
f0103d52:	e9 c6 0a 00 00       	jmp    f010481d <_alltraps>
f0103d57:	90                   	nop

f0103d58 <handler2>:
TRAPHANDLER_NOEC(handler2, 2)
f0103d58:	6a 00                	push   $0x0
f0103d5a:	6a 02                	push   $0x2
f0103d5c:	e9 bc 0a 00 00       	jmp    f010481d <_alltraps>
f0103d61:	90                   	nop

f0103d62 <handler3>:
TRAPHANDLER_NOEC(handler3, 3)
f0103d62:	6a 00                	push   $0x0
f0103d64:	6a 03                	push   $0x3
f0103d66:	e9 b2 0a 00 00       	jmp    f010481d <_alltraps>
f0103d6b:	90                   	nop

f0103d6c <handler4>:
TRAPHANDLER_NOEC(handler4, 4)
f0103d6c:	6a 00                	push   $0x0
f0103d6e:	6a 04                	push   $0x4
f0103d70:	e9 a8 0a 00 00       	jmp    f010481d <_alltraps>
f0103d75:	90                   	nop

f0103d76 <handler5>:
TRAPHANDLER_NOEC(handler5, 5)
f0103d76:	6a 00                	push   $0x0
f0103d78:	6a 05                	push   $0x5
f0103d7a:	e9 9e 0a 00 00       	jmp    f010481d <_alltraps>
f0103d7f:	90                   	nop

f0103d80 <handler6>:
TRAPHANDLER_NOEC(handler6, 6)
f0103d80:	6a 00                	push   $0x0
f0103d82:	6a 06                	push   $0x6
f0103d84:	e9 94 0a 00 00       	jmp    f010481d <_alltraps>
f0103d89:	90                   	nop

f0103d8a <handler7>:
TRAPHANDLER_NOEC(handler7, 7)
f0103d8a:	6a 00                	push   $0x0
f0103d8c:	6a 07                	push   $0x7
f0103d8e:	e9 8a 0a 00 00       	jmp    f010481d <_alltraps>
f0103d93:	90                   	nop

f0103d94 <handler8>:
TRAPHANDLER(handler8, 8)
f0103d94:	6a 08                	push   $0x8
f0103d96:	e9 82 0a 00 00       	jmp    f010481d <_alltraps>
f0103d9b:	90                   	nop

f0103d9c <handler9>:
TRAPHANDLER_NOEC(handler9, 9)
f0103d9c:	6a 00                	push   $0x0
f0103d9e:	6a 09                	push   $0x9
f0103da0:	e9 78 0a 00 00       	jmp    f010481d <_alltraps>
f0103da5:	90                   	nop

f0103da6 <handler10>:
TRAPHANDLER(handler10, 10)
f0103da6:	6a 0a                	push   $0xa
f0103da8:	e9 70 0a 00 00       	jmp    f010481d <_alltraps>
f0103dad:	90                   	nop

f0103dae <handler11>:
TRAPHANDLER(handler11, 11)
f0103dae:	6a 0b                	push   $0xb
f0103db0:	e9 68 0a 00 00       	jmp    f010481d <_alltraps>
f0103db5:	90                   	nop

f0103db6 <handler12>:
TRAPHANDLER(handler12, 12)
f0103db6:	6a 0c                	push   $0xc
f0103db8:	e9 60 0a 00 00       	jmp    f010481d <_alltraps>
f0103dbd:	90                   	nop

f0103dbe <handler13>:
TRAPHANDLER(handler13, 13)
f0103dbe:	6a 0d                	push   $0xd
f0103dc0:	e9 58 0a 00 00       	jmp    f010481d <_alltraps>
f0103dc5:	90                   	nop

f0103dc6 <handler14>:
TRAPHANDLER(handler14, 14)
f0103dc6:	6a 0e                	push   $0xe
f0103dc8:	e9 50 0a 00 00       	jmp    f010481d <_alltraps>
f0103dcd:	90                   	nop

f0103dce <handler15>:
TRAPHANDLER_NOEC(handler15, 15)
f0103dce:	6a 00                	push   $0x0
f0103dd0:	6a 0f                	push   $0xf
f0103dd2:	e9 46 0a 00 00       	jmp    f010481d <_alltraps>
f0103dd7:	90                   	nop

f0103dd8 <handler16>:
TRAPHANDLER_NOEC(handler16, 16)
f0103dd8:	6a 00                	push   $0x0
f0103dda:	6a 10                	push   $0x10
f0103ddc:	e9 3c 0a 00 00       	jmp    f010481d <_alltraps>
f0103de1:	90                   	nop

f0103de2 <handler17>:
TRAPHANDLER_NOEC(handler17, 17)
f0103de2:	6a 00                	push   $0x0
f0103de4:	6a 11                	push   $0x11
f0103de6:	e9 32 0a 00 00       	jmp    f010481d <_alltraps>
f0103deb:	90                   	nop

f0103dec <handler18>:
TRAPHANDLER_NOEC(handler18, 18)
f0103dec:	6a 00                	push   $0x0
f0103dee:	6a 12                	push   $0x12
f0103df0:	e9 28 0a 00 00       	jmp    f010481d <_alltraps>
f0103df5:	90                   	nop

f0103df6 <handler19>:
TRAPHANDLER_NOEC(handler19, 19)
f0103df6:	6a 00                	push   $0x0
f0103df8:	6a 13                	push   $0x13
f0103dfa:	e9 1e 0a 00 00       	jmp    f010481d <_alltraps>
f0103dff:	90                   	nop

f0103e00 <handler20>:
TRAPHANDLER_NOEC(handler20, 20)
f0103e00:	6a 00                	push   $0x0
f0103e02:	6a 14                	push   $0x14
f0103e04:	e9 14 0a 00 00       	jmp    f010481d <_alltraps>
f0103e09:	90                   	nop

f0103e0a <handler21>:
TRAPHANDLER_NOEC(handler21, 21)
f0103e0a:	6a 00                	push   $0x0
f0103e0c:	6a 15                	push   $0x15
f0103e0e:	e9 0a 0a 00 00       	jmp    f010481d <_alltraps>
f0103e13:	90                   	nop

f0103e14 <handler22>:
TRAPHANDLER_NOEC(handler22, 22)
f0103e14:	6a 00                	push   $0x0
f0103e16:	6a 16                	push   $0x16
f0103e18:	e9 00 0a 00 00       	jmp    f010481d <_alltraps>
f0103e1d:	90                   	nop

f0103e1e <handler23>:
TRAPHANDLER_NOEC(handler23, 23)
f0103e1e:	6a 00                	push   $0x0
f0103e20:	6a 17                	push   $0x17
f0103e22:	e9 f6 09 00 00       	jmp    f010481d <_alltraps>
f0103e27:	90                   	nop

f0103e28 <handler24>:
TRAPHANDLER_NOEC(handler24, 24)
f0103e28:	6a 00                	push   $0x0
f0103e2a:	6a 18                	push   $0x18
f0103e2c:	e9 ec 09 00 00       	jmp    f010481d <_alltraps>
f0103e31:	90                   	nop

f0103e32 <handler25>:
TRAPHANDLER_NOEC(handler25, 25)
f0103e32:	6a 00                	push   $0x0
f0103e34:	6a 19                	push   $0x19
f0103e36:	e9 e2 09 00 00       	jmp    f010481d <_alltraps>
f0103e3b:	90                   	nop

f0103e3c <handler26>:
TRAPHANDLER_NOEC(handler26, 26)
f0103e3c:	6a 00                	push   $0x0
f0103e3e:	6a 1a                	push   $0x1a
f0103e40:	e9 d8 09 00 00       	jmp    f010481d <_alltraps>
f0103e45:	90                   	nop

f0103e46 <handler27>:
TRAPHANDLER_NOEC(handler27, 27)
f0103e46:	6a 00                	push   $0x0
f0103e48:	6a 1b                	push   $0x1b
f0103e4a:	e9 ce 09 00 00       	jmp    f010481d <_alltraps>
f0103e4f:	90                   	nop

f0103e50 <handler28>:
TRAPHANDLER_NOEC(handler28, 28)
f0103e50:	6a 00                	push   $0x0
f0103e52:	6a 1c                	push   $0x1c
f0103e54:	e9 c4 09 00 00       	jmp    f010481d <_alltraps>
f0103e59:	90                   	nop

f0103e5a <handler29>:
TRAPHANDLER_NOEC(handler29, 29)
f0103e5a:	6a 00                	push   $0x0
f0103e5c:	6a 1d                	push   $0x1d
f0103e5e:	e9 ba 09 00 00       	jmp    f010481d <_alltraps>
f0103e63:	90                   	nop

f0103e64 <handler30>:
TRAPHANDLER_NOEC(handler30, 30)
f0103e64:	6a 00                	push   $0x0
f0103e66:	6a 1e                	push   $0x1e
f0103e68:	e9 b0 09 00 00       	jmp    f010481d <_alltraps>
f0103e6d:	90                   	nop

f0103e6e <handler31>:
TRAPHANDLER_NOEC(handler31, 31)
f0103e6e:	6a 00                	push   $0x0
f0103e70:	6a 1f                	push   $0x1f
f0103e72:	e9 a6 09 00 00       	jmp    f010481d <_alltraps>
f0103e77:	90                   	nop

f0103e78 <handler32>:
TRAPHANDLER_NOEC(handler32, 32)
f0103e78:	6a 00                	push   $0x0
f0103e7a:	6a 20                	push   $0x20
f0103e7c:	e9 9c 09 00 00       	jmp    f010481d <_alltraps>
f0103e81:	90                   	nop

f0103e82 <handler33>:
TRAPHANDLER_NOEC(handler33, 33)
f0103e82:	6a 00                	push   $0x0
f0103e84:	6a 21                	push   $0x21
f0103e86:	e9 92 09 00 00       	jmp    f010481d <_alltraps>
f0103e8b:	90                   	nop

f0103e8c <handler34>:
TRAPHANDLER_NOEC(handler34, 34)
f0103e8c:	6a 00                	push   $0x0
f0103e8e:	6a 22                	push   $0x22
f0103e90:	e9 88 09 00 00       	jmp    f010481d <_alltraps>
f0103e95:	90                   	nop

f0103e96 <handler35>:
TRAPHANDLER_NOEC(handler35, 35)
f0103e96:	6a 00                	push   $0x0
f0103e98:	6a 23                	push   $0x23
f0103e9a:	e9 7e 09 00 00       	jmp    f010481d <_alltraps>
f0103e9f:	90                   	nop

f0103ea0 <handler36>:
TRAPHANDLER_NOEC(handler36, 36)
f0103ea0:	6a 00                	push   $0x0
f0103ea2:	6a 24                	push   $0x24
f0103ea4:	e9 74 09 00 00       	jmp    f010481d <_alltraps>
f0103ea9:	90                   	nop

f0103eaa <handler37>:
TRAPHANDLER_NOEC(handler37, 37)
f0103eaa:	6a 00                	push   $0x0
f0103eac:	6a 25                	push   $0x25
f0103eae:	e9 6a 09 00 00       	jmp    f010481d <_alltraps>
f0103eb3:	90                   	nop

f0103eb4 <handler38>:
TRAPHANDLER_NOEC(handler38, 38)
f0103eb4:	6a 00                	push   $0x0
f0103eb6:	6a 26                	push   $0x26
f0103eb8:	e9 60 09 00 00       	jmp    f010481d <_alltraps>
f0103ebd:	90                   	nop

f0103ebe <handler39>:
TRAPHANDLER_NOEC(handler39, 39)
f0103ebe:	6a 00                	push   $0x0
f0103ec0:	6a 27                	push   $0x27
f0103ec2:	e9 56 09 00 00       	jmp    f010481d <_alltraps>
f0103ec7:	90                   	nop

f0103ec8 <handler40>:
TRAPHANDLER_NOEC(handler40, 40)
f0103ec8:	6a 00                	push   $0x0
f0103eca:	6a 28                	push   $0x28
f0103ecc:	e9 4c 09 00 00       	jmp    f010481d <_alltraps>
f0103ed1:	90                   	nop

f0103ed2 <handler41>:
TRAPHANDLER_NOEC(handler41, 41)
f0103ed2:	6a 00                	push   $0x0
f0103ed4:	6a 29                	push   $0x29
f0103ed6:	e9 42 09 00 00       	jmp    f010481d <_alltraps>
f0103edb:	90                   	nop

f0103edc <handler42>:
TRAPHANDLER_NOEC(handler42, 42)
f0103edc:	6a 00                	push   $0x0
f0103ede:	6a 2a                	push   $0x2a
f0103ee0:	e9 38 09 00 00       	jmp    f010481d <_alltraps>
f0103ee5:	90                   	nop

f0103ee6 <handler43>:
TRAPHANDLER_NOEC(handler43, 43)
f0103ee6:	6a 00                	push   $0x0
f0103ee8:	6a 2b                	push   $0x2b
f0103eea:	e9 2e 09 00 00       	jmp    f010481d <_alltraps>
f0103eef:	90                   	nop

f0103ef0 <handler44>:
TRAPHANDLER_NOEC(handler44, 44)
f0103ef0:	6a 00                	push   $0x0
f0103ef2:	6a 2c                	push   $0x2c
f0103ef4:	e9 24 09 00 00       	jmp    f010481d <_alltraps>
f0103ef9:	90                   	nop

f0103efa <handler45>:
TRAPHANDLER_NOEC(handler45, 45)
f0103efa:	6a 00                	push   $0x0
f0103efc:	6a 2d                	push   $0x2d
f0103efe:	e9 1a 09 00 00       	jmp    f010481d <_alltraps>
f0103f03:	90                   	nop

f0103f04 <handler46>:
TRAPHANDLER_NOEC(handler46, 46)
f0103f04:	6a 00                	push   $0x0
f0103f06:	6a 2e                	push   $0x2e
f0103f08:	e9 10 09 00 00       	jmp    f010481d <_alltraps>
f0103f0d:	90                   	nop

f0103f0e <handler47>:
TRAPHANDLER_NOEC(handler47, 47)
f0103f0e:	6a 00                	push   $0x0
f0103f10:	6a 2f                	push   $0x2f
f0103f12:	e9 06 09 00 00       	jmp    f010481d <_alltraps>
f0103f17:	90                   	nop

f0103f18 <handler48>:
TRAPHANDLER_NOEC(handler48, 48)
f0103f18:	6a 00                	push   $0x0
f0103f1a:	6a 30                	push   $0x30
f0103f1c:	e9 fc 08 00 00       	jmp    f010481d <_alltraps>
f0103f21:	90                   	nop

f0103f22 <handler49>:
TRAPHANDLER_NOEC(handler49, 49)
f0103f22:	6a 00                	push   $0x0
f0103f24:	6a 31                	push   $0x31
f0103f26:	e9 f2 08 00 00       	jmp    f010481d <_alltraps>
f0103f2b:	90                   	nop

f0103f2c <handler50>:
TRAPHANDLER_NOEC(handler50, 50)
f0103f2c:	6a 00                	push   $0x0
f0103f2e:	6a 32                	push   $0x32
f0103f30:	e9 e8 08 00 00       	jmp    f010481d <_alltraps>
f0103f35:	90                   	nop

f0103f36 <handler51>:
TRAPHANDLER_NOEC(handler51, 51)
f0103f36:	6a 00                	push   $0x0
f0103f38:	6a 33                	push   $0x33
f0103f3a:	e9 de 08 00 00       	jmp    f010481d <_alltraps>
f0103f3f:	90                   	nop

f0103f40 <handler52>:
TRAPHANDLER_NOEC(handler52, 52)
f0103f40:	6a 00                	push   $0x0
f0103f42:	6a 34                	push   $0x34
f0103f44:	e9 d4 08 00 00       	jmp    f010481d <_alltraps>
f0103f49:	90                   	nop

f0103f4a <handler53>:
TRAPHANDLER_NOEC(handler53, 53)
f0103f4a:	6a 00                	push   $0x0
f0103f4c:	6a 35                	push   $0x35
f0103f4e:	e9 ca 08 00 00       	jmp    f010481d <_alltraps>
f0103f53:	90                   	nop

f0103f54 <handler54>:
TRAPHANDLER_NOEC(handler54, 54)
f0103f54:	6a 00                	push   $0x0
f0103f56:	6a 36                	push   $0x36
f0103f58:	e9 c0 08 00 00       	jmp    f010481d <_alltraps>
f0103f5d:	90                   	nop

f0103f5e <handler55>:
TRAPHANDLER_NOEC(handler55, 55)
f0103f5e:	6a 00                	push   $0x0
f0103f60:	6a 37                	push   $0x37
f0103f62:	e9 b6 08 00 00       	jmp    f010481d <_alltraps>
f0103f67:	90                   	nop

f0103f68 <handler56>:
TRAPHANDLER_NOEC(handler56, 56)
f0103f68:	6a 00                	push   $0x0
f0103f6a:	6a 38                	push   $0x38
f0103f6c:	e9 ac 08 00 00       	jmp    f010481d <_alltraps>
f0103f71:	90                   	nop

f0103f72 <handler57>:
TRAPHANDLER_NOEC(handler57, 57)
f0103f72:	6a 00                	push   $0x0
f0103f74:	6a 39                	push   $0x39
f0103f76:	e9 a2 08 00 00       	jmp    f010481d <_alltraps>
f0103f7b:	90                   	nop

f0103f7c <handler58>:
TRAPHANDLER_NOEC(handler58, 58)
f0103f7c:	6a 00                	push   $0x0
f0103f7e:	6a 3a                	push   $0x3a
f0103f80:	e9 98 08 00 00       	jmp    f010481d <_alltraps>
f0103f85:	90                   	nop

f0103f86 <handler59>:
TRAPHANDLER_NOEC(handler59, 59)
f0103f86:	6a 00                	push   $0x0
f0103f88:	6a 3b                	push   $0x3b
f0103f8a:	e9 8e 08 00 00       	jmp    f010481d <_alltraps>
f0103f8f:	90                   	nop

f0103f90 <handler60>:
TRAPHANDLER_NOEC(handler60, 60)
f0103f90:	6a 00                	push   $0x0
f0103f92:	6a 3c                	push   $0x3c
f0103f94:	e9 84 08 00 00       	jmp    f010481d <_alltraps>
f0103f99:	90                   	nop

f0103f9a <handler61>:
TRAPHANDLER_NOEC(handler61, 61)
f0103f9a:	6a 00                	push   $0x0
f0103f9c:	6a 3d                	push   $0x3d
f0103f9e:	e9 7a 08 00 00       	jmp    f010481d <_alltraps>
f0103fa3:	90                   	nop

f0103fa4 <handler62>:
TRAPHANDLER_NOEC(handler62, 62)
f0103fa4:	6a 00                	push   $0x0
f0103fa6:	6a 3e                	push   $0x3e
f0103fa8:	e9 70 08 00 00       	jmp    f010481d <_alltraps>
f0103fad:	90                   	nop

f0103fae <handler63>:
TRAPHANDLER_NOEC(handler63, 63)
f0103fae:	6a 00                	push   $0x0
f0103fb0:	6a 3f                	push   $0x3f
f0103fb2:	e9 66 08 00 00       	jmp    f010481d <_alltraps>
f0103fb7:	90                   	nop

f0103fb8 <handler64>:
TRAPHANDLER_NOEC(handler64, 64)
f0103fb8:	6a 00                	push   $0x0
f0103fba:	6a 40                	push   $0x40
f0103fbc:	e9 5c 08 00 00       	jmp    f010481d <_alltraps>
f0103fc1:	90                   	nop

f0103fc2 <handler65>:
TRAPHANDLER_NOEC(handler65, 65)
f0103fc2:	6a 00                	push   $0x0
f0103fc4:	6a 41                	push   $0x41
f0103fc6:	e9 52 08 00 00       	jmp    f010481d <_alltraps>
f0103fcb:	90                   	nop

f0103fcc <handler66>:
TRAPHANDLER_NOEC(handler66, 66)
f0103fcc:	6a 00                	push   $0x0
f0103fce:	6a 42                	push   $0x42
f0103fd0:	e9 48 08 00 00       	jmp    f010481d <_alltraps>
f0103fd5:	90                   	nop

f0103fd6 <handler67>:
TRAPHANDLER_NOEC(handler67, 67)
f0103fd6:	6a 00                	push   $0x0
f0103fd8:	6a 43                	push   $0x43
f0103fda:	e9 3e 08 00 00       	jmp    f010481d <_alltraps>
f0103fdf:	90                   	nop

f0103fe0 <handler68>:
TRAPHANDLER_NOEC(handler68, 68)
f0103fe0:	6a 00                	push   $0x0
f0103fe2:	6a 44                	push   $0x44
f0103fe4:	e9 34 08 00 00       	jmp    f010481d <_alltraps>
f0103fe9:	90                   	nop

f0103fea <handler69>:
TRAPHANDLER_NOEC(handler69, 69)
f0103fea:	6a 00                	push   $0x0
f0103fec:	6a 45                	push   $0x45
f0103fee:	e9 2a 08 00 00       	jmp    f010481d <_alltraps>
f0103ff3:	90                   	nop

f0103ff4 <handler70>:
TRAPHANDLER_NOEC(handler70, 70)
f0103ff4:	6a 00                	push   $0x0
f0103ff6:	6a 46                	push   $0x46
f0103ff8:	e9 20 08 00 00       	jmp    f010481d <_alltraps>
f0103ffd:	90                   	nop

f0103ffe <handler71>:
TRAPHANDLER_NOEC(handler71, 71)
f0103ffe:	6a 00                	push   $0x0
f0104000:	6a 47                	push   $0x47
f0104002:	e9 16 08 00 00       	jmp    f010481d <_alltraps>
f0104007:	90                   	nop

f0104008 <handler72>:
TRAPHANDLER_NOEC(handler72, 72)
f0104008:	6a 00                	push   $0x0
f010400a:	6a 48                	push   $0x48
f010400c:	e9 0c 08 00 00       	jmp    f010481d <_alltraps>
f0104011:	90                   	nop

f0104012 <handler73>:
TRAPHANDLER_NOEC(handler73, 73)
f0104012:	6a 00                	push   $0x0
f0104014:	6a 49                	push   $0x49
f0104016:	e9 02 08 00 00       	jmp    f010481d <_alltraps>
f010401b:	90                   	nop

f010401c <handler74>:
TRAPHANDLER_NOEC(handler74, 74)
f010401c:	6a 00                	push   $0x0
f010401e:	6a 4a                	push   $0x4a
f0104020:	e9 f8 07 00 00       	jmp    f010481d <_alltraps>
f0104025:	90                   	nop

f0104026 <handler75>:
TRAPHANDLER_NOEC(handler75, 75)
f0104026:	6a 00                	push   $0x0
f0104028:	6a 4b                	push   $0x4b
f010402a:	e9 ee 07 00 00       	jmp    f010481d <_alltraps>
f010402f:	90                   	nop

f0104030 <handler76>:
TRAPHANDLER_NOEC(handler76, 76)
f0104030:	6a 00                	push   $0x0
f0104032:	6a 4c                	push   $0x4c
f0104034:	e9 e4 07 00 00       	jmp    f010481d <_alltraps>
f0104039:	90                   	nop

f010403a <handler77>:
TRAPHANDLER_NOEC(handler77, 77)
f010403a:	6a 00                	push   $0x0
f010403c:	6a 4d                	push   $0x4d
f010403e:	e9 da 07 00 00       	jmp    f010481d <_alltraps>
f0104043:	90                   	nop

f0104044 <handler78>:
TRAPHANDLER_NOEC(handler78, 78)
f0104044:	6a 00                	push   $0x0
f0104046:	6a 4e                	push   $0x4e
f0104048:	e9 d0 07 00 00       	jmp    f010481d <_alltraps>
f010404d:	90                   	nop

f010404e <handler79>:
TRAPHANDLER_NOEC(handler79, 79)
f010404e:	6a 00                	push   $0x0
f0104050:	6a 4f                	push   $0x4f
f0104052:	e9 c6 07 00 00       	jmp    f010481d <_alltraps>
f0104057:	90                   	nop

f0104058 <handler80>:
TRAPHANDLER_NOEC(handler80, 80)
f0104058:	6a 00                	push   $0x0
f010405a:	6a 50                	push   $0x50
f010405c:	e9 bc 07 00 00       	jmp    f010481d <_alltraps>
f0104061:	90                   	nop

f0104062 <handler81>:
TRAPHANDLER_NOEC(handler81, 81)
f0104062:	6a 00                	push   $0x0
f0104064:	6a 51                	push   $0x51
f0104066:	e9 b2 07 00 00       	jmp    f010481d <_alltraps>
f010406b:	90                   	nop

f010406c <handler82>:
TRAPHANDLER_NOEC(handler82, 82)
f010406c:	6a 00                	push   $0x0
f010406e:	6a 52                	push   $0x52
f0104070:	e9 a8 07 00 00       	jmp    f010481d <_alltraps>
f0104075:	90                   	nop

f0104076 <handler83>:
TRAPHANDLER_NOEC(handler83, 83)
f0104076:	6a 00                	push   $0x0
f0104078:	6a 53                	push   $0x53
f010407a:	e9 9e 07 00 00       	jmp    f010481d <_alltraps>
f010407f:	90                   	nop

f0104080 <handler84>:
TRAPHANDLER_NOEC(handler84, 84)
f0104080:	6a 00                	push   $0x0
f0104082:	6a 54                	push   $0x54
f0104084:	e9 94 07 00 00       	jmp    f010481d <_alltraps>
f0104089:	90                   	nop

f010408a <handler85>:
TRAPHANDLER_NOEC(handler85, 85)
f010408a:	6a 00                	push   $0x0
f010408c:	6a 55                	push   $0x55
f010408e:	e9 8a 07 00 00       	jmp    f010481d <_alltraps>
f0104093:	90                   	nop

f0104094 <handler86>:
TRAPHANDLER_NOEC(handler86, 86)
f0104094:	6a 00                	push   $0x0
f0104096:	6a 56                	push   $0x56
f0104098:	e9 80 07 00 00       	jmp    f010481d <_alltraps>
f010409d:	90                   	nop

f010409e <handler87>:
TRAPHANDLER_NOEC(handler87, 87)
f010409e:	6a 00                	push   $0x0
f01040a0:	6a 57                	push   $0x57
f01040a2:	e9 76 07 00 00       	jmp    f010481d <_alltraps>
f01040a7:	90                   	nop

f01040a8 <handler88>:
TRAPHANDLER_NOEC(handler88, 88)
f01040a8:	6a 00                	push   $0x0
f01040aa:	6a 58                	push   $0x58
f01040ac:	e9 6c 07 00 00       	jmp    f010481d <_alltraps>
f01040b1:	90                   	nop

f01040b2 <handler89>:
TRAPHANDLER_NOEC(handler89, 89)
f01040b2:	6a 00                	push   $0x0
f01040b4:	6a 59                	push   $0x59
f01040b6:	e9 62 07 00 00       	jmp    f010481d <_alltraps>
f01040bb:	90                   	nop

f01040bc <handler90>:
TRAPHANDLER_NOEC(handler90, 90)
f01040bc:	6a 00                	push   $0x0
f01040be:	6a 5a                	push   $0x5a
f01040c0:	e9 58 07 00 00       	jmp    f010481d <_alltraps>
f01040c5:	90                   	nop

f01040c6 <handler91>:
TRAPHANDLER_NOEC(handler91, 91)
f01040c6:	6a 00                	push   $0x0
f01040c8:	6a 5b                	push   $0x5b
f01040ca:	e9 4e 07 00 00       	jmp    f010481d <_alltraps>
f01040cf:	90                   	nop

f01040d0 <handler92>:
TRAPHANDLER_NOEC(handler92, 92)
f01040d0:	6a 00                	push   $0x0
f01040d2:	6a 5c                	push   $0x5c
f01040d4:	e9 44 07 00 00       	jmp    f010481d <_alltraps>
f01040d9:	90                   	nop

f01040da <handler93>:
TRAPHANDLER_NOEC(handler93, 93)
f01040da:	6a 00                	push   $0x0
f01040dc:	6a 5d                	push   $0x5d
f01040de:	e9 3a 07 00 00       	jmp    f010481d <_alltraps>
f01040e3:	90                   	nop

f01040e4 <handler94>:
TRAPHANDLER_NOEC(handler94, 94)
f01040e4:	6a 00                	push   $0x0
f01040e6:	6a 5e                	push   $0x5e
f01040e8:	e9 30 07 00 00       	jmp    f010481d <_alltraps>
f01040ed:	90                   	nop

f01040ee <handler95>:
TRAPHANDLER_NOEC(handler95, 95)
f01040ee:	6a 00                	push   $0x0
f01040f0:	6a 5f                	push   $0x5f
f01040f2:	e9 26 07 00 00       	jmp    f010481d <_alltraps>
f01040f7:	90                   	nop

f01040f8 <handler96>:
TRAPHANDLER_NOEC(handler96, 96)
f01040f8:	6a 00                	push   $0x0
f01040fa:	6a 60                	push   $0x60
f01040fc:	e9 1c 07 00 00       	jmp    f010481d <_alltraps>
f0104101:	90                   	nop

f0104102 <handler97>:
TRAPHANDLER_NOEC(handler97, 97)
f0104102:	6a 00                	push   $0x0
f0104104:	6a 61                	push   $0x61
f0104106:	e9 12 07 00 00       	jmp    f010481d <_alltraps>
f010410b:	90                   	nop

f010410c <handler98>:
TRAPHANDLER_NOEC(handler98, 98)
f010410c:	6a 00                	push   $0x0
f010410e:	6a 62                	push   $0x62
f0104110:	e9 08 07 00 00       	jmp    f010481d <_alltraps>
f0104115:	90                   	nop

f0104116 <handler99>:
TRAPHANDLER_NOEC(handler99, 99)
f0104116:	6a 00                	push   $0x0
f0104118:	6a 63                	push   $0x63
f010411a:	e9 fe 06 00 00       	jmp    f010481d <_alltraps>
f010411f:	90                   	nop

f0104120 <handler100>:
TRAPHANDLER_NOEC(handler100, 100)
f0104120:	6a 00                	push   $0x0
f0104122:	6a 64                	push   $0x64
f0104124:	e9 f4 06 00 00       	jmp    f010481d <_alltraps>
f0104129:	90                   	nop

f010412a <handler101>:
TRAPHANDLER_NOEC(handler101, 101)
f010412a:	6a 00                	push   $0x0
f010412c:	6a 65                	push   $0x65
f010412e:	e9 ea 06 00 00       	jmp    f010481d <_alltraps>
f0104133:	90                   	nop

f0104134 <handler102>:
TRAPHANDLER_NOEC(handler102, 102)
f0104134:	6a 00                	push   $0x0
f0104136:	6a 66                	push   $0x66
f0104138:	e9 e0 06 00 00       	jmp    f010481d <_alltraps>
f010413d:	90                   	nop

f010413e <handler103>:
TRAPHANDLER_NOEC(handler103, 103)
f010413e:	6a 00                	push   $0x0
f0104140:	6a 67                	push   $0x67
f0104142:	e9 d6 06 00 00       	jmp    f010481d <_alltraps>
f0104147:	90                   	nop

f0104148 <handler104>:
TRAPHANDLER_NOEC(handler104, 104)
f0104148:	6a 00                	push   $0x0
f010414a:	6a 68                	push   $0x68
f010414c:	e9 cc 06 00 00       	jmp    f010481d <_alltraps>
f0104151:	90                   	nop

f0104152 <handler105>:
TRAPHANDLER_NOEC(handler105, 105)
f0104152:	6a 00                	push   $0x0
f0104154:	6a 69                	push   $0x69
f0104156:	e9 c2 06 00 00       	jmp    f010481d <_alltraps>
f010415b:	90                   	nop

f010415c <handler106>:
TRAPHANDLER_NOEC(handler106, 106)
f010415c:	6a 00                	push   $0x0
f010415e:	6a 6a                	push   $0x6a
f0104160:	e9 b8 06 00 00       	jmp    f010481d <_alltraps>
f0104165:	90                   	nop

f0104166 <handler107>:
TRAPHANDLER_NOEC(handler107, 107)
f0104166:	6a 00                	push   $0x0
f0104168:	6a 6b                	push   $0x6b
f010416a:	e9 ae 06 00 00       	jmp    f010481d <_alltraps>
f010416f:	90                   	nop

f0104170 <handler108>:
TRAPHANDLER_NOEC(handler108, 108)
f0104170:	6a 00                	push   $0x0
f0104172:	6a 6c                	push   $0x6c
f0104174:	e9 a4 06 00 00       	jmp    f010481d <_alltraps>
f0104179:	90                   	nop

f010417a <handler109>:
TRAPHANDLER_NOEC(handler109, 109)
f010417a:	6a 00                	push   $0x0
f010417c:	6a 6d                	push   $0x6d
f010417e:	e9 9a 06 00 00       	jmp    f010481d <_alltraps>
f0104183:	90                   	nop

f0104184 <handler110>:
TRAPHANDLER_NOEC(handler110, 110)
f0104184:	6a 00                	push   $0x0
f0104186:	6a 6e                	push   $0x6e
f0104188:	e9 90 06 00 00       	jmp    f010481d <_alltraps>
f010418d:	90                   	nop

f010418e <handler111>:
TRAPHANDLER_NOEC(handler111, 111)
f010418e:	6a 00                	push   $0x0
f0104190:	6a 6f                	push   $0x6f
f0104192:	e9 86 06 00 00       	jmp    f010481d <_alltraps>
f0104197:	90                   	nop

f0104198 <handler112>:
TRAPHANDLER_NOEC(handler112, 112)
f0104198:	6a 00                	push   $0x0
f010419a:	6a 70                	push   $0x70
f010419c:	e9 7c 06 00 00       	jmp    f010481d <_alltraps>
f01041a1:	90                   	nop

f01041a2 <handler113>:
TRAPHANDLER_NOEC(handler113, 113)
f01041a2:	6a 00                	push   $0x0
f01041a4:	6a 71                	push   $0x71
f01041a6:	e9 72 06 00 00       	jmp    f010481d <_alltraps>
f01041ab:	90                   	nop

f01041ac <handler114>:
TRAPHANDLER_NOEC(handler114, 114)
f01041ac:	6a 00                	push   $0x0
f01041ae:	6a 72                	push   $0x72
f01041b0:	e9 68 06 00 00       	jmp    f010481d <_alltraps>
f01041b5:	90                   	nop

f01041b6 <handler115>:
TRAPHANDLER_NOEC(handler115, 115)
f01041b6:	6a 00                	push   $0x0
f01041b8:	6a 73                	push   $0x73
f01041ba:	e9 5e 06 00 00       	jmp    f010481d <_alltraps>
f01041bf:	90                   	nop

f01041c0 <handler116>:
TRAPHANDLER_NOEC(handler116, 116)
f01041c0:	6a 00                	push   $0x0
f01041c2:	6a 74                	push   $0x74
f01041c4:	e9 54 06 00 00       	jmp    f010481d <_alltraps>
f01041c9:	90                   	nop

f01041ca <handler117>:
TRAPHANDLER_NOEC(handler117, 117)
f01041ca:	6a 00                	push   $0x0
f01041cc:	6a 75                	push   $0x75
f01041ce:	e9 4a 06 00 00       	jmp    f010481d <_alltraps>
f01041d3:	90                   	nop

f01041d4 <handler118>:
TRAPHANDLER_NOEC(handler118, 118)
f01041d4:	6a 00                	push   $0x0
f01041d6:	6a 76                	push   $0x76
f01041d8:	e9 40 06 00 00       	jmp    f010481d <_alltraps>
f01041dd:	90                   	nop

f01041de <handler119>:
TRAPHANDLER_NOEC(handler119, 119)
f01041de:	6a 00                	push   $0x0
f01041e0:	6a 77                	push   $0x77
f01041e2:	e9 36 06 00 00       	jmp    f010481d <_alltraps>
f01041e7:	90                   	nop

f01041e8 <handler120>:
TRAPHANDLER_NOEC(handler120, 120)
f01041e8:	6a 00                	push   $0x0
f01041ea:	6a 78                	push   $0x78
f01041ec:	e9 2c 06 00 00       	jmp    f010481d <_alltraps>
f01041f1:	90                   	nop

f01041f2 <handler121>:
TRAPHANDLER_NOEC(handler121, 121)
f01041f2:	6a 00                	push   $0x0
f01041f4:	6a 79                	push   $0x79
f01041f6:	e9 22 06 00 00       	jmp    f010481d <_alltraps>
f01041fb:	90                   	nop

f01041fc <handler122>:
TRAPHANDLER_NOEC(handler122, 122)
f01041fc:	6a 00                	push   $0x0
f01041fe:	6a 7a                	push   $0x7a
f0104200:	e9 18 06 00 00       	jmp    f010481d <_alltraps>
f0104205:	90                   	nop

f0104206 <handler123>:
TRAPHANDLER_NOEC(handler123, 123)
f0104206:	6a 00                	push   $0x0
f0104208:	6a 7b                	push   $0x7b
f010420a:	e9 0e 06 00 00       	jmp    f010481d <_alltraps>
f010420f:	90                   	nop

f0104210 <handler124>:
TRAPHANDLER_NOEC(handler124, 124)
f0104210:	6a 00                	push   $0x0
f0104212:	6a 7c                	push   $0x7c
f0104214:	e9 04 06 00 00       	jmp    f010481d <_alltraps>
f0104219:	90                   	nop

f010421a <handler125>:
TRAPHANDLER_NOEC(handler125, 125)
f010421a:	6a 00                	push   $0x0
f010421c:	6a 7d                	push   $0x7d
f010421e:	e9 fa 05 00 00       	jmp    f010481d <_alltraps>
f0104223:	90                   	nop

f0104224 <handler126>:
TRAPHANDLER_NOEC(handler126, 126)
f0104224:	6a 00                	push   $0x0
f0104226:	6a 7e                	push   $0x7e
f0104228:	e9 f0 05 00 00       	jmp    f010481d <_alltraps>
f010422d:	90                   	nop

f010422e <handler127>:
TRAPHANDLER_NOEC(handler127, 127)
f010422e:	6a 00                	push   $0x0
f0104230:	6a 7f                	push   $0x7f
f0104232:	e9 e6 05 00 00       	jmp    f010481d <_alltraps>
f0104237:	90                   	nop

f0104238 <handler128>:
TRAPHANDLER_NOEC(handler128, 128)
f0104238:	6a 00                	push   $0x0
f010423a:	68 80 00 00 00       	push   $0x80
f010423f:	e9 d9 05 00 00       	jmp    f010481d <_alltraps>

f0104244 <handler129>:
TRAPHANDLER_NOEC(handler129, 129)
f0104244:	6a 00                	push   $0x0
f0104246:	68 81 00 00 00       	push   $0x81
f010424b:	e9 cd 05 00 00       	jmp    f010481d <_alltraps>

f0104250 <handler130>:
TRAPHANDLER_NOEC(handler130, 130)
f0104250:	6a 00                	push   $0x0
f0104252:	68 82 00 00 00       	push   $0x82
f0104257:	e9 c1 05 00 00       	jmp    f010481d <_alltraps>

f010425c <handler131>:
TRAPHANDLER_NOEC(handler131, 131)
f010425c:	6a 00                	push   $0x0
f010425e:	68 83 00 00 00       	push   $0x83
f0104263:	e9 b5 05 00 00       	jmp    f010481d <_alltraps>

f0104268 <handler132>:
TRAPHANDLER_NOEC(handler132, 132)
f0104268:	6a 00                	push   $0x0
f010426a:	68 84 00 00 00       	push   $0x84
f010426f:	e9 a9 05 00 00       	jmp    f010481d <_alltraps>

f0104274 <handler133>:
TRAPHANDLER_NOEC(handler133, 133)
f0104274:	6a 00                	push   $0x0
f0104276:	68 85 00 00 00       	push   $0x85
f010427b:	e9 9d 05 00 00       	jmp    f010481d <_alltraps>

f0104280 <handler134>:
TRAPHANDLER_NOEC(handler134, 134)
f0104280:	6a 00                	push   $0x0
f0104282:	68 86 00 00 00       	push   $0x86
f0104287:	e9 91 05 00 00       	jmp    f010481d <_alltraps>

f010428c <handler135>:
TRAPHANDLER_NOEC(handler135, 135)
f010428c:	6a 00                	push   $0x0
f010428e:	68 87 00 00 00       	push   $0x87
f0104293:	e9 85 05 00 00       	jmp    f010481d <_alltraps>

f0104298 <handler136>:
TRAPHANDLER_NOEC(handler136, 136)
f0104298:	6a 00                	push   $0x0
f010429a:	68 88 00 00 00       	push   $0x88
f010429f:	e9 79 05 00 00       	jmp    f010481d <_alltraps>

f01042a4 <handler137>:
TRAPHANDLER_NOEC(handler137, 137)
f01042a4:	6a 00                	push   $0x0
f01042a6:	68 89 00 00 00       	push   $0x89
f01042ab:	e9 6d 05 00 00       	jmp    f010481d <_alltraps>

f01042b0 <handler138>:
TRAPHANDLER_NOEC(handler138, 138)
f01042b0:	6a 00                	push   $0x0
f01042b2:	68 8a 00 00 00       	push   $0x8a
f01042b7:	e9 61 05 00 00       	jmp    f010481d <_alltraps>

f01042bc <handler139>:
TRAPHANDLER_NOEC(handler139, 139)
f01042bc:	6a 00                	push   $0x0
f01042be:	68 8b 00 00 00       	push   $0x8b
f01042c3:	e9 55 05 00 00       	jmp    f010481d <_alltraps>

f01042c8 <handler140>:
TRAPHANDLER_NOEC(handler140, 140)
f01042c8:	6a 00                	push   $0x0
f01042ca:	68 8c 00 00 00       	push   $0x8c
f01042cf:	e9 49 05 00 00       	jmp    f010481d <_alltraps>

f01042d4 <handler141>:
TRAPHANDLER_NOEC(handler141, 141)
f01042d4:	6a 00                	push   $0x0
f01042d6:	68 8d 00 00 00       	push   $0x8d
f01042db:	e9 3d 05 00 00       	jmp    f010481d <_alltraps>

f01042e0 <handler142>:
TRAPHANDLER_NOEC(handler142, 142)
f01042e0:	6a 00                	push   $0x0
f01042e2:	68 8e 00 00 00       	push   $0x8e
f01042e7:	e9 31 05 00 00       	jmp    f010481d <_alltraps>

f01042ec <handler143>:
TRAPHANDLER_NOEC(handler143, 143)
f01042ec:	6a 00                	push   $0x0
f01042ee:	68 8f 00 00 00       	push   $0x8f
f01042f3:	e9 25 05 00 00       	jmp    f010481d <_alltraps>

f01042f8 <handler144>:
TRAPHANDLER_NOEC(handler144, 144)
f01042f8:	6a 00                	push   $0x0
f01042fa:	68 90 00 00 00       	push   $0x90
f01042ff:	e9 19 05 00 00       	jmp    f010481d <_alltraps>

f0104304 <handler145>:
TRAPHANDLER_NOEC(handler145, 145)
f0104304:	6a 00                	push   $0x0
f0104306:	68 91 00 00 00       	push   $0x91
f010430b:	e9 0d 05 00 00       	jmp    f010481d <_alltraps>

f0104310 <handler146>:
TRAPHANDLER_NOEC(handler146, 146)
f0104310:	6a 00                	push   $0x0
f0104312:	68 92 00 00 00       	push   $0x92
f0104317:	e9 01 05 00 00       	jmp    f010481d <_alltraps>

f010431c <handler147>:
TRAPHANDLER_NOEC(handler147, 147)
f010431c:	6a 00                	push   $0x0
f010431e:	68 93 00 00 00       	push   $0x93
f0104323:	e9 f5 04 00 00       	jmp    f010481d <_alltraps>

f0104328 <handler148>:
TRAPHANDLER_NOEC(handler148, 148)
f0104328:	6a 00                	push   $0x0
f010432a:	68 94 00 00 00       	push   $0x94
f010432f:	e9 e9 04 00 00       	jmp    f010481d <_alltraps>

f0104334 <handler149>:
TRAPHANDLER_NOEC(handler149, 149)
f0104334:	6a 00                	push   $0x0
f0104336:	68 95 00 00 00       	push   $0x95
f010433b:	e9 dd 04 00 00       	jmp    f010481d <_alltraps>

f0104340 <handler150>:
TRAPHANDLER_NOEC(handler150, 150)
f0104340:	6a 00                	push   $0x0
f0104342:	68 96 00 00 00       	push   $0x96
f0104347:	e9 d1 04 00 00       	jmp    f010481d <_alltraps>

f010434c <handler151>:
TRAPHANDLER_NOEC(handler151, 151)
f010434c:	6a 00                	push   $0x0
f010434e:	68 97 00 00 00       	push   $0x97
f0104353:	e9 c5 04 00 00       	jmp    f010481d <_alltraps>

f0104358 <handler152>:
TRAPHANDLER_NOEC(handler152, 152)
f0104358:	6a 00                	push   $0x0
f010435a:	68 98 00 00 00       	push   $0x98
f010435f:	e9 b9 04 00 00       	jmp    f010481d <_alltraps>

f0104364 <handler153>:
TRAPHANDLER_NOEC(handler153, 153)
f0104364:	6a 00                	push   $0x0
f0104366:	68 99 00 00 00       	push   $0x99
f010436b:	e9 ad 04 00 00       	jmp    f010481d <_alltraps>

f0104370 <handler154>:
TRAPHANDLER_NOEC(handler154, 154)
f0104370:	6a 00                	push   $0x0
f0104372:	68 9a 00 00 00       	push   $0x9a
f0104377:	e9 a1 04 00 00       	jmp    f010481d <_alltraps>

f010437c <handler155>:
TRAPHANDLER_NOEC(handler155, 155)
f010437c:	6a 00                	push   $0x0
f010437e:	68 9b 00 00 00       	push   $0x9b
f0104383:	e9 95 04 00 00       	jmp    f010481d <_alltraps>

f0104388 <handler156>:
TRAPHANDLER_NOEC(handler156, 156)
f0104388:	6a 00                	push   $0x0
f010438a:	68 9c 00 00 00       	push   $0x9c
f010438f:	e9 89 04 00 00       	jmp    f010481d <_alltraps>

f0104394 <handler157>:
TRAPHANDLER_NOEC(handler157, 157)
f0104394:	6a 00                	push   $0x0
f0104396:	68 9d 00 00 00       	push   $0x9d
f010439b:	e9 7d 04 00 00       	jmp    f010481d <_alltraps>

f01043a0 <handler158>:
TRAPHANDLER_NOEC(handler158, 158)
f01043a0:	6a 00                	push   $0x0
f01043a2:	68 9e 00 00 00       	push   $0x9e
f01043a7:	e9 71 04 00 00       	jmp    f010481d <_alltraps>

f01043ac <handler159>:
TRAPHANDLER_NOEC(handler159, 159)
f01043ac:	6a 00                	push   $0x0
f01043ae:	68 9f 00 00 00       	push   $0x9f
f01043b3:	e9 65 04 00 00       	jmp    f010481d <_alltraps>

f01043b8 <handler160>:
TRAPHANDLER_NOEC(handler160, 160)
f01043b8:	6a 00                	push   $0x0
f01043ba:	68 a0 00 00 00       	push   $0xa0
f01043bf:	e9 59 04 00 00       	jmp    f010481d <_alltraps>

f01043c4 <handler161>:
TRAPHANDLER_NOEC(handler161, 161)
f01043c4:	6a 00                	push   $0x0
f01043c6:	68 a1 00 00 00       	push   $0xa1
f01043cb:	e9 4d 04 00 00       	jmp    f010481d <_alltraps>

f01043d0 <handler162>:
TRAPHANDLER_NOEC(handler162, 162)
f01043d0:	6a 00                	push   $0x0
f01043d2:	68 a2 00 00 00       	push   $0xa2
f01043d7:	e9 41 04 00 00       	jmp    f010481d <_alltraps>

f01043dc <handler163>:
TRAPHANDLER_NOEC(handler163, 163)
f01043dc:	6a 00                	push   $0x0
f01043de:	68 a3 00 00 00       	push   $0xa3
f01043e3:	e9 35 04 00 00       	jmp    f010481d <_alltraps>

f01043e8 <handler164>:
TRAPHANDLER_NOEC(handler164, 164)
f01043e8:	6a 00                	push   $0x0
f01043ea:	68 a4 00 00 00       	push   $0xa4
f01043ef:	e9 29 04 00 00       	jmp    f010481d <_alltraps>

f01043f4 <handler165>:
TRAPHANDLER_NOEC(handler165, 165)
f01043f4:	6a 00                	push   $0x0
f01043f6:	68 a5 00 00 00       	push   $0xa5
f01043fb:	e9 1d 04 00 00       	jmp    f010481d <_alltraps>

f0104400 <handler166>:
TRAPHANDLER_NOEC(handler166, 166)
f0104400:	6a 00                	push   $0x0
f0104402:	68 a6 00 00 00       	push   $0xa6
f0104407:	e9 11 04 00 00       	jmp    f010481d <_alltraps>

f010440c <handler167>:
TRAPHANDLER_NOEC(handler167, 167)
f010440c:	6a 00                	push   $0x0
f010440e:	68 a7 00 00 00       	push   $0xa7
f0104413:	e9 05 04 00 00       	jmp    f010481d <_alltraps>

f0104418 <handler168>:
TRAPHANDLER_NOEC(handler168, 168)
f0104418:	6a 00                	push   $0x0
f010441a:	68 a8 00 00 00       	push   $0xa8
f010441f:	e9 f9 03 00 00       	jmp    f010481d <_alltraps>

f0104424 <handler169>:
TRAPHANDLER_NOEC(handler169, 169)
f0104424:	6a 00                	push   $0x0
f0104426:	68 a9 00 00 00       	push   $0xa9
f010442b:	e9 ed 03 00 00       	jmp    f010481d <_alltraps>

f0104430 <handler170>:
TRAPHANDLER_NOEC(handler170, 170)
f0104430:	6a 00                	push   $0x0
f0104432:	68 aa 00 00 00       	push   $0xaa
f0104437:	e9 e1 03 00 00       	jmp    f010481d <_alltraps>

f010443c <handler171>:
TRAPHANDLER_NOEC(handler171, 171)
f010443c:	6a 00                	push   $0x0
f010443e:	68 ab 00 00 00       	push   $0xab
f0104443:	e9 d5 03 00 00       	jmp    f010481d <_alltraps>

f0104448 <handler172>:
TRAPHANDLER_NOEC(handler172, 172)
f0104448:	6a 00                	push   $0x0
f010444a:	68 ac 00 00 00       	push   $0xac
f010444f:	e9 c9 03 00 00       	jmp    f010481d <_alltraps>

f0104454 <handler173>:
TRAPHANDLER_NOEC(handler173, 173)
f0104454:	6a 00                	push   $0x0
f0104456:	68 ad 00 00 00       	push   $0xad
f010445b:	e9 bd 03 00 00       	jmp    f010481d <_alltraps>

f0104460 <handler174>:
TRAPHANDLER_NOEC(handler174, 174)
f0104460:	6a 00                	push   $0x0
f0104462:	68 ae 00 00 00       	push   $0xae
f0104467:	e9 b1 03 00 00       	jmp    f010481d <_alltraps>

f010446c <handler175>:
TRAPHANDLER_NOEC(handler175, 175)
f010446c:	6a 00                	push   $0x0
f010446e:	68 af 00 00 00       	push   $0xaf
f0104473:	e9 a5 03 00 00       	jmp    f010481d <_alltraps>

f0104478 <handler176>:
TRAPHANDLER_NOEC(handler176, 176)
f0104478:	6a 00                	push   $0x0
f010447a:	68 b0 00 00 00       	push   $0xb0
f010447f:	e9 99 03 00 00       	jmp    f010481d <_alltraps>

f0104484 <handler177>:
TRAPHANDLER_NOEC(handler177, 177)
f0104484:	6a 00                	push   $0x0
f0104486:	68 b1 00 00 00       	push   $0xb1
f010448b:	e9 8d 03 00 00       	jmp    f010481d <_alltraps>

f0104490 <handler178>:
TRAPHANDLER_NOEC(handler178, 178)
f0104490:	6a 00                	push   $0x0
f0104492:	68 b2 00 00 00       	push   $0xb2
f0104497:	e9 81 03 00 00       	jmp    f010481d <_alltraps>

f010449c <handler179>:
TRAPHANDLER_NOEC(handler179, 179)
f010449c:	6a 00                	push   $0x0
f010449e:	68 b3 00 00 00       	push   $0xb3
f01044a3:	e9 75 03 00 00       	jmp    f010481d <_alltraps>

f01044a8 <handler180>:
TRAPHANDLER_NOEC(handler180, 180)
f01044a8:	6a 00                	push   $0x0
f01044aa:	68 b4 00 00 00       	push   $0xb4
f01044af:	e9 69 03 00 00       	jmp    f010481d <_alltraps>

f01044b4 <handler181>:
TRAPHANDLER_NOEC(handler181, 181)
f01044b4:	6a 00                	push   $0x0
f01044b6:	68 b5 00 00 00       	push   $0xb5
f01044bb:	e9 5d 03 00 00       	jmp    f010481d <_alltraps>

f01044c0 <handler182>:
TRAPHANDLER_NOEC(handler182, 182)
f01044c0:	6a 00                	push   $0x0
f01044c2:	68 b6 00 00 00       	push   $0xb6
f01044c7:	e9 51 03 00 00       	jmp    f010481d <_alltraps>

f01044cc <handler183>:
TRAPHANDLER_NOEC(handler183, 183)
f01044cc:	6a 00                	push   $0x0
f01044ce:	68 b7 00 00 00       	push   $0xb7
f01044d3:	e9 45 03 00 00       	jmp    f010481d <_alltraps>

f01044d8 <handler184>:
TRAPHANDLER_NOEC(handler184, 184)
f01044d8:	6a 00                	push   $0x0
f01044da:	68 b8 00 00 00       	push   $0xb8
f01044df:	e9 39 03 00 00       	jmp    f010481d <_alltraps>

f01044e4 <handler185>:
TRAPHANDLER_NOEC(handler185, 185)
f01044e4:	6a 00                	push   $0x0
f01044e6:	68 b9 00 00 00       	push   $0xb9
f01044eb:	e9 2d 03 00 00       	jmp    f010481d <_alltraps>

f01044f0 <handler186>:
TRAPHANDLER_NOEC(handler186, 186)
f01044f0:	6a 00                	push   $0x0
f01044f2:	68 ba 00 00 00       	push   $0xba
f01044f7:	e9 21 03 00 00       	jmp    f010481d <_alltraps>

f01044fc <handler187>:
TRAPHANDLER_NOEC(handler187, 187)
f01044fc:	6a 00                	push   $0x0
f01044fe:	68 bb 00 00 00       	push   $0xbb
f0104503:	e9 15 03 00 00       	jmp    f010481d <_alltraps>

f0104508 <handler188>:
TRAPHANDLER_NOEC(handler188, 188)
f0104508:	6a 00                	push   $0x0
f010450a:	68 bc 00 00 00       	push   $0xbc
f010450f:	e9 09 03 00 00       	jmp    f010481d <_alltraps>

f0104514 <handler189>:
TRAPHANDLER_NOEC(handler189, 189)
f0104514:	6a 00                	push   $0x0
f0104516:	68 bd 00 00 00       	push   $0xbd
f010451b:	e9 fd 02 00 00       	jmp    f010481d <_alltraps>

f0104520 <handler190>:
TRAPHANDLER_NOEC(handler190, 190)
f0104520:	6a 00                	push   $0x0
f0104522:	68 be 00 00 00       	push   $0xbe
f0104527:	e9 f1 02 00 00       	jmp    f010481d <_alltraps>

f010452c <handler191>:
TRAPHANDLER_NOEC(handler191, 191)
f010452c:	6a 00                	push   $0x0
f010452e:	68 bf 00 00 00       	push   $0xbf
f0104533:	e9 e5 02 00 00       	jmp    f010481d <_alltraps>

f0104538 <handler192>:
TRAPHANDLER_NOEC(handler192, 192)
f0104538:	6a 00                	push   $0x0
f010453a:	68 c0 00 00 00       	push   $0xc0
f010453f:	e9 d9 02 00 00       	jmp    f010481d <_alltraps>

f0104544 <handler193>:
TRAPHANDLER_NOEC(handler193, 193)
f0104544:	6a 00                	push   $0x0
f0104546:	68 c1 00 00 00       	push   $0xc1
f010454b:	e9 cd 02 00 00       	jmp    f010481d <_alltraps>

f0104550 <handler194>:
TRAPHANDLER_NOEC(handler194, 194)
f0104550:	6a 00                	push   $0x0
f0104552:	68 c2 00 00 00       	push   $0xc2
f0104557:	e9 c1 02 00 00       	jmp    f010481d <_alltraps>

f010455c <handler195>:
TRAPHANDLER_NOEC(handler195, 195)
f010455c:	6a 00                	push   $0x0
f010455e:	68 c3 00 00 00       	push   $0xc3
f0104563:	e9 b5 02 00 00       	jmp    f010481d <_alltraps>

f0104568 <handler196>:
TRAPHANDLER_NOEC(handler196, 196)
f0104568:	6a 00                	push   $0x0
f010456a:	68 c4 00 00 00       	push   $0xc4
f010456f:	e9 a9 02 00 00       	jmp    f010481d <_alltraps>

f0104574 <handler197>:
TRAPHANDLER_NOEC(handler197, 197)
f0104574:	6a 00                	push   $0x0
f0104576:	68 c5 00 00 00       	push   $0xc5
f010457b:	e9 9d 02 00 00       	jmp    f010481d <_alltraps>

f0104580 <handler198>:
TRAPHANDLER_NOEC(handler198, 198)
f0104580:	6a 00                	push   $0x0
f0104582:	68 c6 00 00 00       	push   $0xc6
f0104587:	e9 91 02 00 00       	jmp    f010481d <_alltraps>

f010458c <handler199>:
TRAPHANDLER_NOEC(handler199, 199)
f010458c:	6a 00                	push   $0x0
f010458e:	68 c7 00 00 00       	push   $0xc7
f0104593:	e9 85 02 00 00       	jmp    f010481d <_alltraps>

f0104598 <handler200>:
TRAPHANDLER_NOEC(handler200, 200)
f0104598:	6a 00                	push   $0x0
f010459a:	68 c8 00 00 00       	push   $0xc8
f010459f:	e9 79 02 00 00       	jmp    f010481d <_alltraps>

f01045a4 <handler201>:
TRAPHANDLER_NOEC(handler201, 201)
f01045a4:	6a 00                	push   $0x0
f01045a6:	68 c9 00 00 00       	push   $0xc9
f01045ab:	e9 6d 02 00 00       	jmp    f010481d <_alltraps>

f01045b0 <handler202>:
TRAPHANDLER_NOEC(handler202, 202)
f01045b0:	6a 00                	push   $0x0
f01045b2:	68 ca 00 00 00       	push   $0xca
f01045b7:	e9 61 02 00 00       	jmp    f010481d <_alltraps>

f01045bc <handler203>:
TRAPHANDLER_NOEC(handler203, 203)
f01045bc:	6a 00                	push   $0x0
f01045be:	68 cb 00 00 00       	push   $0xcb
f01045c3:	e9 55 02 00 00       	jmp    f010481d <_alltraps>

f01045c8 <handler204>:
TRAPHANDLER_NOEC(handler204, 204)
f01045c8:	6a 00                	push   $0x0
f01045ca:	68 cc 00 00 00       	push   $0xcc
f01045cf:	e9 49 02 00 00       	jmp    f010481d <_alltraps>

f01045d4 <handler205>:
TRAPHANDLER_NOEC(handler205, 205)
f01045d4:	6a 00                	push   $0x0
f01045d6:	68 cd 00 00 00       	push   $0xcd
f01045db:	e9 3d 02 00 00       	jmp    f010481d <_alltraps>

f01045e0 <handler206>:
TRAPHANDLER_NOEC(handler206, 206)
f01045e0:	6a 00                	push   $0x0
f01045e2:	68 ce 00 00 00       	push   $0xce
f01045e7:	e9 31 02 00 00       	jmp    f010481d <_alltraps>

f01045ec <handler207>:
TRAPHANDLER_NOEC(handler207, 207)
f01045ec:	6a 00                	push   $0x0
f01045ee:	68 cf 00 00 00       	push   $0xcf
f01045f3:	e9 25 02 00 00       	jmp    f010481d <_alltraps>

f01045f8 <handler208>:
TRAPHANDLER_NOEC(handler208, 208)
f01045f8:	6a 00                	push   $0x0
f01045fa:	68 d0 00 00 00       	push   $0xd0
f01045ff:	e9 19 02 00 00       	jmp    f010481d <_alltraps>

f0104604 <handler209>:
TRAPHANDLER_NOEC(handler209, 209)
f0104604:	6a 00                	push   $0x0
f0104606:	68 d1 00 00 00       	push   $0xd1
f010460b:	e9 0d 02 00 00       	jmp    f010481d <_alltraps>

f0104610 <handler210>:
TRAPHANDLER_NOEC(handler210, 210)
f0104610:	6a 00                	push   $0x0
f0104612:	68 d2 00 00 00       	push   $0xd2
f0104617:	e9 01 02 00 00       	jmp    f010481d <_alltraps>

f010461c <handler211>:
TRAPHANDLER_NOEC(handler211, 211)
f010461c:	6a 00                	push   $0x0
f010461e:	68 d3 00 00 00       	push   $0xd3
f0104623:	e9 f5 01 00 00       	jmp    f010481d <_alltraps>

f0104628 <handler212>:
TRAPHANDLER_NOEC(handler212, 212)
f0104628:	6a 00                	push   $0x0
f010462a:	68 d4 00 00 00       	push   $0xd4
f010462f:	e9 e9 01 00 00       	jmp    f010481d <_alltraps>

f0104634 <handler213>:
TRAPHANDLER_NOEC(handler213, 213)
f0104634:	6a 00                	push   $0x0
f0104636:	68 d5 00 00 00       	push   $0xd5
f010463b:	e9 dd 01 00 00       	jmp    f010481d <_alltraps>

f0104640 <handler214>:
TRAPHANDLER_NOEC(handler214, 214)
f0104640:	6a 00                	push   $0x0
f0104642:	68 d6 00 00 00       	push   $0xd6
f0104647:	e9 d1 01 00 00       	jmp    f010481d <_alltraps>

f010464c <handler215>:
TRAPHANDLER_NOEC(handler215, 215)
f010464c:	6a 00                	push   $0x0
f010464e:	68 d7 00 00 00       	push   $0xd7
f0104653:	e9 c5 01 00 00       	jmp    f010481d <_alltraps>

f0104658 <handler216>:
TRAPHANDLER_NOEC(handler216, 216)
f0104658:	6a 00                	push   $0x0
f010465a:	68 d8 00 00 00       	push   $0xd8
f010465f:	e9 b9 01 00 00       	jmp    f010481d <_alltraps>

f0104664 <handler217>:
TRAPHANDLER_NOEC(handler217, 217)
f0104664:	6a 00                	push   $0x0
f0104666:	68 d9 00 00 00       	push   $0xd9
f010466b:	e9 ad 01 00 00       	jmp    f010481d <_alltraps>

f0104670 <handler218>:
TRAPHANDLER_NOEC(handler218, 218)
f0104670:	6a 00                	push   $0x0
f0104672:	68 da 00 00 00       	push   $0xda
f0104677:	e9 a1 01 00 00       	jmp    f010481d <_alltraps>

f010467c <handler219>:
TRAPHANDLER_NOEC(handler219, 219)
f010467c:	6a 00                	push   $0x0
f010467e:	68 db 00 00 00       	push   $0xdb
f0104683:	e9 95 01 00 00       	jmp    f010481d <_alltraps>

f0104688 <handler220>:
TRAPHANDLER_NOEC(handler220, 220)
f0104688:	6a 00                	push   $0x0
f010468a:	68 dc 00 00 00       	push   $0xdc
f010468f:	e9 89 01 00 00       	jmp    f010481d <_alltraps>

f0104694 <handler221>:
TRAPHANDLER_NOEC(handler221, 221)
f0104694:	6a 00                	push   $0x0
f0104696:	68 dd 00 00 00       	push   $0xdd
f010469b:	e9 7d 01 00 00       	jmp    f010481d <_alltraps>

f01046a0 <handler222>:
TRAPHANDLER_NOEC(handler222, 222)
f01046a0:	6a 00                	push   $0x0
f01046a2:	68 de 00 00 00       	push   $0xde
f01046a7:	e9 71 01 00 00       	jmp    f010481d <_alltraps>

f01046ac <handler223>:
TRAPHANDLER_NOEC(handler223, 223)
f01046ac:	6a 00                	push   $0x0
f01046ae:	68 df 00 00 00       	push   $0xdf
f01046b3:	e9 65 01 00 00       	jmp    f010481d <_alltraps>

f01046b8 <handler224>:
TRAPHANDLER_NOEC(handler224, 224)
f01046b8:	6a 00                	push   $0x0
f01046ba:	68 e0 00 00 00       	push   $0xe0
f01046bf:	e9 59 01 00 00       	jmp    f010481d <_alltraps>

f01046c4 <handler225>:
TRAPHANDLER_NOEC(handler225, 225)
f01046c4:	6a 00                	push   $0x0
f01046c6:	68 e1 00 00 00       	push   $0xe1
f01046cb:	e9 4d 01 00 00       	jmp    f010481d <_alltraps>

f01046d0 <handler226>:
TRAPHANDLER_NOEC(handler226, 226)
f01046d0:	6a 00                	push   $0x0
f01046d2:	68 e2 00 00 00       	push   $0xe2
f01046d7:	e9 41 01 00 00       	jmp    f010481d <_alltraps>

f01046dc <handler227>:
TRAPHANDLER_NOEC(handler227, 227)
f01046dc:	6a 00                	push   $0x0
f01046de:	68 e3 00 00 00       	push   $0xe3
f01046e3:	e9 35 01 00 00       	jmp    f010481d <_alltraps>

f01046e8 <handler228>:
TRAPHANDLER_NOEC(handler228, 228)
f01046e8:	6a 00                	push   $0x0
f01046ea:	68 e4 00 00 00       	push   $0xe4
f01046ef:	e9 29 01 00 00       	jmp    f010481d <_alltraps>

f01046f4 <handler229>:
TRAPHANDLER_NOEC(handler229, 229)
f01046f4:	6a 00                	push   $0x0
f01046f6:	68 e5 00 00 00       	push   $0xe5
f01046fb:	e9 1d 01 00 00       	jmp    f010481d <_alltraps>

f0104700 <handler230>:
TRAPHANDLER_NOEC(handler230, 230)
f0104700:	6a 00                	push   $0x0
f0104702:	68 e6 00 00 00       	push   $0xe6
f0104707:	e9 11 01 00 00       	jmp    f010481d <_alltraps>

f010470c <handler231>:
TRAPHANDLER_NOEC(handler231, 231)
f010470c:	6a 00                	push   $0x0
f010470e:	68 e7 00 00 00       	push   $0xe7
f0104713:	e9 05 01 00 00       	jmp    f010481d <_alltraps>

f0104718 <handler232>:
TRAPHANDLER_NOEC(handler232, 232)
f0104718:	6a 00                	push   $0x0
f010471a:	68 e8 00 00 00       	push   $0xe8
f010471f:	e9 f9 00 00 00       	jmp    f010481d <_alltraps>

f0104724 <handler233>:
TRAPHANDLER_NOEC(handler233, 233)
f0104724:	6a 00                	push   $0x0
f0104726:	68 e9 00 00 00       	push   $0xe9
f010472b:	e9 ed 00 00 00       	jmp    f010481d <_alltraps>

f0104730 <handler234>:
TRAPHANDLER_NOEC(handler234, 234)
f0104730:	6a 00                	push   $0x0
f0104732:	68 ea 00 00 00       	push   $0xea
f0104737:	e9 e1 00 00 00       	jmp    f010481d <_alltraps>

f010473c <handler235>:
TRAPHANDLER_NOEC(handler235, 235)
f010473c:	6a 00                	push   $0x0
f010473e:	68 eb 00 00 00       	push   $0xeb
f0104743:	e9 d5 00 00 00       	jmp    f010481d <_alltraps>

f0104748 <handler236>:
TRAPHANDLER_NOEC(handler236, 236)
f0104748:	6a 00                	push   $0x0
f010474a:	68 ec 00 00 00       	push   $0xec
f010474f:	e9 c9 00 00 00       	jmp    f010481d <_alltraps>

f0104754 <handler237>:
TRAPHANDLER_NOEC(handler237, 237)
f0104754:	6a 00                	push   $0x0
f0104756:	68 ed 00 00 00       	push   $0xed
f010475b:	e9 bd 00 00 00       	jmp    f010481d <_alltraps>

f0104760 <handler238>:
TRAPHANDLER_NOEC(handler238, 238)
f0104760:	6a 00                	push   $0x0
f0104762:	68 ee 00 00 00       	push   $0xee
f0104767:	e9 b1 00 00 00       	jmp    f010481d <_alltraps>

f010476c <handler239>:
TRAPHANDLER_NOEC(handler239, 239)
f010476c:	6a 00                	push   $0x0
f010476e:	68 ef 00 00 00       	push   $0xef
f0104773:	e9 a5 00 00 00       	jmp    f010481d <_alltraps>

f0104778 <handler240>:
TRAPHANDLER_NOEC(handler240, 240)
f0104778:	6a 00                	push   $0x0
f010477a:	68 f0 00 00 00       	push   $0xf0
f010477f:	e9 99 00 00 00       	jmp    f010481d <_alltraps>

f0104784 <handler241>:
TRAPHANDLER_NOEC(handler241, 241)
f0104784:	6a 00                	push   $0x0
f0104786:	68 f1 00 00 00       	push   $0xf1
f010478b:	e9 8d 00 00 00       	jmp    f010481d <_alltraps>

f0104790 <handler242>:
TRAPHANDLER_NOEC(handler242, 242)
f0104790:	6a 00                	push   $0x0
f0104792:	68 f2 00 00 00       	push   $0xf2
f0104797:	e9 81 00 00 00       	jmp    f010481d <_alltraps>

f010479c <handler243>:
TRAPHANDLER_NOEC(handler243, 243)
f010479c:	6a 00                	push   $0x0
f010479e:	68 f3 00 00 00       	push   $0xf3
f01047a3:	eb 78                	jmp    f010481d <_alltraps>
f01047a5:	90                   	nop

f01047a6 <handler244>:
TRAPHANDLER_NOEC(handler244, 244)
f01047a6:	6a 00                	push   $0x0
f01047a8:	68 f4 00 00 00       	push   $0xf4
f01047ad:	eb 6e                	jmp    f010481d <_alltraps>
f01047af:	90                   	nop

f01047b0 <handler245>:
TRAPHANDLER_NOEC(handler245, 245)
f01047b0:	6a 00                	push   $0x0
f01047b2:	68 f5 00 00 00       	push   $0xf5
f01047b7:	eb 64                	jmp    f010481d <_alltraps>
f01047b9:	90                   	nop

f01047ba <handler246>:
TRAPHANDLER_NOEC(handler246, 246)
f01047ba:	6a 00                	push   $0x0
f01047bc:	68 f6 00 00 00       	push   $0xf6
f01047c1:	eb 5a                	jmp    f010481d <_alltraps>
f01047c3:	90                   	nop

f01047c4 <handler247>:
TRAPHANDLER_NOEC(handler247, 247)
f01047c4:	6a 00                	push   $0x0
f01047c6:	68 f7 00 00 00       	push   $0xf7
f01047cb:	eb 50                	jmp    f010481d <_alltraps>
f01047cd:	90                   	nop

f01047ce <handler248>:
TRAPHANDLER_NOEC(handler248, 248)
f01047ce:	6a 00                	push   $0x0
f01047d0:	68 f8 00 00 00       	push   $0xf8
f01047d5:	eb 46                	jmp    f010481d <_alltraps>
f01047d7:	90                   	nop

f01047d8 <handler249>:
TRAPHANDLER_NOEC(handler249, 249)
f01047d8:	6a 00                	push   $0x0
f01047da:	68 f9 00 00 00       	push   $0xf9
f01047df:	eb 3c                	jmp    f010481d <_alltraps>
f01047e1:	90                   	nop

f01047e2 <handler250>:
TRAPHANDLER_NOEC(handler250, 250)
f01047e2:	6a 00                	push   $0x0
f01047e4:	68 fa 00 00 00       	push   $0xfa
f01047e9:	eb 32                	jmp    f010481d <_alltraps>
f01047eb:	90                   	nop

f01047ec <handler251>:
TRAPHANDLER_NOEC(handler251, 251)
f01047ec:	6a 00                	push   $0x0
f01047ee:	68 fb 00 00 00       	push   $0xfb
f01047f3:	eb 28                	jmp    f010481d <_alltraps>
f01047f5:	90                   	nop

f01047f6 <handler252>:
TRAPHANDLER_NOEC(handler252, 252)
f01047f6:	6a 00                	push   $0x0
f01047f8:	68 fc 00 00 00       	push   $0xfc
f01047fd:	eb 1e                	jmp    f010481d <_alltraps>
f01047ff:	90                   	nop

f0104800 <handler253>:
TRAPHANDLER_NOEC(handler253, 253)
f0104800:	6a 00                	push   $0x0
f0104802:	68 fd 00 00 00       	push   $0xfd
f0104807:	eb 14                	jmp    f010481d <_alltraps>
f0104809:	90                   	nop

f010480a <handler254>:
TRAPHANDLER_NOEC(handler254, 254)
f010480a:	6a 00                	push   $0x0
f010480c:	68 fe 00 00 00       	push   $0xfe
f0104811:	eb 0a                	jmp    f010481d <_alltraps>
f0104813:	90                   	nop

f0104814 <handler255>:
TRAPHANDLER_NOEC(handler255, 255)
f0104814:	6a 00                	push   $0x0
f0104816:	68 ff 00 00 00       	push   $0xff
f010481b:	eb 00                	jmp    f010481d <_alltraps>

f010481d <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	push %ds
f010481d:	1e                   	push   %ds
	push %es
f010481e:	06                   	push   %es
	pushal
f010481f:	60                   	pusha  

	mov $GD_KD, %ax
f0104820:	66 b8 10 00          	mov    $0x10,%ax
	mov %ax, %ds
f0104824:	8e d8                	mov    %eax,%ds
	mov %ax, %es
f0104826:	8e c0                	mov    %eax,%es

	# trap(Trapframe *tf)
	pushl %esp
f0104828:	54                   	push   %esp
	call trap
f0104829:	e8 f7 f2 ff ff       	call   f0103b25 <trap>

f010482e <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010482e:	55                   	push   %ebp
f010482f:	89 e5                	mov    %esp,%ebp
f0104831:	83 ec 08             	sub    $0x8,%esp
f0104834:	a1 44 02 23 f0       	mov    0xf0230244,%eax
f0104839:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010483c:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104841:	8b 02                	mov    (%edx),%eax
f0104843:	83 e8 01             	sub    $0x1,%eax
f0104846:	83 f8 02             	cmp    $0x2,%eax
f0104849:	76 10                	jbe    f010485b <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010484b:	83 c1 01             	add    $0x1,%ecx
f010484e:	83 c2 7c             	add    $0x7c,%edx
f0104851:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104857:	75 e8                	jne    f0104841 <sched_halt+0x13>
f0104859:	eb 08                	jmp    f0104863 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f010485b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104861:	75 1f                	jne    f0104882 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0104863:	83 ec 0c             	sub    $0xc,%esp
f0104866:	68 50 7e 10 f0       	push   $0xf0107e50
f010486b:	e8 e5 ed ff ff       	call   f0103655 <cprintf>
f0104870:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104873:	83 ec 0c             	sub    $0xc,%esp
f0104876:	6a 00                	push   $0x0
f0104878:	e8 be c0 ff ff       	call   f010093b <monitor>
f010487d:	83 c4 10             	add    $0x10,%esp
f0104880:	eb f1                	jmp    f0104873 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104882:	e8 7b 18 00 00       	call   f0106102 <cpunum>
f0104887:	6b c0 74             	imul   $0x74,%eax,%eax
f010488a:	c7 80 28 10 23 f0 00 	movl   $0x0,-0xfdcefd8(%eax)
f0104891:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104894:	a1 8c 0e 23 f0       	mov    0xf0230e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104899:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010489e:	77 12                	ja     f01048b2 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01048a0:	50                   	push   %eax
f01048a1:	68 e8 67 10 f0       	push   $0xf01067e8
f01048a6:	6a 4a                	push   $0x4a
f01048a8:	68 79 7e 10 f0       	push   $0xf0107e79
f01048ad:	e8 8e b7 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01048b2:	05 00 00 00 10       	add    $0x10000000,%eax
f01048b7:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01048ba:	e8 43 18 00 00       	call   f0106102 <cpunum>
f01048bf:	6b d0 74             	imul   $0x74,%eax,%edx
f01048c2:	81 c2 20 10 23 f0    	add    $0xf0231020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01048c8:	b8 02 00 00 00       	mov    $0x2,%eax
f01048cd:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01048d1:	83 ec 0c             	sub    $0xc,%esp
f01048d4:	68 c0 17 12 f0       	push   $0xf01217c0
f01048d9:	e8 2f 1b 00 00       	call   f010640d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01048de:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f01048e0:	e8 1d 18 00 00       	call   f0106102 <cpunum>
f01048e5:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f01048e8:	8b 80 30 10 23 f0    	mov    -0xfdcefd0(%eax),%eax
f01048ee:	bd 00 00 00 00       	mov    $0x0,%ebp
f01048f3:	89 c4                	mov    %eax,%esp
f01048f5:	6a 00                	push   $0x0
f01048f7:	6a 00                	push   $0x0
f01048f9:	fb                   	sti    
f01048fa:	f4                   	hlt    
f01048fb:	eb fd                	jmp    f01048fa <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f01048fd:	83 c4 10             	add    $0x10,%esp
f0104900:	c9                   	leave  
f0104901:	c3                   	ret    

f0104902 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104902:	55                   	push   %ebp
f0104903:	89 e5                	mov    %esp,%ebp
f0104905:	56                   	push   %esi
f0104906:	53                   	push   %ebx
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int start = 0, i, j;
	if (curenv)
f0104907:	e8 f6 17 00 00       	call   f0106102 <cpunum>
f010490c:	6b c0 74             	imul   $0x74,%eax,%eax
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int start = 0, i, j;
f010490f:	b9 00 00 00 00       	mov    $0x0,%ecx
	if (curenv)
f0104914:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f010491b:	74 1a                	je     f0104937 <sched_yield+0x35>
		start = ENVX(curenv->env_id) + 1;
f010491d:	e8 e0 17 00 00       	call   f0106102 <cpunum>
f0104922:	6b c0 74             	imul   $0x74,%eax,%eax
f0104925:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f010492b:	8b 48 48             	mov    0x48(%eax),%ecx
f010492e:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f0104934:	83 c1 01             	add    $0x1,%ecx

	for (i = 0; i < NENV; i++) {
		j = (start + i) % NENV;
		if (envs[j].env_status == ENV_RUNNABLE) {
f0104937:	8b 1d 44 02 23 f0    	mov    0xf0230244,%ebx
f010493d:	89 ca                	mov    %ecx,%edx
f010493f:	81 c1 00 04 00 00    	add    $0x400,%ecx
f0104945:	89 d6                	mov    %edx,%esi
f0104947:	c1 fe 1f             	sar    $0x1f,%esi
f010494a:	c1 ee 16             	shr    $0x16,%esi
f010494d:	8d 04 32             	lea    (%edx,%esi,1),%eax
f0104950:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104955:	29 f0                	sub    %esi,%eax
f0104957:	6b c0 7c             	imul   $0x7c,%eax,%eax
f010495a:	01 d8                	add    %ebx,%eax
f010495c:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104960:	75 09                	jne    f010496b <sched_yield+0x69>
			env_run(&envs[j]);
f0104962:	83 ec 0c             	sub    $0xc,%esp
f0104965:	50                   	push   %eax
f0104966:	e8 d0 ea ff ff       	call   f010343b <env_run>
f010496b:	83 c2 01             	add    $0x1,%edx
	// LAB 4: Your code here.
	int start = 0, i, j;
	if (curenv)
		start = ENVX(curenv->env_id) + 1;

	for (i = 0; i < NENV; i++) {
f010496e:	39 ca                	cmp    %ecx,%edx
f0104970:	75 d3                	jne    f0104945 <sched_yield+0x43>
		j = (start + i) % NENV;
		if (envs[j].env_status == ENV_RUNNABLE) {
			env_run(&envs[j]);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING) {
f0104972:	e8 8b 17 00 00       	call   f0106102 <cpunum>
f0104977:	6b c0 74             	imul   $0x74,%eax,%eax
f010497a:	83 b8 28 10 23 f0 00 	cmpl   $0x0,-0xfdcefd8(%eax)
f0104981:	74 2a                	je     f01049ad <sched_yield+0xab>
f0104983:	e8 7a 17 00 00       	call   f0106102 <cpunum>
f0104988:	6b c0 74             	imul   $0x74,%eax,%eax
f010498b:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104991:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104995:	75 16                	jne    f01049ad <sched_yield+0xab>
		env_run(curenv);
f0104997:	e8 66 17 00 00       	call   f0106102 <cpunum>
f010499c:	83 ec 0c             	sub    $0xc,%esp
f010499f:	6b c0 74             	imul   $0x74,%eax,%eax
f01049a2:	ff b0 28 10 23 f0    	pushl  -0xfdcefd8(%eax)
f01049a8:	e8 8e ea ff ff       	call   f010343b <env_run>
	}

	// sched_halt never returns
	sched_halt();
f01049ad:	e8 7c fe ff ff       	call   f010482e <sched_halt>
}
f01049b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01049b5:	5b                   	pop    %ebx
f01049b6:	5e                   	pop    %esi
f01049b7:	5d                   	pop    %ebp
f01049b8:	c3                   	ret    

f01049b9 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01049b9:	55                   	push   %ebp
f01049ba:	89 e5                	mov    %esp,%ebp
f01049bc:	57                   	push   %edi
f01049bd:	56                   	push   %esi
f01049be:	53                   	push   %ebx
f01049bf:	83 ec 1c             	sub    $0x1c,%esp
f01049c2:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.

	switch (syscallno) {
f01049c5:	83 f8 0c             	cmp    $0xc,%eax
f01049c8:	0f 87 27 05 00 00    	ja     f0104ef5 <syscall+0x53c>
f01049ce:	ff 24 85 c0 7e 10 f0 	jmp    *-0xfef8140(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f01049d5:	e8 28 17 00 00       	call   f0106102 <cpunum>
f01049da:	6a 04                	push   $0x4
f01049dc:	ff 75 10             	pushl  0x10(%ebp)
f01049df:	ff 75 0c             	pushl  0xc(%ebp)
f01049e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01049e5:	ff b0 28 10 23 f0    	pushl  -0xfdcefd8(%eax)
f01049eb:	e8 7c e3 ff ff       	call   f0102d6c <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01049f0:	83 c4 0c             	add    $0xc,%esp
f01049f3:	ff 75 0c             	pushl  0xc(%ebp)
f01049f6:	ff 75 10             	pushl  0x10(%ebp)
f01049f9:	68 86 7e 10 f0       	push   $0xf0107e86
f01049fe:	e8 52 ec ff ff       	call   f0103655 <cprintf>
f0104a03:	83 c4 10             	add    $0x10,%esp
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104a06:	e8 17 bc ff ff       	call   f0100622 <cons_getc>
f0104a0b:	89 c3                	mov    %eax,%ebx

	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((const char *)a1, a2);
	case SYS_cgetc:
		return sys_cgetc();
f0104a0d:	e9 ef 04 00 00       	jmp    f0104f01 <syscall+0x548>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104a12:	83 ec 04             	sub    $0x4,%esp
f0104a15:	6a 01                	push   $0x1
f0104a17:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104a1a:	50                   	push   %eax
f0104a1b:	ff 75 0c             	pushl  0xc(%ebp)
f0104a1e:	e8 ed e3 ff ff       	call   f0102e10 <envid2env>
f0104a23:	83 c4 10             	add    $0x10,%esp
		return r;
f0104a26:	89 c3                	mov    %eax,%ebx
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104a28:	85 c0                	test   %eax,%eax
f0104a2a:	0f 88 d1 04 00 00    	js     f0104f01 <syscall+0x548>
		return r;
	if (e == curenv)
f0104a30:	e8 cd 16 00 00       	call   f0106102 <cpunum>
f0104a35:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104a38:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a3b:	39 90 28 10 23 f0    	cmp    %edx,-0xfdcefd8(%eax)
f0104a41:	75 23                	jne    f0104a66 <syscall+0xad>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104a43:	e8 ba 16 00 00       	call   f0106102 <cpunum>
f0104a48:	83 ec 08             	sub    $0x8,%esp
f0104a4b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a4e:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104a54:	ff 70 48             	pushl  0x48(%eax)
f0104a57:	68 8b 7e 10 f0       	push   $0xf0107e8b
f0104a5c:	e8 f4 eb ff ff       	call   f0103655 <cprintf>
f0104a61:	83 c4 10             	add    $0x10,%esp
f0104a64:	eb 25                	jmp    f0104a8b <syscall+0xd2>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104a66:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104a69:	e8 94 16 00 00       	call   f0106102 <cpunum>
f0104a6e:	83 ec 04             	sub    $0x4,%esp
f0104a71:	53                   	push   %ebx
f0104a72:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a75:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104a7b:	ff 70 48             	pushl  0x48(%eax)
f0104a7e:	68 a6 7e 10 f0       	push   $0xf0107ea6
f0104a83:	e8 cd eb ff ff       	call   f0103655 <cprintf>
f0104a88:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104a8b:	83 ec 0c             	sub    $0xc,%esp
f0104a8e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104a91:	e8 06 e9 ff ff       	call   f010339c <env_destroy>
f0104a96:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104a99:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104a9e:	e9 5e 04 00 00       	jmp    f0104f01 <syscall+0x548>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104aa3:	e8 5a 16 00 00       	call   f0106102 <cpunum>
f0104aa8:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aab:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104ab1:	8b 58 48             	mov    0x48(%eax),%ebx
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_env_destroy:
		return sys_env_destroy(a1);
	case SYS_getenvid:
		return sys_getenvid();
f0104ab4:	e9 48 04 00 00       	jmp    f0104f01 <syscall+0x548>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104ab9:	e8 44 fe ff ff       	call   f0104902 <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *e;
	int err;
	if ((err = env_alloc(&e, curenv->env_id)) < 0) {
f0104abe:	e8 3f 16 00 00       	call   f0106102 <cpunum>
f0104ac3:	83 ec 08             	sub    $0x8,%esp
f0104ac6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ac9:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104acf:	ff 70 48             	pushl  0x48(%eax)
f0104ad2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104ad5:	50                   	push   %eax
f0104ad6:	e8 46 e4 ff ff       	call   f0102f21 <env_alloc>
f0104adb:	83 c4 10             	add    $0x10,%esp
		return err;
f0104ade:	89 c3                	mov    %eax,%ebx
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *e;
	int err;
	if ((err = env_alloc(&e, curenv->env_id)) < 0) {
f0104ae0:	85 c0                	test   %eax,%eax
f0104ae2:	0f 88 19 04 00 00    	js     f0104f01 <syscall+0x548>
		return err;
	}
	e->env_status = ENV_NOT_RUNNABLE;
f0104ae8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104aeb:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f0104af2:	e8 0b 16 00 00       	call   f0106102 <cpunum>
f0104af7:	6b c0 74             	imul   $0x74,%eax,%eax
f0104afa:	8b b0 28 10 23 f0    	mov    -0xfdcefd8(%eax),%esi
f0104b00:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104b05:	89 df                	mov    %ebx,%edi
f0104b07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_tf.tf_regs.reg_eax = 0;
f0104b09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b0c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0104b13:	8b 58 48             	mov    0x48(%eax),%ebx
f0104b16:	e9 e6 03 00 00       	jmp    f0104f01 <syscall+0x548>
	// envid's status.

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if (!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
f0104b1b:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b1e:	83 e8 02             	sub    $0x2,%eax
f0104b21:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104b26:	75 2b                	jne    f0104b53 <syscall+0x19a>
		return -E_INVAL;
	if ((r = envid2env(envid, &e, 1)) < 0) {
f0104b28:	83 ec 04             	sub    $0x4,%esp
f0104b2b:	6a 01                	push   $0x1
f0104b2d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b30:	50                   	push   %eax
f0104b31:	ff 75 0c             	pushl  0xc(%ebp)
f0104b34:	e8 d7 e2 ff ff       	call   f0102e10 <envid2env>
f0104b39:	83 c4 10             	add    $0x10,%esp
f0104b3c:	85 c0                	test   %eax,%eax
f0104b3e:	78 1d                	js     f0104b5d <syscall+0x1a4>
		return r;
	}
	e->env_status = status;
f0104b40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b43:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104b46:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;
f0104b49:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104b4e:	e9 ae 03 00 00       	jmp    f0104f01 <syscall+0x548>

	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if (!(status == ENV_RUNNABLE || status == ENV_NOT_RUNNABLE))
		return -E_INVAL;
f0104b53:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104b58:	e9 a4 03 00 00       	jmp    f0104f01 <syscall+0x548>
	if ((r = envid2env(envid, &e, 1)) < 0) {
		return r;
f0104b5d:	89 c3                	mov    %eax,%ebx
	case SYS_yield:
		sys_yield();
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
f0104b5f:	e9 9d 03 00 00       	jmp    f0104f01 <syscall+0x548>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	if (va >= (void *)UTOP ||
f0104b64:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104b6b:	77 75                	ja     f0104be2 <syscall+0x229>
f0104b6d:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104b74:	75 76                	jne    f0104bec <syscall+0x233>
		(int)va % PGSIZE != 0 ||
f0104b76:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104b79:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f0104b7f:	75 75                	jne    f0104bf6 <syscall+0x23d>
		(~PTE_SYSCALL & perm) != 0) {
		return -E_INVAL;
	}
	struct Env *e;
	int r;
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104b81:	83 ec 04             	sub    $0x4,%esp
f0104b84:	6a 01                	push   $0x1
f0104b86:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b89:	50                   	push   %eax
f0104b8a:	ff 75 0c             	pushl  0xc(%ebp)
f0104b8d:	e8 7e e2 ff ff       	call   f0102e10 <envid2env>
f0104b92:	83 c4 10             	add    $0x10,%esp
f0104b95:	85 c0                	test   %eax,%eax
f0104b97:	78 67                	js     f0104c00 <syscall+0x247>
		return r;

	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
f0104b99:	83 ec 0c             	sub    $0xc,%esp
f0104b9c:	6a 01                	push   $0x1
f0104b9e:	e8 68 c3 ff ff       	call   f0100f0b <page_alloc>
f0104ba3:	89 c6                	mov    %eax,%esi
	if (!pp) {
f0104ba5:	83 c4 10             	add    $0x10,%esp
f0104ba8:	85 c0                	test   %eax,%eax
f0104baa:	74 5b                	je     f0104c07 <syscall+0x24e>
		return -E_NO_MEM;
	}
	if ((r = page_insert(e->env_pgdir, pp, va, PTE_U | perm)) < 0) {
f0104bac:	8b 45 14             	mov    0x14(%ebp),%eax
f0104baf:	83 c8 04             	or     $0x4,%eax
f0104bb2:	50                   	push   %eax
f0104bb3:	ff 75 10             	pushl  0x10(%ebp)
f0104bb6:	56                   	push   %esi
f0104bb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bba:	ff 70 60             	pushl  0x60(%eax)
f0104bbd:	e8 44 c6 ff ff       	call   f0101206 <page_insert>
f0104bc2:	89 c7                	mov    %eax,%edi
f0104bc4:	83 c4 10             	add    $0x10,%esp
f0104bc7:	85 c0                	test   %eax,%eax
f0104bc9:	0f 89 32 03 00 00    	jns    f0104f01 <syscall+0x548>
		page_free(pp);
f0104bcf:	83 ec 0c             	sub    $0xc,%esp
f0104bd2:	56                   	push   %esi
f0104bd3:	e8 c2 c3 ff ff       	call   f0100f9a <page_free>
f0104bd8:	83 c4 10             	add    $0x10,%esp
		return r;
f0104bdb:	89 fb                	mov    %edi,%ebx
f0104bdd:	e9 1f 03 00 00       	jmp    f0104f01 <syscall+0x548>

	// LAB 4: Your code here.
	if (va >= (void *)UTOP ||
		(int)va % PGSIZE != 0 ||
		(~PTE_SYSCALL & perm) != 0) {
		return -E_INVAL;
f0104be2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104be7:	e9 15 03 00 00       	jmp    f0104f01 <syscall+0x548>
f0104bec:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bf1:	e9 0b 03 00 00       	jmp    f0104f01 <syscall+0x548>
f0104bf6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104bfb:	e9 01 03 00 00       	jmp    f0104f01 <syscall+0x548>
	}
	struct Env *e;
	int r;
	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
f0104c00:	89 c3                	mov    %eax,%ebx
f0104c02:	e9 fa 02 00 00       	jmp    f0104f01 <syscall+0x548>

	struct PageInfo *pp = page_alloc(ALLOC_ZERO);
	if (!pp) {
		return -E_NO_MEM;
f0104c07:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *)a2, a3);
f0104c0c:	e9 f0 02 00 00       	jmp    f0104f01 <syscall+0x548>
	case SYS_page_map:
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f0104c11:	8b 75 18             	mov    0x18(%ebp),%esi
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	if (srcva >= (void *)UTOP ||
f0104c14:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104c1b:	0f 87 ae 00 00 00    	ja     f0104ccf <syscall+0x316>
		(int)srcva % PGSIZE != 0 ||
f0104c21:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104c28:	0f 85 ab 00 00 00    	jne    f0104cd9 <syscall+0x320>
f0104c2e:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104c34:	0f 87 9f 00 00 00    	ja     f0104cd9 <syscall+0x320>
		dstva >= (void *)UTOP ||
f0104c3a:	f7 c6 ff 0f 00 00    	test   $0xfff,%esi
f0104c40:	0f 85 9d 00 00 00    	jne    f0104ce3 <syscall+0x32a>
		(int)dstva % PGSIZE != 0 ||
f0104c46:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104c4d:	0f 85 9a 00 00 00    	jne    f0104ced <syscall+0x334>
		((~PTE_SYSCALL & perm) != 0))
		return -E_INVAL;

	struct Env *srcenv, *dstenv;
	int r;
	if ((r = envid2env(srcenvid, &srcenv, 1)) < 0)
f0104c53:	83 ec 04             	sub    $0x4,%esp
f0104c56:	6a 01                	push   $0x1
f0104c58:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104c5b:	50                   	push   %eax
f0104c5c:	ff 75 0c             	pushl  0xc(%ebp)
f0104c5f:	e8 ac e1 ff ff       	call   f0102e10 <envid2env>
f0104c64:	83 c4 10             	add    $0x10,%esp
		return r;
f0104c67:	89 c3                	mov    %eax,%ebx
		((~PTE_SYSCALL & perm) != 0))
		return -E_INVAL;

	struct Env *srcenv, *dstenv;
	int r;
	if ((r = envid2env(srcenvid, &srcenv, 1)) < 0)
f0104c69:	85 c0                	test   %eax,%eax
f0104c6b:	0f 88 90 02 00 00    	js     f0104f01 <syscall+0x548>
		return r;
	if ((r = envid2env(dstenvid, &dstenv, 1)) < 0)
f0104c71:	83 ec 04             	sub    $0x4,%esp
f0104c74:	6a 01                	push   $0x1
f0104c76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c79:	50                   	push   %eax
f0104c7a:	ff 75 14             	pushl  0x14(%ebp)
f0104c7d:	e8 8e e1 ff ff       	call   f0102e10 <envid2env>
f0104c82:	83 c4 10             	add    $0x10,%esp
		return r;
f0104c85:	89 c3                	mov    %eax,%ebx

	struct Env *srcenv, *dstenv;
	int r;
	if ((r = envid2env(srcenvid, &srcenv, 1)) < 0)
		return r;
	if ((r = envid2env(dstenvid, &dstenv, 1)) < 0)
f0104c87:	85 c0                	test   %eax,%eax
f0104c89:	0f 88 72 02 00 00    	js     f0104f01 <syscall+0x548>
		return r;

	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, 0);
f0104c8f:	83 ec 04             	sub    $0x4,%esp
f0104c92:	6a 00                	push   $0x0
f0104c94:	ff 75 10             	pushl  0x10(%ebp)
f0104c97:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c9a:	ff 70 60             	pushl  0x60(%eax)
f0104c9d:	e8 88 c4 ff ff       	call   f010112a <page_lookup>
	if (!pp) {
f0104ca2:	83 c4 10             	add    $0x10,%esp
f0104ca5:	85 c0                	test   %eax,%eax
f0104ca7:	74 4e                	je     f0104cf7 <syscall+0x33e>
		return -E_INVAL;
	}
	if ((r = page_insert(dstenv->env_pgdir, pp, dstva, PTE_U | perm)) < 0)
f0104ca9:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104cac:	83 ca 04             	or     $0x4,%edx
f0104caf:	52                   	push   %edx
f0104cb0:	56                   	push   %esi
f0104cb1:	50                   	push   %eax
f0104cb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104cb5:	ff 70 60             	pushl  0x60(%eax)
f0104cb8:	e8 49 c5 ff ff       	call   f0101206 <page_insert>
f0104cbd:	83 c4 10             	add    $0x10,%esp
f0104cc0:	85 c0                	test   %eax,%eax
f0104cc2:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104cc7:	0f 4e d8             	cmovle %eax,%ebx
f0104cca:	e9 32 02 00 00       	jmp    f0104f01 <syscall+0x548>
	if (srcva >= (void *)UTOP ||
		(int)srcva % PGSIZE != 0 ||
		dstva >= (void *)UTOP ||
		(int)dstva % PGSIZE != 0 ||
		((~PTE_SYSCALL & perm) != 0))
		return -E_INVAL;
f0104ccf:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104cd4:	e9 28 02 00 00       	jmp    f0104f01 <syscall+0x548>
f0104cd9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104cde:	e9 1e 02 00 00       	jmp    f0104f01 <syscall+0x548>
f0104ce3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ce8:	e9 14 02 00 00       	jmp    f0104f01 <syscall+0x548>
f0104ced:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104cf2:	e9 0a 02 00 00       	jmp    f0104f01 <syscall+0x548>
	if ((r = envid2env(dstenvid, &dstenv, 1)) < 0)
		return r;

	struct PageInfo *pp = page_lookup(srcenv->env_pgdir, srcva, 0);
	if (!pp) {
		return -E_INVAL;
f0104cf7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *)a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f0104cfc:	e9 00 02 00 00       	jmp    f0104f01 <syscall+0x548>
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va >= (void *)UTOP)
f0104d01:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d08:	77 3c                	ja     f0104d46 <syscall+0x38d>
		return -E_INVAL;

	struct Env *e;
	int r;
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104d0a:	83 ec 04             	sub    $0x4,%esp
f0104d0d:	6a 01                	push   $0x1
f0104d0f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d12:	50                   	push   %eax
f0104d13:	ff 75 0c             	pushl  0xc(%ebp)
f0104d16:	e8 f5 e0 ff ff       	call   f0102e10 <envid2env>
f0104d1b:	83 c4 10             	add    $0x10,%esp
		return r;
f0104d1e:	89 c3                	mov    %eax,%ebx
	if (va >= (void *)UTOP)
		return -E_INVAL;

	struct Env *e;
	int r;
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104d20:	85 c0                	test   %eax,%eax
f0104d22:	0f 88 d9 01 00 00    	js     f0104f01 <syscall+0x548>
		return r;
	page_remove(e->env_pgdir, va);
f0104d28:	83 ec 08             	sub    $0x8,%esp
f0104d2b:	ff 75 10             	pushl  0x10(%ebp)
f0104d2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d31:	ff 70 60             	pushl  0x60(%eax)
f0104d34:	e8 80 c4 ff ff       	call   f01011b9 <page_remove>
f0104d39:	83 c4 10             	add    $0x10,%esp

	return 0;
f0104d3c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104d41:	e9 bb 01 00 00       	jmp    f0104f01 <syscall+0x548>
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if (va >= (void *)UTOP)
		return -E_INVAL;
f0104d46:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d4b:	e9 b1 01 00 00       	jmp    f0104f01 <syscall+0x548>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if ((r = envid2env(envid, &e, 1)) < 0) {
f0104d50:	83 ec 04             	sub    $0x4,%esp
f0104d53:	6a 01                	push   $0x1
f0104d55:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d58:	50                   	push   %eax
f0104d59:	ff 75 0c             	pushl  0xc(%ebp)
f0104d5c:	e8 af e0 ff ff       	call   f0102e10 <envid2env>
f0104d61:	83 c4 10             	add    $0x10,%esp
f0104d64:	85 c0                	test   %eax,%eax
f0104d66:	78 13                	js     f0104d7b <syscall+0x3c2>
		return r;
	}
	e->env_pgfault_upcall = func;
f0104d68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d6b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104d6e:	89 48 64             	mov    %ecx,0x64(%eax)
	return 0;
f0104d71:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104d76:	e9 86 01 00 00       	jmp    f0104f01 <syscall+0x548>
{
	// LAB 4: Your code here.
	struct Env *e;
	int r;
	if ((r = envid2env(envid, &e, 1)) < 0) {
		return r;
f0104d7b:	89 c3                	mov    %eax,%ebx
	case SYS_page_map:
		return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
f0104d7d:	e9 7f 01 00 00       	jmp    f0104f01 <syscall+0x548>
{
	// LAB 4: Your code here.
	struct Env *env;
	int r;

	if ((r = envid2env(envid, &env, 0)) < 0)
f0104d82:	83 ec 04             	sub    $0x4,%esp
f0104d85:	6a 00                	push   $0x0
f0104d87:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d8a:	50                   	push   %eax
f0104d8b:	ff 75 0c             	pushl  0xc(%ebp)
f0104d8e:	e8 7d e0 ff ff       	call   f0102e10 <envid2env>
f0104d93:	83 c4 10             	add    $0x10,%esp
f0104d96:	85 c0                	test   %eax,%eax
f0104d98:	0f 88 d7 00 00 00    	js     f0104e75 <syscall+0x4bc>
		return r;

	if (!env->env_ipc_recving)
f0104d9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104da1:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104da5:	0f 84 d1 00 00 00    	je     f0104e7c <syscall+0x4c3>
		return -E_IPC_NOT_RECV;

	if (env->env_ipc_dstva == (void *)-1 || srcva == (void *)-1)
f0104dab:	83 78 6c ff          	cmpl   $0xffffffff,0x6c(%eax)
f0104daf:	74 7b                	je     f0104e2c <syscall+0x473>
f0104db1:	83 7d 14 ff          	cmpl   $0xffffffff,0x14(%ebp)
f0104db5:	74 75                	je     f0104e2c <syscall+0x473>
		perm = 0;

	if (perm) {
f0104db7:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
f0104dbb:	74 76                	je     f0104e33 <syscall+0x47a>
		if (srcva >= (void *)UTOP ||
f0104dbd:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104dc4:	0f 87 b9 00 00 00    	ja     f0104e83 <syscall+0x4ca>
f0104dca:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104dd1:	0f 85 b3 00 00 00    	jne    f0104e8a <syscall+0x4d1>
			(unsigned)srcva % PGSIZE != 0 ||
f0104dd7:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104dde:	0f 85 ad 00 00 00    	jne    f0104e91 <syscall+0x4d8>
			((~PTE_SYSCALL & perm) != 0))
			return -E_INVAL;

		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, 0);
f0104de4:	e8 19 13 00 00       	call   f0106102 <cpunum>
f0104de9:	83 ec 04             	sub    $0x4,%esp
f0104dec:	6a 00                	push   $0x0
f0104dee:	ff 75 14             	pushl  0x14(%ebp)
f0104df1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104df4:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104dfa:	ff 70 60             	pushl  0x60(%eax)
f0104dfd:	e8 28 c3 ff ff       	call   f010112a <page_lookup>
		if (!pp) {
f0104e02:	83 c4 10             	add    $0x10,%esp
f0104e05:	85 c0                	test   %eax,%eax
f0104e07:	0f 84 8b 00 00 00    	je     f0104e98 <syscall+0x4df>
			return -E_INVAL;
		}
		if ((r = page_insert(env->env_pgdir, pp, env->env_ipc_dstva, PTE_U|perm)) < 0)
f0104e0d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e10:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104e13:	83 c9 04             	or     $0x4,%ecx
f0104e16:	51                   	push   %ecx
f0104e17:	ff 72 6c             	pushl  0x6c(%edx)
f0104e1a:	50                   	push   %eax
f0104e1b:	ff 72 60             	pushl  0x60(%edx)
f0104e1e:	e8 e3 c3 ff ff       	call   f0101206 <page_insert>
f0104e23:	83 c4 10             	add    $0x10,%esp
f0104e26:	85 c0                	test   %eax,%eax
f0104e28:	79 09                	jns    f0104e33 <syscall+0x47a>
f0104e2a:	eb 73                	jmp    f0104e9f <syscall+0x4e6>

	if (!env->env_ipc_recving)
		return -E_IPC_NOT_RECV;

	if (env->env_ipc_dstva == (void *)-1 || srcva == (void *)-1)
		perm = 0;
f0104e2c:	c7 45 18 00 00 00 00 	movl   $0x0,0x18(%ebp)
		}
		if ((r = page_insert(env->env_pgdir, pp, env->env_ipc_dstva, PTE_U|perm)) < 0)
			return r;
	}

	env->env_ipc_recving = 0;
f0104e33:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104e36:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env->env_ipc_from = curenv->env_id;
f0104e3a:	e8 c3 12 00 00       	call   f0106102 <cpunum>
f0104e3f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e42:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104e48:	8b 40 48             	mov    0x48(%eax),%eax
f0104e4b:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_value = value;
f0104e4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e51:	8b 55 10             	mov    0x10(%ebp),%edx
f0104e54:	89 50 70             	mov    %edx,0x70(%eax)
	env->env_ipc_perm = perm;
f0104e57:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104e5a:	89 78 78             	mov    %edi,0x78(%eax)

	// have sys_ipc_recv return 0
	env->env_tf.tf_regs.reg_eax = 0;
f0104e5d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	env->env_status = ENV_RUNNABLE;
f0104e64:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)

	return 0;
f0104e6b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e70:	e9 8c 00 00 00       	jmp    f0104f01 <syscall+0x548>
	// LAB 4: Your code here.
	struct Env *env;
	int r;

	if ((r = envid2env(envid, &env, 0)) < 0)
		return r;
f0104e75:	89 c3                	mov    %eax,%ebx
f0104e77:	e9 85 00 00 00       	jmp    f0104f01 <syscall+0x548>

	if (!env->env_ipc_recving)
		return -E_IPC_NOT_RECV;
f0104e7c:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104e81:	eb 7e                	jmp    f0104f01 <syscall+0x548>

	if (perm) {
		if (srcva >= (void *)UTOP ||
			(unsigned)srcva % PGSIZE != 0 ||
			((~PTE_SYSCALL & perm) != 0))
			return -E_INVAL;
f0104e83:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e88:	eb 77                	jmp    f0104f01 <syscall+0x548>
f0104e8a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e8f:	eb 70                	jmp    f0104f01 <syscall+0x548>
f0104e91:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e96:	eb 69                	jmp    f0104f01 <syscall+0x548>

		struct PageInfo *pp = page_lookup(curenv->env_pgdir, srcva, 0);
		if (!pp) {
			return -E_INVAL;
f0104e98:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e9d:	eb 62                	jmp    f0104f01 <syscall+0x548>
		}
		if ((r = page_insert(env->env_pgdir, pp, env->env_ipc_dstva, PTE_U|perm)) < 0)
			return r;
f0104e9f:	89 c3                	mov    %eax,%ebx
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *)a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f0104ea1:	eb 5e                	jmp    f0104f01 <syscall+0x548>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if (dstva < (void *)UTOP && ((unsigned)dstva % PGSIZE))
f0104ea3:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104eaa:	77 09                	ja     f0104eb5 <syscall+0x4fc>
f0104eac:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104eb3:	75 47                	jne    f0104efc <syscall+0x543>
		return -E_INVAL;

	curenv->env_ipc_recving = 1;
f0104eb5:	e8 48 12 00 00       	call   f0106102 <cpunum>
f0104eba:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ebd:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104ec3:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f0104ec7:	e8 36 12 00 00       	call   f0106102 <cpunum>
f0104ecc:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ecf:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104ed5:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104ed8:	89 78 6c             	mov    %edi,0x6c(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104edb:	e8 22 12 00 00       	call   f0106102 <cpunum>
f0104ee0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ee3:	8b 80 28 10 23 f0    	mov    -0xfdcefd8(%eax),%eax
f0104ee9:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0104ef0:	e8 0d fa ff ff       	call   f0104902 <sched_yield>
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
	default:
		return -E_INVAL;
f0104ef5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104efa:	eb 05                	jmp    f0104f01 <syscall+0x548>
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *)a2);
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *)a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *)a1);
f0104efc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	default:
		return -E_INVAL;
	}
}
f0104f01:	89 d8                	mov    %ebx,%eax
f0104f03:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104f06:	5b                   	pop    %ebx
f0104f07:	5e                   	pop    %esi
f0104f08:	5f                   	pop    %edi
f0104f09:	5d                   	pop    %ebp
f0104f0a:	c3                   	ret    

f0104f0b <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104f0b:	55                   	push   %ebp
f0104f0c:	89 e5                	mov    %esp,%ebp
f0104f0e:	57                   	push   %edi
f0104f0f:	56                   	push   %esi
f0104f10:	53                   	push   %ebx
f0104f11:	83 ec 14             	sub    $0x14,%esp
f0104f14:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104f17:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104f1a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104f1d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104f20:	8b 1a                	mov    (%edx),%ebx
f0104f22:	8b 01                	mov    (%ecx),%eax
f0104f24:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104f27:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104f2e:	eb 7f                	jmp    f0104faf <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0104f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104f33:	01 d8                	add    %ebx,%eax
f0104f35:	89 c6                	mov    %eax,%esi
f0104f37:	c1 ee 1f             	shr    $0x1f,%esi
f0104f3a:	01 c6                	add    %eax,%esi
f0104f3c:	d1 fe                	sar    %esi
f0104f3e:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0104f41:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104f44:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104f47:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104f49:	eb 03                	jmp    f0104f4e <stab_binsearch+0x43>
			m--;
f0104f4b:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104f4e:	39 c3                	cmp    %eax,%ebx
f0104f50:	7f 0d                	jg     f0104f5f <stab_binsearch+0x54>
f0104f52:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104f56:	83 ea 0c             	sub    $0xc,%edx
f0104f59:	39 f9                	cmp    %edi,%ecx
f0104f5b:	75 ee                	jne    f0104f4b <stab_binsearch+0x40>
f0104f5d:	eb 05                	jmp    f0104f64 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104f5f:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104f62:	eb 4b                	jmp    f0104faf <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104f64:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104f67:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104f6a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104f6e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104f71:	76 11                	jbe    f0104f84 <stab_binsearch+0x79>
			*region_left = m;
f0104f73:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104f76:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104f78:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104f7b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104f82:	eb 2b                	jmp    f0104faf <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104f84:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104f87:	73 14                	jae    f0104f9d <stab_binsearch+0x92>
			*region_right = m - 1;
f0104f89:	83 e8 01             	sub    $0x1,%eax
f0104f8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104f8f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104f92:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104f94:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104f9b:	eb 12                	jmp    f0104faf <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104f9d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104fa0:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104fa2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104fa6:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104fa8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104faf:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104fb2:	0f 8e 78 ff ff ff    	jle    f0104f30 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104fb8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104fbc:	75 0f                	jne    f0104fcd <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104fbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104fc1:	8b 00                	mov    (%eax),%eax
f0104fc3:	83 e8 01             	sub    $0x1,%eax
f0104fc6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104fc9:	89 06                	mov    %eax,(%esi)
f0104fcb:	eb 2c                	jmp    f0104ff9 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104fcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fd0:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104fd2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104fd5:	8b 0e                	mov    (%esi),%ecx
f0104fd7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104fda:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104fdd:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104fe0:	eb 03                	jmp    f0104fe5 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104fe2:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104fe5:	39 c8                	cmp    %ecx,%eax
f0104fe7:	7e 0b                	jle    f0104ff4 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104fe9:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104fed:	83 ea 0c             	sub    $0xc,%edx
f0104ff0:	39 df                	cmp    %ebx,%edi
f0104ff2:	75 ee                	jne    f0104fe2 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104ff4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104ff7:	89 06                	mov    %eax,(%esi)
	}
}
f0104ff9:	83 c4 14             	add    $0x14,%esp
f0104ffc:	5b                   	pop    %ebx
f0104ffd:	5e                   	pop    %esi
f0104ffe:	5f                   	pop    %edi
f0104fff:	5d                   	pop    %ebp
f0105000:	c3                   	ret    

f0105001 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105001:	55                   	push   %ebp
f0105002:	89 e5                	mov    %esp,%ebp
f0105004:	57                   	push   %edi
f0105005:	56                   	push   %esi
f0105006:	53                   	push   %ebx
f0105007:	83 ec 3c             	sub    $0x3c,%esp
f010500a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010500d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105010:	c7 03 f4 7e 10 f0    	movl   $0xf0107ef4,(%ebx)
	info->eip_line = 0;
f0105016:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f010501d:	c7 43 08 f4 7e 10 f0 	movl   $0xf0107ef4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105024:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010502b:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f010502e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105035:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010503b:	0f 87 a3 00 00 00    	ja     f01050e4 <debuginfo_eip+0xe3>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (!user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0105041:	e8 bc 10 00 00       	call   f0106102 <cpunum>
f0105046:	6a 04                	push   $0x4
f0105048:	6a 10                	push   $0x10
f010504a:	68 00 00 20 00       	push   $0x200000
f010504f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105052:	ff b0 28 10 23 f0    	pushl  -0xfdcefd8(%eax)
f0105058:	e8 99 dc ff ff       	call   f0102cf6 <user_mem_check>
f010505d:	83 c4 10             	add    $0x10,%esp
f0105060:	85 c0                	test   %eax,%eax
f0105062:	0f 84 34 02 00 00    	je     f010529c <debuginfo_eip+0x29b>
			return -1;

		stabs = usd->stabs;
f0105068:	a1 00 00 20 00       	mov    0x200000,%eax
f010506d:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0105070:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0105076:	8b 15 08 00 20 00    	mov    0x200008,%edx
f010507c:	89 55 b8             	mov    %edx,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f010507f:	a1 0c 00 20 00       	mov    0x20000c,%eax
f0105084:	89 45 bc             	mov    %eax,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (!user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ||
f0105087:	e8 76 10 00 00       	call   f0106102 <cpunum>
f010508c:	6a 04                	push   $0x4
f010508e:	89 f2                	mov    %esi,%edx
f0105090:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105093:	29 ca                	sub    %ecx,%edx
f0105095:	c1 fa 02             	sar    $0x2,%edx
f0105098:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f010509e:	52                   	push   %edx
f010509f:	51                   	push   %ecx
f01050a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01050a3:	ff b0 28 10 23 f0    	pushl  -0xfdcefd8(%eax)
f01050a9:	e8 48 dc ff ff       	call   f0102cf6 <user_mem_check>
f01050ae:	83 c4 10             	add    $0x10,%esp
f01050b1:	85 c0                	test   %eax,%eax
f01050b3:	0f 84 ea 01 00 00    	je     f01052a3 <debuginfo_eip+0x2a2>
			!user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
f01050b9:	e8 44 10 00 00       	call   f0106102 <cpunum>
f01050be:	6a 04                	push   $0x4
f01050c0:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01050c3:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f01050c6:	29 ca                	sub    %ecx,%edx
f01050c8:	52                   	push   %edx
f01050c9:	51                   	push   %ecx
f01050ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01050cd:	ff b0 28 10 23 f0    	pushl  -0xfdcefd8(%eax)
f01050d3:	e8 1e dc ff ff       	call   f0102cf6 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (!user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ||
f01050d8:	83 c4 10             	add    $0x10,%esp
f01050db:	85 c0                	test   %eax,%eax
f01050dd:	75 1f                	jne    f01050fe <debuginfo_eip+0xfd>
f01050df:	e9 c6 01 00 00       	jmp    f01052aa <debuginfo_eip+0x2a9>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01050e4:	c7 45 bc d9 63 11 f0 	movl   $0xf01163d9,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01050eb:	c7 45 b8 c1 2d 11 f0 	movl   $0xf0112dc1,-0x48(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01050f2:	be c0 2d 11 f0       	mov    $0xf0112dc0,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01050f7:	c7 45 c0 d4 83 10 f0 	movl   $0xf01083d4,-0x40(%ebp)
			!user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01050fe:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105101:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0105104:	0f 83 a7 01 00 00    	jae    f01052b1 <debuginfo_eip+0x2b0>
f010510a:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010510e:	0f 85 a4 01 00 00    	jne    f01052b8 <debuginfo_eip+0x2b7>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105114:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010511b:	2b 75 c0             	sub    -0x40(%ebp),%esi
f010511e:	c1 fe 02             	sar    $0x2,%esi
f0105121:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f0105127:	83 e8 01             	sub    $0x1,%eax
f010512a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010512d:	83 ec 08             	sub    $0x8,%esp
f0105130:	57                   	push   %edi
f0105131:	6a 64                	push   $0x64
f0105133:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0105136:	89 d1                	mov    %edx,%ecx
f0105138:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010513b:	8b 75 c0             	mov    -0x40(%ebp),%esi
f010513e:	89 f0                	mov    %esi,%eax
f0105140:	e8 c6 fd ff ff       	call   f0104f0b <stab_binsearch>
	if (lfile == 0)
f0105145:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105148:	83 c4 10             	add    $0x10,%esp
f010514b:	85 c0                	test   %eax,%eax
f010514d:	0f 84 6c 01 00 00    	je     f01052bf <debuginfo_eip+0x2be>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105153:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105156:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105159:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010515c:	83 ec 08             	sub    $0x8,%esp
f010515f:	57                   	push   %edi
f0105160:	6a 24                	push   $0x24
f0105162:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0105165:	89 d1                	mov    %edx,%ecx
f0105167:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010516a:	89 f0                	mov    %esi,%eax
f010516c:	e8 9a fd ff ff       	call   f0104f0b <stab_binsearch>

	if (lfun <= rfun) {
f0105171:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105174:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105177:	83 c4 10             	add    $0x10,%esp
f010517a:	39 d0                	cmp    %edx,%eax
f010517c:	7f 2e                	jg     f01051ac <debuginfo_eip+0x1ab>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010517e:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0105181:	8d 34 8e             	lea    (%esi,%ecx,4),%esi
f0105184:	89 75 c4             	mov    %esi,-0x3c(%ebp)
f0105187:	8b 36                	mov    (%esi),%esi
f0105189:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f010518c:	2b 4d b8             	sub    -0x48(%ebp),%ecx
f010518f:	39 ce                	cmp    %ecx,%esi
f0105191:	73 06                	jae    f0105199 <debuginfo_eip+0x198>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105193:	03 75 b8             	add    -0x48(%ebp),%esi
f0105196:	89 73 08             	mov    %esi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105199:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f010519c:	8b 4e 08             	mov    0x8(%esi),%ecx
f010519f:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01051a2:	29 cf                	sub    %ecx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f01051a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01051a7:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01051aa:	eb 0f                	jmp    f01051bb <debuginfo_eip+0x1ba>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01051ac:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f01051af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01051b2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01051b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01051b8:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01051bb:	83 ec 08             	sub    $0x8,%esp
f01051be:	6a 3a                	push   $0x3a
f01051c0:	ff 73 08             	pushl  0x8(%ebx)
f01051c3:	e8 fd 08 00 00       	call   f0105ac5 <strfind>
f01051c8:	2b 43 08             	sub    0x8(%ebx),%eax
f01051cb:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01051ce:	83 c4 08             	add    $0x8,%esp
f01051d1:	57                   	push   %edi
f01051d2:	6a 44                	push   $0x44
f01051d4:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01051d7:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01051da:	8b 75 c0             	mov    -0x40(%ebp),%esi
f01051dd:	89 f0                	mov    %esi,%eax
f01051df:	e8 27 fd ff ff       	call   f0104f0b <stab_binsearch>
	info->eip_line = rline;
f01051e4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01051e7:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01051ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01051ed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01051f0:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01051f3:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01051f6:	83 c4 10             	add    $0x10,%esp
f01051f9:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01051fd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105200:	eb 0a                	jmp    f010520c <debuginfo_eip+0x20b>
f0105202:	83 e8 01             	sub    $0x1,%eax
f0105205:	83 ea 0c             	sub    $0xc,%edx
f0105208:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f010520c:	39 c7                	cmp    %eax,%edi
f010520e:	7e 05                	jle    f0105215 <debuginfo_eip+0x214>
f0105210:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105213:	eb 47                	jmp    f010525c <debuginfo_eip+0x25b>
	       && stabs[lline].n_type != N_SOL
f0105215:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105219:	80 f9 84             	cmp    $0x84,%cl
f010521c:	75 0e                	jne    f010522c <debuginfo_eip+0x22b>
f010521e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105221:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105225:	74 1c                	je     f0105243 <debuginfo_eip+0x242>
f0105227:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010522a:	eb 17                	jmp    f0105243 <debuginfo_eip+0x242>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010522c:	80 f9 64             	cmp    $0x64,%cl
f010522f:	75 d1                	jne    f0105202 <debuginfo_eip+0x201>
f0105231:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0105235:	74 cb                	je     f0105202 <debuginfo_eip+0x201>
f0105237:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010523a:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010523e:	74 03                	je     f0105243 <debuginfo_eip+0x242>
f0105240:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105243:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105246:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105249:	8b 14 87             	mov    (%edi,%eax,4),%edx
f010524c:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010524f:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0105252:	29 f8                	sub    %edi,%eax
f0105254:	39 c2                	cmp    %eax,%edx
f0105256:	73 04                	jae    f010525c <debuginfo_eip+0x25b>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105258:	01 fa                	add    %edi,%edx
f010525a:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010525c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010525f:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105262:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105267:	39 f2                	cmp    %esi,%edx
f0105269:	7d 60                	jge    f01052cb <debuginfo_eip+0x2ca>
		for (lline = lfun + 1;
f010526b:	83 c2 01             	add    $0x1,%edx
f010526e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0105271:	89 d0                	mov    %edx,%eax
f0105273:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105276:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0105279:	8d 14 97             	lea    (%edi,%edx,4),%edx
f010527c:	eb 04                	jmp    f0105282 <debuginfo_eip+0x281>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010527e:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105282:	39 c6                	cmp    %eax,%esi
f0105284:	7e 40                	jle    f01052c6 <debuginfo_eip+0x2c5>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105286:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010528a:	83 c0 01             	add    $0x1,%eax
f010528d:	83 c2 0c             	add    $0xc,%edx
f0105290:	80 f9 a0             	cmp    $0xa0,%cl
f0105293:	74 e9                	je     f010527e <debuginfo_eip+0x27d>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105295:	b8 00 00 00 00       	mov    $0x0,%eax
f010529a:	eb 2f                	jmp    f01052cb <debuginfo_eip+0x2ca>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (!user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f010529c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052a1:	eb 28                	jmp    f01052cb <debuginfo_eip+0x2ca>

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (!user_mem_check(curenv, stabs, stab_end - stabs, PTE_U) ||
			!user_mem_check(curenv, stabstr, stabstr_end - stabstr, PTE_U))
			return -1;
f01052a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052a8:	eb 21                	jmp    f01052cb <debuginfo_eip+0x2ca>
f01052aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052af:	eb 1a                	jmp    f01052cb <debuginfo_eip+0x2ca>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01052b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052b6:	eb 13                	jmp    f01052cb <debuginfo_eip+0x2ca>
f01052b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052bd:	eb 0c                	jmp    f01052cb <debuginfo_eip+0x2ca>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01052bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01052c4:	eb 05                	jmp    f01052cb <debuginfo_eip+0x2ca>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01052c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01052cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01052ce:	5b                   	pop    %ebx
f01052cf:	5e                   	pop    %esi
f01052d0:	5f                   	pop    %edi
f01052d1:	5d                   	pop    %ebp
f01052d2:	c3                   	ret    

f01052d3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01052d3:	55                   	push   %ebp
f01052d4:	89 e5                	mov    %esp,%ebp
f01052d6:	57                   	push   %edi
f01052d7:	56                   	push   %esi
f01052d8:	53                   	push   %ebx
f01052d9:	83 ec 1c             	sub    $0x1c,%esp
f01052dc:	89 c7                	mov    %eax,%edi
f01052de:	89 d6                	mov    %edx,%esi
f01052e0:	8b 45 08             	mov    0x8(%ebp),%eax
f01052e3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01052e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01052e9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01052ec:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01052ef:	bb 00 00 00 00       	mov    $0x0,%ebx
f01052f4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01052f7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01052fa:	39 d3                	cmp    %edx,%ebx
f01052fc:	72 05                	jb     f0105303 <printnum+0x30>
f01052fe:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105301:	77 45                	ja     f0105348 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105303:	83 ec 0c             	sub    $0xc,%esp
f0105306:	ff 75 18             	pushl  0x18(%ebp)
f0105309:	8b 45 14             	mov    0x14(%ebp),%eax
f010530c:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010530f:	53                   	push   %ebx
f0105310:	ff 75 10             	pushl  0x10(%ebp)
f0105313:	83 ec 08             	sub    $0x8,%esp
f0105316:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105319:	ff 75 e0             	pushl  -0x20(%ebp)
f010531c:	ff 75 dc             	pushl  -0x24(%ebp)
f010531f:	ff 75 d8             	pushl  -0x28(%ebp)
f0105322:	e8 d9 11 00 00       	call   f0106500 <__udivdi3>
f0105327:	83 c4 18             	add    $0x18,%esp
f010532a:	52                   	push   %edx
f010532b:	50                   	push   %eax
f010532c:	89 f2                	mov    %esi,%edx
f010532e:	89 f8                	mov    %edi,%eax
f0105330:	e8 9e ff ff ff       	call   f01052d3 <printnum>
f0105335:	83 c4 20             	add    $0x20,%esp
f0105338:	eb 18                	jmp    f0105352 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010533a:	83 ec 08             	sub    $0x8,%esp
f010533d:	56                   	push   %esi
f010533e:	ff 75 18             	pushl  0x18(%ebp)
f0105341:	ff d7                	call   *%edi
f0105343:	83 c4 10             	add    $0x10,%esp
f0105346:	eb 03                	jmp    f010534b <printnum+0x78>
f0105348:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010534b:	83 eb 01             	sub    $0x1,%ebx
f010534e:	85 db                	test   %ebx,%ebx
f0105350:	7f e8                	jg     f010533a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105352:	83 ec 08             	sub    $0x8,%esp
f0105355:	56                   	push   %esi
f0105356:	83 ec 04             	sub    $0x4,%esp
f0105359:	ff 75 e4             	pushl  -0x1c(%ebp)
f010535c:	ff 75 e0             	pushl  -0x20(%ebp)
f010535f:	ff 75 dc             	pushl  -0x24(%ebp)
f0105362:	ff 75 d8             	pushl  -0x28(%ebp)
f0105365:	e8 c6 12 00 00       	call   f0106630 <__umoddi3>
f010536a:	83 c4 14             	add    $0x14,%esp
f010536d:	0f be 80 fe 7e 10 f0 	movsbl -0xfef8102(%eax),%eax
f0105374:	50                   	push   %eax
f0105375:	ff d7                	call   *%edi
}
f0105377:	83 c4 10             	add    $0x10,%esp
f010537a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010537d:	5b                   	pop    %ebx
f010537e:	5e                   	pop    %esi
f010537f:	5f                   	pop    %edi
f0105380:	5d                   	pop    %ebp
f0105381:	c3                   	ret    

f0105382 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105382:	55                   	push   %ebp
f0105383:	89 e5                	mov    %esp,%ebp
f0105385:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105388:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010538c:	8b 10                	mov    (%eax),%edx
f010538e:	3b 50 04             	cmp    0x4(%eax),%edx
f0105391:	73 0a                	jae    f010539d <sprintputch+0x1b>
		*b->buf++ = ch;
f0105393:	8d 4a 01             	lea    0x1(%edx),%ecx
f0105396:	89 08                	mov    %ecx,(%eax)
f0105398:	8b 45 08             	mov    0x8(%ebp),%eax
f010539b:	88 02                	mov    %al,(%edx)
}
f010539d:	5d                   	pop    %ebp
f010539e:	c3                   	ret    

f010539f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010539f:	55                   	push   %ebp
f01053a0:	89 e5                	mov    %esp,%ebp
f01053a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01053a5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01053a8:	50                   	push   %eax
f01053a9:	ff 75 10             	pushl  0x10(%ebp)
f01053ac:	ff 75 0c             	pushl  0xc(%ebp)
f01053af:	ff 75 08             	pushl  0x8(%ebp)
f01053b2:	e8 05 00 00 00       	call   f01053bc <vprintfmt>
	va_end(ap);
}
f01053b7:	83 c4 10             	add    $0x10,%esp
f01053ba:	c9                   	leave  
f01053bb:	c3                   	ret    

f01053bc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01053bc:	55                   	push   %ebp
f01053bd:	89 e5                	mov    %esp,%ebp
f01053bf:	57                   	push   %edi
f01053c0:	56                   	push   %esi
f01053c1:	53                   	push   %ebx
f01053c2:	83 ec 2c             	sub    $0x2c,%esp
f01053c5:	8b 75 08             	mov    0x8(%ebp),%esi
f01053c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01053cb:	8b 7d 10             	mov    0x10(%ebp),%edi
f01053ce:	eb 12                	jmp    f01053e2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01053d0:	85 c0                	test   %eax,%eax
f01053d2:	0f 84 42 04 00 00    	je     f010581a <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
f01053d8:	83 ec 08             	sub    $0x8,%esp
f01053db:	53                   	push   %ebx
f01053dc:	50                   	push   %eax
f01053dd:	ff d6                	call   *%esi
f01053df:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01053e2:	83 c7 01             	add    $0x1,%edi
f01053e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01053e9:	83 f8 25             	cmp    $0x25,%eax
f01053ec:	75 e2                	jne    f01053d0 <vprintfmt+0x14>
f01053ee:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f01053f2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01053f9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0105400:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0105407:	b9 00 00 00 00       	mov    $0x0,%ecx
f010540c:	eb 07                	jmp    f0105415 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010540e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0105411:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105415:	8d 47 01             	lea    0x1(%edi),%eax
f0105418:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010541b:	0f b6 07             	movzbl (%edi),%eax
f010541e:	0f b6 d0             	movzbl %al,%edx
f0105421:	83 e8 23             	sub    $0x23,%eax
f0105424:	3c 55                	cmp    $0x55,%al
f0105426:	0f 87 d3 03 00 00    	ja     f01057ff <vprintfmt+0x443>
f010542c:	0f b6 c0             	movzbl %al,%eax
f010542f:	ff 24 85 c0 7f 10 f0 	jmp    *-0xfef8040(,%eax,4)
f0105436:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105439:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f010543d:	eb d6                	jmp    f0105415 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010543f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105442:	b8 00 00 00 00       	mov    $0x0,%eax
f0105447:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010544a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010544d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0105451:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0105454:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0105457:	83 f9 09             	cmp    $0x9,%ecx
f010545a:	77 3f                	ja     f010549b <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010545c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010545f:	eb e9                	jmp    f010544a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105461:	8b 45 14             	mov    0x14(%ebp),%eax
f0105464:	8b 00                	mov    (%eax),%eax
f0105466:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105469:	8b 45 14             	mov    0x14(%ebp),%eax
f010546c:	8d 40 04             	lea    0x4(%eax),%eax
f010546f:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105475:	eb 2a                	jmp    f01054a1 <vprintfmt+0xe5>
f0105477:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010547a:	85 c0                	test   %eax,%eax
f010547c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105481:	0f 49 d0             	cmovns %eax,%edx
f0105484:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105487:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010548a:	eb 89                	jmp    f0105415 <vprintfmt+0x59>
f010548c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010548f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0105496:	e9 7a ff ff ff       	jmp    f0105415 <vprintfmt+0x59>
f010549b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010549e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f01054a1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01054a5:	0f 89 6a ff ff ff    	jns    f0105415 <vprintfmt+0x59>
				width = precision, precision = -1;
f01054ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01054ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01054b1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f01054b8:	e9 58 ff ff ff       	jmp    f0105415 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01054bd:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01054c3:	e9 4d ff ff ff       	jmp    f0105415 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01054c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01054cb:	8d 78 04             	lea    0x4(%eax),%edi
f01054ce:	83 ec 08             	sub    $0x8,%esp
f01054d1:	53                   	push   %ebx
f01054d2:	ff 30                	pushl  (%eax)
f01054d4:	ff d6                	call   *%esi
			break;
f01054d6:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01054d9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01054df:	e9 fe fe ff ff       	jmp    f01053e2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01054e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01054e7:	8d 78 04             	lea    0x4(%eax),%edi
f01054ea:	8b 00                	mov    (%eax),%eax
f01054ec:	99                   	cltd   
f01054ed:	31 d0                	xor    %edx,%eax
f01054ef:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01054f1:	83 f8 08             	cmp    $0x8,%eax
f01054f4:	7f 0b                	jg     f0105501 <vprintfmt+0x145>
f01054f6:	8b 14 85 20 81 10 f0 	mov    -0xfef7ee0(,%eax,4),%edx
f01054fd:	85 d2                	test   %edx,%edx
f01054ff:	75 1b                	jne    f010551c <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0105501:	50                   	push   %eax
f0105502:	68 16 7f 10 f0       	push   $0xf0107f16
f0105507:	53                   	push   %ebx
f0105508:	56                   	push   %esi
f0105509:	e8 91 fe ff ff       	call   f010539f <printfmt>
f010550e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0105511:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105514:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0105517:	e9 c6 fe ff ff       	jmp    f01053e2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f010551c:	52                   	push   %edx
f010551d:	68 05 77 10 f0       	push   $0xf0107705
f0105522:	53                   	push   %ebx
f0105523:	56                   	push   %esi
f0105524:	e8 76 fe ff ff       	call   f010539f <printfmt>
f0105529:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f010552c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010552f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105532:	e9 ab fe ff ff       	jmp    f01053e2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105537:	8b 45 14             	mov    0x14(%ebp),%eax
f010553a:	83 c0 04             	add    $0x4,%eax
f010553d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105540:	8b 45 14             	mov    0x14(%ebp),%eax
f0105543:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0105545:	85 ff                	test   %edi,%edi
f0105547:	b8 0f 7f 10 f0       	mov    $0xf0107f0f,%eax
f010554c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010554f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0105553:	0f 8e 94 00 00 00    	jle    f01055ed <vprintfmt+0x231>
f0105559:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f010555d:	0f 84 98 00 00 00    	je     f01055fb <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105563:	83 ec 08             	sub    $0x8,%esp
f0105566:	ff 75 d0             	pushl  -0x30(%ebp)
f0105569:	57                   	push   %edi
f010556a:	e8 0c 04 00 00       	call   f010597b <strnlen>
f010556f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105572:	29 c1                	sub    %eax,%ecx
f0105574:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0105577:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010557a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010557e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105581:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105584:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105586:	eb 0f                	jmp    f0105597 <vprintfmt+0x1db>
					putch(padc, putdat);
f0105588:	83 ec 08             	sub    $0x8,%esp
f010558b:	53                   	push   %ebx
f010558c:	ff 75 e0             	pushl  -0x20(%ebp)
f010558f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105591:	83 ef 01             	sub    $0x1,%edi
f0105594:	83 c4 10             	add    $0x10,%esp
f0105597:	85 ff                	test   %edi,%edi
f0105599:	7f ed                	jg     f0105588 <vprintfmt+0x1cc>
f010559b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010559e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01055a1:	85 c9                	test   %ecx,%ecx
f01055a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01055a8:	0f 49 c1             	cmovns %ecx,%eax
f01055ab:	29 c1                	sub    %eax,%ecx
f01055ad:	89 75 08             	mov    %esi,0x8(%ebp)
f01055b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01055b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01055b6:	89 cb                	mov    %ecx,%ebx
f01055b8:	eb 4d                	jmp    f0105607 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01055ba:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01055be:	74 1b                	je     f01055db <vprintfmt+0x21f>
f01055c0:	0f be c0             	movsbl %al,%eax
f01055c3:	83 e8 20             	sub    $0x20,%eax
f01055c6:	83 f8 5e             	cmp    $0x5e,%eax
f01055c9:	76 10                	jbe    f01055db <vprintfmt+0x21f>
					putch('?', putdat);
f01055cb:	83 ec 08             	sub    $0x8,%esp
f01055ce:	ff 75 0c             	pushl  0xc(%ebp)
f01055d1:	6a 3f                	push   $0x3f
f01055d3:	ff 55 08             	call   *0x8(%ebp)
f01055d6:	83 c4 10             	add    $0x10,%esp
f01055d9:	eb 0d                	jmp    f01055e8 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f01055db:	83 ec 08             	sub    $0x8,%esp
f01055de:	ff 75 0c             	pushl  0xc(%ebp)
f01055e1:	52                   	push   %edx
f01055e2:	ff 55 08             	call   *0x8(%ebp)
f01055e5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01055e8:	83 eb 01             	sub    $0x1,%ebx
f01055eb:	eb 1a                	jmp    f0105607 <vprintfmt+0x24b>
f01055ed:	89 75 08             	mov    %esi,0x8(%ebp)
f01055f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01055f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01055f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01055f9:	eb 0c                	jmp    f0105607 <vprintfmt+0x24b>
f01055fb:	89 75 08             	mov    %esi,0x8(%ebp)
f01055fe:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105601:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105604:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105607:	83 c7 01             	add    $0x1,%edi
f010560a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010560e:	0f be d0             	movsbl %al,%edx
f0105611:	85 d2                	test   %edx,%edx
f0105613:	74 23                	je     f0105638 <vprintfmt+0x27c>
f0105615:	85 f6                	test   %esi,%esi
f0105617:	78 a1                	js     f01055ba <vprintfmt+0x1fe>
f0105619:	83 ee 01             	sub    $0x1,%esi
f010561c:	79 9c                	jns    f01055ba <vprintfmt+0x1fe>
f010561e:	89 df                	mov    %ebx,%edi
f0105620:	8b 75 08             	mov    0x8(%ebp),%esi
f0105623:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105626:	eb 18                	jmp    f0105640 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0105628:	83 ec 08             	sub    $0x8,%esp
f010562b:	53                   	push   %ebx
f010562c:	6a 20                	push   $0x20
f010562e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105630:	83 ef 01             	sub    $0x1,%edi
f0105633:	83 c4 10             	add    $0x10,%esp
f0105636:	eb 08                	jmp    f0105640 <vprintfmt+0x284>
f0105638:	89 df                	mov    %ebx,%edi
f010563a:	8b 75 08             	mov    0x8(%ebp),%esi
f010563d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105640:	85 ff                	test   %edi,%edi
f0105642:	7f e4                	jg     f0105628 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105644:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105647:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010564a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010564d:	e9 90 fd ff ff       	jmp    f01053e2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105652:	83 f9 01             	cmp    $0x1,%ecx
f0105655:	7e 19                	jle    f0105670 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0105657:	8b 45 14             	mov    0x14(%ebp),%eax
f010565a:	8b 50 04             	mov    0x4(%eax),%edx
f010565d:	8b 00                	mov    (%eax),%eax
f010565f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105662:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105665:	8b 45 14             	mov    0x14(%ebp),%eax
f0105668:	8d 40 08             	lea    0x8(%eax),%eax
f010566b:	89 45 14             	mov    %eax,0x14(%ebp)
f010566e:	eb 38                	jmp    f01056a8 <vprintfmt+0x2ec>
	else if (lflag)
f0105670:	85 c9                	test   %ecx,%ecx
f0105672:	74 1b                	je     f010568f <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0105674:	8b 45 14             	mov    0x14(%ebp),%eax
f0105677:	8b 00                	mov    (%eax),%eax
f0105679:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010567c:	89 c1                	mov    %eax,%ecx
f010567e:	c1 f9 1f             	sar    $0x1f,%ecx
f0105681:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0105684:	8b 45 14             	mov    0x14(%ebp),%eax
f0105687:	8d 40 04             	lea    0x4(%eax),%eax
f010568a:	89 45 14             	mov    %eax,0x14(%ebp)
f010568d:	eb 19                	jmp    f01056a8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f010568f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105692:	8b 00                	mov    (%eax),%eax
f0105694:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105697:	89 c1                	mov    %eax,%ecx
f0105699:	c1 f9 1f             	sar    $0x1f,%ecx
f010569c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010569f:	8b 45 14             	mov    0x14(%ebp),%eax
f01056a2:	8d 40 04             	lea    0x4(%eax),%eax
f01056a5:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01056a8:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01056ab:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01056ae:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01056b3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01056b7:	0f 89 0e 01 00 00    	jns    f01057cb <vprintfmt+0x40f>
				putch('-', putdat);
f01056bd:	83 ec 08             	sub    $0x8,%esp
f01056c0:	53                   	push   %ebx
f01056c1:	6a 2d                	push   $0x2d
f01056c3:	ff d6                	call   *%esi
				num = -(long long) num;
f01056c5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01056c8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01056cb:	f7 da                	neg    %edx
f01056cd:	83 d1 00             	adc    $0x0,%ecx
f01056d0:	f7 d9                	neg    %ecx
f01056d2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01056d5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01056da:	e9 ec 00 00 00       	jmp    f01057cb <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01056df:	83 f9 01             	cmp    $0x1,%ecx
f01056e2:	7e 18                	jle    f01056fc <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f01056e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01056e7:	8b 10                	mov    (%eax),%edx
f01056e9:	8b 48 04             	mov    0x4(%eax),%ecx
f01056ec:	8d 40 08             	lea    0x8(%eax),%eax
f01056ef:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f01056f2:	b8 0a 00 00 00       	mov    $0xa,%eax
f01056f7:	e9 cf 00 00 00       	jmp    f01057cb <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f01056fc:	85 c9                	test   %ecx,%ecx
f01056fe:	74 1a                	je     f010571a <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0105700:	8b 45 14             	mov    0x14(%ebp),%eax
f0105703:	8b 10                	mov    (%eax),%edx
f0105705:	b9 00 00 00 00       	mov    $0x0,%ecx
f010570a:	8d 40 04             	lea    0x4(%eax),%eax
f010570d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0105710:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105715:	e9 b1 00 00 00       	jmp    f01057cb <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f010571a:	8b 45 14             	mov    0x14(%ebp),%eax
f010571d:	8b 10                	mov    (%eax),%edx
f010571f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105724:	8d 40 04             	lea    0x4(%eax),%eax
f0105727:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f010572a:	b8 0a 00 00 00       	mov    $0xa,%eax
f010572f:	e9 97 00 00 00       	jmp    f01057cb <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0105734:	83 ec 08             	sub    $0x8,%esp
f0105737:	53                   	push   %ebx
f0105738:	6a 58                	push   $0x58
f010573a:	ff d6                	call   *%esi
			putch('X', putdat);
f010573c:	83 c4 08             	add    $0x8,%esp
f010573f:	53                   	push   %ebx
f0105740:	6a 58                	push   $0x58
f0105742:	ff d6                	call   *%esi
			putch('X', putdat);
f0105744:	83 c4 08             	add    $0x8,%esp
f0105747:	53                   	push   %ebx
f0105748:	6a 58                	push   $0x58
f010574a:	ff d6                	call   *%esi
			break;
f010574c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010574f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0105752:	e9 8b fc ff ff       	jmp    f01053e2 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0105757:	83 ec 08             	sub    $0x8,%esp
f010575a:	53                   	push   %ebx
f010575b:	6a 30                	push   $0x30
f010575d:	ff d6                	call   *%esi
			putch('x', putdat);
f010575f:	83 c4 08             	add    $0x8,%esp
f0105762:	53                   	push   %ebx
f0105763:	6a 78                	push   $0x78
f0105765:	ff d6                	call   *%esi
			num = (unsigned long long)
f0105767:	8b 45 14             	mov    0x14(%ebp),%eax
f010576a:	8b 10                	mov    (%eax),%edx
f010576c:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0105771:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105774:	8d 40 04             	lea    0x4(%eax),%eax
f0105777:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010577a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f010577f:	eb 4a                	jmp    f01057cb <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105781:	83 f9 01             	cmp    $0x1,%ecx
f0105784:	7e 15                	jle    f010579b <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
f0105786:	8b 45 14             	mov    0x14(%ebp),%eax
f0105789:	8b 10                	mov    (%eax),%edx
f010578b:	8b 48 04             	mov    0x4(%eax),%ecx
f010578e:	8d 40 08             	lea    0x8(%eax),%eax
f0105791:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0105794:	b8 10 00 00 00       	mov    $0x10,%eax
f0105799:	eb 30                	jmp    f01057cb <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f010579b:	85 c9                	test   %ecx,%ecx
f010579d:	74 17                	je     f01057b6 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
f010579f:	8b 45 14             	mov    0x14(%ebp),%eax
f01057a2:	8b 10                	mov    (%eax),%edx
f01057a4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057a9:	8d 40 04             	lea    0x4(%eax),%eax
f01057ac:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01057af:	b8 10 00 00 00       	mov    $0x10,%eax
f01057b4:	eb 15                	jmp    f01057cb <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f01057b6:	8b 45 14             	mov    0x14(%ebp),%eax
f01057b9:	8b 10                	mov    (%eax),%edx
f01057bb:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057c0:	8d 40 04             	lea    0x4(%eax),%eax
f01057c3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f01057c6:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01057cb:	83 ec 0c             	sub    $0xc,%esp
f01057ce:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01057d2:	57                   	push   %edi
f01057d3:	ff 75 e0             	pushl  -0x20(%ebp)
f01057d6:	50                   	push   %eax
f01057d7:	51                   	push   %ecx
f01057d8:	52                   	push   %edx
f01057d9:	89 da                	mov    %ebx,%edx
f01057db:	89 f0                	mov    %esi,%eax
f01057dd:	e8 f1 fa ff ff       	call   f01052d3 <printnum>
			break;
f01057e2:	83 c4 20             	add    $0x20,%esp
f01057e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01057e8:	e9 f5 fb ff ff       	jmp    f01053e2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01057ed:	83 ec 08             	sub    $0x8,%esp
f01057f0:	53                   	push   %ebx
f01057f1:	52                   	push   %edx
f01057f2:	ff d6                	call   *%esi
			break;
f01057f4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01057fa:	e9 e3 fb ff ff       	jmp    f01053e2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01057ff:	83 ec 08             	sub    $0x8,%esp
f0105802:	53                   	push   %ebx
f0105803:	6a 25                	push   $0x25
f0105805:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105807:	83 c4 10             	add    $0x10,%esp
f010580a:	eb 03                	jmp    f010580f <vprintfmt+0x453>
f010580c:	83 ef 01             	sub    $0x1,%edi
f010580f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0105813:	75 f7                	jne    f010580c <vprintfmt+0x450>
f0105815:	e9 c8 fb ff ff       	jmp    f01053e2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010581a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010581d:	5b                   	pop    %ebx
f010581e:	5e                   	pop    %esi
f010581f:	5f                   	pop    %edi
f0105820:	5d                   	pop    %ebp
f0105821:	c3                   	ret    

f0105822 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105822:	55                   	push   %ebp
f0105823:	89 e5                	mov    %esp,%ebp
f0105825:	83 ec 18             	sub    $0x18,%esp
f0105828:	8b 45 08             	mov    0x8(%ebp),%eax
f010582b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010582e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105831:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105835:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105838:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010583f:	85 c0                	test   %eax,%eax
f0105841:	74 26                	je     f0105869 <vsnprintf+0x47>
f0105843:	85 d2                	test   %edx,%edx
f0105845:	7e 22                	jle    f0105869 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105847:	ff 75 14             	pushl  0x14(%ebp)
f010584a:	ff 75 10             	pushl  0x10(%ebp)
f010584d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105850:	50                   	push   %eax
f0105851:	68 82 53 10 f0       	push   $0xf0105382
f0105856:	e8 61 fb ff ff       	call   f01053bc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010585b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010585e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105861:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105864:	83 c4 10             	add    $0x10,%esp
f0105867:	eb 05                	jmp    f010586e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105869:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010586e:	c9                   	leave  
f010586f:	c3                   	ret    

f0105870 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105870:	55                   	push   %ebp
f0105871:	89 e5                	mov    %esp,%ebp
f0105873:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105876:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105879:	50                   	push   %eax
f010587a:	ff 75 10             	pushl  0x10(%ebp)
f010587d:	ff 75 0c             	pushl  0xc(%ebp)
f0105880:	ff 75 08             	pushl  0x8(%ebp)
f0105883:	e8 9a ff ff ff       	call   f0105822 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105888:	c9                   	leave  
f0105889:	c3                   	ret    

f010588a <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010588a:	55                   	push   %ebp
f010588b:	89 e5                	mov    %esp,%ebp
f010588d:	57                   	push   %edi
f010588e:	56                   	push   %esi
f010588f:	53                   	push   %ebx
f0105890:	83 ec 0c             	sub    $0xc,%esp
f0105893:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105896:	85 c0                	test   %eax,%eax
f0105898:	74 11                	je     f01058ab <readline+0x21>
		cprintf("%s", prompt);
f010589a:	83 ec 08             	sub    $0x8,%esp
f010589d:	50                   	push   %eax
f010589e:	68 05 77 10 f0       	push   $0xf0107705
f01058a3:	e8 ad dd ff ff       	call   f0103655 <cprintf>
f01058a8:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01058ab:	83 ec 0c             	sub    $0xc,%esp
f01058ae:	6a 00                	push   $0x0
f01058b0:	e8 fd ae ff ff       	call   f01007b2 <iscons>
f01058b5:	89 c7                	mov    %eax,%edi
f01058b7:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01058ba:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01058bf:	e8 dd ae ff ff       	call   f01007a1 <getchar>
f01058c4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01058c6:	85 c0                	test   %eax,%eax
f01058c8:	79 18                	jns    f01058e2 <readline+0x58>
			cprintf("read error: %e\n", c);
f01058ca:	83 ec 08             	sub    $0x8,%esp
f01058cd:	50                   	push   %eax
f01058ce:	68 44 81 10 f0       	push   $0xf0108144
f01058d3:	e8 7d dd ff ff       	call   f0103655 <cprintf>
			return NULL;
f01058d8:	83 c4 10             	add    $0x10,%esp
f01058db:	b8 00 00 00 00       	mov    $0x0,%eax
f01058e0:	eb 79                	jmp    f010595b <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01058e2:	83 f8 08             	cmp    $0x8,%eax
f01058e5:	0f 94 c2             	sete   %dl
f01058e8:	83 f8 7f             	cmp    $0x7f,%eax
f01058eb:	0f 94 c0             	sete   %al
f01058ee:	08 c2                	or     %al,%dl
f01058f0:	74 1a                	je     f010590c <readline+0x82>
f01058f2:	85 f6                	test   %esi,%esi
f01058f4:	7e 16                	jle    f010590c <readline+0x82>
			if (echoing)
f01058f6:	85 ff                	test   %edi,%edi
f01058f8:	74 0d                	je     f0105907 <readline+0x7d>
				cputchar('\b');
f01058fa:	83 ec 0c             	sub    $0xc,%esp
f01058fd:	6a 08                	push   $0x8
f01058ff:	e8 8d ae ff ff       	call   f0100791 <cputchar>
f0105904:	83 c4 10             	add    $0x10,%esp
			i--;
f0105907:	83 ee 01             	sub    $0x1,%esi
f010590a:	eb b3                	jmp    f01058bf <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010590c:	83 fb 1f             	cmp    $0x1f,%ebx
f010590f:	7e 23                	jle    f0105934 <readline+0xaa>
f0105911:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105917:	7f 1b                	jg     f0105934 <readline+0xaa>
			if (echoing)
f0105919:	85 ff                	test   %edi,%edi
f010591b:	74 0c                	je     f0105929 <readline+0x9f>
				cputchar(c);
f010591d:	83 ec 0c             	sub    $0xc,%esp
f0105920:	53                   	push   %ebx
f0105921:	e8 6b ae ff ff       	call   f0100791 <cputchar>
f0105926:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105929:	88 9e 80 0a 23 f0    	mov    %bl,-0xfdcf580(%esi)
f010592f:	8d 76 01             	lea    0x1(%esi),%esi
f0105932:	eb 8b                	jmp    f01058bf <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0105934:	83 fb 0a             	cmp    $0xa,%ebx
f0105937:	74 05                	je     f010593e <readline+0xb4>
f0105939:	83 fb 0d             	cmp    $0xd,%ebx
f010593c:	75 81                	jne    f01058bf <readline+0x35>
			if (echoing)
f010593e:	85 ff                	test   %edi,%edi
f0105940:	74 0d                	je     f010594f <readline+0xc5>
				cputchar('\n');
f0105942:	83 ec 0c             	sub    $0xc,%esp
f0105945:	6a 0a                	push   $0xa
f0105947:	e8 45 ae ff ff       	call   f0100791 <cputchar>
f010594c:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010594f:	c6 86 80 0a 23 f0 00 	movb   $0x0,-0xfdcf580(%esi)
			return buf;
f0105956:	b8 80 0a 23 f0       	mov    $0xf0230a80,%eax
		}
	}
}
f010595b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010595e:	5b                   	pop    %ebx
f010595f:	5e                   	pop    %esi
f0105960:	5f                   	pop    %edi
f0105961:	5d                   	pop    %ebp
f0105962:	c3                   	ret    

f0105963 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105963:	55                   	push   %ebp
f0105964:	89 e5                	mov    %esp,%ebp
f0105966:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105969:	b8 00 00 00 00       	mov    $0x0,%eax
f010596e:	eb 03                	jmp    f0105973 <strlen+0x10>
		n++;
f0105970:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105973:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105977:	75 f7                	jne    f0105970 <strlen+0xd>
		n++;
	return n;
}
f0105979:	5d                   	pop    %ebp
f010597a:	c3                   	ret    

f010597b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010597b:	55                   	push   %ebp
f010597c:	89 e5                	mov    %esp,%ebp
f010597e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105981:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105984:	ba 00 00 00 00       	mov    $0x0,%edx
f0105989:	eb 03                	jmp    f010598e <strnlen+0x13>
		n++;
f010598b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010598e:	39 c2                	cmp    %eax,%edx
f0105990:	74 08                	je     f010599a <strnlen+0x1f>
f0105992:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105996:	75 f3                	jne    f010598b <strnlen+0x10>
f0105998:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010599a:	5d                   	pop    %ebp
f010599b:	c3                   	ret    

f010599c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010599c:	55                   	push   %ebp
f010599d:	89 e5                	mov    %esp,%ebp
f010599f:	53                   	push   %ebx
f01059a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01059a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01059a6:	89 c2                	mov    %eax,%edx
f01059a8:	83 c2 01             	add    $0x1,%edx
f01059ab:	83 c1 01             	add    $0x1,%ecx
f01059ae:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01059b2:	88 5a ff             	mov    %bl,-0x1(%edx)
f01059b5:	84 db                	test   %bl,%bl
f01059b7:	75 ef                	jne    f01059a8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01059b9:	5b                   	pop    %ebx
f01059ba:	5d                   	pop    %ebp
f01059bb:	c3                   	ret    

f01059bc <strcat>:

char *
strcat(char *dst, const char *src)
{
f01059bc:	55                   	push   %ebp
f01059bd:	89 e5                	mov    %esp,%ebp
f01059bf:	53                   	push   %ebx
f01059c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01059c3:	53                   	push   %ebx
f01059c4:	e8 9a ff ff ff       	call   f0105963 <strlen>
f01059c9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01059cc:	ff 75 0c             	pushl  0xc(%ebp)
f01059cf:	01 d8                	add    %ebx,%eax
f01059d1:	50                   	push   %eax
f01059d2:	e8 c5 ff ff ff       	call   f010599c <strcpy>
	return dst;
}
f01059d7:	89 d8                	mov    %ebx,%eax
f01059d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01059dc:	c9                   	leave  
f01059dd:	c3                   	ret    

f01059de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01059de:	55                   	push   %ebp
f01059df:	89 e5                	mov    %esp,%ebp
f01059e1:	56                   	push   %esi
f01059e2:	53                   	push   %ebx
f01059e3:	8b 75 08             	mov    0x8(%ebp),%esi
f01059e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01059e9:	89 f3                	mov    %esi,%ebx
f01059eb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01059ee:	89 f2                	mov    %esi,%edx
f01059f0:	eb 0f                	jmp    f0105a01 <strncpy+0x23>
		*dst++ = *src;
f01059f2:	83 c2 01             	add    $0x1,%edx
f01059f5:	0f b6 01             	movzbl (%ecx),%eax
f01059f8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01059fb:	80 39 01             	cmpb   $0x1,(%ecx)
f01059fe:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105a01:	39 da                	cmp    %ebx,%edx
f0105a03:	75 ed                	jne    f01059f2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105a05:	89 f0                	mov    %esi,%eax
f0105a07:	5b                   	pop    %ebx
f0105a08:	5e                   	pop    %esi
f0105a09:	5d                   	pop    %ebp
f0105a0a:	c3                   	ret    

f0105a0b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105a0b:	55                   	push   %ebp
f0105a0c:	89 e5                	mov    %esp,%ebp
f0105a0e:	56                   	push   %esi
f0105a0f:	53                   	push   %ebx
f0105a10:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105a16:	8b 55 10             	mov    0x10(%ebp),%edx
f0105a19:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105a1b:	85 d2                	test   %edx,%edx
f0105a1d:	74 21                	je     f0105a40 <strlcpy+0x35>
f0105a1f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105a23:	89 f2                	mov    %esi,%edx
f0105a25:	eb 09                	jmp    f0105a30 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105a27:	83 c2 01             	add    $0x1,%edx
f0105a2a:	83 c1 01             	add    $0x1,%ecx
f0105a2d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105a30:	39 c2                	cmp    %eax,%edx
f0105a32:	74 09                	je     f0105a3d <strlcpy+0x32>
f0105a34:	0f b6 19             	movzbl (%ecx),%ebx
f0105a37:	84 db                	test   %bl,%bl
f0105a39:	75 ec                	jne    f0105a27 <strlcpy+0x1c>
f0105a3b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0105a3d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105a40:	29 f0                	sub    %esi,%eax
}
f0105a42:	5b                   	pop    %ebx
f0105a43:	5e                   	pop    %esi
f0105a44:	5d                   	pop    %ebp
f0105a45:	c3                   	ret    

f0105a46 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105a46:	55                   	push   %ebp
f0105a47:	89 e5                	mov    %esp,%ebp
f0105a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105a4f:	eb 06                	jmp    f0105a57 <strcmp+0x11>
		p++, q++;
f0105a51:	83 c1 01             	add    $0x1,%ecx
f0105a54:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105a57:	0f b6 01             	movzbl (%ecx),%eax
f0105a5a:	84 c0                	test   %al,%al
f0105a5c:	74 04                	je     f0105a62 <strcmp+0x1c>
f0105a5e:	3a 02                	cmp    (%edx),%al
f0105a60:	74 ef                	je     f0105a51 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105a62:	0f b6 c0             	movzbl %al,%eax
f0105a65:	0f b6 12             	movzbl (%edx),%edx
f0105a68:	29 d0                	sub    %edx,%eax
}
f0105a6a:	5d                   	pop    %ebp
f0105a6b:	c3                   	ret    

f0105a6c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105a6c:	55                   	push   %ebp
f0105a6d:	89 e5                	mov    %esp,%ebp
f0105a6f:	53                   	push   %ebx
f0105a70:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a73:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105a76:	89 c3                	mov    %eax,%ebx
f0105a78:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105a7b:	eb 06                	jmp    f0105a83 <strncmp+0x17>
		n--, p++, q++;
f0105a7d:	83 c0 01             	add    $0x1,%eax
f0105a80:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105a83:	39 d8                	cmp    %ebx,%eax
f0105a85:	74 15                	je     f0105a9c <strncmp+0x30>
f0105a87:	0f b6 08             	movzbl (%eax),%ecx
f0105a8a:	84 c9                	test   %cl,%cl
f0105a8c:	74 04                	je     f0105a92 <strncmp+0x26>
f0105a8e:	3a 0a                	cmp    (%edx),%cl
f0105a90:	74 eb                	je     f0105a7d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105a92:	0f b6 00             	movzbl (%eax),%eax
f0105a95:	0f b6 12             	movzbl (%edx),%edx
f0105a98:	29 d0                	sub    %edx,%eax
f0105a9a:	eb 05                	jmp    f0105aa1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105a9c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105aa1:	5b                   	pop    %ebx
f0105aa2:	5d                   	pop    %ebp
f0105aa3:	c3                   	ret    

f0105aa4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105aa4:	55                   	push   %ebp
f0105aa5:	89 e5                	mov    %esp,%ebp
f0105aa7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105aaa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105aae:	eb 07                	jmp    f0105ab7 <strchr+0x13>
		if (*s == c)
f0105ab0:	38 ca                	cmp    %cl,%dl
f0105ab2:	74 0f                	je     f0105ac3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105ab4:	83 c0 01             	add    $0x1,%eax
f0105ab7:	0f b6 10             	movzbl (%eax),%edx
f0105aba:	84 d2                	test   %dl,%dl
f0105abc:	75 f2                	jne    f0105ab0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105abe:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ac3:	5d                   	pop    %ebp
f0105ac4:	c3                   	ret    

f0105ac5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105ac5:	55                   	push   %ebp
f0105ac6:	89 e5                	mov    %esp,%ebp
f0105ac8:	8b 45 08             	mov    0x8(%ebp),%eax
f0105acb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105acf:	eb 03                	jmp    f0105ad4 <strfind+0xf>
f0105ad1:	83 c0 01             	add    $0x1,%eax
f0105ad4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105ad7:	38 ca                	cmp    %cl,%dl
f0105ad9:	74 04                	je     f0105adf <strfind+0x1a>
f0105adb:	84 d2                	test   %dl,%dl
f0105add:	75 f2                	jne    f0105ad1 <strfind+0xc>
			break;
	return (char *) s;
}
f0105adf:	5d                   	pop    %ebp
f0105ae0:	c3                   	ret    

f0105ae1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105ae1:	55                   	push   %ebp
f0105ae2:	89 e5                	mov    %esp,%ebp
f0105ae4:	57                   	push   %edi
f0105ae5:	56                   	push   %esi
f0105ae6:	53                   	push   %ebx
f0105ae7:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105aea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105aed:	85 c9                	test   %ecx,%ecx
f0105aef:	74 36                	je     f0105b27 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105af1:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105af7:	75 28                	jne    f0105b21 <memset+0x40>
f0105af9:	f6 c1 03             	test   $0x3,%cl
f0105afc:	75 23                	jne    f0105b21 <memset+0x40>
		c &= 0xFF;
f0105afe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105b02:	89 d3                	mov    %edx,%ebx
f0105b04:	c1 e3 08             	shl    $0x8,%ebx
f0105b07:	89 d6                	mov    %edx,%esi
f0105b09:	c1 e6 18             	shl    $0x18,%esi
f0105b0c:	89 d0                	mov    %edx,%eax
f0105b0e:	c1 e0 10             	shl    $0x10,%eax
f0105b11:	09 f0                	or     %esi,%eax
f0105b13:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105b15:	89 d8                	mov    %ebx,%eax
f0105b17:	09 d0                	or     %edx,%eax
f0105b19:	c1 e9 02             	shr    $0x2,%ecx
f0105b1c:	fc                   	cld    
f0105b1d:	f3 ab                	rep stos %eax,%es:(%edi)
f0105b1f:	eb 06                	jmp    f0105b27 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105b21:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b24:	fc                   	cld    
f0105b25:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105b27:	89 f8                	mov    %edi,%eax
f0105b29:	5b                   	pop    %ebx
f0105b2a:	5e                   	pop    %esi
f0105b2b:	5f                   	pop    %edi
f0105b2c:	5d                   	pop    %ebp
f0105b2d:	c3                   	ret    

f0105b2e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105b2e:	55                   	push   %ebp
f0105b2f:	89 e5                	mov    %esp,%ebp
f0105b31:	57                   	push   %edi
f0105b32:	56                   	push   %esi
f0105b33:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b36:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105b39:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105b3c:	39 c6                	cmp    %eax,%esi
f0105b3e:	73 35                	jae    f0105b75 <memmove+0x47>
f0105b40:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105b43:	39 d0                	cmp    %edx,%eax
f0105b45:	73 2e                	jae    f0105b75 <memmove+0x47>
		s += n;
		d += n;
f0105b47:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105b4a:	89 d6                	mov    %edx,%esi
f0105b4c:	09 fe                	or     %edi,%esi
f0105b4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105b54:	75 13                	jne    f0105b69 <memmove+0x3b>
f0105b56:	f6 c1 03             	test   $0x3,%cl
f0105b59:	75 0e                	jne    f0105b69 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0105b5b:	83 ef 04             	sub    $0x4,%edi
f0105b5e:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105b61:	c1 e9 02             	shr    $0x2,%ecx
f0105b64:	fd                   	std    
f0105b65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105b67:	eb 09                	jmp    f0105b72 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105b69:	83 ef 01             	sub    $0x1,%edi
f0105b6c:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105b6f:	fd                   	std    
f0105b70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105b72:	fc                   	cld    
f0105b73:	eb 1d                	jmp    f0105b92 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105b75:	89 f2                	mov    %esi,%edx
f0105b77:	09 c2                	or     %eax,%edx
f0105b79:	f6 c2 03             	test   $0x3,%dl
f0105b7c:	75 0f                	jne    f0105b8d <memmove+0x5f>
f0105b7e:	f6 c1 03             	test   $0x3,%cl
f0105b81:	75 0a                	jne    f0105b8d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105b83:	c1 e9 02             	shr    $0x2,%ecx
f0105b86:	89 c7                	mov    %eax,%edi
f0105b88:	fc                   	cld    
f0105b89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105b8b:	eb 05                	jmp    f0105b92 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105b8d:	89 c7                	mov    %eax,%edi
f0105b8f:	fc                   	cld    
f0105b90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105b92:	5e                   	pop    %esi
f0105b93:	5f                   	pop    %edi
f0105b94:	5d                   	pop    %ebp
f0105b95:	c3                   	ret    

f0105b96 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105b96:	55                   	push   %ebp
f0105b97:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105b99:	ff 75 10             	pushl  0x10(%ebp)
f0105b9c:	ff 75 0c             	pushl  0xc(%ebp)
f0105b9f:	ff 75 08             	pushl  0x8(%ebp)
f0105ba2:	e8 87 ff ff ff       	call   f0105b2e <memmove>
}
f0105ba7:	c9                   	leave  
f0105ba8:	c3                   	ret    

f0105ba9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105ba9:	55                   	push   %ebp
f0105baa:	89 e5                	mov    %esp,%ebp
f0105bac:	56                   	push   %esi
f0105bad:	53                   	push   %ebx
f0105bae:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bb1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105bb4:	89 c6                	mov    %eax,%esi
f0105bb6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105bb9:	eb 1a                	jmp    f0105bd5 <memcmp+0x2c>
		if (*s1 != *s2)
f0105bbb:	0f b6 08             	movzbl (%eax),%ecx
f0105bbe:	0f b6 1a             	movzbl (%edx),%ebx
f0105bc1:	38 d9                	cmp    %bl,%cl
f0105bc3:	74 0a                	je     f0105bcf <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105bc5:	0f b6 c1             	movzbl %cl,%eax
f0105bc8:	0f b6 db             	movzbl %bl,%ebx
f0105bcb:	29 d8                	sub    %ebx,%eax
f0105bcd:	eb 0f                	jmp    f0105bde <memcmp+0x35>
		s1++, s2++;
f0105bcf:	83 c0 01             	add    $0x1,%eax
f0105bd2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105bd5:	39 f0                	cmp    %esi,%eax
f0105bd7:	75 e2                	jne    f0105bbb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105bd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105bde:	5b                   	pop    %ebx
f0105bdf:	5e                   	pop    %esi
f0105be0:	5d                   	pop    %ebp
f0105be1:	c3                   	ret    

f0105be2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105be2:	55                   	push   %ebp
f0105be3:	89 e5                	mov    %esp,%ebp
f0105be5:	53                   	push   %ebx
f0105be6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0105be9:	89 c1                	mov    %eax,%ecx
f0105beb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105bee:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105bf2:	eb 0a                	jmp    f0105bfe <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105bf4:	0f b6 10             	movzbl (%eax),%edx
f0105bf7:	39 da                	cmp    %ebx,%edx
f0105bf9:	74 07                	je     f0105c02 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105bfb:	83 c0 01             	add    $0x1,%eax
f0105bfe:	39 c8                	cmp    %ecx,%eax
f0105c00:	72 f2                	jb     f0105bf4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105c02:	5b                   	pop    %ebx
f0105c03:	5d                   	pop    %ebp
f0105c04:	c3                   	ret    

f0105c05 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105c05:	55                   	push   %ebp
f0105c06:	89 e5                	mov    %esp,%ebp
f0105c08:	57                   	push   %edi
f0105c09:	56                   	push   %esi
f0105c0a:	53                   	push   %ebx
f0105c0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105c11:	eb 03                	jmp    f0105c16 <strtol+0x11>
		s++;
f0105c13:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105c16:	0f b6 01             	movzbl (%ecx),%eax
f0105c19:	3c 20                	cmp    $0x20,%al
f0105c1b:	74 f6                	je     f0105c13 <strtol+0xe>
f0105c1d:	3c 09                	cmp    $0x9,%al
f0105c1f:	74 f2                	je     f0105c13 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105c21:	3c 2b                	cmp    $0x2b,%al
f0105c23:	75 0a                	jne    f0105c2f <strtol+0x2a>
		s++;
f0105c25:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105c28:	bf 00 00 00 00       	mov    $0x0,%edi
f0105c2d:	eb 11                	jmp    f0105c40 <strtol+0x3b>
f0105c2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105c34:	3c 2d                	cmp    $0x2d,%al
f0105c36:	75 08                	jne    f0105c40 <strtol+0x3b>
		s++, neg = 1;
f0105c38:	83 c1 01             	add    $0x1,%ecx
f0105c3b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105c40:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105c46:	75 15                	jne    f0105c5d <strtol+0x58>
f0105c48:	80 39 30             	cmpb   $0x30,(%ecx)
f0105c4b:	75 10                	jne    f0105c5d <strtol+0x58>
f0105c4d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105c51:	75 7c                	jne    f0105ccf <strtol+0xca>
		s += 2, base = 16;
f0105c53:	83 c1 02             	add    $0x2,%ecx
f0105c56:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105c5b:	eb 16                	jmp    f0105c73 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0105c5d:	85 db                	test   %ebx,%ebx
f0105c5f:	75 12                	jne    f0105c73 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105c61:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105c66:	80 39 30             	cmpb   $0x30,(%ecx)
f0105c69:	75 08                	jne    f0105c73 <strtol+0x6e>
		s++, base = 8;
f0105c6b:	83 c1 01             	add    $0x1,%ecx
f0105c6e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105c73:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c78:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105c7b:	0f b6 11             	movzbl (%ecx),%edx
f0105c7e:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105c81:	89 f3                	mov    %esi,%ebx
f0105c83:	80 fb 09             	cmp    $0x9,%bl
f0105c86:	77 08                	ja     f0105c90 <strtol+0x8b>
			dig = *s - '0';
f0105c88:	0f be d2             	movsbl %dl,%edx
f0105c8b:	83 ea 30             	sub    $0x30,%edx
f0105c8e:	eb 22                	jmp    f0105cb2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105c90:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105c93:	89 f3                	mov    %esi,%ebx
f0105c95:	80 fb 19             	cmp    $0x19,%bl
f0105c98:	77 08                	ja     f0105ca2 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0105c9a:	0f be d2             	movsbl %dl,%edx
f0105c9d:	83 ea 57             	sub    $0x57,%edx
f0105ca0:	eb 10                	jmp    f0105cb2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105ca2:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105ca5:	89 f3                	mov    %esi,%ebx
f0105ca7:	80 fb 19             	cmp    $0x19,%bl
f0105caa:	77 16                	ja     f0105cc2 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105cac:	0f be d2             	movsbl %dl,%edx
f0105caf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105cb2:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105cb5:	7d 0b                	jge    f0105cc2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105cb7:	83 c1 01             	add    $0x1,%ecx
f0105cba:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105cbe:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105cc0:	eb b9                	jmp    f0105c7b <strtol+0x76>

	if (endptr)
f0105cc2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105cc6:	74 0d                	je     f0105cd5 <strtol+0xd0>
		*endptr = (char *) s;
f0105cc8:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105ccb:	89 0e                	mov    %ecx,(%esi)
f0105ccd:	eb 06                	jmp    f0105cd5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105ccf:	85 db                	test   %ebx,%ebx
f0105cd1:	74 98                	je     f0105c6b <strtol+0x66>
f0105cd3:	eb 9e                	jmp    f0105c73 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105cd5:	89 c2                	mov    %eax,%edx
f0105cd7:	f7 da                	neg    %edx
f0105cd9:	85 ff                	test   %edi,%edi
f0105cdb:	0f 45 c2             	cmovne %edx,%eax
}
f0105cde:	5b                   	pop    %ebx
f0105cdf:	5e                   	pop    %esi
f0105ce0:	5f                   	pop    %edi
f0105ce1:	5d                   	pop    %ebp
f0105ce2:	c3                   	ret    
f0105ce3:	90                   	nop

f0105ce4 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105ce4:	fa                   	cli    

	xorw    %ax, %ax
f0105ce5:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105ce7:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105ce9:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105ceb:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105ced:	0f 01 16             	lgdtl  (%esi)
f0105cf0:	74 70                	je     f0105d62 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105cf2:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105cf5:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105cf9:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105cfc:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105d02:	08 00                	or     %al,(%eax)

f0105d04 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105d04:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105d08:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105d0a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105d0c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105d0e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105d12:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105d14:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105d16:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0105d1b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105d1e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105d21:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105d26:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105d29:	8b 25 84 0e 23 f0    	mov    0xf0230e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105d2f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105d34:	b8 e0 01 10 f0       	mov    $0xf01001e0,%eax
	call    *%eax
f0105d39:	ff d0                	call   *%eax

f0105d3b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105d3b:	eb fe                	jmp    f0105d3b <spin>
f0105d3d:	8d 76 00             	lea    0x0(%esi),%esi

f0105d40 <gdt>:
	...
f0105d48:	ff                   	(bad)  
f0105d49:	ff 00                	incl   (%eax)
f0105d4b:	00 00                	add    %al,(%eax)
f0105d4d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105d54:	00                   	.byte 0x0
f0105d55:	92                   	xchg   %eax,%edx
f0105d56:	cf                   	iret   
	...

f0105d58 <gdtdesc>:
f0105d58:	17                   	pop    %ss
f0105d59:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105d5e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105d5e:	90                   	nop

f0105d5f <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105d5f:	55                   	push   %ebp
f0105d60:	89 e5                	mov    %esp,%ebp
f0105d62:	57                   	push   %edi
f0105d63:	56                   	push   %esi
f0105d64:	53                   	push   %ebx
f0105d65:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d68:	8b 0d 88 0e 23 f0    	mov    0xf0230e88,%ecx
f0105d6e:	89 c3                	mov    %eax,%ebx
f0105d70:	c1 eb 0c             	shr    $0xc,%ebx
f0105d73:	39 cb                	cmp    %ecx,%ebx
f0105d75:	72 12                	jb     f0105d89 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d77:	50                   	push   %eax
f0105d78:	68 c4 67 10 f0       	push   $0xf01067c4
f0105d7d:	6a 57                	push   $0x57
f0105d7f:	68 e1 82 10 f0       	push   $0xf01082e1
f0105d84:	e8 b7 a2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105d89:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105d8f:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d91:	89 c2                	mov    %eax,%edx
f0105d93:	c1 ea 0c             	shr    $0xc,%edx
f0105d96:	39 ca                	cmp    %ecx,%edx
f0105d98:	72 12                	jb     f0105dac <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105d9a:	50                   	push   %eax
f0105d9b:	68 c4 67 10 f0       	push   $0xf01067c4
f0105da0:	6a 57                	push   $0x57
f0105da2:	68 e1 82 10 f0       	push   $0xf01082e1
f0105da7:	e8 94 a2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105dac:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105db2:	eb 2f                	jmp    f0105de3 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105db4:	83 ec 04             	sub    $0x4,%esp
f0105db7:	6a 04                	push   $0x4
f0105db9:	68 f1 82 10 f0       	push   $0xf01082f1
f0105dbe:	53                   	push   %ebx
f0105dbf:	e8 e5 fd ff ff       	call   f0105ba9 <memcmp>
f0105dc4:	83 c4 10             	add    $0x10,%esp
f0105dc7:	85 c0                	test   %eax,%eax
f0105dc9:	75 15                	jne    f0105de0 <mpsearch1+0x81>
f0105dcb:	89 da                	mov    %ebx,%edx
f0105dcd:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105dd0:	0f b6 0a             	movzbl (%edx),%ecx
f0105dd3:	01 c8                	add    %ecx,%eax
f0105dd5:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105dd8:	39 d7                	cmp    %edx,%edi
f0105dda:	75 f4                	jne    f0105dd0 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105ddc:	84 c0                	test   %al,%al
f0105dde:	74 0e                	je     f0105dee <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105de0:	83 c3 10             	add    $0x10,%ebx
f0105de3:	39 f3                	cmp    %esi,%ebx
f0105de5:	72 cd                	jb     f0105db4 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105de7:	b8 00 00 00 00       	mov    $0x0,%eax
f0105dec:	eb 02                	jmp    f0105df0 <mpsearch1+0x91>
f0105dee:	89 d8                	mov    %ebx,%eax
}
f0105df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105df3:	5b                   	pop    %ebx
f0105df4:	5e                   	pop    %esi
f0105df5:	5f                   	pop    %edi
f0105df6:	5d                   	pop    %ebp
f0105df7:	c3                   	ret    

f0105df8 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105df8:	55                   	push   %ebp
f0105df9:	89 e5                	mov    %esp,%ebp
f0105dfb:	57                   	push   %edi
f0105dfc:	56                   	push   %esi
f0105dfd:	53                   	push   %ebx
f0105dfe:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105e01:	c7 05 c0 13 23 f0 20 	movl   $0xf0231020,0xf02313c0
f0105e08:	10 23 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105e0b:	83 3d 88 0e 23 f0 00 	cmpl   $0x0,0xf0230e88
f0105e12:	75 16                	jne    f0105e2a <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e14:	68 00 04 00 00       	push   $0x400
f0105e19:	68 c4 67 10 f0       	push   $0xf01067c4
f0105e1e:	6a 6f                	push   $0x6f
f0105e20:	68 e1 82 10 f0       	push   $0xf01082e1
f0105e25:	e8 16 a2 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105e2a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105e31:	85 c0                	test   %eax,%eax
f0105e33:	74 16                	je     f0105e4b <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105e35:	c1 e0 04             	shl    $0x4,%eax
f0105e38:	ba 00 04 00 00       	mov    $0x400,%edx
f0105e3d:	e8 1d ff ff ff       	call   f0105d5f <mpsearch1>
f0105e42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105e45:	85 c0                	test   %eax,%eax
f0105e47:	75 3c                	jne    f0105e85 <mp_init+0x8d>
f0105e49:	eb 20                	jmp    f0105e6b <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105e4b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105e52:	c1 e0 0a             	shl    $0xa,%eax
f0105e55:	2d 00 04 00 00       	sub    $0x400,%eax
f0105e5a:	ba 00 04 00 00       	mov    $0x400,%edx
f0105e5f:	e8 fb fe ff ff       	call   f0105d5f <mpsearch1>
f0105e64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105e67:	85 c0                	test   %eax,%eax
f0105e69:	75 1a                	jne    f0105e85 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105e6b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105e70:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105e75:	e8 e5 fe ff ff       	call   f0105d5f <mpsearch1>
f0105e7a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105e7d:	85 c0                	test   %eax,%eax
f0105e7f:	0f 84 5d 02 00 00    	je     f01060e2 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105e85:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e88:	8b 70 04             	mov    0x4(%eax),%esi
f0105e8b:	85 f6                	test   %esi,%esi
f0105e8d:	74 06                	je     f0105e95 <mp_init+0x9d>
f0105e8f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105e93:	74 15                	je     f0105eaa <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105e95:	83 ec 0c             	sub    $0xc,%esp
f0105e98:	68 54 81 10 f0       	push   $0xf0108154
f0105e9d:	e8 b3 d7 ff ff       	call   f0103655 <cprintf>
f0105ea2:	83 c4 10             	add    $0x10,%esp
f0105ea5:	e9 38 02 00 00       	jmp    f01060e2 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105eaa:	89 f0                	mov    %esi,%eax
f0105eac:	c1 e8 0c             	shr    $0xc,%eax
f0105eaf:	3b 05 88 0e 23 f0    	cmp    0xf0230e88,%eax
f0105eb5:	72 15                	jb     f0105ecc <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105eb7:	56                   	push   %esi
f0105eb8:	68 c4 67 10 f0       	push   $0xf01067c4
f0105ebd:	68 90 00 00 00       	push   $0x90
f0105ec2:	68 e1 82 10 f0       	push   $0xf01082e1
f0105ec7:	e8 74 a1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105ecc:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105ed2:	83 ec 04             	sub    $0x4,%esp
f0105ed5:	6a 04                	push   $0x4
f0105ed7:	68 f6 82 10 f0       	push   $0xf01082f6
f0105edc:	53                   	push   %ebx
f0105edd:	e8 c7 fc ff ff       	call   f0105ba9 <memcmp>
f0105ee2:	83 c4 10             	add    $0x10,%esp
f0105ee5:	85 c0                	test   %eax,%eax
f0105ee7:	74 15                	je     f0105efe <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105ee9:	83 ec 0c             	sub    $0xc,%esp
f0105eec:	68 84 81 10 f0       	push   $0xf0108184
f0105ef1:	e8 5f d7 ff ff       	call   f0103655 <cprintf>
f0105ef6:	83 c4 10             	add    $0x10,%esp
f0105ef9:	e9 e4 01 00 00       	jmp    f01060e2 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105efe:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105f02:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105f06:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105f09:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105f0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f13:	eb 0d                	jmp    f0105f22 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105f15:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105f1c:	f0 
f0105f1d:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105f1f:	83 c0 01             	add    $0x1,%eax
f0105f22:	39 c7                	cmp    %eax,%edi
f0105f24:	75 ef                	jne    f0105f15 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105f26:	84 d2                	test   %dl,%dl
f0105f28:	74 15                	je     f0105f3f <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105f2a:	83 ec 0c             	sub    $0xc,%esp
f0105f2d:	68 b8 81 10 f0       	push   $0xf01081b8
f0105f32:	e8 1e d7 ff ff       	call   f0103655 <cprintf>
f0105f37:	83 c4 10             	add    $0x10,%esp
f0105f3a:	e9 a3 01 00 00       	jmp    f01060e2 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105f3f:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f0105f43:	3c 01                	cmp    $0x1,%al
f0105f45:	74 1d                	je     f0105f64 <mp_init+0x16c>
f0105f47:	3c 04                	cmp    $0x4,%al
f0105f49:	74 19                	je     f0105f64 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105f4b:	83 ec 08             	sub    $0x8,%esp
f0105f4e:	0f b6 c0             	movzbl %al,%eax
f0105f51:	50                   	push   %eax
f0105f52:	68 dc 81 10 f0       	push   $0xf01081dc
f0105f57:	e8 f9 d6 ff ff       	call   f0103655 <cprintf>
f0105f5c:	83 c4 10             	add    $0x10,%esp
f0105f5f:	e9 7e 01 00 00       	jmp    f01060e2 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105f64:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f0105f68:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105f6c:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105f71:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105f76:	01 ce                	add    %ecx,%esi
f0105f78:	eb 0d                	jmp    f0105f87 <mp_init+0x18f>
f0105f7a:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105f81:	f0 
f0105f82:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105f84:	83 c0 01             	add    $0x1,%eax
f0105f87:	39 c7                	cmp    %eax,%edi
f0105f89:	75 ef                	jne    f0105f7a <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105f8b:	89 d0                	mov    %edx,%eax
f0105f8d:	02 43 2a             	add    0x2a(%ebx),%al
f0105f90:	74 15                	je     f0105fa7 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105f92:	83 ec 0c             	sub    $0xc,%esp
f0105f95:	68 fc 81 10 f0       	push   $0xf01081fc
f0105f9a:	e8 b6 d6 ff ff       	call   f0103655 <cprintf>
f0105f9f:	83 c4 10             	add    $0x10,%esp
f0105fa2:	e9 3b 01 00 00       	jmp    f01060e2 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105fa7:	85 db                	test   %ebx,%ebx
f0105fa9:	0f 84 33 01 00 00    	je     f01060e2 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105faf:	c7 05 00 10 23 f0 01 	movl   $0x1,0xf0231000
f0105fb6:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105fb9:	8b 43 24             	mov    0x24(%ebx),%eax
f0105fbc:	a3 00 20 27 f0       	mov    %eax,0xf0272000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105fc1:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105fc4:	be 00 00 00 00       	mov    $0x0,%esi
f0105fc9:	e9 85 00 00 00       	jmp    f0106053 <mp_init+0x25b>
		switch (*p) {
f0105fce:	0f b6 07             	movzbl (%edi),%eax
f0105fd1:	84 c0                	test   %al,%al
f0105fd3:	74 06                	je     f0105fdb <mp_init+0x1e3>
f0105fd5:	3c 04                	cmp    $0x4,%al
f0105fd7:	77 55                	ja     f010602e <mp_init+0x236>
f0105fd9:	eb 4e                	jmp    f0106029 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105fdb:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105fdf:	74 11                	je     f0105ff2 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105fe1:	6b 05 c4 13 23 f0 74 	imul   $0x74,0xf02313c4,%eax
f0105fe8:	05 20 10 23 f0       	add    $0xf0231020,%eax
f0105fed:	a3 c0 13 23 f0       	mov    %eax,0xf02313c0
			if (ncpu < NCPU) {
f0105ff2:	a1 c4 13 23 f0       	mov    0xf02313c4,%eax
f0105ff7:	83 f8 07             	cmp    $0x7,%eax
f0105ffa:	7f 13                	jg     f010600f <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105ffc:	6b d0 74             	imul   $0x74,%eax,%edx
f0105fff:	88 82 20 10 23 f0    	mov    %al,-0xfdcefe0(%edx)
				ncpu++;
f0106005:	83 c0 01             	add    $0x1,%eax
f0106008:	a3 c4 13 23 f0       	mov    %eax,0xf02313c4
f010600d:	eb 15                	jmp    f0106024 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010600f:	83 ec 08             	sub    $0x8,%esp
f0106012:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106016:	50                   	push   %eax
f0106017:	68 2c 82 10 f0       	push   $0xf010822c
f010601c:	e8 34 d6 ff ff       	call   f0103655 <cprintf>
f0106021:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106024:	83 c7 14             	add    $0x14,%edi
			continue;
f0106027:	eb 27                	jmp    f0106050 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106029:	83 c7 08             	add    $0x8,%edi
			continue;
f010602c:	eb 22                	jmp    f0106050 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f010602e:	83 ec 08             	sub    $0x8,%esp
f0106031:	0f b6 c0             	movzbl %al,%eax
f0106034:	50                   	push   %eax
f0106035:	68 54 82 10 f0       	push   $0xf0108254
f010603a:	e8 16 d6 ff ff       	call   f0103655 <cprintf>
			ismp = 0;
f010603f:	c7 05 00 10 23 f0 00 	movl   $0x0,0xf0231000
f0106046:	00 00 00 
			i = conf->entry;
f0106049:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f010604d:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106050:	83 c6 01             	add    $0x1,%esi
f0106053:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106057:	39 c6                	cmp    %eax,%esi
f0106059:	0f 82 6f ff ff ff    	jb     f0105fce <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010605f:	a1 c0 13 23 f0       	mov    0xf02313c0,%eax
f0106064:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010606b:	83 3d 00 10 23 f0 00 	cmpl   $0x0,0xf0231000
f0106072:	75 26                	jne    f010609a <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106074:	c7 05 c4 13 23 f0 01 	movl   $0x1,0xf02313c4
f010607b:	00 00 00 
		lapicaddr = 0;
f010607e:	c7 05 00 20 27 f0 00 	movl   $0x0,0xf0272000
f0106085:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106088:	83 ec 0c             	sub    $0xc,%esp
f010608b:	68 74 82 10 f0       	push   $0xf0108274
f0106090:	e8 c0 d5 ff ff       	call   f0103655 <cprintf>
		return;
f0106095:	83 c4 10             	add    $0x10,%esp
f0106098:	eb 48                	jmp    f01060e2 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010609a:	83 ec 04             	sub    $0x4,%esp
f010609d:	ff 35 c4 13 23 f0    	pushl  0xf02313c4
f01060a3:	0f b6 00             	movzbl (%eax),%eax
f01060a6:	50                   	push   %eax
f01060a7:	68 fb 82 10 f0       	push   $0xf01082fb
f01060ac:	e8 a4 d5 ff ff       	call   f0103655 <cprintf>

	if (mp->imcrp) {
f01060b1:	83 c4 10             	add    $0x10,%esp
f01060b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01060b7:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01060bb:	74 25                	je     f01060e2 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01060bd:	83 ec 0c             	sub    $0xc,%esp
f01060c0:	68 a0 82 10 f0       	push   $0xf01082a0
f01060c5:	e8 8b d5 ff ff       	call   f0103655 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01060ca:	ba 22 00 00 00       	mov    $0x22,%edx
f01060cf:	b8 70 00 00 00       	mov    $0x70,%eax
f01060d4:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01060d5:	ba 23 00 00 00       	mov    $0x23,%edx
f01060da:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01060db:	83 c8 01             	or     $0x1,%eax
f01060de:	ee                   	out    %al,(%dx)
f01060df:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f01060e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01060e5:	5b                   	pop    %ebx
f01060e6:	5e                   	pop    %esi
f01060e7:	5f                   	pop    %edi
f01060e8:	5d                   	pop    %ebp
f01060e9:	c3                   	ret    

f01060ea <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f01060ea:	55                   	push   %ebp
f01060eb:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f01060ed:	8b 0d 04 20 27 f0    	mov    0xf0272004,%ecx
f01060f3:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01060f6:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f01060f8:	a1 04 20 27 f0       	mov    0xf0272004,%eax
f01060fd:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106100:	5d                   	pop    %ebp
f0106101:	c3                   	ret    

f0106102 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106102:	55                   	push   %ebp
f0106103:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106105:	a1 04 20 27 f0       	mov    0xf0272004,%eax
f010610a:	85 c0                	test   %eax,%eax
f010610c:	74 08                	je     f0106116 <cpunum+0x14>
		return lapic[ID] >> 24;
f010610e:	8b 40 20             	mov    0x20(%eax),%eax
f0106111:	c1 e8 18             	shr    $0x18,%eax
f0106114:	eb 05                	jmp    f010611b <cpunum+0x19>
	return 0;
f0106116:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010611b:	5d                   	pop    %ebp
f010611c:	c3                   	ret    

f010611d <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f010611d:	a1 00 20 27 f0       	mov    0xf0272000,%eax
f0106122:	85 c0                	test   %eax,%eax
f0106124:	0f 84 21 01 00 00    	je     f010624b <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010612a:	55                   	push   %ebp
f010612b:	89 e5                	mov    %esp,%ebp
f010612d:	83 ec 10             	sub    $0x10,%esp
	if (!lapicaddr)
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106130:	68 00 10 00 00       	push   $0x1000
f0106135:	50                   	push   %eax
f0106136:	e8 40 b1 ff ff       	call   f010127b <mmio_map_region>
f010613b:	a3 04 20 27 f0       	mov    %eax,0xf0272004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106140:	ba 27 01 00 00       	mov    $0x127,%edx
f0106145:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010614a:	e8 9b ff ff ff       	call   f01060ea <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010614f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106154:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106159:	e8 8c ff ff ff       	call   f01060ea <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010615e:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106163:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106168:	e8 7d ff ff ff       	call   f01060ea <lapicw>
	lapicw(TICR, 10000000); 
f010616d:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106172:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106177:	e8 6e ff ff ff       	call   f01060ea <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010617c:	e8 81 ff ff ff       	call   f0106102 <cpunum>
f0106181:	6b c0 74             	imul   $0x74,%eax,%eax
f0106184:	05 20 10 23 f0       	add    $0xf0231020,%eax
f0106189:	83 c4 10             	add    $0x10,%esp
f010618c:	39 05 c0 13 23 f0    	cmp    %eax,0xf02313c0
f0106192:	74 0f                	je     f01061a3 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0106194:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106199:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010619e:	e8 47 ff ff ff       	call   f01060ea <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01061a3:	ba 00 00 01 00       	mov    $0x10000,%edx
f01061a8:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01061ad:	e8 38 ff ff ff       	call   f01060ea <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01061b2:	a1 04 20 27 f0       	mov    0xf0272004,%eax
f01061b7:	8b 40 30             	mov    0x30(%eax),%eax
f01061ba:	c1 e8 10             	shr    $0x10,%eax
f01061bd:	3c 03                	cmp    $0x3,%al
f01061bf:	76 0f                	jbe    f01061d0 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f01061c1:	ba 00 00 01 00       	mov    $0x10000,%edx
f01061c6:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01061cb:	e8 1a ff ff ff       	call   f01060ea <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01061d0:	ba 33 00 00 00       	mov    $0x33,%edx
f01061d5:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01061da:	e8 0b ff ff ff       	call   f01060ea <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01061df:	ba 00 00 00 00       	mov    $0x0,%edx
f01061e4:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01061e9:	e8 fc fe ff ff       	call   f01060ea <lapicw>
	lapicw(ESR, 0);
f01061ee:	ba 00 00 00 00       	mov    $0x0,%edx
f01061f3:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01061f8:	e8 ed fe ff ff       	call   f01060ea <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01061fd:	ba 00 00 00 00       	mov    $0x0,%edx
f0106202:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106207:	e8 de fe ff ff       	call   f01060ea <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010620c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106211:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106216:	e8 cf fe ff ff       	call   f01060ea <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010621b:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106220:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106225:	e8 c0 fe ff ff       	call   f01060ea <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010622a:	8b 15 04 20 27 f0    	mov    0xf0272004,%edx
f0106230:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106236:	f6 c4 10             	test   $0x10,%ah
f0106239:	75 f5                	jne    f0106230 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010623b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106240:	b8 20 00 00 00       	mov    $0x20,%eax
f0106245:	e8 a0 fe ff ff       	call   f01060ea <lapicw>
}
f010624a:	c9                   	leave  
f010624b:	f3 c3                	repz ret 

f010624d <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f010624d:	83 3d 04 20 27 f0 00 	cmpl   $0x0,0xf0272004
f0106254:	74 13                	je     f0106269 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106256:	55                   	push   %ebp
f0106257:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f0106259:	ba 00 00 00 00       	mov    $0x0,%edx
f010625e:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106263:	e8 82 fe ff ff       	call   f01060ea <lapicw>
}
f0106268:	5d                   	pop    %ebp
f0106269:	f3 c3                	repz ret 

f010626b <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010626b:	55                   	push   %ebp
f010626c:	89 e5                	mov    %esp,%ebp
f010626e:	56                   	push   %esi
f010626f:	53                   	push   %ebx
f0106270:	8b 75 08             	mov    0x8(%ebp),%esi
f0106273:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106276:	ba 70 00 00 00       	mov    $0x70,%edx
f010627b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0106280:	ee                   	out    %al,(%dx)
f0106281:	ba 71 00 00 00       	mov    $0x71,%edx
f0106286:	b8 0a 00 00 00       	mov    $0xa,%eax
f010628b:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010628c:	83 3d 88 0e 23 f0 00 	cmpl   $0x0,0xf0230e88
f0106293:	75 19                	jne    f01062ae <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106295:	68 67 04 00 00       	push   $0x467
f010629a:	68 c4 67 10 f0       	push   $0xf01067c4
f010629f:	68 98 00 00 00       	push   $0x98
f01062a4:	68 18 83 10 f0       	push   $0xf0108318
f01062a9:	e8 92 9d ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01062ae:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01062b5:	00 00 
	wrv[1] = addr >> 4;
f01062b7:	89 d8                	mov    %ebx,%eax
f01062b9:	c1 e8 04             	shr    $0x4,%eax
f01062bc:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01062c2:	c1 e6 18             	shl    $0x18,%esi
f01062c5:	89 f2                	mov    %esi,%edx
f01062c7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01062cc:	e8 19 fe ff ff       	call   f01060ea <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01062d1:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01062d6:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062db:	e8 0a fe ff ff       	call   f01060ea <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f01062e0:	ba 00 85 00 00       	mov    $0x8500,%edx
f01062e5:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01062ea:	e8 fb fd ff ff       	call   f01060ea <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01062ef:	c1 eb 0c             	shr    $0xc,%ebx
f01062f2:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f01062f5:	89 f2                	mov    %esi,%edx
f01062f7:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01062fc:	e8 e9 fd ff ff       	call   f01060ea <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106301:	89 da                	mov    %ebx,%edx
f0106303:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106308:	e8 dd fd ff ff       	call   f01060ea <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010630d:	89 f2                	mov    %esi,%edx
f010630f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106314:	e8 d1 fd ff ff       	call   f01060ea <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106319:	89 da                	mov    %ebx,%edx
f010631b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106320:	e8 c5 fd ff ff       	call   f01060ea <lapicw>
		microdelay(200);
	}
}
f0106325:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106328:	5b                   	pop    %ebx
f0106329:	5e                   	pop    %esi
f010632a:	5d                   	pop    %ebp
f010632b:	c3                   	ret    

f010632c <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010632c:	55                   	push   %ebp
f010632d:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010632f:	8b 55 08             	mov    0x8(%ebp),%edx
f0106332:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106338:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010633d:	e8 a8 fd ff ff       	call   f01060ea <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0106342:	8b 15 04 20 27 f0    	mov    0xf0272004,%edx
f0106348:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010634e:	f6 c4 10             	test   $0x10,%ah
f0106351:	75 f5                	jne    f0106348 <lapic_ipi+0x1c>
		;
}
f0106353:	5d                   	pop    %ebp
f0106354:	c3                   	ret    

f0106355 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0106355:	55                   	push   %ebp
f0106356:	89 e5                	mov    %esp,%ebp
f0106358:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f010635b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106361:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106364:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106367:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010636e:	5d                   	pop    %ebp
f010636f:	c3                   	ret    

f0106370 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106370:	55                   	push   %ebp
f0106371:	89 e5                	mov    %esp,%ebp
f0106373:	56                   	push   %esi
f0106374:	53                   	push   %ebx
f0106375:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106378:	83 3b 00             	cmpl   $0x0,(%ebx)
f010637b:	74 14                	je     f0106391 <spin_lock+0x21>
f010637d:	8b 73 08             	mov    0x8(%ebx),%esi
f0106380:	e8 7d fd ff ff       	call   f0106102 <cpunum>
f0106385:	6b c0 74             	imul   $0x74,%eax,%eax
f0106388:	05 20 10 23 f0       	add    $0xf0231020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010638d:	39 c6                	cmp    %eax,%esi
f010638f:	74 07                	je     f0106398 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106391:	ba 01 00 00 00       	mov    $0x1,%edx
f0106396:	eb 20                	jmp    f01063b8 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106398:	8b 5b 04             	mov    0x4(%ebx),%ebx
f010639b:	e8 62 fd ff ff       	call   f0106102 <cpunum>
f01063a0:	83 ec 0c             	sub    $0xc,%esp
f01063a3:	53                   	push   %ebx
f01063a4:	50                   	push   %eax
f01063a5:	68 28 83 10 f0       	push   $0xf0108328
f01063aa:	6a 41                	push   $0x41
f01063ac:	68 8c 83 10 f0       	push   $0xf010838c
f01063b1:	e8 8a 9c ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f01063b6:	f3 90                	pause  
f01063b8:	89 d0                	mov    %edx,%eax
f01063ba:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01063bd:	85 c0                	test   %eax,%eax
f01063bf:	75 f5                	jne    f01063b6 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f01063c1:	e8 3c fd ff ff       	call   f0106102 <cpunum>
f01063c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01063c9:	05 20 10 23 f0       	add    $0xf0231020,%eax
f01063ce:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f01063d1:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01063d4:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01063d6:	b8 00 00 00 00       	mov    $0x0,%eax
f01063db:	eb 0b                	jmp    f01063e8 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01063dd:	8b 4a 04             	mov    0x4(%edx),%ecx
f01063e0:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01063e3:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01063e5:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f01063e8:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f01063ee:	76 11                	jbe    f0106401 <spin_lock+0x91>
f01063f0:	83 f8 09             	cmp    $0x9,%eax
f01063f3:	7e e8                	jle    f01063dd <spin_lock+0x6d>
f01063f5:	eb 0a                	jmp    f0106401 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01063f7:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01063fe:	83 c0 01             	add    $0x1,%eax
f0106401:	83 f8 09             	cmp    $0x9,%eax
f0106404:	7e f1                	jle    f01063f7 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106406:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106409:	5b                   	pop    %ebx
f010640a:	5e                   	pop    %esi
f010640b:	5d                   	pop    %ebp
f010640c:	c3                   	ret    

f010640d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010640d:	55                   	push   %ebp
f010640e:	89 e5                	mov    %esp,%ebp
f0106410:	57                   	push   %edi
f0106411:	56                   	push   %esi
f0106412:	53                   	push   %ebx
f0106413:	83 ec 4c             	sub    $0x4c,%esp
f0106416:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0106419:	83 3e 00             	cmpl   $0x0,(%esi)
f010641c:	74 18                	je     f0106436 <spin_unlock+0x29>
f010641e:	8b 5e 08             	mov    0x8(%esi),%ebx
f0106421:	e8 dc fc ff ff       	call   f0106102 <cpunum>
f0106426:	6b c0 74             	imul   $0x74,%eax,%eax
f0106429:	05 20 10 23 f0       	add    $0xf0231020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010642e:	39 c3                	cmp    %eax,%ebx
f0106430:	0f 84 a5 00 00 00    	je     f01064db <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106436:	83 ec 04             	sub    $0x4,%esp
f0106439:	6a 28                	push   $0x28
f010643b:	8d 46 0c             	lea    0xc(%esi),%eax
f010643e:	50                   	push   %eax
f010643f:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0106442:	53                   	push   %ebx
f0106443:	e8 e6 f6 ff ff       	call   f0105b2e <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0106448:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f010644b:	0f b6 38             	movzbl (%eax),%edi
f010644e:	8b 76 04             	mov    0x4(%esi),%esi
f0106451:	e8 ac fc ff ff       	call   f0106102 <cpunum>
f0106456:	57                   	push   %edi
f0106457:	56                   	push   %esi
f0106458:	50                   	push   %eax
f0106459:	68 54 83 10 f0       	push   $0xf0108354
f010645e:	e8 f2 d1 ff ff       	call   f0103655 <cprintf>
f0106463:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106466:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0106469:	eb 54                	jmp    f01064bf <spin_unlock+0xb2>
f010646b:	83 ec 08             	sub    $0x8,%esp
f010646e:	57                   	push   %edi
f010646f:	50                   	push   %eax
f0106470:	e8 8c eb ff ff       	call   f0105001 <debuginfo_eip>
f0106475:	83 c4 10             	add    $0x10,%esp
f0106478:	85 c0                	test   %eax,%eax
f010647a:	78 27                	js     f01064a3 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010647c:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010647e:	83 ec 04             	sub    $0x4,%esp
f0106481:	89 c2                	mov    %eax,%edx
f0106483:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0106486:	52                   	push   %edx
f0106487:	ff 75 b0             	pushl  -0x50(%ebp)
f010648a:	ff 75 b4             	pushl  -0x4c(%ebp)
f010648d:	ff 75 ac             	pushl  -0x54(%ebp)
f0106490:	ff 75 a8             	pushl  -0x58(%ebp)
f0106493:	50                   	push   %eax
f0106494:	68 9c 83 10 f0       	push   $0xf010839c
f0106499:	e8 b7 d1 ff ff       	call   f0103655 <cprintf>
f010649e:	83 c4 20             	add    $0x20,%esp
f01064a1:	eb 12                	jmp    f01064b5 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01064a3:	83 ec 08             	sub    $0x8,%esp
f01064a6:	ff 36                	pushl  (%esi)
f01064a8:	68 b3 83 10 f0       	push   $0xf01083b3
f01064ad:	e8 a3 d1 ff ff       	call   f0103655 <cprintf>
f01064b2:	83 c4 10             	add    $0x10,%esp
f01064b5:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01064b8:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01064bb:	39 c3                	cmp    %eax,%ebx
f01064bd:	74 08                	je     f01064c7 <spin_unlock+0xba>
f01064bf:	89 de                	mov    %ebx,%esi
f01064c1:	8b 03                	mov    (%ebx),%eax
f01064c3:	85 c0                	test   %eax,%eax
f01064c5:	75 a4                	jne    f010646b <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01064c7:	83 ec 04             	sub    $0x4,%esp
f01064ca:	68 bb 83 10 f0       	push   $0xf01083bb
f01064cf:	6a 67                	push   $0x67
f01064d1:	68 8c 83 10 f0       	push   $0xf010838c
f01064d6:	e8 65 9b ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01064db:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01064e2:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01064e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01064ee:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01064f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01064f4:	5b                   	pop    %ebx
f01064f5:	5e                   	pop    %esi
f01064f6:	5f                   	pop    %edi
f01064f7:	5d                   	pop    %ebp
f01064f8:	c3                   	ret    
f01064f9:	66 90                	xchg   %ax,%ax
f01064fb:	66 90                	xchg   %ax,%ax
f01064fd:	66 90                	xchg   %ax,%ax
f01064ff:	90                   	nop

f0106500 <__udivdi3>:
f0106500:	55                   	push   %ebp
f0106501:	57                   	push   %edi
f0106502:	56                   	push   %esi
f0106503:	53                   	push   %ebx
f0106504:	83 ec 1c             	sub    $0x1c,%esp
f0106507:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010650b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010650f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0106513:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106517:	85 f6                	test   %esi,%esi
f0106519:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010651d:	89 ca                	mov    %ecx,%edx
f010651f:	89 f8                	mov    %edi,%eax
f0106521:	75 3d                	jne    f0106560 <__udivdi3+0x60>
f0106523:	39 cf                	cmp    %ecx,%edi
f0106525:	0f 87 c5 00 00 00    	ja     f01065f0 <__udivdi3+0xf0>
f010652b:	85 ff                	test   %edi,%edi
f010652d:	89 fd                	mov    %edi,%ebp
f010652f:	75 0b                	jne    f010653c <__udivdi3+0x3c>
f0106531:	b8 01 00 00 00       	mov    $0x1,%eax
f0106536:	31 d2                	xor    %edx,%edx
f0106538:	f7 f7                	div    %edi
f010653a:	89 c5                	mov    %eax,%ebp
f010653c:	89 c8                	mov    %ecx,%eax
f010653e:	31 d2                	xor    %edx,%edx
f0106540:	f7 f5                	div    %ebp
f0106542:	89 c1                	mov    %eax,%ecx
f0106544:	89 d8                	mov    %ebx,%eax
f0106546:	89 cf                	mov    %ecx,%edi
f0106548:	f7 f5                	div    %ebp
f010654a:	89 c3                	mov    %eax,%ebx
f010654c:	89 d8                	mov    %ebx,%eax
f010654e:	89 fa                	mov    %edi,%edx
f0106550:	83 c4 1c             	add    $0x1c,%esp
f0106553:	5b                   	pop    %ebx
f0106554:	5e                   	pop    %esi
f0106555:	5f                   	pop    %edi
f0106556:	5d                   	pop    %ebp
f0106557:	c3                   	ret    
f0106558:	90                   	nop
f0106559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106560:	39 ce                	cmp    %ecx,%esi
f0106562:	77 74                	ja     f01065d8 <__udivdi3+0xd8>
f0106564:	0f bd fe             	bsr    %esi,%edi
f0106567:	83 f7 1f             	xor    $0x1f,%edi
f010656a:	0f 84 98 00 00 00    	je     f0106608 <__udivdi3+0x108>
f0106570:	bb 20 00 00 00       	mov    $0x20,%ebx
f0106575:	89 f9                	mov    %edi,%ecx
f0106577:	89 c5                	mov    %eax,%ebp
f0106579:	29 fb                	sub    %edi,%ebx
f010657b:	d3 e6                	shl    %cl,%esi
f010657d:	89 d9                	mov    %ebx,%ecx
f010657f:	d3 ed                	shr    %cl,%ebp
f0106581:	89 f9                	mov    %edi,%ecx
f0106583:	d3 e0                	shl    %cl,%eax
f0106585:	09 ee                	or     %ebp,%esi
f0106587:	89 d9                	mov    %ebx,%ecx
f0106589:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010658d:	89 d5                	mov    %edx,%ebp
f010658f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0106593:	d3 ed                	shr    %cl,%ebp
f0106595:	89 f9                	mov    %edi,%ecx
f0106597:	d3 e2                	shl    %cl,%edx
f0106599:	89 d9                	mov    %ebx,%ecx
f010659b:	d3 e8                	shr    %cl,%eax
f010659d:	09 c2                	or     %eax,%edx
f010659f:	89 d0                	mov    %edx,%eax
f01065a1:	89 ea                	mov    %ebp,%edx
f01065a3:	f7 f6                	div    %esi
f01065a5:	89 d5                	mov    %edx,%ebp
f01065a7:	89 c3                	mov    %eax,%ebx
f01065a9:	f7 64 24 0c          	mull   0xc(%esp)
f01065ad:	39 d5                	cmp    %edx,%ebp
f01065af:	72 10                	jb     f01065c1 <__udivdi3+0xc1>
f01065b1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01065b5:	89 f9                	mov    %edi,%ecx
f01065b7:	d3 e6                	shl    %cl,%esi
f01065b9:	39 c6                	cmp    %eax,%esi
f01065bb:	73 07                	jae    f01065c4 <__udivdi3+0xc4>
f01065bd:	39 d5                	cmp    %edx,%ebp
f01065bf:	75 03                	jne    f01065c4 <__udivdi3+0xc4>
f01065c1:	83 eb 01             	sub    $0x1,%ebx
f01065c4:	31 ff                	xor    %edi,%edi
f01065c6:	89 d8                	mov    %ebx,%eax
f01065c8:	89 fa                	mov    %edi,%edx
f01065ca:	83 c4 1c             	add    $0x1c,%esp
f01065cd:	5b                   	pop    %ebx
f01065ce:	5e                   	pop    %esi
f01065cf:	5f                   	pop    %edi
f01065d0:	5d                   	pop    %ebp
f01065d1:	c3                   	ret    
f01065d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01065d8:	31 ff                	xor    %edi,%edi
f01065da:	31 db                	xor    %ebx,%ebx
f01065dc:	89 d8                	mov    %ebx,%eax
f01065de:	89 fa                	mov    %edi,%edx
f01065e0:	83 c4 1c             	add    $0x1c,%esp
f01065e3:	5b                   	pop    %ebx
f01065e4:	5e                   	pop    %esi
f01065e5:	5f                   	pop    %edi
f01065e6:	5d                   	pop    %ebp
f01065e7:	c3                   	ret    
f01065e8:	90                   	nop
f01065e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01065f0:	89 d8                	mov    %ebx,%eax
f01065f2:	f7 f7                	div    %edi
f01065f4:	31 ff                	xor    %edi,%edi
f01065f6:	89 c3                	mov    %eax,%ebx
f01065f8:	89 d8                	mov    %ebx,%eax
f01065fa:	89 fa                	mov    %edi,%edx
f01065fc:	83 c4 1c             	add    $0x1c,%esp
f01065ff:	5b                   	pop    %ebx
f0106600:	5e                   	pop    %esi
f0106601:	5f                   	pop    %edi
f0106602:	5d                   	pop    %ebp
f0106603:	c3                   	ret    
f0106604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106608:	39 ce                	cmp    %ecx,%esi
f010660a:	72 0c                	jb     f0106618 <__udivdi3+0x118>
f010660c:	31 db                	xor    %ebx,%ebx
f010660e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0106612:	0f 87 34 ff ff ff    	ja     f010654c <__udivdi3+0x4c>
f0106618:	bb 01 00 00 00       	mov    $0x1,%ebx
f010661d:	e9 2a ff ff ff       	jmp    f010654c <__udivdi3+0x4c>
f0106622:	66 90                	xchg   %ax,%ax
f0106624:	66 90                	xchg   %ax,%ax
f0106626:	66 90                	xchg   %ax,%ax
f0106628:	66 90                	xchg   %ax,%ax
f010662a:	66 90                	xchg   %ax,%ax
f010662c:	66 90                	xchg   %ax,%ax
f010662e:	66 90                	xchg   %ax,%ax

f0106630 <__umoddi3>:
f0106630:	55                   	push   %ebp
f0106631:	57                   	push   %edi
f0106632:	56                   	push   %esi
f0106633:	53                   	push   %ebx
f0106634:	83 ec 1c             	sub    $0x1c,%esp
f0106637:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010663b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010663f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106643:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106647:	85 d2                	test   %edx,%edx
f0106649:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010664d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106651:	89 f3                	mov    %esi,%ebx
f0106653:	89 3c 24             	mov    %edi,(%esp)
f0106656:	89 74 24 04          	mov    %esi,0x4(%esp)
f010665a:	75 1c                	jne    f0106678 <__umoddi3+0x48>
f010665c:	39 f7                	cmp    %esi,%edi
f010665e:	76 50                	jbe    f01066b0 <__umoddi3+0x80>
f0106660:	89 c8                	mov    %ecx,%eax
f0106662:	89 f2                	mov    %esi,%edx
f0106664:	f7 f7                	div    %edi
f0106666:	89 d0                	mov    %edx,%eax
f0106668:	31 d2                	xor    %edx,%edx
f010666a:	83 c4 1c             	add    $0x1c,%esp
f010666d:	5b                   	pop    %ebx
f010666e:	5e                   	pop    %esi
f010666f:	5f                   	pop    %edi
f0106670:	5d                   	pop    %ebp
f0106671:	c3                   	ret    
f0106672:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106678:	39 f2                	cmp    %esi,%edx
f010667a:	89 d0                	mov    %edx,%eax
f010667c:	77 52                	ja     f01066d0 <__umoddi3+0xa0>
f010667e:	0f bd ea             	bsr    %edx,%ebp
f0106681:	83 f5 1f             	xor    $0x1f,%ebp
f0106684:	75 5a                	jne    f01066e0 <__umoddi3+0xb0>
f0106686:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010668a:	0f 82 e0 00 00 00    	jb     f0106770 <__umoddi3+0x140>
f0106690:	39 0c 24             	cmp    %ecx,(%esp)
f0106693:	0f 86 d7 00 00 00    	jbe    f0106770 <__umoddi3+0x140>
f0106699:	8b 44 24 08          	mov    0x8(%esp),%eax
f010669d:	8b 54 24 04          	mov    0x4(%esp),%edx
f01066a1:	83 c4 1c             	add    $0x1c,%esp
f01066a4:	5b                   	pop    %ebx
f01066a5:	5e                   	pop    %esi
f01066a6:	5f                   	pop    %edi
f01066a7:	5d                   	pop    %ebp
f01066a8:	c3                   	ret    
f01066a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01066b0:	85 ff                	test   %edi,%edi
f01066b2:	89 fd                	mov    %edi,%ebp
f01066b4:	75 0b                	jne    f01066c1 <__umoddi3+0x91>
f01066b6:	b8 01 00 00 00       	mov    $0x1,%eax
f01066bb:	31 d2                	xor    %edx,%edx
f01066bd:	f7 f7                	div    %edi
f01066bf:	89 c5                	mov    %eax,%ebp
f01066c1:	89 f0                	mov    %esi,%eax
f01066c3:	31 d2                	xor    %edx,%edx
f01066c5:	f7 f5                	div    %ebp
f01066c7:	89 c8                	mov    %ecx,%eax
f01066c9:	f7 f5                	div    %ebp
f01066cb:	89 d0                	mov    %edx,%eax
f01066cd:	eb 99                	jmp    f0106668 <__umoddi3+0x38>
f01066cf:	90                   	nop
f01066d0:	89 c8                	mov    %ecx,%eax
f01066d2:	89 f2                	mov    %esi,%edx
f01066d4:	83 c4 1c             	add    $0x1c,%esp
f01066d7:	5b                   	pop    %ebx
f01066d8:	5e                   	pop    %esi
f01066d9:	5f                   	pop    %edi
f01066da:	5d                   	pop    %ebp
f01066db:	c3                   	ret    
f01066dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01066e0:	8b 34 24             	mov    (%esp),%esi
f01066e3:	bf 20 00 00 00       	mov    $0x20,%edi
f01066e8:	89 e9                	mov    %ebp,%ecx
f01066ea:	29 ef                	sub    %ebp,%edi
f01066ec:	d3 e0                	shl    %cl,%eax
f01066ee:	89 f9                	mov    %edi,%ecx
f01066f0:	89 f2                	mov    %esi,%edx
f01066f2:	d3 ea                	shr    %cl,%edx
f01066f4:	89 e9                	mov    %ebp,%ecx
f01066f6:	09 c2                	or     %eax,%edx
f01066f8:	89 d8                	mov    %ebx,%eax
f01066fa:	89 14 24             	mov    %edx,(%esp)
f01066fd:	89 f2                	mov    %esi,%edx
f01066ff:	d3 e2                	shl    %cl,%edx
f0106701:	89 f9                	mov    %edi,%ecx
f0106703:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106707:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010670b:	d3 e8                	shr    %cl,%eax
f010670d:	89 e9                	mov    %ebp,%ecx
f010670f:	89 c6                	mov    %eax,%esi
f0106711:	d3 e3                	shl    %cl,%ebx
f0106713:	89 f9                	mov    %edi,%ecx
f0106715:	89 d0                	mov    %edx,%eax
f0106717:	d3 e8                	shr    %cl,%eax
f0106719:	89 e9                	mov    %ebp,%ecx
f010671b:	09 d8                	or     %ebx,%eax
f010671d:	89 d3                	mov    %edx,%ebx
f010671f:	89 f2                	mov    %esi,%edx
f0106721:	f7 34 24             	divl   (%esp)
f0106724:	89 d6                	mov    %edx,%esi
f0106726:	d3 e3                	shl    %cl,%ebx
f0106728:	f7 64 24 04          	mull   0x4(%esp)
f010672c:	39 d6                	cmp    %edx,%esi
f010672e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106732:	89 d1                	mov    %edx,%ecx
f0106734:	89 c3                	mov    %eax,%ebx
f0106736:	72 08                	jb     f0106740 <__umoddi3+0x110>
f0106738:	75 11                	jne    f010674b <__umoddi3+0x11b>
f010673a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010673e:	73 0b                	jae    f010674b <__umoddi3+0x11b>
f0106740:	2b 44 24 04          	sub    0x4(%esp),%eax
f0106744:	1b 14 24             	sbb    (%esp),%edx
f0106747:	89 d1                	mov    %edx,%ecx
f0106749:	89 c3                	mov    %eax,%ebx
f010674b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010674f:	29 da                	sub    %ebx,%edx
f0106751:	19 ce                	sbb    %ecx,%esi
f0106753:	89 f9                	mov    %edi,%ecx
f0106755:	89 f0                	mov    %esi,%eax
f0106757:	d3 e0                	shl    %cl,%eax
f0106759:	89 e9                	mov    %ebp,%ecx
f010675b:	d3 ea                	shr    %cl,%edx
f010675d:	89 e9                	mov    %ebp,%ecx
f010675f:	d3 ee                	shr    %cl,%esi
f0106761:	09 d0                	or     %edx,%eax
f0106763:	89 f2                	mov    %esi,%edx
f0106765:	83 c4 1c             	add    $0x1c,%esp
f0106768:	5b                   	pop    %ebx
f0106769:	5e                   	pop    %esi
f010676a:	5f                   	pop    %edi
f010676b:	5d                   	pop    %ebp
f010676c:	c3                   	ret    
f010676d:	8d 76 00             	lea    0x0(%esi),%esi
f0106770:	29 f9                	sub    %edi,%ecx
f0106772:	19 d6                	sbb    %edx,%esi
f0106774:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106778:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010677c:	e9 18 ff ff ff       	jmp    f0106699 <__umoddi3+0x69>
