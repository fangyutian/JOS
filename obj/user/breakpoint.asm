
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
  80003c:	57                   	push   %edi
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800042:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800049:	00 00 00 
	envid_t eid = sys_getenvid();
  80004c:	e8 06 01 00 00       	call   800157 <sys_getenvid>
  800051:	8b 3d 04 20 80 00    	mov    0x802004,%edi
  800057:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80005c:	be 00 00 00 00       	mov    $0x0,%esi
	int i;
	for (i = 0; i < NENV; i++) {
  800061:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == eid) {
  800066:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800069:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  80006f:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &(envs[i]);
  800072:	39 c8                	cmp    %ecx,%eax
  800074:	0f 44 fb             	cmove  %ebx,%edi
  800077:	b9 01 00 00 00       	mov    $0x1,%ecx
  80007c:	0f 44 f1             	cmove  %ecx,%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
	envid_t eid = sys_getenvid();
	int i;
	for (i = 0; i < NENV; i++) {
  80007f:	83 c2 01             	add    $0x1,%edx
  800082:	83 c3 7c             	add    $0x7c,%ebx
  800085:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  80008b:	75 d9                	jne    800066 <libmain+0x2d>
  80008d:	89 f0                	mov    %esi,%eax
  80008f:	84 c0                	test   %al,%al
  800091:	74 06                	je     800099 <libmain+0x60>
  800093:	89 3d 04 20 80 00    	mov    %edi,0x802004
			thisenv = &(envs[i]);
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800099:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80009d:	7e 0a                	jle    8000a9 <libmain+0x70>
		binaryname = argv[0];
  80009f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000a2:	8b 00                	mov    (%eax),%eax
  8000a4:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a9:	83 ec 08             	sub    $0x8,%esp
  8000ac:	ff 75 0c             	pushl  0xc(%ebp)
  8000af:	ff 75 08             	pushl  0x8(%ebp)
  8000b2:	e8 7c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0b 00 00 00       	call   8000c7 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5f                   	pop    %edi
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    

008000c7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000cd:	6a 00                	push   $0x0
  8000cf:	e8 42 00 00 00       	call   800116 <sys_env_destroy>
}
  8000d4:	83 c4 10             	add    $0x10,%esp
  8000d7:	c9                   	leave  
  8000d8:	c3                   	ret    

008000d9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000d9:	55                   	push   %ebp
  8000da:	89 e5                	mov    %esp,%ebp
  8000dc:	57                   	push   %edi
  8000dd:	56                   	push   %esi
  8000de:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b8 00 00 00 00       	mov    $0x0,%eax
  8000e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ea:	89 c3                	mov    %eax,%ebx
  8000ec:	89 c7                	mov    %eax,%edi
  8000ee:	89 c6                	mov    %eax,%esi
  8000f0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	57                   	push   %edi
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800102:	b8 01 00 00 00       	mov    $0x1,%eax
  800107:	89 d1                	mov    %edx,%ecx
  800109:	89 d3                	mov    %edx,%ebx
  80010b:	89 d7                	mov    %edx,%edi
  80010d:	89 d6                	mov    %edx,%esi
  80010f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5f                   	pop    %edi
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	57                   	push   %edi
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
  80011c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800124:	b8 03 00 00 00       	mov    $0x3,%eax
  800129:	8b 55 08             	mov    0x8(%ebp),%edx
  80012c:	89 cb                	mov    %ecx,%ebx
  80012e:	89 cf                	mov    %ecx,%edi
  800130:	89 ce                	mov    %ecx,%esi
  800132:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800134:	85 c0                	test   %eax,%eax
  800136:	7e 17                	jle    80014f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800138:	83 ec 0c             	sub    $0xc,%esp
  80013b:	50                   	push   %eax
  80013c:	6a 03                	push   $0x3
  80013e:	68 0a 10 80 00       	push   $0x80100a
  800143:	6a 23                	push   $0x23
  800145:	68 27 10 80 00       	push   $0x801027
  80014a:	e8 f5 01 00 00       	call   800344 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800152:	5b                   	pop    %ebx
  800153:	5e                   	pop    %esi
  800154:	5f                   	pop    %edi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	57                   	push   %edi
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015d:	ba 00 00 00 00       	mov    $0x0,%edx
  800162:	b8 02 00 00 00       	mov    $0x2,%eax
  800167:	89 d1                	mov    %edx,%ecx
  800169:	89 d3                	mov    %edx,%ebx
  80016b:	89 d7                	mov    %edx,%edi
  80016d:	89 d6                	mov    %edx,%esi
  80016f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800171:	5b                   	pop    %ebx
  800172:	5e                   	pop    %esi
  800173:	5f                   	pop    %edi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    

00800176 <sys_yield>:

void
sys_yield(void)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	57                   	push   %edi
  80017a:	56                   	push   %esi
  80017b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017c:	ba 00 00 00 00       	mov    $0x0,%edx
  800181:	b8 0a 00 00 00       	mov    $0xa,%eax
  800186:	89 d1                	mov    %edx,%ecx
  800188:	89 d3                	mov    %edx,%ebx
  80018a:	89 d7                	mov    %edx,%edi
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5f                   	pop    %edi
  800193:	5d                   	pop    %ebp
  800194:	c3                   	ret    

00800195 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019e:	be 00 00 00 00       	mov    $0x0,%esi
  8001a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b1:	89 f7                	mov    %esi,%edi
  8001b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b5:	85 c0                	test   %eax,%eax
  8001b7:	7e 17                	jle    8001d0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b9:	83 ec 0c             	sub    $0xc,%esp
  8001bc:	50                   	push   %eax
  8001bd:	6a 04                	push   $0x4
  8001bf:	68 0a 10 80 00       	push   $0x80100a
  8001c4:	6a 23                	push   $0x23
  8001c6:	68 27 10 80 00       	push   $0x801027
  8001cb:	e8 74 01 00 00       	call   800344 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d3:	5b                   	pop    %ebx
  8001d4:	5e                   	pop    %esi
  8001d5:	5f                   	pop    %edi
  8001d6:	5d                   	pop    %ebp
  8001d7:	c3                   	ret    

008001d8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	57                   	push   %edi
  8001dc:	56                   	push   %esi
  8001dd:	53                   	push   %ebx
  8001de:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ef:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	7e 17                	jle    800212 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fb:	83 ec 0c             	sub    $0xc,%esp
  8001fe:	50                   	push   %eax
  8001ff:	6a 05                	push   $0x5
  800201:	68 0a 10 80 00       	push   $0x80100a
  800206:	6a 23                	push   $0x23
  800208:	68 27 10 80 00       	push   $0x801027
  80020d:	e8 32 01 00 00       	call   800344 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800212:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5f                   	pop    %edi
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    

0080021a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	57                   	push   %edi
  80021e:	56                   	push   %esi
  80021f:	53                   	push   %ebx
  800220:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800223:	bb 00 00 00 00       	mov    $0x0,%ebx
  800228:	b8 06 00 00 00       	mov    $0x6,%eax
  80022d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800230:	8b 55 08             	mov    0x8(%ebp),%edx
  800233:	89 df                	mov    %ebx,%edi
  800235:	89 de                	mov    %ebx,%esi
  800237:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800239:	85 c0                	test   %eax,%eax
  80023b:	7e 17                	jle    800254 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023d:	83 ec 0c             	sub    $0xc,%esp
  800240:	50                   	push   %eax
  800241:	6a 06                	push   $0x6
  800243:	68 0a 10 80 00       	push   $0x80100a
  800248:	6a 23                	push   $0x23
  80024a:	68 27 10 80 00       	push   $0x801027
  80024f:	e8 f0 00 00 00       	call   800344 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800257:	5b                   	pop    %ebx
  800258:	5e                   	pop    %esi
  800259:	5f                   	pop    %edi
  80025a:	5d                   	pop    %ebp
  80025b:	c3                   	ret    

0080025c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
  800262:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800265:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026a:	b8 08 00 00 00       	mov    $0x8,%eax
  80026f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800272:	8b 55 08             	mov    0x8(%ebp),%edx
  800275:	89 df                	mov    %ebx,%edi
  800277:	89 de                	mov    %ebx,%esi
  800279:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027b:	85 c0                	test   %eax,%eax
  80027d:	7e 17                	jle    800296 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027f:	83 ec 0c             	sub    $0xc,%esp
  800282:	50                   	push   %eax
  800283:	6a 08                	push   $0x8
  800285:	68 0a 10 80 00       	push   $0x80100a
  80028a:	6a 23                	push   $0x23
  80028c:	68 27 10 80 00       	push   $0x801027
  800291:	e8 ae 00 00 00       	call   800344 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    

0080029e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80029e:	55                   	push   %ebp
  80029f:	89 e5                	mov    %esp,%ebp
  8002a1:	57                   	push   %edi
  8002a2:	56                   	push   %esi
  8002a3:	53                   	push   %ebx
  8002a4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ac:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b7:	89 df                	mov    %ebx,%edi
  8002b9:	89 de                	mov    %ebx,%esi
  8002bb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002bd:	85 c0                	test   %eax,%eax
  8002bf:	7e 17                	jle    8002d8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c1:	83 ec 0c             	sub    $0xc,%esp
  8002c4:	50                   	push   %eax
  8002c5:	6a 09                	push   $0x9
  8002c7:	68 0a 10 80 00       	push   $0x80100a
  8002cc:	6a 23                	push   $0x23
  8002ce:	68 27 10 80 00       	push   $0x801027
  8002d3:	e8 6c 00 00 00       	call   800344 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002db:	5b                   	pop    %ebx
  8002dc:	5e                   	pop    %esi
  8002dd:	5f                   	pop    %edi
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e6:	be 00 00 00 00       	mov    $0x0,%esi
  8002eb:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002f9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002fe:	5b                   	pop    %ebx
  8002ff:	5e                   	pop    %esi
  800300:	5f                   	pop    %edi
  800301:	5d                   	pop    %ebp
  800302:	c3                   	ret    

00800303 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
  800306:	57                   	push   %edi
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
  800309:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800311:	b8 0c 00 00 00       	mov    $0xc,%eax
  800316:	8b 55 08             	mov    0x8(%ebp),%edx
  800319:	89 cb                	mov    %ecx,%ebx
  80031b:	89 cf                	mov    %ecx,%edi
  80031d:	89 ce                	mov    %ecx,%esi
  80031f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800321:	85 c0                	test   %eax,%eax
  800323:	7e 17                	jle    80033c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	50                   	push   %eax
  800329:	6a 0c                	push   $0xc
  80032b:	68 0a 10 80 00       	push   $0x80100a
  800330:	6a 23                	push   $0x23
  800332:	68 27 10 80 00       	push   $0x801027
  800337:	e8 08 00 00 00       	call   800344 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033f:	5b                   	pop    %ebx
  800340:	5e                   	pop    %esi
  800341:	5f                   	pop    %edi
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    

00800344 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800344:	55                   	push   %ebp
  800345:	89 e5                	mov    %esp,%ebp
  800347:	56                   	push   %esi
  800348:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800349:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80034c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800352:	e8 00 fe ff ff       	call   800157 <sys_getenvid>
  800357:	83 ec 0c             	sub    $0xc,%esp
  80035a:	ff 75 0c             	pushl  0xc(%ebp)
  80035d:	ff 75 08             	pushl  0x8(%ebp)
  800360:	56                   	push   %esi
  800361:	50                   	push   %eax
  800362:	68 38 10 80 00       	push   $0x801038
  800367:	e8 b1 00 00 00       	call   80041d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036c:	83 c4 18             	add    $0x18,%esp
  80036f:	53                   	push   %ebx
  800370:	ff 75 10             	pushl  0x10(%ebp)
  800373:	e8 54 00 00 00       	call   8003cc <vcprintf>
	cprintf("\n");
  800378:	c7 04 24 5c 10 80 00 	movl   $0x80105c,(%esp)
  80037f:	e8 99 00 00 00       	call   80041d <cprintf>
  800384:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800387:	cc                   	int3   
  800388:	eb fd                	jmp    800387 <_panic+0x43>

0080038a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	53                   	push   %ebx
  80038e:	83 ec 04             	sub    $0x4,%esp
  800391:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800394:	8b 13                	mov    (%ebx),%edx
  800396:	8d 42 01             	lea    0x1(%edx),%eax
  800399:	89 03                	mov    %eax,(%ebx)
  80039b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a7:	75 1a                	jne    8003c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	68 ff 00 00 00       	push   $0xff
  8003b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b4:	50                   	push   %eax
  8003b5:	e8 1f fd ff ff       	call   8000d9 <sys_cputs>
		b->idx = 0;
  8003ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ca:	c9                   	leave  
  8003cb:	c3                   	ret    

008003cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003dc:	00 00 00 
	b.cnt = 0;
  8003df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e9:	ff 75 0c             	pushl  0xc(%ebp)
  8003ec:	ff 75 08             	pushl  0x8(%ebp)
  8003ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f5:	50                   	push   %eax
  8003f6:	68 8a 03 80 00       	push   $0x80038a
  8003fb:	e8 1a 01 00 00       	call   80051a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800409:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040f:	50                   	push   %eax
  800410:	e8 c4 fc ff ff       	call   8000d9 <sys_cputs>

	return b.cnt;
}
  800415:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80041b:	c9                   	leave  
  80041c:	c3                   	ret    

