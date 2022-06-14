TITLE Function library

.code
; parseCommandLine
; Returns the length of a null-terminated string.
; Receives: RCX has max size of command line (20h)
;		  RDX points to the command line string (18h)
;		  R8 pointer to table of argument pointers (10h)
;           R9 pointer to table of argument lengths (08h)
; Returns: RAX = number of arguments
;---------------------------------------------------------
parseCommandLine PROC
     sub       RSP, (4*8 + 8)			; Allocate 32 bytes of Shadow Space (4 parms * 8 bytes) + align it to 16 bytes 
								; (8 byte return address already on stack, so 8 + 32 + 8 = 16*3)
								; for function call to strnlen

	xor	RBX, RBX			; argc counter
	xor	R10, R10			; byte counter
     mov	[RSP + 20h], RCX	; save max size
     mov	[RSP + 18h], RDX	; save pointer to command line
	mov	RSI, RDX			; save start pointer

	; process arguments
process:
	mov	RDI, RDX		; get string pointer
	mov	RDX, RCX		; set max size
	mov	RAX, ' '		; search for ' ' delimeter
	cld				; clear the direction flag
	repne	scasb	; scan string byte by byte
	jnz	lastArg		; if we don't find ' ' delimeter, must be last arg
	sub 	RDX, RCX		; compute the length
	cmp	RDX, 1		; if only 1 char, including blank then skip
	je	skip
	mov	[R8+RBX*8], RSI	; save argv pointer
	mov	[R9+RBX*8], RDX	; save argv length
	inc	RBX			; increment argc
	add	R10, RDX		; increment bytes read
skip:
	mov	RDX, RDI		; move to next argument
	mov	RSI, RDI		; move start pointer
	mov	RCX, [RSP + 20h]
	sub	RCX, R10
	inc	R10			; adjust for ' '
	cmp	R10, [RSP + 20h]	; all bytes processed
	jne	process			
	mov	RAX, RBX		; set argc for return
exit:
	add	     RSP,(4*8 + 8)			; cleanup shadow space
	ret
lastArg:	
	mov	[R8+RBX*8], RSI	; save argv pointer
	sub 	RDX, RCX		; compute the length
	mov	[R9+RBX*8], RDX	; save argv length
	inc	RBX			; increment argc
	mov	RAX, RBX		; set argc for return
	jmp	exit
parseCommandLine	ENDP
;---------------------------------------------------------
; strnlen
; Returns the length of a null-terminated string.
; Receives: RCX has max size of command line
;		  RDX points to the command line string
; Returns: RAX = string length
;---------------------------------------------------------
strnlen PROC
	mov	RDI, RDX		; get string pointer
	mov	RDX, RCX		; save max size
	xor	RAX, RAX		; search for 00h
	cld				; clear the direction flag
	repne	scasb	; scan string byte by byte
	jnz	error		; jump if we don't find null terminator
	sub 	RDX, RCX		; compute the length
	mov	RAX, RDX		; return length
exit:
	ret
error:
	mov	RAX, -1		; return error
	jmp	exit
strnlen ENDP
end