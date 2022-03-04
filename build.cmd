@echo off
 
 title Build script for Android app - Powered by n-iceware.com
 color 0A
 
:: ========================================================================
:: = Build script for Android app - Powered by n-iceware.com
:: = 
:: = For further information about cleanup: https://github.com/flutter/flutter/blob/master/.gitignore
:: =
:: = Script created (dd.mm.yyyy): 22.06.2021/NYB
:: = Script changed (dd.mm.yyyy): 13.07.2021/NYB: Regional and language independent date values and fixed path for build-tools
:: = Script changed (dd.mm.yyyy): 02.08.2021/NYB: Add version string logic
:: = Script changed (dd.mm.yyyy): 06.09.2021/NYB: Add localization logic
:: = Script changed (dd.mm.yyyy): 
:: =
:: ========================================================================

 :: Extract version values
 Powershell -Nop -C "(Get-Content .\assets\cfg\environment.json|ConvertFrom-Json).app_env" >environment.txt
 set /p _appEnvironment=<environment.txt

 Powershell -Nop -C "(Get-Content .\assets\cfg\configurations.%_appEnvironment%.json|ConvertFrom-Json).app_ver" >version.txt
 
 set /p _appVersion=<version.txt
 set _appBuild=%_appVersion:~-2%

:: set _appVersion=1.10.18
:: set _appBuild=18
 
 :: = Set project environment
 set _ProjectPath=%~dp0
 set _OutputPath=%_ProjectPath%_app
 set _FlutterPath=%SYSTEMDRIVE%\src\flutter\bin
 set _BuildTools=%SYSTEMDRIVE%\src\build-tools\30.0.3

 :: Extract date values - language independent
 for /f %%i in ('"powershell (Get-Date).ToString(\"dd\")"') do set day=%%i
 for /f %%i in ('"powershell (Get-Date).ToString(\"MM\")"') do set month=%%i
 for /f %%i in ('"powershell (Get-Date).ToString(\"yyyy\")"') do set year=%%i

 :: Extract time value - for file names 
 set _bTime=%TIME:~0,2%-%TIME:~3,2%-%TIME:~6,2%
 
 :: Set time and date - for file names 
 set _buildTime=%year%-%month%-%day%_%_bTime%
 
 :: Extract time value - for log files  
 set _wTime=%TIME:~0,2%:%TIME:~3,2%:%TIME:~6,2%
 
 :: Set time and date - for log files  
 set _workTime=%day%.%month%.%year% %_wTime%
 
 cls
 echo.
 echo ===================================================================
 echo = Building your Android app - v%_appVersion% (%_appBuild%)
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
 
 echo.
 echo = Generate localization
 start /B /WAIT "" cmd.exe /c "%_FlutterPath%\flutter.bat pub get"
 
 start /B /WAIT "" cmd.exe /c "%_FlutterPath%\flutter.bat gen-l10n --template-arb-file=intl_en.arb"
 start /B /WAIT "" cmd.exe /c "%_FlutterPath%\flutter.bat pub run intl_utils:generate"
 
 echo.
 echo = Build it!
 start /B /WAIT "" cmd.exe /c "%_FlutterPath%\flutter.bat build apk --build-name=%_appVersion% --build-number=%_appBuild%"
 start /B /WAIT "" cmd.exe /c "%_FlutterPath%\flutter.bat build appbundle --build-name=%_appVersion% --build-number=%_appBuild%"
 
 echo ERRORLEVEL: %ERRORLEVEL%
 if %ERRORLEVEL%==0 copy "%_ProjectPath%build\app\outputs\flutter-apk\app-release.apk" "%_OutputPath%\%_buildTime%_%_appVersion%_%_appBuild%.apk"
:: if %ERRORLEVEL%==0 "%_BuildTools%\aapt.exe" dump badging "%_OutputPath%\%_buildTime%_%_appVersion%_%_appBuild%.apk" > "%_OutputPath%\%_buildTime%_%_appVersion%_%_appBuild%.txt"

 if %ERRORLEVEL%==0 copy "%_ProjectPath%build\app\outputs\bundle\release\app-release.aab" "%_OutputPath%\%_buildTime%_%_appVersion%_%_appBuild%.aab"
:: if %ERRORLEVEL%==0 "%LOCALAPPDATA%\Android\Sdk\build-tools\30.0.3\aapt.exe" dump badging "%_OutputPath%\%_buildTime%_%_appVersion%_%_appBuild%.aab" > "%_OutputPath%\%_buildTime%_%_appVersion%_%_appBuild%.txt"

 :: Extract time value - for log files  
 set _wTime=%TIME:~0,2%:%TIME:~3,2%:%TIME:~6,2%
 
 :: Set time and date - for log files  
 set _workTime=%day%.%month%.%year% %_wTime%
 
 echo.
 echo = End: %_workTime%
 echo = Builded your Android app
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