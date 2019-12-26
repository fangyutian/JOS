
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
  800045:	57                   	push   %edi
  800046:	56                   	push   %esi
  800047:	53                   	push   %ebx
  800048:	83 ec 0c             	sub    $0xc,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004b:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800052:	00 00 00 
	envid_t eid = sys_getenvid();
  800055:	e8 06 01 00 00       	call   800160 <sys_getenvid>
  80005a:	8b 3d 04 20 80 00    	mov    0x802004,%edi
  800060:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  800065:	be 00 00 00 00       	mov    $0x0,%esi
	int i;
	for (i = 0; i < NENV; i++) {
  80006a:	ba 00 00 00 00       	mov    $0x0,%edx
		if (envs[i].env_id == eid) {
  80006f:	6b ca 7c             	imul   $0x7c,%edx,%ecx
  800072:	81 c1 00 00 c0 ee    	add    $0xeec00000,%ecx
  800078:	8b 49 48             	mov    0x48(%ecx),%ecx
			thisenv = &(envs[i]);
  80007b:	39 c8                	cmp    %ecx,%eax
  80007d:	0f 44 fb             	cmove  %ebx,%edi
  800080:	b9 01 00 00 00       	mov    $0x1,%ecx
  800085:	0f 44 f1             	cmove  %ecx,%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
	envid_t eid = sys_getenvid();
	int i;
	for (i = 0; i < NENV; i++) {
  800088:	83 c2 01             	add    $0x1,%edx
  80008b:	83 c3 7c             	add    $0x7c,%ebx
  80008e:	81 fa 00 04 00 00    	cmp    $0x400,%edx
  800094:	75 d9                	jne    80006f <libmain+0x2d>
  800096:	89 f0                	mov    %esi,%eax
  800098:	84 c0                	test   %al,%al
  80009a:	74 06                	je     8000a2 <libmain+0x60>
  80009c:	89 3d 04 20 80 00    	mov    %edi,0x802004
			thisenv = &(envs[i]);
		}
	}

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000a6:	7e 0a                	jle    8000b2 <libmain+0x70>
		binaryname = argv[0];
  8000a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ab:	8b 00                	mov    (%eax),%eax
  8000ad:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b2:	83 ec 08             	sub    $0x8,%esp
  8000b5:	ff 75 0c             	pushl  0xc(%ebp)
  8000b8:	ff 75 08             	pushl  0x8(%ebp)
  8000bb:	e8 73 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000c0:	e8 0b 00 00 00       	call   8000d0 <exit>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000cb:	5b                   	pop    %ebx
  8000cc:	5e                   	pop    %esi
  8000cd:	5f                   	pop    %edi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    

008000d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d0:	55                   	push   %ebp
  8000d1:	89 e5                	mov    %esp,%ebp
  8000d3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000d6:	6a 00                	push   $0x0
  8000d8:	e8 42 00 00 00       	call   80011f <sys_env_destroy>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    

008000e2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f3:	89 c3                	mov    %eax,%ebx
  8000f5:	89 c7                	mov    %eax,%edi
  8000f7:	89 c6                	mov    %eax,%esi
  8000f9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000fb:	5b                   	pop    %ebx
  8000fc:	5e                   	pop    %esi
  8000fd:	5f                   	pop    %edi
  8000fe:	5d                   	pop    %ebp
  8000ff:	c3                   	ret    

00800100 <sys_cgetc>:

int
sys_cgetc(void)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	57                   	push   %edi
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800106:	ba 00 00 00 00       	mov    $0x0,%edx
  80010b:	b8 01 00 00 00       	mov    $0x1,%eax
  800110:	89 d1                	mov    %edx,%ecx
  800112:	89 d3                	mov    %edx,%ebx
  800114:	89 d7                	mov    %edx,%edi
  800116:	89 d6                	mov    %edx,%esi
  800118:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80011a:	5b                   	pop    %ebx
  80011b:	5e                   	pop    %esi
  80011c:	5f                   	pop    %edi
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	57                   	push   %edi
  800123:	56                   	push   %esi
  800124:	53                   	push   %ebx
  800125:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800128:	b9 00 00 00 00       	mov    $0x0,%ecx
  80012d:	b8 03 00 00 00       	mov    $0x3,%eax
  800132:	8b 55 08             	mov    0x8(%ebp),%edx
  800135:	89 cb                	mov    %ecx,%ebx
  800137:	89 cf                	mov    %ecx,%edi
  800139:	89 ce                	mov    %ecx,%esi
  80013b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80013d:	85 c0                	test   %eax,%eax
  80013f:	7e 17                	jle    800158 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800141:	83 ec 0c             	sub    $0xc,%esp
  800144:	50                   	push   %eax
  800145:	6a 03                	push   $0x3
  800147:	68 2a 10 80 00       	push   $0x80102a
  80014c:	6a 23                	push   $0x23
  80014e:	68 47 10 80 00       	push   $0x801047
  800153:	e8 f5 01 00 00       	call   80034d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800158:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015b:	5b                   	pop    %ebx
  80015c:	5e                   	pop    %esi
  80015d:	5f                   	pop    %edi
  80015e:	5d                   	pop    %ebp
  80015f:	c3                   	ret    

00800160 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	57                   	push   %edi
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800166:	ba 00 00 00 00       	mov    $0x0,%edx
  80016b:	b8 02 00 00 00       	mov    $0x2,%eax
  800170:	89 d1                	mov    %edx,%ecx
  800172:	89 d3                	mov    %edx,%ebx
  800174:	89 d7                	mov    %edx,%edi
  800176:	89 d6                	mov    %edx,%esi
  800178:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80017a:	5b                   	pop    %ebx
  80017b:	5e                   	pop    %esi
  80017c:	5f                   	pop    %edi
  80017d:	5d                   	pop    %ebp
  80017e:	c3                   	ret    

0080017f <sys_yield>:

void
sys_yield(void)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	57                   	push   %edi
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800185:	ba 00 00 00 00       	mov    $0x0,%edx
  80018a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80018f:	89 d1                	mov    %edx,%ecx
  800191:	89 d3                	mov    %edx,%ebx
  800193:	89 d7                	mov    %edx,%edi
  800195:	89 d6                	mov    %edx,%esi
  800197:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	57                   	push   %edi
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a7:	be 00 00 00 00       	mov    $0x0,%esi
  8001ac:	b8 04 00 00 00       	mov    $0x4,%eax
  8001b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ba:	89 f7                	mov    %esi,%edi
  8001bc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001be:	85 c0                	test   %eax,%eax
  8001c0:	7e 17                	jle    8001d9 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c2:	83 ec 0c             	sub    $0xc,%esp
  8001c5:	50                   	push   %eax
  8001c6:	6a 04                	push   $0x4
  8001c8:	68 2a 10 80 00       	push   $0x80102a
  8001cd:	6a 23                	push   $0x23
  8001cf:	68 47 10 80 00       	push   $0x801047
  8001d4:	e8 74 01 00 00       	call   80034d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5e                   	pop    %esi
  8001de:	5f                   	pop    %edi
  8001df:	5d                   	pop    %ebp
  8001e0:	c3                   	ret    

008001e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	57                   	push   %edi
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001fb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800200:	85 c0                	test   %eax,%eax
  800202:	7e 17                	jle    80021b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800204:	83 ec 0c             	sub    $0xc,%esp
  800207:	50                   	push   %eax
  800208:	6a 05                	push   $0x5
  80020a:	68 2a 10 80 00       	push   $0x80102a
  80020f:	6a 23                	push   $0x23
  800211:	68 47 10 80 00       	push   $0x801047
  800216:	e8 32 01 00 00       	call   80034d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5f                   	pop    %edi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800231:	b8 06 00 00 00       	mov    $0x6,%eax
  800236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800239:	8b 55 08             	mov    0x8(%ebp),%edx
  80023c:	89 df                	mov    %ebx,%edi
  80023e:	89 de                	mov    %ebx,%esi
  800240:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800242:	85 c0                	test   %eax,%eax
  800244:	7e 17                	jle    80025d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	50                   	push   %eax
  80024a:	6a 06                	push   $0x6
  80024c:	68 2a 10 80 00       	push   $0x80102a
  800251:	6a 23                	push   $0x23
  800253:	68 47 10 80 00       	push   $0x801047
  800258:	e8 f0 00 00 00       	call   80034d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80025d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800260:	5b                   	pop    %ebx
  800261:	5e                   	pop    %esi
  800262:	5f                   	pop    %edi
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    

00800265 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	57                   	push   %edi
  800269:	56                   	push   %esi
  80026a:	53                   	push   %ebx
  80026b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800273:	b8 08 00 00 00       	mov    $0x8,%eax
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	8b 55 08             	mov    0x8(%ebp),%edx
  80027e:	89 df                	mov    %ebx,%edi
  800280:	89 de                	mov    %ebx,%esi
  800282:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800284:	85 c0                	test   %eax,%eax
  800286:	7e 17                	jle    80029f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800288:	83 ec 0c             	sub    $0xc,%esp
  80028b:	50                   	push   %eax
  80028c:	6a 08                	push   $0x8
  80028e:	68 2a 10 80 00       	push   $0x80102a
  800293:	6a 23                	push   $0x23
  800295:	68 47 10 80 00       	push   $0x801047
  80029a:	e8 ae 00 00 00       	call   80034d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80029f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a2:	5b                   	pop    %ebx
  8002a3:	5e                   	pop    %esi
  8002a4:	5f                   	pop    %edi
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    

008002a7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a7:	55                   	push   %ebp
  8002a8:	89 e5                	mov    %esp,%ebp
  8002aa:	57                   	push   %edi
  8002ab:	56                   	push   %esi
  8002ac:	53                   	push   %ebx
  8002ad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b5:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c0:	89 df                	mov    %ebx,%edi
  8002c2:	89 de                	mov    %ebx,%esi
  8002c4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c6:	85 c0                	test   %eax,%eax
  8002c8:	7e 17                	jle    8002e1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ca:	83 ec 0c             	sub    $0xc,%esp
  8002cd:	50                   	push   %eax
  8002ce:	6a 09                	push   $0x9
  8002d0:	68 2a 10 80 00       	push   $0x80102a
  8002d5:	6a 23                	push   $0x23
  8002d7:	68 47 10 80 00       	push   $0x801047
  8002dc:	e8 6c 00 00 00       	call   80034d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	57                   	push   %edi
  8002ed:	56                   	push   %esi
  8002ee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ef:	be 00 00 00 00       	mov    $0x0,%esi
  8002f4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800302:	8b 7d 14             	mov    0x14(%ebp),%edi
  800305:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800307:	5b                   	pop    %ebx
  800308:	5e                   	pop    %esi
  800309:	5f                   	pop    %edi
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	57                   	push   %edi
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
  800312:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800315:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031f:	8b 55 08             	mov    0x8(%ebp),%edx
  800322:	89 cb                	mov    %ecx,%ebx
  800324:	89 cf                	mov    %ecx,%edi
  800326:	89 ce                	mov    %ecx,%esi
  800328:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80032a:	85 c0                	test   %eax,%eax
  80032c:	7e 17                	jle    800345 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032e:	83 ec 0c             	sub    $0xc,%esp
  800331:	50                   	push   %eax
  800332:	6a 0c                	push   $0xc
  800334:	68 2a 10 80 00       	push   $0x80102a
  800339:	6a 23                	push   $0x23
  80033b:	68 47 10 80 00       	push   $0x801047
  800340:	e8 08 00 00 00       	call   80034d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800345:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800348:	5b                   	pop    %ebx
  800349:	5e                   	pop    %esi
  80034a:	5f                   	pop    %edi
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	56                   	push   %esi
  800351:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800352:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800355:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80035b:	e8 00 fe ff ff       	call   800160 <sys_getenvid>
  800360:	83 ec 0c             	sub    $0xc,%esp
  800363:	ff 75 0c             	pushl  0xc(%ebp)
  800366:	ff 75 08             	pushl  0x8(%ebp)
  800369:	56                   	push   %esi
  80036a:	50                   	push   %eax
  80036b:	68 58 10 80 00       	push   $0x801058
  800370:	e8 b1 00 00 00       	call   800426 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800375:	83 c4 18             	add    $0x18,%esp
  800378:	53                   	push   %ebx
  800379:	ff 75 10             	pushl  0x10(%ebp)
  80037c:	e8 54 00 00 00       	call   8003d5 <vcprintf>
	cprintf("\n");
  800381:	c7 04 24 7c 10 80 00 	movl   $0x80107c,(%esp)
  800388:	e8 99 00 00 00       	call   800426 <cprintf>
  80038d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800390:	cc                   	int3   
  800391:	eb fd                	jmp    800390 <_panic+0x43>

00800393 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	53                   	push   %ebx
  800397:	83 ec 04             	sub    $0x4,%esp
  80039a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039d:	8b 13                	mov    (%ebx),%edx
  80039f:	8d 42 01             	lea    0x1(%edx),%eax
  8003a2:	89 03                	mov    %eax,(%ebx)
  8003a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003b0:	75 1a                	jne    8003cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8003b2:	83 ec 08             	sub    $0x8,%esp
  8003b5:	68 ff 00 00 00       	push   $0xff
  8003ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8003bd:	50                   	push   %eax
  8003be:	e8 1f fd ff ff       	call   8000e2 <sys_cputs>
		b->idx = 0;
  8003c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003d3:	c9                   	leave  
  8003d4:	c3                   	ret    

008003d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e5:	00 00 00 
	b.cnt = 0;
  8003e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f2:	ff 75 0c             	pushl  0xc(%ebp)
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003fe:	50                   	push   %eax
  8003ff:	68 93 03 80 00       	push   $0x800393
  800404:	e8 1a 01 00 00       	call   800523 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800409:	83 c4 08             	add    $0x8,%esp
  80040c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800412:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800418:	50                   	push   %eax
  800419:	e8 c4 fc ff ff       	call   8000e2 <sys_cputs>

	return b.cnt;
}
  80041e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800424:	c9                   	leave  
  800425:	c3                   	ret    

