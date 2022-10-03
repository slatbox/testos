void _hlt();

// main()必须在main.c最前面生成的汇编里main函数才能在最开始, 应该可以改进
void main() {
    /*
    TODO 暂定
    定义各种结构体和函数 idt ldt tss ...
    初始化 idt 时钟中断 系统调用
    分页
    开中断
    写显存, 在屏幕上画字符串 https://wiki.osdev.org/Printing_To_Screen
    简单的内存和任务管理 内存管理器 进程调度 
    用户模式程序
    */
    while (1) {
        _hlt();
    }
}

void _hlt() {
    asm("hlt");
}

