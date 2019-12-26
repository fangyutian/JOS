
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
  800039:	68 a0 10 80 00       	push   $0x8010a0
  80003e:	e8 12 02 00 00       	call   800255 <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	74 12                	je     800067 <umain+0x34>
			panic("bigarray[%d] isn't cleared!\n", i);
  800055:	50                   	push   %eax
  800056:	68 1b 11 80 00       	push   $0x80111b
  80005b:	6a 11                	push   $0x11
  80005d:	68 38 11 80 00       	push   $0x801138
  800062:	e8 15 01 00 00       	call   80017c <_panic>
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
  800096:	68 c0 10 80 00       	push   $0x8010c0
  80009b:	6a 16                	push   $0x16
  80009d:	68 38 11 80 00       	push   $0x801138
  8000a2:	e8 d5 00 00 00       	call   80017c <_panic>
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
  8000b4:	68 e8 10 80 00       	push   $0x8010e8
  8000b9:	e8 97 01 00 00       	call   800255 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000be:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000c5:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000c8:	83 c4 0c             	add    $0xc,%esp
  8000cb:	68 47 11 80 00       	push   $0x801147
  8000d0:	6a 1a                	push   $0x1a
  8000d2:	68 38 11 80 00       	push   $0x801138
  8000d7:	e8 a0 00 00 00       	call   80017c <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
  8000e2:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000e5:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  8000ec:	00 00 00 
	envid_t eid = sys_getenvid();
  8000ef:	e8 2a 0b 00 00       	call   800c1e <sys_getenvid>
  8000f4:	8b 3d 20 20 c0 00    	mov    0xc02020,%edi
  8000fa:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8000ff:	be 00 00 00 00       	mov    $0x0,%esi
	int i;
	for (i = 0; i < NENV; i++) {
  800104:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == eid) {
  800109:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80010c:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800112:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &(envs[i]);
  800115:	39 c8                	cmp    %ecx,%eax
  800117:	0f 44 fb             	cmove  %ebx,%edi
  80011a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80011f:	0f 44 f1             	cmove  %ecx,%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
	envid_t eid = sys_getenvid();
	int i;
	for (i = 0; i < NENV; i++) {
  800122:	83 c2 01             	add    $0x1,%edx
  800125:	83 c3 7c             	add    $0x7c,%ebx
  800128:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80012e:	75 d9                	jne    800109 <libmain+0x2d>
  800130:	89 f0                	mov    %esi,%eax
  800132:	84 c0                	test   %al,%al
  800134:	74 06                	je     80013c <libmain+0x60>
  800136:	89 3d 20 20 c0 00    	mov    %edi,0xc02020
			thisenv = &(envs[i]);
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80013c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800140:	7e 0a                	jle    80014c <libmain+0x70>
		binaryname = argv[0];
  800142:	8b 45 0c             	mov    0xc(%ebp),%eax
  800145:	8b 00                	mov    (%eax),%eax
  800147:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80014c:	83 ec 08             	sub    $0x8,%esp
  80014f:	ff 75 0c             	pushl  0xc(%ebp)
  800152:	ff 75 08             	pushl  0x8(%ebp)
  800155:	e8 d9 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80015a:	e8 0b 00 00 00       	call   80016a <exit>
}
  80015f:	83 c4 10             	add    $0x10,%esp
  800162:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800170:	6a 00                	push   $0x0
  800172:	e8 66 0a 00 00       	call   800bdd <sys_env_destroy>
}
  800177:	83 c4 10             	add    $0x10,%esp
  80017a:	c9                   	leave  
  80017b:	c3                   	ret    

0080017c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	56                   	push   %esi
  800180:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800181:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800184:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80018a:	e8 8f 0a 00 00       	call   800c1e <sys_getenvid>
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	ff 75 0c             	pushl  0xc(%ebp)
  800195:	ff 75 08             	pushl  0x8(%ebp)
  800198:	56                   	push   %esi
  800199:	50                   	push   %eax
  80019a:	68 68 11 80 00       	push   $0x801168
  80019f:	e8 b1 00 00 00       	call   800255 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001a4:	83 c4 18             	add    $0x18,%esp
  8001a7:	53                   	push   %ebx
  8001a8:	ff 75 10             	pushl  0x10(%ebp)
  8001ab:	e8 54 00 00 00       	call   800204 <vcprintf>
	cprintf("\n");
  8001b0:	c7 04 24 36 11 80 00 	movl   $0x801136,(%esp)
  8001b7:	e8 99 00 00 00       	call   800255 <cprintf>
  8001bc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001bf:	cc                   	int3   
  8001c0:	eb fd                	jmp    8001bf <_panic+0x43>

008001c2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 04             	sub    $0x4,%esp
  8001c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001cc:	8b 13                	mov    (%ebx),%edx
  8001ce:	8d 42 01             	lea    0x1(%edx),%eax
  8001d1:	89 03                	mov    %eax,(%ebx)
  8001d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001df:	75 1a                	jne    8001fb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001e1:	83 ec 08             	sub    $0x8,%esp
  8001e4:	68 ff 00 00 00       	push   $0xff
  8001e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ec:	50                   	push   %eax
  8001ed:	e8 ae 09 00 00       	call   800ba0 <sys_cputs>
		b->idx = 0;
  8001f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001f8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001fb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80020d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800214:	00 00 00 
	b.cnt = 0;
  800217:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80021e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800221:	ff 75 0c             	pushl  0xc(%ebp)
  800224:	ff 75 08             	pushl  0x8(%ebp)
  800227:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022d:	50                   	push   %eax
  80022e:	68 c2 01 80 00       	push   $0x8001c2
  800233:	e8 1a 01 00 00       	call   800352 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800238:	83 c4 08             	add    $0x8,%esp
  80023b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800241:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800247:	50                   	push   %eax
  800248:	e8 53 09 00 00       	call   800ba0 <sys_cputs>

	return b.cnt;
}
  80024d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800253:	c9                   	leave  
  800254:	c3                   	ret    

00800255 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800255:	55                   	push   %ebp
  800256:	89 e5                	mov    %esp,%ebp
  800258:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80025b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80025e:	50                   	push   %eax
  80025f:	ff 75 08             	pushl  0x8(%ebp)
  800262:	e8 9d ff ff ff       	call   800204 <vcprintf>
	va_end(ap);

	return cnt;
}
  800267:	c9                   	leave  
  800268:	c3                   	ret    

