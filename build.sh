#!/usr/bin/env bash

set -e

for d in rustc git cargo ar ld objcopy nasm hexdump; do
    which $d >/dev/null || (echo "Can't find $d, needed to build"; exit 1)
done

printf "Tested on rustc 1.30.0-nightly (f8d34596f 2018-08-30)\n You have  "
rustc --version
echo

if [ ! -d syscall.rs ]; then
    git clone https://github.com/japaric/syscall.rs
    (cd syscall.rs && cargo build --release)
    echo
fi

set -x

rustc tinyrust.rs \
    -O -C relocation-model=static \
    -L syscall.rs/target/release

# tinyrust.tinyrust.3a1fbbbh-cgu.0.rcgu.o
OBJECT=$(ar t libtinyrust.rlib | grep '.o$')
ar x libtinyrust.rlib "$OBJECT"

objdump -dr "$OBJECT"
echo

ld --gc-sections -e main -T script.ld -o payload "$OBJECT"
objcopy -j combined -O binary payload payload.bin

ENTRY=$(nm --format=posix payload | grep '^main ' | awk '{print $3}')
nasm -f bin -o tinyrust -D entry=0x$ENTRY elf.s

chmod +x tinyrust
hexdump -C tinyrust
wc -c tinyrust
