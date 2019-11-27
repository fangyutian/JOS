
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = envs+ENVX(sys_getenvid());
  800045:	e8 c9 00 00 00       	call   800113 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	8d 04 40             	lea    (%eax,%eax,2),%eax
  800052:	c1 e0 05             	shl    $0x5,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 04 20 80 00       	mov    %eax,0x802004
	// cprintf("sys_getenvid(): %x\n", sys_getenvid());
	// cprintf("envs: %x, thisenv: %x\n", envs, thisenv);
	// cprintf("envs.env_id %x %x\n", envs[0].env_id, envs[1].env_id);

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x30>
		binaryname = argv[0];
  800063:	8b 06                	mov    (%esi),%eax
  800065:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	56                   	push   %esi
  80006e:	53                   	push   %ebx
  80006f:	e8 bf ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800074:	e8 0a 00 00 00       	call   800083 <exit>
}
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007f:	5b                   	pop    %ebx
  800080:	5e                   	pop    %esi
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800089:	6a 00                	push   $0x0
  80008b:	e8 42 00 00 00       	call   8000d2 <sys_env_destroy>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	c9                   	leave  
  800094:	c3                   	ret    

00800095 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	57                   	push   %edi
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	89 c7                	mov    %eax,%edi
  8000aa:	89 c6                	mov    %eax,%esi
  8000ac:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ae:	5b                   	pop    %ebx
  8000af:	5e                   	pop    %esi
  8000b0:	5f                   	pop    %edi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	57                   	push   %edi
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000be:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c3:	89 d1                	mov    %edx,%ecx
  8000c5:	89 d3                	mov    %edx,%ebx
  8000c7:	89 d7                	mov    %edx,%edi
  8000c9:	89 d6                	mov    %edx,%esi
  8000cb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e8:	89 cb                	mov    %ecx,%ebx
  8000ea:	89 cf                	mov    %ecx,%edi
  8000ec:	89 ce                	mov    %ecx,%esi
  8000ee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	7e 17                	jle    80010b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f4:	83 ec 0c             	sub    $0xc,%esp
  8000f7:	50                   	push   %eax
  8000f8:	6a 03                	push   $0x3
  8000fa:	68 ce 0d 80 00       	push   $0x800dce
  8000ff:	6a 23                	push   $0x23
  800101:	68 eb 0d 80 00       	push   $0x800deb
  800106:	e8 3c 00 00 00       	call   800147 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
  800119:	83 ec 14             	sub    $0x14,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011c:	ba 00 00 00 00       	mov    $0x0,%edx
  800121:	b8 02 00 00 00       	mov    $0x2,%eax
  800126:	89 d1                	mov    %edx,%ecx
  800128:	89 d3                	mov    %edx,%ebx
  80012a:	89 d7                	mov    %edx,%edi
  80012c:	89 d6                	mov    %edx,%esi
  80012e:	cd 30                	int    $0x30
  800130:	89 c3                	mov    %eax,%ebx

envid_t
sys_getenvid(void)
{
	envid_t ret = syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
	cprintf("lib/syscall.c: %x\n", ret);
  800132:	50                   	push   %eax
  800133:	68 f9 0d 80 00       	push   $0x800df9
  800138:	e8 e3 00 00 00       	call   800220 <cprintf>
	return ret;
}
  80013d:	89 d8                	mov    %ebx,%eax
  80013f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80014c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800155:	e8 b9 ff ff ff       	call   800113 <sys_getenvid>
  80015a:	83 ec 0c             	sub    $0xc,%esp
  80015d:	ff 75 0c             	pushl  0xc(%ebp)
  800160:	ff 75 08             	pushl  0x8(%ebp)
  800163:	56                   	push   %esi
  800164:	50                   	push   %eax
  800165:	68 0c 0e 80 00       	push   $0x800e0c
  80016a:	e8 b1 00 00 00       	call   800220 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016f:	83 c4 18             	add    $0x18,%esp
  800172:	53                   	push   %ebx
  800173:	ff 75 10             	pushl  0x10(%ebp)
  800176:	e8 54 00 00 00       	call   8001cf <vcprintf>
	cprintf("\n");
  80017b:	c7 04 24 0a 0e 80 00 	movl   $0x800e0a,(%esp)
  800182:	e8 99 00 00 00       	call   800220 <cprintf>
  800187:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018a:	cc                   	int3   
  80018b:	eb fd                	jmp    80018a <_panic+0x43>

