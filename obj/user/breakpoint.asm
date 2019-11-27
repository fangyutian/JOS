
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800044:	e8 c9 00 00 00       	call   800112 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800051:	c1 e0 05             	shl    $0x5,%eax
  800054:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800059:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	85 db                	test   %ebx,%ebx
  800060:	7e 07                	jle    800069 <libmain+0x30>
		binaryname = argv[0];
  800062:	8b 06                	mov    (%esi),%eax
  800064:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800069:	83 ec 08             	sub    $0x8,%esp
  80006c:	56                   	push   %esi
  80006d:	53                   	push   %ebx
  80006e:	e8 c0 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800073:	e8 0a 00 00 00       	call   800082 <exit>
}
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007e:	5b                   	pop    %ebx
  80007f:	5e                   	pop    %esi
  800080:	5d                   	pop    %ebp
  800081:	c3                   	ret    

00800082 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800088:	6a 00                	push   $0x0
  80008a:	e8 42 00 00 00       	call   8000d1 <sys_env_destroy>
}
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	57                   	push   %edi
  800098:	56                   	push   %esi
  800099:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009a:	b8 00 00 00 00       	mov    $0x0,%eax
  80009f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a5:	89 c3                	mov    %eax,%ebx
  8000a7:	89 c7                	mov    %eax,%edi
  8000a9:	89 c6                	mov    %eax,%esi
  8000ab:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ad:	5b                   	pop    %ebx
  8000ae:	5e                   	pop    %esi
  8000af:	5f                   	pop    %edi
  8000b0:	5d                   	pop    %ebp
  8000b1:	c3                   	ret    

008000b2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	57                   	push   %edi
  8000b6:	56                   	push   %esi
  8000b7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c2:	89 d1                	mov    %edx,%ecx
  8000c4:	89 d3                	mov    %edx,%ebx
  8000c6:	89 d7                	mov    %edx,%edi
  8000c8:	89 d6                	mov    %edx,%esi
  8000ca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5f                   	pop    %edi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	57                   	push   %edi
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000df:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e7:	89 cb                	mov    %ecx,%ebx
  8000e9:	89 cf                	mov    %ecx,%edi
  8000eb:	89 ce                	mov    %ecx,%esi
  8000ed:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000ef:	85 c0                	test   %eax,%eax
  8000f1:	7e 17                	jle    80010a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f3:	83 ec 0c             	sub    $0xc,%esp
  8000f6:	50                   	push   %eax
  8000f7:	6a 03                	push   $0x3
  8000f9:	68 ce 0d 80 00       	push   $0x800dce
  8000fe:	6a 23                	push   $0x23
  800100:	68 eb 0d 80 00       	push   $0x800deb
  800105:	e8 3c 00 00 00       	call   800146 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010d:	5b                   	pop    %ebx
  80010e:	5e                   	pop    %esi
  80010f:	5f                   	pop    %edi
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    

00800112 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800112:	55                   	push   %ebp
  800113:	89 e5                	mov    %esp,%ebp
  800115:	57                   	push   %edi
  800116:	56                   	push   %esi
  800117:	53                   	push   %ebx
  800118:	83 ec 14             	sub    $0x14,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011b:	ba 00 00 00 00       	mov    $0x0,%edx
  800120:	b8 02 00 00 00       	mov    $0x2,%eax
  800125:	89 d1                	mov    %edx,%ecx
  800127:	89 d3                	mov    %edx,%ebx
  800129:	89 d7                	mov    %edx,%edi
  80012b:	89 d6                	mov    %edx,%esi
  80012d:	cd 30                	int    $0x30
  80012f:	89 c3                	mov    %eax,%ebx

envid_t
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	cprintf("lib/syscall.c: %x\n", ret);
  800131:	50                   	push   %eax
  800132:	68 f9 0d 80 00       	push   $0x800df9
  800137:	e8 e3 00 00 00       	call   80021f <cprintf>
	return ret;
}
  80013c:	89 d8                	mov    %ebx,%eax
  80013e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800141:	5b                   	pop    %ebx
  800142:	5e                   	pop    %esi
  800143:	5f                   	pop    %edi
  800144:	5d                   	pop    %ebp
  800145:	c3                   	ret    

00800146 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	56                   	push   %esi
  80014a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014e:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800154:	e8 b9 ff ff ff       	call   800112 <sys_getenvid>
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	ff 75 0c             	pushl  0xc(%ebp)
  80015f:	ff 75 08             	pushl  0x8(%ebp)
  800162:	56                   	push   %esi
  800163:	50                   	push   %eax
  800164:	68 0c 0e 80 00       	push   $0x800e0c
  800169:	e8 b1 00 00 00       	call   80021f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016e:	83 c4 18             	add    $0x18,%esp
  800171:	53                   	push   %ebx
  800172:	ff 75 10             	pushl  0x10(%ebp)
  800175:	e8 54 00 00 00       	call   8001ce <vcprintf>
	cprintf("\n");
  80017a:	c7 04 24 0a 0e 80 00 	movl   $0x800e0a,(%esp)
  800181:	e8 99 00 00 00       	call   80021f <cprintf>
  800186:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800189:	cc                   	int3   
  80018a:	eb fd                	jmp    800189 <_panic+0x43>

