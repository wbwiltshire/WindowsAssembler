; ----------------------------------------------------------------------------------------
; Writes "Hola, mundo" to the console using a call to another assembler routine
;
;     nasm -fwin64 main.asm -o main.obj
;     nasm -fwin64 writestring.asm -o writestring.obj
;     link /subsystem:console main.obj writestring.obj /entry:main /out:hola.exe
;
; Calls use MS X86_64 calling convention:
;	RCX (parm1)
;	RDX (parm2)
;	R8  (parm3)
;   R9  (parm4)
;	Stack aligned on 16 byte boundaries
; ----------------------------------------------------------------------------------------
	[bits 64]
	default rel

    extern  ExitProcess
	extern  WriteString

    global  main

    section .text
main:                                   
	sub		rsp, (4*8 + 8)		; Allocate 32 bytes of Shadow Space (4 parms * 8 bytes) + align it to 16 bytes 
								; (8 byte return address already on stack, so 8 + 40 = 16*3)
                                ; for function call to WriteString
    lea     rcx, [message]      ; load message address and option
    mov		rdx, 14
	call    WriteString         ; WriteString(message)

    ; exit(0)
    add     rsp, (4*8 + 8)      ; cleanup shadow space
	xor		rcx, rcx
    xor     rax, rax            ; exit code 0
    call    ExitProcess         ; call operating system to exit
	ret
	section	.data
message:
	db      "Hola, mundo", 0        ; Note strings must be terminated with 0 in C