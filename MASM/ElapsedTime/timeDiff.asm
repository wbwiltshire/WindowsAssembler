TITLE Compete different between two times

.code
; timeDiff
;
; Receives: RCX has pointer to the start time in a SYSTIME structure (20h)
;		  RDX has pointer to the end time in a SYSTIME strcture (18h)
; Returns: RAX has difference (RDX - RCX) in milliseconds
;
; VARIABLES: The registers have the following uses
;
;---------------------------------------------------------
; External functions
SystemTimeToFileTime	PROTO
; Constants
BUFSZ		EQU		80

.data
	FileTime	STRUCT	
		LowDT	DWORD	0
		HighDT	DWORD	0
	FileTime	ENDS	
	startTime		FileTime	<>
	endTime		FileTime	<>


.code
timeDiff PROC

     ; Initialize
     sub       RSP, (4*8 + 8)			; Allocate 32 bytes of Shadow Space (2 parms * 8 bytes) + align it to 16 bytes 
								; (8 byte return address already on stack, so 8 + 16 + 8 = 16*2)
								; for function call to WriteFile

	; convert to FileTime so we get the difference
	mov [RSP + 10h], RDX			; save the endTime ptr		
	;mov	RCX, RCX					; RCX already has pointer to start time
	lea	RDX, startTime				; set output location
	call	SystemTimeToFileTime

	mov	RCX, [RSP + 10h]			; get endTime ptr
	lea	RDX, endTime				; set output location
	call	SystemTimeToFileTime

	mov	RAX, QWORD PTR [EndTime]
	sub	RAX, QWORD PTR [StartTime]	; time is in 100 nanosecond intervals
	; Convert to msecs
	mov	RDI, 10000				; setup for divide by 10,000
     xor	RDX, RDX					; division done on combined RDX:RAX, so 0 RDX
	; Divide
     div	RDI						; quotient in RAX, remainder in RDX

exit:
	add	     RSP,(4*8 + 8)			; cleanup shadow space
     ret
timeDiff ENDP
end