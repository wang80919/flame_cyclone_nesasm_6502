FC_Cursor_Show

    LDA FC_Item_Index_L
    SEC
    SBC FC_Page_Index_L
    ASL A
    TAY
    
    ;得到文本显示位置
    LDA Page_List_Item_Pos + 0,Y
    AND #$E0
    STA FC_Data_Addr_L
    LDA Page_List_Item_Pos + 1,Y
    AND #$03
    STA FC_Data_Addr_H
    
    LSR FC_Data_Addr_H
    ROR FC_Data_Addr_L
    
    LSR FC_Data_Addr_H
    ROR FC_Data_Addr_L
    
    ;光标Y坐标
    LDX FC_DMA_Count
    LDA FC_Data_Addr_L
    SEC
    SBC #$01
    STA OAM_DMA_Buffer + $00,X
    CLC
    ADC #ITEM_CURSOR_OFFSET_Y
    STA OAM_DMA_Buffer + $00,X
    
    ;光标Tile
    LDA #ITEM_CURSOR_TILE_ID_X
    STA OAM_DMA_Buffer + $01,X
    
    ;光标属性
    LDA #$00
    STA OAM_DMA_Buffer + $02,X
    
    ;光标X坐标
    LDA FC_Item_Index_L
    SEC
    SBC FC_Page_Index_L
    ASL A
    TAY
    LDA Page_List_Item_Pos + 0,Y
    AND #$1F
    ASL A
    ASL A
    ASL A
    SEC
    SBC #08
    STA OAM_DMA_Buffer + $03,X
    CLC
    ADC #ITEM_CURSOR_OFFSET_X
    STA OAM_DMA_Buffer + $03,X
    STX FC_DMA_Count
    
.End
    RTS