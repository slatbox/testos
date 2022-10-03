/* Simple linker script for the testos kernel.
   See the GNU ld 'info' manual ("info ld") to learn the syntax. */

OUTPUT_FORMAT("binary")
OUTPUT_ARCH(i386)
ENTRY(main)

SECTIONS {
    . = 0x8200;

    .text : {
        *(.text .rel.text)
    }

    .data : {
        *(.data)
    }

    /DISCARD/ : {
        *(.eh_frame .note.GNU-stack .comment)
    }
}
