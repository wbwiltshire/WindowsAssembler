INCLUDE c:\Irvine\Irvine32.inc

.data
    	specifiedArray     DWORD    56, 12, 44, -3, 21, 0, 1        

.code

main PROC
        mov     esi, OFFSET specifiedArray
        mov     ecx, LENGTHOF specifiedArray
        call    ArraySum

        call    WriteDec
        invoke  ExitProcess, 0
main ENDP

ArraySum PROC USES esi ecx
; RECIEVES: esi: dword array offset
;           ecx: quantity of elements in a dword array
; RETURNS:  eax: sum of array elements 
        xor     eax, eax

AddElem:
        add     eax, [esi]
        add     esi, 4
        loop    AddElem

        ret  
ArraySum ENDP

END main