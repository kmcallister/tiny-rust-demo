SECTIONS {
    . = 0x400070;

    combined . : AT(0x400070) ALIGN(1) SUBALIGN(1) {
        *(.text*)
        *(.data*)
        *(.rodata*)
        *(.bss*)
    }
}
