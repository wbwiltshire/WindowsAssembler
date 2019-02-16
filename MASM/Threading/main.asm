TITLE Multi-threading in x64 assembler
; Call uses MS X86_64 calling convention:
;        (return address)
;    RCX (parm1)           (00h)
;    RDX (parm2)           (08h)
;    R8  (parm3)           (10h)
;    R9  (parm4)           (18h)
;        (parm5)           (20h)
;        (parm6)           (28h)
;        (parm7)           (30h)
;        (parm8)           (38h)
;	Stack aligned on 16 byte boundaries

; External Windows function for process exit 
ExitProcess	   PROTO
CreateThread   PROTO
_sleep         PROTO

; Internal functions
PrintChar      PROTO
PrintString    PROTO
PrintStringZ   PROTO
PrintFormat    PROTO

;--------------------------------------------------------
; Data Segment 
;--------------------------------------------------------
.data
    valueMsg    BYTE    "Counter: %d", 0dh, 0ah, 0
    threadIdMsg BYTE    "ThreadId: %d", 0dh, 0ah, 0
    doneMsg     BYTE    "Done!", 0dh, 0ah, 0
    counter     QWORD   0
	handle      QWORD   0
	threadId    DWORD   ?

;--------------------------------------------------------
; Code Segment 
;--------------------------------------------------------
.code
main        PROC
    sub     rsp, (8*8 + 8)      ; Allocate 80 bytes of Shadow Space (8 parms * 8 bytes) + align it to 16 bytes 
                                ; (8 byte return address already on stack, so 8 + 64 + 8 = 16*5)
						
    ; Create Thread requires 8 parameters (hides thread handle at [rsp + 38h]
    lea     rax, threadId
    mov     QWORD ptr [rsp + 28h], rax   ; pointer to Thread Id (parm6)
    mov     DWORD ptr [rsp + 20h], 0     ; Creation flags (parm5), 0 means start immediately
    lea     r9, counter         ; pass pointer to counter to increment
    lea     r8, WorkerThread    ; Function to execute on new thread
    xor     rdx, rdx            ; Stack size with 0 meaning inherit parent size         
    xor     rcx, rcx            ; Security attibutes (default)
    call    CreateThread		  
    mov     [handle], rax       ; Thread handle in rax (parm8)
    
check:
    cmp     [counter], 0
    jne     print
    mov	    rcx, 100            ; sleep for 100ms
    call    _sleep
    jmp     check

    ; print result
print:
    mov     edx, [threadId]	
    lea     rcx, threadIdMsg
    call    PrintFormat
    lea     rcx, valueMsg
    mov     rdx, [counter]      	
    call    PrintFormat
done:
    ; write we're done
    lea     rcx, doneMsg
    call    PrintStringZ

    ;exit code is 0
    xor    rcx, rcx
    add    rsp, (8*8 + 8)       ; cleanup shadow space
    call   ExitProcess          ; exit to OS

main	ENDP
;--------------------------------------------------------
; Worker Thread
; Thread to do work 
; Modifies: none
; Receives: RCX pointer to integer to update
; Returns: none
; Uses: RAX
;--------------------------------------------------------
WorkerThread proc
    inc    DWORD ptr [rcx]         ; increment value passed as pointer
    xor    rax, rax                ; return success
    ret
WorkerThread endp
END