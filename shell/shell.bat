@ECHO OFF


REM 需要配置好java环境和Android环境


REM SHELL的名称
SET SHELL_DEX_PATH=shell.dex
REM DEX的名称
SET CLASSES_DEX_PATH=classes.dex
REM key的名称
SET KEYSTORE_NAME=key.jks
REM key的别名
SET KEYSTORE_ALIAS=vicky
REM key的密码
SET KEYSTORE_STOREPASS=123123
SET KEYSTORE_KEYPASS=123123

REM shell工具
SET SHELL_TOOL=shelltool.exe
SET TINYXMLDLL=tinyxml2.dll

REM apktool
SET APKTOOL=apktool

SET CLASSESDEX=classes.dex

REM 反编译文件夹
SET ANTI_PREFIX=anti
REM 临时文件名或临时文件夹名
SET TEMP_PREFIX=temp_apk
REM 加壳后的前缀
SET RE-SIGNED=shell_
REM asset里面的dex文件名
SET DEXBIN=apkdata.bin
REM assets
SET ASSETS=assets

FOR %%I IN (*.apk) DO (

    ECHO [加壳 %%I]
	
    REM 创建文件夹，如果已存在则先删除
    RD /S /Q 【%%I】
    MD 【%%I】\%TEMP_PREFIX%
    REM 复制需要apk文件到临时文件夹中
    COPY %%I 【%%I】\%TEMP_PREFIX%
    REM 复制key到APK同名文件夹中
    COPY %KEYSTORE_NAME% 【%%I】
	REM 复制shell.dex到APK同名文件夹中的临时文件夹
    COPY %SHELL_DEX_PATH% 【%%I】\%TEMP_PREFIX%

	REM 反编译apk
	%APKTOOL% -o %cd%\【%%I】\%TEMP_PREFIX%\%ANTI_PREFIX% d %cd%\【%%I】\%TEMP_PREFIX%\%%I
	REM 修改AndroidManifest.xml
	%SHELL_TOOL% -m com.vicky.troy.TroyApplication %cd%\【%%I】\%TEMP_PREFIX%\%ANTI_PREFIX%\AndroidManifest.xml
	%APKTOOL% -f -o %%I b %cd%\【%%I】\%TEMP_PREFIX%\%ANTI_PREFIX%
	RD /S /Q %cd%\【%%I】\%TEMP_PREFIX%\%ANTI_PREFIX%
	
    REM 进入临时文件夹
    CD 【%%I】\%TEMP_PREFIX%
	
    REM 解压APK文件
    JAR -xf %%I
	REM 删除MANIFEST
    RD /S /Q META-INF
	REM 删除原来的classdex
	DEL %CLASSESDEX%
	
	REM 更改APK名
	REN %%I %DEXBIN%
	REM 创建assets
	MD %ASSETS%
	REM 复制改名后的classdex到assets
	MOVE %DEXBIN% %ASSETS%
	REM 更改shelldex名
	REN %SHELL_DEX_PATH% %CLASSES_DEX_PATH%
	
	REM 重新压缩成apk文件
    ECHO [重新打包成APK]
    JAR -cf ../%TEMP_PREFIX%%%I ./
    CD ..

    ECHO [JARSIGNER %%I]
    REM 对APK包重新签名,JDK1.7需要增加参数
    JARSIGNER -digestalg SHA1 -sigalg MD5withRSA  -KEYSTORE %KEYSTORE_NAME% -STOREPASS %KEYSTORE_STOREPASS% %TEMP_PREFIX%%%I %KEYSTORE_ALIAS% -KEYPASS %KEYSTORE_KEYPASS%
  
    ECHO [删除JARSIGNER临时文件]
    RD /S /Q %TEMP_PREFIX%
    REM 删除同名文件夹中复制的keystore
    DEL %KEYSTORE_NAME%
  
    ECHO [zipalign %%I]
    REM 使用android的zipalign工具对apk文件进行优化
    ..\zipalign  4 %TEMP_PREFIX%%%I %RE-SIGNED%%%I
    REM 检查apk文件是否被优化
    ..\zipalign -c  4 %RE-SIGNED%%%I
    REM 删除优化前的APK文件，保留优化后的APK
    DEL %TEMP_PREFIX%%%I
    CD ..
    ECHO [加壳完成]  %RE-SIGNED%%%I
    ECHO.
)
 
PAUSE
@ECHO ON