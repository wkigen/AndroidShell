package com.vicky.troy;

import android.util.Log;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Map;

/**
 * Created by Dell on 2016/7/1.
 */
public class RefInvoke {
    private final static String TAG = RefInvoke.class.getSimpleName();

    public static  Object invokeStaticMethod(String className, String methodName, Class[] types, Object[] vaules){
        try
        {
            Class obj_class = Class.forName(className);
            Method method = obj_class.getMethod(methodName,types);
            return method.invoke(null, vaules);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            Log.e(TAG,e.getMessage());
            return null;
        }

    }

    public static  Object getDeclaredField(String className,Object obj, String filedName)
    {
        try
        {
            Class obj_class = Class.forName(className);
            Field field = obj_class.getDeclaredField(filedName);
            field.setAccessible(true);
            return field.get(obj);
        }
        catch (Exception e)
        {
            e.printStackTrace();
            Log.e(TAG,e.getMessage());
            return null;
        }
    }

    public static void setFieldOjbect(String className, String filedName, Object obj, Object vaule) {
        try {
            Class obj_class = Class.forName(className);
            Field field = obj_class.getDeclaredField(filedName);
            field.setAccessible(true);
            field.set(obj, vaule);
        } catch (Exception e) {
            e.printStackTrace();
            Log.e(TAG, e.getMessage());
        }
    }

    public static  Object invokeMethod(String className, String methodName, Object obj ,Class[] types, Object[] vaules) {

        try {
            Class obj_class = Class.forName(className);
            Method method = obj_class.getMethod(methodName, types);
            return method.invoke(obj, vaules);
        } catch (Exception e) {
            e.printStackTrace();
            Log.e(TAG,e.getMessage());
            return null;
        }
    }
}
