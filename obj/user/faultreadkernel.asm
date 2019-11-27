
obj/user/faultreadkernel:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 d4 0d 80 00       	push   $0x800dd4
  800044:	e8 f3 00 00 00       	call   80013c <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800059:	e8 6e 0a 00 00       	call   800acc <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800066:	c1 e0 05             	shl    $0x5,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x30>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007e:	83 ec 08             	sub    $0x8,%esp
  800081:	56                   	push   %esi
  800082:	53                   	push   %ebx
  800083:	e8 ab ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800088:	e8 0a 00 00 00       	call   800097 <exit>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800093:	5b                   	pop    %ebx
  800094:	5e                   	pop    %esi
  800095:	5d                   	pop    %ebp
  800096:	c3                   	ret    

00800097 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800097:	55                   	push   %ebp
  800098:	89 e5                	mov    %esp,%ebp
  80009a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009d:	6a 00                	push   $0x0
  80009f:	e8 e7 09 00 00       	call   800a8b <sys_env_destroy>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    

008000a9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	53                   	push   %ebx
  8000ad:	83 ec 04             	sub    $0x4,%esp
  8000b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b3:	8b 13                	mov    (%ebx),%edx
  8000b5:	8d 42 01             	lea    0x1(%edx),%eax
  8000b8:	89 03                	mov    %eax,(%ebx)
  8000ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000bd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c6:	75 1a                	jne    8000e2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000c8:	83 ec 08             	sub    $0x8,%esp
  8000cb:	68 ff 00 00 00       	push   $0xff
  8000d0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d3:	50                   	push   %eax
  8000d4:	e8 75 09 00 00       	call   800a4e <sys_cputs>
		b->idx = 0;
  8000d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000df:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000e9:	c9                   	leave  
  8000ea:	c3                   	ret    

008000eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fb:	00 00 00 
	b.cnt = 0;
  8000fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800105:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800108:	ff 75 0c             	pushl  0xc(%ebp)
  80010b:	ff 75 08             	pushl  0x8(%ebp)
  80010e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800114:	50                   	push   %eax
  800115:	68 a9 00 80 00       	push   $0x8000a9
  80011a:	e8 54 01 00 00       	call   800273 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011f:	83 c4 08             	add    $0x8,%esp
  800122:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800128:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012e:	50                   	push   %eax
  80012f:	e8 1a 09 00 00       	call   800a4e <sys_cputs>

	return b.cnt;
}
  800134:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013a:	c9                   	leave  
  80013b:	c3                   	ret    

0080013c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800142:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800145:	50                   	push   %eax
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	e8 9d ff ff ff       	call   8000eb <vcprintf>
	va_end(ap);

	return cnt;
}
  80014e:	c9                   	leave  
  80014f:	c3                   	ret    

00800150 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	57                   	push   %edi
  800154:	56                   	push   %esi
  800155:	53                   	push   %ebx
  800156:	83 ec 1c             	sub    $0x1c,%esp
  800159:	89 c7                	mov    %eax,%edi
  80015b:	89 d6                	mov    %edx,%esi
  80015d:	8b 45 08             	mov    0x8(%ebp),%eax
  800160:	8b 55 0c             	mov    0xc(%ebp),%edx
  800163:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800166:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800169:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80016c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800171:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800174:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800177:	39 d3                	cmp    %edx,%ebx
  800179:	72 05                	jb     800180 <printnum+0x30>
  80017b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80017e:	77 45                	ja     8001c5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800180:	83 ec 0c             	sub    $0xc,%esp
  800183:	ff 75 18             	pushl  0x18(%ebp)
  800186:	8b 45 14             	mov    0x14(%ebp),%eax
  800189:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80018c:	53                   	push   %ebx
  80018d:	ff 75 10             	pushl  0x10(%ebp)
  800190:	83 ec 08             	sub    $0x8,%esp
  800193:	ff 75 e4             	pushl  -0x1c(%ebp)
  800196:	ff 75 e0             	pushl  -0x20(%ebp)
  800199:	ff 75 dc             	pushl  -0x24(%ebp)
  80019c:	ff 75 d8             	pushl  -0x28(%ebp)
  80019f:	e8 ac 09 00 00       	call   800b50 <__udivdi3>
  8001a4:	83 c4 18             	add    $0x18,%esp
  8001a7:	52                   	push   %edx
  8001a8:	50                   	push   %eax
  8001a9:	89 f2                	mov    %esi,%edx
  8001ab:	89 f8                	mov    %edi,%eax
  8001ad:	e8 9e ff ff ff       	call   800150 <printnum>
  8001b2:	83 c4 20             	add    $0x20,%esp
  8001b5:	eb 18                	jmp    8001cf <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b7:	83 ec 08             	sub    $0x8,%esp
  8001ba:	56                   	push   %esi
  8001bb:	ff 75 18             	pushl  0x18(%ebp)
  8001be:	ff d7                	call   *%edi
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	eb 03                	jmp    8001c8 <printnum+0x78>
  8001c5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	7f e8                	jg     8001b7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001cf:	83 ec 08             	sub    $0x8,%esp
  8001d2:	56                   	push   %esi
  8001d3:	83 ec 04             	sub    $0x4,%esp
  8001d6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001dc:	ff 75 dc             	pushl  -0x24(%ebp)
  8001df:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e2:	e8 99 0a 00 00       	call   800c80 <__umoddi3>
  8001e7:	83 c4 14             	add    $0x14,%esp
  8001ea:	0f be 80 05 0e 80 00 	movsbl 0x800e05(%eax),%eax
  8001f1:	50                   	push   %eax
  8001f2:	ff d7                	call   *%edi
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5f                   	pop    %edi
  8001fd:	5d                   	pop    %ebp
  8001fe:	c3                   	ret    

008001ff <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800202:	83 fa 01             	cmp    $0x1,%edx
  800205:	7e 0e                	jle    800215 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800207:	8b 10                	mov    (%eax),%edx
  800209:	8d 4a 08             	lea    0x8(%edx),%ecx
  80020c:	89 08                	mov    %ecx,(%eax)
  80020e:	8b 02                	mov    (%edx),%eax
  800210:	8b 52 04             	mov    0x4(%edx),%edx
  800213:	eb 22                	jmp    800237 <getuint+0x38>
	else if (lflag)
  800215:	85 d2                	test   %edx,%edx
  800217:	74 10                	je     800229 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800219:	8b 10                	mov    (%eax),%edx
  80021b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80021e:	89 08                	mov    %ecx,(%eax)
  800220:	8b 02                	mov    (%edx),%eax
  800222:	ba 00 00 00 00       	mov    $0x0,%edx
  800227:	eb 0e                	jmp    800237 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800229:	8b 10                	mov    (%eax),%edx
  80022b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022e:	89 08                	mov    %ecx,(%eax)
  800230:	8b 02                	mov    (%edx),%eax
  800232:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800237:	5d                   	pop    %ebp
  800238:	c3                   	ret    

