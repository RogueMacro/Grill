@echo off

@echo Making bpm

cd bpm

@echo Compiling for Windows-x64
dotnet publish -r win-x64 -c Release /p:IncludeSymbolsInSingleFile=true /p:PublishSingleFile=true >NUL

@echo Compiling for Windows-x86
dotnet publish -r win-x86 -c Release /p:IncludeSymbolsInSingleFile=true /p:PublishSingleFile=true >NUL

@echo Compiling for Linux-x64
dotnet publish -r linux-x64 -c Release /p:IncludeSymbolsInSingleFile=true /p:PublishSingleFile=true >NUL

@echo Compiling for Mac-x64
dotnet publish -r osx-x64 -c Release /p:IncludeSymbolsInSingleFile=true /p:PublishSingleFile=true >NUL
rem /p:PublishSingleFile=true 
@echo Copying files

cd bin\Release\netcoreapp3.1\win-x64\publish
if exist bpm-win-x64.exe ( del /q bpm-win-x64.exe )
rename bpm.exe bpm-win-x64.exe
copy bpm-win-x64.exe ..\..\..\..\..\..\bpm_setup\Resources\ /Y >NUL

cd ..\..\win-x86\publish
if exist bpm-win-x86.exe ( del /q bpm-win-x86.exe )
rename bpm.exe bpm-win-x86.exe
copy bpm-win-x86.exe ..\..\..\..\..\..\bpm_setup\Resources\ /Y >NUL

cd ..\..\linux-x64\publish
if exist bpm-linux-x64 ( del /q bpm-linux-x64 )
rename bpm bpm-linux-x64
copy bpm-linux-x64 ..\..\..\..\..\..\bpm_setup\Resources\ /Y >NUL

cd ..\..\osx-x64\publish
if exist bpm-osx-x64 ( del /q bpm-osx-x64 )
rename bpm bpm-osx-x64
copy bpm-osx-x64 ..\..\..\..\..\..\bpm_setup\Resources\ /Y >NUL

cd ..\..\..\..\..\..\