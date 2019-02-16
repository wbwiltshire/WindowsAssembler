INCLUDE c:\Irvine\Irvine32.inc

.data
        specifiedArray      SDWORD       4, 2, -1, 10, 20, 0, 1
        msgOrigin           BYTE         "ORIGINAL: ", 0
        msgSorted           BYTE         "SORTED: ", 0

.code

main PROC
        lea     edx, msgOrigin
        call    WriteString
        call    OutputArray
        call    CrLf
        lea     edx, msgSorted
        call    WriteString
        push    OFFSET specifiedArray
        push    LENGTHOF specifiedArray
        call    BubbleSort
        call    OutputArray

        call    CrLf
        call    CrLf
        call    WaitMsg
        push    0
        call    ExitProcess
main ENDP

OutputArray PROC
        pushad

        mov     ecx, LENGTHOF specifiedArray
        lea     edi, specifiedArray
LNextElement:
        mov     eax, [edi]
        call    WriteInt
        mov     al, ' '
        call    WriteChar
        add     edi, 4
        loop    LNextElement

        popad
        ret     0
OutputArray ENDP

BubbleSort PROC
        push    ebp
        mov     ebp, esp
        sub     esp, 4          ; local: exchange flag
        pushad
        mov     ecx, [ebp + 8]  ; array size

        dec     ecx
LArrayTraversal:
        push    ecx
        xor     ebx, ebx
        mov     [ebp - 4], ebx  ; exchange flag = 0
        mov     esi, [ebp + 12] ; array offset
LNextElementsPair:
        mov     eax, [esi]
        cmp     [esi + 4], eax
        jge     LContinueTraversal
        mov     ebx, 1
        mov     [ebp - 4], ebx  ; exchange flag = 1
        xchg    eax, [esi + 4]
        mov     [esi], eax
LContinueTraversal:
        add     esi, 4
        loop    LNextElementsPair
        pop     ecx
        xor     ebx, ebx
        cmp     [ebp - 4], ebx
        je      LExitBubbleSort
        loop    LArrayTraversal

LExitBubbleSort:
        popad
        mov     esp, ebp
        pop     ebp
        ret     8
BubbleSort ENDP

END main