00800269 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	57                   	push   %edi
  80026d:	56                   	push   %esi
  80026e:	53                   	push   %ebx
  80026f:	83 ec 1c             	sub    $0x1c,%esp
  800272:	89 c7                	mov    %eax,%edi
  800274:	89 d6                	mov    %edx,%esi
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80027f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800282:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800285:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80028d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800290:	39 d3                	cmp    %edx,%ebx
  800292:	72 05                	jb     800299 <printnum+0x30>
  800294:	39 45 10             	cmp    %eax,0x10(%ebp)
  800297:	77 45                	ja     8002de <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800299:	83 ec 0c             	sub    $0xc,%esp
  80029c:	ff 75 18             	pushl  0x18(%ebp)
  80029f:	8b 45 14             	mov    0x14(%ebp),%eax
  8002a2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002a5:	53                   	push   %ebx
  8002a6:	ff 75 10             	pushl  0x10(%ebp)
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002af:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b8:	e8 53 0b 00 00       	call   800e10 <__udivdi3>
  8002bd:	83 c4 18             	add    $0x18,%esp
  8002c0:	52                   	push   %edx
  8002c1:	50                   	push   %eax
  8002c2:	89 f2                	mov    %esi,%edx
  8002c4:	89 f8                	mov    %edi,%eax
  8002c6:	e8 9e ff ff ff       	call   800269 <printnum>
  8002cb:	83 c4 20             	add    $0x20,%esp
  8002ce:	eb 18                	jmp    8002e8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d0:	83 ec 08             	sub    $0x8,%esp
  8002d3:	56                   	push   %esi
  8002d4:	ff 75 18             	pushl  0x18(%ebp)
  8002d7:	ff d7                	call   *%edi
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	eb 03                	jmp    8002e1 <printnum+0x78>
  8002de:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e1:	83 eb 01             	sub    $0x1,%ebx
  8002e4:	85 db                	test   %ebx,%ebx
  8002e6:	7f e8                	jg     8002d0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e8:	83 ec 08             	sub    $0x8,%esp
  8002eb:	56                   	push   %esi
  8002ec:	83 ec 04             	sub    $0x4,%esp
  8002ef:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8002f5:	ff 75 dc             	pushl  -0x24(%ebp)
  8002f8:	ff 75 d8             	pushl  -0x28(%ebp)
  8002fb:	e8 40 0c 00 00       	call   800f40 <__umoddi3>
  800300:	83 c4 14             	add    $0x14,%esp
  800303:	0f be 80 8c 11 80 00 	movsbl 0x80118c(%eax),%eax
  80030a:	50                   	push   %eax
  80030b:	ff d7                	call   *%edi
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80031e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800322:	8b 10                	mov    (%eax),%edx
  800324:	3b 50 04             	cmp    0x4(%eax),%edx
  800327:	73 0a                	jae    800333 <sprintputch+0x1b>
		*b->buf++ = ch;
  800329:	8d 4a 01             	lea    0x1(%edx),%ecx
  80032c:	89 08                	mov    %ecx,(%eax)
  80032e:	8b 45 08             	mov    0x8(%ebp),%eax
  800331:	88 02                	mov    %al,(%edx)
}
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    

00800335 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80033b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80033e:	50                   	push   %eax
  80033f:	ff 75 10             	pushl  0x10(%ebp)
  800342:	ff 75 0c             	pushl  0xc(%ebp)
  800345:	ff 75 08             	pushl  0x8(%ebp)
  800348:	e8 05 00 00 00       	call   800352 <vprintfmt>
	va_end(ap);
}
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	c9                   	leave  
  800351:	c3                   	ret    

