;======================================================================
;按键值检测             左  上  下  右 选择 开始 B  A
Joystick_Key    .DB $02,$08,$04,$01,$20,$10,$40,$80

;按键状态纵坐标
Joystick_Key_Y  .DB $88,$80,$90,$88,$90,$90,$90,$90

;按键状态横坐标
Joystick_Key_X  .DB $58,$60,$60,$68,$78,$82,$94,$9E

;=================================================
;
Joystick_Once_Down_Text_Group_Set
    LDA #<Joy_Text_Data_Index
    STA FC_Data_Addr_L
    LDA #>Joy_Text_Data_Index
    STA FC_Data_Addr_H
    RTS

;=================================================
;单次按下测试
Joystick_Once_Down_Show
    LDX #$00
    
.Check
    TXA
    ASL
    ASL
    TAY
    LDA Joystick_Key_Y,X
    SEC
    SBC #$01
    STA OAM_DMA_Buffer,Y
    INY
    LDA #$1D
    STA OAM_DMA_Buffer,Y
    INY
    LDA #$00
    STA OAM_DMA_Buffer,Y
    INY
    LDA Joystick_Key_X,X
    STA OAM_DMA_Buffer,Y
    INY
    STY FC_DMA_Count
    
    LDA FC_Gamepad_Once_Down
    ORA FC_Gamepad_Once_Down + 1
    AND Joystick_Key,X
    BEQ .Next
    TXA
    ASL
    ASL
    TAY
    INY
    
    LDA #$1E
    STA OAM_DMA_Buffer,Y
    
    STX FC_Data_Index
    PHA
    TXA
    PHA
    TYA
    PHA
    
    ;写入测试文本, 需要先切页
    LDA #BANK(Joy_Text_Data_Index)
    JSR Mapper_Prg_8000_Banking
    JSR Joystick_Once_Down_Text_Group_Set
    JSR Get_Text_Data_By_Group_Index    ;获取文本信息
    JSR Write_Text_Item_By_Buffer       ;写入文本数据
    
    PLA
    TAY
    PLA
    TAX
    PLA
    
.Next
    INX
    CPX #$08
    BCC .Check

.End
    RTS

;=================================================
;单次弹起测试
Joystick_Once_Up_Show
    LDX #$00
.Check
    TXA
    ASL
    ASL
    CLC
    ADC #$20
    TAY
    SEC
    SBC #$01
    LDA Joystick_Key_Y,X
    CLC
    ADC #$40
    STA OAM_DMA_Buffer,Y
    INY
    LDA #$1D
    STA OAM_DMA_Buffer,Y
    INY
    LDA #$00
    STA OAM_DMA_Buffer,Y
    INY
    LDA Joystick_Key_X,X
    STA OAM_DMA_Buffer,Y
    INY
    STY FC_DMA_Count
    
    LDA FC_Gamepad_Once_Up
    ORA FC_Gamepad_Once_Up + 1
    AND Joystick_Key,X
    BEQ .Next
    TXA
    ASL
    ASL
    CLC
    ADC #$20
    TAY
    INY
    
    LDA #$1E
    STA OAM_DMA_Buffer,Y
    
    STX FC_Data_Index
    PHA
    TXA
    PHA
    TYA
    PHA
    
    ;写入测试文本, 需要先切页
    LDA #BANK(Joy_Text_Data_Index)
    JSR Mapper_Prg_8000_Banking
    JSR Joystick_Once_Down_Text_Group_Set
    JSR Get_Text_Data_By_Group_Index    ;获取文本信息
    JSR Clear_Text_Item_By_Buffer       ;写入文本数据
    
    PLA
    TAY
    PLA
    TAX
    PLA
    
.Next
    INX
    CPX #$08
    BCC .Check

.End
    RTS

;=================================================
;按住测试
Joystick_Keey_Show
    LDX #$00
.Check
    TXA
    ASL
    ASL
    CLC
    ADC #$40
    TAY
    LDA Joystick_Key_Y,X
    CLC
    ADC #$20
    SEC
    SBC #$01
    STA OAM_DMA_Buffer,Y
    INY
    LDA #$1D
    STA OAM_DMA_Buffer,Y
    INY
    LDA #$00
    STA OAM_DMA_Buffer,Y
    INY
    LDA Joystick_Key_X,X
    STA OAM_DMA_Buffer,Y
    INY
    STY FC_DMA_Count
    
    LDA FC_Gamepad_Keep
    AND Joystick_Key,X
    BEQ .Next
    TXA
    ASL
    ASL
    CLC
    ADC #$40
    TAY
    INY
    LDA #$1E
    STA OAM_DMA_Buffer,Y
.Next
    INX
    CPX #$08
    BCC .Check

.End
    RTS

