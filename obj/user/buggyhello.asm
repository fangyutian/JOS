
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
  80003d:	e8 a5 00 00 00       	call   8000e7 <sys_cputs>
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
  80004a:	57                   	push   %edi
  80004b:	56                   	push   %esi
  80004c:	53                   	push   %ebx
  80004d:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800050:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800057:	00 00 00 
	envid_t eid = sys_getenvid();
  80005a:	e8 06 01 00 00       	call   800165 <sys_getenvid>
  80005f:	8b 3d 04 20 80 00    	mov    0x802004,%edi
  800065:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80006a:	be 00 00 00 00       	mov    $0x0,%esi
	int i;
	for (i = 0; i < NENV; i++) {
  80006f:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == eid) {
  800074:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800077:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  80007d:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &(envs[i]);
  800080:	39 c8                	cmp    %ecx,%eax
  800082:	0f 44 fb             	cmove  %ebx,%edi
  800085:	b9 01 00 00 00       	mov    $0x1,%ecx
  80008a:	0f 44 f1             	cmove  %ecx,%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
	envid_t eid = sys_getenvid();
	int i;
	for (i = 0; i < NENV; i++) {
  80008d:	83 c2 01             	add    $0x1,%edx
  800090:	83 c3 7c             	add    $0x7c,%ebx
  800093:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800099:	75 d9                	jne    800074 <libmain+0x2d>
  80009b:	89 f0                	mov    %esi,%eax
  80009d:	84 c0                	test   %al,%al
  80009f:	74 06                	je     8000a7 <libmain+0x60>
  8000a1:	89 3d 04 20 80 00    	mov    %edi,0x802004
			thisenv = &(envs[i]);
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000ab:	7e 0a                	jle    8000b7 <libmain+0x70>
		binaryname = argv[0];
  8000ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000b0:	8b 00                	mov    (%eax),%eax
  8000b2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b7:	83 ec 08             	sub    $0x8,%esp
  8000ba:	ff 75 0c             	pushl  0xc(%ebp)
  8000bd:	ff 75 08             	pushl  0x8(%ebp)
  8000c0:	e8 6e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c5:	e8 0b 00 00 00       	call   8000d5 <exit>
}
  8000ca:	83 c4 10             	add    $0x10,%esp
  8000cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000db:	6a 00                	push   $0x0
  8000dd:	e8 42 00 00 00       	call   800124 <sys_env_destroy>
}
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	c9                   	leave  
  8000e6:	c3                   	ret    

008000e7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	89 c3                	mov    %eax,%ebx
  8000fa:	89 c7                	mov    %eax,%edi
  8000fc:	89 c6                	mov    %eax,%esi
  8000fe:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    

00800105 <sys_cgetc>:

int
sys_cgetc(void)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	57                   	push   %edi
  800109:	56                   	push   %esi
  80010a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	ba 00 00 00 00       	mov    $0x0,%edx
  800110:	b8 01 00 00 00       	mov    $0x1,%eax
  800115:	89 d1                	mov    %edx,%ecx
  800117:	89 d3                	mov    %edx,%ebx
  800119:	89 d7                	mov    %edx,%edi
  80011b:	89 d6                	mov    %edx,%esi
  80011d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800132:	b8 03 00 00 00       	mov    $0x3,%eax
  800137:	8b 55 08             	mov    0x8(%ebp),%edx
  80013a:	89 cb                	mov    %ecx,%ebx
  80013c:	89 cf                	mov    %ecx,%edi
  80013e:	89 ce                	mov    %ecx,%esi
  800140:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800142:	85 c0                	test   %eax,%eax
  800144:	7e 17                	jle    80015d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	50                   	push   %eax
  80014a:	6a 03                	push   $0x3
  80014c:	68 2a 10 80 00       	push   $0x80102a
  800151:	6a 23                	push   $0x23
  800153:	68 47 10 80 00       	push   $0x801047
  800158:	e8 f5 01 00 00       	call   800352 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80015d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016b:	ba 00 00 00 00       	mov    $0x0,%edx
  800170:	b8 02 00 00 00       	mov    $0x2,%eax
  800175:	89 d1                	mov    %edx,%ecx
  800177:	89 d3                	mov    %edx,%ebx
  800179:	89 d7                	mov    %edx,%edi
  80017b:	89 d6                	mov    %edx,%esi
  80017d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5f                   	pop    %edi
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <sys_yield>:

void
sys_yield(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	ba 00 00 00 00       	mov    $0x0,%edx
  80018f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800194:	89 d1                	mov    %edx,%ecx
  800196:	89 d3                	mov    %edx,%ebx
  800198:	89 d7                	mov    %edx,%edi
  80019a:	89 d6                	mov    %edx,%esi
  80019c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80019e:	5b                   	pop    %ebx
  80019f:	5e                   	pop    %esi
  8001a0:	5f                   	pop    %edi
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	57                   	push   %edi
  8001a7:	56                   	push   %esi
  8001a8:	53                   	push   %ebx
  8001a9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ac:	be 00 00 00 00       	mov    $0x0,%esi
  8001b1:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bf:	89 f7                	mov    %esi,%edi
  8001c1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c3:	85 c0                	test   %eax,%eax
  8001c5:	7e 17                	jle    8001de <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	6a 04                	push   $0x4
  8001cd:	68 2a 10 80 00       	push   $0x80102a
  8001d2:	6a 23                	push   $0x23
  8001d4:	68 47 10 80 00       	push   $0x801047
  8001d9:	e8 74 01 00 00       	call   800352 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e1:	5b                   	pop    %ebx
  8001e2:	5e                   	pop    %esi
  8001e3:	5f                   	pop    %edi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	57                   	push   %edi
  8001ea:	56                   	push   %esi
  8001eb:	53                   	push   %ebx
  8001ec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ef:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800200:	8b 75 18             	mov    0x18(%ebp),%esi
  800203:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800205:	85 c0                	test   %eax,%eax
  800207:	7e 17                	jle    800220 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	50                   	push   %eax
  80020d:	6a 05                	push   $0x5
  80020f:	68 2a 10 80 00       	push   $0x80102a
  800214:	6a 23                	push   $0x23
  800216:	68 47 10 80 00       	push   $0x801047
  80021b:	e8 32 01 00 00       	call   800352 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800220:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800223:	5b                   	pop    %ebx
  800224:	5e                   	pop    %esi
  800225:	5f                   	pop    %edi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800231:	bb 00 00 00 00       	mov    $0x0,%ebx
  800236:	b8 06 00 00 00       	mov    $0x6,%eax
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	8b 55 08             	mov    0x8(%ebp),%edx
  800241:	89 df                	mov    %ebx,%edi
  800243:	89 de                	mov    %ebx,%esi
  800245:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800247:	85 c0                	test   %eax,%eax
  800249:	7e 17                	jle    800262 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024b:	83 ec 0c             	sub    $0xc,%esp
  80024e:	50                   	push   %eax
  80024f:	6a 06                	push   $0x6
  800251:	68 2a 10 80 00       	push   $0x80102a
  800256:	6a 23                	push   $0x23
  800258:	68 47 10 80 00       	push   $0x801047
  80025d:	e8 f0 00 00 00       	call   800352 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800262:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800265:	5b                   	pop    %ebx
  800266:	5e                   	pop    %esi
  800267:	5f                   	pop    %edi
  800268:	5d                   	pop    %ebp
  800269:	c3                   	ret    

0080026a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	57                   	push   %edi
  80026e:	56                   	push   %esi
  80026f:	53                   	push   %ebx
  800270:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800273:	bb 00 00 00 00       	mov    $0x0,%ebx
  800278:	b8 08 00 00 00       	mov    $0x8,%eax
  80027d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800280:	8b 55 08             	mov    0x8(%ebp),%edx
  800283:	89 df                	mov    %ebx,%edi
  800285:	89 de                	mov    %ebx,%esi
  800287:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800289:	85 c0                	test   %eax,%eax
  80028b:	7e 17                	jle    8002a4 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028d:	83 ec 0c             	sub    $0xc,%esp
  800290:	50                   	push   %eax
  800291:	6a 08                	push   $0x8
  800293:	68 2a 10 80 00       	push   $0x80102a
  800298:	6a 23                	push   $0x23
  80029a:	68 47 10 80 00       	push   $0x801047
  80029f:	e8 ae 00 00 00       	call   800352 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a7:	5b                   	pop    %ebx
  8002a8:	5e                   	pop    %esi
  8002a9:	5f                   	pop    %edi
  8002aa:	5d                   	pop    %ebp
  8002ab:	c3                   	ret    

008002ac <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	57                   	push   %edi
  8002b0:	56                   	push   %esi
  8002b1:	53                   	push   %ebx
  8002b2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ba:	b8 09 00 00 00       	mov    $0x9,%eax
  8002bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c5:	89 df                	mov    %ebx,%edi
  8002c7:	89 de                	mov    %ebx,%esi
  8002c9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cb:	85 c0                	test   %eax,%eax
  8002cd:	7e 17                	jle    8002e6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cf:	83 ec 0c             	sub    $0xc,%esp
  8002d2:	50                   	push   %eax
  8002d3:	6a 09                	push   $0x9
  8002d5:	68 2a 10 80 00       	push   $0x80102a
  8002da:	6a 23                	push   $0x23
  8002dc:	68 47 10 80 00       	push   $0x801047
  8002e1:	e8 6c 00 00 00       	call   800352 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e9:	5b                   	pop    %ebx
  8002ea:	5e                   	pop    %esi
  8002eb:	5f                   	pop    %edi
  8002ec:	5d                   	pop    %ebp
  8002ed:	c3                   	ret    

008002ee <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f4:	be 00 00 00 00       	mov    $0x0,%esi
  8002f9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800301:	8b 55 08             	mov    0x8(%ebp),%edx
  800304:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800307:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	57                   	push   %edi
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
  800317:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800324:	8b 55 08             	mov    0x8(%ebp),%edx
  800327:	89 cb                	mov    %ecx,%ebx
  800329:	89 cf                	mov    %ecx,%edi
  80032b:	89 ce                	mov    %ecx,%esi
  80032d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80032f:	85 c0                	test   %eax,%eax
  800331:	7e 17                	jle    80034a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800333:	83 ec 0c             	sub    $0xc,%esp
  800336:	50                   	push   %eax
  800337:	6a 0c                	push   $0xc
  800339:	68 2a 10 80 00       	push   $0x80102a
  80033e:	6a 23                	push   $0x23
  800340:	68 47 10 80 00       	push   $0x801047
  800345:	e8 08 00 00 00       	call   800352 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034d:	5b                   	pop    %ebx
  80034e:	5e                   	pop    %esi
  80034f:	5f                   	pop    %edi
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
  800355:	56                   	push   %esi
  800356:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800357:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80035a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800360:	e8 00 fe ff ff       	call   800165 <sys_getenvid>
  800365:	83 ec 0c             	sub    $0xc,%esp
  800368:	ff 75 0c             	pushl  0xc(%ebp)
  80036b:	ff 75 08             	pushl  0x8(%ebp)
  80036e:	56                   	push   %esi
  80036f:	50                   	push   %eax
  800370:	68 58 10 80 00       	push   $0x801058
  800375:	e8 b1 00 00 00       	call   80042b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80037a:	83 c4 18             	add    $0x18,%esp
  80037d:	53                   	push   %ebx
  80037e:	ff 75 10             	pushl  0x10(%ebp)
  800381:	e8 54 00 00 00       	call   8003da <vcprintf>
	cprintf("\n");
  800386:	c7 04 24 7c 10 80 00 	movl   $0x80107c,(%esp)
  80038d:	e8 99 00 00 00       	call   80042b <cprintf>
  800392:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800395:	cc                   	int3   
  800396:	eb fd                	jmp    800395 <_panic+0x43>

00800398 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	53                   	push   %ebx
  80039c:	83 ec 04             	sub    $0x4,%esp
  80039f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003a2:	8b 13                	mov    (%ebx),%edx
  8003a4:	8d 42 01             	lea    0x1(%edx),%eax
  8003a7:	89 03                	mov    %eax,(%ebx)
  8003a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ac:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003b0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b5:	75 1a                	jne    8003d1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003b7:	83 ec 08             	sub    $0x8,%esp
  8003ba:	68 ff 00 00 00       	push   $0xff
  8003bf:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c2:	50                   	push   %eax
  8003c3:	e8 1f fd ff ff       	call   8000e7 <sys_cputs>
		b->idx = 0;
  8003c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ce:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003d1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    

008003da <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ea:	00 00 00 
	b.cnt = 0;
  8003ed:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003f4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f7:	ff 75 0c             	pushl  0xc(%ebp)
  8003fa:	ff 75 08             	pushl  0x8(%ebp)
  8003fd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800403:	50                   	push   %eax
  800404:	68 98 03 80 00       	push   $0x800398
  800409:	e8 1a 01 00 00       	call   800528 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80040e:	83 c4 08             	add    $0x8,%esp
  800411:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800417:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80041d:	50                   	push   %eax
  80041e:	e8 c4 fc ff ff       	call   8000e7 <sys_cputs>

	return b.cnt;
}
  800423:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800429:	c9                   	leave  
  80042a:	c3                   	ret    

