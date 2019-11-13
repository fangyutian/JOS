
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
f0100015:	b8 00 50 11 00       	mov    $0x115000,%eax
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
f0100034:	bc 00 50 11 f0       	mov    $0xf0115000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 70 79 11 f0       	mov    $0xf0117970,%eax
f010004b:	2d 00 73 11 f0       	sub    $0xf0117300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 73 11 f0       	push   $0xf0117300
f0100058:	e8 ab 33 00 00       	call   f0103408 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 a0 04 00 00       	call   f0100502 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 a0 38 10 f0       	push   $0xf01038a0
f010006f:	e8 d0 28 00 00       	call   f0102944 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 c4 11 00 00       	call   f010123d <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 97 08 00 00       	call   f010091d <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 60 79 11 f0 00 	cmpl   $0x0,0xf0117960
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 60 79 11 f0    	mov    %esi,0xf0117960

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000a2:	fa                   	cli    
f01000a3:	fc                   	cld    

	va_start(ap, fmt);
f01000a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	83 ec 04             	sub    $0x4,%esp
f01000aa:	ff 75 0c             	pushl  0xc(%ebp)
f01000ad:	ff 75 08             	pushl  0x8(%ebp)
f01000b0:	68 bb 38 10 f0       	push   $0xf01038bb
f01000b5:	e8 8a 28 00 00       	call   f0102944 <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 5a 28 00 00       	call   f010291e <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 0d 49 10 f0 	movl   $0xf010490d,(%esp)
f01000cb:	e8 74 28 00 00       	call   f0102944 <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 40 08 00 00       	call   f010091d <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x48>

f01000e2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e2:	55                   	push   %ebp
f01000e3:	89 e5                	mov    %esp,%ebp
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000e9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	68 d3 38 10 f0       	push   $0xf01038d3
f01000f7:	e8 48 28 00 00       	call   f0102944 <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 16 28 00 00       	call   f010291e <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 0d 49 10 f0 	movl   $0xf010490d,(%esp)
f010010f:	e8 30 28 00 00       	call   f0102944 <cprintf>
	va_end(ap);
}
f0100114:	83 c4 10             	add    $0x10,%esp
f0100117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011a:	c9                   	leave  
f010011b:	c3                   	ret    

f010011c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010011c:	55                   	push   %ebp
f010011d:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010011f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100124:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100125:	a8 01                	test   $0x1,%al
f0100127:	74 0b                	je     f0100134 <serial_proc_data+0x18>
f0100129:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010012e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010012f:	0f b6 c0             	movzbl %al,%eax
f0100132:	eb 05                	jmp    f0100139 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100139:	5d                   	pop    %ebp
f010013a:	c3                   	ret    

f010013b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010013b:	55                   	push   %ebp
f010013c:	89 e5                	mov    %esp,%ebp
f010013e:	53                   	push   %ebx
f010013f:	83 ec 04             	sub    $0x4,%esp
f0100142:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100144:	eb 2b                	jmp    f0100171 <cons_intr+0x36>
		if (c == 0)
f0100146:	85 c0                	test   %eax,%eax
f0100148:	74 27                	je     f0100171 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010014a:	8b 0d 24 75 11 f0    	mov    0xf0117524,%ecx
f0100150:	8d 51 01             	lea    0x1(%ecx),%edx
f0100153:	89 15 24 75 11 f0    	mov    %edx,0xf0117524
f0100159:	88 81 20 73 11 f0    	mov    %al,-0xfee8ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010015f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100165:	75 0a                	jne    f0100171 <cons_intr+0x36>
			cons.wpos = 0;
f0100167:	c7 05 24 75 11 f0 00 	movl   $0x0,0xf0117524
f010016e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100171:	ff d3                	call   *%ebx
f0100173:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100176:	75 ce                	jne    f0100146 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100178:	83 c4 04             	add    $0x4,%esp
f010017b:	5b                   	pop    %ebx
f010017c:	5d                   	pop    %ebp
f010017d:	c3                   	ret    

f010017e <kbd_proc_data>:
f010017e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100183:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100184:	a8 01                	test   $0x1,%al
f0100186:	0f 84 f0 00 00 00    	je     f010027c <kbd_proc_data+0xfe>
f010018c:	ba 60 00 00 00       	mov    $0x60,%edx
f0100191:	ec                   	in     (%dx),%al
f0100192:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100194:	3c e0                	cmp    $0xe0,%al
f0100196:	75 0d                	jne    f01001a5 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f0100198:	83 0d 00 73 11 f0 40 	orl    $0x40,0xf0117300
		return 0;
f010019f:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001a4:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001a5:	55                   	push   %ebp
f01001a6:	89 e5                	mov    %esp,%ebp
f01001a8:	53                   	push   %ebx
f01001a9:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001ac:	84 c0                	test   %al,%al
f01001ae:	79 36                	jns    f01001e6 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001b0:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01001b6:	89 cb                	mov    %ecx,%ebx
f01001b8:	83 e3 40             	and    $0x40,%ebx
f01001bb:	83 e0 7f             	and    $0x7f,%eax
f01001be:	85 db                	test   %ebx,%ebx
f01001c0:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001c3:	0f b6 d2             	movzbl %dl,%edx
f01001c6:	0f b6 82 40 3a 10 f0 	movzbl -0xfefc5c0(%edx),%eax
f01001cd:	83 c8 40             	or     $0x40,%eax
f01001d0:	0f b6 c0             	movzbl %al,%eax
f01001d3:	f7 d0                	not    %eax
f01001d5:	21 c8                	and    %ecx,%eax
f01001d7:	a3 00 73 11 f0       	mov    %eax,0xf0117300
		return 0;
f01001dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01001e1:	e9 9e 00 00 00       	jmp    f0100284 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f01001e6:	8b 0d 00 73 11 f0    	mov    0xf0117300,%ecx
f01001ec:	f6 c1 40             	test   $0x40,%cl
f01001ef:	74 0e                	je     f01001ff <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001f1:	83 c8 80             	or     $0xffffff80,%eax
f01001f4:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001f6:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001f9:	89 0d 00 73 11 f0    	mov    %ecx,0xf0117300
	}

	shift |= shiftcode[data];
f01001ff:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100202:	0f b6 82 40 3a 10 f0 	movzbl -0xfefc5c0(%edx),%eax
f0100209:	0b 05 00 73 11 f0    	or     0xf0117300,%eax
f010020f:	0f b6 8a 40 39 10 f0 	movzbl -0xfefc6c0(%edx),%ecx
f0100216:	31 c8                	xor    %ecx,%eax
f0100218:	a3 00 73 11 f0       	mov    %eax,0xf0117300

	c = charcode[shift & (CTL | SHIFT)][data];
f010021d:	89 c1                	mov    %eax,%ecx
f010021f:	83 e1 03             	and    $0x3,%ecx
f0100222:	8b 0c 8d 20 39 10 f0 	mov    -0xfefc6e0(,%ecx,4),%ecx
f0100229:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010022d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100230:	a8 08                	test   $0x8,%al
f0100232:	74 1b                	je     f010024f <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100234:	89 da                	mov    %ebx,%edx
f0100236:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100239:	83 f9 19             	cmp    $0x19,%ecx
f010023c:	77 05                	ja     f0100243 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010023e:	83 eb 20             	sub    $0x20,%ebx
f0100241:	eb 0c                	jmp    f010024f <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f0100243:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100246:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100249:	83 fa 19             	cmp    $0x19,%edx
f010024c:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010024f:	f7 d0                	not    %eax
f0100251:	a8 06                	test   $0x6,%al
f0100253:	75 2d                	jne    f0100282 <kbd_proc_data+0x104>
f0100255:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010025b:	75 25                	jne    f0100282 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010025d:	83 ec 0c             	sub    $0xc,%esp
f0100260:	68 ed 38 10 f0       	push   $0xf01038ed
f0100265:	e8 da 26 00 00       	call   f0102944 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010026a:	ba 92 00 00 00       	mov    $0x92,%edx
f010026f:	b8 03 00 00 00       	mov    $0x3,%eax
f0100274:	ee                   	out    %al,(%dx)
f0100275:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100278:	89 d8                	mov    %ebx,%eax
f010027a:	eb 08                	jmp    f0100284 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010027c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100281:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100282:	89 d8                	mov    %ebx,%eax
}
f0100284:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100287:	c9                   	leave  
f0100288:	c3                   	ret    

f0100289 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100289:	55                   	push   %ebp
f010028a:	89 e5                	mov    %esp,%ebp
f010028c:	57                   	push   %edi
f010028d:	56                   	push   %esi
f010028e:	53                   	push   %ebx
f010028f:	83 ec 1c             	sub    $0x1c,%esp
f0100292:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100294:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100299:	be fd 03 00 00       	mov    $0x3fd,%esi
f010029e:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002a3:	eb 09                	jmp    f01002ae <cons_putc+0x25>
f01002a5:	89 ca                	mov    %ecx,%edx
f01002a7:	ec                   	in     (%dx),%al
f01002a8:	ec                   	in     (%dx),%al
f01002a9:	ec                   	in     (%dx),%al
f01002aa:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002ab:	83 c3 01             	add    $0x1,%ebx
f01002ae:	89 f2                	mov    %esi,%edx
f01002b0:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002b1:	a8 20                	test   $0x20,%al
f01002b3:	75 08                	jne    f01002bd <cons_putc+0x34>
f01002b5:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002bb:	7e e8                	jle    f01002a5 <cons_putc+0x1c>
f01002bd:	89 f8                	mov    %edi,%eax
f01002bf:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c2:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002c7:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002c8:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002cd:	be 79 03 00 00       	mov    $0x379,%esi
f01002d2:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002d7:	eb 09                	jmp    f01002e2 <cons_putc+0x59>
f01002d9:	89 ca                	mov    %ecx,%edx
f01002db:	ec                   	in     (%dx),%al
f01002dc:	ec                   	in     (%dx),%al
f01002dd:	ec                   	in     (%dx),%al
f01002de:	ec                   	in     (%dx),%al
f01002df:	83 c3 01             	add    $0x1,%ebx
f01002e2:	89 f2                	mov    %esi,%edx
f01002e4:	ec                   	in     (%dx),%al
f01002e5:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002eb:	7f 04                	jg     f01002f1 <cons_putc+0x68>
f01002ed:	84 c0                	test   %al,%al
f01002ef:	79 e8                	jns    f01002d9 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002f1:	ba 78 03 00 00       	mov    $0x378,%edx
f01002f6:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01002fa:	ee                   	out    %al,(%dx)
f01002fb:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100300:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100305:	ee                   	out    %al,(%dx)
f0100306:	b8 08 00 00 00       	mov    $0x8,%eax
f010030b:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF)) {
f010030c:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100312:	75 22                	jne    f0100336 <cons_putc+0xad>
    	char ch = c & 0xFF;
    		if (ch == 'o' ) {
f0100314:	89 f8                	mov    %edi,%eax
f0100316:	3c 6f                	cmp    $0x6f,%al
f0100318:	75 08                	jne    f0100322 <cons_putc+0x99>
        	c |= 0x0100;
f010031a:	81 cf 00 01 00 00    	or     $0x100,%edi
f0100320:	eb 14                	jmp    f0100336 <cons_putc+0xad>
    		} else if (ch == 's' ) {
        	c |= 0x0200;
f0100322:	89 f8                	mov    %edi,%eax
f0100324:	80 cc 02             	or     $0x2,%ah
f0100327:	89 fa                	mov    %edi,%edx
f0100329:	80 ce 07             	or     $0x7,%dh
f010032c:	89 fb                	mov    %edi,%ebx
f010032e:	80 fb 73             	cmp    $0x73,%bl
f0100331:	0f 45 c2             	cmovne %edx,%eax
f0100334:	89 c7                	mov    %eax,%edi
        	c |= 0x0700;
    		}
}


	switch (c & 0xff) {
f0100336:	89 f8                	mov    %edi,%eax
f0100338:	0f b6 c0             	movzbl %al,%eax
f010033b:	83 f8 09             	cmp    $0x9,%eax
f010033e:	74 74                	je     f01003b4 <cons_putc+0x12b>
f0100340:	83 f8 09             	cmp    $0x9,%eax
f0100343:	7f 0a                	jg     f010034f <cons_putc+0xc6>
f0100345:	83 f8 08             	cmp    $0x8,%eax
f0100348:	74 14                	je     f010035e <cons_putc+0xd5>
f010034a:	e9 99 00 00 00       	jmp    f01003e8 <cons_putc+0x15f>
f010034f:	83 f8 0a             	cmp    $0xa,%eax
f0100352:	74 3a                	je     f010038e <cons_putc+0x105>
f0100354:	83 f8 0d             	cmp    $0xd,%eax
f0100357:	74 3d                	je     f0100396 <cons_putc+0x10d>
f0100359:	e9 8a 00 00 00       	jmp    f01003e8 <cons_putc+0x15f>
	case '\b':
		if (crt_pos > 0) {
f010035e:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f0100365:	66 85 c0             	test   %ax,%ax
f0100368:	0f 84 e6 00 00 00    	je     f0100454 <cons_putc+0x1cb>
			crt_pos--;
f010036e:	83 e8 01             	sub    $0x1,%eax
f0100371:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100377:	0f b7 c0             	movzwl %ax,%eax
f010037a:	66 81 e7 00 ff       	and    $0xff00,%di
f010037f:	83 cf 20             	or     $0x20,%edi
f0100382:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100388:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010038c:	eb 78                	jmp    f0100406 <cons_putc+0x17d>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010038e:	66 83 05 28 75 11 f0 	addw   $0x50,0xf0117528
f0100395:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100396:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f010039d:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003a3:	c1 e8 16             	shr    $0x16,%eax
f01003a6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003a9:	c1 e0 04             	shl    $0x4,%eax
f01003ac:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
f01003b2:	eb 52                	jmp    f0100406 <cons_putc+0x17d>
		break;
	case '\t':
		cons_putc(' ');
f01003b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b9:	e8 cb fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003be:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c3:	e8 c1 fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003c8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003cd:	e8 b7 fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d7:	e8 ad fe ff ff       	call   f0100289 <cons_putc>
		cons_putc(' ');
f01003dc:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e1:	e8 a3 fe ff ff       	call   f0100289 <cons_putc>
f01003e6:	eb 1e                	jmp    f0100406 <cons_putc+0x17d>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003e8:	0f b7 05 28 75 11 f0 	movzwl 0xf0117528,%eax
f01003ef:	8d 50 01             	lea    0x1(%eax),%edx
f01003f2:	66 89 15 28 75 11 f0 	mov    %dx,0xf0117528
f01003f9:	0f b7 c0             	movzwl %ax,%eax
f01003fc:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100402:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100406:	66 81 3d 28 75 11 f0 	cmpw   $0x7cf,0xf0117528
f010040d:	cf 07 
f010040f:	76 43                	jbe    f0100454 <cons_putc+0x1cb>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100411:	a1 2c 75 11 f0       	mov    0xf011752c,%eax
f0100416:	83 ec 04             	sub    $0x4,%esp
f0100419:	68 00 0f 00 00       	push   $0xf00
f010041e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100424:	52                   	push   %edx
f0100425:	50                   	push   %eax
f0100426:	e8 2a 30 00 00       	call   f0103455 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010042b:	8b 15 2c 75 11 f0    	mov    0xf011752c,%edx
f0100431:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100437:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010043d:	83 c4 10             	add    $0x10,%esp
f0100440:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100445:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100448:	39 d0                	cmp    %edx,%eax
f010044a:	75 f4                	jne    f0100440 <cons_putc+0x1b7>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010044c:	66 83 2d 28 75 11 f0 	subw   $0x50,0xf0117528
f0100453:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100454:	8b 0d 30 75 11 f0    	mov    0xf0117530,%ecx
f010045a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010045f:	89 ca                	mov    %ecx,%edx
f0100461:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100462:	0f b7 1d 28 75 11 f0 	movzwl 0xf0117528,%ebx
f0100469:	8d 71 01             	lea    0x1(%ecx),%esi
f010046c:	89 d8                	mov    %ebx,%eax
f010046e:	66 c1 e8 08          	shr    $0x8,%ax
f0100472:	89 f2                	mov    %esi,%edx
f0100474:	ee                   	out    %al,(%dx)
f0100475:	b8 0f 00 00 00       	mov    $0xf,%eax
f010047a:	89 ca                	mov    %ecx,%edx
f010047c:	ee                   	out    %al,(%dx)
f010047d:	89 d8                	mov    %ebx,%eax
f010047f:	89 f2                	mov    %esi,%edx
f0100481:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100482:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100485:	5b                   	pop    %ebx
f0100486:	5e                   	pop    %esi
f0100487:	5f                   	pop    %edi
f0100488:	5d                   	pop    %ebp
f0100489:	c3                   	ret    

f010048a <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f010048a:	80 3d 34 75 11 f0 00 	cmpb   $0x0,0xf0117534
f0100491:	74 11                	je     f01004a4 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100493:	55                   	push   %ebp
f0100494:	89 e5                	mov    %esp,%ebp
f0100496:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100499:	b8 1c 01 10 f0       	mov    $0xf010011c,%eax
f010049e:	e8 98 fc ff ff       	call   f010013b <cons_intr>
}
f01004a3:	c9                   	leave  
f01004a4:	f3 c3                	repz ret 

f01004a6 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004a6:	55                   	push   %ebp
f01004a7:	89 e5                	mov    %esp,%ebp
f01004a9:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004ac:	b8 7e 01 10 f0       	mov    $0xf010017e,%eax
f01004b1:	e8 85 fc ff ff       	call   f010013b <cons_intr>
}
f01004b6:	c9                   	leave  
f01004b7:	c3                   	ret    

f01004b8 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004b8:	55                   	push   %ebp
f01004b9:	89 e5                	mov    %esp,%ebp
f01004bb:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004be:	e8 c7 ff ff ff       	call   f010048a <serial_intr>
	kbd_intr();
f01004c3:	e8 de ff ff ff       	call   f01004a6 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004c8:	a1 20 75 11 f0       	mov    0xf0117520,%eax
f01004cd:	3b 05 24 75 11 f0    	cmp    0xf0117524,%eax
f01004d3:	74 26                	je     f01004fb <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004d5:	8d 50 01             	lea    0x1(%eax),%edx
f01004d8:	89 15 20 75 11 f0    	mov    %edx,0xf0117520
f01004de:	0f b6 88 20 73 11 f0 	movzbl -0xfee8ce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004e5:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004e7:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004ed:	75 11                	jne    f0100500 <cons_getc+0x48>
			cons.rpos = 0;
f01004ef:	c7 05 20 75 11 f0 00 	movl   $0x0,0xf0117520
f01004f6:	00 00 00 
f01004f9:	eb 05                	jmp    f0100500 <cons_getc+0x48>
		return c;
	}
	return 0;
f01004fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100500:	c9                   	leave  
f0100501:	c3                   	ret    

f0100502 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100502:	55                   	push   %ebp
f0100503:	89 e5                	mov    %esp,%ebp
f0100505:	57                   	push   %edi
f0100506:	56                   	push   %esi
f0100507:	53                   	push   %ebx
f0100508:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010050b:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100512:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100519:	5a a5 
	if (*cp != 0xA55A) {
f010051b:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100522:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100526:	74 11                	je     f0100539 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100528:	c7 05 30 75 11 f0 b4 	movl   $0x3b4,0xf0117530
f010052f:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100532:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100537:	eb 16                	jmp    f010054f <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100539:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100540:	c7 05 30 75 11 f0 d4 	movl   $0x3d4,0xf0117530
f0100547:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010054a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010054f:	8b 3d 30 75 11 f0    	mov    0xf0117530,%edi
f0100555:	b8 0e 00 00 00       	mov    $0xe,%eax
f010055a:	89 fa                	mov    %edi,%edx
f010055c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010055d:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100560:	89 da                	mov    %ebx,%edx
f0100562:	ec                   	in     (%dx),%al
f0100563:	0f b6 c8             	movzbl %al,%ecx
f0100566:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100569:	b8 0f 00 00 00       	mov    $0xf,%eax
f010056e:	89 fa                	mov    %edi,%edx
f0100570:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100571:	89 da                	mov    %ebx,%edx
f0100573:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100574:	89 35 2c 75 11 f0    	mov    %esi,0xf011752c
	crt_pos = pos;
f010057a:	0f b6 c0             	movzbl %al,%eax
f010057d:	09 c8                	or     %ecx,%eax
f010057f:	66 a3 28 75 11 f0    	mov    %ax,0xf0117528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100585:	be fa 03 00 00       	mov    $0x3fa,%esi
f010058a:	b8 00 00 00 00       	mov    $0x0,%eax
f010058f:	89 f2                	mov    %esi,%edx
f0100591:	ee                   	out    %al,(%dx)
f0100592:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100597:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010059c:	ee                   	out    %al,(%dx)
f010059d:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005a2:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005a7:	89 da                	mov    %ebx,%edx
f01005a9:	ee                   	out    %al,(%dx)
f01005aa:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005af:	b8 00 00 00 00       	mov    $0x0,%eax
f01005b4:	ee                   	out    %al,(%dx)
f01005b5:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005ba:	b8 03 00 00 00       	mov    $0x3,%eax
f01005bf:	ee                   	out    %al,(%dx)
f01005c0:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ca:	ee                   	out    %al,(%dx)
f01005cb:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01005d5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005d6:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005db:	ec                   	in     (%dx),%al
f01005dc:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005de:	3c ff                	cmp    $0xff,%al
f01005e0:	0f 95 05 34 75 11 f0 	setne  0xf0117534
f01005e7:	89 f2                	mov    %esi,%edx
f01005e9:	ec                   	in     (%dx),%al
f01005ea:	89 da                	mov    %ebx,%edx
f01005ec:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005ed:	80 f9 ff             	cmp    $0xff,%cl
f01005f0:	75 10                	jne    f0100602 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005f2:	83 ec 0c             	sub    $0xc,%esp
f01005f5:	68 f9 38 10 f0       	push   $0xf01038f9
f01005fa:	e8 45 23 00 00       	call   f0102944 <cprintf>
f01005ff:	83 c4 10             	add    $0x10,%esp
}
f0100602:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100605:	5b                   	pop    %ebx
f0100606:	5e                   	pop    %esi
f0100607:	5f                   	pop    %edi
f0100608:	5d                   	pop    %ebp
f0100609:	c3                   	ret    

f010060a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010060a:	55                   	push   %ebp
f010060b:	89 e5                	mov    %esp,%ebp
f010060d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100610:	8b 45 08             	mov    0x8(%ebp),%eax
f0100613:	e8 71 fc ff ff       	call   f0100289 <cons_putc>
}
f0100618:	c9                   	leave  
f0100619:	c3                   	ret    

f010061a <getchar>:

int
getchar(void)
{
f010061a:	55                   	push   %ebp
f010061b:	89 e5                	mov    %esp,%ebp
f010061d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100620:	e8 93 fe ff ff       	call   f01004b8 <cons_getc>
f0100625:	85 c0                	test   %eax,%eax
f0100627:	74 f7                	je     f0100620 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100629:	c9                   	leave  
f010062a:	c3                   	ret    

f010062b <iscons>:

int
iscons(int fdnum)
{
f010062b:	55                   	push   %ebp
f010062c:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010062e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100633:	5d                   	pop    %ebp
f0100634:	c3                   	ret    

f0100635 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100635:	55                   	push   %ebp
f0100636:	89 e5                	mov    %esp,%ebp
f0100638:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010063b:	68 40 3b 10 f0       	push   $0xf0103b40
f0100640:	68 5e 3b 10 f0       	push   $0xf0103b5e
f0100645:	68 63 3b 10 f0       	push   $0xf0103b63
f010064a:	e8 f5 22 00 00       	call   f0102944 <cprintf>
f010064f:	83 c4 0c             	add    $0xc,%esp
f0100652:	68 40 3c 10 f0       	push   $0xf0103c40
f0100657:	68 6c 3b 10 f0       	push   $0xf0103b6c
f010065c:	68 63 3b 10 f0       	push   $0xf0103b63
f0100661:	e8 de 22 00 00       	call   f0102944 <cprintf>
f0100666:	83 c4 0c             	add    $0xc,%esp
f0100669:	68 68 3c 10 f0       	push   $0xf0103c68
f010066e:	68 75 3b 10 f0       	push   $0xf0103b75
f0100673:	68 63 3b 10 f0       	push   $0xf0103b63
f0100678:	e8 c7 22 00 00       	call   f0102944 <cprintf>
	return 0;
}
f010067d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100682:	c9                   	leave  
f0100683:	c3                   	ret    

f0100684 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100684:	55                   	push   %ebp
f0100685:	89 e5                	mov    %esp,%ebp
f0100687:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010068a:	68 82 3b 10 f0       	push   $0xf0103b82
f010068f:	e8 b0 22 00 00       	call   f0102944 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100694:	83 c4 08             	add    $0x8,%esp
f0100697:	68 0c 00 10 00       	push   $0x10000c
f010069c:	68 9c 3c 10 f0       	push   $0xf0103c9c
f01006a1:	e8 9e 22 00 00       	call   f0102944 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006a6:	83 c4 0c             	add    $0xc,%esp
f01006a9:	68 0c 00 10 00       	push   $0x10000c
f01006ae:	68 0c 00 10 f0       	push   $0xf010000c
f01006b3:	68 c4 3c 10 f0       	push   $0xf0103cc4
f01006b8:	e8 87 22 00 00       	call   f0102944 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006bd:	83 c4 0c             	add    $0xc,%esp
f01006c0:	68 91 38 10 00       	push   $0x103891
f01006c5:	68 91 38 10 f0       	push   $0xf0103891
f01006ca:	68 e8 3c 10 f0       	push   $0xf0103ce8
f01006cf:	e8 70 22 00 00       	call   f0102944 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006d4:	83 c4 0c             	add    $0xc,%esp
f01006d7:	68 00 73 11 00       	push   $0x117300
f01006dc:	68 00 73 11 f0       	push   $0xf0117300
f01006e1:	68 0c 3d 10 f0       	push   $0xf0103d0c
f01006e6:	e8 59 22 00 00       	call   f0102944 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006eb:	83 c4 0c             	add    $0xc,%esp
f01006ee:	68 70 79 11 00       	push   $0x117970
f01006f3:	68 70 79 11 f0       	push   $0xf0117970
f01006f8:	68 30 3d 10 f0       	push   $0xf0103d30
f01006fd:	e8 42 22 00 00       	call   f0102944 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100702:	b8 6f 7d 11 f0       	mov    $0xf0117d6f,%eax
f0100707:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010070c:	83 c4 08             	add    $0x8,%esp
f010070f:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100714:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010071a:	85 c0                	test   %eax,%eax
f010071c:	0f 48 c2             	cmovs  %edx,%eax
f010071f:	c1 f8 0a             	sar    $0xa,%eax
f0100722:	50                   	push   %eax
f0100723:	68 54 3d 10 f0       	push   $0xf0103d54
f0100728:	e8 17 22 00 00       	call   f0102944 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010072d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100732:	c9                   	leave  
f0100733:	c3                   	ret    

f0100734 <mon_showmappings>:
	}
}

int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100734:	55                   	push   %ebp
f0100735:	89 e5                	mov    %esp,%ebp
f0100737:	57                   	push   %edi
f0100738:	56                   	push   %esi
f0100739:	53                   	push   %ebx
f010073a:	83 ec 1c             	sub    $0x1c,%esp
f010073d:	8b 75 0c             	mov    0xc(%ebp),%esi
    if (argc != 3) {
f0100740:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
f0100744:	74 1a                	je     f0100760 <mon_showmappings+0x2c>
        cprintf("Require 2 virtual address.\n");
f0100746:	83 ec 0c             	sub    $0xc,%esp
f0100749:	68 9b 3b 10 f0       	push   $0xf0103b9b
f010074e:	e8 f1 21 00 00       	call   f0102944 <cprintf>
        return -1;
f0100753:	83 c4 10             	add    $0x10,%esp
f0100756:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010075b:	e9 3b 01 00 00       	jmp    f010089b <mon_showmappings+0x167>
    }
    char *errChar;
    uintptr_t start_addr = strtol(argv[1], &errChar, 16);
f0100760:	83 ec 04             	sub    $0x4,%esp
f0100763:	6a 10                	push   $0x10
f0100765:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100768:	50                   	push   %eax
f0100769:	ff 76 04             	pushl  0x4(%esi)
f010076c:	e8 bb 2d 00 00       	call   f010352c <strtol>
f0100771:	89 c3                	mov    %eax,%ebx
    if (*errChar) {
f0100773:	83 c4 10             	add    $0x10,%esp
f0100776:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100779:	80 38 00             	cmpb   $0x0,(%eax)
f010077c:	74 1d                	je     f010079b <mon_showmappings+0x67>
        cprintf("Invalid virtual address: %s.\n", argv[1]);
f010077e:	83 ec 08             	sub    $0x8,%esp
f0100781:	ff 76 04             	pushl  0x4(%esi)
f0100784:	68 b7 3b 10 f0       	push   $0xf0103bb7
f0100789:	e8 b6 21 00 00       	call   f0102944 <cprintf>
        return -1;
f010078e:	83 c4 10             	add    $0x10,%esp
f0100791:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100796:	e9 00 01 00 00       	jmp    f010089b <mon_showmappings+0x167>
    }
    uintptr_t end_addr = strtol(argv[2], &errChar, 16);
f010079b:	83 ec 04             	sub    $0x4,%esp
f010079e:	6a 10                	push   $0x10
f01007a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01007a3:	50                   	push   %eax
f01007a4:	ff 76 08             	pushl  0x8(%esi)
f01007a7:	e8 80 2d 00 00       	call   f010352c <strtol>
    if (*errChar) {
f01007ac:	83 c4 10             	add    $0x10,%esp
f01007af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01007b2:	80 3a 00             	cmpb   $0x0,(%edx)
f01007b5:	74 1d                	je     f01007d4 <mon_showmappings+0xa0>
        cprintf("Invalid virtual address: %s.\n", argv[2]);
f01007b7:	83 ec 08             	sub    $0x8,%esp
f01007ba:	ff 76 08             	pushl  0x8(%esi)
f01007bd:	68 b7 3b 10 f0       	push   $0xf0103bb7
f01007c2:	e8 7d 21 00 00       	call   f0102944 <cprintf>
        return -1;
f01007c7:	83 c4 10             	add    $0x10,%esp
f01007ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01007cf:	e9 c7 00 00 00       	jmp    f010089b <mon_showmappings+0x167>
    }
    if (start_addr > end_addr) {
f01007d4:	39 c3                	cmp    %eax,%ebx
f01007d6:	76 1a                	jbe    f01007f2 <mon_showmappings+0xbe>
        cprintf("Address 1 must be lower than address 2\n");
f01007d8:	83 ec 0c             	sub    $0xc,%esp
f01007db:	68 80 3d 10 f0       	push   $0xf0103d80
f01007e0:	e8 5f 21 00 00       	call   f0102944 <cprintf>
        return -1;
f01007e5:	83 c4 10             	add    $0x10,%esp
f01007e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01007ed:	e9 a9 00 00 00       	jmp    f010089b <mon_showmappings+0x167>
    }
    
    start_addr = ROUNDDOWN(start_addr, PGSIZE);
