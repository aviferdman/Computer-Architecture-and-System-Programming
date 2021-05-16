
section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 0	; format string
	format_int: db "%x", 0	; format strings
	format_float: db "%f",10,0
	winner_massage: db "Drone id %d: I am the winner",10,0 ; drone winner 


section .bss
	
	SPT: resd 1 ;temporary stack pointer
	SPMAIN: resd 1 ;stack pointer of main
	STKSZ equ 16*1024 ;co-routine stack size
	CODEP equ 0
	SPP equ 4
	MALLOC_POINTER equ 8
	X_OFFSET equ 0
	Y_OFFSET equ 4
	ALPHA_OFFSET equ 8
	POINTS_OFFSET equ 12
	ACTIVE_OFFSET equ 16
	SPEED_OFFSET equ 20
	DRONES_STATS_OFFSET equ 24
	DRONES_OFFSET equ 12
section .data
	extern droneFunc
	extern printerFunc
	extern schedulerFunc
	extern targetFunc
	extern target_x
	extern target_y
	global scheduler
	global target
	global printer
	global drones
	global drones_structure
	global droneID
	global activeDrones
	global random
	global N
	global R
	global K
	global d
	global seed
	global resume
	global end_game
	global CURR
	CURR: dd 0
	newline: db 0xA,0x00
	tempreg: dd 0
	stackCurSizeBytes: dd 0
	activeDrones: dd 0
	scheduler: dd 0
	target: dd 0
	printer: dd 0
	drones: dd 0
	N: dd 0
	R: dd 0
	K: dd 0
	d: dd 0
	seed: dd 0
	drones_structure: dd 0
	droneID: dd 0
	random: dd 0
	mul: dd 0


section .text

  align 16
  global main
  extern printf
  extern fprintf 
  extern fflush
  extern malloc 
  extern calloc 
  extern free 
  extern sscanf
  


%macro startmain 0
	push ebp
	mov ebp, esp
%endmacro

%macro endMain 0
	free_memory
	mov esp,ebp
	pop ebp
	ret	
%endmacro

%macro create_target 0
	pushad
	random seed ,0 ,100
	mov eax, [random]
	mov [target_x], dword eax
	random seed ,0 ,100
	mov eax, [random]
	mov [target_y], dword eax
	popad
%endmacro

%macro init 3
	mov edx, [ebp+12]
	mov ecx, %1
	mov eax,[edx+ecx]	; get function argument
	push dword %2
	push dword %3
	push eax 
	call sscanf 
	add esp, 12 
	mov eax, 0 
%endmacro

%macro printInt 1
	push %1			  
	push format_int	
	call printf
	add esp, 8		
%endmacro

%macro printString 1
	push %1			  
	push format_string	
	call printf
	add esp, 8		
%endmacro

%macro free_stacks 0
	pushad
	mov edx, [printer]
	mov eax, [edx+MALLOC_POINTER]
	push eax
	call free
	add esp, 4

	mov edx, [scheduler]
	mov eax, [edx+MALLOC_POINTER]
	push eax
	call free
	add esp, 4

	mov edx, [target]
	mov eax, [edx+MALLOC_POINTER]
	push eax
	call free
	add esp, 4

	mov ecx, dword 0
	%%free_loop:
		cmp ecx, dword [N]
		je %%finish_free_loop
		mov [tempreg], dword ecx
		mov edx, [drones]
		mov edi, ecx
		myMult edi, DRONES_OFFSET
		mov edi, [mul]
		mov eax, [edx+edi+MALLOC_POINTER]
		push eax
		call free
		add esp, 4
		mov ecx, [tempreg]
		inc dword ecx
		jmp	%%free_loop
	%%finish_free_loop:

	popad

%endmacro


%macro free_memory 0
	pushad
	free_stacks

	mov eax, [scheduler]
	push eax
	call free
	add esp, 4

	mov eax, [drones_structure]
	push eax
	call free
	add esp, 4

	popad
%endmacro

%macro initializePointersToCorutines 0 ;initialize a stack with pointers to co-routines
	pushad							   ;the number to allocate is 3 + number of active drones
	add [activeDrones], dword 3	;active drones + scheduler + printer + target
	myMult 12, [activeDrones]
	sub [activeDrones], dword 3
	mov eax, [mul]
	push eax
	call malloc
	add esp, 4
	mov [scheduler], dword eax
	add eax, dword 12
	mov [target], dword eax
	add eax, dword 12
	mov [printer], dword eax
	add eax, dword 12
	mov [drones], dword eax
	myMult 4, [activeDrones]
	mov eax, [mul]
	mov [stackCurSizeBytes], eax
	popad
