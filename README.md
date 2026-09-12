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

## Project Structure

```text
.
├── .asm-lsp.toml
├── .git
├── .gitignore
├── lessons
│   ├── 01-exit
│   │   ├── exit.asm
│   │   └── lesson.txt
│   └── 02-console-output
│       ├── hello.asm
│       └── lesson.txt
└── README.md
```