f01007f2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    end_addr = ROUNDUP(end_addr, PGSIZE);
f01007f8:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
f01007fe:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi

    uintptr_t cur_addr = start_addr;
    while (cur_addr <= end_addr) {
f0100804:	e9 85 00 00 00       	jmp    f010088e <mon_showmappings+0x15a>
        pte_t *cur_pte = pgdir_walk(kern_pgdir, (void *) cur_addr, 0);
f0100809:	83 ec 04             	sub    $0x4,%esp
f010080c:	6a 00                	push   $0x0
f010080e:	53                   	push   %ebx
f010080f:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0100815:	e8 be 07 00 00       	call   f0100fd8 <pgdir_walk>
f010081a:	89 c6                	mov    %eax,%esi
        if ( !cur_pte || !(*cur_pte & PTE_P)) {
f010081c:	83 c4 10             	add    $0x10,%esp
f010081f:	85 c0                	test   %eax,%eax
f0100821:	74 06                	je     f0100829 <mon_showmappings+0xf5>
f0100823:	8b 00                	mov    (%eax),%eax
f0100825:	a8 01                	test   $0x1,%al
f0100827:	75 13                	jne    f010083c <mon_showmappings+0x108>
            cprintf( "Virtual address [%08x] - not mapped\n", cur_addr);
f0100829:	83 ec 08             	sub    $0x8,%esp
f010082c:	53                   	push   %ebx
f010082d:	68 a8 3d 10 f0       	push   $0xf0103da8
f0100832:	e8 0d 21 00 00       	call   f0102944 <cprintf>
f0100837:	83 c4 10             	add    $0x10,%esp
f010083a:	eb 4c                	jmp    f0100888 <mon_showmappings+0x154>
        } else {
            cprintf( "Virtual address [0x%08x] - physical address [0x%08x], permission: ", cur_addr, PTE_ADDR(*cur_pte));
f010083c:	83 ec 04             	sub    $0x4,%esp
f010083f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100844:	50                   	push   %eax
f0100845:	53                   	push   %ebx
f0100846:	68 d0 3d 10 f0       	push   $0xf0103dd0
f010084b:	e8 f4 20 00 00       	call   f0102944 <cprintf>
            char perm_W = (*cur_pte & PTE_W) ? 'W':'-';
f0100850:	8b 06                	mov    (%esi),%eax
f0100852:	83 c4 0c             	add    $0xc,%esp
f0100855:	89 c2                	mov    %eax,%edx
f0100857:	83 e2 02             	and    $0x2,%edx
f010085a:	83 fa 01             	cmp    $0x1,%edx
f010085d:	19 d2                	sbb    %edx,%edx
f010085f:	83 e2 d6             	and    $0xffffffd6,%edx
f0100862:	83 c2 57             	add    $0x57,%edx
            char perm_U = (*cur_pte & PTE_U) ? 'U':'-';
f0100865:	83 e0 04             	and    $0x4,%eax
f0100868:	83 f8 01             	cmp    $0x1,%eax
f010086b:	19 c0                	sbb    %eax,%eax
f010086d:	83 e0 d8             	and    $0xffffffd8,%eax
f0100870:	83 c0 55             	add    $0x55,%eax
            cprintf( "-----%c%cP\n",perm_U, perm_W);
f0100873:	0f be d2             	movsbl %dl,%edx
f0100876:	52                   	push   %edx
f0100877:	0f be c0             	movsbl %al,%eax
f010087a:	50                   	push   %eax
f010087b:	68 d5 3b 10 f0       	push   $0xf0103bd5
f0100880:	e8 bf 20 00 00       	call   f0102944 <cprintf>
f0100885:	83 c4 10             	add    $0x10,%esp
        }
        cur_addr += PGSIZE;
f0100888:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    
    start_addr = ROUNDDOWN(start_addr, PGSIZE);
    end_addr = ROUNDUP(end_addr, PGSIZE);

    uintptr_t cur_addr = start_addr;
    while (cur_addr <= end_addr) {
f010088e:	39 fb                	cmp    %edi,%ebx
f0100890:	0f 86 73 ff ff ff    	jbe    f0100809 <mon_showmappings+0xd5>
            char perm_U = (*cur_pte & PTE_U) ? 'U':'-';
            cprintf( "-----%c%cP\n",perm_U, perm_W);
        }
        cur_addr += PGSIZE;
    }
    return 0;
f0100896:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010089b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010089e:	5b                   	pop    %ebx
f010089f:	5e                   	pop    %esi
f01008a0:	5f                   	pop    %edi
f01008a1:	5d                   	pop    %ebp
f01008a2:	c3                   	ret    

f01008a3 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008a3:	55                   	push   %ebp
f01008a4:	89 e5                	mov    %esp,%ebp
f01008a6:	56                   	push   %esi
f01008a7:	53                   	push   %ebx
f01008a8:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ab:	89 eb                	mov    %ebp,%ebx
	// Your code here.
uint32_t *ebp = (uint32_t*)read_ebp();
	cprintf("stack_backtrace:\n");
f01008ad:	68 e1 3b 10 f0       	push   $0xf0103be1
f01008b2:	e8 8d 20 00 00       	call   f0102944 <cprintf>
	while (ebp != 0x00)
f01008b7:	83 c4 10             	add    $0x10,%esp
	{
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, ebp[1], ebp[2], ebp[3], ebp[4],ebp[5],ebp[6]);
                struct Eipdebuginfo info;
		debuginfo_eip(ebp[1],&info);
f01008ba:	8d 75 e0             	lea    -0x20(%ebp),%esi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
uint32_t *ebp = (uint32_t*)read_ebp();
	cprintf("stack_backtrace:\n");
	while (ebp != 0x00)
f01008bd:	eb 4e                	jmp    f010090d <mon_backtrace+0x6a>
	{
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, ebp[1], ebp[2], ebp[3], ebp[4],ebp[5],ebp[6]);
f01008bf:	ff 73 18             	pushl  0x18(%ebx)
f01008c2:	ff 73 14             	pushl  0x14(%ebx)
f01008c5:	ff 73 10             	pushl  0x10(%ebx)
f01008c8:	ff 73 0c             	pushl  0xc(%ebx)
f01008cb:	ff 73 08             	pushl  0x8(%ebx)
f01008ce:	ff 73 04             	pushl  0x4(%ebx)
f01008d1:	53                   	push   %ebx
f01008d2:	68 14 3e 10 f0       	push   $0xf0103e14
f01008d7:	e8 68 20 00 00       	call   f0102944 <cprintf>
                struct Eipdebuginfo info;
		debuginfo_eip(ebp[1],&info);
f01008dc:	83 c4 18             	add    $0x18,%esp
f01008df:	56                   	push   %esi
f01008e0:	ff 73 04             	pushl  0x4(%ebx)
f01008e3:	e8 66 21 00 00       	call   f0102a4e <debuginfo_eip>
		cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
f01008e8:	83 c4 08             	add    $0x8,%esp
f01008eb:	8b 43 04             	mov    0x4(%ebx),%eax
f01008ee:	2b 45 f0             	sub    -0x10(%ebp),%eax
f01008f1:	50                   	push   %eax
f01008f2:	ff 75 e8             	pushl  -0x18(%ebp)
f01008f5:	ff 75 ec             	pushl  -0x14(%ebp)
f01008f8:	ff 75 e4             	pushl  -0x1c(%ebp)
f01008fb:	ff 75 e0             	pushl  -0x20(%ebp)
f01008fe:	68 f3 3b 10 f0       	push   $0xf0103bf3
f0100903:	e8 3c 20 00 00       	call   f0102944 <cprintf>
		ebp = (uint32_t*)ebp[0];
f0100908:	8b 1b                	mov    (%ebx),%ebx
f010090a:	83 c4 20             	add    $0x20,%esp
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
uint32_t *ebp = (uint32_t*)read_ebp();
	cprintf("stack_backtrace:\n");
	while (ebp != 0x00)
f010090d:	85 db                	test   %ebx,%ebx
f010090f:	75 ae                	jne    f01008bf <mon_backtrace+0x1c>
		debuginfo_eip(ebp[1],&info);
		cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
		ebp = (uint32_t*)ebp[0];
	}
	return 0;
}
f0100911:	b8 00 00 00 00       	mov    $0x0,%eax
f0100916:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100919:	5b                   	pop    %ebx
f010091a:	5e                   	pop    %esi
f010091b:	5d                   	pop    %ebp
f010091c:	c3                   	ret    

f010091d <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010091d:	55                   	push   %ebp
f010091e:	89 e5                	mov    %esp,%ebp
f0100920:	57                   	push   %edi
f0100921:	56                   	push   %esi
f0100922:	53                   	push   %ebx
f0100923:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100926:	68 48 3e 10 f0       	push   $0xf0103e48
f010092b:	e8 14 20 00 00       	call   f0102944 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100930:	c7 04 24 6c 3e 10 f0 	movl   $0xf0103e6c,(%esp)
f0100937:	e8 08 20 00 00       	call   f0102944 <cprintf>
f010093c:	83 c4 10             	add    $0x10,%esp
	while (1) {
		buf = readline("K> ");
f010093f:	83 ec 0c             	sub    $0xc,%esp
f0100942:	68 03 3c 10 f0       	push   $0xf0103c03
f0100947:	e8 65 28 00 00       	call   f01031b1 <readline>
f010094c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010094e:	83 c4 10             	add    $0x10,%esp
f0100951:	85 c0                	test   %eax,%eax
f0100953:	74 ea                	je     f010093f <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100955:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010095c:	be 00 00 00 00       	mov    $0x0,%esi
f0100961:	eb 0a                	jmp    f010096d <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100963:	c6 03 00             	movb   $0x0,(%ebx)
f0100966:	89 f7                	mov    %esi,%edi
f0100968:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010096b:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010096d:	0f b6 03             	movzbl (%ebx),%eax
f0100970:	84 c0                	test   %al,%al
f0100972:	74 63                	je     f01009d7 <monitor+0xba>
f0100974:	83 ec 08             	sub    $0x8,%esp
f0100977:	0f be c0             	movsbl %al,%eax
f010097a:	50                   	push   %eax
f010097b:	68 07 3c 10 f0       	push   $0xf0103c07
f0100980:	e8 46 2a 00 00       	call   f01033cb <strchr>
f0100985:	83 c4 10             	add    $0x10,%esp
f0100988:	85 c0                	test   %eax,%eax
f010098a:	75 d7                	jne    f0100963 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f010098c:	80 3b 00             	cmpb   $0x0,(%ebx)
f010098f:	74 46                	je     f01009d7 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100991:	83 fe 0f             	cmp    $0xf,%esi
f0100994:	75 14                	jne    f01009aa <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100996:	83 ec 08             	sub    $0x8,%esp
f0100999:	6a 10                	push   $0x10
f010099b:	68 0c 3c 10 f0       	push   $0xf0103c0c
f01009a0:	e8 9f 1f 00 00       	call   f0102944 <cprintf>
f01009a5:	83 c4 10             	add    $0x10,%esp
f01009a8:	eb 95                	jmp    f010093f <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01009aa:	8d 7e 01             	lea    0x1(%esi),%edi
f01009ad:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009b1:	eb 03                	jmp    f01009b6 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009b3:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009b6:	0f b6 03             	movzbl (%ebx),%eax
f01009b9:	84 c0                	test   %al,%al
f01009bb:	74 ae                	je     f010096b <monitor+0x4e>
f01009bd:	83 ec 08             	sub    $0x8,%esp
f01009c0:	0f be c0             	movsbl %al,%eax
f01009c3:	50                   	push   %eax
f01009c4:	68 07 3c 10 f0       	push   $0xf0103c07
f01009c9:	e8 fd 29 00 00       	call   f01033cb <strchr>
f01009ce:	83 c4 10             	add    $0x10,%esp
f01009d1:	85 c0                	test   %eax,%eax
f01009d3:	74 de                	je     f01009b3 <monitor+0x96>
f01009d5:	eb 94                	jmp    f010096b <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01009d7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009de:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009df:	85 f6                	test   %esi,%esi
f01009e1:	0f 84 58 ff ff ff    	je     f010093f <monitor+0x22>
f01009e7:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009ec:	83 ec 08             	sub    $0x8,%esp
f01009ef:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009f2:	ff 34 85 a0 3e 10 f0 	pushl  -0xfefc160(,%eax,4)
f01009f9:	ff 75 a8             	pushl  -0x58(%ebp)
f01009fc:	e8 6c 29 00 00       	call   f010336d <strcmp>
f0100a01:	83 c4 10             	add    $0x10,%esp
f0100a04:	85 c0                	test   %eax,%eax
f0100a06:	75 21                	jne    f0100a29 <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f0100a08:	83 ec 04             	sub    $0x4,%esp
f0100a0b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a0e:	ff 75 08             	pushl  0x8(%ebp)
f0100a11:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a14:	52                   	push   %edx
f0100a15:	56                   	push   %esi
f0100a16:	ff 14 85 a8 3e 10 f0 	call   *-0xfefc158(,%eax,4)
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a1d:	83 c4 10             	add    $0x10,%esp
f0100a20:	85 c0                	test   %eax,%eax
f0100a22:	78 25                	js     f0100a49 <monitor+0x12c>
f0100a24:	e9 16 ff ff ff       	jmp    f010093f <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a29:	83 c3 01             	add    $0x1,%ebx
f0100a2c:	83 fb 03             	cmp    $0x3,%ebx
f0100a2f:	75 bb                	jne    f01009ec <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a31:	83 ec 08             	sub    $0x8,%esp
f0100a34:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a37:	68 29 3c 10 f0       	push   $0xf0103c29
f0100a3c:	e8 03 1f 00 00       	call   f0102944 <cprintf>
f0100a41:	83 c4 10             	add    $0x10,%esp
f0100a44:	e9 f6 fe ff ff       	jmp    f010093f <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a49:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a4c:	5b                   	pop    %ebx
f0100a4d:	5e                   	pop    %esi
f0100a4e:	5f                   	pop    %edi
f0100a4f:	5d                   	pop    %ebp
f0100a50:	c3                   	ret    

f0100a51 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a51:	89 d1                	mov    %edx,%ecx
f0100a53:	c1 e9 16             	shr    $0x16,%ecx
f0100a56:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a59:	a8 01                	test   $0x1,%al
f0100a5b:	74 52                	je     f0100aaf <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a5d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a62:	89 c1                	mov    %eax,%ecx
f0100a64:	c1 e9 0c             	shr    $0xc,%ecx
f0100a67:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
f0100a6d:	72 1b                	jb     f0100a8a <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a6f:	55                   	push   %ebp
f0100a70:	89 e5                	mov    %esp,%ebp
f0100a72:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a75:	50                   	push   %eax
f0100a76:	68 c4 3e 10 f0       	push   $0xf0103ec4
f0100a7b:	68 dc 02 00 00       	push   $0x2dc
f0100a80:	68 4c 46 10 f0       	push   $0xf010464c
f0100a85:	e8 01 f6 ff ff       	call   f010008b <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100a8a:	c1 ea 0c             	shr    $0xc,%edx
f0100a8d:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a93:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a9a:	89 c2                	mov    %eax,%edx
f0100a9c:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a9f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aa4:	85 d2                	test   %edx,%edx
f0100aa6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100aab:	0f 44 c2             	cmove  %edx,%eax
f0100aae:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100aaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100ab4:	c3                   	ret    

f0100ab5 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100ab5:	55                   	push   %ebp
f0100ab6:	89 e5                	mov    %esp,%ebp
f0100ab8:	83 ec 08             	sub    $0x8,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100abb:	83 3d 38 75 11 f0 00 	cmpl   $0x0,0xf0117538
f0100ac2:	75 11                	jne    f0100ad5 <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100ac4:	ba 6f 89 11 f0       	mov    $0xf011896f,%edx
f0100ac9:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100acf:	89 15 38 75 11 f0    	mov    %edx,0xf0117538
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n==0)
f0100ad5:	85 c0                	test   %eax,%eax
f0100ad7:	75 07                	jne    f0100ae0 <boot_alloc+0x2b>
		return nextfree;
f0100ad9:	a1 38 75 11 f0       	mov    0xf0117538,%eax
f0100ade:	eb 5c                	jmp    f0100b3c <boot_alloc+0x87>
	result=nextfree;
f0100ae0:	8b 0d 38 75 11 f0    	mov    0xf0117538,%ecx
	nextfree+=ROUNDUP(n,PGSIZE);
f0100ae6:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100aec:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100af2:	01 ca                	add    %ecx,%edx
f0100af4:	89 15 38 75 11 f0    	mov    %edx,0xf0117538
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100afa:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100b00:	77 12                	ja     f0100b14 <boot_alloc+0x5f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b02:	52                   	push   %edx
f0100b03:	68 e8 3e 10 f0       	push   $0xf0103ee8
f0100b08:	6a 69                	push   $0x69
f0100b0a:	68 4c 46 10 f0       	push   $0xf010464c
f0100b0f:	e8 77 f5 ff ff       	call   f010008b <_panic>
	if(PADDR(nextfree)>npages*PGSIZE)
f0100b14:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0100b19:	c1 e0 0c             	shl    $0xc,%eax
f0100b1c:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100b22:	39 d0                	cmp    %edx,%eax
f0100b24:	73 14                	jae    f0100b3a <boot_alloc+0x85>
	{
		panic("Out of memory!\n");
f0100b26:	83 ec 04             	sub    $0x4,%esp
f0100b29:	68 58 46 10 f0       	push   $0xf0104658
f0100b2e:	6a 6b                	push   $0x6b
f0100b30:	68 4c 46 10 f0       	push   $0xf010464c
f0100b35:	e8 51 f5 ff ff       	call   f010008b <_panic>
	}
	return result;
f0100b3a:	89 c8                	mov    %ecx,%eax

}
f0100b3c:	c9                   	leave  
f0100b3d:	c3                   	ret    

f0100b3e <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b3e:	55                   	push   %ebp
f0100b3f:	89 e5                	mov    %esp,%ebp
f0100b41:	57                   	push   %edi
f0100b42:	56                   	push   %esi
f0100b43:	53                   	push   %ebx
f0100b44:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b47:	84 c0                	test   %al,%al
f0100b49:	0f 85 72 02 00 00    	jne    f0100dc1 <check_page_free_list+0x283>
f0100b4f:	e9 7f 02 00 00       	jmp    f0100dd3 <check_page_free_list+0x295>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b54:	83 ec 04             	sub    $0x4,%esp
f0100b57:	68 0c 3f 10 f0       	push   $0xf0103f0c
f0100b5c:	68 1f 02 00 00       	push   $0x21f
f0100b61:	68 4c 46 10 f0       	push   $0xf010464c
f0100b66:	e8 20 f5 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b6b:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b6e:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b71:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b74:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b77:	89 c2                	mov    %eax,%edx
f0100b79:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0100b7f:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b85:	0f 95 c2             	setne  %dl
f0100b88:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b8b:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b8f:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b91:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b95:	8b 00                	mov    (%eax),%eax
f0100b97:	85 c0                	test   %eax,%eax
f0100b99:	75 dc                	jne    f0100b77 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b9e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ba4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ba7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100baa:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bac:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100baf:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bb4:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bb9:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100bbf:	eb 53                	jmp    f0100c14 <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bc1:	89 d8                	mov    %ebx,%eax
f0100bc3:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100bc9:	c1 f8 03             	sar    $0x3,%eax
f0100bcc:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bcf:	89 c2                	mov    %eax,%edx
f0100bd1:	c1 ea 16             	shr    $0x16,%edx
f0100bd4:	39 f2                	cmp    %esi,%edx
f0100bd6:	73 3a                	jae    f0100c12 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bd8:	89 c2                	mov    %eax,%edx
f0100bda:	c1 ea 0c             	shr    $0xc,%edx
f0100bdd:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100be3:	72 12                	jb     f0100bf7 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100be5:	50                   	push   %eax
f0100be6:	68 c4 3e 10 f0       	push   $0xf0103ec4
f0100beb:	6a 52                	push   $0x52
f0100bed:	68 68 46 10 f0       	push   $0xf0104668
f0100bf2:	e8 94 f4 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100bf7:	83 ec 04             	sub    $0x4,%esp
f0100bfa:	68 80 00 00 00       	push   $0x80
f0100bff:	68 97 00 00 00       	push   $0x97
f0100c04:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c09:	50                   	push   %eax
f0100c0a:	e8 f9 27 00 00       	call   f0103408 <memset>
f0100c0f:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c12:	8b 1b                	mov    (%ebx),%ebx
f0100c14:	85 db                	test   %ebx,%ebx
f0100c16:	75 a9                	jne    f0100bc1 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c18:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c1d:	e8 93 fe ff ff       	call   f0100ab5 <boot_alloc>
f0100c22:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c25:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c2b:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
		assert(pp < pages + npages);
f0100c31:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0100c36:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c39:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c3c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c3f:	be 00 00 00 00       	mov    $0x0,%esi
f0100c44:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c47:	e9 30 01 00 00       	jmp    f0100d7c <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c4c:	39 ca                	cmp    %ecx,%edx
f0100c4e:	73 19                	jae    f0100c69 <check_page_free_list+0x12b>
f0100c50:	68 76 46 10 f0       	push   $0xf0104676
f0100c55:	68 82 46 10 f0       	push   $0xf0104682
f0100c5a:	68 39 02 00 00       	push   $0x239
f0100c5f:	68 4c 46 10 f0       	push   $0xf010464c
f0100c64:	e8 22 f4 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100c69:	39 fa                	cmp    %edi,%edx
f0100c6b:	72 19                	jb     f0100c86 <check_page_free_list+0x148>
f0100c6d:	68 97 46 10 f0       	push   $0xf0104697
f0100c72:	68 82 46 10 f0       	push   $0xf0104682
f0100c77:	68 3a 02 00 00       	push   $0x23a
f0100c7c:	68 4c 46 10 f0       	push   $0xf010464c
f0100c81:	e8 05 f4 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c86:	89 d0                	mov    %edx,%eax
f0100c88:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100c8b:	a8 07                	test   $0x7,%al
f0100c8d:	74 19                	je     f0100ca8 <check_page_free_list+0x16a>
f0100c8f:	68 30 3f 10 f0       	push   $0xf0103f30
f0100c94:	68 82 46 10 f0       	push   $0xf0104682
f0100c99:	68 3b 02 00 00       	push   $0x23b
f0100c9e:	68 4c 46 10 f0       	push   $0xf010464c
f0100ca3:	e8 e3 f3 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ca8:	c1 f8 03             	sar    $0x3,%eax
f0100cab:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cae:	85 c0                	test   %eax,%eax
f0100cb0:	75 19                	jne    f0100ccb <check_page_free_list+0x18d>
f0100cb2:	68 ab 46 10 f0       	push   $0xf01046ab
f0100cb7:	68 82 46 10 f0       	push   $0xf0104682
f0100cbc:	68 3e 02 00 00       	push   $0x23e
f0100cc1:	68 4c 46 10 f0       	push   $0xf010464c
f0100cc6:	e8 c0 f3 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ccb:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cd0:	75 19                	jne    f0100ceb <check_page_free_list+0x1ad>
f0100cd2:	68 bc 46 10 f0       	push   $0xf01046bc
f0100cd7:	68 82 46 10 f0       	push   $0xf0104682
f0100cdc:	68 3f 02 00 00       	push   $0x23f
f0100ce1:	68 4c 46 10 f0       	push   $0xf010464c
f0100ce6:	e8 a0 f3 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ceb:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100cf0:	75 19                	jne    f0100d0b <check_page_free_list+0x1cd>
f0100cf2:	68 64 3f 10 f0       	push   $0xf0103f64
f0100cf7:	68 82 46 10 f0       	push   $0xf0104682
f0100cfc:	68 40 02 00 00       	push   $0x240
f0100d01:	68 4c 46 10 f0       	push   $0xf010464c
f0100d06:	e8 80 f3 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d0b:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d10:	75 19                	jne    f0100d2b <check_page_free_list+0x1ed>
f0100d12:	68 d5 46 10 f0       	push   $0xf01046d5
f0100d17:	68 82 46 10 f0       	push   $0xf0104682
f0100d1c:	68 41 02 00 00       	push   $0x241
f0100d21:	68 4c 46 10 f0       	push   $0xf010464c
f0100d26:	e8 60 f3 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d2b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d30:	76 3f                	jbe    f0100d71 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d32:	89 c3                	mov    %eax,%ebx
f0100d34:	c1 eb 0c             	shr    $0xc,%ebx
f0100d37:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100d3a:	77 12                	ja     f0100d4e <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d3c:	50                   	push   %eax
f0100d3d:	68 c4 3e 10 f0       	push   $0xf0103ec4
f0100d42:	6a 52                	push   $0x52
f0100d44:	68 68 46 10 f0       	push   $0xf0104668
f0100d49:	e8 3d f3 ff ff       	call   f010008b <_panic>
f0100d4e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d53:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d56:	76 1e                	jbe    f0100d76 <check_page_free_list+0x238>
f0100d58:	68 88 3f 10 f0       	push   $0xf0103f88
f0100d5d:	68 82 46 10 f0       	push   $0xf0104682
f0100d62:	68 42 02 00 00       	push   $0x242
f0100d67:	68 4c 46 10 f0       	push   $0xf010464c
f0100d6c:	e8 1a f3 ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d71:	83 c6 01             	add    $0x1,%esi
f0100d74:	eb 04                	jmp    f0100d7a <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100d76:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d7a:	8b 12                	mov    (%edx),%edx
f0100d7c:	85 d2                	test   %edx,%edx
f0100d7e:	0f 85 c8 fe ff ff    	jne    f0100c4c <check_page_free_list+0x10e>
f0100d84:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d87:	85 f6                	test   %esi,%esi
f0100d89:	7f 19                	jg     f0100da4 <check_page_free_list+0x266>
f0100d8b:	68 ef 46 10 f0       	push   $0xf01046ef
f0100d90:	68 82 46 10 f0       	push   $0xf0104682
f0100d95:	68 4a 02 00 00       	push   $0x24a
f0100d9a:	68 4c 46 10 f0       	push   $0xf010464c
f0100d9f:	e8 e7 f2 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100da4:	85 db                	test   %ebx,%ebx
f0100da6:	7f 42                	jg     f0100dea <check_page_free_list+0x2ac>
f0100da8:	68 01 47 10 f0       	push   $0xf0104701
f0100dad:	68 82 46 10 f0       	push   $0xf0104682
f0100db2:	68 4b 02 00 00       	push   $0x24b
f0100db7:	68 4c 46 10 f0       	push   $0xf010464c
f0100dbc:	e8 ca f2 ff ff       	call   f010008b <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100dc1:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0100dc6:	85 c0                	test   %eax,%eax
f0100dc8:	0f 85 9d fd ff ff    	jne    f0100b6b <check_page_free_list+0x2d>
f0100dce:	e9 81 fd ff ff       	jmp    f0100b54 <check_page_free_list+0x16>
f0100dd3:	83 3d 3c 75 11 f0 00 	cmpl   $0x0,0xf011753c
f0100dda:	0f 84 74 fd ff ff    	je     f0100b54 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100de0:	be 00 04 00 00       	mov    $0x400,%esi
f0100de5:	e9 cf fd ff ff       	jmp    f0100bb9 <check_page_free_list+0x7b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100dea:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ded:	5b                   	pop    %ebx
f0100dee:	5e                   	pop    %esi
f0100def:	5f                   	pop    %edi
f0100df0:	5d                   	pop    %ebp
f0100df1:	c3                   	ret    

f0100df2 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100df2:	55                   	push   %ebp
f0100df3:	89 e5                	mov    %esp,%ebp
f0100df5:	56                   	push   %esi
f0100df6:	53                   	push   %ebx
	size_t i;

    //  1) Mark physical page 0 as in use.
    //     This way we preserve the real-mode IDT and BIOS structures
    //     in case we ever need them.  (Currently we don't, but...)
	pages[0].pp_ref = 1;
