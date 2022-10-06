@echo off
SET THEFILE=C:\Users\Pafnooc\Desktop\AutoTAG2\autotag2.exe
echo Linking %THEFILE%
C:\lazarus\fpc\3.2.0\bin\x86_64-win64\ld.exe -b pei-x86-64  --gc-sections   --subsystem windows --entry=_WinMainCRTStartup    -o C:\Users\Pafnooc\Desktop\AutoTAG2\autotag2.exe C:\Users\Pafnooc\Desktop\AutoTAG2\link.res
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occurred while assembling %THEFILE%
goto end
:linkend
echo An error occurred while linking %THEFILE%
:end
