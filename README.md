# nesasm 6502 汇编例程

## 

## 编译工具

| 工具                     | 介绍                           |
| ------------------------ | ------------------------------ |
| [nesasm_Gui_3_2_x86.exe](tools/nesasm_Gui_3_2_x86.exe)       | nesasm 编译器 GUI 版本         |
| [nesasm_3_2.exe](tools/nesasm_3_2.exe)               | nesasm 编译器 CUI 版本(命令行) |
| [6502_Simulator_cn_1.2.11.zip](tools/6502_Simulator_cn_1.2.11.zip) | 6502 汇编 IDE 中文版           |
| [6502_Simulator_1.2.11.zip](tools/6502_Simulator_1.2.11.zip)    | 6502 汇编 IDE 英文版           |



## FC简单框架

[FC基础框架源码(fc_basic_framework)](source/fc_basic_framework/README.md)

很详细的框架代码, 涵盖 FC ROM的 重启处理, NMI中断处理, IRQ处理, PPU处理, 手柄输入处理, 以及常见的Mapper 的操作

框架例子中使用的 Mapper 包括:

| 公司     | 映射器(Mapper号)                                             |
| -------- | ------------------------------------------------------------ |
| Nintendo | MMC1 (Mapper 1)<br />MMC2 (Mapper 9)<br />MMC3 (Mapper 4)<br />MMC4 (Mapper 10)<br />MMC5 (Mapper 5) |
| Konami   | VRC1 (Mapper 75)<br />VRC2 (Mapper 22 & 23 & 25)<br />VRC3 (Mapper 73)<br />VRC4 (Mapper 21 & 23 & 25)<br />VRC6 (Mapper 24 & 26)<br />VRC7 (Mapper 85) |
| Sunsoft  | Sunsoft FME-7 / 5A /5B (Mapper 69)                           |
| Namco    | Namco 163 (Mapper 19)                                        |



## 例程文件

| 例程名                                                       | 介绍                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [fc_data_copy.asm](source/nesasm/fc_data_copy.asm)           | 数据拷贝<br />拷贝RAM到RAM<br />拷贝RAM到PPU<br />拷贝PPU到RAM<br />使用指定值清除RAM<br />使用指定值清除PPU |
| [fc_hex_to_dec_8_16.asm](source/nesasm/fc_hex_to_dec_8_16.asm) | 8位 16进制转十进制                                           |
| [fc_mul_8_16.asm](source/nesasm/fc_mul_8_16.asm)             | 8位 16位 乘法                                                |
| [fc_add_16_32_64.asm](source/nesasm/fc_add_16_32_64.asm)     | 16, 32, 64 位加法                                            |
| [fc_sub_16_32_64.asm](source/nesasm/fc_sub_16_32_64.asm)     | 16, 32, 64 位减法                                            |
| [fc_cmp_16_32_64.asm](source/nesasm/fc_cmp_16_32_64.asm)     | 16, 32, 64 位比较                                            |
| [fc_zero_16_32_64.asm](source/nesasm/fc_zero_16_32_64.asm)   | 16, 32, 64 位判断是否为0                                     |
| [fc_ppu_write.asm](source/nesasm/fc_ppu_write.asm)           | PPU 缓冲写入处理                                             |
|                                                              |                                                              |