0080041d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800423:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800426:	50                   	push   %eax
  800427:	ff 75 08             	pushl  0x8(%ebp)
  80042a:	e8 9d ff ff ff       	call   8003cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80042f:	c9                   	leave  
  800430:	c3                   	ret    

00800431 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	57                   	push   %edi
  800435:	56                   	push   %esi
  800436:	53                   	push   %ebx
  800437:	83 ec 1c             	sub    $0x1c,%esp
  80043a:	89 c7                	mov    %eax,%edi
  80043c:	89 d6                	mov    %edx,%esi
  80043e:	8b 45 08             	mov    0x8(%ebp),%eax
  800441:	8b 55 0c             	mov    0xc(%ebp),%edx
  800444:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800447:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80044a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80044d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800452:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800455:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800458:	39 d3                	cmp    %edx,%ebx
  80045a:	72 05                	jb     800461 <printnum+0x30>
  80045c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80045f:	77 45                	ja     8004a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800461:	83 ec 0c             	sub    $0xc,%esp
  800464:	ff 75 18             	pushl  0x18(%ebp)
  800467:	8b 45 14             	mov    0x14(%ebp),%eax
  80046a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80046d:	53                   	push   %ebx
  80046e:	ff 75 10             	pushl  0x10(%ebp)
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	ff 75 e4             	pushl  -0x1c(%ebp)
  800477:	ff 75 e0             	pushl  -0x20(%ebp)
  80047a:	ff 75 dc             	pushl  -0x24(%ebp)
  80047d:	ff 75 d8             	pushl  -0x28(%ebp)
  800480:	e8 eb 08 00 00       	call   800d70 <__udivdi3>
  800485:	83 c4 18             	add    $0x18,%esp
  800488:	52                   	push   %edx
  800489:	50                   	push   %eax
  80048a:	89 f2                	mov    %esi,%edx
  80048c:	89 f8                	mov    %edi,%eax
  80048e:	e8 9e ff ff ff       	call   800431 <printnum>
  800493:	83 c4 20             	add    $0x20,%esp
  800496:	eb 18                	jmp    8004b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800498:	83 ec 08             	sub    $0x8,%esp
  80049b:	56                   	push   %esi
  80049c:	ff 75 18             	pushl  0x18(%ebp)
  80049f:	ff d7                	call   *%edi
  8004a1:	83 c4 10             	add    $0x10,%esp
  8004a4:	eb 03                	jmp    8004a9 <printnum+0x78>
  8004a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004a9:	83 eb 01             	sub    $0x1,%ebx
  8004ac:	85 db                	test   %ebx,%ebx
  8004ae:	7f e8                	jg     800498 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	56                   	push   %esi
  8004b4:	83 ec 04             	sub    $0x4,%esp
  8004b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8004bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c3:	e8 d8 09 00 00       	call   800ea0 <__umoddi3>
  8004c8:	83 c4 14             	add    $0x14,%esp
  8004cb:	0f be 80 5e 10 80 00 	movsbl 0x80105e(%eax),%eax
  8004d2:	50                   	push   %eax
  8004d3:	ff d7                	call   *%edi
}
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004db:	5b                   	pop    %ebx
  8004dc:	5e                   	pop    %esi
  8004dd:	5f                   	pop    %edi
  8004de:	5d                   	pop    %ebp
  8004df:	c3                   	ret    