00800352 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	57                   	push   %edi
  800356:	56                   	push   %esi
  800357:	53                   	push   %ebx
  800358:	83 ec 2c             	sub    $0x2c,%esp
  80035b:	8b 75 08             	mov    0x8(%ebp),%esi
  80035e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800361:	8b 7d 10             	mov    0x10(%ebp),%edi
  800364:	eb 12                	jmp    800378 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800366:	85 c0                	test   %eax,%eax
  800368:	0f 84 42 04 00 00    	je     8007b0 <vprintfmt+0x45e>
				return;
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
  800382:	75 e2                	jne    800366 <vprintfmt+0x14>
  800384:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800388:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80038f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800396:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80039d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a2:	eb 07                	jmp    8003ab <vprintfmt+0x59>
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
  8003b4:	0f b6 d0             	movzbl %al,%edx
  8003b7:	83 e8 23             	sub    $0x23,%eax
  8003ba:	3c 55                	cmp    $0x55,%al
  8003bc:	0f 87 d3 03 00 00    	ja     800795 <vprintfmt+0x443>
  8003c2:	0f b6 c0             	movzbl %al,%eax
  8003c5:	ff 24 85 60 12 80 00 	jmp    *0x801260(,%eax,4)
  8003cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003cf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003d3:	eb d6                	jmp    8003ab <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003e0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003e3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003e7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003ea:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003ed:	83 f9 09             	cmp    $0x9,%ecx
  8003f0:	77 3f                	ja     800431 <vprintfmt+0xdf>
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
  8003f5:	eb e9                	jmp    8003e0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 40 04             	lea    0x4(%eax),%eax
  800405:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80040b:	eb 2a                	jmp    800437 <vprintfmt+0xe5>
  80040d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800410:	85 c0                	test   %eax,%eax
  800412:	ba 00 00 00 00       	mov    $0x0,%edx
  800417:	0f 49 d0             	cmovns %eax,%edx
  80041a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800420:	eb 89                	jmp    8003ab <vprintfmt+0x59>
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800425:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80042c:	e9 7a ff ff ff       	jmp    8003ab <vprintfmt+0x59>
  800431:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800434:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800437:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043b:	0f 89 6a ff ff ff    	jns    8003ab <vprintfmt+0x59>
				width = precision, precision = -1;
  800441:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800444:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800447:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80044e:	e9 58 ff ff ff       	jmp    8003ab <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800453:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800459:	e9 4d ff ff ff       	jmp    8003ab <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045e:	8b 45 14             	mov    0x14(%ebp),%eax
  800461:	8d 78 04             	lea    0x4(%eax),%edi
  800464:	83 ec 08             	sub    $0x8,%esp
  800467:	53                   	push   %ebx
  800468:	ff 30                	pushl  (%eax)
  80046a:	ff d6                	call   *%esi
			break;
  80046c:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800475:	e9 fe fe ff ff       	jmp    800378 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	8d 78 04             	lea    0x4(%eax),%edi
  800480:	8b 00                	mov    (%eax),%eax
  800482:	99                   	cltd   
  800483:	31 d0                	xor    %edx,%eax
  800485:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800487:	83 f8 08             	cmp    $0x8,%eax
  80048a:	7f 0b                	jg     800497 <vprintfmt+0x145>
  80048c:	8b 14 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%edx
  800493:	85 d2                	test   %edx,%edx
  800495:	75 1b                	jne    8004b2 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800497:	50                   	push   %eax
  800498:	68 a4 11 80 00       	push   $0x8011a4
  80049d:	53                   	push   %ebx
  80049e:	56                   	push   %esi
  80049f:	e8 91 fe ff ff       	call   800335 <printfmt>
  8004a4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004a7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ad:	e9 c6 fe ff ff       	jmp    800378 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004b2:	52                   	push   %edx
  8004b3:	68 ad 11 80 00       	push   $0x8011ad
  8004b8:	53                   	push   %ebx
  8004b9:	56                   	push   %esi
  8004ba:	e8 76 fe ff ff       	call   800335 <printfmt>
  8004bf:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004c2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c8:	e9 ab fe ff ff       	jmp    800378 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d0:	83 c0 04             	add    $0x4,%eax
  8004d3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004db:	85 ff                	test   %edi,%edi
  8004dd:	b8 9d 11 80 00       	mov    $0x80119d,%eax
  8004e2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e9:	0f 8e 94 00 00 00    	jle    800583 <vprintfmt+0x231>
  8004ef:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f3:	0f 84 98 00 00 00    	je     800591 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f9:	83 ec 08             	sub    $0x8,%esp
  8004fc:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ff:	57                   	push   %edi
  800500:	e8 33 03 00 00       	call   800838 <strnlen>
  800505:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800508:	29 c1                	sub    %eax,%ecx
  80050a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80050d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800510:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800514:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800517:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051c:	eb 0f                	jmp    80052d <vprintfmt+0x1db>
					putch(padc, putdat);
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	53                   	push   %ebx
  800522:	ff 75 e0             	pushl  -0x20(%ebp)
  800525:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800527:	83 ef 01             	sub    $0x1,%edi
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	85 ff                	test   %edi,%edi
  80052f:	7f ed                	jg     80051e <vprintfmt+0x1cc>
  800531:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800534:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800537:	85 c9                	test   %ecx,%ecx
  800539:	b8 00 00 00 00       	mov    $0x0,%eax
  80053e:	0f 49 c1             	cmovns %ecx,%eax
  800541:	29 c1                	sub    %eax,%ecx
  800543:	89 75 08             	mov    %esi,0x8(%ebp)
  800546:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800549:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054c:	89 cb                	mov    %ecx,%ebx
  80054e:	eb 4d                	jmp    80059d <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800550:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800554:	74 1b                	je     800571 <vprintfmt+0x21f>
  800556:	0f be c0             	movsbl %al,%eax
  800559:	83 e8 20             	sub    $0x20,%eax
  80055c:	83 f8 5e             	cmp    $0x5e,%eax
  80055f:	76 10                	jbe    800571 <vprintfmt+0x21f>
					putch('?', putdat);
  800561:	83 ec 08             	sub    $0x8,%esp
  800564:	ff 75 0c             	pushl  0xc(%ebp)
  800567:	6a 3f                	push   $0x3f
  800569:	ff 55 08             	call   *0x8(%ebp)
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	eb 0d                	jmp    80057e <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	ff 75 0c             	pushl  0xc(%ebp)
  800577:	52                   	push   %edx
  800578:	ff 55 08             	call   *0x8(%ebp)
  80057b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057e:	83 eb 01             	sub    $0x1,%ebx
  800581:	eb 1a                	jmp    80059d <vprintfmt+0x24b>
  800583:	89 75 08             	mov    %esi,0x8(%ebp)
  800586:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800589:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058f:	eb 0c                	jmp    80059d <vprintfmt+0x24b>
  800591:	89 75 08             	mov    %esi,0x8(%ebp)
  800594:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800597:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059d:	83 c7 01             	add    $0x1,%edi
  8005a0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a4:	0f be d0             	movsbl %al,%edx
  8005a7:	85 d2                	test   %edx,%edx
  8005a9:	74 23                	je     8005ce <vprintfmt+0x27c>
  8005ab:	85 f6                	test   %esi,%esi
  8005ad:	78 a1                	js     800550 <vprintfmt+0x1fe>
  8005af:	83 ee 01             	sub    $0x1,%esi
  8005b2:	79 9c                	jns    800550 <vprintfmt+0x1fe>
  8005b4:	89 df                	mov    %ebx,%edi
  8005b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bc:	eb 18                	jmp    8005d6 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	6a 20                	push   $0x20
  8005c4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c6:	83 ef 01             	sub    $0x1,%edi
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	eb 08                	jmp    8005d6 <vprintfmt+0x284>
  8005ce:	89 df                	mov    %ebx,%edi
  8005d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d6:	85 ff                	test   %edi,%edi
  8005d8:	7f e4                	jg     8005be <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005da:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e3:	e9 90 fd ff ff       	jmp    800378 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e8:	83 f9 01             	cmp    $0x1,%ecx
  8005eb:	7e 19                	jle    800606 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 50 04             	mov    0x4(%eax),%edx
  8005f3:	8b 00                	mov    (%eax),%eax
  8005f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 40 08             	lea    0x8(%eax),%eax
  800601:	89 45 14             	mov    %eax,0x14(%ebp)
  800604:	eb 38                	jmp    80063e <vprintfmt+0x2ec>
	else if (lflag)
  800606:	85 c9                	test   %ecx,%ecx
  800608:	74 1b                	je     800625 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80060a:	8b 45 14             	mov    0x14(%ebp),%eax
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800612:	89 c1                	mov    %eax,%ecx
  800614:	c1 f9 1f             	sar    $0x1f,%ecx
  800617:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 40 04             	lea    0x4(%eax),%eax
  800620:	89 45 14             	mov    %eax,0x14(%ebp)
  800623:	eb 19                	jmp    80063e <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8b 00                	mov    (%eax),%eax
  80062a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062d:	89 c1                	mov    %eax,%ecx
  80062f:	c1 f9 1f             	sar    $0x1f,%ecx
  800632:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8d 40 04             	lea    0x4(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800641:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800644:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800649:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064d:	0f 89 0e 01 00 00    	jns    800761 <vprintfmt+0x40f>
				putch('-', putdat);
  800653:	83 ec 08             	sub    $0x8,%esp
  800656:	53                   	push   %ebx
  800657:	6a 2d                	push   $0x2d
  800659:	ff d6                	call   *%esi
				num = -(long long) num;
  80065b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80065e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800661:	f7 da                	neg    %edx
  800663:	83 d1 00             	adc    $0x0,%ecx
  800666:	f7 d9                	neg    %ecx
  800668:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80066b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800670:	e9 ec 00 00 00       	jmp    800761 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800675:	83 f9 01             	cmp    $0x1,%ecx
  800678:	7e 18                	jle    800692 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8b 10                	mov    (%eax),%edx
  80067f:	8b 48 04             	mov    0x4(%eax),%ecx
  800682:	8d 40 08             	lea    0x8(%eax),%eax
  800685:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800688:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068d:	e9 cf 00 00 00       	jmp    800761 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800692:	85 c9                	test   %ecx,%ecx
  800694:	74 1a                	je     8006b0 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8b 10                	mov    (%eax),%edx
  80069b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a0:	8d 40 04             	lea    0x4(%eax),%eax
  8006a3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ab:	e9 b1 00 00 00       	jmp    800761 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8b 10                	mov    (%eax),%edx
  8006b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ba:	8d 40 04             	lea    0x4(%eax),%eax
  8006bd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c5:	e9 97 00 00 00       	jmp    800761 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	53                   	push   %ebx
  8006ce:	6a 58                	push   $0x58
  8006d0:	ff d6                	call   *%esi
			putch('X', putdat);
  8006d2:	83 c4 08             	add    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	6a 58                	push   $0x58
  8006d8:	ff d6                	call   *%esi
			putch('X', putdat);
  8006da:	83 c4 08             	add    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	6a 58                	push   $0x58
  8006e0:	ff d6                	call   *%esi
			break;
  8006e2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006e8:	e9 8b fc ff ff       	jmp    800378 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	53                   	push   %ebx
  8006f1:	6a 30                	push   $0x30
  8006f3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006f5:	83 c4 08             	add    $0x8,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	6a 78                	push   $0x78
  8006fb:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8b 10                	mov    (%eax),%edx
  800702:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800707:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80070a:	8d 40 04             	lea    0x4(%eax),%eax
  80070d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800710:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800715:	eb 4a                	jmp    800761 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800717:	83 f9 01             	cmp    $0x1,%ecx
  80071a:	7e 15                	jle    800731 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 10                	mov    (%eax),%edx
  800721:	8b 48 04             	mov    0x4(%eax),%ecx
  800724:	8d 40 08             	lea    0x8(%eax),%eax
  800727:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80072a:	b8 10 00 00 00       	mov    $0x10,%eax
  80072f:	eb 30                	jmp    800761 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800731:	85 c9                	test   %ecx,%ecx
  800733:	74 17                	je     80074c <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800735:	8b 45 14             	mov    0x14(%ebp),%eax
  800738:	8b 10                	mov    (%eax),%edx
  80073a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073f:	8d 40 04             	lea    0x4(%eax),%eax
  800742:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800745:	b8 10 00 00 00       	mov    $0x10,%eax
  80074a:	eb 15                	jmp    800761 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8b 10                	mov    (%eax),%edx
  800751:	b9 00 00 00 00       	mov    $0x0,%ecx
  800756:	8d 40 04             	lea    0x4(%eax),%eax
  800759:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80075c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800761:	83 ec 0c             	sub    $0xc,%esp
  800764:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800768:	57                   	push   %edi
  800769:	ff 75 e0             	pushl  -0x20(%ebp)
  80076c:	50                   	push   %eax
  80076d:	51                   	push   %ecx
  80076e:	52                   	push   %edx
  80076f:	89 da                	mov    %ebx,%edx
  800771:	89 f0                	mov    %esi,%eax
  800773:	e8 f1 fa ff ff       	call   800269 <printnum>
			break;
  800778:	83 c4 20             	add    $0x20,%esp
  80077b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80077e:	e9 f5 fb ff ff       	jmp    800378 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800783:	83 ec 08             	sub    $0x8,%esp
  800786:	53                   	push   %ebx
  800787:	52                   	push   %edx
  800788:	ff d6                	call   *%esi
			break;
  80078a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800790:	e9 e3 fb ff ff       	jmp    800378 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800795:	83 ec 08             	sub    $0x8,%esp
  800798:	53                   	push   %ebx
  800799:	6a 25                	push   $0x25
  80079b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80079d:	83 c4 10             	add    $0x10,%esp
  8007a0:	eb 03                	jmp    8007a5 <vprintfmt+0x453>
  8007a2:	83 ef 01             	sub    $0x1,%edi
  8007a5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007a9:	75 f7                	jne    8007a2 <vprintfmt+0x450>
  8007ab:	e9 c8 fb ff ff       	jmp    800378 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b3:	5b                   	pop    %ebx
  8007b4:	5e                   	pop    %esi
  8007b5:	5f                   	pop    %edi
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	83 ec 18             	sub    $0x18,%esp
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007c7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007cb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	74 26                	je     8007ff <vsnprintf+0x47>
  8007d9:	85 d2                	test   %edx,%edx
  8007db:	7e 22                	jle    8007ff <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007dd:	ff 75 14             	pushl  0x14(%ebp)
  8007e0:	ff 75 10             	pushl  0x10(%ebp)
  8007e3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e6:	50                   	push   %eax
  8007e7:	68 18 03 80 00       	push   $0x800318
  8007ec:	e8 61 fb ff ff       	call   800352 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fa:	83 c4 10             	add    $0x10,%esp
  8007fd:	eb 05                	jmp    800804 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80080c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80080f:	50                   	push   %eax
  800810:	ff 75 10             	pushl  0x10(%ebp)
  800813:	ff 75 0c             	pushl  0xc(%ebp)
  800816:	ff 75 08             	pushl  0x8(%ebp)
  800819:	e8 9a ff ff ff       	call   8007b8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081e:	c9                   	leave  
  80081f:	c3                   	ret    

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	eb 03                	jmp    800830 <strlen+0x10>
		n++;
  80082d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800830:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800834:	75 f7                	jne    80082d <strlen+0xd>
		n++;
	return n;
}
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80083e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800841:	ba 00 00 00 00       	mov    $0x0,%edx
  800846:	eb 03                	jmp    80084b <strnlen+0x13>
		n++;
  800848:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80084b:	39 c2                	cmp    %eax,%edx
  80084d:	74 08                	je     800857 <strnlen+0x1f>
  80084f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800853:	75 f3                	jne    800848 <strnlen+0x10>
  800855:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800863:	89 c2                	mov    %eax,%edx
  800865:	83 c2 01             	add    $0x1,%edx
  800868:	83 c1 01             	add    $0x1,%ecx
  80086b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80086f:	88 5a ff             	mov    %bl,-0x1(%edx)
  800872:	84 db                	test   %bl,%bl
  800874:	75 ef                	jne    800865 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800876:	5b                   	pop    %ebx
  800877:	5d                   	pop    %ebp
  800878:	c3                   	ret    

