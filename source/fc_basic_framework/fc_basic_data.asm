;=================================================
;静态文本数据
;=================================================
;静态文本数据, 格式: 是否居中 显示地址, 文本长度, 文本内容
Text_Data_01 MACRO_TEXT_DATA 1,$2040, "FlameCyclone"
Text_Data_02 MACRO_TEXT_DATA 1,$2080, "2024.8.8"
Text_Data_03 MACRO_TEXT_DATA 1,$20C0, "FC Basic Framework"
Text_Data_04 MACRO_TEXT_DATA 1,$2100, "Thank for 6502"
Text_Data_05 MACRO_TEXT_DATA 1,$2140, "And you"
;-------------------------------------------------
;静态文本数据地址索引, 最多放128条文本索引
Text_Data_Index
    .DW Text_Data_01
    .DW Text_Data_02
    .DW Text_Data_03
    .DW Text_Data_04
    .DW Text_Data_05
Text_Data_Index_End

;=================================================
;手柄测试文本
;=================================================
;静态文本数据, 格式: 是否居中 显示地址, 文本长度, 文本内容
Joy_Text_Data_01 MACRO_TEXT_DATA 0,$2222, "Left"
Joy_Text_Data_02 MACRO_TEXT_DATA 0,$21A2, "Up"
Joy_Text_Data_03 MACRO_TEXT_DATA 0,$21E2, "Down"
Joy_Text_Data_04 MACRO_TEXT_DATA 0,$2262, "Right"
Joy_Text_Data_05 MACRO_TEXT_DATA 0,$22A2, "Select"
Joy_Text_Data_06 MACRO_TEXT_DATA 0,$22E2, "Start"
Joy_Text_Data_07 MACRO_TEXT_DATA 0,$2322, "B"
Joy_Text_Data_08 MACRO_TEXT_DATA 0,$2362, "A"
;-------------------------------------------------
;静态文本数据地址索引, 最多放128条文本索引
Joy_Text_Data_Index
    .DW Joy_Text_Data_01
    .DW Joy_Text_Data_02
    .DW Joy_Text_Data_03
    .DW Joy_Text_Data_04
    .DW Joy_Text_Data_05
    .DW Joy_Text_Data_06
    .DW Joy_Text_Data_07
    .DW Joy_Text_Data_08
Joy_Text_Data_Index_End
