
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 60 00 00 00       	call   8000a5 <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800055:	e8 c9 00 00 00       	call   800123 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800062:	c1 e0 05             	shl    $0x5,%eax
  800065:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006a:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	85 db                	test   %ebx,%ebx
  800071:	7e 07                	jle    80007a <libmain+0x30>
		binaryname = argv[0];
  800073:	8b 06                	mov    (%esi),%eax
  800075:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007a:	83 ec 08             	sub    $0x8,%esp
  80007d:	56                   	push   %esi
  80007e:	53                   	push   %ebx
  80007f:	e8 af ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800084:	e8 0a 00 00 00       	call   800093 <exit>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    

00800093 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800099:	6a 00                	push   $0x0
  80009b:	e8 42 00 00 00       	call   8000e2 <sys_env_destroy>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	c9                   	leave  
  8000a4:	c3                   	ret    

008000a5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b6:	89 c3                	mov    %eax,%ebx
  8000b8:	89 c7                	mov    %eax,%edi
  8000ba:	89 c6                	mov    %eax,%esi
  8000bc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000be:	5b                   	pop    %ebx
  8000bf:	5e                   	pop    %esi
  8000c0:	5f                   	pop    %edi
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	57                   	push   %edi
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d3:	89 d1                	mov    %edx,%ecx
  8000d5:	89 d3                	mov    %edx,%ebx
  8000d7:	89 d7                	mov    %edx,%edi
  8000d9:	89 d6                	mov    %edx,%esi
  8000db:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	89 cb                	mov    %ecx,%ebx
  8000fa:	89 cf                	mov    %ecx,%edi
  8000fc:	89 ce                	mov    %ecx,%esi
  8000fe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800100:	85 c0                	test   %eax,%eax
  800102:	7e 17                	jle    80011b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800104:	83 ec 0c             	sub    $0xc,%esp
  800107:	50                   	push   %eax
  800108:	6a 03                	push   $0x3
  80010a:	68 de 0d 80 00       	push   $0x800dde
  80010f:	6a 23                	push   $0x23
  800111:	68 fb 0d 80 00       	push   $0x800dfb
  800116:	e8 3c 00 00 00       	call   800157 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5f                   	pop    %edi
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    

00800123 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	57                   	push   %edi
  800127:	56                   	push   %esi
  800128:	53                   	push   %ebx
  800129:	83 ec 14             	sub    $0x14,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012c:	ba 00 00 00 00       	mov    $0x0,%edx
  800131:	b8 02 00 00 00       	mov    $0x2,%eax
  800136:	89 d1                	mov    %edx,%ecx
  800138:	89 d3                	mov    %edx,%ebx
  80013a:	89 d7                	mov    %edx,%edi
  80013c:	89 d6                	mov    %edx,%esi
  80013e:	cd 30                	int    $0x30
  800140:	89 c3                	mov    %eax,%ebx

envid_t
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	cprintf("lib/syscall.c: %x\n", ret);
  800142:	50                   	push   %eax
  800143:	68 09 0e 80 00       	push   $0x800e09
  800148:	e8 e3 00 00 00       	call   800230 <cprintf>
	return ret;
}
  80014d:	89 d8                	mov    %ebx,%eax
  80014f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800152:	5b                   	pop    %ebx
  800153:	5e                   	pop    %esi
  800154:	5f                   	pop    %edi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800165:	e8 b9 ff ff ff       	call   800123 <sys_getenvid>
  80016a:	83 ec 0c             	sub    $0xc,%esp
  80016d:	ff 75 0c             	pushl  0xc(%ebp)
  800170:	ff 75 08             	pushl  0x8(%ebp)
  800173:	56                   	push   %esi
  800174:	50                   	push   %eax
  800175:	68 1c 0e 80 00       	push   $0x800e1c
  80017a:	e8 b1 00 00 00       	call   800230 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017f:	83 c4 18             	add    $0x18,%esp
  800182:	53                   	push   %ebx
  800183:	ff 75 10             	pushl  0x10(%ebp)
  800186:	e8 54 00 00 00       	call   8001df <vcprintf>
	cprintf("\n");
  80018b:	c7 04 24 1a 0e 80 00 	movl   $0x800e1a,(%esp)
  800192:	e8 99 00 00 00       	call   800230 <cprintf>
  800197:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019a:	cc                   	int3   
  80019b:	eb fd                	jmp    80019a <_panic+0x43>