0080018c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	53                   	push   %ebx
  800190:	83 ec 04             	sub    $0x4,%esp
  800193:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800196:	8b 13                	mov    (%ebx),%edx
  800198:	8d 42 01             	lea    0x1(%edx),%eax
  80019b:	89 03                	mov    %eax,(%ebx)
  80019d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a9:	75 1a                	jne    8001c5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001ab:	83 ec 08             	sub    $0x8,%esp
  8001ae:	68 ff 00 00 00       	push   $0xff
  8001b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b6:	50                   	push   %eax
  8001b7:	e8 d8 fe ff ff       	call   800094 <sys_cputs>
		b->idx = 0;
  8001bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cc:	c9                   	leave  
  8001cd:	c3                   	ret    

008001ce <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001de:	00 00 00 
	b.cnt = 0;
  8001e1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001eb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ee:	ff 75 08             	pushl  0x8(%ebp)
  8001f1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f7:	50                   	push   %eax
  8001f8:	68 8c 01 80 00       	push   $0x80018c
  8001fd:	e8 54 01 00 00       	call   800356 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800202:	83 c4 08             	add    $0x8,%esp
  800205:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800211:	50                   	push   %eax
  800212:	e8 7d fe ff ff       	call   800094 <sys_cputs>

	return b.cnt;
}
  800217:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021d:	c9                   	leave  
  80021e:	c3                   	ret    

0080021f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800225:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800228:	50                   	push   %eax
  800229:	ff 75 08             	pushl  0x8(%ebp)
  80022c:	e8 9d ff ff ff       	call   8001ce <vcprintf>
	va_end(ap);

	return cnt;
}
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	57                   	push   %edi
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	83 ec 1c             	sub    $0x1c,%esp
  80023c:	89 c7                	mov    %eax,%edi
  80023e:	89 d6                	mov    %edx,%esi
  800240:	8b 45 08             	mov    0x8(%ebp),%eax
  800243:	8b 55 0c             	mov    0xc(%ebp),%edx
  800246:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800249:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800254:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800257:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025a:	39 d3                	cmp    %edx,%ebx
  80025c:	72 05                	jb     800263 <printnum+0x30>
  80025e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800261:	77 45                	ja     8002a8 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800263:	83 ec 0c             	sub    $0xc,%esp
  800266:	ff 75 18             	pushl  0x18(%ebp)
  800269:	8b 45 14             	mov    0x14(%ebp),%eax
  80026c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	83 ec 08             	sub    $0x8,%esp
  800276:	ff 75 e4             	pushl  -0x1c(%ebp)
  800279:	ff 75 e0             	pushl  -0x20(%ebp)
  80027c:	ff 75 dc             	pushl  -0x24(%ebp)
  80027f:	ff 75 d8             	pushl  -0x28(%ebp)
  800282:	e8 b9 08 00 00       	call   800b40 <__udivdi3>
  800287:	83 c4 18             	add    $0x18,%esp
  80028a:	52                   	push   %edx
  80028b:	50                   	push   %eax
  80028c:	89 f2                	mov    %esi,%edx
  80028e:	89 f8                	mov    %edi,%eax
  800290:	e8 9e ff ff ff       	call   800233 <printnum>
  800295:	83 c4 20             	add    $0x20,%esp
  800298:	eb 18                	jmp    8002b2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	56                   	push   %esi
  80029e:	ff 75 18             	pushl  0x18(%ebp)
  8002a1:	ff d7                	call   *%edi
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	eb 03                	jmp    8002ab <printnum+0x78>
  8002a8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ab:	83 eb 01             	sub    $0x1,%ebx
  8002ae:	85 db                	test   %ebx,%ebx
  8002b0:	7f e8                	jg     80029a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b2:	83 ec 08             	sub    $0x8,%esp
  8002b5:	56                   	push   %esi
  8002b6:	83 ec 04             	sub    $0x4,%esp
  8002b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8002bf:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c5:	e8 a6 09 00 00       	call   800c70 <__umoddi3>
  8002ca:	83 c4 14             	add    $0x14,%esp
  8002cd:	0f be 80 30 0e 80 00 	movsbl 0x800e30(%eax),%eax
  8002d4:	50                   	push   %eax
  8002d5:	ff d7                	call   *%edi
}
  8002d7:	83 c4 10             	add    $0x10,%esp
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e5:	83 fa 01             	cmp    $0x1,%edx
  8002e8:	7e 0e                	jle    8002f8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ea:	8b 10                	mov    (%eax),%edx
  8002ec:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ef:	89 08                	mov    %ecx,(%eax)
  8002f1:	8b 02                	mov    (%edx),%eax
  8002f3:	8b 52 04             	mov    0x4(%edx),%edx
  8002f6:	eb 22                	jmp    80031a <getuint+0x38>
	else if (lflag)
  8002f8:	85 d2                	test   %edx,%edx
  8002fa:	74 10                	je     80030c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800301:	89 08                	mov    %ecx,(%eax)
  800303:	8b 02                	mov    (%edx),%eax
  800305:	ba 00 00 00 00       	mov    $0x0,%edx
  80030a:	eb 0e                	jmp    80031a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030c:	8b 10                	mov    (%eax),%edx
  80030e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800311:	89 08                	mov    %ecx,(%eax)
  800313:	8b 02                	mov    (%edx),%eax
  800315:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800322:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800326:	8b 10                	mov    (%eax),%edx
  800328:	3b 50 04             	cmp    0x4(%eax),%edx
  80032b:	73 0a                	jae    800337 <sprintputch+0x1b>
		*b->buf++ = ch;
  80032d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800330:	89 08                	mov    %ecx,(%eax)
  800332:	8b 45 08             	mov    0x8(%ebp),%eax
  800335:	88 02                	mov    %al,(%edx)
}
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80033f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800342:	50                   	push   %eax
  800343:	ff 75 10             	pushl  0x10(%ebp)
  800346:	ff 75 0c             	pushl  0xc(%ebp)
  800349:	ff 75 08             	pushl  0x8(%ebp)
  80034c:	e8 05 00 00 00       	call   800356 <vprintfmt>
	va_end(ap);
}
  800351:	83 c4 10             	add    $0x10,%esp
  800354:	c9                   	leave  
  800355:	c3                   	ret    

