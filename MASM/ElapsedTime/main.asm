TITLE Elapsed Time
; Calls use MS X86_64 calling convention:
;	RCX (parm1)
;	RDX (parm2)
;	R8  (parm3)
;    R9  (parm4)
;	Stack aligned on 16 byte boundaries

ExitProcess	PROTO
GetLocalTime	PROTO
Sleep		PROTO
printToConsole	PROTO
printNLToConsole	PROTO
printIntToConsole	PROTO
timeDiff		PROTO

.data
	message		BYTE      "Elapsed time (msec): "
	messageSz		EQU		SIZEOF	message
	SystemTime	STRUCT	
		Year		WORD		0
		Month	WORD		0
		ToDay	WORD		0	; Sunday 0 to Saturday 6
		Day		WORD		0
		Hour		WORD		0
		Minute	WORD		0
		Second	WORD		0
		Ksecond	WORD		0
	SystemTime	ENDS
	startTime		SystemTime	<>
	endTime		SystemTime	<>

.code
main	PROC
	sub   RSP, (5 * 8) 				; create shadow space for 5 parameters
								; plus caller address (8 + 40 = 16*3 so it's aligned)
								; used by WriteConsoleA
    ; get start time
    lea	RCX, startTime
    call	GetLocalTime

    ; WriteFile( hstdOut, message, length(message), &bytesWritten, 0);
    mov   RCX, messageSz				; message size (parm 1)
    lea   RDX, message				; message ptr (parm 2)
    call  printToConsole

    ; sleep for 1 sec (1,000 milliseconds)
    mov	RCX, 1000
    call	Sleep

    ; get end time
    lea	RCX, endTime
    call	GetLocalTime

    ; compute the difference
    lea	RCX, startTime
    lea	RDX, endTime
    call	timeDiff
    ; result is an integer in RAX

    ; Print elapsed time
    mov	RCX, RAX
    call	printIntToConsole

    ; Write NewLine
    call    PrintNLToConsole
    
    ; ExitProcess(0)
    add   RSP,(5 * 8)				; cleanup shadow space
    xor	RCX, RCX
    call  ExitProcess
main	ENDP
end