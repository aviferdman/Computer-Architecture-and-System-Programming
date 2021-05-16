
%macro startmain 0
	push ebp
	mov ebp,esp
	pushad
%endmacro

%macro endMain 0
	freeStackLists ;free remaining lists
	freeStack
	popad
	mov eax, [retval]
	mov esp,ebp
	pop ebp
	ret	
%endmacro

%macro freeStack 0
	%%freeStackLoop:
		cmp [stackCurSizeBytes], dword 0x00
		je %%endFreeStack
		mov edx, [stackPointer]	;edx has the top operand pointer
		add edx, [stackCurSizeBytes]
		;sub edx, 4
		push dword edx;free edx
		call free
		add esp, 4
		dec dword [stackCurSize] ; dec stack
		sub [stackCurSizeBytes], dword 4 ; dec stack
		jmp %%freeStackLoop
	%%endFreeStack:
		mov edx, [stackPointer]	;edx has the top operand pointer
		push dword edx;free edx
		call free
		add esp, 4
%endmacro

%macro freeList 1
	mov ecx, %1	;prev
	mov edx, %1	;current
	cmp edx, 0x00
	je %%endFreeList
	%%freeListLoop:
	getNext edx
	cmp [nextLink], dword 0x00
	je %%deleteLast
	mov ecx, edx
	mov edx, [nextLink]
	push dword ecx;free ecx
	call free
	add esp, 4
	mov edx, dword [nextLink]
	jmp %%freeListLoop
	%%deleteLast:
	push dword edx;free edx
	call free
	add esp,4
	%%endFreeList:
%endmacro

%macro freeStackLists 0
	%%freeStackListsLoop:
	mov ecx, [stackCurSize]
	cmp ecx, 0x00
	je %%freedAllLists
		mov edx, [stackPointer]	;edx has the top operand pointer
		add edx, [stackCurSizeBytes]
		sub edx, 4
		mov edx, [edx]
		dec dword [stackCurSize] ; dec stack
		sub [stackCurSizeBytes], dword 4 ; dec stack
		freeList dword edx
		jmp %%freeStackListsLoop
	%%freedAllLists:

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

%macro StringToInt 0
	mov [len], dword 0
	mov [number], dword 0
	mov [sum], dword 0
	mov [counter], dword 0
	mov [tempreg], dword 0
	jmp %%Size
	%%endSize:

	mov eax, dword 1
	mov dl, byte 16

%%loop:
	dec ecx					;go to next char
	mov dh, byte [counter]
	cmp dh, byte [len]
	je %%endConvertion

	mov dl, byte [ecx]
	cmp dl, 0x41
	jge %%treatLetter
	sub dl, byte 0x30
	jmp %%endLetter
	%%treatLetter:
	sub dl, 0x37 
	jmp %%endLetter

	%%endLetter:

	mov [tempreg], dword eax
	movzx edx, dl
	mul edx
	mov [sum], dword eax
	mov eax, dword [tempreg]
	
	mov ebx, dword[sum]
	add [number] ,ebx 		;decimal multiply power amout
	

	mov dl, byte[counter] ; counter ++
	add dl, byte 1
	mov [counter], byte dl

	mov dl, byte 16	; base = 16

	
	mov [sum], dword 0	
	mov [tempreg], dword eax
	movzx edx, dl
	mul edx
	mov [sum], dword eax
	mov eax, dword [tempreg]
	mov eax, dword [sum]
	jmp %%loop	

	%%Size:
	%%SizeLoop:
	cmp [ecx], byte 0
	jz %%endSize
	cmp [ecx], byte 10	
	jz %%endSize
	add [len], dword 1
	inc ecx	
	
	jmp %%SizeLoop

	%%endConvertion:

%endmacro

%macro addNewLink 1
	mov [add], %1
	push 5
	call malloc
	add esp, 4

	mov bl, [add]
	mov [eax], byte bl 
	mov edx, [firstLink]
	mov [eax+1], edx
	mov [firstLink], eax
	mov [add], byte 0

%endmacro


%macro getNext 1 ; get pointer to link and return pointer to next link
	mov eax, %1
	mov eax, [eax+1]
	mov [nextLink], eax
%endmacro

