TITLE Get Command Line parameters and print them
; Calls use MS X86_64 calling convention:
;	RCX (parm1)
;	RDX (parm2)
;	R8  (parm3)
;    R9  (parm4)
;	Stack aligned on 16 byte boundaries

STDOUT		EQU		-11
ARG_COUNT		EQU		3
CL_MAX_LEN	EQU		240

GetStdHandle	PROTO
WriteFile		PROTO
GetCommandLineA	PROTO
LocalFree		PROTO
strlen		PROTO
ExitProcess	PROTO
;CommandLineToArgv	PROTO
; Internal procs
parseCommandLine	PROTO
strnlen		PROTO

.data
	stdout_handle	QWORD	?
	usageMsg		BYTE		"Usage: getcommandline <arg1> <arg2>", 0dh, 0ah	
	usageMsgEnd	BYTE		0
	cntMsg		BYTE      "Command line args: "
	cntMsgEnd		QWORD	0
	argMsg		BYTE      "Command line values: "
	argMsgEnd		BYTE		0
	newLine		BYTE		0dh, 0ah, 0
	argCStr		BYTE		0, 0 , 0dh, 0ah, 0	
	argPtrs		QWORD	ARG_COUNT	DUP	(0)	; table of argument ptrs
	argLens		QWORD	ARG_COUNT	DUP	(0)	; table of argument lengths
	bytesWritten	QWORD	?
	argC			QWORD	?
	argV			QWORD	?
	cmdLine		QWORD	?

.code
main	PROC
	sub    RSP, (5 * 8) 			; create shadow space for 5 parameters
								; plus caller address (8 + 40 = 16*3 so it's aligned)
								; used by the called functions
    mov	  RCX, STDOUT
    call    GetStdHandle
    mov	  [stdout_handle], RAX

    ; GetCommandLine( void)
    xor	RCX, RCX
    call	GetCommandLineA
    ; Returns pointer to command line string in RAX
    mov	[cmdLine], RAX
    
    ; Get length of command line string
    mov	RCX, CL_MAX_LEN
    mov	RDX, RAX
    call	strnlen
    ; returns length of command line in RAX

    mov	RCX, RAX				; length of command line
    mov	RDX, [cmdLine]			; Command line pointer
    lea	R8, argPtrs			; table of argv pointers
    lea	R9, argLens			; table of argv lengths
    call	parseCommandLine
    ; returns number of command line args in RAX

    cmp	RAX, -1
    je	usage
    cmp	RAX, ARG_COUNT
    jg	usage

    ; Print argument count to console
    mov	[argC], RAX			; save argc
    add	RAX, 30h				; adjust to ASCII
    mov	[argCStr], AL			; save count for output
    ; WriteFile( hstdOut, message, length(message), &bytesWritten, 0);
    mov     RCX, [stdout_handle]			; handle (parm 1)
    lea     RDX, cntMsg				; message ptr (parm 2)
    mov	  R8, (cntMsgEnd - cntMsg) ; length of message (parm 3)
    lea	  R9, bytesWritten				; bytes written (parm 4)
    mov     qword ptr [RSP + 4* SIZEOF QWORD], 0	; reserved parameter, set to zero (parm 5)
    call    WriteFile

    ; Write Argument Count
    mov     RCX, [stdout_handle]			; handle (parm 1)
    lea     RDX, argCStr					; message ptr (parm 2)
    mov	  R8, 1						; length of message (parm 3)
    lea	  R9, bytesWritten				; bytes written (parm 4)
    mov     qword ptr [RSP + 4* SIZEOF QWORD], 0	; reserved parameter, set to zero (parm 5)
    call    WriteFile
    ; Write NewLine
    mov     RCX, [stdout_handle]			; handle (parm 1)
    lea     RDX, newLine					; message ptr (parm 2)
    mov	  R8, 2						; length of message (parm 3)
    lea	  R9, bytesWritten				; bytes written (parm 4)
    mov     qword ptr [RSP + 4* SIZEOF QWORD], 0	; reserved parameter, set to zero (parm 5)
    call    WriteFile

    ; Write Argument List title
    mov     RCX, [stdout_handle]			; handle (parm 1)
    lea     RDX, argMsg				; message ptr (parm 2)
    mov	  R8, (argMsgEnd - argMsg) ; length of message (parm 3)
    lea	  R9, bytesWritten				; bytes written (parm 4)
    mov     qword ptr [RSP + 4* SIZEOF QWORD], 0	; reserved parameter, set to zero (parm 5)
    call    WriteFile
    ; Write NewLine
    mov     RCX, [stdout_handle]			; handle (parm 1)
    lea     RDX, newLine					; message ptr (parm 2)
    mov	  R8, 2						; length of message (parm 3)
    lea	  R9, bytesWritten				; bytes written (parm 4)
    mov     qword ptr [RSP + 4* SIZEOF QWORD], 0	; reserved parameter, set to zero (parm 5)
    call    WriteFile

    ; Write the Argument List
    mov	  RBX, [argC]
    lea     RDI, argPtrs
    lea     RSI, argLens
listArgs:    
    mov     RCX, [stdout_handle]			; handle (parm 1)
    mov     RDX, [RDI]					; message ptr (parm 2)
    mov	  R8, [RSI] 					; get length of argv
    lea	  R9, bytesWritten				; bytes written (parm 4)
    mov     qword ptr [RSP + 4* SIZEOF QWORD], 0	; reserved parameter, set to zero (parm 5)
    call    WriteFile
    ; Write NewLine
    mov     RCX, [stdout_handle]			; handle (parm 1)
    lea     RDX, newLine					; message ptr (parm 2)
    mov	  R8, 2						; length of message (parm 3)
    lea	  R9, bytesWritten				; bytes written (parm 4)
    mov     qword ptr [RSP + 4* SIZEOF QWORD], 0	; reserved parameter, set to zero (parm 5)
    call    WriteFile
    add     RDI, 8						; move to next in list
    add     RSI, 8						; move to next in list
    dec	  RBX
    jnz     listArgs


    ; ExitProcess(0)
exit:
    add     RSP,(5 * 8)				; cleanup shadow space
    xor	  RCX, RCX
    call    ExitProcess
usage:
    mov     RCX, [stdout_handle]		; handle (parm 1)
    lea     RDX, usageMsg			; message ptr (parm 2)
    mov	  R8, (usageMsgEnd - usageMsg) ; length of message (parm 3)
    lea	  R9, bytesWritten				; bytes written (parm 4)
    mov     qword ptr [RSP + 4* SIZEOF QWORD], 0	; reserved parameter, set to zero (parm 5)
    call    WriteFile
    jmp	exit

main	ENDP
end