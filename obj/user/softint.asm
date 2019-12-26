
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
  80003d:	57                   	push   %edi
  80003e:	56                   	push   %esi
  80003f:	53                   	push   %ebx
  800040:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800043:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80004a:	00 00 00 
	envid_t eid = sys_getenvid();
  80004d:	e8 06 01 00 00       	call   800158 <sys_getenvid>
  800052:	8b 3d 04 20 80 00    	mov    0x802004,%edi
  800058:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80005d:	be 00 00 00 00       	mov    $0x0,%esi
	int i;
	for (i = 0; i < NENV; i++) {
  800062:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == eid) {
  800067:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80006a:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800070:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &(envs[i]);
  800073:	39 c8                	cmp    %ecx,%eax
  800075:	0f 44 fb             	cmove  %ebx,%edi
  800078:	b9 01 00 00 00       	mov    $0x1,%ecx
  80007d:	0f 44 f1             	cmove  %ecx,%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
	envid_t eid = sys_getenvid();
	int i;
	for (i = 0; i < NENV; i++) {
  800080:	83 c2 01             	add    $0x1,%edx
  800083:	83 c3 7c             	add    $0x7c,%ebx
  800086:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80008c:	75 d9                	jne    800067 <libmain+0x2d>
  80008e:	89 f0                	mov    %esi,%eax
  800090:	84 c0                	test   %al,%al
  800092:	74 06                	je     80009a <libmain+0x60>
  800094:	89 3d 04 20 80 00    	mov    %edi,0x802004
			thisenv = &(envs[i]);
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80009e:	7e 0a                	jle    8000aa <libmain+0x70>
		binaryname = argv[0];
  8000a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000a3:	8b 00                	mov    (%eax),%eax
  8000a5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000aa:	83 ec 08             	sub    $0x8,%esp
  8000ad:	ff 75 0c             	pushl  0xc(%ebp)
  8000b0:	ff 75 08             	pushl  0x8(%ebp)
  8000b3:	e8 7b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0b 00 00 00       	call   8000c8 <exit>
}
  8000bd:	83 c4 10             	add    $0x10,%esp
  8000c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ce:	6a 00                	push   $0x0
  8000d0:	e8 42 00 00 00       	call   800117 <sys_env_destroy>
}
  8000d5:	83 c4 10             	add    $0x10,%esp
  8000d8:	c9                   	leave  
  8000d9:	c3                   	ret    

008000da <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000eb:	89 c3                	mov    %eax,%ebx
  8000ed:	89 c7                	mov    %eax,%edi
  8000ef:	89 c6                	mov    %eax,%esi
  8000f1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	57                   	push   %edi
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800103:	b8 01 00 00 00       	mov    $0x1,%eax
  800108:	89 d1                	mov    %edx,%ecx
  80010a:	89 d3                	mov    %edx,%ebx
  80010c:	89 d7                	mov    %edx,%edi
  80010e:	89 d6                	mov    %edx,%esi
  800110:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
  80011d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800120:	b9 00 00 00 00       	mov    $0x0,%ecx
  800125:	b8 03 00 00 00       	mov    $0x3,%eax
  80012a:	8b 55 08             	mov    0x8(%ebp),%edx
  80012d:	89 cb                	mov    %ecx,%ebx
  80012f:	89 cf                	mov    %ecx,%edi
  800131:	89 ce                	mov    %ecx,%esi
  800133:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800135:	85 c0                	test   %eax,%eax
  800137:	7e 17                	jle    800150 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800139:	83 ec 0c             	sub    $0xc,%esp
  80013c:	50                   	push   %eax
  80013d:	6a 03                	push   $0x3
  80013f:	68 0a 10 80 00       	push   $0x80100a
  800144:	6a 23                	push   $0x23
  800146:	68 27 10 80 00       	push   $0x801027
  80014b:	e8 f5 01 00 00       	call   800345 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800150:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5f                   	pop    %edi
  800156:	5d                   	pop    %ebp
  800157:	c3                   	ret    

00800158 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	57                   	push   %edi
  80015c:	56                   	push   %esi
  80015d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	ba 00 00 00 00       	mov    $0x0,%edx
  800163:	b8 02 00 00 00       	mov    $0x2,%eax
  800168:	89 d1                	mov    %edx,%ecx
  80016a:	89 d3                	mov    %edx,%ebx
  80016c:	89 d7                	mov    %edx,%edi
  80016e:	89 d6                	mov    %edx,%esi
  800170:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800172:	5b                   	pop    %ebx
  800173:	5e                   	pop    %esi
  800174:	5f                   	pop    %edi
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <sys_yield>:

void
sys_yield(void)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	57                   	push   %edi
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017d:	ba 00 00 00 00       	mov    $0x0,%edx
  800182:	b8 0a 00 00 00       	mov    $0xa,%eax
  800187:	89 d1                	mov    %edx,%ecx
  800189:	89 d3                	mov    %edx,%ebx
  80018b:	89 d7                	mov    %edx,%edi
  80018d:	89 d6                	mov    %edx,%esi
  80018f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800191:	5b                   	pop    %ebx
  800192:	5e                   	pop    %esi
  800193:	5f                   	pop    %edi
  800194:	5d                   	pop    %ebp
  800195:	c3                   	ret    

00800196 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	57                   	push   %edi
  80019a:	56                   	push   %esi
  80019b:	53                   	push   %ebx
  80019c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019f:	be 00 00 00 00       	mov    $0x0,%esi
  8001a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8001af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b2:	89 f7                	mov    %esi,%edi
  8001b4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	7e 17                	jle    8001d1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ba:	83 ec 0c             	sub    $0xc,%esp
  8001bd:	50                   	push   %eax
  8001be:	6a 04                	push   $0x4
  8001c0:	68 0a 10 80 00       	push   $0x80100a
  8001c5:	6a 23                	push   $0x23
  8001c7:	68 27 10 80 00       	push   $0x801027
  8001cc:	e8 74 01 00 00       	call   800345 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d4:	5b                   	pop    %ebx
  8001d5:	5e                   	pop    %esi
  8001d6:	5f                   	pop    %edi
  8001d7:	5d                   	pop    %ebp
  8001d8:	c3                   	ret    

008001d9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	57                   	push   %edi
  8001dd:	56                   	push   %esi
  8001de:	53                   	push   %ebx
  8001df:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	7e 17                	jle    800213 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fc:	83 ec 0c             	sub    $0xc,%esp
  8001ff:	50                   	push   %eax
  800200:	6a 05                	push   $0x5
  800202:	68 0a 10 80 00       	push   $0x80100a
  800207:	6a 23                	push   $0x23
  800209:	68 27 10 80 00       	push   $0x801027
  80020e:	e8 32 01 00 00       	call   800345 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800213:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800216:	5b                   	pop    %ebx
  800217:	5e                   	pop    %esi
  800218:	5f                   	pop    %edi
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    

0080021b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	57                   	push   %edi
  80021f:	56                   	push   %esi
  800220:	53                   	push   %ebx
  800221:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800224:	bb 00 00 00 00       	mov    $0x0,%ebx
  800229:	b8 06 00 00 00       	mov    $0x6,%eax
  80022e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800231:	8b 55 08             	mov    0x8(%ebp),%edx
  800234:	89 df                	mov    %ebx,%edi
  800236:	89 de                	mov    %ebx,%esi
  800238:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023a:	85 c0                	test   %eax,%eax
  80023c:	7e 17                	jle    800255 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023e:	83 ec 0c             	sub    $0xc,%esp
  800241:	50                   	push   %eax
  800242:	6a 06                	push   $0x6
  800244:	68 0a 10 80 00       	push   $0x80100a
  800249:	6a 23                	push   $0x23
  80024b:	68 27 10 80 00       	push   $0x801027
  800250:	e8 f0 00 00 00       	call   800345 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800255:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800258:	5b                   	pop    %ebx
  800259:	5e                   	pop    %esi
  80025a:	5f                   	pop    %edi
  80025b:	5d                   	pop    %ebp
  80025c:	c3                   	ret    

