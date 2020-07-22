# Using Rust to make a 137-byte static AMD64 Linux binary

[![Build Status](https://api.cirrus-ci.com/github/tormol/tiny-rust-executable.svg)](https://cirrus-ci.com/github/tormol/tiny-rust-executable)

Requires nightly Rust because it uses the `sc` crate to make direct
system calls.

`elf.s` contains a custom ELF header, but no instructions.
All of the machine code comes out of `rustc`.
(While most of the operations originate from inline assembly, LLVM replaces the instructions with more compact ones!)

```
$ ./build.sh
Tested on rustc 1.46.0-nightly (346aec9b0 2020-07-11)
You have  rustc 1.46.0-nightly (346aec9b0 2020-07-11)

Cloning into 'syscall.rs'...
   Compiling sc v0.2.3 (file:///home/tormol/p/rust/tiny-rust-executable/syscall.rs)

+ rustc tinyrust.rs --crate-type lib -L syscall.rs/target/release -C relocation-model=static -O -C opt-level=z
++ ar t libtinyrust.rlib
++ grep '.o$'
+ OBJECT=tinyrust.tinyrust.3a1fbbbh-cgu.0.rcgu.o
+ ar x libtinyrust.rlib tinyrust.tinyrust.3a1fbbbh-cgu.0.rcgu.o
+ objdump -dr tinyrust.tinyrust.3a1fbbbh-cgu.0.rcgu.o

tinyrust.tinyrust.3a1fbbbh-cgu.0.rcgu.o:     file format elf64-x86-64


Disassembly of section .text.main:

0000000000000000 <main>:
   0:	6a 07                	pushq  $0x7
   2:	5a                   	pop    %rdx
   3:	6a 01                	pushq  $0x1
   5:	58                   	pop    %rax
   6:	be 08 00 40 00       	mov    $0x400008,%esi
   b:	48 89 c7             	mov    %rax,%rdi
   e:	0f 05                	syscall 
  10:	6a 3c                	pushq  $0x3c
  12:	58                   	pop    %rax
  13:	31 ff                	xor    %edi,%edi
  15:	0f 05                	syscall 
  17:	0f 0b                	ud2    
+ echo

+ ld --gc-sections -e main -T script.ld -o payload tinyrust.tinyrust.3a1fbbbh-cgu.0.rcgu.o
+ objcopy -j combined -O binary payload payload.bin
++ nm --format=posix payload
++ grep '^main '
++ awk '{print $3}'
+ ENTRY=0000000000400070
+ nasm -f bin -o tinyrust -D entry=0x0000000000400070 elf.s
+ chmod +x tinyrust
+ hexdump -C tinyrust
00000000  7f 45 4c 46 02 01 01 09  48 65 6c 6c 6f 21 0a 00  |.ELF....Hello!..|
00000010  02 00 3e 00 01 00 00 00  70 00 40 00 00 00 00 00  |..>.....p.@.....|
00000020  38 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |8...............|
00000030  00 00 00 00 38 00 38 00  01 00 00 00 07 00 00 00  |....8.8.........|
00000040  00 00 00 00 00 00 00 00  00 00 40 00 00 00 00 00  |..........@.....|
00000050  00 00 40 00 00 00 00 00  89 00 00 00 00 00 00 00  |..@.............|
00000060  89 00 00 00 00 00 00 00  00 10 00 00 00 00 00 00  |................|
00000070  6a 07 5a 6a 01 58 be 08  00 40 00 48 89 c7 0f 05  |j.Zj.X...@.H....|
00000080  6a 3c 58 31 ff 0f 05 0f  0b                       |j<X1.....|
00000089
+ wc -c tinyrust
137 tinyrust

$ ./tinyrust
Hello!
```