00800239 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800243:	8b 10                	mov    (%eax),%edx
  800245:	3b 50 04             	cmp    0x4(%eax),%edx
  800248:	73 0a                	jae    800254 <sprintputch+0x1b>
		*b->buf++ = ch;
  80024a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024d:	89 08                	mov    %ecx,(%eax)
  80024f:	8b 45 08             	mov    0x8(%ebp),%eax
  800252:	88 02                	mov    %al,(%edx)
}
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80025c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025f:	50                   	push   %eax
  800260:	ff 75 10             	pushl  0x10(%ebp)
  800263:	ff 75 0c             	pushl  0xc(%ebp)
  800266:	ff 75 08             	pushl  0x8(%ebp)
  800269:	e8 05 00 00 00       	call   800273 <vprintfmt>
	va_end(ap);
}
  80026e:	83 c4 10             	add    $0x10,%esp
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 2c             	sub    $0x2c,%esp
  80027c:	8b 75 08             	mov    0x8(%ebp),%esi
  80027f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800282:	8b 7d 10             	mov    0x10(%ebp),%edi
  800285:	eb 1d                	jmp    8002a4 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800287:	85 c0                	test   %eax,%eax
  800289:	75 0f                	jne    80029a <vprintfmt+0x27>
				csa = 0x0700;
  80028b:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  800292:	07 00 00 
				return;
  800295:	e9 c4 03 00 00       	jmp    80065e <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	53                   	push   %ebx
  80029e:	50                   	push   %eax
  80029f:	ff d6                	call   *%esi
  8002a1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002a4:	83 c7 01             	add    $0x1,%edi
  8002a7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002ab:	83 f8 25             	cmp    $0x25,%eax
  8002ae:	75 d7                	jne    800287 <vprintfmt+0x14>
  8002b0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002b4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002bb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002c2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ce:	eb 07                	jmp    8002d7 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002d3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d7:	8d 47 01             	lea    0x1(%edi),%eax
  8002da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dd:	0f b6 07             	movzbl (%edi),%eax
  8002e0:	0f b6 c8             	movzbl %al,%ecx
  8002e3:	83 e8 23             	sub    $0x23,%eax
  8002e6:	3c 55                	cmp    $0x55,%al
  8002e8:	0f 87 55 03 00 00    	ja     800643 <vprintfmt+0x3d0>
  8002ee:	0f b6 c0             	movzbl %al,%eax
  8002f1:	ff 24 85 94 0e 80 00 	jmp    *0x800e94(,%eax,4)
  8002f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002fb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002ff:	eb d6                	jmp    8002d7 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800301:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800304:	b8 00 00 00 00       	mov    $0x0,%eax
  800309:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80030c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80030f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800313:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800316:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800319:	83 fa 09             	cmp    $0x9,%edx
  80031c:	77 39                	ja     800357 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80031e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800321:	eb e9                	jmp    80030c <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800323:	8b 45 14             	mov    0x14(%ebp),%eax
  800326:	8d 48 04             	lea    0x4(%eax),%ecx
  800329:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80032c:	8b 00                	mov    (%eax),%eax
  80032e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800334:	eb 27                	jmp    80035d <vprintfmt+0xea>
  800336:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800339:	85 c0                	test   %eax,%eax
  80033b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800340:	0f 49 c8             	cmovns %eax,%ecx
  800343:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800349:	eb 8c                	jmp    8002d7 <vprintfmt+0x64>
  80034b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80034e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800355:	eb 80                	jmp    8002d7 <vprintfmt+0x64>
  800357:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80035a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80035d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800361:	0f 89 70 ff ff ff    	jns    8002d7 <vprintfmt+0x64>
				width = precision, precision = -1;
  800367:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80036a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800374:	e9 5e ff ff ff       	jmp    8002d7 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800379:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80037f:	e9 53 ff ff ff       	jmp    8002d7 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8d 50 04             	lea    0x4(%eax),%edx
  80038a:	89 55 14             	mov    %edx,0x14(%ebp)
  80038d:	83 ec 08             	sub    $0x8,%esp
  800390:	53                   	push   %ebx
  800391:	ff 30                	pushl  (%eax)
  800393:	ff d6                	call   *%esi
			break;
  800395:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800398:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80039b:	e9 04 ff ff ff       	jmp    8002a4 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8d 50 04             	lea    0x4(%eax),%edx
  8003a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003a9:	8b 00                	mov    (%eax),%eax
  8003ab:	99                   	cltd   
  8003ac:	31 d0                	xor    %edx,%eax
  8003ae:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b0:	83 f8 06             	cmp    $0x6,%eax
  8003b3:	7f 0b                	jg     8003c0 <vprintfmt+0x14d>
  8003b5:	8b 14 85 ec 0f 80 00 	mov    0x800fec(,%eax,4),%edx
  8003bc:	85 d2                	test   %edx,%edx
  8003be:	75 18                	jne    8003d8 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8003c0:	50                   	push   %eax
  8003c1:	68 1d 0e 80 00       	push   $0x800e1d
  8003c6:	53                   	push   %ebx
  8003c7:	56                   	push   %esi
  8003c8:	e8 89 fe ff ff       	call   800256 <printfmt>
  8003cd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003d3:	e9 cc fe ff ff       	jmp    8002a4 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8003d8:	52                   	push   %edx
  8003d9:	68 26 0e 80 00       	push   $0x800e26
  8003de:	53                   	push   %ebx
  8003df:	56                   	push   %esi
  8003e0:	e8 71 fe ff ff       	call   800256 <printfmt>
  8003e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003eb:	e9 b4 fe ff ff       	jmp    8002a4 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 50 04             	lea    0x4(%eax),%edx
  8003f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003fb:	85 ff                	test   %edi,%edi
  8003fd:	b8 16 0e 80 00       	mov    $0x800e16,%eax
  800402:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800405:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800409:	0f 8e 94 00 00 00    	jle    8004a3 <vprintfmt+0x230>
  80040f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800413:	0f 84 98 00 00 00    	je     8004b1 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800419:	83 ec 08             	sub    $0x8,%esp
  80041c:	ff 75 d0             	pushl  -0x30(%ebp)
  80041f:	57                   	push   %edi
  800420:	e8 c1 02 00 00       	call   8006e6 <strnlen>
  800425:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800428:	29 c1                	sub    %eax,%ecx
  80042a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80042d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800430:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800434:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800437:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80043a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043c:	eb 0f                	jmp    80044d <vprintfmt+0x1da>
					putch(padc, putdat);
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	53                   	push   %ebx
  800442:	ff 75 e0             	pushl  -0x20(%ebp)
  800445:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800447:	83 ef 01             	sub    $0x1,%edi
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	85 ff                	test   %edi,%edi
  80044f:	7f ed                	jg     80043e <vprintfmt+0x1cb>
  800451:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800454:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800457:	85 c9                	test   %ecx,%ecx
  800459:	b8 00 00 00 00       	mov    $0x0,%eax
  80045e:	0f 49 c1             	cmovns %ecx,%eax
  800461:	29 c1                	sub    %eax,%ecx
  800463:	89 75 08             	mov    %esi,0x8(%ebp)
  800466:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800469:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046c:	89 cb                	mov    %ecx,%ebx
  80046e:	eb 4d                	jmp    8004bd <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800470:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800474:	74 1b                	je     800491 <vprintfmt+0x21e>
  800476:	0f be c0             	movsbl %al,%eax
  800479:	83 e8 20             	sub    $0x20,%eax
  80047c:	83 f8 5e             	cmp    $0x5e,%eax
  80047f:	76 10                	jbe    800491 <vprintfmt+0x21e>
					putch('?', putdat);
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	ff 75 0c             	pushl  0xc(%ebp)
  800487:	6a 3f                	push   $0x3f
  800489:	ff 55 08             	call   *0x8(%ebp)
  80048c:	83 c4 10             	add    $0x10,%esp
  80048f:	eb 0d                	jmp    80049e <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	ff 75 0c             	pushl  0xc(%ebp)
  800497:	52                   	push   %edx
  800498:	ff 55 08             	call   *0x8(%ebp)
  80049b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049e:	83 eb 01             	sub    $0x1,%ebx
  8004a1:	eb 1a                	jmp    8004bd <vprintfmt+0x24a>
  8004a3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ac:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004af:	eb 0c                	jmp    8004bd <vprintfmt+0x24a>
  8004b1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ba:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bd:	83 c7 01             	add    $0x1,%edi
  8004c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c4:	0f be d0             	movsbl %al,%edx
  8004c7:	85 d2                	test   %edx,%edx
  8004c9:	74 23                	je     8004ee <vprintfmt+0x27b>
  8004cb:	85 f6                	test   %esi,%esi
  8004cd:	78 a1                	js     800470 <vprintfmt+0x1fd>
  8004cf:	83 ee 01             	sub    $0x1,%esi
  8004d2:	79 9c                	jns    800470 <vprintfmt+0x1fd>
  8004d4:	89 df                	mov    %ebx,%edi
  8004d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004dc:	eb 18                	jmp    8004f6 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	53                   	push   %ebx
  8004e2:	6a 20                	push   $0x20
  8004e4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e6:	83 ef 01             	sub    $0x1,%edi
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	eb 08                	jmp    8004f6 <vprintfmt+0x283>
  8004ee:	89 df                	mov    %ebx,%edi
  8004f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f6:	85 ff                	test   %edi,%edi
  8004f8:	7f e4                	jg     8004de <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004fd:	e9 a2 fd ff ff       	jmp    8002a4 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800502:	83 fa 01             	cmp    $0x1,%edx
  800505:	7e 16                	jle    80051d <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	8d 50 08             	lea    0x8(%eax),%edx
  80050d:	89 55 14             	mov    %edx,0x14(%ebp)
  800510:	8b 50 04             	mov    0x4(%eax),%edx
  800513:	8b 00                	mov    (%eax),%eax
  800515:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800518:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80051b:	eb 32                	jmp    80054f <vprintfmt+0x2dc>
	else if (lflag)
  80051d:	85 d2                	test   %edx,%edx
  80051f:	74 18                	je     800539 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 50 04             	lea    0x4(%eax),%edx
  800527:	89 55 14             	mov    %edx,0x14(%ebp)
  80052a:	8b 00                	mov    (%eax),%eax
  80052c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052f:	89 c1                	mov    %eax,%ecx
  800531:	c1 f9 1f             	sar    $0x1f,%ecx
  800534:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800537:	eb 16                	jmp    80054f <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 50 04             	lea    0x4(%eax),%edx
  80053f:	89 55 14             	mov    %edx,0x14(%ebp)
  800542:	8b 00                	mov    (%eax),%eax
  800544:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800547:	89 c1                	mov    %eax,%ecx
  800549:	c1 f9 1f             	sar    $0x1f,%ecx
  80054c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80054f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800552:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800555:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80055e:	79 74                	jns    8005d4 <vprintfmt+0x361>
				putch('-', putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	53                   	push   %ebx
  800564:	6a 2d                	push   $0x2d
  800566:	ff d6                	call   *%esi
				num = -(long long) num;
  800568:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80056b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80056e:	f7 d8                	neg    %eax
  800570:	83 d2 00             	adc    $0x0,%edx
  800573:	f7 da                	neg    %edx
  800575:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800578:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80057d:	eb 55                	jmp    8005d4 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80057f:	8d 45 14             	lea    0x14(%ebp),%eax
  800582:	e8 78 fc ff ff       	call   8001ff <getuint>
			base = 10;
  800587:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80058c:	eb 46                	jmp    8005d4 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80058e:	8d 45 14             	lea    0x14(%ebp),%eax
  800591:	e8 69 fc ff ff       	call   8001ff <getuint>
      base = 8;
  800596:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80059b:	eb 37                	jmp    8005d4 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	53                   	push   %ebx
  8005a1:	6a 30                	push   $0x30
  8005a3:	ff d6                	call   *%esi
			putch('x', putdat);
  8005a5:	83 c4 08             	add    $0x8,%esp
  8005a8:	53                   	push   %ebx
  8005a9:	6a 78                	push   $0x78
  8005ab:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8d 50 04             	lea    0x4(%eax),%edx
  8005b3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005b6:	8b 00                	mov    (%eax),%eax
  8005b8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005bd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005c0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005c5:	eb 0d                	jmp    8005d4 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ca:	e8 30 fc ff ff       	call   8001ff <getuint>
			base = 16;
  8005cf:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005d4:	83 ec 0c             	sub    $0xc,%esp
  8005d7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005db:	57                   	push   %edi
  8005dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005df:	51                   	push   %ecx
  8005e0:	52                   	push   %edx
  8005e1:	50                   	push   %eax
  8005e2:	89 da                	mov    %ebx,%edx
  8005e4:	89 f0                	mov    %esi,%eax
  8005e6:	e8 65 fb ff ff       	call   800150 <printnum>
			break;
  8005eb:	83 c4 20             	add    $0x20,%esp
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f1:	e9 ae fc ff ff       	jmp    8002a4 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	53                   	push   %ebx
  8005fa:	51                   	push   %ecx
  8005fb:	ff d6                	call   *%esi
			break;
  8005fd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800600:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800603:	e9 9c fc ff ff       	jmp    8002a4 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800608:	83 fa 01             	cmp    $0x1,%edx
  80060b:	7e 0d                	jle    80061a <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 08             	lea    0x8(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)
  800616:	8b 00                	mov    (%eax),%eax
  800618:	eb 1c                	jmp    800636 <vprintfmt+0x3c3>
	else if (lflag)
  80061a:	85 d2                	test   %edx,%edx
  80061c:	74 0d                	je     80062b <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  80061e:	8b 45 14             	mov    0x14(%ebp),%eax
  800621:	8d 50 04             	lea    0x4(%eax),%edx
  800624:	89 55 14             	mov    %edx,0x14(%ebp)
  800627:	8b 00                	mov    (%eax),%eax
  800629:	eb 0b                	jmp    800636 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 50 04             	lea    0x4(%eax),%edx
  800631:	89 55 14             	mov    %edx,0x14(%ebp)
  800634:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800636:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  80063e:	e9 61 fc ff ff       	jmp    8002a4 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	6a 25                	push   $0x25
  800649:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	eb 03                	jmp    800653 <vprintfmt+0x3e0>
  800650:	83 ef 01             	sub    $0x1,%edi
  800653:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800657:	75 f7                	jne    800650 <vprintfmt+0x3dd>
  800659:	e9 46 fc ff ff       	jmp    8002a4 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80065e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800661:	5b                   	pop    %ebx
  800662:	5e                   	pop    %esi
  800663:	5f                   	pop    %edi
  800664:	5d                   	pop    %ebp
  800665:	c3                   	ret    

00800666 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800666:	55                   	push   %ebp
  800667:	89 e5                	mov    %esp,%ebp
  800669:	83 ec 18             	sub    $0x18,%esp
  80066c:	8b 45 08             	mov    0x8(%ebp),%eax
  80066f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800672:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800675:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800679:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80067c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800683:	85 c0                	test   %eax,%eax
  800685:	74 26                	je     8006ad <vsnprintf+0x47>
  800687:	85 d2                	test   %edx,%edx
  800689:	7e 22                	jle    8006ad <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80068b:	ff 75 14             	pushl  0x14(%ebp)
  80068e:	ff 75 10             	pushl  0x10(%ebp)
  800691:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800694:	50                   	push   %eax
  800695:	68 39 02 80 00       	push   $0x800239
  80069a:	e8 d4 fb ff ff       	call   800273 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80069f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	eb 05                	jmp    8006b2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006bd:	50                   	push   %eax
  8006be:	ff 75 10             	pushl  0x10(%ebp)
  8006c1:	ff 75 0c             	pushl  0xc(%ebp)
  8006c4:	ff 75 08             	pushl  0x8(%ebp)
  8006c7:	e8 9a ff ff ff       	call   800666 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006cc:	c9                   	leave  
  8006cd:	c3                   	ret    

008006ce <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d9:	eb 03                	jmp    8006de <strlen+0x10>
		n++;
  8006db:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006e2:	75 f7                	jne    8006db <strlen+0xd>
		n++;
	return n;
}
  8006e4:	5d                   	pop    %ebp
  8006e5:	c3                   	ret    

