TITLE Hola, Warren!

; External Windows function for process exit 
ExitProcess	PROTO
WriteString	PROTO

; Calls use MS X86_64 calling convention:
;	RCX (parm1)
;	RDX (parm2)
;	R8  (parm3)
;   R9  (parm4)
;	Stack aligned on 16 byte boundaries

.data
    holaWarren	  BYTE "Hola, World!", 0dh, 0ah, 0

.code
main        PROC
    sub     RSP, (4*8 + 8)      ; Allocate 32 bytes of Shadow Space (4 parms * 8 bytes) + align it to 16 bytes 
                                ; (8 byte return address already on stack, so 8 + 40 = 16*3)
                                ; for function call to WriteString
    mov     RCX, OFFSET holaWarren
    mov     RDX, 14
    call    WriteString	

    ;exit code is 0
    add    RSP, (4*8 + 8)       ; cleanup shadow space
    xor    RCX, RCX
    call   ExitProcess          ; exit to OS

main	ENDP

END