0080018d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	53                   	push   %ebx
  800191:	83 ec 04             	sub    $0x4,%esp
  800194:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800197:	8b 13                	mov    (%ebx),%edx
  800199:	8d 42 01             	lea    0x1(%edx),%eax
  80019c:	89 03                	mov    %eax,(%ebx)
  80019e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001aa:	75 1a                	jne    8001c6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001ac:	83 ec 08             	sub    $0x8,%esp
  8001af:	68 ff 00 00 00       	push   $0xff
  8001b4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b7:	50                   	push   %eax
  8001b8:	e8 d8 fe ff ff       	call   800095 <sys_cputs>
		b->idx = 0;
  8001bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001c6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001df:	00 00 00 
	b.cnt = 0;
  8001e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ec:	ff 75 0c             	pushl  0xc(%ebp)
  8001ef:	ff 75 08             	pushl  0x8(%ebp)
  8001f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f8:	50                   	push   %eax
  8001f9:	68 8d 01 80 00       	push   $0x80018d
  8001fe:	e8 54 01 00 00       	call   800357 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800203:	83 c4 08             	add    $0x8,%esp
  800206:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80020c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800212:	50                   	push   %eax
  800213:	e8 7d fe ff ff       	call   800095 <sys_cputs>

	return b.cnt;
}
  800218:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800226:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800229:	50                   	push   %eax
  80022a:	ff 75 08             	pushl  0x8(%ebp)
  80022d:	e8 9d ff ff ff       	call   8001cf <vcprintf>
	va_end(ap);

	return cnt;
}
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	83 ec 1c             	sub    $0x1c,%esp
  80023d:	89 c7                	mov    %eax,%edi
  80023f:	89 d6                	mov    %edx,%esi
  800241:	8b 45 08             	mov    0x8(%ebp),%eax
  800244:	8b 55 0c             	mov    0xc(%ebp),%edx
  800247:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80024a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800250:	bb 00 00 00 00       	mov    $0x0,%ebx
  800255:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800258:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80025b:	39 d3                	cmp    %edx,%ebx
  80025d:	72 05                	jb     800264 <printnum+0x30>
  80025f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800262:	77 45                	ja     8002a9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800264:	83 ec 0c             	sub    $0xc,%esp
  800267:	ff 75 18             	pushl  0x18(%ebp)
  80026a:	8b 45 14             	mov    0x14(%ebp),%eax
  80026d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800270:	53                   	push   %ebx
  800271:	ff 75 10             	pushl  0x10(%ebp)
  800274:	83 ec 08             	sub    $0x8,%esp
  800277:	ff 75 e4             	pushl  -0x1c(%ebp)
  80027a:	ff 75 e0             	pushl  -0x20(%ebp)
  80027d:	ff 75 dc             	pushl  -0x24(%ebp)
  800280:	ff 75 d8             	pushl  -0x28(%ebp)
  800283:	e8 b8 08 00 00       	call   800b40 <__udivdi3>
  800288:	83 c4 18             	add    $0x18,%esp
  80028b:	52                   	push   %edx
  80028c:	50                   	push   %eax
  80028d:	89 f2                	mov    %esi,%edx
  80028f:	89 f8                	mov    %edi,%eax
  800291:	e8 9e ff ff ff       	call   800234 <printnum>
  800296:	83 c4 20             	add    $0x20,%esp
  800299:	eb 18                	jmp    8002b3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	56                   	push   %esi
  80029f:	ff 75 18             	pushl  0x18(%ebp)
  8002a2:	ff d7                	call   *%edi
  8002a4:	83 c4 10             	add    $0x10,%esp
  8002a7:	eb 03                	jmp    8002ac <printnum+0x78>
  8002a9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ac:	83 eb 01             	sub    $0x1,%ebx
  8002af:	85 db                	test   %ebx,%ebx
  8002b1:	7f e8                	jg     80029b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b3:	83 ec 08             	sub    $0x8,%esp
  8002b6:	56                   	push   %esi
  8002b7:	83 ec 04             	sub    $0x4,%esp
  8002ba:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c0:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c3:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c6:	e8 a5 09 00 00       	call   800c70 <__umoddi3>
  8002cb:	83 c4 14             	add    $0x14,%esp
  8002ce:	0f be 80 30 0e 80 00 	movsbl 0x800e30(%eax),%eax
  8002d5:	50                   	push   %eax
  8002d6:	ff d7                	call   *%edi
}
  8002d8:	83 c4 10             	add    $0x10,%esp
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e6:	83 fa 01             	cmp    $0x1,%edx
  8002e9:	7e 0e                	jle    8002f9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002eb:	8b 10                	mov    (%eax),%edx
  8002ed:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f0:	89 08                	mov    %ecx,(%eax)
  8002f2:	8b 02                	mov    (%edx),%eax
  8002f4:	8b 52 04             	mov    0x4(%edx),%edx
  8002f7:	eb 22                	jmp    80031b <getuint+0x38>
	else if (lflag)
  8002f9:	85 d2                	test   %edx,%edx
  8002fb:	74 10                	je     80030d <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002fd:	8b 10                	mov    (%eax),%edx
  8002ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  800302:	89 08                	mov    %ecx,(%eax)
  800304:	8b 02                	mov    (%edx),%eax
  800306:	ba 00 00 00 00       	mov    $0x0,%edx
  80030b:	eb 0e                	jmp    80031b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80030d:	8b 10                	mov    (%eax),%edx
  80030f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800312:	89 08                	mov    %ecx,(%eax)
  800314:	8b 02                	mov    (%edx),%eax
  800316:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800323:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800327:	8b 10                	mov    (%eax),%edx
  800329:	3b 50 04             	cmp    0x4(%eax),%edx
  80032c:	73 0a                	jae    800338 <sprintputch+0x1b>
		*b->buf++ = ch;
  80032e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800331:	89 08                	mov    %ecx,(%eax)
  800333:	8b 45 08             	mov    0x8(%ebp),%eax
  800336:	88 02                	mov    %al,(%edx)
}
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800340:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800343:	50                   	push   %eax
  800344:	ff 75 10             	pushl  0x10(%ebp)
  800347:	ff 75 0c             	pushl  0xc(%ebp)
  80034a:	ff 75 08             	pushl  0x8(%ebp)
  80034d:	e8 05 00 00 00       	call   800357 <vprintfmt>
	va_end(ap);
}
  800352:	83 c4 10             	add    $0x10,%esp
  800355:	c9                   	leave  
  800356:	c3                   	ret    

