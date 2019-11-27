
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800049:	e8 c9 00 00 00       	call   800117 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800056:	c1 e0 05             	shl    $0x5,%eax
  800059:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005e:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800063:	85 db                	test   %ebx,%ebx
  800065:	7e 07                	jle    80006e <libmain+0x30>
		binaryname = argv[0];
  800067:	8b 06                	mov    (%esi),%eax
  800069:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006e:	83 ec 08             	sub    $0x8,%esp
  800071:	56                   	push   %esi
  800072:	53                   	push   %ebx
  800073:	e8 bb ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800078:	e8 0a 00 00 00       	call   800087 <exit>
}
  80007d:	83 c4 10             	add    $0x10,%esp
  800080:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800083:	5b                   	pop    %ebx
  800084:	5e                   	pop    %esi
  800085:	5d                   	pop    %ebp
  800086:	c3                   	ret    

00800087 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800087:	55                   	push   %ebp
  800088:	89 e5                	mov    %esp,%ebp
  80008a:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 ce 0d 80 00       	push   $0x800dce
  800103:	6a 23                	push   $0x23
  800105:	68 eb 0d 80 00       	push   $0x800deb
  80010a:	e8 3c 00 00 00       	call   80014b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
  80011d:	83 ec 14             	sub    $0x14,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800120:	ba 00 00 00 00       	mov    $0x0,%edx
  800125:	b8 02 00 00 00       	mov    $0x2,%eax
  80012a:	89 d1                	mov    %edx,%ecx
  80012c:	89 d3                	mov    %edx,%ebx
  80012e:	89 d7                	mov    %edx,%edi
  800130:	89 d6                	mov    %edx,%esi
  800132:	cd 30                	int    $0x30
  800134:	89 c3                	mov    %eax,%ebx

envid_t
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	cprintf("lib/syscall.c: %x\n", ret);
  800136:	50                   	push   %eax
  800137:	68 f9 0d 80 00       	push   $0x800df9
  80013c:	e8 e3 00 00 00       	call   800224 <cprintf>
	return ret;
}
  800141:	89 d8                	mov    %ebx,%eax
  800143:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	56                   	push   %esi
  80014f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800150:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800153:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800159:	e8 b9 ff ff ff       	call   800117 <sys_getenvid>
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	ff 75 0c             	pushl  0xc(%ebp)
  800164:	ff 75 08             	pushl  0x8(%ebp)
  800167:	56                   	push   %esi
  800168:	50                   	push   %eax
  800169:	68 0c 0e 80 00       	push   $0x800e0c
  80016e:	e8 b1 00 00 00       	call   800224 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800173:	83 c4 18             	add    $0x18,%esp
  800176:	53                   	push   %ebx
  800177:	ff 75 10             	pushl  0x10(%ebp)
  80017a:	e8 54 00 00 00       	call   8001d3 <vcprintf>
	cprintf("\n");
  80017f:	c7 04 24 0a 0e 80 00 	movl   $0x800e0a,(%esp)
  800186:	e8 99 00 00 00       	call   800224 <cprintf>
  80018b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018e:	cc                   	int3   
  80018f:	eb fd                	jmp    80018e <_panic+0x43>

00800191 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	53                   	push   %ebx
  800195:	83 ec 04             	sub    $0x4,%esp
  800198:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019b:	8b 13                	mov    (%ebx),%edx
  80019d:	8d 42 01             	lea    0x1(%edx),%eax
  8001a0:	89 03                	mov    %eax,(%ebx)
  8001a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ae:	75 1a                	jne    8001ca <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b0:	83 ec 08             	sub    $0x8,%esp
  8001b3:	68 ff 00 00 00       	push   $0xff
  8001b8:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bb:	50                   	push   %eax
  8001bc:	e8 d8 fe ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8001c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001ca:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d1:	c9                   	leave  
  8001d2:	c3                   	ret    

