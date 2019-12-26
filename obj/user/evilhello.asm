
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
  800040:	e8 a5 00 00 00       	call   8000ea <sys_cputs>
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
  80004d:	57                   	push   %edi
  80004e:	56                   	push   %esi
  80004f:	53                   	push   %ebx
  800050:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800053:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80005a:	00 00 00 
	envid_t eid = sys_getenvid();
  80005d:	e8 06 01 00 00       	call   800168 <sys_getenvid>
  800062:	8b 3d 04 20 80 00    	mov    0x802004,%edi
  800068:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80006d:	be 00 00 00 00       	mov    $0x0,%esi
	int i;
	for (i = 0; i < NENV; i++) {
  800072:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == eid) {
  800077:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80007a:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800080:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &(envs[i]);
  800083:	39 c8                	cmp    %ecx,%eax
  800085:	0f 44 fb             	cmove  %ebx,%edi
  800088:	b9 01 00 00 00       	mov    $0x1,%ecx
  80008d:	0f 44 f1             	cmove  %ecx,%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
	envid_t eid = sys_getenvid();
	int i;
	for (i = 0; i < NENV; i++) {
  800090:	83 c2 01             	add    $0x1,%edx
  800093:	83 c3 7c             	add    $0x7c,%ebx
  800096:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80009c:	75 d9                	jne    800077 <libmain+0x2d>
  80009e:	89 f0                	mov    %esi,%eax
  8000a0:	84 c0                	test   %al,%al
  8000a2:	74 06                	je     8000aa <libmain+0x60>
  8000a4:	89 3d 04 20 80 00    	mov    %edi,0x802004
			thisenv = &(envs[i]);
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000aa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000ae:	7e 0a                	jle    8000ba <libmain+0x70>
		binaryname = argv[0];
  8000b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000b3:	8b 00                	mov    (%eax),%eax
  8000b5:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	ff 75 0c             	pushl  0xc(%ebp)
  8000c0:	ff 75 08             	pushl  0x8(%ebp)
  8000c3:	e8 6b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c8:	e8 0b 00 00 00       	call   8000d8 <exit>
}
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d3:	5b                   	pop    %ebx
  8000d4:	5e                   	pop    %esi
  8000d5:	5f                   	pop    %edi
  8000d6:	5d                   	pop    %ebp
  8000d7:	c3                   	ret    

008000d8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000de:	6a 00                	push   $0x0
  8000e0:	e8 42 00 00 00       	call   800127 <sys_env_destroy>
}
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	c9                   	leave  
  8000e9:	c3                   	ret    

008000ea <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	89 c3                	mov    %eax,%ebx
  8000fd:	89 c7                	mov    %eax,%edi
  8000ff:	89 c6                	mov    %eax,%esi
  800101:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800103:	5b                   	pop    %ebx
  800104:	5e                   	pop    %esi
  800105:	5f                   	pop    %edi
  800106:	5d                   	pop    %ebp
  800107:	c3                   	ret    

00800108 <sys_cgetc>:

