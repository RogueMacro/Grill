@echo off

@echo Making setup files

cd bpm_setup

@echo Compiling for Windows-x64
dotnet publish -r win-x64 -c Release /p:PublishSingleFile=true >NUL

@echo Compiling for Windows-x86
dotnet publish -r win-x86 -c Release /p:PublishSingleFile=true >NUL

@echo Compiling for Linux-x64
dotnet publish -r linux-x64 -c Release /p:PublishSingleFile=true >NUL

@echo Compiling for Mac-x64
dotnet publish -r osx-x64 -c Release /p:PublishSingleFile=true >NUL

cd ..

if exist setup-files rmdir setup-files /s /q
mkdir setup-files

copy bpm_setup\bin\Release\netcoreapp3.1\win-x64\publish\bpm_setup.exe setup-files /y >NUL
rename setup-files\bpm_setup.exe bpm_setup-win64.exe

copy bpm_setup\bin\Release\netcoreapp3.1\win-x86\publish\bpm_setup.exe setup-files /y >NUL
rename setup-files\bpm_setup.exe bpm_setup-win32.exe

copy bpm_setup\bin\Release\netcoreapp3.1\osx-x64\publish\bpm_setup setup-files /y >NUL
rename setup-files\bpm_setup bpm_setup-mac

copy bpm_setup\bin\Release\netcoreapp3.1\linux-x64\publish\bpm_setup setup-files /y >NUL
rename setup-files\bpm_setup bpm_setup-linux