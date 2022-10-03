define kq
shell kill `ps -ef | grep qemu | xargs -n1 | grep "[0-9]" | head -n1`
end

target remote :1234
set architecture i8086
set disassembly-flavor intel
# b *0x7c00
b *0x8000
c
x/20i $pc