008004e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ea:	8b 10                	mov    (%eax),%edx
  8004ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ef:	73 0a                	jae    8004fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004f4:	89 08                	mov    %ecx,(%eax)
  8004f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f9:	88 02                	mov    %al,(%edx)
}
  8004fb:	5d                   	pop    %ebp
  8004fc:	c3                   	ret    

008004fd <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004fd:	55                   	push   %ebp
  8004fe:	89 e5                	mov    %esp,%ebp
  800500:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800503:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800506:	50                   	push   %eax
  800507:	ff 75 10             	pushl  0x10(%ebp)
  80050a:	ff 75 0c             	pushl  0xc(%ebp)
  80050d:	ff 75 08             	pushl  0x8(%ebp)
  800510:	e8 05 00 00 00       	call   80051a <vprintfmt>
	va_end(ap);
}
  800515:	83 c4 10             	add    $0x10,%esp
  800518:	c9                   	leave  
  800519:	c3                   	ret    

0080051a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	57                   	push   %edi
  80051e:	56                   	push   %esi
  80051f:	53                   	push   %ebx
  800520:	83 ec 2c             	sub    $0x2c,%esp
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	8b 7d 10             	mov    0x10(%ebp),%edi
  80052c:	eb 12                	jmp    800540 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80052e:	85 c0                	test   %eax,%eax
  800530:	0f 84 42 04 00 00    	je     800978 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	53                   	push   %ebx
  80053a:	50                   	push   %eax
  80053b:	ff d6                	call   *%esi
  80053d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800540:	83 c7 01             	add    $0x1,%edi
  800543:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800547:	83 f8 25             	cmp    $0x25,%eax
  80054a:	75 e2                	jne    80052e <vprintfmt+0x14>
  80054c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800550:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800557:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80055e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800565:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056a:	eb 07                	jmp    800573 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80056f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8d 47 01             	lea    0x1(%edi),%eax
  800576:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800579:	0f b6 07             	movzbl (%edi),%eax
  80057c:	0f b6 d0             	movzbl %al,%edx
  80057f:	83 e8 23             	sub    $0x23,%eax
  800582:	3c 55                	cmp    $0x55,%al
  800584:	0f 87 d3 03 00 00    	ja     80095d <vprintfmt+0x443>
  80058a:	0f b6 c0             	movzbl %al,%eax
  80058d:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  800594:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800597:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80059b:	eb d6                	jmp    800573 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005ab:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005af:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005b2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005b5:	83 f9 09             	cmp    $0x9,%ecx
  8005b8:	77 3f                	ja     8005f9 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005bd:	eb e9                	jmp    8005a8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8b 00                	mov    (%eax),%eax
  8005c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8d 40 04             	lea    0x4(%eax),%eax
  8005cd:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d3:	eb 2a                	jmp    8005ff <vprintfmt+0xe5>
  8005d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005d8:	85 c0                	test   %eax,%eax
  8005da:	ba 00 00 00 00       	mov    $0x0,%edx
  8005df:	0f 49 d0             	cmovns %eax,%edx
  8005e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e8:	eb 89                	jmp    800573 <vprintfmt+0x59>
  8005ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005ed:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f4:	e9 7a ff ff ff       	jmp    800573 <vprintfmt+0x59>
  8005f9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800603:	0f 89 6a ff ff ff    	jns    800573 <vprintfmt+0x59>
				width = precision, precision = -1;
  800609:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80060c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800616:	e9 58 ff ff ff       	jmp    800573 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061b:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800621:	e9 4d ff ff ff       	jmp    800573 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 78 04             	lea    0x4(%eax),%edi
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	ff 30                	pushl  (%eax)
  800632:	ff d6                	call   *%esi
			break;
  800634:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800637:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063d:	e9 fe fe ff ff       	jmp    800540 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 78 04             	lea    0x4(%eax),%edi
  800648:	8b 00                	mov    (%eax),%eax
  80064a:	99                   	cltd   
  80064b:	31 d0                	xor    %edx,%eax
  80064d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064f:	83 f8 08             	cmp    $0x8,%eax
  800652:	7f 0b                	jg     80065f <vprintfmt+0x145>
  800654:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  80065b:	85 d2                	test   %edx,%edx
  80065d:	75 1b                	jne    80067a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80065f:	50                   	push   %eax
  800660:	68 76 10 80 00       	push   $0x801076
  800665:	53                   	push   %ebx
  800666:	56                   	push   %esi
  800667:	e8 91 fe ff ff       	call   8004fd <printfmt>
  80066c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80066f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800672:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800675:	e9 c6 fe ff ff       	jmp    800540 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067a:	52                   	push   %edx
  80067b:	68 7f 10 80 00       	push   $0x80107f
  800680:	53                   	push   %ebx
  800681:	56                   	push   %esi
  800682:	e8 76 fe ff ff       	call   8004fd <printfmt>
  800687:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80068a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800690:	e9 ab fe ff ff       	jmp    800540 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	83 c0 04             	add    $0x4,%eax
  80069b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006a3:	85 ff                	test   %edi,%edi
  8006a5:	b8 6f 10 80 00       	mov    $0x80106f,%eax
  8006aa:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006b1:	0f 8e 94 00 00 00    	jle    80074b <vprintfmt+0x231>
  8006b7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006bb:	0f 84 98 00 00 00    	je     800759 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c1:	83 ec 08             	sub    $0x8,%esp
  8006c4:	ff 75 d0             	pushl  -0x30(%ebp)
  8006c7:	57                   	push   %edi
  8006c8:	e8 33 03 00 00       	call   800a00 <strnlen>
  8006cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006d0:	29 c1                	sub    %eax,%ecx
  8006d2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006d5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006df:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006e2:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e4:	eb 0f                	jmp    8006f5 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006e6:	83 ec 08             	sub    $0x8,%esp
  8006e9:	53                   	push   %ebx
  8006ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ed:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ef:	83 ef 01             	sub    $0x1,%edi
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	85 ff                	test   %edi,%edi
  8006f7:	7f ed                	jg     8006e6 <vprintfmt+0x1cc>
  8006f9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006fc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006ff:	85 c9                	test   %ecx,%ecx
  800701:	b8 00 00 00 00       	mov    $0x0,%eax
  800706:	0f 49 c1             	cmovns %ecx,%eax
  800709:	29 c1                	sub    %eax,%ecx
  80070b:	89 75 08             	mov    %esi,0x8(%ebp)
  80070e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800711:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800714:	89 cb                	mov    %ecx,%ebx
  800716:	eb 4d                	jmp    800765 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800718:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071c:	74 1b                	je     800739 <vprintfmt+0x21f>
  80071e:	0f be c0             	movsbl %al,%eax
  800721:	83 e8 20             	sub    $0x20,%eax
  800724:	83 f8 5e             	cmp    $0x5e,%eax
  800727:	76 10                	jbe    800739 <vprintfmt+0x21f>
					putch('?', putdat);
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	6a 3f                	push   $0x3f
  800731:	ff 55 08             	call   *0x8(%ebp)
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	eb 0d                	jmp    800746 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800739:	83 ec 08             	sub    $0x8,%esp
  80073c:	ff 75 0c             	pushl  0xc(%ebp)
  80073f:	52                   	push   %edx
  800740:	ff 55 08             	call   *0x8(%ebp)
  800743:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800746:	83 eb 01             	sub    $0x1,%ebx
  800749:	eb 1a                	jmp    800765 <vprintfmt+0x24b>
  80074b:	89 75 08             	mov    %esi,0x8(%ebp)
  80074e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800751:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800754:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800757:	eb 0c                	jmp    800765 <vprintfmt+0x24b>
  800759:	89 75 08             	mov    %esi,0x8(%ebp)
  80075c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800762:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800765:	83 c7 01             	add    $0x1,%edi
  800768:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80076c:	0f be d0             	movsbl %al,%edx
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 23                	je     800796 <vprintfmt+0x27c>
  800773:	85 f6                	test   %esi,%esi
  800775:	78 a1                	js     800718 <vprintfmt+0x1fe>
  800777:	83 ee 01             	sub    $0x1,%esi
  80077a:	79 9c                	jns    800718 <vprintfmt+0x1fe>
  80077c:	89 df                	mov    %ebx,%edi
  80077e:	8b 75 08             	mov    0x8(%ebp),%esi
  800781:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800784:	eb 18                	jmp    80079e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800786:	83 ec 08             	sub    $0x8,%esp
  800789:	53                   	push   %ebx
  80078a:	6a 20                	push   $0x20
  80078c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078e:	83 ef 01             	sub    $0x1,%edi
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	eb 08                	jmp    80079e <vprintfmt+0x284>
  800796:	89 df                	mov    %ebx,%edi
  800798:	8b 75 08             	mov    0x8(%ebp),%esi
  80079b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80079e:	85 ff                	test   %edi,%edi
  8007a0:	7f e4                	jg     800786 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007a5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ab:	e9 90 fd ff ff       	jmp    800540 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b0:	83 f9 01             	cmp    $0x1,%ecx
  8007b3:	7e 19                	jle    8007ce <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8b 50 04             	mov    0x4(%eax),%edx
  8007bb:	8b 00                	mov    (%eax),%eax
  8007bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8d 40 08             	lea    0x8(%eax),%eax
  8007c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007cc:	eb 38                	jmp    800806 <vprintfmt+0x2ec>
	else if (lflag)
  8007ce:	85 c9                	test   %ecx,%ecx
  8007d0:	74 1b                	je     8007ed <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8b 00                	mov    (%eax),%eax
  8007d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007da:	89 c1                	mov    %eax,%ecx
  8007dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8007df:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 40 04             	lea    0x4(%eax),%eax
  8007e8:	89 45 14             	mov    %eax,0x14(%ebp)
  8007eb:	eb 19                	jmp    800806 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	8b 00                	mov    (%eax),%eax
  8007f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007f5:	89 c1                	mov    %eax,%ecx
  8007f7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007fa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800800:	8d 40 04             	lea    0x4(%eax),%eax
  800803:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800806:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800809:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80080c:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800811:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800815:	0f 89 0e 01 00 00    	jns    800929 <vprintfmt+0x40f>
				putch('-', putdat);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	53                   	push   %ebx
  80081f:	6a 2d                	push   $0x2d
  800821:	ff d6                	call   *%esi
				num = -(long long) num;
  800823:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800826:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800829:	f7 da                	neg    %edx
  80082b:	83 d1 00             	adc    $0x0,%ecx
  80082e:	f7 d9                	neg    %ecx
  800830:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800833:	b8 0a 00 00 00       	mov    $0xa,%eax
  800838:	e9 ec 00 00 00       	jmp    800929 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80083d:	83 f9 01             	cmp    $0x1,%ecx
  800840:	7e 18                	jle    80085a <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800842:	8b 45 14             	mov    0x14(%ebp),%eax
  800845:	8b 10                	mov    (%eax),%edx
  800847:	8b 48 04             	mov    0x4(%eax),%ecx
  80084a:	8d 40 08             	lea    0x8(%eax),%eax
  80084d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800850:	b8 0a 00 00 00       	mov    $0xa,%eax
  800855:	e9 cf 00 00 00       	jmp    800929 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80085a:	85 c9                	test   %ecx,%ecx
  80085c:	74 1a                	je     800878 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8b 10                	mov    (%eax),%edx
  800863:	b9 00 00 00 00       	mov    $0x0,%ecx
  800868:	8d 40 04             	lea    0x4(%eax),%eax
  80086b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80086e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800873:	e9 b1 00 00 00       	jmp    800929 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8b 10                	mov    (%eax),%edx
  80087d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800882:	8d 40 04             	lea    0x4(%eax),%eax
  800885:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800888:	b8 0a 00 00 00       	mov    $0xa,%eax
  80088d:	e9 97 00 00 00       	jmp    800929 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800892:	83 ec 08             	sub    $0x8,%esp
  800895:	53                   	push   %ebx
  800896:	6a 58                	push   $0x58
  800898:	ff d6                	call   *%esi
			putch('X', putdat);
  80089a:	83 c4 08             	add    $0x8,%esp
  80089d:	53                   	push   %ebx
  80089e:	6a 58                	push   $0x58
  8008a0:	ff d6                	call   *%esi
			putch('X', putdat);
  8008a2:	83 c4 08             	add    $0x8,%esp
  8008a5:	53                   	push   %ebx
  8008a6:	6a 58                	push   $0x58
  8008a8:	ff d6                	call   *%esi
			break;
  8008aa:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008b0:	e9 8b fc ff ff       	jmp    800540 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8008b5:	83 ec 08             	sub    $0x8,%esp
  8008b8:	53                   	push   %ebx
  8008b9:	6a 30                	push   $0x30
  8008bb:	ff d6                	call   *%esi
			putch('x', putdat);
  8008bd:	83 c4 08             	add    $0x8,%esp
  8008c0:	53                   	push   %ebx
  8008c1:	6a 78                	push   $0x78
  8008c3:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c8:	8b 10                	mov    (%eax),%edx
  8008ca:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008cf:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008d2:	8d 40 04             	lea    0x4(%eax),%eax
  8008d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008d8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008dd:	eb 4a                	jmp    800929 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008df:	83 f9 01             	cmp    $0x1,%ecx
  8008e2:	7e 15                	jle    8008f9 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e7:	8b 10                	mov    (%eax),%edx
  8008e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8008ec:	8d 40 08             	lea    0x8(%eax),%eax
  8008ef:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008f2:	b8 10 00 00 00       	mov    $0x10,%eax
  8008f7:	eb 30                	jmp    800929 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008f9:	85 c9                	test   %ecx,%ecx
  8008fb:	74 17                	je     800914 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800900:	8b 10                	mov    (%eax),%edx
  800902:	b9 00 00 00 00       	mov    $0x0,%ecx
  800907:	8d 40 04             	lea    0x4(%eax),%eax
  80090a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80090d:	b8 10 00 00 00       	mov    $0x10,%eax
  800912:	eb 15                	jmp    800929 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800914:	8b 45 14             	mov    0x14(%ebp),%eax
  800917:	8b 10                	mov    (%eax),%edx
  800919:	b9 00 00 00 00       	mov    $0x0,%ecx
  80091e:	8d 40 04             	lea    0x4(%eax),%eax
  800921:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800924:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800929:	83 ec 0c             	sub    $0xc,%esp
  80092c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800930:	57                   	push   %edi
  800931:	ff 75 e0             	pushl  -0x20(%ebp)
  800934:	50                   	push   %eax
  800935:	51                   	push   %ecx
  800936:	52                   	push   %edx
  800937:	89 da                	mov    %ebx,%edx
  800939:	89 f0                	mov    %esi,%eax
  80093b:	e8 f1 fa ff ff       	call   800431 <printnum>
			break;
  800940:	83 c4 20             	add    $0x20,%esp
  800943:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800946:	e9 f5 fb ff ff       	jmp    800540 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80094b:	83 ec 08             	sub    $0x8,%esp
  80094e:	53                   	push   %ebx
  80094f:	52                   	push   %edx
  800950:	ff d6                	call   *%esi
			break;
  800952:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800955:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800958:	e9 e3 fb ff ff       	jmp    800540 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80095d:	83 ec 08             	sub    $0x8,%esp
  800960:	53                   	push   %ebx
  800961:	6a 25                	push   $0x25
  800963:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800965:	83 c4 10             	add    $0x10,%esp
  800968:	eb 03                	jmp    80096d <vprintfmt+0x453>
  80096a:	83 ef 01             	sub    $0x1,%edi
  80096d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800971:	75 f7                	jne    80096a <vprintfmt+0x450>
  800973:	e9 c8 fb ff ff       	jmp    800540 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800978:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5f                   	pop    %edi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	83 ec 18             	sub    $0x18,%esp
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80098c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80098f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800993:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800996:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80099d:	85 c0                	test   %eax,%eax
  80099f:	74 26                	je     8009c7 <vsnprintf+0x47>
  8009a1:	85 d2                	test   %edx,%edx
  8009a3:	7e 22                	jle    8009c7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a5:	ff 75 14             	pushl  0x14(%ebp)
  8009a8:	ff 75 10             	pushl  0x10(%ebp)
  8009ab:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ae:	50                   	push   %eax
  8009af:	68 e0 04 80 00       	push   $0x8004e0
  8009b4:	e8 61 fb ff ff       	call   80051a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009bc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c2:	83 c4 10             	add    $0x10,%esp
  8009c5:	eb 05                	jmp    8009cc <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009cc:	c9                   	leave  
  8009cd:	c3                   	ret    

