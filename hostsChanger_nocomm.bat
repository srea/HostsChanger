@ECHO off
:RESTART
SETLOCAL ENABLEDELAYEDEXPANSION
SET HOSTS=C:\WINDOWS\system32\drivers\etc\
SET PRINT_HOST=0
IF "%RE%"=="1" GOTO RE
cd  %~dp1
IF NOT EXIST "hosts_files\hosts_backup.txt" (
    ECHO 上記パスにディレクトリを作成し、現在のhostsのバックアップを行います。
    ECHO 初期設定を行いますか？(y/n^)
    SET /p SHO=""
    IF /i NOT "!SHO!"=="y" GOTO END
    mkdir hosts_files
    copy /V %HOSTS%hosts hosts_files\hosts_backup.txt >nul
    ECHO 127.0.0.1 localhost > hosts_files\example.txt
    ECHO ::1 localhost >> hosts_files\example.txt
    ECHO 現在のhostsをバックアップしました。
    ECHO hosts_filesフォルダを作成しました。
    ECHO hosts_filesの中にあるexample.txt
    ECHO を参考に設定ファイルを作成し、
    ECHO Enterを押してください。
	PAUSE >nul
    GOTO START
)
:START
ECHO DNS Flushing...
ipconfig /flushdns
cls
set errorlevel=
SET /A count=0
SET mode=0
SET NOW=0
SET FILES=0
FOR %%A IN ( hosts_files\*.txt ) DO SET /A FILES=FILES+1
ECHO +-+-+-+-+-+-+-+-+-+-+
ECHO -   HOSTS CHANGER   -
ECHO +-+-+-+-+-+-+-+-+-+-+
FOR /F %%A IN ('dir /b hosts_files\*.txt') do (
    SET /A count=count+1
	SET CNT=0000!count!
    IF "%NUM%"=="!count!" (
   		SET /p X=^><nul
   		SET NOW=!count!
    )
    IF NOT "%NUM%"=="!count!" SET /p X=-<nul
    ECHO [!CNT:~-2!] : %%~nA
)
IF "%NOW%"=="%count%" SET NUM=
if "%count%"=="0" (
	ECHO hosts_filesフォルダに*.txtの形式で
	ECHO hostsファイルを入れてください。
	ECHO Enterで再チェックします。
	ECHO +-+-+-+-+-+-+-+-+-+-+
	PAUSE > nul
	GOTO START
)
IF "%NUM%"=="0" ECHO.^>[ 0] : RESET
IF "%NUM%" NEQ "0" ECHO.-[ 0] : RESET
ECHO. [ h] : HELP
IF "%PRINT_HOST%"=="1" GOTO PRINTHOST
IF "%NUM%"=="p" ( 
	:PRINTHOST
	SET NUM=
    ECHO +-+-+-+-+-+-+-+-+-+-+
    FOR /F "delims=" %%a IN (C:\WINDOWS\system32\drivers\etc\hosts) DO (
	    ECHO %%a 
    )
)
IF NOT "%NUM%"=="p" SET NUM=
ECHO +-+-+-+-+-+-+-+-+-+-+
SET /p NUM="Enter the number. >"
IF /i "%NUM%"=="e" GOTO EDIT
IF /i "%NUM%"=="p" GOTO START
IF /i "%NUM%"=="h" GOTO HELP
IF "%NUM%"=="" (
    IF NOT "%NOW%"=="%count%" SET /A NUM=%NOW%
	SET /A NUM=NUM+1
    IF     "%NOW%"=="%count%" (
    	ENDLOCAL
    	SET RE=1
    	GOTO RESTART
    	:RE
    	SET /A NUM=0
	)
)
IF "%NUM%"=="0" (
    ECHO 127.0.0.1 localhost > %HOSTS%hosts
    ECHO ::1 localhost >> %HOSTS%hosts
    GOTO START
)
IF NOT "%NUM%"=="" GOTO SEARCH
GOTO START
:SEARCH
SET /A search=0
SET FILENAME=
FOR /F %%A IN ('dir /b hosts_files\*.txt') do (
    SET /A search=search+1
    SET FILENAME=%%A
    IF "%NUM%"=="!search!" IF "%mode%"=="0" GOTO REWRITE
    IF "%NUM2%"=="!search!" IF "%mode%"=="1" GOTO MENU
)
@ECHO Nothing... No.%NUM%
PAUSE > nul
GOTO START
:REWRITE
IF NOT EXIST "hosts_files\%FILENAME%" (
    ECHO ファイルが存在しません．処理を終了します．
    GOTO :EOF
)
cd /d %~dp0
SET ck=hosts_files
@ECHO #hosts changer > C:\WINDOWS\system32\drivers\etc\hosts
FOR /F "delims=" %%a IN (%ck%\%FILENAME%) DO (
    @ECHO %%a >> C:\WINDOWS\system32\drivers\etc\hosts
)
GOTO START
:EDIT
cls
SET NUM2=
SET /A count=0
SET mode=1
ECHO +-+-+-+-+-+-+-+-+-+-+
ECHO -   HOSTS MANAGER   -
ECHO +-+-+-+-+-+-+-+-+-+-+
FOR /F %%A IN ('dir /b hosts_files\*.txt') do (
    SET /A count=count+1
    ECHO [!count!] : %%A
)
ECHO [n] : New File
ECHO [0] : Back
ECHO +-+-+-+-+-+-+-+-+-+-+
SET /p NUM2="Enter the number. >"

