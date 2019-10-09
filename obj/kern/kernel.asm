
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 20 19 10 f0       	push   $0xf0101920
f0100050:	e8 59 09 00 00       	call   f01009ae <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 fd 06 00 00       	call   f0100778 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 3c 19 10 f0       	push   $0xf010193c
f0100087:	e8 22 09 00 00       	call   f01009ae <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 c1 13 00 00       	call   f0101472 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 a7 04 00 00       	call   f010055d <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 57 19 10 f0       	push   $0xf0101957
f01000c3:	e8 e6 08 00 00       	call   f01009ae <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 11 07 00 00       	call   f01007f2 <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 72 19 10 f0       	push   $0xf0101972
f0100110:	e8 99 08 00 00       	call   f01009ae <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 69 08 00 00       	call   f0100988 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 ae 19 10 f0 	movl   $0xf01019ae,(%esp)
f0100126:	e8 83 08 00 00       	call   f01009ae <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 ba 06 00 00       	call   f01007f2 <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 8a 19 10 f0       	push   $0xf010198a
f0100152:	e8 57 08 00 00       	call   f01009ae <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 25 08 00 00       	call   f0100988 <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 ae 19 10 f0 	movl   $0xf01019ae,(%esp)
f010016a:	e8 3f 08 00 00       	call   f01009ae <cprintf>
	va_end(ap);
}
f010016f:	83 c4 10             	add    $0x10,%esp
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 0b                	je     f010018f <serial_proc_data+0x18>
f0100184:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100189:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018a:	0f b6 c0             	movzbl %al,%eax
f010018d:	eb 05                	jmp    f0100194 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100194:	5d                   	pop    %ebp
f0100195:	c3                   	ret    

f0100196 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	53                   	push   %ebx
f010019a:	83 ec 04             	sub    $0x4,%esp
f010019d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019f:	eb 2b                	jmp    f01001cc <cons_intr+0x36>
		if (c == 0)
f01001a1:	85 c0                	test   %eax,%eax
f01001a3:	74 27                	je     f01001cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a5:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ae:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001b4:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c0:	75 0a                	jne    f01001cc <cons_intr+0x36>
			cons.wpos = 0;
f01001c2:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001cc:	ff d3                	call   *%ebx
f01001ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d1:	75 ce                	jne    f01001a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d3:	83 c4 04             	add    $0x4,%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    

f01001d9 <kbd_proc_data>:
f01001d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001de:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001df:	a8 01                	test   $0x1,%al
f01001e1:	0f 84 f0 00 00 00    	je     f01002d7 <kbd_proc_data+0xfe>
f01001e7:	ba 60 00 00 00       	mov    $0x60,%edx
f01001ec:	ec                   	in     (%dx),%al
f01001ed:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001ef:	3c e0                	cmp    $0xe0,%al
f01001f1:	75 0d                	jne    f0100200 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001f3:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f01001fa:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001ff:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100200:	55                   	push   %ebp
f0100201:	89 e5                	mov    %esp,%ebp
f0100203:	53                   	push   %ebx
f0100204:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100207:	84 c0                	test   %al,%al
f0100209:	79 36                	jns    f0100241 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010020b:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100211:	89 cb                	mov    %ecx,%ebx
f0100213:	83 e3 40             	and    $0x40,%ebx
f0100216:	83 e0 7f             	and    $0x7f,%eax
f0100219:	85 db                	test   %ebx,%ebx
f010021b:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010021e:	0f b6 d2             	movzbl %dl,%edx
f0100221:	0f b6 82 00 1b 10 f0 	movzbl -0xfefe500(%edx),%eax
f0100228:	83 c8 40             	or     $0x40,%eax
f010022b:	0f b6 c0             	movzbl %al,%eax
f010022e:	f7 d0                	not    %eax
f0100230:	21 c8                	and    %ecx,%eax
f0100232:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f0100237:	b8 00 00 00 00       	mov    $0x0,%eax
f010023c:	e9 9e 00 00 00       	jmp    f01002df <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100241:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100247:	f6 c1 40             	test   $0x40,%cl
f010024a:	74 0e                	je     f010025a <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010024c:	83 c8 80             	or     $0xffffff80,%eax
f010024f:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100251:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100254:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f010025a:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010025d:	0f b6 82 00 1b 10 f0 	movzbl -0xfefe500(%edx),%eax
f0100264:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f010026a:	0f b6 8a 00 1a 10 f0 	movzbl -0xfefe600(%edx),%ecx
f0100271:	31 c8                	xor    %ecx,%eax
f0100273:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100278:	89 c1                	mov    %eax,%ecx
f010027a:	83 e1 03             	and    $0x3,%ecx
f010027d:	8b 0c 8d e0 19 10 f0 	mov    -0xfefe620(,%ecx,4),%ecx
f0100284:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100288:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010028b:	a8 08                	test   $0x8,%al
f010028d:	74 1b                	je     f01002aa <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f010028f:	89 da                	mov    %ebx,%edx
f0100291:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100294:	83 f9 19             	cmp    $0x19,%ecx
f0100297:	77 05                	ja     f010029e <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100299:	83 eb 20             	sub    $0x20,%ebx
f010029c:	eb 0c                	jmp    f01002aa <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010029e:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002a1:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002a4:	83 fa 19             	cmp    $0x19,%edx
f01002a7:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002aa:	f7 d0                	not    %eax
f01002ac:	a8 06                	test   $0x6,%al
f01002ae:	75 2d                	jne    f01002dd <kbd_proc_data+0x104>
f01002b0:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002b6:	75 25                	jne    f01002dd <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01002b8:	83 ec 0c             	sub    $0xc,%esp
f01002bb:	68 a4 19 10 f0       	push   $0xf01019a4
f01002c0:	e8 e9 06 00 00       	call   f01009ae <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c5:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ca:	b8 03 00 00 00       	mov    $0x3,%eax
f01002cf:	ee                   	out    %al,(%dx)
f01002d0:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002d3:	89 d8                	mov    %ebx,%eax
f01002d5:	eb 08                	jmp    f01002df <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002dc:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002dd:	89 d8                	mov    %ebx,%eax
}
f01002df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002e2:	c9                   	leave  
f01002e3:	c3                   	ret    

f01002e4 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002e4:	55                   	push   %ebp
f01002e5:	89 e5                	mov    %esp,%ebp
f01002e7:	57                   	push   %edi
f01002e8:	56                   	push   %esi
f01002e9:	53                   	push   %ebx
f01002ea:	83 ec 1c             	sub    $0x1c,%esp
f01002ed:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002ef:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f4:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002f9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002fe:	eb 09                	jmp    f0100309 <cons_putc+0x25>
f0100300:	89 ca                	mov    %ecx,%edx
f0100302:	ec                   	in     (%dx),%al
f0100303:	ec                   	in     (%dx),%al
f0100304:	ec                   	in     (%dx),%al
f0100305:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100306:	83 c3 01             	add    $0x1,%ebx
f0100309:	89 f2                	mov    %esi,%edx
f010030b:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010030c:	a8 20                	test   $0x20,%al
f010030e:	75 08                	jne    f0100318 <cons_putc+0x34>
f0100310:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100316:	7e e8                	jle    f0100300 <cons_putc+0x1c>
f0100318:	89 f8                	mov    %edi,%eax
f010031a:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010031d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100322:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100323:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100328:	be 79 03 00 00       	mov    $0x379,%esi
f010032d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100332:	eb 09                	jmp    f010033d <cons_putc+0x59>
f0100334:	89 ca                	mov    %ecx,%edx
f0100336:	ec                   	in     (%dx),%al
f0100337:	ec                   	in     (%dx),%al
f0100338:	ec                   	in     (%dx),%al
f0100339:	ec                   	in     (%dx),%al
f010033a:	83 c3 01             	add    $0x1,%ebx
f010033d:	89 f2                	mov    %esi,%edx
f010033f:	ec                   	in     (%dx),%al
f0100340:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100346:	7f 04                	jg     f010034c <cons_putc+0x68>
f0100348:	84 c0                	test   %al,%al
f010034a:	79 e8                	jns    f0100334 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100351:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100355:	ee                   	out    %al,(%dx)
f0100356:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010035b:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100360:	ee                   	out    %al,(%dx)
f0100361:	b8 08 00 00 00       	mov    $0x8,%eax
f0100366:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF)) {
f0100367:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010036d:	75 22                	jne    f0100391 <cons_putc+0xad>
    	char ch = c & 0xFF;
    		if (ch == 'o' ) {
f010036f:	89 f8                	mov    %edi,%eax
f0100371:	3c 6f                	cmp    $0x6f,%al
f0100373:	75 08                	jne    f010037d <cons_putc+0x99>
        	c |= 0x0100;
f0100375:	81 cf 00 01 00 00    	or     $0x100,%edi
f010037b:	eb 14                	jmp    f0100391 <cons_putc+0xad>
    		} else if (ch == 's' ) {
        	c |= 0x0200;
f010037d:	89 f8                	mov    %edi,%eax
f010037f:	80 cc 02             	or     $0x2,%ah
f0100382:	89 fa                	mov    %edi,%edx
f0100384:	80 ce 07             	or     $0x7,%dh
f0100387:	89 fb                	mov    %edi,%ebx
f0100389:	80 fb 73             	cmp    $0x73,%bl
f010038c:	0f 45 c2             	cmovne %edx,%eax
f010038f:	89 c7                	mov    %eax,%edi
        	c |= 0x0700;
    		}
}


	switch (c & 0xff) {
f0100391:	89 f8                	mov    %edi,%eax
f0100393:	0f b6 c0             	movzbl %al,%eax
f0100396:	83 f8 09             	cmp    $0x9,%eax
f0100399:	74 74                	je     f010040f <cons_putc+0x12b>
f010039b:	83 f8 09             	cmp    $0x9,%eax
f010039e:	7f 0a                	jg     f01003aa <cons_putc+0xc6>
f01003a0:	83 f8 08             	cmp    $0x8,%eax
f01003a3:	74 14                	je     f01003b9 <cons_putc+0xd5>
f01003a5:	e9 99 00 00 00       	jmp    f0100443 <cons_putc+0x15f>
f01003aa:	83 f8 0a             	cmp    $0xa,%eax
f01003ad:	74 3a                	je     f01003e9 <cons_putc+0x105>
f01003af:	83 f8 0d             	cmp    $0xd,%eax
f01003b2:	74 3d                	je     f01003f1 <cons_putc+0x10d>
f01003b4:	e9 8a 00 00 00       	jmp    f0100443 <cons_putc+0x15f>
	case '\b':
		if (crt_pos > 0) {
f01003b9:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003c0:	66 85 c0             	test   %ax,%ax
f01003c3:	0f 84 e6 00 00 00    	je     f01004af <cons_putc+0x1cb>
			crt_pos--;
f01003c9:	83 e8 01             	sub    $0x1,%eax
f01003cc:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003d2:	0f b7 c0             	movzwl %ax,%eax
f01003d5:	66 81 e7 00 ff       	and    $0xff00,%di
f01003da:	83 cf 20             	or     $0x20,%edi
f01003dd:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003e3:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003e7:	eb 78                	jmp    f0100461 <cons_putc+0x17d>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003e9:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003f0:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003f1:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003f8:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003fe:	c1 e8 16             	shr    $0x16,%eax
f0100401:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100404:	c1 e0 04             	shl    $0x4,%eax
f0100407:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f010040d:	eb 52                	jmp    f0100461 <cons_putc+0x17d>
		break;
	case '\t':
		cons_putc(' ');
f010040f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100414:	e8 cb fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f0100419:	b8 20 00 00 00       	mov    $0x20,%eax
f010041e:	e8 c1 fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f0100423:	b8 20 00 00 00       	mov    $0x20,%eax
f0100428:	e8 b7 fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f010042d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100432:	e8 ad fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f0100437:	b8 20 00 00 00       	mov    $0x20,%eax
f010043c:	e8 a3 fe ff ff       	call   f01002e4 <cons_putc>
f0100441:	eb 1e                	jmp    f0100461 <cons_putc+0x17d>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100443:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010044a:	8d 50 01             	lea    0x1(%eax),%edx
f010044d:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f0100454:	0f b7 c0             	movzwl %ax,%eax
f0100457:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f010045d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100461:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f0100468:	cf 07 
f010046a:	76 43                	jbe    f01004af <cons_putc+0x1cb>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010046c:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100471:	83 ec 04             	sub    $0x4,%esp
f0100474:	68 00 0f 00 00       	push   $0xf00
f0100479:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010047f:	52                   	push   %edx
f0100480:	50                   	push   %eax
f0100481:	e8 39 10 00 00       	call   f01014bf <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100486:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f010048c:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100492:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100498:	83 c4 10             	add    $0x10,%esp
f010049b:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004a0:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004a3:	39 d0                	cmp    %edx,%eax
f01004a5:	75 f4                	jne    f010049b <cons_putc+0x1b7>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004a7:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004ae:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004af:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004b5:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004ba:	89 ca                	mov    %ecx,%edx
f01004bc:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004bd:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004c4:	8d 71 01             	lea    0x1(%ecx),%esi
f01004c7:	89 d8                	mov    %ebx,%eax
f01004c9:	66 c1 e8 08          	shr    $0x8,%ax
f01004cd:	89 f2                	mov    %esi,%edx
f01004cf:	ee                   	out    %al,(%dx)
f01004d0:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004d5:	89 ca                	mov    %ecx,%edx
f01004d7:	ee                   	out    %al,(%dx)
f01004d8:	89 d8                	mov    %ebx,%eax
f01004da:	89 f2                	mov    %esi,%edx
f01004dc:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004e0:	5b                   	pop    %ebx
f01004e1:	5e                   	pop    %esi
f01004e2:	5f                   	pop    %edi
f01004e3:	5d                   	pop    %ebp
f01004e4:	c3                   	ret    

f01004e5 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004e5:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004ec:	74 11                	je     f01004ff <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004ee:	55                   	push   %ebp
f01004ef:	89 e5                	mov    %esp,%ebp
f01004f1:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004f4:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004f9:	e8 98 fc ff ff       	call   f0100196 <cons_intr>
}
f01004fe:	c9                   	leave  
f01004ff:	f3 c3                	repz ret 

f0100501 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100501:	55                   	push   %ebp
f0100502:	89 e5                	mov    %esp,%ebp
f0100504:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100507:	b8 d9 01 10 f0       	mov    $0xf01001d9,%eax
f010050c:	e8 85 fc ff ff       	call   f0100196 <cons_intr>
}
f0100511:	c9                   	leave  
f0100512:	c3                   	ret    

