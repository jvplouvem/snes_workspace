@echo off

REM aqruivo main sem extensao
REM set main_file_path=nesdoug-part6-controllers-and-nmi\main
REM set main_file_path=vram-update-test\main
REM set main_file_path=magician-lord\main
set main_file_path=testes_kof\main

REM =============================================================================
set main_file=%cd%\projects\%main_file_path%
cd assemblers\ca65

call compile.bat
pause
call run.bat

cd C:\ambiente_desenvolvimento\test\asssembly_workspace
REM pause