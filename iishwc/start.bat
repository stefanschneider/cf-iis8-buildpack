@echo off

pushd %~dp0..\..
set CONTAINERPATH=%CD%
popd

powershell -ExecutionPolicy bypass "& %~dp0\start.ps1"
set bitness=%ERRORLEVEL%

powershell -ExecutionPolicy bypass "& %~dp0\detectVersion.ps1"
set version=%ERRORLEVEL%

IF %bitness% EQU 0 (
    IF %version% EQU 40 (
        %~dp0\iishwcx64.exe %~dp0applicationHost.config %windir%\Microsoft.NET\Framework\v4.0.30319\Config\web.config %PORT%
    ) ELSE (
        %~dp0\iishwcx64.exe %~dp0applicationHost.config %windir%\Microsoft.NET\Framework\v2.0.50727\Config\web.config %PORT%
    )
) ELSE (
    IF %version% EQU 40 (
        %~dp0\iishwcx86.exe %~dp0applicationHost.config %windir%\Microsoft.NET\Framework\v4.0.30319\Config\web.config %PORT%
    ) ELSE (
        %~dp0\iishwcx86.exe %~dp0applicationHost.config %windir%\Microsoft.NET\Framework\v2.0.50727\Config\web.config %PORT%
    )
)