f0100df7:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0100dfc:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)

    //  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
    //     is free.
    for (i = 1; i < npages_basemem; i++) {
f0100e02:	8b 35 40 75 11 f0    	mov    0xf0117540,%esi
f0100e08:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100e0e:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e13:	b8 01 00 00 00       	mov    $0x1,%eax
f0100e18:	eb 27                	jmp    f0100e41 <page_init+0x4f>
	pages[i].pp_ref = 0;
f0100e1a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100e21:	89 d1                	mov    %edx,%ecx
f0100e23:	03 0d 6c 79 11 f0    	add    0xf011796c,%ecx
f0100e29:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
	pages[i].pp_link = page_free_list;
f0100e2f:	89 19                	mov    %ebx,(%ecx)
    //     in case we ever need them.  (Currently we don't, but...)
	pages[0].pp_ref = 1;

    //  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
    //     is free.
    for (i = 1; i < npages_basemem; i++) {
f0100e31:	83 c0 01             	add    $0x1,%eax
	pages[i].pp_ref = 0;
	pages[i].pp_link = page_free_list;
	page_free_list = &pages[i];
f0100e34:	89 d3                	mov    %edx,%ebx
f0100e36:	03 1d 6c 79 11 f0    	add    0xf011796c,%ebx
f0100e3c:	ba 01 00 00 00       	mov    $0x1,%edx
    //     in case we ever need them.  (Currently we don't, but...)
	pages[0].pp_ref = 1;

    //  2) The rest of base memory, [PGSIZE, npages_basemem * PGSIZE)
    //     is free.
    for (i = 1; i < npages_basemem; i++) {
f0100e41:	39 f0                	cmp    %esi,%eax
f0100e43:	72 d5                	jb     f0100e1a <page_init+0x28>
f0100e45:	84 d2                	test   %dl,%dl
f0100e47:	74 06                	je     f0100e4f <page_init+0x5d>
f0100e49:	89 1d 3c 75 11 f0    	mov    %ebx,0xf011753c
    }

    //  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
    //     never be allocated.
for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
	pages[i].pp_ref = 1;
f0100e4f:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
f0100e55:	8d 82 04 05 00 00    	lea    0x504(%edx),%eax
f0100e5b:	81 c2 04 08 00 00    	add    $0x804,%edx
f0100e61:	66 c7 00 01 00       	movw   $0x1,(%eax)
f0100e66:	83 c0 08             	add    $0x8,%eax
	page_free_list = &pages[i];
    }

    //  3) Then comes the IO hole [IOPHYSMEM, EXTPHYSMEM), which must
    //     never be allocated.
for (i = IOPHYSMEM/PGSIZE; i < EXTPHYSMEM/PGSIZE; i++) {
f0100e69:	39 d0                	cmp    %edx,%eax
f0100e6b:	75 f4                	jne    f0100e61 <page_init+0x6f>

    //  4) Then extended memory [EXTPHYSMEM, ...).
    //     Some of it is in use, some is free. Where is the kernel
    //     in physical memory?  Which pages are already in use for
    //     page tables and other data structures?
    size_t first_free_address = PADDR(boot_alloc(0));
f0100e6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e72:	e8 3e fc ff ff       	call   f0100ab5 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100e77:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e7c:	77 15                	ja     f0100e93 <page_init+0xa1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e7e:	50                   	push   %eax
f0100e7f:	68 e8 3e 10 f0       	push   $0xf0103ee8
f0100e84:	68 0d 01 00 00       	push   $0x10d
f0100e89:	68 4c 46 10 f0       	push   $0xf010464c
f0100e8e:	e8 f8 f1 ff ff       	call   f010008b <_panic>
    for (i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
f0100e93:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e98:	c1 e8 0c             	shr    $0xc,%eax
        pages[i].pp_ref = 1;
f0100e9b:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
    //  4) Then extended memory [EXTPHYSMEM, ...).
    //     Some of it is in use, some is free. Where is the kernel
    //     in physical memory?  Which pages are already in use for
    //     page tables and other data structures?
    size_t first_free_address = PADDR(boot_alloc(0));
    for (i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
f0100ea1:	ba 00 01 00 00       	mov    $0x100,%edx
f0100ea6:	eb 0a                	jmp    f0100eb2 <page_init+0xc0>
        pages[i].pp_ref = 1;
f0100ea8:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
    //  4) Then extended memory [EXTPHYSMEM, ...).
    //     Some of it is in use, some is free. Where is the kernel
    //     in physical memory?  Which pages are already in use for
    //     page tables and other data structures?
    size_t first_free_address = PADDR(boot_alloc(0));
    for (i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
f0100eaf:	83 c2 01             	add    $0x1,%edx
f0100eb2:	39 c2                	cmp    %eax,%edx
f0100eb4:	72 f2                	jb     f0100ea8 <page_init+0xb6>
f0100eb6:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100ebc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100ec3:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ec8:	eb 23                	jmp    f0100eed <page_init+0xfb>
        pages[i].pp_ref = 1;
    }
    for (i = first_free_address/PGSIZE; i < npages; i++) {
        pages[i].pp_ref = 0;
f0100eca:	89 d1                	mov    %edx,%ecx
f0100ecc:	03 0d 6c 79 11 f0    	add    0xf011796c,%ecx
f0100ed2:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
        pages[i].pp_link = page_free_list;
f0100ed8:	89 19                	mov    %ebx,(%ecx)
        page_free_list = &pages[i];
f0100eda:	89 d3                	mov    %edx,%ebx
f0100edc:	03 1d 6c 79 11 f0    	add    0xf011796c,%ebx
    //     page tables and other data structures?
    size_t first_free_address = PADDR(boot_alloc(0));
    for (i = EXTPHYSMEM/PGSIZE; i < first_free_address/PGSIZE; i++) {
        pages[i].pp_ref = 1;
    }
    for (i = first_free_address/PGSIZE; i < npages; i++) {
f0100ee2:	83 c0 01             	add    $0x1,%eax
f0100ee5:	83 c2 08             	add    $0x8,%edx
f0100ee8:	b9 01 00 00 00       	mov    $0x1,%ecx
f0100eed:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0100ef3:	72 d5                	jb     f0100eca <page_init+0xd8>
f0100ef5:	84 c9                	test   %cl,%cl
f0100ef7:	74 06                	je     f0100eff <page_init+0x10d>
f0100ef9:	89 1d 3c 75 11 f0    	mov    %ebx,0xf011753c
        pages[i].pp_ref = 0;
        pages[i].pp_link = page_free_list;
        page_free_list = &pages[i];
    }
}
f0100eff:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f02:	5b                   	pop    %ebx
f0100f03:	5e                   	pop    %esi
f0100f04:	5d                   	pop    %ebp
f0100f05:	c3                   	ret    

f0100f06 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f06:	55                   	push   %ebp
f0100f07:	89 e5                	mov    %esp,%ebp
f0100f09:	53                   	push   %ebx
f0100f0a:	83 ec 04             	sub    $0x4,%esp
    // Fill this function in
    struct PageInfo *result;
    if (page_free_list == NULL)
f0100f0d:	8b 1d 3c 75 11 f0    	mov    0xf011753c,%ebx
f0100f13:	85 db                	test   %ebx,%ebx
f0100f15:	74 58                	je     f0100f6f <page_alloc+0x69>
        return NULL;

      result= page_free_list;
      page_free_list = result->pp_link;
f0100f17:	8b 03                	mov    (%ebx),%eax
f0100f19:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
      result->pp_link = NULL;
f0100f1e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

    if (alloc_flags & ALLOC_ZERO)
f0100f24:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f28:	74 45                	je     f0100f6f <page_alloc+0x69>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f2a:	89 d8                	mov    %ebx,%eax
f0100f2c:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0100f32:	c1 f8 03             	sar    $0x3,%eax
f0100f35:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f38:	89 c2                	mov    %eax,%edx
f0100f3a:	c1 ea 0c             	shr    $0xc,%edx
f0100f3d:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0100f43:	72 12                	jb     f0100f57 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f45:	50                   	push   %eax
f0100f46:	68 c4 3e 10 f0       	push   $0xf0103ec4
f0100f4b:	6a 52                	push   $0x52
f0100f4d:	68 68 46 10 f0       	push   $0xf0104668
f0100f52:	e8 34 f1 ff ff       	call   f010008b <_panic>
        memset(page2kva(result), 0, PGSIZE); 
f0100f57:	83 ec 04             	sub    $0x4,%esp
f0100f5a:	68 00 10 00 00       	push   $0x1000
f0100f5f:	6a 00                	push   $0x0
f0100f61:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f66:	50                   	push   %eax
f0100f67:	e8 9c 24 00 00       	call   f0103408 <memset>
f0100f6c:	83 c4 10             	add    $0x10,%esp
      return result;
}
f0100f6f:	89 d8                	mov    %ebx,%eax
f0100f71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f74:	c9                   	leave  
f0100f75:	c3                   	ret    

f0100f76 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f76:	55                   	push   %ebp
f0100f77:	89 e5                	mov    %esp,%ebp
f0100f79:	83 ec 08             	sub    $0x8,%esp
f0100f7c:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
if (pp->pp_ref > 0 || pp->pp_link != NULL) {
f0100f7f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f84:	75 05                	jne    f0100f8b <page_free+0x15>
f0100f86:	83 38 00             	cmpl   $0x0,(%eax)
f0100f89:	74 17                	je     f0100fa2 <page_free+0x2c>
        panic("pp->pp_ref is nonzero or pp->pp_link is not NULL");
f0100f8b:	83 ec 04             	sub    $0x4,%esp
f0100f8e:	68 d0 3f 10 f0       	push   $0xf0103fd0
f0100f93:	68 3f 01 00 00       	push   $0x13f
f0100f98:	68 4c 46 10 f0       	push   $0xf010464c
f0100f9d:	e8 e9 f0 ff ff       	call   f010008b <_panic>
	return;
    }
    pp->pp_link = page_free_list;
f0100fa2:	8b 15 3c 75 11 f0    	mov    0xf011753c,%edx
f0100fa8:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
f0100faa:	a3 3c 75 11 f0       	mov    %eax,0xf011753c
}
f0100faf:	c9                   	leave  
f0100fb0:	c3                   	ret    

f0100fb1 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100fb1:	55                   	push   %ebp
f0100fb2:	89 e5                	mov    %esp,%ebp
f0100fb4:	83 ec 08             	sub    $0x8,%esp
f0100fb7:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fba:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fbe:	83 e8 01             	sub    $0x1,%eax
f0100fc1:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fc5:	66 85 c0             	test   %ax,%ax
f0100fc8:	75 0c                	jne    f0100fd6 <page_decref+0x25>
		page_free(pp);
f0100fca:	83 ec 0c             	sub    $0xc,%esp
f0100fcd:	52                   	push   %edx
f0100fce:	e8 a3 ff ff ff       	call   f0100f76 <page_free>
f0100fd3:	83 c4 10             	add    $0x10,%esp
}
f0100fd6:	c9                   	leave  
f0100fd7:	c3                   	ret    

f0100fd8 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100fd8:	55                   	push   %ebp
f0100fd9:	89 e5                	mov    %esp,%ebp
f0100fdb:	56                   	push   %esi
f0100fdc:	53                   	push   %ebx
f0100fdd:	8b 45 0c             	mov    0xc(%ebp),%eax
	uint32_t page_dir_idx = PDX(va);
	uint32_t page_tab_idx = PTX(va);
f0100fe0:	89 c6                	mov    %eax,%esi
f0100fe2:	c1 ee 0c             	shr    $0xc,%esi
f0100fe5:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	pte_t *pgtab;
	if (pgdir[page_dir_idx] & PTE_P) {
f0100feb:	c1 e8 16             	shr    $0x16,%eax
f0100fee:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f0100ff5:	03 5d 08             	add    0x8(%ebp),%ebx
f0100ff8:	8b 03                	mov    (%ebx),%eax
f0100ffa:	a8 01                	test   $0x1,%al
f0100ffc:	74 2e                	je     f010102c <pgdir_walk+0x54>
	pgtab = KADDR(PTE_ADDR(pgdir[page_dir_idx]));
f0100ffe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101003:	89 c2                	mov    %eax,%edx
f0101005:	c1 ea 0c             	shr    $0xc,%edx
f0101008:	39 15 64 79 11 f0    	cmp    %edx,0xf0117964
f010100e:	77 15                	ja     f0101025 <pgdir_walk+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101010:	50                   	push   %eax
f0101011:	68 c4 3e 10 f0       	push   $0xf0103ec4
f0101016:	68 6e 01 00 00       	push   $0x16e
f010101b:	68 4c 46 10 f0       	push   $0xf010464c
f0101020:	e8 66 f0 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101025:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010102a:	eb 73                	jmp    f010109f <pgdir_walk+0xc7>
	}else{
	if (create) {
f010102c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101030:	74 72                	je     f01010a4 <pgdir_walk+0xcc>
		struct PageInfo *new_pageInfo = page_alloc(ALLOC_ZERO);
f0101032:	83 ec 0c             	sub    $0xc,%esp
f0101035:	6a 01                	push   $0x1
f0101037:	e8 ca fe ff ff       	call   f0100f06 <page_alloc>
		if (new_pageInfo) {
f010103c:	83 c4 10             	add    $0x10,%esp
f010103f:	85 c0                	test   %eax,%eax
f0101041:	74 68                	je     f01010ab <pgdir_walk+0xd3>
		new_pageInfo->pp_ref += 1;
f0101043:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101048:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f010104e:	89 c2                	mov    %eax,%edx
f0101050:	c1 fa 03             	sar    $0x3,%edx
f0101053:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101056:	89 d0                	mov    %edx,%eax
f0101058:	c1 e8 0c             	shr    $0xc,%eax
f010105b:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0101061:	72 12                	jb     f0101075 <pgdir_walk+0x9d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101063:	52                   	push   %edx
f0101064:	68 c4 3e 10 f0       	push   $0xf0103ec4
f0101069:	6a 52                	push   $0x52
f010106b:	68 68 46 10 f0       	push   $0xf0104668
f0101070:	e8 16 f0 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101075:	8d 8a 00 00 00 f0    	lea    -0x10000000(%edx),%ecx
f010107b:	89 c8                	mov    %ecx,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010107d:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f0101083:	77 15                	ja     f010109a <pgdir_walk+0xc2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101085:	51                   	push   %ecx
f0101086:	68 e8 3e 10 f0       	push   $0xf0103ee8
f010108b:	68 75 01 00 00       	push   $0x175
f0101090:	68 4c 46 10 f0       	push   $0xf010464c
f0101095:	e8 f1 ef ff ff       	call   f010008b <_panic>
		pgtab = (pte_t *) page2kva(new_pageInfo);
		pgdir[page_dir_idx] = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
f010109a:	83 ca 07             	or     $0x7,%edx
f010109d:	89 13                	mov    %edx,(%ebx)
		}
	}else{
	return NULL;
	}
  	}
	return &pgtab[page_tab_idx];
f010109f:	8d 04 b0             	lea    (%eax,%esi,4),%eax
f01010a2:	eb 0c                	jmp    f01010b0 <pgdir_walk+0xd8>
		pgdir[page_dir_idx] = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
	}else{
		return NULL;
		}
	}else{
	return NULL;
f01010a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01010a9:	eb 05                	jmp    f01010b0 <pgdir_walk+0xd8>
		if (new_pageInfo) {
		new_pageInfo->pp_ref += 1;
		pgtab = (pte_t *) page2kva(new_pageInfo);
		pgdir[page_dir_idx] = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
	}else{
		return NULL;
f01010ab:	b8 00 00 00 00       	mov    $0x0,%eax
	}else{
	return NULL;
	}
  	}
	return &pgtab[page_tab_idx];
}
f01010b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010b3:	5b                   	pop    %ebx
f01010b4:	5e                   	pop    %esi
f01010b5:	5d                   	pop    %ebp
f01010b6:	c3                   	ret    

f01010b7 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01010b7:	55                   	push   %ebp
f01010b8:	89 e5                	mov    %esp,%ebp
f01010ba:	57                   	push   %edi
f01010bb:	56                   	push   %esi
f01010bc:	53                   	push   %ebx
f01010bd:	83 ec 1c             	sub    $0x1c,%esp
f01010c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01010c3:	8b 45 08             	mov    0x8(%ebp),%eax
    // Fill this function in
    pte_t *pgtab;
    size_t pg_num = PGNUM(size);
f01010c6:	c1 e9 0c             	shr    $0xc,%ecx
f01010c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
    //cprintf("map region size = %d, %d pages\n",size, pg_num);
    for (size_t i=0; i<pg_num; i++) {
f01010cc:	89 c3                	mov    %eax,%ebx
f01010ce:	be 00 00 00 00       	mov    $0x0,%esi
        pgtab = pgdir_walk(pgdir, (void *)va, 1);
f01010d3:	89 d7                	mov    %edx,%edi
f01010d5:	29 c7                	sub    %eax,%edi
        if (!pgtab) {
            return;
        }
        //cprintf("va = %p\n", va);
        *pgtab = pa | perm | PTE_P;
f01010d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010da:	83 c8 01             	or     $0x1,%eax
f01010dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
    // Fill this function in
    pte_t *pgtab;
    size_t pg_num = PGNUM(size);
    //cprintf("map region size = %d, %d pages\n",size, pg_num);
    for (size_t i=0; i<pg_num; i++) {
f01010e0:	eb 28                	jmp    f010110a <boot_map_region+0x53>
        pgtab = pgdir_walk(pgdir, (void *)va, 1);
f01010e2:	83 ec 04             	sub    $0x4,%esp
f01010e5:	6a 01                	push   $0x1
f01010e7:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01010ea:	50                   	push   %eax
f01010eb:	ff 75 e0             	pushl  -0x20(%ebp)
f01010ee:	e8 e5 fe ff ff       	call   f0100fd8 <pgdir_walk>
        if (!pgtab) {
f01010f3:	83 c4 10             	add    $0x10,%esp
f01010f6:	85 c0                	test   %eax,%eax
f01010f8:	74 15                	je     f010110f <boot_map_region+0x58>
            return;
        }
        //cprintf("va = %p\n", va);
        *pgtab = pa | perm | PTE_P;
f01010fa:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010fd:	09 da                	or     %ebx,%edx
f01010ff:	89 10                	mov    %edx,(%eax)
        va += PGSIZE;
        pa += PGSIZE;
f0101101:	81 c3 00 10 00 00    	add    $0x1000,%ebx
{
    // Fill this function in
    pte_t *pgtab;
    size_t pg_num = PGNUM(size);
    //cprintf("map region size = %d, %d pages\n",size, pg_num);
    for (size_t i=0; i<pg_num; i++) {
f0101107:	83 c6 01             	add    $0x1,%esi
f010110a:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010110d:	75 d3                	jne    f01010e2 <boot_map_region+0x2b>
        //cprintf("va = %p\n", va);
        *pgtab = pa | perm | PTE_P;
        va += PGSIZE;
        pa += PGSIZE;
    }
}
f010110f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101112:	5b                   	pop    %ebx
f0101113:	5e                   	pop    %esi
f0101114:	5f                   	pop    %edi
f0101115:	5d                   	pop    %ebp
f0101116:	c3                   	ret    

f0101117 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101117:	55                   	push   %ebp
f0101118:	89 e5                	mov    %esp,%ebp
f010111a:	53                   	push   %ebx
f010111b:	83 ec 08             	sub    $0x8,%esp
f010111e:	8b 5d 10             	mov    0x10(%ebp),%ebx
    pte_t *pgtab = pgdir_walk(pgdir, va, 0);  
f0101121:	6a 00                	push   $0x0
f0101123:	ff 75 0c             	pushl  0xc(%ebp)
f0101126:	ff 75 08             	pushl  0x8(%ebp)
f0101129:	e8 aa fe ff ff       	call   f0100fd8 <pgdir_walk>
    if (!pgtab) {
f010112e:	83 c4 10             	add    $0x10,%esp
f0101131:	85 c0                	test   %eax,%eax
f0101133:	74 32                	je     f0101167 <page_lookup+0x50>
        return NULL;  
    }
    if (pte_store) {
f0101135:	85 db                	test   %ebx,%ebx
f0101137:	74 02                	je     f010113b <page_lookup+0x24>
        *pte_store = pgtab; 
f0101139:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010113b:	8b 00                	mov    (%eax),%eax
f010113d:	c1 e8 0c             	shr    $0xc,%eax
f0101140:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0101146:	72 14                	jb     f010115c <page_lookup+0x45>
		panic("pa2page called with invalid pa");
f0101148:	83 ec 04             	sub    $0x4,%esp
f010114b:	68 04 40 10 f0       	push   $0xf0104004
f0101150:	6a 4b                	push   $0x4b
f0101152:	68 68 46 10 f0       	push   $0xf0104668
f0101157:	e8 2f ef ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f010115c:	8b 15 6c 79 11 f0    	mov    0xf011796c,%edx
f0101162:	8d 04 c2             	lea    (%edx,%eax,8),%eax
    }
    return pa2page(PTE_ADDR(*pgtab)); 
f0101165:	eb 05                	jmp    f010116c <page_lookup+0x55>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    pte_t *pgtab = pgdir_walk(pgdir, va, 0);  
    if (!pgtab) {
        return NULL;  
f0101167:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    if (pte_store) {
        *pte_store = pgtab; 
    }
    return pa2page(PTE_ADDR(*pgtab)); 
}
f010116c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010116f:	c9                   	leave  
f0101170:	c3                   	ret    

f0101171 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101171:	55                   	push   %ebp
f0101172:	89 e5                	mov    %esp,%ebp
f0101174:	53                   	push   %ebx
f0101175:	83 ec 18             	sub    $0x18,%esp
f0101178:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    // Fill this function in
    pte_t *pgtab;
    pte_t **pte_store = &pgtab;
    struct PageInfo *pInfo = page_lookup(pgdir, va, pte_store);
f010117b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010117e:	50                   	push   %eax
f010117f:	53                   	push   %ebx
f0101180:	ff 75 08             	pushl  0x8(%ebp)
f0101183:	e8 8f ff ff ff       	call   f0101117 <page_lookup>
    if (!pInfo) {
f0101188:	83 c4 10             	add    $0x10,%esp
f010118b:	85 c0                	test   %eax,%eax
f010118d:	74 18                	je     f01011a7 <page_remove+0x36>
        return;
	}
    page_decref(pInfo);
f010118f:	83 ec 0c             	sub    $0xc,%esp
f0101192:	50                   	push   %eax
f0101193:	e8 19 fe ff ff       	call   f0100fb1 <page_decref>
    *pgtab = 0;  
f0101198:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010119b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011a1:	0f 01 3b             	invlpg (%ebx)
f01011a4:	83 c4 10             	add    $0x10,%esp
    tlb_invalidate(pgdir, va);

}
f01011a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011aa:	c9                   	leave  
f01011ab:	c3                   	ret    

f01011ac <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01011ac:	55                   	push   %ebp
f01011ad:	89 e5                	mov    %esp,%ebp
f01011af:	57                   	push   %edi
f01011b0:	56                   	push   %esi
f01011b1:	53                   	push   %ebx
f01011b2:	83 ec 10             	sub    $0x10,%esp
f01011b5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011b8:	8b 7d 10             	mov    0x10(%ebp),%edi
    pte_t *pgtab = pgdir_walk(pgdir, va, 1);  
f01011bb:	6a 01                	push   $0x1
f01011bd:	57                   	push   %edi
f01011be:	ff 75 08             	pushl  0x8(%ebp)
f01011c1:	e8 12 fe ff ff       	call   f0100fd8 <pgdir_walk>
    if (!pgtab) {
f01011c6:	83 c4 10             	add    $0x10,%esp
f01011c9:	85 c0                	test   %eax,%eax
f01011cb:	74 63                	je     f0101230 <page_insert+0x84>
f01011cd:	89 c3                	mov    %eax,%ebx
        return -E_NO_MEM;  
    }
    if (*pgtab & PTE_P) {
f01011cf:	8b 00                	mov    (%eax),%eax
f01011d1:	a8 01                	test   $0x1,%al
f01011d3:	74 37                	je     f010120c <page_insert+0x60>
        if (page2pa(pp) == PTE_ADDR(*pgtab)) {
f01011d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01011da:	89 f2                	mov    %esi,%edx
f01011dc:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f01011e2:	c1 fa 03             	sar    $0x3,%edx
f01011e5:	c1 e2 0c             	shl    $0xc,%edx
f01011e8:	39 d0                	cmp    %edx,%eax
f01011ea:	75 11                	jne    f01011fd <page_insert+0x51>
            *pgtab = page2pa(pp) | perm | PTE_P;
f01011ec:	8b 55 14             	mov    0x14(%ebp),%edx
f01011ef:	83 ca 01             	or     $0x1,%edx
f01011f2:	09 d0                	or     %edx,%eax
f01011f4:	89 03                	mov    %eax,(%ebx)
            return 0;
f01011f6:	b8 00 00 00 00       	mov    $0x0,%eax
f01011fb:	eb 38                	jmp    f0101235 <page_insert+0x89>
        } else {
            page_remove(pgdir, va);
f01011fd:	83 ec 08             	sub    $0x8,%esp
f0101200:	57                   	push   %edi
f0101201:	ff 75 08             	pushl  0x8(%ebp)
f0101204:	e8 68 ff ff ff       	call   f0101171 <page_remove>
f0101209:	83 c4 10             	add    $0x10,%esp
        }
    }
    *pgtab = page2pa(pp) | perm | PTE_P;
f010120c:	89 f0                	mov    %esi,%eax
f010120e:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101214:	c1 f8 03             	sar    $0x3,%eax
f0101217:	c1 e0 0c             	shl    $0xc,%eax
f010121a:	8b 55 14             	mov    0x14(%ebp),%edx
f010121d:	83 ca 01             	or     $0x1,%edx
f0101220:	09 d0                	or     %edx,%eax
f0101222:	89 03                	mov    %eax,(%ebx)
    pp->pp_ref++;
f0101224:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
    return 0;
f0101229:	b8 00 00 00 00       	mov    $0x0,%eax
f010122e:	eb 05                	jmp    f0101235 <page_insert+0x89>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    pte_t *pgtab = pgdir_walk(pgdir, va, 1);  
    if (!pgtab) {
        return -E_NO_MEM;  
f0101230:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
        }
    }
    *pgtab = page2pa(pp) | perm | PTE_P;
    pp->pp_ref++;
    return 0;
}
f0101235:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101238:	5b                   	pop    %ebx
f0101239:	5e                   	pop    %esi
f010123a:	5f                   	pop    %edi
f010123b:	5d                   	pop    %ebp
f010123c:	c3                   	ret    

f010123d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010123d:	55                   	push   %ebp
f010123e:	89 e5                	mov    %esp,%ebp
f0101240:	57                   	push   %edi
f0101241:	56                   	push   %esi
f0101242:	53                   	push   %ebx
f0101243:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101246:	6a 15                	push   $0x15
f0101248:	e8 90 16 00 00       	call   f01028dd <mc146818_read>
f010124d:	89 c3                	mov    %eax,%ebx
f010124f:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f0101256:	e8 82 16 00 00       	call   f01028dd <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010125b:	c1 e0 08             	shl    $0x8,%eax
f010125e:	09 d8                	or     %ebx,%eax
f0101260:	c1 e0 0a             	shl    $0xa,%eax
f0101263:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101269:	85 c0                	test   %eax,%eax
f010126b:	0f 48 c2             	cmovs  %edx,%eax
f010126e:	c1 f8 0c             	sar    $0xc,%eax
f0101271:	a3 40 75 11 f0       	mov    %eax,0xf0117540
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101276:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f010127d:	e8 5b 16 00 00       	call   f01028dd <mc146818_read>
f0101282:	89 c3                	mov    %eax,%ebx
f0101284:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f010128b:	e8 4d 16 00 00       	call   f01028dd <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101290:	c1 e0 08             	shl    $0x8,%eax
f0101293:	09 d8                	or     %ebx,%eax
f0101295:	c1 e0 0a             	shl    $0xa,%eax
f0101298:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f010129e:	83 c4 10             	add    $0x10,%esp
f01012a1:	85 c0                	test   %eax,%eax
f01012a3:	0f 48 c2             	cmovs  %edx,%eax
f01012a6:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01012a9:	85 c0                	test   %eax,%eax
f01012ab:	74 0e                	je     f01012bb <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01012ad:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01012b3:	89 15 64 79 11 f0    	mov    %edx,0xf0117964
f01012b9:	eb 0c                	jmp    f01012c7 <mem_init+0x8a>
	else
		npages = npages_basemem;
f01012bb:	8b 15 40 75 11 f0    	mov    0xf0117540,%edx
f01012c1:	89 15 64 79 11 f0    	mov    %edx,0xf0117964

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01012c7:	c1 e0 0c             	shl    $0xc,%eax
f01012ca:	c1 e8 0a             	shr    $0xa,%eax
f01012cd:	50                   	push   %eax
f01012ce:	a1 40 75 11 f0       	mov    0xf0117540,%eax
f01012d3:	c1 e0 0c             	shl    $0xc,%eax
f01012d6:	c1 e8 0a             	shr    $0xa,%eax
f01012d9:	50                   	push   %eax
f01012da:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f01012df:	c1 e0 0c             	shl    $0xc,%eax
f01012e2:	c1 e8 0a             	shr    $0xa,%eax
f01012e5:	50                   	push   %eax
f01012e6:	68 24 40 10 f0       	push   $0xf0104024
f01012eb:	e8 54 16 00 00       	call   f0102944 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01012f0:	b8 00 10 00 00       	mov    $0x1000,%eax
f01012f5:	e8 bb f7 ff ff       	call   f0100ab5 <boot_alloc>
f01012fa:	a3 68 79 11 f0       	mov    %eax,0xf0117968
	memset(kern_pgdir, 0, PGSIZE);
f01012ff:	83 c4 0c             	add    $0xc,%esp
f0101302:	68 00 10 00 00       	push   $0x1000
f0101307:	6a 00                	push   $0x0
f0101309:	50                   	push   %eax
f010130a:	e8 f9 20 00 00       	call   f0103408 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010130f:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101314:	83 c4 10             	add    $0x10,%esp
f0101317:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010131c:	77 15                	ja     f0101333 <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010131e:	50                   	push   %eax
f010131f:	68 e8 3e 10 f0       	push   $0xf0103ee8
f0101324:	68 92 00 00 00       	push   $0x92
f0101329:	68 4c 46 10 f0       	push   $0xf010464c
f010132e:	e8 58 ed ff ff       	call   f010008b <_panic>
f0101333:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101339:	83 ca 05             	or     $0x5,%edx
f010133c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages=(struct PageInfo*)boot_alloc(npages*sizeof(struct PageInfo));
f0101342:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f0101347:	c1 e0 03             	shl    $0x3,%eax
f010134a:	e8 66 f7 ff ff       	call   f0100ab5 <boot_alloc>
f010134f:	a3 6c 79 11 f0       	mov    %eax,0xf011796c
	memset(pages,0,npages*sizeof(struct PageInfo));
f0101354:	83 ec 04             	sub    $0x4,%esp
f0101357:	8b 0d 64 79 11 f0    	mov    0xf0117964,%ecx
f010135d:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101364:	52                   	push   %edx
f0101365:	6a 00                	push   $0x0
f0101367:	50                   	push   %eax
f0101368:	e8 9b 20 00 00       	call   f0103408 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010136d:	e8 80 fa ff ff       	call   f0100df2 <page_init>

	check_page_free_list(1);
f0101372:	b8 01 00 00 00       	mov    $0x1,%eax
f0101377:	e8 c2 f7 ff ff       	call   f0100b3e <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010137c:	83 c4 10             	add    $0x10,%esp
f010137f:	83 3d 6c 79 11 f0 00 	cmpl   $0x0,0xf011796c
f0101386:	75 17                	jne    f010139f <mem_init+0x162>
		panic("'pages' is a null pointer!");
f0101388:	83 ec 04             	sub    $0x4,%esp
f010138b:	68 12 47 10 f0       	push   $0xf0104712
f0101390:	68 5c 02 00 00       	push   $0x25c
f0101395:	68 4c 46 10 f0       	push   $0xf010464c
f010139a:	e8 ec ec ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010139f:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f01013a4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013a9:	eb 05                	jmp    f01013b0 <mem_init+0x173>
		++nfree;
