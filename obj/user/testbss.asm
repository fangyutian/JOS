
obj/user/testbss:     file format elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 64 0e 80 00       	push   $0x800e64
  80003e:	e8 cd 01 00 00       	call   800210 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 df 0e 80 00       	push   $0x800edf
  80005b:	6a 11                	push   $0x11
  80005d:	68 fc 0e 80 00       	push   $0x800efc
  800062:	e8 d0 00 00 00       	call   800137 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800067:	83 c0 01             	add    $0x1,%eax
  80006a:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80006f:	75 da                	jne    80004b <umain+0x18>
  800071:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800076:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80007d:	83 c0 01             	add    $0x1,%eax
  800080:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800085:	75 ef                	jne    800076 <umain+0x43>
  800087:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  80008c:	3b 04 85 20 20 80 00 	cmp    0x802020(,%eax,4),%eax
  800093:	74 12                	je     8000a7 <umain+0x74>
			panic("bigarray[%d] didn't hold its value!\n", i);
  800095:	50                   	push   %eax
  800096:	68 84 0e 80 00       	push   $0x800e84
  80009b:	6a 16                	push   $0x16
  80009d:	68 fc 0e 80 00       	push   $0x800efc
  8000a2:	e8 90 00 00 00       	call   800137 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000a7:	83 c0 01             	add    $0x1,%eax
  8000aa:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000af:	75 db                	jne    80008c <umain+0x59>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	68 ac 0e 80 00       	push   $0x800eac
  8000b9:	e8 52 01 00 00       	call   800210 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 0b 0f 80 00       	push   $0x800f0b
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 fc 0e 80 00       	push   $0x800efc
  8000d7:	e8 5b 00 00 00       	call   800137 <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  8000e7:	e8 b4 0a 00 00       	call   800ba0 <sys_getenvid>
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	8d 04 40             	lea    (%eax,%eax,2),%eax
  8000f4:	c1 e0 05             	shl    $0x5,%eax
  8000f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fc:	a3 20 20 c0 00       	mov    %eax,0xc02020
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800101:	85 db                	test   %ebx,%ebx
  800103:	7e 07                	jle    80010c <libmain+0x30>
		binaryname = argv[0];
  800105:	8b 06                	mov    (%esi),%eax
  800107:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80010c:	83 ec 08             	sub    $0x8,%esp
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
  800111:	e8 1d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800116:	e8 0a 00 00 00       	call   800125 <exit>
}
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800121:	5b                   	pop    %ebx
  800122:	5e                   	pop    %esi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80012b:	6a 00                	push   $0x0
  80012d:	e8 2d 0a 00 00       	call   800b5f <sys_env_destroy>
}
  800132:	83 c4 10             	add    $0x10,%esp
  800135:	c9                   	leave  
  800136:	c3                   	ret    

00800137 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80013c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800145:	e8 56 0a 00 00       	call   800ba0 <sys_getenvid>
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	ff 75 0c             	pushl  0xc(%ebp)
  800150:	ff 75 08             	pushl  0x8(%ebp)
  800153:	56                   	push   %esi
  800154:	50                   	push   %eax
  800155:	68 2c 0f 80 00       	push   $0x800f2c
  80015a:	e8 b1 00 00 00       	call   800210 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015f:	83 c4 18             	add    $0x18,%esp
  800162:	53                   	push   %ebx
  800163:	ff 75 10             	pushl  0x10(%ebp)
  800166:	e8 54 00 00 00       	call   8001bf <vcprintf>
	cprintf("\n");
  80016b:	c7 04 24 fa 0e 80 00 	movl   $0x800efa,(%esp)
  800172:	e8 99 00 00 00       	call   800210 <cprintf>
  800177:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80017a:	cc                   	int3   
  80017b:	eb fd                	jmp    80017a <_panic+0x43>

0080017d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	53                   	push   %ebx
  800181:	83 ec 04             	sub    $0x4,%esp
  800184:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800187:	8b 13                	mov    (%ebx),%edx
  800189:	8d 42 01             	lea    0x1(%edx),%eax
  80018c:	89 03                	mov    %eax,(%ebx)
  80018e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800191:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800195:	3d ff 00 00 00       	cmp    $0xff,%eax
  80019a:	75 1a                	jne    8001b6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80019c:	83 ec 08             	sub    $0x8,%esp
  80019f:	68 ff 00 00 00       	push   $0xff
  8001a4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a7:	50                   	push   %eax
  8001a8:	e8 75 09 00 00       	call   800b22 <sys_cputs>
		b->idx = 0;
  8001ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001b6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001bd:	c9                   	leave  
  8001be:	c3                   	ret    