00800357 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	57                   	push   %edi
  80035b:	56                   	push   %esi
  80035c:	53                   	push   %ebx
  80035d:	83 ec 2c             	sub    $0x2c,%esp
  800360:	8b 75 08             	mov    0x8(%ebp),%esi
  800363:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800366:	8b 7d 10             	mov    0x10(%ebp),%edi
  800369:	eb 1d                	jmp    800388 <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0') {
  80036b:	85 c0                	test   %eax,%eax
  80036d:	75 0f                	jne    80037e <vprintfmt+0x27>
				csa = 0x0700;
  80036f:	c7 05 08 20 80 00 00 	movl   $0x700,0x802008
  800376:	07 00 00 
				return;
  800379:	e9 c4 03 00 00       	jmp    800742 <vprintfmt+0x3eb>
			}
			putch(ch, putdat);
  80037e:	83 ec 08             	sub    $0x8,%esp
  800381:	53                   	push   %ebx
  800382:	50                   	push   %eax
  800383:	ff d6                	call   *%esi
  800385:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800388:	83 c7 01             	add    $0x1,%edi
  80038b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80038f:	83 f8 25             	cmp    $0x25,%eax
  800392:	75 d7                	jne    80036b <vprintfmt+0x14>
  800394:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800398:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80039f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b2:	eb 07                	jmp    8003bb <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003b7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003bb:	8d 47 01             	lea    0x1(%edi),%eax
  8003be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c1:	0f b6 07             	movzbl (%edi),%eax
  8003c4:	0f b6 c8             	movzbl %al,%ecx
  8003c7:	83 e8 23             	sub    $0x23,%eax
  8003ca:	3c 55                	cmp    $0x55,%al
  8003cc:	0f 87 55 03 00 00    	ja     800727 <vprintfmt+0x3d0>
  8003d2:	0f b6 c0             	movzbl %al,%eax
  8003d5:	ff 24 85 c0 0e 80 00 	jmp    *0x800ec0(,%eax,4)
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003df:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003e3:	eb d6                	jmp    8003bb <vprintfmt+0x64>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003f0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003f3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8003f7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8003fa:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8003fd:	83 fa 09             	cmp    $0x9,%edx
  800400:	77 39                	ja     80043b <vprintfmt+0xe4>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800402:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800405:	eb e9                	jmp    8003f0 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800407:	8b 45 14             	mov    0x14(%ebp),%eax
  80040a:	8d 48 04             	lea    0x4(%eax),%ecx
  80040d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800410:	8b 00                	mov    (%eax),%eax
  800412:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800415:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800418:	eb 27                	jmp    800441 <vprintfmt+0xea>
  80041a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80041d:	85 c0                	test   %eax,%eax
  80041f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800424:	0f 49 c8             	cmovns %eax,%ecx
  800427:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80042d:	eb 8c                	jmp    8003bb <vprintfmt+0x64>
  80042f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800432:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800439:	eb 80                	jmp    8003bb <vprintfmt+0x64>
  80043b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80043e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800441:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800445:	0f 89 70 ff ff ff    	jns    8003bb <vprintfmt+0x64>
				width = precision, precision = -1;
  80044b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80044e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800451:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800458:	e9 5e ff ff ff       	jmp    8003bb <vprintfmt+0x64>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80045d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800460:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800463:	e9 53 ff ff ff       	jmp    8003bb <vprintfmt+0x64>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 50 04             	lea    0x4(%eax),%edx
  80046e:	89 55 14             	mov    %edx,0x14(%ebp)
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	53                   	push   %ebx
  800475:	ff 30                	pushl  (%eax)
  800477:	ff d6                	call   *%esi
			break;
  800479:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80047f:	e9 04 ff ff ff       	jmp    800388 <vprintfmt+0x31>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8d 50 04             	lea    0x4(%eax),%edx
  80048a:	89 55 14             	mov    %edx,0x14(%ebp)
  80048d:	8b 00                	mov    (%eax),%eax
  80048f:	99                   	cltd   
  800490:	31 d0                	xor    %edx,%eax
  800492:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800494:	83 f8 06             	cmp    $0x6,%eax
  800497:	7f 0b                	jg     8004a4 <vprintfmt+0x14d>
  800499:	8b 14 85 18 10 80 00 	mov    0x801018(,%eax,4),%edx
  8004a0:	85 d2                	test   %edx,%edx
  8004a2:	75 18                	jne    8004bc <vprintfmt+0x165>
				printfmt(putch, putdat, "error %d", err);
  8004a4:	50                   	push   %eax
  8004a5:	68 48 0e 80 00       	push   $0x800e48
  8004aa:	53                   	push   %ebx
  8004ab:	56                   	push   %esi
  8004ac:	e8 89 fe ff ff       	call   80033a <printfmt>
  8004b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004b7:	e9 cc fe ff ff       	jmp    800388 <vprintfmt+0x31>
			else
				printfmt(putch, putdat, "%s", p);
  8004bc:	52                   	push   %edx
  8004bd:	68 51 0e 80 00       	push   $0x800e51
  8004c2:	53                   	push   %ebx
  8004c3:	56                   	push   %esi
  8004c4:	e8 71 fe ff ff       	call   80033a <printfmt>
  8004c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cf:	e9 b4 fe ff ff       	jmp    800388 <vprintfmt+0x31>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d7:	8d 50 04             	lea    0x4(%eax),%edx
  8004da:	89 55 14             	mov    %edx,0x14(%ebp)
  8004dd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004df:	85 ff                	test   %edi,%edi
  8004e1:	b8 41 0e 80 00       	mov    $0x800e41,%eax
  8004e6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ed:	0f 8e 94 00 00 00    	jle    800587 <vprintfmt+0x230>
  8004f3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004f7:	0f 84 98 00 00 00    	je     800595 <vprintfmt+0x23e>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	ff 75 d0             	pushl  -0x30(%ebp)
  800503:	57                   	push   %edi
  800504:	e8 c1 02 00 00       	call   8007ca <strnlen>
  800509:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050c:	29 c1                	sub    %eax,%ecx
  80050e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800511:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800514:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800518:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80051e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800520:	eb 0f                	jmp    800531 <vprintfmt+0x1da>
					putch(padc, putdat);
  800522:	83 ec 08             	sub    $0x8,%esp
  800525:	53                   	push   %ebx
  800526:	ff 75 e0             	pushl  -0x20(%ebp)
  800529:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	83 ef 01             	sub    $0x1,%edi
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	85 ff                	test   %edi,%edi
  800533:	7f ed                	jg     800522 <vprintfmt+0x1cb>
  800535:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800538:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80053b:	85 c9                	test   %ecx,%ecx
  80053d:	b8 00 00 00 00       	mov    $0x0,%eax
  800542:	0f 49 c1             	cmovns %ecx,%eax
  800545:	29 c1                	sub    %eax,%ecx
  800547:	89 75 08             	mov    %esi,0x8(%ebp)
  80054a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80054d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800550:	89 cb                	mov    %ecx,%ebx
  800552:	eb 4d                	jmp    8005a1 <vprintfmt+0x24a>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800554:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800558:	74 1b                	je     800575 <vprintfmt+0x21e>
  80055a:	0f be c0             	movsbl %al,%eax
  80055d:	83 e8 20             	sub    $0x20,%eax
  800560:	83 f8 5e             	cmp    $0x5e,%eax
  800563:	76 10                	jbe    800575 <vprintfmt+0x21e>
					putch('?', putdat);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	ff 75 0c             	pushl  0xc(%ebp)
  80056b:	6a 3f                	push   $0x3f
  80056d:	ff 55 08             	call   *0x8(%ebp)
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	eb 0d                	jmp    800582 <vprintfmt+0x22b>
				else
					putch(ch, putdat);
  800575:	83 ec 08             	sub    $0x8,%esp
  800578:	ff 75 0c             	pushl  0xc(%ebp)
  80057b:	52                   	push   %edx
  80057c:	ff 55 08             	call   *0x8(%ebp)
  80057f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800582:	83 eb 01             	sub    $0x1,%ebx
  800585:	eb 1a                	jmp    8005a1 <vprintfmt+0x24a>
  800587:	89 75 08             	mov    %esi,0x8(%ebp)
  80058a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80058d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800590:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800593:	eb 0c                	jmp    8005a1 <vprintfmt+0x24a>
  800595:	89 75 08             	mov    %esi,0x8(%ebp)
  800598:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80059b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80059e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005a1:	83 c7 01             	add    $0x1,%edi
  8005a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005a8:	0f be d0             	movsbl %al,%edx
  8005ab:	85 d2                	test   %edx,%edx
  8005ad:	74 23                	je     8005d2 <vprintfmt+0x27b>
  8005af:	85 f6                	test   %esi,%esi
  8005b1:	78 a1                	js     800554 <vprintfmt+0x1fd>
  8005b3:	83 ee 01             	sub    $0x1,%esi
  8005b6:	79 9c                	jns    800554 <vprintfmt+0x1fd>
  8005b8:	89 df                	mov    %ebx,%edi
  8005ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8005bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c0:	eb 18                	jmp    8005da <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c2:	83 ec 08             	sub    $0x8,%esp
  8005c5:	53                   	push   %ebx
  8005c6:	6a 20                	push   $0x20
  8005c8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ca:	83 ef 01             	sub    $0x1,%edi
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	eb 08                	jmp    8005da <vprintfmt+0x283>
  8005d2:	89 df                	mov    %ebx,%edi
  8005d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005da:	85 ff                	test   %edi,%edi
  8005dc:	7f e4                	jg     8005c2 <vprintfmt+0x26b>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e1:	e9 a2 fd ff ff       	jmp    800388 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e6:	83 fa 01             	cmp    $0x1,%edx
  8005e9:	7e 16                	jle    800601 <vprintfmt+0x2aa>
		return va_arg(*ap, long long);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 50 08             	lea    0x8(%eax),%edx
  8005f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f4:	8b 50 04             	mov    0x4(%eax),%edx
  8005f7:	8b 00                	mov    (%eax),%eax
  8005f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005ff:	eb 32                	jmp    800633 <vprintfmt+0x2dc>
	else if (lflag)
  800601:	85 d2                	test   %edx,%edx
  800603:	74 18                	je     80061d <vprintfmt+0x2c6>
		return va_arg(*ap, long);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8d 50 04             	lea    0x4(%eax),%edx
  80060b:	89 55 14             	mov    %edx,0x14(%ebp)
  80060e:	8b 00                	mov    (%eax),%eax
  800610:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800613:	89 c1                	mov    %eax,%ecx
  800615:	c1 f9 1f             	sar    $0x1f,%ecx
  800618:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80061b:	eb 16                	jmp    800633 <vprintfmt+0x2dc>
	else
		return va_arg(*ap, int);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8d 50 04             	lea    0x4(%eax),%edx
  800623:	89 55 14             	mov    %edx,0x14(%ebp)
  800626:	8b 00                	mov    (%eax),%eax
  800628:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062b:	89 c1                	mov    %eax,%ecx
  80062d:	c1 f9 1f             	sar    $0x1f,%ecx
  800630:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800633:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800636:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800639:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800642:	79 74                	jns    8006b8 <vprintfmt+0x361>
				putch('-', putdat);
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	53                   	push   %ebx
  800648:	6a 2d                	push   $0x2d
  80064a:	ff d6                	call   *%esi
				num = -(long long) num;
  80064c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800652:	f7 d8                	neg    %eax
  800654:	83 d2 00             	adc    $0x0,%edx
  800657:	f7 da                	neg    %edx
  800659:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80065c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800661:	eb 55                	jmp    8006b8 <vprintfmt+0x361>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	e8 78 fc ff ff       	call   8002e3 <getuint>
			base = 10;
  80066b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800670:	eb 46                	jmp    8006b8 <vprintfmt+0x361>

		// (unsigned) octal
		case 'o':
      num = getuint(&ap, lflag);
  800672:	8d 45 14             	lea    0x14(%ebp),%eax
  800675:	e8 69 fc ff ff       	call   8002e3 <getuint>
      base = 8;
  80067a:	b9 08 00 00 00       	mov    $0x8,%ecx
      goto number;
  80067f:	eb 37                	jmp    8006b8 <vprintfmt+0x361>

		// pointer
		case 'p':
			putch('0', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 30                	push   $0x30
  800687:	ff d6                	call   *%esi
			putch('x', putdat);
  800689:	83 c4 08             	add    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	6a 78                	push   $0x78
  80068f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 50 04             	lea    0x4(%eax),%edx
  800697:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069a:	8b 00                	mov    (%eax),%eax
  80069c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8006a9:	eb 0d                	jmp    8006b8 <vprintfmt+0x361>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ae:	e8 30 fc ff ff       	call   8002e3 <getuint>
			base = 16;
  8006b3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b8:	83 ec 0c             	sub    $0xc,%esp
  8006bb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006bf:	57                   	push   %edi
  8006c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c3:	51                   	push   %ecx
  8006c4:	52                   	push   %edx
  8006c5:	50                   	push   %eax
  8006c6:	89 da                	mov    %ebx,%edx
  8006c8:	89 f0                	mov    %esi,%eax
  8006ca:	e8 65 fb ff ff       	call   800234 <printnum>
			break;
  8006cf:	83 c4 20             	add    $0x20,%esp
  8006d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d5:	e9 ae fc ff ff       	jmp    800388 <vprintfmt+0x31>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	51                   	push   %ecx
  8006df:	ff d6                	call   *%esi
			break;
  8006e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e7:	e9 9c fc ff ff       	jmp    800388 <vprintfmt+0x31>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ec:	83 fa 01             	cmp    $0x1,%edx
  8006ef:	7e 0d                	jle    8006fe <vprintfmt+0x3a7>
		return va_arg(*ap, long long);
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8d 50 08             	lea    0x8(%eax),%edx
  8006f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fa:	8b 00                	mov    (%eax),%eax
  8006fc:	eb 1c                	jmp    80071a <vprintfmt+0x3c3>
	else if (lflag)
  8006fe:	85 d2                	test   %edx,%edx
  800700:	74 0d                	je     80070f <vprintfmt+0x3b8>
		return va_arg(*ap, long);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8d 50 04             	lea    0x4(%eax),%edx
  800708:	89 55 14             	mov    %edx,0x14(%ebp)
  80070b:	8b 00                	mov    (%eax),%eax
  80070d:	eb 0b                	jmp    80071a <vprintfmt+0x3c3>
	else
		return va_arg(*ap, int);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 00                	mov    (%eax),%eax
			putch(ch, putdat);
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
  80071a:	a3 08 20 80 00       	mov    %eax,0x802008
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		case 'm':
			num = getint(&ap, lflag);
			csa = num;
			break;
  800722:	e9 61 fc ff ff       	jmp    800388 <vprintfmt+0x31>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	53                   	push   %ebx
  80072b:	6a 25                	push   $0x25
  80072d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	eb 03                	jmp    800737 <vprintfmt+0x3e0>
  800734:	83 ef 01             	sub    $0x1,%edi
  800737:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80073b:	75 f7                	jne    800734 <vprintfmt+0x3dd>
  80073d:	e9 46 fc ff ff       	jmp    800388 <vprintfmt+0x31>
				/* do nothing */;
			break;
		}
	}
}
  800742:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800745:	5b                   	pop    %ebx
  800746:	5e                   	pop    %esi
  800747:	5f                   	pop    %edi
  800748:	5d                   	pop    %ebp
  800749:	c3                   	ret    