f01013ab:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013ae:	8b 00                	mov    (%eax),%eax
f01013b0:	85 c0                	test   %eax,%eax
f01013b2:	75 f7                	jne    f01013ab <mem_init+0x16e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01013b4:	83 ec 0c             	sub    $0xc,%esp
f01013b7:	6a 00                	push   $0x0
f01013b9:	e8 48 fb ff ff       	call   f0100f06 <page_alloc>
f01013be:	89 c7                	mov    %eax,%edi
f01013c0:	83 c4 10             	add    $0x10,%esp
f01013c3:	85 c0                	test   %eax,%eax
f01013c5:	75 19                	jne    f01013e0 <mem_init+0x1a3>
f01013c7:	68 2d 47 10 f0       	push   $0xf010472d
f01013cc:	68 82 46 10 f0       	push   $0xf0104682
f01013d1:	68 64 02 00 00       	push   $0x264
f01013d6:	68 4c 46 10 f0       	push   $0xf010464c
f01013db:	e8 ab ec ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01013e0:	83 ec 0c             	sub    $0xc,%esp
f01013e3:	6a 00                	push   $0x0
f01013e5:	e8 1c fb ff ff       	call   f0100f06 <page_alloc>
f01013ea:	89 c6                	mov    %eax,%esi
f01013ec:	83 c4 10             	add    $0x10,%esp
f01013ef:	85 c0                	test   %eax,%eax
f01013f1:	75 19                	jne    f010140c <mem_init+0x1cf>
f01013f3:	68 43 47 10 f0       	push   $0xf0104743
f01013f8:	68 82 46 10 f0       	push   $0xf0104682
f01013fd:	68 65 02 00 00       	push   $0x265
f0101402:	68 4c 46 10 f0       	push   $0xf010464c
f0101407:	e8 7f ec ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010140c:	83 ec 0c             	sub    $0xc,%esp
f010140f:	6a 00                	push   $0x0
f0101411:	e8 f0 fa ff ff       	call   f0100f06 <page_alloc>
f0101416:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101419:	83 c4 10             	add    $0x10,%esp
f010141c:	85 c0                	test   %eax,%eax
f010141e:	75 19                	jne    f0101439 <mem_init+0x1fc>
f0101420:	68 59 47 10 f0       	push   $0xf0104759
f0101425:	68 82 46 10 f0       	push   $0xf0104682
f010142a:	68 66 02 00 00       	push   $0x266
f010142f:	68 4c 46 10 f0       	push   $0xf010464c
f0101434:	e8 52 ec ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101439:	39 f7                	cmp    %esi,%edi
f010143b:	75 19                	jne    f0101456 <mem_init+0x219>
f010143d:	68 6f 47 10 f0       	push   $0xf010476f
f0101442:	68 82 46 10 f0       	push   $0xf0104682
f0101447:	68 69 02 00 00       	push   $0x269
f010144c:	68 4c 46 10 f0       	push   $0xf010464c
f0101451:	e8 35 ec ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101456:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101459:	39 c6                	cmp    %eax,%esi
f010145b:	74 04                	je     f0101461 <mem_init+0x224>
f010145d:	39 c7                	cmp    %eax,%edi
f010145f:	75 19                	jne    f010147a <mem_init+0x23d>
f0101461:	68 60 40 10 f0       	push   $0xf0104060
f0101466:	68 82 46 10 f0       	push   $0xf0104682
f010146b:	68 6a 02 00 00       	push   $0x26a
f0101470:	68 4c 46 10 f0       	push   $0xf010464c
f0101475:	e8 11 ec ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010147a:	8b 0d 6c 79 11 f0    	mov    0xf011796c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101480:	8b 15 64 79 11 f0    	mov    0xf0117964,%edx
f0101486:	c1 e2 0c             	shl    $0xc,%edx
f0101489:	89 f8                	mov    %edi,%eax
f010148b:	29 c8                	sub    %ecx,%eax
f010148d:	c1 f8 03             	sar    $0x3,%eax
f0101490:	c1 e0 0c             	shl    $0xc,%eax
f0101493:	39 d0                	cmp    %edx,%eax
f0101495:	72 19                	jb     f01014b0 <mem_init+0x273>
f0101497:	68 81 47 10 f0       	push   $0xf0104781
f010149c:	68 82 46 10 f0       	push   $0xf0104682
f01014a1:	68 6b 02 00 00       	push   $0x26b
f01014a6:	68 4c 46 10 f0       	push   $0xf010464c
f01014ab:	e8 db eb ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01014b0:	89 f0                	mov    %esi,%eax
f01014b2:	29 c8                	sub    %ecx,%eax
f01014b4:	c1 f8 03             	sar    $0x3,%eax
f01014b7:	c1 e0 0c             	shl    $0xc,%eax
f01014ba:	39 c2                	cmp    %eax,%edx
f01014bc:	77 19                	ja     f01014d7 <mem_init+0x29a>
f01014be:	68 9e 47 10 f0       	push   $0xf010479e
f01014c3:	68 82 46 10 f0       	push   $0xf0104682
f01014c8:	68 6c 02 00 00       	push   $0x26c
f01014cd:	68 4c 46 10 f0       	push   $0xf010464c
f01014d2:	e8 b4 eb ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01014d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014da:	29 c8                	sub    %ecx,%eax
f01014dc:	c1 f8 03             	sar    $0x3,%eax
f01014df:	c1 e0 0c             	shl    $0xc,%eax
f01014e2:	39 c2                	cmp    %eax,%edx
f01014e4:	77 19                	ja     f01014ff <mem_init+0x2c2>
f01014e6:	68 bb 47 10 f0       	push   $0xf01047bb
f01014eb:	68 82 46 10 f0       	push   $0xf0104682
f01014f0:	68 6d 02 00 00       	push   $0x26d
f01014f5:	68 4c 46 10 f0       	push   $0xf010464c
f01014fa:	e8 8c eb ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01014ff:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101504:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101507:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f010150e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101511:	83 ec 0c             	sub    $0xc,%esp
f0101514:	6a 00                	push   $0x0
f0101516:	e8 eb f9 ff ff       	call   f0100f06 <page_alloc>
f010151b:	83 c4 10             	add    $0x10,%esp
f010151e:	85 c0                	test   %eax,%eax
f0101520:	74 19                	je     f010153b <mem_init+0x2fe>
f0101522:	68 d8 47 10 f0       	push   $0xf01047d8
f0101527:	68 82 46 10 f0       	push   $0xf0104682
f010152c:	68 74 02 00 00       	push   $0x274
f0101531:	68 4c 46 10 f0       	push   $0xf010464c
f0101536:	e8 50 eb ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f010153b:	83 ec 0c             	sub    $0xc,%esp
f010153e:	57                   	push   %edi
f010153f:	e8 32 fa ff ff       	call   f0100f76 <page_free>
	page_free(pp1);
f0101544:	89 34 24             	mov    %esi,(%esp)
f0101547:	e8 2a fa ff ff       	call   f0100f76 <page_free>
	page_free(pp2);
f010154c:	83 c4 04             	add    $0x4,%esp
f010154f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101552:	e8 1f fa ff ff       	call   f0100f76 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101557:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010155e:	e8 a3 f9 ff ff       	call   f0100f06 <page_alloc>
f0101563:	89 c6                	mov    %eax,%esi
f0101565:	83 c4 10             	add    $0x10,%esp
f0101568:	85 c0                	test   %eax,%eax
f010156a:	75 19                	jne    f0101585 <mem_init+0x348>
f010156c:	68 2d 47 10 f0       	push   $0xf010472d
f0101571:	68 82 46 10 f0       	push   $0xf0104682
f0101576:	68 7b 02 00 00       	push   $0x27b
f010157b:	68 4c 46 10 f0       	push   $0xf010464c
f0101580:	e8 06 eb ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101585:	83 ec 0c             	sub    $0xc,%esp
f0101588:	6a 00                	push   $0x0
f010158a:	e8 77 f9 ff ff       	call   f0100f06 <page_alloc>
f010158f:	89 c7                	mov    %eax,%edi
f0101591:	83 c4 10             	add    $0x10,%esp
f0101594:	85 c0                	test   %eax,%eax
f0101596:	75 19                	jne    f01015b1 <mem_init+0x374>
f0101598:	68 43 47 10 f0       	push   $0xf0104743
f010159d:	68 82 46 10 f0       	push   $0xf0104682
f01015a2:	68 7c 02 00 00       	push   $0x27c
f01015a7:	68 4c 46 10 f0       	push   $0xf010464c
f01015ac:	e8 da ea ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01015b1:	83 ec 0c             	sub    $0xc,%esp
f01015b4:	6a 00                	push   $0x0
f01015b6:	e8 4b f9 ff ff       	call   f0100f06 <page_alloc>
f01015bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015be:	83 c4 10             	add    $0x10,%esp
f01015c1:	85 c0                	test   %eax,%eax
f01015c3:	75 19                	jne    f01015de <mem_init+0x3a1>
f01015c5:	68 59 47 10 f0       	push   $0xf0104759
f01015ca:	68 82 46 10 f0       	push   $0xf0104682
f01015cf:	68 7d 02 00 00       	push   $0x27d
f01015d4:	68 4c 46 10 f0       	push   $0xf010464c
f01015d9:	e8 ad ea ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015de:	39 fe                	cmp    %edi,%esi
f01015e0:	75 19                	jne    f01015fb <mem_init+0x3be>
f01015e2:	68 6f 47 10 f0       	push   $0xf010476f
f01015e7:	68 82 46 10 f0       	push   $0xf0104682
f01015ec:	68 7f 02 00 00       	push   $0x27f
f01015f1:	68 4c 46 10 f0       	push   $0xf010464c
f01015f6:	e8 90 ea ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01015fe:	39 c7                	cmp    %eax,%edi
f0101600:	74 04                	je     f0101606 <mem_init+0x3c9>
f0101602:	39 c6                	cmp    %eax,%esi
f0101604:	75 19                	jne    f010161f <mem_init+0x3e2>
f0101606:	68 60 40 10 f0       	push   $0xf0104060
f010160b:	68 82 46 10 f0       	push   $0xf0104682
f0101610:	68 80 02 00 00       	push   $0x280
f0101615:	68 4c 46 10 f0       	push   $0xf010464c
f010161a:	e8 6c ea ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f010161f:	83 ec 0c             	sub    $0xc,%esp
f0101622:	6a 00                	push   $0x0
f0101624:	e8 dd f8 ff ff       	call   f0100f06 <page_alloc>
f0101629:	83 c4 10             	add    $0x10,%esp
f010162c:	85 c0                	test   %eax,%eax
f010162e:	74 19                	je     f0101649 <mem_init+0x40c>
f0101630:	68 d8 47 10 f0       	push   $0xf01047d8
f0101635:	68 82 46 10 f0       	push   $0xf0104682
f010163a:	68 81 02 00 00       	push   $0x281
f010163f:	68 4c 46 10 f0       	push   $0xf010464c
f0101644:	e8 42 ea ff ff       	call   f010008b <_panic>
f0101649:	89 f0                	mov    %esi,%eax
f010164b:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101651:	c1 f8 03             	sar    $0x3,%eax
f0101654:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101657:	89 c2                	mov    %eax,%edx
f0101659:	c1 ea 0c             	shr    $0xc,%edx
f010165c:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0101662:	72 12                	jb     f0101676 <mem_init+0x439>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101664:	50                   	push   %eax
f0101665:	68 c4 3e 10 f0       	push   $0xf0103ec4
f010166a:	6a 52                	push   $0x52
f010166c:	68 68 46 10 f0       	push   $0xf0104668
f0101671:	e8 15 ea ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101676:	83 ec 04             	sub    $0x4,%esp
f0101679:	68 00 10 00 00       	push   $0x1000
f010167e:	6a 01                	push   $0x1
f0101680:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101685:	50                   	push   %eax
f0101686:	e8 7d 1d 00 00       	call   f0103408 <memset>
	page_free(pp0);
f010168b:	89 34 24             	mov    %esi,(%esp)
f010168e:	e8 e3 f8 ff ff       	call   f0100f76 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101693:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010169a:	e8 67 f8 ff ff       	call   f0100f06 <page_alloc>
f010169f:	83 c4 10             	add    $0x10,%esp
f01016a2:	85 c0                	test   %eax,%eax
f01016a4:	75 19                	jne    f01016bf <mem_init+0x482>
f01016a6:	68 e7 47 10 f0       	push   $0xf01047e7
f01016ab:	68 82 46 10 f0       	push   $0xf0104682
f01016b0:	68 86 02 00 00       	push   $0x286
f01016b5:	68 4c 46 10 f0       	push   $0xf010464c
f01016ba:	e8 cc e9 ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f01016bf:	39 c6                	cmp    %eax,%esi
f01016c1:	74 19                	je     f01016dc <mem_init+0x49f>
f01016c3:	68 05 48 10 f0       	push   $0xf0104805
f01016c8:	68 82 46 10 f0       	push   $0xf0104682
f01016cd:	68 87 02 00 00       	push   $0x287
f01016d2:	68 4c 46 10 f0       	push   $0xf010464c
f01016d7:	e8 af e9 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016dc:	89 f0                	mov    %esi,%eax
f01016de:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01016e4:	c1 f8 03             	sar    $0x3,%eax
f01016e7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016ea:	89 c2                	mov    %eax,%edx
f01016ec:	c1 ea 0c             	shr    $0xc,%edx
f01016ef:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f01016f5:	72 12                	jb     f0101709 <mem_init+0x4cc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016f7:	50                   	push   %eax
f01016f8:	68 c4 3e 10 f0       	push   $0xf0103ec4
f01016fd:	6a 52                	push   $0x52
f01016ff:	68 68 46 10 f0       	push   $0xf0104668
f0101704:	e8 82 e9 ff ff       	call   f010008b <_panic>
f0101709:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010170f:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101715:	80 38 00             	cmpb   $0x0,(%eax)
f0101718:	74 19                	je     f0101733 <mem_init+0x4f6>
f010171a:	68 15 48 10 f0       	push   $0xf0104815
f010171f:	68 82 46 10 f0       	push   $0xf0104682
f0101724:	68 8a 02 00 00       	push   $0x28a
f0101729:	68 4c 46 10 f0       	push   $0xf010464c
f010172e:	e8 58 e9 ff ff       	call   f010008b <_panic>
f0101733:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101736:	39 d0                	cmp    %edx,%eax
f0101738:	75 db                	jne    f0101715 <mem_init+0x4d8>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010173a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010173d:	a3 3c 75 11 f0       	mov    %eax,0xf011753c

	// free the pages we took
	page_free(pp0);
f0101742:	83 ec 0c             	sub    $0xc,%esp
f0101745:	56                   	push   %esi
f0101746:	e8 2b f8 ff ff       	call   f0100f76 <page_free>
	page_free(pp1);
f010174b:	89 3c 24             	mov    %edi,(%esp)
f010174e:	e8 23 f8 ff ff       	call   f0100f76 <page_free>
	page_free(pp2);
f0101753:	83 c4 04             	add    $0x4,%esp
f0101756:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101759:	e8 18 f8 ff ff       	call   f0100f76 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010175e:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101763:	83 c4 10             	add    $0x10,%esp
f0101766:	eb 05                	jmp    f010176d <mem_init+0x530>
		--nfree;
f0101768:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010176b:	8b 00                	mov    (%eax),%eax
f010176d:	85 c0                	test   %eax,%eax
f010176f:	75 f7                	jne    f0101768 <mem_init+0x52b>
		--nfree;
	assert(nfree == 0);
