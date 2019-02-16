TITLE Print to console (character, string, and zero terminated string)
; Calls use MS X86_64 calling convention:
;    RCX (parm1)
;    RDX (parm2)
;    R8  (parm3)
;    R9  (parm4)
;    Stack aligned on 16 byte boundaries

; External functions
GetStdHandle	PROTO
WriteConsoleA	PROTO
putchar        PROTO
printf         PROTO

; Constants
STD_OUTPUT_HANDLE EQU -11		; predefined Win API constant

;-------------------------------------------------------------
; Helper macro
; Check to see if the console handles have been initialized
; If not, initialize them now.
;-------------------------------------------------------------
CheckInit MACRO
LOCAL exit
	cmp		initFlag, 0
	jne		exit
	call		Initialize
exit:
ENDM
;-------------------------------------------------------------
; Data Segment
;-------------------------------------------------------------

.data
	initFlag		  BYTE 0		; initialization flag
	consoleOutHandle QWORD ?     	; handle to standard output device
     bytesWritten     QWORD ?     	; number of bytes written

;-------------------------------------------------------------
; Code Segment
;-------------------------------------------------------------
.code

;----------------------------------------------------
; Initialize
; Gets the standard console handles for input and output,
; and sets a flag indicating that it has been done.
; Modifies: consoleInHandle, consoleOutHandle, InitFlag
; Receives: nothing
; Returns: nothing
; Uses: RAX RCX
; ----------------------------------------------------
Initialize  proc private 
    sub     rsp, (4*8 + 8)			; Allocate 32 bytes of Shadow Space (4 parms * 8 bytes) + align it to 16 bytes 
								; (8 byte return address already on stack, so 8 + 32 + 8 = 16*3)
								; for function call to GetStdHandle

    mov     rcx, STD_OUTPUT_HANDLE
    call	  GetStdHandle			     ; request STD_OUTPUT handle
    mov     [consoleOutHandle], rax	; store handle

    add	  rsp,(4*8 + 8)			; cleanup shadow space
    ret
Initialize  endp
;--------------------------------------------------------
; PrintChar 
; Prints a character to the console.
; Modifies: bytesWritten
; Receives: RCX has character to print
; Returns: nothing
; Uses: RCX RDX R8 R9
;--------------------------------------------------------
PrintChar   proc
    sub     rsp, (4 * 8 + 8) 			; create shadow space for 4 parameters
								; plus caller address (8 + 32 + 8 = 16*3 so it's aligned)
								; used by WriteConsoleA
    
    call    putchar                     ; int = (chacter in rcx)

    add     rsp,(4 * 8 + 8)			; cleanup shadow space
    ret
PrintChar   endp

;--------------------------------------------------------
; PrintString 
; Prints a fixed length string to the console.
; Modifies: bytesWritten
; Receives: RCX points to the string, and RDX has string length
; Returns: nothing
; Uses: RCX RDX R8 R9
;--------------------------------------------------------
PrintString proc 
    sub     rsp, (5 * 8) 			; create shadow space for 5 parameters
								; plus caller address (8 + 40 = 16*3 so it's aligned)
								; used by WriteConsoleA

    mov     [rsp + 30h], rcx			; save string pointer (arg1 1 = 48 bytes back in the stack (40 for Shadow Space above, 8 for return address)
    mov     [rsp + 38h], rdx			; save string length (arg 2 is just after arg 1

    ;Print to console
    CheckInit						; macro that checks that STD_OUTPUT handle initialized	
    mov     rcx, consoleOutHandle		; set to value of STD_OUTPUT handle
    mov	  rdx, [rsp + 30h]			; string pointer
    mov     r8, [rsp + 38h]			; length of string
    lea	  r9, bytesWritten			; set to address of byteWritten
    mov     qword ptr [rsp + 4 * SIZEOF QWORD], 0	; (reserved parameter, set to zero)

    call    WriteConsoleA			; (handle, pointer, length, written, reserved )

    add     rsp,(5 * 8)				; cleanup shadow space
    ret
PrintString endp

;--------------------------------------------------------
; PrintStringZ 
; Prints a null-terminated string to the console.
; Modifies: bytesWritten
; Receives: RCX points to the string
; Returns: nothing
; Uses: RCX RDX R8 R9 RDI
;--------------------------------------------------------
PrintStringZ proc
    sub     rsp, (5 * 8) 				; create shadow space for 5 parameters
								; plus caller address (8 + 40 = 16*3 so it's aligned)
								; used by WriteConsoleA

    mov     [rsp + 30h], rcx			; save string pointer (arg1 1 = 48 bytes back in the stack (40 for Shadow Space above, 8 for return address)

    ;Determine length of string
    mov     rdi, rcx                    ; address of string to search
    xor     rax, rax                    ; search for null string terminator '\0'
    xor     rcx, rcx                    ; set max string length
    not     rcx
    cld                                 ; clear direction for forward search
    repne   scasb                       ; scan string byte by byte
    jnz     notFound                    ; ZF set, if match
    not     rcx                         ; rcx has position of match, so calculate length
    dec     rcx
    mov     [rsp + 38h], rcx			; save string length (arg 2 is just after arg 1

    ;Print to console
    CheckInit						; macro that checks that STD_OUTPUT handle initialized
    mov     rcx, consoleOutHandle		; set to value of STD_OUTPUT handle
    mov	  rdx, [rsp + 30h]			; string pointer
    mov     r8, [rsp + 38h]			; length of string
    lea	  r9, bytesWritten			; set to address of byteWritten
    mov     QWORD ptr [rsp + 4 * SIZEOF QWORD], 0	; (reserved parameter, set to zero)

    call    WriteConsoleA			; (handle, pointer, length, written, reserved )

notFound:                               ; don't print, if not null terminated
    add     rsp,(5 * 8)				; cleanup shadow space
    ret
PrintStringZ endp
;--------------------------------------------------------
; PrintFormat 
; Prints formatted output and up to 3 arguments
; Modifies: bytesWritten
; Receives: RCX points to the format string
; Returns: nothing
; Uses: RCX RDX R8 R9 RDI
;--------------------------------------------------------
PrintFormat proc
    sub     rsp, (4 * 8 + 8) 			; create shadow space for format plus 3 arguments
								; plus caller address (8 + 40 = 16*3 so it's aligned)
								; used by WriteConsoleA
    mov     [rsp + 30h], rcx			; save format string pointer (arg1 1 = 48 bytes back in the stack (40 for Shadow Space above, 8 for return address)
    mov     [rsp + 38h], rdx			; save first argument (arg 1 is just after format argument
    mov     [rsp + 40h], r8			
    mov     [rsp + 48h], r9			

    call    printf        			; bytesWritten = (format, arg1, arg2, arg3, arg4 )

    add     rsp,(4 * 8 + 8)				; cleanup shadow space
    ret
PrintFormat endp
end