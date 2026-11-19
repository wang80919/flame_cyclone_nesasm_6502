;=================================================
;进制转换
;FlameCyclone
;2024.8.7
;=================================================
;进制转换
;FC_HEX_To_Dec_8        最差耗时 134      指令长度 29
;=================================================
;进制转换
FC_HEX_Data_L               = $200
FC_HEX_Data_H               = $201
FC_Dec_16                   = $202
FC_Dec_1                    = FC_Dec_16 + 0
FC_Dec_10                   = FC_Dec_16 + 1
FC_Dec_100                  = FC_Dec_16 + 2
;=================================================
    .INESPRG 1      ;16KB PRG 数量, $01-$EF8(1-3832),即16-61,312 KB
    .INESCHR 0       ;8KB CHR 数量,$01-$EF8(1-3832),即0-30,656 KB
    .INESMAP 4          ;Mapper号 (0-4095)
    .BANK 1
    .ORG $E000
    
Test_Hex = 59999
;=================================================
Reset_Program
    SEI
    CLD
    
    LDA #<Test_Hex
    STA FC_HEX_Data_L
    LDA #>Test_Hex
    STA FC_HEX_Data_H
    JSR FC_HEX_To_Dec_Ex
    
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
    JSR Test_Hex_to_Dec_8
    RTS

Test_Hex_to_Dec_8
    LDA #99
    
    BIT $FFFF
    JSR FC_HEX_To_Dec_8
    RTS

;=================================================
    .MACRO HEX_TO_DEC_16_CMP
        LDA \2
        CMP #>\3
        BCC Label_\@_End
        BNE Label_\@_Calc
        LDA \1
        CMP #<\3
        BCC Label_\@_End
Label_\@_Calc
        LDA \1
        SBC #<\3
        STA \1
        LDA \2
        SBC #>\3
        STA \2
        LDA #\3 / \4
        STA \5
Label_\@_End
    .ENDM

;=================================================
    .MACRO HEX_TO_DEC_UNIT_CMP
        LDA \2
        CMP #>\3
        BCC Label_\@_Over
        BNE Label_\@_Start
        LDA \1
        CMP #<\3
        BCC Label_\@_Over
Label_\@_Start
        JMP \4
Label_\@_Over
        JMP \5
    .ENDM

;=================================================
;位十六进制转十进制(16位)
;编译指令长度: 零页: 372(882) / 非零页: 429(1065)
;65535耗时 零页: 344 / 非零页: 392 359
;59999耗时 零页: 344 / 非零页: 392 357
;11111耗时 零页: 344 / 非零页: 392 420
; 1111耗时 零页: 319 / 非零页: 361 332
;  999耗时 零页: 341 / 非零页: 377 264
;   99耗时 零页: 176 / 非零页: 189
;    9耗时 零页:  77 / 非零页: 90
FC_HEX_To_Dec_Ex
    LDA FC_HEX_Data_L
    ORA FC_HEX_Data_H
    BNE FC_HEX_To_Dec_Ex_Range_0_65535
    BCC FC_HEX_To_Dec_Ex_Range_0_65535
FC_HEX_To_Dec_Ex_65536
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
FC_HEX_To_Dec_Ex_Range_0_65535
    LDA #$00
    STA FC_Dec_16 + 4
    STA FC_Dec_16 + 3
    STA FC_Dec_16 + 2
    STA FC_Dec_16 + 1
    STA FC_Dec_16 + 0
    
    LDA FC_HEX_Data_H
    BNE FC_HEX_To_Dec_Ex_Range_10000_60000
    JMP FC_HEX_To_Dec_Ex_Range_100_199
    
;转换10000-60000
FC_HEX_To_Dec_Ex_Range_10000_60000
    HEX_TO_DEC_UNIT_CMP FC_HEX_Data_L, FC_HEX_Data_H, 10000, FC_HEX_To_Dec_Ex_Unit_10000, FC_HEX_To_Dec_Ex_Range_1000_9000