f0101771:	85 db                	test   %ebx,%ebx
f0101773:	74 19                	je     f010178e <mem_init+0x551>
f0101775:	68 1f 48 10 f0       	push   $0xf010481f
f010177a:	68 82 46 10 f0       	push   $0xf0104682
f010177f:	68 97 02 00 00       	push   $0x297
f0101784:	68 4c 46 10 f0       	push   $0xf010464c
f0101789:	e8 fd e8 ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010178e:	83 ec 0c             	sub    $0xc,%esp
f0101791:	68 80 40 10 f0       	push   $0xf0104080
f0101796:	e8 a9 11 00 00       	call   f0102944 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010179b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a2:	e8 5f f7 ff ff       	call   f0100f06 <page_alloc>
f01017a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01017aa:	83 c4 10             	add    $0x10,%esp
f01017ad:	85 c0                	test   %eax,%eax
f01017af:	75 19                	jne    f01017ca <mem_init+0x58d>
f01017b1:	68 2d 47 10 f0       	push   $0xf010472d
f01017b6:	68 82 46 10 f0       	push   $0xf0104682
f01017bb:	68 f0 02 00 00       	push   $0x2f0
f01017c0:	68 4c 46 10 f0       	push   $0xf010464c
f01017c5:	e8 c1 e8 ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01017ca:	83 ec 0c             	sub    $0xc,%esp
f01017cd:	6a 00                	push   $0x0
f01017cf:	e8 32 f7 ff ff       	call   f0100f06 <page_alloc>
f01017d4:	89 c3                	mov    %eax,%ebx
f01017d6:	83 c4 10             	add    $0x10,%esp
f01017d9:	85 c0                	test   %eax,%eax
f01017db:	75 19                	jne    f01017f6 <mem_init+0x5b9>
f01017dd:	68 43 47 10 f0       	push   $0xf0104743
f01017e2:	68 82 46 10 f0       	push   $0xf0104682
f01017e7:	68 f1 02 00 00       	push   $0x2f1
f01017ec:	68 4c 46 10 f0       	push   $0xf010464c
f01017f1:	e8 95 e8 ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01017f6:	83 ec 0c             	sub    $0xc,%esp
f01017f9:	6a 00                	push   $0x0
f01017fb:	e8 06 f7 ff ff       	call   f0100f06 <page_alloc>
f0101800:	89 c6                	mov    %eax,%esi
f0101802:	83 c4 10             	add    $0x10,%esp
f0101805:	85 c0                	test   %eax,%eax
f0101807:	75 19                	jne    f0101822 <mem_init+0x5e5>
f0101809:	68 59 47 10 f0       	push   $0xf0104759
f010180e:	68 82 46 10 f0       	push   $0xf0104682
f0101813:	68 f2 02 00 00       	push   $0x2f2
f0101818:	68 4c 46 10 f0       	push   $0xf010464c
f010181d:	e8 69 e8 ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101822:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101825:	75 19                	jne    f0101840 <mem_init+0x603>
f0101827:	68 6f 47 10 f0       	push   $0xf010476f
f010182c:	68 82 46 10 f0       	push   $0xf0104682
f0101831:	68 f5 02 00 00       	push   $0x2f5
f0101836:	68 4c 46 10 f0       	push   $0xf010464c
f010183b:	e8 4b e8 ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101840:	39 c3                	cmp    %eax,%ebx
f0101842:	74 05                	je     f0101849 <mem_init+0x60c>
f0101844:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101847:	75 19                	jne    f0101862 <mem_init+0x625>
f0101849:	68 60 40 10 f0       	push   $0xf0104060
f010184e:	68 82 46 10 f0       	push   $0xf0104682
f0101853:	68 f6 02 00 00       	push   $0x2f6
f0101858:	68 4c 46 10 f0       	push   $0xf010464c
f010185d:	e8 29 e8 ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101862:	a1 3c 75 11 f0       	mov    0xf011753c,%eax
f0101867:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010186a:	c7 05 3c 75 11 f0 00 	movl   $0x0,0xf011753c
f0101871:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101874:	83 ec 0c             	sub    $0xc,%esp
f0101877:	6a 00                	push   $0x0
f0101879:	e8 88 f6 ff ff       	call   f0100f06 <page_alloc>
f010187e:	83 c4 10             	add    $0x10,%esp
f0101881:	85 c0                	test   %eax,%eax
f0101883:	74 19                	je     f010189e <mem_init+0x661>
f0101885:	68 d8 47 10 f0       	push   $0xf01047d8
f010188a:	68 82 46 10 f0       	push   $0xf0104682
f010188f:	68 fd 02 00 00       	push   $0x2fd
f0101894:	68 4c 46 10 f0       	push   $0xf010464c
f0101899:	e8 ed e7 ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010189e:	83 ec 04             	sub    $0x4,%esp
f01018a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018a4:	50                   	push   %eax
f01018a5:	6a 00                	push   $0x0
f01018a7:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01018ad:	e8 65 f8 ff ff       	call   f0101117 <page_lookup>
f01018b2:	83 c4 10             	add    $0x10,%esp
f01018b5:	85 c0                	test   %eax,%eax
f01018b7:	74 19                	je     f01018d2 <mem_init+0x695>
f01018b9:	68 a0 40 10 f0       	push   $0xf01040a0
f01018be:	68 82 46 10 f0       	push   $0xf0104682
f01018c3:	68 00 03 00 00       	push   $0x300
f01018c8:	68 4c 46 10 f0       	push   $0xf010464c
f01018cd:	e8 b9 e7 ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018d2:	6a 02                	push   $0x2
f01018d4:	6a 00                	push   $0x0
f01018d6:	53                   	push   %ebx
f01018d7:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01018dd:	e8 ca f8 ff ff       	call   f01011ac <page_insert>
f01018e2:	83 c4 10             	add    $0x10,%esp
f01018e5:	85 c0                	test   %eax,%eax
f01018e7:	78 19                	js     f0101902 <mem_init+0x6c5>
f01018e9:	68 d8 40 10 f0       	push   $0xf01040d8
f01018ee:	68 82 46 10 f0       	push   $0xf0104682
f01018f3:	68 03 03 00 00       	push   $0x303
f01018f8:	68 4c 46 10 f0       	push   $0xf010464c
f01018fd:	e8 89 e7 ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101902:	83 ec 0c             	sub    $0xc,%esp
f0101905:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101908:	e8 69 f6 ff ff       	call   f0100f76 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010190d:	6a 02                	push   $0x2
f010190f:	6a 00                	push   $0x0
f0101911:	53                   	push   %ebx
f0101912:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101918:	e8 8f f8 ff ff       	call   f01011ac <page_insert>
f010191d:	83 c4 20             	add    $0x20,%esp
f0101920:	85 c0                	test   %eax,%eax
f0101922:	74 19                	je     f010193d <mem_init+0x700>
f0101924:	68 08 41 10 f0       	push   $0xf0104108
f0101929:	68 82 46 10 f0       	push   $0xf0104682
f010192e:	68 07 03 00 00       	push   $0x307
f0101933:	68 4c 46 10 f0       	push   $0xf010464c
f0101938:	e8 4e e7 ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010193d:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101943:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
f0101948:	89 c1                	mov    %eax,%ecx
f010194a:	89 45 cc             	mov    %eax,-0x34(%ebp)
f010194d:	8b 17                	mov    (%edi),%edx
f010194f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101955:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101958:	29 c8                	sub    %ecx,%eax
f010195a:	c1 f8 03             	sar    $0x3,%eax
f010195d:	c1 e0 0c             	shl    $0xc,%eax
f0101960:	39 c2                	cmp    %eax,%edx
f0101962:	74 19                	je     f010197d <mem_init+0x740>
f0101964:	68 38 41 10 f0       	push   $0xf0104138
f0101969:	68 82 46 10 f0       	push   $0xf0104682
f010196e:	68 08 03 00 00       	push   $0x308
f0101973:	68 4c 46 10 f0       	push   $0xf010464c
f0101978:	e8 0e e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010197d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101982:	89 f8                	mov    %edi,%eax
f0101984:	e8 c8 f0 ff ff       	call   f0100a51 <check_va2pa>
f0101989:	89 da                	mov    %ebx,%edx
f010198b:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010198e:	c1 fa 03             	sar    $0x3,%edx
f0101991:	c1 e2 0c             	shl    $0xc,%edx
f0101994:	39 d0                	cmp    %edx,%eax
f0101996:	74 19                	je     f01019b1 <mem_init+0x774>
f0101998:	68 60 41 10 f0       	push   $0xf0104160
f010199d:	68 82 46 10 f0       	push   $0xf0104682
f01019a2:	68 09 03 00 00       	push   $0x309
f01019a7:	68 4c 46 10 f0       	push   $0xf010464c
f01019ac:	e8 da e6 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f01019b1:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019b6:	74 19                	je     f01019d1 <mem_init+0x794>
f01019b8:	68 2a 48 10 f0       	push   $0xf010482a
f01019bd:	68 82 46 10 f0       	push   $0xf0104682
f01019c2:	68 0a 03 00 00       	push   $0x30a
f01019c7:	68 4c 46 10 f0       	push   $0xf010464c
f01019cc:	e8 ba e6 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f01019d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019d4:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01019d9:	74 19                	je     f01019f4 <mem_init+0x7b7>
f01019db:	68 3b 48 10 f0       	push   $0xf010483b
f01019e0:	68 82 46 10 f0       	push   $0xf0104682
f01019e5:	68 0b 03 00 00       	push   $0x30b
f01019ea:	68 4c 46 10 f0       	push   $0xf010464c
f01019ef:	e8 97 e6 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019f4:	6a 02                	push   $0x2
f01019f6:	68 00 10 00 00       	push   $0x1000
f01019fb:	56                   	push   %esi
f01019fc:	57                   	push   %edi
f01019fd:	e8 aa f7 ff ff       	call   f01011ac <page_insert>
f0101a02:	83 c4 10             	add    $0x10,%esp
f0101a05:	85 c0                	test   %eax,%eax
f0101a07:	74 19                	je     f0101a22 <mem_init+0x7e5>
f0101a09:	68 90 41 10 f0       	push   $0xf0104190
f0101a0e:	68 82 46 10 f0       	push   $0xf0104682
f0101a13:	68 0e 03 00 00       	push   $0x30e
f0101a18:	68 4c 46 10 f0       	push   $0xf010464c
f0101a1d:	e8 69 e6 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a22:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a27:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101a2c:	e8 20 f0 ff ff       	call   f0100a51 <check_va2pa>
f0101a31:	89 f2                	mov    %esi,%edx
f0101a33:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101a39:	c1 fa 03             	sar    $0x3,%edx
f0101a3c:	c1 e2 0c             	shl    $0xc,%edx
f0101a3f:	39 d0                	cmp    %edx,%eax
f0101a41:	74 19                	je     f0101a5c <mem_init+0x81f>
f0101a43:	68 cc 41 10 f0       	push   $0xf01041cc
f0101a48:	68 82 46 10 f0       	push   $0xf0104682
f0101a4d:	68 0f 03 00 00       	push   $0x30f
f0101a52:	68 4c 46 10 f0       	push   $0xf010464c
f0101a57:	e8 2f e6 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101a5c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a61:	74 19                	je     f0101a7c <mem_init+0x83f>
f0101a63:	68 4c 48 10 f0       	push   $0xf010484c
f0101a68:	68 82 46 10 f0       	push   $0xf0104682
f0101a6d:	68 10 03 00 00       	push   $0x310
f0101a72:	68 4c 46 10 f0       	push   $0xf010464c
f0101a77:	e8 0f e6 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101a7c:	83 ec 0c             	sub    $0xc,%esp
f0101a7f:	6a 00                	push   $0x0
f0101a81:	e8 80 f4 ff ff       	call   f0100f06 <page_alloc>
f0101a86:	83 c4 10             	add    $0x10,%esp
f0101a89:	85 c0                	test   %eax,%eax
f0101a8b:	74 19                	je     f0101aa6 <mem_init+0x869>
f0101a8d:	68 d8 47 10 f0       	push   $0xf01047d8
f0101a92:	68 82 46 10 f0       	push   $0xf0104682
f0101a97:	68 13 03 00 00       	push   $0x313
f0101a9c:	68 4c 46 10 f0       	push   $0xf010464c
f0101aa1:	e8 e5 e5 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101aa6:	6a 02                	push   $0x2
f0101aa8:	68 00 10 00 00       	push   $0x1000
f0101aad:	56                   	push   %esi
f0101aae:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101ab4:	e8 f3 f6 ff ff       	call   f01011ac <page_insert>
f0101ab9:	83 c4 10             	add    $0x10,%esp
f0101abc:	85 c0                	test   %eax,%eax
f0101abe:	74 19                	je     f0101ad9 <mem_init+0x89c>
f0101ac0:	68 90 41 10 f0       	push   $0xf0104190
f0101ac5:	68 82 46 10 f0       	push   $0xf0104682
f0101aca:	68 16 03 00 00       	push   $0x316
f0101acf:	68 4c 46 10 f0       	push   $0xf010464c
f0101ad4:	e8 b2 e5 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ad9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ade:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101ae3:	e8 69 ef ff ff       	call   f0100a51 <check_va2pa>
f0101ae8:	89 f2                	mov    %esi,%edx
f0101aea:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101af0:	c1 fa 03             	sar    $0x3,%edx
f0101af3:	c1 e2 0c             	shl    $0xc,%edx
f0101af6:	39 d0                	cmp    %edx,%eax
f0101af8:	74 19                	je     f0101b13 <mem_init+0x8d6>
f0101afa:	68 cc 41 10 f0       	push   $0xf01041cc
f0101aff:	68 82 46 10 f0       	push   $0xf0104682
f0101b04:	68 17 03 00 00       	push   $0x317
f0101b09:	68 4c 46 10 f0       	push   $0xf010464c
f0101b0e:	e8 78 e5 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101b13:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b18:	74 19                	je     f0101b33 <mem_init+0x8f6>
f0101b1a:	68 4c 48 10 f0       	push   $0xf010484c
f0101b1f:	68 82 46 10 f0       	push   $0xf0104682
f0101b24:	68 18 03 00 00       	push   $0x318
f0101b29:	68 4c 46 10 f0       	push   $0xf010464c
f0101b2e:	e8 58 e5 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b33:	83 ec 0c             	sub    $0xc,%esp
f0101b36:	6a 00                	push   $0x0
f0101b38:	e8 c9 f3 ff ff       	call   f0100f06 <page_alloc>
f0101b3d:	83 c4 10             	add    $0x10,%esp
f0101b40:	85 c0                	test   %eax,%eax
f0101b42:	74 19                	je     f0101b5d <mem_init+0x920>
f0101b44:	68 d8 47 10 f0       	push   $0xf01047d8
f0101b49:	68 82 46 10 f0       	push   $0xf0104682
f0101b4e:	68 1c 03 00 00       	push   $0x31c
f0101b53:	68 4c 46 10 f0       	push   $0xf010464c
f0101b58:	e8 2e e5 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101b5d:	8b 15 68 79 11 f0    	mov    0xf0117968,%edx
f0101b63:	8b 02                	mov    (%edx),%eax
f0101b65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b6a:	89 c1                	mov    %eax,%ecx
f0101b6c:	c1 e9 0c             	shr    $0xc,%ecx
f0101b6f:	3b 0d 64 79 11 f0    	cmp    0xf0117964,%ecx
f0101b75:	72 15                	jb     f0101b8c <mem_init+0x94f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b77:	50                   	push   %eax
f0101b78:	68 c4 3e 10 f0       	push   $0xf0103ec4
f0101b7d:	68 1f 03 00 00       	push   $0x31f
f0101b82:	68 4c 46 10 f0       	push   $0xf010464c
f0101b87:	e8 ff e4 ff ff       	call   f010008b <_panic>
f0101b8c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b91:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b94:	83 ec 04             	sub    $0x4,%esp
f0101b97:	6a 00                	push   $0x0
f0101b99:	68 00 10 00 00       	push   $0x1000
f0101b9e:	52                   	push   %edx
f0101b9f:	e8 34 f4 ff ff       	call   f0100fd8 <pgdir_walk>
f0101ba4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101ba7:	8d 51 04             	lea    0x4(%ecx),%edx
f0101baa:	83 c4 10             	add    $0x10,%esp
f0101bad:	39 d0                	cmp    %edx,%eax
f0101baf:	74 19                	je     f0101bca <mem_init+0x98d>
f0101bb1:	68 fc 41 10 f0       	push   $0xf01041fc
f0101bb6:	68 82 46 10 f0       	push   $0xf0104682
f0101bbb:	68 20 03 00 00       	push   $0x320
f0101bc0:	68 4c 46 10 f0       	push   $0xf010464c
f0101bc5:	e8 c1 e4 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101bca:	6a 06                	push   $0x6
f0101bcc:	68 00 10 00 00       	push   $0x1000
f0101bd1:	56                   	push   %esi
f0101bd2:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101bd8:	e8 cf f5 ff ff       	call   f01011ac <page_insert>
f0101bdd:	83 c4 10             	add    $0x10,%esp
f0101be0:	85 c0                	test   %eax,%eax
f0101be2:	74 19                	je     f0101bfd <mem_init+0x9c0>
f0101be4:	68 3c 42 10 f0       	push   $0xf010423c
f0101be9:	68 82 46 10 f0       	push   $0xf0104682
f0101bee:	68 23 03 00 00       	push   $0x323
f0101bf3:	68 4c 46 10 f0       	push   $0xf010464c
f0101bf8:	e8 8e e4 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bfd:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101c03:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c08:	89 f8                	mov    %edi,%eax
f0101c0a:	e8 42 ee ff ff       	call   f0100a51 <check_va2pa>
f0101c0f:	89 f2                	mov    %esi,%edx
f0101c11:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101c17:	c1 fa 03             	sar    $0x3,%edx
f0101c1a:	c1 e2 0c             	shl    $0xc,%edx
f0101c1d:	39 d0                	cmp    %edx,%eax
f0101c1f:	74 19                	je     f0101c3a <mem_init+0x9fd>
f0101c21:	68 cc 41 10 f0       	push   $0xf01041cc
f0101c26:	68 82 46 10 f0       	push   $0xf0104682
f0101c2b:	68 24 03 00 00       	push   $0x324
f0101c30:	68 4c 46 10 f0       	push   $0xf010464c
f0101c35:	e8 51 e4 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101c3a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c3f:	74 19                	je     f0101c5a <mem_init+0xa1d>
f0101c41:	68 4c 48 10 f0       	push   $0xf010484c
f0101c46:	68 82 46 10 f0       	push   $0xf0104682
f0101c4b:	68 25 03 00 00       	push   $0x325
f0101c50:	68 4c 46 10 f0       	push   $0xf010464c
f0101c55:	e8 31 e4 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101c5a:	83 ec 04             	sub    $0x4,%esp
f0101c5d:	6a 00                	push   $0x0
f0101c5f:	68 00 10 00 00       	push   $0x1000
f0101c64:	57                   	push   %edi
f0101c65:	e8 6e f3 ff ff       	call   f0100fd8 <pgdir_walk>
f0101c6a:	83 c4 10             	add    $0x10,%esp
f0101c6d:	f6 00 04             	testb  $0x4,(%eax)
f0101c70:	75 19                	jne    f0101c8b <mem_init+0xa4e>
f0101c72:	68 7c 42 10 f0       	push   $0xf010427c
f0101c77:	68 82 46 10 f0       	push   $0xf0104682
f0101c7c:	68 26 03 00 00       	push   $0x326
f0101c81:	68 4c 46 10 f0       	push   $0xf010464c
f0101c86:	e8 00 e4 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101c8b:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0101c90:	f6 00 04             	testb  $0x4,(%eax)
f0101c93:	75 19                	jne    f0101cae <mem_init+0xa71>
f0101c95:	68 5d 48 10 f0       	push   $0xf010485d
f0101c9a:	68 82 46 10 f0       	push   $0xf0104682
f0101c9f:	68 27 03 00 00       	push   $0x327
f0101ca4:	68 4c 46 10 f0       	push   $0xf010464c
f0101ca9:	e8 dd e3 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101cae:	6a 02                	push   $0x2
f0101cb0:	68 00 10 00 00       	push   $0x1000
f0101cb5:	56                   	push   %esi
f0101cb6:	50                   	push   %eax
f0101cb7:	e8 f0 f4 ff ff       	call   f01011ac <page_insert>
f0101cbc:	83 c4 10             	add    $0x10,%esp
f0101cbf:	85 c0                	test   %eax,%eax
f0101cc1:	74 19                	je     f0101cdc <mem_init+0xa9f>
f0101cc3:	68 90 41 10 f0       	push   $0xf0104190
f0101cc8:	68 82 46 10 f0       	push   $0xf0104682
f0101ccd:	68 2a 03 00 00       	push   $0x32a
f0101cd2:	68 4c 46 10 f0       	push   $0xf010464c
f0101cd7:	e8 af e3 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101cdc:	83 ec 04             	sub    $0x4,%esp
f0101cdf:	6a 00                	push   $0x0
f0101ce1:	68 00 10 00 00       	push   $0x1000
f0101ce6:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101cec:	e8 e7 f2 ff ff       	call   f0100fd8 <pgdir_walk>
f0101cf1:	83 c4 10             	add    $0x10,%esp
f0101cf4:	f6 00 02             	testb  $0x2,(%eax)
f0101cf7:	75 19                	jne    f0101d12 <mem_init+0xad5>
f0101cf9:	68 b0 42 10 f0       	push   $0xf01042b0
f0101cfe:	68 82 46 10 f0       	push   $0xf0104682
f0101d03:	68 2b 03 00 00       	push   $0x32b
f0101d08:	68 4c 46 10 f0       	push   $0xf010464c
f0101d0d:	e8 79 e3 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d12:	83 ec 04             	sub    $0x4,%esp
f0101d15:	6a 00                	push   $0x0
f0101d17:	68 00 10 00 00       	push   $0x1000
f0101d1c:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101d22:	e8 b1 f2 ff ff       	call   f0100fd8 <pgdir_walk>
f0101d27:	83 c4 10             	add    $0x10,%esp
f0101d2a:	f6 00 04             	testb  $0x4,(%eax)
f0101d2d:	74 19                	je     f0101d48 <mem_init+0xb0b>
f0101d2f:	68 e4 42 10 f0       	push   $0xf01042e4
f0101d34:	68 82 46 10 f0       	push   $0xf0104682
f0101d39:	68 2c 03 00 00       	push   $0x32c
f0101d3e:	68 4c 46 10 f0       	push   $0xf010464c
f0101d43:	e8 43 e3 ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101d48:	6a 02                	push   $0x2
f0101d4a:	68 00 00 40 00       	push   $0x400000
f0101d4f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d52:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101d58:	e8 4f f4 ff ff       	call   f01011ac <page_insert>
f0101d5d:	83 c4 10             	add    $0x10,%esp
f0101d60:	85 c0                	test   %eax,%eax
f0101d62:	78 19                	js     f0101d7d <mem_init+0xb40>
f0101d64:	68 1c 43 10 f0       	push   $0xf010431c
f0101d69:	68 82 46 10 f0       	push   $0xf0104682
f0101d6e:	68 2f 03 00 00       	push   $0x32f
f0101d73:	68 4c 46 10 f0       	push   $0xf010464c
f0101d78:	e8 0e e3 ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101d7d:	6a 02                	push   $0x2
f0101d7f:	68 00 10 00 00       	push   $0x1000
f0101d84:	53                   	push   %ebx
f0101d85:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101d8b:	e8 1c f4 ff ff       	call   f01011ac <page_insert>
f0101d90:	83 c4 10             	add    $0x10,%esp
f0101d93:	85 c0                	test   %eax,%eax
f0101d95:	74 19                	je     f0101db0 <mem_init+0xb73>
f0101d97:	68 54 43 10 f0       	push   $0xf0104354
f0101d9c:	68 82 46 10 f0       	push   $0xf0104682
f0101da1:	68 32 03 00 00       	push   $0x332
f0101da6:	68 4c 46 10 f0       	push   $0xf010464c
f0101dab:	e8 db e2 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101db0:	83 ec 04             	sub    $0x4,%esp
f0101db3:	6a 00                	push   $0x0
f0101db5:	68 00 10 00 00       	push   $0x1000
f0101dba:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101dc0:	e8 13 f2 ff ff       	call   f0100fd8 <pgdir_walk>
f0101dc5:	83 c4 10             	add    $0x10,%esp
f0101dc8:	f6 00 04             	testb  $0x4,(%eax)
f0101dcb:	74 19                	je     f0101de6 <mem_init+0xba9>
f0101dcd:	68 e4 42 10 f0       	push   $0xf01042e4
f0101dd2:	68 82 46 10 f0       	push   $0xf0104682
f0101dd7:	68 33 03 00 00       	push   $0x333
f0101ddc:	68 4c 46 10 f0       	push   $0xf010464c
f0101de1:	e8 a5 e2 ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101de6:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101dec:	ba 00 00 00 00       	mov    $0x0,%edx
f0101df1:	89 f8                	mov    %edi,%eax
f0101df3:	e8 59 ec ff ff       	call   f0100a51 <check_va2pa>
f0101df8:	89 c1                	mov    %eax,%ecx
f0101dfa:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101dfd:	89 d8                	mov    %ebx,%eax
f0101dff:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0101e05:	c1 f8 03             	sar    $0x3,%eax
f0101e08:	c1 e0 0c             	shl    $0xc,%eax
f0101e0b:	39 c1                	cmp    %eax,%ecx
f0101e0d:	74 19                	je     f0101e28 <mem_init+0xbeb>
f0101e0f:	68 90 43 10 f0       	push   $0xf0104390
f0101e14:	68 82 46 10 f0       	push   $0xf0104682
f0101e19:	68 36 03 00 00       	push   $0x336
f0101e1e:	68 4c 46 10 f0       	push   $0xf010464c
f0101e23:	e8 63 e2 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e28:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e2d:	89 f8                	mov    %edi,%eax
f0101e2f:	e8 1d ec ff ff       	call   f0100a51 <check_va2pa>
f0101e34:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101e37:	74 19                	je     f0101e52 <mem_init+0xc15>
f0101e39:	68 bc 43 10 f0       	push   $0xf01043bc
f0101e3e:	68 82 46 10 f0       	push   $0xf0104682
f0101e43:	68 37 03 00 00       	push   $0x337
f0101e48:	68 4c 46 10 f0       	push   $0xf010464c
f0101e4d:	e8 39 e2 ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101e52:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101e57:	74 19                	je     f0101e72 <mem_init+0xc35>
f0101e59:	68 73 48 10 f0       	push   $0xf0104873
f0101e5e:	68 82 46 10 f0       	push   $0xf0104682
f0101e63:	68 39 03 00 00       	push   $0x339
f0101e68:	68 4c 46 10 f0       	push   $0xf010464c
f0101e6d:	e8 19 e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101e72:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e77:	74 19                	je     f0101e92 <mem_init+0xc55>
f0101e79:	68 84 48 10 f0       	push   $0xf0104884
f0101e7e:	68 82 46 10 f0       	push   $0xf0104682
f0101e83:	68 3a 03 00 00       	push   $0x33a
f0101e88:	68 4c 46 10 f0       	push   $0xf010464c
f0101e8d:	e8 f9 e1 ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e92:	83 ec 0c             	sub    $0xc,%esp
f0101e95:	6a 00                	push   $0x0
f0101e97:	e8 6a f0 ff ff       	call   f0100f06 <page_alloc>
f0101e9c:	83 c4 10             	add    $0x10,%esp
f0101e9f:	85 c0                	test   %eax,%eax
f0101ea1:	74 04                	je     f0101ea7 <mem_init+0xc6a>
f0101ea3:	39 c6                	cmp    %eax,%esi
f0101ea5:	74 19                	je     f0101ec0 <mem_init+0xc83>
f0101ea7:	68 ec 43 10 f0       	push   $0xf01043ec
f0101eac:	68 82 46 10 f0       	push   $0xf0104682
f0101eb1:	68 3d 03 00 00       	push   $0x33d
f0101eb6:	68 4c 46 10 f0       	push   $0xf010464c
f0101ebb:	e8 cb e1 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101ec0:	83 ec 08             	sub    $0x8,%esp
f0101ec3:	6a 00                	push   $0x0
f0101ec5:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101ecb:	e8 a1 f2 ff ff       	call   f0101171 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ed0:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101ed6:	ba 00 00 00 00       	mov    $0x0,%edx
f0101edb:	89 f8                	mov    %edi,%eax
f0101edd:	e8 6f eb ff ff       	call   f0100a51 <check_va2pa>
f0101ee2:	83 c4 10             	add    $0x10,%esp
f0101ee5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101ee8:	74 19                	je     f0101f03 <mem_init+0xcc6>
f0101eea:	68 10 44 10 f0       	push   $0xf0104410
f0101eef:	68 82 46 10 f0       	push   $0xf0104682
f0101ef4:	68 41 03 00 00       	push   $0x341
f0101ef9:	68 4c 46 10 f0       	push   $0xf010464c
f0101efe:	e8 88 e1 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f03:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f08:	89 f8                	mov    %edi,%eax
f0101f0a:	e8 42 eb ff ff       	call   f0100a51 <check_va2pa>
f0101f0f:	89 da                	mov    %ebx,%edx
f0101f11:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f0101f17:	c1 fa 03             	sar    $0x3,%edx
f0101f1a:	c1 e2 0c             	shl    $0xc,%edx
f0101f1d:	39 d0                	cmp    %edx,%eax
f0101f1f:	74 19                	je     f0101f3a <mem_init+0xcfd>
f0101f21:	68 bc 43 10 f0       	push   $0xf01043bc
f0101f26:	68 82 46 10 f0       	push   $0xf0104682
f0101f2b:	68 42 03 00 00       	push   $0x342
f0101f30:	68 4c 46 10 f0       	push   $0xf010464c
f0101f35:	e8 51 e1 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101f3a:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f3f:	74 19                	je     f0101f5a <mem_init+0xd1d>
f0101f41:	68 2a 48 10 f0       	push   $0xf010482a
f0101f46:	68 82 46 10 f0       	push   $0xf0104682
f0101f4b:	68 43 03 00 00       	push   $0x343
f0101f50:	68 4c 46 10 f0       	push   $0xf010464c
f0101f55:	e8 31 e1 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101f5a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101f5f:	74 19                	je     f0101f7a <mem_init+0xd3d>
f0101f61:	68 84 48 10 f0       	push   $0xf0104884
f0101f66:	68 82 46 10 f0       	push   $0xf0104682
f0101f6b:	68 44 03 00 00       	push   $0x344
f0101f70:	68 4c 46 10 f0       	push   $0xf010464c
f0101f75:	e8 11 e1 ff ff       	call   f010008b <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f7a:	6a 00                	push   $0x0
f0101f7c:	68 00 10 00 00       	push   $0x1000
f0101f81:	53                   	push   %ebx
f0101f82:	57                   	push   %edi
f0101f83:	e8 24 f2 ff ff       	call   f01011ac <page_insert>
f0101f88:	83 c4 10             	add    $0x10,%esp
f0101f8b:	85 c0                	test   %eax,%eax
f0101f8d:	74 19                	je     f0101fa8 <mem_init+0xd6b>
f0101f8f:	68 34 44 10 f0       	push   $0xf0104434
f0101f94:	68 82 46 10 f0       	push   $0xf0104682
f0101f99:	68 47 03 00 00       	push   $0x347
f0101f9e:	68 4c 46 10 f0       	push   $0xf010464c
f0101fa3:	e8 e3 e0 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f0101fa8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101fad:	75 19                	jne    f0101fc8 <mem_init+0xd8b>
f0101faf:	68 95 48 10 f0       	push   $0xf0104895
f0101fb4:	68 82 46 10 f0       	push   $0xf0104682
f0101fb9:	68 48 03 00 00       	push   $0x348
f0101fbe:	68 4c 46 10 f0       	push   $0xf010464c
f0101fc3:	e8 c3 e0 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f0101fc8:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101fcb:	74 19                	je     f0101fe6 <mem_init+0xda9>
f0101fcd:	68 a1 48 10 f0       	push   $0xf01048a1
f0101fd2:	68 82 46 10 f0       	push   $0xf0104682
f0101fd7:	68 49 03 00 00       	push   $0x349
f0101fdc:	68 4c 46 10 f0       	push   $0xf010464c
f0101fe1:	e8 a5 e0 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101fe6:	83 ec 08             	sub    $0x8,%esp
f0101fe9:	68 00 10 00 00       	push   $0x1000
f0101fee:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0101ff4:	e8 78 f1 ff ff       	call   f0101171 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ff9:	8b 3d 68 79 11 f0    	mov    0xf0117968,%edi
f0101fff:	ba 00 00 00 00       	mov    $0x0,%edx
f0102004:	89 f8                	mov    %edi,%eax
f0102006:	e8 46 ea ff ff       	call   f0100a51 <check_va2pa>
f010200b:	83 c4 10             	add    $0x10,%esp
f010200e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102011:	74 19                	je     f010202c <mem_init+0xdef>
f0102013:	68 10 44 10 f0       	push   $0xf0104410
f0102018:	68 82 46 10 f0       	push   $0xf0104682
f010201d:	68 4d 03 00 00       	push   $0x34d
f0102022:	68 4c 46 10 f0       	push   $0xf010464c
f0102027:	e8 5f e0 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010202c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102031:	89 f8                	mov    %edi,%eax
f0102033:	e8 19 ea ff ff       	call   f0100a51 <check_va2pa>
f0102038:	83 f8 ff             	cmp    $0xffffffff,%eax
f010203b:	74 19                	je     f0102056 <mem_init+0xe19>
f010203d:	68 6c 44 10 f0       	push   $0xf010446c
f0102042:	68 82 46 10 f0       	push   $0xf0104682
f0102047:	68 4e 03 00 00       	push   $0x34e
f010204c:	68 4c 46 10 f0       	push   $0xf010464c
f0102051:	e8 35 e0 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0102056:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010205b:	74 19                	je     f0102076 <mem_init+0xe39>
f010205d:	68 b6 48 10 f0       	push   $0xf01048b6
f0102062:	68 82 46 10 f0       	push   $0xf0104682
f0102067:	68 4f 03 00 00       	push   $0x34f
f010206c:	68 4c 46 10 f0       	push   $0xf010464c
f0102071:	e8 15 e0 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0102076:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010207b:	74 19                	je     f0102096 <mem_init+0xe59>
f010207d:	68 84 48 10 f0       	push   $0xf0104884
f0102082:	68 82 46 10 f0       	push   $0xf0104682
f0102087:	68 50 03 00 00       	push   $0x350
f010208c:	68 4c 46 10 f0       	push   $0xf010464c
f0102091:	e8 f5 df ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102096:	83 ec 0c             	sub    $0xc,%esp
f0102099:	6a 00                	push   $0x0
f010209b:	e8 66 ee ff ff       	call   f0100f06 <page_alloc>
f01020a0:	83 c4 10             	add    $0x10,%esp
f01020a3:	39 c3                	cmp    %eax,%ebx
f01020a5:	75 04                	jne    f01020ab <mem_init+0xe6e>
f01020a7:	85 c0                	test   %eax,%eax
f01020a9:	75 19                	jne    f01020c4 <mem_init+0xe87>
f01020ab:	68 94 44 10 f0       	push   $0xf0104494
f01020b0:	68 82 46 10 f0       	push   $0xf0104682
f01020b5:	68 53 03 00 00       	push   $0x353
f01020ba:	68 4c 46 10 f0       	push   $0xf010464c
f01020bf:	e8 c7 df ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01020c4:	83 ec 0c             	sub    $0xc,%esp
f01020c7:	6a 00                	push   $0x0
f01020c9:	e8 38 ee ff ff       	call   f0100f06 <page_alloc>
f01020ce:	83 c4 10             	add    $0x10,%esp
f01020d1:	85 c0                	test   %eax,%eax
f01020d3:	74 19                	je     f01020ee <mem_init+0xeb1>
f01020d5:	68 d8 47 10 f0       	push   $0xf01047d8
f01020da:	68 82 46 10 f0       	push   $0xf0104682
f01020df:	68 56 03 00 00       	push   $0x356
f01020e4:	68 4c 46 10 f0       	push   $0xf010464c
f01020e9:	e8 9d df ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01020ee:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f01020f4:	8b 11                	mov    (%ecx),%edx
f01020f6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01020fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020ff:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102105:	c1 f8 03             	sar    $0x3,%eax
f0102108:	c1 e0 0c             	shl    $0xc,%eax
f010210b:	39 c2                	cmp    %eax,%edx
f010210d:	74 19                	je     f0102128 <mem_init+0xeeb>
f010210f:	68 38 41 10 f0       	push   $0xf0104138
f0102114:	68 82 46 10 f0       	push   $0xf0104682
f0102119:	68 59 03 00 00       	push   $0x359
f010211e:	68 4c 46 10 f0       	push   $0xf010464c
f0102123:	e8 63 df ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102128:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010212e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102131:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102136:	74 19                	je     f0102151 <mem_init+0xf14>
f0102138:	68 3b 48 10 f0       	push   $0xf010483b
f010213d:	68 82 46 10 f0       	push   $0xf0104682
f0102142:	68 5b 03 00 00       	push   $0x35b
f0102147:	68 4c 46 10 f0       	push   $0xf010464c
f010214c:	e8 3a df ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0102151:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102154:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010215a:	83 ec 0c             	sub    $0xc,%esp
f010215d:	50                   	push   %eax
f010215e:	e8 13 ee ff ff       	call   f0100f76 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102163:	83 c4 0c             	add    $0xc,%esp
f0102166:	6a 01                	push   $0x1
f0102168:	68 00 10 40 00       	push   $0x401000
f010216d:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0102173:	e8 60 ee ff ff       	call   f0100fd8 <pgdir_walk>
f0102178:	89 c7                	mov    %eax,%edi
f010217a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010217d:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102182:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102185:	8b 40 04             	mov    0x4(%eax),%eax
f0102188:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010218d:	8b 0d 64 79 11 f0    	mov    0xf0117964,%ecx
f0102193:	89 c2                	mov    %eax,%edx
f0102195:	c1 ea 0c             	shr    $0xc,%edx
f0102198:	83 c4 10             	add    $0x10,%esp
f010219b:	39 ca                	cmp    %ecx,%edx
f010219d:	72 15                	jb     f01021b4 <mem_init+0xf77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010219f:	50                   	push   %eax
f01021a0:	68 c4 3e 10 f0       	push   $0xf0103ec4
f01021a5:	68 62 03 00 00       	push   $0x362
f01021aa:	68 4c 46 10 f0       	push   $0xf010464c
f01021af:	e8 d7 de ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f01021b4:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f01021b9:	39 c7                	cmp    %eax,%edi
f01021bb:	74 19                	je     f01021d6 <mem_init+0xf99>
f01021bd:	68 c7 48 10 f0       	push   $0xf01048c7
f01021c2:	68 82 46 10 f0       	push   $0xf0104682
f01021c7:	68 63 03 00 00       	push   $0x363
f01021cc:	68 4c 46 10 f0       	push   $0xf010464c
f01021d1:	e8 b5 de ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f01021d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01021d9:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f01021e0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021e3:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01021e9:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01021ef:	c1 f8 03             	sar    $0x3,%eax
f01021f2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021f5:	89 c2                	mov    %eax,%edx
f01021f7:	c1 ea 0c             	shr    $0xc,%edx
f01021fa:	39 d1                	cmp    %edx,%ecx
f01021fc:	77 12                	ja     f0102210 <mem_init+0xfd3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021fe:	50                   	push   %eax
f01021ff:	68 c4 3e 10 f0       	push   $0xf0103ec4
f0102204:	6a 52                	push   $0x52
f0102206:	68 68 46 10 f0       	push   $0xf0104668
f010220b:	e8 7b de ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102210:	83 ec 04             	sub    $0x4,%esp
f0102213:	68 00 10 00 00       	push   $0x1000
f0102218:	68 ff 00 00 00       	push   $0xff
f010221d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102222:	50                   	push   %eax
f0102223:	e8 e0 11 00 00       	call   f0103408 <memset>
	page_free(pp0);
f0102228:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010222b:	89 3c 24             	mov    %edi,(%esp)
f010222e:	e8 43 ed ff ff       	call   f0100f76 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102233:	83 c4 0c             	add    $0xc,%esp
f0102236:	6a 01                	push   $0x1
f0102238:	6a 00                	push   $0x0
f010223a:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0102240:	e8 93 ed ff ff       	call   f0100fd8 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102245:	89 fa                	mov    %edi,%edx
f0102247:	2b 15 6c 79 11 f0    	sub    0xf011796c,%edx
f010224d:	c1 fa 03             	sar    $0x3,%edx
f0102250:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102253:	89 d0                	mov    %edx,%eax
f0102255:	c1 e8 0c             	shr    $0xc,%eax
f0102258:	83 c4 10             	add    $0x10,%esp
f010225b:	3b 05 64 79 11 f0    	cmp    0xf0117964,%eax
f0102261:	72 12                	jb     f0102275 <mem_init+0x1038>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102263:	52                   	push   %edx
f0102264:	68 c4 3e 10 f0       	push   $0xf0103ec4
f0102269:	6a 52                	push   $0x52
f010226b:	68 68 46 10 f0       	push   $0xf0104668
f0102270:	e8 16 de ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0102275:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010227b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010227e:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102284:	f6 00 01             	testb  $0x1,(%eax)
f0102287:	74 19                	je     f01022a2 <mem_init+0x1065>
f0102289:	68 df 48 10 f0       	push   $0xf01048df
f010228e:	68 82 46 10 f0       	push   $0xf0104682
f0102293:	68 6d 03 00 00       	push   $0x36d
f0102298:	68 4c 46 10 f0       	push   $0xf010464c
f010229d:	e8 e9 dd ff ff       	call   f010008b <_panic>
f01022a2:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01022a5:	39 d0                	cmp    %edx,%eax
f01022a7:	75 db                	jne    f0102284 <mem_init+0x1047>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01022a9:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f01022ae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01022b4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022b7:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f01022bd:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01022c0:	89 0d 3c 75 11 f0    	mov    %ecx,0xf011753c

	// free the pages we took
	page_free(pp0);
f01022c6:	83 ec 0c             	sub    $0xc,%esp
f01022c9:	50                   	push   %eax
f01022ca:	e8 a7 ec ff ff       	call   f0100f76 <page_free>
	page_free(pp1);
f01022cf:	89 1c 24             	mov    %ebx,(%esp)
f01022d2:	e8 9f ec ff ff       	call   f0100f76 <page_free>
	page_free(pp2);
f01022d7:	89 34 24             	mov    %esi,(%esp)
f01022da:	e8 97 ec ff ff       	call   f0100f76 <page_free>

	cprintf("check_page() succeeded!\n");
f01022df:	c7 04 24 f6 48 10 f0 	movl   $0xf01048f6,(%esp)
f01022e6:	e8 59 06 00 00       	call   f0102944 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,(uintptr_t)UPAGES,ROUNDUP((npages*sizeof(struct PageInfo)),PGSIZE),PADDR(pages),PTE_U|PTE_P);
f01022eb:	a1 6c 79 11 f0       	mov    0xf011796c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022f0:	83 c4 10             	add    $0x10,%esp
f01022f3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022f8:	77 15                	ja     f010230f <mem_init+0x10d2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022fa:	50                   	push   %eax
f01022fb:	68 e8 3e 10 f0       	push   $0xf0103ee8
f0102300:	68 b4 00 00 00       	push   $0xb4
f0102305:	68 4c 46 10 f0       	push   $0xf010464c
f010230a:	e8 7c dd ff ff       	call   f010008b <_panic>
f010230f:	8b 15 64 79 11 f0    	mov    0xf0117964,%edx
f0102315:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f010231c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102322:	83 ec 08             	sub    $0x8,%esp
f0102325:	6a 05                	push   $0x5
f0102327:	05 00 00 00 10       	add    $0x10000000,%eax
f010232c:	50                   	push   %eax
f010232d:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102332:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102337:	e8 7b ed ff ff       	call   f01010b7 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010233c:	83 c4 10             	add    $0x10,%esp
f010233f:	b8 00 d0 10 f0       	mov    $0xf010d000,%eax
f0102344:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102349:	77 15                	ja     f0102360 <mem_init+0x1123>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010234b:	50                   	push   %eax
f010234c:	68 e8 3e 10 f0       	push   $0xf0103ee8
f0102351:	68 c0 00 00 00       	push   $0xc0
f0102356:	68 4c 46 10 f0       	push   $0xf010464c
f010235b:	e8 2b dd ff ff       	call   f010008b <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,(uintptr_t)(KSTACKTOP-KSTKSIZE),KSTKSIZE,PADDR(bootstack),PTE_W|PTE_P);
f0102360:	83 ec 08             	sub    $0x8,%esp
f0102363:	6a 03                	push   $0x3
f0102365:	68 00 d0 10 00       	push   $0x10d000
f010236a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010236f:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102374:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102379:	e8 39 ed ff ff       	call   f01010b7 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir,(uintptr_t)KERNBASE,ROUNDUP(0xffffffff-KERNBASE,PGSIZE),0,PTE_W|PTE_P);
f010237e:	83 c4 08             	add    $0x8,%esp
f0102381:	6a 03                	push   $0x3
f0102383:	6a 00                	push   $0x0
f0102385:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010238a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010238f:	a1 68 79 11 f0       	mov    0xf0117968,%eax
f0102394:	e8 1e ed ff ff       	call   f01010b7 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102399:	8b 35 68 79 11 f0    	mov    0xf0117968,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010239f:	a1 64 79 11 f0       	mov    0xf0117964,%eax
f01023a4:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01023a7:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01023ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01023b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01023b6:	8b 3d 6c 79 11 f0    	mov    0xf011796c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01023bc:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01023bf:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01023c2:	bb 00 00 00 00       	mov    $0x0,%ebx
f01023c7:	eb 55                	jmp    f010241e <mem_init+0x11e1>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01023c9:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01023cf:	89 f0                	mov    %esi,%eax
f01023d1:	e8 7b e6 ff ff       	call   f0100a51 <check_va2pa>
f01023d6:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01023dd:	77 15                	ja     f01023f4 <mem_init+0x11b7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01023df:	57                   	push   %edi
f01023e0:	68 e8 3e 10 f0       	push   $0xf0103ee8
f01023e5:	68 af 02 00 00       	push   $0x2af
f01023ea:	68 4c 46 10 f0       	push   $0xf010464c
f01023ef:	e8 97 dc ff ff       	call   f010008b <_panic>
f01023f4:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f01023fb:	39 c2                	cmp    %eax,%edx
f01023fd:	74 19                	je     f0102418 <mem_init+0x11db>
f01023ff:	68 b8 44 10 f0       	push   $0xf01044b8
f0102404:	68 82 46 10 f0       	push   $0xf0104682
f0102409:	68 af 02 00 00       	push   $0x2af
f010240e:	68 4c 46 10 f0       	push   $0xf010464c
f0102413:	e8 73 dc ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102418:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010241e:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102421:	77 a6                	ja     f01023c9 <mem_init+0x118c>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102423:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102426:	c1 e7 0c             	shl    $0xc,%edi
f0102429:	bb 00 00 00 00       	mov    $0x0,%ebx
f010242e:	eb 30                	jmp    f0102460 <mem_init+0x1223>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102430:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102436:	89 f0                	mov    %esi,%eax
f0102438:	e8 14 e6 ff ff       	call   f0100a51 <check_va2pa>
f010243d:	39 c3                	cmp    %eax,%ebx
f010243f:	74 19                	je     f010245a <mem_init+0x121d>
f0102441:	68 ec 44 10 f0       	push   $0xf01044ec
f0102446:	68 82 46 10 f0       	push   $0xf0104682
f010244b:	68 b4 02 00 00       	push   $0x2b4
f0102450:	68 4c 46 10 f0       	push   $0xf010464c
f0102455:	e8 31 dc ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010245a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102460:	39 fb                	cmp    %edi,%ebx
f0102462:	72 cc                	jb     f0102430 <mem_init+0x11f3>
f0102464:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102469:	89 da                	mov    %ebx,%edx
f010246b:	89 f0                	mov    %esi,%eax
f010246d:	e8 df e5 ff ff       	call   f0100a51 <check_va2pa>
f0102472:	8d 93 00 50 11 10    	lea    0x10115000(%ebx),%edx
f0102478:	39 c2                	cmp    %eax,%edx
f010247a:	74 19                	je     f0102495 <mem_init+0x1258>
f010247c:	68 14 45 10 f0       	push   $0xf0104514
f0102481:	68 82 46 10 f0       	push   $0xf0104682
f0102486:	68 b8 02 00 00       	push   $0x2b8
f010248b:	68 4c 46 10 f0       	push   $0xf010464c
f0102490:	e8 f6 db ff ff       	call   f010008b <_panic>
f0102495:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010249b:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f01024a1:	75 c6                	jne    f0102469 <mem_init+0x122c>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01024a3:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01024a8:	89 f0                	mov    %esi,%eax
f01024aa:	e8 a2 e5 ff ff       	call   f0100a51 <check_va2pa>
f01024af:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024b2:	74 51                	je     f0102505 <mem_init+0x12c8>
f01024b4:	68 5c 45 10 f0       	push   $0xf010455c
f01024b9:	68 82 46 10 f0       	push   $0xf0104682
f01024be:	68 b9 02 00 00       	push   $0x2b9
f01024c3:	68 4c 46 10 f0       	push   $0xf010464c
f01024c8:	e8 be db ff ff       	call   f010008b <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01024cd:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01024d2:	72 36                	jb     f010250a <mem_init+0x12cd>
f01024d4:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01024d9:	76 07                	jbe    f01024e2 <mem_init+0x12a5>
f01024db:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01024e0:	75 28                	jne    f010250a <mem_init+0x12cd>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f01024e2:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f01024e6:	0f 85 83 00 00 00    	jne    f010256f <mem_init+0x1332>
f01024ec:	68 0f 49 10 f0       	push   $0xf010490f
f01024f1:	68 82 46 10 f0       	push   $0xf0104682
f01024f6:	68 c1 02 00 00       	push   $0x2c1
f01024fb:	68 4c 46 10 f0       	push   $0xf010464c
f0102500:	e8 86 db ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102505:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010250a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010250f:	76 3f                	jbe    f0102550 <mem_init+0x1313>
				assert(pgdir[i] & PTE_P);