0080074a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	83 ec 18             	sub    $0x18,%esp
  800750:	8b 45 08             	mov    0x8(%ebp),%eax
  800753:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800756:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800759:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800760:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800767:	85 c0                	test   %eax,%eax
  800769:	74 26                	je     800791 <vsnprintf+0x47>
  80076b:	85 d2                	test   %edx,%edx
  80076d:	7e 22                	jle    800791 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076f:	ff 75 14             	pushl  0x14(%ebp)
  800772:	ff 75 10             	pushl  0x10(%ebp)
  800775:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800778:	50                   	push   %eax
  800779:	68 1d 03 80 00       	push   $0x80031d
  80077e:	e8 d4 fb ff ff       	call   800357 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800783:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800786:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	eb 05                	jmp    800796 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800791:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800796:	c9                   	leave  
  800797:	c3                   	ret    

00800798 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a1:	50                   	push   %eax
  8007a2:	ff 75 10             	pushl  0x10(%ebp)
  8007a5:	ff 75 0c             	pushl  0xc(%ebp)
  8007a8:	ff 75 08             	pushl  0x8(%ebp)
  8007ab:	e8 9a ff ff ff       	call   80074a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bd:	eb 03                	jmp    8007c2 <strlen+0x10>
		n++;
  8007bf:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c6:	75 f7                	jne    8007bf <strlen+0xd>
		n++;
	return n;
}
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8007d8:	eb 03                	jmp    8007dd <strnlen+0x13>
		n++;
  8007da:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dd:	39 c2                	cmp    %eax,%edx
  8007df:	74 08                	je     8007e9 <strnlen+0x1f>
  8007e1:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007e5:	75 f3                	jne    8007da <strnlen+0x10>
  8007e7:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007f5:	89 c2                	mov    %eax,%edx
  8007f7:	83 c2 01             	add    $0x1,%edx
  8007fa:	83 c1 01             	add    $0x1,%ecx
  8007fd:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800801:	88 5a ff             	mov    %bl,-0x1(%edx)
  800804:	84 db                	test   %bl,%bl
  800806:	75 ef                	jne    8007f7 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800808:	5b                   	pop    %ebx
  800809:	5d                   	pop    %ebp
  80080a:	c3                   	ret    

