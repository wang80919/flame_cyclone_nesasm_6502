@echo off

set IN_FILE_NAME=fc_basic_framework.asm
set OUT_FILE_NAME=fc_basic_framework.nes
set NESASM3=nesasm_Gui_3_2_x86.exe

cd /d %~dp0

call "%NESASM3%" %IN_FILE_NAME% -out "%OUT_FILE_NAME%"
set result=%errorlevel%

IF 0 NEQ %result% (
    pause
) else (
    rem TODO
)

goto:eof