f0102511:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102514:	f6 c2 01             	test   $0x1,%dl
f0102517:	75 19                	jne    f0102532 <mem_init+0x12f5>
f0102519:	68 0f 49 10 f0       	push   $0xf010490f
f010251e:	68 82 46 10 f0       	push   $0xf0104682
f0102523:	68 c5 02 00 00       	push   $0x2c5
f0102528:	68 4c 46 10 f0       	push   $0xf010464c
f010252d:	e8 59 db ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f0102532:	f6 c2 02             	test   $0x2,%dl
f0102535:	75 38                	jne    f010256f <mem_init+0x1332>
f0102537:	68 20 49 10 f0       	push   $0xf0104920
f010253c:	68 82 46 10 f0       	push   $0xf0104682
f0102541:	68 c6 02 00 00       	push   $0x2c6
f0102546:	68 4c 46 10 f0       	push   $0xf010464c
f010254b:	e8 3b db ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f0102550:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102554:	74 19                	je     f010256f <mem_init+0x1332>
f0102556:	68 31 49 10 f0       	push   $0xf0104931
f010255b:	68 82 46 10 f0       	push   $0xf0104682
f0102560:	68 c8 02 00 00       	push   $0x2c8
f0102565:	68 4c 46 10 f0       	push   $0xf010464c
f010256a:	e8 1c db ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010256f:	83 c0 01             	add    $0x1,%eax
f0102572:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102577:	0f 86 50 ff ff ff    	jbe    f01024cd <mem_init+0x1290>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010257d:	83 ec 0c             	sub    $0xc,%esp
f0102580:	68 8c 45 10 f0       	push   $0xf010458c
f0102585:	e8 ba 03 00 00       	call   f0102944 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010258a:	a1 68 79 11 f0       	mov    0xf0117968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010258f:	83 c4 10             	add    $0x10,%esp
f0102592:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102597:	77 15                	ja     f01025ae <mem_init+0x1371>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102599:	50                   	push   %eax
f010259a:	68 e8 3e 10 f0       	push   $0xf0103ee8
f010259f:	68 d4 00 00 00       	push   $0xd4
f01025a4:	68 4c 46 10 f0       	push   $0xf010464c
f01025a9:	e8 dd da ff ff       	call   f010008b <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01025ae:	05 00 00 00 10       	add    $0x10000000,%eax
f01025b3:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01025b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01025bb:	e8 7e e5 ff ff       	call   f0100b3e <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f01025c0:	0f 20 c0             	mov    %cr0,%eax
f01025c3:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f01025c6:	0d 23 00 05 80       	or     $0x80050023,%eax
f01025cb:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01025ce:	83 ec 0c             	sub    $0xc,%esp
f01025d1:	6a 00                	push   $0x0
f01025d3:	e8 2e e9 ff ff       	call   f0100f06 <page_alloc>
f01025d8:	89 c3                	mov    %eax,%ebx
f01025da:	83 c4 10             	add    $0x10,%esp
f01025dd:	85 c0                	test   %eax,%eax
f01025df:	75 19                	jne    f01025fa <mem_init+0x13bd>
f01025e1:	68 2d 47 10 f0       	push   $0xf010472d
f01025e6:	68 82 46 10 f0       	push   $0xf0104682
f01025eb:	68 88 03 00 00       	push   $0x388
f01025f0:	68 4c 46 10 f0       	push   $0xf010464c
f01025f5:	e8 91 da ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01025fa:	83 ec 0c             	sub    $0xc,%esp
f01025fd:	6a 00                	push   $0x0
f01025ff:	e8 02 e9 ff ff       	call   f0100f06 <page_alloc>
f0102604:	89 c7                	mov    %eax,%edi
f0102606:	83 c4 10             	add    $0x10,%esp
f0102609:	85 c0                	test   %eax,%eax
f010260b:	75 19                	jne    f0102626 <mem_init+0x13e9>
f010260d:	68 43 47 10 f0       	push   $0xf0104743
f0102612:	68 82 46 10 f0       	push   $0xf0104682
f0102617:	68 89 03 00 00       	push   $0x389
f010261c:	68 4c 46 10 f0       	push   $0xf010464c
f0102621:	e8 65 da ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0102626:	83 ec 0c             	sub    $0xc,%esp
f0102629:	6a 00                	push   $0x0
f010262b:	e8 d6 e8 ff ff       	call   f0100f06 <page_alloc>
f0102630:	89 c6                	mov    %eax,%esi
f0102632:	83 c4 10             	add    $0x10,%esp
f0102635:	85 c0                	test   %eax,%eax
f0102637:	75 19                	jne    f0102652 <mem_init+0x1415>
f0102639:	68 59 47 10 f0       	push   $0xf0104759
f010263e:	68 82 46 10 f0       	push   $0xf0104682
f0102643:	68 8a 03 00 00       	push   $0x38a
f0102648:	68 4c 46 10 f0       	push   $0xf010464c
f010264d:	e8 39 da ff ff       	call   f010008b <_panic>
	page_free(pp0);
f0102652:	83 ec 0c             	sub    $0xc,%esp
f0102655:	53                   	push   %ebx
f0102656:	e8 1b e9 ff ff       	call   f0100f76 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010265b:	89 f8                	mov    %edi,%eax
f010265d:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102663:	c1 f8 03             	sar    $0x3,%eax
f0102666:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102669:	89 c2                	mov    %eax,%edx
f010266b:	c1 ea 0c             	shr    $0xc,%edx
f010266e:	83 c4 10             	add    $0x10,%esp
f0102671:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f0102677:	72 12                	jb     f010268b <mem_init+0x144e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102679:	50                   	push   %eax
f010267a:	68 c4 3e 10 f0       	push   $0xf0103ec4
f010267f:	6a 52                	push   $0x52
f0102681:	68 68 46 10 f0       	push   $0xf0104668
f0102686:	e8 00 da ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010268b:	83 ec 04             	sub    $0x4,%esp
f010268e:	68 00 10 00 00       	push   $0x1000
f0102693:	6a 01                	push   $0x1
f0102695:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010269a:	50                   	push   %eax
f010269b:	e8 68 0d 00 00       	call   f0103408 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026a0:	89 f0                	mov    %esi,%eax
f01026a2:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01026a8:	c1 f8 03             	sar    $0x3,%eax
f01026ab:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026ae:	89 c2                	mov    %eax,%edx
f01026b0:	c1 ea 0c             	shr    $0xc,%edx
f01026b3:	83 c4 10             	add    $0x10,%esp
f01026b6:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f01026bc:	72 12                	jb     f01026d0 <mem_init+0x1493>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026be:	50                   	push   %eax
f01026bf:	68 c4 3e 10 f0       	push   $0xf0103ec4
f01026c4:	6a 52                	push   $0x52
f01026c6:	68 68 46 10 f0       	push   $0xf0104668
f01026cb:	e8 bb d9 ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01026d0:	83 ec 04             	sub    $0x4,%esp
f01026d3:	68 00 10 00 00       	push   $0x1000
f01026d8:	6a 02                	push   $0x2
f01026da:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026df:	50                   	push   %eax
f01026e0:	e8 23 0d 00 00       	call   f0103408 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01026e5:	6a 02                	push   $0x2
f01026e7:	68 00 10 00 00       	push   $0x1000
f01026ec:	57                   	push   %edi
f01026ed:	ff 35 68 79 11 f0    	pushl  0xf0117968
f01026f3:	e8 b4 ea ff ff       	call   f01011ac <page_insert>
	assert(pp1->pp_ref == 1);
f01026f8:	83 c4 20             	add    $0x20,%esp
f01026fb:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102700:	74 19                	je     f010271b <mem_init+0x14de>
f0102702:	68 2a 48 10 f0       	push   $0xf010482a
f0102707:	68 82 46 10 f0       	push   $0xf0104682
f010270c:	68 8f 03 00 00       	push   $0x38f
f0102711:	68 4c 46 10 f0       	push   $0xf010464c
f0102716:	e8 70 d9 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010271b:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102722:	01 01 01 
f0102725:	74 19                	je     f0102740 <mem_init+0x1503>
f0102727:	68 ac 45 10 f0       	push   $0xf01045ac
f010272c:	68 82 46 10 f0       	push   $0xf0104682
f0102731:	68 90 03 00 00       	push   $0x390
f0102736:	68 4c 46 10 f0       	push   $0xf010464c
f010273b:	e8 4b d9 ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102740:	6a 02                	push   $0x2
f0102742:	68 00 10 00 00       	push   $0x1000
f0102747:	56                   	push   %esi
f0102748:	ff 35 68 79 11 f0    	pushl  0xf0117968
f010274e:	e8 59 ea ff ff       	call   f01011ac <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102753:	83 c4 10             	add    $0x10,%esp
f0102756:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010275d:	02 02 02 
f0102760:	74 19                	je     f010277b <mem_init+0x153e>
f0102762:	68 d0 45 10 f0       	push   $0xf01045d0
f0102767:	68 82 46 10 f0       	push   $0xf0104682
f010276c:	68 92 03 00 00       	push   $0x392
f0102771:	68 4c 46 10 f0       	push   $0xf010464c
f0102776:	e8 10 d9 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f010277b:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102780:	74 19                	je     f010279b <mem_init+0x155e>
f0102782:	68 4c 48 10 f0       	push   $0xf010484c
f0102787:	68 82 46 10 f0       	push   $0xf0104682
f010278c:	68 93 03 00 00       	push   $0x393
f0102791:	68 4c 46 10 f0       	push   $0xf010464c
f0102796:	e8 f0 d8 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f010279b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01027a0:	74 19                	je     f01027bb <mem_init+0x157e>
f01027a2:	68 b6 48 10 f0       	push   $0xf01048b6
f01027a7:	68 82 46 10 f0       	push   $0xf0104682
f01027ac:	68 94 03 00 00       	push   $0x394
f01027b1:	68 4c 46 10 f0       	push   $0xf010464c
f01027b6:	e8 d0 d8 ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01027bb:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01027c2:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01027c5:	89 f0                	mov    %esi,%eax
f01027c7:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f01027cd:	c1 f8 03             	sar    $0x3,%eax
f01027d0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01027d3:	89 c2                	mov    %eax,%edx
f01027d5:	c1 ea 0c             	shr    $0xc,%edx
f01027d8:	3b 15 64 79 11 f0    	cmp    0xf0117964,%edx
f01027de:	72 12                	jb     f01027f2 <mem_init+0x15b5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01027e0:	50                   	push   %eax
f01027e1:	68 c4 3e 10 f0       	push   $0xf0103ec4
f01027e6:	6a 52                	push   $0x52
f01027e8:	68 68 46 10 f0       	push   $0xf0104668
f01027ed:	e8 99 d8 ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01027f2:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01027f9:	03 03 03 
f01027fc:	74 19                	je     f0102817 <mem_init+0x15da>
f01027fe:	68 f4 45 10 f0       	push   $0xf01045f4
f0102803:	68 82 46 10 f0       	push   $0xf0104682
f0102808:	68 96 03 00 00       	push   $0x396
f010280d:	68 4c 46 10 f0       	push   $0xf010464c
f0102812:	e8 74 d8 ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102817:	83 ec 08             	sub    $0x8,%esp
f010281a:	68 00 10 00 00       	push   $0x1000
f010281f:	ff 35 68 79 11 f0    	pushl  0xf0117968
f0102825:	e8 47 e9 ff ff       	call   f0101171 <page_remove>
	assert(pp2->pp_ref == 0);
f010282a:	83 c4 10             	add    $0x10,%esp
f010282d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102832:	74 19                	je     f010284d <mem_init+0x1610>
f0102834:	68 84 48 10 f0       	push   $0xf0104884
f0102839:	68 82 46 10 f0       	push   $0xf0104682
f010283e:	68 98 03 00 00       	push   $0x398
f0102843:	68 4c 46 10 f0       	push   $0xf010464c
f0102848:	e8 3e d8 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010284d:	8b 0d 68 79 11 f0    	mov    0xf0117968,%ecx
f0102853:	8b 11                	mov    (%ecx),%edx
f0102855:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010285b:	89 d8                	mov    %ebx,%eax
f010285d:	2b 05 6c 79 11 f0    	sub    0xf011796c,%eax
f0102863:	c1 f8 03             	sar    $0x3,%eax
f0102866:	c1 e0 0c             	shl    $0xc,%eax
f0102869:	39 c2                	cmp    %eax,%edx
f010286b:	74 19                	je     f0102886 <mem_init+0x1649>
f010286d:	68 38 41 10 f0       	push   $0xf0104138
f0102872:	68 82 46 10 f0       	push   $0xf0104682
f0102877:	68 9b 03 00 00       	push   $0x39b
f010287c:	68 4c 46 10 f0       	push   $0xf010464c
f0102881:	e8 05 d8 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0102886:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010288c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102891:	74 19                	je     f01028ac <mem_init+0x166f>
f0102893:	68 3b 48 10 f0       	push   $0xf010483b
f0102898:	68 82 46 10 f0       	push   $0xf0104682
f010289d:	68 9d 03 00 00       	push   $0x39d
f01028a2:	68 4c 46 10 f0       	push   $0xf010464c
f01028a7:	e8 df d7 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f01028ac:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01028b2:	83 ec 0c             	sub    $0xc,%esp
f01028b5:	53                   	push   %ebx
f01028b6:	e8 bb e6 ff ff       	call   f0100f76 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01028bb:	c7 04 24 20 46 10 f0 	movl   $0xf0104620,(%esp)
f01028c2:	e8 7d 00 00 00       	call   f0102944 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01028c7:	83 c4 10             	add    $0x10,%esp
f01028ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01028cd:	5b                   	pop    %ebx
f01028ce:	5e                   	pop    %esi
f01028cf:	5f                   	pop    %edi
f01028d0:	5d                   	pop    %ebp
f01028d1:	c3                   	ret    

f01028d2 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01028d2:	55                   	push   %ebp
f01028d3:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01028d5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01028d8:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01028db:	5d                   	pop    %ebp
f01028dc:	c3                   	ret    

f01028dd <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01028dd:	55                   	push   %ebp
f01028de:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01028e0:	ba 70 00 00 00       	mov    $0x70,%edx
f01028e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01028e8:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01028e9:	ba 71 00 00 00       	mov    $0x71,%edx
f01028ee:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01028ef:	0f b6 c0             	movzbl %al,%eax
}
f01028f2:	5d                   	pop    %ebp
f01028f3:	c3                   	ret    

f01028f4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01028f4:	55                   	push   %ebp
f01028f5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01028f7:	ba 70 00 00 00       	mov    $0x70,%edx
f01028fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01028ff:	ee                   	out    %al,(%dx)
f0102900:	ba 71 00 00 00       	mov    $0x71,%edx
f0102905:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102908:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102909:	5d                   	pop    %ebp
f010290a:	c3                   	ret    

f010290b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010290b:	55                   	push   %ebp
f010290c:	89 e5                	mov    %esp,%ebp
f010290e:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102911:	ff 75 08             	pushl  0x8(%ebp)
f0102914:	e8 f1 dc ff ff       	call   f010060a <cputchar>
	*cnt++;
}
f0102919:	83 c4 10             	add    $0x10,%esp
f010291c:	c9                   	leave  
f010291d:	c3                   	ret    

f010291e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010291e:	55                   	push   %ebp
f010291f:	89 e5                	mov    %esp,%ebp
f0102921:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102924:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010292b:	ff 75 0c             	pushl  0xc(%ebp)
f010292e:	ff 75 08             	pushl  0x8(%ebp)
f0102931:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102934:	50                   	push   %eax
f0102935:	68 0b 29 10 f0       	push   $0xf010290b
f010293a:	e8 5d 04 00 00       	call   f0102d9c <vprintfmt>
	return cnt;
}
f010293f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102942:	c9                   	leave  
f0102943:	c3                   	ret    

f0102944 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102944:	55                   	push   %ebp
f0102945:	89 e5                	mov    %esp,%ebp
f0102947:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010294a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010294d:	50                   	push   %eax
f010294e:	ff 75 08             	pushl  0x8(%ebp)
f0102951:	e8 c8 ff ff ff       	call   f010291e <vcprintf>
	va_end(ap);

	return cnt;
}
f0102956:	c9                   	leave  
f0102957:	c3                   	ret    

f0102958 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102958:	55                   	push   %ebp
f0102959:	89 e5                	mov    %esp,%ebp
f010295b:	57                   	push   %edi
f010295c:	56                   	push   %esi
f010295d:	53                   	push   %ebx
f010295e:	83 ec 14             	sub    $0x14,%esp
f0102961:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102964:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102967:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010296a:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010296d:	8b 1a                	mov    (%edx),%ebx
f010296f:	8b 01                	mov    (%ecx),%eax
f0102971:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102974:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010297b:	eb 7f                	jmp    f01029fc <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f010297d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102980:	01 d8                	add    %ebx,%eax
f0102982:	89 c6                	mov    %eax,%esi
f0102984:	c1 ee 1f             	shr    $0x1f,%esi
f0102987:	01 c6                	add    %eax,%esi
f0102989:	d1 fe                	sar    %esi
f010298b:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010298e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0102991:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0102994:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102996:	eb 03                	jmp    f010299b <stab_binsearch+0x43>
			m--;
f0102998:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010299b:	39 c3                	cmp    %eax,%ebx
f010299d:	7f 0d                	jg     f01029ac <stab_binsearch+0x54>
f010299f:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01029a3:	83 ea 0c             	sub    $0xc,%edx
f01029a6:	39 f9                	cmp    %edi,%ecx
f01029a8:	75 ee                	jne    f0102998 <stab_binsearch+0x40>
f01029aa:	eb 05                	jmp    f01029b1 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01029ac:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01029af:	eb 4b                	jmp    f01029fc <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01029b1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01029b4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01029b7:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01029bb:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01029be:	76 11                	jbe    f01029d1 <stab_binsearch+0x79>
			*region_left = m;
f01029c0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01029c3:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01029c5:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01029c8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01029cf:	eb 2b                	jmp    f01029fc <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01029d1:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01029d4:	73 14                	jae    f01029ea <stab_binsearch+0x92>
			*region_right = m - 1;
f01029d6:	83 e8 01             	sub    $0x1,%eax
f01029d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01029dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01029df:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01029e1:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01029e8:	eb 12                	jmp    f01029fc <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01029ea:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01029ed:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f01029ef:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01029f3:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01029f5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01029fc:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01029ff:	0f 8e 78 ff ff ff    	jle    f010297d <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102a05:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102a09:	75 0f                	jne    f0102a1a <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0102a0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102a0e:	8b 00                	mov    (%eax),%eax
f0102a10:	83 e8 01             	sub    $0x1,%eax
f0102a13:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102a16:	89 06                	mov    %eax,(%esi)
f0102a18:	eb 2c                	jmp    f0102a46 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102a1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102a1d:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102a1f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102a22:	8b 0e                	mov    (%esi),%ecx
f0102a24:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102a27:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102a2a:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102a2d:	eb 03                	jmp    f0102a32 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102a2f:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102a32:	39 c8                	cmp    %ecx,%eax
f0102a34:	7e 0b                	jle    f0102a41 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0102a36:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0102a3a:	83 ea 0c             	sub    $0xc,%edx
f0102a3d:	39 df                	cmp    %ebx,%edi
f0102a3f:	75 ee                	jne    f0102a2f <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102a41:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102a44:	89 06                	mov    %eax,(%esi)
	}
}
f0102a46:	83 c4 14             	add    $0x14,%esp
f0102a49:	5b                   	pop    %ebx
f0102a4a:	5e                   	pop    %esi
f0102a4b:	5f                   	pop    %edi
f0102a4c:	5d                   	pop    %ebp
f0102a4d:	c3                   	ret    

f0102a4e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102a4e:	55                   	push   %ebp
f0102a4f:	89 e5                	mov    %esp,%ebp
f0102a51:	57                   	push   %edi
f0102a52:	56                   	push   %esi
f0102a53:	53                   	push   %ebx
f0102a54:	83 ec 3c             	sub    $0x3c,%esp
f0102a57:	8b 75 08             	mov    0x8(%ebp),%esi
f0102a5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102a5d:	c7 03 3f 49 10 f0    	movl   $0xf010493f,(%ebx)
	info->eip_line = 0;
f0102a63:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102a6a:	c7 43 08 3f 49 10 f0 	movl   $0xf010493f,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102a71:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102a78:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102a7b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102a82:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102a88:	76 11                	jbe    f0102a9b <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102a8a:	b8 79 c6 10 f0       	mov    $0xf010c679,%eax
f0102a8f:	3d 19 a8 10 f0       	cmp    $0xf010a819,%eax
f0102a94:	77 19                	ja     f0102aaf <debuginfo_eip+0x61>
f0102a96:	e9 b5 01 00 00       	jmp    f0102c50 <debuginfo_eip+0x202>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102a9b:	83 ec 04             	sub    $0x4,%esp
f0102a9e:	68 49 49 10 f0       	push   $0xf0104949
f0102aa3:	6a 7f                	push   $0x7f
f0102aa5:	68 56 49 10 f0       	push   $0xf0104956
f0102aaa:	e8 dc d5 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102aaf:	80 3d 78 c6 10 f0 00 	cmpb   $0x0,0xf010c678
f0102ab6:	0f 85 9b 01 00 00    	jne    f0102c57 <debuginfo_eip+0x209>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102abc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102ac3:	b8 18 a8 10 f0       	mov    $0xf010a818,%eax
f0102ac8:	2d 90 4b 10 f0       	sub    $0xf0104b90,%eax
f0102acd:	c1 f8 02             	sar    $0x2,%eax
f0102ad0:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102ad6:	83 e8 01             	sub    $0x1,%eax
f0102ad9:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102adc:	83 ec 08             	sub    $0x8,%esp
f0102adf:	56                   	push   %esi
f0102ae0:	6a 64                	push   $0x64
f0102ae2:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102ae5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102ae8:	b8 90 4b 10 f0       	mov    $0xf0104b90,%eax
f0102aed:	e8 66 fe ff ff       	call   f0102958 <stab_binsearch>
	if (lfile == 0)
f0102af2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102af5:	83 c4 10             	add    $0x10,%esp
f0102af8:	85 c0                	test   %eax,%eax
f0102afa:	0f 84 5e 01 00 00    	je     f0102c5e <debuginfo_eip+0x210>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102b00:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0102b03:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102b06:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102b09:	83 ec 08             	sub    $0x8,%esp
f0102b0c:	56                   	push   %esi
f0102b0d:	6a 24                	push   $0x24
f0102b0f:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102b12:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102b15:	b8 90 4b 10 f0       	mov    $0xf0104b90,%eax
f0102b1a:	e8 39 fe ff ff       	call   f0102958 <stab_binsearch>

	if (lfun <= rfun) {
f0102b1f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102b22:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102b25:	83 c4 10             	add    $0x10,%esp
f0102b28:	39 d0                	cmp    %edx,%eax
f0102b2a:	7f 40                	jg     f0102b6c <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102b2c:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102b2f:	c1 e1 02             	shl    $0x2,%ecx
f0102b32:	8d b9 90 4b 10 f0    	lea    -0xfefb470(%ecx),%edi
f0102b38:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102b3b:	8b b9 90 4b 10 f0    	mov    -0xfefb470(%ecx),%edi
f0102b41:	b9 79 c6 10 f0       	mov    $0xf010c679,%ecx
f0102b46:	81 e9 19 a8 10 f0    	sub    $0xf010a819,%ecx
f0102b4c:	39 cf                	cmp    %ecx,%edi
f0102b4e:	73 09                	jae    f0102b59 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102b50:	81 c7 19 a8 10 f0    	add    $0xf010a819,%edi
f0102b56:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102b59:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102b5c:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102b5f:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102b62:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102b64:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102b67:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102b6a:	eb 0f                	jmp    f0102b7b <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102b6c:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102b6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102b72:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102b75:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102b78:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102b7b:	83 ec 08             	sub    $0x8,%esp
f0102b7e:	6a 3a                	push   $0x3a
f0102b80:	ff 73 08             	pushl  0x8(%ebx)
f0102b83:	e8 64 08 00 00       	call   f01033ec <strfind>
f0102b88:	2b 43 08             	sub    0x8(%ebx),%eax
f0102b8b:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102b8e:	83 c4 08             	add    $0x8,%esp
f0102b91:	56                   	push   %esi
f0102b92:	6a 44                	push   $0x44
f0102b94:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102b97:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102b9a:	b8 90 4b 10 f0       	mov    $0xf0104b90,%eax
f0102b9f:	e8 b4 fd ff ff       	call   f0102958 <stab_binsearch>
if (lline > rline) {
f0102ba4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ba7:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102baa:	83 c4 10             	add    $0x10,%esp
f0102bad:	39 d0                	cmp    %edx,%eax
f0102baf:	0f 8f b0 00 00 00    	jg     f0102c65 <debuginfo_eip+0x217>
    return -1;
} else {
    info->eip_line = stabs[rline].n_desc;
f0102bb5:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102bb8:	0f b7 14 95 96 4b 10 	movzwl -0xfefb46a(,%edx,4),%edx
f0102bbf:	f0 
f0102bc0:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102bc3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102bc6:	89 c2                	mov    %eax,%edx
f0102bc8:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102bcb:	8d 04 85 90 4b 10 f0 	lea    -0xfefb470(,%eax,4),%eax
f0102bd2:	eb 06                	jmp    f0102bda <debuginfo_eip+0x18c>
f0102bd4:	83 ea 01             	sub    $0x1,%edx
f0102bd7:	83 e8 0c             	sub    $0xc,%eax
f0102bda:	39 d7                	cmp    %edx,%edi
f0102bdc:	7f 34                	jg     f0102c12 <debuginfo_eip+0x1c4>
	       && stabs[lline].n_type != N_SOL
f0102bde:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0102be2:	80 f9 84             	cmp    $0x84,%cl
f0102be5:	74 0b                	je     f0102bf2 <debuginfo_eip+0x1a4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102be7:	80 f9 64             	cmp    $0x64,%cl
f0102bea:	75 e8                	jne    f0102bd4 <debuginfo_eip+0x186>
f0102bec:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0102bf0:	74 e2                	je     f0102bd4 <debuginfo_eip+0x186>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102bf2:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102bf5:	8b 14 85 90 4b 10 f0 	mov    -0xfefb470(,%eax,4),%edx
f0102bfc:	b8 79 c6 10 f0       	mov    $0xf010c679,%eax
f0102c01:	2d 19 a8 10 f0       	sub    $0xf010a819,%eax
f0102c06:	39 c2                	cmp    %eax,%edx
f0102c08:	73 08                	jae    f0102c12 <debuginfo_eip+0x1c4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102c0a:	81 c2 19 a8 10 f0    	add    $0xf010a819,%edx
f0102c10:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102c12:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102c15:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102c18:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102c1d:	39 f2                	cmp    %esi,%edx
f0102c1f:	7d 50                	jge    f0102c71 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
f0102c21:	83 c2 01             	add    $0x1,%edx
f0102c24:	89 d0                	mov    %edx,%eax
f0102c26:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102c29:	8d 14 95 90 4b 10 f0 	lea    -0xfefb470(,%edx,4),%edx
f0102c30:	eb 04                	jmp    f0102c36 <debuginfo_eip+0x1e8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102c32:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102c36:	39 c6                	cmp    %eax,%esi
f0102c38:	7e 32                	jle    f0102c6c <debuginfo_eip+0x21e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102c3a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0102c3e:	83 c0 01             	add    $0x1,%eax
f0102c41:	83 c2 0c             	add    $0xc,%edx
f0102c44:	80 f9 a0             	cmp    $0xa0,%cl
f0102c47:	74 e9                	je     f0102c32 <debuginfo_eip+0x1e4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102c49:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c4e:	eb 21                	jmp    f0102c71 <debuginfo_eip+0x223>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102c50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102c55:	eb 1a                	jmp    f0102c71 <debuginfo_eip+0x223>
f0102c57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102c5c:	eb 13                	jmp    f0102c71 <debuginfo_eip+0x223>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102c5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102c63:	eb 0c                	jmp    f0102c71 <debuginfo_eip+0x223>
	// Your code here.


stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
if (lline > rline) {
    return -1;
f0102c65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102c6a:	eb 05                	jmp    f0102c71 <debuginfo_eip+0x223>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102c6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c74:	5b                   	pop    %ebx
f0102c75:	5e                   	pop    %esi
f0102c76:	5f                   	pop    %edi
f0102c77:	5d                   	pop    %ebp
f0102c78:	c3                   	ret    

f0102c79 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102c79:	55                   	push   %ebp
f0102c7a:	89 e5                	mov    %esp,%ebp
f0102c7c:	57                   	push   %edi
f0102c7d:	56                   	push   %esi
f0102c7e:	53                   	push   %ebx
f0102c7f:	83 ec 1c             	sub    $0x1c,%esp
f0102c82:	89 c7                	mov    %eax,%edi
f0102c84:	89 d6                	mov    %edx,%esi
f0102c86:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c89:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102c8c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102c8f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102c92:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102c95:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102c9a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102c9d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0102ca0:	39 d3                	cmp    %edx,%ebx
f0102ca2:	72 05                	jb     f0102ca9 <printnum+0x30>
f0102ca4:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102ca7:	77 45                	ja     f0102cee <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102ca9:	83 ec 0c             	sub    $0xc,%esp
f0102cac:	ff 75 18             	pushl  0x18(%ebp)
f0102caf:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cb2:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102cb5:	53                   	push   %ebx
f0102cb6:	ff 75 10             	pushl  0x10(%ebp)
f0102cb9:	83 ec 08             	sub    $0x8,%esp
f0102cbc:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102cbf:	ff 75 e0             	pushl  -0x20(%ebp)
f0102cc2:	ff 75 dc             	pushl  -0x24(%ebp)
f0102cc5:	ff 75 d8             	pushl  -0x28(%ebp)
f0102cc8:	e8 43 09 00 00       	call   f0103610 <__udivdi3>
f0102ccd:	83 c4 18             	add    $0x18,%esp
f0102cd0:	52                   	push   %edx
f0102cd1:	50                   	push   %eax
f0102cd2:	89 f2                	mov    %esi,%edx
f0102cd4:	89 f8                	mov    %edi,%eax
f0102cd6:	e8 9e ff ff ff       	call   f0102c79 <printnum>
f0102cdb:	83 c4 20             	add    $0x20,%esp
f0102cde:	eb 18                	jmp    f0102cf8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102ce0:	83 ec 08             	sub    $0x8,%esp
f0102ce3:	56                   	push   %esi
f0102ce4:	ff 75 18             	pushl  0x18(%ebp)
f0102ce7:	ff d7                	call   *%edi
f0102ce9:	83 c4 10             	add    $0x10,%esp
f0102cec:	eb 03                	jmp    f0102cf1 <printnum+0x78>
f0102cee:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102cf1:	83 eb 01             	sub    $0x1,%ebx
f0102cf4:	85 db                	test   %ebx,%ebx
f0102cf6:	7f e8                	jg     f0102ce0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102cf8:	83 ec 08             	sub    $0x8,%esp
f0102cfb:	56                   	push   %esi
f0102cfc:	83 ec 04             	sub    $0x4,%esp
f0102cff:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102d02:	ff 75 e0             	pushl  -0x20(%ebp)
f0102d05:	ff 75 dc             	pushl  -0x24(%ebp)
f0102d08:	ff 75 d8             	pushl  -0x28(%ebp)
f0102d0b:	e8 30 0a 00 00       	call   f0103740 <__umoddi3>
f0102d10:	83 c4 14             	add    $0x14,%esp
f0102d13:	0f be 80 64 49 10 f0 	movsbl -0xfefb69c(%eax),%eax
f0102d1a:	50                   	push   %eax
f0102d1b:	ff d7                	call   *%edi
}
f0102d1d:	83 c4 10             	add    $0x10,%esp
f0102d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d23:	5b                   	pop    %ebx
f0102d24:	5e                   	pop    %esi
f0102d25:	5f                   	pop    %edi
f0102d26:	5d                   	pop    %ebp
f0102d27:	c3                   	ret    

f0102d28 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102d28:	55                   	push   %ebp
f0102d29:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102d2b:	83 fa 01             	cmp    $0x1,%edx
f0102d2e:	7e 0e                	jle    f0102d3e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102d30:	8b 10                	mov    (%eax),%edx
f0102d32:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102d35:	89 08                	mov    %ecx,(%eax)
f0102d37:	8b 02                	mov    (%edx),%eax
f0102d39:	8b 52 04             	mov    0x4(%edx),%edx
f0102d3c:	eb 22                	jmp    f0102d60 <getuint+0x38>
	else if (lflag)
f0102d3e:	85 d2                	test   %edx,%edx
f0102d40:	74 10                	je     f0102d52 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102d42:	8b 10                	mov    (%eax),%edx
f0102d44:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102d47:	89 08                	mov    %ecx,(%eax)
f0102d49:	8b 02                	mov    (%edx),%eax
f0102d4b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102d50:	eb 0e                	jmp    f0102d60 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102d52:	8b 10                	mov    (%eax),%edx
f0102d54:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102d57:	89 08                	mov    %ecx,(%eax)
f0102d59:	8b 02                	mov    (%edx),%eax
f0102d5b:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102d60:	5d                   	pop    %ebp
f0102d61:	c3                   	ret    

f0102d62 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102d62:	55                   	push   %ebp
f0102d63:	89 e5                	mov    %esp,%ebp
f0102d65:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102d68:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102d6c:	8b 10                	mov    (%eax),%edx
f0102d6e:	3b 50 04             	cmp    0x4(%eax),%edx
f0102d71:	73 0a                	jae    f0102d7d <sprintputch+0x1b>
		*b->buf++ = ch;
f0102d73:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102d76:	89 08                	mov    %ecx,(%eax)
f0102d78:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d7b:	88 02                	mov    %al,(%edx)
}
f0102d7d:	5d                   	pop    %ebp
f0102d7e:	c3                   	ret    

f0102d7f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102d7f:	55                   	push   %ebp
f0102d80:	89 e5                	mov    %esp,%ebp
f0102d82:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102d85:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102d88:	50                   	push   %eax
f0102d89:	ff 75 10             	pushl  0x10(%ebp)
f0102d8c:	ff 75 0c             	pushl  0xc(%ebp)
f0102d8f:	ff 75 08             	pushl  0x8(%ebp)
f0102d92:	e8 05 00 00 00       	call   f0102d9c <vprintfmt>
	va_end(ap);
}
f0102d97:	83 c4 10             	add    $0x10,%esp
f0102d9a:	c9                   	leave  
f0102d9b:	c3                   	ret    

