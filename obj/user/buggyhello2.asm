
obj/user/buggyhello2:     file format elf32-i386


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

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 60 00 00 00       	call   8000a9 <sys_cputs>
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
  800059:	e8 c9 00 00 00       	call   800127 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800066:	c1 e0 05             	shl    $0x5,%eax
  800069:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006e:	a3 08 20 80 00       	mov    %eax,0x802008
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800073:	85 db                	test   %ebx,%ebx
  800075:	7e 07                	jle    80007e <libmain+0x30>
		binaryname = argv[0];
  800077:	8b 06                	mov    (%esi),%eax
  800079:	a3 04 20 80 00       	mov    %eax,0x802004

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
  80009f:	e8 42 00 00 00       	call   8000e6 <sys_env_destroy>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    

008000a9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	57                   	push   %edi
  8000ad:	56                   	push   %esi
  8000ae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000af:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	89 c3                	mov    %eax,%ebx
  8000bc:	89 c7                	mov    %eax,%edi
  8000be:	89 c6                	mov    %eax,%esi
  8000c0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5f                   	pop    %edi
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    

008000c7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	57                   	push   %edi
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d7:	89 d1                	mov    %edx,%ecx
  8000d9:	89 d3                	mov    %edx,%ebx
  8000db:	89 d7                	mov    %edx,%edi
  8000dd:	89 d6                	mov    %edx,%esi
  8000df:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fc:	89 cb                	mov    %ecx,%ebx
  8000fe:	89 cf                	mov    %ecx,%edi
  800100:	89 ce                	mov    %ecx,%esi
  800102:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800104:	85 c0                	test   %eax,%eax
  800106:	7e 17                	jle    80011f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800108:	83 ec 0c             	sub    $0xc,%esp
  80010b:	50                   	push   %eax
  80010c:	6a 03                	push   $0x3
  80010e:	68 ec 0d 80 00       	push   $0x800dec
  800113:	6a 23                	push   $0x23
  800115:	68 09 0e 80 00       	push   $0x800e09
  80011a:	e8 3c 00 00 00       	call   80015b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5f                   	pop    %edi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	57                   	push   %edi
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
  80012d:	83 ec 14             	sub    $0x14,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
  800144:	89 c3                	mov    %eax,%ebx

envid_t
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	cprintf("lib/syscall.c: %x\n", ret);
  800146:	50                   	push   %eax
  800147:	68 17 0e 80 00       	push   $0x800e17
  80014c:	e8 e3 00 00 00       	call   800234 <cprintf>
	return ret;
}
  800151:	89 d8                	mov    %ebx,%eax
  800153:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800160:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800163:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800169:	e8 b9 ff ff ff       	call   800127 <sys_getenvid>
  80016e:	83 ec 0c             	sub    $0xc,%esp
  800171:	ff 75 0c             	pushl  0xc(%ebp)
  800174:	ff 75 08             	pushl  0x8(%ebp)
  800177:	56                   	push   %esi
  800178:	50                   	push   %eax
  800179:	68 2c 0e 80 00       	push   $0x800e2c
  80017e:	e8 b1 00 00 00       	call   800234 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800183:	83 c4 18             	add    $0x18,%esp
  800186:	53                   	push   %ebx
  800187:	ff 75 10             	pushl  0x10(%ebp)
  80018a:	e8 54 00 00 00       	call   8001e3 <vcprintf>
	cprintf("\n");
  80018f:	c7 04 24 e0 0d 80 00 	movl   $0x800de0,(%esp)
  800196:	e8 99 00 00 00       	call   800234 <cprintf>
  80019b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019e:	cc                   	int3   
  80019f:	eb fd                	jmp    80019e <_panic+0x43>

