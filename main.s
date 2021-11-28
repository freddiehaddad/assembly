	.section .text
foo:
	push	%rbp
	movq	%rsp, %rbp
	sub	$24, %rsp       # int a;
				# int b;
				# int c;

	movq	%rdi, 0(%rsp)   # a = _a;
	movq	%rsi, 8(%rsp)   # b = _b;

	add	%rdi, %rsi	# c = a + b;
	movq	%rsi, 16(%rsp)
	
	movq	%rsi, %rax	# return c;
	movq	%rbp, %rsp
        pop	%rbp
	ret

bar:
	push	%rbp
	movq	%rsp, %rbp
	sub	$24, %rsp	# int a;
				# int b;
				# int c;
	
	movq	$1, 0(%rsp)	# a = 1;
	movq	$2, 8(%rsp)	# b = 2;

	movq	0(%rsp), %rdi	# foo(a, b);
	movq	8(%rsp), %rsi
	call	foo

	movq	%rax, 16(%rsp)	# c = foo(a, b);

	leave			# return c;
	ret

	.global	main
main:
	push	%rbp
	movq	%rsp, %rbp

	call	bar

	leave
	ret
	
