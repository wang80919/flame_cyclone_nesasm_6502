;=================================================
;静态文本数据
;=================================================
;静态文本数据, 格式: 是否居中 显示地址, 文本长度, 文本内容
Text_Data_01 MACRO_TEXT_DATA 1,$2040, "FlameCyclone"
Text_Data_02 MACRO_TEXT_DATA 1,$2080, "2024.8.14"
Text_Data_03 MACRO_TEXT_DATA 1,$20C0, "FC Basic page list"
Text_Data_04 MACRO_TEXT_DATA 1,$2100, "Thank for 6502"
Text_Data_05 MACRO_TEXT_DATA 1,$2140, "And you"
;-------------------------------------------------
;静态文本数据地址索引, 最多放128条文本索引
Text_Data_Index
    .DW Text_Data_01
    .DW Text_Data_02
    .DW Text_Data_03
    ;.DW Text_Data_04
    ;.DW Text_Data_05
Text_Data_Index_End
