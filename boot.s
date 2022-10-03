BITS 16

; 历史设计, bios读取第一个扇区到0000:7c00, 然后从这里开始执行引导程序
org 0x7c00

; 初始化堆栈(后面中断要用)和数据段
mov ax, 0
mov ss, ax
mov sp, 7c00h
mov ds, ax

; 打印字符串msg
mov ah, 0   ; 设置显卡模式
mov al, 02h ; 16 色 文本
int 10h

mov ah, 01h ; 设置光标
mov ch, 0
mov cl, 15

mov ah, 05h ;设置活动页为0
mov al, 0   
int 10h

mov si, 0   ;作为索引
print_msg:
    mov  ax, si
    call chg_col
    mov  al, [msg+si]
    call putchar
    inc  si
    cmp  al, 0
    je   next
    jmp  print_msg

chg_col: ; change column to al
    push ax
    push bx
    push dx
    mov  ah, 02h ; 移动光标
    mov  dl, al  ; 列
    mov  dh, 0   ; 行
    mov  bh, 0   ; 页
    int  10h
    pop  dx
    pop  bx
    pop  ax
    ret

putchar: ; putchar(al)
    push ax
    push bx
    push cx
    mov  ah, 0ah ; 显示字符
    mov  bh, 0   ; 当前页
    mov  cl, 1   ; 输出一次
    int  10h
    pop  cx
    pop  bx
    pop  ax
    ret

; TODO? 设置鼠标键盘

; 因为这里只能有510字节的代码, 所以用bios磁盘服务中断读取引导扇区之后3个扇区的内容到内存 0x8000 处
; real mode es:bx == es<<4+bx
next:
    mov ax, 0800h
    mov es, ax
    mov bx, 0       ; 内存缓冲区地址 es:bx
    mov ch, 0       ; 柱面号
    mov dh, 0       ; 磁头号
    mov cl, 2       ; 起始扇区号
    mov ah, 2       ; 读扇区功能号
    mov al, 3       ; 读3个扇区
    mov dl, 80h     ; C盘
    int 13h

    ; 跳转到setup.s (Mixed-Size Jumps) 
    ; https://www.nasm.us/xdoc/2.15.05/html/nasmdo11.html#section-11.1
    jmp word 0000:8000h

; 应该不会执行到这里
fin: 
    hlt
    jmp fin

msg: db "Test Operation System  :) --- Principle of Software Security Course", 0h

; nasm预处理指令, 用0填满除去代码之后到510字节
resb 510-($-$$)

; 引导扇区最后两个字节必须是0x55aa
dw 0xaa55

; objdump -bbinary -mi8086 -D boot.bin 还有 -mi386 查看编译出来的指令是否正确