00800426 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800426:	55                   	push   %ebp
  800427:	89 e5                	mov    %esp,%ebp
  800429:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80042f:	50                   	push   %eax
  800430:	ff 75 08             	pushl  0x8(%ebp)
  800433:	e8 9d ff ff ff       	call   8003d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800438:	c9                   	leave  
  800439:	c3                   	ret    

0080043a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	57                   	push   %edi
  80043e:	56                   	push   %esi
  80043f:	53                   	push   %ebx
  800440:	83 ec 1c             	sub    $0x1c,%esp
  800443:	89 c7                	mov    %eax,%edi
  800445:	89 d6                	mov    %edx,%esi
  800447:	8b 45 08             	mov    0x8(%ebp),%eax
  80044a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800450:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800453:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800456:	bb 00 00 00 00       	mov    $0x0,%ebx
  80045b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80045e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800461:	39 d3                	cmp    %edx,%ebx
  800463:	72 05                	jb     80046a <printnum+0x30>
  800465:	39 45 10             	cmp    %eax,0x10(%ebp)
  800468:	77 45                	ja     8004af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046a:	83 ec 0c             	sub    $0xc,%esp
  80046d:	ff 75 18             	pushl  0x18(%ebp)
  800470:	8b 45 14             	mov    0x14(%ebp),%eax
  800473:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800476:	53                   	push   %ebx
  800477:	ff 75 10             	pushl  0x10(%ebp)
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800480:	ff 75 e0             	pushl  -0x20(%ebp)
  800483:	ff 75 dc             	pushl  -0x24(%ebp)
  800486:	ff 75 d8             	pushl  -0x28(%ebp)
  800489:	e8 f2 08 00 00       	call   800d80 <__udivdi3>
  80048e:	83 c4 18             	add    $0x18,%esp
  800491:	52                   	push   %edx
  800492:	50                   	push   %eax
  800493:	89 f2                	mov    %esi,%edx
  800495:	89 f8                	mov    %edi,%eax
  800497:	e8 9e ff ff ff       	call   80043a <printnum>
  80049c:	83 c4 20             	add    $0x20,%esp
  80049f:	eb 18                	jmp    8004b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	56                   	push   %esi
  8004a5:	ff 75 18             	pushl  0x18(%ebp)
  8004a8:	ff d7                	call   *%edi
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	eb 03                	jmp    8004b2 <printnum+0x78>
  8004af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004b2:	83 eb 01             	sub    $0x1,%ebx
  8004b5:	85 db                	test   %ebx,%ebx
  8004b7:	7f e8                	jg     8004a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	56                   	push   %esi
  8004bd:	83 ec 04             	sub    $0x4,%esp
  8004c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8004cc:	e8 df 09 00 00       	call   800eb0 <__umoddi3>
  8004d1:	83 c4 14             	add    $0x14,%esp
  8004d4:	0f be 80 7e 10 80 00 	movsbl 0x80107e(%eax),%eax
  8004db:	50                   	push   %eax
  8004dc:	ff d7                	call   *%edi
}
  8004de:	83 c4 10             	add    $0x10,%esp
  8004e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e4:	5b                   	pop    %ebx
  8004e5:	5e                   	pop    %esi
  8004e6:	5f                   	pop    %edi
  8004e7:	5d                   	pop    %ebp
  8004e8:	c3                   	ret    

