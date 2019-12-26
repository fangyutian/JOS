
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
  800044:	e8 a5 00 00 00       	call   8000ee <sys_cputs>
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
  800051:	57                   	push   %edi
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800057:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80005e:	00 00 00 
	envid_t eid = sys_getenvid();
  800061:	e8 06 01 00 00       	call   80016c <sys_getenvid>
  800066:	8b 3d 08 20 80 00    	mov    0x802008,%edi
  80006c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800071:	be 00 00 00 00       	mov    $0x0,%esi
	int i;
	for (i = 0; i < NENV; i++) {
  800076:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == eid) {
  80007b:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  80007e:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800084:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &(envs[i]);
  800087:	39 c8                	cmp    %ecx,%eax
  800089:	0f 44 fb             	cmove  %ebx,%edi
  80008c:	b9 01 00 00 00       	mov    $0x1,%ecx
  800091:	0f 44 f1             	cmove  %ecx,%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
	envid_t eid = sys_getenvid();
	int i;
	for (i = 0; i < NENV; i++) {
  800094:	83 c2 01             	add    $0x1,%edx
  800097:	83 c3 7c             	add    $0x7c,%ebx
  80009a:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  8000a0:	75 d9                	jne    80007b <libmain+0x2d>
  8000a2:	89 f0                	mov    %esi,%eax
  8000a4:	84 c0                	test   %al,%al
  8000a6:	74 06                	je     8000ae <libmain+0x60>
  8000a8:	89 3d 08 20 80 00    	mov    %edi,0x802008
			thisenv = &(envs[i]);
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000b2:	7e 0a                	jle    8000be <libmain+0x70>
		binaryname = argv[0];
  8000b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000b7:	8b 00                	mov    (%eax),%eax
  8000b9:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  8000be:	83 ec 08             	sub    $0x8,%esp
  8000c1:	ff 75 0c             	pushl  0xc(%ebp)
  8000c4:	ff 75 08             	pushl  0x8(%ebp)
  8000c7:	e8 67 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000cc:	e8 0b 00 00 00       	call   8000dc <exit>
}
  8000d1:	83 c4 10             	add    $0x10,%esp
  8000d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000e2:	6a 00                	push   $0x0
  8000e4:	e8 42 00 00 00       	call   80012b <sys_env_destroy>
}
  8000e9:	83 c4 10             	add    $0x10,%esp
  8000ec:	c9                   	leave  
  8000ed:	c3                   	ret    

008000ee <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ee:	55                   	push   %ebp
  8000ef:	89 e5                	mov    %esp,%ebp
  8000f1:	57                   	push   %edi
  8000f2:	56                   	push   %esi
  8000f3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 c3                	mov    %eax,%ebx
  800101:	89 c7                	mov    %eax,%edi
  800103:	89 c6                	mov    %eax,%esi
  800105:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800107:	5b                   	pop    %ebx
  800108:	5e                   	pop    %esi
  800109:	5f                   	pop    %edi
  80010a:	5d                   	pop    %ebp
  80010b:	c3                   	ret    

0080010c <sys_cgetc>:

int
sys_cgetc(void)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	57                   	push   %edi
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800112:	ba 00 00 00 00       	mov    $0x0,%edx
  800117:	b8 01 00 00 00       	mov    $0x1,%eax
  80011c:	89 d1                	mov    %edx,%ecx
  80011e:	89 d3                	mov    %edx,%ebx
  800120:	89 d7                	mov    %edx,%edi
  800122:	89 d6                	mov    %edx,%esi
  800124:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800126:	5b                   	pop    %ebx
  800127:	5e                   	pop    %esi
  800128:	5f                   	pop    %edi
  800129:	5d                   	pop    %ebp
  80012a:	c3                   	ret    

0080012b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80012b:	55                   	push   %ebp
  80012c:	89 e5                	mov    %esp,%ebp
  80012e:	57                   	push   %edi
  80012f:	56                   	push   %esi
  800130:	53                   	push   %ebx
  800131:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800134:	b9 00 00 00 00       	mov    $0x0,%ecx
  800139:	b8 03 00 00 00       	mov    $0x3,%eax
  80013e:	8b 55 08             	mov    0x8(%ebp),%edx
  800141:	89 cb                	mov    %ecx,%ebx
  800143:	89 cf                	mov    %ecx,%edi
  800145:	89 ce                	mov    %ecx,%esi
  800147:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800149:	85 c0                	test   %eax,%eax
  80014b:	7e 17                	jle    800164 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80014d:	83 ec 0c             	sub    $0xc,%esp
  800150:	50                   	push   %eax
  800151:	6a 03                	push   $0x3
  800153:	68 38 10 80 00       	push   $0x801038
  800158:	6a 23                	push   $0x23
  80015a:	68 55 10 80 00       	push   $0x801055
  80015f:	e8 f5 01 00 00       	call   800359 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800164:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	57                   	push   %edi
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800172:	ba 00 00 00 00       	mov    $0x0,%edx
  800177:	b8 02 00 00 00       	mov    $0x2,%eax
  80017c:	89 d1                	mov    %edx,%ecx
  80017e:	89 d3                	mov    %edx,%ebx
  800180:	89 d7                	mov    %edx,%edi
  800182:	89 d6                	mov    %edx,%esi
  800184:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800186:	5b                   	pop    %ebx
  800187:	5e                   	pop    %esi
  800188:	5f                   	pop    %edi
  800189:	5d                   	pop    %ebp
  80018a:	c3                   	ret    

0080018b <sys_yield>:

void
sys_yield(void)
{
  80018b:	55                   	push   %ebp
  80018c:	89 e5                	mov    %esp,%ebp
  80018e:	57                   	push   %edi
  80018f:	56                   	push   %esi
  800190:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800191:	ba 00 00 00 00       	mov    $0x0,%edx
  800196:	b8 0a 00 00 00       	mov    $0xa,%eax
  80019b:	89 d1                	mov    %edx,%ecx
  80019d:	89 d3                	mov    %edx,%ebx
  80019f:	89 d7                	mov    %edx,%edi
  8001a1:	89 d6                	mov    %edx,%esi
  8001a3:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001a5:	5b                   	pop    %ebx
  8001a6:	5e                   	pop    %esi
  8001a7:	5f                   	pop    %edi
  8001a8:	5d                   	pop    %ebp
  8001a9:	c3                   	ret    

008001aa <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	57                   	push   %edi
  8001ae:	56                   	push   %esi
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b3:	be 00 00 00 00       	mov    $0x0,%esi
  8001b8:	b8 04 00 00 00       	mov    $0x4,%eax
  8001bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c6:	89 f7                	mov    %esi,%edi
  8001c8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7e 17                	jle    8001e5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	50                   	push   %eax
  8001d2:	6a 04                	push   $0x4
  8001d4:	68 38 10 80 00       	push   $0x801038
  8001d9:	6a 23                	push   $0x23
  8001db:	68 55 10 80 00       	push   $0x801055
  8001e0:	e8 74 01 00 00       	call   800359 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800204:	8b 7d 14             	mov    0x14(%ebp),%edi
  800207:	8b 75 18             	mov    0x18(%ebp),%esi
  80020a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 17                	jle    800227 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	83 ec 0c             	sub    $0xc,%esp
  800213:	50                   	push   %eax
  800214:	6a 05                	push   $0x5
  800216:	68 38 10 80 00       	push   $0x801038
  80021b:	6a 23                	push   $0x23
  80021d:	68 55 10 80 00       	push   $0x801055
  800222:	e8 32 01 00 00       	call   800359 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022a:	5b                   	pop    %ebx
  80022b:	5e                   	pop    %esi
  80022c:	5f                   	pop    %edi
  80022d:	5d                   	pop    %ebp
  80022e:	c3                   	ret    

0080022f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	b8 06 00 00 00       	mov    $0x6,%eax
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7e 17                	jle    800269 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800252:	83 ec 0c             	sub    $0xc,%esp
  800255:	50                   	push   %eax
  800256:	6a 06                	push   $0x6
  800258:	68 38 10 80 00       	push   $0x801038
  80025d:	6a 23                	push   $0x23
  80025f:	68 55 10 80 00       	push   $0x801055
  800264:	e8 f0 00 00 00       	call   800359 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026c:	5b                   	pop    %ebx
  80026d:	5e                   	pop    %esi
  80026e:	5f                   	pop    %edi
  80026f:	5d                   	pop    %ebp
  800270:	c3                   	ret    

00800271 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	b8 08 00 00 00       	mov    $0x8,%eax
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7e 17                	jle    8002ab <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800294:	83 ec 0c             	sub    $0xc,%esp
  800297:	50                   	push   %eax
  800298:	6a 08                	push   $0x8
  80029a:	68 38 10 80 00       	push   $0x801038
  80029f:	6a 23                	push   $0x23
  8002a1:	68 55 10 80 00       	push   $0x801055
  8002a6:	e8 ae 00 00 00       	call   800359 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5f                   	pop    %edi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
  8002b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cc:	89 df                	mov    %ebx,%edi
  8002ce:	89 de                	mov    %ebx,%esi
  8002d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d2:	85 c0                	test   %eax,%eax
  8002d4:	7e 17                	jle    8002ed <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d6:	83 ec 0c             	sub    $0xc,%esp
  8002d9:	50                   	push   %eax
  8002da:	6a 09                	push   $0x9
  8002dc:	68 38 10 80 00       	push   $0x801038
  8002e1:	6a 23                	push   $0x23
  8002e3:	68 55 10 80 00       	push   $0x801055
  8002e8:	e8 6c 00 00 00       	call   800359 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f0:	5b                   	pop    %ebx
  8002f1:	5e                   	pop    %esi
  8002f2:	5f                   	pop    %edi
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	57                   	push   %edi
  8002f9:	56                   	push   %esi
  8002fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fb:	be 00 00 00 00       	mov    $0x0,%esi
  800300:	b8 0b 00 00 00       	mov    $0xb,%eax
  800305:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800308:	8b 55 08             	mov    0x8(%ebp),%edx
  80030b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800311:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800313:	5b                   	pop    %ebx
  800314:	5e                   	pop    %esi
  800315:	5f                   	pop    %edi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800321:	b9 00 00 00 00       	mov    $0x0,%ecx
  800326:	b8 0c 00 00 00       	mov    $0xc,%eax
  80032b:	8b 55 08             	mov    0x8(%ebp),%edx
  80032e:	89 cb                	mov    %ecx,%ebx
  800330:	89 cf                	mov    %ecx,%edi
  800332:	89 ce                	mov    %ecx,%esi
  800334:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800336:	85 c0                	test   %eax,%eax
  800338:	7e 17                	jle    800351 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033a:	83 ec 0c             	sub    $0xc,%esp
  80033d:	50                   	push   %eax
  80033e:	6a 0c                	push   $0xc
  800340:	68 38 10 80 00       	push   $0x801038
  800345:	6a 23                	push   $0x23
  800347:	68 55 10 80 00       	push   $0x801055
  80034c:	e8 08 00 00 00       	call   800359 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800351:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800354:	5b                   	pop    %ebx
  800355:	5e                   	pop    %esi
  800356:	5f                   	pop    %edi
  800357:	5d                   	pop    %ebp
  800358:	c3                   	ret    

00800359 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800359:	55                   	push   %ebp
  80035a:	89 e5                	mov    %esp,%ebp
  80035c:	56                   	push   %esi
  80035d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80035e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800361:	8b 35 04 20 80 00    	mov    0x802004,%esi
  800367:	e8 00 fe ff ff       	call   80016c <sys_getenvid>
  80036c:	83 ec 0c             	sub    $0xc,%esp
  80036f:	ff 75 0c             	pushl  0xc(%ebp)
  800372:	ff 75 08             	pushl  0x8(%ebp)
  800375:	56                   	push   %esi
  800376:	50                   	push   %eax
  800377:	68 64 10 80 00       	push   $0x801064
  80037c:	e8 b1 00 00 00       	call   800432 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800381:	83 c4 18             	add    $0x18,%esp
  800384:	53                   	push   %ebx
  800385:	ff 75 10             	pushl  0x10(%ebp)
  800388:	e8 54 00 00 00       	call   8003e1 <vcprintf>
	cprintf("\n");
  80038d:	c7 04 24 2c 10 80 00 	movl   $0x80102c,(%esp)
  800394:	e8 99 00 00 00       	call   800432 <cprintf>
  800399:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80039c:	cc                   	int3   
  80039d:	eb fd                	jmp    80039c <_panic+0x43>

0080039f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	53                   	push   %ebx
  8003a3:	83 ec 04             	sub    $0x4,%esp
  8003a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003a9:	8b 13                	mov    (%ebx),%edx
  8003ab:	8d 42 01             	lea    0x1(%edx),%eax
  8003ae:	89 03                	mov    %eax,(%ebx)
  8003b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003bc:	75 1a                	jne    8003d8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003be:	83 ec 08             	sub    $0x8,%esp
  8003c1:	68 ff 00 00 00       	push   $0xff
  8003c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c9:	50                   	push   %eax
  8003ca:	e8 1f fd ff ff       	call   8000ee <sys_cputs>
		b->idx = 0;
  8003cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003d5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003df:	c9                   	leave  
  8003e0:	c3                   	ret    

008003e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
  8003e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003f1:	00 00 00 
	b.cnt = 0;
  8003f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003fe:	ff 75 0c             	pushl  0xc(%ebp)
  800401:	ff 75 08             	pushl  0x8(%ebp)
  800404:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80040a:	50                   	push   %eax
  80040b:	68 9f 03 80 00       	push   $0x80039f
  800410:	e8 1a 01 00 00       	call   80052f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800415:	83 c4 08             	add    $0x8,%esp
  800418:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80041e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800424:	50                   	push   %eax
  800425:	e8 c4 fc ff ff       	call   8000ee <sys_cputs>

	return b.cnt;
}
  80042a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800430:	c9                   	leave  
  800431:	c3                   	ret    