008001bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cf:	00 00 00 
	b.cnt = 0;
  8001d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001dc:	ff 75 0c             	pushl  0xc(%ebp)
  8001df:	ff 75 08             	pushl  0x8(%ebp)
  8001e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e8:	50                   	push   %eax
  8001e9:	68 7d 01 80 00       	push   $0x80017d
  8001ee:	e8 54 01 00 00       	call   800347 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f3:	83 c4 08             	add    $0x8,%esp
  8001f6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800202:	50                   	push   %eax
  800203:	e8 1a 09 00 00       	call   800b22 <sys_cputs>

	return b.cnt;
}
  800208:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800216:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800219:	50                   	push   %eax
  80021a:	ff 75 08             	pushl  0x8(%ebp)
  80021d:	e8 9d ff ff ff       	call   8001bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 1c             	sub    $0x1c,%esp
  80022d:	89 c7                	mov    %eax,%edi
  80022f:	89 d6                	mov    %edx,%esi
  800231:	8b 45 08             	mov    0x8(%ebp),%eax
  800234:	8b 55 0c             	mov    0xc(%ebp),%edx
  800237:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80023a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800248:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024b:	39 d3                	cmp    %edx,%ebx
  80024d:	72 05                	jb     800254 <printnum+0x30>
  80024f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800252:	77 45                	ja     800299 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	ff 75 18             	pushl  0x18(%ebp)
  80025a:	8b 45 14             	mov    0x14(%ebp),%eax
  80025d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800260:	53                   	push   %ebx
  800261:	ff 75 10             	pushl  0x10(%ebp)
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026a:	ff 75 e0             	pushl  -0x20(%ebp)
  80026d:	ff 75 dc             	pushl  -0x24(%ebp)
  800270:	ff 75 d8             	pushl  -0x28(%ebp)
  800273:	e8 68 09 00 00       	call   800be0 <__udivdi3>
  800278:	83 c4 18             	add    $0x18,%esp
  80027b:	52                   	push   %edx
  80027c:	50                   	push   %eax
  80027d:	89 f2                	mov    %esi,%edx
  80027f:	89 f8                	mov    %edi,%eax
  800281:	e8 9e ff ff ff       	call   800224 <printnum>
  800286:	83 c4 20             	add    $0x20,%esp
  800289:	eb 18                	jmp    8002a3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028b:	83 ec 08             	sub    $0x8,%esp
  80028e:	56                   	push   %esi
  80028f:	ff 75 18             	pushl  0x18(%ebp)
  800292:	ff d7                	call   *%edi
  800294:	83 c4 10             	add    $0x10,%esp
  800297:	eb 03                	jmp    80029c <printnum+0x78>
  800299:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029c:	83 eb 01             	sub    $0x1,%ebx
  80029f:	85 db                	test   %ebx,%ebx
  8002a1:	7f e8                	jg     80028b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a3:	83 ec 08             	sub    $0x8,%esp
  8002a6:	56                   	push   %esi
  8002a7:	83 ec 04             	sub    $0x4,%esp
  8002aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b6:	e8 55 0a 00 00       	call   800d10 <__umoddi3>
  8002bb:	83 c4 14             	add    $0x14,%esp
  8002be:	0f be 80 50 0f 80 00 	movsbl 0x800f50(%eax),%eax
  8002c5:	50                   	push   %eax
  8002c6:	ff d7                	call   *%edi
}
  8002c8:	83 c4 10             	add    $0x10,%esp
  8002cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ce:	5b                   	pop    %ebx
  8002cf:	5e                   	pop    %esi
  8002d0:	5f                   	pop    %edi
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002d6:	83 fa 01             	cmp    $0x1,%edx
  8002d9:	7e 0e                	jle    8002e9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002db:	8b 10                	mov    (%eax),%edx
  8002dd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002e0:	89 08                	mov    %ecx,(%eax)
  8002e2:	8b 02                	mov    (%edx),%eax
  8002e4:	8b 52 04             	mov    0x4(%edx),%edx
  8002e7:	eb 22                	jmp    80030b <getuint+0x38>
	else if (lflag)
  8002e9:	85 d2                	test   %edx,%edx
  8002eb:	74 10                	je     8002fd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002ed:	8b 10                	mov    (%eax),%edx
  8002ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 02                	mov    (%edx),%eax
  8002f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fb:	eb 0e                	jmp    80030b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 02                	mov    (%edx),%eax
  800306:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800313:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800317:	8b 10                	mov    (%eax),%edx
  800319:	3b 50 04             	cmp    0x4(%eax),%edx
  80031c:	73 0a                	jae    800328 <sprintputch+0x1b>
		*b->buf++ = ch;
  80031e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800321:	89 08                	mov    %ecx,(%eax)
  800323:	8b 45 08             	mov    0x8(%ebp),%eax
  800326:	88 02                	mov    %al,(%edx)
}
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800330:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800333:	50                   	push   %eax
  800334:	ff 75 10             	pushl  0x10(%ebp)
  800337:	ff 75 0c             	pushl  0xc(%ebp)
  80033a:	ff 75 08             	pushl  0x8(%ebp)
  80033d:	e8 05 00 00 00       	call   800347 <vprintfmt>
	va_end(ap);
}
  800342:	83 c4 10             	add    $0x10,%esp
  800345:	c9                   	leave  
  800346:	c3                   	ret    