008001a1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	53                   	push   %ebx
  8001a5:	83 ec 04             	sub    $0x4,%esp
  8001a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ab:	8b 13                	mov    (%ebx),%edx
  8001ad:	8d 42 01             	lea    0x1(%edx),%eax
  8001b0:	89 03                	mov    %eax,(%ebx)
  8001b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001be:	75 1a                	jne    8001da <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001c0:	83 ec 08             	sub    $0x8,%esp
  8001c3:	68 ff 00 00 00       	push   $0xff
  8001c8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001cb:	50                   	push   %eax
  8001cc:	e8 d8 fe ff ff       	call   8000a9 <sys_cputs>
		b->idx = 0;
  8001d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001da:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f3:	00 00 00 
	b.cnt = 0;
  8001f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800200:	ff 75 0c             	pushl  0xc(%ebp)
  800203:	ff 75 08             	pushl  0x8(%ebp)
  800206:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020c:	50                   	push   %eax
  80020d:	68 a1 01 80 00       	push   $0x8001a1
  800212:	e8 54 01 00 00       	call   80036b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800217:	83 c4 08             	add    $0x8,%esp
  80021a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800220:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800226:	50                   	push   %eax
  800227:	e8 7d fe ff ff       	call   8000a9 <sys_cputs>

	return b.cnt;
}
  80022c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023d:	50                   	push   %eax
  80023e:	ff 75 08             	pushl  0x8(%ebp)
  800241:	e8 9d ff ff ff       	call   8001e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 1c             	sub    $0x1c,%esp
  800251:	89 c7                	mov    %eax,%edi
  800253:	89 d6                	mov    %edx,%esi
  800255:	8b 45 08             	mov    0x8(%ebp),%eax
  800258:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800261:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80026c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026f:	39 d3                	cmp    %edx,%ebx
  800271:	72 05                	jb     800278 <printnum+0x30>
  800273:	39 45 10             	cmp    %eax,0x10(%ebp)
  800276:	77 45                	ja     8002bd <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800278:	83 ec 0c             	sub    $0xc,%esp
  80027b:	ff 75 18             	pushl  0x18(%ebp)
  80027e:	8b 45 14             	mov    0x14(%ebp),%eax
  800281:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800284:	53                   	push   %ebx
  800285:	ff 75 10             	pushl  0x10(%ebp)
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 b4 08 00 00       	call   800b50 <__udivdi3>
  80029c:	83 c4 18             	add    $0x18,%esp
  80029f:	52                   	push   %edx
  8002a0:	50                   	push   %eax
  8002a1:	89 f2                	mov    %esi,%edx
  8002a3:	89 f8                	mov    %edi,%eax
  8002a5:	e8 9e ff ff ff       	call   800248 <printnum>
  8002aa:	83 c4 20             	add    $0x20,%esp
  8002ad:	eb 18                	jmp    8002c7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002af:	83 ec 08             	sub    $0x8,%esp
  8002b2:	56                   	push   %esi
  8002b3:	ff 75 18             	pushl  0x18(%ebp)
  8002b6:	ff d7                	call   *%edi
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	eb 03                	jmp    8002c0 <printnum+0x78>
  8002bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002c0:	83 eb 01             	sub    $0x1,%ebx
  8002c3:	85 db                	test   %ebx,%ebx
  8002c5:	7f e8                	jg     8002af <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c7:	83 ec 08             	sub    $0x8,%esp
  8002ca:	56                   	push   %esi
  8002cb:	83 ec 04             	sub    $0x4,%esp
  8002ce:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002da:	e8 a1 09 00 00       	call   800c80 <__umoddi3>
  8002df:	83 c4 14             	add    $0x14,%esp
  8002e2:	0f be 80 50 0e 80 00 	movsbl 0x800e50(%eax),%eax
  8002e9:	50                   	push   %eax
  8002ea:	ff d7                	call   *%edi
}
  8002ec:	83 c4 10             	add    $0x10,%esp
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002fa:	83 fa 01             	cmp    $0x1,%edx
  8002fd:	7e 0e                	jle    80030d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ff:	8b 10                	mov    (%eax),%edx
  800301:	8d 4a 08             	lea    0x8(%edx),%ecx
  800304:	89 08                	mov    %ecx,(%eax)
  800306:	8b 02                	mov    (%edx),%eax
  800308:	8b 52 04             	mov    0x4(%edx),%edx
  80030b:	eb 22                	jmp    80032f <getuint+0x38>
	else if (lflag)
  80030d:	85 d2                	test   %edx,%edx
  80030f:	74 10                	je     800321 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800311:	8b 10                	mov    (%eax),%edx
  800313:	8d 4a 04             	lea    0x4(%edx),%ecx
  800316:	89 08                	mov    %ecx,(%eax)
  800318:	8b 02                	mov    (%edx),%eax
  80031a:	ba 00 00 00 00       	mov    $0x0,%edx
  80031f:	eb 0e                	jmp    80032f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800321:	8b 10                	mov    (%eax),%edx
  800323:	8d 4a 04             	lea    0x4(%edx),%ecx
  800326:	89 08                	mov    %ecx,(%eax)
  800328:	8b 02                	mov    (%edx),%eax
  80032a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800337:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033b:	8b 10                	mov    (%eax),%edx
  80033d:	3b 50 04             	cmp    0x4(%eax),%edx
  800340:	73 0a                	jae    80034c <sprintputch+0x1b>
		*b->buf++ = ch;
  800342:	8d 4a 01             	lea    0x1(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 45 08             	mov    0x8(%ebp),%eax
  80034a:	88 02                	mov    %al,(%edx)
}
  80034c:	5d                   	pop    %ebp
  80034d:	c3                   	ret    

0080034e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034e:	55                   	push   %ebp
  80034f:	89 e5                	mov    %esp,%ebp
  800351:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800354:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800357:	50                   	push   %eax
  800358:	ff 75 10             	pushl  0x10(%ebp)
  80035b:	ff 75 0c             	pushl  0xc(%ebp)
  80035e:	ff 75 08             	pushl  0x8(%ebp)
  800361:	e8 05 00 00 00       	call   80036b <vprintfmt>
	va_end(ap);
}
  800366:	83 c4 10             	add    $0x10,%esp
  800369:	c9                   	leave  
  80036a:	c3                   	ret    

