# Using Rust to make a 137-byte static AMD64 Linux binary

[![Build Status](https://api.cirrus-ci.com/github/tormol/tiny-rust-executable.svg)](https://cirrus-ci.com/github/tormol/tiny-rust-executable)

Requires nightly Rust because it uses the `sc` crate to make direct
system calls.

`elf.s` contains a custom ELF header, but no instructions.
All of the machine code comes out of `rustc`.
(While most of the operations originate from inline assembly, LLVM replaces the instructions with more compact ones!)

```sh
$ ./build.sh
Tested on rustc 1.46.0-nightly (346aec9b0 2020-07-11)
You have  rustc 1.46.0-nightly (346aec9b0 2020-07-11)

+ cargo build --release --verbose
  Downloaded sc v0.2.3
  Downloaded 1 crate (37.2 KB) in 0.71s
   Compiling sc v0.2.3
     Running `rustc --crate-name sc /home/tormol/.cargo/registry/src/github.com-1ecc6299db9ec823/sc-0.2.3/src/lib.rs --error-format=json --json=diagnostic-rendered-ansi,artifacts --crate-type lib --emit=dep-info,metadata,link -C opt-level=z -C panic=abort -Cembed-bitcode=no -C metadata=8fa96b43c9d094b0 -C extra-filename=-8fa96b43c9d094b0 --out-dir /home/tormol/p/rust/tiny-rust-demo/target/release/deps -L dependency=/home/tormol/p/rust/tiny-rust-demo/target/release/deps --cap-lints allow -C relocation-model=static`
   Compiling tiny-rust-executable v0.5.0 (/home/tormol/p/rust/tiny-rust-executable)
     Running `rustc --crate-name tinyrust tinyrust.rs --error-format=json --json=diagnostic-rendered-ansi --crate-type lib --emit=dep-info,metadata,link -C opt-level=z -C panic=abort -Clinker-plugin-lto -C metadata=61b6ba1ff0efe210 -C extra-filename=-61b6ba1ff0efe210 --out-dir /home/tormol/p/rust/tiny-rust-executable/target/release/deps -L dependency=/home/tormol/p/rust/tiny-rust-executable/target/release/deps --extern sc=/home/tormol/p/rust/tiny-rust-executable/target/release/deps/libsc-35c3430f33082929.rmeta -C relocation-model=static`
    Finished release [optimized] target(s) in 0.45s
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

## License

Licensed under either of

* Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
* MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any additional terms or conditions.
