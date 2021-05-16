section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 0	; format string
	format_int: db "%d", 0	; format strings
section .bss

section .data
	DRONES_STATS_OFFSET equ 24
	DRONES_OFFSET equ 12
	X_OFFSET equ 0
	Y_OFFSET equ 4
	ALPHA_OFFSET equ 8
	POINTS_OFFSET equ 12
	ACTIVE_OFFSET equ 16
	SPEED_OFFSET equ 20
	extern printf
	extern end_game
	extern drones_structure
	extern activeDrones
	extern resume
	extern droneID
	extern drones
	extern printer
	extern CURR
	global schedulerFunc
	

	i: dd 0
	droneStep: dd 0
	modulo: dd 0
	div: dd 0
	droneFlag: dd 0
	loosingDroneID: dd 0
	loosingDronePoints: dd 0
	newline: db 0xA,0x00
	keeper: dd 0
	mul1: dd 0
	extern N
	extern R
	extern K
	extern d
	extern seed

section .text

%macro newLine 0; print new line
	push newline			  
	push format_string	
	call printf
	add esp, 8	
%endmacro

%macro modulo 2 ;get two parameters and do %1mod%2 the result in [modulo]
	pushad
	mov ebx, %1
	mov ecx, %2
	mov [modulo], dword 0
	
	%%moduloLoop:
		cmp ebx, ecx
		jl %%finishModulo
		sub ebx, ecx
		jmp %%moduloLoop
	%%finishModulo:
	mov [modulo], dword ebx
	popad
%endmacro

%macro divide 2 ;get two parameters and do %1/%2 the result in [div]
	pushad
	mov ebx, %1
	mov [div], dword 0
	
	%%divLoop:
		cmp ebx, dword %2
		jle %%finishDiv
		sub ebx, %2
		inc dword [div]
		jmp %%divLoop
	%%finishDiv:
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
		mov [mul1], dword eax
	popad

%endmacro
%macro nextID 1
	pushad
	;inc dword %1	
	mov eax, %1		;droneID = (droneID+1)mod(N)
	inc dword eax
	modulo eax, [N]
	mov ebx, [modulo]
	mov [droneID], dword ebx
	popad
%endmacro

%macro getDroneFlag 1	;gets droneID -> returns the flag of the drone
	pushad
	;mov ebx, [[drones_structure] + DRONES_STATS_OFFSET*ebx + ACTIVE_OFFSET]
	mov ebx, %1
	myMult DRONES_STATS_OFFSET, ebx
	mov eax, [mul1]
	mov ebx, [drones_structure]
	add ebx, eax
	add ebx, ACTIVE_OFFSET
	mov ebx, [ebx]
	mov [droneFlag], dword ebx
	popad
%endmacro

%macro findNextActiveDrone 1	;find next availabe drone, assume available flag is 1 -> return droneID
	pushad
	mov ebx, %1 ;the id of the current drone
	getDroneFlag ebx
	mov [droneID], dword ebx
	%%searchActive:
		cmp [droneFlag], dword 1
		je %%foundActive
		nextID [droneID]
		getDroneFlag [droneID]
		jmp %%searchActive
	%%foundActive:
	popad
	
%endmacro

%macro getLoosingDroneID 0
	
	;eax - the current drone flag 
	;ebx - the current link address
	;ecx - the current drone points
	;edx - the current drone id
	;keeper - stores the next droneID of the scheduler
	;

	pushad
	mov eax, [droneID]
	mov [keeper], dword eax 
	mov ebx, [drones_structure]
	mov ecx, ebx
	add ecx, POINTS_OFFSET
	mov eax, ebx
	add eax, ACTIVE_OFFSET
	mov ecx, [ecx]
	mov eax, [eax]

	mov edx, 0  
	mov [loosingDronePoints], dword 10000000 	;max points
	
	%%loosingLoop:
		cmp edx, dword [activeDrones]
		je %%endLoosingDrone
		cmp eax, dword 1 	;check if current drone is active
		jne %%nextIter	
		cmp ecx, dword [loosingDronePoints] 	;check if current drone has less points than the current minimum
		jg %%nextIter	
		mov [loosingDronePoints], dword ecx
		mov [loosingDroneID], dword edx
		%%nextIter:		;init the next parameters for the next drone
			add ebx, DRONES_STATS_OFFSET
			mov ecx, ebx
			add ecx, POINTS_OFFSET
			mov eax, ebx
			add eax, ACTIVE_OFFSET
			mov ecx, [ecx]
			mov eax, [eax]
			inc dword edx  
			jmp %%loosingLoop
	%%endLoosingDrone:
	;restore the next drone ID
	mov eax, [keeper]
	mov [droneID], dword eax 
	popad
%endmacro

%macro removeLosingDrone 0
	pushad 
	getLoosingDroneID 
	mov ebx, [loosingDroneID] ;ebx contains loosing drone ID
	myMult DRONES_STATS_OFFSET, ebx
	mov ecx, [mul1]	;ecx = drones_structure + DRONES_STATS_OFFSET*loosingDroneID + ACTIVE_OFFSET 
	add ecx, dword [drones_structure]
	add ecx, dword ACTIVE_OFFSET
	mov [ecx], dword 0
	dec dword [activeDrones]
	popad 
%endmacro

schedulerFunc:

	mov [i], dword 0
	cmp [activeDrones], dword 1
	je schedulerEnd
	schedulerLoop:

		modulo [i], [K]
		cmp [modulo], dword 0
		je needToPrint
		jmp endPrint
		needToPrint:
			mov ebx, dword [printer]
			call resume
		endPrint:

		myMult DRONES_OFFSET, [droneID]	;ebx = droneID * DRONES_OFFSET + drones 
		mov ecx, [mul1]
		mov ebx, dword [drones]
		add ebx, ecx
        call resume
		inc dword [i]
		inc dword [droneStep]
		modulo [droneStep], [activeDrones]
		mov ecx, [modulo]
		mov [droneStep], dword ecx

		roundOver:
			nextID [droneID]	;next legal drone ID
			findNextActiveDrone [droneID]	;find the next active drone from this id and advance the droneID

			cmp [droneStep], dword 0
			jne schedulerLoop
			mov [droneStep], dword 0
			removeLosingDrone
			cmp [activeDrones], dword 1
			je schedulerEnd		;check if only one drone left
			jmp schedulerLoop
	schedulerEnd:

		findNextActiveDrone 0
		jmp end_game