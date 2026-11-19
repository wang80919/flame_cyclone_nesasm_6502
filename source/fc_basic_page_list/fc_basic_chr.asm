;=================================================
;CHR 数据
;=================================================
    .BANK NES_16KB_PRG_SIZE * 2, "CHR Data"
    .ORG $0000
    
    .INCBIN "fc_basic_bg.chr"
    .INCBIN "fc_basic_sp.chr"
    
    ;CHR末尾填充
    .BANK NES_16KB_PRG_SIZE * 2 + NES_8KB_CHR_SIZE - 1
    .ORG $1FFF
    .HEX 00
