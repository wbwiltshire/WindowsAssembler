; Calls use MS X86_64 calling convention:
;	RCX (parm1)
;	RDX (parm2)
;	R8  (parm3)
;   R9  (parm4)
;	Stack aligned on 16 byte boundaries
	[bits 64]
	default rel

	extern GetStdHandle
	extern WriteConsoleA

STD_OUTPUT_HANDLE 	equ -11		; predefined Win API constant
QWORD_SZ 			equ 8

	section	.data
initFlag		  	db 0			; initialization flag
consoleOutHandle 	dq 0     		; handle to standard output device	
bytesWritten     	dq 0     		; number of bytes written

;----------------------------------------------------
; CODE SECTION
;--------------------------------------------------------
; WriteString 
; Writes a null-terminated string to the console.
; Modifies: bytesWritten
; Receives: RCX points to the string, and RDX has string length
; Returns: nothing
; Uses: RCX RDX R8 R9
;--------------------------------------------------------
	global WriteString
	section .text
WriteString: 
	sub   	rsp, (5 * 8) 				; create shadow space for 5 parameters
										; plus caller address (8 + 40 = 16*3 so it's aligned)
										; used by WriteConsoleA

	mov 	[rsp + 30h], rcx			; save string pointer (arg1 1 = 48 bytes back in the stack (40 for Shadow Space above, 8 for return address)
	mov 	[rsp + 38h], rdx			; save string length (arg 2 is just after arg 1
	cmp		BYTE [initFlag], 0
	jne		exit
	call	Initialize

exit:		
	mov	 rcx, [consoleOutHandle]	; set to value of STD_OUTPUT handle
	mov	 rdx, [rsp + 30h]			; restore string pointer
	mov	 r8, [rsp + 38h]			; restore length of string
	lea	 r9, [bytesWritten]			; set to address of byteWritten
	mov	 QWORD [rsp + 4 * QWORD_SZ], 0	; (reserved parameter, set to zero)

	call  WriteConsoleA				; (handle, pointer, length, written, reserved )

	add   rsp,(5 * 8)				; cleanup shadow space
	ret
;----------------------------------------------------
; Initialize
; Gets the standard console handles for input and output,
; and sets a flag indicating that it has been done.
; Modifies: consoleInHandle, consoleOutHandle, InitFlag
; Receives: nothing
; Returns: nothing
; Uses: RAX RCX
; ----------------------------------------------------
Initialize: 
    sub		rsp, (4*8 + 8)		; Allocate 32 bytes of Shadow Space (4 parms * 8 bytes) + align it to 16 bytes 
								; (8 byte return address already on stack, so 8 + 32 + 8 = 16*3)
								; for function call to WriteString

	mov		rcx, STD_OUTPUT_HANDLE
	call	GetStdHandle			; request STD_OUTPUT handle
	mov		[consoleOutHandle], rax	; store handle
	mov     [initFlag], BYTE 1      ; set init flag

	add	    rsp,(4*8 + 8)			; cleanup shadow space
	ret
