section	.rodata			; we define (global) read-only variables in .rodata section
	format_int: dd `%d  \n`,10 ,0

section .data
	an: dd 0          
	x:dd 0	
	y:dd 0

section .text                    	
        global assFunc
	extern c_checkValidity 
	extern printf

assFunc:
	
	push ebp
	mov ebp,esp
	pushad

	mov ecx, [ebp+8]
	mov [x], dword ecx
	mov edx, [ebp+12]	
	mov [y], dword edx

	mov ecx,dword[x]
	mov [an],dword ecx


	push dword ecx
	push dword edx


	call c_checkValidity

	add esp, 8

	mov ecx, dword [x]

	cmp eax, dword 0x31
	
	jne sub

	add ecx , [y]
	mov [an],dword ecx
	jmp print
	
sub:		
	sub ecx, dword [y]
	mov [an],dword ecx
	jmp print
	
print:
	mov edx, dword [an]
	push edx
	push format_int
	call printf
	add esp,8
			

	popad
	mov esp,ebp
	pop ebp
	ret