00800879 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800880:	53                   	push   %ebx
  800881:	e8 9a ff ff ff       	call   800820 <strlen>
  800886:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800889:	ff 75 0c             	pushl  0xc(%ebp)
  80088c:	01 d8                	add    %ebx,%eax
  80088e:	50                   	push   %eax
  80088f:	e8 c5 ff ff ff       	call   800859 <strcpy>
	return dst;
}
  800894:	89 d8                	mov    %ebx,%eax
  800896:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800899:	c9                   	leave  
  80089a:	c3                   	ret    

0080089b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a6:	89 f3                	mov    %esi,%ebx
  8008a8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008ab:	89 f2                	mov    %esi,%edx
  8008ad:	eb 0f                	jmp    8008be <strncpy+0x23>
		*dst++ = *src;
  8008af:	83 c2 01             	add    $0x1,%edx
  8008b2:	0f b6 01             	movzbl (%ecx),%eax
  8008b5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b8:	80 39 01             	cmpb   $0x1,(%ecx)
  8008bb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008be:	39 da                	cmp    %ebx,%edx
  8008c0:	75 ed                	jne    8008af <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c2:	89 f0                	mov    %esi,%eax
  8008c4:	5b                   	pop    %ebx
  8008c5:	5e                   	pop    %esi
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	56                   	push   %esi
  8008cc:	53                   	push   %ebx
  8008cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8008d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d3:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d8:	85 d2                	test   %edx,%edx
  8008da:	74 21                	je     8008fd <strlcpy+0x35>
  8008dc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008e0:	89 f2                	mov    %esi,%edx
  8008e2:	eb 09                	jmp    8008ed <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e4:	83 c2 01             	add    $0x1,%edx
  8008e7:	83 c1 01             	add    $0x1,%ecx
  8008ea:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008ed:	39 c2                	cmp    %eax,%edx
  8008ef:	74 09                	je     8008fa <strlcpy+0x32>
  8008f1:	0f b6 19             	movzbl (%ecx),%ebx
  8008f4:	84 db                	test   %bl,%bl
  8008f6:	75 ec                	jne    8008e4 <strlcpy+0x1c>
  8008f8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008fa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008fd:	29 f0                	sub    %esi,%eax
}
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090c:	eb 06                	jmp    800914 <strcmp+0x11>
		p++, q++;
  80090e:	83 c1 01             	add    $0x1,%ecx
  800911:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800914:	0f b6 01             	movzbl (%ecx),%eax
  800917:	84 c0                	test   %al,%al
  800919:	74 04                	je     80091f <strcmp+0x1c>
  80091b:	3a 02                	cmp    (%edx),%al
  80091d:	74 ef                	je     80090e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80091f:	0f b6 c0             	movzbl %al,%eax
  800922:	0f b6 12             	movzbl (%edx),%edx
  800925:	29 d0                	sub    %edx,%eax
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	53                   	push   %ebx
  80092d:	8b 45 08             	mov    0x8(%ebp),%eax
  800930:	8b 55 0c             	mov    0xc(%ebp),%edx
  800933:	89 c3                	mov    %eax,%ebx
  800935:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800938:	eb 06                	jmp    800940 <strncmp+0x17>
		n--, p++, q++;
  80093a:	83 c0 01             	add    $0x1,%eax
  80093d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800940:	39 d8                	cmp    %ebx,%eax
  800942:	74 15                	je     800959 <strncmp+0x30>
  800944:	0f b6 08             	movzbl (%eax),%ecx
  800947:	84 c9                	test   %cl,%cl
  800949:	74 04                	je     80094f <strncmp+0x26>
  80094b:	3a 0a                	cmp    (%edx),%cl
  80094d:	74 eb                	je     80093a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094f:	0f b6 00             	movzbl (%eax),%eax
  800952:	0f b6 12             	movzbl (%edx),%edx
  800955:	29 d0                	sub    %edx,%eax
  800957:	eb 05                	jmp    80095e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800959:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80095e:	5b                   	pop    %ebx
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096b:	eb 07                	jmp    800974 <strchr+0x13>
		if (*s == c)
  80096d:	38 ca                	cmp    %cl,%dl
  80096f:	74 0f                	je     800980 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	0f b6 10             	movzbl (%eax),%edx
  800977:	84 d2                	test   %dl,%dl
  800979:	75 f2                	jne    80096d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80097b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098c:	eb 03                	jmp    800991 <strfind+0xf>
  80098e:	83 c0 01             	add    $0x1,%eax
  800991:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800994:	38 ca                	cmp    %cl,%dl
  800996:	74 04                	je     80099c <strfind+0x1a>
  800998:	84 d2                	test   %dl,%dl
  80099a:	75 f2                	jne    80098e <strfind+0xc>
			break;
	return (char *) s;
}
  80099c:	5d                   	pop    %ebp
  80099d:	c3                   	ret    