int
sys_cgetc(void)
{
  800108:	55                   	push   %ebp
  800109:	89 e5                	mov    %esp,%ebp
  80010b:	57                   	push   %edi
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010e:	ba 00 00 00 00       	mov    $0x0,%edx
  800113:	b8 01 00 00 00       	mov    $0x1,%eax
  800118:	89 d1                	mov    %edx,%ecx
  80011a:	89 d3                	mov    %edx,%ebx
  80011c:	89 d7                	mov    %edx,%edi
  80011e:	89 d6                	mov    %edx,%esi
  800120:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5f                   	pop    %edi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	57                   	push   %edi
  80012b:	56                   	push   %esi
  80012c:	53                   	push   %ebx
  80012d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800130:	b9 00 00 00 00       	mov    $0x0,%ecx
  800135:	b8 03 00 00 00       	mov    $0x3,%eax
  80013a:	8b 55 08             	mov    0x8(%ebp),%edx
  80013d:	89 cb                	mov    %ecx,%ebx
  80013f:	89 cf                	mov    %ecx,%edi
  800141:	89 ce                	mov    %ecx,%esi
  800143:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800145:	85 c0                	test   %eax,%eax
  800147:	7e 17                	jle    800160 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	50                   	push   %eax
  80014d:	6a 03                	push   $0x3
  80014f:	68 2a 10 80 00       	push   $0x80102a
  800154:	6a 23                	push   $0x23
  800156:	68 47 10 80 00       	push   $0x801047
  80015b:	e8 f5 01 00 00       	call   800355 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800160:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016e:	ba 00 00 00 00       	mov    $0x0,%edx
  800173:	b8 02 00 00 00       	mov    $0x2,%eax
  800178:	89 d1                	mov    %edx,%ecx
  80017a:	89 d3                	mov    %edx,%ebx
  80017c:	89 d7                	mov    %edx,%edi
  80017e:	89 d6                	mov    %edx,%esi
  800180:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800182:	5b                   	pop    %ebx
  800183:	5e                   	pop    %esi
  800184:	5f                   	pop    %edi
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    

00800187 <sys_yield>:

void
sys_yield(void)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018d:	ba 00 00 00 00       	mov    $0x0,%edx
  800192:	b8 0a 00 00 00       	mov    $0xa,%eax
  800197:	89 d1                	mov    %edx,%ecx
  800199:	89 d3                	mov    %edx,%ebx
  80019b:	89 d7                	mov    %edx,%edi
  80019d:	89 d6                	mov    %edx,%esi
  80019f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	be 00 00 00 00       	mov    $0x0,%esi
  8001b4:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	89 f7                	mov    %esi,%edi
  8001c4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c6:	85 c0                	test   %eax,%eax
  8001c8:	7e 17                	jle    8001e1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ca:	83 ec 0c             	sub    $0xc,%esp
  8001cd:	50                   	push   %eax
  8001ce:	6a 04                	push   $0x4
  8001d0:	68 2a 10 80 00       	push   $0x80102a
  8001d5:	6a 23                	push   $0x23
  8001d7:	68 47 10 80 00       	push   $0x801047
  8001dc:	e8 74 01 00 00       	call   800355 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e4:	5b                   	pop    %ebx
  8001e5:	5e                   	pop    %esi
  8001e6:	5f                   	pop    %edi
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    

008001e9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	57                   	push   %edi
  8001ed:	56                   	push   %esi
  8001ee:	53                   	push   %ebx
  8001ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800200:	8b 7d 14             	mov    0x14(%ebp),%edi
  800203:	8b 75 18             	mov    0x18(%ebp),%esi
  800206:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800208:	85 c0                	test   %eax,%eax
  80020a:	7e 17                	jle    800223 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020c:	83 ec 0c             	sub    $0xc,%esp
  80020f:	50                   	push   %eax
  800210:	6a 05                	push   $0x5
  800212:	68 2a 10 80 00       	push   $0x80102a
  800217:	6a 23                	push   $0x23
  800219:	68 47 10 80 00       	push   $0x801047
  80021e:	e8 32 01 00 00       	call   800355 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800223:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5f                   	pop    %edi
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	57                   	push   %edi
  80022f:	56                   	push   %esi
  800230:	53                   	push   %ebx
  800231:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800234:	bb 00 00 00 00       	mov    $0x0,%ebx
  800239:	b8 06 00 00 00       	mov    $0x6,%eax
  80023e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800241:	8b 55 08             	mov    0x8(%ebp),%edx
  800244:	89 df                	mov    %ebx,%edi
  800246:	89 de                	mov    %ebx,%esi
  800248:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024a:	85 c0                	test   %eax,%eax
  80024c:	7e 17                	jle    800265 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	50                   	push   %eax
  800252:	6a 06                	push   $0x6
  800254:	68 2a 10 80 00       	push   $0x80102a
  800259:	6a 23                	push   $0x23
  80025b:	68 47 10 80 00       	push   $0x801047
  800260:	e8 f0 00 00 00       	call   800355 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800265:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800268:	5b                   	pop    %ebx
  800269:	5e                   	pop    %esi
  80026a:	5f                   	pop    %edi
  80026b:	5d                   	pop    %ebp
  80026c:	c3                   	ret    

0080026d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	57                   	push   %edi
  800271:	56                   	push   %esi
  800272:	53                   	push   %ebx
  800273:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800276:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027b:	b8 08 00 00 00       	mov    $0x8,%eax
  800280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800283:	8b 55 08             	mov    0x8(%ebp),%edx
  800286:	89 df                	mov    %ebx,%edi
  800288:	89 de                	mov    %ebx,%esi
  80028a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028c:	85 c0                	test   %eax,%eax
  80028e:	7e 17                	jle    8002a7 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800290:	83 ec 0c             	sub    $0xc,%esp
  800293:	50                   	push   %eax
  800294:	6a 08                	push   $0x8
  800296:	68 2a 10 80 00       	push   $0x80102a
  80029b:	6a 23                	push   $0x23
  80029d:	68 47 10 80 00       	push   $0x801047
  8002a2:	e8 ae 00 00 00       	call   800355 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	57                   	push   %edi
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bd:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	89 df                	mov    %ebx,%edi
  8002ca:	89 de                	mov    %ebx,%esi
  8002cc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	7e 17                	jle    8002e9 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d2:	83 ec 0c             	sub    $0xc,%esp
  8002d5:	50                   	push   %eax
  8002d6:	6a 09                	push   $0x9
  8002d8:	68 2a 10 80 00       	push   $0x80102a
  8002dd:	6a 23                	push   $0x23
  8002df:	68 47 10 80 00       	push   $0x801047
  8002e4:	e8 6c 00 00 00       	call   800355 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ec:	5b                   	pop    %ebx
  8002ed:	5e                   	pop    %esi
  8002ee:	5f                   	pop    %edi
  8002ef:	5d                   	pop    %ebp
  8002f0:	c3                   	ret    

008002f1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	57                   	push   %edi
  8002f5:	56                   	push   %esi
  8002f6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f7:	be 00 00 00 00       	mov    $0x0,%esi
  8002fc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800301:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800304:	8b 55 08             	mov    0x8(%ebp),%edx
  800307:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030d:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030f:	5b                   	pop    %ebx
  800310:	5e                   	pop    %esi
  800311:	5f                   	pop    %edi
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	53                   	push   %ebx
  80031a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800322:	b8 0c 00 00 00       	mov    $0xc,%eax
  800327:	8b 55 08             	mov    0x8(%ebp),%edx
  80032a:	89 cb                	mov    %ecx,%ebx
  80032c:	89 cf                	mov    %ecx,%edi
  80032e:	89 ce                	mov    %ecx,%esi
  800330:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800332:	85 c0                	test   %eax,%eax
  800334:	7e 17                	jle    80034d <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800336:	83 ec 0c             	sub    $0xc,%esp
  800339:	50                   	push   %eax
  80033a:	6a 0c                	push   $0xc
  80033c:	68 2a 10 80 00       	push   $0x80102a
  800341:	6a 23                	push   $0x23
  800343:	68 47 10 80 00       	push   $0x801047
  800348:	e8 08 00 00 00       	call   800355 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800350:	5b                   	pop    %ebx
  800351:	5e                   	pop    %esi
  800352:	5f                   	pop    %edi
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80035a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80035d:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800363:	e8 00 fe ff ff       	call   800168 <sys_getenvid>
  800368:	83 ec 0c             	sub    $0xc,%esp
  80036b:	ff 75 0c             	pushl  0xc(%ebp)
  80036e:	ff 75 08             	pushl  0x8(%ebp)
  800371:	56                   	push   %esi
  800372:	50                   	push   %eax
  800373:	68 58 10 80 00       	push   $0x801058
  800378:	e8 b1 00 00 00       	call   80042e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80037d:	83 c4 18             	add    $0x18,%esp
  800380:	53                   	push   %ebx
  800381:	ff 75 10             	pushl  0x10(%ebp)
  800384:	e8 54 00 00 00       	call   8003dd <vcprintf>
	cprintf("\n");
  800389:	c7 04 24 7c 10 80 00 	movl   $0x80107c,(%esp)
  800390:	e8 99 00 00 00       	call   80042e <cprintf>
  800395:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800398:	cc                   	int3   
  800399:	eb fd                	jmp    800398 <_panic+0x43>

0080039b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	53                   	push   %ebx
  80039f:	83 ec 04             	sub    $0x4,%esp
  8003a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003a5:	8b 13                	mov    (%ebx),%edx
  8003a7:	8d 42 01             	lea    0x1(%edx),%eax
  8003aa:	89 03                	mov    %eax,(%ebx)
  8003ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003af:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003b3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b8:	75 1a                	jne    8003d4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003ba:	83 ec 08             	sub    $0x8,%esp
  8003bd:	68 ff 00 00 00       	push   $0xff
  8003c2:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c5:	50                   	push   %eax
  8003c6:	e8 1f fd ff ff       	call   8000ea <sys_cputs>
		b->idx = 0;
  8003cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003d4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003db:	c9                   	leave  
  8003dc:	c3                   	ret    

008003dd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003dd:	55                   	push   %ebp
  8003de:	89 e5                	mov    %esp,%ebp
  8003e0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ed:	00 00 00 
	b.cnt = 0;
  8003f0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003f7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003fa:	ff 75 0c             	pushl  0xc(%ebp)
  8003fd:	ff 75 08             	pushl  0x8(%ebp)
  800400:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800406:	50                   	push   %eax
  800407:	68 9b 03 80 00       	push   $0x80039b
  80040c:	e8 1a 01 00 00       	call   80052b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800411:	83 c4 08             	add    $0x8,%esp
  800414:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80041a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800420:	50                   	push   %eax
  800421:	e8 c4 fc ff ff       	call   8000ea <sys_cputs>

	return b.cnt;
}
  800426:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800434:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800437:	50                   	push   %eax
  800438:	ff 75 08             	pushl  0x8(%ebp)
  80043b:	e8 9d ff ff ff       	call   8003dd <vcprintf>
	va_end(ap);

	return cnt;
}
  800440:	c9                   	leave  
  800441:	c3                   	ret    

