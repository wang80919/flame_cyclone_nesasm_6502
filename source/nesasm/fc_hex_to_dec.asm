;=================================================
;进制转换
;FlameCyclone
;2024.8.7
;=================================================
;进制转换
;FC_HEX_To_Dec_8        最差耗时 134      指令长度 29
;=================================================
;进制转换
FC_Use_Addr       = $140
FC_Hex_Data_L     = FC_Use_Addr + 0
FC_Hex_Data_H     = FC_Use_Addr + 1
FC_Dec_Data_1     = FC_Use_Addr + 2
FC_Dec_Data_10    = FC_Use_Addr + 3
FC_Dec_Data_100   = FC_Use_Addr + 4
FC_Dec_Data_1000  = FC_Use_Addr + 5
FC_Dec_Data_10000 = FC_Use_Addr + 6

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
    JSR FC_HEX_To_Dec_16
    
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
;位十六进制转十进制(16位)
;  零页编译字节: FC(252)
;非零页编译字节: 11D(285)
;
;非零页耗时 
;65535 耗时 391
;59999 耗时 337
;11111 耗时 589
; 9999 耗时 384
; 1111 耗时 568
;  999 耗时 232
;   99 耗时 147
;    9 耗时 43
;
;零页耗时
;65535 耗时 357
;59999 耗时 310
;11111 耗时 542
; 9999 耗时 357
; 1111 耗时 525
;  999 耗时 217
;   99 耗时 142
;    9 耗时 43

;=================================================
FC_HEX_To_Dec
FC_HEX_To_Dec_16
FC_Hex_To_Dec_Ex
    TYA
    PHA
    BIT $FFFF
    JSR FC_Hex_To_Dec_Ex_Start
    PLA
    TAY
    RTS

FC_Hex_To_Dec_Ex_Start
    LDA FC_Hex_Data_H
    ORA FC_Hex_Data_L
    BNE .FC_HEX_To_Dec_Calc
    BCC .FC_HEX_To_Dec_Calc
    LDA #6
    STA FC_Dec_Data_10000
    LDA #5
    STA FC_Dec_Data_1000
    LDA #5
    STA FC_Dec_Data_100
    LDA #4
    STA FC_Dec_Data_10
    LDA #5
    STA FC_Dec_Data_1
    RTS

.FC_HEX_To_Dec_Calc
    LDA FC_Hex_Data_H
    BNE .FC_Hex_To_Dec_Ex_0_65535
    LDA FC_Hex_Data_L
    LDY #$00
;------------------------------
.FC_HEX_To_Dec_8_100_Calc
    CMP #100
    BCC .FC_HEX_To_Dec_8_10
    SBC #100
    INY
    BNE .FC_HEX_To_Dec_8_100_Calc
;------------------------------
.FC_HEX_To_Dec_8_10
    STY FC_Dec_Data_100
    LDY #$00
.FC_HEX_To_Dec_8_10_Calc
    CMP #10
    BCC .FC_HEX_To_Dec_8_1
    SBC #10
    INY
    BNE .FC_HEX_To_Dec_8_10_Calc
;------------------------------
.FC_HEX_To_Dec_8_1
    STY FC_Dec_Data_10
    STA FC_Dec_Data_1
    RTS
    
.FC_Hex_To_Dec_Ex_0_65535
    LDA FC_Hex_Data_H
    CMP #>1000
    BCC .FC_Hex_To_Dec_Cmp_1000_Start
    BNE .FC_Hex_To_Dec_Cmp_10000_Start
    LDA FC_Hex_Data_L
    CMP #<1000
    BCC .FC_Hex_To_Dec_Cmp_1000_Start
.FC_Hex_To_Dec_Cmp_10000_Start
    LDY #$06
.FC_Hex_To_Dec_Cmp_10000
    LDA FC_Hex_Data_H
    CMP FC_Hex_To_Unit_10000_H,Y
    BCC .FC_Hex_To_Dec_Cmp_10000_Next
    BNE .FC_Hex_To_Dec_Sub_10000
    LDA FC_Hex_Data_L
    CMP FC_Hex_To_Unit_10000_L,Y
    BCS .FC_Hex_To_Dec_Sub_10000
.FC_Hex_To_Dec_Cmp_10000_Next
    DEY
    BNE .FC_Hex_To_Dec_Cmp_10000
    BEQ .FC_Hex_To_Dec_10000_End
.FC_Hex_To_Dec_Sub_10000
    LDA FC_Hex_Data_L
    SBC FC_Hex_To_Unit_10000_L,Y
    STA FC_Hex_Data_L
    LDA FC_Hex_Data_H
    SBC FC_Hex_To_Unit_10000_H,Y
    STA FC_Hex_Data_H
.FC_Hex_To_Dec_10000_End
    STY FC_Dec_Data_10000
;-------------------------------------------------
.FC_Hex_To_Dec_Cmp_1000_Start
    LDA FC_Hex_Data_H
    CMP #>1000
    BCC .FC_Hex_To_Dec_Cmp_100_Start
    BNE .FC_Hex_To_Dec_Cmp_1000_Calc
    LDA FC_Hex_Data_L
    CMP #<1000
    BCC .FC_Hex_To_Dec_Cmp_100_Start