008001d3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e3:	00 00 00 
	b.cnt = 0;
  8001e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f0:	ff 75 0c             	pushl  0xc(%ebp)
  8001f3:	ff 75 08             	pushl  0x8(%ebp)
  8001f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fc:	50                   	push   %eax
  8001fd:	68 91 01 80 00       	push   $0x800191
  800202:	e8 54 01 00 00       	call   80035b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800207:	83 c4 08             	add    $0x8,%esp
  80020a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800210:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800216:	50                   	push   %eax
  800217:	e8 7d fe ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  80021c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022d:	50                   	push   %eax
  80022e:	ff 75 08             	pushl  0x8(%ebp)
  800231:	e8 9d ff ff ff       	call   8001d3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 1c             	sub    $0x1c,%esp
  800241:	89 c7                	mov    %eax,%edi
  800243:	89 d6                	mov    %edx,%esi
  800245:	8b 45 08             	mov    0x8(%ebp),%eax
  800248:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800251:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800254:	bb 00 00 00 00       	mov    $0x0,%ebx
  800259:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025f:	39 d3                	cmp    %edx,%ebx
  800261:	72 05                	jb     800268 <printnum+0x30>
  800263:	39 45 10             	cmp    %eax,0x10(%ebp)
  800266:	77 45                	ja     8002ad <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800268:	83 ec 0c             	sub    $0xc,%esp
  80026b:	ff 75 18             	pushl  0x18(%ebp)
  80026e:	8b 45 14             	mov    0x14(%ebp),%eax
  800271:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800274:	53                   	push   %ebx
  800275:	ff 75 10             	pushl  0x10(%ebp)
  800278:	83 ec 08             	sub    $0x8,%esp
  80027b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027e:	ff 75 e0             	pushl  -0x20(%ebp)
  800281:	ff 75 dc             	pushl  -0x24(%ebp)
  800284:	ff 75 d8             	pushl  -0x28(%ebp)
  800287:	e8 b4 08 00 00       	call   800b40 <__udivdi3>
  80028c:	83 c4 18             	add    $0x18,%esp
  80028f:	52                   	push   %edx
  800290:	50                   	push   %eax
  800291:	89 f2                	mov    %esi,%edx
  800293:	89 f8                	mov    %edi,%eax
  800295:	e8 9e ff ff ff       	call   800238 <printnum>
  80029a:	83 c4 20             	add    $0x20,%esp
  80029d:	eb 18                	jmp    8002b7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	56                   	push   %esi
  8002a3:	ff 75 18             	pushl  0x18(%ebp)
  8002a6:	ff d7                	call   *%edi
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	eb 03                	jmp    8002b0 <printnum+0x78>
  8002ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b0:	83 eb 01             	sub    $0x1,%ebx
  8002b3:	85 db                	test   %ebx,%ebx
  8002b5:	7f e8                	jg     80029f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b7:	83 ec 08             	sub    $0x8,%esp
  8002ba:	56                   	push   %esi
  8002bb:	83 ec 04             	sub    $0x4,%esp
  8002be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c4:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c7:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ca:	e8 a1 09 00 00       	call   800c70 <__umoddi3>
  8002cf:	83 c4 14             	add    $0x14,%esp
  8002d2:	0f be 80 30 0e 80 00 	movsbl 0x800e30(%eax),%eax
  8002d9:	50                   	push   %eax
  8002da:	ff d7                	call   *%edi
}
  8002dc:	83 c4 10             	add    $0x10,%esp
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002ea:	83 fa 01             	cmp    $0x1,%edx
  8002ed:	7e 0e                	jle    8002fd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ef:	8b 10                	mov    (%eax),%edx
  8002f1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 02                	mov    (%edx),%eax
  8002f8:	8b 52 04             	mov    0x4(%edx),%edx
  8002fb:	eb 22                	jmp    80031f <getuint+0x38>
	else if (lflag)
  8002fd:	85 d2                	test   %edx,%edx
  8002ff:	74 10                	je     800311 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800301:	8b 10                	mov    (%eax),%edx
  800303:	8d 4a 04             	lea    0x4(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 02                	mov    (%edx),%eax
  80030a:	ba 00 00 00 00       	mov    $0x0,%edx
  80030f:	eb 0e                	jmp    80031f <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800311:	8b 10                	mov    (%eax),%edx
  800313:	8d 4a 04             	lea    0x4(%edx),%ecx
  800316:	89 08                	mov    %ecx,(%eax)
  800318:	8b 02                	mov    (%edx),%eax
  80031a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800327:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032b:	8b 10                	mov    (%eax),%edx
  80032d:	3b 50 04             	cmp    0x4(%eax),%edx
  800330:	73 0a                	jae    80033c <sprintputch+0x1b>
		*b->buf++ = ch;
  800332:	8d 4a 01             	lea    0x1(%edx),%ecx
  800335:	89 08                	mov    %ecx,(%eax)
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	88 02                	mov    %al,(%edx)
}
  80033c:	5d                   	pop    %ebp
  80033d:	c3                   	ret    

0080033e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800344:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800347:	50                   	push   %eax
  800348:	ff 75 10             	pushl  0x10(%ebp)
  80034b:	ff 75 0c             	pushl  0xc(%ebp)
  80034e:	ff 75 08             	pushl  0x8(%ebp)
  800351:	e8 05 00 00 00       	call   80035b <vprintfmt>
	va_end(ap);
}
  800356:	83 c4 10             	add    $0x10,%esp
  800359:	c9                   	leave  
  80035a:	c3                   	ret    

