@echo off
rem 清空输出文件夹并创建
rd /s /q ".\output" 2>nul
mkdir ".\output"

rem 便利src/lib文件夹下的.j文件
for /r ".\src\lib" %%i in (*.j) do (
    rem 在输出文件中添加文件名注释
    echo///=========================================================================== >> ".\output\release.j"
    echo/// filename is %%~nxi >> ".\output\release.j"
    echo///=========================================================================== >> ".\output\release.j"
    rem 将文件内容追加到输出文件中
    type "%%i" >> ".\output\release.j"
    rem 添加换行
    echo. >> ".\output\release.j"
)

rem 遍历src文件夹下的.j文件
for /r ".\src" %%i in (*.j) do (
    rem 检查是否在lib文件夹内
    echo %%i | findstr /I /C:"\\lib\\" >nul
    if errorlevel 1 (
        rem 在输出文件中添加文件名注释
        echo///=========================================================================== >> ".\output\release.j"
        echo/// filename is %%~nxi >> ".\output\release.j"
        echo///=========================================================================== >> ".\output\release.j"
        rem 将文件内容追加到输出文件中
        type "%%i" >> ".\output\release.j"
        rem 添加换行
        echo. >> ".\output\release.j"
    )
)
