;=================================================
;比较运算
;FlameCyclone
;2024.8.7
;=================================================
;比较
;FC_Cmp_16              最差耗时 49       指令长度: 14
;FC_Cmp_16_Fast         最差耗时 40       指令长度: 16
;FC_Cmp_32              最差耗时 83       指令长度: 14
;FC_Cmp_32_Fast         最差耗时 68       指令长度: 30
;FC_Cmp_64              最差耗时 151      指令长度: 14
;FC_Cmp_64_Fast         最差耗时 124      指令长度: 58
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
    JSR Test_Cmp_16
    JSR Test_Cmp_16_Fast
    JSR Test_Cmp_32
    JSR Test_Cmp_32_Fast
    JSR Test_Cmp_64
    JSR Test_Cmp_64_Fast
    RTS

Test_Cmp_16
    LDA #<.Test_Src
    STA FC_Data_Src_L
    LDA #>.Test_Src
    STA FC_Data_Src_H
    LDA #<.Test_Dest
    STA FC_Data_Dest_L
    LDA #>.Test_Dest
    STA FC_Data_Dest_H
    
    BIT $FFFF
    JSR FC_Cmp_16
    RTS
.Test_Src
    .DW $FFFF
.Test_Dest
    .DW $FFFF

Test_Cmp_16_Fast
    LDA #<.Test_Src
    STA FC_Data_Src_L
    LDA #>.Test_Src
    STA FC_Data_Src_H
    LDA #<.Test_Dest
    STA FC_Data_Dest_L
    LDA #>.Test_Dest
    STA FC_Data_Dest_H
    
    BIT $FFFF
    JSR FC_Cmp_16_Fast
    RTS
.Test_Src
    .DW $FFFF
.Test_Dest
    .DW $FFFF

Test_Cmp_32
    LDA #<.Test_Src
    STA FC_Data_Src_L
    LDA #>.Test_Src
    STA FC_Data_Src_H
    LDA #<.Test_Dest
    STA FC_Data_Dest_L
    LDA #>.Test_Dest
    STA FC_Data_Dest_H
    
    BIT $FFFF
    JSR FC_Cmp_32
    RTS
.Test_Src
    .DW $FFFF
    .DW $FFFF
.Test_Dest
    .DW $FFFF
    .DW $FFFF

Test_Cmp_32_Fast
    LDA #<.Test_Src
    STA FC_Data_Src_L
    LDA #>.Test_Src
    STA FC_Data_Src_H
    LDA #<.Test_Dest
    STA FC_Data_Dest_L
    LDA #>.Test_Dest
    STA FC_Data_Dest_H
    
    BIT $FFFF
    JSR FC_Cmp_32_Fast
    RTS
.Test_Src
    .DW $FFFF
    .DW $FFFF
.Test_Dest
    .DW $FFFF
    .DW $FFFF

Test_Cmp_64
    LDA #<.Test_Src
    STA FC_Data_Src_L
    LDA #>.Test_Src
    STA FC_Data_Src_H
    LDA #<.Test_Dest
    STA FC_Data_Dest_L
    LDA #>.Test_Dest
    STA FC_Data_Dest_H
    
    BIT $FFFF
    JSR FC_Cmp_64
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

Test_Cmp_64_Fast
    LDA #<.Test_Src
    STA FC_Data_Src_L
    LDA #>.Test_Src
    STA FC_Data_Src_H
    LDA #<.Test_Dest
    STA FC_Data_Dest_L
    LDA #>.Test_Dest
    STA FC_Data_Dest_H
    
    BIT $FFFF
    JSR FC_Cmp_64_Fast
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
;16位整数比较, 结果: 若 C = 1, Src > Dest 若 C = 0, Src < Dest 若 Z = 1, Src = Dest
;最多耗时周期: 49
;编译指令长度: 14
FC_Cmp_16
    LDY #$01
FC_Cmp_16_Data
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_16_End
    DEY
    BPL FC_Cmp_16_Data
    LDA #$00
FC_Cmp_16_End
    RTS

;=================================================
;16位整数比较, 结果: 若 C = 1, Src > Dest 若 C = 0, Src < Dest 若 Z = 1, Src = Dest
;最多耗时周期: 40
;编译指令长度: 16
FC_Cmp_16_Fast
    LDY #$01
FC_Cmp_16_Fast_Data
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_16_Fast_End
    DEY
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_16_Fast_End
FC_Cmp_16_Fast_End
    RTS

;=================================================
;32位整数比较, 结果: 若 C = 1, Src > Dest 若 C = 0, Src < Dest 若 Z = 1, Src = Dest
;最多耗时周期: 83
;编译指令长度: 14
FC_Cmp_32
    LDY #$03
FC_Cmp_32_Data
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_32_End
    DEY
    BPL FC_Cmp_32_Data
    LDA #$00
FC_Cmp_32_End
    RTS

;=================================================
;32位整数比较, 结果: 若 C = 1, Src > Dest 若 C = 0, Src < Dest 若 Z = 1, Src = Dest
;最多耗时周期: 68
;编译指令长度: 30
FC_Cmp_32_Fast
    LDY #$03
FC_Cmp_32_Fast_Data
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_32_Fast_End
    DEY
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_32_Fast_End
    DEY
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_32_Fast_End
    DEY
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_32_Fast_End
FC_Cmp_32_Fast_End
    RTS

;=================================================
;64位整数比较, 结果: 若 C = 1, Src > Dest 若 C = 0, Src < Dest 若 Z = 1, Src = Dest
;最多耗时周期: 151
;编译指令长度: 14
FC_Cmp_64
    LDY #$07
FC_Cmp_64_Data
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_64_End
    DEY
    BPL FC_Cmp_64_Data
    LDA #$00
FC_Cmp_64_End
    RTS

;=================================================
;64位整数比较, 结果: 若 C = 1, Src > Dest 若 C = 0, Src < Dest 若 Z = 1, Src = Dest
;最多耗时周期: 124
;编译指令长度: 58
FC_Cmp_64_Fast
    LDY #$07
FC_Cmp_64_Fast_Data
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_64_Fast_End
    DEY
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_64_Fast_End
    DEY
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_64_Fast_End
    DEY
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_64_Fast_End
    DEY
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_64_Fast_End
    DEY
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_64_Fast_End
    DEY
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_64_Fast_End
    DEY
    LDA (FC_Data_Src_L),Y
    CMP (FC_Data_Dest_L),Y
    BNE FC_Cmp_64_Fast_End
FC_Cmp_64_Fast_End
    RTS

;=================================================
;NES 入口
    .ORG $FFFA
    .DW 0
    .DW Reset_Program
    .DW 0
    