%macro pushLinkedList 0
	removeZeros ;remove zeroes from beginning of input
	mov edx, [firstLink]
	mov ecx, [stackPointer]
	add ecx, [stackCurSizeBytes]
	mov [ecx], edx
	inc dword [stackCurSize]
	add [stackCurSizeBytes], dword 4
%endmacro

%macro getLinkData 1 ; gets pointer to link and return its data (byte)
	mov ebx, %1
	mov ebx, [ebx]
	mov [data], dword ebx
%endmacro

%macro clearInput 0
	mov eax,0
	%%loop:
	cmp eax, 0x50
	je %%end
	mov [input + eax], byte 0x00
	inc eax
	jmp %%loop
	%%end:
%endmacro

%macro mult 2 ; mul 2 numbers until 256, result in eax
	mov bl, %1
	mov al, %2
	mul bl
	mov ecx,0
	mov cx, ax
	mov eax, ecx 
%endmacro

%macro newLine 0; print new line
	push newline			  
	push format_string	
	call printf
	add esp, 8	
%endmacro

%macro handleZero 1
	cmp %1, 0x30
	jne %%end
	mov dl, 0
	addNewLink dl
	inc dword [index]
	jmp endHandleZero
	%%end:
%endmacro

	%macro removeZeros 0
		mov edx, [firstLink];stand
		mov ecx, [firstLink];run
		%%removeZerosLoop:
			getNext ecx
			cmp [nextLink], dword 0x00
			je %%endZeroesLoop
			mov ecx, [nextLink]
			getLinkData ecx
			cmp [data], byte 0x00
			je %%removeZerosLoop ;eax = eax.next
			mov edx, ecx
			jmp %%removeZerosLoop
			%%endZeroesLoop:
			;[ebx+1] is the pointer to the link to free from it and on
			;push ebx
			mov [tempreg], dword edx
			freeList dword [edx+1]
			mov edx, [tempreg]
			mov [edx+1], dword 0x00
			
	%endmacro

%macro createLinkedList 0

	mov [index], dword 0
	mov [firstLink], dword 0

	%%createLinkListMainLoop:
		mov [byteNumber], dword 0
		mov ecx,0
		mov ebx,0
		mov ebx, [index]	;ebx = index
		mov cl, [input+ebx]

		handleZero cl

		add [byteNumber], dword ecx
		mov ecx, byteNumber

		StringToInt
		mov ecx, [number]

		cmp cl, 0x00	;check end of input
		je %%endCreate

		addNewLink cl	;add new link to the end of the linked list
		add [index], dword 1	;i = i + 2
		endHandleZero:
		jmp %%createLinkListMainLoop
		%%endCreate:
		clearInput
%endmacro

%macro rator 0
	mov edx, 0
	mov edx, [input]
	cmp edx, 0x2B	;+
	je ratorPlus
	cmp edx, 0x70	;p
	je ratorP
	cmp edx, 0x64	;d
	je ratorD
	cmp edx, 0x26	;&
	je ratorAnd
	cmp edx, 0x7C	;|
	je ratorOr
	cmp edx, 0x6E	;n
	je ratorN 
%endmacro



section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 0	; format string
	format_int: db "%x", 0	; format strings


section .bss
	input: resb 80
section .data
	calc: db 'calc: ',0x00
	msgErrorOverflow: db 'Error: Operand Stack Overflow',0x00
	newline: db 0xA,0x00
	msgErrorArgument: db 'Error: Insufficient Number of Arguments on Stack',0x00
	sum: dd 0
	firstLink: dd 0
	retval: dd 0
	stackSize: dd 0
	stackCurSizeBytes: dd 0
	stackPointer: dd 0
	stackCurSize: dd 0
	recursive: dd 0
	counter: db 0
	add: db 0
	len: dd 0
	len2: dd 0
	number: dd 0
	tempreg: dd 0
	nextLink: dd 0
	byteNumber: dd 0
	printLink: dd 0
	data: dd 0
	carry: dd 0
	index: dd 0
	i: dd 0
	numPush: dd 0 
	deletePointer1: dd 0
	deletePointer2: dd 0

