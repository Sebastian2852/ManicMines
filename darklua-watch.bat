@echo off
setlocal EnableDelayedExpansion

:: Get release mode input
set /p RELEASE_MODE="Release mode? [y/n]: "
set "WATCH_DIR=.\Source"

echo ---------------------------------------
echo Starting darklua watch
if /i "%RELEASE_MODE%"=="y" (
    echo compiling scripts in release mode
) else (
    echo compiling scripts in debug mode
)
echo ---------------------------------------

:: Set command based on release mode
if /i "%RELEASE_MODE%"=="y" (
    set "COMMAND=darklua process Source Build --config release.darklua.json"
) else (
    set "COMMAND=darklua process Source Build --config debug.darklua.json"
)

:loop
%COMMAND%
timeout /t 1 /nobreak >nul
goto loop
