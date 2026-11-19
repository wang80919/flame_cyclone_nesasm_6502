;=================================================
;FC ROM 简单框架
;FlameCyclone
;2024.8.9
;=================================================
    .INCLUDE "fc_basic_config.asm"      ;配置
;=================================================
;音乐数据
    .IF MUSIC_PLAY_ENABLE
        .INCLUDE "fc_basic_music_bank.asm"  ;音乐数据
    .ENDIF

;=================================================
;文本数据放在开头Bank
    .BANK $08, "Text Data"
    .ORG $8000
    .INCLUDE "fc_basic_data.asm"

;=================================================
;主程序放在最后一个 8KB bank
    .BANK FC_PRG_E000 & PRG_8K_BANK_MASK, "Main Program"
    .ORG $E000

;=================================================
;Mapper 操作引用
    .IF 1 = MAPPER_NUMBER
        .INCLUDE "fc_basic_mapper_mmc1"
    .ENDIF

    .IF 4 = MAPPER_NUMBER
        .INCLUDE "fc_basic_mapper_mmc3"
    .ENDIF

    .IF 5 = MAPPER_NUMBER
        .INCLUDE "fc_basic_mapper_mmc5"
    .ENDIF
    
    .IF 9 = MAPPER_NUMBER
        .INCLUDE "fc_basic_mapper_mmc2"
    .ENDIF
    
    .IF 10 = MAPPER_NUMBER
        .INCLUDE "fc_basic_mapper_mmc4"
    .ENDIF
    
    .IF 19 = MAPPER_NUMBER
        .INCLUDE "fc_basic_mapper_namco_163.asm"
    .ENDIF
    
    .IF (21 = MAPPER_NUMBER) | (22 = MAPPER_NUMBER) | (23 = MAPPER_NUMBER) | (25 = MAPPER_NUMBER)
        .INCLUDE "fc_basic_mapper_vrc4.asm"
    .ENDIF

    .IF (24 = MAPPER_NUMBER) | (26 = MAPPER_NUMBER)
        .INCLUDE "fc_basic_mapper_vrc6.asm"
    .ENDIF

    .IF 69 = MAPPER_NUMBER
        .INCLUDE "fc_basic_mapper_sunsoft_5b.asm"
    .ENDIF
    
    .IF 73 = MAPPER_NUMBER
        .INCLUDE "fc_basic_mapper_vrc3.asm"
    .ENDIF
    
    .IF 75 = MAPPER_NUMBER
        .INCLUDE "fc_basic_mapper_vrc1.asm"
    .ENDIF
    
    .IF 85 = MAPPER_NUMBER
    .INCLUDE "fc_basic_mapper_vrc7.asm"
    .ENDIF

;=================================================
;其他源码引用
    .INCLUDE "fc_basic_constant.asm"    ;常量定义
    .INCLUDE "fc_basic_ppu.asm"         ;PPU处理
    .INCLUDE "fc_basic_text.asm"        ;文本处理
    .INCLUDE "fc_basic_joy.asm"         ;手柄输入处理
    .INCLUDE "fc_basic_joy_test.asm"    ;手柄输入测试
    .INCLUDE "fc_basic_utils.asm"       ;使用工具
    .INCLUDE "fc_basic_paging.asm"      ;翻页操作
    .INCLUDE "fc_basic_page_list.asm"   ;翻页文本列表
    .INCLUDE "fc_basic_cursor.asm"      ;光标处理
    .INCLUDE "fc_basic_mapper.asm"      ;Mapper操作
    
    .IF MUSIC_PLAY_ENABLE
        .INCLUDE "fc_basic_music.asm"       ;音乐播放
    .ENDIF
    
;=================================================
;等待 Vblank 触发
Wait_For_Vblank
    LDA PPU_STATUS      ;$2002
    BPL Wait_For_Vblank
    RTS

;=================================================
;初始化调色板数据与调色板缓冲
Init_Palette_With_Buffer
    LDA #$3F
    STA PPU_ADDRESS     ;$2006      ;写入 PPU 地址高位
    LDA #$00
    STA PPU_ADDRESS     ;$2006      ;写入 PPU 地址低位
    LDX #$00
    LDY #$20
