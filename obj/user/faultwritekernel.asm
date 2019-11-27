
obj/user/faultwritekernel:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  80004d:	e8 c9 00 00 00       	call   80011b <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005a:	c1 e0 05             	shl    $0x5,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 db                	test   %ebx,%ebx
  800069:	7e 07                	jle    800072 <libmain+0x30>
		binaryname = argv[0];
  80006b:	8b 06                	mov    (%esi),%eax
  80006d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	56                   	push   %esi
  800076:	53                   	push   %ebx
  800077:	e8 b7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0a 00 00 00       	call   80008b <exit>
}
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800087:	5b                   	pop    %ebx
  800088:	5e                   	pop    %esi
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    

0080008b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008b:	55                   	push   %ebp
  80008c:	89 e5                	mov    %esp,%ebp
  80008e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800091:	6a 00                	push   $0x0
  800093:	e8 42 00 00 00       	call   8000da <sys_env_destroy>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	c9                   	leave  
  80009c:	c3                   	ret    

0080009d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	57                   	push   %edi
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ae:	89 c3                	mov    %eax,%ebx
  8000b0:	89 c7                	mov    %eax,%edi
  8000b2:	89 c6                	mov    %eax,%esi
  8000b4:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b6:	5b                   	pop    %ebx
  8000b7:	5e                   	pop    %esi
  8000b8:	5f                   	pop    %edi
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	57                   	push   %edi
  8000bf:	56                   	push   %esi
  8000c0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cb:	89 d1                	mov    %edx,%ecx
  8000cd:	89 d3                	mov    %edx,%ebx
  8000cf:	89 d7                	mov    %edx,%edi
  8000d1:	89 d6                	mov    %edx,%esi
  8000d3:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
  8000e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f0:	89 cb                	mov    %ecx,%ebx
  8000f2:	89 cf                	mov    %ecx,%edi
  8000f4:	89 ce                	mov    %ecx,%esi
  8000f6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f8:	85 c0                	test   %eax,%eax
  8000fa:	7e 17                	jle    800113 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fc:	83 ec 0c             	sub    $0xc,%esp
  8000ff:	50                   	push   %eax
  800100:	6a 03                	push   $0x3
  800102:	68 ce 0d 80 00       	push   $0x800dce
  800107:	6a 23                	push   $0x23
  800109:	68 eb 0d 80 00       	push   $0x800deb
  80010e:	e8 3c 00 00 00       	call   80014f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800113:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5f                   	pop    %edi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	83 ec 14             	sub    $0x14,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800124:	ba 00 00 00 00       	mov    $0x0,%edx
  800129:	b8 02 00 00 00       	mov    $0x2,%eax
  80012e:	89 d1                	mov    %edx,%ecx
  800130:	89 d3                	mov    %edx,%ebx
  800132:	89 d7                	mov    %edx,%edi
  800134:	89 d6                	mov    %edx,%esi
  800136:	cd 30                	int    $0x30
  800138:	89 c3                	mov    %eax,%ebx

envid_t
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	cprintf("lib/syscall.c: %x\n", ret);
  80013a:	50                   	push   %eax
  80013b:	68 f9 0d 80 00       	push   $0x800df9
  800140:	e8 e3 00 00 00       	call   800228 <cprintf>
	return ret;
}
  800145:	89 d8                	mov    %ebx,%eax
  800147:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80014a:	5b                   	pop    %ebx
  80014b:	5e                   	pop    %esi
  80014c:	5f                   	pop    %edi
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    

0080014f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800154:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800157:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80015d:	e8 b9 ff ff ff       	call   80011b <sys_getenvid>
  800162:	83 ec 0c             	sub    $0xc,%esp
  800165:	ff 75 0c             	pushl  0xc(%ebp)
  800168:	ff 75 08             	pushl  0x8(%ebp)
  80016b:	56                   	push   %esi
  80016c:	50                   	push   %eax
  80016d:	68 0c 0e 80 00       	push   $0x800e0c
  800172:	e8 b1 00 00 00       	call   800228 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800177:	83 c4 18             	add    $0x18,%esp
  80017a:	53                   	push   %ebx
  80017b:	ff 75 10             	pushl  0x10(%ebp)
  80017e:	e8 54 00 00 00       	call   8001d7 <vcprintf>
	cprintf("\n");
  800183:	c7 04 24 0a 0e 80 00 	movl   $0x800e0a,(%esp)
  80018a:	e8 99 00 00 00       	call   800228 <cprintf>
  80018f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800192:	cc                   	int3   
  800193:	eb fd                	jmp    800192 <_panic+0x43>

00800195 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	53                   	push   %ebx
  800199:	83 ec 04             	sub    $0x4,%esp
  80019c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019f:	8b 13                	mov    (%ebx),%edx
  8001a1:	8d 42 01             	lea    0x1(%edx),%eax
  8001a4:	89 03                	mov    %eax,(%ebx)
  8001a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ad:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b2:	75 1a                	jne    8001ce <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	68 ff 00 00 00       	push   $0xff
  8001bc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bf:	50                   	push   %eax
  8001c0:	e8 d8 fe ff ff       	call   80009d <sys_cputs>
		b->idx = 0;
  8001c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ce:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d5:	c9                   	leave  
  8001d6:	c3                   	ret    