f0100513 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100513:	55                   	push   %ebp
f0100514:	89 e5                	mov    %esp,%ebp
f0100516:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100519:	e8 c7 ff ff ff       	call   f01004e5 <serial_intr>
	kbd_intr();
f010051e:	e8 de ff ff ff       	call   f0100501 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100523:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f0100528:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f010052e:	74 26                	je     f0100556 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100530:	8d 50 01             	lea    0x1(%eax),%edx
f0100533:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f0100539:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100540:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100542:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100548:	75 11                	jne    f010055b <cons_getc+0x48>
			cons.rpos = 0;
f010054a:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100551:	00 00 00 
f0100554:	eb 05                	jmp    f010055b <cons_getc+0x48>
		return c;
	}
	return 0;
f0100556:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010055b:	c9                   	leave  
f010055c:	c3                   	ret    

f010055d <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010055d:	55                   	push   %ebp
f010055e:	89 e5                	mov    %esp,%ebp
f0100560:	57                   	push   %edi
f0100561:	56                   	push   %esi
f0100562:	53                   	push   %ebx
f0100563:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100566:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010056d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100574:	5a a5 
	if (*cp != 0xA55A) {
f0100576:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010057d:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100581:	74 11                	je     f0100594 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100583:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f010058a:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010058d:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100592:	eb 16                	jmp    f01005aa <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100594:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010059b:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f01005a2:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005a5:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005aa:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005b0:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b5:	89 fa                	mov    %edi,%edx
f01005b7:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005b8:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005bb:	89 da                	mov    %ebx,%edx
f01005bd:	ec                   	in     (%dx),%al
f01005be:	0f b6 c8             	movzbl %al,%ecx
f01005c1:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c4:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005c9:	89 fa                	mov    %edi,%edx
f01005cb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005cc:	89 da                	mov    %ebx,%edx
f01005ce:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005cf:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f01005d5:	0f b6 c0             	movzbl %al,%eax
f01005d8:	09 c8                	or     %ecx,%eax
f01005da:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e0:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ea:	89 f2                	mov    %esi,%edx
f01005ec:	ee                   	out    %al,(%dx)
f01005ed:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005f2:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005f7:	ee                   	out    %al,(%dx)
f01005f8:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005fd:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100602:	89 da                	mov    %ebx,%edx
f0100604:	ee                   	out    %al,(%dx)
f0100605:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010060a:	b8 00 00 00 00       	mov    $0x0,%eax
f010060f:	ee                   	out    %al,(%dx)
f0100610:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100615:	b8 03 00 00 00       	mov    $0x3,%eax
f010061a:	ee                   	out    %al,(%dx)
f010061b:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100620:	b8 00 00 00 00       	mov    $0x0,%eax
f0100625:	ee                   	out    %al,(%dx)
f0100626:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010062b:	b8 01 00 00 00       	mov    $0x1,%eax
f0100630:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100631:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100636:	ec                   	in     (%dx),%al
f0100637:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100639:	3c ff                	cmp    $0xff,%al
f010063b:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100642:	89 f2                	mov    %esi,%edx
f0100644:	ec                   	in     (%dx),%al
f0100645:	89 da                	mov    %ebx,%edx
f0100647:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100648:	80 f9 ff             	cmp    $0xff,%cl
f010064b:	75 10                	jne    f010065d <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f010064d:	83 ec 0c             	sub    $0xc,%esp
f0100650:	68 b0 19 10 f0       	push   $0xf01019b0
f0100655:	e8 54 03 00 00       	call   f01009ae <cprintf>
f010065a:	83 c4 10             	add    $0x10,%esp
}
f010065d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100660:	5b                   	pop    %ebx
f0100661:	5e                   	pop    %esi
f0100662:	5f                   	pop    %edi
f0100663:	5d                   	pop    %ebp
f0100664:	c3                   	ret    

f0100665 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100665:	55                   	push   %ebp
f0100666:	89 e5                	mov    %esp,%ebp
f0100668:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010066b:	8b 45 08             	mov    0x8(%ebp),%eax
f010066e:	e8 71 fc ff ff       	call   f01002e4 <cons_putc>
}
f0100673:	c9                   	leave  
f0100674:	c3                   	ret    

f0100675 <getchar>:

int
getchar(void)
{
f0100675:	55                   	push   %ebp
f0100676:	89 e5                	mov    %esp,%ebp
f0100678:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010067b:	e8 93 fe ff ff       	call   f0100513 <cons_getc>
f0100680:	85 c0                	test   %eax,%eax
f0100682:	74 f7                	je     f010067b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100684:	c9                   	leave  
f0100685:	c3                   	ret    

f0100686 <iscons>:

int
iscons(int fdnum)
{
f0100686:	55                   	push   %ebp
f0100687:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100689:	b8 01 00 00 00       	mov    $0x1,%eax
f010068e:	5d                   	pop    %ebp
f010068f:	c3                   	ret    

f0100690 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100690:	55                   	push   %ebp
f0100691:	89 e5                	mov    %esp,%ebp
f0100693:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100696:	68 00 1c 10 f0       	push   $0xf0101c00
f010069b:	68 1e 1c 10 f0       	push   $0xf0101c1e
f01006a0:	68 23 1c 10 f0       	push   $0xf0101c23
f01006a5:	e8 04 03 00 00       	call   f01009ae <cprintf>
f01006aa:	83 c4 0c             	add    $0xc,%esp
f01006ad:	68 d0 1c 10 f0       	push   $0xf0101cd0
f01006b2:	68 2c 1c 10 f0       	push   $0xf0101c2c
f01006b7:	68 23 1c 10 f0       	push   $0xf0101c23
f01006bc:	e8 ed 02 00 00       	call   f01009ae <cprintf>
	return 0;
}
f01006c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01006c6:	c9                   	leave  
f01006c7:	c3                   	ret    

f01006c8 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006c8:	55                   	push   %ebp
f01006c9:	89 e5                	mov    %esp,%ebp
f01006cb:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006ce:	68 35 1c 10 f0       	push   $0xf0101c35
f01006d3:	e8 d6 02 00 00       	call   f01009ae <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006d8:	83 c4 08             	add    $0x8,%esp
f01006db:	68 0c 00 10 00       	push   $0x10000c
f01006e0:	68 f8 1c 10 f0       	push   $0xf0101cf8
f01006e5:	e8 c4 02 00 00       	call   f01009ae <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006ea:	83 c4 0c             	add    $0xc,%esp
f01006ed:	68 0c 00 10 00       	push   $0x10000c
f01006f2:	68 0c 00 10 f0       	push   $0xf010000c
f01006f7:	68 20 1d 10 f0       	push   $0xf0101d20
f01006fc:	e8 ad 02 00 00       	call   f01009ae <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100701:	83 c4 0c             	add    $0xc,%esp
f0100704:	68 01 19 10 00       	push   $0x101901
f0100709:	68 01 19 10 f0       	push   $0xf0101901
f010070e:	68 44 1d 10 f0       	push   $0xf0101d44
f0100713:	e8 96 02 00 00       	call   f01009ae <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100718:	83 c4 0c             	add    $0xc,%esp
f010071b:	68 00 23 11 00       	push   $0x112300
f0100720:	68 00 23 11 f0       	push   $0xf0112300
f0100725:	68 68 1d 10 f0       	push   $0xf0101d68
f010072a:	e8 7f 02 00 00       	call   f01009ae <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010072f:	83 c4 0c             	add    $0xc,%esp
f0100732:	68 44 29 11 00       	push   $0x112944
f0100737:	68 44 29 11 f0       	push   $0xf0112944
f010073c:	68 8c 1d 10 f0       	push   $0xf0101d8c
f0100741:	e8 68 02 00 00       	call   f01009ae <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100746:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f010074b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100750:	83 c4 08             	add    $0x8,%esp
f0100753:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100758:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010075e:	85 c0                	test   %eax,%eax
f0100760:	0f 48 c2             	cmovs  %edx,%eax
f0100763:	c1 f8 0a             	sar    $0xa,%eax
f0100766:	50                   	push   %eax
f0100767:	68 b0 1d 10 f0       	push   $0xf0101db0
f010076c:	e8 3d 02 00 00       	call   f01009ae <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100771:	b8 00 00 00 00       	mov    $0x0,%eax
f0100776:	c9                   	leave  
f0100777:	c3                   	ret    

f0100778 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100778:	55                   	push   %ebp
f0100779:	89 e5                	mov    %esp,%ebp
f010077b:	56                   	push   %esi
f010077c:	53                   	push   %ebx
f010077d:	83 ec 2c             	sub    $0x2c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100780:	89 eb                	mov    %ebp,%ebx
	// Your code here.
uint32_t *ebp = (uint32_t*)read_ebp();
	cprintf("stack_backtrace:\n");
f0100782:	68 4e 1c 10 f0       	push   $0xf0101c4e
f0100787:	e8 22 02 00 00       	call   f01009ae <cprintf>
	while (ebp != 0x00)
f010078c:	83 c4 10             	add    $0x10,%esp
	{
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, ebp[1], ebp[2], ebp[3], ebp[4],ebp[5],ebp[6]);
                struct Eipdebuginfo info;
		debuginfo_eip(ebp[1],&info);
f010078f:	8d 75 e0             	lea    -0x20(%ebp),%esi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
uint32_t *ebp = (uint32_t*)read_ebp();
	cprintf("stack_backtrace:\n");
	while (ebp != 0x00)
f0100792:	eb 4e                	jmp    f01007e2 <mon_backtrace+0x6a>
	{
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, ebp[1], ebp[2], ebp[3], ebp[4],ebp[5],ebp[6]);
f0100794:	ff 73 18             	pushl  0x18(%ebx)
f0100797:	ff 73 14             	pushl  0x14(%ebx)
f010079a:	ff 73 10             	pushl  0x10(%ebx)
f010079d:	ff 73 0c             	pushl  0xc(%ebx)
f01007a0:	ff 73 08             	pushl  0x8(%ebx)
f01007a3:	ff 73 04             	pushl  0x4(%ebx)
f01007a6:	53                   	push   %ebx
f01007a7:	68 dc 1d 10 f0       	push   $0xf0101ddc
f01007ac:	e8 fd 01 00 00       	call   f01009ae <cprintf>
                struct Eipdebuginfo info;
		debuginfo_eip(ebp[1],&info);
f01007b1:	83 c4 18             	add    $0x18,%esp
f01007b4:	56                   	push   %esi
f01007b5:	ff 73 04             	pushl  0x4(%ebx)
f01007b8:	e8 fb 02 00 00       	call   f0100ab8 <debuginfo_eip>
		cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
f01007bd:	83 c4 08             	add    $0x8,%esp
f01007c0:	8b 43 04             	mov    0x4(%ebx),%eax
f01007c3:	2b 45 f0             	sub    -0x10(%ebp),%eax
f01007c6:	50                   	push   %eax
f01007c7:	ff 75 e8             	pushl  -0x18(%ebp)
f01007ca:	ff 75 ec             	pushl  -0x14(%ebp)
f01007cd:	ff 75 e4             	pushl  -0x1c(%ebp)
f01007d0:	ff 75 e0             	pushl  -0x20(%ebp)
f01007d3:	68 60 1c 10 f0       	push   $0xf0101c60
f01007d8:	e8 d1 01 00 00       	call   f01009ae <cprintf>
		ebp = (uint32_t*)ebp[0];
f01007dd:	8b 1b                	mov    (%ebx),%ebx
f01007df:	83 c4 20             	add    $0x20,%esp
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
uint32_t *ebp = (uint32_t*)read_ebp();
	cprintf("stack_backtrace:\n");
	while (ebp != 0x00)
f01007e2:	85 db                	test   %ebx,%ebx
f01007e4:	75 ae                	jne    f0100794 <mon_backtrace+0x1c>
		debuginfo_eip(ebp[1],&info);
		cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,ebp[1]-info.eip_fn_addr);
		ebp = (uint32_t*)ebp[0];
	}
	return 0;
}
f01007e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01007eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007ee:	5b                   	pop    %ebx
f01007ef:	5e                   	pop    %esi
f01007f0:	5d                   	pop    %ebp
f01007f1:	c3                   	ret    

f01007f2 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007f2:	55                   	push   %ebp
f01007f3:	89 e5                	mov    %esp,%ebp
f01007f5:	57                   	push   %edi
f01007f6:	56                   	push   %esi
f01007f7:	53                   	push   %ebx
f01007f8:	83 ec 68             	sub    $0x68,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007fb:	68 10 1e 10 f0       	push   $0xf0101e10
f0100800:	e8 a9 01 00 00       	call   f01009ae <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100805:	c7 04 24 34 1e 10 f0 	movl   $0xf0101e34,(%esp)
f010080c:	e8 9d 01 00 00       	call   f01009ae <cprintf>
	int x=1,y=3,z=4;
	cprintf("x %d,y %d,z %d\n",x,y,z);