008009ce <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009d4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d7:	50                   	push   %eax
  8009d8:	ff 75 10             	pushl  0x10(%ebp)
  8009db:	ff 75 0c             	pushl  0xc(%ebp)
  8009de:	ff 75 08             	pushl  0x8(%ebp)
  8009e1:	e8 9a ff ff ff       	call   800980 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e6:	c9                   	leave  
  8009e7:	c3                   	ret    

008009e8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f3:	eb 03                	jmp    8009f8 <strlen+0x10>
		n++;
  8009f5:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009fc:	75 f7                	jne    8009f5 <strlen+0xd>
		n++;
	return n;
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a06:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a09:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0e:	eb 03                	jmp    800a13 <strnlen+0x13>
		n++;
  800a10:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a13:	39 c2                	cmp    %eax,%edx
  800a15:	74 08                	je     800a1f <strnlen+0x1f>
  800a17:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a1b:	75 f3                	jne    800a10 <strnlen+0x10>
  800a1d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	53                   	push   %ebx
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a2b:	89 c2                	mov    %eax,%edx
  800a2d:	83 c2 01             	add    $0x1,%edx
  800a30:	83 c1 01             	add    $0x1,%ecx
  800a33:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a37:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a3a:	84 db                	test   %bl,%bl
  800a3c:	75 ef                	jne    800a2d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	53                   	push   %ebx
  800a45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a48:	53                   	push   %ebx
  800a49:	e8 9a ff ff ff       	call   8009e8 <strlen>
  800a4e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a51:	ff 75 0c             	pushl  0xc(%ebp)
  800a54:	01 d8                	add    %ebx,%eax
  800a56:	50                   	push   %eax
  800a57:	e8 c5 ff ff ff       	call   800a21 <strcpy>
	return dst;
}
  800a5c:	89 d8                	mov    %ebx,%eax
  800a5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a61:	c9                   	leave  
  800a62:	c3                   	ret    