008006e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8006f4:	eb 03                	jmp    8006f9 <strnlen+0x13>
		n++;
  8006f6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006f9:	39 c2                	cmp    %eax,%edx
  8006fb:	74 08                	je     800705 <strnlen+0x1f>
  8006fd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800701:	75 f3                	jne    8006f6 <strnlen+0x10>
  800703:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	53                   	push   %ebx
  80070b:	8b 45 08             	mov    0x8(%ebp),%eax
  80070e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800711:	89 c2                	mov    %eax,%edx
  800713:	83 c2 01             	add    $0x1,%edx
  800716:	83 c1 01             	add    $0x1,%ecx
  800719:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80071d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800720:	84 db                	test   %bl,%bl
  800722:	75 ef                	jne    800713 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800724:	5b                   	pop    %ebx
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    

00800727 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800727:	55                   	push   %ebp
  800728:	89 e5                	mov    %esp,%ebp
  80072a:	53                   	push   %ebx
  80072b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072e:	53                   	push   %ebx
  80072f:	e8 9a ff ff ff       	call   8006ce <strlen>
  800734:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800737:	ff 75 0c             	pushl  0xc(%ebp)
  80073a:	01 d8                	add    %ebx,%eax
  80073c:	50                   	push   %eax
  80073d:	e8 c5 ff ff ff       	call   800707 <strcpy>
	return dst;
}
  800742:	89 d8                	mov    %ebx,%eax
  800744:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800747:	c9                   	leave  
  800748:	c3                   	ret    