00800442 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	57                   	push   %edi
  800446:	56                   	push   %esi
  800447:	53                   	push   %ebx
  800448:	83 ec 1c             	sub    $0x1c,%esp
  80044b:	89 c7                	mov    %eax,%edi
  80044d:	89 d6                	mov    %edx,%esi
  80044f:	8b 45 08             	mov    0x8(%ebp),%eax
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800458:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80045b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80045e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800463:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800466:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800469:	39 d3                	cmp    %edx,%ebx
  80046b:	72 05                	jb     800472 <printnum+0x30>
  80046d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800470:	77 45                	ja     8004b7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800472:	83 ec 0c             	sub    $0xc,%esp
  800475:	ff 75 18             	pushl  0x18(%ebp)
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80047e:	53                   	push   %ebx
  80047f:	ff 75 10             	pushl  0x10(%ebp)
  800482:	83 ec 08             	sub    $0x8,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 ea 08 00 00       	call   800d80 <__udivdi3>
  800496:	83 c4 18             	add    $0x18,%esp
  800499:	52                   	push   %edx
  80049a:	50                   	push   %eax
  80049b:	89 f2                	mov    %esi,%edx
  80049d:	89 f8                	mov    %edi,%eax
  80049f:	e8 9e ff ff ff       	call   800442 <printnum>
  8004a4:	83 c4 20             	add    $0x20,%esp
  8004a7:	eb 18                	jmp    8004c1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	56                   	push   %esi
  8004ad:	ff 75 18             	pushl  0x18(%ebp)
  8004b0:	ff d7                	call   *%edi
  8004b2:	83 c4 10             	add    $0x10,%esp
  8004b5:	eb 03                	jmp    8004ba <printnum+0x78>
  8004b7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004ba:	83 eb 01             	sub    $0x1,%ebx
  8004bd:	85 db                	test   %ebx,%ebx
  8004bf:	7f e8                	jg     8004a9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	56                   	push   %esi
  8004c5:	83 ec 04             	sub    $0x4,%esp
  8004c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d4:	e8 d7 09 00 00       	call   800eb0 <__umoddi3>
  8004d9:	83 c4 14             	add    $0x14,%esp
  8004dc:	0f be 80 7e 10 80 00 	movsbl 0x80107e(%eax),%eax
  8004e3:	50                   	push   %eax
  8004e4:	ff d7                	call   *%edi
}
  8004e6:	83 c4 10             	add    $0x10,%esp
  8004e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004ec:	5b                   	pop    %ebx
  8004ed:	5e                   	pop    %esi
  8004ee:	5f                   	pop    %edi
  8004ef:	5d                   	pop    %ebp
  8004f0:	c3                   	ret    

008004f1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f1:	55                   	push   %ebp
  8004f2:	89 e5                	mov    %esp,%ebp
  8004f4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004fb:	8b 10                	mov    (%eax),%edx
  8004fd:	3b 50 04             	cmp    0x4(%eax),%edx
  800500:	73 0a                	jae    80050c <sprintputch+0x1b>
		*b->buf++ = ch;
  800502:	8d 4a 01             	lea    0x1(%edx),%ecx
  800505:	89 08                	mov    %ecx,(%eax)
  800507:	8b 45 08             	mov    0x8(%ebp),%eax
  80050a:	88 02                	mov    %al,(%edx)
}
  80050c:	5d                   	pop    %ebp
  80050d:	c3                   	ret    

0080050e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800514:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800517:	50                   	push   %eax
  800518:	ff 75 10             	pushl  0x10(%ebp)
  80051b:	ff 75 0c             	pushl  0xc(%ebp)
  80051e:	ff 75 08             	pushl  0x8(%ebp)
  800521:	e8 05 00 00 00       	call   80052b <vprintfmt>
	va_end(ap);
}
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	c9                   	leave  
  80052a:	c3                   	ret    

