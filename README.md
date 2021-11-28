
## Calling Convention

You can think of a calling convention as a standard for how functions in a program communicate.  This agreed upon standard includes:

* How parameters are passed from the caller to the callee
* Which registers the callee must preserve for the caller
* How the program flow from one function to another will happen
* How a stack frame will be created and destroyed

## Address Space

One common layout of a program in memory:

```text
Low Memory      +-----------+
                |   Text    |    Program Instructions
                +-----------+
                |   Data    |    Initialized Global Variables
                +-----------+
                |    BSS    |    Uninitialized Global Variables
                +-----------+
                |   Heap    |    Dynamically Allocated Memory
                |     |     |
                |     v     |
                |           |
                |     ^     |
                |     |     |
                |   Stack   |    Runtime Stack
High Memory     +-----------+
```

In this layout the runtime stack grows from high memory to low memory and any dynamically allocated memory grows from low memory towards high memory.  More simply put, the heap and the stack grow towards each other.

## Function Call Process

Let's first consider the things that need to happen when one function needs to call another.

1. Caller needs to make available to the callee any arguments required by that function
   * Parameters need to be passed in some standardized way
1. Caller needs to preserve any registers that the callee might overwrite if needed
1. Caller needs a way to call that function
   * The instruction pointer needs to jump from the current function to the called function
   * When the called function returns program execution must continue where it left off
1. Callee needs to create a new stack frame
   * Any callee saved registers must be preserved if they are to be used
   * Space needs to be allocated for local variables if needed 
1. Callee needs to access the arguments
1. Callee needs to put the return value somewhere for the caller to find it
1. Callee needs destroy its stack frame
1. Callee needs to restore the callers stack frame

There's a lot to unpack here.  Let's examine how this happens step-by-step or (instruction by instruction).

We'll describe two function prototypes `foo` and `bar` using a higher level language and translate their behavior into Assembly instructions following the interface and conventions above.

```C
int foo(int _a, int _b)
{
	int a;
	int b;
	int c;

	a = _a;
	b = _b;

	c = a + b;
	return c;
}

int bar()
{
	int a;
	int b;
	int c;
	
	a = 1;
	b = 2;

	c = foo(a, b);

	return c;
}
```

For simplicity, we will assume ILP-64 -- meaning integers and pointers are all 64-bit (8 bytes).  Program flow will be captured starting inside `bar`, ignoring how we got to this point.  We'll walk through the calling convention from here.

If we were to imagine the stack at the moment program flow moves to `bar`, it might look like this:

```text
bar            +--------+
          rsp  | rip    |
               .        .
               .        .
               .        .  rbp
```

The instruction at the point the call to `bar` was made (in the instruction pointer) is at the top of the previous function's call stack.  This happened as a result of the `call` instruction which saves the value in the `rip` register on the stack and moves the stack pointer `rsp`.  Lastly, the instruction pointer register is set to the address of `bar`.

Thinking about how we got to `bar`, the stack pointer and the base pointer registers represent the caller's stack frame.  The values in those registers need to be preserved because `bar` must create its own stack frame, use it for its work, destroy it when finished, and restore the caller's stack frame.

Looking at the definition of `bar`, we can see the function defines three local variables (`a`, `b`, and `c`), calls `foo` with `a` and `b` as the arguments, stores the return value in `c`, and returns that value to the caller.

Let's start by setting up the stack frame.  We need to save the caller's base pointer `rbp` value.  This is achieved by using the `push` instruction.

```Assembly
push    %rbp
```

The push operation allocates space on the stack to hold the value of the `rbp` register and stores its value.  The stack frame after this instruction looks like this:

```text
          rsp  | rbp    |
bar            +--------+
               | rip    |
               .        .
               .        .
               .        .  rbp
```

Now that we saved the value in the `rbp` register, we need to update it to reflect the base of `bar`'s stack frame.  This can be achieved with the `movq` instruction.

```Assembly
movq     %rsp, %rbp
```

We move the value of the stack pointer `rsp` into the base pointer `rbp` since this will be the start of `bar`'s stack frame.

The layout now:

```text
     rsp, rbp  | rbp    |
bar            +--------+
               | rip    |
               .        .
               .        .
               .        .
```

Now we need to allocate space on the stack for the three local variables (`a`, `b`, and `c`).  Remembering that we are treating all values at 64-bit (8 bytes), we need increase the size of our stack frame to 24 bytes.  We can do this by subtracting 24 from the value in the stack pointer.

Recall that the stack grows from high to low memory towards the heap.  In other words, the top of the stack is approaching zero as it grows.  Hence, the reason for the subtraction.  As a side note, you could also use the `add` instruction to add -24 to the stack pointer.

```Assembly
sub     $24, %rsp
```

or

```Assembly
add     $-24, %rsp
```

We have now allocated space on the stack for `bar`'s local variables:

```text
          rsp  | a      |
               | b      |
               | c      |
          rbp  | rbp    |
bar            +--------+
               | rip    |
               .        .
               .        .
               .        .
```

Next, we need to assign the values `1` and `2` to `a` and `b`, respectively.  Looking at the `rsp` register, we can see that it's already pointing to the top of the stack. This is where `a` is.  Since `b` is adjacent to `a` in memory, it's 8 bytes past `a`.  With the top of the stack at a lower memory address than the bottom, the offsets to the local variables are positive from the stack pointer.

With all that in mind, we can assign the values:

```Assembly
movq     $1, 0(%rsp)
movq     $2, 8(%rsp)
```