00800432 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800438:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80043b:	50                   	push   %eax
  80043c:	ff 75 08             	pushl  0x8(%ebp)
  80043f:	e8 9d ff ff ff       	call   8003e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 1c             	sub    $0x1c,%esp
  80044f:	89 c7                	mov    %eax,%edi
  800451:	89 d6                	mov    %edx,%esi
  800453:	8b 45 08             	mov    0x8(%ebp),%eax
  800456:	8b 55 0c             	mov    0xc(%ebp),%edx
  800459:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80045c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80045f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800462:	bb 00 00 00 00       	mov    $0x0,%ebx
  800467:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80046a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80046d:	39 d3                	cmp    %edx,%ebx
  80046f:	72 05                	jb     800476 <printnum+0x30>
  800471:	39 45 10             	cmp    %eax,0x10(%ebp)
  800474:	77 45                	ja     8004bb <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800476:	83 ec 0c             	sub    $0xc,%esp
  800479:	ff 75 18             	pushl  0x18(%ebp)
  80047c:	8b 45 14             	mov    0x14(%ebp),%eax
  80047f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800482:	53                   	push   %ebx
  800483:	ff 75 10             	pushl  0x10(%ebp)
  800486:	83 ec 08             	sub    $0x8,%esp
  800489:	ff 75 e4             	pushl  -0x1c(%ebp)
  80048c:	ff 75 e0             	pushl  -0x20(%ebp)
  80048f:	ff 75 dc             	pushl  -0x24(%ebp)
  800492:	ff 75 d8             	pushl  -0x28(%ebp)
  800495:	e8 e6 08 00 00       	call   800d80 <__udivdi3>
  80049a:	83 c4 18             	add    $0x18,%esp
  80049d:	52                   	push   %edx
  80049e:	50                   	push   %eax
  80049f:	89 f2                	mov    %esi,%edx
  8004a1:	89 f8                	mov    %edi,%eax
  8004a3:	e8 9e ff ff ff       	call   800446 <printnum>
  8004a8:	83 c4 20             	add    $0x20,%esp
  8004ab:	eb 18                	jmp    8004c5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	56                   	push   %esi
  8004b1:	ff 75 18             	pushl  0x18(%ebp)
  8004b4:	ff d7                	call   *%edi
  8004b6:	83 c4 10             	add    $0x10,%esp
  8004b9:	eb 03                	jmp    8004be <printnum+0x78>
  8004bb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004be:	83 eb 01             	sub    $0x1,%ebx
  8004c1:	85 db                	test   %ebx,%ebx
  8004c3:	7f e8                	jg     8004ad <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	56                   	push   %esi
  8004c9:	83 ec 04             	sub    $0x4,%esp
  8004cc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d2:	ff 75 dc             	pushl  -0x24(%ebp)
  8004d5:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d8:	e8 d3 09 00 00       	call   800eb0 <__umoddi3>
  8004dd:	83 c4 14             	add    $0x14,%esp
  8004e0:	0f be 80 88 10 80 00 	movsbl 0x801088(%eax),%eax
  8004e7:	50                   	push   %eax
  8004e8:	ff d7                	call   *%edi
}
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5f                   	pop    %edi
  8004f3:	5d                   	pop    %ebp
  8004f4:	c3                   	ret    

008004f5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f5:	55                   	push   %ebp
  8004f6:	89 e5                	mov    %esp,%ebp
  8004f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004fb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ff:	8b 10                	mov    (%eax),%edx
  800501:	3b 50 04             	cmp    0x4(%eax),%edx
  800504:	73 0a                	jae    800510 <sprintputch+0x1b>
		*b->buf++ = ch;
  800506:	8d 4a 01             	lea    0x1(%edx),%ecx
  800509:	89 08                	mov    %ecx,(%eax)
  80050b:	8b 45 08             	mov    0x8(%ebp),%eax
  80050e:	88 02                	mov    %al,(%edx)
}
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800518:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80051b:	50                   	push   %eax
  80051c:	ff 75 10             	pushl  0x10(%ebp)
  80051f:	ff 75 0c             	pushl  0xc(%ebp)
  800522:	ff 75 08             	pushl  0x8(%ebp)
  800525:	e8 05 00 00 00       	call   80052f <vprintfmt>
	va_end(ap);
}
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	c9                   	leave  
  80052e:	c3                   	ret    

