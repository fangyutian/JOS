
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 60 00 00 00       	call   8000a2 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800052:	e8 c9 00 00 00       	call   800120 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005f:	c1 e0 05             	shl    $0x5,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x30>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 ce 0d 80 00       	push   $0x800dce
  80010c:	6a 23                	push   $0x23
  80010e:	68 eb 0d 80 00       	push   $0x800deb
  800113:	e8 3c 00 00 00       	call   800154 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
  800126:	83 ec 14             	sub    $0x14,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800129:	ba 00 00 00 00       	mov    $0x0,%edx
  80012e:	b8 02 00 00 00       	mov    $0x2,%eax
  800133:	89 d1                	mov    %edx,%ecx
  800135:	89 d3                	mov    %edx,%ebx
  800137:	89 d7                	mov    %edx,%edi
  800139:	89 d6                	mov    %edx,%esi
  80013b:	cd 30                	int    $0x30
  80013d:	89 c3                	mov    %eax,%ebx

envid_t
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	cprintf("lib/syscall.c: %x\n", ret);
  80013f:	50                   	push   %eax
  800140:	68 f9 0d 80 00       	push   $0x800df9
  800145:	e8 e3 00 00 00       	call   80022d <cprintf>
	return ret;
}
  80014a:	89 d8                	mov    %ebx,%eax
  80014c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5f                   	pop    %edi
  800152:	5d                   	pop    %ebp
  800153:	c3                   	ret    

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800159:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800162:	e8 b9 ff ff ff       	call   800120 <sys_getenvid>
  800167:	83 ec 0c             	sub    $0xc,%esp
  80016a:	ff 75 0c             	pushl  0xc(%ebp)
  80016d:	ff 75 08             	pushl  0x8(%ebp)
  800170:	56                   	push   %esi
  800171:	50                   	push   %eax
  800172:	68 0c 0e 80 00       	push   $0x800e0c
  800177:	e8 b1 00 00 00       	call   80022d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017c:	83 c4 18             	add    $0x18,%esp
  80017f:	53                   	push   %ebx
  800180:	ff 75 10             	pushl  0x10(%ebp)
  800183:	e8 54 00 00 00       	call   8001dc <vcprintf>
	cprintf("\n");
  800188:	c7 04 24 0a 0e 80 00 	movl   $0x800e0a,(%esp)
  80018f:	e8 99 00 00 00       	call   80022d <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800197:	cc                   	int3   
  800198:	eb fd                	jmp    800197 <_panic+0x43>

0080019a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	53                   	push   %ebx
  80019e:	83 ec 04             	sub    $0x4,%esp
  8001a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a4:	8b 13                	mov    (%ebx),%edx
  8001a6:	8d 42 01             	lea    0x1(%edx),%eax
  8001a9:	89 03                	mov    %eax,(%ebx)
  8001ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ae:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b7:	75 1a                	jne    8001d3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b9:	83 ec 08             	sub    $0x8,%esp
  8001bc:	68 ff 00 00 00       	push   $0xff
  8001c1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c4:	50                   	push   %eax
  8001c5:	e8 d8 fe ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8001ca:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    

008001dc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ec:	00 00 00 
	b.cnt = 0;
  8001ef:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f9:	ff 75 0c             	pushl  0xc(%ebp)
  8001fc:	ff 75 08             	pushl  0x8(%ebp)
  8001ff:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800205:	50                   	push   %eax
  800206:	68 9a 01 80 00       	push   $0x80019a
  80020b:	e8 54 01 00 00       	call   800364 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800210:	83 c4 08             	add    $0x8,%esp
  800213:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800219:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021f:	50                   	push   %eax
  800220:	e8 7d fe ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  800225:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022b:	c9                   	leave  
  80022c:	c3                   	ret    

0080022d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800233:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800236:	50                   	push   %eax
  800237:	ff 75 08             	pushl  0x8(%ebp)
  80023a:	e8 9d ff ff ff       	call   8001dc <vcprintf>
	va_end(ap);

	return cnt;
}
  80023f:	c9                   	leave  
  800240:	c3                   	ret    

00800241 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	57                   	push   %edi
  800245:	56                   	push   %esi
  800246:	53                   	push   %ebx
  800247:	83 ec 1c             	sub    $0x1c,%esp
  80024a:	89 c7                	mov    %eax,%edi
  80024c:	89 d6                	mov    %edx,%esi
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	8b 55 0c             	mov    0xc(%ebp),%edx
  800254:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800257:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80025d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800262:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800265:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800268:	39 d3                	cmp    %edx,%ebx
  80026a:	72 05                	jb     800271 <printnum+0x30>
  80026c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80026f:	77 45                	ja     8002b6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800271:	83 ec 0c             	sub    $0xc,%esp
  800274:	ff 75 18             	pushl  0x18(%ebp)
  800277:	8b 45 14             	mov    0x14(%ebp),%eax
  80027a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80027d:	53                   	push   %ebx
  80027e:	ff 75 10             	pushl  0x10(%ebp)
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	ff 75 e4             	pushl  -0x1c(%ebp)
  800287:	ff 75 e0             	pushl  -0x20(%ebp)
  80028a:	ff 75 dc             	pushl  -0x24(%ebp)
  80028d:	ff 75 d8             	pushl  -0x28(%ebp)
  800290:	e8 ab 08 00 00       	call   800b40 <__udivdi3>
  800295:	83 c4 18             	add    $0x18,%esp
  800298:	52                   	push   %edx
  800299:	50                   	push   %eax
  80029a:	89 f2                	mov    %esi,%edx
  80029c:	89 f8                	mov    %edi,%eax
  80029e:	e8 9e ff ff ff       	call   800241 <printnum>
  8002a3:	83 c4 20             	add    $0x20,%esp
  8002a6:	eb 18                	jmp    8002c0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a8:	83 ec 08             	sub    $0x8,%esp
  8002ab:	56                   	push   %esi
  8002ac:	ff 75 18             	pushl  0x18(%ebp)
  8002af:	ff d7                	call   *%edi
  8002b1:	83 c4 10             	add    $0x10,%esp
  8002b4:	eb 03                	jmp    8002b9 <printnum+0x78>
  8002b6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b9:	83 eb 01             	sub    $0x1,%ebx
  8002bc:	85 db                	test   %ebx,%ebx
  8002be:	7f e8                	jg     8002a8 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c0:	83 ec 08             	sub    $0x8,%esp
  8002c3:	56                   	push   %esi
  8002c4:	83 ec 04             	sub    $0x4,%esp
  8002c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8002cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d3:	e8 98 09 00 00       	call   800c70 <__umoddi3>
  8002d8:	83 c4 14             	add    $0x14,%esp
  8002db:	0f be 80 30 0e 80 00 	movsbl 0x800e30(%eax),%eax
  8002e2:	50                   	push   %eax
  8002e3:	ff d7                	call   *%edi
}
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f3:	83 fa 01             	cmp    $0x1,%edx
  8002f6:	7e 0e                	jle    800306 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f8:	8b 10                	mov    (%eax),%edx
  8002fa:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 02                	mov    (%edx),%eax
  800301:	8b 52 04             	mov    0x4(%edx),%edx
  800304:	eb 22                	jmp    800328 <getuint+0x38>
	else if (lflag)
  800306:	85 d2                	test   %edx,%edx
  800308:	74 10                	je     80031a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030f:	89 08                	mov    %ecx,(%eax)
  800311:	8b 02                	mov    (%edx),%eax
  800313:	ba 00 00 00 00       	mov    $0x0,%edx
  800318:	eb 0e                	jmp    800328 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80031a:	8b 10                	mov    (%eax),%edx
  80031c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031f:	89 08                	mov    %ecx,(%eax)
  800321:	8b 02                	mov    (%edx),%eax
  800323:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800328:	5d                   	pop    %ebp
  800329:	c3                   	ret    