00800347 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
  80034d:	83 ec 2c             	sub    $0x2c,%esp
  800350:	8b 75 08             	mov    0x8(%ebp),%esi
  800353:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800356:	8b 7d 10             	mov    0x10(%ebp),%edi
  800359:	eb 1d                	jmp    800378 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80035b:	85 c0                	test   %eax,%eax
  80035d:	75 0f                	jne    80036e <vprintfmt+0x27>
				csa = 0x0700;
  80035f:	c7 05 24 20 c0 00 00 	movl   $0x700,0xc02024
  800366:	07 00 00 
				return;
  800369:	e9 c4 03 00 00       	jmp    800732 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  80036e:	83 ec 08             	sub    $0x8,%esp
  800371:	53                   	push   %ebx
  800372:	50                   	push   %eax
  800373:	ff d6                	call   *%esi
  800375:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800378:	83 c7 01             	add    $0x1,%edi
  80037b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80037f:	83 f8 25             	cmp    $0x25,%eax
  800382:	75 d7                	jne    80035b <vprintfmt+0x14>
  800384:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800388:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80038f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800396:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80039d:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a2:	eb 07                	jmp    8003ab <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003a7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ab:	8d 47 01             	lea    0x1(%edi),%eax
  8003ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b1:	0f b6 07             	movzbl (%edi),%eax
  8003b4:	0f b6 c8             	movzbl %al,%ecx
  8003b7:	83 e8 23             	sub    $0x23,%eax
  8003ba:	3c 55                	cmp    $0x55,%al
  8003bc:	0f 87 55 03 00 00    	ja     800717 <vprintfmt+0x3d0>
  8003c2:	0f b6 c0             	movzbl %al,%eax
  8003c5:	ff 24 85 e0 0f 80 00 	jmp    *0x800fe0(,%eax,4)
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003cf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d3:	eb d6                	jmp    8003ab <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003e7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003ea:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003ed:	83 fa 09             	cmp    $0x9,%edx
  8003f0:	77 39                	ja     80042b <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003f2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003f5:	eb e9                	jmp    8003e0 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 48 04             	lea    0x4(%eax),%ecx
  8003fd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800400:	8b 00                	mov    (%eax),%eax
  800402:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800405:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800408:	eb 27                	jmp    800431 <vprintfmt+0xea>
  80040a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80040d:	85 c0                	test   %eax,%eax
  80040f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800414:	0f 49 c8             	cmovns %eax,%ecx
  800417:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041d:	eb 8c                	jmp    8003ab <vprintfmt+0x64>
  80041f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800422:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800429:	eb 80                	jmp    8003ab <vprintfmt+0x64>
  80042b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80042e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800431:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800435:	0f 89 70 ff ff ff    	jns    8003ab <vprintfmt+0x64>
				width = precision, precision = -1;
  80043b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80043e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800441:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800448:	e9 5e ff ff ff       	jmp    8003ab <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80044d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800453:	e9 53 ff ff ff       	jmp    8003ab <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8d 50 04             	lea    0x4(%eax),%edx
  80045e:	89 55 14             	mov    %edx,0x14(%ebp)
  800461:	83 ec 08             	sub    $0x8,%esp
  800464:	53                   	push   %ebx
  800465:	ff 30                	pushl  (%eax)
  800467:	ff d6                	call   *%esi
			break;
  800469:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80046f:	e9 04 ff ff ff       	jmp    800378 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	8d 50 04             	lea    0x4(%eax),%edx
  80047a:	89 55 14             	mov    %edx,0x14(%ebp)
  80047d:	8b 00                	mov    (%eax),%eax
  80047f:	99                   	cltd   
  800480:	31 d0                	xor    %edx,%eax
  800482:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800484:	83 f8 06             	cmp    $0x6,%eax
  800487:	7f 0b                	jg     800494 <vprintfmt+0x14d>
  800489:	8b 14 85 38 11 80 00 	mov    0x801138(,%eax,4),%edx
  800490:	85 d2                	test   %edx,%edx
  800492:	75 18                	jne    8004ac <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  800494:	50                   	push   %eax
  800495:	68 68 0f 80 00       	push   $0x800f68
  80049a:	53                   	push   %ebx
  80049b:	56                   	push   %esi
  80049c:	e8 89 fe ff ff       	call   80032a <printfmt>
  8004a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004a7:	e9 cc fe ff ff       	jmp    800378 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8004ac:	52                   	push   %edx
  8004ad:	68 71 0f 80 00       	push   $0x800f71
  8004b2:	53                   	push   %ebx
  8004b3:	56                   	push   %esi
  8004b4:	e8 71 fe ff ff       	call   80032a <printfmt>
  8004b9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bf:	e9 b4 fe ff ff       	jmp    800378 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8004cd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004cf:	85 ff                	test   %edi,%edi
  8004d1:	b8 61 0f 80 00       	mov    $0x800f61,%eax
  8004d6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004d9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004dd:	0f 8e 94 00 00 00    	jle    800577 <vprintfmt+0x230>
  8004e3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004e7:	0f 84 98 00 00 00    	je     800585 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	ff 75 d0             	pushl  -0x30(%ebp)
  8004f3:	57                   	push   %edi
  8004f4:	e8 c1 02 00 00       	call   8007ba <strnlen>
  8004f9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004fc:	29 c1                	sub    %eax,%ecx
  8004fe:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800501:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800504:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800508:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80050b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80050e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800510:	eb 0f                	jmp    800521 <vprintfmt+0x1da>
					putch(padc, putdat);
  800512:	83 ec 08             	sub    $0x8,%esp
  800515:	53                   	push   %ebx
  800516:	ff 75 e0             	pushl  -0x20(%ebp)
  800519:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051b:	83 ef 01             	sub    $0x1,%edi
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	85 ff                	test   %edi,%edi
  800523:	7f ed                	jg     800512 <vprintfmt+0x1cb>
  800525:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800528:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80052b:	85 c9                	test   %ecx,%ecx
  80052d:	b8 00 00 00 00       	mov    $0x0,%eax
  800532:	0f 49 c1             	cmovns %ecx,%eax
  800535:	29 c1                	sub    %eax,%ecx
  800537:	89 75 08             	mov    %esi,0x8(%ebp)
  80053a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80053d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800540:	89 cb                	mov    %ecx,%ebx
  800542:	eb 4d                	jmp    800591 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800544:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800548:	74 1b                	je     800565 <vprintfmt+0x21e>
  80054a:	0f be c0             	movsbl %al,%eax
  80054d:	83 e8 20             	sub    $0x20,%eax
  800550:	83 f8 5e             	cmp    $0x5e,%eax
  800553:	76 10                	jbe    800565 <vprintfmt+0x21e>
					putch('?', putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	ff 75 0c             	pushl  0xc(%ebp)
  80055b:	6a 3f                	push   $0x3f
  80055d:	ff 55 08             	call   *0x8(%ebp)
  800560:	83 c4 10             	add    $0x10,%esp
  800563:	eb 0d                	jmp    800572 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	ff 75 0c             	pushl  0xc(%ebp)
  80056b:	52                   	push   %edx
  80056c:	ff 55 08             	call   *0x8(%ebp)
  80056f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800572:	83 eb 01             	sub    $0x1,%ebx
  800575:	eb 1a                	jmp    800591 <vprintfmt+0x24a>
  800577:	89 75 08             	mov    %esi,0x8(%ebp)
  80057a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80057d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800580:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800583:	eb 0c                	jmp    800591 <vprintfmt+0x24a>
  800585:	89 75 08             	mov    %esi,0x8(%ebp)
  800588:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800591:	83 c7 01             	add    $0x1,%edi
  800594:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800598:	0f be d0             	movsbl %al,%edx
  80059b:	85 d2                	test   %edx,%edx
  80059d:	74 23                	je     8005c2 <vprintfmt+0x27b>
  80059f:	85 f6                	test   %esi,%esi
  8005a1:	78 a1                	js     800544 <vprintfmt+0x1fd>
  8005a3:	83 ee 01             	sub    $0x1,%esi
  8005a6:	79 9c                	jns    800544 <vprintfmt+0x1fd>
  8005a8:	89 df                	mov    %ebx,%edi
  8005aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b0:	eb 18                	jmp    8005ca <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	6a 20                	push   $0x20
  8005b8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ba:	83 ef 01             	sub    $0x1,%edi
  8005bd:	83 c4 10             	add    $0x10,%esp
  8005c0:	eb 08                	jmp    8005ca <vprintfmt+0x283>
  8005c2:	89 df                	mov    %ebx,%edi
  8005c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ca:	85 ff                	test   %edi,%edi
  8005cc:	7f e4                	jg     8005b2 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d1:	e9 a2 fd ff ff       	jmp    800378 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d6:	83 fa 01             	cmp    $0x1,%edx
  8005d9:	7e 16                	jle    8005f1 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 50 08             	lea    0x8(%eax),%edx
  8005e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e4:	8b 50 04             	mov    0x4(%eax),%edx
  8005e7:	8b 00                	mov    (%eax),%eax
  8005e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ef:	eb 32                	jmp    800623 <vprintfmt+0x2dc>
	else if (lflag)
  8005f1:	85 d2                	test   %edx,%edx
  8005f3:	74 18                	je     80060d <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	8b 00                	mov    (%eax),%eax
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	89 c1                	mov    %eax,%ecx
  800605:	c1 f9 1f             	sar    $0x1f,%ecx
  800608:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80060b:	eb 16                	jmp    800623 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 04             	lea    0x4(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)
  800616:	8b 00                	mov    (%eax),%eax
  800618:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061b:	89 c1                	mov    %eax,%ecx
  80061d:	c1 f9 1f             	sar    $0x1f,%ecx
  800620:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800623:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800626:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800629:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800632:	79 74                	jns    8006a8 <vprintfmt+0x361>
				putch('-', putdat);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 2d                	push   $0x2d
  80063a:	ff d6                	call   *%esi
				num = -(long long) num;
  80063c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800642:	f7 d8                	neg    %eax
  800644:	83 d2 00             	adc    $0x0,%edx
  800647:	f7 da                	neg    %edx
  800649:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80064c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800651:	eb 55                	jmp    8006a8 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 78 fc ff ff       	call   8002d3 <getuint>
			base = 10;
  80065b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800660:	eb 46                	jmp    8006a8 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800662:	8d 45 14             	lea    0x14(%ebp),%eax
  800665:	e8 69 fc ff ff       	call   8002d3 <getuint>
      base = 8;
  80066a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80066f:	eb 37                	jmp    8006a8 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 30                	push   $0x30
  800677:	ff d6                	call   *%esi
			putch('x', putdat);
  800679:	83 c4 08             	add    $0x8,%esp
  80067c:	53                   	push   %ebx
  80067d:	6a 78                	push   $0x78
  80067f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8d 50 04             	lea    0x4(%eax),%edx
  800687:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80068a:	8b 00                	mov    (%eax),%eax
  80068c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800691:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800694:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800699:	eb 0d                	jmp    8006a8 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 30 fc ff ff       	call   8002d3 <getuint>
			base = 16;
  8006a3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a8:	83 ec 0c             	sub    $0xc,%esp
  8006ab:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006af:	57                   	push   %edi
  8006b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006b3:	51                   	push   %ecx
  8006b4:	52                   	push   %edx
  8006b5:	50                   	push   %eax
  8006b6:	89 da                	mov    %ebx,%edx
  8006b8:	89 f0                	mov    %esi,%eax
  8006ba:	e8 65 fb ff ff       	call   800224 <printnum>
			break;
  8006bf:	83 c4 20             	add    $0x20,%esp
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c5:	e9 ae fc ff ff       	jmp    800378 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	51                   	push   %ecx
  8006cf:	ff d6                	call   *%esi
			break;
  8006d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006d7:	e9 9c fc ff ff       	jmp    800378 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006dc:	83 fa 01             	cmp    $0x1,%edx
  8006df:	7e 0d                	jle    8006ee <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8d 50 08             	lea    0x8(%eax),%edx
  8006e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ea:	8b 00                	mov    (%eax),%eax
  8006ec:	eb 1c                	jmp    80070a <vprintfmt+0x3c3>
	else if (lflag)
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	74 0d                	je     8006ff <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 04             	lea    0x4(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fb:	8b 00                	mov    (%eax),%eax
  8006fd:	eb 0b                	jmp    80070a <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8d 50 04             	lea    0x4(%eax),%edx
  800705:	89 55 14             	mov    %edx,0x14(%ebp)
  800708:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  80070a:	a3 24 20 c0 00       	mov    %eax,0xc02024
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  800712:	e9 61 fc ff ff       	jmp    800378 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	53                   	push   %ebx
  80071b:	6a 25                	push   $0x25
  80071d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	eb 03                	jmp    800727 <vprintfmt+0x3e0>
  800724:	83 ef 01             	sub    $0x1,%edi
  800727:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80072b:	75 f7                	jne    800724 <vprintfmt+0x3dd>
  80072d:	e9 46 fc ff ff       	jmp    800378 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800732:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800735:	5b                   	pop    %ebx
  800736:	5e                   	pop    %esi
  800737:	5f                   	pop    %edi
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 18             	sub    $0x18,%esp
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800746:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800749:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800750:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800757:	85 c0                	test   %eax,%eax
  800759:	74 26                	je     800781 <vsnprintf+0x47>
  80075b:	85 d2                	test   %edx,%edx
  80075d:	7e 22                	jle    800781 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075f:	ff 75 14             	pushl  0x14(%ebp)
  800762:	ff 75 10             	pushl  0x10(%ebp)
  800765:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800768:	50                   	push   %eax
  800769:	68 0d 03 80 00       	push   $0x80030d
  80076e:	e8 d4 fb ff ff       	call   800347 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800773:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800776:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb 05                	jmp    800786 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800781:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800791:	50                   	push   %eax
  800792:	ff 75 10             	pushl  0x10(%ebp)
  800795:	ff 75 0c             	pushl  0xc(%ebp)
  800798:	ff 75 08             	pushl  0x8(%ebp)
  80079b:	e8 9a ff ff ff       	call   80073a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    

008007a2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ad:	eb 03                	jmp    8007b2 <strlen+0x10>
		n++;
  8007af:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b6:	75 f7                	jne    8007af <strlen+0xd>
		n++;
	return n;
}
  8007b8:	5d                   	pop    %ebp
  8007b9:	c3                   	ret    

008007ba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c8:	eb 03                	jmp    8007cd <strnlen+0x13>
		n++;
  8007ca:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cd:	39 c2                	cmp    %eax,%edx
  8007cf:	74 08                	je     8007d9 <strnlen+0x1f>
  8007d1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d5:	75 f3                	jne    8007ca <strnlen+0x10>
  8007d7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e5:	89 c2                	mov    %eax,%edx
  8007e7:	83 c2 01             	add    $0x1,%edx
  8007ea:	83 c1 01             	add    $0x1,%ecx
  8007ed:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007f1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f4:	84 db                	test   %bl,%bl
  8007f6:	75 ef                	jne    8007e7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f8:	5b                   	pop    %ebx
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800802:	53                   	push   %ebx
  800803:	e8 9a ff ff ff       	call   8007a2 <strlen>
  800808:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80080b:	ff 75 0c             	pushl  0xc(%ebp)
  80080e:	01 d8                	add    %ebx,%eax
  800810:	50                   	push   %eax
  800811:	e8 c5 ff ff ff       	call   8007db <strcpy>
	return dst;
}
  800816:	89 d8                	mov    %ebx,%eax
  800818:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081b:	c9                   	leave  
  80081c:	c3                   	ret    