0080080b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80080b:	55                   	push   %ebp
  80080c:	89 e5                	mov    %esp,%ebp
  80080e:	53                   	push   %ebx
  80080f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800812:	53                   	push   %ebx
  800813:	e8 9a ff ff ff       	call   8007b2 <strlen>
  800818:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80081b:	ff 75 0c             	pushl  0xc(%ebp)
  80081e:	01 d8                	add    %ebx,%eax
  800820:	50                   	push   %eax
  800821:	e8 c5 ff ff ff       	call   8007eb <strcpy>
	return dst;
}
  800826:	89 d8                	mov    %ebx,%eax
  800828:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082b:	c9                   	leave  
  80082c:	c3                   	ret    

0080082d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	56                   	push   %esi
  800831:	53                   	push   %ebx
  800832:	8b 75 08             	mov    0x8(%ebp),%esi
  800835:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800838:	89 f3                	mov    %esi,%ebx
  80083a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083d:	89 f2                	mov    %esi,%edx
  80083f:	eb 0f                	jmp    800850 <strncpy+0x23>
		*dst++ = *src;
  800841:	83 c2 01             	add    $0x1,%edx
  800844:	0f b6 01             	movzbl (%ecx),%eax
  800847:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80084a:	80 39 01             	cmpb   $0x1,(%ecx)
  80084d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800850:	39 da                	cmp    %ebx,%edx
  800852:	75 ed                	jne    800841 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800854:	89 f0                	mov    %esi,%eax
  800856:	5b                   	pop    %ebx
  800857:	5e                   	pop    %esi
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	56                   	push   %esi
  80085e:	53                   	push   %ebx
  80085f:	8b 75 08             	mov    0x8(%ebp),%esi
  800862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800865:	8b 55 10             	mov    0x10(%ebp),%edx
  800868:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086a:	85 d2                	test   %edx,%edx
  80086c:	74 21                	je     80088f <strlcpy+0x35>
  80086e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800872:	89 f2                	mov    %esi,%edx
  800874:	eb 09                	jmp    80087f <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800876:	83 c2 01             	add    $0x1,%edx
  800879:	83 c1 01             	add    $0x1,%ecx
  80087c:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80087f:	39 c2                	cmp    %eax,%edx
  800881:	74 09                	je     80088c <strlcpy+0x32>
  800883:	0f b6 19             	movzbl (%ecx),%ebx
  800886:	84 db                	test   %bl,%bl
  800888:	75 ec                	jne    800876 <strlcpy+0x1c>
  80088a:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80088c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088f:	29 f0                	sub    %esi,%eax
}
  800891:	5b                   	pop    %ebx
  800892:	5e                   	pop    %esi
  800893:	5d                   	pop    %ebp
  800894:	c3                   	ret    