0080025d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	57                   	push   %edi
  800261:	56                   	push   %esi
  800262:	53                   	push   %ebx
  800263:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800266:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026b:	b8 08 00 00 00       	mov    $0x8,%eax
  800270:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800273:	8b 55 08             	mov    0x8(%ebp),%edx
  800276:	89 df                	mov    %ebx,%edi
  800278:	89 de                	mov    %ebx,%esi
  80027a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027c:	85 c0                	test   %eax,%eax
  80027e:	7e 17                	jle    800297 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800280:	83 ec 0c             	sub    $0xc,%esp
  800283:	50                   	push   %eax
  800284:	6a 08                	push   $0x8
  800286:	68 0a 10 80 00       	push   $0x80100a
  80028b:	6a 23                	push   $0x23
  80028d:	68 27 10 80 00       	push   $0x801027
  800292:	e8 ae 00 00 00       	call   800345 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800297:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029a:	5b                   	pop    %ebx
  80029b:	5e                   	pop    %esi
  80029c:	5f                   	pop    %edi
  80029d:	5d                   	pop    %ebp
  80029e:	c3                   	ret    

0080029f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	57                   	push   %edi
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ad:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b8:	89 df                	mov    %ebx,%edi
  8002ba:	89 de                	mov    %ebx,%esi
  8002bc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	7e 17                	jle    8002d9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c2:	83 ec 0c             	sub    $0xc,%esp
  8002c5:	50                   	push   %eax
  8002c6:	6a 09                	push   $0x9
  8002c8:	68 0a 10 80 00       	push   $0x80100a
  8002cd:	6a 23                	push   $0x23
  8002cf:	68 27 10 80 00       	push   $0x801027
  8002d4:	e8 6c 00 00 00       	call   800345 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    

008002e1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	57                   	push   %edi
  8002e5:	56                   	push   %esi
  8002e6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e7:	be 00 00 00 00       	mov    $0x0,%esi
  8002ec:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ff:	5b                   	pop    %ebx
  800300:	5e                   	pop    %esi
  800301:	5f                   	pop    %edi
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	57                   	push   %edi
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
  80030a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800312:	b8 0c 00 00 00       	mov    $0xc,%eax
  800317:	8b 55 08             	mov    0x8(%ebp),%edx
  80031a:	89 cb                	mov    %ecx,%ebx
  80031c:	89 cf                	mov    %ecx,%edi
  80031e:	89 ce                	mov    %ecx,%esi
  800320:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800322:	85 c0                	test   %eax,%eax
  800324:	7e 17                	jle    80033d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800326:	83 ec 0c             	sub    $0xc,%esp
  800329:	50                   	push   %eax
  80032a:	6a 0c                	push   $0xc
  80032c:	68 0a 10 80 00       	push   $0x80100a
  800331:	6a 23                	push   $0x23
  800333:	68 27 10 80 00       	push   $0x801027
  800338:	e8 08 00 00 00       	call   800345 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800340:	5b                   	pop    %ebx
  800341:	5e                   	pop    %esi
  800342:	5f                   	pop    %edi
  800343:	5d                   	pop    %ebp
  800344:	c3                   	ret    

00800345 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	56                   	push   %esi
  800349:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80034a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80034d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800353:	e8 00 fe ff ff       	call   800158 <sys_getenvid>
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	ff 75 0c             	pushl  0xc(%ebp)
  80035e:	ff 75 08             	pushl  0x8(%ebp)
  800361:	56                   	push   %esi
  800362:	50                   	push   %eax
  800363:	68 38 10 80 00       	push   $0x801038
  800368:	e8 b1 00 00 00       	call   80041e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036d:	83 c4 18             	add    $0x18,%esp
  800370:	53                   	push   %ebx
  800371:	ff 75 10             	pushl  0x10(%ebp)
  800374:	e8 54 00 00 00       	call   8003cd <vcprintf>
	cprintf("\n");
  800379:	c7 04 24 5c 10 80 00 	movl   $0x80105c,(%esp)
  800380:	e8 99 00 00 00       	call   80041e <cprintf>
  800385:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800388:	cc                   	int3   
  800389:	eb fd                	jmp    800388 <_panic+0x43>

0080038b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	53                   	push   %ebx
  80038f:	83 ec 04             	sub    $0x4,%esp
  800392:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800395:	8b 13                	mov    (%ebx),%edx
  800397:	8d 42 01             	lea    0x1(%edx),%eax
  80039a:	89 03                	mov    %eax,(%ebx)
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a8:	75 1a                	jne    8003c4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003aa:	83 ec 08             	sub    $0x8,%esp
  8003ad:	68 ff 00 00 00       	push   $0xff
  8003b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b5:	50                   	push   %eax
  8003b6:	e8 1f fd ff ff       	call   8000da <sys_cputs>
		b->idx = 0;
  8003bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003cb:	c9                   	leave  
  8003cc:	c3                   	ret    

008003cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003dd:	00 00 00 
	b.cnt = 0;
  8003e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ea:	ff 75 0c             	pushl  0xc(%ebp)
  8003ed:	ff 75 08             	pushl  0x8(%ebp)
  8003f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f6:	50                   	push   %eax
  8003f7:	68 8b 03 80 00       	push   $0x80038b
  8003fc:	e8 1a 01 00 00       	call   80051b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800401:	83 c4 08             	add    $0x8,%esp
  800404:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80040a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800410:	50                   	push   %eax
  800411:	e8 c4 fc ff ff       	call   8000da <sys_cputs>

	return b.cnt;
}
  800416:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041c:	c9                   	leave  
  80041d:	c3                   	ret    

0080041e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800424:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800427:	50                   	push   %eax
  800428:	ff 75 08             	pushl  0x8(%ebp)
  80042b:	e8 9d ff ff ff       	call   8003cd <vcprintf>
	va_end(ap);

	return cnt;
}
  800430:	c9                   	leave  
  800431:	c3                   	ret    

