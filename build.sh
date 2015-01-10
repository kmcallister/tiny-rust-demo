#!/bin/bash

set -e

for d in rustc git cargo ar ld objcopy nasm; do
    which $d >/dev/null || (echo "Can't find $d, needed to build"; exit 1)
done

printf "Tested on rustc 1.0.0-dev (44a287e6e 2015-01-08 17:03:40 -0800)\nYou have  "
rustc --version
echo

if [ ! -d syscall.rs ]; then
    git clone https://github.com/kmcallister/syscall.rs
    (cd syscall.rs && cargo build)
    echo
fi

set -x

rustc tinyrust.rs \
    -O -C no-stack-check -C relocation-model=static \
    -L syscall.rs/target

ar x libtinyrust.rlib tinyrust.o

objdump -dr tinyrust.o
echo

ld --gc-sections -e main -T script.ld -o payload tinyrust.o
objcopy -j combined -O binary payload payload.bin

ENTRY=$(nm -f posix payload | grep '^main ' | awk '{print $3}')
nasm -f bin -o tinyrust -D entry=0x$ENTRY elf.s

chmod +x tinyrust
hd tinyrust
wc -c tinyrust