0080099e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	57                   	push   %edi
  8009a2:	56                   	push   %esi
  8009a3:	53                   	push   %ebx
  8009a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009aa:	85 c9                	test   %ecx,%ecx
  8009ac:	74 36                	je     8009e4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009b4:	75 28                	jne    8009de <memset+0x40>
  8009b6:	f6 c1 03             	test   $0x3,%cl
  8009b9:	75 23                	jne    8009de <memset+0x40>
		c &= 0xFF;
  8009bb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009bf:	89 d3                	mov    %edx,%ebx
  8009c1:	c1 e3 08             	shl    $0x8,%ebx
  8009c4:	89 d6                	mov    %edx,%esi
  8009c6:	c1 e6 18             	shl    $0x18,%esi
  8009c9:	89 d0                	mov    %edx,%eax
  8009cb:	c1 e0 10             	shl    $0x10,%eax
  8009ce:	09 f0                	or     %esi,%eax
  8009d0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009d2:	89 d8                	mov    %ebx,%eax
  8009d4:	09 d0                	or     %edx,%eax
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
  8009d9:	fc                   	cld    
  8009da:	f3 ab                	rep stos %eax,%es:(%edi)
  8009dc:	eb 06                	jmp    8009e4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e1:	fc                   	cld    
  8009e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e4:	89 f8                	mov    %edi,%eax
  8009e6:	5b                   	pop    %ebx
  8009e7:	5e                   	pop    %esi
  8009e8:	5f                   	pop    %edi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	57                   	push   %edi
  8009ef:	56                   	push   %esi
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f9:	39 c6                	cmp    %eax,%esi
  8009fb:	73 35                	jae    800a32 <memmove+0x47>
  8009fd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a00:	39 d0                	cmp    %edx,%eax
  800a02:	73 2e                	jae    800a32 <memmove+0x47>
		s += n;
		d += n;
  800a04:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a07:	89 d6                	mov    %edx,%esi
  800a09:	09 fe                	or     %edi,%esi
  800a0b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a11:	75 13                	jne    800a26 <memmove+0x3b>
  800a13:	f6 c1 03             	test   $0x3,%cl
  800a16:	75 0e                	jne    800a26 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a18:	83 ef 04             	sub    $0x4,%edi
  800a1b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a1e:	c1 e9 02             	shr    $0x2,%ecx
  800a21:	fd                   	std    
  800a22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a24:	eb 09                	jmp    800a2f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a26:	83 ef 01             	sub    $0x1,%edi
  800a29:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a2c:	fd                   	std    
  800a2d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a2f:	fc                   	cld    
  800a30:	eb 1d                	jmp    800a4f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a32:	89 f2                	mov    %esi,%edx
  800a34:	09 c2                	or     %eax,%edx
  800a36:	f6 c2 03             	test   $0x3,%dl
  800a39:	75 0f                	jne    800a4a <memmove+0x5f>
  800a3b:	f6 c1 03             	test   $0x3,%cl
  800a3e:	75 0a                	jne    800a4a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a40:	c1 e9 02             	shr    $0x2,%ecx
  800a43:	89 c7                	mov    %eax,%edi
  800a45:	fc                   	cld    
  800a46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a48:	eb 05                	jmp    800a4f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a4a:	89 c7                	mov    %eax,%edi
  800a4c:	fc                   	cld    
  800a4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a4f:	5e                   	pop    %esi
  800a50:	5f                   	pop    %edi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a56:	ff 75 10             	pushl  0x10(%ebp)
  800a59:	ff 75 0c             	pushl  0xc(%ebp)
  800a5c:	ff 75 08             	pushl  0x8(%ebp)
  800a5f:	e8 87 ff ff ff       	call   8009eb <memmove>
}
  800a64:	c9                   	leave  
  800a65:	c3                   	ret    

00800a66 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a71:	89 c6                	mov    %eax,%esi
  800a73:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a76:	eb 1a                	jmp    800a92 <memcmp+0x2c>
		if (*s1 != *s2)
  800a78:	0f b6 08             	movzbl (%eax),%ecx
  800a7b:	0f b6 1a             	movzbl (%edx),%ebx
  800a7e:	38 d9                	cmp    %bl,%cl
  800a80:	74 0a                	je     800a8c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a82:	0f b6 c1             	movzbl %cl,%eax
  800a85:	0f b6 db             	movzbl %bl,%ebx
  800a88:	29 d8                	sub    %ebx,%eax
  800a8a:	eb 0f                	jmp    800a9b <memcmp+0x35>
		s1++, s2++;
  800a8c:	83 c0 01             	add    $0x1,%eax
  800a8f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a92:	39 f0                	cmp    %esi,%eax
  800a94:	75 e2                	jne    800a78 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5e                   	pop    %esi
  800a9d:	5d                   	pop    %ebp
  800a9e:	c3                   	ret    

