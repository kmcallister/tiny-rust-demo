# Using Rust to make a 151-byte static AMD64 Linux binary

`elf.s` contains a custom ELF header, but no instructions.  All of the machine
code comes out of `rustc`.  (Although all of the instructions that survive
optimization *went in* as inline assembly.)

```
$ ./build.sh
Tested on rustc 1.0.0-dev (44a287e6e 2015-01-08 17:03:40 -0800)
You have  rustc 1.0.0-dev (44a287e6e 2015-01-08 17:03:40 -0800)

Cloning into 'syscall.rs'...
   Compiling syscall v0.1.0 (file:///home/keegan/tiny-rust-demo/syscall.rs)

+ rustc tinyrust.rs -O -C no-stack-check -C relocation-model=static -L syscall.rs/target
+ ar x libtinyrust.rlib tinyrust.o
+ objdump -dr tinyrust.o

tinyrust.o:     file format elf64-x86-64


Disassembly of section .text.main:

0000000000000000 <main>:
   0:	b8 01 00 00 00       	mov    $0x1,%eax
   5:	bf 01 00 00 00       	mov    $0x1,%edi
   a:	be 08 00 40 00       	mov    $0x400008,%esi
   f:	ba 07 00 00 00       	mov    $0x7,%edx
  14:	0f 05                	syscall
  16:	b8 3c 00 00 00       	mov    $0x3c,%eax
  1b:	31 ff                	xor    %edi,%edi
  1d:	0f 05                	syscall
+ echo

+ ld --gc-sections -e main -T script.ld -o payload tinyrust.o
+ objcopy -j combined -O binary payload payload.bin
++ nm -f posix payload
++ grep '^main '
++ awk '{print $3}'
+ ENTRY=0000000000400078
+ set -x
+ nasm -f bin -o tinyrust -D entry=0x0000000000400078 elf.s
+ chmod +x tinyrust
+ hd tinyrust
00000000  7f 45 4c 46 02 01 01 00  48 65 6c 6c 6f 21 0a 00  |.ELF....Hello!..|
00000010  02 00 3e 00 01 00 00 00  78 00 40 00 00 00 00 00  |..>.....x.@.....|
00000020  40 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |@...............|
00000030  00 00 00 00 40 00 38 00  01 00 00 00 00 00 00 00  |....@.8.........|
00000040  01 00 00 00 07 00 00 00  00 00 00 00 00 00 00 00  |................|
00000050  00 00 40 00 00 00 00 00  00 00 40 00 00 00 00 00  |..@.......@.....|
00000060  97 00 00 00 00 00 00 00  97 00 00 00 00 00 00 00  |................|
00000070  00 10 00 00 00 00 00 00  b8 01 00 00 00 bf 01 00  |................|
00000080  00 00 be 08 00 40 00 ba  07 00 00 00 0f 05 b8 3c  |.....@.........<|
00000090  00 00 00 31 ff 0f 05                              |...1...|
00000097
+ wc -c tinyrust
151 tinyrust

$ ./tinyrust
Hello!
```

# See also

* [A very synthetic, but very small hello world on Go (99 bytes, i386)](https://github.com/xaionaro-go/tinyhelloworld).