00800a63 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6e:	89 f3                	mov    %esi,%ebx
  800a70:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a73:	89 f2                	mov    %esi,%edx
  800a75:	eb 0f                	jmp    800a86 <strncpy+0x23>
		*dst++ = *src;
  800a77:	83 c2 01             	add    $0x1,%edx
  800a7a:	0f b6 01             	movzbl (%ecx),%eax
  800a7d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a80:	80 39 01             	cmpb   $0x1,(%ecx)
  800a83:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a86:	39 da                	cmp    %ebx,%edx
  800a88:	75 ed                	jne    800a77 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a8a:	89 f0                	mov    %esi,%eax
  800a8c:	5b                   	pop    %ebx
  800a8d:	5e                   	pop    %esi
  800a8e:	5d                   	pop    %ebp
  800a8f:	c3                   	ret    

00800a90 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 75 08             	mov    0x8(%ebp),%esi
  800a98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9b:	8b 55 10             	mov    0x10(%ebp),%edx
  800a9e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa0:	85 d2                	test   %edx,%edx
  800aa2:	74 21                	je     800ac5 <strlcpy+0x35>
  800aa4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800aa8:	89 f2                	mov    %esi,%edx
  800aaa:	eb 09                	jmp    800ab5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aac:	83 c2 01             	add    $0x1,%edx
  800aaf:	83 c1 01             	add    $0x1,%ecx
  800ab2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ab5:	39 c2                	cmp    %eax,%edx
  800ab7:	74 09                	je     800ac2 <strlcpy+0x32>
  800ab9:	0f b6 19             	movzbl (%ecx),%ebx
  800abc:	84 db                	test   %bl,%bl
  800abe:	75 ec                	jne    800aac <strlcpy+0x1c>
  800ac0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ac2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ac5:	29 f0                	sub    %esi,%eax
}
  800ac7:	5b                   	pop    %ebx
  800ac8:	5e                   	pop    %esi
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ad1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ad4:	eb 06                	jmp    800adc <strcmp+0x11>
		p++, q++;
  800ad6:	83 c1 01             	add    $0x1,%ecx
  800ad9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800adc:	0f b6 01             	movzbl (%ecx),%eax
  800adf:	84 c0                	test   %al,%al
  800ae1:	74 04                	je     800ae7 <strcmp+0x1c>
  800ae3:	3a 02                	cmp    (%edx),%al
  800ae5:	74 ef                	je     800ad6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae7:	0f b6 c0             	movzbl %al,%eax
  800aea:	0f b6 12             	movzbl (%edx),%edx
  800aed:	29 d0                	sub    %edx,%eax
}
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	53                   	push   %ebx
  800af5:	8b 45 08             	mov    0x8(%ebp),%eax
  800af8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800afb:	89 c3                	mov    %eax,%ebx
  800afd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b00:	eb 06                	jmp    800b08 <strncmp+0x17>
		n--, p++, q++;
  800b02:	83 c0 01             	add    $0x1,%eax
  800b05:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b08:	39 d8                	cmp    %ebx,%eax
  800b0a:	74 15                	je     800b21 <strncmp+0x30>
  800b0c:	0f b6 08             	movzbl (%eax),%ecx
  800b0f:	84 c9                	test   %cl,%cl
  800b11:	74 04                	je     800b17 <strncmp+0x26>
  800b13:	3a 0a                	cmp    (%edx),%cl
  800b15:	74 eb                	je     800b02 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b17:	0f b6 00             	movzbl (%eax),%eax
  800b1a:	0f b6 12             	movzbl (%edx),%edx
  800b1d:	29 d0                	sub    %edx,%eax
  800b1f:	eb 05                	jmp    800b26 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b21:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b26:	5b                   	pop    %ebx
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b33:	eb 07                	jmp    800b3c <strchr+0x13>
		if (*s == c)
  800b35:	38 ca                	cmp    %cl,%dl
  800b37:	74 0f                	je     800b48 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b39:	83 c0 01             	add    $0x1,%eax
  800b3c:	0f b6 10             	movzbl (%eax),%edx
  800b3f:	84 d2                	test   %dl,%dl
  800b41:	75 f2                	jne    800b35 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b54:	eb 03                	jmp    800b59 <strfind+0xf>
  800b56:	83 c0 01             	add    $0x1,%eax
  800b59:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b5c:	38 ca                	cmp    %cl,%dl
  800b5e:	74 04                	je     800b64 <strfind+0x1a>
  800b60:	84 d2                	test   %dl,%dl
  800b62:	75 f2                	jne    800b56 <strfind+0xc>
			break;
	return (char *) s;
}
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b72:	85 c9                	test   %ecx,%ecx
  800b74:	74 36                	je     800bac <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b76:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b7c:	75 28                	jne    800ba6 <memset+0x40>
  800b7e:	f6 c1 03             	test   $0x3,%cl
  800b81:	75 23                	jne    800ba6 <memset+0x40>
		c &= 0xFF;
  800b83:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b87:	89 d3                	mov    %edx,%ebx
  800b89:	c1 e3 08             	shl    $0x8,%ebx
  800b8c:	89 d6                	mov    %edx,%esi
  800b8e:	c1 e6 18             	shl    $0x18,%esi
  800b91:	89 d0                	mov    %edx,%eax
  800b93:	c1 e0 10             	shl    $0x10,%eax
  800b96:	09 f0                	or     %esi,%eax
  800b98:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b9a:	89 d8                	mov    %ebx,%eax
  800b9c:	09 d0                	or     %edx,%eax
  800b9e:	c1 e9 02             	shr    $0x2,%ecx
  800ba1:	fc                   	cld    
  800ba2:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba4:	eb 06                	jmp    800bac <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba9:	fc                   	cld    
  800baa:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bac:	89 f8                	mov    %edi,%eax
  800bae:	5b                   	pop    %ebx
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	57                   	push   %edi
  800bb7:	56                   	push   %esi
  800bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc1:	39 c6                	cmp    %eax,%esi
  800bc3:	73 35                	jae    800bfa <memmove+0x47>
  800bc5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc8:	39 d0                	cmp    %edx,%eax
  800bca:	73 2e                	jae    800bfa <memmove+0x47>
		s += n;
		d += n;
  800bcc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcf:	89 d6                	mov    %edx,%esi
  800bd1:	09 fe                	or     %edi,%esi
  800bd3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bd9:	75 13                	jne    800bee <memmove+0x3b>
  800bdb:	f6 c1 03             	test   $0x3,%cl
  800bde:	75 0e                	jne    800bee <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800be0:	83 ef 04             	sub    $0x4,%edi
  800be3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be6:	c1 e9 02             	shr    $0x2,%ecx
  800be9:	fd                   	std    
  800bea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bec:	eb 09                	jmp    800bf7 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bee:	83 ef 01             	sub    $0x1,%edi
  800bf1:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bf4:	fd                   	std    
  800bf5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf7:	fc                   	cld    
  800bf8:	eb 1d                	jmp    800c17 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfa:	89 f2                	mov    %esi,%edx
  800bfc:	09 c2                	or     %eax,%edx
  800bfe:	f6 c2 03             	test   $0x3,%dl
  800c01:	75 0f                	jne    800c12 <memmove+0x5f>
  800c03:	f6 c1 03             	test   $0x3,%cl
  800c06:	75 0a                	jne    800c12 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c08:	c1 e9 02             	shr    $0x2,%ecx
  800c0b:	89 c7                	mov    %eax,%edi
  800c0d:	fc                   	cld    
  800c0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c10:	eb 05                	jmp    800c17 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c12:	89 c7                	mov    %eax,%edi
  800c14:	fc                   	cld    
  800c15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c1e:	ff 75 10             	pushl  0x10(%ebp)
  800c21:	ff 75 0c             	pushl  0xc(%ebp)
  800c24:	ff 75 08             	pushl  0x8(%ebp)
  800c27:	e8 87 ff ff ff       	call   800bb3 <memmove>
}
  800c2c:	c9                   	leave  
  800c2d:	c3                   	ret    