00800432 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	57                   	push   %edi
  800436:	56                   	push   %esi
  800437:	53                   	push   %ebx
  800438:	83 ec 1c             	sub    $0x1c,%esp
  80043b:	89 c7                	mov    %eax,%edi
  80043d:	89 d6                	mov    %edx,%esi
  80043f:	8b 45 08             	mov    0x8(%ebp),%eax
  800442:	8b 55 0c             	mov    0xc(%ebp),%edx
  800445:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800448:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80044b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80044e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800453:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800456:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800459:	39 d3                	cmp    %edx,%ebx
  80045b:	72 05                	jb     800462 <printnum+0x30>
  80045d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800460:	77 45                	ja     8004a7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800462:	83 ec 0c             	sub    $0xc,%esp
  800465:	ff 75 18             	pushl  0x18(%ebp)
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80046e:	53                   	push   %ebx
  80046f:	ff 75 10             	pushl  0x10(%ebp)
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	ff 75 e4             	pushl  -0x1c(%ebp)
  800478:	ff 75 e0             	pushl  -0x20(%ebp)
  80047b:	ff 75 dc             	pushl  -0x24(%ebp)
  80047e:	ff 75 d8             	pushl  -0x28(%ebp)
  800481:	e8 ea 08 00 00       	call   800d70 <__udivdi3>
  800486:	83 c4 18             	add    $0x18,%esp
  800489:	52                   	push   %edx
  80048a:	50                   	push   %eax
  80048b:	89 f2                	mov    %esi,%edx
  80048d:	89 f8                	mov    %edi,%eax
  80048f:	e8 9e ff ff ff       	call   800432 <printnum>
  800494:	83 c4 20             	add    $0x20,%esp
  800497:	eb 18                	jmp    8004b1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800499:	83 ec 08             	sub    $0x8,%esp
  80049c:	56                   	push   %esi
  80049d:	ff 75 18             	pushl  0x18(%ebp)
  8004a0:	ff d7                	call   *%edi
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	eb 03                	jmp    8004aa <printnum+0x78>
  8004a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004aa:	83 eb 01             	sub    $0x1,%ebx
  8004ad:	85 db                	test   %ebx,%ebx
  8004af:	7f e8                	jg     800499 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	83 ec 04             	sub    $0x4,%esp
  8004b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004be:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c4:	e8 d7 09 00 00       	call   800ea0 <__umoddi3>
  8004c9:	83 c4 14             	add    $0x14,%esp
  8004cc:	0f be 80 5e 10 80 00 	movsbl 0x80105e(%eax),%eax
  8004d3:	50                   	push   %eax
  8004d4:	ff d7                	call   *%edi
}
  8004d6:	83 c4 10             	add    $0x10,%esp
  8004d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004dc:	5b                   	pop    %ebx
  8004dd:	5e                   	pop    %esi
  8004de:	5f                   	pop    %edi
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  8004e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004eb:	8b 10                	mov    (%eax),%edx
  8004ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f0:	73 0a                	jae    8004fc <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f5:	89 08                	mov    %ecx,(%eax)
  8004f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fa:	88 02                	mov    %al,(%edx)
}
  8004fc:	5d                   	pop    %ebp
  8004fd:	c3                   	ret    

008004fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800504:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800507:	50                   	push   %eax
  800508:	ff 75 10             	pushl  0x10(%ebp)
  80050b:	ff 75 0c             	pushl  0xc(%ebp)
  80050e:	ff 75 08             	pushl  0x8(%ebp)
  800511:	e8 05 00 00 00       	call   80051b <vprintfmt>
	va_end(ap);
}
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	c9                   	leave  
  80051a:	c3                   	ret    