00800a9f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	53                   	push   %ebx
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aa6:	89 c1                	mov    %eax,%ecx
  800aa8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800aab:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aaf:	eb 0a                	jmp    800abb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab1:	0f b6 10             	movzbl (%eax),%edx
  800ab4:	39 da                	cmp    %ebx,%edx
  800ab6:	74 07                	je     800abf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ab8:	83 c0 01             	add    $0x1,%eax
  800abb:	39 c8                	cmp    %ecx,%eax
  800abd:	72 f2                	jb     800ab1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800abf:	5b                   	pop    %ebx
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	57                   	push   %edi
  800ac6:	56                   	push   %esi
  800ac7:	53                   	push   %ebx
  800ac8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ace:	eb 03                	jmp    800ad3 <strtol+0x11>
		s++;
  800ad0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ad3:	0f b6 01             	movzbl (%ecx),%eax
  800ad6:	3c 20                	cmp    $0x20,%al
  800ad8:	74 f6                	je     800ad0 <strtol+0xe>
  800ada:	3c 09                	cmp    $0x9,%al
  800adc:	74 f2                	je     800ad0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ade:	3c 2b                	cmp    $0x2b,%al
  800ae0:	75 0a                	jne    800aec <strtol+0x2a>
		s++;
  800ae2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ae5:	bf 00 00 00 00       	mov    $0x0,%edi
  800aea:	eb 11                	jmp    800afd <strtol+0x3b>
  800aec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800af1:	3c 2d                	cmp    $0x2d,%al
  800af3:	75 08                	jne    800afd <strtol+0x3b>
		s++, neg = 1;
  800af5:	83 c1 01             	add    $0x1,%ecx
  800af8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b03:	75 15                	jne    800b1a <strtol+0x58>
  800b05:	80 39 30             	cmpb   $0x30,(%ecx)
  800b08:	75 10                	jne    800b1a <strtol+0x58>
  800b0a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b0e:	75 7c                	jne    800b8c <strtol+0xca>
		s += 2, base = 16;
  800b10:	83 c1 02             	add    $0x2,%ecx
  800b13:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b18:	eb 16                	jmp    800b30 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b1a:	85 db                	test   %ebx,%ebx
  800b1c:	75 12                	jne    800b30 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b1e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b23:	80 39 30             	cmpb   $0x30,(%ecx)
  800b26:	75 08                	jne    800b30 <strtol+0x6e>
		s++, base = 8;
  800b28:	83 c1 01             	add    $0x1,%ecx
  800b2b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b30:	b8 00 00 00 00       	mov    $0x0,%eax
  800b35:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b38:	0f b6 11             	movzbl (%ecx),%edx
  800b3b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b3e:	89 f3                	mov    %esi,%ebx
  800b40:	80 fb 09             	cmp    $0x9,%bl
  800b43:	77 08                	ja     800b4d <strtol+0x8b>
			dig = *s - '0';
  800b45:	0f be d2             	movsbl %dl,%edx
  800b48:	83 ea 30             	sub    $0x30,%edx
  800b4b:	eb 22                	jmp    800b6f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b4d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b50:	89 f3                	mov    %esi,%ebx
  800b52:	80 fb 19             	cmp    $0x19,%bl
  800b55:	77 08                	ja     800b5f <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b57:	0f be d2             	movsbl %dl,%edx
  800b5a:	83 ea 57             	sub    $0x57,%edx
  800b5d:	eb 10                	jmp    800b6f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b5f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b62:	89 f3                	mov    %esi,%ebx
  800b64:	80 fb 19             	cmp    $0x19,%bl
  800b67:	77 16                	ja     800b7f <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b69:	0f be d2             	movsbl %dl,%edx
  800b6c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b6f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b72:	7d 0b                	jge    800b7f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b74:	83 c1 01             	add    $0x1,%ecx
  800b77:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b7b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b7d:	eb b9                	jmp    800b38 <strtol+0x76>

	if (endptr)
  800b7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b83:	74 0d                	je     800b92 <strtol+0xd0>
		*endptr = (char *) s;
  800b85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b88:	89 0e                	mov    %ecx,(%esi)
  800b8a:	eb 06                	jmp    800b92 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8c:	85 db                	test   %ebx,%ebx
  800b8e:	74 98                	je     800b28 <strtol+0x66>
  800b90:	eb 9e                	jmp    800b30 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b92:	89 c2                	mov    %eax,%edx
  800b94:	f7 da                	neg    %edx
  800b96:	85 ff                	test   %edi,%edi
  800b98:	0f 45 c2             	cmovne %edx,%eax
}
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5f                   	pop    %edi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	57                   	push   %edi
  800ba4:	56                   	push   %esi
  800ba5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	89 c3                	mov    %eax,%ebx
  800bb3:	89 c7                	mov    %eax,%edi
  800bb5:	89 c6                	mov    %eax,%esi
  800bb7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <sys_cgetc>:

int
sys_cgetc(void)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	57                   	push   %edi
  800bc2:	56                   	push   %esi
  800bc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bce:	89 d1                	mov    %edx,%ecx
  800bd0:	89 d3                	mov    %edx,%ebx
  800bd2:	89 d7                	mov    %edx,%edi
  800bd4:	89 d6                	mov    %edx,%esi
  800bd6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800be6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800beb:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf3:	89 cb                	mov    %ecx,%ebx
  800bf5:	89 cf                	mov    %ecx,%edi
  800bf7:	89 ce                	mov    %ecx,%esi
  800bf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 03                	push   $0x3
  800c05:	68 e4 13 80 00       	push   $0x8013e4
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 01 14 80 00       	push   $0x801401
  800c11:	e8 66 f5 ff ff       	call   80017c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c24:	ba 00 00 00 00       	mov    $0x0,%edx
  800c29:	b8 02 00 00 00       	mov    $0x2,%eax
  800c2e:	89 d1                	mov    %edx,%ecx
  800c30:	89 d3                	mov    %edx,%ebx
  800c32:	89 d7                	mov    %edx,%edi
  800c34:	89 d6                	mov    %edx,%esi
  800c36:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_yield>:

void
sys_yield(void)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c43:	ba 00 00 00 00       	mov    $0x0,%edx
  800c48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c4d:	89 d1                	mov    %edx,%ecx
  800c4f:	89 d3                	mov    %edx,%ebx
  800c51:	89 d7                	mov    %edx,%edi
  800c53:	89 d6                	mov    %edx,%esi
  800c55:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	be 00 00 00 00       	mov    $0x0,%esi
  800c6a:	b8 04 00 00 00       	mov    $0x4,%eax
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c78:	89 f7                	mov    %esi,%edi
  800c7a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	7e 17                	jle    800c97 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c80:	83 ec 0c             	sub    $0xc,%esp
  800c83:	50                   	push   %eax
  800c84:	6a 04                	push   $0x4
  800c86:	68 e4 13 80 00       	push   $0x8013e4
  800c8b:	6a 23                	push   $0x23
  800c8d:	68 01 14 80 00       	push   $0x801401
  800c92:	e8 e5 f4 ff ff       	call   80017c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5f                   	pop    %edi
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca8:	b8 05 00 00 00       	mov    $0x5,%eax
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cb9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cbe:	85 c0                	test   %eax,%eax
  800cc0:	7e 17                	jle    800cd9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc2:	83 ec 0c             	sub    $0xc,%esp
  800cc5:	50                   	push   %eax
  800cc6:	6a 05                	push   $0x5
  800cc8:	68 e4 13 80 00       	push   $0x8013e4
  800ccd:	6a 23                	push   $0x23
  800ccf:	68 01 14 80 00       	push   $0x801401
  800cd4:	e8 a3 f4 ff ff       	call   80017c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cea:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cef:	b8 06 00 00 00       	mov    $0x6,%eax
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	89 df                	mov    %ebx,%edi
  800cfc:	89 de                	mov    %ebx,%esi
  800cfe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d00:	85 c0                	test   %eax,%eax
  800d02:	7e 17                	jle    800d1b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d04:	83 ec 0c             	sub    $0xc,%esp
  800d07:	50                   	push   %eax
  800d08:	6a 06                	push   $0x6
  800d0a:	68 e4 13 80 00       	push   $0x8013e4
  800d0f:	6a 23                	push   $0x23
  800d11:	68 01 14 80 00       	push   $0x801401
  800d16:	e8 61 f4 ff ff       	call   80017c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5f                   	pop    %edi
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	57                   	push   %edi
  800d27:	56                   	push   %esi
  800d28:	53                   	push   %ebx
  800d29:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d31:	b8 08 00 00 00       	mov    $0x8,%eax
  800d36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	89 df                	mov    %ebx,%edi
  800d3e:	89 de                	mov    %ebx,%esi
  800d40:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d42:	85 c0                	test   %eax,%eax
  800d44:	7e 17                	jle    800d5d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d46:	83 ec 0c             	sub    $0xc,%esp
  800d49:	50                   	push   %eax
  800d4a:	6a 08                	push   $0x8
  800d4c:	68 e4 13 80 00       	push   $0x8013e4
  800d51:	6a 23                	push   $0x23
  800d53:	68 01 14 80 00       	push   $0x801401
  800d58:	e8 1f f4 ff ff       	call   80017c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	57                   	push   %edi
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
  800d6b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d73:	b8 09 00 00 00       	mov    $0x9,%eax
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	89 df                	mov    %ebx,%edi
  800d80:	89 de                	mov    %ebx,%esi
  800d82:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d84:	85 c0                	test   %eax,%eax
  800d86:	7e 17                	jle    800d9f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	6a 09                	push   $0x9
  800d8e:	68 e4 13 80 00       	push   $0x8013e4
  800d93:	6a 23                	push   $0x23
  800d95:	68 01 14 80 00       	push   $0x801401
  800d9a:	e8 dd f3 ff ff       	call   80017c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dad:	be 00 00 00 00       	mov    $0x0,%esi
  800db2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dba:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dc3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc5:	5b                   	pop    %ebx
  800dc6:	5e                   	pop    %esi
  800dc7:	5f                   	pop    %edi
  800dc8:	5d                   	pop    %ebp
  800dc9:	c3                   	ret    

