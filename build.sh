#!/usr/bin/env bash

set -e

for d in rustc git cargo ar ld objcopy nasm hexdump; do
    which $d >/dev/null || (echo "Can't find $d, needed to build"; exit 1)
done

printf "Tested on rustc 1.46.0-nightly (346aec9b0 2020-07-11)\nYou have  "
rustc --version
echo

if [ ! -d syscall.rs ]; then
    git clone --depth=1 https://github.com/AgustinCB/syscall.rs
    # a fork of https://github.com/japaric/syscall.rs with updated asm feature flag
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