008004e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e9:	55                   	push   %ebp
  8004ea:	89 e5                	mov    %esp,%ebp
  8004ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f3:	8b 10                	mov    (%eax),%edx
  8004f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f8:	73 0a                	jae    800504 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fd:	89 08                	mov    %ecx,(%eax)
  8004ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800502:	88 02                	mov    %al,(%edx)
}
  800504:	5d                   	pop    %ebp
  800505:	c3                   	ret    

00800506 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050f:	50                   	push   %eax
  800510:	ff 75 10             	pushl  0x10(%ebp)
  800513:	ff 75 0c             	pushl  0xc(%ebp)
  800516:	ff 75 08             	pushl  0x8(%ebp)
  800519:	e8 05 00 00 00       	call   800523 <vprintfmt>
	va_end(ap);
}
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	c9                   	leave  
  800522:	c3                   	ret    

00800523 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800523:	55                   	push   %ebp
  800524:	89 e5                	mov    %esp,%ebp
  800526:	57                   	push   %edi
  800527:	56                   	push   %esi
  800528:	53                   	push   %ebx
  800529:	83 ec 2c             	sub    $0x2c,%esp
  80052c:	8b 75 08             	mov    0x8(%ebp),%esi
  80052f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800532:	8b 7d 10             	mov    0x10(%ebp),%edi
  800535:	eb 12                	jmp    800549 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800537:	85 c0                	test   %eax,%eax
  800539:	0f 84 42 04 00 00    	je     800981 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	50                   	push   %eax
  800544:	ff d6                	call   *%esi
  800546:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800549:	83 c7 01             	add    $0x1,%edi
  80054c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800550:	83 f8 25             	cmp    $0x25,%eax
  800553:	75 e2                	jne    800537 <vprintfmt+0x14>
  800555:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800559:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800560:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800567:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800573:	eb 07                	jmp    80057c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800578:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8d 47 01             	lea    0x1(%edi),%eax
  80057f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800582:	0f b6 07             	movzbl (%edi),%eax
  800585:	0f b6 d0             	movzbl %al,%edx
  800588:	83 e8 23             	sub    $0x23,%eax
  80058b:	3c 55                	cmp    $0x55,%al
  80058d:	0f 87 d3 03 00 00    	ja     800966 <vprintfmt+0x443>
  800593:	0f b6 c0             	movzbl %al,%eax
  800596:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  80059d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005a0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a4:	eb d6                	jmp    80057c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005b8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005bb:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005be:	83 f9 09             	cmp    $0x9,%ecx
  8005c1:	77 3f                	ja     800602 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c6:	eb e9                	jmp    8005b1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8d 40 04             	lea    0x4(%eax),%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005dc:	eb 2a                	jmp    800608 <vprintfmt+0xe5>
  8005de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e8:	0f 49 d0             	cmovns %eax,%edx
  8005eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f1:	eb 89                	jmp    80057c <vprintfmt+0x59>
  8005f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005fd:	e9 7a ff ff ff       	jmp    80057c <vprintfmt+0x59>
  800602:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800605:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800608:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80060c:	0f 89 6a ff ff ff    	jns    80057c <vprintfmt+0x59>
				width = precision, precision = -1;
  800612:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800615:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800618:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80061f:	e9 58 ff ff ff       	jmp    80057c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800624:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800627:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80062a:	e9 4d ff ff ff       	jmp    80057c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8d 78 04             	lea    0x4(%eax),%edi
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	53                   	push   %ebx
  800639:	ff 30                	pushl  (%eax)
  80063b:	ff d6                	call   *%esi
			break;
  80063d:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800640:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800643:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800646:	e9 fe fe ff ff       	jmp    800549 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8d 78 04             	lea    0x4(%eax),%edi
  800651:	8b 00                	mov    (%eax),%eax
  800653:	99                   	cltd   
  800654:	31 d0                	xor    %edx,%eax
  800656:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800658:	83 f8 08             	cmp    $0x8,%eax
  80065b:	7f 0b                	jg     800668 <vprintfmt+0x145>
  80065d:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  800664:	85 d2                	test   %edx,%edx
  800666:	75 1b                	jne    800683 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800668:	50                   	push   %eax
  800669:	68 96 10 80 00       	push   $0x801096
  80066e:	53                   	push   %ebx
  80066f:	56                   	push   %esi
  800670:	e8 91 fe ff ff       	call   800506 <printfmt>
  800675:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800678:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80067e:	e9 c6 fe ff ff       	jmp    800549 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800683:	52                   	push   %edx
  800684:	68 9f 10 80 00       	push   $0x80109f
  800689:	53                   	push   %ebx
  80068a:	56                   	push   %esi
  80068b:	e8 76 fe ff ff       	call   800506 <printfmt>
  800690:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800693:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800696:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800699:	e9 ab fe ff ff       	jmp    800549 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	83 c0 04             	add    $0x4,%eax
  8006a4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8006ac:	85 ff                	test   %edi,%edi
  8006ae:	b8 8f 10 80 00       	mov    $0x80108f,%eax
  8006b3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ba:	0f 8e 94 00 00 00    	jle    800754 <vprintfmt+0x231>
  8006c0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c4:	0f 84 98 00 00 00    	je     800762 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	ff 75 d0             	pushl  -0x30(%ebp)
  8006d0:	57                   	push   %edi
  8006d1:	e8 33 03 00 00       	call   800a09 <strnlen>
  8006d6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006d9:	29 c1                	sub    %eax,%ecx
  8006db:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006de:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006e8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006eb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ed:	eb 0f                	jmp    8006fe <vprintfmt+0x1db>
					putch(padc, putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	53                   	push   %ebx
  8006f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8006f6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f8:	83 ef 01             	sub    $0x1,%edi
  8006fb:	83 c4 10             	add    $0x10,%esp
  8006fe:	85 ff                	test   %edi,%edi
  800700:	7f ed                	jg     8006ef <vprintfmt+0x1cc>
  800702:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800705:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800708:	85 c9                	test   %ecx,%ecx
  80070a:	b8 00 00 00 00       	mov    $0x0,%eax
  80070f:	0f 49 c1             	cmovns %ecx,%eax
  800712:	29 c1                	sub    %eax,%ecx
  800714:	89 75 08             	mov    %esi,0x8(%ebp)
  800717:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80071d:	89 cb                	mov    %ecx,%ebx
  80071f:	eb 4d                	jmp    80076e <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800721:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800725:	74 1b                	je     800742 <vprintfmt+0x21f>
  800727:	0f be c0             	movsbl %al,%eax
  80072a:	83 e8 20             	sub    $0x20,%eax
  80072d:	83 f8 5e             	cmp    $0x5e,%eax
  800730:	76 10                	jbe    800742 <vprintfmt+0x21f>
					putch('?', putdat);
  800732:	83 ec 08             	sub    $0x8,%esp
  800735:	ff 75 0c             	pushl  0xc(%ebp)
  800738:	6a 3f                	push   $0x3f
  80073a:	ff 55 08             	call   *0x8(%ebp)
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	eb 0d                	jmp    80074f <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	ff 75 0c             	pushl  0xc(%ebp)
  800748:	52                   	push   %edx
  800749:	ff 55 08             	call   *0x8(%ebp)
  80074c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80074f:	83 eb 01             	sub    $0x1,%ebx
  800752:	eb 1a                	jmp    80076e <vprintfmt+0x24b>
  800754:	89 75 08             	mov    %esi,0x8(%ebp)
  800757:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800760:	eb 0c                	jmp    80076e <vprintfmt+0x24b>
  800762:	89 75 08             	mov    %esi,0x8(%ebp)
  800765:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800768:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80076b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80076e:	83 c7 01             	add    $0x1,%edi
  800771:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800775:	0f be d0             	movsbl %al,%edx
  800778:	85 d2                	test   %edx,%edx
  80077a:	74 23                	je     80079f <vprintfmt+0x27c>
  80077c:	85 f6                	test   %esi,%esi
  80077e:	78 a1                	js     800721 <vprintfmt+0x1fe>
  800780:	83 ee 01             	sub    $0x1,%esi
  800783:	79 9c                	jns    800721 <vprintfmt+0x1fe>
  800785:	89 df                	mov    %ebx,%edi
  800787:	8b 75 08             	mov    0x8(%ebp),%esi
  80078a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80078d:	eb 18                	jmp    8007a7 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	53                   	push   %ebx
  800793:	6a 20                	push   $0x20
  800795:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800797:	83 ef 01             	sub    $0x1,%edi
  80079a:	83 c4 10             	add    $0x10,%esp
  80079d:	eb 08                	jmp    8007a7 <vprintfmt+0x284>
  80079f:	89 df                	mov    %ebx,%edi
  8007a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007a7:	85 ff                	test   %edi,%edi
  8007a9:	7f e4                	jg     80078f <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007ae:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b4:	e9 90 fd ff ff       	jmp    800549 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b9:	83 f9 01             	cmp    $0x1,%ecx
  8007bc:	7e 19                	jle    8007d7 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	8b 50 04             	mov    0x4(%eax),%edx
  8007c4:	8b 00                	mov    (%eax),%eax
  8007c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8d 40 08             	lea    0x8(%eax),%eax
  8007d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8007d5:	eb 38                	jmp    80080f <vprintfmt+0x2ec>
	else if (lflag)
  8007d7:	85 c9                	test   %ecx,%ecx
  8007d9:	74 1b                	je     8007f6 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8b 00                	mov    (%eax),%eax
  8007e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e3:	89 c1                	mov    %eax,%ecx
  8007e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ee:	8d 40 04             	lea    0x4(%eax),%eax
  8007f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f4:	eb 19                	jmp    80080f <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8b 00                	mov    (%eax),%eax
  8007fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fe:	89 c1                	mov    %eax,%ecx
  800800:	c1 f9 1f             	sar    $0x1f,%ecx
  800803:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8d 40 04             	lea    0x4(%eax),%eax
  80080c:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80080f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800812:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800815:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80081a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80081e:	0f 89 0e 01 00 00    	jns    800932 <vprintfmt+0x40f>
				putch('-', putdat);
  800824:	83 ec 08             	sub    $0x8,%esp
  800827:	53                   	push   %ebx
  800828:	6a 2d                	push   $0x2d
  80082a:	ff d6                	call   *%esi
				num = -(long long) num;
  80082c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80082f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800832:	f7 da                	neg    %edx
  800834:	83 d1 00             	adc    $0x0,%ecx
  800837:	f7 d9                	neg    %ecx
  800839:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80083c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800841:	e9 ec 00 00 00       	jmp    800932 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800846:	83 f9 01             	cmp    $0x1,%ecx
  800849:	7e 18                	jle    800863 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80084b:	8b 45 14             	mov    0x14(%ebp),%eax
  80084e:	8b 10                	mov    (%eax),%edx
  800850:	8b 48 04             	mov    0x4(%eax),%ecx
  800853:	8d 40 08             	lea    0x8(%eax),%eax
  800856:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800859:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085e:	e9 cf 00 00 00       	jmp    800932 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800863:	85 c9                	test   %ecx,%ecx
  800865:	74 1a                	je     800881 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800867:	8b 45 14             	mov    0x14(%ebp),%eax
  80086a:	8b 10                	mov    (%eax),%edx
  80086c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800871:	8d 40 04             	lea    0x4(%eax),%eax
  800874:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800877:	b8 0a 00 00 00       	mov    $0xa,%eax
  80087c:	e9 b1 00 00 00       	jmp    800932 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800881:	8b 45 14             	mov    0x14(%ebp),%eax
  800884:	8b 10                	mov    (%eax),%edx
  800886:	b9 00 00 00 00       	mov    $0x0,%ecx
  80088b:	8d 40 04             	lea    0x4(%eax),%eax
  80088e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800891:	b8 0a 00 00 00       	mov    $0xa,%eax
  800896:	e9 97 00 00 00       	jmp    800932 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80089b:	83 ec 08             	sub    $0x8,%esp
  80089e:	53                   	push   %ebx
  80089f:	6a 58                	push   $0x58
  8008a1:	ff d6                	call   *%esi
			putch('X', putdat);
  8008a3:	83 c4 08             	add    $0x8,%esp
  8008a6:	53                   	push   %ebx
  8008a7:	6a 58                	push   $0x58
  8008a9:	ff d6                	call   *%esi
			putch('X', putdat);
  8008ab:	83 c4 08             	add    $0x8,%esp
  8008ae:	53                   	push   %ebx
  8008af:	6a 58                	push   $0x58
  8008b1:	ff d6                	call   *%esi
			break;
  8008b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8008b9:	e9 8b fc ff ff       	jmp    800549 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	53                   	push   %ebx
  8008c2:	6a 30                	push   $0x30
  8008c4:	ff d6                	call   *%esi
			putch('x', putdat);
  8008c6:	83 c4 08             	add    $0x8,%esp
  8008c9:	53                   	push   %ebx
  8008ca:	6a 78                	push   $0x78
  8008cc:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d1:	8b 10                	mov    (%eax),%edx
  8008d3:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008d8:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008db:	8d 40 04             	lea    0x4(%eax),%eax
  8008de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008e6:	eb 4a                	jmp    800932 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008e8:	83 f9 01             	cmp    $0x1,%ecx
  8008eb:	7e 15                	jle    800902 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f0:	8b 10                	mov    (%eax),%edx
  8008f2:	8b 48 04             	mov    0x4(%eax),%ecx
  8008f5:	8d 40 08             	lea    0x8(%eax),%eax
  8008f8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008fb:	b8 10 00 00 00       	mov    $0x10,%eax
  800900:	eb 30                	jmp    800932 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800902:	85 c9                	test   %ecx,%ecx
  800904:	74 17                	je     80091d <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800906:	8b 45 14             	mov    0x14(%ebp),%eax
  800909:	8b 10                	mov    (%eax),%edx
  80090b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800910:	8d 40 04             	lea    0x4(%eax),%eax
  800913:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800916:	b8 10 00 00 00       	mov    $0x10,%eax
  80091b:	eb 15                	jmp    800932 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80091d:	8b 45 14             	mov    0x14(%ebp),%eax
  800920:	8b 10                	mov    (%eax),%edx
  800922:	b9 00 00 00 00       	mov    $0x0,%ecx
  800927:	8d 40 04             	lea    0x4(%eax),%eax
  80092a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80092d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800932:	83 ec 0c             	sub    $0xc,%esp
  800935:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800939:	57                   	push   %edi
  80093a:	ff 75 e0             	pushl  -0x20(%ebp)
  80093d:	50                   	push   %eax
  80093e:	51                   	push   %ecx
  80093f:	52                   	push   %edx
  800940:	89 da                	mov    %ebx,%edx
  800942:	89 f0                	mov    %esi,%eax
  800944:	e8 f1 fa ff ff       	call   80043a <printnum>
			break;
  800949:	83 c4 20             	add    $0x20,%esp
  80094c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80094f:	e9 f5 fb ff ff       	jmp    800549 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800954:	83 ec 08             	sub    $0x8,%esp
  800957:	53                   	push   %ebx
  800958:	52                   	push   %edx
  800959:	ff d6                	call   *%esi
			break;
  80095b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80095e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800961:	e9 e3 fb ff ff       	jmp    800549 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800966:	83 ec 08             	sub    $0x8,%esp
  800969:	53                   	push   %ebx
  80096a:	6a 25                	push   $0x25
  80096c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80096e:	83 c4 10             	add    $0x10,%esp
  800971:	eb 03                	jmp    800976 <vprintfmt+0x453>
  800973:	83 ef 01             	sub    $0x1,%edi
  800976:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80097a:	75 f7                	jne    800973 <vprintfmt+0x450>
  80097c:	e9 c8 fb ff ff       	jmp    800549 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800981:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800984:	5b                   	pop    %ebx
  800985:	5e                   	pop    %esi
  800986:	5f                   	pop    %edi
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	83 ec 18             	sub    $0x18,%esp
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800995:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800998:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80099c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80099f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009a6:	85 c0                	test   %eax,%eax
  8009a8:	74 26                	je     8009d0 <vsnprintf+0x47>
  8009aa:	85 d2                	test   %edx,%edx
  8009ac:	7e 22                	jle    8009d0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009ae:	ff 75 14             	pushl  0x14(%ebp)
  8009b1:	ff 75 10             	pushl  0x10(%ebp)
  8009b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b7:	50                   	push   %eax
  8009b8:	68 e9 04 80 00       	push   $0x8004e9
  8009bd:	e8 61 fb ff ff       	call   800523 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009c5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009cb:	83 c4 10             	add    $0x10,%esp
  8009ce:	eb 05                	jmp    8009d5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    

008009d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e0:	50                   	push   %eax
  8009e1:	ff 75 10             	pushl  0x10(%ebp)
  8009e4:	ff 75 0c             	pushl  0xc(%ebp)
  8009e7:	ff 75 08             	pushl  0x8(%ebp)
  8009ea:	e8 9a ff ff ff       	call   800989 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ef:	c9                   	leave  
  8009f0:	c3                   	ret    

008009f1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fc:	eb 03                	jmp    800a01 <strlen+0x10>
		n++;
  8009fe:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a01:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a05:	75 f7                	jne    8009fe <strlen+0xd>
		n++;
	return n;
}
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a12:	ba 00 00 00 00       	mov    $0x0,%edx
  800a17:	eb 03                	jmp    800a1c <strnlen+0x13>
		n++;
  800a19:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a1c:	39 c2                	cmp    %eax,%edx
  800a1e:	74 08                	je     800a28 <strnlen+0x1f>
  800a20:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a24:	75 f3                	jne    800a19 <strnlen+0x10>
  800a26:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	53                   	push   %ebx
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a34:	89 c2                	mov    %eax,%edx
  800a36:	83 c2 01             	add    $0x1,%edx
  800a39:	83 c1 01             	add    $0x1,%ecx
  800a3c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a40:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a43:	84 db                	test   %bl,%bl
  800a45:	75 ef                	jne    800a36 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a47:	5b                   	pop    %ebx
  800a48:	5d                   	pop    %ebp
  800a49:	c3                   	ret    

