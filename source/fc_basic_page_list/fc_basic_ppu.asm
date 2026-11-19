;=================================================
;PPU缓冲数据处理
FC_PPU_Buffer_Process
    LDX FC_PPU_Buf_Count
    BEQ FC_PPU_Palette_Buffer_Process
    LDA #$00
    STA FC_PPU_Buf_Count
    STA FC_PPU_Buf_Addr,X
    TAX
    
    ;关闭 PPU 显示
    LDA #$00
    STA PPU_MASK            ;$2001
    JSR FC_PPU_Buffer_Mode_Select

;PPU调色板缓冲处理
FC_PPU_Palette_Buffer_Process
    LDA #$3F
    STA PPU_ADDRESS         ;$2006
    LDA #$00
    STA PPU_ADDRESS         ;$2006
    LDX #$00
    LDY #$20
FC_PPU_Palette_Buffer_Write
    LDA FC_PPU_Pal_Addr,X
    STA PPU_DATA            ;$2007
    INX
    DEY
    BNE FC_PPU_Palette_Buffer_Write
    
FC_PPU_Buffer_Process_End
    
    ;重置 PPU 位置
    LDA #$00
    STA PPU_ADDRESS         ;$2006
    STA PPU_ADDRESS         ;$2006
    
    ;恢复 PPU 滚动
    LDA FC_PPU_H_Scroll
    STA PPU_SCROLL          ;$2005
    LDA FC_PPU_V_Scroll
    STA PPU_SCROLL          ;$2005
    
    ;恢复 PPU 显示
    LDA FC_PPU_Mask
    STA PPU_MASK            ;$2001
    
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
    STA PPU_ADDRESS         ;$2006
    INX
    LDA FC_PPU_Buf_Addr,X
    STA PPU_ADDRESS         ;$2006
    INX
    LDY FC_PPU_Buf_Addr,X
    INX
FC_PPU_Buffer_Line_Write
    LDA FC_PPU_Buf_Addr,X
    STA PPU_DATA            ;$2007
    INX
    DEY
    BNE FC_PPU_Buffer_Line_Write
    BEQ FC_PPU_Buffer_Mode_Select
    
;单行文本清除处理
FC_PPU_Buffer_Clear
    LDA FC_PPU_Buf_Addr,X
    STA PPU_ADDRESS         ;$2006
    INX
    LDA FC_PPU_Buf_Addr,X
    STA PPU_ADDRESS         ;$2006
    INX
    LDY FC_PPU_Buf_Addr,X
    INX
    LDA #$00
FC_PPU_Buffer_Clear_Write
    STA PPU_DATA            ;$2007
    DEY
    BNE FC_PPU_Buffer_Clear_Write
    BEQ FC_PPU_Buffer_Mode_Select