f0100811:	6a 04                	push   $0x4
f0100813:	6a 03                	push   $0x3
f0100815:	6a 01                	push   $0x1
f0100817:	68 70 1c 10 f0       	push   $0xf0101c70
f010081c:	e8 8d 01 00 00       	call   f01009ae <cprintf>
	unsigned int i=0x00646c72;
f0100821:	c7 45 e4 72 6c 64 00 	movl   $0x646c72,-0x1c(%ebp)
	cprintf("H%x Wo%s",57616,&i);
f0100828:	83 c4 1c             	add    $0x1c,%esp
f010082b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010082e:	50                   	push   %eax
f010082f:	68 10 e1 00 00       	push   $0xe110
f0100834:	68 80 1c 10 f0       	push   $0xf0101c80
f0100839:	e8 70 01 00 00       	call   f01009ae <cprintf>
	cprintf("x%d,y%d",3);
f010083e:	83 c4 08             	add    $0x8,%esp
f0100841:	6a 03                	push   $0x3
f0100843:	68 89 1c 10 f0       	push   $0xf0101c89
f0100848:	e8 61 01 00 00       	call   f01009ae <cprintf>
f010084d:	83 c4 10             	add    $0x10,%esp
	while (1) {
		buf = readline("K> ");
f0100850:	83 ec 0c             	sub    $0xc,%esp
f0100853:	68 91 1c 10 f0       	push   $0xf0101c91
f0100858:	e8 be 09 00 00       	call   f010121b <readline>
f010085d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010085f:	83 c4 10             	add    $0x10,%esp
f0100862:	85 c0                	test   %eax,%eax
f0100864:	74 ea                	je     f0100850 <monitor+0x5e>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100866:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010086d:	be 00 00 00 00       	mov    $0x0,%esi
f0100872:	eb 0a                	jmp    f010087e <monitor+0x8c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100874:	c6 03 00             	movb   $0x0,(%ebx)
f0100877:	89 f7                	mov    %esi,%edi
f0100879:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010087c:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010087e:	0f b6 03             	movzbl (%ebx),%eax
f0100881:	84 c0                	test   %al,%al
f0100883:	74 63                	je     f01008e8 <monitor+0xf6>
f0100885:	83 ec 08             	sub    $0x8,%esp
f0100888:	0f be c0             	movsbl %al,%eax
f010088b:	50                   	push   %eax
f010088c:	68 95 1c 10 f0       	push   $0xf0101c95
f0100891:	e8 9f 0b 00 00       	call   f0101435 <strchr>
f0100896:	83 c4 10             	add    $0x10,%esp
f0100899:	85 c0                	test   %eax,%eax
f010089b:	75 d7                	jne    f0100874 <monitor+0x82>
			*buf++ = 0;
		if (*buf == 0)
f010089d:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008a0:	74 46                	je     f01008e8 <monitor+0xf6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008a2:	83 fe 0f             	cmp    $0xf,%esi
f01008a5:	75 14                	jne    f01008bb <monitor+0xc9>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008a7:	83 ec 08             	sub    $0x8,%esp
f01008aa:	6a 10                	push   $0x10
f01008ac:	68 9a 1c 10 f0       	push   $0xf0101c9a
f01008b1:	e8 f8 00 00 00       	call   f01009ae <cprintf>
f01008b6:	83 c4 10             	add    $0x10,%esp
f01008b9:	eb 95                	jmp    f0100850 <monitor+0x5e>
			return 0;
		}
		argv[argc++] = buf;
f01008bb:	8d 7e 01             	lea    0x1(%esi),%edi
f01008be:	89 5c b5 a4          	mov    %ebx,-0x5c(%ebp,%esi,4)
f01008c2:	eb 03                	jmp    f01008c7 <monitor+0xd5>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008c4:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008c7:	0f b6 03             	movzbl (%ebx),%eax
f01008ca:	84 c0                	test   %al,%al
f01008cc:	74 ae                	je     f010087c <monitor+0x8a>
f01008ce:	83 ec 08             	sub    $0x8,%esp
f01008d1:	0f be c0             	movsbl %al,%eax
f01008d4:	50                   	push   %eax
f01008d5:	68 95 1c 10 f0       	push   $0xf0101c95
f01008da:	e8 56 0b 00 00       	call   f0101435 <strchr>
f01008df:	83 c4 10             	add    $0x10,%esp
f01008e2:	85 c0                	test   %eax,%eax
f01008e4:	74 de                	je     f01008c4 <monitor+0xd2>
f01008e6:	eb 94                	jmp    f010087c <monitor+0x8a>
			buf++;
	}
	argv[argc] = 0;
f01008e8:	c7 44 b5 a4 00 00 00 	movl   $0x0,-0x5c(%ebp,%esi,4)
f01008ef:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008f0:	85 f6                	test   %esi,%esi
f01008f2:	0f 84 58 ff ff ff    	je     f0100850 <monitor+0x5e>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008f8:	83 ec 08             	sub    $0x8,%esp
f01008fb:	68 1e 1c 10 f0       	push   $0xf0101c1e
f0100900:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100903:	e8 cf 0a 00 00       	call   f01013d7 <strcmp>
f0100908:	83 c4 10             	add    $0x10,%esp
f010090b:	85 c0                	test   %eax,%eax
f010090d:	74 1e                	je     f010092d <monitor+0x13b>
f010090f:	83 ec 08             	sub    $0x8,%esp
f0100912:	68 2c 1c 10 f0       	push   $0xf0101c2c
f0100917:	ff 75 a4             	pushl  -0x5c(%ebp)
f010091a:	e8 b8 0a 00 00       	call   f01013d7 <strcmp>
f010091f:	83 c4 10             	add    $0x10,%esp
f0100922:	85 c0                	test   %eax,%eax
f0100924:	75 2f                	jne    f0100955 <monitor+0x163>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100926:	b8 01 00 00 00       	mov    $0x1,%eax
f010092b:	eb 05                	jmp    f0100932 <monitor+0x140>
		if (strcmp(argv[0], commands[i].name) == 0)
f010092d:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100932:	83 ec 04             	sub    $0x4,%esp
f0100935:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100938:	01 d0                	add    %edx,%eax
f010093a:	ff 75 08             	pushl  0x8(%ebp)
f010093d:	8d 4d a4             	lea    -0x5c(%ebp),%ecx
f0100940:	51                   	push   %ecx
f0100941:	56                   	push   %esi
f0100942:	ff 14 85 64 1e 10 f0 	call   *-0xfefe19c(,%eax,4)
	cprintf("H%x Wo%s",57616,&i);
	cprintf("x%d,y%d",3);
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100949:	83 c4 10             	add    $0x10,%esp
f010094c:	85 c0                	test   %eax,%eax
f010094e:	78 1d                	js     f010096d <monitor+0x17b>
f0100950:	e9 fb fe ff ff       	jmp    f0100850 <monitor+0x5e>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100955:	83 ec 08             	sub    $0x8,%esp
f0100958:	ff 75 a4             	pushl  -0x5c(%ebp)
f010095b:	68 b7 1c 10 f0       	push   $0xf0101cb7
f0100960:	e8 49 00 00 00       	call   f01009ae <cprintf>
f0100965:	83 c4 10             	add    $0x10,%esp
f0100968:	e9 e3 fe ff ff       	jmp    f0100850 <monitor+0x5e>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010096d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100970:	5b                   	pop    %ebx
f0100971:	5e                   	pop    %esi
f0100972:	5f                   	pop    %edi
f0100973:	5d                   	pop    %ebp
f0100974:	c3                   	ret    

f0100975 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100975:	55                   	push   %ebp
f0100976:	89 e5                	mov    %esp,%ebp
f0100978:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010097b:	ff 75 08             	pushl  0x8(%ebp)
f010097e:	e8 e2 fc ff ff       	call   f0100665 <cputchar>
	*cnt++;
}
f0100983:	83 c4 10             	add    $0x10,%esp
f0100986:	c9                   	leave  
f0100987:	c3                   	ret    

f0100988 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100988:	55                   	push   %ebp
f0100989:	89 e5                	mov    %esp,%ebp
f010098b:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010098e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100995:	ff 75 0c             	pushl  0xc(%ebp)
f0100998:	ff 75 08             	pushl  0x8(%ebp)
f010099b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010099e:	50                   	push   %eax
f010099f:	68 75 09 10 f0       	push   $0xf0100975
f01009a4:	e8 5d 04 00 00       	call   f0100e06 <vprintfmt>
	return cnt;
}
f01009a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009ac:	c9                   	leave  
f01009ad:	c3                   	ret    

f01009ae <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009ae:	55                   	push   %ebp
f01009af:	89 e5                	mov    %esp,%ebp
f01009b1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009b4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009b7:	50                   	push   %eax
f01009b8:	ff 75 08             	pushl  0x8(%ebp)
f01009bb:	e8 c8 ff ff ff       	call   f0100988 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009c0:	c9                   	leave  
f01009c1:	c3                   	ret    

f01009c2 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009c2:	55                   	push   %ebp
f01009c3:	89 e5                	mov    %esp,%ebp
f01009c5:	57                   	push   %edi
f01009c6:	56                   	push   %esi
f01009c7:	53                   	push   %ebx
f01009c8:	83 ec 14             	sub    $0x14,%esp
f01009cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01009ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01009d1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01009d4:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009d7:	8b 1a                	mov    (%edx),%ebx
f01009d9:	8b 01                	mov    (%ecx),%eax
f01009db:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009de:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009e5:	eb 7f                	jmp    f0100a66 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01009e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009ea:	01 d8                	add    %ebx,%eax
f01009ec:	89 c6                	mov    %eax,%esi
f01009ee:	c1 ee 1f             	shr    $0x1f,%esi
f01009f1:	01 c6                	add    %eax,%esi
f01009f3:	d1 fe                	sar    %esi
f01009f5:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009f8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009fb:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01009fe:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a00:	eb 03                	jmp    f0100a05 <stab_binsearch+0x43>
			m--;
f0100a02:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a05:	39 c3                	cmp    %eax,%ebx
f0100a07:	7f 0d                	jg     f0100a16 <stab_binsearch+0x54>
f0100a09:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100a0d:	83 ea 0c             	sub    $0xc,%edx
f0100a10:	39 f9                	cmp    %edi,%ecx
f0100a12:	75 ee                	jne    f0100a02 <stab_binsearch+0x40>
f0100a14:	eb 05                	jmp    f0100a1b <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a16:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100a19:	eb 4b                	jmp    f0100a66 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a1b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a1e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a21:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a25:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a28:	76 11                	jbe    f0100a3b <stab_binsearch+0x79>
			*region_left = m;
f0100a2a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a2d:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a2f:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a32:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a39:	eb 2b                	jmp    f0100a66 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a3b:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a3e:	73 14                	jae    f0100a54 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a40:	83 e8 01             	sub    $0x1,%eax
f0100a43:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a46:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a49:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a4b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a52:	eb 12                	jmp    f0100a66 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a54:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a57:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a59:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a5d:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a5f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a66:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a69:	0f 8e 78 ff ff ff    	jle    f01009e7 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a6f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a73:	75 0f                	jne    f0100a84 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100a75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a78:	8b 00                	mov    (%eax),%eax
f0100a7a:	83 e8 01             	sub    $0x1,%eax
f0100a7d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a80:	89 06                	mov    %eax,(%esi)
f0100a82:	eb 2c                	jmp    f0100ab0 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a84:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a87:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a89:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a8c:	8b 0e                	mov    (%esi),%ecx
f0100a8e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a91:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a94:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a97:	eb 03                	jmp    f0100a9c <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a99:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a9c:	39 c8                	cmp    %ecx,%eax
f0100a9e:	7e 0b                	jle    f0100aab <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100aa0:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100aa4:	83 ea 0c             	sub    $0xc,%edx
f0100aa7:	39 df                	cmp    %ebx,%edi
f0100aa9:	75 ee                	jne    f0100a99 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100aab:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100aae:	89 06                	mov    %eax,(%esi)
	}
}
f0100ab0:	83 c4 14             	add    $0x14,%esp
f0100ab3:	5b                   	pop    %ebx
f0100ab4:	5e                   	pop    %esi
f0100ab5:	5f                   	pop    %edi
f0100ab6:	5d                   	pop    %ebp
f0100ab7:	c3                   	ret    

f0100ab8 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100ab8:	55                   	push   %ebp
f0100ab9:	89 e5                	mov    %esp,%ebp
f0100abb:	57                   	push   %edi
f0100abc:	56                   	push   %esi
f0100abd:	53                   	push   %ebx
f0100abe:	83 ec 3c             	sub    $0x3c,%esp
f0100ac1:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ac4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100ac7:	c7 03 74 1e 10 f0    	movl   $0xf0101e74,(%ebx)
	info->eip_line = 0;
f0100acd:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100ad4:	c7 43 08 74 1e 10 f0 	movl   $0xf0101e74,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100adb:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100ae2:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100ae5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100aec:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100af2:	76 11                	jbe    f0100b05 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100af4:	b8 16 74 10 f0       	mov    $0xf0107416,%eax
f0100af9:	3d e5 5a 10 f0       	cmp    $0xf0105ae5,%eax
f0100afe:	77 19                	ja     f0100b19 <debuginfo_eip+0x61>
f0100b00:	e9 b5 01 00 00       	jmp    f0100cba <debuginfo_eip+0x202>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b05:	83 ec 04             	sub    $0x4,%esp
f0100b08:	68 7e 1e 10 f0       	push   $0xf0101e7e
f0100b0d:	6a 7f                	push   $0x7f
f0100b0f:	68 8b 1e 10 f0       	push   $0xf0101e8b
f0100b14:	e8 cd f5 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b19:	80 3d 15 74 10 f0 00 	cmpb   $0x0,0xf0107415
f0100b20:	0f 85 9b 01 00 00    	jne    f0100cc1 <debuginfo_eip+0x209>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b26:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b2d:	b8 e4 5a 10 f0       	mov    $0xf0105ae4,%eax
f0100b32:	2d d0 20 10 f0       	sub    $0xf01020d0,%eax
f0100b37:	c1 f8 02             	sar    $0x2,%eax
f0100b3a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b40:	83 e8 01             	sub    $0x1,%eax
f0100b43:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b46:	83 ec 08             	sub    $0x8,%esp
f0100b49:	56                   	push   %esi
f0100b4a:	6a 64                	push   $0x64
f0100b4c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b4f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b52:	b8 d0 20 10 f0       	mov    $0xf01020d0,%eax
f0100b57:	e8 66 fe ff ff       	call   f01009c2 <stab_binsearch>
	if (lfile == 0)
