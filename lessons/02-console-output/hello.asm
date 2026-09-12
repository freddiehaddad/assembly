option casemap:none

; This is the documented Windows standard output device.
; https://learn.microsoft.com/en-us/windows/console/getstdhandle
STD_OUTPUT_HANDLE equ -11

.data

message db "Hello from x64 assembly!", 13, 10 ; 13, 10: CR LF ASCII
message_length equ $ - message

.code

extern GetStdHandle:proc
extern WriteFile:proc
extern ExitProcess:proc

main proc
	; Caller-side layout after SUB:
	;   [rsp+00h..rsp+1Fh]  20h shadow space
	;   [rsp+20h..rsp+27h]  08h fifth argument
	;   [rsp+28h..rsp+2Fh]  08h bytes-written local slot
	;   [rsp+30h..rsp+37h]  08h unused alignment padding
	; RSP points at the low-address end; positive offsets move upward.
	; 30h is storage; the extra 08h makes the call-site RSP aligned.
	sub rsp, 38h

	; GetStdHandle(STD_OUTPUT_HANDLE)
	mov ecx, STD_OUTPUT_HANDLE
	call GetStdHandle

	; WriteFile(
	;	stdout_handle,
	;	message,
	;	message_length,
	;	&bytes_written
	;	NULL
	; )
	mov rcx, rax
	lea rdx, message
	mov r8d, message_length
	lea r9, [rsp+28h]
	; This is the caller's [rsp+20h]. After CALL pushes the return
	; address, WriteFile sees this same fifth argument at [rsp+28h].
	mov qword ptr [rsp+20h], 0
	call WriteFile

	; ExitProcess(0)
	xor ecx, ecx
	call ExitProcess
main endp

end