0080052b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
  80052e:	57                   	push   %edi
  80052f:	56                   	push   %esi
  800530:	53                   	push   %ebx
  800531:	83 ec 2c             	sub    $0x2c,%esp
  800534:	8b 75 08             	mov    0x8(%ebp),%esi
  800537:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80053d:	eb 12                	jmp    800551 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80053f:	85 c0                	test   %eax,%eax
  800541:	0f 84 42 04 00 00    	je     800989 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	53                   	push   %ebx
  80054b:	50                   	push   %eax
  80054c:	ff d6                	call   *%esi
  80054e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800551:	83 c7 01             	add    $0x1,%edi
  800554:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800558:	83 f8 25             	cmp    $0x25,%eax
  80055b:	75 e2                	jne    80053f <vprintfmt+0x14>
  80055d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800561:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800568:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80056f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800576:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057b:	eb 07                	jmp    800584 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800580:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8d 47 01             	lea    0x1(%edi),%eax
  800587:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058a:	0f b6 07             	movzbl (%edi),%eax
  80058d:	0f b6 d0             	movzbl %al,%edx
  800590:	83 e8 23             	sub    $0x23,%eax
  800593:	3c 55                	cmp    $0x55,%al
  800595:	0f 87 d3 03 00 00    	ja     80096e <vprintfmt+0x443>
  80059b:	0f b6 c0             	movzbl %al,%eax
  80059e:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  8005a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a8:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005ac:	eb d6                	jmp    800584 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005bc:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005c0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005c3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005c6:	83 f9 09             	cmp    $0x9,%ecx
  8005c9:	77 3f                	ja     80060a <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005cb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005ce:	eb e9                	jmp    8005b9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 00                	mov    (%eax),%eax
  8005d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005db:	8d 40 04             	lea    0x4(%eax),%eax
  8005de:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e4:	eb 2a                	jmp    800610 <vprintfmt+0xe5>
  8005e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e9:	85 c0                	test   %eax,%eax
  8005eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f0:	0f 49 d0             	cmovns %eax,%edx
  8005f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f9:	eb 89                	jmp    800584 <vprintfmt+0x59>
  8005fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005fe:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800605:	e9 7a ff ff ff       	jmp    800584 <vprintfmt+0x59>
  80060a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80060d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800610:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800614:	0f 89 6a ff ff ff    	jns    800584 <vprintfmt+0x59>
				width = precision, precision = -1;
  80061a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80061d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800620:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800627:	e9 58 ff ff ff       	jmp    800584 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80062c:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800632:	e9 4d ff ff ff       	jmp    800584 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800637:	8b 45 14             	mov    0x14(%ebp),%eax
  80063a:	8d 78 04             	lea    0x4(%eax),%edi
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	53                   	push   %ebx
  800641:	ff 30                	pushl  (%eax)
  800643:	ff d6                	call   *%esi
			break;
  800645:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800648:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80064e:	e9 fe fe ff ff       	jmp    800551 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8d 78 04             	lea    0x4(%eax),%edi
  800659:	8b 00                	mov    (%eax),%eax
  80065b:	99                   	cltd   
  80065c:	31 d0                	xor    %edx,%eax
  80065e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800660:	83 f8 08             	cmp    $0x8,%eax
  800663:	7f 0b                	jg     800670 <vprintfmt+0x145>
  800665:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  80066c:	85 d2                	test   %edx,%edx
  80066e:	75 1b                	jne    80068b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800670:	50                   	push   %eax
  800671:	68 96 10 80 00       	push   $0x801096
  800676:	53                   	push   %ebx
  800677:	56                   	push   %esi
  800678:	e8 91 fe ff ff       	call   80050e <printfmt>
  80067d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800680:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800683:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800686:	e9 c6 fe ff ff       	jmp    800551 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80068b:	52                   	push   %edx
  80068c:	68 9f 10 80 00       	push   $0x80109f
  800691:	53                   	push   %ebx
  800692:	56                   	push   %esi
  800693:	e8 76 fe ff ff       	call   80050e <printfmt>
  800698:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80069b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a1:	e9 ab fe ff ff       	jmp    800551 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	83 c0 04             	add    $0x4,%eax
  8006ac:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b4:	85 ff                	test   %edi,%edi
  8006b6:	b8 8f 10 80 00       	mov    $0x80108f,%eax
  8006bb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006be:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c2:	0f 8e 94 00 00 00    	jle    80075c <vprintfmt+0x231>
  8006c8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006cc:	0f 84 98 00 00 00    	je     80076a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d8:	57                   	push   %edi
  8006d9:	e8 33 03 00 00       	call   800a11 <strnlen>
  8006de:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e1:	29 c1                	sub    %eax,%ecx
  8006e3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006e6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ed:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f5:	eb 0f                	jmp    800706 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	53                   	push   %ebx
  8006fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fe:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800700:	83 ef 01             	sub    $0x1,%edi
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	85 ff                	test   %edi,%edi
  800708:	7f ed                	jg     8006f7 <vprintfmt+0x1cc>
  80070a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800710:	85 c9                	test   %ecx,%ecx
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	0f 49 c1             	cmovns %ecx,%eax
  80071a:	29 c1                	sub    %eax,%ecx
  80071c:	89 75 08             	mov    %esi,0x8(%ebp)
  80071f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800722:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800725:	89 cb                	mov    %ecx,%ebx
  800727:	eb 4d                	jmp    800776 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800729:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072d:	74 1b                	je     80074a <vprintfmt+0x21f>
  80072f:	0f be c0             	movsbl %al,%eax
  800732:	83 e8 20             	sub    $0x20,%eax
  800735:	83 f8 5e             	cmp    $0x5e,%eax
  800738:	76 10                	jbe    80074a <vprintfmt+0x21f>
					putch('?', putdat);
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	ff 75 0c             	pushl  0xc(%ebp)
  800740:	6a 3f                	push   $0x3f
  800742:	ff 55 08             	call   *0x8(%ebp)
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	eb 0d                	jmp    800757 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	ff 75 0c             	pushl  0xc(%ebp)
  800750:	52                   	push   %edx
  800751:	ff 55 08             	call   *0x8(%ebp)
  800754:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800757:	83 eb 01             	sub    $0x1,%ebx
  80075a:	eb 1a                	jmp    800776 <vprintfmt+0x24b>
  80075c:	89 75 08             	mov    %esi,0x8(%ebp)
  80075f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800762:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800765:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800768:	eb 0c                	jmp    800776 <vprintfmt+0x24b>
  80076a:	89 75 08             	mov    %esi,0x8(%ebp)
  80076d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800770:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800773:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800776:	83 c7 01             	add    $0x1,%edi
  800779:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077d:	0f be d0             	movsbl %al,%edx
  800780:	85 d2                	test   %edx,%edx
  800782:	74 23                	je     8007a7 <vprintfmt+0x27c>
  800784:	85 f6                	test   %esi,%esi
  800786:	78 a1                	js     800729 <vprintfmt+0x1fe>
  800788:	83 ee 01             	sub    $0x1,%esi
  80078b:	79 9c                	jns    800729 <vprintfmt+0x1fe>
  80078d:	89 df                	mov    %ebx,%edi
  80078f:	8b 75 08             	mov    0x8(%ebp),%esi
  800792:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800795:	eb 18                	jmp    8007af <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	53                   	push   %ebx
  80079b:	6a 20                	push   $0x20
  80079d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079f:	83 ef 01             	sub    $0x1,%edi
  8007a2:	83 c4 10             	add    $0x10,%esp
  8007a5:	eb 08                	jmp    8007af <vprintfmt+0x284>
  8007a7:	89 df                	mov    %ebx,%edi
  8007a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007af:	85 ff                	test   %edi,%edi
  8007b1:	7f e4                	jg     800797 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007b3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007b6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bc:	e9 90 fd ff ff       	jmp    800551 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c1:	83 f9 01             	cmp    $0x1,%ecx
  8007c4:	7e 19                	jle    8007df <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8b 50 04             	mov    0x4(%eax),%edx
  8007cc:	8b 00                	mov    (%eax),%eax
  8007ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8d 40 08             	lea    0x8(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
  8007dd:	eb 38                	jmp    800817 <vprintfmt+0x2ec>
	else if (lflag)
  8007df:	85 c9                	test   %ecx,%ecx
  8007e1:	74 1b                	je     8007fe <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8b 00                	mov    (%eax),%eax
  8007e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007eb:	89 c1                	mov    %eax,%ecx
  8007ed:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f6:	8d 40 04             	lea    0x4(%eax),%eax
  8007f9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007fc:	eb 19                	jmp    800817 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800801:	8b 00                	mov    (%eax),%eax
  800803:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800806:	89 c1                	mov    %eax,%ecx
  800808:	c1 f9 1f             	sar    $0x1f,%ecx
  80080b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80080e:	8b 45 14             	mov    0x14(%ebp),%eax
  800811:	8d 40 04             	lea    0x4(%eax),%eax
  800814:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800817:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80081a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80081d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800822:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800826:	0f 89 0e 01 00 00    	jns    80093a <vprintfmt+0x40f>
				putch('-', putdat);
  80082c:	83 ec 08             	sub    $0x8,%esp
  80082f:	53                   	push   %ebx
  800830:	6a 2d                	push   $0x2d
  800832:	ff d6                	call   *%esi
				num = -(long long) num;
  800834:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800837:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80083a:	f7 da                	neg    %edx
  80083c:	83 d1 00             	adc    $0x0,%ecx
  80083f:	f7 d9                	neg    %ecx
  800841:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800844:	b8 0a 00 00 00       	mov    $0xa,%eax
  800849:	e9 ec 00 00 00       	jmp    80093a <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80084e:	83 f9 01             	cmp    $0x1,%ecx
  800851:	7e 18                	jle    80086b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800853:	8b 45 14             	mov    0x14(%ebp),%eax
  800856:	8b 10                	mov    (%eax),%edx
  800858:	8b 48 04             	mov    0x4(%eax),%ecx
  80085b:	8d 40 08             	lea    0x8(%eax),%eax
  80085e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800861:	b8 0a 00 00 00       	mov    $0xa,%eax
  800866:	e9 cf 00 00 00       	jmp    80093a <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80086b:	85 c9                	test   %ecx,%ecx
  80086d:	74 1a                	je     800889 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80086f:	8b 45 14             	mov    0x14(%ebp),%eax
  800872:	8b 10                	mov    (%eax),%edx
  800874:	b9 00 00 00 00       	mov    $0x0,%ecx
  800879:	8d 40 04             	lea    0x4(%eax),%eax
  80087c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80087f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800884:	e9 b1 00 00 00       	jmp    80093a <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800889:	8b 45 14             	mov    0x14(%ebp),%eax
  80088c:	8b 10                	mov    (%eax),%edx
  80088e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800893:	8d 40 04             	lea    0x4(%eax),%eax
  800896:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800899:	b8 0a 00 00 00       	mov    $0xa,%eax
  80089e:	e9 97 00 00 00       	jmp    80093a <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008a3:	83 ec 08             	sub    $0x8,%esp
  8008a6:	53                   	push   %ebx
  8008a7:	6a 58                	push   $0x58
  8008a9:	ff d6                	call   *%esi
			putch('X', putdat);
  8008ab:	83 c4 08             	add    $0x8,%esp
  8008ae:	53                   	push   %ebx
  8008af:	6a 58                	push   $0x58
  8008b1:	ff d6                	call   *%esi
			putch('X', putdat);
  8008b3:	83 c4 08             	add    $0x8,%esp
  8008b6:	53                   	push   %ebx
  8008b7:	6a 58                	push   $0x58
  8008b9:	ff d6                	call   *%esi
			break;
  8008bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008c1:	e9 8b fc ff ff       	jmp    800551 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	53                   	push   %ebx
  8008ca:	6a 30                	push   $0x30
  8008cc:	ff d6                	call   *%esi
			putch('x', putdat);
  8008ce:	83 c4 08             	add    $0x8,%esp
  8008d1:	53                   	push   %ebx
  8008d2:	6a 78                	push   $0x78
  8008d4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d9:	8b 10                	mov    (%eax),%edx
  8008db:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008e0:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008e3:	8d 40 04             	lea    0x4(%eax),%eax
  8008e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008ee:	eb 4a                	jmp    80093a <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008f0:	83 f9 01             	cmp    $0x1,%ecx
  8008f3:	7e 15                	jle    80090a <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f8:	8b 10                	mov    (%eax),%edx
  8008fa:	8b 48 04             	mov    0x4(%eax),%ecx
  8008fd:	8d 40 08             	lea    0x8(%eax),%eax
  800900:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800903:	b8 10 00 00 00       	mov    $0x10,%eax
  800908:	eb 30                	jmp    80093a <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80090a:	85 c9                	test   %ecx,%ecx
  80090c:	74 17                	je     800925 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80090e:	8b 45 14             	mov    0x14(%ebp),%eax
  800911:	8b 10                	mov    (%eax),%edx
  800913:	b9 00 00 00 00       	mov    $0x0,%ecx
  800918:	8d 40 04             	lea    0x4(%eax),%eax
  80091b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80091e:	b8 10 00 00 00       	mov    $0x10,%eax
  800923:	eb 15                	jmp    80093a <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800925:	8b 45 14             	mov    0x14(%ebp),%eax
  800928:	8b 10                	mov    (%eax),%edx
  80092a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092f:	8d 40 04             	lea    0x4(%eax),%eax
  800932:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800935:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80093a:	83 ec 0c             	sub    $0xc,%esp
  80093d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800941:	57                   	push   %edi
  800942:	ff 75 e0             	pushl  -0x20(%ebp)
  800945:	50                   	push   %eax
  800946:	51                   	push   %ecx
  800947:	52                   	push   %edx
  800948:	89 da                	mov    %ebx,%edx
  80094a:	89 f0                	mov    %esi,%eax
  80094c:	e8 f1 fa ff ff       	call   800442 <printnum>
			break;
  800951:	83 c4 20             	add    $0x20,%esp
  800954:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800957:	e9 f5 fb ff ff       	jmp    800551 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80095c:	83 ec 08             	sub    $0x8,%esp
  80095f:	53                   	push   %ebx
  800960:	52                   	push   %edx
  800961:	ff d6                	call   *%esi
			break;
  800963:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800966:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800969:	e9 e3 fb ff ff       	jmp    800551 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80096e:	83 ec 08             	sub    $0x8,%esp
  800971:	53                   	push   %ebx
  800972:	6a 25                	push   $0x25
  800974:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800976:	83 c4 10             	add    $0x10,%esp
  800979:	eb 03                	jmp    80097e <vprintfmt+0x453>
  80097b:	83 ef 01             	sub    $0x1,%edi
  80097e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800982:	75 f7                	jne    80097b <vprintfmt+0x450>
  800984:	e9 c8 fb ff ff       	jmp    800551 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800989:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5f                   	pop    %edi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	83 ec 18             	sub    $0x18,%esp
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80099d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009a0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ae:	85 c0                	test   %eax,%eax
  8009b0:	74 26                	je     8009d8 <vsnprintf+0x47>
  8009b2:	85 d2                	test   %edx,%edx
  8009b4:	7e 22                	jle    8009d8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b6:	ff 75 14             	pushl  0x14(%ebp)
  8009b9:	ff 75 10             	pushl  0x10(%ebp)
  8009bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009bf:	50                   	push   %eax
  8009c0:	68 f1 04 80 00       	push   $0x8004f1
  8009c5:	e8 61 fb ff ff       	call   80052b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ca:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009cd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	eb 05                	jmp    8009dd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e8:	50                   	push   %eax
  8009e9:	ff 75 10             	pushl  0x10(%ebp)
  8009ec:	ff 75 0c             	pushl  0xc(%ebp)
  8009ef:	ff 75 08             	pushl  0x8(%ebp)
  8009f2:	e8 9a ff ff ff       	call   800991 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009f7:	c9                   	leave  
  8009f8:	c3                   	ret    

008009f9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800a04:	eb 03                	jmp    800a09 <strlen+0x10>
		n++;
  800a06:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a09:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a0d:	75 f7                	jne    800a06 <strlen+0xd>
		n++;
	return n;
}
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a17:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1f:	eb 03                	jmp    800a24 <strnlen+0x13>
		n++;
  800a21:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a24:	39 c2                	cmp    %eax,%edx
  800a26:	74 08                	je     800a30 <strnlen+0x1f>
  800a28:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a2c:	75 f3                	jne    800a21 <strnlen+0x10>
  800a2e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	53                   	push   %ebx
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a3c:	89 c2                	mov    %eax,%edx
  800a3e:	83 c2 01             	add    $0x1,%edx
  800a41:	83 c1 01             	add    $0x1,%ecx
  800a44:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a48:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a4b:	84 db                	test   %bl,%bl
  800a4d:	75 ef                	jne    800a3e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a4f:	5b                   	pop    %ebx
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	53                   	push   %ebx
  800a56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a59:	53                   	push   %ebx
  800a5a:	e8 9a ff ff ff       	call   8009f9 <strlen>
  800a5f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a62:	ff 75 0c             	pushl  0xc(%ebp)
  800a65:	01 d8                	add    %ebx,%eax
  800a67:	50                   	push   %eax
  800a68:	e8 c5 ff ff ff       	call   800a32 <strcpy>
	return dst;
}
  800a6d:	89 d8                	mov    %ebx,%eax
  800a6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a72:	c9                   	leave  
  800a73:	c3                   	ret    