.FC_Hex_To_Dec_Cmp_1000_Calc
    LDY #$09
.FC_Hex_To_Dec_Cmp_1000
    LDA FC_Hex_Data_H
    CMP FC_Hex_To_Unit_1000_H,Y
    BCC .FC_Hex_To_Dec_Cmp_1000_Next
    BNE .FC_Hex_To_Dec_Sub_1000
    LDA FC_Hex_Data_L
    CMP FC_Hex_To_Unit_1000_L,Y
    BCS .FC_Hex_To_Dec_Sub_1000
.FC_Hex_To_Dec_Cmp_1000_Next
    DEY
    BNE .FC_Hex_To_Dec_Cmp_1000
    BEQ .FC_Hex_To_Dec_1000_End
.FC_Hex_To_Dec_Sub_1000
    LDA FC_Hex_Data_L
    SBC FC_Hex_To_Unit_1000_L,Y
    STA FC_Hex_Data_L
    LDA FC_Hex_Data_H
    SBC FC_Hex_To_Unit_1000_H,Y
    STA FC_Hex_Data_H
.FC_Hex_To_Dec_1000_End
    STY FC_Dec_Data_1000
;-------------------------------------------------
.FC_Hex_To_Dec_Cmp_100_Start
    LDY #$09
.FC_Hex_To_Dec_Cmp_100
    LDA FC_Hex_Data_H
    CMP FC_Hex_To_Unit_100_H,Y
    BCC .FC_Hex_To_Dec_Cmp_100_Next
    BNE .FC_Hex_To_Dec_Sub_100
    LDA FC_Hex_Data_L
    CMP FC_Hex_To_Unit_100_L,Y
    BCS .FC_Hex_To_Dec_Sub_100
.FC_Hex_To_Dec_Cmp_100_Next
    DEY
    BNE .FC_Hex_To_Dec_Cmp_100
    BEQ .FC_Hex_To_Dec_100_End
.FC_Hex_To_Dec_Sub_100
    LDA FC_Hex_Data_L
    SBC FC_Hex_To_Unit_100_L,Y
    STA FC_Hex_Data_L
    LDA FC_Hex_Data_H
    SBC FC_Hex_To_Unit_100_H,Y
    STA FC_Hex_Data_H
.FC_Hex_To_Dec_100_End
    STY FC_Dec_Data_100
;-------------------------------------------------
.FC_Hex_To_Dec_10
    LDY #$00
    LDA FC_Hex_Data_L
.FC_Hex_To_Dec_10_Cmp
    CMP #10
    BCC .FC_Hex_To_Dec_10_End
    SBC #10
    INY
    BNE .FC_Hex_To_Dec_10_Cmp
.FC_Hex_To_Dec_10_End
    STY FC_Dec_Data_10
    STA FC_Dec_Data_1
    RTS
    
;-------------------------------------------------
FC_Hex_To_Unit_10000_L
    .DB 0
    .DB LOW(10000)
    .DB LOW(20000)
    .DB LOW(30000)
    .DB LOW(40000)
    .DB LOW(50000)
    .DB LOW(60000)
FC_Hex_To_Unit_1000_L
    .DB 0
    .DB LOW(1000)
    .DB LOW(2000)
    .DB LOW(3000)
    .DB LOW(4000)
    .DB LOW(5000)
    .DB LOW(6000)
    .DB LOW(7000)
    .DB LOW(8000)
    .DB LOW(9000)
FC_Hex_To_Unit_100_L
    .DB 0
    .DB LOW(100)
    .DB LOW(200)
    .DB LOW(300)
    .DB LOW(400)
    .DB LOW(500)
    .DB LOW(600)
    .DB LOW(700)
    .DB LOW(800)
    .DB LOW(900)
;-------------------------------------------------
FC_Hex_To_Unit_10000_H
    .DB 0
    .DB HIGH(10000)
    .DB HIGH(20000)
    .DB HIGH(30000)
    .DB HIGH(40000)
    .DB HIGH(50000)
    .DB HIGH(60000)
FC_Hex_To_Unit_1000_H
    .DB 0
    .DB HIGH(1000)
    .DB HIGH(2000)
    .DB HIGH(3000)
    .DB HIGH(4000)
    .DB HIGH(5000)
    .DB HIGH(6000)
    .DB HIGH(7000)
    .DB HIGH(8000)
    .DB HIGH(9000)
FC_Hex_To_Unit_100_H
    .DB 0
    .DB HIGH(100)
    .DB HIGH(200)
    .DB HIGH(300)
    .DB HIGH(400)
    .DB HIGH(500)
    .DB HIGH(600)
    .DB HIGH(700)
    .DB HIGH(800)
    .DB HIGH(900)
    
;=================================================
;NES 入口
    .ORG $FFFA
    .DW 0
    .DW Reset_Program
    .DW 0
    