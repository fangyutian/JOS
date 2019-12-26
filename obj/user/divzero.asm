
obj/user/divzero:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 20 10 80 00       	push   $0x801020
  800056:	e8 38 01 00 00       	call   800193 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	57                   	push   %edi
  800064:	56                   	push   %esi
  800065:	53                   	push   %ebx
  800066:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800069:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800070:	00 00 00 
	envid_t eid = sys_getenvid();
  800073:	e8 e4 0a 00 00       	call   800b5c <sys_getenvid>
  800078:	8b 3d 08 20 80 00    	mov    0x802008,%edi
  80007e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800083:	be 00 00 00 00       	mov    $0x0,%esi
	int i;
	for (i = 0; i < NENV; i++) {
  800088:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == eid) {
  80008d:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800090:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800096:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &(envs[i]);
  800099:	39 c8                	cmp    %ecx,%eax
  80009b:	0f 44 fb             	cmove  %ebx,%edi
  80009e:	b9 01 00 00 00       	mov    $0x1,%ecx
  8000a3:	0f 44 f1             	cmove  %ecx,%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
	envid_t eid = sys_getenvid();
	int i;
	for (i = 0; i < NENV; i++) {
  8000a6:	83 c2 01             	add    $0x1,%edx
  8000a9:	83 c3 7c             	add    $0x7c,%ebx
  8000ac:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8000b2:	75 d9                	jne    80008d <libmain+0x2d>
  8000b4:	89 f0                	mov    %esi,%eax
  8000b6:	84 c0                	test   %al,%al
  8000b8:	74 06                	je     8000c0 <libmain+0x60>
  8000ba:	89 3d 08 20 80 00    	mov    %edi,0x802008
			thisenv = &(envs[i]);
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000c4:	7e 0a                	jle    8000d0 <libmain+0x70>
		binaryname = argv[0];
  8000c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000c9:	8b 00                	mov    (%eax),%eax
  8000cb:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d0:	83 ec 08             	sub    $0x8,%esp
  8000d3:	ff 75 0c             	pushl  0xc(%ebp)
  8000d6:	ff 75 08             	pushl  0x8(%ebp)
  8000d9:	e8 55 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000de:	e8 0b 00 00 00       	call   8000ee <exit>
}
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5f                   	pop    %edi
  8000ec:	5d                   	pop    %ebp
  8000ed:	c3                   	ret    

008000ee <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f4:	6a 00                	push   $0x0
  8000f6:	e8 20 0a 00 00       	call   800b1b <sys_env_destroy>
}
  8000fb:	83 c4 10             	add    $0x10,%esp
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	53                   	push   %ebx
  800104:	83 ec 04             	sub    $0x4,%esp
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010a:	8b 13                	mov    (%ebx),%edx
  80010c:	8d 42 01             	lea    0x1(%edx),%eax
  80010f:	89 03                	mov    %eax,(%ebx)
  800111:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800114:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800118:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011d:	75 1a                	jne    800139 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80011f:	83 ec 08             	sub    $0x8,%esp
  800122:	68 ff 00 00 00       	push   $0xff
  800127:	8d 43 08             	lea    0x8(%ebx),%eax
  80012a:	50                   	push   %eax
  80012b:	e8 ae 09 00 00       	call   800ade <sys_cputs>
		b->idx = 0;
  800130:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800136:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800139:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800140:	c9                   	leave  
  800141:	c3                   	ret    

00800142 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800152:	00 00 00 
	b.cnt = 0;
  800155:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015f:	ff 75 0c             	pushl  0xc(%ebp)
  800162:	ff 75 08             	pushl  0x8(%ebp)
  800165:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016b:	50                   	push   %eax
  80016c:	68 00 01 80 00       	push   $0x800100
  800171:	e8 1a 01 00 00       	call   800290 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800176:	83 c4 08             	add    $0x8,%esp
  800179:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800185:	50                   	push   %eax
  800186:	e8 53 09 00 00       	call   800ade <sys_cputs>

	return b.cnt;
}
  80018b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800199:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019c:	50                   	push   %eax
  80019d:	ff 75 08             	pushl  0x8(%ebp)
  8001a0:	e8 9d ff ff ff       	call   800142 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	57                   	push   %edi
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
  8001ad:	83 ec 1c             	sub    $0x1c,%esp
  8001b0:	89 c7                	mov    %eax,%edi
  8001b2:	89 d6                	mov    %edx,%esi
  8001b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cb:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ce:	39 d3                	cmp    %edx,%ebx
  8001d0:	72 05                	jb     8001d7 <printnum+0x30>
  8001d2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d5:	77 45                	ja     80021c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	ff 75 18             	pushl  0x18(%ebp)
  8001dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e3:	53                   	push   %ebx
  8001e4:	ff 75 10             	pushl  0x10(%ebp)
  8001e7:	83 ec 08             	sub    $0x8,%esp
  8001ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f6:	e8 95 0b 00 00       	call   800d90 <__udivdi3>
  8001fb:	83 c4 18             	add    $0x18,%esp
  8001fe:	52                   	push   %edx
  8001ff:	50                   	push   %eax
  800200:	89 f2                	mov    %esi,%edx
  800202:	89 f8                	mov    %edi,%eax
  800204:	e8 9e ff ff ff       	call   8001a7 <printnum>
  800209:	83 c4 20             	add    $0x20,%esp
  80020c:	eb 18                	jmp    800226 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020e:	83 ec 08             	sub    $0x8,%esp
  800211:	56                   	push   %esi
  800212:	ff 75 18             	pushl  0x18(%ebp)
  800215:	ff d7                	call   *%edi
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb 03                	jmp    80021f <printnum+0x78>
  80021c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80021f:	83 eb 01             	sub    $0x1,%ebx
  800222:	85 db                	test   %ebx,%ebx
  800224:	7f e8                	jg     80020e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800226:	83 ec 08             	sub    $0x8,%esp
  800229:	56                   	push   %esi
  80022a:	83 ec 04             	sub    $0x4,%esp
  80022d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800230:	ff 75 e0             	pushl  -0x20(%ebp)
  800233:	ff 75 dc             	pushl  -0x24(%ebp)
  800236:	ff 75 d8             	pushl  -0x28(%ebp)
  800239:	e8 82 0c 00 00       	call   800ec0 <__umoddi3>
  80023e:	83 c4 14             	add    $0x14,%esp
  800241:	0f be 80 38 10 80 00 	movsbl 0x801038(%eax),%eax
  800248:	50                   	push   %eax
  800249:	ff d7                	call   *%edi
}
  80024b:	83 c4 10             	add    $0x10,%esp
  80024e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800251:	5b                   	pop    %ebx
  800252:	5e                   	pop    %esi
  800253:	5f                   	pop    %edi
  800254:	5d                   	pop    %ebp
  800255:	c3                   	ret    