f0100b5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b5f:	83 c4 10             	add    $0x10,%esp
f0100b62:	85 c0                	test   %eax,%eax
f0100b64:	0f 84 5e 01 00 00    	je     f0100cc8 <debuginfo_eip+0x210>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b6a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b6d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b70:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b73:	83 ec 08             	sub    $0x8,%esp
f0100b76:	56                   	push   %esi
f0100b77:	6a 24                	push   $0x24
f0100b79:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b7c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b7f:	b8 d0 20 10 f0       	mov    $0xf01020d0,%eax
f0100b84:	e8 39 fe ff ff       	call   f01009c2 <stab_binsearch>

	if (lfun <= rfun) {
f0100b89:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b8c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b8f:	83 c4 10             	add    $0x10,%esp
f0100b92:	39 d0                	cmp    %edx,%eax
f0100b94:	7f 40                	jg     f0100bd6 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b96:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100b99:	c1 e1 02             	shl    $0x2,%ecx
f0100b9c:	8d b9 d0 20 10 f0    	lea    -0xfefdf30(%ecx),%edi
f0100ba2:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100ba5:	8b b9 d0 20 10 f0    	mov    -0xfefdf30(%ecx),%edi
f0100bab:	b9 16 74 10 f0       	mov    $0xf0107416,%ecx
f0100bb0:	81 e9 e5 5a 10 f0    	sub    $0xf0105ae5,%ecx
f0100bb6:	39 cf                	cmp    %ecx,%edi
f0100bb8:	73 09                	jae    f0100bc3 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100bba:	81 c7 e5 5a 10 f0    	add    $0xf0105ae5,%edi
f0100bc0:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100bc3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100bc6:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100bc9:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100bcc:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100bce:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100bd1:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100bd4:	eb 0f                	jmp    f0100be5 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100bd6:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100bd9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bdc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100bdf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100be2:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100be5:	83 ec 08             	sub    $0x8,%esp
f0100be8:	6a 3a                	push   $0x3a
f0100bea:	ff 73 08             	pushl  0x8(%ebx)
f0100bed:	e8 64 08 00 00       	call   f0101456 <strfind>
f0100bf2:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bf5:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.


stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100bf8:	83 c4 08             	add    $0x8,%esp
f0100bfb:	56                   	push   %esi
f0100bfc:	6a 44                	push   $0x44
f0100bfe:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100c01:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100c04:	b8 d0 20 10 f0       	mov    $0xf01020d0,%eax
f0100c09:	e8 b4 fd ff ff       	call   f01009c2 <stab_binsearch>
if (lline > rline) {
f0100c0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100c11:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0100c14:	83 c4 10             	add    $0x10,%esp
f0100c17:	39 d0                	cmp    %edx,%eax
f0100c19:	0f 8f b0 00 00 00    	jg     f0100ccf <debuginfo_eip+0x217>
    return -1;
} else {
    info->eip_line = stabs[rline].n_desc;
f0100c1f:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c22:	0f b7 14 95 d6 20 10 	movzwl -0xfefdf2a(,%edx,4),%edx
f0100c29:	f0 
f0100c2a:	89 53 04             	mov    %edx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c2d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c30:	89 c2                	mov    %eax,%edx
f0100c32:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100c35:	8d 04 85 d0 20 10 f0 	lea    -0xfefdf30(,%eax,4),%eax
f0100c3c:	eb 06                	jmp    f0100c44 <debuginfo_eip+0x18c>
f0100c3e:	83 ea 01             	sub    $0x1,%edx
f0100c41:	83 e8 0c             	sub    $0xc,%eax
f0100c44:	39 d7                	cmp    %edx,%edi
f0100c46:	7f 34                	jg     f0100c7c <debuginfo_eip+0x1c4>
	       && stabs[lline].n_type != N_SOL
f0100c48:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100c4c:	80 f9 84             	cmp    $0x84,%cl
f0100c4f:	74 0b                	je     f0100c5c <debuginfo_eip+0x1a4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c51:	80 f9 64             	cmp    $0x64,%cl
f0100c54:	75 e8                	jne    f0100c3e <debuginfo_eip+0x186>
f0100c56:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c5a:	74 e2                	je     f0100c3e <debuginfo_eip+0x186>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c5c:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c5f:	8b 14 85 d0 20 10 f0 	mov    -0xfefdf30(,%eax,4),%edx
f0100c66:	b8 16 74 10 f0       	mov    $0xf0107416,%eax
f0100c6b:	2d e5 5a 10 f0       	sub    $0xf0105ae5,%eax
f0100c70:	39 c2                	cmp    %eax,%edx
f0100c72:	73 08                	jae    f0100c7c <debuginfo_eip+0x1c4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c74:	81 c2 e5 5a 10 f0    	add    $0xf0105ae5,%edx
f0100c7a:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c7c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c7f:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c82:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c87:	39 f2                	cmp    %esi,%edx
f0100c89:	7d 50                	jge    f0100cdb <debuginfo_eip+0x223>
		for (lline = lfun + 1;
f0100c8b:	83 c2 01             	add    $0x1,%edx
f0100c8e:	89 d0                	mov    %edx,%eax
f0100c90:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c93:	8d 14 95 d0 20 10 f0 	lea    -0xfefdf30(,%edx,4),%edx
f0100c9a:	eb 04                	jmp    f0100ca0 <debuginfo_eip+0x1e8>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c9c:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100ca0:	39 c6                	cmp    %eax,%esi
f0100ca2:	7e 32                	jle    f0100cd6 <debuginfo_eip+0x21e>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100ca4:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100ca8:	83 c0 01             	add    $0x1,%eax
f0100cab:	83 c2 0c             	add    $0xc,%edx
f0100cae:	80 f9 a0             	cmp    $0xa0,%cl
f0100cb1:	74 e9                	je     f0100c9c <debuginfo_eip+0x1e4>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cb3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cb8:	eb 21                	jmp    f0100cdb <debuginfo_eip+0x223>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100cba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cbf:	eb 1a                	jmp    f0100cdb <debuginfo_eip+0x223>
f0100cc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cc6:	eb 13                	jmp    f0100cdb <debuginfo_eip+0x223>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100cc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ccd:	eb 0c                	jmp    f0100cdb <debuginfo_eip+0x223>
	// Your code here.


stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
if (lline > rline) {
    return -1;
f0100ccf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cd4:	eb 05                	jmp    f0100cdb <debuginfo_eip+0x223>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cde:	5b                   	pop    %ebx
f0100cdf:	5e                   	pop    %esi
f0100ce0:	5f                   	pop    %edi
f0100ce1:	5d                   	pop    %ebp
f0100ce2:	c3                   	ret    

f0100ce3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ce3:	55                   	push   %ebp
f0100ce4:	89 e5                	mov    %esp,%ebp
f0100ce6:	57                   	push   %edi
f0100ce7:	56                   	push   %esi
f0100ce8:	53                   	push   %ebx
f0100ce9:	83 ec 1c             	sub    $0x1c,%esp
f0100cec:	89 c7                	mov    %eax,%edi
f0100cee:	89 d6                	mov    %edx,%esi
f0100cf0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cf3:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100cf6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100cf9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100cfc:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100cff:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d04:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100d07:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100d0a:	39 d3                	cmp    %edx,%ebx
f0100d0c:	72 05                	jb     f0100d13 <printnum+0x30>
f0100d0e:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100d11:	77 45                	ja     f0100d58 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d13:	83 ec 0c             	sub    $0xc,%esp
f0100d16:	ff 75 18             	pushl  0x18(%ebp)
f0100d19:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d1c:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100d1f:	53                   	push   %ebx
f0100d20:	ff 75 10             	pushl  0x10(%ebp)
f0100d23:	83 ec 08             	sub    $0x8,%esp
f0100d26:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d29:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d2c:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d2f:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d32:	e8 49 09 00 00       	call   f0101680 <__udivdi3>
f0100d37:	83 c4 18             	add    $0x18,%esp
f0100d3a:	52                   	push   %edx
f0100d3b:	50                   	push   %eax
f0100d3c:	89 f2                	mov    %esi,%edx
f0100d3e:	89 f8                	mov    %edi,%eax
f0100d40:	e8 9e ff ff ff       	call   f0100ce3 <printnum>
f0100d45:	83 c4 20             	add    $0x20,%esp
f0100d48:	eb 18                	jmp    f0100d62 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d4a:	83 ec 08             	sub    $0x8,%esp
f0100d4d:	56                   	push   %esi
f0100d4e:	ff 75 18             	pushl  0x18(%ebp)
f0100d51:	ff d7                	call   *%edi
f0100d53:	83 c4 10             	add    $0x10,%esp
f0100d56:	eb 03                	jmp    f0100d5b <printnum+0x78>
f0100d58:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d5b:	83 eb 01             	sub    $0x1,%ebx
f0100d5e:	85 db                	test   %ebx,%ebx
f0100d60:	7f e8                	jg     f0100d4a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d62:	83 ec 08             	sub    $0x8,%esp
f0100d65:	56                   	push   %esi
f0100d66:	83 ec 04             	sub    $0x4,%esp
f0100d69:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d6c:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d6f:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d72:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d75:	e8 36 0a 00 00       	call   f01017b0 <__umoddi3>
f0100d7a:	83 c4 14             	add    $0x14,%esp
f0100d7d:	0f be 80 99 1e 10 f0 	movsbl -0xfefe167(%eax),%eax
f0100d84:	50                   	push   %eax
f0100d85:	ff d7                	call   *%edi
}
f0100d87:	83 c4 10             	add    $0x10,%esp
f0100d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d8d:	5b                   	pop    %ebx
f0100d8e:	5e                   	pop    %esi
f0100d8f:	5f                   	pop    %edi
f0100d90:	5d                   	pop    %ebp
f0100d91:	c3                   	ret    

f0100d92 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d92:	55                   	push   %ebp
f0100d93:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d95:	83 fa 01             	cmp    $0x1,%edx
f0100d98:	7e 0e                	jle    f0100da8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d9a:	8b 10                	mov    (%eax),%edx
f0100d9c:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d9f:	89 08                	mov    %ecx,(%eax)
f0100da1:	8b 02                	mov    (%edx),%eax
f0100da3:	8b 52 04             	mov    0x4(%edx),%edx
f0100da6:	eb 22                	jmp    f0100dca <getuint+0x38>
	else if (lflag)
f0100da8:	85 d2                	test   %edx,%edx
f0100daa:	74 10                	je     f0100dbc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100dac:	8b 10                	mov    (%eax),%edx
f0100dae:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100db1:	89 08                	mov    %ecx,(%eax)
f0100db3:	8b 02                	mov    (%edx),%eax
f0100db5:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dba:	eb 0e                	jmp    f0100dca <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100dbc:	8b 10                	mov    (%eax),%edx
f0100dbe:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100dc1:	89 08                	mov    %ecx,(%eax)
f0100dc3:	8b 02                	mov    (%edx),%eax
f0100dc5:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100dca:	5d                   	pop    %ebp
f0100dcb:	c3                   	ret    

f0100dcc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100dcc:	55                   	push   %ebp
f0100dcd:	89 e5                	mov    %esp,%ebp
f0100dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100dd2:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100dd6:	8b 10                	mov    (%eax),%edx
f0100dd8:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ddb:	73 0a                	jae    f0100de7 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100ddd:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100de0:	89 08                	mov    %ecx,(%eax)
f0100de2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100de5:	88 02                	mov    %al,(%edx)
}
f0100de7:	5d                   	pop    %ebp
f0100de8:	c3                   	ret    

f0100de9 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100de9:	55                   	push   %ebp
f0100dea:	89 e5                	mov    %esp,%ebp
f0100dec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100def:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100df2:	50                   	push   %eax
f0100df3:	ff 75 10             	pushl  0x10(%ebp)
f0100df6:	ff 75 0c             	pushl  0xc(%ebp)
f0100df9:	ff 75 08             	pushl  0x8(%ebp)
f0100dfc:	e8 05 00 00 00       	call   f0100e06 <vprintfmt>
	va_end(ap);
}
f0100e01:	83 c4 10             	add    $0x10,%esp
f0100e04:	c9                   	leave  
f0100e05:	c3                   	ret    

f0100e06 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100e06:	55                   	push   %ebp
f0100e07:	89 e5                	mov    %esp,%ebp
f0100e09:	57                   	push   %edi
f0100e0a:	56                   	push   %esi
f0100e0b:	53                   	push   %ebx
f0100e0c:	83 ec 2c             	sub    $0x2c,%esp
f0100e0f:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100e15:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100e18:	eb 12                	jmp    f0100e2c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100e1a:	85 c0                	test   %eax,%eax
f0100e1c:	0f 84 89 03 00 00    	je     f01011ab <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100e22:	83 ec 08             	sub    $0x8,%esp
f0100e25:	53                   	push   %ebx
f0100e26:	50                   	push   %eax
f0100e27:	ff d6                	call   *%esi
f0100e29:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e2c:	83 c7 01             	add    $0x1,%edi
f0100e2f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100e33:	83 f8 25             	cmp    $0x25,%eax
f0100e36:	75 e2                	jne    f0100e1a <vprintfmt+0x14>
f0100e38:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100e3c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e43:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e4a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e51:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e56:	eb 07                	jmp    f0100e5f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e58:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e5b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e5f:	8d 47 01             	lea    0x1(%edi),%eax
f0100e62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e65:	0f b6 07             	movzbl (%edi),%eax
f0100e68:	0f b6 c8             	movzbl %al,%ecx
f0100e6b:	83 e8 23             	sub    $0x23,%eax
f0100e6e:	3c 55                	cmp    $0x55,%al
f0100e70:	0f 87 1a 03 00 00    	ja     f0101190 <vprintfmt+0x38a>
f0100e76:	0f b6 c0             	movzbl %al,%eax
f0100e79:	ff 24 85 40 1f 10 f0 	jmp    *-0xfefe0c0(,%eax,4)
f0100e80:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e83:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e87:	eb d6                	jmp    f0100e5f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e89:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e8c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e91:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e94:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e97:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100e9b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100e9e:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100ea1:	83 fa 09             	cmp    $0x9,%edx
f0100ea4:	77 39                	ja     f0100edf <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100ea6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100ea9:	eb e9                	jmp    f0100e94 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100eab:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eae:	8d 48 04             	lea    0x4(%eax),%ecx
f0100eb1:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100eb4:	8b 00                	mov    (%eax),%eax
f0100eb6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eb9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100ebc:	eb 27                	jmp    f0100ee5 <vprintfmt+0xdf>
f0100ebe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ec1:	85 c0                	test   %eax,%eax
f0100ec3:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ec8:	0f 49 c8             	cmovns %eax,%ecx
f0100ecb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ece:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ed1:	eb 8c                	jmp    f0100e5f <vprintfmt+0x59>
f0100ed3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100ed6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100edd:	eb 80                	jmp    f0100e5f <vprintfmt+0x59>
f0100edf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ee2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100ee5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100ee9:	0f 89 70 ff ff ff    	jns    f0100e5f <vprintfmt+0x59>
				width = precision, precision = -1;
f0100eef:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100ef2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ef5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100efc:	e9 5e ff ff ff       	jmp    f0100e5f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100f01:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100f07:	e9 53 ff ff ff       	jmp    f0100e5f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100f0c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f0f:	8d 50 04             	lea    0x4(%eax),%edx
f0100f12:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f15:	83 ec 08             	sub    $0x8,%esp
f0100f18:	53                   	push   %ebx
f0100f19:	ff 30                	pushl  (%eax)
f0100f1b:	ff d6                	call   *%esi
			break;
f0100f1d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f20:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100f23:	e9 04 ff ff ff       	jmp    f0100e2c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f28:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f2b:	8d 50 04             	lea    0x4(%eax),%edx
f0100f2e:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f31:	8b 00                	mov    (%eax),%eax
f0100f33:	99                   	cltd   
f0100f34:	31 d0                	xor    %edx,%eax
f0100f36:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f38:	83 f8 07             	cmp    $0x7,%eax
f0100f3b:	7f 0b                	jg     f0100f48 <vprintfmt+0x142>
f0100f3d:	8b 14 85 a0 20 10 f0 	mov    -0xfefdf60(,%eax,4),%edx
f0100f44:	85 d2                	test   %edx,%edx
f0100f46:	75 18                	jne    f0100f60 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100f48:	50                   	push   %eax
f0100f49:	68 b1 1e 10 f0       	push   $0xf0101eb1
f0100f4e:	53                   	push   %ebx
f0100f4f:	56                   	push   %esi
f0100f50:	e8 94 fe ff ff       	call   f0100de9 <printfmt>
f0100f55:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f58:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f5b:	e9 cc fe ff ff       	jmp    f0100e2c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100f60:	52                   	push   %edx
f0100f61:	68 86 1c 10 f0       	push   $0xf0101c86
f0100f66:	53                   	push   %ebx
f0100f67:	56                   	push   %esi
f0100f68:	e8 7c fe ff ff       	call   f0100de9 <printfmt>
f0100f6d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f73:	e9 b4 fe ff ff       	jmp    f0100e2c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f78:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f7b:	8d 50 04             	lea    0x4(%eax),%edx
f0100f7e:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f81:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100f83:	85 ff                	test   %edi,%edi
f0100f85:	b8 aa 1e 10 f0       	mov    $0xf0101eaa,%eax
f0100f8a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100f8d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f91:	0f 8e 94 00 00 00    	jle    f010102b <vprintfmt+0x225>
f0100f97:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f9b:	0f 84 98 00 00 00    	je     f0101039 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fa1:	83 ec 08             	sub    $0x8,%esp
f0100fa4:	ff 75 d0             	pushl  -0x30(%ebp)
f0100fa7:	57                   	push   %edi
f0100fa8:	e8 5f 03 00 00       	call   f010130c <strnlen>
f0100fad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fb0:	29 c1                	sub    %eax,%ecx
f0100fb2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100fb5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100fb8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100fbc:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100fbf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100fc2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fc4:	eb 0f                	jmp    f0100fd5 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0100fc6:	83 ec 08             	sub    $0x8,%esp
f0100fc9:	53                   	push   %ebx
f0100fca:	ff 75 e0             	pushl  -0x20(%ebp)
f0100fcd:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fcf:	83 ef 01             	sub    $0x1,%edi
f0100fd2:	83 c4 10             	add    $0x10,%esp
f0100fd5:	85 ff                	test   %edi,%edi
f0100fd7:	7f ed                	jg     f0100fc6 <vprintfmt+0x1c0>
f0100fd9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100fdc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100fdf:	85 c9                	test   %ecx,%ecx
f0100fe1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fe6:	0f 49 c1             	cmovns %ecx,%eax
f0100fe9:	29 c1                	sub    %eax,%ecx
f0100feb:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fee:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ff1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ff4:	89 cb                	mov    %ecx,%ebx
f0100ff6:	eb 4d                	jmp    f0101045 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100ff8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100ffc:	74 1b                	je     f0101019 <vprintfmt+0x213>
f0100ffe:	0f be c0             	movsbl %al,%eax
f0101001:	83 e8 20             	sub    $0x20,%eax
f0101004:	83 f8 5e             	cmp    $0x5e,%eax
f0101007:	76 10                	jbe    f0101019 <vprintfmt+0x213>
					putch('?', putdat);
f0101009:	83 ec 08             	sub    $0x8,%esp
f010100c:	ff 75 0c             	pushl  0xc(%ebp)
f010100f:	6a 3f                	push   $0x3f
f0101011:	ff 55 08             	call   *0x8(%ebp)
f0101014:	83 c4 10             	add    $0x10,%esp
f0101017:	eb 0d                	jmp    f0101026 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0101019:	83 ec 08             	sub    $0x8,%esp
f010101c:	ff 75 0c             	pushl  0xc(%ebp)
f010101f:	52                   	push   %edx
f0101020:	ff 55 08             	call   *0x8(%ebp)
f0101023:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101026:	83 eb 01             	sub    $0x1,%ebx
f0101029:	eb 1a                	jmp    f0101045 <vprintfmt+0x23f>
f010102b:	89 75 08             	mov    %esi,0x8(%ebp)
f010102e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101031:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101034:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101037:	eb 0c                	jmp    f0101045 <vprintfmt+0x23f>
f0101039:	89 75 08             	mov    %esi,0x8(%ebp)
f010103c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010103f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101042:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101045:	83 c7 01             	add    $0x1,%edi
f0101048:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010104c:	0f be d0             	movsbl %al,%edx
f010104f:	85 d2                	test   %edx,%edx
f0101051:	74 23                	je     f0101076 <vprintfmt+0x270>
f0101053:	85 f6                	test   %esi,%esi
f0101055:	78 a1                	js     f0100ff8 <vprintfmt+0x1f2>
f0101057:	83 ee 01             	sub    $0x1,%esi
f010105a:	79 9c                	jns    f0100ff8 <vprintfmt+0x1f2>
f010105c:	89 df                	mov    %ebx,%edi
f010105e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101061:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101064:	eb 18                	jmp    f010107e <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101066:	83 ec 08             	sub    $0x8,%esp
f0101069:	53                   	push   %ebx
f010106a:	6a 20                	push   $0x20
f010106c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010106e:	83 ef 01             	sub    $0x1,%edi
f0101071:	83 c4 10             	add    $0x10,%esp
f0101074:	eb 08                	jmp    f010107e <vprintfmt+0x278>
f0101076:	89 df                	mov    %ebx,%edi
f0101078:	8b 75 08             	mov    0x8(%ebp),%esi
f010107b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010107e:	85 ff                	test   %edi,%edi
f0101080:	7f e4                	jg     f0101066 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101082:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101085:	e9 a2 fd ff ff       	jmp    f0100e2c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010108a:	83 fa 01             	cmp    $0x1,%edx
f010108d:	7e 16                	jle    f01010a5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f010108f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101092:	8d 50 08             	lea    0x8(%eax),%edx
f0101095:	89 55 14             	mov    %edx,0x14(%ebp)
f0101098:	8b 50 04             	mov    0x4(%eax),%edx
f010109b:	8b 00                	mov    (%eax),%eax
f010109d:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010a0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01010a3:	eb 32                	jmp    f01010d7 <vprintfmt+0x2d1>
	else if (lflag)
f01010a5:	85 d2                	test   %edx,%edx
f01010a7:	74 18                	je     f01010c1 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01010a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01010ac:	8d 50 04             	lea    0x4(%eax),%edx
f01010af:	89 55 14             	mov    %edx,0x14(%ebp)
f01010b2:	8b 00                	mov    (%eax),%eax
f01010b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010b7:	89 c1                	mov    %eax,%ecx
f01010b9:	c1 f9 1f             	sar    $0x1f,%ecx
f01010bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01010bf:	eb 16                	jmp    f01010d7 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01010c1:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c4:	8d 50 04             	lea    0x4(%eax),%edx
f01010c7:	89 55 14             	mov    %edx,0x14(%ebp)
f01010ca:	8b 00                	mov    (%eax),%eax
f01010cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010cf:	89 c1                	mov    %eax,%ecx
f01010d1:	c1 f9 1f             	sar    $0x1f,%ecx
f01010d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01010d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010da:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01010dd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01010e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01010e6:	79 74                	jns    f010115c <vprintfmt+0x356>
				putch('-', putdat);
f01010e8:	83 ec 08             	sub    $0x8,%esp
f01010eb:	53                   	push   %ebx
f01010ec:	6a 2d                	push   $0x2d
f01010ee:	ff d6                	call   *%esi
				num = -(long long) num;
f01010f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010f3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010f6:	f7 d8                	neg    %eax
f01010f8:	83 d2 00             	adc    $0x0,%edx
f01010fb:	f7 da                	neg    %edx
f01010fd:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0101100:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101105:	eb 55                	jmp    f010115c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101107:	8d 45 14             	lea    0x14(%ebp),%eax
f010110a:	e8 83 fc ff ff       	call   f0100d92 <getuint>
			base = 10;
f010110f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101114:	eb 46                	jmp    f010115c <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0101116:	8d 45 14             	lea    0x14(%ebp),%eax
f0101119:	e8 74 fc ff ff       	call   f0100d92 <getuint>
			base = 8;
f010111e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0101123:	eb 37                	jmp    f010115c <vprintfmt+0x356>
			

		// pointer
		case 'p':
			putch('0', putdat);
f0101125:	83 ec 08             	sub    $0x8,%esp
f0101128:	53                   	push   %ebx
f0101129:	6a 30                	push   $0x30
f010112b:	ff d6                	call   *%esi
			putch('x', putdat);
f010112d:	83 c4 08             	add    $0x8,%esp
f0101130:	53                   	push   %ebx
f0101131:	6a 78                	push   $0x78
f0101133:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101135:	8b 45 14             	mov    0x14(%ebp),%eax
f0101138:	8d 50 04             	lea    0x4(%eax),%edx
f010113b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010113e:	8b 00                	mov    (%eax),%eax
f0101140:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101145:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101148:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010114d:	eb 0d                	jmp    f010115c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010114f:	8d 45 14             	lea    0x14(%ebp),%eax
f0101152:	e8 3b fc ff ff       	call   f0100d92 <getuint>
			base = 16;
f0101157:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010115c:	83 ec 0c             	sub    $0xc,%esp
f010115f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101163:	57                   	push   %edi
f0101164:	ff 75 e0             	pushl  -0x20(%ebp)
f0101167:	51                   	push   %ecx
f0101168:	52                   	push   %edx
f0101169:	50                   	push   %eax
f010116a:	89 da                	mov    %ebx,%edx
f010116c:	89 f0                	mov    %esi,%eax
f010116e:	e8 70 fb ff ff       	call   f0100ce3 <printnum>
			break;
f0101173:	83 c4 20             	add    $0x20,%esp
f0101176:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101179:	e9 ae fc ff ff       	jmp    f0100e2c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010117e:	83 ec 08             	sub    $0x8,%esp
f0101181:	53                   	push   %ebx
f0101182:	51                   	push   %ecx
f0101183:	ff d6                	call   *%esi
			break;
f0101185:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101188:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010118b:	e9 9c fc ff ff       	jmp    f0100e2c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101190:	83 ec 08             	sub    $0x8,%esp
f0101193:	53                   	push   %ebx
f0101194:	6a 25                	push   $0x25
f0101196:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101198:	83 c4 10             	add    $0x10,%esp
f010119b:	eb 03                	jmp    f01011a0 <vprintfmt+0x39a>
f010119d:	83 ef 01             	sub    $0x1,%edi
f01011a0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01011a4:	75 f7                	jne    f010119d <vprintfmt+0x397>
f01011a6:	e9 81 fc ff ff       	jmp    f0100e2c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01011ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011ae:	5b                   	pop    %ebx
f01011af:	5e                   	pop    %esi
f01011b0:	5f                   	pop    %edi
f01011b1:	5d                   	pop    %ebp
f01011b2:	c3                   	ret    

f01011b3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01011b3:	55                   	push   %ebp
f01011b4:	89 e5                	mov    %esp,%ebp
f01011b6:	83 ec 18             	sub    $0x18,%esp
f01011b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01011bc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01011bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01011c2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01011c6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01011c9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01011d0:	85 c0                	test   %eax,%eax
f01011d2:	74 26                	je     f01011fa <vsnprintf+0x47>
f01011d4:	85 d2                	test   %edx,%edx
f01011d6:	7e 22                	jle    f01011fa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01011d8:	ff 75 14             	pushl  0x14(%ebp)
f01011db:	ff 75 10             	pushl  0x10(%ebp)
f01011de:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011e1:	50                   	push   %eax
f01011e2:	68 cc 0d 10 f0       	push   $0xf0100dcc
f01011e7:	e8 1a fc ff ff       	call   f0100e06 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011f5:	83 c4 10             	add    $0x10,%esp
f01011f8:	eb 05                	jmp    f01011ff <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01011fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01011ff:	c9                   	leave  
f0101200:	c3                   	ret    

f0101201 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101201:	55                   	push   %ebp
f0101202:	89 e5                	mov    %esp,%ebp
f0101204:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101207:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010120a:	50                   	push   %eax
f010120b:	ff 75 10             	pushl  0x10(%ebp)
f010120e:	ff 75 0c             	pushl  0xc(%ebp)
f0101211:	ff 75 08             	pushl  0x8(%ebp)
f0101214:	e8 9a ff ff ff       	call   f01011b3 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101219:	c9                   	leave  
f010121a:	c3                   	ret    

f010121b <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010121b:	55                   	push   %ebp
f010121c:	89 e5                	mov    %esp,%ebp
f010121e:	57                   	push   %edi
f010121f:	56                   	push   %esi
f0101220:	53                   	push   %ebx
f0101221:	83 ec 0c             	sub    $0xc,%esp
f0101224:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101227:	85 c0                	test   %eax,%eax
f0101229:	74 11                	je     f010123c <readline+0x21>
		cprintf("%s", prompt);
f010122b:	83 ec 08             	sub    $0x8,%esp
f010122e:	50                   	push   %eax
f010122f:	68 86 1c 10 f0       	push   $0xf0101c86
f0101234:	e8 75 f7 ff ff       	call   f01009ae <cprintf>
f0101239:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010123c:	83 ec 0c             	sub    $0xc,%esp
f010123f:	6a 00                	push   $0x0
f0101241:	e8 40 f4 ff ff       	call   f0100686 <iscons>
f0101246:	89 c7                	mov    %eax,%edi
f0101248:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010124b:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101250:	e8 20 f4 ff ff       	call   f0100675 <getchar>
f0101255:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101257:	85 c0                	test   %eax,%eax
f0101259:	79 18                	jns    f0101273 <readline+0x58>
			cprintf("read error: %e\n", c);
f010125b:	83 ec 08             	sub    $0x8,%esp
f010125e:	50                   	push   %eax
f010125f:	68 c0 20 10 f0       	push   $0xf01020c0
f0101264:	e8 45 f7 ff ff       	call   f01009ae <cprintf>
			return NULL;
f0101269:	83 c4 10             	add    $0x10,%esp
f010126c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101271:	eb 79                	jmp    f01012ec <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101273:	83 f8 08             	cmp    $0x8,%eax
f0101276:	0f 94 c2             	sete   %dl
f0101279:	83 f8 7f             	cmp    $0x7f,%eax
f010127c:	0f 94 c0             	sete   %al
f010127f:	08 c2                	or     %al,%dl
f0101281:	74 1a                	je     f010129d <readline+0x82>
f0101283:	85 f6                	test   %esi,%esi
f0101285:	7e 16                	jle    f010129d <readline+0x82>
			if (echoing)
f0101287:	85 ff                	test   %edi,%edi
f0101289:	74 0d                	je     f0101298 <readline+0x7d>
				cputchar('\b');
f010128b:	83 ec 0c             	sub    $0xc,%esp
f010128e:	6a 08                	push   $0x8
f0101290:	e8 d0 f3 ff ff       	call   f0100665 <cputchar>
f0101295:	83 c4 10             	add    $0x10,%esp
			i--;
f0101298:	83 ee 01             	sub    $0x1,%esi
f010129b:	eb b3                	jmp    f0101250 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010129d:	83 fb 1f             	cmp    $0x1f,%ebx
f01012a0:	7e 23                	jle    f01012c5 <readline+0xaa>
f01012a2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01012a8:	7f 1b                	jg     f01012c5 <readline+0xaa>
			if (echoing)
f01012aa:	85 ff                	test   %edi,%edi
f01012ac:	74 0c                	je     f01012ba <readline+0x9f>
				cputchar(c);
f01012ae:	83 ec 0c             	sub    $0xc,%esp
f01012b1:	53                   	push   %ebx
f01012b2:	e8 ae f3 ff ff       	call   f0100665 <cputchar>
f01012b7:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01012ba:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f01012c0:	8d 76 01             	lea    0x1(%esi),%esi
f01012c3:	eb 8b                	jmp    f0101250 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01012c5:	83 fb 0a             	cmp    $0xa,%ebx
f01012c8:	74 05                	je     f01012cf <readline+0xb4>
f01012ca:	83 fb 0d             	cmp    $0xd,%ebx
f01012cd:	75 81                	jne    f0101250 <readline+0x35>
			if (echoing)
f01012cf:	85 ff                	test   %edi,%edi
f01012d1:	74 0d                	je     f01012e0 <readline+0xc5>
				cputchar('\n');
f01012d3:	83 ec 0c             	sub    $0xc,%esp
f01012d6:	6a 0a                	push   $0xa
f01012d8:	e8 88 f3 ff ff       	call   f0100665 <cputchar>
f01012dd:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01012e0:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01012e7:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f01012ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012ef:	5b                   	pop    %ebx
f01012f0:	5e                   	pop    %esi
f01012f1:	5f                   	pop    %edi
f01012f2:	5d                   	pop    %ebp
f01012f3:	c3                   	ret    

f01012f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012f4:	55                   	push   %ebp
f01012f5:	89 e5                	mov    %esp,%ebp
f01012f7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01012fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01012ff:	eb 03                	jmp    f0101304 <strlen+0x10>
		n++;
f0101301:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101304:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101308:	75 f7                	jne    f0101301 <strlen+0xd>
		n++;
	return n;
}
f010130a:	5d                   	pop    %ebp
f010130b:	c3                   	ret    