00800dca <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ddd:	8b 55 08             	mov    0x8(%ebp),%edx
  800de0:	89 cb                	mov    %ecx,%ebx
  800de2:	89 cf                	mov    %ecx,%edi
  800de4:	89 ce                	mov    %ecx,%esi
  800de6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de8:	85 c0                	test   %eax,%eax
  800dea:	7e 17                	jle    800e03 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dec:	83 ec 0c             	sub    $0xc,%esp
  800def:	50                   	push   %eax
  800df0:	6a 0c                	push   $0xc
  800df2:	68 e4 13 80 00       	push   $0x8013e4
  800df7:	6a 23                	push   $0x23
  800df9:	68 01 14 80 00       	push   $0x801401
  800dfe:	e8 79 f3 ff ff       	call   80017c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e06:	5b                   	pop    %ebx
  800e07:	5e                   	pop    %esi
  800e08:	5f                   	pop    %edi
  800e09:	5d                   	pop    %ebp
  800e0a:	c3                   	ret    
  800e0b:	66 90                	xchg   %ax,%ax
  800e0d:	66 90                	xchg   %ax,%ax
  800e0f:	90                   	nop

00800e10 <__udivdi3>:
  800e10:	55                   	push   %ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 1c             	sub    $0x1c,%esp
  800e17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e27:	85 f6                	test   %esi,%esi
  800e29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e2d:	89 ca                	mov    %ecx,%edx
  800e2f:	89 f8                	mov    %edi,%eax
  800e31:	75 3d                	jne    800e70 <__udivdi3+0x60>
  800e33:	39 cf                	cmp    %ecx,%edi
  800e35:	0f 87 c5 00 00 00    	ja     800f00 <__udivdi3+0xf0>
  800e3b:	85 ff                	test   %edi,%edi
  800e3d:	89 fd                	mov    %edi,%ebp
  800e3f:	75 0b                	jne    800e4c <__udivdi3+0x3c>
  800e41:	b8 01 00 00 00       	mov    $0x1,%eax
  800e46:	31 d2                	xor    %edx,%edx
  800e48:	f7 f7                	div    %edi
  800e4a:	89 c5                	mov    %eax,%ebp
  800e4c:	89 c8                	mov    %ecx,%eax
  800e4e:	31 d2                	xor    %edx,%edx
  800e50:	f7 f5                	div    %ebp
  800e52:	89 c1                	mov    %eax,%ecx
  800e54:	89 d8                	mov    %ebx,%eax
  800e56:	89 cf                	mov    %ecx,%edi
  800e58:	f7 f5                	div    %ebp
  800e5a:	89 c3                	mov    %eax,%ebx
  800e5c:	89 d8                	mov    %ebx,%eax
  800e5e:	89 fa                	mov    %edi,%edx
  800e60:	83 c4 1c             	add    $0x1c,%esp
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    
  800e68:	90                   	nop
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	39 ce                	cmp    %ecx,%esi
  800e72:	77 74                	ja     800ee8 <__udivdi3+0xd8>
  800e74:	0f bd fe             	bsr    %esi,%edi
  800e77:	83 f7 1f             	xor    $0x1f,%edi
  800e7a:	0f 84 98 00 00 00    	je     800f18 <__udivdi3+0x108>
  800e80:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e85:	89 f9                	mov    %edi,%ecx
  800e87:	89 c5                	mov    %eax,%ebp
  800e89:	29 fb                	sub    %edi,%ebx
  800e8b:	d3 e6                	shl    %cl,%esi
  800e8d:	89 d9                	mov    %ebx,%ecx
  800e8f:	d3 ed                	shr    %cl,%ebp
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e0                	shl    %cl,%eax
  800e95:	09 ee                	or     %ebp,%esi
  800e97:	89 d9                	mov    %ebx,%ecx
  800e99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e9d:	89 d5                	mov    %edx,%ebp
  800e9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ea3:	d3 ed                	shr    %cl,%ebp
  800ea5:	89 f9                	mov    %edi,%ecx
  800ea7:	d3 e2                	shl    %cl,%edx
  800ea9:	89 d9                	mov    %ebx,%ecx
  800eab:	d3 e8                	shr    %cl,%eax
  800ead:	09 c2                	or     %eax,%edx
  800eaf:	89 d0                	mov    %edx,%eax
  800eb1:	89 ea                	mov    %ebp,%edx
  800eb3:	f7 f6                	div    %esi
  800eb5:	89 d5                	mov    %edx,%ebp
  800eb7:	89 c3                	mov    %eax,%ebx
  800eb9:	f7 64 24 0c          	mull   0xc(%esp)
  800ebd:	39 d5                	cmp    %edx,%ebp
  800ebf:	72 10                	jb     800ed1 <__udivdi3+0xc1>
  800ec1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ec5:	89 f9                	mov    %edi,%ecx
  800ec7:	d3 e6                	shl    %cl,%esi
  800ec9:	39 c6                	cmp    %eax,%esi
  800ecb:	73 07                	jae    800ed4 <__udivdi3+0xc4>
  800ecd:	39 d5                	cmp    %edx,%ebp
  800ecf:	75 03                	jne    800ed4 <__udivdi3+0xc4>
  800ed1:	83 eb 01             	sub    $0x1,%ebx
  800ed4:	31 ff                	xor    %edi,%edi
  800ed6:	89 d8                	mov    %ebx,%eax
  800ed8:	89 fa                	mov    %edi,%edx
  800eda:	83 c4 1c             	add    $0x1c,%esp
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    
  800ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee8:	31 ff                	xor    %edi,%edi
  800eea:	31 db                	xor    %ebx,%ebx
  800eec:	89 d8                	mov    %ebx,%eax
  800eee:	89 fa                	mov    %edi,%edx
  800ef0:	83 c4 1c             	add    $0x1c,%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    
  800ef8:	90                   	nop
  800ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f00:	89 d8                	mov    %ebx,%eax
  800f02:	f7 f7                	div    %edi
  800f04:	31 ff                	xor    %edi,%edi
  800f06:	89 c3                	mov    %eax,%ebx
  800f08:	89 d8                	mov    %ebx,%eax
  800f0a:	89 fa                	mov    %edi,%edx
  800f0c:	83 c4 1c             	add    $0x1c,%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    
  800f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f18:	39 ce                	cmp    %ecx,%esi
  800f1a:	72 0c                	jb     800f28 <__udivdi3+0x118>
  800f1c:	31 db                	xor    %ebx,%ebx
  800f1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f22:	0f 87 34 ff ff ff    	ja     800e5c <__udivdi3+0x4c>
  800f28:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f2d:	e9 2a ff ff ff       	jmp    800e5c <__udivdi3+0x4c>
  800f32:	66 90                	xchg   %ax,%ax
  800f34:	66 90                	xchg   %ax,%ax
  800f36:	66 90                	xchg   %ax,%ax
  800f38:	66 90                	xchg   %ax,%ax
  800f3a:	66 90                	xchg   %ax,%ax
  800f3c:	66 90                	xchg   %ax,%ax
  800f3e:	66 90                	xchg   %ax,%ax