00800c2e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	8b 45 08             	mov    0x8(%ebp),%eax
  800c36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c39:	89 c6                	mov    %eax,%esi
  800c3b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3e:	eb 1a                	jmp    800c5a <memcmp+0x2c>
		if (*s1 != *s2)
  800c40:	0f b6 08             	movzbl (%eax),%ecx
  800c43:	0f b6 1a             	movzbl (%edx),%ebx
  800c46:	38 d9                	cmp    %bl,%cl
  800c48:	74 0a                	je     800c54 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c4a:	0f b6 c1             	movzbl %cl,%eax
  800c4d:	0f b6 db             	movzbl %bl,%ebx
  800c50:	29 d8                	sub    %ebx,%eax
  800c52:	eb 0f                	jmp    800c63 <memcmp+0x35>
		s1++, s2++;
  800c54:	83 c0 01             	add    $0x1,%eax
  800c57:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5a:	39 f0                	cmp    %esi,%eax
  800c5c:	75 e2                	jne    800c40 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c63:	5b                   	pop    %ebx
  800c64:	5e                   	pop    %esi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	53                   	push   %ebx
  800c6b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c6e:	89 c1                	mov    %eax,%ecx
  800c70:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c73:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c77:	eb 0a                	jmp    800c83 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c79:	0f b6 10             	movzbl (%eax),%edx
  800c7c:	39 da                	cmp    %ebx,%edx
  800c7e:	74 07                	je     800c87 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c80:	83 c0 01             	add    $0x1,%eax
  800c83:	39 c8                	cmp    %ecx,%eax
  800c85:	72 f2                	jb     800c79 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c87:	5b                   	pop    %ebx
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    

