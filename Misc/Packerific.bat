@echo off
title Packerific: ROM (Un)Packer
setlocal EnableDelayedExpansion

rem -- 3DS ROM (Un)Packer batch script --
rem --            Very WIP             --

rem TODO: add some manual control
rem TODO: add error handling

rem set temporary path to include batch directory
set "PATH=%~dp0;%PATH%"

rem if no file arg, ask for file/directory.  Otherwise use arg
IF [%1] EQU [] (
  set /p input=Enter path to input file/directory: 
  call :stripQuote !input! input
) ELSE ( 
  set input=%~f1
)

rem check for existence of input
IF Not Exist "%input%" (
  echo Operation failed.  Cannot find file/directory "%input%"
  pause
  goto exit
)


rem get input name, extension and path
call :getExt "%input%" inExt
call :getName "%input%" inName
call :getPath "%input%" inPath

rem convert input to absolute path
set input=%inPath%%inName%%inExt%

rem determine action by file type (cia=ctrtool extract, cci=3dstool extract, cxi/cfa=extract container, folder=build cxi from contents)
IF [%inExt%] EQU [] goto packDir
IF [%inExt%] EQU [.cia] goto extCIA
IF [%inExt%] EQU [.cci] goto extCCI
IF [%inExt%] EQU [.3ds] goto extCCI
IF [%inExt%] EQU [.cxi] goto extCXI

echo Operation failed.  Unable to determine input type.
pause
goto exit


:extCIA
echo Extracting %inName%%inExt%
call :makeDir
ctrtool --contents=contents "%input%" > nul 2>&1
call :unpack contents.0000.00000000
del contents.*
pause
goto exit


:extCCI
echo Extracting %inName%%inExt%
call :makeDir
3dstool -xtf 3ds "%input%" --header "HeaderNCCH.bin" -0 Partition0.cxi
call :unpack Partition0.cxi
del Partition0.cxi
pause
goto exit


:extCXI
echo Extracting %inName%%inExt%
call :makeDir
call :unpack "%input%"

pause
goto exit


:packDir
echo Packing "%inName%"
cd /d "%input%"
if not exist "RomFS.bin" 3dstool -ctf romfs "RomFS.bin" --romfs-dir "RomFS"
3dstool -ctf cxi "%inPath%%inName%.cxi" --header HeaderNCCH0.bin --exh ExHeader.bin --exefs ExeFS.bin --romfs RomFS.bin --logo Logo.bin --plain Plain.bin --not-encrypt
del RomFS.bin
pause
goto exit


:unpack
3dstool -xtf cxi "%~1" --header HeaderNCCH0.bin
ctrtool --exheader=ExHeader.bin --exefs=ExeFS.bin --romfsdir=RomFS --logo=Logo.bin --plainrgn=Plain.bin "%~1"  > nul 2>&1
rem 3dstool -xtf cxi "%~1" --header HeaderNCCH0.bin --exh ExHeader.bin --exefs ExeFS.bin --romfs RomFS.bin --logo Logo.bin --plain PlainRGN.bin
EXIT /B


:stripQuote
set "%2=%~1"
EXIT /B

:getExt
set "%2=%~x1"
EXIT /B

:getName
set "%2=%~n1"
EXIT /B

:getPath
set "%2=%~dp1"
EXIT /B

:makeDir
if Not Exist "%inPath%%inName%" mkdir "%inPath%%inName%"
cd /d "%inPath%%inName%"
EXIT /B

:exit