0080052f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	57                   	push   %edi
  800533:	56                   	push   %esi
  800534:	53                   	push   %ebx
  800535:	83 ec 2c             	sub    $0x2c,%esp
  800538:	8b 75 08             	mov    0x8(%ebp),%esi
  80053b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800541:	eb 12                	jmp    800555 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800543:	85 c0                	test   %eax,%eax
  800545:	0f 84 42 04 00 00    	je     80098d <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	53                   	push   %ebx
  80054f:	50                   	push   %eax
  800550:	ff d6                	call   *%esi
  800552:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800555:	83 c7 01             	add    $0x1,%edi
  800558:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80055c:	83 f8 25             	cmp    $0x25,%eax
  80055f:	75 e2                	jne    800543 <vprintfmt+0x14>
  800561:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800565:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80056c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800573:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80057a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057f:	eb 07                	jmp    800588 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800584:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8d 47 01             	lea    0x1(%edi),%eax
  80058b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058e:	0f b6 07             	movzbl (%edi),%eax
  800591:	0f b6 d0             	movzbl %al,%edx
  800594:	83 e8 23             	sub    $0x23,%eax
  800597:	3c 55                	cmp    $0x55,%al
  800599:	0f 87 d3 03 00 00    	ja     800972 <vprintfmt+0x443>
  80059f:	0f b6 c0             	movzbl %al,%eax
  8005a2:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  8005a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005ac:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005b0:	eb d6                	jmp    800588 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ba:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005c0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005c4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005c7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005ca:	83 f9 09             	cmp    $0x9,%ecx
  8005cd:	77 3f                	ja     80060e <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005cf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005d2:	eb e9                	jmp    8005bd <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8b 00                	mov    (%eax),%eax
  8005d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005df:	8d 40 04             	lea    0x4(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e8:	eb 2a                	jmp    800614 <vprintfmt+0xe5>
  8005ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ed:	85 c0                	test   %eax,%eax
  8005ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f4:	0f 49 d0             	cmovns %eax,%edx
  8005f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005fd:	eb 89                	jmp    800588 <vprintfmt+0x59>
  8005ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800602:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800609:	e9 7a ff ff ff       	jmp    800588 <vprintfmt+0x59>
  80060e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800611:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800614:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800618:	0f 89 6a ff ff ff    	jns    800588 <vprintfmt+0x59>
				width = precision, precision = -1;
  80061e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800621:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800624:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80062b:	e9 58 ff ff ff       	jmp    800588 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800630:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800633:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800636:	e9 4d ff ff ff       	jmp    800588 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8d 78 04             	lea    0x4(%eax),%edi
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	ff 30                	pushl  (%eax)
  800647:	ff d6                	call   *%esi
			break;
  800649:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80064c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800652:	e9 fe fe ff ff       	jmp    800555 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 78 04             	lea    0x4(%eax),%edi
  80065d:	8b 00                	mov    (%eax),%eax
  80065f:	99                   	cltd   
  800660:	31 d0                	xor    %edx,%eax
  800662:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800664:	83 f8 08             	cmp    $0x8,%eax
  800667:	7f 0b                	jg     800674 <vprintfmt+0x145>
  800669:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  800670:	85 d2                	test   %edx,%edx
  800672:	75 1b                	jne    80068f <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800674:	50                   	push   %eax
  800675:	68 a0 10 80 00       	push   $0x8010a0
  80067a:	53                   	push   %ebx
  80067b:	56                   	push   %esi
  80067c:	e8 91 fe ff ff       	call   800512 <printfmt>
  800681:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800684:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800687:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80068a:	e9 c6 fe ff ff       	jmp    800555 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80068f:	52                   	push   %edx
  800690:	68 a9 10 80 00       	push   $0x8010a9
  800695:	53                   	push   %ebx
  800696:	56                   	push   %esi
  800697:	e8 76 fe ff ff       	call   800512 <printfmt>
  80069c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80069f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a5:	e9 ab fe ff ff       	jmp    800555 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	83 c0 04             	add    $0x4,%eax
  8006b0:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b6:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b8:	85 ff                	test   %edi,%edi
  8006ba:	b8 99 10 80 00       	mov    $0x801099,%eax
  8006bf:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006c6:	0f 8e 94 00 00 00    	jle    800760 <vprintfmt+0x231>
  8006cc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006d0:	0f 84 98 00 00 00    	je     80076e <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	ff 75 d0             	pushl  -0x30(%ebp)
  8006dc:	57                   	push   %edi
  8006dd:	e8 33 03 00 00       	call   800a15 <strnlen>
  8006e2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006e5:	29 c1                	sub    %eax,%ecx
  8006e7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006ea:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006ed:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f9:	eb 0f                	jmp    80070a <vprintfmt+0x1db>
					putch(padc, putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	53                   	push   %ebx
  8006ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800702:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800704:	83 ef 01             	sub    $0x1,%edi
  800707:	83 c4 10             	add    $0x10,%esp
  80070a:	85 ff                	test   %edi,%edi
  80070c:	7f ed                	jg     8006fb <vprintfmt+0x1cc>
  80070e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800711:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800714:	85 c9                	test   %ecx,%ecx
  800716:	b8 00 00 00 00       	mov    $0x0,%eax
  80071b:	0f 49 c1             	cmovns %ecx,%eax
  80071e:	29 c1                	sub    %eax,%ecx
  800720:	89 75 08             	mov    %esi,0x8(%ebp)
  800723:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800726:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800729:	89 cb                	mov    %ecx,%ebx
  80072b:	eb 4d                	jmp    80077a <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80072d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800731:	74 1b                	je     80074e <vprintfmt+0x21f>
  800733:	0f be c0             	movsbl %al,%eax
  800736:	83 e8 20             	sub    $0x20,%eax
  800739:	83 f8 5e             	cmp    $0x5e,%eax
  80073c:	76 10                	jbe    80074e <vprintfmt+0x21f>
					putch('?', putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	6a 3f                	push   $0x3f
  800746:	ff 55 08             	call   *0x8(%ebp)
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	eb 0d                	jmp    80075b <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80074e:	83 ec 08             	sub    $0x8,%esp
  800751:	ff 75 0c             	pushl  0xc(%ebp)
  800754:	52                   	push   %edx
  800755:	ff 55 08             	call   *0x8(%ebp)
  800758:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80075b:	83 eb 01             	sub    $0x1,%ebx
  80075e:	eb 1a                	jmp    80077a <vprintfmt+0x24b>
  800760:	89 75 08             	mov    %esi,0x8(%ebp)
  800763:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800766:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800769:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80076c:	eb 0c                	jmp    80077a <vprintfmt+0x24b>
  80076e:	89 75 08             	mov    %esi,0x8(%ebp)
  800771:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800774:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800777:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80077a:	83 c7 01             	add    $0x1,%edi
  80077d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800781:	0f be d0             	movsbl %al,%edx
  800784:	85 d2                	test   %edx,%edx
  800786:	74 23                	je     8007ab <vprintfmt+0x27c>
  800788:	85 f6                	test   %esi,%esi
  80078a:	78 a1                	js     80072d <vprintfmt+0x1fe>
  80078c:	83 ee 01             	sub    $0x1,%esi
  80078f:	79 9c                	jns    80072d <vprintfmt+0x1fe>
  800791:	89 df                	mov    %ebx,%edi
  800793:	8b 75 08             	mov    0x8(%ebp),%esi
  800796:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800799:	eb 18                	jmp    8007b3 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80079b:	83 ec 08             	sub    $0x8,%esp
  80079e:	53                   	push   %ebx
  80079f:	6a 20                	push   $0x20
  8007a1:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007a3:	83 ef 01             	sub    $0x1,%edi
  8007a6:	83 c4 10             	add    $0x10,%esp
  8007a9:	eb 08                	jmp    8007b3 <vprintfmt+0x284>
  8007ab:	89 df                	mov    %ebx,%edi
  8007ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007b3:	85 ff                	test   %edi,%edi
  8007b5:	7f e4                	jg     80079b <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007b7:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007ba:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c0:	e9 90 fd ff ff       	jmp    800555 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007c5:	83 f9 01             	cmp    $0x1,%ecx
  8007c8:	7e 19                	jle    8007e3 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	8b 50 04             	mov    0x4(%eax),%edx
  8007d0:	8b 00                	mov    (%eax),%eax
  8007d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8d 40 08             	lea    0x8(%eax),%eax
  8007de:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e1:	eb 38                	jmp    80081b <vprintfmt+0x2ec>
	else if (lflag)
  8007e3:	85 c9                	test   %ecx,%ecx
  8007e5:	74 1b                	je     800802 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8b 00                	mov    (%eax),%eax
  8007ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ef:	89 c1                	mov    %eax,%ecx
  8007f1:	c1 f9 1f             	sar    $0x1f,%ecx
  8007f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fa:	8d 40 04             	lea    0x4(%eax),%eax
  8007fd:	89 45 14             	mov    %eax,0x14(%ebp)
  800800:	eb 19                	jmp    80081b <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800802:	8b 45 14             	mov    0x14(%ebp),%eax
  800805:	8b 00                	mov    (%eax),%eax
  800807:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080a:	89 c1                	mov    %eax,%ecx
  80080c:	c1 f9 1f             	sar    $0x1f,%ecx
  80080f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8d 40 04             	lea    0x4(%eax),%eax
  800818:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80081b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80081e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800821:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800826:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80082a:	0f 89 0e 01 00 00    	jns    80093e <vprintfmt+0x40f>
				putch('-', putdat);
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	53                   	push   %ebx
  800834:	6a 2d                	push   $0x2d
  800836:	ff d6                	call   *%esi
				num = -(long long) num;
  800838:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80083b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80083e:	f7 da                	neg    %edx
  800840:	83 d1 00             	adc    $0x0,%ecx
  800843:	f7 d9                	neg    %ecx
  800845:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800848:	b8 0a 00 00 00       	mov    $0xa,%eax
  80084d:	e9 ec 00 00 00       	jmp    80093e <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800852:	83 f9 01             	cmp    $0x1,%ecx
  800855:	7e 18                	jle    80086f <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800857:	8b 45 14             	mov    0x14(%ebp),%eax
  80085a:	8b 10                	mov    (%eax),%edx
  80085c:	8b 48 04             	mov    0x4(%eax),%ecx
  80085f:	8d 40 08             	lea    0x8(%eax),%eax
  800862:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800865:	b8 0a 00 00 00       	mov    $0xa,%eax
  80086a:	e9 cf 00 00 00       	jmp    80093e <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80086f:	85 c9                	test   %ecx,%ecx
  800871:	74 1a                	je     80088d <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8b 10                	mov    (%eax),%edx
  800878:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087d:	8d 40 04             	lea    0x4(%eax),%eax
  800880:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800883:	b8 0a 00 00 00       	mov    $0xa,%eax
  800888:	e9 b1 00 00 00       	jmp    80093e <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80088d:	8b 45 14             	mov    0x14(%ebp),%eax
  800890:	8b 10                	mov    (%eax),%edx
  800892:	b9 00 00 00 00       	mov    $0x0,%ecx
  800897:	8d 40 04             	lea    0x4(%eax),%eax
  80089a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80089d:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008a2:	e9 97 00 00 00       	jmp    80093e <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008a7:	83 ec 08             	sub    $0x8,%esp
  8008aa:	53                   	push   %ebx
  8008ab:	6a 58                	push   $0x58
  8008ad:	ff d6                	call   *%esi
			putch('X', putdat);
  8008af:	83 c4 08             	add    $0x8,%esp
  8008b2:	53                   	push   %ebx
  8008b3:	6a 58                	push   $0x58
  8008b5:	ff d6                	call   *%esi
			putch('X', putdat);
  8008b7:	83 c4 08             	add    $0x8,%esp
  8008ba:	53                   	push   %ebx
  8008bb:	6a 58                	push   $0x58
  8008bd:	ff d6                	call   *%esi
			break;
  8008bf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008c5:	e9 8b fc ff ff       	jmp    800555 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8008ca:	83 ec 08             	sub    $0x8,%esp
  8008cd:	53                   	push   %ebx
  8008ce:	6a 30                	push   $0x30
  8008d0:	ff d6                	call   *%esi
			putch('x', putdat);
  8008d2:	83 c4 08             	add    $0x8,%esp
  8008d5:	53                   	push   %ebx
  8008d6:	6a 78                	push   $0x78
  8008d8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008da:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dd:	8b 10                	mov    (%eax),%edx
  8008df:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008e4:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008e7:	8d 40 04             	lea    0x4(%eax),%eax
  8008ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ed:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008f2:	eb 4a                	jmp    80093e <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008f4:	83 f9 01             	cmp    $0x1,%ecx
  8008f7:	7e 15                	jle    80090e <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fc:	8b 10                	mov    (%eax),%edx
  8008fe:	8b 48 04             	mov    0x4(%eax),%ecx
  800901:	8d 40 08             	lea    0x8(%eax),%eax
  800904:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800907:	b8 10 00 00 00       	mov    $0x10,%eax
  80090c:	eb 30                	jmp    80093e <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80090e:	85 c9                	test   %ecx,%ecx
  800910:	74 17                	je     800929 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800912:	8b 45 14             	mov    0x14(%ebp),%eax
  800915:	8b 10                	mov    (%eax),%edx
  800917:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091c:	8d 40 04             	lea    0x4(%eax),%eax
  80091f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800922:	b8 10 00 00 00       	mov    $0x10,%eax
  800927:	eb 15                	jmp    80093e <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800929:	8b 45 14             	mov    0x14(%ebp),%eax
  80092c:	8b 10                	mov    (%eax),%edx
  80092e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800933:	8d 40 04             	lea    0x4(%eax),%eax
  800936:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800939:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80093e:	83 ec 0c             	sub    $0xc,%esp
  800941:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800945:	57                   	push   %edi
  800946:	ff 75 e0             	pushl  -0x20(%ebp)
  800949:	50                   	push   %eax
  80094a:	51                   	push   %ecx
  80094b:	52                   	push   %edx
  80094c:	89 da                	mov    %ebx,%edx
  80094e:	89 f0                	mov    %esi,%eax
  800950:	e8 f1 fa ff ff       	call   800446 <printnum>
			break;
  800955:	83 c4 20             	add    $0x20,%esp
  800958:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80095b:	e9 f5 fb ff ff       	jmp    800555 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800960:	83 ec 08             	sub    $0x8,%esp
  800963:	53                   	push   %ebx
  800964:	52                   	push   %edx
  800965:	ff d6                	call   *%esi
			break;
  800967:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80096a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80096d:	e9 e3 fb ff ff       	jmp    800555 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800972:	83 ec 08             	sub    $0x8,%esp
  800975:	53                   	push   %ebx
  800976:	6a 25                	push   $0x25
  800978:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80097a:	83 c4 10             	add    $0x10,%esp
  80097d:	eb 03                	jmp    800982 <vprintfmt+0x453>
  80097f:	83 ef 01             	sub    $0x1,%edi
  800982:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800986:	75 f7                	jne    80097f <vprintfmt+0x450>
  800988:	e9 c8 fb ff ff       	jmp    800555 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80098d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800990:	5b                   	pop    %ebx
  800991:	5e                   	pop    %esi
  800992:	5f                   	pop    %edi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	83 ec 18             	sub    $0x18,%esp
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009a4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009b2:	85 c0                	test   %eax,%eax
  8009b4:	74 26                	je     8009dc <vsnprintf+0x47>
  8009b6:	85 d2                	test   %edx,%edx
  8009b8:	7e 22                	jle    8009dc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ba:	ff 75 14             	pushl  0x14(%ebp)
  8009bd:	ff 75 10             	pushl  0x10(%ebp)
  8009c0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009c3:	50                   	push   %eax
  8009c4:	68 f5 04 80 00       	push   $0x8004f5
  8009c9:	e8 61 fb ff ff       	call   80052f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009d1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d7:	83 c4 10             	add    $0x10,%esp
  8009da:	eb 05                	jmp    8009e1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009e1:	c9                   	leave  
  8009e2:	c3                   	ret    

008009e3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ec:	50                   	push   %eax
  8009ed:	ff 75 10             	pushl  0x10(%ebp)
  8009f0:	ff 75 0c             	pushl  0xc(%ebp)
  8009f3:	ff 75 08             	pushl  0x8(%ebp)
  8009f6:	e8 9a ff ff ff       	call   800995 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009fb:	c9                   	leave  
  8009fc:	c3                   	ret    

008009fd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
  800a08:	eb 03                	jmp    800a0d <strlen+0x10>
		n++;
  800a0a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a11:	75 f7                	jne    800a0a <strlen+0xd>
		n++;
	return n;
}
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a23:	eb 03                	jmp    800a28 <strnlen+0x13>
		n++;
  800a25:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a28:	39 c2                	cmp    %eax,%edx
  800a2a:	74 08                	je     800a34 <strnlen+0x1f>
  800a2c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a30:	75 f3                	jne    800a25 <strnlen+0x10>
  800a32:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	53                   	push   %ebx
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a40:	89 c2                	mov    %eax,%edx
  800a42:	83 c2 01             	add    $0x1,%edx
  800a45:	83 c1 01             	add    $0x1,%ecx
  800a48:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a4c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a4f:	84 db                	test   %bl,%bl
  800a51:	75 ef                	jne    800a42 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a53:	5b                   	pop    %ebx
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	53                   	push   %ebx
  800a5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a5d:	53                   	push   %ebx
  800a5e:	e8 9a ff ff ff       	call   8009fd <strlen>
  800a63:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a66:	ff 75 0c             	pushl  0xc(%ebp)
  800a69:	01 d8                	add    %ebx,%eax
  800a6b:	50                   	push   %eax
  800a6c:	e8 c5 ff ff ff       	call   800a36 <strcpy>
	return dst;
}
  800a71:	89 d8                	mov    %ebx,%eax
  800a73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a83:	89 f3                	mov    %esi,%ebx
  800a85:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a88:	89 f2                	mov    %esi,%edx
  800a8a:	eb 0f                	jmp    800a9b <strncpy+0x23>
		*dst++ = *src;
  800a8c:	83 c2 01             	add    $0x1,%edx
  800a8f:	0f b6 01             	movzbl (%ecx),%eax
  800a92:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a95:	80 39 01             	cmpb   $0x1,(%ecx)
  800a98:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a9b:	39 da                	cmp    %ebx,%edx
  800a9d:	75 ed                	jne    800a8c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a9f:	89 f0                	mov    %esi,%eax
  800aa1:	5b                   	pop    %ebx
  800aa2:	5e                   	pop    %esi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	56                   	push   %esi
  800aa9:	53                   	push   %ebx
  800aaa:	8b 75 08             	mov    0x8(%ebp),%esi
  800aad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab0:	8b 55 10             	mov    0x10(%ebp),%edx
  800ab3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ab5:	85 d2                	test   %edx,%edx
  800ab7:	74 21                	je     800ada <strlcpy+0x35>
  800ab9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800abd:	89 f2                	mov    %esi,%edx
  800abf:	eb 09                	jmp    800aca <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ac1:	83 c2 01             	add    $0x1,%edx
  800ac4:	83 c1 01             	add    $0x1,%ecx
  800ac7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aca:	39 c2                	cmp    %eax,%edx
  800acc:	74 09                	je     800ad7 <strlcpy+0x32>
  800ace:	0f b6 19             	movzbl (%ecx),%ebx
  800ad1:	84 db                	test   %bl,%bl
  800ad3:	75 ec                	jne    800ac1 <strlcpy+0x1c>
  800ad5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ad7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ada:	29 f0                	sub    %esi,%eax
}
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ae9:	eb 06                	jmp    800af1 <strcmp+0x11>
		p++, q++;
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800af1:	0f b6 01             	movzbl (%ecx),%eax
  800af4:	84 c0                	test   %al,%al
  800af6:	74 04                	je     800afc <strcmp+0x1c>
  800af8:	3a 02                	cmp    (%edx),%al
  800afa:	74 ef                	je     800aeb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800afc:	0f b6 c0             	movzbl %al,%eax
  800aff:	0f b6 12             	movzbl (%edx),%edx
  800b02:	29 d0                	sub    %edx,%eax
}
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	53                   	push   %ebx
  800b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b10:	89 c3                	mov    %eax,%ebx
  800b12:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b15:	eb 06                	jmp    800b1d <strncmp+0x17>
		n--, p++, q++;
  800b17:	83 c0 01             	add    $0x1,%eax
  800b1a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b1d:	39 d8                	cmp    %ebx,%eax
  800b1f:	74 15                	je     800b36 <strncmp+0x30>
  800b21:	0f b6 08             	movzbl (%eax),%ecx
  800b24:	84 c9                	test   %cl,%cl
  800b26:	74 04                	je     800b2c <strncmp+0x26>
  800b28:	3a 0a                	cmp    (%edx),%cl
  800b2a:	74 eb                	je     800b17 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b2c:	0f b6 00             	movzbl (%eax),%eax
  800b2f:	0f b6 12             	movzbl (%edx),%edx
  800b32:	29 d0                	sub    %edx,%eax
  800b34:	eb 05                	jmp    800b3b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b36:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b3b:	5b                   	pop    %ebx
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	8b 45 08             	mov    0x8(%ebp),%eax
  800b44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b48:	eb 07                	jmp    800b51 <strchr+0x13>
		if (*s == c)
  800b4a:	38 ca                	cmp    %cl,%dl
  800b4c:	74 0f                	je     800b5d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b4e:	83 c0 01             	add    $0x1,%eax
  800b51:	0f b6 10             	movzbl (%eax),%edx
  800b54:	84 d2                	test   %dl,%dl
  800b56:	75 f2                	jne    800b4a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	8b 45 08             	mov    0x8(%ebp),%eax
  800b65:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b69:	eb 03                	jmp    800b6e <strfind+0xf>
  800b6b:	83 c0 01             	add    $0x1,%eax
  800b6e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b71:	38 ca                	cmp    %cl,%dl
  800b73:	74 04                	je     800b79 <strfind+0x1a>
  800b75:	84 d2                	test   %dl,%dl
  800b77:	75 f2                	jne    800b6b <strfind+0xc>
			break;
	return (char *) s;
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b84:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b87:	85 c9                	test   %ecx,%ecx
  800b89:	74 36                	je     800bc1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b8b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b91:	75 28                	jne    800bbb <memset+0x40>
  800b93:	f6 c1 03             	test   $0x3,%cl
  800b96:	75 23                	jne    800bbb <memset+0x40>
		c &= 0xFF;
  800b98:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b9c:	89 d3                	mov    %edx,%ebx
  800b9e:	c1 e3 08             	shl    $0x8,%ebx
  800ba1:	89 d6                	mov    %edx,%esi
  800ba3:	c1 e6 18             	shl    $0x18,%esi
  800ba6:	89 d0                	mov    %edx,%eax
  800ba8:	c1 e0 10             	shl    $0x10,%eax
  800bab:	09 f0                	or     %esi,%eax
  800bad:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800baf:	89 d8                	mov    %ebx,%eax
  800bb1:	09 d0                	or     %edx,%eax
  800bb3:	c1 e9 02             	shr    $0x2,%ecx
  800bb6:	fc                   	cld    
  800bb7:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb9:	eb 06                	jmp    800bc1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbe:	fc                   	cld    
  800bbf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bc1:	89 f8                	mov    %edi,%eax
  800bc3:	5b                   	pop    %ebx
  800bc4:	5e                   	pop    %esi
  800bc5:	5f                   	pop    %edi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bd6:	39 c6                	cmp    %eax,%esi
  800bd8:	73 35                	jae    800c0f <memmove+0x47>
  800bda:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bdd:	39 d0                	cmp    %edx,%eax
  800bdf:	73 2e                	jae    800c0f <memmove+0x47>
		s += n;
		d += n;
  800be1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be4:	89 d6                	mov    %edx,%esi
  800be6:	09 fe                	or     %edi,%esi
  800be8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bee:	75 13                	jne    800c03 <memmove+0x3b>
  800bf0:	f6 c1 03             	test   $0x3,%cl
  800bf3:	75 0e                	jne    800c03 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bf5:	83 ef 04             	sub    $0x4,%edi
  800bf8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bfb:	c1 e9 02             	shr    $0x2,%ecx
  800bfe:	fd                   	std    
  800bff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c01:	eb 09                	jmp    800c0c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c03:	83 ef 01             	sub    $0x1,%edi
  800c06:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c09:	fd                   	std    
  800c0a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c0c:	fc                   	cld    
  800c0d:	eb 1d                	jmp    800c2c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0f:	89 f2                	mov    %esi,%edx
  800c11:	09 c2                	or     %eax,%edx
  800c13:	f6 c2 03             	test   $0x3,%dl
  800c16:	75 0f                	jne    800c27 <memmove+0x5f>
  800c18:	f6 c1 03             	test   $0x3,%cl
  800c1b:	75 0a                	jne    800c27 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c1d:	c1 e9 02             	shr    $0x2,%ecx
  800c20:	89 c7                	mov    %eax,%edi
  800c22:	fc                   	cld    
  800c23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c25:	eb 05                	jmp    800c2c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c27:	89 c7                	mov    %eax,%edi
  800c29:	fc                   	cld    
  800c2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c33:	ff 75 10             	pushl  0x10(%ebp)
  800c36:	ff 75 0c             	pushl  0xc(%ebp)
  800c39:	ff 75 08             	pushl  0x8(%ebp)
  800c3c:	e8 87 ff ff ff       	call   800bc8 <memmove>
}
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c4e:	89 c6                	mov    %eax,%esi
  800c50:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c53:	eb 1a                	jmp    800c6f <memcmp+0x2c>
		if (*s1 != *s2)
  800c55:	0f b6 08             	movzbl (%eax),%ecx
  800c58:	0f b6 1a             	movzbl (%edx),%ebx
  800c5b:	38 d9                	cmp    %bl,%cl
  800c5d:	74 0a                	je     800c69 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c5f:	0f b6 c1             	movzbl %cl,%eax
  800c62:	0f b6 db             	movzbl %bl,%ebx
  800c65:	29 d8                	sub    %ebx,%eax
  800c67:	eb 0f                	jmp    800c78 <memcmp+0x35>
		s1++, s2++;
  800c69:	83 c0 01             	add    $0x1,%eax
  800c6c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6f:	39 f0                	cmp    %esi,%eax
  800c71:	75 e2                	jne    800c55 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5d                   	pop    %ebp
  800c7b:	c3                   	ret    

