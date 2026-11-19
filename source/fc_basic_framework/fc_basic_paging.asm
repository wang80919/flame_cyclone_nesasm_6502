;=================================================
;记录上次项索引
FC_Item_Index_Save
    LDA FC_Item_Index_L
    STA FC_Item_Index_Last_L
    LDA FC_Item_Index_H
    STA FC_Item_Index_Last_H
    RTS

;=================================================
;记录上次页起始索引
FC_Page_Index_Save
    LDA FC_Page_Index_L
    STA FC_Page_Index_Last_L
    LDA FC_Page_Index_H
    STA FC_Page_Index_Last_H
    RTS

;=================================================
;比较索引
FC_Cmp_Item_Index
    LDA FC_Temp_Src_Index_H
    CMP FC_Temp_Dest_Index_H
    BNE .End
    LDA FC_Temp_Src_Index_L
    CMP FC_Temp_Dest_Index_L
.End
    RTS

;=================================================
;更新项索引
FC_Page_Item_Index_Update

    ;记录上次索引在上次页起始索引的位置
    SEC 
    LDA FC_Item_Index_Last_L
    SBC FC_Page_Index_Last_L
    STA FC_Temp_Dest_Index_L
    
    LDA FC_Item_Index_Last_H
    SBC FC_Page_Index_Last_H
    STA FC_Temp_Dest_Index_H
    
    ;得到当前项索引
    CLC
    LDA FC_Temp_Dest_Index_L
    ADC FC_Page_Index_L
    STA FC_Temp_Src_Index_L
    LDA FC_Temp_Dest_Index_H
    ADC FC_Page_Index_H
    STA FC_Temp_Src_Index_H
    BCS .Update_Item_Index_Max  ;产生进位, 超过65535则需要限制
    
    LDA #<ITEM_INDEX_MAX
    STA FC_Temp_Dest_Index_L
    LDA #>ITEM_INDEX_MAX
    STA FC_Temp_Dest_Index_H
    JSR FC_Cmp_Item_Index
    BCC .Update_Item_Index

;限制项最大索引
.Update_Item_Index_Max
    LDA #<ITEM_INDEX_MAX
    STA FC_Item_Index_L
    LDA #>ITEM_INDEX_MAX
    STA FC_Item_Index_H
    RTS

;更新项索引
.Update_Item_Index
    LDA FC_Temp_Src_Index_L
    STA FC_Item_Index_L
    LDA FC_Temp_Src_Index_H
    STA FC_Item_Index_H
    RTS

;=================================================
;前一个
FC_Item_Pre
    JSR FC_Item_Index_Save
    JSR FC_Page_Index_Save
    
    ;检查是否需要切换到最后一项
    LDA FC_Item_Index_L
    ORA FC_Item_Index_H
    BNE .Item_Index_Pre

;设置为最后一项
.Item_Index_Max
    LDA #<PAGE_INDEX_MAX
    STA FC_Page_Index_L
    LDA #>PAGE_INDEX_MAX
    STA FC_Page_Index_H
    
    LDA #<ITEM_INDEX_MAX
    STA FC_Item_Index_L
    LDA #>ITEM_INDEX_MAX
    STA FC_Item_Index_H
    
    JSR FC_Page_Index_Changed
    RTS
    
;设置为前一项
.Item_Index_Pre

    ;获取前一项索引
    SEC
    LDA FC_Item_Index_L
    SBC #$01
    STA FC_Temp_Src_Index_L
    LDA FC_Item_Index_H
    SBC #$00
    STA FC_Temp_Src_Index_H
    
    ;获取触发翻页临界索引
    LDA FC_Page_Index_L
    STA FC_Temp_Dest_Index_L
    LDA FC_Page_Index_H
    STA FC_Temp_Dest_Index_H
    
    ;检查是否切换到前一页
    SEC
    LDA FC_Item_Index_L
    SBC #$01
    STA FC_Item_Index_L
    LDA FC_Item_Index_H
    SBC #$00
    STA FC_Item_Index_H
    
    ;检查是否需要翻页
    JSR FC_Cmp_Item_Index
    BCS .Item_Index_Pre_Item_Change
    
    SEC
    LDA FC_Page_Index_L
    SBC #ITEM_PAGE_SIZE
    STA FC_Page_Index_L
    LDA FC_Page_Index_H
    SBC #$00
    STA FC_Page_Index_H
    
    JSR FC_Page_Index_Changed
    RTS

.Item_Index_Pre_Item_Change
    JSR FC_Item_Index_Changed
    RTS

;=================================================
;下一个
FC_Item_Next
    JSR FC_Item_Index_Save
    JSR FC_Page_Index_Save

    ;检查是否需要切换到最前一项
    LDA FC_Item_Index_L
    CMP #<ITEM_INDEX_MAX
    BNE .Item_Index_Next
    LDA FC_Item_Index_H
    CMP #>ITEM_INDEX_MAX
    BNE .Item_Index_Next

