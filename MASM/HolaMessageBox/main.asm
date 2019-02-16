TITLE ASM Hola World Win64 MessageBox
; Link: https://docs.microsoft.com/en-us/cpp/windows/walkthrough-creating-windows-desktop-applications-cpp
;       http://lallouslab.net/2016/01/11/introduction-to-writing-x64-assembly-in-visual-studio/

; Calls use MS X86_64 calling convention:
;	RCX (parm1)
;	RDX (parm2)
;	R8  (parm3)
;   R9  (parm4)
;	Stack aligned on 16 byte boundaries

extrn GetForegroundWindow: PROC
extrn MessageBoxA: PROC
extrn ExitProcess: PROC

.data
caption db 'Windows GUI - Assembly x64', 0
msg db 'Hola World!', 0

.code
main proc
	add  rsp, (4*8 + 8)		; create shadow space  
	
    ; Get the window handle and return in rax
    call GetForegroundWindow
	
    ; WINUSERAPI int WINAPI MessageBoxA(
    ;  RCX =>  HWND hWnd,
    ;  RDX =>  LPCSTR lpText,
    ;  R8  =>  LPCSTR lpCaption,
    ;  R9  =>  UINT uType);
    mov  rcx, rax           ; Parent window handle (hWnd = HWND_DESKTOP)
	lea  rdx, msg     		; Text to display in message box (LPCSTR lpText)
	lea  r8, caption 		; Message box caption (LPCSTR lpCaption)
	mov  r9, 0       		; Message box response type (uType = MB_OK)
	call MessageBoxA
	add  rsp, 28h			; restore stack frame from called proc  
	mov  ecx, eax     		; Move return code to eax (uExitCode = MessageBox(...))

	; exit code is 0
	;xor rcx, rcx			; return the exit code from above

	add rsp, (4*8 + 8)		; cleanup shadow space
  
	call ExitProcess		; return to Operating System

main endp
End