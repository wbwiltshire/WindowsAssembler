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

TITLE Add two integers
.code
;--------------------------------------------------------
; Add 
; Adds to integers
; Receives: RCX and RDX contain the two integers
; Returns: RCX
; Uses: RCX RDX
;--------------------------------------------------------
AddInt PROC
	; make new call frame
	push		RBP       ; save old call frame
	sub		RSP, 32	; Adjust X64 calling convention (4 * 8 parms, whether we use them or not)
     mov		RBP, RSP  ; initialize new call frame

	mov		EAX, ECX	; move in first integer
	add		EAX, EDX	; Add second and return in RAX
	
	mov		RSP, RBP  ; Restore old stack pointer
	add		RSP, 32   ; Adjust for X64 calling convention
	pop		RBP		; restore old call frame

	ret
AddInt ENDP
AddLong PROC
	; make new call frame
	push		RBP       ; save old call frame
	sub		RSP, 32	; Adjust X64 calling convention (4 * 8 parms, whether we use them or not)
     mov		RBP, RSP  ; initialize new call frame

	mov		RAX, RCX	; move in first integer
	add		RAX, RDX	; Add second and return in RAX
	
	mov		RSP, RBP  ; Restore old stack pointer
	add		RSP, 32   ; Adjust for X64 calling convention
	pop		RBP		; restore old call frame

	ret
AddLong ENDP
end