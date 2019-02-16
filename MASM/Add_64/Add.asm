; AddTwoSum_64.asm

; Don't need this line for ml64.exe assembler
;.model	flat, stdcall

ExitProcess proto
.data
sum qword 0
.code
main proc
   mov  rax,5
   add  rax,6
   mov  sum,rax

   mov  ecx,0
   call ExitProcess
main endp
end