0080036b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	57                   	push   %edi
  80036f:	56                   	push   %esi
  800370:	53                   	push   %ebx
  800371:	83 ec 2c             	sub    $0x2c,%esp
  800374:	8b 75 08             	mov    0x8(%ebp),%esi
  800377:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80037a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037d:	eb 1d                	jmp    80039c <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80037f:	85 c0                	test   %eax,%eax
  800381:	75 0f                	jne    800392 <vprintfmt+0x27>
				csa = 0x0700;
  800383:	c7 05 0c 20 80 00 00 	movl   $0x700,0x80200c
  80038a:	07 00 00 
				return;
  80038d:	e9 c4 03 00 00       	jmp    800756 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800392:	83 ec 08             	sub    $0x8,%esp
  800395:	53                   	push   %ebx
  800396:	50                   	push   %eax
  800397:	ff d6                	call   *%esi
  800399:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80039c:	83 c7 01             	add    $0x1,%edi
  80039f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003a3:	83 f8 25             	cmp    $0x25,%eax
  8003a6:	75 d7                	jne    80037f <vprintfmt+0x14>
  8003a8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003ac:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003b3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ba:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c6:	eb 07                	jmp    8003cf <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003cb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8d 47 01             	lea    0x1(%edi),%eax
  8003d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d5:	0f b6 07             	movzbl (%edi),%eax
  8003d8:	0f b6 c8             	movzbl %al,%ecx
  8003db:	83 e8 23             	sub    $0x23,%eax
  8003de:	3c 55                	cmp    $0x55,%al
  8003e0:	0f 87 55 03 00 00    	ja     80073b <vprintfmt+0x3d0>
  8003e6:	0f b6 c0             	movzbl %al,%eax
  8003e9:	ff 24 85 e0 0e 80 00 	jmp    *0x800ee0(,%eax,4)
  8003f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f7:	eb d6                	jmp    8003cf <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800401:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800404:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800407:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80040b:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80040e:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800411:	83 fa 09             	cmp    $0x9,%edx
  800414:	77 39                	ja     80044f <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800416:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800419:	eb e9                	jmp    800404 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80041b:	8b 45 14             	mov    0x14(%ebp),%eax
  80041e:	8d 48 04             	lea    0x4(%eax),%ecx
  800421:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800424:	8b 00                	mov    (%eax),%eax
  800426:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80042c:	eb 27                	jmp    800455 <vprintfmt+0xea>
  80042e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800431:	85 c0                	test   %eax,%eax
  800433:	b9 00 00 00 00       	mov    $0x0,%ecx
  800438:	0f 49 c8             	cmovns %eax,%ecx
  80043b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800441:	eb 8c                	jmp    8003cf <vprintfmt+0x64>
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800446:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80044d:	eb 80                	jmp    8003cf <vprintfmt+0x64>
  80044f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800452:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800455:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800459:	0f 89 70 ff ff ff    	jns    8003cf <vprintfmt+0x64>
				width = precision, precision = -1;
  80045f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800462:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800465:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80046c:	e9 5e ff ff ff       	jmp    8003cf <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800471:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800477:	e9 53 ff ff ff       	jmp    8003cf <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8d 50 04             	lea    0x4(%eax),%edx
  800482:	89 55 14             	mov    %edx,0x14(%ebp)
  800485:	83 ec 08             	sub    $0x8,%esp
  800488:	53                   	push   %ebx
  800489:	ff 30                	pushl  (%eax)
  80048b:	ff d6                	call   *%esi
			break;
  80048d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800493:	e9 04 ff ff ff       	jmp    80039c <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	8d 50 04             	lea    0x4(%eax),%edx
  80049e:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a1:	8b 00                	mov    (%eax),%eax
  8004a3:	99                   	cltd   
  8004a4:	31 d0                	xor    %edx,%eax
  8004a6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a8:	83 f8 06             	cmp    $0x6,%eax
  8004ab:	7f 0b                	jg     8004b8 <vprintfmt+0x14d>
  8004ad:	8b 14 85 38 10 80 00 	mov    0x801038(,%eax,4),%edx
  8004b4:	85 d2                	test   %edx,%edx
  8004b6:	75 18                	jne    8004d0 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8004b8:	50                   	push   %eax
  8004b9:	68 68 0e 80 00       	push   $0x800e68
  8004be:	53                   	push   %ebx
  8004bf:	56                   	push   %esi
  8004c0:	e8 89 fe ff ff       	call   80034e <printfmt>
  8004c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004cb:	e9 cc fe ff ff       	jmp    80039c <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8004d0:	52                   	push   %edx
  8004d1:	68 71 0e 80 00       	push   $0x800e71
  8004d6:	53                   	push   %ebx
  8004d7:	56                   	push   %esi
  8004d8:	e8 71 fe ff ff       	call   80034e <printfmt>
  8004dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e3:	e9 b4 fe ff ff       	jmp    80039c <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004eb:	8d 50 04             	lea    0x4(%eax),%edx
  8004ee:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004f3:	85 ff                	test   %edi,%edi
  8004f5:	b8 61 0e 80 00       	mov    $0x800e61,%eax
  8004fa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004fd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800501:	0f 8e 94 00 00 00    	jle    80059b <vprintfmt+0x230>
  800507:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80050b:	0f 84 98 00 00 00    	je     8005a9 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	ff 75 d0             	pushl  -0x30(%ebp)
  800517:	57                   	push   %edi
  800518:	e8 c1 02 00 00       	call   8007de <strnlen>
  80051d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800520:	29 c1                	sub    %eax,%ecx
  800522:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800525:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800528:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80052c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800532:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800534:	eb 0f                	jmp    800545 <vprintfmt+0x1da>
					putch(padc, putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	53                   	push   %ebx
  80053a:	ff 75 e0             	pushl  -0x20(%ebp)
  80053d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	83 ef 01             	sub    $0x1,%edi
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	85 ff                	test   %edi,%edi
  800547:	7f ed                	jg     800536 <vprintfmt+0x1cb>
  800549:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80054c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80054f:	85 c9                	test   %ecx,%ecx
  800551:	b8 00 00 00 00       	mov    $0x0,%eax
  800556:	0f 49 c1             	cmovns %ecx,%eax
  800559:	29 c1                	sub    %eax,%ecx
  80055b:	89 75 08             	mov    %esi,0x8(%ebp)
  80055e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800561:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800564:	89 cb                	mov    %ecx,%ebx
  800566:	eb 4d                	jmp    8005b5 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800568:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80056c:	74 1b                	je     800589 <vprintfmt+0x21e>
  80056e:	0f be c0             	movsbl %al,%eax
  800571:	83 e8 20             	sub    $0x20,%eax
  800574:	83 f8 5e             	cmp    $0x5e,%eax
  800577:	76 10                	jbe    800589 <vprintfmt+0x21e>
					putch('?', putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	ff 75 0c             	pushl  0xc(%ebp)
  80057f:	6a 3f                	push   $0x3f
  800581:	ff 55 08             	call   *0x8(%ebp)
  800584:	83 c4 10             	add    $0x10,%esp
  800587:	eb 0d                	jmp    800596 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	ff 75 0c             	pushl  0xc(%ebp)
  80058f:	52                   	push   %edx
  800590:	ff 55 08             	call   *0x8(%ebp)
  800593:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800596:	83 eb 01             	sub    $0x1,%ebx
  800599:	eb 1a                	jmp    8005b5 <vprintfmt+0x24a>
  80059b:	89 75 08             	mov    %esi,0x8(%ebp)
  80059e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a7:	eb 0c                	jmp    8005b5 <vprintfmt+0x24a>
  8005a9:	89 75 08             	mov    %esi,0x8(%ebp)
  8005ac:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005af:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005b2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b5:	83 c7 01             	add    $0x1,%edi
  8005b8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005bc:	0f be d0             	movsbl %al,%edx
  8005bf:	85 d2                	test   %edx,%edx
  8005c1:	74 23                	je     8005e6 <vprintfmt+0x27b>
  8005c3:	85 f6                	test   %esi,%esi
  8005c5:	78 a1                	js     800568 <vprintfmt+0x1fd>
  8005c7:	83 ee 01             	sub    $0x1,%esi
  8005ca:	79 9c                	jns    800568 <vprintfmt+0x1fd>
  8005cc:	89 df                	mov    %ebx,%edi
  8005ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d4:	eb 18                	jmp    8005ee <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d6:	83 ec 08             	sub    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	6a 20                	push   $0x20
  8005dc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005de:	83 ef 01             	sub    $0x1,%edi
  8005e1:	83 c4 10             	add    $0x10,%esp
  8005e4:	eb 08                	jmp    8005ee <vprintfmt+0x283>
  8005e6:	89 df                	mov    %ebx,%edi
  8005e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ee:	85 ff                	test   %edi,%edi
  8005f0:	7f e4                	jg     8005d6 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f5:	e9 a2 fd ff ff       	jmp    80039c <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fa:	83 fa 01             	cmp    $0x1,%edx
  8005fd:	7e 16                	jle    800615 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8005ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800602:	8d 50 08             	lea    0x8(%eax),%edx
  800605:	89 55 14             	mov    %edx,0x14(%ebp)
  800608:	8b 50 04             	mov    0x4(%eax),%edx
  80060b:	8b 00                	mov    (%eax),%eax
  80060d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800610:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800613:	eb 32                	jmp    800647 <vprintfmt+0x2dc>
	else if (lflag)
  800615:	85 d2                	test   %edx,%edx
  800617:	74 18                	je     800631 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800619:	8b 45 14             	mov    0x14(%ebp),%eax
  80061c:	8d 50 04             	lea    0x4(%eax),%edx
  80061f:	89 55 14             	mov    %edx,0x14(%ebp)
  800622:	8b 00                	mov    (%eax),%eax
  800624:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800627:	89 c1                	mov    %eax,%ecx
  800629:	c1 f9 1f             	sar    $0x1f,%ecx
  80062c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80062f:	eb 16                	jmp    800647 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 50 04             	lea    0x4(%eax),%edx
  800637:	89 55 14             	mov    %edx,0x14(%ebp)
  80063a:	8b 00                	mov    (%eax),%eax
  80063c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063f:	89 c1                	mov    %eax,%ecx
  800641:	c1 f9 1f             	sar    $0x1f,%ecx
  800644:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800647:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80064d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800652:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800656:	79 74                	jns    8006cc <vprintfmt+0x361>
				putch('-', putdat);
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	53                   	push   %ebx
  80065c:	6a 2d                	push   $0x2d
  80065e:	ff d6                	call   *%esi
				num = -(long long) num;
  800660:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800663:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800666:	f7 d8                	neg    %eax
  800668:	83 d2 00             	adc    $0x0,%edx
  80066b:	f7 da                	neg    %edx
  80066d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800670:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800675:	eb 55                	jmp    8006cc <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800677:	8d 45 14             	lea    0x14(%ebp),%eax
  80067a:	e8 78 fc ff ff       	call   8002f7 <getuint>
			base = 10;
  80067f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800684:	eb 46                	jmp    8006cc <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800686:	8d 45 14             	lea    0x14(%ebp),%eax
  800689:	e8 69 fc ff ff       	call   8002f7 <getuint>
      base = 8;
  80068e:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800693:	eb 37                	jmp    8006cc <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 30                	push   $0x30
  80069b:	ff d6                	call   *%esi
			putch('x', putdat);
  80069d:	83 c4 08             	add    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	6a 78                	push   $0x78
  8006a3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8d 50 04             	lea    0x4(%eax),%edx
  8006ab:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006ae:	8b 00                	mov    (%eax),%eax
  8006b0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006bd:	eb 0d                	jmp    8006cc <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c2:	e8 30 fc ff ff       	call   8002f7 <getuint>
			base = 16;
  8006c7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006cc:	83 ec 0c             	sub    $0xc,%esp
  8006cf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006d3:	57                   	push   %edi
  8006d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d7:	51                   	push   %ecx
  8006d8:	52                   	push   %edx
  8006d9:	50                   	push   %eax
  8006da:	89 da                	mov    %ebx,%edx
  8006dc:	89 f0                	mov    %esi,%eax
  8006de:	e8 65 fb ff ff       	call   800248 <printnum>
			break;
  8006e3:	83 c4 20             	add    $0x20,%esp
  8006e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e9:	e9 ae fc ff ff       	jmp    80039c <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ee:	83 ec 08             	sub    $0x8,%esp
  8006f1:	53                   	push   %ebx
  8006f2:	51                   	push   %ecx
  8006f3:	ff d6                	call   *%esi
			break;
  8006f5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006fb:	e9 9c fc ff ff       	jmp    80039c <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800700:	83 fa 01             	cmp    $0x1,%edx
  800703:	7e 0d                	jle    800712 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8d 50 08             	lea    0x8(%eax),%edx
  80070b:	89 55 14             	mov    %edx,0x14(%ebp)
  80070e:	8b 00                	mov    (%eax),%eax
  800710:	eb 1c                	jmp    80072e <vprintfmt+0x3c3>
	else if (lflag)
  800712:	85 d2                	test   %edx,%edx
  800714:	74 0d                	je     800723 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8d 50 04             	lea    0x4(%eax),%edx
  80071c:	89 55 14             	mov    %edx,0x14(%ebp)
  80071f:	8b 00                	mov    (%eax),%eax
  800721:	eb 0b                	jmp    80072e <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  800723:	8b 45 14             	mov    0x14(%ebp),%eax
  800726:	8d 50 04             	lea    0x4(%eax),%edx
  800729:	89 55 14             	mov    %edx,0x14(%ebp)
  80072c:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  80072e:	a3 0c 20 80 00       	mov    %eax,0x80200c
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800733:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  800736:	e9 61 fc ff ff       	jmp    80039c <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073b:	83 ec 08             	sub    $0x8,%esp
  80073e:	53                   	push   %ebx
  80073f:	6a 25                	push   $0x25
  800741:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800743:	83 c4 10             	add    $0x10,%esp
  800746:	eb 03                	jmp    80074b <vprintfmt+0x3e0>
  800748:	83 ef 01             	sub    $0x1,%edi
  80074b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80074f:	75 f7                	jne    800748 <vprintfmt+0x3dd>
  800751:	e9 46 fc ff ff       	jmp    80039c <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800756:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800759:	5b                   	pop    %ebx
  80075a:	5e                   	pop    %esi
  80075b:	5f                   	pop    %edi
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 18             	sub    $0x18,%esp
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80076a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800771:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800774:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80077b:	85 c0                	test   %eax,%eax
  80077d:	74 26                	je     8007a5 <vsnprintf+0x47>
  80077f:	85 d2                	test   %edx,%edx
  800781:	7e 22                	jle    8007a5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800783:	ff 75 14             	pushl  0x14(%ebp)
  800786:	ff 75 10             	pushl  0x10(%ebp)
  800789:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078c:	50                   	push   %eax
  80078d:	68 31 03 80 00       	push   $0x800331
  800792:	e8 d4 fb ff ff       	call   80036b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800797:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80079d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a0:	83 c4 10             	add    $0x10,%esp
  8007a3:	eb 05                	jmp    8007aa <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    

008007ac <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007b2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b5:	50                   	push   %eax
  8007b6:	ff 75 10             	pushl  0x10(%ebp)
  8007b9:	ff 75 0c             	pushl  0xc(%ebp)
  8007bc:	ff 75 08             	pushl  0x8(%ebp)
  8007bf:	e8 9a ff ff ff       	call   80075e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d1:	eb 03                	jmp    8007d6 <strlen+0x10>
		n++;
  8007d3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007da:	75 f7                	jne    8007d3 <strlen+0xd>
		n++;
	return n;
}
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ec:	eb 03                	jmp    8007f1 <strnlen+0x13>
		n++;
  8007ee:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f1:	39 c2                	cmp    %eax,%edx
  8007f3:	74 08                	je     8007fd <strnlen+0x1f>
  8007f5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007f9:	75 f3                	jne    8007ee <strnlen+0x10>
  8007fb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	53                   	push   %ebx
  800803:	8b 45 08             	mov    0x8(%ebp),%eax
  800806:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800809:	89 c2                	mov    %eax,%edx
  80080b:	83 c2 01             	add    $0x1,%edx
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800815:	88 5a ff             	mov    %bl,-0x1(%edx)
  800818:	84 db                	test   %bl,%bl
  80081a:	75 ef                	jne    80080b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80081c:	5b                   	pop    %ebx
  80081d:	5d                   	pop    %ebp
  80081e:	c3                   	ret    

0080081f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	53                   	push   %ebx
  800823:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800826:	53                   	push   %ebx
  800827:	e8 9a ff ff ff       	call   8007c6 <strlen>
  80082c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80082f:	ff 75 0c             	pushl  0xc(%ebp)
  800832:	01 d8                	add    %ebx,%eax
  800834:	50                   	push   %eax
  800835:	e8 c5 ff ff ff       	call   8007ff <strcpy>
	return dst;
}
  80083a:	89 d8                	mov    %ebx,%eax
  80083c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	56                   	push   %esi
  800845:	53                   	push   %ebx
  800846:	8b 75 08             	mov    0x8(%ebp),%esi
  800849:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80084c:	89 f3                	mov    %esi,%ebx
  80084e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800851:	89 f2                	mov    %esi,%edx
  800853:	eb 0f                	jmp    800864 <strncpy+0x23>
		*dst++ = *src;
  800855:	83 c2 01             	add    $0x1,%edx
  800858:	0f b6 01             	movzbl (%ecx),%eax
  80085b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085e:	80 39 01             	cmpb   $0x1,(%ecx)
  800861:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800864:	39 da                	cmp    %ebx,%edx
  800866:	75 ed                	jne    800855 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800868:	89 f0                	mov    %esi,%eax
  80086a:	5b                   	pop    %ebx
  80086b:	5e                   	pop    %esi
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	8b 75 08             	mov    0x8(%ebp),%esi
  800876:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800879:	8b 55 10             	mov    0x10(%ebp),%edx
  80087c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087e:	85 d2                	test   %edx,%edx
  800880:	74 21                	je     8008a3 <strlcpy+0x35>
  800882:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800886:	89 f2                	mov    %esi,%edx
  800888:	eb 09                	jmp    800893 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088a:	83 c2 01             	add    $0x1,%edx
  80088d:	83 c1 01             	add    $0x1,%ecx
  800890:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800893:	39 c2                	cmp    %eax,%edx
  800895:	74 09                	je     8008a0 <strlcpy+0x32>
  800897:	0f b6 19             	movzbl (%ecx),%ebx
  80089a:	84 db                	test   %bl,%bl
  80089c:	75 ec                	jne    80088a <strlcpy+0x1c>
  80089e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a3:	29 f0                	sub    %esi,%eax
}
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b2:	eb 06                	jmp    8008ba <strcmp+0x11>
		p++, q++;
  8008b4:	83 c1 01             	add    $0x1,%ecx
  8008b7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ba:	0f b6 01             	movzbl (%ecx),%eax
  8008bd:	84 c0                	test   %al,%al
  8008bf:	74 04                	je     8008c5 <strcmp+0x1c>
  8008c1:	3a 02                	cmp    (%edx),%al
  8008c3:	74 ef                	je     8008b4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c5:	0f b6 c0             	movzbl %al,%eax
  8008c8:	0f b6 12             	movzbl (%edx),%edx
  8008cb:	29 d0                	sub    %edx,%eax
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	53                   	push   %ebx
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d9:	89 c3                	mov    %eax,%ebx
  8008db:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008de:	eb 06                	jmp    8008e6 <strncmp+0x17>
		n--, p++, q++;
  8008e0:	83 c0 01             	add    $0x1,%eax
  8008e3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e6:	39 d8                	cmp    %ebx,%eax
  8008e8:	74 15                	je     8008ff <strncmp+0x30>
  8008ea:	0f b6 08             	movzbl (%eax),%ecx
  8008ed:	84 c9                	test   %cl,%cl
  8008ef:	74 04                	je     8008f5 <strncmp+0x26>
  8008f1:	3a 0a                	cmp    (%edx),%cl
  8008f3:	74 eb                	je     8008e0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f5:	0f b6 00             	movzbl (%eax),%eax
  8008f8:	0f b6 12             	movzbl (%edx),%edx
  8008fb:	29 d0                	sub    %edx,%eax
  8008fd:	eb 05                	jmp    800904 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800904:	5b                   	pop    %ebx
  800905:	5d                   	pop    %ebp
  800906:	c3                   	ret    