0080042b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80042b:	55                   	push   %ebp
  80042c:	89 e5                	mov    %esp,%ebp
  80042e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800431:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800434:	50                   	push   %eax
  800435:	ff 75 08             	pushl  0x8(%ebp)
  800438:	e8 9d ff ff ff       	call   8003da <vcprintf>
	va_end(ap);

	return cnt;
}
  80043d:	c9                   	leave  
  80043e:	c3                   	ret    

0080043f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80043f:	55                   	push   %ebp
  800440:	89 e5                	mov    %esp,%ebp
  800442:	57                   	push   %edi
  800443:	56                   	push   %esi
  800444:	53                   	push   %ebx
  800445:	83 ec 1c             	sub    $0x1c,%esp
  800448:	89 c7                	mov    %eax,%edi
  80044a:	89 d6                	mov    %edx,%esi
  80044c:	8b 45 08             	mov    0x8(%ebp),%eax
  80044f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800452:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800455:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800458:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80045b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800460:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800463:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800466:	39 d3                	cmp    %edx,%ebx
  800468:	72 05                	jb     80046f <printnum+0x30>
  80046a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80046d:	77 45                	ja     8004b4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046f:	83 ec 0c             	sub    $0xc,%esp
  800472:	ff 75 18             	pushl  0x18(%ebp)
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80047b:	53                   	push   %ebx
  80047c:	ff 75 10             	pushl  0x10(%ebp)
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	ff 75 e4             	pushl  -0x1c(%ebp)
  800485:	ff 75 e0             	pushl  -0x20(%ebp)
  800488:	ff 75 dc             	pushl  -0x24(%ebp)
  80048b:	ff 75 d8             	pushl  -0x28(%ebp)
  80048e:	e8 ed 08 00 00       	call   800d80 <__udivdi3>
  800493:	83 c4 18             	add    $0x18,%esp
  800496:	52                   	push   %edx
  800497:	50                   	push   %eax
  800498:	89 f2                	mov    %esi,%edx
  80049a:	89 f8                	mov    %edi,%eax
  80049c:	e8 9e ff ff ff       	call   80043f <printnum>
  8004a1:	83 c4 20             	add    $0x20,%esp
  8004a4:	eb 18                	jmp    8004be <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	56                   	push   %esi
  8004aa:	ff 75 18             	pushl  0x18(%ebp)
  8004ad:	ff d7                	call   *%edi
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	eb 03                	jmp    8004b7 <printnum+0x78>
  8004b4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004b7:	83 eb 01             	sub    $0x1,%ebx
  8004ba:	85 db                	test   %ebx,%ebx
  8004bc:	7f e8                	jg     8004a6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	56                   	push   %esi
  8004c2:	83 ec 04             	sub    $0x4,%esp
  8004c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8004cb:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ce:	ff 75 d8             	pushl  -0x28(%ebp)
  8004d1:	e8 da 09 00 00       	call   800eb0 <__umoddi3>
  8004d6:	83 c4 14             	add    $0x14,%esp
  8004d9:	0f be 80 7e 10 80 00 	movsbl 0x80107e(%eax),%eax
  8004e0:	50                   	push   %eax
  8004e1:	ff d7                	call   *%edi
}
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e9:	5b                   	pop    %ebx
  8004ea:	5e                   	pop    %esi
  8004eb:	5f                   	pop    %edi
  8004ec:	5d                   	pop    %ebp
  8004ed:	c3                   	ret    

008004ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004f4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f8:	8b 10                	mov    (%eax),%edx
  8004fa:	3b 50 04             	cmp    0x4(%eax),%edx
  8004fd:	73 0a                	jae    800509 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ff:	8d 4a 01             	lea    0x1(%edx),%ecx
  800502:	89 08                	mov    %ecx,(%eax)
  800504:	8b 45 08             	mov    0x8(%ebp),%eax
  800507:	88 02                	mov    %al,(%edx)
}
  800509:	5d                   	pop    %ebp
  80050a:	c3                   	ret    

0080050b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80050b:	55                   	push   %ebp
  80050c:	89 e5                	mov    %esp,%ebp
  80050e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800511:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800514:	50                   	push   %eax
  800515:	ff 75 10             	pushl  0x10(%ebp)
  800518:	ff 75 0c             	pushl  0xc(%ebp)
  80051b:	ff 75 08             	pushl  0x8(%ebp)
  80051e:	e8 05 00 00 00       	call   800528 <vprintfmt>
	va_end(ap);
}
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	c9                   	leave  
  800527:	c3                   	ret    

