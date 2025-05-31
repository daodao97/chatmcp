# Flutter相关的混淆规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Dart相关
-dontwarn io.flutter.embedding.**

# 保留注解
-keepattributes *Annotation*

# 保留泛型信息
-keepattributes Signature

# 保留源文件名和行号信息(用于调试)
-keepattributes SourceFile,LineNumberTable

# 混淆时不使用大小写混合类名
-dontusemixedcaseclassnames

# 不跳过非公共的库类
-dontskipnonpubliclibraryclasses

# 打印混淆的详细信息
-verbose

# 不做预检验，preverify是proguard的四个步骤之一
-dontpreverify

# 保留Serializable序列化的类不被混淆
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# 保留Parcelable序列化的类不被混淆
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# 保留枚举类不被混淆
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 保留原生方法不被混淆
-keepclasseswithmembernames class * {
    native <methods>;
}

# 保留在Activity中的方法参数是view的方法
-keepclassmembers class * extends android.app.Activity {
    public void *(android.view.View);
}

# WebView相关
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# 保留反射使用的类和方法
-keep class * {
    public <methods>;
} 