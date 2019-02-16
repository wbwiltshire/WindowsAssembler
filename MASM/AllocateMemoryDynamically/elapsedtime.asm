TITLE Elapsed Time
; Call uses MS X86_64 calling convention:
;    RCX (parm1)
;    RDX (parm2)
;    R8  (parm3)
;    R9  (parm4)
;	Stack aligned on 16 byte boundaries

; External c library functions
_tzset        PROTO
_ftime64_s    PROTO
_time64       PROTO
;-------------------------------------------------------------
; Data Segment
;-------------------------------------------------------------

.data
    beginTime		 QWORD ?		; begin elapsed time
                     QWORD ? 
    endTime          QWORD ?     	; end elapsed time
                     QWORD ? 
    elapsed          WORD  0

;-------------------------------------------------------------
; Code Segment
;-------------------------------------------------------------
.code
;--------------------------------------------------------
; Start Elapsed Timer Clock 
; Starts the capture of elapsed time
; Modifies: none
; Receives: none
; Returns: none
; Uses: RCX
;--------------------------------------------------------
StartClock  proc
    sub     rsp, (4*8 + 8)  ; Allocate 32 bytes of Shadow Space (4 parms * 8 bytes) + align it to 16 bytes 
                            ; (8 byte return address already on stack, so 8 + 32 + 8 = 16*3)
                            ; for function call to GetStdHandle

    call    _tzset          ; Set time zone from TZ environment variable or OS

    ;save the begin time
    lea     rcx, beginTime  ; 
    call    _ftime64_s      ; (time_64 structure)
    
    add     rsp,(4*8 + 8)   ; cleanup shadow space
    ret
StartClock  endp
;--------------------------------------------------------
; Stoop Elapsed Timer Clock 
; Stops the capture of elapsed time and returns time
; Modifies: none
; Receives: none
; Returns: RAX number of milliseconds
; Uses: RCX
;--------------------------------------------------------
ElapsedTime proc
    sub     rsp, (4*8 + 8)  ; Allocate 32 bytes of Shadow Space (4 parms * 8 bytes) + align it to 16 bytes 
                            ; (8 byte return address already on stack, so 8 + 32 + 8 = 16*3)
                            ; for function call to GetStdHandle

    ;save the end time
    lea     rcx, endTime    ; 
    call    _ftime64_s      ; (time_64 structure)

    ;compare begin and end time
    mov     rax, QWORD ptr beginTime
    cmp     QWORD ptr endTime, rax
    jne     adjust
    movzx   eax, WORD ptr endTime+8
    movzx   ecx, WORD ptr beginTime+8
    sub     eax, ecx
    mov     WORD ptr elapsed, ax
    jmp     done
adjust:
    mov     ecx, 1000
    sub     ecx, eax
    mov     eax, ecx
    movzx   ecx, WORD ptr endTime+8
    add     eax, ecx
    mov     WORD ptr elapsed, ax
done:
    xor     eax, eax
    mov     ax, WORD ptr elapsed    ; return milliseconds in RAX
    
    add     rsp,(4*8 + 8)   ; cleanup shadow space
    ret

ElapsedTime endp
end