0080019d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 04             	sub    $0x4,%esp
  8001a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a7:	8b 13                	mov    (%ebx),%edx
  8001a9:	8d 42 01             	lea    0x1(%edx),%eax
  8001ac:	89 03                	mov    %eax,(%ebx)
  8001ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ba:	75 1a                	jne    8001d6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	68 ff 00 00 00       	push   $0xff
  8001c4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c7:	50                   	push   %eax
  8001c8:	e8 d8 fe ff ff       	call   8000a5 <sys_cputs>
		b->idx = 0;
  8001cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ef:	00 00 00 
	b.cnt = 0;
  8001f2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fc:	ff 75 0c             	pushl  0xc(%ebp)
  8001ff:	ff 75 08             	pushl  0x8(%ebp)
  800202:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	68 9d 01 80 00       	push   $0x80019d
  80020e:	e8 54 01 00 00       	call   800367 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800213:	83 c4 08             	add    $0x8,%esp
  800216:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800222:	50                   	push   %eax
  800223:	e8 7d fe ff ff       	call   8000a5 <sys_cputs>

	return b.cnt;
}
  800228:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800236:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800239:	50                   	push   %eax
  80023a:	ff 75 08             	pushl  0x8(%ebp)
  80023d:	e8 9d ff ff ff       	call   8001df <vcprintf>
	va_end(ap);

	return cnt;
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	57                   	push   %edi
  800248:	56                   	push   %esi
  800249:	53                   	push   %ebx
  80024a:	83 ec 1c             	sub    $0x1c,%esp
  80024d:	89 c7                	mov    %eax,%edi
  80024f:	89 d6                	mov    %edx,%esi
  800251:	8b 45 08             	mov    0x8(%ebp),%eax
  800254:	8b 55 0c             	mov    0xc(%ebp),%edx
  800257:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800260:	bb 00 00 00 00       	mov    $0x0,%ebx
  800265:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800268:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026b:	39 d3                	cmp    %edx,%ebx
  80026d:	72 05                	jb     800274 <printnum+0x30>
  80026f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800272:	77 45                	ja     8002b9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800274:	83 ec 0c             	sub    $0xc,%esp
  800277:	ff 75 18             	pushl  0x18(%ebp)
  80027a:	8b 45 14             	mov    0x14(%ebp),%eax
  80027d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800280:	53                   	push   %ebx
  800281:	ff 75 10             	pushl  0x10(%ebp)
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028a:	ff 75 e0             	pushl  -0x20(%ebp)
  80028d:	ff 75 dc             	pushl  -0x24(%ebp)
  800290:	ff 75 d8             	pushl  -0x28(%ebp)
  800293:	e8 b8 08 00 00       	call   800b50 <__udivdi3>
  800298:	83 c4 18             	add    $0x18,%esp
  80029b:	52                   	push   %edx
  80029c:	50                   	push   %eax
  80029d:	89 f2                	mov    %esi,%edx
  80029f:	89 f8                	mov    %edi,%eax
  8002a1:	e8 9e ff ff ff       	call   800244 <printnum>
  8002a6:	83 c4 20             	add    $0x20,%esp
  8002a9:	eb 18                	jmp    8002c3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	56                   	push   %esi
  8002af:	ff 75 18             	pushl  0x18(%ebp)
  8002b2:	ff d7                	call   *%edi
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	eb 03                	jmp    8002bc <printnum+0x78>
  8002b9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bc:	83 eb 01             	sub    $0x1,%ebx
  8002bf:	85 db                	test   %ebx,%ebx
  8002c1:	7f e8                	jg     8002ab <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c3:	83 ec 08             	sub    $0x8,%esp
  8002c6:	56                   	push   %esi
  8002c7:	83 ec 04             	sub    $0x4,%esp
  8002ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d6:	e8 a5 09 00 00       	call   800c80 <__umoddi3>
  8002db:	83 c4 14             	add    $0x14,%esp
  8002de:	0f be 80 40 0e 80 00 	movsbl 0x800e40(%eax),%eax
  8002e5:	50                   	push   %eax
  8002e6:	ff d7                	call   *%edi
}
  8002e8:	83 c4 10             	add    $0x10,%esp
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f6:	83 fa 01             	cmp    $0x1,%edx
  8002f9:	7e 0e                	jle    800309 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fb:	8b 10                	mov    (%eax),%edx
  8002fd:	8d 4a 08             	lea    0x8(%edx),%ecx
  800300:	89 08                	mov    %ecx,(%eax)
  800302:	8b 02                	mov    (%edx),%eax
  800304:	8b 52 04             	mov    0x4(%edx),%edx
  800307:	eb 22                	jmp    80032b <getuint+0x38>
	else if (lflag)
  800309:	85 d2                	test   %edx,%edx
  80030b:	74 10                	je     80031d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030d:	8b 10                	mov    (%eax),%edx
  80030f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800312:	89 08                	mov    %ecx,(%eax)
  800314:	8b 02                	mov    (%edx),%eax
  800316:	ba 00 00 00 00       	mov    $0x0,%edx
  80031b:	eb 0e                	jmp    80032b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031d:	8b 10                	mov    (%eax),%edx
  80031f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800322:	89 08                	mov    %ecx,(%eax)
  800324:	8b 02                	mov    (%edx),%eax
  800326:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800333:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800337:	8b 10                	mov    (%eax),%edx
  800339:	3b 50 04             	cmp    0x4(%eax),%edx
  80033c:	73 0a                	jae    800348 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800341:	89 08                	mov    %ecx,(%eax)
  800343:	8b 45 08             	mov    0x8(%ebp),%eax
  800346:	88 02                	mov    %al,(%edx)
}
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    