00800528 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	57                   	push   %edi
  80052c:	56                   	push   %esi
  80052d:	53                   	push   %ebx
  80052e:	83 ec 2c             	sub    $0x2c,%esp
  800531:	8b 75 08             	mov    0x8(%ebp),%esi
  800534:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800537:	8b 7d 10             	mov    0x10(%ebp),%edi
  80053a:	eb 12                	jmp    80054e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80053c:	85 c0                	test   %eax,%eax
  80053e:	0f 84 42 04 00 00    	je     800986 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	53                   	push   %ebx
  800548:	50                   	push   %eax
  800549:	ff d6                	call   *%esi
  80054b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80054e:	83 c7 01             	add    $0x1,%edi
  800551:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800555:	83 f8 25             	cmp    $0x25,%eax
  800558:	75 e2                	jne    80053c <vprintfmt+0x14>
  80055a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80055e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800565:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80056c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800573:	b9 00 00 00 00       	mov    $0x0,%ecx
  800578:	eb 07                	jmp    800581 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80057d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800581:	8d 47 01             	lea    0x1(%edi),%eax
  800584:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800587:	0f b6 07             	movzbl (%edi),%eax
  80058a:	0f b6 d0             	movzbl %al,%edx
  80058d:	83 e8 23             	sub    $0x23,%eax
  800590:	3c 55                	cmp    $0x55,%al
  800592:	0f 87 d3 03 00 00    	ja     80096b <vprintfmt+0x443>
  800598:	0f b6 c0             	movzbl %al,%eax
  80059b:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  8005a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a9:	eb d6                	jmp    800581 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005bd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005c0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005c3:	83 f9 09             	cmp    $0x9,%ecx
  8005c6:	77 3f                	ja     800607 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005cb:	eb e9                	jmp    8005b6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 00                	mov    (%eax),%eax
  8005d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8d 40 04             	lea    0x4(%eax),%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e1:	eb 2a                	jmp    80060d <vprintfmt+0xe5>
  8005e3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e6:	85 c0                	test   %eax,%eax
  8005e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ed:	0f 49 d0             	cmovns %eax,%edx
  8005f0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f6:	eb 89                	jmp    800581 <vprintfmt+0x59>
  8005f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005fb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800602:	e9 7a ff ff ff       	jmp    800581 <vprintfmt+0x59>
  800607:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80060a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80060d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800611:	0f 89 6a ff ff ff    	jns    800581 <vprintfmt+0x59>
				width = precision, precision = -1;
  800617:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80061a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80061d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800624:	e9 58 ff ff ff       	jmp    800581 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800629:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80062f:	e9 4d ff ff ff       	jmp    800581 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 78 04             	lea    0x4(%eax),%edi
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	ff 30                	pushl  (%eax)
  800640:	ff d6                	call   *%esi
			break;
  800642:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800645:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800648:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80064b:	e9 fe fe ff ff       	jmp    80054e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8d 78 04             	lea    0x4(%eax),%edi
  800656:	8b 00                	mov    (%eax),%eax
  800658:	99                   	cltd   
  800659:	31 d0                	xor    %edx,%eax
  80065b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80065d:	83 f8 08             	cmp    $0x8,%eax
  800660:	7f 0b                	jg     80066d <vprintfmt+0x145>
  800662:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  800669:	85 d2                	test   %edx,%edx
  80066b:	75 1b                	jne    800688 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80066d:	50                   	push   %eax
  80066e:	68 96 10 80 00       	push   $0x801096
  800673:	53                   	push   %ebx
  800674:	56                   	push   %esi
  800675:	e8 91 fe ff ff       	call   80050b <printfmt>
  80067a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80067d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800680:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800683:	e9 c6 fe ff ff       	jmp    80054e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800688:	52                   	push   %edx
  800689:	68 9f 10 80 00       	push   $0x80109f
  80068e:	53                   	push   %ebx
  80068f:	56                   	push   %esi
  800690:	e8 76 fe ff ff       	call   80050b <printfmt>
  800695:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800698:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069e:	e9 ab fe ff ff       	jmp    80054e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	83 c0 04             	add    $0x4,%eax
  8006a9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006b1:	85 ff                	test   %edi,%edi
  8006b3:	b8 8f 10 80 00       	mov    $0x80108f,%eax
  8006b8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006bb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006bf:	0f 8e 94 00 00 00    	jle    800759 <vprintfmt+0x231>
  8006c5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c9:	0f 84 98 00 00 00    	je     800767 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d5:	57                   	push   %edi
  8006d6:	e8 33 03 00 00       	call   800a0e <strnlen>
  8006db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006de:	29 c1                	sub    %eax,%ecx
  8006e0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006e3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006ea:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f2:	eb 0f                	jmp    800703 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fd:	83 ef 01             	sub    $0x1,%edi
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	85 ff                	test   %edi,%edi
  800705:	7f ed                	jg     8006f4 <vprintfmt+0x1cc>
  800707:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80070a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	b8 00 00 00 00       	mov    $0x0,%eax
  800714:	0f 49 c1             	cmovns %ecx,%eax
  800717:	29 c1                	sub    %eax,%ecx
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	89 cb                	mov    %ecx,%ebx
  800724:	eb 4d                	jmp    800773 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800726:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80072a:	74 1b                	je     800747 <vprintfmt+0x21f>
  80072c:	0f be c0             	movsbl %al,%eax
  80072f:	83 e8 20             	sub    $0x20,%eax
  800732:	83 f8 5e             	cmp    $0x5e,%eax
  800735:	76 10                	jbe    800747 <vprintfmt+0x21f>
					putch('?', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	6a 3f                	push   $0x3f
  80073f:	ff 55 08             	call   *0x8(%ebp)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb 0d                	jmp    800754 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800747:	83 ec 08             	sub    $0x8,%esp
  80074a:	ff 75 0c             	pushl  0xc(%ebp)
  80074d:	52                   	push   %edx
  80074e:	ff 55 08             	call   *0x8(%ebp)
  800751:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800754:	83 eb 01             	sub    $0x1,%ebx
  800757:	eb 1a                	jmp    800773 <vprintfmt+0x24b>
  800759:	89 75 08             	mov    %esi,0x8(%ebp)
  80075c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800762:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800765:	eb 0c                	jmp    800773 <vprintfmt+0x24b>
  800767:	89 75 08             	mov    %esi,0x8(%ebp)
  80076a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80076d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800770:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800773:	83 c7 01             	add    $0x1,%edi
  800776:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80077a:	0f be d0             	movsbl %al,%edx
  80077d:	85 d2                	test   %edx,%edx
  80077f:	74 23                	je     8007a4 <vprintfmt+0x27c>
  800781:	85 f6                	test   %esi,%esi
  800783:	78 a1                	js     800726 <vprintfmt+0x1fe>
  800785:	83 ee 01             	sub    $0x1,%esi
  800788:	79 9c                	jns    800726 <vprintfmt+0x1fe>
  80078a:	89 df                	mov    %ebx,%edi
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800792:	eb 18                	jmp    8007ac <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800794:	83 ec 08             	sub    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 20                	push   $0x20
  80079a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079c:	83 ef 01             	sub    $0x1,%edi
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 08                	jmp    8007ac <vprintfmt+0x284>
  8007a4:	89 df                	mov    %ebx,%edi
  8007a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ac:	85 ff                	test   %edi,%edi
  8007ae:	7f e4                	jg     800794 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007b0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007b3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b9:	e9 90 fd ff ff       	jmp    80054e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007be:	83 f9 01             	cmp    $0x1,%ecx
  8007c1:	7e 19                	jle    8007dc <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8b 50 04             	mov    0x4(%eax),%edx
  8007c9:	8b 00                	mov    (%eax),%eax
  8007cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8d 40 08             	lea    0x8(%eax),%eax
  8007d7:	89 45 14             	mov    %eax,0x14(%ebp)
  8007da:	eb 38                	jmp    800814 <vprintfmt+0x2ec>
	else if (lflag)
  8007dc:	85 c9                	test   %ecx,%ecx
  8007de:	74 1b                	je     8007fb <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8b 00                	mov    (%eax),%eax
  8007e5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e8:	89 c1                	mov    %eax,%ecx
  8007ea:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	8d 40 04             	lea    0x4(%eax),%eax
  8007f6:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f9:	eb 19                	jmp    800814 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	8b 00                	mov    (%eax),%eax
  800800:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800803:	89 c1                	mov    %eax,%ecx
  800805:	c1 f9 1f             	sar    $0x1f,%ecx
  800808:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 40 04             	lea    0x4(%eax),%eax
  800811:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800814:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800817:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80081a:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80081f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800823:	0f 89 0e 01 00 00    	jns    800937 <vprintfmt+0x40f>
				putch('-', putdat);
  800829:	83 ec 08             	sub    $0x8,%esp
  80082c:	53                   	push   %ebx
  80082d:	6a 2d                	push   $0x2d
  80082f:	ff d6                	call   *%esi
				num = -(long long) num;
  800831:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800834:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800837:	f7 da                	neg    %edx
  800839:	83 d1 00             	adc    $0x0,%ecx
  80083c:	f7 d9                	neg    %ecx
  80083e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800841:	b8 0a 00 00 00       	mov    $0xa,%eax
  800846:	e9 ec 00 00 00       	jmp    800937 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80084b:	83 f9 01             	cmp    $0x1,%ecx
  80084e:	7e 18                	jle    800868 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8b 10                	mov    (%eax),%edx
  800855:	8b 48 04             	mov    0x4(%eax),%ecx
  800858:	8d 40 08             	lea    0x8(%eax),%eax
  80085b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80085e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800863:	e9 cf 00 00 00       	jmp    800937 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800868:	85 c9                	test   %ecx,%ecx
  80086a:	74 1a                	je     800886 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80086c:	8b 45 14             	mov    0x14(%ebp),%eax
  80086f:	8b 10                	mov    (%eax),%edx
  800871:	b9 00 00 00 00       	mov    $0x0,%ecx
  800876:	8d 40 04             	lea    0x4(%eax),%eax
  800879:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80087c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800881:	e9 b1 00 00 00       	jmp    800937 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800886:	8b 45 14             	mov    0x14(%ebp),%eax
  800889:	8b 10                	mov    (%eax),%edx
  80088b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800890:	8d 40 04             	lea    0x4(%eax),%eax
  800893:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800896:	b8 0a 00 00 00       	mov    $0xa,%eax
  80089b:	e9 97 00 00 00       	jmp    800937 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	6a 58                	push   $0x58
  8008a6:	ff d6                	call   *%esi
			putch('X', putdat);
  8008a8:	83 c4 08             	add    $0x8,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	6a 58                	push   $0x58
  8008ae:	ff d6                	call   *%esi
			putch('X', putdat);
  8008b0:	83 c4 08             	add    $0x8,%esp
  8008b3:	53                   	push   %ebx
  8008b4:	6a 58                	push   $0x58
  8008b6:	ff d6                	call   *%esi
			break;
  8008b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008be:	e9 8b fc ff ff       	jmp    80054e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	6a 30                	push   $0x30
  8008c9:	ff d6                	call   *%esi
			putch('x', putdat);
  8008cb:	83 c4 08             	add    $0x8,%esp
  8008ce:	53                   	push   %ebx
  8008cf:	6a 78                	push   $0x78
  8008d1:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d6:	8b 10                	mov    (%eax),%edx
  8008d8:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008dd:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008e0:	8d 40 04             	lea    0x4(%eax),%eax
  8008e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008eb:	eb 4a                	jmp    800937 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008ed:	83 f9 01             	cmp    $0x1,%ecx
  8008f0:	7e 15                	jle    800907 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8b 10                	mov    (%eax),%edx
  8008f7:	8b 48 04             	mov    0x4(%eax),%ecx
  8008fa:	8d 40 08             	lea    0x8(%eax),%eax
  8008fd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800900:	b8 10 00 00 00       	mov    $0x10,%eax
  800905:	eb 30                	jmp    800937 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800907:	85 c9                	test   %ecx,%ecx
  800909:	74 17                	je     800922 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80090b:	8b 45 14             	mov    0x14(%ebp),%eax
  80090e:	8b 10                	mov    (%eax),%edx
  800910:	b9 00 00 00 00       	mov    $0x0,%ecx
  800915:	8d 40 04             	lea    0x4(%eax),%eax
  800918:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80091b:	b8 10 00 00 00       	mov    $0x10,%eax
  800920:	eb 15                	jmp    800937 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800922:	8b 45 14             	mov    0x14(%ebp),%eax
  800925:	8b 10                	mov    (%eax),%edx
  800927:	b9 00 00 00 00       	mov    $0x0,%ecx
  80092c:	8d 40 04             	lea    0x4(%eax),%eax
  80092f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800932:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800937:	83 ec 0c             	sub    $0xc,%esp
  80093a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80093e:	57                   	push   %edi
  80093f:	ff 75 e0             	pushl  -0x20(%ebp)
  800942:	50                   	push   %eax
  800943:	51                   	push   %ecx
  800944:	52                   	push   %edx
  800945:	89 da                	mov    %ebx,%edx
  800947:	89 f0                	mov    %esi,%eax
  800949:	e8 f1 fa ff ff       	call   80043f <printnum>
			break;
  80094e:	83 c4 20             	add    $0x20,%esp
  800951:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800954:	e9 f5 fb ff ff       	jmp    80054e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800959:	83 ec 08             	sub    $0x8,%esp
  80095c:	53                   	push   %ebx
  80095d:	52                   	push   %edx
  80095e:	ff d6                	call   *%esi
			break;
  800960:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800963:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800966:	e9 e3 fb ff ff       	jmp    80054e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80096b:	83 ec 08             	sub    $0x8,%esp
  80096e:	53                   	push   %ebx
  80096f:	6a 25                	push   $0x25
  800971:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800973:	83 c4 10             	add    $0x10,%esp
  800976:	eb 03                	jmp    80097b <vprintfmt+0x453>
  800978:	83 ef 01             	sub    $0x1,%edi
  80097b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80097f:	75 f7                	jne    800978 <vprintfmt+0x450>
  800981:	e9 c8 fb ff ff       	jmp    80054e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800986:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5f                   	pop    %edi
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	83 ec 18             	sub    $0x18,%esp
  800994:	8b 45 08             	mov    0x8(%ebp),%eax
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80099a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80099d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009a1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009ab:	85 c0                	test   %eax,%eax
  8009ad:	74 26                	je     8009d5 <vsnprintf+0x47>
  8009af:	85 d2                	test   %edx,%edx
  8009b1:	7e 22                	jle    8009d5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009b3:	ff 75 14             	pushl  0x14(%ebp)
  8009b6:	ff 75 10             	pushl  0x10(%ebp)
  8009b9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009bc:	50                   	push   %eax
  8009bd:	68 ee 04 80 00       	push   $0x8004ee
  8009c2:	e8 61 fb ff ff       	call   800528 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ca:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009d0:	83 c4 10             	add    $0x10,%esp
  8009d3:	eb 05                	jmp    8009da <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e5:	50                   	push   %eax
  8009e6:	ff 75 10             	pushl  0x10(%ebp)
  8009e9:	ff 75 0c             	pushl  0xc(%ebp)
  8009ec:	ff 75 08             	pushl  0x8(%ebp)
  8009ef:	e8 9a ff ff ff       	call   80098e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800a01:	eb 03                	jmp    800a06 <strlen+0x10>
		n++;
  800a03:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a06:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a0a:	75 f7                	jne    800a03 <strlen+0xd>
		n++;
	return n;
}
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a14:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a17:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1c:	eb 03                	jmp    800a21 <strnlen+0x13>
		n++;
  800a1e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a21:	39 c2                	cmp    %eax,%edx
  800a23:	74 08                	je     800a2d <strnlen+0x1f>
  800a25:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a29:	75 f3                	jne    800a1e <strnlen+0x10>
  800a2b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
  800a32:	53                   	push   %ebx
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a39:	89 c2                	mov    %eax,%edx
  800a3b:	83 c2 01             	add    $0x1,%edx
  800a3e:	83 c1 01             	add    $0x1,%ecx
  800a41:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a45:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a48:	84 db                	test   %bl,%bl
  800a4a:	75 ef                	jne    800a3b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a4c:	5b                   	pop    %ebx
  800a4d:	5d                   	pop    %ebp
  800a4e:	c3                   	ret    