00800256 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800260:	8b 10                	mov    (%eax),%edx
  800262:	3b 50 04             	cmp    0x4(%eax),%edx
  800265:	73 0a                	jae    800271 <sprintputch+0x1b>
		*b->buf++ = ch;
  800267:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026a:	89 08                	mov    %ecx,(%eax)
  80026c:	8b 45 08             	mov    0x8(%ebp),%eax
  80026f:	88 02                	mov    %al,(%edx)
}
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800279:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027c:	50                   	push   %eax
  80027d:	ff 75 10             	pushl  0x10(%ebp)
  800280:	ff 75 0c             	pushl  0xc(%ebp)
  800283:	ff 75 08             	pushl  0x8(%ebp)
  800286:	e8 05 00 00 00       	call   800290 <vprintfmt>
	va_end(ap);
}
  80028b:	83 c4 10             	add    $0x10,%esp
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	57                   	push   %edi
  800294:	56                   	push   %esi
  800295:	53                   	push   %ebx
  800296:	83 ec 2c             	sub    $0x2c,%esp
  800299:	8b 75 08             	mov    0x8(%ebp),%esi
  80029c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80029f:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a2:	eb 12                	jmp    8002b6 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a4:	85 c0                	test   %eax,%eax
  8002a6:	0f 84 42 04 00 00    	je     8006ee <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	53                   	push   %ebx
  8002b0:	50                   	push   %eax
  8002b1:	ff d6                	call   *%esi
  8002b3:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b6:	83 c7 01             	add    $0x1,%edi
  8002b9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002bd:	83 f8 25             	cmp    $0x25,%eax
  8002c0:	75 e2                	jne    8002a4 <vprintfmt+0x14>
  8002c2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002cd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002d4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e0:	eb 07                	jmp    8002e9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e9:	8d 47 01             	lea    0x1(%edi),%eax
  8002ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ef:	0f b6 07             	movzbl (%edi),%eax
  8002f2:	0f b6 d0             	movzbl %al,%edx
  8002f5:	83 e8 23             	sub    $0x23,%eax
  8002f8:	3c 55                	cmp    $0x55,%al
  8002fa:	0f 87 d3 03 00 00    	ja     8006d3 <vprintfmt+0x443>
  800300:	0f b6 c0             	movzbl %al,%eax
  800303:	ff 24 85 00 11 80 00 	jmp    *0x801100(,%eax,4)
  80030a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800311:	eb d6                	jmp    8002e9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800316:	b8 00 00 00 00       	mov    $0x0,%eax
  80031b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800321:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800325:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800328:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032b:	83 f9 09             	cmp    $0x9,%ecx
  80032e:	77 3f                	ja     80036f <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800330:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800333:	eb e9                	jmp    80031e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800335:	8b 45 14             	mov    0x14(%ebp),%eax
  800338:	8b 00                	mov    (%eax),%eax
  80033a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80033d:	8b 45 14             	mov    0x14(%ebp),%eax
  800340:	8d 40 04             	lea    0x4(%eax),%eax
  800343:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800349:	eb 2a                	jmp    800375 <vprintfmt+0xe5>
  80034b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034e:	85 c0                	test   %eax,%eax
  800350:	ba 00 00 00 00       	mov    $0x0,%edx
  800355:	0f 49 d0             	cmovns %eax,%edx
  800358:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035e:	eb 89                	jmp    8002e9 <vprintfmt+0x59>
  800360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800363:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80036a:	e9 7a ff ff ff       	jmp    8002e9 <vprintfmt+0x59>
  80036f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800372:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800375:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800379:	0f 89 6a ff ff ff    	jns    8002e9 <vprintfmt+0x59>
				width = precision, precision = -1;
  80037f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800382:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800385:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038c:	e9 58 ff ff ff       	jmp    8002e9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800391:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800397:	e9 4d ff ff ff       	jmp    8002e9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80039c:	8b 45 14             	mov    0x14(%ebp),%eax
  80039f:	8d 78 04             	lea    0x4(%eax),%edi
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	53                   	push   %ebx
  8003a6:	ff 30                	pushl  (%eax)
  8003a8:	ff d6                	call   *%esi
			break;
  8003aa:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ad:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b3:	e9 fe fe ff ff       	jmp    8002b6 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bb:	8d 78 04             	lea    0x4(%eax),%edi
  8003be:	8b 00                	mov    (%eax),%eax
  8003c0:	99                   	cltd   
  8003c1:	31 d0                	xor    %edx,%eax
  8003c3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c5:	83 f8 08             	cmp    $0x8,%eax
  8003c8:	7f 0b                	jg     8003d5 <vprintfmt+0x145>
  8003ca:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  8003d1:	85 d2                	test   %edx,%edx
  8003d3:	75 1b                	jne    8003f0 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003d5:	50                   	push   %eax
  8003d6:	68 50 10 80 00       	push   $0x801050
  8003db:	53                   	push   %ebx
  8003dc:	56                   	push   %esi
  8003dd:	e8 91 fe ff ff       	call   800273 <printfmt>
  8003e2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e5:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003eb:	e9 c6 fe ff ff       	jmp    8002b6 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f0:	52                   	push   %edx
  8003f1:	68 59 10 80 00       	push   $0x801059
  8003f6:	53                   	push   %ebx
  8003f7:	56                   	push   %esi
  8003f8:	e8 76 fe ff ff       	call   800273 <printfmt>
  8003fd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800400:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800406:	e9 ab fe ff ff       	jmp    8002b6 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	83 c0 04             	add    $0x4,%eax
  800411:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800419:	85 ff                	test   %edi,%edi
  80041b:	b8 49 10 80 00       	mov    $0x801049,%eax
  800420:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800423:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800427:	0f 8e 94 00 00 00    	jle    8004c1 <vprintfmt+0x231>
  80042d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800431:	0f 84 98 00 00 00    	je     8004cf <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800437:	83 ec 08             	sub    $0x8,%esp
  80043a:	ff 75 d0             	pushl  -0x30(%ebp)
  80043d:	57                   	push   %edi
  80043e:	e8 33 03 00 00       	call   800776 <strnlen>
  800443:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800446:	29 c1                	sub    %eax,%ecx
  800448:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80044b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80044e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800452:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800455:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800458:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045a:	eb 0f                	jmp    80046b <vprintfmt+0x1db>
					putch(padc, putdat);
  80045c:	83 ec 08             	sub    $0x8,%esp
  80045f:	53                   	push   %ebx
  800460:	ff 75 e0             	pushl  -0x20(%ebp)
  800463:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800465:	83 ef 01             	sub    $0x1,%edi
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	85 ff                	test   %edi,%edi
  80046d:	7f ed                	jg     80045c <vprintfmt+0x1cc>
  80046f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800472:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800475:	85 c9                	test   %ecx,%ecx
  800477:	b8 00 00 00 00       	mov    $0x0,%eax
  80047c:	0f 49 c1             	cmovns %ecx,%eax
  80047f:	29 c1                	sub    %eax,%ecx
  800481:	89 75 08             	mov    %esi,0x8(%ebp)
  800484:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800487:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048a:	89 cb                	mov    %ecx,%ebx
  80048c:	eb 4d                	jmp    8004db <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800492:	74 1b                	je     8004af <vprintfmt+0x21f>
  800494:	0f be c0             	movsbl %al,%eax
  800497:	83 e8 20             	sub    $0x20,%eax
  80049a:	83 f8 5e             	cmp    $0x5e,%eax
  80049d:	76 10                	jbe    8004af <vprintfmt+0x21f>
					putch('?', putdat);
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	ff 75 0c             	pushl  0xc(%ebp)
  8004a5:	6a 3f                	push   $0x3f
  8004a7:	ff 55 08             	call   *0x8(%ebp)
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	eb 0d                	jmp    8004bc <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	ff 75 0c             	pushl  0xc(%ebp)
  8004b5:	52                   	push   %edx
  8004b6:	ff 55 08             	call   *0x8(%ebp)
  8004b9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bc:	83 eb 01             	sub    $0x1,%ebx
  8004bf:	eb 1a                	jmp    8004db <vprintfmt+0x24b>
  8004c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004cd:	eb 0c                	jmp    8004db <vprintfmt+0x24b>
  8004cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004db:	83 c7 01             	add    $0x1,%edi
  8004de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e2:	0f be d0             	movsbl %al,%edx
  8004e5:	85 d2                	test   %edx,%edx
  8004e7:	74 23                	je     80050c <vprintfmt+0x27c>
  8004e9:	85 f6                	test   %esi,%esi
  8004eb:	78 a1                	js     80048e <vprintfmt+0x1fe>
  8004ed:	83 ee 01             	sub    $0x1,%esi
  8004f0:	79 9c                	jns    80048e <vprintfmt+0x1fe>
  8004f2:	89 df                	mov    %ebx,%edi
  8004f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fa:	eb 18                	jmp    800514 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	53                   	push   %ebx
  800500:	6a 20                	push   $0x20
  800502:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800504:	83 ef 01             	sub    $0x1,%edi
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	eb 08                	jmp    800514 <vprintfmt+0x284>
  80050c:	89 df                	mov    %ebx,%edi
  80050e:	8b 75 08             	mov    0x8(%ebp),%esi
  800511:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800514:	85 ff                	test   %edi,%edi
  800516:	7f e4                	jg     8004fc <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800518:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80051b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800521:	e9 90 fd ff ff       	jmp    8002b6 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800526:	83 f9 01             	cmp    $0x1,%ecx
  800529:	7e 19                	jle    800544 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8b 50 04             	mov    0x4(%eax),%edx
  800531:	8b 00                	mov    (%eax),%eax
  800533:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800536:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 40 08             	lea    0x8(%eax),%eax
  80053f:	89 45 14             	mov    %eax,0x14(%ebp)
  800542:	eb 38                	jmp    80057c <vprintfmt+0x2ec>
	else if (lflag)
  800544:	85 c9                	test   %ecx,%ecx
  800546:	74 1b                	je     800563 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800548:	8b 45 14             	mov    0x14(%ebp),%eax
  80054b:	8b 00                	mov    (%eax),%eax
  80054d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800550:	89 c1                	mov    %eax,%ecx
  800552:	c1 f9 1f             	sar    $0x1f,%ecx
  800555:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800558:	8b 45 14             	mov    0x14(%ebp),%eax
  80055b:	8d 40 04             	lea    0x4(%eax),%eax
  80055e:	89 45 14             	mov    %eax,0x14(%ebp)
  800561:	eb 19                	jmp    80057c <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056b:	89 c1                	mov    %eax,%ecx
  80056d:	c1 f9 1f             	sar    $0x1f,%ecx
  800570:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8d 40 04             	lea    0x4(%eax),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800582:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800587:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058b:	0f 89 0e 01 00 00    	jns    80069f <vprintfmt+0x40f>
				putch('-', putdat);
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	53                   	push   %ebx
  800595:	6a 2d                	push   $0x2d
  800597:	ff d6                	call   *%esi
				num = -(long long) num;
  800599:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80059f:	f7 da                	neg    %edx
  8005a1:	83 d1 00             	adc    $0x0,%ecx
  8005a4:	f7 d9                	neg    %ecx
  8005a6:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005a9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ae:	e9 ec 00 00 00       	jmp    80069f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b3:	83 f9 01             	cmp    $0x1,%ecx
  8005b6:	7e 18                	jle    8005d0 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 10                	mov    (%eax),%edx
  8005bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c0:	8d 40 08             	lea    0x8(%eax),%eax
  8005c3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cb:	e9 cf 00 00 00       	jmp    80069f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005d0:	85 c9                	test   %ecx,%ecx
  8005d2:	74 1a                	je     8005ee <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8b 10                	mov    (%eax),%edx
  8005d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005de:	8d 40 04             	lea    0x4(%eax),%eax
  8005e1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e9:	e9 b1 00 00 00       	jmp    80069f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8b 10                	mov    (%eax),%edx
  8005f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005fe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800603:	e9 97 00 00 00       	jmp    80069f <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	6a 58                	push   $0x58
  80060e:	ff d6                	call   *%esi
			putch('X', putdat);
  800610:	83 c4 08             	add    $0x8,%esp
  800613:	53                   	push   %ebx
  800614:	6a 58                	push   $0x58
  800616:	ff d6                	call   *%esi
			putch('X', putdat);
  800618:	83 c4 08             	add    $0x8,%esp
  80061b:	53                   	push   %ebx
  80061c:	6a 58                	push   $0x58
  80061e:	ff d6                	call   *%esi
			break;
  800620:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800623:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800626:	e9 8b fc ff ff       	jmp    8002b6 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	53                   	push   %ebx
  80062f:	6a 30                	push   $0x30
  800631:	ff d6                	call   *%esi
			putch('x', putdat);
  800633:	83 c4 08             	add    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	6a 78                	push   $0x78
  800639:	ff d6                	call   *%esi
			num = (unsigned long long)
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800645:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800648:	8d 40 04             	lea    0x4(%eax),%eax
  80064b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800653:	eb 4a                	jmp    80069f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800655:	83 f9 01             	cmp    $0x1,%ecx
  800658:	7e 15                	jle    80066f <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80065a:	8b 45 14             	mov    0x14(%ebp),%eax
  80065d:	8b 10                	mov    (%eax),%edx
  80065f:	8b 48 04             	mov    0x4(%eax),%ecx
  800662:	8d 40 08             	lea    0x8(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800668:	b8 10 00 00 00       	mov    $0x10,%eax
  80066d:	eb 30                	jmp    80069f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80066f:	85 c9                	test   %ecx,%ecx
  800671:	74 17                	je     80068a <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800673:	8b 45 14             	mov    0x14(%ebp),%eax
  800676:	8b 10                	mov    (%eax),%edx
  800678:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067d:	8d 40 04             	lea    0x4(%eax),%eax
  800680:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800683:	b8 10 00 00 00       	mov    $0x10,%eax
  800688:	eb 15                	jmp    80069f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8b 10                	mov    (%eax),%edx
  80068f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800694:	8d 40 04             	lea    0x4(%eax),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80069a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80069f:	83 ec 0c             	sub    $0xc,%esp
  8006a2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a6:	57                   	push   %edi
  8006a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006aa:	50                   	push   %eax
  8006ab:	51                   	push   %ecx
  8006ac:	52                   	push   %edx
  8006ad:	89 da                	mov    %ebx,%edx
  8006af:	89 f0                	mov    %esi,%eax
  8006b1:	e8 f1 fa ff ff       	call   8001a7 <printnum>
			break;
  8006b6:	83 c4 20             	add    $0x20,%esp
  8006b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bc:	e9 f5 fb ff ff       	jmp    8002b6 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	52                   	push   %edx
  8006c6:	ff d6                	call   *%esi
			break;
  8006c8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ce:	e9 e3 fb ff ff       	jmp    8002b6 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	6a 25                	push   $0x25
  8006d9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006db:	83 c4 10             	add    $0x10,%esp
  8006de:	eb 03                	jmp    8006e3 <vprintfmt+0x453>
  8006e0:	83 ef 01             	sub    $0x1,%edi
  8006e3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e7:	75 f7                	jne    8006e0 <vprintfmt+0x450>
  8006e9:	e9 c8 fb ff ff       	jmp    8002b6 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f1:	5b                   	pop    %ebx
  8006f2:	5e                   	pop    %esi
  8006f3:	5f                   	pop    %edi
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	83 ec 18             	sub    $0x18,%esp
  8006fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800702:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800705:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800709:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800713:	85 c0                	test   %eax,%eax
  800715:	74 26                	je     80073d <vsnprintf+0x47>
  800717:	85 d2                	test   %edx,%edx
  800719:	7e 22                	jle    80073d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071b:	ff 75 14             	pushl  0x14(%ebp)
  80071e:	ff 75 10             	pushl  0x10(%ebp)
  800721:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	68 56 02 80 00       	push   $0x800256
  80072a:	e8 61 fb ff ff       	call   800290 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800732:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	eb 05                	jmp    800742 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800742:	c9                   	leave  
  800743:	c3                   	ret    

00800744 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074d:	50                   	push   %eax
  80074e:	ff 75 10             	pushl  0x10(%ebp)
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	ff 75 08             	pushl  0x8(%ebp)
  800757:	e8 9a ff ff ff       	call   8006f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075c:	c9                   	leave  
  80075d:	c3                   	ret    

0080075e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800764:	b8 00 00 00 00       	mov    $0x0,%eax
  800769:	eb 03                	jmp    80076e <strlen+0x10>
		n++;
  80076b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800772:	75 f7                	jne    80076b <strlen+0xd>
		n++;
	return n;
}
  800774:	5d                   	pop    %ebp
  800775:	c3                   	ret    