0080034a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800350:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800353:	50                   	push   %eax
  800354:	ff 75 10             	pushl  0x10(%ebp)
  800357:	ff 75 0c             	pushl  0xc(%ebp)
  80035a:	ff 75 08             	pushl  0x8(%ebp)
  80035d:	e8 05 00 00 00       	call   800367 <vprintfmt>
	va_end(ap);
}
  800362:	83 c4 10             	add    $0x10,%esp
  800365:	c9                   	leave  
  800366:	c3                   	ret    

00800367 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
  80036a:	57                   	push   %edi
  80036b:	56                   	push   %esi
  80036c:	53                   	push   %ebx
  80036d:	83 ec 2c             	sub    $0x2c,%esp
  800370:	8b 75 08             	mov    0x8(%ebp),%esi
  800373:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800376:	8b 7d 10             	mov    0x10(%ebp),%edi
  800379:	eb 1d                	jmp    800398 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80037b:	85 c0                	test   %eax,%eax
  80037d:	75 0f                	jne    80038e <vprintfmt+0x27>
				csa = 0x0700;
  80037f:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  800386:	07 00 00 
				return;
  800389:	e9 c4 03 00 00       	jmp    800752 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  80038e:	83 ec 08             	sub    $0x8,%esp
  800391:	53                   	push   %ebx
  800392:	50                   	push   %eax
  800393:	ff d6                	call   *%esi
  800395:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800398:	83 c7 01             	add    $0x1,%edi
  80039b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80039f:	83 f8 25             	cmp    $0x25,%eax
  8003a2:	75 d7                	jne    80037b <vprintfmt+0x14>
  8003a4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003af:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c2:	eb 07                	jmp    8003cb <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8d 47 01             	lea    0x1(%edi),%eax
  8003ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d1:	0f b6 07             	movzbl (%edi),%eax
  8003d4:	0f b6 c8             	movzbl %al,%ecx
  8003d7:	83 e8 23             	sub    $0x23,%eax
  8003da:	3c 55                	cmp    $0x55,%al
  8003dc:	0f 87 55 03 00 00    	ja     800737 <vprintfmt+0x3d0>
  8003e2:	0f b6 c0             	movzbl %al,%eax
  8003e5:	ff 24 85 d0 0e 80 00 	jmp    *0x800ed0(,%eax,4)
  8003ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ef:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f3:	eb d6                	jmp    8003cb <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800400:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800403:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800407:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80040a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80040d:	83 fa 09             	cmp    $0x9,%edx
  800410:	77 39                	ja     80044b <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800412:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800415:	eb e9                	jmp    800400 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 48 04             	lea    0x4(%eax),%ecx
  80041d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800420:	8b 00                	mov    (%eax),%eax
  800422:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800428:	eb 27                	jmp    800451 <vprintfmt+0xea>
  80042a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042d:	85 c0                	test   %eax,%eax
  80042f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800434:	0f 49 c8             	cmovns %eax,%ecx
  800437:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043d:	eb 8c                	jmp    8003cb <vprintfmt+0x64>
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800442:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800449:	eb 80                	jmp    8003cb <vprintfmt+0x64>
  80044b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80044e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800451:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800455:	0f 89 70 ff ff ff    	jns    8003cb <vprintfmt+0x64>
				width = precision, precision = -1;
  80045b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800461:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800468:	e9 5e ff ff ff       	jmp    8003cb <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800473:	e9 53 ff ff ff       	jmp    8003cb <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 50 04             	lea    0x4(%eax),%edx
  80047e:	89 55 14             	mov    %edx,0x14(%ebp)
  800481:	83 ec 08             	sub    $0x8,%esp
  800484:	53                   	push   %ebx
  800485:	ff 30                	pushl  (%eax)
  800487:	ff d6                	call   *%esi
			break;
  800489:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048f:	e9 04 ff ff ff       	jmp    800398 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	8d 50 04             	lea    0x4(%eax),%edx
  80049a:	89 55 14             	mov    %edx,0x14(%ebp)
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	99                   	cltd   
  8004a0:	31 d0                	xor    %edx,%eax
  8004a2:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a4:	83 f8 06             	cmp    $0x6,%eax
  8004a7:	7f 0b                	jg     8004b4 <vprintfmt+0x14d>
  8004a9:	8b 14 85 28 10 80 00 	mov    0x801028(,%eax,4),%edx
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	75 18                	jne    8004cc <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8004b4:	50                   	push   %eax
  8004b5:	68 58 0e 80 00       	push   $0x800e58
  8004ba:	53                   	push   %ebx
  8004bb:	56                   	push   %esi
  8004bc:	e8 89 fe ff ff       	call   80034a <printfmt>
  8004c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c7:	e9 cc fe ff ff       	jmp    800398 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8004cc:	52                   	push   %edx
  8004cd:	68 61 0e 80 00       	push   $0x800e61
  8004d2:	53                   	push   %ebx
  8004d3:	56                   	push   %esi
  8004d4:	e8 71 fe ff ff       	call   80034a <printfmt>
  8004d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004df:	e9 b4 fe ff ff       	jmp    800398 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8d 50 04             	lea    0x4(%eax),%edx
  8004ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ed:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ef:	85 ff                	test   %edi,%edi
  8004f1:	b8 51 0e 80 00       	mov    $0x800e51,%eax
  8004f6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fd:	0f 8e 94 00 00 00    	jle    800597 <vprintfmt+0x230>
  800503:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800507:	0f 84 98 00 00 00    	je     8005a5 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	ff 75 d0             	pushl  -0x30(%ebp)
  800513:	57                   	push   %edi
  800514:	e8 c1 02 00 00       	call   8007da <strnlen>
  800519:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80051c:	29 c1                	sub    %eax,%ecx
  80051e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800521:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800524:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800528:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80052e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800530:	eb 0f                	jmp    800541 <vprintfmt+0x1da>
					putch(padc, putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	53                   	push   %ebx
  800536:	ff 75 e0             	pushl  -0x20(%ebp)
  800539:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80053b:	83 ef 01             	sub    $0x1,%edi
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	85 ff                	test   %edi,%edi
  800543:	7f ed                	jg     800532 <vprintfmt+0x1cb>
  800545:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800548:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80054b:	85 c9                	test   %ecx,%ecx
  80054d:	b8 00 00 00 00       	mov    $0x0,%eax
  800552:	0f 49 c1             	cmovns %ecx,%eax
  800555:	29 c1                	sub    %eax,%ecx
  800557:	89 75 08             	mov    %esi,0x8(%ebp)
  80055a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800560:	89 cb                	mov    %ecx,%ebx
  800562:	eb 4d                	jmp    8005b1 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800564:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800568:	74 1b                	je     800585 <vprintfmt+0x21e>
  80056a:	0f be c0             	movsbl %al,%eax
  80056d:	83 e8 20             	sub    $0x20,%eax
  800570:	83 f8 5e             	cmp    $0x5e,%eax
  800573:	76 10                	jbe    800585 <vprintfmt+0x21e>
					putch('?', putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	ff 75 0c             	pushl  0xc(%ebp)
  80057b:	6a 3f                	push   $0x3f
  80057d:	ff 55 08             	call   *0x8(%ebp)
  800580:	83 c4 10             	add    $0x10,%esp
  800583:	eb 0d                	jmp    800592 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800585:	83 ec 08             	sub    $0x8,%esp
  800588:	ff 75 0c             	pushl  0xc(%ebp)
  80058b:	52                   	push   %edx
  80058c:	ff 55 08             	call   *0x8(%ebp)
  80058f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800592:	83 eb 01             	sub    $0x1,%ebx
  800595:	eb 1a                	jmp    8005b1 <vprintfmt+0x24a>
  800597:	89 75 08             	mov    %esi,0x8(%ebp)
  80059a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a3:	eb 0c                	jmp    8005b1 <vprintfmt+0x24a>
  8005a5:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ab:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ae:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005b1:	83 c7 01             	add    $0x1,%edi
  8005b4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b8:	0f be d0             	movsbl %al,%edx
  8005bb:	85 d2                	test   %edx,%edx
  8005bd:	74 23                	je     8005e2 <vprintfmt+0x27b>
  8005bf:	85 f6                	test   %esi,%esi
  8005c1:	78 a1                	js     800564 <vprintfmt+0x1fd>
  8005c3:	83 ee 01             	sub    $0x1,%esi
  8005c6:	79 9c                	jns    800564 <vprintfmt+0x1fd>
  8005c8:	89 df                	mov    %ebx,%edi
  8005ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8005cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d0:	eb 18                	jmp    8005ea <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	6a 20                	push   $0x20
  8005d8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005da:	83 ef 01             	sub    $0x1,%edi
  8005dd:	83 c4 10             	add    $0x10,%esp
  8005e0:	eb 08                	jmp    8005ea <vprintfmt+0x283>
  8005e2:	89 df                	mov    %ebx,%edi
  8005e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005ea:	85 ff                	test   %edi,%edi
  8005ec:	7f e4                	jg     8005d2 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f1:	e9 a2 fd ff ff       	jmp    800398 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f6:	83 fa 01             	cmp    $0x1,%edx
  8005f9:	7e 16                	jle    800611 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 08             	lea    0x8(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)
  800604:	8b 50 04             	mov    0x4(%eax),%edx
  800607:	8b 00                	mov    (%eax),%eax
  800609:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060f:	eb 32                	jmp    800643 <vprintfmt+0x2dc>
	else if (lflag)
  800611:	85 d2                	test   %edx,%edx
  800613:	74 18                	je     80062d <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8d 50 04             	lea    0x4(%eax),%edx
  80061b:	89 55 14             	mov    %edx,0x14(%ebp)
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800623:	89 c1                	mov    %eax,%ecx
  800625:	c1 f9 1f             	sar    $0x1f,%ecx
  800628:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80062b:	eb 16                	jmp    800643 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  80062d:	8b 45 14             	mov    0x14(%ebp),%eax
  800630:	8d 50 04             	lea    0x4(%eax),%edx
  800633:	89 55 14             	mov    %edx,0x14(%ebp)
  800636:	8b 00                	mov    (%eax),%eax
  800638:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063b:	89 c1                	mov    %eax,%ecx
  80063d:	c1 f9 1f             	sar    $0x1f,%ecx
  800640:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800643:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800646:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800649:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800652:	79 74                	jns    8006c8 <vprintfmt+0x361>
				putch('-', putdat);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 2d                	push   $0x2d
  80065a:	ff d6                	call   *%esi
				num = -(long long) num;
  80065c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800662:	f7 d8                	neg    %eax
  800664:	83 d2 00             	adc    $0x0,%edx
  800667:	f7 da                	neg    %edx
  800669:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80066c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800671:	eb 55                	jmp    8006c8 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800673:	8d 45 14             	lea    0x14(%ebp),%eax
  800676:	e8 78 fc ff ff       	call   8002f3 <getuint>
			base = 10;
  80067b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800680:	eb 46                	jmp    8006c8 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800682:	8d 45 14             	lea    0x14(%ebp),%eax
  800685:	e8 69 fc ff ff       	call   8002f3 <getuint>
      base = 8;
  80068a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80068f:	eb 37                	jmp    8006c8 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	6a 30                	push   $0x30
  800697:	ff d6                	call   *%esi
			putch('x', putdat);
  800699:	83 c4 08             	add    $0x8,%esp
  80069c:	53                   	push   %ebx
  80069d:	6a 78                	push   $0x78
  80069f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8d 50 04             	lea    0x4(%eax),%edx
  8006a7:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006aa:	8b 00                	mov    (%eax),%eax
  8006ac:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b9:	eb 0d                	jmp    8006c8 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 30 fc ff ff       	call   8002f3 <getuint>
			base = 16;
  8006c3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c8:	83 ec 0c             	sub    $0xc,%esp
  8006cb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006cf:	57                   	push   %edi
  8006d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d3:	51                   	push   %ecx
  8006d4:	52                   	push   %edx
  8006d5:	50                   	push   %eax
  8006d6:	89 da                	mov    %ebx,%edx
  8006d8:	89 f0                	mov    %esi,%eax
  8006da:	e8 65 fb ff ff       	call   800244 <printnum>
			break;
  8006df:	83 c4 20             	add    $0x20,%esp
  8006e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e5:	e9 ae fc ff ff       	jmp    800398 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	51                   	push   %ecx
  8006ef:	ff d6                	call   *%esi
			break;
  8006f1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f7:	e9 9c fc ff ff       	jmp    800398 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006fc:	83 fa 01             	cmp    $0x1,%edx
  8006ff:	7e 0d                	jle    80070e <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 08             	lea    0x8(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	eb 1c                	jmp    80072a <vprintfmt+0x3c3>
	else if (lflag)
  80070e:	85 d2                	test   %edx,%edx
  800710:	74 0d                	je     80071f <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8d 50 04             	lea    0x4(%eax),%edx
  800718:	89 55 14             	mov    %edx,0x14(%ebp)
  80071b:	8b 00                	mov    (%eax),%eax
  80071d:	eb 0b                	jmp    80072a <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  80071f:	8b 45 14             	mov    0x14(%ebp),%eax
  800722:	8d 50 04             	lea    0x4(%eax),%edx
  800725:	89 55 14             	mov    %edx,0x14(%ebp)
  800728:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  80072a:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  800732:	e9 61 fc ff ff       	jmp    800398 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	53                   	push   %ebx
  80073b:	6a 25                	push   $0x25
  80073d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	eb 03                	jmp    800747 <vprintfmt+0x3e0>
  800744:	83 ef 01             	sub    $0x1,%edi
  800747:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80074b:	75 f7                	jne    800744 <vprintfmt+0x3dd>
  80074d:	e9 46 fc ff ff       	jmp    800398 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800752:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800755:	5b                   	pop    %ebx
  800756:	5e                   	pop    %esi
  800757:	5f                   	pop    %edi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	83 ec 18             	sub    $0x18,%esp
  800760:	8b 45 08             	mov    0x8(%ebp),%eax
  800763:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800766:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800769:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800770:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800777:	85 c0                	test   %eax,%eax
  800779:	74 26                	je     8007a1 <vsnprintf+0x47>
  80077b:	85 d2                	test   %edx,%edx
  80077d:	7e 22                	jle    8007a1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077f:	ff 75 14             	pushl  0x14(%ebp)
  800782:	ff 75 10             	pushl  0x10(%ebp)
  800785:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800788:	50                   	push   %eax
  800789:	68 2d 03 80 00       	push   $0x80032d
  80078e:	e8 d4 fb ff ff       	call   800367 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800793:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800796:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800799:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079c:	83 c4 10             	add    $0x10,%esp
  80079f:	eb 05                	jmp    8007a6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ae:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b1:	50                   	push   %eax
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	ff 75 08             	pushl  0x8(%ebp)
  8007bb:	e8 9a ff ff ff       	call   80075a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cd:	eb 03                	jmp    8007d2 <strlen+0x10>
		n++;
  8007cf:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d6:	75 f7                	jne    8007cf <strlen+0xd>
		n++;
	return n;
}
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e8:	eb 03                	jmp    8007ed <strnlen+0x13>
		n++;
  8007ea:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ed:	39 c2                	cmp    %eax,%edx
  8007ef:	74 08                	je     8007f9 <strnlen+0x1f>
  8007f1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007f5:	75 f3                	jne    8007ea <strnlen+0x10>
  8007f7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800805:	89 c2                	mov    %eax,%edx
  800807:	83 c2 01             	add    $0x1,%edx
  80080a:	83 c1 01             	add    $0x1,%ecx
  80080d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800811:	88 5a ff             	mov    %bl,-0x1(%edx)
  800814:	84 db                	test   %bl,%bl
  800816:	75 ef                	jne    800807 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800818:	5b                   	pop    %ebx
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800822:	53                   	push   %ebx
  800823:	e8 9a ff ff ff       	call   8007c2 <strlen>
  800828:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	01 d8                	add    %ebx,%eax
  800830:	50                   	push   %eax
  800831:	e8 c5 ff ff ff       	call   8007fb <strcpy>
	return dst;
}
  800836:	89 d8                	mov    %ebx,%eax
  800838:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	56                   	push   %esi
  800841:	53                   	push   %ebx
  800842:	8b 75 08             	mov    0x8(%ebp),%esi
  800845:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800848:	89 f3                	mov    %esi,%ebx
  80084a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084d:	89 f2                	mov    %esi,%edx
  80084f:	eb 0f                	jmp    800860 <strncpy+0x23>
		*dst++ = *src;
  800851:	83 c2 01             	add    $0x1,%edx
  800854:	0f b6 01             	movzbl (%ecx),%eax
  800857:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80085a:	80 39 01             	cmpb   $0x1,(%ecx)
  80085d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800860:	39 da                	cmp    %ebx,%edx
  800862:	75 ed                	jne    800851 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800864:	89 f0                	mov    %esi,%eax
  800866:	5b                   	pop    %ebx
  800867:	5e                   	pop    %esi
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	56                   	push   %esi
  80086e:	53                   	push   %ebx
  80086f:	8b 75 08             	mov    0x8(%ebp),%esi
  800872:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800875:	8b 55 10             	mov    0x10(%ebp),%edx
  800878:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80087a:	85 d2                	test   %edx,%edx
  80087c:	74 21                	je     80089f <strlcpy+0x35>
  80087e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800882:	89 f2                	mov    %esi,%edx
  800884:	eb 09                	jmp    80088f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800886:	83 c2 01             	add    $0x1,%edx
  800889:	83 c1 01             	add    $0x1,%ecx
  80088c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80088f:	39 c2                	cmp    %eax,%edx
  800891:	74 09                	je     80089c <strlcpy+0x32>
  800893:	0f b6 19             	movzbl (%ecx),%ebx
  800896:	84 db                	test   %bl,%bl
  800898:	75 ec                	jne    800886 <strlcpy+0x1c>
  80089a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80089c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80089f:	29 f0                	sub    %esi,%eax
}
  8008a1:	5b                   	pop    %ebx
  8008a2:	5e                   	pop    %esi
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ae:	eb 06                	jmp    8008b6 <strcmp+0x11>
		p++, q++;
  8008b0:	83 c1 01             	add    $0x1,%ecx
  8008b3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b6:	0f b6 01             	movzbl (%ecx),%eax
  8008b9:	84 c0                	test   %al,%al
  8008bb:	74 04                	je     8008c1 <strcmp+0x1c>
  8008bd:	3a 02                	cmp    (%edx),%al
  8008bf:	74 ef                	je     8008b0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c1:	0f b6 c0             	movzbl %al,%eax
  8008c4:	0f b6 12             	movzbl (%edx),%edx
  8008c7:	29 d0                	sub    %edx,%eax
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	53                   	push   %ebx
  8008cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d5:	89 c3                	mov    %eax,%ebx
  8008d7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008da:	eb 06                	jmp    8008e2 <strncmp+0x17>
		n--, p++, q++;
  8008dc:	83 c0 01             	add    $0x1,%eax
  8008df:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e2:	39 d8                	cmp    %ebx,%eax
  8008e4:	74 15                	je     8008fb <strncmp+0x30>
  8008e6:	0f b6 08             	movzbl (%eax),%ecx
  8008e9:	84 c9                	test   %cl,%cl
  8008eb:	74 04                	je     8008f1 <strncmp+0x26>
  8008ed:	3a 0a                	cmp    (%edx),%cl
  8008ef:	74 eb                	je     8008dc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f1:	0f b6 00             	movzbl (%eax),%eax
  8008f4:	0f b6 12             	movzbl (%edx),%edx
  8008f7:	29 d0                	sub    %edx,%eax
  8008f9:	eb 05                	jmp    800900 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800900:	5b                   	pop    %ebx
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090d:	eb 07                	jmp    800916 <strchr+0x13>
		if (*s == c)
  80090f:	38 ca                	cmp    %cl,%dl
  800911:	74 0f                	je     800922 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800913:	83 c0 01             	add    $0x1,%eax
  800916:	0f b6 10             	movzbl (%eax),%edx
  800919:	84 d2                	test   %dl,%dl
  80091b:	75 f2                	jne    80090f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80091d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092e:	eb 03                	jmp    800933 <strfind+0xf>
  800930:	83 c0 01             	add    $0x1,%eax
  800933:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800936:	38 ca                	cmp    %cl,%dl
  800938:	74 04                	je     80093e <strfind+0x1a>
  80093a:	84 d2                	test   %dl,%dl
  80093c:	75 f2                	jne    800930 <strfind+0xc>
			break;
	return (char *) s;
}
  80093e:	5d                   	pop    %ebp
  80093f:	c3                   	ret    