00800a4a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	53                   	push   %ebx
  800a4e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a51:	53                   	push   %ebx
  800a52:	e8 9a ff ff ff       	call   8009f1 <strlen>
  800a57:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a5a:	ff 75 0c             	pushl  0xc(%ebp)
  800a5d:	01 d8                	add    %ebx,%eax
  800a5f:	50                   	push   %eax
  800a60:	e8 c5 ff ff ff       	call   800a2a <strcpy>
	return dst;
}
  800a65:	89 d8                	mov    %ebx,%eax
  800a67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	8b 75 08             	mov    0x8(%ebp),%esi
  800a74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a77:	89 f3                	mov    %esi,%ebx
  800a79:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a7c:	89 f2                	mov    %esi,%edx
  800a7e:	eb 0f                	jmp    800a8f <strncpy+0x23>
		*dst++ = *src;
  800a80:	83 c2 01             	add    $0x1,%edx
  800a83:	0f b6 01             	movzbl (%ecx),%eax
  800a86:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a89:	80 39 01             	cmpb   $0x1,(%ecx)
  800a8c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a8f:	39 da                	cmp    %ebx,%edx
  800a91:	75 ed                	jne    800a80 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a93:	89 f0                	mov    %esi,%eax
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
  800a9e:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa4:	8b 55 10             	mov    0x10(%ebp),%edx
  800aa7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa9:	85 d2                	test   %edx,%edx
  800aab:	74 21                	je     800ace <strlcpy+0x35>
  800aad:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ab1:	89 f2                	mov    %esi,%edx
  800ab3:	eb 09                	jmp    800abe <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ab5:	83 c2 01             	add    $0x1,%edx
  800ab8:	83 c1 01             	add    $0x1,%ecx
  800abb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800abe:	39 c2                	cmp    %eax,%edx
  800ac0:	74 09                	je     800acb <strlcpy+0x32>
  800ac2:	0f b6 19             	movzbl (%ecx),%ebx
  800ac5:	84 db                	test   %bl,%bl
  800ac7:	75 ec                	jne    800ab5 <strlcpy+0x1c>
  800ac9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800acb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ace:	29 f0                	sub    %esi,%eax
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ada:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800add:	eb 06                	jmp    800ae5 <strcmp+0x11>
		p++, q++;
  800adf:	83 c1 01             	add    $0x1,%ecx
  800ae2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ae5:	0f b6 01             	movzbl (%ecx),%eax
  800ae8:	84 c0                	test   %al,%al
  800aea:	74 04                	je     800af0 <strcmp+0x1c>
  800aec:	3a 02                	cmp    (%edx),%al
  800aee:	74 ef                	je     800adf <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af0:	0f b6 c0             	movzbl %al,%eax
  800af3:	0f b6 12             	movzbl (%edx),%edx
  800af6:	29 d0                	sub    %edx,%eax
}
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	53                   	push   %ebx
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b04:	89 c3                	mov    %eax,%ebx
  800b06:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b09:	eb 06                	jmp    800b11 <strncmp+0x17>
		n--, p++, q++;
  800b0b:	83 c0 01             	add    $0x1,%eax
  800b0e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b11:	39 d8                	cmp    %ebx,%eax
  800b13:	74 15                	je     800b2a <strncmp+0x30>
  800b15:	0f b6 08             	movzbl (%eax),%ecx
  800b18:	84 c9                	test   %cl,%cl
  800b1a:	74 04                	je     800b20 <strncmp+0x26>
  800b1c:	3a 0a                	cmp    (%edx),%cl
  800b1e:	74 eb                	je     800b0b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b20:	0f b6 00             	movzbl (%eax),%eax
  800b23:	0f b6 12             	movzbl (%edx),%edx
  800b26:	29 d0                	sub    %edx,%eax
  800b28:	eb 05                	jmp    800b2f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b2a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b3c:	eb 07                	jmp    800b45 <strchr+0x13>
		if (*s == c)
  800b3e:	38 ca                	cmp    %cl,%dl
  800b40:	74 0f                	je     800b51 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b42:	83 c0 01             	add    $0x1,%eax
  800b45:	0f b6 10             	movzbl (%eax),%edx
  800b48:	84 d2                	test   %dl,%dl
  800b4a:	75 f2                	jne    800b3e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	8b 45 08             	mov    0x8(%ebp),%eax
  800b59:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b5d:	eb 03                	jmp    800b62 <strfind+0xf>
  800b5f:	83 c0 01             	add    $0x1,%eax
  800b62:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b65:	38 ca                	cmp    %cl,%dl
  800b67:	74 04                	je     800b6d <strfind+0x1a>
  800b69:	84 d2                	test   %dl,%dl
  800b6b:	75 f2                	jne    800b5f <strfind+0xc>
			break;
	return (char *) s;
}
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	57                   	push   %edi
  800b73:	56                   	push   %esi
  800b74:	53                   	push   %ebx
  800b75:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b78:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b7b:	85 c9                	test   %ecx,%ecx
  800b7d:	74 36                	je     800bb5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b85:	75 28                	jne    800baf <memset+0x40>
  800b87:	f6 c1 03             	test   $0x3,%cl
  800b8a:	75 23                	jne    800baf <memset+0x40>
		c &= 0xFF;
  800b8c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b90:	89 d3                	mov    %edx,%ebx
  800b92:	c1 e3 08             	shl    $0x8,%ebx
  800b95:	89 d6                	mov    %edx,%esi
  800b97:	c1 e6 18             	shl    $0x18,%esi
  800b9a:	89 d0                	mov    %edx,%eax
  800b9c:	c1 e0 10             	shl    $0x10,%eax
  800b9f:	09 f0                	or     %esi,%eax
  800ba1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ba3:	89 d8                	mov    %ebx,%eax
  800ba5:	09 d0                	or     %edx,%eax
  800ba7:	c1 e9 02             	shr    $0x2,%ecx
  800baa:	fc                   	cld    
  800bab:	f3 ab                	rep stos %eax,%es:(%edi)
  800bad:	eb 06                	jmp    800bb5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800baf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb2:	fc                   	cld    
  800bb3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bb5:	89 f8                	mov    %edi,%eax
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bca:	39 c6                	cmp    %eax,%esi
  800bcc:	73 35                	jae    800c03 <memmove+0x47>
  800bce:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bd1:	39 d0                	cmp    %edx,%eax
  800bd3:	73 2e                	jae    800c03 <memmove+0x47>
		s += n;
		d += n;
  800bd5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	09 fe                	or     %edi,%esi
  800bdc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800be2:	75 13                	jne    800bf7 <memmove+0x3b>
  800be4:	f6 c1 03             	test   $0x3,%cl
  800be7:	75 0e                	jne    800bf7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800be9:	83 ef 04             	sub    $0x4,%edi
  800bec:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bef:	c1 e9 02             	shr    $0x2,%ecx
  800bf2:	fd                   	std    
  800bf3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf5:	eb 09                	jmp    800c00 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bf7:	83 ef 01             	sub    $0x1,%edi
  800bfa:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bfd:	fd                   	std    
  800bfe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c00:	fc                   	cld    
  800c01:	eb 1d                	jmp    800c20 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c03:	89 f2                	mov    %esi,%edx
  800c05:	09 c2                	or     %eax,%edx
  800c07:	f6 c2 03             	test   $0x3,%dl
  800c0a:	75 0f                	jne    800c1b <memmove+0x5f>
  800c0c:	f6 c1 03             	test   $0x3,%cl
  800c0f:	75 0a                	jne    800c1b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800c11:	c1 e9 02             	shr    $0x2,%ecx
  800c14:	89 c7                	mov    %eax,%edi
  800c16:	fc                   	cld    
  800c17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c19:	eb 05                	jmp    800c20 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c1b:	89 c7                	mov    %eax,%edi
  800c1d:	fc                   	cld    
  800c1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c27:	ff 75 10             	pushl  0x10(%ebp)
  800c2a:	ff 75 0c             	pushl  0xc(%ebp)
  800c2d:	ff 75 08             	pushl  0x8(%ebp)
  800c30:	e8 87 ff ff ff       	call   800bbc <memmove>
}
  800c35:	c9                   	leave  
  800c36:	c3                   	ret    