0080051b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051b:	55                   	push   %ebp
  80051c:	89 e5                	mov    %esp,%ebp
  80051e:	57                   	push   %edi
  80051f:	56                   	push   %esi
  800520:	53                   	push   %ebx
  800521:	83 ec 2c             	sub    $0x2c,%esp
  800524:	8b 75 08             	mov    0x8(%ebp),%esi
  800527:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80052d:	eb 12                	jmp    800541 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80052f:	85 c0                	test   %eax,%eax
  800531:	0f 84 42 04 00 00    	je     800979 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	53                   	push   %ebx
  80053b:	50                   	push   %eax
  80053c:	ff d6                	call   *%esi
  80053e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800541:	83 c7 01             	add    $0x1,%edi
  800544:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800548:	83 f8 25             	cmp    $0x25,%eax
  80054b:	75 e2                	jne    80052f <vprintfmt+0x14>
  80054d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800551:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800558:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80055f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800566:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056b:	eb 07                	jmp    800574 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800570:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8d 47 01             	lea    0x1(%edi),%eax
  800577:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057a:	0f b6 07             	movzbl (%edi),%eax
  80057d:	0f b6 d0             	movzbl %al,%edx
  800580:	83 e8 23             	sub    $0x23,%eax
  800583:	3c 55                	cmp    $0x55,%al
  800585:	0f 87 d3 03 00 00    	ja     80095e <vprintfmt+0x443>
  80058b:	0f b6 c0             	movzbl %al,%eax
  80058e:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  800595:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800598:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80059c:	eb d6                	jmp    800574 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ac:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005b0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005b3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005b6:	83 f9 09             	cmp    $0x9,%ecx
  8005b9:	77 3f                	ja     8005fa <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005bb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005be:	eb e9                	jmp    8005a9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8b 00                	mov    (%eax),%eax
  8005c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d4:	eb 2a                	jmp    800600 <vprintfmt+0xe5>
  8005d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e0:	0f 49 d0             	cmovns %eax,%edx
  8005e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e9:	eb 89                	jmp    800574 <vprintfmt+0x59>
  8005eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ee:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f5:	e9 7a ff ff ff       	jmp    800574 <vprintfmt+0x59>
  8005fa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005fd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800600:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800604:	0f 89 6a ff ff ff    	jns    800574 <vprintfmt+0x59>
				width = precision, precision = -1;
  80060a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80060d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800610:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800617:	e9 58 ff ff ff       	jmp    800574 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061c:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800622:	e9 4d ff ff ff       	jmp    800574 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8d 78 04             	lea    0x4(%eax),%edi
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	ff 30                	pushl  (%eax)
  800633:	ff d6                	call   *%esi
			break;
  800635:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800638:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063e:	e9 fe fe ff ff       	jmp    800541 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 78 04             	lea    0x4(%eax),%edi
  800649:	8b 00                	mov    (%eax),%eax
  80064b:	99                   	cltd   
  80064c:	31 d0                	xor    %edx,%eax
  80064e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800650:	83 f8 08             	cmp    $0x8,%eax
  800653:	7f 0b                	jg     800660 <vprintfmt+0x145>
  800655:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  80065c:	85 d2                	test   %edx,%edx
  80065e:	75 1b                	jne    80067b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800660:	50                   	push   %eax
  800661:	68 76 10 80 00       	push   $0x801076
  800666:	53                   	push   %ebx
  800667:	56                   	push   %esi
  800668:	e8 91 fe ff ff       	call   8004fe <printfmt>
  80066d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800670:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800676:	e9 c6 fe ff ff       	jmp    800541 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067b:	52                   	push   %edx
  80067c:	68 7f 10 80 00       	push   $0x80107f
  800681:	53                   	push   %ebx
  800682:	56                   	push   %esi
  800683:	e8 76 fe ff ff       	call   8004fe <printfmt>
  800688:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80068b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800691:	e9 ab fe ff ff       	jmp    800541 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	83 c0 04             	add    $0x4,%eax
  80069c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006a4:	85 ff                	test   %edi,%edi
  8006a6:	b8 6f 10 80 00       	mov    $0x80106f,%eax
  8006ab:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b2:	0f 8e 94 00 00 00    	jle    80074c <vprintfmt+0x231>
  8006b8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006bc:	0f 84 98 00 00 00    	je     80075a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c8:	57                   	push   %edi
  8006c9:	e8 33 03 00 00       	call   800a01 <strnlen>
  8006ce:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006d1:	29 c1                	sub    %eax,%ecx
  8006d3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006d6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006e3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e5:	eb 0f                	jmp    8006f6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	53                   	push   %ebx
  8006eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f0:	83 ef 01             	sub    $0x1,%edi
  8006f3:	83 c4 10             	add    $0x10,%esp
  8006f6:	85 ff                	test   %edi,%edi
  8006f8:	7f ed                	jg     8006e7 <vprintfmt+0x1cc>
  8006fa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006fd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800700:	85 c9                	test   %ecx,%ecx
  800702:	b8 00 00 00 00       	mov    $0x0,%eax
  800707:	0f 49 c1             	cmovns %ecx,%eax
  80070a:	29 c1                	sub    %eax,%ecx
  80070c:	89 75 08             	mov    %esi,0x8(%ebp)
  80070f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800712:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800715:	89 cb                	mov    %ecx,%ebx
  800717:	eb 4d                	jmp    800766 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800719:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071d:	74 1b                	je     80073a <vprintfmt+0x21f>
  80071f:	0f be c0             	movsbl %al,%eax
  800722:	83 e8 20             	sub    $0x20,%eax
  800725:	83 f8 5e             	cmp    $0x5e,%eax
  800728:	76 10                	jbe    80073a <vprintfmt+0x21f>
					putch('?', putdat);
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	6a 3f                	push   $0x3f
  800732:	ff 55 08             	call   *0x8(%ebp)
  800735:	83 c4 10             	add    $0x10,%esp
  800738:	eb 0d                	jmp    800747 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	52                   	push   %edx
  800741:	ff 55 08             	call   *0x8(%ebp)
  800744:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800747:	83 eb 01             	sub    $0x1,%ebx
  80074a:	eb 1a                	jmp    800766 <vprintfmt+0x24b>
  80074c:	89 75 08             	mov    %esi,0x8(%ebp)
  80074f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800752:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800755:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800758:	eb 0c                	jmp    800766 <vprintfmt+0x24b>
  80075a:	89 75 08             	mov    %esi,0x8(%ebp)
  80075d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800760:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800763:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800766:	83 c7 01             	add    $0x1,%edi
  800769:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80076d:	0f be d0             	movsbl %al,%edx
  800770:	85 d2                	test   %edx,%edx
  800772:	74 23                	je     800797 <vprintfmt+0x27c>
  800774:	85 f6                	test   %esi,%esi
  800776:	78 a1                	js     800719 <vprintfmt+0x1fe>
  800778:	83 ee 01             	sub    $0x1,%esi
  80077b:	79 9c                	jns    800719 <vprintfmt+0x1fe>
  80077d:	89 df                	mov    %ebx,%edi
  80077f:	8b 75 08             	mov    0x8(%ebp),%esi
  800782:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800785:	eb 18                	jmp    80079f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800787:	83 ec 08             	sub    $0x8,%esp
  80078a:	53                   	push   %ebx
  80078b:	6a 20                	push   $0x20
  80078d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078f:	83 ef 01             	sub    $0x1,%edi
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	eb 08                	jmp    80079f <vprintfmt+0x284>
  800797:	89 df                	mov    %ebx,%edi
  800799:	8b 75 08             	mov    0x8(%ebp),%esi
  80079c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079f:	85 ff                	test   %edi,%edi
  8007a1:	7f e4                	jg     800787 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007a3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007a6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ac:	e9 90 fd ff ff       	jmp    800541 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b1:	83 f9 01             	cmp    $0x1,%ecx
  8007b4:	7e 19                	jle    8007cf <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8b 50 04             	mov    0x4(%eax),%edx
  8007bc:	8b 00                	mov    (%eax),%eax
  8007be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8d 40 08             	lea    0x8(%eax),%eax
  8007ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8007cd:	eb 38                	jmp    800807 <vprintfmt+0x2ec>
	else if (lflag)
  8007cf:	85 c9                	test   %ecx,%ecx
  8007d1:	74 1b                	je     8007ee <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8b 00                	mov    (%eax),%eax
  8007d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007db:	89 c1                	mov    %eax,%ecx
  8007dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8d 40 04             	lea    0x4(%eax),%eax
  8007e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ec:	eb 19                	jmp    800807 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f1:	8b 00                	mov    (%eax),%eax
  8007f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f6:	89 c1                	mov    %eax,%ecx
  8007f8:	c1 f9 1f             	sar    $0x1f,%ecx
  8007fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800801:	8d 40 04             	lea    0x4(%eax),%eax
  800804:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800807:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80080a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80080d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800812:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800816:	0f 89 0e 01 00 00    	jns    80092a <vprintfmt+0x40f>
				putch('-', putdat);
  80081c:	83 ec 08             	sub    $0x8,%esp
  80081f:	53                   	push   %ebx
  800820:	6a 2d                	push   $0x2d
  800822:	ff d6                	call   *%esi
				num = -(long long) num;
  800824:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800827:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80082a:	f7 da                	neg    %edx
  80082c:	83 d1 00             	adc    $0x0,%ecx
  80082f:	f7 d9                	neg    %ecx
  800831:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800834:	b8 0a 00 00 00       	mov    $0xa,%eax
  800839:	e9 ec 00 00 00       	jmp    80092a <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80083e:	83 f9 01             	cmp    $0x1,%ecx
  800841:	7e 18                	jle    80085b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800843:	8b 45 14             	mov    0x14(%ebp),%eax
  800846:	8b 10                	mov    (%eax),%edx
  800848:	8b 48 04             	mov    0x4(%eax),%ecx
  80084b:	8d 40 08             	lea    0x8(%eax),%eax
  80084e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800851:	b8 0a 00 00 00       	mov    $0xa,%eax
  800856:	e9 cf 00 00 00       	jmp    80092a <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80085b:	85 c9                	test   %ecx,%ecx
  80085d:	74 1a                	je     800879 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8b 10                	mov    (%eax),%edx
  800864:	b9 00 00 00 00       	mov    $0x0,%ecx
  800869:	8d 40 04             	lea    0x4(%eax),%eax
  80086c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80086f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800874:	e9 b1 00 00 00       	jmp    80092a <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800879:	8b 45 14             	mov    0x14(%ebp),%eax
  80087c:	8b 10                	mov    (%eax),%edx
  80087e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800883:	8d 40 04             	lea    0x4(%eax),%eax
  800886:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800889:	b8 0a 00 00 00       	mov    $0xa,%eax
  80088e:	e9 97 00 00 00       	jmp    80092a <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800893:	83 ec 08             	sub    $0x8,%esp
  800896:	53                   	push   %ebx
  800897:	6a 58                	push   $0x58
  800899:	ff d6                	call   *%esi
			putch('X', putdat);
  80089b:	83 c4 08             	add    $0x8,%esp
  80089e:	53                   	push   %ebx
  80089f:	6a 58                	push   $0x58
  8008a1:	ff d6                	call   *%esi
			putch('X', putdat);
  8008a3:	83 c4 08             	add    $0x8,%esp
  8008a6:	53                   	push   %ebx
  8008a7:	6a 58                	push   $0x58
  8008a9:	ff d6                	call   *%esi
			break;
  8008ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008b1:	e9 8b fc ff ff       	jmp    800541 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8008b6:	83 ec 08             	sub    $0x8,%esp
  8008b9:	53                   	push   %ebx
  8008ba:	6a 30                	push   $0x30
  8008bc:	ff d6                	call   *%esi
			putch('x', putdat);
  8008be:	83 c4 08             	add    $0x8,%esp
  8008c1:	53                   	push   %ebx
  8008c2:	6a 78                	push   $0x78
  8008c4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c9:	8b 10                	mov    (%eax),%edx
  8008cb:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008d0:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008d3:	8d 40 04             	lea    0x4(%eax),%eax
  8008d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008d9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008de:	eb 4a                	jmp    80092a <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008e0:	83 f9 01             	cmp    $0x1,%ecx
  8008e3:	7e 15                	jle    8008fa <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e8:	8b 10                	mov    (%eax),%edx
  8008ea:	8b 48 04             	mov    0x4(%eax),%ecx
  8008ed:	8d 40 08             	lea    0x8(%eax),%eax
  8008f0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008f3:	b8 10 00 00 00       	mov    $0x10,%eax
  8008f8:	eb 30                	jmp    80092a <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008fa:	85 c9                	test   %ecx,%ecx
  8008fc:	74 17                	je     800915 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800901:	8b 10                	mov    (%eax),%edx
  800903:	b9 00 00 00 00       	mov    $0x0,%ecx
  800908:	8d 40 04             	lea    0x4(%eax),%eax
  80090b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80090e:	b8 10 00 00 00       	mov    $0x10,%eax
  800913:	eb 15                	jmp    80092a <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800915:	8b 45 14             	mov    0x14(%ebp),%eax
  800918:	8b 10                	mov    (%eax),%edx
  80091a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091f:	8d 40 04             	lea    0x4(%eax),%eax
  800922:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800925:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80092a:	83 ec 0c             	sub    $0xc,%esp
  80092d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800931:	57                   	push   %edi
  800932:	ff 75 e0             	pushl  -0x20(%ebp)
  800935:	50                   	push   %eax
  800936:	51                   	push   %ecx
  800937:	52                   	push   %edx
  800938:	89 da                	mov    %ebx,%edx
  80093a:	89 f0                	mov    %esi,%eax
  80093c:	e8 f1 fa ff ff       	call   800432 <printnum>
			break;
  800941:	83 c4 20             	add    $0x20,%esp
  800944:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800947:	e9 f5 fb ff ff       	jmp    800541 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80094c:	83 ec 08             	sub    $0x8,%esp
  80094f:	53                   	push   %ebx
  800950:	52                   	push   %edx
  800951:	ff d6                	call   *%esi
			break;
  800953:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800956:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800959:	e9 e3 fb ff ff       	jmp    800541 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80095e:	83 ec 08             	sub    $0x8,%esp
  800961:	53                   	push   %ebx
  800962:	6a 25                	push   $0x25
  800964:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800966:	83 c4 10             	add    $0x10,%esp
  800969:	eb 03                	jmp    80096e <vprintfmt+0x453>
  80096b:	83 ef 01             	sub    $0x1,%edi
  80096e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800972:	75 f7                	jne    80096b <vprintfmt+0x450>
  800974:	e9 c8 fb ff ff       	jmp    800541 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800979:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5f                   	pop    %edi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    