section .text
  align 16
  global main
  extern printf
  extern fprintf 
  extern fflush
  extern malloc 
  extern calloc 
  extern free 
  extern gets 
  extern getchar 
  extern fgets 

main:
	startmain
	mov ecx, [ebp+8]
	cmp ecx, 1
	jle defaultAllocate
	mov ecx, [ebp+12]	; get function argument (pointer to string)
	mov ecx, [ecx+4]
	StringToInt
	mov eax, dword [number]
	jmp endAllocate
	defaultAllocate:
	mov eax, 5
	jmp endAllocate
	endAllocate: ; eax contain the size of the stack 

	mov [stackSize],eax ;mul the stack size by 4, result in eax
	mult 4, [stackSize]

	push eax
	call malloc
	add esp, 4
	mov [stackPointer], dword eax ;now stackPointer points to an allocated buffer
	
	running:
		printString calc ;print calc
		mov [input], dword 0
		mov ecx,input ;gets an input from the user
		push ecx
		call gets
		pop ecx

		mov edx,[input]	; check q
		cmp edx, 0x71
		je quit	

		rator

		mov edx, [stackCurSize] 
		cmp edx, [stackSize]
		je overflowError

		createLinkedList
		pushLinkedList
		jmp running
	quit:
	endMain

argumentError:
	printString msgErrorArgument
	newLine
	jmp running

overflowError:
	printString msgErrorOverflow
	newLine
	jmp running

ratorP:
	inc dword [retval]
	cmp [stackCurSize], dword 0
	je  argumentError

		mov edx, [stackPointer]
		add edx, [stackCurSizeBytes]
		sub edx, 4
		mov edx, [edx]

		dec dword [stackCurSize] ; dec stack
		sub [stackCurSizeBytes], dword 4 ; dec stack

		mov [deletePointer1], dword edx
		mov [len], dword 0
		mov [recursive], dword edx
		printRecursive:

			cmp [recursive], dword 0x00
			je finishPush
			inc dword [len]
			push dword [recursive]
			getNext [recursive]
			mov edx, [nextLink]
			mov [recursive], dword edx
			jmp printRecursive
			finishPush:
			cmp [len], dword 0
			je endPrint
			pop eax
			getLinkData eax
			mov eax, 0
			mov al, [data]
			printInt eax
			dec dword [len]
			jmp finishPush
		endPrint:
			newLine
			mov [len], dword 0
			freeList dword [deletePointer1]
			jmp running

ratorD:
	inc dword [retval]
	cmp [stackCurSize], dword 0
	je  argumentError
	mov ebx, [stackSize]
	cmp [stackCurSize], ebx
	je  overflowError
	mov [firstLink], dword 0
	mov edx, [stackPointer]
	add edx, [stackCurSizeBytes]
	sub edx, 4
	mov edx, [edx]
	mov [len], dword 0
	ratorDlPush:
		cmp edx, 0x00
		je endRatorDloop
		mov [tempreg], dword edx
		getLinkData edx
		mov ebx, 0
		mov bl, [data]
		push ebx
		inc dword [len]
		mov edx, [tempreg]
		getNext edx
		mov edx, [nextLink]
		jmp ratorDlPush
	endRatorDloop:
		cmp [len], dword 0
		je endRatorD
		pop eax
		addNewLink al
		dec dword [len]
		jmp endRatorDloop

	endRatorD:
		mov [len], dword 0
		pushLinkedList
		jmp running


ratorN:
	inc dword [retval]
	cmp [stackCurSize], dword 0
	je  argumentError

	mov [firstLink], dword 0
	mov edx, [stackPointer]
	add edx, [stackCurSizeBytes]
	sub edx, 4
	mov edx, [edx]

	dec dword [stackCurSize] ; dec stack
	sub [stackCurSizeBytes], dword 4 ; dec stack

	mov [firstLink], dword 0
	mov [deletePointer1], dword edx
	mov [len], dword 0
	ratorNloop:
		cmp edx, 0x00
		je endRatorNloop
		mov [tempreg], dword edx
		getLinkData edx
		add [len], dword 1
		mov edx, [tempreg]
		getNext edx
		mov edx, [nextLink]
		jmp ratorNloop
	endRatorNloop:
		;printInt dword [len]
		;newLine
		mov [i], dword 3
		mov [tempreg], ebx
		loopCreateListFromLen:
		cmp [i], dword 0	;creates a links from every byte of len
		jl listCreated
			mov eax, 0
			mov ebx, [i]
			mov al, byte [len+ebx]
			addNewLink al
			dec dword [i]
			jmp loopCreateListFromLen
		listCreated:
		mov [i], dword 0
		mov ebx, [tempreg]
		mov [len], dword 0
		pushLinkedList
		freeList dword [deletePointer1]
		jmp running 