00800a74 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a84:	89 f2                	mov    %esi,%edx
  800a86:	eb 0f                	jmp    800a97 <strncpy+0x23>
		*dst++ = *src;
  800a88:	83 c2 01             	add    $0x1,%edx
  800a8b:	0f b6 01             	movzbl (%ecx),%eax
  800a8e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a91:	80 39 01             	cmpb   $0x1,(%ecx)
  800a94:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a97:	39 da                	cmp    %ebx,%edx
  800a99:	75 ed                	jne    800a88 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a9b:	89 f0                	mov    %esi,%eax
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aac:	8b 55 10             	mov    0x10(%ebp),%edx
  800aaf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab1:	85 d2                	test   %edx,%edx
  800ab3:	74 21                	je     800ad6 <strlcpy+0x35>
  800ab5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ab9:	89 f2                	mov    %esi,%edx
  800abb:	eb 09                	jmp    800ac6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800abd:	83 c2 01             	add    $0x1,%edx
  800ac0:	83 c1 01             	add    $0x1,%ecx
  800ac3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ac6:	39 c2                	cmp    %eax,%edx
  800ac8:	74 09                	je     800ad3 <strlcpy+0x32>
  800aca:	0f b6 19             	movzbl (%ecx),%ebx
  800acd:	84 db                	test   %bl,%bl
  800acf:	75 ec                	jne    800abd <strlcpy+0x1c>
  800ad1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ad3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ad6:	29 f0                	sub    %esi,%eax
}
  800ad8:	5b                   	pop    %ebx
  800ad9:	5e                   	pop    %esi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ae5:	eb 06                	jmp    800aed <strcmp+0x11>
		p++, q++;
  800ae7:	83 c1 01             	add    $0x1,%ecx
  800aea:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aed:	0f b6 01             	movzbl (%ecx),%eax
  800af0:	84 c0                	test   %al,%al
  800af2:	74 04                	je     800af8 <strcmp+0x1c>
  800af4:	3a 02                	cmp    (%edx),%al
  800af6:	74 ef                	je     800ae7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af8:	0f b6 c0             	movzbl %al,%eax
  800afb:	0f b6 12             	movzbl (%edx),%edx
  800afe:	29 d0                	sub    %edx,%eax
}
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	53                   	push   %ebx
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0c:	89 c3                	mov    %eax,%ebx
  800b0e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b11:	eb 06                	jmp    800b19 <strncmp+0x17>
		n--, p++, q++;
  800b13:	83 c0 01             	add    $0x1,%eax
  800b16:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b19:	39 d8                	cmp    %ebx,%eax
  800b1b:	74 15                	je     800b32 <strncmp+0x30>
  800b1d:	0f b6 08             	movzbl (%eax),%ecx
  800b20:	84 c9                	test   %cl,%cl
  800b22:	74 04                	je     800b28 <strncmp+0x26>
  800b24:	3a 0a                	cmp    (%edx),%cl
  800b26:	74 eb                	je     800b13 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b28:	0f b6 00             	movzbl (%eax),%eax
  800b2b:	0f b6 12             	movzbl (%edx),%edx
  800b2e:	29 d0                	sub    %edx,%eax
  800b30:	eb 05                	jmp    800b37 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b40:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b44:	eb 07                	jmp    800b4d <strchr+0x13>
		if (*s == c)
  800b46:	38 ca                	cmp    %cl,%dl
  800b48:	74 0f                	je     800b59 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b4a:	83 c0 01             	add    $0x1,%eax
  800b4d:	0f b6 10             	movzbl (%eax),%edx
  800b50:	84 d2                	test   %dl,%dl
  800b52:	75 f2                	jne    800b46 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b65:	eb 03                	jmp    800b6a <strfind+0xf>
  800b67:	83 c0 01             	add    $0x1,%eax
  800b6a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b6d:	38 ca                	cmp    %cl,%dl
  800b6f:	74 04                	je     800b75 <strfind+0x1a>
  800b71:	84 d2                	test   %dl,%dl
  800b73:	75 f2                	jne    800b67 <strfind+0xc>
			break;
	return (char *) s;
}
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b80:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b83:	85 c9                	test   %ecx,%ecx
  800b85:	74 36                	je     800bbd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b87:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b8d:	75 28                	jne    800bb7 <memset+0x40>
  800b8f:	f6 c1 03             	test   $0x3,%cl
  800b92:	75 23                	jne    800bb7 <memset+0x40>
		c &= 0xFF;
  800b94:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b98:	89 d3                	mov    %edx,%ebx
  800b9a:	c1 e3 08             	shl    $0x8,%ebx
  800b9d:	89 d6                	mov    %edx,%esi
  800b9f:	c1 e6 18             	shl    $0x18,%esi
  800ba2:	89 d0                	mov    %edx,%eax
  800ba4:	c1 e0 10             	shl    $0x10,%eax
  800ba7:	09 f0                	or     %esi,%eax
  800ba9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800bab:	89 d8                	mov    %ebx,%eax
  800bad:	09 d0                	or     %edx,%eax
  800baf:	c1 e9 02             	shr    $0x2,%ecx
  800bb2:	fc                   	cld    
  800bb3:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb5:	eb 06                	jmp    800bbd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bba:	fc                   	cld    
  800bbb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bbd:	89 f8                	mov    %edi,%eax
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5f                   	pop    %edi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	57                   	push   %edi
  800bc8:	56                   	push   %esi
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bcf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bd2:	39 c6                	cmp    %eax,%esi
  800bd4:	73 35                	jae    800c0b <memmove+0x47>
  800bd6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd9:	39 d0                	cmp    %edx,%eax
  800bdb:	73 2e                	jae    800c0b <memmove+0x47>
		s += n;
		d += n;
  800bdd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be0:	89 d6                	mov    %edx,%esi
  800be2:	09 fe                	or     %edi,%esi
  800be4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bea:	75 13                	jne    800bff <memmove+0x3b>
  800bec:	f6 c1 03             	test   $0x3,%cl
  800bef:	75 0e                	jne    800bff <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bf1:	83 ef 04             	sub    $0x4,%edi
  800bf4:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bf7:	c1 e9 02             	shr    $0x2,%ecx
  800bfa:	fd                   	std    
  800bfb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bfd:	eb 09                	jmp    800c08 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bff:	83 ef 01             	sub    $0x1,%edi
  800c02:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c05:	fd                   	std    
  800c06:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c08:	fc                   	cld    
  800c09:	eb 1d                	jmp    800c28 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0b:	89 f2                	mov    %esi,%edx
  800c0d:	09 c2                	or     %eax,%edx
  800c0f:	f6 c2 03             	test   $0x3,%dl
  800c12:	75 0f                	jne    800c23 <memmove+0x5f>
  800c14:	f6 c1 03             	test   $0x3,%cl
  800c17:	75 0a                	jne    800c23 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c19:	c1 e9 02             	shr    $0x2,%ecx
  800c1c:	89 c7                	mov    %eax,%edi
  800c1e:	fc                   	cld    
  800c1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c21:	eb 05                	jmp    800c28 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c23:	89 c7                	mov    %eax,%edi
  800c25:	fc                   	cld    
  800c26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    

