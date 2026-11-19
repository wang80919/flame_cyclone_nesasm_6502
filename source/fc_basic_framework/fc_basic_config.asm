;==================================================================================================
;ROM信息
NES_16KB_PRG_SIZE           =   8   ;16KB PRG大小数量
NES_8KB_CHR_SIZE            =   1   ;8KB CHR大小数量
PRG_8K_BANK_MASK            =   NES_16KB_PRG_SIZE * 2 - 1
;--------------------------------------------------------------------------------------------------
MAPPER_NUMBER               =   4   ;映射器号
SUB_NUMBER                  =   0   ;子映射器号
;--------------------------------------------------------------------------------------------------
;Mapper号       名称      PRG 容量    CHR 容量        IRQ  扩展声音  PRG 窗口                
;--------------------------------------------------------------------------------------------------
;Mapper 1.0:    MMC1      PRG 256KB   CHR 128KB       No      No     PRG 16KB + 16KB(Fixed)        
;--------------------------------------------------------------------------------------------------
;Mapper 4.0:    MMC3      PRG 512KB   CHR 256KB       Yes     No     PRG 8KB * 2 + 16KB(Fixed)     
;--------------------------------------------------------------------------------------------------
;Mapper 5.0:    MMC5      PRG 1024KB  CHR 1024KB      Yes     Yes    PRG 8KB * 4                   
;--------------------------------------------------------------------------------------------------
;Mapper 9.0:    MMC2      PRG 128KB   CHR 128KB       No      No     PRG 8KB + 24KB(Fixed)         
;--------------------------------------------------------------------------------------------------
;Mapper 10.0:   MMC4      PRG 256KB   CHR 128KB       No      No     PRG 16KB + 16KB(Fixed)        
;--------------------------------------------------------------------------------------------------
;Mapper 19.0:   Namco 163 PRG 512KB   CHR 256KB       Yes     Yes    PRG 8KB * 3 + 8KB(Fixed)      
;--------------------------------------------------------------------------------------------------
;Mapper 21.0:   VRC4a     PRG 256KB   CHR 512KB       Yes     No     PRG 8KB * 2  + 16KB(Fixed)    
;Mapper 21.1:   VRC4a     PRG 256KB   CHR 512KB       Yes     No     PRG 8KB * 2  + 16KB(Fixed)    
;Mapper 21.2:   VRC4c     PRG 256KB   CHR 512KB       Yes     No     PRG 8KB * 2  + 16KB(Fixed)    
;--------------------------------------------------------------------------------------------------
;Mapper 22.0    VRC2a     PRG 256KB   CHR 256KB       No      No     PRG 8KB * 2  + 16KB(Fixed)    
;--------------------------------------------------------------------------------------------------
;Mapper 23.0:   VRC4e     PRG 256KB   CHR 512KB       Yes     No     PRG 8KB * 2  + 16KB(Fixed)    
;Mapper 23.1:   VRC4f     PRG 256KB   CHR 512KB       Yes     No     PRG 8KB * 2  + 16KB(Fixed)    
;Mapper 23.2:   VRC4e     PRG 256KB   CHR 512KB       Yes     No     PRG 8KB * 2  + 16KB(Fixed)    
;Mapper 23.3:   VRC2b     PRG 256KB   CHR 256KB       No      No     PRG 8KB * 2  + 16KB(Fixed)    
;--------------------------------------------------------------------------------------------------
;Mapper 25.0:   VRC4d     PRG 256KB   CHR 512KB       Yes     No     PRG 8KB * 2  + 16KB(Fixed)    
;Mapper 25.1:   VRC4b     PRG 256KB   CHR 512KB       Yes     No     PRG 8KB * 2  + 16KB(Fixed)    
;Mapper 25.2:   VRC4d     PRG 256KB   CHR 512KB       Yes     No     PRG 8KB * 2  + 16KB(Fixed)    
;Mapper 25.3:   VRC2c     PRG 256KB   CHR 256KB       No      No     PRG 8KB * 2  + 16KB(Fixed)    
;--------------------------------------------------------------------------------------------------
;Mapper 24.0    VRC6a     PRG 256KB   CHR 256KB       Yes     Yes    PRG 16KB + 8KB + 8KB(Fixed)   
;Mapper 26.0    VRC6b     PRG 256KB   CHR 256KB       Yes     Yes    PRG 16KB + 8KB + 8KB(Fixed)   
;--------------------------------------------------------------------------------------------------
;Mapper 69.0:   FME-7     PRG 512KB   CHR 256KB       Yes     Yes    PRG 8KB * 3 + 8KB(Fixed)      
;--------------------------------------------------------------------------------------------------
;Mapper 73.0:   VRC3      PRG 128KB   CHR 8KB         Yes     No     PRG 16KB + 16KB(Fixed)        
;--------------------------------------------------------------------------------------------------
;Mapper 75.0:   VRC1      PRG 128KB   CHR 128KB       No      No     PRG 8KB * 3 + 8KB(Fixed)      
;--------------------------------------------------------------------------------------------------
;Mapper 85.0:   VRC7      PRG 512KB   CHR 256KB       Yes     Yes    PRG 8KB * 3 + 8KB Fixed       
;==================================================================================================
FC_PRG_E000                 =   NES_16KB_PRG_SIZE * 2 - 1   ;最后一个 8KB bank
FC_PRG_C000                 =   NES_16KB_PRG_SIZE * 2 - 2   ;倒数第2个 8KB bank


    .IF (1 = MAPPER_NUMBER) | (10 = MAPPER_NUMBER) | (24 = MAPPER_NUMBER) | (26 = MAPPER_NUMBER) | (73 = MAPPER_NUMBER)