0080032a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800330:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800334:	8b 10                	mov    (%eax),%edx
  800336:	3b 50 04             	cmp    0x4(%eax),%edx
  800339:	73 0a                	jae    800345 <sprintputch+0x1b>
		*b->buf++ = ch;
  80033b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80033e:	89 08                	mov    %ecx,(%eax)
  800340:	8b 45 08             	mov    0x8(%ebp),%eax
  800343:	88 02                	mov    %al,(%edx)
}
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80034d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800350:	50                   	push   %eax
  800351:	ff 75 10             	pushl  0x10(%ebp)
  800354:	ff 75 0c             	pushl  0xc(%ebp)
  800357:	ff 75 08             	pushl  0x8(%ebp)
  80035a:	e8 05 00 00 00       	call   800364 <vprintfmt>
	va_end(ap);
}
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	c9                   	leave  
  800363:	c3                   	ret    

00800364 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	57                   	push   %edi
  800368:	56                   	push   %esi
  800369:	53                   	push   %ebx
  80036a:	83 ec 2c             	sub    $0x2c,%esp
  80036d:	8b 75 08             	mov    0x8(%ebp),%esi
  800370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800373:	8b 7d 10             	mov    0x10(%ebp),%edi
  800376:	eb 1d                	jmp    800395 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800378:	85 c0                	test   %eax,%eax
  80037a:	75 0f                	jne    80038b <vprintfmt+0x27>
				csa = 0x0700;
  80037c:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  800383:	07 00 00 
				return;
  800386:	e9 c4 03 00 00       	jmp    80074f <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  80038b:	83 ec 08             	sub    $0x8,%esp
  80038e:	53                   	push   %ebx
  80038f:	50                   	push   %eax
  800390:	ff d6                	call   *%esi
  800392:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800395:	83 c7 01             	add    $0x1,%edi
  800398:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80039c:	83 f8 25             	cmp    $0x25,%eax
  80039f:	75 d7                	jne    800378 <vprintfmt+0x14>
  8003a1:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a5:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003ac:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003b3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bf:	eb 07                	jmp    8003c8 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c4:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8d 47 01             	lea    0x1(%edi),%eax
  8003cb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003ce:	0f b6 07             	movzbl (%edi),%eax
  8003d1:	0f b6 c8             	movzbl %al,%ecx
  8003d4:	83 e8 23             	sub    $0x23,%eax
  8003d7:	3c 55                	cmp    $0x55,%al
  8003d9:	0f 87 55 03 00 00    	ja     800734 <vprintfmt+0x3d0>
  8003df:	0f b6 c0             	movzbl %al,%eax
  8003e2:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ec:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003f0:	eb d6                	jmp    8003c8 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003fd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800400:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800404:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800407:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80040a:	83 fa 09             	cmp    $0x9,%edx
  80040d:	77 39                	ja     800448 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800412:	eb e9                	jmp    8003fd <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 48 04             	lea    0x4(%eax),%ecx
  80041a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80041d:	8b 00                	mov    (%eax),%eax
  80041f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800422:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800425:	eb 27                	jmp    80044e <vprintfmt+0xea>
  800427:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042a:	85 c0                	test   %eax,%eax
  80042c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800431:	0f 49 c8             	cmovns %eax,%ecx
  800434:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80043a:	eb 8c                	jmp    8003c8 <vprintfmt+0x64>
  80043c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800446:	eb 80                	jmp    8003c8 <vprintfmt+0x64>
  800448:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80044b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80044e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800452:	0f 89 70 ff ff ff    	jns    8003c8 <vprintfmt+0x64>
				width = precision, precision = -1;
  800458:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80045b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800465:	e9 5e ff ff ff       	jmp    8003c8 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046a:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800470:	e9 53 ff ff ff       	jmp    8003c8 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 50 04             	lea    0x4(%eax),%edx
  80047b:	89 55 14             	mov    %edx,0x14(%ebp)
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	53                   	push   %ebx
  800482:	ff 30                	pushl  (%eax)
  800484:	ff d6                	call   *%esi
			break;
  800486:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800489:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048c:	e9 04 ff ff ff       	jmp    800395 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 50 04             	lea    0x4(%eax),%edx
  800497:	89 55 14             	mov    %edx,0x14(%ebp)
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	99                   	cltd   
  80049d:	31 d0                	xor    %edx,%eax
  80049f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a1:	83 f8 06             	cmp    $0x6,%eax
  8004a4:	7f 0b                	jg     8004b1 <vprintfmt+0x14d>
  8004a6:	8b 14 85 18 10 80 00 	mov    0x801018(,%eax,4),%edx
  8004ad:	85 d2                	test   %edx,%edx
  8004af:	75 18                	jne    8004c9 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8004b1:	50                   	push   %eax
  8004b2:	68 48 0e 80 00       	push   $0x800e48
  8004b7:	53                   	push   %ebx
  8004b8:	56                   	push   %esi
  8004b9:	e8 89 fe ff ff       	call   800347 <printfmt>
  8004be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004c4:	e9 cc fe ff ff       	jmp    800395 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8004c9:	52                   	push   %edx
  8004ca:	68 51 0e 80 00       	push   $0x800e51
  8004cf:	53                   	push   %ebx
  8004d0:	56                   	push   %esi
  8004d1:	e8 71 fe ff ff       	call   800347 <printfmt>
  8004d6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004dc:	e9 b4 fe ff ff       	jmp    800395 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 50 04             	lea    0x4(%eax),%edx
  8004e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ea:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ec:	85 ff                	test   %edi,%edi
  8004ee:	b8 41 0e 80 00       	mov    $0x800e41,%eax
  8004f3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fa:	0f 8e 94 00 00 00    	jle    800594 <vprintfmt+0x230>
  800500:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800504:	0f 84 98 00 00 00    	je     8005a2 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	ff 75 d0             	pushl  -0x30(%ebp)
  800510:	57                   	push   %edi
  800511:	e8 c1 02 00 00       	call   8007d7 <strnlen>
  800516:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800519:	29 c1                	sub    %eax,%ecx
  80051b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80051e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800521:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800525:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800528:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80052b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052d:	eb 0f                	jmp    80053e <vprintfmt+0x1da>
					putch(padc, putdat);
  80052f:	83 ec 08             	sub    $0x8,%esp
  800532:	53                   	push   %ebx
  800533:	ff 75 e0             	pushl  -0x20(%ebp)
  800536:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800538:	83 ef 01             	sub    $0x1,%edi
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	85 ff                	test   %edi,%edi
  800540:	7f ed                	jg     80052f <vprintfmt+0x1cb>
  800542:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800545:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800548:	85 c9                	test   %ecx,%ecx
  80054a:	b8 00 00 00 00       	mov    $0x0,%eax
  80054f:	0f 49 c1             	cmovns %ecx,%eax
  800552:	29 c1                	sub    %eax,%ecx
  800554:	89 75 08             	mov    %esi,0x8(%ebp)
  800557:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055d:	89 cb                	mov    %ecx,%ebx
  80055f:	eb 4d                	jmp    8005ae <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800561:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800565:	74 1b                	je     800582 <vprintfmt+0x21e>
  800567:	0f be c0             	movsbl %al,%eax
  80056a:	83 e8 20             	sub    $0x20,%eax
  80056d:	83 f8 5e             	cmp    $0x5e,%eax
  800570:	76 10                	jbe    800582 <vprintfmt+0x21e>
					putch('?', putdat);
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	ff 75 0c             	pushl  0xc(%ebp)
  800578:	6a 3f                	push   $0x3f
  80057a:	ff 55 08             	call   *0x8(%ebp)
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	eb 0d                	jmp    80058f <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	ff 75 0c             	pushl  0xc(%ebp)
  800588:	52                   	push   %edx
  800589:	ff 55 08             	call   *0x8(%ebp)
  80058c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058f:	83 eb 01             	sub    $0x1,%ebx
  800592:	eb 1a                	jmp    8005ae <vprintfmt+0x24a>
  800594:	89 75 08             	mov    %esi,0x8(%ebp)
  800597:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a0:	eb 0c                	jmp    8005ae <vprintfmt+0x24a>
  8005a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ae:	83 c7 01             	add    $0x1,%edi
  8005b1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b5:	0f be d0             	movsbl %al,%edx
  8005b8:	85 d2                	test   %edx,%edx
  8005ba:	74 23                	je     8005df <vprintfmt+0x27b>
  8005bc:	85 f6                	test   %esi,%esi
  8005be:	78 a1                	js     800561 <vprintfmt+0x1fd>
  8005c0:	83 ee 01             	sub    $0x1,%esi
  8005c3:	79 9c                	jns    800561 <vprintfmt+0x1fd>
  8005c5:	89 df                	mov    %ebx,%edi
  8005c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8005ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005cd:	eb 18                	jmp    8005e7 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	53                   	push   %ebx
  8005d3:	6a 20                	push   $0x20
  8005d5:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d7:	83 ef 01             	sub    $0x1,%edi
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	eb 08                	jmp    8005e7 <vprintfmt+0x283>
  8005df:	89 df                	mov    %ebx,%edi
  8005e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e7:	85 ff                	test   %edi,%edi
  8005e9:	7f e4                	jg     8005cf <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ee:	e9 a2 fd ff ff       	jmp    800395 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f3:	83 fa 01             	cmp    $0x1,%edx
  8005f6:	7e 16                	jle    80060e <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 50 08             	lea    0x8(%eax),%edx
  8005fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800601:	8b 50 04             	mov    0x4(%eax),%edx
  800604:	8b 00                	mov    (%eax),%eax
  800606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800609:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80060c:	eb 32                	jmp    800640 <vprintfmt+0x2dc>
	else if (lflag)
  80060e:	85 d2                	test   %edx,%edx
  800610:	74 18                	je     80062a <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800620:	89 c1                	mov    %eax,%ecx
  800622:	c1 f9 1f             	sar    $0x1f,%ecx
  800625:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800628:	eb 16                	jmp    800640 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 50 04             	lea    0x4(%eax),%edx
  800630:	89 55 14             	mov    %edx,0x14(%ebp)
  800633:	8b 00                	mov    (%eax),%eax
  800635:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800638:	89 c1                	mov    %eax,%ecx
  80063a:	c1 f9 1f             	sar    $0x1f,%ecx
  80063d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800640:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800643:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800646:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064f:	79 74                	jns    8006c5 <vprintfmt+0x361>
				putch('-', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 2d                	push   $0x2d
  800657:	ff d6                	call   *%esi
				num = -(long long) num;
  800659:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80065f:	f7 d8                	neg    %eax
  800661:	83 d2 00             	adc    $0x0,%edx
  800664:	f7 da                	neg    %edx
  800666:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800669:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80066e:	eb 55                	jmp    8006c5 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800670:	8d 45 14             	lea    0x14(%ebp),%eax
  800673:	e8 78 fc ff ff       	call   8002f0 <getuint>
			base = 10;
  800678:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80067d:	eb 46                	jmp    8006c5 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
  800682:	e8 69 fc ff ff       	call   8002f0 <getuint>
      base = 8;
  800687:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80068c:	eb 37                	jmp    8006c5 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	6a 30                	push   $0x30
  800694:	ff d6                	call   *%esi
			putch('x', putdat);
  800696:	83 c4 08             	add    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	6a 78                	push   $0x78
  80069c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8d 50 04             	lea    0x4(%eax),%edx
  8006a4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a7:	8b 00                	mov    (%eax),%eax
  8006a9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ae:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006b1:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b6:	eb 0d                	jmp    8006c5 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006bb:	e8 30 fc ff ff       	call   8002f0 <getuint>
			base = 16;
  8006c0:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c5:	83 ec 0c             	sub    $0xc,%esp
  8006c8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006cc:	57                   	push   %edi
  8006cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d0:	51                   	push   %ecx
  8006d1:	52                   	push   %edx
  8006d2:	50                   	push   %eax
  8006d3:	89 da                	mov    %ebx,%edx
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	e8 65 fb ff ff       	call   800241 <printnum>
			break;
  8006dc:	83 c4 20             	add    $0x20,%esp
  8006df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006e2:	e9 ae fc ff ff       	jmp    800395 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	51                   	push   %ecx
  8006ec:	ff d6                	call   *%esi
			break;
  8006ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f4:	e9 9c fc ff ff       	jmp    800395 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f9:	83 fa 01             	cmp    $0x1,%edx
  8006fc:	7e 0d                	jle    80070b <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8006fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800701:	8d 50 08             	lea    0x8(%eax),%edx
  800704:	89 55 14             	mov    %edx,0x14(%ebp)
  800707:	8b 00                	mov    (%eax),%eax
  800709:	eb 1c                	jmp    800727 <vprintfmt+0x3c3>
	else if (lflag)
  80070b:	85 d2                	test   %edx,%edx
  80070d:	74 0d                	je     80071c <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	eb 0b                	jmp    800727 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8d 50 04             	lea    0x4(%eax),%edx
  800722:	89 55 14             	mov    %edx,0x14(%ebp)
  800725:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800727:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  80072f:	e9 61 fc ff ff       	jmp    800395 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	53                   	push   %ebx
  800738:	6a 25                	push   $0x25
  80073a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	eb 03                	jmp    800744 <vprintfmt+0x3e0>
  800741:	83 ef 01             	sub    $0x1,%edi
  800744:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800748:	75 f7                	jne    800741 <vprintfmt+0x3dd>
  80074a:	e9 46 fc ff ff       	jmp    800395 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80074f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800752:	5b                   	pop    %ebx
  800753:	5e                   	pop    %esi
  800754:	5f                   	pop    %edi
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	83 ec 18             	sub    $0x18,%esp
  80075d:	8b 45 08             	mov    0x8(%ebp),%eax
  800760:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800763:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800766:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80076a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800774:	85 c0                	test   %eax,%eax
  800776:	74 26                	je     80079e <vsnprintf+0x47>
  800778:	85 d2                	test   %edx,%edx
  80077a:	7e 22                	jle    80079e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077c:	ff 75 14             	pushl  0x14(%ebp)
  80077f:	ff 75 10             	pushl  0x10(%ebp)
  800782:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800785:	50                   	push   %eax
  800786:	68 2a 03 80 00       	push   $0x80032a
  80078b:	e8 d4 fb ff ff       	call   800364 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800790:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800793:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800799:	83 c4 10             	add    $0x10,%esp
  80079c:	eb 05                	jmp    8007a3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    

008007a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ae:	50                   	push   %eax
  8007af:	ff 75 10             	pushl  0x10(%ebp)
  8007b2:	ff 75 0c             	pushl  0xc(%ebp)
  8007b5:	ff 75 08             	pushl  0x8(%ebp)
  8007b8:	e8 9a ff ff ff       	call   800757 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ca:	eb 03                	jmp    8007cf <strlen+0x10>
		n++;
  8007cc:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d3:	75 f7                	jne    8007cc <strlen+0xd>
		n++;
	return n;
}
  8007d5:	5d                   	pop    %ebp
  8007d6:	c3                   	ret    