00800c2c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c2f:	ff 75 10             	pushl  0x10(%ebp)
  800c32:	ff 75 0c             	pushl  0xc(%ebp)
  800c35:	ff 75 08             	pushl  0x8(%ebp)
  800c38:	e8 87 ff ff ff       	call   800bc4 <memmove>
}
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    

00800c3f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	8b 45 08             	mov    0x8(%ebp),%eax
  800c47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c4a:	89 c6                	mov    %eax,%esi
  800c4c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c4f:	eb 1a                	jmp    800c6b <memcmp+0x2c>
		if (*s1 != *s2)
  800c51:	0f b6 08             	movzbl (%eax),%ecx
  800c54:	0f b6 1a             	movzbl (%edx),%ebx
  800c57:	38 d9                	cmp    %bl,%cl
  800c59:	74 0a                	je     800c65 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c5b:	0f b6 c1             	movzbl %cl,%eax
  800c5e:	0f b6 db             	movzbl %bl,%ebx
  800c61:	29 d8                	sub    %ebx,%eax
  800c63:	eb 0f                	jmp    800c74 <memcmp+0x35>
		s1++, s2++;
  800c65:	83 c0 01             	add    $0x1,%eax
  800c68:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6b:	39 f0                	cmp    %esi,%eax
  800c6d:	75 e2                	jne    800c51 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	53                   	push   %ebx
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c7f:	89 c1                	mov    %eax,%ecx
  800c81:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c84:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c88:	eb 0a                	jmp    800c94 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c8a:	0f b6 10             	movzbl (%eax),%edx
  800c8d:	39 da                	cmp    %ebx,%edx
  800c8f:	74 07                	je     800c98 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c91:	83 c0 01             	add    $0x1,%eax
  800c94:	39 c8                	cmp    %ecx,%eax
  800c96:	72 f2                	jb     800c8a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c98:	5b                   	pop    %ebx
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca7:	eb 03                	jmp    800cac <strtol+0x11>
		s++;
  800ca9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cac:	0f b6 01             	movzbl (%ecx),%eax
  800caf:	3c 20                	cmp    $0x20,%al
  800cb1:	74 f6                	je     800ca9 <strtol+0xe>
  800cb3:	3c 09                	cmp    $0x9,%al
  800cb5:	74 f2                	je     800ca9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb7:	3c 2b                	cmp    $0x2b,%al
  800cb9:	75 0a                	jne    800cc5 <strtol+0x2a>
		s++;
  800cbb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cbe:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc3:	eb 11                	jmp    800cd6 <strtol+0x3b>
  800cc5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cca:	3c 2d                	cmp    $0x2d,%al
  800ccc:	75 08                	jne    800cd6 <strtol+0x3b>
		s++, neg = 1;
  800cce:	83 c1 01             	add    $0x1,%ecx
  800cd1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cdc:	75 15                	jne    800cf3 <strtol+0x58>
  800cde:	80 39 30             	cmpb   $0x30,(%ecx)
  800ce1:	75 10                	jne    800cf3 <strtol+0x58>
  800ce3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ce7:	75 7c                	jne    800d65 <strtol+0xca>
		s += 2, base = 16;
  800ce9:	83 c1 02             	add    $0x2,%ecx
  800cec:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cf1:	eb 16                	jmp    800d09 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cf3:	85 db                	test   %ebx,%ebx
  800cf5:	75 12                	jne    800d09 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cf7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cfc:	80 39 30             	cmpb   $0x30,(%ecx)
  800cff:	75 08                	jne    800d09 <strtol+0x6e>
		s++, base = 8;
  800d01:	83 c1 01             	add    $0x1,%ecx
  800d04:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d11:	0f b6 11             	movzbl (%ecx),%edx
  800d14:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d17:	89 f3                	mov    %esi,%ebx
  800d19:	80 fb 09             	cmp    $0x9,%bl
  800d1c:	77 08                	ja     800d26 <strtol+0x8b>
			dig = *s - '0';
  800d1e:	0f be d2             	movsbl %dl,%edx
  800d21:	83 ea 30             	sub    $0x30,%edx
  800d24:	eb 22                	jmp    800d48 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d26:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d29:	89 f3                	mov    %esi,%ebx
  800d2b:	80 fb 19             	cmp    $0x19,%bl
  800d2e:	77 08                	ja     800d38 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d30:	0f be d2             	movsbl %dl,%edx
  800d33:	83 ea 57             	sub    $0x57,%edx
  800d36:	eb 10                	jmp    800d48 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d38:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d3b:	89 f3                	mov    %esi,%ebx
  800d3d:	80 fb 19             	cmp    $0x19,%bl
  800d40:	77 16                	ja     800d58 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d42:	0f be d2             	movsbl %dl,%edx
  800d45:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d48:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d4b:	7d 0b                	jge    800d58 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d4d:	83 c1 01             	add    $0x1,%ecx
  800d50:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d54:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d56:	eb b9                	jmp    800d11 <strtol+0x76>

	if (endptr)
  800d58:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d5c:	74 0d                	je     800d6b <strtol+0xd0>
		*endptr = (char *) s;
  800d5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d61:	89 0e                	mov    %ecx,(%esi)
  800d63:	eb 06                	jmp    800d6b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d65:	85 db                	test   %ebx,%ebx
  800d67:	74 98                	je     800d01 <strtol+0x66>
  800d69:	eb 9e                	jmp    800d09 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d6b:	89 c2                	mov    %eax,%edx
  800d6d:	f7 da                	neg    %edx
  800d6f:	85 ff                	test   %edi,%edi
  800d71:	0f 45 c2             	cmovne %edx,%eax
}
  800d74:	5b                   	pop    %ebx
  800d75:	5e                   	pop    %esi
  800d76:	5f                   	pop    %edi
  800d77:	5d                   	pop    %ebp
  800d78:	c3                   	ret    
  800d79:	66 90                	xchg   %ax,%ax
  800d7b:	66 90                	xchg   %ax,%ax
  800d7d:	66 90                	xchg   %ax,%ax
  800d7f:	90                   	nop

