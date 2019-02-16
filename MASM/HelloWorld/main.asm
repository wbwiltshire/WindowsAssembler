TITLE Hello World
; Calls use MS X86_64 calling convention:
;	RCX (parm1)
;	RDX (parm2)
;	R8  (parm3)
;    R9  (parm4)
;	Stack aligned on 16 byte boundaries

STDOUT		EQU		-11
GetStdHandle	PROTO
WriteFile		PROTO
ExitProcess	PROTO

.data
	message		BYTE      "Hello, World!", 0dh, 0ah
	message_end	BYTE		0
	bytesWritten	QWORD	?

.code
main	PROC
	sub   RSP, (5 * 8) 				; create shadow space for 5 parameters
								; plus caller address (8 + 40 = 16*3 so it's aligned)
								; used by WriteConsoleA

    MOV	  RCX, STDOUT
    call    GetStdHandle

    ; WriteFile( hstdOut, message, length(message), &bytesWritten, 0);
    mov     RCX, RAX				; handle (parm 1)
    lea     RDX, message				; message ptr (parm 2)
    mov	  R8, (message_end - message) ; length of message (parm 3)
    lea	  R9, bytesWritten			; bytes written (parm 4)
    mov     qword ptr [RSP + 4* SIZEOF QWORD], 0	; reserved parameter, set to zero (parm 5)
    call    WriteFile

    ; ExitProcess(0)
    add     RSP,(5 * 8)				; cleanup shadow space
    xor	  RCX, RCX
    call    ExitProcess
main	ENDP
end