@ECHO OFF


REM ��Ҫ���ú�java������Android����


REM SHELL������
SET SHELL_DEX_PATH=shell.dex
REM DEX������
SET CLASSES_DEX_PATH=classes.dex
REM key������
SET KEYSTORE_NAME=key.jks
REM key�ı���
SET KEYSTORE_ALIAS=vicky
REM key������
SET KEYSTORE_STOREPASS=123123
SET KEYSTORE_KEYPASS=123123

REM shell����
SET SHELL_TOOL=shelltool.exe
SET TINYXMLDLL=tinyxml2.dll

REM apktool
SET APKTOOL=apktool

SET CLASSESDEX=classes.dex

REM �������ļ���
SET ANTI_PREFIX=anti
REM ��ʱ�ļ�������ʱ�ļ�����
SET TEMP_PREFIX=temp_apk
REM �ӿǺ��ǰ׺
SET RE-SIGNED=shell_
REM asset�����dex�ļ���
SET DEXBIN=apkdata.bin
REM assets
SET ASSETS=assets

FOR %%I IN (*.apk) DO (

    ECHO [�ӿ� %%I]
	
    REM �����ļ��У�����Ѵ�������ɾ��
    RD /S /Q ��%%I��
    MD ��%%I��\%TEMP_PREFIX%
    REM ������Ҫapk�ļ�����ʱ�ļ�����
    COPY %%I ��%%I��\%TEMP_PREFIX%
    REM ����key��APKͬ���ļ�����
    COPY %KEYSTORE_NAME% ��%%I��
	REM ����shell.dex��APKͬ���ļ����е���ʱ�ļ���
    COPY %SHELL_DEX_PATH% ��%%I��\%TEMP_PREFIX%

	REM ������apk
	%APKTOOL% -o %cd%\��%%I��\%TEMP_PREFIX%\%ANTI_PREFIX% d %cd%\��%%I��\%TEMP_PREFIX%\%%I
	REM �޸�AndroidManifest.xml
	%SHELL_TOOL% -m com.vicky.troy.TroyApplication %cd%\��%%I��\%TEMP_PREFIX%\%ANTI_PREFIX%\AndroidManifest.xml
	%APKTOOL% -f -o %%I b %cd%\��%%I��\%TEMP_PREFIX%\%ANTI_PREFIX%
	RD /S /Q %cd%\��%%I��\%TEMP_PREFIX%\%ANTI_PREFIX%
	
    REM ������ʱ�ļ���
    CD ��%%I��\%TEMP_PREFIX%
	
    REM ��ѹAPK�ļ�
    JAR -xf %%I
	REM ɾ��MANIFEST
    RD /S /Q META-INF
	REM ɾ��ԭ����classdex
	DEL %CLASSESDEX%
	
	REM ����APK��
	REN %%I %DEXBIN%
	REM ����assets
	MD %ASSETS%
	REM ���Ƹ������classdex��assets
	MOVE %DEXBIN% %ASSETS%
	REM ����shelldex��
	REN %SHELL_DEX_PATH% %CLASSES_DEX_PATH%
	
	REM ����ѹ����apk�ļ�
    ECHO [���´����APK]
    JAR -cf ../%TEMP_PREFIX%%%I ./
    CD ..

    ECHO [JARSIGNER %%I]
    REM ��APK������ǩ��,JDK1.7��Ҫ���Ӳ���
    JARSIGNER -digestalg SHA1 -sigalg MD5withRSA  -KEYSTORE %KEYSTORE_NAME% -STOREPASS %KEYSTORE_STOREPASS% %TEMP_PREFIX%%%I %KEYSTORE_ALIAS% -KEYPASS %KEYSTORE_KEYPASS%
  
    ECHO [ɾ��JARSIGNER��ʱ�ļ�]
    RD /S /Q %TEMP_PREFIX%
    REM ɾ��ͬ���ļ����и��Ƶ�keystore
    DEL %KEYSTORE_NAME%
  
    ECHO [zipalign %%I]
    REM ʹ��android��zipalign���߶�apk�ļ������Ż�
    ..\zipalign  4 %TEMP_PREFIX%%%I %RE-SIGNED%%%I
    REM ���apk�ļ��Ƿ��Ż�
    ..\zipalign -c  4 %RE-SIGNED%%%I
    REM ɾ���Ż�ǰ��APK�ļ��������Ż����APK
    DEL %TEMP_PREFIX%%%I
    CD ..
    ECHO [�ӿ����]  %RE-SIGNED%%%I
    ECHO.
)
 
PAUSE
@ECHO ON