IF "%NUM2%"=="n" GOTO NEWFILE
IF "%NUM2%"=="0" GOTO START
IF NOT "%NUM2%"=="" GOTO SEARCH
GOTO START
:NEWFILE
cls
SET NEWFILENAME=
SET NEWFILENTEXT=
SET /p NEWFILENAME="ファイル名は？ >"
IF "%NEWFILENAME%"=="" (GOTO EDIT)
:MORE
SET /p NEWFILETEXT="書き込む内容は？ >"
IF "%NEWFILETEXT%"=="" (GOTO EDIT)
ECHO %NEWFILETEXT% >> hosts_files\%NEWFILENAME%
SET NEWFILETEXT=
GOTO MORE
GOTO EDIT
:MENU
cls
SET NUM2=
SET NUM3=
ECHO +-+-+-+-+-+-+-+-+-+-+
ECHO %FILENAME% 
ECHO +-+-+-+-+-+-+-+-+-+-+
ECHO [1] : INSERT
ECHO [2] : UPDATE
ECHO [3] : DELETE
ECHO [4] : RENAME
ECHO [5] : DROP
ECHO [0] : BACK
ECHO [x] : Notepad
ECHO +-+-+-+-+-+-+-+-+-+-+
SET /p NUM3="Enter the number. >"
IF "%NUM3%"=="1" GOTO INSERT
IF "%NUM3%"=="2" GOTO MODIFY
IF "%NUM3%"=="3" GOTO DELETE
IF "%NUM3%"=="4" GOTO RENAME
IF "%NUM3%"=="5" GOTO DROP
IF "%NUM3%"=="0" GOTO EDIT
IF "%NUM3%"=="x" (
    start notepad "hosts_files\%FILENAME%"
    ECHO 編集が終わったらEnterを押してください。
    PAUSE > nul
    GOTO START
)
GOTO EDIT 
:INSERT
SET TEXT=
SET /p TEXT="INSERT >"
IF "%TEXT%"=="" GOTO MENU
@ECHO %TEXT% >> hosts_files\%FILENAME%
ECHO 終了する場合は、そのままEnter
GOTO INSERT
:MODIFY
SET NUM2=
ECHO +-+-+-+-+-+-+-+-+-+-+
SET /A count=0
FOR /F "delims=" %%a IN (hosts_files\%FILENAME%) DO (
    SET /A count=count+1
    IF "%UPNUM%"=="!count!" (
	type hosts_files\%FILENAME% | find /v "%%a" > hosts_files\tmp_%FILENAME%
	del hosts_files\%FILENAME%
	ren hosts_files\tmp_%FILENAME% %FILENAME%
	SET UPNUM=
    GOTO MODIFY
    )
    @ECHO No.!count! ^> %%a
)
ECHO +-+-+-+-+-+-+-+-+-+-+
SET UPNUM=
ECHO 終了する場合は、そのままEnter
SET /p UPNUM="Update num >"
IF "%UPNUM%"=="" GOTO MENU
GOTO MODIFY
GOTO START
:DELETE
SET NUM2=
ECHO +-+-+-+-+-+-+-+-+-+-+
SET /A count=0
FOR /F "delims=" %%a IN (hosts_files\%FILENAME%) DO (
    SET /A count=count+1
    IF "%DELNUM%"=="!count!" (
	type hosts_files\%FILENAME% | fINd /v "%%a" > hosts_files\tmp_%FILENAME%
	del hosts_files\%FILENAME%
	ren hosts_files\tmp_%FILENAME% %FILENAME%
	SET DELNUM= 
	GOTO DELETE
    )
    @ECHO No.!count! ^> %%a
)
ECHO +-+-+-+-+-+-+-+-+-+-+
SET DELNUM=
SET /p DELNUM="Delete Num >"
IF "%DELNUM%"=="" GOTO MENU
GOTO DELETE
GOTO START
:RENAME
SET NAME=
ECHO Alt + 半角/漢字で日本語入力
SET /p NAME="New FileName >" 
IF "%NAME%"=="" GOTO MENU
ren hosts_files\%FILENAME% %NAME%
GOTO START
:DROP
del /p hosts_files\%FILENAME%
GOTO EDIT
:HELP
cls
ECHO +-+-+-+-+-+-+-+-+-+-+
ECHO **  command  **
ECHO +-+-+-+-+-+-+-+-+-+-+
ECHO p 現在のhosts内容を出力
ECHO e hosts管理メニュー
ECHO.
ECHO +-+-+-+-+-+-+-+-+-+-+
ECHO ** Short cut **
ECHO +-+-+-+-+-+-+-+-+-+-+
ECHO Enter the number. ^> (未入力Enterで終了or戻る)
ECHO (※但し、changer画面では順番にhosts切り替え)
SET NUM=
PAUSE > nul
GOTO START
GOTO END
ENDLOCAL
:END