00800d80 <__udivdi3>:
  800d80:	55                   	push   %ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 1c             	sub    $0x1c,%esp
  800d87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d97:	85 f6                	test   %esi,%esi
  800d99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d9d:	89 ca                	mov    %ecx,%edx
  800d9f:	89 f8                	mov    %edi,%eax
  800da1:	75 3d                	jne    800de0 <__udivdi3+0x60>
  800da3:	39 cf                	cmp    %ecx,%edi
  800da5:	0f 87 c5 00 00 00    	ja     800e70 <__udivdi3+0xf0>
  800dab:	85 ff                	test   %edi,%edi
  800dad:	89 fd                	mov    %edi,%ebp
  800daf:	75 0b                	jne    800dbc <__udivdi3+0x3c>
  800db1:	b8 01 00 00 00       	mov    $0x1,%eax
  800db6:	31 d2                	xor    %edx,%edx
  800db8:	f7 f7                	div    %edi
  800dba:	89 c5                	mov    %eax,%ebp
  800dbc:	89 c8                	mov    %ecx,%eax
  800dbe:	31 d2                	xor    %edx,%edx
  800dc0:	f7 f5                	div    %ebp
  800dc2:	89 c1                	mov    %eax,%ecx
  800dc4:	89 d8                	mov    %ebx,%eax
  800dc6:	89 cf                	mov    %ecx,%edi
  800dc8:	f7 f5                	div    %ebp
  800dca:	89 c3                	mov    %eax,%ebx
  800dcc:	89 d8                	mov    %ebx,%eax
  800dce:	89 fa                	mov    %edi,%edx
  800dd0:	83 c4 1c             	add    $0x1c,%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    
  800dd8:	90                   	nop
  800dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800de0:	39 ce                	cmp    %ecx,%esi
  800de2:	77 74                	ja     800e58 <__udivdi3+0xd8>
  800de4:	0f bd fe             	bsr    %esi,%edi
  800de7:	83 f7 1f             	xor    $0x1f,%edi
  800dea:	0f 84 98 00 00 00    	je     800e88 <__udivdi3+0x108>
  800df0:	bb 20 00 00 00       	mov    $0x20,%ebx
  800df5:	89 f9                	mov    %edi,%ecx
  800df7:	89 c5                	mov    %eax,%ebp
  800df9:	29 fb                	sub    %edi,%ebx
  800dfb:	d3 e6                	shl    %cl,%esi
  800dfd:	89 d9                	mov    %ebx,%ecx
  800dff:	d3 ed                	shr    %cl,%ebp
  800e01:	89 f9                	mov    %edi,%ecx
  800e03:	d3 e0                	shl    %cl,%eax
  800e05:	09 ee                	or     %ebp,%esi
  800e07:	89 d9                	mov    %ebx,%ecx
  800e09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e0d:	89 d5                	mov    %edx,%ebp
  800e0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e13:	d3 ed                	shr    %cl,%ebp
  800e15:	89 f9                	mov    %edi,%ecx
  800e17:	d3 e2                	shl    %cl,%edx
  800e19:	89 d9                	mov    %ebx,%ecx
  800e1b:	d3 e8                	shr    %cl,%eax
  800e1d:	09 c2                	or     %eax,%edx
  800e1f:	89 d0                	mov    %edx,%eax
  800e21:	89 ea                	mov    %ebp,%edx
  800e23:	f7 f6                	div    %esi
  800e25:	89 d5                	mov    %edx,%ebp
  800e27:	89 c3                	mov    %eax,%ebx
  800e29:	f7 64 24 0c          	mull   0xc(%esp)
  800e2d:	39 d5                	cmp    %edx,%ebp
  800e2f:	72 10                	jb     800e41 <__udivdi3+0xc1>
  800e31:	8b 74 24 08          	mov    0x8(%esp),%esi
  800e35:	89 f9                	mov    %edi,%ecx
  800e37:	d3 e6                	shl    %cl,%esi
  800e39:	39 c6                	cmp    %eax,%esi
  800e3b:	73 07                	jae    800e44 <__udivdi3+0xc4>
  800e3d:	39 d5                	cmp    %edx,%ebp
  800e3f:	75 03                	jne    800e44 <__udivdi3+0xc4>
  800e41:	83 eb 01             	sub    $0x1,%ebx
  800e44:	31 ff                	xor    %edi,%edi
  800e46:	89 d8                	mov    %ebx,%eax
  800e48:	89 fa                	mov    %edi,%edx
  800e4a:	83 c4 1c             	add    $0x1c,%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    
  800e52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e58:	31 ff                	xor    %edi,%edi
  800e5a:	31 db                	xor    %ebx,%ebx
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
  800e70:	89 d8                	mov    %ebx,%eax
  800e72:	f7 f7                	div    %edi
  800e74:	31 ff                	xor    %edi,%edi
  800e76:	89 c3                	mov    %eax,%ebx
  800e78:	89 d8                	mov    %ebx,%eax
  800e7a:	89 fa                	mov    %edi,%edx
  800e7c:	83 c4 1c             	add    $0x1c,%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    
  800e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e88:	39 ce                	cmp    %ecx,%esi
  800e8a:	72 0c                	jb     800e98 <__udivdi3+0x118>
  800e8c:	31 db                	xor    %ebx,%ebx
  800e8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e92:	0f 87 34 ff ff ff    	ja     800dcc <__udivdi3+0x4c>
  800e98:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e9d:	e9 2a ff ff ff       	jmp    800dcc <__udivdi3+0x4c>
  800ea2:	66 90                	xchg   %ax,%ax
  800ea4:	66 90                	xchg   %ax,%ax
  800ea6:	66 90                	xchg   %ax,%ax
  800ea8:	66 90                	xchg   %ax,%ax
  800eaa:	66 90                	xchg   %ax,%ax
  800eac:	66 90                	xchg   %ax,%ax
  800eae:	66 90                	xchg   %ax,%ax

