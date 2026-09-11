option casemap:none

extern ExitProcess:proc

.code ; code section, analogous to the text segment in Unix terminology

main proc ; procedure named main; /entry:main selects it as the entry symbol
	; Reserve 20h (32) bytes of shadow space plus 08h of alignment padding.
	; 28h is the total subtraction, not an argument offset.
	sub rsp, 28h
	mov ecx, 42
	call ExitProcess
main endp ; end of the procedure named main

end ; marks the end of the MASM source file
