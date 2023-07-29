@echo off

SET source_folder=C:\ambiente_desenvolvimento\test\asssembly_workspace\tools
SET file_name=0_1
SET source_image=%source_folder%\%file_name%.png

gfx2snes -gs8 -pc16 -po16 -fpng %source_image%
pause