f010130c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010130c:	55                   	push   %ebp
f010130d:	89 e5                	mov    %esp,%ebp
f010130f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101312:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101315:	ba 00 00 00 00       	mov    $0x0,%edx
f010131a:	eb 03                	jmp    f010131f <strnlen+0x13>
		n++;
f010131c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010131f:	39 c2                	cmp    %eax,%edx
f0101321:	74 08                	je     f010132b <strnlen+0x1f>
f0101323:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101327:	75 f3                	jne    f010131c <strnlen+0x10>
f0101329:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010132b:	5d                   	pop    %ebp
f010132c:	c3                   	ret    

f010132d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010132d:	55                   	push   %ebp
f010132e:	89 e5                	mov    %esp,%ebp
f0101330:	53                   	push   %ebx
f0101331:	8b 45 08             	mov    0x8(%ebp),%eax
f0101334:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101337:	89 c2                	mov    %eax,%edx
f0101339:	83 c2 01             	add    $0x1,%edx
f010133c:	83 c1 01             	add    $0x1,%ecx
f010133f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101343:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101346:	84 db                	test   %bl,%bl
f0101348:	75 ef                	jne    f0101339 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010134a:	5b                   	pop    %ebx
f010134b:	5d                   	pop    %ebp
f010134c:	c3                   	ret    

