section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 10, 0	; format string


section .bss			; we define (global) uninitialized variables in .bss section
	an: resb 12		; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]

section .data
	sum: dd 0
	counter: db 0
	len: dd 0
	number: dd 0
	tempeax: dd 0
	tempebx: dd 0


section .text
	global convertor
	extern printf

convertor:
	push ebp
	mov ebp, esp	
	pushad			

	mov ecx, dword [ebp+8]	; get function argument (pointer to string)

	jmp StringToInt
	endConvertion:
	jmp IntToStringHex
	end:

	mov [ebx], byte 0x00

	jmp Swap
	endSwap:
	push an			; call printf with 2 arguments -  
	push format_string	; pointer to str and pointer to format string
	call printf
	add esp, 8		; clean up stack after call
	
	popad			
	mov esp, ebp	
	pop ebp
	ret

Size:
	;string in ecx
	SizeLoop:
	cmp [ecx], byte 0
	jz endSize
	cmp [ecx], byte 10	
	jz endSize
	add [len], dword 1
	inc ecx	
	
	jmp SizeLoop

StringToInt:
	jmp Size
	endSize:

	mov eax, dword 1
	mov dl, byte 10

loop:
	dec ecx					;go to next char
	mov dh, byte [counter]
	cmp dh, byte [len]
	je endConvertion

	mov dl, byte [ecx]
	sub dl, byte 0x30 

	mov [tempeax], dword eax
	movzx edx, dl
	mul edx
	mov [sum], dword eax
	mov eax, dword [tempeax]
	
	mov ebx, dword[sum]
	add [number] ,ebx 		;decimal multiply power amout
	

	mov dl, byte[counter] ; counter ++
	add dl, byte 1
	mov [counter], byte dl

	mov dl, byte 10	; base = 10

	
	mov [sum], dword 0	
	mov [tempeax], dword eax
	movzx edx, dl
	mul edx
	mov [sum], dword eax
	mov eax, dword [tempeax]
	mov eax, dword [sum]
	jmp loop	
	

IntToStringHex:
	mov ebx, dword 0
	add ebx, an
    	whileIntToHex:

		cmp [number] , dword 0  		;if number is zero jump to finish
		jle end
		mov eax, dword [number]

		mov [tempebx], dword ebx
		mov ebx, dword 16
		mov edx, dword 0
		div dword ebx
		mov ebx, dword [tempebx]
	
		cmp edx, dword 9
		jle doItHexNumber
		sub edx, dword 9
		add edx, dword 0x40
		jmp isHexa

		doItHexNumber:
		add edx, dword 0x30
		jmp isHexa

		isHexa:
		mov [ebx], edx 	;insert value of modulo to string
		inc ebx


		mov [number], dword eax		;divide number by 16
		jmp whileIntToHex

Swap:
		mov ebx,an
		mov eax,an
		lastDigit:;put in ebx the last char adrres
		cmp [ebx], byte 0
		je step 
		inc ebx
		jmp lastDigit
		step:	
		dec ebx
	swapLoop:
		cmp eax,ebx
		jg endSwap
		mov cl,[ebx]
		mov dl, [eax]
		mov [ebx], byte dl
		mov [eax], byte cl
		dec ebx
		inc eax
		jmp swapLoop