TITLE Allocate Memory Dynamically

; External c library function
malloc    PROTO
free      PROTO

; Call uses MS X86_64 calling convention:
;    RCX (parm1)
;    RDX (parm2)
;    R8  (parm3)
;    R9  (parm4)
;	Stack aligned on 16 byte boundaries

;--------------------------------------------------------
; AllocateMem 
; Allocates a block of memory
; Modifies: none
; Receives: RCX has number of bytes of memory to allocate
; Returns: RAX address of memory block; 0 if error
; Uses: RAX
;--------------------------------------------------------
.code
AllocateMem proc 
    sub     rsp, (4*8 + 8)  ; Allocate 32 bytes of Shadow Space (4 parms * 8 bytes) + align it to 16 bytes 
                            ; (8 byte return address already on stack, so 8 + 32 + 8 = 16*3)
                            ; for function call to GetStdHandle

    call    malloc          ; library call: ptr = malloc(bytes to allocate)
                            ; RAX is either memory block address or 0, if error
									
    add     rsp,(4*8 + 8)   ; cleanup shadow space
    ret
AllocateMem ENDP
;--------------------------------------------------------
; FreeMem 
; Frees a block of memory
; Modifies: none
; Receives: RCX has pointer to memory to free
; Returns: Nothing
; Uses: Nothing
;--------------------------------------------------------FreeMem proc 
FreeMem proc 
    sub     rsp, (4*8 + 8)	; Allocate 32 bytes of Shadow Space (4 parms * 8 bytes) + align it to 16 bytes 
                            ; (8 byte return address already on stack, so 8 + 32 + 8 = 16*3)
                            ; for function call to GetStdHandle

    call    free            ; library call: ptr = free(ptr)
									
    add     rsp,(4*8 + 8)   ; cleanup shadow space
    ret
FreeMem ENDP
end