0080081d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081d:	55                   	push   %ebp
  80081e:	89 e5                	mov    %esp,%ebp
  800820:	56                   	push   %esi
  800821:	53                   	push   %ebx
  800822:	8b 75 08             	mov    0x8(%ebp),%esi
  800825:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800828:	89 f3                	mov    %esi,%ebx
  80082a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082d:	89 f2                	mov    %esi,%edx
  80082f:	eb 0f                	jmp    800840 <strncpy+0x23>
		*dst++ = *src;
  800831:	83 c2 01             	add    $0x1,%edx
  800834:	0f b6 01             	movzbl (%ecx),%eax
  800837:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083a:	80 39 01             	cmpb   $0x1,(%ecx)
  80083d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800840:	39 da                	cmp    %ebx,%edx
  800842:	75 ed                	jne    800831 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800844:	89 f0                	mov    %esi,%eax
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	56                   	push   %esi
  80084e:	53                   	push   %ebx
  80084f:	8b 75 08             	mov    0x8(%ebp),%esi
  800852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800855:	8b 55 10             	mov    0x10(%ebp),%edx
  800858:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085a:	85 d2                	test   %edx,%edx
  80085c:	74 21                	je     80087f <strlcpy+0x35>
  80085e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800862:	89 f2                	mov    %esi,%edx
  800864:	eb 09                	jmp    80086f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800866:	83 c2 01             	add    $0x1,%edx
  800869:	83 c1 01             	add    $0x1,%ecx
  80086c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086f:	39 c2                	cmp    %eax,%edx
  800871:	74 09                	je     80087c <strlcpy+0x32>
  800873:	0f b6 19             	movzbl (%ecx),%ebx
  800876:	84 db                	test   %bl,%bl
  800878:	75 ec                	jne    800866 <strlcpy+0x1c>
  80087a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80087c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087f:	29 f0                	sub    %esi,%eax
}
  800881:	5b                   	pop    %ebx
  800882:	5e                   	pop    %esi
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088e:	eb 06                	jmp    800896 <strcmp+0x11>
		p++, q++;
  800890:	83 c1 01             	add    $0x1,%ecx
  800893:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800896:	0f b6 01             	movzbl (%ecx),%eax
  800899:	84 c0                	test   %al,%al
  80089b:	74 04                	je     8008a1 <strcmp+0x1c>
  80089d:	3a 02                	cmp    (%edx),%al
  80089f:	74 ef                	je     800890 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a1:	0f b6 c0             	movzbl %al,%eax
  8008a4:	0f b6 12             	movzbl (%edx),%edx
  8008a7:	29 d0                	sub    %edx,%eax
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b5:	89 c3                	mov    %eax,%ebx
  8008b7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ba:	eb 06                	jmp    8008c2 <strncmp+0x17>
		n--, p++, q++;
  8008bc:	83 c0 01             	add    $0x1,%eax
  8008bf:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008c2:	39 d8                	cmp    %ebx,%eax
  8008c4:	74 15                	je     8008db <strncmp+0x30>
  8008c6:	0f b6 08             	movzbl (%eax),%ecx
  8008c9:	84 c9                	test   %cl,%cl
  8008cb:	74 04                	je     8008d1 <strncmp+0x26>
  8008cd:	3a 0a                	cmp    (%edx),%cl
  8008cf:	74 eb                	je     8008bc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d1:	0f b6 00             	movzbl (%eax),%eax
  8008d4:	0f b6 12             	movzbl (%edx),%edx
  8008d7:	29 d0                	sub    %edx,%eax
  8008d9:	eb 05                	jmp    8008e0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	5d                   	pop    %ebp
  8008e2:	c3                   	ret    