00800981 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	83 ec 18             	sub    $0x18,%esp
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80098d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800990:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800994:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800997:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80099e:	85 c0                	test   %eax,%eax
  8009a0:	74 26                	je     8009c8 <vsnprintf+0x47>
  8009a2:	85 d2                	test   %edx,%edx
  8009a4:	7e 22                	jle    8009c8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a6:	ff 75 14             	pushl  0x14(%ebp)
  8009a9:	ff 75 10             	pushl  0x10(%ebp)
  8009ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009af:	50                   	push   %eax
  8009b0:	68 e1 04 80 00       	push   $0x8004e1
  8009b5:	e8 61 fb ff ff       	call   80051b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009bd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c3:	83 c4 10             	add    $0x10,%esp
  8009c6:	eb 05                	jmp    8009cd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    

008009cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009d5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d8:	50                   	push   %eax
  8009d9:	ff 75 10             	pushl  0x10(%ebp)
  8009dc:	ff 75 0c             	pushl  0xc(%ebp)
  8009df:	ff 75 08             	pushl  0x8(%ebp)
  8009e2:	e8 9a ff ff ff       	call   800981 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e7:	c9                   	leave  
  8009e8:	c3                   	ret    

008009e9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f4:	eb 03                	jmp    8009f9 <strlen+0x10>
		n++;
  8009f6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009fd:	75 f7                	jne    8009f6 <strlen+0xd>
		n++;
	return n;
}
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0f:	eb 03                	jmp    800a14 <strnlen+0x13>
		n++;
  800a11:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a14:	39 c2                	cmp    %eax,%edx
  800a16:	74 08                	je     800a20 <strnlen+0x1f>
  800a18:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a1c:	75 f3                	jne    800a11 <strnlen+0x10>
  800a1e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	53                   	push   %ebx
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a2c:	89 c2                	mov    %eax,%edx
  800a2e:	83 c2 01             	add    $0x1,%edx
  800a31:	83 c1 01             	add    $0x1,%ecx
  800a34:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a38:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a3b:	84 db                	test   %bl,%bl
  800a3d:	75 ef                	jne    800a2e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a3f:	5b                   	pop    %ebx
  800a40:	5d                   	pop    %ebp
  800a41:	c3                   	ret    

00800a42 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	53                   	push   %ebx
  800a46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a49:	53                   	push   %ebx
  800a4a:	e8 9a ff ff ff       	call   8009e9 <strlen>
  800a4f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a52:	ff 75 0c             	pushl  0xc(%ebp)
  800a55:	01 d8                	add    %ebx,%eax
  800a57:	50                   	push   %eax
  800a58:	e8 c5 ff ff ff       	call   800a22 <strcpy>
	return dst;
}
  800a5d:	89 d8                	mov    %ebx,%eax
  800a5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6f:	89 f3                	mov    %esi,%ebx
  800a71:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a74:	89 f2                	mov    %esi,%edx
  800a76:	eb 0f                	jmp    800a87 <strncpy+0x23>
		*dst++ = *src;
  800a78:	83 c2 01             	add    $0x1,%edx
  800a7b:	0f b6 01             	movzbl (%ecx),%eax
  800a7e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a81:	80 39 01             	cmpb   $0x1,(%ecx)
  800a84:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a87:	39 da                	cmp    %ebx,%edx
  800a89:	75 ed                	jne    800a78 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a8b:	89 f0                	mov    %esi,%eax
  800a8d:	5b                   	pop    %ebx
  800a8e:	5e                   	pop    %esi
  800a8f:	5d                   	pop    %ebp
  800a90:	c3                   	ret    

00800a91 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a91:	55                   	push   %ebp
  800a92:	89 e5                	mov    %esp,%ebp
  800a94:	56                   	push   %esi
  800a95:	53                   	push   %ebx
  800a96:	8b 75 08             	mov    0x8(%ebp),%esi
  800a99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9c:	8b 55 10             	mov    0x10(%ebp),%edx
  800a9f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa1:	85 d2                	test   %edx,%edx
  800aa3:	74 21                	je     800ac6 <strlcpy+0x35>
  800aa5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aa9:	89 f2                	mov    %esi,%edx
  800aab:	eb 09                	jmp    800ab6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aad:	83 c2 01             	add    $0x1,%edx
  800ab0:	83 c1 01             	add    $0x1,%ecx
  800ab3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ab6:	39 c2                	cmp    %eax,%edx
  800ab8:	74 09                	je     800ac3 <strlcpy+0x32>
  800aba:	0f b6 19             	movzbl (%ecx),%ebx
  800abd:	84 db                	test   %bl,%bl
  800abf:	75 ec                	jne    800aad <strlcpy+0x1c>
  800ac1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ac3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ac6:	29 f0                	sub    %esi,%eax
}
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ad5:	eb 06                	jmp    800add <strcmp+0x11>
		p++, q++;
  800ad7:	83 c1 01             	add    $0x1,%ecx
  800ada:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800add:	0f b6 01             	movzbl (%ecx),%eax
  800ae0:	84 c0                	test   %al,%al
  800ae2:	74 04                	je     800ae8 <strcmp+0x1c>
  800ae4:	3a 02                	cmp    (%edx),%al
  800ae6:	74 ef                	je     800ad7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae8:	0f b6 c0             	movzbl %al,%eax
  800aeb:	0f b6 12             	movzbl (%edx),%edx
  800aee:	29 d0                	sub    %edx,%eax
}
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	53                   	push   %ebx
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afc:	89 c3                	mov    %eax,%ebx
  800afe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b01:	eb 06                	jmp    800b09 <strncmp+0x17>
		n--, p++, q++;
  800b03:	83 c0 01             	add    $0x1,%eax
  800b06:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b09:	39 d8                	cmp    %ebx,%eax
  800b0b:	74 15                	je     800b22 <strncmp+0x30>
  800b0d:	0f b6 08             	movzbl (%eax),%ecx
  800b10:	84 c9                	test   %cl,%cl
  800b12:	74 04                	je     800b18 <strncmp+0x26>
  800b14:	3a 0a                	cmp    (%edx),%cl
  800b16:	74 eb                	je     800b03 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b18:	0f b6 00             	movzbl (%eax),%eax
  800b1b:	0f b6 12             	movzbl (%edx),%edx
  800b1e:	29 d0                	sub    %edx,%eax
  800b20:	eb 05                	jmp    800b27 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b22:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b27:	5b                   	pop    %ebx
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    