008001d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e7:	00 00 00 
	b.cnt = 0;
  8001ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f4:	ff 75 0c             	pushl  0xc(%ebp)
  8001f7:	ff 75 08             	pushl  0x8(%ebp)
  8001fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800200:	50                   	push   %eax
  800201:	68 95 01 80 00       	push   $0x800195
  800206:	e8 54 01 00 00       	call   80035f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80020b:	83 c4 08             	add    $0x8,%esp
  80020e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800214:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80021a:	50                   	push   %eax
  80021b:	e8 7d fe ff ff       	call   80009d <sys_cputs>

	return b.cnt;
}
  800220:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800231:	50                   	push   %eax
  800232:	ff 75 08             	pushl  0x8(%ebp)
  800235:	e8 9d ff ff ff       	call   8001d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	57                   	push   %edi
  800240:	56                   	push   %esi
  800241:	53                   	push   %ebx
  800242:	83 ec 1c             	sub    $0x1c,%esp
  800245:	89 c7                	mov    %eax,%edi
  800247:	89 d6                	mov    %edx,%esi
  800249:	8b 45 08             	mov    0x8(%ebp),%eax
  80024c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800252:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800255:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800258:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800260:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800263:	39 d3                	cmp    %edx,%ebx
  800265:	72 05                	jb     80026c <printnum+0x30>
  800267:	39 45 10             	cmp    %eax,0x10(%ebp)
  80026a:	77 45                	ja     8002b1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	ff 75 18             	pushl  0x18(%ebp)
  800272:	8b 45 14             	mov    0x14(%ebp),%eax
  800275:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800278:	53                   	push   %ebx
  800279:	ff 75 10             	pushl  0x10(%ebp)
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800282:	ff 75 e0             	pushl  -0x20(%ebp)
  800285:	ff 75 dc             	pushl  -0x24(%ebp)
  800288:	ff 75 d8             	pushl  -0x28(%ebp)
  80028b:	e8 b0 08 00 00       	call   800b40 <__udivdi3>
  800290:	83 c4 18             	add    $0x18,%esp
  800293:	52                   	push   %edx
  800294:	50                   	push   %eax
  800295:	89 f2                	mov    %esi,%edx
  800297:	89 f8                	mov    %edi,%eax
  800299:	e8 9e ff ff ff       	call   80023c <printnum>
  80029e:	83 c4 20             	add    $0x20,%esp
  8002a1:	eb 18                	jmp    8002bb <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a3:	83 ec 08             	sub    $0x8,%esp
  8002a6:	56                   	push   %esi
  8002a7:	ff 75 18             	pushl  0x18(%ebp)
  8002aa:	ff d7                	call   *%edi
  8002ac:	83 c4 10             	add    $0x10,%esp
  8002af:	eb 03                	jmp    8002b4 <printnum+0x78>
  8002b1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b4:	83 eb 01             	sub    $0x1,%ebx
  8002b7:	85 db                	test   %ebx,%ebx
  8002b9:	7f e8                	jg     8002a3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002bb:	83 ec 08             	sub    $0x8,%esp
  8002be:	56                   	push   %esi
  8002bf:	83 ec 04             	sub    $0x4,%esp
  8002c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ce:	e8 9d 09 00 00       	call   800c70 <__umoddi3>
  8002d3:	83 c4 14             	add    $0x14,%esp
  8002d6:	0f be 80 30 0e 80 00 	movsbl 0x800e30(%eax),%eax
  8002dd:	50                   	push   %eax
  8002de:	ff d7                	call   *%edi
}
  8002e0:	83 c4 10             	add    $0x10,%esp
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ee:	83 fa 01             	cmp    $0x1,%edx
  8002f1:	7e 0e                	jle    800301 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002f3:	8b 10                	mov    (%eax),%edx
  8002f5:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f8:	89 08                	mov    %ecx,(%eax)
  8002fa:	8b 02                	mov    (%edx),%eax
  8002fc:	8b 52 04             	mov    0x4(%edx),%edx
  8002ff:	eb 22                	jmp    800323 <getuint+0x38>
	else if (lflag)
  800301:	85 d2                	test   %edx,%edx
  800303:	74 10                	je     800315 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800305:	8b 10                	mov    (%eax),%edx
  800307:	8d 4a 04             	lea    0x4(%edx),%ecx
  80030a:	89 08                	mov    %ecx,(%eax)
  80030c:	8b 02                	mov    (%edx),%eax
  80030e:	ba 00 00 00 00       	mov    $0x0,%edx
  800313:	eb 0e                	jmp    800323 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800315:	8b 10                	mov    (%eax),%edx
  800317:	8d 4a 04             	lea    0x4(%edx),%ecx
  80031a:	89 08                	mov    %ecx,(%eax)
  80031c:	8b 02                	mov    (%edx),%eax
  80031e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    