008008e3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ed:	eb 07                	jmp    8008f6 <strchr+0x13>
		if (*s == c)
  8008ef:	38 ca                	cmp    %cl,%dl
  8008f1:	74 0f                	je     800902 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	0f b6 10             	movzbl (%eax),%edx
  8008f9:	84 d2                	test   %dl,%dl
  8008fb:	75 f2                	jne    8008ef <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	8b 45 08             	mov    0x8(%ebp),%eax
  80090a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090e:	eb 03                	jmp    800913 <strfind+0xf>
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800916:	38 ca                	cmp    %cl,%dl
  800918:	74 04                	je     80091e <strfind+0x1a>
  80091a:	84 d2                	test   %dl,%dl
  80091c:	75 f2                	jne    800910 <strfind+0xc>
			break;
	return (char *) s;
}
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	57                   	push   %edi
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	8b 7d 08             	mov    0x8(%ebp),%edi
  800929:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092c:	85 c9                	test   %ecx,%ecx
  80092e:	74 36                	je     800966 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800930:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800936:	75 28                	jne    800960 <memset+0x40>
  800938:	f6 c1 03             	test   $0x3,%cl
  80093b:	75 23                	jne    800960 <memset+0x40>
		c &= 0xFF;
  80093d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800941:	89 d3                	mov    %edx,%ebx
  800943:	c1 e3 08             	shl    $0x8,%ebx
  800946:	89 d6                	mov    %edx,%esi
  800948:	c1 e6 18             	shl    $0x18,%esi
  80094b:	89 d0                	mov    %edx,%eax
  80094d:	c1 e0 10             	shl    $0x10,%eax
  800950:	09 f0                	or     %esi,%eax
  800952:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800954:	89 d8                	mov    %ebx,%eax
  800956:	09 d0                	or     %edx,%eax
  800958:	c1 e9 02             	shr    $0x2,%ecx
  80095b:	fc                   	cld    
  80095c:	f3 ab                	rep stos %eax,%es:(%edi)
  80095e:	eb 06                	jmp    800966 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800960:	8b 45 0c             	mov    0xc(%ebp),%eax
  800963:	fc                   	cld    
  800964:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800966:	89 f8                	mov    %edi,%eax
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5f                   	pop    %edi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	57                   	push   %edi
  800971:	56                   	push   %esi
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 75 0c             	mov    0xc(%ebp),%esi
  800978:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097b:	39 c6                	cmp    %eax,%esi
  80097d:	73 35                	jae    8009b4 <memmove+0x47>
  80097f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800982:	39 d0                	cmp    %edx,%eax
  800984:	73 2e                	jae    8009b4 <memmove+0x47>
		s += n;
		d += n;
  800986:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800989:	89 d6                	mov    %edx,%esi
  80098b:	09 fe                	or     %edi,%esi
  80098d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800993:	75 13                	jne    8009a8 <memmove+0x3b>
  800995:	f6 c1 03             	test   $0x3,%cl
  800998:	75 0e                	jne    8009a8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80099a:	83 ef 04             	sub    $0x4,%edi
  80099d:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a0:	c1 e9 02             	shr    $0x2,%ecx
  8009a3:	fd                   	std    
  8009a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a6:	eb 09                	jmp    8009b1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a8:	83 ef 01             	sub    $0x1,%edi
  8009ab:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ae:	fd                   	std    
  8009af:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b1:	fc                   	cld    
  8009b2:	eb 1d                	jmp    8009d1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b4:	89 f2                	mov    %esi,%edx
  8009b6:	09 c2                	or     %eax,%edx
  8009b8:	f6 c2 03             	test   $0x3,%dl
  8009bb:	75 0f                	jne    8009cc <memmove+0x5f>
  8009bd:	f6 c1 03             	test   $0x3,%cl
  8009c0:	75 0a                	jne    8009cc <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009c2:	c1 e9 02             	shr    $0x2,%ecx
  8009c5:	89 c7                	mov    %eax,%edi
  8009c7:	fc                   	cld    
  8009c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ca:	eb 05                	jmp    8009d1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009cc:	89 c7                	mov    %eax,%edi
  8009ce:	fc                   	cld    
  8009cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d1:	5e                   	pop    %esi
  8009d2:	5f                   	pop    %edi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d8:	ff 75 10             	pushl  0x10(%ebp)
  8009db:	ff 75 0c             	pushl  0xc(%ebp)
  8009de:	ff 75 08             	pushl  0x8(%ebp)
  8009e1:	e8 87 ff ff ff       	call   80096d <memmove>
}
  8009e6:	c9                   	leave  
  8009e7:	c3                   	ret    