00800895 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089e:	eb 06                	jmp    8008a6 <strcmp+0x11>
		p++, q++;
  8008a0:	83 c1 01             	add    $0x1,%ecx
  8008a3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a6:	0f b6 01             	movzbl (%ecx),%eax
  8008a9:	84 c0                	test   %al,%al
  8008ab:	74 04                	je     8008b1 <strcmp+0x1c>
  8008ad:	3a 02                	cmp    (%edx),%al
  8008af:	74 ef                	je     8008a0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b1:	0f b6 c0             	movzbl %al,%eax
  8008b4:	0f b6 12             	movzbl (%edx),%edx
  8008b7:	29 d0                	sub    %edx,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c5:	89 c3                	mov    %eax,%ebx
  8008c7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ca:	eb 06                	jmp    8008d2 <strncmp+0x17>
		n--, p++, q++;
  8008cc:	83 c0 01             	add    $0x1,%eax
  8008cf:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d2:	39 d8                	cmp    %ebx,%eax
  8008d4:	74 15                	je     8008eb <strncmp+0x30>
  8008d6:	0f b6 08             	movzbl (%eax),%ecx
  8008d9:	84 c9                	test   %cl,%cl
  8008db:	74 04                	je     8008e1 <strncmp+0x26>
  8008dd:	3a 0a                	cmp    (%edx),%cl
  8008df:	74 eb                	je     8008cc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e1:	0f b6 00             	movzbl (%eax),%eax
  8008e4:	0f b6 12             	movzbl (%edx),%edx
  8008e7:	29 d0                	sub    %edx,%eax
  8008e9:	eb 05                	jmp    8008f0 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008eb:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f0:	5b                   	pop    %ebx
  8008f1:	5d                   	pop    %ebp
  8008f2:	c3                   	ret    