00800776 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80077f:	ba 00 00 00 00       	mov    $0x0,%edx
  800784:	eb 03                	jmp    800789 <strnlen+0x13>
		n++;
  800786:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800789:	39 c2                	cmp    %eax,%edx
  80078b:	74 08                	je     800795 <strnlen+0x1f>
  80078d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800791:	75 f3                	jne    800786 <strnlen+0x10>
  800793:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	83 c2 01             	add    $0x1,%edx
  8007a6:	83 c1 01             	add    $0x1,%ecx
  8007a9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ad:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b0:	84 db                	test   %bl,%bl
  8007b2:	75 ef                	jne    8007a3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b4:	5b                   	pop    %ebx
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	53                   	push   %ebx
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007be:	53                   	push   %ebx
  8007bf:	e8 9a ff ff ff       	call   80075e <strlen>
  8007c4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ca:	01 d8                	add    %ebx,%eax
  8007cc:	50                   	push   %eax
  8007cd:	e8 c5 ff ff ff       	call   800797 <strcpy>
	return dst;
}
  8007d2:	89 d8                	mov    %ebx,%eax
  8007d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	56                   	push   %esi
  8007dd:	53                   	push   %ebx
  8007de:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e4:	89 f3                	mov    %esi,%ebx
  8007e6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007e9:	89 f2                	mov    %esi,%edx
  8007eb:	eb 0f                	jmp    8007fc <strncpy+0x23>
		*dst++ = *src;
  8007ed:	83 c2 01             	add    $0x1,%edx
  8007f0:	0f b6 01             	movzbl (%ecx),%eax
  8007f3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007f9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fc:	39 da                	cmp    %ebx,%edx
  8007fe:	75 ed                	jne    8007ed <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800800:	89 f0                	mov    %esi,%eax
  800802:	5b                   	pop    %ebx
  800803:	5e                   	pop    %esi
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    