00800749 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	56                   	push   %esi
  80074d:	53                   	push   %ebx
  80074e:	8b 75 08             	mov    0x8(%ebp),%esi
  800751:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800754:	89 f3                	mov    %esi,%ebx
  800756:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800759:	89 f2                	mov    %esi,%edx
  80075b:	eb 0f                	jmp    80076c <strncpy+0x23>
		*dst++ = *src;
  80075d:	83 c2 01             	add    $0x1,%edx
  800760:	0f b6 01             	movzbl (%ecx),%eax
  800763:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800766:	80 39 01             	cmpb   $0x1,(%ecx)
  800769:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80076c:	39 da                	cmp    %ebx,%edx
  80076e:	75 ed                	jne    80075d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800770:	89 f0                	mov    %esi,%eax
  800772:	5b                   	pop    %ebx
  800773:	5e                   	pop    %esi
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	8b 75 08             	mov    0x8(%ebp),%esi
  80077e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800781:	8b 55 10             	mov    0x10(%ebp),%edx
  800784:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800786:	85 d2                	test   %edx,%edx
  800788:	74 21                	je     8007ab <strlcpy+0x35>
  80078a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80078e:	89 f2                	mov    %esi,%edx
  800790:	eb 09                	jmp    80079b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800792:	83 c2 01             	add    $0x1,%edx
  800795:	83 c1 01             	add    $0x1,%ecx
  800798:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80079b:	39 c2                	cmp    %eax,%edx
  80079d:	74 09                	je     8007a8 <strlcpy+0x32>
  80079f:	0f b6 19             	movzbl (%ecx),%ebx
  8007a2:	84 db                	test   %bl,%bl
  8007a4:	75 ec                	jne    800792 <strlcpy+0x1c>
  8007a6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007a8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007ab:	29 f0                	sub    %esi,%eax
}
  8007ad:	5b                   	pop    %ebx
  8007ae:	5e                   	pop    %esi
  8007af:	5d                   	pop    %ebp
  8007b0:	c3                   	ret    