008008f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fd:	eb 07                	jmp    800906 <strchr+0x13>
		if (*s == c)
  8008ff:	38 ca                	cmp    %cl,%dl
  800901:	74 0f                	je     800912 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800903:	83 c0 01             	add    $0x1,%eax
  800906:	0f b6 10             	movzbl (%eax),%edx
  800909:	84 d2                	test   %dl,%dl
  80090b:	75 f2                	jne    8008ff <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091e:	eb 03                	jmp    800923 <strfind+0xf>
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800926:	38 ca                	cmp    %cl,%dl
  800928:	74 04                	je     80092e <strfind+0x1a>
  80092a:	84 d2                	test   %dl,%dl
  80092c:	75 f2                	jne    800920 <strfind+0xc>
			break;
	return (char *) s;
}
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	57                   	push   %edi
  800934:	56                   	push   %esi
  800935:	53                   	push   %ebx
  800936:	8b 7d 08             	mov    0x8(%ebp),%edi
  800939:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093c:	85 c9                	test   %ecx,%ecx
  80093e:	74 36                	je     800976 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800940:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800946:	75 28                	jne    800970 <memset+0x40>
  800948:	f6 c1 03             	test   $0x3,%cl
  80094b:	75 23                	jne    800970 <memset+0x40>
		c &= 0xFF;
  80094d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800951:	89 d3                	mov    %edx,%ebx
  800953:	c1 e3 08             	shl    $0x8,%ebx
  800956:	89 d6                	mov    %edx,%esi
  800958:	c1 e6 18             	shl    $0x18,%esi
  80095b:	89 d0                	mov    %edx,%eax
  80095d:	c1 e0 10             	shl    $0x10,%eax
  800960:	09 f0                	or     %esi,%eax
  800962:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800964:	89 d8                	mov    %ebx,%eax
  800966:	09 d0                	or     %edx,%eax
  800968:	c1 e9 02             	shr    $0x2,%ecx
  80096b:	fc                   	cld    
  80096c:	f3 ab                	rep stos %eax,%es:(%edi)
  80096e:	eb 06                	jmp    800976 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800970:	8b 45 0c             	mov    0xc(%ebp),%eax
  800973:	fc                   	cld    
  800974:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800976:	89 f8                	mov    %edi,%eax
  800978:	5b                   	pop    %ebx
  800979:	5e                   	pop    %esi
  80097a:	5f                   	pop    %edi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    

0080097d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	57                   	push   %edi
  800981:	56                   	push   %esi
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 75 0c             	mov    0xc(%ebp),%esi
  800988:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098b:	39 c6                	cmp    %eax,%esi
  80098d:	73 35                	jae    8009c4 <memmove+0x47>
  80098f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800992:	39 d0                	cmp    %edx,%eax
  800994:	73 2e                	jae    8009c4 <memmove+0x47>
		s += n;
		d += n;
  800996:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800999:	89 d6                	mov    %edx,%esi
  80099b:	09 fe                	or     %edi,%esi
  80099d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a3:	75 13                	jne    8009b8 <memmove+0x3b>
  8009a5:	f6 c1 03             	test   $0x3,%cl
  8009a8:	75 0e                	jne    8009b8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009aa:	83 ef 04             	sub    $0x4,%edi
  8009ad:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b0:	c1 e9 02             	shr    $0x2,%ecx
  8009b3:	fd                   	std    
  8009b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b6:	eb 09                	jmp    8009c1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b8:	83 ef 01             	sub    $0x1,%edi
  8009bb:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009be:	fd                   	std    
  8009bf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c1:	fc                   	cld    
  8009c2:	eb 1d                	jmp    8009e1 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c4:	89 f2                	mov    %esi,%edx
  8009c6:	09 c2                	or     %eax,%edx
  8009c8:	f6 c2 03             	test   $0x3,%dl
  8009cb:	75 0f                	jne    8009dc <memmove+0x5f>
  8009cd:	f6 c1 03             	test   $0x3,%cl
  8009d0:	75 0a                	jne    8009dc <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d2:	c1 e9 02             	shr    $0x2,%ecx
  8009d5:	89 c7                	mov    %eax,%edi
  8009d7:	fc                   	cld    
  8009d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009da:	eb 05                	jmp    8009e1 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e1:	5e                   	pop    %esi
  8009e2:	5f                   	pop    %edi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009e8:	ff 75 10             	pushl  0x10(%ebp)
  8009eb:	ff 75 0c             	pushl  0xc(%ebp)
  8009ee:	ff 75 08             	pushl  0x8(%ebp)
  8009f1:	e8 87 ff ff ff       	call   80097d <memmove>
}
  8009f6:	c9                   	leave  
  8009f7:	c3                   	ret    