00800b2a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b2a:	55                   	push   %ebp
  800b2b:	89 e5                	mov    %esp,%ebp
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b34:	eb 07                	jmp    800b3d <strchr+0x13>
		if (*s == c)
  800b36:	38 ca                	cmp    %cl,%dl
  800b38:	74 0f                	je     800b49 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b3a:	83 c0 01             	add    $0x1,%eax
  800b3d:	0f b6 10             	movzbl (%eax),%edx
  800b40:	84 d2                	test   %dl,%dl
  800b42:	75 f2                	jne    800b36 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b55:	eb 03                	jmp    800b5a <strfind+0xf>
  800b57:	83 c0 01             	add    $0x1,%eax
  800b5a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b5d:	38 ca                	cmp    %cl,%dl
  800b5f:	74 04                	je     800b65 <strfind+0x1a>
  800b61:	84 d2                	test   %dl,%dl
  800b63:	75 f2                	jne    800b57 <strfind+0xc>
			break;
	return (char *) s;
}
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b70:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b73:	85 c9                	test   %ecx,%ecx
  800b75:	74 36                	je     800bad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b77:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7d:	75 28                	jne    800ba7 <memset+0x40>
  800b7f:	f6 c1 03             	test   $0x3,%cl
  800b82:	75 23                	jne    800ba7 <memset+0x40>
		c &= 0xFF;
  800b84:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b88:	89 d3                	mov    %edx,%ebx
  800b8a:	c1 e3 08             	shl    $0x8,%ebx
  800b8d:	89 d6                	mov    %edx,%esi
  800b8f:	c1 e6 18             	shl    $0x18,%esi
  800b92:	89 d0                	mov    %edx,%eax
  800b94:	c1 e0 10             	shl    $0x10,%eax
  800b97:	09 f0                	or     %esi,%eax
  800b99:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b9b:	89 d8                	mov    %ebx,%eax
  800b9d:	09 d0                	or     %edx,%eax
  800b9f:	c1 e9 02             	shr    $0x2,%ecx
  800ba2:	fc                   	cld    
  800ba3:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba5:	eb 06                	jmp    800bad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800baa:	fc                   	cld    
  800bab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bad:	89 f8                	mov    %edi,%eax
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc2:	39 c6                	cmp    %eax,%esi
  800bc4:	73 35                	jae    800bfb <memmove+0x47>
  800bc6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc9:	39 d0                	cmp    %edx,%eax
  800bcb:	73 2e                	jae    800bfb <memmove+0x47>
		s += n;
		d += n;
  800bcd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	09 fe                	or     %edi,%esi
  800bd4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bda:	75 13                	jne    800bef <memmove+0x3b>
  800bdc:	f6 c1 03             	test   $0x3,%cl
  800bdf:	75 0e                	jne    800bef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800be1:	83 ef 04             	sub    $0x4,%edi
  800be4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be7:	c1 e9 02             	shr    $0x2,%ecx
  800bea:	fd                   	std    
  800beb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bed:	eb 09                	jmp    800bf8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bef:	83 ef 01             	sub    $0x1,%edi
  800bf2:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bf5:	fd                   	std    
  800bf6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf8:	fc                   	cld    
  800bf9:	eb 1d                	jmp    800c18 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfb:	89 f2                	mov    %esi,%edx
  800bfd:	09 c2                	or     %eax,%edx
  800bff:	f6 c2 03             	test   $0x3,%dl
  800c02:	75 0f                	jne    800c13 <memmove+0x5f>
  800c04:	f6 c1 03             	test   $0x3,%cl
  800c07:	75 0a                	jne    800c13 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c09:	c1 e9 02             	shr    $0x2,%ecx
  800c0c:	89 c7                	mov    %eax,%edi
  800c0e:	fc                   	cld    
  800c0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c11:	eb 05                	jmp    800c18 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c13:	89 c7                	mov    %eax,%edi
  800c15:	fc                   	cld    
  800c16:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    

00800c1c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c1c:	55                   	push   %ebp
  800c1d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c1f:	ff 75 10             	pushl  0x10(%ebp)
  800c22:	ff 75 0c             	pushl  0xc(%ebp)
  800c25:	ff 75 08             	pushl  0x8(%ebp)
  800c28:	e8 87 ff ff ff       	call   800bb4 <memmove>
}
  800c2d:	c9                   	leave  
  800c2e:	c3                   	ret    

00800c2f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	8b 45 08             	mov    0x8(%ebp),%eax
  800c37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3a:	89 c6                	mov    %eax,%esi
  800c3c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3f:	eb 1a                	jmp    800c5b <memcmp+0x2c>
		if (*s1 != *s2)
  800c41:	0f b6 08             	movzbl (%eax),%ecx
  800c44:	0f b6 1a             	movzbl (%edx),%ebx
  800c47:	38 d9                	cmp    %bl,%cl
  800c49:	74 0a                	je     800c55 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c4b:	0f b6 c1             	movzbl %cl,%eax
  800c4e:	0f b6 db             	movzbl %bl,%ebx
  800c51:	29 d8                	sub    %ebx,%eax
  800c53:	eb 0f                	jmp    800c64 <memcmp+0x35>
		s1++, s2++;
  800c55:	83 c0 01             	add    $0x1,%eax
  800c58:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5b:	39 f0                	cmp    %esi,%eax
  800c5d:	75 e2                	jne    800c41 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	53                   	push   %ebx
  800c6c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c6f:	89 c1                	mov    %eax,%ecx
  800c71:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c74:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c78:	eb 0a                	jmp    800c84 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c7a:	0f b6 10             	movzbl (%eax),%edx
  800c7d:	39 da                	cmp    %ebx,%edx
  800c7f:	74 07                	je     800c88 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c81:	83 c0 01             	add    $0x1,%eax
  800c84:	39 c8                	cmp    %ecx,%eax
  800c86:	72 f2                	jb     800c7a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c88:	5b                   	pop    %ebx
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c97:	eb 03                	jmp    800c9c <strtol+0x11>
		s++;
  800c99:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9c:	0f b6 01             	movzbl (%ecx),%eax
  800c9f:	3c 20                	cmp    $0x20,%al
  800ca1:	74 f6                	je     800c99 <strtol+0xe>
  800ca3:	3c 09                	cmp    $0x9,%al
  800ca5:	74 f2                	je     800c99 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca7:	3c 2b                	cmp    $0x2b,%al
  800ca9:	75 0a                	jne    800cb5 <strtol+0x2a>
		s++;
  800cab:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cae:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb3:	eb 11                	jmp    800cc6 <strtol+0x3b>
  800cb5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cba:	3c 2d                	cmp    $0x2d,%al
  800cbc:	75 08                	jne    800cc6 <strtol+0x3b>
		s++, neg = 1;
  800cbe:	83 c1 01             	add    $0x1,%ecx
  800cc1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ccc:	75 15                	jne    800ce3 <strtol+0x58>
  800cce:	80 39 30             	cmpb   $0x30,(%ecx)
  800cd1:	75 10                	jne    800ce3 <strtol+0x58>
  800cd3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd7:	75 7c                	jne    800d55 <strtol+0xca>
		s += 2, base = 16;
  800cd9:	83 c1 02             	add    $0x2,%ecx
  800cdc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce1:	eb 16                	jmp    800cf9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ce3:	85 db                	test   %ebx,%ebx
  800ce5:	75 12                	jne    800cf9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ce7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cec:	80 39 30             	cmpb   $0x30,(%ecx)
  800cef:	75 08                	jne    800cf9 <strtol+0x6e>
		s++, base = 8;
  800cf1:	83 c1 01             	add    $0x1,%ecx
  800cf4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cf9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfe:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d01:	0f b6 11             	movzbl (%ecx),%edx
  800d04:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d07:	89 f3                	mov    %esi,%ebx
  800d09:	80 fb 09             	cmp    $0x9,%bl
  800d0c:	77 08                	ja     800d16 <strtol+0x8b>
			dig = *s - '0';
  800d0e:	0f be d2             	movsbl %dl,%edx
  800d11:	83 ea 30             	sub    $0x30,%edx
  800d14:	eb 22                	jmp    800d38 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d16:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d19:	89 f3                	mov    %esi,%ebx
  800d1b:	80 fb 19             	cmp    $0x19,%bl
  800d1e:	77 08                	ja     800d28 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d20:	0f be d2             	movsbl %dl,%edx
  800d23:	83 ea 57             	sub    $0x57,%edx
  800d26:	eb 10                	jmp    800d38 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d28:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d2b:	89 f3                	mov    %esi,%ebx
  800d2d:	80 fb 19             	cmp    $0x19,%bl
  800d30:	77 16                	ja     800d48 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d32:	0f be d2             	movsbl %dl,%edx
  800d35:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d38:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d3b:	7d 0b                	jge    800d48 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d3d:	83 c1 01             	add    $0x1,%ecx
  800d40:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d44:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d46:	eb b9                	jmp    800d01 <strtol+0x76>

	if (endptr)
  800d48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d4c:	74 0d                	je     800d5b <strtol+0xd0>
		*endptr = (char *) s;
  800d4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d51:	89 0e                	mov    %ecx,(%esi)
  800d53:	eb 06                	jmp    800d5b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d55:	85 db                	test   %ebx,%ebx
  800d57:	74 98                	je     800cf1 <strtol+0x66>
  800d59:	eb 9e                	jmp    800cf9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d5b:	89 c2                	mov    %eax,%edx
  800d5d:	f7 da                	neg    %edx
  800d5f:	85 ff                	test   %edi,%edi
  800d61:	0f 45 c2             	cmovne %edx,%eax
}
  800d64:	5b                   	pop    %ebx
  800d65:	5e                   	pop    %esi
  800d66:	5f                   	pop    %edi
  800d67:	5d                   	pop    %ebp
  800d68:	c3                   	ret    
  800d69:	66 90                	xchg   %ax,%ax
  800d6b:	66 90                	xchg   %ax,%ax
  800d6d:	66 90                	xchg   %ax,%ax
  800d6f:	90                   	nop

