%macro newLine 0; print new line
	push newline			  
	push format_string	
	call printf
	add esp, 8	
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
section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 0	; format string
	format_int: db "%x", 0	; format strings

section .bss

section .data
	extern drones_structure
	X_OFFSET equ 0
	Y_OFFSET equ 4
	ALPHA_OFFSET equ 8
	POINTS_OFFSET equ 12
	ACTIVE_OFFSET equ 16
	SPEED_OFFSET equ 20
	DRONES_STATS_OFFSET equ 24
	DRONES_OFFSET equ 8
	extern random
	extern seed
	extern scheduler
	extern resume
	extern CURR
	global targetFunc
	global target_x
	global target_y
	target_x: dd 0
	target_y: dd 0
	tempreg: dd 0
	newline: db 0xA,0x00


section .text
	extern printf

targetFunc:
	target_loop:
		jmp createTarget ;(*) call createTarget() function to create a new target with random coordinates on the game board
		endCreateTarget:
			mov ebx, [scheduler];(*) switch to the co-routine of the "current" drone by calling resume function
			call resume
			jmp target_loop

createTarget: ;The function createTarget() is as follows:

	random seed ,0 ,100
	mov eax, [random]
	mov [target_x], dword eax
	random seed ,0 ,100
	mov eax, [random]
	mov [target_y], dword eax
	jmp endCreateTarget