MAPPER_PRG_8KB_SUPPORT      =   0
    .ELSE
MAPPER_PRG_8KB_SUPPORT      =   1
    .ENDIF

;==================================================================================================
;文件头信息
    .INESPRG NES_16KB_PRG_SIZE      ;16KB PRG 数量, $01-$EF8(1-3832),即16-61,312 KB
    .INESCHR NES_8KB_CHR_SIZE       ;8KB CHR 数量,$01-$EF8(1-3832),即0-30,656 KB
    .INESMAP MAPPER_NUMBER          ;Mapper号 (0-4095)
    ;.INESSUBMAP 0                   ;子Mapper号 (0-15)
    ;.INESMIR 0                      ;命名表镜像 (0: 水平 1: 垂直 2: 四屏)
    ;.INESBAT 0                      ;指定是否存在电池备份 (0: 不存在 1: 存在)
    ;.INESPRGRAM 0                   ;指定 PRG RAM 大小 (大小 = 64字节 << 计数)
    ;.INESPRGNVRAM 0                 ;指定 PRG NVRAM 大小(大小 = 64字节 << 计数)
    ;.INESCHRRAM 0                   ;指定 CHR RAM 大小(大小 = 64字节 << 计数)
    ;.INESCHRNVRAM 0                 ;指定 CHR NVRAM 大小(大小 = 64字节 << 计数)
    ;.INESTIM 0                      ;指定时序 (0: NTSC, 1: PAL, 2: 多区域, 3: Dendy)
;==================================================================================================
;文本列表翻页
ITEM_COUNT_MAX              =   65536                   ;项总数(1-65536)
ITEM_INDEX_MAX              =   ITEM_COUNT_MAX - 1      ;项最大索引(0-65535)
ITEM_PAGE_SIZE              =   20                      ;每页项数量(1-20)
LIST_ITEM_POS               =   $2118                   ;列表显示位置
LIST_ITEM_LINE_SPACING      =   0                       ;列表空行(0-2)
ITEM_PAGE_BUFFER_SIZE       =   5                       ;每页刷新项缓冲数量(1-4)
;-------------------------------------------------
;音乐播放
MUSIC_PLAY_ENABLE           =   1       ;启用音乐播放
MUSIC_INFO_POS              =   $218C   ;曲目信息位置
SOUND_CLEAR_ENABLE          =   1       ;启用音乐清理
;-------------------------------------------------
;按键连发配置
FC_GAMEPAD_BURST_TIME       =   20      ;连发触发帧数
FC_GAMEPAD_BURST_INTERVAL   =   06      ;连发间隔帧数
;-------------------------------------------------
;光标配置
ITEM_CURSOR_TILE_ID_X       =   $1F
ITEM_CURSOR_OFFSET_X        =   0
ITEM_CURSOR_OFFSET_Y        =   0