00800d70 <__udivdi3>:
  800d70:	55                   	push   %ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 1c             	sub    $0x1c,%esp
  800d77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d87:	85 f6                	test   %esi,%esi
  800d89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d8d:	89 ca                	mov    %ecx,%edx
  800d8f:	89 f8                	mov    %edi,%eax
  800d91:	75 3d                	jne    800dd0 <__udivdi3+0x60>
  800d93:	39 cf                	cmp    %ecx,%edi
  800d95:	0f 87 c5 00 00 00    	ja     800e60 <__udivdi3+0xf0>
  800d9b:	85 ff                	test   %edi,%edi
  800d9d:	89 fd                	mov    %edi,%ebp
  800d9f:	75 0b                	jne    800dac <__udivdi3+0x3c>
  800da1:	b8 01 00 00 00       	mov    $0x1,%eax
  800da6:	31 d2                	xor    %edx,%edx
  800da8:	f7 f7                	div    %edi
  800daa:	89 c5                	mov    %eax,%ebp
  800dac:	89 c8                	mov    %ecx,%eax
  800dae:	31 d2                	xor    %edx,%edx
  800db0:	f7 f5                	div    %ebp
  800db2:	89 c1                	mov    %eax,%ecx
  800db4:	89 d8                	mov    %ebx,%eax
  800db6:	89 cf                	mov    %ecx,%edi
  800db8:	f7 f5                	div    %ebp
  800dba:	89 c3                	mov    %eax,%ebx
  800dbc:	89 d8                	mov    %ebx,%eax
  800dbe:	89 fa                	mov    %edi,%edx
  800dc0:	83 c4 1c             	add    $0x1c,%esp
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    
  800dc8:	90                   	nop
  800dc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dd0:	39 ce                	cmp    %ecx,%esi
  800dd2:	77 74                	ja     800e48 <__udivdi3+0xd8>
  800dd4:	0f bd fe             	bsr    %esi,%edi
  800dd7:	83 f7 1f             	xor    $0x1f,%edi
  800dda:	0f 84 98 00 00 00    	je     800e78 <__udivdi3+0x108>
  800de0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800de5:	89 f9                	mov    %edi,%ecx
  800de7:	89 c5                	mov    %eax,%ebp
  800de9:	29 fb                	sub    %edi,%ebx
  800deb:	d3 e6                	shl    %cl,%esi
  800ded:	89 d9                	mov    %ebx,%ecx
  800def:	d3 ed                	shr    %cl,%ebp
  800df1:	89 f9                	mov    %edi,%ecx
  800df3:	d3 e0                	shl    %cl,%eax
  800df5:	09 ee                	or     %ebp,%esi
  800df7:	89 d9                	mov    %ebx,%ecx
  800df9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dfd:	89 d5                	mov    %edx,%ebp
  800dff:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e03:	d3 ed                	shr    %cl,%ebp
  800e05:	89 f9                	mov    %edi,%ecx
  800e07:	d3 e2                	shl    %cl,%edx
  800e09:	89 d9                	mov    %ebx,%ecx
  800e0b:	d3 e8                	shr    %cl,%eax
  800e0d:	09 c2                	or     %eax,%edx
  800e0f:	89 d0                	mov    %edx,%eax
  800e11:	89 ea                	mov    %ebp,%edx
  800e13:	f7 f6                	div    %esi
  800e15:	89 d5                	mov    %edx,%ebp
  800e17:	89 c3                	mov    %eax,%ebx
  800e19:	f7 64 24 0c          	mull   0xc(%esp)
  800e1d:	39 d5                	cmp    %edx,%ebp
  800e1f:	72 10                	jb     800e31 <__udivdi3+0xc1>
  800e21:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e25:	89 f9                	mov    %edi,%ecx
  800e27:	d3 e6                	shl    %cl,%esi
  800e29:	39 c6                	cmp    %eax,%esi
  800e2b:	73 07                	jae    800e34 <__udivdi3+0xc4>
  800e2d:	39 d5                	cmp    %edx,%ebp
  800e2f:	75 03                	jne    800e34 <__udivdi3+0xc4>
  800e31:	83 eb 01             	sub    $0x1,%ebx
  800e34:	31 ff                	xor    %edi,%edi
  800e36:	89 d8                	mov    %ebx,%eax
  800e38:	89 fa                	mov    %edi,%edx
  800e3a:	83 c4 1c             	add    $0x1c,%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    
  800e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e48:	31 ff                	xor    %edi,%edi
  800e4a:	31 db                	xor    %ebx,%ebx
  800e4c:	89 d8                	mov    %ebx,%eax
  800e4e:	89 fa                	mov    %edi,%edx
  800e50:	83 c4 1c             	add    $0x1c,%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    
  800e58:	90                   	nop
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	89 d8                	mov    %ebx,%eax
  800e62:	f7 f7                	div    %edi
  800e64:	31 ff                	xor    %edi,%edi
  800e66:	89 c3                	mov    %eax,%ebx
  800e68:	89 d8                	mov    %ebx,%eax
  800e6a:	89 fa                	mov    %edi,%edx
  800e6c:	83 c4 1c             	add    $0x1c,%esp
  800e6f:	5b                   	pop    %ebx
  800e70:	5e                   	pop    %esi
  800e71:	5f                   	pop    %edi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    
  800e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e78:	39 ce                	cmp    %ecx,%esi
  800e7a:	72 0c                	jb     800e88 <__udivdi3+0x118>
  800e7c:	31 db                	xor    %ebx,%ebx
  800e7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e82:	0f 87 34 ff ff ff    	ja     800dbc <__udivdi3+0x4c>
  800e88:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e8d:	e9 2a ff ff ff       	jmp    800dbc <__udivdi3+0x4c>
  800e92:	66 90                	xchg   %ax,%ax
  800e94:	66 90                	xchg   %ax,%ax
  800e96:	66 90                	xchg   %ax,%ax
  800e98:	66 90                	xchg   %ax,%ax
  800e9a:	66 90                	xchg   %ax,%ax
  800e9c:	66 90                	xchg   %ax,%ax
  800e9e:	66 90                	xchg   %ax,%ax