008007d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e5:	eb 03                	jmp    8007ea <strnlen+0x13>
		n++;
  8007e7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ea:	39 c2                	cmp    %eax,%edx
  8007ec:	74 08                	je     8007f6 <strnlen+0x1f>
  8007ee:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007f2:	75 f3                	jne    8007e7 <strnlen+0x10>
  8007f4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800802:	89 c2                	mov    %eax,%edx
  800804:	83 c2 01             	add    $0x1,%edx
  800807:	83 c1 01             	add    $0x1,%ecx
  80080a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800811:	84 db                	test   %bl,%bl
  800813:	75 ef                	jne    800804 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800815:	5b                   	pop    %ebx
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	53                   	push   %ebx
  80081c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081f:	53                   	push   %ebx
  800820:	e8 9a ff ff ff       	call   8007bf <strlen>
  800825:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800828:	ff 75 0c             	pushl  0xc(%ebp)
  80082b:	01 d8                	add    %ebx,%eax
  80082d:	50                   	push   %eax
  80082e:	e8 c5 ff ff ff       	call   8007f8 <strcpy>
	return dst;
}
  800833:	89 d8                	mov    %ebx,%eax
  800835:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800838:	c9                   	leave  
  800839:	c3                   	ret    

0080083a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	56                   	push   %esi
  80083e:	53                   	push   %ebx
  80083f:	8b 75 08             	mov    0x8(%ebp),%esi
  800842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800845:	89 f3                	mov    %esi,%ebx
  800847:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084a:	89 f2                	mov    %esi,%edx
  80084c:	eb 0f                	jmp    80085d <strncpy+0x23>
		*dst++ = *src;
  80084e:	83 c2 01             	add    $0x1,%edx
  800851:	0f b6 01             	movzbl (%ecx),%eax
  800854:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800857:	80 39 01             	cmpb   $0x1,(%ecx)
  80085a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085d:	39 da                	cmp    %ebx,%edx
  80085f:	75 ed                	jne    80084e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800861:	89 f0                	mov    %esi,%eax
  800863:	5b                   	pop    %ebx
  800864:	5e                   	pop    %esi
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	56                   	push   %esi
  80086b:	53                   	push   %ebx
  80086c:	8b 75 08             	mov    0x8(%ebp),%esi
  80086f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800872:	8b 55 10             	mov    0x10(%ebp),%edx
  800875:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800877:	85 d2                	test   %edx,%edx
  800879:	74 21                	je     80089c <strlcpy+0x35>
  80087b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80087f:	89 f2                	mov    %esi,%edx
  800881:	eb 09                	jmp    80088c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800883:	83 c2 01             	add    $0x1,%edx
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80088c:	39 c2                	cmp    %eax,%edx
  80088e:	74 09                	je     800899 <strlcpy+0x32>
  800890:	0f b6 19             	movzbl (%ecx),%ebx
  800893:	84 db                	test   %bl,%bl
  800895:	75 ec                	jne    800883 <strlcpy+0x1c>
  800897:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800899:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80089c:	29 f0                	sub    %esi,%eax
}
  80089e:	5b                   	pop    %ebx
  80089f:	5e                   	pop    %esi
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ab:	eb 06                	jmp    8008b3 <strcmp+0x11>
		p++, q++;
  8008ad:	83 c1 01             	add    $0x1,%ecx
  8008b0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b3:	0f b6 01             	movzbl (%ecx),%eax
  8008b6:	84 c0                	test   %al,%al
  8008b8:	74 04                	je     8008be <strcmp+0x1c>
  8008ba:	3a 02                	cmp    (%edx),%al
  8008bc:	74 ef                	je     8008ad <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008be:	0f b6 c0             	movzbl %al,%eax
  8008c1:	0f b6 12             	movzbl (%edx),%edx
  8008c4:	29 d0                	sub    %edx,%eax
}
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	53                   	push   %ebx
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d2:	89 c3                	mov    %eax,%ebx
  8008d4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d7:	eb 06                	jmp    8008df <strncmp+0x17>
		n--, p++, q++;
  8008d9:	83 c0 01             	add    $0x1,%eax
  8008dc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008df:	39 d8                	cmp    %ebx,%eax
  8008e1:	74 15                	je     8008f8 <strncmp+0x30>
  8008e3:	0f b6 08             	movzbl (%eax),%ecx
  8008e6:	84 c9                	test   %cl,%cl
  8008e8:	74 04                	je     8008ee <strncmp+0x26>
  8008ea:	3a 0a                	cmp    (%edx),%cl
  8008ec:	74 eb                	je     8008d9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ee:	0f b6 00             	movzbl (%eax),%eax
  8008f1:	0f b6 12             	movzbl (%edx),%edx
  8008f4:	29 d0                	sub    %edx,%eax
  8008f6:	eb 05                	jmp    8008fd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008fd:	5b                   	pop    %ebx
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090a:	eb 07                	jmp    800913 <strchr+0x13>
		if (*s == c)
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	74 0f                	je     80091f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	0f b6 10             	movzbl (%eax),%edx
  800916:	84 d2                	test   %dl,%dl
  800918:	75 f2                	jne    80090c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80091a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092b:	eb 03                	jmp    800930 <strfind+0xf>
  80092d:	83 c0 01             	add    $0x1,%eax
  800930:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800933:	38 ca                	cmp    %cl,%dl
  800935:	74 04                	je     80093b <strfind+0x1a>
  800937:	84 d2                	test   %dl,%dl
  800939:	75 f2                	jne    80092d <strfind+0xc>
			break;
	return (char *) s;
}
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	57                   	push   %edi
  800941:	56                   	push   %esi
  800942:	53                   	push   %ebx
  800943:	8b 7d 08             	mov    0x8(%ebp),%edi
  800946:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800949:	85 c9                	test   %ecx,%ecx
  80094b:	74 36                	je     800983 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800953:	75 28                	jne    80097d <memset+0x40>
  800955:	f6 c1 03             	test   $0x3,%cl
  800958:	75 23                	jne    80097d <memset+0x40>
		c &= 0xFF;
  80095a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095e:	89 d3                	mov    %edx,%ebx
  800960:	c1 e3 08             	shl    $0x8,%ebx
  800963:	89 d6                	mov    %edx,%esi
  800965:	c1 e6 18             	shl    $0x18,%esi
  800968:	89 d0                	mov    %edx,%eax
  80096a:	c1 e0 10             	shl    $0x10,%eax
  80096d:	09 f0                	or     %esi,%eax
  80096f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800971:	89 d8                	mov    %ebx,%eax
  800973:	09 d0                	or     %edx,%eax
  800975:	c1 e9 02             	shr    $0x2,%ecx
  800978:	fc                   	cld    
  800979:	f3 ab                	rep stos %eax,%es:(%edi)
  80097b:	eb 06                	jmp    800983 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	fc                   	cld    
  800981:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800983:	89 f8                	mov    %edi,%eax
  800985:	5b                   	pop    %ebx
  800986:	5e                   	pop    %esi
  800987:	5f                   	pop    %edi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	57                   	push   %edi
  80098e:	56                   	push   %esi
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 75 0c             	mov    0xc(%ebp),%esi
  800995:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800998:	39 c6                	cmp    %eax,%esi
  80099a:	73 35                	jae    8009d1 <memmove+0x47>
  80099c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099f:	39 d0                	cmp    %edx,%eax
  8009a1:	73 2e                	jae    8009d1 <memmove+0x47>
		s += n;
		d += n;
  8009a3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a6:	89 d6                	mov    %edx,%esi
  8009a8:	09 fe                	or     %edi,%esi
  8009aa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b0:	75 13                	jne    8009c5 <memmove+0x3b>
  8009b2:	f6 c1 03             	test   $0x3,%cl
  8009b5:	75 0e                	jne    8009c5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b7:	83 ef 04             	sub    $0x4,%edi
  8009ba:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009bd:	c1 e9 02             	shr    $0x2,%ecx
  8009c0:	fd                   	std    
  8009c1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c3:	eb 09                	jmp    8009ce <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c5:	83 ef 01             	sub    $0x1,%edi
  8009c8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009cb:	fd                   	std    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ce:	fc                   	cld    
  8009cf:	eb 1d                	jmp    8009ee <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d1:	89 f2                	mov    %esi,%edx
  8009d3:	09 c2                	or     %eax,%edx
  8009d5:	f6 c2 03             	test   $0x3,%dl
  8009d8:	75 0f                	jne    8009e9 <memmove+0x5f>
  8009da:	f6 c1 03             	test   $0x3,%cl
  8009dd:	75 0a                	jne    8009e9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009df:	c1 e9 02             	shr    $0x2,%ecx
  8009e2:	89 c7                	mov    %eax,%edi
  8009e4:	fc                   	cld    
  8009e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e7:	eb 05                	jmp    8009ee <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e9:	89 c7                	mov    %eax,%edi
  8009eb:	fc                   	cld    
  8009ec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ee:	5e                   	pop    %esi
  8009ef:	5f                   	pop    %edi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f5:	ff 75 10             	pushl  0x10(%ebp)
  8009f8:	ff 75 0c             	pushl  0xc(%ebp)
  8009fb:	ff 75 08             	pushl  0x8(%ebp)
  8009fe:	e8 87 ff ff ff       	call   80098a <memmove>
}
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    