00800806 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	56                   	push   %esi
  80080a:	53                   	push   %ebx
  80080b:	8b 75 08             	mov    0x8(%ebp),%esi
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800811:	8b 55 10             	mov    0x10(%ebp),%edx
  800814:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800816:	85 d2                	test   %edx,%edx
  800818:	74 21                	je     80083b <strlcpy+0x35>
  80081a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081e:	89 f2                	mov    %esi,%edx
  800820:	eb 09                	jmp    80082b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800822:	83 c2 01             	add    $0x1,%edx
  800825:	83 c1 01             	add    $0x1,%ecx
  800828:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082b:	39 c2                	cmp    %eax,%edx
  80082d:	74 09                	je     800838 <strlcpy+0x32>
  80082f:	0f b6 19             	movzbl (%ecx),%ebx
  800832:	84 db                	test   %bl,%bl
  800834:	75 ec                	jne    800822 <strlcpy+0x1c>
  800836:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800838:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083b:	29 f0                	sub    %esi,%eax
}
  80083d:	5b                   	pop    %ebx
  80083e:	5e                   	pop    %esi
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084a:	eb 06                	jmp    800852 <strcmp+0x11>
		p++, q++;
  80084c:	83 c1 01             	add    $0x1,%ecx
  80084f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800852:	0f b6 01             	movzbl (%ecx),%eax
  800855:	84 c0                	test   %al,%al
  800857:	74 04                	je     80085d <strcmp+0x1c>
  800859:	3a 02                	cmp    (%edx),%al
  80085b:	74 ef                	je     80084c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085d:	0f b6 c0             	movzbl %al,%eax
  800860:	0f b6 12             	movzbl (%edx),%edx
  800863:	29 d0                	sub    %edx,%eax
}
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	89 c3                	mov    %eax,%ebx
  800873:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800876:	eb 06                	jmp    80087e <strncmp+0x17>
		n--, p++, q++;
  800878:	83 c0 01             	add    $0x1,%eax
  80087b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087e:	39 d8                	cmp    %ebx,%eax
  800880:	74 15                	je     800897 <strncmp+0x30>
  800882:	0f b6 08             	movzbl (%eax),%ecx
  800885:	84 c9                	test   %cl,%cl
  800887:	74 04                	je     80088d <strncmp+0x26>
  800889:	3a 0a                	cmp    (%edx),%cl
  80088b:	74 eb                	je     800878 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088d:	0f b6 00             	movzbl (%eax),%eax
  800890:	0f b6 12             	movzbl (%edx),%edx
  800893:	29 d0                	sub    %edx,%eax
  800895:	eb 05                	jmp    80089c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800897:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089c:	5b                   	pop    %ebx
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a9:	eb 07                	jmp    8008b2 <strchr+0x13>
		if (*s == c)
  8008ab:	38 ca                	cmp    %cl,%dl
  8008ad:	74 0f                	je     8008be <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008af:	83 c0 01             	add    $0x1,%eax
  8008b2:	0f b6 10             	movzbl (%eax),%edx
  8008b5:	84 d2                	test   %dl,%dl
  8008b7:	75 f2                	jne    8008ab <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ca:	eb 03                	jmp    8008cf <strfind+0xf>
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d2:	38 ca                	cmp    %cl,%dl
  8008d4:	74 04                	je     8008da <strfind+0x1a>
  8008d6:	84 d2                	test   %dl,%dl
  8008d8:	75 f2                	jne    8008cc <strfind+0xc>
			break;
	return (char *) s;
}
  8008da:	5d                   	pop    %ebp
  8008db:	c3                   	ret    

