# x86-64 Assembly and Systems Programming

Learn how instructions operate on data, how procedures cooperate, and how a
program uses operating-system services. The target is Windows x64, using MASM
(`ml64.exe`), Microsoft's linker, and the standard Windows x64 calling convention.

The examples deliberately omit the C runtime (CRT) and use Windows APIs directly
so that startup and library boundaries are visible. This is a dependency choice,
not a different instruction set or calling convention. Lesson 1 explains where
runtime startup would otherwise fit.

## Keep the layers separate

| Layer | What it defines | Example |
| --- | --- | --- |
| Instruction set (ISA) | CPU operations and their effects | `call`, `mov`, registers, addressing |
| Assembler notation | How we express instructions and data | MASM's `qword ptr`, `db`, `proc` |
| Calling convention (ABI) | How separately written procedures cooperate | Argument registers, shadow space, preservation |
| Operating-system API | Services available to the program | `WriteFile`, `ExitProcess` |

Do not confuse a convention with a CPU requirement, or an assembler directive
with an instruction. Each lesson identifies the layer responsible for a rule.

## Lessons

| Lesson | Main ideas | Program or assignment |
| --- | --- | --- |
| 1. `lessons\01-exit` | Toolchain, register widths, entry and termination, first call frame | Return a chosen exit status |
| 2. `lessons\02-console-output` | Bytes and addresses, API types, stack arguments and output parameters | Write a byte buffer to standard output |
| 3. `lessons\03-string-length` | String representation, loop invariants, procedure contracts, volatile registers | Implement and test string length |

Lessons 1-3 contain the student's completed programs.

Later topics will include bounded buffers, integer representation and formatting,
Unicode and argument vectors, file I/O, memory allocation, debugging, and PE
structure. These are a roadmap, not prerequisites for the current exercises.

## How to study

Start at `lessons\01-exit\prerequisites.txt`. Prerequisites live only in their
lesson directories. In each lesson:

1. Check `prerequisites.txt` and read the goals in `objectives.txt`.
2. Read `lesson.txt`, predicting the checkpoint results before running code.
3. Read the accompanying `.asm` worked example.
4. Work through `exercises.txt`: observe, explain, then implement.
5. Use `common-mistakes.txt` to diagnose discrepancies.

The core exercises define completion; extension exercises are optional. A
working executable is necessary but not sufficient: explain its data, register,
and stack behavior. This course is being refined with its first student. Review
the student's exercise before committing a new lesson; preparation alone does
not mark it complete.

## Build and run

Use a Visual Studio developer PowerShell configured for the x64 tools and Windows
SDK. The script uses that environment; it does not initialize Visual Studio.

From a lesson directory:

```powershell
..\..\build.ps1 -Source exit.asm -NoRun
.\exit.exe
$LASTEXITCODE
```

Substitute the lesson's source name. `-Source` may be omitted only when the current
directory contains exactly one `.asm` file. Without `-NoRun`, the script also runs
the executable and returns its exit status. A deliberate status such as 42 in
Lesson 1 is not an assembly or link failure.

Builds include debug information by default. Use `-NoDebug` to omit it.
`-NoRun` only controls execution, so it works with either build mode. To prepare
an executable for WinDbgX, use `-NoRun` as above; the script does not launch a
debugger.

An older `.pdb` can remain beside a `-NoDebug` build; the new executable does
not reference it.

For an equivalent manual debug build:

```powershell
ml64 /nologo /Zi /c /Fo exit.obj exit.asm
link /nologo /machine:x64 /subsystem:console /entry:main /nodefaultlib `
     /incremental:no /debug /pdb:exit.pdb exit.obj kernel32.lib /out:exit.exe
```

To omit debug information manually, omit `/Zi`, `/debug`, and `/pdb:exit.pdb`.
Use the manual linker command when an exercise changes the entry symbol.

For a first debugging session, follow `lessons\concepts\windbg.txt`. It walks
through WinDbgX startup, symbols, breakpoints, and instruction-level stepping
using `exit.exe` from lesson 1.

## References and file conventions

`glossary.txt` defines terminology. The documents in `lessons\concepts` cover the
calling convention, alignment calculations, changing RSP viewpoints, and using
WinDbg. They are references to consult as needed, not required cover-to-cover
reading before Lesson 1. Links in lesson text are relative to that text's folder.

Repository text is ASCII with CRLF line endings and no byte-order mark.
`.gitattributes` specifies CRLF working copies; Git may store normalized LF
internally. `.editorconfig` supplies matching editor settings. Neovim's
`fileformat` should be `dos`.