FC_HEX_To_Dec_Ex_Unit_10000
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 60000, 10000, FC_Dec_16 + 4, FC_HEX_To_Dec_Ex_Range_1000_9000
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 50000, 10000, FC_Dec_16 + 4, FC_HEX_To_Dec_Ex_Range_1000_9000
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 40000, 10000, FC_Dec_16 + 4, FC_HEX_To_Dec_Ex_Range_1000_9000
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 30000, 10000, FC_Dec_16 + 4, FC_HEX_To_Dec_Ex_Range_1000_9000
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 20000, 10000, FC_Dec_16 + 4, FC_HEX_To_Dec_Ex_Range_1000_9000
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 10000, 10000, FC_Dec_16 + 4, FC_HEX_To_Dec_Ex_Range_1000_9000

;转换1000-9000
FC_HEX_To_Dec_Ex_Range_1000_9000
    HEX_TO_DEC_UNIT_CMP FC_HEX_Data_L, FC_HEX_Data_H, 1000, FC_HEX_To_Dec_Ex_Unit_1000, FC_HEX_To_Dec_Ex_Range_200_900
FC_HEX_To_Dec_Ex_Unit_1000
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 9000, 1000, FC_Dec_16 + 3, FC_HEX_To_Dec_Ex_Range_200_900
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 8000, 1000, FC_Dec_16 + 3, FC_HEX_To_Dec_Ex_Range_200_900
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 7000, 1000, FC_Dec_16 + 3, FC_HEX_To_Dec_Ex_Range_200_900
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 6000, 1000, FC_Dec_16 + 3, FC_HEX_To_Dec_Ex_Range_200_900
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 5000, 1000, FC_Dec_16 + 3, FC_HEX_To_Dec_Ex_Range_200_900
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 4000, 1000, FC_Dec_16 + 3, FC_HEX_To_Dec_Ex_Range_200_900
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 3000, 1000, FC_Dec_16 + 3, FC_HEX_To_Dec_Ex_Range_200_900
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 2000, 1000, FC_Dec_16 + 3, FC_HEX_To_Dec_Ex_Range_200_900
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 1000, 1000, FC_Dec_16 + 3, FC_HEX_To_Dec_Ex_Range_200_900

;转换200-900
FC_HEX_To_Dec_Ex_Range_200_900
FC_HEX_To_Dec_Ex_Unit_100
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 900, 100, FC_Dec_16 + 2, FC_HEX_To_Dec_Ex_Range_100_199
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 800, 100, FC_Dec_16 + 2, FC_HEX_To_Dec_Ex_Range_100_199
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 700, 100, FC_Dec_16 + 2, FC_HEX_To_Dec_Ex_Range_100_199
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 600, 100, FC_Dec_16 + 2, FC_HEX_To_Dec_Ex_Range_100_199
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 500, 100, FC_Dec_16 + 2, FC_HEX_To_Dec_Ex_Range_100_199
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 400, 100, FC_Dec_16 + 2, FC_HEX_To_Dec_Ex_Range_100_199
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 300, 100, FC_Dec_16 + 2, FC_HEX_To_Dec_Ex_Range_100_199
    HEX_TO_DEC_16_CMP FC_HEX_Data_L, FC_HEX_Data_H, 200, 100, FC_Dec_16 + 2, FC_HEX_To_Dec_Ex_Range_100_199

;转换0-100
FC_HEX_To_Dec_Ex_Range_100_199
    LDY #$00
    LDA FC_HEX_Data_L
    LDY FC_Dec_100
    BNE FC_HEX_To_Dec_Ex_Range_10_99
FC_HEX_To_Dec_Ex_Range_100_199_Calc
    CMP #100
    BCC FC_HEX_To_Dec_Ex_Range_10_99
    SBC #100
    INY
    BNE FC_HEX_To_Dec_Ex_Range_100_199_Calc
    
;转换0-10
FC_HEX_To_Dec_Ex_Range_10_99
    STY FC_Dec_100
    LDY #$00
FC_HEX_To_Dec_Ex_Range_10_99_Calc
    CMP #10
    BCC FC_HEX_To_Dec_Ex_Range_0_9
    SBC #10
    INY
    BNE FC_HEX_To_Dec_Ex_Range_10_99_Calc
FC_HEX_To_Dec_Ex_Range_0_9
    STY FC_Dec_10
    STA FC_Dec_1
    RTS

;=================================================
;NES 入口
    .ORG $FFFA
    .DW 0
    .DW Reset_Program
    .DW 0
    