0080035b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
  800361:	83 ec 2c             	sub    $0x2c,%esp
  800364:	8b 75 08             	mov    0x8(%ebp),%esi
  800367:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80036a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80036d:	eb 1d                	jmp    80038c <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80036f:	85 c0                	test   %eax,%eax
  800371:	75 0f                	jne    800382 <vprintfmt+0x27>
				csa = 0x0700;
  800373:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  80037a:	07 00 00 
				return;
  80037d:	e9 c4 03 00 00       	jmp    800746 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	53                   	push   %ebx
  800386:	50                   	push   %eax
  800387:	ff d6                	call   *%esi
  800389:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038c:	83 c7 01             	add    $0x1,%edi
  80038f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800393:	83 f8 25             	cmp    $0x25,%eax
  800396:	75 d7                	jne    80036f <vprintfmt+0x14>
  800398:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80039c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003aa:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b6:	eb 07                	jmp    8003bf <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003bb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bf:	8d 47 01             	lea    0x1(%edi),%eax
  8003c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c5:	0f b6 07             	movzbl (%edi),%eax
  8003c8:	0f b6 c8             	movzbl %al,%ecx
  8003cb:	83 e8 23             	sub    $0x23,%eax
  8003ce:	3c 55                	cmp    $0x55,%al
  8003d0:	0f 87 55 03 00 00    	ja     80072b <vprintfmt+0x3d0>
  8003d6:	0f b6 c0             	movzbl %al,%eax
  8003d9:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e7:	eb d6                	jmp    8003bf <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003fb:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003fe:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800401:	83 fa 09             	cmp    $0x9,%edx
  800404:	77 39                	ja     80043f <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800406:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800409:	eb e9                	jmp    8003f4 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80040b:	8b 45 14             	mov    0x14(%ebp),%eax
  80040e:	8d 48 04             	lea    0x4(%eax),%ecx
  800411:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800414:	8b 00                	mov    (%eax),%eax
  800416:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800419:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80041c:	eb 27                	jmp    800445 <vprintfmt+0xea>
  80041e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800421:	85 c0                	test   %eax,%eax
  800423:	b9 00 00 00 00       	mov    $0x0,%ecx
  800428:	0f 49 c8             	cmovns %eax,%ecx
  80042b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800431:	eb 8c                	jmp    8003bf <vprintfmt+0x64>
  800433:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800436:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80043d:	eb 80                	jmp    8003bf <vprintfmt+0x64>
  80043f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800442:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800445:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800449:	0f 89 70 ff ff ff    	jns    8003bf <vprintfmt+0x64>
				width = precision, precision = -1;
  80044f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800452:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800455:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80045c:	e9 5e ff ff ff       	jmp    8003bf <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800461:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800467:	e9 53 ff ff ff       	jmp    8003bf <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80046c:	8b 45 14             	mov    0x14(%ebp),%eax
  80046f:	8d 50 04             	lea    0x4(%eax),%edx
  800472:	89 55 14             	mov    %edx,0x14(%ebp)
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	53                   	push   %ebx
  800479:	ff 30                	pushl  (%eax)
  80047b:	ff d6                	call   *%esi
			break;
  80047d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800480:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800483:	e9 04 ff ff ff       	jmp    80038c <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800488:	8b 45 14             	mov    0x14(%ebp),%eax
  80048b:	8d 50 04             	lea    0x4(%eax),%edx
  80048e:	89 55 14             	mov    %edx,0x14(%ebp)
  800491:	8b 00                	mov    (%eax),%eax
  800493:	99                   	cltd   
  800494:	31 d0                	xor    %edx,%eax
  800496:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800498:	83 f8 06             	cmp    $0x6,%eax
  80049b:	7f 0b                	jg     8004a8 <vprintfmt+0x14d>
  80049d:	8b 14 85 18 10 80 00 	mov    0x801018(,%eax,4),%edx
  8004a4:	85 d2                	test   %edx,%edx
  8004a6:	75 18                	jne    8004c0 <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8004a8:	50                   	push   %eax
  8004a9:	68 48 0e 80 00       	push   $0x800e48
  8004ae:	53                   	push   %ebx
  8004af:	56                   	push   %esi
  8004b0:	e8 89 fe ff ff       	call   80033e <printfmt>
  8004b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004bb:	e9 cc fe ff ff       	jmp    80038c <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8004c0:	52                   	push   %edx
  8004c1:	68 51 0e 80 00       	push   $0x800e51
  8004c6:	53                   	push   %ebx
  8004c7:	56                   	push   %esi
  8004c8:	e8 71 fe ff ff       	call   80033e <printfmt>
  8004cd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004d3:	e9 b4 fe ff ff       	jmp    80038c <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004db:	8d 50 04             	lea    0x4(%eax),%edx
  8004de:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004e3:	85 ff                	test   %edi,%edi
  8004e5:	b8 41 0e 80 00       	mov    $0x800e41,%eax
  8004ea:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004ed:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f1:	0f 8e 94 00 00 00    	jle    80058b <vprintfmt+0x230>
  8004f7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004fb:	0f 84 98 00 00 00    	je     800599 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	ff 75 d0             	pushl  -0x30(%ebp)
  800507:	57                   	push   %edi
  800508:	e8 c1 02 00 00       	call   8007ce <strnlen>
  80050d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800510:	29 c1                	sub    %eax,%ecx
  800512:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800515:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800518:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80051c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800522:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	eb 0f                	jmp    800535 <vprintfmt+0x1da>
					putch(padc, putdat);
  800526:	83 ec 08             	sub    $0x8,%esp
  800529:	53                   	push   %ebx
  80052a:	ff 75 e0             	pushl  -0x20(%ebp)
  80052d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	83 ef 01             	sub    $0x1,%edi
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	85 ff                	test   %edi,%edi
  800537:	7f ed                	jg     800526 <vprintfmt+0x1cb>
  800539:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80053c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80053f:	85 c9                	test   %ecx,%ecx
  800541:	b8 00 00 00 00       	mov    $0x0,%eax
  800546:	0f 49 c1             	cmovns %ecx,%eax
  800549:	29 c1                	sub    %eax,%ecx
  80054b:	89 75 08             	mov    %esi,0x8(%ebp)
  80054e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800551:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800554:	89 cb                	mov    %ecx,%ebx
  800556:	eb 4d                	jmp    8005a5 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800558:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80055c:	74 1b                	je     800579 <vprintfmt+0x21e>
  80055e:	0f be c0             	movsbl %al,%eax
  800561:	83 e8 20             	sub    $0x20,%eax
  800564:	83 f8 5e             	cmp    $0x5e,%eax
  800567:	76 10                	jbe    800579 <vprintfmt+0x21e>
					putch('?', putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	ff 75 0c             	pushl  0xc(%ebp)
  80056f:	6a 3f                	push   $0x3f
  800571:	ff 55 08             	call   *0x8(%ebp)
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	eb 0d                	jmp    800586 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	ff 75 0c             	pushl  0xc(%ebp)
  80057f:	52                   	push   %edx
  800580:	ff 55 08             	call   *0x8(%ebp)
  800583:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800586:	83 eb 01             	sub    $0x1,%ebx
  800589:	eb 1a                	jmp    8005a5 <vprintfmt+0x24a>
  80058b:	89 75 08             	mov    %esi,0x8(%ebp)
  80058e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800591:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800594:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800597:	eb 0c                	jmp    8005a5 <vprintfmt+0x24a>
  800599:	89 75 08             	mov    %esi,0x8(%ebp)
  80059c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a5:	83 c7 01             	add    $0x1,%edi
  8005a8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005ac:	0f be d0             	movsbl %al,%edx
  8005af:	85 d2                	test   %edx,%edx
  8005b1:	74 23                	je     8005d6 <vprintfmt+0x27b>
  8005b3:	85 f6                	test   %esi,%esi
  8005b5:	78 a1                	js     800558 <vprintfmt+0x1fd>
  8005b7:	83 ee 01             	sub    $0x1,%esi
  8005ba:	79 9c                	jns    800558 <vprintfmt+0x1fd>
  8005bc:	89 df                	mov    %ebx,%edi
  8005be:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c4:	eb 18                	jmp    8005de <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	53                   	push   %ebx
  8005ca:	6a 20                	push   $0x20
  8005cc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ce:	83 ef 01             	sub    $0x1,%edi
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	eb 08                	jmp    8005de <vprintfmt+0x283>
  8005d6:	89 df                	mov    %ebx,%edi
  8005d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8005db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005de:	85 ff                	test   %edi,%edi
  8005e0:	7f e4                	jg     8005c6 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e5:	e9 a2 fd ff ff       	jmp    80038c <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ea:	83 fa 01             	cmp    $0x1,%edx
  8005ed:	7e 16                	jle    800605 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 50 08             	lea    0x8(%eax),%edx
  8005f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f8:	8b 50 04             	mov    0x4(%eax),%edx
  8005fb:	8b 00                	mov    (%eax),%eax
  8005fd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800600:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800603:	eb 32                	jmp    800637 <vprintfmt+0x2dc>
	else if (lflag)
  800605:	85 d2                	test   %edx,%edx
  800607:	74 18                	je     800621 <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800609:	8b 45 14             	mov    0x14(%ebp),%eax
  80060c:	8d 50 04             	lea    0x4(%eax),%edx
  80060f:	89 55 14             	mov    %edx,0x14(%ebp)
  800612:	8b 00                	mov    (%eax),%eax
  800614:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800617:	89 c1                	mov    %eax,%ecx
  800619:	c1 f9 1f             	sar    $0x1f,%ecx
  80061c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80061f:	eb 16                	jmp    800637 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8d 50 04             	lea    0x4(%eax),%edx
  800627:	89 55 14             	mov    %edx,0x14(%ebp)
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062f:	89 c1                	mov    %eax,%ecx
  800631:	c1 f9 1f             	sar    $0x1f,%ecx
  800634:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800637:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800642:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800646:	79 74                	jns    8006bc <vprintfmt+0x361>
				putch('-', putdat);
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 2d                	push   $0x2d
  80064e:	ff d6                	call   *%esi
				num = -(long long) num;
  800650:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800653:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800656:	f7 d8                	neg    %eax
  800658:	83 d2 00             	adc    $0x0,%edx
  80065b:	f7 da                	neg    %edx
  80065d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800660:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800665:	eb 55                	jmp    8006bc <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800667:	8d 45 14             	lea    0x14(%ebp),%eax
  80066a:	e8 78 fc ff ff       	call   8002e7 <getuint>
			base = 10;
  80066f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800674:	eb 46                	jmp    8006bc <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800676:	8d 45 14             	lea    0x14(%ebp),%eax
  800679:	e8 69 fc ff ff       	call   8002e7 <getuint>
      base = 8;
  80067e:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  800683:	eb 37                	jmp    8006bc <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 30                	push   $0x30
  80068b:	ff d6                	call   *%esi
			putch('x', putdat);
  80068d:	83 c4 08             	add    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	6a 78                	push   $0x78
  800693:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8d 50 04             	lea    0x4(%eax),%edx
  80069b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069e:	8b 00                	mov    (%eax),%eax
  8006a0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006ad:	eb 0d                	jmp    8006bc <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006af:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b2:	e8 30 fc ff ff       	call   8002e7 <getuint>
			base = 16;
  8006b7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bc:	83 ec 0c             	sub    $0xc,%esp
  8006bf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c3:	57                   	push   %edi
  8006c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c7:	51                   	push   %ecx
  8006c8:	52                   	push   %edx
  8006c9:	50                   	push   %eax
  8006ca:	89 da                	mov    %ebx,%edx
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	e8 65 fb ff ff       	call   800238 <printnum>
			break;
  8006d3:	83 c4 20             	add    $0x20,%esp
  8006d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d9:	e9 ae fc ff ff       	jmp    80038c <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006de:	83 ec 08             	sub    $0x8,%esp
  8006e1:	53                   	push   %ebx
  8006e2:	51                   	push   %ecx
  8006e3:	ff d6                	call   *%esi
			break;
  8006e5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006eb:	e9 9c fc ff ff       	jmp    80038c <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f0:	83 fa 01             	cmp    $0x1,%edx
  8006f3:	7e 0d                	jle    800702 <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8006f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f8:	8d 50 08             	lea    0x8(%eax),%edx
  8006fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fe:	8b 00                	mov    (%eax),%eax
  800700:	eb 1c                	jmp    80071e <vprintfmt+0x3c3>
	else if (lflag)
  800702:	85 d2                	test   %edx,%edx
  800704:	74 0d                	je     800713 <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	eb 0b                	jmp    80071e <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8d 50 04             	lea    0x4(%eax),%edx
  800719:	89 55 14             	mov    %edx,0x14(%ebp)
  80071c:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  80071e:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800723:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  800726:	e9 61 fc ff ff       	jmp    80038c <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072b:	83 ec 08             	sub    $0x8,%esp
  80072e:	53                   	push   %ebx
  80072f:	6a 25                	push   $0x25
  800731:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	eb 03                	jmp    80073b <vprintfmt+0x3e0>
  800738:	83 ef 01             	sub    $0x1,%edi
  80073b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80073f:	75 f7                	jne    800738 <vprintfmt+0x3dd>
  800741:	e9 46 fc ff ff       	jmp    80038c <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800746:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800749:	5b                   	pop    %ebx
  80074a:	5e                   	pop    %esi
  80074b:	5f                   	pop    %edi
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	83 ec 18             	sub    $0x18,%esp
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
  800757:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80075d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800761:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800764:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076b:	85 c0                	test   %eax,%eax
  80076d:	74 26                	je     800795 <vsnprintf+0x47>
  80076f:	85 d2                	test   %edx,%edx
  800771:	7e 22                	jle    800795 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800773:	ff 75 14             	pushl  0x14(%ebp)
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077c:	50                   	push   %eax
  80077d:	68 21 03 80 00       	push   $0x800321
  800782:	e8 d4 fb ff ff       	call   80035b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800787:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80078d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	eb 05                	jmp    80079a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800795:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a5:	50                   	push   %eax
  8007a6:	ff 75 10             	pushl  0x10(%ebp)
  8007a9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ac:	ff 75 08             	pushl  0x8(%ebp)
  8007af:	e8 9a ff ff ff       	call   80074e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c1:	eb 03                	jmp    8007c6 <strlen+0x10>
		n++;
  8007c3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ca:	75 f7                	jne    8007c3 <strlen+0xd>
		n++;
	return n;
}
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8007dc:	eb 03                	jmp    8007e1 <strnlen+0x13>
		n++;
  8007de:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e1:	39 c2                	cmp    %eax,%edx
  8007e3:	74 08                	je     8007ed <strnlen+0x1f>
  8007e5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007e9:	75 f3                	jne    8007de <strnlen+0x10>
  8007eb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	53                   	push   %ebx
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f9:	89 c2                	mov    %eax,%edx
  8007fb:	83 c2 01             	add    $0x1,%edx
  8007fe:	83 c1 01             	add    $0x1,%ecx
  800801:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800805:	88 5a ff             	mov    %bl,-0x1(%edx)
  800808:	84 db                	test   %bl,%bl
  80080a:	75 ef                	jne    8007fb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080c:	5b                   	pop    %ebx
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	53                   	push   %ebx
  800813:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800816:	53                   	push   %ebx
  800817:	e8 9a ff ff ff       	call   8007b6 <strlen>
  80081c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081f:	ff 75 0c             	pushl  0xc(%ebp)
  800822:	01 d8                	add    %ebx,%eax
  800824:	50                   	push   %eax
  800825:	e8 c5 ff ff ff       	call   8007ef <strcpy>
	return dst;
}
  80082a:	89 d8                	mov    %ebx,%eax
  80082c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082f:	c9                   	leave  
  800830:	c3                   	ret    