;设置为最前一项
.Item_Index_Min
    LDA #$00
    STA FC_Page_Index_L
    STA FC_Page_Index_H
    STA FC_Item_Index_L
    STA FC_Item_Index_H
    
    JSR FC_Page_Index_Changed
    RTS

.Item_Index_Next
    
    ;获取下一项索引
    CLC
    LDA FC_Item_Index_L
    ADC #$01
    STA FC_Temp_Src_Index_L
    LDA FC_Item_Index_H
    ADC #$00
    STA FC_Temp_Src_Index_H
    
    ;获取触发翻页临界索引
    CLC
    LDA FC_Page_Index_L
    ADC #ITEM_PAGE_SIZE
    STA FC_Temp_Dest_Index_L
    LDA FC_Page_Index_H
    ADC #$00
    STA FC_Temp_Dest_Index_H
    BCC .Item_Index_Next_Normal
    JSR .Item_Index_Next_Update
    
    JSR FC_Item_Index_Changed
    RTS

.Item_Index_Next_Normal
    JSR .Item_Index_Next_Update
    
    ;检查是否需要翻页
    JSR FC_Cmp_Item_Index
    BCC .Item_Index_Next_Item_Change
    
    CLC
    LDA FC_Page_Index_L
    ADC #ITEM_PAGE_SIZE
    STA FC_Page_Index_L
    LDA FC_Page_Index_H
    ADC #$00
    STA FC_Page_Index_H
    
    JSR FC_Page_Index_Changed
    RTS
    
.Item_Index_Next_Item_Change
    JSR FC_Item_Index_Changed
    RTS
    
;项索引递增1
.Item_Index_Next_Update
    CLC
    LDA FC_Item_Index_L
    ADC #$01
    STA FC_Item_Index_L
    LDA FC_Item_Index_H
    ADC #$00
    STA FC_Item_Index_H
    RTS

;=================================================
;前一页
FC_Page_Pre
    JSR FC_Item_Index_Save
    JSR FC_Page_Index_Save
    
    ;检查是否需要切换到最后页
    LDA FC_Page_Index_L
    ORA FC_Page_Index_H
    BNE .Page_Index_Pre

;最后页
.Page_Index_Max
    LDA #<PAGE_INDEX_MAX
    STA FC_Page_Index_L
    LDA #>PAGE_INDEX_MAX
    STA FC_Page_Index_H
    JSR FC_Page_Item_Index_Update
    JSR FC_Page_Index_Changed
    RTS

;前一页
.Page_Index_Pre
    SEC
    LDA FC_Page_Index_L
    SBC #ITEM_PAGE_SIZE
    STA FC_Page_Index_L
    LDA FC_Page_Index_H
    SBC #$00
    STA FC_Page_Index_H
    JSR FC_Page_Item_Index_Update
    JSR FC_Page_Index_Changed
    RTS

;=================================================
;下一页
FC_Page_Next
    JSR FC_Item_Index_Save
    JSR FC_Page_Index_Save
    
    ;检查是否需要切换到最前页
    LDA FC_Page_Index_L
    CMP #<PAGE_INDEX_MAX
    BNE .Page_Index_Next
    LDA FC_Page_Index_H
    CMP #>PAGE_INDEX_MAX
    BNE .Page_Index_Next

;最前页
.Page_Index_Min
    LDA #$00
    STA FC_Page_Index_L
    STA FC_Page_Index_H
    JSR FC_Page_Item_Index_Update
    JSR FC_Page_Index_Changed
    RTS

;下一页
.Page_Index_Next
    CLC
    LDA FC_Page_Index_L
    ADC #ITEM_PAGE_SIZE
    STA FC_Page_Index_L
    LDA FC_Page_Index_H
    ADC #$00
    STA FC_Page_Index_H
    JSR FC_Page_Item_Index_Update
    JSR FC_Page_Index_Changed
    RTS
    
;=================================================
;项索引变化
FC_Item_Index_Changed
    LDA #17 - 1
    STA FC_Music_Index
    JSR Music_Init_Process
    RTS

;=================================================
;页索引变化
FC_Page_Index_Changed
    LDA #19 - 1
    STA FC_Music_Index
    JSR Music_Init_Process
    JSR Page_List_Update
    RTS

;======================================================================
;翻页测试
FC_Page_Test
    LDA FC_Nmi_Task_Busy
    BNE .End
.Item_Pre
    LDA FC_Gamepad_Once_Down
    AND #JOY_KEY_LEFT
    BEQ .Item_Next
    JSR FC_Page_Pre
.Item_Next
    LDA FC_Gamepad_Once_Down
    AND #JOY_KEY_RIGHT | JOY_KEY_SELECT
    BEQ .Page_Pre
    JSR FC_Page_Next
.Page_Pre
    LDA FC_Gamepad_Once_Down
    CMP #JOY_KEY_UP
    BNE .Page_Next
    JSR FC_Item_Pre
.Page_Next
    LDA FC_Gamepad_Once_Down
    CMP #JOY_KEY_DOWN
    BNE .End
    JSR FC_Item_Next
.End
    RTS
