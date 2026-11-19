;======================================================================
;音乐配置
    .BANK 0 & PRG_8K_BANK_MASK, "nsf 8000"
Music_Data_8000
    MACRO_INCBIN_NSF_DATA "Super Contra (J).nsf",$0080,$2000

    .BANK 1 & PRG_8K_BANK_MASK, "nsf A000"
Music_Data_A000
    MACRO_INCBIN_NSF_DATA "Super Contra (J).nsf",$2080,$4000

    .BANK FC_PRG_C000 & PRG_8K_BANK_MASK, "nsf C000"
Music_Data_C000
    .ORG $C000
    MACRO_INCBIN_NSF_DATA "Super Contra (J).nsf",$6080,$2000
    .BANK FC_PRG_C000 & PRG_8K_BANK_MASK, "nsf C000"
    .ORG $DF85
    LSR
    JMP Switch_Music_Bank_A000_A_Pre
