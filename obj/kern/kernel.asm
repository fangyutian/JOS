
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
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
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
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:


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
f010004b:	68 e0 4a 10 f0       	push   $0xf0104ae0
f0100050:	e8 ab 32 00 00       	call   f0103300 <cprintf>
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
f0100076:	e8 0f 07 00 00       	call   f010078a <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 fc 4a 10 f0       	push   $0xf0104afc
f0100087:	e8 74 32 00 00       	call   f0103300 <cprintf>
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
f010009a:	b8 14 de 17 f0       	mov    $0xf017de14,%eax
f010009f:	2d ee ce 17 f0       	sub    $0xf017ceee,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 ee ce 17 f0       	push   $0xf017ceee
f01000ac:	e8 99 45 00 00       	call   f010464a <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 ba 04 00 00       	call   f0100570 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 17 4b 10 f0       	push   $0xf0104b17
f01000c3:	e8 38 32 00 00       	call   f0103300 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000c8:	e8 e9 12 00 00       	call   f01013b6 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000cd:	e8 7d 2c 00 00       	call   f0102d4f <env_init>
	trap_init();
f01000d2:	e8 9a 32 00 00       	call   f0103371 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01000d7:	83 c4 0c             	add    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	68 30 78 00 00       	push   $0x7830
f01000e1:	68 c6 1c 13 f0       	push   $0xf0131cc6
f01000e6:	e8 2a 2e 00 00       	call   f0102f15 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000eb:	83 c4 04             	add    $0x4,%esp
f01000ee:	ff 35 4c d1 17 f0    	pushl  0xf017d14c
f01000f4:	e8 40 31 00 00       	call   f0103239 <env_run>

f01000f9 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f9:	55                   	push   %ebp
f01000fa:	89 e5                	mov    %esp,%ebp
f01000fc:	56                   	push   %esi
f01000fd:	53                   	push   %ebx
f01000fe:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100101:	83 3d 00 de 17 f0 00 	cmpl   $0x0,0xf017de00
f0100108:	75 37                	jne    f0100141 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010010a:	89 35 00 de 17 f0    	mov    %esi,0xf017de00

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100110:	fa                   	cli    
f0100111:	fc                   	cld    

	va_start(ap, fmt);
f0100112:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100115:	83 ec 04             	sub    $0x4,%esp
f0100118:	ff 75 0c             	pushl  0xc(%ebp)
f010011b:	ff 75 08             	pushl  0x8(%ebp)
f010011e:	68 32 4b 10 f0       	push   $0xf0104b32
f0100123:	e8 d8 31 00 00       	call   f0103300 <cprintf>
	vcprintf(fmt, ap);
f0100128:	83 c4 08             	add    $0x8,%esp
f010012b:	53                   	push   %ebx
f010012c:	56                   	push   %esi
f010012d:	e8 a8 31 00 00       	call   f01032da <vcprintf>
	cprintf("\n");
f0100132:	c7 04 24 1a 55 10 f0 	movl   $0xf010551a,(%esp)
f0100139:	e8 c2 31 00 00       	call   f0103300 <cprintf>
	va_end(ap);
f010013e:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100141:	83 ec 0c             	sub    $0xc,%esp
f0100144:	6a 00                	push   $0x0
f0100146:	e8 52 07 00 00       	call   f010089d <monitor>
f010014b:	83 c4 10             	add    $0x10,%esp
f010014e:	eb f1                	jmp    f0100141 <_panic+0x48>

f0100150 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100150:	55                   	push   %ebp
f0100151:	89 e5                	mov    %esp,%ebp
f0100153:	53                   	push   %ebx
f0100154:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100157:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010015a:	ff 75 0c             	pushl  0xc(%ebp)
f010015d:	ff 75 08             	pushl  0x8(%ebp)
f0100160:	68 4a 4b 10 f0       	push   $0xf0104b4a
f0100165:	e8 96 31 00 00       	call   f0103300 <cprintf>
	vcprintf(fmt, ap);
f010016a:	83 c4 08             	add    $0x8,%esp
f010016d:	53                   	push   %ebx
f010016e:	ff 75 10             	pushl  0x10(%ebp)
f0100171:	e8 64 31 00 00       	call   f01032da <vcprintf>
	cprintf("\n");
f0100176:	c7 04 24 1a 55 10 f0 	movl   $0xf010551a,(%esp)
f010017d:	e8 7e 31 00 00       	call   f0103300 <cprintf>
	va_end(ap);
}
f0100182:	83 c4 10             	add    $0x10,%esp
f0100185:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100188:	c9                   	leave  
f0100189:	c3                   	ret    

f010018a <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010018a:	55                   	push   %ebp
f010018b:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010018d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100192:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100193:	a8 01                	test   $0x1,%al
f0100195:	74 0b                	je     f01001a2 <serial_proc_data+0x18>
f0100197:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010019c:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010019d:	0f b6 c0             	movzbl %al,%eax
f01001a0:	eb 05                	jmp    f01001a7 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001a7:	5d                   	pop    %ebp
f01001a8:	c3                   	ret    

f01001a9 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001a9:	55                   	push   %ebp
f01001aa:	89 e5                	mov    %esp,%ebp
f01001ac:	53                   	push   %ebx
f01001ad:	83 ec 04             	sub    $0x4,%esp
f01001b0:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001b2:	eb 2b                	jmp    f01001df <cons_intr+0x36>
		if (c == 0)
f01001b4:	85 c0                	test   %eax,%eax
f01001b6:	74 27                	je     f01001df <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001b8:	8b 0d 24 d1 17 f0    	mov    0xf017d124,%ecx
f01001be:	8d 51 01             	lea    0x1(%ecx),%edx
f01001c1:	89 15 24 d1 17 f0    	mov    %edx,0xf017d124
f01001c7:	88 81 20 cf 17 f0    	mov    %al,-0xfe830e0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001cd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001d3:	75 0a                	jne    f01001df <cons_intr+0x36>
			cons.wpos = 0;
f01001d5:	c7 05 24 d1 17 f0 00 	movl   $0x0,0xf017d124
f01001dc:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001df:	ff d3                	call   *%ebx
f01001e1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001e4:	75 ce                	jne    f01001b4 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001e6:	83 c4 04             	add    $0x4,%esp
f01001e9:	5b                   	pop    %ebx
f01001ea:	5d                   	pop    %ebp
f01001eb:	c3                   	ret    

f01001ec <kbd_proc_data>:
f01001ec:	ba 64 00 00 00       	mov    $0x64,%edx
f01001f1:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001f2:	a8 01                	test   $0x1,%al
f01001f4:	0f 84 f0 00 00 00    	je     f01002ea <kbd_proc_data+0xfe>
f01001fa:	ba 60 00 00 00       	mov    $0x60,%edx
f01001ff:	ec                   	in     (%dx),%al
f0100200:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100202:	3c e0                	cmp    $0xe0,%al
f0100204:	75 0d                	jne    f0100213 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f0100206:	83 0d 00 cf 17 f0 40 	orl    $0x40,0xf017cf00
		return 0;
f010020d:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100212:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100213:	55                   	push   %ebp
f0100214:	89 e5                	mov    %esp,%ebp
f0100216:	53                   	push   %ebx
f0100217:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010021a:	84 c0                	test   %al,%al
f010021c:	79 36                	jns    f0100254 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010021e:	8b 0d 00 cf 17 f0    	mov    0xf017cf00,%ecx
f0100224:	89 cb                	mov    %ecx,%ebx
f0100226:	83 e3 40             	and    $0x40,%ebx
f0100229:	83 e0 7f             	and    $0x7f,%eax
f010022c:	85 db                	test   %ebx,%ebx
f010022e:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100231:	0f b6 d2             	movzbl %dl,%edx
f0100234:	0f b6 82 c0 4c 10 f0 	movzbl -0xfefb340(%edx),%eax
f010023b:	83 c8 40             	or     $0x40,%eax
f010023e:	0f b6 c0             	movzbl %al,%eax
f0100241:	f7 d0                	not    %eax
f0100243:	21 c8                	and    %ecx,%eax
f0100245:	a3 00 cf 17 f0       	mov    %eax,0xf017cf00
		return 0;
f010024a:	b8 00 00 00 00       	mov    $0x0,%eax
f010024f:	e9 9e 00 00 00       	jmp    f01002f2 <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100254:	8b 0d 00 cf 17 f0    	mov    0xf017cf00,%ecx
f010025a:	f6 c1 40             	test   $0x40,%cl
f010025d:	74 0e                	je     f010026d <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010025f:	83 c8 80             	or     $0xffffff80,%eax
f0100262:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100264:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100267:	89 0d 00 cf 17 f0    	mov    %ecx,0xf017cf00
	}

	shift |= shiftcode[data];
f010026d:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100270:	0f b6 82 c0 4c 10 f0 	movzbl -0xfefb340(%edx),%eax
f0100277:	0b 05 00 cf 17 f0    	or     0xf017cf00,%eax
f010027d:	0f b6 8a c0 4b 10 f0 	movzbl -0xfefb440(%edx),%ecx
f0100284:	31 c8                	xor    %ecx,%eax
f0100286:	a3 00 cf 17 f0       	mov    %eax,0xf017cf00

	c = charcode[shift & (CTL | SHIFT)][data];
f010028b:	89 c1                	mov    %eax,%ecx
f010028d:	83 e1 03             	and    $0x3,%ecx
f0100290:	8b 0c 8d a0 4b 10 f0 	mov    -0xfefb460(,%ecx,4),%ecx
f0100297:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010029b:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010029e:	a8 08                	test   $0x8,%al
f01002a0:	74 1b                	je     f01002bd <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f01002a2:	89 da                	mov    %ebx,%edx
f01002a4:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002a7:	83 f9 19             	cmp    $0x19,%ecx
f01002aa:	77 05                	ja     f01002b1 <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01002ac:	83 eb 20             	sub    $0x20,%ebx
f01002af:	eb 0c                	jmp    f01002bd <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01002b1:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002b4:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002b7:	83 fa 19             	cmp    $0x19,%edx
f01002ba:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002bd:	f7 d0                	not    %eax
f01002bf:	a8 06                	test   $0x6,%al
f01002c1:	75 2d                	jne    f01002f0 <kbd_proc_data+0x104>
f01002c3:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002c9:	75 25                	jne    f01002f0 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01002cb:	83 ec 0c             	sub    $0xc,%esp
f01002ce:	68 64 4b 10 f0       	push   $0xf0104b64
f01002d3:	e8 28 30 00 00       	call   f0103300 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d8:	ba 92 00 00 00       	mov    $0x92,%edx
f01002dd:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e2:	ee                   	out    %al,(%dx)
f01002e3:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002e6:	89 d8                	mov    %ebx,%eax
f01002e8:	eb 08                	jmp    f01002f2 <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ef:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002f0:	89 d8                	mov    %ebx,%eax
}
f01002f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002f5:	c9                   	leave  
f01002f6:	c3                   	ret    

f01002f7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002f7:	55                   	push   %ebp
f01002f8:	89 e5                	mov    %esp,%ebp
f01002fa:	57                   	push   %edi
f01002fb:	56                   	push   %esi
f01002fc:	53                   	push   %ebx
f01002fd:	83 ec 1c             	sub    $0x1c,%esp
f0100300:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100302:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100307:	be fd 03 00 00       	mov    $0x3fd,%esi
f010030c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100311:	eb 09                	jmp    f010031c <cons_putc+0x25>
f0100313:	89 ca                	mov    %ecx,%edx
f0100315:	ec                   	in     (%dx),%al
f0100316:	ec                   	in     (%dx),%al
f0100317:	ec                   	in     (%dx),%al
f0100318:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100319:	83 c3 01             	add    $0x1,%ebx
f010031c:	89 f2                	mov    %esi,%edx
f010031e:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010031f:	a8 20                	test   $0x20,%al
f0100321:	75 08                	jne    f010032b <cons_putc+0x34>
f0100323:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100329:	7e e8                	jle    f0100313 <cons_putc+0x1c>
f010032b:	89 f8                	mov    %edi,%eax
f010032d:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100330:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100335:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100336:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010033b:	be 79 03 00 00       	mov    $0x379,%esi
f0100340:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100345:	eb 09                	jmp    f0100350 <cons_putc+0x59>
f0100347:	89 ca                	mov    %ecx,%edx
f0100349:	ec                   	in     (%dx),%al
f010034a:	ec                   	in     (%dx),%al
f010034b:	ec                   	in     (%dx),%al
f010034c:	ec                   	in     (%dx),%al
f010034d:	83 c3 01             	add    $0x1,%ebx
f0100350:	89 f2                	mov    %esi,%edx
f0100352:	ec                   	in     (%dx),%al
f0100353:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100359:	7f 04                	jg     f010035f <cons_putc+0x68>
f010035b:	84 c0                	test   %al,%al
f010035d:	79 e8                	jns    f0100347 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100364:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100368:	ee                   	out    %al,(%dx)
f0100369:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010036e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100373:	ee                   	out    %al,(%dx)
f0100374:	b8 08 00 00 00       	mov    $0x8,%eax
f0100379:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF)) {
f010037a:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100380:	75 22                	jne    f01003a4 <cons_putc+0xad>
    	char ch = c & 0xFF;
    		if (ch == 'o' ) {
f0100382:	89 f8                	mov    %edi,%eax
f0100384:	3c 6f                	cmp    $0x6f,%al
f0100386:	75 08                	jne    f0100390 <cons_putc+0x99>
        	c |= 0x0100;
f0100388:	81 cf 00 01 00 00    	or     $0x100,%edi
f010038e:	eb 14                	jmp    f01003a4 <cons_putc+0xad>
    		} else if (ch == 's' ) {
        	c |= 0x0200;
f0100390:	89 f8                	mov    %edi,%eax
f0100392:	80 cc 02             	or     $0x2,%ah
f0100395:	89 fa                	mov    %edi,%edx
f0100397:	80 ce 07             	or     $0x7,%dh
f010039a:	89 fb                	mov    %edi,%ebx
f010039c:	80 fb 73             	cmp    $0x73,%bl
f010039f:	0f 45 c2             	cmovne %edx,%eax
f01003a2:	89 c7                	mov    %eax,%edi
        	c |= 0x0700;
    		}
}


	switch (c & 0xff) {
f01003a4:	89 f8                	mov    %edi,%eax
f01003a6:	0f b6 c0             	movzbl %al,%eax
f01003a9:	83 f8 09             	cmp    $0x9,%eax
f01003ac:	74 74                	je     f0100422 <cons_putc+0x12b>
f01003ae:	83 f8 09             	cmp    $0x9,%eax
f01003b1:	7f 0a                	jg     f01003bd <cons_putc+0xc6>
f01003b3:	83 f8 08             	cmp    $0x8,%eax
f01003b6:	74 14                	je     f01003cc <cons_putc+0xd5>
f01003b8:	e9 99 00 00 00       	jmp    f0100456 <cons_putc+0x15f>
f01003bd:	83 f8 0a             	cmp    $0xa,%eax
f01003c0:	74 3a                	je     f01003fc <cons_putc+0x105>
f01003c2:	83 f8 0d             	cmp    $0xd,%eax
f01003c5:	74 3d                	je     f0100404 <cons_putc+0x10d>
f01003c7:	e9 8a 00 00 00       	jmp    f0100456 <cons_putc+0x15f>
	case '\b':
		if (crt_pos > 0) {
f01003cc:	0f b7 05 28 d1 17 f0 	movzwl 0xf017d128,%eax
f01003d3:	66 85 c0             	test   %ax,%ax
f01003d6:	0f 84 e6 00 00 00    	je     f01004c2 <cons_putc+0x1cb>
			crt_pos--;
f01003dc:	83 e8 01             	sub    $0x1,%eax
f01003df:	66 a3 28 d1 17 f0    	mov    %ax,0xf017d128
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003e5:	0f b7 c0             	movzwl %ax,%eax
f01003e8:	66 81 e7 00 ff       	and    $0xff00,%di
f01003ed:	83 cf 20             	or     $0x20,%edi
f01003f0:	8b 15 2c d1 17 f0    	mov    0xf017d12c,%edx
f01003f6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003fa:	eb 78                	jmp    f0100474 <cons_putc+0x17d>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003fc:	66 83 05 28 d1 17 f0 	addw   $0x50,0xf017d128
f0100403:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100404:	0f b7 05 28 d1 17 f0 	movzwl 0xf017d128,%eax
f010040b:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100411:	c1 e8 16             	shr    $0x16,%eax
f0100414:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100417:	c1 e0 04             	shl    $0x4,%eax
f010041a:	66 a3 28 d1 17 f0    	mov    %ax,0xf017d128
f0100420:	eb 52                	jmp    f0100474 <cons_putc+0x17d>
		break;
	case '\t':
		cons_putc(' ');
f0100422:	b8 20 00 00 00       	mov    $0x20,%eax
f0100427:	e8 cb fe ff ff       	call   f01002f7 <cons_putc>
		cons_putc(' ');
f010042c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100431:	e8 c1 fe ff ff       	call   f01002f7 <cons_putc>
		cons_putc(' ');
f0100436:	b8 20 00 00 00       	mov    $0x20,%eax
f010043b:	e8 b7 fe ff ff       	call   f01002f7 <cons_putc>
		cons_putc(' ');
f0100440:	b8 20 00 00 00       	mov    $0x20,%eax
f0100445:	e8 ad fe ff ff       	call   f01002f7 <cons_putc>
		cons_putc(' ');
f010044a:	b8 20 00 00 00       	mov    $0x20,%eax
f010044f:	e8 a3 fe ff ff       	call   f01002f7 <cons_putc>
f0100454:	eb 1e                	jmp    f0100474 <cons_putc+0x17d>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100456:	0f b7 05 28 d1 17 f0 	movzwl 0xf017d128,%eax
f010045d:	8d 50 01             	lea    0x1(%eax),%edx
f0100460:	66 89 15 28 d1 17 f0 	mov    %dx,0xf017d128
f0100467:	0f b7 c0             	movzwl %ax,%eax
f010046a:	8b 15 2c d1 17 f0    	mov    0xf017d12c,%edx
f0100470:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100474:	66 81 3d 28 d1 17 f0 	cmpw   $0x7cf,0xf017d128
f010047b:	cf 07 
f010047d:	76 43                	jbe    f01004c2 <cons_putc+0x1cb>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010047f:	a1 2c d1 17 f0       	mov    0xf017d12c,%eax
f0100484:	83 ec 04             	sub    $0x4,%esp
f0100487:	68 00 0f 00 00       	push   $0xf00
f010048c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100492:	52                   	push   %edx
f0100493:	50                   	push   %eax
f0100494:	e8 fe 41 00 00       	call   f0104697 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100499:	8b 15 2c d1 17 f0    	mov    0xf017d12c,%edx
f010049f:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004a5:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004ab:	83 c4 10             	add    $0x10,%esp
f01004ae:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004b3:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004b6:	39 d0                	cmp    %edx,%eax
f01004b8:	75 f4                	jne    f01004ae <cons_putc+0x1b7>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004ba:	66 83 2d 28 d1 17 f0 	subw   $0x50,0xf017d128
f01004c1:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004c2:	8b 0d 30 d1 17 f0    	mov    0xf017d130,%ecx
f01004c8:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004cd:	89 ca                	mov    %ecx,%edx
f01004cf:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004d0:	0f b7 1d 28 d1 17 f0 	movzwl 0xf017d128,%ebx
f01004d7:	8d 71 01             	lea    0x1(%ecx),%esi
f01004da:	89 d8                	mov    %ebx,%eax
f01004dc:	66 c1 e8 08          	shr    $0x8,%ax
f01004e0:	89 f2                	mov    %esi,%edx
f01004e2:	ee                   	out    %al,(%dx)
f01004e3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004e8:	89 ca                	mov    %ecx,%edx
f01004ea:	ee                   	out    %al,(%dx)
f01004eb:	89 d8                	mov    %ebx,%eax
f01004ed:	89 f2                	mov    %esi,%edx
f01004ef:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004f3:	5b                   	pop    %ebx
f01004f4:	5e                   	pop    %esi
f01004f5:	5f                   	pop    %edi
f01004f6:	5d                   	pop    %ebp
f01004f7:	c3                   	ret    

f01004f8 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004f8:	80 3d 34 d1 17 f0 00 	cmpb   $0x0,0xf017d134
f01004ff:	74 11                	je     f0100512 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100501:	55                   	push   %ebp
f0100502:	89 e5                	mov    %esp,%ebp
f0100504:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100507:	b8 8a 01 10 f0       	mov    $0xf010018a,%eax
f010050c:	e8 98 fc ff ff       	call   f01001a9 <cons_intr>
}
f0100511:	c9                   	leave  
f0100512:	f3 c3                	repz ret 

f0100514 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100514:	55                   	push   %ebp
f0100515:	89 e5                	mov    %esp,%ebp
f0100517:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010051a:	b8 ec 01 10 f0       	mov    $0xf01001ec,%eax
f010051f:	e8 85 fc ff ff       	call   f01001a9 <cons_intr>
}
f0100524:	c9                   	leave  
f0100525:	c3                   	ret    

f0100526 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100526:	55                   	push   %ebp
f0100527:	89 e5                	mov    %esp,%ebp
f0100529:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010052c:	e8 c7 ff ff ff       	call   f01004f8 <serial_intr>
	kbd_intr();
f0100531:	e8 de ff ff ff       	call   f0100514 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100536:	a1 20 d1 17 f0       	mov    0xf017d120,%eax
f010053b:	3b 05 24 d1 17 f0    	cmp    0xf017d124,%eax
f0100541:	74 26                	je     f0100569 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100543:	8d 50 01             	lea    0x1(%eax),%edx
f0100546:	89 15 20 d1 17 f0    	mov    %edx,0xf017d120
f010054c:	0f b6 88 20 cf 17 f0 	movzbl -0xfe830e0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100553:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100555:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010055b:	75 11                	jne    f010056e <cons_getc+0x48>
			cons.rpos = 0;
f010055d:	c7 05 20 d1 17 f0 00 	movl   $0x0,0xf017d120
f0100564:	00 00 00 
f0100567:	eb 05                	jmp    f010056e <cons_getc+0x48>
		return c;
	}
	return 0;
f0100569:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010056e:	c9                   	leave  
f010056f:	c3                   	ret    

f0100570 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100570:	55                   	push   %ebp
f0100571:	89 e5                	mov    %esp,%ebp
f0100573:	57                   	push   %edi
f0100574:	56                   	push   %esi
f0100575:	53                   	push   %ebx
f0100576:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100579:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100580:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100587:	5a a5 
	if (*cp != 0xA55A) {
f0100589:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100590:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100594:	74 11                	je     f01005a7 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100596:	c7 05 30 d1 17 f0 b4 	movl   $0x3b4,0xf017d130
f010059d:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005a0:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01005a5:	eb 16                	jmp    f01005bd <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01005a7:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005ae:	c7 05 30 d1 17 f0 d4 	movl   $0x3d4,0xf017d130
f01005b5:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005b8:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005bd:	8b 3d 30 d1 17 f0    	mov    0xf017d130,%edi
f01005c3:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005c8:	89 fa                	mov    %edi,%edx
f01005ca:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005cb:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ce:	89 da                	mov    %ebx,%edx
f01005d0:	ec                   	in     (%dx),%al
f01005d1:	0f b6 c8             	movzbl %al,%ecx
f01005d4:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005d7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005dc:	89 fa                	mov    %edi,%edx
f01005de:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005df:	89 da                	mov    %ebx,%edx
f01005e1:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005e2:	89 35 2c d1 17 f0    	mov    %esi,0xf017d12c
	crt_pos = pos;
f01005e8:	0f b6 c0             	movzbl %al,%eax
f01005eb:	09 c8                	or     %ecx,%eax
f01005ed:	66 a3 28 d1 17 f0    	mov    %ax,0xf017d128
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005f3:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01005fd:	89 f2                	mov    %esi,%edx
f01005ff:	ee                   	out    %al,(%dx)
f0100600:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100605:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010060a:	ee                   	out    %al,(%dx)
f010060b:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100610:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100615:	89 da                	mov    %ebx,%edx
f0100617:	ee                   	out    %al,(%dx)
f0100618:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010061d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100622:	ee                   	out    %al,(%dx)
f0100623:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100628:	b8 03 00 00 00       	mov    $0x3,%eax
f010062d:	ee                   	out    %al,(%dx)
f010062e:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100633:	b8 00 00 00 00       	mov    $0x0,%eax
f0100638:	ee                   	out    %al,(%dx)
f0100639:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010063e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100643:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100644:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100649:	ec                   	in     (%dx),%al
f010064a:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010064c:	3c ff                	cmp    $0xff,%al
f010064e:	0f 95 05 34 d1 17 f0 	setne  0xf017d134
f0100655:	89 f2                	mov    %esi,%edx
f0100657:	ec                   	in     (%dx),%al
f0100658:	89 da                	mov    %ebx,%edx
f010065a:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010065b:	80 f9 ff             	cmp    $0xff,%cl
f010065e:	75 10                	jne    f0100670 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100660:	83 ec 0c             	sub    $0xc,%esp
f0100663:	68 70 4b 10 f0       	push   $0xf0104b70
f0100668:	e8 93 2c 00 00       	call   f0103300 <cprintf>
f010066d:	83 c4 10             	add    $0x10,%esp
}
f0100670:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100673:	5b                   	pop    %ebx
f0100674:	5e                   	pop    %esi
f0100675:	5f                   	pop    %edi
f0100676:	5d                   	pop    %ebp
f0100677:	c3                   	ret    

f0100678 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100678:	55                   	push   %ebp
f0100679:	89 e5                	mov    %esp,%ebp
f010067b:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010067e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100681:	e8 71 fc ff ff       	call   f01002f7 <cons_putc>
}
f0100686:	c9                   	leave  
f0100687:	c3                   	ret    

f0100688 <getchar>:

int
getchar(void)
{
f0100688:	55                   	push   %ebp
f0100689:	89 e5                	mov    %esp,%ebp
f010068b:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010068e:	e8 93 fe ff ff       	call   f0100526 <cons_getc>
f0100693:	85 c0                	test   %eax,%eax
f0100695:	74 f7                	je     f010068e <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100697:	c9                   	leave  
f0100698:	c3                   	ret    

f0100699 <iscons>:

int
iscons(int fdnum)
{
f0100699:	55                   	push   %ebp
f010069a:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010069c:	b8 01 00 00 00       	mov    $0x1,%eax
f01006a1:	5d                   	pop    %ebp
f01006a2:	c3                   	ret    

f01006a3 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006a3:	55                   	push   %ebp
f01006a4:	89 e5                	mov    %esp,%ebp
f01006a6:	56                   	push   %esi
f01006a7:	53                   	push   %ebx
f01006a8:	bb 84 51 10 f0       	mov    $0xf0105184,%ebx
f01006ad:	be d8 51 10 f0       	mov    $0xf01051d8,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006b2:	83 ec 04             	sub    $0x4,%esp
f01006b5:	ff 33                	pushl  (%ebx)
f01006b7:	ff 73 fc             	pushl  -0x4(%ebx)
f01006ba:	68 c0 4d 10 f0       	push   $0xf0104dc0
f01006bf:	e8 3c 2c 00 00       	call   f0103300 <cprintf>
f01006c4:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01006c7:	83 c4 10             	add    $0x10,%esp
f01006ca:	39 f3                	cmp    %esi,%ebx
f01006cc:	75 e4                	jne    f01006b2 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01006ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01006d6:	5b                   	pop    %ebx
f01006d7:	5e                   	pop    %esi
f01006d8:	5d                   	pop    %ebp
f01006d9:	c3                   	ret    

f01006da <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006da:	55                   	push   %ebp
f01006db:	89 e5                	mov    %esp,%ebp
f01006dd:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006e0:	68 c9 4d 10 f0       	push   $0xf0104dc9
f01006e5:	e8 16 2c 00 00       	call   f0103300 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006ea:	83 c4 08             	add    $0x8,%esp
f01006ed:	68 0c 00 10 00       	push   $0x10000c
f01006f2:	68 70 4f 10 f0       	push   $0xf0104f70
f01006f7:	e8 04 2c 00 00       	call   f0103300 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006fc:	83 c4 0c             	add    $0xc,%esp
f01006ff:	68 0c 00 10 00       	push   $0x10000c
f0100704:	68 0c 00 10 f0       	push   $0xf010000c
f0100709:	68 98 4f 10 f0       	push   $0xf0104f98
f010070e:	e8 ed 2b 00 00       	call   f0103300 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100713:	83 c4 0c             	add    $0xc,%esp
f0100716:	68 d1 4a 10 00       	push   $0x104ad1
f010071b:	68 d1 4a 10 f0       	push   $0xf0104ad1
f0100720:	68 bc 4f 10 f0       	push   $0xf0104fbc
f0100725:	e8 d6 2b 00 00       	call   f0103300 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010072a:	83 c4 0c             	add    $0xc,%esp
f010072d:	68 ee ce 17 00       	push   $0x17ceee
f0100732:	68 ee ce 17 f0       	push   $0xf017ceee
f0100737:	68 e0 4f 10 f0       	push   $0xf0104fe0
f010073c:	e8 bf 2b 00 00       	call   f0103300 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100741:	83 c4 0c             	add    $0xc,%esp
f0100744:	68 14 de 17 00       	push   $0x17de14
f0100749:	68 14 de 17 f0       	push   $0xf017de14
f010074e:	68 04 50 10 f0       	push   $0xf0105004
f0100753:	e8 a8 2b 00 00       	call   f0103300 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100758:	b8 13 e2 17 f0       	mov    $0xf017e213,%eax
f010075d:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100762:	83 c4 08             	add    $0x8,%esp
f0100765:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010076a:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100770:	85 c0                	test   %eax,%eax
f0100772:	0f 48 c2             	cmovs  %edx,%eax
f0100775:	c1 f8 0a             	sar    $0xa,%eax
f0100778:	50                   	push   %eax
f0100779:	68 28 50 10 f0       	push   $0xf0105028
f010077e:	e8 7d 2b 00 00       	call   f0103300 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100783:	b8 00 00 00 00       	mov    $0x0,%eax
f0100788:	c9                   	leave  
f0100789:	c3                   	ret    

f010078a <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010078a:	55                   	push   %ebp
f010078b:	89 e5                	mov    %esp,%ebp
f010078d:	57                   	push   %edi
f010078e:	56                   	push   %esi
f010078f:	53                   	push   %ebx
f0100790:	83 ec 18             	sub    $0x18,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100793:	89 ee                	mov    %ebp,%esi
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
f0100795:	68 e2 4d 10 f0       	push   $0xf0104de2
f010079a:	e8 61 2b 00 00       	call   f0103300 <cprintf>
	while (ebp) {
f010079f:	83 c4 10             	add    $0x10,%esp
f01007a2:	eb 45                	jmp    f01007e9 <mon_backtrace+0x5f>
		cprintf("ebp %x  eip %x  args", ebp, ebp[1]);
f01007a4:	83 ec 04             	sub    $0x4,%esp
f01007a7:	ff 76 04             	pushl  0x4(%esi)
f01007aa:	56                   	push   %esi
f01007ab:	68 f4 4d 10 f0       	push   $0xf0104df4
f01007b0:	e8 4b 2b 00 00       	call   f0103300 <cprintf>
f01007b5:	8d 5e 08             	lea    0x8(%esi),%ebx
f01007b8:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01007bb:	83 c4 10             	add    $0x10,%esp
		int i;
		for (i = 2; i <= 6; ++i)
			cprintf(" %08.x", ebp[i]);
f01007be:	83 ec 08             	sub    $0x8,%esp
f01007c1:	ff 33                	pushl  (%ebx)
f01007c3:	68 09 4e 10 f0       	push   $0xf0104e09
f01007c8:	e8 33 2b 00 00       	call   f0103300 <cprintf>
f01007cd:	83 c3 04             	add    $0x4,%ebx
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
		cprintf("ebp %x  eip %x  args", ebp, ebp[1]);
		int i;
		for (i = 2; i <= 6; ++i)
f01007d0:	83 c4 10             	add    $0x10,%esp
f01007d3:	39 fb                	cmp    %edi,%ebx
f01007d5:	75 e7                	jne    f01007be <mon_backtrace+0x34>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
f01007d7:	83 ec 0c             	sub    $0xc,%esp
f01007da:	68 1a 55 10 f0       	push   $0xf010551a
f01007df:	e8 1c 2b 00 00       	call   f0103300 <cprintf>
		ebp = (uint32_t*) *ebp;
f01007e4:	8b 36                	mov    (%esi),%esi
f01007e6:	83 c4 10             	add    $0x10,%esp
int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f01007e9:	85 f6                	test   %esi,%esi
f01007eb:	75 b7                	jne    f01007a4 <mon_backtrace+0x1a>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
		ebp = (uint32_t*) *ebp;
	}
	return 0;
}
f01007ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007f5:	5b                   	pop    %ebx
f01007f6:	5e                   	pop    %esi
f01007f7:	5f                   	pop    %edi
f01007f8:	5d                   	pop    %ebp
f01007f9:	c3                   	ret    

f01007fa <csa_backtrace>:

int
csa_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01007fa:	55                   	push   %ebp
f01007fb:	89 e5                	mov    %esp,%ebp
f01007fd:	57                   	push   %edi
f01007fe:	56                   	push   %esi
f01007ff:	53                   	push   %ebx
f0100800:	83 ec 48             	sub    $0x48,%esp
f0100803:	89 ee                	mov    %ebp,%esi
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
f0100805:	68 e2 4d 10 f0       	push   $0xf0104de2
f010080a:	e8 f1 2a 00 00       	call   f0103300 <cprintf>
	while (ebp) {
f010080f:	83 c4 10             	add    $0x10,%esp
f0100812:	eb 78                	jmp    f010088c <csa_backtrace+0x92>
		uint32_t eip = ebp[1];
f0100814:	8b 46 04             	mov    0x4(%esi),%eax
f0100817:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		cprintf("ebp %x  eip %x  args", ebp, eip);
f010081a:	83 ec 04             	sub    $0x4,%esp
f010081d:	50                   	push   %eax
f010081e:	56                   	push   %esi
f010081f:	68 f4 4d 10 f0       	push   $0xf0104df4
f0100824:	e8 d7 2a 00 00       	call   f0103300 <cprintf>
f0100829:	8d 5e 08             	lea    0x8(%esi),%ebx
f010082c:	8d 7e 1c             	lea    0x1c(%esi),%edi
f010082f:	83 c4 10             	add    $0x10,%esp
		int i;
		for (i = 2; i <= 6; ++i)
			cprintf(" %08.x", ebp[i]);
f0100832:	83 ec 08             	sub    $0x8,%esp
f0100835:	ff 33                	pushl  (%ebx)
f0100837:	68 09 4e 10 f0       	push   $0xf0104e09
f010083c:	e8 bf 2a 00 00       	call   f0103300 <cprintf>
f0100841:	83 c3 04             	add    $0x4,%ebx
	cprintf("Stack backtrace:\n");
	while (ebp) {
		uint32_t eip = ebp[1];
		cprintf("ebp %x  eip %x  args", ebp, eip);
		int i;
		for (i = 2; i <= 6; ++i)
f0100844:	83 c4 10             	add    $0x10,%esp
f0100847:	39 fb                	cmp    %edi,%ebx
f0100849:	75 e7                	jne    f0100832 <csa_backtrace+0x38>
			cprintf(" %08.x", ebp[i]);
		cprintf("\n");
f010084b:	83 ec 0c             	sub    $0xc,%esp
f010084e:	68 1a 55 10 f0       	push   $0xf010551a
f0100853:	e8 a8 2a 00 00       	call   f0103300 <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f0100858:	83 c4 08             	add    $0x8,%esp
f010085b:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010085e:	50                   	push   %eax
f010085f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100862:	57                   	push   %edi
f0100863:	e8 63 33 00 00       	call   f0103bcb <debuginfo_eip>
		cprintf("\t%s:%d: %.*s+%d\n", 
f0100868:	83 c4 08             	add    $0x8,%esp
f010086b:	89 f8                	mov    %edi,%eax
f010086d:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100870:	50                   	push   %eax
f0100871:	ff 75 d8             	pushl  -0x28(%ebp)
f0100874:	ff 75 dc             	pushl  -0x24(%ebp)
f0100877:	ff 75 d4             	pushl  -0x2c(%ebp)
f010087a:	ff 75 d0             	pushl  -0x30(%ebp)
f010087d:	68 10 4e 10 f0       	push   $0xf0104e10
f0100882:	e8 79 2a 00 00       	call   f0103300 <cprintf>
			info.eip_file, info.eip_line,
			info.eip_fn_namelen, info.eip_fn_name,
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
f0100887:	8b 36                	mov    (%esi),%esi
f0100889:	83 c4 20             	add    $0x20,%esp
int
csa_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t* ebp = (uint32_t*) read_ebp();
	cprintf("Stack backtrace:\n");
	while (ebp) {
f010088c:	85 f6                	test   %esi,%esi
f010088e:	75 84                	jne    f0100814 <csa_backtrace+0x1a>
			eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
		ebp = (uint32_t*) *ebp;
	}
	return 0;
}
f0100890:	b8 00 00 00 00       	mov    $0x0,%eax
f0100895:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100898:	5b                   	pop    %ebx
f0100899:	5e                   	pop    %esi
f010089a:	5f                   	pop    %edi
f010089b:	5d                   	pop    %ebp
f010089c:	c3                   	ret    

f010089d <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010089d:	55                   	push   %ebp
f010089e:	89 e5                	mov    %esp,%ebp
f01008a0:	57                   	push   %edi
f01008a1:	56                   	push   %esi
f01008a2:	53                   	push   %ebx
f01008a3:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008a6:	68 54 50 10 f0       	push   $0xf0105054
f01008ab:	e8 50 2a 00 00       	call   f0103300 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008b0:	c7 04 24 78 50 10 f0 	movl   $0xf0105078,(%esp)
f01008b7:	e8 44 2a 00 00       	call   f0103300 <cprintf>
	cprintf("%m%s\n%m%s\n%m%s\n", 
f01008bc:	83 c4 0c             	add    $0xc,%esp
f01008bf:	68 21 4e 10 f0       	push   $0xf0104e21
f01008c4:	68 00 04 00 00       	push   $0x400
f01008c9:	68 25 4e 10 f0       	push   $0xf0104e25
f01008ce:	68 00 02 00 00       	push   $0x200
f01008d3:	68 2b 4e 10 f0       	push   $0xf0104e2b
f01008d8:	68 00 01 00 00       	push   $0x100
f01008dd:	68 30 4e 10 f0       	push   $0xf0104e30
f01008e2:	e8 19 2a 00 00       	call   f0103300 <cprintf>
		0x0100, "blue", 0x0200, "green", 0x0400, "red");

	if (tf != NULL)
f01008e7:	83 c4 20             	add    $0x20,%esp
f01008ea:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01008ee:	74 0e                	je     f01008fe <monitor+0x61>
		print_trapframe(tf);
f01008f0:	83 ec 0c             	sub    $0xc,%esp
f01008f3:	ff 75 08             	pushl  0x8(%ebp)
f01008f6:	e8 63 2d 00 00       	call   f010365e <print_trapframe>
f01008fb:	83 c4 10             	add    $0x10,%esp
	// asm volatile("or $0x0100, %%eax\n":::);
	// asm volatile("\tpushl %%eax\n":::);
	// asm volatile("\tpopf\n":::);
	// asm volatile("\tjmp *%0\n":: "g" (&tf->tf_eip): "memory");
	while (1) {
		buf = readline("K> ");
f01008fe:	83 ec 0c             	sub    $0xc,%esp
f0100901:	68 40 4e 10 f0       	push   $0xf0104e40
f0100906:	e8 e8 3a 00 00       	call   f01043f3 <readline>
f010090b:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010090d:	83 c4 10             	add    $0x10,%esp
f0100910:	85 c0                	test   %eax,%eax
f0100912:	74 ea                	je     f01008fe <monitor+0x61>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100914:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010091b:	be 00 00 00 00       	mov    $0x0,%esi
f0100920:	eb 0a                	jmp    f010092c <monitor+0x8f>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100922:	c6 03 00             	movb   $0x0,(%ebx)
f0100925:	89 f7                	mov    %esi,%edi
f0100927:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010092a:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010092c:	0f b6 03             	movzbl (%ebx),%eax
f010092f:	84 c0                	test   %al,%al
f0100931:	74 63                	je     f0100996 <monitor+0xf9>
f0100933:	83 ec 08             	sub    $0x8,%esp
f0100936:	0f be c0             	movsbl %al,%eax
f0100939:	50                   	push   %eax
f010093a:	68 44 4e 10 f0       	push   $0xf0104e44
f010093f:	e8 c9 3c 00 00       	call   f010460d <strchr>
f0100944:	83 c4 10             	add    $0x10,%esp
f0100947:	85 c0                	test   %eax,%eax
f0100949:	75 d7                	jne    f0100922 <monitor+0x85>
			*buf++ = 0;
		if (*buf == 0)
f010094b:	80 3b 00             	cmpb   $0x0,(%ebx)
f010094e:	74 46                	je     f0100996 <monitor+0xf9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100950:	83 fe 0f             	cmp    $0xf,%esi
f0100953:	75 14                	jne    f0100969 <monitor+0xcc>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100955:	83 ec 08             	sub    $0x8,%esp
f0100958:	6a 10                	push   $0x10
f010095a:	68 49 4e 10 f0       	push   $0xf0104e49
f010095f:	e8 9c 29 00 00       	call   f0103300 <cprintf>
f0100964:	83 c4 10             	add    $0x10,%esp
f0100967:	eb 95                	jmp    f01008fe <monitor+0x61>
			return 0;
		}
		argv[argc++] = buf;
f0100969:	8d 7e 01             	lea    0x1(%esi),%edi
f010096c:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100970:	eb 03                	jmp    f0100975 <monitor+0xd8>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100972:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100975:	0f b6 03             	movzbl (%ebx),%eax
f0100978:	84 c0                	test   %al,%al
f010097a:	74 ae                	je     f010092a <monitor+0x8d>
f010097c:	83 ec 08             	sub    $0x8,%esp
f010097f:	0f be c0             	movsbl %al,%eax
f0100982:	50                   	push   %eax
f0100983:	68 44 4e 10 f0       	push   $0xf0104e44
f0100988:	e8 80 3c 00 00       	call   f010460d <strchr>
f010098d:	83 c4 10             	add    $0x10,%esp
f0100990:	85 c0                	test   %eax,%eax
f0100992:	74 de                	je     f0100972 <monitor+0xd5>
f0100994:	eb 94                	jmp    f010092a <monitor+0x8d>
			buf++;
	}
	argv[argc] = 0;
f0100996:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010099d:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010099e:	85 f6                	test   %esi,%esi
f01009a0:	0f 84 58 ff ff ff    	je     f01008fe <monitor+0x61>
f01009a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01009ab:	83 ec 08             	sub    $0x8,%esp
f01009ae:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009b1:	ff 34 85 80 51 10 f0 	pushl  -0xfefae80(,%eax,4)
f01009b8:	ff 75 a8             	pushl  -0x58(%ebp)
f01009bb:	e8 ef 3b 00 00       	call   f01045af <strcmp>
f01009c0:	83 c4 10             	add    $0x10,%esp
f01009c3:	85 c0                	test   %eax,%eax
f01009c5:	75 21                	jne    f01009e8 <monitor+0x14b>
			return commands[i].func(argc, argv, tf);
f01009c7:	83 ec 04             	sub    $0x4,%esp
f01009ca:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01009cd:	ff 75 08             	pushl  0x8(%ebp)
f01009d0:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009d3:	52                   	push   %edx
f01009d4:	56                   	push   %esi
f01009d5:	ff 14 85 88 51 10 f0 	call   *-0xfefae78(,%eax,4)
	// asm volatile("\tpopf\n":::);
	// asm volatile("\tjmp *%0\n":: "g" (&tf->tf_eip): "memory");
	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009dc:	83 c4 10             	add    $0x10,%esp
f01009df:	85 c0                	test   %eax,%eax
f01009e1:	78 25                	js     f0100a08 <monitor+0x16b>
f01009e3:	e9 16 ff ff ff       	jmp    f01008fe <monitor+0x61>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01009e8:	83 c3 01             	add    $0x1,%ebx
f01009eb:	83 fb 07             	cmp    $0x7,%ebx
f01009ee:	75 bb                	jne    f01009ab <monitor+0x10e>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009f0:	83 ec 08             	sub    $0x8,%esp
f01009f3:	ff 75 a8             	pushl  -0x58(%ebp)
f01009f6:	68 66 4e 10 f0       	push   $0xf0104e66
f01009fb:	e8 00 29 00 00       	call   f0103300 <cprintf>
f0100a00:	83 c4 10             	add    $0x10,%esp
f0100a03:	e9 f6 fe ff ff       	jmp    f01008fe <monitor+0x61>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a08:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a0b:	5b                   	pop    %ebx
f0100a0c:	5e                   	pop    %esi
f0100a0d:	5f                   	pop    %edi
f0100a0e:	5d                   	pop    %ebp
f0100a0f:	c3                   	ret    

f0100a10 <xtoi>:

uint32_t xtoi(char* buf) {
f0100a10:	55                   	push   %ebp
f0100a11:	89 e5                	mov    %esp,%ebp
	uint32_t res = 0;
	buf += 2; //0x...
f0100a13:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a16:	8d 50 02             	lea    0x2(%eax),%edx
				break;
	}
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
f0100a19:	b8 00 00 00 00       	mov    $0x0,%eax
	buf += 2; //0x...
	while (*buf) { 
f0100a1e:	eb 17                	jmp    f0100a37 <xtoi+0x27>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
f0100a20:	80 f9 60             	cmp    $0x60,%cl
f0100a23:	7e 05                	jle    f0100a2a <xtoi+0x1a>
f0100a25:	83 e9 27             	sub    $0x27,%ecx
f0100a28:	88 0a                	mov    %cl,(%edx)
f0100a2a:	c1 e0 04             	shl    $0x4,%eax
		res = res*16 + *buf - '0';
f0100a2d:	0f be 0a             	movsbl (%edx),%ecx
f0100a30:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
		++buf;
f0100a34:	83 c2 01             	add    $0x1,%edx
}

uint32_t xtoi(char* buf) {
	uint32_t res = 0;
	buf += 2; //0x...
	while (*buf) { 
f0100a37:	0f b6 0a             	movzbl (%edx),%ecx
f0100a3a:	84 c9                	test   %cl,%cl
f0100a3c:	75 e2                	jne    f0100a20 <xtoi+0x10>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
		res = res*16 + *buf - '0';
		++buf;
	}
	return res;
}
f0100a3e:	5d                   	pop    %ebp
f0100a3f:	c3                   	ret    

f0100a40 <showvm>:
	cprintf("%x after  setm: ", addr);
	pprint(pte);
	return 0;
}

int showvm(int argc, char **argv, struct Trapframe *tf) {
f0100a40:	55                   	push   %ebp
f0100a41:	89 e5                	mov    %esp,%ebp
f0100a43:	57                   	push   %edi
f0100a44:	56                   	push   %esi
f0100a45:	53                   	push   %ebx
f0100a46:	83 ec 0c             	sub    $0xc,%esp
f0100a49:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100a4c:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100a50:	75 12                	jne    f0100a64 <showvm+0x24>
		cprintf("Usage: showvm 0xaddr 0xn\n");
f0100a52:	83 ec 0c             	sub    $0xc,%esp
f0100a55:	68 7c 4e 10 f0       	push   $0xf0104e7c
f0100a5a:	e8 a1 28 00 00       	call   f0103300 <cprintf>
		return 0;
f0100a5f:	83 c4 10             	add    $0x10,%esp
f0100a62:	eb 41                	jmp    f0100aa5 <showvm+0x65>
	}
	void** addr = (void**) xtoi(argv[1]);
f0100a64:	83 ec 0c             	sub    $0xc,%esp
f0100a67:	ff 76 04             	pushl  0x4(%esi)
f0100a6a:	e8 a1 ff ff ff       	call   f0100a10 <xtoi>
f0100a6f:	89 c3                	mov    %eax,%ebx
	uint32_t n = xtoi(argv[2]);
f0100a71:	83 c4 04             	add    $0x4,%esp
f0100a74:	ff 76 08             	pushl  0x8(%esi)
f0100a77:	e8 94 ff ff ff       	call   f0100a10 <xtoi>
f0100a7c:	89 c6                	mov    %eax,%esi
	int i;
	for (i = 0; i < n; ++i)
f0100a7e:	83 c4 10             	add    $0x10,%esp
f0100a81:	bf 00 00 00 00       	mov    $0x0,%edi
f0100a86:	eb 19                	jmp    f0100aa1 <showvm+0x61>
		cprintf("VM at %x is %x\n", addr+i, addr[i]);
f0100a88:	83 ec 04             	sub    $0x4,%esp
f0100a8b:	ff 33                	pushl  (%ebx)
f0100a8d:	53                   	push   %ebx
f0100a8e:	68 96 4e 10 f0       	push   $0xf0104e96
f0100a93:	e8 68 28 00 00       	call   f0103300 <cprintf>
		return 0;
	}
	void** addr = (void**) xtoi(argv[1]);
	uint32_t n = xtoi(argv[2]);
	int i;
	for (i = 0; i < n; ++i)
f0100a98:	83 c7 01             	add    $0x1,%edi
f0100a9b:	83 c3 04             	add    $0x4,%ebx
f0100a9e:	83 c4 10             	add    $0x10,%esp
f0100aa1:	39 f7                	cmp    %esi,%edi
f0100aa3:	75 e3                	jne    f0100a88 <showvm+0x48>
		cprintf("VM at %x is %x\n", addr+i, addr[i]);
	return 0;
}
f0100aa5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aad:	5b                   	pop    %ebx
f0100aae:	5e                   	pop    %esi
f0100aaf:	5f                   	pop    %edi
f0100ab0:	5d                   	pop    %ebp
f0100ab1:	c3                   	ret    

f0100ab2 <pprint>:
		res = res*16 + *buf - '0';
		++buf;
	}
	return res;
}
void pprint(pte_t *pte) {
f0100ab2:	55                   	push   %ebp
f0100ab3:	89 e5                	mov    %esp,%ebp
f0100ab5:	83 ec 08             	sub    $0x8,%esp
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
f0100ab8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100abb:	8b 00                	mov    (%eax),%eax
		++buf;
	}
	return res;
}
void pprint(pte_t *pte) {
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
f0100abd:	89 c2                	mov    %eax,%edx
f0100abf:	83 e2 04             	and    $0x4,%edx
f0100ac2:	52                   	push   %edx
f0100ac3:	89 c2                	mov    %eax,%edx
f0100ac5:	83 e2 02             	and    $0x2,%edx
f0100ac8:	52                   	push   %edx
f0100ac9:	83 e0 01             	and    $0x1,%eax
f0100acc:	50                   	push   %eax
f0100acd:	68 a0 50 10 f0       	push   $0xf01050a0
f0100ad2:	e8 29 28 00 00       	call   f0103300 <cprintf>
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
}
f0100ad7:	83 c4 10             	add    $0x10,%esp
f0100ada:	c9                   	leave  
f0100adb:	c3                   	ret    

f0100adc <showmappings>:
int
showmappings(int argc, char **argv, struct Trapframe *tf)
{
f0100adc:	55                   	push   %ebp
f0100add:	89 e5                	mov    %esp,%ebp
f0100adf:	57                   	push   %edi
f0100ae0:	56                   	push   %esi
f0100ae1:	53                   	push   %ebx
f0100ae2:	83 ec 0c             	sub    $0xc,%esp
f0100ae5:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100ae8:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100aec:	75 15                	jne    f0100b03 <showmappings+0x27>
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
f0100aee:	83 ec 0c             	sub    $0xc,%esp
f0100af1:	68 c4 50 10 f0       	push   $0xf01050c4
f0100af6:	e8 05 28 00 00       	call   f0103300 <cprintf>
		return 0;
f0100afb:	83 c4 10             	add    $0x10,%esp
f0100afe:	e9 9a 00 00 00       	jmp    f0100b9d <showmappings+0xc1>
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
f0100b03:	83 ec 0c             	sub    $0xc,%esp
f0100b06:	ff 76 04             	pushl  0x4(%esi)
f0100b09:	e8 02 ff ff ff       	call   f0100a10 <xtoi>
f0100b0e:	89 c3                	mov    %eax,%ebx
f0100b10:	83 c4 04             	add    $0x4,%esp
f0100b13:	ff 76 08             	pushl  0x8(%esi)
f0100b16:	e8 f5 fe ff ff       	call   f0100a10 <xtoi>
f0100b1b:	89 c7                	mov    %eax,%edi
	cprintf("begin: %x, end: %x\n", begin, end);
f0100b1d:	83 c4 0c             	add    $0xc,%esp
f0100b20:	50                   	push   %eax
f0100b21:	53                   	push   %ebx
f0100b22:	68 a6 4e 10 f0       	push   $0xf0104ea6
f0100b27:	e8 d4 27 00 00       	call   f0103300 <cprintf>
	for (; begin <= end; begin += PGSIZE) {
f0100b2c:	83 c4 10             	add    $0x10,%esp
f0100b2f:	eb 68                	jmp    f0100b99 <showmappings+0xbd>
		pte_t *pte = pgdir_walk(kern_pgdir, (void *) begin, 1);	//create
f0100b31:	83 ec 04             	sub    $0x4,%esp
f0100b34:	6a 01                	push   $0x1
f0100b36:	53                   	push   %ebx
f0100b37:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0100b3d:	e8 4a 06 00 00       	call   f010118c <pgdir_walk>
f0100b42:	89 c6                	mov    %eax,%esi
		if (!pte) panic("boot_map_region panic, out of memory");
f0100b44:	83 c4 10             	add    $0x10,%esp
f0100b47:	85 c0                	test   %eax,%eax
f0100b49:	75 17                	jne    f0100b62 <showmappings+0x86>
f0100b4b:	83 ec 04             	sub    $0x4,%esp
f0100b4e:	68 f4 50 10 f0       	push   $0xf01050f4
f0100b53:	68 cf 00 00 00       	push   $0xcf
f0100b58:	68 ba 4e 10 f0       	push   $0xf0104eba
f0100b5d:	e8 97 f5 ff ff       	call   f01000f9 <_panic>
		if (*pte & PTE_P) {
f0100b62:	f6 00 01             	testb  $0x1,(%eax)
f0100b65:	74 1b                	je     f0100b82 <showmappings+0xa6>
			cprintf("page %x with ", begin);
f0100b67:	83 ec 08             	sub    $0x8,%esp
f0100b6a:	53                   	push   %ebx
f0100b6b:	68 c9 4e 10 f0       	push   $0xf0104ec9
f0100b70:	e8 8b 27 00 00       	call   f0103300 <cprintf>
			pprint(pte);
f0100b75:	89 34 24             	mov    %esi,(%esp)
f0100b78:	e8 35 ff ff ff       	call   f0100ab2 <pprint>
f0100b7d:	83 c4 10             	add    $0x10,%esp
f0100b80:	eb 11                	jmp    f0100b93 <showmappings+0xb7>
		} else cprintf("page not exist: %x\n", begin);
f0100b82:	83 ec 08             	sub    $0x8,%esp
f0100b85:	53                   	push   %ebx
f0100b86:	68 d7 4e 10 f0       	push   $0xf0104ed7
f0100b8b:	e8 70 27 00 00       	call   f0103300 <cprintf>
f0100b90:	83 c4 10             	add    $0x10,%esp
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
		return 0;
	}
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
	cprintf("begin: %x, end: %x\n", begin, end);
	for (; begin <= end; begin += PGSIZE) {
f0100b93:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100b99:	39 fb                	cmp    %edi,%ebx
f0100b9b:	76 94                	jbe    f0100b31 <showmappings+0x55>
			cprintf("page %x with ", begin);
			pprint(pte);
		} else cprintf("page not exist: %x\n", begin);
	}
	return 0;
}
f0100b9d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ba2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ba5:	5b                   	pop    %ebx
f0100ba6:	5e                   	pop    %esi
f0100ba7:	5f                   	pop    %edi
f0100ba8:	5d                   	pop    %ebp
f0100ba9:	c3                   	ret    

f0100baa <setm>:

int setm(int argc, char **argv, struct Trapframe *tf) {
f0100baa:	55                   	push   %ebp
f0100bab:	89 e5                	mov    %esp,%ebp
f0100bad:	57                   	push   %edi
f0100bae:	56                   	push   %esi
f0100baf:	53                   	push   %ebx
f0100bb0:	83 ec 0c             	sub    $0xc,%esp
f0100bb3:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100bb6:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100bba:	75 15                	jne    f0100bd1 <setm+0x27>
		cprintf("Usage: setm 0xaddr [0|1 :clear or set] [P|W|U]\n");
f0100bbc:	83 ec 0c             	sub    $0xc,%esp
f0100bbf:	68 1c 51 10 f0       	push   $0xf010511c
f0100bc4:	e8 37 27 00 00       	call   f0103300 <cprintf>
		return 0;
f0100bc9:	83 c4 10             	add    $0x10,%esp
f0100bcc:	e9 85 00 00 00       	jmp    f0100c56 <setm+0xac>
	}
	uint32_t addr = xtoi(argv[1]);
f0100bd1:	83 ec 0c             	sub    $0xc,%esp
f0100bd4:	ff 76 04             	pushl  0x4(%esi)
f0100bd7:	e8 34 fe ff ff       	call   f0100a10 <xtoi>
f0100bdc:	89 c7                	mov    %eax,%edi
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
f0100bde:	83 c4 0c             	add    $0xc,%esp
f0100be1:	6a 01                	push   $0x1
f0100be3:	50                   	push   %eax
f0100be4:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0100bea:	e8 9d 05 00 00       	call   f010118c <pgdir_walk>
f0100bef:	89 c3                	mov    %eax,%ebx
	cprintf("%x before setm: ", addr);
f0100bf1:	83 c4 08             	add    $0x8,%esp
f0100bf4:	57                   	push   %edi
f0100bf5:	68 eb 4e 10 f0       	push   $0xf0104eeb
f0100bfa:	e8 01 27 00 00       	call   f0103300 <cprintf>
	pprint(pte);
f0100bff:	89 1c 24             	mov    %ebx,(%esp)
f0100c02:	e8 ab fe ff ff       	call   f0100ab2 <pprint>
	uint32_t perm = 0;
	if (argv[3][0] == 'P') perm = PTE_P;
f0100c07:	8b 46 0c             	mov    0xc(%esi),%eax
f0100c0a:	0f b6 10             	movzbl (%eax),%edx
	if (argv[3][0] == 'W') perm = PTE_W;
f0100c0d:	83 c4 10             	add    $0x10,%esp
f0100c10:	b8 02 00 00 00       	mov    $0x2,%eax
f0100c15:	80 fa 57             	cmp    $0x57,%dl
f0100c18:	74 13                	je     f0100c2d <setm+0x83>
	if (argv[3][0] == 'U') perm = PTE_U;
f0100c1a:	b8 04 00 00 00       	mov    $0x4,%eax
f0100c1f:	80 fa 55             	cmp    $0x55,%dl
f0100c22:	74 09                	je     f0100c2d <setm+0x83>
	}
	uint32_t addr = xtoi(argv[1]);
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
	cprintf("%x before setm: ", addr);
	pprint(pte);
	uint32_t perm = 0;
f0100c24:	80 fa 50             	cmp    $0x50,%dl
f0100c27:	0f 94 c0             	sete   %al
f0100c2a:	0f b6 c0             	movzbl %al,%eax
	if (argv[3][0] == 'P') perm = PTE_P;
	if (argv[3][0] == 'W') perm = PTE_W;
	if (argv[3][0] == 'U') perm = PTE_U;
	if (argv[2][0] == '0') 	//clear
f0100c2d:	8b 56 08             	mov    0x8(%esi),%edx
f0100c30:	80 3a 30             	cmpb   $0x30,(%edx)
f0100c33:	75 06                	jne    f0100c3b <setm+0x91>
		*pte = *pte & ~perm;
f0100c35:	f7 d0                	not    %eax
f0100c37:	21 03                	and    %eax,(%ebx)
f0100c39:	eb 02                	jmp    f0100c3d <setm+0x93>
	else 	//set
		*pte = *pte | perm;
f0100c3b:	09 03                	or     %eax,(%ebx)
	cprintf("%x after  setm: ", addr);
f0100c3d:	83 ec 08             	sub    $0x8,%esp
f0100c40:	57                   	push   %edi
f0100c41:	68 fc 4e 10 f0       	push   $0xf0104efc
f0100c46:	e8 b5 26 00 00       	call   f0103300 <cprintf>
	pprint(pte);
f0100c4b:	89 1c 24             	mov    %ebx,(%esp)
f0100c4e:	e8 5f fe ff ff       	call   f0100ab2 <pprint>
	return 0;
f0100c53:	83 c4 10             	add    $0x10,%esp
}
f0100c56:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c5e:	5b                   	pop    %ebx
f0100c5f:	5e                   	pop    %esi
f0100c60:	5f                   	pop    %edi
f0100c61:	5d                   	pop    %ebp
f0100c62:	c3                   	ret    

f0100c63 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100c63:	55                   	push   %ebp
f0100c64:	89 e5                	mov    %esp,%ebp
f0100c66:	53                   	push   %ebx
f0100c67:	83 ec 04             	sub    $0x4,%esp
f0100c6a:	89 c3                	mov    %eax,%ebx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100c6c:	83 3d 38 d1 17 f0 00 	cmpl   $0x0,0xf017d138
f0100c73:	75 0f                	jne    f0100c84 <boot_alloc+0x21>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100c75:	b8 13 ee 17 f0       	mov    $0xf017ee13,%eax
f0100c7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c7f:	a3 38 d1 17 f0       	mov    %eax,0xf017d138
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
f0100c84:	83 ec 08             	sub    $0x8,%esp
f0100c87:	ff 35 38 d1 17 f0    	pushl  0xf017d138
f0100c8d:	68 d4 51 10 f0       	push   $0xf01051d4
f0100c92:	e8 69 26 00 00       	call   f0103300 <cprintf>
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
f0100c97:	89 d8                	mov    %ebx,%eax
f0100c99:	03 05 38 d1 17 f0    	add    0xf017d138,%eax
f0100c9f:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100ca4:	83 c4 08             	add    $0x8,%esp
f0100ca7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100cac:	50                   	push   %eax
f0100cad:	68 ed 51 10 f0       	push   $0xf01051ed
f0100cb2:	e8 49 26 00 00       	call   f0103300 <cprintf>
	if (n != 0) {
f0100cb7:	83 c4 10             	add    $0x10,%esp
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
		return next;
	} else return nextfree;
f0100cba:	a1 38 d1 17 f0       	mov    0xf017d138,%eax
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	cprintf("boot_alloc memory at %x\n", nextfree);
	cprintf("Next memory at %x\n", ROUNDUP((char *) (nextfree+n), PGSIZE));
	if (n != 0) {
f0100cbf:	85 db                	test   %ebx,%ebx
f0100cc1:	74 13                	je     f0100cd6 <boot_alloc+0x73>
		char *next = nextfree;
		nextfree = ROUNDUP((char *) (nextfree+n), PGSIZE);
f0100cc3:	8d 94 18 ff 0f 00 00 	lea    0xfff(%eax,%ebx,1),%edx
f0100cca:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100cd0:	89 15 38 d1 17 f0    	mov    %edx,0xf017d138
		return next;
	} else return nextfree;

	return NULL;
}
f0100cd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100cd9:	c9                   	leave  
f0100cda:	c3                   	ret    

f0100cdb <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100cdb:	89 d1                	mov    %edx,%ecx
f0100cdd:	c1 e9 16             	shr    $0x16,%ecx
f0100ce0:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ce3:	a8 01                	test   $0x1,%al
f0100ce5:	74 52                	je     f0100d39 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ce7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cec:	89 c1                	mov    %eax,%ecx
f0100cee:	c1 e9 0c             	shr    $0xc,%ecx
f0100cf1:	3b 0d 04 de 17 f0    	cmp    0xf017de04,%ecx
f0100cf7:	72 1b                	jb     f0100d14 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100cf9:	55                   	push   %ebp
f0100cfa:	89 e5                	mov    %esp,%ebp
f0100cfc:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cff:	50                   	push   %eax
f0100d00:	68 74 55 10 f0       	push   $0xf0105574
f0100d05:	68 26 03 00 00       	push   $0x326
f0100d0a:	68 00 52 10 f0       	push   $0xf0105200
f0100d0f:	e8 e5 f3 ff ff       	call   f01000f9 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100d14:	c1 ea 0c             	shr    $0xc,%edx
f0100d17:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100d1d:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100d24:	89 c2                	mov    %eax,%edx
f0100d26:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100d29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d2e:	85 d2                	test   %edx,%edx
f0100d30:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100d35:	0f 44 c2             	cmove  %edx,%eax
f0100d38:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100d39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100d3e:	c3                   	ret    

f0100d3f <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100d3f:	55                   	push   %ebp
f0100d40:	89 e5                	mov    %esp,%ebp
f0100d42:	57                   	push   %edi
f0100d43:	56                   	push   %esi
f0100d44:	53                   	push   %ebx
f0100d45:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d48:	84 c0                	test   %al,%al
f0100d4a:	0f 85 81 02 00 00    	jne    f0100fd1 <check_page_free_list+0x292>
f0100d50:	e9 8e 02 00 00       	jmp    f0100fe3 <check_page_free_list+0x2a4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100d55:	83 ec 04             	sub    $0x4,%esp
f0100d58:	68 98 55 10 f0       	push   $0xf0105598
f0100d5d:	68 60 02 00 00       	push   $0x260
f0100d62:	68 00 52 10 f0       	push   $0xf0105200
f0100d67:	e8 8d f3 ff ff       	call   f01000f9 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100d6c:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100d6f:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100d72:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100d75:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100d78:	89 c2                	mov    %eax,%edx
f0100d7a:	2b 15 0c de 17 f0    	sub    0xf017de0c,%edx
f0100d80:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100d86:	0f 95 c2             	setne  %dl
f0100d89:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100d8c:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100d90:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100d92:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d96:	8b 00                	mov    (%eax),%eax
f0100d98:	85 c0                	test   %eax,%eax
f0100d9a:	75 dc                	jne    f0100d78 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100d9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d9f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100da5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100da8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100dab:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100dad:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100db0:	a3 40 d1 17 f0       	mov    %eax,0xf017d140
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100db5:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100dba:	8b 1d 40 d1 17 f0    	mov    0xf017d140,%ebx
f0100dc0:	eb 53                	jmp    f0100e15 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100dc2:	89 d8                	mov    %ebx,%eax
f0100dc4:	2b 05 0c de 17 f0    	sub    0xf017de0c,%eax
f0100dca:	c1 f8 03             	sar    $0x3,%eax
f0100dcd:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100dd0:	89 c2                	mov    %eax,%edx
f0100dd2:	c1 ea 16             	shr    $0x16,%edx
f0100dd5:	39 f2                	cmp    %esi,%edx
f0100dd7:	73 3a                	jae    f0100e13 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dd9:	89 c2                	mov    %eax,%edx
f0100ddb:	c1 ea 0c             	shr    $0xc,%edx
f0100dde:	3b 15 04 de 17 f0    	cmp    0xf017de04,%edx
f0100de4:	72 12                	jb     f0100df8 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100de6:	50                   	push   %eax
f0100de7:	68 74 55 10 f0       	push   $0xf0105574
f0100dec:	6a 56                	push   $0x56
f0100dee:	68 0c 52 10 f0       	push   $0xf010520c
f0100df3:	e8 01 f3 ff ff       	call   f01000f9 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100df8:	83 ec 04             	sub    $0x4,%esp
f0100dfb:	68 80 00 00 00       	push   $0x80
f0100e00:	68 97 00 00 00       	push   $0x97
f0100e05:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e0a:	50                   	push   %eax
f0100e0b:	e8 3a 38 00 00       	call   f010464a <memset>
f0100e10:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e13:	8b 1b                	mov    (%ebx),%ebx
f0100e15:	85 db                	test   %ebx,%ebx
f0100e17:	75 a9                	jne    f0100dc2 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100e19:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e1e:	e8 40 fe ff ff       	call   f0100c63 <boot_alloc>
f0100e23:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e26:	8b 15 40 d1 17 f0    	mov    0xf017d140,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100e2c:	8b 0d 0c de 17 f0    	mov    0xf017de0c,%ecx
		assert(pp < pages + npages);
f0100e32:	a1 04 de 17 f0       	mov    0xf017de04,%eax
f0100e37:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100e3a:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e3d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100e40:	be 00 00 00 00       	mov    $0x0,%esi
f0100e45:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e48:	e9 30 01 00 00       	jmp    f0100f7d <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100e4d:	39 ca                	cmp    %ecx,%edx
f0100e4f:	73 19                	jae    f0100e6a <check_page_free_list+0x12b>
f0100e51:	68 1a 52 10 f0       	push   $0xf010521a
f0100e56:	68 26 52 10 f0       	push   $0xf0105226
f0100e5b:	68 7a 02 00 00       	push   $0x27a
f0100e60:	68 00 52 10 f0       	push   $0xf0105200
f0100e65:	e8 8f f2 ff ff       	call   f01000f9 <_panic>
		assert(pp < pages + npages);
f0100e6a:	39 fa                	cmp    %edi,%edx
f0100e6c:	72 19                	jb     f0100e87 <check_page_free_list+0x148>
f0100e6e:	68 3b 52 10 f0       	push   $0xf010523b
f0100e73:	68 26 52 10 f0       	push   $0xf0105226
f0100e78:	68 7b 02 00 00       	push   $0x27b
f0100e7d:	68 00 52 10 f0       	push   $0xf0105200
f0100e82:	e8 72 f2 ff ff       	call   f01000f9 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100e87:	89 d0                	mov    %edx,%eax
f0100e89:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100e8c:	a8 07                	test   $0x7,%al
f0100e8e:	74 19                	je     f0100ea9 <check_page_free_list+0x16a>
f0100e90:	68 bc 55 10 f0       	push   $0xf01055bc
f0100e95:	68 26 52 10 f0       	push   $0xf0105226
f0100e9a:	68 7c 02 00 00       	push   $0x27c
f0100e9f:	68 00 52 10 f0       	push   $0xf0105200
f0100ea4:	e8 50 f2 ff ff       	call   f01000f9 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ea9:	c1 f8 03             	sar    $0x3,%eax
f0100eac:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100eaf:	85 c0                	test   %eax,%eax
f0100eb1:	75 19                	jne    f0100ecc <check_page_free_list+0x18d>
f0100eb3:	68 4f 52 10 f0       	push   $0xf010524f
f0100eb8:	68 26 52 10 f0       	push   $0xf0105226
f0100ebd:	68 7f 02 00 00       	push   $0x27f
f0100ec2:	68 00 52 10 f0       	push   $0xf0105200
f0100ec7:	e8 2d f2 ff ff       	call   f01000f9 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ecc:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ed1:	75 19                	jne    f0100eec <check_page_free_list+0x1ad>
f0100ed3:	68 60 52 10 f0       	push   $0xf0105260
f0100ed8:	68 26 52 10 f0       	push   $0xf0105226
f0100edd:	68 80 02 00 00       	push   $0x280
f0100ee2:	68 00 52 10 f0       	push   $0xf0105200
f0100ee7:	e8 0d f2 ff ff       	call   f01000f9 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100eec:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ef1:	75 19                	jne    f0100f0c <check_page_free_list+0x1cd>
f0100ef3:	68 f0 55 10 f0       	push   $0xf01055f0
f0100ef8:	68 26 52 10 f0       	push   $0xf0105226
f0100efd:	68 81 02 00 00       	push   $0x281
f0100f02:	68 00 52 10 f0       	push   $0xf0105200
f0100f07:	e8 ed f1 ff ff       	call   f01000f9 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100f0c:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100f11:	75 19                	jne    f0100f2c <check_page_free_list+0x1ed>
f0100f13:	68 79 52 10 f0       	push   $0xf0105279
f0100f18:	68 26 52 10 f0       	push   $0xf0105226
f0100f1d:	68 82 02 00 00       	push   $0x282
f0100f22:	68 00 52 10 f0       	push   $0xf0105200
f0100f27:	e8 cd f1 ff ff       	call   f01000f9 <_panic>
		// cprintf("pp: %x, page2pa(pp): %x, page2kva(pp): %x, first_free_page: %x\n",
		// 	pp, page2pa(pp), page2kva(pp), first_free_page);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100f2c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100f31:	76 3f                	jbe    f0100f72 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f33:	89 c3                	mov    %eax,%ebx
f0100f35:	c1 eb 0c             	shr    $0xc,%ebx
f0100f38:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100f3b:	77 12                	ja     f0100f4f <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f3d:	50                   	push   %eax
f0100f3e:	68 74 55 10 f0       	push   $0xf0105574
f0100f43:	6a 56                	push   $0x56
f0100f45:	68 0c 52 10 f0       	push   $0xf010520c
f0100f4a:	e8 aa f1 ff ff       	call   f01000f9 <_panic>
f0100f4f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f54:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100f57:	76 1e                	jbe    f0100f77 <check_page_free_list+0x238>
f0100f59:	68 14 56 10 f0       	push   $0xf0105614
f0100f5e:	68 26 52 10 f0       	push   $0xf0105226
f0100f63:	68 85 02 00 00       	push   $0x285
f0100f68:	68 00 52 10 f0       	push   $0xf0105200
f0100f6d:	e8 87 f1 ff ff       	call   f01000f9 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100f72:	83 c6 01             	add    $0x1,%esi
f0100f75:	eb 04                	jmp    f0100f7b <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100f77:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f7b:	8b 12                	mov    (%edx),%edx
f0100f7d:	85 d2                	test   %edx,%edx
f0100f7f:	0f 85 c8 fe ff ff    	jne    f0100e4d <check_page_free_list+0x10e>
f0100f85:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100f88:	85 f6                	test   %esi,%esi
f0100f8a:	7f 19                	jg     f0100fa5 <check_page_free_list+0x266>
f0100f8c:	68 93 52 10 f0       	push   $0xf0105293
f0100f91:	68 26 52 10 f0       	push   $0xf0105226
f0100f96:	68 8d 02 00 00       	push   $0x28d
f0100f9b:	68 00 52 10 f0       	push   $0xf0105200
f0100fa0:	e8 54 f1 ff ff       	call   f01000f9 <_panic>
	assert(nfree_extmem > 0);
f0100fa5:	85 db                	test   %ebx,%ebx
f0100fa7:	7f 19                	jg     f0100fc2 <check_page_free_list+0x283>
f0100fa9:	68 a5 52 10 f0       	push   $0xf01052a5
f0100fae:	68 26 52 10 f0       	push   $0xf0105226
f0100fb3:	68 8e 02 00 00       	push   $0x28e
f0100fb8:	68 00 52 10 f0       	push   $0xf0105200
f0100fbd:	e8 37 f1 ff ff       	call   f01000f9 <_panic>
	cprintf("check_page_free_list done\n");
f0100fc2:	83 ec 0c             	sub    $0xc,%esp
f0100fc5:	68 b6 52 10 f0       	push   $0xf01052b6
f0100fca:	e8 31 23 00 00       	call   f0103300 <cprintf>
}
f0100fcf:	eb 29                	jmp    f0100ffa <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100fd1:	a1 40 d1 17 f0       	mov    0xf017d140,%eax
f0100fd6:	85 c0                	test   %eax,%eax
f0100fd8:	0f 85 8e fd ff ff    	jne    f0100d6c <check_page_free_list+0x2d>
f0100fde:	e9 72 fd ff ff       	jmp    f0100d55 <check_page_free_list+0x16>
f0100fe3:	83 3d 40 d1 17 f0 00 	cmpl   $0x0,0xf017d140
f0100fea:	0f 84 65 fd ff ff    	je     f0100d55 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ff0:	be 00 04 00 00       	mov    $0x400,%esi
f0100ff5:	e9 c0 fd ff ff       	jmp    f0100dba <check_page_free_list+0x7b>
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
	cprintf("check_page_free_list done\n");
}
f0100ffa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ffd:	5b                   	pop    %ebx
f0100ffe:	5e                   	pop    %esi
f0100fff:	5f                   	pop    %edi
f0101000:	5d                   	pop    %ebp
f0101001:	c3                   	ret    

f0101002 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101002:	55                   	push   %ebp
f0101003:	89 e5                	mov    %esp,%ebp
f0101005:	56                   	push   %esi
f0101006:	53                   	push   %ebx
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0101007:	8b 35 44 d1 17 f0    	mov    0xf017d144,%esi
f010100d:	8b 1d 40 d1 17 f0    	mov    0xf017d140,%ebx
f0101013:	ba 00 00 00 00       	mov    $0x0,%edx
f0101018:	b8 01 00 00 00       	mov    $0x1,%eax
f010101d:	eb 27                	jmp    f0101046 <page_init+0x44>
		pages[i].pp_ref = 0;
f010101f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0101026:	89 d1                	mov    %edx,%ecx
f0101028:	03 0d 0c de 17 f0    	add    0xf017de0c,%ecx
f010102e:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0101034:	89 19                	mov    %ebx,(%ecx)
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0101036:	83 c0 01             	add    $0x1,%eax
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
f0101039:	89 d3                	mov    %edx,%ebx
f010103b:	03 1d 0c de 17 f0    	add    0xf017de0c,%ebx
f0101041:	ba 01 00 00 00       	mov    $0x1,%edx
	// 
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 1; i < npages_basemem; i++) {
f0101046:	39 f0                	cmp    %esi,%eax
f0101048:	72 d5                	jb     f010101f <page_init+0x1d>
f010104a:	84 d2                	test   %dl,%dl
f010104c:	74 06                	je     f0101054 <page_init+0x52>
f010104e:	89 1d 40 d1 17 f0    	mov    %ebx,0xf017d140
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
f0101054:	8b 15 4c d1 17 f0    	mov    0xf017d14c,%edx
f010105a:	8d 82 ff 8f 01 10    	lea    0x10018fff(%edx),%eax
f0101060:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101065:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
f010106b:	85 c0                	test   %eax,%eax
f010106d:	0f 48 c3             	cmovs  %ebx,%eax
f0101070:	c1 f8 0c             	sar    $0xc,%eax
f0101073:	89 c3                	mov    %eax,%ebx
	cprintf("%x\n", ((char*)envs) + (sizeof(struct Env) * NENV));
f0101075:	83 ec 08             	sub    $0x8,%esp
f0101078:	81 c2 00 80 01 00    	add    $0x18000,%edx
f010107e:	52                   	push   %edx
f010107f:	68 3e 55 10 f0       	push   $0xf010553e
f0101084:	e8 77 22 00 00       	call   f0103300 <cprintf>
	cprintf("med=%d\n", med);
f0101089:	83 c4 08             	add    $0x8,%esp
f010108c:	53                   	push   %ebx
f010108d:	68 d1 52 10 f0       	push   $0xf01052d1
f0101092:	e8 69 22 00 00       	call   f0103300 <cprintf>
	for (i = med; i < npages; i++) {
f0101097:	89 da                	mov    %ebx,%edx
f0101099:	8b 35 40 d1 17 f0    	mov    0xf017d140,%esi
f010109f:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
f01010a6:	83 c4 10             	add    $0x10,%esp
f01010a9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01010ae:	eb 23                	jmp    f01010d3 <page_init+0xd1>
		pages[i].pp_ref = 0;
f01010b0:	89 c1                	mov    %eax,%ecx
f01010b2:	03 0d 0c de 17 f0    	add    0xf017de0c,%ecx
f01010b8:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f01010be:	89 31                	mov    %esi,(%ecx)
		page_free_list = &pages[i];
f01010c0:	89 c6                	mov    %eax,%esi
f01010c2:	03 35 0c de 17 f0    	add    0xf017de0c,%esi
		page_free_list = &pages[i];
	}
	int med = (int)ROUNDUP(((char*)envs) + (sizeof(struct Env) * NENV) - 0xf0000000, PGSIZE)/PGSIZE;
	cprintf("%x\n", ((char*)envs) + (sizeof(struct Env) * NENV));
	cprintf("med=%d\n", med);
	for (i = med; i < npages; i++) {
f01010c8:	83 c2 01             	add    $0x1,%edx
f01010cb:	83 c0 08             	add    $0x8,%eax
f01010ce:	b9 01 00 00 00       	mov    $0x1,%ecx
f01010d3:	3b 15 04 de 17 f0    	cmp    0xf017de04,%edx
f01010d9:	72 d5                	jb     f01010b0 <page_init+0xae>
f01010db:	84 c9                	test   %cl,%cl
f01010dd:	74 06                	je     f01010e5 <page_init+0xe3>
f01010df:	89 35 40 d1 17 f0    	mov    %esi,0xf017d140
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f01010e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01010e8:	5b                   	pop    %ebx
f01010e9:	5e                   	pop    %esi
f01010ea:	5d                   	pop    %ebp
f01010eb:	c3                   	ret    

f01010ec <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f01010ec:	55                   	push   %ebp
f01010ed:	89 e5                	mov    %esp,%ebp
f01010ef:	53                   	push   %ebx
f01010f0:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list) {
f01010f3:	8b 1d 40 d1 17 f0    	mov    0xf017d140,%ebx
f01010f9:	85 db                	test   %ebx,%ebx
f01010fb:	74 52                	je     f010114f <page_alloc+0x63>
		struct PageInfo *ret = page_free_list;
		page_free_list = page_free_list->pp_link;
f01010fd:	8b 03                	mov    (%ebx),%eax
f01010ff:	a3 40 d1 17 f0       	mov    %eax,0xf017d140
		if (alloc_flags & ALLOC_ZERO) 
f0101104:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101108:	74 45                	je     f010114f <page_alloc+0x63>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010110a:	89 d8                	mov    %ebx,%eax
f010110c:	2b 05 0c de 17 f0    	sub    0xf017de0c,%eax
f0101112:	c1 f8 03             	sar    $0x3,%eax
f0101115:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101118:	89 c2                	mov    %eax,%edx
f010111a:	c1 ea 0c             	shr    $0xc,%edx
f010111d:	3b 15 04 de 17 f0    	cmp    0xf017de04,%edx
f0101123:	72 12                	jb     f0101137 <page_alloc+0x4b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101125:	50                   	push   %eax
f0101126:	68 74 55 10 f0       	push   $0xf0105574
f010112b:	6a 56                	push   $0x56
f010112d:	68 0c 52 10 f0       	push   $0xf010520c
f0101132:	e8 c2 ef ff ff       	call   f01000f9 <_panic>
			memset(page2kva(ret), 0, PGSIZE);
f0101137:	83 ec 04             	sub    $0x4,%esp
f010113a:	68 00 10 00 00       	push   $0x1000
f010113f:	6a 00                	push   $0x0
f0101141:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101146:	50                   	push   %eax
f0101147:	e8 fe 34 00 00       	call   f010464a <memset>
f010114c:	83 c4 10             	add    $0x10,%esp
		return ret;
	}
	return NULL;
}
f010114f:	89 d8                	mov    %ebx,%eax
f0101151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101154:	c9                   	leave  
f0101155:	c3                   	ret    

f0101156 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101156:	55                   	push   %ebp
f0101157:	89 e5                	mov    %esp,%ebp
f0101159:	8b 45 08             	mov    0x8(%ebp),%eax
	pp->pp_link = page_free_list;
f010115c:	8b 15 40 d1 17 f0    	mov    0xf017d140,%edx
f0101162:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101164:	a3 40 d1 17 f0       	mov    %eax,0xf017d140
}
f0101169:	5d                   	pop    %ebp
f010116a:	c3                   	ret    

f010116b <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010116b:	55                   	push   %ebp
f010116c:	89 e5                	mov    %esp,%ebp
f010116e:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101171:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0101175:	83 e8 01             	sub    $0x1,%eax
f0101178:	66 89 42 04          	mov    %ax,0x4(%edx)
f010117c:	66 85 c0             	test   %ax,%ax
f010117f:	75 09                	jne    f010118a <page_decref+0x1f>
		page_free(pp);
f0101181:	52                   	push   %edx
f0101182:	e8 cf ff ff ff       	call   f0101156 <page_free>
f0101187:	83 c4 04             	add    $0x4,%esp
}
f010118a:	c9                   	leave  
f010118b:	c3                   	ret    

f010118c <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010118c:	55                   	push   %ebp
f010118d:	89 e5                	mov    %esp,%ebp
f010118f:	56                   	push   %esi
f0101190:	53                   	push   %ebx
f0101191:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int dindex = PDX(va), tindex = PTX(va);
f0101194:	89 de                	mov    %ebx,%esi
f0101196:	c1 ee 0c             	shr    $0xc,%esi
f0101199:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
f010119f:	c1 eb 16             	shr    $0x16,%ebx
f01011a2:	c1 e3 02             	shl    $0x2,%ebx
f01011a5:	03 5d 08             	add    0x8(%ebp),%ebx
f01011a8:	f6 03 01             	testb  $0x1,(%ebx)
f01011ab:	75 2d                	jne    f01011da <pgdir_walk+0x4e>
		if (create) {
f01011ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01011b1:	74 59                	je     f010120c <pgdir_walk+0x80>
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
f01011b3:	83 ec 0c             	sub    $0xc,%esp
f01011b6:	6a 01                	push   $0x1
f01011b8:	e8 2f ff ff ff       	call   f01010ec <page_alloc>
			if (!pg) return NULL;	//allocation fails
f01011bd:	83 c4 10             	add    $0x10,%esp
f01011c0:	85 c0                	test   %eax,%eax
f01011c2:	74 4f                	je     f0101213 <pgdir_walk+0x87>
			pg->pp_ref++;
f01011c4:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
f01011c9:	2b 05 0c de 17 f0    	sub    0xf017de0c,%eax
f01011cf:	c1 f8 03             	sar    $0x3,%eax
f01011d2:	c1 e0 0c             	shl    $0xc,%eax
f01011d5:	83 c8 07             	or     $0x7,%eax
f01011d8:	89 03                	mov    %eax,(%ebx)
		} else return NULL;
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[dindex]));
f01011da:	8b 03                	mov    (%ebx),%eax
f01011dc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011e1:	89 c2                	mov    %eax,%edx
f01011e3:	c1 ea 0c             	shr    $0xc,%edx
f01011e6:	3b 15 04 de 17 f0    	cmp    0xf017de04,%edx
f01011ec:	72 15                	jb     f0101203 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011ee:	50                   	push   %eax
f01011ef:	68 74 55 10 f0       	push   $0xf0105574
f01011f4:	68 8b 01 00 00       	push   $0x18b
f01011f9:	68 00 52 10 f0       	push   $0xf0105200
f01011fe:	e8 f6 ee ff ff       	call   f01000f9 <_panic>
	// 		struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
f0101203:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f010120a:	eb 0c                	jmp    f0101218 <pgdir_walk+0x8c>
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
			pg->pp_ref++;
			pgdir[dindex] = page2pa(pg) | PTE_P | PTE_U | PTE_W;
		} else return NULL;
f010120c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101211:	eb 05                	jmp    f0101218 <pgdir_walk+0x8c>
	int dindex = PDX(va), tindex = PTX(va);
	//dir index, table index
	if (!(pgdir[dindex] & PTE_P)) {	//if pde not exist
		if (create) {
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);	//alloc a zero page
			if (!pg) return NULL;	//allocation fails
f0101213:	b8 00 00 00 00       	mov    $0x0,%eax
	// 		pg->pp_ref++;
	// 		p[tindex] = page2pa(pg) | PTE_P;
	// 	} else return NULL;

	return p+tindex;
}
f0101218:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010121b:	5b                   	pop    %ebx
f010121c:	5e                   	pop    %esi
f010121d:	5d                   	pop    %ebp
f010121e:	c3                   	ret    

f010121f <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f010121f:	55                   	push   %ebp
f0101220:	89 e5                	mov    %esp,%ebp
f0101222:	57                   	push   %edi
f0101223:	56                   	push   %esi
f0101224:	53                   	push   %ebx
f0101225:	83 ec 20             	sub    $0x20,%esp
f0101228:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010122b:	89 d7                	mov    %edx,%edi
f010122d:	89 cb                	mov    %ecx,%ebx
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
f010122f:	ff 75 08             	pushl  0x8(%ebp)
f0101232:	52                   	push   %edx
f0101233:	68 5c 56 10 f0       	push   $0xf010565c
f0101238:	e8 c3 20 00 00       	call   f0103300 <cprintf>
f010123d:	c1 eb 0c             	shr    $0xc,%ebx
f0101240:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101243:	83 c4 10             	add    $0x10,%esp
f0101246:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0101249:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f010124e:	29 df                	sub    %ebx,%edi
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
f0101250:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101253:	83 c8 01             	or     $0x1,%eax
f0101256:	89 45 dc             	mov    %eax,-0x24(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101259:	eb 3f                	jmp    f010129a <boot_map_region+0x7b>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
f010125b:	83 ec 04             	sub    $0x4,%esp
f010125e:	6a 01                	push   $0x1
f0101260:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f0101263:	50                   	push   %eax
f0101264:	ff 75 e0             	pushl  -0x20(%ebp)
f0101267:	e8 20 ff ff ff       	call   f010118c <pgdir_walk>
		if (!pte) panic("boot_map_region panic, out of memory");
f010126c:	83 c4 10             	add    $0x10,%esp
f010126f:	85 c0                	test   %eax,%eax
f0101271:	75 17                	jne    f010128a <boot_map_region+0x6b>
f0101273:	83 ec 04             	sub    $0x4,%esp
f0101276:	68 f4 50 10 f0       	push   $0xf01050f4
f010127b:	68 a9 01 00 00       	push   $0x1a9
f0101280:	68 00 52 10 f0       	push   $0xf0105200
f0101285:	e8 6f ee ff ff       	call   f01000f9 <_panic>
		*pte = pa | perm | PTE_P;
f010128a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010128d:	09 da                	or     %ebx,%edx
f010128f:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	int i;
	cprintf("Virtual Address %x mapped to Physical Address %x\n", va, pa);
	for (i = 0; i < size/PGSIZE; ++i, va += PGSIZE, pa += PGSIZE) {
f0101291:	83 c6 01             	add    $0x1,%esi
f0101294:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010129a:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010129d:	75 bc                	jne    f010125b <boot_map_region+0x3c>
		pte_t *pte = pgdir_walk(pgdir, (void *) va, 1);	//create
		if (!pte) panic("boot_map_region panic, out of memory");
		*pte = pa | perm | PTE_P;
	}
}
f010129f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012a2:	5b                   	pop    %ebx
f01012a3:	5e                   	pop    %esi
f01012a4:	5f                   	pop    %edi
f01012a5:	5d                   	pop    %ebp
f01012a6:	c3                   	ret    

f01012a7 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f01012a7:	55                   	push   %ebp
f01012a8:	89 e5                	mov    %esp,%ebp
f01012aa:	53                   	push   %ebx
f01012ab:	83 ec 08             	sub    $0x8,%esp
f01012ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
f01012b1:	6a 00                	push   $0x0
f01012b3:	ff 75 0c             	pushl  0xc(%ebp)
f01012b6:	ff 75 08             	pushl  0x8(%ebp)
f01012b9:	e8 ce fe ff ff       	call   f010118c <pgdir_walk>
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f01012be:	83 c4 10             	add    $0x10,%esp
f01012c1:	85 c0                	test   %eax,%eax
f01012c3:	74 37                	je     f01012fc <page_lookup+0x55>
f01012c5:	f6 00 01             	testb  $0x1,(%eax)
f01012c8:	74 39                	je     f0101303 <page_lookup+0x5c>
	if (pte_store)
f01012ca:	85 db                	test   %ebx,%ebx
f01012cc:	74 02                	je     f01012d0 <page_lookup+0x29>
		*pte_store = pte;	//found and set
f01012ce:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012d0:	8b 00                	mov    (%eax),%eax
f01012d2:	c1 e8 0c             	shr    $0xc,%eax
f01012d5:	3b 05 04 de 17 f0    	cmp    0xf017de04,%eax
f01012db:	72 14                	jb     f01012f1 <page_lookup+0x4a>
		panic("pa2page called with invalid pa");
f01012dd:	83 ec 04             	sub    $0x4,%esp
f01012e0:	68 90 56 10 f0       	push   $0xf0105690
f01012e5:	6a 4f                	push   $0x4f
f01012e7:	68 0c 52 10 f0       	push   $0xf010520c
f01012ec:	e8 08 ee ff ff       	call   f01000f9 <_panic>
	return &pages[PGNUM(pa)];
f01012f1:	8b 15 0c de 17 f0    	mov    0xf017de0c,%edx
f01012f7:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(PTE_ADDR(*pte));		
f01012fa:	eb 0c                	jmp    f0101308 <page_lookup+0x61>
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
	pte_t *pte = pgdir_walk(pgdir, va, 0);	//not create
	if (!pte || !(*pte & PTE_P)) return NULL;	//page not found
f01012fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0101301:	eb 05                	jmp    f0101308 <page_lookup+0x61>
f0101303:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pte_store)
		*pte_store = pte;	//found and set
	return pa2page(PTE_ADDR(*pte));		
}
f0101308:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010130b:	c9                   	leave  
f010130c:	c3                   	ret    

f010130d <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010130d:	55                   	push   %ebp
f010130e:	89 e5                	mov    %esp,%ebp
f0101310:	53                   	push   %ebx
f0101311:	83 ec 18             	sub    $0x18,%esp
f0101314:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte;
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f0101317:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010131a:	50                   	push   %eax
f010131b:	53                   	push   %ebx
f010131c:	ff 75 08             	pushl  0x8(%ebp)
f010131f:	e8 83 ff ff ff       	call   f01012a7 <page_lookup>
	if (!pg || !(*pte & PTE_P)) return;	//page not exist
f0101324:	83 c4 10             	add    $0x10,%esp
f0101327:	85 c0                	test   %eax,%eax
f0101329:	74 20                	je     f010134b <page_remove+0x3e>
f010132b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010132e:	f6 02 01             	testb  $0x1,(%edx)
f0101331:	74 18                	je     f010134b <page_remove+0x3e>
//   - The ref count on the physical page should decrement.
//   - The physical page should be freed if the refcount reaches 0.
	page_decref(pg);
f0101333:	83 ec 0c             	sub    $0xc,%esp
f0101336:	50                   	push   %eax
f0101337:	e8 2f fe ff ff       	call   f010116b <page_decref>
//   - The pg table entry corresponding to 'va' should be set to 0.
	*pte = 0;
f010133c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010133f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101345:	0f 01 3b             	invlpg (%ebx)
f0101348:	83 c4 10             	add    $0x10,%esp
//   - The TLB must be invalidated if you remove an entry from
//     the page table.
	tlb_invalidate(pgdir, va);
}
f010134b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010134e:	c9                   	leave  
f010134f:	c3                   	ret    

f0101350 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101350:	55                   	push   %ebp
f0101351:	89 e5                	mov    %esp,%ebp
f0101353:	57                   	push   %edi
f0101354:	56                   	push   %esi
f0101355:	53                   	push   %ebx
f0101356:	83 ec 10             	sub    $0x10,%esp
f0101359:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010135c:	8b 7d 10             	mov    0x10(%ebp),%edi
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
f010135f:	6a 01                	push   $0x1
f0101361:	57                   	push   %edi
f0101362:	ff 75 08             	pushl  0x8(%ebp)
f0101365:	e8 22 fe ff ff       	call   f010118c <pgdir_walk>
	if (!pte) 	//page table not allocated
f010136a:	83 c4 10             	add    $0x10,%esp
f010136d:	85 c0                	test   %eax,%eax
f010136f:	74 38                	je     f01013a9 <page_insert+0x59>
f0101371:	89 c6                	mov    %eax,%esi
		return -E_NO_MEM;	
	//increase ref count to avoid the corner case that pp is freed before it is inserted.
	pp->pp_ref++;	
f0101373:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
f0101378:	f6 00 01             	testb  $0x1,(%eax)
f010137b:	74 0f                	je     f010138c <page_insert+0x3c>
		page_remove(pgdir, va);
f010137d:	83 ec 08             	sub    $0x8,%esp
f0101380:	57                   	push   %edi
f0101381:	ff 75 08             	pushl  0x8(%ebp)
f0101384:	e8 84 ff ff ff       	call   f010130d <page_remove>
f0101389:	83 c4 10             	add    $0x10,%esp
	*pte = page2pa(pp) | perm | PTE_P;
f010138c:	2b 1d 0c de 17 f0    	sub    0xf017de0c,%ebx
f0101392:	c1 fb 03             	sar    $0x3,%ebx
f0101395:	c1 e3 0c             	shl    $0xc,%ebx
f0101398:	8b 45 14             	mov    0x14(%ebp),%eax
f010139b:	83 c8 01             	or     $0x1,%eax
f010139e:	09 c3                	or     %eax,%ebx
f01013a0:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01013a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01013a7:	eb 05                	jmp    f01013ae <page_insert+0x5e>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	pte_t *pte = pgdir_walk(pgdir, va, 1);	//create on demand
	if (!pte) 	//page table not allocated
		return -E_NO_MEM;	
f01013a9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	pp->pp_ref++;	
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
		page_remove(pgdir, va);
	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f01013ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013b1:	5b                   	pop    %ebx
f01013b2:	5e                   	pop    %esi
f01013b3:	5f                   	pop    %edi
f01013b4:	5d                   	pop    %ebp
f01013b5:	c3                   	ret    

f01013b6 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01013b6:	55                   	push   %ebp
f01013b7:	89 e5                	mov    %esp,%ebp
f01013b9:	57                   	push   %edi
f01013ba:	56                   	push   %esi
f01013bb:	53                   	push   %ebx
f01013bc:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013bf:	6a 15                	push   $0x15
f01013c1:	e8 d3 1e 00 00       	call   f0103299 <mc146818_read>
f01013c6:	89 c3                	mov    %eax,%ebx
f01013c8:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01013cf:	e8 c5 1e 00 00       	call   f0103299 <mc146818_read>
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01013d4:	c1 e0 08             	shl    $0x8,%eax
f01013d7:	09 d8                	or     %ebx,%eax
f01013d9:	c1 e0 0a             	shl    $0xa,%eax
f01013dc:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01013e2:	85 c0                	test   %eax,%eax
f01013e4:	0f 48 c2             	cmovs  %edx,%eax
f01013e7:	c1 f8 0c             	sar    $0xc,%eax
f01013ea:	a3 44 d1 17 f0       	mov    %eax,0xf017d144
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01013ef:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01013f6:	e8 9e 1e 00 00       	call   f0103299 <mc146818_read>
f01013fb:	89 c3                	mov    %eax,%ebx
f01013fd:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f0101404:	e8 90 1e 00 00       	call   f0103299 <mc146818_read>
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101409:	c1 e0 08             	shl    $0x8,%eax
f010140c:	09 d8                	or     %ebx,%eax
f010140e:	c1 e0 0a             	shl    $0xa,%eax
f0101411:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101417:	83 c4 10             	add    $0x10,%esp
f010141a:	85 c0                	test   %eax,%eax
f010141c:	0f 48 c2             	cmovs  %edx,%eax
f010141f:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101422:	85 c0                	test   %eax,%eax
f0101424:	74 0e                	je     f0101434 <mem_init+0x7e>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0101426:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f010142c:	89 15 04 de 17 f0    	mov    %edx,0xf017de04
f0101432:	eb 0c                	jmp    f0101440 <mem_init+0x8a>
	else
		npages = npages_basemem;
f0101434:	8b 15 44 d1 17 f0    	mov    0xf017d144,%edx
f010143a:	89 15 04 de 17 f0    	mov    %edx,0xf017de04

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101440:	c1 e0 0c             	shl    $0xc,%eax
f0101443:	c1 e8 0a             	shr    $0xa,%eax
f0101446:	50                   	push   %eax
f0101447:	a1 44 d1 17 f0       	mov    0xf017d144,%eax
f010144c:	c1 e0 0c             	shl    $0xc,%eax
f010144f:	c1 e8 0a             	shr    $0xa,%eax
f0101452:	50                   	push   %eax
f0101453:	a1 04 de 17 f0       	mov    0xf017de04,%eax
f0101458:	c1 e0 0c             	shl    $0xc,%eax
f010145b:	c1 e8 0a             	shr    $0xa,%eax
f010145e:	50                   	push   %eax
f010145f:	68 b0 56 10 f0       	push   $0xf01056b0
f0101464:	e8 97 1e 00 00       	call   f0103300 <cprintf>
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101469:	b8 00 10 00 00       	mov    $0x1000,%eax
f010146e:	e8 f0 f7 ff ff       	call   f0100c63 <boot_alloc>
f0101473:	a3 08 de 17 f0       	mov    %eax,0xf017de08
	memset(kern_pgdir, 0, PGSIZE);
f0101478:	83 c4 0c             	add    $0xc,%esp
f010147b:	68 00 10 00 00       	push   $0x1000
f0101480:	6a 00                	push   $0x0
f0101482:	50                   	push   %eax
f0101483:	e8 c2 31 00 00       	call   f010464a <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101488:	a1 08 de 17 f0       	mov    0xf017de08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010148d:	83 c4 10             	add    $0x10,%esp
f0101490:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101495:	77 15                	ja     f01014ac <mem_init+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101497:	50                   	push   %eax
f0101498:	68 ec 56 10 f0       	push   $0xf01056ec
f010149d:	68 93 00 00 00       	push   $0x93
f01014a2:	68 00 52 10 f0       	push   $0xf0105200
f01014a7:	e8 4d ec ff ff       	call   f01000f9 <_panic>
f01014ac:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01014b2:	83 ca 05             	or     $0x5,%edx
f01014b5:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct PageInfo's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f01014bb:	a1 04 de 17 f0       	mov    0xf017de04,%eax
f01014c0:	c1 e0 03             	shl    $0x3,%eax
f01014c3:	e8 9b f7 ff ff       	call   f0100c63 <boot_alloc>
f01014c8:	a3 0c de 17 f0       	mov    %eax,0xf017de0c

	cprintf("npages: %d\n", npages);
f01014cd:	83 ec 08             	sub    $0x8,%esp
f01014d0:	ff 35 04 de 17 f0    	pushl  0xf017de04
f01014d6:	68 d9 52 10 f0       	push   $0xf01052d9
f01014db:	e8 20 1e 00 00       	call   f0103300 <cprintf>
	cprintf("npages_basemem: %d\n", npages_basemem);
f01014e0:	83 c4 08             	add    $0x8,%esp
f01014e3:	ff 35 44 d1 17 f0    	pushl  0xf017d144
f01014e9:	68 e5 52 10 f0       	push   $0xf01052e5
f01014ee:	e8 0d 1e 00 00       	call   f0103300 <cprintf>
	cprintf("pages: %x\n", pages);
f01014f3:	83 c4 08             	add    $0x8,%esp
f01014f6:	ff 35 0c de 17 f0    	pushl  0xf017de0c
f01014fc:	68 f9 52 10 f0       	push   $0xf01052f9
f0101501:	e8 fa 1d 00 00       	call   f0103300 <cprintf>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f0101506:	b8 00 80 01 00       	mov    $0x18000,%eax
f010150b:	e8 53 f7 ff ff       	call   f0100c63 <boot_alloc>
f0101510:	a3 4c d1 17 f0       	mov    %eax,0xf017d14c
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101515:	e8 e8 fa ff ff       	call   f0101002 <page_init>

	check_page_free_list(1);
f010151a:	b8 01 00 00 00       	mov    $0x1,%eax
f010151f:	e8 1b f8 ff ff       	call   f0100d3f <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101524:	83 c4 10             	add    $0x10,%esp
f0101527:	83 3d 0c de 17 f0 00 	cmpl   $0x0,0xf017de0c
f010152e:	75 17                	jne    f0101547 <mem_init+0x191>
		panic("'pages' is a null pointer!");
f0101530:	83 ec 04             	sub    $0x4,%esp
f0101533:	68 04 53 10 f0       	push   $0xf0105304
f0101538:	68 a0 02 00 00       	push   $0x2a0
f010153d:	68 00 52 10 f0       	push   $0xf0105200
f0101542:	e8 b2 eb ff ff       	call   f01000f9 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101547:	a1 40 d1 17 f0       	mov    0xf017d140,%eax
f010154c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101551:	eb 05                	jmp    f0101558 <mem_init+0x1a2>
		++nfree;
f0101553:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101556:	8b 00                	mov    (%eax),%eax
f0101558:	85 c0                	test   %eax,%eax
f010155a:	75 f7                	jne    f0101553 <mem_init+0x19d>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010155c:	83 ec 0c             	sub    $0xc,%esp
f010155f:	6a 00                	push   $0x0
f0101561:	e8 86 fb ff ff       	call   f01010ec <page_alloc>
f0101566:	89 c7                	mov    %eax,%edi
f0101568:	83 c4 10             	add    $0x10,%esp
f010156b:	85 c0                	test   %eax,%eax
f010156d:	75 19                	jne    f0101588 <mem_init+0x1d2>
f010156f:	68 1f 53 10 f0       	push   $0xf010531f
f0101574:	68 26 52 10 f0       	push   $0xf0105226
f0101579:	68 a8 02 00 00       	push   $0x2a8
f010157e:	68 00 52 10 f0       	push   $0xf0105200
f0101583:	e8 71 eb ff ff       	call   f01000f9 <_panic>
	assert((pp1 = page_alloc(0)));
f0101588:	83 ec 0c             	sub    $0xc,%esp
f010158b:	6a 00                	push   $0x0
f010158d:	e8 5a fb ff ff       	call   f01010ec <page_alloc>
f0101592:	89 c6                	mov    %eax,%esi
f0101594:	83 c4 10             	add    $0x10,%esp
f0101597:	85 c0                	test   %eax,%eax
f0101599:	75 19                	jne    f01015b4 <mem_init+0x1fe>
f010159b:	68 35 53 10 f0       	push   $0xf0105335
f01015a0:	68 26 52 10 f0       	push   $0xf0105226
f01015a5:	68 a9 02 00 00       	push   $0x2a9
f01015aa:	68 00 52 10 f0       	push   $0xf0105200
f01015af:	e8 45 eb ff ff       	call   f01000f9 <_panic>
	assert((pp2 = page_alloc(0)));
f01015b4:	83 ec 0c             	sub    $0xc,%esp
f01015b7:	6a 00                	push   $0x0
f01015b9:	e8 2e fb ff ff       	call   f01010ec <page_alloc>
f01015be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015c1:	83 c4 10             	add    $0x10,%esp
f01015c4:	85 c0                	test   %eax,%eax
f01015c6:	75 19                	jne    f01015e1 <mem_init+0x22b>
f01015c8:	68 4b 53 10 f0       	push   $0xf010534b
f01015cd:	68 26 52 10 f0       	push   $0xf0105226
f01015d2:	68 aa 02 00 00       	push   $0x2aa
f01015d7:	68 00 52 10 f0       	push   $0xf0105200
f01015dc:	e8 18 eb ff ff       	call   f01000f9 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015e1:	39 f7                	cmp    %esi,%edi
f01015e3:	75 19                	jne    f01015fe <mem_init+0x248>
f01015e5:	68 61 53 10 f0       	push   $0xf0105361
f01015ea:	68 26 52 10 f0       	push   $0xf0105226
f01015ef:	68 ad 02 00 00       	push   $0x2ad
f01015f4:	68 00 52 10 f0       	push   $0xf0105200
f01015f9:	e8 fb ea ff ff       	call   f01000f9 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101601:	39 c6                	cmp    %eax,%esi
f0101603:	74 04                	je     f0101609 <mem_init+0x253>
f0101605:	39 c7                	cmp    %eax,%edi
f0101607:	75 19                	jne    f0101622 <mem_init+0x26c>
f0101609:	68 10 57 10 f0       	push   $0xf0105710
f010160e:	68 26 52 10 f0       	push   $0xf0105226
f0101613:	68 ae 02 00 00       	push   $0x2ae
f0101618:	68 00 52 10 f0       	push   $0xf0105200
f010161d:	e8 d7 ea ff ff       	call   f01000f9 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101622:	8b 0d 0c de 17 f0    	mov    0xf017de0c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101628:	8b 15 04 de 17 f0    	mov    0xf017de04,%edx
f010162e:	c1 e2 0c             	shl    $0xc,%edx
f0101631:	89 f8                	mov    %edi,%eax
f0101633:	29 c8                	sub    %ecx,%eax
f0101635:	c1 f8 03             	sar    $0x3,%eax
f0101638:	c1 e0 0c             	shl    $0xc,%eax
f010163b:	39 d0                	cmp    %edx,%eax
f010163d:	72 19                	jb     f0101658 <mem_init+0x2a2>
f010163f:	68 73 53 10 f0       	push   $0xf0105373
f0101644:	68 26 52 10 f0       	push   $0xf0105226
f0101649:	68 af 02 00 00       	push   $0x2af
f010164e:	68 00 52 10 f0       	push   $0xf0105200
f0101653:	e8 a1 ea ff ff       	call   f01000f9 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101658:	89 f0                	mov    %esi,%eax
f010165a:	29 c8                	sub    %ecx,%eax
f010165c:	c1 f8 03             	sar    $0x3,%eax
f010165f:	c1 e0 0c             	shl    $0xc,%eax
f0101662:	39 c2                	cmp    %eax,%edx
f0101664:	77 19                	ja     f010167f <mem_init+0x2c9>
f0101666:	68 90 53 10 f0       	push   $0xf0105390
f010166b:	68 26 52 10 f0       	push   $0xf0105226
f0101670:	68 b0 02 00 00       	push   $0x2b0
f0101675:	68 00 52 10 f0       	push   $0xf0105200
f010167a:	e8 7a ea ff ff       	call   f01000f9 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010167f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101682:	29 c8                	sub    %ecx,%eax
f0101684:	c1 f8 03             	sar    $0x3,%eax
f0101687:	c1 e0 0c             	shl    $0xc,%eax
f010168a:	39 c2                	cmp    %eax,%edx
f010168c:	77 19                	ja     f01016a7 <mem_init+0x2f1>
f010168e:	68 ad 53 10 f0       	push   $0xf01053ad
f0101693:	68 26 52 10 f0       	push   $0xf0105226
f0101698:	68 b1 02 00 00       	push   $0x2b1
f010169d:	68 00 52 10 f0       	push   $0xf0105200
f01016a2:	e8 52 ea ff ff       	call   f01000f9 <_panic>


	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01016a7:	a1 40 d1 17 f0       	mov    0xf017d140,%eax
f01016ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01016af:	c7 05 40 d1 17 f0 00 	movl   $0x0,0xf017d140
f01016b6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01016b9:	83 ec 0c             	sub    $0xc,%esp
f01016bc:	6a 00                	push   $0x0
f01016be:	e8 29 fa ff ff       	call   f01010ec <page_alloc>
f01016c3:	83 c4 10             	add    $0x10,%esp
f01016c6:	85 c0                	test   %eax,%eax
f01016c8:	74 19                	je     f01016e3 <mem_init+0x32d>
f01016ca:	68 ca 53 10 f0       	push   $0xf01053ca
f01016cf:	68 26 52 10 f0       	push   $0xf0105226
f01016d4:	68 b9 02 00 00       	push   $0x2b9
f01016d9:	68 00 52 10 f0       	push   $0xf0105200
f01016de:	e8 16 ea ff ff       	call   f01000f9 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01016e3:	83 ec 0c             	sub    $0xc,%esp
f01016e6:	57                   	push   %edi
f01016e7:	e8 6a fa ff ff       	call   f0101156 <page_free>
	page_free(pp1);
f01016ec:	89 34 24             	mov    %esi,(%esp)
f01016ef:	e8 62 fa ff ff       	call   f0101156 <page_free>
	page_free(pp2);
f01016f4:	83 c4 04             	add    $0x4,%esp
f01016f7:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016fa:	e8 57 fa ff ff       	call   f0101156 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101706:	e8 e1 f9 ff ff       	call   f01010ec <page_alloc>
f010170b:	89 c6                	mov    %eax,%esi
f010170d:	83 c4 10             	add    $0x10,%esp
f0101710:	85 c0                	test   %eax,%eax
f0101712:	75 19                	jne    f010172d <mem_init+0x377>
f0101714:	68 1f 53 10 f0       	push   $0xf010531f
f0101719:	68 26 52 10 f0       	push   $0xf0105226
f010171e:	68 c0 02 00 00       	push   $0x2c0
f0101723:	68 00 52 10 f0       	push   $0xf0105200
f0101728:	e8 cc e9 ff ff       	call   f01000f9 <_panic>
	assert((pp1 = page_alloc(0)));
f010172d:	83 ec 0c             	sub    $0xc,%esp
f0101730:	6a 00                	push   $0x0
f0101732:	e8 b5 f9 ff ff       	call   f01010ec <page_alloc>
f0101737:	89 c7                	mov    %eax,%edi
f0101739:	83 c4 10             	add    $0x10,%esp
f010173c:	85 c0                	test   %eax,%eax
f010173e:	75 19                	jne    f0101759 <mem_init+0x3a3>
f0101740:	68 35 53 10 f0       	push   $0xf0105335
f0101745:	68 26 52 10 f0       	push   $0xf0105226
f010174a:	68 c1 02 00 00       	push   $0x2c1
f010174f:	68 00 52 10 f0       	push   $0xf0105200
f0101754:	e8 a0 e9 ff ff       	call   f01000f9 <_panic>
	assert((pp2 = page_alloc(0)));
f0101759:	83 ec 0c             	sub    $0xc,%esp
f010175c:	6a 00                	push   $0x0
f010175e:	e8 89 f9 ff ff       	call   f01010ec <page_alloc>
f0101763:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101766:	83 c4 10             	add    $0x10,%esp
f0101769:	85 c0                	test   %eax,%eax
f010176b:	75 19                	jne    f0101786 <mem_init+0x3d0>
f010176d:	68 4b 53 10 f0       	push   $0xf010534b
f0101772:	68 26 52 10 f0       	push   $0xf0105226
f0101777:	68 c2 02 00 00       	push   $0x2c2
f010177c:	68 00 52 10 f0       	push   $0xf0105200
f0101781:	e8 73 e9 ff ff       	call   f01000f9 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101786:	39 fe                	cmp    %edi,%esi
f0101788:	75 19                	jne    f01017a3 <mem_init+0x3ed>
f010178a:	68 61 53 10 f0       	push   $0xf0105361
f010178f:	68 26 52 10 f0       	push   $0xf0105226
f0101794:	68 c4 02 00 00       	push   $0x2c4
f0101799:	68 00 52 10 f0       	push   $0xf0105200
f010179e:	e8 56 e9 ff ff       	call   f01000f9 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017a6:	39 c7                	cmp    %eax,%edi
f01017a8:	74 04                	je     f01017ae <mem_init+0x3f8>
f01017aa:	39 c6                	cmp    %eax,%esi
f01017ac:	75 19                	jne    f01017c7 <mem_init+0x411>
f01017ae:	68 10 57 10 f0       	push   $0xf0105710
f01017b3:	68 26 52 10 f0       	push   $0xf0105226
f01017b8:	68 c5 02 00 00       	push   $0x2c5
f01017bd:	68 00 52 10 f0       	push   $0xf0105200
f01017c2:	e8 32 e9 ff ff       	call   f01000f9 <_panic>
	assert(!page_alloc(0));
f01017c7:	83 ec 0c             	sub    $0xc,%esp
f01017ca:	6a 00                	push   $0x0
f01017cc:	e8 1b f9 ff ff       	call   f01010ec <page_alloc>
f01017d1:	83 c4 10             	add    $0x10,%esp
f01017d4:	85 c0                	test   %eax,%eax
f01017d6:	74 19                	je     f01017f1 <mem_init+0x43b>
f01017d8:	68 ca 53 10 f0       	push   $0xf01053ca
f01017dd:	68 26 52 10 f0       	push   $0xf0105226
f01017e2:	68 c6 02 00 00       	push   $0x2c6
f01017e7:	68 00 52 10 f0       	push   $0xf0105200
f01017ec:	e8 08 e9 ff ff       	call   f01000f9 <_panic>
f01017f1:	89 f0                	mov    %esi,%eax
f01017f3:	2b 05 0c de 17 f0    	sub    0xf017de0c,%eax
f01017f9:	c1 f8 03             	sar    $0x3,%eax
f01017fc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017ff:	89 c2                	mov    %eax,%edx
f0101801:	c1 ea 0c             	shr    $0xc,%edx
f0101804:	3b 15 04 de 17 f0    	cmp    0xf017de04,%edx
f010180a:	72 12                	jb     f010181e <mem_init+0x468>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010180c:	50                   	push   %eax
f010180d:	68 74 55 10 f0       	push   $0xf0105574
f0101812:	6a 56                	push   $0x56
f0101814:	68 0c 52 10 f0       	push   $0xf010520c
f0101819:	e8 db e8 ff ff       	call   f01000f9 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010181e:	83 ec 04             	sub    $0x4,%esp
f0101821:	68 00 10 00 00       	push   $0x1000
f0101826:	6a 01                	push   $0x1
f0101828:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010182d:	50                   	push   %eax
f010182e:	e8 17 2e 00 00       	call   f010464a <memset>
	page_free(pp0);
f0101833:	89 34 24             	mov    %esi,(%esp)
f0101836:	e8 1b f9 ff ff       	call   f0101156 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010183b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101842:	e8 a5 f8 ff ff       	call   f01010ec <page_alloc>
f0101847:	83 c4 10             	add    $0x10,%esp
f010184a:	85 c0                	test   %eax,%eax
f010184c:	75 19                	jne    f0101867 <mem_init+0x4b1>
f010184e:	68 d9 53 10 f0       	push   $0xf01053d9
f0101853:	68 26 52 10 f0       	push   $0xf0105226
f0101858:	68 cb 02 00 00       	push   $0x2cb
f010185d:	68 00 52 10 f0       	push   $0xf0105200
f0101862:	e8 92 e8 ff ff       	call   f01000f9 <_panic>
	assert(pp && pp0 == pp);
f0101867:	39 c6                	cmp    %eax,%esi
f0101869:	74 19                	je     f0101884 <mem_init+0x4ce>
f010186b:	68 f7 53 10 f0       	push   $0xf01053f7
f0101870:	68 26 52 10 f0       	push   $0xf0105226
f0101875:	68 cc 02 00 00       	push   $0x2cc
f010187a:	68 00 52 10 f0       	push   $0xf0105200
f010187f:	e8 75 e8 ff ff       	call   f01000f9 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101884:	89 f0                	mov    %esi,%eax
f0101886:	2b 05 0c de 17 f0    	sub    0xf017de0c,%eax
f010188c:	c1 f8 03             	sar    $0x3,%eax
f010188f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101892:	89 c2                	mov    %eax,%edx
f0101894:	c1 ea 0c             	shr    $0xc,%edx
f0101897:	3b 15 04 de 17 f0    	cmp    0xf017de04,%edx
f010189d:	72 12                	jb     f01018b1 <mem_init+0x4fb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010189f:	50                   	push   %eax
f01018a0:	68 74 55 10 f0       	push   $0xf0105574
f01018a5:	6a 56                	push   $0x56
f01018a7:	68 0c 52 10 f0       	push   $0xf010520c
f01018ac:	e8 48 e8 ff ff       	call   f01000f9 <_panic>
f01018b1:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01018b7:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018bd:	80 38 00             	cmpb   $0x0,(%eax)
f01018c0:	74 19                	je     f01018db <mem_init+0x525>
f01018c2:	68 07 54 10 f0       	push   $0xf0105407
f01018c7:	68 26 52 10 f0       	push   $0xf0105226
f01018cc:	68 cf 02 00 00       	push   $0x2cf
f01018d1:	68 00 52 10 f0       	push   $0xf0105200
f01018d6:	e8 1e e8 ff ff       	call   f01000f9 <_panic>
f01018db:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01018de:	39 d0                	cmp    %edx,%eax
f01018e0:	75 db                	jne    f01018bd <mem_init+0x507>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01018e2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01018e5:	a3 40 d1 17 f0       	mov    %eax,0xf017d140

	// free the pages we took
	page_free(pp0);
f01018ea:	83 ec 0c             	sub    $0xc,%esp
f01018ed:	56                   	push   %esi
f01018ee:	e8 63 f8 ff ff       	call   f0101156 <page_free>
	page_free(pp1);
f01018f3:	89 3c 24             	mov    %edi,(%esp)
f01018f6:	e8 5b f8 ff ff       	call   f0101156 <page_free>
	page_free(pp2);
f01018fb:	83 c4 04             	add    $0x4,%esp
f01018fe:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101901:	e8 50 f8 ff ff       	call   f0101156 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101906:	a1 40 d1 17 f0       	mov    0xf017d140,%eax
f010190b:	83 c4 10             	add    $0x10,%esp
f010190e:	eb 05                	jmp    f0101915 <mem_init+0x55f>
		--nfree;
f0101910:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101913:	8b 00                	mov    (%eax),%eax
f0101915:	85 c0                	test   %eax,%eax
f0101917:	75 f7                	jne    f0101910 <mem_init+0x55a>
		--nfree;
	assert(nfree == 0);
f0101919:	85 db                	test   %ebx,%ebx
f010191b:	74 19                	je     f0101936 <mem_init+0x580>
f010191d:	68 11 54 10 f0       	push   $0xf0105411
f0101922:	68 26 52 10 f0       	push   $0xf0105226
f0101927:	68 dc 02 00 00       	push   $0x2dc
f010192c:	68 00 52 10 f0       	push   $0xf0105200
f0101931:	e8 c3 e7 ff ff       	call   f01000f9 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101936:	83 ec 0c             	sub    $0xc,%esp
f0101939:	68 30 57 10 f0       	push   $0xf0105730
f010193e:	e8 bd 19 00 00       	call   f0103300 <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	cprintf("so far so good\n");
f0101943:	c7 04 24 1c 54 10 f0 	movl   $0xf010541c,(%esp)
f010194a:	e8 b1 19 00 00       	call   f0103300 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010194f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101956:	e8 91 f7 ff ff       	call   f01010ec <page_alloc>
f010195b:	89 c6                	mov    %eax,%esi
f010195d:	83 c4 10             	add    $0x10,%esp
f0101960:	85 c0                	test   %eax,%eax
f0101962:	75 19                	jne    f010197d <mem_init+0x5c7>
f0101964:	68 1f 53 10 f0       	push   $0xf010531f
f0101969:	68 26 52 10 f0       	push   $0xf0105226
f010196e:	68 3a 03 00 00       	push   $0x33a
f0101973:	68 00 52 10 f0       	push   $0xf0105200
f0101978:	e8 7c e7 ff ff       	call   f01000f9 <_panic>
	assert((pp1 = page_alloc(0)));
f010197d:	83 ec 0c             	sub    $0xc,%esp
f0101980:	6a 00                	push   $0x0
f0101982:	e8 65 f7 ff ff       	call   f01010ec <page_alloc>
f0101987:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010198a:	83 c4 10             	add    $0x10,%esp
f010198d:	85 c0                	test   %eax,%eax
f010198f:	75 19                	jne    f01019aa <mem_init+0x5f4>
f0101991:	68 35 53 10 f0       	push   $0xf0105335
f0101996:	68 26 52 10 f0       	push   $0xf0105226
f010199b:	68 3b 03 00 00       	push   $0x33b
f01019a0:	68 00 52 10 f0       	push   $0xf0105200
f01019a5:	e8 4f e7 ff ff       	call   f01000f9 <_panic>
	assert((pp2 = page_alloc(0)));
f01019aa:	83 ec 0c             	sub    $0xc,%esp
f01019ad:	6a 00                	push   $0x0
f01019af:	e8 38 f7 ff ff       	call   f01010ec <page_alloc>
f01019b4:	89 c3                	mov    %eax,%ebx
f01019b6:	83 c4 10             	add    $0x10,%esp
f01019b9:	85 c0                	test   %eax,%eax
f01019bb:	75 19                	jne    f01019d6 <mem_init+0x620>
f01019bd:	68 4b 53 10 f0       	push   $0xf010534b
f01019c2:	68 26 52 10 f0       	push   $0xf0105226
f01019c7:	68 3c 03 00 00       	push   $0x33c
f01019cc:	68 00 52 10 f0       	push   $0xf0105200
f01019d1:	e8 23 e7 ff ff       	call   f01000f9 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019d6:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01019d9:	75 19                	jne    f01019f4 <mem_init+0x63e>
f01019db:	68 61 53 10 f0       	push   $0xf0105361
f01019e0:	68 26 52 10 f0       	push   $0xf0105226
f01019e5:	68 3f 03 00 00       	push   $0x33f
f01019ea:	68 00 52 10 f0       	push   $0xf0105200
f01019ef:	e8 05 e7 ff ff       	call   f01000f9 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01019f4:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01019f7:	74 04                	je     f01019fd <mem_init+0x647>
f01019f9:	39 c6                	cmp    %eax,%esi
f01019fb:	75 19                	jne    f0101a16 <mem_init+0x660>
f01019fd:	68 10 57 10 f0       	push   $0xf0105710
f0101a02:	68 26 52 10 f0       	push   $0xf0105226
f0101a07:	68 40 03 00 00       	push   $0x340
f0101a0c:	68 00 52 10 f0       	push   $0xf0105200
f0101a11:	e8 e3 e6 ff ff       	call   f01000f9 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a16:	a1 40 d1 17 f0       	mov    0xf017d140,%eax
f0101a1b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101a1e:	c7 05 40 d1 17 f0 00 	movl   $0x0,0xf017d140
f0101a25:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a28:	83 ec 0c             	sub    $0xc,%esp
f0101a2b:	6a 00                	push   $0x0
f0101a2d:	e8 ba f6 ff ff       	call   f01010ec <page_alloc>
f0101a32:	83 c4 10             	add    $0x10,%esp
f0101a35:	85 c0                	test   %eax,%eax
f0101a37:	74 19                	je     f0101a52 <mem_init+0x69c>
f0101a39:	68 ca 53 10 f0       	push   $0xf01053ca
f0101a3e:	68 26 52 10 f0       	push   $0xf0105226
f0101a43:	68 47 03 00 00       	push   $0x347
f0101a48:	68 00 52 10 f0       	push   $0xf0105200
f0101a4d:	e8 a7 e6 ff ff       	call   f01000f9 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a52:	83 ec 04             	sub    $0x4,%esp
f0101a55:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a58:	50                   	push   %eax
f0101a59:	6a 00                	push   $0x0
f0101a5b:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0101a61:	e8 41 f8 ff ff       	call   f01012a7 <page_lookup>
f0101a66:	83 c4 10             	add    $0x10,%esp
f0101a69:	85 c0                	test   %eax,%eax
f0101a6b:	74 19                	je     f0101a86 <mem_init+0x6d0>
f0101a6d:	68 50 57 10 f0       	push   $0xf0105750
f0101a72:	68 26 52 10 f0       	push   $0xf0105226
f0101a77:	68 4a 03 00 00       	push   $0x34a
f0101a7c:	68 00 52 10 f0       	push   $0xf0105200
f0101a81:	e8 73 e6 ff ff       	call   f01000f9 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101a86:	6a 02                	push   $0x2
f0101a88:	6a 00                	push   $0x0
f0101a8a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a8d:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0101a93:	e8 b8 f8 ff ff       	call   f0101350 <page_insert>
f0101a98:	83 c4 10             	add    $0x10,%esp
f0101a9b:	85 c0                	test   %eax,%eax
f0101a9d:	78 19                	js     f0101ab8 <mem_init+0x702>
f0101a9f:	68 88 57 10 f0       	push   $0xf0105788
f0101aa4:	68 26 52 10 f0       	push   $0xf0105226
f0101aa9:	68 4d 03 00 00       	push   $0x34d
f0101aae:	68 00 52 10 f0       	push   $0xf0105200
f0101ab3:	e8 41 e6 ff ff       	call   f01000f9 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101ab8:	83 ec 0c             	sub    $0xc,%esp
f0101abb:	56                   	push   %esi
f0101abc:	e8 95 f6 ff ff       	call   f0101156 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101ac1:	6a 02                	push   $0x2
f0101ac3:	6a 00                	push   $0x0
f0101ac5:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ac8:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0101ace:	e8 7d f8 ff ff       	call   f0101350 <page_insert>
f0101ad3:	83 c4 20             	add    $0x20,%esp
f0101ad6:	85 c0                	test   %eax,%eax
f0101ad8:	74 19                	je     f0101af3 <mem_init+0x73d>
f0101ada:	68 b8 57 10 f0       	push   $0xf01057b8
f0101adf:	68 26 52 10 f0       	push   $0xf0105226
f0101ae4:	68 51 03 00 00       	push   $0x351
f0101ae9:	68 00 52 10 f0       	push   $0xf0105200
f0101aee:	e8 06 e6 ff ff       	call   f01000f9 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101af3:	8b 3d 08 de 17 f0    	mov    0xf017de08,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101af9:	a1 0c de 17 f0       	mov    0xf017de0c,%eax
f0101afe:	89 c1                	mov    %eax,%ecx
f0101b00:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b03:	8b 17                	mov    (%edi),%edx
f0101b05:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b0b:	89 f0                	mov    %esi,%eax
f0101b0d:	29 c8                	sub    %ecx,%eax
f0101b0f:	c1 f8 03             	sar    $0x3,%eax
f0101b12:	c1 e0 0c             	shl    $0xc,%eax
f0101b15:	39 c2                	cmp    %eax,%edx
f0101b17:	74 19                	je     f0101b32 <mem_init+0x77c>
f0101b19:	68 e8 57 10 f0       	push   $0xf01057e8
f0101b1e:	68 26 52 10 f0       	push   $0xf0105226
f0101b23:	68 52 03 00 00       	push   $0x352
f0101b28:	68 00 52 10 f0       	push   $0xf0105200
f0101b2d:	e8 c7 e5 ff ff       	call   f01000f9 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101b32:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b37:	89 f8                	mov    %edi,%eax
f0101b39:	e8 9d f1 ff ff       	call   f0100cdb <check_va2pa>
f0101b3e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101b41:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101b44:	c1 fa 03             	sar    $0x3,%edx
f0101b47:	c1 e2 0c             	shl    $0xc,%edx
f0101b4a:	39 d0                	cmp    %edx,%eax
f0101b4c:	74 19                	je     f0101b67 <mem_init+0x7b1>
f0101b4e:	68 10 58 10 f0       	push   $0xf0105810
f0101b53:	68 26 52 10 f0       	push   $0xf0105226
f0101b58:	68 53 03 00 00       	push   $0x353
f0101b5d:	68 00 52 10 f0       	push   $0xf0105200
f0101b62:	e8 92 e5 ff ff       	call   f01000f9 <_panic>
	assert(pp1->pp_ref == 1);
f0101b67:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b6a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b6f:	74 19                	je     f0101b8a <mem_init+0x7d4>
f0101b71:	68 2c 54 10 f0       	push   $0xf010542c
f0101b76:	68 26 52 10 f0       	push   $0xf0105226
f0101b7b:	68 54 03 00 00       	push   $0x354
f0101b80:	68 00 52 10 f0       	push   $0xf0105200
f0101b85:	e8 6f e5 ff ff       	call   f01000f9 <_panic>
	assert(pp0->pp_ref == 1);
f0101b8a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101b8f:	74 19                	je     f0101baa <mem_init+0x7f4>
f0101b91:	68 3d 54 10 f0       	push   $0xf010543d
f0101b96:	68 26 52 10 f0       	push   $0xf0105226
f0101b9b:	68 55 03 00 00       	push   $0x355
f0101ba0:	68 00 52 10 f0       	push   $0xf0105200
f0101ba5:	e8 4f e5 ff ff       	call   f01000f9 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101baa:	6a 02                	push   $0x2
f0101bac:	68 00 10 00 00       	push   $0x1000
f0101bb1:	53                   	push   %ebx
f0101bb2:	57                   	push   %edi
f0101bb3:	e8 98 f7 ff ff       	call   f0101350 <page_insert>
f0101bb8:	83 c4 10             	add    $0x10,%esp
f0101bbb:	85 c0                	test   %eax,%eax
f0101bbd:	74 19                	je     f0101bd8 <mem_init+0x822>
f0101bbf:	68 40 58 10 f0       	push   $0xf0105840
f0101bc4:	68 26 52 10 f0       	push   $0xf0105226
f0101bc9:	68 58 03 00 00       	push   $0x358
f0101bce:	68 00 52 10 f0       	push   $0xf0105200
f0101bd3:	e8 21 e5 ff ff       	call   f01000f9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bd8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bdd:	a1 08 de 17 f0       	mov    0xf017de08,%eax
f0101be2:	e8 f4 f0 ff ff       	call   f0100cdb <check_va2pa>
f0101be7:	89 da                	mov    %ebx,%edx
f0101be9:	2b 15 0c de 17 f0    	sub    0xf017de0c,%edx
f0101bef:	c1 fa 03             	sar    $0x3,%edx
f0101bf2:	c1 e2 0c             	shl    $0xc,%edx
f0101bf5:	39 d0                	cmp    %edx,%eax
f0101bf7:	74 19                	je     f0101c12 <mem_init+0x85c>
f0101bf9:	68 7c 58 10 f0       	push   $0xf010587c
f0101bfe:	68 26 52 10 f0       	push   $0xf0105226
f0101c03:	68 59 03 00 00       	push   $0x359
f0101c08:	68 00 52 10 f0       	push   $0xf0105200
f0101c0d:	e8 e7 e4 ff ff       	call   f01000f9 <_panic>
	assert(pp2->pp_ref == 1);
f0101c12:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c17:	74 19                	je     f0101c32 <mem_init+0x87c>
f0101c19:	68 4e 54 10 f0       	push   $0xf010544e
f0101c1e:	68 26 52 10 f0       	push   $0xf0105226
f0101c23:	68 5a 03 00 00       	push   $0x35a
f0101c28:	68 00 52 10 f0       	push   $0xf0105200
f0101c2d:	e8 c7 e4 ff ff       	call   f01000f9 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101c32:	83 ec 0c             	sub    $0xc,%esp
f0101c35:	6a 00                	push   $0x0
f0101c37:	e8 b0 f4 ff ff       	call   f01010ec <page_alloc>
f0101c3c:	83 c4 10             	add    $0x10,%esp
f0101c3f:	85 c0                	test   %eax,%eax
f0101c41:	74 19                	je     f0101c5c <mem_init+0x8a6>
f0101c43:	68 ca 53 10 f0       	push   $0xf01053ca
f0101c48:	68 26 52 10 f0       	push   $0xf0105226
f0101c4d:	68 5d 03 00 00       	push   $0x35d
f0101c52:	68 00 52 10 f0       	push   $0xf0105200
f0101c57:	e8 9d e4 ff ff       	call   f01000f9 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c5c:	6a 02                	push   $0x2
f0101c5e:	68 00 10 00 00       	push   $0x1000
f0101c63:	53                   	push   %ebx
f0101c64:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0101c6a:	e8 e1 f6 ff ff       	call   f0101350 <page_insert>
f0101c6f:	83 c4 10             	add    $0x10,%esp
f0101c72:	85 c0                	test   %eax,%eax
f0101c74:	74 19                	je     f0101c8f <mem_init+0x8d9>
f0101c76:	68 40 58 10 f0       	push   $0xf0105840
f0101c7b:	68 26 52 10 f0       	push   $0xf0105226
f0101c80:	68 60 03 00 00       	push   $0x360
f0101c85:	68 00 52 10 f0       	push   $0xf0105200
f0101c8a:	e8 6a e4 ff ff       	call   f01000f9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c8f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c94:	a1 08 de 17 f0       	mov    0xf017de08,%eax
f0101c99:	e8 3d f0 ff ff       	call   f0100cdb <check_va2pa>
f0101c9e:	89 da                	mov    %ebx,%edx
f0101ca0:	2b 15 0c de 17 f0    	sub    0xf017de0c,%edx
f0101ca6:	c1 fa 03             	sar    $0x3,%edx
f0101ca9:	c1 e2 0c             	shl    $0xc,%edx
f0101cac:	39 d0                	cmp    %edx,%eax
f0101cae:	74 19                	je     f0101cc9 <mem_init+0x913>
f0101cb0:	68 7c 58 10 f0       	push   $0xf010587c
f0101cb5:	68 26 52 10 f0       	push   $0xf0105226
f0101cba:	68 61 03 00 00       	push   $0x361
f0101cbf:	68 00 52 10 f0       	push   $0xf0105200
f0101cc4:	e8 30 e4 ff ff       	call   f01000f9 <_panic>
	assert(pp2->pp_ref == 1);
f0101cc9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cce:	74 19                	je     f0101ce9 <mem_init+0x933>
f0101cd0:	68 4e 54 10 f0       	push   $0xf010544e
f0101cd5:	68 26 52 10 f0       	push   $0xf0105226
f0101cda:	68 62 03 00 00       	push   $0x362
f0101cdf:	68 00 52 10 f0       	push   $0xf0105200
f0101ce4:	e8 10 e4 ff ff       	call   f01000f9 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ce9:	83 ec 0c             	sub    $0xc,%esp
f0101cec:	6a 00                	push   $0x0
f0101cee:	e8 f9 f3 ff ff       	call   f01010ec <page_alloc>
f0101cf3:	83 c4 10             	add    $0x10,%esp
f0101cf6:	85 c0                	test   %eax,%eax
f0101cf8:	74 19                	je     f0101d13 <mem_init+0x95d>
f0101cfa:	68 ca 53 10 f0       	push   $0xf01053ca
f0101cff:	68 26 52 10 f0       	push   $0xf0105226
f0101d04:	68 66 03 00 00       	push   $0x366
f0101d09:	68 00 52 10 f0       	push   $0xf0105200
f0101d0e:	e8 e6 e3 ff ff       	call   f01000f9 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101d13:	8b 15 08 de 17 f0    	mov    0xf017de08,%edx
f0101d19:	8b 02                	mov    (%edx),%eax
f0101d1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d20:	89 c1                	mov    %eax,%ecx
f0101d22:	c1 e9 0c             	shr    $0xc,%ecx
f0101d25:	3b 0d 04 de 17 f0    	cmp    0xf017de04,%ecx
f0101d2b:	72 15                	jb     f0101d42 <mem_init+0x98c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d2d:	50                   	push   %eax
f0101d2e:	68 74 55 10 f0       	push   $0xf0105574
f0101d33:	68 69 03 00 00       	push   $0x369
f0101d38:	68 00 52 10 f0       	push   $0xf0105200
f0101d3d:	e8 b7 e3 ff ff       	call   f01000f9 <_panic>
f0101d42:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d4a:	83 ec 04             	sub    $0x4,%esp
f0101d4d:	6a 00                	push   $0x0
f0101d4f:	68 00 10 00 00       	push   $0x1000
f0101d54:	52                   	push   %edx
f0101d55:	e8 32 f4 ff ff       	call   f010118c <pgdir_walk>
f0101d5a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101d5d:	8d 57 04             	lea    0x4(%edi),%edx
f0101d60:	83 c4 10             	add    $0x10,%esp
f0101d63:	39 d0                	cmp    %edx,%eax
f0101d65:	74 19                	je     f0101d80 <mem_init+0x9ca>
f0101d67:	68 ac 58 10 f0       	push   $0xf01058ac
f0101d6c:	68 26 52 10 f0       	push   $0xf0105226
f0101d71:	68 6a 03 00 00       	push   $0x36a
f0101d76:	68 00 52 10 f0       	push   $0xf0105200
f0101d7b:	e8 79 e3 ff ff       	call   f01000f9 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d80:	6a 06                	push   $0x6
f0101d82:	68 00 10 00 00       	push   $0x1000
f0101d87:	53                   	push   %ebx
f0101d88:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0101d8e:	e8 bd f5 ff ff       	call   f0101350 <page_insert>
f0101d93:	83 c4 10             	add    $0x10,%esp
f0101d96:	85 c0                	test   %eax,%eax
f0101d98:	74 19                	je     f0101db3 <mem_init+0x9fd>
f0101d9a:	68 ec 58 10 f0       	push   $0xf01058ec
f0101d9f:	68 26 52 10 f0       	push   $0xf0105226
f0101da4:	68 6d 03 00 00       	push   $0x36d
f0101da9:	68 00 52 10 f0       	push   $0xf0105200
f0101dae:	e8 46 e3 ff ff       	call   f01000f9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101db3:	8b 3d 08 de 17 f0    	mov    0xf017de08,%edi
f0101db9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dbe:	89 f8                	mov    %edi,%eax
f0101dc0:	e8 16 ef ff ff       	call   f0100cdb <check_va2pa>
f0101dc5:	89 da                	mov    %ebx,%edx
f0101dc7:	2b 15 0c de 17 f0    	sub    0xf017de0c,%edx
f0101dcd:	c1 fa 03             	sar    $0x3,%edx
f0101dd0:	c1 e2 0c             	shl    $0xc,%edx
f0101dd3:	39 d0                	cmp    %edx,%eax
f0101dd5:	74 19                	je     f0101df0 <mem_init+0xa3a>
f0101dd7:	68 7c 58 10 f0       	push   $0xf010587c
f0101ddc:	68 26 52 10 f0       	push   $0xf0105226
f0101de1:	68 6e 03 00 00       	push   $0x36e
f0101de6:	68 00 52 10 f0       	push   $0xf0105200
f0101deb:	e8 09 e3 ff ff       	call   f01000f9 <_panic>
	assert(pp2->pp_ref == 1);
f0101df0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101df5:	74 19                	je     f0101e10 <mem_init+0xa5a>
f0101df7:	68 4e 54 10 f0       	push   $0xf010544e
f0101dfc:	68 26 52 10 f0       	push   $0xf0105226
f0101e01:	68 6f 03 00 00       	push   $0x36f
f0101e06:	68 00 52 10 f0       	push   $0xf0105200
f0101e0b:	e8 e9 e2 ff ff       	call   f01000f9 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e10:	83 ec 04             	sub    $0x4,%esp
f0101e13:	6a 00                	push   $0x0
f0101e15:	68 00 10 00 00       	push   $0x1000
f0101e1a:	57                   	push   %edi
f0101e1b:	e8 6c f3 ff ff       	call   f010118c <pgdir_walk>
f0101e20:	83 c4 10             	add    $0x10,%esp
f0101e23:	f6 00 04             	testb  $0x4,(%eax)
f0101e26:	75 19                	jne    f0101e41 <mem_init+0xa8b>
f0101e28:	68 2c 59 10 f0       	push   $0xf010592c
f0101e2d:	68 26 52 10 f0       	push   $0xf0105226
f0101e32:	68 70 03 00 00       	push   $0x370
f0101e37:	68 00 52 10 f0       	push   $0xf0105200
f0101e3c:	e8 b8 e2 ff ff       	call   f01000f9 <_panic>
	cprintf("pp2 %x\n", pp2);
f0101e41:	83 ec 08             	sub    $0x8,%esp
f0101e44:	53                   	push   %ebx
f0101e45:	68 5f 54 10 f0       	push   $0xf010545f
f0101e4a:	e8 b1 14 00 00       	call   f0103300 <cprintf>
	cprintf("kern_pgdir %x\n", kern_pgdir);
f0101e4f:	83 c4 08             	add    $0x8,%esp
f0101e52:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0101e58:	68 67 54 10 f0       	push   $0xf0105467
f0101e5d:	e8 9e 14 00 00       	call   f0103300 <cprintf>
	cprintf("kern_pgdir[0] is %x\n", kern_pgdir[0]);
f0101e62:	83 c4 08             	add    $0x8,%esp
f0101e65:	a1 08 de 17 f0       	mov    0xf017de08,%eax
f0101e6a:	ff 30                	pushl  (%eax)
f0101e6c:	68 76 54 10 f0       	push   $0xf0105476
f0101e71:	e8 8a 14 00 00       	call   f0103300 <cprintf>
	assert(kern_pgdir[0] & PTE_U);
f0101e76:	a1 08 de 17 f0       	mov    0xf017de08,%eax
f0101e7b:	83 c4 10             	add    $0x10,%esp
f0101e7e:	f6 00 04             	testb  $0x4,(%eax)
f0101e81:	75 19                	jne    f0101e9c <mem_init+0xae6>
f0101e83:	68 8b 54 10 f0       	push   $0xf010548b
f0101e88:	68 26 52 10 f0       	push   $0xf0105226
f0101e8d:	68 74 03 00 00       	push   $0x374
f0101e92:	68 00 52 10 f0       	push   $0xf0105200
f0101e97:	e8 5d e2 ff ff       	call   f01000f9 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e9c:	6a 02                	push   $0x2
f0101e9e:	68 00 10 00 00       	push   $0x1000
f0101ea3:	53                   	push   %ebx
f0101ea4:	50                   	push   %eax
f0101ea5:	e8 a6 f4 ff ff       	call   f0101350 <page_insert>
f0101eaa:	83 c4 10             	add    $0x10,%esp
f0101ead:	85 c0                	test   %eax,%eax
f0101eaf:	74 19                	je     f0101eca <mem_init+0xb14>
f0101eb1:	68 40 58 10 f0       	push   $0xf0105840
f0101eb6:	68 26 52 10 f0       	push   $0xf0105226
f0101ebb:	68 77 03 00 00       	push   $0x377
f0101ec0:	68 00 52 10 f0       	push   $0xf0105200
f0101ec5:	e8 2f e2 ff ff       	call   f01000f9 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101eca:	83 ec 04             	sub    $0x4,%esp
f0101ecd:	6a 00                	push   $0x0
f0101ecf:	68 00 10 00 00       	push   $0x1000
f0101ed4:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0101eda:	e8 ad f2 ff ff       	call   f010118c <pgdir_walk>
f0101edf:	83 c4 10             	add    $0x10,%esp
f0101ee2:	f6 00 02             	testb  $0x2,(%eax)
f0101ee5:	75 19                	jne    f0101f00 <mem_init+0xb4a>
f0101ee7:	68 60 59 10 f0       	push   $0xf0105960
f0101eec:	68 26 52 10 f0       	push   $0xf0105226
f0101ef1:	68 78 03 00 00       	push   $0x378
f0101ef6:	68 00 52 10 f0       	push   $0xf0105200
f0101efb:	e8 f9 e1 ff ff       	call   f01000f9 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f00:	83 ec 04             	sub    $0x4,%esp
f0101f03:	6a 00                	push   $0x0
f0101f05:	68 00 10 00 00       	push   $0x1000
f0101f0a:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0101f10:	e8 77 f2 ff ff       	call   f010118c <pgdir_walk>
f0101f15:	83 c4 10             	add    $0x10,%esp
f0101f18:	f6 00 04             	testb  $0x4,(%eax)
f0101f1b:	74 19                	je     f0101f36 <mem_init+0xb80>
f0101f1d:	68 94 59 10 f0       	push   $0xf0105994
f0101f22:	68 26 52 10 f0       	push   $0xf0105226
f0101f27:	68 79 03 00 00       	push   $0x379
f0101f2c:	68 00 52 10 f0       	push   $0xf0105200
f0101f31:	e8 c3 e1 ff ff       	call   f01000f9 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f36:	6a 02                	push   $0x2
f0101f38:	68 00 00 40 00       	push   $0x400000
f0101f3d:	56                   	push   %esi
f0101f3e:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0101f44:	e8 07 f4 ff ff       	call   f0101350 <page_insert>
f0101f49:	83 c4 10             	add    $0x10,%esp
f0101f4c:	85 c0                	test   %eax,%eax
f0101f4e:	78 19                	js     f0101f69 <mem_init+0xbb3>
f0101f50:	68 cc 59 10 f0       	push   $0xf01059cc
f0101f55:	68 26 52 10 f0       	push   $0xf0105226
f0101f5a:	68 7c 03 00 00       	push   $0x37c
f0101f5f:	68 00 52 10 f0       	push   $0xf0105200
f0101f64:	e8 90 e1 ff ff       	call   f01000f9 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f69:	6a 02                	push   $0x2
f0101f6b:	68 00 10 00 00       	push   $0x1000
f0101f70:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101f73:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0101f79:	e8 d2 f3 ff ff       	call   f0101350 <page_insert>
f0101f7e:	83 c4 10             	add    $0x10,%esp
f0101f81:	85 c0                	test   %eax,%eax
f0101f83:	74 19                	je     f0101f9e <mem_init+0xbe8>
f0101f85:	68 04 5a 10 f0       	push   $0xf0105a04
f0101f8a:	68 26 52 10 f0       	push   $0xf0105226
f0101f8f:	68 7f 03 00 00       	push   $0x37f
f0101f94:	68 00 52 10 f0       	push   $0xf0105200
f0101f99:	e8 5b e1 ff ff       	call   f01000f9 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f9e:	83 ec 04             	sub    $0x4,%esp
f0101fa1:	6a 00                	push   $0x0
f0101fa3:	68 00 10 00 00       	push   $0x1000
f0101fa8:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0101fae:	e8 d9 f1 ff ff       	call   f010118c <pgdir_walk>
f0101fb3:	83 c4 10             	add    $0x10,%esp
f0101fb6:	f6 00 04             	testb  $0x4,(%eax)
f0101fb9:	74 19                	je     f0101fd4 <mem_init+0xc1e>
f0101fbb:	68 94 59 10 f0       	push   $0xf0105994
f0101fc0:	68 26 52 10 f0       	push   $0xf0105226
f0101fc5:	68 80 03 00 00       	push   $0x380
f0101fca:	68 00 52 10 f0       	push   $0xf0105200
f0101fcf:	e8 25 e1 ff ff       	call   f01000f9 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101fd4:	8b 3d 08 de 17 f0    	mov    0xf017de08,%edi
f0101fda:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fdf:	89 f8                	mov    %edi,%eax
f0101fe1:	e8 f5 ec ff ff       	call   f0100cdb <check_va2pa>
f0101fe6:	89 c1                	mov    %eax,%ecx
f0101fe8:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101feb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fee:	2b 05 0c de 17 f0    	sub    0xf017de0c,%eax
f0101ff4:	c1 f8 03             	sar    $0x3,%eax
f0101ff7:	c1 e0 0c             	shl    $0xc,%eax
f0101ffa:	39 c1                	cmp    %eax,%ecx
f0101ffc:	74 19                	je     f0102017 <mem_init+0xc61>
f0101ffe:	68 40 5a 10 f0       	push   $0xf0105a40
f0102003:	68 26 52 10 f0       	push   $0xf0105226
f0102008:	68 83 03 00 00       	push   $0x383
f010200d:	68 00 52 10 f0       	push   $0xf0105200
f0102012:	e8 e2 e0 ff ff       	call   f01000f9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102017:	ba 00 10 00 00       	mov    $0x1000,%edx
f010201c:	89 f8                	mov    %edi,%eax
f010201e:	e8 b8 ec ff ff       	call   f0100cdb <check_va2pa>
f0102023:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0102026:	74 19                	je     f0102041 <mem_init+0xc8b>
f0102028:	68 6c 5a 10 f0       	push   $0xf0105a6c
f010202d:	68 26 52 10 f0       	push   $0xf0105226
f0102032:	68 84 03 00 00       	push   $0x384
f0102037:	68 00 52 10 f0       	push   $0xf0105200
f010203c:	e8 b8 e0 ff ff       	call   f01000f9 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102041:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102044:	66 83 78 04 02       	cmpw   $0x2,0x4(%eax)
f0102049:	74 19                	je     f0102064 <mem_init+0xcae>
f010204b:	68 a1 54 10 f0       	push   $0xf01054a1
f0102050:	68 26 52 10 f0       	push   $0xf0105226
f0102055:	68 86 03 00 00       	push   $0x386
f010205a:	68 00 52 10 f0       	push   $0xf0105200
f010205f:	e8 95 e0 ff ff       	call   f01000f9 <_panic>
	assert(pp2->pp_ref == 0);
f0102064:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102069:	74 19                	je     f0102084 <mem_init+0xcce>
f010206b:	68 b2 54 10 f0       	push   $0xf01054b2
f0102070:	68 26 52 10 f0       	push   $0xf0105226
f0102075:	68 87 03 00 00       	push   $0x387
f010207a:	68 00 52 10 f0       	push   $0xf0105200
f010207f:	e8 75 e0 ff ff       	call   f01000f9 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102084:	83 ec 0c             	sub    $0xc,%esp
f0102087:	6a 00                	push   $0x0
f0102089:	e8 5e f0 ff ff       	call   f01010ec <page_alloc>
f010208e:	83 c4 10             	add    $0x10,%esp
f0102091:	85 c0                	test   %eax,%eax
f0102093:	74 04                	je     f0102099 <mem_init+0xce3>
f0102095:	39 c3                	cmp    %eax,%ebx
f0102097:	74 19                	je     f01020b2 <mem_init+0xcfc>
f0102099:	68 9c 5a 10 f0       	push   $0xf0105a9c
f010209e:	68 26 52 10 f0       	push   $0xf0105226
f01020a3:	68 8a 03 00 00       	push   $0x38a
f01020a8:	68 00 52 10 f0       	push   $0xf0105200
f01020ad:	e8 47 e0 ff ff       	call   f01000f9 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020b2:	83 ec 08             	sub    $0x8,%esp
f01020b5:	6a 00                	push   $0x0
f01020b7:	ff 35 08 de 17 f0    	pushl  0xf017de08
f01020bd:	e8 4b f2 ff ff       	call   f010130d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020c2:	8b 3d 08 de 17 f0    	mov    0xf017de08,%edi
f01020c8:	ba 00 00 00 00       	mov    $0x0,%edx
f01020cd:	89 f8                	mov    %edi,%eax
f01020cf:	e8 07 ec ff ff       	call   f0100cdb <check_va2pa>
f01020d4:	83 c4 10             	add    $0x10,%esp
f01020d7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020da:	74 19                	je     f01020f5 <mem_init+0xd3f>
f01020dc:	68 c0 5a 10 f0       	push   $0xf0105ac0
f01020e1:	68 26 52 10 f0       	push   $0xf0105226
f01020e6:	68 8e 03 00 00       	push   $0x38e
f01020eb:	68 00 52 10 f0       	push   $0xf0105200
f01020f0:	e8 04 e0 ff ff       	call   f01000f9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01020f5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020fa:	89 f8                	mov    %edi,%eax
f01020fc:	e8 da eb ff ff       	call   f0100cdb <check_va2pa>
f0102101:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102104:	2b 15 0c de 17 f0    	sub    0xf017de0c,%edx
f010210a:	c1 fa 03             	sar    $0x3,%edx
f010210d:	c1 e2 0c             	shl    $0xc,%edx
f0102110:	39 d0                	cmp    %edx,%eax
f0102112:	74 19                	je     f010212d <mem_init+0xd77>
f0102114:	68 6c 5a 10 f0       	push   $0xf0105a6c
f0102119:	68 26 52 10 f0       	push   $0xf0105226
f010211e:	68 8f 03 00 00       	push   $0x38f
f0102123:	68 00 52 10 f0       	push   $0xf0105200
f0102128:	e8 cc df ff ff       	call   f01000f9 <_panic>
	assert(pp1->pp_ref == 1);
f010212d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102130:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102135:	74 19                	je     f0102150 <mem_init+0xd9a>
f0102137:	68 2c 54 10 f0       	push   $0xf010542c
f010213c:	68 26 52 10 f0       	push   $0xf0105226
f0102141:	68 90 03 00 00       	push   $0x390
f0102146:	68 00 52 10 f0       	push   $0xf0105200
f010214b:	e8 a9 df ff ff       	call   f01000f9 <_panic>
	assert(pp2->pp_ref == 0);
f0102150:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102155:	74 19                	je     f0102170 <mem_init+0xdba>
f0102157:	68 b2 54 10 f0       	push   $0xf01054b2
f010215c:	68 26 52 10 f0       	push   $0xf0105226
f0102161:	68 91 03 00 00       	push   $0x391
f0102166:	68 00 52 10 f0       	push   $0xf0105200
f010216b:	e8 89 df ff ff       	call   f01000f9 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102170:	83 ec 08             	sub    $0x8,%esp
f0102173:	68 00 10 00 00       	push   $0x1000
f0102178:	57                   	push   %edi
f0102179:	e8 8f f1 ff ff       	call   f010130d <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010217e:	8b 3d 08 de 17 f0    	mov    0xf017de08,%edi
f0102184:	ba 00 00 00 00       	mov    $0x0,%edx
f0102189:	89 f8                	mov    %edi,%eax
f010218b:	e8 4b eb ff ff       	call   f0100cdb <check_va2pa>
f0102190:	83 c4 10             	add    $0x10,%esp
f0102193:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102196:	74 19                	je     f01021b1 <mem_init+0xdfb>
f0102198:	68 c0 5a 10 f0       	push   $0xf0105ac0
f010219d:	68 26 52 10 f0       	push   $0xf0105226
f01021a2:	68 95 03 00 00       	push   $0x395
f01021a7:	68 00 52 10 f0       	push   $0xf0105200
f01021ac:	e8 48 df ff ff       	call   f01000f9 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01021b1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021b6:	89 f8                	mov    %edi,%eax
f01021b8:	e8 1e eb ff ff       	call   f0100cdb <check_va2pa>
f01021bd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021c0:	74 19                	je     f01021db <mem_init+0xe25>
f01021c2:	68 e4 5a 10 f0       	push   $0xf0105ae4
f01021c7:	68 26 52 10 f0       	push   $0xf0105226
f01021cc:	68 96 03 00 00       	push   $0x396
f01021d1:	68 00 52 10 f0       	push   $0xf0105200
f01021d6:	e8 1e df ff ff       	call   f01000f9 <_panic>
	assert(pp1->pp_ref == 0);
f01021db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021de:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f01021e3:	74 19                	je     f01021fe <mem_init+0xe48>
f01021e5:	68 c3 54 10 f0       	push   $0xf01054c3
f01021ea:	68 26 52 10 f0       	push   $0xf0105226
f01021ef:	68 97 03 00 00       	push   $0x397
f01021f4:	68 00 52 10 f0       	push   $0xf0105200
f01021f9:	e8 fb de ff ff       	call   f01000f9 <_panic>
	assert(pp2->pp_ref == 0);
f01021fe:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102203:	74 19                	je     f010221e <mem_init+0xe68>
f0102205:	68 b2 54 10 f0       	push   $0xf01054b2
f010220a:	68 26 52 10 f0       	push   $0xf0105226
f010220f:	68 98 03 00 00       	push   $0x398
f0102214:	68 00 52 10 f0       	push   $0xf0105200
f0102219:	e8 db de ff ff       	call   f01000f9 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010221e:	83 ec 0c             	sub    $0xc,%esp
f0102221:	6a 00                	push   $0x0
f0102223:	e8 c4 ee ff ff       	call   f01010ec <page_alloc>
f0102228:	83 c4 10             	add    $0x10,%esp
f010222b:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010222e:	75 04                	jne    f0102234 <mem_init+0xe7e>
f0102230:	85 c0                	test   %eax,%eax
f0102232:	75 19                	jne    f010224d <mem_init+0xe97>
f0102234:	68 0c 5b 10 f0       	push   $0xf0105b0c
f0102239:	68 26 52 10 f0       	push   $0xf0105226
f010223e:	68 9b 03 00 00       	push   $0x39b
f0102243:	68 00 52 10 f0       	push   $0xf0105200
f0102248:	e8 ac de ff ff       	call   f01000f9 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010224d:	83 ec 0c             	sub    $0xc,%esp
f0102250:	6a 00                	push   $0x0
f0102252:	e8 95 ee ff ff       	call   f01010ec <page_alloc>
f0102257:	83 c4 10             	add    $0x10,%esp
f010225a:	85 c0                	test   %eax,%eax
f010225c:	74 19                	je     f0102277 <mem_init+0xec1>
f010225e:	68 ca 53 10 f0       	push   $0xf01053ca
f0102263:	68 26 52 10 f0       	push   $0xf0105226
f0102268:	68 9e 03 00 00       	push   $0x39e
f010226d:	68 00 52 10 f0       	push   $0xf0105200
f0102272:	e8 82 de ff ff       	call   f01000f9 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102277:	8b 0d 08 de 17 f0    	mov    0xf017de08,%ecx
f010227d:	8b 11                	mov    (%ecx),%edx
f010227f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102285:	89 f0                	mov    %esi,%eax
f0102287:	2b 05 0c de 17 f0    	sub    0xf017de0c,%eax
f010228d:	c1 f8 03             	sar    $0x3,%eax
f0102290:	c1 e0 0c             	shl    $0xc,%eax
f0102293:	39 c2                	cmp    %eax,%edx
f0102295:	74 19                	je     f01022b0 <mem_init+0xefa>
f0102297:	68 e8 57 10 f0       	push   $0xf01057e8
f010229c:	68 26 52 10 f0       	push   $0xf0105226
f01022a1:	68 a1 03 00 00       	push   $0x3a1
f01022a6:	68 00 52 10 f0       	push   $0xf0105200
f01022ab:	e8 49 de ff ff       	call   f01000f9 <_panic>
	kern_pgdir[0] = 0;
f01022b0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01022b6:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01022bb:	74 19                	je     f01022d6 <mem_init+0xf20>
f01022bd:	68 3d 54 10 f0       	push   $0xf010543d
f01022c2:	68 26 52 10 f0       	push   $0xf0105226
f01022c7:	68 a3 03 00 00       	push   $0x3a3
f01022cc:	68 00 52 10 f0       	push   $0xf0105200
f01022d1:	e8 23 de ff ff       	call   f01000f9 <_panic>
	pp0->pp_ref = 0;
f01022d6:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01022dc:	83 ec 0c             	sub    $0xc,%esp
f01022df:	56                   	push   %esi
f01022e0:	e8 71 ee ff ff       	call   f0101156 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01022e5:	83 c4 0c             	add    $0xc,%esp
f01022e8:	6a 01                	push   $0x1
f01022ea:	68 00 10 40 00       	push   $0x401000
f01022ef:	ff 35 08 de 17 f0    	pushl  0xf017de08
f01022f5:	e8 92 ee ff ff       	call   f010118c <pgdir_walk>
f01022fa:	89 c7                	mov    %eax,%edi
f01022fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01022ff:	a1 08 de 17 f0       	mov    0xf017de08,%eax
f0102304:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102307:	8b 40 04             	mov    0x4(%eax),%eax
f010230a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010230f:	8b 0d 04 de 17 f0    	mov    0xf017de04,%ecx
f0102315:	89 c2                	mov    %eax,%edx
f0102317:	c1 ea 0c             	shr    $0xc,%edx
f010231a:	83 c4 10             	add    $0x10,%esp
f010231d:	39 ca                	cmp    %ecx,%edx
f010231f:	72 15                	jb     f0102336 <mem_init+0xf80>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102321:	50                   	push   %eax
f0102322:	68 74 55 10 f0       	push   $0xf0105574
f0102327:	68 aa 03 00 00       	push   $0x3aa
f010232c:	68 00 52 10 f0       	push   $0xf0105200
f0102331:	e8 c3 dd ff ff       	call   f01000f9 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102336:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010233b:	39 c7                	cmp    %eax,%edi
f010233d:	74 19                	je     f0102358 <mem_init+0xfa2>
f010233f:	68 d4 54 10 f0       	push   $0xf01054d4
f0102344:	68 26 52 10 f0       	push   $0xf0105226
f0102349:	68 ab 03 00 00       	push   $0x3ab
f010234e:	68 00 52 10 f0       	push   $0xf0105200
f0102353:	e8 a1 dd ff ff       	call   f01000f9 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102358:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010235b:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102362:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102368:	89 f0                	mov    %esi,%eax
f010236a:	2b 05 0c de 17 f0    	sub    0xf017de0c,%eax
f0102370:	c1 f8 03             	sar    $0x3,%eax
f0102373:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102376:	89 c2                	mov    %eax,%edx
f0102378:	c1 ea 0c             	shr    $0xc,%edx
f010237b:	39 d1                	cmp    %edx,%ecx
f010237d:	77 12                	ja     f0102391 <mem_init+0xfdb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010237f:	50                   	push   %eax
f0102380:	68 74 55 10 f0       	push   $0xf0105574
f0102385:	6a 56                	push   $0x56
f0102387:	68 0c 52 10 f0       	push   $0xf010520c
f010238c:	e8 68 dd ff ff       	call   f01000f9 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102391:	83 ec 04             	sub    $0x4,%esp
f0102394:	68 00 10 00 00       	push   $0x1000
f0102399:	68 ff 00 00 00       	push   $0xff
f010239e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023a3:	50                   	push   %eax
f01023a4:	e8 a1 22 00 00       	call   f010464a <memset>
	page_free(pp0);
f01023a9:	89 34 24             	mov    %esi,(%esp)
f01023ac:	e8 a5 ed ff ff       	call   f0101156 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01023b1:	83 c4 0c             	add    $0xc,%esp
f01023b4:	6a 01                	push   $0x1
f01023b6:	6a 00                	push   $0x0
f01023b8:	ff 35 08 de 17 f0    	pushl  0xf017de08
f01023be:	e8 c9 ed ff ff       	call   f010118c <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023c3:	89 f2                	mov    %esi,%edx
f01023c5:	2b 15 0c de 17 f0    	sub    0xf017de0c,%edx
f01023cb:	c1 fa 03             	sar    $0x3,%edx
f01023ce:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023d1:	89 d0                	mov    %edx,%eax
f01023d3:	c1 e8 0c             	shr    $0xc,%eax
f01023d6:	83 c4 10             	add    $0x10,%esp
f01023d9:	3b 05 04 de 17 f0    	cmp    0xf017de04,%eax
f01023df:	72 12                	jb     f01023f3 <mem_init+0x103d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023e1:	52                   	push   %edx
f01023e2:	68 74 55 10 f0       	push   $0xf0105574
f01023e7:	6a 56                	push   $0x56
f01023e9:	68 0c 52 10 f0       	push   $0xf010520c
f01023ee:	e8 06 dd ff ff       	call   f01000f9 <_panic>
	return (void *)(pa + KERNBASE);
f01023f3:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01023f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01023fc:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102402:	f6 00 01             	testb  $0x1,(%eax)
f0102405:	74 19                	je     f0102420 <mem_init+0x106a>
f0102407:	68 ec 54 10 f0       	push   $0xf01054ec
f010240c:	68 26 52 10 f0       	push   $0xf0105226
f0102411:	68 b5 03 00 00       	push   $0x3b5
f0102416:	68 00 52 10 f0       	push   $0xf0105200
f010241b:	e8 d9 dc ff ff       	call   f01000f9 <_panic>
f0102420:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102423:	39 c2                	cmp    %eax,%edx
f0102425:	75 db                	jne    f0102402 <mem_init+0x104c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102427:	a1 08 de 17 f0       	mov    0xf017de08,%eax
f010242c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102432:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102438:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010243b:	a3 40 d1 17 f0       	mov    %eax,0xf017d140

	// free the pages we took
	page_free(pp0);
f0102440:	83 ec 0c             	sub    $0xc,%esp
f0102443:	56                   	push   %esi
f0102444:	e8 0d ed ff ff       	call   f0101156 <page_free>
	page_free(pp1);
f0102449:	83 c4 04             	add    $0x4,%esp
f010244c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010244f:	e8 02 ed ff ff       	call   f0101156 <page_free>
	page_free(pp2);
f0102454:	89 1c 24             	mov    %ebx,(%esp)
f0102457:	e8 fa ec ff ff       	call   f0101156 <page_free>

	cprintf("check_page() succeeded!\n");
f010245c:	c7 04 24 03 55 10 f0 	movl   $0xf0105503,(%esp)
f0102463:	e8 98 0e 00 00       	call   f0103300 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f0102468:	a1 0c de 17 f0       	mov    0xf017de0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010246d:	83 c4 10             	add    $0x10,%esp
f0102470:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102475:	77 15                	ja     f010248c <mem_init+0x10d6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102477:	50                   	push   %eax
f0102478:	68 ec 56 10 f0       	push   $0xf01056ec
f010247d:	68 c0 00 00 00       	push   $0xc0
f0102482:	68 00 52 10 f0       	push   $0xf0105200
f0102487:	e8 6d dc ff ff       	call   f01000f9 <_panic>
f010248c:	83 ec 08             	sub    $0x8,%esp
f010248f:	6a 04                	push   $0x4
f0102491:	05 00 00 00 10       	add    $0x10000000,%eax
f0102496:	50                   	push   %eax
f0102497:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010249c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01024a1:	a1 08 de 17 f0       	mov    0xf017de08,%eax
f01024a6:	e8 74 ed ff ff       	call   f010121f <boot_map_region>
		UPAGES, 
		PTSIZE, 
		PADDR(pages), 
		PTE_U);
	cprintf("PADDR(pages) %x\n", PADDR(pages));
f01024ab:	a1 0c de 17 f0       	mov    0xf017de0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01024b0:	83 c4 10             	add    $0x10,%esp
f01024b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024b8:	77 15                	ja     f01024cf <mem_init+0x1119>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024ba:	50                   	push   %eax
f01024bb:	68 ec 56 10 f0       	push   $0xf01056ec
f01024c0:	68 c2 00 00 00       	push   $0xc2
f01024c5:	68 00 52 10 f0       	push   $0xf0105200
f01024ca:	e8 2a dc ff ff       	call   f01000f9 <_panic>
f01024cf:	83 ec 08             	sub    $0x8,%esp
f01024d2:	05 00 00 00 10       	add    $0x10000000,%eax
f01024d7:	50                   	push   %eax
f01024d8:	68 1c 55 10 f0       	push   $0xf010551c
f01024dd:	e8 1e 0e 00 00       	call   f0103300 <cprintf>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,
f01024e2:	a1 4c d1 17 f0       	mov    0xf017d14c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01024e7:	83 c4 10             	add    $0x10,%esp
f01024ea:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024ef:	77 15                	ja     f0102506 <mem_init+0x1150>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024f1:	50                   	push   %eax
f01024f2:	68 ec 56 10 f0       	push   $0xf01056ec
f01024f7:	68 cd 00 00 00       	push   $0xcd
f01024fc:	68 00 52 10 f0       	push   $0xf0105200
f0102501:	e8 f3 db ff ff       	call   f01000f9 <_panic>
f0102506:	83 ec 08             	sub    $0x8,%esp
f0102509:	6a 04                	push   $0x4
f010250b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102510:	50                   	push   %eax
f0102511:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102516:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010251b:	a1 08 de 17 f0       	mov    0xf017de08,%eax
f0102520:	e8 fa ec ff ff       	call   f010121f <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102525:	83 c4 10             	add    $0x10,%esp
f0102528:	b8 00 10 11 f0       	mov    $0xf0111000,%eax
f010252d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102532:	77 15                	ja     f0102549 <mem_init+0x1193>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102534:	50                   	push   %eax
f0102535:	68 ec 56 10 f0       	push   $0xf01056ec
f010253a:	68 df 00 00 00       	push   $0xdf
f010253f:	68 00 52 10 f0       	push   $0xf0105200
f0102544:	e8 b0 db ff ff       	call   f01000f9 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102549:	83 ec 08             	sub    $0x8,%esp
f010254c:	6a 02                	push   $0x2
f010254e:	68 00 10 11 00       	push   $0x111000
f0102553:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102558:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010255d:	a1 08 de 17 f0       	mov    0xf017de08,%eax
f0102562:	e8 b8 ec ff ff       	call   f010121f <boot_map_region>
		KSTACKTOP-KSTKSIZE, 
		KSTKSIZE, 
		PADDR(bootstack), 
		PTE_W);
	cprintf("PADDR(bootstack) %x\n", PADDR(bootstack));
f0102567:	83 c4 08             	add    $0x8,%esp
f010256a:	68 00 10 11 00       	push   $0x111000
f010256f:	68 2d 55 10 f0       	push   $0xf010552d
f0102574:	e8 87 0d 00 00       	call   f0103300 <cprintf>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, 
f0102579:	83 c4 08             	add    $0x8,%esp
f010257c:	6a 02                	push   $0x2
f010257e:	6a 00                	push   $0x0
f0102580:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102585:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010258a:	a1 08 de 17 f0       	mov    0xf017de08,%eax
f010258f:	e8 8b ec ff ff       	call   f010121f <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102594:	8b 1d 08 de 17 f0    	mov    0xf017de08,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010259a:	a1 04 de 17 f0       	mov    0xf017de04,%eax
f010259f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01025a2:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01025a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01025ae:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01025b1:	8b 3d 0c de 17 f0    	mov    0xf017de0c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025b7:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01025ba:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01025bd:	be 00 00 00 00       	mov    $0x0,%esi
f01025c2:	eb 55                	jmp    f0102619 <mem_init+0x1263>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01025c4:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01025ca:	89 d8                	mov    %ebx,%eax
f01025cc:	e8 0a e7 ff ff       	call   f0100cdb <check_va2pa>
f01025d1:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01025d8:	77 15                	ja     f01025ef <mem_init+0x1239>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025da:	57                   	push   %edi
f01025db:	68 ec 56 10 f0       	push   $0xf01056ec
f01025e0:	68 f4 02 00 00       	push   $0x2f4
f01025e5:	68 00 52 10 f0       	push   $0xf0105200
f01025ea:	e8 0a db ff ff       	call   f01000f9 <_panic>
f01025ef:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f01025f6:	39 d0                	cmp    %edx,%eax
f01025f8:	74 19                	je     f0102613 <mem_init+0x125d>
f01025fa:	68 30 5b 10 f0       	push   $0xf0105b30
f01025ff:	68 26 52 10 f0       	push   $0xf0105226
f0102604:	68 f4 02 00 00       	push   $0x2f4
f0102609:	68 00 52 10 f0       	push   $0xf0105200
f010260e:	e8 e6 da ff ff       	call   f01000f9 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102613:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102619:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f010261c:	77 a6                	ja     f01025c4 <mem_init+0x120e>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010261e:	8b 3d 4c d1 17 f0    	mov    0xf017d14c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102624:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102627:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f010262c:	89 f2                	mov    %esi,%edx
f010262e:	89 d8                	mov    %ebx,%eax
f0102630:	e8 a6 e6 ff ff       	call   f0100cdb <check_va2pa>
f0102635:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f010263c:	77 15                	ja     f0102653 <mem_init+0x129d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010263e:	57                   	push   %edi
f010263f:	68 ec 56 10 f0       	push   $0xf01056ec
f0102644:	68 f9 02 00 00       	push   $0x2f9
f0102649:	68 00 52 10 f0       	push   $0xf0105200
f010264e:	e8 a6 da ff ff       	call   f01000f9 <_panic>
f0102653:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f010265a:	39 c2                	cmp    %eax,%edx
f010265c:	74 19                	je     f0102677 <mem_init+0x12c1>
f010265e:	68 64 5b 10 f0       	push   $0xf0105b64
f0102663:	68 26 52 10 f0       	push   $0xf0105226
f0102668:	68 f9 02 00 00       	push   $0x2f9
f010266d:	68 00 52 10 f0       	push   $0xf0105200
f0102672:	e8 82 da ff ff       	call   f01000f9 <_panic>
f0102677:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010267d:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f0102683:	75 a7                	jne    f010262c <mem_init+0x1276>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102685:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102688:	c1 e7 0c             	shl    $0xc,%edi
f010268b:	be 00 00 00 00       	mov    $0x0,%esi
f0102690:	eb 30                	jmp    f01026c2 <mem_init+0x130c>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102692:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0102698:	89 d8                	mov    %ebx,%eax
f010269a:	e8 3c e6 ff ff       	call   f0100cdb <check_va2pa>
f010269f:	39 c6                	cmp    %eax,%esi
f01026a1:	74 19                	je     f01026bc <mem_init+0x1306>
f01026a3:	68 98 5b 10 f0       	push   $0xf0105b98
f01026a8:	68 26 52 10 f0       	push   $0xf0105226
f01026ad:	68 fd 02 00 00       	push   $0x2fd
f01026b2:	68 00 52 10 f0       	push   $0xf0105200
f01026b7:	e8 3d da ff ff       	call   f01000f9 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01026bc:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01026c2:	39 fe                	cmp    %edi,%esi
f01026c4:	72 cc                	jb     f0102692 <mem_init+0x12dc>
f01026c6:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01026cb:	89 f2                	mov    %esi,%edx
f01026cd:	89 d8                	mov    %ebx,%eax
f01026cf:	e8 07 e6 ff ff       	call   f0100cdb <check_va2pa>
f01026d4:	8d 96 00 90 11 10    	lea    0x10119000(%esi),%edx
f01026da:	39 c2                	cmp    %eax,%edx
f01026dc:	74 19                	je     f01026f7 <mem_init+0x1341>
f01026de:	68 c0 5b 10 f0       	push   $0xf0105bc0
f01026e3:	68 26 52 10 f0       	push   $0xf0105226
f01026e8:	68 01 03 00 00       	push   $0x301
f01026ed:	68 00 52 10 f0       	push   $0xf0105200
f01026f2:	e8 02 da ff ff       	call   f01000f9 <_panic>
f01026f7:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01026fd:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102703:	75 c6                	jne    f01026cb <mem_init+0x1315>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102705:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010270a:	89 d8                	mov    %ebx,%eax
f010270c:	e8 ca e5 ff ff       	call   f0100cdb <check_va2pa>
f0102711:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102714:	74 51                	je     f0102767 <mem_init+0x13b1>
f0102716:	68 08 5c 10 f0       	push   $0xf0105c08
f010271b:	68 26 52 10 f0       	push   $0xf0105226
f0102720:	68 02 03 00 00       	push   $0x302
f0102725:	68 00 52 10 f0       	push   $0xf0105200
f010272a:	e8 ca d9 ff ff       	call   f01000f9 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010272f:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102734:	72 36                	jb     f010276c <mem_init+0x13b6>
f0102736:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010273b:	76 07                	jbe    f0102744 <mem_init+0x138e>
f010273d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102742:	75 28                	jne    f010276c <mem_init+0x13b6>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102744:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102748:	0f 85 83 00 00 00    	jne    f01027d1 <mem_init+0x141b>
f010274e:	68 42 55 10 f0       	push   $0xf0105542
f0102753:	68 26 52 10 f0       	push   $0xf0105226
f0102758:	68 0b 03 00 00       	push   $0x30b
f010275d:	68 00 52 10 f0       	push   $0xf0105200
f0102762:	e8 92 d9 ff ff       	call   f01000f9 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102767:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010276c:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102771:	76 3f                	jbe    f01027b2 <mem_init+0x13fc>
				assert(pgdir[i] & PTE_P);
f0102773:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102776:	f6 c2 01             	test   $0x1,%dl
f0102779:	75 19                	jne    f0102794 <mem_init+0x13de>
f010277b:	68 42 55 10 f0       	push   $0xf0105542
f0102780:	68 26 52 10 f0       	push   $0xf0105226
f0102785:	68 0f 03 00 00       	push   $0x30f
f010278a:	68 00 52 10 f0       	push   $0xf0105200
f010278f:	e8 65 d9 ff ff       	call   f01000f9 <_panic>
				assert(pgdir[i] & PTE_W);
f0102794:	f6 c2 02             	test   $0x2,%dl
f0102797:	75 38                	jne    f01027d1 <mem_init+0x141b>
f0102799:	68 53 55 10 f0       	push   $0xf0105553
f010279e:	68 26 52 10 f0       	push   $0xf0105226
f01027a3:	68 10 03 00 00       	push   $0x310
f01027a8:	68 00 52 10 f0       	push   $0xf0105200
f01027ad:	e8 47 d9 ff ff       	call   f01000f9 <_panic>
			} else
				assert(pgdir[i] == 0);
f01027b2:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01027b6:	74 19                	je     f01027d1 <mem_init+0x141b>
f01027b8:	68 64 55 10 f0       	push   $0xf0105564
f01027bd:	68 26 52 10 f0       	push   $0xf0105226
f01027c2:	68 12 03 00 00       	push   $0x312
f01027c7:	68 00 52 10 f0       	push   $0xf0105200
f01027cc:	e8 28 d9 ff ff       	call   f01000f9 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01027d1:	83 c0 01             	add    $0x1,%eax
f01027d4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01027d9:	0f 86 50 ff ff ff    	jbe    f010272f <mem_init+0x1379>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01027df:	83 ec 0c             	sub    $0xc,%esp
f01027e2:	68 38 5c 10 f0       	push   $0xf0105c38
f01027e7:	e8 14 0b 00 00       	call   f0103300 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01027ec:	a1 08 de 17 f0       	mov    0xf017de08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027f1:	83 c4 10             	add    $0x10,%esp
f01027f4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027f9:	77 15                	ja     f0102810 <mem_init+0x145a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027fb:	50                   	push   %eax
f01027fc:	68 ec 56 10 f0       	push   $0xf01056ec
f0102801:	68 fd 00 00 00       	push   $0xfd
f0102806:	68 00 52 10 f0       	push   $0xf0105200
f010280b:	e8 e9 d8 ff ff       	call   f01000f9 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102810:	05 00 00 00 10       	add    $0x10000000,%eax
f0102815:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102818:	b8 00 00 00 00       	mov    $0x0,%eax
f010281d:	e8 1d e5 ff ff       	call   f0100d3f <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102822:	0f 20 c0             	mov    %cr0,%eax
f0102825:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102828:	0d 23 00 05 80       	or     $0x80050023,%eax
f010282d:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102830:	83 ec 0c             	sub    $0xc,%esp
f0102833:	6a 00                	push   $0x0
f0102835:	e8 b2 e8 ff ff       	call   f01010ec <page_alloc>
f010283a:	89 c3                	mov    %eax,%ebx
f010283c:	83 c4 10             	add    $0x10,%esp
f010283f:	85 c0                	test   %eax,%eax
f0102841:	75 19                	jne    f010285c <mem_init+0x14a6>
f0102843:	68 1f 53 10 f0       	push   $0xf010531f
f0102848:	68 26 52 10 f0       	push   $0xf0105226
f010284d:	68 d0 03 00 00       	push   $0x3d0
f0102852:	68 00 52 10 f0       	push   $0xf0105200
f0102857:	e8 9d d8 ff ff       	call   f01000f9 <_panic>
	assert((pp1 = page_alloc(0)));
f010285c:	83 ec 0c             	sub    $0xc,%esp
f010285f:	6a 00                	push   $0x0
f0102861:	e8 86 e8 ff ff       	call   f01010ec <page_alloc>
f0102866:	89 c7                	mov    %eax,%edi
f0102868:	83 c4 10             	add    $0x10,%esp
f010286b:	85 c0                	test   %eax,%eax
f010286d:	75 19                	jne    f0102888 <mem_init+0x14d2>
f010286f:	68 35 53 10 f0       	push   $0xf0105335
f0102874:	68 26 52 10 f0       	push   $0xf0105226
f0102879:	68 d1 03 00 00       	push   $0x3d1
f010287e:	68 00 52 10 f0       	push   $0xf0105200
f0102883:	e8 71 d8 ff ff       	call   f01000f9 <_panic>
	assert((pp2 = page_alloc(0)));
f0102888:	83 ec 0c             	sub    $0xc,%esp
f010288b:	6a 00                	push   $0x0
f010288d:	e8 5a e8 ff ff       	call   f01010ec <page_alloc>
f0102892:	89 c6                	mov    %eax,%esi
f0102894:	83 c4 10             	add    $0x10,%esp
f0102897:	85 c0                	test   %eax,%eax
f0102899:	75 19                	jne    f01028b4 <mem_init+0x14fe>
f010289b:	68 4b 53 10 f0       	push   $0xf010534b
f01028a0:	68 26 52 10 f0       	push   $0xf0105226
f01028a5:	68 d2 03 00 00       	push   $0x3d2
f01028aa:	68 00 52 10 f0       	push   $0xf0105200
f01028af:	e8 45 d8 ff ff       	call   f01000f9 <_panic>
	page_free(pp0);
f01028b4:	83 ec 0c             	sub    $0xc,%esp
f01028b7:	53                   	push   %ebx
f01028b8:	e8 99 e8 ff ff       	call   f0101156 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01028bd:	89 f8                	mov    %edi,%eax
f01028bf:	2b 05 0c de 17 f0    	sub    0xf017de0c,%eax
f01028c5:	c1 f8 03             	sar    $0x3,%eax
f01028c8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028cb:	89 c2                	mov    %eax,%edx
f01028cd:	c1 ea 0c             	shr    $0xc,%edx
f01028d0:	83 c4 10             	add    $0x10,%esp
f01028d3:	3b 15 04 de 17 f0    	cmp    0xf017de04,%edx
f01028d9:	72 12                	jb     f01028ed <mem_init+0x1537>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028db:	50                   	push   %eax
f01028dc:	68 74 55 10 f0       	push   $0xf0105574
f01028e1:	6a 56                	push   $0x56
f01028e3:	68 0c 52 10 f0       	push   $0xf010520c
f01028e8:	e8 0c d8 ff ff       	call   f01000f9 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01028ed:	83 ec 04             	sub    $0x4,%esp
f01028f0:	68 00 10 00 00       	push   $0x1000
f01028f5:	6a 01                	push   $0x1
f01028f7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01028fc:	50                   	push   %eax
f01028fd:	e8 48 1d 00 00       	call   f010464a <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102902:	89 f0                	mov    %esi,%eax
f0102904:	2b 05 0c de 17 f0    	sub    0xf017de0c,%eax
f010290a:	c1 f8 03             	sar    $0x3,%eax
f010290d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102910:	89 c2                	mov    %eax,%edx
f0102912:	c1 ea 0c             	shr    $0xc,%edx
f0102915:	83 c4 10             	add    $0x10,%esp
f0102918:	3b 15 04 de 17 f0    	cmp    0xf017de04,%edx
f010291e:	72 12                	jb     f0102932 <mem_init+0x157c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102920:	50                   	push   %eax
f0102921:	68 74 55 10 f0       	push   $0xf0105574
f0102926:	6a 56                	push   $0x56
f0102928:	68 0c 52 10 f0       	push   $0xf010520c
f010292d:	e8 c7 d7 ff ff       	call   f01000f9 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102932:	83 ec 04             	sub    $0x4,%esp
f0102935:	68 00 10 00 00       	push   $0x1000
f010293a:	6a 02                	push   $0x2
f010293c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102941:	50                   	push   %eax
f0102942:	e8 03 1d 00 00       	call   f010464a <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102947:	6a 02                	push   $0x2
f0102949:	68 00 10 00 00       	push   $0x1000
f010294e:	57                   	push   %edi
f010294f:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0102955:	e8 f6 e9 ff ff       	call   f0101350 <page_insert>
	assert(pp1->pp_ref == 1);
f010295a:	83 c4 20             	add    $0x20,%esp
f010295d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102962:	74 19                	je     f010297d <mem_init+0x15c7>
f0102964:	68 2c 54 10 f0       	push   $0xf010542c
f0102969:	68 26 52 10 f0       	push   $0xf0105226
f010296e:	68 d7 03 00 00       	push   $0x3d7
f0102973:	68 00 52 10 f0       	push   $0xf0105200
f0102978:	e8 7c d7 ff ff       	call   f01000f9 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010297d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102984:	01 01 01 
f0102987:	74 19                	je     f01029a2 <mem_init+0x15ec>
f0102989:	68 58 5c 10 f0       	push   $0xf0105c58
f010298e:	68 26 52 10 f0       	push   $0xf0105226
f0102993:	68 d8 03 00 00       	push   $0x3d8
f0102998:	68 00 52 10 f0       	push   $0xf0105200
f010299d:	e8 57 d7 ff ff       	call   f01000f9 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01029a2:	6a 02                	push   $0x2
f01029a4:	68 00 10 00 00       	push   $0x1000
f01029a9:	56                   	push   %esi
f01029aa:	ff 35 08 de 17 f0    	pushl  0xf017de08
f01029b0:	e8 9b e9 ff ff       	call   f0101350 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01029b5:	83 c4 10             	add    $0x10,%esp
f01029b8:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01029bf:	02 02 02 
f01029c2:	74 19                	je     f01029dd <mem_init+0x1627>
f01029c4:	68 7c 5c 10 f0       	push   $0xf0105c7c
f01029c9:	68 26 52 10 f0       	push   $0xf0105226
f01029ce:	68 da 03 00 00       	push   $0x3da
f01029d3:	68 00 52 10 f0       	push   $0xf0105200
f01029d8:	e8 1c d7 ff ff       	call   f01000f9 <_panic>
	assert(pp2->pp_ref == 1);
f01029dd:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01029e2:	74 19                	je     f01029fd <mem_init+0x1647>
f01029e4:	68 4e 54 10 f0       	push   $0xf010544e
f01029e9:	68 26 52 10 f0       	push   $0xf0105226
f01029ee:	68 db 03 00 00       	push   $0x3db
f01029f3:	68 00 52 10 f0       	push   $0xf0105200
f01029f8:	e8 fc d6 ff ff       	call   f01000f9 <_panic>
	assert(pp1->pp_ref == 0);
f01029fd:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102a02:	74 19                	je     f0102a1d <mem_init+0x1667>
f0102a04:	68 c3 54 10 f0       	push   $0xf01054c3
f0102a09:	68 26 52 10 f0       	push   $0xf0105226
f0102a0e:	68 dc 03 00 00       	push   $0x3dc
f0102a13:	68 00 52 10 f0       	push   $0xf0105200
f0102a18:	e8 dc d6 ff ff       	call   f01000f9 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102a1d:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102a24:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a27:	89 f0                	mov    %esi,%eax
f0102a29:	2b 05 0c de 17 f0    	sub    0xf017de0c,%eax
f0102a2f:	c1 f8 03             	sar    $0x3,%eax
f0102a32:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a35:	89 c2                	mov    %eax,%edx
f0102a37:	c1 ea 0c             	shr    $0xc,%edx
f0102a3a:	3b 15 04 de 17 f0    	cmp    0xf017de04,%edx
f0102a40:	72 12                	jb     f0102a54 <mem_init+0x169e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a42:	50                   	push   %eax
f0102a43:	68 74 55 10 f0       	push   $0xf0105574
f0102a48:	6a 56                	push   $0x56
f0102a4a:	68 0c 52 10 f0       	push   $0xf010520c
f0102a4f:	e8 a5 d6 ff ff       	call   f01000f9 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102a54:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102a5b:	03 03 03 
f0102a5e:	74 19                	je     f0102a79 <mem_init+0x16c3>
f0102a60:	68 a0 5c 10 f0       	push   $0xf0105ca0
f0102a65:	68 26 52 10 f0       	push   $0xf0105226
f0102a6a:	68 de 03 00 00       	push   $0x3de
f0102a6f:	68 00 52 10 f0       	push   $0xf0105200
f0102a74:	e8 80 d6 ff ff       	call   f01000f9 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102a79:	83 ec 08             	sub    $0x8,%esp
f0102a7c:	68 00 10 00 00       	push   $0x1000
f0102a81:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0102a87:	e8 81 e8 ff ff       	call   f010130d <page_remove>
	assert(pp2->pp_ref == 0);
f0102a8c:	83 c4 10             	add    $0x10,%esp
f0102a8f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102a94:	74 19                	je     f0102aaf <mem_init+0x16f9>
f0102a96:	68 b2 54 10 f0       	push   $0xf01054b2
f0102a9b:	68 26 52 10 f0       	push   $0xf0105226
f0102aa0:	68 e0 03 00 00       	push   $0x3e0
f0102aa5:	68 00 52 10 f0       	push   $0xf0105200
f0102aaa:	e8 4a d6 ff ff       	call   f01000f9 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102aaf:	8b 0d 08 de 17 f0    	mov    0xf017de08,%ecx
f0102ab5:	8b 11                	mov    (%ecx),%edx
f0102ab7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102abd:	89 d8                	mov    %ebx,%eax
f0102abf:	2b 05 0c de 17 f0    	sub    0xf017de0c,%eax
f0102ac5:	c1 f8 03             	sar    $0x3,%eax
f0102ac8:	c1 e0 0c             	shl    $0xc,%eax
f0102acb:	39 c2                	cmp    %eax,%edx
f0102acd:	74 19                	je     f0102ae8 <mem_init+0x1732>
f0102acf:	68 e8 57 10 f0       	push   $0xf01057e8
f0102ad4:	68 26 52 10 f0       	push   $0xf0105226
f0102ad9:	68 e3 03 00 00       	push   $0x3e3
f0102ade:	68 00 52 10 f0       	push   $0xf0105200
f0102ae3:	e8 11 d6 ff ff       	call   f01000f9 <_panic>
	kern_pgdir[0] = 0;
f0102ae8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102aee:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102af3:	74 19                	je     f0102b0e <mem_init+0x1758>
f0102af5:	68 3d 54 10 f0       	push   $0xf010543d
f0102afa:	68 26 52 10 f0       	push   $0xf0105226
f0102aff:	68 e5 03 00 00       	push   $0x3e5
f0102b04:	68 00 52 10 f0       	push   $0xf0105200
f0102b09:	e8 eb d5 ff ff       	call   f01000f9 <_panic>
	pp0->pp_ref = 0;
f0102b0e:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102b14:	83 ec 0c             	sub    $0xc,%esp
f0102b17:	53                   	push   %ebx
f0102b18:	e8 39 e6 ff ff       	call   f0101156 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102b1d:	c7 04 24 cc 5c 10 f0 	movl   $0xf0105ccc,(%esp)
f0102b24:	e8 d7 07 00 00       	call   f0103300 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102b29:	83 c4 10             	add    $0x10,%esp
f0102b2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b2f:	5b                   	pop    %ebx
f0102b30:	5e                   	pop    %esi
f0102b31:	5f                   	pop    %edi
f0102b32:	5d                   	pop    %ebp
f0102b33:	c3                   	ret    

f0102b34 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102b34:	55                   	push   %ebp
f0102b35:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102b37:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b3a:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102b3d:	5d                   	pop    %ebp
f0102b3e:	c3                   	ret    

f0102b3f <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102b3f:	55                   	push   %ebp
f0102b40:	89 e5                	mov    %esp,%ebp
f0102b42:	57                   	push   %edi
f0102b43:	56                   	push   %esi
f0102b44:	53                   	push   %ebx
f0102b45:	83 ec 20             	sub    $0x20,%esp
f0102b48:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102b4b:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	cprintf("user_mem_check va: %x, len: %x\n", va, len);
f0102b4e:	ff 75 10             	pushl  0x10(%ebp)
f0102b51:	ff 75 0c             	pushl  0xc(%ebp)
f0102b54:	68 f8 5c 10 f0       	push   $0xf0105cf8
f0102b59:	e8 a2 07 00 00       	call   f0103300 <cprintf>
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102b5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102b61:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0102b67:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b6a:	8b 55 10             	mov    0x10(%ebp),%edx
f0102b6d:	8d 84 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%eax
f0102b74:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102b79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102b7c:	83 c4 10             	add    $0x10,%esp
f0102b7f:	eb 43                	jmp    f0102bc4 <user_mem_check+0x85>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0102b81:	83 ec 04             	sub    $0x4,%esp
f0102b84:	6a 00                	push   $0x0
f0102b86:	53                   	push   %ebx
f0102b87:	ff 77 5c             	pushl  0x5c(%edi)
f0102b8a:	e8 fd e5 ff ff       	call   f010118c <pgdir_walk>
		// pprint(pte);
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f0102b8f:	83 c4 10             	add    $0x10,%esp
f0102b92:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102b98:	77 10                	ja     f0102baa <user_mem_check+0x6b>
f0102b9a:	85 c0                	test   %eax,%eax
f0102b9c:	74 0c                	je     f0102baa <user_mem_check+0x6b>
f0102b9e:	8b 00                	mov    (%eax),%eax
f0102ba0:	a8 01                	test   $0x1,%al
f0102ba2:	74 06                	je     f0102baa <user_mem_check+0x6b>
f0102ba4:	21 f0                	and    %esi,%eax
f0102ba6:	39 c6                	cmp    %eax,%esi
f0102ba8:	74 14                	je     f0102bbe <user_mem_check+0x7f>
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
f0102baa:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102bad:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102bb1:	89 1d 3c d1 17 f0    	mov    %ebx,0xf017d13c
			return -E_FAULT;
f0102bb7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102bbc:	eb 26                	jmp    f0102be4 <user_mem_check+0xa5>
	// LAB 3: Your code here.
	cprintf("user_mem_check va: %x, len: %x\n", va, len);
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	for (i = (uint32_t)begin; i < end; i+=PGSIZE) {
f0102bbe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102bc4:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102bc7:	72 b8                	jb     f0102b81 <user_mem_check+0x42>
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
			user_mem_check_addr = (i<(uint32_t)va?(uint32_t)va:i);
			return -E_FAULT;
		}
	}
	cprintf("user_mem_check success va: %x, len: %x\n", va, len);
f0102bc9:	83 ec 04             	sub    $0x4,%esp
f0102bcc:	ff 75 10             	pushl  0x10(%ebp)
f0102bcf:	ff 75 0c             	pushl  0xc(%ebp)
f0102bd2:	68 18 5d 10 f0       	push   $0xf0105d18
f0102bd7:	e8 24 07 00 00       	call   f0103300 <cprintf>
	return 0;
f0102bdc:	83 c4 10             	add    $0x10,%esp
f0102bdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102be7:	5b                   	pop    %ebx
f0102be8:	5e                   	pop    %esi
f0102be9:	5f                   	pop    %edi
f0102bea:	5d                   	pop    %ebp
f0102beb:	c3                   	ret    

f0102bec <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102bec:	55                   	push   %ebp
f0102bed:	89 e5                	mov    %esp,%ebp
f0102bef:	53                   	push   %ebx
f0102bf0:	83 ec 04             	sub    $0x4,%esp
f0102bf3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102bf6:	8b 45 14             	mov    0x14(%ebp),%eax
f0102bf9:	83 c8 04             	or     $0x4,%eax
f0102bfc:	50                   	push   %eax
f0102bfd:	ff 75 10             	pushl  0x10(%ebp)
f0102c00:	ff 75 0c             	pushl  0xc(%ebp)
f0102c03:	53                   	push   %ebx
f0102c04:	e8 36 ff ff ff       	call   f0102b3f <user_mem_check>
f0102c09:	83 c4 10             	add    $0x10,%esp
f0102c0c:	85 c0                	test   %eax,%eax
f0102c0e:	79 21                	jns    f0102c31 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102c10:	83 ec 04             	sub    $0x4,%esp
f0102c13:	ff 35 3c d1 17 f0    	pushl  0xf017d13c
f0102c19:	ff 73 48             	pushl  0x48(%ebx)
f0102c1c:	68 40 5d 10 f0       	push   $0xf0105d40
f0102c21:	e8 da 06 00 00       	call   f0103300 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102c26:	89 1c 24             	mov    %ebx,(%esp)
f0102c29:	e8 bb 05 00 00       	call   f01031e9 <env_destroy>
f0102c2e:	83 c4 10             	add    $0x10,%esp
	}
}
f0102c31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102c34:	c9                   	leave  
f0102c35:	c3                   	ret    

f0102c36 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102c36:	55                   	push   %ebp
f0102c37:	89 e5                	mov    %esp,%ebp
f0102c39:	57                   	push   %edi
f0102c3a:	56                   	push   %esi
f0102c3b:	53                   	push   %ebx
f0102c3c:	83 ec 0c             	sub    $0xc,%esp
f0102c3f:	89 c7                	mov    %eax,%edi
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f0102c41:	89 d3                	mov    %edx,%ebx
f0102c43:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102c49:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102c50:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; begin < end; begin += PGSIZE) {
f0102c56:	eb 3d                	jmp    f0102c95 <region_alloc+0x5f>
		struct PageInfo *pg = page_alloc(0);
f0102c58:	83 ec 0c             	sub    $0xc,%esp
f0102c5b:	6a 00                	push   $0x0
f0102c5d:	e8 8a e4 ff ff       	call   f01010ec <page_alloc>
		if (!pg) panic("region_alloc failed!");
f0102c62:	83 c4 10             	add    $0x10,%esp
f0102c65:	85 c0                	test   %eax,%eax
f0102c67:	75 17                	jne    f0102c80 <region_alloc+0x4a>
f0102c69:	83 ec 04             	sub    $0x4,%esp
f0102c6c:	68 75 5d 10 f0       	push   $0xf0105d75
f0102c71:	68 15 01 00 00       	push   $0x115
f0102c76:	68 8a 5d 10 f0       	push   $0xf0105d8a
f0102c7b:	e8 79 d4 ff ff       	call   f01000f9 <_panic>
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
f0102c80:	6a 06                	push   $0x6
f0102c82:	53                   	push   %ebx
f0102c83:	50                   	push   %eax
f0102c84:	ff 77 5c             	pushl  0x5c(%edi)
f0102c87:	e8 c4 e6 ff ff       	call   f0101350 <page_insert>
static void
region_alloc(struct Env *e, void *va, size_t len)
{
	// LAB 3: Your code here.
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
	for (; begin < end; begin += PGSIZE) {
f0102c8c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102c92:	83 c4 10             	add    $0x10,%esp
f0102c95:	39 f3                	cmp    %esi,%ebx
f0102c97:	72 bf                	jb     f0102c58 <region_alloc+0x22>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
}
f0102c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c9c:	5b                   	pop    %ebx
f0102c9d:	5e                   	pop    %esi
f0102c9e:	5f                   	pop    %edi
f0102c9f:	5d                   	pop    %ebp
f0102ca0:	c3                   	ret    

f0102ca1 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102ca1:	55                   	push   %ebp
f0102ca2:	89 e5                	mov    %esp,%ebp
f0102ca4:	8b 55 08             	mov    0x8(%ebp),%edx
f0102ca7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102caa:	85 d2                	test   %edx,%edx
f0102cac:	75 11                	jne    f0102cbf <envid2env+0x1e>
		*env_store = curenv;
f0102cae:	a1 48 d1 17 f0       	mov    0xf017d148,%eax
f0102cb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102cb6:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102cb8:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cbd:	eb 5e                	jmp    f0102d1d <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102cbf:	89 d0                	mov    %edx,%eax
f0102cc1:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102cc6:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102cc9:	c1 e0 05             	shl    $0x5,%eax
f0102ccc:	03 05 4c d1 17 f0    	add    0xf017d14c,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102cd2:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0102cd6:	74 05                	je     f0102cdd <envid2env+0x3c>
f0102cd8:	3b 50 48             	cmp    0x48(%eax),%edx
f0102cdb:	74 10                	je     f0102ced <envid2env+0x4c>
		*env_store = 0;
f0102cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ce0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102ce6:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102ceb:	eb 30                	jmp    f0102d1d <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102ced:	84 c9                	test   %cl,%cl
f0102cef:	74 22                	je     f0102d13 <envid2env+0x72>
f0102cf1:	8b 15 48 d1 17 f0    	mov    0xf017d148,%edx
f0102cf7:	39 d0                	cmp    %edx,%eax
f0102cf9:	74 18                	je     f0102d13 <envid2env+0x72>
f0102cfb:	8b 4a 48             	mov    0x48(%edx),%ecx
f0102cfe:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f0102d01:	74 10                	je     f0102d13 <envid2env+0x72>
		*env_store = 0;
f0102d03:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d06:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102d0c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102d11:	eb 0a                	jmp    f0102d1d <envid2env+0x7c>
	}

	*env_store = e;
f0102d13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102d16:	89 01                	mov    %eax,(%ecx)
	return 0;
f0102d18:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d1d:	5d                   	pop    %ebp
f0102d1e:	c3                   	ret    

f0102d1f <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102d1f:	55                   	push   %ebp
f0102d20:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102d22:	b8 00 b3 11 f0       	mov    $0xf011b300,%eax
f0102d27:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102d2a:	b8 23 00 00 00       	mov    $0x23,%eax
f0102d2f:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102d31:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102d33:	b8 10 00 00 00       	mov    $0x10,%eax
f0102d38:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102d3a:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102d3c:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102d3e:	ea 45 2d 10 f0 08 00 	ljmp   $0x8,$0xf0102d45
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102d45:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d4a:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102d4d:	5d                   	pop    %ebp
f0102d4e:	c3                   	ret    

f0102d4f <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102d4f:	55                   	push   %ebp
f0102d50:	89 e5                	mov    %esp,%ebp
f0102d52:	56                   	push   %esi
f0102d53:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
		envs[i].env_id = 0;
f0102d54:	8b 35 4c d1 17 f0    	mov    0xf017d14c,%esi
f0102d5a:	8b 15 50 d1 17 f0    	mov    0xf017d150,%edx
f0102d60:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f0102d66:	8d 5e a0             	lea    -0x60(%esi),%ebx
f0102d69:	89 c1                	mov    %eax,%ecx
f0102d6b:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102d72:	89 50 44             	mov    %edx,0x44(%eax)
f0102d75:	83 e8 60             	sub    $0x60,%eax
		env_free_list = envs+i;
f0102d78:	89 ca                	mov    %ecx,%edx
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for (i = NENV-1;i >= 0; --i) {
f0102d7a:	39 d8                	cmp    %ebx,%eax
f0102d7c:	75 eb                	jne    f0102d69 <env_init+0x1a>
f0102d7e:	89 35 50 d1 17 f0    	mov    %esi,0xf017d150
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs+i;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102d84:	e8 96 ff ff ff       	call   f0102d1f <env_init_percpu>
}
f0102d89:	5b                   	pop    %ebx
f0102d8a:	5e                   	pop    %esi
f0102d8b:	5d                   	pop    %ebp
f0102d8c:	c3                   	ret    

f0102d8d <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102d8d:	55                   	push   %ebp
f0102d8e:	89 e5                	mov    %esp,%ebp
f0102d90:	53                   	push   %ebx
f0102d91:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102d94:	8b 1d 50 d1 17 f0    	mov    0xf017d150,%ebx
f0102d9a:	85 db                	test   %ebx,%ebx
f0102d9c:	0f 84 62 01 00 00    	je     f0102f04 <env_alloc+0x177>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102da2:	83 ec 0c             	sub    $0xc,%esp
f0102da5:	6a 01                	push   $0x1
f0102da7:	e8 40 e3 ff ff       	call   f01010ec <page_alloc>
f0102dac:	83 c4 10             	add    $0x10,%esp
f0102daf:	85 c0                	test   %eax,%eax
f0102db1:	0f 84 54 01 00 00    	je     f0102f0b <env_alloc+0x17e>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0102db7:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102dbc:	2b 05 0c de 17 f0    	sub    0xf017de0c,%eax
f0102dc2:	c1 f8 03             	sar    $0x3,%eax
f0102dc5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dc8:	89 c2                	mov    %eax,%edx
f0102dca:	c1 ea 0c             	shr    $0xc,%edx
f0102dcd:	3b 15 04 de 17 f0    	cmp    0xf017de04,%edx
f0102dd3:	72 12                	jb     f0102de7 <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dd5:	50                   	push   %eax
f0102dd6:	68 74 55 10 f0       	push   $0xf0105574
f0102ddb:	6a 56                	push   $0x56
f0102ddd:	68 0c 52 10 f0       	push   $0xf010520c
f0102de2:	e8 12 d3 ff ff       	call   f01000f9 <_panic>
	return (void *)(pa + KERNBASE);
f0102de7:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *) page2kva(p);
f0102dec:	89 43 5c             	mov    %eax,0x5c(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102def:	83 ec 04             	sub    $0x4,%esp
f0102df2:	68 00 10 00 00       	push   $0x1000
f0102df7:	ff 35 08 de 17 f0    	pushl  0xf017de08
f0102dfd:	50                   	push   %eax
f0102dfe:	e8 fc 18 00 00       	call   f01046ff <memcpy>

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102e03:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e06:	83 c4 10             	add    $0x10,%esp
f0102e09:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e0e:	77 15                	ja     f0102e25 <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102e10:	50                   	push   %eax
f0102e11:	68 ec 56 10 f0       	push   $0xf01056ec
f0102e16:	68 c1 00 00 00       	push   $0xc1
f0102e1b:	68 8a 5d 10 f0       	push   $0xf0105d8a
f0102e20:	e8 d4 d2 ff ff       	call   f01000f9 <_panic>
f0102e25:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102e2b:	83 ca 05             	or     $0x5,%edx
f0102e2e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102e34:	8b 43 48             	mov    0x48(%ebx),%eax
f0102e37:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102e3c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102e41:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102e46:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102e49:	8b 0d 4c d1 17 f0    	mov    0xf017d14c,%ecx
f0102e4f:	89 da                	mov    %ebx,%edx
f0102e51:	29 ca                	sub    %ecx,%edx
f0102e53:	c1 fa 05             	sar    $0x5,%edx
f0102e56:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0102e5c:	09 d0                	or     %edx,%eax
f0102e5e:	89 43 48             	mov    %eax,0x48(%ebx)
	cprintf("envs: %x, e: %x, e->env_id: %x\n", envs, e, e->env_id);
f0102e61:	50                   	push   %eax
f0102e62:	53                   	push   %ebx
f0102e63:	51                   	push   %ecx
f0102e64:	68 04 5e 10 f0       	push   $0xf0105e04
f0102e69:	e8 92 04 00 00       	call   f0103300 <cprintf>

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e71:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102e74:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102e7b:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102e82:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102e89:	83 c4 0c             	add    $0xc,%esp
f0102e8c:	6a 44                	push   $0x44
f0102e8e:	6a 00                	push   $0x0
f0102e90:	53                   	push   %ebx
f0102e91:	e8 b4 17 00 00       	call   f010464a <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102e96:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102e9c:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102ea2:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102ea8:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102eaf:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102eb5:	8b 43 44             	mov    0x44(%ebx),%eax
f0102eb8:	a3 50 d1 17 f0       	mov    %eax,0xf017d150
	*newenv_store = e;
f0102ebd:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ec0:	89 18                	mov    %ebx,(%eax)

	cprintf("env_id, %x\n", e->env_id);
f0102ec2:	83 c4 08             	add    $0x8,%esp
f0102ec5:	ff 73 48             	pushl  0x48(%ebx)
f0102ec8:	68 95 5d 10 f0       	push   $0xf0105d95
f0102ecd:	e8 2e 04 00 00       	call   f0103300 <cprintf>
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102ed2:	8b 53 48             	mov    0x48(%ebx),%edx
f0102ed5:	a1 48 d1 17 f0       	mov    0xf017d148,%eax
f0102eda:	83 c4 10             	add    $0x10,%esp
f0102edd:	85 c0                	test   %eax,%eax
f0102edf:	74 05                	je     f0102ee6 <env_alloc+0x159>
f0102ee1:	8b 40 48             	mov    0x48(%eax),%eax
f0102ee4:	eb 05                	jmp    f0102eeb <env_alloc+0x15e>
f0102ee6:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eeb:	83 ec 04             	sub    $0x4,%esp
f0102eee:	52                   	push   %edx
f0102eef:	50                   	push   %eax
f0102ef0:	68 a1 5d 10 f0       	push   $0xf0105da1
f0102ef5:	e8 06 04 00 00       	call   f0103300 <cprintf>
	return 0;
f0102efa:	83 c4 10             	add    $0x10,%esp
f0102efd:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f02:	eb 0c                	jmp    f0102f10 <env_alloc+0x183>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102f04:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102f09:	eb 05                	jmp    f0102f10 <env_alloc+0x183>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102f0b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	*newenv_store = e;

	cprintf("env_id, %x\n", e->env_id);
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102f10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f13:	c9                   	leave  
f0102f14:	c3                   	ret    

f0102f15 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0102f15:	55                   	push   %ebp
f0102f16:	89 e5                	mov    %esp,%ebp
f0102f18:	57                   	push   %edi
f0102f19:	56                   	push   %esi
f0102f1a:	53                   	push   %ebx
f0102f1b:	83 ec 34             	sub    $0x34,%esp
f0102f1e:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
f0102f21:	6a 00                	push   $0x0
f0102f23:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102f26:	50                   	push   %eax
f0102f27:	e8 61 fe ff ff       	call   f0102d8d <env_alloc>
	load_icode(penv, binary, size);
f0102f2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102f2f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// LAB 3: Your code here.
	struct Elf *ELFHDR = (struct Elf *) binary;
	struct Proghdr *ph, *eph;

	if (ELFHDR->e_magic != ELF_MAGIC)
f0102f32:	83 c4 10             	add    $0x10,%esp
f0102f35:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102f3b:	74 17                	je     f0102f54 <env_create+0x3f>
		panic("Not executable!");
f0102f3d:	83 ec 04             	sub    $0x4,%esp
f0102f40:	68 b6 5d 10 f0       	push   $0xf0105db6
f0102f45:	68 52 01 00 00       	push   $0x152
f0102f4a:	68 8a 5d 10 f0       	push   $0xf0105d8a
f0102f4f:	e8 a5 d1 ff ff       	call   f01000f9 <_panic>
	
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0102f54:	89 fb                	mov    %edi,%ebx
f0102f56:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0102f59:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102f5d:	c1 e6 05             	shl    $0x5,%esi
f0102f60:	01 de                	add    %ebx,%esi
	//  The ph->p_filesz bytes from the ELF binary, starting at
	//  'binary + ph->p_offset', should be copied to virtual address
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
f0102f62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f65:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f68:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f6d:	77 15                	ja     f0102f84 <env_create+0x6f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f6f:	50                   	push   %eax
f0102f70:	68 ec 56 10 f0       	push   $0xf01056ec
f0102f75:	68 5e 01 00 00       	push   $0x15e
f0102f7a:	68 8a 5d 10 f0       	push   $0xf0105d8a
f0102f7f:	e8 75 d1 ff ff       	call   f01000f9 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102f84:	05 00 00 00 10       	add    $0x10000000,%eax
f0102f89:	0f 22 d8             	mov    %eax,%cr3
f0102f8c:	eb 50                	jmp    f0102fde <env_create+0xc9>
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD) {
f0102f8e:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102f91:	75 48                	jne    f0102fdb <env_create+0xc6>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102f93:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102f96:	8b 53 08             	mov    0x8(%ebx),%edx
f0102f99:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f9c:	e8 95 fc ff ff       	call   f0102c36 <region_alloc>
			memset((void *)ph->p_va, 0, ph->p_memsz);
f0102fa1:	83 ec 04             	sub    $0x4,%esp
f0102fa4:	ff 73 14             	pushl  0x14(%ebx)
f0102fa7:	6a 00                	push   $0x0
f0102fa9:	ff 73 08             	pushl  0x8(%ebx)
f0102fac:	e8 99 16 00 00       	call   f010464a <memset>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0102fb1:	83 c4 0c             	add    $0xc,%esp
f0102fb4:	ff 73 10             	pushl  0x10(%ebx)
f0102fb7:	89 f8                	mov    %edi,%eax
f0102fb9:	03 43 04             	add    0x4(%ebx),%eax
f0102fbc:	50                   	push   %eax
f0102fbd:	ff 73 08             	pushl  0x8(%ebx)
f0102fc0:	e8 3a 17 00 00       	call   f01046ff <memcpy>
			
			cprintf("p_memsz: %x, p_filesz: %x\n", ph->p_memsz, ph->p_filesz);
f0102fc5:	83 c4 0c             	add    $0xc,%esp
f0102fc8:	ff 73 10             	pushl  0x10(%ebx)
f0102fcb:	ff 73 14             	pushl  0x14(%ebx)
f0102fce:	68 c6 5d 10 f0       	push   $0xf0105dc6
f0102fd3:	e8 28 03 00 00       	call   f0103300 <cprintf>
f0102fd8:	83 c4 10             	add    $0x10,%esp
	//  ph->p_va.  Any remaining memory bytes should be cleared to zero.
	//  (The ELF header should have ph->p_filesz <= ph->p_memsz.)
	//  Use functions from the previous lab to allocate and map pages.
	lcr3(PADDR(e->env_pgdir));
	//it's silly to use kern_pgdir here.
	for (; ph < eph; ph++)
f0102fdb:	83 c3 20             	add    $0x20,%ebx
f0102fde:	39 de                	cmp    %ebx,%esi
f0102fe0:	77 ac                	ja     f0102f8e <env_create+0x79>
			memcpy((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
			
			cprintf("p_memsz: %x, p_filesz: %x\n", ph->p_memsz, ph->p_filesz);
		}
	//we can use this because kern_pgdir is a subset of e->env_pgdir
	lcr3(PADDR(kern_pgdir));
f0102fe2:	a1 08 de 17 f0       	mov    0xf017de08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fe7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fec:	77 15                	ja     f0103003 <env_create+0xee>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fee:	50                   	push   %eax
f0102fef:	68 ec 56 10 f0       	push   $0xf01056ec
f0102ff4:	68 69 01 00 00       	push   $0x169
f0102ff9:	68 8a 5d 10 f0       	push   $0xf0105d8a
f0102ffe:	e8 f6 d0 ff ff       	call   f01000f9 <_panic>
f0103003:	05 00 00 00 10       	add    $0x10000000,%eax
f0103008:	0f 22 d8             	mov    %eax,%cr3
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here.
	e->env_tf.tf_eip = ELFHDR->e_entry;
f010300b:	8b 47 18             	mov    0x18(%edi),%eax
f010300e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103011:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0103014:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103019:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010301e:	89 f8                	mov    %edi,%eax
f0103020:	e8 11 fc ff ff       	call   f0102c36 <region_alloc>
{
	// LAB 3: Your code here.
	struct Env *penv;
	env_alloc(&penv, 0);
	load_icode(penv, binary, size);
}
f0103025:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103028:	5b                   	pop    %ebx
f0103029:	5e                   	pop    %esi
f010302a:	5f                   	pop    %edi
f010302b:	5d                   	pop    %ebp
f010302c:	c3                   	ret    

f010302d <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010302d:	55                   	push   %ebp
f010302e:	89 e5                	mov    %esp,%ebp
f0103030:	57                   	push   %edi
f0103031:	56                   	push   %esi
f0103032:	53                   	push   %ebx
f0103033:	83 ec 1c             	sub    $0x1c,%esp
f0103036:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103039:	8b 15 48 d1 17 f0    	mov    0xf017d148,%edx
f010303f:	39 fa                	cmp    %edi,%edx
f0103041:	75 29                	jne    f010306c <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0103043:	a1 08 de 17 f0       	mov    0xf017de08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103048:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010304d:	77 15                	ja     f0103064 <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010304f:	50                   	push   %eax
f0103050:	68 ec 56 10 f0       	push   $0xf01056ec
f0103055:	68 8f 01 00 00       	push   $0x18f
f010305a:	68 8a 5d 10 f0       	push   $0xf0105d8a
f010305f:	e8 95 d0 ff ff       	call   f01000f9 <_panic>
f0103064:	05 00 00 00 10       	add    $0x10000000,%eax
f0103069:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010306c:	8b 4f 48             	mov    0x48(%edi),%ecx
f010306f:	85 d2                	test   %edx,%edx
f0103071:	74 05                	je     f0103078 <env_free+0x4b>
f0103073:	8b 42 48             	mov    0x48(%edx),%eax
f0103076:	eb 05                	jmp    f010307d <env_free+0x50>
f0103078:	b8 00 00 00 00       	mov    $0x0,%eax
f010307d:	83 ec 04             	sub    $0x4,%esp
f0103080:	51                   	push   %ecx
f0103081:	50                   	push   %eax
f0103082:	68 e1 5d 10 f0       	push   $0xf0105de1
f0103087:	e8 74 02 00 00       	call   f0103300 <cprintf>
f010308c:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010308f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103096:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103099:	89 d0                	mov    %edx,%eax
f010309b:	c1 e0 02             	shl    $0x2,%eax
f010309e:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01030a1:	8b 47 5c             	mov    0x5c(%edi),%eax
f01030a4:	8b 34 90             	mov    (%eax,%edx,4),%esi
f01030a7:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01030ad:	0f 84 a8 00 00 00    	je     f010315b <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01030b3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030b9:	89 f0                	mov    %esi,%eax
f01030bb:	c1 e8 0c             	shr    $0xc,%eax
f01030be:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01030c1:	39 05 04 de 17 f0    	cmp    %eax,0xf017de04
f01030c7:	77 15                	ja     f01030de <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030c9:	56                   	push   %esi
f01030ca:	68 74 55 10 f0       	push   $0xf0105574
f01030cf:	68 9e 01 00 00       	push   $0x19e
f01030d4:	68 8a 5d 10 f0       	push   $0xf0105d8a
f01030d9:	e8 1b d0 ff ff       	call   f01000f9 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01030de:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01030e1:	c1 e0 16             	shl    $0x16,%eax
f01030e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01030e7:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01030ec:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01030f3:	01 
f01030f4:	74 17                	je     f010310d <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01030f6:	83 ec 08             	sub    $0x8,%esp
f01030f9:	89 d8                	mov    %ebx,%eax
f01030fb:	c1 e0 0c             	shl    $0xc,%eax
f01030fe:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103101:	50                   	push   %eax
f0103102:	ff 77 5c             	pushl  0x5c(%edi)
f0103105:	e8 03 e2 ff ff       	call   f010130d <page_remove>
f010310a:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010310d:	83 c3 01             	add    $0x1,%ebx
f0103110:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103116:	75 d4                	jne    f01030ec <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103118:	8b 47 5c             	mov    0x5c(%edi),%eax
f010311b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010311e:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103125:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103128:	3b 05 04 de 17 f0    	cmp    0xf017de04,%eax
f010312e:	72 14                	jb     f0103144 <env_free+0x117>
		panic("pa2page called with invalid pa");
f0103130:	83 ec 04             	sub    $0x4,%esp
f0103133:	68 90 56 10 f0       	push   $0xf0105690
f0103138:	6a 4f                	push   $0x4f
f010313a:	68 0c 52 10 f0       	push   $0xf010520c
f010313f:	e8 b5 cf ff ff       	call   f01000f9 <_panic>
		page_decref(pa2page(pa));
f0103144:	83 ec 0c             	sub    $0xc,%esp
f0103147:	a1 0c de 17 f0       	mov    0xf017de0c,%eax
f010314c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010314f:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0103152:	50                   	push   %eax
f0103153:	e8 13 e0 ff ff       	call   f010116b <page_decref>
f0103158:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010315b:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010315f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103162:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103167:	0f 85 29 ff ff ff    	jne    f0103096 <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010316d:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103170:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103175:	77 15                	ja     f010318c <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103177:	50                   	push   %eax
f0103178:	68 ec 56 10 f0       	push   $0xf01056ec
f010317d:	68 ac 01 00 00       	push   $0x1ac
f0103182:	68 8a 5d 10 f0       	push   $0xf0105d8a
f0103187:	e8 6d cf ff ff       	call   f01000f9 <_panic>
	e->env_pgdir = 0;
f010318c:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103193:	05 00 00 00 10       	add    $0x10000000,%eax
f0103198:	c1 e8 0c             	shr    $0xc,%eax
f010319b:	3b 05 04 de 17 f0    	cmp    0xf017de04,%eax
f01031a1:	72 14                	jb     f01031b7 <env_free+0x18a>
		panic("pa2page called with invalid pa");
f01031a3:	83 ec 04             	sub    $0x4,%esp
f01031a6:	68 90 56 10 f0       	push   $0xf0105690
f01031ab:	6a 4f                	push   $0x4f
f01031ad:	68 0c 52 10 f0       	push   $0xf010520c
f01031b2:	e8 42 cf ff ff       	call   f01000f9 <_panic>
	page_decref(pa2page(pa));
f01031b7:	83 ec 0c             	sub    $0xc,%esp
f01031ba:	8b 15 0c de 17 f0    	mov    0xf017de0c,%edx
f01031c0:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f01031c3:	50                   	push   %eax
f01031c4:	e8 a2 df ff ff       	call   f010116b <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01031c9:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01031d0:	a1 50 d1 17 f0       	mov    0xf017d150,%eax
f01031d5:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01031d8:	89 3d 50 d1 17 f0    	mov    %edi,0xf017d150
}
f01031de:	83 c4 10             	add    $0x10,%esp
f01031e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031e4:	5b                   	pop    %ebx
f01031e5:	5e                   	pop    %esi
f01031e6:	5f                   	pop    %edi
f01031e7:	5d                   	pop    %ebp
f01031e8:	c3                   	ret    

f01031e9 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01031e9:	55                   	push   %ebp
f01031ea:	89 e5                	mov    %esp,%ebp
f01031ec:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f01031ef:	ff 75 08             	pushl  0x8(%ebp)
f01031f2:	e8 36 fe ff ff       	call   f010302d <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01031f7:	c7 04 24 24 5e 10 f0 	movl   $0xf0105e24,(%esp)
f01031fe:	e8 fd 00 00 00       	call   f0103300 <cprintf>
f0103203:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0103206:	83 ec 0c             	sub    $0xc,%esp
f0103209:	6a 00                	push   $0x0
f010320b:	e8 8d d6 ff ff       	call   f010089d <monitor>
f0103210:	83 c4 10             	add    $0x10,%esp
f0103213:	eb f1                	jmp    f0103206 <env_destroy+0x1d>

f0103215 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103215:	55                   	push   %ebp
f0103216:	89 e5                	mov    %esp,%ebp
f0103218:	83 ec 0c             	sub    $0xc,%esp
	__asm __volatile("movl %0,%%esp\n"
f010321b:	8b 65 08             	mov    0x8(%ebp),%esp
f010321e:	61                   	popa   
f010321f:	07                   	pop    %es
f0103220:	1f                   	pop    %ds
f0103221:	83 c4 08             	add    $0x8,%esp
f0103224:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103225:	68 f7 5d 10 f0       	push   $0xf0105df7
f010322a:	68 d4 01 00 00       	push   $0x1d4
f010322f:	68 8a 5d 10 f0       	push   $0xf0105d8a
f0103234:	e8 c0 ce ff ff       	call   f01000f9 <_panic>

f0103239 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103239:	55                   	push   %ebp
f010323a:	89 e5                	mov    %esp,%ebp
f010323c:	53                   	push   %ebx
f010323d:	83 ec 10             	sub    $0x10,%esp
f0103240:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	// cprintf("curenv: %x, e: %x\n", curenv, e);
	cprintf("\n");
f0103243:	68 1a 55 10 f0       	push   $0xf010551a
f0103248:	e8 b3 00 00 00       	call   f0103300 <cprintf>
	if (curenv != e) {
f010324d:	83 c4 10             	add    $0x10,%esp
f0103250:	39 1d 48 d1 17 f0    	cmp    %ebx,0xf017d148
f0103256:	74 38                	je     f0103290 <env_run+0x57>
		// if (curenv->env_status == ENV_RUNNING)
		// 	curenv->env_status = ENV_RUNNABLE;
		curenv = e;
f0103258:	89 1d 48 d1 17 f0    	mov    %ebx,0xf017d148
		e->env_status = ENV_RUNNING;
f010325e:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		e->env_runs++;
f0103265:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		lcr3(PADDR(e->env_pgdir));
f0103269:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010326c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103271:	77 15                	ja     f0103288 <env_run+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103273:	50                   	push   %eax
f0103274:	68 ec 56 10 f0       	push   $0xf01056ec
f0103279:	68 fa 01 00 00       	push   $0x1fa
f010327e:	68 8a 5d 10 f0       	push   $0xf0105d8a
f0103283:	e8 71 ce ff ff       	call   f01000f9 <_panic>
f0103288:	05 00 00 00 10       	add    $0x10000000,%eax
f010328d:	0f 22 d8             	mov    %eax,%cr3
	}
	env_pop_tf(&e->env_tf);
f0103290:	83 ec 0c             	sub    $0xc,%esp
f0103293:	53                   	push   %ebx
f0103294:	e8 7c ff ff ff       	call   f0103215 <env_pop_tf>

f0103299 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103299:	55                   	push   %ebp
f010329a:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010329c:	ba 70 00 00 00       	mov    $0x70,%edx
f01032a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01032a4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01032a5:	ba 71 00 00 00       	mov    $0x71,%edx
f01032aa:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01032ab:	0f b6 c0             	movzbl %al,%eax
}
f01032ae:	5d                   	pop    %ebp
f01032af:	c3                   	ret    

f01032b0 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01032b0:	55                   	push   %ebp
f01032b1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01032b3:	ba 70 00 00 00       	mov    $0x70,%edx
f01032b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01032bb:	ee                   	out    %al,(%dx)
f01032bc:	ba 71 00 00 00       	mov    $0x71,%edx
f01032c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032c4:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01032c5:	5d                   	pop    %ebp
f01032c6:	c3                   	ret    

f01032c7 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01032c7:	55                   	push   %ebp
f01032c8:	89 e5                	mov    %esp,%ebp
f01032ca:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01032cd:	ff 75 08             	pushl  0x8(%ebp)
f01032d0:	e8 a3 d3 ff ff       	call   f0100678 <cputchar>
	*cnt++;
}
f01032d5:	83 c4 10             	add    $0x10,%esp
f01032d8:	c9                   	leave  
f01032d9:	c3                   	ret    

f01032da <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01032da:	55                   	push   %ebp
f01032db:	89 e5                	mov    %esp,%ebp
f01032dd:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01032e0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01032e7:	ff 75 0c             	pushl  0xc(%ebp)
f01032ea:	ff 75 08             	pushl  0x8(%ebp)
f01032ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01032f0:	50                   	push   %eax
f01032f1:	68 c7 32 10 f0       	push   $0xf01032c7
f01032f6:	e8 9d 0c 00 00       	call   f0103f98 <vprintfmt>
	return cnt;
}
f01032fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01032fe:	c9                   	leave  
f01032ff:	c3                   	ret    

f0103300 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103300:	55                   	push   %ebp
f0103301:	89 e5                	mov    %esp,%ebp
f0103303:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103306:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103309:	50                   	push   %eax
f010330a:	ff 75 08             	pushl  0x8(%ebp)
f010330d:	e8 c8 ff ff ff       	call   f01032da <vcprintf>
	va_end(ap);

	return cnt;
}
f0103312:	c9                   	leave  
f0103313:	c3                   	ret    

f0103314 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103314:	55                   	push   %ebp
f0103315:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103317:	b8 80 d9 17 f0       	mov    $0xf017d980,%eax
f010331c:	c7 05 84 d9 17 f0 00 	movl   $0xf0000000,0xf017d984
f0103323:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103326:	66 c7 05 88 d9 17 f0 	movw   $0x10,0xf017d988
f010332d:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f010332f:	66 c7 05 48 b3 11 f0 	movw   $0x68,0xf011b348
f0103336:	68 00 
f0103338:	66 a3 4a b3 11 f0    	mov    %ax,0xf011b34a
f010333e:	89 c2                	mov    %eax,%edx
f0103340:	c1 ea 10             	shr    $0x10,%edx
f0103343:	88 15 4c b3 11 f0    	mov    %dl,0xf011b34c
f0103349:	c6 05 4e b3 11 f0 40 	movb   $0x40,0xf011b34e
f0103350:	c1 e8 18             	shr    $0x18,%eax
f0103353:	a2 4f b3 11 f0       	mov    %al,0xf011b34f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103358:	c6 05 4d b3 11 f0 89 	movb   $0x89,0xf011b34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010335f:	b8 28 00 00 00       	mov    $0x28,%eax
f0103364:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103367:	b8 50 b3 11 f0       	mov    $0xf011b350,%eax
f010336c:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010336f:	5d                   	pop    %ebp
f0103370:	c3                   	ret    

f0103371 <trap_init>:



void
trap_init(void)
{
f0103371:	55                   	push   %ebp
f0103372:	89 e5                	mov    %esp,%ebp
f0103374:	57                   	push   %edi
f0103375:	56                   	push   %esi
f0103376:	53                   	push   %ebx
f0103377:	83 ec 24             	sub    $0x24,%esp
	// SETGATE(idt[14], 0, GD_KT, th14, 0);
	// SETGATE(idt[16], 0, GD_KT, th16, 0);

	// Challenge:
	extern void (*funs[])();
	cprintf("funs %x\n", funs);
f010337a:	68 56 b3 11 f0       	push   $0xf011b356
f010337f:	68 5a 5e 10 f0       	push   $0xf0105e5a
f0103384:	e8 77 ff ff ff       	call   f0103300 <cprintf>
	cprintf("funs[0] %x\n", funs[0]);
f0103389:	83 c4 08             	add    $0x8,%esp
f010338c:	ff 35 56 b3 11 f0    	pushl  0xf011b356
f0103392:	68 63 5e 10 f0       	push   $0xf0105e63
f0103397:	e8 64 ff ff ff       	call   f0103300 <cprintf>
	cprintf("funs[48] %x\n", funs[48]);
f010339c:	83 c4 08             	add    $0x8,%esp
f010339f:	ff 35 16 b4 11 f0    	pushl  0xf011b416
f01033a5:	68 6f 5e 10 f0       	push   $0xf0105e6f
f01033aa:	e8 51 ff ff ff       	call   f0103300 <cprintf>
f01033af:	83 c4 10             	add    $0x10,%esp
	int i;
	for (i = 0; i <= 16; ++i)
f01033b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01033b7:	e9 bb 00 00 00       	jmp    f0103477 <trap_init+0x106>
		if (i==T_BRKPT)
f01033bc:	83 f8 03             	cmp    $0x3,%eax
f01033bf:	75 35                	jne    f01033f6 <trap_init+0x85>
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
f01033c1:	8b 35 62 b3 11 f0    	mov    0xf011b362,%esi
f01033c7:	89 f7                	mov    %esi,%edi
f01033c9:	bb 01 00 00 00       	mov    $0x1,%ebx
f01033ce:	66 c7 45 e6 08 00    	movw   $0x8,-0x1a(%ebp)
f01033d4:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
f01033d8:	c6 45 e4 00          	movb   $0x0,-0x1c(%ebp)
f01033dc:	c6 45 e3 0e          	movb   $0xe,-0x1d(%ebp)
f01033e0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01033e5:	ba 03 00 00 00       	mov    $0x3,%edx
f01033ea:	c6 45 e2 01          	movb   $0x1,-0x1e(%ebp)
f01033ee:	c1 ee 10             	shr    $0x10,%esi
f01033f1:	e9 17 01 00 00       	jmp    f010350d <trap_init+0x19c>
f01033f6:	84 db                	test   %bl,%bl
f01033f8:	74 14                	je     f010340e <trap_init+0x9d>
f01033fa:	66 89 3d 78 d1 17 f0 	mov    %di,0xf017d178
f0103401:	0f b7 7d e6          	movzwl -0x1a(%ebp),%edi
f0103405:	66 89 3d 7a d1 17 f0 	mov    %di,0xf017d17a
f010340c:	eb 04                	jmp    f0103412 <trap_init+0xa1>
f010340e:	84 db                	test   %bl,%bl
f0103410:	74 12                	je     f0103424 <trap_init+0xb3>
f0103412:	0f b6 5d e4          	movzbl -0x1c(%ebp),%ebx
f0103416:	c1 e3 05             	shl    $0x5,%ebx
f0103419:	0a 5d e5             	or     -0x1b(%ebp),%bl
f010341c:	88 1d 7c d1 17 f0    	mov    %bl,0xf017d17c
f0103422:	eb 04                	jmp    f0103428 <trap_init+0xb7>
f0103424:	84 db                	test   %bl,%bl
f0103426:	74 1d                	je     f0103445 <trap_init+0xd4>
f0103428:	0f b6 1d 7d d1 17 f0 	movzbl 0xf017d17d,%ebx
f010342f:	83 e3 e0             	and    $0xffffffe0,%ebx
f0103432:	83 e1 01             	and    $0x1,%ecx
f0103435:	c1 e1 04             	shl    $0x4,%ecx
f0103438:	0a 5d e3             	or     -0x1d(%ebp),%bl
f010343b:	09 d9                	or     %ebx,%ecx
f010343d:	88 0d 7d d1 17 f0    	mov    %cl,0xf017d17d
f0103443:	eb 04                	jmp    f0103449 <trap_init+0xd8>
f0103445:	84 db                	test   %bl,%bl
f0103447:	74 23                	je     f010346c <trap_init+0xfb>
f0103449:	83 e2 03             	and    $0x3,%edx
f010344c:	c1 e2 05             	shl    $0x5,%edx
f010344f:	0f b6 1d 7d d1 17 f0 	movzbl 0xf017d17d,%ebx
f0103456:	83 e3 1f             	and    $0x1f,%ebx
f0103459:	0f b6 4d e2          	movzbl -0x1e(%ebp),%ecx
f010345d:	c1 e1 07             	shl    $0x7,%ecx
f0103460:	09 da                	or     %ebx,%edx
f0103462:	09 ca                	or     %ecx,%edx
f0103464:	88 15 7d d1 17 f0    	mov    %dl,0xf017d17d
f010346a:	eb 04                	jmp    f0103470 <trap_init+0xff>
f010346c:	84 db                	test   %bl,%bl
f010346e:	74 07                	je     f0103477 <trap_init+0x106>
f0103470:	66 89 35 7e d1 17 f0 	mov    %si,0xf017d17e
		else if (i!=2 && i!=15) {
f0103477:	83 f8 02             	cmp    $0x2,%eax
f010347a:	74 39                	je     f01034b5 <trap_init+0x144>
f010347c:	83 f8 0f             	cmp    $0xf,%eax
f010347f:	74 34                	je     f01034b5 <trap_init+0x144>
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
f0103481:	8b 14 85 56 b3 11 f0 	mov    -0xfee4caa(,%eax,4),%edx
f0103488:	66 89 14 c5 60 d1 17 	mov    %dx,-0xfe82ea0(,%eax,8)
f010348f:	f0 
f0103490:	66 c7 04 c5 62 d1 17 	movw   $0x8,-0xfe82e9e(,%eax,8)
f0103497:	f0 08 00 
f010349a:	c6 04 c5 64 d1 17 f0 	movb   $0x0,-0xfe82e9c(,%eax,8)
f01034a1:	00 
f01034a2:	c6 04 c5 65 d1 17 f0 	movb   $0x8e,-0xfe82e9b(,%eax,8)
f01034a9:	8e 
f01034aa:	c1 ea 10             	shr    $0x10,%edx
f01034ad:	66 89 14 c5 66 d1 17 	mov    %dx,-0xfe82e9a(,%eax,8)
f01034b4:	f0 
f01034b5:	0f b7 3d 78 d1 17 f0 	movzwl 0xf017d178,%edi
f01034bc:	0f b7 35 7a d1 17 f0 	movzwl 0xf017d17a,%esi
f01034c3:	66 89 75 e6          	mov    %si,-0x1a(%ebp)
f01034c7:	0f b6 15 7c d1 17 f0 	movzbl 0xf017d17c,%edx
f01034ce:	89 d1                	mov    %edx,%ecx
f01034d0:	83 e1 1f             	and    $0x1f,%ecx
f01034d3:	88 4d e5             	mov    %cl,-0x1b(%ebp)
f01034d6:	c0 ea 05             	shr    $0x5,%dl
f01034d9:	88 55 e4             	mov    %dl,-0x1c(%ebp)
f01034dc:	0f b6 1d 7d d1 17 f0 	movzbl 0xf017d17d,%ebx
f01034e3:	89 d9                	mov    %ebx,%ecx
f01034e5:	83 e1 0f             	and    $0xf,%ecx
f01034e8:	88 4d e3             	mov    %cl,-0x1d(%ebp)
f01034eb:	89 d9                	mov    %ebx,%ecx
f01034ed:	c0 e9 04             	shr    $0x4,%cl
f01034f0:	83 e1 01             	and    $0x1,%ecx
f01034f3:	89 da                	mov    %ebx,%edx
f01034f5:	c0 ea 05             	shr    $0x5,%dl
f01034f8:	83 e2 03             	and    $0x3,%edx
f01034fb:	c0 eb 07             	shr    $0x7,%bl
f01034fe:	88 5d e2             	mov    %bl,-0x1e(%ebp)
f0103501:	0f b7 35 7e d1 17 f0 	movzwl 0xf017d17e,%esi
	extern void (*funs[])();
	cprintf("funs %x\n", funs);
	cprintf("funs[0] %x\n", funs[0]);
	cprintf("funs[48] %x\n", funs[48]);
	int i;
	for (i = 0; i <= 16; ++i)
f0103508:	bb 00 00 00 00       	mov    $0x0,%ebx
f010350d:	83 c0 01             	add    $0x1,%eax
f0103510:	83 f8 10             	cmp    $0x10,%eax
f0103513:	0f 8e a3 fe ff ff    	jle    f01033bc <trap_init+0x4b>
f0103519:	84 db                	test   %bl,%bl
f010351b:	74 13                	je     f0103530 <trap_init+0x1bf>
f010351d:	66 89 3d 78 d1 17 f0 	mov    %di,0xf017d178
f0103524:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
f0103528:	66 a3 7a d1 17 f0    	mov    %ax,0xf017d17a
f010352e:	eb 04                	jmp    f0103534 <trap_init+0x1c3>
f0103530:	84 db                	test   %bl,%bl
f0103532:	74 11                	je     f0103545 <trap_init+0x1d4>
f0103534:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0103538:	c1 e0 05             	shl    $0x5,%eax
f010353b:	0a 45 e5             	or     -0x1b(%ebp),%al
f010353e:	a2 7c d1 17 f0       	mov    %al,0xf017d17c
f0103543:	eb 04                	jmp    f0103549 <trap_init+0x1d8>
f0103545:	84 db                	test   %bl,%bl
f0103547:	74 1c                	je     f0103565 <trap_init+0x1f4>
f0103549:	0f b6 05 7d d1 17 f0 	movzbl 0xf017d17d,%eax
f0103550:	83 e0 e0             	and    $0xffffffe0,%eax
f0103553:	83 e1 01             	and    $0x1,%ecx
f0103556:	c1 e1 04             	shl    $0x4,%ecx
f0103559:	0a 45 e3             	or     -0x1d(%ebp),%al
f010355c:	09 c8                	or     %ecx,%eax
f010355e:	a2 7d d1 17 f0       	mov    %al,0xf017d17d
f0103563:	eb 04                	jmp    f0103569 <trap_init+0x1f8>
f0103565:	84 db                	test   %bl,%bl
f0103567:	74 24                	je     f010358d <trap_init+0x21c>
f0103569:	89 d0                	mov    %edx,%eax
f010356b:	83 e0 03             	and    $0x3,%eax
f010356e:	c1 e0 05             	shl    $0x5,%eax
f0103571:	0f b6 0d 7d d1 17 f0 	movzbl 0xf017d17d,%ecx
f0103578:	83 e1 1f             	and    $0x1f,%ecx
f010357b:	0f b6 55 e2          	movzbl -0x1e(%ebp),%edx
f010357f:	c1 e2 07             	shl    $0x7,%edx
f0103582:	09 c8                	or     %ecx,%eax
f0103584:	09 d0                	or     %edx,%eax
f0103586:	a2 7d d1 17 f0       	mov    %al,0xf017d17d
f010358b:	eb 04                	jmp    f0103591 <trap_init+0x220>
f010358d:	84 db                	test   %bl,%bl
f010358f:	74 07                	je     f0103598 <trap_init+0x227>
f0103591:	66 89 35 7e d1 17 f0 	mov    %si,0xf017d17e
		if (i==T_BRKPT)
			SETGATE(idt[i], 0, GD_KT, funs[i], 3)
		else if (i!=2 && i!=15) {
			SETGATE(idt[i], 0, GD_KT, funs[i], 0);
		}
	SETGATE(idt[48], 0, GD_KT, funs[48], 3);
f0103598:	a1 16 b4 11 f0       	mov    0xf011b416,%eax
f010359d:	66 a3 e0 d2 17 f0    	mov    %ax,0xf017d2e0
f01035a3:	66 c7 05 e2 d2 17 f0 	movw   $0x8,0xf017d2e2
f01035aa:	08 00 
f01035ac:	c6 05 e4 d2 17 f0 00 	movb   $0x0,0xf017d2e4
f01035b3:	c6 05 e5 d2 17 f0 ee 	movb   $0xee,0xf017d2e5
f01035ba:	c1 e8 10             	shr    $0x10,%eax
f01035bd:	66 a3 e6 d2 17 f0    	mov    %ax,0xf017d2e6
	// Per-CPU setup 
	trap_init_percpu();
f01035c3:	e8 4c fd ff ff       	call   f0103314 <trap_init_percpu>
}
f01035c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035cb:	5b                   	pop    %ebx
f01035cc:	5e                   	pop    %esi
f01035cd:	5f                   	pop    %edi
f01035ce:	5d                   	pop    %ebp
f01035cf:	c3                   	ret    

f01035d0 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01035d0:	55                   	push   %ebp
f01035d1:	89 e5                	mov    %esp,%ebp
f01035d3:	53                   	push   %ebx
f01035d4:	83 ec 0c             	sub    $0xc,%esp
f01035d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01035da:	ff 33                	pushl  (%ebx)
f01035dc:	68 7c 5e 10 f0       	push   $0xf0105e7c
f01035e1:	e8 1a fd ff ff       	call   f0103300 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01035e6:	83 c4 08             	add    $0x8,%esp
f01035e9:	ff 73 04             	pushl  0x4(%ebx)
f01035ec:	68 8b 5e 10 f0       	push   $0xf0105e8b
f01035f1:	e8 0a fd ff ff       	call   f0103300 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01035f6:	83 c4 08             	add    $0x8,%esp
f01035f9:	ff 73 08             	pushl  0x8(%ebx)
f01035fc:	68 9a 5e 10 f0       	push   $0xf0105e9a
f0103601:	e8 fa fc ff ff       	call   f0103300 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103606:	83 c4 08             	add    $0x8,%esp
f0103609:	ff 73 0c             	pushl  0xc(%ebx)
f010360c:	68 a9 5e 10 f0       	push   $0xf0105ea9
f0103611:	e8 ea fc ff ff       	call   f0103300 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103616:	83 c4 08             	add    $0x8,%esp
f0103619:	ff 73 10             	pushl  0x10(%ebx)
f010361c:	68 b8 5e 10 f0       	push   $0xf0105eb8
f0103621:	e8 da fc ff ff       	call   f0103300 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103626:	83 c4 08             	add    $0x8,%esp
f0103629:	ff 73 14             	pushl  0x14(%ebx)
f010362c:	68 c7 5e 10 f0       	push   $0xf0105ec7
f0103631:	e8 ca fc ff ff       	call   f0103300 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103636:	83 c4 08             	add    $0x8,%esp
f0103639:	ff 73 18             	pushl  0x18(%ebx)
f010363c:	68 d6 5e 10 f0       	push   $0xf0105ed6
f0103641:	e8 ba fc ff ff       	call   f0103300 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103646:	83 c4 08             	add    $0x8,%esp
f0103649:	ff 73 1c             	pushl  0x1c(%ebx)
f010364c:	68 e5 5e 10 f0       	push   $0xf0105ee5
f0103651:	e8 aa fc ff ff       	call   f0103300 <cprintf>
}
f0103656:	83 c4 10             	add    $0x10,%esp
f0103659:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010365c:	c9                   	leave  
f010365d:	c3                   	ret    

f010365e <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010365e:	55                   	push   %ebp
f010365f:	89 e5                	mov    %esp,%ebp
f0103661:	56                   	push   %esi
f0103662:	53                   	push   %ebx
f0103663:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103666:	83 ec 08             	sub    $0x8,%esp
f0103669:	53                   	push   %ebx
f010366a:	68 2e 60 10 f0       	push   $0xf010602e
f010366f:	e8 8c fc ff ff       	call   f0103300 <cprintf>
	print_regs(&tf->tf_regs);
f0103674:	89 1c 24             	mov    %ebx,(%esp)
f0103677:	e8 54 ff ff ff       	call   f01035d0 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010367c:	83 c4 08             	add    $0x8,%esp
f010367f:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103683:	50                   	push   %eax
f0103684:	68 36 5f 10 f0       	push   $0xf0105f36
f0103689:	e8 72 fc ff ff       	call   f0103300 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010368e:	83 c4 08             	add    $0x8,%esp
f0103691:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103695:	50                   	push   %eax
f0103696:	68 49 5f 10 f0       	push   $0xf0105f49
f010369b:	e8 60 fc ff ff       	call   f0103300 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01036a0:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01036a3:	83 c4 10             	add    $0x10,%esp
f01036a6:	83 f8 13             	cmp    $0x13,%eax
f01036a9:	77 09                	ja     f01036b4 <print_trapframe+0x56>
		return excnames[trapno];
f01036ab:	8b 14 85 20 62 10 f0 	mov    -0xfef9de0(,%eax,4),%edx
f01036b2:	eb 10                	jmp    f01036c4 <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f01036b4:	83 f8 30             	cmp    $0x30,%eax
f01036b7:	b9 00 5f 10 f0       	mov    $0xf0105f00,%ecx
f01036bc:	ba f4 5e 10 f0       	mov    $0xf0105ef4,%edx
f01036c1:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01036c4:	83 ec 04             	sub    $0x4,%esp
f01036c7:	52                   	push   %edx
f01036c8:	50                   	push   %eax
f01036c9:	68 5c 5f 10 f0       	push   $0xf0105f5c
f01036ce:	e8 2d fc ff ff       	call   f0103300 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01036d3:	83 c4 10             	add    $0x10,%esp
f01036d6:	3b 1d 60 d9 17 f0    	cmp    0xf017d960,%ebx
f01036dc:	75 1a                	jne    f01036f8 <print_trapframe+0x9a>
f01036de:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01036e2:	75 14                	jne    f01036f8 <print_trapframe+0x9a>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01036e4:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01036e7:	83 ec 08             	sub    $0x8,%esp
f01036ea:	50                   	push   %eax
f01036eb:	68 6e 5f 10 f0       	push   $0xf0105f6e
f01036f0:	e8 0b fc ff ff       	call   f0103300 <cprintf>
f01036f5:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f01036f8:	83 ec 08             	sub    $0x8,%esp
f01036fb:	ff 73 2c             	pushl  0x2c(%ebx)
f01036fe:	68 7d 5f 10 f0       	push   $0xf0105f7d
f0103703:	e8 f8 fb ff ff       	call   f0103300 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103708:	83 c4 10             	add    $0x10,%esp
f010370b:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010370f:	75 49                	jne    f010375a <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103711:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103714:	89 c2                	mov    %eax,%edx
f0103716:	83 e2 01             	and    $0x1,%edx
f0103719:	ba 1a 5f 10 f0       	mov    $0xf0105f1a,%edx
f010371e:	b9 0f 5f 10 f0       	mov    $0xf0105f0f,%ecx
f0103723:	0f 44 ca             	cmove  %edx,%ecx
f0103726:	89 c2                	mov    %eax,%edx
f0103728:	83 e2 02             	and    $0x2,%edx
f010372b:	ba 2c 5f 10 f0       	mov    $0xf0105f2c,%edx
f0103730:	be 26 5f 10 f0       	mov    $0xf0105f26,%esi
f0103735:	0f 45 d6             	cmovne %esi,%edx
f0103738:	83 e0 04             	and    $0x4,%eax
f010373b:	be 7f 60 10 f0       	mov    $0xf010607f,%esi
f0103740:	b8 31 5f 10 f0       	mov    $0xf0105f31,%eax
f0103745:	0f 44 c6             	cmove  %esi,%eax
f0103748:	51                   	push   %ecx
f0103749:	52                   	push   %edx
f010374a:	50                   	push   %eax
f010374b:	68 8b 5f 10 f0       	push   $0xf0105f8b
f0103750:	e8 ab fb ff ff       	call   f0103300 <cprintf>
f0103755:	83 c4 10             	add    $0x10,%esp
f0103758:	eb 10                	jmp    f010376a <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f010375a:	83 ec 0c             	sub    $0xc,%esp
f010375d:	68 1a 55 10 f0       	push   $0xf010551a
f0103762:	e8 99 fb ff ff       	call   f0103300 <cprintf>
f0103767:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010376a:	83 ec 08             	sub    $0x8,%esp
f010376d:	ff 73 30             	pushl  0x30(%ebx)
f0103770:	68 9a 5f 10 f0       	push   $0xf0105f9a
f0103775:	e8 86 fb ff ff       	call   f0103300 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010377a:	83 c4 08             	add    $0x8,%esp
f010377d:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103781:	50                   	push   %eax
f0103782:	68 a9 5f 10 f0       	push   $0xf0105fa9
f0103787:	e8 74 fb ff ff       	call   f0103300 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010378c:	83 c4 08             	add    $0x8,%esp
f010378f:	ff 73 38             	pushl  0x38(%ebx)
f0103792:	68 bc 5f 10 f0       	push   $0xf0105fbc
f0103797:	e8 64 fb ff ff       	call   f0103300 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010379c:	83 c4 10             	add    $0x10,%esp
f010379f:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01037a3:	74 25                	je     f01037ca <print_trapframe+0x16c>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01037a5:	83 ec 08             	sub    $0x8,%esp
f01037a8:	ff 73 3c             	pushl  0x3c(%ebx)
f01037ab:	68 cb 5f 10 f0       	push   $0xf0105fcb
f01037b0:	e8 4b fb ff ff       	call   f0103300 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01037b5:	83 c4 08             	add    $0x8,%esp
f01037b8:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01037bc:	50                   	push   %eax
f01037bd:	68 da 5f 10 f0       	push   $0xf0105fda
f01037c2:	e8 39 fb ff ff       	call   f0103300 <cprintf>
f01037c7:	83 c4 10             	add    $0x10,%esp
	}
}
f01037ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01037cd:	5b                   	pop    %ebx
f01037ce:	5e                   	pop    %esi
f01037cf:	5d                   	pop    %ebp
f01037d0:	c3                   	ret    

f01037d1 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01037d1:	55                   	push   %ebp
f01037d2:	89 e5                	mov    %esp,%ebp
f01037d4:	53                   	push   %ebx
f01037d5:	83 ec 04             	sub    $0x4,%esp
f01037d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01037db:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs&3) == 0)
f01037de:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01037e2:	75 17                	jne    f01037fb <page_fault_handler+0x2a>
		panic("Kernel page fault!");
f01037e4:	83 ec 04             	sub    $0x4,%esp
f01037e7:	68 ed 5f 10 f0       	push   $0xf0105fed
f01037ec:	68 0c 01 00 00       	push   $0x10c
f01037f1:	68 00 60 10 f0       	push   $0xf0106000
f01037f6:	e8 fe c8 ff ff       	call   f01000f9 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01037fb:	ff 73 30             	pushl  0x30(%ebx)
f01037fe:	50                   	push   %eax
f01037ff:	a1 48 d1 17 f0       	mov    0xf017d148,%eax
f0103804:	ff 70 48             	pushl  0x48(%eax)
f0103807:	68 cc 61 10 f0       	push   $0xf01061cc
f010380c:	e8 ef fa ff ff       	call   f0103300 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103811:	89 1c 24             	mov    %ebx,(%esp)
f0103814:	e8 45 fe ff ff       	call   f010365e <print_trapframe>
	env_destroy(curenv);
f0103819:	83 c4 04             	add    $0x4,%esp
f010381c:	ff 35 48 d1 17 f0    	pushl  0xf017d148
f0103822:	e8 c2 f9 ff ff       	call   f01031e9 <env_destroy>
}
f0103827:	83 c4 10             	add    $0x10,%esp
f010382a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010382d:	c9                   	leave  
f010382e:	c3                   	ret    

f010382f <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010382f:	55                   	push   %ebp
f0103830:	89 e5                	mov    %esp,%ebp
f0103832:	57                   	push   %edi
f0103833:	56                   	push   %esi
f0103834:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103837:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103838:	9c                   	pushf  
f0103839:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f010383a:	f6 c4 02             	test   $0x2,%ah
f010383d:	74 19                	je     f0103858 <trap+0x29>
f010383f:	68 0c 60 10 f0       	push   $0xf010600c
f0103844:	68 26 52 10 f0       	push   $0xf0105226
f0103849:	68 e3 00 00 00       	push   $0xe3
f010384e:	68 00 60 10 f0       	push   $0xf0106000
f0103853:	e8 a1 c8 ff ff       	call   f01000f9 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103858:	83 ec 08             	sub    $0x8,%esp
f010385b:	56                   	push   %esi
f010385c:	68 25 60 10 f0       	push   $0xf0106025
f0103861:	e8 9a fa ff ff       	call   f0103300 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103866:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010386a:	83 e0 03             	and    $0x3,%eax
f010386d:	83 c4 10             	add    $0x10,%esp
f0103870:	66 83 f8 03          	cmp    $0x3,%ax
f0103874:	75 31                	jne    f01038a7 <trap+0x78>
		// Trapped from user mode.
		assert(curenv);
f0103876:	a1 48 d1 17 f0       	mov    0xf017d148,%eax
f010387b:	85 c0                	test   %eax,%eax
f010387d:	75 19                	jne    f0103898 <trap+0x69>
f010387f:	68 40 60 10 f0       	push   $0xf0106040
f0103884:	68 26 52 10 f0       	push   $0xf0105226
f0103889:	68 e9 00 00 00       	push   $0xe9
f010388e:	68 00 60 10 f0       	push   $0xf0106000
f0103893:	e8 61 c8 ff ff       	call   f01000f9 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103898:	b9 11 00 00 00       	mov    $0x11,%ecx
f010389d:	89 c7                	mov    %eax,%edi
f010389f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01038a1:	8b 35 48 d1 17 f0    	mov    0xf017d148,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01038a7:	89 35 60 d9 17 f0    	mov    %esi,0xf017d960
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if (tf->tf_trapno == T_PGFLT) {
f01038ad:	8b 46 28             	mov    0x28(%esi),%eax
f01038b0:	83 f8 0e             	cmp    $0xe,%eax
f01038b3:	75 1d                	jne    f01038d2 <trap+0xa3>
		cprintf("PAGE FAULT\n");
f01038b5:	83 ec 0c             	sub    $0xc,%esp
f01038b8:	68 47 60 10 f0       	push   $0xf0106047
f01038bd:	e8 3e fa ff ff       	call   f0103300 <cprintf>
		page_fault_handler(tf);
f01038c2:	89 34 24             	mov    %esi,(%esp)
f01038c5:	e8 07 ff ff ff       	call   f01037d1 <page_fault_handler>
f01038ca:	83 c4 10             	add    $0x10,%esp
f01038cd:	e9 8d 00 00 00       	jmp    f010395f <trap+0x130>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f01038d2:	83 f8 03             	cmp    $0x3,%eax
f01038d5:	75 1a                	jne    f01038f1 <trap+0xc2>
		cprintf("BREAK POINT\n");
f01038d7:	83 ec 0c             	sub    $0xc,%esp
f01038da:	68 53 60 10 f0       	push   $0xf0106053
f01038df:	e8 1c fa ff ff       	call   f0103300 <cprintf>
		monitor(tf);
f01038e4:	89 34 24             	mov    %esi,(%esp)
f01038e7:	e8 b1 cf ff ff       	call   f010089d <monitor>
f01038ec:	83 c4 10             	add    $0x10,%esp
f01038ef:	eb 6e                	jmp    f010395f <trap+0x130>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f01038f1:	83 f8 30             	cmp    $0x30,%eax
f01038f4:	75 2e                	jne    f0103924 <trap+0xf5>
		cprintf("SYSTEM CALL\n");
f01038f6:	83 ec 0c             	sub    $0xc,%esp
f01038f9:	68 60 60 10 f0       	push   $0xf0106060
f01038fe:	e8 fd f9 ff ff       	call   f0103300 <cprintf>
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0103903:	83 c4 08             	add    $0x8,%esp
f0103906:	ff 76 04             	pushl  0x4(%esi)
f0103909:	ff 36                	pushl  (%esi)
f010390b:	ff 76 10             	pushl  0x10(%esi)
f010390e:	ff 76 18             	pushl  0x18(%esi)
f0103911:	ff 76 14             	pushl  0x14(%esi)
f0103914:	ff 76 1c             	pushl  0x1c(%esi)
f0103917:	e8 d7 00 00 00       	call   f01039f3 <syscall>
		monitor(tf);
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
		cprintf("SYSTEM CALL\n");
		tf->tf_regs.reg_eax = 
f010391c:	89 46 1c             	mov    %eax,0x1c(%esi)
f010391f:	83 c4 20             	add    $0x20,%esp
f0103922:	eb 3b                	jmp    f010395f <trap+0x130>
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103924:	83 ec 0c             	sub    $0xc,%esp
f0103927:	56                   	push   %esi
f0103928:	e8 31 fd ff ff       	call   f010365e <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010392d:	83 c4 10             	add    $0x10,%esp
f0103930:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103935:	75 17                	jne    f010394e <trap+0x11f>
		panic("unhandled trap in kernel");
f0103937:	83 ec 04             	sub    $0x4,%esp
f010393a:	68 6d 60 10 f0       	push   $0xf010606d
f010393f:	68 d2 00 00 00       	push   $0xd2
f0103944:	68 00 60 10 f0       	push   $0xf0106000
f0103949:	e8 ab c7 ff ff       	call   f01000f9 <_panic>
	else {
		env_destroy(curenv);
f010394e:	83 ec 0c             	sub    $0xc,%esp
f0103951:	ff 35 48 d1 17 f0    	pushl  0xf017d148
f0103957:	e8 8d f8 ff ff       	call   f01031e9 <env_destroy>
f010395c:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f010395f:	a1 48 d1 17 f0       	mov    0xf017d148,%eax
f0103964:	85 c0                	test   %eax,%eax
f0103966:	74 06                	je     f010396e <trap+0x13f>
f0103968:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010396c:	74 19                	je     f0103987 <trap+0x158>
f010396e:	68 f0 61 10 f0       	push   $0xf01061f0
f0103973:	68 26 52 10 f0       	push   $0xf0105226
f0103978:	68 fb 00 00 00       	push   $0xfb
f010397d:	68 00 60 10 f0       	push   $0xf0106000
f0103982:	e8 72 c7 ff ff       	call   f01000f9 <_panic>
	env_run(curenv);
f0103987:	83 ec 0c             	sub    $0xc,%esp
f010398a:	50                   	push   %eax
f010398b:	e8 a9 f8 ff ff       	call   f0103239 <env_run>

f0103990 <th0>:
funs:
.text
/*
 * Challenge: my code here
 */
	noec(th0, 0)
f0103990:	6a 00                	push   $0x0
f0103992:	6a 00                	push   $0x0
f0103994:	eb 4e                	jmp    f01039e4 <_alltraps>

f0103996 <th1>:
	noec(th1, 1)
f0103996:	6a 00                	push   $0x0
f0103998:	6a 01                	push   $0x1
f010399a:	eb 48                	jmp    f01039e4 <_alltraps>

f010399c <th3>:
	zhanwei()
	noec(th3, 3)
f010399c:	6a 00                	push   $0x0
f010399e:	6a 03                	push   $0x3
f01039a0:	eb 42                	jmp    f01039e4 <_alltraps>

f01039a2 <th4>:
	noec(th4, 4)
f01039a2:	6a 00                	push   $0x0
f01039a4:	6a 04                	push   $0x4
f01039a6:	eb 3c                	jmp    f01039e4 <_alltraps>

f01039a8 <th5>:
	noec(th5, 5)
f01039a8:	6a 00                	push   $0x0
f01039aa:	6a 05                	push   $0x5
f01039ac:	eb 36                	jmp    f01039e4 <_alltraps>

f01039ae <th6>:
	noec(th6, 6)
f01039ae:	6a 00                	push   $0x0
f01039b0:	6a 06                	push   $0x6
f01039b2:	eb 30                	jmp    f01039e4 <_alltraps>

f01039b4 <th7>:
	noec(th7, 7)
f01039b4:	6a 00                	push   $0x0
f01039b6:	6a 07                	push   $0x7
f01039b8:	eb 2a                	jmp    f01039e4 <_alltraps>

f01039ba <th8>:
	ec(th8, 8)
f01039ba:	6a 08                	push   $0x8
f01039bc:	eb 26                	jmp    f01039e4 <_alltraps>

f01039be <th9>:
	noec(th9, 9)
f01039be:	6a 00                	push   $0x0
f01039c0:	6a 09                	push   $0x9
f01039c2:	eb 20                	jmp    f01039e4 <_alltraps>

f01039c4 <th10>:
	ec(th10, 10)
f01039c4:	6a 0a                	push   $0xa
f01039c6:	eb 1c                	jmp    f01039e4 <_alltraps>

f01039c8 <th11>:
	ec(th11, 11)
f01039c8:	6a 0b                	push   $0xb
f01039ca:	eb 18                	jmp    f01039e4 <_alltraps>

f01039cc <th12>:
	ec(th12, 12)
f01039cc:	6a 0c                	push   $0xc
f01039ce:	eb 14                	jmp    f01039e4 <_alltraps>

f01039d0 <th13>:
	ec(th13, 13)
f01039d0:	6a 0d                	push   $0xd
f01039d2:	eb 10                	jmp    f01039e4 <_alltraps>

f01039d4 <th14>:
	ec(th14, 14)
f01039d4:	6a 0e                	push   $0xe
f01039d6:	eb 0c                	jmp    f01039e4 <_alltraps>

f01039d8 <th16>:
	zhanwei()
	noec(th16, 16)
f01039d8:	6a 00                	push   $0x0
f01039da:	6a 10                	push   $0x10
f01039dc:	eb 06                	jmp    f01039e4 <_alltraps>

f01039de <th48>:
.data
	.space 124
.text
	noec(th48, 48)
f01039de:	6a 00                	push   $0x0
f01039e0:	6a 30                	push   $0x30
f01039e2:	eb 00                	jmp    f01039e4 <_alltraps>

f01039e4 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f01039e4:	1e                   	push   %ds
	pushl %es
f01039e5:	06                   	push   %es
	pushal
f01039e6:	60                   	pusha  
	pushl $GD_KD
f01039e7:	6a 10                	push   $0x10
	popl %ds
f01039e9:	1f                   	pop    %ds
	pushl $GD_KD
f01039ea:	6a 10                	push   $0x10
	popl %es
f01039ec:	07                   	pop    %es
	pushl %esp
f01039ed:	54                   	push   %esp
	call trap
f01039ee:	e8 3c fe ff ff       	call   f010382f <trap>

f01039f3 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01039f3:	55                   	push   %ebp
f01039f4:	89 e5                	mov    %esp,%ebp
f01039f6:	83 ec 18             	sub    $0x18,%esp
f01039f9:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int ret = 0;
	switch (syscallno) {
f01039fc:	83 f8 01             	cmp    $0x1,%eax
f01039ff:	74 57                	je     f0103a58 <syscall+0x65>
f0103a01:	83 f8 01             	cmp    $0x1,%eax
f0103a04:	72 0f                	jb     f0103a15 <syscall+0x22>
f0103a06:	83 f8 02             	cmp    $0x2,%eax
f0103a09:	74 54                	je     f0103a5f <syscall+0x6c>
f0103a0b:	83 f8 03             	cmp    $0x3,%eax
f0103a0e:	74 59                	je     f0103a69 <syscall+0x76>
f0103a10:	e9 b9 00 00 00       	jmp    f0103ace <syscall+0xdb>
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f0103a15:	83 ec 04             	sub    $0x4,%esp
f0103a18:	6a 01                	push   $0x1
f0103a1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103a1d:	50                   	push   %eax
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f0103a1e:	a1 48 d1 17 f0       	mov    0xf017d148,%eax
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	struct Env *e;
	envid2env(sys_getenvid(), &e, 1);
f0103a23:	ff 70 48             	pushl  0x48(%eax)
f0103a26:	e8 76 f2 ff ff       	call   f0102ca1 <envid2env>
	user_mem_assert(e, s, len, PTE_U);
f0103a2b:	6a 04                	push   $0x4
f0103a2d:	ff 75 10             	pushl  0x10(%ebp)
f0103a30:	ff 75 0c             	pushl  0xc(%ebp)
f0103a33:	ff 75 f4             	pushl  -0xc(%ebp)
f0103a36:	e8 b1 f1 ff ff       	call   f0102bec <user_mem_assert>
	//user_mem_check(struct Env *env, const void *va, size_t len, int perm)

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103a3b:	83 c4 1c             	add    $0x1c,%esp
f0103a3e:	ff 75 0c             	pushl  0xc(%ebp)
f0103a41:	ff 75 10             	pushl  0x10(%ebp)
f0103a44:	68 70 62 10 f0       	push   $0xf0106270
f0103a49:	e8 b2 f8 ff ff       	call   f0103300 <cprintf>
f0103a4e:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
	int ret = 0;
	switch (syscallno) {
		case SYS_cputs: 
			sys_cputs((char*)a1, a2);
			ret = 0;
f0103a51:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a56:	eb 7b                	jmp    f0103ad3 <syscall+0xe0>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103a58:	e8 c9 ca ff ff       	call   f0100526 <cons_getc>
			sys_cputs((char*)a1, a2);
			ret = 0;
			break;
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
f0103a5d:	eb 74                	jmp    f0103ad3 <syscall+0xe0>
// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	// cprintf("sys curenv_id: %x\n", curenv->env_id);
	return curenv->env_id;
f0103a5f:	a1 48 d1 17 f0       	mov    0xf017d148,%eax
f0103a64:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cgetc:
			ret = sys_cgetc();
			break;
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
f0103a67:	eb 6a                	jmp    f0103ad3 <syscall+0xe0>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103a69:	83 ec 04             	sub    $0x4,%esp
f0103a6c:	6a 01                	push   $0x1
f0103a6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103a71:	50                   	push   %eax
f0103a72:	ff 75 0c             	pushl  0xc(%ebp)
f0103a75:	e8 27 f2 ff ff       	call   f0102ca1 <envid2env>
f0103a7a:	83 c4 10             	add    $0x10,%esp
f0103a7d:	85 c0                	test   %eax,%eax
f0103a7f:	78 46                	js     f0103ac7 <syscall+0xd4>
		return r;
	if (e == curenv)
f0103a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a84:	8b 15 48 d1 17 f0    	mov    0xf017d148,%edx
f0103a8a:	39 d0                	cmp    %edx,%eax
f0103a8c:	75 15                	jne    f0103aa3 <syscall+0xb0>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103a8e:	83 ec 08             	sub    $0x8,%esp
f0103a91:	ff 70 48             	pushl  0x48(%eax)
f0103a94:	68 75 62 10 f0       	push   $0xf0106275
f0103a99:	e8 62 f8 ff ff       	call   f0103300 <cprintf>
f0103a9e:	83 c4 10             	add    $0x10,%esp
f0103aa1:	eb 16                	jmp    f0103ab9 <syscall+0xc6>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103aa3:	83 ec 04             	sub    $0x4,%esp
f0103aa6:	ff 70 48             	pushl  0x48(%eax)
f0103aa9:	ff 72 48             	pushl  0x48(%edx)
f0103aac:	68 90 62 10 f0       	push   $0xf0106290
f0103ab1:	e8 4a f8 ff ff       	call   f0103300 <cprintf>
f0103ab6:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103ab9:	83 ec 0c             	sub    $0xc,%esp
f0103abc:	ff 75 f4             	pushl  -0xc(%ebp)
f0103abf:	e8 25 f7 ff ff       	call   f01031e9 <env_destroy>
f0103ac4:	83 c4 10             	add    $0x10,%esp
		case SYS_getenvid:
			ret = sys_getenvid();
			break;
		case SYS_env_destroy:
			sys_env_destroy(a1);
			ret = 0;
f0103ac7:	b8 00 00 00 00       	mov    $0x0,%eax
f0103acc:	eb 05                	jmp    f0103ad3 <syscall+0xe0>
			break;
		default:
			ret = -E_INVAL;
f0103ace:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	// cprintf("ret: %x\n", ret);
	return ret;
	panic("syscall not implemented");
}
f0103ad3:	c9                   	leave  
f0103ad4:	c3                   	ret    

f0103ad5 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103ad5:	55                   	push   %ebp
f0103ad6:	89 e5                	mov    %esp,%ebp
f0103ad8:	57                   	push   %edi
f0103ad9:	56                   	push   %esi
f0103ada:	53                   	push   %ebx
f0103adb:	83 ec 14             	sub    $0x14,%esp
f0103ade:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ae1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103ae4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103ae7:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103aea:	8b 1a                	mov    (%edx),%ebx
f0103aec:	8b 01                	mov    (%ecx),%eax
f0103aee:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103af1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0103af8:	eb 7f                	jmp    f0103b79 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0103afa:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103afd:	01 d8                	add    %ebx,%eax
f0103aff:	89 c6                	mov    %eax,%esi
f0103b01:	c1 ee 1f             	shr    $0x1f,%esi
f0103b04:	01 c6                	add    %eax,%esi
f0103b06:	d1 fe                	sar    %esi
f0103b08:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0103b0b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103b0e:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0103b11:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103b13:	eb 03                	jmp    f0103b18 <stab_binsearch+0x43>
			m--;
f0103b15:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103b18:	39 c3                	cmp    %eax,%ebx
f0103b1a:	7f 0d                	jg     f0103b29 <stab_binsearch+0x54>
f0103b1c:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103b20:	83 ea 0c             	sub    $0xc,%edx
f0103b23:	39 f9                	cmp    %edi,%ecx
f0103b25:	75 ee                	jne    f0103b15 <stab_binsearch+0x40>
f0103b27:	eb 05                	jmp    f0103b2e <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103b29:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0103b2c:	eb 4b                	jmp    f0103b79 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103b2e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103b31:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103b34:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103b38:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103b3b:	76 11                	jbe    f0103b4e <stab_binsearch+0x79>
			*region_left = m;
f0103b3d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103b40:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103b42:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103b45:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103b4c:	eb 2b                	jmp    f0103b79 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103b4e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103b51:	73 14                	jae    f0103b67 <stab_binsearch+0x92>
			*region_right = m - 1;
f0103b53:	83 e8 01             	sub    $0x1,%eax
f0103b56:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103b59:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103b5c:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103b5e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103b65:	eb 12                	jmp    f0103b79 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103b67:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103b6a:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0103b6c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103b70:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103b72:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0103b79:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0103b7c:	0f 8e 78 ff ff ff    	jle    f0103afa <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103b82:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103b86:	75 0f                	jne    f0103b97 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0103b88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103b8b:	8b 00                	mov    (%eax),%eax
f0103b8d:	83 e8 01             	sub    $0x1,%eax
f0103b90:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103b93:	89 06                	mov    %eax,(%esi)
f0103b95:	eb 2c                	jmp    f0103bc3 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103b97:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b9a:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103b9c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103b9f:	8b 0e                	mov    (%esi),%ecx
f0103ba1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103ba4:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0103ba7:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103baa:	eb 03                	jmp    f0103baf <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103bac:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103baf:	39 c8                	cmp    %ecx,%eax
f0103bb1:	7e 0b                	jle    f0103bbe <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0103bb3:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0103bb7:	83 ea 0c             	sub    $0xc,%edx
f0103bba:	39 df                	cmp    %ebx,%edi
f0103bbc:	75 ee                	jne    f0103bac <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103bbe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103bc1:	89 06                	mov    %eax,(%esi)
	}
}
f0103bc3:	83 c4 14             	add    $0x14,%esp
f0103bc6:	5b                   	pop    %ebx
f0103bc7:	5e                   	pop    %esi
f0103bc8:	5f                   	pop    %edi
f0103bc9:	5d                   	pop    %ebp
f0103bca:	c3                   	ret    

f0103bcb <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103bcb:	55                   	push   %ebp
f0103bcc:	89 e5                	mov    %esp,%ebp
f0103bce:	57                   	push   %edi
f0103bcf:	56                   	push   %esi
f0103bd0:	53                   	push   %ebx
f0103bd1:	83 ec 3c             	sub    $0x3c,%esp
f0103bd4:	8b 75 08             	mov    0x8(%ebp),%esi
f0103bd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103bda:	c7 03 a8 62 10 f0    	movl   $0xf01062a8,(%ebx)
	info->eip_line = 0;
f0103be0:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103be7:	c7 43 08 a8 62 10 f0 	movl   $0xf01062a8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103bee:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103bf5:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103bf8:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103bff:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103c05:	77 7e                	ja     f0103c85 <debuginfo_eip+0xba>
		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f0103c07:	6a 04                	push   $0x4
f0103c09:	6a 10                	push   $0x10
f0103c0b:	68 00 00 20 00       	push   $0x200000
f0103c10:	ff 35 48 d1 17 f0    	pushl  0xf017d148
f0103c16:	e8 24 ef ff ff       	call   f0102b3f <user_mem_check>
f0103c1b:	83 c4 10             	add    $0x10,%esp
f0103c1e:	85 c0                	test   %eax,%eax
f0103c20:	0f 85 18 02 00 00    	jne    f0103e3e <debuginfo_eip+0x273>
			return -1;

		stabs = usd->stabs;
f0103c26:	a1 00 00 20 00       	mov    0x200000,%eax
f0103c2b:	89 c1                	mov    %eax,%ecx
f0103c2d:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0103c30:	8b 3d 04 00 20 00    	mov    0x200004,%edi
		stabstr = usd->stabstr;
f0103c36:	a1 08 00 20 00       	mov    0x200008,%eax
f0103c3b:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stabstr_end = usd->stabstr_end;
f0103c3e:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0103c44:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0103c47:	6a 04                	push   $0x4
f0103c49:	6a 0c                	push   $0xc
f0103c4b:	51                   	push   %ecx
f0103c4c:	ff 35 48 d1 17 f0    	pushl  0xf017d148
f0103c52:	e8 e8 ee ff ff       	call   f0102b3f <user_mem_check>
f0103c57:	83 c4 10             	add    $0x10,%esp
f0103c5a:	85 c0                	test   %eax,%eax
f0103c5c:	0f 85 e3 01 00 00    	jne    f0103e45 <debuginfo_eip+0x27a>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f0103c62:	6a 04                	push   $0x4
f0103c64:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0103c67:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f0103c6a:	29 ca                	sub    %ecx,%edx
f0103c6c:	52                   	push   %edx
f0103c6d:	51                   	push   %ecx
f0103c6e:	ff 35 48 d1 17 f0    	pushl  0xf017d148
f0103c74:	e8 c6 ee ff ff       	call   f0102b3f <user_mem_check>
f0103c79:	83 c4 10             	add    $0x10,%esp
f0103c7c:	85 c0                	test   %eax,%eax
f0103c7e:	74 1f                	je     f0103c9f <debuginfo_eip+0xd4>
f0103c80:	e9 c7 01 00 00       	jmp    f0103e4c <debuginfo_eip+0x281>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103c85:	c7 45 bc 67 0f 11 f0 	movl   $0xf0110f67,-0x44(%ebp)
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103c8c:	c7 45 b8 1d e4 10 f0 	movl   $0xf010e41d,-0x48(%ebp)
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103c93:	bf 1c e4 10 f0       	mov    $0xf010e41c,%edi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;
	// return 0;
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0103c98:	c7 45 c0 c0 64 10 f0 	movl   $0xf01064c0,-0x40(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103c9f:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103ca2:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0103ca5:	0f 83 a8 01 00 00    	jae    f0103e53 <debuginfo_eip+0x288>
f0103cab:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0103caf:	0f 85 a5 01 00 00    	jne    f0103e5a <debuginfo_eip+0x28f>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103cb5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103cbc:	2b 7d c0             	sub    -0x40(%ebp),%edi
f0103cbf:	c1 ff 02             	sar    $0x2,%edi
f0103cc2:	69 c7 ab aa aa aa    	imul   $0xaaaaaaab,%edi,%eax
f0103cc8:	83 e8 01             	sub    $0x1,%eax
f0103ccb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103cce:	83 ec 08             	sub    $0x8,%esp
f0103cd1:	56                   	push   %esi
f0103cd2:	6a 64                	push   $0x64
f0103cd4:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0103cd7:	89 d1                	mov    %edx,%ecx
f0103cd9:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103cdc:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103cdf:	89 f8                	mov    %edi,%eax
f0103ce1:	e8 ef fd ff ff       	call   f0103ad5 <stab_binsearch>
	if (lfile == 0)
f0103ce6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ce9:	83 c4 10             	add    $0x10,%esp
f0103cec:	85 c0                	test   %eax,%eax
f0103cee:	0f 84 6d 01 00 00    	je     f0103e61 <debuginfo_eip+0x296>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103cf4:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103cf7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103cfa:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103cfd:	83 ec 08             	sub    $0x8,%esp
f0103d00:	56                   	push   %esi
f0103d01:	6a 24                	push   $0x24
f0103d03:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0103d06:	89 d1                	mov    %edx,%ecx
f0103d08:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103d0b:	89 f8                	mov    %edi,%eax
f0103d0d:	e8 c3 fd ff ff       	call   f0103ad5 <stab_binsearch>

	if (lfun <= rfun) {
f0103d12:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103d15:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103d18:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f0103d1b:	83 c4 10             	add    $0x10,%esp
f0103d1e:	39 d0                	cmp    %edx,%eax
f0103d20:	7f 2b                	jg     f0103d4d <debuginfo_eip+0x182>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103d22:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103d25:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0103d28:	8b 11                	mov    (%ecx),%edx
f0103d2a:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0103d2d:	2b 7d b8             	sub    -0x48(%ebp),%edi
f0103d30:	39 fa                	cmp    %edi,%edx
f0103d32:	73 06                	jae    f0103d3a <debuginfo_eip+0x16f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103d34:	03 55 b8             	add    -0x48(%ebp),%edx
f0103d37:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103d3a:	8b 51 08             	mov    0x8(%ecx),%edx
f0103d3d:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0103d40:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0103d42:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103d45:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103d48:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103d4b:	eb 0f                	jmp    f0103d5c <debuginfo_eip+0x191>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103d4d:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103d50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103d56:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d59:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103d5c:	83 ec 08             	sub    $0x8,%esp
f0103d5f:	6a 3a                	push   $0x3a
f0103d61:	ff 73 08             	pushl  0x8(%ebx)
f0103d64:	e8 c5 08 00 00       	call   f010462e <strfind>
f0103d69:	2b 43 08             	sub    0x8(%ebx),%eax
f0103d6c:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103d6f:	83 c4 08             	add    $0x8,%esp
f0103d72:	56                   	push   %esi
f0103d73:	6a 44                	push   $0x44
f0103d75:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103d78:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103d7b:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103d7e:	89 f8                	mov    %edi,%eax
f0103d80:	e8 50 fd ff ff       	call   f0103ad5 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0103d85:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103d88:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103d8b:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103d8e:	0f b7 4a 06          	movzwl 0x6(%edx),%ecx
f0103d92:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103d95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103d98:	83 c4 10             	add    $0x10,%esp
f0103d9b:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0103d9f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103da2:	eb 0a                	jmp    f0103dae <debuginfo_eip+0x1e3>
f0103da4:	83 e8 01             	sub    $0x1,%eax
f0103da7:	83 ea 0c             	sub    $0xc,%edx
f0103daa:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0103dae:	39 c7                	cmp    %eax,%edi
f0103db0:	7e 05                	jle    f0103db7 <debuginfo_eip+0x1ec>
f0103db2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103db5:	eb 47                	jmp    f0103dfe <debuginfo_eip+0x233>
	       && stabs[lline].n_type != N_SOL
f0103db7:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103dbb:	80 f9 84             	cmp    $0x84,%cl
f0103dbe:	75 0e                	jne    f0103dce <debuginfo_eip+0x203>
f0103dc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103dc3:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103dc7:	74 1c                	je     f0103de5 <debuginfo_eip+0x21a>
f0103dc9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0103dcc:	eb 17                	jmp    f0103de5 <debuginfo_eip+0x21a>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103dce:	80 f9 64             	cmp    $0x64,%cl
f0103dd1:	75 d1                	jne    f0103da4 <debuginfo_eip+0x1d9>
f0103dd3:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0103dd7:	74 cb                	je     f0103da4 <debuginfo_eip+0x1d9>
f0103dd9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103ddc:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103de0:	74 03                	je     f0103de5 <debuginfo_eip+0x21a>
f0103de2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103de5:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103de8:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103deb:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103dee:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0103df1:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0103df4:	29 f0                	sub    %esi,%eax
f0103df6:	39 c2                	cmp    %eax,%edx
f0103df8:	73 04                	jae    f0103dfe <debuginfo_eip+0x233>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103dfa:	01 f2                	add    %esi,%edx
f0103dfc:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103dfe:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103e01:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103e04:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103e09:	39 f2                	cmp    %esi,%edx
f0103e0b:	7d 60                	jge    f0103e6d <debuginfo_eip+0x2a2>
		for (lline = lfun + 1;
f0103e0d:	83 c2 01             	add    $0x1,%edx
f0103e10:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0103e13:	89 d0                	mov    %edx,%eax
f0103e15:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0103e18:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103e1b:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103e1e:	eb 04                	jmp    f0103e24 <debuginfo_eip+0x259>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103e20:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103e24:	39 c6                	cmp    %eax,%esi
f0103e26:	7e 40                	jle    f0103e68 <debuginfo_eip+0x29d>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103e28:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103e2c:	83 c0 01             	add    $0x1,%eax
f0103e2f:	83 c2 0c             	add    $0xc,%edx
f0103e32:	80 f9 a0             	cmp    $0xa0,%cl
f0103e35:	74 e9                	je     f0103e20 <debuginfo_eip+0x255>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103e37:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e3c:	eb 2f                	jmp    f0103e6d <debuginfo_eip+0x2a2>
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		// user_mem_check
		//
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0103e3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103e43:	eb 28                	jmp    f0103e6d <debuginfo_eip+0x2a2>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0103e45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103e4a:	eb 21                	jmp    f0103e6d <debuginfo_eip+0x2a2>

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
f0103e4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103e51:	eb 1a                	jmp    f0103e6d <debuginfo_eip+0x2a2>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0103e53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103e58:	eb 13                	jmp    f0103e6d <debuginfo_eip+0x2a2>
f0103e5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103e5f:	eb 0c                	jmp    f0103e6d <debuginfo_eip+0x2a2>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103e61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103e66:	eb 05                	jmp    f0103e6d <debuginfo_eip+0x2a2>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103e68:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103e6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e70:	5b                   	pop    %ebx
f0103e71:	5e                   	pop    %esi
f0103e72:	5f                   	pop    %edi
f0103e73:	5d                   	pop    %ebp
f0103e74:	c3                   	ret    

f0103e75 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103e75:	55                   	push   %ebp
f0103e76:	89 e5                	mov    %esp,%ebp
f0103e78:	57                   	push   %edi
f0103e79:	56                   	push   %esi
f0103e7a:	53                   	push   %ebx
f0103e7b:	83 ec 1c             	sub    $0x1c,%esp
f0103e7e:	89 c7                	mov    %eax,%edi
f0103e80:	89 d6                	mov    %edx,%esi
f0103e82:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e85:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103e88:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103e8b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103e8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103e91:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103e96:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103e99:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0103e9c:	39 d3                	cmp    %edx,%ebx
f0103e9e:	72 05                	jb     f0103ea5 <printnum+0x30>
f0103ea0:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103ea3:	77 45                	ja     f0103eea <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103ea5:	83 ec 0c             	sub    $0xc,%esp
f0103ea8:	ff 75 18             	pushl  0x18(%ebp)
f0103eab:	8b 45 14             	mov    0x14(%ebp),%eax
f0103eae:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103eb1:	53                   	push   %ebx
f0103eb2:	ff 75 10             	pushl  0x10(%ebp)
f0103eb5:	83 ec 08             	sub    $0x8,%esp
f0103eb8:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103ebb:	ff 75 e0             	pushl  -0x20(%ebp)
f0103ebe:	ff 75 dc             	pushl  -0x24(%ebp)
f0103ec1:	ff 75 d8             	pushl  -0x28(%ebp)
f0103ec4:	e8 87 09 00 00       	call   f0104850 <__udivdi3>
f0103ec9:	83 c4 18             	add    $0x18,%esp
f0103ecc:	52                   	push   %edx
f0103ecd:	50                   	push   %eax
f0103ece:	89 f2                	mov    %esi,%edx
f0103ed0:	89 f8                	mov    %edi,%eax
f0103ed2:	e8 9e ff ff ff       	call   f0103e75 <printnum>
f0103ed7:	83 c4 20             	add    $0x20,%esp
f0103eda:	eb 18                	jmp    f0103ef4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103edc:	83 ec 08             	sub    $0x8,%esp
f0103edf:	56                   	push   %esi
f0103ee0:	ff 75 18             	pushl  0x18(%ebp)
f0103ee3:	ff d7                	call   *%edi
f0103ee5:	83 c4 10             	add    $0x10,%esp
f0103ee8:	eb 03                	jmp    f0103eed <printnum+0x78>
f0103eea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103eed:	83 eb 01             	sub    $0x1,%ebx
f0103ef0:	85 db                	test   %ebx,%ebx
f0103ef2:	7f e8                	jg     f0103edc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103ef4:	83 ec 08             	sub    $0x8,%esp
f0103ef7:	56                   	push   %esi
f0103ef8:	83 ec 04             	sub    $0x4,%esp
f0103efb:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103efe:	ff 75 e0             	pushl  -0x20(%ebp)
f0103f01:	ff 75 dc             	pushl  -0x24(%ebp)
f0103f04:	ff 75 d8             	pushl  -0x28(%ebp)
f0103f07:	e8 74 0a 00 00       	call   f0104980 <__umoddi3>
f0103f0c:	83 c4 14             	add    $0x14,%esp
f0103f0f:	0f be 80 b2 62 10 f0 	movsbl -0xfef9d4e(%eax),%eax
f0103f16:	50                   	push   %eax
f0103f17:	ff d7                	call   *%edi
}
f0103f19:	83 c4 10             	add    $0x10,%esp
f0103f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103f1f:	5b                   	pop    %ebx
f0103f20:	5e                   	pop    %esi
f0103f21:	5f                   	pop    %edi
f0103f22:	5d                   	pop    %ebp
f0103f23:	c3                   	ret    

f0103f24 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103f24:	55                   	push   %ebp
f0103f25:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103f27:	83 fa 01             	cmp    $0x1,%edx
f0103f2a:	7e 0e                	jle    f0103f3a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103f2c:	8b 10                	mov    (%eax),%edx
f0103f2e:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103f31:	89 08                	mov    %ecx,(%eax)
f0103f33:	8b 02                	mov    (%edx),%eax
f0103f35:	8b 52 04             	mov    0x4(%edx),%edx
f0103f38:	eb 22                	jmp    f0103f5c <getuint+0x38>
	else if (lflag)
f0103f3a:	85 d2                	test   %edx,%edx
f0103f3c:	74 10                	je     f0103f4e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103f3e:	8b 10                	mov    (%eax),%edx
f0103f40:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103f43:	89 08                	mov    %ecx,(%eax)
f0103f45:	8b 02                	mov    (%edx),%eax
f0103f47:	ba 00 00 00 00       	mov    $0x0,%edx
f0103f4c:	eb 0e                	jmp    f0103f5c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103f4e:	8b 10                	mov    (%eax),%edx
f0103f50:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103f53:	89 08                	mov    %ecx,(%eax)
f0103f55:	8b 02                	mov    (%edx),%eax
f0103f57:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103f5c:	5d                   	pop    %ebp
f0103f5d:	c3                   	ret    

f0103f5e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103f5e:	55                   	push   %ebp
f0103f5f:	89 e5                	mov    %esp,%ebp
f0103f61:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103f64:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103f68:	8b 10                	mov    (%eax),%edx
f0103f6a:	3b 50 04             	cmp    0x4(%eax),%edx
f0103f6d:	73 0a                	jae    f0103f79 <sprintputch+0x1b>
		*b->buf++ = ch;
f0103f6f:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103f72:	89 08                	mov    %ecx,(%eax)
f0103f74:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f77:	88 02                	mov    %al,(%edx)
}
f0103f79:	5d                   	pop    %ebp
f0103f7a:	c3                   	ret    

f0103f7b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103f7b:	55                   	push   %ebp
f0103f7c:	89 e5                	mov    %esp,%ebp
f0103f7e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103f81:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103f84:	50                   	push   %eax
f0103f85:	ff 75 10             	pushl  0x10(%ebp)
f0103f88:	ff 75 0c             	pushl  0xc(%ebp)
f0103f8b:	ff 75 08             	pushl  0x8(%ebp)
f0103f8e:	e8 05 00 00 00       	call   f0103f98 <vprintfmt>
	va_end(ap);
}
f0103f93:	83 c4 10             	add    $0x10,%esp
f0103f96:	c9                   	leave  
f0103f97:	c3                   	ret    

f0103f98 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103f98:	55                   	push   %ebp
f0103f99:	89 e5                	mov    %esp,%ebp
f0103f9b:	57                   	push   %edi
f0103f9c:	56                   	push   %esi
f0103f9d:	53                   	push   %ebx
f0103f9e:	83 ec 2c             	sub    $0x2c,%esp
f0103fa1:	8b 75 08             	mov    0x8(%ebp),%esi
f0103fa4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103fa7:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103faa:	eb 1d                	jmp    f0103fc9 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
f0103fac:	85 c0                	test   %eax,%eax
f0103fae:	75 0f                	jne    f0103fbf <vprintfmt+0x27>
				csa = 0x0700;
f0103fb0:	c7 05 10 de 17 f0 00 	movl   $0x700,0xf017de10
f0103fb7:	07 00 00 
				return;
f0103fba:	e9 c4 03 00 00       	jmp    f0104383 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
f0103fbf:	83 ec 08             	sub    $0x8,%esp
f0103fc2:	53                   	push   %ebx
f0103fc3:	50                   	push   %eax
f0103fc4:	ff d6                	call   *%esi
f0103fc6:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103fc9:	83 c7 01             	add    $0x1,%edi
f0103fcc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103fd0:	83 f8 25             	cmp    $0x25,%eax
f0103fd3:	75 d7                	jne    f0103fac <vprintfmt+0x14>
f0103fd5:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103fd9:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103fe0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103fe7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103fee:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ff3:	eb 07                	jmp    f0103ffc <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ff5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103ff8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ffc:	8d 47 01             	lea    0x1(%edi),%eax
f0103fff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104002:	0f b6 07             	movzbl (%edi),%eax
f0104005:	0f b6 c8             	movzbl %al,%ecx
f0104008:	83 e8 23             	sub    $0x23,%eax
f010400b:	3c 55                	cmp    $0x55,%al
f010400d:	0f 87 55 03 00 00    	ja     f0104368 <vprintfmt+0x3d0>
f0104013:	0f b6 c0             	movzbl %al,%eax
f0104016:	ff 24 85 3c 63 10 f0 	jmp    *-0xfef9cc4(,%eax,4)
f010401d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104020:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104024:	eb d6                	jmp    f0103ffc <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104026:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104029:	b8 00 00 00 00       	mov    $0x0,%eax
f010402e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104031:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104034:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104038:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f010403b:	8d 51 d0             	lea    -0x30(%ecx),%edx
f010403e:	83 fa 09             	cmp    $0x9,%edx
f0104041:	77 39                	ja     f010407c <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104043:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104046:	eb e9                	jmp    f0104031 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104048:	8b 45 14             	mov    0x14(%ebp),%eax
f010404b:	8d 48 04             	lea    0x4(%eax),%ecx
f010404e:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104051:	8b 00                	mov    (%eax),%eax
f0104053:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104056:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104059:	eb 27                	jmp    f0104082 <vprintfmt+0xea>
f010405b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010405e:	85 c0                	test   %eax,%eax
f0104060:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104065:	0f 49 c8             	cmovns %eax,%ecx
f0104068:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010406b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010406e:	eb 8c                	jmp    f0103ffc <vprintfmt+0x64>
f0104070:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104073:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f010407a:	eb 80                	jmp    f0103ffc <vprintfmt+0x64>
f010407c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010407f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104082:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104086:	0f 89 70 ff ff ff    	jns    f0103ffc <vprintfmt+0x64>
				width = precision, precision = -1;
f010408c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010408f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104092:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104099:	e9 5e ff ff ff       	jmp    f0103ffc <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010409e:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01040a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01040a4:	e9 53 ff ff ff       	jmp    f0103ffc <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01040a9:	8b 45 14             	mov    0x14(%ebp),%eax
f01040ac:	8d 50 04             	lea    0x4(%eax),%edx
f01040af:	89 55 14             	mov    %edx,0x14(%ebp)
f01040b2:	83 ec 08             	sub    $0x8,%esp
f01040b5:	53                   	push   %ebx
f01040b6:	ff 30                	pushl  (%eax)
f01040b8:	ff d6                	call   *%esi
			break;
f01040ba:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01040bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01040c0:	e9 04 ff ff ff       	jmp    f0103fc9 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01040c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01040c8:	8d 50 04             	lea    0x4(%eax),%edx
f01040cb:	89 55 14             	mov    %edx,0x14(%ebp)
f01040ce:	8b 00                	mov    (%eax),%eax
f01040d0:	99                   	cltd   
f01040d1:	31 d0                	xor    %edx,%eax
f01040d3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01040d5:	83 f8 06             	cmp    $0x6,%eax
f01040d8:	7f 0b                	jg     f01040e5 <vprintfmt+0x14d>
f01040da:	8b 14 85 94 64 10 f0 	mov    -0xfef9b6c(,%eax,4),%edx
f01040e1:	85 d2                	test   %edx,%edx
f01040e3:	75 18                	jne    f01040fd <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
f01040e5:	50                   	push   %eax
f01040e6:	68 ca 62 10 f0       	push   $0xf01062ca
f01040eb:	53                   	push   %ebx
f01040ec:	56                   	push   %esi
f01040ed:	e8 89 fe ff ff       	call   f0103f7b <printfmt>
f01040f2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01040f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01040f8:	e9 cc fe ff ff       	jmp    f0103fc9 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
f01040fd:	52                   	push   %edx
f01040fe:	68 38 52 10 f0       	push   $0xf0105238
f0104103:	53                   	push   %ebx
f0104104:	56                   	push   %esi
f0104105:	e8 71 fe ff ff       	call   f0103f7b <printfmt>
f010410a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010410d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104110:	e9 b4 fe ff ff       	jmp    f0103fc9 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104115:	8b 45 14             	mov    0x14(%ebp),%eax
f0104118:	8d 50 04             	lea    0x4(%eax),%edx
f010411b:	89 55 14             	mov    %edx,0x14(%ebp)
f010411e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104120:	85 ff                	test   %edi,%edi
f0104122:	b8 c3 62 10 f0       	mov    $0xf01062c3,%eax
f0104127:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f010412a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010412e:	0f 8e 94 00 00 00    	jle    f01041c8 <vprintfmt+0x230>
f0104134:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104138:	0f 84 98 00 00 00    	je     f01041d6 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
f010413e:	83 ec 08             	sub    $0x8,%esp
f0104141:	ff 75 d0             	pushl  -0x30(%ebp)
f0104144:	57                   	push   %edi
f0104145:	e8 9a 03 00 00       	call   f01044e4 <strnlen>
f010414a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010414d:	29 c1                	sub    %eax,%ecx
f010414f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104152:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104155:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104159:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010415c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010415f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104161:	eb 0f                	jmp    f0104172 <vprintfmt+0x1da>
					putch(padc, putdat);
f0104163:	83 ec 08             	sub    $0x8,%esp
f0104166:	53                   	push   %ebx
f0104167:	ff 75 e0             	pushl  -0x20(%ebp)
f010416a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010416c:	83 ef 01             	sub    $0x1,%edi
f010416f:	83 c4 10             	add    $0x10,%esp
f0104172:	85 ff                	test   %edi,%edi
f0104174:	7f ed                	jg     f0104163 <vprintfmt+0x1cb>
f0104176:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104179:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010417c:	85 c9                	test   %ecx,%ecx
f010417e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104183:	0f 49 c1             	cmovns %ecx,%eax
f0104186:	29 c1                	sub    %eax,%ecx
f0104188:	89 75 08             	mov    %esi,0x8(%ebp)
f010418b:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010418e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104191:	89 cb                	mov    %ecx,%ebx
f0104193:	eb 4d                	jmp    f01041e2 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104195:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104199:	74 1b                	je     f01041b6 <vprintfmt+0x21e>
f010419b:	0f be c0             	movsbl %al,%eax
f010419e:	83 e8 20             	sub    $0x20,%eax
f01041a1:	83 f8 5e             	cmp    $0x5e,%eax
f01041a4:	76 10                	jbe    f01041b6 <vprintfmt+0x21e>
					putch('?', putdat);
f01041a6:	83 ec 08             	sub    $0x8,%esp
f01041a9:	ff 75 0c             	pushl  0xc(%ebp)
f01041ac:	6a 3f                	push   $0x3f
f01041ae:	ff 55 08             	call   *0x8(%ebp)
f01041b1:	83 c4 10             	add    $0x10,%esp
f01041b4:	eb 0d                	jmp    f01041c3 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
f01041b6:	83 ec 08             	sub    $0x8,%esp
f01041b9:	ff 75 0c             	pushl  0xc(%ebp)
f01041bc:	52                   	push   %edx
f01041bd:	ff 55 08             	call   *0x8(%ebp)
f01041c0:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01041c3:	83 eb 01             	sub    $0x1,%ebx
f01041c6:	eb 1a                	jmp    f01041e2 <vprintfmt+0x24a>
f01041c8:	89 75 08             	mov    %esi,0x8(%ebp)
f01041cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01041ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01041d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01041d4:	eb 0c                	jmp    f01041e2 <vprintfmt+0x24a>
f01041d6:	89 75 08             	mov    %esi,0x8(%ebp)
f01041d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01041dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01041df:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01041e2:	83 c7 01             	add    $0x1,%edi
f01041e5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01041e9:	0f be d0             	movsbl %al,%edx
f01041ec:	85 d2                	test   %edx,%edx
f01041ee:	74 23                	je     f0104213 <vprintfmt+0x27b>
f01041f0:	85 f6                	test   %esi,%esi
f01041f2:	78 a1                	js     f0104195 <vprintfmt+0x1fd>
f01041f4:	83 ee 01             	sub    $0x1,%esi
f01041f7:	79 9c                	jns    f0104195 <vprintfmt+0x1fd>
f01041f9:	89 df                	mov    %ebx,%edi
f01041fb:	8b 75 08             	mov    0x8(%ebp),%esi
f01041fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104201:	eb 18                	jmp    f010421b <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104203:	83 ec 08             	sub    $0x8,%esp
f0104206:	53                   	push   %ebx
f0104207:	6a 20                	push   $0x20
f0104209:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010420b:	83 ef 01             	sub    $0x1,%edi
f010420e:	83 c4 10             	add    $0x10,%esp
f0104211:	eb 08                	jmp    f010421b <vprintfmt+0x283>
f0104213:	89 df                	mov    %ebx,%edi
f0104215:	8b 75 08             	mov    0x8(%ebp),%esi
f0104218:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010421b:	85 ff                	test   %edi,%edi
f010421d:	7f e4                	jg     f0104203 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010421f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104222:	e9 a2 fd ff ff       	jmp    f0103fc9 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104227:	83 fa 01             	cmp    $0x1,%edx
f010422a:	7e 16                	jle    f0104242 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
f010422c:	8b 45 14             	mov    0x14(%ebp),%eax
f010422f:	8d 50 08             	lea    0x8(%eax),%edx
f0104232:	89 55 14             	mov    %edx,0x14(%ebp)
f0104235:	8b 50 04             	mov    0x4(%eax),%edx
f0104238:	8b 00                	mov    (%eax),%eax
f010423a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010423d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104240:	eb 32                	jmp    f0104274 <vprintfmt+0x2dc>
	else if (lflag)
f0104242:	85 d2                	test   %edx,%edx
f0104244:	74 18                	je     f010425e <vprintfmt+0x2c6>
		return va_arg(*ap, long);
f0104246:	8b 45 14             	mov    0x14(%ebp),%eax
f0104249:	8d 50 04             	lea    0x4(%eax),%edx
f010424c:	89 55 14             	mov    %edx,0x14(%ebp)
f010424f:	8b 00                	mov    (%eax),%eax
f0104251:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104254:	89 c1                	mov    %eax,%ecx
f0104256:	c1 f9 1f             	sar    $0x1f,%ecx
f0104259:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010425c:	eb 16                	jmp    f0104274 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
f010425e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104261:	8d 50 04             	lea    0x4(%eax),%edx
f0104264:	89 55 14             	mov    %edx,0x14(%ebp)
f0104267:	8b 00                	mov    (%eax),%eax
f0104269:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010426c:	89 c1                	mov    %eax,%ecx
f010426e:	c1 f9 1f             	sar    $0x1f,%ecx
f0104271:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104274:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104277:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010427a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010427f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104283:	79 74                	jns    f01042f9 <vprintfmt+0x361>
				putch('-', putdat);
f0104285:	83 ec 08             	sub    $0x8,%esp
f0104288:	53                   	push   %ebx
f0104289:	6a 2d                	push   $0x2d
f010428b:	ff d6                	call   *%esi
				num = -(long long) num;
f010428d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104290:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104293:	f7 d8                	neg    %eax
f0104295:	83 d2 00             	adc    $0x0,%edx
f0104298:	f7 da                	neg    %edx
f010429a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010429d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01042a2:	eb 55                	jmp    f01042f9 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01042a4:	8d 45 14             	lea    0x14(%ebp),%eax
f01042a7:	e8 78 fc ff ff       	call   f0103f24 <getuint>
			base = 10;
f01042ac:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01042b1:	eb 46                	jmp    f01042f9 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
f01042b3:	8d 45 14             	lea    0x14(%ebp),%eax
f01042b6:	e8 69 fc ff ff       	call   f0103f24 <getuint>
      base = 8;
f01042bb:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
f01042c0:	eb 37                	jmp    f01042f9 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
f01042c2:	83 ec 08             	sub    $0x8,%esp
f01042c5:	53                   	push   %ebx
f01042c6:	6a 30                	push   $0x30
f01042c8:	ff d6                	call   *%esi
			putch('x', putdat);
f01042ca:	83 c4 08             	add    $0x8,%esp
f01042cd:	53                   	push   %ebx
f01042ce:	6a 78                	push   $0x78
f01042d0:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01042d2:	8b 45 14             	mov    0x14(%ebp),%eax
f01042d5:	8d 50 04             	lea    0x4(%eax),%edx
f01042d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01042db:	8b 00                	mov    (%eax),%eax
f01042dd:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f01042e2:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01042e5:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01042ea:	eb 0d                	jmp    f01042f9 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01042ec:	8d 45 14             	lea    0x14(%ebp),%eax
f01042ef:	e8 30 fc ff ff       	call   f0103f24 <getuint>
			base = 16;
f01042f4:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01042f9:	83 ec 0c             	sub    $0xc,%esp
f01042fc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104300:	57                   	push   %edi
f0104301:	ff 75 e0             	pushl  -0x20(%ebp)
f0104304:	51                   	push   %ecx
f0104305:	52                   	push   %edx
f0104306:	50                   	push   %eax
f0104307:	89 da                	mov    %ebx,%edx
f0104309:	89 f0                	mov    %esi,%eax
f010430b:	e8 65 fb ff ff       	call   f0103e75 <printnum>
			break;
f0104310:	83 c4 20             	add    $0x20,%esp
f0104313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104316:	e9 ae fc ff ff       	jmp    f0103fc9 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010431b:	83 ec 08             	sub    $0x8,%esp
f010431e:	53                   	push   %ebx
f010431f:	51                   	push   %ecx
f0104320:	ff d6                	call   *%esi
			break;
f0104322:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104328:	e9 9c fc ff ff       	jmp    f0103fc9 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010432d:	83 fa 01             	cmp    $0x1,%edx
f0104330:	7e 0d                	jle    f010433f <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
f0104332:	8b 45 14             	mov    0x14(%ebp),%eax
f0104335:	8d 50 08             	lea    0x8(%eax),%edx
f0104338:	89 55 14             	mov    %edx,0x14(%ebp)
f010433b:	8b 00                	mov    (%eax),%eax
f010433d:	eb 1c                	jmp    f010435b <vprintfmt+0x3c3>
	else if (lflag)
f010433f:	85 d2                	test   %edx,%edx
f0104341:	74 0d                	je     f0104350 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
f0104343:	8b 45 14             	mov    0x14(%ebp),%eax
f0104346:	8d 50 04             	lea    0x4(%eax),%edx
f0104349:	89 55 14             	mov    %edx,0x14(%ebp)
f010434c:	8b 00                	mov    (%eax),%eax
f010434e:	eb 0b                	jmp    f010435b <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
f0104350:	8b 45 14             	mov    0x14(%ebp),%eax
f0104353:	8d 50 04             	lea    0x4(%eax),%edx
f0104356:	89 55 14             	mov    %edx,0x14(%ebp)
f0104359:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
f010435b:	a3 10 de 17 f0       	mov    %eax,0xf017de10
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
f0104363:	e9 61 fc ff ff       	jmp    f0103fc9 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104368:	83 ec 08             	sub    $0x8,%esp
f010436b:	53                   	push   %ebx
f010436c:	6a 25                	push   $0x25
f010436e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104370:	83 c4 10             	add    $0x10,%esp
f0104373:	eb 03                	jmp    f0104378 <vprintfmt+0x3e0>
f0104375:	83 ef 01             	sub    $0x1,%edi
f0104378:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010437c:	75 f7                	jne    f0104375 <vprintfmt+0x3dd>
f010437e:	e9 46 fc ff ff       	jmp    f0103fc9 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
f0104383:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104386:	5b                   	pop    %ebx
f0104387:	5e                   	pop    %esi
f0104388:	5f                   	pop    %edi
f0104389:	5d                   	pop    %ebp
f010438a:	c3                   	ret    

f010438b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010438b:	55                   	push   %ebp
f010438c:	89 e5                	mov    %esp,%ebp
f010438e:	83 ec 18             	sub    $0x18,%esp
f0104391:	8b 45 08             	mov    0x8(%ebp),%eax
f0104394:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104397:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010439a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010439e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01043a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01043a8:	85 c0                	test   %eax,%eax
f01043aa:	74 26                	je     f01043d2 <vsnprintf+0x47>
f01043ac:	85 d2                	test   %edx,%edx
f01043ae:	7e 22                	jle    f01043d2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01043b0:	ff 75 14             	pushl  0x14(%ebp)
f01043b3:	ff 75 10             	pushl  0x10(%ebp)
f01043b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01043b9:	50                   	push   %eax
f01043ba:	68 5e 3f 10 f0       	push   $0xf0103f5e
f01043bf:	e8 d4 fb ff ff       	call   f0103f98 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01043c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01043c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01043ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01043cd:	83 c4 10             	add    $0x10,%esp
f01043d0:	eb 05                	jmp    f01043d7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01043d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01043d7:	c9                   	leave  
f01043d8:	c3                   	ret    

f01043d9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01043d9:	55                   	push   %ebp
f01043da:	89 e5                	mov    %esp,%ebp
f01043dc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01043df:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01043e2:	50                   	push   %eax
f01043e3:	ff 75 10             	pushl  0x10(%ebp)
f01043e6:	ff 75 0c             	pushl  0xc(%ebp)
f01043e9:	ff 75 08             	pushl  0x8(%ebp)
f01043ec:	e8 9a ff ff ff       	call   f010438b <vsnprintf>
	va_end(ap);

	return rc;
}
f01043f1:	c9                   	leave  
f01043f2:	c3                   	ret    

f01043f3 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01043f3:	55                   	push   %ebp
f01043f4:	89 e5                	mov    %esp,%ebp
f01043f6:	57                   	push   %edi
f01043f7:	56                   	push   %esi
f01043f8:	53                   	push   %ebx
f01043f9:	83 ec 0c             	sub    $0xc,%esp
f01043fc:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01043ff:	85 c0                	test   %eax,%eax
f0104401:	74 11                	je     f0104414 <readline+0x21>
		cprintf("%s", prompt);
f0104403:	83 ec 08             	sub    $0x8,%esp
f0104406:	50                   	push   %eax
f0104407:	68 38 52 10 f0       	push   $0xf0105238
f010440c:	e8 ef ee ff ff       	call   f0103300 <cprintf>
f0104411:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104414:	83 ec 0c             	sub    $0xc,%esp
f0104417:	6a 00                	push   $0x0
f0104419:	e8 7b c2 ff ff       	call   f0100699 <iscons>
f010441e:	89 c7                	mov    %eax,%edi
f0104420:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104423:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104428:	e8 5b c2 ff ff       	call   f0100688 <getchar>
f010442d:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010442f:	85 c0                	test   %eax,%eax
f0104431:	79 18                	jns    f010444b <readline+0x58>
			cprintf("read error: %e\n", c);
f0104433:	83 ec 08             	sub    $0x8,%esp
f0104436:	50                   	push   %eax
f0104437:	68 b0 64 10 f0       	push   $0xf01064b0
f010443c:	e8 bf ee ff ff       	call   f0103300 <cprintf>
			return NULL;
f0104441:	83 c4 10             	add    $0x10,%esp
f0104444:	b8 00 00 00 00       	mov    $0x0,%eax
f0104449:	eb 79                	jmp    f01044c4 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010444b:	83 f8 08             	cmp    $0x8,%eax
f010444e:	0f 94 c2             	sete   %dl
f0104451:	83 f8 7f             	cmp    $0x7f,%eax
f0104454:	0f 94 c0             	sete   %al
f0104457:	08 c2                	or     %al,%dl
f0104459:	74 1a                	je     f0104475 <readline+0x82>
f010445b:	85 f6                	test   %esi,%esi
f010445d:	7e 16                	jle    f0104475 <readline+0x82>
			if (echoing)
f010445f:	85 ff                	test   %edi,%edi
f0104461:	74 0d                	je     f0104470 <readline+0x7d>
				cputchar('\b');
f0104463:	83 ec 0c             	sub    $0xc,%esp
f0104466:	6a 08                	push   $0x8
f0104468:	e8 0b c2 ff ff       	call   f0100678 <cputchar>
f010446d:	83 c4 10             	add    $0x10,%esp
			i--;
f0104470:	83 ee 01             	sub    $0x1,%esi
f0104473:	eb b3                	jmp    f0104428 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104475:	83 fb 1f             	cmp    $0x1f,%ebx
f0104478:	7e 23                	jle    f010449d <readline+0xaa>
f010447a:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104480:	7f 1b                	jg     f010449d <readline+0xaa>
			if (echoing)
f0104482:	85 ff                	test   %edi,%edi
f0104484:	74 0c                	je     f0104492 <readline+0x9f>
				cputchar(c);
f0104486:	83 ec 0c             	sub    $0xc,%esp
f0104489:	53                   	push   %ebx
f010448a:	e8 e9 c1 ff ff       	call   f0100678 <cputchar>
f010448f:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104492:	88 9e 00 da 17 f0    	mov    %bl,-0xfe82600(%esi)
f0104498:	8d 76 01             	lea    0x1(%esi),%esi
f010449b:	eb 8b                	jmp    f0104428 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f010449d:	83 fb 0a             	cmp    $0xa,%ebx
f01044a0:	74 05                	je     f01044a7 <readline+0xb4>
f01044a2:	83 fb 0d             	cmp    $0xd,%ebx
f01044a5:	75 81                	jne    f0104428 <readline+0x35>
			if (echoing)
f01044a7:	85 ff                	test   %edi,%edi
f01044a9:	74 0d                	je     f01044b8 <readline+0xc5>
				cputchar('\n');
f01044ab:	83 ec 0c             	sub    $0xc,%esp
f01044ae:	6a 0a                	push   $0xa
f01044b0:	e8 c3 c1 ff ff       	call   f0100678 <cputchar>
f01044b5:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01044b8:	c6 86 00 da 17 f0 00 	movb   $0x0,-0xfe82600(%esi)
			return buf;
f01044bf:	b8 00 da 17 f0       	mov    $0xf017da00,%eax
		}
	}
}
f01044c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01044c7:	5b                   	pop    %ebx
f01044c8:	5e                   	pop    %esi
f01044c9:	5f                   	pop    %edi
f01044ca:	5d                   	pop    %ebp
f01044cb:	c3                   	ret    

f01044cc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01044cc:	55                   	push   %ebp
f01044cd:	89 e5                	mov    %esp,%ebp
f01044cf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01044d2:	b8 00 00 00 00       	mov    $0x0,%eax
f01044d7:	eb 03                	jmp    f01044dc <strlen+0x10>
		n++;
f01044d9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01044dc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01044e0:	75 f7                	jne    f01044d9 <strlen+0xd>
		n++;
	return n;
}
f01044e2:	5d                   	pop    %ebp
f01044e3:	c3                   	ret    

f01044e4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01044e4:	55                   	push   %ebp
f01044e5:	89 e5                	mov    %esp,%ebp
f01044e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01044ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01044ed:	ba 00 00 00 00       	mov    $0x0,%edx
f01044f2:	eb 03                	jmp    f01044f7 <strnlen+0x13>
		n++;
f01044f4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01044f7:	39 c2                	cmp    %eax,%edx
f01044f9:	74 08                	je     f0104503 <strnlen+0x1f>
f01044fb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f01044ff:	75 f3                	jne    f01044f4 <strnlen+0x10>
f0104501:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0104503:	5d                   	pop    %ebp
f0104504:	c3                   	ret    

f0104505 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104505:	55                   	push   %ebp
f0104506:	89 e5                	mov    %esp,%ebp
f0104508:	53                   	push   %ebx
f0104509:	8b 45 08             	mov    0x8(%ebp),%eax
f010450c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010450f:	89 c2                	mov    %eax,%edx
f0104511:	83 c2 01             	add    $0x1,%edx
f0104514:	83 c1 01             	add    $0x1,%ecx
f0104517:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010451b:	88 5a ff             	mov    %bl,-0x1(%edx)
f010451e:	84 db                	test   %bl,%bl
f0104520:	75 ef                	jne    f0104511 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104522:	5b                   	pop    %ebx
f0104523:	5d                   	pop    %ebp
f0104524:	c3                   	ret    

f0104525 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104525:	55                   	push   %ebp
f0104526:	89 e5                	mov    %esp,%ebp
f0104528:	53                   	push   %ebx
f0104529:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010452c:	53                   	push   %ebx
f010452d:	e8 9a ff ff ff       	call   f01044cc <strlen>
f0104532:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104535:	ff 75 0c             	pushl  0xc(%ebp)
f0104538:	01 d8                	add    %ebx,%eax
f010453a:	50                   	push   %eax
f010453b:	e8 c5 ff ff ff       	call   f0104505 <strcpy>
	return dst;
}
f0104540:	89 d8                	mov    %ebx,%eax
f0104542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104545:	c9                   	leave  
f0104546:	c3                   	ret    

f0104547 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104547:	55                   	push   %ebp
f0104548:	89 e5                	mov    %esp,%ebp
f010454a:	56                   	push   %esi
f010454b:	53                   	push   %ebx
f010454c:	8b 75 08             	mov    0x8(%ebp),%esi
f010454f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104552:	89 f3                	mov    %esi,%ebx
f0104554:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104557:	89 f2                	mov    %esi,%edx
f0104559:	eb 0f                	jmp    f010456a <strncpy+0x23>
		*dst++ = *src;
f010455b:	83 c2 01             	add    $0x1,%edx
f010455e:	0f b6 01             	movzbl (%ecx),%eax
f0104561:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104564:	80 39 01             	cmpb   $0x1,(%ecx)
f0104567:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010456a:	39 da                	cmp    %ebx,%edx
f010456c:	75 ed                	jne    f010455b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010456e:	89 f0                	mov    %esi,%eax
f0104570:	5b                   	pop    %ebx
f0104571:	5e                   	pop    %esi
f0104572:	5d                   	pop    %ebp
f0104573:	c3                   	ret    

f0104574 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104574:	55                   	push   %ebp
f0104575:	89 e5                	mov    %esp,%ebp
f0104577:	56                   	push   %esi
f0104578:	53                   	push   %ebx
f0104579:	8b 75 08             	mov    0x8(%ebp),%esi
f010457c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010457f:	8b 55 10             	mov    0x10(%ebp),%edx
f0104582:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104584:	85 d2                	test   %edx,%edx
f0104586:	74 21                	je     f01045a9 <strlcpy+0x35>
f0104588:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010458c:	89 f2                	mov    %esi,%edx
f010458e:	eb 09                	jmp    f0104599 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104590:	83 c2 01             	add    $0x1,%edx
f0104593:	83 c1 01             	add    $0x1,%ecx
f0104596:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104599:	39 c2                	cmp    %eax,%edx
f010459b:	74 09                	je     f01045a6 <strlcpy+0x32>
f010459d:	0f b6 19             	movzbl (%ecx),%ebx
f01045a0:	84 db                	test   %bl,%bl
f01045a2:	75 ec                	jne    f0104590 <strlcpy+0x1c>
f01045a4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01045a6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01045a9:	29 f0                	sub    %esi,%eax
}
f01045ab:	5b                   	pop    %ebx
f01045ac:	5e                   	pop    %esi
f01045ad:	5d                   	pop    %ebp
f01045ae:	c3                   	ret    

f01045af <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01045af:	55                   	push   %ebp
f01045b0:	89 e5                	mov    %esp,%ebp
f01045b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01045b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01045b8:	eb 06                	jmp    f01045c0 <strcmp+0x11>
		p++, q++;
f01045ba:	83 c1 01             	add    $0x1,%ecx
f01045bd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01045c0:	0f b6 01             	movzbl (%ecx),%eax
f01045c3:	84 c0                	test   %al,%al
f01045c5:	74 04                	je     f01045cb <strcmp+0x1c>
f01045c7:	3a 02                	cmp    (%edx),%al
f01045c9:	74 ef                	je     f01045ba <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01045cb:	0f b6 c0             	movzbl %al,%eax
f01045ce:	0f b6 12             	movzbl (%edx),%edx
f01045d1:	29 d0                	sub    %edx,%eax
}
f01045d3:	5d                   	pop    %ebp
f01045d4:	c3                   	ret    

f01045d5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01045d5:	55                   	push   %ebp
f01045d6:	89 e5                	mov    %esp,%ebp
f01045d8:	53                   	push   %ebx
f01045d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01045dc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01045df:	89 c3                	mov    %eax,%ebx
f01045e1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01045e4:	eb 06                	jmp    f01045ec <strncmp+0x17>
		n--, p++, q++;
f01045e6:	83 c0 01             	add    $0x1,%eax
f01045e9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01045ec:	39 d8                	cmp    %ebx,%eax
f01045ee:	74 15                	je     f0104605 <strncmp+0x30>
f01045f0:	0f b6 08             	movzbl (%eax),%ecx
f01045f3:	84 c9                	test   %cl,%cl
f01045f5:	74 04                	je     f01045fb <strncmp+0x26>
f01045f7:	3a 0a                	cmp    (%edx),%cl
f01045f9:	74 eb                	je     f01045e6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01045fb:	0f b6 00             	movzbl (%eax),%eax
f01045fe:	0f b6 12             	movzbl (%edx),%edx
f0104601:	29 d0                	sub    %edx,%eax
f0104603:	eb 05                	jmp    f010460a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104605:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010460a:	5b                   	pop    %ebx
f010460b:	5d                   	pop    %ebp
f010460c:	c3                   	ret    

f010460d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010460d:	55                   	push   %ebp
f010460e:	89 e5                	mov    %esp,%ebp
f0104610:	8b 45 08             	mov    0x8(%ebp),%eax
f0104613:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104617:	eb 07                	jmp    f0104620 <strchr+0x13>
		if (*s == c)
f0104619:	38 ca                	cmp    %cl,%dl
f010461b:	74 0f                	je     f010462c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010461d:	83 c0 01             	add    $0x1,%eax
f0104620:	0f b6 10             	movzbl (%eax),%edx
f0104623:	84 d2                	test   %dl,%dl
f0104625:	75 f2                	jne    f0104619 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104627:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010462c:	5d                   	pop    %ebp
f010462d:	c3                   	ret    

f010462e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010462e:	55                   	push   %ebp
f010462f:	89 e5                	mov    %esp,%ebp
f0104631:	8b 45 08             	mov    0x8(%ebp),%eax
f0104634:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104638:	eb 03                	jmp    f010463d <strfind+0xf>
f010463a:	83 c0 01             	add    $0x1,%eax
f010463d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0104640:	38 ca                	cmp    %cl,%dl
f0104642:	74 04                	je     f0104648 <strfind+0x1a>
f0104644:	84 d2                	test   %dl,%dl
f0104646:	75 f2                	jne    f010463a <strfind+0xc>
			break;
	return (char *) s;
}
f0104648:	5d                   	pop    %ebp
f0104649:	c3                   	ret    

f010464a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010464a:	55                   	push   %ebp
f010464b:	89 e5                	mov    %esp,%ebp
f010464d:	57                   	push   %edi
f010464e:	56                   	push   %esi
f010464f:	53                   	push   %ebx
f0104650:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104653:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104656:	85 c9                	test   %ecx,%ecx
f0104658:	74 36                	je     f0104690 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010465a:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104660:	75 28                	jne    f010468a <memset+0x40>
f0104662:	f6 c1 03             	test   $0x3,%cl
f0104665:	75 23                	jne    f010468a <memset+0x40>
		c &= 0xFF;
f0104667:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010466b:	89 d3                	mov    %edx,%ebx
f010466d:	c1 e3 08             	shl    $0x8,%ebx
f0104670:	89 d6                	mov    %edx,%esi
f0104672:	c1 e6 18             	shl    $0x18,%esi
f0104675:	89 d0                	mov    %edx,%eax
f0104677:	c1 e0 10             	shl    $0x10,%eax
f010467a:	09 f0                	or     %esi,%eax
f010467c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010467e:	89 d8                	mov    %ebx,%eax
f0104680:	09 d0                	or     %edx,%eax
f0104682:	c1 e9 02             	shr    $0x2,%ecx
f0104685:	fc                   	cld    
f0104686:	f3 ab                	rep stos %eax,%es:(%edi)
f0104688:	eb 06                	jmp    f0104690 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010468a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010468d:	fc                   	cld    
f010468e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104690:	89 f8                	mov    %edi,%eax
f0104692:	5b                   	pop    %ebx
f0104693:	5e                   	pop    %esi
f0104694:	5f                   	pop    %edi
f0104695:	5d                   	pop    %ebp
f0104696:	c3                   	ret    

f0104697 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104697:	55                   	push   %ebp
f0104698:	89 e5                	mov    %esp,%ebp
f010469a:	57                   	push   %edi
f010469b:	56                   	push   %esi
f010469c:	8b 45 08             	mov    0x8(%ebp),%eax
f010469f:	8b 75 0c             	mov    0xc(%ebp),%esi
f01046a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01046a5:	39 c6                	cmp    %eax,%esi
f01046a7:	73 35                	jae    f01046de <memmove+0x47>
f01046a9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01046ac:	39 d0                	cmp    %edx,%eax
f01046ae:	73 2e                	jae    f01046de <memmove+0x47>
		s += n;
		d += n;
f01046b0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01046b3:	89 d6                	mov    %edx,%esi
f01046b5:	09 fe                	or     %edi,%esi
f01046b7:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01046bd:	75 13                	jne    f01046d2 <memmove+0x3b>
f01046bf:	f6 c1 03             	test   $0x3,%cl
f01046c2:	75 0e                	jne    f01046d2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01046c4:	83 ef 04             	sub    $0x4,%edi
f01046c7:	8d 72 fc             	lea    -0x4(%edx),%esi
f01046ca:	c1 e9 02             	shr    $0x2,%ecx
f01046cd:	fd                   	std    
f01046ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01046d0:	eb 09                	jmp    f01046db <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01046d2:	83 ef 01             	sub    $0x1,%edi
f01046d5:	8d 72 ff             	lea    -0x1(%edx),%esi
f01046d8:	fd                   	std    
f01046d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01046db:	fc                   	cld    
f01046dc:	eb 1d                	jmp    f01046fb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01046de:	89 f2                	mov    %esi,%edx
f01046e0:	09 c2                	or     %eax,%edx
f01046e2:	f6 c2 03             	test   $0x3,%dl
f01046e5:	75 0f                	jne    f01046f6 <memmove+0x5f>
f01046e7:	f6 c1 03             	test   $0x3,%cl
f01046ea:	75 0a                	jne    f01046f6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01046ec:	c1 e9 02             	shr    $0x2,%ecx
f01046ef:	89 c7                	mov    %eax,%edi
f01046f1:	fc                   	cld    
f01046f2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01046f4:	eb 05                	jmp    f01046fb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01046f6:	89 c7                	mov    %eax,%edi
f01046f8:	fc                   	cld    
f01046f9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01046fb:	5e                   	pop    %esi
f01046fc:	5f                   	pop    %edi
f01046fd:	5d                   	pop    %ebp
f01046fe:	c3                   	ret    

f01046ff <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01046ff:	55                   	push   %ebp
f0104700:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104702:	ff 75 10             	pushl  0x10(%ebp)
f0104705:	ff 75 0c             	pushl  0xc(%ebp)
f0104708:	ff 75 08             	pushl  0x8(%ebp)
f010470b:	e8 87 ff ff ff       	call   f0104697 <memmove>
}
f0104710:	c9                   	leave  
f0104711:	c3                   	ret    

f0104712 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104712:	55                   	push   %ebp
f0104713:	89 e5                	mov    %esp,%ebp
f0104715:	56                   	push   %esi
f0104716:	53                   	push   %ebx
f0104717:	8b 45 08             	mov    0x8(%ebp),%eax
f010471a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010471d:	89 c6                	mov    %eax,%esi
f010471f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104722:	eb 1a                	jmp    f010473e <memcmp+0x2c>
		if (*s1 != *s2)
f0104724:	0f b6 08             	movzbl (%eax),%ecx
f0104727:	0f b6 1a             	movzbl (%edx),%ebx
f010472a:	38 d9                	cmp    %bl,%cl
f010472c:	74 0a                	je     f0104738 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010472e:	0f b6 c1             	movzbl %cl,%eax
f0104731:	0f b6 db             	movzbl %bl,%ebx
f0104734:	29 d8                	sub    %ebx,%eax
f0104736:	eb 0f                	jmp    f0104747 <memcmp+0x35>
		s1++, s2++;
f0104738:	83 c0 01             	add    $0x1,%eax
f010473b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010473e:	39 f0                	cmp    %esi,%eax
f0104740:	75 e2                	jne    f0104724 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104742:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104747:	5b                   	pop    %ebx
f0104748:	5e                   	pop    %esi
f0104749:	5d                   	pop    %ebp
f010474a:	c3                   	ret    

f010474b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010474b:	55                   	push   %ebp
f010474c:	89 e5                	mov    %esp,%ebp
f010474e:	53                   	push   %ebx
f010474f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0104752:	89 c1                	mov    %eax,%ecx
f0104754:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0104757:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010475b:	eb 0a                	jmp    f0104767 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010475d:	0f b6 10             	movzbl (%eax),%edx
f0104760:	39 da                	cmp    %ebx,%edx
f0104762:	74 07                	je     f010476b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104764:	83 c0 01             	add    $0x1,%eax
f0104767:	39 c8                	cmp    %ecx,%eax
f0104769:	72 f2                	jb     f010475d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010476b:	5b                   	pop    %ebx
f010476c:	5d                   	pop    %ebp
f010476d:	c3                   	ret    

f010476e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010476e:	55                   	push   %ebp
f010476f:	89 e5                	mov    %esp,%ebp
f0104771:	57                   	push   %edi
f0104772:	56                   	push   %esi
f0104773:	53                   	push   %ebx
f0104774:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104777:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010477a:	eb 03                	jmp    f010477f <strtol+0x11>
		s++;
f010477c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010477f:	0f b6 01             	movzbl (%ecx),%eax
f0104782:	3c 20                	cmp    $0x20,%al
f0104784:	74 f6                	je     f010477c <strtol+0xe>
f0104786:	3c 09                	cmp    $0x9,%al
f0104788:	74 f2                	je     f010477c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f010478a:	3c 2b                	cmp    $0x2b,%al
f010478c:	75 0a                	jne    f0104798 <strtol+0x2a>
		s++;
f010478e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104791:	bf 00 00 00 00       	mov    $0x0,%edi
f0104796:	eb 11                	jmp    f01047a9 <strtol+0x3b>
f0104798:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010479d:	3c 2d                	cmp    $0x2d,%al
f010479f:	75 08                	jne    f01047a9 <strtol+0x3b>
		s++, neg = 1;
f01047a1:	83 c1 01             	add    $0x1,%ecx
f01047a4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01047a9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01047af:	75 15                	jne    f01047c6 <strtol+0x58>
f01047b1:	80 39 30             	cmpb   $0x30,(%ecx)
f01047b4:	75 10                	jne    f01047c6 <strtol+0x58>
f01047b6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01047ba:	75 7c                	jne    f0104838 <strtol+0xca>
		s += 2, base = 16;
f01047bc:	83 c1 02             	add    $0x2,%ecx
f01047bf:	bb 10 00 00 00       	mov    $0x10,%ebx
f01047c4:	eb 16                	jmp    f01047dc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01047c6:	85 db                	test   %ebx,%ebx
f01047c8:	75 12                	jne    f01047dc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01047ca:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01047cf:	80 39 30             	cmpb   $0x30,(%ecx)
f01047d2:	75 08                	jne    f01047dc <strtol+0x6e>
		s++, base = 8;
f01047d4:	83 c1 01             	add    $0x1,%ecx
f01047d7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01047dc:	b8 00 00 00 00       	mov    $0x0,%eax
f01047e1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01047e4:	0f b6 11             	movzbl (%ecx),%edx
f01047e7:	8d 72 d0             	lea    -0x30(%edx),%esi
f01047ea:	89 f3                	mov    %esi,%ebx
f01047ec:	80 fb 09             	cmp    $0x9,%bl
f01047ef:	77 08                	ja     f01047f9 <strtol+0x8b>
			dig = *s - '0';
f01047f1:	0f be d2             	movsbl %dl,%edx
f01047f4:	83 ea 30             	sub    $0x30,%edx
f01047f7:	eb 22                	jmp    f010481b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f01047f9:	8d 72 9f             	lea    -0x61(%edx),%esi
f01047fc:	89 f3                	mov    %esi,%ebx
f01047fe:	80 fb 19             	cmp    $0x19,%bl
f0104801:	77 08                	ja     f010480b <strtol+0x9d>
			dig = *s - 'a' + 10;
f0104803:	0f be d2             	movsbl %dl,%edx
f0104806:	83 ea 57             	sub    $0x57,%edx
f0104809:	eb 10                	jmp    f010481b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010480b:	8d 72 bf             	lea    -0x41(%edx),%esi
f010480e:	89 f3                	mov    %esi,%ebx
f0104810:	80 fb 19             	cmp    $0x19,%bl
f0104813:	77 16                	ja     f010482b <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104815:	0f be d2             	movsbl %dl,%edx
f0104818:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010481b:	3b 55 10             	cmp    0x10(%ebp),%edx
f010481e:	7d 0b                	jge    f010482b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0104820:	83 c1 01             	add    $0x1,%ecx
f0104823:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104827:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0104829:	eb b9                	jmp    f01047e4 <strtol+0x76>

	if (endptr)
f010482b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010482f:	74 0d                	je     f010483e <strtol+0xd0>
		*endptr = (char *) s;
f0104831:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104834:	89 0e                	mov    %ecx,(%esi)
f0104836:	eb 06                	jmp    f010483e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104838:	85 db                	test   %ebx,%ebx
f010483a:	74 98                	je     f01047d4 <strtol+0x66>
f010483c:	eb 9e                	jmp    f01047dc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010483e:	89 c2                	mov    %eax,%edx
f0104840:	f7 da                	neg    %edx
f0104842:	85 ff                	test   %edi,%edi
f0104844:	0f 45 c2             	cmovne %edx,%eax
}
f0104847:	5b                   	pop    %ebx
f0104848:	5e                   	pop    %esi
f0104849:	5f                   	pop    %edi
f010484a:	5d                   	pop    %ebp
f010484b:	c3                   	ret    
f010484c:	66 90                	xchg   %ax,%ax
f010484e:	66 90                	xchg   %ax,%ax

f0104850 <__udivdi3>:
f0104850:	55                   	push   %ebp
f0104851:	57                   	push   %edi
f0104852:	56                   	push   %esi
f0104853:	53                   	push   %ebx
f0104854:	83 ec 1c             	sub    $0x1c,%esp
f0104857:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010485b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010485f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0104863:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104867:	85 f6                	test   %esi,%esi
f0104869:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010486d:	89 ca                	mov    %ecx,%edx
f010486f:	89 f8                	mov    %edi,%eax
f0104871:	75 3d                	jne    f01048b0 <__udivdi3+0x60>
f0104873:	39 cf                	cmp    %ecx,%edi
f0104875:	0f 87 c5 00 00 00    	ja     f0104940 <__udivdi3+0xf0>
f010487b:	85 ff                	test   %edi,%edi
f010487d:	89 fd                	mov    %edi,%ebp
f010487f:	75 0b                	jne    f010488c <__udivdi3+0x3c>
f0104881:	b8 01 00 00 00       	mov    $0x1,%eax
f0104886:	31 d2                	xor    %edx,%edx
f0104888:	f7 f7                	div    %edi
f010488a:	89 c5                	mov    %eax,%ebp
f010488c:	89 c8                	mov    %ecx,%eax
f010488e:	31 d2                	xor    %edx,%edx
f0104890:	f7 f5                	div    %ebp
f0104892:	89 c1                	mov    %eax,%ecx
f0104894:	89 d8                	mov    %ebx,%eax
f0104896:	89 cf                	mov    %ecx,%edi
f0104898:	f7 f5                	div    %ebp
f010489a:	89 c3                	mov    %eax,%ebx
f010489c:	89 d8                	mov    %ebx,%eax
f010489e:	89 fa                	mov    %edi,%edx
f01048a0:	83 c4 1c             	add    $0x1c,%esp
f01048a3:	5b                   	pop    %ebx
f01048a4:	5e                   	pop    %esi
f01048a5:	5f                   	pop    %edi
f01048a6:	5d                   	pop    %ebp
f01048a7:	c3                   	ret    
f01048a8:	90                   	nop
f01048a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01048b0:	39 ce                	cmp    %ecx,%esi
f01048b2:	77 74                	ja     f0104928 <__udivdi3+0xd8>
f01048b4:	0f bd fe             	bsr    %esi,%edi
f01048b7:	83 f7 1f             	xor    $0x1f,%edi
f01048ba:	0f 84 98 00 00 00    	je     f0104958 <__udivdi3+0x108>
f01048c0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01048c5:	89 f9                	mov    %edi,%ecx
f01048c7:	89 c5                	mov    %eax,%ebp
f01048c9:	29 fb                	sub    %edi,%ebx
f01048cb:	d3 e6                	shl    %cl,%esi
f01048cd:	89 d9                	mov    %ebx,%ecx
f01048cf:	d3 ed                	shr    %cl,%ebp
f01048d1:	89 f9                	mov    %edi,%ecx
f01048d3:	d3 e0                	shl    %cl,%eax
f01048d5:	09 ee                	or     %ebp,%esi
f01048d7:	89 d9                	mov    %ebx,%ecx
f01048d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01048dd:	89 d5                	mov    %edx,%ebp
f01048df:	8b 44 24 08          	mov    0x8(%esp),%eax
f01048e3:	d3 ed                	shr    %cl,%ebp
f01048e5:	89 f9                	mov    %edi,%ecx
f01048e7:	d3 e2                	shl    %cl,%edx
f01048e9:	89 d9                	mov    %ebx,%ecx
f01048eb:	d3 e8                	shr    %cl,%eax
f01048ed:	09 c2                	or     %eax,%edx
f01048ef:	89 d0                	mov    %edx,%eax
f01048f1:	89 ea                	mov    %ebp,%edx
f01048f3:	f7 f6                	div    %esi
f01048f5:	89 d5                	mov    %edx,%ebp
f01048f7:	89 c3                	mov    %eax,%ebx
f01048f9:	f7 64 24 0c          	mull   0xc(%esp)
f01048fd:	39 d5                	cmp    %edx,%ebp
f01048ff:	72 10                	jb     f0104911 <__udivdi3+0xc1>
f0104901:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104905:	89 f9                	mov    %edi,%ecx
f0104907:	d3 e6                	shl    %cl,%esi
f0104909:	39 c6                	cmp    %eax,%esi
f010490b:	73 07                	jae    f0104914 <__udivdi3+0xc4>
f010490d:	39 d5                	cmp    %edx,%ebp
f010490f:	75 03                	jne    f0104914 <__udivdi3+0xc4>
f0104911:	83 eb 01             	sub    $0x1,%ebx
f0104914:	31 ff                	xor    %edi,%edi
f0104916:	89 d8                	mov    %ebx,%eax
f0104918:	89 fa                	mov    %edi,%edx
f010491a:	83 c4 1c             	add    $0x1c,%esp
f010491d:	5b                   	pop    %ebx
f010491e:	5e                   	pop    %esi
f010491f:	5f                   	pop    %edi
f0104920:	5d                   	pop    %ebp
f0104921:	c3                   	ret    
f0104922:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104928:	31 ff                	xor    %edi,%edi
f010492a:	31 db                	xor    %ebx,%ebx
f010492c:	89 d8                	mov    %ebx,%eax
f010492e:	89 fa                	mov    %edi,%edx
f0104930:	83 c4 1c             	add    $0x1c,%esp
f0104933:	5b                   	pop    %ebx
f0104934:	5e                   	pop    %esi
f0104935:	5f                   	pop    %edi
f0104936:	5d                   	pop    %ebp
f0104937:	c3                   	ret    
f0104938:	90                   	nop
f0104939:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104940:	89 d8                	mov    %ebx,%eax
f0104942:	f7 f7                	div    %edi
f0104944:	31 ff                	xor    %edi,%edi
f0104946:	89 c3                	mov    %eax,%ebx
f0104948:	89 d8                	mov    %ebx,%eax
f010494a:	89 fa                	mov    %edi,%edx
f010494c:	83 c4 1c             	add    $0x1c,%esp
f010494f:	5b                   	pop    %ebx
f0104950:	5e                   	pop    %esi
f0104951:	5f                   	pop    %edi
f0104952:	5d                   	pop    %ebp
f0104953:	c3                   	ret    
f0104954:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104958:	39 ce                	cmp    %ecx,%esi
f010495a:	72 0c                	jb     f0104968 <__udivdi3+0x118>
f010495c:	31 db                	xor    %ebx,%ebx
f010495e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0104962:	0f 87 34 ff ff ff    	ja     f010489c <__udivdi3+0x4c>
f0104968:	bb 01 00 00 00       	mov    $0x1,%ebx
f010496d:	e9 2a ff ff ff       	jmp    f010489c <__udivdi3+0x4c>
f0104972:	66 90                	xchg   %ax,%ax
f0104974:	66 90                	xchg   %ax,%ax
f0104976:	66 90                	xchg   %ax,%ax
f0104978:	66 90                	xchg   %ax,%ax
f010497a:	66 90                	xchg   %ax,%ax
f010497c:	66 90                	xchg   %ax,%ax
f010497e:	66 90                	xchg   %ax,%ax

f0104980 <__umoddi3>:
f0104980:	55                   	push   %ebp
f0104981:	57                   	push   %edi
f0104982:	56                   	push   %esi
f0104983:	53                   	push   %ebx
f0104984:	83 ec 1c             	sub    $0x1c,%esp
f0104987:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010498b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010498f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104993:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104997:	85 d2                	test   %edx,%edx
f0104999:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010499d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01049a1:	89 f3                	mov    %esi,%ebx
f01049a3:	89 3c 24             	mov    %edi,(%esp)
f01049a6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01049aa:	75 1c                	jne    f01049c8 <__umoddi3+0x48>
f01049ac:	39 f7                	cmp    %esi,%edi
f01049ae:	76 50                	jbe    f0104a00 <__umoddi3+0x80>
f01049b0:	89 c8                	mov    %ecx,%eax
f01049b2:	89 f2                	mov    %esi,%edx
f01049b4:	f7 f7                	div    %edi
f01049b6:	89 d0                	mov    %edx,%eax
f01049b8:	31 d2                	xor    %edx,%edx
f01049ba:	83 c4 1c             	add    $0x1c,%esp
f01049bd:	5b                   	pop    %ebx
f01049be:	5e                   	pop    %esi
f01049bf:	5f                   	pop    %edi
f01049c0:	5d                   	pop    %ebp
f01049c1:	c3                   	ret    
f01049c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01049c8:	39 f2                	cmp    %esi,%edx
f01049ca:	89 d0                	mov    %edx,%eax
f01049cc:	77 52                	ja     f0104a20 <__umoddi3+0xa0>
f01049ce:	0f bd ea             	bsr    %edx,%ebp
f01049d1:	83 f5 1f             	xor    $0x1f,%ebp
f01049d4:	75 5a                	jne    f0104a30 <__umoddi3+0xb0>
f01049d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01049da:	0f 82 e0 00 00 00    	jb     f0104ac0 <__umoddi3+0x140>
f01049e0:	39 0c 24             	cmp    %ecx,(%esp)
f01049e3:	0f 86 d7 00 00 00    	jbe    f0104ac0 <__umoddi3+0x140>
f01049e9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01049ed:	8b 54 24 04          	mov    0x4(%esp),%edx
f01049f1:	83 c4 1c             	add    $0x1c,%esp
f01049f4:	5b                   	pop    %ebx
f01049f5:	5e                   	pop    %esi
f01049f6:	5f                   	pop    %edi
f01049f7:	5d                   	pop    %ebp
f01049f8:	c3                   	ret    
f01049f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104a00:	85 ff                	test   %edi,%edi
f0104a02:	89 fd                	mov    %edi,%ebp
f0104a04:	75 0b                	jne    f0104a11 <__umoddi3+0x91>
f0104a06:	b8 01 00 00 00       	mov    $0x1,%eax
f0104a0b:	31 d2                	xor    %edx,%edx
f0104a0d:	f7 f7                	div    %edi
f0104a0f:	89 c5                	mov    %eax,%ebp
f0104a11:	89 f0                	mov    %esi,%eax
f0104a13:	31 d2                	xor    %edx,%edx
f0104a15:	f7 f5                	div    %ebp
f0104a17:	89 c8                	mov    %ecx,%eax
f0104a19:	f7 f5                	div    %ebp
f0104a1b:	89 d0                	mov    %edx,%eax
f0104a1d:	eb 99                	jmp    f01049b8 <__umoddi3+0x38>
f0104a1f:	90                   	nop
f0104a20:	89 c8                	mov    %ecx,%eax
f0104a22:	89 f2                	mov    %esi,%edx
f0104a24:	83 c4 1c             	add    $0x1c,%esp
f0104a27:	5b                   	pop    %ebx
f0104a28:	5e                   	pop    %esi
f0104a29:	5f                   	pop    %edi
f0104a2a:	5d                   	pop    %ebp
f0104a2b:	c3                   	ret    
f0104a2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104a30:	8b 34 24             	mov    (%esp),%esi
f0104a33:	bf 20 00 00 00       	mov    $0x20,%edi
f0104a38:	89 e9                	mov    %ebp,%ecx
f0104a3a:	29 ef                	sub    %ebp,%edi
f0104a3c:	d3 e0                	shl    %cl,%eax
f0104a3e:	89 f9                	mov    %edi,%ecx
f0104a40:	89 f2                	mov    %esi,%edx
f0104a42:	d3 ea                	shr    %cl,%edx
f0104a44:	89 e9                	mov    %ebp,%ecx
f0104a46:	09 c2                	or     %eax,%edx
f0104a48:	89 d8                	mov    %ebx,%eax
f0104a4a:	89 14 24             	mov    %edx,(%esp)
f0104a4d:	89 f2                	mov    %esi,%edx
f0104a4f:	d3 e2                	shl    %cl,%edx
f0104a51:	89 f9                	mov    %edi,%ecx
f0104a53:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104a57:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104a5b:	d3 e8                	shr    %cl,%eax
f0104a5d:	89 e9                	mov    %ebp,%ecx
f0104a5f:	89 c6                	mov    %eax,%esi
f0104a61:	d3 e3                	shl    %cl,%ebx
f0104a63:	89 f9                	mov    %edi,%ecx
f0104a65:	89 d0                	mov    %edx,%eax
f0104a67:	d3 e8                	shr    %cl,%eax
f0104a69:	89 e9                	mov    %ebp,%ecx
f0104a6b:	09 d8                	or     %ebx,%eax
f0104a6d:	89 d3                	mov    %edx,%ebx
f0104a6f:	89 f2                	mov    %esi,%edx
f0104a71:	f7 34 24             	divl   (%esp)
f0104a74:	89 d6                	mov    %edx,%esi
f0104a76:	d3 e3                	shl    %cl,%ebx
f0104a78:	f7 64 24 04          	mull   0x4(%esp)
f0104a7c:	39 d6                	cmp    %edx,%esi
f0104a7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104a82:	89 d1                	mov    %edx,%ecx
f0104a84:	89 c3                	mov    %eax,%ebx
f0104a86:	72 08                	jb     f0104a90 <__umoddi3+0x110>
f0104a88:	75 11                	jne    f0104a9b <__umoddi3+0x11b>
f0104a8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0104a8e:	73 0b                	jae    f0104a9b <__umoddi3+0x11b>
f0104a90:	2b 44 24 04          	sub    0x4(%esp),%eax
f0104a94:	1b 14 24             	sbb    (%esp),%edx
f0104a97:	89 d1                	mov    %edx,%ecx
f0104a99:	89 c3                	mov    %eax,%ebx
f0104a9b:	8b 54 24 08          	mov    0x8(%esp),%edx
f0104a9f:	29 da                	sub    %ebx,%edx
f0104aa1:	19 ce                	sbb    %ecx,%esi
f0104aa3:	89 f9                	mov    %edi,%ecx
f0104aa5:	89 f0                	mov    %esi,%eax
f0104aa7:	d3 e0                	shl    %cl,%eax
f0104aa9:	89 e9                	mov    %ebp,%ecx
f0104aab:	d3 ea                	shr    %cl,%edx
f0104aad:	89 e9                	mov    %ebp,%ecx
f0104aaf:	d3 ee                	shr    %cl,%esi
f0104ab1:	09 d0                	or     %edx,%eax
f0104ab3:	89 f2                	mov    %esi,%edx
f0104ab5:	83 c4 1c             	add    $0x1c,%esp
f0104ab8:	5b                   	pop    %ebx
f0104ab9:	5e                   	pop    %esi
f0104aba:	5f                   	pop    %edi
f0104abb:	5d                   	pop    %ebp
f0104abc:	c3                   	ret    
f0104abd:	8d 76 00             	lea    0x0(%esi),%esi
f0104ac0:	29 f9                	sub    %edi,%ecx
f0104ac2:	19 d6                	sbb    %edx,%esi
f0104ac4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104ac8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104acc:	e9 18 ff ff ff       	jmp    f01049e9 <__umoddi3+0x69>