00800c8a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c96:	eb 03                	jmp    800c9b <strtol+0x11>
		s++;
  800c98:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9b:	0f b6 01             	movzbl (%ecx),%eax
  800c9e:	3c 20                	cmp    $0x20,%al
  800ca0:	74 f6                	je     800c98 <strtol+0xe>
  800ca2:	3c 09                	cmp    $0x9,%al
  800ca4:	74 f2                	je     800c98 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca6:	3c 2b                	cmp    $0x2b,%al
  800ca8:	75 0a                	jne    800cb4 <strtol+0x2a>
		s++;
  800caa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cad:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb2:	eb 11                	jmp    800cc5 <strtol+0x3b>
  800cb4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb9:	3c 2d                	cmp    $0x2d,%al
  800cbb:	75 08                	jne    800cc5 <strtol+0x3b>
		s++, neg = 1;
  800cbd:	83 c1 01             	add    $0x1,%ecx
  800cc0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ccb:	75 15                	jne    800ce2 <strtol+0x58>
  800ccd:	80 39 30             	cmpb   $0x30,(%ecx)
  800cd0:	75 10                	jne    800ce2 <strtol+0x58>
  800cd2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd6:	75 7c                	jne    800d54 <strtol+0xca>
		s += 2, base = 16;
  800cd8:	83 c1 02             	add    $0x2,%ecx
  800cdb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce0:	eb 16                	jmp    800cf8 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ce2:	85 db                	test   %ebx,%ebx
  800ce4:	75 12                	jne    800cf8 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ce6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ceb:	80 39 30             	cmpb   $0x30,(%ecx)
  800cee:	75 08                	jne    800cf8 <strtol+0x6e>
		s++, base = 8;
  800cf0:	83 c1 01             	add    $0x1,%ecx
  800cf3:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfd:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d00:	0f b6 11             	movzbl (%ecx),%edx
  800d03:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d06:	89 f3                	mov    %esi,%ebx
  800d08:	80 fb 09             	cmp    $0x9,%bl
  800d0b:	77 08                	ja     800d15 <strtol+0x8b>
			dig = *s - '0';
  800d0d:	0f be d2             	movsbl %dl,%edx
  800d10:	83 ea 30             	sub    $0x30,%edx
  800d13:	eb 22                	jmp    800d37 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d15:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d18:	89 f3                	mov    %esi,%ebx
  800d1a:	80 fb 19             	cmp    $0x19,%bl
  800d1d:	77 08                	ja     800d27 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d1f:	0f be d2             	movsbl %dl,%edx
  800d22:	83 ea 57             	sub    $0x57,%edx
  800d25:	eb 10                	jmp    800d37 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d27:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d2a:	89 f3                	mov    %esi,%ebx
  800d2c:	80 fb 19             	cmp    $0x19,%bl
  800d2f:	77 16                	ja     800d47 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d31:	0f be d2             	movsbl %dl,%edx
  800d34:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d37:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d3a:	7d 0b                	jge    800d47 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d3c:	83 c1 01             	add    $0x1,%ecx
  800d3f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d43:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d45:	eb b9                	jmp    800d00 <strtol+0x76>

	if (endptr)
  800d47:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d4b:	74 0d                	je     800d5a <strtol+0xd0>
		*endptr = (char *) s;
  800d4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d50:	89 0e                	mov    %ecx,(%esi)
  800d52:	eb 06                	jmp    800d5a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d54:	85 db                	test   %ebx,%ebx
  800d56:	74 98                	je     800cf0 <strtol+0x66>
  800d58:	eb 9e                	jmp    800cf8 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d5a:	89 c2                	mov    %eax,%edx
  800d5c:	f7 da                	neg    %edx
  800d5e:	85 ff                	test   %edi,%edi
  800d60:	0f 45 c2             	cmovne %edx,%eax
}
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    
  800d68:	66 90                	xchg   %ax,%ax
  800d6a:	66 90                	xchg   %ax,%ax
  800d6c:	66 90                	xchg   %ax,%ax
  800d6e:	66 90                	xchg   %ax,%ax

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