00800356 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	57                   	push   %edi
  80035a:	56                   	push   %esi
  80035b:	53                   	push   %ebx
  80035c:	83 ec 2c             	sub    $0x2c,%esp
  80035f:	8b 75 08             	mov    0x8(%ebp),%esi
  800362:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800365:	8b 7d 10             	mov    0x10(%ebp),%edi
  800368:	eb 1d                	jmp    800387 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80036a:	85 c0                	test   %eax,%eax
  80036c:	75 0f                	jne    80037d <vprintfmt+0x27>
				csa = 0x0700;
  80036e:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  800375:	07 00 00 
				return;
  800378:	e9 c4 03 00 00       	jmp    800741 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  80037d:	83 ec 08             	sub    $0x8,%esp
  800380:	53                   	push   %ebx
  800381:	50                   	push   %eax
  800382:	ff d6                	call   *%esi
  800384:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800387:	83 c7 01             	add    $0x1,%edi
  80038a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038e:	83 f8 25             	cmp    $0x25,%eax
  800391:	75 d7                	jne    80036a <vprintfmt+0x14>
  800393:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800397:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b1:	eb 07                	jmp    8003ba <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8d 47 01             	lea    0x1(%edi),%eax
  8003bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c0:	0f b6 07             	movzbl (%edi),%eax
  8003c3:	0f b6 c8             	movzbl %al,%ecx
  8003c6:	83 e8 23             	sub    $0x23,%eax
  8003c9:	3c 55                	cmp    $0x55,%al
  8003cb:	0f 87 55 03 00 00    	ja     800726 <vprintfmt+0x3d0>
  8003d1:	0f b6 c0             	movzbl %al,%eax
  8003d4:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003de:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e2:	eb d6                	jmp    8003ba <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003ef:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003f9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003fc:	83 fa 09             	cmp    $0x9,%edx
  8003ff:	77 39                	ja     80043a <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800401:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800404:	eb e9                	jmp    8003ef <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	8d 48 04             	lea    0x4(%eax),%ecx
  80040c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80040f:	8b 00                	mov    (%eax),%eax
  800411:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800414:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800417:	eb 27                	jmp    800440 <vprintfmt+0xea>
  800419:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80041c:	85 c0                	test   %eax,%eax
  80041e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800423:	0f 49 c8             	cmovns %eax,%ecx
  800426:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042c:	eb 8c                	jmp    8003ba <vprintfmt+0x64>
  80042e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800431:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800438:	eb 80                	jmp    8003ba <vprintfmt+0x64>
  80043a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80043d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800440:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800444:	0f 89 70 ff ff ff    	jns    8003ba <vprintfmt+0x64>
				width = precision, precision = -1;
  80044a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80044d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800450:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800457:	e9 5e ff ff ff       	jmp    8003ba <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800462:	e9 53 ff ff ff       	jmp    8003ba <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8d 50 04             	lea    0x4(%eax),%edx
  80046d:	89 55 14             	mov    %edx,0x14(%ebp)
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	ff 30                	pushl  (%eax)
  800476:	ff d6                	call   *%esi
			break;
  800478:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047e:	e9 04 ff ff ff       	jmp    800387 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800483:	8b 45 14             	mov    0x14(%ebp),%eax
  800486:	8d 50 04             	lea    0x4(%eax),%edx
  800489:	89 55 14             	mov    %edx,0x14(%ebp)
  80048c:	8b 00                	mov    (%eax),%eax
  80048e:	99                   	cltd   
  80048f:	31 d0                	xor    %edx,%eax
  800491:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800493:	83 f8 06             	cmp    $0x6,%eax
  800496:	7f 0b                	jg     8004a3 <vprintfmt+0x14d>
  800498:	8b 14 85 18 10 80 00 	mov    0x801018(,%eax,4),%edx
  80049f:	85 d2                	test   %edx,%edx
  8004a1:	75 18                	jne    8004bb <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8004a3:	50                   	push   %eax
  8004a4:	68 48 0e 80 00       	push   $0x800e48
  8004a9:	53                   	push   %ebx
  8004aa:	56                   	push   %esi
  8004ab:	e8 89 fe ff ff       	call   800339 <printfmt>
  8004b0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b6:	e9 cc fe ff ff       	jmp    800387 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8004bb:	52                   	push   %edx
  8004bc:	68 51 0e 80 00       	push   $0x800e51
  8004c1:	53                   	push   %ebx
  8004c2:	56                   	push   %esi
  8004c3:	e8 71 fe ff ff       	call   800339 <printfmt>
  8004c8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ce:	e9 b4 fe ff ff       	jmp    800387 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d6:	8d 50 04             	lea    0x4(%eax),%edx
  8004d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004de:	85 ff                	test   %edi,%edi
  8004e0:	b8 41 0e 80 00       	mov    $0x800e41,%eax
  8004e5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ec:	0f 8e 94 00 00 00    	jle    800586 <vprintfmt+0x230>
  8004f2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f6:	0f 84 98 00 00 00    	je     800594 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	ff 75 d0             	pushl  -0x30(%ebp)
  800502:	57                   	push   %edi
  800503:	e8 c1 02 00 00       	call   8007c9 <strnlen>
  800508:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050b:	29 c1                	sub    %eax,%ecx
  80050d:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800510:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800513:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800517:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051f:	eb 0f                	jmp    800530 <vprintfmt+0x1da>
					putch(padc, putdat);
  800521:	83 ec 08             	sub    $0x8,%esp
  800524:	53                   	push   %ebx
  800525:	ff 75 e0             	pushl  -0x20(%ebp)
  800528:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052a:	83 ef 01             	sub    $0x1,%edi
  80052d:	83 c4 10             	add    $0x10,%esp
  800530:	85 ff                	test   %edi,%edi
  800532:	7f ed                	jg     800521 <vprintfmt+0x1cb>
  800534:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800537:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80053a:	85 c9                	test   %ecx,%ecx
  80053c:	b8 00 00 00 00       	mov    $0x0,%eax
  800541:	0f 49 c1             	cmovns %ecx,%eax
  800544:	29 c1                	sub    %eax,%ecx
  800546:	89 75 08             	mov    %esi,0x8(%ebp)
  800549:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80054f:	89 cb                	mov    %ecx,%ebx
  800551:	eb 4d                	jmp    8005a0 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800553:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800557:	74 1b                	je     800574 <vprintfmt+0x21e>
  800559:	0f be c0             	movsbl %al,%eax
  80055c:	83 e8 20             	sub    $0x20,%eax
  80055f:	83 f8 5e             	cmp    $0x5e,%eax
  800562:	76 10                	jbe    800574 <vprintfmt+0x21e>
					putch('?', putdat);
  800564:	83 ec 08             	sub    $0x8,%esp
  800567:	ff 75 0c             	pushl  0xc(%ebp)
  80056a:	6a 3f                	push   $0x3f
  80056c:	ff 55 08             	call   *0x8(%ebp)
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	eb 0d                	jmp    800581 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800574:	83 ec 08             	sub    $0x8,%esp
  800577:	ff 75 0c             	pushl  0xc(%ebp)
  80057a:	52                   	push   %edx
  80057b:	ff 55 08             	call   *0x8(%ebp)
  80057e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800581:	83 eb 01             	sub    $0x1,%ebx
  800584:	eb 1a                	jmp    8005a0 <vprintfmt+0x24a>
  800586:	89 75 08             	mov    %esi,0x8(%ebp)
  800589:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80058f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800592:	eb 0c                	jmp    8005a0 <vprintfmt+0x24a>
  800594:	89 75 08             	mov    %esi,0x8(%ebp)
  800597:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a0:	83 c7 01             	add    $0x1,%edi
  8005a3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a7:	0f be d0             	movsbl %al,%edx
  8005aa:	85 d2                	test   %edx,%edx
  8005ac:	74 23                	je     8005d1 <vprintfmt+0x27b>
  8005ae:	85 f6                	test   %esi,%esi
  8005b0:	78 a1                	js     800553 <vprintfmt+0x1fd>
  8005b2:	83 ee 01             	sub    $0x1,%esi
  8005b5:	79 9c                	jns    800553 <vprintfmt+0x1fd>
  8005b7:	89 df                	mov    %ebx,%edi
  8005b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005bf:	eb 18                	jmp    8005d9 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	6a 20                	push   $0x20
  8005c7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005c9:	83 ef 01             	sub    $0x1,%edi
  8005cc:	83 c4 10             	add    $0x10,%esp
  8005cf:	eb 08                	jmp    8005d9 <vprintfmt+0x283>
  8005d1:	89 df                	mov    %ebx,%edi
  8005d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005d9:	85 ff                	test   %edi,%edi
  8005db:	7f e4                	jg     8005c1 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e0:	e9 a2 fd ff ff       	jmp    800387 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e5:	83 fa 01             	cmp    $0x1,%edx
  8005e8:	7e 16                	jle    800600 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8005ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ed:	8d 50 08             	lea    0x8(%eax),%edx
  8005f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f3:	8b 50 04             	mov    0x4(%eax),%edx
  8005f6:	8b 00                	mov    (%eax),%eax
  8005f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fe:	eb 32                	jmp    800632 <vprintfmt+0x2dc>
	else if (lflag)
  800600:	85 d2                	test   %edx,%edx
  800602:	74 18                	je     80061c <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800612:	89 c1                	mov    %eax,%ecx
  800614:	c1 f9 1f             	sar    $0x1f,%ecx
  800617:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80061a:	eb 16                	jmp    800632 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 00                	mov    (%eax),%eax
  800627:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062a:	89 c1                	mov    %eax,%ecx
  80062c:	c1 f9 1f             	sar    $0x1f,%ecx
  80062f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800632:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800635:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800638:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800641:	79 74                	jns    8006b7 <vprintfmt+0x361>
				putch('-', putdat);
  800643:	83 ec 08             	sub    $0x8,%esp
  800646:	53                   	push   %ebx
  800647:	6a 2d                	push   $0x2d
  800649:	ff d6                	call   *%esi
				num = -(long long) num;
  80064b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800651:	f7 d8                	neg    %eax
  800653:	83 d2 00             	adc    $0x0,%edx
  800656:	f7 da                	neg    %edx
  800658:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80065b:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800660:	eb 55                	jmp    8006b7 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800662:	8d 45 14             	lea    0x14(%ebp),%eax
  800665:	e8 78 fc ff ff       	call   8002e2 <getuint>
			base = 10;
  80066a:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80066f:	eb 46                	jmp    8006b7 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800671:	8d 45 14             	lea    0x14(%ebp),%eax
  800674:	e8 69 fc ff ff       	call   8002e2 <getuint>
      base = 8;
  800679:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80067e:	eb 37                	jmp    8006b7 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 30                	push   $0x30
  800686:	ff d6                	call   *%esi
			putch('x', putdat);
  800688:	83 c4 08             	add    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 78                	push   $0x78
  80068e:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 50 04             	lea    0x4(%eax),%edx
  800696:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800699:	8b 00                	mov    (%eax),%eax
  80069b:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a3:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a8:	eb 0d                	jmp    8006b7 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ad:	e8 30 fc ff ff       	call   8002e2 <getuint>
			base = 16;
  8006b2:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b7:	83 ec 0c             	sub    $0xc,%esp
  8006ba:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006be:	57                   	push   %edi
  8006bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c2:	51                   	push   %ecx
  8006c3:	52                   	push   %edx
  8006c4:	50                   	push   %eax
  8006c5:	89 da                	mov    %ebx,%edx
  8006c7:	89 f0                	mov    %esi,%eax
  8006c9:	e8 65 fb ff ff       	call   800233 <printnum>
			break;
  8006ce:	83 c4 20             	add    $0x20,%esp
  8006d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d4:	e9 ae fc ff ff       	jmp    800387 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	53                   	push   %ebx
  8006dd:	51                   	push   %ecx
  8006de:	ff d6                	call   *%esi
			break;
  8006e0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e6:	e9 9c fc ff ff       	jmp    800387 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006eb:	83 fa 01             	cmp    $0x1,%edx
  8006ee:	7e 0d                	jle    8006fd <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8006f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f3:	8d 50 08             	lea    0x8(%eax),%edx
  8006f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f9:	8b 00                	mov    (%eax),%eax
  8006fb:	eb 1c                	jmp    800719 <vprintfmt+0x3c3>
	else if (lflag)
  8006fd:	85 d2                	test   %edx,%edx
  8006ff:	74 0d                	je     80070e <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	eb 0b                	jmp    800719 <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  80070e:	8b 45 14             	mov    0x14(%ebp),%eax
  800711:	8d 50 04             	lea    0x4(%eax),%edx
  800714:	89 55 14             	mov    %edx,0x14(%ebp)
  800717:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  800719:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  800721:	e9 61 fc ff ff       	jmp    800387 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	53                   	push   %ebx
  80072a:	6a 25                	push   $0x25
  80072c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072e:	83 c4 10             	add    $0x10,%esp
  800731:	eb 03                	jmp    800736 <vprintfmt+0x3e0>
  800733:	83 ef 01             	sub    $0x1,%edi
  800736:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80073a:	75 f7                	jne    800733 <vprintfmt+0x3dd>
  80073c:	e9 46 fc ff ff       	jmp    800387 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800741:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800744:	5b                   	pop    %ebx
  800745:	5e                   	pop    %esi
  800746:	5f                   	pop    %edi
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	83 ec 18             	sub    $0x18,%esp
  80074f:	8b 45 08             	mov    0x8(%ebp),%eax
  800752:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800755:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800758:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800766:	85 c0                	test   %eax,%eax
  800768:	74 26                	je     800790 <vsnprintf+0x47>
  80076a:	85 d2                	test   %edx,%edx
  80076c:	7e 22                	jle    800790 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076e:	ff 75 14             	pushl  0x14(%ebp)
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800777:	50                   	push   %eax
  800778:	68 1c 03 80 00       	push   $0x80031c
  80077d:	e8 d4 fb ff ff       	call   800356 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800782:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800785:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800788:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078b:	83 c4 10             	add    $0x10,%esp
  80078e:	eb 05                	jmp    800795 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800790:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a0:	50                   	push   %eax
  8007a1:	ff 75 10             	pushl  0x10(%ebp)
  8007a4:	ff 75 0c             	pushl  0xc(%ebp)
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 9a ff ff ff       	call   800749 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bc:	eb 03                	jmp    8007c1 <strlen+0x10>
		n++;
  8007be:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c5:	75 f7                	jne    8007be <strlen+0xd>
		n++;
	return n;
}
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d7:	eb 03                	jmp    8007dc <strnlen+0x13>
		n++;
  8007d9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dc:	39 c2                	cmp    %eax,%edx
  8007de:	74 08                	je     8007e8 <strnlen+0x1f>
  8007e0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007e4:	75 f3                	jne    8007d9 <strnlen+0x10>
  8007e6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	53                   	push   %ebx
  8007ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	83 c2 01             	add    $0x1,%edx
  8007f9:	83 c1 01             	add    $0x1,%ecx
  8007fc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800800:	88 5a ff             	mov    %bl,-0x1(%edx)
  800803:	84 db                	test   %bl,%bl
  800805:	75 ef                	jne    8007f6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800807:	5b                   	pop    %ebx
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	53                   	push   %ebx
  80080e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800811:	53                   	push   %ebx
  800812:	e8 9a ff ff ff       	call   8007b1 <strlen>
  800817:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081a:	ff 75 0c             	pushl  0xc(%ebp)
  80081d:	01 d8                	add    %ebx,%eax
  80081f:	50                   	push   %eax
  800820:	e8 c5 ff ff ff       	call   8007ea <strcpy>
	return dst;
}
  800825:	89 d8                	mov    %ebx,%eax
  800827:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	56                   	push   %esi
  800830:	53                   	push   %ebx
  800831:	8b 75 08             	mov    0x8(%ebp),%esi
  800834:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800837:	89 f3                	mov    %esi,%ebx
  800839:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083c:	89 f2                	mov    %esi,%edx
  80083e:	eb 0f                	jmp    80084f <strncpy+0x23>
		*dst++ = *src;
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	0f b6 01             	movzbl (%ecx),%eax
  800846:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800849:	80 39 01             	cmpb   $0x1,(%ecx)
  80084c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084f:	39 da                	cmp    %ebx,%edx
  800851:	75 ed                	jne    800840 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800853:	89 f0                	mov    %esi,%eax
  800855:	5b                   	pop    %ebx
  800856:	5e                   	pop    %esi
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	56                   	push   %esi
  80085d:	53                   	push   %ebx
  80085e:	8b 75 08             	mov    0x8(%ebp),%esi
  800861:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800864:	8b 55 10             	mov    0x10(%ebp),%edx
  800867:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800869:	85 d2                	test   %edx,%edx
  80086b:	74 21                	je     80088e <strlcpy+0x35>
  80086d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800871:	89 f2                	mov    %esi,%edx
  800873:	eb 09                	jmp    80087e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800875:	83 c2 01             	add    $0x1,%edx
  800878:	83 c1 01             	add    $0x1,%ecx
  80087b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80087e:	39 c2                	cmp    %eax,%edx
  800880:	74 09                	je     80088b <strlcpy+0x32>
  800882:	0f b6 19             	movzbl (%ecx),%ebx
  800885:	84 db                	test   %bl,%bl
  800887:	75 ec                	jne    800875 <strlcpy+0x1c>
  800889:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80088b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088e:	29 f0                	sub    %esi,%eax
}
  800890:	5b                   	pop    %ebx
  800891:	5e                   	pop    %esi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089d:	eb 06                	jmp    8008a5 <strcmp+0x11>
		p++, q++;
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a5:	0f b6 01             	movzbl (%ecx),%eax
  8008a8:	84 c0                	test   %al,%al
  8008aa:	74 04                	je     8008b0 <strcmp+0x1c>
  8008ac:	3a 02                	cmp    (%edx),%al
  8008ae:	74 ef                	je     80089f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b0:	0f b6 c0             	movzbl %al,%eax
  8008b3:	0f b6 12             	movzbl (%edx),%edx
  8008b6:	29 d0                	sub    %edx,%eax
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	53                   	push   %ebx
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c4:	89 c3                	mov    %eax,%ebx
  8008c6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c9:	eb 06                	jmp    8008d1 <strncmp+0x17>
		n--, p++, q++;
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d1:	39 d8                	cmp    %ebx,%eax
  8008d3:	74 15                	je     8008ea <strncmp+0x30>
  8008d5:	0f b6 08             	movzbl (%eax),%ecx
  8008d8:	84 c9                	test   %cl,%cl
  8008da:	74 04                	je     8008e0 <strncmp+0x26>
  8008dc:	3a 0a                	cmp    (%edx),%cl
  8008de:	74 eb                	je     8008cb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e0:	0f b6 00             	movzbl (%eax),%eax
  8008e3:	0f b6 12             	movzbl (%edx),%edx
  8008e6:	29 d0                	sub    %edx,%eax
  8008e8:	eb 05                	jmp    8008ef <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ea:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ef:	5b                   	pop    %ebx
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fc:	eb 07                	jmp    800905 <strchr+0x13>
		if (*s == c)
  8008fe:	38 ca                	cmp    %cl,%dl
  800900:	74 0f                	je     800911 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800902:	83 c0 01             	add    $0x1,%eax
  800905:	0f b6 10             	movzbl (%eax),%edx
  800908:	84 d2                	test   %dl,%dl
  80090a:	75 f2                	jne    8008fe <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80090c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	8b 45 08             	mov    0x8(%ebp),%eax
  800919:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091d:	eb 03                	jmp    800922 <strfind+0xf>
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800925:	38 ca                	cmp    %cl,%dl
  800927:	74 04                	je     80092d <strfind+0x1a>
  800929:	84 d2                	test   %dl,%dl
  80092b:	75 f2                	jne    80091f <strfind+0xc>
			break;
	return (char *) s;
}
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	57                   	push   %edi
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	8b 7d 08             	mov    0x8(%ebp),%edi
  800938:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093b:	85 c9                	test   %ecx,%ecx
  80093d:	74 36                	je     800975 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80093f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800945:	75 28                	jne    80096f <memset+0x40>
  800947:	f6 c1 03             	test   $0x3,%cl
  80094a:	75 23                	jne    80096f <memset+0x40>
		c &= 0xFF;
  80094c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800950:	89 d3                	mov    %edx,%ebx
  800952:	c1 e3 08             	shl    $0x8,%ebx
  800955:	89 d6                	mov    %edx,%esi
  800957:	c1 e6 18             	shl    $0x18,%esi
  80095a:	89 d0                	mov    %edx,%eax
  80095c:	c1 e0 10             	shl    $0x10,%eax
  80095f:	09 f0                	or     %esi,%eax
  800961:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800963:	89 d8                	mov    %ebx,%eax
  800965:	09 d0                	or     %edx,%eax
  800967:	c1 e9 02             	shr    $0x2,%ecx
  80096a:	fc                   	cld    
  80096b:	f3 ab                	rep stos %eax,%es:(%edi)
  80096d:	eb 06                	jmp    800975 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800972:	fc                   	cld    
  800973:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800975:	89 f8                	mov    %edi,%eax
  800977:	5b                   	pop    %ebx
  800978:	5e                   	pop    %esi
  800979:	5f                   	pop    %edi
  80097a:	5d                   	pop    %ebp
  80097b:	c3                   	ret    