00800eb0 <__umoddi3>:
  800eb0:	55                   	push   %ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 1c             	sub    $0x1c,%esp
  800eb7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ebb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800ebf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ec3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ec7:	85 d2                	test   %edx,%edx
  800ec9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800ecd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ed1:	89 f3                	mov    %esi,%ebx
  800ed3:	89 3c 24             	mov    %edi,(%esp)
  800ed6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eda:	75 1c                	jne    800ef8 <__umoddi3+0x48>
  800edc:	39 f7                	cmp    %esi,%edi
  800ede:	76 50                	jbe    800f30 <__umoddi3+0x80>
  800ee0:	89 c8                	mov    %ecx,%eax
  800ee2:	89 f2                	mov    %esi,%edx
  800ee4:	f7 f7                	div    %edi
  800ee6:	89 d0                	mov    %edx,%eax
  800ee8:	31 d2                	xor    %edx,%edx
  800eea:	83 c4 1c             	add    $0x1c,%esp
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5f                   	pop    %edi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    
  800ef2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ef8:	39 f2                	cmp    %esi,%edx
  800efa:	89 d0                	mov    %edx,%eax
  800efc:	77 52                	ja     800f50 <__umoddi3+0xa0>
  800efe:	0f bd ea             	bsr    %edx,%ebp
  800f01:	83 f5 1f             	xor    $0x1f,%ebp
  800f04:	75 5a                	jne    800f60 <__umoddi3+0xb0>
  800f06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f0a:	0f 82 e0 00 00 00    	jb     800ff0 <__umoddi3+0x140>
  800f10:	39 0c 24             	cmp    %ecx,(%esp)
  800f13:	0f 86 d7 00 00 00    	jbe    800ff0 <__umoddi3+0x140>
  800f19:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f21:	83 c4 1c             	add    $0x1c,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    
  800f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f30:	85 ff                	test   %edi,%edi
  800f32:	89 fd                	mov    %edi,%ebp
  800f34:	75 0b                	jne    800f41 <__umoddi3+0x91>
  800f36:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	f7 f7                	div    %edi
  800f3f:	89 c5                	mov    %eax,%ebp
  800f41:	89 f0                	mov    %esi,%eax
  800f43:	31 d2                	xor    %edx,%edx
  800f45:	f7 f5                	div    %ebp
  800f47:	89 c8                	mov    %ecx,%eax
  800f49:	f7 f5                	div    %ebp
  800f4b:	89 d0                	mov    %edx,%eax
  800f4d:	eb 99                	jmp    800ee8 <__umoddi3+0x38>
  800f4f:	90                   	nop
  800f50:	89 c8                	mov    %ecx,%eax
  800f52:	89 f2                	mov    %esi,%edx
  800f54:	83 c4 1c             	add    $0x1c,%esp
  800f57:	5b                   	pop    %ebx
  800f58:	5e                   	pop    %esi
  800f59:	5f                   	pop    %edi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    
  800f5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f60:	8b 34 24             	mov    (%esp),%esi
  800f63:	bf 20 00 00 00       	mov    $0x20,%edi
  800f68:	89 e9                	mov    %ebp,%ecx
  800f6a:	29 ef                	sub    %ebp,%edi
  800f6c:	d3 e0                	shl    %cl,%eax
  800f6e:	89 f9                	mov    %edi,%ecx
  800f70:	89 f2                	mov    %esi,%edx
  800f72:	d3 ea                	shr    %cl,%edx
  800f74:	89 e9                	mov    %ebp,%ecx
  800f76:	09 c2                	or     %eax,%edx
  800f78:	89 d8                	mov    %ebx,%eax
  800f7a:	89 14 24             	mov    %edx,(%esp)
  800f7d:	89 f2                	mov    %esi,%edx
  800f7f:	d3 e2                	shl    %cl,%edx
  800f81:	89 f9                	mov    %edi,%ecx
  800f83:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f8b:	d3 e8                	shr    %cl,%eax
  800f8d:	89 e9                	mov    %ebp,%ecx
  800f8f:	89 c6                	mov    %eax,%esi
  800f91:	d3 e3                	shl    %cl,%ebx
  800f93:	89 f9                	mov    %edi,%ecx
  800f95:	89 d0                	mov    %edx,%eax
  800f97:	d3 e8                	shr    %cl,%eax
  800f99:	89 e9                	mov    %ebp,%ecx
  800f9b:	09 d8                	or     %ebx,%eax
  800f9d:	89 d3                	mov    %edx,%ebx
  800f9f:	89 f2                	mov    %esi,%edx
  800fa1:	f7 34 24             	divl   (%esp)
  800fa4:	89 d6                	mov    %edx,%esi
  800fa6:	d3 e3                	shl    %cl,%ebx
  800fa8:	f7 64 24 04          	mull   0x4(%esp)
  800fac:	39 d6                	cmp    %edx,%esi
  800fae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fb2:	89 d1                	mov    %edx,%ecx
  800fb4:	89 c3                	mov    %eax,%ebx
  800fb6:	72 08                	jb     800fc0 <__umoddi3+0x110>
  800fb8:	75 11                	jne    800fcb <__umoddi3+0x11b>
  800fba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800fbe:	73 0b                	jae    800fcb <__umoddi3+0x11b>
  800fc0:	2b 44 24 04          	sub    0x4(%esp),%eax
  800fc4:	1b 14 24             	sbb    (%esp),%edx
  800fc7:	89 d1                	mov    %edx,%ecx
  800fc9:	89 c3                	mov    %eax,%ebx
  800fcb:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fcf:	29 da                	sub    %ebx,%edx
  800fd1:	19 ce                	sbb    %ecx,%esi
  800fd3:	89 f9                	mov    %edi,%ecx
  800fd5:	89 f0                	mov    %esi,%eax
  800fd7:	d3 e0                	shl    %cl,%eax
  800fd9:	89 e9                	mov    %ebp,%ecx
  800fdb:	d3 ea                	shr    %cl,%edx
  800fdd:	89 e9                	mov    %ebp,%ecx
  800fdf:	d3 ee                	shr    %cl,%esi
  800fe1:	09 d0                	or     %edx,%eax
  800fe3:	89 f2                	mov    %esi,%edx
  800fe5:	83 c4 1c             	add    $0x1c,%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5f                   	pop    %edi
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    
  800fed:	8d 76 00             	lea    0x0(%esi),%esi
  800ff0:	29 f9                	sub    %edi,%ecx
  800ff2:	19 d6                	sbb    %edx,%esi
  800ff4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ff8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ffc:	e9 18 ff ff ff       	jmp    800f19 <__umoddi3+0x69>
