package com.vicky.troy;

import android.app.Application;
import android.app.Instrumentation;
import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import dalvik.system.DexClassLoader;

/**
 * Created by Dell on 2016/7/1.
 */
public class TroyApplication extends Application {

    private static final String TAG = TroyApplication.class.getSimpleName();


    @Override
    protected void attachBaseContext(Context context) {
        super.attachBaseContext(context);

        try
        {
            File dexPath = this.getDir("dexPath", MODE_PRIVATE);
            File libPath = this.getDir("libPath", MODE_PRIVATE);

            String readDexPath = dexPath.getAbsolutePath() + "/outdex.apk";
            //解密DEX
            decryptDex(readDexPath);

            // 获取ActivityThread
            Object currentActivityThread = RefInvoke.invokeStaticMethod(
                    "android.app.ActivityThread", "currentActivityThread",
                    new Class[]{}, new Object[]{});

            String packageName = this.getPackageName();
            HashMap mPackages = (HashMap) RefInvoke.getDeclaredField(
                    "android.app.ActivityThread", currentActivityThread,
                    "mPackages");

            //HashMap<String, WeakReference<LoadedApk>>
            WeakReference loadedApk = (WeakReference) mPackages.get(packageName);

            //替换DexClassLoader
            DexClassLoader dexLoader = new DexClassLoader(readDexPath, dexPath.getAbsolutePath(),
                    libPath.getAbsolutePath(), (ClassLoader) RefInvoke.getDeclaredField(
                    "android.app.LoadedApk", loadedApk.get(), "mClassLoader"));

            RefInvoke.setFieldOjbect("android.app.LoadedApk", "mClassLoader",
                    loadedApk.get(), dexLoader);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            Log.e(TAG, e.getMessage());
            System.exit(0);
        }
    }

    public void onCreate()
    {
        super.onCreate();

        // 替换application
        String appClassName = null;
        try {
            ApplicationInfo applicationInfo = this.getPackageManager().getApplicationInfo(this.getPackageName(), PackageManager.GET_META_DATA);
            Bundle bundle = applicationInfo.metaData;
            if (bundle != null && bundle.containsKey("VICKY_APPLICATION_CLASS_NAME")) {
                appClassName = bundle.getString("VICKY_APPLICATION_CLASS_NAME");
            } else {
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            Log.e(TAG, e.getMessage());
            System.exit(0);
        }

        //ActivityThread
        Object currentActivityThread = RefInvoke.invokeStaticMethod(
                "android.app.ActivityThread", "currentActivityThread",
                new Class[] {}, new Object[] {});

        //AppBindData
        Object mBoundApplication = RefInvoke.getDeclaredField(
                "android.app.ActivityThread", currentActivityThread,
                "mBoundApplication");

        //AppBindData.info
        Object loadedApkInfo = RefInvoke.getDeclaredField(
                "android.app.ActivityThread$AppBindData",
                mBoundApplication, "info");

        //置空
        RefInvoke.setFieldOjbect("android.app.LoadedApk", "mApplication",
                loadedApkInfo, null);

        //移除TroyApplication
        Object oldApplication = RefInvoke.getDeclaredField(
                "android.app.ActivityThread", currentActivityThread,
                "mInitialApplication");
        ArrayList<Application> mAllApplications = (ArrayList<Application>) RefInvoke
                .getDeclaredField("android.app.ActivityThread",
                        currentActivityThread, "mAllApplications");
        mAllApplications.remove(oldApplication);

        ApplicationInfo appinfo_In_LoadedApk = (ApplicationInfo) RefInvoke
                .getDeclaredField("android.app.LoadedApk", loadedApkInfo,
                        "mApplicationInfo");

        ApplicationInfo appinfo_In_AppBindData = (ApplicationInfo) RefInvoke
                .getDeclaredField("android.app.ActivityThread$AppBindData",
                        mBoundApplication, "appInfo");


        appinfo_In_LoadedApk.className = appClassName;
        appinfo_In_AppBindData.className = appClassName;

        //创建application
        Application app = (Application) RefInvoke.invokeMethod(
                "android.app.LoadedApk", "makeApplication", loadedApkInfo,
                new Class[] { boolean.class, Instrumentation.class },
                new Object[] { false, null });
        RefInvoke.setFieldOjbect("android.app.ActivityThread",
                "mInitialApplication", currentActivityThread, app);


        HashMap mProviderMap = (HashMap) RefInvoke.getDeclaredField(
                "android.app.ActivityThread", currentActivityThread,
                "mProviderMap");
        Iterator it = mProviderMap.values().iterator();
        while (it.hasNext()) {
            Object providerClientRecord = it.next();
            Object localProvider = RefInvoke.getDeclaredField(
                    "android.app.ActivityThread$ProviderClientRecord",
                    providerClientRecord, "mLocalProvider");
            RefInvoke.setFieldOjbect("android.content.ContentProvider",
                    "mContext", localProvider, app);
        }

        app.onCreate();
    }

    private void decryptDex(String outDex)
    {
        try
        {
            ByteArrayOutputStream outputByteStream = new ByteArrayOutputStream();
            InputStream inputStream =  getAssets().open("apkdata.bin");

            byte[] temp = new byte[1024];

            int i = 0;
            while((i=inputStream.read(temp))!=-1)
            {
                outputByteStream.write(temp,0,i);
            }

            inputStream.close();
            byte[] dexData = outputByteStream.toByteArray();
            outputByteStream.close();

            FileOutputStream fileOutStream = new FileOutputStream(outDex);
            fileOutStream.write(dexData, 0, dexData.length);
            fileOutStream.close();

        }
        catch (Exception e)
        {
            e.printStackTrace();
            Log.e(TAG, e.getMessage());
            System.exit(0);
        }
    }
}
