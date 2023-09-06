@echo off

cls
set emulator_path=..\..\emulators
set source_code_path=..\..\output

%emulator_path%\mesen\Mesen.exe %source_code_path%\rom.sfc
REM %emulator_path%\no_cash_sns\NO_CASH_SNS.EXE %source_code_path%\rom.sfc