Note: The X64 Intel/AMD processors have general purpose registers that can be used instead of allocating memory on the stack.  Storing the values on the stack is purely for educational purposes.

We are now ready to set up the call to `foo`.

As per the AMD64 calling convention, the following registers are used for the first two arguments to a function:

* `rdi` is used for the first argument
* `rsi` is used for the second argument

This can be achieved as follows:

```Assembly
movq    0(%rsp), %rdi
movq    8(%rsp), %rsi
```

With the arguments now in the proper registers, we are ready to call `foo`.  This can be done with the `call` instruction:

```Assembly
call    foo
```

After the call to `foo`, the instruction pointer `rip` is pointing to the function `foo` and the runtime stack now looks like this:

```text
foo            +--------+
          rsp  | rip    |
               | a      |
               | b      |
               | c      |
          rbp  | rbp    |
bar            +--------+
               | rip    |
               .        .
               .        .
               .        .
```

Recall that the instruction `call` saves the value in the instruction pointer `rip` register on the stack and adjusts the stack pointer.

Looking at the definition of `foo`, we can see that it needs three integers (`a`, `b`, and `c`) just like `bar`.  Following in the same steps as we did when entering `bar`, we would do the following:

```Assembly
push    %rbp
movq    %rsp, %rbp
sub     $24, %rsp
```

At the end of this sequence of instructions, the stack now looks like this:

```text
          rsp  | a      |
               | b      |
               | c      |
          rbp  | rbp    |
foo            +--------+
               | rip    |
               | a      |
               | b      |
               | c      |
          rbp  | rbp    |
bar            +--------+
               | rip    |
               .        .
               .        .
               .        .
```

Next, we need to get the arguments `a` and `b` which the function expects and were passed in the `rdi` and `rsi` registers.  The first thing `foo` does is assign these values to its local variables.

```Assembly
movq    %rdi, 0(%rsp)
movq    %rsi, 8(%rsp)
```

Adding the two values is slightly interesting because the `add` instruction only takes two arguments -- the operands.  The second operand is updated with the result of the operation.

You can think of

```Assembly
add     %rdi, %rsi
```

as

```text
rsi = rdi + rsi
```

Now that `rsi` has the result of the operation, assigning it to `c` is achieved with a `movq` operation.

```Assembly
movq    %rsi, 16(%rsp)
```

Finally, `foo` needs to return the value to the caller.  This is handled by placing the return value in the `rax` register.

```Assembly
movq    %rsi, %rax
```

or

```Assembly
movq   16(%rsp), %rax
```

With the return value placed in the proper register, it's time to tear down the stack and return to the caller.

To accomplish this, a few things need to happen:

1. We need to tear down the stack
2. Restore the previous values in the `rsp` and `rbp` registers
3. Update the instruction pointer (`rip`) to the next instruction in the caller's function

Let's start with restoring the stack by thinking about how we created it.

The instructions

```Assembly
push    %rbp
movq    %rsp, %rbp
sub     $24, %rsp
```

resulted in 

```text
          rsp  | a      |
               | b      |
               | c      |
          rbp  | rbp    |
foo            +--------+
```

which is `foo`'s stack.

In essence if we undo the three actions we took when creating the stack frame, we should be able to restore it.

Thus,

```Assembly
add     $24, %rsp
movq    %rbp, %rsp
pop     %rbp
```

would suffice to achieve our goal returning us to the moment we entered `foo`.

However, one observation reveals a minor optimization saving us the step of executing the `add` instruction.

Notice how the instruction

```Assembly
movq     %rbp, %rsp
```

automatically collapses the stack frame by setting the `rsp` register to the same value as `rbp`.  The `add` happened implicitly as a result of the `movq` instruction.

The `pop` instruction is doing two things that must be noted:

1. Writes the value at the top of the stack to the specified register (in this case `rbp`)
2. Adjusts the stack pointer `rsp` register value to point to the next element on the stack 

As another side note, the two instructions can actually be reduced to a single instruction `leave` which does the same thing.

So, our final solution to the problem of restoring the stack frame can be reduced to:

```Assembly
movq    %rbp, %rsp
pop     %rbp
```

or

```Assembly
leave
```

partially restoring the stack to our desired state:

```text
foo            +--------+
          rsp  | rip    |
               | a      |
               | b      |
               | c      |
          rbp  | rbp    |
bar            +--------+
               | rip    |
               .        .
               .        .
               .        .
```

With `foo`'s stack frame destroyed, we are almost finished.  The last step `foo` needs to take is returning control back to the caller.  We can accomplish this with the `ret` instruction.

```Assembly
ret
```

The `ret` instruction is equivalent to popping the next value off the stack and placing it in the instruction pointer `rip` register.

After the `ret` instruction is executed, our stack frame is restored:

```text
          rsp  | a      |
               | b      |
               | c      |
          rbp  | rbp    |
bar            +--------+
               | rip    |
               .        .
               .        .
               .        .
```

Alas, we are back inside `bar` with all registers restored and the return value ready for us in the `rax` register.  The last two steps of `bar` include assign the return value from `foo` to it's local variable `c` and returning that value to the caller.

Since the return value is already in the `rax` register and bar doesn't make any changes to it, the return value is already set.  Therefore, all we need to do is assign the the return value to our local variable `c`.

```Assembly
movq    %rax, 16(%rsp)
```

Tearing down `bar`'s stack is the same as what we did in `foo`'s stack.

```Assembly
leave
ret
```

With those instructions exectued, flow has now returned to the `bar`'s caller and the program contines executing.

```text
          rsp  .        .
               .        .
               .        .  rbp
```