Init_Palette_With_Buffer_Write
    LDA Init_Palette_Data,X
    STA FC_PPU_Pal_Addr,X           ;写入到缓冲
    STA PPU_DATA        ;$2007      ;写入 PPU 数据
    INX
    DEY
    BNE Init_Palette_With_Buffer_Write
    RTS

Init_Palette_Data
    .HEX 0F 20 25 0F 0F 23 20 22 0F 22 21 23 0F 27 20 0F
    .HEX 0F 21 20 20 0F 24 24 24 0F 21 21 21 0F 22 22 22

;=================================================
;NMI(重置中断)处理, 上电时
Reset_Program
    SEI                 ;设置中断禁用标志, 防止程序执行被中断
    CLD                 ;禁用 10进制模式, NES 不支持 10进制
    
    .IF 1 = MAPPER_NUMBER
.Reset_Mapper
        INC .Reset_Mapper
    .ENDIF

    ;关闭屏幕
    LDA #$00
    STA PPU_CTRL        ;$2000  ;静音NMI
    STA PPU_MASK        ;$2001  ;禁用屏幕渲染
    
    LDA #$40
    STA JOY2_FRAME      ;$4017  ;禁用 APU 帧 IRQ

;-------------------------------------------------
;等待 PPU 准备完毕
    LDX #$02
.Wait_For_Vblank
    LDA PPU_STATUS      ;$2002
    BPL .Wait_For_Vblank
    DEX
    BNE .Wait_For_Vblank

;-------------------------------------------------
;清空 PPU 调色板(PPU 调色板内存: $3F00 - $3F1F)
;重要: 只能在 Vblank 期间操作调色板, 否则即使屏幕关闭, 也会出现撕裂的色条横线
.Clear_PPU_Palette
    LDA #$3F
    STA PPU_ADDRESS     ;$2006      ;写入 PPU 地址高位
    LDA #$00
    STA PPU_ADDRESS     ;$2006      ;写入 PPU 地址低位
    LDA #$0F
    LDX #$20
.Clear_PPU_Palette_Write
    STA PPU_DATA        ;$2007
    DEX
    BNE .Clear_PPU_Palette_Write
    
    ;设置栈指针
    LDX #$FF
    TXS
    
;-------------------------------------------------
;清空 APU 状态    
.Clear_Apu_Status
    LDY #$13
.Clear_Apu_Status_Write
    LDA .Default_Apu_Status_Data,Y
    STA $4000,Y
    DEY
    BPL .Clear_Apu_Status_Write
    LDA #$0F
    STA $4015
    JMP .Clear_Apu_Status_End
.Default_Apu_Status_Data
    .DB $30,$08,$00,$00
    .DB $30,$08,$00,$00
    .DB $80,$00,$00,$00
    .DB $30,$00,$00,$00
    .DB $00,$00,$00,$00
.Clear_Apu_Status_End

    JSR Mapper_Sound_Clear  ;Mapper 音频清理
    
;-------------------------------------------------
;清空 PPU 命名表(PPU 命名表内存: $2000 - $2FFF)
.Clear_PPU_Nametable
    LDA #$20
    STA PPU_ADDRESS     ;$2006      ;写入 PPU 地址高位
    LDA #$00
    STA PPU_ADDRESS     ;$2006      ;写入 PPU 地址低位
    LDA #$00
    LDX #$10
    LDY #$00
.Clear_PPU_Nametable_Write
    STA PPU_DATA        ;$2007
    INY
    BNE .Clear_PPU_Nametable_Write
    DEX
    BNE .Clear_PPU_Nametable_Write
    
;-------------------------------------------------
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
    
