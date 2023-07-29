@echo off

set asar_path=C:\ambiente_desenvolvimento\test\snes-lab\snes-lab\tools\assemblers\asar
REM set emulator_path=C:\ambiente_desenvolvimento\test\snes-lab\snes-lab\emuladores\bsnes-plus
set emulator_path=C:\ambiente_desenvolvimento\test\snes-lab\snes-lab\emuladores\Mesen-S
REM set emulator_path=C:\ambiente_desenvolvimento\test\snes-lab\snes-lab\emuladores\no_cash_sns


set source_code_path=C:\ambiente_desenvolvimento\test\snes-lab\snes-lab\tools\SnesAPI\asm\output

cd %source_code_path%
del rom.sfc

%asar_path%\asar.exe main.asm rom.sfc
pause
cls

REM start %emulator_path%\bsnes.exe rom.sfc
start %emulator_path%\Mesen-S.exe rom.sfc
REM start %emulator_path%\NO_CASH_SNS.EXE rom.sfc
exit