00800325 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800325:	55                   	push   %ebp
  800326:	89 e5                	mov    %esp,%ebp
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80032b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032f:	8b 10                	mov    (%eax),%edx
  800331:	3b 50 04             	cmp    0x4(%eax),%edx
  800334:	73 0a                	jae    800340 <sprintputch+0x1b>
		*b->buf++ = ch;
  800336:	8d 4a 01             	lea    0x1(%edx),%ecx
  800339:	89 08                	mov    %ecx,(%eax)
  80033b:	8b 45 08             	mov    0x8(%ebp),%eax
  80033e:	88 02                	mov    %al,(%edx)
}
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800348:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80034b:	50                   	push   %eax
  80034c:	ff 75 10             	pushl  0x10(%ebp)
  80034f:	ff 75 0c             	pushl  0xc(%ebp)
  800352:	ff 75 08             	pushl  0x8(%ebp)
  800355:	e8 05 00 00 00       	call   80035f <vprintfmt>
	va_end(ap);
}
  80035a:	83 c4 10             	add    $0x10,%esp
  80035d:	c9                   	leave  
  80035e:	c3                   	ret    

0080035f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	57                   	push   %edi
  800363:	56                   	push   %esi
  800364:	53                   	push   %ebx
  800365:	83 ec 2c             	sub    $0x2c,%esp
  800368:	8b 75 08             	mov    0x8(%ebp),%esi
  80036b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800371:	eb 1d                	jmp    800390 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  800373:	85 c0                	test   %eax,%eax
  800375:	75 0f                	jne    800386 <vprintfmt+0x27>
				csa = 0x0700;
  800377:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80037e:	07 00 00 
				return;
  800381:	e9 c4 03 00 00       	jmp    80074a <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	53                   	push   %ebx
  80038a:	50                   	push   %eax
  80038b:	ff d6                	call   *%esi
  80038d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800390:	83 c7 01             	add    $0x1,%edi
  800393:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800397:	83 f8 25             	cmp    $0x25,%eax
  80039a:	75 d7                	jne    800373 <vprintfmt+0x14>
  80039c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003a0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ae:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ba:	eb 07                	jmp    8003c3 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bf:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8d 47 01             	lea    0x1(%edi),%eax
  8003c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c9:	0f b6 07             	movzbl (%edi),%eax
  8003cc:	0f b6 c8             	movzbl %al,%ecx
  8003cf:	83 e8 23             	sub    $0x23,%eax
  8003d2:	3c 55                	cmp    $0x55,%al
  8003d4:	0f 87 55 03 00 00    	ja     80072f <vprintfmt+0x3d0>
  8003da:	0f b6 c0             	movzbl %al,%eax
  8003dd:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003eb:	eb d6                	jmp    8003c3 <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003fb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003ff:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800402:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800405:	83 fa 09             	cmp    $0x9,%edx
  800408:	77 39                	ja     800443 <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80040a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80040d:	eb e9                	jmp    8003f8 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8d 48 04             	lea    0x4(%eax),%ecx
  800415:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800418:	8b 00                	mov    (%eax),%eax
  80041a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800420:	eb 27                	jmp    800449 <vprintfmt+0xea>
  800422:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800425:	85 c0                	test   %eax,%eax
  800427:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042c:	0f 49 c8             	cmovns %eax,%ecx
  80042f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800435:	eb 8c                	jmp    8003c3 <vprintfmt+0x64>
  800437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80043a:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800441:	eb 80                	jmp    8003c3 <vprintfmt+0x64>
  800443:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800446:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800449:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80044d:	0f 89 70 ff ff ff    	jns    8003c3 <vprintfmt+0x64>
				width = precision, precision = -1;
  800453:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800456:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800459:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800460:	e9 5e ff ff ff       	jmp    8003c3 <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800465:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80046b:	e9 53 ff ff ff       	jmp    8003c3 <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 50 04             	lea    0x4(%eax),%edx
  800476:	89 55 14             	mov    %edx,0x14(%ebp)
  800479:	83 ec 08             	sub    $0x8,%esp
  80047c:	53                   	push   %ebx
  80047d:	ff 30                	pushl  (%eax)
  80047f:	ff d6                	call   *%esi
			break;
  800481:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800487:	e9 04 ff ff ff       	jmp    800390 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 50 04             	lea    0x4(%eax),%edx
  800492:	89 55 14             	mov    %edx,0x14(%ebp)
  800495:	8b 00                	mov    (%eax),%eax
  800497:	99                   	cltd   
  800498:	31 d0                	xor    %edx,%eax
  80049a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80049c:	83 f8 06             	cmp    $0x6,%eax
  80049f:	7f 0b                	jg     8004ac <vprintfmt+0x14d>
  8004a1:	8b 14 85 18 10 80 00 	mov    0x801018(,%eax,4),%edx
  8004a8:	85 d2                	test   %edx,%edx
  8004aa:	75 18                	jne    8004c4 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8004ac:	50                   	push   %eax
  8004ad:	68 48 0e 80 00       	push   $0x800e48
  8004b2:	53                   	push   %ebx
  8004b3:	56                   	push   %esi
  8004b4:	e8 89 fe ff ff       	call   800342 <printfmt>
  8004b9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bf:	e9 cc fe ff ff       	jmp    800390 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8004c4:	52                   	push   %edx
  8004c5:	68 51 0e 80 00       	push   $0x800e51
  8004ca:	53                   	push   %ebx
  8004cb:	56                   	push   %esi
  8004cc:	e8 71 fe ff ff       	call   800342 <printfmt>
  8004d1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d7:	e9 b4 fe ff ff       	jmp    800390 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8004df:	8d 50 04             	lea    0x4(%eax),%edx
  8004e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e7:	85 ff                	test   %edi,%edi
  8004e9:	b8 41 0e 80 00       	mov    $0x800e41,%eax
  8004ee:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f5:	0f 8e 94 00 00 00    	jle    80058f <vprintfmt+0x230>
  8004fb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004ff:	0f 84 98 00 00 00    	je     80059d <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	ff 75 d0             	pushl  -0x30(%ebp)
  80050b:	57                   	push   %edi
  80050c:	e8 c1 02 00 00       	call   8007d2 <strnlen>
  800511:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800514:	29 c1                	sub    %eax,%ecx
  800516:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800519:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80051c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800520:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800523:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800526:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800528:	eb 0f                	jmp    800539 <vprintfmt+0x1da>
					putch(padc, putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	53                   	push   %ebx
  80052e:	ff 75 e0             	pushl  -0x20(%ebp)
  800531:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800533:	83 ef 01             	sub    $0x1,%edi
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	85 ff                	test   %edi,%edi
  80053b:	7f ed                	jg     80052a <vprintfmt+0x1cb>
  80053d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800540:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800543:	85 c9                	test   %ecx,%ecx
  800545:	b8 00 00 00 00       	mov    $0x0,%eax
  80054a:	0f 49 c1             	cmovns %ecx,%eax
  80054d:	29 c1                	sub    %eax,%ecx
  80054f:	89 75 08             	mov    %esi,0x8(%ebp)
  800552:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800555:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800558:	89 cb                	mov    %ecx,%ebx
  80055a:	eb 4d                	jmp    8005a9 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800560:	74 1b                	je     80057d <vprintfmt+0x21e>
  800562:	0f be c0             	movsbl %al,%eax
  800565:	83 e8 20             	sub    $0x20,%eax
  800568:	83 f8 5e             	cmp    $0x5e,%eax
  80056b:	76 10                	jbe    80057d <vprintfmt+0x21e>
					putch('?', putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	ff 75 0c             	pushl  0xc(%ebp)
  800573:	6a 3f                	push   $0x3f
  800575:	ff 55 08             	call   *0x8(%ebp)
  800578:	83 c4 10             	add    $0x10,%esp
  80057b:	eb 0d                	jmp    80058a <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	ff 75 0c             	pushl  0xc(%ebp)
  800583:	52                   	push   %edx
  800584:	ff 55 08             	call   *0x8(%ebp)
  800587:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058a:	83 eb 01             	sub    $0x1,%ebx
  80058d:	eb 1a                	jmp    8005a9 <vprintfmt+0x24a>
  80058f:	89 75 08             	mov    %esi,0x8(%ebp)
  800592:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800595:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800598:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80059b:	eb 0c                	jmp    8005a9 <vprintfmt+0x24a>
  80059d:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a9:	83 c7 01             	add    $0x1,%edi
  8005ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005b0:	0f be d0             	movsbl %al,%edx
  8005b3:	85 d2                	test   %edx,%edx
  8005b5:	74 23                	je     8005da <vprintfmt+0x27b>
  8005b7:	85 f6                	test   %esi,%esi
  8005b9:	78 a1                	js     80055c <vprintfmt+0x1fd>
  8005bb:	83 ee 01             	sub    $0x1,%esi
  8005be:	79 9c                	jns    80055c <vprintfmt+0x1fd>
  8005c0:	89 df                	mov    %ebx,%edi
  8005c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c8:	eb 18                	jmp    8005e2 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ca:	83 ec 08             	sub    $0x8,%esp
  8005cd:	53                   	push   %ebx
  8005ce:	6a 20                	push   $0x20
  8005d0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d2:	83 ef 01             	sub    $0x1,%edi
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	eb 08                	jmp    8005e2 <vprintfmt+0x283>
  8005da:	89 df                	mov    %ebx,%edi
  8005dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8005df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005e2:	85 ff                	test   %edi,%edi
  8005e4:	7f e4                	jg     8005ca <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e9:	e9 a2 fd ff ff       	jmp    800390 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ee:	83 fa 01             	cmp    $0x1,%edx
  8005f1:	7e 16                	jle    800609 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 08             	lea    0x8(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fc:	8b 50 04             	mov    0x4(%eax),%edx
  8005ff:	8b 00                	mov    (%eax),%eax
  800601:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800604:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800607:	eb 32                	jmp    80063b <vprintfmt+0x2dc>
	else if (lflag)
  800609:	85 d2                	test   %edx,%edx
  80060b:	74 18                	je     800625 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8d 50 04             	lea    0x4(%eax),%edx
  800613:	89 55 14             	mov    %edx,0x14(%ebp)
  800616:	8b 00                	mov    (%eax),%eax
  800618:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80061b:	89 c1                	mov    %eax,%ecx
  80061d:	c1 f9 1f             	sar    $0x1f,%ecx
  800620:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800623:	eb 16                	jmp    80063b <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800625:	8b 45 14             	mov    0x14(%ebp),%eax
  800628:	8d 50 04             	lea    0x4(%eax),%edx
  80062b:	89 55 14             	mov    %edx,0x14(%ebp)
  80062e:	8b 00                	mov    (%eax),%eax
  800630:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800633:	89 c1                	mov    %eax,%ecx
  800635:	c1 f9 1f             	sar    $0x1f,%ecx
  800638:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80063b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800641:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800646:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80064a:	79 74                	jns    8006c0 <vprintfmt+0x361>
				putch('-', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 2d                	push   $0x2d
  800652:	ff d6                	call   *%esi
				num = -(long long) num;
  800654:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800657:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80065a:	f7 d8                	neg    %eax
  80065c:	83 d2 00             	adc    $0x0,%edx
  80065f:	f7 da                	neg    %edx
  800661:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800664:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800669:	eb 55                	jmp    8006c0 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
  80066e:	e8 78 fc ff ff       	call   8002eb <getuint>
			base = 10;
  800673:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800678:	eb 46                	jmp    8006c0 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  80067a:	8d 45 14             	lea    0x14(%ebp),%eax
  80067d:	e8 69 fc ff ff       	call   8002eb <getuint>
      base = 8;
  800682:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800687:	eb 37                	jmp    8006c0 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	6a 30                	push   $0x30
  80068f:	ff d6                	call   *%esi
			putch('x', putdat);
  800691:	83 c4 08             	add    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	6a 78                	push   $0x78
  800697:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8d 50 04             	lea    0x4(%eax),%edx
  80069f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a2:	8b 00                	mov    (%eax),%eax
  8006a4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ac:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006b1:	eb 0d                	jmp    8006c0 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b6:	e8 30 fc ff ff       	call   8002eb <getuint>
			base = 16;
  8006bb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c0:	83 ec 0c             	sub    $0xc,%esp
  8006c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c7:	57                   	push   %edi
  8006c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cb:	51                   	push   %ecx
  8006cc:	52                   	push   %edx
  8006cd:	50                   	push   %eax
  8006ce:	89 da                	mov    %ebx,%edx
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	e8 65 fb ff ff       	call   80023c <printnum>
			break;
  8006d7:	83 c4 20             	add    $0x20,%esp
  8006da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006dd:	e9 ae fc ff ff       	jmp    800390 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	51                   	push   %ecx
  8006e7:	ff d6                	call   *%esi
			break;
  8006e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ef:	e9 9c fc ff ff       	jmp    800390 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f4:	83 fa 01             	cmp    $0x1,%edx
  8006f7:	7e 0d                	jle    800706 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8006f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fc:	8d 50 08             	lea    0x8(%eax),%edx
  8006ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800702:	8b 00                	mov    (%eax),%eax
  800704:	eb 1c                	jmp    800722 <vprintfmt+0x3c3>
	else if (lflag)
  800706:	85 d2                	test   %edx,%edx
  800708:	74 0d                	je     800717 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)
  800713:	8b 00                	mov    (%eax),%eax
  800715:	eb 0b                	jmp    800722 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8d 50 04             	lea    0x4(%eax),%edx
  80071d:	89 55 14             	mov    %edx,0x14(%ebp)
  800720:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800722:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800727:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  80072a:	e9 61 fc ff ff       	jmp    800390 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072f:	83 ec 08             	sub    $0x8,%esp
  800732:	53                   	push   %ebx
  800733:	6a 25                	push   $0x25
  800735:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800737:	83 c4 10             	add    $0x10,%esp
  80073a:	eb 03                	jmp    80073f <vprintfmt+0x3e0>
  80073c:	83 ef 01             	sub    $0x1,%edi
  80073f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800743:	75 f7                	jne    80073c <vprintfmt+0x3dd>
  800745:	e9 46 fc ff ff       	jmp    800390 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  80074a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 18             	sub    $0x18,%esp
  800758:	8b 45 08             	mov    0x8(%ebp),%eax
  80075b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800761:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800765:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800768:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076f:	85 c0                	test   %eax,%eax
  800771:	74 26                	je     800799 <vsnprintf+0x47>
  800773:	85 d2                	test   %edx,%edx
  800775:	7e 22                	jle    800799 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800777:	ff 75 14             	pushl  0x14(%ebp)
  80077a:	ff 75 10             	pushl  0x10(%ebp)
  80077d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800780:	50                   	push   %eax
  800781:	68 25 03 80 00       	push   $0x800325
  800786:	e8 d4 fb ff ff       	call   80035f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800791:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800794:	83 c4 10             	add    $0x10,%esp
  800797:	eb 05                	jmp    80079e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800799:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079e:	c9                   	leave  
  80079f:	c3                   	ret    

008007a0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a9:	50                   	push   %eax
  8007aa:	ff 75 10             	pushl  0x10(%ebp)
  8007ad:	ff 75 0c             	pushl  0xc(%ebp)
  8007b0:	ff 75 08             	pushl  0x8(%ebp)
  8007b3:	e8 9a ff ff ff       	call   800752 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c5:	eb 03                	jmp    8007ca <strlen+0x10>
		n++;
  8007c7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ca:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ce:	75 f7                	jne    8007c7 <strlen+0xd>
		n++;
	return n;
}
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e0:	eb 03                	jmp    8007e5 <strnlen+0x13>
		n++;
  8007e2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e5:	39 c2                	cmp    %eax,%edx
  8007e7:	74 08                	je     8007f1 <strnlen+0x1f>
  8007e9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ed:	75 f3                	jne    8007e2 <strnlen+0x10>
  8007ef:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fd:	89 c2                	mov    %eax,%edx
  8007ff:	83 c2 01             	add    $0x1,%edx
  800802:	83 c1 01             	add    $0x1,%ecx
  800805:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800809:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080c:	84 db                	test   %bl,%bl
  80080e:	75 ef                	jne    8007ff <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800810:	5b                   	pop    %ebx
  800811:	5d                   	pop    %ebp
  800812:	c3                   	ret    

00800813 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081a:	53                   	push   %ebx
  80081b:	e8 9a ff ff ff       	call   8007ba <strlen>
  800820:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800823:	ff 75 0c             	pushl  0xc(%ebp)
  800826:	01 d8                	add    %ebx,%eax
  800828:	50                   	push   %eax
  800829:	e8 c5 ff ff ff       	call   8007f3 <strcpy>
	return dst;
}
  80082e:	89 d8                	mov    %ebx,%eax
  800830:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	56                   	push   %esi
  800839:	53                   	push   %ebx
  80083a:	8b 75 08             	mov    0x8(%ebp),%esi
  80083d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800840:	89 f3                	mov    %esi,%ebx
  800842:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800845:	89 f2                	mov    %esi,%edx
  800847:	eb 0f                	jmp    800858 <strncpy+0x23>
		*dst++ = *src;
  800849:	83 c2 01             	add    $0x1,%edx
  80084c:	0f b6 01             	movzbl (%ecx),%eax
  80084f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800852:	80 39 01             	cmpb   $0x1,(%ecx)
  800855:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800858:	39 da                	cmp    %ebx,%edx
  80085a:	75 ed                	jne    800849 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085c:	89 f0                	mov    %esi,%eax
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	56                   	push   %esi
  800866:	53                   	push   %ebx
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086d:	8b 55 10             	mov    0x10(%ebp),%edx
  800870:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800872:	85 d2                	test   %edx,%edx
  800874:	74 21                	je     800897 <strlcpy+0x35>
  800876:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80087a:	89 f2                	mov    %esi,%edx
  80087c:	eb 09                	jmp    800887 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087e:	83 c2 01             	add    $0x1,%edx
  800881:	83 c1 01             	add    $0x1,%ecx
  800884:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800887:	39 c2                	cmp    %eax,%edx
  800889:	74 09                	je     800894 <strlcpy+0x32>
  80088b:	0f b6 19             	movzbl (%ecx),%ebx
  80088e:	84 db                	test   %bl,%bl
  800890:	75 ec                	jne    80087e <strlcpy+0x1c>
  800892:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800894:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800897:	29 f0                	sub    %esi,%eax
}
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a6:	eb 06                	jmp    8008ae <strcmp+0x11>
		p++, q++;
  8008a8:	83 c1 01             	add    $0x1,%ecx
  8008ab:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ae:	0f b6 01             	movzbl (%ecx),%eax
  8008b1:	84 c0                	test   %al,%al
  8008b3:	74 04                	je     8008b9 <strcmp+0x1c>
  8008b5:	3a 02                	cmp    (%edx),%al
  8008b7:	74 ef                	je     8008a8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b9:	0f b6 c0             	movzbl %al,%eax
  8008bc:	0f b6 12             	movzbl (%edx),%edx
  8008bf:	29 d0                	sub    %edx,%eax
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	53                   	push   %ebx
  8008c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cd:	89 c3                	mov    %eax,%ebx
  8008cf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d2:	eb 06                	jmp    8008da <strncmp+0x17>
		n--, p++, q++;
  8008d4:	83 c0 01             	add    $0x1,%eax
  8008d7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008da:	39 d8                	cmp    %ebx,%eax
  8008dc:	74 15                	je     8008f3 <strncmp+0x30>
  8008de:	0f b6 08             	movzbl (%eax),%ecx
  8008e1:	84 c9                	test   %cl,%cl
  8008e3:	74 04                	je     8008e9 <strncmp+0x26>
  8008e5:	3a 0a                	cmp    (%edx),%cl
  8008e7:	74 eb                	je     8008d4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e9:	0f b6 00             	movzbl (%eax),%eax
  8008ec:	0f b6 12             	movzbl (%edx),%edx
  8008ef:	29 d0                	sub    %edx,%eax
  8008f1:	eb 05                	jmp    8008f8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f8:	5b                   	pop    %ebx
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800905:	eb 07                	jmp    80090e <strchr+0x13>
		if (*s == c)
  800907:	38 ca                	cmp    %cl,%dl
  800909:	74 0f                	je     80091a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	0f b6 10             	movzbl (%eax),%edx
  800911:	84 d2                	test   %dl,%dl
  800913:	75 f2                	jne    800907 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800926:	eb 03                	jmp    80092b <strfind+0xf>
  800928:	83 c0 01             	add    $0x1,%eax
  80092b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092e:	38 ca                	cmp    %cl,%dl
  800930:	74 04                	je     800936 <strfind+0x1a>
  800932:	84 d2                	test   %dl,%dl
  800934:	75 f2                	jne    800928 <strfind+0xc>
			break;
	return (char *) s;
}
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	57                   	push   %edi
  80093c:	56                   	push   %esi
  80093d:	53                   	push   %ebx
  80093e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800944:	85 c9                	test   %ecx,%ecx
  800946:	74 36                	je     80097e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800948:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094e:	75 28                	jne    800978 <memset+0x40>
  800950:	f6 c1 03             	test   $0x3,%cl
  800953:	75 23                	jne    800978 <memset+0x40>
		c &= 0xFF;
  800955:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800959:	89 d3                	mov    %edx,%ebx
  80095b:	c1 e3 08             	shl    $0x8,%ebx
  80095e:	89 d6                	mov    %edx,%esi
  800960:	c1 e6 18             	shl    $0x18,%esi
  800963:	89 d0                	mov    %edx,%eax
  800965:	c1 e0 10             	shl    $0x10,%eax
  800968:	09 f0                	or     %esi,%eax
  80096a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096c:	89 d8                	mov    %ebx,%eax
  80096e:	09 d0                	or     %edx,%eax
  800970:	c1 e9 02             	shr    $0x2,%ecx
  800973:	fc                   	cld    
  800974:	f3 ab                	rep stos %eax,%es:(%edi)
  800976:	eb 06                	jmp    80097e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800978:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097b:	fc                   	cld    
  80097c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097e:	89 f8                	mov    %edi,%eax
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5f                   	pop    %edi
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	57                   	push   %edi
  800989:	56                   	push   %esi
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800990:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800993:	39 c6                	cmp    %eax,%esi
  800995:	73 35                	jae    8009cc <memmove+0x47>
  800997:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099a:	39 d0                	cmp    %edx,%eax
  80099c:	73 2e                	jae    8009cc <memmove+0x47>
		s += n;
		d += n;
  80099e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a1:	89 d6                	mov    %edx,%esi
  8009a3:	09 fe                	or     %edi,%esi
  8009a5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ab:	75 13                	jne    8009c0 <memmove+0x3b>
  8009ad:	f6 c1 03             	test   $0x3,%cl
  8009b0:	75 0e                	jne    8009c0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b2:	83 ef 04             	sub    $0x4,%edi
  8009b5:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b8:	c1 e9 02             	shr    $0x2,%ecx
  8009bb:	fd                   	std    
  8009bc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009be:	eb 09                	jmp    8009c9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c0:	83 ef 01             	sub    $0x1,%edi
  8009c3:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c6:	fd                   	std    
  8009c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c9:	fc                   	cld    
  8009ca:	eb 1d                	jmp    8009e9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cc:	89 f2                	mov    %esi,%edx
  8009ce:	09 c2                	or     %eax,%edx
  8009d0:	f6 c2 03             	test   $0x3,%dl
  8009d3:	75 0f                	jne    8009e4 <memmove+0x5f>
  8009d5:	f6 c1 03             	test   $0x3,%cl
  8009d8:	75 0a                	jne    8009e4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009da:	c1 e9 02             	shr    $0x2,%ecx
  8009dd:	89 c7                	mov    %eax,%edi
  8009df:	fc                   	cld    
  8009e0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e2:	eb 05                	jmp    8009e9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e4:	89 c7                	mov    %eax,%edi
  8009e6:	fc                   	cld    
  8009e7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e9:	5e                   	pop    %esi
  8009ea:	5f                   	pop    %edi
  8009eb:	5d                   	pop    %ebp
  8009ec:	c3                   	ret    