0080097c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	57                   	push   %edi
  800980:	56                   	push   %esi
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 75 0c             	mov    0xc(%ebp),%esi
  800987:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098a:	39 c6                	cmp    %eax,%esi
  80098c:	73 35                	jae    8009c3 <memmove+0x47>
  80098e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800991:	39 d0                	cmp    %edx,%eax
  800993:	73 2e                	jae    8009c3 <memmove+0x47>
		s += n;
		d += n;
  800995:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800998:	89 d6                	mov    %edx,%esi
  80099a:	09 fe                	or     %edi,%esi
  80099c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a2:	75 13                	jne    8009b7 <memmove+0x3b>
  8009a4:	f6 c1 03             	test   $0x3,%cl
  8009a7:	75 0e                	jne    8009b7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009a9:	83 ef 04             	sub    $0x4,%edi
  8009ac:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009af:	c1 e9 02             	shr    $0x2,%ecx
  8009b2:	fd                   	std    
  8009b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b5:	eb 09                	jmp    8009c0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b7:	83 ef 01             	sub    $0x1,%edi
  8009ba:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009bd:	fd                   	std    
  8009be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c0:	fc                   	cld    
  8009c1:	eb 1d                	jmp    8009e0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c3:	89 f2                	mov    %esi,%edx
  8009c5:	09 c2                	or     %eax,%edx
  8009c7:	f6 c2 03             	test   $0x3,%dl
  8009ca:	75 0f                	jne    8009db <memmove+0x5f>
  8009cc:	f6 c1 03             	test   $0x3,%cl
  8009cf:	75 0a                	jne    8009db <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d1:	c1 e9 02             	shr    $0x2,%ecx
  8009d4:	89 c7                	mov    %eax,%edi
  8009d6:	fc                   	cld    
  8009d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d9:	eb 05                	jmp    8009e0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009db:	89 c7                	mov    %eax,%edi
  8009dd:	fc                   	cld    
  8009de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e0:	5e                   	pop    %esi
  8009e1:	5f                   	pop    %edi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e7:	ff 75 10             	pushl  0x10(%ebp)
  8009ea:	ff 75 0c             	pushl  0xc(%ebp)
  8009ed:	ff 75 08             	pushl  0x8(%ebp)
  8009f0:	e8 87 ff ff ff       	call   80097c <memmove>
}
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	56                   	push   %esi
  8009fb:	53                   	push   %ebx
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a02:	89 c6                	mov    %eax,%esi
  800a04:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a07:	eb 1a                	jmp    800a23 <memcmp+0x2c>
		if (*s1 != *s2)
  800a09:	0f b6 08             	movzbl (%eax),%ecx
  800a0c:	0f b6 1a             	movzbl (%edx),%ebx
  800a0f:	38 d9                	cmp    %bl,%cl
  800a11:	74 0a                	je     800a1d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a13:	0f b6 c1             	movzbl %cl,%eax
  800a16:	0f b6 db             	movzbl %bl,%ebx
  800a19:	29 d8                	sub    %ebx,%eax
  800a1b:	eb 0f                	jmp    800a2c <memcmp+0x35>
		s1++, s2++;
  800a1d:	83 c0 01             	add    $0x1,%eax
  800a20:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a23:	39 f0                	cmp    %esi,%eax
  800a25:	75 e2                	jne    800a09 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	53                   	push   %ebx
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a37:	89 c1                	mov    %eax,%ecx
  800a39:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a40:	eb 0a                	jmp    800a4c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a42:	0f b6 10             	movzbl (%eax),%edx
  800a45:	39 da                	cmp    %ebx,%edx
  800a47:	74 07                	je     800a50 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a49:	83 c0 01             	add    $0x1,%eax
  800a4c:	39 c8                	cmp    %ecx,%eax
  800a4e:	72 f2                	jb     800a42 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a50:	5b                   	pop    %ebx
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	57                   	push   %edi
  800a57:	56                   	push   %esi
  800a58:	53                   	push   %ebx
  800a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5f:	eb 03                	jmp    800a64 <strtol+0x11>
		s++;
  800a61:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a64:	0f b6 01             	movzbl (%ecx),%eax
  800a67:	3c 20                	cmp    $0x20,%al
  800a69:	74 f6                	je     800a61 <strtol+0xe>
  800a6b:	3c 09                	cmp    $0x9,%al
  800a6d:	74 f2                	je     800a61 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a6f:	3c 2b                	cmp    $0x2b,%al
  800a71:	75 0a                	jne    800a7d <strtol+0x2a>
		s++;
  800a73:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a76:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7b:	eb 11                	jmp    800a8e <strtol+0x3b>
  800a7d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a82:	3c 2d                	cmp    $0x2d,%al
  800a84:	75 08                	jne    800a8e <strtol+0x3b>
		s++, neg = 1;
  800a86:	83 c1 01             	add    $0x1,%ecx
  800a89:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a94:	75 15                	jne    800aab <strtol+0x58>
  800a96:	80 39 30             	cmpb   $0x30,(%ecx)
  800a99:	75 10                	jne    800aab <strtol+0x58>
  800a9b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a9f:	75 7c                	jne    800b1d <strtol+0xca>
		s += 2, base = 16;
  800aa1:	83 c1 02             	add    $0x2,%ecx
  800aa4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa9:	eb 16                	jmp    800ac1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	75 12                	jne    800ac1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aaf:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab4:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab7:	75 08                	jne    800ac1 <strtol+0x6e>
		s++, base = 8;
  800ab9:	83 c1 01             	add    $0x1,%ecx
  800abc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac9:	0f b6 11             	movzbl (%ecx),%edx
  800acc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800acf:	89 f3                	mov    %esi,%ebx
  800ad1:	80 fb 09             	cmp    $0x9,%bl
  800ad4:	77 08                	ja     800ade <strtol+0x8b>
			dig = *s - '0';
  800ad6:	0f be d2             	movsbl %dl,%edx
  800ad9:	83 ea 30             	sub    $0x30,%edx
  800adc:	eb 22                	jmp    800b00 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ade:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae1:	89 f3                	mov    %esi,%ebx
  800ae3:	80 fb 19             	cmp    $0x19,%bl
  800ae6:	77 08                	ja     800af0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ae8:	0f be d2             	movsbl %dl,%edx
  800aeb:	83 ea 57             	sub    $0x57,%edx
  800aee:	eb 10                	jmp    800b00 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af0:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af3:	89 f3                	mov    %esi,%ebx
  800af5:	80 fb 19             	cmp    $0x19,%bl
  800af8:	77 16                	ja     800b10 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800afa:	0f be d2             	movsbl %dl,%edx
  800afd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b00:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b03:	7d 0b                	jge    800b10 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b05:	83 c1 01             	add    $0x1,%ecx
  800b08:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b0e:	eb b9                	jmp    800ac9 <strtol+0x76>

	if (endptr)
  800b10:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b14:	74 0d                	je     800b23 <strtol+0xd0>
		*endptr = (char *) s;
  800b16:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b19:	89 0e                	mov    %ecx,(%esi)
  800b1b:	eb 06                	jmp    800b23 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1d:	85 db                	test   %ebx,%ebx
  800b1f:	74 98                	je     800ab9 <strtol+0x66>
  800b21:	eb 9e                	jmp    800ac1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b23:	89 c2                	mov    %eax,%edx
  800b25:	f7 da                	neg    %edx
  800b27:	85 ff                	test   %edi,%edi
  800b29:	0f 45 c2             	cmovne %edx,%eax
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5f                   	pop    %edi
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    
  800b31:	66 90                	xchg   %ax,%ax
  800b33:	66 90                	xchg   %ax,%ax
  800b35:	66 90                	xchg   %ax,%ax
  800b37:	66 90                	xchg   %ax,%ax
  800b39:	66 90                	xchg   %ax,%ax
  800b3b:	66 90                	xchg   %ax,%ax
  800b3d:	66 90                	xchg   %ax,%ax
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