00800c7c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c7c:	55                   	push   %ebp
  800c7d:	89 e5                	mov    %esp,%ebp
  800c7f:	53                   	push   %ebx
  800c80:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c83:	89 c1                	mov    %eax,%ecx
  800c85:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c88:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c8c:	eb 0a                	jmp    800c98 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c8e:	0f b6 10             	movzbl (%eax),%edx
  800c91:	39 da                	cmp    %ebx,%edx
  800c93:	74 07                	je     800c9c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c95:	83 c0 01             	add    $0x1,%eax
  800c98:	39 c8                	cmp    %ecx,%eax
  800c9a:	72 f2                	jb     800c8e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c9c:	5b                   	pop    %ebx
  800c9d:	5d                   	pop    %ebp
  800c9e:	c3                   	ret    

00800c9f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	57                   	push   %edi
  800ca3:	56                   	push   %esi
  800ca4:	53                   	push   %ebx
  800ca5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cab:	eb 03                	jmp    800cb0 <strtol+0x11>
		s++;
  800cad:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb0:	0f b6 01             	movzbl (%ecx),%eax
  800cb3:	3c 20                	cmp    $0x20,%al
  800cb5:	74 f6                	je     800cad <strtol+0xe>
  800cb7:	3c 09                	cmp    $0x9,%al
  800cb9:	74 f2                	je     800cad <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cbb:	3c 2b                	cmp    $0x2b,%al
  800cbd:	75 0a                	jne    800cc9 <strtol+0x2a>
		s++;
  800cbf:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc2:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc7:	eb 11                	jmp    800cda <strtol+0x3b>
  800cc9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cce:	3c 2d                	cmp    $0x2d,%al
  800cd0:	75 08                	jne    800cda <strtol+0x3b>
		s++, neg = 1;
  800cd2:	83 c1 01             	add    $0x1,%ecx
  800cd5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cda:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ce0:	75 15                	jne    800cf7 <strtol+0x58>
  800ce2:	80 39 30             	cmpb   $0x30,(%ecx)
  800ce5:	75 10                	jne    800cf7 <strtol+0x58>
  800ce7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ceb:	75 7c                	jne    800d69 <strtol+0xca>
		s += 2, base = 16;
  800ced:	83 c1 02             	add    $0x2,%ecx
  800cf0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cf5:	eb 16                	jmp    800d0d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cf7:	85 db                	test   %ebx,%ebx
  800cf9:	75 12                	jne    800d0d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cfb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d00:	80 39 30             	cmpb   $0x30,(%ecx)
  800d03:	75 08                	jne    800d0d <strtol+0x6e>
		s++, base = 8;
  800d05:	83 c1 01             	add    $0x1,%ecx
  800d08:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d12:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d15:	0f b6 11             	movzbl (%ecx),%edx
  800d18:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d1b:	89 f3                	mov    %esi,%ebx
  800d1d:	80 fb 09             	cmp    $0x9,%bl
  800d20:	77 08                	ja     800d2a <strtol+0x8b>
			dig = *s - '0';
  800d22:	0f be d2             	movsbl %dl,%edx
  800d25:	83 ea 30             	sub    $0x30,%edx
  800d28:	eb 22                	jmp    800d4c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d2a:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d2d:	89 f3                	mov    %esi,%ebx
  800d2f:	80 fb 19             	cmp    $0x19,%bl
  800d32:	77 08                	ja     800d3c <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d34:	0f be d2             	movsbl %dl,%edx
  800d37:	83 ea 57             	sub    $0x57,%edx
  800d3a:	eb 10                	jmp    800d4c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d3c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d3f:	89 f3                	mov    %esi,%ebx
  800d41:	80 fb 19             	cmp    $0x19,%bl
  800d44:	77 16                	ja     800d5c <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d46:	0f be d2             	movsbl %dl,%edx
  800d49:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d4c:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d4f:	7d 0b                	jge    800d5c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d51:	83 c1 01             	add    $0x1,%ecx
  800d54:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d58:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d5a:	eb b9                	jmp    800d15 <strtol+0x76>

	if (endptr)
  800d5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d60:	74 0d                	je     800d6f <strtol+0xd0>
		*endptr = (char *) s;
  800d62:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d65:	89 0e                	mov    %ecx,(%esi)
  800d67:	eb 06                	jmp    800d6f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d69:	85 db                	test   %ebx,%ebx
  800d6b:	74 98                	je     800d05 <strtol+0x66>
  800d6d:	eb 9e                	jmp    800d0d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d6f:	89 c2                	mov    %eax,%edx
  800d71:	f7 da                	neg    %edx
  800d73:	85 ff                	test   %edi,%edi
  800d75:	0f 45 c2             	cmovne %edx,%eax
}
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    
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