008009ed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f0:	ff 75 10             	pushl  0x10(%ebp)
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	ff 75 08             	pushl  0x8(%ebp)
  8009f9:	e8 87 ff ff ff       	call   800985 <memmove>
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	56                   	push   %esi
  800a04:	53                   	push   %ebx
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0b:	89 c6                	mov    %eax,%esi
  800a0d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a10:	eb 1a                	jmp    800a2c <memcmp+0x2c>
		if (*s1 != *s2)
  800a12:	0f b6 08             	movzbl (%eax),%ecx
  800a15:	0f b6 1a             	movzbl (%edx),%ebx
  800a18:	38 d9                	cmp    %bl,%cl
  800a1a:	74 0a                	je     800a26 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1c:	0f b6 c1             	movzbl %cl,%eax
  800a1f:	0f b6 db             	movzbl %bl,%ebx
  800a22:	29 d8                	sub    %ebx,%eax
  800a24:	eb 0f                	jmp    800a35 <memcmp+0x35>
		s1++, s2++;
  800a26:	83 c0 01             	add    $0x1,%eax
  800a29:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2c:	39 f0                	cmp    %esi,%eax
  800a2e:	75 e2                	jne    800a12 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a35:	5b                   	pop    %ebx
  800a36:	5e                   	pop    %esi
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	53                   	push   %ebx
  800a3d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a40:	89 c1                	mov    %eax,%ecx
  800a42:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a45:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a49:	eb 0a                	jmp    800a55 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4b:	0f b6 10             	movzbl (%eax),%edx
  800a4e:	39 da                	cmp    %ebx,%edx
  800a50:	74 07                	je     800a59 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a52:	83 c0 01             	add    $0x1,%eax
  800a55:	39 c8                	cmp    %ecx,%eax
  800a57:	72 f2                	jb     800a4b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a59:	5b                   	pop    %ebx
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a68:	eb 03                	jmp    800a6d <strtol+0x11>
		s++;
  800a6a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6d:	0f b6 01             	movzbl (%ecx),%eax
  800a70:	3c 20                	cmp    $0x20,%al
  800a72:	74 f6                	je     800a6a <strtol+0xe>
  800a74:	3c 09                	cmp    $0x9,%al
  800a76:	74 f2                	je     800a6a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a78:	3c 2b                	cmp    $0x2b,%al
  800a7a:	75 0a                	jne    800a86 <strtol+0x2a>
		s++;
  800a7c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7f:	bf 00 00 00 00       	mov    $0x0,%edi
  800a84:	eb 11                	jmp    800a97 <strtol+0x3b>
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8b:	3c 2d                	cmp    $0x2d,%al
  800a8d:	75 08                	jne    800a97 <strtol+0x3b>
		s++, neg = 1;
  800a8f:	83 c1 01             	add    $0x1,%ecx
  800a92:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a97:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9d:	75 15                	jne    800ab4 <strtol+0x58>
  800a9f:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa2:	75 10                	jne    800ab4 <strtol+0x58>
  800aa4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa8:	75 7c                	jne    800b26 <strtol+0xca>
		s += 2, base = 16;
  800aaa:	83 c1 02             	add    $0x2,%ecx
  800aad:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab2:	eb 16                	jmp    800aca <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab4:	85 db                	test   %ebx,%ebx
  800ab6:	75 12                	jne    800aca <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abd:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac0:	75 08                	jne    800aca <strtol+0x6e>
		s++, base = 8;
  800ac2:	83 c1 01             	add    $0x1,%ecx
  800ac5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aca:	b8 00 00 00 00       	mov    $0x0,%eax
  800acf:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad2:	0f b6 11             	movzbl (%ecx),%edx
  800ad5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad8:	89 f3                	mov    %esi,%ebx
  800ada:	80 fb 09             	cmp    $0x9,%bl
  800add:	77 08                	ja     800ae7 <strtol+0x8b>
			dig = *s - '0';
  800adf:	0f be d2             	movsbl %dl,%edx
  800ae2:	83 ea 30             	sub    $0x30,%edx
  800ae5:	eb 22                	jmp    800b09 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae7:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aea:	89 f3                	mov    %esi,%ebx
  800aec:	80 fb 19             	cmp    $0x19,%bl
  800aef:	77 08                	ja     800af9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af1:	0f be d2             	movsbl %dl,%edx
  800af4:	83 ea 57             	sub    $0x57,%edx
  800af7:	eb 10                	jmp    800b09 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af9:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afc:	89 f3                	mov    %esi,%ebx
  800afe:	80 fb 19             	cmp    $0x19,%bl
  800b01:	77 16                	ja     800b19 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b03:	0f be d2             	movsbl %dl,%edx
  800b06:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b09:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0c:	7d 0b                	jge    800b19 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0e:	83 c1 01             	add    $0x1,%ecx
  800b11:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b15:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b17:	eb b9                	jmp    800ad2 <strtol+0x76>

	if (endptr)
  800b19:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1d:	74 0d                	je     800b2c <strtol+0xd0>
		*endptr = (char *) s;
  800b1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b22:	89 0e                	mov    %ecx,(%esi)
  800b24:	eb 06                	jmp    800b2c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b26:	85 db                	test   %ebx,%ebx
  800b28:	74 98                	je     800ac2 <strtol+0x66>
  800b2a:	eb 9e                	jmp    800aca <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2c:	89 c2                	mov    %eax,%edx
  800b2e:	f7 da                	neg    %edx
  800b30:	85 ff                	test   %edi,%edi
  800b32:	0f 45 c2             	cmovne %edx,%eax
}
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    
  800b3a:	66 90                	xchg   %ax,%ax
  800b3c:	66 90                	xchg   %ax,%ax
  800b3e:	66 90                	xchg   %ax,%ax

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