f0102d9c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102d9c:	55                   	push   %ebp
f0102d9d:	89 e5                	mov    %esp,%ebp
f0102d9f:	57                   	push   %edi
f0102da0:	56                   	push   %esi
f0102da1:	53                   	push   %ebx
f0102da2:	83 ec 2c             	sub    $0x2c,%esp
f0102da5:	8b 75 08             	mov    0x8(%ebp),%esi
f0102da8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102dab:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102dae:	eb 12                	jmp    f0102dc2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102db0:	85 c0                	test   %eax,%eax
f0102db2:	0f 84 89 03 00 00    	je     f0103141 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0102db8:	83 ec 08             	sub    $0x8,%esp
f0102dbb:	53                   	push   %ebx
f0102dbc:	50                   	push   %eax
f0102dbd:	ff d6                	call   *%esi
f0102dbf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102dc2:	83 c7 01             	add    $0x1,%edi
f0102dc5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102dc9:	83 f8 25             	cmp    $0x25,%eax
f0102dcc:	75 e2                	jne    f0102db0 <vprintfmt+0x14>
f0102dce:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102dd2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102dd9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102de0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102de7:	ba 00 00 00 00       	mov    $0x0,%edx
f0102dec:	eb 07                	jmp    f0102df5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102dee:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102df1:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102df5:	8d 47 01             	lea    0x1(%edi),%eax
f0102df8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102dfb:	0f b6 07             	movzbl (%edi),%eax
f0102dfe:	0f b6 c8             	movzbl %al,%ecx
f0102e01:	83 e8 23             	sub    $0x23,%eax
f0102e04:	3c 55                	cmp    $0x55,%al
f0102e06:	0f 87 1a 03 00 00    	ja     f0103126 <vprintfmt+0x38a>
f0102e0c:	0f b6 c0             	movzbl %al,%eax
f0102e0f:	ff 24 85 00 4a 10 f0 	jmp    *-0xfefb600(,%eax,4)
f0102e16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102e19:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102e1d:	eb d6                	jmp    f0102df5 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e22:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e27:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102e2a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102e2d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0102e31:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0102e34:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0102e37:	83 fa 09             	cmp    $0x9,%edx
f0102e3a:	77 39                	ja     f0102e75 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102e3c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102e3f:	eb e9                	jmp    f0102e2a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102e41:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e44:	8d 48 04             	lea    0x4(%eax),%ecx
f0102e47:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102e4a:	8b 00                	mov    (%eax),%eax
f0102e4c:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e4f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102e52:	eb 27                	jmp    f0102e7b <vprintfmt+0xdf>
f0102e54:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e57:	85 c0                	test   %eax,%eax
f0102e59:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102e5e:	0f 49 c8             	cmovns %eax,%ecx
f0102e61:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e67:	eb 8c                	jmp    f0102df5 <vprintfmt+0x59>
f0102e69:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102e6c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102e73:	eb 80                	jmp    f0102df5 <vprintfmt+0x59>
f0102e75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102e78:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102e7b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102e7f:	0f 89 70 ff ff ff    	jns    f0102df5 <vprintfmt+0x59>
				width = precision, precision = -1;
f0102e85:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102e88:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102e8b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102e92:	e9 5e ff ff ff       	jmp    f0102df5 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102e97:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102e9d:	e9 53 ff ff ff       	jmp    f0102df5 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102ea2:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ea5:	8d 50 04             	lea    0x4(%eax),%edx
f0102ea8:	89 55 14             	mov    %edx,0x14(%ebp)
f0102eab:	83 ec 08             	sub    $0x8,%esp
f0102eae:	53                   	push   %ebx
f0102eaf:	ff 30                	pushl  (%eax)
f0102eb1:	ff d6                	call   *%esi
			break;
f0102eb3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102eb6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102eb9:	e9 04 ff ff ff       	jmp    f0102dc2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102ebe:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ec1:	8d 50 04             	lea    0x4(%eax),%edx
f0102ec4:	89 55 14             	mov    %edx,0x14(%ebp)
f0102ec7:	8b 00                	mov    (%eax),%eax
f0102ec9:	99                   	cltd   
f0102eca:	31 d0                	xor    %edx,%eax
f0102ecc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102ece:	83 f8 07             	cmp    $0x7,%eax
f0102ed1:	7f 0b                	jg     f0102ede <vprintfmt+0x142>
f0102ed3:	8b 14 85 60 4b 10 f0 	mov    -0xfefb4a0(,%eax,4),%edx
f0102eda:	85 d2                	test   %edx,%edx
f0102edc:	75 18                	jne    f0102ef6 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0102ede:	50                   	push   %eax
f0102edf:	68 7c 49 10 f0       	push   $0xf010497c
f0102ee4:	53                   	push   %ebx
f0102ee5:	56                   	push   %esi
f0102ee6:	e8 94 fe ff ff       	call   f0102d7f <printfmt>
f0102eeb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102eee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102ef1:	e9 cc fe ff ff       	jmp    f0102dc2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102ef6:	52                   	push   %edx
f0102ef7:	68 94 46 10 f0       	push   $0xf0104694
f0102efc:	53                   	push   %ebx
f0102efd:	56                   	push   %esi
f0102efe:	e8 7c fe ff ff       	call   f0102d7f <printfmt>
f0102f03:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102f06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102f09:	e9 b4 fe ff ff       	jmp    f0102dc2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102f0e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f11:	8d 50 04             	lea    0x4(%eax),%edx
f0102f14:	89 55 14             	mov    %edx,0x14(%ebp)
f0102f17:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102f19:	85 ff                	test   %edi,%edi
f0102f1b:	b8 75 49 10 f0       	mov    $0xf0104975,%eax
f0102f20:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102f23:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102f27:	0f 8e 94 00 00 00    	jle    f0102fc1 <vprintfmt+0x225>
f0102f2d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102f31:	0f 84 98 00 00 00    	je     f0102fcf <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102f37:	83 ec 08             	sub    $0x8,%esp
f0102f3a:	ff 75 d0             	pushl  -0x30(%ebp)
f0102f3d:	57                   	push   %edi
f0102f3e:	e8 5f 03 00 00       	call   f01032a2 <strnlen>
f0102f43:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102f46:	29 c1                	sub    %eax,%ecx
f0102f48:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102f4b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102f4e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102f52:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102f55:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102f58:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102f5a:	eb 0f                	jmp    f0102f6b <vprintfmt+0x1cf>
					putch(padc, putdat);
f0102f5c:	83 ec 08             	sub    $0x8,%esp
f0102f5f:	53                   	push   %ebx
f0102f60:	ff 75 e0             	pushl  -0x20(%ebp)
f0102f63:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102f65:	83 ef 01             	sub    $0x1,%edi
f0102f68:	83 c4 10             	add    $0x10,%esp
f0102f6b:	85 ff                	test   %edi,%edi
f0102f6d:	7f ed                	jg     f0102f5c <vprintfmt+0x1c0>
f0102f6f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102f72:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102f75:	85 c9                	test   %ecx,%ecx
f0102f77:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f7c:	0f 49 c1             	cmovns %ecx,%eax
f0102f7f:	29 c1                	sub    %eax,%ecx
f0102f81:	89 75 08             	mov    %esi,0x8(%ebp)
f0102f84:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102f87:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102f8a:	89 cb                	mov    %ecx,%ebx
f0102f8c:	eb 4d                	jmp    f0102fdb <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102f8e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102f92:	74 1b                	je     f0102faf <vprintfmt+0x213>
f0102f94:	0f be c0             	movsbl %al,%eax
f0102f97:	83 e8 20             	sub    $0x20,%eax
f0102f9a:	83 f8 5e             	cmp    $0x5e,%eax
f0102f9d:	76 10                	jbe    f0102faf <vprintfmt+0x213>
					putch('?', putdat);
f0102f9f:	83 ec 08             	sub    $0x8,%esp
f0102fa2:	ff 75 0c             	pushl  0xc(%ebp)
f0102fa5:	6a 3f                	push   $0x3f
f0102fa7:	ff 55 08             	call   *0x8(%ebp)
f0102faa:	83 c4 10             	add    $0x10,%esp
f0102fad:	eb 0d                	jmp    f0102fbc <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0102faf:	83 ec 08             	sub    $0x8,%esp
f0102fb2:	ff 75 0c             	pushl  0xc(%ebp)
f0102fb5:	52                   	push   %edx
f0102fb6:	ff 55 08             	call   *0x8(%ebp)
f0102fb9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102fbc:	83 eb 01             	sub    $0x1,%ebx
f0102fbf:	eb 1a                	jmp    f0102fdb <vprintfmt+0x23f>
f0102fc1:	89 75 08             	mov    %esi,0x8(%ebp)
f0102fc4:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102fc7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102fca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102fcd:	eb 0c                	jmp    f0102fdb <vprintfmt+0x23f>
f0102fcf:	89 75 08             	mov    %esi,0x8(%ebp)
f0102fd2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102fd5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102fd8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102fdb:	83 c7 01             	add    $0x1,%edi
f0102fde:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102fe2:	0f be d0             	movsbl %al,%edx
f0102fe5:	85 d2                	test   %edx,%edx
f0102fe7:	74 23                	je     f010300c <vprintfmt+0x270>
f0102fe9:	85 f6                	test   %esi,%esi
f0102feb:	78 a1                	js     f0102f8e <vprintfmt+0x1f2>
f0102fed:	83 ee 01             	sub    $0x1,%esi
f0102ff0:	79 9c                	jns    f0102f8e <vprintfmt+0x1f2>
f0102ff2:	89 df                	mov    %ebx,%edi
f0102ff4:	8b 75 08             	mov    0x8(%ebp),%esi
f0102ff7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ffa:	eb 18                	jmp    f0103014 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102ffc:	83 ec 08             	sub    $0x8,%esp
f0102fff:	53                   	push   %ebx
f0103000:	6a 20                	push   $0x20
f0103002:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103004:	83 ef 01             	sub    $0x1,%edi
f0103007:	83 c4 10             	add    $0x10,%esp
f010300a:	eb 08                	jmp    f0103014 <vprintfmt+0x278>
f010300c:	89 df                	mov    %ebx,%edi
f010300e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103011:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103014:	85 ff                	test   %edi,%edi
f0103016:	7f e4                	jg     f0102ffc <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103018:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010301b:	e9 a2 fd ff ff       	jmp    f0102dc2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103020:	83 fa 01             	cmp    $0x1,%edx
f0103023:	7e 16                	jle    f010303b <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0103025:	8b 45 14             	mov    0x14(%ebp),%eax
f0103028:	8d 50 08             	lea    0x8(%eax),%edx
f010302b:	89 55 14             	mov    %edx,0x14(%ebp)
f010302e:	8b 50 04             	mov    0x4(%eax),%edx
f0103031:	8b 00                	mov    (%eax),%eax
f0103033:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103036:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103039:	eb 32                	jmp    f010306d <vprintfmt+0x2d1>
	else if (lflag)
f010303b:	85 d2                	test   %edx,%edx
f010303d:	74 18                	je     f0103057 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f010303f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103042:	8d 50 04             	lea    0x4(%eax),%edx
f0103045:	89 55 14             	mov    %edx,0x14(%ebp)
f0103048:	8b 00                	mov    (%eax),%eax
f010304a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010304d:	89 c1                	mov    %eax,%ecx
f010304f:	c1 f9 1f             	sar    $0x1f,%ecx
f0103052:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103055:	eb 16                	jmp    f010306d <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0103057:	8b 45 14             	mov    0x14(%ebp),%eax
f010305a:	8d 50 04             	lea    0x4(%eax),%edx
f010305d:	89 55 14             	mov    %edx,0x14(%ebp)
f0103060:	8b 00                	mov    (%eax),%eax
f0103062:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103065:	89 c1                	mov    %eax,%ecx
f0103067:	c1 f9 1f             	sar    $0x1f,%ecx
f010306a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010306d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103070:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103073:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103078:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010307c:	79 74                	jns    f01030f2 <vprintfmt+0x356>
				putch('-', putdat);
f010307e:	83 ec 08             	sub    $0x8,%esp
f0103081:	53                   	push   %ebx
f0103082:	6a 2d                	push   $0x2d
f0103084:	ff d6                	call   *%esi
				num = -(long long) num;
f0103086:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103089:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010308c:	f7 d8                	neg    %eax
f010308e:	83 d2 00             	adc    $0x0,%edx
f0103091:	f7 da                	neg    %edx
f0103093:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103096:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010309b:	eb 55                	jmp    f01030f2 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010309d:	8d 45 14             	lea    0x14(%ebp),%eax
f01030a0:	e8 83 fc ff ff       	call   f0102d28 <getuint>
			base = 10;
f01030a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01030aa:	eb 46                	jmp    f01030f2 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01030ac:	8d 45 14             	lea    0x14(%ebp),%eax
f01030af:	e8 74 fc ff ff       	call   f0102d28 <getuint>
			base = 8;
f01030b4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01030b9:	eb 37                	jmp    f01030f2 <vprintfmt+0x356>
			

		// pointer
		case 'p':
			putch('0', putdat);
f01030bb:	83 ec 08             	sub    $0x8,%esp
f01030be:	53                   	push   %ebx
f01030bf:	6a 30                	push   $0x30
f01030c1:	ff d6                	call   *%esi
			putch('x', putdat);
f01030c3:	83 c4 08             	add    $0x8,%esp
f01030c6:	53                   	push   %ebx
f01030c7:	6a 78                	push   $0x78
f01030c9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01030cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01030ce:	8d 50 04             	lea    0x4(%eax),%edx
f01030d1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01030d4:	8b 00                	mov    (%eax),%eax
f01030d6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01030db:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01030de:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01030e3:	eb 0d                	jmp    f01030f2 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01030e5:	8d 45 14             	lea    0x14(%ebp),%eax
f01030e8:	e8 3b fc ff ff       	call   f0102d28 <getuint>
			base = 16;
f01030ed:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01030f2:	83 ec 0c             	sub    $0xc,%esp
f01030f5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01030f9:	57                   	push   %edi
f01030fa:	ff 75 e0             	pushl  -0x20(%ebp)
f01030fd:	51                   	push   %ecx
f01030fe:	52                   	push   %edx
f01030ff:	50                   	push   %eax
f0103100:	89 da                	mov    %ebx,%edx
f0103102:	89 f0                	mov    %esi,%eax
f0103104:	e8 70 fb ff ff       	call   f0102c79 <printnum>
			break;
f0103109:	83 c4 20             	add    $0x20,%esp
f010310c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010310f:	e9 ae fc ff ff       	jmp    f0102dc2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103114:	83 ec 08             	sub    $0x8,%esp
f0103117:	53                   	push   %ebx
f0103118:	51                   	push   %ecx
f0103119:	ff d6                	call   *%esi
			break;
f010311b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010311e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103121:	e9 9c fc ff ff       	jmp    f0102dc2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103126:	83 ec 08             	sub    $0x8,%esp
f0103129:	53                   	push   %ebx
f010312a:	6a 25                	push   $0x25
f010312c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010312e:	83 c4 10             	add    $0x10,%esp
f0103131:	eb 03                	jmp    f0103136 <vprintfmt+0x39a>
f0103133:	83 ef 01             	sub    $0x1,%edi
f0103136:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010313a:	75 f7                	jne    f0103133 <vprintfmt+0x397>
f010313c:	e9 81 fc ff ff       	jmp    f0102dc2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0103141:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103144:	5b                   	pop    %ebx
f0103145:	5e                   	pop    %esi
f0103146:	5f                   	pop    %edi
f0103147:	5d                   	pop    %ebp
f0103148:	c3                   	ret    

f0103149 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103149:	55                   	push   %ebp
f010314a:	89 e5                	mov    %esp,%ebp
f010314c:	83 ec 18             	sub    $0x18,%esp
f010314f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103152:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103155:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103158:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010315c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010315f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103166:	85 c0                	test   %eax,%eax
f0103168:	74 26                	je     f0103190 <vsnprintf+0x47>
f010316a:	85 d2                	test   %edx,%edx
f010316c:	7e 22                	jle    f0103190 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010316e:	ff 75 14             	pushl  0x14(%ebp)
f0103171:	ff 75 10             	pushl  0x10(%ebp)
f0103174:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103177:	50                   	push   %eax
f0103178:	68 62 2d 10 f0       	push   $0xf0102d62
f010317d:	e8 1a fc ff ff       	call   f0102d9c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103182:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103185:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103188:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010318b:	83 c4 10             	add    $0x10,%esp
f010318e:	eb 05                	jmp    f0103195 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103190:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103195:	c9                   	leave  
f0103196:	c3                   	ret    

f0103197 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103197:	55                   	push   %ebp
f0103198:	89 e5                	mov    %esp,%ebp
f010319a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010319d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01031a0:	50                   	push   %eax
f01031a1:	ff 75 10             	pushl  0x10(%ebp)
f01031a4:	ff 75 0c             	pushl  0xc(%ebp)
f01031a7:	ff 75 08             	pushl  0x8(%ebp)
f01031aa:	e8 9a ff ff ff       	call   f0103149 <vsnprintf>
	va_end(ap);

	return rc;
}
f01031af:	c9                   	leave  
f01031b0:	c3                   	ret    

f01031b1 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01031b1:	55                   	push   %ebp
f01031b2:	89 e5                	mov    %esp,%ebp
f01031b4:	57                   	push   %edi
f01031b5:	56                   	push   %esi
f01031b6:	53                   	push   %ebx
f01031b7:	83 ec 0c             	sub    $0xc,%esp
f01031ba:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01031bd:	85 c0                	test   %eax,%eax
f01031bf:	74 11                	je     f01031d2 <readline+0x21>
		cprintf("%s", prompt);
f01031c1:	83 ec 08             	sub    $0x8,%esp
f01031c4:	50                   	push   %eax
f01031c5:	68 94 46 10 f0       	push   $0xf0104694
f01031ca:	e8 75 f7 ff ff       	call   f0102944 <cprintf>
f01031cf:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01031d2:	83 ec 0c             	sub    $0xc,%esp
f01031d5:	6a 00                	push   $0x0
f01031d7:	e8 4f d4 ff ff       	call   f010062b <iscons>
f01031dc:	89 c7                	mov    %eax,%edi
f01031de:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01031e1:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01031e6:	e8 2f d4 ff ff       	call   f010061a <getchar>
f01031eb:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01031ed:	85 c0                	test   %eax,%eax
f01031ef:	79 18                	jns    f0103209 <readline+0x58>
			cprintf("read error: %e\n", c);
f01031f1:	83 ec 08             	sub    $0x8,%esp
f01031f4:	50                   	push   %eax
f01031f5:	68 80 4b 10 f0       	push   $0xf0104b80
f01031fa:	e8 45 f7 ff ff       	call   f0102944 <cprintf>
			return NULL;
f01031ff:	83 c4 10             	add    $0x10,%esp
f0103202:	b8 00 00 00 00       	mov    $0x0,%eax
f0103207:	eb 79                	jmp    f0103282 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103209:	83 f8 08             	cmp    $0x8,%eax
f010320c:	0f 94 c2             	sete   %dl
f010320f:	83 f8 7f             	cmp    $0x7f,%eax
f0103212:	0f 94 c0             	sete   %al
f0103215:	08 c2                	or     %al,%dl
f0103217:	74 1a                	je     f0103233 <readline+0x82>
f0103219:	85 f6                	test   %esi,%esi
f010321b:	7e 16                	jle    f0103233 <readline+0x82>
			if (echoing)
f010321d:	85 ff                	test   %edi,%edi
f010321f:	74 0d                	je     f010322e <readline+0x7d>
				cputchar('\b');
f0103221:	83 ec 0c             	sub    $0xc,%esp
f0103224:	6a 08                	push   $0x8
f0103226:	e8 df d3 ff ff       	call   f010060a <cputchar>
f010322b:	83 c4 10             	add    $0x10,%esp
			i--;
f010322e:	83 ee 01             	sub    $0x1,%esi
f0103231:	eb b3                	jmp    f01031e6 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103233:	83 fb 1f             	cmp    $0x1f,%ebx
f0103236:	7e 23                	jle    f010325b <readline+0xaa>
f0103238:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010323e:	7f 1b                	jg     f010325b <readline+0xaa>
			if (echoing)
f0103240:	85 ff                	test   %edi,%edi
f0103242:	74 0c                	je     f0103250 <readline+0x9f>
				cputchar(c);
f0103244:	83 ec 0c             	sub    $0xc,%esp
f0103247:	53                   	push   %ebx
f0103248:	e8 bd d3 ff ff       	call   f010060a <cputchar>
f010324d:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103250:	88 9e 60 75 11 f0    	mov    %bl,-0xfee8aa0(%esi)
f0103256:	8d 76 01             	lea    0x1(%esi),%esi
f0103259:	eb 8b                	jmp    f01031e6 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010325b:	83 fb 0a             	cmp    $0xa,%ebx
f010325e:	74 05                	je     f0103265 <readline+0xb4>
f0103260:	83 fb 0d             	cmp    $0xd,%ebx
f0103263:	75 81                	jne    f01031e6 <readline+0x35>
			if (echoing)
f0103265:	85 ff                	test   %edi,%edi
f0103267:	74 0d                	je     f0103276 <readline+0xc5>
				cputchar('\n');
f0103269:	83 ec 0c             	sub    $0xc,%esp
f010326c:	6a 0a                	push   $0xa
f010326e:	e8 97 d3 ff ff       	call   f010060a <cputchar>
f0103273:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0103276:	c6 86 60 75 11 f0 00 	movb   $0x0,-0xfee8aa0(%esi)
			return buf;
f010327d:	b8 60 75 11 f0       	mov    $0xf0117560,%eax
		}
	}
}
f0103282:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103285:	5b                   	pop    %ebx
f0103286:	5e                   	pop    %esi
f0103287:	5f                   	pop    %edi
f0103288:	5d                   	pop    %ebp
f0103289:	c3                   	ret    

f010328a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010328a:	55                   	push   %ebp
f010328b:	89 e5                	mov    %esp,%ebp
f010328d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103290:	b8 00 00 00 00       	mov    $0x0,%eax
f0103295:	eb 03                	jmp    f010329a <strlen+0x10>
		n++;
f0103297:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010329a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010329e:	75 f7                	jne    f0103297 <strlen+0xd>
		n++;
	return n;
}
f01032a0:	5d                   	pop    %ebp
f01032a1:	c3                   	ret    

f01032a2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01032a2:	55                   	push   %ebp
f01032a3:	89 e5                	mov    %esp,%ebp
f01032a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01032a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01032ab:	ba 00 00 00 00       	mov    $0x0,%edx
f01032b0:	eb 03                	jmp    f01032b5 <strnlen+0x13>
		n++;
f01032b2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01032b5:	39 c2                	cmp    %eax,%edx
f01032b7:	74 08                	je     f01032c1 <strnlen+0x1f>
f01032b9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01032bd:	75 f3                	jne    f01032b2 <strnlen+0x10>
f01032bf:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f01032c1:	5d                   	pop    %ebp
f01032c2:	c3                   	ret    

f01032c3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01032c3:	55                   	push   %ebp
f01032c4:	89 e5                	mov    %esp,%ebp
f01032c6:	53                   	push   %ebx
f01032c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01032ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01032cd:	89 c2                	mov    %eax,%edx
f01032cf:	83 c2 01             	add    $0x1,%edx
f01032d2:	83 c1 01             	add    $0x1,%ecx
f01032d5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f01032d9:	88 5a ff             	mov    %bl,-0x1(%edx)
f01032dc:	84 db                	test   %bl,%bl
f01032de:	75 ef                	jne    f01032cf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f01032e0:	5b                   	pop    %ebx
f01032e1:	5d                   	pop    %ebp
f01032e2:	c3                   	ret    

f01032e3 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01032e3:	55                   	push   %ebp
f01032e4:	89 e5                	mov    %esp,%ebp
f01032e6:	53                   	push   %ebx
f01032e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01032ea:	53                   	push   %ebx
f01032eb:	e8 9a ff ff ff       	call   f010328a <strlen>
f01032f0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f01032f3:	ff 75 0c             	pushl  0xc(%ebp)
f01032f6:	01 d8                	add    %ebx,%eax
f01032f8:	50                   	push   %eax
f01032f9:	e8 c5 ff ff ff       	call   f01032c3 <strcpy>
	return dst;
}
f01032fe:	89 d8                	mov    %ebx,%eax
f0103300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103303:	c9                   	leave  
f0103304:	c3                   	ret    

f0103305 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103305:	55                   	push   %ebp
f0103306:	89 e5                	mov    %esp,%ebp
f0103308:	56                   	push   %esi
f0103309:	53                   	push   %ebx
f010330a:	8b 75 08             	mov    0x8(%ebp),%esi
f010330d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103310:	89 f3                	mov    %esi,%ebx
f0103312:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103315:	89 f2                	mov    %esi,%edx
f0103317:	eb 0f                	jmp    f0103328 <strncpy+0x23>
		*dst++ = *src;
f0103319:	83 c2 01             	add    $0x1,%edx
f010331c:	0f b6 01             	movzbl (%ecx),%eax
f010331f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103322:	80 39 01             	cmpb   $0x1,(%ecx)
f0103325:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103328:	39 da                	cmp    %ebx,%edx
f010332a:	75 ed                	jne    f0103319 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010332c:	89 f0                	mov    %esi,%eax
f010332e:	5b                   	pop    %ebx
f010332f:	5e                   	pop    %esi
f0103330:	5d                   	pop    %ebp
f0103331:	c3                   	ret    

