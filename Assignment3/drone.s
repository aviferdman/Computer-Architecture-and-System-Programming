%macro newLine 0; print new line
	push newline			  
	push format_string	
	call printf
	add esp, 8	
%endmacro

%macro mult 2 ; mul 2 numbers until 256, result in eax

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
		mov [mul2], dword eax
	popad

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

%macro fix_range 3 ;input: %1 = start, %2 = end, 3% = value output: fixed value in [result]
	pushad
	finit
	mov ecx, %3;float
	mov [result], dword ecx
	mov eax, %2;int
	sub eax, %1;int, eax contains the range
	mov [tempreg], dword ecx
	fld dword [tempreg]
	mov ecx, %2
	mov [tempreg], dword ecx
	fild dword [tempreg]
	fcomip
	ja %%end_fix_top
	mov [tempreg], dword eax
	fild dword [tempreg]
	fsubp
	fst dword [result]
	jmp %%end_fix

	%%end_fix_top:
	mov ecx, %1
	mov [tempreg], dword ecx
	fild dword [tempreg]
	fcomip
	jb %%end_fix_down
	mov [tempreg], dword eax
	fild dword [tempreg]
	faddp
	fst dword [result]
	%%end_fix_down:
	%%end_fix:
	ffree
	popad
%endmacro

%macro getMyStat 2	;%1 = offset of the stat, %2 has return
	pushad
	mov edx, [droneID]
	mult edx, DRONES_STATS_OFFSET
	mov eax, [mul2]
	add eax, [drones_structure]
	add eax, %1
	mov ebx, 0
	mov ebx, [eax]
	mov ecx, %2
	mov [ecx], dword ebx
	popad
%endmacro

%macro setMyStat 2	;%1 = offset of the stat, %2 value
	pushad
	mov edx, [droneID]
	mult edx, DRONES_STATS_OFFSET
	mov eax, [mul2]
	add eax, [drones_structure]
	add eax, %1
	mov ebx,0
	mov ecx, %2
	mov ebx, [ecx]
	mov [eax], dword ebx
	popad
%endmacro


section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 0	; format string
	format_int: db "%x", 0	; format strings

section .bss
	X_OFFSET equ 0
	Y_OFFSET equ 4
	ALPHA_OFFSET equ 8
	POINTS_OFFSET equ 12
	ACTIVE_OFFSET equ 16
	SPEED_OFFSET equ 20
	DRONES_STATS_OFFSET equ 24
	DRONES_OFFSET equ 12

section .data
	
	global droneFunc
	newline: db 0xA,0x00
	extern drones_structure
	extern N
	extern R
	extern K
	extern d
	extern seed
	extern drones_structure
	extern droneID
	extern random
	extern activeDrones
	extern resume
	extern scheduler
	extern target_x
	extern target_y
	extern target
	extern CURR
	result: dd 0
	positionX: dd 0
	positionY: dd 0
	angle: dd 0
	speed: dd 0
	score2: dd 0
	tempreg: dd 0
	distance: dd 0
	drone_ret: dd 0
	mul2: dd 0

section .text
	extern printf
droneFunc:
	mayDestroy:
		;calc: ((x1-x2)^2+(y1-y2)^2)^0.5
		finit
		fld dword [positionX]
		fld dword [target_x]
		fsubp
		fst st1
		fmulp
		fstp dword [tempreg]
		ffree
		fld dword [positionY]
		fld dword [target_y]
		fsubp
		fst st1
		fmulp
		fld dword [tempreg]
		faddp
		fsqrt
		fst dword [distance]
		ffree
		mov edx, [scheduler]
		mov [drone_ret], dword edx
		fld dword [distance]
		fld dword [d]
		fcomip 
		jb  end_destroy
		mov edx, [target]
		mov [drone_ret], dword edx

		getMyStat POINTS_OFFSET, score2
		inc dword [score2]
		setMyStat POINTS_OFFSET, score2
	end_destroy:

	getMyStat SPEED_OFFSET, speed
	getMyStat ALPHA_OFFSET, angle
	finit
	mov [tempreg], dword 180
	fild dword [tempreg]
	fldpi
	fdivp
	fld dword [angle]
	fmulp
	fcos
	fld dword [speed]
	fmulp
	fstp dword [positionX];(speed * cos alpha) + posX = new posX
	mov [tempreg], dword 180
	fild dword [tempreg]
	fldpi
	fdivp
	fld dword [angle]
	fmulp
	fsin
	fld dword [speed]
	fmulp
	fst dword [positionY];(speed * sin alpha) + posY = new posY
	ffree

	;fix position if needed to torus
	getMyStat X_OFFSET, tempreg
	finit 
	fld dword [tempreg]
	fld dword [positionX]
	faddp 
	fstp dword [positionX]
	ffree
	fix_range 0, 100, [positionX]
	mov eax, [result]
	mov [positionX], dword eax

	getMyStat Y_OFFSET, tempreg
	finit 
	fld dword [tempreg]
	fld dword [positionY]
	faddp 
	fstp dword [positionY]
	ffree
	fix_range 0, 100, [positionY]
	mov eax, [result]
	mov [positionY], dword eax

	setMyStat X_OFFSET, positionX 
	setMyStat Y_OFFSET, positionY

	random seed, -60, 60
	mov eax, [random]
	mov [angle], dword eax
	
	random seed, -10, 10
	mov eax, [random]
	mov [speed], dword eax

	;fix alpha if needed 0 - 360
	;fix speed if needed 0 - 100

	getMyStat ALPHA_OFFSET, tempreg
	finit 
	fld dword [tempreg]
	fld dword [angle]
	faddp 
	fstp dword [angle]
	ffree
	fix_range 0, 360, [angle]
	mov eax, [result]
	mov [angle], dword eax

	getMyStat SPEED_OFFSET, tempreg
	finit 
	fld dword [tempreg]
	fld dword [speed]
	faddp 
	fstp dword [speed]
	ffree
	fix_range 0, 100, [speed]
	mov eax, [result]
	mov [speed], dword eax


	setMyStat SPEED_OFFSET, speed 
	setMyStat ALPHA_OFFSET, angle
	
	mov ebx, [drone_ret]	;set next routine (target/scheduler)
	call resume
	jmp droneFunc