008009f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a03:	89 c6                	mov    %eax,%esi
  800a05:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a08:	eb 1a                	jmp    800a24 <memcmp+0x2c>
		if (*s1 != *s2)
  800a0a:	0f b6 08             	movzbl (%eax),%ecx
  800a0d:	0f b6 1a             	movzbl (%edx),%ebx
  800a10:	38 d9                	cmp    %bl,%cl
  800a12:	74 0a                	je     800a1e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a14:	0f b6 c1             	movzbl %cl,%eax
  800a17:	0f b6 db             	movzbl %bl,%ebx
  800a1a:	29 d8                	sub    %ebx,%eax
  800a1c:	eb 0f                	jmp    800a2d <memcmp+0x35>
		s1++, s2++;
  800a1e:	83 c0 01             	add    $0x1,%eax
  800a21:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a24:	39 f0                	cmp    %esi,%eax
  800a26:	75 e2                	jne    800a0a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5e                   	pop    %esi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	53                   	push   %ebx
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a38:	89 c1                	mov    %eax,%ecx
  800a3a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a41:	eb 0a                	jmp    800a4d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a43:	0f b6 10             	movzbl (%eax),%edx
  800a46:	39 da                	cmp    %ebx,%edx
  800a48:	74 07                	je     800a51 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	39 c8                	cmp    %ecx,%eax
  800a4f:	72 f2                	jb     800a43 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a51:	5b                   	pop    %ebx
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    

00800a54 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	57                   	push   %edi
  800a58:	56                   	push   %esi
  800a59:	53                   	push   %ebx
  800a5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a60:	eb 03                	jmp    800a65 <strtol+0x11>
		s++;
  800a62:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a65:	0f b6 01             	movzbl (%ecx),%eax
  800a68:	3c 20                	cmp    $0x20,%al
  800a6a:	74 f6                	je     800a62 <strtol+0xe>
  800a6c:	3c 09                	cmp    $0x9,%al
  800a6e:	74 f2                	je     800a62 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a70:	3c 2b                	cmp    $0x2b,%al
  800a72:	75 0a                	jne    800a7e <strtol+0x2a>
		s++;
  800a74:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a77:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7c:	eb 11                	jmp    800a8f <strtol+0x3b>
  800a7e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a83:	3c 2d                	cmp    $0x2d,%al
  800a85:	75 08                	jne    800a8f <strtol+0x3b>
		s++, neg = 1;
  800a87:	83 c1 01             	add    $0x1,%ecx
  800a8a:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a95:	75 15                	jne    800aac <strtol+0x58>
  800a97:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9a:	75 10                	jne    800aac <strtol+0x58>
  800a9c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa0:	75 7c                	jne    800b1e <strtol+0xca>
		s += 2, base = 16;
  800aa2:	83 c1 02             	add    $0x2,%ecx
  800aa5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aaa:	eb 16                	jmp    800ac2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aac:	85 db                	test   %ebx,%ebx
  800aae:	75 12                	jne    800ac2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab8:	75 08                	jne    800ac2 <strtol+0x6e>
		s++, base = 8;
  800aba:	83 c1 01             	add    $0x1,%ecx
  800abd:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aca:	0f b6 11             	movzbl (%ecx),%edx
  800acd:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad0:	89 f3                	mov    %esi,%ebx
  800ad2:	80 fb 09             	cmp    $0x9,%bl
  800ad5:	77 08                	ja     800adf <strtol+0x8b>
			dig = *s - '0';
  800ad7:	0f be d2             	movsbl %dl,%edx
  800ada:	83 ea 30             	sub    $0x30,%edx
  800add:	eb 22                	jmp    800b01 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800adf:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae2:	89 f3                	mov    %esi,%ebx
  800ae4:	80 fb 19             	cmp    $0x19,%bl
  800ae7:	77 08                	ja     800af1 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ae9:	0f be d2             	movsbl %dl,%edx
  800aec:	83 ea 57             	sub    $0x57,%edx
  800aef:	eb 10                	jmp    800b01 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af1:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af4:	89 f3                	mov    %esi,%ebx
  800af6:	80 fb 19             	cmp    $0x19,%bl
  800af9:	77 16                	ja     800b11 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800afb:	0f be d2             	movsbl %dl,%edx
  800afe:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b01:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b04:	7d 0b                	jge    800b11 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b06:	83 c1 01             	add    $0x1,%ecx
  800b09:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b0d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b0f:	eb b9                	jmp    800aca <strtol+0x76>

	if (endptr)
  800b11:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b15:	74 0d                	je     800b24 <strtol+0xd0>
		*endptr = (char *) s;
  800b17:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1a:	89 0e                	mov    %ecx,(%esi)
  800b1c:	eb 06                	jmp    800b24 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b1e:	85 db                	test   %ebx,%ebx
  800b20:	74 98                	je     800aba <strtol+0x66>
  800b22:	eb 9e                	jmp    800ac2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b24:	89 c2                	mov    %eax,%edx
  800b26:	f7 da                	neg    %edx
  800b28:	85 ff                	test   %edi,%edi
  800b2a:	0f 45 c2             	cmovne %edx,%eax
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    
  800b32:	66 90                	xchg   %ax,%ax
  800b34:	66 90                	xchg   %ax,%ax
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
