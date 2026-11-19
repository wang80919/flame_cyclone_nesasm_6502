;==============================
;转换十进制到PPU缓冲
FC_Convert_Dec_To_PPU_10000
    LDA FC_Dec_16 + 4
    ORA #'0'
    STA FC_PPU_Buf_Addr,X
    INX
FC_Convert_Dec_To_PPU_1000
    LDA FC_Dec_16 + 3
    ORA #'0'
    STA FC_PPU_Buf_Addr,X
    INX
FC_Convert_Dec_To_PPU_100
    LDA FC_Dec_16 + 2
    ORA #'0'
    STA FC_PPU_Buf_Addr,X
    INX
FC_Convert_Dec_To_PPU_10
    LDA FC_Dec_16 + 1
    ORA #'0'
    STA FC_PPU_Buf_Addr,X
    INX
FC_Convert_Dec_To_PPU_1
    LDA FC_Dec_16 + 0
    ORA #'0'
    STA FC_PPU_Buf_Addr,X
    INX
    RTS
    
;=================================================
;位十六进制转十进制(16位)
;65535耗时1054
;59999耗时1732
;9999耗时1507
;999耗时1054
;99耗时616
;9耗时130
FC_HEX_To_Dec
FC_HEX_To_Dec_16
    BCC FC_HEX_To_Dec_16_0_65535
    LDA #06
    STA FC_Dec_16 + 4
    LDA #05
    STA FC_Dec_16 + 3
    LDA #05
    STA FC_Dec_16 + 2
    LDA #03
    STA FC_Dec_16 + 1
    LDA #06
    STA FC_Dec_16 + 0
    RTS
FC_HEX_To_Dec_16_0_65535
    TXA
    PHA
    TYA
    PHA
    LDY #$00
    LDX #$04
FC_HEX_To_Dec_16_Begin
    LDA FC_HEX_Data_H
    CMP FC_HEX_To_Dec_16_Data_H,X
    BCC FC_HEX_To_Dec_16_Continue
    BNE FC_HEX_To_Dec_16_Sub_L
    LDA FC_HEX_Data_L
    CMP FC_HEX_To_Dec_16_Data_L,X
    BCC FC_HEX_To_Dec_16_Continue
FC_HEX_To_Dec_16_Sub_L
    LDA FC_HEX_Data_L
    SBC FC_HEX_To_Dec_16_Data_L,X
    STA FC_HEX_Data_L
    BCS FC_HEX_To_Dec_16_Sub_H
    DEC FC_HEX_Data_H
FC_HEX_To_Dec_16_Sub_H
    LDA FC_HEX_Data_H
    SEC
    SBC FC_HEX_To_Dec_16_Data_H,X
    STA FC_HEX_Data_H
    INY
    BNE FC_HEX_To_Dec_16_Begin
FC_HEX_To_Dec_16_Continue
    PHA
    TYA
    STA FC_Dec_16,X
    PLA
    LDY #$00
    DEX
    BNE FC_HEX_To_Dec_16_Begin
    STA FC_Dec_16
    PLA
    TAY
    PLA
    TAX
    RTS

FC_HEX_To_Dec_16_Data_L
    .DB $01,$0A,$64,$E8,$10
FC_HEX_To_Dec_16_Data_H
    .DB $00,$00,$00,$03,$27
