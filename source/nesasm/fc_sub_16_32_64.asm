;=================================================
;减法运算
;FlameCyclone
;2024.8.7
;=================================================
;减法
;FC_Sub_16              最差耗时 63       指令长度: 16
;FC_Sub_16_Fast         最差耗时 50       指令长度: 17
;FC_Sub_32              最差耗时 109      指令长度: 16
;FC_Sub_32_Fast         最差耗时 86       指令长度: 31
;FC_Sub_64              最差耗时 201      指令长度: 16
;FC_Sub_64_Fast         最差耗时 158      指令长度: 59
;=================================================
FC_Data_Src_L               = $40
FC_Data_Src_H               = $41
FC_Data_Dest_L              = $42
FC_Data_Dest_H              = $43
FC_Data_Result_L            = $44
FC_Data_Result_H            = $45
;=================================================
    .INESPRG 1      ;16KB PRG 数量, $01-$EF8(1-3832),即16-61,312 KB
    .INESCHR 0       ;8KB CHR 数量,$01-$EF8(1-3832),即0-30,656 KB
    .INESMAP 4          ;Mapper号 (0-4095)
    .BANK 1
    .ORG $E000
;=================================================
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
    
    JSR Test

.Loop
    JMP .Loop

;=================================================
Test
    JSR Test_Sub_16
    JSR Test_Sub_16_Fast
    JSR Test_Sub_32
    JSR Test_Sub_32_Fast
    JSR Test_Sub_64
    JSR Test_Sub_64_Fast
    RTS

Test_Sub_16
    LDA #<.Test_Src
    STA FC_Data_Src_L
    LDA #>.Test_Src
    STA FC_Data_Src_H
    LDA #<.Test_Dest
    STA FC_Data_Dest_L
    LDA #>.Test_Dest
    STA FC_Data_Dest_H
    
    BIT $FFFF
    JSR FC_Sub_16
    RTS
.Test_Src
    .DW $FFFF
.Test_Dest
    .DW $FFFF

Test_Sub_16_Fast
    LDA #<.Test_Src
    STA FC_Data_Src_L
    LDA #>.Test_Src
    STA FC_Data_Src_H
    LDA #<.Test_Dest
    STA FC_Data_Dest_L
    LDA #>.Test_Dest
    STA FC_Data_Dest_H
    
    BIT $FFFF
    JSR FC_Sub_16_Fast
    RTS
.Test_Src
    .DW $FFFF
.Test_Dest
    .DW $FFFF

Test_Sub_32
    LDA #<.Test_Src
    STA FC_Data_Src_L
    LDA #>.Test_Src
    STA FC_Data_Src_H
    LDA #<.Test_Dest
    STA FC_Data_Dest_L
    LDA #>.Test_Dest
    STA FC_Data_Dest_H
    
    BIT $FFFF
    JSR FC_Sub_32
    RTS
.Test_Src
    .DW $FFFF
    .DW $FFFF
.Test_Dest
    .DW $FFFF
    .DW $FFFF

Test_Sub_32_Fast
    LDA #<.Test_Src
    STA FC_Data_Src_L
    LDA #>.Test_Src
    STA FC_Data_Src_H
    LDA #<.Test_Dest
    STA FC_Data_Dest_L
    LDA #>.Test_Dest
    STA FC_Data_Dest_H
    
    BIT $FFFF
    JSR FC_Sub_32_Fast
    RTS
.Test_Src
    .DW $FFFF
    .DW $FFFF
.Test_Dest
    .DW $FFFF
    .DW $FFFF

Test_Sub_64
    LDA #<.Test_Src
    STA FC_Data_Src_L
    LDA #>.Test_Src
    STA FC_Data_Src_H
    LDA #<.Test_Dest
    STA FC_Data_Dest_L
    LDA #>.Test_Dest
    STA FC_Data_Dest_H
    
    BIT $FFFF
    JSR FC_Sub_64
    RTS
.Test_Src
    .DW $FFFF
    .DW $FFFF
    .DW $FFFF
    .DW $FFFF
.Test_Dest
    .DW $FFFF
    .DW $FFFF
    .DW $FFFF
    .DW $FFFF

Test_Sub_64_Fast
    LDA #<.Test_Src
    STA FC_Data_Src_L
    LDA #>.Test_Src
    STA FC_Data_Src_H
    LDA #<.Test_Dest
    STA FC_Data_Dest_L
    LDA #>.Test_Dest
    STA FC_Data_Dest_H
    
    BIT $FFFF
    JSR FC_Sub_64_Fast
    RTS
.Test_Src
    .DW $FFFF
    .DW $FFFF
    .DW $FFFF
    .DW $FFFF
.Test_Dest
    .DW $FFFF
    .DW $FFFF
    .DW $FFFF
    .DW $FFFF

;=================================================
;16位整数减法
;最多耗时周期: 63
;编译指令长度: 16
FC_Sub_16
    LDY #$00
    LDX #$02
    SEC
FC_Sub_16_Calc
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    DEX
    BNE FC_Sub_16_Calc
    RTS

;=================================================
;16位整数减法
;最多耗时周期: 50
;编译指令长度: 17
FC_Sub_16_Fast
    LDY #$00
    SEC
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    RTS

;=================================================
;32位整数减法
;最多耗时周期: 109
;编译指令长度: 16
FC_Sub_32
    LDY #$00
    LDX #$04
    SEC
FC_Sub_32_Calc
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    DEX
    BNE FC_Sub_32_Calc
    RTS

;=================================================
;32位整数减法
;最多耗时周期: 86
;编译指令长度: 31
FC_Sub_32_Fast
    LDY #$00
    SEC
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    RTS

;=================================================
;32位整数减法
;最多耗时周期: 201
;编译指令长度: 16
FC_Sub_64
    LDY #$00
    LDX #$08
    SEC
FC_Sub_64_Calc
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    DEX
    BNE FC_Sub_64_Calc
    RTS

;=================================================
;64位整数减法
;最多耗时周期: 158
;编译指令长度: 59
FC_Sub_64_Fast
    LDY #$00
    SEC
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    INY
    LDA (FC_Data_Src_L),Y
    SBC (FC_Data_Dest_L),Y
    STA (FC_Data_Result_L),Y
    RTS

;=================================================
;NES 入口
    .ORG $FFFA
    .DW 0
    .DW Reset_Program
    .DW 0
    