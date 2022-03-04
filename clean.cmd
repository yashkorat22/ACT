@echo off
 title Clean script for Android app - Powered by n-iceware.com
 color 0A
:: ========================================================================
:: = Clean script for Android app - Powered by n-iceware.com
:: = 
:: = For further information about cleanup: https://github.com/flutter/flutter/blob/master/.gitignore
:: =
:: = Script created (dd.mm.yyyy): 22.06.2021/NYB
:: = Script changed (dd.mm.yyyy): 02.07.2021/NYB: Exclude test folders from cleanup
:: = Script changed (dd.mm.yyyy): 06.09.2021/NYB: Include lib\generated to cleanup
:: =
:: ========================================================================

 set _appVersion=1.10.8
 set _appBuild=5
  
 set _ProjectPath=%~dp0
 set _OutputPath=%_ProjectPath%_app
 set _FlutterPath=%SYSTEMDRIVE%\src\flutter\bin

 :: Extract date values - language independent
 for /f %%i in ('"powershell (Get-Date).ToString(\"dd\")"') do set day=%%i
 for /f %%i in ('"powershell (Get-Date).ToString(\"MM\")"') do set month=%%i
 for /f %%i in ('"powershell (Get-Date).ToString(\"yyyy\")"') do set year=%%i

 :: Extract time value - for log files  
 set _wTime=%TIME:~0,2%:%TIME:~3,2%:%TIME:~6,2%
 
 :: Set time and date - for log files  
 set _workTime=%day%.%month%.%year% %_wTime%
 
 cls
 echo.
 echo ===================================================================
 echo = Cleaning your Android app
 echo = Start: %_workTime%
 
 echo.
 echo = Check prerequisites
 If not exist "%_FlutterPath%\flutter.bat" goto ERROR1

 echo.
 echo = Change directory
 CD %_ProjectPath%

 echo.
 echo = Create output path
 MD "%_OutputPath%" 2>nul
 
 echo.
 echo = Clean build data
 start /B /WAIT "" cmd.exe /c "%_FlutterPath%\flutter.bat clean"
 echo ERRORLEVEL: %ERRORLEVEL%
 
 rd "%_ProjectPath%\.idea" /S /Q 2>nul
 rd "%_ProjectPath%\build" /S /Q 2>nul
:: rd "%_ProjectPath%\integration_test" /S /Q 2>nul
:: rd "%_ProjectPath%\test" /S /Q 2>nul
 rd "%_ProjectPath%\lib\generated" /S /Q 2>nul
 del "%_ProjectPath%\.packages" /F 2>nul
 rd "%_ProjectPath%\android\.gradle" /S /Q 2>nul
 del "%_ProjectPath%\android\local.properties" /F 2>nul
 del "%_ProjectPath%\android\gradlew" /F 2>nul
 del "%_ProjectPath%\android\gradlew.bat" /F 2>nul
 del "%_ProjectPath%\android\gradle\wrapper\gradle-wrapper.jar" /F 2>nul
 del "%_ProjectPath%\android\app\src\main\java\io\flutter\plugins\GeneratedPluginRegistrant.java" /F 2>nul
 del "%_ProjectPath%\ios\Runner\GeneratedPluginRegistrant.*" /F 2>nul
 
 del "%_ProjectPath%\version.txt" /F 2>nul
 del "%_ProjectPath%\environment.txt" /F 2>nul
  
 del "%_ProjectPath%\pubspec.lock" /F 2>nul 
 
 :: Extract date values - language independent
 for /f %%i in ('"powershell (Get-Date).ToString(\"dd\")"') do set day=%%i
 for /f %%i in ('"powershell (Get-Date).ToString(\"MM\")"') do set month=%%i
 for /f %%i in ('"powershell (Get-Date).ToString(\"yyyy\")"') do set year=%%i

 :: Extract time value - for log files  
 set _wTime=%TIME:~0,2%:%TIME:~3,2%:%TIME:~6,2%
 
 :: Set time and date - for log files  
 set _workTime=%day%.%month%.%year% %_wTime%
 
 echo.
 echo = End: %_workTime%
 echo = Cleaned your Android app
 echo ===================================================================
 
 echo = Press any key...
 pause >nul
 goto END
 
:ERROR1
 cls
 echo.
 echo ===================================================================
 echo = Missing the flutter binaries!
 echo.
 echo   "%_FlutterPath%\flutter.bat" not found
 echo.
 echo = Press any key...
 pause >nul
 goto END

:END