008009e8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f3:	89 c6                	mov    %eax,%esi
  8009f5:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f8:	eb 1a                	jmp    800a14 <memcmp+0x2c>
		if (*s1 != *s2)
  8009fa:	0f b6 08             	movzbl (%eax),%ecx
  8009fd:	0f b6 1a             	movzbl (%edx),%ebx
  800a00:	38 d9                	cmp    %bl,%cl
  800a02:	74 0a                	je     800a0e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a04:	0f b6 c1             	movzbl %cl,%eax
  800a07:	0f b6 db             	movzbl %bl,%ebx
  800a0a:	29 d8                	sub    %ebx,%eax
  800a0c:	eb 0f                	jmp    800a1d <memcmp+0x35>
		s1++, s2++;
  800a0e:	83 c0 01             	add    $0x1,%eax
  800a11:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a14:	39 f0                	cmp    %esi,%eax
  800a16:	75 e2                	jne    8009fa <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	53                   	push   %ebx
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a28:	89 c1                	mov    %eax,%ecx
  800a2a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a31:	eb 0a                	jmp    800a3d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a33:	0f b6 10             	movzbl (%eax),%edx
  800a36:	39 da                	cmp    %ebx,%edx
  800a38:	74 07                	je     800a41 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	39 c8                	cmp    %ecx,%eax
  800a3f:	72 f2                	jb     800a33 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a41:	5b                   	pop    %ebx
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
  800a4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a50:	eb 03                	jmp    800a55 <strtol+0x11>
		s++;
  800a52:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a55:	0f b6 01             	movzbl (%ecx),%eax
  800a58:	3c 20                	cmp    $0x20,%al
  800a5a:	74 f6                	je     800a52 <strtol+0xe>
  800a5c:	3c 09                	cmp    $0x9,%al
  800a5e:	74 f2                	je     800a52 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a60:	3c 2b                	cmp    $0x2b,%al
  800a62:	75 0a                	jne    800a6e <strtol+0x2a>
		s++;
  800a64:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a67:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6c:	eb 11                	jmp    800a7f <strtol+0x3b>
  800a6e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a73:	3c 2d                	cmp    $0x2d,%al
  800a75:	75 08                	jne    800a7f <strtol+0x3b>
		s++, neg = 1;
  800a77:	83 c1 01             	add    $0x1,%ecx
  800a7a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a85:	75 15                	jne    800a9c <strtol+0x58>
  800a87:	80 39 30             	cmpb   $0x30,(%ecx)
  800a8a:	75 10                	jne    800a9c <strtol+0x58>
  800a8c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a90:	75 7c                	jne    800b0e <strtol+0xca>
		s += 2, base = 16;
  800a92:	83 c1 02             	add    $0x2,%ecx
  800a95:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a9a:	eb 16                	jmp    800ab2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a9c:	85 db                	test   %ebx,%ebx
  800a9e:	75 12                	jne    800ab2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa5:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa8:	75 08                	jne    800ab2 <strtol+0x6e>
		s++, base = 8;
  800aaa:	83 c1 01             	add    $0x1,%ecx
  800aad:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ab2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aba:	0f b6 11             	movzbl (%ecx),%edx
  800abd:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ac0:	89 f3                	mov    %esi,%ebx
  800ac2:	80 fb 09             	cmp    $0x9,%bl
  800ac5:	77 08                	ja     800acf <strtol+0x8b>
			dig = *s - '0';
  800ac7:	0f be d2             	movsbl %dl,%edx
  800aca:	83 ea 30             	sub    $0x30,%edx
  800acd:	eb 22                	jmp    800af1 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800acf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ad2:	89 f3                	mov    %esi,%ebx
  800ad4:	80 fb 19             	cmp    $0x19,%bl
  800ad7:	77 08                	ja     800ae1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad9:	0f be d2             	movsbl %dl,%edx
  800adc:	83 ea 57             	sub    $0x57,%edx
  800adf:	eb 10                	jmp    800af1 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ae1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae4:	89 f3                	mov    %esi,%ebx
  800ae6:	80 fb 19             	cmp    $0x19,%bl
  800ae9:	77 16                	ja     800b01 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aeb:	0f be d2             	movsbl %dl,%edx
  800aee:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800af1:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af4:	7d 0b                	jge    800b01 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af6:	83 c1 01             	add    $0x1,%ecx
  800af9:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afd:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800aff:	eb b9                	jmp    800aba <strtol+0x76>

	if (endptr)
  800b01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b05:	74 0d                	je     800b14 <strtol+0xd0>
		*endptr = (char *) s;
  800b07:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0a:	89 0e                	mov    %ecx,(%esi)
  800b0c:	eb 06                	jmp    800b14 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0e:	85 db                	test   %ebx,%ebx
  800b10:	74 98                	je     800aaa <strtol+0x66>
  800b12:	eb 9e                	jmp    800ab2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b14:	89 c2                	mov    %eax,%edx
  800b16:	f7 da                	neg    %edx
  800b18:	85 ff                	test   %edi,%edi
  800b1a:	0f 45 c2             	cmovne %edx,%eax
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b28:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b30:	8b 55 08             	mov    0x8(%ebp),%edx
  800b33:	89 c3                	mov    %eax,%ebx
  800b35:	89 c7                	mov    %eax,%edi
  800b37:	89 c6                	mov    %eax,%esi
  800b39:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5e                   	pop    %esi
  800b3d:	5f                   	pop    %edi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    

00800b40 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b46:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b50:	89 d1                	mov    %edx,%ecx
  800b52:	89 d3                	mov    %edx,%ebx
  800b54:	89 d7                	mov    %edx,%edi
  800b56:	89 d6                	mov    %edx,%esi
  800b58:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6d:	b8 03 00 00 00       	mov    $0x3,%eax
  800b72:	8b 55 08             	mov    0x8(%ebp),%edx
  800b75:	89 cb                	mov    %ecx,%ebx
  800b77:	89 cf                	mov    %ecx,%edi
  800b79:	89 ce                	mov    %ecx,%esi
  800b7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	7e 17                	jle    800b98 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	50                   	push   %eax
  800b85:	6a 03                	push   $0x3
  800b87:	68 54 11 80 00       	push   $0x801154
  800b8c:	6a 23                	push   $0x23
  800b8e:	68 71 11 80 00       	push   $0x801171
  800b93:	e8 9f f5 ff ff       	call   800137 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
  800ba6:	83 ec 14             	sub    $0x14,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  800bae:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb3:	89 d1                	mov    %edx,%ecx
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	89 d7                	mov    %edx,%edi
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	cd 30                	int    $0x30
  800bbd:	89 c3                	mov    %eax,%ebx

