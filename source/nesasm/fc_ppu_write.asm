;=================================================
;PPU简单操作
;FlameCyclone
;2024.8.7
;=================================================
;文件头
NES_16KB_PRG_SIZE           =   1   ;16KB PRG大小数量
NES_8KB_CHR_SIZE            =   1   ;8KB CHR大小数量
MAPPER_NUMBER               =   4   ;映射器号
;=================================================
    .INESPRG NES_16KB_PRG_SIZE      ;16KB PRG 数量, $01-$EF8(1-3832),即16-61,312 KB
    .INESCHR NES_8KB_CHR_SIZE       ;8KB CHR 数量,$01-$EF8(1-3832),即0-30,656 KB
    .INESMAP MAPPER_NUMBER          ;Mapper号 (0-4095)
    
;=================================================
    .RSSET  $40
FC_Data_Addr_L              .RS 1
FC_Data_Addr_H              .RS 1
FC_Data_Count               .RS 1
FC_Data_Index               .RS 1

;缓冲分配
    .RSSET  $200
FC_PPU_Buf_Addr             .RS $A0     ;PPU数据缓冲地址
FC_PPU_Pal_Addr             .RS $20     ;PPU调色板缓冲地址
FC_PPU_Ctrl                 .RS 1       ;PPU控制缓冲
FC_PPU_Mask                 .RS 1       ;PPU掩码缓冲
FC_PPU_H_Scroll             .RS 1       ;PPU水平滚动缓冲
FC_PPU_V_Scroll             .RS 1       ;PPU垂直滚动缓冲
FC_PPU_Buf_Count            .RS 1       ;PPU数据缓冲待处理数据量
;=================================================
FC_PPU_MODE_LINE            =   $FE     ;单行文本写入模式
FC_PPU_MODE_CLEAR           =   $FD     ;单行文本清理模式
;=================================================
    .BANK 1,"Main Program"
    .ORG $E000

;=================================================
;PPU缓冲数据处理
FC_PPU_Buffer_Process
    LDX FC_PPU_Buf_Count
    BEQ FC_PPU_Palette_Buffer_Process
    LDA #$00
    STA FC_PPU_Buf_Count
    STA FC_PPU_Buf_Addr,X
    TAX
    
    LDA #$00
    STA $2001
    JSR FC_PPU_Buffer_Mode_Select

;PPU调色板缓冲处理
FC_PPU_Palette_Buffer_Process
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
    LDY #$20
FC_PPU_Palette_Buffer_Write
    LDA FC_PPU_Pal_Addr,X
    STA $2007
    INX
    DEY
    BNE FC_PPU_Palette_Buffer_Write
    
FC_PPU_Buffer_Process_End
    LDA #$00
    STA $2006
    STA $2006
    
    ;恢复 PPU 滚动
    LDA FC_PPU_H_Scroll
    STA $2005
    LDA FC_PPU_V_Scroll
    STA $2005
    
    ;恢复 PPU 显示掩码
    LDA FC_PPU_Mask
    STA $2001
    
    RTS

;处理模式选择
FC_PPU_Buffer_Mode_Select
    LDA FC_PPU_Buf_Addr,X
    INX
    CMP #FC_PPU_MODE_LINE
    BEQ FC_PPU_Buffer_Line
    CMP #FC_PPU_MODE_CLEAR
    BEQ FC_PPU_Buffer_Clear
    RTS

;单行文本写入处理
FC_PPU_Buffer_Line
    LDA FC_PPU_Buf_Addr,X
    STA $2006
    INX
    LDA FC_PPU_Buf_Addr,X
    STA $2006
    INX
    LDY FC_PPU_Buf_Addr,X
    INX
FC_PPU_Buffer_Line_Write
    LDA FC_PPU_Buf_Addr,X
    STA $2007
    INX
    DEY
    BNE FC_PPU_Buffer_Line_Write
    BEQ FC_PPU_Buffer_Mode_Select
    
;单行文本清除处理
FC_PPU_Buffer_Clear
    LDA FC_PPU_Buf_Addr,X
    STA $2006
    INX
    LDA FC_PPU_Buf_Addr,X
    STA $2006
    INX
    LDY FC_PPU_Buf_Addr,X
    INX
    LDA #$00