ratorAnd:
	inc dword [retval]
	cmp [stackCurSize], dword 1
	jle  argumentError

	mov edx, [stackPointer]	;edx has the top operand pointer
	add edx, [stackCurSizeBytes]
	sub edx, 4
	mov edx, [edx]
	mov [deletePointer1], dword edx

	dec dword [stackCurSize] ; dec stack
	sub [stackCurSizeBytes], dword 4 ; dec stack

	mov ecx, [stackPointer]	;ecx has the second top operand pointer
	add ecx, [stackCurSizeBytes]
	sub ecx, 4
	mov ecx, [ecx]
	mov [deletePointer2], dword ecx

	dec dword [stackCurSize] ; dec stack
	sub [stackCurSizeBytes], dword 4 ; dec stack

	mov [firstLink], dword 0	;initialize function params
	mov [numPush], dword 0

	checkLen1:
		cmp edx, dword 0x00
		je endFirstNumber1
		cmp ecx, dword 0x00
		je SecondEndedFirstNot1
		;both numbers still not null
		getLinkData edx
		mov ebx, [data]	;ebx is the first list data
		mov [tempreg], dword ebx
		getLinkData ecx
		mov ebx, [tempreg]
		mov eax, [data]	;eax is the second list data
		and ebx, eax	;preform bitwise and and stores the result in ebx
		push ebx
		inc dword [numPush]
		getNext edx
		mov edx, [nextLink]
		getNext ecx
		mov ecx, [nextLink]
		jmp checkLen1

	endFirstNumber1:	
	jmp BothEnded1

	SecondEndedFirstNot1: ;second number is null first is not
	jmp BothEnded1

	BothEnded1: ;both numbers ended
		cmp [numPush], dword 0
		je endRatorAnd1
		pop eax
		addNewLink al
		dec dword [numPush]
		jmp BothEnded1

	endRatorAnd1:
		mov [numPush], dword 0
		pushLinkedList
		freeList dword [deletePointer1]
		freeList dword [deletePointer2]
		jmp running