00800a05 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a10:	89 c6                	mov    %eax,%esi
  800a12:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a15:	eb 1a                	jmp    800a31 <memcmp+0x2c>
		if (*s1 != *s2)
  800a17:	0f b6 08             	movzbl (%eax),%ecx
  800a1a:	0f b6 1a             	movzbl (%edx),%ebx
  800a1d:	38 d9                	cmp    %bl,%cl
  800a1f:	74 0a                	je     800a2b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a21:	0f b6 c1             	movzbl %cl,%eax
  800a24:	0f b6 db             	movzbl %bl,%ebx
  800a27:	29 d8                	sub    %ebx,%eax
  800a29:	eb 0f                	jmp    800a3a <memcmp+0x35>
		s1++, s2++;
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a31:	39 f0                	cmp    %esi,%eax
  800a33:	75 e2                	jne    800a17 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3a:	5b                   	pop    %ebx
  800a3b:	5e                   	pop    %esi
  800a3c:	5d                   	pop    %ebp
  800a3d:	c3                   	ret    

00800a3e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	53                   	push   %ebx
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a45:	89 c1                	mov    %eax,%ecx
  800a47:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4e:	eb 0a                	jmp    800a5a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a50:	0f b6 10             	movzbl (%eax),%edx
  800a53:	39 da                	cmp    %ebx,%edx
  800a55:	74 07                	je     800a5e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a57:	83 c0 01             	add    $0x1,%eax
  800a5a:	39 c8                	cmp    %ecx,%eax
  800a5c:	72 f2                	jb     800a50 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5e:	5b                   	pop    %ebx
  800a5f:	5d                   	pop    %ebp
  800a60:	c3                   	ret    