f010134d <strcat>:

char *
strcat(char *dst, const char *src)
{
f010134d:	55                   	push   %ebp
f010134e:	89 e5                	mov    %esp,%ebp
f0101350:	53                   	push   %ebx
f0101351:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101354:	53                   	push   %ebx
f0101355:	e8 9a ff ff ff       	call   f01012f4 <strlen>
f010135a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010135d:	ff 75 0c             	pushl  0xc(%ebp)
f0101360:	01 d8                	add    %ebx,%eax
f0101362:	50                   	push   %eax
f0101363:	e8 c5 ff ff ff       	call   f010132d <strcpy>
	return dst;
}
f0101368:	89 d8                	mov    %ebx,%eax
f010136a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010136d:	c9                   	leave  
f010136e:	c3                   	ret    

f010136f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010136f:	55                   	push   %ebp
f0101370:	89 e5                	mov    %esp,%ebp
f0101372:	56                   	push   %esi
f0101373:	53                   	push   %ebx
f0101374:	8b 75 08             	mov    0x8(%ebp),%esi
f0101377:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010137a:	89 f3                	mov    %esi,%ebx
f010137c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010137f:	89 f2                	mov    %esi,%edx
f0101381:	eb 0f                	jmp    f0101392 <strncpy+0x23>
		*dst++ = *src;
f0101383:	83 c2 01             	add    $0x1,%edx
f0101386:	0f b6 01             	movzbl (%ecx),%eax
f0101389:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010138c:	80 39 01             	cmpb   $0x1,(%ecx)
f010138f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101392:	39 da                	cmp    %ebx,%edx
f0101394:	75 ed                	jne    f0101383 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101396:	89 f0                	mov    %esi,%eax
f0101398:	5b                   	pop    %ebx
f0101399:	5e                   	pop    %esi
f010139a:	5d                   	pop    %ebp
f010139b:	c3                   	ret    

f010139c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010139c:	55                   	push   %ebp
f010139d:	89 e5                	mov    %esp,%ebp
f010139f:	56                   	push   %esi
f01013a0:	53                   	push   %ebx
f01013a1:	8b 75 08             	mov    0x8(%ebp),%esi
f01013a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013a7:	8b 55 10             	mov    0x10(%ebp),%edx
f01013aa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01013ac:	85 d2                	test   %edx,%edx
f01013ae:	74 21                	je     f01013d1 <strlcpy+0x35>
f01013b0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01013b4:	89 f2                	mov    %esi,%edx
f01013b6:	eb 09                	jmp    f01013c1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01013b8:	83 c2 01             	add    $0x1,%edx
f01013bb:	83 c1 01             	add    $0x1,%ecx
f01013be:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01013c1:	39 c2                	cmp    %eax,%edx
f01013c3:	74 09                	je     f01013ce <strlcpy+0x32>
f01013c5:	0f b6 19             	movzbl (%ecx),%ebx
f01013c8:	84 db                	test   %bl,%bl
f01013ca:	75 ec                	jne    f01013b8 <strlcpy+0x1c>
f01013cc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01013ce:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01013d1:	29 f0                	sub    %esi,%eax
}
f01013d3:	5b                   	pop    %ebx
f01013d4:	5e                   	pop    %esi
f01013d5:	5d                   	pop    %ebp
f01013d6:	c3                   	ret    

f01013d7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01013d7:	55                   	push   %ebp
f01013d8:	89 e5                	mov    %esp,%ebp
f01013da:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013e0:	eb 06                	jmp    f01013e8 <strcmp+0x11>
		p++, q++;
f01013e2:	83 c1 01             	add    $0x1,%ecx
f01013e5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01013e8:	0f b6 01             	movzbl (%ecx),%eax
f01013eb:	84 c0                	test   %al,%al
f01013ed:	74 04                	je     f01013f3 <strcmp+0x1c>
f01013ef:	3a 02                	cmp    (%edx),%al
f01013f1:	74 ef                	je     f01013e2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01013f3:	0f b6 c0             	movzbl %al,%eax
f01013f6:	0f b6 12             	movzbl (%edx),%edx
f01013f9:	29 d0                	sub    %edx,%eax
}
f01013fb:	5d                   	pop    %ebp
f01013fc:	c3                   	ret    

f01013fd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01013fd:	55                   	push   %ebp
f01013fe:	89 e5                	mov    %esp,%ebp
f0101400:	53                   	push   %ebx
f0101401:	8b 45 08             	mov    0x8(%ebp),%eax
f0101404:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101407:	89 c3                	mov    %eax,%ebx
f0101409:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010140c:	eb 06                	jmp    f0101414 <strncmp+0x17>
		n--, p++, q++;
f010140e:	83 c0 01             	add    $0x1,%eax
f0101411:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101414:	39 d8                	cmp    %ebx,%eax
f0101416:	74 15                	je     f010142d <strncmp+0x30>
f0101418:	0f b6 08             	movzbl (%eax),%ecx
f010141b:	84 c9                	test   %cl,%cl
f010141d:	74 04                	je     f0101423 <strncmp+0x26>
f010141f:	3a 0a                	cmp    (%edx),%cl
f0101421:	74 eb                	je     f010140e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101423:	0f b6 00             	movzbl (%eax),%eax
f0101426:	0f b6 12             	movzbl (%edx),%edx
f0101429:	29 d0                	sub    %edx,%eax
f010142b:	eb 05                	jmp    f0101432 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010142d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101432:	5b                   	pop    %ebx
f0101433:	5d                   	pop    %ebp
f0101434:	c3                   	ret    