008008dc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008dc:	55                   	push   %ebp
  8008dd:	89 e5                	mov    %esp,%ebp
  8008df:	57                   	push   %edi
  8008e0:	56                   	push   %esi
  8008e1:	53                   	push   %ebx
  8008e2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e8:	85 c9                	test   %ecx,%ecx
  8008ea:	74 36                	je     800922 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ec:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f2:	75 28                	jne    80091c <memset+0x40>
  8008f4:	f6 c1 03             	test   $0x3,%cl
  8008f7:	75 23                	jne    80091c <memset+0x40>
		c &= 0xFF;
  8008f9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fd:	89 d3                	mov    %edx,%ebx
  8008ff:	c1 e3 08             	shl    $0x8,%ebx
  800902:	89 d6                	mov    %edx,%esi
  800904:	c1 e6 18             	shl    $0x18,%esi
  800907:	89 d0                	mov    %edx,%eax
  800909:	c1 e0 10             	shl    $0x10,%eax
  80090c:	09 f0                	or     %esi,%eax
  80090e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800910:	89 d8                	mov    %ebx,%eax
  800912:	09 d0                	or     %edx,%eax
  800914:	c1 e9 02             	shr    $0x2,%ecx
  800917:	fc                   	cld    
  800918:	f3 ab                	rep stos %eax,%es:(%edi)
  80091a:	eb 06                	jmp    800922 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091f:	fc                   	cld    
  800920:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800922:	89 f8                	mov    %edi,%eax
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5f                   	pop    %edi
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	57                   	push   %edi
  80092d:	56                   	push   %esi
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 75 0c             	mov    0xc(%ebp),%esi
  800934:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800937:	39 c6                	cmp    %eax,%esi
  800939:	73 35                	jae    800970 <memmove+0x47>
  80093b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093e:	39 d0                	cmp    %edx,%eax
  800940:	73 2e                	jae    800970 <memmove+0x47>
		s += n;
		d += n;
  800942:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800945:	89 d6                	mov    %edx,%esi
  800947:	09 fe                	or     %edi,%esi
  800949:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094f:	75 13                	jne    800964 <memmove+0x3b>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 0e                	jne    800964 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800956:	83 ef 04             	sub    $0x4,%edi
  800959:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095c:	c1 e9 02             	shr    $0x2,%ecx
  80095f:	fd                   	std    
  800960:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800962:	eb 09                	jmp    80096d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800964:	83 ef 01             	sub    $0x1,%edi
  800967:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096a:	fd                   	std    
  80096b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096d:	fc                   	cld    
  80096e:	eb 1d                	jmp    80098d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800970:	89 f2                	mov    %esi,%edx
  800972:	09 c2                	or     %eax,%edx
  800974:	f6 c2 03             	test   $0x3,%dl
  800977:	75 0f                	jne    800988 <memmove+0x5f>
  800979:	f6 c1 03             	test   $0x3,%cl
  80097c:	75 0a                	jne    800988 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097e:	c1 e9 02             	shr    $0x2,%ecx
  800981:	89 c7                	mov    %eax,%edi
  800983:	fc                   	cld    
  800984:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800986:	eb 05                	jmp    80098d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800988:	89 c7                	mov    %eax,%edi
  80098a:	fc                   	cld    
  80098b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800994:	ff 75 10             	pushl  0x10(%ebp)
  800997:	ff 75 0c             	pushl  0xc(%ebp)
  80099a:	ff 75 08             	pushl  0x8(%ebp)
  80099d:	e8 87 ff ff ff       	call   800929 <memmove>
}
  8009a2:	c9                   	leave  
  8009a3:	c3                   	ret    