00800907 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800907:	55                   	push   %ebp
  800908:	89 e5                	mov    %esp,%ebp
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800911:	eb 07                	jmp    80091a <strchr+0x13>
		if (*s == c)
  800913:	38 ca                	cmp    %cl,%dl
  800915:	74 0f                	je     800926 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800917:	83 c0 01             	add    $0x1,%eax
  80091a:	0f b6 10             	movzbl (%eax),%edx
  80091d:	84 d2                	test   %dl,%dl
  80091f:	75 f2                	jne    800913 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800921:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800932:	eb 03                	jmp    800937 <strfind+0xf>
  800934:	83 c0 01             	add    $0x1,%eax
  800937:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093a:	38 ca                	cmp    %cl,%dl
  80093c:	74 04                	je     800942 <strfind+0x1a>
  80093e:	84 d2                	test   %dl,%dl
  800940:	75 f2                	jne    800934 <strfind+0xc>
			break;
	return (char *) s;
}
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	57                   	push   %edi
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80094d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800950:	85 c9                	test   %ecx,%ecx
  800952:	74 36                	je     80098a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800954:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095a:	75 28                	jne    800984 <memset+0x40>
  80095c:	f6 c1 03             	test   $0x3,%cl
  80095f:	75 23                	jne    800984 <memset+0x40>
		c &= 0xFF;
  800961:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800965:	89 d3                	mov    %edx,%ebx
  800967:	c1 e3 08             	shl    $0x8,%ebx
  80096a:	89 d6                	mov    %edx,%esi
  80096c:	c1 e6 18             	shl    $0x18,%esi
  80096f:	89 d0                	mov    %edx,%eax
  800971:	c1 e0 10             	shl    $0x10,%eax
  800974:	09 f0                	or     %esi,%eax
  800976:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800978:	89 d8                	mov    %ebx,%eax
  80097a:	09 d0                	or     %edx,%eax
  80097c:	c1 e9 02             	shr    $0x2,%ecx
  80097f:	fc                   	cld    
  800980:	f3 ab                	rep stos %eax,%es:(%edi)
  800982:	eb 06                	jmp    80098a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800984:	8b 45 0c             	mov    0xc(%ebp),%eax
  800987:	fc                   	cld    
  800988:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80098a:	89 f8                	mov    %edi,%eax
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	57                   	push   %edi
  800995:	56                   	push   %esi
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 75 0c             	mov    0xc(%ebp),%esi
  80099c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099f:	39 c6                	cmp    %eax,%esi
  8009a1:	73 35                	jae    8009d8 <memmove+0x47>
  8009a3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a6:	39 d0                	cmp    %edx,%eax
  8009a8:	73 2e                	jae    8009d8 <memmove+0x47>
		s += n;
		d += n;
  8009aa:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ad:	89 d6                	mov    %edx,%esi
  8009af:	09 fe                	or     %edi,%esi
  8009b1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b7:	75 13                	jne    8009cc <memmove+0x3b>
  8009b9:	f6 c1 03             	test   $0x3,%cl
  8009bc:	75 0e                	jne    8009cc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009be:	83 ef 04             	sub    $0x4,%edi
  8009c1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
  8009c7:	fd                   	std    
  8009c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ca:	eb 09                	jmp    8009d5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009cc:	83 ef 01             	sub    $0x1,%edi
  8009cf:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009d2:	fd                   	std    
  8009d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d5:	fc                   	cld    
  8009d6:	eb 1d                	jmp    8009f5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d8:	89 f2                	mov    %esi,%edx
  8009da:	09 c2                	or     %eax,%edx
  8009dc:	f6 c2 03             	test   $0x3,%dl
  8009df:	75 0f                	jne    8009f0 <memmove+0x5f>
  8009e1:	f6 c1 03             	test   $0x3,%cl
  8009e4:	75 0a                	jne    8009f0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009e6:	c1 e9 02             	shr    $0x2,%ecx
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	fc                   	cld    
  8009ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ee:	eb 05                	jmp    8009f5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f0:	89 c7                	mov    %eax,%edi
  8009f2:	fc                   	cld    
  8009f3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f5:	5e                   	pop    %esi
  8009f6:	5f                   	pop    %edi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009fc:	ff 75 10             	pushl  0x10(%ebp)
  8009ff:	ff 75 0c             	pushl  0xc(%ebp)
  800a02:	ff 75 08             	pushl  0x8(%ebp)
  800a05:	e8 87 ff ff ff       	call   800991 <memmove>
}
  800a0a:	c9                   	leave  
  800a0b:	c3                   	ret    