f0101435 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101435:	55                   	push   %ebp
f0101436:	89 e5                	mov    %esp,%ebp
f0101438:	8b 45 08             	mov    0x8(%ebp),%eax
f010143b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010143f:	eb 07                	jmp    f0101448 <strchr+0x13>
		if (*s == c)
f0101441:	38 ca                	cmp    %cl,%dl
f0101443:	74 0f                	je     f0101454 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101445:	83 c0 01             	add    $0x1,%eax
f0101448:	0f b6 10             	movzbl (%eax),%edx
f010144b:	84 d2                	test   %dl,%dl
f010144d:	75 f2                	jne    f0101441 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010144f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101454:	5d                   	pop    %ebp
f0101455:	c3                   	ret    

f0101456 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101456:	55                   	push   %ebp
f0101457:	89 e5                	mov    %esp,%ebp
f0101459:	8b 45 08             	mov    0x8(%ebp),%eax
f010145c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101460:	eb 03                	jmp    f0101465 <strfind+0xf>
f0101462:	83 c0 01             	add    $0x1,%eax
f0101465:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101468:	38 ca                	cmp    %cl,%dl
f010146a:	74 04                	je     f0101470 <strfind+0x1a>
f010146c:	84 d2                	test   %dl,%dl
f010146e:	75 f2                	jne    f0101462 <strfind+0xc>
			break;
	return (char *) s;
}
f0101470:	5d                   	pop    %ebp
f0101471:	c3                   	ret    

f0101472 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101472:	55                   	push   %ebp
f0101473:	89 e5                	mov    %esp,%ebp
f0101475:	57                   	push   %edi
f0101476:	56                   	push   %esi
f0101477:	53                   	push   %ebx
f0101478:	8b 7d 08             	mov    0x8(%ebp),%edi
f010147b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010147e:	85 c9                	test   %ecx,%ecx
f0101480:	74 36                	je     f01014b8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101482:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101488:	75 28                	jne    f01014b2 <memset+0x40>
f010148a:	f6 c1 03             	test   $0x3,%cl
f010148d:	75 23                	jne    f01014b2 <memset+0x40>
		c &= 0xFF;
f010148f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101493:	89 d3                	mov    %edx,%ebx
f0101495:	c1 e3 08             	shl    $0x8,%ebx
f0101498:	89 d6                	mov    %edx,%esi
f010149a:	c1 e6 18             	shl    $0x18,%esi
f010149d:	89 d0                	mov    %edx,%eax
f010149f:	c1 e0 10             	shl    $0x10,%eax
f01014a2:	09 f0                	or     %esi,%eax
f01014a4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01014a6:	89 d8                	mov    %ebx,%eax
f01014a8:	09 d0                	or     %edx,%eax
f01014aa:	c1 e9 02             	shr    $0x2,%ecx
f01014ad:	fc                   	cld    
f01014ae:	f3 ab                	rep stos %eax,%es:(%edi)
f01014b0:	eb 06                	jmp    f01014b8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01014b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014b5:	fc                   	cld    
f01014b6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01014b8:	89 f8                	mov    %edi,%eax
f01014ba:	5b                   	pop    %ebx
f01014bb:	5e                   	pop    %esi
f01014bc:	5f                   	pop    %edi
f01014bd:	5d                   	pop    %ebp
f01014be:	c3                   	ret    

f01014bf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01014bf:	55                   	push   %ebp
f01014c0:	89 e5                	mov    %esp,%ebp
f01014c2:	57                   	push   %edi
f01014c3:	56                   	push   %esi
f01014c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01014c7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01014cd:	39 c6                	cmp    %eax,%esi
f01014cf:	73 35                	jae    f0101506 <memmove+0x47>
f01014d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01014d4:	39 d0                	cmp    %edx,%eax
f01014d6:	73 2e                	jae    f0101506 <memmove+0x47>
		s += n;
		d += n;
f01014d8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014db:	89 d6                	mov    %edx,%esi
f01014dd:	09 fe                	or     %edi,%esi
f01014df:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014e5:	75 13                	jne    f01014fa <memmove+0x3b>
f01014e7:	f6 c1 03             	test   $0x3,%cl
f01014ea:	75 0e                	jne    f01014fa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01014ec:	83 ef 04             	sub    $0x4,%edi
f01014ef:	8d 72 fc             	lea    -0x4(%edx),%esi
f01014f2:	c1 e9 02             	shr    $0x2,%ecx
f01014f5:	fd                   	std    
f01014f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014f8:	eb 09                	jmp    f0101503 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01014fa:	83 ef 01             	sub    $0x1,%edi
f01014fd:	8d 72 ff             	lea    -0x1(%edx),%esi
f0101500:	fd                   	std    
f0101501:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101503:	fc                   	cld    
f0101504:	eb 1d                	jmp    f0101523 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101506:	89 f2                	mov    %esi,%edx
f0101508:	09 c2                	or     %eax,%edx
f010150a:	f6 c2 03             	test   $0x3,%dl
f010150d:	75 0f                	jne    f010151e <memmove+0x5f>
f010150f:	f6 c1 03             	test   $0x3,%cl
f0101512:	75 0a                	jne    f010151e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0101514:	c1 e9 02             	shr    $0x2,%ecx
f0101517:	89 c7                	mov    %eax,%edi
f0101519:	fc                   	cld    
f010151a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010151c:	eb 05                	jmp    f0101523 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010151e:	89 c7                	mov    %eax,%edi
f0101520:	fc                   	cld    
f0101521:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101523:	5e                   	pop    %esi
f0101524:	5f                   	pop    %edi
f0101525:	5d                   	pop    %ebp
f0101526:	c3                   	ret    

f0101527 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101527:	55                   	push   %ebp
f0101528:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010152a:	ff 75 10             	pushl  0x10(%ebp)
f010152d:	ff 75 0c             	pushl  0xc(%ebp)
f0101530:	ff 75 08             	pushl  0x8(%ebp)
f0101533:	e8 87 ff ff ff       	call   f01014bf <memmove>
}
f0101538:	c9                   	leave  
f0101539:	c3                   	ret    

f010153a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010153a:	55                   	push   %ebp
f010153b:	89 e5                	mov    %esp,%ebp
f010153d:	56                   	push   %esi
f010153e:	53                   	push   %ebx
f010153f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101542:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101545:	89 c6                	mov    %eax,%esi
f0101547:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010154a:	eb 1a                	jmp    f0101566 <memcmp+0x2c>
		if (*s1 != *s2)
f010154c:	0f b6 08             	movzbl (%eax),%ecx
f010154f:	0f b6 1a             	movzbl (%edx),%ebx
f0101552:	38 d9                	cmp    %bl,%cl
f0101554:	74 0a                	je     f0101560 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0101556:	0f b6 c1             	movzbl %cl,%eax
f0101559:	0f b6 db             	movzbl %bl,%ebx
f010155c:	29 d8                	sub    %ebx,%eax
f010155e:	eb 0f                	jmp    f010156f <memcmp+0x35>
		s1++, s2++;
f0101560:	83 c0 01             	add    $0x1,%eax
f0101563:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101566:	39 f0                	cmp    %esi,%eax
f0101568:	75 e2                	jne    f010154c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010156a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010156f:	5b                   	pop    %ebx
f0101570:	5e                   	pop    %esi
f0101571:	5d                   	pop    %ebp
f0101572:	c3                   	ret    

f0101573 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101573:	55                   	push   %ebp
f0101574:	89 e5                	mov    %esp,%ebp
f0101576:	53                   	push   %ebx
f0101577:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010157a:	89 c1                	mov    %eax,%ecx
f010157c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010157f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101583:	eb 0a                	jmp    f010158f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101585:	0f b6 10             	movzbl (%eax),%edx
f0101588:	39 da                	cmp    %ebx,%edx
f010158a:	74 07                	je     f0101593 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010158c:	83 c0 01             	add    $0x1,%eax
f010158f:	39 c8                	cmp    %ecx,%eax
f0101591:	72 f2                	jb     f0101585 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101593:	5b                   	pop    %ebx
f0101594:	5d                   	pop    %ebp
f0101595:	c3                   	ret    

f0101596 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101596:	55                   	push   %ebp
f0101597:	89 e5                	mov    %esp,%ebp
f0101599:	57                   	push   %edi
f010159a:	56                   	push   %esi
f010159b:	53                   	push   %ebx
f010159c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010159f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015a2:	eb 03                	jmp    f01015a7 <strtol+0x11>
		s++;
f01015a4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015a7:	0f b6 01             	movzbl (%ecx),%eax
f01015aa:	3c 20                	cmp    $0x20,%al
f01015ac:	74 f6                	je     f01015a4 <strtol+0xe>
f01015ae:	3c 09                	cmp    $0x9,%al
f01015b0:	74 f2                	je     f01015a4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01015b2:	3c 2b                	cmp    $0x2b,%al
f01015b4:	75 0a                	jne    f01015c0 <strtol+0x2a>
		s++;
f01015b6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01015b9:	bf 00 00 00 00       	mov    $0x0,%edi
f01015be:	eb 11                	jmp    f01015d1 <strtol+0x3b>
f01015c0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01015c5:	3c 2d                	cmp    $0x2d,%al
f01015c7:	75 08                	jne    f01015d1 <strtol+0x3b>
		s++, neg = 1;
f01015c9:	83 c1 01             	add    $0x1,%ecx
f01015cc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01015d1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01015d7:	75 15                	jne    f01015ee <strtol+0x58>
f01015d9:	80 39 30             	cmpb   $0x30,(%ecx)
f01015dc:	75 10                	jne    f01015ee <strtol+0x58>
f01015de:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01015e2:	75 7c                	jne    f0101660 <strtol+0xca>
		s += 2, base = 16;
f01015e4:	83 c1 02             	add    $0x2,%ecx
f01015e7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01015ec:	eb 16                	jmp    f0101604 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01015ee:	85 db                	test   %ebx,%ebx
f01015f0:	75 12                	jne    f0101604 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01015f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015f7:	80 39 30             	cmpb   $0x30,(%ecx)
f01015fa:	75 08                	jne    f0101604 <strtol+0x6e>
		s++, base = 8;
f01015fc:	83 c1 01             	add    $0x1,%ecx
f01015ff:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0101604:	b8 00 00 00 00       	mov    $0x0,%eax
f0101609:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010160c:	0f b6 11             	movzbl (%ecx),%edx
f010160f:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101612:	89 f3                	mov    %esi,%ebx
f0101614:	80 fb 09             	cmp    $0x9,%bl
f0101617:	77 08                	ja     f0101621 <strtol+0x8b>
			dig = *s - '0';
f0101619:	0f be d2             	movsbl %dl,%edx
f010161c:	83 ea 30             	sub    $0x30,%edx
f010161f:	eb 22                	jmp    f0101643 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0101621:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101624:	89 f3                	mov    %esi,%ebx
f0101626:	80 fb 19             	cmp    $0x19,%bl
f0101629:	77 08                	ja     f0101633 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010162b:	0f be d2             	movsbl %dl,%edx
f010162e:	83 ea 57             	sub    $0x57,%edx
f0101631:	eb 10                	jmp    f0101643 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0101633:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101636:	89 f3                	mov    %esi,%ebx
f0101638:	80 fb 19             	cmp    $0x19,%bl
f010163b:	77 16                	ja     f0101653 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010163d:	0f be d2             	movsbl %dl,%edx
f0101640:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101643:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101646:	7d 0b                	jge    f0101653 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0101648:	83 c1 01             	add    $0x1,%ecx
f010164b:	0f af 45 10          	imul   0x10(%ebp),%eax
f010164f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101651:	eb b9                	jmp    f010160c <strtol+0x76>

	if (endptr)
f0101653:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101657:	74 0d                	je     f0101666 <strtol+0xd0>
		*endptr = (char *) s;
f0101659:	8b 75 0c             	mov    0xc(%ebp),%esi
f010165c:	89 0e                	mov    %ecx,(%esi)
f010165e:	eb 06                	jmp    f0101666 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101660:	85 db                	test   %ebx,%ebx
f0101662:	74 98                	je     f01015fc <strtol+0x66>
f0101664:	eb 9e                	jmp    f0101604 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0101666:	89 c2                	mov    %eax,%edx
f0101668:	f7 da                	neg    %edx
f010166a:	85 ff                	test   %edi,%edi
f010166c:	0f 45 c2             	cmovne %edx,%eax
}
f010166f:	5b                   	pop    %ebx
f0101670:	5e                   	pop    %esi
f0101671:	5f                   	pop    %edi
f0101672:	5d                   	pop    %ebp
f0101673:	c3                   	ret    
f0101674:	66 90                	xchg   %ax,%ax
f0101676:	66 90                	xchg   %ax,%ax
f0101678:	66 90                	xchg   %ax,%ax
f010167a:	66 90                	xchg   %ax,%ax
f010167c:	66 90                	xchg   %ax,%ax
f010167e:	66 90                	xchg   %ax,%ax

