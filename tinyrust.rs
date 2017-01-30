#![crate_type="rlib"]
#![feature(core_intrinsics)]

#[macro_use] extern crate sc;

use std::{mem, slice, intrinsics};

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
        mem::transmute(slice::from_raw_parts(0x00400008 as *const u8, 7))
    };

    write(1, message);
    exit(0);
}
