TITLE Print Buffer to Console

; External functions
GetStdHandle	PROTO
WriteFile		PROTO

; Constants
STDOUT		EQU - 11
BUFSZ		EQU		80

.data
buffer		BYTE		BUFSZ	DUP(0)
newLine		BYTE		0dh, 0ah, 0
newLineSz		EQU		SIZEOF	NewLine
bytesWritten	QWORD	?
hStdOut		QWORD	0
initialized	QWORD	0

.code
; ---------------------------------------------------------
TITLE Print Buffer to Console
;
; prinToConsole
;
; Receives: RCX number of characters to print (28h)
;		  RDX has pointer of buffer to print(20h)
; Returns: Nothing
;
; VARIABLES: The registers have the following uses:
;
; ---------------------------------------------------------
printToConsole PROC

	; Initialize
	sub       RSP, (5 * 8)	; Allocate 32 bytes of Shadow Space(5 parms * 8 bytes) + align it to 16 bytes
							; (8 byte return address already on stack, so 8 + 40 = 16 * 3)
							; for function call to WriteFile

	mov	RAX, [initialized]
	cmp	RAX, 1
	je	print
	inc	RAX
	mov	[initialized], RAX		; save initialized flag
	mov	[RSP + 20h], RCX		; save number of bytes to write 
	mov	RCX, STDOUT
	call  GetStdHandle
	mov	[hStdOut], RAX			; save console handle
	mov	RCX, [RSP + 20h]
print:
	; WriteFile(hstdOut, message, length(message), &bytesWritten, 0);
	mov	RAX, RCX			; save number of bytes
	mov  RCX, [hStdOut]		; handle(parm 1)
	;mov  RDX, RDX			; RDX already has message buffer ptr(parm 2)
	mov	R8, RAX			; length of message(parm 3)
	lea	R9, bytesWritten	; bytes written(parm 4)
	mov   qword ptr[RSP + 4 * SIZEOF QWORD], 0; reserved parameter, set to zero(parm 5)
	call  WriteFile

	add	     RSP, (5 * 8)	; cleanup shadow space
	ret
printToConsole ENDP

printNLToConsole PROC
	sub       RSP, (2 * 8 + 8)	; Allocate 32 bytes of Shadow Space(2 parms * 8 bytes) + align it to 16 bytes
							; (8 byte return address already on stack, so 8 + 16 + 8 = 16 * 2)
							; for function call to WriteFile

     ; Write NewLine
	mov	  RCX, newLineSz		; length of message (parm 1)
	lea    RDX, newLine			; newLine ptr (parm 2)
	call   printToConsole

	add	     RSP, (2 * 8 + 8)	; cleanup shadow space
	ret
printNLToConsole ENDP

TITLE Convert Integer To String and Print
; printIntToConsole
;
; Receives: RCX has an integer to print (20h)
; Returns: Nothing
;
; VARIABLES: The registers have the following uses
;
; RAX - division of integer
; RBX - length of the buffer
; RCX - digit count
; RDX - division of integer
; RDI - divisor
;---------------------------------------------------------
printIntToConsole PROC

     ; Initialize
     sub       RSP, (2*8 + 8)			; Allocate 16 bytes of Shadow Space (2 parms * 8 bytes) + align it to 16 bytes 
								; (8 byte return address already on stack, so 8 + 16 + 8 = 16*2)
								; for function call to printToConsole

	mov	RAX, RCX		; move integer for division
	xor	RCX, RCX		; 0 the digit count
	xor	R8, R8		; 0 counter for ',' print
	mov	RDI, 10		; setup for divide by 10
convert:
     xor	RDX, RDX		; division done on combined RDX:RAX, so 0 RDX
	; Start dividing
     div	RDI			; quotient in RAX, remainder in RDX
	add	RDX, '0'		; convert to ascii digit
	inc	R8			; inc count for ','
	cmp	R8, 4		; print ',' if necessary
	je	addComma
nextDigit:
	push	RDX			; save digit
	inc	RCX			; increment digit count
	cmp 	RAX, 0		; if remainer is 0, we're done
	jne	convert

	; Move from stack to bufffer
	lea	RDX, buffer	
	mov	RBX, RCX		; save the digit count
save:
	pop	RAX			; get digit from stack
	mov	byte ptr [RDX], AL		; save it in the buffer
	dec	RCX			; decrement digit count
	inc	RDX			; move buffer ptr
	cmp	RCX, 0		; all digits moved?
	jne	save
	mov	byte ptr [RDX], 0		; terminate string with null byte
	
	; WriteFile( hstdOut, message, length(message), &bytesWritten, 0);
	mov	RCX, BUFSZ		; length of message (parm 3)
	lea   RDX, buffer		; buffer ptr (parm 2)
	call  printToConsole
exit:
	add	     RSP,(2*8 + 8)			; cleanup shadow space
     ret
addComma:
	xor	RSI, RSI
	add	RSI, ','
	push	RSI
	inc	RCX
	mov	R8, 1			; rest count
	jmp nextDigit
printIntToConsole ENDP
end