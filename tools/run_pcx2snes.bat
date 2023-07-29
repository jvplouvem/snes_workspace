@echo off

REM pcx2snes -s32 -c16 -o16 -n biker
REM            |    |    |   |   |
REM            |    |    |   |   |
REM            |    |    |   |    \--> Name of pcx file (without extension)
REM            |    |    |   |
REM            |    |    |    \------> No border surrounding tile(s)
REM            |    |    |   
REM            |    |     \----------> Number of colors in palette to output
REM            |    |
REM            |     \---------------> Color Depth of tiles(s)
REM            |
REM             \--------------------> Size of tile(s)

pcx2snes -s16 -c16 -o16 -n 0_1

REM gfx2snes 

pause