%endmacro

%macro initializeCo_Routines 0
	pushad
	mov ecx, dword 0
	%%initializeCo_RoutinesLoop:
		cmp ecx, dword [activeDrones]
		je %%finishInitDrones
			mov [tempreg], dword ecx
			mov eax, dword STKSZ
			push eax
			call malloc
			add esp, 4
			mov edx, [drones]
			mov ecx, [tempreg]
			mov edi, ecx
			myMult edi, DRONES_OFFSET
			mov edi, [mul]
			mov [edx+edi+MALLOC_POINTER], dword eax
			add eax, dword STKSZ
			mov [edx+edi+SPP], dword eax
			mov [edx+edi+CODEP], dword droneFunc
			inc dword ecx
			jmp %%initializeCo_RoutinesLoop
	%%finishInitDrones:
	%%init_printer: 
		mov eax, dword STKSZ
		push eax
		call malloc
		add esp, 4
		mov edx, [printer]
		mov [edx+MALLOC_POINTER], dword eax
		add eax, dword STKSZ
		mov [edx+SPP], dword eax
		mov [edx+CODEP], dword printerFunc
		
	%%init_target:
		mov eax, dword STKSZ
		push eax
		call malloc
		add esp, 4
		mov edx, [target]
		mov [edx+MALLOC_POINTER], dword eax
		add eax, dword STKSZ
		mov [edx+SPP], dword eax
		mov [edx+CODEP], dword targetFunc
		
	%%init_scheduler:
		mov eax, dword STKSZ
		push eax
		call malloc
		add esp, 4
		mov edx, [scheduler]
		mov [edx+MALLOC_POINTER], dword eax
		add eax, dword STKSZ
		mov [edx+SPP], dword eax
		mov [edx+CODEP], dword schedulerFunc
		
	popad
%endmacro

%macro init_drones_structure 0
	pushad
	mov ebx, DRONES_STATS_OFFSET
	myMult ebx, [N]
	mov eax, [mul]
	push eax
	call malloc
	add esp, 4
	mov [drones_structure], dword eax
	popad
%endmacro

%macro init_single_co_drone 1
	pushad	
	mov ebx, %1
	mov edx, [drones]
	mov edi, ebx
	myMult edi, DRONES_OFFSET
	mov edi, [mul]
	mov eax, dword [edi + edx + CODEP]
	mov ebx, dword [edi + edx + SPP]
	mov [SPT], dword esp 
	mov esp, ebx 
	push eax 
	pushfd
	pushad 

	mov edx, %1	;ebx = DRONES_OFFSET * ebx + drones + SPP -> save esp to [SPP]
	myMult DRONES_OFFSET, edx
	mov eax, [mul]
	mov ebx, eax
	add ebx, [drones] 
	add ebx, SPP 
	mov [ebx], dword esp 

	mov esp, dword [SPT]
	popad
%endmacro

%macro init_single_co_target 0
	pushad	
	mov edx, [target]
	mov eax, [edx + CODEP]
	mov ebx, [edx + SPP]
	mov [SPT], dword esp
	mov esp, ebx
	push eax 
	pushfd	
	pushad 

	mov ebx, dword [target] 
	add ebx, SPP 
	mov [ebx], dword esp 

	mov esp, dword [SPT]
	popad
%endmacro

%macro init_single_co_printer 0
	pushad	
	mov edx, [printer]
	mov eax, [edx + CODEP]
	mov ebx, [edx + SPP]
	mov [SPT], dword esp
	mov esp, ebx
	push eax 
	pushfd	
	pushad 

	mov ebx, dword [printer] 
	add ebx, SPP 
	mov [ebx], dword esp 

	mov esp, dword [SPT]
	popad
%endmacro

%macro init_single_co_scheduler 0
	pushad 
	mov edx, [scheduler] 
	mov eax, [edx + CODEP] 
	mov ebx, [edx + SPP] 
	mov [SPT], dword esp 
	mov esp, ebx 
	push eax 
	pushfd 
	pushad 

	mov ebx, dword [scheduler] 
	add ebx, SPP 
	mov [ebx], dword esp 

	mov esp, dword [SPT]
	popad
%endmacro