;-------------------------------------------------
;初始化栈指针
    LDX #$FF
    TXS

    JSR Mapper_Init                 ;Mapper 初始化
    
    LDA #$FF
    STA Use_Zero_Page_End
    STA Use_Non_Zero_Page_End
    
    ;调色板初始化 & 调色板缓冲初始化
    JSR Mapper_Mirroring_H           ;设置命名表水平镜像
    JSR Wait_For_Vblank              ;等到 Vblank
    JSR Init_Palette_With_Buffer     ;初始化调色板缓冲
    
    ;写入静态文本, 需要先切页
    LDA #BANK(Text_Data_Index)
    JSR Mapper_Prg_8000_Banking
    ;JSR Write_Text_Group_By_Buffer  ;写入静态文本组(缓冲方式)
    JSR Write_Text_Group_By_Data     ;写入静态文本组(直写模式)
    
    ;初始化音乐
    .IFDEF Music_Init_Process
        JSR Music_Init_Process
    .ENDIF
        
    ;启用 NMI 中断
    LDA #$88
    STA FC_PPU_Ctrl
    STA PPU_CTRL        ;$2000
    
    ;刷新文本列表
    JSR Page_List_Update
    
    ;开启屏幕显示
    LDA #$1E
    STA FC_PPU_Mask

    CLI
;-------------------------------------------------
;死循环, 后续操作交给 NMI 中断
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
    
    LDA PPU_STATUS      ;$2002  读取清除 Vblank 状态
    
    ;设置IRQ触发位置低位, 假设在第 30 条扫描线触发 
    .IFDEF MACRO_GET_IRQ_FIRST_VALUE_L
        MACRO_GET_IRQ_FIRST_VALUE_L #30
        STA FC_Irq_Latch_L
    .ENDIF
    
    .IFDEF MACRO_IRQ_LATCH_L
        MACRO_IRQ_LATCH_L
    .ENDIF
    
    .IFDEF MACRO_IRQ_RELOAD_L
        MACRO_IRQ_RELOAD_L
    .ENDIF
    
    ;设置IRQ触发位置高位, 假设在第 30 条扫描线触发
    .IFDEF MACRO_GET_IRQ_FIRST_VALUE_H
        MACRO_GET_IRQ_FIRST_VALUE_H #30
        STA FC_Irq_Latch_H
    .ENDIF
    
    .IFDEF MACRO_IRQ_LATCH_H
        MACRO_IRQ_LATCH_H
    .ENDIF
    
    .IFDEF MACRO_IRQ_RELOAD_H
        MACRO_IRQ_RELOAD_H
    .ENDIF
    
    ;启用 IRQ
    .IFDEF MACRO_IRQ_ENABLE
        MACRO_IRQ_ENABLE
    .ENDIF 
    CLI
    
    JSR FC_PPU_Buffer_Process   ;PPU缓冲处理
    
    LDA #OAM_DMA_Buffer / $100
    STA OAM_DMA         ;$4014  ;将精灵缓冲写入精灵内存
    
    LDA FC_PPU_Ctrl
    STA PPU_CTRL        ;$2000  ;恢复屏幕控制
    
    JSR FC_Gamepad_Process      ;手柄输入处理
    
    JSR Joystick_Once_Down_Show ;显示按下
    JSR Joystick_Once_Up_Show   ;显示弹起
    JSR Joystick_Keey_Show      ;显示按住
    
    INC FC_Irq_Scroll           ;IRQ 滚动增加
    
    ;选择音乐
    .IFDEF Music_Select_Process
        JSR Music_Select_Process
    .ENDIF
    
    .IFDEF FC_Page_Test
        JSR FC_Page_Test
    .ENDIF
    JSR FC_Cursor_Show
    
    ;播放音乐
    .IFDEF Music_Play_Process
        JSR Music_Play_Process
    .ENDIF
    
    LDA #$00
    STA FC_Nmi_Task_Busy
        
    PLA
    TAY
    PLA
    TAX
    PLA
    RTI
    
;=================================================
;IRQ(请求中断)处理
Irq_Program
    PHA
    TXA
    PHA
    TYA
    PHA
    
    ;响应IRQ
    .IFDEF MACRO_IRQ_ACK
        MACRO_IRQ_ACK
    .ENDIF
    
    LDA FC_Irq_Index
    INC FC_Irq_Index
    
    CMP #$00
    BEQ Irq_Process_Scroll_Left
    CMP #$01
    BEQ Irq_Process_Scroll_Right
    CMP #$02
    BEQ Irq_Process_Disable
    JMP Irq_Program_End