FC_PPU_Buffer_Clear_Write
    STA $2007
    DEY
    BNE FC_PPU_Buffer_Clear_Write
    BEQ FC_PPU_Buffer_Mode_Select

;=================================================
;初始化调色板缓冲
Init_Palette_Buffer
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00
    LDY #$20
Init_Palette_Buffer_Write
    LDA Init_Palette_Data,X
    STA FC_PPU_Pal_Addr,X
    STA $2007
    INX
    DEY
    BNE Init_Palette_Buffer_Write
    RTS

Init_Palette_Data
    .HEX 0F 20 21 0F 0F 23 24 25 0F 26 27 28 0F 29 2A 2B
    .HEX 0F 20 21 0F 0F 23 24 25 0F 26 27 28 0F 29 2A 2B
    
;=================================================
;等待 Vblank 触发
Wait_For_Vblank
    LDA $2002
    BPL Wait_For_Vblank
    RTS

;=================================================
;初始化静态文本
Init_Static_Text
    BIT $FFFF
    LDA #(Init_Static_Text_Index_End - Init_Static_Text_Index) / 2
    BEQ Init_Static_Text_End
    
    LDX FC_PPU_Buf_Count
    LDA #$00
    STA FC_Data_Index

;单条静态文本写入
Init_Static_Text_Write
    LDA #<Init_Static_Text_Index
    STA FC_Data_Addr_L
    LDA #>Init_Static_Text_Index
    STA FC_Data_Addr_H
    
    LDA FC_Data_Index
    ASL
    TAY
    
    ;获取文本数据地址
    LDA [FC_Data_Addr_L],Y
    PHA
    INY
    LDA [FC_Data_Addr_L],Y
    STA FC_Data_Addr_H
    PLA
    STA FC_Data_Addr_L
    
    ;设置PPU缓冲写入模式
    LDA #FC_PPU_MODE_LINE
    STA FC_PPU_Buf_Addr,X
    INX
    
    LDY #$02
    LDA [FC_Data_Addr_L],Y
    STA FC_Data_Count
    
    ;居中处理
    LDA #$20
    SEC
    SBC FC_Data_Count
    LSR
    STA FC_Data_Count
    
    ;PPU地址高位
    LDY #$01
    LDA [FC_Data_Addr_L],Y
    STA FC_PPU_Buf_Addr,X
    INX
    DEY
    
    ;PPU地址低位
    LDA [FC_Data_Addr_L],Y
    AND #$E0
    CLC
    ADC FC_Data_Count
    STA FC_PPU_Buf_Addr,X
    INX
    INY
    
    ;文本数据长度
    LDY #$02
    LDA [FC_Data_Addr_L],Y
    STA FC_Data_Count
    STA FC_PPU_Buf_Addr,X
    INX
    INY
    
;写入文本字符数据
Init_Static_Text_Write_Data
    LDA [FC_Data_Addr_L],Y
    STA FC_PPU_Buf_Addr,X
    INX
    INY
    DEC FC_Data_Count
    BNE Init_Static_Text_Write_Data

;检查文本写入是否结束
Init_Static_Text_Write_Next
    INC FC_Data_Index
    LDA FC_Data_Index
    CMP #(Init_Static_Text_Index_End - Init_Static_Text_Index) / 2
    BCC Init_Static_Text_Write
    
    STX FC_PPU_Buf_Count
    
Init_Static_Text_End
    RTS
    
Init_Static_Text_Data
Static_Text_01
    .DW $2140
    .USTR "FlameCyclone"
Static_Text_02
    .DW $2180
    .USTR "2024.8.7"
Static_Text_03
    .DW $21C0
    .USTR "FC PPU Write"
Static_Text_04
    .DW $2200
    .USTR "Thank for 6502"
Static_Text_05
    .DW $2240
    .USTR "And you"
Init_Static_Text_Index
    .DW Static_Text_01
    .DW Static_Text_02
    .DW Static_Text_03
    .DW Static_Text_04
    .DW Static_Text_05
Init_Static_Text_Index_End