envid_t
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	cprintf("lib/syscall.c: %x\n", ret);
  800bbf:	50                   	push   %eax
  800bc0:	68 7f 11 80 00       	push   $0x80117f
  800bc5:	e8 46 f6 ff ff       	call   800210 <cprintf>
	return ret;
}
  800bca:	89 d8                	mov    %ebx,%eax
  800bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcf:	5b                   	pop    %ebx
  800bd0:	5e                   	pop    %esi
  800bd1:	5f                   	pop    %edi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    
  800bd4:	66 90                	xchg   %ax,%ax
  800bd6:	66 90                	xchg   %ax,%ax
  800bd8:	66 90                	xchg   %ax,%ax
  800bda:	66 90                	xchg   %ax,%ax
  800bdc:	66 90                	xchg   %ax,%ax
  800bde:	66 90                	xchg   %ax,%ax

00800be0 <__udivdi3>:
  800be0:	55                   	push   %ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 1c             	sub    $0x1c,%esp
  800be7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800beb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800bef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800bf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800bf7:	85 f6                	test   %esi,%esi
  800bf9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800bfd:	89 ca                	mov    %ecx,%edx
  800bff:	89 f8                	mov    %edi,%eax
  800c01:	75 3d                	jne    800c40 <__udivdi3+0x60>
  800c03:	39 cf                	cmp    %ecx,%edi
  800c05:	0f 87 c5 00 00 00    	ja     800cd0 <__udivdi3+0xf0>
  800c0b:	85 ff                	test   %edi,%edi
  800c0d:	89 fd                	mov    %edi,%ebp
  800c0f:	75 0b                	jne    800c1c <__udivdi3+0x3c>
  800c11:	b8 01 00 00 00       	mov    $0x1,%eax
  800c16:	31 d2                	xor    %edx,%edx
  800c18:	f7 f7                	div    %edi
  800c1a:	89 c5                	mov    %eax,%ebp
  800c1c:	89 c8                	mov    %ecx,%eax
  800c1e:	31 d2                	xor    %edx,%edx
  800c20:	f7 f5                	div    %ebp
  800c22:	89 c1                	mov    %eax,%ecx
  800c24:	89 d8                	mov    %ebx,%eax
  800c26:	89 cf                	mov    %ecx,%edi
  800c28:	f7 f5                	div    %ebp
  800c2a:	89 c3                	mov    %eax,%ebx
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
  800c40:	39 ce                	cmp    %ecx,%esi
  800c42:	77 74                	ja     800cb8 <__udivdi3+0xd8>
  800c44:	0f bd fe             	bsr    %esi,%edi
  800c47:	83 f7 1f             	xor    $0x1f,%edi
  800c4a:	0f 84 98 00 00 00    	je     800ce8 <__udivdi3+0x108>
  800c50:	bb 20 00 00 00       	mov    $0x20,%ebx
  800c55:	89 f9                	mov    %edi,%ecx
  800c57:	89 c5                	mov    %eax,%ebp
  800c59:	29 fb                	sub    %edi,%ebx
  800c5b:	d3 e6                	shl    %cl,%esi
  800c5d:	89 d9                	mov    %ebx,%ecx
  800c5f:	d3 ed                	shr    %cl,%ebp
  800c61:	89 f9                	mov    %edi,%ecx
  800c63:	d3 e0                	shl    %cl,%eax
  800c65:	09 ee                	or     %ebp,%esi
  800c67:	89 d9                	mov    %ebx,%ecx
  800c69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c6d:	89 d5                	mov    %edx,%ebp
  800c6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800c73:	d3 ed                	shr    %cl,%ebp
  800c75:	89 f9                	mov    %edi,%ecx
  800c77:	d3 e2                	shl    %cl,%edx
  800c79:	89 d9                	mov    %ebx,%ecx
  800c7b:	d3 e8                	shr    %cl,%eax
  800c7d:	09 c2                	or     %eax,%edx
  800c7f:	89 d0                	mov    %edx,%eax
  800c81:	89 ea                	mov    %ebp,%edx
  800c83:	f7 f6                	div    %esi
  800c85:	89 d5                	mov    %edx,%ebp
  800c87:	89 c3                	mov    %eax,%ebx
  800c89:	f7 64 24 0c          	mull   0xc(%esp)
  800c8d:	39 d5                	cmp    %edx,%ebp
  800c8f:	72 10                	jb     800ca1 <__udivdi3+0xc1>
  800c91:	8b 74 24 08          	mov    0x8(%esp),%esi
  800c95:	89 f9                	mov    %edi,%ecx
  800c97:	d3 e6                	shl    %cl,%esi
  800c99:	39 c6                	cmp    %eax,%esi
  800c9b:	73 07                	jae    800ca4 <__udivdi3+0xc4>
  800c9d:	39 d5                	cmp    %edx,%ebp
  800c9f:	75 03                	jne    800ca4 <__udivdi3+0xc4>
  800ca1:	83 eb 01             	sub    $0x1,%ebx
  800ca4:	31 ff                	xor    %edi,%edi
  800ca6:	89 d8                	mov    %ebx,%eax
  800ca8:	89 fa                	mov    %edi,%edx
  800caa:	83 c4 1c             	add    $0x1c,%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    
  800cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cb8:	31 ff                	xor    %edi,%edi
  800cba:	31 db                	xor    %ebx,%ebx
  800cbc:	89 d8                	mov    %ebx,%eax
  800cbe:	89 fa                	mov    %edi,%edx
  800cc0:	83 c4 1c             	add    $0x1c,%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    
  800cc8:	90                   	nop
  800cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	89 d8                	mov    %ebx,%eax
  800cd2:	f7 f7                	div    %edi
  800cd4:	31 ff                	xor    %edi,%edi
  800cd6:	89 c3                	mov    %eax,%ebx
  800cd8:	89 d8                	mov    %ebx,%eax
  800cda:	89 fa                	mov    %edi,%edx
  800cdc:	83 c4 1c             	add    $0x1c,%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    
  800ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ce8:	39 ce                	cmp    %ecx,%esi
  800cea:	72 0c                	jb     800cf8 <__udivdi3+0x118>
  800cec:	31 db                	xor    %ebx,%ebx
  800cee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800cf2:	0f 87 34 ff ff ff    	ja     800c2c <__udivdi3+0x4c>
  800cf8:	bb 01 00 00 00       	mov    $0x1,%ebx
  800cfd:	e9 2a ff ff ff       	jmp    800c2c <__udivdi3+0x4c>
  800d02:	66 90                	xchg   %ax,%ax
  800d04:	66 90                	xchg   %ax,%ax
  800d06:	66 90                	xchg   %ax,%ax
  800d08:	66 90                	xchg   %ax,%ax
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