00800a0c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 45 08             	mov    0x8(%ebp),%eax
  800a14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a17:	89 c6                	mov    %eax,%esi
  800a19:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1c:	eb 1a                	jmp    800a38 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1e:	0f b6 08             	movzbl (%eax),%ecx
  800a21:	0f b6 1a             	movzbl (%edx),%ebx
  800a24:	38 d9                	cmp    %bl,%cl
  800a26:	74 0a                	je     800a32 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a28:	0f b6 c1             	movzbl %cl,%eax
  800a2b:	0f b6 db             	movzbl %bl,%ebx
  800a2e:	29 d8                	sub    %ebx,%eax
  800a30:	eb 0f                	jmp    800a41 <memcmp+0x35>
		s1++, s2++;
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a38:	39 f0                	cmp    %esi,%eax
  800a3a:	75 e2                	jne    800a1e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	53                   	push   %ebx
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a4c:	89 c1                	mov    %eax,%ecx
  800a4e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a51:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a55:	eb 0a                	jmp    800a61 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a57:	0f b6 10             	movzbl (%eax),%edx
  800a5a:	39 da                	cmp    %ebx,%edx
  800a5c:	74 07                	je     800a65 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5e:	83 c0 01             	add    $0x1,%eax
  800a61:	39 c8                	cmp    %ecx,%eax
  800a63:	72 f2                	jb     800a57 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a65:	5b                   	pop    %ebx
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	57                   	push   %edi
  800a6c:	56                   	push   %esi
  800a6d:	53                   	push   %ebx
  800a6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a71:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a74:	eb 03                	jmp    800a79 <strtol+0x11>
		s++;
  800a76:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a79:	0f b6 01             	movzbl (%ecx),%eax
  800a7c:	3c 20                	cmp    $0x20,%al
  800a7e:	74 f6                	je     800a76 <strtol+0xe>
  800a80:	3c 09                	cmp    $0x9,%al
  800a82:	74 f2                	je     800a76 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a84:	3c 2b                	cmp    $0x2b,%al
  800a86:	75 0a                	jne    800a92 <strtol+0x2a>
		s++;
  800a88:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a90:	eb 11                	jmp    800aa3 <strtol+0x3b>
  800a92:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a97:	3c 2d                	cmp    $0x2d,%al
  800a99:	75 08                	jne    800aa3 <strtol+0x3b>
		s++, neg = 1;
  800a9b:	83 c1 01             	add    $0x1,%ecx
  800a9e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa9:	75 15                	jne    800ac0 <strtol+0x58>
  800aab:	80 39 30             	cmpb   $0x30,(%ecx)
  800aae:	75 10                	jne    800ac0 <strtol+0x58>
  800ab0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab4:	75 7c                	jne    800b32 <strtol+0xca>
		s += 2, base = 16;
  800ab6:	83 c1 02             	add    $0x2,%ecx
  800ab9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abe:	eb 16                	jmp    800ad6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ac0:	85 db                	test   %ebx,%ebx
  800ac2:	75 12                	jne    800ad6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac9:	80 39 30             	cmpb   $0x30,(%ecx)
  800acc:	75 08                	jne    800ad6 <strtol+0x6e>
		s++, base = 8;
  800ace:	83 c1 01             	add    $0x1,%ecx
  800ad1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
  800adb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ade:	0f b6 11             	movzbl (%ecx),%edx
  800ae1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae4:	89 f3                	mov    %esi,%ebx
  800ae6:	80 fb 09             	cmp    $0x9,%bl
  800ae9:	77 08                	ja     800af3 <strtol+0x8b>
			dig = *s - '0';
  800aeb:	0f be d2             	movsbl %dl,%edx
  800aee:	83 ea 30             	sub    $0x30,%edx
  800af1:	eb 22                	jmp    800b15 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800af3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af6:	89 f3                	mov    %esi,%ebx
  800af8:	80 fb 19             	cmp    $0x19,%bl
  800afb:	77 08                	ja     800b05 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800afd:	0f be d2             	movsbl %dl,%edx
  800b00:	83 ea 57             	sub    $0x57,%edx
  800b03:	eb 10                	jmp    800b15 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b05:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b08:	89 f3                	mov    %esi,%ebx
  800b0a:	80 fb 19             	cmp    $0x19,%bl
  800b0d:	77 16                	ja     800b25 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b0f:	0f be d2             	movsbl %dl,%edx
  800b12:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b15:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b18:	7d 0b                	jge    800b25 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b1a:	83 c1 01             	add    $0x1,%ecx
  800b1d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b21:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b23:	eb b9                	jmp    800ade <strtol+0x76>

	if (endptr)
  800b25:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b29:	74 0d                	je     800b38 <strtol+0xd0>
		*endptr = (char *) s;
  800b2b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2e:	89 0e                	mov    %ecx,(%esi)
  800b30:	eb 06                	jmp    800b38 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b32:	85 db                	test   %ebx,%ebx
  800b34:	74 98                	je     800ace <strtol+0x66>
  800b36:	eb 9e                	jmp    800ad6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b38:	89 c2                	mov    %eax,%edx
  800b3a:	f7 da                	neg    %edx
  800b3c:	85 ff                	test   %edi,%edi
  800b3e:	0f 45 c2             	cmovne %edx,%eax
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    
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
