#![crate_type="rlib"]
#![allow(unstable)]

#[macro_use] extern crate syscall;

use std::{mem, raw, intrinsics};

fn exit(n: usize) -> ! {
    unsafe {
        syscall!(EXIT, n);
        intrinsics::unreachable()
    }
}

fn write(fd: usize, buf: &[u8]) {
    unsafe {
        syscall!(WRITE, fd, buf.as_ptr(), buf.len());
    }
}

#[no_mangle]
pub fn main() {
    // Make a Rust value representing the string constant we stashed
    // in the ELF file header.
    let message: &'static [u8] = unsafe {
        mem::transmute(raw::Slice {
            data: 0x00400008 as *const u8,
            len: 7,
        })
    };

    write(1, message);
    exit(0);
}
