
obj/user/hello:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 20 10 80 00       	push   $0x801020
  80003e:	e8 4e 01 00 00       	call   800191 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 2e 10 80 00       	push   $0x80102e
  800054:	e8 38 01 00 00       	call   800191 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800067:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80006e:	00 00 00 
	envid_t eid = sys_getenvid();
  800071:	e8 e4 0a 00 00       	call   800b5a <sys_getenvid>
  800076:	8b 3d 04 20 80 00    	mov    0x802004,%edi
  80007c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800081:	be 00 00 00 00       	mov    $0x0,%esi
	int i;
	for (i = 0; i < NENV; i++) {
  800086:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == eid) {
  80008b:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80008e:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800094:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &(envs[i]);
  800097:	39 c8                	cmp    %ecx,%eax
  800099:	0f 44 fb             	cmove  %ebx,%edi
  80009c:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000a1:	0f 44 f1             	cmove  %ecx,%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
	envid_t eid = sys_getenvid();
	int i;
	for (i = 0; i < NENV; i++) {
  8000a4:	83 c2 01             	add    $0x1,%edx
  8000a7:	83 c3 7c             	add    $0x7c,%ebx
  8000aa:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8000b0:	75 d9                	jne    80008b <libmain+0x2d>
  8000b2:	89 f0                	mov    %esi,%eax
  8000b4:	84 c0                	test   %al,%al
  8000b6:	74 06                	je     8000be <libmain+0x60>
  8000b8:	89 3d 04 20 80 00    	mov    %edi,0x802004
			thisenv = &(envs[i]);
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000be:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000c2:	7e 0a                	jle    8000ce <libmain+0x70>
		binaryname = argv[0];
  8000c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000c7:	8b 00                	mov    (%eax),%eax
  8000c9:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	ff 75 0c             	pushl  0xc(%ebp)
  8000d4:	ff 75 08             	pushl  0x8(%ebp)
  8000d7:	e8 57 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000dc:	e8 0b 00 00 00       	call   8000ec <exit>
}
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5f                   	pop    %edi
  8000ea:	5d                   	pop    %ebp
  8000eb:	c3                   	ret    

008000ec <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f2:	6a 00                	push   $0x0
  8000f4:	e8 20 0a 00 00       	call   800b19 <sys_env_destroy>
}
  8000f9:	83 c4 10             	add    $0x10,%esp
  8000fc:	c9                   	leave  
  8000fd:	c3                   	ret    

008000fe <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	53                   	push   %ebx
  800102:	83 ec 04             	sub    $0x4,%esp
  800105:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800108:	8b 13                	mov    (%ebx),%edx
  80010a:	8d 42 01             	lea    0x1(%edx),%eax
  80010d:	89 03                	mov    %eax,(%ebx)
  80010f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800112:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800116:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011b:	75 1a                	jne    800137 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80011d:	83 ec 08             	sub    $0x8,%esp
  800120:	68 ff 00 00 00       	push   $0xff
  800125:	8d 43 08             	lea    0x8(%ebx),%eax
  800128:	50                   	push   %eax
  800129:	e8 ae 09 00 00       	call   800adc <sys_cputs>
		b->idx = 0;
  80012e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800134:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800137:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800149:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800150:	00 00 00 
	b.cnt = 0;
  800153:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015d:	ff 75 0c             	pushl  0xc(%ebp)
  800160:	ff 75 08             	pushl  0x8(%ebp)
  800163:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800169:	50                   	push   %eax
  80016a:	68 fe 00 80 00       	push   $0x8000fe
  80016f:	e8 1a 01 00 00       	call   80028e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800174:	83 c4 08             	add    $0x8,%esp
  800177:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800183:	50                   	push   %eax
  800184:	e8 53 09 00 00       	call   800adc <sys_cputs>

	return b.cnt;
}
  800189:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800197:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019a:	50                   	push   %eax
  80019b:	ff 75 08             	pushl  0x8(%ebp)
  80019e:	e8 9d ff ff ff       	call   800140 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 1c             	sub    $0x1c,%esp
  8001ae:	89 c7                	mov    %eax,%edi
  8001b0:	89 d6                	mov    %edx,%esi
  8001b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001bb:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001c9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cc:	39 d3                	cmp    %edx,%ebx
  8001ce:	72 05                	jb     8001d5 <printnum+0x30>
  8001d0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d3:	77 45                	ja     80021a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d5:	83 ec 0c             	sub    $0xc,%esp
  8001d8:	ff 75 18             	pushl  0x18(%ebp)
  8001db:	8b 45 14             	mov    0x14(%ebp),%eax
  8001de:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e1:	53                   	push   %ebx
  8001e2:	ff 75 10             	pushl  0x10(%ebp)
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f4:	e8 97 0b 00 00       	call   800d90 <__udivdi3>
  8001f9:	83 c4 18             	add    $0x18,%esp
  8001fc:	52                   	push   %edx
  8001fd:	50                   	push   %eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	89 f8                	mov    %edi,%eax
  800202:	e8 9e ff ff ff       	call   8001a5 <printnum>
  800207:	83 c4 20             	add    $0x20,%esp
  80020a:	eb 18                	jmp    800224 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	56                   	push   %esi
  800210:	ff 75 18             	pushl  0x18(%ebp)
  800213:	ff d7                	call   *%edi
  800215:	83 c4 10             	add    $0x10,%esp
  800218:	eb 03                	jmp    80021d <printnum+0x78>
  80021a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021d:	83 eb 01             	sub    $0x1,%ebx
  800220:	85 db                	test   %ebx,%ebx
  800222:	7f e8                	jg     80020c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	83 ec 04             	sub    $0x4,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 84 0c 00 00       	call   800ec0 <__umoddi3>
  80023c:	83 c4 14             	add    $0x14,%esp
  80023f:	0f be 80 4f 10 80 00 	movsbl 0x80104f(%eax),%eax
  800246:	50                   	push   %eax
  800247:	ff d7                	call   *%edi
}
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    

00800254 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80025e:	8b 10                	mov    (%eax),%edx
  800260:	3b 50 04             	cmp    0x4(%eax),%edx
  800263:	73 0a                	jae    80026f <sprintputch+0x1b>
		*b->buf++ = ch;
  800265:	8d 4a 01             	lea    0x1(%edx),%ecx
  800268:	89 08                	mov    %ecx,(%eax)
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	88 02                	mov    %al,(%edx)
}
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800277:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027a:	50                   	push   %eax
  80027b:	ff 75 10             	pushl  0x10(%ebp)
  80027e:	ff 75 0c             	pushl  0xc(%ebp)
  800281:	ff 75 08             	pushl  0x8(%ebp)
  800284:	e8 05 00 00 00       	call   80028e <vprintfmt>
	va_end(ap);
}
  800289:	83 c4 10             	add    $0x10,%esp
  80028c:	c9                   	leave  
  80028d:	c3                   	ret    