00800a61 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a61:	55                   	push   %ebp
  800a62:	89 e5                	mov    %esp,%ebp
  800a64:	57                   	push   %edi
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
  800a67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6d:	eb 03                	jmp    800a72 <strtol+0x11>
		s++;
  800a6f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a72:	0f b6 01             	movzbl (%ecx),%eax
  800a75:	3c 20                	cmp    $0x20,%al
  800a77:	74 f6                	je     800a6f <strtol+0xe>
  800a79:	3c 09                	cmp    $0x9,%al
  800a7b:	74 f2                	je     800a6f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7d:	3c 2b                	cmp    $0x2b,%al
  800a7f:	75 0a                	jne    800a8b <strtol+0x2a>
		s++;
  800a81:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a84:	bf 00 00 00 00       	mov    $0x0,%edi
  800a89:	eb 11                	jmp    800a9c <strtol+0x3b>
  800a8b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a90:	3c 2d                	cmp    $0x2d,%al
  800a92:	75 08                	jne    800a9c <strtol+0x3b>
		s++, neg = 1;
  800a94:	83 c1 01             	add    $0x1,%ecx
  800a97:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aa2:	75 15                	jne    800ab9 <strtol+0x58>
  800aa4:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa7:	75 10                	jne    800ab9 <strtol+0x58>
  800aa9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aad:	75 7c                	jne    800b2b <strtol+0xca>
		s += 2, base = 16;
  800aaf:	83 c1 02             	add    $0x2,%ecx
  800ab2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab7:	eb 16                	jmp    800acf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab9:	85 db                	test   %ebx,%ebx
  800abb:	75 12                	jne    800acf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800abd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac5:	75 08                	jne    800acf <strtol+0x6e>
		s++, base = 8;
  800ac7:	83 c1 01             	add    $0x1,%ecx
  800aca:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800acf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad7:	0f b6 11             	movzbl (%ecx),%edx
  800ada:	8d 72 d0             	lea    -0x30(%edx),%esi
  800add:	89 f3                	mov    %esi,%ebx
  800adf:	80 fb 09             	cmp    $0x9,%bl
  800ae2:	77 08                	ja     800aec <strtol+0x8b>
			dig = *s - '0';
  800ae4:	0f be d2             	movsbl %dl,%edx
  800ae7:	83 ea 30             	sub    $0x30,%edx
  800aea:	eb 22                	jmp    800b0e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aec:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aef:	89 f3                	mov    %esi,%ebx
  800af1:	80 fb 19             	cmp    $0x19,%bl
  800af4:	77 08                	ja     800afe <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af6:	0f be d2             	movsbl %dl,%edx
  800af9:	83 ea 57             	sub    $0x57,%edx
  800afc:	eb 10                	jmp    800b0e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800afe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b01:	89 f3                	mov    %esi,%ebx
  800b03:	80 fb 19             	cmp    $0x19,%bl
  800b06:	77 16                	ja     800b1e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b08:	0f be d2             	movsbl %dl,%edx
  800b0b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b0e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b11:	7d 0b                	jge    800b1e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b13:	83 c1 01             	add    $0x1,%ecx
  800b16:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b1c:	eb b9                	jmp    800ad7 <strtol+0x76>

	if (endptr)
  800b1e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b22:	74 0d                	je     800b31 <strtol+0xd0>
		*endptr = (char *) s;
  800b24:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b27:	89 0e                	mov    %ecx,(%esi)
  800b29:	eb 06                	jmp    800b31 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b2b:	85 db                	test   %ebx,%ebx
  800b2d:	74 98                	je     800ac7 <strtol+0x66>
  800b2f:	eb 9e                	jmp    800acf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b31:	89 c2                	mov    %eax,%edx
  800b33:	f7 da                	neg    %edx
  800b35:	85 ff                	test   %edi,%edi
  800b37:	0f 45 c2             	cmovne %edx,%eax
}
  800b3a:	5b                   	pop    %ebx
  800b3b:	5e                   	pop    %esi
  800b3c:	5f                   	pop    %edi
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    
  800b3f:	90                   	nop