;-------------------------------------------------
    .IF 1 != ITEM_PAGE_SIZE
    
    .IF 0 = (ITEM_COUNT_MAX % ITEM_PAGE_SIZE)
PAGE_COUNT_MAX              =   ITEM_COUNT_MAX / ITEM_PAGE_SIZE
    .ELSE
PAGE_COUNT_MAX              =   (ITEM_COUNT_MAX / ITEM_PAGE_SIZE) + 1
    .ENDIF
    
    .ELSE
    
PAGE_COUNT_MAX              =   ITEM_COUNT_MAX

    .ENDIF

    .IF 1 != ITEM_PAGE_SIZE
PAGE_INDEX_MAX              =   (ITEM_COUNT_MAX / ITEM_PAGE_SIZE) * ITEM_PAGE_SIZE
    .ELSE
PAGE_INDEX_MAX              =   ITEM_INDEX_MAX
    .ENDIF

;=================================================
;零页内存分配
Use_Zero_Page_Begin         =   $40
    .RSSET  Use_Zero_Page_Begin
;=================================================
FC_Data_Addr_L              .RS 1
FC_Data_Addr_H              .RS 1
FC_Data_Count               .RS 1
FC_Data_Index               .RS 1

Use_Zero_Page_End           .RS 1

    .RSSET  $200
OAM_DMA_Buffer              .RS $100
;=================================================
;非零页内存分配
Use_Non_Zero_Page_Begin     =   $300
;=================================================
;PPU操作内存分配
    .RSSET  Use_Non_Zero_Page_Begin