f0103332 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103332:	55                   	push   %ebp
f0103333:	89 e5                	mov    %esp,%ebp
f0103335:	56                   	push   %esi
f0103336:	53                   	push   %ebx
f0103337:	8b 75 08             	mov    0x8(%ebp),%esi
f010333a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010333d:	8b 55 10             	mov    0x10(%ebp),%edx
f0103340:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103342:	85 d2                	test   %edx,%edx
f0103344:	74 21                	je     f0103367 <strlcpy+0x35>
f0103346:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010334a:	89 f2                	mov    %esi,%edx
f010334c:	eb 09                	jmp    f0103357 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010334e:	83 c2 01             	add    $0x1,%edx
f0103351:	83 c1 01             	add    $0x1,%ecx
f0103354:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103357:	39 c2                	cmp    %eax,%edx
f0103359:	74 09                	je     f0103364 <strlcpy+0x32>
f010335b:	0f b6 19             	movzbl (%ecx),%ebx
f010335e:	84 db                	test   %bl,%bl
f0103360:	75 ec                	jne    f010334e <strlcpy+0x1c>
f0103362:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103364:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103367:	29 f0                	sub    %esi,%eax
}
f0103369:	5b                   	pop    %ebx
f010336a:	5e                   	pop    %esi
f010336b:	5d                   	pop    %ebp
f010336c:	c3                   	ret    

f010336d <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010336d:	55                   	push   %ebp
f010336e:	89 e5                	mov    %esp,%ebp
f0103370:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103373:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103376:	eb 06                	jmp    f010337e <strcmp+0x11>
		p++, q++;
f0103378:	83 c1 01             	add    $0x1,%ecx
f010337b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010337e:	0f b6 01             	movzbl (%ecx),%eax
f0103381:	84 c0                	test   %al,%al
f0103383:	74 04                	je     f0103389 <strcmp+0x1c>
f0103385:	3a 02                	cmp    (%edx),%al
f0103387:	74 ef                	je     f0103378 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103389:	0f b6 c0             	movzbl %al,%eax
f010338c:	0f b6 12             	movzbl (%edx),%edx
f010338f:	29 d0                	sub    %edx,%eax
}
f0103391:	5d                   	pop    %ebp
f0103392:	c3                   	ret    

f0103393 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103393:	55                   	push   %ebp
f0103394:	89 e5                	mov    %esp,%ebp
f0103396:	53                   	push   %ebx
f0103397:	8b 45 08             	mov    0x8(%ebp),%eax
f010339a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010339d:	89 c3                	mov    %eax,%ebx
f010339f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01033a2:	eb 06                	jmp    f01033aa <strncmp+0x17>
		n--, p++, q++;
f01033a4:	83 c0 01             	add    $0x1,%eax
f01033a7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01033aa:	39 d8                	cmp    %ebx,%eax
f01033ac:	74 15                	je     f01033c3 <strncmp+0x30>
f01033ae:	0f b6 08             	movzbl (%eax),%ecx
f01033b1:	84 c9                	test   %cl,%cl
f01033b3:	74 04                	je     f01033b9 <strncmp+0x26>
f01033b5:	3a 0a                	cmp    (%edx),%cl
f01033b7:	74 eb                	je     f01033a4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01033b9:	0f b6 00             	movzbl (%eax),%eax
f01033bc:	0f b6 12             	movzbl (%edx),%edx
f01033bf:	29 d0                	sub    %edx,%eax
f01033c1:	eb 05                	jmp    f01033c8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01033c3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01033c8:	5b                   	pop    %ebx
f01033c9:	5d                   	pop    %ebp
f01033ca:	c3                   	ret    

f01033cb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01033cb:	55                   	push   %ebp
f01033cc:	89 e5                	mov    %esp,%ebp
f01033ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01033d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01033d5:	eb 07                	jmp    f01033de <strchr+0x13>
		if (*s == c)
f01033d7:	38 ca                	cmp    %cl,%dl
f01033d9:	74 0f                	je     f01033ea <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01033db:	83 c0 01             	add    $0x1,%eax
f01033de:	0f b6 10             	movzbl (%eax),%edx
f01033e1:	84 d2                	test   %dl,%dl
f01033e3:	75 f2                	jne    f01033d7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f01033e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033ea:	5d                   	pop    %ebp
f01033eb:	c3                   	ret    

f01033ec <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01033ec:	55                   	push   %ebp
f01033ed:	89 e5                	mov    %esp,%ebp
f01033ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01033f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01033f6:	eb 03                	jmp    f01033fb <strfind+0xf>
f01033f8:	83 c0 01             	add    $0x1,%eax
f01033fb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01033fe:	38 ca                	cmp    %cl,%dl
f0103400:	74 04                	je     f0103406 <strfind+0x1a>
f0103402:	84 d2                	test   %dl,%dl
f0103404:	75 f2                	jne    f01033f8 <strfind+0xc>
			break;
	return (char *) s;
}
f0103406:	5d                   	pop    %ebp
f0103407:	c3                   	ret    

f0103408 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103408:	55                   	push   %ebp
f0103409:	89 e5                	mov    %esp,%ebp
f010340b:	57                   	push   %edi
f010340c:	56                   	push   %esi
f010340d:	53                   	push   %ebx
f010340e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103411:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103414:	85 c9                	test   %ecx,%ecx
f0103416:	74 36                	je     f010344e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103418:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010341e:	75 28                	jne    f0103448 <memset+0x40>
f0103420:	f6 c1 03             	test   $0x3,%cl
f0103423:	75 23                	jne    f0103448 <memset+0x40>
		c &= 0xFF;
f0103425:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103429:	89 d3                	mov    %edx,%ebx
f010342b:	c1 e3 08             	shl    $0x8,%ebx
f010342e:	89 d6                	mov    %edx,%esi
f0103430:	c1 e6 18             	shl    $0x18,%esi
f0103433:	89 d0                	mov    %edx,%eax
f0103435:	c1 e0 10             	shl    $0x10,%eax
f0103438:	09 f0                	or     %esi,%eax
f010343a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010343c:	89 d8                	mov    %ebx,%eax
f010343e:	09 d0                	or     %edx,%eax
f0103440:	c1 e9 02             	shr    $0x2,%ecx
f0103443:	fc                   	cld    
f0103444:	f3 ab                	rep stos %eax,%es:(%edi)
f0103446:	eb 06                	jmp    f010344e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103448:	8b 45 0c             	mov    0xc(%ebp),%eax
f010344b:	fc                   	cld    
f010344c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010344e:	89 f8                	mov    %edi,%eax
f0103450:	5b                   	pop    %ebx
f0103451:	5e                   	pop    %esi
f0103452:	5f                   	pop    %edi
f0103453:	5d                   	pop    %ebp
f0103454:	c3                   	ret    

f0103455 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103455:	55                   	push   %ebp
f0103456:	89 e5                	mov    %esp,%ebp
f0103458:	57                   	push   %edi
f0103459:	56                   	push   %esi
f010345a:	8b 45 08             	mov    0x8(%ebp),%eax
f010345d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103460:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103463:	39 c6                	cmp    %eax,%esi
f0103465:	73 35                	jae    f010349c <memmove+0x47>
f0103467:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010346a:	39 d0                	cmp    %edx,%eax
f010346c:	73 2e                	jae    f010349c <memmove+0x47>
		s += n;
		d += n;
f010346e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103471:	89 d6                	mov    %edx,%esi
f0103473:	09 fe                	or     %edi,%esi
f0103475:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010347b:	75 13                	jne    f0103490 <memmove+0x3b>
f010347d:	f6 c1 03             	test   $0x3,%cl
f0103480:	75 0e                	jne    f0103490 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0103482:	83 ef 04             	sub    $0x4,%edi
f0103485:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103488:	c1 e9 02             	shr    $0x2,%ecx
f010348b:	fd                   	std    
f010348c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010348e:	eb 09                	jmp    f0103499 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103490:	83 ef 01             	sub    $0x1,%edi
f0103493:	8d 72 ff             	lea    -0x1(%edx),%esi
f0103496:	fd                   	std    
f0103497:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103499:	fc                   	cld    
f010349a:	eb 1d                	jmp    f01034b9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010349c:	89 f2                	mov    %esi,%edx
f010349e:	09 c2                	or     %eax,%edx
f01034a0:	f6 c2 03             	test   $0x3,%dl
f01034a3:	75 0f                	jne    f01034b4 <memmove+0x5f>
f01034a5:	f6 c1 03             	test   $0x3,%cl
f01034a8:	75 0a                	jne    f01034b4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01034aa:	c1 e9 02             	shr    $0x2,%ecx
f01034ad:	89 c7                	mov    %eax,%edi
f01034af:	fc                   	cld    
f01034b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01034b2:	eb 05                	jmp    f01034b9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01034b4:	89 c7                	mov    %eax,%edi
f01034b6:	fc                   	cld    
f01034b7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01034b9:	5e                   	pop    %esi
f01034ba:	5f                   	pop    %edi
f01034bb:	5d                   	pop    %ebp
f01034bc:	c3                   	ret    

f01034bd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01034bd:	55                   	push   %ebp
f01034be:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01034c0:	ff 75 10             	pushl  0x10(%ebp)
f01034c3:	ff 75 0c             	pushl  0xc(%ebp)
f01034c6:	ff 75 08             	pushl  0x8(%ebp)
f01034c9:	e8 87 ff ff ff       	call   f0103455 <memmove>
}
f01034ce:	c9                   	leave  
f01034cf:	c3                   	ret    

f01034d0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01034d0:	55                   	push   %ebp
f01034d1:	89 e5                	mov    %esp,%ebp
f01034d3:	56                   	push   %esi
f01034d4:	53                   	push   %ebx
f01034d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01034d8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01034db:	89 c6                	mov    %eax,%esi
f01034dd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01034e0:	eb 1a                	jmp    f01034fc <memcmp+0x2c>
		if (*s1 != *s2)
f01034e2:	0f b6 08             	movzbl (%eax),%ecx
f01034e5:	0f b6 1a             	movzbl (%edx),%ebx
f01034e8:	38 d9                	cmp    %bl,%cl
f01034ea:	74 0a                	je     f01034f6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f01034ec:	0f b6 c1             	movzbl %cl,%eax
f01034ef:	0f b6 db             	movzbl %bl,%ebx
f01034f2:	29 d8                	sub    %ebx,%eax
f01034f4:	eb 0f                	jmp    f0103505 <memcmp+0x35>
		s1++, s2++;
f01034f6:	83 c0 01             	add    $0x1,%eax
f01034f9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01034fc:	39 f0                	cmp    %esi,%eax
f01034fe:	75 e2                	jne    f01034e2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103500:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103505:	5b                   	pop    %ebx
f0103506:	5e                   	pop    %esi
f0103507:	5d                   	pop    %ebp
f0103508:	c3                   	ret    

f0103509 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103509:	55                   	push   %ebp
f010350a:	89 e5                	mov    %esp,%ebp
f010350c:	53                   	push   %ebx
f010350d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103510:	89 c1                	mov    %eax,%ecx
f0103512:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0103515:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103519:	eb 0a                	jmp    f0103525 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010351b:	0f b6 10             	movzbl (%eax),%edx
f010351e:	39 da                	cmp    %ebx,%edx
f0103520:	74 07                	je     f0103529 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103522:	83 c0 01             	add    $0x1,%eax
f0103525:	39 c8                	cmp    %ecx,%eax
f0103527:	72 f2                	jb     f010351b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103529:	5b                   	pop    %ebx
f010352a:	5d                   	pop    %ebp
f010352b:	c3                   	ret    

f010352c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010352c:	55                   	push   %ebp
f010352d:	89 e5                	mov    %esp,%ebp
f010352f:	57                   	push   %edi
f0103530:	56                   	push   %esi
f0103531:	53                   	push   %ebx
f0103532:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103535:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103538:	eb 03                	jmp    f010353d <strtol+0x11>
		s++;
f010353a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010353d:	0f b6 01             	movzbl (%ecx),%eax
f0103540:	3c 20                	cmp    $0x20,%al
f0103542:	74 f6                	je     f010353a <strtol+0xe>
f0103544:	3c 09                	cmp    $0x9,%al
f0103546:	74 f2                	je     f010353a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103548:	3c 2b                	cmp    $0x2b,%al
f010354a:	75 0a                	jne    f0103556 <strtol+0x2a>
		s++;
f010354c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010354f:	bf 00 00 00 00       	mov    $0x0,%edi
f0103554:	eb 11                	jmp    f0103567 <strtol+0x3b>
f0103556:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010355b:	3c 2d                	cmp    $0x2d,%al
f010355d:	75 08                	jne    f0103567 <strtol+0x3b>
		s++, neg = 1;
f010355f:	83 c1 01             	add    $0x1,%ecx
f0103562:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103567:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010356d:	75 15                	jne    f0103584 <strtol+0x58>
f010356f:	80 39 30             	cmpb   $0x30,(%ecx)
f0103572:	75 10                	jne    f0103584 <strtol+0x58>
f0103574:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0103578:	75 7c                	jne    f01035f6 <strtol+0xca>
		s += 2, base = 16;
f010357a:	83 c1 02             	add    $0x2,%ecx
f010357d:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103582:	eb 16                	jmp    f010359a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0103584:	85 db                	test   %ebx,%ebx
f0103586:	75 12                	jne    f010359a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0103588:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010358d:	80 39 30             	cmpb   $0x30,(%ecx)
f0103590:	75 08                	jne    f010359a <strtol+0x6e>
		s++, base = 8;
f0103592:	83 c1 01             	add    $0x1,%ecx
f0103595:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010359a:	b8 00 00 00 00       	mov    $0x0,%eax
f010359f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01035a2:	0f b6 11             	movzbl (%ecx),%edx
f01035a5:	8d 72 d0             	lea    -0x30(%edx),%esi
f01035a8:	89 f3                	mov    %esi,%ebx
f01035aa:	80 fb 09             	cmp    $0x9,%bl
f01035ad:	77 08                	ja     f01035b7 <strtol+0x8b>
			dig = *s - '0';
f01035af:	0f be d2             	movsbl %dl,%edx
f01035b2:	83 ea 30             	sub    $0x30,%edx
f01035b5:	eb 22                	jmp    f01035d9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01035b7:	8d 72 9f             	lea    -0x61(%edx),%esi
f01035ba:	89 f3                	mov    %esi,%ebx
f01035bc:	80 fb 19             	cmp    $0x19,%bl
f01035bf:	77 08                	ja     f01035c9 <strtol+0x9d>
			dig = *s - 'a' + 10;
f01035c1:	0f be d2             	movsbl %dl,%edx
f01035c4:	83 ea 57             	sub    $0x57,%edx
f01035c7:	eb 10                	jmp    f01035d9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f01035c9:	8d 72 bf             	lea    -0x41(%edx),%esi
f01035cc:	89 f3                	mov    %esi,%ebx
f01035ce:	80 fb 19             	cmp    $0x19,%bl
f01035d1:	77 16                	ja     f01035e9 <strtol+0xbd>
			dig = *s - 'A' + 10;
f01035d3:	0f be d2             	movsbl %dl,%edx
f01035d6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f01035d9:	3b 55 10             	cmp    0x10(%ebp),%edx
f01035dc:	7d 0b                	jge    f01035e9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f01035de:	83 c1 01             	add    $0x1,%ecx
f01035e1:	0f af 45 10          	imul   0x10(%ebp),%eax
f01035e5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f01035e7:	eb b9                	jmp    f01035a2 <strtol+0x76>

	if (endptr)
f01035e9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01035ed:	74 0d                	je     f01035fc <strtol+0xd0>
		*endptr = (char *) s;
f01035ef:	8b 75 0c             	mov    0xc(%ebp),%esi
f01035f2:	89 0e                	mov    %ecx,(%esi)
f01035f4:	eb 06                	jmp    f01035fc <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01035f6:	85 db                	test   %ebx,%ebx
f01035f8:	74 98                	je     f0103592 <strtol+0x66>
f01035fa:	eb 9e                	jmp    f010359a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f01035fc:	89 c2                	mov    %eax,%edx
f01035fe:	f7 da                	neg    %edx
f0103600:	85 ff                	test   %edi,%edi
f0103602:	0f 45 c2             	cmovne %edx,%eax
}
f0103605:	5b                   	pop    %ebx
f0103606:	5e                   	pop    %esi
f0103607:	5f                   	pop    %edi
f0103608:	5d                   	pop    %ebp
f0103609:	c3                   	ret    
f010360a:	66 90                	xchg   %ax,%ax
f010360c:	66 90                	xchg   %ax,%ax
f010360e:	66 90                	xchg   %ax,%ax

f0103610 <__udivdi3>:
f0103610:	55                   	push   %ebp
f0103611:	57                   	push   %edi
f0103612:	56                   	push   %esi
f0103613:	53                   	push   %ebx
f0103614:	83 ec 1c             	sub    $0x1c,%esp
f0103617:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010361b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010361f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0103623:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103627:	85 f6                	test   %esi,%esi
f0103629:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010362d:	89 ca                	mov    %ecx,%edx
f010362f:	89 f8                	mov    %edi,%eax
f0103631:	75 3d                	jne    f0103670 <__udivdi3+0x60>
f0103633:	39 cf                	cmp    %ecx,%edi
f0103635:	0f 87 c5 00 00 00    	ja     f0103700 <__udivdi3+0xf0>
f010363b:	85 ff                	test   %edi,%edi
f010363d:	89 fd                	mov    %edi,%ebp
f010363f:	75 0b                	jne    f010364c <__udivdi3+0x3c>
f0103641:	b8 01 00 00 00       	mov    $0x1,%eax
f0103646:	31 d2                	xor    %edx,%edx
f0103648:	f7 f7                	div    %edi
f010364a:	89 c5                	mov    %eax,%ebp
f010364c:	89 c8                	mov    %ecx,%eax
f010364e:	31 d2                	xor    %edx,%edx
f0103650:	f7 f5                	div    %ebp
f0103652:	89 c1                	mov    %eax,%ecx
f0103654:	89 d8                	mov    %ebx,%eax
f0103656:	89 cf                	mov    %ecx,%edi
f0103658:	f7 f5                	div    %ebp
f010365a:	89 c3                	mov    %eax,%ebx
f010365c:	89 d8                	mov    %ebx,%eax
f010365e:	89 fa                	mov    %edi,%edx
f0103660:	83 c4 1c             	add    $0x1c,%esp
f0103663:	5b                   	pop    %ebx
f0103664:	5e                   	pop    %esi
f0103665:	5f                   	pop    %edi
f0103666:	5d                   	pop    %ebp
f0103667:	c3                   	ret    
f0103668:	90                   	nop
f0103669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103670:	39 ce                	cmp    %ecx,%esi
f0103672:	77 74                	ja     f01036e8 <__udivdi3+0xd8>
f0103674:	0f bd fe             	bsr    %esi,%edi
f0103677:	83 f7 1f             	xor    $0x1f,%edi
f010367a:	0f 84 98 00 00 00    	je     f0103718 <__udivdi3+0x108>
f0103680:	bb 20 00 00 00       	mov    $0x20,%ebx
f0103685:	89 f9                	mov    %edi,%ecx
f0103687:	89 c5                	mov    %eax,%ebp
f0103689:	29 fb                	sub    %edi,%ebx
f010368b:	d3 e6                	shl    %cl,%esi
f010368d:	89 d9                	mov    %ebx,%ecx
f010368f:	d3 ed                	shr    %cl,%ebp
f0103691:	89 f9                	mov    %edi,%ecx
f0103693:	d3 e0                	shl    %cl,%eax
f0103695:	09 ee                	or     %ebp,%esi
f0103697:	89 d9                	mov    %ebx,%ecx
f0103699:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010369d:	89 d5                	mov    %edx,%ebp
f010369f:	8b 44 24 08          	mov    0x8(%esp),%eax
f01036a3:	d3 ed                	shr    %cl,%ebp
f01036a5:	89 f9                	mov    %edi,%ecx
f01036a7:	d3 e2                	shl    %cl,%edx
f01036a9:	89 d9                	mov    %ebx,%ecx
f01036ab:	d3 e8                	shr    %cl,%eax
f01036ad:	09 c2                	or     %eax,%edx
f01036af:	89 d0                	mov    %edx,%eax
f01036b1:	89 ea                	mov    %ebp,%edx
f01036b3:	f7 f6                	div    %esi
f01036b5:	89 d5                	mov    %edx,%ebp
f01036b7:	89 c3                	mov    %eax,%ebx
f01036b9:	f7 64 24 0c          	mull   0xc(%esp)
f01036bd:	39 d5                	cmp    %edx,%ebp
f01036bf:	72 10                	jb     f01036d1 <__udivdi3+0xc1>
f01036c1:	8b 74 24 08          	mov    0x8(%esp),%esi
f01036c5:	89 f9                	mov    %edi,%ecx
f01036c7:	d3 e6                	shl    %cl,%esi
f01036c9:	39 c6                	cmp    %eax,%esi
f01036cb:	73 07                	jae    f01036d4 <__udivdi3+0xc4>
f01036cd:	39 d5                	cmp    %edx,%ebp
f01036cf:	75 03                	jne    f01036d4 <__udivdi3+0xc4>
f01036d1:	83 eb 01             	sub    $0x1,%ebx
f01036d4:	31 ff                	xor    %edi,%edi
f01036d6:	89 d8                	mov    %ebx,%eax
f01036d8:	89 fa                	mov    %edi,%edx
f01036da:	83 c4 1c             	add    $0x1c,%esp
f01036dd:	5b                   	pop    %ebx
f01036de:	5e                   	pop    %esi
f01036df:	5f                   	pop    %edi
f01036e0:	5d                   	pop    %ebp
f01036e1:	c3                   	ret    
f01036e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01036e8:	31 ff                	xor    %edi,%edi
f01036ea:	31 db                	xor    %ebx,%ebx
f01036ec:	89 d8                	mov    %ebx,%eax
f01036ee:	89 fa                	mov    %edi,%edx
f01036f0:	83 c4 1c             	add    $0x1c,%esp
f01036f3:	5b                   	pop    %ebx
f01036f4:	5e                   	pop    %esi
f01036f5:	5f                   	pop    %edi
f01036f6:	5d                   	pop    %ebp
f01036f7:	c3                   	ret    
f01036f8:	90                   	nop
f01036f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103700:	89 d8                	mov    %ebx,%eax
f0103702:	f7 f7                	div    %edi
f0103704:	31 ff                	xor    %edi,%edi
f0103706:	89 c3                	mov    %eax,%ebx
f0103708:	89 d8                	mov    %ebx,%eax
f010370a:	89 fa                	mov    %edi,%edx
f010370c:	83 c4 1c             	add    $0x1c,%esp
f010370f:	5b                   	pop    %ebx
f0103710:	5e                   	pop    %esi
f0103711:	5f                   	pop    %edi
f0103712:	5d                   	pop    %ebp
f0103713:	c3                   	ret    
f0103714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103718:	39 ce                	cmp    %ecx,%esi
f010371a:	72 0c                	jb     f0103728 <__udivdi3+0x118>
f010371c:	31 db                	xor    %ebx,%ebx
f010371e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0103722:	0f 87 34 ff ff ff    	ja     f010365c <__udivdi3+0x4c>
f0103728:	bb 01 00 00 00       	mov    $0x1,%ebx
f010372d:	e9 2a ff ff ff       	jmp    f010365c <__udivdi3+0x4c>
f0103732:	66 90                	xchg   %ax,%ax
f0103734:	66 90                	xchg   %ax,%ax
f0103736:	66 90                	xchg   %ax,%ax
f0103738:	66 90                	xchg   %ax,%ax
f010373a:	66 90                	xchg   %ax,%ax
f010373c:	66 90                	xchg   %ax,%ax
f010373e:	66 90                	xchg   %ax,%ax

f0103740 <__umoddi3>:
f0103740:	55                   	push   %ebp
f0103741:	57                   	push   %edi
f0103742:	56                   	push   %esi
f0103743:	53                   	push   %ebx
f0103744:	83 ec 1c             	sub    $0x1c,%esp
f0103747:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010374b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010374f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103753:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103757:	85 d2                	test   %edx,%edx
f0103759:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010375d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0103761:	89 f3                	mov    %esi,%ebx
f0103763:	89 3c 24             	mov    %edi,(%esp)
f0103766:	89 74 24 04          	mov    %esi,0x4(%esp)
f010376a:	75 1c                	jne    f0103788 <__umoddi3+0x48>
f010376c:	39 f7                	cmp    %esi,%edi
f010376e:	76 50                	jbe    f01037c0 <__umoddi3+0x80>
f0103770:	89 c8                	mov    %ecx,%eax
f0103772:	89 f2                	mov    %esi,%edx
f0103774:	f7 f7                	div    %edi
f0103776:	89 d0                	mov    %edx,%eax
f0103778:	31 d2                	xor    %edx,%edx
f010377a:	83 c4 1c             	add    $0x1c,%esp
f010377d:	5b                   	pop    %ebx
f010377e:	5e                   	pop    %esi
f010377f:	5f                   	pop    %edi
f0103780:	5d                   	pop    %ebp
f0103781:	c3                   	ret    
f0103782:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103788:	39 f2                	cmp    %esi,%edx
f010378a:	89 d0                	mov    %edx,%eax
f010378c:	77 52                	ja     f01037e0 <__umoddi3+0xa0>
f010378e:	0f bd ea             	bsr    %edx,%ebp
f0103791:	83 f5 1f             	xor    $0x1f,%ebp
f0103794:	75 5a                	jne    f01037f0 <__umoddi3+0xb0>
f0103796:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010379a:	0f 82 e0 00 00 00    	jb     f0103880 <__umoddi3+0x140>
f01037a0:	39 0c 24             	cmp    %ecx,(%esp)
f01037a3:	0f 86 d7 00 00 00    	jbe    f0103880 <__umoddi3+0x140>
f01037a9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01037ad:	8b 54 24 04          	mov    0x4(%esp),%edx
f01037b1:	83 c4 1c             	add    $0x1c,%esp
f01037b4:	5b                   	pop    %ebx
f01037b5:	5e                   	pop    %esi
f01037b6:	5f                   	pop    %edi
f01037b7:	5d                   	pop    %ebp
f01037b8:	c3                   	ret    
f01037b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01037c0:	85 ff                	test   %edi,%edi
f01037c2:	89 fd                	mov    %edi,%ebp
f01037c4:	75 0b                	jne    f01037d1 <__umoddi3+0x91>
f01037c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01037cb:	31 d2                	xor    %edx,%edx
f01037cd:	f7 f7                	div    %edi
f01037cf:	89 c5                	mov    %eax,%ebp
f01037d1:	89 f0                	mov    %esi,%eax
f01037d3:	31 d2                	xor    %edx,%edx
f01037d5:	f7 f5                	div    %ebp
f01037d7:	89 c8                	mov    %ecx,%eax
f01037d9:	f7 f5                	div    %ebp
f01037db:	89 d0                	mov    %edx,%eax
f01037dd:	eb 99                	jmp    f0103778 <__umoddi3+0x38>
f01037df:	90                   	nop
f01037e0:	89 c8                	mov    %ecx,%eax
f01037e2:	89 f2                	mov    %esi,%edx
f01037e4:	83 c4 1c             	add    $0x1c,%esp
f01037e7:	5b                   	pop    %ebx
f01037e8:	5e                   	pop    %esi
f01037e9:	5f                   	pop    %edi
f01037ea:	5d                   	pop    %ebp
f01037eb:	c3                   	ret    
f01037ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01037f0:	8b 34 24             	mov    (%esp),%esi
f01037f3:	bf 20 00 00 00       	mov    $0x20,%edi
f01037f8:	89 e9                	mov    %ebp,%ecx
f01037fa:	29 ef                	sub    %ebp,%edi
f01037fc:	d3 e0                	shl    %cl,%eax
f01037fe:	89 f9                	mov    %edi,%ecx
f0103800:	89 f2                	mov    %esi,%edx
f0103802:	d3 ea                	shr    %cl,%edx
f0103804:	89 e9                	mov    %ebp,%ecx
f0103806:	09 c2                	or     %eax,%edx
f0103808:	89 d8                	mov    %ebx,%eax
f010380a:	89 14 24             	mov    %edx,(%esp)
f010380d:	89 f2                	mov    %esi,%edx
f010380f:	d3 e2                	shl    %cl,%edx
f0103811:	89 f9                	mov    %edi,%ecx
f0103813:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103817:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010381b:	d3 e8                	shr    %cl,%eax
f010381d:	89 e9                	mov    %ebp,%ecx
f010381f:	89 c6                	mov    %eax,%esi
f0103821:	d3 e3                	shl    %cl,%ebx
f0103823:	89 f9                	mov    %edi,%ecx
f0103825:	89 d0                	mov    %edx,%eax
f0103827:	d3 e8                	shr    %cl,%eax
f0103829:	89 e9                	mov    %ebp,%ecx
f010382b:	09 d8                	or     %ebx,%eax
f010382d:	89 d3                	mov    %edx,%ebx
f010382f:	89 f2                	mov    %esi,%edx
f0103831:	f7 34 24             	divl   (%esp)
f0103834:	89 d6                	mov    %edx,%esi
f0103836:	d3 e3                	shl    %cl,%ebx
f0103838:	f7 64 24 04          	mull   0x4(%esp)
f010383c:	39 d6                	cmp    %edx,%esi
f010383e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103842:	89 d1                	mov    %edx,%ecx
f0103844:	89 c3                	mov    %eax,%ebx
f0103846:	72 08                	jb     f0103850 <__umoddi3+0x110>
f0103848:	75 11                	jne    f010385b <__umoddi3+0x11b>
f010384a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010384e:	73 0b                	jae    f010385b <__umoddi3+0x11b>
f0103850:	2b 44 24 04          	sub    0x4(%esp),%eax
f0103854:	1b 14 24             	sbb    (%esp),%edx
f0103857:	89 d1                	mov    %edx,%ecx
f0103859:	89 c3                	mov    %eax,%ebx
f010385b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010385f:	29 da                	sub    %ebx,%edx
f0103861:	19 ce                	sbb    %ecx,%esi
f0103863:	89 f9                	mov    %edi,%ecx
f0103865:	89 f0                	mov    %esi,%eax
f0103867:	d3 e0                	shl    %cl,%eax
f0103869:	89 e9                	mov    %ebp,%ecx
f010386b:	d3 ea                	shr    %cl,%edx
f010386d:	89 e9                	mov    %ebp,%ecx
f010386f:	d3 ee                	shr    %cl,%esi
f0103871:	09 d0                	or     %edx,%eax
f0103873:	89 f2                	mov    %esi,%edx
f0103875:	83 c4 1c             	add    $0x1c,%esp
f0103878:	5b                   	pop    %ebx
f0103879:	5e                   	pop    %esi
f010387a:	5f                   	pop    %edi
f010387b:	5d                   	pop    %ebp
f010387c:	c3                   	ret    
f010387d:	8d 76 00             	lea    0x0(%esi),%esi
f0103880:	29 f9                	sub    %edi,%ecx
f0103882:	19 d6                	sbb    %edx,%esi
f0103884:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103888:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010388c:	e9 18 ff ff ff       	jmp    f01037a9 <__umoddi3+0x69>