008007b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ba:	eb 06                	jmp    8007c2 <strcmp+0x11>
		p++, q++;
  8007bc:	83 c1 01             	add    $0x1,%ecx
  8007bf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007c2:	0f b6 01             	movzbl (%ecx),%eax
  8007c5:	84 c0                	test   %al,%al
  8007c7:	74 04                	je     8007cd <strcmp+0x1c>
  8007c9:	3a 02                	cmp    (%edx),%al
  8007cb:	74 ef                	je     8007bc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007cd:	0f b6 c0             	movzbl %al,%eax
  8007d0:	0f b6 12             	movzbl (%edx),%edx
  8007d3:	29 d0                	sub    %edx,%eax
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	53                   	push   %ebx
  8007db:	8b 45 08             	mov    0x8(%ebp),%eax
  8007de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e1:	89 c3                	mov    %eax,%ebx
  8007e3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007e6:	eb 06                	jmp    8007ee <strncmp+0x17>
		n--, p++, q++;
  8007e8:	83 c0 01             	add    $0x1,%eax
  8007eb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007ee:	39 d8                	cmp    %ebx,%eax
  8007f0:	74 15                	je     800807 <strncmp+0x30>
  8007f2:	0f b6 08             	movzbl (%eax),%ecx
  8007f5:	84 c9                	test   %cl,%cl
  8007f7:	74 04                	je     8007fd <strncmp+0x26>
  8007f9:	3a 0a                	cmp    (%edx),%cl
  8007fb:	74 eb                	je     8007e8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8007fd:	0f b6 00             	movzbl (%eax),%eax
  800800:	0f b6 12             	movzbl (%edx),%edx
  800803:	29 d0                	sub    %edx,%eax
  800805:	eb 05                	jmp    80080c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800807:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80080c:	5b                   	pop    %ebx
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	8b 45 08             	mov    0x8(%ebp),%eax
  800815:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800819:	eb 07                	jmp    800822 <strchr+0x13>
		if (*s == c)
  80081b:	38 ca                	cmp    %cl,%dl
  80081d:	74 0f                	je     80082e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80081f:	83 c0 01             	add    $0x1,%eax
  800822:	0f b6 10             	movzbl (%eax),%edx
  800825:	84 d2                	test   %dl,%dl
  800827:	75 f2                	jne    80081b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800829:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 45 08             	mov    0x8(%ebp),%eax
  800836:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80083a:	eb 03                	jmp    80083f <strfind+0xf>
  80083c:	83 c0 01             	add    $0x1,%eax
  80083f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800842:	38 ca                	cmp    %cl,%dl
  800844:	74 04                	je     80084a <strfind+0x1a>
  800846:	84 d2                	test   %dl,%dl
  800848:	75 f2                	jne    80083c <strfind+0xc>
			break;
	return (char *) s;
}
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	57                   	push   %edi
  800850:	56                   	push   %esi
  800851:	53                   	push   %ebx
  800852:	8b 7d 08             	mov    0x8(%ebp),%edi
  800855:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800858:	85 c9                	test   %ecx,%ecx
  80085a:	74 36                	je     800892 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80085c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800862:	75 28                	jne    80088c <memset+0x40>
  800864:	f6 c1 03             	test   $0x3,%cl
  800867:	75 23                	jne    80088c <memset+0x40>
		c &= 0xFF;
  800869:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80086d:	89 d3                	mov    %edx,%ebx
  80086f:	c1 e3 08             	shl    $0x8,%ebx
  800872:	89 d6                	mov    %edx,%esi
  800874:	c1 e6 18             	shl    $0x18,%esi
  800877:	89 d0                	mov    %edx,%eax
  800879:	c1 e0 10             	shl    $0x10,%eax
  80087c:	09 f0                	or     %esi,%eax
  80087e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800880:	89 d8                	mov    %ebx,%eax
  800882:	09 d0                	or     %edx,%eax
  800884:	c1 e9 02             	shr    $0x2,%ecx
  800887:	fc                   	cld    
  800888:	f3 ab                	rep stos %eax,%es:(%edi)
  80088a:	eb 06                	jmp    800892 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80088c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80088f:	fc                   	cld    
  800890:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800892:	89 f8                	mov    %edi,%eax
  800894:	5b                   	pop    %ebx
  800895:	5e                   	pop    %esi
  800896:	5f                   	pop    %edi
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	57                   	push   %edi
  80089d:	56                   	push   %esi
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008a7:	39 c6                	cmp    %eax,%esi
  8008a9:	73 35                	jae    8008e0 <memmove+0x47>
  8008ab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ae:	39 d0                	cmp    %edx,%eax
  8008b0:	73 2e                	jae    8008e0 <memmove+0x47>
		s += n;
		d += n;
  8008b2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008b5:	89 d6                	mov    %edx,%esi
  8008b7:	09 fe                	or     %edi,%esi
  8008b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008bf:	75 13                	jne    8008d4 <memmove+0x3b>
  8008c1:	f6 c1 03             	test   $0x3,%cl
  8008c4:	75 0e                	jne    8008d4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008c6:	83 ef 04             	sub    $0x4,%edi
  8008c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008cc:	c1 e9 02             	shr    $0x2,%ecx
  8008cf:	fd                   	std    
  8008d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008d2:	eb 09                	jmp    8008dd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008d4:	83 ef 01             	sub    $0x1,%edi
  8008d7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008da:	fd                   	std    
  8008db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008dd:	fc                   	cld    
  8008de:	eb 1d                	jmp    8008fd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008e0:	89 f2                	mov    %esi,%edx
  8008e2:	09 c2                	or     %eax,%edx
  8008e4:	f6 c2 03             	test   $0x3,%dl
  8008e7:	75 0f                	jne    8008f8 <memmove+0x5f>
  8008e9:	f6 c1 03             	test   $0x3,%cl
  8008ec:	75 0a                	jne    8008f8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008ee:	c1 e9 02             	shr    $0x2,%ecx
  8008f1:	89 c7                	mov    %eax,%edi
  8008f3:	fc                   	cld    
  8008f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008f6:	eb 05                	jmp    8008fd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8008f8:	89 c7                	mov    %eax,%edi
  8008fa:	fc                   	cld    
  8008fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8008fd:	5e                   	pop    %esi
  8008fe:	5f                   	pop    %edi
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800904:	ff 75 10             	pushl  0x10(%ebp)
  800907:	ff 75 0c             	pushl  0xc(%ebp)
  80090a:	ff 75 08             	pushl  0x8(%ebp)
  80090d:	e8 87 ff ff ff       	call   800899 <memmove>
}
  800912:	c9                   	leave  
  800913:	c3                   	ret    

00800914 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	89 c6                	mov    %eax,%esi
  800921:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800924:	eb 1a                	jmp    800940 <memcmp+0x2c>
		if (*s1 != *s2)
  800926:	0f b6 08             	movzbl (%eax),%ecx
  800929:	0f b6 1a             	movzbl (%edx),%ebx
  80092c:	38 d9                	cmp    %bl,%cl
  80092e:	74 0a                	je     80093a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800930:	0f b6 c1             	movzbl %cl,%eax
  800933:	0f b6 db             	movzbl %bl,%ebx
  800936:	29 d8                	sub    %ebx,%eax
  800938:	eb 0f                	jmp    800949 <memcmp+0x35>
		s1++, s2++;
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800940:	39 f0                	cmp    %esi,%eax
  800942:	75 e2                	jne    800926 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800944:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5d                   	pop    %ebp
  80094c:	c3                   	ret    