;-------------------------------------------------
FC_PPU_Buf_Addr             .RS $80     ;PPU数据缓冲地址
FC_PPU_Pal_Addr             .RS $20     ;PPU调色板缓冲地址
FC_PPU_Ctrl                 .RS 1       ;PPU控制缓冲
FC_PPU_Mask                 .RS 1       ;PPU掩码缓冲
FC_PPU_H_Scroll             .RS 1       ;PPU水平滚动缓冲
FC_PPU_V_Scroll             .RS 1       ;PPU垂直滚动缓冲
FC_PPU_Buf_Count            .RS 1       ;PPU数据缓冲待处理数据量
FC_Nmi_Task_Busy            .RS 1       ;NMI 任务繁忙标记
FC_DMA_Count                .RS 1
;-------------------------------------------------
;PRG 8KB Bank 备份
FC_Music_Prg_8000           .RS 1
FC_Music_Prg_A000           .RS 1
FC_Music_Prg_C000           .RS 1
FC_Music_Prg_E000           .RS 1
FC_Prg_8000                 .RS 1
FC_Prg_A000                 .RS 1
FC_Prg_C000                 .RS 1
FC_Prg_E000                 .RS 1
FC_Music_DMC_Offset         .RS 1
;=================================================
;手柄输入内存分配
FC_GAMEPAD_COUNT            =   2       ;输入设备数量
FC_Gamepad_Keep             .RS FC_GAMEPAD_COUNT       ;按住状态
FC_Gamepad_Once_Down        .RS FC_GAMEPAD_COUNT       ;单次按下
FC_Gamepad_Keep_Last        .RS FC_GAMEPAD_COUNT       ;上次按住状态
FC_Gamepad_Once_Up          .RS FC_GAMEPAD_COUNT       ;单次弹起
FC_Gamepad_Temp             .RS FC_GAMEPAD_COUNT       ;按键缓冲
FC_Gamepad_Buf              .RS FC_GAMEPAD_COUNT       ;按键缓冲
FC_Gamepad_Status           .RS FC_GAMEPAD_COUNT       ;按键读取状态
FC_Gamepad_Burst_Delay      .RS FC_GAMEPAD_COUNT       ;按键连发延迟
;=================================================
FC_Mapper_Control           .RS 1       ;Mapper 占用
;=================================================
;IRQ内存分配
FC_Irq_Latch_L              .RS 1       ;IRQ 扫描线触发值(仅扫描线模式)  /  ;IRQ 触发值低位(仅CPU周期模式)
FC_Irq_Latch_H              .RS 1       ;IRQ 触发值高位(仅CPU周期模式)
FC_Irq_Interval_L           .RS 1       ;IRQ 触发间隔低位
FC_Irq_Interval_H           .RS 1       ;IRQ 触发间隔高位
FC_Irq_Index                .RS 1       ;IRQ 操作索引
FC_Irq_Scroll               .RS 1       ;IRQ 发生时设置 PPU 的滚动值
;=================================================
;音乐播放
FC_Music_Index              .RS 1       ;曲目
FC_Music_Index_Max          .RS 1       ;最大曲目索引
FC_HEX_Data_L               .RS 1       ;十六进制数据低位
FC_HEX_Data_H               .RS 1       ;十六进制数据高位
FC_Dec_16                   .RS 5       ;十进制数据
FC_HEX_Data                 = FC_HEX_Data_L
FC_Dec_1                    = FC_Dec_16 + 0
FC_Dec_10                   = FC_Dec_16 + 1
FC_Dec_100                  = FC_Dec_16 + 2
;=================================================
;文本列表翻页
FC_Item_Index_L             .RS 1       ;当前索引低位
FC_Item_Index_H             .RS 1       ;当前索引高位
FC_Item_Index_Last_L        .RS 1       ;上次索引低位
FC_Item_Index_Last_H        .RS 1       ;上次索引高位
FC_Page_Index_L             .RS 1       ;当前页起始索引低位
FC_Page_Index_H             .RS 1       ;当前页起始索引高位
FC_Page_Index_Last_L        .RS 1       ;上次页起始索引低位
FC_Page_Index_Last_H        .RS 1       ;上次页起始索引高位
FC_Temp_Src_Index_L         .RS 1       ;临时索引低位
FC_Temp_Src_Index_H         .RS 1       ;临时索引高位
FC_Temp_Dest_Index_L        .RS 1       ;临时索引低位
FC_Temp_Dest_Index_H        .RS 1       ;临时索引高位
FC_Item_Count_L             .RS 1       ;计数索引低位
FC_Item_Count_H             .RS 1       ;计数索引高位
FC_Page_Item_Index          .RS 1       ;计数索引低位
FC_Page_Item_Buffer         .RS 1       ;计数索引高位
;=================================================
Use_Non_Zero_Page_End       .RS 1

;=================================================
;常量定义
;-------------------------------------------------
;PPU缓冲处理模式
FC_PPU_MODE_LINE            =   $FE     ;单行文本写入模式
FC_PPU_MODE_CLEAR           =   $FD     ;单行文本清理模式
;-------------------------------------------------
;手柄按键常量
JOY_KEY_UP                  =   $08     ;上
JOY_KEY_DOWN                =   $04     ;下
JOY_KEY_LEFT                =   $02     ;左
JOY_KEY_RIGHT               =   $01     ;右
JOY_KEY_SELECT              =   $20     ;选择
JOY_KEY_START               =   $10     ;开始
JOY_KEY_B                   =   $40     ;B
JOY_KEY_A                   =   $80     ;A

;=================================================
;文本数据定义工具宏
    .MACRO MACRO_TEXT_DATA
        .DB \1
        .DW \2
        .USTR \3
    .ENDM
;=================================================
;文本数据位置索引常量
TEXT_INFO_INDEX_FLAG        =   0   ;文本显示控制偏移
TEXT_INFO_INDEX_POS_L       =   1   ;文本显示地址偏移
TEXT_INFO_INDEX_POS_H       =   2   ;文本显示地址偏移
TEXT_INFO_INDEX_DATA        =   3   ;文本数据地址偏移

;=================================================
;音乐数据宏
    .MACRO MACRO_INCBIN_NSF_DATA
        .INCBIN \1,\2,\3
    .ENDM