0080028e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	57                   	push   %edi
  800292:	56                   	push   %esi
  800293:	53                   	push   %ebx
  800294:	83 ec 2c             	sub    $0x2c,%esp
  800297:	8b 75 08             	mov    0x8(%ebp),%esi
  80029a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029d:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a0:	eb 12                	jmp    8002b4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a2:	85 c0                	test   %eax,%eax
  8002a4:	0f 84 42 04 00 00    	je     8006ec <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002aa:	83 ec 08             	sub    $0x8,%esp
  8002ad:	53                   	push   %ebx
  8002ae:	50                   	push   %eax
  8002af:	ff d6                	call   *%esi
  8002b1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b4:	83 c7 01             	add    $0x1,%edi
  8002b7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002bb:	83 f8 25             	cmp    $0x25,%eax
  8002be:	75 e2                	jne    8002a2 <vprintfmt+0x14>
  8002c0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002d2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002de:	eb 07                	jmp    8002e7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e7:	8d 47 01             	lea    0x1(%edi),%eax
  8002ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ed:	0f b6 07             	movzbl (%edi),%eax
  8002f0:	0f b6 d0             	movzbl %al,%edx
  8002f3:	83 e8 23             	sub    $0x23,%eax
  8002f6:	3c 55                	cmp    $0x55,%al
  8002f8:	0f 87 d3 03 00 00    	ja     8006d1 <vprintfmt+0x443>
  8002fe:	0f b6 c0             	movzbl %al,%eax
  800301:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  800308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030f:	eb d6                	jmp    8002e7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800314:	b8 00 00 00 00       	mov    $0x0,%eax
  800319:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800323:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800326:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800329:	83 f9 09             	cmp    $0x9,%ecx
  80032c:	77 3f                	ja     80036d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80032e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800331:	eb e9                	jmp    80031c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800333:	8b 45 14             	mov    0x14(%ebp),%eax
  800336:	8b 00                	mov    (%eax),%eax
  800338:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 40 04             	lea    0x4(%eax),%eax
  800341:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800347:	eb 2a                	jmp    800373 <vprintfmt+0xe5>
  800349:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034c:	85 c0                	test   %eax,%eax
  80034e:	ba 00 00 00 00       	mov    $0x0,%edx
  800353:	0f 49 d0             	cmovns %eax,%edx
  800356:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035c:	eb 89                	jmp    8002e7 <vprintfmt+0x59>
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800361:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800368:	e9 7a ff ff ff       	jmp    8002e7 <vprintfmt+0x59>
  80036d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800370:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800373:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800377:	0f 89 6a ff ff ff    	jns    8002e7 <vprintfmt+0x59>
				width = precision, precision = -1;
  80037d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800380:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800383:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038a:	e9 58 ff ff ff       	jmp    8002e7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80038f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800395:	e9 4d ff ff ff       	jmp    8002e7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80039a:	8b 45 14             	mov    0x14(%ebp),%eax
  80039d:	8d 78 04             	lea    0x4(%eax),%edi
  8003a0:	83 ec 08             	sub    $0x8,%esp
  8003a3:	53                   	push   %ebx
  8003a4:	ff 30                	pushl  (%eax)
  8003a6:	ff d6                	call   *%esi
			break;
  8003a8:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ab:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b1:	e9 fe fe ff ff       	jmp    8002b4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b9:	8d 78 04             	lea    0x4(%eax),%edi
  8003bc:	8b 00                	mov    (%eax),%eax
  8003be:	99                   	cltd   
  8003bf:	31 d0                	xor    %edx,%eax
  8003c1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c3:	83 f8 08             	cmp    $0x8,%eax
  8003c6:	7f 0b                	jg     8003d3 <vprintfmt+0x145>
  8003c8:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  8003cf:	85 d2                	test   %edx,%edx
  8003d1:	75 1b                	jne    8003ee <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003d3:	50                   	push   %eax
  8003d4:	68 67 10 80 00       	push   $0x801067
  8003d9:	53                   	push   %ebx
  8003da:	56                   	push   %esi
  8003db:	e8 91 fe ff ff       	call   800271 <printfmt>
  8003e0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e9:	e9 c6 fe ff ff       	jmp    8002b4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ee:	52                   	push   %edx
  8003ef:	68 70 10 80 00       	push   $0x801070
  8003f4:	53                   	push   %ebx
  8003f5:	56                   	push   %esi
  8003f6:	e8 76 fe ff ff       	call   800271 <printfmt>
  8003fb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fe:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800404:	e9 ab fe ff ff       	jmp    8002b4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	83 c0 04             	add    $0x4,%eax
  80040f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800417:	85 ff                	test   %edi,%edi
  800419:	b8 60 10 80 00       	mov    $0x801060,%eax
  80041e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800421:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800425:	0f 8e 94 00 00 00    	jle    8004bf <vprintfmt+0x231>
  80042b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80042f:	0f 84 98 00 00 00    	je     8004cd <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	ff 75 d0             	pushl  -0x30(%ebp)
  80043b:	57                   	push   %edi
  80043c:	e8 33 03 00 00       	call   800774 <strnlen>
  800441:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800444:	29 c1                	sub    %eax,%ecx
  800446:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800449:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80044c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800450:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800453:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800456:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800458:	eb 0f                	jmp    800469 <vprintfmt+0x1db>
					putch(padc, putdat);
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	53                   	push   %ebx
  80045e:	ff 75 e0             	pushl  -0x20(%ebp)
  800461:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800463:	83 ef 01             	sub    $0x1,%edi
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	85 ff                	test   %edi,%edi
  80046b:	7f ed                	jg     80045a <vprintfmt+0x1cc>
  80046d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800470:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800473:	85 c9                	test   %ecx,%ecx
  800475:	b8 00 00 00 00       	mov    $0x0,%eax
  80047a:	0f 49 c1             	cmovns %ecx,%eax
  80047d:	29 c1                	sub    %eax,%ecx
  80047f:	89 75 08             	mov    %esi,0x8(%ebp)
  800482:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800485:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800488:	89 cb                	mov    %ecx,%ebx
  80048a:	eb 4d                	jmp    8004d9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800490:	74 1b                	je     8004ad <vprintfmt+0x21f>
  800492:	0f be c0             	movsbl %al,%eax
  800495:	83 e8 20             	sub    $0x20,%eax
  800498:	83 f8 5e             	cmp    $0x5e,%eax
  80049b:	76 10                	jbe    8004ad <vprintfmt+0x21f>
					putch('?', putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	ff 75 0c             	pushl  0xc(%ebp)
  8004a3:	6a 3f                	push   $0x3f
  8004a5:	ff 55 08             	call   *0x8(%ebp)
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	eb 0d                	jmp    8004ba <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	ff 75 0c             	pushl  0xc(%ebp)
  8004b3:	52                   	push   %edx
  8004b4:	ff 55 08             	call   *0x8(%ebp)
  8004b7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ba:	83 eb 01             	sub    $0x1,%ebx
  8004bd:	eb 1a                	jmp    8004d9 <vprintfmt+0x24b>
  8004bf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cb:	eb 0c                	jmp    8004d9 <vprintfmt+0x24b>
  8004cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004d9:	83 c7 01             	add    $0x1,%edi
  8004dc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e0:	0f be d0             	movsbl %al,%edx
  8004e3:	85 d2                	test   %edx,%edx
  8004e5:	74 23                	je     80050a <vprintfmt+0x27c>
  8004e7:	85 f6                	test   %esi,%esi
  8004e9:	78 a1                	js     80048c <vprintfmt+0x1fe>
  8004eb:	83 ee 01             	sub    $0x1,%esi
  8004ee:	79 9c                	jns    80048c <vprintfmt+0x1fe>
  8004f0:	89 df                	mov    %ebx,%edi
  8004f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f8:	eb 18                	jmp    800512 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	6a 20                	push   $0x20
  800500:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800502:	83 ef 01             	sub    $0x1,%edi
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	eb 08                	jmp    800512 <vprintfmt+0x284>
  80050a:	89 df                	mov    %ebx,%edi
  80050c:	8b 75 08             	mov    0x8(%ebp),%esi
  80050f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800512:	85 ff                	test   %edi,%edi
  800514:	7f e4                	jg     8004fa <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800516:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800519:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051f:	e9 90 fd ff ff       	jmp    8002b4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800524:	83 f9 01             	cmp    $0x1,%ecx
  800527:	7e 19                	jle    800542 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8b 50 04             	mov    0x4(%eax),%edx
  80052f:	8b 00                	mov    (%eax),%eax
  800531:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800534:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8d 40 08             	lea    0x8(%eax),%eax
  80053d:	89 45 14             	mov    %eax,0x14(%ebp)
  800540:	eb 38                	jmp    80057a <vprintfmt+0x2ec>
	else if (lflag)
  800542:	85 c9                	test   %ecx,%ecx
  800544:	74 1b                	je     800561 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8b 00                	mov    (%eax),%eax
  80054b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054e:	89 c1                	mov    %eax,%ecx
  800550:	c1 f9 1f             	sar    $0x1f,%ecx
  800553:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8d 40 04             	lea    0x4(%eax),%eax
  80055c:	89 45 14             	mov    %eax,0x14(%ebp)
  80055f:	eb 19                	jmp    80057a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8b 00                	mov    (%eax),%eax
  800566:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800569:	89 c1                	mov    %eax,%ecx
  80056b:	c1 f9 1f             	sar    $0x1f,%ecx
  80056e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 40 04             	lea    0x4(%eax),%eax
  800577:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800580:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800585:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800589:	0f 89 0e 01 00 00    	jns    80069d <vprintfmt+0x40f>
				putch('-', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	6a 2d                	push   $0x2d
  800595:	ff d6                	call   *%esi
				num = -(long long) num;
  800597:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059d:	f7 da                	neg    %edx
  80059f:	83 d1 00             	adc    $0x0,%ecx
  8005a2:	f7 d9                	neg    %ecx
  8005a4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ac:	e9 ec 00 00 00       	jmp    80069d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b1:	83 f9 01             	cmp    $0x1,%ecx
  8005b4:	7e 18                	jle    8005ce <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	8b 48 04             	mov    0x4(%eax),%ecx
  8005be:	8d 40 08             	lea    0x8(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c9:	e9 cf 00 00 00       	jmp    80069d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005ce:	85 c9                	test   %ecx,%ecx
  8005d0:	74 1a                	je     8005ec <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8b 10                	mov    (%eax),%edx
  8005d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005dc:	8d 40 04             	lea    0x4(%eax),%eax
  8005df:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e7:	e9 b1 00 00 00       	jmp    80069d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8b 10                	mov    (%eax),%edx
  8005f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f6:	8d 40 04             	lea    0x4(%eax),%eax
  8005f9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005fc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800601:	e9 97 00 00 00       	jmp    80069d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 58                	push   $0x58
  80060c:	ff d6                	call   *%esi
			putch('X', putdat);
  80060e:	83 c4 08             	add    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 58                	push   $0x58
  800614:	ff d6                	call   *%esi
			putch('X', putdat);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	6a 58                	push   $0x58
  80061c:	ff d6                	call   *%esi
			break;
  80061e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800621:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800624:	e9 8b fc ff ff       	jmp    8002b4 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 30                	push   $0x30
  80062f:	ff d6                	call   *%esi
			putch('x', putdat);
  800631:	83 c4 08             	add    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 78                	push   $0x78
  800637:	ff d6                	call   *%esi
			num = (unsigned long long)
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 10                	mov    (%eax),%edx
  80063e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800643:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800646:	8d 40 04             	lea    0x4(%eax),%eax
  800649:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800651:	eb 4a                	jmp    80069d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800653:	83 f9 01             	cmp    $0x1,%ecx
  800656:	7e 15                	jle    80066d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	8b 48 04             	mov    0x4(%eax),%ecx
  800660:	8d 40 08             	lea    0x8(%eax),%eax
  800663:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800666:	b8 10 00 00 00       	mov    $0x10,%eax
  80066b:	eb 30                	jmp    80069d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80066d:	85 c9                	test   %ecx,%ecx
  80066f:	74 17                	je     800688 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 10                	mov    (%eax),%edx
  800676:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067b:	8d 40 04             	lea    0x4(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800681:	b8 10 00 00 00       	mov    $0x10,%eax
  800686:	eb 15                	jmp    80069d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800692:	8d 40 04             	lea    0x4(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800698:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069d:	83 ec 0c             	sub    $0xc,%esp
  8006a0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a4:	57                   	push   %edi
  8006a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a8:	50                   	push   %eax
  8006a9:	51                   	push   %ecx
  8006aa:	52                   	push   %edx
  8006ab:	89 da                	mov    %ebx,%edx
  8006ad:	89 f0                	mov    %esi,%eax
  8006af:	e8 f1 fa ff ff       	call   8001a5 <printnum>
			break;
  8006b4:	83 c4 20             	add    $0x20,%esp
  8006b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ba:	e9 f5 fb ff ff       	jmp    8002b4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	53                   	push   %ebx
  8006c3:	52                   	push   %edx
  8006c4:	ff d6                	call   *%esi
			break;
  8006c6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cc:	e9 e3 fb ff ff       	jmp    8002b4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	53                   	push   %ebx
  8006d5:	6a 25                	push   $0x25
  8006d7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	eb 03                	jmp    8006e1 <vprintfmt+0x453>
  8006de:	83 ef 01             	sub    $0x1,%edi
  8006e1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e5:	75 f7                	jne    8006de <vprintfmt+0x450>
  8006e7:	e9 c8 fb ff ff       	jmp    8002b4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ef:	5b                   	pop    %ebx
  8006f0:	5e                   	pop    %esi
  8006f1:	5f                   	pop    %edi
  8006f2:	5d                   	pop    %ebp
  8006f3:	c3                   	ret    

008006f4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	83 ec 18             	sub    $0x18,%esp
  8006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800700:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800703:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800707:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800711:	85 c0                	test   %eax,%eax
  800713:	74 26                	je     80073b <vsnprintf+0x47>
  800715:	85 d2                	test   %edx,%edx
  800717:	7e 22                	jle    80073b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800719:	ff 75 14             	pushl  0x14(%ebp)
  80071c:	ff 75 10             	pushl  0x10(%ebp)
  80071f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800722:	50                   	push   %eax
  800723:	68 54 02 80 00       	push   $0x800254
  800728:	e8 61 fb ff ff       	call   80028e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800730:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800733:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb 05                	jmp    800740 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800740:	c9                   	leave  
  800741:	c3                   	ret    

00800742 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800742:	55                   	push   %ebp
  800743:	89 e5                	mov    %esp,%ebp
  800745:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800748:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074b:	50                   	push   %eax
  80074c:	ff 75 10             	pushl  0x10(%ebp)
  80074f:	ff 75 0c             	pushl  0xc(%ebp)
  800752:	ff 75 08             	pushl  0x8(%ebp)
  800755:	e8 9a ff ff ff       	call   8006f4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075a:	c9                   	leave  
  80075b:	c3                   	ret    

0080075c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075c:	55                   	push   %ebp
  80075d:	89 e5                	mov    %esp,%ebp
  80075f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800762:	b8 00 00 00 00       	mov    $0x0,%eax
  800767:	eb 03                	jmp    80076c <strlen+0x10>
		n++;
  800769:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800770:	75 f7                	jne    800769 <strlen+0xd>
		n++;
	return n;
}
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077d:	ba 00 00 00 00       	mov    $0x0,%edx
  800782:	eb 03                	jmp    800787 <strnlen+0x13>
		n++;
  800784:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800787:	39 c2                	cmp    %eax,%edx
  800789:	74 08                	je     800793 <strnlen+0x1f>
  80078b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80078f:	75 f3                	jne    800784 <strnlen+0x10>
  800791:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800793:	5d                   	pop    %ebp
  800794:	c3                   	ret    

00800795 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	53                   	push   %ebx
  800799:	8b 45 08             	mov    0x8(%ebp),%eax
  80079c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079f:	89 c2                	mov    %eax,%edx
  8007a1:	83 c2 01             	add    $0x1,%edx
  8007a4:	83 c1 01             	add    $0x1,%ecx
  8007a7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ab:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ae:	84 db                	test   %bl,%bl
  8007b0:	75 ef                	jne    8007a1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b2:	5b                   	pop    %ebx
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	53                   	push   %ebx
  8007b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bc:	53                   	push   %ebx
  8007bd:	e8 9a ff ff ff       	call   80075c <strlen>
  8007c2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c5:	ff 75 0c             	pushl  0xc(%ebp)
  8007c8:	01 d8                	add    %ebx,%eax
  8007ca:	50                   	push   %eax
  8007cb:	e8 c5 ff ff ff       	call   800795 <strcpy>
	return dst;
}
  8007d0:	89 d8                	mov    %ebx,%eax
  8007d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	56                   	push   %esi
  8007db:	53                   	push   %ebx
  8007dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e2:	89 f3                	mov    %esi,%ebx
  8007e4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e7:	89 f2                	mov    %esi,%edx
  8007e9:	eb 0f                	jmp    8007fa <strncpy+0x23>
		*dst++ = *src;
  8007eb:	83 c2 01             	add    $0x1,%edx
  8007ee:	0f b6 01             	movzbl (%ecx),%eax
  8007f1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fa:	39 da                	cmp    %ebx,%edx
  8007fc:	75 ed                	jne    8007eb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007fe:	89 f0                	mov    %esi,%eax
  800800:	5b                   	pop    %ebx
  800801:	5e                   	pop    %esi
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	56                   	push   %esi
  800808:	53                   	push   %ebx
  800809:	8b 75 08             	mov    0x8(%ebp),%esi
  80080c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80080f:	8b 55 10             	mov    0x10(%ebp),%edx
  800812:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800814:	85 d2                	test   %edx,%edx
  800816:	74 21                	je     800839 <strlcpy+0x35>
  800818:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081c:	89 f2                	mov    %esi,%edx
  80081e:	eb 09                	jmp    800829 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800820:	83 c2 01             	add    $0x1,%edx
  800823:	83 c1 01             	add    $0x1,%ecx
  800826:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800829:	39 c2                	cmp    %eax,%edx
  80082b:	74 09                	je     800836 <strlcpy+0x32>
  80082d:	0f b6 19             	movzbl (%ecx),%ebx
  800830:	84 db                	test   %bl,%bl
  800832:	75 ec                	jne    800820 <strlcpy+0x1c>
  800834:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800836:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800839:	29 f0                	sub    %esi,%eax
}
  80083b:	5b                   	pop    %ebx
  80083c:	5e                   	pop    %esi
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800845:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800848:	eb 06                	jmp    800850 <strcmp+0x11>
		p++, q++;
  80084a:	83 c1 01             	add    $0x1,%ecx
  80084d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800850:	0f b6 01             	movzbl (%ecx),%eax
  800853:	84 c0                	test   %al,%al
  800855:	74 04                	je     80085b <strcmp+0x1c>
  800857:	3a 02                	cmp    (%edx),%al
  800859:	74 ef                	je     80084a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085b:	0f b6 c0             	movzbl %al,%eax
  80085e:	0f b6 12             	movzbl (%edx),%edx
  800861:	29 d0                	sub    %edx,%eax
}
  800863:	5d                   	pop    %ebp
  800864:	c3                   	ret    

00800865 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800865:	55                   	push   %ebp
  800866:	89 e5                	mov    %esp,%ebp
  800868:	53                   	push   %ebx
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80086f:	89 c3                	mov    %eax,%ebx
  800871:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800874:	eb 06                	jmp    80087c <strncmp+0x17>
		n--, p++, q++;
  800876:	83 c0 01             	add    $0x1,%eax
  800879:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087c:	39 d8                	cmp    %ebx,%eax
  80087e:	74 15                	je     800895 <strncmp+0x30>
  800880:	0f b6 08             	movzbl (%eax),%ecx
  800883:	84 c9                	test   %cl,%cl
  800885:	74 04                	je     80088b <strncmp+0x26>
  800887:	3a 0a                	cmp    (%edx),%cl
  800889:	74 eb                	je     800876 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088b:	0f b6 00             	movzbl (%eax),%eax
  80088e:	0f b6 12             	movzbl (%edx),%edx
  800891:	29 d0                	sub    %edx,%eax
  800893:	eb 05                	jmp    80089a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800895:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089a:	5b                   	pop    %ebx
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a7:	eb 07                	jmp    8008b0 <strchr+0x13>
		if (*s == c)
  8008a9:	38 ca                	cmp    %cl,%dl
  8008ab:	74 0f                	je     8008bc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	0f b6 10             	movzbl (%eax),%edx
  8008b3:	84 d2                	test   %dl,%dl
  8008b5:	75 f2                	jne    8008a9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c8:	eb 03                	jmp    8008cd <strfind+0xf>
  8008ca:	83 c0 01             	add    $0x1,%eax
  8008cd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d0:	38 ca                	cmp    %cl,%dl
  8008d2:	74 04                	je     8008d8 <strfind+0x1a>
  8008d4:	84 d2                	test   %dl,%dl
  8008d6:	75 f2                	jne    8008ca <strfind+0xc>
			break;
	return (char *) s;
}
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	57                   	push   %edi
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e6:	85 c9                	test   %ecx,%ecx
  8008e8:	74 36                	je     800920 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ea:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f0:	75 28                	jne    80091a <memset+0x40>
  8008f2:	f6 c1 03             	test   $0x3,%cl
  8008f5:	75 23                	jne    80091a <memset+0x40>
		c &= 0xFF;
  8008f7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fb:	89 d3                	mov    %edx,%ebx
  8008fd:	c1 e3 08             	shl    $0x8,%ebx
  800900:	89 d6                	mov    %edx,%esi
  800902:	c1 e6 18             	shl    $0x18,%esi
  800905:	89 d0                	mov    %edx,%eax
  800907:	c1 e0 10             	shl    $0x10,%eax
  80090a:	09 f0                	or     %esi,%eax
  80090c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80090e:	89 d8                	mov    %ebx,%eax
  800910:	09 d0                	or     %edx,%eax
  800912:	c1 e9 02             	shr    $0x2,%ecx
  800915:	fc                   	cld    
  800916:	f3 ab                	rep stos %eax,%es:(%edi)
  800918:	eb 06                	jmp    800920 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091d:	fc                   	cld    
  80091e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800920:	89 f8                	mov    %edi,%eax
  800922:	5b                   	pop    %ebx
  800923:	5e                   	pop    %esi
  800924:	5f                   	pop    %edi
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	57                   	push   %edi
  80092b:	56                   	push   %esi
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800932:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800935:	39 c6                	cmp    %eax,%esi
  800937:	73 35                	jae    80096e <memmove+0x47>
  800939:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093c:	39 d0                	cmp    %edx,%eax
  80093e:	73 2e                	jae    80096e <memmove+0x47>
		s += n;
		d += n;
  800940:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800943:	89 d6                	mov    %edx,%esi
  800945:	09 fe                	or     %edi,%esi
  800947:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094d:	75 13                	jne    800962 <memmove+0x3b>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 0e                	jne    800962 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800954:	83 ef 04             	sub    $0x4,%edi
  800957:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095a:	c1 e9 02             	shr    $0x2,%ecx
  80095d:	fd                   	std    
  80095e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800960:	eb 09                	jmp    80096b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800962:	83 ef 01             	sub    $0x1,%edi
  800965:	8d 72 ff             	lea    -0x1(%edx),%esi
  800968:	fd                   	std    
  800969:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096b:	fc                   	cld    
  80096c:	eb 1d                	jmp    80098b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096e:	89 f2                	mov    %esi,%edx
  800970:	09 c2                	or     %eax,%edx
  800972:	f6 c2 03             	test   $0x3,%dl
  800975:	75 0f                	jne    800986 <memmove+0x5f>
  800977:	f6 c1 03             	test   $0x3,%cl
  80097a:	75 0a                	jne    800986 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097c:	c1 e9 02             	shr    $0x2,%ecx
  80097f:	89 c7                	mov    %eax,%edi
  800981:	fc                   	cld    
  800982:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800984:	eb 05                	jmp    80098b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800986:	89 c7                	mov    %eax,%edi
  800988:	fc                   	cld    
  800989:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098b:	5e                   	pop    %esi
  80098c:	5f                   	pop    %edi
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800992:	ff 75 10             	pushl  0x10(%ebp)
  800995:	ff 75 0c             	pushl  0xc(%ebp)
  800998:	ff 75 08             	pushl  0x8(%ebp)
  80099b:	e8 87 ff ff ff       	call   800927 <memmove>
}
  8009a0:	c9                   	leave  
  8009a1:	c3                   	ret    