ratorPlus:
	inc dword [retval]
	cmp [stackCurSize], dword 1
	jle  argumentError

	mov edx, [stackPointer]	;edx has the top operand pointer
	add edx, [stackCurSizeBytes]
	sub edx, 4
	mov edx, [edx]
	mov [deletePointer1], dword edx

	dec dword [stackCurSize] ; dec stack
	sub [stackCurSizeBytes], dword 4 ; dec stack

	mov ecx, [stackPointer]	;ecx has the second top operand pointer
	add ecx, [stackCurSizeBytes]
	sub ecx, 4
	mov ecx, [ecx]
	mov [deletePointer2], dword ecx

	dec dword [stackCurSize] ; dec stack
	sub [stackCurSizeBytes], dword 4 ; dec stack

	mov [firstLink], dword 0	;initialize function params
	mov [numPush], dword 0
	mov [carry], dword 0

	checkLen3:
		cmp edx, dword 0x00
		je endFirstNumber3
		cmp ecx, dword 0x00
		je SecondEndedFirstNot3
		;both numbers still not null
		getLinkData edx

		mov bl, [data]	;ebx is the first list data
		mov [tempreg], dword ebx
		getLinkData ecx

		mov ebx, [tempreg]
		mov eax,0
		add al, [data]	;eax is the second list data

		add bl, al	;preform plus and and stores the result in ebx
		add ebx, [carry]
		
		cmp ebx, 0xF
		jle noCary1
		mov [carry], dword 1
		sub ebx, 0x10
		jmp endCary1
		noCary1:
		mov [carry], dword 0
		jmp endCary1
		endCary1:
		and ebx, 0xF
		push ebx
		inc dword [numPush]
		getNext edx
		mov edx, [nextLink]
		getNext ecx
		mov ecx, [nextLink]
		jmp checkLen3

	endFirstNumber3:	
	cmp ecx, dword 0x00
	je BothEnded3
	;second is longer
		getLinkData ecx
		mov eax,0
		mov al, [data]	;eax is the data
		add eax, [carry]
		cmp eax, 0xF
		jle noCary2
		mov [carry], dword 1
		sub eax, 0x10
		jmp endCary2
		noCary2:
		mov [carry], dword 0
		jmp endCary2
		endCary2:
		and eax, 0xF
		push eax
		inc dword [numPush]
		getNext ecx
		mov ecx, [nextLink]
		jmp checkLen3

	SecondEndedFirstNot3: ;first s longer
		getLinkData edx
		mov eax,0
		mov al, [data]	;eax is the data
		add eax, [carry]
		cmp eax, 0xF
		jle noCary3
		mov [carry], dword 1
		sub eax, 0x10
		jmp endCary3
		noCary3:
		mov [carry], dword 0
		jmp endCary3
		endCary3:
		and eax, 0xF
		push eax
		inc dword [numPush]
		getNext edx
		mov edx, [nextLink]

		jmp checkLen3

	BothEnded3:

		cmp [carry], byte 1 ;both numbers ended
		jne BothEnded2Loop
		push 1
		inc dword [numPush]
		BothEnded2Loop:
		cmp [numPush], dword 0
		je endRatorPlus
		pop eax
		addNewLink al
		dec dword [numPush]
		jmp BothEnded2Loop

	endRatorPlus:
		mov [numPush], dword 0
		mov [carry], dword 0
		pushLinkedList
		freeList dword [deletePointer1]
		freeList dword  [deletePointer2]
		jmp running
ratorOr:
	inc dword [retval]
	cmp [stackCurSize], dword 1
	jle  argumentError

	mov edx, [stackPointer]	;edx has the top operand pointer
	add edx, [stackCurSizeBytes]
	sub edx, 4
	mov edx, [edx]
	mov [deletePointer1], dword edx

	dec dword [stackCurSize] ; dec stack
	sub [stackCurSizeBytes], dword 4 ; dec stack

	mov ecx, [stackPointer]	;ecx has the second top operand pointer
	add ecx, [stackCurSizeBytes]
	sub ecx, 4
	mov ecx, [ecx]
	mov [deletePointer2], dword ecx

	dec dword [stackCurSize] ; dec stack
	sub [stackCurSizeBytes], dword 4 ; dec stack

	mov [firstLink], dword 0	;initialize function params
	mov [numPush], dword 0

	checkLen2:
		cmp edx, dword 0x00
		je endFirstNumber2
		cmp ecx, dword 0x00
		je SecondEndedFirstNot2
		;both numbers still not null
		getLinkData edx
		mov ebx, [data]	;ebx is the first list data
		mov [tempreg], dword ebx
		getLinkData ecx
		mov ebx, [tempreg]
		mov eax, [data]	;eax is the second list data

		or ebx, eax	;preform bitwise and and stores the result in ebx
		push ebx
		inc dword [numPush]
		getNext edx
		mov edx, [nextLink]
		getNext ecx
		mov ecx, [nextLink]
		jmp checkLen2

	endFirstNumber2:	
	cmp ecx, dword 0x00
	je BothEnded2
	;second is longer
		getLinkData ecx
		mov eax, [data]	;eax is the data
		push eax
		inc dword [numPush]
		getNext ecx
		mov ecx, [nextLink]
		jmp checkLen2

	SecondEndedFirstNot2: ;first s longer
		getLinkData edx
		mov eax, [data]	;eax is the data
		push eax
		inc dword [numPush]
		getNext edx
		mov edx, [nextLink]
		jmp checkLen2

	BothEnded2: ;both numbers ended
		cmp [numPush], dword 0
		je endRatorAnd2
		pop eax
		addNewLink al
		dec dword [numPush]
		jmp BothEnded2

	endRatorAnd2:
		mov [numPush], dword 0
		pushLinkedList
		freeList dword [deletePointer1]
		freeList dword [deletePointer2]
		jmp running