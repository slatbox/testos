# TEST OPERATION SYSTEM

## 说明

一个i386架构的保护模式下简陋的操作系统.

使用 `nasm` + `gcc` + `qemu-system-i386`

## TODO

- [x] 保护模式
- [x] 分段
- [ ] 分页
- [ ] 内存管理
- [ ] 任务管理
- [ ] ...............

## 测试

`make` 或者 `make debug`

## 注意

我用的`xubuntu`终端是`xfce4-terminal`, 请`make`前自行修改`Makefile`的`TERMINAL`的值.

Linux环境需要 `gcc`, `nasm`, `qemu-system-i386`.

Windows下需要 `mingw`, `nasm`, `qemu-system-i386` 并配置好环境变量. 最好还是在Linux下整.

## 参考资料

[ucore](https://github.com/chyyuu/ucore_os_lab)

[30天自制操作系统](https://item.jd.com/13148621.html)

[nasm文档](https://www.nasm.us/xdoc/2.15.05/html/)

[OSDEV wiki](https://wiki.osdev.org/Main_Page)

[Intel 80386 Programmer's Reference Manual](https://www.logix.cz/michal/doc/i386/)

[Linux内核0.11完全注释修正版3.0](http://www.oldlinux.org/download/CLK-5.0-WithCover.pdf)