00800b40 <__udivdi3>:
  800b40:	55                   	push   %ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
  800b44:	83 ec 1c             	sub    $0x1c,%esp
  800b47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800b4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800b4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800b53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800b57:	85 f6                	test   %esi,%esi
  800b59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b5d:	89 ca                	mov    %ecx,%edx
  800b5f:	89 f8                	mov    %edi,%eax
  800b61:	75 3d                	jne    800ba0 <__udivdi3+0x60>
  800b63:	39 cf                	cmp    %ecx,%edi
  800b65:	0f 87 c5 00 00 00    	ja     800c30 <__udivdi3+0xf0>
  800b6b:	85 ff                	test   %edi,%edi
  800b6d:	89 fd                	mov    %edi,%ebp
  800b6f:	75 0b                	jne    800b7c <__udivdi3+0x3c>
  800b71:	b8 01 00 00 00       	mov    $0x1,%eax
  800b76:	31 d2                	xor    %edx,%edx
  800b78:	f7 f7                	div    %edi
  800b7a:	89 c5                	mov    %eax,%ebp
  800b7c:	89 c8                	mov    %ecx,%eax
  800b7e:	31 d2                	xor    %edx,%edx
  800b80:	f7 f5                	div    %ebp
  800b82:	89 c1                	mov    %eax,%ecx
  800b84:	89 d8                	mov    %ebx,%eax
  800b86:	89 cf                	mov    %ecx,%edi
  800b88:	f7 f5                	div    %ebp
  800b8a:	89 c3                	mov    %eax,%ebx
  800b8c:	89 d8                	mov    %ebx,%eax
  800b8e:	89 fa                	mov    %edi,%edx
  800b90:	83 c4 1c             	add    $0x1c,%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    
  800b98:	90                   	nop
  800b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ba0:	39 ce                	cmp    %ecx,%esi
  800ba2:	77 74                	ja     800c18 <__udivdi3+0xd8>
  800ba4:	0f bd fe             	bsr    %esi,%edi
  800ba7:	83 f7 1f             	xor    $0x1f,%edi
  800baa:	0f 84 98 00 00 00    	je     800c48 <__udivdi3+0x108>
  800bb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800bb5:	89 f9                	mov    %edi,%ecx
  800bb7:	89 c5                	mov    %eax,%ebp
  800bb9:	29 fb                	sub    %edi,%ebx
  800bbb:	d3 e6                	shl    %cl,%esi
  800bbd:	89 d9                	mov    %ebx,%ecx
  800bbf:	d3 ed                	shr    %cl,%ebp
  800bc1:	89 f9                	mov    %edi,%ecx
  800bc3:	d3 e0                	shl    %cl,%eax
  800bc5:	09 ee                	or     %ebp,%esi
  800bc7:	89 d9                	mov    %ebx,%ecx
  800bc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bcd:	89 d5                	mov    %edx,%ebp
  800bcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  800bd3:	d3 ed                	shr    %cl,%ebp
  800bd5:	89 f9                	mov    %edi,%ecx
  800bd7:	d3 e2                	shl    %cl,%edx
  800bd9:	89 d9                	mov    %ebx,%ecx
  800bdb:	d3 e8                	shr    %cl,%eax
  800bdd:	09 c2                	or     %eax,%edx
  800bdf:	89 d0                	mov    %edx,%eax
  800be1:	89 ea                	mov    %ebp,%edx
  800be3:	f7 f6                	div    %esi
  800be5:	89 d5                	mov    %edx,%ebp
  800be7:	89 c3                	mov    %eax,%ebx
  800be9:	f7 64 24 0c          	mull   0xc(%esp)
  800bed:	39 d5                	cmp    %edx,%ebp
  800bef:	72 10                	jb     800c01 <__udivdi3+0xc1>
  800bf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800bf5:	89 f9                	mov    %edi,%ecx
  800bf7:	d3 e6                	shl    %cl,%esi
  800bf9:	39 c6                	cmp    %eax,%esi
  800bfb:	73 07                	jae    800c04 <__udivdi3+0xc4>
  800bfd:	39 d5                	cmp    %edx,%ebp
  800bff:	75 03                	jne    800c04 <__udivdi3+0xc4>
  800c01:	83 eb 01             	sub    $0x1,%ebx
  800c04:	31 ff                	xor    %edi,%edi
  800c06:	89 d8                	mov    %ebx,%eax
  800c08:	89 fa                	mov    %edi,%edx
  800c0a:	83 c4 1c             	add    $0x1c,%esp
  800c0d:	5b                   	pop    %ebx
  800c0e:	5e                   	pop    %esi
  800c0f:	5f                   	pop    %edi
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    
  800c12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c18:	31 ff                	xor    %edi,%edi
  800c1a:	31 db                	xor    %ebx,%ebx
  800c1c:	89 d8                	mov    %ebx,%eax
  800c1e:	89 fa                	mov    %edi,%edx
  800c20:	83 c4 1c             	add    $0x1c,%esp
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    
  800c28:	90                   	nop
  800c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c30:	89 d8                	mov    %ebx,%eax
  800c32:	f7 f7                	div    %edi
  800c34:	31 ff                	xor    %edi,%edi
  800c36:	89 c3                	mov    %eax,%ebx
  800c38:	89 d8                	mov    %ebx,%eax
  800c3a:	89 fa                	mov    %edi,%edx
  800c3c:	83 c4 1c             	add    $0x1c,%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    
  800c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c48:	39 ce                	cmp    %ecx,%esi
  800c4a:	72 0c                	jb     800c58 <__udivdi3+0x118>
  800c4c:	31 db                	xor    %ebx,%ebx
  800c4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800c52:	0f 87 34 ff ff ff    	ja     800b8c <__udivdi3+0x4c>
  800c58:	bb 01 00 00 00       	mov    $0x1,%ebx
  800c5d:	e9 2a ff ff ff       	jmp    800b8c <__udivdi3+0x4c>
  800c62:	66 90                	xchg   %ax,%ax
  800c64:	66 90                	xchg   %ax,%ax
  800c66:	66 90                	xchg   %ax,%ax
  800c68:	66 90                	xchg   %ax,%ax
  800c6a:	66 90                	xchg   %ax,%ax
  800c6c:	66 90                	xchg   %ax,%ax
  800c6e:	66 90                	xchg   %ax,%ax

