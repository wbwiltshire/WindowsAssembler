INCLUDE c:\Irvine\Irvine32.inc

.data
        resultArray     DWORD   65000 DUP(0)
        valueN          DWORD   65000
        msgValueN       BYTE    "Value N: ", 0
        msgPrimes       BYTE    "Prime numbers < N: ", 0

.code

main PROC
        lea     edx, msgValueN
        call    WriteString
        mov     eax, valueN
        call    WriteDec
        call    CrLf
        lea     edx, msgPrimes
        call    WriteString
        call    CrLf
        push    OFFSET resultArray
        push    valueN
        call    SieveOfEratosthenes
        xor     eax, eax
        mov     ecx, LENGTHOF resultArray
        lea     edi, resultArray
        lea     esi, resultArray
LContinueOutput:
        repne   scasd
        or      ecx, ecx
        jz      LExit
        push    edi
        sub     edi, esi
        push    edi
        call    OutputPrime
        pop     edi
        jmp     LContinueOutput

LExit:
        call    CrLf
        call    CrLf
        call    WaitMsg
        push    0
        call    ExitProcess
main ENDP

WriteSpace PROC
        mov     al, ' '
        call    WriteChar

        ret
WriteSpace ENDP

OutputPrime PROC
        push    ebp
        mov     ebp, esp
        pushad
        mov     eax, [ebp + 8]

        xor     edx, edx
        mov     ebx, 4
        div     ebx
        call    WriteDec
        call    CrLf

        popad
        pop     ebp
        ret     4
OutputPrime ENDP

SieveOfEratosthenes PROC
        push    ebp
        mov     ebp, esp
        pushad
        mov     esi, [ebp + 12] ; array of numbers
        mov     ecx, [ebp + 8]  ; value n

        xor     eax, eax
        mov     [esi], eax
        dec     ecx
        mov     edx, 1
LNextNumber:
        add     esi, 4
        inc     edx
        mov     eax, [esi]
        or      eax, eax
        jnz     LContinueSieving
        push    esi
        push    edx
        push    ecx
        call    MarkCells
LContinueSieving:
        loop    LNextNumber

        popad
        pop     ebp
        ret     8
SieveOfEratosthenes ENDP

MarkCells PROC
        push    ebp
        mov     ebp, esp
        pushad
        mov     esi, [ebp + 16] ; array of numbers
        mov     ebx, [ebp + 12] ; num to check
        mov     ecx, [ebp + 8]  ; repeats

        dec     ecx
        mov     edx, ebx
LCheckNextCell:
        add     esi, 4
        inc     edx
        mov     eax, edx
        push    edx
        xor     edx, edx
        div     ebx
        or      edx, edx
        jnz     LContinueCheck
        mov     eax, 1
        mov     [esi], eax
LContinueCheck:
        pop     edx
        loop    LCheckNextCell

        popad
        pop     ebp
        ret     12
MarkCells ENDP

END main