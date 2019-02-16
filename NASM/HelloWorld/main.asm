	[bits 64]
	default rel

	global main
	extern ExitProcess
	extern GetStdHandle
	extern WriteFile

	section .text
main:
    ;align stack to 16 bytes for Win64 calls
    and rsp, -10h
    ;give room to Win64 API calls that don't take stack params
    sub rsp, 020h

    mov rcx, -0Bh   ;STD_OUTPUT_HANDLE
    call GetStdHandle
    mov rcx, rax
    mov rdx, message
    mov r8, msglen
    xor r9, r9
    push r9
    sub rsp, 20h ;Give Win64 API calls room
    call WriteFile
    add rsp, 28h ;Restore Stack Pointer
    mov rcx, 0
    call ExitProcess
    xor rax, rax
    ret

	section .data
message db 'Hello, World', 10
msglen equ $-message
