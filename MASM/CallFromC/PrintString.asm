;-------------------------------------------------------------
; Uses Microsoft X64 call convention
; Link: https://docs.microsoft.com/en-us/cpp/build/parameter-passing
; RCX: Parameter 1
; RDX: Parameter 2
; R8:  Parameter 3
; R9:  Parameter 4
; Additional arguments pushed on the stack
;
; Result returned in RAX


TITLE Print string to console

GetStdHandle	PROTO
WriteConsoleA	PROTO

; Calls use MS X86_64 calling convention:
;	RCX (parm1)
;	RDX (parm2)
;	R8  (parm3)
;   R9  (parm4)
;	Stack aligned on 16 byte boundaries

STD_OUTPUT_HANDLE EQU -11		; predefined Win API constant

;-------------------------------------------------------------
CheckInit MACRO
;
; Helper macro
; Check to see if the console handles have been initialized
; If not, initialize them now.
;-------------------------------------------------------------
LOCAL exit
	cmp		initFlag, 0
	jne		exit
	call		Initialize
exit:
ENDM

.data
	initFlag		  BYTE 0		; initialization flag
	consoleOutHandle QWORD ?     	; handle to standard output device	
	bytesWritten     QWORD ?     	; number of bytes written

.code
;--------------------------------------------------------
; PrintString 
; Writes a null-terminated string to the console.
; Receives: RCX points to the string
; Returns: nothing
; Uses: RCX RDX
;--------------------------------------------------------

PrintString PROC
	; make new call frame
	push		RBP       ; save old call frame
	sub		RSP, 32	; Adjust X64 calling convention (4 * 8 parms, whether we use them or not)
     mov		RBP, RSP  ; initialize new call frame

	call		StrLength ; 
	mov		RDX, RAX	; Length of string
	call		WriteString
	
	mov		RSP, RBP  ; Restore old stack pointer
	add		RSP, 32   ; Adjust for X64 calling convention
	pop		RBP		; restore old call frame

	ret
PrintString ENDP
;----------------------------------------------------
; Initialize
; Gets the standard console handles for input and output,
; and sets a flag indicating that it has been done.
; Modifies: consoleInHandle, consoleOutHandle, InitFlag
; Receives: nothing
; Returns: nothing
; Uses: RAX RCX
; ----------------------------------------------------
Initialize PROC private 
    sub    RSP, (4*8 + 8)		; Allocate 32 bytes of Shadow Space (4 parms * 8 bytes) + align it to 16 bytes 
							; (8 byte return address already on stack, so 8 + 32 + 8 = 16*3)
							; for function call to GetStdHandle

	mov		RCX, STD_OUTPUT_HANDLE
	call		GetStdHandle			; request STD_OUTPUT handle
	mov		[consoleOutHandle], RAX	; store handle

	add	     RSP,(4*8 + 8)			; cleanup shadow space
	ret
Initialize ENDP
;--------------------------------------------------------
; WriteString 
; Writes a string with a defined length to the console.
; Modifies: bytesWritten
; Receives: RCX points to the string, and RDX has string length
; Returns: nothing
; Uses: RCX RDX R8 R9
;--------------------------------------------------------
WriteString proc private
	sub   RSP, (5 * 8) 				; create shadow space for 5 parameters
								; plus caller address (8 + 40 = 16*3 so it's aligned)
								; used by WriteConsoleA

	mov [RSP + 30h], RCX			; save string pointer (arg1 1 = 48 bytes back in the stack (40 for Shadow Space above, 8 for return address)
	mov [RSP + 38h], RDX			; save string length (arg 2 is just after arg 1
	CheckInit						; macro that checks that STD_OUTPUT handle initialized
		
	mov	 RCX, consoleOutHandle		; set to value of STD_OUTPUT handle
	mov	 RDX, [RSP + 30h]			; restore string pointer
	mov	 R8, [RSP + 38h]			; restore length of string
	lea	 R9, bytesWritten			; set to address of byteWritten
	mov	 qword ptr [RSP + 4 * SIZEOF QWORD], 0	; (reserved parameter, set to zero)

	call  WriteConsoleA				; (handle, pointer, length, written, reserved )

	add   RSP,(5 * 8)				; cleanup shadow space
	ret
WriteString ENDP
;---------------------------------------------------------
; StrLength
; Returns the length of a null-terminated string.
; Receives: RCX points to the string
; Returns: RAX = string length
;---------------------------------------------------------
StrLength PROC uses rdi
	mov  rdi,rcx
	mov  rax,0     	             ; character count
L1:
	cmp  BYTE PTR [rdi],0	     ; end of string?
	je   L2	                     ; yes: quit
	inc  rdi	                     ; no: point to next
	inc  rax	                     ; add 1 to count
	jmp  L1
L2: 
	ret
StrLength ENDP
end