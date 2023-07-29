@echo off
REM superfamiconv -v --in-image ferrari_2.png -B 4 --out-palette snes.palette --out-tiles snes.tiles --out-map snes.map --out-tiles-image tiles.png
	REM superfamiconv -v --in-image ferrari_8bpp.png -B 8 --out-palette snes.palette --out-tiles snes.tiles --out-map snes.map --out-tiles-image tiles.png
REM superfamiconv -v -W 256 -H 224 --in-image snes.png --out-palette snes.palette --out-tiles snes.tiles --out-map snes.map --out-tiles-image tiles.png
REM superfamiconv


SET source_folder=C:\ambiente_desenvolvimento\test\asssembly_workspace\tools
SET file_name=0_1
SET source_image=%source_folder%\%file_name%.png

REM For Backgrounds
REM superfamiconv --verbose --no-discard --no-flip --in-image %source_image% --out-palette %source_folder%\image.palette --out-tiles %source_folder%\image.tiles --out-map %source_folder%\image.map

REM --sprite-mode

REM For Sprites
REM superfamiconv.exe --verbose --no-discard -R --color-zero #FF00FF --in-image %source_image% --out-palette %source_folder%\image.palette --out-tiles %source_folder%\image.tiles --out-tiles-image %source_folder%\tiles.png
REM superfamiconv.exe --verbose --no-discard --no-flip --bpp 4 --tile-width 8 --tile-height 8 --mode snes --in-image %source_image% --out-palette %source_folder%\%file_name%.palette --out-tiles %source_folder%\%file_name%.tiles
superfamiconv.exe --verbose --sprite-mode --no-remap --in-image %source_image% --out-palette %source_folder%\%file_name%.palette --out-tiles %source_folder%\%file_name%.tiles


REM superfamiconv palette --verbose -R --in-image %source_image%  --out-data %source_folder%\image.palette
REM superfamiconv tiles --verbose --sprite-mode -R --in-image %source_image% --in-palette %source_folder%\image.palette  --out-image %source_folder%\image.tiles

pause