Irq_Process_Scroll_Left
    LDA FC_Irq_Scroll
    STA PPU_SCROLL
    STA PPU_SCROLL
    
    ;获取下次 IRQ 触发时机低位, 假设在第 14 条扫描线后触发
    .IFDEF MACRO_GET_IRQ_INTERVAL_VALUE_L
        MACRO_GET_IRQ_INTERVAL_VALUE_L #14
        STA FC_Irq_Interval_L
    .ENDIF
    
    ;获取下次 IRQ 触发时机高位, 假设在第 14 条扫描线后触发
    .IFDEF MACRO_GET_IRQ_INTERVAL_VALUE_H
        MACRO_GET_IRQ_INTERVAL_VALUE_H #14
        STA FC_Irq_Interval_H
    .ENDIF
    
    JSR Set_Next_Irq_Latch_Value    ;设置 IRQ 触发时机
    
    ;启用 IRQ
    .IFDEF MACRO_IRQ_ENABLE
        MACRO_IRQ_ENABLE
    .ENDIF
    
    JMP Irq_Program_End
    
Irq_Process_Scroll_Right
    LDA FC_Irq_Scroll
    EOR #$FF
    CLC
    ADC #$01
    STA PPU_SCROLL
    STA PPU_SCROLL
    
    ;14条扫描线后再次触发IRQ
    .IFDEF MACRO_GET_IRQ_INTERVAL_VALUE_L
        MACRO_GET_IRQ_INTERVAL_VALUE_L #14
        STA FC_Irq_Interval_L
    .ENDIF
    
    .IFDEF MACRO_GET_IRQ_INTERVAL_VALUE_H
        MACRO_GET_IRQ_INTERVAL_VALUE_H #14
        STA FC_Irq_Interval_H
    .ENDIF
    
    JSR Set_Next_Irq_Latch_Value
    
    ;启用 IRQ
    .IFDEF MACRO_IRQ_ENABLE
        MACRO_IRQ_ENABLE
    .ENDIF
    
    JMP Irq_Program_End
    
Irq_Process_Disable
    LDA #$00
    STA PPU_SCROLL
    STA PPU_SCROLL
    STA FC_Irq_Index
    
    ;禁用IRQ
    .IFDEF MACRO_IRQ_DISABLE
        MACRO_IRQ_DISABLE
    .ENDIF

Irq_Program_End
    PLA
    TAY
    PLA
    TAX
    PLA
    RTI

;=================================================
;设置下次IRQ触发值
Set_Next_Irq_Latch_Value

    .IF MAPPER_IS_ABSOLUTE
        ;如果是绝对位置触发IRQ, 则累加后写入触发IRQ
        
        .IFDEF MACRO_IRQ_LATCH_L
            LDA FC_Irq_Latch_L
            CLC
            ADC FC_Irq_Interval_L
            STA FC_Irq_Latch_L
            MACRO_IRQ_LATCH_L
        .ENDIF
        
        .IFDEF MACRO_IRQ_LATCH_H
            LDA FC_Irq_Latch_H
            ADC FC_Irq_Interval_H
            STA FC_Irq_Latch_H
            MACRO_IRQ_LATCH_H
        .ENDIF
        
    .ELSE
        ;如果是相对位置触发IRQ, 则直接写入触发IRQ
        .IFDEF MACRO_IRQ_LATCH_L
            LDA FC_Irq_Interval_L
            MACRO_IRQ_LATCH_L
        .ENDIF
        
        .IFDEF MACRO_IRQ_LATCH_H
            LDA FC_Irq_Interval_H
            MACRO_IRQ_LATCH_H
        .ENDIF
    .ENDIF
    RTS

;=================================================
    .INCLUDE "fc_basic_interface.asm"   ;外部切页接口

;=================================================
;NES 中断向量入口
    .ORG $FFFA
    .DW Nmi_Program     ;NMI    ;开启NMI后, 渲染扫描线在第 241 行时触发
    .DW Reset_Program   ;RESET  ;开机上电时触发
    .DW Irq_Program     ;IRQ    ;发生IRQ时触发

;=================================================
;CHR 数据
    .INCLUDE "fc_basic_chr.asm"