f0101680 <__udivdi3>:
f0101680:	55                   	push   %ebp
f0101681:	57                   	push   %edi
f0101682:	56                   	push   %esi
f0101683:	53                   	push   %ebx
f0101684:	83 ec 1c             	sub    $0x1c,%esp
f0101687:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010168b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010168f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101693:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101697:	85 f6                	test   %esi,%esi
f0101699:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010169d:	89 ca                	mov    %ecx,%edx
f010169f:	89 f8                	mov    %edi,%eax
f01016a1:	75 3d                	jne    f01016e0 <__udivdi3+0x60>
f01016a3:	39 cf                	cmp    %ecx,%edi
f01016a5:	0f 87 c5 00 00 00    	ja     f0101770 <__udivdi3+0xf0>
f01016ab:	85 ff                	test   %edi,%edi
f01016ad:	89 fd                	mov    %edi,%ebp
f01016af:	75 0b                	jne    f01016bc <__udivdi3+0x3c>
f01016b1:	b8 01 00 00 00       	mov    $0x1,%eax
f01016b6:	31 d2                	xor    %edx,%edx
f01016b8:	f7 f7                	div    %edi
f01016ba:	89 c5                	mov    %eax,%ebp
f01016bc:	89 c8                	mov    %ecx,%eax
f01016be:	31 d2                	xor    %edx,%edx
f01016c0:	f7 f5                	div    %ebp
f01016c2:	89 c1                	mov    %eax,%ecx
f01016c4:	89 d8                	mov    %ebx,%eax
f01016c6:	89 cf                	mov    %ecx,%edi
f01016c8:	f7 f5                	div    %ebp
f01016ca:	89 c3                	mov    %eax,%ebx
f01016cc:	89 d8                	mov    %ebx,%eax
f01016ce:	89 fa                	mov    %edi,%edx
f01016d0:	83 c4 1c             	add    $0x1c,%esp
f01016d3:	5b                   	pop    %ebx
f01016d4:	5e                   	pop    %esi
f01016d5:	5f                   	pop    %edi
f01016d6:	5d                   	pop    %ebp
f01016d7:	c3                   	ret    
f01016d8:	90                   	nop
f01016d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016e0:	39 ce                	cmp    %ecx,%esi
f01016e2:	77 74                	ja     f0101758 <__udivdi3+0xd8>
f01016e4:	0f bd fe             	bsr    %esi,%edi
f01016e7:	83 f7 1f             	xor    $0x1f,%edi
f01016ea:	0f 84 98 00 00 00    	je     f0101788 <__udivdi3+0x108>
f01016f0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01016f5:	89 f9                	mov    %edi,%ecx
f01016f7:	89 c5                	mov    %eax,%ebp
f01016f9:	29 fb                	sub    %edi,%ebx
f01016fb:	d3 e6                	shl    %cl,%esi
f01016fd:	89 d9                	mov    %ebx,%ecx
f01016ff:	d3 ed                	shr    %cl,%ebp
f0101701:	89 f9                	mov    %edi,%ecx
f0101703:	d3 e0                	shl    %cl,%eax
f0101705:	09 ee                	or     %ebp,%esi
f0101707:	89 d9                	mov    %ebx,%ecx
f0101709:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010170d:	89 d5                	mov    %edx,%ebp
f010170f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101713:	d3 ed                	shr    %cl,%ebp
f0101715:	89 f9                	mov    %edi,%ecx
f0101717:	d3 e2                	shl    %cl,%edx
f0101719:	89 d9                	mov    %ebx,%ecx
f010171b:	d3 e8                	shr    %cl,%eax
f010171d:	09 c2                	or     %eax,%edx
f010171f:	89 d0                	mov    %edx,%eax
f0101721:	89 ea                	mov    %ebp,%edx
f0101723:	f7 f6                	div    %esi
f0101725:	89 d5                	mov    %edx,%ebp
f0101727:	89 c3                	mov    %eax,%ebx
f0101729:	f7 64 24 0c          	mull   0xc(%esp)
f010172d:	39 d5                	cmp    %edx,%ebp
f010172f:	72 10                	jb     f0101741 <__udivdi3+0xc1>
f0101731:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101735:	89 f9                	mov    %edi,%ecx
f0101737:	d3 e6                	shl    %cl,%esi
f0101739:	39 c6                	cmp    %eax,%esi
f010173b:	73 07                	jae    f0101744 <__udivdi3+0xc4>
f010173d:	39 d5                	cmp    %edx,%ebp
f010173f:	75 03                	jne    f0101744 <__udivdi3+0xc4>
f0101741:	83 eb 01             	sub    $0x1,%ebx
f0101744:	31 ff                	xor    %edi,%edi
f0101746:	89 d8                	mov    %ebx,%eax
f0101748:	89 fa                	mov    %edi,%edx
f010174a:	83 c4 1c             	add    $0x1c,%esp
f010174d:	5b                   	pop    %ebx
f010174e:	5e                   	pop    %esi
f010174f:	5f                   	pop    %edi
f0101750:	5d                   	pop    %ebp
f0101751:	c3                   	ret    
f0101752:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101758:	31 ff                	xor    %edi,%edi
f010175a:	31 db                	xor    %ebx,%ebx
f010175c:	89 d8                	mov    %ebx,%eax
f010175e:	89 fa                	mov    %edi,%edx
f0101760:	83 c4 1c             	add    $0x1c,%esp
f0101763:	5b                   	pop    %ebx
f0101764:	5e                   	pop    %esi
f0101765:	5f                   	pop    %edi
f0101766:	5d                   	pop    %ebp
f0101767:	c3                   	ret    
f0101768:	90                   	nop
f0101769:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101770:	89 d8                	mov    %ebx,%eax
f0101772:	f7 f7                	div    %edi
f0101774:	31 ff                	xor    %edi,%edi
f0101776:	89 c3                	mov    %eax,%ebx
f0101778:	89 d8                	mov    %ebx,%eax
f010177a:	89 fa                	mov    %edi,%edx
f010177c:	83 c4 1c             	add    $0x1c,%esp
f010177f:	5b                   	pop    %ebx
f0101780:	5e                   	pop    %esi
f0101781:	5f                   	pop    %edi
f0101782:	5d                   	pop    %ebp
f0101783:	c3                   	ret    
f0101784:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101788:	39 ce                	cmp    %ecx,%esi
f010178a:	72 0c                	jb     f0101798 <__udivdi3+0x118>
f010178c:	31 db                	xor    %ebx,%ebx
f010178e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101792:	0f 87 34 ff ff ff    	ja     f01016cc <__udivdi3+0x4c>
f0101798:	bb 01 00 00 00       	mov    $0x1,%ebx
f010179d:	e9 2a ff ff ff       	jmp    f01016cc <__udivdi3+0x4c>
f01017a2:	66 90                	xchg   %ax,%ax
f01017a4:	66 90                	xchg   %ax,%ax
f01017a6:	66 90                	xchg   %ax,%ax
f01017a8:	66 90                	xchg   %ax,%ax
f01017aa:	66 90                	xchg   %ax,%ax
f01017ac:	66 90                	xchg   %ax,%ax
f01017ae:	66 90                	xchg   %ax,%ax

f01017b0 <__umoddi3>:
f01017b0:	55                   	push   %ebp
f01017b1:	57                   	push   %edi
f01017b2:	56                   	push   %esi
f01017b3:	53                   	push   %ebx
f01017b4:	83 ec 1c             	sub    $0x1c,%esp
f01017b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01017bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01017bf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01017c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01017c7:	85 d2                	test   %edx,%edx
f01017c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01017cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01017d1:	89 f3                	mov    %esi,%ebx
f01017d3:	89 3c 24             	mov    %edi,(%esp)
f01017d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017da:	75 1c                	jne    f01017f8 <__umoddi3+0x48>
f01017dc:	39 f7                	cmp    %esi,%edi
f01017de:	76 50                	jbe    f0101830 <__umoddi3+0x80>
f01017e0:	89 c8                	mov    %ecx,%eax
f01017e2:	89 f2                	mov    %esi,%edx
f01017e4:	f7 f7                	div    %edi
f01017e6:	89 d0                	mov    %edx,%eax
f01017e8:	31 d2                	xor    %edx,%edx
f01017ea:	83 c4 1c             	add    $0x1c,%esp
f01017ed:	5b                   	pop    %ebx
f01017ee:	5e                   	pop    %esi
f01017ef:	5f                   	pop    %edi
f01017f0:	5d                   	pop    %ebp
f01017f1:	c3                   	ret    
f01017f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017f8:	39 f2                	cmp    %esi,%edx
f01017fa:	89 d0                	mov    %edx,%eax
f01017fc:	77 52                	ja     f0101850 <__umoddi3+0xa0>
f01017fe:	0f bd ea             	bsr    %edx,%ebp
f0101801:	83 f5 1f             	xor    $0x1f,%ebp
f0101804:	75 5a                	jne    f0101860 <__umoddi3+0xb0>
f0101806:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010180a:	0f 82 e0 00 00 00    	jb     f01018f0 <__umoddi3+0x140>
f0101810:	39 0c 24             	cmp    %ecx,(%esp)
f0101813:	0f 86 d7 00 00 00    	jbe    f01018f0 <__umoddi3+0x140>
f0101819:	8b 44 24 08          	mov    0x8(%esp),%eax
f010181d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101821:	83 c4 1c             	add    $0x1c,%esp
f0101824:	5b                   	pop    %ebx
f0101825:	5e                   	pop    %esi
f0101826:	5f                   	pop    %edi
f0101827:	5d                   	pop    %ebp
f0101828:	c3                   	ret    
f0101829:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101830:	85 ff                	test   %edi,%edi
f0101832:	89 fd                	mov    %edi,%ebp
f0101834:	75 0b                	jne    f0101841 <__umoddi3+0x91>
f0101836:	b8 01 00 00 00       	mov    $0x1,%eax
f010183b:	31 d2                	xor    %edx,%edx
f010183d:	f7 f7                	div    %edi
f010183f:	89 c5                	mov    %eax,%ebp
f0101841:	89 f0                	mov    %esi,%eax
f0101843:	31 d2                	xor    %edx,%edx
f0101845:	f7 f5                	div    %ebp
f0101847:	89 c8                	mov    %ecx,%eax
f0101849:	f7 f5                	div    %ebp
f010184b:	89 d0                	mov    %edx,%eax
f010184d:	eb 99                	jmp    f01017e8 <__umoddi3+0x38>
f010184f:	90                   	nop
f0101850:	89 c8                	mov    %ecx,%eax
f0101852:	89 f2                	mov    %esi,%edx
f0101854:	83 c4 1c             	add    $0x1c,%esp
f0101857:	5b                   	pop    %ebx
f0101858:	5e                   	pop    %esi
f0101859:	5f                   	pop    %edi
f010185a:	5d                   	pop    %ebp
f010185b:	c3                   	ret    
f010185c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101860:	8b 34 24             	mov    (%esp),%esi
f0101863:	bf 20 00 00 00       	mov    $0x20,%edi
f0101868:	89 e9                	mov    %ebp,%ecx
f010186a:	29 ef                	sub    %ebp,%edi
f010186c:	d3 e0                	shl    %cl,%eax
f010186e:	89 f9                	mov    %edi,%ecx
f0101870:	89 f2                	mov    %esi,%edx
f0101872:	d3 ea                	shr    %cl,%edx
f0101874:	89 e9                	mov    %ebp,%ecx
f0101876:	09 c2                	or     %eax,%edx
f0101878:	89 d8                	mov    %ebx,%eax
f010187a:	89 14 24             	mov    %edx,(%esp)
f010187d:	89 f2                	mov    %esi,%edx
f010187f:	d3 e2                	shl    %cl,%edx
f0101881:	89 f9                	mov    %edi,%ecx
f0101883:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101887:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010188b:	d3 e8                	shr    %cl,%eax
f010188d:	89 e9                	mov    %ebp,%ecx
f010188f:	89 c6                	mov    %eax,%esi
f0101891:	d3 e3                	shl    %cl,%ebx
f0101893:	89 f9                	mov    %edi,%ecx
f0101895:	89 d0                	mov    %edx,%eax
f0101897:	d3 e8                	shr    %cl,%eax
f0101899:	89 e9                	mov    %ebp,%ecx
f010189b:	09 d8                	or     %ebx,%eax
f010189d:	89 d3                	mov    %edx,%ebx
f010189f:	89 f2                	mov    %esi,%edx
f01018a1:	f7 34 24             	divl   (%esp)
f01018a4:	89 d6                	mov    %edx,%esi
f01018a6:	d3 e3                	shl    %cl,%ebx
f01018a8:	f7 64 24 04          	mull   0x4(%esp)
f01018ac:	39 d6                	cmp    %edx,%esi
f01018ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01018b2:	89 d1                	mov    %edx,%ecx
f01018b4:	89 c3                	mov    %eax,%ebx
f01018b6:	72 08                	jb     f01018c0 <__umoddi3+0x110>
f01018b8:	75 11                	jne    f01018cb <__umoddi3+0x11b>
f01018ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01018be:	73 0b                	jae    f01018cb <__umoddi3+0x11b>
f01018c0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01018c4:	1b 14 24             	sbb    (%esp),%edx
f01018c7:	89 d1                	mov    %edx,%ecx
f01018c9:	89 c3                	mov    %eax,%ebx
f01018cb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01018cf:	29 da                	sub    %ebx,%edx
f01018d1:	19 ce                	sbb    %ecx,%esi
f01018d3:	89 f9                	mov    %edi,%ecx
f01018d5:	89 f0                	mov    %esi,%eax
f01018d7:	d3 e0                	shl    %cl,%eax
f01018d9:	89 e9                	mov    %ebp,%ecx
f01018db:	d3 ea                	shr    %cl,%edx
f01018dd:	89 e9                	mov    %ebp,%ecx
f01018df:	d3 ee                	shr    %cl,%esi
f01018e1:	09 d0                	or     %edx,%eax
f01018e3:	89 f2                	mov    %esi,%edx
f01018e5:	83 c4 1c             	add    $0x1c,%esp
f01018e8:	5b                   	pop    %ebx
f01018e9:	5e                   	pop    %esi
f01018ea:	5f                   	pop    %edi
f01018eb:	5d                   	pop    %ebp
f01018ec:	c3                   	ret    
f01018ed:	8d 76 00             	lea    0x0(%esi),%esi
f01018f0:	29 f9                	sub    %edi,%ecx
f01018f2:	19 d6                	sbb    %edx,%esi
f01018f4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01018fc:	e9 18 ff ff ff       	jmp    f0101819 <__umoddi3+0x69>
