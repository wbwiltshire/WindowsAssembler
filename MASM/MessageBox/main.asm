TITLE ASM Hello World Win64 MessageBox

extrn MessageBoxA: PROC
extrn ExitProcess: PROC

.data
caption db 'Win64', 0
msg db 'Hello World!', 0

.code
main proc
  add rsp, (4*8 + 8)	; create shadow space  
  mov rcx, 0       ; hWnd = HWND_DESKTOP
  lea rdx, msg     ; LPCSTR lpText
  lea r8,  caption ; LPCSTR lpCaption
  mov r9d, 0       ; uType = MB_OK
  call MessageBoxA
  add rsp, 28h  
  mov ecx, eax     ; uExitCode = MessageBox(...)

	; exit code is 0
  add rsp, (4*8 + 8)	; cleanup shadow space
  ;xor rcx, rcx		; return the uExcitCode above
  call ExitProcess
main endp

End