00800a4f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a4f:	55                   	push   %ebp
  800a50:	89 e5                	mov    %esp,%ebp
  800a52:	53                   	push   %ebx
  800a53:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a56:	53                   	push   %ebx
  800a57:	e8 9a ff ff ff       	call   8009f6 <strlen>
  800a5c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a5f:	ff 75 0c             	pushl  0xc(%ebp)
  800a62:	01 d8                	add    %ebx,%eax
  800a64:	50                   	push   %eax
  800a65:	e8 c5 ff ff ff       	call   800a2f <strcpy>
	return dst;
}
  800a6a:	89 d8                	mov    %ebx,%eax
  800a6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a6f:	c9                   	leave  
  800a70:	c3                   	ret    

00800a71 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 75 08             	mov    0x8(%ebp),%esi
  800a79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7c:	89 f3                	mov    %esi,%ebx
  800a7e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a81:	89 f2                	mov    %esi,%edx
  800a83:	eb 0f                	jmp    800a94 <strncpy+0x23>
		*dst++ = *src;
  800a85:	83 c2 01             	add    $0x1,%edx
  800a88:	0f b6 01             	movzbl (%ecx),%eax
  800a8b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a8e:	80 39 01             	cmpb   $0x1,(%ecx)
  800a91:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a94:	39 da                	cmp    %ebx,%edx
  800a96:	75 ed                	jne    800a85 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a98:	89 f0                	mov    %esi,%eax
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	56                   	push   %esi
  800aa2:	53                   	push   %ebx
  800aa3:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa9:	8b 55 10             	mov    0x10(%ebp),%edx
  800aac:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aae:	85 d2                	test   %edx,%edx
  800ab0:	74 21                	je     800ad3 <strlcpy+0x35>
  800ab2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ab6:	89 f2                	mov    %esi,%edx
  800ab8:	eb 09                	jmp    800ac3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aba:	83 c2 01             	add    $0x1,%edx
  800abd:	83 c1 01             	add    $0x1,%ecx
  800ac0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ac3:	39 c2                	cmp    %eax,%edx
  800ac5:	74 09                	je     800ad0 <strlcpy+0x32>
  800ac7:	0f b6 19             	movzbl (%ecx),%ebx
  800aca:	84 db                	test   %bl,%bl
  800acc:	75 ec                	jne    800aba <strlcpy+0x1c>
  800ace:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ad0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ad3:	29 f0                	sub    %esi,%eax
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ae2:	eb 06                	jmp    800aea <strcmp+0x11>
		p++, q++;
  800ae4:	83 c1 01             	add    $0x1,%ecx
  800ae7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aea:	0f b6 01             	movzbl (%ecx),%eax
  800aed:	84 c0                	test   %al,%al
  800aef:	74 04                	je     800af5 <strcmp+0x1c>
  800af1:	3a 02                	cmp    (%edx),%al
  800af3:	74 ef                	je     800ae4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af5:	0f b6 c0             	movzbl %al,%eax
  800af8:	0f b6 12             	movzbl (%edx),%edx
  800afb:	29 d0                	sub    %edx,%eax
}
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	53                   	push   %ebx
  800b03:	8b 45 08             	mov    0x8(%ebp),%eax
  800b06:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b09:	89 c3                	mov    %eax,%ebx
  800b0b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b0e:	eb 06                	jmp    800b16 <strncmp+0x17>
		n--, p++, q++;
  800b10:	83 c0 01             	add    $0x1,%eax
  800b13:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b16:	39 d8                	cmp    %ebx,%eax
  800b18:	74 15                	je     800b2f <strncmp+0x30>
  800b1a:	0f b6 08             	movzbl (%eax),%ecx
  800b1d:	84 c9                	test   %cl,%cl
  800b1f:	74 04                	je     800b25 <strncmp+0x26>
  800b21:	3a 0a                	cmp    (%edx),%cl
  800b23:	74 eb                	je     800b10 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b25:	0f b6 00             	movzbl (%eax),%eax
  800b28:	0f b6 12             	movzbl (%edx),%edx
  800b2b:	29 d0                	sub    %edx,%eax
  800b2d:	eb 05                	jmp    800b34 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b2f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b41:	eb 07                	jmp    800b4a <strchr+0x13>
		if (*s == c)
  800b43:	38 ca                	cmp    %cl,%dl
  800b45:	74 0f                	je     800b56 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b47:	83 c0 01             	add    $0x1,%eax
  800b4a:	0f b6 10             	movzbl (%eax),%edx
  800b4d:	84 d2                	test   %dl,%dl
  800b4f:	75 f2                	jne    800b43 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b62:	eb 03                	jmp    800b67 <strfind+0xf>
  800b64:	83 c0 01             	add    $0x1,%eax
  800b67:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b6a:	38 ca                	cmp    %cl,%dl
  800b6c:	74 04                	je     800b72 <strfind+0x1a>
  800b6e:	84 d2                	test   %dl,%dl
  800b70:	75 f2                	jne    800b64 <strfind+0xc>
			break;
	return (char *) s;
}
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	57                   	push   %edi
  800b78:	56                   	push   %esi
  800b79:	53                   	push   %ebx
  800b7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b80:	85 c9                	test   %ecx,%ecx
  800b82:	74 36                	je     800bba <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b8a:	75 28                	jne    800bb4 <memset+0x40>
  800b8c:	f6 c1 03             	test   $0x3,%cl
  800b8f:	75 23                	jne    800bb4 <memset+0x40>
		c &= 0xFF;
  800b91:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b95:	89 d3                	mov    %edx,%ebx
  800b97:	c1 e3 08             	shl    $0x8,%ebx
  800b9a:	89 d6                	mov    %edx,%esi
  800b9c:	c1 e6 18             	shl    $0x18,%esi
  800b9f:	89 d0                	mov    %edx,%eax
  800ba1:	c1 e0 10             	shl    $0x10,%eax
  800ba4:	09 f0                	or     %esi,%eax
  800ba6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ba8:	89 d8                	mov    %ebx,%eax
  800baa:	09 d0                	or     %edx,%eax
  800bac:	c1 e9 02             	shr    $0x2,%ecx
  800baf:	fc                   	cld    
  800bb0:	f3 ab                	rep stos %eax,%es:(%edi)
  800bb2:	eb 06                	jmp    800bba <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb7:	fc                   	cld    
  800bb8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bba:	89 f8                	mov    %edi,%eax
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	57                   	push   %edi
  800bc5:	56                   	push   %esi
  800bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bcc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bcf:	39 c6                	cmp    %eax,%esi
  800bd1:	73 35                	jae    800c08 <memmove+0x47>
  800bd3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd6:	39 d0                	cmp    %edx,%eax
  800bd8:	73 2e                	jae    800c08 <memmove+0x47>
		s += n;
		d += n;
  800bda:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdd:	89 d6                	mov    %edx,%esi
  800bdf:	09 fe                	or     %edi,%esi
  800be1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800be7:	75 13                	jne    800bfc <memmove+0x3b>
  800be9:	f6 c1 03             	test   $0x3,%cl
  800bec:	75 0e                	jne    800bfc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bee:	83 ef 04             	sub    $0x4,%edi
  800bf1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bf4:	c1 e9 02             	shr    $0x2,%ecx
  800bf7:	fd                   	std    
  800bf8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bfa:	eb 09                	jmp    800c05 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bfc:	83 ef 01             	sub    $0x1,%edi
  800bff:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c02:	fd                   	std    
  800c03:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c05:	fc                   	cld    
  800c06:	eb 1d                	jmp    800c25 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c08:	89 f2                	mov    %esi,%edx
  800c0a:	09 c2                	or     %eax,%edx
  800c0c:	f6 c2 03             	test   $0x3,%dl
  800c0f:	75 0f                	jne    800c20 <memmove+0x5f>
  800c11:	f6 c1 03             	test   $0x3,%cl
  800c14:	75 0a                	jne    800c20 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c16:	c1 e9 02             	shr    $0x2,%ecx
  800c19:	89 c7                	mov    %eax,%edi
  800c1b:	fc                   	cld    
  800c1c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c1e:	eb 05                	jmp    800c25 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c20:	89 c7                	mov    %eax,%edi
  800c22:	fc                   	cld    
  800c23:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c2c:	ff 75 10             	pushl  0x10(%ebp)
  800c2f:	ff 75 0c             	pushl  0xc(%ebp)
  800c32:	ff 75 08             	pushl  0x8(%ebp)
  800c35:	e8 87 ff ff ff       	call   800bc1 <memmove>
}
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    