00800d10 <__umoddi3>:
  800d10:	55                   	push   %ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 1c             	sub    $0x1c,%esp
  800d17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d1b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800d1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d27:	85 d2                	test   %edx,%edx
  800d29:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800d31:	89 f3                	mov    %esi,%ebx
  800d33:	89 3c 24             	mov    %edi,(%esp)
  800d36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d3a:	75 1c                	jne    800d58 <__umoddi3+0x48>
  800d3c:	39 f7                	cmp    %esi,%edi
  800d3e:	76 50                	jbe    800d90 <__umoddi3+0x80>
  800d40:	89 c8                	mov    %ecx,%eax
  800d42:	89 f2                	mov    %esi,%edx
  800d44:	f7 f7                	div    %edi
  800d46:	89 d0                	mov    %edx,%eax
  800d48:	31 d2                	xor    %edx,%edx
  800d4a:	83 c4 1c             	add    $0x1c,%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
  800d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d58:	39 f2                	cmp    %esi,%edx
  800d5a:	89 d0                	mov    %edx,%eax
  800d5c:	77 52                	ja     800db0 <__umoddi3+0xa0>
  800d5e:	0f bd ea             	bsr    %edx,%ebp
  800d61:	83 f5 1f             	xor    $0x1f,%ebp
  800d64:	75 5a                	jne    800dc0 <__umoddi3+0xb0>
  800d66:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800d6a:	0f 82 e0 00 00 00    	jb     800e50 <__umoddi3+0x140>
  800d70:	39 0c 24             	cmp    %ecx,(%esp)
  800d73:	0f 86 d7 00 00 00    	jbe    800e50 <__umoddi3+0x140>
  800d79:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d7d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800d81:	83 c4 1c             	add    $0x1c,%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	85 ff                	test   %edi,%edi
  800d92:	89 fd                	mov    %edi,%ebp
  800d94:	75 0b                	jne    800da1 <__umoddi3+0x91>
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	f7 f7                	div    %edi
  800d9f:	89 c5                	mov    %eax,%ebp
  800da1:	89 f0                	mov    %esi,%eax
  800da3:	31 d2                	xor    %edx,%edx
  800da5:	f7 f5                	div    %ebp
  800da7:	89 c8                	mov    %ecx,%eax
  800da9:	f7 f5                	div    %ebp
  800dab:	89 d0                	mov    %edx,%eax
  800dad:	eb 99                	jmp    800d48 <__umoddi3+0x38>
  800daf:	90                   	nop
  800db0:	89 c8                	mov    %ecx,%eax
  800db2:	89 f2                	mov    %esi,%edx
  800db4:	83 c4 1c             	add    $0x1c,%esp
  800db7:	5b                   	pop    %ebx
  800db8:	5e                   	pop    %esi
  800db9:	5f                   	pop    %edi
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    
  800dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	8b 34 24             	mov    (%esp),%esi
  800dc3:	bf 20 00 00 00       	mov    $0x20,%edi
  800dc8:	89 e9                	mov    %ebp,%ecx
  800dca:	29 ef                	sub    %ebp,%edi
  800dcc:	d3 e0                	shl    %cl,%eax
  800dce:	89 f9                	mov    %edi,%ecx
  800dd0:	89 f2                	mov    %esi,%edx
  800dd2:	d3 ea                	shr    %cl,%edx
  800dd4:	89 e9                	mov    %ebp,%ecx
  800dd6:	09 c2                	or     %eax,%edx
  800dd8:	89 d8                	mov    %ebx,%eax
  800dda:	89 14 24             	mov    %edx,(%esp)
  800ddd:	89 f2                	mov    %esi,%edx
  800ddf:	d3 e2                	shl    %cl,%edx
  800de1:	89 f9                	mov    %edi,%ecx
  800de3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800de7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800deb:	d3 e8                	shr    %cl,%eax
  800ded:	89 e9                	mov    %ebp,%ecx
  800def:	89 c6                	mov    %eax,%esi
  800df1:	d3 e3                	shl    %cl,%ebx
  800df3:	89 f9                	mov    %edi,%ecx
  800df5:	89 d0                	mov    %edx,%eax
  800df7:	d3 e8                	shr    %cl,%eax
  800df9:	89 e9                	mov    %ebp,%ecx
  800dfb:	09 d8                	or     %ebx,%eax
  800dfd:	89 d3                	mov    %edx,%ebx
  800dff:	89 f2                	mov    %esi,%edx
  800e01:	f7 34 24             	divl   (%esp)
  800e04:	89 d6                	mov    %edx,%esi
  800e06:	d3 e3                	shl    %cl,%ebx
  800e08:	f7 64 24 04          	mull   0x4(%esp)
  800e0c:	39 d6                	cmp    %edx,%esi
  800e0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e12:	89 d1                	mov    %edx,%ecx
  800e14:	89 c3                	mov    %eax,%ebx
  800e16:	72 08                	jb     800e20 <__umoddi3+0x110>
  800e18:	75 11                	jne    800e2b <__umoddi3+0x11b>
  800e1a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800e1e:	73 0b                	jae    800e2b <__umoddi3+0x11b>
  800e20:	2b 44 24 04          	sub    0x4(%esp),%eax
  800e24:	1b 14 24             	sbb    (%esp),%edx
  800e27:	89 d1                	mov    %edx,%ecx
  800e29:	89 c3                	mov    %eax,%ebx
  800e2b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800e2f:	29 da                	sub    %ebx,%edx
  800e31:	19 ce                	sbb    %ecx,%esi
  800e33:	89 f9                	mov    %edi,%ecx
  800e35:	89 f0                	mov    %esi,%eax
  800e37:	d3 e0                	shl    %cl,%eax
  800e39:	89 e9                	mov    %ebp,%ecx
  800e3b:	d3 ea                	shr    %cl,%edx
  800e3d:	89 e9                	mov    %ebp,%ecx
  800e3f:	d3 ee                	shr    %cl,%esi
  800e41:	09 d0                	or     %edx,%eax
  800e43:	89 f2                	mov    %esi,%edx
  800e45:	83 c4 1c             	add    $0x1c,%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    
  800e4d:	8d 76 00             	lea    0x0(%esi),%esi
  800e50:	29 f9                	sub    %edi,%ecx
  800e52:	19 d6                	sbb    %edx,%esi
  800e54:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e5c:	e9 18 ff ff ff       	jmp    800d79 <__umoddi3+0x69>