00800831 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	56                   	push   %esi
  800835:	53                   	push   %ebx
  800836:	8b 75 08             	mov    0x8(%ebp),%esi
  800839:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083c:	89 f3                	mov    %esi,%ebx
  80083e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800841:	89 f2                	mov    %esi,%edx
  800843:	eb 0f                	jmp    800854 <strncpy+0x23>
		*dst++ = *src;
  800845:	83 c2 01             	add    $0x1,%edx
  800848:	0f b6 01             	movzbl (%ecx),%eax
  80084b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084e:	80 39 01             	cmpb   $0x1,(%ecx)
  800851:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800854:	39 da                	cmp    %ebx,%edx
  800856:	75 ed                	jne    800845 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800858:	89 f0                	mov    %esi,%eax
  80085a:	5b                   	pop    %ebx
  80085b:	5e                   	pop    %esi
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	56                   	push   %esi
  800862:	53                   	push   %ebx
  800863:	8b 75 08             	mov    0x8(%ebp),%esi
  800866:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800869:	8b 55 10             	mov    0x10(%ebp),%edx
  80086c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086e:	85 d2                	test   %edx,%edx
  800870:	74 21                	je     800893 <strlcpy+0x35>
  800872:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800876:	89 f2                	mov    %esi,%edx
  800878:	eb 09                	jmp    800883 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087a:	83 c2 01             	add    $0x1,%edx
  80087d:	83 c1 01             	add    $0x1,%ecx
  800880:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800883:	39 c2                	cmp    %eax,%edx
  800885:	74 09                	je     800890 <strlcpy+0x32>
  800887:	0f b6 19             	movzbl (%ecx),%ebx
  80088a:	84 db                	test   %bl,%bl
  80088c:	75 ec                	jne    80087a <strlcpy+0x1c>
  80088e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800890:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800893:	29 f0                	sub    %esi,%eax
}
  800895:	5b                   	pop    %ebx
  800896:	5e                   	pop    %esi
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a2:	eb 06                	jmp    8008aa <strcmp+0x11>
		p++, q++;
  8008a4:	83 c1 01             	add    $0x1,%ecx
  8008a7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008aa:	0f b6 01             	movzbl (%ecx),%eax
  8008ad:	84 c0                	test   %al,%al
  8008af:	74 04                	je     8008b5 <strcmp+0x1c>
  8008b1:	3a 02                	cmp    (%edx),%al
  8008b3:	74 ef                	je     8008a4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b5:	0f b6 c0             	movzbl %al,%eax
  8008b8:	0f b6 12             	movzbl (%edx),%edx
  8008bb:	29 d0                	sub    %edx,%eax
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	53                   	push   %ebx
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c9:	89 c3                	mov    %eax,%ebx
  8008cb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ce:	eb 06                	jmp    8008d6 <strncmp+0x17>
		n--, p++, q++;
  8008d0:	83 c0 01             	add    $0x1,%eax
  8008d3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d6:	39 d8                	cmp    %ebx,%eax
  8008d8:	74 15                	je     8008ef <strncmp+0x30>
  8008da:	0f b6 08             	movzbl (%eax),%ecx
  8008dd:	84 c9                	test   %cl,%cl
  8008df:	74 04                	je     8008e5 <strncmp+0x26>
  8008e1:	3a 0a                	cmp    (%edx),%cl
  8008e3:	74 eb                	je     8008d0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e5:	0f b6 00             	movzbl (%eax),%eax
  8008e8:	0f b6 12             	movzbl (%edx),%edx
  8008eb:	29 d0                	sub    %edx,%eax
  8008ed:	eb 05                	jmp    8008f4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f4:	5b                   	pop    %ebx
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800901:	eb 07                	jmp    80090a <strchr+0x13>
		if (*s == c)
  800903:	38 ca                	cmp    %cl,%dl
  800905:	74 0f                	je     800916 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800907:	83 c0 01             	add    $0x1,%eax
  80090a:	0f b6 10             	movzbl (%eax),%edx
  80090d:	84 d2                	test   %dl,%dl
  80090f:	75 f2                	jne    800903 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800911:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800922:	eb 03                	jmp    800927 <strfind+0xf>
  800924:	83 c0 01             	add    $0x1,%eax
  800927:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092a:	38 ca                	cmp    %cl,%dl
  80092c:	74 04                	je     800932 <strfind+0x1a>
  80092e:	84 d2                	test   %dl,%dl
  800930:	75 f2                	jne    800924 <strfind+0xc>
			break;
	return (char *) s;
}
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	57                   	push   %edi
  800938:	56                   	push   %esi
  800939:	53                   	push   %ebx
  80093a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800940:	85 c9                	test   %ecx,%ecx
  800942:	74 36                	je     80097a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800944:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094a:	75 28                	jne    800974 <memset+0x40>
  80094c:	f6 c1 03             	test   $0x3,%cl
  80094f:	75 23                	jne    800974 <memset+0x40>
		c &= 0xFF;
  800951:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800955:	89 d3                	mov    %edx,%ebx
  800957:	c1 e3 08             	shl    $0x8,%ebx
  80095a:	89 d6                	mov    %edx,%esi
  80095c:	c1 e6 18             	shl    $0x18,%esi
  80095f:	89 d0                	mov    %edx,%eax
  800961:	c1 e0 10             	shl    $0x10,%eax
  800964:	09 f0                	or     %esi,%eax
  800966:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800968:	89 d8                	mov    %ebx,%eax
  80096a:	09 d0                	or     %edx,%eax
  80096c:	c1 e9 02             	shr    $0x2,%ecx
  80096f:	fc                   	cld    
  800970:	f3 ab                	rep stos %eax,%es:(%edi)
  800972:	eb 06                	jmp    80097a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800974:	8b 45 0c             	mov    0xc(%ebp),%eax
  800977:	fc                   	cld    
  800978:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097a:	89 f8                	mov    %edi,%eax
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5f                   	pop    %edi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	57                   	push   %edi
  800985:	56                   	push   %esi
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098f:	39 c6                	cmp    %eax,%esi
  800991:	73 35                	jae    8009c8 <memmove+0x47>
  800993:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800996:	39 d0                	cmp    %edx,%eax
  800998:	73 2e                	jae    8009c8 <memmove+0x47>
		s += n;
		d += n;
  80099a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099d:	89 d6                	mov    %edx,%esi
  80099f:	09 fe                	or     %edi,%esi
  8009a1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a7:	75 13                	jne    8009bc <memmove+0x3b>
  8009a9:	f6 c1 03             	test   $0x3,%cl
  8009ac:	75 0e                	jne    8009bc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009ae:	83 ef 04             	sub    $0x4,%edi
  8009b1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b4:	c1 e9 02             	shr    $0x2,%ecx
  8009b7:	fd                   	std    
  8009b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ba:	eb 09                	jmp    8009c5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bc:	83 ef 01             	sub    $0x1,%edi
  8009bf:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c2:	fd                   	std    
  8009c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c5:	fc                   	cld    
  8009c6:	eb 1d                	jmp    8009e5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c8:	89 f2                	mov    %esi,%edx
  8009ca:	09 c2                	or     %eax,%edx
  8009cc:	f6 c2 03             	test   $0x3,%dl
  8009cf:	75 0f                	jne    8009e0 <memmove+0x5f>
  8009d1:	f6 c1 03             	test   $0x3,%cl
  8009d4:	75 0a                	jne    8009e0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d6:	c1 e9 02             	shr    $0x2,%ecx
  8009d9:	89 c7                	mov    %eax,%edi
  8009db:	fc                   	cld    
  8009dc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009de:	eb 05                	jmp    8009e5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e0:	89 c7                	mov    %eax,%edi
  8009e2:	fc                   	cld    
  8009e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e5:	5e                   	pop    %esi
  8009e6:	5f                   	pop    %edi
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ec:	ff 75 10             	pushl  0x10(%ebp)
  8009ef:	ff 75 0c             	pushl  0xc(%ebp)
  8009f2:	ff 75 08             	pushl  0x8(%ebp)
  8009f5:	e8 87 ff ff ff       	call   800981 <memmove>
}
  8009fa:	c9                   	leave  
  8009fb:	c3                   	ret    