00800940 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	57                   	push   %edi
  800944:	56                   	push   %esi
  800945:	53                   	push   %ebx
  800946:	8b 7d 08             	mov    0x8(%ebp),%edi
  800949:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80094c:	85 c9                	test   %ecx,%ecx
  80094e:	74 36                	je     800986 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800950:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800956:	75 28                	jne    800980 <memset+0x40>
  800958:	f6 c1 03             	test   $0x3,%cl
  80095b:	75 23                	jne    800980 <memset+0x40>
		c &= 0xFF;
  80095d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800961:	89 d3                	mov    %edx,%ebx
  800963:	c1 e3 08             	shl    $0x8,%ebx
  800966:	89 d6                	mov    %edx,%esi
  800968:	c1 e6 18             	shl    $0x18,%esi
  80096b:	89 d0                	mov    %edx,%eax
  80096d:	c1 e0 10             	shl    $0x10,%eax
  800970:	09 f0                	or     %esi,%eax
  800972:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800974:	89 d8                	mov    %ebx,%eax
  800976:	09 d0                	or     %edx,%eax
  800978:	c1 e9 02             	shr    $0x2,%ecx
  80097b:	fc                   	cld    
  80097c:	f3 ab                	rep stos %eax,%es:(%edi)
  80097e:	eb 06                	jmp    800986 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800980:	8b 45 0c             	mov    0xc(%ebp),%eax
  800983:	fc                   	cld    
  800984:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800986:	89 f8                	mov    %edi,%eax
  800988:	5b                   	pop    %ebx
  800989:	5e                   	pop    %esi
  80098a:	5f                   	pop    %edi
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	57                   	push   %edi
  800991:	56                   	push   %esi
  800992:	8b 45 08             	mov    0x8(%ebp),%eax
  800995:	8b 75 0c             	mov    0xc(%ebp),%esi
  800998:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80099b:	39 c6                	cmp    %eax,%esi
  80099d:	73 35                	jae    8009d4 <memmove+0x47>
  80099f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009a2:	39 d0                	cmp    %edx,%eax
  8009a4:	73 2e                	jae    8009d4 <memmove+0x47>
		s += n;
		d += n;
  8009a6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a9:	89 d6                	mov    %edx,%esi
  8009ab:	09 fe                	or     %edi,%esi
  8009ad:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b3:	75 13                	jne    8009c8 <memmove+0x3b>
  8009b5:	f6 c1 03             	test   $0x3,%cl
  8009b8:	75 0e                	jne    8009c8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009ba:	83 ef 04             	sub    $0x4,%edi
  8009bd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009c0:	c1 e9 02             	shr    $0x2,%ecx
  8009c3:	fd                   	std    
  8009c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c6:	eb 09                	jmp    8009d1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c8:	83 ef 01             	sub    $0x1,%edi
  8009cb:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ce:	fd                   	std    
  8009cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009d1:	fc                   	cld    
  8009d2:	eb 1d                	jmp    8009f1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d4:	89 f2                	mov    %esi,%edx
  8009d6:	09 c2                	or     %eax,%edx
  8009d8:	f6 c2 03             	test   $0x3,%dl
  8009db:	75 0f                	jne    8009ec <memmove+0x5f>
  8009dd:	f6 c1 03             	test   $0x3,%cl
  8009e0:	75 0a                	jne    8009ec <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009e2:	c1 e9 02             	shr    $0x2,%ecx
  8009e5:	89 c7                	mov    %eax,%edi
  8009e7:	fc                   	cld    
  8009e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ea:	eb 05                	jmp    8009f1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009ec:	89 c7                	mov    %eax,%edi
  8009ee:	fc                   	cld    
  8009ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009f1:	5e                   	pop    %esi
  8009f2:	5f                   	pop    %edi
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f8:	ff 75 10             	pushl  0x10(%ebp)
  8009fb:	ff 75 0c             	pushl  0xc(%ebp)
  8009fe:	ff 75 08             	pushl  0x8(%ebp)
  800a01:	e8 87 ff ff ff       	call   80098d <memmove>
}
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a13:	89 c6                	mov    %eax,%esi
  800a15:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a18:	eb 1a                	jmp    800a34 <memcmp+0x2c>
		if (*s1 != *s2)
  800a1a:	0f b6 08             	movzbl (%eax),%ecx
  800a1d:	0f b6 1a             	movzbl (%edx),%ebx
  800a20:	38 d9                	cmp    %bl,%cl
  800a22:	74 0a                	je     800a2e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a24:	0f b6 c1             	movzbl %cl,%eax
  800a27:	0f b6 db             	movzbl %bl,%ebx
  800a2a:	29 d8                	sub    %ebx,%eax
  800a2c:	eb 0f                	jmp    800a3d <memcmp+0x35>
		s1++, s2++;
  800a2e:	83 c0 01             	add    $0x1,%eax
  800a31:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a34:	39 f0                	cmp    %esi,%eax
  800a36:	75 e2                	jne    800a1a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3d:	5b                   	pop    %ebx
  800a3e:	5e                   	pop    %esi
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	53                   	push   %ebx
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a48:	89 c1                	mov    %eax,%ecx
  800a4a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a51:	eb 0a                	jmp    800a5d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a53:	0f b6 10             	movzbl (%eax),%edx
  800a56:	39 da                	cmp    %ebx,%edx
  800a58:	74 07                	je     800a61 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	39 c8                	cmp    %ecx,%eax
  800a5f:	72 f2                	jb     800a53 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a61:	5b                   	pop    %ebx
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a70:	eb 03                	jmp    800a75 <strtol+0x11>
		s++;
  800a72:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a75:	0f b6 01             	movzbl (%ecx),%eax
  800a78:	3c 20                	cmp    $0x20,%al
  800a7a:	74 f6                	je     800a72 <strtol+0xe>
  800a7c:	3c 09                	cmp    $0x9,%al
  800a7e:	74 f2                	je     800a72 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a80:	3c 2b                	cmp    $0x2b,%al
  800a82:	75 0a                	jne    800a8e <strtol+0x2a>
		s++;
  800a84:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a87:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8c:	eb 11                	jmp    800a9f <strtol+0x3b>
  800a8e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a93:	3c 2d                	cmp    $0x2d,%al
  800a95:	75 08                	jne    800a9f <strtol+0x3b>
		s++, neg = 1;
  800a97:	83 c1 01             	add    $0x1,%ecx
  800a9a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa5:	75 15                	jne    800abc <strtol+0x58>
  800aa7:	80 39 30             	cmpb   $0x30,(%ecx)
  800aaa:	75 10                	jne    800abc <strtol+0x58>
  800aac:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ab0:	75 7c                	jne    800b2e <strtol+0xca>
		s += 2, base = 16;
  800ab2:	83 c1 02             	add    $0x2,%ecx
  800ab5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aba:	eb 16                	jmp    800ad2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800abc:	85 db                	test   %ebx,%ebx
  800abe:	75 12                	jne    800ad2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac8:	75 08                	jne    800ad2 <strtol+0x6e>
		s++, base = 8;
  800aca:	83 c1 01             	add    $0x1,%ecx
  800acd:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ada:	0f b6 11             	movzbl (%ecx),%edx
  800add:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ae0:	89 f3                	mov    %esi,%ebx
  800ae2:	80 fb 09             	cmp    $0x9,%bl
  800ae5:	77 08                	ja     800aef <strtol+0x8b>
			dig = *s - '0';
  800ae7:	0f be d2             	movsbl %dl,%edx
  800aea:	83 ea 30             	sub    $0x30,%edx
  800aed:	eb 22                	jmp    800b11 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aef:	8d 72 9f             	lea    -0x61(%edx),%esi
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	80 fb 19             	cmp    $0x19,%bl
  800af7:	77 08                	ja     800b01 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af9:	0f be d2             	movsbl %dl,%edx
  800afc:	83 ea 57             	sub    $0x57,%edx
  800aff:	eb 10                	jmp    800b11 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b01:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b04:	89 f3                	mov    %esi,%ebx
  800b06:	80 fb 19             	cmp    $0x19,%bl
  800b09:	77 16                	ja     800b21 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b0b:	0f be d2             	movsbl %dl,%edx
  800b0e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b11:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b14:	7d 0b                	jge    800b21 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b16:	83 c1 01             	add    $0x1,%ecx
  800b19:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b1f:	eb b9                	jmp    800ada <strtol+0x76>

	if (endptr)
  800b21:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b25:	74 0d                	je     800b34 <strtol+0xd0>
		*endptr = (char *) s;
  800b27:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b2a:	89 0e                	mov    %ecx,(%esi)
  800b2c:	eb 06                	jmp    800b34 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2e:	85 db                	test   %ebx,%ebx
  800b30:	74 98                	je     800aca <strtol+0x66>
  800b32:	eb 9e                	jmp    800ad2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b34:	89 c2                	mov    %eax,%edx
  800b36:	f7 da                	neg    %edx
  800b38:	85 ff                	test   %edi,%edi
  800b3a:	0f 45 c2             	cmovne %edx,%eax
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5e                   	pop    %esi
  800b3f:	5f                   	pop    %edi
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    
  800b42:	66 90                	xchg   %ax,%ax
  800b44:	66 90                	xchg   %ax,%ax
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
