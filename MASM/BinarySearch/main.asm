INCLUDE c:\Irvine\Irvine32.inc

.data
        specifiedArray      SDWORD      -55, -4, 0, 1, 4, 10, 56, 101, 3
        msgArray            BYTE        "ARRAY: ", 0
        msgValueToSearch    BYTE        "VAL TO SEARCH: ", 0
        msgPosition         BYTE        "POSITION: ", 0
        msgNotFound         BYTE        "Value not found.", 0

.code

main PROC
        push    -55
        call    TestSearch
        push    56
        call    TestSearch
        push    102
        call    TestSearch

        call    WaitMsg
        push    0
        call    ExitProcess
main ENDP

TestSearch PROC
        push    ebp
        mov     ebp, esp
        push    eax
        push    ebx
        mov     ebx, [ebp + 8]  ; value to search

        lea     edx, msgArray
        call    WriteString
        call    OutputArray
        call    CrLf
        lea     edx, msgValueToSearch
        call    WriteString
        mov     eax, ebx
        call    WriteInt
        call    CrLf
        push    ebx
        push    LENGTHOF specifiedArray
        push    OFFSET specifiedArray
        call    BinarySearch
        cmp     eax, -1
        je      LNotFoundMessage
        lea     edx, msgPosition
        call    WriteString
        inc     eax
        call    WriteDec
        jmp     LExitTestSearch
LNotFoundMessage:
        lea     edx, msgNotFound
        call    WriteString

LExitTestSearch:
        call    CrLf
        call    CrLf
        pop     ebx
        pop     eax
        pop     ebp
        ret     4
TestSearch ENDP

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

BinarySearch PROC
        push    ebp
        mov     ebp, esp
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi
        mov     edi, [ebp + 16] ; value to search
        mov     edx, [ebp + 12] ; array size = last
        mov     ebx, [ebp + 8]  ; array offset

        xor     eax, eax        ; eax = first
        dec     edx
LSearch:
        ; while first <= last
        cmp     eax, edx
        jg      LNotFound

        ; mid = (last + first) / 2
        mov     ecx, edx
        add     ecx, eax
        shr     ecx, 1          ; ecx = mid

        ; edx = array[mid]
        mov     esi, ecx
        shl     esi, 2
        push    edx
        mov     edx, [ebx + esi]

        ; if array[mid] < search value
        ;   first = mid + 1
        cmp     edx, edi
        jge     LSearchBelow
        pop     edx
        mov     eax, ecx
        inc     eax
        jmp     LSearch

        ; elseif array[mid] > search value
        ;   last = mid - 1
LSearchBelow:
        cmp     edx, edi
        jle     LFound
        pop     edx
        mov     edx, ecx
        dec     edx
        jmp     LSearch

        ; else return mid
LFound:
        pop     edx
        mov     eax, ecx
        jmp     LExitBinarySearch
LNotFound:
        mov     eax, -1

LExitBinarySearch:
        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     ebp
        ret     12
BinarySearch ENDP

END main