0080094d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	53                   	push   %ebx
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800954:	89 c1                	mov    %eax,%ecx
  800956:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800959:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80095d:	eb 0a                	jmp    800969 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80095f:	0f b6 10             	movzbl (%eax),%edx
  800962:	39 da                	cmp    %ebx,%edx
  800964:	74 07                	je     80096d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800966:	83 c0 01             	add    $0x1,%eax
  800969:	39 c8                	cmp    %ecx,%eax
  80096b:	72 f2                	jb     80095f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80096d:	5b                   	pop    %ebx
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	57                   	push   %edi
  800974:	56                   	push   %esi
  800975:	53                   	push   %ebx
  800976:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800979:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80097c:	eb 03                	jmp    800981 <strtol+0x11>
		s++;
  80097e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800981:	0f b6 01             	movzbl (%ecx),%eax
  800984:	3c 20                	cmp    $0x20,%al
  800986:	74 f6                	je     80097e <strtol+0xe>
  800988:	3c 09                	cmp    $0x9,%al
  80098a:	74 f2                	je     80097e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80098c:	3c 2b                	cmp    $0x2b,%al
  80098e:	75 0a                	jne    80099a <strtol+0x2a>
		s++;
  800990:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800993:	bf 00 00 00 00       	mov    $0x0,%edi
  800998:	eb 11                	jmp    8009ab <strtol+0x3b>
  80099a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80099f:	3c 2d                	cmp    $0x2d,%al
  8009a1:	75 08                	jne    8009ab <strtol+0x3b>
		s++, neg = 1;
  8009a3:	83 c1 01             	add    $0x1,%ecx
  8009a6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009ab:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009b1:	75 15                	jne    8009c8 <strtol+0x58>
  8009b3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009b6:	75 10                	jne    8009c8 <strtol+0x58>
  8009b8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009bc:	75 7c                	jne    800a3a <strtol+0xca>
		s += 2, base = 16;
  8009be:	83 c1 02             	add    $0x2,%ecx
  8009c1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009c6:	eb 16                	jmp    8009de <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009c8:	85 db                	test   %ebx,%ebx
  8009ca:	75 12                	jne    8009de <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009cc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009d1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009d4:	75 08                	jne    8009de <strtol+0x6e>
		s++, base = 8;
  8009d6:	83 c1 01             	add    $0x1,%ecx
  8009d9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009e6:	0f b6 11             	movzbl (%ecx),%edx
  8009e9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009ec:	89 f3                	mov    %esi,%ebx
  8009ee:	80 fb 09             	cmp    $0x9,%bl
  8009f1:	77 08                	ja     8009fb <strtol+0x8b>
			dig = *s - '0';
  8009f3:	0f be d2             	movsbl %dl,%edx
  8009f6:	83 ea 30             	sub    $0x30,%edx
  8009f9:	eb 22                	jmp    800a1d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8009fb:	8d 72 9f             	lea    -0x61(%edx),%esi
  8009fe:	89 f3                	mov    %esi,%ebx
  800a00:	80 fb 19             	cmp    $0x19,%bl
  800a03:	77 08                	ja     800a0d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a05:	0f be d2             	movsbl %dl,%edx
  800a08:	83 ea 57             	sub    $0x57,%edx
  800a0b:	eb 10                	jmp    800a1d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a0d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a10:	89 f3                	mov    %esi,%ebx
  800a12:	80 fb 19             	cmp    $0x19,%bl
  800a15:	77 16                	ja     800a2d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a17:	0f be d2             	movsbl %dl,%edx
  800a1a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a1d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a20:	7d 0b                	jge    800a2d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a22:	83 c1 01             	add    $0x1,%ecx
  800a25:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a29:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a2b:	eb b9                	jmp    8009e6 <strtol+0x76>

	if (endptr)
  800a2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a31:	74 0d                	je     800a40 <strtol+0xd0>
		*endptr = (char *) s;
  800a33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a36:	89 0e                	mov    %ecx,(%esi)
  800a38:	eb 06                	jmp    800a40 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3a:	85 db                	test   %ebx,%ebx
  800a3c:	74 98                	je     8009d6 <strtol+0x66>
  800a3e:	eb 9e                	jmp    8009de <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a40:	89 c2                	mov    %eax,%edx
  800a42:	f7 da                	neg    %edx
  800a44:	85 ff                	test   %edi,%edi
  800a46:	0f 45 c2             	cmovne %edx,%eax
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5f                   	pop    %edi
  800a4c:	5d                   	pop    %ebp
  800a4d:	c3                   	ret    

00800a4e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	57                   	push   %edi
  800a52:	56                   	push   %esi
  800a53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
  800a59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5f:	89 c3                	mov    %eax,%ebx
  800a61:	89 c7                	mov    %eax,%edi
  800a63:	89 c6                	mov    %eax,%esi
  800a65:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <sys_cgetc>:

int
sys_cgetc(void)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a72:	ba 00 00 00 00       	mov    $0x0,%edx
  800a77:	b8 01 00 00 00       	mov    $0x1,%eax
  800a7c:	89 d1                	mov    %edx,%ecx
  800a7e:	89 d3                	mov    %edx,%ebx
  800a80:	89 d7                	mov    %edx,%edi
  800a82:	89 d6                	mov    %edx,%esi
  800a84:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a86:	5b                   	pop    %ebx
  800a87:	5e                   	pop    %esi
  800a88:	5f                   	pop    %edi
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	57                   	push   %edi
  800a8f:	56                   	push   %esi
  800a90:	53                   	push   %ebx
  800a91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a99:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa1:	89 cb                	mov    %ecx,%ebx
  800aa3:	89 cf                	mov    %ecx,%edi
  800aa5:	89 ce                	mov    %ecx,%esi
  800aa7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800aa9:	85 c0                	test   %eax,%eax
  800aab:	7e 17                	jle    800ac4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aad:	83 ec 0c             	sub    $0xc,%esp
  800ab0:	50                   	push   %eax
  800ab1:	6a 03                	push   $0x3
  800ab3:	68 08 10 80 00       	push   $0x801008
  800ab8:	6a 23                	push   $0x23
  800aba:	68 25 10 80 00       	push   $0x801025
  800abf:	e8 3c 00 00 00       	call   800b00 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ac4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5f                   	pop    %edi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	57                   	push   %edi
  800ad0:	56                   	push   %esi
  800ad1:	53                   	push   %ebx
  800ad2:	83 ec 14             	sub    $0x14,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	b8 02 00 00 00       	mov    $0x2,%eax
  800adf:	89 d1                	mov    %edx,%ecx
  800ae1:	89 d3                	mov    %edx,%ebx
  800ae3:	89 d7                	mov    %edx,%edi
  800ae5:	89 d6                	mov    %edx,%esi
  800ae7:	cd 30                	int    $0x30
  800ae9:	89 c3                	mov    %eax,%ebx

envid_t
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	cprintf("lib/syscall.c: %x\n", ret);
  800aeb:	50                   	push   %eax
  800aec:	68 33 10 80 00       	push   $0x801033
  800af1:	e8 46 f6 ff ff       	call   80013c <cprintf>
	return ret;
}
  800af6:	89 d8                	mov    %ebx,%eax
  800af8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b05:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b08:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800b0e:	e8 b9 ff ff ff       	call   800acc <sys_getenvid>
  800b13:	83 ec 0c             	sub    $0xc,%esp
  800b16:	ff 75 0c             	pushl  0xc(%ebp)
  800b19:	ff 75 08             	pushl  0x8(%ebp)
  800b1c:	56                   	push   %esi
  800b1d:	50                   	push   %eax
  800b1e:	68 48 10 80 00       	push   $0x801048
  800b23:	e8 14 f6 ff ff       	call   80013c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b28:	83 c4 18             	add    $0x18,%esp
  800b2b:	53                   	push   %ebx
  800b2c:	ff 75 10             	pushl  0x10(%ebp)
  800b2f:	e8 b7 f5 ff ff       	call   8000eb <vcprintf>
	cprintf("\n");
  800b34:	c7 04 24 44 10 80 00 	movl   $0x801044,(%esp)
  800b3b:	e8 fc f5 ff ff       	call   80013c <cprintf>
  800b40:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b43:	cc                   	int3   
  800b44:	eb fd                	jmp    800b43 <_panic+0x43>
  800b46:	66 90                	xchg   %ax,%ax
  800b48:	66 90                	xchg   %ax,%ax
  800b4a:	66 90                	xchg   %ax,%ax
  800b4c:	66 90                	xchg   %ax,%ax
  800b4e:	66 90                	xchg   %ax,%ax

