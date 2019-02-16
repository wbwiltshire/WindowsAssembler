TITLE Allocate Memory Dynamically

; External Windows function for process exit 
ExitProcess	PROTO

; Internal functions
PrintChar      PROTO
PrintString    PROTO
PrintStringZ   PROTO
PrintFormat    PROTO
AllocateMem	PROTO
FreeMem	     PROTO
StartClock     PROTO
ElapsedTime    PROTO

; Calls use MS X86_64 fast calling convention:
;	RCX (parm1)
;	RDX (parm2)
;	R8  (parm3)
;    R9  (parm4)
;	Stack aligned on 16 byte boundaries

.data
    elapsedMsg  BYTE    "Elapsed time %d(ms)", 0dh, 0ah, 0
    allocOKMsg  BYTE    "Allocated %d bytes successfully!", 0dh, 0ah, 0
    allocErrMsg BYTE    "Allocate error!", 0dh, 0ah, 0
    MemFreeMsg  BYTE    "Memory freed!", 0dh, 0ah, 0
    doneMsg     BYTE    "Done!", 0dh, 0ah, 0
    memPointer  QWORD   0

.code
main        PROC
    ;Don't need shadow space. It's handled in the functions
    ;sub     rsp, (4*8 + 8)      ; Allocate 32 bytes of Shadow Space (4 parms * 8 bytes) + align it to 16 bytes 
                                ; (8 byte return address already on stack, so 8 + 40 = 16*3)
						
    ; start elapsed time clock
    call    StartClock

    ; allocate 1MB of memory
    mov     rcx, 1024*1024*1024    ; 1GB	
    ;mov     rcx, 1024*1024*100     ; 100MB	
    ;mov     rcx, 1024*1024         ; 1MB	
    push    rcx
    call    AllocateMem
    mov     memPointer, rax
    pop     rcx
    
    ; display success or error message
    or      rax, rax
    jz      error
    lea     rcx, allocOKMsg
    mov     rdx, 1024*1024*1024    ; 1GB	
    ;mov     rdx, 1024*1024*100     ; 100MB	
    ;mov     rdx, 1024*1024         ; 1MB	
    call    PrintFormat	
    jmp     freeBlock
error:						
    lea     rcx, allocErrMsg
    call    PrintStringZ	
    jmp     done

    ; Free memory block
freeBlock:
    ; get elapsed time in rax
    call    ElapsedTime
    lea     rcx, elapsedMsg    
    mov     rdx, rax
    call    PrintFormat

    mov     rcx, memPointer
    call    FreeMem
    lea     rcx, MemFreeMsg
    call    PrintStringZ

done:
    ; write we're done
    mov     rcx, OFFSET doneMsg
    call    PrintStringZ

    ;exit code is 0
    ;add    rsp, (4*8 + 8)       ; cleanup shadow space
    xor    rcx, rcx
    call   ExitProcess          ; exit to OS

main	ENDP

END