00800ea0 <__umoddi3>:
  800ea0:	55                   	push   %ebp
  800ea1:	57                   	push   %edi
  800ea2:	56                   	push   %esi
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 1c             	sub    $0x1c,%esp
  800ea7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800eab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800eaf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800eb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800eb7:	85 d2                	test   %edx,%edx
  800eb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ebd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ec1:	89 f3                	mov    %esi,%ebx
  800ec3:	89 3c 24             	mov    %edi,(%esp)
  800ec6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eca:	75 1c                	jne    800ee8 <__umoddi3+0x48>
  800ecc:	39 f7                	cmp    %esi,%edi
  800ece:	76 50                	jbe    800f20 <__umoddi3+0x80>
  800ed0:	89 c8                	mov    %ecx,%eax
  800ed2:	89 f2                	mov    %esi,%edx
  800ed4:	f7 f7                	div    %edi
  800ed6:	89 d0                	mov    %edx,%eax
  800ed8:	31 d2                	xor    %edx,%edx
  800eda:	83 c4 1c             	add    $0x1c,%esp
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    
  800ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee8:	39 f2                	cmp    %esi,%edx
  800eea:	89 d0                	mov    %edx,%eax
  800eec:	77 52                	ja     800f40 <__umoddi3+0xa0>
  800eee:	0f bd ea             	bsr    %edx,%ebp
  800ef1:	83 f5 1f             	xor    $0x1f,%ebp
  800ef4:	75 5a                	jne    800f50 <__umoddi3+0xb0>
  800ef6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800efa:	0f 82 e0 00 00 00    	jb     800fe0 <__umoddi3+0x140>
  800f00:	39 0c 24             	cmp    %ecx,(%esp)
  800f03:	0f 86 d7 00 00 00    	jbe    800fe0 <__umoddi3+0x140>
  800f09:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f0d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f11:	83 c4 1c             	add    $0x1c,%esp
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5f                   	pop    %edi
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	85 ff                	test   %edi,%edi
  800f22:	89 fd                	mov    %edi,%ebp
  800f24:	75 0b                	jne    800f31 <__umoddi3+0x91>
  800f26:	b8 01 00 00 00       	mov    $0x1,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	f7 f7                	div    %edi
  800f2f:	89 c5                	mov    %eax,%ebp
  800f31:	89 f0                	mov    %esi,%eax
  800f33:	31 d2                	xor    %edx,%edx
  800f35:	f7 f5                	div    %ebp
  800f37:	89 c8                	mov    %ecx,%eax
  800f39:	f7 f5                	div    %ebp
  800f3b:	89 d0                	mov    %edx,%eax
  800f3d:	eb 99                	jmp    800ed8 <__umoddi3+0x38>
  800f3f:	90                   	nop
  800f40:	89 c8                	mov    %ecx,%eax
  800f42:	89 f2                	mov    %esi,%edx
  800f44:	83 c4 1c             	add    $0x1c,%esp
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    
  800f4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f50:	8b 34 24             	mov    (%esp),%esi
  800f53:	bf 20 00 00 00       	mov    $0x20,%edi
  800f58:	89 e9                	mov    %ebp,%ecx
  800f5a:	29 ef                	sub    %ebp,%edi
  800f5c:	d3 e0                	shl    %cl,%eax
  800f5e:	89 f9                	mov    %edi,%ecx
  800f60:	89 f2                	mov    %esi,%edx
  800f62:	d3 ea                	shr    %cl,%edx
  800f64:	89 e9                	mov    %ebp,%ecx
  800f66:	09 c2                	or     %eax,%edx
  800f68:	89 d8                	mov    %ebx,%eax
  800f6a:	89 14 24             	mov    %edx,(%esp)
  800f6d:	89 f2                	mov    %esi,%edx
  800f6f:	d3 e2                	shl    %cl,%edx
  800f71:	89 f9                	mov    %edi,%ecx
  800f73:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f77:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f7b:	d3 e8                	shr    %cl,%eax
  800f7d:	89 e9                	mov    %ebp,%ecx
  800f7f:	89 c6                	mov    %eax,%esi
  800f81:	d3 e3                	shl    %cl,%ebx
  800f83:	89 f9                	mov    %edi,%ecx
  800f85:	89 d0                	mov    %edx,%eax
  800f87:	d3 e8                	shr    %cl,%eax
  800f89:	89 e9                	mov    %ebp,%ecx
  800f8b:	09 d8                	or     %ebx,%eax
  800f8d:	89 d3                	mov    %edx,%ebx
  800f8f:	89 f2                	mov    %esi,%edx
  800f91:	f7 34 24             	divl   (%esp)
  800f94:	89 d6                	mov    %edx,%esi
  800f96:	d3 e3                	shl    %cl,%ebx
  800f98:	f7 64 24 04          	mull   0x4(%esp)
  800f9c:	39 d6                	cmp    %edx,%esi
  800f9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fa2:	89 d1                	mov    %edx,%ecx
  800fa4:	89 c3                	mov    %eax,%ebx
  800fa6:	72 08                	jb     800fb0 <__umoddi3+0x110>
  800fa8:	75 11                	jne    800fbb <__umoddi3+0x11b>
  800faa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fae:	73 0b                	jae    800fbb <__umoddi3+0x11b>
  800fb0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fb4:	1b 14 24             	sbb    (%esp),%edx
  800fb7:	89 d1                	mov    %edx,%ecx
  800fb9:	89 c3                	mov    %eax,%ebx
  800fbb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fbf:	29 da                	sub    %ebx,%edx
  800fc1:	19 ce                	sbb    %ecx,%esi
  800fc3:	89 f9                	mov    %edi,%ecx
  800fc5:	89 f0                	mov    %esi,%eax
  800fc7:	d3 e0                	shl    %cl,%eax
  800fc9:	89 e9                	mov    %ebp,%ecx
  800fcb:	d3 ea                	shr    %cl,%edx
  800fcd:	89 e9                	mov    %ebp,%ecx
  800fcf:	d3 ee                	shr    %cl,%esi
  800fd1:	09 d0                	or     %edx,%eax
  800fd3:	89 f2                	mov    %esi,%edx
  800fd5:	83 c4 1c             	add    $0x1c,%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    
  800fdd:	8d 76 00             	lea    0x0(%esi),%esi
  800fe0:	29 f9                	sub    %edi,%ecx
  800fe2:	19 d6                	sbb    %edx,%esi
  800fe4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fe8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fec:	e9 18 ff ff ff       	jmp    800f09 <__umoddi3+0x69>