00800c37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c42:	89 c6                	mov    %eax,%esi
  800c44:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c47:	eb 1a                	jmp    800c63 <memcmp+0x2c>
		if (*s1 != *s2)
  800c49:	0f b6 08             	movzbl (%eax),%ecx
  800c4c:	0f b6 1a             	movzbl (%edx),%ebx
  800c4f:	38 d9                	cmp    %bl,%cl
  800c51:	74 0a                	je     800c5d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c53:	0f b6 c1             	movzbl %cl,%eax
  800c56:	0f b6 db             	movzbl %bl,%ebx
  800c59:	29 d8                	sub    %ebx,%eax
  800c5b:	eb 0f                	jmp    800c6c <memcmp+0x35>
		s1++, s2++;
  800c5d:	83 c0 01             	add    $0x1,%eax
  800c60:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c63:	39 f0                	cmp    %esi,%eax
  800c65:	75 e2                	jne    800c49 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c6c:	5b                   	pop    %ebx
  800c6d:	5e                   	pop    %esi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	53                   	push   %ebx
  800c74:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c77:	89 c1                	mov    %eax,%ecx
  800c79:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c7c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c80:	eb 0a                	jmp    800c8c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c82:	0f b6 10             	movzbl (%eax),%edx
  800c85:	39 da                	cmp    %ebx,%edx
  800c87:	74 07                	je     800c90 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c89:	83 c0 01             	add    $0x1,%eax
  800c8c:	39 c8                	cmp    %ecx,%eax
  800c8e:	72 f2                	jb     800c82 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c90:	5b                   	pop    %ebx
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9f:	eb 03                	jmp    800ca4 <strtol+0x11>
		s++;
  800ca1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca4:	0f b6 01             	movzbl (%ecx),%eax
  800ca7:	3c 20                	cmp    $0x20,%al
  800ca9:	74 f6                	je     800ca1 <strtol+0xe>
  800cab:	3c 09                	cmp    $0x9,%al
  800cad:	74 f2                	je     800ca1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800caf:	3c 2b                	cmp    $0x2b,%al
  800cb1:	75 0a                	jne    800cbd <strtol+0x2a>
		s++;
  800cb3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cbb:	eb 11                	jmp    800cce <strtol+0x3b>
  800cbd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cc2:	3c 2d                	cmp    $0x2d,%al
  800cc4:	75 08                	jne    800cce <strtol+0x3b>
		s++, neg = 1;
  800cc6:	83 c1 01             	add    $0x1,%ecx
  800cc9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cce:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cd4:	75 15                	jne    800ceb <strtol+0x58>
  800cd6:	80 39 30             	cmpb   $0x30,(%ecx)
  800cd9:	75 10                	jne    800ceb <strtol+0x58>
  800cdb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cdf:	75 7c                	jne    800d5d <strtol+0xca>
		s += 2, base = 16;
  800ce1:	83 c1 02             	add    $0x2,%ecx
  800ce4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce9:	eb 16                	jmp    800d01 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ceb:	85 db                	test   %ebx,%ebx
  800ced:	75 12                	jne    800d01 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cef:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cf4:	80 39 30             	cmpb   $0x30,(%ecx)
  800cf7:	75 08                	jne    800d01 <strtol+0x6e>
		s++, base = 8;
  800cf9:	83 c1 01             	add    $0x1,%ecx
  800cfc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d09:	0f b6 11             	movzbl (%ecx),%edx
  800d0c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d0f:	89 f3                	mov    %esi,%ebx
  800d11:	80 fb 09             	cmp    $0x9,%bl
  800d14:	77 08                	ja     800d1e <strtol+0x8b>
			dig = *s - '0';
  800d16:	0f be d2             	movsbl %dl,%edx
  800d19:	83 ea 30             	sub    $0x30,%edx
  800d1c:	eb 22                	jmp    800d40 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800d1e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d21:	89 f3                	mov    %esi,%ebx
  800d23:	80 fb 19             	cmp    $0x19,%bl
  800d26:	77 08                	ja     800d30 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800d28:	0f be d2             	movsbl %dl,%edx
  800d2b:	83 ea 57             	sub    $0x57,%edx
  800d2e:	eb 10                	jmp    800d40 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800d30:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d33:	89 f3                	mov    %esi,%ebx
  800d35:	80 fb 19             	cmp    $0x19,%bl
  800d38:	77 16                	ja     800d50 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800d3a:	0f be d2             	movsbl %dl,%edx
  800d3d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d40:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d43:	7d 0b                	jge    800d50 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d45:	83 c1 01             	add    $0x1,%ecx
  800d48:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d4c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d4e:	eb b9                	jmp    800d09 <strtol+0x76>

	if (endptr)
  800d50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d54:	74 0d                	je     800d63 <strtol+0xd0>
		*endptr = (char *) s;
  800d56:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d59:	89 0e                	mov    %ecx,(%esi)
  800d5b:	eb 06                	jmp    800d63 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d5d:	85 db                	test   %ebx,%ebx
  800d5f:	74 98                	je     800cf9 <strtol+0x66>
  800d61:	eb 9e                	jmp    800d01 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d63:	89 c2                	mov    %eax,%edx
  800d65:	f7 da                	neg    %edx
  800d67:	85 ff                	test   %edi,%edi
  800d69:	0f 45 c2             	cmovne %edx,%eax
}
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    
  800d71:	66 90                	xchg   %ax,%ax
  800d73:	66 90                	xchg   %ax,%ax
  800d75:	66 90                	xchg   %ax,%ax
  800d77:	66 90                	xchg   %ax,%ax
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