008009a2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	56                   	push   %esi
  8009a6:	53                   	push   %ebx
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ad:	89 c6                	mov    %eax,%esi
  8009af:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b2:	eb 1a                	jmp    8009ce <memcmp+0x2c>
		if (*s1 != *s2)
  8009b4:	0f b6 08             	movzbl (%eax),%ecx
  8009b7:	0f b6 1a             	movzbl (%edx),%ebx
  8009ba:	38 d9                	cmp    %bl,%cl
  8009bc:	74 0a                	je     8009c8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009be:	0f b6 c1             	movzbl %cl,%eax
  8009c1:	0f b6 db             	movzbl %bl,%ebx
  8009c4:	29 d8                	sub    %ebx,%eax
  8009c6:	eb 0f                	jmp    8009d7 <memcmp+0x35>
		s1++, s2++;
  8009c8:	83 c0 01             	add    $0x1,%eax
  8009cb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ce:	39 f0                	cmp    %esi,%eax
  8009d0:	75 e2                	jne    8009b4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d7:	5b                   	pop    %ebx
  8009d8:	5e                   	pop    %esi
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	53                   	push   %ebx
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e2:	89 c1                	mov    %eax,%ecx
  8009e4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009eb:	eb 0a                	jmp    8009f7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	39 da                	cmp    %ebx,%edx
  8009f2:	74 07                	je     8009fb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	39 c8                	cmp    %ecx,%eax
  8009f9:	72 f2                	jb     8009ed <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fb:	5b                   	pop    %ebx
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	57                   	push   %edi
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0a:	eb 03                	jmp    800a0f <strtol+0x11>
		s++;
  800a0c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0f:	0f b6 01             	movzbl (%ecx),%eax
  800a12:	3c 20                	cmp    $0x20,%al
  800a14:	74 f6                	je     800a0c <strtol+0xe>
  800a16:	3c 09                	cmp    $0x9,%al
  800a18:	74 f2                	je     800a0c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1a:	3c 2b                	cmp    $0x2b,%al
  800a1c:	75 0a                	jne    800a28 <strtol+0x2a>
		s++;
  800a1e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a21:	bf 00 00 00 00       	mov    $0x0,%edi
  800a26:	eb 11                	jmp    800a39 <strtol+0x3b>
  800a28:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2d:	3c 2d                	cmp    $0x2d,%al
  800a2f:	75 08                	jne    800a39 <strtol+0x3b>
		s++, neg = 1;
  800a31:	83 c1 01             	add    $0x1,%ecx
  800a34:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a39:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a3f:	75 15                	jne    800a56 <strtol+0x58>
  800a41:	80 39 30             	cmpb   $0x30,(%ecx)
  800a44:	75 10                	jne    800a56 <strtol+0x58>
  800a46:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4a:	75 7c                	jne    800ac8 <strtol+0xca>
		s += 2, base = 16;
  800a4c:	83 c1 02             	add    $0x2,%ecx
  800a4f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a54:	eb 16                	jmp    800a6c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a56:	85 db                	test   %ebx,%ebx
  800a58:	75 12                	jne    800a6c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a5f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a62:	75 08                	jne    800a6c <strtol+0x6e>
		s++, base = 8;
  800a64:	83 c1 01             	add    $0x1,%ecx
  800a67:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a71:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a74:	0f b6 11             	movzbl (%ecx),%edx
  800a77:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7a:	89 f3                	mov    %esi,%ebx
  800a7c:	80 fb 09             	cmp    $0x9,%bl
  800a7f:	77 08                	ja     800a89 <strtol+0x8b>
			dig = *s - '0';
  800a81:	0f be d2             	movsbl %dl,%edx
  800a84:	83 ea 30             	sub    $0x30,%edx
  800a87:	eb 22                	jmp    800aab <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a89:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8c:	89 f3                	mov    %esi,%ebx
  800a8e:	80 fb 19             	cmp    $0x19,%bl
  800a91:	77 08                	ja     800a9b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a93:	0f be d2             	movsbl %dl,%edx
  800a96:	83 ea 57             	sub    $0x57,%edx
  800a99:	eb 10                	jmp    800aab <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a9e:	89 f3                	mov    %esi,%ebx
  800aa0:	80 fb 19             	cmp    $0x19,%bl
  800aa3:	77 16                	ja     800abb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa5:	0f be d2             	movsbl %dl,%edx
  800aa8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aab:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aae:	7d 0b                	jge    800abb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab0:	83 c1 01             	add    $0x1,%ecx
  800ab3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ab9:	eb b9                	jmp    800a74 <strtol+0x76>

	if (endptr)
  800abb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800abf:	74 0d                	je     800ace <strtol+0xd0>
		*endptr = (char *) s;
  800ac1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac4:	89 0e                	mov    %ecx,(%esi)
  800ac6:	eb 06                	jmp    800ace <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac8:	85 db                	test   %ebx,%ebx
  800aca:	74 98                	je     800a64 <strtol+0x66>
  800acc:	eb 9e                	jmp    800a6c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ace:	89 c2                	mov    %eax,%edx
  800ad0:	f7 da                	neg    %edx
  800ad2:	85 ff                	test   %edi,%edi
  800ad4:	0f 45 c2             	cmovne %edx,%eax
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aea:	8b 55 08             	mov    0x8(%ebp),%edx
  800aed:	89 c3                	mov    %eax,%ebx
  800aef:	89 c7                	mov    %eax,%edi
  800af1:	89 c6                	mov    %eax,%esi
  800af3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af5:	5b                   	pop    %ebx
  800af6:	5e                   	pop    %esi
  800af7:	5f                   	pop    %edi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <sys_cgetc>:

int
sys_cgetc(void)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	57                   	push   %edi
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b00:	ba 00 00 00 00       	mov    $0x0,%edx
  800b05:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0a:	89 d1                	mov    %edx,%ecx
  800b0c:	89 d3                	mov    %edx,%ebx
  800b0e:	89 d7                	mov    %edx,%edi
  800b10:	89 d6                	mov    %edx,%esi
  800b12:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5f                   	pop    %edi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    

00800b19 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	57                   	push   %edi
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
  800b1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b27:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2f:	89 cb                	mov    %ecx,%ebx
  800b31:	89 cf                	mov    %ecx,%edi
  800b33:	89 ce                	mov    %ecx,%esi
  800b35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b37:	85 c0                	test   %eax,%eax
  800b39:	7e 17                	jle    800b52 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3b:	83 ec 0c             	sub    $0xc,%esp
  800b3e:	50                   	push   %eax
  800b3f:	6a 03                	push   $0x3
  800b41:	68 a4 12 80 00       	push   $0x8012a4
  800b46:	6a 23                	push   $0x23
  800b48:	68 c1 12 80 00       	push   $0x8012c1
  800b4d:	e8 f5 01 00 00       	call   800d47 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_yield>:

void
sys_yield(void)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b84:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b89:	89 d1                	mov    %edx,%ecx
  800b8b:	89 d3                	mov    %edx,%ebx
  800b8d:	89 d7                	mov    %edx,%edi
  800b8f:	89 d6                	mov    %edx,%esi
  800b91:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	53                   	push   %ebx
  800b9e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba1:	be 00 00 00 00       	mov    $0x0,%esi
  800ba6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb4:	89 f7                	mov    %esi,%edi
  800bb6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bb8:	85 c0                	test   %eax,%eax
  800bba:	7e 17                	jle    800bd3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbc:	83 ec 0c             	sub    $0xc,%esp
  800bbf:	50                   	push   %eax
  800bc0:	6a 04                	push   $0x4
  800bc2:	68 a4 12 80 00       	push   $0x8012a4
  800bc7:	6a 23                	push   $0x23
  800bc9:	68 c1 12 80 00       	push   $0x8012c1
  800bce:	e8 74 01 00 00       	call   800d47 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	b8 05 00 00 00       	mov    $0x5,%eax
  800be9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf5:	8b 75 18             	mov    0x18(%ebp),%esi
  800bf8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfa:	85 c0                	test   %eax,%eax
  800bfc:	7e 17                	jle    800c15 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfe:	83 ec 0c             	sub    $0xc,%esp
  800c01:	50                   	push   %eax
  800c02:	6a 05                	push   $0x5
  800c04:	68 a4 12 80 00       	push   $0x8012a4
  800c09:	6a 23                	push   $0x23
  800c0b:	68 c1 12 80 00       	push   $0x8012c1
  800c10:	e8 32 01 00 00       	call   800d47 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c33:	8b 55 08             	mov    0x8(%ebp),%edx
  800c36:	89 df                	mov    %ebx,%edi
  800c38:	89 de                	mov    %ebx,%esi
  800c3a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	7e 17                	jle    800c57 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c40:	83 ec 0c             	sub    $0xc,%esp
  800c43:	50                   	push   %eax
  800c44:	6a 06                	push   $0x6
  800c46:	68 a4 12 80 00       	push   $0x8012a4
  800c4b:	6a 23                	push   $0x23
  800c4d:	68 c1 12 80 00       	push   $0x8012c1
  800c52:	e8 f0 00 00 00       	call   800d47 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
  800c65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c68:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c75:	8b 55 08             	mov    0x8(%ebp),%edx
  800c78:	89 df                	mov    %ebx,%edi
  800c7a:	89 de                	mov    %ebx,%esi
  800c7c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7e:	85 c0                	test   %eax,%eax
  800c80:	7e 17                	jle    800c99 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c82:	83 ec 0c             	sub    $0xc,%esp
  800c85:	50                   	push   %eax
  800c86:	6a 08                	push   $0x8
  800c88:	68 a4 12 80 00       	push   $0x8012a4
  800c8d:	6a 23                	push   $0x23
  800c8f:	68 c1 12 80 00       	push   $0x8012c1
  800c94:	e8 ae 00 00 00       	call   800d47 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	57                   	push   %edi
  800ca5:	56                   	push   %esi
  800ca6:	53                   	push   %ebx
  800ca7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caa:	bb 00 00 00 00       	mov    $0x0,%ebx
  800caf:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	89 df                	mov    %ebx,%edi
  800cbc:	89 de                	mov    %ebx,%esi
  800cbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc0:	85 c0                	test   %eax,%eax
  800cc2:	7e 17                	jle    800cdb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc4:	83 ec 0c             	sub    $0xc,%esp
  800cc7:	50                   	push   %eax
  800cc8:	6a 09                	push   $0x9
  800cca:	68 a4 12 80 00       	push   $0x8012a4
  800ccf:	6a 23                	push   $0x23
  800cd1:	68 c1 12 80 00       	push   $0x8012c1
  800cd6:	e8 6c 00 00 00       	call   800d47 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	be 00 00 00 00       	mov    $0x0,%esi
  800cee:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d14:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 cb                	mov    %ecx,%ebx
  800d1e:	89 cf                	mov    %ecx,%edi
  800d20:	89 ce                	mov    %ecx,%esi
  800d22:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d24:	85 c0                	test   %eax,%eax
  800d26:	7e 17                	jle    800d3f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d28:	83 ec 0c             	sub    $0xc,%esp
  800d2b:	50                   	push   %eax
  800d2c:	6a 0c                	push   $0xc
  800d2e:	68 a4 12 80 00       	push   $0x8012a4
  800d33:	6a 23                	push   $0x23
  800d35:	68 c1 12 80 00       	push   $0x8012c1
  800d3a:	e8 08 00 00 00       	call   800d47 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d4c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d4f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d55:	e8 00 fe ff ff       	call   800b5a <sys_getenvid>
  800d5a:	83 ec 0c             	sub    $0xc,%esp
  800d5d:	ff 75 0c             	pushl  0xc(%ebp)
  800d60:	ff 75 08             	pushl  0x8(%ebp)
  800d63:	56                   	push   %esi
  800d64:	50                   	push   %eax
  800d65:	68 d0 12 80 00       	push   $0x8012d0
  800d6a:	e8 22 f4 ff ff       	call   800191 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d6f:	83 c4 18             	add    $0x18,%esp
  800d72:	53                   	push   %ebx
  800d73:	ff 75 10             	pushl  0x10(%ebp)
  800d76:	e8 c5 f3 ff ff       	call   800140 <vcprintf>
	cprintf("\n");
  800d7b:	c7 04 24 2c 10 80 00 	movl   $0x80102c,(%esp)
  800d82:	e8 0a f4 ff ff       	call   800191 <cprintf>
  800d87:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d8a:	cc                   	int3   
  800d8b:	eb fd                	jmp    800d8a <_panic+0x43>
  800d8d:	66 90                	xchg   %ax,%ax
  800d8f:	90                   	nop