008009fc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	56                   	push   %esi
  800a00:	53                   	push   %ebx
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a07:	89 c6                	mov    %eax,%esi
  800a09:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0c:	eb 1a                	jmp    800a28 <memcmp+0x2c>
		if (*s1 != *s2)
  800a0e:	0f b6 08             	movzbl (%eax),%ecx
  800a11:	0f b6 1a             	movzbl (%edx),%ebx
  800a14:	38 d9                	cmp    %bl,%cl
  800a16:	74 0a                	je     800a22 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a18:	0f b6 c1             	movzbl %cl,%eax
  800a1b:	0f b6 db             	movzbl %bl,%ebx
  800a1e:	29 d8                	sub    %ebx,%eax
  800a20:	eb 0f                	jmp    800a31 <memcmp+0x35>
		s1++, s2++;
  800a22:	83 c0 01             	add    $0x1,%eax
  800a25:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a28:	39 f0                	cmp    %esi,%eax
  800a2a:	75 e2                	jne    800a0e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	53                   	push   %ebx
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3c:	89 c1                	mov    %eax,%ecx
  800a3e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a41:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a45:	eb 0a                	jmp    800a51 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a47:	0f b6 10             	movzbl (%eax),%edx
  800a4a:	39 da                	cmp    %ebx,%edx
  800a4c:	74 07                	je     800a55 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4e:	83 c0 01             	add    $0x1,%eax
  800a51:	39 c8                	cmp    %ecx,%eax
  800a53:	72 f2                	jb     800a47 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a55:	5b                   	pop    %ebx
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a64:	eb 03                	jmp    800a69 <strtol+0x11>
		s++;
  800a66:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a69:	0f b6 01             	movzbl (%ecx),%eax
  800a6c:	3c 20                	cmp    $0x20,%al
  800a6e:	74 f6                	je     800a66 <strtol+0xe>
  800a70:	3c 09                	cmp    $0x9,%al
  800a72:	74 f2                	je     800a66 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a74:	3c 2b                	cmp    $0x2b,%al
  800a76:	75 0a                	jne    800a82 <strtol+0x2a>
		s++;
  800a78:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a80:	eb 11                	jmp    800a93 <strtol+0x3b>
  800a82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a87:	3c 2d                	cmp    $0x2d,%al
  800a89:	75 08                	jne    800a93 <strtol+0x3b>
		s++, neg = 1;
  800a8b:	83 c1 01             	add    $0x1,%ecx
  800a8e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a93:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a99:	75 15                	jne    800ab0 <strtol+0x58>
  800a9b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9e:	75 10                	jne    800ab0 <strtol+0x58>
  800aa0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa4:	75 7c                	jne    800b22 <strtol+0xca>
		s += 2, base = 16;
  800aa6:	83 c1 02             	add    $0x2,%ecx
  800aa9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aae:	eb 16                	jmp    800ac6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab0:	85 db                	test   %ebx,%ebx
  800ab2:	75 12                	jne    800ac6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab9:	80 39 30             	cmpb   $0x30,(%ecx)
  800abc:	75 08                	jne    800ac6 <strtol+0x6e>
		s++, base = 8;
  800abe:	83 c1 01             	add    $0x1,%ecx
  800ac1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac6:	b8 00 00 00 00       	mov    $0x0,%eax
  800acb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ace:	0f b6 11             	movzbl (%ecx),%edx
  800ad1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad4:	89 f3                	mov    %esi,%ebx
  800ad6:	80 fb 09             	cmp    $0x9,%bl
  800ad9:	77 08                	ja     800ae3 <strtol+0x8b>
			dig = *s - '0';
  800adb:	0f be d2             	movsbl %dl,%edx
  800ade:	83 ea 30             	sub    $0x30,%edx
  800ae1:	eb 22                	jmp    800b05 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae6:	89 f3                	mov    %esi,%ebx
  800ae8:	80 fb 19             	cmp    $0x19,%bl
  800aeb:	77 08                	ja     800af5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aed:	0f be d2             	movsbl %dl,%edx
  800af0:	83 ea 57             	sub    $0x57,%edx
  800af3:	eb 10                	jmp    800b05 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af8:	89 f3                	mov    %esi,%ebx
  800afa:	80 fb 19             	cmp    $0x19,%bl
  800afd:	77 16                	ja     800b15 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aff:	0f be d2             	movsbl %dl,%edx
  800b02:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b05:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b08:	7d 0b                	jge    800b15 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0a:	83 c1 01             	add    $0x1,%ecx
  800b0d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b11:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b13:	eb b9                	jmp    800ace <strtol+0x76>

	if (endptr)
  800b15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b19:	74 0d                	je     800b28 <strtol+0xd0>
		*endptr = (char *) s;
  800b1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1e:	89 0e                	mov    %ecx,(%esi)
  800b20:	eb 06                	jmp    800b28 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b22:	85 db                	test   %ebx,%ebx
  800b24:	74 98                	je     800abe <strtol+0x66>
  800b26:	eb 9e                	jmp    800ac6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b28:	89 c2                	mov    %eax,%edx
  800b2a:	f7 da                	neg    %edx
  800b2c:	85 ff                	test   %edi,%edi
  800b2e:	0f 45 c2             	cmovne %edx,%eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5e                   	pop    %esi
  800b33:	5f                   	pop    %edi
  800b34:	5d                   	pop    %ebp
  800b35:	c3                   	ret    
  800b36:	66 90                	xchg   %ax,%ax
  800b38:	66 90                	xchg   %ax,%ax
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
