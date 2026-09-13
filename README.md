# x86-64 Assembly Lessons

This is a course teaching x86-64 Windows assembly with MASM (`ml64.exe`), the
Microsoft calling convention, and the Windows linker. These programs avoid the C
runtime entirely.

## Course Roadmap

1. Toolchain and the Windows x64 ABI
   * MASM syntax, object files, linking, entry points
   * Registers, stack alignment, shadow space
   * Assignment: exit cleanly and return status codes
1. Calling Windows APIs without the CRT
   * Imports, `kernel32.lib`, API arguments and return values
   * Assignment: write text to standard output
1. Memory and data
   * `.data`, `.const`, `.code`, pointers, arrays
   * Assignment: implement string length and integer formatting
1. Control flow and procedures
   * Conditional branches, loops, stack frames, callee-saved registers
   * Assignment: command-line argument printer
1. Windows process startup
   * `GetCommandLineA`, `CommandLineToArgvW`, environment access
   * Assignment: a small argument-processing utility
1. File I/O
   * `CreateFileA`, `ReadFile`, `WriteFile`, `CloseHandle` 
   * Assignment: file copy or hex dump utility
1. Dynamic memory
   * `VirtualAlloc`, manual buffers, heap-free data structures
   * Assignment: dynamically growing text buffer
1. Debugging and reverse engineering
   * WinDbg or Visual Studio debugger, registers, stack, disassembly
   * Assignment: debug a deliberately broken program
1. PE structure and imports
   * Executable layout, sections, import tables, relocations
   * Assignment: inspect your own executable with available tooling
1. Advanced Windows assembly
   * Unicode APIs, callbacks, structured exception handling
   * Optional: direct NT calls and why they are fragile

## Project Structure

```text
.
├── .asm-lsp.toml
├── .git
├── .gitignore
├── build.ps1                          shared build script
├── glossary.txt                       assembly terminology
├── README.md
└── lessons/
    ├── 00-prerequisites/
    │   ├── README.txt                 getting started guide
    │   ├── lesson-1.txt               readiness for Lesson 1
    │   ├── lesson-2.txt               readiness for Lesson 2
    │   └── lesson-3.txt               readiness for Lesson 3
    ├── concepts/
    │   ├── windows-x64-calling-convention.txt
    │   ├── stack-alignment.txt
    │   └── caller-vs-callee-rsp.txt
    ├── 01-exit/
    │   ├── prerequisites.txt          readiness checklist
    │   ├── objectives.txt             learning goals
    │   ├── lesson.txt                 full explanation
    │   ├── common-mistakes.txt        error diagnosis
    │   ├── exercises.txt              tiered practice
    │   └── exit.asm
    ├── 02-console-output/
    │   ├── prerequisites.txt
    │   ├── objectives.txt
    │   ├── lesson.txt
    │   ├── common-mistakes.txt
    │   ├── exercises.txt
    │   └── hello.asm
    └── 03-string-length/
        ├── prerequisites.txt
        ├── objectives.txt
        ├── lesson.txt
        ├── common-mistakes.txt
        ├── exercises.txt
        └── string-length.asm
```

## Getting Started

1. Read `lessons/00-prerequisites/README.txt`
2. Read `lessons/00-prerequisites/lesson-1.txt`
3. Navigate to `lessons/01-exit/`
4. Read `prerequisites.txt`, then `objectives.txt`
5. Read `lesson.txt` and follow the build instructions
6. Work through `exercises.txt` (Tier 1 → 2 → 3)
7. Refer to `common-mistakes.txt` if you get stuck

## Lesson Files

Each lesson directory contains:

- **prerequisites.txt**: Verify you are ready before starting
- **objectives.txt**: Learning goals and success criteria
- **lesson.txt**: Full explanation with examples and diagrams
- **exercises.txt**: Three tiers of practice problems
- **common-mistakes.txt**: Error diagnosis and fixes
- **\*.asm**: Assembly source code

## Reference Files

- **lessons/concepts/**: Reusable reference documents on key topics
- **glossary.txt**: Assembly terminology
- **build.ps1**: Shared build script (works in any lesson directory)

## Building a Lesson

In any lesson directory:

```powershell
.\..\..\build.ps1
```

Or use the Visual Studio developer shell:

```powershell
ml64 /c /Fo lesson.obj lesson.asm
link /subsystem:console /entry:main lesson.obj kernel32.lib /out:lesson.exe
.\lesson.exe
```