00800f40 <__umoddi3>:
  800f40:	55                   	push   %ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	83 ec 1c             	sub    $0x1c,%esp
  800f47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f57:	85 d2                	test   %edx,%edx
  800f59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f61:	89 f3                	mov    %esi,%ebx
  800f63:	89 3c 24             	mov    %edi,(%esp)
  800f66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f6a:	75 1c                	jne    800f88 <__umoddi3+0x48>
  800f6c:	39 f7                	cmp    %esi,%edi
  800f6e:	76 50                	jbe    800fc0 <__umoddi3+0x80>
  800f70:	89 c8                	mov    %ecx,%eax
  800f72:	89 f2                	mov    %esi,%edx
  800f74:	f7 f7                	div    %edi
  800f76:	89 d0                	mov    %edx,%eax
  800f78:	31 d2                	xor    %edx,%edx
  800f7a:	83 c4 1c             	add    $0x1c,%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5f                   	pop    %edi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    
  800f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f88:	39 f2                	cmp    %esi,%edx
  800f8a:	89 d0                	mov    %edx,%eax
  800f8c:	77 52                	ja     800fe0 <__umoddi3+0xa0>
  800f8e:	0f bd ea             	bsr    %edx,%ebp
  800f91:	83 f5 1f             	xor    $0x1f,%ebp
  800f94:	75 5a                	jne    800ff0 <__umoddi3+0xb0>
  800f96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f9a:	0f 82 e0 00 00 00    	jb     801080 <__umoddi3+0x140>
  800fa0:	39 0c 24             	cmp    %ecx,(%esp)
  800fa3:	0f 86 d7 00 00 00    	jbe    801080 <__umoddi3+0x140>
  800fa9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fad:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fb1:	83 c4 1c             	add    $0x1c,%esp
  800fb4:	5b                   	pop    %ebx
  800fb5:	5e                   	pop    %esi
  800fb6:	5f                   	pop    %edi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    
  800fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	85 ff                	test   %edi,%edi
  800fc2:	89 fd                	mov    %edi,%ebp
  800fc4:	75 0b                	jne    800fd1 <__umoddi3+0x91>
  800fc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	f7 f7                	div    %edi
  800fcf:	89 c5                	mov    %eax,%ebp
  800fd1:	89 f0                	mov    %esi,%eax
  800fd3:	31 d2                	xor    %edx,%edx
  800fd5:	f7 f5                	div    %ebp
  800fd7:	89 c8                	mov    %ecx,%eax
  800fd9:	f7 f5                	div    %ebp
  800fdb:	89 d0                	mov    %edx,%eax
  800fdd:	eb 99                	jmp    800f78 <__umoddi3+0x38>
  800fdf:	90                   	nop
  800fe0:	89 c8                	mov    %ecx,%eax
  800fe2:	89 f2                	mov    %esi,%edx
  800fe4:	83 c4 1c             	add    $0x1c,%esp
  800fe7:	5b                   	pop    %ebx
  800fe8:	5e                   	pop    %esi
  800fe9:	5f                   	pop    %edi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    
  800fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ff0:	8b 34 24             	mov    (%esp),%esi
  800ff3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ff8:	89 e9                	mov    %ebp,%ecx
  800ffa:	29 ef                	sub    %ebp,%edi
  800ffc:	d3 e0                	shl    %cl,%eax
  800ffe:	89 f9                	mov    %edi,%ecx
  801000:	89 f2                	mov    %esi,%edx
  801002:	d3 ea                	shr    %cl,%edx
  801004:	89 e9                	mov    %ebp,%ecx
  801006:	09 c2                	or     %eax,%edx
  801008:	89 d8                	mov    %ebx,%eax
  80100a:	89 14 24             	mov    %edx,(%esp)
  80100d:	89 f2                	mov    %esi,%edx
  80100f:	d3 e2                	shl    %cl,%edx
  801011:	89 f9                	mov    %edi,%ecx
  801013:	89 54 24 04          	mov    %edx,0x4(%esp)
  801017:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80101b:	d3 e8                	shr    %cl,%eax
  80101d:	89 e9                	mov    %ebp,%ecx
  80101f:	89 c6                	mov    %eax,%esi
  801021:	d3 e3                	shl    %cl,%ebx
  801023:	89 f9                	mov    %edi,%ecx
  801025:	89 d0                	mov    %edx,%eax
  801027:	d3 e8                	shr    %cl,%eax
  801029:	89 e9                	mov    %ebp,%ecx
  80102b:	09 d8                	or     %ebx,%eax
  80102d:	89 d3                	mov    %edx,%ebx
  80102f:	89 f2                	mov    %esi,%edx
  801031:	f7 34 24             	divl   (%esp)
  801034:	89 d6                	mov    %edx,%esi
  801036:	d3 e3                	shl    %cl,%ebx
  801038:	f7 64 24 04          	mull   0x4(%esp)
  80103c:	39 d6                	cmp    %edx,%esi
  80103e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801042:	89 d1                	mov    %edx,%ecx
  801044:	89 c3                	mov    %eax,%ebx
  801046:	72 08                	jb     801050 <__umoddi3+0x110>
  801048:	75 11                	jne    80105b <__umoddi3+0x11b>
  80104a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80104e:	73 0b                	jae    80105b <__umoddi3+0x11b>
  801050:	2b 44 24 04          	sub    0x4(%esp),%eax
  801054:	1b 14 24             	sbb    (%esp),%edx
  801057:	89 d1                	mov    %edx,%ecx
  801059:	89 c3                	mov    %eax,%ebx
  80105b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80105f:	29 da                	sub    %ebx,%edx
  801061:	19 ce                	sbb    %ecx,%esi
  801063:	89 f9                	mov    %edi,%ecx
  801065:	89 f0                	mov    %esi,%eax
  801067:	d3 e0                	shl    %cl,%eax
  801069:	89 e9                	mov    %ebp,%ecx
  80106b:	d3 ea                	shr    %cl,%edx
  80106d:	89 e9                	mov    %ebp,%ecx
  80106f:	d3 ee                	shr    %cl,%esi
  801071:	09 d0                	or     %edx,%eax
  801073:	89 f2                	mov    %esi,%edx
  801075:	83 c4 1c             	add    $0x1c,%esp
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    
  80107d:	8d 76 00             	lea    0x0(%esi),%esi
  801080:	29 f9                	sub    %edi,%ecx
  801082:	19 d6                	sbb    %edx,%esi
  801084:	89 74 24 04          	mov    %esi,0x4(%esp)
  801088:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80108c:	e9 18 ff ff ff       	jmp    800fa9 <__umoddi3+0x69>
