;======================================================================
;页文本列表项显示位置
Page_List_Item_Pos
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*00 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*01 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*02 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*03 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*04 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*05 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*06 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*07 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*08 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*09 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*10 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*11 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*12 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*13 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*14 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*15 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*16 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*17 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*18 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*19 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*20 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*21 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*22 + $00)
    .DW LIST_ITEM_POS+(($20*(LIST_ITEM_LINE_SPACING+1))*23 + $00)

;======================================================================
;写入文本PPU位置
Page_List_Item_Pos_Write
    LDA FC_Page_Item_Index
    ASL A
    TAY
    LDA Page_List_Item_Pos + 1,Y
    STA FC_PPU_Buf_Addr,X
    INX
    LDA Page_List_Item_Pos + 0,Y
    STA FC_PPU_Buf_Addr,X
    INX
    RTS

;======================================================================
;页文本列表项清除
Page_List_Item_Clear
    LDA FC_Page_Item_Index
    CLC
    ADC FC_Page_Index_Last_L
    STA FC_Temp_Src_Index_L
    
    LDA FC_Item_Count_H
    ADC FC_Page_Index_Last_H
    STA FC_Temp_Src_Index_H
    
    LDA #<ITEM_INDEX_MAX
    STA FC_Temp_Dest_Index_L
    LDA #>ITEM_INDEX_MAX
    STA FC_Temp_Dest_Index_H
    
    JSR FC_Cmp_Item_Index
    BEQ .Start
    BCS .End

.Start

    LDX FC_PPU_Buf_Count
    
    ;写入行模式
    LDA #FC_PPU_MODE_CLEAR
    STA FC_PPU_Buf_Addr,X
    INX
    
    JSR Page_List_Item_Pos_Write
    
    LDA #$05
    STA FC_PPU_Buf_Addr,X
    INX
    
    STX FC_PPU_Buf_Count
.End
    RTS

;======================================================================
;页文本列表项写入
Page_List_Item_Write

    LDA FC_Page_Item_Index
    CLC
    ADC FC_Page_Index_L
    STA FC_Temp_Src_Index_L
    
    LDA FC_Item_Count_H
    ADC FC_Page_Index_H
    STA FC_Temp_Src_Index_H
    BCS .End
    
    LDA #<ITEM_INDEX_MAX
    STA FC_Temp_Dest_Index_L
    LDA #>ITEM_INDEX_MAX
    STA FC_Temp_Dest_Index_H
    
    JSR FC_Cmp_Item_Index
    BEQ .Start
    BCS .End

.Start
    LDX FC_PPU_Buf_Count
    
    ;写入行模式
    LDA #FC_PPU_MODE_LINE
    STA FC_PPU_Buf_Addr,X
    INX
    
    JSR Page_List_Item_Pos_Write
    
    ;写入序号
    LDA #$05
    STA FC_PPU_Buf_Addr,X
    INX
    
    LDA FC_Page_Item_Index
    CLC
    ADC FC_Page_Index_L
    STA FC_Temp_Dest_Index_L
    
    LDA FC_Item_Count_H
    ADC FC_Page_Index_H
    STA FC_Temp_Dest_Index_H
    
    LDA FC_Temp_Dest_Index_L
    CLC
    ADC #$01
    STA FC_HEX_Data_L
    LDA FC_Temp_Dest_Index_H
    ADC #$00
    STA FC_HEX_Data_H
    
    JSR FC_HEX_To_Dec_16
    JSR FC_Convert_Dec_To_PPU_10000
    
    STX FC_PPU_Buf_Count
    
.End

    RTS

;======================================================================
;页文本列表更新
Page_List_Update
    LDA #$00
    STA FC_Page_Item_Index
    STA FC_Page_Item_Buffer
    
    ;PPU 缓冲还有数据则处理完
    LDX FC_PPU_Buf_Count
    BEQ .Update_Item_Content
    
    JSR .Page_Buffer_Flush
    
.Update_Item_Content

    JSR Page_List_Item_Clear
    JSR Page_List_Item_Write

    INC FC_Page_Item_Index
    INC FC_Page_Item_Buffer
    
    LDA FC_Page_Item_Buffer
    CMP #ITEM_PAGE_BUFFER_SIZE
    BCC .Update_Item_Content_Continue
    
    ;刷新缓冲
    JSR .Page_Buffer_Flush
    LDA #$00
    STA FC_Page_Item_Buffer
    
.Update_Item_Content_Continue
    LDA FC_Page_Item_Index
    CMP #ITEM_PAGE_SIZE
    BCC .Update_Item_Content

.Update_Item_Finish
    LDA FC_Page_Item_Buffer
    BNE .Page_List_Update_End
    JSR .Page_Buffer_Flush
    LDA #$00
    STA FC_Page_Item_Buffer
.Page_List_Update_End
    
    RTS

;刷新 PPU 缓冲(等待 NMI 处理完缓冲)
.Page_Buffer_Flush
    LDA #$01
    STA FC_Nmi_Task_Busy
.Wait_Vblank
    LDA FC_Nmi_Task_Busy
    BNE .Wait_Vblank
    RTS
    