008009a4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009af:	89 c6                	mov    %eax,%esi
  8009b1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b4:	eb 1a                	jmp    8009d0 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b6:	0f b6 08             	movzbl (%eax),%ecx
  8009b9:	0f b6 1a             	movzbl (%edx),%ebx
  8009bc:	38 d9                	cmp    %bl,%cl
  8009be:	74 0a                	je     8009ca <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c0:	0f b6 c1             	movzbl %cl,%eax
  8009c3:	0f b6 db             	movzbl %bl,%ebx
  8009c6:	29 d8                	sub    %ebx,%eax
  8009c8:	eb 0f                	jmp    8009d9 <memcmp+0x35>
		s1++, s2++;
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d0:	39 f0                	cmp    %esi,%eax
  8009d2:	75 e2                	jne    8009b6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d9:	5b                   	pop    %ebx
  8009da:	5e                   	pop    %esi
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	53                   	push   %ebx
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e4:	89 c1                	mov    %eax,%ecx
  8009e6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ed:	eb 0a                	jmp    8009f9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ef:	0f b6 10             	movzbl (%eax),%edx
  8009f2:	39 da                	cmp    %ebx,%edx
  8009f4:	74 07                	je     8009fd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f6:	83 c0 01             	add    $0x1,%eax
  8009f9:	39 c8                	cmp    %ecx,%eax
  8009fb:	72 f2                	jb     8009ef <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	57                   	push   %edi
  800a04:	56                   	push   %esi
  800a05:	53                   	push   %ebx
  800a06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0c:	eb 03                	jmp    800a11 <strtol+0x11>
		s++;
  800a0e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a11:	0f b6 01             	movzbl (%ecx),%eax
  800a14:	3c 20                	cmp    $0x20,%al
  800a16:	74 f6                	je     800a0e <strtol+0xe>
  800a18:	3c 09                	cmp    $0x9,%al
  800a1a:	74 f2                	je     800a0e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1c:	3c 2b                	cmp    $0x2b,%al
  800a1e:	75 0a                	jne    800a2a <strtol+0x2a>
		s++;
  800a20:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a23:	bf 00 00 00 00       	mov    $0x0,%edi
  800a28:	eb 11                	jmp    800a3b <strtol+0x3b>
  800a2a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a2f:	3c 2d                	cmp    $0x2d,%al
  800a31:	75 08                	jne    800a3b <strtol+0x3b>
		s++, neg = 1;
  800a33:	83 c1 01             	add    $0x1,%ecx
  800a36:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a41:	75 15                	jne    800a58 <strtol+0x58>
  800a43:	80 39 30             	cmpb   $0x30,(%ecx)
  800a46:	75 10                	jne    800a58 <strtol+0x58>
  800a48:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4c:	75 7c                	jne    800aca <strtol+0xca>
		s += 2, base = 16;
  800a4e:	83 c1 02             	add    $0x2,%ecx
  800a51:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a56:	eb 16                	jmp    800a6e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a58:	85 db                	test   %ebx,%ebx
  800a5a:	75 12                	jne    800a6e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a61:	80 39 30             	cmpb   $0x30,(%ecx)
  800a64:	75 08                	jne    800a6e <strtol+0x6e>
		s++, base = 8;
  800a66:	83 c1 01             	add    $0x1,%ecx
  800a69:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a73:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a76:	0f b6 11             	movzbl (%ecx),%edx
  800a79:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	80 fb 09             	cmp    $0x9,%bl
  800a81:	77 08                	ja     800a8b <strtol+0x8b>
			dig = *s - '0';
  800a83:	0f be d2             	movsbl %dl,%edx
  800a86:	83 ea 30             	sub    $0x30,%edx
  800a89:	eb 22                	jmp    800aad <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8e:	89 f3                	mov    %esi,%ebx
  800a90:	80 fb 19             	cmp    $0x19,%bl
  800a93:	77 08                	ja     800a9d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a95:	0f be d2             	movsbl %dl,%edx
  800a98:	83 ea 57             	sub    $0x57,%edx
  800a9b:	eb 10                	jmp    800aad <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa0:	89 f3                	mov    %esi,%ebx
  800aa2:	80 fb 19             	cmp    $0x19,%bl
  800aa5:	77 16                	ja     800abd <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa7:	0f be d2             	movsbl %dl,%edx
  800aaa:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aad:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab0:	7d 0b                	jge    800abd <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab2:	83 c1 01             	add    $0x1,%ecx
  800ab5:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abb:	eb b9                	jmp    800a76 <strtol+0x76>

	if (endptr)
  800abd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac1:	74 0d                	je     800ad0 <strtol+0xd0>
		*endptr = (char *) s;
  800ac3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac6:	89 0e                	mov    %ecx,(%esi)
  800ac8:	eb 06                	jmp    800ad0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aca:	85 db                	test   %ebx,%ebx
  800acc:	74 98                	je     800a66 <strtol+0x66>
  800ace:	eb 9e                	jmp    800a6e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad0:	89 c2                	mov    %eax,%edx
  800ad2:	f7 da                	neg    %edx
  800ad4:	85 ff                	test   %edi,%edi
  800ad6:	0f 45 c2             	cmovne %edx,%eax
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	57                   	push   %edi
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
  800aef:	89 c3                	mov    %eax,%ebx
  800af1:	89 c7                	mov    %eax,%edi
  800af3:	89 c6                	mov    %eax,%esi
  800af5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_cgetc>:

int
sys_cgetc(void)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	ba 00 00 00 00       	mov    $0x0,%edx
  800b07:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0c:	89 d1                	mov    %edx,%ecx
  800b0e:	89 d3                	mov    %edx,%ebx
  800b10:	89 d7                	mov    %edx,%edi
  800b12:	89 d6                	mov    %edx,%esi
  800b14:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b16:	5b                   	pop    %ebx
  800b17:	5e                   	pop    %esi
  800b18:	5f                   	pop    %edi
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b29:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	89 cb                	mov    %ecx,%ebx
  800b33:	89 cf                	mov    %ecx,%edi
  800b35:	89 ce                	mov    %ecx,%esi
  800b37:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b39:	85 c0                	test   %eax,%eax
  800b3b:	7e 17                	jle    800b54 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3d:	83 ec 0c             	sub    $0xc,%esp
  800b40:	50                   	push   %eax
  800b41:	6a 03                	push   $0x3
  800b43:	68 84 12 80 00       	push   $0x801284
  800b48:	6a 23                	push   $0x23
  800b4a:	68 a1 12 80 00       	push   $0x8012a1
  800b4f:	e8 f5 01 00 00       	call   800d49 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6c:	89 d1                	mov    %edx,%ecx
  800b6e:	89 d3                	mov    %edx,%ebx
  800b70:	89 d7                	mov    %edx,%edi
  800b72:	89 d6                	mov    %edx,%esi
  800b74:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_yield>:

void
sys_yield(void)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b81:	ba 00 00 00 00       	mov    $0x0,%edx
  800b86:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8b:	89 d1                	mov    %edx,%ecx
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	89 d7                	mov    %edx,%edi
  800b91:	89 d6                	mov    %edx,%esi
  800b93:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
  800ba0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	be 00 00 00 00       	mov    $0x0,%esi
  800ba8:	b8 04 00 00 00       	mov    $0x4,%eax
  800bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb6:	89 f7                	mov    %esi,%edi
  800bb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bba:	85 c0                	test   %eax,%eax
  800bbc:	7e 17                	jle    800bd5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	50                   	push   %eax
  800bc2:	6a 04                	push   $0x4
  800bc4:	68 84 12 80 00       	push   $0x801284
  800bc9:	6a 23                	push   $0x23
  800bcb:	68 a1 12 80 00       	push   $0x8012a1
  800bd0:	e8 74 01 00 00       	call   800d49 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b8 05 00 00 00       	mov    $0x5,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	7e 17                	jle    800c17 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	50                   	push   %eax
  800c04:	6a 05                	push   $0x5
  800c06:	68 84 12 80 00       	push   $0x801284
  800c0b:	6a 23                	push   $0x23
  800c0d:	68 a1 12 80 00       	push   $0x8012a1
  800c12:	e8 32 01 00 00       	call   800d49 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c35:	8b 55 08             	mov    0x8(%ebp),%edx
  800c38:	89 df                	mov    %ebx,%edi
  800c3a:	89 de                	mov    %ebx,%esi
  800c3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7e 17                	jle    800c59 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	50                   	push   %eax
  800c46:	6a 06                	push   $0x6
  800c48:	68 84 12 80 00       	push   $0x801284
  800c4d:	6a 23                	push   $0x23
  800c4f:	68 a1 12 80 00       	push   $0x8012a1
  800c54:	e8 f0 00 00 00       	call   800d49 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	89 df                	mov    %ebx,%edi
  800c7c:	89 de                	mov    %ebx,%esi
  800c7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 17                	jle    800c9b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	50                   	push   %eax
  800c88:	6a 08                	push   $0x8
  800c8a:	68 84 12 80 00       	push   $0x801284
  800c8f:	6a 23                	push   $0x23
  800c91:	68 a1 12 80 00       	push   $0x8012a1
  800c96:	e8 ae 00 00 00       	call   800d49 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb1:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	89 df                	mov    %ebx,%edi
  800cbe:	89 de                	mov    %ebx,%esi
  800cc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7e 17                	jle    800cdd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc6:	83 ec 0c             	sub    $0xc,%esp
  800cc9:	50                   	push   %eax
  800cca:	6a 09                	push   $0x9
  800ccc:	68 84 12 80 00       	push   $0x801284
  800cd1:	6a 23                	push   $0x23
  800cd3:	68 a1 12 80 00       	push   $0x8012a1
  800cd8:	e8 6c 00 00 00       	call   800d49 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	be 00 00 00 00       	mov    $0x0,%esi
  800cf0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d01:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d16:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	89 cb                	mov    %ecx,%ebx
  800d20:	89 cf                	mov    %ecx,%edi
  800d22:	89 ce                	mov    %ecx,%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 17                	jle    800d41 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	50                   	push   %eax
  800d2e:	6a 0c                	push   $0xc
  800d30:	68 84 12 80 00       	push   $0x801284
  800d35:	6a 23                	push   $0x23
  800d37:	68 a1 12 80 00       	push   $0x8012a1
  800d3c:	e8 08 00 00 00       	call   800d49 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d4e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d51:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d57:	e8 00 fe ff ff       	call   800b5c <sys_getenvid>
  800d5c:	83 ec 0c             	sub    $0xc,%esp
  800d5f:	ff 75 0c             	pushl  0xc(%ebp)
  800d62:	ff 75 08             	pushl  0x8(%ebp)
  800d65:	56                   	push   %esi
  800d66:	50                   	push   %eax
  800d67:	68 b0 12 80 00       	push   $0x8012b0
  800d6c:	e8 22 f4 ff ff       	call   800193 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d71:	83 c4 18             	add    $0x18,%esp
  800d74:	53                   	push   %ebx
  800d75:	ff 75 10             	pushl  0x10(%ebp)
  800d78:	e8 c5 f3 ff ff       	call   800142 <vcprintf>
	cprintf("\n");
  800d7d:	c7 04 24 2c 10 80 00 	movl   $0x80102c,(%esp)
  800d84:	e8 0a f4 ff ff       	call   800193 <cprintf>
  800d89:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d8c:	cc                   	int3   
  800d8d:	eb fd                	jmp    800d8c <_panic+0x43>
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
