BITS 16

; main.bin 在boot.s里读的第2个扇区 8x8000+512 == 0x8200 main函数在最前面
%define C_MAIN 8200h

; 这个程序会被加载到这里, 见boot.s
org 0x8000

; 关中断 ignore maskable external interrupts
cli

; 使能A20 Gate, 然后才可以访问超过1MB的内存, 否则会“回卷”.
; 据说是因为多年前某些目光短浅的程序员偏要利用这个特性来写程序, 为了保证向下兼容才不得不加上A20 Gate.
; A20 Gate由8042键盘控制器来控制, 因为当时8042键盘控制器刚好有个闲置的引脚
; 通过将键盘控制器上的A20线置于高电位, 全部32条地址线可用, 可以访问4G的内存空间。
; 更详细的资料可以参考  
; https://wiki.osdev.org/%228042%22_PS/2_Controller#Data_Port
; https://wiki.osdev.org/A20_Line

wait1:
    in   al,  64h   ; 读64端口, 也就是8042的status register
    test al,  02h
    jnz  wait1      ; 如果输入缓冲有数据(鼠标键盘), 再等等
    mov  al,  0xd1  ; 0xd1 -> port 0x64
    out  64h, al    ; 发送0xd1命令到Controller, 指示下一个写入0x60的字节写出到Output Port
wait2:
    in   al,  64h
    test al,  02h
    jnz  wait2
    mov  al,  0xdf  ; 0xdf -> port 0x60
    out  60h, al    ; 0xdf = 11011111, 使Output Port第二位为1打开A20 Gate

; 加载暂定的全局段描述符表
lgdt [temp_gdtdesc]

; 修改cr0的PE(Protection Enable)位(bit0位)为1进入保护模式
mov eax, cr0
or  eax, 1
mov cr0, eax

; 因为进入(受)保护(的虚拟内存地址)模式后对机器语言指令的解释会改变还有流水线的原因, 需要jmp到下一指令
; long jump使cs=0x8(0000000000001000后3位为TI,RPL)也就是指向gdt+1的段, eip=protect
; 之后bios中断就废了
jmp dword 0x8:protect

; 用来定义gdt表项的宏. 改自ucore
%define seg_null resb 8

; 三个参数 type:4位, base:32位 ,lim:20位
%macro set_seg 3
    dw (((%3) >> 12) & 0xffff), ((%2) & 0xffff)
    db (((%2) >> 16) & 0xff), (0x90 | (%1)), \
       (0xC0 | (((%3) >> 28) & 0xf)), (((%2) >> 24) & 0xff)
%endmacro

%if 0
宏set_seg的解释:
.word (((lim) >> 12) & 0xffff)        lim的15-0位
.word ((base) & 0xffff)               base的15-0位
.byte (((base) >> 16) & 0xff)         base的23-16位
.byte (0x90 | (type))                 1001(段存在位1, 最高特权级00, 1: 代码or数据段), 0000|type 段类型
.byte (0xC0 | (((lim) >> 28) & 0xf))  1100(段界限以4k为单位, 32位段, 不用, 保留), lim的19-16位
.byte (((base) >> 24) & 0xff)         base的31-24位
%endif

%define STA_X 0x8     ; Executable segment
%define STA_E 0x4     ; Expand down (non-executable segments)
%define STA_C 0x4     ; Conforming code segment (executable only)
%define STA_W 0x2     ; Writeable (non-executable segments)
%define STA_R 0x2     ; Readable (executable segments)
%define STA_A 0x1     ; Accessed

; 4字节对齐
align 16

; 段描述符的各个位的解释 http://www.logix.cz/michal/doc/i386/chp05-01.htm#05-01-01
%if 0 
设置的三个段分别为
0000000000000000h
1111111111111111, 0000000000000000, 00000000, 10011010, 11001111, 00000000
ffff0000009acf00
1111111111111111, 0000000000000000, 00000000, 10010010, 11001111, 00000000
ffff00000092cf00
%endif

; 这里设置的gdt的base和lim使得进入保护模式后虚拟地址等于物理地址, 保证了内存映射不变. 当然段类型得不一样.
temp_gdt:
    seg_null
    set_seg STA_X|STA_R, 0x0, 0xffffffff ; 代码段
    set_seg STA_W, 0x0, 0xffffffff       ; 数据段
align 16
temp_gdtdesc:
    dw 0x17      ; 段上限（有效字节数-1）sizeof(gdt) - 1
                 ; 三个段, 3*8-1=23=0x17
    dd temp_gdt  ; gdt起始地址

BITS 32

protect:
    ; 初始化数据段寄存器
    mov ax, 2*8
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    xor ax, ax

    ; 设置堆栈
    mov ebp, 0xe0000
    mov esp, 0xf0000

    ; 后面就写C语言加gcc内嵌汇编了, 继续用nasm+gcc也行
    jmp C_MAIN
