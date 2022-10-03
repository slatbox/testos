# 我的Linux环境用的xfce4桌面, Windows下用的msys2
TERMINAL = xfce4-terminal

OSIMG = test.img
V = @
OS_NAME = $(shell uname)

.DEFAULT_GOAL = debug

boot.bin: boot.s
	$(V)nasm $< -o $@

setup.bin: setup.s
	$(V)nasm $< -o $@

main.o: main.c
	$(V)gcc main.c -march=i386 -m32 -fno-builtin -fno-PIC -Wall -nostdinc -fno-stack-protector -ffreestanding -c -o main.o

main.bin: main.o
ifeq ($(OS_NAME), Linux)
	$(V)ld -nostdlib -Tmain.ld $< -o $@
else
	$(V)strip --strip-all $<
	$(V)ld -nostdlib -mi386pe $< -o $@
	$(V)objcopy -O binary $@ $@
endif

$(OSIMG): boot.bin setup.bin main.bin
	$(V)dd if=/dev/zero of=$@ count=100
	$(V)dd if=$< of=$@ conv=notrunc
	$(V)dd if=setup.bin of=$@ seek=1 conv=notrunc
	$(V)dd if=main.bin of=$@ seek=2 conv=notrunc

.PHONY: debug clean
debug: $(OSIMG)
	$(V)qemu-system-i386 -S -s -drive file=$(OSIMG),media=disk,format=raw &
	$(V)sleep 2
ifeq ($(OS_NAME), Linux)
	$(V)$(TERMINAL) -e "gdb -q -x gdbinit"
else
	$(V)cmd /c "start gdb -q -x gdbinit"
endif
# 退出调试时可执行kq结束qemu再quit

run: $(OSIMG)
	$(V)qemu-system-i386 -drive file=$(OSIMG),media=disk,format=raw

clean:
	$(V)rm *.img
	$(V)rm *.bin
	$(V)rm *.o