00800c3c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	8b 45 08             	mov    0x8(%ebp),%eax
  800c44:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c47:	89 c6                	mov    %eax,%esi
  800c49:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c4c:	eb 1a                	jmp    800c68 <memcmp+0x2c>
		if (*s1 != *s2)
  800c4e:	0f b6 08             	movzbl (%eax),%ecx
  800c51:	0f b6 1a             	movzbl (%edx),%ebx
  800c54:	38 d9                	cmp    %bl,%cl
  800c56:	74 0a                	je     800c62 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c58:	0f b6 c1             	movzbl %cl,%eax
  800c5b:	0f b6 db             	movzbl %bl,%ebx
  800c5e:	29 d8                	sub    %ebx,%eax
  800c60:	eb 0f                	jmp    800c71 <memcmp+0x35>
		s1++, s2++;
  800c62:	83 c0 01             	add    $0x1,%eax
  800c65:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c68:	39 f0                	cmp    %esi,%eax
  800c6a:	75 e2                	jne    800c4e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	53                   	push   %ebx
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c7c:	89 c1                	mov    %eax,%ecx
  800c7e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c81:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c85:	eb 0a                	jmp    800c91 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c87:	0f b6 10             	movzbl (%eax),%edx
  800c8a:	39 da                	cmp    %ebx,%edx
  800c8c:	74 07                	je     800c95 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c8e:	83 c0 01             	add    $0x1,%eax
  800c91:	39 c8                	cmp    %ecx,%eax
  800c93:	72 f2                	jb     800c87 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c95:	5b                   	pop    %ebx
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca4:	eb 03                	jmp    800ca9 <strtol+0x11>
		s++;
  800ca6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca9:	0f b6 01             	movzbl (%ecx),%eax
  800cac:	3c 20                	cmp    $0x20,%al
  800cae:	74 f6                	je     800ca6 <strtol+0xe>
  800cb0:	3c 09                	cmp    $0x9,%al
  800cb2:	74 f2                	je     800ca6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb4:	3c 2b                	cmp    $0x2b,%al
  800cb6:	75 0a                	jne    800cc2 <strtol+0x2a>
		s++;
  800cb8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cbb:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc0:	eb 11                	jmp    800cd3 <strtol+0x3b>
  800cc2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cc7:	3c 2d                	cmp    $0x2d,%al
  800cc9:	75 08                	jne    800cd3 <strtol+0x3b>
		s++, neg = 1;
  800ccb:	83 c1 01             	add    $0x1,%ecx
  800cce:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cd9:	75 15                	jne    800cf0 <strtol+0x58>
  800cdb:	80 39 30             	cmpb   $0x30,(%ecx)
  800cde:	75 10                	jne    800cf0 <strtol+0x58>
  800ce0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ce4:	75 7c                	jne    800d62 <strtol+0xca>
		s += 2, base = 16;
  800ce6:	83 c1 02             	add    $0x2,%ecx
  800ce9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cee:	eb 16                	jmp    800d06 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cf0:	85 db                	test   %ebx,%ebx
  800cf2:	75 12                	jne    800d06 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cf4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cf9:	80 39 30             	cmpb   $0x30,(%ecx)
  800cfc:	75 08                	jne    800d06 <strtol+0x6e>
		s++, base = 8;
  800cfe:	83 c1 01             	add    $0x1,%ecx
  800d01:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d06:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d0e:	0f b6 11             	movzbl (%ecx),%edx
  800d11:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d14:	89 f3                	mov    %esi,%ebx
  800d16:	80 fb 09             	cmp    $0x9,%bl
  800d19:	77 08                	ja     800d23 <strtol+0x8b>
			dig = *s - '0';
  800d1b:	0f be d2             	movsbl %dl,%edx
  800d1e:	83 ea 30             	sub    $0x30,%edx
  800d21:	eb 22                	jmp    800d45 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d23:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d26:	89 f3                	mov    %esi,%ebx
  800d28:	80 fb 19             	cmp    $0x19,%bl
  800d2b:	77 08                	ja     800d35 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d2d:	0f be d2             	movsbl %dl,%edx
  800d30:	83 ea 57             	sub    $0x57,%edx
  800d33:	eb 10                	jmp    800d45 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d35:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d38:	89 f3                	mov    %esi,%ebx
  800d3a:	80 fb 19             	cmp    $0x19,%bl
  800d3d:	77 16                	ja     800d55 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d3f:	0f be d2             	movsbl %dl,%edx
  800d42:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d45:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d48:	7d 0b                	jge    800d55 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d4a:	83 c1 01             	add    $0x1,%ecx
  800d4d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d51:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d53:	eb b9                	jmp    800d0e <strtol+0x76>

	if (endptr)
  800d55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d59:	74 0d                	je     800d68 <strtol+0xd0>
		*endptr = (char *) s;
  800d5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d5e:	89 0e                	mov    %ecx,(%esi)
  800d60:	eb 06                	jmp    800d68 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d62:	85 db                	test   %ebx,%ebx
  800d64:	74 98                	je     800cfe <strtol+0x66>
  800d66:	eb 9e                	jmp    800d06 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d68:	89 c2                	mov    %eax,%edx
  800d6a:	f7 da                	neg    %edx
  800d6c:	85 ff                	test   %edi,%edi
  800d6e:	0f 45 c2             	cmovne %edx,%eax
}
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    
  800d76:	66 90                	xchg   %ax,%ax
  800d78:	66 90                	xchg   %ax,%ax
  800d7a:	66 90                	xchg   %ax,%ax
  800d7c:	66 90                	xchg   %ax,%ax
  800d7e:	66 90                	xchg   %ax,%ax

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