00800b50 <__udivdi3>:
  800b50:	55                   	push   %ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	83 ec 1c             	sub    $0x1c,%esp
  800b57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b67:	85 f6                	test   %esi,%esi
  800b69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b6d:	89 ca                	mov    %ecx,%edx
  800b6f:	89 f8                	mov    %edi,%eax
  800b71:	75 3d                	jne    800bb0 <__udivdi3+0x60>
  800b73:	39 cf                	cmp    %ecx,%edi
  800b75:	0f 87 c5 00 00 00    	ja     800c40 <__udivdi3+0xf0>
  800b7b:	85 ff                	test   %edi,%edi
  800b7d:	89 fd                	mov    %edi,%ebp
  800b7f:	75 0b                	jne    800b8c <__udivdi3+0x3c>
  800b81:	b8 01 00 00 00       	mov    $0x1,%eax
  800b86:	31 d2                	xor    %edx,%edx
  800b88:	f7 f7                	div    %edi
  800b8a:	89 c5                	mov    %eax,%ebp
  800b8c:	89 c8                	mov    %ecx,%eax
  800b8e:	31 d2                	xor    %edx,%edx
  800b90:	f7 f5                	div    %ebp
  800b92:	89 c1                	mov    %eax,%ecx
  800b94:	89 d8                	mov    %ebx,%eax
  800b96:	89 cf                	mov    %ecx,%edi
  800b98:	f7 f5                	div    %ebp
  800b9a:	89 c3                	mov    %eax,%ebx
  800b9c:	89 d8                	mov    %ebx,%eax
  800b9e:	89 fa                	mov    %edi,%edx
  800ba0:	83 c4 1c             	add    $0x1c,%esp
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    
  800ba8:	90                   	nop
  800ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bb0:	39 ce                	cmp    %ecx,%esi
  800bb2:	77 74                	ja     800c28 <__udivdi3+0xd8>
  800bb4:	0f bd fe             	bsr    %esi,%edi
  800bb7:	83 f7 1f             	xor    $0x1f,%edi
  800bba:	0f 84 98 00 00 00    	je     800c58 <__udivdi3+0x108>
  800bc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800bc5:	89 f9                	mov    %edi,%ecx
  800bc7:	89 c5                	mov    %eax,%ebp
  800bc9:	29 fb                	sub    %edi,%ebx
  800bcb:	d3 e6                	shl    %cl,%esi
  800bcd:	89 d9                	mov    %ebx,%ecx
  800bcf:	d3 ed                	shr    %cl,%ebp
  800bd1:	89 f9                	mov    %edi,%ecx
  800bd3:	d3 e0                	shl    %cl,%eax
  800bd5:	09 ee                	or     %ebp,%esi
  800bd7:	89 d9                	mov    %ebx,%ecx
  800bd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bdd:	89 d5                	mov    %edx,%ebp
  800bdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800be3:	d3 ed                	shr    %cl,%ebp
  800be5:	89 f9                	mov    %edi,%ecx
  800be7:	d3 e2                	shl    %cl,%edx
  800be9:	89 d9                	mov    %ebx,%ecx
  800beb:	d3 e8                	shr    %cl,%eax
  800bed:	09 c2                	or     %eax,%edx
  800bef:	89 d0                	mov    %edx,%eax
  800bf1:	89 ea                	mov    %ebp,%edx
  800bf3:	f7 f6                	div    %esi
  800bf5:	89 d5                	mov    %edx,%ebp
  800bf7:	89 c3                	mov    %eax,%ebx
  800bf9:	f7 64 24 0c          	mull   0xc(%esp)
  800bfd:	39 d5                	cmp    %edx,%ebp
  800bff:	72 10                	jb     800c11 <__udivdi3+0xc1>
  800c01:	8b 74 24 08          	mov    0x8(%esp),%esi
  800c05:	89 f9                	mov    %edi,%ecx
  800c07:	d3 e6                	shl    %cl,%esi
  800c09:	39 c6                	cmp    %eax,%esi
  800c0b:	73 07                	jae    800c14 <__udivdi3+0xc4>
  800c0d:	39 d5                	cmp    %edx,%ebp
  800c0f:	75 03                	jne    800c14 <__udivdi3+0xc4>
  800c11:	83 eb 01             	sub    $0x1,%ebx
  800c14:	31 ff                	xor    %edi,%edi
  800c16:	89 d8                	mov    %ebx,%eax
  800c18:	89 fa                	mov    %edi,%edx
  800c1a:	83 c4 1c             	add    $0x1c,%esp
  800c1d:	5b                   	pop    %ebx
  800c1e:	5e                   	pop    %esi
  800c1f:	5f                   	pop    %edi
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    
  800c22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c28:	31 ff                	xor    %edi,%edi
  800c2a:	31 db                	xor    %ebx,%ebx
  800c2c:	89 d8                	mov    %ebx,%eax
  800c2e:	89 fa                	mov    %edi,%edx
  800c30:	83 c4 1c             	add    $0x1c,%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    
  800c38:	90                   	nop
  800c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c40:	89 d8                	mov    %ebx,%eax
  800c42:	f7 f7                	div    %edi
  800c44:	31 ff                	xor    %edi,%edi
  800c46:	89 c3                	mov    %eax,%ebx
  800c48:	89 d8                	mov    %ebx,%eax
  800c4a:	89 fa                	mov    %edi,%edx
  800c4c:	83 c4 1c             	add    $0x1c,%esp
  800c4f:	5b                   	pop    %ebx
  800c50:	5e                   	pop    %esi
  800c51:	5f                   	pop    %edi
  800c52:	5d                   	pop    %ebp
  800c53:	c3                   	ret    
  800c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c58:	39 ce                	cmp    %ecx,%esi
  800c5a:	72 0c                	jb     800c68 <__udivdi3+0x118>
  800c5c:	31 db                	xor    %ebx,%ebx
  800c5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c62:	0f 87 34 ff ff ff    	ja     800b9c <__udivdi3+0x4c>
  800c68:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c6d:	e9 2a ff ff ff       	jmp    800b9c <__udivdi3+0x4c>
  800c72:	66 90                	xchg   %ax,%ax
  800c74:	66 90                	xchg   %ax,%ax
  800c76:	66 90                	xchg   %ax,%ax
  800c78:	66 90                	xchg   %ax,%ax
  800c7a:	66 90                	xchg   %ax,%ax
  800c7c:	66 90                	xchg   %ax,%ax
  800c7e:	66 90                	xchg   %ax,%ax

00800c80 <__umoddi3>:
  800c80:	55                   	push   %ebp
  800c81:	57                   	push   %edi
  800c82:	56                   	push   %esi
  800c83:	53                   	push   %ebx
  800c84:	83 ec 1c             	sub    $0x1c,%esp
  800c87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c97:	85 d2                	test   %edx,%edx
  800c99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ca1:	89 f3                	mov    %esi,%ebx
  800ca3:	89 3c 24             	mov    %edi,(%esp)
  800ca6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800caa:	75 1c                	jne    800cc8 <__umoddi3+0x48>
  800cac:	39 f7                	cmp    %esi,%edi
  800cae:	76 50                	jbe    800d00 <__umoddi3+0x80>
  800cb0:	89 c8                	mov    %ecx,%eax
  800cb2:	89 f2                	mov    %esi,%edx
  800cb4:	f7 f7                	div    %edi
  800cb6:	89 d0                	mov    %edx,%eax
  800cb8:	31 d2                	xor    %edx,%edx
  800cba:	83 c4 1c             	add    $0x1c,%esp
  800cbd:	5b                   	pop    %ebx
  800cbe:	5e                   	pop    %esi
  800cbf:	5f                   	pop    %edi
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    
  800cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cc8:	39 f2                	cmp    %esi,%edx
  800cca:	89 d0                	mov    %edx,%eax
  800ccc:	77 52                	ja     800d20 <__umoddi3+0xa0>
  800cce:	0f bd ea             	bsr    %edx,%ebp
  800cd1:	83 f5 1f             	xor    $0x1f,%ebp
  800cd4:	75 5a                	jne    800d30 <__umoddi3+0xb0>
  800cd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800cda:	0f 82 e0 00 00 00    	jb     800dc0 <__umoddi3+0x140>
  800ce0:	39 0c 24             	cmp    %ecx,(%esp)
  800ce3:	0f 86 d7 00 00 00    	jbe    800dc0 <__umoddi3+0x140>
  800ce9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ced:	8b 54 24 04          	mov    0x4(%esp),%edx
  800cf1:	83 c4 1c             	add    $0x1c,%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    
  800cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d00:	85 ff                	test   %edi,%edi
  800d02:	89 fd                	mov    %edi,%ebp
  800d04:	75 0b                	jne    800d11 <__umoddi3+0x91>
  800d06:	b8 01 00 00 00       	mov    $0x1,%eax
  800d0b:	31 d2                	xor    %edx,%edx
  800d0d:	f7 f7                	div    %edi
  800d0f:	89 c5                	mov    %eax,%ebp
  800d11:	89 f0                	mov    %esi,%eax
  800d13:	31 d2                	xor    %edx,%edx
  800d15:	f7 f5                	div    %ebp
  800d17:	89 c8                	mov    %ecx,%eax
  800d19:	f7 f5                	div    %ebp
  800d1b:	89 d0                	mov    %edx,%eax
  800d1d:	eb 99                	jmp    800cb8 <__umoddi3+0x38>
  800d1f:	90                   	nop
  800d20:	89 c8                	mov    %ecx,%eax
  800d22:	89 f2                	mov    %esi,%edx
  800d24:	83 c4 1c             	add    $0x1c,%esp
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    
  800d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d30:	8b 34 24             	mov    (%esp),%esi
  800d33:	bf 20 00 00 00       	mov    $0x20,%edi
  800d38:	89 e9                	mov    %ebp,%ecx
  800d3a:	29 ef                	sub    %ebp,%edi
  800d3c:	d3 e0                	shl    %cl,%eax
  800d3e:	89 f9                	mov    %edi,%ecx
  800d40:	89 f2                	mov    %esi,%edx
  800d42:	d3 ea                	shr    %cl,%edx
  800d44:	89 e9                	mov    %ebp,%ecx
  800d46:	09 c2                	or     %eax,%edx
  800d48:	89 d8                	mov    %ebx,%eax
  800d4a:	89 14 24             	mov    %edx,(%esp)
  800d4d:	89 f2                	mov    %esi,%edx
  800d4f:	d3 e2                	shl    %cl,%edx
  800d51:	89 f9                	mov    %edi,%ecx
  800d53:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d5b:	d3 e8                	shr    %cl,%eax
  800d5d:	89 e9                	mov    %ebp,%ecx
  800d5f:	89 c6                	mov    %eax,%esi
  800d61:	d3 e3                	shl    %cl,%ebx
  800d63:	89 f9                	mov    %edi,%ecx
  800d65:	89 d0                	mov    %edx,%eax
  800d67:	d3 e8                	shr    %cl,%eax
  800d69:	89 e9                	mov    %ebp,%ecx
  800d6b:	09 d8                	or     %ebx,%eax
  800d6d:	89 d3                	mov    %edx,%ebx
  800d6f:	89 f2                	mov    %esi,%edx
  800d71:	f7 34 24             	divl   (%esp)
  800d74:	89 d6                	mov    %edx,%esi
  800d76:	d3 e3                	shl    %cl,%ebx
  800d78:	f7 64 24 04          	mull   0x4(%esp)
  800d7c:	39 d6                	cmp    %edx,%esi
  800d7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d82:	89 d1                	mov    %edx,%ecx
  800d84:	89 c3                	mov    %eax,%ebx
  800d86:	72 08                	jb     800d90 <__umoddi3+0x110>
  800d88:	75 11                	jne    800d9b <__umoddi3+0x11b>
  800d8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d8e:	73 0b                	jae    800d9b <__umoddi3+0x11b>
  800d90:	2b 44 24 04          	sub    0x4(%esp),%eax
  800d94:	1b 14 24             	sbb    (%esp),%edx
  800d97:	89 d1                	mov    %edx,%ecx
  800d99:	89 c3                	mov    %eax,%ebx
  800d9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800d9f:	29 da                	sub    %ebx,%edx
  800da1:	19 ce                	sbb    %ecx,%esi
  800da3:	89 f9                	mov    %edi,%ecx
  800da5:	89 f0                	mov    %esi,%eax
  800da7:	d3 e0                	shl    %cl,%eax
  800da9:	89 e9                	mov    %ebp,%ecx
  800dab:	d3 ea                	shr    %cl,%edx
  800dad:	89 e9                	mov    %ebp,%ecx
  800daf:	d3 ee                	shr    %cl,%esi
  800db1:	09 d0                	or     %edx,%eax
  800db3:	89 f2                	mov    %esi,%edx
  800db5:	83 c4 1c             	add    $0x1c,%esp
  800db8:	5b                   	pop    %ebx
  800db9:	5e                   	pop    %esi
  800dba:	5f                   	pop    %edi
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    
  800dbd:	8d 76 00             	lea    0x0(%esi),%esi
  800dc0:	29 f9                	sub    %edi,%ecx
  800dc2:	19 d6                	sbb    %edx,%esi
  800dc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dcc:	e9 18 ff ff ff       	jmp    800ce9 <__umoddi3+0x69>