00800c70 <__umoddi3>:
  800c70:	55                   	push   %ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 1c             	sub    $0x1c,%esp
  800c77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800c7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800c7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800c87:	85 d2                	test   %edx,%edx
  800c89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800c91:	89 f3                	mov    %esi,%ebx
  800c93:	89 3c 24             	mov    %edi,(%esp)
  800c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c9a:	75 1c                	jne    800cb8 <__umoddi3+0x48>
  800c9c:	39 f7                	cmp    %esi,%edi
  800c9e:	76 50                	jbe    800cf0 <__umoddi3+0x80>
  800ca0:	89 c8                	mov    %ecx,%eax
  800ca2:	89 f2                	mov    %esi,%edx
  800ca4:	f7 f7                	div    %edi
  800ca6:	89 d0                	mov    %edx,%eax
  800ca8:	31 d2                	xor    %edx,%edx
  800caa:	83 c4 1c             	add    $0x1c,%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    
  800cb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800cb8:	39 f2                	cmp    %esi,%edx
  800cba:	89 d0                	mov    %edx,%eax
  800cbc:	77 52                	ja     800d10 <__umoddi3+0xa0>
  800cbe:	0f bd ea             	bsr    %edx,%ebp
  800cc1:	83 f5 1f             	xor    $0x1f,%ebp
  800cc4:	75 5a                	jne    800d20 <__umoddi3+0xb0>
  800cc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800cca:	0f 82 e0 00 00 00    	jb     800db0 <__umoddi3+0x140>
  800cd0:	39 0c 24             	cmp    %ecx,(%esp)
  800cd3:	0f 86 d7 00 00 00    	jbe    800db0 <__umoddi3+0x140>
  800cd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800cdd:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ce1:	83 c4 1c             	add    $0x1c,%esp
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    
  800ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cf0:	85 ff                	test   %edi,%edi
  800cf2:	89 fd                	mov    %edi,%ebp
  800cf4:	75 0b                	jne    800d01 <__umoddi3+0x91>
  800cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfb:	31 d2                	xor    %edx,%edx
  800cfd:	f7 f7                	div    %edi
  800cff:	89 c5                	mov    %eax,%ebp
  800d01:	89 f0                	mov    %esi,%eax
  800d03:	31 d2                	xor    %edx,%edx
  800d05:	f7 f5                	div    %ebp
  800d07:	89 c8                	mov    %ecx,%eax
  800d09:	f7 f5                	div    %ebp
  800d0b:	89 d0                	mov    %edx,%eax
  800d0d:	eb 99                	jmp    800ca8 <__umoddi3+0x38>
  800d0f:	90                   	nop
  800d10:	89 c8                	mov    %ecx,%eax
  800d12:	89 f2                	mov    %esi,%edx
  800d14:	83 c4 1c             	add    $0x1c,%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    
  800d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d20:	8b 34 24             	mov    (%esp),%esi
  800d23:	bf 20 00 00 00       	mov    $0x20,%edi
  800d28:	89 e9                	mov    %ebp,%ecx
  800d2a:	29 ef                	sub    %ebp,%edi
  800d2c:	d3 e0                	shl    %cl,%eax
  800d2e:	89 f9                	mov    %edi,%ecx
  800d30:	89 f2                	mov    %esi,%edx
  800d32:	d3 ea                	shr    %cl,%edx
  800d34:	89 e9                	mov    %ebp,%ecx
  800d36:	09 c2                	or     %eax,%edx
  800d38:	89 d8                	mov    %ebx,%eax
  800d3a:	89 14 24             	mov    %edx,(%esp)
  800d3d:	89 f2                	mov    %esi,%edx
  800d3f:	d3 e2                	shl    %cl,%edx
  800d41:	89 f9                	mov    %edi,%ecx
  800d43:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800d4b:	d3 e8                	shr    %cl,%eax
  800d4d:	89 e9                	mov    %ebp,%ecx
  800d4f:	89 c6                	mov    %eax,%esi
  800d51:	d3 e3                	shl    %cl,%ebx
  800d53:	89 f9                	mov    %edi,%ecx
  800d55:	89 d0                	mov    %edx,%eax
  800d57:	d3 e8                	shr    %cl,%eax
  800d59:	89 e9                	mov    %ebp,%ecx
  800d5b:	09 d8                	or     %ebx,%eax
  800d5d:	89 d3                	mov    %edx,%ebx
  800d5f:	89 f2                	mov    %esi,%edx
  800d61:	f7 34 24             	divl   (%esp)
  800d64:	89 d6                	mov    %edx,%esi
  800d66:	d3 e3                	shl    %cl,%ebx
  800d68:	f7 64 24 04          	mull   0x4(%esp)
  800d6c:	39 d6                	cmp    %edx,%esi
  800d6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d72:	89 d1                	mov    %edx,%ecx
  800d74:	89 c3                	mov    %eax,%ebx
  800d76:	72 08                	jb     800d80 <__umoddi3+0x110>
  800d78:	75 11                	jne    800d8b <__umoddi3+0x11b>
  800d7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800d7e:	73 0b                	jae    800d8b <__umoddi3+0x11b>
  800d80:	2b 44 24 04          	sub    0x4(%esp),%eax
  800d84:	1b 14 24             	sbb    (%esp),%edx
  800d87:	89 d1                	mov    %edx,%ecx
  800d89:	89 c3                	mov    %eax,%ebx
  800d8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800d8f:	29 da                	sub    %ebx,%edx
  800d91:	19 ce                	sbb    %ecx,%esi
  800d93:	89 f9                	mov    %edi,%ecx
  800d95:	89 f0                	mov    %esi,%eax
  800d97:	d3 e0                	shl    %cl,%eax
  800d99:	89 e9                	mov    %ebp,%ecx
  800d9b:	d3 ea                	shr    %cl,%edx
  800d9d:	89 e9                	mov    %ebp,%ecx
  800d9f:	d3 ee                	shr    %cl,%esi
  800da1:	09 d0                	or     %edx,%eax
  800da3:	89 f2                	mov    %esi,%edx
  800da5:	83 c4 1c             	add    $0x1c,%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    
  800dad:	8d 76 00             	lea    0x0(%esi),%esi
  800db0:	29 f9                	sub    %edi,%ecx
  800db2:	19 d6                	sbb    %edx,%esi
  800db4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dbc:	e9 18 ff ff ff       	jmp    800cd9 <__umoddi3+0x69>
