-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

-dontwarn com.google.android.play.core.**
-dontwarn androidx.**
-dontwarn okhttp3.**
-dontwarn okio.**

-keep class com.tav.reseller.** { *; }
-dontwarn com.tav.reseller.**

-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod