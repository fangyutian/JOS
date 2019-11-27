
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
  800039:	68 e4 0d 80 00       	push   $0x800de4
  80003e:	e8 09 01 00 00       	call   80014c <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 f2 0d 80 00       	push   $0x800df2
  800054:	e8 f3 00 00 00       	call   80014c <cprintf>
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
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800069:	e8 6e 0a 00 00       	call   800adc <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800076:	c1 e0 05             	shl    $0x5,%eax
  800079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007e:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800083:	85 db                	test   %ebx,%ebx
  800085:	7e 07                	jle    80008e <libmain+0x30>
		binaryname = argv[0];
  800087:	8b 06                	mov    (%esi),%eax
  800089:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008e:	83 ec 08             	sub    $0x8,%esp
  800091:	56                   	push   %esi
  800092:	53                   	push   %ebx
  800093:	e8 9b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800098:	e8 0a 00 00 00       	call   8000a7 <exit>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a3:	5b                   	pop    %ebx
  8000a4:	5e                   	pop    %esi
  8000a5:	5d                   	pop    %ebp
  8000a6:	c3                   	ret    

008000a7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ad:	6a 00                	push   $0x0
  8000af:	e8 e7 09 00 00       	call   800a9b <sys_env_destroy>
}
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    

008000b9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	53                   	push   %ebx
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c3:	8b 13                	mov    (%ebx),%edx
  8000c5:	8d 42 01             	lea    0x1(%edx),%eax
  8000c8:	89 03                	mov    %eax,(%ebx)
  8000ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d6:	75 1a                	jne    8000f2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000d8:	83 ec 08             	sub    $0x8,%esp
  8000db:	68 ff 00 00 00       	push   $0xff
  8000e0:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e3:	50                   	push   %eax
  8000e4:	e8 75 09 00 00       	call   800a5e <sys_cputs>
		b->idx = 0;
  8000e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000ef:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000f9:	c9                   	leave  
  8000fa:	c3                   	ret    

008000fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800104:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010b:	00 00 00 
	b.cnt = 0;
  80010e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800115:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800118:	ff 75 0c             	pushl  0xc(%ebp)
  80011b:	ff 75 08             	pushl  0x8(%ebp)
  80011e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800124:	50                   	push   %eax
  800125:	68 b9 00 80 00       	push   $0x8000b9
  80012a:	e8 54 01 00 00       	call   800283 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012f:	83 c4 08             	add    $0x8,%esp
  800132:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800138:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013e:	50                   	push   %eax
  80013f:	e8 1a 09 00 00       	call   800a5e <sys_cputs>

	return b.cnt;
}
  800144:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014a:	c9                   	leave  
  80014b:	c3                   	ret    

0080014c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800152:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800155:	50                   	push   %eax
  800156:	ff 75 08             	pushl  0x8(%ebp)
  800159:	e8 9d ff ff ff       	call   8000fb <vcprintf>
	va_end(ap);

	return cnt;
}
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 1c             	sub    $0x1c,%esp
  800169:	89 c7                	mov    %eax,%edi
  80016b:	89 d6                	mov    %edx,%esi
  80016d:	8b 45 08             	mov    0x8(%ebp),%eax
  800170:	8b 55 0c             	mov    0xc(%ebp),%edx
  800173:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800176:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800179:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800181:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800184:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800187:	39 d3                	cmp    %edx,%ebx
  800189:	72 05                	jb     800190 <printnum+0x30>
  80018b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018e:	77 45                	ja     8001d5 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	ff 75 18             	pushl  0x18(%ebp)
  800196:	8b 45 14             	mov    0x14(%ebp),%eax
  800199:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019c:	53                   	push   %ebx
  80019d:	ff 75 10             	pushl  0x10(%ebp)
  8001a0:	83 ec 08             	sub    $0x8,%esp
  8001a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a6:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a9:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ac:	ff 75 d8             	pushl  -0x28(%ebp)
  8001af:	e8 ac 09 00 00       	call   800b60 <__udivdi3>
  8001b4:	83 c4 18             	add    $0x18,%esp
  8001b7:	52                   	push   %edx
  8001b8:	50                   	push   %eax
  8001b9:	89 f2                	mov    %esi,%edx
  8001bb:	89 f8                	mov    %edi,%eax
  8001bd:	e8 9e ff ff ff       	call   800160 <printnum>
  8001c2:	83 c4 20             	add    $0x20,%esp
  8001c5:	eb 18                	jmp    8001df <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	56                   	push   %esi
  8001cb:	ff 75 18             	pushl  0x18(%ebp)
  8001ce:	ff d7                	call   *%edi
  8001d0:	83 c4 10             	add    $0x10,%esp
  8001d3:	eb 03                	jmp    8001d8 <printnum+0x78>
  8001d5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	85 db                	test   %ebx,%ebx
  8001dd:	7f e8                	jg     8001c7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001df:	83 ec 08             	sub    $0x8,%esp
  8001e2:	56                   	push   %esi
  8001e3:	83 ec 04             	sub    $0x4,%esp
  8001e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f2:	e8 99 0a 00 00       	call   800c90 <__umoddi3>
  8001f7:	83 c4 14             	add    $0x14,%esp
  8001fa:	0f be 80 13 0e 80 00 	movsbl 0x800e13(%eax),%eax
  800201:	50                   	push   %eax
  800202:	ff d7                	call   *%edi
}
  800204:	83 c4 10             	add    $0x10,%esp
  800207:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020a:	5b                   	pop    %ebx
  80020b:	5e                   	pop    %esi
  80020c:	5f                   	pop    %edi
  80020d:	5d                   	pop    %ebp
  80020e:	c3                   	ret    

0080020f <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800212:	83 fa 01             	cmp    $0x1,%edx
  800215:	7e 0e                	jle    800225 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800217:	8b 10                	mov    (%eax),%edx
  800219:	8d 4a 08             	lea    0x8(%edx),%ecx
  80021c:	89 08                	mov    %ecx,(%eax)
  80021e:	8b 02                	mov    (%edx),%eax
  800220:	8b 52 04             	mov    0x4(%edx),%edx
  800223:	eb 22                	jmp    800247 <getuint+0x38>
	else if (lflag)
  800225:	85 d2                	test   %edx,%edx
  800227:	74 10                	je     800239 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800229:	8b 10                	mov    (%eax),%edx
  80022b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80022e:	89 08                	mov    %ecx,(%eax)
  800230:	8b 02                	mov    (%edx),%eax
  800232:	ba 00 00 00 00       	mov    $0x0,%edx
  800237:	eb 0e                	jmp    800247 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800239:	8b 10                	mov    (%eax),%edx
  80023b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80023e:	89 08                	mov    %ecx,(%eax)
  800240:	8b 02                	mov    (%edx),%eax
  800242:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800247:	5d                   	pop    %ebp
  800248:	c3                   	ret    

00800249 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800249:	55                   	push   %ebp
  80024a:	89 e5                	mov    %esp,%ebp
  80024c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80024f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800253:	8b 10                	mov    (%eax),%edx
  800255:	3b 50 04             	cmp    0x4(%eax),%edx
  800258:	73 0a                	jae    800264 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 45 08             	mov    0x8(%ebp),%eax
  800262:	88 02                	mov    %al,(%edx)
}
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    

00800266 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80026c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80026f:	50                   	push   %eax
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	ff 75 0c             	pushl  0xc(%ebp)
  800276:	ff 75 08             	pushl  0x8(%ebp)
  800279:	e8 05 00 00 00       	call   800283 <vprintfmt>
	va_end(ap);
}
  80027e:	83 c4 10             	add    $0x10,%esp
  800281:	c9                   	leave  
  800282:	c3                   	ret    

00800283 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 2c             	sub    $0x2c,%esp
  80028c:	8b 75 08             	mov    0x8(%ebp),%esi
  80028f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800292:	8b 7d 10             	mov    0x10(%ebp),%edi
  800295:	eb 1d                	jmp    8002b4 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800297:	85 c0                	test   %eax,%eax
  800299:	75 0f                	jne    8002aa <vprintfmt+0x27>
				csa = 0x0700;
  80029b:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  8002a2:	07 00 00 
				return;
  8002a5:	e9 c4 03 00 00       	jmp    80066e <vprintfmt+0x3eb>
			}
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
  8002be:	75 d7                	jne    800297 <vprintfmt+0x14>
  8002c0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002cb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002d2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002de:	eb 07                	jmp    8002e7 <vprintfmt+0x64>
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
  8002f0:	0f b6 c8             	movzbl %al,%ecx
  8002f3:	83 e8 23             	sub    $0x23,%eax
  8002f6:	3c 55                	cmp    $0x55,%al
  8002f8:	0f 87 55 03 00 00    	ja     800653 <vprintfmt+0x3d0>
  8002fe:	0f b6 c0             	movzbl %al,%eax
  800301:	ff 24 85 a0 0e 80 00 	jmp    *0x800ea0(,%eax,4)
  800308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80030f:	eb d6                	jmp    8002e7 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800314:	b8 00 00 00 00       	mov    $0x0,%eax
  800319:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031f:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800323:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800326:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800329:	83 fa 09             	cmp    $0x9,%edx
  80032c:	77 39                	ja     800367 <vprintfmt+0xe4>
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
  800331:	eb e9                	jmp    80031c <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800333:	8b 45 14             	mov    0x14(%ebp),%eax
  800336:	8d 48 04             	lea    0x4(%eax),%ecx
  800339:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80033c:	8b 00                	mov    (%eax),%eax
  80033e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800344:	eb 27                	jmp    80036d <vprintfmt+0xea>
  800346:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800349:	85 c0                	test   %eax,%eax
  80034b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800350:	0f 49 c8             	cmovns %eax,%ecx
  800353:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800359:	eb 8c                	jmp    8002e7 <vprintfmt+0x64>
  80035b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80035e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800365:	eb 80                	jmp    8002e7 <vprintfmt+0x64>
  800367:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80036a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80036d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800371:	0f 89 70 ff ff ff    	jns    8002e7 <vprintfmt+0x64>
				width = precision, precision = -1;
  800377:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80037a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80037d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800384:	e9 5e ff ff ff       	jmp    8002e7 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800389:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80038f:	e9 53 ff ff ff       	jmp    8002e7 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8d 50 04             	lea    0x4(%eax),%edx
  80039a:	89 55 14             	mov    %edx,0x14(%ebp)
  80039d:	83 ec 08             	sub    $0x8,%esp
  8003a0:	53                   	push   %ebx
  8003a1:	ff 30                	pushl  (%eax)
  8003a3:	ff d6                	call   *%esi
			break;
  8003a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003ab:	e9 04 ff ff ff       	jmp    8002b4 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b3:	8d 50 04             	lea    0x4(%eax),%edx
  8003b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003b9:	8b 00                	mov    (%eax),%eax
  8003bb:	99                   	cltd   
  8003bc:	31 d0                	xor    %edx,%eax
  8003be:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c0:	83 f8 06             	cmp    $0x6,%eax
  8003c3:	7f 0b                	jg     8003d0 <vprintfmt+0x14d>
  8003c5:	8b 14 85 f8 0f 80 00 	mov    0x800ff8(,%eax,4),%edx
  8003cc:	85 d2                	test   %edx,%edx
  8003ce:	75 18                	jne    8003e8 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8003d0:	50                   	push   %eax
  8003d1:	68 2b 0e 80 00       	push   $0x800e2b
  8003d6:	53                   	push   %ebx
  8003d7:	56                   	push   %esi
  8003d8:	e8 89 fe ff ff       	call   800266 <printfmt>
  8003dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003e3:	e9 cc fe ff ff       	jmp    8002b4 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8003e8:	52                   	push   %edx
  8003e9:	68 34 0e 80 00       	push   $0x800e34
  8003ee:	53                   	push   %ebx
  8003ef:	56                   	push   %esi
  8003f0:	e8 71 fe ff ff       	call   800266 <printfmt>
  8003f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fb:	e9 b4 fe ff ff       	jmp    8002b4 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 50 04             	lea    0x4(%eax),%edx
  800406:	89 55 14             	mov    %edx,0x14(%ebp)
  800409:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80040b:	85 ff                	test   %edi,%edi
  80040d:	b8 24 0e 80 00       	mov    $0x800e24,%eax
  800412:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800415:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800419:	0f 8e 94 00 00 00    	jle    8004b3 <vprintfmt+0x230>
  80041f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800423:	0f 84 98 00 00 00    	je     8004c1 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	ff 75 d0             	pushl  -0x30(%ebp)
  80042f:	57                   	push   %edi
  800430:	e8 c1 02 00 00       	call   8006f6 <strnlen>
  800435:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800438:	29 c1                	sub    %eax,%ecx
  80043a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80043d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800440:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800444:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800447:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80044a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80044c:	eb 0f                	jmp    80045d <vprintfmt+0x1da>
					putch(padc, putdat);
  80044e:	83 ec 08             	sub    $0x8,%esp
  800451:	53                   	push   %ebx
  800452:	ff 75 e0             	pushl  -0x20(%ebp)
  800455:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800457:	83 ef 01             	sub    $0x1,%edi
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	85 ff                	test   %edi,%edi
  80045f:	7f ed                	jg     80044e <vprintfmt+0x1cb>
  800461:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800464:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800467:	85 c9                	test   %ecx,%ecx
  800469:	b8 00 00 00 00       	mov    $0x0,%eax
  80046e:	0f 49 c1             	cmovns %ecx,%eax
  800471:	29 c1                	sub    %eax,%ecx
  800473:	89 75 08             	mov    %esi,0x8(%ebp)
  800476:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800479:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047c:	89 cb                	mov    %ecx,%ebx
  80047e:	eb 4d                	jmp    8004cd <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800480:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800484:	74 1b                	je     8004a1 <vprintfmt+0x21e>
  800486:	0f be c0             	movsbl %al,%eax
  800489:	83 e8 20             	sub    $0x20,%eax
  80048c:	83 f8 5e             	cmp    $0x5e,%eax
  80048f:	76 10                	jbe    8004a1 <vprintfmt+0x21e>
					putch('?', putdat);
  800491:	83 ec 08             	sub    $0x8,%esp
  800494:	ff 75 0c             	pushl  0xc(%ebp)
  800497:	6a 3f                	push   $0x3f
  800499:	ff 55 08             	call   *0x8(%ebp)
  80049c:	83 c4 10             	add    $0x10,%esp
  80049f:	eb 0d                	jmp    8004ae <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	ff 75 0c             	pushl  0xc(%ebp)
  8004a7:	52                   	push   %edx
  8004a8:	ff 55 08             	call   *0x8(%ebp)
  8004ab:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ae:	83 eb 01             	sub    $0x1,%ebx
  8004b1:	eb 1a                	jmp    8004cd <vprintfmt+0x24a>
  8004b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bf:	eb 0c                	jmp    8004cd <vprintfmt+0x24a>
  8004c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cd:	83 c7 01             	add    $0x1,%edi
  8004d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d4:	0f be d0             	movsbl %al,%edx
  8004d7:	85 d2                	test   %edx,%edx
  8004d9:	74 23                	je     8004fe <vprintfmt+0x27b>
  8004db:	85 f6                	test   %esi,%esi
  8004dd:	78 a1                	js     800480 <vprintfmt+0x1fd>
  8004df:	83 ee 01             	sub    $0x1,%esi
  8004e2:	79 9c                	jns    800480 <vprintfmt+0x1fd>
  8004e4:	89 df                	mov    %ebx,%edi
  8004e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ec:	eb 18                	jmp    800506 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	53                   	push   %ebx
  8004f2:	6a 20                	push   $0x20
  8004f4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004f6:	83 ef 01             	sub    $0x1,%edi
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	eb 08                	jmp    800506 <vprintfmt+0x283>
  8004fe:	89 df                	mov    %ebx,%edi
  800500:	8b 75 08             	mov    0x8(%ebp),%esi
  800503:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800506:	85 ff                	test   %edi,%edi
  800508:	7f e4                	jg     8004ee <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80050d:	e9 a2 fd ff ff       	jmp    8002b4 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800512:	83 fa 01             	cmp    $0x1,%edx
  800515:	7e 16                	jle    80052d <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 50 08             	lea    0x8(%eax),%edx
  80051d:	89 55 14             	mov    %edx,0x14(%ebp)
  800520:	8b 50 04             	mov    0x4(%eax),%edx
  800523:	8b 00                	mov    (%eax),%eax
  800525:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800528:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80052b:	eb 32                	jmp    80055f <vprintfmt+0x2dc>
	else if (lflag)
  80052d:	85 d2                	test   %edx,%edx
  80052f:	74 18                	je     800549 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 50 04             	lea    0x4(%eax),%edx
  800537:	89 55 14             	mov    %edx,0x14(%ebp)
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053f:	89 c1                	mov    %eax,%ecx
  800541:	c1 f9 1f             	sar    $0x1f,%ecx
  800544:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800547:	eb 16                	jmp    80055f <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8d 50 04             	lea    0x4(%eax),%edx
  80054f:	89 55 14             	mov    %edx,0x14(%ebp)
  800552:	8b 00                	mov    (%eax),%eax
  800554:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800557:	89 c1                	mov    %eax,%ecx
  800559:	c1 f9 1f             	sar    $0x1f,%ecx
  80055c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800562:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800565:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80056a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056e:	79 74                	jns    8005e4 <vprintfmt+0x361>
				putch('-', putdat);
  800570:	83 ec 08             	sub    $0x8,%esp
  800573:	53                   	push   %ebx
  800574:	6a 2d                	push   $0x2d
  800576:	ff d6                	call   *%esi
				num = -(long long) num;
  800578:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80057b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80057e:	f7 d8                	neg    %eax
  800580:	83 d2 00             	adc    $0x0,%edx
  800583:	f7 da                	neg    %edx
  800585:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800588:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80058d:	eb 55                	jmp    8005e4 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80058f:	8d 45 14             	lea    0x14(%ebp),%eax
  800592:	e8 78 fc ff ff       	call   80020f <getuint>
			base = 10;
  800597:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80059c:	eb 46                	jmp    8005e4 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80059e:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a1:	e8 69 fc ff ff       	call   80020f <getuint>
      base = 8;
  8005a6:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  8005ab:	eb 37                	jmp    8005e4 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	53                   	push   %ebx
  8005b1:	6a 30                	push   $0x30
  8005b3:	ff d6                	call   *%esi
			putch('x', putdat);
  8005b5:	83 c4 08             	add    $0x8,%esp
  8005b8:	53                   	push   %ebx
  8005b9:	6a 78                	push   $0x78
  8005bb:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 50 04             	lea    0x4(%eax),%edx
  8005c3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8005c6:	8b 00                	mov    (%eax),%eax
  8005c8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005cd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8005d0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8005d5:	eb 0d                	jmp    8005e4 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8005d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005da:	e8 30 fc ff ff       	call   80020f <getuint>
			base = 16;
  8005df:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8005e4:	83 ec 0c             	sub    $0xc,%esp
  8005e7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005eb:	57                   	push   %edi
  8005ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ef:	51                   	push   %ecx
  8005f0:	52                   	push   %edx
  8005f1:	50                   	push   %eax
  8005f2:	89 da                	mov    %ebx,%edx
  8005f4:	89 f0                	mov    %esi,%eax
  8005f6:	e8 65 fb ff ff       	call   800160 <printnum>
			break;
  8005fb:	83 c4 20             	add    $0x20,%esp
  8005fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800601:	e9 ae fc ff ff       	jmp    8002b4 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	51                   	push   %ecx
  80060b:	ff d6                	call   *%esi
			break;
  80060d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800610:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800613:	e9 9c fc ff ff       	jmp    8002b4 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800618:	83 fa 01             	cmp    $0x1,%edx
  80061b:	7e 0d                	jle    80062a <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 50 08             	lea    0x8(%eax),%edx
  800623:	89 55 14             	mov    %edx,0x14(%ebp)
  800626:	8b 00                	mov    (%eax),%eax
  800628:	eb 1c                	jmp    800646 <vprintfmt+0x3c3>
	else if (lflag)
  80062a:	85 d2                	test   %edx,%edx
  80062c:	74 0d                	je     80063b <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 00                	mov    (%eax),%eax
  800639:	eb 0b                	jmp    800646 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8d 50 04             	lea    0x4(%eax),%edx
  800641:	89 55 14             	mov    %edx,0x14(%ebp)
  800644:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800646:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  80064e:	e9 61 fc ff ff       	jmp    8002b4 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	53                   	push   %ebx
  800657:	6a 25                	push   $0x25
  800659:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80065b:	83 c4 10             	add    $0x10,%esp
  80065e:	eb 03                	jmp    800663 <vprintfmt+0x3e0>
  800660:	83 ef 01             	sub    $0x1,%edi
  800663:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800667:	75 f7                	jne    800660 <vprintfmt+0x3dd>
  800669:	e9 46 fc ff ff       	jmp    8002b4 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80066e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800671:	5b                   	pop    %ebx
  800672:	5e                   	pop    %esi
  800673:	5f                   	pop    %edi
  800674:	5d                   	pop    %ebp
  800675:	c3                   	ret    

00800676 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800676:	55                   	push   %ebp
  800677:	89 e5                	mov    %esp,%ebp
  800679:	83 ec 18             	sub    $0x18,%esp
  80067c:	8b 45 08             	mov    0x8(%ebp),%eax
  80067f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800682:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800685:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800689:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80068c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800693:	85 c0                	test   %eax,%eax
  800695:	74 26                	je     8006bd <vsnprintf+0x47>
  800697:	85 d2                	test   %edx,%edx
  800699:	7e 22                	jle    8006bd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80069b:	ff 75 14             	pushl  0x14(%ebp)
  80069e:	ff 75 10             	pushl  0x10(%ebp)
  8006a1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006a4:	50                   	push   %eax
  8006a5:	68 49 02 80 00       	push   $0x800249
  8006aa:	e8 d4 fb ff ff       	call   800283 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006af:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006b2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	eb 05                	jmp    8006c2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006ca:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006cd:	50                   	push   %eax
  8006ce:	ff 75 10             	pushl  0x10(%ebp)
  8006d1:	ff 75 0c             	pushl  0xc(%ebp)
  8006d4:	ff 75 08             	pushl  0x8(%ebp)
  8006d7:	e8 9a ff ff ff       	call   800676 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    

008006de <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e9:	eb 03                	jmp    8006ee <strlen+0x10>
		n++;
  8006eb:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8006ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006f2:	75 f7                	jne    8006eb <strlen+0xd>
		n++;
	return n;
}
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006fc:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800704:	eb 03                	jmp    800709 <strnlen+0x13>
		n++;
  800706:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800709:	39 c2                	cmp    %eax,%edx
  80070b:	74 08                	je     800715 <strnlen+0x1f>
  80070d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800711:	75 f3                	jne    800706 <strnlen+0x10>
  800713:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	53                   	push   %ebx
  80071b:	8b 45 08             	mov    0x8(%ebp),%eax
  80071e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800721:	89 c2                	mov    %eax,%edx
  800723:	83 c2 01             	add    $0x1,%edx
  800726:	83 c1 01             	add    $0x1,%ecx
  800729:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80072d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800730:	84 db                	test   %bl,%bl
  800732:	75 ef                	jne    800723 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800734:	5b                   	pop    %ebx
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	53                   	push   %ebx
  80073b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80073e:	53                   	push   %ebx
  80073f:	e8 9a ff ff ff       	call   8006de <strlen>
  800744:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800747:	ff 75 0c             	pushl  0xc(%ebp)
  80074a:	01 d8                	add    %ebx,%eax
  80074c:	50                   	push   %eax
  80074d:	e8 c5 ff ff ff       	call   800717 <strcpy>
	return dst;
}
  800752:	89 d8                	mov    %ebx,%eax
  800754:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	56                   	push   %esi
  80075d:	53                   	push   %ebx
  80075e:	8b 75 08             	mov    0x8(%ebp),%esi
  800761:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800764:	89 f3                	mov    %esi,%ebx
  800766:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800769:	89 f2                	mov    %esi,%edx
  80076b:	eb 0f                	jmp    80077c <strncpy+0x23>
		*dst++ = *src;
  80076d:	83 c2 01             	add    $0x1,%edx
  800770:	0f b6 01             	movzbl (%ecx),%eax
  800773:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800776:	80 39 01             	cmpb   $0x1,(%ecx)
  800779:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80077c:	39 da                	cmp    %ebx,%edx
  80077e:	75 ed                	jne    80076d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800780:	89 f0                	mov    %esi,%eax
  800782:	5b                   	pop    %ebx
  800783:	5e                   	pop    %esi
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	56                   	push   %esi
  80078a:	53                   	push   %ebx
  80078b:	8b 75 08             	mov    0x8(%ebp),%esi
  80078e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800791:	8b 55 10             	mov    0x10(%ebp),%edx
  800794:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800796:	85 d2                	test   %edx,%edx
  800798:	74 21                	je     8007bb <strlcpy+0x35>
  80079a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80079e:	89 f2                	mov    %esi,%edx
  8007a0:	eb 09                	jmp    8007ab <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007a2:	83 c2 01             	add    $0x1,%edx
  8007a5:	83 c1 01             	add    $0x1,%ecx
  8007a8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007ab:	39 c2                	cmp    %eax,%edx
  8007ad:	74 09                	je     8007b8 <strlcpy+0x32>
  8007af:	0f b6 19             	movzbl (%ecx),%ebx
  8007b2:	84 db                	test   %bl,%bl
  8007b4:	75 ec                	jne    8007a2 <strlcpy+0x1c>
  8007b6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007b8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007bb:	29 f0                	sub    %esi,%eax
}
  8007bd:	5b                   	pop    %ebx
  8007be:	5e                   	pop    %esi
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    

008007c1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007c1:	55                   	push   %ebp
  8007c2:	89 e5                	mov    %esp,%ebp
  8007c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007ca:	eb 06                	jmp    8007d2 <strcmp+0x11>
		p++, q++;
  8007cc:	83 c1 01             	add    $0x1,%ecx
  8007cf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8007d2:	0f b6 01             	movzbl (%ecx),%eax
  8007d5:	84 c0                	test   %al,%al
  8007d7:	74 04                	je     8007dd <strcmp+0x1c>
  8007d9:	3a 02                	cmp    (%edx),%al
  8007db:	74 ef                	je     8007cc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007dd:	0f b6 c0             	movzbl %al,%eax
  8007e0:	0f b6 12             	movzbl (%edx),%edx
  8007e3:	29 d0                	sub    %edx,%eax
}
  8007e5:	5d                   	pop    %ebp
  8007e6:	c3                   	ret    

008007e7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e7:	55                   	push   %ebp
  8007e8:	89 e5                	mov    %esp,%ebp
  8007ea:	53                   	push   %ebx
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f1:	89 c3                	mov    %eax,%ebx
  8007f3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f6:	eb 06                	jmp    8007fe <strncmp+0x17>
		n--, p++, q++;
  8007f8:	83 c0 01             	add    $0x1,%eax
  8007fb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8007fe:	39 d8                	cmp    %ebx,%eax
  800800:	74 15                	je     800817 <strncmp+0x30>
  800802:	0f b6 08             	movzbl (%eax),%ecx
  800805:	84 c9                	test   %cl,%cl
  800807:	74 04                	je     80080d <strncmp+0x26>
  800809:	3a 0a                	cmp    (%edx),%cl
  80080b:	74 eb                	je     8007f8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080d:	0f b6 00             	movzbl (%eax),%eax
  800810:	0f b6 12             	movzbl (%edx),%edx
  800813:	29 d0                	sub    %edx,%eax
  800815:	eb 05                	jmp    80081c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800817:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80081c:	5b                   	pop    %ebx
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 45 08             	mov    0x8(%ebp),%eax
  800825:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800829:	eb 07                	jmp    800832 <strchr+0x13>
		if (*s == c)
  80082b:	38 ca                	cmp    %cl,%dl
  80082d:	74 0f                	je     80083e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80082f:	83 c0 01             	add    $0x1,%eax
  800832:	0f b6 10             	movzbl (%eax),%edx
  800835:	84 d2                	test   %dl,%dl
  800837:	75 f2                	jne    80082b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800839:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80083e:	5d                   	pop    %ebp
  80083f:	c3                   	ret    

00800840 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800840:	55                   	push   %ebp
  800841:	89 e5                	mov    %esp,%ebp
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80084a:	eb 03                	jmp    80084f <strfind+0xf>
  80084c:	83 c0 01             	add    $0x1,%eax
  80084f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800852:	38 ca                	cmp    %cl,%dl
  800854:	74 04                	je     80085a <strfind+0x1a>
  800856:	84 d2                	test   %dl,%dl
  800858:	75 f2                	jne    80084c <strfind+0xc>
			break;
	return (char *) s;
}
  80085a:	5d                   	pop    %ebp
  80085b:	c3                   	ret    

0080085c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80085c:	55                   	push   %ebp
  80085d:	89 e5                	mov    %esp,%ebp
  80085f:	57                   	push   %edi
  800860:	56                   	push   %esi
  800861:	53                   	push   %ebx
  800862:	8b 7d 08             	mov    0x8(%ebp),%edi
  800865:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800868:	85 c9                	test   %ecx,%ecx
  80086a:	74 36                	je     8008a2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80086c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800872:	75 28                	jne    80089c <memset+0x40>
  800874:	f6 c1 03             	test   $0x3,%cl
  800877:	75 23                	jne    80089c <memset+0x40>
		c &= 0xFF;
  800879:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80087d:	89 d3                	mov    %edx,%ebx
  80087f:	c1 e3 08             	shl    $0x8,%ebx
  800882:	89 d6                	mov    %edx,%esi
  800884:	c1 e6 18             	shl    $0x18,%esi
  800887:	89 d0                	mov    %edx,%eax
  800889:	c1 e0 10             	shl    $0x10,%eax
  80088c:	09 f0                	or     %esi,%eax
  80088e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800890:	89 d8                	mov    %ebx,%eax
  800892:	09 d0                	or     %edx,%eax
  800894:	c1 e9 02             	shr    $0x2,%ecx
  800897:	fc                   	cld    
  800898:	f3 ab                	rep stos %eax,%es:(%edi)
  80089a:	eb 06                	jmp    8008a2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80089c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089f:	fc                   	cld    
  8008a0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008a2:	89 f8                	mov    %edi,%eax
  8008a4:	5b                   	pop    %ebx
  8008a5:	5e                   	pop    %esi
  8008a6:	5f                   	pop    %edi
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	57                   	push   %edi
  8008ad:	56                   	push   %esi
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008b7:	39 c6                	cmp    %eax,%esi
  8008b9:	73 35                	jae    8008f0 <memmove+0x47>
  8008bb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008be:	39 d0                	cmp    %edx,%eax
  8008c0:	73 2e                	jae    8008f0 <memmove+0x47>
		s += n;
		d += n;
  8008c2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008c5:	89 d6                	mov    %edx,%esi
  8008c7:	09 fe                	or     %edi,%esi
  8008c9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008cf:	75 13                	jne    8008e4 <memmove+0x3b>
  8008d1:	f6 c1 03             	test   $0x3,%cl
  8008d4:	75 0e                	jne    8008e4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8008d6:	83 ef 04             	sub    $0x4,%edi
  8008d9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008dc:	c1 e9 02             	shr    $0x2,%ecx
  8008df:	fd                   	std    
  8008e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008e2:	eb 09                	jmp    8008ed <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8008e4:	83 ef 01             	sub    $0x1,%edi
  8008e7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8008ea:	fd                   	std    
  8008eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008ed:	fc                   	cld    
  8008ee:	eb 1d                	jmp    80090d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f0:	89 f2                	mov    %esi,%edx
  8008f2:	09 c2                	or     %eax,%edx
  8008f4:	f6 c2 03             	test   $0x3,%dl
  8008f7:	75 0f                	jne    800908 <memmove+0x5f>
  8008f9:	f6 c1 03             	test   $0x3,%cl
  8008fc:	75 0a                	jne    800908 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8008fe:	c1 e9 02             	shr    $0x2,%ecx
  800901:	89 c7                	mov    %eax,%edi
  800903:	fc                   	cld    
  800904:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800906:	eb 05                	jmp    80090d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800908:	89 c7                	mov    %eax,%edi
  80090a:	fc                   	cld    
  80090b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80090d:	5e                   	pop    %esi
  80090e:	5f                   	pop    %edi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800914:	ff 75 10             	pushl  0x10(%ebp)
  800917:	ff 75 0c             	pushl  0xc(%ebp)
  80091a:	ff 75 08             	pushl  0x8(%ebp)
  80091d:	e8 87 ff ff ff       	call   8008a9 <memmove>
}
  800922:	c9                   	leave  
  800923:	c3                   	ret    

00800924 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092f:	89 c6                	mov    %eax,%esi
  800931:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800934:	eb 1a                	jmp    800950 <memcmp+0x2c>
		if (*s1 != *s2)
  800936:	0f b6 08             	movzbl (%eax),%ecx
  800939:	0f b6 1a             	movzbl (%edx),%ebx
  80093c:	38 d9                	cmp    %bl,%cl
  80093e:	74 0a                	je     80094a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800940:	0f b6 c1             	movzbl %cl,%eax
  800943:	0f b6 db             	movzbl %bl,%ebx
  800946:	29 d8                	sub    %ebx,%eax
  800948:	eb 0f                	jmp    800959 <memcmp+0x35>
		s1++, s2++;
  80094a:	83 c0 01             	add    $0x1,%eax
  80094d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800950:	39 f0                	cmp    %esi,%eax
  800952:	75 e2                	jne    800936 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800954:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800959:	5b                   	pop    %ebx
  80095a:	5e                   	pop    %esi
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	53                   	push   %ebx
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800964:	89 c1                	mov    %eax,%ecx
  800966:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800969:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80096d:	eb 0a                	jmp    800979 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80096f:	0f b6 10             	movzbl (%eax),%edx
  800972:	39 da                	cmp    %ebx,%edx
  800974:	74 07                	je     80097d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800976:	83 c0 01             	add    $0x1,%eax
  800979:	39 c8                	cmp    %ecx,%eax
  80097b:	72 f2                	jb     80096f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80097d:	5b                   	pop    %ebx
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	57                   	push   %edi
  800984:	56                   	push   %esi
  800985:	53                   	push   %ebx
  800986:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800989:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80098c:	eb 03                	jmp    800991 <strtol+0x11>
		s++;
  80098e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800991:	0f b6 01             	movzbl (%ecx),%eax
  800994:	3c 20                	cmp    $0x20,%al
  800996:	74 f6                	je     80098e <strtol+0xe>
  800998:	3c 09                	cmp    $0x9,%al
  80099a:	74 f2                	je     80098e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80099c:	3c 2b                	cmp    $0x2b,%al
  80099e:	75 0a                	jne    8009aa <strtol+0x2a>
		s++;
  8009a0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009a3:	bf 00 00 00 00       	mov    $0x0,%edi
  8009a8:	eb 11                	jmp    8009bb <strtol+0x3b>
  8009aa:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009af:	3c 2d                	cmp    $0x2d,%al
  8009b1:	75 08                	jne    8009bb <strtol+0x3b>
		s++, neg = 1;
  8009b3:	83 c1 01             	add    $0x1,%ecx
  8009b6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c1:	75 15                	jne    8009d8 <strtol+0x58>
  8009c3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c6:	75 10                	jne    8009d8 <strtol+0x58>
  8009c8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009cc:	75 7c                	jne    800a4a <strtol+0xca>
		s += 2, base = 16;
  8009ce:	83 c1 02             	add    $0x2,%ecx
  8009d1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8009d6:	eb 16                	jmp    8009ee <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8009d8:	85 db                	test   %ebx,%ebx
  8009da:	75 12                	jne    8009ee <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009dc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009e1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009e4:	75 08                	jne    8009ee <strtol+0x6e>
		s++, base = 8;
  8009e6:	83 c1 01             	add    $0x1,%ecx
  8009e9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8009f6:	0f b6 11             	movzbl (%ecx),%edx
  8009f9:	8d 72 d0             	lea    -0x30(%edx),%esi
  8009fc:	89 f3                	mov    %esi,%ebx
  8009fe:	80 fb 09             	cmp    $0x9,%bl
  800a01:	77 08                	ja     800a0b <strtol+0x8b>
			dig = *s - '0';
  800a03:	0f be d2             	movsbl %dl,%edx
  800a06:	83 ea 30             	sub    $0x30,%edx
  800a09:	eb 22                	jmp    800a2d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a0b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a0e:	89 f3                	mov    %esi,%ebx
  800a10:	80 fb 19             	cmp    $0x19,%bl
  800a13:	77 08                	ja     800a1d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a15:	0f be d2             	movsbl %dl,%edx
  800a18:	83 ea 57             	sub    $0x57,%edx
  800a1b:	eb 10                	jmp    800a2d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a1d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a20:	89 f3                	mov    %esi,%ebx
  800a22:	80 fb 19             	cmp    $0x19,%bl
  800a25:	77 16                	ja     800a3d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a27:	0f be d2             	movsbl %dl,%edx
  800a2a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a2d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a30:	7d 0b                	jge    800a3d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a32:	83 c1 01             	add    $0x1,%ecx
  800a35:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a39:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a3b:	eb b9                	jmp    8009f6 <strtol+0x76>

	if (endptr)
  800a3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a41:	74 0d                	je     800a50 <strtol+0xd0>
		*endptr = (char *) s;
  800a43:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a46:	89 0e                	mov    %ecx,(%esi)
  800a48:	eb 06                	jmp    800a50 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a4a:	85 db                	test   %ebx,%ebx
  800a4c:	74 98                	je     8009e6 <strtol+0x66>
  800a4e:	eb 9e                	jmp    8009ee <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a50:	89 c2                	mov    %eax,%edx
  800a52:	f7 da                	neg    %edx
  800a54:	85 ff                	test   %edi,%edi
  800a56:	0f 45 c2             	cmovne %edx,%eax
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
  800a69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6f:	89 c3                	mov    %eax,%ebx
  800a71:	89 c7                	mov    %eax,%edi
  800a73:	89 c6                	mov    %eax,%esi
  800a75:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <sys_cgetc>:

int
sys_cgetc(void)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a82:	ba 00 00 00 00       	mov    $0x0,%edx
  800a87:	b8 01 00 00 00       	mov    $0x1,%eax
  800a8c:	89 d1                	mov    %edx,%ecx
  800a8e:	89 d3                	mov    %edx,%ebx
  800a90:	89 d7                	mov    %edx,%edi
  800a92:	89 d6                	mov    %edx,%esi
  800a94:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5f                   	pop    %edi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	57                   	push   %edi
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa9:	b8 03 00 00 00       	mov    $0x3,%eax
  800aae:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab1:	89 cb                	mov    %ecx,%ebx
  800ab3:	89 cf                	mov    %ecx,%edi
  800ab5:	89 ce                	mov    %ecx,%esi
  800ab7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ab9:	85 c0                	test   %eax,%eax
  800abb:	7e 17                	jle    800ad4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800abd:	83 ec 0c             	sub    $0xc,%esp
  800ac0:	50                   	push   %eax
  800ac1:	6a 03                	push   $0x3
  800ac3:	68 14 10 80 00       	push   $0x801014
  800ac8:	6a 23                	push   $0x23
  800aca:	68 31 10 80 00       	push   $0x801031
  800acf:	e8 3c 00 00 00       	call   800b10 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ad4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
  800ae2:	83 ec 14             	sub    $0x14,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aea:	b8 02 00 00 00       	mov    $0x2,%eax
  800aef:	89 d1                	mov    %edx,%ecx
  800af1:	89 d3                	mov    %edx,%ebx
  800af3:	89 d7                	mov    %edx,%edi
  800af5:	89 d6                	mov    %edx,%esi
  800af7:	cd 30                	int    $0x30
  800af9:	89 c3                	mov    %eax,%ebx

envid_t
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	cprintf("lib/syscall.c: %x\n", ret);
  800afb:	50                   	push   %eax
  800afc:	68 3f 10 80 00       	push   $0x80103f
  800b01:	e8 46 f6 ff ff       	call   80014c <cprintf>
	return ret;
}
  800b06:	89 d8                	mov    %ebx,%eax
  800b08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800b15:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800b18:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800b1e:	e8 b9 ff ff ff       	call   800adc <sys_getenvid>
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	ff 75 0c             	pushl  0xc(%ebp)
  800b29:	ff 75 08             	pushl  0x8(%ebp)
  800b2c:	56                   	push   %esi
  800b2d:	50                   	push   %eax
  800b2e:	68 54 10 80 00       	push   $0x801054
  800b33:	e8 14 f6 ff ff       	call   80014c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800b38:	83 c4 18             	add    $0x18,%esp
  800b3b:	53                   	push   %ebx
  800b3c:	ff 75 10             	pushl  0x10(%ebp)
  800b3f:	e8 b7 f5 ff ff       	call   8000fb <vcprintf>
	cprintf("\n");
  800b44:	c7 04 24 f0 0d 80 00 	movl   $0x800df0,(%esp)
  800b4b:	e8 fc f5 ff ff       	call   80014c <cprintf>
  800b50:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800b53:	cc                   	int3   
  800b54:	eb fd                	jmp    800b53 <_panic+0x43>
  800b56:	66 90                	xchg   %ax,%ax
  800b58:	66 90                	xchg   %ax,%ax
  800b5a:	66 90                	xchg   %ax,%ax
  800b5c:	66 90                	xchg   %ax,%ax
  800b5e:	66 90                	xchg   %ax,%ax

00800b60 <__udivdi3>:
  800b60:	55                   	push   %ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	83 ec 1c             	sub    $0x1c,%esp
  800b67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b77:	85 f6                	test   %esi,%esi
  800b79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b7d:	89 ca                	mov    %ecx,%edx
  800b7f:	89 f8                	mov    %edi,%eax
  800b81:	75 3d                	jne    800bc0 <__udivdi3+0x60>
  800b83:	39 cf                	cmp    %ecx,%edi
  800b85:	0f 87 c5 00 00 00    	ja     800c50 <__udivdi3+0xf0>
  800b8b:	85 ff                	test   %edi,%edi
  800b8d:	89 fd                	mov    %edi,%ebp
  800b8f:	75 0b                	jne    800b9c <__udivdi3+0x3c>
  800b91:	b8 01 00 00 00       	mov    $0x1,%eax
  800b96:	31 d2                	xor    %edx,%edx
  800b98:	f7 f7                	div    %edi
  800b9a:	89 c5                	mov    %eax,%ebp
  800b9c:	89 c8                	mov    %ecx,%eax
  800b9e:	31 d2                	xor    %edx,%edx
  800ba0:	f7 f5                	div    %ebp
  800ba2:	89 c1                	mov    %eax,%ecx
  800ba4:	89 d8                	mov    %ebx,%eax
  800ba6:	89 cf                	mov    %ecx,%edi
  800ba8:	f7 f5                	div    %ebp
  800baa:	89 c3                	mov    %eax,%ebx
  800bac:	89 d8                	mov    %ebx,%eax
  800bae:	89 fa                	mov    %edi,%edx
  800bb0:	83 c4 1c             	add    $0x1c,%esp
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    
  800bb8:	90                   	nop
  800bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800bc0:	39 ce                	cmp    %ecx,%esi
  800bc2:	77 74                	ja     800c38 <__udivdi3+0xd8>
  800bc4:	0f bd fe             	bsr    %esi,%edi
  800bc7:	83 f7 1f             	xor    $0x1f,%edi
  800bca:	0f 84 98 00 00 00    	je     800c68 <__udivdi3+0x108>
  800bd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800bd5:	89 f9                	mov    %edi,%ecx
  800bd7:	89 c5                	mov    %eax,%ebp
  800bd9:	29 fb                	sub    %edi,%ebx
  800bdb:	d3 e6                	shl    %cl,%esi
  800bdd:	89 d9                	mov    %ebx,%ecx
  800bdf:	d3 ed                	shr    %cl,%ebp
  800be1:	89 f9                	mov    %edi,%ecx
  800be3:	d3 e0                	shl    %cl,%eax
  800be5:	09 ee                	or     %ebp,%esi
  800be7:	89 d9                	mov    %ebx,%ecx
  800be9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bed:	89 d5                	mov    %edx,%ebp
  800bef:	8b 44 24 08          	mov    0x8(%esp),%eax
  800bf3:	d3 ed                	shr    %cl,%ebp
  800bf5:	89 f9                	mov    %edi,%ecx
  800bf7:	d3 e2                	shl    %cl,%edx
  800bf9:	89 d9                	mov    %ebx,%ecx
  800bfb:	d3 e8                	shr    %cl,%eax
  800bfd:	09 c2                	or     %eax,%edx
  800bff:	89 d0                	mov    %edx,%eax
  800c01:	89 ea                	mov    %ebp,%edx
  800c03:	f7 f6                	div    %esi
  800c05:	89 d5                	mov    %edx,%ebp
  800c07:	89 c3                	mov    %eax,%ebx
  800c09:	f7 64 24 0c          	mull   0xc(%esp)
  800c0d:	39 d5                	cmp    %edx,%ebp
  800c0f:	72 10                	jb     800c21 <__udivdi3+0xc1>
  800c11:	8b 74 24 08          	mov    0x8(%esp),%esi
  800c15:	89 f9                	mov    %edi,%ecx
  800c17:	d3 e6                	shl    %cl,%esi
  800c19:	39 c6                	cmp    %eax,%esi
  800c1b:	73 07                	jae    800c24 <__udivdi3+0xc4>
  800c1d:	39 d5                	cmp    %edx,%ebp
  800c1f:	75 03                	jne    800c24 <__udivdi3+0xc4>
  800c21:	83 eb 01             	sub    $0x1,%ebx
  800c24:	31 ff                	xor    %edi,%edi
  800c26:	89 d8                	mov    %ebx,%eax
  800c28:	89 fa                	mov    %edi,%edx
  800c2a:	83 c4 1c             	add    $0x1c,%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    
  800c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c38:	31 ff                	xor    %edi,%edi
  800c3a:	31 db                	xor    %ebx,%ebx
  800c3c:	89 d8                	mov    %ebx,%eax
  800c3e:	89 fa                	mov    %edi,%edx
  800c40:	83 c4 1c             	add    $0x1c,%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5f                   	pop    %edi
  800c46:	5d                   	pop    %ebp
  800c47:	c3                   	ret    
  800c48:	90                   	nop
  800c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c50:	89 d8                	mov    %ebx,%eax
  800c52:	f7 f7                	div    %edi
  800c54:	31 ff                	xor    %edi,%edi
  800c56:	89 c3                	mov    %eax,%ebx
  800c58:	89 d8                	mov    %ebx,%eax
  800c5a:	89 fa                	mov    %edi,%edx
  800c5c:	83 c4 1c             	add    $0x1c,%esp
  800c5f:	5b                   	pop    %ebx
  800c60:	5e                   	pop    %esi
  800c61:	5f                   	pop    %edi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    
  800c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c68:	39 ce                	cmp    %ecx,%esi
  800c6a:	72 0c                	jb     800c78 <__udivdi3+0x118>
  800c6c:	31 db                	xor    %ebx,%ebx
  800c6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c72:	0f 87 34 ff ff ff    	ja     800bac <__udivdi3+0x4c>
  800c78:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c7d:	e9 2a ff ff ff       	jmp    800bac <__udivdi3+0x4c>
  800c82:	66 90                	xchg   %ax,%ax
  800c84:	66 90                	xchg   %ax,%ax
  800c86:	66 90                	xchg   %ax,%ax
  800c88:	66 90                	xchg   %ax,%ax
  800c8a:	66 90                	xchg   %ax,%ax
  800c8c:	66 90                	xchg   %ax,%ax
  800c8e:	66 90                	xchg   %ax,%ax

00800c90 <__umoddi3>:
  800c90:	55                   	push   %ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 1c             	sub    $0x1c,%esp
  800c97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ca7:	85 d2                	test   %edx,%edx
  800ca9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cb1:	89 f3                	mov    %esi,%ebx
  800cb3:	89 3c 24             	mov    %edi,(%esp)
  800cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cba:	75 1c                	jne    800cd8 <__umoddi3+0x48>
  800cbc:	39 f7                	cmp    %esi,%edi
  800cbe:	76 50                	jbe    800d10 <__umoddi3+0x80>
  800cc0:	89 c8                	mov    %ecx,%eax
  800cc2:	89 f2                	mov    %esi,%edx
  800cc4:	f7 f7                	div    %edi
  800cc6:	89 d0                	mov    %edx,%eax
  800cc8:	31 d2                	xor    %edx,%edx
  800cca:	83 c4 1c             	add    $0x1c,%esp
  800ccd:	5b                   	pop    %ebx
  800cce:	5e                   	pop    %esi
  800ccf:	5f                   	pop    %edi
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    
  800cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cd8:	39 f2                	cmp    %esi,%edx
  800cda:	89 d0                	mov    %edx,%eax
  800cdc:	77 52                	ja     800d30 <__umoddi3+0xa0>
  800cde:	0f bd ea             	bsr    %edx,%ebp
  800ce1:	83 f5 1f             	xor    $0x1f,%ebp
  800ce4:	75 5a                	jne    800d40 <__umoddi3+0xb0>
  800ce6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800cea:	0f 82 e0 00 00 00    	jb     800dd0 <__umoddi3+0x140>
  800cf0:	39 0c 24             	cmp    %ecx,(%esp)
  800cf3:	0f 86 d7 00 00 00    	jbe    800dd0 <__umoddi3+0x140>
  800cf9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800cfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d01:	83 c4 1c             	add    $0x1c,%esp
  800d04:	5b                   	pop    %ebx
  800d05:	5e                   	pop    %esi
  800d06:	5f                   	pop    %edi
  800d07:	5d                   	pop    %ebp
  800d08:	c3                   	ret    
  800d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d10:	85 ff                	test   %edi,%edi
  800d12:	89 fd                	mov    %edi,%ebp
  800d14:	75 0b                	jne    800d21 <__umoddi3+0x91>
  800d16:	b8 01 00 00 00       	mov    $0x1,%eax
  800d1b:	31 d2                	xor    %edx,%edx
  800d1d:	f7 f7                	div    %edi
  800d1f:	89 c5                	mov    %eax,%ebp
  800d21:	89 f0                	mov    %esi,%eax
  800d23:	31 d2                	xor    %edx,%edx
  800d25:	f7 f5                	div    %ebp
  800d27:	89 c8                	mov    %ecx,%eax
  800d29:	f7 f5                	div    %ebp
  800d2b:	89 d0                	mov    %edx,%eax
  800d2d:	eb 99                	jmp    800cc8 <__umoddi3+0x38>
  800d2f:	90                   	nop
  800d30:	89 c8                	mov    %ecx,%eax
  800d32:	89 f2                	mov    %esi,%edx
  800d34:	83 c4 1c             	add    $0x1c,%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    
  800d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d40:	8b 34 24             	mov    (%esp),%esi
  800d43:	bf 20 00 00 00       	mov    $0x20,%edi
  800d48:	89 e9                	mov    %ebp,%ecx
  800d4a:	29 ef                	sub    %ebp,%edi
  800d4c:	d3 e0                	shl    %cl,%eax
  800d4e:	89 f9                	mov    %edi,%ecx
  800d50:	89 f2                	mov    %esi,%edx
  800d52:	d3 ea                	shr    %cl,%edx
  800d54:	89 e9                	mov    %ebp,%ecx
  800d56:	09 c2                	or     %eax,%edx
  800d58:	89 d8                	mov    %ebx,%eax
  800d5a:	89 14 24             	mov    %edx,(%esp)
  800d5d:	89 f2                	mov    %esi,%edx
  800d5f:	d3 e2                	shl    %cl,%edx
  800d61:	89 f9                	mov    %edi,%ecx
  800d63:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d6b:	d3 e8                	shr    %cl,%eax
  800d6d:	89 e9                	mov    %ebp,%ecx
  800d6f:	89 c6                	mov    %eax,%esi
  800d71:	d3 e3                	shl    %cl,%ebx
  800d73:	89 f9                	mov    %edi,%ecx
  800d75:	89 d0                	mov    %edx,%eax
  800d77:	d3 e8                	shr    %cl,%eax
  800d79:	89 e9                	mov    %ebp,%ecx
  800d7b:	09 d8                	or     %ebx,%eax
  800d7d:	89 d3                	mov    %edx,%ebx
  800d7f:	89 f2                	mov    %esi,%edx
  800d81:	f7 34 24             	divl   (%esp)
  800d84:	89 d6                	mov    %edx,%esi
  800d86:	d3 e3                	shl    %cl,%ebx
  800d88:	f7 64 24 04          	mull   0x4(%esp)
  800d8c:	39 d6                	cmp    %edx,%esi
  800d8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d92:	89 d1                	mov    %edx,%ecx
  800d94:	89 c3                	mov    %eax,%ebx
  800d96:	72 08                	jb     800da0 <__umoddi3+0x110>
  800d98:	75 11                	jne    800dab <__umoddi3+0x11b>
  800d9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d9e:	73 0b                	jae    800dab <__umoddi3+0x11b>
  800da0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800da4:	1b 14 24             	sbb    (%esp),%edx
  800da7:	89 d1                	mov    %edx,%ecx
  800da9:	89 c3                	mov    %eax,%ebx
  800dab:	8b 54 24 08          	mov    0x8(%esp),%edx
  800daf:	29 da                	sub    %ebx,%edx
  800db1:	19 ce                	sbb    %ecx,%esi
  800db3:	89 f9                	mov    %edi,%ecx
  800db5:	89 f0                	mov    %esi,%eax
  800db7:	d3 e0                	shl    %cl,%eax
  800db9:	89 e9                	mov    %ebp,%ecx
  800dbb:	d3 ea                	shr    %cl,%edx
  800dbd:	89 e9                	mov    %ebp,%ecx
  800dbf:	d3 ee                	shr    %cl,%esi
  800dc1:	09 d0                	or     %edx,%eax
  800dc3:	89 f2                	mov    %esi,%edx
  800dc5:	83 c4 1c             	add    $0x1c,%esp
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    
  800dcd:	8d 76 00             	lea    0x0(%esi),%esi
  800dd0:	29 f9                	sub    %edi,%ecx
  800dd2:	19 d6                	sbb    %edx,%esi
  800dd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ddc:	e9 18 ff ff ff       	jmp    800cf9 <__umoddi3+0x69>