%macro myMult 2 ; mul 2 numbers until 256, result in eax

	pushad
		mov eax, dword 0
		mov ecx, dword %1
		mov edx, dword %2
		%%mulLoop:
			cmp ecx, dword 0
			je %%endMulLoop
			add eax, dword %2
			dec dword ecx
			jmp %%mulLoop
		%%endMulLoop:
		mov [mul], dword eax
	popad

%endmacro

%macro newLine 0; print new line
	push newline			  
	push format_string	
	call printf
	add esp, 8	
%endmacro

%macro initializeArguments 0
	pushad
	init 4, N, format_int
	init 8, R, format_int
	init 12, K, format_int
	init 16, d, format_float
	init 20, seed, format_int
	mov ebx, [N]
	mov [activeDrones], dword ebx
	popad
%endmacro

%macro initialize 0

	initializeArguments
	initializePointersToCorutines
	initializeCo_Routines
	mov ecx, dword [activeDrones] ;init active drones structure

	%%dronesSetter:
		dec ecx
		init_single_co_drone ecx

	cmp ecx, dword 1
	jge %%dronesSetter

	init_single_co_scheduler
	init_single_co_target
	init_single_co_printer

%endmacro

%macro random 3  ; seed, low, high
	pushad
	mov ebx, 0
	mov ax, 0
	mov bx, [%1]
	mov edx, 16
	%%shift:
		cmp edx, 0
		je %%end_shift
		mov ax, 45 ;000000001000101
		and ax, bx 
		jp %%zero
		shr bx, 1
		add bx, 32768 ;1000000000000000
		jmp %%end_adding
		%%zero:
			shr bx, 1
			jmp %%end_adding
		%%end_adding:
		dec dword edx
		jmp %%shift
	%%end_shift:
		finit
		mov [seed], dword ebx
		fild dword [seed]
		mov [tempreg], dword 65535
		fild dword [tempreg] ; 1111111111111111
		fdivp
		mov [tempreg], dword  %3
		sub [tempreg], dword %2
		fild dword [tempreg]
		fmulp
		mov [tempreg], dword %2
		fiadd dword [tempreg]
		mov [tempreg], dword 0
		fstp dword [tempreg]
		mov ebx, [tempreg]
		mov [random], dword ebx
		ffree
		popad

%endmacro

%macro makeRandomStats 0
	pushad
	mov edx, dword 0
	%%loopRandomStats:
		cmp edx, dword [N]
		jge %%endRandomStats

		myMult edx, DRONES_STATS_OFFSET
		mov eax, [mul]
		add eax, [drones_structure]
		mov ebx, eax
		add ebx, X_OFFSET

		random seed, 0, 100
		mov ecx, [random]
		;0x5657a230
		mov [ebx], dword ecx
		mov ebx, eax
		add ebx, Y_OFFSET
		random seed, 0, 100
		mov ecx, [random]
		mov [ebx], dword ecx

		mov ebx, eax
		add ebx, ALPHA_OFFSET
		random seed, 0, 360
		mov ecx, [random]
		mov [ebx], dword ecx

		mov ebx, eax
		add ebx, SPEED_OFFSET
		random seed, 0, 100
		mov ecx, [random]
		mov [ebx], dword ecx

		mov ebx, eax
		add ebx, ACTIVE_OFFSET
		mov [ebx], dword 1

		mov ebx, eax
		add ebx, POINTS_OFFSET
		mov [ebx], dword 0

		inc dword edx
		jmp %%loopRandomStats

	%%endRandomStats:
	popad

%endmacro

%macro print_float 1
	pushad
	mov eax, %1
	mov [tempreg], dword eax
	sub esp, dword 8
	finit
	fld dword [tempreg]
	fstp qword [esp]		  
	ffree
	push format_float	
	call printf
	add esp, 12
	popad
%endmacro
main:

	startmain
	initialize
	init_drones_structure
	makeRandomStats
	create_target

	jmp startCo
	end_game:
		push ebx
		push winner_massage
		call printf
		add esp, 8
		mov esp, [SPMAIN]
		popad
		mov ebx, [droneID]
	endMain

startCo:
	
	pushad	;saves main registers and esp
	mov [SPMAIN], dword esp
	popad
	mov ebx, dword [scheduler]
	jmp do_resume

resume:
	pushfd
	pushad
	mov edx, [CURR]
	mov [edx+SPP], esp

do_resume: 

	mov esp, ebx
	add esp, SPP
	mov esp, [esp]

	mov [CURR], dword ebx 
	popad
	popfd
	ret

