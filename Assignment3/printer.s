%macro newLine 0; print new line
	push newline			  
	push format_string	
	call printf
	add esp, 8	
%endmacro
section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 0	; format string
	format_int: db "%d",10, 0	; format strings
	format_float: db "%lf",10,0 
	format_print: db "%d, %.2f, %.2f, %.2f, %.2f, %d", 10, 0
	format_target: db "%.2f, %.2f", 10, 0

section .bss

section .data
	global printerFunc
	extern drones_structure
	X_OFFSET equ 0
	Y_OFFSET equ 4
	ALPHA_OFFSET equ 8
	POINTS_OFFSET equ 12
	ACTIVE_OFFSET equ 16
	SPEED_OFFSET equ 20
	DRONES_STATS_OFFSET equ 24
	DRONES_OFFSET equ 8
	extern N
	extern scheduler
	extern resume
	extern CURR
	extern target_x
	extern target_y
	index2: dd 0
	posX: dd 0
	posY: dd 0
	alpha: dd 0
	score: dd 0
	active: dd 0
	speed: dd 0
	newline: db 0xA,0x00
	tempreg: dd 0
	print_help: dd 0
section .text
	extern printf


%macro printerInt 1
	push %1			  
	push format_int	
	call printf
	add esp, 8		
%endmacro

%macro printerString 1
	push %1			  
	push format_string	
	call printf
	add esp, 8		
%endmacro


%macro printerFloat 1
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
	add esp, 8
	popad
%endmacro

%macro printDroneParams 6		
	;[score]
	mov eax, %6
	push eax
	;[speed]
	mov eax, %5
	mov [tempreg], dword eax
	finit
	fld dword [tempreg]
	sub esp, 8
	fst qword [esp]
	ffree
	;[alpha]
	mov eax, %4
	mov [tempreg], dword eax
	finit
	fld dword [tempreg]
	sub esp,8
	fst qword [esp]
	ffree
	;[posY]
	mov eax, %3
	mov [tempreg], dword eax
	finit
	fld dword [tempreg]
	sub esp,8
	fst qword [esp]
	ffree
	;[posX]
	mov eax, %2
	mov [tempreg], dword eax
	finit
	fld dword [tempreg]
	sub esp,8
	fst qword [esp]
	ffree
	;[index]
	mov eax, %1
	push eax

	push format_print
	call printf
	add esp, 40
	
%endmacro

printerFunc:
	mov [index2], dword 0
	mov eax, [drones_structure]
	mov [print_help], dword eax

	finit
	fld dword [target_x]
	fld dword [target_y]
	sub esp, 8
	fstp qword [esp]
	sub esp, 8
	fst qword [esp]
	ffree
	push format_target
	call printf
	add esp, 20
	printerLoop:
	mov ecx, [N]
	cmp dword [index2], ecx
	jge printerEnd
		mov edx, [print_help]
		add edx, X_OFFSET
		mov edx, [edx]
		mov [posX], dword edx

		mov edx, [print_help]
		add edx, Y_OFFSET
		mov edx, [edx]
		mov [posY], dword edx

		mov edx, [print_help]
		add edx, ALPHA_OFFSET
		mov edx, [edx]
	
		mov [alpha], dword edx

		mov edx, [print_help]
		add edx, POINTS_OFFSET
		mov edx, [edx]
		mov [score], dword edx

		mov edx, [print_help]
		add edx, ACTIVE_OFFSET
		mov edx, [edx]
		mov [active], dword edx

		mov edx, [print_help]
		add edx, SPEED_OFFSET
		mov edx, [edx]
		mov [speed], dword edx

		cmp [active], dword 1
		jne nextIter

		printDroneParams [index2], [posX], [posY], [alpha], [speed], [score]
		nextIter:

		add [print_help], dword DRONES_STATS_OFFSET
		inc dword [index2]
		
		jmp printerLoop
	
	printerEnd:
		newLine
		mov ebx, [scheduler]
		call resume
		jmp printerFunc