;=================================================
;NMI(重置中断)处理
Reset_Program
    SEI
    CLD
    LDA #$00
    STA $2000
    STA $2001
    LDA #$C0
    STA $4017
    STA $E000
    LDX #$FF
    TXS

;等待PPU准备完毕
    LDX #$02
.Wait_For_Vblank
    LDA $2002
    BPL .Wait_For_Vblank
    DEX
    BNE .Wait_For_Vblank

;清空调色板
.Clear_PPU_Palette
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDA #$0F
    LDX #$20
.Clear_PPU_Palette_Write
    STA $2007
    DEX
    BNE .Clear_PPU_Palette_Write
    
;清空命名表
.Clear_PPU_Nametable
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006
    LDA #$00
    LDX #$10
    LDY #$00
.Clear_PPU_Nametable_Write
    STA $2007
    INY
    BNE .Clear_PPU_Nametable_Write
    DEX
    BNE .Clear_PPU_Nametable_Write
    
;清空内存
.Clear_RAM
    LDA #$00
    STA $00
    STA $01
    LDX #$08
    LDY #$00
.Clear_RAM_Write
    STA [$00],Y
    INY
    BNE .Clear_RAM_Write
    INC $01
    DEX
    BNE .Clear_RAM_Write
    
;初始化栈指针
    LDX #$FF
    TXS
    
    JSR Wait_For_Vblank
    JSR Init_Palette_Buffer
    JSR Init_Static_Text
    
    LDA #$88
    STA FC_PPU_Ctrl
    STA $2000
    LDA #$1E
    STA FC_PPU_Mask
    
.Loop
    JMP .Loop

;=================================================
;NMI(不可屏蔽中断)处理
Nmi_Program
    PHA
    TXA
    PHA
    TYA
    PHA
    
    LDA $2002
    JSR FC_PPU_Buffer_Process
    
    LDA FC_PPU_Ctrl
    STA $2000
    
    PLA
    TAY
    PLA
    TAX
    PLA
    RTI

;=================================================
;IRQ(请求中断)处理
Irq_Program
    RTI

;=================================================
;NES 入口
    .ORG $FFFA
    .DW Nmi_Program
    .DW Reset_Program
    .DW Irq_Program
    
