@echo off

cd bpm_setup

@echo Compiling for Windows-x64
dotnet publish -r win-x64 -c Release /p:PublishSingleFile=true >NUL

@echo Compiling for Windows-x86
dotnet publish -r win-x86 -c Release /p:PublishSingleFile=true >NUL

@echo Compiling for Linux-x64
dotnet publish -r linux-x64 -c Release /p:PublishSingleFile=true >NUL

@echo Compiling for Mac-x64
dotnet publish -r osx-x64 -c Release /p:PublishSingleFile=true >NUL