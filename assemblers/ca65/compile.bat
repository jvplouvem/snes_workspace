@echo off

cls
set output_folder=..\..\output


del %output_folder%\rom.sym 
del %output_folder%\rom.dbg

ca65 -g %main_file%.asm
REM ld65 -C lorom.cfg -o %source_code_path%\rom.sfc %source_code_path%\main.o -Ln labels.txt --dbgfile %source_code_path%\rom.dbg


ld65 -C lorom.cfg -o %output_folder%\rom.sfc %main_file%.o -Ln %output_folder%\rom.sym --dbgfile %output_folder%\rom.dbg
REM ld65 -C hirom.cfg -o %source_code_path%\rom.sfc %source_code_path%\main.o -Ln %source_code_path%\rom.sym

REM ld65 -C lorom.cfg -o %source_code_path%\rom.sfc %source_code_path%\main.o --dbgfile %source_code_path%\rom.dbg
REM del %source_code_path%\*.o