;=================================================
    .BANK NES_16KB_PRG_SIZE * 2, "CHR Data"
    
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 18 18 18 18 00 18 18 00 00 00 00 00 00 00 00
    .HEX 00 0A 14 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 14 3E 14 14 14 3E 14 00 00 00 00 00 00 00 00
    .HEX 00 08 1E 28 1C 0A 3C 08 00 00 00 00 00 00 00 00
    .HEX 00 30 32 04 08 10 26 06 00 00 00 00 00 00 00 00
    .HEX 00 10 28 10 2A 24 26 18 00 00 00 00 00 00 00 00
    .HEX 00 18 18 08 10 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 06 08 10 10 10 08 06 00 00 00 00 00 00 00 00
    .HEX 00 30 08 04 04 04 08 30 00 00 00 00 00 00 00 00
    .HEX 00 00 08 2A 1C 1C 2A 08 00 00 00 00 00 00 00 00
    .HEX 00 00 08 08 3E 08 08 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 30 30 10 20 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 3C 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 18 18 00 00 00 00 00 00 00 00
    .HEX 00 02 06 0C 18 30 60 40 00 00 00 00 00 00 00 00
    .HEX 00 1C 22 63 63 63 22 1C 00 00 00 00 00 00 00 00
    .HEX 00 18 38 18 18 18 18 7E 00 00 00 00 00 00 00 00
    .HEX 00 3E 63 03 0E 3C 70 7F 00 00 00 00 00 00 00 00
    .HEX 00 3E 63 03 0E 03 63 3E 00 00 00 00 00 00 00 00
    .HEX 00 0E 1E 36 66 66 7F 06 00 00 00 00 00 00 00 00
    .HEX 00 7F 60 7E 63 03 63 3E 00 00 00 00 00 00 00 00
    .HEX 00 3E 63 60 7E 63 63 3E 00 00 00 00 00 00 00 00
    .HEX 00 7F 63 06 0C 18 18 18 00 00 00 00 00 00 00 00
    .HEX 00 3E 63 63 3E 63 63 3E 00 00 00 00 00 00 00 00
    .HEX 00 3E 63 63 3F 03 63 3E 00 00 00 00 00 00 00 00
    .HEX 00 00 18 18 00 18 18 00 00 00 00 00 00 00 00 00
    .HEX 00 00 30 30 00 30 10 20 00 00 00 00 00 00 00 00
    .HEX 00 04 08 10 20 10 08 04 00 00 00 00 00 00 00 00
    .HEX 00 00 00 3E 00 3E 00 00 00 00 00 00 00 00 00 00
    .HEX 00 20 10 08 04 08 10 20 00 00 00 00 00 00 00 00
    .HEX 00 1C 22 22 04 08 00 08 00 00 00 00 00 00 00 00
    .HEX 1C 22 5D 51 51 5D 22 1C 00 00 00 00 00 00 00 00
    .HEX 00 1C 36 63 63 7F 63 63 00 00 00 00 00 00 00 00
    .HEX 00 7E 63 63 7E 63 63 7E 00 00 00 00 00 00 00 00
    .HEX 00 3E 63 60 60 60 63 3E 00 00 00 00 00 00 00 00
    .HEX 00 7C 66 63 63 63 66 7C 00 00 00 00 00 00 00 00
    .HEX 00 7F 60 60 7E 60 60 7F 00 00 00 00 00 00 00 00
    .HEX 00 7F 60 60 7E 60 60 60 00 00 00 00 00 00 00 00
    .HEX 00 3E 63 60 67 63 63 3E 00 00 00 00 00 00 00 00
    .HEX 00 63 63 63 7F 63 63 63 00 00 00 00 00 00 00 00
    .HEX 00 3C 18 18 18 18 18 3C 00 00 00 00 00 00 00 00
    .HEX 00 1F 06 06 06 06 66 3C 00 00 00 00 00 00 00 00
    .HEX 00 63 66 6C 78 7C 6E 67 00 00 00 00 00 00 00 00
    .HEX 00 60 60 60 60 60 60 7F 00 00 00 00 00 00 00 00
    .HEX 00 63 77 7F 7F 6B 63 63 00 00 00 00 00 00 00 00
    .HEX 00 63 73 7B 7F 6F 67 63 00 00 00 00 00 00 00 00
    .HEX 00 3E 63 63 63 63 63 3E 00 00 00 00 00 00 00 00
    .HEX 00 7E 63 63 63 7E 60 60 00 00 00 00 00 00 00 00
    .HEX 00 3E 63 63 63 6F 66 3D 00 00 00 00 00 00 00 00
    .HEX 00 7E 63 63 62 7C 66 63 00 00 00 00 00 00 00 00
    .HEX 00 3E 63 60 3E 03 63 3E 00 00 00 00 00 00 00 00
    .HEX 00 7E 18 18 18 18 18 18 00 00 00 00 00 00 00 00
    .HEX 00 63 63 63 63 63 63 3E 00 00 00 00 00 00 00 00
    .HEX 00 63 63 63 63 36 1C 08 00 00 00 00 00 00 00 00
    .HEX 00 63 63 6B 6B 7F 77 22 00 00 00 00 00 00 00 00
    .HEX 00 63 76 3C 1C 1E 37 63 00 00 00 00 00 00 00 00
    .HEX 00 66 66 7E 3C 18 18 18 00 00 00 00 00 00 00 00
    .HEX 00 7F 07 0E 1C 38 70 7F 00 00 00 00 00 00 00 00
    .HEX 00 0F 0C 0C 0C 0C 0C 0C 00 00 00 00 00 00 00 00
    .HEX 00 40 60 30 18 0C 06 02 00 00 00 00 00 00 00 00
    .HEX 00 78 18 18 18 18 18 18 00 00 00 00 00 00 00 00
    .HEX 00 20 50 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 3C 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    .HEX 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

    ;CHR末尾填充
    .BANK NES_16KB_PRG_SIZE * 2 + NES_8KB_CHR_SIZE - 1
    .ORG $1FFF
    .HEX FF