00800d90 <__udivdi3>:
  800d90:	55                   	push   %ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 1c             	sub    $0x1c,%esp
  800d97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800da7:	85 f6                	test   %esi,%esi
  800da9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800dad:	89 ca                	mov    %ecx,%edx
  800daf:	89 f8                	mov    %edi,%eax
  800db1:	75 3d                	jne    800df0 <__udivdi3+0x60>
  800db3:	39 cf                	cmp    %ecx,%edi
  800db5:	0f 87 c5 00 00 00    	ja     800e80 <__udivdi3+0xf0>
  800dbb:	85 ff                	test   %edi,%edi
  800dbd:	89 fd                	mov    %edi,%ebp
  800dbf:	75 0b                	jne    800dcc <__udivdi3+0x3c>
  800dc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800dc6:	31 d2                	xor    %edx,%edx
  800dc8:	f7 f7                	div    %edi
  800dca:	89 c5                	mov    %eax,%ebp
  800dcc:	89 c8                	mov    %ecx,%eax
  800dce:	31 d2                	xor    %edx,%edx
  800dd0:	f7 f5                	div    %ebp
  800dd2:	89 c1                	mov    %eax,%ecx
  800dd4:	89 d8                	mov    %ebx,%eax
  800dd6:	89 cf                	mov    %ecx,%edi
  800dd8:	f7 f5                	div    %ebp
  800dda:	89 c3                	mov    %eax,%ebx
  800ddc:	89 d8                	mov    %ebx,%eax
  800dde:	89 fa                	mov    %edi,%edx
  800de0:	83 c4 1c             	add    $0x1c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    
  800de8:	90                   	nop
  800de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800df0:	39 ce                	cmp    %ecx,%esi
  800df2:	77 74                	ja     800e68 <__udivdi3+0xd8>
  800df4:	0f bd fe             	bsr    %esi,%edi
  800df7:	83 f7 1f             	xor    $0x1f,%edi
  800dfa:	0f 84 98 00 00 00    	je     800e98 <__udivdi3+0x108>
  800e00:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e05:	89 f9                	mov    %edi,%ecx
  800e07:	89 c5                	mov    %eax,%ebp
  800e09:	29 fb                	sub    %edi,%ebx
  800e0b:	d3 e6                	shl    %cl,%esi
  800e0d:	89 d9                	mov    %ebx,%ecx
  800e0f:	d3 ed                	shr    %cl,%ebp
  800e11:	89 f9                	mov    %edi,%ecx
  800e13:	d3 e0                	shl    %cl,%eax
  800e15:	09 ee                	or     %ebp,%esi
  800e17:	89 d9                	mov    %ebx,%ecx
  800e19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e1d:	89 d5                	mov    %edx,%ebp
  800e1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e23:	d3 ed                	shr    %cl,%ebp
  800e25:	89 f9                	mov    %edi,%ecx
  800e27:	d3 e2                	shl    %cl,%edx
  800e29:	89 d9                	mov    %ebx,%ecx
  800e2b:	d3 e8                	shr    %cl,%eax
  800e2d:	09 c2                	or     %eax,%edx
  800e2f:	89 d0                	mov    %edx,%eax
  800e31:	89 ea                	mov    %ebp,%edx
  800e33:	f7 f6                	div    %esi
  800e35:	89 d5                	mov    %edx,%ebp
  800e37:	89 c3                	mov    %eax,%ebx
  800e39:	f7 64 24 0c          	mull   0xc(%esp)
  800e3d:	39 d5                	cmp    %edx,%ebp
  800e3f:	72 10                	jb     800e51 <__udivdi3+0xc1>
  800e41:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e45:	89 f9                	mov    %edi,%ecx
  800e47:	d3 e6                	shl    %cl,%esi
  800e49:	39 c6                	cmp    %eax,%esi
  800e4b:	73 07                	jae    800e54 <__udivdi3+0xc4>
  800e4d:	39 d5                	cmp    %edx,%ebp
  800e4f:	75 03                	jne    800e54 <__udivdi3+0xc4>
  800e51:	83 eb 01             	sub    $0x1,%ebx
  800e54:	31 ff                	xor    %edi,%edi
  800e56:	89 d8                	mov    %ebx,%eax
  800e58:	89 fa                	mov    %edi,%edx
  800e5a:	83 c4 1c             	add    $0x1c,%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
  800e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e68:	31 ff                	xor    %edi,%edi
  800e6a:	31 db                	xor    %ebx,%ebx
  800e6c:	89 d8                	mov    %ebx,%eax
  800e6e:	89 fa                	mov    %edi,%edx
  800e70:	83 c4 1c             	add    $0x1c,%esp
  800e73:	5b                   	pop    %ebx
  800e74:	5e                   	pop    %esi
  800e75:	5f                   	pop    %edi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    
  800e78:	90                   	nop
  800e79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e80:	89 d8                	mov    %ebx,%eax
  800e82:	f7 f7                	div    %edi
  800e84:	31 ff                	xor    %edi,%edi
  800e86:	89 c3                	mov    %eax,%ebx
  800e88:	89 d8                	mov    %ebx,%eax
  800e8a:	89 fa                	mov    %edi,%edx
  800e8c:	83 c4 1c             	add    $0x1c,%esp
  800e8f:	5b                   	pop    %ebx
  800e90:	5e                   	pop    %esi
  800e91:	5f                   	pop    %edi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    
  800e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e98:	39 ce                	cmp    %ecx,%esi
  800e9a:	72 0c                	jb     800ea8 <__udivdi3+0x118>
  800e9c:	31 db                	xor    %ebx,%ebx
  800e9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800ea2:	0f 87 34 ff ff ff    	ja     800ddc <__udivdi3+0x4c>
  800ea8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800ead:	e9 2a ff ff ff       	jmp    800ddc <__udivdi3+0x4c>
  800eb2:	66 90                	xchg   %ax,%ax
  800eb4:	66 90                	xchg   %ax,%ax
  800eb6:	66 90                	xchg   %ax,%ax
  800eb8:	66 90                	xchg   %ax,%ax
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__umoddi3>:
  800ec0:	55                   	push   %ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 1c             	sub    $0x1c,%esp
  800ec7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ecb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800ecf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ed3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ed7:	85 d2                	test   %edx,%edx
  800ed9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ee1:	89 f3                	mov    %esi,%ebx
  800ee3:	89 3c 24             	mov    %edi,(%esp)
  800ee6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eea:	75 1c                	jne    800f08 <__umoddi3+0x48>
  800eec:	39 f7                	cmp    %esi,%edi
  800eee:	76 50                	jbe    800f40 <__umoddi3+0x80>
  800ef0:	89 c8                	mov    %ecx,%eax
  800ef2:	89 f2                	mov    %esi,%edx
  800ef4:	f7 f7                	div    %edi
  800ef6:	89 d0                	mov    %edx,%eax
  800ef8:	31 d2                	xor    %edx,%edx
  800efa:	83 c4 1c             	add    $0x1c,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	39 f2                	cmp    %esi,%edx
  800f0a:	89 d0                	mov    %edx,%eax
  800f0c:	77 52                	ja     800f60 <__umoddi3+0xa0>
  800f0e:	0f bd ea             	bsr    %edx,%ebp
  800f11:	83 f5 1f             	xor    $0x1f,%ebp
  800f14:	75 5a                	jne    800f70 <__umoddi3+0xb0>
  800f16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f1a:	0f 82 e0 00 00 00    	jb     801000 <__umoddi3+0x140>
  800f20:	39 0c 24             	cmp    %ecx,(%esp)
  800f23:	0f 86 d7 00 00 00    	jbe    801000 <__umoddi3+0x140>
  800f29:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f31:	83 c4 1c             	add    $0x1c,%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    
  800f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f40:	85 ff                	test   %edi,%edi
  800f42:	89 fd                	mov    %edi,%ebp
  800f44:	75 0b                	jne    800f51 <__umoddi3+0x91>
  800f46:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	f7 f7                	div    %edi
  800f4f:	89 c5                	mov    %eax,%ebp
  800f51:	89 f0                	mov    %esi,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	f7 f5                	div    %ebp
  800f57:	89 c8                	mov    %ecx,%eax
  800f59:	f7 f5                	div    %ebp
  800f5b:	89 d0                	mov    %edx,%eax
  800f5d:	eb 99                	jmp    800ef8 <__umoddi3+0x38>
  800f5f:	90                   	nop
  800f60:	89 c8                	mov    %ecx,%eax
  800f62:	89 f2                	mov    %esi,%edx
  800f64:	83 c4 1c             	add    $0x1c,%esp
  800f67:	5b                   	pop    %ebx
  800f68:	5e                   	pop    %esi
  800f69:	5f                   	pop    %edi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    
  800f6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f70:	8b 34 24             	mov    (%esp),%esi
  800f73:	bf 20 00 00 00       	mov    $0x20,%edi
  800f78:	89 e9                	mov    %ebp,%ecx
  800f7a:	29 ef                	sub    %ebp,%edi
  800f7c:	d3 e0                	shl    %cl,%eax
  800f7e:	89 f9                	mov    %edi,%ecx
  800f80:	89 f2                	mov    %esi,%edx
  800f82:	d3 ea                	shr    %cl,%edx
  800f84:	89 e9                	mov    %ebp,%ecx
  800f86:	09 c2                	or     %eax,%edx
  800f88:	89 d8                	mov    %ebx,%eax
  800f8a:	89 14 24             	mov    %edx,(%esp)
  800f8d:	89 f2                	mov    %esi,%edx
  800f8f:	d3 e2                	shl    %cl,%edx
  800f91:	89 f9                	mov    %edi,%ecx
  800f93:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f9b:	d3 e8                	shr    %cl,%eax
  800f9d:	89 e9                	mov    %ebp,%ecx
  800f9f:	89 c6                	mov    %eax,%esi
  800fa1:	d3 e3                	shl    %cl,%ebx
  800fa3:	89 f9                	mov    %edi,%ecx
  800fa5:	89 d0                	mov    %edx,%eax
  800fa7:	d3 e8                	shr    %cl,%eax
  800fa9:	89 e9                	mov    %ebp,%ecx
  800fab:	09 d8                	or     %ebx,%eax
  800fad:	89 d3                	mov    %edx,%ebx
  800faf:	89 f2                	mov    %esi,%edx
  800fb1:	f7 34 24             	divl   (%esp)
  800fb4:	89 d6                	mov    %edx,%esi
  800fb6:	d3 e3                	shl    %cl,%ebx
  800fb8:	f7 64 24 04          	mull   0x4(%esp)
  800fbc:	39 d6                	cmp    %edx,%esi
  800fbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fc2:	89 d1                	mov    %edx,%ecx
  800fc4:	89 c3                	mov    %eax,%ebx
  800fc6:	72 08                	jb     800fd0 <__umoddi3+0x110>
  800fc8:	75 11                	jne    800fdb <__umoddi3+0x11b>
  800fca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fce:	73 0b                	jae    800fdb <__umoddi3+0x11b>
  800fd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fd4:	1b 14 24             	sbb    (%esp),%edx
  800fd7:	89 d1                	mov    %edx,%ecx
  800fd9:	89 c3                	mov    %eax,%ebx
  800fdb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fdf:	29 da                	sub    %ebx,%edx
  800fe1:	19 ce                	sbb    %ecx,%esi
  800fe3:	89 f9                	mov    %edi,%ecx
  800fe5:	89 f0                	mov    %esi,%eax
  800fe7:	d3 e0                	shl    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	d3 ea                	shr    %cl,%edx
  800fed:	89 e9                	mov    %ebp,%ecx
  800fef:	d3 ee                	shr    %cl,%esi
  800ff1:	09 d0                	or     %edx,%eax
  800ff3:	89 f2                	mov    %esi,%edx
  800ff5:	83 c4 1c             	add    $0x1c,%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5f                   	pop    %edi
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    
  800ffd:	8d 76 00             	lea    0x0(%esi),%esi
  801000:	29 f9                	sub    %edi,%ecx
  801002:	19 d6                	sbb    %edx,%esi
  801004:	89 74 24 04          	mov    %esi,0x4(%esp)
  801008:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80100c:	e9 18 ff ff ff       	jmp    800f29 <__umoddi3+0x69>
