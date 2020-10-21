::dwinternal
xcopy /y /e /i ..\depends\dwinternal\thundervs2015\bin\release\x86\*.dll ..\bin\release
xcopy /y /e /i ..\3rd\soui3\binary\x86\release\dll\*.dll ..\bin\release
xcopy /y /e /i ..\shadow\bin\release\Jocloud.exe ..\bin\release
xcopy /y /e /i ..\shadow\bin\release\Jocloud.pdb ..\bin\release

@echo off
echo %BUILD_NUMBER%>..\bin\release\number.txt