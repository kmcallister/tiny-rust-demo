# Using Rust to make a 145-byte static AMD64 Linux binary

Requires nightly Rust because it uses the `sc` crate to make direct
system calls.

`elf.s` contains a custom ELF header, but no instructions.
All of the machine code comes out of `rustc`. (Although all except one of the instructions that survive optimization *went in* as inline assembly.)

```
$ ./build.sh
Tested on rustc 1.30.0-nightly (f8d34596f 2018-08-30)
You have  rustc 1.30.0-nightly (f8d34596f 2018-08-30)

Cloning into 'syscall.rs'...
   Compiling sc v0.2.2 (file:///home/keegan/tiny-rust-demo/syscall.rs)      

+ rustc tinyrust.rs -O -C relocation-model=static -L syscall.rs/target/release
++ grep '.o$'
++ ar t libtinyrust.rlib
+ OBJECT=tinyrust.tinyrust.3a1fbbbh-cgu.0.rcgu.o
+ ar x libtinyrust.rlib tinyrust.tinyrust.3a1fbbbh-cgu.0.rcgu.o
+ objdump -dr tinyrust.tinyrust.3a1fbbbh-cgu.0.rcgu.o

tinyrust.tinyrust.3a1fbbbh-cgu.0.rcgu.o:     file format elf64-x86-64


Disassembly of section .text.main:

0000000000000000 <main>:
   0:	bf 01 00 00 00       	mov    $0x1,%edi
   5:	be 08 00 40 00       	mov    $0x400008,%esi
   a:	ba 07 00 00 00       	mov    $0x7,%edx
   f:	b8 01 00 00 00       	mov    $0x1,%eax
  14:	0f 05                	syscall 
  16:	31 ff                	xor    %edi,%edi
  18:	b8 3c 00 00 00       	mov    $0x3c,%eax
  1d:	0f 05                	syscall 
  1f:	0f 0b                	ud2    
+ echo


+ ld --gc-sections -e main -T script.ld -o payload tinyrust.tinyrust.3a1fbbbh-cgu.0.rcgu.o
+ objcopy -j combined -O binary payload payload.bin
++ nm --format=posix payload
++ awk '{print $3}'
++ grep '^main '
+ ENTRY=0000000000400070
+ nasm -f bin -o tinyrust -D entry=0x0000000000400070 elf.s
+ chmod +x tinyrust
+ hexdump -C tinyrust
00000000  7f 45 4c 46 02 01 01 09  48 65 6c 6c 6f 21 0a 00  |.ELF....Hello!..|
00000010  02 00 3e 00 01 00 00 00  70 00 40 00 00 00 00 00  |..>.....p.@.....|
00000020  38 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |8...............|
00000030  00 00 00 00 38 00 38 00  01 00 00 00 07 00 00 00  |....8.8.........|
00000040  00 00 00 00 00 00 00 00  00 00 40 00 00 00 00 00  |..........@.....|
00000050  00 00 40 00 00 00 00 00  91 00 00 00 00 00 00 00  |..@.............|
00000060  91 00 00 00 00 00 00 00  00 10 00 00 00 00 00 00  |................|
00000070  bf 01 00 00 00 be 08 00  40 00 ba 07 00 00 00 b8  |........@.......|
00000080  01 00 00 00 0f 05 31 ff  b8 3c 00 00 00 0f 05 0f  |......1..<......|
00000090  0b                                                |.|
00000091
+ wc -c tinyrust
145 tinyrust

$ ./tinyrust
Hello!
```
